# Prime native neural-gate historical worker invocation seam caller/result-consumer design

Date: 2026-08-02

## Decision

V24 freezes only the security and leakage design for one future caller and
discard consumer of the V23 internal invocation seam. The future source is a
same-file, append-only extension of the existing V23 wrapper. It may call
`Self.sourceBoundUnavailableHistoricalWorkerInvocationSeam(...)` exactly once
with unchanged Evidence/context inputs, explicitly discard the returned
wrapper without observing its payload, collapse every thrown Swift `Error`
without inspecting it, and return only one of two fixed, zero-payload mechanics
dispositions.

V24 does not materialize that worker source. It does not establish its compiler
feasibility, add a worker caller, invoke the worker, or change any package
declaration, worker target, dependency, resource, process, request, transport,
artifact, or authority edge. V24 does materialize the PrimeCore governance
contract and additive topology, their tests, this documentation, and the
repository provenance reseal. The exact V23 worker source and its absence of a
checked-in caller remain the repository truth. Prime remains `ABSTAIN`.

The design contract is
`prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_security_design_v24`,
with canonical SHA-256 `3c9f34cfae3e50012e40a4b59e38eb5a90bc47e3906a1df5c5111978dac3c902`. The additive design
topology is
`prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_security_design_topology_v24`,
with canonical SHA-256 `711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91`. The rights holder remains
`Ergentics, LLC`, and the license expression remains
`LicenseRef-Ergentics-Proprietary`.

## Exact preservation boundary

V24 preserves the V23 source contract at
`6ae4cd1fadf95f3b18c38d7e4ec2d732f6e0b614399fb76334043bf9851bb656`
and the V23 topology at
`48f5f1359af1eb3151196ef1e9cb417a6189d8c6461b0c3e595edee39aaee3d9`.
The only future worker source path admitted by this design is:

`Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift`

Its complete 13,227-byte V23 content at
`62c0c413e25b95576a023f9b93f67b55a6c38f0cadbdfa4330dba31aea41ae54`
must remain the exact byte-for-byte prefix of any V25 continuation. That V23
file already preserves the 11,354-byte V21 prefix at
`39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d`
and has the sole 1,873-byte V23 suffix at
`64a0db36f309d92dbd8737f9a6401bb7b9adf58b0193dd4c6d3e46d906017811`.

The future V25 continuation may not rewrite a V23 byte, change imports, add a
fifth worker source, place the caller in another file, or change the exact
status-`78` `main`. `Package.swift`, the four-file worker inventory, seven
ordered direct local dependencies, one resource, target graph, products, and
forbidden-reachability rules remain exact. V24 materializes PrimeCore
governance contract/test/topology source, documentation, and the provenance
reseal only. It adds no worker or runtime implementation, worker test-target
dependency/import, package declaration, caller/result-consumer source, or
execution source.

## Threat model and access-control truth

The complete worker module is inside the trusted source-governance boundary.
That is a repository review boundary, not a hard runtime security boundary.
The V23 wrapper and raw seam are internal, so any same-module source,
including a changed `main`, can name them. A separately compiled test or other
privileged module using `@testable import` can name internal declarations when
the worker is built for testing. A debugger, injected same-process code,
dynamic-symbol lookup, or emitted Swift metadata can also bypass the planned
consumer. V24 neither denies nor mitigates those paths.

Ordinary non-testable source outside the worker module cannot name the raw
seam through Swift access control. Exact source inventory and exact caller
scans can prove that no checked-in bypass is added. They cannot prove binary
symbol absence, unforgeable caller capability, same-process confidentiality,
dynamic-invocation resistance, or runtime authorization. The future safe
consumer must be the only checked-in raw-seam call outside the raw-seam
declaration, but that exclusivity remains source-governance-only.

No test target may gain a dependency on or `@testable import` of the worker.
Tests may inspect source or use reduced language canaries; they may not import,
launch, or execute the historical worker.

## Evidence, context, and result sensitivity

The Evidence value contains the ordered invariant records, baseline bundle,
mutation identifiers, stream identifiers, fingerprints, failure sets,
critical-leg values, statistics, and historical verdict material. Its
non-`Codable` declaration is not a confidentiality property: it remains a
copyable, reflectable value that same-process code can manually inspect or
serialize.

