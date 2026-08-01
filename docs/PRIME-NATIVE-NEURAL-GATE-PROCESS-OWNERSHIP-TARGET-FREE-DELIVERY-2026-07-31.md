# Prime Native Neural Gate Process Ownership and Target-Free Delivery

Date: 2026-07-31

## Outcome

This additive Stage-B slice freezes the process, evaluation, and receipt
ownership that the historical six-process plan left ambiguous. It also freezes
a narrow Swift-only schedule format and a supervisor-only retained-capture
adapter that can prepare source- and owner-bound candidates without making
target material representable to the corrected raw worker.

The replacement topology has exactly ten distinct process roles:

| Side | Supervisor | SwiftPM child | Historical worker | Corrected raw worker | Corrected evaluation worker |
| --- | --- | --- | --- | --- | --- |
| Probe | one | one | one | one | one |
| Verifier | one | one | one | one | one |

The count is derived from the closed role roster, not inferred from the old
six-process statement. Probe and verifier receive separate corrected raw runs
and separate evaluation executables. The verifier supervisor alone owns the
future terminal-receipt publication lease; neither evaluation worker may
publish it.

This V6 slice was a contract, projection, and retained-capability-binding
change. It materialized no supervisor or worker target, no schedule crossed a
process boundary, no model ran, and no receipt was created.

## Compile-time boundary

Five new targets keep the raw closure narrow:

```text
PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
    -> ReplayArtifactContracts
    -> ReplayMechanics
    -> CorrectedMechanics

PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
    -> ReplayArtifactContracts
    -> TargetFreeScheduleDeliveryContracts

PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts
    -> ReplayArtifactContracts
    -> CorrectedProcessOwnershipContracts

PrimeNativeNeuralGateTerminalReceiptOwnershipContracts
    -> ReplayArtifactContracts
    -> CorrectedProcessOwnershipContracts
    -> CorrectedEvaluationOwnershipContracts

PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority
    -> ReplayCaptureInventory
    -> ReplaySourceComposition
    -> TargetFreeScheduleDeliveryContracts
    -> CorrectedProcessOwnershipContracts
    -> CorrectedEvaluationOwnershipContracts
```

`ReplaySourceComposition` may project its already sealed schedule into the
narrow delivery types. The dependency is one-way. A future corrected raw
worker may import the target-free and process-ownership contracts, but it may
not import source binding/composition, capture inventory, crosswalk authority,
fixture authority, corrected evaluation mechanics, receipt ownership,
historical runtime, MLX, or product authority.

The delivery-authority target is not in the corrected raw-worker closure. It is
a real supervisor-only wrapper around the retained V5 capture: it recaptures
before and after projection, derives the maintained source schedule, verifies
candidate content identities, and binds the probe/verifier branch to its exact
raw and outer owners. The sealed wrapper retains the capture authority rather
than reducing it to scalar JSON. This establishes preparation under the held
source capability; it does not establish delivery.

The two evaluation-ownership and receipt-ownership targets contain only
declarative wire/ownership contracts. They do not import target-bearing
evaluation mechanics or the crosswalk. Future probe and verifier evaluation
executables are distinct planned targets so the probe executable cannot gain
the verifier receipt path through a role flag.

## Target-free schedule

The raw row shape is exactly:

- execution index;
- canonical prompt tokens;
- canonical prompt text;
- the typed `PRIMECPI2` prompt binding; and
- the typed `PRIMECOR1` correlation identity.

The outer row shape is exactly execution index plus `PRIMECOR1` correlation.
Row ID, split, semantic family, expected completion, target bytes or tokens,
regrade material, caller-selected budget/support, and caller-selected
termination cannot be encoded. Individual raw and outer slots have byte-capped
decoding and strict unknown-key rejection. Raw slots additionally rederive the
maintained prompt binding and correlation identity; outer slots validate their
correlation digest shape, and complete-pair validation cross-checks each outer
correlation against the independently validated raw candidate. Aggregate raw,
outer, and paired candidates are intentionally `Encodable`-only: no bounded candidate
stream decoder exists yet, so untrusted aggregate JSON cannot be decoded into
an authoritative candidate. Constructed complete candidates require exact
contiguous coverage of all 18,432 rows and an exact raw/outer
index-and-correlation join.

Constructed schedule values remain candidates, not authority. Their contract
records `processDeliveryObserved == false`,
`promptContentTargetIndependenceEstablished == false`,
`modelExecutionEstablished == false`, and
`mechanicsPassAuthorized == false`.

