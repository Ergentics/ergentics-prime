<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime Llama quarantine and Python trace

Date: 2026-08-04

## Scope and product boundary

This is a trace of the `ergentics-prime` research repository. It is not a
trace of a released PMHNP application binary. The repository owner states
that the live App Store PMHNP application consumes none of this research
graph; this change did not inspect, build, fetch, or modify the PMHNP
application repository and does not independently attest its binary closure.

PMHNP references preserved in Prime source, tests, documents, or receipts are
historical migration or pending-integration references. They are not evidence
that the live application uses Prime, MLX, MLXLLM, Llama, a Prime tokenizer,
or a Prime checkpoint.

## Third-party Llama trace

Commit `bed8f3182bf05ca3b6189efc981733c64d7c9499` first added the root
`ml-explore/mlx-swift-lm` package dependency and the
`PrimeGPUCalibration` target. Commit
`4507fe629a4f8982712790c79ba4cf2aab221955` added the
`PrimeNative3BMetalContinuationProbe` binding. Those were bounded Prime R&D
probes, not released product dependencies.

The current quarantine removes from the active root SwiftPM graph:

- the `ml-explore/mlx-swift-lm` package dependency and lock pin;
- the transitive `swift-syntax` lock pin brought by that dependency;
- the `PrimeGPUCalibration` product and target; and
- the `PrimeNative3BMetalContinuationProbe` product and target.

The active root and validation lockfiles retain direct first-party
`Ergentics/ergentics-mlx-swift` pins. The typed-optimizer validation package
retains its evidence-bound earlier Ergentics revision
`68904d54b72871f26968261ae05d4fbb7c5e3142`; the other admitted locks retain
`d37885a278f1c37484a94d0f401a418735e66519`. No mirror remapping is active.

Llama-named pure-Swift research contracts, source, tests, documents, and
receipts remain in the repository for historical accounting. Some are within
the root `PrimeCore` compilation surface or historical-fixture targets. That
is a source-context reachability fact, not a third-party package import.
Driver V2 depends on `PrimeCore`, so its build can compile those pure-Swift
contracts; Driver source does not import `MLXLLM`, and its linked-image gate
rejects MLX, MLXNN, MLXLLM, optimizer, and MLX C++ symbols. No claim is made
here that mere absence of those symbols proves a released product boundary.

The historical R&D artifacts and their receipts are intentionally unchanged.
The passing continuation receipt records
`continuationModelImplementation: MLXLLM.LlamaModel`, while also recording
`companionRuntimeDependencyAuthorized: false`,
`productPromotionAuthorized: false`, and `newModelFamilyAuthorized: false`.
That fact is retained as history; it is not current decoder authority and is
not described as critical infrastructure.

## Python process trace

One development-tool invocation during the Stage-B/package-lock period
started Python and evaluated the stdin program `print("skip")`. The process
was unnecessary and is excluded from Prime evidence. The user-supplied tool
transcript is the surviving direct record of the invocation; it was not found
in this checkout, the project attachments searched on 2026-08-04, or shell
history.

The following narrower observations are supported:

- the program text did not request repository reads, writes, network access,
  package resolution, or evidence production;
- no `.py`, `.pyc`, `.pyo`, or `__pycache__` path is present in the current
  Prime checkout as a result of that invocation;
- no `.py` path exists in the current Prime Git tree, reachable commit
  history, or inspected unreachable commit objects;
- `Package.resolved` remained byte-identical, SHA-256
  `da7f7baa10f6da34b01ad69dc116f8a2d31140eca6770cb562ac05a7c50b356c`,
  across the surrounding Stage-B commits `4deada1d`, `7840c6c3`, `f99df8a4`,
  `d5c23f42`, and `50f9e7e3`; and
- no Prime receipt or verdict admits that process as scientific authority.

The stronger historical statement that Python had no possible side effect at
all is not reproducible. Unless started with isolation flags, Python normally
initializes its import environment and may process `site`, `.pth`,
`sitecustomize`, or `usercustomize` hooks. The old process trace does not
preserve enough executable, flag, environment, file-open, or startup telemetry
to prove that none was read or executed. No resulting repository mutation,
cache artifact, network action, or evidence effect was found, but absence of
every transient operating-system effect is not claimed.

Python files observed later in disposable dependency or companion scratch
checkouts are source files copied by those checkouts. Their presence is not
evidence that Python executed, and broad searches over the outer Codex work
directory must not project those files into Prime or the live PMHNP app.

## Swift `print` effects in the quarantined probes

The relevant probe calls are Swift `print`, not Python `print`.

`PrimeGPUCalibration` publishes and round-trip verifies its canonical receipt
before printing a human-readable outcome and receipt digest. Its supervisor
forwards worker stdout/stderr to the parent terminal; no source in the
repository was found that parses those status strings as model or scientific
authority.

`PrimeNative3BMetalContinuationProbe` publishes and verifies its canonical
receipt before printing `PASS`/`ABSTAIN` plus the receipt digest. Child-role
stdout and stderr are bounded and hashed for failure diagnostics. In the
preserved passing receipt, the `control`, `writer`, and `restorer` records each
have `outputByteCount: 0`, `outputOverflowed: false`, and
`outputDrainCompleted: true`. The authoritative observations are the immutable
files and receipt, not the parent console line.

## Preservation and forward rule

Do not rewrite or delete the historical Llama receipts, executables, source
snapshots, fixture evidence, or commits. Current manifests, locks, CI checks,
and future implementation work must treat them only as quarantined historical
R&D context. A future Llama dependency requires a new explicit decision; it
must not re-enter through restoration helpers, stale lockfiles, mirrors,
copied package manifests, or context summaries.