The context contains a caller-selectable invocation role and two explicit
observation states. The future boundary does not authenticate the Evidence
origin, the caller, or the selected role. It passes both inputs unchanged and
does not inspect, copy explicitly, compare, encode, hash, normalize, default,
coerce, log, retain, or publish them. The private V21 composition remains the
sole owner of its exact `.unavailable` requirements; `.observed_false`,
`.observed_true`, and absence are not aliases for `.unavailable`.

The V23 wrapper transitively retains projected historical artifact bytes,
specifications, paths, hashes, and decoded semantic artifacts. That payload is
not authorized for disclosure. Generic `Mirror`, unsafe memory access, string
reflection, or same-module code could expose it despite the private field. The
future consumer therefore does not access the payload at all.

## Reserved fixed disposition

The future append may add exactly one internal enum nested in the existing V23
wrapper. Its exact fully qualified name is:

`PrimeNativeNeuralGateHistoricalFixtureWorker.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult.CallerResultConsumerDisposition`

It has exactly two cases, in this order:

1. `compositionCompletedAndDiscarded`
2. `failedClosedWithoutDetail`

Both cases have zero associated values. The enum has no raw value type and
declares no conformance, custom description, reflection helper, encoding,
error surface, property, method, or subscript. It carries no Evidence,
context, wrapper, composition result, payload, path, hash, count, role, error,
timing, receipt, or authority value.

`compositionCompletedAndDiscarded` means only that the raw V23 seam returned a
wrapper for the supplied in-memory values and the caller explicitly discarded
that wrapper. It does not mean the Evidence was authentic, the role was
authorized, an artifact was durably read or written, a replay passed, or a
scientific/product verdict was established. `failedClosedWithoutDetail` means
only that a thrown Swift `Error` crossed the raw seam and was reduced to the
single failure disposition. It is neither `nil` nor an observed-false value.
Both dispositions preserve Prime `ABSTAIN`.

The two-case return exposes one deliberately coarse mechanics distinction:
returned versus threw. No finer result or failure detail is authorized.

## Reserved caller and discard consumer

The future same-file append may extend the V23 wrapper with exactly one
internal, static, synchronous, nonthrowing, nongeneric method:

```swift
internal static func
    sourceBoundUnavailableHistoricalWorkerInvocationSeamCallerAndDiscardConsumer(
        evidence:
            PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
        context:
            PrimeNativeNeuralGateHistoricalProjectionContext
    ) -> CallerResultConsumerDisposition
```

Its entire semantic shape is reserved as:

```swift
do {
    _ = try Self.sourceBoundUnavailableHistoricalWorkerInvocationSeam(
        evidence: evidence,
        context: context
    )
    return .compositionCompletedAndDiscarded
} catch {
    return .failedClosedWithoutDetail
}
```

The direct call must use the explicit `Self.` qualification shown above and
occurs exactly once. The exact nonoptional Evidence and context values are
forwarded unchanged, with no default arguments, variadics, `inout`, overload,
generic, retry, fallback, substitution, partial result, or alternate call
path. Success is returned only after the raw seam returns. The underscore
assignment deliberately creates no named wrapper binding. The sole bare catch
may not bind, reference, inspect, pattern-match, cast, compare, stringify,
encode, log, retain, or rethrow the implicit error. Every thrown Swift `Error`,
including transitive exporter/projector/decoder/composition errors, maps to
`failedClosedWithoutDetail`.

The method may not return the V23 wrapper or payload, make an explicit wrapper
copy, store it in any local name, property, static/global, collection, cache,
closure, task, actor, continuation, or other escaping location, or pass it to
another function. It may not use `Mirror`, unsafe memory, pointers,
`String(describing:)`, `String(reflecting:)`, an encoder, serializer, hash,
comparison, logger, assertion, metric, trace, signpost, debugger helper, or
timing measurement. It may not add a second raw-seam caller.

## Retention and memory nonclaims

The discard contract prohibits explicit retention and observation; it does
not establish compiler copy elision, unique storage, deterministic
destruction, or memory erasure. The V23 wrapper is ordinarily `Copyable` and
may be inferred `Sendable`. Its `Data` values can use copy-on-write storage.
The compiler and runtime may create temporaries, and discarded bytes may
remain in process memory. V24 does not establish zeroization, debugger
confidentiality, or protection from unsafe same-process inspection.

