# Prime native neural-gate historical worker exported-evidence projection/decode composition design

Date: 2026-08-02

## Decision

V20 freezes only the design for one future, unavailable-worker, in-memory
composition operation. The operation accepts exactly two already-formed typed
inputs:

1. V14
   `PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence`; and
2. V16 `PrimeNativeNeuralGateHistoricalProjectionContext`.

The reserved operation is `compose`, the reserved same-file worker method is
`sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge`, and the
reserved result is
`PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult`.
V20 does not implement any of them.

The design contract is
`prime_source_bound_historical_worker_exported_evidence_projection_decode_composition_design_v20`,
with canonical SHA-256 `b1fc91f4026cb1c513be53f9cf6f5d53834489eab215e1343aa6b00f05a51f4c`. The additive design topology is
`prime_stage_b_historical_worker_exported_evidence_projection_decode_composition_design_topology_v20`,
with canonical SHA-256 `b8045480883016fd49e7a63b02437f54835c1e7de6e61a4c2dea7f439a052a57`.

The rights holder is `Ergentics, LLC`, and the license expression is
`LicenseRef-Ergentics-Proprietary`. The only future source path admitted by
this design is
`Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift`.
Its complete V19 content is the required 7,050-byte prefix with SHA-256
`b8a4aaf4d9328df657f8fd62c3425b04ee2a293fb6dc75df19913635ef2f4cca`;
any later continuation must preserve that prefix byte-for-byte.

## Design-only boundary

V20 changes no `Package.swift` declaration, target, product, dependency,
resource, worker source, V16 projector source, V18 decoder source, V19 decoder
call-edge source, runtime source, test fixture, or executable entry point. The
V19 target graph, forbidden-reachability graph, source inventory, and
unconditional status-`78` `main` remain the actual package state.

The contract and topology describe a future source edge only. No evidence or
context is accepted at runtime, no projected or decoded value is produced, and
neither the V16 projector nor V18 decoder is invoked in V20.

## Exact input and context policy

The future operation may accept only the complete already-formed V14 Evidence
value and one complete explicit V16 context value. It may not:

- call the V14 exporter or materialize its fixture;
- reconstruct, normalize, copy field-by-field, partially validate, serialize,
  decode, or hash Evidence;
- make Evidence or context optional;
- default or infer invocation role or either observation state;
- read role or state from a path, environment, process, request, target,
  artifact, or Evidence field; or
- catch a validation failure and retry with a substituted role or state.

Evidence remains role-neutral. The invocation role is explicit caller context,
but V20 does not authenticate that caller choice. A `probe`/`verifier` role
change is a distinct future composition input and namespace, not a fallback or
normalization.

The only V20-admissible values for both
`sourceBytesResolved` and `adaptationProofRecomputed` are `unavailable`.
`observed_false` is not a substitute for unavailable: it is still an
observation requiring evidence outside this design. `observed_true` is also
rejected because descriptor/source resolution and adaptation-proof
recomputation are not performed here.

## Evidence identity and evaluation-leakage boundary

V14 Evidence is deliberately non-`Codable`, role-neutral, path-free,
timing-free, and authority-free. Possession of the type does not prove that
the exporter ran, the fixture was materialized, donor bytes were executed, or
the value has descriptor-rooted or durable origin.

Its synthesized `Equatable` conformance is not a canonical byte identity,
source identity, deduplication key, or provenance proof. In particular,
`+0.0 == -0.0` while V16 preserves `Double.bitPattern`; equal Evidence values
can therefore project to different bytes under a signed-zero mutation. Swift
String equality likewise must not be promoted to emitted UTF-8 identity. The
future operation may not derive an identity from equality, `hashValue`,
reflection, a description, memory layout, or a newly invented encoding.

Evidence contains target-bearing heldout and abstention rows, predictions,
losses, historical outcomes, and triadic labels. The future composition edge
must pass Evidence opaquely into the maintained V16 projector. It may not
inspect, log, select, rank, sort, filter, train on, generate from, recommend
from, or otherwise branch on those fields. Projection or decode success does
not establish independent prompt/target provenance, target independence,
evaluation validity, scientific authority, or product eligibility.

## Reserved non-Codable result

The future result is a non-`Codable`, non-authorizing in-memory pair containing
only:

1. the exact V16 `PrimeNativeNeuralGateHistoricalProjectedArtifactSet`; and
2. the exact V18
   `PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet` decoded from
   that same projected set.

It retains no V14 Evidence value and no V16 context value. Retaining the
projected bytes avoids a later projection rerun or hand reconstruction before
a separately authorized publication design. The pair is not a receipt,
descriptor capture, source binding, publication candidate, durable value, or
admission result.

Construction must fail unless both members have the same invocation role and
the decoded ordered bindings match the projected set across all 22 canonical
typed keys, in exact namespace order, with exact byte counts and SHA-256
values. The result must have no `Equatable` conformance. Tests compare its two
members and their explicit linkage fields directly; those comparisons convey
no identity or authority. The result must not add `Codable`, `Equatable`,
`Hashable`, `Identifiable`,
`CustomStringConvertible`, logging, callback, filesystem, transport,
publication, or execution behavior.

