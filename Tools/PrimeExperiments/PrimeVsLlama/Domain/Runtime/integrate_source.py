#!/usr/bin/env python3
"""Integrate the completed domain/geometry experiment into the existing Prime project."""
import hashlib,json,re,shutil,subprocess
from pathlib import Path
w=Path(__file__).resolve().parent;out=w.parents[1]/'outputs/Prime-Experiment-Builds/Prime-Domain-03'
repo=Path('/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging')
parent='0ebff52a6d5c2e983d76b64f8bbea91ea2f64e62'
source=Path('Tools/PrimeExperiments/PrimeVsLlama/Domain');docs=Path('docs/experiments/2026-09-08-prime-domain')
main=Path('Tools/PrimeExperiments/PrimeVsLlama/README.md')
def git(*a):return subprocess.run(['git',*a],cwd=repo,capture_output=True,text=True,check=True).stdout.strip()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(a,b):b.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(a,b)
assert git('rev-parse','HEAD')==parent and not git('diff','--name-only') and not git('diff','--cached','--name-only')
assert not (repo/source).exists() and not (repo/docs).exists()
assert (out/'VERIFICATION.json').exists()
preserved={p:sha(repo/p) for p in git('ls-files','--others','--exclude-standard').splitlines() if (repo/p).is_file()}
# Code and its build provenance belong in Git; model/logit binaries retain local sealed builds.
for folder in ('Native','Guest','Admission','Checks','GeometryMetal'):
 for p in (w/folder).rglob('*'):
  rel=p.relative_to(w/folder)
  if not p.is_file() or any(x in ('Live','module-cache','cache','__pycache__') for x in rel.parts):continue
  if 'build01' in rel.parts:
   if p.name not in ('build-result.json','compile-inputs.json','invocation.json','result.json','admission-compile.json','PrimeGuestImage.h'):continue
   rel=Path(str(rel).replace('build01/','RecordedBuild/',1))
  elif p.suffix not in ('.swift','.c','.h','.py','.S','.md','.json','.plist','.patch','.txt'):continue
  copy(p,repo/source/folder/rel)
for p in w.glob('*.py'):copy(p,repo/source/'Runtime'/p.name)
copy(out/'Runtime/controller.rb',repo/source/'Runtime/controller.rb')
copy(out/'REPLAY-CONFIG.json',repo/source/'REPLAY-CONFIG.json')
for sub in ('Comparison','Generator'):
 for p in (w/sub).glob('*.py'):copy(p,repo/source/sub/p.name)
 for p in (w/sub/'Inputs').glob('*.json'):copy(p,repo/source/sub/'Inputs'/p.name)
 for p in (w/sub).glob('*AUDIT.json'):copy(p,repo/docs/sub/p.name)
# Retain original Python architecture probe and exact source dependencies, not its live output binaries.
for p in (w/'Comparison/PythonParity').rglob('*'):
 if p.is_file() and not any(x.startswith('Live-') or x=='__pycache__' for x in p.relative_to(w/'Comparison/PythonParity').parts):
  copy(p,repo/source/'Comparison/PythonParity'/p.relative_to(w/'Comparison/PythonParity'))
for p in (w/'Review').glob('*.py'):copy(p,repo/source/'Review'/p.name)
for p in (w/'Review').glob('*.json'):copy(p,repo/docs/'Review'/p.name)
for p in (w/'Review').glob('*.md'):copy(p,repo/docs/'Review'/p.name)
for name in ('REPLAY-CONFIG.json','SNAPSHOT-INDEX.json'):
 copy(out/name,repo/docs/name)
for sub in ('Comparison','Generator'):copy(w/sub/'NATIVE-COMPLETE.json',repo/docs/sub/'NATIVE-COMPLETE.json')
def absolute_link(match):
 target=match.group(1)
 if '://' in target or target.startswith(('/', '#')):return match.group(0)
 return ']('+str((out/target).resolve())+')'
(repo/docs/'README.md').write_text(re.sub(r'\]\(([^)\s]+)\)',absolute_link,(out/'README.md').read_text()))
(repo/source/'README.md').write_text('''# Current native Prime domain comparison

ABI2 in Native/ and Guest/ supports two distinct earlier predictions, preserving all16384 output IDs. Native Swift computes on host Metal; the real ARM guest owns feedback. GeometryMetal/ reuses geometry-app’s actual field kernel with bounded finite inputs and explicit GPU completion. These are working experiment components in this same Prime project.

Sealed executable runtime0009, retained checkpoints0010–0012, all generated inputs, raw logits, raw Llama replies and independent reviews are saved at:

'''+str(out)+'''

Replay from that saved directory with `python3 Runtime/replay.py /absolute/fresh/results --seed all --execution both`. Add `--suite generator` for the1024 valid context-variation cases per seed. This requires this Mac’s retained runtime and Metal/Hypervisor access; no training or dependency installation occurs. Git retains source and concise result evidence; large model/logit files remain in the verified local build collection. Source compilation uses the recorded local MLX dependency objects and existing predecessor build paths recorded by the build scripts. Prior VCPU/ source and runtime0008 remain the completed historical ABI1 experiment.
''')
old=(repo/main).read_bytes()
(repo/main).write_text('''# Live Prime experiments

The current completed integration is [Domain](Domain/README.md): native Swift/Metal inference, real ARM vCPU control with two-source prediction feedback, three retained Prime domain-policy checkpoints, a same-input older Llama comparison, a1024-case valid-input generator follow-up, and geometry-app host Metal parity.

Runtime0009 and checkpoint builds0010–0012 are durable local artifacts. Raw model outputs are retained; scoring targets never replace predictions. These experiments use the existing Prime project and do not change the installed Provenance app.

Earlier completed experiment source remains in NativeSwift/ and [VCPU](VCPU/README.md). Their corresponding sealed builds and reports preserve original results. The current results, executable and replay entry point are:

'''+str(out)+'''/README.md

The code establishes inference and feedback behavior. It does not make the finite domain-policy checkpoint a prose chatbot, move model weights into a guest, or change formal gate authority.
''')
expected={str(main)}|{str(p.relative_to(repo)) for d in (source,docs) for p in (repo/d).rglob('*') if p.is_file()}
git('add','--',str(source),str(docs),str(main));assert set(git('diff','--cached','--name-only').splitlines())==expected
git('diff','--cached','--check');git('commit','-m','Run Prime domain checkpoints through two-source guest feedback and compare geometry Metal')
commit=git('rev-parse','HEAD');assert git('rev-parse','HEAD^')==parent
assert not git('diff','--name-only') and not git('diff','--cached','--name-only')
assert all(sha(repo/p)==h for p,h in preserved.items())
bundle=out/'prime-domain-source.bundle';git('bundle','create',str(bundle),parent+'..HEAD');git('bundle','verify',str(bundle))
receipt={'repository':str(repo),'parentCommit':parent,'commit':commit,'committedFiles':[{'path':p,'byteCount':(repo/p).stat().st_size,'sha256':sha(repo/p)} for p in sorted(expected)],
 'previousProjectReadmeSHA256':hashlib.sha256(old).hexdigest(),'preservedUntrackedFiles':preserved,'trackedWorkingTreeClean':True,'pushPerformed':False,
 'modelTrainingPerformed':False,'bundle':{'path':str(bundle),'byteCount':bundle.stat().st_size,'sha256':sha(bundle),'verified':True}}
(out/'SOURCE-INTEGRATION.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({'commit':commit,'files':len(expected),'preservedUntracked':len(preserved),'bundleVerified':True,'pushPerformed':False}))
