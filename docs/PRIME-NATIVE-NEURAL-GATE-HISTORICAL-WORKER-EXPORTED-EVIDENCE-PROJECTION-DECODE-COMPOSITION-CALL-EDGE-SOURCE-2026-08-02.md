# Prime native neural-gate historical worker exported-evidence projection/decode composition call-edge source

Date: 2026-08-02

## Decision

V21 fulfills the exact V20 source prerequisite by appending one private,
compiler-checked, in-memory composition continuation to the existing V19
worker decoder-edge file. It adds no file to the worker inventory and changes
no `Package.swift` declaration, target, dependency, product, resource,
transport edge, executable entry point, or runtime reachability.

The source contract is
`prime_source_bound_historical_worker_exported_evidence_projection_decode_composition_call_edge_v21`,
with canonical SHA-256
`843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494`.
Topology V21 is
`prime_stage_b_historical_worker_exported_evidence_projection_decode_composition_call_edge_source_topology_v21`,
with canonical SHA-256
`6d9e2787b54b6ab20f449497e6ac2b91c9945567211badfd4383f37b417f14a4`.
The rights holder is `Ergentics, LLC`; the license expression is
`LicenseRef-Ergentics-Proprietary`.

## Physical append identity

The only evolved worker source is:

`Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift`

Its exact V19 content remains the first 7,050 bytes with SHA-256
`b8a4aaf4d9328df657f8fd62c3425b04ee2a293fb6dc75df19913635ef2f4cca`.
V21 appends a 4,304-byte suffix with SHA-256
`ba11c0a40cb2b49d56471b9863d63adc694fc0e52963de087e563e7105066c95`.
The resulting 11,354-byte live file has SHA-256
`39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d`.
No formatter or import sorter rewrote the prefix.

The physical V21 source-contract file is 42,027 bytes with SHA-256
`667f69bc9746e7eb6ab580e28d1980a5b534510343ffeb001fc6b1f30e874486`.
`Package.swift` remains the exact 27,650-byte file with SHA-256
`190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d`.

## Exact source shape

The append introduces one file-scope import for the already-declared direct
worker dependency
`PrimeNativeNeuralGateHistoricalEvidenceExportMechanics`. It then defines:

- a private typed error with only
  `contextMustRemainUnavailable` and `invalidArtifactLinkage`;
- a private, `Sendable`-only
  `PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult`
  containing exactly `projectedArtifacts` and `decodedArtifacts`;
- private static `compose(evidence:context:)`; and
- private static
  `sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge(evidence:context:)`,
  whose body delegates only to `compose`.

The result is not `Codable`, `Equatable`, `Hashable`, `Identifiable`, or
`CustomStringConvertible`; it has no public initializer and retains no V14
Evidence value or object and no V16 context value or object. Evidence-derived
bytes, the context-derived invocation role, and fail-closed metadata
transitively present on the two maintained sets remain unchanged. The result
adds no new dedicated path, descriptor, callback, logging, publication,
verdict, `PASS`, receipt, or authority field or accessor and cannot promote
that retained metadata.

## Fail-closed composition order

`compose` performs these operations in exact order:

1. require both `sourceBytesResolved` and `adaptationProofRecomputed` to be
   `.unavailable`;
2. pass the already-formed V14 Evidence and explicit V16 context unchanged to
   the maintained V16 projector exactly once;
3. pass that exact projected set to the same-file private V19 decoder edge
   exactly once;
4. require the context, projected set, and decoded set to share one role;
5. require exactly 22 projected artifacts and 22 unique decoded typed keys in
   the maintained canonical specification order;
6. for every decoded typed key, use the maintained keyed projected-artifact
   lookup and require equal specification, byte count, and SHA-256; and
7. construct the two-field result only after all linkage succeeds.

The maintained V16 projected-set validator owns projected canonical order;
the maintained V18 decoded-set initializer owns decoded canonical order and
unique coverage. V21 explicitly compares those orders, but the per-key join
remains keyed. It does not use `zip`, enumeration/index joins, sorting,
filtering, a duplicate-key dictionary constructor, or positional-only
matching.

## Evidence and failure boundary

The new V21 composition layer passes Evidence unchanged and does not directly
access a field or invent an Evidence comparison, hash, reflection,
description, encoding, log, sort, filter, rank, training, generation,
recommendation, or routing operation. The maintained V16 projector still
reads Evidence and encodes/hashes derived artifacts exactly as already bound;
V21 neither duplicates nor reinterprets that work. This preserves the V20
signed-zero and Unicode equality boundary: value equality is not emitted byte
identity, instance identity, source identity, or provenance.

