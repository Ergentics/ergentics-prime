# Prime durable pickup — decoder authority and secure-child supervision

Status: two isolated feature branches; no pull request is open

Snapshot date: 2026-08-03

Repository: `Ergentics/ergentics-prime`

This document is the restart boundary. It separates the first-party decoder
authority correction from the unfinished secure-child supervision work. Do not
combine their implementation diffs or infer validation across the branches.

## Durable branch map

| Scope | Branch | Durable checkpoint | Disposition |
| --- | --- | --- | --- |
| First-party decoder authority | `feat/native-decoder-authority-correction` | remote commit `25f6906fa69ed6ecf6e196e319c02d7f82f74d9a`; exact tree `e557c95d59ae1bac2f436914b8b7adc4183390e0` | Focused authority tests pass; reviewable as its own slice |
| Neutral secure-child supervision | `feat/neutral-secure-child-supervision` | local WIP commit `463d5a08b327d42d31ffa044efe4d278c9818a2b`; remote WIP parent `87dc5210e76c606bc6a63ecffbba05d27880e844`; exact tree `f19bc4aa6267daff710e4f35dc385dc908267f03` | Explicitly unverified WIP; resume and validate before any pull request |

The decoder correction also exists locally as commit
`a3fdb645a3ea688dbb9c2eb07e30aa7042925f59`. The local and remote commit IDs
differ because GitHub created the durable remote commit, but their tree ID is
identical. The tree identity, not an implied metadata equivalence, proves that
the source bytes are the same.

The secure-child branch head includes this handoff as a documentation-only
commit above the pinned WIP parent. Use the branch ref for the current head;
the final head is intentionally not embedded in its own source tree.

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

## Secure-child WIP truth

The WIP checkpoint extracts neutral child-process mechanics shared by the
native neural gate paths:

- exact-PID wait observation and Darwin process proof;
- checked phase deadlines with a cleanup-only timeline;
- independent memory and file EOF drains;
- non-restorable supervision capability;
- neutral lifecycle and supervision types;
- both existing consumers integrated with the neutral substrate;
- live-child obligation fail-stop handling.

The exact WIP tree has passed only structural checkpoint checks, including
`git diff --check`. It has not earned a current Debug build, focused test
pass, Release build, Release source-provenance proof, live two-role canary,
nested Driver V2 validation, nine-mode live integration, or final independent
audit. Earlier lifecycle and capture test results predate the final WIP tree
and must not be carried forward as current evidence.

Known gaps at pickup:

- add direct retained test evidence for the
  `ownsLiveChildObligation: true` fail-stop path;
- reassess direct `HeldExecutableSnapshot` initialization by mapped-image
  consumers;
- refresh the source seal and package-description canary only after code and
  tests freeze;
- update README/disposition prose after behavior is verified;
- run an independent final audit before opening a pull request.

Frozen test inventories must remain unchanged unless a separately reviewed
scope explicitly replaces them:

- XCTest: 891 lines, 114,060 bytes, SHA-256
  `583056975d443cb9195ab8af6944625833b78b848b0afa2640275811aec3f829`;
- Swift Testing: 12 lines, 1,287 bytes, SHA-256
  `487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3`.

## Resume order

Start from the secure-child branch and preserve the WIP checkpoint:

```sh
git fetch origin
git switch feat/neutral-secure-child-supervision
git status --short --branch
git log --oneline --decorate -3
```

Then proceed in this order:

1. Audit the exact WIP diff against the neutral transport contract and add the
   missing live-child-obligation test.
2. Run the root Debug build and the two focused secure-child suites.
3. Resolve findings without broadening public evidence, products, targets,
   dependencies, or Driver V2 authority.
4. Freeze implementation and tests; then update disposition, README, source
   provenance, source seal, and package-description canary.
5. Run Release build/test and source-provenance proof.
6. Run the live two-role canary, nested Driver V2 Debug/Release checks, and the
   nine-mode Release integration. The expected final line is
   `PASS modes=9 logical_argv0=PASS one_shot=PASS executable_replacement=REJECTED`.
7. Obtain an independent final audit. Only then may this WIP become a pull
   request candidate.
8. After the secure-child and Driver V2 boundary is resolved, return to the
   decoder branch. The next model-boundary slice is complete root
   `MLXLLM`/`mlx-swift-lm` quarantine before any `PrimeNativeDecoder` target
   appears. It is not decoder implementation or a training run.

Managed-workspace focused commands:

```sh
env CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache" SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache" swift build --disable-sandbox --scratch-path .build
env CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache" SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache" swift test --disable-sandbox --scratch-path .build --filter PrimeNativeNeuralGateSecureChildLifecycleTests
env CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache" SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache" swift test --disable-sandbox --scratch-path .build --filter PrimeNativeNeuralGateSecureExternalChildCaptureTests
```

## Do not

- Do not reset, clean, stash, rebase, squash, or rewrite either checkpoint.
- Do not merge the decoder authority correction into the secure-child WIP.
- Do not open a secure-child pull request while its checkpoint is unverified.
- Do not treat the WIP label, prior test output, or `.build` timestamps as
  validation of the current tree.
- Do not change historical receipt hashes, the frozen 891/12 inventories, or
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
