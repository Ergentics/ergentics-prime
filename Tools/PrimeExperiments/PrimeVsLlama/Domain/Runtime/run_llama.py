#!/usr/bin/env python3
import json,subprocess
from pathlib import Path
w=Path(__file__).resolve().parent;c=w/'Comparison';out=c/'Llama';collection=w.parent.parent/'outputs/Prime-Experiment-Builds'
def write(p,x):
 with p.open('x') as f:json.dump(x,f,indent=2);f.write('\n')
cases=json.loads((out/'Inputs/cases.json').read_bytes())['cases']
for i,case in enumerate(cases):
 phase=out/'Results'/f'case-{i:03d}'
 assert not phase.exists();phase.mkdir(parents=True);(phase/'cache').mkdir()
 write(phase/'request.json',{'schema':'prime_llama_domain_comparison_v1','modelPath':str(collection/'0002-older-llama/Runtime/model'),'maximumNewTokens':512,'cases':[case]})
 write(phase/'specification.json',{'argv':[str(collection/'SharedRuntime/python/bin/python3'),str(c/'llama_domain_compare.py'),'--request',str(phase/'request.json')],
       'environment':{'PATH':'/usr/bin:/bin:/usr/sbin:/sbin','HOME':str(phase),'TMPDIR':str(phase/'cache'),'OMP_NUM_THREADS':'2','HF_HUB_OFFLINE':'1','TRANSFORMERS_OFFLINE':'1','PYTHONDONTWRITEBYTECODE':'1'},
       'phase':f'llama-domain-{i:03d}','referencesProvidedToModel':False,'trainingPerformed':False})
 with (phase/'outer.stdout').open('x') as outlog,(phase/'outer.stderr').open('x') as err:
  proc=subprocess.run(['/usr/bin/ruby',str(collection/'Prime-vCPU-02/Runtime/controller.rb'),str(phase)],stdout=outlog,stderr=err,timeout=140)
 receipt=json.loads((phase/'controller/result.json').read_bytes());assert proc.returncode==0 and receipt['passed'],str(phase)
 print(json.dumps({'phase':i,'seconds':receipt['elapsed_seconds'],'status':'completed'}),flush=True)
write(out/'COMPLETE.json',{'caseCount':len(cases),'status':'completed'})
