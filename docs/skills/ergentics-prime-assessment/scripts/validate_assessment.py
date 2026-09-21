#!/usr/bin/env python3
"""Finite, read-only validation of supplied assessment metadata; no discovery."""

import argparse
from datetime import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import sys

SHA = re.compile(r'[0-9a-f]{64}\Z')
SENSITIVE = re.compile(r'(?:\.ssh|\.aws|\.netrc|\.env.*|auth\.json|credentials.*|secrets.*)\Z', re.I)
FILE_CAP = 512 * 1024 * 1024
RECORD_CAP = 16 * 1024 * 1024


class Invalid(ValueError):
    pass


def require(condition, message):
    if not condition:
        raise Invalid(message)


def nonempty(value):
    return isinstance(value, str) and bool(value.strip())


def evidence(value):
    return isinstance(value, list) and bool(value) and all(nonempty(x) for x in value)


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, 'duplicate JSON key')
        result[key] = value
    return result


def parse_record(data):
    def invalid_constant(_):
        raise Invalid('non-finite JSON number')
    return json.loads(data, object_pairs_hook=unique_object, parse_constant=invalid_constant)


def identity(value):
    return (value.st_dev, value.st_ino, value.st_mode, value.st_size,
            value.st_mtime_ns, value.st_ctime_ns)


def open_regular(path):
    """Return one owned descriptor after a fresh absolute no-symlink walk."""
    path = Path(path)
    require(path.is_absolute() and '..' not in path.parts, 'file path must be absolute and normalized')
    require(not any(SENSITIVE.fullmatch(p) for p in path.parts), 'excluded credential-like path')
    directory = os.open('/', os.O_RDONLY | os.O_DIRECTORY | os.O_CLOEXEC)
    leaf = None
    try:
        for component in path.parts[1:-1]:
            child = os.open(component, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW | os.O_CLOEXEC,
                            dir_fd=directory)
            os.close(directory)
            directory = child
        leaf = os.open(path.name, os.O_RDONLY | os.O_NONBLOCK | os.O_NOFOLLOW | os.O_CLOEXEC,
                       dir_fd=directory)
        require(stat.S_ISREG(os.fstat(leaf).st_mode), 'not a regular file')
        result, leaf = leaf, None
        return result
    finally:
        if leaf is not None:
            os.close(leaf)
        os.close(directory)


def read_regular(path, cap, collect=False):
    """Bound reads and rejoin the current absolute pathname before success."""
    leaf = open_regular(path)
    try:
        before = os.fstat(leaf)
        require(before.st_size <= cap, 'file exceeds read cap')
        hasher = hashlib.sha256()
        chunks = []
        total = 0
        while total <= cap:
            chunk = os.read(leaf, min(65536, cap + 1 - total))
            if not chunk:
                break
            total += len(chunk)
            hasher.update(chunk)
            if collect:
                chunks.append(chunk)
        require(total <= cap, 'file grew beyond read cap')
        after = os.fstat(leaf)
        # A retained parent descriptor alone would miss ancestor replacement.
        named_leaf = open_regular(path)
        try:
            named = os.fstat(named_leaf)
        finally:
            os.close(named_leaf)
        require(identity(before) == identity(after) == identity(named) and total == before.st_size,
                'file identity changed during read')
        return hasher.hexdigest(), b''.join(chunks) if collect else None
    finally:
        os.close(leaf)


def keyed(rows, key, label):
    require(isinstance(rows, list), label + ' must be a list')
    result = {}
    for row in rows:
        require(isinstance(row, dict) and nonempty(row.get(key)), label + ' has an invalid ID')
        require(row[key] not in result, label + ' has a duplicate ID')
        result[row[key]] = row
    return result


