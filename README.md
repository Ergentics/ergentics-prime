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
The narrow post-Phase-2 companion-blob resolver boundary is recorded in
[`docs/PRIME-NATIVE-CONTRACT-RESOLVER-2026-07-29.md`](docs/PRIME-NATIVE-CONTRACT-RESOLVER-2026-07-29.md).
The bounded Swift compatibility adapter over that frozen resolver output is
recorded in
[`docs/PRIME-NATIVE-CONTRACT-COMPATIBILITY-2026-07-30.md`](docs/PRIME-NATIVE-CONTRACT-COMPATIBILITY-2026-07-30.md).
The corrected source-pinned tokenizer/corpus transplant, exact eight-split
goldens, same-implementation regrade limitation, and receipt-last
fresh-process replay protocol are recorded in
[`docs/PRIME-NATIVE-FULL-CORPUS-REPLAY-2026-07-30.md`](docs/PRIME-NATIVE-FULL-CORPUS-REPLAY-2026-07-30.md).
The bounded NeuralKit gate source projection, exact ten-leg and 46-mutation
catalog, count-label correction, and Stage-A/Stage-B truth boundary are
recorded in
[`docs/PRIME-NATIVE-NEURAL-GATE-CONTRACT-PROJECTION-2026-07-30.md`](docs/PRIME-NATIVE-NEURAL-GATE-CONTRACT-PROJECTION-2026-07-30.md).
The forward-audited Stage-B execution contract, historical target-data leak,
dual replay arms, exact invariant serialization, and direct/accelerated
fingerprint boundary are recorded in
[`docs/PRIME-NATIVE-NEURAL-GATE-FIXTURE-REPLAY-PLAN-2026-07-30.md`](docs/PRIME-NATIVE-NEURAL-GATE-FIXTURE-REPLAY-PLAN-2026-07-30.md).
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
the existing companion arc. Prime now contains an exact isolated Swift
tokenizer/corpus transplant that regenerated and embedded-regraded all
155,648 rows, plus standalone source-pinned projections of the fixed-cap/EOS
generation boundary and NeuralKit's native-language gate contract. The gate
projection preserves its ten ordered critical-leg identifiers, 46 mutation
contracts, guarded target-token-weighted statistics, fixed-prompt
runner-up-margin predicate, finite-field mechanics, selected capability
thresholds, and stronger all-critical rule. It does not yet reconstruct the
unpublished 59,497 historical invariant records or execute those 46 semantic
mutations. None of these contract/mechanics results implies an accepted
checkpoint or functional-language result.

The first GPU action was the frozen
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

## Exact 3B interrupted Metal continuation

`PrimeNative3BMetalContinuationProbe` is the single bounded follow-on to the
typed CPU restore gate. It creates the exact 2,820,320,256-parameter Prime
profile from deterministic random initialization with the maintained MLX Swift
Llama implementation, runs AdamW step 1 and step 2 in one fresh Metal worker,
then independently repeats step 1, saves model plus both typed Adam moment
families through descriptor-backed safetensors, restores them into a poisoned
fresh process, and runs step 2 again. It downloads or loads no pretrained
weights, tokenizer, corpus, adapter, or external model artifact.

The parent admits checkpoint publication only after the control and writer
step-1 state match exactly. `PASS` requires exact tensor-byte catalogs and
fixed-logit equality before save, immediately after restore, and after the
continued step. Parent-observed worker role, PID, exit status, bounded output,
and record identity are receipt-bound. A mismatch or incomplete process
boundary produces `ABSTAIN`; it does not select a profile or authorize
training, quantization, language claims, or product use.

