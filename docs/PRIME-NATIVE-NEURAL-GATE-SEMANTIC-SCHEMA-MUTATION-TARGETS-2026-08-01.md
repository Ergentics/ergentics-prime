# Prime native neural-gate semantic schemas and mutation targets

Date: 2026-08-01

## Decision

Topology V8 completes the declaration and local-mechanics prerequisite left by
V7 without starting Stage-B worker execution. It adds four internal Swift
library targets and no product or executable:

- `PrimeNativeNeuralGateCorrectedMutationSurfaceContracts` freezes the narrow,
  label-free, presence-only corrected-mutation control surface and its bounded
  wire codec;
- `PrimeNativeNeuralGateSemanticRecordContracts` freezes an additive,
  non-authorizing schema overlay for the deferred mutation, historical, MLX
  digest, statistics, and verdict records, plus the corrected mutation
  catalog, identity, and exact allowed failed-leg sets;
- `PrimeNativeNeuralGateCorrectedMutationProducer` implements the exact
  corrected 15-case defect producer; and
- `PrimeNativeNeuralGateCorrectedMutationDetector` independently evaluates the
  resulting policy material.

The producer directly depends on the semantic and surface targets. The
detector directly depends only on the surface target; its complete local
dependency closure is the surface target plus
`PrimeNativeNeuralGateReplayMechanics`. The detector therefore has no package
path to the mutation catalog, mutation identity, expected-leg mapping,
`PrimeNativeNeuralGateReplayArtifactContracts`, or producer implementation.
Its sole public entry is
`PrimeNativeNeuralGateCorrectedMutationDetector.detectBatch(_:)`, which admits
exactly 15 blind triplets at once; the single-triplet classifier is private.
Neither role target imports or reaches the other. Neither is a worker, process,
executor, evaluator, receipt owner, or publication authority.

## Preserved history

The following contracts remain byte-exact historical inputs rather than being
rewritten:

- semantic output namespace V4,
  `prime_stage_b_non_authorizing_semantic_output_namespace_v4`, SHA-256
  `60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1`;
- dual-fixture replay plan V5,
  `ergentics_prime_native_neural_gate_dual_fixture_replay_v5`, SHA-256
  `c811555bc3a04f053378519ca9c33d18de075d0eb7b347587a9789f4aff3466b`;
- topology V7,
  `prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7`,
  SHA-256
  `88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156`;
- the ordered historical 46-case catalog, SHA-256
  `8a1f70ae9f20f60e63cc53df6841d8a160bcbee61621c6f80a4f0272a186100f`;
  and
- the ordered corrected 15-case catalog already frozen in Prime.

The V8 overlay fills identifiers and bounds missing from V4. It does not
reinterpret V4's deferred owner fields or extend V7's exact twenty corrected
pre-receipt role/artifact content-reference paths.

## Semantic record boundary

The additive contract freezes schema identities and bounded values for:

- per-arm mutation delta manifests, records, and chunks;
- corrected mutation detector observations;
- historical material identity, ten-leg gate, invariant stream, SZ
  fingerprint, 46-case mutation, and statistics/verdict observations;
- per-seed MLX Float32 log-softmax digest observations; and
- corrected weighted-statistics, fixed-prompt-margin, critical-leg, and
  statistics/verdict observations.

Absence is represented by an explicit `unavailable` state. It is never folded
into `observed_false`. Aggregate artifact values remain `Encodable` only;
bounded canonical record mechanics reject malformed or oversized material
before it can become an observation.

MLX records contain identities and digests only. They do not import MLX,
contain `[[Float]]`, or claim that the 18,432-row full-vocabulary fixture was
recomputed.

## Verdict admission is evidence-bound

`countDerivedLabel` remains a lineage diagnostic with exact
`countDerivedLabelScope` value
`provisional_count_only_non_authorizing`. It never directly determines
`mechanicsOutcome`. In particular, ten critical-leg values set to
`observed_true` without their bound evidence still produce `ABSTAIN`.

The older live exported
`PrimeNativeNeuralGateCountDerivedVerdict.recompute(legs:)` type and call shape
remain API-compatible. Its result now always has `mechanicsOutcome == ABSTAIN`,
including when all ten Boolean legs pass, and exposes
`countDerivedLabelScope == provisional_count_only_non_authorizing` while model
capability stays unavailable and source-bound evidence, distinct-family, and
four-tier fields stay false. This count-only evaluator cannot produce a generic
`GROUNDED`.

The corrected statistics/verdict record derives `GROUNDED` only when all of
the following are observed together:

- all ten critical legs are true and every true leg has verified and durably
  published evidence references;
- weighted-statistics recomputation is observed;
- the greedy token is stable and behavioral fixed-prompt replay is exact;
- model capability is observed, including
  `exactAbstentionDecisionsObserved`
  (`exact_abstention_decisions_observed`) on the abstention split rather than
  aggregate 1.0 accuracy alone;
- the mutation sweep and source-bound critical-leg evidence are observed;
- distinct implementation families are established; and
- the AgentContractKit four-tier audit is performed.

Any unavailable or false prerequisite yields `ABSTAIN`. The historical gate is
separately fail-closed: `GROUNDED` requires the same ten bound critical-leg
evidence records, all five aggregate artifact references verified and durably
published, explicit source-bound-leg evidence, and observed model execution.
Ten bare true legs are insufficient there as well.

V8 supplies schemas for these facts, not the facts themselves. They remain
absent or unavailable, and `mechanicsPassAuthorized`, scientific authority,
and product authority remain false regardless of the provisional count label.

## Corrected mutation mechanics

The producer applies exactly one declared defect to a frozen target-independent
control surface for each corrected catalog entry. It emits canonical baseline,
mutated, and restored material plus generic byte and fingerprint bindings. It
does not emit a detector result, failed leg, verdict, or success Boolean.

