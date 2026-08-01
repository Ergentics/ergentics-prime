# Prime Native Neural Gate Descriptor Source Binding

Date: 2026-07-31

## Outcome

Stage B now has a Swift-only descriptor source boundary and an outer
source-composition adapter. The implemented targets are:

```text
PrimeNativeNeuralGateReplaySourceBinding
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayTransport
      - PrimeNativeNeuralGateReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateLogitSidecarMechanics

PrimeNativeNeuralGateReplaySourceComposition
    dependencies:
      - PrimeNativeNeuralGateReplaySourceBinding
      - PrimeNativeNeuralGateReplayComposition
      - PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts

PrimeNativeNeuralGateReplayCaptureInventory
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplaySourceBinding

PrimeNativeNeuralGatePromptTargetCrosswalkAuthority
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateCorrectedFixtureAuthority
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateReplayCaptureInventory
      - PrimeNativeNeuralGateReplayComposition
      - PrimeNativeNeuralGateReplaySourceComposition
      - PrimeNativeNeuralGateReplayTransport
```

The pure `PrimeNativeNeuralGateReplayComposition` target remains unchanged in
authority and remains free of `PrimeCore`, filesystem, process, fixture,
evaluation, and model dependencies.

This slice implements no worker or model run. The V5 wrappers establish
corrected fixture identity and the independent keyed crosswalk, but create no
Stage-B process record or receipt, do not issue source binding V7, do not
establish prompt-content target independence, and cannot authorize mechanics
`PASS`, science, publication, or product use.

## Frozen identities

- source-reader contract:
  `prime_stage_b_descriptor_rooted_exact_source_binding_v1`;
- outer source-composition contract:
  `prime_stage_b_descriptor_source_bound_schedule_delivery_v1`, canonical
  SHA-256
  `f3d0a58905065836caaae8c9d03c1b2840b07bcd1a4f0bf35f1ce638c6ac29b5`;
- unchanged pure composition V1, canonical SHA-256
  `75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e`;
- topology V4:
  `prime_stage_b_descriptor_source_binding_topology_v4`, canonical SHA-256
  `8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af`;
- topology V5:
  `prime_stage_b_held_root_capture_crosswalk_authority_topology_v5`, canonical
  SHA-256
  `252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930`;
- capture inventory V1, canonical SHA-256
  `ae3477c44af1f36a111a6312a88a6b86995ddad231c9225a069173860ed29878`;
- crosswalk authority V1, canonical SHA-256
  `b4a994635c2d7fafe8f9d47587122beee149533013b69592242bcba33b60ea67`;
- topology V1, V2, and V3 remain exact historical contracts; and
- semantic artifact namespace V4 remains exact at SHA-256
  `60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1`.

Topology V4 remains exact history. Topology V5 is now the exact historical
held-root/crosswalk boundary. Historical topology V6, SHA-256
`6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1`,
adds the non-authorizing target-free schedule, process/evaluation/receipt
ownership, and retained-capture binding boundaries. It remains globally
`planned_not_materialized` and keeps `executionImplemented == false` and
`sourceBindingV7Issued == false`.
Current topology V7,
`prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7`,
SHA-256
`88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156`,
adds exact-count bounded stream admission and typed copied-reference
declarations without widening that authority ceiling. Real common/branch
scalar references are supervisor-derived and non-authorizing; worker-source
and role-artifact content references remain absent.
Topology V7 is distinct from the still-unissued source/execution-binding V7.

## Descriptor admission

The source target accepts an already-admitted `PrimeArtifactRoot`, or creates
one from the URL convenience entry point. Child traversal, no-symlink lookup,
regular-file admission, exact owner/mode/link policy, ACL and extended-
attribute policy, descriptor-relative name-to-vnode checks, byte count,
SHA-256, and pre/post stability are delegated to
`PrimeArtifactRoot.withVerifiedArtifactDescriptor`. The source target does not
reimplement `openat` path walking.

`PrimeArtifactRoot.verifiedRootIdentity()` exposes a sealed value derived from
the held root descriptor. Each operation requires the root identity before and
after materialization to be identical. Each returned source capability records
the root identity plus exact admitted file observations. These observations
are not caller-authored booleans and are not serializable authority tokens.

