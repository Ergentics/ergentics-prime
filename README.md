# Ergentics Prime

Ergentics Prime is the first-party Swift/MLX/Metal research system for the
native Prime language model. It is split out from the PMHNP companion so model
execution, evaluation, and evidence durability can evolve without making a
product consumer the scientific authority.

## Implemented now

- exact maintained `ergentics_prime_native_3b_gqa_v1` geometry;
- random initialization and full FP32 weights;
- explicit initialization, training-schedule, and evaluation controls;
- Swift-native process supervision, mutation gates, and immutable receipts;
- MLX/Metal execution through maintained model, differentiation, optimizer,
  and device primitives.

The 512-entry profile vocabulary is only a tensor dimension today. A native
tokenizer manifest, deterministic first-party compositional corpus, full
training loop, independent evaluator, statistical battery, and SZ
fingerprinting are planned but are not implemented or claimed by the initial
mechanics slice.

The first GPU action is the frozen
`exact_3b_fp32_allocation_update_probe_b1_s128_a1`: one optimizer step at
batch 1, sequence 128, and accumulation 1. It allocates the exact 3B FP32
model, executes forward/backward, proves nonzero Adam state, and changes model
weights. It is not a language-quality result and does not authorize a long
training run. Larger activation and 4,096-position arms require this measured
memory floor first; “4,096-position” means padded positions per optimizer
step, not a 4,096-token context window.

## Language boundary

Python and shell do not generate, mutate, grade, summarize, or authorize
scientific evidence in this repository. Shell may invoke `swift build`,
`swift test`, or a compiled Swift executable during development; that is
recorded separately from shell scientific authority, which remains false.
Production orchestration launches exact hashed executables directly from
Swift.

The pinned MLX Swift binary contains an upstream CPU-JIT helper that is linked
with `popen`. Prime does not use that helper as scientific authority and the
GPU calibration does not intentionally invoke it, but this first canary does
not include child-process tracing. Receipts therefore disclose the capability
and record dependency-shell execution as unavailable; they do not claim a
mechanically observed `false`.

`PrimeLeaseHolder` is a Swift-only diagnostic used to hold the same
descriptor-anchored lease while the supervisor integration path is tested. It
does not execute MLX, select scientific parameters, or emit model evidence.

The reason no Python mutation waiver exists is concrete: every admitted
mutation operator is implemented and independently replayed in Swift. If a
future mutation truly requires an unavailable Swift primitive, the run remains
`ABSTAIN` until that primitive is implemented or a separately reviewed,
mutation-specific exception is added. There is no general Python fallback.

## AdamW

AdamW is an optimizer algorithm, not a Python component. Prime uses the
maintained `MLXOptimizers.AdamW` implementation from the Swift package.
The pinned `mlx-swift` 0.31.3 implementation intentionally omits first- and
second-moment bias correction. The receipt binds that fact plus learning rate,
betas, epsilon, weight decay, optimizer-state count, dtype, and nonzero norm.
The current upstream Swift API does not provide a supported optimizer-state
restore setter. Long interrupted/resumed training therefore remains
fail-closed until a maintained typed restore API is available and trajectory
identity is proven.

## Optimizer resume feasibility gate

`PrimeOptimizerRestoreProbe` is the Swift-only spend gate in front of any
resumable training work. It runs a deterministic tiny FP32 `MLXNN.Linear`
model and one real maintained `MLXOptimizers.AdamW` step on MLX's CPU device,
then crosses two fresh Swift processes:

- the writer publishes immutable model and optimizer-state safetensors plus
  dtype, shape, logical-byte count, and logical-byte SHA-256 catalogs;
- the verifier reloads both files, proves exact logical tensor equality, and
  restores the model through `Module.update(parameters:verify:)`;
- the supervisor matches both child-reported PIDs to the exact `Process`
  instances it launched, binds both child records, and publishes the final
  receipt from their durable CPU-device observations.

The gate binds the exact `mlx-swift` 0.31.3 revision and audited API-source
hashes, including the nested flattening implementation that defines anonymous
optimizer-slot order. It also binds the complete admitted Prime Swift source
snapshot to the embedded Release source identity. It never calls
`_updateInternal`, uses reflection, or substitutes a Prime-written AdamW
equation. With the pinned stock package, model restore and optimizer-state
serialization can be grounded, but optimizer restore and continued-trajectory
identity remain `ABSTAIN` because no supported typed state setter exists.
That result does not authorize a 3B checkpoint write or long training.

The CPU tensor lane is intentional: this gate answers an API and serialization
question, not GPU throughput. The maintained MLX scheduler still initializes
its Metal runtime and requires `default.metallib` even when the graph is
CPU-scoped. Prime therefore stages and binds the same exact pinned metallib and
Info.plist under a separate frozen probe runtime role; it does not reinterpret
that loader dependency as GPU tensor execution. The exact 3B FP32 raw
checkpoint floor is about 31.52 GiB before manifests and safetensors headers:
10.51 GiB of model weights and 21.01 GiB of Adam moments.

Run the gate from a Release build with a new, empty mode-0700 artifact root:

```sh
swift build -c release
xcodebuild -downloadComponent MetalToolchain
xcodebuild -scheme PrimeGPUCalibration -configuration Release -destination 'platform=macOS,arch=arm64' -toolchain com.apple.dt.toolchain.Metal.32023.883 -derivedDataPath .build/apple build
.build/arm64-apple-macosx/release/PrimeMLXBundleStage \
  --source-host .build/apple/Build/Products/Release/PrimeGPUCalibration \
  --destination-host .build/arm64-apple-macosx/release/PrimeOptimizerRestoreProbe \
  --runtime-role optimizer_restore_probe
.build/arm64-apple-macosx/release/PrimeOptimizerRestoreProbe \
  --artifact-root /private/tmp/ergentics-prime-optimizer-restore \
  --source-root "$PWD"
```

