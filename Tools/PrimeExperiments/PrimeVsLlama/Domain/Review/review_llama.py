#!/usr/bin/env python3
"""Read completed evidence only. No inference, model import, or evidence writes."""
from pathlib import Path
import collections, hashlib, json, re

W = Path(__file__).resolve().parent.parent
C = W / 'Comparison'
L = C / 'Llama'
BASE = W.parents[1] / 'outputs/Prime-Experiment-Builds'
assert (L / 'COMPLETE.json').is_file(), 'Llama remains pending'
pins = {}
failures = []
checks = 0

def data(p):
    b = p.read_bytes()
    pin = {'path': str(p), 'byteCount': len(b), 'sha256': hashlib.sha256(b).hexdigest()}
    if str(p) in pins: assert pins[str(p)] == pin, 'review input changed'
    pins[str(p)] = pin
    return b

def read(p): return json.loads(data(p))
def sha(b): return hashlib.sha256(b).hexdigest()
def check(ok, coordinate):
    global checks
    checks += 1
    if not ok: failures.append(coordinate)

def control(folder):
    r = read(folder / 'controller/result.json')
    check(r['passed'] is True and r['exit_status'] == 0 and r['raw_wait_status'] == 0 and
          r['termination_signal'] is None and r['reason'] is None and r['runner_error'] is None and
          r['signals'] == [] and r['process_group_members_after_reap'] == [] and
          r['exact_reap_count'] == 1 and r['pid'] == r['requested_wait_pid'] == r['returned_wait_pid'],
          str(folder) + ':normal_exact_reap_empty_group')
    streams = {}
    for name in ['stdout', 'stderr']:
        b = data(folder / ('controller/' + name + '.bin')); s = r['streams'][name]
        check(s['eof'] is True and s['total_bytes'] == s['captured_bytes'] == len(b) and
              s['sha256'] == sha(b), str(folder) + ':' + name + '_capture')
        streams[name] = b
    return r, streams

complete = read(L / 'COMPLETE.json')
check(complete == {'caseCount': 32, 'status': 'completed'}, 'Llama completion marker')
inputs = read(L / 'Inputs/cases.json')
cases = inputs['cases']
gold = {r['id']: r for r in read(L / 'References/gold.json')['cases']}
all_inputs = {r['id']: r for r in read(C / 'Inputs/cases.json')['cases']}
all_gold = {r['id']: r for r in read(C / 'References/gold.json')['cases']}
audit = read(L / 'INPUT-AUDIT.json')
check(len(cases) == len(gold) == 32 and len({c['id'] for c in cases}) == 32, 'exact32 distinct cases')
check(audit['caseFileSHA256'] == pins[str(L / 'Inputs/cases.json')]['sha256'], 'input audit hash')
check(audit['ruleSheetSHA256'] == sha(data(L / 'Inputs/policy-rules.md')), 'policy rule hash')
runner = data(W / 'run_llama.py')
inference = data(C / 'llama_domain_compare.py')
controller_path = BASE / 'Prime-vCPU-02/Runtime/controller.rb'
controller_sha = sha(data(controller_path))
sealed = read(BASE / '0002-older-llama/file-manifest.json')
model_files = {p['path'].removeprefix('Runtime/model/'): {'bytes': p['byteCount'], 'sha256': p['sha256']}
               for p in sealed['files'] if p['path'].startswith('Runtime/model/')}
check(len(model_files) == 8, 'eight sealed Llama model/tokenizer leaves')
roles = ['direct', 'leftSummary', 'rightSummary', 'final']
scores = {r: collections.Counter() for r in roles}
case_rows = []
controller_pids = []

def conditional_target(left, right):
    if left == 224 or right == 224: return 224, 'abstain_propagation'
    if not (128 <= left <= 163 and 128 <= right <= 163): return None, 'undefined_summary_symbol'
    lb, rb = (left - 128) // 3, (right - 128) // 3
    if lb == rb: return None, 'undefined_equal_band'
    return (192 + (left - 128) % 3 if lb > rb else 195 + (right - 128) % 3), 'defined_unequal_band'

