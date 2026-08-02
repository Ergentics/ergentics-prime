# Prime Native Neural Gate Trap-Disjoint Topology

Date: 2026-07-30; updated 2026-07-31

## Outcome

Stage B now has an implemented trap-disjoint mechanics boundary, pure typed
artifact contracts, bounded in-memory transport with a shared codec, and an
exact replay-composition target. It also has descriptor-rooted invariant and
logit source binding plus an outer source-composition adapter. Historical
topology V5 added a retained exact 41-file held-root capture and a downstream
trap-bearing source-derived 18,432-row keyed prompt/target crosswalk. It still
does not have a Stage-B executor, worker, probe, verifier, process record, or
terminal receipt.

Topology V5,
`prime_stage_b_held_root_capture_crosswalk_authority_topology_v5`, remains
exact history. Its canonical SHA-256 is
`252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930`.
Historical topology V6,
`prime_stage_b_process_evaluation_receipt_ownership_target_free_delivery_topology_v6`,
has canonical SHA-256
`6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1`.
It freezes an exact symmetric ten-role future topology, target-free schedule
candidate declarations, branch-scoped process/evaluation ownership,
verifier-supervisor receipt-last ownership, and a supervisor-only retained
capture binding wrapper. No process is materialized and no delivery is
observed.
Current topology V7,
`prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7`,
has canonical SHA-256
`88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156`.
It preserves V1 through V6 and adds exact-count bounded `PRIMEIRM1` stream
admission, typed common/branch/twenty-path artifact-reference declarations,
six four-part Release worker-source declarations, and a supervisor-only
retained-capture reference adapter. Real common/branch scalar references are
supervisor-derived and non-authorizing; realized worker-source and role-
artifact content references remain absent.
Historical `PrimeNativeNeuralGateTrapDisjointTopologyContract.frozenV4`
remains exact at SHA-256
`8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af`.
Topology V3 remains byte-exact at SHA-256
`b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd`.
Historical topology V1 remains byte-exact at SHA-256
`48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5`.
Topology V2 also remains byte-exact at SHA-256
`abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415`.
Topology V7's status is `planned_not_materialized`, `executionImplemented` is
false, and
source/execution-binding V7 is explicitly not issued. Topology V7 and
source/execution-binding V7 are separate version domains.

The historical fixture replay plan V5 and source binding V6 remain
byte-for-byte history. The topology contract supersedes only their unsafe
future target-routing assumption. It does not relabel them as an observed
execution graph.
The V6 claim boundary is recorded in
`PRIME-NATIVE-NEURAL-GATE-PROCESS-OWNERSHIP-TARGET-FREE-DELIVERY-2026-07-31.md`;
the current V7 boundary is recorded in
`PRIME-NATIVE-NEURAL-GATE-TYPED-REFERENCE-STREAM-BINDING-2026-07-31.md`.

## Implemented package boundary

The package now has these exact local closures:

