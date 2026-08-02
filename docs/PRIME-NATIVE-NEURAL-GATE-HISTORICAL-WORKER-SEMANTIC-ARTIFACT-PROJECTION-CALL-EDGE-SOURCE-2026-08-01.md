# Prime native neural-gate historical worker semantic-artifact projection call-edge source

Date: 2026-08-01

## Decision

V17 source- and compile-binds one private carrier-to-projector call edge in a
third historical-worker Swift source. The member accepts an already-formed
V13 `PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence` value and an
explicit V16 `PrimeNativeNeuralGateHistoricalProjectionContext`, then contains
exactly one typed call to
`PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection.project(evidence:context:)`.

This is compiler evidence only. The source does not derive or materialize the
carrier, materialize the fixture, invoke the exporter, infer context, or add
defaulting, reduction, ordering, or serialization beyond the delegated V16
projector; that projector performs the carrier-to-artifact-set transformation
if called. The edge does not decode transport, write artifacts, or publish
evidence. The exact
V11 `main` and exact V14 exporter edge remain in separate files and cannot name
the new `private` member. No test imports the executable target, and this
validation slice does not launch it.

## Frozen identities

- Source contract ID:
  `prime_source_bound_historical_worker_semantic_artifact_projection_call_edge_v17`
- Source contract canonical SHA-256:
  `ccf2e46ffc9e980d96357980e128ecb411a5ac5f55b8e783bf611582ec32d6d3`
- Topology ID:
  `prime_stage_b_historical_worker_semantic_artifact_projection_call_edge_source_topology_v17`
- Topology canonical SHA-256:
  `3a14288df628b1d44936013af44dd237e876fd1cf2b38e4ce0afd3a4c5cd2166`
- Preserved V14 worker/exporter call-edge contract SHA-256:
  `8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8`
- Preserved V16 projection-source contract SHA-256:
  `2b9c1565f103622eb82e53e4a83820b98d6dd0d3dfd5487353dde06c5a4fd4dd`
- Preserved V16 topology SHA-256:
  `7e9dafad211bb0fb450ff9054be71a0022f5a259b4021d90123eb4736df747d3`

The new call-edge source is 1,227 bytes with SHA-256
`dce631bd4749a05d8f04323b51c4da37e5ef67df14b950f1e5eee1d1565e0964`.
Its focused source guard is 12,467 bytes with SHA-256
`ff03b3a143ebc748dadf6d9a337d68753add478811395d78d27e5654c805a8f4`.
The V17 source-contract declaration is 37,424 bytes with source SHA-256
`aa745be837ec221324812740771e2f6373824feeb4a135221f0e9f32a2333b7f`.
The V17 topology/source test is 26,788 bytes with source SHA-256
`a3d7a6be22fa5ffdec50e449eeabe1d74e0cabf8e7ce2fd48e29421937a79ced`.
These physical source identities are distinct from the canonical contract and
topology hashes above.

## Exact worker delta

The worker inventory is exactly one copied resource and three Swift sources:

1. `HistoricalFixtureEvidence/Package.resolved` — the preserved V11 fixture
   lock;
2. `PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift` — the
   preserved V14 private exporter edge;
3. `PrimeNativeNeuralGateHistoricalFixtureWorker.swift` — the preserved V11
   status-`78` entry point; and
4. `PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift`
   — the V17 private projector edge.

The worker's exact six direct dependencies are:

1. `PrimeCore`;
2. `ErgenticsPrimeRuntime`;
3. `PrimeNativeNeuralGateHistoricalReplayMechanics`;
4. `PrimeNativeNeuralGateReplayTransport`;
5. `PrimeNativeNeuralGateHistoricalEvidenceExportMechanics`; and
6. `PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection`.

The first five remain the exact V14 prefix. The projector target and its four
dependencies remain unchanged and product-free.

## Reachability and authority

V17 removes exactly two worker prohibitions because the new direct edge makes
them structurally false: the worker target can reach the projector and, through
it, `PrimeNativeNeuralGateSemanticRecordContracts`. All corrected mutation,
probe, verifier, corrected-worker, evaluation, receipt, and source-binding
paths remain forbidden. The asymmetric boundary is unchanged: the projector
cannot reach the worker, `PrimeNativeNeuralGateReplayTransport`, `PrimeCore`,
or any corrected-mutation target.

