# Prime native neural-gate historical worker invocation seam design

Date: 2026-08-02

## Decision

V22 freezes only the design for one future, same-file, internal access seam to
the source-bound V21 composition edge. A reduced Swift lexical-access canary
compiler-checks the proposed nesting pattern, but the exact worker seam is not
materialized and its compiler feasibility remains unobserved. The design is
not a worker invocation, process invocation, request surface, transport edge,
runtime entry point, or execution observation. V22 adds PrimeCore governance
contract/topology source only; it adds no worker, invocation-seam, or runtime
implementation source.

The design contract is
`prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_design_v22`,
with canonical SHA-256 `3954a98474cdaf79a62c65a20cf612f3a1ddaf6b8305aa941e94d3863791e757`. The additive design
topology is
`prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_design_topology_v22`,
with canonical SHA-256 `af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5`. The rights holder is
`Ergentics, LLC`, and the license expression is
`LicenseRef-Ergentics-Proprietary`.

## Design-only preservation boundary

V22 changes no `Package.swift` declaration, target, dependency, product,
resource, worker inventory, worker source, executable entry point, projector,
decoder, replay transport, runtime, test fixture, or model/learning source.
The only future source path admitted by this design is the existing V21 file:

`Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift`

Its complete 11,354-byte V21 content with SHA-256
`39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d`
must remain the exact prefix of any later source continuation. The separate
2,298-byte `PrimeNativeNeuralGateHistoricalFixtureWorker.swift` remains exact
at SHA-256
`9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df`;
its `main` continues to exit unconditionally with status `78`. The 27,650-byte
`Package.swift` remains exact at SHA-256
`190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d`.
The complete V21 target and forbidden-reachability graphs remain the actual
package state.

## Reserved internal wrapper

The future append may introduce exactly one nested internal, nonpublic typed
wrapper whose fully qualified name is
`PrimeNativeNeuralGateHistoricalFixtureWorker.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult`.
It must contain exactly one stored property:

`private let compositionResult: PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult`

The payload type is the unchanged private V21 result. The wrapper must have an
explicit private initializer accepting only that payload. It may not declare
an accessor, property, method, subscript, closure, reflection/description
helper, custom mirror, encoding, or callback that exposes the payload or
either projected/decoded member. It has no additional stored or computed
properties and no declared `Codable`, `Equatable`, `Hashable`, `Identifiable`,
`Sendable`, `CustomStringConvertible`, error, collection, iterator, or other
conformance. As an internal value type with a `Sendable` payload, Swift may
infer `Sendable`, and the value remains ordinarily copyable; neither property
creates confidentiality, concurrency security, provenance, or authority.
Its internal name makes the wrapper type nameable within the worker module
without declaring a payload accessor. Swift `private` is API hiding, not a
confidentiality boundary: generic `Mirror` or unsafe same-module code may
still expose the stored label and value.

The wrapper is neither a receipt, confidentiality boundary, nor capability
token. Possession cannot establish security, source identity, fixture origin,
execution, publication, durability, admission, or authority.

## Reserved one-call seam

The future append may introduce exactly one internal, nonpublic static method
on the nested wrapper itself:

```swift
internal static func sourceBoundUnavailableHistoricalWorkerInvocationSeam(
    evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
    context: PrimeNativeNeuralGateHistoricalProjectionContext
) throws -> Self
```

Keeping the method on the nested wrapper is required: it can use its private
initializer while its lexical nesting in the worker can name the enclosing
worker's private V21 member. A top-level wrapper or a method directly on the
worker would require widening the initializer and is not admitted. Its body
must call the existing private V21
`sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge(evidence:context:)`
exactly once with the same arguments and place that sole returned value into
the wrapper through its private initializer. It may not call `compose`, the
V16 projector, the V19 decoder edge, the V18 decoder, the V14 exporter, or any
fixture, gate, model, transport, request, process, filesystem, network,
environment, publication, or receipt surface directly.

No V21 access level changes. The V21 error, result, `compose`, and composition
call-edge declarations all remain private. The future seam adds no error type,
case, mapping, catch, retry, fallback, optional try, force try, default,
logging, partial result, or substitution. It forwards the exact already-formed
Evidence and explicit V16 context unchanged, so V21 continues to own the
unavailable-only state guards, projection/decode work, linkage validation,
and every thrown failure.

