# Ergentics Prime

Ergentics Prime is the Ergentics-authored, Swift-first research system for the
native Prime language model, built on licensed MLX/Metal primitives. It is
split out from the PMHNP companion so model execution, evaluation, and
evidence durability can evolve without making a product consumer the
scientific authority.

The current Apple-native training, optimizer-resume, M5 Max, cross-repository,
and product-integration roadmap is recorded in
[`docs/APPLE-NATIVE-LEARNING-PLAN-2026-07-29.md`](docs/APPLE-NATIVE-LEARNING-PLAN-2026-07-29.md).
That plan does not authorize functional training or change PMHNP release
authority.

The implemented-versus-planned authority boundary, Swift-first policy,
narrow audited Python exception criteria, supply-chain requirements, and
open-source readiness conditions are recorded in
[`docs/PRIME-AI-RD-GOVERNANCE.md`](docs/PRIME-AI-RD-GOVERNANCE.md).
Prime remains private and proprietary; that charter does not claim
scientific, clinical, security, regulatory, or federal compliance.
The preserved companion/Lab Metal and quant history, its 55-commit resolution
ledger, and the non-overwrite continuation rule are recorded in
[`docs/PMHNP-METAL-QUANT-ARC-RESOLUTION-2026-07-29.md`](docs/PMHNP-METAL-QUANT-ARC-RESOLUTION-2026-07-29.md).
The typed no-rebuild inventory between Prime, `prime-runtime`, NeuralKit, and
the Lab is recorded in
[`docs/PRIME-NEURALKIT-ARC-CONTINUITY-2026-07-29.md`](docs/PRIME-NEURALKIT-ARC-CONTINUITY-2026-07-29.md).
The exact private-MLX migration sequence, narrow commit-identity rewrite
boundary, recovery anchors, and post-migration evidence gates are recorded in
[`docs/PRIME-PICKUP-PRIVATE-MLX-MIRROR-2026-07-29.md`](docs/PRIME-PICKUP-PRIVATE-MLX-MIRROR-2026-07-29.md).

## Implemented now

- exact maintained `ergentics_prime_native_3b_gqa_v1` geometry;
- random initialization and full FP32 weights;
- explicit initialization, training-schedule, and evaluation controls;
- Swift-native process supervision, mutation gates, and immutable receipts;
- MLX/Metal execution through maintained model, differentiation, optimizer,
  and device primitives.

Prime's current mechanics target uses the same 512-entry model vocabulary as
the existing companion arc. The Swift tokenizer manifest, deterministic
first-party compositional corpus, native training executor, fixed-cap/EOS
evaluation contract, NeuralKit SZ/triadic/mutation gate, and 15-trial profile
screen already exist at the frozen companion revision. They are not yet
migrated into Prime's training authority and do not imply an accepted
checkpoint or functional-language result.

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

The reason no Python mutation waiver exists is concrete: every currently
admitted mutation operator is implemented and executed in Swift. The typed
optimizer gate's structural sweep is deliberately recorded as a same-process
self-check, not as an independent scientific oracle. Later functional claims
still require a disjoint Swift regrader. If a future mutation truly requires
an unavailable Swift primitive, the run remains `ABSTAIN` until that primitive
is implemented or a separately reviewed, mutation-specific exception is
added. There is no general Python fallback.

## AdamW

AdamW is an optimizer algorithm, not a Python component. Prime uses the
maintained `MLXOptimizers.AdamW` implementation from the Swift package.
The pinned `mlx-swift` 0.31.3 implementation intentionally omits first- and
second-moment bias correction. The receipt binds that fact plus learning rate,
betas, epsilon, weight decay, optimizer-state count, dtype, and nonzero norm.
The upstream Swift API does not provide a supported optimizer-state restore
setter. A minimal private Ergentics derivative now adds public, named, typed
Adam/AdamW state export/import without changing the pinned optimizer arithmetic
source. Fork-level tests prove the public API, topology/dtype/shape rejection,
alias isolation, an API-unused trajectory guard, and exact `N+1` continuation.
Revision `68904d54b72871f26968261ae05d4fbb7c5e3142` is available from the
license-preserving private `Ergentics/ergentics-mlx-swift` mirror, and an
authenticated cache-empty clone has resolved it. This does not claim CI
credentialing, public availability, upstream acceptance, or open-source
release.

## Optimizer resume feasibility gate

`PrimeOptimizerRestoreProbe` remains the historical stock-API diagnostic. Its
anonymous state files and `ABSTAIN` receipt are preserved byte-for-byte; they
are not reinterpreted as resumable training. It is not a live gate for the
migrated root: an intentional rerun requires an isolated package pinned to
upstream `mlx-swift` `0.31.3`.

