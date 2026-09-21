#!/usr/bin/env python3
"""Parameterised CPU-only numerical readback for completed four-job host/guest collections.
No model imports, process launches, target injection or writes to the collection.
"""
from pathlib import Path
import argparse,collections,hashlib,json,math,struct,time

def J(p):return json.loads(p.read_bytes())
def H(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return {'byteCount':n,'sha256':h.hexdigest()}
def C(b,m):
 if not b:raise AssertionError(m)
def line(f,x):f.write(json.dumps(x,sort_keys=True,separators=(',',':'))+'\n')
def score_new():return {'cases':0,'directCorrect':0,'leftSummaryCorrect':0,'rightSummaryCorrect':0,'iterativeFinalCorrect':0,'bothSummariesCorrect':0,'completeIterativeTraceCorrect':0,'directUnexpected224':0,'iterativeUnexpected224':0}
def score_add(s,ids,target):
 eq=[a==b for a,b in zip(ids,target)];s['cases']+=1
 for k,b in zip(['directCorrect','leftSummaryCorrect','rightSummaryCorrect','iterativeFinalCorrect'],eq):s[k]+=b
 s['bothSummariesCorrect']+=all(eq[1:3]);s['completeIterativeTraceCorrect']+=all(eq[1:]);s['directUnexpected224']+=ids[0]==224 and target[0]!=224;s['iterativeUnexpected224']+=ids[3]==224 and target[3]!=224
 return eq

def main():
 a=argparse.ArgumentParser();a.add_argument('--comparison',required=True,type=Path);a.add_argument('--expected-cases',required=True,type=int);a.add_argument('--output',required=True,type=Path);args=a.parse_args()
 P=args.comparison;O=args.output;C(P.is_absolute() and O.is_absolute() and P.resolve()==P and O.parent.resolve()==O.parent,'canonical absolute paths required');C(1<=args.expected_cases<=4096,'bounded case count');C(P not in O.parents and P!=O,'review output must be outside source collection')
 terminal=P/'NATIVE-COMPLETE.json';C(terminal.is_file() and J(terminal)['status']=='completed','complete native run required')
 proof=P/'GENERATION-COMPLETE.json';C(proof.is_file(),'generated input proof required');generation=J(proof)
 cases=J(P/'Inputs/cases.json')['cases'];golds=J(P/'References/gold.json')['cases'];n=args.expected_cases
 audit=J(P/'INPUT-AUDIT.json');prov_rows=J(P/'References/case-provenance.json')['cases'];provenance={r['id']:r for r in prov_rows};manifest=J(P/'References/original-manifest.json')
 C(generation['status']=='prepared' and generation['cases']==n and generation['gpuRun']is False and generation['trainingRun']is False,'preparation scope')
 C(generation['commonInputsSHA256']==H(P/'Inputs/cases.json')['sha256'] and generation['goldSHA256']==H(P/'References/gold.json')['sha256'] and generation['inputAuditSHA256']==H(P/'INPUT-AUDIT.json')['sha256'],'generation pins')
 C(audit['sourcePolicy']['originalManifestSHA256']==H(P/'References/original-manifest.json')['sha256'],'original manifest pin')
 C(len(provenance)==len(prov_rows)==n,'percase provenance inventory')
 old_index={r['row_id']:r for r in manifest['rows']};roles=['left_input_ids','right_input_ids','direct_input_ids','final_prefix_ids','final_suffix_ids'];names=['left','right','direct','prefix','suffix']
 def input_obj(row):return dict(zip(names,[row[k] for k in roles]))
 def digest(obj):return hashlib.sha256(json.dumps(obj,sort_keys=True,separators=(',',':')).encode()).hexdigest()
 def stripped(ids):return ids[:1]+ids[2:] if len(ids)>1 and ids[1]==4 else ids[:]
 def semantic(obj):return {k:v if k=='suffix' else stripped(v) for k,v in obj.items()}
 def toggle(ids):return ids[:1]+ids[2:] if ids[1]==4 else ids[:1]+[4]+ids[1:]
 original_sets={}
 for split in ['train','validation','holdout','mutation']:
  rr=manifest['mutations'] if split=='mutation' else [r for r in manifest['rows'] if r['split']==split]
  original_sets[split]={'exact':{digest(input_obj(r)) for r in rr},'semantic':{digest(semantic(input_obj(r))) for r in rr},'components':{role:{tuple(r[role]) for r in rr} for role in roles}}
 measured_overlap={k:{'generatedWholeInputExactMatches':0,'generatedWholeInputSemanticMatchesIgnoringNeutralContext':0,'generatedComponentExactMatches':{role:0 for role in roles}} for k in original_sets}
 measured_splits=collections.Counter()
 for c,g in zip(cases,golds):
  pr=provenance[c['id']];old=old_index[pr['sourceRowID']];j=c['jobs'];offset=j[3]['feedbackBindings'][0]['inputOffset'];obj={'left':j[1]['inputTokenIDs'],'right':j[2]['inputTokenIDs'],'direct':j[0]['inputTokenIDs'],'prefix':j[3]['inputTokenIDs'][:offset],'suffix':j[3]['inputTokenIDs'][offset+2:]};oi=input_obj(old)
  C(all(obj[k]==(oi[k] if k=='suffix' else toggle(oi[k])) for k in names),'only supported neutral-context toggle')
  C(digest(oi)==pr['selectionInputSHA256'] and digest(obj)==pr['generatedInputSHA256'] and digest(semantic(obj))==pr['semanticInputSHA256'] and semantic(obj)==semantic(oi),'exact input/semantic provenance hashes')
  C(pr['sourceSplit']==g['sourceSplit']==old['split'] and pr['familyID']==g['familyID']==old['family_id'],'source family/split preserved');measured_splits[old['split']]+=1
  C(g['expectedJobIDs']==[old['final_target_id'],old['left_summary_target_id'],old['right_summary_target_id'],old['final_target_id']],'original semantic references unchanged')
  for split,sets in original_sets.items():
   m=measured_overlap[split];m['generatedWholeInputExactMatches']+=digest(obj)in sets['exact'];m['generatedWholeInputSemanticMatchesIgnoringNeutralContext']+=digest(semantic(obj))in sets['semantic']
   for role,k in zip(roles,names):m['generatedComponentExactMatches'][role]+=tuple(obj[k])in sets['components'][role]
 C(dict(measured_splits)==audit['originalSourceSplitCounts']==generation['originalSourceSplitCounts'],'source split counts')
 for split,m in measured_overlap.items():
  C(all(v==audit['overlapWithOriginalBySplit'][split][k] for k,v in m.items()),'overlap recomputed from actual arrays')
 C(len(cases)==len(golds)==n and len({c['id'] for c in cases})==n,'expected unique case count')
 for c,g in zip(cases,golds):
  C(c['id']==g['id'] and set(c)=={'id','allowedValueMinimum','allowedValueCount','jobs'} and c['allowedValueMinimum']==0 and c['allowedValueCount']==16384,'case identity/full vocabulary')
  C(len(c['jobs'])==4 and len(g['expectedJobIDs'])==4,'four-job contract');C(g['expectedJobIDs'][0]==g['expectedJobIDs'][3],'same direct/final reference')
  C(g['represented'] is True and 192<=g['expectedJobIDs'][0]<=197,'valid represented generated scope')
  for index,job in enumerate(c['jobs']):
   C(set(job)=={'inputTokenIDs','feedbackBindings'} and 1<=len(job['inputTokenIDs'])<=64 and all(type(v)is int and 0<=v<16384 for v in job['inputTokenIDs']),'bounded original IDs')
   b=job['feedbackBindings'];C(len(b)==(2 if index==3 else 0),'four job dependency counts')
   if index==3:
    C([x['sourceJobIndex'] for x in b]==[1,2] and len({x['inputOffset'] for x in b})==2,'fan-in actual sources1/2')
    C(all(0<=x['inputOffset']<len(job['inputTokenIDs']) and job['inputTokenIDs'][x['inputOffset']]==0 for x in b),'zero placeholders')
 O.mkdir(mode=0o700);started=time.monotonic();seeds=[1618,2718,3141];routes=['host','guest'];batches=math.ceil(n/16)
 aggregates={};vectors=rawbytes=pairs_equal=feedback=0;diffs=[];phasebindings=[];pids=set();weightpins={};chain=hashlib.sha256()
 scalar_buckets=['sourceSplit','originalSplit','basisSplit','basisSourceSplit','familyID','exactInputOverlap','semanticOverlap','originalInputOverlap','originalSemanticOverlap']
 with (O/'case-scores.jsonl').open('x') as scored,(O/'host-guest-differences.jsonl').open('x') as differences:
  for seed in seeds:
   aggregates[str(seed)]={route:{'all':score_new(),'byMetadata':{}} for route in routes}
   for batch in range(batches):
    chunk=cases[batch*16:(batch+1)*16];goldchunk=golds[batch*16:(batch+1)*16];results={};dirs={}
    for route in routes:
     d=P/'Results'/f'seed-{seed}-{route}-batch-{batch:03d}';dirs[route]=d;req=J(d/'request.json');r=J(d/'native/result.json');results[route]=r
     C(set(req)=={'cases','execution','schema','weightsPath','weightsSHA256'} and req['execution']==route and req['cases']==chunk,'only canonical generated inputs')
     C(r['status']=='completed' and r['execution']==route and r['trainingPerformed']is False and r['modelWeightsInGuest']is False and r['compute']=='native_Swift_host_Metal','actual runtime route')
     C(r['weightsBefore']==r['weightsAfter'] and r['weightsBefore']['sha256']==req['weightsSHA256'] and r['weightsPath']==req['weightsPath'],'model binding')
     wb=(r['weightsPath'],r['weightsBefore']);C(seed not in weightpins or weightpins[seed]==wb,'one checkpoint per seed');weightpins[seed]=wb
     C(r['requestSHA256']==H(d/'request.json')['sha256'] and (d/'request.json').read_bytes()==(d/'native/request.json').read_bytes(),'retained request bytes')
     C(r['parameterCount']==10227968 and r['tensorCount']==74 and len(r['cases'])==len(chunk),'strict model/case geometry')
     C(r['processID']not in pids,'unique process');pids.add(r['processID']);phasebindings.append({'phase':d.name,'pid':r['processID'],'result':H(d/'native/result.json')})
    for ci,(case,gold) in enumerate(zip(chunk,goldchunk)):
     ps={};payloads={};prediction_ids={}
     for route in routes:
      g=results[route]['cases'][ci];C(g['id']==case['id'] and g['status']=='completed' and len(g['predictions'])==4,'case completion');ps[route]=g['predictions'];ids=[p['predictionTokenID'] for p in ps[route]];prediction_ids[route]=ids;payloads[route]=[]
      if route=='guest':C(g['guest']['guestCommittedPredictions']==ids and len(g['guest']['observedInputTokenIDs'])==4,'guest commitment')
      for j,p in enumerate(ps[route]):
       expected=case['jobs'][j]['inputTokenIDs'].copy()
       for b in case['jobs'][j]['feedbackBindings']:expected[b['inputOffset']]=ids[b['sourceJobIndex']];feedback+=1
       C(p['id']==case['id'] and p['inputTokenIDs']==expected,'actual source fan-in')
       if route=='guest':C(g['guest']['observedInputTokenIDs'][j]==expected,'guest observed exact input')
       l=p['logits'];C(l['dtype']=='float32_little_endian' and l['shape']==[16384] and p['logitsFinite']is True and l['path']==f'case-{ci:03d}-job-{j:02d}-logits.f32le','raw shape/path')
       data=(dirs[route]/'native'/l['path']).read_bytes();h={'byteCount':len(data),'sha256':hashlib.sha256(data).hexdigest()};C(h==l['content'] and len(data)==65536,'full logit content hash');payloads[route].append(data);vectors+=1;rawbytes+=len(data);chain.update(json.dumps([seed,route,case['id'],j,h],sort_keys=True,separators=(',',':')).encode()+b'\n')
      agg=aggregates[str(seed)][route];eq=score_add(agg['all'],ids,gold['expectedJobIDs'])
      for field in scalar_buckets:
       if field in gold and isinstance(gold[field],(str,int,bool,float)):
        group=agg['byMetadata'].setdefault(field,{});score_add(group.setdefault(str(gold[field]),score_new()),ids,gold['expectedJobIDs'])
      line(scored,{'seed':seed,'execution':route,'caseID':case['id'],'predictions':ids,'correctByJob':eq,'referenceAndSourceMetadata':gold,'inputProvenance':provenance[case['id']]})
     for j,(hd,gd) in enumerate(zip(payloads['host'],payloads['guest'])):
      eq=hd==gd;pairs_equal+=eq;vv={'host':struct.unpack('<16384f',hd)};vv['guest']=vv['host'] if eq else struct.unpack('<16384f',gd)
      for route in routes:
       v=vv[route];pred=ps[route][j]
       if route=='host' or not eq:
        C(all(math.isfinite(x) for x in v),'finite output');arg=max(range(16384),key=v.__getitem__);prob=1/sum(math.exp(x-v[arg]) for x in v)
       C(arg==pred['predictionTokenID'] and struct.pack('<f',v[arg])==struct.pack('<f',pred['maximumLogit']) and abs(prob-pred['predictionProbability'])<1e-12,'unrestricted argmax/probability')
      ieq=ps['host'][j]['inputTokenIDs']==ps['guest'][j]['inputTokenIDs']
      if not eq or not ieq:
       delta=max(abs(a-b) for a,b in zip(vv['host'],vv['guest']));diff={'seed':seed,'caseID':case['id'],'job':j,'inputsEqual':ieq,'bytesEqual':eq,'maxAbsoluteLogitDelta':delta,'hostPrediction':prediction_ids['host'][j],'guestPrediction':prediction_ids['guest'][j]};line(differences,diff);diffs.append(diff)
    if batch%16==0:print(json.dumps({'seed':seed,'reviewedBatch':batch,'logitFiles':vectors}),flush=True)
 C(vectors==n*3*2*4 and feedback==n*3*2*2 and len(phasebindings)==batches*3*2,'actual full generated counts')
 models=[]
 for seed,(path,pin) in weightpins.items():C(H(Path(path))==pin,'unchanged model bytes');models.append({'seed':seed,'path':path,**pin})
 report={'status':'REVIEW_COMPLETE','numericalEvidenceIntegrityVerified':True,'caseCountPerSeedExecution':n,'actualCases':n*6,'actualModelForwards':vectors,'actualProcesses':len(phasebindings),'allLogitFilesHashedFiniteAndFullArgmaxVerified':True,'verifiedLogitBytes':rawbytes,'logitBindingChainSHA256':chain.hexdigest(),'actualPredictedFanInBindings':feedback,'hostGuestByteIdenticalPairs':pairs_equal,'hostGuestComparedPairs':n*3*4,'hostGuestAllLogitsByteIdentical':pairs_equal==n*3*4,'hostGuestDifferences':{'count':len(diffs),'first20':diffs[:20]},'accuracy':aggregates,'generationProof':{'path':str(proof),**H(proof),'content':generation},'sourceSplitCountsRecomputed':dict(measured_splits),'overlapRecomputedFromActualArrays':measured_overlap,'sourceProvenanceBinding':H(P/'References/case-provenance.json'),'inputAuditBinding':H(P/'INPUT-AUDIT.json'),'unchangedModelBindings':models,'inputBindings':{str(p.relative_to(P)):H(p) for p in [P/'Inputs/cases.json',P/'References/gold.json',terminal]},'detailArtifacts':[{'path':str(p),**H(p)} for p in O.iterdir() if p.is_file()],'phaseBindings':phasebindings,'elapsedSeconds':time.monotonic()-started,'reviewerSource':H(Path(__file__)),'limits':['All outcomes are actual fixed-checkpoint inference, not training or generated target injection.','Every generated case reuses an existing semantic request. Only supported neutral-context placement changed. All source train/validation/holdout and component/whole-input overlap counts were independently recomputed; this is not an unseen-semantic-task benchmark.','Full vocabulary is unrestricted:224 or another wrong output on a valid case remains a wrong model prediction, never repaired.','Four-job fan-in uses actual source jobs1and2, not scorer summary targets.','Host/guest numerical parity and data integrity do not imply model accuracy, formal authority, product promotion, or a general language benchmark.','This generated set has no historical prediction baseline; the separate original940-case reproduction retains historical comparison.']}
 with (O/'NUMERICAL-REVIEW.json').open('x') as f:json.dump(report,f,indent=2);f.write('\n')
 print(json.dumps({'status':report['status'],'sameLogits':report['hostGuestAllLogitsByteIdentical'],'accuracy':{s:{r:a['all'] for r,a in x.items()} for s,x in aggregates.items()},'report':str(O/'NUMERICAL-REVIEW.json')},indent=2),flush=True)
if __name__=='__main__':main()
