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
