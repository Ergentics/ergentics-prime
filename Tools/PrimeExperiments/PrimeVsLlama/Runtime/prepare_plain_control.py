#!/usr/bin/env python3
"""Prepare a separate language-encoding control from input metadata only."""
import ast
import hashlib
import json
from pathlib import Path
import sys

out = Path(sys.argv[1]).resolve()
control = out/'Plain-Arithmetic-Control'
control.mkdir()
runtime = control/'Runtime'
runtime.mkdir()
original = out/'Runtime/llama_symbol_compare.py'
source = original.read_text()
old = """        question = (c['questionPrefix'] + '\\nStarting value token: ' + str(prior) +
                    '. Apply these operation tokens in order: ' + ', '.join(map(str, operations)) +
                    '. Return only the final value token ID as one integer, with no explanation.')"""
new = """        words = {32: 'add 1', 33: 'subtract 1', 34: 'negate the current value'}
        question = (c['questionPrefix'] + '\\nStart with ' + str(prior) +
                    '. In order: ' + '; then '.join(words[op] for op in operations) +
                    '. Return only the final integer from 0 through 7, with no explanation.')"""
assert source.count(old) == 1
source = source.replace(old, new).replace('prime_llama_symbol_comparison_v1',
                                        'prime_llama_plain_arithmetic_control_v1')
source = source.replace("assert c['startTokenID'] in c['valueTokenIDs']",
                        "assert c['valueTokenIDs'] == list(range(8))\n        assert c['startTokenID'] in c['valueTokenIDs']")
source = source.replace("assert all(type(v) is int and 0 <= v < 16384 for v in c['operationTokenIDs'])",
                        "assert all(type(v) is int and v in (32, 33, 34) for v in c['operationTokenIDs'])")
ast.parse(source)
(runtime/'llama_plain_control.py').write_text(source)
inputs = json.loads((out/'Inputs/cases.json').read_text())['cases']
cases = []
for c in inputs:
    if c['axis'] != 'base':
        continue
    header = c['codebookHeaderIDs']
    assert header[0] == 8 and header[-1] == 11
    mapping = {header[i]: header[i+2] for i in (1, 5, 9)}
    assert c['allowedValueSymbols'] == list(range(16, 24))
    cases.append({'id': c['id'], 'questionPrefix': 'Use arithmetic modulo 8, with residues 0 through 7. Reduce after each operation.',
                  'startTokenID': c['startSurfaceSymbol'] - 16,
                  'operationTokenIDs': [mapping[op] for op in c['operationSurfaceSymbols']],
                  'valueTokenIDs': list(range(8))})
assert len(cases) == 16 and len({c['id'] for c in cases}) == 16
conf = json.loads((out/'RUN-CONFIG.json').read_text())
phase = control/'Result'
phase.mkdir()
cache = phase/'cache'
cache.mkdir()
def write(path, value):
    with path.open('x') as f:
        json.dump(value, f, indent=2)
        f.write('\n')
write(phase/'request.json', {'schema': 'prime_llama_plain_arithmetic_control_v1',
      'modelPath': conf['llamaModel'], 'maximumNewTokens': conf['maximumNewTokens'], 'cases': cases})
write(phase/'specification.json', {'argv': [conf['llamaPython'], str(runtime/'llama_plain_control.py'), '--request', str(phase/'request.json')],
      'environment': {'PATH':'/usr/bin:/bin:/usr/sbin:/sbin', 'HOME':str(phase), 'TMPDIR':str(cache),
       'HF_HOME':str(cache), 'HF_HUB_OFFLINE':'1', 'TRANSFORMERS_OFFLINE':'1', 'HF_HUB_DISABLE_TELEMETRY':'1',
       'TOKENIZERS_PARALLELISM':'false','PYTHONDONTWRITEBYTECODE':'1','OMP_NUM_THREADS':'2'},
      'phase':'llama-plain-arithmetic-control', 'trainingPerformed':False,'referencesProvidedToModel':False})
write(control/'PREPARATION.json', {'purpose': 'Separate natural-language control for the same sixteen semantic programs/starts; task-symbol codebooks removed.',
      'timing': 'Added after the fixed coded-symbol suite exposed frequent invalid symbols; not part of its 80-case score.',
      'caseCount':len(cases), 'goldReadByPreparation':False, 'inputSourceSHA256':hashlib.sha256((out/'Inputs/cases.json').read_bytes()).hexdigest(),
      'sourceRuntimeSHA256':hashlib.sha256(original.read_bytes()).hexdigest(),
      'scope': 'Only the question rendering and schema/domain validation differ from the original comparator. Same weights, original tokenizer/template, greedy decode, 512-token budget and continuation rule.',
      'fieldNaming': 'Inherited token-ID field names hold task data, not tokenizer IDs. User-facing questions contain ordinary numbers and operation words.'})
print(phase)
