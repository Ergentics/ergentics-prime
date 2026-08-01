# Prime native neural-gate historical evidence semantic-artifact projection design

Date: 2026-08-01

## Decision

V15 source-binds the exact design boundary between the V13 typed historical
evidence carrier and the V2 worker's frozen semantic-artifact inventory. It
does not implement a projection codec, add a package target, change the V14
worker or exporter, or enable the private V14 call edge.

Forward audit found three blockers that make projector implementation unsafe:

1. the V4 non-authorizing namespace reserves only three schema-deferred
   historical keys per role, while the worker requires 22 semantic artifacts
   per role;
2. the carrier preserves three seed-specific statistics families, while the
   frozen semantic statistics record accepts one value from each family; and
3. the existing semantic-record target reaches the corrected mutation surface,
   which the frozen historical-worker closure is forbidden to reach.

Selecting a seed, averaging values, treating array position as seed identity,
inventing artifact paths, or importing the mixed semantic target would lose
evidence or violate isolation. V15 records the exact mappings and blockers and
keeps admission at `ABSTAIN`.

## Frozen identities

- V15 design contract:
  `prime_source_bound_historical_evidence_semantic_artifact_projection_design_v15`
- V15 design-contract SHA-256:
  `2d7da9703cf710f6f795900d91872780297a0e8d18f345cca302711d7fd0ec27`
- V15 topology:
  `prime_stage_b_historical_evidence_semantic_artifact_projection_design_topology_v15`
- V15 topology SHA-256:
  `c4fe0ddd24fc5d614b36ee2698d62cb7cdae745b087c02cc176225a070852eb0`
- preserved V14 call-edge source-contract SHA-256:
  `8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8`
- preserved V14 topology SHA-256:
  `4aee5e011a7db85ed74955684f885b03f306e82b8fd4d0f12422d0b791663564`
- preserved V13 exporter source-contract SHA-256:
  `ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e`
- preserved V8 semantic-record-contract SHA-256:
  `67451098c4c486cd6a2d1701190c7ba3129d48f47956dc5c674295053f47cf9a`
- preserved V4 semantic-namespace SHA-256:
  `60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1`

The rights holder is `Ergentics, LLC`; the license expression remains
`LicenseRef-Ergentics-Proprietary`.

## Exact carrier and artifact-set mapping

The V13 carrier remains non-`Codable`, role-neutral, path-free, timing-free,
and authority-free. V15 binds all nine carrier fields to exact destination
semantic types and worker artifact sets:

1. ordered invariant records map to the global invariant stream and 15
   ordinal invariant chunks;
2. per-record ASCII flags validate the original record bytes but do not create
   an independent artifact;
3. the baseline invariant bundle maps to the invariant manifest, global
   stream, chunks, and fingerprint observation;
4. ordered mutation identities map to the mutation observation;
5. per-mutation stream identities map to the mutation observation;
6. per-mutation fingerprints map to the mutation observation;
7. per-mutation failed-leg sets map to the mutation observation;
8. ten historical critical-leg values map to the gate and statistics
   observations; and
9. the three seed-specific statistics families are explicitly blocked from
   the singular frozen statistics record.

The projection must receive `invocationRole`, `sourceBytesResolved`, and
`adaptationProofRecomputed` as explicit external context. None may be inferred
from the role-neutral carrier. Role prefixes must derive only from the explicit
invocation role.

## Namespace gap: three specifications versus 22 artifacts

For each of `probe` and `verifier`, the V4 namespace currently reserves only:

- `historicalMaterialManifest`;
- `historicalGateObservation`; and
- `historicalMutationObservation`.

All three use `reserved_schema_deferred` encoding and `schema_deferred`
decoding. They are not projection-ready.

The worker requires seven fixed leaves and 15 dynamic invariant chunks per
role:

- `material-identity-manifest.v1.json`;
- `gate-observation.v1.json`;
- `invariant-records-manifest.v1.json`;
- `invariant-records.v1.bin`;
- `fingerprint-observation.v1.json`;
- `mutation-observations.v1.json`;
- `statistics-verdict-observation.v1.json`; and
- `invariant-chunks/{ordinal_8digit}.v1.bin`, exactly 15 times.

