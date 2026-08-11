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

`PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityPlanV1.frozenV1`
defines that separate corrective arc without modifying any frozen seed-42
source. Only the first attempt of the history-preserving direct successor may
materialize one seed-43 Native-300M source, complete one public V2 write, and
complete one public fresh load in a new fixed private root. Publication
continuity compares only device, inode, owner, group, and mode. Directory link
count and timestamps remain positive, validated observations rather than
stable-object fields because creating the sole leaf changes directory topology.
The root must begin empty, contain exactly the fixed immutable single-link leaf
after publication, and retain its complete post-write identity through the
read-only load. The parent must reconstruct and validate the complete ordered
chunked receipt before literal `unlink`/`rmdir` cleanup. A failure handler is
limited to the same exact root and fixed-leaf inventory, performs no recursive
artifact-root deletion, and cannot establish success. The repair authority is
`ABSTAIN` without a separate exact reviewed-main outcome. It authorizes no
rerun, existing-artifact compatibility, replacement/recovery, retention,
provenance, admission, forward, backward, training, product use, or
publication.

`PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservationV1.frozenV1`
is that append-only outcome. It binds history-preserving merge
`44cfa2caa3af5bb44ad53294de33ba2d0faa9a59`, ordered parents
`1a69407a8fbd5f141e8ece584066b8dcfa6f606f` and
`7314b8a85c5f134c9521b84d2d51d12d3d5084bb`, tree
`fbd57cd9de786e38121fa02b0664b1fb4fcd3d3c`, and direct-main workflow run
`31484642403`, attempt 1. Active-root job `93757136546` and reviewed-main
job `93757733456` completed successfully. Their decoded structured logs are
respectively 225,372 bytes with SHA-256
`a6f948b106edb307a3a826af74bdc82398afba6b1961359e77ec79bb9f069de8`
and 10,348,719 bytes with SHA-256
`caa3e223077cca02d917d2814668a2dc4e36d5e8eed3f60c76689821ed53e588`.
The reviewed job rebuilt the 6,292,732-byte metallib with SHA-256
`d4e858ce07e26d7c82f8218fc7964d05f307db95620242348699cfff33e0d52f`,
then passed the frozen Metal, maintained-runtime, and tokenizer launchers in
that exact order before invoking the seed-43 repair once.

The repair invoked and completed exactly one public V2 write and exactly one
public fresh load. Before the write, the empty 0700 artifact root was bound as
device `16777230`, inode `2970995`, owner `501`, group `20`, mode
`448`, link count `2`, mtime `1786448484.733729583`, and ctime
`1786448484.735646374`. After the write its link count was `3` and both
mtime and ctime were `1786448532.850740833`; every other field was unchanged.
The complete post-load identity matched that post-write identity, giving the
observed `2 -> 3 -> 3` link topology and exact read-only full-root identity.
The root contained exactly
`checkpoint-v2-native300m-seed43-root-identity-repair.safetensors`, a regular,
non-symlink, single-link, 0444 `immutable_data` leaf. Its full container
binding is 1,084,525,304 bytes with SHA-256
`a6dae67b9a24e3d0220d22e3060bb43bab7d8cd027d97ea635db8580774cd538`.
The manifest binds 218 finite FP32 tensors, 271,107,072 parameters, and
1,084,428,288 parameter bytes.

The receipt transport emitted one begin marker, 26 contiguous base64 chunks,
and one end marker with no interleaving. It reconstructs to 77,205 canonical
bytes with SHA-256
`b4aec02aa666433fa7bff5e913629e51f06f5388d21bf9e86d7801ca00dd67bf`.
Its canonical compatibility identity is 30,553 bytes/SHA-256
`aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843`;
the 218 tensor bindings are 35,184 bytes/SHA-256
`7cc7aec0d990a0bb6bb1748de396b84c85af06dea918610343e2f6560c926566`;
the manifest is 66,373 bytes/SHA-256
`6b42dac70d522b248b02d564c8e850f82a28ca12fcfab4ca4db91ea8cc9098e3`;
and the full external binding is 66,854 bytes/SHA-256
`c5a9b8a8aa4301f2dde0ab199bc39771298b1842009836537a085ba4b676d961`.
Only after reconstructing and semantically validating that receipt did the
parent revalidate the exact root and sole leaf, literally `unlink` the leaf,
`rmdir` the empty root, and prove both paths absent. The receipt end preceded
the exact cleanup-success line, and the run published zero Actions artifacts.

