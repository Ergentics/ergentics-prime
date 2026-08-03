# Prime durable pickup — decoder authority and secure-child supervision

Status: two isolated feature branches; no pull request is open; exact-head
independent audit remains mandatory for secure-child PR candidacy

Snapshot date: 2026-08-03

Repository: `Ergentics/ergentics-prime`

This document is the restart boundary. It separates the first-party decoder
authority correction from the secure-child supervision candidate. Do not
combine their implementation diffs or infer validation across the branches.

## Durable branch map

| Scope | Branch | Durable checkpoint | Disposition |
| --- | --- | --- | --- |
| First-party decoder authority | `feat/native-decoder-authority-correction` | remote commit `25f6906fa69ed6ecf6e196e319c02d7f82f74d9a`; exact tree `e557c95d59ae1bac2f436914b8b7adc4183390e0` | Focused authority tests pass; reviewable as its own slice |
| Neutral secure-child supervision | `feat/neutral-secure-child-supervision` | remote branch ref is authoritative; rejected first-audit commit `7180526e9ab4dc851faa3c4b3bbd9740a6046443`, exact tree `da3319cd3ee7399f974df8571d4a74e88dbee7c9`, is retained as history | First-audit findings remediated on the later branch head; require an independent audit of that exact head before any pull request |

The decoder correction also exists locally as commit
`a3fdb645a3ea688dbb9c2eb07e30aa7042925f59`. The local and remote commit IDs
differ because GitHub created the durable remote commit, but their tree ID is
identical. The tree identity, not an implied metadata equivalence, proves that
the source bytes are the same.

The secure-child branch includes this handoff and later validation/remediation
commits above the pinned WIP parent. Use the remote branch ref for the current
head; a final head cannot be embedded in its own source tree. Commit `7180526`
is the preserved first-audit target, not authority that its findings were
resolved.

## Corrected decoder authority

The frozen historical Llama mechanics receipt remains immutable evidence for
the experiment it actually ran. It is not the authority for a future Prime
decoder and must not be rewritten, relabeled, or used to select that decoder.

`PrimeNativeDecoderAuthorityPlan.frozenV1` now binds the forward path:

- the historical `MLXLLM.LlamaModel` path is a bounded mechanics comparator;
- only `PrimeGPUCalibration` and
  `PrimeNative3BMetalContinuationProbe` may retain `MLXLLM` imports;
- a future `PrimeNativeDecoder` target is Prime-owned and may depend only on
  `PrimeCore`, `MLX`, and `MLXNN`; a separate trainer may add the typed
  `MLXOptimizers` boundary;
- the first executable conformance profile is the pinned Logic 10M profile;
  the 300M profile remains inventory only and is not authorized to execute;
- the exact first-party architecture donor is
  `Ergentics/ergentics-logic` revision
  `97be84b2790b79ce79558d6bade846a532226540`, source
  `Sources/ModelKit/model.py`, Git blob
  `fcc471205780bf742fb742d70f5d4fdb073b90f216`, SHA-256
  `8e28d1e19b5aea4504af62d5ff11b8d318d77c3e232670b9d8751b0996e264a2`;
- ownership evidence is the same revision's `SEED.md`, Git blob
  `3ed6e27813bf61ca76e3919848ac14f14d4c4c4f`, raw SHA-256
  `e85812acc482d37643c135fd6db8dbfc0007dd5add712ed4407b7076ab978d54`,
  naming `Ergentics, LLC` and `LicenseRef-Ergentics-Proprietary`;
- the donor is source-pinned design evidence, not a runtime dependency;
- MHA-to-GQA adaptation, checkpoint compatibility, Adam-state
  compatibility, functional training, quantization, and product promotion
  remain `ABSTAIN` until separately evidenced;
- old Llama receipt schemas cannot admit evidence for the native decoder.

No Python interpreter, Python command, Python mutation authority, or Python
runtime dependency was introduced or executed by this correction. The pinned
`.py` donor is read-only historical source evidence for an exact first-party
architecture; any Swift implementation must be independently typed and
tested.

Focused validation completed on the exact correction tree:

```sh
env CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache" SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache" swift test --disable-sandbox --scratch-path .build --filter 'PrimeNative(DecoderAuthority|ArcContinuity)Tests'
```

Result: 19 tests, 0 failures. `git diff --check` also passed. The initial
SwiftPM attempt without `--disable-sandbox` was blocked before compilation by
the nested package sandbox in the managed Codex environment; it was not a
code failure. No repository-wide pass is claimed for this authority-only
slice.

## Secure-child supervision truth

The supervision slice extracts neutral child-process mechanics shared by the
native neural gate paths:

