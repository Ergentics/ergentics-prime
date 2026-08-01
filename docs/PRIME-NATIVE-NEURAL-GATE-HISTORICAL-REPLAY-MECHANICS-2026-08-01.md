# Prime native neural-gate historical replay mechanics

Date: 2026-08-01

## Decision

Topology V10 completes the bounded V9 prerequisite by materializing two
internal Swift library targets and no product, executable, worker, or process:

- `ErgenticsPrimeRuntime` contains the seven byte-exact first-party Ergentics
  runtime sources required by the historical gate and has no dependencies;
- `PrimeNativeNeuralGateHistoricalReplayMechanics` contains the byte-exact
  historical native gate, the exact V9-derived verdict carrier, and one
  Prime-authored in-memory observation seam; and
- the historical target depends only on `ErgenticsPrimeRuntime` and the
  existing pure `PrimeNativeNeuralGateReplayMechanics` codec.

At the V10 checkpoint, neither target was reachable from a production product
or executable. The then-planned historical fixture worker was the only future
closure allowed to reach them. PMHNP remains a read-only source oracle and is
not a Prime package or runtime dependency.

This is source-closure and compile evidence only. The seam contains a direct
call edge from `observe(_:)` to the donor `dispose(_:)` for a later isolated
worker, but V10 does not call `observe`, `load`, or `dispose`, evaluate an
artifact, execute a model, or publish an observation.

## Frozen lineage and rights

- rights holder: `Ergentics, LLC`
- license: `LicenseRef-Ergentics-Proprietary`
- companion: `Ergentics/pmhnp-companion-ergentics`
- revision: `163fc100710ece48119bc25954452d10f6a84f7f`
- tree: `9009daa4f8a07fbd5897e00b9571cef44ec292db`
- adaptation proof V3 SHA-256:
  `40db6bae391ef4a74723451307a66cda9b7b834c2262ae05085a5f3db68694c1`
- historical source-material contract SHA-256:
  `884588bbe5c0aad160366f611d096d88e14946f1923b88c78a5a8b3d6a546da8`
- V10 replay-mechanics contract SHA-256:
  `6bd51cb07b0f6bf72eb9cba6dec1fd9686377dab838fd6468497c34d6704debe`
- topology V10 SHA-256:
  `b7990ee20d69660b29d12e0ba9014df2849da5747329c80cbe168644b6a170a5`

The complete transitive compiled closure is 11 Swift files and 1,147,892
bytes:

- seven byte-exact runtime files: 691,319 bytes;
- byte-exact native gate: 368,918 bytes, SHA-256
  `c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6`;
- V9-derived verdict carrier: 2,397 bytes, SHA-256
  `4d9847738c6e3079d8951a3ade21355d6d5be56c193b98a6151b634930e2e51f`;
- Prime-authored observation seam: 25,318 bytes, SHA-256
  `537e51906fe26d1bcd252f0067a89ddf0cf83d1cb2a69c831265b06af546de7b`;
  and
- existing pure replay mechanics: 59,940 bytes, SHA-256
  `8c04e88c1ef9745c12499646e195a5e86e4c426112f324785aba8ad524896ffb`.

The contract recursively inventories each target directory and rejects a
missing, changed, nested extra, nonregular, or symlinked Swift source. The
required cross-repository gate verifies the live donor `HEAD`, tree, per-file
Git blob OIDs, bytes, and SHA-256 values, then derives the carrier twice and
requires exact equality with the checked-in carrier.

## Observation semantics

The public future-worker entry accepts only
`PrimeNeuralNativeLanguageVerifyAbstainGate.Materials`. It accepts no URL,
path, expected hash, expected verdict, mutation ID, failed-leg set, or runtime
manifest value. The V10 tests use only the internal synthetic projection seam;
they do not invoke the historical admission evaluator.

The projection validates the donor's public assessment surface without
inventing access to its private evaluation records:

- all ten critical-leg IDs, order, counts, and count-derived triadic label are
  recomputed;
- the exact nine NL1 material-reload component names are required and NL1 is
  bound to all nine values;
- NL2 passing requires the exact 59,497-record, three-point finite-field
  fingerprint surface;
- NL1 through NL9 determine whether a mutation sweep may exist;
- the exact ordered 46-mutation catalog, expected named leg, four result
  booleans, sweep outcome, and historical triadic label are cross-validated;
- NL10 is bound to a complete historically `GROUNDED` sweep; and
- nondeterministic wall-clock phase telemetry is excluded from canonical
  observation identity.

The invariant records, per-mutation fingerprints, and observed failed-leg
sets are explicitly `not_exposed_by_pinned_gate_public_api`; phase telemetry is
`not_observed_by_observation_seam`. The 15,578-byte synthetic canonical
known-good observation has SHA-256
`a89e60bc8c0bb24f366e815f73fd9916c7becfc9d5db67105b97251b3e2d153a`.
That is a projection KAT, not historical artifact evidence.

Historical payload may retain the donor string `GROUNDED`, but Prime admission
is always `ABSTAIN`. Candidate payload authority, compiled-source observation,
gate/model execution binding, durable publication, independent detection,
distinct implementation families, AgentContractKit four-tier audit, mechanics
`PASS`, terminal receipt, source/execution-binding V7, scientific authority,
and product authority all remain false.

The exact donor closure intentionally retains historical filesystem-capable
and trap-bearing APIs. Compilation and synthetic projection do not make those
APIs safe to run in the package test process. Historical admission execution
must wait for the separately source-bound fixture and sealed fresh-process
worker.

## Required validation

The V10 donor gate is explicit and fail-closed:

```sh
env PRIME_REQUIRE_V9_PINNED_DONOR_GATE=1 PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE=1 PRIME_PMHNP_COMPANION_ROOT=/path/to/pinned/pmhnp-companion-ergentics swift test
```

`PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE=1` with a missing root, an
unknown marker value, wrong revision/tree, wrong blob, or changed donor byte
fails rather than skips. No Python is used by implementation or validation.

The live Release two-role actual-package secure-capture canary produced equal
probe/verifier output at 49,923 bytes, SHA-256
`c7032eb16cde10e40b55cbb605e92f3169a6cfe3feddd038c4c58f3179f9d551`.
That captures the actual package/source topology only. It is not historical
gate execution, worker evidence, or source/execution-binding V7.

## V10 next prerequisite and V11 boundary

The V10 next exact prerequisite was:

`derive_and_source_bind_source_faithful_historical_fixture_then_materialize_only_the_sealed_historical_worker_without_materializing_probe_verifier_or_issuing_source_binding_v7`

V11 preserves the V10 closure, source-binds the exact fixture, and adds only a
package-internal executable target whose `main` exits unavailable with status
`78`. The fixture-to-observation call edge is private and unreachable. No
sealed image, request handling, worker execution, historical evaluation,
supervisor probe/verifier, or source/execution-binding V7 is created.

The V11 next exact prerequisite was:

`derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7`

V12 resolves only that design/source-contract boundary; the live prerequisite
is recorded in [Prime Native Neural Gate Historical Evidence Export Adapter Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-EXPORT-ADAPTER-DESIGN-2026-08-01.md).

The later materialization must source-derive the missing raw-record export
without modifying the byte-exact gate or reinterpreting the donor's
same-family mutation dispatch as independent detection. See
[Prime Native Neural Gate Historical Fixture and Worker Boundary](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-FIXTURE-WORKER-BOUNDARY-2026-08-01.md).