for i, c in enumerate(cases):
    ident = c['id']; g = gold[ident]; orig = all_inputs[ident]
    check(g['expectedJobIDs'] == all_gold[ident]['expectedJobIDs'], ident + ':separate gold join')
    expected_arrays = [c['directInputIDs'], c['leftInputIDs'], c['rightInputIDs']]
    check([j['inputTokenIDs'] for j in orig['jobs'][:3]] == expected_arrays, ident + ':same underlying native inputs')
    check(orig['jobs'][3]['inputTokenIDs'] == c['finalPrefixIDs'] + [0, 0] + c['finalSuffixIDs'], ident + ':same final prefix/suffix')
    folder = L / 'Results' / ('case-%03d' % i)
    req = read(folder / 'request.json'); spec = read(folder / 'specification.json')
    check(req == {'schema':'prime_llama_domain_comparison_v1', 'modelPath':str(BASE / '0002-older-llama/Runtime/model'),
                  'maximumNewTokens':512, 'cases':[c]}, ident + ':exact input-only request')
    inv = read(folder / 'controller/invocation.json')
    check(inv['argv'] == spec['argv'] == [str(BASE / 'SharedRuntime/python/bin/python3'), str(C / 'llama_domain_compare.py'), '--request', str(folder / 'request.json')], ident + ':argv')
    check(inv['runner_sha256'] == controller_sha and inv['replacement_environment'] == spec['environment'] and
          inv['timeout_seconds'] == 120 and inv['stdin'] == 'owned EOF pipe' and
          spec['referencesProvidedToModel'] is False and spec['trainingPerformed'] is False and
          spec['environment']['HF_HUB_OFFLINE'] == '1' and spec['environment']['TRANSFORMERS_OFFLINE'] == '1', ident + ':controller/offline policy')
    cr, streams = control(folder); controller_pids.append(cr['pid'])
    check(read(folder / 'outer.stdout') == cr and data(folder / 'outer.stderr') == b'', ident + ':outer joins')
    events = [json.loads(line) for line in streams['stdout'].splitlines()]
    check(events[0]['type'] == 'loaded' and events[-1] == {'type':'complete','caseCount':1,'modelUnchanged':True,'trainingPerformed':False,'goldTargetsProvided':False}, ident + ':loaded/complete order')
    loaded = events[0]
    check(loaded['modelFiles'] == model_files and loaded['requestSHA256'] == pins[str(folder / 'request.json')]['sha256'] and
          loaded['trainingPerformed'] is False and loaded['goldTargetsProvided'] is False, ident + ':model and request hash bindings')
    preds = [r for r in events if r['type'] == 'prediction']
    summary = events[-2]
    check(summary['type'] == 'case_complete' and summary['caseID'] == ident and
          [p['jobIndex'] for p in preds] in [[0,1,2], [0,1,2,3]] and len(events) == len(preds) + 3, ident + ':exact ordered events')
    valid = []; rows = []
    for j, pred in enumerate(preds):
        text = pred['rawOutput']; match = re.fullmatch(r'\s*([0-9]{1,5})\s*', text)
        parsed = int(match[1]) if match else None
        accepted = parsed is not None and 0 <= parsed < 16384 and pred['stopReason'] != 'deadline'
        check(pred['caseID'] == ident and pred['parsedSymbolID'] == parsed and pred['validVocabularySymbol'] == accepted and
              pred['maximumNewTokens'] == 512 and len(pred['generatedTokenIDs']) <= 512 and
              all(type(t) is int and 0 <= t < 128256 for t in pred['generatedTokenIDs']) and
              pred['stopReason'] in ['endOfSequence','tokenLimit','deadline'] and pred['outputRewritten'] is False,
              ident + ':job%d raw parse/token budget' % j)
        expected_question = c[['directQuestion','leftQuestion','rightQuestion'][j]] if j < 3 else c['finalQuestionTemplate'].replace('{left_summary_symbol}', str(valid[1])).replace('{right_summary_symbol}', str(valid[2]))
        sources = [] if j < 3 else [{'jobIndex':1,'predictedSymbolID':valid[1]}, {'jobIndex':2,'predictedSymbolID':valid[2]}]
        check(pred['question'] == expected_question and pred['questionSHA256'] == sha(expected_question.encode()) and pred['feedbackSources'] == sources,
              ident + ':job%d exact question/actual-source provenance' % j)
        valid.append(parsed if accepted else None)
        role = roles[j]; metric = scores[role]
        metric['attempted'] += 1; metric['decimalOnlyFormat'] += match is not None
        metric['validVocabularySymbol'] += accepted
        metric['allowedTaskSymbol'] += accepted and (parsed == 224 or (128 <= parsed <= 163 if j in [1,2] else 192 <= parsed <= 197))
        metric['correctOriginalTarget'] += accepted and parsed == g['expectedJobIDs'][j]
        metric['numeric224'] += accepted and parsed == 224
        metric['literalABSTAINOnly'] += text.strip() == 'ABSTAIN'
        metric['containsLiteralABSTAIN'] += re.search(r'\bABSTAIN\b', text) is not None
        metric[pred['stopReason']] += 1
        row = {'jobIndex':j,'role':role,'rawOutput':text,'parsedSymbolID':parsed,'validVocabularySymbol':accepted,
               'expectedOriginalTarget':g['expectedJobIDs'][j],'correctOriginalTarget':accepted and parsed == g['expectedJobIDs'][j],
               'generatedTokenCount':len(pred['generatedTokenIDs']),'stopReason':pred['stopReason'], 'questionSHA256':pred['questionSHA256'],
               'actualFeedbackSources':sources}
        if j == 3:
            target, rule = conditional_target(valid[1], valid[2])
            row['actualInputCombinerRule'] = rule; row['actualInputCombinerTarget'] = target
            row['correctForActualFeedback'] = None if target is None else accepted and parsed == target
            metric['actualInputRuleDefined'] += target is not None
            metric['correctForActualFeedback'] += target is not None and accepted and parsed == target
            metric[rule] += 1
        rows.append(row)
    expected_final = valid[3] if len(valid) == 4 else None
    check(summary['directSymbolID'] == valid[0] and summary['leftSymbolID'] == valid[1] and summary['rightSymbolID'] == valid[2] and
          summary['finalSymbolID'] == expected_final and summary['traceCompleted'] == (expected_final is not None) and
          summary['continuationStopped'] == (valid[1] is None or valid[2] is None) and
          (len(preds) == 4) == (valid[1] is not None and valid[2] is not None), ident + ':case summary/continuation')
    case_rows.append({'id':ident,'sourceSplit':g['sourceSplit'],'represented':g['represented'],'expectedJobIDs':g['expectedJobIDs'],
                      'controllerPID':cr['pid'],'predictions':rows,'finalAttempted':len(preds)==4,
                      'allFourCorrect':len(rows)==4 and all(p['correctOriginalTarget'] for p in rows)})

