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
corrected row-identity metadata leak, trap-disjoint execution admission, dual
replay arms, exact invariant serialization, and direct/accelerated fingerprint
boundary are recorded in
[`docs/PRIME-NATIVE-NEURAL-GATE-FIXTURE-REPLAY-PLAN-2026-07-30.md`](docs/PRIME-NATIVE-NEURAL-GATE-FIXTURE-REPLAY-PLAN-2026-07-30.md).
The additive topology-V7 exact-count stream decoder, typed worker/artifact
reference declarations, retained-capture binding, and unchanged authority
ceiling are recorded in
[`docs/PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md`](docs/PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md).
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
executable optimizer mutation operator is implemented and executed in Swift.
The corrected Stage-B catalog is narrower in authority: its fifteen Swift
values currently validate ordered caller-supplied divergence, named-leg, and
exact-restoration observations; they do not yet inject mutations or establish
independent detection. The typed optimizer gate's structural sweep is
deliberately recorded as a same-process self-check, not as an independent
scientific oracle. Later functional claims still require a disjoint Swift
regrader. If a future mutation truly requires an unavailable Swift primitive,
the run remains `ABSTAIN` until that primitive is implemented or a separately
reviewed, mutation-specific exception is added. There is no general Python
fallback.

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
The dual-arm Stage-B execution remains unimplemented and authorizes no
receipt. Topology V3 now materializes three trap-free, non-authorizing
libraries: dependency-free
`PrimeNativeNeuralGateReplayArtifactContracts` and
`PrimeNativeNeuralGateReplayTransport`, which depends only on the contracts
target and pure replay mechanics, plus
`PrimeNativeNeuralGateReplayComposition`, which assigns strict ordinals across
exactly 18,432 caller-provided canonical prompt records and requires exact
outer/raw/validated-sidecar joins with prompt, correlation, decision, and
corrected trace replay. V4 freezes the current 116-spec non-authorizing
overlay, catalogs, and leg domains; bounded canonical decoding and the shared
producer codec are implemented only for the prompt/outer/raw manifests and
their three pathless row/reference shapes. All other semantic observation
schemas remain deferred, and no production or execution target imports the
transport or composition. The replay still requires two
separately fingerprinted arms: exact historical
forensic replay, which remains `ABSTAIN` on target independence because the
pinned fixture consumes target length and expected completion, and a corrected
Prime-owned prompt-only fixed-cap-64/EOS replay. Each arm must publish the full
raw invariant multiset, match direct and accelerated fingerprints, recompute
all ten Verify/Abstain legs plus the projected statistics/margin and
count-derived verdict, and detect/diverge/restore its complete frozen mutation
catalog in a distinct Release verifier.

The exact implemented boundary, digest locks, decoder semantics, nonclaims,
and remaining gaps are recorded in
`docs/PRIME-NATIVE-NEURAL-GATE-TYPED-ARTIFACT-TRANSPORT-2026-07-31.md` and
`docs/PRIME-NATIVE-NEURAL-GATE-REPLAY-COMPOSITION-2026-07-31.md`. The additive
held-root/crosswalk boundary is recorded in
`docs/PRIME-NATIVE-NEURAL-GATE-HELD-ROOT-CROSSWALK-AUTHORITY-2026-07-31.md`.

The bounded pure-library Stage-B foundation now also includes a separate
corrected-mechanics target. It implements only value mechanics: a
non-`Codable` prompt-token row input, replicate-scoped admitted seed context,
fixed-cap-64/EOS full-512-logit decision trace validation, allowed-support
selection, exact structural raw-argmax/parity/count witnesses, canonical post-execution
exact regrade, weighted statistics, exact 512-logit fixed-prompt margin,
capability-threshold calculation, the ten-leg count-derived verdict, and
fifteen mutation IDs plus observation validation. Full logits are locally
bound by digest; the Foundation/Double probability calculations are explicitly
non-evidentiary and do not substitute for the frozen source-pinned Float32
log-softmax. These calculators accept caller-provided values; they do not
inject/detect defects or establish observed leg, capability, semantic, or
model truth. The corrected-mechanics target itself contains no prompt solver,
process, filesystem, network, donor-runtime, model, or receipt authority.

