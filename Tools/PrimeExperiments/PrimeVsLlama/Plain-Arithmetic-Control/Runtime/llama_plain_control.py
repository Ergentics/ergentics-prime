#!/usr/bin/env python3
"""Inference-only direct and iterative evaluation of retained symbolic programs."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import time


def emit(value):
    print(json.dumps(value, ensure_ascii=False), flush=True)


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def unique(pairs):
    result = {}
    for k, v in pairs:
        if k in result:
            raise ValueError('duplicate JSON field: ' + k)
        result[k] = v
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--request', type=Path, required=True)
    args = parser.parse_args()
    assert args.request.is_absolute() and args.request.stat().st_size < 1024 * 1024
    request = json.loads(args.request.read_text(), object_pairs_hook=unique)
    assert set(request) == {'schema', 'modelPath', 'maximumNewTokens', 'cases'}
    assert request['schema'] == 'prime_llama_plain_arithmetic_control_v1'
    maximum = request['maximumNewTokens']
    assert type(maximum) is int and 1 <= maximum <= 512
    cases = request['cases']
    assert isinstance(cases, list) and 1 <= len(cases) <= 16
    assert len({c['id'] for c in cases}) == len(cases)
    for c in cases:
        assert set(c) == {'id', 'questionPrefix', 'startTokenID', 'operationTokenIDs', 'valueTokenIDs'}
        assert isinstance(c['id'], str) and 1 <= len(c['id']) <= 200
        assert isinstance(c['questionPrefix'], str) and 1 <= len(c['questionPrefix'].encode()) <= 8192
        assert type(c['startTokenID']) is int
        assert isinstance(c['valueTokenIDs'], list) and len(c['valueTokenIDs']) == 8
        assert all(type(v) is int and 0 <= v < 16384 for v in c['valueTokenIDs'])
        assert c['valueTokenIDs'] == list(range(8))
        assert c['startTokenID'] in c['valueTokenIDs']
        assert isinstance(c['operationTokenIDs'], list) and 1 <= len(c['operationTokenIDs']) <= 8
        assert all(type(v) is int and v in (32, 33, 34) for v in c['operationTokenIDs'])
    model_path = Path(request['modelPath'])
    assert model_path.is_absolute() and model_path.is_dir()
    paths = sorted(p for p in model_path.iterdir() if p.is_file())
    before = {p.name: {'bytes': p.stat().st_size, 'sha256': digest(p)} for p in paths}
    assert before['model.safetensors']['sha256'] == 'c9661f6b390552c011bf0e827d61b0339bc3030c6ffbc78afc68d31ecfbdb42c'
    import mlx.core as mx
    from mlx_lm import load, stream_generate
    from mlx_lm.sample_utils import make_sampler
    mx.random.seed(0)
    model, tokenizer = load(str(model_path))
    assert tokenizer.chat_template is not None
    max_context = json.loads((model_path/'config.json').read_text())['max_position_embeddings']
    emit({'type': 'loaded', 'modelID': 'older_Ergentics_Llama_3.2_3B_fine_tune',
          'weightsSHA256': before['model.safetensors']['sha256'],
          'requestSHA256': digest(args.request), 'modelFiles': before,
          'trainingPerformed': False, 'goldTargetsProvided': False})

    def predict(c, mode, stage, prior, operations):
        words = {32: 'add 1', 33: 'subtract 1', 34: 'negate the current value'}
        question = (c['questionPrefix'] + '\nStart with ' + str(prior) +
                    '. In order: ' + '; then '.join(words[op] for op in operations) +
                    '. Return only the final integer from 0 through 7, with no explanation.')
        prompt = tokenizer.apply_chat_template([{'role': 'user', 'content': question}],
                                               tokenize=False, add_generation_prompt=True)
        add_special = tokenizer.bos_token is None or not prompt.startswith(tokenizer.bos_token)
        input_ids = tokenizer.encode(prompt, add_special_tokens=add_special)
        assert len(input_ids) + maximum <= max_context
        started = time.monotonic()
        token_ids, pieces = [], []
        finish = None
        deadline = False
        for response in stream_generate(model, tokenizer, input_ids, max_tokens=maximum,
                                        sampler=make_sampler(temp=0)):
            token_ids.append(response.token)
            pieces.append(response.text)
            finish = response.finish_reason
            if time.monotonic() - started > 20:
                deadline = True
                break
        rendered = ''.join(pieces)
        match = re.fullmatch(r'\s*([0-9]{1,5})\s*', rendered)
        value = int(match.group(1)) if match else None
        admitted = value in c['valueTokenIDs'] if value is not None else False
        result = {'type': 'prediction', 'caseID': c['id'], 'mode': mode, 'stage': stage,
                  'question': question, 'questionSHA256': hashlib.sha256(question.encode()).hexdigest(),
                  'effectivePromptSHA256': hashlib.sha256(prompt.encode()).hexdigest(),
                  'inputTokenIDs': input_ids, 'generatedTokenIDs': token_ids,
                  'rawOutput': rendered, 'parsedValueTokenID': value,
                  'validValueSymbol': admitted, 'priorValueTokenID': prior,
                  'operationTokenIDs': operations, 'maximumNewTokens': maximum,
                  'stopReason': 'deadline' if deadline else ('endOfSequence' if finish == 'stop' else 'tokenLimit'),
                  'elapsedSeconds': time.monotonic()-started,
                  'predictionEligibleForContinuation': (mode == 'iterative' and admitted and not deadline
                                                        and stage + 1 < len(c['operationTokenIDs'])),
                  'priorSource': ('previous_model_prediction' if mode == 'iterative' and stage > 0
                                  else 'case_start'),
                  'outputRewritten': False}
        emit(result)
        return value if admitted and not deadline else None

    completed = []
    for c in cases:
        direct = predict(c, 'direct', None, c['startTokenID'], c['operationTokenIDs'])
        prior = c['startTokenID']
        states = []
        for stage, op in enumerate(c['operationTokenIDs']):
            value = predict(c, 'iterative', stage, prior, [op])
            if value is None:
                break
            states.append(value)
            prior = value
        complete = len(states) == len(c['operationTokenIDs'])
        row = {'type': 'case_complete', 'caseID': c['id'], 'directValueTokenID': direct,
               'traceValueTokenIDs': states, 'traceCompleted': complete,
               'traceFinalValueTokenID': states[-1] if complete else None}
        completed.append(row)
        emit(row)
    after = {p.name: {'bytes': p.stat().st_size, 'sha256': digest(p)} for p in paths}
    assert before == after, 'model or tokenizer changed during inference'
    emit({'type': 'complete', 'caseCount': len(completed), 'modelUnchanged': True,
          'trainingPerformed': False, 'goldTargetsProvided': False})


if __name__ == '__main__':
    main()