Both V16 observation fields remain nonoptional and must arrive as the concrete
`.unavailable` case before V21 projects anything. `.observed_false` is a real
negative observation, not `.unavailable`; `.observed_true` is also outside
this seam; and `nil` is neither representable nor an alias for either state.
The future bridge may not duplicate these guards or default, infer, normalize,
coerce, or translate among `nil`, `.unavailable`, `.observed_false`, and
`.observed_true`.

## Invocation and leakage boundary

The word “invocation” names the future access seam, not an invocation event.
Even after a later source-binding slice, an internal method declaration alone
does not show that another source called it. V22 does not add the method at
all. It adds no `main` call edge, command argument, request decoder, transport
handler, service loop, process owner, launcher, test import of the worker,
wrapper consumer, or payload observer.

Evidence remains target-bearing, role-neutral, and non-`Codable`; this layer
is contractually prohibited from inspecting it. Context remains explicit. The
future seam may not inspect, copy, encode, hash, compare, normalize, rank,
select, log, train on, generate from, or recommend from either input. It may
not authenticate the caller-selected role or change `unavailable` into an
observation. The wrapper declares no payload accessor, but generic reflection
can extract private stored state. Any later caller, consumer, and publication
boundary therefore requires a separate security and leakage audit.

## Topology and authority ceiling

V22 binds only this design contract into an additive frozen topology. The V21
target graph, dependency order, target materialization, worker inventory,
products, resources, forbidden reachability, status, and source-contract
bindings remain exact. PrimeCore gains only the governance contract/topology
source in this slice; no worker target gains a dependency or source, no private
V21 member becomes reachable, and no composition wrapper or seam exists in
worker source.

No fixture, exporter, projector, decoder, composition, worker, gate, mutation
workload, triad, SZ, model, training, MLX, Metal, or evaluation runs. No
runtime input or output, request handling, sealing, launch, execution,
artifact I/O, transport integration, publication, durability, independent
detection, distinct implementation family, mechanics `PASS`, terminal
receipt, source/execution binding V7, scientific authority, or product
authority is observed or authorized. Prime remains `ABSTAIN`.

## Required mutation proofs

The design validation must reject:

- any change to the exact V21 source prefix, status-`78` main, `Package.swift`,
  worker inventory, target graph, dependency order, or forbidden reachability;
- source materialization of the wrapper or seam in V22;
- a top-level, public, package, SPI, exported, or otherwise broader wrapper or
  method, or relocation of the method from the nested wrapper;
- any wrapper payload other than the sole private V21 composition result;
- a non-private initializer, accessor, computed property, method, subscript,
  callback, declared reflection/description surface, extra field, or
  conformance, or any claim that private storage blocks generic reflection or
  provides confidentiality/security;
- any access-level change to a V21 private declaration;
- zero, two, conditional, indirect, retried, or substituted calls to the V21
  composition call edge;
- a direct call to `compose`, projector, decoder edge, decoder, exporter,
  fixture, gate, model, transport, request, process, I/O, publication, or
  receipt behavior;
- changed, optional, defaulted, inferred, inspected, copied, encoded, hashed,
  compared, or normalized Evidence/context inputs;
- any new error, catch, mapping, retry, fallback, optional/forced try, logging,
  partial result, or error-to-`ABSTAIN` conversion; and
- any `main` call edge, worker invocation, process invocation, execution,
  publication, durable-evidence, `PASS`, receipt, V7, scientific, or product
  claim.

Unknown canonical design/topology fields and every false-to-true execution or
authority mutation must also fail closed.

## Truthful nonclaims

V22 establishes a reviewed access-seam design and canonical design/topology
identities only. It does not establish source binding, compiler feasibility of
the reserved private/internal nesting, a callable method, a call site, payload
consumption, runtime invocation, artifact observation, memory behavior,
throughput, replay, model behavior, or publication feasibility.

## Next exact prerequisite

