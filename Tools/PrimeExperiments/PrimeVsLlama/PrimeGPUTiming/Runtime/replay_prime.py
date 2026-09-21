#!/usr/bin/env python3
"""Replay the bounded Prime-only GPU timing cases from the durable assessment."""
import argparse,hashlib,json,subprocess
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('destination',type=Path)
p.add_argument('--seed',choices=['1618','2718','3141','all'],default='1618')
p.add_argument('--execution',choices=['host','guest','both'],default='both')
a=p.parse_args();root=Path(__file__).resolve().parents[1]
config=json.loads((root/'REPLAY-CONFIG.json').read_bytes())
exe=Path(config['executable'])
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(exe)==config['sha256']
dest=a.destination.expanduser().resolve();assert not dest.exists(),'fresh output directory required'
dest.mkdir(parents=True)
seeds=['1618','2718','3141'] if a.seed=='all' else [a.seed]
modes=['host','guest'] if a.execution=='both' else [a.execution]
count=0
for seed in seeds:
    for mode in modes:
        phase=dest/f'seed-{seed}-{mode}';phase.mkdir();(phase/'cache').mkdir()
        request=json.loads((root/f'PrimeLive/seed-{seed}-{mode}/request.json').read_bytes())
        assert sha(Path(request['weightsPath']))==request['weightsSHA256']
        (phase/'request.json').write_text(json.dumps(request,indent=2)+'\n')
        spec={'argv':[str(exe),'--request',str(phase/'request.json'),'--output-directory',str(phase/'native')],
              'environment':{'PATH':'/usr/bin:/bin:/usr/sbin:/sbin','HOME':str(phase),'TMPDIR':str(phase/'cache'),'OMP_NUM_THREADS':'2'},'phase':phase.name,'trainingPerformed':False,'referencesProvidedToModel':False,'executableSHA256':config['sha256']}
        (phase/'specification.json').write_text(json.dumps(spec,indent=2)+'\n')
        with (phase/'outer.stdout').open('x') as out,(phase/'outer.stderr').open('x') as err:
            result=subprocess.run(['/usr/bin/ruby',str(root/'Runtime/controller.rb'),str(phase)],stdout=out,stderr=err,timeout=140)
        assert result.returncode==0 and json.loads((phase/'controller/result.json').read_bytes())['passed']
        count+=1;print(json.dumps({'completed':phase.name}),flush=True)
(dest/'COMPLETE.json').write_text(json.dumps({'processes':count,'modelForwards':count*16,'trainingPerformed':False})+'\n')
