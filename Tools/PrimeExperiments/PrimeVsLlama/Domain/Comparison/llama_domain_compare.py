#!/usr/bin/env python3
"""Raw retained Llama inference on input-only domain rules; no target imports."""
import argparse, hashlib, json, re, time
from pathlib import Path

def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return h.hexdigest()
def emit(x):print(json.dumps(x,ensure_ascii=False),flush=True)
def main():
 a=argparse.ArgumentParser();a.add_argument('--request',type=Path,required=True);args=a.parse_args()
 assert args.request.is_absolute() and args.request.stat().st_size<131072
 r=json.loads(args.request.read_bytes());assert set(r)=={'schema','modelPath','maximumNewTokens','cases'}
 assert r['schema']=='prime_llama_domain_comparison_v1' and r['maximumNewTokens']==512 and len(r['cases'])==1
 modelpath=Path(r['modelPath']);assert modelpath.is_absolute()
 paths=sorted(p for p in modelpath.iterdir() if p.is_file())
 before={p.name:{'bytes':p.stat().st_size,'sha256':sha(p)} for p in paths}
 assert before['model.safetensors']['sha256']=='c9661f6b390552c011bf0e827d61b0339bc3030c6ffbc78afc68d31ecfbdb42c'
 import mlx.core as mx
 from mlx_lm import load,stream_generate
 from mlx_lm.sample_utils import make_sampler
 mx.random.seed(0);model,tokenizer=load(str(modelpath));model.eval()
 assert tokenizer.chat_template is not None
 limit=json.loads((modelpath/'config.json').read_bytes())['max_position_embeddings']
 emit({'type':'loaded','modelID':'older_Ergentics_Llama_3.2_3B_fine_tune','modelFiles':before,'requestSHA256':sha(args.request),'trainingPerformed':False,'goldTargetsProvided':False})
 def predict(c,job,question,source):
  assert isinstance(question,str) and len(question.encode())<=16384
  prompt=tokenizer.apply_chat_template([{'role':'user','content':question}],tokenize=False,add_generation_prompt=True)
  ids=tokenizer.encode(prompt,add_special_tokens=tokenizer.bos_token is None or not prompt.startswith(tokenizer.bos_token))
  assert len(ids)+512<=limit
  start=time.monotonic();tokens=[];pieces=[];finish=None;deadline=False
  for v in stream_generate(model,tokenizer,ids,max_tokens=512,sampler=make_sampler(temp=0)):
   tokens.append(v.token);pieces.append(v.text);finish=v.finish_reason
   if time.monotonic()-start>20:deadline=True;break
  text=''.join(pieces);match=re.fullmatch(r'\s*([0-9]{1,5})\s*',text)
  value=int(match[1]) if match else None
  valid=value is not None and 0<=value<16384 and not deadline
  emit({'type':'prediction','caseID':c['id'],'jobIndex':job,'question':question,'questionSHA256':hashlib.sha256(question.encode()).hexdigest(),
        'effectivePromptSHA256':hashlib.sha256(prompt.encode()).hexdigest(),'inputTokenIDs':ids,'generatedTokenIDs':tokens,
        'rawOutput':text,'parsedSymbolID':value,'validVocabularySymbol':valid,'feedbackSources':source,'maximumNewTokens':512,
        'stopReason':'deadline' if deadline else 'endOfSequence' if finish=='stop' else 'tokenLimit',
        'elapsedSeconds':time.monotonic()-start,'outputRewritten':False})
  return value if valid else None
 for c in r['cases']:
  direct=predict(c,0,c['directQuestion'],[])
  left=predict(c,1,c['leftQuestion'],[]);right=predict(c,2,c['rightQuestion'],[])
  final=None
  if left is not None and right is not None:
   q=c['finalQuestionTemplate'].replace('{left_summary_symbol}',str(left)).replace('{right_summary_symbol}',str(right))
   final=predict(c,3,q,[{'jobIndex':1,'predictedSymbolID':left},{'jobIndex':2,'predictedSymbolID':right}])
  emit({'type':'case_complete','caseID':c['id'],'directSymbolID':direct,'leftSymbolID':left,'rightSymbolID':right,
        'finalSymbolID':final,'traceCompleted':final is not None,'continuationStopped':left is None or right is None})
 after={p.name:{'bytes':p.stat().st_size,'sha256':sha(p)} for p in paths};assert before==after
 emit({'type':'complete','caseCount':1,'modelUnchanged':True,'trainingPerformed':False,'goldTargetsProvided':False})
if __name__=='__main__':main()