An isolated
`PrimeNativeNeuralGateCorrectedFixtureAuthority` target now derives the exact
corrected fixture from Prime's byte-exact source-pinned tokenizer/corpus
transplant while binding the identities of the closed Stage-A and full-corpus
replay receipts. It selects 4,096 validation, 4,096 combination-holdout, 4,096
OOD, 4,096 mutation, and 2,048 abstention rows, then globally orders all
18,432 rows by row ID. The
domain-separated fixture identity is
`c1f29a0d1067a4bce5541ee5100044276ccc16c63e57501b509fb3126fcd29a4`;
the canonical observation SHA-256 is
`a30c7fe39157ce6e0de2e0783a8af8807c4a1b02b309a144ba3272a6cc6d931d`.
This derivation exhaustively regrades every selected fixture row and binds
prompt-only inputs separately from target-token/EOS feasibility. Its corpus
dependency is trap-bearing derivation authority and is forbidden from the
corrected executor closure. The historical regression fixture is lineage-only here; it
is neither read nor executed. Closed parent receipt identities are
source-bound and type-decoded in tests, but the derivation itself reads no
receipt bytes and publishes no independent fixture receipt. It performs no
solver or model execution and authorizes no Stage-B receipt.

An isolated `PrimeNativeNeuralGatePromptSolver` target now supplies the
concrete `PrimeNativeNeuralGatePromptOnlyReplicateSolver`. Its sole local
dependency is `PrimeNativeNeuralGateCorrectedMechanics`; it receives only
prompt token IDs plus a replicate-scoped admitted evaluation seed and creates
fresh local parse/evaluation state for each call. The implementation is a
trap-free Swift adaptation, not a byte-exact transplant, of the Ergentics,
LLC-owned corpus solver at companion revision
`163fc100710ece48119bc25954452d10f6a84f7f`, tree
`9009daa4f8a07fbd5897e00b9571cef44ec292db`, path
`prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift`,
blob `b2a087c9410a71f2bc99debade752ff779d7a8a8`, 177,032 bytes,
SHA-256
`4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210`,
under `LicenseRef-Ergentics-Proprietary`. The repository test contract is
observed across all 18,432 selected rows in each of the three admitted
replicate contexts and again under seed-keyed row permutations. It passed
with exact output/EOS, 512-Float bit-pattern and digest, cross-seed logit
manifest, and seed-bound trace checks. Malformed surface, action-lead, and LF
wire-shape mutations also fail closed to `ABSTAIN`. That is repository-only
symbolic/synthetic mechanics coverage, not model execution, an independent
scientific oracle, a durable observation or receipt, Metal authority, or
product authority.
The historical source-plan slice advanced corrected admission to V3, the
source/execution binding to V6, and the fixture plan to V5/schema 5. It binds
the bounded lossless logit-sidecar codec and the maintained MLX Float32
log-softmax operation as source contracts only. It does not change
`executionImplemented`: no durable sidecar, full-fixture process observation
or recomputation, model execution, Stage-B Metal authority, process record,
terminal receipt, independent scientific oracle, or product authority has
been established.

The pure trace binds every 512-logit decision by an exact bit-pattern digest
instead of hex-expanding logits into the invariant multiset; the expanded
three-replicate fixture would violate Stage-B decode bounds. This is not a
durable full-logit artifact. The source-bound codec admits at most 1,179,648
candidate vectors and 65,536 unique vectors; exceeding either bound fails
closed. Durable sidecar observation and complete-fixture MLX Float32
recomputation remain mandatory, while the local Foundation/Double probability
diagnostic is excluded from canonical fingerprints.

The repository-test checkpoint passed pure sidecar mechanics 6/6. The
source-pinned MLX validation package remains outside the MLX-free
`PrimeCoreTests` bundle and passed 9/9 in 193.005 seconds against the exact
3,817,916-byte metallib, SHA-256
`24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b`;
the structural three-vector output digest is
`8dca965dbb3057c79d268435b23e58ecab8e77ecfe745b6a434cc1b2a852d98a`.
Those nine cases comprise seven focused MLX mechanics cases and two exhaustive
integration cases; the main exhaustive case took 192.889 seconds and covered
18,432 rows and 232,638 decisions per seed for `1618`, `2718`, and `3141`,
with 44 unique complete 512-value vectors, a 90,136-byte dictionary, a
2,070,912-byte aggregate, bit-exact reconstruction, and stable MLX digest
`db6906710bffd6a81653ca01df91f913f8a5430da8c8e9c8e620b3c88f7b2f02`.
This is repository mechanics only, not a durable Stage-B
artifact, full-fixture process observation, model or Stage-B Metal authority,
process record, receipt, or product evidence.