The invariant manifest/global/chunks, fingerprint, and statistics paths are
not represented by the three deferred V4 specifications: four fixed paths and
15 chunk paths, 19 artifacts per role, remain absent. V15 therefore does not
invent decoders or close the namespace by assertion.

## Three-seed statistics gap

The carrier retains heldout statistics, fixed-prompt replay values, and
capability values for exact seeds `1618`, `2718`, and `3141`. Their Swift array
order is not authoritative. Any future codec must join and canonicalize by the
seed key, never by position.

The frozen statistics schema has one weighted-statistics value, one
fixed-prompt margin value, and one capability value. No source-pinned,
lossless three-to-one rule exists. First, mean, median, minimum, or maximum
would be an unreviewed reduction. The required repair is an additive keyed
three-seed envelope that preserves every seed-specific value. A separately
derived summary may remain non-authorizing, but it cannot replace the keyed
evidence.

## Exact joins and observation policy

V15 freezes these implementation requirements:

- each ASCII flag must match its raw invariant-record bytes;
- the baseline invariant bundle must be recomputed exactly from the ordered
  records;
- all 46 mutation arrays must join by exact ordinal and identity;
- allowed failed-leg singletons must derive only from the frozen historical
  catalog;
- all ten critical legs must join by exact ordinal and identity; and
- seed arrays must join and canonicalize by exact seed, never positionally.

The carrier cannot promote derivation into observation. Source-byte
resolution, adaptation-proof recomputation, critical-leg evidence bindings,
descriptor verification, durable publication, model execution, independent
detection, distinct-family confirmation, and four-tier audit state remain
`unavailable` unless a later runtime actually observes and binds them.

## Dependency-isolation gap

`PrimeNativeNeuralGateSemanticRecordContracts` directly depends on
`PrimeNativeNeuralGateCorrectedMutationSurfaceContracts`. Frozen historical
worker reachability forbids that surface. V15 therefore does not add the
semantic-record target to the worker or materialize the reserved historical
projection target.

The authorized next slice must expose a historical-only semantic projection
boundary with no corrected-surface reachability. Any topology redesign is a
separate future decision outside V15's prerequisite.

## Package, execution, and authority boundary

The V15 Swift/package implementation delta is limited to `PrimeCore`
design/topology contracts and their static tests; this record and continuation
pointers document that delta. Topology status remains
`planned_not_materialized`, and `executionImplemented` remains false. The V15
target graph and forbidden-reachability rules are byte- and order-identical to
V14. `Package.swift`, worker sources, worker dependencies, exporter source,
fixture resource, and the status-`78` unavailable `main` remain unchanged.

The primary worker remains exactly 2,298 bytes with SHA-256
`9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df`.
The private V14 call edge remains exactly 1,512 bytes with SHA-256
`d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319`.

No projector source or target exists. The worker is not sealed or launched,
and no request is handled. No fixture, exporter, projector, gate, worker,
model, MLX, Metal, mutation, or statistics workload executes. No historical
evidence is observed; no artifact binding is created; no artifact is encoded
or written; and no evidence is published or durably observed. This checkpoint
does not establish independent detection, distinct implementation families,
an AgentContractKit four-tier audit, mechanics `PASS`, a terminal receipt,
source/execution binding V7, scientific authority, or product authority.

## Swift-only validation boundary

V15 validation covers canonical encode/decode and frozen hashes, every V1
through V14 topology identity, exact V14 graph and forbidden-reachability
preservation, all nine field mappings and the complete artifact-set inventory,
the three-versus-22 namespace gap, keyed seed rules, external context and
observation policies, absence of the reserved projector, exact physical worker
and call-edge identities, and fail-closed decoded mutations. Compilation and
static tests do not establish runtime projection or evidence.

The existing donor-gated suite remains mandatory cross-repository process
evidence. V15 adds no donor source or environment marker.

## Next exact prerequisite

`freeze_the_complete_non_authorizing_historical_semantic_artifact_namespace_and_additive_keyed_three_seed_statistics_envelope_then_source_bind_a_historical_only_projection_codec_without_enabling_worker_request_handling_sealing_launch_execution_publication_or_issuing_source_binding_v7`

That next slice must remain separately reviewable. It must not collapse the
three seeds, weaken exact joins, broaden historical reachability, or make the
unavailable worker executable.
