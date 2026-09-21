#!/usr/bin/env python3
"""Inference only for saved Prime Z/8Z trace weights, using the original token schema."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import signal
import struct
import time

RUNTIME_ROOT = Path(__file__).resolve().parent
WEIGHTS = RUNTIME_ROOT / 'model' / 'weights.safetensors'
WEIGHTS_SHA256 = 'fd313073fce8d3b1dc2b306f43457689aa5521c7d4a456e16da270ef30d127ee'
REPORT = RUNTIME_ROOT / 'model' / 'training-report.json'
EXPECTED_PARAMETERS = 10227968
SYMBOLS = {1:'BOS',2:'APPLY',3:'ANSWER',4:'CONTEXT',5:'TRACE',6:'THEN',7:'RESUME',32:'INCREMENT',33:'DECREMENT',34:'NEGATE'}
SYMBOLS.update({16+n:'VALUE_'+str(n) for n in range(8)})

def sha256(path):
 h=hashlib.sha256()
 with path.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''): h.update(b)
 return h.hexdigest()

def require(condition, reason):
 if not condition:raise ValueError(reason)

def unique_object(pairs):
 result={}
 for k,v in pairs:
  require(k not in result,'duplicate JSON key');result[k]=v
 return result

def decode_request(path):
 require(path.is_absolute() and path.resolve()==path and path.is_file(),'request must be an absolute regular file without symlinks')
 require(path.stat().st_size<=16384,'request exceeds 16 KiB')
 data=json.loads(path.read_text(),object_pairs_hook=unique_object)
 require(isinstance(data,dict),'request must be an object')
 require(set(data)=={'schema','start','operations','context'},'request keys must be exactly schema, start, operations, context; text or targets are not accepted')
 require(data['schema']=='prime_z8_trace_request_v1','request schema mismatch')
 require(type(data['start']) is int and 0<=data['start']<8,'start must be an original Z/8Z value')
 require(isinstance(data['operations'],list) and len(data['operations'])==2 and all(type(n) is int and n in (32,33,34) for n in data['operations']),'exactly two original operation IDs are required')
 require(type(data['context']) is bool,'context must be boolean')
 return data

def prefixes(request):
 context=[4] if request['context'] else []
 return ([1]+context+[5,16+request['start'],request['operations'][0],6], [1]+context+[7], [request['operations'][1],3])

def main():
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('--request',type=Path,required=True)
 parser.add_argument('--output',type=Path,required=True)
 parser.add_argument('--validate-only',action='store_true',help='Check original input schema and saved artifacts without importing MLX or invoking a model')
 args=parser.parse_args()
 request=decode_request(args.request)
 require(args.output.is_absolute() and args.output.parent.resolve()==args.output.parent,'output must have an existing absolute canonical parent')
 require(not args.output.exists(),'output already exists')
 signal.alarm(45)
 report=json.loads(REPORT.read_text())
 require(report['durability']['checkpoint_sha256']==WEIGHTS_SHA256,'historical report checkpoint binding differs')
 require(sha256(WEIGHTS)==WEIGHTS_SHA256,'saved checkpoint hash differs')
 with WEIGHTS.open('rb') as f:
  header_size=struct.unpack('<Q',f.read(8))[0]
  require(header_size<=16777216,'invalid safetensors header')
  header=json.loads(f.read(header_size))
 tensors={k:v for k,v in header.items() if k!='__metadata__'}
 require(len(tensors)==74 and all(v['dtype']=='F32' for v in tensors.values()) and sum(math.prod(v['shape']) for v in tensors.values())==EXPECTED_PARAMETERS,'checkpoint header differs from original trace profile')
 intermediate_input,final_prefix,final_suffix=prefixes(request)
 result={'schema':'prime_z8_trace_inference_result_v1','status':'validated_native_input' if args.validate_only else 'generated_native_symbols','modelID':'ergentics_prime_poc_10m_v1','languageID':'ergentics_prime_z8_trace_v1','weightsPath':str(WEIGHTS),'weightsSHA256':WEIGHTS_SHA256,'originalReportPath':str(REPORT),'originalReportSHA256':sha256(REPORT),'request':request,'requestSHA256':sha256(args.request),'vocabularySize':16384,'textCodecAvailable':False,'trainingPerformed':False,'goldTargetsAccepted':False,'intermediateInputTokenIDs':intermediate_input,'finalPrefixTokenIDs':final_prefix,'finalSuffixTokenIDs':final_suffix,'modelExecutionPerformed':not args.validate_only}
 if not args.validate_only:
  # Imports are deliberately delayed: --validate-only does not initialize Metal.
  import mlx.core as mx
  from mlx.utils import tree_flatten
  from mlx_lm.models.llama import Model, ModelArgs
  from importlib.metadata import version
  mx.set_default_device(mx.gpu)
  config=ModelArgs(model_type='llama',hidden_size=256,num_hidden_layers=8,intermediate_size=640,num_attention_heads=4,num_key_value_heads=4,head_dim=64,rms_norm_eps=1e-5,vocab_size=16384,max_position_embeddings=2048,rope_theta=10000.0,tie_word_embeddings=True)
  model=Model(config)
  model.load_weights(str(WEIGHTS),strict=True)
  model.eval()
  require(sum(p.size for _,p in tree_flatten(model.parameters()))==EXPECTED_PARAMETERS,'loaded model parameter count differs')
  mx.eval(model.parameters())
  def predict(ids):
   logits=model(mx.array([ids],dtype=mx.int32))[:,-1,:]
   token=mx.argmax(logits,axis=-1)
   probability=mx.softmax(logits,axis=-1)
   mx.eval(logits,token,probability)
   require(bool(mx.all(mx.isfinite(logits)).item()),'nonfinite logits')
   prediction=int(token.item())
   return prediction,float(probability[0,prediction].item())
  started=time.monotonic()
  intermediate,intermediate_probability=predict(intermediate_input)
  # Feed only the model's prediction into the second forward pass. No oracle or target is consulted.
  final_input=final_prefix+[intermediate]+final_suffix
  final,final_probability=predict(final_input)
  result.update({'observedParameterCount':EXPECTED_PARAMETERS,'intermediatePredictionTokenID':intermediate,'intermediatePredictionSymbol':SYMBOLS.get(intermediate,'UNASSIGNED_TOKEN_'+str(intermediate)),'intermediatePredictionProbability':intermediate_probability,'finalInputTokenIDs':final_input,'predictionTokenID':final,'predictionSymbol':SYMBOLS.get(final,'UNASSIGNED_TOKEN_'+str(final)),'predictedResidue':final-16 if 16<=final<24 else None,'predictionProbability':final_probability,'generationSeconds':time.monotonic()-started,'mlxVersion':version('mlx'),'mlxLMVersion':version('mlx-lm'),'fullVocabularyGreedy':True,'generationForwardPasses':2})
 with args.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
 print(json.dumps(result,sort_keys=True))
 signal.alarm(0)

if __name__=='__main__':
 try:main()
 except Exception as e:
  import sys
  print('Prime original-symbol inference failed: '+type(e).__name__+': '+str(e)[:240],file=sys.stderr)
  sys.exit(1)
