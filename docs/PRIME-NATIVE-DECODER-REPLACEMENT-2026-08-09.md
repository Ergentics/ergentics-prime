# Prime-native decoder replacement

Date: 2026-08-09

## Ownership

`Ergentics/ergentics-prime` owns the cross-repository native decoder asset,
its future trainer and checkpoint truth, and the evidence used for selection.
`ergentics-llm` supplied the pinned Swift GQA body/cache mechanics used by this
port. It is not a runtime package dependency. PMHNP remains a read-only
integration and oracle consumer for this arc.

Historical MLXLLM/Llama comparator sources and receipts remain immutable. The
MLXLLM dependency and its two Llama execution products are absent from the
active Prime package graph; preserved source-only historical targets remain
source-pinned for evidence continuity but cannot select the new decoder.
PrimeCore history is likewise preserved; the new authority is append-only.

## Implemented mechanics

The library-only `PrimeNativeDecoder` target depends exactly on `PrimeCore`,
`MLX`, and `MLXNN` at the existing pinned Ergentics MLX revision. It contains:

- grouped-query attention without KV-head tiling;
- RoPE, RMSNorm, SwiGLU, residual blocks, and tied output projection;
- exact checked geometry and parameter-count derivation;
- deterministic task-local seeded construction;
- full-prefix causal forward mechanics;
- an opaque, decoder-bound, revision-bound KV cache with bounded growth,
  explicit materialization, poison/reset behavior, and rectangular-batch
  semantics.

The implementation can inventory the frozen Logic-10M MHA geometry by setting
query and KV heads equal, but does not claim parity with the earlier manual
attention implementation. Native-300M GQA geometry remains declarative in the
library and authority records; those records alone do not allocate or execute
it. The bounded execution observation below separately records one
random-initialized allocation and forward.

The separate library-only `PrimeNativeDecoderCheckpoint` target depends
exactly on `PrimeCore`, `PrimeNativeDecoder`, `MLX`, and `MLXNN`. Its frozen V1
surface supplies the historical compatibility identity, ordered
path/shape/FP32/count catalog, weights-only manifest, logical tensor hashes,
and explicit state exclusions. V1 executable save/load mechanics remain
internal and accept only the exact tiny synthetic configuration through
caller-owned regular file descriptors. That V1 writer truncates before save
and may leave its borrowed file empty or partial on failure, so it is not the
native-profile publication boundary and remains byte-frozen.

The additive V2 surface described below does expose exact native-profile
checkpoint write/load, but only through `PrimeArtifactRoot`; it neither
promotes nor calls V1's private descriptor codec. V2 implements exclusive
atomic-creation and synchronization mechanics, but this slice does not observe
their Native-300M execution and does not establish atomic replacement,
transparent failed-write recovery, retained artifact provenance, or checkpoint
admission.

## Authority ceiling

`PrimeNativeDecoderAuthorityPlan.frozenV1` remains the frozen predecessor.
`PrimeNativeDecoderDerivedDeltaPlan.frozenV1` separately binds the exact local
LLM donor commits, tree, source blob, byte count, SHA-256, implementation ID,
derived architecture deltas, Prime product/target, and dependency closure.
The donor revisions are explicitly recorded as not observed on `origin`.

`PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1` is another append-only
successor. It authorizes strict compatibility-schema and analytic-catalog
mechanics plus a bounded synthetic descriptor roundtrip only. Native-300M
allocation/write/load, checkpoint provenance/admission, live runtime and Metal
observations, tokenizer functional compatibility, optimizer/RNG/data-cursor
state, training/resume, candidate selection, trial, canary, product, and
publication authority all remain false.

`PrimeNativeDecoderMetalRepairAuthorityPlan.frozenV1` succeeds those frozen
records without rewriting them. It binds the old and repaired decoder source,
the exact pinned MLX and nested-core revisions, the affected RoPE source, and
the regression and upstream-repair revisions. The pinned MLX single-token
scalar-offset RoPE dispatch omitted the batch dimension; Prime supplies one
explicit `Int32` offset per rectangular batch row, forcing the batch-aware
kernel without changing the MLX pin or parameter topology.