`PrimeTypedOptimizerRestoreProbe` is the new Swift-only spend gate. It uses the
public derivative API and three fresh role processes:

- **control** runs steps `N` and `N+1` without interruption;
- **writer** independently reaches `N`, then publishes immutable model and
  named first/second-moment safetensors;
- **restorer** validates the ordered manifest before dictionary
  materialization, reloads the files, imports model and optimizer state through
  public typed APIs, records restored `N`, and runs `N+1`.

Both a flat model and a nested model with same-shaped sibling tensors must
match exactly at `N` and `N+1`: loss, output, every gradient, every model
parameter, and every first and second moment are compared by evaluated FP32
logical bytes. The mechanics reject zero/nonfinite gradients and require every
model and moment tensor to change at each step. A 19-case same-process
proposal/detector/disposal sweep executes typed-import, trajectory,
ordered-manifest, frozen-plan, seed-domain, logical-byte, and alias-isolation
detectors. Each case binds distinct proposal and detector hashes and records
`independent_scientific_oracle_claimed: false`.

The parent launches workers with an empty environment and stdin bound to EOF,
asynchronously drains and caps both output streams, requires empty output for
success, and observes all three PIDs and clean exits. A timeout uses bounded
SIGTERM/SIGKILL escalation; if termination is not observed, the parent
withholds even the normal `ABSTAIN` receipt. It begins only in a
descriptor-verified empty root, recaptures Prime and dependency source at
closure, and live-verifies every receipt-bound artifact from the private
descriptor-rooted store: worker records, source snapshot, Release executable,
the canonical 1,667-file admitted MLX Swift manifest/source tree, reviewed
dependency evidence, exact metallib and Info.plist, and checkpoint files.
`swift-numerics` remains revision-pinned and incorporated into the executable
identity, but its source tree is not yet a separately frozen receipt artifact;
full transitive build-source closure is therefore not claimed.
Missing or failed evidence produces a separate durable `ABSTAIN` receipt
containing a sanitized reason code and detail hash; it cannot validate as
partial success. No Prime code calls
`innerState`, `_updateInternal`, reflection, a dummy optimizer step, Python, or
a shell to implement or grade this gate.

The CPU tensor lane is intentional: this gate answers an API and serialization
question, not GPU throughput. The maintained MLX scheduler still initializes
its Metal runtime and requires `default.metallib` even when the graph is
CPU-scoped. Prime therefore stages the exact pinned metallib into the
canonical SwiftPM resource bundle, then binds that metallib and the canonical
SwiftPM `Info.plist` under a separate frozen probe runtime role. It does not
reinterpret that loader dependency as GPU tensor execution. The exact 3B FP32
raw checkpoint floor is about 31.52 GiB before manifests and safetensors
headers: 10.51 GiB of model weights and 21.01 GiB of Adam moments.

Run the gate from a Release build with a new, empty mode-0700 artifact root:

```sh
swift build -c release
xcodebuild -downloadComponent MetalToolchain
xcodebuild -scheme PrimeGPUCalibration -configuration Release -destination 'platform=macOS,arch=arm64' -toolchain com.apple.dt.toolchain.Metal.32023.883 -derivedDataPath .build/apple build
.build/arm64-apple-macosx/release/PrimeMLXBundleStage \
  --source-host .build/apple/Build/Products/Release/PrimeGPUCalibration \
  --destination-host .build/arm64-apple-macosx/release/PrimeTypedOptimizerRestoreProbe \
  --runtime-role typed_optimizer_restore_probe
.build/arm64-apple-macosx/release/PrimeTypedOptimizerRestoreProbe \
  --artifact-root /private/tmp/ergentics-prime-typed-optimizer-restore \
  --source-root "$PWD"
```

The artifact root must already exist, be empty, and have mode `0700`.
Exact typed restore exits `0` only after canonical receipt replay succeeds.
After empty-root admission, any preflight, child, mutation, artifact, or
final-validation failure exits `2` and attempts to publish
`prime-typed-optimizer-restore-receipt.v2.json.abstain.json`. Consumers must
verify the canonical receipt and must not collapse process status into a
successful restore. If root emptiness cannot be established or a timed-out
child's termination cannot be observed, normal failure-receipt publication is
withheld to avoid mixing runs or claiming a completed process boundary.

Even an exact CPU result authorizes only one bounded two-step interrupted
Metal continuation canary on the existing exact 3B profile. It authorizes the
temporary full-state checkpoint required by that gate; it does not authorize
a retained functional checkpoint, long training, quantization, product
promotion, or a broad-language claim.