The source target opens no writable artifact handle. Its only low-level system
operation is bounded reading from the borrowed, already-verified descriptor.

## Incremental invariant stream validation

`PrimeNativeNeuralGateInvariantFramedRecordReader` is the shared pure parser
for both frozen envelopes:

- `PRIMEIRM1` global stream; and
- `PRIMEIRC1` chunk stream.

It receives descriptor bytes in blocks of at most 64 KiB, retains at most the
current and previous record plus bounded unmatched records, and rejects before
record allocation when the declared length exceeds the schema-specific row
limit. The transport target owns those exact limits:

- prompt row: 65,536 bytes;
- outer-evaluation row: 8,192 bytes; and
- raw-execution reference: 8,192 bytes.

The reader verifies magic, declared count, chunk ordinal, per-record and
aggregate bounds, integer conversions, UTF-8, canonical order, exact EOF,
exact stream byte count, and exact stream SHA-256. A parse or callback failure
poisons the reader. It cannot resume or emit a validated summary after partial
failure.

Source binding holds the verified global descriptor while it opens each
verified chunk. Global and chunk records are compared byte-for-byte in
lockstep, including across chunk boundaries. Exact V4 partitioning is enforced
as four 4,096-record chunks plus one 2,048-record chunk. Complete invariant
stream bytes are never assembled in one `Data` value; the typed 18,432-row
result array is intentionally materialized for the existing pure composition
API.

`PrimeNativeNeuralGateInvariantGlobalStreamSHA256Accumulator` separately
reconstructs the exact `PRIMEIRM1` hash from one canonical record at a time.
The pure composition target uses it to check the descriptor-observed global
digest without re-encoding a second complete global stream.

## Sealed source capabilities

The source target returns separate, non-`Codable`, non-publicly constructible
capabilities for:

- prompt records, with each typed row's canonical-record SHA-256 and the exact
  global-stream SHA-256;
- outer-evaluation rows;
- one seed-scoped raw-execution stream; and
- one seed-scoped validated lossless-logit sidecar.

The logit path descriptor-binds its manifest, dictionary, and all 18 chunks,
then delegates semantic reconstruction to the existing frozen complete
sidecar validator. Unlike the invariant parser, that existing codec requires
bounded `Data` materialization of the dictionary and chunks. This slice does
not claim a non-materializing logit codec.

An individual V4 source capability records `sourceStreamBindingEstablished ==
true`, but keeps durable replay origin false. Each capability is one separately
observed role. Topology V5 does not mutate those frozen values; it wraps their
authoritative rebind in a retained exact whole-root inventory capability and
requires final unchanged recapture before promoting bounded durable origin.

## Schedule projection and exact source join

The outer adapter reconstructs the unchanged pure V1 prompt schedule from the
sealed prompt capability. For every row it:

1. re-encodes the typed prompt row through the shared canonical codec;
2. requires the re-encoded record's SHA-256 to equal the source-bound
   canonical-record digest;
3. requires strict record order and unique `PRIMECPI2` prompt bindings;
4. derives the exact `PRIMECOR1` correlation identity; and
5. requires the incremental `PRIMEIRM1` digest to equal the held descriptor's
   global-stream digest.

The underlying V1 schedule remains non-authorizing and still records source
binding false. The outer wrapper, rather than mutating V1, carries the sealed
source identity.

Two asymmetric role projections are implemented:

- raw projection: execution index, prompt token IDs, canonical prompt text,
  `PRIMECPI2` binding, and `PRIMECOR1` correlation only; and
- outer projection: execution index and `PRIMECOR1` correlation only.

Neither projection contains an expected completion. The outer projection
contains no prompt text, prompt token IDs, or direct `PRIMECPI2` binding;
its `PRIMECOR1` value remains deterministically prompt-binding-derived and is
therefore linkable. They are typed in-memory projections, not observations of
delivery to a separate process; `processDeliveryObserved` remains false.