The first sealed run at commit `4507fe6` correctly produced `ABSTAIN`: its
random generator sampled with replacement, exposing the tied embedding to
repeated-ID contention, and the only control/writer divergence was
`model.embed_tokens.weight`. MLX's maintained gather backward uses
floating-point Metal scatter accumulation at that locus. The receipt localizes
the first divergence but does not contain raw tokens or by itself prove kernel
causality. Its canonical structural-replay receipt is archived under
`artifacts/native-3b-metal-continuation-4507fe629a4f-20260730T040459Z/` with
SHA-256
`da888aea4eed5445efc1f5c75f4d209629922fee4b790790d36fe5c2503e75fc`.
The receipt is not a complete artifact root and cannot satisfy descriptor
replay without the intentionally omitted local executable and bound files.

The mechanics gate now uses a seed-bound odd-stride modular schedule with 128
distinct IDs from its 256-token synthetic domain. It fails closed unless every
training input is collision-free. This removes the observed atomic contention
without changing the exact 3B tied-Llama topology, AdamW, Metal execution,
process interruption, or exact comparisons. The passing result proves only
the declared collision-free synthetic continuation mechanics; arbitrary
repeated-token training determinism remains unresolved.

The next sealed attempt at commit `5477d27` admitted the control and writer and
published all three exact checkpoint components, then failed closed in the
restorer. Two independent Swift diagnostics localized the causes. MLX 0.31.3
does not implement descriptor-backed `Load` on Metal, so immutable checkpoint
bytes are now materialized and verified through its maintained CPU load stream
before the model and optimizer continue on Metal. The loaded moment trees also
lose parameterless module containers during flat safetensor serialization.
Ergentics MLX PR 2, merged as
`d37885a278f1c37484a94d0f401a418735e66519`, keeps exact path, shape, and
dtype admission and rebuilds optimizer storage in the target model topology.
A retained-checkpoint replay passed model and moment loading, typed rebinding,
and a real GPU forward/backward/AdamW step. That replay is feasibility
diagnosis, not an authoritative continuation receipt.

The source-sealed run at Prime commit
`7c3989bd0e448eddf3b8b8b87d83c90f518a7d0c` then passed the exact declared
step-1 and step-2 comparisons across three fresh workers. Its canonical
receipt SHA-256 is
`2943fd00df212df597dc85f7a70bfb779933bb75751fbdd772f9a26cbe2efe1e`.
The receipt is repository- and off-device-durable. The complete approximately
32 GiB descriptor-backed checkpoint/runtime root remains local-only, so a
later checkpoint-consuming action still requires separate off-device
durability. This `PASS` closes only the collision-free, random-initialized
Phase 2 continuation-mechanics gate.

Run only from a source-sealed Release build. The artifact root and the parent
directory of the Metal lease file must be separate, empty/private as
applicable, precreated directories with mode `0700`:

```sh
swift build -c release
xcodebuild -downloadComponent MetalToolchain
xcodebuild -scheme PrimeGPUCalibration -configuration Release -destination 'platform=macOS,arch=arm64' -toolchain com.apple.dt.toolchain.Metal.32023.883 -derivedDataPath .build/apple build
.build/arm64-apple-macosx/release/PrimeMLXBundleStage \
  --source-host .build/apple/Build/Products/Release/PrimeGPUCalibration \
  --destination-host .build/arm64-apple-macosx/release/PrimeNative3BMetalContinuationProbe \
  --runtime-role native_3b_metal_continuation_probe
.build/arm64-apple-macosx/release/PrimeNative3BMetalContinuationProbe \
  --artifact-root /absolute/private/artifact-root \
  --source-root "$PWD" \
  --metal-lease-file /absolute/private/lease-parent/prime-metal.lock
```

Each checkpoint component is capped at 12 GiB before load. The expected raw
model-plus-Adam floor is about 31.52 GiB, so the artifact root is local
research evidence unless its exact bindings are separately copied to durable
off-device storage.

## Phase 3 frozen-contract resolver

The completed resolver slice was a Swift-authoritative, resolver-only
transition. It binds exactly eight already-frozen companion artifacts,
totalling 11,969,097 bytes, at companion commit
`163fc100710ece48119bc25954452d10f6a84f7f` and tree
`9009daa4f8a07fbd5897e00b9571cef44ec292db`. `/usr/bin/git` is used only as a
directly executed, read-only raw-object transport; Swift owns revision, tree,
path, mode, object type, object ID, byte-count, SHA-256, mutation, publication,
and receipt decisions.