Projector, decoder, binding, and specification errors propagate directly.
There is no `try?`, `try!`, catch, retry, fallback, partial result, role/state
substitution, or error-to-`ABSTAIN` conversion. The local typed errors identify
only unavailable-context or linkage rejection; they convey no verdict or
authority.

## Historical test evolution

Two older tests truthfully evolved because they previously treated the V19
prefix as the complete live file:

- the V19 topology test moved from 36,630 bytes / SHA-256
  `c3299463d56354424f57243737aa05611d7b7237f291bf723705762bfd63b476`
  to 37,734 bytes / SHA-256
  `88fd3f1159794593ea71d18bdf994df584b821c2d6f94eea03be73ad50a9f841`;
  it now applies V19 import, call-count, zipper, and `.project(` prohibitions
  only to the exact 7,050-byte historical prefix; and
- the V20 design test moved from 29,489 bytes / SHA-256
  `fcd0acea3e81123fb2764e46dfaa9bffb2f9c0d21167407e90a73ab03663343e`
  to 30,219 bytes / SHA-256
  `ccb83ef6eef21ae77aaf20cb056f49cfd6b04f4861e1f45ae1de4a32b7691eec`;
  it now verifies both the exact V19 prefix and the transparent V21 suffix.

The frozen V19 and V20 contracts and canonical topology identities do not
change.

## Topology and authority ceiling

V21 adds one optional source-contract binding to the canonical topology. Its
V20-to-V21 canonical delta is exactly the new binding plus schema version,
contract ID, package-capture statement, next prerequisite, and authority
statement. The V20 target graph, dependency order, target materialization,
forbidden reachability, prior bindings, products, resources, worker inventory,
and status remain exact.

The worker stays a four-Swift-source, seven-dependency, product-free executable
whose separate `main` unconditionally exits status 78. That file cannot name
the private V19 decoder edge or private V21 composition members. Compilation
therefore proves the source route and access constraints only; it is not a
runtime composition observation.

No fixture, exporter, projector, decoder, gate, mutation workload, triad, SZ,
model, or evaluation is executed. No runtime input or output, request handling,
sealing, launch, historical-artifact or worker-runtime filesystem/process/
network/environment access, artifact I/O, transport integration, publication,
durability, memory or throughput measure, independent detector, distinct
implementation family, mechanics `PASS`, terminal receipt, source/execution
binding V7, scientific authority, or product authority is observed or
authorized. Prime remains `ABSTAIN`. Source-integrity tests may read the
checked-in repository files they verify; that test access is not worker or
historical-artifact runtime access.

## Next exact prerequisite

`design_the_bounded_unavailable_historical_worker_invocation_seam_for_the_source_bound_v21_composition_before_any_private_access_change_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

That checkpoint must decide the smallest non-public invocation/access boundary
before any source change can make V21 callable from another worker file. It is
design-only: it may not enable transport, request handling, sealing, launch,
execution, artifact I/O, publication, receipt issuance, or source/execution
authority.

## V22 design-only bounded invocation seam

V22 resolves that design question without changing this source. The exact
11,354-byte V21 file remains the only admitted future source path and must be
the byte-exact prefix of any successor. The viable bridge is one internal
wrapper nested in the worker. It stores only this file's private V21 result
behind a private initializer, exposes no declared accessor, declares no
conformance, and
owns one internal static method that calls this file's private V21 call edge
exactly once with unchanged Evidence and context. Errors propagate unchanged.
The private field is API-hidden but is not a confidentiality boundary against
generic reflection or unsafe same-module code; any later consumer therefore
requires a separate leakage and security audit.
The seam preserves V21's two pre-projection `.unavailable` guards exactly:
`.observed_false` remains a distinct observation and `nil` is not representable
or accepted as a substitute. No guard is duplicated, defaulted, inferred, or
normalized.

The method belongs to the nested wrapper so no initializer or V21 member must
be widened. V22 materializes neither wrapper nor method and adds no caller,
`main` edge, package/graph delta, request, transport, execution, I/O, or
publication. The exact status-78 main and `Package.swift` are preserved.
Design/topology hashes are `3954a98474cdaf79a62c65a20cf612f3a1ddaf6b8305aa941e94d3863791e757` and
`af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5`. See [Prime Native Neural Gate Historical Worker
Invocation Seam
Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-DESIGN-2026-08-02.md).

All execution and authority claims remain false; Prime remains `ABSTAIN`. The
next exact prerequisite is:

`source_bind_the_bounded_unavailable_historical_worker_invocation_seam_as_an_append_only_same_file_v21_composition_continuation_preserving_all_v21_private_members_and_delegating_exactly_once_from_one_new_internal_nonpublic_typed_bridge_without_adding_a_main_call_edge_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V23 append-only source-bound seam

