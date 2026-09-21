#!/usr/bin/env python3
"""Bounded compile only; no GPU, model, guest, downloads or dependency resolution."""
from pathlib import Path
import hashlib,json,os,signal,subprocess,time
root=Path(__file__).resolve().parent;out=root/'build01';os.umask(0o077);out.mkdir(mode=0o700)
def binding(p):
 b=p.read_bytes();return {'path':str(p),'byteCount':len(b),'sha256':hashlib.sha256(b).hexdigest()}
files=[root/n for n in ['main.swift','MetalFieldEvaluator.swift','CPUReference.swift','PROVENANCE.json','ADAPTER.patch','Original/MetalFieldEvaluator.swift','Original/FieldPotential.functions.swift.txt','build.py']]
before=[binding(p) for p in files]
compiler='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc'
sdk='/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk'
args=[compiler,str(root/'main.swift'),str(root/'MetalFieldEvaluator.swift'),str(root/'CPUReference.swift'),'-parse-as-library','-swift-version','5','-target','arm64-apple-macosx14.0','-sdk',sdk,'-O','-whole-module-optimization','-j2','-num-threads','2','-warnings-as-errors','-module-cache-path',str(out/'module-cache'),'-framework','Metal','-framework','Foundation','-o',str(out/'GeometryMetalComparison')]
env={'PATH':'/usr/bin:/bin:/usr/sbin:/sbin','HOME':str(out),'TMPDIR':str(out),'LANG':'C','LC_ALL':'C'}
(out/'invocation.json').write_text(json.dumps({'argv':args,'environment':env,'compilerThreads':2,'timeoutSeconds':60,'GPUExecution':False},indent=2)+'\n')
start=time.monotonic_ns();timed=False
with (out/'stdout.log').open('xb') as stdout,(out/'stderr.log').open('xb') as stderr:
 child=subprocess.Popen(args,cwd=root,env=env,stdin=subprocess.DEVNULL,stdout=stdout,stderr=stderr,start_new_session=True)
 try:code=child.wait(timeout=60)
 except subprocess.TimeoutExpired:
  timed=True
  try:os.killpg(child.pid,signal.SIGKILL)
  except ProcessLookupError:pass
  code=child.wait()
receipt={'status':'COMPILED_NOT_EXECUTED' if code==0 and not timed else 'COMPILE_FAILED','processID':child.pid,'exitCode':code,'exactDirectChildReaped':True,'timedOut':timed,'elapsedNanoseconds':time.monotonic_ns()-start,'inputs':before,'inputsUnchanged':before==[binding(p) for p in files],'stdout':binding(out/'stdout.log'),'stderr':binding(out/'stderr.log'),'modelRuns':0,'guestRuns':0,'GPUExecutions':0}
if (out/'GeometryMetalComparison').exists():receipt['binary']=binding(out/'GeometryMetalComparison')
(out/'build-result.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps({k:receipt[k] for k in ['status','exitCode','inputsUnchanged','stderr']},indent=2))
assert code==0 and not timed and receipt['inputsUnchanged'],'compile failure retained'
