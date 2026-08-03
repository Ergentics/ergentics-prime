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

## V20 composition design continuation

V20 freezes the continuation design but does not alter this V19 file or any
other worker, projector, decoder, runtime, package, or executable source. Its
future `compose` operation accepts exactly already-formed V14 Evidence and
explicit V16 context. Both context observation states must be `unavailable`;
the operation may not call the exporter, reconstruct Evidence, infer or
default role/state, or retry after substitution.

Evidence equality is explicitly non-authoritative. The signed-zero case proves
why: equal `Double` values can retain different V16 bit-pattern bytes.
Evidence also contains target-bearing evaluation fields, which the future edge
must pass opaquely to V16 and never inspect, log, rank, train on, generate from,
or use for recommendation.

The reserved
`PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult`
is a non-`Codable` pair of the exact V16 projected set and exact V18 decoded
set. The members must share one role and the exact ordered 22-key byte-count
and SHA-256 inventory. Keeping the projected bytes avoids later rerun or hand
reconstruction; it does not make the pair published, durable, admitted, or
receipt-bearing.

The later source slice must append both private static `compose` and
`sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge` members to
this same file. The worker call edge delegates only to `compose`; `compose`
invokes the V16 projector once, reuses the existing private V19 decoder edge
once, validates exact 22-key linkage, and constructs the result. Neither may
duplicate the zipper, widen private access, or introduce another decoder. V20
performs none of those actions.

Design SHA-256 is `b1fc91f4026cb1c513be53f9cf6f5d53834489eab215e1343aa6b00f05a51f4c`; topology SHA-256 is
`b8045480883016fd49e7a63b02437f54835c1e7de6e61a4c2dea7f439a052a57`. All runtime, transport, I/O, publication,
`PASS`, receipt, V7, scientific, and product claims remain false. See [Prime
Native Neural Gate Historical Worker Exported-Evidence Projection/Decode
Composition
Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORTED-EVIDENCE-PROJECTION-DECODE-COMPOSITION-DESIGN-2026-08-02.md).

The next exact prerequisite is:

`source_bind_the_unavailable_historical_worker_exported_evidence_projection_decode_composition_call_edge_as_an_append_only_same_file_v19_decoder_edge_continuation_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_changing_package_topology_or_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V21 append-only continuation

V21 now fulfills the V20 reservation in this same file. The complete V19 file
remains the exact first 7,050 bytes. The appended private `compose` method
guards both context observations as `unavailable`, invokes the V16 projector
once, reuses `sourceBoundHistoricalSemanticArtifactDecoderCallEdge` once, and
constructs the private `Sendable` result only after keyed 22-item role/order/
specification/byte-count/SHA linkage. The separately named V21 worker call edge
delegates only to `compose`.

No V19 zipper byte changes, access widening, direct V18 decoder call, direct
Evidence inspection in the new V21 layer, positional join, retry, parser, I/O,
transport, or publication is introduced. The maintained V16 projector's
transitive Evidence processing remains unchanged and bound. The full live file
is 11,354 bytes with SHA-256
`39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d`.
Source/topology canonical hashes are
`843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494`
and `6d9e2787b54b6ab20f449497e6ac2b91c9945567211badfd4383f37b417f14a4`.
See [Prime Native Neural Gate Historical Worker Exported-Evidence Projection/
Decode Composition Call-Edge
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORTED-EVIDENCE-PROJECTION-DECODE-COMPOSITION-CALL-EDGE-SOURCE-2026-08-02.md).

The next exact prerequisite is design-only:

`design_the_bounded_unavailable_historical_worker_invocation_seam_for_the_source_bound_v21_composition_before_any_private_access_change_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V22 design continuity without decoder-edge change

V22 preserves this complete V19 prefix, the V21 suffix, and every private
member/access level. It designs one later same-file continuation only: a
nested internal wrapper whose sole private payload is the V21 composition
result, with a private initializer, no declared accessor or conformance, and one
internal static method on the wrapper. That method calls the private V21
composition edge exactly once with unchanged inputs and propagates its errors.

The future bridge may not call or duplicate this V19 decoder edge, zipper, V18
decoder, or V16 projector. V22 adds PrimeCore governance contract/topology
source only; it adds no worker, invocation-seam, runtime, or caller source and
no main edge, package/graph change, replay, transport, execution, I/O, or publication.
Design/topology SHA-256 values are `3954a98474cdaf79a62c65a20cf612f3a1ddaf6b8305aa941e94d3863791e757` and
`af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5`. See [Prime Native Neural Gate Historical Worker
Invocation Seam
Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-DESIGN-2026-08-02.md).

Compilation, invocation, and authority remain unobserved; Prime remains
`ABSTAIN`. The next exact prerequisite is:

`source_bind_the_bounded_unavailable_historical_worker_invocation_seam_as_an_append_only_same_file_v21_composition_continuation_preserving_all_v21_private_members_and_delegating_exactly_once_from_one_new_internal_nonpublic_typed_bridge_without_adding_a_main_call_edge_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V23 same-file invocation seam after the V19/V21 edges

V23 preserves every V19 and V21 byte and private access level, then appends the
bounded wrapper/seam in the same file. The full source is 13,227 bytes at
`62c0c413e25b95576a023f9b93f67b55a6c38f0cadbdfa4330dba31aea41ae54`;
its exact V21 prefix is 11,354 bytes at
`39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d`,
and its sole 1,873-byte suffix is
`64a0db36f309d92dbd8737f9a6401bb7b9adf58b0193dd4c6d3e46d906017811`.
The new method delegates only to the private V21 edge exactly once and does not
duplicate or call the V19 decoder edge directly.

Internal module nameability is now real, but no other worker source or `main`
reference exists. The wrapper has no declared accessor or conformance; inferred
`Sendable`, ordinary `Copyable`, and generic `Mirror` exposure remain possible,
so it is not a security boundary.

Ordinary external imports cannot name the internal seam. A separately compiled
test or privileged module using `@testable import` could name internals when the
worker is built for testing, but no such dependency, import, or caller exists.

Source/topology hashes are `6ae4cd1fadf95f3b18c38d7e4ec2d732f6e0b614399fb76334043bf9851bb656` and
`48f5f1359af1eb3151196ef1e9cb417a6189d8c6461b0c3e595edee39aaee3d9`. No caller, decoder execution, I/O, transport,
publication, receipt, V7, scientific, or product authority is observed; Prime
remains `ABSTAIN`. See [Prime Native Neural Gate Historical Worker Invocation
Seam Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-SOURCE-2026-08-02.md).

The next exact prerequisite is design-only:

`design_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_result_consumer_boundary_for_the_source_bound_v23_internal_bridge_before_any_cross_file_or_main_call_edge_payload_observation_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V24 post-decoder caller/discard design

V24 materializes design-only PrimeCore governance contracts/tests/topology,
documentation, and provenance reseal at hashes
`3c9f34cfae3e50012e40a4b59e38eb5a90bc47e3906a1df5c5111978dac3c902` and `711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91`; no worker
caller/result-consumer source or compiler materialization follows. A future
V25 may append only after the exact
V23 bytes in this same composition/decoder-edge file. It extends the V23
wrapper with one internal, zero-payload two-case disposition and one
synchronous nonthrowing consumer. That consumer calls
`Self.sourceBoundUnavailableHistoricalWorkerInvocationSeam(...)` exactly once
with unchanged Evidence/context, discards the returned wrapper via `_ = try`,
and collapses every thrown Swift `Error` through one bare catch without
inspecting it.

No fifth worker source, direct decoder duplication, cross-file or `main`
caller, testable worker import, result/error observation, retention,
reflection, serialization, output, logging, timing, artifact I/O, request,
transport, process, execution, or publication is admitted. Source scans do not
prevent same-module, privileged/`@testable`, debugger/injected, dynamic-symbol,
`Mirror`, or unsafe bypass. Memory zeroization, constant-time behavior, crash
confidentiality, and trap/signal/OOM containment remain unestablished. The raw
seam must later be narrowed/removed or isolated before hard-runtime use. Prime
remains `ABSTAIN`. See [the V24 design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-CALLER-RESULT-CONSUMER-DESIGN-2026-08-02.md).

The next exact prerequisite is:

`source_bind_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_discard_consumer_as_an_append_only_same_file_v23_continuation_with_exactly_one_unchanged_argument_v23_seam_call_exactly_two_nonpayload_dispositions_composition_completed_and_discarded_or_failed_closed_without_detail_and_total_swift_error_detail_suppression_without_returning_explicitly_copying_retaining_reflecting_encoding_serializing_logging_timing_measuring_or_publishing_evidence_context_wrapper_composition_or_error_values_and_without_adding_any_other_seam_caller_main_or_cross_file_call_edge_testable_worker_import_request_process_replay_transport_artifact_io_launch_execution_authority_or_source_binding_v7`


## V25 source continuation

V25 completes that historical prerequisite with the exact 948-byte append. The
nonpayload boundary is the sole checked-in raw-seam caller, its opaque result is
discarded, and its fixed two-case disposition has no caller. The worker target
compiler-checks, but no runtime, I/O, publication, receipt, V7, scientific, or
product authority edge exists. Prime remains `ABSTAIN`. See [the canonical V25
source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-CALLER-RESULT-CONSUMER-SOURCE-2026-08-02.md).

The V25 next exact prerequisite is:

`design_the_one_token_non_append_only_raw_v23_invocation_seam_access_rebinding_from_internal_to_private_while_preserving_the_v25_internal_nonpayload_boundary_as_the_sole_ordinary_source_level_callable_path_before_any_main_or_cross_file_call_edge_untrusted_request_transport_launch_runtime_confidentiality_artifact_io_publication_authority_or_source_binding_v7`

## V26 private-access rebinding design update

V26 now binds the design for the exact future half-open byte replacement
12_555..<12_563 from internal to private. V26 does not edit the worker:
the checked-in raw seam remains internal, the V25 internal nonpayload
boundary remains its sole checked-in caller, main still exits 78, and Prime
remains ABSTAIN.

The projected source passed a bounded Swift frontend typecheck, but it is not
checked in and no clean Release product build, launch, execution, input,
output, I/O, publication, receipt, V7, scientific authority, or product
authority is claimed. Private will block ordinary direct cross-file naming;
it will not block indirect calls through the internal boundary, same-file
extensions of the declaring nested type, compiler/debugger privilege,
reflection after wrapper possession, unsafe access, or the conditional
returned-versus-threw/timing/resource/crash oracle.

See [the V26 design contract](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-PRIVATE-ACCESS-REBINDING-DESIGN-2026-08-02.md).

The V27 exact prerequisite is:

`source_bind_the_one_token_non_append_only_raw_v23_invocation_seam_access_rebinding_from_internal_to_private_while_preserving_every_other_v25_worker_source_byte_the_v25_internal_nonpayload_boundary_as_the_sole_checked_in_raw_seam_caller_and_the_four_file_worker_inventory_without_any_main_cross_file_caller_request_transport_launch_runtime_confidentiality_artifact_io_publication_authority_or_source_binding_v7`