A forward audit found that the earlier five-field corrected request exposed
`row_id`; corpus row IDs encode split and semantic family, including the
abstention class. Corrected row execution therefore sees exactly
`prompt_token_ids`; one seed is fixed at replicate/shard scope and correlation
identity stays outside the execution value. Fresh per-row solver state and
row-order permutation identity are mandatory because retained state, order, or
row-selected seeds are also metadata channels. The audit also found that the
planned shared donor topology would expose trap-bearing historical code to
corrected supervisors. The package now splits raw execution mechanics from
evaluation/regrade mechanics, and
historical `PrimeNativeNeuralGateTrapDisjointTopologyContract.frozenV4`,
SHA-256
`8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af`,
preserves topology V1/V2/V3 and supersedes the unsafe future routing while
preserving plan V5 and source binding V6 as history. Composition V1, SHA-256
`75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e`,
freezes the shared codec, strict prompt schedule, and exact in-memory join.
Source composition V1, SHA-256
`f3d0a58905065836caaae8c9d03c1b2840b07bcd1a4f0bf35f1ce638c6ac29b5`,
adds descriptor-rooted prompt/outer/raw/logit source capabilities,
incremental prompt reconstruction, target-free role projections, and an exact
four-source keyed join. Historical additive topology V5,
`prime_stage_b_held_root_capture_crosswalk_authority_topology_v5` (canonical
SHA-256
`252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930`),
added a retained exact 41-file
held-root capture and a separate trap-bearing 18,432-row source-derived keyed
prompt/target crosswalk. The focused integration passed in 300.125 seconds.
That sealed boundary establishes one capture epoch, durable origin for only the
captured four-source bytes, corrected fixture identity, exact source-capability
join, independent prompt/target association, and outer expected-completion
binding. Historical topology V6,
`prime_stage_b_process_evaluation_receipt_ownership_target_free_delivery_topology_v6`
(canonical SHA-256
`6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1`),
freezes the symmetric ten-process role/ownership model, separate corrected
evaluation roles, verifier-supervisor receipt-last ownership, byte-bounded
target-free slot decoding, `Encodable`-only aggregate candidates, and a real
supervisor-only retained-capture binding wrapper. The wrapper prepares and
source-binds candidates; `processDeliveryObserved` remains false.

Current topology V7,
`prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7`
(canonical SHA-256
`88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156`),
preserves V1 through V6 and adds exact-count bounded `PRIMEIRM1` raw and outer
stream admission, typed common/branch/twenty-path artifact-reference schemas,
six four-part Release worker-source declarations, and a supervisor-only
retained-capture reference adapter. Aggregate candidates remain
non-`Decodable`; the decoder does not deserialize aggregate candidate arrays.
Topology V7 is distinct from source/execution-binding V7, which remains
unissued.