## Ownership and receipt order

Corrected raw and evaluation record paths are role-scoped under separate
`probe` and `verifier` prefixes. This removes the collision hidden by the
historical singleton deferred paths. Each schedule, request, process binding,
supervisor execution record, and worker result has exactly one owner and a
closed reader set.

The historical artifact namespace V4, including its singleton reserved
corrected paths, remains exact history. The new ownership contracts bind that
identity and declare role-scoped replacements; they do not reinterpret V4 as
execution evidence.

The future receipt path remains
`prime-native-neural-gate-fixture-replay-receipt.v2.json`. Its ownership and
ordering envelope requires all ten positive PIDs to be distinct, all eight
children to have observed death and exact-once reap, both independent
evaluation results to be bound, and the exact 20 declared role-scoped
pre-receipt paths to be inventoried. Publication must be exclusive/no-replace
and last, with no post-receipt artifact creation. Abnormal containment, a
missing result, or an inventory mismatch permits no successful execution
record, no receipt, and no retry. This is not yet an exact full-root inventory:
at the V6 checkpoint, typed role-to-path-to-content binding, common
capture/schedule references, and source-pinned worker closure/executable
references were forward blockers. Topology V7 now freezes those declaration
schemas and their retained-capture adapter, but all realized artifact,
source-snapshot, compiled-closure, and sealed-executable values remain absent.

The receipt's final semantic body remains deferred until the mutation,
historical, MLX, and statistics/verdict record schemas are frozen. Freezing an
owner and publication order does not authorize publication.

## Authority ceiling

The following remain false:

- process or schedule delivery observed;
- supervisor, worker, or model execution;
- corrected evaluation or verdict observation;
- prompt-content target independence;
- mechanics `PASS`;
- terminal receipt authorization or publication;
- source binding V7;
- mutation production or independent detection;
- scientific authority; and
- product authority.

Mutation producer/detector assignment remains explicitly deferred. No target
name or implementation is invented in this slice.

## Verification identities

Historical topology V1 through V5, replay plan V3 through V5, artifact
namespace V4, replay composition V1, source composition V1, held-root capture
V1, and crosswalk authority V1 remain byte-exact and are pinned by tests. The
new canonical identities are:

- topology V6: `6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1`;
- target-free schedule-delivery contract V1:
  `2418856c22891798954b43ef956ee1bc7b91a7b3959b7c572ad07c4e1e1d377d`;
- corrected ten-process ownership contract V1:
  `24dda3ac4302922d52b6dbfe3e541954c98f7da74c9d3b71e277fb0bbebabbbb`;
- corrected evaluation-ownership contract V1:
  `98df1fb980ce99eae93d22a887088999256c61ba8d1ec190ebe61da58afb913e`;
- terminal-receipt ownership contract V1:
  `7d15c024cff20a1d712c6664b4b6e878903eae104ce44fc2784547e4ab0406f6`;
- terminal-receipt envelope V2:
  `0afe62ebeac173ea7ffd1fb090e7d223a968dee97ba2a154375469ca6a5065a8`;
  and
- retained-capture-bound delivery-authority contract V1:
  `b638564791715dcd250c86d3c0faaac7b79b2a26b7dd7a0334ad4772d9afaf88`.

The focused contract/topology checkpoint passed **48/48**. The real retained
41-file root projection and binding test passed **1/1 in 363.326 seconds**
across the full 18,432-row schedule. These are focused results, not a claim
that the complete Debug or Release package suites passed in this slice. The
embedded source identity and Release actual-package canary remain separate
final reseal gates.

## Historical V6 prerequisite and V7 continuation

Topology V7 satisfies the declaration-and-decoder prerequisite that followed
this V6 checkpoint. Current topology V7 is
`prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7`,
canonical SHA-256
`88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156`.
It adds exact-count bounded `PRIMEIRM1` stream admission, typed reference
declarations, and a retained-capture reference adapter without materializing a
worker. Real common/branch scalar references are supervisor-derived and non-
authorizing; realized worker-source and role-artifact content references remain
absent. Topology V7 is distinct from the still-unissued source/execution-binding
V7.

The current bounded implementation step is:

`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`

The next slice must freeze the deferred schemas and the disjoint
producer/detector boundary. Only after that boundary is frozen should Prime
consider materializing the historical worker and paired Stage-B
supervisors/workers. The V7 details are recorded in
`PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md`.

## Additive V8 continuation

