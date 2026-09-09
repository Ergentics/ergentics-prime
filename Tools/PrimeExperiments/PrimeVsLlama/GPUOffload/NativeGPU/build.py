#!/usr/bin/env python3
"""Bounded compile only; no GPU, model, guest, downloads or dependency resolution."""
from pathlib import Path
import hashlib,json,os,signal,subprocess,time,sys
root=Path(__file__).resolve().parent;name=sys.argv[1] if len(sys.argv)==2 else 'build01';assert name in ('build01','build02');out=root/name;os.umask(0o077);out.mkdir(mode=0o700)
def binding(p):
 b=p.read_bytes();return {'path':str(p),'byteCount':len(b),'sha256':hashlib.sha256(b).hexdigest()}
files=[root/n for n in ['main.swift','MetalFieldEvaluator.swift','CPUReference.swift','Bridge.h','build.py']]
files += [root.parent/'GuestCompute'/n for n in ['PrimeGuestCompute.h','PrimeGuestCompute.c','guest.S','build_guest.py','build01/PrimeGuestCompute.o']]
files += [root.parent/'Admission'/n for n in ['PrimeInferenceAdmission.h','PrimeInferenceAdmission.c']]
guest=json.loads((root.parent/'GuestCompute/build01/build-result.json').read_bytes())
for pin in guest['sourceFiles']+[guest['bridgeObject'],guest['image'],guest['generatedHeader']]:
    assert binding(Path(pin['path']))==pin,'guest build binding changed'
before=[binding(p) for p in files]
compiler='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc'
sdk='/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk'
admission=out/'Admission.o'
subprocess.run(['/usr/bin/xcrun','clang','-target','arm64-apple-macosx14.0','-isysroot',sdk,'-std=c11','-O2','-Wall','-Wextra','-Werror','-c',str(root.parent/'Admission/PrimeInferenceAdmission.c'),'-o',str(admission)],check=True,timeout=30)
args=[compiler,str(root/'main.swift'),str(root/'MetalFieldEvaluator.swift'),str(root/'CPUReference.swift'),str(root.parent/'GuestCompute/build01/PrimeGuestCompute.o'),str(admission),'-import-objc-header',str(root/'Bridge.h'),'-framework','Hypervisor','-framework','Security','-framework','CoreFoundation','-parse-as-library','-swift-version','5','-target','arm64-apple-macosx14.0','-sdk',sdk,'-O','-whole-module-optimization','-j2','-num-threads','2','-warnings-as-errors','-module-cache-path',str(out/'module-cache'),'-framework','Metal','-framework','Foundation','-o',str(out/'PrimeGuestGPU')]
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
if (out/'PrimeGuestGPU').exists():receipt['binary']=binding(out/'PrimeGuestGPU')
(out/'build-result.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps({k:receipt[k] for k in ['status','exitCode','inputsUnchanged','stderr']},indent=2))
assert code==0 and not timed and receipt['inputsUnchanged'],'compile failure retained'
