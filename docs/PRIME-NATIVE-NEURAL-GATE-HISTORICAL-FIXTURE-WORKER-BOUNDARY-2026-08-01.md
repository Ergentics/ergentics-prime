# Prime native neural-gate historical fixture and worker boundary

Date: 2026-08-01

## Decision

Topology V11 advances only the source-fixture and package-target portion of
the composite V10 prerequisite. It does two bounded things:

- the existing pure Swift source-derivation target now accepts the exact
  historical regression-fixture and `Package.resolved` bytes, validates both
  inputs before any line operation, and reproduces the frozen 88,141-byte
  source-faithful fixture; and
- `PrimeNativeNeuralGateHistoricalFixtureWorker` now exists as a
  package-internal executable target whose current `main` is deliberately
  unavailable and exits with status `78`.

This is fixture source binding and executable-target compile evidence. It is
not a sealed historical worker, worker execution, or historical evaluation
result. The previous composite prerequisite is therefore only partially
realized: the fixture and unavailable target now exist, while the
evidence-producing worker remains blocked on an exact source-derived export
of historical records that the V10 public observation seam cannot expose.

## Frozen lineage and fixture derivation

- rights holder: `Ergentics, LLC`
- license: `LicenseRef-Ergentics-Proprietary`
- source repository: `Ergentics/pmhnp-companion-ergentics`
- source revision: `163fc100710ece48119bc25954452d10f6a84f7f`
- source tree: `9009daa4f8a07fbd5897e00b9571cef44ec292db`
- eleven-input catalog SHA-256:
  `e9ac9a697dd24cbe6583c713e96840c810cda1771497a6a69ace1e190963bca4`
- V11 source-contract SHA-256:
  `64f0de29eed04145db6b598f2895bf9ee9d7804b03b35971f1ca77a72f76e9fb`
- topology V11 SHA-256:
  `06ce2af33e574c04ef4a46ca356402457ddd4e045bce6d100fed796c19c909eb`

The two exact fixture inputs are:

| Input | Bytes | SHA-256 |
| --- | ---: | --- |
| `neural-kit/Tests/NeuralKitTests/EngineProposesNativeLanguageVerifyAbstainTests.swift` | 165,692 | `266475d337fb49ba9c84e03a53871269a73812c3200a830a799ef90f4901968c` |
| `neural-kit/Package.resolved` | 1,949 | `cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3` |

Derivation
`exact_lf_forensic_fixture_five_group_four_rewrite_v1` preserves the frozen
five exact LF line groups and four ordered, single-occurrence, hash-bound
rewrites from adaptation proof V2. Its output is exactly 88,141 bytes with
SHA-256
`e04daaf783f0cb79958daea9a70579fc959b47ceea4ae913bcb69cdc458fcf99`.
The package-lock digest is a required second input and is also embedded by the
frozen rewrite.

The checked-in derived fixture is routed into
`PrimeNativeNeuralGateHistoricalReplayMechanics`, beside the byte-exact gate.
That same-module placement is required because the source-faithful fixture
uses internal gate declarations. It changes neither donor access levels nor
the frozen derived bytes. Adaptation proof V2 remains exact history, V3
continues to own gate/carrier routing, and V10's three-file historical source
identity remains historical input rather than being rewritten as V11.

This fixture derivation/input binding is not the separately versioned
source/execution-binding V7, which remains unissued.

## Package and reachability boundary

Topology V11 has contract ID
`prime_stage_b_source_bound_historical_fixture_worker_topology_v11`. Its
overall status remains `planned_not_materialized`,
`executionImplemented == false`, and `sourceBindingV7Issued == false`.
`implemented` on the historical worker node means only that the SwiftPM target
and source now exist. The target's non-authorizing source-boundary identifier
is `prime_source_bound_historical_fixture_worker_v11`.

The worker target has the previously frozen four direct local dependencies:

- `PrimeCore`;
- `ErgenticsPrimeRuntime`;
- `PrimeNativeNeuralGateHistoricalReplayMechanics`; and
- `PrimeNativeNeuralGateReplayTransport`.

