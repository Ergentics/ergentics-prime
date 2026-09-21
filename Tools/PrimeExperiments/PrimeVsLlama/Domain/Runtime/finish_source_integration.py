#!/usr/bin/env python3
"""Finish the prepared source commit, preserving verbatim patch/extract whitespace."""
import hashlib,json,shutil,subprocess
from pathlib import Path
w=Path(__file__).resolve().parent;out=w.parents[1]/'outputs/Prime-Experiment-Builds/Prime-Domain-03'
repo=Path('/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging')
parent='0ebff52a6d5c2e983d76b64f8bbea91ea2f64e62';source=Path('Tools/PrimeExperiments/PrimeVsLlama/Domain');docs=Path('docs/experiments/2026-09-08-prime-domain');main=Path('Tools/PrimeExperiments/PrimeVsLlama/README.md')
def git(*a):return subprocess.run(['git',*a],cwd=repo,capture_output=True,text=True,check=True).stdout.strip()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert git('rev-parse','HEAD')==parent and not git('diff','--name-only')
prior=json.loads((out.parent/'Prime-vCPU-02/SOURCE-INTEGRATION.json').read_bytes());preserved=prior['preservedUntrackedFiles']
assert all(sha(repo/p)==h for p,h in preserved.items())
expected={str(main)}|{str(p.relative_to(repo)) for d in (source,docs) for p in (repo/d).rglob('*') if p.is_file()}
assert set(git('diff','--cached','--name-only').splitlines())==expected
exceptions=[]
for rel in ('GeometryMetal/ADAPTER.patch','GeometryMetal/Original/FieldPotential.functions.swift.txt'):
 original=out/rel;copied=repo/source/rel;assert copied.read_bytes()==original.read_bytes()
 exceptions.append({'path':str(source/rel),'sha256':sha(copied),'reason':'Verbatim retained patch context/extracted source; trailing blank-line whitespace is original evidence, not a source edit.'})
# The original check stopped before commit only on these exact retained evidence files.
git('diff','--cached','--check','--','.',*[f":(exclude){e['path']}" for e in exceptions])
helper=source/'Runtime/finish_source_integration.py';shutil.copy2(Path(__file__),repo/helper);git('add','--',str(helper));expected.add(str(helper))
assert set(git('diff','--cached','--name-only').splitlines())==expected
old=subprocess.run(['git','show',parent+':'+str(main)],cwd=repo,capture_output=True,check=True).stdout
git('commit','-m','Run Prime domain checkpoints through two-source guest feedback and compare geometry Metal')
commit=git('rev-parse','HEAD');assert git('rev-parse','HEAD^')==parent
assert not git('diff','--name-only') and not git('diff','--cached','--name-only')
assert all(sha(repo/p)==h for p,h in preserved.items())
bundle=out/'prime-domain-source.bundle';git('bundle','create',str(bundle),parent+'..HEAD');git('bundle','verify',str(bundle))
receipt={'repository':str(repo),'parentCommit':parent,'commit':commit,
 'committedFiles':[{'path':p,'byteCount':(repo/p).stat().st_size,'sha256':sha(repo/p)} for p in sorted(expected)],
 'previousProjectReadmeSHA256':hashlib.sha256(old).hexdigest(),'preservedUntrackedFiles':preserved,'trackedWorkingTreeClean':True,
 'whitespaceCheckVerbatimEvidenceExceptions':exceptions,'remainingSourceWhitespaceCheckPassed':True,
 'pushPerformed':False,'modelTrainingPerformed':False,
 'bundle':{'path':str(bundle),'byteCount':bundle.stat().st_size,'sha256':sha(bundle),'verified':True}}
(out/'SOURCE-INTEGRATION.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({'commit':commit,'files':len(expected),'preservedUntracked':len(preserved),'bundleVerified':True,'pushPerformed':False}))