No asynchronous or concurrent handoff is admitted. The future method is
synchronous and may not create a task, actor hop, detached operation,
continuation, escaping closure, callback, or retry queue.

## Error, crash, and timing nonclaims

The bare catch contains the normal Swift thrown-error channel only. It does
not catch traps, signals, process termination, fatal runtime failures,
precondition or assertion failures, stack exhaustion, or out-of-memory
termination. The future source may not introduce `assert`, `precondition`,
`fatalError`, forced casts, forced unwraps, or forced tries.

The transitive V21 implementation has input- and failure-location-dependent
work. V24 does not establish constant-time behavior, timing-side-channel
resistance, resource-exhaustion resistance, or crash-report confidentiality.
The future consumer must not measure or publish elapsed time, throughput,
memory, branch location, error count, or error category. A later process owner
requires a separate crash, resource-budget, and timing policy before launch.

## Output, process, and publication boundary

The future consumer returns only the fixed in-memory disposition. It produces
no encoded bytes, `Data`, JSON, property list, text, log, standard output,
standard error, metric, signpost, artifact, path, hash, count, role, or error
description. It performs no filesystem, resource, `Bundle`, environment,
command-line, standard-input, network, IPC, XPC, request, process, launcher,
or publication operation.

The worker's existing dependency on `PrimeNativeNeuralGateReplayTransport` is
pre-existing and remains unintegrated. V24 does not add a transport handler,
request decoder, service loop, process owner, `main` caller, cross-file caller,
or artifact read/write edge. No wrapper, composition result, error, or
disposition is serialized, durably retained, or published.

## Source-governance proof and hard-runtime prerequisite

A V25 source-binding contract may enforce the exact V23 prefix, one appended
same-file extension, one disposition enum, one safe method, one explicitly
`Self.`-qualified raw-seam call, one bare catch, no other call outside
declarations, exact import and four-file worker inventories, and lexical
absence of every forbidden observation, retention, output, I/O, transport, and
runtime surface. Those proofs govern checked-in source only.

The append-only V25 shape cannot narrow or remove the already materialized V23
internal seam. Before any untrusted process launch, request or transport
surface, runtime confidentiality assertion, or dynamically adversarial use,
the raw seam must be deliberately narrowed/removed in a separately reviewed
non-append-only source-rebinding checkpoint or isolated behind a hardened
module/process boundary that does not export it. Release-binary symbol and
metadata inspection, process ownership, caller authentication, crash policy,
resource budgets, and dynamic-invocation hardening belong to that later
checkpoint. V24 makes no claim that it is already satisfied.

## Topology and authority ceiling

V24 binds design facts only. It changes no V1-through-V23 topology identity,
package declaration, target state, dependency order, product, resource,
four-file worker inventory, status, source contract, or forbidden-reachability
edge. The future consumer is not source-materialized; its compiler feasibility
is not observed. There is still no checked-in caller, wrapper instance, result
consumption event, runtime input/output, process launch, or execution event.

No fixture, exporter, projector, decoder, composition, worker, gate, mutation
workload, triad, SZ, model, training, MLX, Metal, or evaluation runs. No
artifact I/O, replay, request, transport, publication, durability, independent
detection, distinct implementation family, mechanics `PASS`, receipt,
source/execution binding V7, scientific authority, or product authority is
observed or authorized. Prime remains `ABSTAIN`.

## Required fail-closed proofs

The future design contract and topology validation must reject:

- any change to a V1-through-V23 canonical identity, the V23 worker prefix,
  import inventory, `Package.swift`, status-`78` `main`, other worker source,
  resource, package graph, target graph, dependency order, physical inventory,
  or forbidden reachability;
- caller/result-consumer source or compiler-feasibility claims in V24, or any
  worker/runtime implementation, worker test-target dependency/import, package
  declaration, or execution-source change attributed to V24;
- a fifth worker file, separate-file continuation, cross-file or `main` caller,
  test-target dependency, `@testable` worker import, second raw-seam call, or
  any claim that source scans prevent same-module, dynamic, injected,
  debugger, or metadata-based bypass;
