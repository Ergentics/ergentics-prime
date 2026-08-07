<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime Swift validation evidence contract

Date: 2026-08-02

## Disposition

Prime now has a first-party Swift contract and reconciler for repository-wide
test evidence. It is isolated in `Tests/PrimeValidationWorkflow` so adding the
contract does not change the root package graph or the frozen `swift package
describe` receipt.

This is not the execution driver. It does not launch processes, allocate
scratch roots, acquire a lease, stage bundles, authorize training, or make a
scientific or product claim. Its frozen authority ceiling says exactly that.

## Toolchain truth that determines the contract

The maintained Apple Swift 6.3.3 / Xcode 26.6 toolchain exposes different
evidence for the two test frameworks:

- the current root compiled inventory contains 904 tests: 892 XCTest and 12 Swift
  Testing
- a parallel XCTest run can emit an XCTest xUnit file that proves case names
  and failures
- that xUnit representation does not reliably encode an actually skipped
  XCTest case; a skipped case can look identical to a pass
- Swift Testing emits a separate xUnit representation with its own failure,
  error, and skip elements
- XCTest's sequential transcript carries the start, terminal state, aggregate
  counts, and exact skip reason that the xUnit file omits

The contract therefore never treats parallel XCTest xUnit as skip authority.
It requires an independent sequential XCTest transcript over the same
inventory and accepts a skip only from that transcript.

## Bound evidence

A plan is fixed before execution and binds:

- a run identifier
- the canonical compiled-inventory identity
- source snapshot, package lock, test bundle, XCTest-list, and Swift
  Testing-list artifacts
- each lane's executable path and content identity, arguments, environment,
  working directory, and test-bundle identity
- the exact optional-skip policy identity
- the frozen no-executor authority ceiling

Evidence carries all artifact receipts, the raw list/XML/transcript material
that affects test semantics, and separate process evidence for parallel
XCTest, sequential XCTest, and Swift Testing. Each lane record joins its run
ID and planned invocation to its result, stdout, stderr, containment, reap,
drain, termination, and matched-count evidence. Workflow phase durations are
recorded separately.

The reconciler reparses the raw bytes. It does not trust a decoded object that
claims different pass/fail semantics while retaining an old content hash. The
raw material must bind back to the evidence receipt, the planned input
artifacts, and the planned inventory identity.

## Outcome semantics

Only three outcomes exist:

- `complete_pass`: every inventory member has a terminal result; all three
  process observations are contained, reaped, drained, non-overflowing, and
  count-exact; exits agree with results; there are no failures or required
  skips
- `complete_fail`: all evidence is complete and coherent, but a test failed or
  a required/unknown skip occurred
- `incomplete`: evidence cannot support either complete outcome because a run
  timed out, was signaled, was not reaped/drained, overflowed, matched no
  tests, omitted or added results, used stale or mismatched bindings, or
  disagreed with its exit status

An exit of 1 is a complete failure only when the corresponding complete lane
contains failure evidence. Exit 0 with a failure, or exit 1 without one, is
`incomplete`. Other non-test-runner exits are also `incomplete`.

## Skip policy

Exactly two XCTest ID-and-reason pairs are optional:

1. `PrimeCoreTests.PrimeDurableArtifactsTests/testGeneratedDescriptorPublishesSparseMultiGigabyteSafetensors`
   with `set PRIME_RUN_LARGE_ARTIFACT_TESTS=1`
2. `PrimeCoreTests.PrimeNativeContractMigrationTests/testOptInLivePinnedCompanionTransport`
   with `set PRIME_NATIVE_COMPANION_ROOT for the opt-in live pinned transport test`

Changing either the ID or reason makes the skip a complete gate failure. Swift
Testing has no optional skip. The seven native 3B tests guarded by finalized
dependency pins remain required; their former setup skip is not admitted.

## Parser and mutation boundary

