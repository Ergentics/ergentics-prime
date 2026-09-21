#!/usr/bin/env python3
"""Exercise selected evidence distinctions using owned synthetic fixtures."""
import copy
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys
import tempfile
from unittest.mock import patch

PACKAGE = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('prime_assessment_validator', PACKAGE / 'scripts/validate_assessment.py')
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)


def base_record(root):
    source = root / 'fixture.swift'
    source.write_text('// benign owned fixture\n')
    digest = hashlib.sha256(source.read_bytes()).hexdigest()
    return {
        'schema_version': 1, 'assessment_id': 'golden-synthetic',
        'scope': {'roots': [str(root)], 'question': 'Review this source only.',
                  'required_surfaces': ['maintained_source'], 'exclusions': []},
        'inventory': [{'id': 'source', 'surface': 'maintained_source', 'kind': 'source',
                       'path': str(source), 'sha256': digest}],
        'reviews': [{'item_id': 'source', 'state': 'reviewed', 'basis': 'Synthetic fixture inspected.',
                     'evidence': ['owned fixture']}],
        'findings': [],
        'verifications': [{'id': 'check', 'status': 'pass', 'subjects': {'source': digest},
                           'evidence': ['synthetic identity check']}],
        'live_processes': {'state': 'unknown', 'count': None, 'evidence': []},
        'holds': [{'id': 'user_commit_hold', 'active': True, 'reason': 'Retained synthetic user hold.'}],
        'completion': {'state': 'complete', 'summary': 'Source-only result.'},
    }


def run_case(case):
    with tempfile.TemporaryDirectory(prefix='prime-skill-golden-') as temporary:
        root = Path(temporary).resolve()
        record = base_record(root)
        exercise = case['exercise']
        assertion = None
        if exercise == 'unknown_zero':
            record['live_processes']['count'] = 0
        elif exercise == 'stored_copies':
            second = root / 'second.swift'
            second.write_bytes((root / 'fixture.swift').read_bytes())
            row = dict(record['inventory'][0], id='second', path=str(second))
            record['inventory'].append(row)
            record['reviews'].append(dict(record['reviews'][0], item_id='second'))
            assertion = 'two_paths_one_hash_no_live_count'
        elif exercise == 'source_guard_image':
            image = root / 'retained-image.bin'
            image.write_bytes(b'benign synthetic image data, never executed')
            record['inventory'].append({'id': 'image', 'surface': 'retained_images', 'kind': 'image',
                'path': str(image), 'sha256': hashlib.sha256(image.read_bytes()).hexdigest()})
            record['reviews'].append(dict(record['reviews'][0], item_id='image'))
            record['findings'] = [{'id': 'repair', 'state': 'fixed', 'item_ids': ['source', 'image'],
                'evidence': ['source guard only'], 'verification_ids': ['check']}]
        elif exercise == 'stale_pass':
            record['verifications'][0]['subjects']['source'] = '0' * 64
        elif exercise in {'commit_hold', 'source_only', 'baseline'}:
            record['live_processes']['evidence'] = ['An unrelated observation was unavailable.']
        elif exercise == 'sensitive_pre_read':
            record['inventory'][0]['path'] = str(root / '.env.synthetic')
            # This fixture requires rejection before *any* os.open. A generic
            # filesystem failure would not prove the pre-read exclusion.
            with patch.object(validator.os, 'open', side_effect=AssertionError('Unexpected content intake')) as opened:
                try:
                    validator.validate(record, True)
                except validator.Invalid:
                    assert opened.call_count == 0
                    return {'id': case['id'], 'accepted': False, 'pre_read_rejection': True}
            raise AssertionError('Sensitive path accepted')
        elif exercise == 'alias':
            alias = root / 'alias.swift'
            alias.symlink_to(root / 'fixture.swift')
            record['inventory'][0]['path'] = str(alias)
        elif exercise == 'unresolved_failure':
            record['verifications'][0]['status'] = 'fail'
        elif exercise == 'missing_extension':
            record['scope']['required_surfaces'].append('project_extension')
        elif exercise == 'historical_cannot_fix':
            record['verifications'][0].update(current=False, history_reason='Older candidate.',
                subjects={'source': '0' * 64})
            record['findings'] = [{'id': 'repair', 'state': 'fixed', 'item_ids': ['source'],
                'evidence': ['synthetic observation'], 'verification_ids': ['check']}]
        elif exercise == 'limited_result':
            record['scope']['required_surfaces'].append('live_processes')
            record['inventory'].append({'id': 'live', 'surface': 'live_processes', 'kind': 'logical',
                'description': 'Requested snapshot unavailable.'})
            record['reviews'].append({'item_id': 'live', 'state': 'blocked', 'basis': 'Synthetic denial.',
                'evidence': ['synthetic denial observation']})
            record['completion'].update(state='complete_with_limits', summary='Requested live surface unavailable.')
        elif exercise == 'fixed_current':
            record['findings'] = [{'id': 'repair', 'state': 'fixed', 'item_ids': ['source'],
                'evidence': ['synthetic observed correction'], 'verification_ids': ['check']}]
        elif exercise == 'compatible_extension':
            record['scope']['required_surfaces'].append('project_extension')
            record['inventory'].append({'id': 'extension', 'surface': 'project_extension', 'kind': 'logical',
                'description': 'Explicit additional decision surface.', 'project_specific_evidence': {'revision': 1}})
            record['reviews'].append({'item_id': 'extension', 'state': 'reviewed', 'basis': 'Synthetic extension reviewed.',
                'evidence': ['extension result']})
            record['project_extension'] = {'classification': 'additional optional evidence'}
        elif exercise == 'preserved_failure':
            old = copy.deepcopy(record['verifications'][0])
            old.update(id='initial', status='fail', superseded_by='check')
            record['verifications'].insert(0, old)
        else:
            raise AssertionError('Unimplemented golden exercise: ' + exercise)
        original = copy.deepcopy(record)
        try:
            result = validator.validate(record, True)
            accepted = True
        except (validator.Invalid, OSError):
            result = None
            accepted = False
        assert record == original, 'Read-only validation changed the record'
        if accepted:
            assert result['scope_or_behavior_qualified_by_this_validator'] is False
            assert result['active_holds'] == ['user_commit_hold']
            assert record['live_processes']['state'] == 'unknown'
            assert record['live_processes']['count'] is None
            if assertion:
                assert result['files_verified'] == 2
                assert len({r['sha256'] for r in record['inventory']}) == 1
            if exercise == 'preserved_failure':
                assert record['verifications'][0]['status'] == 'fail'
        return {'id': case['id'], 'accepted': accepted, 'record_unchanged': True}


def main():
    collection = json.loads((PACKAGE / 'references/golden-cases.json').read_text())
    cases = collection['executable_cases']
    assert cases and len({r['id'] for r in cases}) == len(cases)
    results = []
    for case in cases:
        row = run_case(case)
        row['expected_acceptance'] = case['expected_acceptance']
        row['pass'] = row['accepted'] == case['expected_acceptance']
        results.append(row)
    passed = all(r['pass'] for r in results)
    print(json.dumps({'golden_executable_result': 'PASS' if passed else 'FAIL',
        'cases': len(results), 'results': results,
        'interpretation_cases_executed_by_this_script': False,
        'native_or_live_system_qualification': False}, indent=2))
    return 0 if passed else 1


if __name__ == '__main__':
    sys.exit(main())