Admission requires an empty artifact root with exact mode `0700`. Prime's
remote, revision, tree, and complete tracked/untracked cleanliness state are
checked before source snapshotting and again after running-executable capture;
both observations must remain identical and clean. Executable capture opens
the running image without following links, binds the file descriptor's device
and inode to the executable vnode loaded in the current process, and rejects
metadata change across the read.

`PrimeNativeContractResolutionVerifier` is a separate Swift-only executable
with only an artifact-root input. In a fresh process it rebinds the canonical
receipt and validates the complete persisted descriptor root twice. It has no
Git, donor-selection, or execution knobs and claims no independent scientific
oracle; it tests persistence and structural replay only.

The source-sealed Release resolver and separately invoked fresh-process
verifier both pass. The repository-durable receipt and evidence note are under
`artifacts/native-contract-resolution-canonical-2026-07-29/`; the verifier
claims persistence and structural replay, not an independent scientific
oracle. This slice does not perform compatibility replay, implement an
adapter, expand the archived profile screen, execute companion or NeuralKit
code, execute a model, train, quantize, or authorize product use. The next
admissible step was the narrowly scoped compatibility adapter.

## Resolved-contract compatibility adapter

The current implementation adds a dependency-light Swift adapter over the
exact frozen resolver result. It revalidates the parent descriptor root,
replays the NFC UTF-8 byte tokenizer through two native byte paths, validates
the corpus/evaluation manifest and inert historical Verify/Abstain envelope,
and publishes a typed Prime projection into a fresh descriptor-backed
artifact root with immutable receipt-bound files.

This is not full Phase 3 compatibility. The resolved inventory embeds neither
the corpus rows nor a standalone fixed-cap/EOS generation wire contract, so
the adapter cannot claim corpus regeneration, semantic row regrade,
generation-behavior compatibility, model or NeuralKit execution, training,
quantization, product authority, or an independent scientific oracle. Its
canonical Release status, receipt identity, and fresh-process verifier result
are recorded only in
`artifacts/native-resolved-contract-adapter-canonical-2026-07-30/README.md`
when that evidence exists; absence of that note means the result is pending.

## Native generation, corpus, and NeuralKit gate contracts

The next source boundaries no longer depend on opaque prose:

- `PrimeNativeGenerationContractProjection` freezes the target-independent
  prompt-only, fixed-cap/EOS, raw-output, full-vocabulary, and KV-cache
  contract;
- `PrimeNativeCorpusReplay` compiles the exact tokenizer and corpus blobs in
  an isolated target, regenerates all eight splits and all 155,648 rows, and
  reruns the embedded regrader in distinct Release processes; and
- `PrimeNativeNeuralGateContract` binds those canonical parents and projects
  the selected eight-file native-gate pre-carrier compile closure, the generic
  verdict-carrier slice, guarded loss statistics, fixed-prompt runner-up
  margins, finite-field mechanics, selected capability thresholds,
  count-label/all-critical rules, and the complete mutation catalog without
  importing NeuralKit or PMHNP.

The NeuralKit projection executes a fixed raw-UTF-8 finite-field vector and
twelve structural projection falsifiers. Those are adapter-integrity checks,
not the historical 46 semantic mutations. NeuralKit's
`independentThreePlus(k)` is a count-derived label produced inside one gate;
it is not AgentContractKit's four-tier TriadAudit and is not evidence of ten
separately implemented authorities.

The two parent receipt hashes are paired with closed historical Prime source
pins and exact Git/snapshot tuples. Parent replay therefore authenticates each
older Release snapshot against its own frozen identity while the new
probe/verifier authenticate the current clean source; artifacts cannot supply
an arbitrary expected digest.

