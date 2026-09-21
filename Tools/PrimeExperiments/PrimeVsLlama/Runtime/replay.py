#!/usr/bin/env python3
"""Run the fixed comparison again in a fresh directory, using saved model bytes."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('destination',type=Path)
args=parser.parse_args()
source=Path(__file__).resolve().parents[1]
destination=args.destination.expanduser().resolve()
if destination.exists():
    parser.error('destination must be a new directory; existing results are preserved')
conf=json.loads((source/'RUN-CONFIG.json').read_text())
for required in [conf['llamaPython'],conf['llamaModel']]+[m['nativeExecutable'] for m in conf['models']]+[m['weights'] for m in conf['models']]:
    if not Path(required).exists():
        parser.error('saved runtime or weights missing: '+required)
destination.mkdir(parents=True)
for name in ['Inputs','Runtime']:
    shutil.copytree(source/name,destination/name)
(destination/'Results').mkdir()
conf['output']=str(destination)
conf['caseFile']=str(destination/'Inputs/cases.json')
(destination/'RUN-CONFIG.json').write_text(json.dumps(conf,indent=2)+'\n')
print('Running offline with saved weights; results: '+str(destination),flush=True)
subprocess.run([sys.executable,str(destination/'Runtime/run_comparison.py'),str(destination)],check=True)