check(len(set(controller_pids)) == 32, 'distinct32 Llama processes')
# Small result projections only: the separate numerical audit owns native full-logit hashing.
native_models = {str(r['seed']):r for r in read(C / 'References/model-bindings.json')}
native_rows = collections.defaultdict(list)
read(C / 'NATIVE-COMPLETE.json')
for p in sorted((C / 'Results').glob('seed-*-*-batch-*/native/result.json')):
    n = read(p); selected = [g for g in n['cases'] if g['id'] in gold]
    if not selected: continue
    seed = p.parents[1].name.split('-')[1]; route = n['execution']; expected_model = native_models[seed]
    check(n['status'] == 'completed' and n['trainingPerformed'] is False and n['modelWeightsInGuest'] is False and
          n['weightsBefore'] == n['weightsAfter'] == {'byteCount':expected_model['weightsBytes'],'sha256':expected_model['weightsSHA256']}, str(p)+':native binding')
    request = read(p.parent / 'request.json'); check(n['requestSHA256'] == pins[str(p.parent / 'request.json')]['sha256'], str(p)+':native request')
    for group in selected:
        ident=group['id']; original=all_inputs[ident]; values=[]
        check(group['status']=='completed' and len(group['predictions'])==4, ident+':native4jobs')
        for j,pred in enumerate(group['predictions']):
            expected=list(original['jobs'][j]['inputTokenIDs'])
            for binding in original['jobs'][j]['feedbackBindings']: expected[binding['inputOffset']]=values[binding['sourceJobIndex']]
            check(pred['inputTokenIDs']==expected and pred['logitsFinite'] is True and 0<=pred['predictionTokenID']<16384, ident+':native actual feedback')
            values.append(pred['predictionTokenID'])
        native_rows[seed+'-'+route].append({'id':ident,'predictedIDs':values,'correct':[a==b for a,b in zip(values,gold[ident]['expectedJobIDs'])]})
