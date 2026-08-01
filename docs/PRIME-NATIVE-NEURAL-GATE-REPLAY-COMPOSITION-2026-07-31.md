# Prime Native Neural Gate Replay Composition

Date: 2026-07-31

## Outcome

Stage B has a pure Swift composition boundary for the three independently
canonicalized V4 corrected-replay record streams plus a separately validated
in-memory logit sidecar. It now also has a descriptor-rooted source adapter
outside that pure target. Together they implement:

- one producer/decoder-shared bounded canonical JSON codec in
  `PrimeNativeNeuralGateReplayTransport`;
- one strict prompt-derived execution schedule over exactly 18,432 canonical
  prompt records; and
- one exact, keyed outer/raw/validated-logit-sidecar join that reconstructs
  every decision and requires the corrected `PRIMECRT4` trace to match;
- one incremental prompt-schedule reconstruction that binds each canonical row
  and the exact `PRIMEIRM1` global digest without allocating a second complete
  stream; and
- one sealed four-source wrapper over descriptor-bound prompt, outer, raw, and
  logit artifacts.

The new package target is:

```text
PrimeNativeNeuralGateReplayComposition
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayTransport
      - PrimeNativeNeuralGateReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateLogitSidecarMechanics
```

It has no dependency on `PrimeCore`, corpus/fixture authority, evaluation or
regrade mechanics, the prompt solver, MLX, a historical runtime, PMHNP, a
worker, a process supervisor, or a receipt writer.

Descriptor admission and the outer wrapper are isolated in
`PrimeNativeNeuralGateReplaySourceBinding` and
`PrimeNativeNeuralGateReplaySourceComposition`. The latter depends only on
source binding, this unchanged pure composition target, and the target-free
schedule-delivery contracts. See
`PRIME-NATIVE-NEURAL-GATE-DESCRIPTOR-SOURCE-BINDING-2026-07-31.md`.

This remains repository mechanics, not Stage-B execution. The pure target
reads no descriptor-rooted record stream or durable logit artifact. Its
validated values remain non-`Codable` and keep durable origin false. The V4 outer
source wrapper proves one exact four-capability keyed join, but separate binds
under an equal root identity do not prove a common capture epoch or descendant
inventory. It therefore also keeps durable origin false. Prompt/target binding,
prompt-content target independence, process delivery, model execution,
mechanics `PASS`, publication, science, receipt, and product authority remain
false.

Additive topology V5 wraps that unchanged composition with
`PrimeNativeNeuralGateReplayCaptureInventory` and
`PrimeNativeNeuralGatePromptTargetCrosswalkAuthority`. The first retains the
exact 41-file held-root inventory and authoritatively rebinds all four sources;
the second binds the resulting schedule/join to the independently
source-derived 18,432-row keyed prompt/target crosswalk. The focused integration
passed in 300.125 seconds. Durable origin is promoted only for the captured
four-source bytes; the pure composition values remain unchanged and
non-authorizing.

## Frozen identities

- semantic artifact namespace V4 remains byte-for-byte unchanged at SHA-256
  `60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1`;
- composition V1 is
  `prime_stage_b_strict_prompt_schedule_exact_cross_artifact_join_v1`,
  canonical SHA-256
  `75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e`;
- source composition V1 is
  `prime_stage_b_descriptor_source_bound_schedule_delivery_v1`, canonical
  SHA-256
  `f3d0a58905065836caaae8c9d03c1b2840b07bcd1a4f0bf35f1ce638c6ac29b5`;
- capture inventory V1 has canonical SHA-256
  `ae3477c44af1f36a111a6312a88a6b86995ddad231c9225a069173860ed29878`;
- crosswalk authority V1 has canonical SHA-256
  `b4a994635c2d7fafe8f9d47587122beee149533013b69592242bcba33b60ea67`;
- topology V4 is `prime_stage_b_descriptor_source_binding_topology_v4`,
  canonical SHA-256
  `8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af`;
- topology V3 is `prime_stage_b_trap_disjoint_topology_v3`, canonical SHA-256
  `b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd`;
- topology V1 remains exact at
  `48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5`;
  and
- topology V2 remains exact at
  `abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415`.

