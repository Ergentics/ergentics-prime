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
attention implementation. Native-300M GQA geometry is inventory only and is
not allocated or executed by an authority contract.

The separate library-only `PrimeNativeDecoderCheckpoint` target depends
exactly on `PrimeCore`, `PrimeNativeDecoder`, `MLX`, and `MLXNN`. Its public
surface is declarative: an exact Native-300M/Prime-byte-512 checkpoint
compatibility identity, full ordered parameter path/shape/FP32/count catalog,
weights-only manifest schema, canonical little-endian logical tensor hashing,
and explicit state exclusions. Executable save/load mechanics remain internal
and accept only the exact tiny synthetic configuration through caller-owned
regular file descriptors. The loader size-caps the descriptor before MLX,
requires exact canonical metadata and tensor projections, and restores only a
fresh decoder after complete preflight.

This checkpoint slice does not expose native-profile checkpoint write/load.
It owns no path, closes no caller descriptor, and claims no atomic replace,
fsync durability, failed-write recovery, container hash, retained artifact,
artifact provenance, or checkpoint admission. A pinned MLX descriptor write
truncates the borrowed file and may leave it empty or partial on failure; those
bytes remain outside any accepted-artifact boundary.

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

The Metal gate also binds a separate synthetic CI-mechanics policy that starts
without any inherited `MLX_`, `DYLD_`, or `LLVM_PROFILE_` override and sets
only `MLX_ENABLE_TF32=0` before its first Metal or MLX call. No comparison
tolerance was globally widened. This policy does not weaken or satisfy the
frozen maintained-runtime environment policy, which still rejects every
`MLX_` key; an admitted runtime compute-policy successor remains required.

These slices establish the repaired source's exact declarative compatibility
identity in addition to source materialization, compilation, and bounded
synthetic mechanics. They do not define a V2 manifest or codec, establish a
checkpoint artifact or native-profile I/O, admit a runtime compute policy,
close runtime dependencies or initialization, validate tokenizer/model
behavior, train, authorize a trial, replace a canary, quantize, select product
use, or publish. The result remains `ABSTAIN` at those boundaries.

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

1. append an admitted runtime compute policy, establish the exact dependency,
   metallib, device, and initialization closure, and keep it separate from the
   synthetic CI policy;
2. establish tokenizer/model functional compatibility, then define bounded
   native-profile checkpoint container and I/O mechanics;
3. define generic Prime-owned train/evaluate surfaces and persist exact
   optimizer, RNG, and data-cursor state for trajectory-exact resume;
4. separately authorize bounded training, then produce and bind a non-fixture
   checkpoint with exact training-state and artifact provenance;
5. separately authorize and run a bounded candidate canary/trial;
6. migrate the read-only PMHNP canary consumer to the Prime-owned interface and
   remove its active Llama factory after single-MLX-graph reconciliation;
7. address CoreML/NeuralKit product export only after accepted checkpoint and
   parity evidence.

No training, PMHNP write, or product decision is part of this hosted
observation. Network activity is limited to the separately authorized branch,
pull-request, merge, and GitHub Actions workflow operations.
