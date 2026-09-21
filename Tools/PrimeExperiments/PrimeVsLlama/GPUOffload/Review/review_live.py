#!/usr/bin/env python3
"""Independent readback only: stdlib F32/CPU math, no model, Metal, VM or subprocess."""
from pathlib import Path
import ctypes as C
import hashlib
import json
import math
import statistics
import struct

W = Path(__file__).resolve().parent.parent
N = W / 'Live/native'
U, I, Q, F = C.c_uint32, C.c_int32, C.c_uint64, C.c_float

class Input(C.Structure):
    _fields_ = [('pointCount', U), ('nodeCount', U), ('sigma', F), ('reserved', U),
                ('pointsXY', F * 400), ('nodesXYWeight', F * 192)]

class Reply(C.Structure):
    _fields_ = [('valueCount', U), ('reserved', U), ('values', F * 600)]

class Exit(C.Structure):
    _fields_ = [('runStatus', I), ('reason', U)] + [(k, Q) for k in
        'pc cpsr syndrome virtualAddress physicalAddress x0 x1 x2 x3 x20 x21 x22 x23 x27 x28 sctlr'.split()] + [('validated', U)]

class Result(C.Structure):
    _fields_ = [('status', I), ('stage', U), ('failureCode', I)] + [(k, U) for k in
        'runCount exceptionCount requestHVCCount replyReturnCount callbackCount completionHVCCount guestReadCount'.split()] + [
        ('guestChecksum', Q), ('hostExpectedChecksum', Q), ('observedInput', Input), ('observedReply', Reply), ('exits', Exit * 2),
        ('ownerThreadID', Q), ('elapsedNanoseconds', Q)] + [(k, U) for k in
        'codeByteCount codeImmutableValidated dataGuardValidated registerChecksPassed inputValidated replyValidated checksumMatched'.split()] + [(k, I) for k in
        'vmCreateStatus codeMapStatus dataMapStatus vcpuCreateStatus codeProtectStatus dataProtectStatus watchdogCreateStatus watchdogJoinStatus watchdogWaitStatus'.split()] + [
        ('watchdogFired', U), ('watchdogExitCalls', U)] + [(k, I) for k in
        'watchdogExitStatus vcpuDestroyStatus codeUnmapStatus dataUnmapStatus vmDestroyStatus codeMunmapStatus dataMunmapStatus'.split()] + [('cleanupComplete', U)]

def load(p): return json.loads(p.read_bytes())
def sha(b): return hashlib.sha256(b).hexdigest()
def pin(p):
    b = p.read_bytes()
    return {'path': str(p), 'bytes': len(b), 'sha256': sha(b)}