`source_bind_the_bounded_unavailable_historical_worker_invocation_seam_as_an_append_only_same_file_v21_composition_continuation_preserving_all_v21_private_members_and_delegating_exactly_once_from_one_new_internal_nonpublic_typed_bridge_without_adding_a_main_call_edge_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

That successor may source-bind only the reserved append-only wrapper and
one-call seam. A caller, `main` call edge, worker/process invocation, replay or
transport integration, request handling, execution, artifact I/O,
publication, receipt issuance, and source/execution authority remain later,
separately audited checkpoints.

## V23 source fulfillment

V23 fulfills this design with an exact append-only source continuation. The
full worker file is 13,227 bytes at
`62c0c413e25b95576a023f9b93f67b55a6c38f0cadbdfa4330dba31aea41ae54`.
It preserves the complete 11,354-byte V21 prefix at
`39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d`
and adds only a 1,873-byte suffix at
`64a0db36f309d92dbd8737f9a6401bb7b9adf58b0193dd4c6d3e46d906017811`.
The exact worker source now compiler-binds the nested internal wrapper and one
direct throwing call to the private V21 edge.

The V22 nonclaims evolve narrowly: wrapper/method source and compiler
feasibility are now observed, but invocation is not. Internal access makes the
seam nameable across the worker module, including from `main`; exact source
identity proves that `main` and every other worker file contain no reference or
call. No actual wrapper value, caller, or result consumer exists.

Ordinary external imports cannot name the internal seam. A separately compiled
test or privileged module using `@testable import` could name internals when the
worker is built for testing, but no such dependency, import, or caller exists.

The wrapper declares no accessor or conformance. Swift may infer `Sendable`,
the value remains ordinarily `Copyable`, and generic `Mirror` or unsafe
same-module code may expose the private payload. The value is not a
confidentiality, concurrency-security, provenance, receipt, or authority
boundary, and any future caller requires a separate leakage audit.

The V23 source-contract/topology hashes are
`6ae4cd1fadf95f3b18c38d7e4ec2d732f6e0b614399fb76334043bf9851bb656` and `48f5f1359af1eb3151196ef1e9cb417a6189d8c6461b0c3e595edee39aaee3d9`. No runtime
execution, I/O, transport, publication, receipt, V7, scientific, or product
authority is observed; Prime remains `ABSTAIN`. See [Prime Native Neural Gate
Historical Worker Invocation Seam
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-SOURCE-2026-08-02.md).

## V23 next exact prerequisite

`design_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_result_consumer_boundary_for_the_source_bound_v23_internal_bridge_before_any_cross_file_or_main_call_edge_payload_observation_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

That successor remains design-only. A cross-file or `main` call edge, payload
or error observation, replay/transport integration, execution, I/O, and
publication remain outside V23.

## V24 security audit resolution

V24 resolves the required caller/result-consumer audit by materializing its
PrimeCore governance contract/tests/additive topology, documentation, and
provenance reseal. Its canonical design/topology hashes are
`3c9f34cfae3e50012e40a4b59e38eb5a90bc47e3906a1df5c5111978dac3c902` and `711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91`; no worker
consumer source or compiler feasibility is claimed. A future V25 must preserve
the entire V23 source as an exact prefix
and append only a same-file extension of the existing wrapper. The extension
adds one internal no-payload disposition with exactly
`compositionCompletedAndDiscarded` and `failedClosedWithoutDetail`, and one
synchronous nonthrowing method. The method calls
`Self.sourceBoundUnavailableHistoricalWorkerInvocationSeam(...)` once with
unchanged inputs, discards the wrapper using `_ = try`, and reduces every
thrown Swift `Error` through one bare catch that binds or observes nothing.

The audit prohibits a fifth worker source, cross-file or `main` caller,
testable worker import, result retention/reflection, error detail,
serialization, output, logging, timing measurement, artifact I/O, request,
transport, process, execution, and publication. This is source-governance
exclusivity only: same-module, privileged/`@testable`, debugger/injected,
dynamic-symbol, `Mirror`, and unsafe code can bypass or expose the raw seam.
Zeroization, constant-time behavior, crash confidentiality, and trap/signal/OOM
containment remain nonclaims. Hard-runtime authorization requires a later
raw-seam narrowing/removal or hardened isolation checkpoint. Prime remains
`ABSTAIN`. See [the canonical V24 design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-CALLER-RESULT-CONSUMER-DESIGN-2026-08-02.md).

## V24 next exact prerequisite

`source_bind_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_discard_consumer_as_an_append_only_same_file_v23_continuation_with_exactly_one_unchanged_argument_v23_seam_call_exactly_two_nonpayload_dispositions_composition_completed_and_discarded_or_failed_closed_without_detail_and_total_swift_error_detail_suppression_without_returning_explicitly_copying_retaining_reflecting_encoding_serializing_logging_timing_measuring_or_publishing_evidence_context_wrapper_composition_or_error_values_and_without_adding_any_other_seam_caller_main_or_cross_file_call_edge_testable_worker_import_request_process_replay_transport_artifact_io_launch_execution_authority_or_source_binding_v7`