The Stage-A source contract is implemented. A canonical result exists only
when a repository-durable evidence note is present under
`artifacts/native-neural-gate-contract-projection-canonical-2026-07-30/`.
The dual-arm Stage-B replay is frozen but not implemented and authorizes no
receipt. It requires two separately fingerprinted arms: exact historical
forensic replay, which remains `ABSTAIN` on target independence because the
pinned fixture consumes target length and expected completion, and a corrected
Prime-owned prompt-only fixed-cap-64/EOS replay. Each arm must publish the full
raw invariant multiset, match direct and accelerated fingerprints, recompute
all ten Verify/Abstain legs plus the projected statistics/margin and
count-derived verdict, and detect/diverge/restore its complete frozen mutation
catalog in a distinct Release verifier.

The first bounded pure-library Stage-B sub-slice implements only the canonical
raw-UTF-8 global-stream and chunk mechanics, independent direct and affine
finite-field fingerprints, the raw-byte cache guard, and typed
invariant/fingerprint payload validation. It does not complete the replay
library layer. The pinned runtime donors, prompt-only corrected gate,
statistics/verdict and mutation mechanics, historical worker, and paired
probe/verifier remain pending; `executionImplemented` remains false and the
frozen plan hash is unchanged.

The closed PrimeCore external-child capture substrate is implemented. It
accepts only the role and source root, directly launches the frozen Xcode 26.6
build 17F113 `swift-package describe --type json` executable with no shell,
stdin at EOF, and an exact non-inherited four-key environment:
`HOME`, `TMPDIR`, `CLANG_MODULE_CACHE_PATH`, and
`SWIFT_MODULECACHE_PATH`, all rooted inside a fresh per-role scratch
namespace. Its exact arguments bind `--scratch-path`, `--cache-path`,
`--config-path`, and `--security-path` to that namespace; disable the
dependency cache, prefetching, automatic resolution, netrc, and keychain; set
`--manifest-cache none`; and end in `describe --type json`. It deliberately
uses neither `--skip-update` nor `--disable-sandbox`, so SwiftPM's manifest
sandbox remains enabled. The repository `.build` tree is neither used nor
authoritative.

Each run root is atomically created as `0700` below Darwin's
`_CS_DARWIN_USER_TEMP_DIR` and holds exactly `work`, `cache`, `config`,
`security`, `home`, `tmp`, and `module-cache` directories on the same local
APFS filesystem as the source. PrimeCore holds no-follow, close-on-exec
descriptors and rejects ACLs and unknown extended attributes. It permits
`com.apple.provenance` only as opaque, non-authoritative bytes bounded to 4,096
bytes. It additionally permits optional `com.apple.TextEncoding` only on the
regular file `work/.lock`, with the exact 15-byte value
`utf-8;134217984`; absence is allowed. The Darwin user-temporary parent is an
explicit trusted prerequisite. Prime does not recursively delete the
namespace; it closes its authority and leaves cleanup to the system
temporary-directory lifecycle. This boundary makes no hermeticity, OS-level
network-denial, or hostile same-UID-process isolation claim.

Spawn flags are exactly `0x448c`: start suspended, close-on-exec default, new
session, default resettable signal dispositions, and an empty signal mask.
Positive direct-PID authority is retained until `SID == PGID == PID`; only
then may lifecycle signals target the dedicated process group. The factory
binds the executable's exact full-file descriptor identity to the suspended
mapped executable vnode.

Source admission is limited to a current-owner local-APFS tree: at most 4,096
files, 4,096 directories, 512 MiB aggregate file bytes, 8 MiB per file,
relative depth 32, and 30 seconds. PrimeCore holds the root, authority
directories, and every admitted source file descriptor; arms receipt-checked
`EVFILT_VNODE` guards; and requires exact inventories, bytes, metadata, path
joins, and zero source events at initial, pre-resume, and post-reap
checkpoints. Its bounded post-reap scratch audit scans all seven subtrees,
requires `cache`, `config`, and `security` to remain empty, and rejects
dependency-resolution residue anywhere. The wire facts are
`dependencyResolutionPermitted = false` and
`networkDenialEstablished = false`: CLI policy forbids resolution, but no
kernel network sandbox is claimed.