The checkpoint V1 compatibility identity remains immutable history bound to
the pre-repair decoder source. It is not the current repaired decoder identity.
`PrimeNativeDecoderCheckpointCompatibilityV2AuthorityPlan.frozenV2` and
`PrimeNativeDecoderCompatibilityIdentityV2` now provide the append-only
declarative successor. V2 retains the exact V1 Native-300M configuration,
Prime byte-512 tokenizer identity, and ordered 218-entry FP32 path/shape/count
catalog while changing the schema, authority lineage, and decoder-source
binding. V1 and V2 relabeling is rejected in both directions, and the V1
manifest rejects a V2 identity. This is weight-topology compatibility only;
behavioral parity with the historical source and existing artifact
compatibility remain unestablished.

`PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1.frozenV1` is the
next append-only source authority. It defines an exact V2 weights-only
manifest, per-tensor logical Float32 hashes, and an external binding that
combines the canonical manifest identity with a whole-container
`PrimeArtifactBinding`. The codec accepts only a held `PrimeArtifactRoot` and
a descriptor-relative name. Its writer prevalidates the exact Native-300M
catalog, generates beneath an exclusive hidden descriptor, strictly checks the
raw safetensors header and extents, and reloads and materializes a fresh model
before artifact-root sealing, synchronization, no-replace publication, and
parent synchronization. Its loader requires the caller-supplied external
binding, holds the verified artifact descriptor across full materialization,
and returns a newly restored decoder after exact reinspection. There is no
public raw-descriptor, URL, discover-and-trust, replacement, or in-place model
mutation API, and embedded metadata cannot nominate its own expected
whole-container hash. The two exact Native-300M write/load calls are authorized
but are not executed by this source slice. No checkpoint is available,
retained, admitted, or granted provenance by this design.

`PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityPlanV1.frozenV1`
defines the separate one-shot execution boundary. It permits only the
first-attempt, two-parent direct successor of the exact reviewed-main base to
materialize one seed-42 Native-300M source, call the public V2 writer exactly
once, and call the public V2 loader exactly once into a fresh decoder. The
hosted launcher first validates all predecessor logs and receipts, reclaims
only its exact allowlisted predecessor scratch roots, and requires three times
the checkpoint cap in free space. The child holds the maintained environment,
Metal lease, and exclusive same-job metallib checks; it emits one bounded,
ordered, chunked canonical receipt containing the complete external binding.
The parent independently validates the receipt and then removes exactly the
immutable checkpoint leaf and its empty private root with literal
`unlink`/`rmdir`. The plan records no execution by itself and remains
`ABSTAIN`. Its one authorized attempt ran at reviewed-main merge
`27749af3347437daa693d4375acb759283923a4a`, workflow run `31472165002`, job
`93718282081`. The frozen predecessor, build, and pure-test gates passed;
source-pinned control flow establishes that the public writer returned
successfully before the probe rejected its first post-write artifact-root
stable-identity comparison. The failed run emitted neither root snapshot nor
the changed field. A separate local APFS reproduction diagnosed a directory
link-count transition from two to three when one leaf was added; that diagnosis
is not hosted-run telemetry. Execution stopped before artifact-path observation,
the second cache clear, public load, any V2 receipt marker, parent validation,
or literal `unlink`/`rmdir` cleanup; no external-binding field or container hash
was independently observed, and the run uploaded zero Actions artifacts. The append-only
`PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationV1`
binds that failure and establishes neither checkpoint-I/O success nor retained
or admitted checkpoint state. Retry, forward, backward, training, product, and
publication remain false. Its exact status is
`ABSTAIN_seed42_public_write_return_source_inferred_postwrite_root_guard_failed_no_load_no_receipt_no_artifact_admission`.
The old live command is removed and the temporary reviewed-main timeout and
checkout-depth expansions are restored. Any correction must use a separately
authorized seed-43 direct-successor arc; it cannot rerun this seed-42 attempt.

The Metal gate also binds a separate synthetic CI-mechanics policy that starts
without any inherited `MLX_`, `DYLD_`, or `LLVM_PROFILE_` override and sets
only `MLX_ENABLE_TF32=0` before its first Metal or MLX call. No comparison
tolerance was globally widened. That historical CI policy does not weaken or
satisfy the frozen maintained-runtime environment policy, which still rejects
every `MLX_` key for its existing roles.

`PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1.frozenV1` now adds
the decoder-specific successor policy without rewriting either predecessor.
The supervisor must begin with no `MLX_`, `DYLD_`, or `LLVM_PROFILE_` key; the
dedicated Release child must start with and retain exactly
`MLX_ENABLE_TF32=0` in the MLX namespace until process exit. The additive
`PrimeNativeDecoderRuntime` target validates V2 and Native-300M/byte-512
geometry declaratively, checks release instrumentation, holds the Prime Metal
lease, verifies one caller-expected `default.metallib` before and after the
operation against the exact pinned loader-candidate order, reconciles a
singleton Metal default device with MLX GPU index zero, and performs only an
exact FP32 2x2 GPU matmul with checked evaluation and readback. It allocates no
decoder, executes no forward pass, and performs no checkpoint I/O.

The caller-supplied metallib size and SHA-256 are verification inputs, not
artifact provenance or admission. The implementation supports only a
source-pinned exclusive-candidate inference: direct instrumentation of the
path MLX loaded remains false. The authority admits the compute policy and
authorizes this bounded closure without claiming that it has executed.

`PrimeNativeDecoderMaintainedRuntimeExecutionObservationV1.frozenV1` is the
append-only execution successor. It binds the history-preserving merge commit
`b127b2f96c1bcbc8f2ee2017027898853c871469`, workflow run `31449020532`,
the successful active-root and reviewed-main jobs, their decoded log
identities, the exact hosted toolchain and pinned MLX dependency revisions,
and the canonical Release-process receipt. The `macos-26` job exposed the
singleton `Apple Paravirtual device`, built one fresh 6,292,684-byte
`default.metallib` with SHA-256
`b7ea3fb0e851f4e2417f3e82be63deca8df627daf480cf04cc1b2b70195d7b87`,
passed the frozen 44-test decoder suite with zero failures or skips, passed the
one-test runtime authority package, and completed the exact FP32 2x2 GPU
matmul readback under the sole `MLX_ENABLE_TF32=0` override.

That observation establishes the maintained dependency closure, singleton
Metal/default-index-zero binding, bounded MLX initialization, and
source-pinned exclusive loader-candidate inference. It does not independently
instrument the metallib path MLX loaded, establish artifact provenance or
admission, identify a physical GPU, allocate or execute Native-300M, perform
checkpoint I/O, observe the TF32 static or NAX consumer path, train, or grant
trial, canary, product, or publication authority.

`PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1.frozenV1`
is the append-only Stage-1 authority successor. It binds the exact reviewed
base and maintained-runtime predecessor, tokenizer, repaired decoder, V2
identity, root package, lock, and dependency revisions. It authorizes only an
isolated gate that verifies the Prime byte-512 tokenizer maps source text `A`
through two native paths to `[1, 321, 70]` with an exact decode roundtrip,
constructs the exact V2 Native-300M topology once from seed 42, materializes
its FP32 parameters before the forward, projects the exact globally
lexicographically ordered 218-entry catalog and 271,107,072-parameter count,
and executes exactly one full-prefix, no-KV-cache forward. The required output
is a finite FP32 `[1, 3, 512]` tensor whose ordered big-endian Float32 bit
patterns are hashed; the output hash is run evidence, not a frozen expected
value. The bounded process repeats the maintained singleton GPU-index-zero,
Metal-lease, and exclusive staged-metallib checks and uses four distinct
allocator-cache clears around the two explicit checked-evaluation boundaries.