Topology V4 remains exact history. The additive topology V5 is now an exact
historical boundary:
`prime_stage_b_held_root_capture_crosswalk_authority_topology_v5`; its canonical
SHA-256 is
`252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930`.
Historical topology V6 is
`prime_stage_b_process_evaluation_receipt_ownership_target_free_delivery_topology_v6`,
SHA-256
`6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1`.
The global status remains `planned_not_materialized`, with
`executionImplemented == false` and source binding V7 unissued. Neither V5 nor
V6 promotes any planned worker or supervisor.
Current topology V7 is
`prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7`,
SHA-256
`88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156`.
It preserves that global status and is distinct from the unissued
source/execution-binding V7.

## V3 package-capture checkpoint

After the complete topology-V3 source reseal, the Release canary passed with
byte-identical probe/verifier package-description output: 29,905 bytes, SHA-256
`ad4a66338d7348cb44419a115e062a30da129dea9a6355eec81f6b98932b6e11`.
This is the last accepted historical topology-V3 actual-package secure-capture
reseal.
Topology V1 and V2 capture values remain historical checkpoints.

The V3 pass validates only the secure-capture substrate on the pinned host. It
is not V6/V7 selected-source execution-graph proof; it does not issue source
binding V7 or establish worker or model execution, fixture identity,
evaluation or mechanics `PASS`, Stage-B publication or a terminal receipt,
reproducible-build identity, or network denial.
It predates topology V4 and is not reused as V4 package-capture evidence.

## V4 package-capture checkpoint

After the complete topology-V4 source reseal, the Release canary passed with
byte-identical probe/verifier package-description output: 32,735 bytes,
SHA-256
`f7d873db2b91ecc61d356136b37bf7bc8017db962f40637998de914eeaa8d894`.
This is the last accepted historical topology-V4 actual-package secure-capture
reseal.
After the additive topology-V5 source reseal, the same Release canary passed
with byte-identical probe/verifier package-description output: 36,047 bytes,
SHA-256
`88571dc5cc4d15f11395430ab9ea410aba6cafa295edebe54acff816585a3fbb`.
The V4 bytes were not reused as V5 evidence.
It validates only the secure-capture substrate on the pinned host. It does not
establish V6/V7 selected-source execution-graph reconciliation, source binding
V7, worker/model execution, fixture identity, evaluation or mechanics `PASS`,
Stage-B publication, a terminal receipt, reproducible-build identity, network
denial, Metal authority, scientific authority, or product authority.

## Shared canonical codec

`PrimeNativeNeuralGateReplayTransportCodec` is the only bounded JSON producer
seam for the three implemented record shapes and their three manifests. Its
serialization contract is
`prime_stage_b_bounded_canonical_json_shared_transport_codec_v1`.

The codec accepts semantic fields, not a caller-authored wire envelope. It
derives schema and kind IDs, paths, chunk ordinals and counts, the exact record
count, and all false authority flags from frozen V4. For a raw row it derives
the decision count from termination and generated-token count; a caller cannot
supply that redundant field. A manifest input from the invariant codec is
treated as untrusted and must satisfy its exact identity, partition, ordinal,
count, digest, and byte bounds. Every produced value is decoded again through
the same bounded decoder before its bytes are returned.

Known-answer tests bind exact bytes for prompt, outer, and raw rows plus the
exact manifest byte count and SHA-256. Negative tests reject invalid
fixed-cap/EOS accounting, oversized semantic inputs before encoding, and
manifest count or ordinal changes. A future worker must use this codec;
hand-authored JSON is outside the contract.

## Strict prompt schedule

The schedule is not a row-ID order and is not inferred from outer, raw, or
sidecar records. It is the strict zero-based ordinal of each canonical
prompt-row JSON record. The source adapter now proves that this exact sequence
reconstructs the descriptor-bound prompt global-stream digest:

```text
execution_index = ordinal(canonical_prompt_row_bytes)
```

`makePromptSchedule` requires exactly 18,432 records in strict raw-byte
lexicographic order. It validates only in-memory bounded shape, exact
count/order, codec round trip, corrected prompt-token derivation, and unique
`PRIMECPI2` bindings. It rejects any failure of those checks, recomputes the
invariant global-stream SHA-256, and derives a schedule identity from
`PRIMESCH1`, the big-endian record count, and the raw global-stream digest. The
magic and exact serialization are part of composition V1 and the schedule has
full known-answer SHA-256 coverage.
The historical whole-array API still does not validate a descriptor,
filesystem object, manifest binding, or durable source origin. The additive
typed-observation API re-encodes and digest-checks one row at a time and uses
the incremental `PRIMEIRM1` accumulator. The separate source wrapper, not the
pure V1 schedule, carries descriptor origin.

