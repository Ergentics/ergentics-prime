#!/usr/bin/env python3
"""Serial offline generation; copies only questions into each model request."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--build-root', type=Path, required=True)
parser.add_argument('--questions', type=Path, required=True)
args = parser.parse_args()
root = args.build_root.resolve(strict=True)
cases = json.loads(args.questions.read_text())['cases']
assert cases and len({c['caseID'] for c in cases}) == len(cases)
for case in cases:
    assert set(case) == {'caseID', 'question', 'questionSHA256'}
    assert hashlib.sha256(case['question'].encode()).hexdigest() == case['questionSHA256']
    assert case['caseID'] and all(ch.isalnum() or ch == '-' for ch in case['caseID'])
for case in cases:
    for name in ['0001-pmhnp-native', '0002-older-llama', '0003-native-llm-english', '0004-native-llm-latin']:
        build = root / name
        output = build / 'Results' / ('expanded-' + case['caseID'])
        launcher = build / 'Revisions/expanded-01/run.rb'
        result = subprocess.run(['/usr/bin/ruby', str(launcher), '--prompt', case['question'],
                                 '--output', str(output)], capture_output=True, text=True)
        (output / 'launcher.stdout.txt').write_text(result.stdout)
        (output / 'launcher.stderr.txt').write_text(result.stderr)
        if result.returncode == 0:
            records = [json.loads(line) for line in (output / 'controller/stdout.bin').read_text().splitlines()]
            final = [r for r in records if r.get('type') == 'result']
            assert len(final) == 1 and final[0]['questionSHA256'] == case['questionSHA256']
            generation = final[0]
            (output / 'generation.json').write_text(json.dumps(generation, indent=2) + '\n')
            print(json.dumps({'build': name, 'case': case['caseID'], 'exit': 0,
                'tokens': len(generation['generatedTokenIDs']), 'stop': generation['stopReason']}), flush=True)
        else:
            print(json.dumps({'build': name, 'case': case['caseID'], 'exit': result.returncode}), flush=True)
            raise SystemExit(result.returncode)
