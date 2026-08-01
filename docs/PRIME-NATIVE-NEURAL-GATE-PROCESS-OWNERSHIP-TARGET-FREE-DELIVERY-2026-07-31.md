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

This is a contract, projection, and retained-capability-binding change. No
supervisor or worker target is materialized, no schedule has crossed a process
boundary, no model has run, and no receipt has been created.

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
typed role-to-path-to-content binding, common capture/schedule references, and
source-pinned worker closure/executable references remain forward blockers.

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

## Next prerequisite

The next bounded implementation step is:

`freeze_typed_source_pinned_worker_and_role_artifact_references_with_common_capture_schedule_binding_and_bounded_candidate_stream_decoder_then_freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers`

The next slice must first freeze typed source-pinned worker and role-artifact
references plus their common capture/schedule binding. Its decoder must
preserve the slot byte limits and aggregate row/byte bounds and must not promote
copied source references into capture authority. Only after those references,
the decoder, the deferred schemas, and the disjoint producer/detector boundary
are frozen should Prime materialize the historical worker and paired Stage-B
supervisors/workers.
