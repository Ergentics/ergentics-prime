#!/usr/bin/env python3
"""Replay saved domain inputs with durable local weights into a fresh directory."""
import argparse,hashlib,json,shutil,subprocess
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('destination',type=Path);p.add_argument('--suite',choices=['comparison','generator'],default='comparison')
p.add_argument('--seed',choices=['1618','2718','3141','all'],default='1618')
p.add_argument('--execution',choices=['host','guest','both'],default='guest');a=p.parse_args()
here=Path(__file__).resolve().parent;root=here if (here/'Comparison').exists() else here.parent
config=json.loads((root/'REPLAY-CONFIG.json').read_bytes());exe=Path(config['nativeExecutable'])
assert exe.is_file() and hashlib.sha256(exe.read_bytes()).hexdigest()==config['nativeSHA256']
dest=a.destination.expanduser().resolve();assert not dest.exists(),'fresh destination required'
seeds=['1618','2718','3141'] if a.seed=='all' else [a.seed]
modes=['host','guest'] if a.execution=='both' else [a.execution]
suite=root/('Comparison' if a.suite=='comparison' else 'Generator')
requests=[x for seed in seeds for mode in modes for x in sorted((suite/f'Requests/seed-{seed}'/mode).glob('batch-*.json'))]
assert requests and all(x.is_file() for x in requests)
dest.mkdir(parents=True);processes=0
for source in requests:
 req=json.loads(source.read_bytes());seed=source.parts[-3].removeprefix('seed-');model=Path(config['weights'][seed])
 assert model.is_file() and hashlib.sha256(model.read_bytes()).hexdigest()==req['weightsSHA256']
 req['weightsPath']=str(model)
 phase=dest/('-'.join(source.parts[-3:]).removesuffix('.json'));phase.mkdir();(phase/'cache').mkdir()
 (phase/'request.json').write_text(json.dumps(req,indent=2)+'\n')
 spec={'argv':[str(exe),'--request',str(phase/'request.json'),'--output-directory',str(phase/'native')],
       'environment':{'PATH':'/usr/bin:/bin:/usr/sbin:/sbin','HOME':str(phase),'TMPDIR':str(phase/'cache'),'OMP_NUM_THREADS':'2'},
       'phase':phase.name,'trainingPerformed':False,'referencesProvidedToModel':False,
       'originalInputRequestSHA256':hashlib.sha256(source.read_bytes()).hexdigest()}
 (phase/'specification.json').write_text(json.dumps(spec,indent=2)+'\n')
 with (phase/'outer.stdout').open('x') as o,(phase/'outer.stderr').open('x') as e:
  r=subprocess.run(['/usr/bin/ruby',config['controller'],str(phase)],stdout=o,stderr=e,timeout=140)
 receipt=json.loads((phase/'controller/result.json').read_bytes());assert r.returncode==0 and receipt['passed'],str(phase)
 processes+=1;print(json.dumps({'completed':phase.name}),flush=True)
(dest/'REPLAY-COMPLETE.json').write_text(json.dumps({'processes':processes,'suite':a.suite,'seed':a.seed,'execution':a.execution,'trainingPerformed':False},indent=2)+'\n')
