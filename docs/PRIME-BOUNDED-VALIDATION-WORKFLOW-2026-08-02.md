<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime bounded validation workflow

Date: 2026-08-02

## Disposition

The earlier repository-wide Debug suite did not complete during its bounded
1,800-second observation. It is not counted as passing. Git configuration was
not causal.

The measured defect is repeated historical predecessor validation in
`PrimeNativeNeuralGateTrapDisjointTopologyContract.validate()`. V17, V18, and
V19 used broad `schemaVersion >= introduction` branches, so every later valid
topology replayed those source validators. V19 and V20 also called
`contentSHA256()` after explicit validation even though that API validates the
same dependency again.

## Performance-only correction

This slice makes topology V17 through V20 follow the introduction-only rule
already used by V12 through V16 and V21 through V27:

1. the introduction version validates the frozen bound contract once
2. its SHA-256 is computed directly from canonical bytes after validation
3. later versions verify the retained literal ID and digest against the live
   canonical encoding without recursively replaying the predecessor validator
4. versions before introduction require the binding to remain absent

The V19 topology factory also uses its already-frozen source digest rather
than a trapping `try!` validation/hash path.

No frozen stored field, coding key, contract ID, canonical JSON byte, topology
graph, package edge, runtime state, authority, disposition, or public
`contentSHA256()` behavior changes. Prime remains ABSTAIN.

## Complete-suite recovery finding

The first bounded Release aggregate scheduled all 891 XCTest cases and ran all
12 Swift Testing cases, but it did not pass. The Release-only secure-child
canary was initially blocked because the outer Codex sandbox cannot create the
canary's own SwiftPM sandbox. An isolated run outside that outer sandbox then
completed both frozen child roles and exposed a stale expected `swift package
describe` receipt.

The old 51,757-byte receipt was last resealed at V11. The package description
then acquired reviewed target, dependency, and test-edge changes through V19,
while source-inventory additions continued through V27. Two independent live
Release observations produced the same current 62,855-byte output and SHA-256
`29c85c6fc6362f7ed035cfc4c9a02714e2841072f26e4f5ef5f47fcd3aee6f8e`.
The canary reconciliation reseals only that test expectation. It does not
change the manifest, package graph, child arguments, child environment,
sandbox policy, or capture authority. The failed aggregate remains failed;
only a subsequent complete run can satisfy the acceptance gate.

## Final acceptance receipt

The subsequent Release aggregate completed under the 1,800-second bound with
process exit zero:

- compiled root-package inventory: 903 tests
- XCTest execution: 891/891 reported
- Swift Testing execution: 12/12 passed in two suites
- required Release secure-child canary: passed in the aggregate and in three
  focused confirmation runs
- required V9-V12 cross-repository donor gates: passed against clean companion
  commit `163fc100710ece48119bc25954452d10f6a84f7f`
- focused topology, V27, secure-child, and live-provenance gate: 31/31 passed
- fresh-scratch `PrimeNativeNeuralGateHistoricalFixtureWorker` Release build:
  passed from the exact resolved dependency revisions

The aggregate ran outside only the outer Codex sandbox so that the canary
could create its own frozen SwiftPM sandbox. The canary's child sandbox,
arguments, environment, descriptor checks, process containment, and receipt
validation remained enabled. The multi-gigabyte artifact and live companion
transport tests remain separately opt-in; they are not reclassified as
required passes by this receipt.

## Measured evidence

All measurements use the same M5 Max checkout and pinned dependency graph.

| Gate | Before | After localized correction |
| --- | ---: | ---: |
| V20 topology suite | 123.24 s | 67.70 s |
| V21 topology suite | 97.91 s | 43.34 s |
| V17-V21 topology matrix | not measured as one baseline | 47/47 in 167.87 s Debug |
| V20 design suite | 224.27 s | 221.82 s |

The unchanged V20 design timing is important: this correction removes the
topology replay defect but does not pretend to repair the V20 design
mutation-path ordering. Release optimization and bounded parallel execution
are separate workflow levers, not semantic proof.

## Fail-closed workflow requirements

The isolated Swift evidence contract in
`Tests/PrimeValidationWorkflow` now encodes the result semantics below. The
cross-package process driver remains a later boundary and must not trust
process exit status alone.
The current SwiftPM/XCTest stack can exit zero when a filter matches no tests,
and a skipped required test can still leave an overall passing suite label.
The driver therefore must:

- acquire one exclusive workflow lease
- use separate scratch roots for the root, optimizer, and neural-MLX packages
- inventory compiled tests before execution
- bind the inventory, package locks, and test bundle identities
- record lease, planning, build, staging, and execution durations separately
- use an allowlisted child environment and bounded file-backed logs
- reject zero tests, required skips, timeout, signal, log overflow, missing or
  stale receipts, unfinished shards, and nonzero exit
- represent outcomes as complete pass, complete fail, or incomplete with a
  typed reason

CI remains out of scope until that local Swift driver is proven. No Git setting
is changed by this slice.

## Acceptance gates

Publication requires focused canonical, mutation, source-shape, topology, and
provenance gates; a fresh Release build; and one complete root-package suite
under the same 1,800-second wall bound. The execution receipt must record the
compiled inventory and actual completed count. An unfinished run, a zero-test
match, a required skip, or process exit without that receipt is not passing.

The remaining cross-package Swift validation driver is a separate boundary.
The plan, strict parsers, raw-byte bindings, three-lane reconciliation, and
mutation tests now exist; lease acquisition, process launch, scratch-root
orchestration, staging, and durable receipt publication do not. See
`PRIME-SWIFT-VALIDATION-EVIDENCE-CONTRACT-2026-08-02.md` for that exact line.