```text
PrimeNativeNeuralGateReplayMechanics
    dependencies: []
    authority: pure raw-UTF8 stream, chunk, invariant, and fingerprint mechanics

PrimeNativeNeuralGateReplayArtifactContracts
    dependencies: []
    authority: typed paths, identities, bounds, roles, readers, and
               non-authorizing semantic namespace

PrimeNativeNeuralGateReplayTransport
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayMechanics
    authority: three bounded record manifests, three pathless record shapes,
               typed bindings, and the shared canonical producer/decoder codec

PrimeNativeNeuralGateReplayComposition
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayTransport
      - PrimeNativeNeuralGateReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateLogitSidecarMechanics
    authority: strict prompt schedule and exact outer/raw/validated-sidecar
               join with corrected trace recomputation

PrimeNativeNeuralGateReplaySourceBinding
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayTransport
      - PrimeNativeNeuralGateReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateLogitSidecarMechanics
    authority: descriptor-rooted read-only invariant and lossless-sidecar
               validation plus sealed non-authorizing source capabilities

PrimeNativeNeuralGateReplaySourceComposition
    dependencies:
      - PrimeNativeNeuralGateReplaySourceBinding
      - PrimeNativeNeuralGateReplayComposition
      - PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
    authority: incremental source-bound prompt schedule, asymmetric target-free
               role projections, and exact four-source join

PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
    authority: bounded non-authorizing raw/outer slot decoding and
               construct-only aggregate candidate identities

PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
    authority: non-authorizing symmetric ten-process ownership declarations

PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
    authority: non-authorizing branch-scoped evaluation ownership declarations

PrimeNativeNeuralGateTerminalReceiptOwnershipContracts
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
      - PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts
    authority: non-authorizing receipt-last ownership and ordering declaration

PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority
    dependencies:
      - PrimeNativeNeuralGateReplayCaptureInventory
      - PrimeNativeNeuralGateReplaySourceComposition
      - PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
      - PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
      - PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts
    authority: supervisor-only retained-capture candidate preparation with
               pre/post recapture; no process delivery is observed

PrimeNativeNeuralGateReplayCaptureInventory
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateReplaySourceBinding
    authority: retained exact 41-file held-root inventory, authoritative
               four-source rebind, final unchanged recapture, and bounded
               durable origin for the captured bytes

PrimeNativeNeuralGatePromptTargetCrosswalkAuthority
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateCorrectedFixtureAuthority
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateReplayCaptureInventory
      - PrimeNativeNeuralGateReplayComposition
      - PrimeNativeNeuralGateReplaySourceComposition
      - PrimeNativeNeuralGateReplayTransport
    authority: downstream trap-bearing source-derived PRIMECPI2-to-PRIMECOR1-
               to-PRIMECFT1 keyed prompt/target association and exact outer
               expected-completion binding

PrimeNativeNeuralGateCorrectedMechanics
    dependencies:
      - PrimeNativeNeuralGateReplayMechanics
    authority: prompt-only raw execution values and structural traces

PrimeNativeNeuralGateCorrectedEvaluationMechanics
    dependencies:
      - PrimeNativeNeuralGateReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
    authority: correlation, target feasibility, regrade, statistics,
               capability, verdict, and mutation-observation validation

PrimeNativeNeuralGateCorrectedFixtureAuthority
    dependencies:
      - PrimeNativeCorpusReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateCorrectedEvaluationMechanics
    authority: trap-bearing offline corrected-fixture derivation

PrimeNativeNeuralGatePromptSolver
    dependencies:
      - PrimeNativeNeuralGateCorrectedMechanics

PrimeNativeNeuralGateLogitSidecarMechanics
    dependencies:
      - PrimeNativeNeuralGateCorrectedMechanics

PrimeNativeNeuralGateMLXLogSoftmaxRecomputation
    dependencies:
      - PrimeNativeNeuralGateLogitSidecarMechanics
    external products:
      - MLX
      - MLXNN
```

The prompt solver and sidecar closure can no longer reach correlation,
expected completion, regrade, capability, verdict, or mutation-observation
types. The fixture authority can reach those types, but the corrected raw
executor cannot reach the fixture authority or corpus mechanics.

The artifact namespace V4 and transport boundary are specified in
`PRIME-NATIVE-NEURAL-GATE-TYPED-ARTIFACT-TRANSPORT-2026-07-31.md`.
The schedule and join are specified in
`PRIME-NATIVE-NEURAL-GATE-REPLAY-COMPOSITION-2026-07-31.md`. No production or
execution target imports transport or composition.
Descriptor source behavior is specified in
`PRIME-NATIVE-NEURAL-GATE-DESCRIPTOR-SOURCE-BINDING-2026-07-31.md`.

## Historical V1 planned execution topology

At topology V1, the following targets were names and dependency constraints
only; none existed in `Package.swift` at that checkpoint:

