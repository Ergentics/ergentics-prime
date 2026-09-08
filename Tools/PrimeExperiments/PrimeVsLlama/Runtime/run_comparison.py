#!/usr/bin/env python3
"""Run fixed input-only phases serially; never load scoring references."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

OUT = Path(sys.argv[1]).resolve()
CONF = json.loads((OUT/'RUN-CONFIG.json').read_text())
CASES = json.loads((OUT/'Inputs/cases.json').read_text())['cases']
BY_ID = {c['id']: c for c in CASES}
CONTROLLER = OUT/'Runtime/controller.rb'


def write(path, value):
    with path.open('x') as f:
        json.dump(value, f, indent=2)
        f.write('\n')


def environment(directory):
    cache = directory/'cache'
    cache.mkdir()
    return {'PATH':'/usr/bin:/bin:/usr/sbin:/sbin','HOME':str(directory),'TMPDIR':str(cache),
            'HF_HOME':str(cache),'HF_HUB_OFFLINE':'1','TRANSFORMERS_OFFLINE':'1',
            'HF_HUB_DISABLE_TELEMETRY':'1','TOKENIZERS_PARALLELISM':'false',
            'PYTHONDONTWRITEBYTECODE':'1','OMP_NUM_THREADS':'2'}


def phase(name, request, argv):
    directory = OUT/'Results'/name
    if directory.exists():
        assert json.loads((directory/'request.json').read_text()) == request, 'existing phase request differs'
        result = json.loads((directory/'controller/result.json').read_text())
        assert result['passed'] is True, 'existing phase did not complete; retain it and diagnose'
        return directory
    directory.mkdir()
    write(directory/'request.json',request)
    command = [s.replace('{request}',str(directory/'request.json')).replace('{native}',str(directory/'native')) for s in argv]
    write(directory/'specification.json',{'argv':command,'environment':environment(directory),
          'phase':name,'trainingPerformed':False,'referencesProvidedToModel':False})
    with (directory/'outer.stdout').open('x') as stdout, (directory/'outer.stderr').open('x') as stderr:
        completed = subprocess.run(['/usr/bin/ruby',str(CONTROLLER),str(directory)],stdout=stdout,stderr=stderr)
    result = json.loads((directory/'controller/result.json').read_text())
    assert completed.returncode == 0 and result['passed'] is True, 'phase failed: '+name
    print(json.dumps({'phase':name,'status':'completed','seconds':result['elapsed_seconds']}),flush=True)
    return directory


def native(model, name, inputs):
    request={'schema':'prime_10m_inference_request_v1','weightsPath':model['weights'],
             'weightsSHA256':model['weightsSHA256'],'cases':inputs}
    directory=phase(name,request,[model['nativeExecutable'],'--request','{request}','--output-directory','{native}'])
    result=json.loads((directory/'native/result.json').read_text())
    assert result['status']=='completed' and result['weightsBefore']['sha256']==model['weightsSHA256']
    rows=result['cases']; assert {r['id'] for r in rows}=={c['id'] for c in inputs}
    expected={c['id']:c['inputTokenIDs'] for c in inputs}
    assert all(r['inputTokenIDs']==expected[r['id']] for r in rows)
    return {r['id']:r for r in rows}


for model in CONF['models']:
    tag=Path(model['directory']).name.split('-')[0]
    destination=OUT/'Results'/f'{tag}-summary.json'
    if destination.exists():
        continue
    direct=native(model,tag+'-direct',[{'id':c['id'],'inputTokenIDs':c['directInputIDs']} for c in CASES])
    states={c['id']:[] for c in CASES}
    feedback=[]
    for stage in range(max(c['depth'] for c in CASES)):
        inputs=[]
        for c in CASES:
            if stage>=c['depth'] or len(states[c['id']])!=stage:continue
            template=c['traceStages'][stage]
            prior=states[c['id']][-1] if stage>0 else None
            if prior is not None and prior not in c['allowedValueSymbols']:continue
            assert template['requiresPriorPrediction']==(stage>0)
            ids=template['inputPrefixIDs']+([prior] if prior is not None else [])+template['inputSuffixIDs']
            inputs.append({'id':c['id'],'inputTokenIDs':ids})
            if stage>0:
                feedback.append({'id':c['id'],'stage':stage,'priorPredictionTokenID':prior,
                                 'sourcePhase':f'{tag}-trace-{stage-1}','destinationPhase':f'{tag}-trace-{stage}',
                                 'inputTokenIDs':ids,'insertionOffset':len(template['inputPrefixIDs'])})
        if not inputs:break
        predictions=native(model,f'{tag}-trace-{stage}',inputs)
        for case_id,row in predictions.items():states[case_id].append(row['predictionTokenID'])
    rows=[]
    for c in CASES:
        values=states[c['id']]
        complete=len(values)==c['depth'] and all(v in c['allowedValueSymbols'] for v in values)
        rows.append({'caseID':c['id'],'directValueTokenID':direct[c['id']]['predictionTokenID'],
                     'traceValueTokenIDs':values,'traceCompleted':complete,
                     'traceFinalValueTokenID':values[-1] if complete else None})
    write(destination,{'model':model,'cases':rows,'feedback':feedback,
                       'continuationPolicy':'Stop after an unassigned value symbol; preserve the raw prediction. Same value-domain rule as Llama.'})

llama_cases=json.loads((OUT/'Inputs/llama-cases.json').read_text())
all_llama=[]
for offset in range(0,len(llama_cases),CONF['llamaBatchSize']):
    batch=llama_cases[offset:offset+CONF['llamaBatchSize']]
    request={'schema':'prime_llama_symbol_comparison_v1','modelPath':CONF['llamaModel'],
             'maximumNewTokens':CONF['maximumNewTokens'],'cases':batch}
    directory=phase(f'llama-batch-{offset//CONF["llamaBatchSize"]:02d}',request,
                    [CONF['llamaPython'],str(OUT/'Runtime/llama_symbol_compare.py'),'--request','{request}'])
    events=[json.loads(line) for line in (directory/'controller/stdout.bin').read_text().splitlines() if line.strip()]
    assert events[-1]['type']=='complete' and events[-1]['caseCount']==len(batch)
    rows=[e for e in events if e.get('type')=='case_complete']
    assert {r['caseID'] for r in rows}=={r['id'] for r in batch}
    all_llama.extend(rows)
    predictions=[e for e in events if e.get('type')=='prediction']
    for c in batch:
        stages=[e for e in predictions if e['caseID']==c['id'] and e['mode']=='iterative']
        for before,after in zip(stages,stages[1:]):
            assert before['validValueSymbol'] and before['parsedValueTokenID']==after['priorValueTokenID']
            assert after['priorSource']=='previous_model_prediction'

destination=OUT/'Results/llama-summary.json'
if not destination.exists():write(destination,{'modelID':'older_Ergentics_Llama_3.2_3B_fine_tune','cases':all_llama})
write(OUT/'RUN-COMPLETE.json',{'status':'completed','caseCount':len(CASES),'primeCheckpoints':2,
                             'modes':['direct','iterative'],'llamaCases':len(all_llama),
                             'modelTrainingPerformed':False,'goldLoadedByOrchestrator':False})
print('COMPARISON_EXECUTION_COMPLETE',flush=True)