The historical process/artifact protocol remains
`PrimeNativeNeuralGateHistoricalWorkerContract.frozenV2`, contract ID
`prime_stage_b_historical_fixture_worker_v2`. V11 source-binds that contract
into the unavailable target but does not satisfy or revise it.

It bundles the exact 1,949-byte `Package.resolved` input under
`HistoricalFixtureEvidence`. No product is explicitly declared for the
target; it adds no PMHNP package/runtime dependency, and no existing
production executable can reach it. Every probe, verifier, corrected worker,
and remaining Stage-B execution role stays absent.

The embedded Prime source identity remains authoritative only in
`PrimeEmbeddedBuildProvenance.swift` so this source-hashed document does not
create a self-reference. Final full-suite counts remain process evidence.

## Deliberately unavailable executable behavior

The target declares the three frozen argument names
`--artifact-root`, `--invocation-role`, and `--request-sha256`, and the two
future roles `probe` and `verifier`. Those are inert declarations, not a
request parser or accepted invocation contract. Every current invocation
exits `78` before fixture materialization or historical observation.

One private unreachable call edge binds the future fixture materializer to the
V10 observation seam for compile-time closure checking. A second private
unreachable edge binds the frozen historical-worker V2 contract. Neither edge
calls `materialize`, `observe`, `load`, or `dispose` at runtime. No test may
invoke either edge in this slice.

The boundary is unavailable because the V10 gate API does not expose the raw
59,497 invariant records, per-mutation fingerprints, or observed failed-leg
sets required by the frozen historical-worker artifact protocol. Summary
projection fields cannot be expanded into those missing records. The derived
fixture also retains donor traps and forced unwraps, so compilation does not
make it a fail-closed in-process evaluator.

## Required validation

The cross-repository source gate is explicit and fail-closed:

```sh
env PRIME_REQUIRE_V9_PINNED_DONOR_GATE=1 PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE=1 PRIME_REQUIRE_V11_HISTORICAL_FIXTURE_SOURCE_GATE=1 PRIME_PMHNP_COMPANION_ROOT=/path/to/pinned/pmhnp-companion-ergentics swift test
```

Required final evidence is:

- deterministic derivation twice from the exact two donor inputs and exact
  equality with the checked-in 88,141-byte fixture;
- rejection of wrong hashes, byte counts, line structure, rewrite
  multiplicity, and package-lock drift;
- exact target/file/resource inventory and forbidden-reachability checks;
- source audits proving that `main` exits unavailable and both reserved call
  edges remain unreachable;
- focused and full Swift test results; and
- a resealed Release two-role actual-package capture.

The Release canary, when recorded, proves only package/source topology on the
pinned host. It cannot prove worker execution. No Python is used by the V11
implementation or validation.

The observed V11 Release two-role actual-package capture passed with
byte-identical probe/verifier output at 51,757 bytes, SHA-256
`7c2f125d1ab4298518365d5b00998f5205e5506c48d4f5a7722e3598133c4b5c`.
The V11 source-contract tests passed 7/7; the donor-required source-derivation
and V10 closure suites each passed 10/10. These are source, package, and
non-execution boundary checks only.

## Authority ceiling

V11 establishes no:

- runtime fixture-object materialization or historical admission evaluation;
- worker image sealing, request handling, launch, process observation, or
  result;
- gate, `load`, `dispose`, model, MLX, or Metal execution;
- invariant, fingerprint, mutation, statistics, or verdict artifact
  publication;
- independent historical mutation detector or distinct implementation
  family;
- durable observation, mechanics `PASS`, terminal receipt, or generic
  `GROUNDED` admission;
- source/execution-binding V7;
- scientific authority; or
- product authority.

Prime admission remains `ABSTAIN`. A donor payload string such as `GROUNDED`
does not alter that disposition.

## V11 next exact prerequisite

`derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7`

V12 resolves only that design/source-contract boundary; the live prerequisite
is recorded in [Prime Native Neural Gate Historical Evidence Export Adapter Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-EXPORT-ADAPTER-DESIGN-2026-08-01.md).

That adapter must be derived and source-bound without editing the byte-exact
gate or hand-porting missing records. Worker request handling, process
supervision, image sealing, execution, durable publication, probe/verifier,
and source/execution-binding V7 remain later boundaries.