V23 makes this complete 11,354-byte V21 source at
`39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d`
the exact prefix of a 13,227-byte file at
`62c0c413e25b95576a023f9b93f67b55a6c38f0cadbdfa4330dba31aea41ae54`.
The sole 1,873-byte suffix at
`64a0db36f309d92dbd8737f9a6401bb7b9adf58b0193dd4c6d3e46d906017811`
adds the V22-designed nested wrapper and a method whose only operation is one
unchanged-argument call to the private V21 edge. All V21 private declarations
and error propagation remain exact.

The internal seam is now nameable across worker-module source, including from
`main`, but the exact status-`78` main and other worker files contain no
reference or caller. The wrapper declares no accessor or conformance; it may
still be inferred `Sendable`, is ordinarily `Copyable`, and is reflectable. It
provides no confidentiality, provenance, receipt, or authority boundary.

Ordinary external imports cannot name the internal seam. A separately compiled
test or privileged module using `@testable import` could name internals when the
worker is built for testing, but no such dependency, import, or caller exists.

Source/topology hashes are `6ae4cd1fadf95f3b18c38d7e4ec2d732f6e0b614399fb76334043bf9851bb656` and
`48f5f1359af1eb3151196ef1e9cb417a6189d8c6461b0c3e595edee39aaee3d9`. No runtime invocation, request, transport, I/O,
publication, receipt, V7, scientific, or product authority is observed; Prime
remains `ABSTAIN`. See [Prime Native Neural Gate Historical Worker Invocation
Seam Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-SOURCE-2026-08-02.md).

The next exact prerequisite is design-only:

`design_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_result_consumer_boundary_for_the_source_bound_v23_internal_bridge_before_any_cross_file_or_main_call_edge_payload_observation_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

## V24 composition-result discard design continuity

V24 materializes design-only PrimeCore governance contracts/tests/topology,
documentation, and provenance reseal at `3c9f34cfae3e50012e40a4b59e38eb5a90bc47e3906a1df5c5111978dac3c902` and
`711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91`; it does not add or compile a worker caller. A
future V25 may preserve this complete V23 file as its exact prefix and append only an
extension of the existing wrapper. That extension has one internal disposition
with exactly the zero-payload cases `compositionCompletedAndDiscarded` and
`failedClosedWithoutDetail` and one synchronous nonthrowing consumer. The
consumer makes one unchanged-argument call to
`Self.sourceBoundUnavailableHistoricalWorkerInvocationSeam(...)`, discards the
result with `_ = try`, and maps every thrown Swift `Error` through one bare,
uninspected catch.

No fifth worker source, second/raw alternate call, direct composition member
access, cross-file or `main` caller, testable import, retention, reflection,
encoding, output, logging, timing, I/O, request, transport, process, execution,
or publication is admitted. Source inventory cannot prevent same-module,
privileged/`@testable`, debugger/injected, dynamic-symbol, `Mirror`, or unsafe
bypass. Zeroization, constant-time behavior, crash confidentiality, and
trap/signal/OOM containment remain nonclaims. The raw seam must be narrowed,
removed, or hardened by isolation before runtime exposure. Prime remains
`ABSTAIN`. See [the V24 design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-CALLER-RESULT-CONSUMER-DESIGN-2026-08-02.md).

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

## V27 private-access source binding — 2026-08-02

V27 realizes the V26 design with the sole checked-in worker mutation:
internal to private at current bytes 12_555..<12_562. The live source is
14,174 bytes / 767cc0101c52a311d40acc1dbba1747b7e3cdf7430f73d69a168ab62d1290e15;
reverse reconstruction restores the exact V25 source.

The V27 source contract is 92f6abf8417d7845d5425b973f7a45d13297bc5af736bd1a9248bc39fdc191ce
and topology V27 is a572b5813e0410235f387222f6399c2984fcb52da69f4bd9393a5adf6869cd7c.
The worker remains four Swift files, main remains status 78, the internal V25
nonpayload boundary remains the sole checked-in raw-seam caller, and no caller,
request, transport, launch, execution, artifact I/O, publication, mechanics
PASS, source-binding V7, scientific authority, or product authority is added.

Private narrows ordinary cross-file and testable direct naming only. It does
not establish authentication, confidentiality, zeroization, constant-time or
constant-resource behavior, or crash, trap, signal, out-of-memory, timing, or
resource containment. Prime remains ABSTAIN.

The repository-wide suite did not complete within the bounded 1,800-second
observation and is not counted as passing. Repeated predecessor validation is
separate workflow/performance debt, not a Git-configuration issue or a V27
remediation. The next semantic boundary is design for hardened nonexporting
isolation and an authenticated fixture-only caller/observation policy.