The Stage-1 authority itself records no execution. Native-300M allocation,
the live catalog projection, decoder forward, output shape/dtype/finiteness,
and exact reviewed-main compatibility execution remain false, and its exact
status is
`ABSTAIN_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_authorized_not_observed`.
Even a passing receipt can establish only tokenizer sequence mechanics
and the tokenizer-to-random-initialized-Native-300M full-prefix forward
witness. Broad model functional or semantic compatibility, model quality,
deterministic seed replay, padding/ragged-batch behavior, KV-cache behavior,
generation or generated-token detokenization, backward/gradient behavior, a
V2 manifest or codec, native checkpoint write/load, checkpoint artifact
availability, provenance, or admission, optimizer/RNG/data-cursor state,
train/evaluate or resume behavior, training, candidate admission, trial,
canary replacement, quantization, product use, and publication authority all
remain false. The caller-supplied revision/tree binding is not an independent
observation, and caller metallib expectation is still not artifact admission;
exact loaded-metallib identity, physical-GPU identity, TF32
static/differential evidence, and the NAX TF32 consumer path also remain
unobserved. No root-package, frozen-source, predecessor, frozen-launcher,
existing-validation, 44-test-inventory, workflow-topology,
external-rendering, or new-external-dependency mutation is authorized by this
slice.

`PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservationV1.frozenV1`
is the append-only execution successor. It binds reviewed-main merge
`16dbcb3bad551bc6fd94f02dc3289dff60a94f24`, workflow run `31457183699`,
both successful jobs and decoded-log identities, the hosted toolchain, the
fresh 6,292,716-byte metallib with SHA-256
`e76ce19a7bf47f6087a8dde1f5243fc6eee81c81c55d1d35e2eccbe44701d175`,
and the exact 7,182-byte compatibility receipt. After the frozen 44-test suite
and maintained-runtime closure, source `A` encoded as `[1, 321, 70]`, the live
model projection matched all 218 descriptors and 271,107,072 FP32 parameters,
and one seed-42 full-prefix, no-KV-cache forward produced finite
`[1, 3, 512]` logits. Their ordered-bit-pattern digest is
`b3679db619f92575e87d48a7633d432b194b5b641ca6c54b1cc6996216ebb223`.
That digest binds this execution only; it is not a frozen expected output or a
deterministic-replay claim.

The successor establishes exact fixed-input tokenizer sequence mechanics and
the one tokenizer-to-random-initialized-Native-300M interface witness. It does
not establish broad model functional or semantic compatibility, model quality,
padding/ragged-batch behavior, KV-cache or generation behavior, checkpoint I/O
execution or artifact provenance/admission, backward/training/resume,
candidate/trial/canary/quantization, product use, artifact/product publication
authority, independently observed loaded-metallib identity, or physical-GPU
identity.
The decoded job logs and metallib bytes were not retained or published, the
device detail comes from the preceding same-job runtime receipt rather than an
independent compatibility-process device observation, and the compatibility
probe did not emit an executable byte identity.

These slices establish the repaired source's exact declarative compatibility
identity, admit the narrowly scoped maintained-runtime compute policy, and
observe the bounded initialization closure at the exact hosted merge. The
latest append-only successor now observes the exact
tokenizer-to-random-initialized-Native-300M full-prefix forward witness. These
execution slices do not establish a checkpoint artifact or observed
native-profile I/O, establish broad model functional or semantic
compatibility, train, authorize a trial, replace a canary, quantize, select
product use, or publish. The result remains `ABSTAIN` at those boundaries.

## Verification and next slices

The isolated validation package compiles against the exact first-party MLX
pin. Metal-free configuration, overflow, profile inventory, cache arithmetic,
compatibility identity, mutation, logical-byte encoding, and descriptor-cap
tests run in trusted-main CI.

A second isolated one-test package validates V2 without changing the frozen
44-test Metal launcher or Driver V2 inventories. It checks the exact V1
projection reuse, repaired source binding, canonical V1/catalog/V2 hashes,
bidirectional version rejection, V1-manifest rejection, source capability
ceiling, and fail-closed mutations. It performs no model allocation, Metal
execution, or checkpoint I/O.

A third isolated package validates the maintained-runtime authority and pure
runtime plan in one Metal-free test, then builds a separate Release probe for
the reviewed-main lane. After the frozen 44-test launcher has produced its
same-job pinned-source metallib, a new launcher stages one exclusive candidate,
starts the probe from an empty private working directory with the admitted
environment, requires explicit CoreGraphics and Metal linkage and no dynamic
MLX/Cmlx image, and checks the bounded receipt. This adds no decoder test to
the frozen 44-test inventory and no Driver V2 test resource.