The historical runtime, every supervisor and worker, probe, verifier, mutation
producer, and mutation detector are still `planned_not_materialized`. All
actual source-snapshot, package-description, compiled-closure,
sealed-executable, and artifact-content reference values remain absent;
declarations are not evidence. Corrected execution remains blocked:
prompt-content target independence, process/schedule delivery, model
execution, evaluation/verdict publication, mechanics `PASS`, a terminal
receipt, science, and product authority all remain false. The exact next
prerequisite is
`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`.
`executionImplemented` remains false. The exact topology and nonclaims are in
`docs/PRIME-NATIVE-NEURAL-GATE-TRAP-DISJOINT-TOPOLOGY-2026-07-30.md` and
`docs/PRIME-NATIVE-NEURAL-GATE-PROCESS-OWNERSHIP-TARGET-FREE-DELIVERY-2026-07-31.md`;
the current additive boundary is in
`docs/PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md`.

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
corrected execution-admission contract is V3. The source/execution-binding
contract is frozen at V6; V5 remains the historical thirteen-target
prompt-solver source contract and V4 the earlier twelve-target
fixture-authority binding. The replay-output contract remains V3, the
output-path-classification contract ID is
`prime_stage_b_output_path_namespace_classification_v3`, and the fixture plan
is V5/schema 5 with canonical content SHA-256
`c811555bc3a04f053378519ca9c33d18de075d0eb7b347587a9789f4aff3466b`.
V4/schema 4 remains the historical pre-sidecar plan and V3/schema 3 the
pre-solver plan. The frozen V3 replay-output namespace still
reserves `neural-gate-replay/plan.v3.json`; no V4 or V5 execution artifact or
receipt is claimed. The adaptation proof remains at
`neural-gate-replay/source/adaptation-proof.v2.json`. The nested held-source
mutation-guard observation remains schema 1, while the scratch-namespace
observation is schema 2. The raw evaluated
`swift-package-describe.v1.json`, compiled-source closure, Release bindings,
historical-worker request/process/result/success records, and terminal receipt
remain V1 records.

Focused Swift tests cover the lifecycle and scratch mechanics; they are not a
live factory proof. Two initial Release two-role factory canary attempts failed
after each child and drain remained contained and the child was reaped: the
first exposed the terminal mapped-region zero-byte/`EINVAL` behavior, and the
second progressed past that point and exposed the exact optional
`com.apple.TextEncoding` value on the regular file `work/.lock`. After those
corrections, the then-current live Release two-role secure-capture canary
was rerun after the fixture-authority twelve-target source freeze and passed
end to end on the pinned host. Probe and verifier output was byte-identical:
23,207 bytes with SHA-256
`f2204bbae8623c35fdf7357c6b0aa2a585e9071f22556edbe6ce6e7cfccf04d5`.
That is the preceding twelve-target fixture-authority reseal. After the
isolated thirteenth prompt-solver target was added, the same Release canary was
rerun on the pinned host and passed with byte-identical probe/verifier output:
23,791 bytes with SHA-256
`9d56ad223c9d980272583dc752e0ff05bb815ce504cd3c82fc7e186627c02aa7`.
This remains valid historical secure-capture evidence for the complete
thirteen-target package description and source snapshot. The live factory
still used the typed V4 selected-subgraph contract, so it was not a typed V5
source-binding reseal and does not widen canary authority. After the
fifteen-target V6 source graph and isolated MLX validation topology were
frozen, the same Release canary passed with byte-identical probe/verifier
output: 26,090 bytes with SHA-256
`53ace0b68b1f8f2cf6534be886cb93241b08a36e0ddf0e9da7f8eee33f37cb40`.
The later topology audit established that this is an actual-package
secure-capture reseal only. The captured package description was not
reconciled against V6's planned closure, whose future execution targets were
not materialized, so it is not V6 selected-source execution-graph proof.
After the raw/evaluation package split and topology V1 correction, the same
Release canary passed with byte-identical probe/verifier output: 27,015 bytes,
SHA-256
`00dc419e101367d1f4a1d39f63bd35649b4de45417d74e4197f2376d729cdadf`.
This is the last accepted topology-V1 actual-package secure-capture reseal.
It predates the two topology-V2 targets and is not current V2 evidence. After
the complete topology-V2 source reseal, the same Release canary passed with
byte-identical probe/verifier output: 28,589 bytes, SHA-256
`3a4ae506f5ed2eae16e9f46d099c5d53681ec1d1a02aa9c20549b0fbeb230d7c`.
This is the last accepted topology-V2 actual-package secure-capture reseal and
predates topology V3 plus replay composition. It is not current V3 package or
V6/V7 execution-graph proof, and source binding V7 remains unissued.
After the complete topology-V3 source reseal, the same Release canary passed
with byte-identical probe/verifier package-description output: 29,905 bytes,
SHA-256
`ad4a66338d7348cb44419a115e062a30da129dea9a6355eec81f6b98932b6e11`.
This is the last accepted historical topology-V3 actual-package secure-capture
reseal. It predates topology V4 and is not V4 package-capture evidence.
It validates only the secure-capture substrate on the pinned host. It is not
V6/V7 selected-source execution-graph proof; it does not issue source binding
V7 or establish worker or model execution, fixture identity,
evaluation or mechanics `PASS`, Stage-B publication or a terminal receipt,
reproducible-build identity, or network denial.
After the complete topology-V4 source reseal, the same Release canary passed
with byte-identical probe/verifier package-description output: 32,735 bytes,
SHA-256
`f7d873db2b91ecc61d356136b37bf7bc8017db962f40637998de914eeaa8d894`.
This is the last accepted historical topology-V4 actual-package secure-capture
reseal.
After the additive topology-V5 source reseal, the same Release canary passed
with byte-identical probe/verifier package-description output: 36,047 bytes,
SHA-256
`88571dc5cc4d15f11395430ab9ea410aba6cafa295edebe54acff816585a3fbb`.
The V4 bytes were not reused as V5 evidence.
It has the same secure-capture-only scope and does not widen any execution,
evaluation, receipt, reproducibility, network-denial, Metal, or product claim.
`executionImplemented` remains false, and no Stage-B replay, historical worker,
Metal execution, or product use is implemented or authorized. The historical
V5 six-process count is preserved as history. Topology V6 replaces it for
future execution with an exact symmetric ten-process roster and freezes the
process, evaluation, and receipt ownership declarations; none of those ten
processes is implemented.
Distinct running Release executable bindings, exact pre-receipt realized
path-and-metadata inventory, separate typed artifact-content validation,
purpose-correct `0444` data / `0555` executable publication, and scoped
`PASS`/`ABSTAIN` composition remain required future Stage-B work. The direct
launch path, `proc_pidpath` pathname, and code-sign fields are
non-authoritative telemetry; no Apple trust claim is made.
V6's receipt declaration inventories exactly 20 role-scoped pre-receipt paths;
it is not an exact full-root inventory. At the V6 checkpoint, typed
role-to-path-to-content binding, common capture/schedule references, and
source-pinned worker closure/executable references were forward blockers.
Topology V7 now freezes those typed declaration schemas and their retained
capture/schedule adapter, but no realized artifact content, source snapshot,
compiled closure, sealed executable, or process observation exists.
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
or 36 artifacts total. The V6 contract/topology checkpoint passed 48/48
focused tests, and the real retained 41-file-root projection/binding test
passed 1/1 over 18,432 rows in 363.326 seconds. These are focused results, not
a full-suite claim. The exact next prerequisite is
`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`.