This records one process-local V2 checkpoint round trip and its literal
ephemeral cleanup. It does not retain a checkpoint, establish artifact
provenance or checkpoint admission, authorize an existing artifact,
replacement or failed-write recovery, run a loaded-model forward, or grant
training, product, or publication authority. The repair live command is now
removed, the ordinary 45-minute/depth-one workflow bounds are restored, and
the reviewed live sequence remains exactly Metal, runtime, then tokenizer. The
isolated repair package now runs exactly two pure authority/evidence and
outcome-observation tests; both allocate no model and call neither public
checkpoint-I/O entry point.

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
tokenizer successor observes the exact random-initialized Native-300M
full-prefix forward witness, and the root-identity repair successor observes
one exact process-local native-profile write/load followed by literal cleanup.
These execution slices do not establish a retained checkpoint, artifact
provenance or admission, broad model functional or semantic compatibility,
training, trial, canary, quantization, product use, or publication. The result
remains `ABSTAIN` at those boundaries.

### Seed-42 consequence and trajectory-resume design

Seed 42 did not complete its single authorized checkpoint-I/O execution. That
created a permanent evidence gap, not loss of trained model state. Source-pinned
control flow establishes that one ephemeral random-initialized V2 write
returned, so the in-process artifact-root publication and complete external
binding are source-inferred. Execution stopped at the first post-publication
root guard before the binding fields or container hash were emitted or
independently observed. It never reached a public load, receipt begin or end
marker, parent receipt validation, or observed literal supervisor cleanup. The
run uploaded zero Actions artifacts and retained no durable bytes, so there is
no seed-42 checkpoint to admit, recover, or use as a training parent.

The one-shot authority was consumed by that attempt. Repeating the command would
have contradicted the frozen first-attempt contract and blurred failure evidence
with a retry, so the correction required append-only design, test, launcher,
observation, review, and hosted-execution work. The separate seed-43 authority
used a distinct seed-43 random initialization and a repaired definition of
directory continuity. It completed one public write and fresh load and then
deleted the only leaf and root. That outcome validates the repaired mechanics
but neither completes seed 42 nor establishes byte inequality or byte
equivalence with the unavailable seed-42 artifact. It is deliberately ephemeral
and is not an available parent checkpoint. Any future training arc must
establish its own exact initial state and cannot cite either run as retained
resume state.

The dependency-free
`PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1.frozenV1` is the
immediate successor. It is a schema and sequencing authority, not an execution
authority. It keeps the existing V2 checkpoint exactly weights-only. A future
trajectory checkpoint must instead use a separate envelope with externally
bound immutable leaves for exact V2 weights, optimizer state, and canonical
control state; the exclusive canonical commit manifest is published last and
is the only commit point. Uncommitted or partial leaves are non-authoritative
and cannot be discovered and promoted by a loader.

The frozen design records these minimum exact-state requirements:

- the exact model/configuration identity and 1,084,428,288 logical FP32 model
  bytes already bound by V2;
- AdamW first and second moments for all 218 model paths: 436 path-bound FP32
  tensors and 2,168,856,576 logical bytes, plus exact hyperparameter bit
  patterns, schedule identity/current learning rate, and optimizer step;
- Prime-owned, domain-separated model, data-order, augmentation, and evaluation
  key/counter streams, with no implicit global random state;
- exact corpus, tokenizer, split, curriculum, row-order/permutation, batching,
  masking, and next-unconsumed batch identity in the data cursor; and
- a post-update checked-evaluation snapshot boundary where
  `accumulationPhase == 0` and no pending gradients, prefetch, or KV cache
  exists.