The V7 prerequisite above is now satisfied by topology V8,
`prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8`,
SHA-256
`8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b`.
The V6 ownership envelopes and V7's exact twenty corrected pre-receipt paths
remain unchanged history. V8 freezes the semantic bodies separately and adds
four internal targets: a narrow label-free, presence-only surface contract;
the semantic catalog/identity contract; the corrected producer; and the
independent detector. The corrected mutation catalog/control contract has
SHA-256
`9b40258ed7ba07dc62ff6bda96df03b2233575a039b5598b487d738d036a78bd`;
the role-specific assignment contract has SHA-256
`020fa5275a4ab7941b935271ad26b094b35b96c9fb85be765db1dd9130de36e2`.
The producer directly depends on semantic plus surface contracts. The
detector directly depends only on surface contracts and transitively only on
surface plus replay mechanics, so catalog/identity, expected-leg mapping,
replay-artifact contracts, and producer are structurally unreachable.
Its only public entry is exact 15-case batch detection. Every full bound
baseline/restored context must be byte-and-binding identical throughout the
batch, and mutated surfaces must be pairwise distinct. Wrong counts, duplicate
cases, per-case reference-hash or seed drift, and any cap other than exact
defect 63 against baseline 64 are rejected. Permutation invariance is
verified. `Label-free` excludes explicit mutation IDs/labels, arbitrary
prediction strings, and per-case caller-controlled context.
This closes target assignment and local mechanics, not process ownership or
delivery: actual Release source references, all workers/processes, durable
artifacts, verdict publication, and receipt issuance remain absent and
non-authorizing.
`executionImplemented` remains false and source/execution-binding V7 remains
unissued. The final-validation absence was the V8 prevalidation authoring
state. Completed final V8 validation is recorded canonically in the
[V8 semantic-schema and mutation-target record](PRIME-NATIVE-NEURAL-GATE-SEMANTIC-SCHEMA-MUTATION-TARGETS-2026-08-01.md).

Verdict state cannot manufacture the missing ownership or delivery evidence.
`countDerivedLabel` is scoped `provisional_count_only_non_authorizing`; ten
bare true legs remain `ABSTAIN`. `GROUNDED` requires verified/durably published
per-leg evidence, weighted-statistics recomputation, stable-greedy and
behavioral fixed-prompt predicates, model capability including exact
abstention decisions, mutation-sweep and source-bound-leg evidence, distinct
implementation families, and four-tier audit state. The live exported
`PrimeNativeNeuralGateCountDerivedVerdict.recompute(legs:)` call is
API-compatible but always returns `ABSTAIN` with only the provisional scope; it
cannot produce generic `GROUNDED`. The historical gate also requires all five
aggregate references verified/durably published and model execution observed.
Those facts remain absent, so process, mechanics `PASS`, science, and product
authority remain false.

The V8 next prerequisite was
`derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7`.
Topology V9 now satisfies it without process delivery or worker
materialization. Topology V10 then materializes only the internal historical
source closure; process delivery and worker targets remained absent at V10.
Its next prerequisite was
`derive_and_source_bind_source_faithful_historical_fixture_then_materialize_only_the_sealed_historical_worker_without_materializing_probe_verifier_or_issuing_source_binding_v7`.
Topology V11 now adds only the unavailable historical worker target; process
delivery, worker execution, and supervision remain absent. The V11 next
prerequisite was
`derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7`.
V12 resolved only that design/source-contract boundary. Topology V13
materialized the exact source-only exporter. V14 now source- and compile-binds
one private cross-file worker/exporter call edge. That edge remains unreachable
from the exact V11 `main`, which exits `78`. Process delivery, worker execution,
encoding, and publication remain absent. The V14 prerequisite is recorded
in [Prime Native Neural Gate Historical Worker/Export Call-Edge Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORT-CALL-EDGE-SOURCE-2026-08-01.md).
V15 source-binds only the projection design; its current prerequisite is
recorded in [Prime Native Neural Gate Historical Evidence Semantic-Artifact Projection Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-SEMANTIC-ARTIFACT-PROJECTION-DESIGN-2026-08-01.md).
See [Prime Native Neural Gate Historical Source Material](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-SOURCE-MATERIAL-2026-08-01.md).
See [Prime Native Neural Gate Historical Replay Mechanics](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-REPLAY-MECHANICS-2026-08-01.md).
See [Prime Native Neural Gate Historical Fixture and Worker Boundary](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-FIXTURE-WORKER-BOUNDARY-2026-08-01.md).
