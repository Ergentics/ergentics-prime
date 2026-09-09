#!/usr/bin/env python3
"""Freeze all original domain evaluation inputs; no model execution/imports."""
import collections
import hashlib
import json
from pathlib import Path
import struct
import math

HERE = Path(__file__).resolve().parent
LAB = Path('/Users/ergentics/prime-mlx-lab')
REPO = Path('/Users/ergentics/pmhnp-companion-ergentics')
RUNS = [(1618, 'domain-trace-shadow-seed1618'), (2718, 'domain-trace-shadow'), (3141, 'domain-trace-shadow-seed3141')]

def sha(data):
    return hashlib.sha256(data).hexdigest()

def canonical(obj):
    return sha(json.dumps(obj, sort_keys=True, separators=(',', ':')).encode())

def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        assert path.read_bytes() == data, f'Existing artifact differs: {path}'
        return sha(data)
    with path.open('xb') as f:
        f.write(data)
    return sha(data)

def save(path, obj):
    return write(path, (json.dumps(obj, indent=2, sort_keys=True) + '\n').encode())

def projection(row):
    p = row['final_prefix_ids']
    result = {'id': row['row_id'], 'allowedValueMinimum': 0, 'allowedValueCount': 16384,
              'jobs': [
                  {'inputTokenIDs': row['direct_input_ids'], 'feedbackBindings': []},
                  {'inputTokenIDs': row['left_input_ids'], 'feedbackBindings': []},
                  {'inputTokenIDs': row['right_input_ids'], 'feedbackBindings': []},
                  {'inputTokenIDs': p + [0, 0] + row['final_suffix_ids'],
                   'feedbackBindings': [{'inputOffset': len(p), 'sourceJobIndex': 1},
                                        {'inputOffset': len(p) + 1, 'sourceJobIndex': 2}]},
              ]}
    assert len(result['jobs']) == 4
    for i, job in enumerate(result['jobs']):
        assert 1 <= len(job['inputTokenIDs']) <= 64
        assert all(type(x) is int and 0 <= x < 16384 for x in job['inputTokenIDs'])
        for b in job['feedbackBindings']:
            assert 0 <= b['sourceJobIndex'] < i and job['inputTokenIDs'][b['inputOffset']] == 0
    return result

