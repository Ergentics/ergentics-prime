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

## Remaining planned execution topology

The following targets are names and dependency constraints only. None exists
in `Package.swift` yet:

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

A future adaptation proof V3 must route both into:

```text
Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/
```

The fixture prefix, transformed byte count, and SHA-256 must then be
recomputed from the pinned Swift donor bytes. No donor source is copied or
compiled by this topology slice.

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

The separate read-only Swift Git workflow preflight remains a later workflow
slice. It does not belong in the Stage-B evidence graph, and the signed-in
GitHub app remains the PR/check/merge publication boundary.
