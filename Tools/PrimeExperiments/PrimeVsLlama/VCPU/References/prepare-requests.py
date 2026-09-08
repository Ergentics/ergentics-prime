#!/usr/bin/env python3
"""Project the saved input-only suite into guest jobs; never run a model.

No scored outputs or reference targets are read while constructing requests.
References are copied separately after request construction for later scoring.
Writes use exclusive creation to preserve previously prepared files.
"""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
TASK = HERE.parents[2]
BASE = TASK / 'outputs/Prime-Experiment-Builds/Prime-v-Llama-01'
BUILDS = TASK / 'outputs/Prime-Experiment-Builds'
MODELS = [
    ('0006', '0006-prime-swift-variable-depth-4000', '4ec25a1a577aee22d70bb44bff2caf7e4b9790322596a13135a69e642e8047bd'),
    ('0007', '0007-prime-swift-variable-depth-8000', '4baff383398b024661ff48fb7b5d283a3451950ee2702455eb3a3f7c52a54afb'),
]

def digest(data):
    return hashlib.sha256(data).hexdigest()

def write_bytes(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('xb') as f:
        f.write(data)

def write_json(path, obj):
    data = (json.dumps(obj, indent=2, sort_keys=True) + '\n').encode()
    write_bytes(path, data)
    return digest(data)

def project(case):
    minimum = min(case['allowedValueSymbols'])
    assert minimum in (16, 64)
    assert case['allowedValueSymbols'] == list(range(minimum, minimum + 8))
    jobs = [{'inputTokenIDs': case['directInputIDs'], 'priorPredictionOffset': -1}]
    assert len(case['traceStages']) == case['depth']
    for stage_index, stage in enumerate(case['traceStages']):
        assert stage['stageIndex'] == stage_index
        assert stage['requiresPriorPrediction'] == (stage_index > 0)
        prefix, suffix = stage['inputPrefixIDs'], stage['inputSuffixIDs']
        if stage['requiresPriorPrediction']:
            # 0 is an explicitly empty sentinel, never an inferred prior state.
            ids = prefix + [0] + suffix
            offset = len(prefix)
            assert ids[offset] == 0 and ids[:offset] == prefix and ids[offset + 1:] == suffix
        else:
            ids, offset = prefix + suffix, -1
        jobs.append({'inputTokenIDs': ids, 'priorPredictionOffset': offset})
    assert 1 <= len(jobs) <= 5
    assert jobs[0]['priorPredictionOffset'] == jobs[1]['priorPredictionOffset'] == -1
    for index, job in enumerate(jobs):
        assert set(job) == {'inputTokenIDs', 'priorPredictionOffset'}
        ids, offset = job['inputTokenIDs'], job['priorPredictionOffset']
        assert 1 <= len(ids) <= 64
        assert all(type(x) is int and 0 <= x < 16384 for x in ids)
        assert type(offset) is int and (offset == -1 or 0 <= offset < len(ids))
        assert (offset >= 0) == (index >= 2)
    return {'id': case['id'], 'allowedValueMinimum': minimum, 'jobs': jobs}

def main():
    original_inputs = BASE / 'Inputs/cases.json'
    original_bytes = original_inputs.read_bytes()
    data = json.loads(original_bytes)
    cases = data['cases']
    assert len(cases) == len({c['id'] for c in cases}) == 80
    projections = [project(c) for c in cases]
    assert sum(len(c['jobs']) for c in projections) == 360
    assert sum(j['priorPredictionOffset'] >= 0 for c in projections for j in c['jobs']) == 200
    # The original cases are the sole data source for model-visible requests.
    request_receipts = []
    weights_receipts = []
    for label, directory, expected_hash in MODELS:
        weights = BUILDS / directory / 'Runtime/weights.safetensors'
        before = weights.read_bytes()
        assert digest(before) == expected_hash
        weights_receipts.append({'model': label, 'path': str(weights), 'sha256': expected_hash, 'byteCount': len(before)})
        for batch in range(10):
            selected = projections[batch * 8:(batch + 1) * 8]
            request = {'schema': 'prime_10m_vcpu_inference_request_v1',
                       'weightsPath': str(weights), 'weightsSHA256': expected_hash,
                       'cases': selected}
            assert set(request) == {'schema', 'weightsPath', 'weightsSHA256', 'cases'}
            assert len(request['cases']) == 8
            path = HERE / 'Requests' / label / f'batch-{batch:02d}.json'
            content_hash = write_json(path, request)
            request_receipts.append({'model': label, 'batch': batch, 'path': str(path), 'sha256': content_hash,
                                     'caseIDs': [c['id'] for c in selected],
                                     'caseCount': len(selected), 'jobCount': sum(len(c['jobs']) for c in selected),
                                     'livePriorSlots': sum(j['priorPredictionOffset'] >= 0 for c in selected for j in c['jobs'])})
        assert weights.read_bytes() == before
    # Copy references/provenance only after all model requests are complete.
    provenance_copies = [
        (original_inputs, 'original-input-cases.json'),
        (BASE / 'References/gold.json', 'gold.json'),
        (TASK / 'work/prime-system-comparison-2026-09-08/variable-depth-v1-preparation/input-audit.json', 'original-v1-input-audit.json'),
        (TASK / 'work/prime-system-comparison-2026-09-08/variable-depth-v1-preparation/References/checkpoint-source-receipts.json', 'original-checkpoint-source-receipts.json'),
    ]
    reference_receipts = []
    for source, leaf in provenance_copies:
        target = HERE / 'References' / leaf
        content = source.read_bytes()
        write_bytes(target, content)
        reference_receipts.append({'source': str(source), 'copy': str(target), 'sha256': digest(content), 'byteCount': len(content)})
    assert original_inputs.read_bytes() == original_bytes
    report = {
        'schema': 'prime_vcpu_input_projection_audit_v1',
        'originalInputsPath': str(original_inputs), 'originalInputsSHA256': digest(original_bytes),
        'scriptPath': str(Path(__file__).resolve()), 'scriptSHA256': digest(Path(__file__).read_bytes()),
        'requestSchema': 'prime_10m_vcpu_inference_request_v1',
        'caseCountPerModel': 80, 'modelCount': 2, 'batchesPerModel': 10, 'casesPerBatch': 8,
        'jobsPerModel': 360, 'livePriorSlotsPerModel': 200,
        'jobMapping': {'0': 'direct original full input, static; priorPredictionOffset=-1',
                       '1': 'first trace stage, static; priorPredictionOffset=-1; does not consume direct output',
                       '2_and_later': 'trace continuation: prefix + placeholder0 + suffix; guest replaces placeholder using that model run’s immediately preceding fresh trace prediction'},
        'runtimeSchemaExact': {'requestKeys': ['schema','weightsPath','weightsSHA256','cases'],
                               'caseKeys': ['id','allowedValueMinimum','jobs'],
                               'jobKeys': ['inputTokenIDs','priorPredictionOffset']},
        'predictionPlaceholder': 0,
        'predictionPlaceholderMustBeReplacedBeforeInference': True,
        'inputContainsGold': False, 'inputContainsHistoricalPredictions': False,
        'sourceForInputConstruction': 'Original input-only case definitions only; no result summaries or gold file parsed during construction.',
        'referenceFilesCopiedSeparately': reference_receipts,
        'weights': weights_receipts, 'requests': request_receipts,
        'comparisonPlan': 'After actual guest runs, compare each job’s actual input IDs, predicted symbol, and full logits bytes/hash to its matching previous host phase for the same checkpoint and case. Verify live slot came from the guest-observed immediately preceding fresh prediction. Score against References/gold.json separately. Record any missing or differing job without substituting prior results.',
        'gpuRun': False, 'buildRun': False, 'oldOutputsModified': False,
    }
    report_sha = write_json(HERE / 'PROJECTION-AUDIT.json', report)
    print(json.dumps({'root': str(HERE), 'requests': len(request_receipts), 'casesPerModel': 80,
                      'jobsPerModel': 360, 'livePriorSlotsPerModel': 200, 'auditSHA256': report_sha}, indent=2))

if __name__ == '__main__':
    main()