def main():
    bindings = []
    manifest_bytes = None
    tensor_shapes = None
    reports = []
    for seed, name in RUNS:
        folder = LAB / name
        wp = folder / 'prime-domain-trace.safetensors'
        rp = folder / 'prime-domain-trace-shadow.json'
        mp = folder / 'prime-domain-trace-manifest.json'
        wb, rb, mb = wp.read_bytes(), rp.read_bytes(), mp.read_bytes()
        report, manifest = json.loads(rb), json.loads(mb)
        assert report['seed'] == seed
        assert sha(wb) == report['durability']['checkpoint_sha256']
        if manifest_bytes is None:
            manifest_bytes = mb
        else:
            assert manifest_bytes == mb
        assert canonical(manifest['rows']) == report['manifest']['manifest_sha256']
        for split in ['train', 'validation', 'holdout']:
            assert canonical([r for r in manifest['rows'] if r['split'] == split]) == report['manifest'][split + '_sha256']
        assert canonical(manifest['mutations']) == report['manifest']['mutation_sha256']
        length = struct.unpack('<Q', wb[:8])[0]
        header = json.loads(wb[8:8 + length])
        shapes = {k: {'shape': v['shape'], 'dtype': v['dtype']} for k, v in header.items() if k != '__metadata__'}
        assert len(shapes) == 74 and all(x['dtype'] == 'F32' for x in shapes.values())
        assert sum(math.prod(x['shape']) for x in shapes.values()) == 10227968
        if tensor_shapes is None:
            tensor_shapes = shapes
        else:
            assert tensor_shapes == shapes
        bindings.append({'seed': seed, 'weightsPath': str(wp), 'weightsSHA256': sha(wb), 'weightsBytes': len(wb),
                         'originalReportPath': str(rp), 'originalReportSHA256': sha(rb),
                         'originalManifestPath': str(mp), 'originalManifestFileSHA256': sha(mb),
                         'originalManifestRowsCanonicalSHA256': report['manifest']['manifest_sha256'],
                         'profile': report['profile'], 'implementation': report['implementation'],
                         'reportedTrainingSteps': report['training']['completed_steps']})
        reports.append((seed, rb))
    manifest = json.loads(manifest_bytes)
    selected = [r for r in manifest['rows'] if r['split'] == 'holdout'] + manifest['mutations']
    assert len(selected) == 940 and len({r['row_id'] for r in selected}) == 940
    assert collections.Counter(r['split'] for r in selected) == {'holdout': 470, 'mutation': 470}
    cases = [projection(r) for r in selected]
    common_sha = save(HERE / 'Inputs/cases.json', {'schema': 'prime_domain_original_evaluation_inputs_v1', 'cases': cases})
    request_receipts = []
    for model in bindings:
        for execution in ['host', 'guest']:
            for batch, offset in enumerate(range(0, len(cases), 16)):
                selected_cases = cases[offset:offset + 16]
                request = {'schema': 'prime_10m_feedback_inference_request_v2',
                           'weightsPath': model['weightsPath'], 'weightsSHA256': model['weightsSHA256'],
                           'execution': execution, 'cases': selected_cases}
                dest = HERE / 'Requests' / f'seed-{model["seed"]}' / execution / f'batch-{batch:03d}.json'
                h = save(dest, request)
                request_receipts.append({'seed': model['seed'], 'execution': execution, 'batch': batch,
                                         'path': str(dest), 'sha256': h, 'caseCount': len(selected_cases),
                                         'caseIDs': [c['id'] for c in selected_cases]})
    # Provenance and gold are saved separately and never appear in requests.
    write(HERE / 'References/original-manifest.json', manifest_bytes)
    for seed, rb in reports:
        write(HERE / 'References' / f'original-report-seed-{seed}.json', rb)
    save(HERE / 'References/model-bindings.json', bindings)
    save(HERE / 'References/tensor-shapes.json', tensor_shapes)
    refs = [{'id': r['row_id'], 'sourceSplit': r['split'], 'familyID': r['family_id'],
             'represented': r['represented'], 'directTargetID': r['final_target_id'],
             'expectedJobIDs': [r['final_target_id'], r['left_summary_target_id'], r['right_summary_target_id'], r['final_target_id']],
             'engineWinner': r.get('engine_winner'), 'engineEventType': r.get('engine_event_type')}
            for r in selected]
    gold_sha = save(HERE / 'References/gold.json', {'schema': 'prime_domain_original_evaluation_references_v1', 'cases': refs})
    source_receipts = []
    for rel in ['prime-runtime/tools/prime_mlx_domain_trace_shadow.py',
                'prime-runtime/tools/prime_mlx_native_mechanics_canary.py',
                'recommender-seat/Sources/SeatEngine/Lab/ErgenticsPrimeDomainTraceShadowCanary.swift',
                'recommender-seat/Sources/SeatEngine/Recommender.swift',
                'recommender-seat/Sources/SeatEngine/EngineV21.swift',
                'recommender-seat/Sources/SeatEngine/Domain.swift',
                'recommender-seat/Sources/SeatEngine/MatchScore.swift',
                'recommender-seat/Sources/SeatEngine/EngineConstants.swift',
                'recommender-seat/Sources/SeatEngine/AntiRedundancy.swift']:
        original = REPO / rel
        content = original.read_bytes()
        dest = HERE / 'Source' / rel
        write(dest, content)
        source_receipts.append({'originalPath': str(original), 'copyPath': str(dest), 'sha256': sha(content)})
    # Verify paired requests agree on every model/input field except execution.
    for model in bindings:
        for batch in range(59):
            root = HERE / 'Requests' / f'seed-{model["seed"]}'
            host = json.loads((root / 'host' / f'batch-{batch:03d}.json').read_bytes())
            guest = json.loads((root / 'guest' / f'batch-{batch:03d}.json').read_bytes())
            assert host.pop('execution') == 'host' and guest.pop('execution') == 'guest' and host == guest
    audit = {
        'schema': 'prime_domain_input_projection_audit_v1',
        'sourceLanguageID': manifest['language_id'], 'sourceEngineBuild': manifest['engine_build'],
        'selection': 'All470original holdout rows in original manifest order, followed by all470original mutation rows in original order. No train/validation rows used as cases. No selection using predicted results.',
        'caseCountPerSeedExecution': 940, 'seeds': [1618, 2718, 3141], 'executions': ['host', 'guest'],
        'requestFiles': len(request_receipts), 'batchesPerSeedExecution': 59,
        'batchCaseCounts': [16] * 58 + [12], 'jobsPerCase': 4,
        'projectedJobsPerSeedExecution': 3760, 'projectedJobsAcrossAllRequests': 22560,
        'nativeSubset': {'represented': sum(r['represented'] for r in selected), 'malformed': sum(not r['represented'] for r in selected)},
        'jobMapping': ['0: direct original input', '1: left candidate original input', '2: right candidate original input',
                       '3: final_prefix + [fresh guest/host prediction fromjob1, fresh prediction fromjob2] + final_suffix'],
        'feedbackPolicy': 'Every actual0..16383 argmax output is retained, including224ABSTAIN and symbols outside assigned semantic sets; no Z8 earlystop/clamping.',
        'hostGuestJobsExactlyIdentical': True, 'inputContainsGoldOrHistoricalPredictions': False,
        'placeholderIDs': [0, 0], 'commonInputsSHA256': common_sha, 'goldSHA256': gold_sha,
        'checkpointBindings': bindings, 'requestReceipts': request_receipts, 'sourceReceipts': source_receipts,
        'originalPythonEquivalenceCautions': [
            'Weights were first-party random-init trained with Python MLX using llama-shaped10M architecture; they are not imported olderLlama weights.',
            'Original Python predictor groups examples by sequence length and uses batchsize64; proposed native runner evaluates one row at a time. Floating-point/batching/backend differences require observation; exact parity with historical Python is not assumed.',
            'All74 tensor names/shapes/F32 dtypes match the retained Swift10M loader geometry. A live strict load and output check are still required.',
            'Original evaluate contains a separate teacher-final control using gold summary targets. That control is omitted from these live inputs; only actual predicted summary fan-in is requested.',
            'Original three-seed consensus remainsABSTAIN; preparing inputs does not promote model quality or the product route.'
        ],
        'scriptPath': str(Path(__file__).resolve()), 'scriptSHA256': sha(Path(__file__).read_bytes()),
        'gpuRun': False, 'trainingRun': False, 'originalSourcesModified': False,
    }
    h = save(HERE / 'INPUT-AUDIT.json', audit)
    print(json.dumps({'root': str(HERE), 'requests': len(request_receipts), 'casesPerSeedExecution': 940,
                      'inputAuditSHA256': h, 'commonInputsSHA256': common_sha}, indent=2))

if __name__ == '__main__':
    main()