The V4 complete source join requires prompt, outer, raw, and logit capabilities
to share one exact held-root identity and requires raw/logit replicate seeds
to match. It then calls the existing keyed V1 join. Array position is never a
join key. Root identity does not cover nested replacement between separate
bind calls, so the resulting four-source wrapper records exact capability join
true but single-capture epoch and durable artifact origin false. Independent
prompt/target crosswalk, expected-completion binding, prompt-content
independence, process delivery, model execution, mechanics `PASS`, receipt,
science, and product authority all remain false.

The additive V5 capture discovers the exact 41-file set, discards discovery
values, captures the complete descriptor-rooted inventory, rebinds all four
sources while that capability is live, and requires final unchanged recapture.
The downstream crosswalk then establishes corrected fixture identity, the
independent source-derived 18,432-row keyed prompt/target association, and exact
outer expected-completion binding. Prompt-content target independence, process
delivery, model execution, mechanics `PASS`, receipt, science, and product
authority remain false.

## Verification

Focused verification covers:

- every feed split point for known global and chunk streams;
- exact parity between incremental and frozen whole-buffer encoders/decoders;
- wrong magic, truncation, trailing bytes, early and repeated finish,
  consume-after-finish, callback failure/reentry, invalid UTF-8, ordering,
  count, length, aggregate, and overflow failures;
- parity acceptance for valid zero-length and duplicate ordered-multiset
  records;
- manifest/path/count/order/digest/size and global/chunk divergence;
- symlink, hard-link, writable-mode, wrong-size, wrong-hash, and typed-record
  mutation rejection;
- exact incremental prompt schedule equality and rejection of
  canonical-record-digest/`PRIMECPI2` digest-domain substitution;
- a real 18,432-row prompt/outer/raw/logit artifact publication and
  descriptor-source join;
- the exact 41-file held-root capture, authoritative four-source rebind, final
  recapture, and source-derived crosswalk over all 18,432 rows;
- independently canonicalized input ordering, proving the join is keyed and
  not positional;
- root and replicate-seed substitution rejection; and
- same-root nested outer-artifact replacement between binds, including an
  expected-completion swap, proving the exact join cannot promote a set of
  separately captured capabilities to one durable epoch.

The focused replay family passed 54/54 before the complete topology-V4 package
reseal. The focused topology-V5 held-root/crosswalk integration passed in
300.125 seconds.

## Package-capture checkpoints

The historical topology-V4 Release two-role canary passed with byte-identical
probe/verifier package-description output: 32,735 bytes, SHA-256
`f7d873db2b91ecc61d356136b37bf7bc8017db962f40637998de914eeaa8d894`.
This is actual-package secure-capture evidence on the pinned host, not V6/V7
selected-source execution-graph reconciliation. It does not establish source
binding V7, execution, evaluation, publication, a receipt, reproducible-build
identity, network denial, Metal authority, scientific authority, or product
authority.

The additive topology-V5 Release canary passed with byte-identical
probe/verifier package-description output: 36,047 bytes, SHA-256
`88571dc5cc4d15f11395430ab9ea410aba6cafa295edebe54acff816585a3fbb`.
It carries the same secure-capture-only authority ceiling. The historical V4
canary is not relabeled as V5 evidence.

## Historical V6 continuation and current V7 truth gap

The held-root inventory and independent source-derived crosswalk prerequisite
remains implemented and verified. Topology V6 froze the replacement
ten-role process/evaluation/receipt ownership declarations, target-free
schedule candidate shapes, and a supervisor-only retained-capture binding
wrapper. That wrapper is real, but delivery remains false. Individual slot
decoding is strict and byte-bounded. Topology V7 now adds exact-count bounded
`PRIMEIRM1` raw/outer stream admission while keeping aggregate candidates
non-`Decodable`, plus typed common/branch/artifact and worker-source reference
declarations under the retained capture/schedule identity. Real common/branch
scalar references are supervisor-derived and non-authorizing; realized worker-
source and role-artifact content references remain absent. The immediate
implementation prerequisite is:

`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`

Stage B must next freeze the deferred mutation, historical, MLX, and
statistics/verdict schemas, then assign a disjoint source-bound mutation
producer/detector pair. Mutation assignment remains deferred and must not share
implementation authority with the detector.
Historical runtime, all supervisors/workers, probe, verifier, mutation producer,
and mutation detector remain
`planned_not_materialized`.

