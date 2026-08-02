# Prime native neural-gate historical worker semantic-artifact decoder call-edge source

Date: 2026-08-02

## Decision

V19 source- and compile-binds one private, direct call edge from an
already-formed V16
`PrimeNativeNeuralGateHistoricalProjectedArtifactSet` to the complete V18
historical semantic-artifact decoder. The edge is a fourth Swift source in the
existing unavailable historical worker target. The V18 decoder becomes the
worker's seventh direct dependency after the exact six-dependency V17 prefix.

The edge first validates the supplied projected set and derives the invocation
role only from that set. It obtains exactly the six canonical leaves by typed
key, invokes the maintained V18 canonical decoder, and then drives the
maintained V18 invariant-stream decoder. It does not materialize the fixture,
invoke the V14 exporter, invoke the V16 projector, infer projection context,
or reconstruct projected identity.

This is compiler-bound plumbing, not historical execution evidence. The exact
V11 `main` remains in a separate source and exits unconditionally with status
`78`. The exact private V14 exporter edge and private V17 projector edge also
remain in separate files. None can name the new cross-file `private` member,
no test imports the worker executable, and the V19 edge is not invoked.

## Frozen identities

- Source contract ID:
  `prime_source_bound_historical_worker_semantic_artifact_decoder_call_edge_v19`
- Source contract canonical SHA-256:
  `f8739c0d162e026522dbdc2e6902403d935ebcfd2c9d13b07704b05ea3f9dac8`
- Topology ID:
  `prime_stage_b_historical_worker_semantic_artifact_decoder_call_edge_source_topology_v19`
- Topology canonical SHA-256:
  `84f07261ff86dab5836e96a2667a8d3a05b0ec597b9677d5f1bab77c2c8801ba`
- Preserved V17 source-contract canonical SHA-256:
  `ccf2e46ffc9e980d96357980e128ecb411a5ac5f55b8e783bf611582ec32d6d3`
- Preserved V18 decoder source-contract canonical SHA-256:
  `18b747001331df62115ba502a15f3bb8379a12f484176811860b191738235ae3`
- Preserved V17 topology canonical SHA-256:
  `3a14288df628b1d44936013af44dd237e876fd1cf2b38e4ce0afd3a4c5cd2166`
- Preserved V18 topology canonical SHA-256:
  `aa9dd4031469742fca5d0241bd329e7712d98ec81677704fbca911d5bdcf043f`

The V19 worker call-edge source is 7,050 bytes with SHA-256
`b8a4aaf4d9328df657f8fd62c3425b04ee2a293fb6dc75df19913635ef2f4cca`.
The V19 source-contract declaration is 36,540 bytes with source SHA-256
`4d0cf2c55b51aa3f63c850afbd597ee4c8aff35549a239378843c2519d256fbf`.
These physical source identities are distinct from the canonical contract and
topology hashes above.

Both canonical V19 identities were frozen only after the final source
contract and topology values were independently recomputed from canonical
JSON.

## Exact worker delta

The worker inventory contains one copied resource and exactly four Swift
sources:

1. `HistoricalFixtureEvidence/Package.resolved` — the preserved V11 fixture
   lock;
2. `PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift` — the
   preserved V14 private exporter edge;
3. `PrimeNativeNeuralGateHistoricalFixtureWorker.swift` — the preserved V11
   status-`78` entry point;
4. `PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift`
   — the V19 private decoder edge; and
5. `PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift`
   — the preserved V17 private projector edge.

The worker's exact seven direct dependencies are:

1. `PrimeCore`;
2. `ErgenticsPrimeRuntime`;
3. `PrimeNativeNeuralGateHistoricalReplayMechanics`;
4. `PrimeNativeNeuralGateReplayTransport`;
5. `PrimeNativeNeuralGateHistoricalEvidenceExportMechanics`;
6. `PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection`; and
7. `PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder`.