The canonical Release gate bound to private revision
`68904d54b72871f26968261ae05d4fbb7c5e3142` observed exact continuation
across three fresh worker processes for both fixtures and disposed all 19
declared structural mutations. A fresh reissue from Prime source
`6465beb184228f2e6ff03f08d5f5e523210e5d7e` is preserved in full at
`artifacts/typed-optimizer-restore-6465beb-20260729T184600Z` by repository
revision `3481ffc24f3a81a26197fc8625510cab66e6e29b`; its canonical receipt
SHA-256 is
`fafc7d236a8a9b8f857d4a5bd9f34a3ed12012dd061a8a4c984fe85876fb569d`.
Both source revisions are remote-resolvable. This remains optimizer-resume
mechanics, not Metal training or functional evidence.

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
benchmark evidence; it is a stage-time donor only. Its
`mlx-swift_Cmlx.bundle` must contain the 1,130-byte `Info.plist` with SHA-256
`124c82bbfd7fe1ea93aa05b5a50d1e5828759fb268556ed119399212726e6a1e`
and bundle identifier `ergentics-mlx-swift.Cmlx.resources`, plus the
3,817,916-byte `default.metallib` with SHA-256
`24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b`.
`PrimeMLXBundleStage` descriptor-validates a trusted source-host anchor and the
exact donor bundle tree on every invocation, including when the destination
already contains the exact metallib. The unexecuted anchor's executable bytes
are not claimed as donor provenance.

The destination host is the uninstrumented SwiftPM Release executable. Its
resource bundle must already contain the canonical 1,120-byte `Info.plist`
with SHA-256
`62486b35d9253522fe58dba1487d910b3d00d892954558145c553051bd61684d`
and bundle identifier `mlx-swift.Cmlx.resources`. Staging is one-way and
metallib-only: if the destination metallib is absent, Swift publishes the
exact donor metallib with no-replace semantics; if it is already exact, the
operation is idempotent after donor validation; any other existing bytes fail.
The donor `Info.plist` is never copied, normalized, synthesized, or allowed to
overwrite the canonical SwiftPM manifest. Runtime and receipt evidence bind
only the canonical SwiftPM manifest and the shared exact metallib. The
architecture-specific, non-symlink SwiftPM path is intentional:
descriptor-root admission rejects `.build/release`, which is a symlink.
Before staging or execution is admitted, Swift inspects the loaded main
executable through Darwin dyld/Mach-O APIs and rejects LLVM
coverage/profiling segments or sections and known sanitizer runtimes. That
frozen instrumentation policy is configuration- and receipt-bound.
Before any MLX device call, Swift verifies that the canonical runtime bundle
contains only `Contents/Info.plist` and
`Contents/Resources/default.metallib`, checks the frozen identities above,
rejects ACLs, unsafe modes, links, unapproved extended attributes,
loader-shadow metallibs, and forbidden MLX/DYLD/LLVM-profile environment
overrides, then publishes immutable copies into the artifact root. Apple
provenance/build-system attributes are admitted only by the explicitly
declared allowlist. Both canonical runtime files are configuration- and
receipt-bound and are reverified after worker execution before any success or
failure candidate can be published.
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

PrimeCore's complete Swift suite requires the independently built bundle and
does not skip its bundle/receipt tests when that fixture is absent:

```sh
PRIME_TEST_PINNED_MLX_METALLIB=.build/arm64-apple-macosx/release/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib swift test
```

The MLX-linked mechanics tests are a separate Swift package so their required
resource bundle cannot appear as a loader shadow in the PrimeCore security-test
process. Build the isolated test bundle, stage the exact resource with the
compiled Swift utility, then run without rebuilding:

```sh
swift build --product PrimeTypedOptimizerRestoreProbe
swift build --product PrimeMLXTestBundleStage
swift build \
  --package-path Tests/PrimeTypedOptimizerRestoreMechanicsValidation \
  --scratch-path .build \
  --build-tests
.build/arm64-apple-macosx/debug/PrimeMLXTestBundleStage \
  --source-host .build/arm64-apple-macosx/debug/PrimeTypedOptimizerRestoreProbe \
  --destination-resources-root .build/arm64-apple-macosx/debug/PrimeTypedOptimizerRestoreMechanicsValidationPackageTests.xctest/Contents/Resources
swift test \
  --package-path Tests/PrimeTypedOptimizerRestoreMechanicsValidation \
  --scratch-path .build \
  --skip-build
```

The requested 96 GiB MLX memory setting is an MLX scheduler limit, not a claim
that process RSS cannot exceed 96 GiB.
`artifacts/` is intentionally gitignored; successful binary evidence must also
be copied to durable off-device storage before it can authorize a later run.

## Provenance

The initial architecture values and historical evidence were separated from
`Ergentics/pmhnp-companion-ergentics` at commit `163fc10`. Historical reports
remain in that repository; this repository owns new Prime execution.
