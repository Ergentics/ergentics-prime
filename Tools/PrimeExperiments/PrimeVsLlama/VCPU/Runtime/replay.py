#!/usr/bin/env python3
"""Replay the saved real vCPU suite into a fresh directory."""
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
if destination.exists():parser.error('destination already exists; preserve previous results')
conf=json.loads((source/'RUN-CONFIG.json').read_text())
if not Path(conf['nativeExecutable']).is_file():parser.error('saved signed native executable missing')
for path in (source/'Requests').glob('*/*.json'):
    request=json.loads(path.read_text())
    if not Path(request['weightsPath']).is_file():parser.error('retained checkpoint missing: '+request['weightsPath'])
destination.mkdir(parents=True)
for name in ['Requests','Runtime']:
    shutil.copytree(source/name,destination/name)
(destination/'Results').mkdir()
shutil.copy2(source/'RUN-CONFIG.json',destination/'RUN-CONFIG.json')
subprocess.run([sys.executable,str(destination/'Runtime/run_guest_comparison.py'),str(destination)],check=True)