```text
ErgenticsPrimeRuntime
    dependencies: []

PrimeNativeNeuralGateHistoricalReplayMechanics
    dependencies:
      - ErgenticsPrimeRuntime
      - PrimeNativeNeuralGateReplayMechanics

PrimeNativeNeuralGateHistoricalFixtureWorker
    dependencies:
      - PrimeCore
      - ErgenticsPrimeRuntime
      - PrimeNativeNeuralGateHistoricalReplayMechanics
      - PrimeNativeNeuralGateReplayTransport

PrimeNativeNeuralGateReplayProbe
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateReplayTransport
      - PrimeNativeNeuralGateCorrectedProcessOwnershipContracts

PrimeNativeNeuralGateReplayVerifier
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateReplayTransport
      - PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
      - PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts
      - PrimeNativeNeuralGateTerminalReceiptOwnershipContracts

PrimeNativeNeuralGateCorrectedRawWorker
    dependencies:
      - PrimeNativeNeuralGateReplayArtifactContracts
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGatePromptSolver
      - PrimeNativeNeuralGateLogitSidecarMechanics
      - PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
      - PrimeNativeNeuralGateCorrectedProcessOwnershipContracts

PrimeNativeNeuralGateCorrectedProbeEvaluationWorker
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateCorrectedEvaluationMechanics
      - PrimeNativeNeuralGatePromptTargetCrosswalkAuthority
      - PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts

PrimeNativeNeuralGateCorrectedVerifierEvaluationWorker
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateCorrectedEvaluationMechanics
      - PrimeNativeNeuralGatePromptTargetCrosswalkAuthority
      - PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts
```

Topology V10 subsequently materialized the internal runtime and historical
replay libraries. V11 subsequently added the historical fixture worker target
as a deliberately unavailable executable boundary. Every other executable
role in this historical plan remains absent, and no worker process or Stage-B
execution has been observed.

No target outside the historical runtime module, its historical replay
adapter, and the historical fixture worker closure may reach
`ErgenticsPrimeRuntime` or
`PrimeNativeNeuralGateHistoricalReplayMechanics`. Probe and verifier remain
trap-free supervisors. The corrected raw worker is a separately launched
prompt-only executor and cannot compile against evaluation/regrade mechanics,
fixture authority, the historical runtime, or MLX recomputation.

Topology V6 freezes a replacement symmetric ten-role process/evaluation/
receipt ownership declaration; it does not materialize any of these targets.
Topology V7 freezes typed role-to-path-to-content and four-part worker-source
reference declarations under a common capture/schedule identity and adds exact-
count bounded stream admission. Real common/branch scalar references are
supervisor-derived and non-authorizing; realized worker-source and role-
artifact content references remain absent.
Deferred semantic schemas, disjoint source-bound mutator ownership, and actual
process execution remain prerequisites.

## Donor routing

Adaptation proof V2 is preserved as historical evidence. Its donor gate and
verdict-carrier destinations point into the pure replay target, which is the
unsafe routing discovered by this audit.

The then-future adaptation proof V3 was required to route both into:

```text
Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/
```

V3 now performs that gate/carrier routing. V11 separately reproduces the
frozen fixture prefix, transformed byte count, and SHA-256 from the pinned
Swift donor bytes and places the exact result beside the historical gate.
No donor source was copied or compiled by the original topology slice.

## Package-capture truth

The prior 26,090-byte Release secure-capture canary, SHA-256
`53ace0b68b1f8f2cf6534be886cb93241b08a36e0ddf0e9da7f8eee33f37cb40`,
captured and parsed the actual package description. It did not reconcile that
description against source binding V6's planned target closure. V6 names
future targets that are absent from the package and assigns runtime
dependencies to the currently pure replay target.