The typed rejection lifecycle has ten focused cases covering pre-join direct
PID cleanup, proven-group cleanup, TERM/KILL escalation, death after TERM,
bounded exact-PID `WNOHANG` fallback, exact-once reap, overflow-through-EOF,
read failure, uncontained drain, and the no-post-reap-signal invariant.
Contained and reaped rejection may return as internal `ABSTAIN`; inability to
contain the child or drain must fail-stop rather than continue into evidence
logic. External-child evidence and its enclosing describe-capture record are
schema 4 at
`neural-gate-replay/source/probe-swift-package-describe-capture.v4.json` and
`neural-gate-replay/source/verifier-swift-package-describe-capture.v4.json`.
The adaptation-proof and historical-worker aggregate contracts remain V2. The
source/execution-binding and replay-output contracts are frozen at V3, the
output-path-classification contract ID is
`prime_stage_b_output_path_namespace_classification_v3`, and the fixture plan
is V3/schema 3 at `neural-gate-replay/plan.v3.json`. The adaptation proof
remains at `neural-gate-replay/source/adaptation-proof.v2.json`. The nested
held-source mutation-guard observation remains schema 1, while the
scratch-namespace observation is schema 2. The raw evaluated
`swift-package-describe.v1.json`, compiled-source closure, Release bindings,
historical-worker request/process/result/success records, and terminal receipt
remain V1 records.

Focused Swift tests cover the lifecycle and scratch mechanics; they are not a
live factory proof. Two initial Release two-role factory canary attempts failed
after each child and drain remained contained and the child was reaped: the
first exposed the terminal mapped-region zero-byte/`EINVAL` behavior, and the
second progressed past that point and exposed the exact optional
`com.apple.TextEncoding` value on the regular file `work/.lock`. After those
corrections, the resealed live Release two-role secure-capture canary passed end
to end on the pinned host. Probe and verifier output was byte-identical:
22,022 bytes with SHA-256
`f5f2d2ebf4409da26164c1980bcece14c60db6937f664adb96e4e57693580b86`.
This current reseal includes the trusted descriptor-inventory substrate and
the pure Stage-B replay-mechanics foundation; it does not widen the canary's
authority.
That pass validates only the secure capture substrate on the pinned host. It
published no durable Stage-B process record or receipt,
`executionImplemented` remains false, and no Stage-B replay, historical
worker, model execution, Metal execution, or product use is implemented or
authorized. A validated six-process topology,
distinct running Release executable bindings, exact pre-receipt realized
path-and-metadata inventory, separate typed artifact-content validation,
purpose-correct `0444` data / `0555` executable publication, and scoped
`PASS`/`ABSTAIN` composition remain required future Stage-B work. The direct
launch path, `proc_pidpath` pathname, and code-sign fields are
non-authoritative telemetry; no Apple trust claim is made.
Because the source-faithful fixture inherits traps, a sealed Swift worker owns
the entire historical arm; probe and verifier supervise separate bounded
invocations with
empty successful stdout/stderr, mandatory death/reap, exact role-prefix
inventory, and role-separated artifact evidence. An abnormal worker outcome
that is successfully contained and reaped poisons the root, accepts no result
as evidence, emits no successful-execution record or terminal receipt, and
permits no retry; partial files remain non-authoritative. An uncontained child
or drain must fail-stop. Worker result transport cannot authorize mechanics
`PASS`; the verifier must decode and recompute the semantic artifacts. Stage A
is copied as 35 reachable typed bindings plus its separately pinned receipt,
or 36 artifacts total. The exact next prerequisite is
`implement_stage_b_role_scoped_historical_worker_probe_verifier_using_completed_primecore_secure_capture_typed_artifact_recomputation_corrected_fixed_cap_eos_fixture_and_exact_path_content_inventory`.

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
