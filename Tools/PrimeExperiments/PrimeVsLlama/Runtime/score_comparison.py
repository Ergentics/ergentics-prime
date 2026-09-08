#!/usr/bin/env python3
"""Score retained predictions after inference; never import or invoke a model."""
import collections
import csv
import hashlib
import json
from pathlib import Path
import sys

out = Path(sys.argv[1]).resolve()
assert json.loads((out/'RUN-COMPLETE.json').read_text())['status'] == 'completed'
cases = {c['id']: c for c in json.loads((out/'Inputs/cases.json').read_text())['cases']}
gold = {c['id']: c for c in json.loads((out/'References/gold.json').read_text())['cases']}
assert cases.keys() == gold.keys() and len(cases) == 80

def counts(rows):
    keys = ['directCorrect', 'traceFinalCorrect', 'fullTraceCorrect', 'traceCompleted',
            'directAssignedValue', 'finalCorrectWithIntermediateError']
    return dict(caseCount=len(rows), **{k: sum(r[k] for r in rows) for k in keys})

models, all_rows = [], []
for name, label in [('0006', 'Prime Swift 4000'), ('0007', 'Prime Swift 8000'), ('llama', 'Older Ergentics Llama 3.2 3B')]:
    path = out/'Results'/f'{name}-summary.json'
    data = json.loads(path.read_text())
    assert len(data['cases']) == 80 and {r['caseID'] for r in data['cases']} == cases.keys()
    rows = []
    for r in data['cases']:
        c, g = cases[r['caseID']], gold[r['caseID']]
        full = r['traceCompleted'] and r['traceValueTokenIDs'] == g['expectedStateIDs']
        final = r['traceCompleted'] and r['traceFinalValueTokenID'] == g['directTargetID']
        rows.append({'model': label, 'caseID':r['caseID'], 'axis':c['axis'], 'depth':c['depth'],
           'directCorrect':r['directValueTokenID'] == g['directTargetID'],
           'traceFinalCorrect':final, 'fullTraceCorrect':full,
           'traceCompleted':r['traceCompleted'],
           'directAssignedValue':r['directValueTokenID'] in c['allowedValueSymbols'],
           'finalCorrectWithIntermediateError':final and not full,
           'directPrediction':r['directValueTokenID'], 'tracePredictions':r['traceValueTokenIDs'],
           'referenceFinal':g['directTargetID'], 'referenceTrace':g['expectedStateIDs']})
    models.append({'tag':name, 'label':label, 'aggregate':counts(rows),
       'perAxis':{a:counts([r for r in rows if r['axis']==a]) for a in sorted({r['axis'] for r in rows})},
       'perDepth':{str(d):counts([r for r in rows if r['depth']==d]) for d in (3,4)},
       'sourceSummarySHA256':hashlib.sha256(path.read_bytes()).hexdigest()})
    all_rows.extend(rows)
independent = json.loads((out/'INDEPENDENT-SCORE.json').read_text())
for ours, other in zip(models, independent['models']):
    assert ours['aggregate']['directCorrect'] == other['aggregate']['directFinalCorrect']['correct']
    assert ours['aggregate']['traceFinalCorrect'] == other['aggregate']['traceFinalCorrect']['correct']
    assert ours['aggregate']['fullTraceCorrect'] == other['aggregate']['fullTraceCorrect']['correct']
result = {'schema':'prime_llama_live_scores_v1', 'models':models, 'independentScoresAgree':True,
    'modelExecutionPerformedByScorer':False, 'caseCountPerModel':80, 'distinctSemanticPrograms':2,
    'interpretation':'Focused symbolic program diagnostic. Direct and iterative use actual model outputs; no reference repair. Final correctness can mask wrong intermediate states.',
    'mainSuite':{'nativeForwardCalls':720, 'llamaGenerationCalls':189, 'controllerPhases':20},
    'referencesSHA256':hashlib.sha256((out/'References/gold.json').read_bytes()).hexdigest()}
(out/'SCORES.json').write_text(json.dumps(result,indent=2)+'\n')
with (out/'case-results.csv').open('w',newline='') as f:
    writer=csv.DictWriter(f,fieldnames=list(all_rows[0]));writer.writeheader();writer.writerows(all_rows)
control=out/'Plain-Arithmetic-Control'
if (control/'Result/controller/result.json').exists():
    receipt=json.loads((control/'Result/controller/result.json').read_text());assert receipt['passed']
    events=[json.loads(line) for line in (control/'Result/controller/stdout.bin').read_text().splitlines()]
    assert events[-1]['type']=='complete' and events[-1]['caseCount']==16
    predictions=[e for e in events if e['type']=='prediction']
    rows=[]
    for r in [e for e in events if e['type']=='case_complete']:
        expected=[v-16 for v in gold[r['caseID']]['expectedStateIDs']]
        direct=next(e for e in predictions if e['caseID']==r['caseID'] and e['mode']=='direct')
        rows.append(dict(r,expectedStates=expected,directCorrect=r['directValueTokenID']==expected[-1],
               traceFinalCorrect=r['traceFinalValueTokenID']==expected[-1],
               fullTraceCorrect=r['traceValueTokenIDs']==expected,
               directRawOutput=direct['rawOutput'],directQuestion=direct['question']))
    report={'caseCount':16,'generationCalls':len(predictions),
            'strictSingleInteger':{k:sum(r[k] for r in rows) for k in ['directCorrect','traceFinalCorrect','fullTraceCorrect','traceCompleted']},
            'formatOrValueInvalidPredictions':sum(not e['validValueSymbol'] for e in predictions),
            'cases':rows,'modelExecutionPerformedByScorer':False,
            'interpretation':'Strict interface score: multi-line worked answers are not admitted for feedback even if their final claim is correct. Inspect raw answers and the separate descriptive audit; do not label this score as pure arithmetic accuracy.'}
    (control/'SCORES.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'models':[{**m['aggregate'],'model':m['label']} for m in models], 'independentScoresAgree':True},indent=2))
