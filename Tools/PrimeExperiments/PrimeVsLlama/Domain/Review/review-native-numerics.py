#!/usr/bin/env python3
"""Read-only native numerical verification. Requires terminal run marker; never imports MLX or launches helpers."""
from pathlib import Path
import collections,hashlib,json,math,struct,sys,time,traceback
W=Path(__file__).resolve().parent.parent;P=W/'Comparison';R=Path(__file__).resolve().parent
SEEDS=[1618,2718,3141];ROUTES=['host','guest'];BATCHES=59
KEYS=['direct','leftSummary','rightSummary','iterativeFinal']
OLD_KEYS=['direct_prediction','left_summary_prediction','right_summary_prediction','autoregressive_prediction']
def J(p):return json.loads(p.read_bytes())
def H(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return {'byteCount':n,'sha256':h.hexdigest()}
def C(b,m):
 if not b:raise AssertionError(m)
def dump(p,x):
 with p.open('x') as f:json.dump(x,f,indent=2);f.write('\n')
def line(f,x):f.write(json.dumps(x,sort_keys=True,separators=(',',':'))+'\n')
def score_new():return {'cases':0,'directCorrect':0,'leftSummaryCorrect':0,'rightSummaryCorrect':0,'iterativeFinalCorrect':0,'bothSummariesCorrect':0,'completeIterativeTraceCorrect':0,'bothDirectAndIterativeCorrect':0,'malformedCases':0,'malformedDirectCorrect':0,'malformedIterativeCorrect':0}
def score_add(s,ids,target,represented):
 eq=[a==b for a,b in zip(ids,target)];s['cases']+=1
 for k,b in zip(['directCorrect','leftSummaryCorrect','rightSummaryCorrect','iterativeFinalCorrect'],eq):s[k]+=b
 s['bothSummariesCorrect']+=all(eq[1:3]);s['completeIterativeTraceCorrect']+=all(eq[1:]);s['bothDirectAndIterativeCorrect']+=eq[0] and eq[3]
 if not represented:s['malformedCases']+=1;s['malformedDirectCorrect']+=eq[0];s['malformedIterativeCorrect']+=eq[3]
 return eq

def main():
 C(len(sys.argv)==1,'No arguments; this reviewer is bound to its adjacent completed comparison.')
 terminal=P/'NATIVE-COMPLETE.json';C(terminal.is_file(),'NATIVE-COMPLETE.json absent; no readback permitted yet')
 completed=J(terminal);C(completed.get('status')=='completed','terminal marker not completed')
 out=R/'native-readback-01';out.mkdir(mode=0o700)
 started=time.monotonic();cases=J(P/'Inputs/cases.json')['cases'];golds=J(P/'References/gold.json')['cases'];manifest=J(P/'References/original-manifest.json')
 originals=[r for r in manifest['rows'] if r['split']=='holdout']+manifest['mutations']
 C(len(cases)==len(golds)==len(originals)==940 and len({c['id'] for c in cases})==940,'exact940 case inventory')
 for c,g,old in zip(cases,golds,originals):
  C(c['id']==g['id']==old['row_id'],'original row identity')
  C(set(c)=={'id','allowedValueCount','allowedValueMinimum','jobs'} and c['allowedValueMinimum']==0 and c['allowedValueCount']==16384,'unrestricted vocabulary policy')
  prefix=old['final_prefix_ids'];suffix=old['final_suffix_ids']
  expected=[old['direct_input_ids'],old['left_input_ids'],old['right_input_ids'],prefix+[0,0]+suffix]
  C(len(c['jobs'])==4 and [j['inputTokenIDs'] for j in c['jobs']]==expected,'input-only original projection')
  bindings=[[],[],[],[{'inputOffset':len(prefix),'sourceJobIndex':1},{'inputOffset':len(prefix)+1,'sourceJobIndex':2}]]
  C([j['feedbackBindings'] for j in c['jobs']]==bindings and all(set(j)=={'inputTokenIDs','feedbackBindings'} for j in c['jobs']),'fan-in only actual sources1and2')
  targets=[old['final_target_id'],old['left_summary_target_id'],old['right_summary_target_id'],old['final_target_id']]
  C(g['expectedJobIDs']==targets and g['directTargetID']==targets[0] and g['sourceSplit']==old['split'] and g['represented']==old['represented'],'scorer targets joined original source')
 model_bindings={x['seed']:x for x in J(P/'References/model-bindings.json')}
 reports={};historical={};history_summary={}
 for seed in SEEDS:
  path=P/f'References/original-report-seed-{seed}.json';r=J(path);pin=model_bindings[seed]
  C(H(path)['sha256']==pin['originalReportSHA256'] and H(Path(pin['originalReportPath']))==H(path),'original report unchanged/copied exactly')
  C(r['durability']['checkpoint_sha256']==pin['weightsSHA256'],'historical model SHA')
  reports[seed]=r;historical[seed]={};hs={}
  for split in ['holdout','mutation']:
   ev=r['evaluation'][split];C(len(ev['results'])==470,'historical split count');sc=score_new()
   for old in ev['results']:
    C(old['row_id'] not in historical[seed],'historical unique rows');historical[seed][old['row_id']]=old
    g=next(g for g in golds if g['id']==old['row_id']);ids=[old[k] for k in OLD_KEYS]
    C([old['final_target'],old['left_summary_target'],old['right_summary_target'],old['final_target']]==g['expectedJobIDs'],'historical targets equal current references')
    score_add(sc,ids,g['expectedJobIDs'],g['represented'])
   for field,key in [('directCorrect','direct_accuracy'),('leftSummaryCorrect','left_summary_accuracy'),('rightSummaryCorrect','right_summary_accuracy'),('iterativeFinalCorrect','autoregressive_accuracy')]:C(abs(sc[field]/470-ev[key])<1e-15,'historical aggregate arithmetic')
   hs[split]=sc
  history_summary[str(seed)]={'recordedOutcome':r['outcome'],'recordedEngineAuthoritative':r['engine_authoritative'],'recordedProductPromotionAuthorized':r['product_promotion_authorized'],'nextAction':r['next_action'],'recomputedScores':hs,'reportBinding':H(path)}
 aggregate={};historical_change_counts=collections.Counter();pair_differences=[];vectors=bytes_checked=paired_identical=feedback_joins=0;max_host_guest_logit_delta=0.0;phases=[];weights=[];seen_pids=set();chain=hashlib.sha256()
 with (out/'case-scores.jsonl').open('x') as scores_file,(out/'historical-prediction-differences.jsonl').open('x') as hist_file,(out/'host-guest-differences.jsonl').open('x') as diff_file:
  for seed in SEEDS:
   pin=model_bindings[seed];actual_weight=H(Path(pin['weightsPath']));C(actual_weight=={'byteCount':pin['weightsBytes'],'sha256':pin['weightsSHA256']},'retained original weights changed')
   weights.append({'seed':seed,'path':pin['weightsPath'],**actual_weight});aggregate[str(seed)]={route:{s:score_new() for s in ['all','holdout','mutation']} for route in ROUTES}
   for batch in range(BATCHES):
    chunk=cases[batch*16:min((batch+1)*16,940)];gold_chunk=golds[batch*16:min((batch+1)*16,940)];run={};dirs={}
    for route in ROUTES:
     d=P/'Results'/f'seed-{seed}-{route}-batch-{batch:03d}';dirs[route]=d;r=J(d/'native/result.json');req=J(d/'request.json');run[route]=r
     C(set(req)=={'cases','execution','schema','weightsPath','weightsSHA256'} and req['cases']==chunk and req['execution']==route,'exact batch inputs, no gold input keys')
     C(req['weightsPath']==pin['weightsPath'] and req['weightsSHA256']==pin['weightsSHA256'],'selected checkpoint')
     C(r['status']=='completed' and r['execution']==route and r['compute']=='native_Swift_host_Metal' and r['trainingPerformed'] is False and r['modelWeightsInGuest'] is False,'live execution scope')
     C(r['weightsBefore']==r['weightsAfter']==actual_weight and r['requestSHA256']==H(d/'request.json')['sha256'] and (d/'request.json').read_bytes()==(d/'native/request.json').read_bytes(),'run inputs/model bound')
     C(r['tensorCount']==74 and r['parameterCount']==10227968 and len(r['cases'])==len(chunk),'actual geometry/case count')
     C(r['processID'] not in seen_pids,'fresh process identity');seen_pids.add(r['processID']);phases.append({'phase':d.name,'pid':r['processID'],'cases':len(chunk),'resultBinding':H(d/'native/result.json')})
    for ci,(case,gold) in enumerate(zip(chunk,gold_chunk)):
     predictions={};payloads={};ids_by_route={}
     for route in ROUTES:
      group=run[route]['cases'][ci];C(group['id']==case['id'] and group['status']=='completed' and len(group['predictions'])==4,'case prediction scope')
      ps=group['predictions'];ids=[x['predictionTokenID'] for x in ps];predictions[route]=ps;ids_by_route[route]=ids;payloads[route]=[]
      if route=='guest':C(group['guest']['guestCommittedPredictions']==ids and len(group['guest']['observedInputTokenIDs'])==4,'actual guest committed predictions')
      for j,pred in enumerate(ps):
       expected=case['jobs'][j]['inputTokenIDs'].copy()
       for b in case['jobs'][j]['feedbackBindings']:
        C(expected[b['inputOffset']]==0 and b['sourceJobIndex']<j,'empty placeholder/earlier source');expected[b['inputOffset']]=ids[b['sourceJobIndex']];feedback_joins+=1
       C(pred['id']==case['id'] and pred['inputTokenIDs']==expected,'actual predicted fan-in')
       if route=='guest':C(group['guest']['observedInputTokenIDs'][j]==expected,'guest actually used computed operands')
       l=pred['logits'];C(l['dtype']=='float32_little_endian' and l['shape']==[16384] and pred['logitsFinite'] is True,'full vocabulary output')
       leaf=l['path'];C(Path(leaf).name==leaf and leaf==f'case-{ci:03d}-job-{j:02d}-logits.f32le','output leaf')
       data=(dirs[route]/'native'/leaf).read_bytes();h={'byteCount':len(data),'sha256':hashlib.sha256(data).hexdigest()};C(h==l['content'] and len(data)==65536,'all original output bytes hashed')
       vectors+=1;bytes_checked+=len(data);chain.update(json.dumps([seed,route,case['id'],j,h],sort_keys=True,separators=(',',':')).encode()+b'\n');payloads[route].append(data)
      eq=score_add(aggregate[str(seed)][route]['all'],ids,gold['expectedJobIDs'],gold['represented']);score_add(aggregate[str(seed)][route][gold['sourceSplit']],ids,gold['expectedJobIDs'],gold['represented'])
      old=historical[seed][case['id']];old_ids=[old[k] for k in OLD_KEYS];changed=[]
      for j,(old_id,new_id) in enumerate(zip(old_ids,ids)):
       if old_id!=new_id:
        changed.append(KEYS[j]);historical_change_counts[f'{seed}/{route}/{KEYS[j]}']+=1
        line(hist_file,{'seed':seed,'execution':route,'caseID':case['id'],'split':gold['sourceSplit'],'job':KEYS[j],'historicalPrediction':old_id,'currentPrediction':new_id,'target':gold['expectedJobIDs'][j],'historicalCorrect':old_id==gold['expectedJobIDs'][j],'currentCorrect':new_id==gold['expectedJobIDs'][j]})
      line(scores_file,{'seed':seed,'execution':route,'caseID':case['id'],'split':gold['sourceSplit'],'family':gold['familyID'],'represented':gold['represented'],'predictions':ids,'targets':gold['expectedJobIDs'],'correctByJob':eq,'historicalPredictions':old_ids,'changedFromHistory':changed})
     for j,(hb,gb) in enumerate(zip(payloads['host'],payloads['guest'])):
      equal=hb==gb;paired_identical+=equal;vecs={'host':struct.unpack('<16384f',hb)}
      if not equal:vecs['guest']=struct.unpack('<16384f',gb)
      else:vecs['guest']=vecs['host']
      for route in ROUTES:
       v=vecs[route];pred=predictions[route][j]
       if route=='host' or not equal:
        C(all(math.isfinite(x) for x in v),'nonfinite raw logit');arg=max(range(16384),key=v.__getitem__);prob=1/sum(math.exp(x-v[arg]) for x in v)
       # Equal guest bytes reuse the same independently computed numeric result.
       C(arg==pred['predictionTokenID'] and struct.pack('<f',v[arg])==struct.pack('<f',pred['maximumLogit']),'full16384 argmax/maximum binding')
       C(abs(prob-pred['predictionProbability'])<1e-12,'reported softmax probability')
      same_input=predictions['host'][j]['inputTokenIDs']==predictions['guest'][j]['inputTokenIDs']
      if not equal or not same_input:
       delta=max(abs(a-b) for a,b in zip(vecs['host'],vecs['guest']));max_host_guest_logit_delta=max(max_host_guest_logit_delta,delta)
       d={'seed':seed,'caseID':case['id'],'job':KEYS[j],'inputsEqual':same_input,'bytesEqual':equal,'maximumAbsoluteLogitDifference':delta,'hostPrediction':ids_by_route['host'][j],'guestPrediction':ids_by_route['guest'][j]};line(diff_file,d);pair_differences.append(d)
    if batch%15==0:print(json.dumps({'seed':seed,'reviewedBatch':batch,'verifiedLogitFiles':vectors}),flush=True)
   C(H(Path(pin['weightsPath']))==actual_weight,'weights changed during readback')
 C(vectors==22560 and bytes_checked==1478492160 and feedback_joins==11280 and len(phases)==354,'final exact numerical counts')
 score_deltas={}
 for seed in SEEDS:
  score_deltas[str(seed)]={route:{split:{k:aggregate[str(seed)][route][split][k]-history_summary[str(seed)]['recomputedScores'][split][k] for k in ['directCorrect','leftSummaryCorrect','rightSummaryCorrect','iterativeFinalCorrect','completeIterativeTraceCorrect']} for split in ['holdout','mutation']} for route in ROUTES}
 final={'status':'REVIEW_COMPLETE','numericalEvidenceIntegrityVerified':True,'scope':'Read-only full native host/guest numerical review; no model/GPU/HV execution by reviewer.','caseCountPerSeedExecution':940,'seeds':SEEDS,'executions':ROUTES,'actualProcesses':354,'actualCases':5640,'actualModelForwards':22560,'verifiedFullLogitFiles':vectors,'verifiedLogitBytes':bytes_checked,'logitBindingChainSHA256':chain.hexdigest(),'allVectorsFiniteAndUnrestrictedArgmaxVerified':True,'actualFanInBindingsVerified':feedback_joins,'hostGuestIdenticalLogitPairs':paired_identical,'hostGuestComparedLogitPairs':11280,'hostGuestAllLogitsByteIdentical':paired_identical==11280,'hostGuestDifferences':{'count':len(pair_differences),'maximumAbsoluteLogitDifference':max_host_guest_logit_delta,'first20':pair_differences[:20]},'accuracy':aggregate,'historicalReports':history_summary,'historicalPredictionChangeCounts':dict(historical_change_counts),'accuracyDeltaFromHistoricalPython':score_deltas,'unchangedModelWeights':weights,'inputBindings':{str(p.relative_to(P)):H(p) for p in [P/'Inputs/cases.json',P/'References/gold.json',P/'References/original-manifest.json',P/'NATIVE-COMPLETE.json']},'detailArtifacts':[{'path':str(p),**H(p)} for p in out.iterdir() if p.is_file()],'phaseBindings':phases,'elapsedSeconds':time.monotonic()-started,'reviewerSource':H(Path(__file__)),'limits':['REVIEW_COMPLETE reports evidence integrity and measured scores; it does not mean940/940 model accuracy or model/product promotion.','Original Python evaluation used grouping/batching and a different implementation; actual historical prediction differences are retained instead of assumed exact reproduction.','The original teacher-final control that fed gold summary targets is intentionally absent; iterative final uses actual new job1 and job2 predictions.','Original selected cases are470holdout plus470mutation; no training/validation examples are evaluated here. These are domain-specific symbolic engine rows, not arbitrary English or a general language benchmark.','Original three-seed consensus remains ABSTAIN. Individual recorded GROUNDED/ABSTAIN labels are preserved, as is product_promotion_authorized=false. This experiment does not redefine formal authority.','Host and guest both compute model math on host Metal. Guest owns request/fan-in flow; weights and GPU execution do not move into guest OS.']}
 dump(R/'NATIVE-NUMERICAL-REVIEW.json',final);print(json.dumps({'status':final['status'],'allHostGuestBytesEqual':final['hostGuestAllLogitsByteIdentical'],'files':vectors,'accuracy':aggregate,'historicalPredictionChanges':dict(historical_change_counts),'report':str(R/'NATIVE-NUMERICAL-REVIEW.json')},indent=2),flush=True)
if __name__=='__main__':
 try:main()
 except Exception as error:
  p=R/'NUMERICAL-REVIEW-ERROR.json'
  if not p.exists():dump(p,{'status':'REVIEW_ERROR','error':str(error),'traceback':traceback.format_exc()})
  raise