The surface contract is
`prime_stage_b_corrected_mutation_label_free_surface_contract_v1`. Its wire
contract is
`pmutrec1_fixed_order_lowercase_ascii_hex_presence_only_control_surface_v1`,
an exact 165-byte encoding. Expected-completion, row-ID, split, and semantic-
family prediction inputs are represented only by presence controls. Arbitrary
prediction strings were eliminated, so label or identity bytes cannot travel
through those fields. The fixed-order codec also bounds the decision cap and
seed domain and requires canonical lowercase ASCII hexadecimal digests. The
baseline cap is exactly 64; the one admitted fixed-cap defect is exactly 63.

The producer creates the complete batch with `produceBatch(baseline:)` and
explicitly erases each identity-bearing result to a `blindTriplet` before the
detector boundary. The detector receives no mutation ID, expected failed leg,
catalog, mutation identity, or caller-reported success. Every full bound
baseline and restored surface in the batch must equal the one batch-common
baseline in both bytes and binding. Mutated surfaces must be pairwise distinct.
Wrong counts, duplicate cases, or per-case schedule-reference-hash/replicate-
seed drift are rejected before a report can be admitted. Batch permutation
invariance is verified.

Within this contract, `label-free` therefore means no explicit mutation ID or
label, no arbitrary prediction string, and no admitted per-case caller-
controlled context. It does not mean that an unbound singleton is safe to
classify; there is no public singleton detector entry.

The detector evaluates the complete ordered corrected leg battery from the
material itself. The paired integration boundary, not the producer or
detector, compares the observed failed-leg set with the exact catalog contract
set. Extra failures are rejected; a set that merely contains the expected leg
is insufficient.

The local mechanics require:

- a valid all-pass baseline and restored record;
- byte and fingerprint divergence for the mutation;
- exact baseline/restored byte and fingerprint equality;
- agreement between the existing direct and accelerated SZ fingerprint paths;
- exact ordered 15-case coverage; and
- fail-closed handling of malformed, trailing, oversized, digest-tampered,
  unchanged, inexactly restored, or multi-leg material.

These are local in-memory Swift mechanics tests. They are not durable mutation
artifacts or process-scoped Stage-B observations.

## Target and source-reference boundary

The frozen assignment contract is
`prime_stage_b_corrected_mutation_producer_detector_source_assignment_v1`.
It records that both role targets exist and assigns role-specific direct
dependencies and ordered contract IDs. The producer's direct dependencies are
`PrimeNativeNeuralGateSemanticRecordContracts` and
`PrimeNativeNeuralGateCorrectedMutationSurfaceContracts`; the detector's only
direct dependency is
`PrimeNativeNeuralGateCorrectedMutationSurfaceContracts`. The typed future
source reference requires a Release package-description identity, Prime source
snapshot identity, and compiled-source-closure identity. Those actual
references remain absent and non-authorizing in V8.

No executable reference is invented for either library. `target implementation
present` and `source reference observed` are different facts. V8 records the
first as true and the second as false.

Topology V8 is
`prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8`,
SHA-256 `8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b`.
Its graph contains the four internal targets above, prevents direct or
transitive producer-to-detector reachability in both directions, freezes the
detector closure to surface plus replay mechanics, and prevents either role
implementation from reaching PrimeCore, target-bearing fixture/evaluation
authority, the prompt-target crosswalk, MLX, retained delivery/reference
authority, terminal receipt ownership, historical runtimes, or any planned
worker or supervisor.

## Validation record

Final validation is intentionally recorded only after the complete admitted
source tree is resealed:

- semantic contract SHA-256:
  `67451098c4c486cd6a2d1701190c7ba3129d48f47956dc5c674295053f47cf9a`;
- corrected mutation catalog/control contract SHA-256:
  `9b40258ed7ba07dc62ff6bda96df03b2233575a039b5598b487d738d036a78bd`;
- mutation target assignment SHA-256:
  `020fa5275a4ab7941b935271ad26b094b35b96c9fb85be765db1dd9130de36e2`;
- embedded Prime source identity: the exact final value is compiled only in
  `PrimeEmbeddedBuildProvenance.sourceIdentitySHA256` and is verified against
  the complete admitted tree by
  `testLiveRepositoryMatchesEmbeddedSourceIdentity`; it is deliberately not
  duplicated in this admitted document because that would make the digest
  self-referential;
- Debug test result: 571 XCTest tests executed with four expected skips and
  zero failures, plus 12 Swift Testing tests executed with zero failures; and
- Release secure-capture canary: the probe and verifier role captures were
  byte-identical at 46,909 bytes, SHA-256
  `db8bf052946263f50730e1b561be7fb272cf873e639955e1f02554505a8ea923`.

The Release canary, when recorded, proves only the existing actual-package
secure-capture path on the pinned host. It does not issue source/execution-
binding V7 or prove that any Stage-B mutation artifact crossed a process
boundary.

## Authority ceiling and continuation

V8 keeps all of the following false or absent:

- Stage-B worker, supervisor, or executable materialization;
- schedule/process delivery, PID, death/reap, or receipt evidence;
- durable mutation, historical, MLX, statistics, or verdict observations;
- historical 59,497-record reconstruction;
- model or Metal execution;
- accepted mechanics `PASS` or capability verdict;
- source/execution-binding V7;
- AgentContractKit four-tier or distinct-implementation-family authority;
- scientific authority; and
- product authority.

The completed V7 prerequisite was:

`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`

The next exact prerequisite is:

`derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7`

That next slice must derive the historical gate/carrier seam and raw 46-case
material from the pinned donor source. It must not hand-port the historical
summary, invent records from the 59,497 count, or materialize workers.