That canary is therefore secure-capture evidence for the actual package at
that checkpoint, not a V6 selected-source execution-graph proof. After the
raw/evaluation split and topology V1 correction, the same Release canary
passed with byte-identical probe/verifier output: 27,015 bytes, SHA-256
`00dc419e101367d1f4a1d39f63bd35649b4de45417d74e4197f2376d729cdadf`.
That is the last accepted topology-V1 actual-package secure-capture reseal
and still is not a V6 or V7 execution-graph proof. It predates the two
topology-V2 targets. After the complete topology-V2 source reseal, the same
Release canary passed with byte-identical probe/verifier output: 28,589 bytes,
SHA-256
`3a4ae506f5ed2eae16e9f46d099c5d53681ec1d1a02aa9c20549b0fbeb230d7c`.
This is the last topology-V2 actual-package secure-capture reseal. It predates
topology V3 and the composition target, and still is not V6/V7 execution-graph
proof.

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
It predates the two topology-V4 targets and is not V4 package-capture evidence.

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
It validates only the secure-capture substrate on the pinned host. It does not
reconcile V6/V7 selected-source execution graphs or establish source binding
V7, worker/model execution, fixture identity, evaluation, mechanics `PASS`,
Stage-B publication, a terminal receipt, reproducible-build identity, network
denial, Metal authority, scientific authority, or product authority.

Source binding V7 is reserved until every planned and deferred evidence role
is frozen and materialized, including the independent corrected mutation
producer/detector and process-scoped evaluation ownership, and a live
`PrimeNativeNeuralGateCompiledSourceClosureRecord` validates the same captured
`swift-package describe` bytes against the exact contract.

## Remaining evidence gaps

The existing 15-case corrected mutation observation is a validator over
caller-provided baseline, mutated, and restored records. It does not inject a
mutation or independently detect one.

The historical 46-case donor output exposes summary fields, not enough typed
raw material for a terminal verifier to recompute every mutation. Its private
mutators and detectors require a hash-bound source-derived seam rather than a
hand-port.

Bounded canonical JSON schemas exist only for the prompt-only,
outer-evaluation, and seed-scoped raw-execution manifests and their three row
shapes. Mutation deltas, historical observations, MLX observations,
statistics/verdict observations, worker/process/result records, and the
receipt remain `schema_deferred` and reject bytes before parsing. Descriptor
source binding streams invariant payloads, source-binds the complete
lossless sidecar, and produces sealed prompt/outer/raw/logit capabilities. The
outer adapter creates exact target-free raw and outer role projections and a
common-root keyed join. The V4 wrapper remains non-durable because each source
is bound separately. Topology V5 now retains the exact whole-root inventory,
authoritatively rebinds all four sources, requires unchanged recapture, and
binds the joined replay to the independent source-derived crosswalk. It proves
one bounded capture epoch and durable origin for those captured bytes,
corrected fixture identity, independent prompt/target association, and outer
expected-completion binding. It does not prove prompt-content target
independence, observe process delivery, execute mutations, or authorize a
verdict.

The three record streams are independently canonicalized ordered multisets.
Prompt rows have no execution index, while outer and raw rows do; therefore no
implementation may zip the sorted streams. Composition V1 now derives indexes
only as strict prompt-record ordinals and performs an exact keyed
outer/raw/validated-sidecar join with trace recomputation. Topology V5
binds that replay through one held-root four-source capture epoch and the
independent keyed crosswalk without materializing a worker. The focused
18,432-row, 41-file integration passed in 300.125 seconds. Topology V6
freezes the corrected process/evaluation/receipt ownership and target-free
delivery-preparation declarations. Topology V7 adds exact-count bounded stream
admission while keeping aggregate candidates non-`Decodable`, and freezes typed
common/branch/artifact and worker-source reference declarations. Real common/
branch scalar references are supervisor-derived and non-authorizing; realized
worker-source and role-artifact content references remain absent. The remaining
semantic gap begins with deferred
mutation/historical/MLX/statistics/verdict schemas, followed by disjoint
source-bound mutation producer/detector assignment, workers, and receipt-last
publication. The receipt declaration covers exactly 20 role-scoped
pre-receipt paths, not a full-root inventory; realized path/content and worker
closure/executable evidence remain absent.

Mutation identity must be `(arm, ordinal, mutation_id)` because
`target_dependent_prompt_grouping` has different meanings in the two arms.
Each mutation must bind an exact or explicitly allowed failure set; merely
containing one expected failed leg is insufficient.