The pinned public MLX `RandomState` can expose `innerState()` but provides no
dedicated, supported typed exact-state importer. A public underscored
`MLXArray._updateInternal` mutation path exists, but it is an implementation
detail and is neither a stable nor an authorized resume contract. A future
exact-resume implementation therefore cannot use that path to label implicit
MLX randomness restorable; it must use the explicit Prime-owned streams
required above or gain a separately reviewed pinned typed import API. Likewise,
exact Metal trajectory
replay is not inferred from deterministic seeds: repeated same-device
uninterrupted-versus-resumed assays remain necessary because repeated-token
embedding gradients can reach atomic scatter accumulation. Native-300M resource
sufficiency also remains unproved. The minimum committed model-plus-moment state
alone is 3,253,284,864 bytes before headers, manifests, gradients, graphs, and
temporary buffers.

The predecessor embedded source identity remains a repository-only closure of
414 files, 413 records, 132 directories, and 83,251 canonical bytes. It covers
every repository input used by this design but does not contain or authenticate
external dependency bytes. The design therefore records twelve separate exact
path/mode/blob/byte-count/SHA-256 bindings for the pinned MLX Swift, MLX C, and
MLX sources supporting its optimizer, RNG, protocol/array underscored-mutation,
gather-VJP, and Metal-scatter claims. Two mode-160000 relationships separately
bind the root MLX Swift revision
`d37885a278f1c37484a94d0f401a418735e66519` to MLX revision
`ce45c52505c8158ea48d2a54e8caae05efd86bfe` and MLX C revision
`0726ca922fc902c4c61ef9c27d94132be418e945`. This arc freezes those declared
inputs and tests their exact shape; it does not perform a fresh external
checkout or reclassify them as members of the embedded repository closure.

The authorized stage order is:

1. `trajectory_schema_and_pure_contract_v1` — this declaration and its one pure
   mutation test only;
2. `tiny_cpu_train_evaluate_mechanics_v1`;
3. `tiny_cpu_explicit_rng_cursor_resume_v1`;
4. `tiny_durable_multileaf_commit_fault_injection_v1`;
5. `tiny_repeated_metal_trajectory_determinism_assay_v1`;
6. `native300m_resource_only_one_step_probe_v1`;
7. `native300m_trajectory_checkpoint_execution_v1`; and
8. `retained_trajectory_provenance_and_admission_v1`.

At that boundary only stage 1 was declared. It introduced no training target or
dependency, no train/evaluate implementation, no MLX or optimizer execution,
no checkpoint I/O or artifact root, no Native-300M allocation, no workflow
launcher or model execution, and no timeout or checkout-depth expansion.
Training, exact resume, retention, provenance, admission, trial, canary,
product, and publication authority all remained false.

### Reviewed-main timeout observation and bounded repair

The first reviewed-main execution after the Stage-1 design merge did not
complete. `PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationV1`
binds exact merge/head `5eeba9e6483bafd1bbb5c96753491b3dd1609ea0`, tree
`aeae7b7f0c7ab1eb0236a6a2216789c62a082ea1`, and workflow run
`31509046898`. Active-root job `93837901444` completed all seven steps
successfully in 2 minutes 30.767 seconds. Its decoded log is 227,498 bytes with
SHA-256
`5042f65f7185aa0395b126b4e9cdc8dffee39fb2bc277b9aae4bbf383fe3961a`.

Reviewed-main job `93838685818` was observed for 45 minutes 15.472 seconds and
finished cancelled. Setup, toolchain capture, exact depth-one checkout, pinned
dependency fetch, and focused contracts all succeeded. The focused step took
20 minutes 7.237 seconds by the retained step-member timestamps. Its five
commands completed 38 tests in total with
zero failures or skips: 32 root-package focused tests and groups of 1, 1, 2,
and 2 tests in the four isolated packages. The live step then completed the
frozen Metal suite with 44 tests and zero failures or skips, followed by exactly
one maintained-runtime receipt and its success marker. The tokenizer launcher
started next. It completed only the
`PrimeNativeDecoderTokenizerCompatibilityProbe` product build in 527.15
seconds. The following tokenizer authority-test build reached
`[3/7] Write swift-version-7974D3F7F03D5E95.txt`; the sole subsequent error was
`The operation was canceled.` when the job-level 45-minute timeout fired.
The decoded reviewed log is 10,220,130 bytes with SHA-256
`20844ca1de14ac3f3ab1990494338ea994a353d0b063f36be6669ecaa7219038`.

