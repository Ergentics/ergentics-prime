# Prime native neural-gate historical worker invocation seam source

Date: 2026-08-02

## Decision

V23 source-binds the exact V22-designed invocation seam as an append-only
continuation of the V21 composition file. It adds one nested internal wrapper,
one private payload, one private initializer, and one internal static throwing
method. That method passes an already-formed Evidence value and explicit V16
context unchanged to the private V21 composition edge exactly once and stores
only its returned value.

This is a compiler-bound source seam, not an invocation event. No other worker
source references the wrapper or method. The status-`78` `main` remains exact,
there is no caller or result consumer, and no wrapper value is constructed at
runtime.

The V23 source-contract canonical SHA-256 is
`6ae4cd1fadf95f3b18c38d7e4ec2d732f6e0b614399fb76334043bf9851bb656`. The additive V23 topology canonical SHA-256
is `48f5f1359af1eb3151196ef1e9cb417a6189d8c6461b0c3e595edee39aaee3d9`. The rights holder remains `Ergentics, LLC`, and
the license expression remains `LicenseRef-Ergentics-Proprietary`.

## Exact append-only source identity

The evolved source is:

`Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift`

Its complete V23 identity is:

- byte count: `13,227`;
- SHA-256:
  `62c0c413e25b95576a023f9b93f67b55a6c38f0cadbdfa4330dba31aea41ae54`.

The exact V21 source remains the byte-for-byte prefix:

- byte count: `11,354`;
- SHA-256:
  `39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d`.

The sole V23 suffix is:

- byte count: `1,873`;
- SHA-256:
  `64a0db36f309d92dbd8737f9a6401bb7b9adf58b0193dd4c6d3e46d906017811`.

No V21 byte, import, private declaration, error, result, `compose` method, or
composition call edge changes. The V23 material is a same-file continuation;
no fifth worker source is added.

## Exact wrapper and call edge

The continuation adds the internal nested type
`PrimeNativeNeuralGateHistoricalFixtureWorker.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult`.
It has exactly one stored property:

`private let compositionResult: PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult`

The property is initialized only by an explicit private initializer. The
wrapper declares no payload accessor, additional stored or computed property,
subscript, callback, custom reflection/description surface, encoding, or
conformance.

The wrapper owns one internal static throwing method:

```swift
internal static func sourceBoundUnavailableHistoricalWorkerInvocationSeam(
    evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
    context: PrimeNativeNeuralGateHistoricalProjectionContext
) throws -> Self
```

Its body performs exactly one operation: it calls the unchanged private V21
`sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge(evidence:context:)`
once with the original arguments and places the sole returned value into the
private initializer. It adds no guard, parser, validation, normalization,
comparison, branch, retry, fallback, optional or forced try, catch, error
mapping, logging, partial result, exporter call, direct projector/decoder call,
I/O, transport, process, request, or publication operation. Every transitive
thrown error propagates without handling.

## Access-control and caller truth

The wrapper and method are internal. They are therefore nameable from source
inside the worker module, including the `main` file and the other worker source
files. Internal access is not a caller-isolation or runtime-reachability proof.
An ordinary non-testable import from outside the module cannot name the seam,
but a separately compiled test or otherwise privileged module using
`@testable import` may name internal declarations when the worker is built for
testing. V23 adds no test-target dependency on the worker, `@testable` worker
import, privileged module, or caller.

V23 instead proves absence of a caller by preserving the complete physical
worker inventory and exact identities of every non-evolved source:

- evidence-export edge: `1,512` bytes,
  `d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319`;
- status-`78` main: `2,298` bytes,
  `9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df`;
- semantic-artifact projection edge: `1,227` bytes,
  `dce631bd4749a05d8f04323b51c4da37e5ef67df14b950f1e5eee1d1565e0964`.

None contains the V23 wrapper or method name or a call edge to it. No new
source, cross-file reference, `main` reference, test import of the worker,
consumer, or runtime entry point exists.

That source-level fact is not a binary-hardening claim. A debug build may emit
the internal seam function, type metadata, value witnesses, and reflection
metadata as dynamically visible symbols. V23 does not assert their absence and
does not establish resistance to dynamic lookup, code injection, or external
invocation. The exact claim is limited to no checked-in caller, no process or
request entry point, no call path from `main`, and no observed invocation.

## Reflection, copying, and concurrency truth

The private payload is source-level API hiding only. Generic `Mirror` or unsafe
same-module code may expose the stored label and value. The wrapper is not a
confidentiality, secrecy, provenance, receipt, capability, or authority
boundary.

The wrapper declares no conformance. Because its private payload is
`Sendable`, Swift may infer `Sendable` for the internal value type; the value is
also ordinarily `Copyable`. Inferred sendability and ordinary copying do not
provide concurrency isolation or security. A future caller could also observe
transitively propagated errors. Any caller, payload observation, reflection,
error handling, result consumption, or publication boundary therefore requires
a separate security and leakage design before source is added.