The Swift parsers bound input size, require UTF-8 without NUL, carriage-return,
or terminal-escape framing, reject malformed XCTest transitions, prevent
interleaved or duplicate cases, require exact nonnegative durations, require
one final top-level `All tests` terminal and aggregate after all case
terminals, and validate exact case partitions and counts. XML rejects
DTD/entity input, unknown hierarchy,
duplicate cases, inconsistent declared counts, and oversized input.
Each inventory list is rejected before identifier parsing when it exceeds 16
MiB, any line exceeds 16 KiB, or it contains more than 100,000 test IDs.

Process safety is reconciled globally across all lanes: failed containment or
exact reap outranks unfinished drain, which outranks log overflow, and all
three outrank timeout, signal, or unobserved termination. A lower-priority
outcome in an earlier lane therefore cannot mask a higher-priority defect in a
later lane.

Mutation tests cover exact pass, optional skip, required or reason-mutated
skip, coherent failure, exit/result disagreement, timeout, transcript grammar
and transition defects, final-aggregate spoofing, explicit cross-lane skip
disagreement, lane/run receipt substitution, receipt/raw-byte mismatch,
duration rules, and the nested first-party MLX mirror and lock.

## Historical performance boundary

V20 design validation still takes about 222 seconds because it validates
frozen predecessors before rejecting mutations. Its source is pinned by its
test and then forward-bound through V21-V27. Rewriting that historical chain
for roughly three minutes of aggregate savings is not justified while the
complete Release suite remains inside the 1,800-second acceptance bound. A
future driver should receipt V20 as a slow shard rather than silently rewrite
historical identities.

The corrected Release aggregate completed 891 XCTest cases with exactly the
two admitted skips and zero failures in 750.455 seconds; the independent Swift
Testing lane completed 12 cases with zero failures in 0.010 seconds. The older
30-minute noncompletion remains historical Debug evidence, not current Release
truth and not a Git-configuration issue.

## Next implementation boundary

The next slice may implement the Swift execution driver against this contract:

1. one exclusive workflow lease
2. planned, build, staging, and execution phases with separate bounded clocks
3. distinct scratch roots for root, optimizer, and neural-MLX packages
4. bounded file-backed stdout/stderr capture and exact process-group reap
5. inventory-first shard construction and all three evidence lanes
6. durable plan, evidence, and outcome receipts
7. resumable phase evidence without treating an unfinished phase as passing

That driver must remain Swift-first. It must prove the existing 904-test root
acceptance target and preserve the root package-description canary before it
is allowed to govern optimizer or neural training gates.

The 904 value is inventory cardinality and one root acceptance execution, not
the paired V2 terminal count. Each reference/candidate arm requires 892 XCTest
terminals in the parallel lane, the same 892 in the sequential skip-authority
lane, and 12 Swift Testing terminals: 1,796 per arm and 3,592 across both arms.
No 904-case receipt may be relabeled as complete paired Driver V2 evidence.

## V2 foundation update

The additive V2 schema, deterministic shard and invocation planner, exact
phase-ledger and conservative resume contracts, caller-value semantic
comparison mechanics, shared secure-child mechanics kernel, deterministic
closed fixture, and Swift-only live fixture integration now exist. Public
complete shard, aggregate, comparison, and final-receipt admission remains
closed until raw runner output is parser-derived. The accepted root inventory
is replaced by 892 XCTest plus the unchanged 12 Swift Testing cases because the
later secure-child scope retained one new required root fail-stop regression
identifier. The prior 891/12 aggregate remains historical evidence and is not
rewritten.

The dedicated root Driver V2 binary now closes only exact supervisor-image
identity through a non-restorable live bridge. This update still does not
implement the root-suite executor, parse child output into V2 shard receipts,
publish a durable complete run, or change the frozen planner authority ceiling.
The exact implemented line and next boundary are recorded in
`PRIME-SWIFT-VALIDATION-SUPERVISOR-IMAGE-2026-08-03.md`.