A fourth isolated package and launcher validate the Stage-1 authority and run
the separately scoped tokenizer-to-random-initialized-Native-300M witness.
Their addition extends the existing trusted workflow command list and source
pins without changing workflow topology, the root package, frozen sources or
launchers, existing validation packages, or the 44-test inventory.
The append-only execution observation now binds the exact reviewed-main merge,
environment, same-job metallib metadata, catalog, evaluation, and output
receipt. No rerun of that completed Stage-1 witness is required to begin the
next bounded design.

A fifth isolated one-test package now validates the V2 container/I/O authority,
canonical manifest and external-binding schemas, exhaustive Boolean and
critical scalar mutations, and the exact source capability boundary. It does
not call the codec, allocate Native-300M, create a checkpoint file, or alter the
frozen 44-test launcher. Its separately approved seed-42 hosted successor was
attempted once and source-pinned control flow establishes that the public write
returned before the failure, before the public load or receipt. Neither that
source contract nor the failed execution establishes retained or admitted
checkpoint state; the next boundary is the distinct seed-43 repair below.

A sixth isolated package keeps the one-shot execution mechanics separate from
that declarative test. Its one pure authority test constructs no model and
performs no checkpoint I/O; its Release executable is invoked only after the
frozen Metal, maintained-runtime, and tokenizer launchers on the exact direct
successor. Source-pinned control flow establishes that exact seed-42 attempt
returned from its public write before failing at the first post-write root
stable-identity comparison. The failed run did not emit either root snapshot or
identify the changed field; a separate local APFS reproduction diagnosed the
frozen contract's publication-stable directory link-count assumption. It
reached no public load or V2 receipt marker, and its parent reached no receipt
validation or literal artifact cleanup; the run uploaded zero Actions
artifacts. A second pure test now validates the exact append-only failure
observation without model allocation or I/O. The existing hosted focused step
runs both isolated pure tests with an exact two-test/no-skip assertion. The live
V2 I/O command is absent, both workflow checkouts use depth one, and both job
timeouts are 45 minutes.
The next execution design is a distinct seed-43 repair arc with its own
authority, evidence, isolated package, probe, test, and launcher—not a rerun of
the frozen attempt.

The first external live-Metal run of exact head `84504dc` executed all 41 tests
with no skips but reported 306 assertions. Disabling pinned-MLX TF32 removed
the scalar-reference and single-batch cache differences, leaving 96 assertions
only in rectangular-batch continuation. With the explicit per-row RoPE-offset
repair and TF32 disabled, the external working-tree run executed all 41 tests
with zero failures or skips. The three raw log hashes and byte counts are bound
by the repair authority, but the logs are not retained in the repository. All
three runs used the same externally prebuilt, exact-pinned MLX
`default.metallib`; its hash and byte count are bound, while fresh-build
provenance remains unobserved until the hosted action builds it itself.

That first passing run was a live working-tree mechanics observation before
the distinct-row regression and in-process environment preflight were
strengthened; its intermediate test-source identity was not retained. It is
therefore decoder-mechanics evidence, not a complete source-identical suite
observation.

Commit `8e5d1555506a824d19528fb8dd3e115eb8aefb41` then sealed the repair,
regression, policy, launcher, and source identity. An external Terminal run
executed the rebuilt bundle under `MLX_ENABLE_TF32=0`: 11 authority, 14
checkpoint, and 19 GQA tests all passed, for 44 total with zero failures or
skips. `PrimeNativeDecoderMetalExecutionObservationV1.frozenV1` binds that
revision/tree, the exact raw-log and attachment-transport hashes, and their
single trailing-line-feed difference. The raw bytes are not retained in the
repository.

That predecessor also claimed the exact clean-head active-root and whole gate
sequence completed. The claim is contradicted by the frozen gate itself: its
fixed-substring `Process` matcher included validation sources containing the
required `ProcessInfo.processInfo.environment` preflight. The same matcher
failed both the pull-request and manually dispatched hosted active-root jobs
at `ee5ed4276203b2c1eb299fa4eb17292de604e25d`. The append-only
`PrimeNativeDecoderMetalExecutionObservationCorrectionV1.frozenV1` therefore
preserves the exact 44/44 Metal projection but makes the predecessor's
active-root and whole-sequence completion claims unusable. The Latin claim is
not re-adjudicated by this correction.