No tokenizer test suite or probe ran, no Native-300M model was allocated, and
no tokenizer receipt or tokenizer success marker was emitted. The run invoked
no seed-42 or seed-43 one-shot/checkpoint launcher, emitted none of their
markers, and the Actions artifacts API returned the exact empty inventory
`[]`. It was not rerun. The timeout is therefore
`timeout_incomplete_not_semantic_failure`: it neither invalidates the completed
focused, Metal, or runtime evidence nor establishes tokenizer compatibility or
a successful whole reviewed-main sequence.

This append-only observation adds no trainer, evaluator, optimizer, RNG,
cursor, checkpoint I/O, artifact retention, admission, or execution authority.
At that boundary, `tiny_cpu_train_evaluate_mechanics_v1` remained blocked until
a new exact reviewed-main execution completed the retained Metal, maintained
runtime, and tokenizer sequence. The bounded repair raised only the
reviewed-main job limit from 45 to 60 minutes. Active-root remained at 45
minutes; both exact checkouts remained depth one; topology remained two jobs
with five steps each; the only live decoder launchers remained Metal,
maintained runtime, and tokenizer in that exact order; and no upload or
one-shot launcher was added.

### Sixty-minute repair success and Stage-2 mechanics authority

The repair successor merged as
`605d47dde85715f356e4d6e11beb3a3262cc4e7e`, with ordered parents
`5eeba9e6483bafd1bbb5c96753491b3dd1609ea0` and
`defbefcc49a0dea3cbe723af0015a670323fe0e4` and tree
`72200da83e2ae16f3986c525e3a6cd13b47869c4`. Exact-main workflow
`31515766609` completed successfully on attempt one. Active-root job
`93860388811` passed in 2 minutes 31 seconds. Reviewed-main job `93861112336`
passed in 35 minutes 12 seconds, 24 minutes 48 seconds inside the 60-minute
bound. The focused commands passed 39 tests total. The final live step then
completed the exact sequence of 44 Metal tests, one maintained-runtime receipt
and pass, and one tokenizer receipt and pass. The sealed active and reviewed
job-log SHA-256 values are respectively
`3cd63de60767b4a5bad072a5c444eea4fa167342d28c1e21fc4e26c6577b9e9d`
and `ac682eb0ab4a179f5e621b731d176a73879ce2ceba55ff7a5dc0dd1a19b8b391`.
The run had no rerun, retired checkpoint command or receipt marker, upload
step, or Actions artifact. This clears the Stage-2 sequencing prerequisite; it
does not itself establish train/evaluate or resume mechanics.

The append-only
`PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1.frozenV1`
authorizes one exact implementation and validation boundary:

- a new `PrimeNativeDecoderTraining` product and target with exactly
  `PrimeCore`, `PrimeNativeDecoder`, `MLX`, `MLXNN`, and `MLXOptimizers` as
  dependencies; the checkpoint target is intentionally deferred;
- one package-scoped rank-two decoder seam that performs full-prefix no-cache
  forward computation without exposing a public raw-`MLXArray` decoder API;
- one fixed true-GQA CPU fixture with vocabulary 32, width 16, two layers,
  four query heads, two key/value heads, head width 4, intermediate width 32,
  maximum sequence length 16, maximum batch size 2, seed 7, 20 parameter
  paths, and 5,200 FP32 parameters;
- rectangular right-padded batches whose `validTokenCounts` define the valid
  prefix and whose token-aligned completion masks are `false* true+` before
  padding. Token ID zero remains valid content inside that prefix; only suffix
  positions are required to contain the fixed zero filler and a false mask;
- causal cross-entropy at logits columns `0..<S-1` against token columns
  `1..<S`, explicit zero label smoothing, reduction none, and one global sum
  divided by the exact selected-target count;
- a Prime-owned FP32 gradient norm: every path must be present, unique,
  finite, nonzero, shape-exact, and FP32; paths are ordered by raw UTF-8 bytes;
  per-tensor sums of squares are left-folded in that order; threshold 1 and
  epsilon `1e-6` are exact Float32 values; and equality takes the scaled branch
  `1/(norm+1e-6)`;