The schedule does not silently sort input. Sorting would conceal whether the
caller had actually validated the source stream. The resulting capability
therefore records exact coverage and strict order but explicitly records that
source-stream binding and mechanics `PASS` are not established.

The existing exhaustive logit-sidecar repository test historically emits
`rowOrdinal` in corrected fixture row-ID order. That remains valid mechanics
coverage for dictionary/chunk reconstruction, but it is not durable Stage-B
schedule authority. A future artifact producer must emit sidecar row ordinals
as the prompt-record schedule indexes defined here.

## Exact cross-artifact join

For one admitted replicate seed, the composition join requires:

- exactly 18,432 outer rows and a complete unique execution-index bijection;
- exactly 18,432 raw rows, a complete unique execution-index bijection, and
  the requested replicate seed on every row;
- a previously validated 18-chunk lossless sidecar containing exactly 18,432
  rows under the same replicate seed;
- globally unique outer correlation IDs;
- exact raw `PRIMECPI2` prompt binding at every schedule index;
- exact outer and sidecar correlation equality with the schedule-derived
  `PRIMECOR1` identity at every index; and
- exact equality between sidecar decision count and raw decision count.

`PRIMECOR1` hashes the big-endian execution index plus the raw `PRIMECPI2`
prompt-binding digest. It is target-free: neither producer chooses a free-form
coordination string. The outer adapter now constructs a raw role projection
containing index, prompt, prompt binding, and correlation, plus an outer role
projection containing only index and correlation. No process receives either
projection yet, so `processDeliveryObserved` remains false and no worker
topology is claimed.

The join indexes each stream independently; input array order is irrelevant
and positional zipping is never used. It resolves every sidecar dictionary
index into the complete 512-value Float32 logit vector, reconstructs each
corrected completion decision, reruns
`PrimeNativeNeuralGateRawExecution.validate`, and then requires exact generated
tokens and `PRIMECRT4` trace SHA-256 equality with the raw reference.
EOS/fixed-cap shape is already fixed by raw decision/generated-token accounting
and reconstructed decisions. A copied correlation ID or self-consistent raw
summary cannot launder unrelated logits through this join.

Mutations cover duplicate or missing indexes, duplicate correlations,
cross-seed rows, prompt and trace digest changes, generated-token and
termination changes, sidecar correlation/count/seed changes, and an exact
Float bit-pattern change. The full 18,432-row join is exercised with outer and
raw inputs independently reversed to prove that the implementation is keyed,
not positional.

The unchanged pure V1 join deliberately does not establish that an outer expected completion is
the source-authoritative target for the scheduled prompt. Swapping two expected
completions while preserving their indexes is outside the raw trace and cannot
be detected from these in-memory values alone. The result therefore records
corrected-fixture identity and outer expected-completion binding as false. A
separately derived prompt/target crosswalk is mandatory before grading or any
promotion. The V4 source wrapper additionally requires one held-root identity
across prompt, outer, raw, and logit capabilities. That check rejects
cross-root substitution, but it does not detect nested replacement between
separate bind calls and does not mark durable origin true. Topology V5 closes
that specific gap with a retained exact inventory plus authoritative rebind and
then requires exact outer expected-completion bytes through the source-derived
keyed crosswalk. It still does not grade or execute a model.

## Remaining truth gap

Descriptor-rooted invariant validation, source-bound logit validation,
incremental schedule reconstruction, typed role projections, the exact
four-source join, one held-root capture epoch, and the independently
source-derived crosswalk remain implemented. Topology V6 additionally
freezes the exact ten-role ownership model, branch-scoped raw/evaluation
records, verifier-only receipt-last ownership, byte-bounded strict slot
decoding, and `Encodable`-only aggregate target-free candidates. Its real
supervisor-only wrapper retains the capture across projection and binds the
candidate content to exact branch owners, but it does not deliver a schedule.
Topology V7 adds exact-count bounded `PRIMEIRM1` raw/outer stream admission,
typed common/branch/twenty-path artifact-reference declarations, six four-part
Release worker-source declarations, and a retained-capture reference adapter.
Aggregate candidates remain non-`Decodable`. Real common/branch scalar
references are supervisor-derived and non-authorizing; realized worker-source
and role-artifact content references remain absent.
The next implementation prerequisite is:

`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`

