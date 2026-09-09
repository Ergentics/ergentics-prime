#!/usr/bin/env python3
"""Serial bounded CPU/Metal/VM checks, no model substitution."""
import json,subprocess,sys
from pathlib import Path
w=Path(__file__).resolve().parent;collection=w.parent.parent/'outputs/Prime-Experiment-Builds'
which=sys.argv[1];assert which in ('mechanism','geometry','python-parity')
if which=='mechanism':
 phases=[(w/'Checks/Live',[str(w/'Checks/build01/PrimeGuestABITwoChecks')])]
elif which=='geometry':
 p=w/'GeometryMetal/Live';phases=[(p,[str(w/'GeometryMetal/build01/GeometryMetalComparison'),'--output-directory',str(p/'native')])]
else:
 phases=[]
 for seed in (1618,2718,3141):
  p=w/f'Comparison/PythonParity/Live-seed-{seed}'
  phases.append((p,[str(collection/'SharedRuntime/python/bin/python3'),'-B',str(w/'Comparison/PythonParity/infer.py'),'--seed',str(seed),'--output',str(p/'native')]))
for phase,argv in phases:
 phase.mkdir();(phase/'cache').mkdir()
 spec={'argv':argv,'environment':{'PATH':'/usr/bin:/bin:/usr/sbin:/sbin','HOME':str(phase),'TMPDIR':str(phase/'cache'),'OMP_NUM_THREADS':'2','HF_HUB_OFFLINE':'1','TRANSFORMERS_OFFLINE':'1','PYTHONDONTWRITEBYTECODE':'1'},'phase':which,'trainingPerformed':False}
 (phase/'specification.json').write_text(json.dumps(spec,indent=2)+'\n')
 with (phase/'outer.stdout').open('x') as o,(phase/'outer.stderr').open('x') as e:
  r=subprocess.run(['/usr/bin/ruby',str(collection/'Prime-vCPU-02/Runtime/controller.rb'),str(phase)],stdout=o,stderr=e,timeout=140)
 receipt=json.loads((phase/'controller/result.json').read_bytes());assert r.returncode==0 and receipt['passed'],str(phase)
 print(json.dumps({'phase':which,'status':'completed','seconds':receipt['elapsed_seconds']}))
