#!/usr/bin/env python3
"""Independent saved mechanism-receipt checks; never starts a process or VM."""
from pathlib import Path
import json,hashlib
W=Path(__file__).resolve().parent.parent; P=W/'Checks'; evidence={}; failures=[]; count=0
def data(p):
 b=p.read_bytes();evidence[str(p)]={'path':str(p),'byteCount':len(b),'sha256':hashlib.sha256(b).hexdigest()};return b
def read(p):return json.loads(data(p))
def ck(v,name):
 global count
 count+=1
 if not v:failures.append(name)
b=read(P/'build01/build-result.json')
for pin in b['files']:
 p=Path(pin['path']);data(p);ck(evidence[str(p)]==pin,'compiled_input:'+str(p))
ck(all(c['exitCode']==0 and c['exactDirectChildReaped'] and not c['timedOut'] for c in b['commands']),'compiler_terminations')
ck(b['inputsUnchanged'] is True and b['guestRuns']==b['modelRuns']==b['gpuRuns']==0,'build_is_compile_only')
raw=data(P/'Live/controller/stdout.bin');err=data(P/'Live/controller/stderr.bin');ctrl=read(P/'Live/controller/result.json')
for name,bytes_ in [('stdout',raw),('stderr',err)]:
 s=ctrl['streams'][name];ck(s['eof'] is True and s['total_bytes']==s['captured_bytes']==len(bytes_) and s['sha256']==hashlib.sha256(bytes_).hexdigest(),name+'_capture')