The next slice must freeze the deferred mutation, historical, MLX, and
statistics/verdict schemas, then assign disjoint source-bound mutation
producer/detector targets. Prompt-content target
independence, process delivery, model execution, evaluation/verdict authority,
mechanics `PASS`, receipt, science, and product authority remain false. The
historical runtime and all supervisors/workers remain planned. See
`PRIME-NATIVE-NEURAL-GATE-PROCESS-OWNERSHIP-TARGET-FREE-DELIVERY-2026-07-31.md`
and
`PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md`.

## Additive V8 continuation

The V7 prerequisite above is satisfied by topology V8,
`prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8`,
SHA-256
`8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b`.
V8 preserves composition V1, semantic namespace V4, and V7's exact twenty
corrected pre-receipt paths. It freezes the deferred semantic schemas and adds
four internal Swift targets: the narrow label-free, presence-only surface
contract; the semantic catalog/identity contract; the corrected producer; and
the independent detector. The corrected mutation catalog/control contract has
SHA-256
`9b40258ed7ba07dc62ff6bda96df03b2233575a039b5598b487d738d036a78bd`;
the role-specific assignment contract has SHA-256
`020fa5275a4ab7941b935271ad26b094b35b96c9fb85be765db1dd9130de36e2`.
The producer directly depends on semantic plus surface contracts. The
detector directly depends only on the surface contracts, and its transitive
local closure contains only surface plus replay mechanics. The catalog,
identity, expected-leg mapping, replay-artifact contracts, and producer are
therefore structurally unavailable to the detector.
Its sole public entry requires exactly 15 triplets as one batch; singleton
detection is private. Every full bound baseline/restored context must match in
bytes and binding across the batch, while mutated surfaces must be pairwise
distinct. Wrong counts, duplicate cases, per-case reference-hash or seed drift,
and cap drift other than exact 63 against baseline 64 are rejected.
Permutation invariance is verified. `Label-free` excludes explicit mutation
IDs/labels, arbitrary prediction strings, and per-case caller-controlled
context.
Their in-memory mechanics do not change composition authority: actual Release
source references, process delivery, durable observations, verdicts, and
receipts remain absent and non-authorizing, and source/execution-binding V7
remains unissued.

Composition does not turn a leg count into evidence. `countDerivedLabel` is
scoped `provisional_count_only_non_authorizing`; ten bare true critical legs
still yield `ABSTAIN`. `GROUNDED` requires verified/durably published evidence
per true leg, weighted-statistics recomputation, stable-greedy and behavioral
fixed-prompt predicates, model capability including exact abstention decisions,
the mutation sweep, source-bound leg evidence, distinct implementation
families, and four-tier audit state. The live exported
`PrimeNativeNeuralGateCountDerivedVerdict.recompute(legs:)` API is retained but
always emits `ABSTAIN` with only the provisional scope and cannot emit generic
`GROUNDED`. Historical `GROUNDED` additionally requires all five aggregate
references verified/durably published and model execution observed. These
inputs remain absent and all authority remains false.

Historical actual-package canaries were V6 at 40,100 bytes, SHA-256
`99431ac9477a6546225721027319fc460ff8b10c8e55ef68f07b5cb8c73c8cd9`,
and V7 at 41,951 bytes, SHA-256
`770b719a7e594f95e422f40dc5d4acd0fd93241928416a6bb3f27a448791f928`,
with V7 source identity
`9cdfe7bfcbbedebce59b7abb45b614778e6674391b570a679ea40728be4c514f`.
That was the V8 prevalidation state. Completed final V8 validation is recorded
canonically in the
[V8 semantic-schema and mutation-target record](PRIME-NATIVE-NEURAL-GATE-SEMANTIC-SCHEMA-MUTATION-TARGETS-2026-08-01.md).

The V8 next prerequisite was
`derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7`.
Topology V9 now satisfies it without changing replay composition or
materializing a worker. Topology V10 then adds only the unreachable internal
historical source closure and non-authorizing seam. Its next prerequisite was
`derive_and_source_bind_source_faithful_historical_fixture_then_materialize_only_the_sealed_historical_worker_without_materializing_probe_verifier_or_issuing_source_binding_v7`.
Topology V11 now source-binds the fixture and adds only an unavailable
executable target; replay composition authority is unchanged. The current next
prerequisite is
`derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7`.
See [Prime Native Neural Gate Historical Source Material](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-SOURCE-MATERIAL-2026-08-01.md).
See [Prime Native Neural Gate Historical Replay Mechanics](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-REPLAY-MECHANICS-2026-08-01.md).
See [Prime Native Neural Gate Historical Fixture and Worker Boundary](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-FIXTURE-WORKER-BOUNDARY-2026-08-01.md).