`PrimeNativeNeuralGateReplayTransport` remains an independent existing worker
dependency. V17 adds no decoder or transport integration. Package reachability
does not establish invocation.

The worker remains unavailable with status `78`. V16 synthetic
projector-component tests remain non-historical mechanics evidence. V17
enables no request handling, sealing, launch, worker call-edge or public
`project(evidence:context:)` entry-point invocation, worker-derived historical
artifact construction or I/O, gate/model execution, historical evidence
observation or publication, durable evidence, independent detection,
distinct-family or four-tier audit, mechanics `PASS`, terminal receipt,
source/execution binding V7, scientific authority, or product authority. Prime
admission remains `ABSTAIN`.

## Validation boundary

Swift tests bind the exact source inventory, imports, normalized method body,
single projector call, package delta, asymmetric target closure, frozen V1
through V16 canonical hashes, decoded mutation rejection, and absence of test
imports of the worker and absence of public projector-entry-point
invocation. Projector tests may import that library and bind its function value
without calling it. A separate `swift build --target
PrimeNativeNeuralGateHistoricalFixtureWorker` compiler gate is required. The
worker executable must not be run in this slice.

The existing V9–V12 donor-gate environment markers remain mandatory for the
full suite. V17 adds no donor source and no environment marker.

## Next exact prerequisite

`design_and_source_bind_the_complete_v16_historical_semantic_artifact_decoder_boundary_for_six_canonical_json_leaves_and_descriptor_streamed_global_and_chunk_artifacts_per_role_before_any_replay_transport_integration_request_handling_sealing_launch_execution_io_publication_or_source_binding_v7`

That decoder boundary must preserve exact keyed identity and complete artifact
coverage. ReplayTransport integration, worker request handling, sealing,
launch, execution, I/O, publication, and source/execution binding V7 remain
later, separately audited work.

## V18 decoder fulfillment and next boundary

V18 satisfies the decoder-design prerequisite above without changing this V17
worker target, its exact six-dependency graph, its private projector member, or
its status-`78` unavailable main. Two product-free consumer targets are added
outside the worker closure. The statistics target exposes a public
`Encodable` envelope and keeps its `Decodable` wire private behind bounded,
validated canonical decoding. The semantic decoder admits exactly six keyed
canonical-JSON leaves for one role and does not import or call the V16
projector.

The stream API accepts exact-keyed fragments no larger than 65,536 bytes for
the global stream or current chunk. It exposes neither an all-stream `Data`
convenience nor an unverified record callback. Sixteen stream bindings become
available only after terminal verification of exact FIFO equality for 59,497
records across one global stream and fifteen ordered chunks, including all
framing, count, byte-count, SHA-256, ordinal, coverage, and pending-queue
checks. The complete result then joins those sixteen bindings with the six
canonical-leaf bindings into the namespace's exact ordered 22-key set.

Package reachability still does not establish invocation. V18 adds no edge
from the unavailable worker to either decoder target and performs no
descriptor capture, `ReplayTransport` integration, request handling, sealing,
launch, filesystem/process I/O, worker/gate/model execution, artifact write,
publication, mechanics `PASS`, terminal receipt, source/execution binding V7,
scientific authorization, or product authorization. See [Prime Native Neural
Gate Historical Semantic-Artifact Decoder
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-SEMANTIC-ARTIFACT-DECODER-SOURCE-2026-08-02.md).

The exact next prerequisite is:

`source_bind_the_unavailable_historical_worker_already_formed_v16_projected_artifact_set_to_the_complete_v18_historical_semantic_artifact_decoder_call_edge_without_enabling_replay_transport_integration_request_handling_sealing_launch_execution_io_publication_or_issuing_source_binding_v7`

That future call edge must remain private and unavailable from the status-`78`
main. It may delegate only an already-formed V16 artifact set and may not
reconstruct identity, default observations, enable transport or request
handling, perform I/O or execution, publish, seal, or widen authority.