- any disposition type with a different name, order, count, payload, raw type,
  associated value, conformance, property, method, description, reflection,
  encoding, error, timing, or authority surface;
- a throwing, asynchronous, instance, generic, overloaded, defaulted,
  optional, variadic, `inout`, differently named, or differently typed future
  consumer;
- zero, two, unqualified, indirect, conditional, retried, or substituted
  raw-seam calls, or any changed, inspected, copied explicitly, normalized,
  encoded, retained, or authenticated Evidence/context argument;
- any named wrapper result, returned or escaped wrapper, payload access,
  explicit copy, storage, cache, collection, closure/task/actor/continuation
  handoff, reflection, unsafe/pointer access, string description, comparison,
  hash, encoding, serialization, logging, output, metric, signpost, trace,
  timing measurement, assertion, precondition, trap, or publication;
- any catch binding, error inspection, pattern matching, cast, description,
  encoding, logging, retention, rethrow, differentiated error mapping, retry,
  fallback, substitution, optional/forced try, or partial result;
- any claim of compiler copy elision, unique `Data` ownership, zeroization,
  constant-time behavior, crash-report confidentiality, trap/signal/OOM
  containment, resource-exhaustion resistance, binary-symbol absence,
  unforgeable capability, dynamic resistance, or runtime authorization; and
- any process, request, transport, replay, artifact I/O, launch, execution,
  publication, mechanics `PASS`, receipt, V7, science, product, or other
  authority claim.

Unknown canonical design/topology fields and every false-to-true execution,
security, or authority mutation must fail closed.

## Truthful nonclaims

V24 establishes a reviewed, canonical design for a bounded source-level
caller/discard consumer only. It does not establish that the future enum or
method exists, compiles, is called, is unbypassable, prevents reflection or
unsafe access, erases memory, contains traps/OOM, resists timing, authenticates
inputs, or safely owns a process. The V23 raw seam remains present and has no
checked-in caller. V24 materializes only its PrimeCore governance
contract/tests/additive topology, documentation, and provenance reseal; the
reserved worker caller/result-consumer source and its compiler feasibility
remain future work.

## Next exact prerequisite

`source_bind_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_discard_consumer_as_an_append_only_same_file_v23_continuation_with_exactly_one_unchanged_argument_v23_seam_call_exactly_two_nonpayload_dispositions_composition_completed_and_discarded_or_failed_closed_without_detail_and_total_swift_error_detail_suppression_without_returning_explicitly_copying_retaining_reflecting_encoding_serializing_logging_timing_measuring_or_publishing_evidence_context_wrapper_composition_or_error_values_and_without_adding_any_other_seam_caller_main_or_cross_file_call_edge_testable_worker_import_request_process_replay_transport_artifact_io_launch_execution_authority_or_source_binding_v7`

That successor may source-bind only the reserved same-file caller/discard
consumer. It must preserve the complete V23 source as an exact prefix and the
four-file worker inventory. A `main` or cross-file caller, process/request or
transport boundary, runtime launch, payload publication, and hard-runtime
access narrowing/isolation remain later, separately audited prerequisites.

## V25 source-binding resolution

V25 materializes the reserved source shape exactly. It preserves all 13,227 V23
bytes, appends the 948-byte reviewed suffix, retains the four-file worker
inventory and unchanged imports, and compiler-checks the exact Release worker
target. The new nonpayload boundary is the sole checked-in raw-seam caller and
has no caller of its own.

The source binding does not alter the V24 design's security ceiling. `_ =`
avoids a named wrapper binding but does not establish destruction, zeroization,
confidentiality, constant-time behavior, or trap/signal/out-of-memory
containment. The raw seam remains internal and therefore bypassable by other
same-module or privileged code. No runtime or authority edge exists and Prime
remains `ABSTAIN`.

See [the canonical V25 source contract](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-CALLER-RESULT-CONSUMER-SOURCE-2026-08-02.md).

The V25 next exact prerequisite is:

`design_the_one_token_non_append_only_raw_v23_invocation_seam_access_rebinding_from_internal_to_private_while_preserving_the_v25_internal_nonpayload_boundary_as_the_sole_ordinary_source_level_callable_path_before_any_main_or_cross_file_call_edge_untrusted_request_transport_launch_runtime_confidentiality_artifact_io_publication_authority_or_source_binding_v7`