- pinned constant-rate AdamW with exact Float32 hyperparameter bits, no bias
  correction or internal step counter, complete first and second moments for
  all 20 paths, and one Prime-owned step moving only from zero to one to two;
  and
- two independent same-seed trainers in one process, exact per-step loss,
  parameter, and moment equality, read-only no-cache evaluation, and a third
  step rejected before graph construction or mutation.

The root manifest necessarily changes to add that target. Its lock refreshes
only the `originHash`; the exact MLX and Swift Numerics pins and revisions do
not change. The package-only seam also changes the decoder file's byte
identity. All older V2, runtime, and tokenizer source bindings remain frozen
historical evidence, but they are not silently projected onto the modified
decoder. This Stage-2 authority establishes no new checkpoint compatibility,
artifact provenance, or admission; the later durable-composition stage must
bind the then-current decoder and state identities explicitly.

The attached Codex app sandbox has no visible Metal device. Pinned MLX creates
its process-level Metal scheduler state before returning even a default CPU
stream, so local execution stops before trainer initialization. The isolated
test performs only a test-scoped CoreGraphics/Metal discovery check before any
MLX device access and may skip on that incapable local host. That skip is not a
pass or execution observation. Trusted reviewed main must execute exactly one
test with zero skips and failures, and the test asserts that all tensor work is
on CPU. The test-only scheduler bootstrap does not authorize GPU or Metal
tensor operations.

This authority remains below checkpoint I/O, artifact creation, filesystem
mutation, explicit RNG/cursor state, restart or resume, Metal determinism,
Native-300M allocation or training, quality, candidate admission, trial,
canary, product, and publication. General rollback after a post-optimizer
validation failure is not established; continuation from such a trainer is
forbidden. Stage 3 remains blocked until an append-only observation binds a
successful exact-main Stage-2 execution.

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
checkpoint state. The distinct seed-43 repair and its observed outcome remain
separate below.

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
V2 I/O command is absent. At that predecessor boundary, both workflow checkouts
used depth one and both job timeouts were 45 minutes.

A seventh isolated package kept the seed-43 correction distinct from the
exhausted seed-42 package. Its first pure test validates the repair authority,
evidence, and chunk transport without model allocation or checkpoint I/O. The
one authorized reviewed-main execution then passed Metal, runtime, and
tokenizer before exactly one public write and one public fresh load, emitted
the complete bound receipt, and completed literal parent cleanup. Its
append-only outcome observation adds a second pure mutation/source-identity
test. The focused step now requires exactly two tests with no skips for this
repair package. The live repair command is absent. At that repair boundary,
both checkouts used depth one, both jobs used 45-minute limits, and the only
reviewed live launchers were the frozen Metal, maintained-runtime, and tokenizer
sequence.

The trajectory-resume design authority is compiled and exercised by one pure
`PrimeCoreTests` mutation test in the existing focused source-contract command.
It adds no validation package, dependency checkout, workflow job or step, model
allocation, checkpoint I/O, or live launcher. The active-root parser and gate
pin the exact source and test identities. At that design-only merge, the
workflow preserved two jobs, five steps per job, 45-minute timeouts, depth-one
checkouts, and the reviewed live order Metal, maintained runtime, then tokenizer
compatibility.

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

1. obtain and record the separately authorized tiny CPU train/evaluate hosted
   execution, then separately implement and execute explicit RNG/cursor state;
2. prove tiny durable multi-leaf commit behavior and repeated tiny Metal
   trajectory determinism;
3. run the separately authorized Native-300M resource-only probe, then decide
   whether Native-300M trajectory-checkpoint execution is supportable;
4. separately establish retained trajectory provenance/admission and only then
   authorize bounded training that can produce a non-fixture checkpoint;
5. separately authorize and run a bounded candidate canary/trial;
6. migrate the read-only PMHNP canary consumer to the Prime-owned interface and
   remove its active Llama factory after single-MLX-graph reconciliation; and
7. address CoreML/NeuralKit product export only after accepted checkpoint and
   parity evidence.

No training, PMHNP write, or product decision was part of the checkpoint
observation or the Stage-1 design-authority arc. Stage 2 is limited to its
separate two-step tiny CPU mechanics fixture and grants no PMHNP or product
authority.