The exact next prerequisite is
`freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`.

## Ordered continuation

1. Freeze the deferred mutation, historical, MLX, and statistics/verdict
   schemas.
2. Assign the corrected 15-case source-bound producer and an independently
   implemented
   detector. They may not share mutation implementation code.
3. Derive the historical gate/carrier seam and 46-case raw mutation material
   from the pinned donor source.
4. Materialize role-scoped workers and implement probe, verifier, exact
   inventory, process
   records, and receipt-last composition.
5. Run the durable full-vocabulary sidecar and maintained MLX Float32
   recomputation as Stage-B evidence.

Every step remains Swift-first and Prime-owned. Python, shell scientific
authority, PMHNP runtime dependencies, new model execution, Metal authority,
and product authorization are outside this topology claim.

## Additive topology V8 continuation

Steps 1 and 2 above are now satisfied by topology V8,
`prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8`,
SHA-256
`8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b`.
V8 preserves topology V1 through V7, semantic namespace V4, and V7's exact
twenty corrected pre-receipt paths. It freezes the deferred semantic record
schemas and adds four internal Swift targets: the narrow label-free,
presence-only surface contract; the semantic catalog/identity contract; the
corrected 15-case producer; and the independent detector. The corrected
mutation catalog/control contract has SHA-256
`9b40258ed7ba07dc62ff6bda96df03b2233575a039b5598b487d738d036a78bd`;
the role-specific assignment contract has SHA-256
`020fa5275a4ab7941b935271ad26b094b35b96c9fb85be765db1dd9130de36e2`.
The producer directly depends on semantic plus surface contracts. The
detector directly depends only on surface contracts, with a complete local
closure of surface plus replay mechanics. Its graph excludes catalog/identity,
expected-leg mapping, replay-artifact contracts, and producer reachability.
The detector's only public route requires an exact 15-case batch; the
single-triplet classifier is private. Every full bound baseline/restored
context must be byte-and-binding identical throughout that batch, and mutated
surfaces must be pairwise distinct. Wrong counts, duplicate cases, per-case
reference-hash or seed drift, and cap drift other than exact 63 against
baseline 64 fail closed. Permutation invariance is verified. `Label-free`
excludes explicit mutation IDs/labels, arbitrary prediction strings, and
per-case caller-controlled context.
The producer/detector assignment is no longer deferred, but actual Release
source-reference values remain absent and non-authorizing. No worker,
executable, process,
delivery, durable semantic artifact, verdict publication, or receipt is
materialized. `executionImplemented` remains false and source/execution-
binding V7 remains unissued.

The semantic boundary separately rejects count-only verdict promotion.
`countDerivedLabel` has scope `provisional_count_only_non_authorizing`; ten
bare true critical legs remain `ABSTAIN`. `GROUNDED` requires verified and
durably published per-leg evidence, weighted-statistics recomputation,
stable-greedy and behavioral fixed-prompt predicates, model capability
including exact abstention decisions, the mutation sweep, source-bound leg
evidence, distinct implementation families, and four-tier audit state.
The live exported
`PrimeNativeNeuralGateCountDerivedVerdict.recompute(legs:)` API remains
compatible but always returns `ABSTAIN`, exposes only the provisional scope,
and cannot return generic `GROUNDED`. Historical `GROUNDED` additionally
requires all five aggregate references to be verified/durably published and
model execution observed. These conditions remain absent, with mechanics
`PASS`, science, and product authority false.

Historical actual-package secure-capture checkpoints after topology V5 were
V6 at 40,100 bytes, SHA-256
`99431ac9477a6546225721027319fc460ff8b10c8e55ef68f07b5cb8c73c8cd9`,
and V7 at 41,951 bytes, SHA-256
`770b719a7e594f95e422f40dc5d4acd0fd93241928416a6bb3f27a448791f928`.
V7's embedded source identity was
`9cdfe7bfcbbedebce59b7abb45b614778e6674391b570a679ea40728be4c514f`.
These are secure-capture substrate prevalidation history only. Completed final
V8 validation is recorded canonically in the
[V8 semantic-schema and mutation-target record](PRIME-NATIVE-NEURAL-GATE-SEMANTIC-SCHEMA-MUTATION-TARGETS-2026-08-01.md).