## Additive topology V8 continuation

The V7 prerequisite quoted above is now satisfied additively. Current topology
V8 is
`prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8`,
canonical SHA-256
`8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b`.
It preserves semantic namespace V4 and V7's exact twenty corrected
pre-receipt paths and freezes the deferred semantic record schemas. It adds
four internal Swift targets: a narrow label-free, presence-only corrected
mutation surface; the semantic catalog/identity boundary; the producer; and
the detector. The corrected mutation catalog/control contract has SHA-256
`9b40258ed7ba07dc62ff6bda96df03b2233575a039b5598b487d738d036a78bd`,
and the role-specific assignment contract has SHA-256
`020fa5275a4ab7941b935271ad26b094b35b96c9fb85be765db1dd9130de36e2`.
The producer directly depends on the semantic and surface targets. The
detector directly depends only on the surface target; its complete local
closure is the surface plus replay mechanics, so it cannot reach mutation
catalog/identity, expected-leg mapping, replay-artifact contracts, or producer
implementation. The surface carries presence controls rather than arbitrary
prediction strings. The detector's only public entry is exact 15-case batch
detection; the single-triplet path is private. Every full bound baseline and
restored surface must equal the batch-common baseline in both bytes and
binding, and all mutated surfaces must be pairwise distinct. Wrong counts,
duplicates, per-case reference-hash or seed drift, and any nonexact cap change
are rejected; the fixed-cap defect is exactly 63 against baseline 64, and
permutation invariance is verified. Here `label-free` means no explicit
mutation ID or label, no arbitrary prediction string, and no admitted per-case
caller-controlled context. These are local in-memory mechanics, not worker,
process, durable artifact, verdict, or receipt evidence. Actual Release source
references for both role libraries remain absent, `executionImplemented`
remains false, and source/execution-binding V7 remains unissued.

