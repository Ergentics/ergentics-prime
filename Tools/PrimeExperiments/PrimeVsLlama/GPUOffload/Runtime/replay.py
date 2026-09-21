#!/usr/bin/env python3
"""Run the saved bounded GPU-offload diagnostic into a fresh directory."""
import argparse,json,hashlib,subprocess
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('destination',type=Path);a=p.parse_args()
root=Path(__file__).resolve().parents[1];cfg=json.loads((root/'REPLAY-CONFIG.json').read_bytes())
exe=Path(cfg['executable']);assert hashlib.sha256(exe.read_bytes()).hexdigest()==cfg['sha256']
out=a.destination.expanduser().resolve();assert not out.exists();out.mkdir(parents=True);(out/'cache').mkdir()
s={'argv':[str(exe),'--output-directory',str(out/'native')],'environment':{'PATH':'/usr/bin:/bin:/usr/sbin:/sbin','HOME':str(out),'TMPDIR':str(out/'cache')},'phase':'replay-typed-guest-gpu','trainingPerformed':False,'learnedModelInvoked':False}
(out/'specification.json').write_text(json.dumps(s,indent=2)+'\n')
r=subprocess.run(['/usr/bin/ruby',str(root/'Runtime/controller.rb'),str(out)],timeout=140)
assert r.returncode==0 and json.loads((out/'controller/result.json').read_bytes())['passed']
