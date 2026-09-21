#!/usr/bin/env python3
"""CPU-only readback of original Python/Swift192job numerical parity."""
from pathlib import Path
import hashlib,json,math,struct
R=Path(__file__).resolve().parent;W=R.parent;P=W/'Comparison';Y=P/'PythonParity'
def J(p):return json.loads(p.read_bytes())
def H(p):
 d=p.read_bytes();return {'byteCount':len(d),'sha256':hashlib.sha256(d).hexdigest()}
def C(b,m):
 if not b:raise AssertionError(m)
def write(p,x):
 with p.open('x') as f:json.dump(x,f,indent=2);f.write('\n')
def vector(p,pred):
 d=p.read_bytes();h={'byteCount':len(d),'sha256':hashlib.sha256(d).hexdigest()};C(h==pred['logits']['content'] and len(d)==65536,'raw vector hash');C(pred['logits']['shape']==[16384] and pred['logits']['dtype']=='float32_little_endian','dtype/shape')
 v=struct.unpack('<16384f',d);C(all(math.isfinite(x) for x in v),'finite vector');a=max(range(16384),key=v.__getitem__);C(a==pred['predictionTokenID'] and struct.pack('<f',v[a])==struct.pack('<f',pred['maximumLogit']),'argmax/maximum');return d,v
for seed in [1618,2718,3141]:
 C((Y/f'Live-seed-{seed}/native/result.json').is_file() and (Y/f'Live-seed-{seed}/controller/result.json').is_file(),'wait for all three completed live probes')
sourcepins=J(Y/'PINNED-SOURCES.json');source_checks=[]
for source in sourcepins['sources']:
 orig=Path(source['originalPath']);saved=Path(source['savedPath']);h=H(saved);C(h==H(orig)=={'byteCount':source['byteCount'],'sha256':source['sha256']},'original source bytes');source_checks.append({'originalPath':str(orig),'savedPath':str(saved),**h})