Verdict derivation is independently fail-closed. `countDerivedLabel` is retained
only with scope `provisional_count_only_non_authorizing`; ten bare true leg
states still produce `ABSTAIN`. `GROUNDED` requires verified and durably
published evidence for every true critical leg, weighted-statistics
recomputation, stable-greedy and behavioral fixed-prompt predicates, model
capability including exact abstention decisions, mutation-sweep evidence,
source-bound critical-leg evidence, distinct implementation families, and the
four-tier audit state. The live exported
`PrimeNativeNeuralGateCountDerivedVerdict.recompute(legs:)` API remains
compatible but now always returns `ABSTAIN`, exposes only the same provisional
scope, and cannot produce a generic `GROUNDED`. The historical gate additionally
requires all five aggregate references to be verified and durably published
plus observed model execution. Those inputs remain absent in V8, so mechanics
`PASS`, scientific, and product authority remain false.

For historical package-capture continuity, topology V6 passed at 40,100 bytes,
SHA-256
`99431ac9477a6546225721027319fc460ff8b10c8e55ef68f07b5cb8c73c8cd9`.
Topology V7 was source-sealed at
`9cdfe7bfcbbedebce59b7abb45b614778e6674391b570a679ea40728be4c514f`
and passed at 41,951 bytes, SHA-256
`770b719a7e594f95e422f40dc5d4acd0fd93241928416a6bb3f27a448791f928`.
Both are historical prevalidation actual-package secure-capture checkpoints
only. Completed final V8 validation is recorded canonically in the
[V8 semantic-schema and mutation-target record](docs/PRIME-NATIVE-NEURAL-GATE-SEMANTIC-SCHEMA-MUTATION-TARGETS-2026-08-01.md).

The V8 next prerequisite was
`derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7`.
Topology V9 now satisfies it with caller-byte-only Swift derivation of the
exact pinned carrier seam and 45,090-byte direct mutation source material. It
does not parse per-case executable transforms, establish an independent
detector, materialize the historical target or workers, or issue source
binding V7. Topology V10 now completes that next bounded prerequisite by
materializing the exact seven-file runtime and isolated historical replay
libraries plus a Prime-authored observation seam. They remain internal and
unreachable from production executables. The current next exact prerequisite
is
`derive_and_source_bind_source_faithful_historical_fixture_then_materialize_only_the_sealed_historical_worker_without_materializing_probe_verifier_or_issuing_source_binding_v7`.
See [Prime Native Neural Gate Historical Source Material](docs/PRIME-NATIVE-NEURAL-GATE-HISTORICAL-SOURCE-MATERIAL-2026-08-01.md).
See [Prime Native Neural Gate Historical Replay Mechanics](docs/PRIME-NATIVE-NEURAL-GATE-HISTORICAL-REPLAY-MECHANICS-2026-08-01.md).

V9 and V10 keep the exact donor files in the first-party companion repository. Their
cross-repository source proof is therefore an explicit manual pre-merge gate.
The requirement marker makes a missing donor root or mistyped policy fail
rather than skip:

```sh
env PRIME_REQUIRE_V9_PINNED_DONOR_GATE=1 PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE=1 PRIME_PMHNP_COMPANION_ROOT=/path/to/pinned/pmhnp-companion-ergentics swift test
```

This command is mandatory process evidence for V9 and V10. Prime has no repository CI
or branch-rule status check yet, so this record does not claim GitHub enforces
the invocation automatically.

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

The neural-gate logit/recomputation mechanics use a second isolated package
with its own source-pinned mirror and lock. It reuses the same compiled stager:

```sh
swift build --product PrimeTypedOptimizerRestoreProbe
swift build --product PrimeMLXTestBundleStage
swift build \
  --package-path Tests/PrimeNativeNeuralGateMLXValidation \
  --scratch-path .build \
  --build-tests
.build/arm64-apple-macosx/debug/PrimeMLXTestBundleStage \
  --source-host .build/arm64-apple-macosx/debug/PrimeTypedOptimizerRestoreProbe \
  --destination-resources-root .build/arm64-apple-macosx/debug/PrimeNativeNeuralGateMLXValidationPackageTests.xctest/Contents/Resources
swift test \
  --package-path Tests/PrimeNativeNeuralGateMLXValidation \
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