The V8 next prerequisite was
`derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7`.
Topology V9 now satisfies it with one internal source-derivation target and
additive adaptation proof V3; every historical runtime, worker, process, and
source-binding authority remains absent. Topology V10 then materializes only
the exact runtime and isolated historical replay library targets; all current
production targets still cannot reach them. Its next prerequisite was
`derive_and_source_bind_source_faithful_historical_fixture_then_materialize_only_the_sealed_historical_worker_without_materializing_probe_verifier_or_issuing_source_binding_v7`.
Topology V11 now source-binds the exact historical fixture and adds only the
unavailable historical executable target. Target presence is not a sealed
worker or execution result. The V11 next prerequisite was
`derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7`.
V12 resolved only that design/source-contract boundary. Topology V13
materialized the exact source-only exporter. Topology V14 now appends that
exporter to the worker's exact four-dependency prefix and source- and
compile-binds one private cross-file call edge. That edge remains unreachable
from the exact V11 `main`, which exits `78`. The V14 prerequisite is
recorded in [Prime Native Neural Gate Historical Worker/Export Call-Edge Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORT-CALL-EDGE-SOURCE-2026-08-01.md).
V15 source-binds only the projection design; its prerequisite was
recorded in [Prime Native Neural Gate Historical Evidence Semantic-Artifact Projection Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-SEMANTIC-ARTIFACT-PROJECTION-DESIGN-2026-08-01.md).
V16 satisfies it additively with a product-free isolated projector. The worker
remains unavailable, ReplayTransport is not in the projector closure, no
artifact is written or published, and source/execution binding V7 is unissued.
See [Prime Native Neural Gate Historical Evidence Semantic-Artifact Projection
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-SEMANTIC-ARTIFACT-PROJECTION-SOURCE-2026-08-01.md).
V17 changes only worker reachability: the worker may reach the projector and
historical-safe semantic records through one private compiler-bound edge. The
reverse projector closure, corrected-target prohibitions, unavailable status,
and non-execution/V7 ceiling remain intact. See [Prime Native Neural Gate
Historical Worker Semantic-Artifact Projection Call-Edge
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-SEMANTIC-ARTIFACT-PROJECTION-CALL-EDGE-SOURCE-2026-08-01.md).
The topology remains `planned_not_materialized`, `executionImplemented`
remains false, and source/execution-binding V7 remains unissued.
See [Prime Native Neural Gate Historical Source Material](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-SOURCE-MATERIAL-2026-08-01.md).
See [Prime Native Neural Gate Historical Replay Mechanics](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-REPLAY-MECHANICS-2026-08-01.md).
See [Prime Native Neural Gate Historical Fixture and Worker Boundary](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-FIXTURE-WORKER-BOUNDARY-2026-08-01.md).

## V18 pure historical semantic-artifact decoder continuation

V18 appends exactly two implemented internal targets to the V17 graph and
changes no V17 target. The statistics wire target reaches only replay artifact
contracts. The decoder reaches only that statistics target, replay artifact
contracts, replay mechanics, and semantic record contracts. Both have empty
external-product and resource inventories. The exact V17 worker retains its
six dependencies and cannot reach either new target.

The V18 forbidden-reachability delta is symmetric and fail-closed: every V17
target is forbidden from reaching both new targets, while the statistics and
decoder targets are forbidden from reaching every target outside their exact
pure closures. The decoder therefore cannot reach the V16 projector, V13
exporter, historical runtime or worker, `PrimeCore`, `ReplayTransport`, any
corrected target, process ownership, or receipt ownership.

