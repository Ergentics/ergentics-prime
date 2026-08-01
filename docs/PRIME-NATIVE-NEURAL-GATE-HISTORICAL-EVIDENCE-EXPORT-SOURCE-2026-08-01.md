# Prime native neural-gate historical evidence-export source

Date: 2026-08-01

Current continuation: V14 has now satisfied this document's call-edge
prerequisite without enabling or executing the worker. Treat the V13
no-consumer and unchanged-worker-dependency statements below as frozen
historical checkpoint facts, not the current package graph. Continue from
[Prime Native Neural Gate Historical Worker/Export Call-Edge Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORT-CALL-EDGE-SOURCE-2026-08-01.md).

## Decision

V13 materializes the V12-designed historical evidence exporter as one isolated,
package-internal Swift library. It is a source and compilation checkpoint, not
an execution checkpoint.

At the V13 checkpoint, the new target had no product declaration and no
production or executable consumer. The existing historical worker did not
depend on it, and its `main` still exited unavailable with status `78`. Its
source remains exactly 2,298
bytes with SHA-256
`9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df`.
No exporter, worker, gate, fixture, mutation, model, MLX, or Metal workload is
invoked by V13 validation.

## Frozen contracts

- V12 design contract:
  `prime_source_bound_historical_evidence_export_adapter_design_v12`
- V12 design SHA-256:
  `e3305d5ee4054c977a7cb006dc2f1b38c169f5b1e2d905f568cf31166f803e8d`
- V12 topology SHA-256:
  `335e6d54a94305ee2976c9433d0b5570cdd0f67ca8fea0fa00c8dd9f12eaebbe`
- V13 source contract:
  `prime_source_bound_historical_evidence_export_source_v13`
- V13 source-contract SHA-256:
  `ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e`
- V13 topology:
  `prime_stage_b_source_bound_historical_evidence_export_source_topology_v13`
- V13 topology SHA-256:
  `b1564c277a50b8bc2b2ba325809130920dcb123f0d02297efba73e3bb3aec4ea`

The rights holder is `Ergentics, LLC`; the license expression remains
`LicenseRef-Ergentics-Proprietary`.

## Non-circular source derivation

The final exporter is reproducible from two independent checked-in inputs:

1. the unchanged 368,918-byte historical gate at
   `Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/PrimeNeuralNativeLanguageVerifyAbstainGate.swift`,
   SHA-256
   `c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6`;
2. the independently stored 43,273-byte append-only Swift suffix at
   `Sources/PrimeNativeNeuralGateHistoricalSourceDerivation/HistoricalEvidenceExportSource/PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.suffix.swiftpart`,
   SHA-256
   `5eb1481f71b6071b56306e5bc20bd6ed2805cf7cad8441b5e9deb5929f026b67`.

The exact two V12 namespace rewrites produce a 368,953-byte namespace basis,
SHA-256
`c323aab1b3f01c78552ee30e5d50c2c7974a1d846121d887dc5f005f6a89cd31`.
Appending the independent suffix without intervening bytes produces the sole
checked-in exporter source:

`Sources/PrimeNativeNeuralGateHistoricalEvidenceExportMechanics/PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.swift`

Its exact identity is 412,226 bytes, SHA-256
`a20bb86529988f75a46340b9a62924ebda151744a4028ad7726a2d712a385eae`.
Tests derive it twice from the independent inputs and require byte equality
with the checked-in final source. A suffix obtained by slicing the final source
is not accepted as derivation evidence.

## Export boundary

The sole cross-module facade is
`PrimeNativeNeuralGateHistoricalEvidenceExporter.export(_:)`. It accepts only
the historical module's in-memory `Materials` value. The bridge passes all
twelve fields explicitly and performs fieldwise conversion of the nominally
distinct package, checkpoint, and Metal binding types. No field may be
dropped, defaulted, swapped, or reinterpreted.

The returned carrier is deliberately non-`Codable`, role-neutral, path-free,
timing-free, and authority-free. It has the exact nine V12-designed top-level
fields. The public API does not expose a filesystem, process, publication,
receipt, admission, or authority operation.

## Historical stream versus complete regrade

V13 keeps two computations distinct:

- per-mutation stream identities and fingerprints use the historical donor
  mutation sweep's exact invariant-record construction, including its
  `rowHashRegrade: mutation != .executorRowHash` rule, seed-keyed row cache,
  raw-prediction cache invalidation, and baseline finite-field plan;
- complete observed failure sets use a separate full mutated `Materials`
  evaluation over ordered primitive legs NL1 through NL9.

Before constructing the seed-keyed row cache, the exporter requires the exact
frozen three-seed catalog and independent uniqueness. Cache construction uses
explicit checked insertion rather than `Dictionary(uniqueKeysWithValues:)`, so
malformed duplicate-seed material throws a typed error instead of trapping.

The expected failed-leg singleton is compared only after the complete observed
set has been retained. It never stands in for that observation and cannot
widen its own allowed set. The resulting source-derived singleton-regrade
disposition is named separately from the donor's historical outcome and is
explicitly `ABSTAIN` whenever an observed set is not the exact expected
singleton.

The ninth evidence field also retains the timing-free donor values needed for
later typed statistics reconstruction: raw heldout rows, recorded heldout
non-padding token count, initial and final loss, fixed-prompt bit patterns and
margins, split metrics, and exact typed abstention-decision inputs. It does not
export phase durations or latency.

## Package topology

`PrimeNativeNeuralGateHistoricalEvidenceExportMechanics` depends on exactly:

1. `ErgenticsPrimeRuntime`
2. `PrimeNativeNeuralGateReplayMechanics`
3. `PrimeNativeNeuralGateHistoricalReplayMechanics`

Every pre-existing topology target is forbidden from reaching the exporter.
The exporter is forbidden from reaching every target outside that exact
three-target dependency closure. A single test-only dependency compile-checks
the module; no test imports or calls the exporter facade.

The independent suffix is a copied resource of
`PrimeNativeNeuralGateHistoricalSourceDerivation`. It is source material for
deterministic derivation, not an executable plugin or runtime input.

## Swift-only validation

The focused V13 tests must establish:

- exact donor, suffix, namespace, final-source, worker, source-contract, and
  topology identities;
- deterministic two-pass derivation from the independent suffix material;
- fail-closed donor and suffix drift handling;
- the exact public facade, nine-field non-Codable carrier, twelve-field bridge,
  historical mutation-stream construction, complete regrade separation,
  timing-free statistics, and typed abstention inputs;
- exact package target/resource inventory, no product declaration, no
  production or executable reverse dependency, and unchanged worker source;
- preservation of all V1 through V12 canonical topology identities; and
- rejection of decoded binding or reachability mutation.

The cross-repository donor gate remains mandatory:

```sh
env PRIME_REQUIRE_V9_PINNED_DONOR_GATE=1 \
    PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE=1 \
    PRIME_REQUIRE_V11_HISTORICAL_FIXTURE_SOURCE_GATE=1 \
    PRIME_REQUIRE_V12_HISTORICAL_EVIDENCE_EXPORT_SOURCE_GATE=1 \
    PRIME_PMHNP_COMPANION_ROOT=/path/to/pinned/pmhnp-companion-ergentics \
    swift test
```

This is source, contract, topology, and compilation evidence only.

## Authority ceiling and next prerequisite

V13 does not observe historical evidence, establish an independent detector or
distinct implementation family, perform a four-tier audit, authorize mechanics
`PASS`, issue a terminal receipt or source/execution binding V7, or establish
scientific or product authority. Prime admission remains `ABSTAIN`.

The V13 next exact prerequisite was:

`source_bind_the_historical_worker_evidence_export_call_edge_without_sealing_launching_or_executing_the_worker_or_issuing_source_binding_v7`

V14 now satisfies that prerequisite with one private, cross-file call edge and
one appended worker dependency. The exact V11 primary source and unavailable
exit remain unchanged, so compilation cannot make the private member reachable
from `main`. No request handling, sealing, launch, worker/fixture/exporter/gate
execution, encoding, publication, terminal receipt, source/execution binding
V7, scientific authority, or product authority is observed or authorized.
See [Prime Native Neural Gate Historical Worker/Export Call-Edge Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-EXPORT-CALL-EDGE-SOURCE-2026-08-01.md).