The retained projection establishes exact committed-source external Metal
mechanics. The later
`PrimeNativeDecoderGateRepairExecutionObservationV1.frozenV1` binds the
successful exact-head pull-request active-root and Latin gate at
`4a79fb2cb66c55ebc581fb4488ebcf9c7e2382c1`; it does not reinterpret the
reviewed-main job, which was skipped by design. It therefore is not a
GitHub-hosted Metal or freshly built-metallib observation, a published binary
provenance envelope, an admitted runtime policy, checkpoint admission,
training, or model-quality evidence.

The history-preserving merge commit
`b7bad4db76a3ceadba69195ff218af64b19fb716` then ran the complete workflow on
reviewed `main`. `PrimeNativeDecoderReviewedMainMetalExecutionObservationV1`
binds workflow run `31361320313`: the corrected active-root and Latin gates,
focused source contracts, and reviewed-main Metal job all completed on the
same exact clean tree. The `macos-26-arm64` job exposed an
`Apple Paravirtual device`, built exactly one fresh pinned-MLX
`default.metallib` (6,292,716 bytes; SHA-256
`bf45fbb69d87f3cc51b3f8d9ca8a3b114dd155a7a9eee5001092d8fd5f7a7f61`),
staged two byte-identical copies, and passed 11 authority, 14 checkpoint, and
19 GQA tests: 44 total with zero failures, unexpected failures, or skips.

This establishes GitHub-hosted synthetic Metal mechanics and job-scoped fresh
metallib build/staging provenance. It does not identify the physical host GPU,
instrument MLX to prove which staged metallib image it loaded, retain or
publish the metallib or test binary, establish an admitted runtime policy,
execute Native-300M, or authorize training. The later V2 identity is a
separate declarative source/catalog successor, not a projection of this Metal
observation. Exact
byte counts and SHA-256 values bind the two downloaded GitHub job-log endpoint
responses, but no raw log archive or durable log artifact is retained here.

The decoder and V2 identity validation packages deliberately have no
repository-owned SwiftPM mirror. Every gate supplies an isolated
`--config-path`, and the quarantine gate asserts that no package-local mirror
appears. This keeps dependency remapping outside the committed authority
surface while each exact lock remains pinned.

Geometry RenderKit remains a useful Metal lifecycle and CPU/GPU parity-pattern
donor at its pinned audited revision. Prime's existing roadmap explicitly
records that Geometry field/render kernels are not language or quant kernels.
No Geometry checkout is available in this workspace for a fresh source audit,
so this slice neither imports it nor claims that it resolves the current
process's Metal-device visibility. A later test-host arc may source-bind and
adapt a neutral device/bootstrap pattern without making the app a decoder
dependency.

The remaining replacement order is:

1. publish the append-only seed-42 failure observation while retiring its live
   command and restoring the normal workflow timeout and checkout depth;
2. define and independently review a seed-43 corrective execution authority
   that permits the root directory link count to change across publication,
   still requires all stable object fields, exact one-leaf topology, and full
   post-write-to-post-load identity stability, and runs only as a new
   first-attempt direct successor;
3. append either that repair execution's exact success observation or its
   exact failure observation without artifact admission, and retire its live
   command before any later main merge;
4. define generic Prime-owned train/evaluate surfaces and persist exact
   optimizer, RNG, and data-cursor state for trajectory-exact resume;
5. separately authorize bounded training, then produce and bind a non-fixture
   checkpoint with exact training-state and artifact provenance;
6. separately authorize and run a bounded candidate canary/trial;
7. migrate the read-only PMHNP canary consumer to the Prime-owned interface and
   remove its active Llama factory after single-MLX-graph reconciliation;
8. address CoreML/NeuralKit product export only after accepted checkpoint and
   parity evidence.

No training, PMHNP write, or product decision is part of this hosted
observation. Network activity is limited to the separately authorized branch,
pull-request, merge, and GitHub Actions workflow operations.