def validate(record, check_files=False):
    require(isinstance(record, dict), 'record must be an object')
    require(type(record.get('schema_version')) is int and record['schema_version'] == 1,
            'unsupported schema version')
    require(nonempty(record.get('assessment_id')), 'assessment_id is required')
    scope = record.get('scope', {})
    require(isinstance(scope, dict) and nonempty(scope.get('question')), 'scope question is required')
    roots = scope.get('roots')
    require(isinstance(roots, list) and roots and all(nonempty(x) for x in roots), 'explicit roots required')
    roots = [Path(p) for p in roots]
    require(all(p.is_absolute() and p != Path('/') and '..' not in p.parts for p in roots), 'invalid scope root')
    required = scope.get('required_surfaces')
    require(isinstance(required, list) and required and all(nonempty(x) for x in required), 'surfaces required')
    require(len(set(required)) == len(required), 'duplicate required surface')
    exclusions = scope.get('exclusions')
    require(isinstance(exclusions, list), 'explicit exclusions required')
    require(all(isinstance(x, dict) and nonempty(x.get('pattern')) and nonempty(x.get('reason'))
                for x in exclusions), 'each exclusion needs pattern and reason')
    inventory = keyed(record.get('inventory'), 'id', 'inventory')
    require(inventory, 'empty inventory cannot establish coverage')
    paths = set()
    checked = 0
    for item in inventory.values():
        require(nonempty(item.get('surface')), 'item surface is required')
        require(item.get('kind') in {'source', 'image', 'record', 'logical'}, 'unknown inventory kind')
        if item['kind'] == 'logical':
            require(nonempty(item.get('description')), 'logical item needs description')
            require('path' not in item and 'sha256' not in item, 'logical item cannot hide a file binding')
            continue
        require(nonempty(item.get('path')), 'file path is required')
        path = Path(item['path'])
        require(path.is_absolute() and '..' not in path.parts and any(path.is_relative_to(p) for p in roots),
                'file outside declared roots')
        require(not any(SENSITIVE.fullmatch(p) for p in path.parts), 'excluded credential-like path')
        require(str(path) not in paths, 'duplicate file path; use one item with multiple evidence references')
        paths.add(str(path))
        require(isinstance(item.get('sha256'), str) and SHA.fullmatch(item['sha256']), 'file SHA-256 required')
        if check_files:
            observed, _ = read_regular(path, FILE_CAP)
            require(observed == item['sha256'], 'file identity differs: ' + str(path))
            checked += 1
    require(set(required) <= {i['surface'] for i in inventory.values()}, 'required surface absent from inventory')
    reviews = keyed(record.get('reviews'), 'item_id', 'reviews')
    require(reviews.keys() == inventory.keys(), 'inventory/review coverage mismatch')
    states = {'pending', 'blocked', 'reviewed', 'fixed', 'retired', 'excluded'}
    for row in reviews.values():
        require(row.get('state') in states and nonempty(row.get('basis')), 'review state/basis required')
        require(isinstance(row.get('evidence'), list), 'review evidence list required')
        if row['state'] not in {'pending', 'blocked'}:
            require(evidence(row['evidence']), 'completed disposition needs evidence')
    verifications = keyed(record.get('verifications'), 'id', 'verifications')
    for row in verifications.values():
        require(row.get('status') in {'pass', 'fail', 'not_run'}, 'invalid verification status')
        require(evidence(row.get('evidence')), 'verification evidence required')
        require(isinstance(row.get('subjects'), dict) and row['subjects'], 'verification subjects required')
        for item_id, sha in row['subjects'].items():
            require(item_id in inventory and isinstance(sha, str) and SHA.fullmatch(sha), 'unknown verification subject or hash')
        require(type(row.get('current', True)) is bool, 'current must be boolean')
        if not row.get('current', True):
            require(nonempty(row.get('history_reason')), 'historical check needs a reason')
        else:
            for item_id, sha in row['subjects'].items():
                require(inventory[item_id].get('sha256') == sha,
                        'current verification must bind the current file identity')
        if row.get('superseded_by') is not None:
            seen = {row['id']}
            latest = row
            while latest.get('superseded_by') is not None:
                next_id = latest['superseded_by']
                require(next_id in verifications and next_id not in seen, 'invalid verification supersession')
                seen.add(next_id)
                latest = verifications[next_id]
                require(latest.get('subjects') == row['subjects'], 'supersession changed the subject identities')
            require(latest.get('status') == 'pass', 'supersession must terminate at a pass')
    findings = keyed(record.get('findings'), 'id', 'findings')
    for row in findings.values():
        require(row.get('state') in {'open', 'fixed', 'accepted_limit'}, 'invalid finding state')
        require(evidence(row.get('evidence')), 'finding evidence required')
        ids = row.get('item_ids')
        require(isinstance(ids, list) and ids and all(i in inventory for i in ids), 'finding item coverage invalid')
        if row['state'] == 'accepted_limit':
            require(nonempty(row.get('reason')), 'accepted limit needs explicit reason')
        if row['state'] == 'fixed':
            checks = row.get('verification_ids')
            require(isinstance(checks, list) and checks and all(x in verifications for x in checks), 'fixed finding needs verification')
            for item_id in ids:
                expected = inventory[item_id].get('sha256')
                require(expected is not None and any(
                    verifications[x]['status'] == 'pass' and verifications[x].get('current', True)
                    and verifications[x]['subjects'].get(item_id) == expected for x in checks
                ), 'fixed finding lacks passing evidence for current bytes')
    live = record.get('live_processes', {})
    require(isinstance(live, dict) and live.get('state') in {'unknown', 'observed'}, 'live-process state required')
    require(isinstance(live.get('evidence'), list) and all(nonempty(x) for x in live['evidence']), 'live evidence list required')
    if live['state'] == 'unknown':
        require(live.get('count') is None, 'unknown live count must remain null')
    else:
        require(type(live.get('count')) is int and live['count'] >= 0, 'invalid observed live count')
        require(evidence(live.get('evidence')) and nonempty(live.get('observed_at')), 'live observation evidence/time required')
        try:
            timestamp = datetime.fromisoformat(live['observed_at'].replace('Z', '+00:00'))
            require(timestamp.tzinfo is not None, 'live observation timestamp needs a timezone')
        except ValueError as error:
            raise Invalid('invalid live observation timestamp') from error
    holds = keyed(record.get('holds'), 'id', 'holds')
    require(all(type(h.get('active')) is bool and nonempty(h.get('reason')) for h in holds.values()), 'hold state/reason required')
    completion = record.get('completion', {})
    require(isinstance(completion, dict) and completion.get('state') in {'in_progress', 'complete_with_limits', 'complete'}
            and nonempty(completion.get('summary')), 'completion state/summary required')
    state = completion['state']
    if state != 'in_progress':
        require(not any(r['state'] == 'pending' for r in reviews.values()), 'pending review prevents completion')
    if state == 'complete':
        require(not any(r['state'] == 'blocked' for r in reviews.values()), 'blocked review prevents unqualified completion')
        require(not any(f['state'] == 'open' for f in findings.values()), 'open finding prevents unqualified completion')
        require('live_processes' not in required or live['state'] == 'observed', 'required live coverage is unknown')
        require(not any(v.get('current', True) and v['status'] != 'pass' and not v.get('superseded_by')
                        for v in verifications.values()), 'failed or unrun current verification remains')
    return {
        'metadata_validation': 'PASS', 'schema_version': 1, 'assessment_id': record['assessment_id'],
        'inventory_items': len(inventory), 'files_verified': checked,
        'declared_completion': state, 'active_holds': [h['id'] for h in holds.values() if h['active']],
        'scope_or_behavior_qualified_by_this_validator': False,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('record')
    parser.add_argument('--check-files', action='store_true')
    arguments = parser.parse_args()
    try:
        _, data = read_regular(Path(arguments.record).absolute(), RECORD_CAP, collect=True)
        record = parse_record(data)
        print(json.dumps(validate(record, arguments.check_files), indent=2))
        return 0
    except (Invalid, OSError, ValueError, TypeError, KeyError, RecursionError) as error:
        print(json.dumps({'metadata_validation': 'FAIL', 'error_type': type(error).__name__, 'error': str(error)}))
        return 1


if __name__ == '__main__':
    sys.exit(main())
