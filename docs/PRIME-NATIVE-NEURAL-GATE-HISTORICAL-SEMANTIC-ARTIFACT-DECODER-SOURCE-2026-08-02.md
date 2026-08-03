# Prime native neural-gate historical semantic-artifact decoder source

Date: 2026-08-02

## Decision

V18 satisfies the V17 decoder prerequisite with two product-free internal
Swift targets:

1. `PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts` owns the
   typed, lossless wire contract and canonical decoder for the complete V16
   keyed three-seed statistics artifact; and
2. `PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder` owns the pure
   caller-byte decoder for the six canonical JSON leaves and the paired
   invariant global/chunk streams.

This is a consumer boundary. It does not alter or import the frozen V16
projector, invoke the V17 worker edge, integrate `ReplayTransport`, obtain a
descriptor, read or write a filesystem path, launch a process, execute the
historical gate or a model, publish evidence, seal a receipt, or issue source
binding V7. Prime admission remains `ABSTAIN`.

## Identity status

The V18 source freeze is complete. The canonical source-contract identity is
`18b747001331df62115ba502a15f3bb8379a12f484176811860b191738235ae3`.
The canonical V18 topology identity is
`aa9dd4031469742fca5d0241bd329e7712d98ec81677704fbca911d5bdcf043f`.

The source contract also freezes the complete production and focused-test
inventory by Prime-relative path, exact byte count, and SHA-256:

- statistics artifact contracts: 28,668 bytes,
  `11a5d2d2bf82cad49a4767db1fd178422f32cdf0bf49a827f809848e5f50ea05`;
- canonical semantic-artifact decoder: 42,068 bytes,
  `22186320c67246dc0d97528bab2390dc6d95fc80f47b69732b11783957290ab8`;
- invariant artifact-stream decoder: 23,251 bytes,
  `3e543a7225afb1eedb8311a34cc995139fc725e1b3ea998fd66149f9783fcb30`;
  and
- focused decoder test: 63,808 bytes,
  `4d3bd9f07eb8c6ab3320e1bde7626c78270009e1d3f8afc43440d36cad3b1b9c`.

These identities are test-derived from live bytes and are not provisional.

V18 preserves these already-frozen inputs without rewriting them:

- V16 projection source contract
  `prime_source_bound_historical_evidence_semantic_artifact_projection_source_v16`;
- V17 worker/projector call-edge source contract
  `prime_source_bound_historical_worker_semantic_artifact_projection_call_edge_v17`;
  and
- V17 topology
  `prime_stage_b_historical_worker_semantic_artifact_projection_call_edge_source_topology_v17`.

The rights holder remains `Ergentics, LLC`; the license expression remains
`LicenseRef-Ergentics-Proprietary`.

## Pure consumer closure

The statistics target has one direct local dependency:

1. `PrimeNativeNeuralGateReplayArtifactContracts`.

The decoder target has four direct local dependencies:

1. `PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts`;
2. `PrimeNativeNeuralGateReplayArtifactContracts`;
3. `PrimeNativeNeuralGateReplayMechanics`; and
4. `PrimeNativeNeuralGateSemanticRecordContracts`.

Neither target is a library product or executable and neither copies a
resource. Their closures exclude the V16 projector, V13 exporter, historical
runtime, historical worker, `PrimeCore`, `PrimeNativeNeuralGateReplayTransport`,
corrected mutation/evaluation targets, process ownership, and receipt
ownership. Every V17 target remains unable to reach either V18 target. In
particular, the worker remains the exact V17 six-dependency status-`78`
executable and has no decoder edge.

## Exact artifact coverage

For each `probe` or `verifier` role, the V16 namespace contains exactly 22
keyed artifacts. V18 decodes the six bounded canonical-JSON leaves:

1. material-identity manifest;
2. gate observation;
3. invariant-record manifest;
4. fingerprint observation;
5. mutation-sweep observation; and
6. keyed three-seed statistics/verdict observation.

The remaining sixteen keyed artifacts are the invariant global stream and
fifteen ordered chunk streams. Artifact identity is always the typed namespace
key plus exact byte count and SHA-256. Array position is not accepted as
artifact identity. Missing, duplicate, wrong-role, unexpected, oversized,
empty, invalid-UTF-8, structurally invalid, or non-canonical leaves fail
closed.