- exact-PID wait observation and Darwin process proof;
- checked phase deadlines with a cleanup-only timeline;
- independent memory and file EOF drains;
- non-restorable supervision capability;
- neutral lifecycle and supervision types;
- both existing consumers integrated with the neutral substrate;
- proof-aware live-child obligation fail-stop handling.

The first independent audit rejected exact remote commit `7180526` on four
findings: pre-proof abandonment used process-group authority, its retained test
performed unsafe post-`fork` Swift work and waited without a deadline, the
managed-workspace instructions disabled SwiftPM's frozen sandbox, and this
restart boundary still reported obsolete pre-validation state.

The later branch head remediates those findings without adding a product,
target, dependency, public API, or Driver V2 authority. The spawn handle now
records process-group authority only after the suspended child's SID/PGID proof.
Pre-proof abandonment signals and reaps only the exact PID. The retained test
runs an actual raw-handle abandonment in a separately spawned XCTest role and
bounds both PID reporting and exact-process observation. The commands below
retain SwiftPM's sandbox.

Validation recorded for the remediated exact tree:

- root Debug and Release builds passed;
- Debug lifecycle: 10/10; Debug capture: 10 passes plus the one expected
  Release-only canary skip;
- Release lifecycle: 10/10; Release capture: 11/11, including the live
  two-role canary;
- Release source provenance: 1/1;
- nested Driver V2 Debug: 86 passes plus the one expected Release-only skip;
  nested Driver V2 Release: 87/87; and
- nine-mode Release integration reached
  `PASS modes=9 logical_argv0=PASS one_shot=PASS executable_replacement=REJECTED`;
- the complete root Release aggregate executed 892 XCTest cases with the two
  declared opt-in skips and zero failures, then passed all 12 Swift Testing
  cases; and
- after exact metallib staging, the isolated Ergentics-MLX Release package
  passed 9/9, including the exhaustive corrected-fixture/three-seed lane.

An independent audit must still name and approve the exact final branch head
before it becomes a pull request candidate. That external result is not inferred
from this self-describing tree.

The retained fail-stop regression test is one new required root XCTest case.
The first complete Release aggregate exposed that the earlier 891-entry Driver
V2 resource was therefore stale. This audited secure-child scope explicitly
replaces only that XCTest inventory anchor; the Swift Testing inventory remains
byte-identical:

- XCTest: 892 lines, 114,186 bytes, SHA-256
  `93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b`;
- Swift Testing: 12 lines, 1,287 bytes, SHA-256
  `487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3`.

## Resume order

Start from the secure-child audit-candidate branch in this durable workspace
and preserve both historical checkpoints:

```sh
git fetch origin
git switch wip/neutral-secure-child-supervision-audit-candidate
git status --short --branch
git log --oneline --decorate -3
```

Then proceed in this order:

1. Verify the local and remote candidate refs identify the same exact commit
   and the working tree is clean.
2. Verify the recorded source seal, package-description canary, frozen
   inventories, focused Debug/Release suites, nested Driver V2 checks, and
   nine-mode integration on that exact tree.
3. Obtain an independent final audit naming the exact commit. Only then may
   this branch become a pull request candidate.
4. After the secure-child and Driver V2 boundary is resolved, return to the
   decoder branch. The next model-boundary slice is complete root
   `MLXLLM`/`mlx-swift-lm` quarantine before any `PrimeNativeDecoder` target
   appears. It is not decoder implementation or a training run.

Managed-workspace focused commands:

```sh
env CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache" SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache" swift build --scratch-path .build
env CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache" SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache" swift test --scratch-path .build --filter PrimeNativeNeuralGateSecureChildLifecycleTests
env CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache" SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache" swift test --scratch-path .build --filter PrimeNativeNeuralGateSecureExternalChildCaptureTests
```

If an outer managed executor reports
`sandbox-exec: sandbox_apply: Operation not permitted`, obtain authorization to
run the same CLI command outside that outer sandbox. Do not weaken SwiftPM's
inner sandbox with `--disable-sandbox`.

## Do not

- Do not reset, clean, stash, rebase, squash, or rewrite either checkpoint.
- Do not merge the decoder authority correction into the secure-child WIP.
- Do not open a secure-child pull request while its checkpoint is unverified.
- Do not treat the WIP label, prior test output, or `.build` timestamps as
  validation of the current tree.
- Do not change historical receipt hashes, the replacement 892/12 inventories, or
  the historical Llama experiment to manufacture native-decoder continuity.
- Do not collapse `nil`, `false`, absent evidence, and observed failure into
  one state.
- Do not reset relative deadlines or use saturation to `UInt64.max` as a
  substitute for checked time arithmetic.
- Do not accept caller-supplied generic callbacks as Darwin process proof.
- Do not add Python execution, a Python truth gate, a Python runtime
  dependency, or shell output as scientific authority.
- Do not run model training, quantization, profile promotion, or product
  promotion from either branch.