The consumer mechanics admit the six canonical JSON leaves and complete
22-key artifact set for each historical role, then pair exact-keyed fragments
of the 59,497-record global invariant stream against fifteen exact ordinal
chunks. Foundation `Codable` and canonical re-encoding own JSON admission,
while the statistics envelope is not publicly `Decodable`; the maintained
framed record reader owns stream parsing. Stream fragments are capped at
65,536 bytes, no all-binary materialization convenience or unverified record
callback exists, and the sixteen stream bindings plus complete 22-binding set
are derived only after terminal acceptance. No custom JSON/frame parser,
descriptor, filesystem or network API, worker edge, transport edge,
execution, or publication API is admitted.

Topology remains `planned_not_materialized`; this describes the wider
execution topology, not absence of the two source targets. Worker execution,
artifact I/O, durable evidence, mechanics `PASS`, receipt, source/execution
binding V7, scientific authority, and product authority remain false. The
next exact prerequisite is
`source_bind_the_unavailable_historical_worker_already_formed_v16_projected_artifact_set_to_the_complete_v18_historical_semantic_artifact_decoder_call_edge_without_enabling_replay_transport_integration_request_handling_sealing_launch_execution_io_publication_or_issuing_source_binding_v7`.
See [Prime Native Neural Gate Historical Semantic-Artifact Decoder
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-SEMANTIC-ARTIFACT-DECODER-SOURCE-2026-08-02.md).

The separate read-only Swift Git workflow preflight remains a later workflow
slice. It does not belong in the Stage-B evidence graph, and the signed-in
GitHub app remains the PR/check/merge publication boundary.

## V19 private worker/decoder call-edge topology continuation

V19 preserves the V18 target count and changes only the existing unavailable
historical worker. Its exact six V17 dependencies remain the prefix, the V18
decoder is appended as dependency seven, and one fourth worker Swift source
contains the direct private already-formed-V16-set-to-V18-decoder edge. The
status-`78` main and V14/V17 private members remain byte-exact and cannot name
the new member.

Worker reachability now includes the decoder and its statistics-contract
dependency, so exactly those two V18 worker prohibitions are removed. Every
other prohibition remains. The decoder/statistics reverse closures are
unchanged and still cannot reach the worker, projector, exporter, historical
runtime, `ReplayTransport`, corrected targets, process ownership, or receipt
ownership.

The edge's global-first equal-byte zipper caps every paired or remainder feed
at 65,536 bytes and delegates parsing and equality to the maintained V18
decoder. It adds no parser, frame-header arithmetic, record inspection,
filesystem/process I/O, transport, execution, or publication surface. The
live V17 guard evolves explicitly and additively to cover the V19 source and
dependency; its original identity remains historical rather than being
silently overwritten.

Topology stays `planned_not_materialized` and `executionImplemented` remains
false. Package reachability is not call-edge invocation. No worker, decoder,
gate, or model execution, durable evidence, `PASS`, receipt, source/execution
binding V7, scientific authority, or product authority is observed or
authorized. See [Prime Native Neural Gate Historical Worker Semantic-Artifact
Decoder Call-Edge
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-SEMANTIC-ARTIFACT-DECODER-CALL-EDGE-SOURCE-2026-08-02.md).

The next exact prerequisite is design-only:

`design_the_unavailable_historical_worker_in_memory_exported_evidence_projection_decode_composition_boundary_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V20 design-only composition topology

Topology V20 binds only
`prime_source_bound_historical_worker_exported_evidence_projection_decode_composition_design_v20`.
It preserves the exact V19 target graph, forbidden-reachability graph, target
count, package dependencies, products, resources, worker inventory, and
status-`78` entry point. No composition target or source edge is materialized.
The design and topology SHA-256 values are `b1fc91f4026cb1c513be53f9cf6f5d53834489eab215e1343aa6b00f05a51f4c` and
`b8045480883016fd49e7a63b02437f54835c1e7de6e61a4c2dea7f439a052a57`.

The future boundary has exactly two inputs: already-formed V14 Evidence and
explicit V16 context with both observation states fixed to `unavailable`.
Evidence equality or any invented digest cannot supply instance/source
identity; signed zero demonstrates the mismatch between value equality and
projected bit-pattern bytes. Its target-bearing fields remain opaque.

The reserved non-`Codable` projected+decoded pair must link one role and the
exact 22 typed keys by canonical order, byte count, and SHA-256. Future source
ownership is append-only in the V19 decoder edge's same file, allowing reuse
of the private decoder edge and V16 projector without duplicating the zipper
or widening access. V20 implements no such edge and makes no transport,
request, process, publication, receipt, or model path newly reachable.

Topology remains `planned_not_materialized` with
`executionImplemented == false`. No I/O, execution, durable evidence,
`PASS`, receipt, source/execution binding V7, scientific authority, or
product authority is observed or authorized. See [Prime Native Neural Gate
Historical Worker Exported-Evidence Projection/Decode Composition
Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORTED-EVIDENCE-PROJECTION-DECODE-COMPOSITION-DESIGN-2026-08-02.md).

The next exact prerequisite is:

`source_bind_the_unavailable_historical_worker_exported_evidence_projection_decode_composition_call_edge_as_an_append_only_same_file_v19_decoder_edge_continuation_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_changing_package_topology_or_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V21 composition source topology

Topology V21 adds only the source-contract binding for
`prime_source_bound_historical_worker_exported_evidence_projection_decode_composition_call_edge_v21`.
Its canonical SHA-256 is
`6d9e2787b54b6ab20f449497e6ac2b91c9945567211badfd4383f37b417f14a4`;
the bound source-contract SHA-256 is
`843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494`.

The V20 graph, forbidden reachability, target count, materialization states,
dependency order, products, resources, historical bindings, and status remain
exact. The existing fourth worker file evolves append-only, so neither the
worker inventory nor `Package.swift` changes. The separate status-78 main
cannot name the private composition edge, and no target gains reachability.

The new source guard/projects/decodes/links in memory only. No transport,
request, process, I/O, publication, receipt, model, mechanics `PASS`, V7,
scientific, or product authority is observed or authorized. See [Prime Native
Neural Gate Historical Worker Exported-Evidence Projection/Decode Composition
Call-Edge
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORTED-EVIDENCE-PROJECTION-DECODE-COMPOSITION-CALL-EDGE-SOURCE-2026-08-02.md).

Prime remains `ABSTAIN`. The next exact prerequisite is:

`design_the_bounded_unavailable_historical_worker_invocation_seam_for_the_source_bound_v21_composition_before_any_private_access_change_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V22 design-only invocation-seam topology

Topology V22 binds only
`prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_design_v22`
at `3954a98474cdaf79a62c65a20cf612f3a1ddaf6b8305aa941e94d3863791e757`; its own canonical SHA-256 is
`af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5`. The exact V21 target/forbidden-reachability
graphs, target count, materialization states, dependency order, products,
resources, worker inventory, status, source, and prior bindings remain exact.

The design reserves one future append-only nested internal wrapper with a sole
private V21 payload/private initializer and no accessor or conformance. Its
one internal static method may call the private V21 composition edge exactly
once with unchanged inputs and propagate all errors. V22 adds PrimeCore
governance contract/topology source only; it adds no worker, invocation-seam,
or runtime source and no reachability. The exact status-78 main cannot call the
nonexistent seam. See
[Prime Native Neural Gate Historical Worker Invocation Seam
Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-DESIGN-2026-08-02.md).

Topology remains `planned_not_materialized` with
`executionImplemented == false`. No invocation, replay, transport, request,
process, I/O, publication, receipt, V7, scientific, or product authority is
observed or authorized. Prime remains `ABSTAIN`. The next exact prerequisite
is:

`source_bind_the_bounded_unavailable_historical_worker_invocation_seam_as_an_append_only_same_file_v21_composition_continuation_preserving_all_v21_private_members_and_delegating_exactly_once_from_one_new_internal_nonpublic_typed_bridge_without_adding_a_main_call_edge_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`
