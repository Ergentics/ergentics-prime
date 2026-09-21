#!/usr/bin/env python3
"""Original saved Llama weights/tokenizer and chat template, with explicit token/stop records."""
import argparse
import hashlib
import json
from pathlib import Path
import time
import mlx.core as mx
from mlx_lm import load, stream_generate
from mlx_lm.sample_utils import make_sampler

parser = argparse.ArgumentParser()
parser.add_argument('--request', type=Path, required=True)
args = parser.parse_args()
request = json.loads(args.request.read_text())
assert set(request) == {'profile', 'question', 'maximumNewTokens'}
assert request['profile'] == 'older_llama'
question = request['question']
maximum = request['maximumNewTokens']
assert isinstance(question, str) and 1 <= len(question.encode()) <= 4096 and '\0' not in question
assert type(maximum) is int and 1 <= maximum <= 512
model_path = Path(__file__).resolve().parents[3] / 'Runtime/model'
files = sorted(p for p in model_path.iterdir() if p.is_file())

def bindings():
    result = []
    for path in files:
        digest = hashlib.sha256()
        with path.open('rb') as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b''):
                digest.update(chunk)
        result.append({'path': path.name, 'byteCount': path.stat().st_size, 'sha256': digest.hexdigest()})
    return result

before = bindings()
weights = next(item for item in before if item['path'] == 'model.safetensors')
assert weights['sha256'] == 'c9661f6b390552c011bf0e827d61b0339bc3030c6ffbc78afc68d31ecfbdb42c'
mx.random.seed(0)
model, tokenizer = load(str(model_path))
assert tokenizer.chat_template is not None
prompt = tokenizer.apply_chat_template([{'role': 'user', 'content': question}],
                                      tokenize=False, add_generation_prompt=True)
add_special = tokenizer.bos_token is None or not prompt.startswith(tokenizer.bos_token)
ids = tokenizer.encode(prompt, add_special_tokens=add_special)
assert len(ids) + maximum <= json.loads((model_path / 'config.json').read_text())['max_position_embeddings']
tokens, segments = [], []
started = time.monotonic()
finish = None
for response in stream_generate(model, tokenizer, ids, max_tokens=maximum, sampler=make_sampler(temp=0)):
    tokens.append(response.token)
    segments.append(response.text)
    print(json.dumps({'type': 'token', 'ordinal': len(tokens)-1, 'tokenID': response.token,
                      'textSegment': response.text, 'finishReason': response.finish_reason}), flush=True)
    finish = response.finish_reason
assert finish in ('stop', 'length')
assert bindings() == before, 'model/tokenizer changed during inference'
print(json.dumps({'type': 'result', 'schema': 'prime_llama_checkpoint_comparison_v2',
    'profile': 'older_llama', 'questionSHA256': hashlib.sha256(question.encode()).hexdigest(),
    'effectivePromptSHA256': hashlib.sha256(prompt.encode()).hexdigest(),
    'inputTransform': 'original_saved_chat_template_single_user_add_generation_prompt',
    'promptTokenIDs': ids, 'generatedTokenIDs': tokens, 'renderedOutput': ''.join(segments),
    'stopReason': 'endOfSequence' if finish == 'stop' else 'tokenLimit',
    'requestedMaximumNewTokens': maximum, 'maximumNewTokens': maximum,
    'elapsedGenerationSeconds': time.monotonic()-started, 'modelFiles': before,
    'eosTokenIDs': sorted(tokenizer.eos_token_ids), 'inputTruncated': False,
    'trainingPerformed': False, 'referenceAnswersProvidedToModel': False}), flush=True)
