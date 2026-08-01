# Prime Native Neural Gate Typed Artifact Transport

Date: 2026-07-31

## Outcome

Stage B has two pure Swift transport-foundation targets, one trap-free
composition consumer, and separate descriptor-source adapters:

```text
PrimeNativeNeuralGateReplayArtifactContracts
    dependencies: []

PrimeNativeNeuralGateReplayTransport
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayMechanics

PrimeNativeNeuralGateReplayComposition
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayTransport
      - PrimeNativeNeuralGateReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateLogitSidecarMechanics

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

No production or execution target imports the transport. The contract target
contains typed artifact identities, paths, roles, ownership, reader sets,
bounds, and non-authorizing namespace policy. The transport target validates
exactly three bounded canonical manifest envelopes and exactly three pathless
record shapes: prompt-only row, outer-evaluation row, and raw-execution
reference. The transport also owns the shared producer/decoder canonical
codec; the composition target owns the strict prompt schedule and exact
outer/raw/validated-sidecar join. Source binding delegates hardened file
admission to `PrimeCore` and incrementally streams the large invariant files;
source composition bridges only sealed capabilities into the unchanged pure
join. The V5 capture target retains the exact 41-file source inventory; the
downstream trap-bearing crosswalk target binds the joined replay to the
independently source-derived 18,432-row prompt/target association. None
executes a worker, invokes MLX, imports PMHNP, publishes an artifact, or creates
a receipt.

This closes the manifest/record-shape, shared-codec, strict-schedule,
descriptor-stream, source-bound sidecar, role-projection, and exact-source-join
slices of the prior Stage-B prerequisite. It does not implement Stage-B
execution. Exact source behavior is recorded in
`PRIME-NATIVE-NEURAL-GATE-DESCRIPTOR-SOURCE-BINDING-2026-07-31.md`.

## Frozen identities

- historical topology V1 remains unchanged at SHA-256
  `48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5`;
- topology V2 has canonical SHA-256
  `abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415`;
- topology V3 has canonical SHA-256
  `b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd`;
- topology V4 has canonical SHA-256
  `8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af`;
- topology V5 has canonical SHA-256
  `252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930`;
- composition V1 has canonical SHA-256
  `75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e`;
- source composition V1 has canonical SHA-256
  `f3d0a58905065836caaae8c9d03c1b2840b07bcd1a4f0bf35f1ce638c6ac29b5`;
- capture inventory V1 has canonical SHA-256
  `ae3477c44af1f36a111a6312a88a6b86995ddad231c9225a069173860ed29878`;
- crosswalk authority V1 has canonical SHA-256
  `b4a994635c2d7fafe8f9d47587122beee149533013b69592242bcba33b60ea67`;
- historical replay plan V5 and source-binding V6 remain unchanged;
- historical replay-output and path-classification V3 remain unchanged;
- the non-authorizing semantic-namespace overlay V4 has canonical SHA-256
  `60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1`.

Topology V4 remains exact history. Topology V5 is now the exact historical
held-root/crosswalk boundary. Historical topology V6, SHA-256
`6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1`,
preserves V1 through V5 and adds the non-authorizing target-free schedule,
process/evaluation/receipt ownership, and retained-capture binding boundaries.
The execution graph remains globally `planned_not_materialized`;
`executionImplemented` is false and source binding V7 is unissued.
Current topology V7,
`prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7`,
SHA-256
`88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156`,
adds exact-count bounded stream admission and typed copied-reference
declarations without changing that authority ceiling. Topology V7 is distinct
from the unissued source/execution-binding V7.

Semantic namespace V4 is an incomplete overlay, not an execution artifact,
source-binding version, or receipt. Its identity embeds the complete 116-spec
table, exact historical 46-case and corrected 15-case mutation catalogs,
historical and corrected leg domains, and the three implemented record-schema
IDs. It preserves historical V3 identity while making changes to the concrete
namespace semantics change the V4 digest.

## Decoder boundary

The in-memory artifact decoder accepts only a V4 artifact whose decoder mode
is `bounded_canonical_json`. Its hard maximum is 1,048,576 bytes, nesting depth
is 16, individual JSON string content is limited to 65,536 encoded bytes, and
the lexical structural-token ceiling is 700,000. All four limits are embedded
in semantic namespace V4. It rejects:

- empty input, UTF-8 BOM, invalid UTF-8, and a non-object root;
- excess bytes, depth, string content, or structural tokens;
- duplicate, unknown, missing, or `null` fields through exact canonical
  decode/re-encode equality;
- alternate key order, whitespace, escaping, number, or boolean encodings;
- wrong schema version, artifact kind, path, digest syntax, byte count,
  ordinal, chunk order, partition count, or record count;
- any transport field that attempts to authorize execution, mechanics
  `PASS`, `GROUNDED`, mutation detection, science, product use, or a receipt.

The bounded artifact entry point implements exactly three manifest schemas:
prompt-only fixture, outer-evaluation, and seed-scoped raw-execution. The
pathless record entry points implement exactly the corresponding prompt,
outer-evaluation, and raw-execution row shapes. Descriptor-streamed record
payloads, source-bound logit codecs, mutation payloads, historical
observations, MLX observations, statistics/verdict observations, worker and
process records, results, and the receipt all fail before JSON parsing with
their frozen decoder mode. A manifest can bind the paths, counts, sizes, and
digests of an admitted record stream; this target does not read or decode that
stream.

## Record semantics

The prompt row has only the canonical prompt-token array. Replicate seed is
replicate-scoped and is rejected at the row boundary together with dedicated
target, correlation, regrade, caller-budget, support, and termination fields.
Valid prompt bytes can still contain any string, including target-like text,
so the decoded value explicitly reports
`targetIndependenceEstablished == false`. Content independence belongs to a
future cross-artifact derivation verifier, not this shape decoder.

Outer evaluation rows carry correlation and expected completion separately.
Raw execution rows carry only seed, execution index, prompt/trace digests,
generated byte tokens, and exact EOS-or-fixed-cap decision accounting. The raw
row cannot carry expected completion. Its seed must equal the caller's
seed-scoped stream context, so a valid row from another replicate is rejected.

The contract target freezes mutation identity as
`(arm, one_based_ordinal, mutation_id, expected_failed_leg_id)`. The copied
46-case historical and 15-case corrected catalogs are reconciled in tests
against the existing frozen Swift authorities. This is namespace and identity
authority only. No mutation-delta schema, producer, detector, or result
decoder is implemented.

The historical and corrected leg domains are likewise frozen in semantic
order, including exact `NL1` through `NL10` ordering. No historical
observation, MLX observation, statistic, verdict, or receipt value can be
decoded in this slice. Those schemas remain explicit deferred keys rather
than permissive placeholder records.

Prompt-only, outer-evaluation, and each per-seed raw-execution payload are
separate `prime_raw_utf8_length_framed_ordered_multiset_v1` streams. Each
stream is independently sorted by its own raw record bytes; cross-stream
positional zipping is forbidden. Composition V1 now defines
`execution_index` as the strict ordinal of canonical prompt-row JSON bytes in
the caller-provided in-memory sequence, requires exact `0..<18_432` coverage,
derives target-free `PRIMECOR1` identity from index plus prompt binding, and
joins outer/raw/sidecar records against that identity. It reconstructs every
full-logit decision and requires the exact corrected trace. Duplicate, missing,
or conflicting indexes fail closed. Descriptor-rooted streaming now proves
the exact global/chunk bytes and produces sealed source capabilities. The V4
outer adapter reconstructs the schedule incrementally and requires a common
held-root identity for the complete prompt/outer/raw/logit join. The pure
composition result itself remains non-authorizing, process delivery is not
observed, and independent prompt/expected-completion binding plus
prompt-content independence remain false.

Topology V5 retains the exact root closure, rebinds all four sources while that
capability is live, and requires final unchanged recapture. Its downstream
crosswalk then establishes corrected fixture identity, independent keyed
prompt/target association, and exact outer expected-completion binding. It
does not establish prompt-content target independence or process delivery.

## Package-capture status

The 27,015-byte package-description capture with SHA-256
`00dc419e101367d1f4a1d39f63bd35649b4de45417d74e4197f2376d729cdadf`
is preserved as the last accepted topology-V1 actual-package secure-capture
checkpoint. It predates the two V2 targets and is not current V2 evidence.

After the complete topology-V2 source was resealed, the Release canary passed
with byte-identical probe/verifier package-description output: 28,589 bytes,
SHA-256
`3a4ae506f5ed2eae16e9f46d099c5d53681ec1d1a02aa9c20549b0fbeb230d7c`.
This is the last topology-V2 actual-package secure-capture reseal and predates
the composition target and topology V3. It remains
secure-capture evidence only, not V6/V7 selected-source execution-graph proof;
source binding V7 is unissued.

After the complete topology-V3 source reseal, the same Release canary passed
with byte-identical probe/verifier package-description output: 29,905 bytes,
SHA-256
`ad4a66338d7348cb44419a115e062a30da129dea9a6355eec81f6b98932b6e11`.
This is the last accepted historical topology-V3 actual-package secure-capture
reseal.
It validates only the secure-capture substrate on the pinned host. It is not
V6/V7 selected-source execution-graph proof; it does not issue source binding
V7 or establish worker or model execution, fixture identity,
evaluation or mechanics `PASS`, Stage-B publication or a terminal receipt,
reproducible-build identity, or network denial.
It predates the topology-V4 package graph and cannot serve as the V4 reseal.

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
It validates only the secure-capture substrate on the pinned host and does not
establish V6/V7 selected-source graph reconciliation, source binding V7,
execution, evaluation, publication, receipt, reproducible-build,
network-denial, Metal, scientific, or product authority.

## Historical V5/V6 results, current V7 boundary, and remaining evidence gaps

- the focused 18,432-row, exact 41-file held-root/crosswalk integration passed
  in 300.125 seconds;
- topology V6 freezes the exact ten-role process roster, branch-scoped
  raw/evaluation ownership, verifier-only receipt-last ownership, and the
  target-free schedule candidate contract;
- topology V7 adds exact-count bounded `PRIMEIRM1` raw/outer stream admission
  while aggregate candidates remain non-`Decodable`;
- topology V7 freezes typed common/branch/twenty-path artifact-reference and
  six four-part Release worker-source declarations; real common/branch scalar
  references are supervisor-derived and non-authorizing, while realized
  worker-source and role-artifact content references remain absent;
- the retained-capture-bound supervisor wrapper is implemented and keeps the
  V5 capture live across projection, but actual process delivery remains
  unobserved;
- freeze and implement mutation-delta, historical-observation, MLX-observation,
  and corrected statistics/verdict schemas before any of those keys can admit
  bytes;
- implement the corrected 15-case mutation producer and an independently
  implemented detector in disjoint targets;
- derive the historical gate/carrier seam and 46-case raw mutation material
  from pinned donor source rather than hand-porting it;
- only then materialize role-scoped workers, probe, verifier, complete
  path/metadata/content inventory, full-fixture MLX observation, and terminal
  composition.

The next implementation prerequisite is therefore:

`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`

The shared codec, exact global/chunk source binding, source-bound lossless
sidecar, incremental schedule, target-free role projections, and keyed join are
now joined by the retained capture epoch, independent source-derived crosswalk,
and V6's ownership/delivery-preparation declarations without giving
trap-bearing authority to the corrected raw closure. V7 adds the bounded stream
and typed reference-declaration boundary without realizing a source or
artifact. The next slice must freeze the deferred semantic schemas before
assigning disjoint source-bound mutation producers and detectors.
Prompt-content target independence, process delivery, model
execution, evaluation/verdict authority, mechanics `PASS`, receipt, science,
and product authority remain false. See
`PRIME-NATIVE-NEURAL-GATE-PROCESS-OWNERSHIP-TARGET-FREE-DELIVERY-2026-07-31.md`
and
`PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md`.

## Additive V8 semantic record boundary

The V7 prerequisite above is now satisfied. Topology V8,
`prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8`,
SHA-256
`8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b`,
adds a separate semantic-record overlay without changing namespace V4 or its
116-spec identity. The mutation, historical, MLX-digest, statistics, and
verdict schemas are frozen; V4's deferred fields remain historical rather than
being rewritten. Four internal Swift targets now separate the narrow
label-free, presence-only surface contract, the semantic catalog/identity
contract, the corrected producer, and the independent detector. The corrected
mutation catalog/control contract is
`9b40258ed7ba07dc62ff6bda96df03b2233575a039b5598b487d738d036a78bd`;
the role-specific assignment contract is
`020fa5275a4ab7941b935271ad26b094b35b96c9fb85be765db1dd9130de36e2`.
The producer directly depends on semantic plus surface contracts. The
detector directly depends only on surface contracts and transitively only on
surface plus replay mechanics, structurally excluding catalog/identity,
expected-leg mapping, replay-artifact contracts, and producer.
Its only public entry requires exactly 15 triplets as a batch; singleton
detection is private. Every full bound baseline/restored context must be
byte-and-binding identical across the batch, while mutated surfaces must be
pairwise distinct. Wrong counts, duplicate cases, per-case reference-hash or
seed drift, and any fixed-cap defect other than exact 63 against baseline 64
are rejected. Permutation invariance is verified. `Label-free` means no
explicit mutation IDs/labels, arbitrary prediction strings, or per-case
caller-controlled context.
Their bounded local mechanics do not admit or publish a durable artifact, and
actual Release source references remain absent and non-authorizing. No
worker/process execution, accepted verdict, mechanics `PASS`, receipt,
science, or product authority is created; source/execution-binding V7 remains
unissued.

Typed transport does not authorize a count-derived label. `countDerivedLabel`
is scoped `provisional_count_only_non_authorizing`; ten bare true legs still
produce `ABSTAIN`. `GROUNDED` requires verified/durably published per-leg
evidence, weighted-statistics recomputation, stable-greedy and behavioral
fixed-prompt predicates, model capability including exact abstention decisions,
mutation-sweep and source-bound-leg evidence, distinct implementation families,
and four-tier audit state. The live exported
`PrimeNativeNeuralGateCountDerivedVerdict.recompute(legs:)` entry remains
API-compatible but always yields `ABSTAIN` with the provisional scope and
cannot yield generic `GROUNDED`. Historical `GROUNDED` also requires all five
aggregate references verified/durably published and observed model execution.
Those observations are absent, and transport creates no mechanics, science,
or product authority.

The historical actual-package canaries missing from the sequence above are V6
at 40,100 bytes, SHA-256
`99431ac9477a6546225721027319fc460ff8b10c8e55ef68f07b5cb8c73c8cd9`,
and V7 at 41,951 bytes, SHA-256
`770b719a7e594f95e422f40dc5d4acd0fd93241928416a6bb3f27a448791f928`.
V7 used source identity
`9cdfe7bfcbbedebce59b7abb45b614778e6674391b570a679ea40728be4c514f`.
Final V8 test, source, and Release-canary results remain pending.

The next exact prerequisite is
`derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7`.
See [Prime Native Neural Gate Semantic Schema and Mutation Targets](PRIME-NATIVE-NEURAL-GATE-SEMANTIC-SCHEMA-MUTATION-TARGETS-2026-08-01.md).

## Workflow boundary

Publication remains explicit: local Git for intentional commit/push and the
signed-in GitHub app for PR checks and merge. A future credential-free Swift
Git preflight belongs in `ergentics-workstation` as a read-only outer observer.
It may report repository root, branch/upstream, HEAD, cleanliness or exact
diff state, author identity, source-seal agreement, and named test evidence.
It must not own GitHub credentials, push, mutate a PR, approve, or merge, and
it does not enter Prime's scientific evidence graph.
