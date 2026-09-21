#!/usr/bin/env python3
"""Inference-only parity probe using the exact retained original make_model.

Use the saved SharedRuntime/python/bin/python3 interpreter. The --validate-only
path performs metadata checks without importing MLX. A live invocation is owned
by the root orchestration process, not by input preparation.
"""
from __future__ import annotations
import argparse
import ast
import hashlib
import importlib
import importlib.metadata
import json
import math
import os
from pathlib import Path
import signal
import struct
import sys
import time

HERE = Path(__file__).resolve().parent
COMPARISON = HERE.parent
SOURCES = {
    'prime_mlx_native_mechanics_canary.py': 'c22d5a9591923ec10213339a4380207f0a09da24571b7970849b9f35776c203b',
    'prime_native_compositional_language.py': '434496b900d52e3d1236b8a17b5cb80c9b0df1f663c55e883fe987f03c4c6663',
}
WEIGHTS = {
    1618: '122af63187129249ef0c85dbac6e6f1bd0c0e67c60f88b387844fd002bd2d0ec',
    2718: 'f5201fae919d8636300086829943fd38059767ab293147ca8c0c65ce91402067',
    3141: '7064c514a9a41369951d1ee829ac0f028bb488a0b9551d5e8b1d2433173cd4e1',
}

def sha(data):
    return hashlib.sha256(data).hexdigest()

def require(condition, message):
    if not condition:
        raise ValueError(message)

def bounded_read(path, maximum):
    path = path.resolve(strict=True)
    require(path.is_file() and 0 < path.stat().st_size <= maximum, 'invalid file size/type')
    data = path.read_bytes()
    require(0 < len(data) <= maximum, 'input grew during read')
    return data

def inspect_sources():
    receipts = []
    for name, expected in SOURCES.items():
        path = HERE / 'Source' / name
        data = bounded_read(path, 100000)
        require(sha(data) == expected, 'original source hash mismatch')
        tree = ast.parse(data)
        for node in tree.body:
            if isinstance(node, ast.Expr):
                require(isinstance(node.value, ast.Constant) and isinstance(node.value.value, str), 'unexpected top-level expression')
            elif isinstance(node, ast.Assign):
                # The language module's OPERATIONS tuple names preceding
                # integer constants; it is not a function call or model run.
                require(not any(isinstance(n, (ast.Call, ast.Await, ast.Yield, ast.ListComp,
                                               ast.SetComp, ast.DictComp, ast.GeneratorExp))
                                for n in ast.walk(node.value)), 'unexpected evaluated source initializer')
            elif isinstance(node, ast.If):
                require(ast.dump(node.test) == ast.dump(ast.parse('__name__ == "__main__"', mode='eval').body), 'unexpected source top-level conditional')
            else:
                require(isinstance(node, (ast.Import, ast.ImportFrom, ast.FunctionDef, ast.ClassDef)), 'unexpected source top-level statement')
        receipts.append({'name': name, 'path': str(path), 'sha256': expected, 'byteCount': len(data)})
    return receipts