native_scores={}
for key,rows in native_rows.items():
    check(len(rows)==32 and len({r['id'] for r in rows})==32, key+':exact matching subset')
    native_scores[key]={'cases':len(rows),'perJobCorrect':{role:sum(r['correct'][j] for r in rows) for j,role in enumerate(roles)},
                        'allFourCorrect':sum(all(r['correct']) for r in rows),'numeric224PerJob':{role:sum(r['predictedIDs'][j]==224 for r in rows) for j,role in enumerate(roles)}}
check(len(native_scores)==6, 'three seeds by two routes')
for seed in native_models:
    host={r['id']:r['predictedIDs'] for r in native_rows[seed+'-host']}
    guest={r['id']:r['predictedIDs'] for r in native_rows[seed+'-guest']}
    check(host==guest, seed+':host/guest subset prediction parity')
report={'status':'VERIFIED_COMPLETED_COMPARISON' if not failures else 'REVIEW_FAILED','checks':checks,'failedChecks':failures,
        'scope':'32 input-matched symbolic policy cases. Llama receives fresh explicit rule prompts; three Prime checkpoints were trained on this finite task. This is not equal-training or general model-quality evidence.',
        'llama':{'caseCount':32,'representedCases':sum(r['represented'] for r in case_rows),'malformedCases':sum(not r['represented'] for r in case_rows),
                 'controllersPassed':32 if not failures else None,'jobs':{k:dict(v) for k,v in scores.items()},
                 'continuationsStopped':sum(not r['finalAttempted'] for r in case_rows),'allFourCorrect':sum(r['allFourCorrect'] for r in case_rows),
                 'cases':case_rows},'nativeMatchingSubset':native_scores,'nativeSubsetPredictions':dict(native_rows),
        'sourceReview':['Inference code reads only the request and retained model; separate References/gold is used by this review after inference.',
                        'Job3 prompt uses the actual accepted decimal job1/job2 outputs without recomputing summaries. Valid numeric224 is propagated; literal ABSTAIN is retained as invalid requested numeric format.',
                        'A parsed vocabulary ID is not automatically a valid task answer. Summary IDs128..163/224 and final IDs192..197/224 are counted separately.',
                        'Undefined equal-band or other summary inputs receive no invented oracle rule. Original final-target accuracy remains an end-to-end measure, with conditional combiner scoring separately reported.',
                        'Controller evidence is an exact leader wait/EOF/empty recorded process-group observation, not detached-session or App Sandbox containment.'],
        'limits':['Scoring consumes saved outputs and token IDs; token decoding was not independently rerun.','Before/after model equality is recorded by each unchanged inference process and joined to the sealed eight-file manifest. This reader does not duplicate the 1.807GB model rehash.','No generation, training, VM execution or scientific tensor changes were performed by this reader.'],
        'evidence':list(pins.values())}
out=W/'Review/LLAMA-REVIEW.json'
with out.open('x') as f: json.dump(report,f,indent=2);f.write('\n')
examples=['# Recorded domain-policy outputs','',report['scope'],'',
          'The quoted strings below are verbatim model outputs. Numeric format, task-symbol validity and reference correctness are separate.','']
chosen=[]
for row in case_rows:
    if len(chosen)<2 or any(p['parsedSymbolID']==224 or p['rawOutput'].strip()=='ABSTAIN' for p in row['predictions']):
        chosen.append(row)
    if len(chosen)>=5:break
for row in chosen:
    examples.extend(['## '+row['id'],'','Source split: '+row['sourceSplit']+'. Reference IDs: `'+str(row['expectedJobIDs'])+'`.',''])
    for pred in row['predictions']:
        examples.extend([pred['role']+' (expected '+str(pred['expectedOriginalTarget'])+'):','', '```text',pred['rawOutput'],'```',''])
    last=row['predictions'][-1]
    if last['jobIndex']==3: examples.extend(['Final prompt feedback: `'+json.dumps(last['actualFeedbackSources'])+'`. Conditional rule: `'+last['actualInputCombinerRule']+'`.',''])
with (W/'Review/examples.md').open('x') as f:f.write('\n'.join(examples)+'\n')
print(json.dumps({'status':report['status'],'checks':checks,'failedChecks':failures,'llamaJobs':report['llama']['jobs'],'continuationsStopped':report['llama']['continuationsStopped'],'nativeSubset':native_scores},indent=2))
raise SystemExit(1 if failures else 0)