rows=[];seeds=[];maxdelta=0;pred_equal=byte_equal=input_equal=feedback=0
for seed in [1618,2718,3141]:
 d=Y/f'Live-seed-{seed}';p=J(d/'native/result.json');c=J(d/'controller/result.json');inv=J(d/'controller/invocation.json');spec=J(d/'specification.json')
 sdir=P/'Results'/f'seed-{seed}-host-batch-000';s=J(sdir/'native/result.json');req=J(d/'native/request.json')
 C(c['passed'] and c['exit_status']==c['raw_wait_status']==0 and c['exact_reap_count']==1 and c['pid']==c['requested_wait_pid']==c['returned_wait_pid'] and c['process_group_members_after_reap']==c['signals']==[] and c['reason'] is None and c['runner_error'] is None,'controller normal exact completion')
 C(inv['argv']==spec['argv'] and inv['replacement_environment']==spec['environment'],'actual invocation')
 streams={}
 for name in ['stdout','stderr']:
  h=H(d/f'controller/{name}.bin');r=c['streams'][name];C(r['eof'] and r['captured_bytes']==r['total_bytes']==h['byteCount'] and r['sha256']==h['sha256'],'complete streams');streams[name]=h
 C(p['status']=='completed' and p['seed']==seed and p['caseCount']==16 and p['modelForwards']==64 and p['parameterCount']==10227968 and p['tensorCount']==74,'Python run shape')
 C(p['targetsUsed'] is False and p['teacherFinalUsed'] is False and p['trainingPerformed'] is False,'no reference inputs or training')
 C(p['weightsBefore']==p['weightsAfter']==s['weightsBefore']==H(Path(p['weightsPath'])) and p['weightsPath']==s['weightsPath'],'same unchanged weights')
 C(p['requestSHA256']==H(d/'native/request.json')['sha256'] and req==J(sdir/'request.json'),'same first16 requests')
 C(len(p['cases'])==len(s['cases'])==16,'16 live cases');seedmax=0;seedeq=0;seedbyte=0;seedinput=0;seedfeedback=0
 events=[]
 for ci,(pg,sg,case) in enumerate(zip(p['cases'],s['cases'],req['cases'])):
  C(pg['id']==sg['id']==case['id'] and pg['status']=='completed' and len(pg['predictions'])==len(sg['predictions'])==4,'case identity')
  ids=[x['predictionTokenID'] for x in pg['predictions']];joins=[];events.append({'caseIndex':ci,'id':case['id'],'predictions':ids})
  for j,(pp,sp,job) in enumerate(zip(pg['predictions'],sg['predictions'],case['jobs'])):
   expected=job['inputTokenIDs'].copy()
   for b in job['feedbackBindings']:
    C(expected[b['inputOffset']]==0 and b['sourceJobIndex'] in [1,2] and j==3,'source binding');value=ids[b['sourceJobIndex']];expected[b['inputOffset']]=value;seedfeedback+=1;joins.append({'jobIndex':j,'inputOffset':b['inputOffset'],'sourceJobIndex':b['sourceJobIndex'],'actualPredictionTokenID':value})
   C(pp['inputTokenIDs']==expected and pp['jobIndex']==j,'actual Python feedback')
   pd,pv=vector(d/'native'/pp['logits']['path'],pp);sd,sv=vector(sdir/'native'/sp['logits']['path'],sp)
   delta=max(abs(a-b) for a,b in zip(pv,sv));rms=math.sqrt(sum((a-b)**2 for a,b in zip(pv,sv))/16384)
   eq=pp['predictionTokenID']==sp['predictionTokenID'];beq=pd==sd;ieq=pp['inputTokenIDs']==sp['inputTokenIDs'];seedeq+=eq;seedbyte+=beq;seedinput+=ieq;seedmax=max(seedmax,delta)
   rows.append({'seed':seed,'caseID':case['id'],'job':j,'inputsEqual':ieq,'predictionEqual':eq,'pythonPrediction':pp['predictionTokenID'],'swiftPrediction':sp['predictionTokenID'],'allLogitBytesEqual':beq,'maximumAbsoluteLogitDelta':delta,'rootMeanSquareLogitDelta':rms,'pythonLogitSHA256':pp['logits']['content']['sha256'],'swiftLogitSHA256':sp['logits']['content']['sha256']})
  C(pg['feedback']==joins,'retained Python joins')
 C([json.loads(x) for x in (d/'controller/stdout.bin').read_text().splitlines()]==events,'actual stdout case events')
 maxdelta=max(maxdelta,seedmax);pred_equal+=seedeq;byte_equal+=seedbyte;input_equal+=seedinput;feedback+=seedfeedback
 seeds.append({'seed':seed,'actualCases':16,'actualForwards':64,'actualFanInBindings':seedfeedback,'samePredictions':seedeq,'sameInputs':seedinput,'byteIdenticalLogitVectors':seedbyte,'maximumAbsoluteLogitDelta':seedmax,'weights':p['weightsBefore'],'runtime':p['runtime'],'controller':{'pid':c['pid'],'exitCode':0,'exactReapCount':1,'groupMembersAfterReap':[],'elapsedSeconds':c['elapsed_seconds'],'streams':streams},'resultBinding':H(d/'native/result.json')})
C(len(rows)==192 and feedback==96,'all192 output rows and96 actual feedback joins')
report={'status':'REVIEW_COMPLETE','scope':'Original Python make_model strict checkpoint reload versus native Swift first16 cases for each of three seeds. CPU-only independent file readback.','originalSources':source_checks,'sourceBinding':H(Y/'infer.py'),'all384RawVectorsHashFiniteAndFullArgmaxVerified':True,'comparedJobs':192,'identicalPredictions':pred_equal,'identicalInputVectors':input_equal,'byteIdenticalFullLogitVectors':byte_equal,'maximumAbsoluteLogitDelta':maxdelta,'actualPythonFanInBindings':feedback,'seeds':seeds,'comparisons':rows,'limits':['No bit-exact Python-versus-Swift requirement was assumed; observed raw deltas and predictions are reported.','Only first16 holdout cases per checkpoint are probed numerically in Python. Full940-case native host/guest reproduction is reviewed separately.','Both routes run host Metal full-prefix/no-cache forward. This does not place MLX or model weights in an OS guest.','No teacher-final/gold-summary model input is used. Each route uses its own actually predicted summaries.','Recorded historical authority and product status are not changed by successful implementation parity.'],'reviewerSource':H(Path(__file__))}
write(R/'PYTHON-SWIFT-PARITY.json',report);print(json.dumps({k:report[k] for k in ['status','comparedJobs','identicalPredictions','identicalInputVectors','byteIdenticalFullLogitVectors','maximumAbsoluteLogitDelta']},indent=2))