def inspect_request(seed, request_path):
    raw = bounded_read(request_path, 131072)
    request = json.loads(raw)
    require(set(request) == {'schema', 'weightsPath', 'weightsSHA256', 'execution', 'cases'}, 'unexpected request keys')
    require(request['schema'] == 'prime_10m_feedback_inference_request_v2' and request['execution'] == 'host', 'expected host feedback request')
    require(request['weightsSHA256'] == WEIGHTS[seed], 'wrong checkpoint for selected seed')
    canonical_first = json.loads(bounded_read(COMPARISON / 'Requests' / f'seed-{seed}' / 'host/batch-000.json', 131072))
    require(request['cases'] == canonical_first['cases'] and len(request['cases']) == 16, 'only the first original16 cases are admitted')
    for case in request['cases']:
        require(set(case) == {'id', 'allowedValueMinimum', 'allowedValueCount', 'jobs'}, 'unexpected case keys')
        require(case['allowedValueMinimum'] == 0 and case['allowedValueCount'] == 16384, 'full-vocabulary feedback required')
        require(len(case['jobs']) == 4, 'expected four jobs')
        for index, job in enumerate(case['jobs']):
            require(set(job) == {'inputTokenIDs', 'feedbackBindings'}, 'unexpected job keys')
            require(1 <= len(job['inputTokenIDs']) <= 64 and all(type(i) is int and 0 <= i < 16384 for i in job['inputTokenIDs']), 'invalid token IDs')
            require(len(job['feedbackBindings']) == (2 if index == 3 else 0), 'incorrect dependency count')
            for binding in job['feedbackBindings']:
                require(set(binding) == {'inputOffset', 'sourceJobIndex'}, 'unexpected binding keys')
                require(type(binding['inputOffset']) is int and 0 <= binding['inputOffset'] < len(job['inputTokenIDs']), 'invalid binding offset')
                require(binding['sourceJobIndex'] in [1, 2] and index == 3, 'invalid dependency source')
                require(job['inputTokenIDs'][binding['inputOffset']] == 0, 'expected zero placeholder')
            if index == 3:
                require([b['sourceJobIndex'] for b in job['feedbackBindings']] == [1, 2], 'left/right dependency order mismatch')
                require(job['feedbackBindings'][1]['inputOffset'] == job['feedbackBindings'][0]['inputOffset'] + 1, 'nonadjacent summary slots')
    weights_path = Path(request['weightsPath'])
    wb = bounded_read(weights_path, 67108864)
    require(sha(wb) == WEIGHTS[seed], 'checkpoint bytes hash mismatch')
    header_length = struct.unpack('<Q', wb[:8])[0]
    require(header_length < len(wb) - 8, 'invalid safetensors header length')
    header = json.loads(wb[8:8 + header_length])
    shapes = {k: {'shape': v['shape'], 'dtype': v['dtype']} for k, v in header.items() if k != '__metadata__'}
    retained_shapes = json.loads((COMPARISON / 'References/tensor-shapes.json').read_bytes())
    require(shapes == retained_shapes and len(shapes) == 74, 'tensor schema mismatch')
    require(all(v['dtype'] == 'F32' for v in shapes.values()), 'expected F32 tensors')
    return request, raw, wb

def write(output, name, data):
    path = output / name
    with path.open('xb') as f:
        f.write(data)
        f.flush()
        os.fsync(f.fileno())
    path.chmod(0o444)

def save(output, name, obj):
    write(output, name, (json.dumps(obj, indent=2, sort_keys=True, allow_nan=False) + '\n').encode())

