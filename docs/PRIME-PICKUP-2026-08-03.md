# Prime durable pickup — Driver V2, decoder authority, and secure-child history

Status: secure-child supervision is independently audited and merged through
PR 52; Driver V2 supervisor-image work is isolated on a new branch; decoder
authority remains isolated and unchanged

Snapshot date: 2026-08-03

Repository: `Ergentics/ergentics-prime`

This document is the restart boundary. It separates the first-party decoder
authority correction, merged secure-child supervision evidence, and current
Driver V2 work. Do not combine their implementation diffs or infer validation
across the branches.

## Durable branch map

| Scope | Branch | Durable checkpoint | Disposition |
| --- | --- | --- | --- |
| First-party decoder authority | `feat/native-decoder-authority-correction` | remote commit `25f6906fa69ed6ecf6e196e319c02d7f82f74d9a`; exact tree `e557c95d59ae1bac2f436914b8b7adc4183390e0` | Focused authority tests pass; reviewable as its own slice |
| Neutral secure-child supervision | `feat/neutral-secure-child-supervision` | audited remote head `4be3bdb9eb768e0617851cf22c2d67f677025001`, tree `1421c77105240be361e36e2f52d9626ad8e9ca98`; merged to `main` by PR 52 as merge commit `7d5b2a7f0dbfb6bc7c5ae44aa8fb3c7b444dd6f6` | Complete and preserved; source branch remains retained |
| Driver V2 supervisor image | `wip/prime-validation-driver-v2-evidence-completion` | branched from merged `main` commit `7d5b2a7`; final implementation head cannot be embedded in its own tree | Current isolated pre-execution work; exact-head validation and independent audit required before publication |

The decoder correction also exists locally as commit
`a3fdb645a3ea688dbb9c2eb07e30aa7042925f59`. The local and remote commit IDs
differ because GitHub created the durable remote commit, but their tree ID is
identical. The tree identity, not an implied metadata equivalence, proves that
the source bytes are the same.

The rejected secure-child first-audit commit `7180526` remains preserved in
history. Its findings were remediated at exact head `4be3bdb`, independently
audited CLEAN, and merged without squash or source-branch deletion. The Driver
branch starts from that merge and must not move either historical ref.

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

Historical evidence record only: the exact decoder-correction tree previously
ran the `PrimeNative(DecoderAuthority|ArcContinuity)Tests` filter under an
older managed-workspace sandbox bypass. That invocation predates the frozen
no-weakening boundary and is not an authorized restart command. Do not repeat
it with `--disable-sandbox`; current validation must retain SwiftPM's sandbox
and use outer managed-workspace permission when required.

The recorded historical result was 19 tests, 0 failures, and
`git diff --check` passed. The earlier managed nested-sandbox failure occurred
before compilation and was not a code failure. No repository-wide pass is
claimed for that authority-only slice, and no validation claim transfers from
it to the current Driver branch.

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

An independent final audit named exact secure-child head `4be3bdb` CLEAN before
PR 52 was opened and merged. The merge commit has the exact audited tree and
retains `4be3bdb` as its second parent; this document does not transfer that
audit to later Driver or decoder changes.

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

Start from the isolated Driver branch in this durable workspace and preserve
all historical checkpoints:

```sh
git fetch origin
git switch wip/prime-validation-driver-v2-evidence-completion
git status --short --branch
git log --oneline --decorate -3
```

Then proceed in this order:

1. Finish only the Driver V2 supervisor-image boundary: exact current-image
   handoff, package-scoped bridge, and root executable canary. Do not run a
   Git/Swift child or mint a positive repository receipt in this slice.
2. Verify two disjoint Release builds are byte-identical, run both binaries
   directly against fresh private roots, verify the MLX-free target and binary
   linkage closure, and reseal source/package-description evidence.
3. Verify the frozen 892/12 resources remain byte-identical, then obtain an
   independent final audit naming the exact Driver commit before publication.
4. The next Driver slice must add canonical held Prime/companion tracked-tree
   manifests plus one gapless source window before any fixed Git/Swift probe.
5. After the Driver V2 evidence boundary is resolved, return to the decoder
   branch. The next model-boundary slice is complete root
   `MLXLLM`/`mlx-swift-lm` quarantine before any `PrimeNativeDecoder` target
   appears. Logic 10M is the first native conformance boundary; it is not
   authorization for 300M/3B/10B execution, quantization, training, or release.

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
- Do not merge the decoder authority correction into Driver V2 work.
- Do not rewrite, squash, delete, or repoint the audited secure-child refs.
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
