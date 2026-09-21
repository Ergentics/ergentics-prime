#!/usr/bin/env python3
"""Independently review saved guest outputs; only standard-library file reads.

No Swift, Metal, MLX, guest, subprocess, training or inference is invoked.
"""
import collections
import hashlib
import json
import math
from pathlib import Path
import struct

HERE = Path(__file__).resolve().parent
TASK = HERE.parents[2]
OUT = TASK / 'outputs/Prime-Experiment-Builds/Prime-vCPU-02'
BUILD = TASK / 'outputs/Prime-Experiment-Builds/0008-prime-vcpu-runtime'

def digest(data):
    return hashlib.sha256(data).hexdigest()

def read_json(path):
    return json.loads(path.read_bytes())

def score(rows):
    total = len(rows)
    return {'cases': total, **{key: {'correct': sum(r[key] for r in rows), 'total': total,
                                  'fraction': sum(r[key] for r in rows) / total}
                              for key in ['directFinalCorrect', 'traceFinalCorrect', 'fullTraceCorrect']}}

def main():
    baseline_path = OUT / 'References/previous-host-baseline-index.json'
    baseline_data = read_json(baseline_path)
    baseline = {(r['model'], r['caseID'], r['jobIndex']): r for r in baseline_data['rows']}
    assert len(baseline) == 720
    source_cases = {c['id']: c for c in read_json(OUT / 'References/original-input-cases.json')['cases']}
    gold = {c['id']: c for c in read_json(OUT / 'References/gold.json')['cases']}
    assert set(source_cases) == set(gold) and len(gold) == 80
    # Independently recompute all intermediate/reference outputs.
    permutation = [3, 0, 6, 1, 7, 4, 2, 5]
    for case_id, ref in gold.items():
        value = ref['semanticStart']
        values = []
        for op in ref['semanticOperations']:
            value = ((value + 1) if op == 32 else (value - 1) if op == 33 else -value) % 8
            values.append(16 + value if source_cases[case_id]['surface'] == 'canonical' else 64 + permutation[value])
        assert values == ref['expectedStateIDs'] and values[-1] == ref['directTargetID']
    projections = read_json(OUT / 'References/PROJECTION-AUDIT.json')
    requests_expected = {(r['model'], r['batch']): r['sha256'] for r in projections['requests']}
    issues, jobs, feedback, phases, case_scores = [], [], [], [], []
    seen = set()
    counter = collections.Counter()
    for model in ['0006', '0007']:
        for batch in range(10):
            native = OUT / 'Results' / f'{model}-batch-{batch:02d}' / 'native'
            rp = native / 'result.json'
            data = read_json(rp)
            requested_path = OUT / 'Requests' / model / f'batch-{batch:02d}.json'
            requested_bytes = requested_path.read_bytes()
            request_hash = digest(requested_bytes)
            request = json.loads(requested_bytes)
            assert request_hash == requests_expected[(model, batch)]
            assert native.joinpath('request.json').read_bytes() == requested_bytes
            assert data['requestSHA256'] == request_hash
            assert data['status'] == 'completed'
            assert data['weightsBefore'] == data['weightsAfter']
            assert data['weightsBefore']['sha256'] == request['weightsSHA256']
            assert data['weightsPath'] == request['weightsPath']
            assert data['modelWeightsInGuest'] is False and data['trainingPerformed'] is False
            assert data['parameterCount'] == 10227968 and data['tensorCount'] == 74
            assert data['admission']['observations']['status'] == 1
            case_requests = {c['id']: c for c in request['cases']}
            assert len(case_requests) == len(data['cases']) == 8
            assert set(case_requests) == {c['id'] for c in data['cases']}
            phases.append({'model': model, 'batch': batch, 'resultPath': str(rp),
                           'resultSHA256': digest(rp.read_bytes()), 'requestSHA256': request_hash,
                           'device': data['device'], 'weightsSHA256': request['weightsSHA256']})
            for group in data['cases']:
                case_id = group['id']
                cr = case_requests[case_id]
                predictions = group['predictions']
                guest = group['guest']
                obs = guest['observations']
                n = len(cr['jobs'])
                assert group['status'] == 'completed' and len(predictions) == n
                assert obs['status'] == obs['failureCode'] == 0
                assert obs['callbackCount'] == obs['completedCount'] == obs['requestedCount'] == n
                assert obs['inferenceRequestCount'] == obs['inferenceReturnCount'] == n
                assert obs['runCount'] == obs['exceptionCount'] == n + 1
                assert obs['completionHVCCount'] == 1
                assert obs['cleanupComplete'] == obs['guestInputChecksPassed'] == obs['registerChecksPassed'] == 1
                assert obs['codeImmutableValidated'] == obs['dataGuardValidated'] == 1
                assert obs['watchdogFired'] == obs['watchdogExitCalls'] == 0
                assert all(e['runStatusBits'] == 0 and e['validated'] == 1 for e in guest['exits'])
                assert len(guest['exits']) == n + 1
                assert guest['guestCommittedPredictions'] == [p['predictionTokenID'] for p in predictions]
                assert len(guest['observedInputTokenIDs']) == n
                counter['guestCases'] += 1
                counter['guestRunEntries'] += obs['runCount']
                counter['guestCommittedPredictions'] += n
                previous = None
                for index, prediction in enumerate(predictions):
                    key = (model, case_id, index)
                    assert key not in seen and key in baseline
                    seen.add(key)
                    old = baseline[key]
                    assert prediction['id'] == case_id
                    template = cr['jobs'][index]
                    expected = list(template['inputTokenIDs'])
                    offset = template['priorPredictionOffset']
                    if index <= 1:
                        assert offset == -1
                    else:
                        assert offset >= 0 and expected[offset] == 0 and previous is not None
                        expected[offset] = previous
                        feedback.append({'model': model, 'caseID': case_id, 'jobIndex': index,
                                         'placeholderInSavedRequest': template['inputTokenIDs'][offset],
                                         'offset': offset, 'actualPreviousPrediction': previous,
                                         'actualGuestSlot': prediction['inputTokenIDs'][offset],
                                         'matches': prediction['inputTokenIDs'][offset] == previous})
                    actual_ids = prediction['inputTokenIDs']
                    raw_path = native / prediction['logits']['path']
                    raw = raw_path.read_bytes()
                    old_raw_path = Path(old['logitsPath'])
                    old_raw = old_raw_path.read_bytes()
                    assert len(raw) == len(old_raw) == 65536
                    values = struct.unpack('<16384f', raw)
                    finite = all(math.isfinite(x) for x in values)
                    # Python max returns the first equal value, matching lowest-ID ties.
                    argmax = max(range(len(values)), key=values.__getitem__)
                    checks = {
                        'inputIDsExactBaseline': actual_ids == old['inputTokenIDs'],
                        'actualInputsEqualFreshFeedbackTemplate': actual_ids == expected,
                        'actualInputsEqualGuestReceipt': actual_ids == guest['observedInputTokenIDs'][index],
                        'logitsBytesExactBaseline': raw == old_raw,
                        'logitsHashExactBaseline': digest(raw) == old['logitsSHA256'],
                        'baselineRawHashStillMatches': digest(old_raw) == old['logitsSHA256'],
                        'newRawHashMatchesReceipt': digest(raw) == prediction['logits']['content']['sha256'],
                        'all16384RawLogitsFinite': finite,
                        'rawArgmaxEqualsReportedPrediction': argmax == prediction['predictionTokenID'],
                        'predictionExactBaseline': prediction['predictionTokenID'] == old['predictionTokenID'],
                        'maximumLogitFloat32BitsMatch': struct.pack('<f', prediction['maximumLogit']) == raw[argmax * 4:argmax * 4 + 4],
                        'logitsReceiptShapeAndSize': prediction['logits']['shape'] == [16384]
                            and prediction['logits']['content']['byteCount'] == len(raw)
                            and prediction['logits']['dtype'] == 'float32_little_endian',
                    }
                    failed = [k for k, v in checks.items() if not v]
                    if failed:
                        issues.append({'model': model, 'caseID': case_id, 'jobIndex': index, 'failedChecks': failed})
                    for name, passed in checks.items():
                        counter[name] += passed
                    jobs.append({'model': model, 'caseID': case_id, 'jobIndex': index,
                                 'allChecksPassed': not failed, 'rawLogitsPath': str(raw_path),
                                 'rawLogitsSHA256': digest(raw), 'baselineLogitsPath': str(old_raw_path),
                                 'prediction': prediction['predictionTokenID'], 'independentRawArgmax': argmax})
                    previous = prediction['predictionTokenID']
                ref = gold[case_id]
                direct = predictions[0]['predictionTokenID']
                trace = [x['predictionTokenID'] for x in predictions[1:]]
                case_scores.append({'model': model, 'id': case_id, 'axis': source_cases[case_id]['axis'],
                                    'depth': source_cases[case_id]['depth'],
                                    'directPrediction': direct, 'tracePredictions': trace,
                                    'directFinalCorrect': direct == ref['directTargetID'],
                                    'traceFinalCorrect': trace[-1] == ref['directTargetID'],
                                    'fullTraceCorrect': trace == ref['expectedStateIDs']})
    assert seen == set(baseline) and len(jobs) == 720 and len(feedback) == 400
    scores = {m: {'aggregate': score([r for r in case_scores if r['model'] == m]),
                  'perAxis': {a: score([r for r in case_scores if r['model'] == m and r['axis'] == a])
                              for a in sorted({r['axis'] for r in case_scores})}}
              for m in ['0006', '0007']}
    current_source = HERE.parent / 'Native/main.swift'
    packaged_source = BUILD / 'Source/Native/main.swift'
    final_bytes = current_source.read_bytes()
    assert final_bytes == packaged_source.read_bytes()
    final_text = final_bytes.decode()
    final_fragment = ('"x0":e.x0,"x1":e.x1,"x2":e.x2,"x3":e.x3,\n'
                      '                 "x20":e.x20,"x21":e.x21,"x22":e.x22,"x23":e.x23,"x24":e.x24,"sctlr":e.sctlr,"validated":UInt64(e.validated)]')
    previous_fragment = '"x0":e.x0,"x1":e.x1,"x2":e.x2,"x3":e.x3,"validated":UInt64(e.validated)]'
    assert final_text.count(final_fragment) == 1
    reconstructed_previous = final_text.replace(final_fragment, previous_fragment).encode()
    old_review = read_json(OUT / 'References/SWIFT-REVIEW.json')
    reviewed_before = next(r['sha256'] for r in old_review['reviewedSources'] if r['path'].endswith('/Native/main.swift'))
    assert digest(reconstructed_previous) == reviewed_before
    report = {
        'schema': 'prime_vcpu_independent_numerical_review_v1',
        'outcome': 'PASS_EXACT720JOB_HOST_BASELINE_PARITY' if not issues else 'FAIL_NUMERICAL_OR_INPUT_MISMATCH',
        'reviewScript': {'path': str(Path(__file__).resolve()), 'sha256': digest(Path(__file__).read_bytes())},
        'baselineIndex': {'path': str(baseline_path), 'sha256': digest(baseline_path.read_bytes())},
        'counts': {'phases': len(phases), 'models': 2, 'cases': len(case_scores), 'jobs': len(jobs),
                   'freshFeedbackSlots': len(feedback), 'rawFloat32LogitsChecked': len(jobs) * 16384,
                   'rawNewLogitsBytesCompared': len(jobs) * 65536, **dict(counter)},
        'exactMismatches': issues,
        'allFreshGuestFeedbackSlotsMatchActualPrecedingPredictions': all(f['matches'] for f in feedback),
        'allSavedDynamicSlotsAreZeroPlaceholders': all(f['placeholderInSavedRequest'] == 0 for f in feedback),
        'requestFilesExactlyMatchIndependentInputOnlyProjection': True,
        'referenceAnswersRecomputedIndependently': True,
        'sourceBindingRefresh': {'previousReviewPath': str(OUT / 'References/SWIFT-REVIEW.json'),
                                 'previousNativeSwiftSHA256': reviewed_before,
                                 'finalNativeSwiftPath': str(current_source), 'finalNativeSwiftSHA256': digest(final_bytes),
                                 'packagedNativeSwiftPath': str(packaged_source), 'packagedEqualsReviewedFinalSource': True,
                                 'onlyChangeSincePreviousReview': 'GuestReceipt exit serialization adds x20,x21,x22,x23,x24,sctlr fields. Reversing only that exact addition reproduces previously reviewed source SHA256.',
                                 'inferenceCodeUnchangedSinceReview': True},
        'scores': scores, 'caseScores': case_scores, 'jobReviews': jobs, 'freshFeedback': feedback, 'phaseReceipts': phases,
        'interpretation': 'All720 actual host-Metal neural forwards in the vCPU-controlled runs reproduce the prior host-only inputs, complete16384-logit vectors byte-for-byte, and predictions. This establishes integration equivalence, not increased model quality.',
        'scope': ['80 correlated input variations per checkpoint from2 original semantic programs across5 axes and8starts.',
                  'Guest controls requests and carries actual predictions; weights and numerical model execution remain in the host Swift Metal process.',
                  'No training, GPU execution, or guest execution was performed by this review; only retained files were decoded and compared.',
                  'C bridge lifecycle/signature/architecture review is separate; this review verifies its saved guest observation values and input/output correspondence.'],
        'originalResultsModified': False,
    }
    destination = OUT / 'NUMERICAL-REVIEW.json'
    with destination.open('x') as f:
        json.dump(report, f, indent=2, sort_keys=True)
        f.write('\n')
    print(json.dumps({'path': str(destination), 'sha256': digest(destination.read_bytes()),
                      'outcome': report['outcome'], 'counts': report['counts'],
                      'scores': {m: s['aggregate'] for m, s in scores.items()}, 'mismatches': issues}, indent=2))

if __name__ == '__main__':
    main()
