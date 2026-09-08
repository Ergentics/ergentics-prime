#!/usr/bin/env python3
"""Serial real vCPU/Swift inference; no scoring references are read here."""
import json
from pathlib import Path
import subprocess
import sys

out=Path(sys.argv[1]).resolve()
config=json.loads((out/'RUN-CONFIG.json').read_text())
def write(p,value):
    with p.open('x') as f:
        json.dump(value,f,indent=2);f.write('\n')
counts={'models':0,'cases':0,'nativeModelForwards':0,'guestVMInstances':0,'controllerProcesses':0,
        'guestRunEntries':0,'guestCommittedPredictions':0}
for model in ['0006','0007']:
    counts['models']+=1
    for request_path in sorted((out/'Requests'/model).glob('batch-*.json')):
        name=model+'-'+request_path.stem
        request=json.loads(request_path.read_text())
        phase=out/'Results'/name
        assert not phase.exists(),'refuse overwriting earlier result phase'
        phase.mkdir();cache=phase/'cache';cache.mkdir()
        write(phase/'request.json',request)
        write(phase/'specification.json',{'argv':[config['nativeExecutable'],'--request',str(phase/'request.json'),
             '--output-directory',str(phase/'native')],
             'environment':{'PATH':'/usr/bin:/bin:/usr/sbin:/sbin','HOME':str(phase),'TMPDIR':str(cache),
                            'OMP_NUM_THREADS':'2','HF_HUB_OFFLINE':'1','TRANSFORMERS_OFFLINE':'1'},
             'phase':name,'referencesProvidedToModel':False,'trainingPerformed':False})
        with (phase/'outer.stdout').open('x') as stdout,(phase/'outer.stderr').open('x') as stderr:
            process=subprocess.run(['/usr/bin/ruby',str(out/'Runtime/controller.rb'),str(phase)],stdout=stdout,stderr=stderr)
        receipt=json.loads((phase/'controller/result.json').read_text())
        assert process.returncode==0 and receipt['passed'],name+' process failed; retained'
        result=json.loads((phase/'native/result.json').read_text())
        assert result['status']=='completed' and result['weightsBefore']['sha256']==request['weightsSHA256']
        assert result['weightsBefore']==result['weightsAfter']
        assert [c['id'] for c in result['cases']]==[c['id'] for c in request['cases']]
        counts['cases']+=len(result['cases']);counts['controllerProcesses']+=1
        for case in result['cases']:
            observed=case['guest']['observations']
            counts['nativeModelForwards']+=len(case['predictions'])
            counts['guestVMInstances']+=observed['vmCreateStatus']==0
            counts['guestRunEntries']+=observed['runCount']
            counts['guestCommittedPredictions']+=observed['completedCount']
        print(json.dumps({'phase':name,'status':'completed','cases':len(result['cases']),
                          'seconds':receipt['elapsed_seconds']}),flush=True)
write(out/'RUN-COMPLETE.json',{'status':'completed','actualCounts':counts,'modelTrainingPerformed':False,
      'modelWeightsInGuest':False,'execution':'guest_controls_requests_and_feedback;host_Swift_Metal_inference'})