An evidence-backed API-limit `ABSTAIN` intentionally exits with status `2`
after publishing the receipt; status `0` is never a parent-gate success signal.
Preflight, child, or artifact failures exit with status `1` and do not
authorize training. Consumers must verify the canonical receipt rather than
collapsing either nonzero status into a successful restore.

## Initial calibration

The executable accepts paths and the explicit human allocation authorization;
scientific knobs are frozen in the canonical Swift configuration:

```sh
swift build -c release
xcodebuild -downloadComponent MetalToolchain
xcodebuild -scheme PrimeGPUCalibration -configuration Release -destination 'platform=macOS,arch=arm64' -toolchain com.apple.dt.toolchain.Metal.32023.883 -derivedDataPath .build/apple build
.build/arm64-apple-macosx/release/PrimeMLXBundleStage \
  --source-host .build/apple/Build/Products/Release/PrimeGPUCalibration \
  --destination-host .build/arm64-apple-macosx/release/PrimeGPUCalibration \
  --runtime-role calibration
.build/arm64-apple-macosx/release/PrimeGPUCalibration \
  --artifact-root /private/tmp/ergentics-prime-calibration \
  --source-root "$PWD" \
  --historical-evidence-root /path/to/pmhnp-companion-ergentics \
  --lease-file /private/tmp/ergentics-prime-metal/prime-metal.lock \
  --authorize-gpu-allocation true
```

Both the artifact root and lease parent must already be private directories.
The embedded source identity must be regenerated after any admitted source
change; a debug, stale, or source-divergent executable fails before Metal.
The Xcode host in the staging command is never executed and is not admitted as
benchmark evidence; Xcode is used only to build the official package resource.
`PrimeMLXBundleStage` validates that resource against the independently
reproduced identities and places it beside the uninstrumented SwiftPM Release
host. The architecture-specific, non-symlink SwiftPM path is intentional:
descriptor-root admission rejects `.build/release`, which is a symlink.
Before staging or execution is admitted, Swift inspects the loaded main
executable through Darwin dyld/Mach-O APIs and rejects LLVM
coverage/profiling segments or sections and known sanitizer runtimes. That
frozen instrumentation policy is configuration- and receipt-bound.
The uninstrumented SwiftPM release host must have the independently reproduced
Xcode Release `mlx-swift_Cmlx.bundle` as an exact sibling. Before any MLX
device call, Swift verifies that the bundle contains only `Contents/Info.plist`
and `Contents/Resources/default.metallib`, checks their frozen byte counts and
SHA-256 values for mlx-swift 0.31.3, rejects ACLs, unsafe modes, links,
unapproved extended attributes, loader-shadow metallibs, and forbidden
MLX/DYLD/LLVM-profile environment overrides, then publishes immutable copies
into the artifact root. Apple provenance/build-system attributes are admitted
only by the explicitly declared allowlist. Both files
are configuration- and receipt-bound and are reverified after worker execution
before any success or failure candidate can be published.
The executable imports and independently verifies the three exact historical
seed records before it acquires Metal. It then self-snapshots the complete
Swift source and executable, publishes configuration and evidence with
descriptor-anchored no-replace semantics, and emits a canonical receipt.
The release executable is also a Swift supervisor: it launches the same
release binary from the artifact root beside the exact staged bundle, without
a shell. It applies a hard end-to-end timeout, verifies the worker receipt, and
publishes a distinct `ABSTAIN` receipt if the worker terminates through a
signal, process-level allocation failure, or other fatal path before it can
write one. Missing worker observations remain unavailable rather than being
rewritten as `false`.

Loader authority is process-scoped. The staged worker checks its own live
Bundle/framework search context, working directory, environment,
instrumentation, executable, and sibling bundle before and after MLX work.
After that process exits, the supervisor does not reinterpret its own loaded
bundles as child state. It independently verifies the staged executable
binding, the three target-local alternate loader paths, and the complete
immutable sibling-bundle tree before finalizing either `GROUNDED` or
`ABSTAIN`.

The current filesystem claim is deliberately bounded. Mode, ownership,
descriptor, tree, hash, loader-shadow, environment, and pre/post checks protect
against accidental and persistent mutation. The artifact root remains owned
and writable by the invoking account so receipts can be published. This does
not prove resistance to a malicious process running concurrently as that same
user that swaps and restores bytes between checks. That stronger claim would
require a separately isolated identity or an upstream loader-return
attestation that MLX Swift does not currently expose.

The complete Swift test suite requires the independently built bundle and does
not skip its bundle/receipt tests when that fixture is absent:

```sh
PRIME_TEST_PINNED_MLX_METALLIB=.build/apple/Build/Products/Release/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib swift test
```

The requested 96 GiB MLX memory setting is an MLX scheduler limit, not a claim
that process RSS cannot exceed 96 GiB.
`artifacts/` is intentionally gitignored; successful binary evidence must also
be copied to durable off-device storage before it can authorize a later run.

## Provenance

The initial architecture values and historical evidence were separated from
`Ergentics/pmhnp-companion-ergentics` at commit `163fc10`. Historical reports
remain in that repository; this repository owns new Prime execution.
