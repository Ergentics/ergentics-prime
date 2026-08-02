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