Foundation `Codable` owns JSON parsing. The statistics envelope is publicly
`Encodable` but deliberately not publicly `Decodable`; only its bounded
canonical admission method can construct it from bytes. Private exact wire
DTOs are decoded, canonically re-encoded with sorted keys and unescaped
slashes, and compared to the caller bytes. The decoder then reconstructs the
existing public validating semantic contracts and requires their canonical
encoding to match the same bytes. This rejects ignored unknown keys,
duplicate-key normalization, whitespace or ordering drift, and fixed or
derived field drift without adding a custom JSON parser.

The six leaves are joined across role, artifact references, invariant
manifest, global SHA-256, direct fingerprint, all 46 historical mutation
records, the ten ordered critical-leg carrier values, and explicit observation
states. `unavailable` remains distinct from `observed_false`; decoding never
promotes either state.

## Paired invariant-stream admission

V18 reuses
`PrimeNativeNeuralGateInvariantFramedRecordReader`; it implements no second
frame parser. The caller supplies exact-keyed bounded `Data` fragments of at
most 65,536 bytes. The public boundary has no convenience that accepts all
sixteen descriptor-only binary artifacts as already-materialized `Data`. The
session incrementally admits:

- one canonical global stream containing exactly 59,497 records; and
- fifteen canonical chunk streams with exact ordinals zero through fourteen,
  4,096 records in each of the first fourteen chunks, and 2,153 records in the
  final chunk.

Global and chunk records are compared as exact `Data` in FIFO order. The
decoder exposes no pre-verification record callback, so a late-invalid suffix
cannot commit caller side effects. It verifies the declared and observed
record counts, chunk ordinals, stream byte counts, stream SHA-256 values,
manifest geometry, complete global/chunk equality, and empty pending queues
before deriving the sixteen stream bindings and complete ordered 22-binding
set. It retains only bounded unmatched records, never decodes either complete
stream through the whole-`Data` codec, and poisons the session after the first
failure. A successful finish is idempotent; feeds after finish are rejected.

These mechanics establish byte and schema admission only. Caller-supplied
`Data` is not a descriptor observation, filesystem provenance, durable
publication, or historical execution fact.

## Validation boundary

The focused Swift validation surface binds the exact target declarations,
dependencies, source inventories, imports, absence of products/resources and
forbidden APIs, canonical JSON rejection, complete keyed coverage, cross-leaf
joins, exact 59,497/15 geometry, global/chunk record equality, arbitrary feed
splits including nonzero-index `Data` slices, bounded global read-ahead, wrong
stream-key/ordinal poisoning, bounded pending state, terminal binding, and
source/topology mutation rejection. It also requires every V1 through V17
canonical topology hash to remain exact and the V17 worker target to remain
byte-for-byte equal in the V18 graph.

Synthetic producer bytes may be constructed only through the V16
package-internal assembly seam for compatibility mechanics tests. Those tests
do not show that the exporter, projector, worker, gate, model, historical
mutation workload, descriptor path, or publication path ran.

The repository-wide forward audit also extends the frozen V13 and V14 test
inventories by exactly this V18 focused test target and its exact source path.
Those legacy guards continue to reject every unlisted consumer or importer;
no production consumer, worker dependency, exporter edge, or broad wildcard
was added.

## Authority ceiling

V18 observes or authorizes none of the following:

- descriptor source binding or process delivery;
- worker request handling, sealing, launch, supervision, or execution;
- historical gate, model, mutation, MLX, or Metal execution;
- artifact writes, evidence publication, or durable publication;
- independent scientific detection or distinct implementation families;
- mechanics `PASS`, terminal receipt, or source/execution binding V7; or
- scientific or product authority.

Target materialization, compilation, decoding, and synthetic tests do not
change that ceiling.

## Next exact prerequisite

`source_bind_the_unavailable_historical_worker_already_formed_v16_projected_artifact_set_to_the_complete_v18_historical_semantic_artifact_decoder_call_edge_without_enabling_replay_transport_integration_request_handling_sealing_launch_execution_io_publication_or_issuing_source_binding_v7`

That later call edge must accept only the already-formed V16 artifact set and
delegate to the complete V18 decoder without reconstructing identity,
defaulting observations, performing I/O, or making `ReplayTransport`
reachable from the decoder. Transport integration, descriptor capture,
request handling, sealing, launch, execution, publication, and authority
remain separate future audits.

## V19 fulfillment and next design boundary

V19 satisfies the call-edge prerequisite above without changing either V18
target or any V16 producer source. The unavailable historical worker appends
the unchanged decoder as dependency seven after the exact V17 six-dependency
prefix and adds one fourth Swift source. Its private member accepts only an
already-formed V16 projected artifact set. The exact status-`78` main and
private V14/V17 members remain in other files and cannot name it.