ck(ctrl['passed'] is True and ctrl['exit_status']==ctrl['raw_wait_status']==0 and ctrl['termination_signal'] is None and ctrl['reason'] is None and ctrl['runner_error'] is None and ctrl['signals']==[] and ctrl['process_group_members_after_reap']==[] and ctrl['exact_reap_count']==1 and ctrl['pid']==ctrl['requested_wait_pid']==ctrl['returned_wait_pid'],'exact_process_completion')
inv=read(P/'Live/controller/invocation.json');spec=read(P/'Live/specification.json')
ck(inv['argv']==spec['argv']==[str(P/'build01/PrimeGuestABITwoChecks')] and inv['replacement_environment']==spec['environment'],'exact_invocation')
controller=W.parents[1]/'outputs/Prime-Experiment-Builds/Prime-vCPU-02/Runtime/controller.rb'
ck(inv['runner_sha256']==hashlib.sha256(data(controller)).hexdigest(),'controller_source_hash')
ck(read(P/'Live/outer.stdout')==ctrl and data(P/'Live/outer.stderr')==b'','outer_join')
signed_binary=data(P/'build01/PrimeGuestABITwoChecks')
rows=[json.loads(l) for l in raw.splitlines()]
ck(len(rows)==7 and rows[-1]=={'type':'summary','passed':6,'expected':6,'mechanismOnly':True,'modelInvoked':False},'six_rows_summary')
expected_status=[0,1,1,1,0,7];summary=[]
for i,row in enumerate(rows[:6]):
 r=row['result'];a=row['admission'];f=row['fixture'];req=row['request'];pre=i in [1,2,3]
 ck(row['type']=='mechanism_check' and row['test']==i and row['passed'] is True and row['mechanismOnly'] is True and row['modelInvoked'] is False,'row_identity_'+str(i))
 ck(a['status']==1 and a['reason']==a['securityStatus']==a['effectiveEntitlementError']==0 and a['identifier']=='com.ergentics.prime.vcpu-inference' and a['team']=='ZCQ435U8JP','actual_admission_'+str(i))
 for key in ['identityMatches','teamMatches','hardenedRuntime','hypervisorEntitlementTrue','entitlementSetExact','signatureValidationPerformed','signatureValid','effectiveEntitlementChecked','effectiveHypervisorTrue']:
  ck(a[key]==1,'admission_'+str(i)+'_'+key)
 ck(a['adHoc']==a['getTaskAllowPresent']==a['appSandboxPresent']==a['unexpectedEntitlementCount']==0 and a['entitlementCount']==1,'exact_entitlements_'+str(i))
 ck(r['status']==row['returnedStatus']==expected_status[i] and r['callbackCount']==f['calls']==f['returned'],'status_callback_counts_'+str(i))
 ck(r['cleanupComplete']==1 and r['allowedMin']==req['allowedMin'] and r['allowedCount']==req['allowedCount'],'policy_cleanup_'+str(i))
 if pre:
  ck(r['runCount']==r['callbackCount']==r['completedCount']==r['inferenceReturnCount']==0 and r['vmCreateStatus']==r['vcpuCreateStatus']==r['watchdogCreateStatus']==-2147483648,'pre_vm_rejection_'+str(i))
  if i==1:ck(req['jobs'][3]['bindings'][0]['inputOffset']==req['jobs'][3]['bindings'][1]['inputOffset'],'actual_duplicate_slot')
  if i==2:ck(req['jobs'][3]['bindings'][0]['sourceJobIndex']==3,'actual_self_source')
  if i==3:ck(req['jobs'][1]['bindings'][0]['sourceJobIndex']==2,'actual_forward_source')
 else:
  for key in ['vmCreateStatus','codeMapStatus','dataMapStatus','vcpuCreateStatus','codeProtectStatus','dataProtectStatus','watchdogCreateStatus','watchdogJoinStatus','vcpuDestroyStatus','codeUnmapStatus','dataUnmapStatus','vmDestroyStatus','codeMunmapStatus','dataMunmapStatus']:
   ck(r[key]==0,'lifecycle_'+str(i)+'_'+key)
  ck(r['watchdogFired']==r['watchdogExitCalls']==0 and r['codeByteCount']==240 and r['codeImmutableValidated']==r['dataGuardValidated']==r['registerChecksPassed']==r['guestInputChecksPassed']==1,'guards_'+str(i))
  ck(r['inferenceRequestCount']==r['inferenceReturnCount']==r['completedCount']==f['calls'],'committed_callback_prefix_'+str(i))
  for j,e in enumerate(r['exits']):
   ck(e['runStatus']==0 and e['reason']==1 and e['validated']==1 and e['cpsr']&~0xf0000000==0x3c5 and e['sctlr']==0x30d00980 and e['x20']==0x10004000 and e['x21']==j and e['x22']==r['requestedCount'] and e['x23']==r['allowedMin'] and e['x28']==r['allowedCount'] and e['x24']==0x10004000+64+j*280,'guest_registers_'+str(i)+'_'+str(j))
   hvc=e['syndrome']&0xffff;offset={0x41:(136,140),0x42:(196,200),0x43:(232,236)}.get(hvc)
   ck(offset is not None and e['syndrome']==0x5a000000+hvc and e['pc']-0x10000000 in offset,'fixed_hvc_pc_'+str(i)+'_'+str(j))
  for j,job in enumerate(r['observedJobs']):
   want=list(req['jobs'][j]['inputTokenIDs'])
   for binding in req['jobs'][j]['bindings']:want[binding['inputOffset']]=f['returnValues'][binding['sourceJobIndex']]
   ck(job['inputTokenIDs']==f['observedInputs'][j]['inputTokenIDs']==want,'actual_callback_fan_in_'+str(i)+'_'+str(j))
 if i==0:
  ck(r['predictions'][:4]==[17,19,22,20] and r['runCount']==5 and r['completionHVCCount']==1 and r['observedJobs'][3]['inputTokenIDs']==[60,19,22,61],'two_distinct_sources_exact')
 if i==4:
  ck((r['allowedMin'],r['allowedCount'])==(0,16384) and r['predictions'][:2]==[224,16383] and r['runCount']==3 and r['completionHVCCount']==1 and r['observedJobs'][1]['inputTokenIDs']==[60,224,61],'unrestricted224_feedback')
 if i==5:
  last=r['exits'][-1]
  ck(r['stage']==r['completedCount']==r['callbackCount']==3 and r['runCount']==4 and r['completionHVCCount']==0 and r['predictions'][:3]==[17,19,47] and last['syndrome']==0x5a000043 and last['x11']==1 and last['x12']==2 and last['x13']==2 and last['x2']==47 and row['invalidSecondBindingFullPagePrefixValidated'] is True,'second_invalid_binding_exact_partial_prefix')
 summary.append({'test':i,'name':row['name'],'status':r['status'],'vmCreated':not pre,'callbacks':r['callbackCount'],'guestCommitted':r['completedCount'],'entries':r['runCount'],'cleanupComplete':r['cleanupComplete']})
report={'status':'VERIFIED_SIX_MECHANISM_CHECKS' if not failures else 'REVIEW_FAILED','checks':count,'failedChecks':failures,'scope':'Fixed callback fixtures exercised the actual signed ABI 2 bridge. No model, GPU inference, teacher labels or scientific accuracy claim.','controllerPID':ctrl['pid'],'controllerElapsedSeconds':ctrl['elapsed_seconds'],'results':summary,'actualTotals':{'admissions':6,'VMs':3,'vCPURunEntries':12,'callbacks':9,'guestCommittedPredictions':9},'evidence':list(evidence.values()),'limits':['Invalid-second-binding partial memory content is established by the source-bound native full-page comparison and its validated receipt, not a separate dumped guest memory image.','The binary hash records the current signed file; its pre-signing compiler image is separately preserved in build-result.json. Actual executed identity/signature/hypervisor entitlement was inspected by the fixture before every bridge call.','The controller verifies the recorded process group; it does not claim App Sandbox or arbitrary detached-session containment.']}
with (W/'Review/CHECKS-REVIEW.json').open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps({k:report[k] for k in ['status','checks','failedChecks','actualTotals']},indent=2))
raise SystemExit(bool(failures))
