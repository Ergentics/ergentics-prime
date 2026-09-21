#!/usr/bin/env python3
"""Serial bounded inference, references are never loaded here. Resume only verified complete phases."""
import json, subprocess, sys, hashlib
from pathlib import Path
w=Path(__file__).resolve().parent
c=w/('Generator' if '--generator' in sys.argv else 'Comparison')
controller=w.parent.parent/'outputs/Prime-Experiment-Builds/Prime-vCPU-02/Runtime/controller.rb'
exe=w/'Native/build01/PrimeVCPUInference'
def write(p,x):
    with p.open('x') as f: json.dump(x,f,indent=2);f.write('\n')
requests=sorted((c/'Requests').glob('seed-*/*/batch-*.json'))
if '--pilot' in sys.argv: requests=[p for p in requests if p.name=='batch-000.json']
counts={'cases':0,'forwards':0,'guestVMs':0,'guestEntries':0,'processes':0}
for p in requests:
    name='-'.join(p.parts[-3:]).removesuffix('.json')
    phase=c/'Results'/name
    request=json.loads(p.read_bytes())
    if not phase.exists():
        phase.mkdir(parents=True); (phase/'cache').mkdir()
        write(phase/'request.json',request)
        write(phase/'specification.json',{'argv':[str(exe),'--request',str(phase/'request.json'),'--output-directory',str(phase/'native')],
              'environment':{'PATH':'/usr/bin:/bin:/usr/sbin:/sbin','HOME':str(phase),'TMPDIR':str(phase/'cache'),'OMP_NUM_THREADS':'2','HF_HUB_OFFLINE':'1','TRANSFORMERS_OFFLINE':'1'},
              'phase':name,'referencesProvidedToModel':False,'trainingPerformed':False})
        with (phase/'outer.stdout').open('x') as out,(phase/'outer.stderr').open('x') as err:
            proc=subprocess.run(['/usr/bin/ruby',str(controller),str(phase)],stdout=out,stderr=err,timeout=140)
        assert proc.returncode==0, name+' failed; retain phase'
    receipt=json.loads((phase/'controller/result.json').read_bytes())
    r=json.loads((phase/'native/result.json').read_bytes())
    assert receipt['passed'] and r['status']=='completed'
    assert json.loads((phase/'request.json').read_bytes())==request
    assert r['requestSHA256']==hashlib.sha256((phase/'request.json').read_bytes()).hexdigest()
    assert r['weightsBefore']==r['weightsAfter'] and r['weightsBefore']['sha256']==request['weightsSHA256']
    assert r['execution']==request['execution'] and [x['id'] for x in r['cases']]==[x['id'] for x in request['cases']]
    for case in r['cases']:
        assert case['status']=='completed' and len(case['predictions'])==4
        counts['cases']+=1;counts['forwards']+=4
        if request['execution']=='guest':
            o=case['guest']['observations'];assert o['cleanupComplete']==1 and o['status']==0 and o['callbackCount']==4
            counts['guestVMs']+=o['vmCreateStatus']==0;counts['guestEntries']+=o['runCount']
        else: assert 'guest' not in case
    counts['processes']+=1
    print(json.dumps({'phase':name,'seconds':receipt['elapsed_seconds'],'status':'completed'}),flush=True)
write(c/('PILOT-COMPLETE.json' if '--pilot' in sys.argv else 'NATIVE-COMPLETE.json'),{'status':'completed','actualCounts':counts})
