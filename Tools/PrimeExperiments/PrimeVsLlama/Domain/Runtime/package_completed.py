#!/usr/bin/env python3
"""Save the completed experiment without changing prior sealed model/runtime builds."""
from pathlib import Path
import hashlib,json,shutil
w=Path(__file__).resolve().parent;collection=w.parents[1]/'outputs/Prime-Experiment-Builds'
out=collection/'Prime-Domain-03';runtime=collection/'0009-prime-domain-feedback-runtime'
def write(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def pin(p,base):return {'path':str(p.relative_to(base)),'byteCount':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
def copy(a,b):b.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(a,b)
def tree(a,b):
 shutil.copytree(a,b,ignore=shutil.ignore_patterns('module-cache','cache','__pycache__','*.pyc'))
assert not out.exists() and not runtime.exists()
assert (w/'Review/NATIVE-NUMERICAL-REVIEW.json').exists() and (w/'Review/LLAMA-REVIEW.json').exists()
assert (w/'Review/GENERATOR-NUMERICAL-REVIEW.json').exists() and (w/'Review/CHECKS-REVIEW.json').exists()
assert (w/'GeometryMetal/Live/native/result.json').exists() and (w/'Checks/Live/controller/result.json').exists()
old=json.loads((collection/'BUILD-INDEX.json').read_bytes());assert len(old['builds'])==8
old_bytes=(collection/'BUILD-INDEX.json').read_bytes()
for entry in old['builds']:
 p=collection/entry['directory']/entry['fileManifest']['path']
 assert pin(p,p.parent)==entry['fileManifest']
runtime.mkdir();(runtime/'Runtime').mkdir()
for n in ('PrimeVCPUInference','mlx.metallib'):copy(w/'Native/build01'/n,runtime/'Runtime'/n)
for n in ('Native','Admission','Guest'):tree(w/n,runtime/'Source'/n)
out.mkdir();tree(w/'Comparison',out/'Comparison')
for n in ('GeometryMetal','Checks','Review'):tree(w/n,out/n)
if (w/'Generator').exists():tree(w/'Generator',out/'Generator')
(out/'Runtime').mkdir()
for p in w.glob('*.py'):copy(p,out/'Runtime'/p.name)
copy(collection/'Prime-vCPU-02/Runtime/controller.rb',out/'Runtime/controller.rb')
copy(collection/'Prime-vCPU-02/Runtime/verify_snapshot.py',out/'Runtime/verify_snapshot.py')
copy(w/'geometry-metal-review.json',out/'geometry-metal-review.json')
copy(w/'README.md',out/'README.md')
copy(w/'REPLAY-CONFIG.json',out/'REPLAY-CONFIG.json')
write(runtime/'BUILD.json',{'buildID':'EPM-20260908-0009-prime-domain-feedback-runtime','kind':'runtime_not_new_checkpoint',
 'status':'live_verified','abiVersion':2,'binary':pin(runtime/'Runtime/PrimeVCPUInference',runtime),
 'compute':'native Swift MLX on host Metal','control':'host baseline or actual ARM vCPU guest with two earlier prediction bindings',
 'weightsInGuest':False,'newTraining':False,'installedAppReplaced':False,'results':str(out)})
(runtime/'README.md').write_text('Native Prime feedback runtime ABI2. Keep Runtime/PrimeVCPUInference beside Runtime/mlx.metallib. Invoke with --request ABS_JSON --output-directory ABS_FRESH_DIR. Request execution is host or guest; both compute real model logits using host Swift/Metal. Guest mode performs ARM vCPU feedback from two earlier committed predictions. This experiment runtime is separate from Provenance app build numbers. Full comparison: ../Prime-Domain-03/README.md.\n')
builds=[runtime]
models=json.loads((w/'Comparison/References/model-bindings.json').read_bytes())
# Source paths and expected identities are independently present in every original request.
for number,seed in enumerate((1618,2718,3141),10):
 req=json.loads((w/f'Comparison/Requests/seed-{seed}/host/batch-000.json').read_bytes())
 src=Path(req['weightsPath']);dest=collection/f'{number:04d}-prime-domain-seed{seed}'
 assert not dest.exists();dest.mkdir();copy(src,dest/'Runtime/prime-domain-trace.safetensors')
 weight=pin(dest/'Runtime/prime-domain-trace.safetensors',dest)
 assert weight['sha256']==req['weightsSHA256']
 copy(w/f'Comparison/References/original-report-seed-{seed}.json',dest/'References/original-report.json')
 write(dest/'BUILD.json',{'buildID':f'EPM-20260908-{number:04d}-prime-domain-seed{seed}',
 'kind':'retained_checkpoint_copy_not_new_training','seed':seed,'originalPath':str(src),'weights':weight,
 'parameterCount':10227968,'tensorCount':74,'vocabularySize':16384,'language':'ergentics_prime_engine_domain_trace_v1',
 'newTraining':False,'runtime':str(runtime/'Runtime/PrimeVCPUInference'),'comparison':str(out)})
 (dest/'README.md').write_text(f'Retained first-party Prime domain-policy checkpoint, seed {seed}. Exact original weights are saved in Runtime, with original report in References. This is a symbolic domain-policy model, not a prose chatbot or new training run. Use runtime0009 with hash-bound input-only requests.\n')
 builds.append(dest)
snapshots=[]
for base in builds+[out]:
 name='FILE-MANIFEST.json' if base==out else 'file-manifest.json'
 excluded={name,'SNAPSHOT-INDEX.json','VERIFICATION.json','SOURCE-INTEGRATION.json','prime-domain-source.bundle'}
 files=[]
 for p in sorted(base.rglob('*')):
  assert not p.is_symlink(),str(p)
  if p.is_file() and str(p.relative_to(base)) not in excluded:files.append(pin(p,base))
 write(base/name,{'schema':'prime_saved_files_v1','files':files})
 snapshots.append({'directory':'.' if base==out else '../'+base.name,'manifest':pin(base/name,base),'fileCount':len(files),'byteCount':sum(x['byteCount'] for x in files)})
write(out/'SNAPSHOT-INDEX.json',{'snapshots':snapshots,'scope':'Runtime0009, three retained domain checkpoints and actual host/guest/Llama/geometry comparisons',
 'excludedUnsealedAdministrativeFiles':['SNAPSHOT-INDEX.json','VERIFICATION.json','SOURCE-INTEGRATION.json','prime-domain-source.bundle']})
copy(collection/'BUILD-INDEX.json',collection/'BUILD-INDEX.before-domain.json');copy(collection/'README.md',collection/'README.before-domain.md')
for b,s in zip(builds,snapshots):
 meta=json.loads((b/'BUILD.json').read_bytes());old['builds'].append({'directory':b.name,'buildID':meta['buildID'],'kind':meta['kind'],'fileManifest':s['manifest'],'fileCount':s['fileCount'],'bytes':s['byteCount']})
old['primarySystemComparison']='Live domain policy predictions across native host and guest feedback, retained Llama comparison, and independent geometry host-Metal parity.'
old['domainComparison']={'directory':out.name,'snapshotIndex':pin(out/'SNAPSHOT-INDEX.json',collection),'newTraining':False}
write(collection/'BUILD-INDEX.json',old)
(collection/'README.md').write_text('# Durable Ergentics experiments\n\n[Current domain comparison, generator follow-up and geometry Metal results](Prime-Domain-03/README.md). Saved runtime0009 adds two-source guest feedback; builds0010–0012 preserve the original domain checkpoints.\n\nEarlier work remains sealed: [vCPU comparison02](Prime-vCPU-02/README.md), [Prime versus Llama01](Prime-v-Llama-01/README.md), and [expanded shared questions](Expanded-01/README.md). [Build index](BUILD-INDEX.json).\n\nThese are local experiment builds. Installed Provenance Build22 remains unchanged.\n')
assert json.loads(old_bytes)['builds']==old['builds'][:8]
print(json.dumps({'status':'sealed','savedBuilds':[b.name for b in builds],'files':sum(s['fileCount'] for s in snapshots)}))
