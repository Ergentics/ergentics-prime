#!/usr/bin/env python3
"""Prepare deterministic neutral-context variants; no inference or training."""
import collections
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOURCE = HERE.parent / 'Comparison'
EXPECTED_MANIFEST_SHA = '1a49ef580dd702567c3a66df443cbb6f1e1b10f08f525ce1648d76612388f80d'
ROLES = ('left_input_ids', 'right_input_ids', 'direct_input_ids', 'final_prefix_ids', 'final_suffix_ids')

def sha(data):
    return hashlib.sha256(data).hexdigest()

def digest(value):
    return sha(json.dumps(value, sort_keys=True, separators=(',', ':')).encode())

def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        assert path.read_bytes() == data, str(path)
    else:
        with path.open('xb') as handle:
            handle.write(data)
    return sha(data)

def save(path, value):
    return write(path, (json.dumps(value, indent=2, sort_keys=True) + '\n').encode())

def input_only(row):
    return dict(zip(('left', 'right', 'direct', 'prefix', 'suffix'), (row[k] for k in ROLES)))

def without_context(ids):
    assert ids[0] == 1
    return ids[:1] + ids[2:] if len(ids) > 1 and ids[1] == 4 else ids[:]

def semantic_inputs(row):
    obj = input_only(row)
    return {k: (v if k == 'suffix' else without_context(v)) for k, v in obj.items()}

def toggle(ids):
    assert ids[0] == 1 and ids.count(4) in (0, 1)
    assert 4 not in ids[2:]
    return ids[:1] + ids[2:] if ids[1] == 4 else ids[:1] + [4] + ids[1:]

def valid_input(row):
    # Eligibility uses input codec fields only, never predictions or target labels.
    left = without_context(row['left_input_ids'])
    right = without_context(row['right_input_ids'])
    return all(len(a) == 6 and a[:2] == [1, 5] and a[-1] == 3
               and 64 <= a[2] <= 68 and 80 <= a[3] <= 84 and 96 <= a[4] <= 98
               for a in (left, right))

def projection(row):
    prefix = row['final_prefix_ids']
    return {'id': row['row_id'], 'allowedValueMinimum': 0, 'allowedValueCount': 16384,
            'jobs': [
                {'inputTokenIDs': row['direct_input_ids'], 'feedbackBindings': []},
                {'inputTokenIDs': row['left_input_ids'], 'feedbackBindings': []},
                {'inputTokenIDs': row['right_input_ids'], 'feedbackBindings': []},
                {'inputTokenIDs': prefix + [0, 0] + row['final_suffix_ids'],
                 'feedbackBindings': [{'inputOffset': len(prefix), 'sourceJobIndex': 1},
                                      {'inputOffset': len(prefix) + 1, 'sourceJobIndex': 2}]}]}