That next slice must keep `executionImplemented == false` and
`sourceBindingV7Issued == false` until its own evidence says otherwise. Neither
the historical V5 slice nor V6 establishes prompt-content target independence,
observed process or schedule delivery, model execution, evaluation or verdict publication,
mechanics `PASS`, a terminal receipt, scientific authority, or product
authority.

See
[Prime Native Neural Gate Held-Root Crosswalk Authority](PRIME-NATIVE-NEURAL-GATE-HELD-ROOT-CROSSWALK-AUTHORITY-2026-07-31.md)
for the exact V5 authority boundary and observed focused result.
The additive V6 identities and evidence are recorded in
[Prime Native Neural Gate Process Ownership and Target-Free Delivery](PRIME-NATIVE-NEURAL-GATE-PROCESS-OWNERSHIP-TARGET-FREE-DELIVERY-2026-07-31.md).
The additive V7 declaration and decoder boundary is recorded in
[Prime Native Neural Gate Typed Reference and Stream Binding](PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md).

## Additive V8 continuation

The V7 prerequisite above is now satisfied by topology V8,
`prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8`,
SHA-256
`8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b`.
Four internal targets now exist: the narrow label-free, presence-only surface
contract; the semantic catalog/identity contract; the corrected producer; and
the independent detector. The corrected mutation catalog/control contract is
`9b40258ed7ba07dc62ff6bda96df03b2233575a039b5598b487d738d036a78bd`;
the role-specific assignment contract is
`020fa5275a4ab7941b935271ad26b094b35b96c9fb85be765db1dd9130de36e2`.
The producer directly depends on semantic plus surface contracts. The
detector directly depends only on the surface contracts, with a complete local
closure of surface plus replay mechanics; it therefore cannot reach the
catalog/identity, expected-leg mapping, replay-artifact contracts, or producer.
The only public detector entry is an exact 15-case batch. Every full bound
baseline/restored context must be byte-and-binding identical across that
batch, mutated surfaces must be pairwise distinct, and wrong counts, duplicate
cases, or per-case reference-hash/seed drift are rejected. The fixed-cap
defect is exactly 63 against baseline 64, and permutation invariance is
verified. `Label-free` excludes explicit mutation IDs/labels, arbitrary
prediction strings, and per-case caller-controlled context.
This does not alter descriptor binding V1, semantic namespace V4, or V7's
twenty-path declaration. Actual Release source references and all
worker/process/durable evidence remain absent and non-authorizing, so
source/execution-binding V7 is still unissued. Historical secure-capture
continuation was V6 at 40,100
bytes, SHA-256
`99431ac9477a6546225721027319fc460ff8b10c8e55ef68f07b5cb8c73c8cd9`,
and V7 at 41,951 bytes, SHA-256
`770b719a7e594f95e422f40dc5d4acd0fd93241928416a6bb3f27a448791f928`,
under source identity
`9cdfe7bfcbbedebce59b7abb45b614778e6674391b570a679ea40728be4c514f`.
Final V8 validation and canary results remain pending.

The verdict path cannot substitute a count for source binding.
`countDerivedLabel` is scoped `provisional_count_only_non_authorizing`; ten bare
true legs remain `ABSTAIN`. `GROUNDED` requires verified/durably published
per-leg evidence, weighted-statistics recomputation, stable-greedy and
behavioral fixed-prompt predicates, model capability including exact
abstention decisions, the mutation sweep, source-bound leg evidence, distinct
implementation families, and four-tier audit state. The live exported
`PrimeNativeNeuralGateCountDerivedVerdict.recompute(legs:)` API remains
compatible but always emits `ABSTAIN` with the provisional scope and cannot
emit generic `GROUNDED`. The historical gate also requires all five aggregate
references to be verified/durably published and model execution observed. None
of those absent references is inferred from a descriptor, and all
mechanics/science/product authority stays false.

The next exact prerequisite is
`derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7`.
See [Prime Native Neural Gate Semantic Schema and Mutation Targets](PRIME-NATIVE-NEURAL-GATE-SEMANTIC-SCHEMA-MUTATION-TARGETS-2026-08-01.md).