V23 creates no runtime wrapper instance and performs no reflection or payload
observation. Its reflection proof is a reduced language canary, not an
invocation of the actual seam.

## Package and topology preservation

The exact `Package.swift` remains `27,650` bytes at
`190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d`.
The worker still has four Swift sources, seven direct local dependencies, and
one resource. The resource remains `1,949` bytes at
`cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3`.
No symlink or unsupported filesystem node is admitted.

V23 changes no package declaration, product, target, dependency, resource,
target graph, or forbidden-reachability rule. The additive topology binds only
the V23 source contract. Module-level nameability is stated separately and is
not misrepresented as a target-graph edge.

## Authority ceiling

V23 establishes exact source identity and compiler feasibility for the bounded
seam only. It does not establish a caller, result consumer, runtime invocation,
successful composition, error observation, fixture materialization, exporter,
projector or decoder execution, replay, request handling, process ownership,
sealing, launch, artifact I/O, transport integration, evidence publication,
durability, independent detection, distinct implementation family, mechanics
`PASS`, terminal receipt, source/execution binding V7, scientific authority,
or product authority. Repository source reads performed by tests are governance
verification, not historical-artifact I/O.

Prime remains `ABSTAIN`.

## Fail-closed source proof

The source contract and tests must reject:

- any change to the exact V21 prefix, V23 suffix, full V23 file, import
  inventory, other worker source, resource, `Package.swift`, package graph, or
  physical inventory;
- any broader or different wrapper/method access, relocation, overload,
  attribute, generic, conformance, accessor, extra field, default argument, or
  alternate initializer;
- zero, two, indirect, conditional, retried, substituted, or reordered V21
  calls, or changed Evidence/context arguments;
- any new guard, validation, catch, error mapping, optional/forced try,
  fallback, logging, reflection helper, I/O, transport, request, process,
  publication, or direct exporter/projector/decoder behavior;
- any other worker-file or `main` reference, caller, consumer, invocation, or
  claim that internal/private access prevents module naming, reflection,
  copying, inferred sendability, or error observation; and
- every false-to-true execution or authority mutation and every unknown
  canonical field.

## Next exact prerequisite

`design_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_result_consumer_boundary_for_the_source_bound_v23_internal_bridge_before_any_cross_file_or_main_call_edge_payload_observation_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

That successor is design-only. It must explicitly constrain who may call the
internal seam, how the reflectable and copyable result may be consumed, and how
transitive errors are handled before any caller or runtime path is
materialized.

## V24 caller/result-consumer design continuity

V24 leaves this canonical V23 worker source exact while materializing its
PrimeCore governance contract/tests/additive topology, documentation, and
provenance reseal. The V24 design/topology hashes are
`3c9f34cfae3e50012e40a4b59e38eb5a90bc47e3906a1df5c5111978dac3c902` and `711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91`; no new worker
wrapper extension, caller, result consumer, or compiler feasibility is
observed. V25 may use this complete 13,227-byte V23
file only as an exact prefix and append a same-file extension of the existing
wrapper. The extension reserves one internal two-case, zero-payload disposition
and one synchronous nonthrowing method: exactly one unchanged-argument call to
`Self.sourceBoundUnavailableHistoricalWorkerInvocationSeam(...)`, explicit
`_ = try` wrapper discard, and one bare catch mapping every thrown Swift
`Error` to `failedClosedWithoutDetail` without inspection.

The future source may add no fifth worker file, cross-file or `main` caller,
testable worker import, named/retained/reflected wrapper, error detail, encoded
or serialized output, log, timing measurement, I/O, request, transport,
process, execution, or publication. Exact source identity remains only a
checked-in governance control. Same-module, privileged/`@testable`,
debugger/injected, dynamic-symbol, generic `Mirror`, and unsafe code can bypass
the safe consumer or expose V23 state. Zeroization, constant-time behavior,
crash confidentiality, and trap/signal/OOM containment are not established.
Before hard-runtime use, the raw V23 seam must be narrowed/removed or isolated
behind a hardened boundary. Prime remains `ABSTAIN`. See [the canonical V24
design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-CALLER-RESULT-CONSUMER-DESIGN-2026-08-02.md).

## V24 next exact prerequisite

`source_bind_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_discard_consumer_as_an_append_only_same_file_v23_continuation_with_exactly_one_unchanged_argument_v23_seam_call_exactly_two_nonpayload_dispositions_composition_completed_and_discarded_or_failed_closed_without_detail_and_total_swift_error_detail_suppression_without_returning_explicitly_copying_retaining_reflecting_encoding_serializing_logging_timing_measuring_or_publishing_evidence_context_wrapper_composition_or_error_values_and_without_adding_any_other_seam_caller_main_or_cross_file_call_edge_testable_worker_import_request_process_replay_transport_artifact_io_launch_execution_authority_or_source_binding_v7`