def main():
    manifest_bytes = (SOURCE / 'References/original-manifest.json').read_bytes()
    assert sha(manifest_bytes) == EXPECTED_MANIFEST_SHA
    manifest = json.loads(manifest_bytes)
    bindings_bytes = (SOURCE / 'References/model-bindings.json').read_bytes()
    bindings = json.loads(bindings_bytes)
    eligible = [r for r in manifest['rows'] if valid_input(r)]
    assert len(eligible) == 2109 and all(r['represented'] for r in eligible)
    groups = collections.defaultdict(list)
    for row in eligible:
        groups[row['family_id']].append(row)
    families = sorted(groups)
    assert len(families) == 10
    selected = []
    for index, family in enumerate(families):
        quota = 103 if index < 4 else 102
        ordered = sorted(groups[family], key=lambda r: (digest(input_only(r)), r['row_id']))
        assert len(ordered) >= quota
        selected.extend(ordered[:quota])
    assert len(selected) == 1024
    variants, provenance = [], []
    for source in selected:
        row = dict(source)
        row['row_id'] = 'neutral-toggle-' + source['row_id']
        for role in ROLES[:-1]:
            row[role] = toggle(source[role])
        assert semantic_inputs(row) == semantic_inputs(source)
        assert valid_input(row)
        assert digest(input_only(row)) != digest(input_only(source))
        variants.append(row)
        provenance.append({'id': row['row_id'], 'sourceRowID': source['row_id'],
                           'sourceSplit': source['split'], 'familyID': source['family_id'],
                           'selectionInputSHA256': digest(input_only(source)),
                           'generatedInputSHA256': digest(input_only(row)),
                           'semanticInputSHA256': digest(semantic_inputs(row)),
                           'neutralContextChange': 'removed' if source['left_input_ids'][1] == 4 else 'inserted'})
    cases = [projection(r) for r in variants]
    assert len({c['id'] for c in cases}) == len(cases)
    assert len({digest(input_only(r)) for r in variants}) == len(cases)
    for c in cases:
        assert len(c['id'].encode()) <= 128
        for index, job in enumerate(c['jobs']):
            assert 1 <= len(job['inputTokenIDs']) <= 64
            assert all(type(x) is int and 0 <= x < 16384 and x != 225 for x in job['inputTokenIDs'])
            for b in job['feedbackBindings']:
                assert b['sourceJobIndex'] < index and job['inputTokenIDs'][b['inputOffset']] == 0
    input_sha = save(HERE / 'Inputs/cases.json', {'schema': 'prime_domain_original_evaluation_inputs_v1', 'cases': cases})
    refs = [{'id': r['row_id'], 'sourceSplit': r['split'], 'familyID': r['family_id'],
             'represented': True, 'directTargetID': r['final_target_id'],
             'expectedJobIDs': [r['final_target_id'], r['left_summary_target_id'], r['right_summary_target_id'], r['final_target_id']],
             'engineWinner': r.get('engine_winner'), 'engineEventType': r.get('engine_event_type')}
            for r in variants]
    assert all(192 <= r['directTargetID'] <= 197 and 224 not in r['expectedJobIDs'] for r in refs)
    gold_sha = save(HERE / 'References/gold.json', {'schema': 'prime_domain_original_evaluation_references_v1', 'cases': refs})
    write(HERE / 'References/model-bindings.json', bindings_bytes)
    receipts = []
    for binding in bindings:
        for execution in ('host', 'guest'):
            for batch, offset in enumerate(range(0, len(cases), 16)):
                request = {'schema': 'prime_10m_feedback_inference_request_v2',
                           'weightsPath': binding['weightsPath'], 'weightsSHA256': binding['weightsSHA256'],
                           'execution': execution, 'cases': cases[offset:offset + 16]}
                path = HERE / 'Requests' / ('seed-' + str(binding['seed'])) / execution / ('batch-%03d.json' % batch)
                request_sha = save(path, request)
                receipts.append({'seed': binding['seed'], 'execution': execution, 'batch': batch,
                                 'path': str(path), 'sha256': request_sha, 'caseCount': len(request['cases'])})
    assert len(receipts) == 384
    for binding in bindings:
        for batch in range(64):
            folder = HERE / 'Requests' / ('seed-' + str(binding['seed']))
            h = json.loads((folder / 'host' / ('batch-%03d.json' % batch)).read_bytes())
            g = json.loads((folder / 'guest' / ('batch-%03d.json' % batch)).read_bytes())
            assert h.pop('execution') == 'host' and g.pop('execution') == 'guest' and h == g
    save(HERE / 'References/case-provenance.json', {'cases': provenance})
    all_original = manifest['rows'] + manifest['mutations']
    overlap = {}
    for split in ('train', 'validation', 'holdout', 'mutation'):
        original = [r for r in all_original if r['split'] == split]
        full = {digest(input_only(r)) for r in original}
        semantic = {digest(semantic_inputs(r)) for r in original}
        role_sets = {role: {tuple(r[role]) for r in original} for role in ROLES}
        overlap[split] = {
            'originalRows': len(original),
            'generatedWholeInputExactMatches': sum(digest(input_only(r)) in full for r in variants),
            'generatedWholeInputSemanticMatchesIgnoringNeutralContext': sum(digest(semantic_inputs(r)) in semantic for r in variants),
            'generatedComponentExactMatches': {role: sum(tuple(r[role]) in role_sets[role] for r in variants) for role in ROLES}}
    write(HERE / 'References/original-manifest.json', manifest_bytes)
    source_relative = 'recommender-seat/Sources/SeatEngine/Lab/ErgenticsPrimeDomainTraceShadowCanary.swift'
    source_bytes = (SOURCE / 'Source' / source_relative).read_bytes()
    source_sha = write(HERE / 'Source' / source_relative, source_bytes)
    audit = {
        'schema': 'prime_domain_neutral_context_generator_audit_v1',
        'selection': 'All 2109 valid base rows were eligible. Ten lexicographically sorted domain pairs receive quota 102, with one extra for the first four. Select smallest SHA256 of canonical input-only role arrays, tie-breaking by row ID; no target or prediction selection.',
        'transformation': 'Toggle neutral CONTEXT token 4 at index 1, immediately after BOS 1, in left, right, direct and final-prefix inputs. All other original input symbols, role order and semantic references are preserved.',
        'scope': '1024 new exact input-array combinations using 1024 retained semantic requests, including training and validation cases. This is a valid-input neutral-context robustness experiment, not an unseen-task or pure holdout evaluation.',
        'sourcePolicy': {'originalManifestSHA256': EXPECTED_MANIFEST_SHA,
                         'originalManifestRowsCanonicalSHA256': digest(manifest['rows']),
                         'generatorSourceSHA256': source_sha,
                         'generatorSourceLines': {'split': '552-565', 'contextPlacement': '567-586', 'validRows': '596-718'},
                         'languageID': manifest['language_id'], 'engineBuild': manifest['engine_build']},
        'caseCountPerSeedExecution': 1024, 'eligibleBaseRows': 2109,
        'familyCounts': dict(sorted(collections.Counter(r['family_id'] for r in variants).items())),
        'originalSourceSplitCounts': dict(sorted(collections.Counter(r['split'] for r in selected).items())),
        'contextToggleCounts': dict(sorted(collections.Counter(p['neutralContextChange'] for p in provenance).items())),
        'overlapWithOriginalBySplit': overlap,
        'overlapInterpretation': 'Component matches are counted per generated case and are not mutually exclusive. Ignoring the supported neutral context, every request reuses original semantic inputs. Swapped mutation pairs remain different ordered requests.',
        'expectedABSTAIN224': {'direct': 0, 'traceFinal': 0, 'allJobs': 0,
                              'interpretation': 'Every generated input is valid. A model output of 224 is an unexpected abstention here. The prior main suite emitted 224 only on malformed inputs; this follow-up does not imply a prior valid-input abstention was found.'},
        'seeds': [b['seed'] for b in bindings], 'executions': ['host', 'guest'],
        'batchesPerSeedExecution': 64, 'requestFiles': 384, 'batchCaseCounts': [16] * 64,
        'jobsPerCase': 4, 'projectedJobsPerSeedExecution': 4096, 'projectedJobsAcrossAllRequests': 24576,
        'hostGuestJobsExactlyIdentical': True, 'inputContainsGoldOrHistoricalPredictions': False,
        'feedbackPolicy': 'Final input contains two zero placeholders bound to fresh predictions of jobs 1 and 2. Retain every full-vocabulary argmax including 224; no teacher summaries, output clamping or gold-driven early stopping.',
        'commonInputsSHA256': input_sha, 'goldSHA256': gold_sha,
        'checkpointBindings': bindings, 'requestReceipts': receipts,
        'generatorScriptSHA256': sha(Path(__file__).read_bytes()),
        'gpuRun': False, 'trainingRun': False, 'originalSourcesModified': False}
    audit_sha = save(HERE / 'INPUT-AUDIT.json', audit)
    complete = {'schema': 'prime_domain_generator_preparation_complete_v1', 'status': 'prepared',
                'cases': 1024, 'requests': 384, 'commonInputsSHA256': input_sha,
                'goldSHA256': gold_sha, 'inputAuditSHA256': audit_sha,
                'originalSourceSplitCounts': audit['originalSourceSplitCounts'],
                'gpuRun': False, 'trainingRun': False}
    save(HERE / 'GENERATION-COMPLETE.json', complete)
    print(json.dumps(complete, indent=2))

if __name__ == '__main__':
    main()