def unpack_float(b): return struct.unpack('<' + 'f' * (len(b) // 4), b)
def packed(v): return struct.pack('<' + 'f' * len(v), *v)
def f32(x): return struct.unpack('<f', struct.pack('<f', x))[0]
def projection(v):
    if isinstance(v, C.Structure): return {k: projection(getattr(v, k)) for k, _ in v._fields_}
    if isinstance(v, C.Array): return [projection(x) for x in v]
    if isinstance(v, float) and math.isnan(v): return 'nan'
    return v
def read_result(name, record):
    p = N / name
    b = p.read_bytes()
    assert len(b) == C.sizeof(Result), ('C result size', name, len(b), C.sizeof(Result))
    obj = Result.from_buffer_copy(b)
    assert projection(obj) == record, ('raw C versus JSON', name)
    return obj
def fnv(b):
    h = 0xcbf29ce484222325
    for (word,) in struct.iter_unpack('<I', b): h = ((h ^ word) * 0x100000001b3) & ((1 << 64) - 1)
    return h
def stats(xs):
    return {'count': len(xs), 'min': min(xs), 'median': statistics.median(xs), 'max': max(xs)}
def lifecycle(r):
    for k in 'vmCreateStatus codeMapStatus dataMapStatus vcpuCreateStatus codeProtectStatus dataProtectStatus watchdogCreateStatus watchdogJoinStatus vcpuDestroyStatus codeUnmapStatus dataUnmapStatus vmDestroyStatus codeMunmapStatus dataMunmapStatus'.split(): assert r[k] == 0, k
    assert r['cleanupComplete'] == 1 and r['watchdogFired'] == r['watchdogExitCalls'] == 0
    assert r['watchdogWaitStatus'] in (0, 60) and r['watchdogExitStatus'] == -(1 << 31)

assert C.sizeof(Input) == 2384 and C.sizeof(Reply) == 2408
result = load(N / 'result.json')
assert result['status'] == 'PASS' and len(result['measurements']) == 48
assert result['trainingPerformed'] is result['learnedModelInvoked'] is result['virtualGPUDeviceImplemented'] is False
measurements = result['measurements']
assert len({(m['pointCount'], m['repetition'], m['route']) for m in measurements}) == 48
table, bindings = [], []
max_v = max_g = max_reported_error_delta = 0.0
valid_timestamps = pairs = guest_values = guest_entries = 0
for count in (1, 32, 200):
    ib = (N / f'input-{count}.bin').read_bytes()
    inp = Input.from_buffer_copy(ib)
    ij = load(N / f'input-{count}.json')
    assert len(ib) == 2384 and projection(inp) == ij
    assert inp.pointCount == count and inp.nodeCount == 12 and inp.sigma == f32(0.42) and inp.reserved == 0
    expected_xy = [z for k in range(count) for z in (f32(-1.2 + 2.4 * (k % 20) / 19), f32(-1.2 + 2.4 * (k // 20) / 9))]
    expected_nodes = [z for k in range(12) for z in (f32(-0.75 + 0.5 * (k % 4)), f32(-0.6 + 0.6 * (k // 4)), f32(0.2 + 0.1 * k))]
    assert packed(list(inp.pointsXY)) == packed(expected_xy + [0.] * (400 - count * 2))
    assert packed(list(inp.nodesXYWeight)) == packed(expected_nodes + [0.] * (192 - 36))
    reference_v, reference_g = [], []
    sigma2 = float(inp.sigma) ** 2
    for k in range(count):
        x, y = inp.pointsXY[k * 2:k * 2 + 2]
        sv = sx = sy = 0.0
        for n in range(12):
            nx, ny, weight = inp.nodesXYWeight[n * 3:n * 3 + 3]
            dx, dy = x - nx, y - ny
            gaussian = math.exp(-(dx * dx + dy * dy) / (2 * sigma2))
            sv -= weight * gaussian
            sx += weight * gaussian * dx / sigma2
            sy += weight * gaussian * dy / sigma2
        reference_v.append(sv); reference_g.extend([sx, sy])
    for repetition in range(8):
        expected_routes = ['host', 'guest'] if repetition % 2 == 0 else ['guest', 'host']
        ms = [m for m in measurements if m['pointCount'] == count and m['repetition'] == repetition]
        assert [m['route'] for m in ms] == expected_routes
        data_by_route = {}
        for m in ms:
            route = m['route']; p = N / f'{route}-{count}-{repetition}.f32le'; b = p.read_bytes()
            data_by_route[route] = b
            assert len(b) == count * 12 and sha(b) == m['outputSHA256']
            values = unpack_float(b); assert all(math.isfinite(v) for v in values)
            assert m['valueCount'] == count * 3 and m['nodeCount'] == 12 and m['commandBufferStatus'] == 4 and m['CPUFallback'] is False
            ev = [abs(a - v) for a, v in zip(reference_v, values[:count])]
            eg = [abs(a - v) for a, v in zip(reference_g, values[count:])]
            assert all(d <= max(1e-5, 1e-4 * max(abs(a), abs(v))) for d, a, v in zip(ev, reference_v, values[:count]))
            assert all(d <= max(1e-4, 1e-3 * max(abs(a), abs(v))) for d, a, v in zip(eg, reference_g, values[count:]))
            delta = max(abs(max(ev) - m['maximumPotentialError']), abs(max(eg) - m['maximumGradientError']))
            assert delta < 1e-12
            max_reported_error_delta = max(max_reported_error_delta, delta)
            max_v = max(max_v, max(ev)); max_g = max(max_g, max(eg))
            start, end = m['gpuStartHostSeconds'], m['gpuEndHostSeconds']
            if start is not None and end is not None and math.isfinite(start) and math.isfinite(end) and start > 0 and end >= start:
                assert m['gpuNanoseconds'] == (end - start) * 1e9
                valid_timestamps += 1
            else: assert m['gpuNanoseconds'] is None
            assert 0 < m['callbackWallNanoseconds'] <= m['totalWallNanoseconds']
            if route == 'guest':
                gj = load(N / f'guest-{count}-{repetition}.json')
                gr = read_result(f'guest-{count}-{repetition}.bin', gj)
                lifecycle(gj)
                for k in 'codeImmutableValidated dataGuardValidated registerChecksPassed inputValidated replyValidated checksumMatched requestHVCCount replyReturnCount callbackCount completionHVCCount'.split(): assert gj[k] == 1, k
                assert gj['codeByteCount'] == 152 and gj['status'] == gj['failureCode'] == 0 and gj['stage'] == gj['runCount'] == gj['exceptionCount'] == 2
                assert bytes(gr.observedInput) == ib
                assert gr.observedReply.valueCount == count * 3 and gr.observedReply.reserved == 0
                assert bytes(gr.observedReply.values) == b + bytes((600 - count * 3) * 4)
                h = fnv(b)
                assert gj['guestChecksum'] == gj['hostExpectedChecksum'] == m['guestChecksum'] == h
                assert gj['guestReadCount'] == m['guestReadCount'] == count * 3
                assert gj['elapsedNanoseconds'] == m['guestElapsedNanoseconds'] <= m['totalWallNanoseconds']
                for i, ex in enumerate(gj['exits']):
                    assert ex['validated'] == 1 and ex['runStatus'] == 0 and ex['reason'] == 1 and ex['syndrome'] == 0x5a000051 + i
                    assert ex['pc'] in ([0x1000002c, 0x10000030] if i == 0 else [0x10000090, 0x10000094])
                    assert ex['cpsr'] & ~0xf0000000 == 0x3c5 and ex['sctlr'] == 0x30d00980
                    assert ex['x20'] == 0x10004000 and ex['x21'] == 0x10005000 and ex['x22'] == ex['x3'] == count * 3
                    if i == 0: assert (ex['x0'], ex['x1'], ex['x2'], ex['x23'], ex['x27'], ex['x28']) == (1, 0x10004040, 0x10005000, 0, 0, 0)
                    else: assert (ex['x0'], ex['x1'], ex['x2'], ex['x23'], ex['x27'], ex['x28']) == (2, count * 3, h, count * 3, h, 0x100000001b3)
                guest_values += count * 3; guest_entries += 2
            bindings.append(pin(p))
        assert data_by_route['host'] == data_by_route['guest']; pairs += 1
    for route in ('host', 'guest'):
        ms = [m for m in measurements if m['pointCount'] == count and m['route'] == route]
        row = {'pointCount': count, 'route': route, 'samples': 8}
        for key in ('gpuNanoseconds', 'callbackWallNanoseconds', 'totalWallNanoseconds'):
            available = [m[key] for m in ms if m[key] is not None]
            row[key] = stats(available) if available else None
        table.append(row)

negatives = load(N / 'invalid-checks.json'); assert len(negatives) == 4
for j, case in enumerate(negatives[:3]):
    r = case['result']; assert case['case'] == j
    assert r['status'] == 1 and r['cleanupComplete'] == 1
    assert r['runCount'] == r['callbackCount'] == r['completionHVCCount'] == r['inputValidated'] == 0
    assert r['vmCreateStatus'] == r['vcpuCreateStatus'] == -(1 << 31)
bad = negatives[3]['result']; lifecycle(bad)
br = read_result('invalid-reply.bin', bad)
assert negatives[3]['case'] == 'nonfinite_fixture_reply_no_GPU' and bad['status'] == 7
assert bad['runCount'] == bad['callbackCount'] == 1 and bad['completionHVCCount'] == bad['replyReturnCount'] == bad['guestReadCount'] == 0
assert math.isnan(br.observedReply.values[0]) and br.observedReply.valueCount == 3
assert all(v == 0 for v in br.observedReply.values[1:])
warm = load(N / 'warmup.json'); assert len(warm) == 2
assert all(m['commandBufferStatus'] == 4 and m['valueCount'] == 600 and m['CPUFallback'] is False for m in warm)

controller = W / 'Live/controller'; c = load(controller / 'result.json')
assert c['passed'] and c['exit_status'] == c['raw_wait_status'] == 0
assert c['pid'] == c['requested_wait_pid'] == c['returned_wait_pid'] and c['exact_reap_count'] == 1
assert c['termination_signal'] is c['reason'] is c['runner_error'] is None
assert c['signals'] == c['process_group_members_after_reap'] == []
for stream in ('stdout', 'stderr'):
    d = (controller / (stream + '.bin')).read_bytes(); s = c['streams'][stream]
    assert s['eof'] and s['total_bytes'] == s['captured_bytes'] == len(d) and s['sha256'] == sha(d)
spec = load(W / 'Live/specification.json'); inv = load(controller / 'invocation.json')
assert spec['argv'] == inv['argv'] and spec['environment'] == inv['replacement_environment']
build = load(W / 'NativeGPU/build02/build-result.json')
assert build['status'] == 'COMPILED_NOT_EXECUTED' and build['inputsUnchanged']
for b in build['inputs']:
    p = Path(b['path']); pb = p.read_bytes(); assert len(pb) == b['byteCount'] and sha(pb) == b['sha256']
ad = load(N / 'admission.json')
for k in 'status signature_valid identity_matches team_matches hardened_runtime hypervisor_entitlement_true entitlement_set_exact effective_hypervisor_true'.split(): assert ad[k] == 1
assert ad['ad_hoc'] == ad['get_task_allow_present'] == ad['app_sandbox_present'] == ad['unexpected_entitlement_count'] == 0
assert guest_values == result['guestReturnedFloatValues'] == 5592 and guest_entries == result['measuredGuestEntries'] == 48

report = {'status': 'INDEPENDENT_READBACK_PASSED', 'device': result['device'],
    'hostGuestByteIdenticalPairs': pairs, 'measuredVectorFiles': len(bindings), 'measuredVectorBytes': sum(x['bytes'] for x in bindings),
    'guestReturnedFloatValues': guest_values, 'measuredGuestEntries': guest_entries, 'measuredGuestVMs': 24,
    'CPUFormulaParity': {'allWithinDeclaredTolerances': True, 'maximumPotentialError': max_v, 'maximumGradientError': max_g,
        'maximumErrorDifferenceFromRecordedSwiftCPU': max_reported_error_delta, 'formula': 'V=-sum(w*exp(-r2/(2*sigma2))); gradient=sum(w*exp(-r2/(2*sigma2))*(p-node)/sigma2)',
        'potentialTolerance': 'max(1e-5,1e-4*max(abs(reference),abs(actual)))', 'gradientTolerance': 'max(1e-4,1e-3*max(abs(reference),abs(actual)))'},
    'validMeasuredGPUTimestamps': valid_timestamps, 'timingsNanoseconds': table, 'initializationNanoseconds': result['initializationNanoseconds'],
    'warmupGPUDispatches': 2, 'negativeChecks': {'preVMRejections': 3, 'nonfiniteReplyVM': 1, 'GPUUsedForNegativeReply': False, 'rawNaNBitsRetained': True},
    'controller': {'PID': c['pid'], 'normalExit': 0, 'exactReapCount': 1, 'groupEmpty': True, 'streamsEOFAndHashesVerified': True, 'elapsedSeconds': c['elapsed_seconds']},
    'rawCRecordsAndJSONExact': 25, 'allBuild02InputsUnchanged': True, 'admissionReceiptVerified': True,
    'currentSignedExecutableBinding': pin(Path(spec['argv'][0])), 'sourceBuildReceipt': pin(W / 'NativeGPU/build02/build-result.json'),
    'resultBinding': pin(N / 'result.json'), 'vectorBindings': bindings, 'reviewer': pin(Path(__file__)),
    'limits': ['Only saved artifacts were read; no new model, GPU, VM or calibration execution.',
        'Eight paired samples per size, with alternating route order and two shared GPU warmups. Every guest sample creates a fresh VM.',
        'GPU interval, evaluator wall and full route wall have separate scopes. No speedup, utilization or isolated vCPU-cost claim.',
        'Custom typed HVC-to-host-Metal offload; no Apple PGDevice or learned model execution. CPU formula is independent scoring, not a reply fallback.',
        'Admission receipt and current executable bytes verified here; no fresh codesign trust evaluation was launched.']}
out = W / 'Readiness/LIVE-REVIEW.json'
with out.open('x') as f: json.dump(report, f, indent=2); f.write('\n')
print(json.dumps({'report': pin(out), 'hostGuestByteIdenticalPairs': pairs, 'validMeasuredGPUTimestamps': valid_timestamps,
                  'CPUFormulaParity': report['CPUFormulaParity'], 'timingsNanoseconds': table}, indent=2))