def execute(seed, request, request_raw, weights_before, sources, output, request_path):
    # Delayed imports: metadata validation never reaches the MLX runtime.
    sys.path.insert(0, str(HERE / 'Source'))
    original = importlib.import_module('prime_mlx_native_mechanics_canary')
    require(Path(original.__file__).resolve() == (HERE / 'Source/prime_mlx_native_mechanics_canary.py').resolve(), 'unexpected original module route')
    mx = original.mx
    mx.set_default_device(mx.gpu)
    began = time.monotonic_ns()
    model = original.make_model(seed)
    model.load_weights(request['weightsPath'], strict=True)
    mx.eval(model.parameters())
    model.eval()
    require(original.parameter_count(model) == 10227968, 'incorrect parameter count after strict reload')
    require(len(original.tree_flatten(model.parameters())) == 74, 'incorrect tensor count after strict reload')
    results = []
    for case_index, case in enumerate(request['cases']):
        predictions, feedback = [], []
        for job_index, job in enumerate(case['jobs']):
            ids = list(job['inputTokenIDs'])
            for binding in job['feedbackBindings']:
                source = binding['sourceJobIndex']
                value = predictions[source]['predictionTokenID']
                ids[binding['inputOffset']] = value
                feedback.append({'jobIndex': job_index, 'inputOffset': binding['inputOffset'],
                                 'sourceJobIndex': source, 'actualPredictionTokenID': value})
            started = time.monotonic_ns()
            # Original Python domain executor's full-prefix/no-cache numerical path.
            inputs = mx.array([ids], dtype=mx.int32)
            logits = model(inputs)[:, -1, :]
            predicted = mx.argmax(logits, axis=-1)
            mx.eval(logits, predicted)
            values = logits.astype(mx.float32).reshape(-1).tolist()
            require(len(values) == 16384 and all(math.isfinite(v) for v in values), 'invalid logits')
            token = int(predicted.item())
            independent_argmax = max(range(len(values)), key=values.__getitem__)
            require(token == independent_argmax, 'argmax/tie mismatch')
            raw = struct.pack('<16384f', *values)
            prefix = f'case-{case_index:03d}-job-{job_index:02d}'
            leaf = prefix + '-logits.f32le'
            write(output, leaf, raw)
            result = {'id': case['id'], 'jobIndex': job_index, 'inputTokenIDs': ids, 'predictionTokenID': token,
                      'maximumLogit': values[token], 'logitsFinite': True,
                      'logits': {'path': leaf, 'dtype': 'float32_little_endian', 'shape': [16384],
                                 'content': {'sha256': sha(raw), 'byteCount': len(raw)}},
                      'elapsedNanoseconds': time.monotonic_ns() - started}
            save(output, prefix + '.json', result)
            predictions.append(result)
        group = {'id': case['id'], 'status': 'completed', 'predictions': predictions, 'feedback': feedback}
        save(output, f'case-{case_index:03d}.json', group)
        results.append(group)
        print(json.dumps({'caseIndex': case_index, 'id': case['id'], 'predictions': [p['predictionTokenID'] for p in predictions]}), flush=True)
    weights_after = bounded_read(Path(request['weightsPath']), 67108864)
    require(weights_before == weights_after, 'weights changed')
    require(bounded_read(request_path, 131072) == request_raw, 'request changed')
    require(inspect_sources() == sources, 'original source changed')
    result = {'schema': 'prime_domain_original_python_inference_parity_v1', 'status': 'completed',
              'seed': seed, 'cases': results, 'caseCount': len(results), 'modelForwards': len(results) * 4,
              'weightsPath': request['weightsPath'], 'weightsBefore': {'sha256': sha(weights_before), 'byteCount': len(weights_before)},
              'weightsAfter': {'sha256': sha(weights_after), 'byteCount': len(weights_after)},
              'requestSHA256': sha(request_raw), 'originalSources': sources,
              'runtime': {'pythonExecutable': sys.executable, 'pythonVersion': sys.version,
                          'mlxVersion': importlib.metadata.version('mlx'), 'mlxLMVersion': importlib.metadata.version('mlx-lm'),
                          'device': str(mx.default_device())},
              'parameterCount': 10227968, 'tensorCount': 74, 'dtype': 'F32',
              'modelConstruction': 'Exact copied original prime_mlx_native_mechanics_canary.make_model(seed), followed by strict retained checkpoint reload and eval().',
              'batchPolicy': 'One case per forward, matching the new Swift parity probe. Historical Python report used grouped batches of up to64.',
              'targetsUsed': False, 'teacherFinalUsed': False, 'trainingPerformed': False,
              'elapsedNanoseconds': time.monotonic_ns() - began}
    save(output, 'result.json', result)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--seed', type=int, choices=sorted(WEIGHTS), required=True)
    parser.add_argument('--request', type=Path)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--validate-only', action='store_true')
    args = parser.parse_args()
    os.umask(0o077)
    sources = inspect_sources()
    path = args.request or COMPARISON / 'Requests' / f'seed-{args.seed}' / 'host/batch-000.json'
    request, raw, weights = inspect_request(args.seed, path)
    if args.validate_only:
        print(json.dumps({'status': 'metadata_validated_no_MLX_import', 'seed': args.seed, 'cases': 16, 'jobs': 64,
                          'weightsSHA256': sha(weights), 'requestSHA256': sha(raw), 'sourceBindings': sources}, indent=2))
        return
    require(args.output is not None and args.output.is_absolute(), '--output must be a fresh absolute directory')
    args.output.mkdir(parents=True, exist_ok=False)
    signal.alarm(120)
    write(args.output, 'request.json', raw)
    try:
        execute(args.seed, request, raw, weights, sources, args.output, path)
    except Exception as error:
        save(args.output, 'error.json', {'status': 'failed', 'errorType': type(error).__name__, 'message': str(error)})
        raise
    finally:
        signal.alarm(0)

if __name__ == '__main__':
    main()