The first six are the exact V17 prefix. The V16 projector, V18 statistics
contract, and V18 decoder targets remain byte-exact and product-free. V19 does
not add a product, resource, adapter target, or external dependency.

## Bounded equal-byte zipper

The edge constructs exactly six canonical inputs by typed key:

1. material identity manifest;
2. gate observation;
3. invariant-records manifest;
4. fingerprint observation;
5. mutation observations; and
6. statistics-verdict observation.

After canonical admission, it iterates only the fifteen chunk indices declared
by the decoded manifest. For each current chunk it computes a paired byte count
as the smaller remaining global/chunk count, then caps the feed at the V18
descriptor maximum of 65,536 bytes. It feeds the global fragment first and the
current-chunk fragment second with the same byte count. It drains any bounded
current-chunk remainder before `finishCurrentChunk()`, then drains any bounded
global remainder after all declared chunks and calls
`finishSemanticArtifactSet()` once.

This is a memory-bounded delivery schedule into the existing decoder, not a
second decoder. Foundation `Data` indices and slices own byte partitioning.
Foundation `Codable` and the maintained V18 framed-record reader continue to
own JSON and frame parsing. V19 implements no JSON parser, frame parser,
frame-header constant, record-boundary arithmetic, positional artifact join,
or decoded-record inspection. Exact global/chunk record equality and terminal
binding remain V18 decoder responsibilities.

## Historical guard evolution

The V17 focused source guard is preserved transparently in two identities:

- historical V17 guard: 12,467 bytes, SHA-256
  `ff03b3a143ebc748dadf6d9a337d68753add478811395d78d27e5654c805a8f4`;
  and
- current additively evolved guard: 13,182 bytes, SHA-256
  `abba5e6dc188dfdebe5f5e6f519199c52692bd8e10b2cabbb68f0e44ac976b39`.

The live file is not represented as byte-identical to its V17 form. Its V19
evolution retains the exact V11/V14/V17 worker-source assertions and adds only
the fourth-source inventory and seventh-dependency continuation required by
the actual package. The V17 identity remains historical evidence; the evolved
identity is the current guard.

## Reachability and authority

V19 removes only the worker prohibitions that became structurally false: the
worker may now reach the V18 decoder and, through it, the V18 statistics
contract. Every other V18 prohibition is preserved. The reverse closures stay
disjoint: the decoder and statistics targets cannot reach the worker, V16
projector, V13 exporter, historical runtime, `ReplayTransport`, corrected
targets, process ownership, or receipt ownership.

Package reachability is not invocation. V19 enables no replay-transport
integration, request handling, sealing, launch, worker/fixture/exporter/
projector/decoder/gate/model execution, filesystem or process I/O, artifact
write, historical observation, evidence publication, durable publication,
independent detection, distinct implementation family, AgentContractKit
four-tier audit, mechanics `PASS`, terminal receipt, source/execution binding
V7, scientific authority, or product authority. Prime admission remains
`ABSTAIN`.

## Validation boundary

The Swift validation surface binds the exact worker source inventory, source
bytes, imports, normalized private signature, six keyed canonical inputs,
bounded global-first equal-byte schedule, absence of parser and I/O symbols,
exact package dependency delta, asymmetric target closure, prior canonical
hashes, additive historical-guard evolution, decoded mutation rejection, and
absence of worker import or call-edge invocation. A separate `swift build
--target PrimeNativeNeuralGateHistoricalFixtureWorker` compiler gate proves
only that the edge type-checks. The worker executable must not be run in this
slice.

## Next exact prerequisite

`design_the_unavailable_historical_worker_in_memory_exported_evidence_projection_decode_composition_boundary_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

This successor is design-only. It may specify composition from an
already-formed V14 evidence carrier plus explicit V16 context, but it must not
invoke the exporter, enable the worker, integrate transport, perform artifact
I/O, publish evidence, or claim any source/execution authority. Source binding
and implementation require separate later checkpoints.