## Future source ownership

The future implementation must be an append-only continuation in the existing
V19 decoder-call-edge source file. It must add both distinct private static
members: `compose` and
`sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge`. The
worker call edge delegates only to `compose`; `compose` alone must:

1. pass the exact V14 Evidence and explicit V16 context to the maintained V16
   projector exactly once;
2. pass that exact projected set to the existing V19 private decoder edge
   exactly once; and
3. construct the reserved typed result only after exact 22-key linkage
   succeeds.

This route must not duplicate the V19 bounded global-first equal-byte zipper,
widen either private edge's access, introduce another parser, or reconstruct a
projected or decoded artifact. Any later live evolution of the V19 file must
record its former and current physical identities transparently; V20 itself
does not alter that file.

## Topology and authority ceiling

V20 binds only this design contract into an additive frozen topology. It
preserves the exact V19 target graph and forbidden-reachability graph. In
particular, it adds no composition target or product and does not make
`ReplayTransport`, request handling, source binding, publication, process
ownership, receipt ownership, MLX, training, evaluation, recommendation, or
model execution newly reachable.

Every runtime and authority claim remains false: no worker request is handled;
no worker is sealed, launched, or executed; no fixture, exporter, projector,
decoder, gate, mutation workload, model, triad, SZ, or four-tier audit runs; no
artifact is read, written, transported, logged, published, or observed as
durable; no independent detection or distinct implementation family is
established; and no mechanics `PASS`, terminal receipt, source/execution
binding V7, scientific authority, or product authority is issued. Prime
admission remains `ABSTAIN`.

## Required mutation proofs

The design validation must fail closed for:

- either context observation state changed from `unavailable` to
  `observed_false` or `observed_true`;
- absent, optional, defaulted, inferred, or swapped context fields;
- any claim that Evidence equality or a digest establishes canonical or source
  identity, including the signed-zero counterexample;
- any Evidence field inspection, target-derived branch, logging, encoding,
  hashing, model, evaluation, or recommendation surface;
- projected/decoded role, typed-key order, byte-count, SHA-256, or exact
  22-key-coverage mismatch in the reserved result;
- `Codable`, publication, durability, receipt, V7, science, or product
  promotion on that result;
- duplicated zipper logic, widened private access, or a second projector or
  decoder implementation;
- any V20 `Package.swift`, target graph, forbidden reachability, worker
  inventory, worker source, runtime, or executable change; and
- any mutation of a V1-through-V19 canonical topology identity.

Unknown canonical design/topology fields and every false-to-true execution or
authority mutation must also be rejected.

## Truthful nonclaims

V20 establishes a reviewed composition design and canonical design/topology
identities only. It does not establish a runtime composition value, canonical
Evidence instance identity, source or capture epoch, authenticated role,
bounded untrusted-input admission, zero-copy or peak-memory behavior,
evaluation leakage detection, artifact publication feasibility, execution,
or model behavior.

## Next exact prerequisite

`source_bind_the_unavailable_historical_worker_exported_evidence_projection_decode_composition_call_edge_as_an_append_only_same_file_v19_decoder_edge_continuation_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_changing_package_topology_or_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`

That successor may source-bind only the append-only same-file private
composition edge and reserved non-Codable result above. Runtime invocation,
transport, request handling, worker enablement, I/O, publication, durability,
receipt issuance, and source/execution authority remain later, separately
audited checkpoints.

## V21 source fulfillment

V21 fulfills this design without revising the frozen V20 contract. The exact
V19 file is preserved as a 7,050-byte prefix; a 4,304-byte suffix adds the
private typed error, `Sendable`-only two-field result, `compose`, and
delegate-only worker call edge. The complete live file is 11,354 bytes with
SHA-256
`39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d`.

The source enforces the design order directly: unavailable-only context guard,
one unchanged V14 Evidence/V16 context call into the maintained projector, one
same-file private V19 decoder call, then context/projected/decoded role equality
and exact keyed 22-item maintained-order/specification/byte-count/SHA linkage.
The new V21 layer contains no direct Evidence field access, equality-derived
identity, positional join, catch, retry, optional try, parser, zipper
duplication, I/O, or transport surface. It adds no dedicated authority field
or accessor and cannot promote the fail-closed authority metadata transitively
retained on the maintained sets. It delegates unchanged Evidence to the
maintained V16 projector, whose already-bound projection behavior is not
denied or duplicated by this narrower claim.

The V21 source contract and topology have canonical SHA-256 values
`843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494`
and `6d9e2787b54b6ab20f449497e6ac2b91c9945567211badfd4383f37b417f14a4`.
The separate status-78 main cannot name the private members; compilation is
not execution or publication. See [Prime Native Neural Gate Historical Worker
Exported-Evidence Projection/Decode Composition Call-Edge
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORTED-EVIDENCE-PROJECTION-DECODE-COMPOSITION-CALL-EDGE-SOURCE-2026-08-02.md).

Prime remains `ABSTAIN`. The next exact prerequisite is design-only:

`design_the_bounded_unavailable_historical_worker_invocation_seam_for_the_source_bound_v21_composition_before_any_private_access_change_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7`