The member validates the set, constructs the six canonical inputs by exact
key, and drives this V18 decoder with a bounded global-first equal-byte zipper.
Each paired global/chunk feed has the same byte count and is capped at 65,536
bytes. Current-chunk remainders are drained before chunk finish and any global
remainder is drained before the one terminal semantic-artifact-set finish.
V18 continues to own JSON/frame parsing, record equality, poisoning, and
terminal bindings; V19 adds no parser, frame-header math, record inspection,
I/O, transport, execution, or publication mechanism.

The V17 focused guard evolves transparently: its frozen historical identity
remains recorded while its current identity admits only the fourth worker
source and seventh dependency and retains the old exact source assertions.
Compilation is not invocation. No descriptor is captured, no worker or decoder
edge runs, and no historical evidence, mechanics `PASS`, receipt,
source/execution binding V7, scientific authority, or product authority is
created. See [Prime Native Neural Gate Historical Worker Semantic-Artifact
Decoder Call-Edge
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-SEMANTIC-ARTIFACT-DECODER-CALL-EDGE-SOURCE-2026-08-02.md).

The next exact prerequisite is deliberately design-only:

`design_the_unavailable_historical_worker_in_memory_exported_evidence_projection_decode_composition_boundary_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

It may design composition from an already-formed V14 evidence carrier and
explicit V16 context. It does not authorize exporter invocation, source
binding, implementation, request handling, transport, launch, artifact I/O,
publication, or execution.

## V20 design fulfillment

V20 fulfills that design prerequisite without changing this V18 decoder, the
V16 projector, the V19 bounded decoder edge, the unavailable worker, or the
package graph. The future operation accepts exactly an already-formed V14
Evidence value plus explicit V16 context. Both context observation states are
restricted to `unavailable`; no role or state may be inferred, defaulted, or
retried.

Evidence remains opaque and without canonical or source identity. In
particular, its equality cannot bind projected bytes because signed zeros
compare equal while the projection preserves distinct `Double.bitPattern`
values. Its target-bearing evaluation fields are not inspected, logged, or
used for model, evaluation, selection, or recommendation behavior.

The reserved non-`Codable` result retains both the exact projected artifact
set and this decoder's semantic artifact set. A future constructor must require
one role and exact linkage across all 22 ordered typed keys, byte counts, and
SHA-256 values. The pair retains bytes to avoid projection rerun, but creates
no origin, publication, durability, receipt, or admission authority.

Future source binding must be an append-only continuation in the V19 decoder
edge's same file and reuse the existing private edge; it may not copy this
decoder schedule, widen access, or add a parser. V20 implements or invokes no
such operation. Design SHA-256 is `b1fc91f4026cb1c513be53f9cf6f5d53834489eab215e1343aa6b00f05a51f4c`; topology SHA-256
is `b8045480883016fd49e7a63b02437f54835c1e7de6e61a4c2dea7f439a052a57`. See [Prime Native Neural Gate Historical
Worker Exported-Evidence Projection/Decode Composition
Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORTED-EVIDENCE-PROJECTION-DECODE-COMPOSITION-DESIGN-2026-08-02.md).

All transport, request handling, worker execution, artifact I/O, publication,
`PASS`, receipt, source/execution binding V7, scientific authority, and
product authority remain false. The next exact prerequisite is:

`source_bind_the_unavailable_historical_worker_exported_evidence_projection_decode_composition_call_edge_as_an_append_only_same_file_v19_decoder_edge_continuation_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_changing_package_topology_or_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V21 same-file decoder-edge reuse

V21 appends the designed composition after the exact V19 decoder-edge bytes.
It invokes that private edge once with the exact projected set; it does not call
this target's public decoder APIs directly, duplicate the global/chunk zipper,
add a parser, or widen access. The returned decoded set is linked to the
retained projected set across one role and all 22 typed keys by maintained
order and exact keyed specification, byte count, and SHA-256.

The append is compiler-bound but unreachable from the separate status-78
`main`. No decoder runtime observation, artifact I/O, transport, publication,
receipt, V7, science, or product authority follows. Source/topology SHA-256
values are `843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494`
and `6d9e2787b54b6ab20f449497e6ac2b91c9945567211badfd4383f37b417f14a4`.
See [Prime Native Neural Gate Historical Worker Exported-Evidence Projection/
Decode Composition Call-Edge
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORTED-EVIDENCE-PROJECTION-DECODE-COMPOSITION-CALL-EDGE-SOURCE-2026-08-02.md).

The next exact prerequisite is design-only:

`design_the_bounded_unavailable_historical_worker_invocation_seam_for_the_source_bound_v21_composition_before_any_private_access_change_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V22 invocation-seam design continuity

V22 leaves this decoder, its stream mechanics, and the V19/V21 worker source
exact. It designs only a later append to the existing V21 same-file
composition source: one internal wrapper nested in the worker, containing only
the private V21 result behind a private initializer, plus one internal static
method on that wrapper. The method may call only the private V21 composition
edge, exactly once, with unchanged Evidence/context inputs; all errors remain
the V21 errors and propagate without handling.

The future bridge may not call this decoder, the V19 decoder edge, or the V16
projector directly. V22 adds PrimeCore governance contract/topology source
only; it adds no worker, invocation-seam, runtime, decoder-consumer, or caller
source, and no `main` edge, package or graph delta, replay, transport, I/O, or publication.
Design/topology SHA-256 values are `3954a98474cdaf79a62c65a20cf612f3a1ddaf6b8305aa941e94d3863791e757` and
`af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5`. See [Prime Native Neural Gate Historical Worker
Invocation Seam
Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-DESIGN-2026-08-02.md).

No decoder or worker runs; Prime remains `ABSTAIN`. The next exact
prerequisite is:

`source_bind_the_bounded_unavailable_historical_worker_invocation_seam_as_an_append_only_same_file_v21_composition_continuation_preserving_all_v21_private_members_and_delegating_exactly_once_from_one_new_internal_nonpublic_typed_bridge_without_adding_a_main_call_edge_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V23 invocation-seam source continuity

V23 preserves this V18 decoder and the complete V19/V21 worker prefix while
appending only the V22-designed internal wrapper and one-call seam. The evolved
worker file is 13,227 bytes at
`62c0c413e25b95576a023f9b93f67b55a6c38f0cadbdfa4330dba31aea41ae54`;
the exact 11,354-byte V21 prefix is followed by a 1,873-byte suffix at
`64a0db36f309d92dbd8737f9a6401bb7b9adf58b0193dd4c6d3e46d906017811`.
The seam calls only the private V21 composition edge, never this decoder or the
V19 decoder edge directly.

The internal seam is module-nameable, but no `main` or cross-file reference,
caller, consumer, or runtime invocation exists. Its wrapper declares no
accessor or conformance. Ordinary external imports cannot name it, while a
separately built test/privileged module using `@testable import` could; no such
dependency or import exists. The wrapper remains ordinarily `Copyable`, may be inferred
`Sendable`, and can expose its private payload through generic reflection or
unsafe same-module code.

Source/topology hashes are `6ae4cd1fadf95f3b18c38d7e4ec2d732f6e0b614399fb76334043bf9851bb656` and
`48f5f1359af1eb3151196ef1e9cb417a6189d8c6461b0c3e595edee39aaee3d9`. No decoder execution, artifact I/O, transport,
publication, receipt, V7, scientific, or product authority is observed; Prime
remains `ABSTAIN`. See [Prime Native Neural Gate Historical Worker Invocation
Seam Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-SOURCE-2026-08-02.md).

The next exact prerequisite is design-only:

`design_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_result_consumer_boundary_for_the_source_bound_v23_internal_bridge_before_any_cross_file_or_main_call_edge_payload_observation_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V24 decoder-result discard design continuity

V24 materializes design-only PrimeCore governance contracts/tests/topology,
documentation, and provenance reseal at canonical hashes
`3c9f34cfae3e50012e40a4b59e38eb5a90bc47e3906a1df5c5111978dac3c902` and `711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91`; no worker
consumer source or compiler feasibility is observed. Its future V25 continuation must
remain in the V23 composition file and extend only the existing wrapper. The
extension reserves a two-case no-payload disposition and one synchronous
nonthrowing method that calls
`Self.sourceBoundUnavailableHistoricalWorkerInvocationSeam(...)` exactly once
with unchanged inputs, discards the wrapper via `_ = try`, and collapses every
thrown Swift `Error` through one bare catch without inspecting it.

Neither decoder artifacts nor errors may be observed, retained, reflected,
encoded, logged, timed, output, or published. No fifth file, direct decoder
call, cross-file or `main` caller, testable worker import, request, transport,
process, I/O, or execution is admitted. Source checks alone do not block
same-module, privileged/`@testable`, debugger/injected, dynamic-symbol,
`Mirror`, or unsafe bypass. Zeroization, constant-time behavior, crash
confidentiality, and trap/signal/OOM containment remain unestablished. A hard
runtime boundary requires later raw-seam narrowing/removal or isolation. Prime
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
