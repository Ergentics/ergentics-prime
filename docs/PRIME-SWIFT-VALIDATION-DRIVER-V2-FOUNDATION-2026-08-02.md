<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime Swift validation driver V2 foundation

Date: 2026-08-02

## Disposition

This slice adds the next bounded foundation for recovering repository-wide
validation without treating an unfinished long run as passing. It does not
implement or authorize the root-suite execution driver.

The implemented authority is limited to:

- a frozen V2 run-intent, build/inventory receipt, execution-plan, shard,
  phase-ledger, aggregation, comparison, and final-receipt schema;
- deterministic inventory-first shard planning and exact framework-specific
  filter construction;
- conservative never-started/incomplete resume decisions plus internal
  mechanics over exact phase and shard receipt chains;
- a paired semantic comparator over caller-supplied reference and candidate
  values, without authority to mint an execution outcome;
- a reusable PrimeCore secure-child mechanics kernel exposed publicly only
  through an exact first-party validation-fixture capability; and
- a Swift-only live integration executable for that closed fixture surface.

Process supervision, build or inventory execution, durable resume execution,
CI authority, optimizer or neural authority, and scientific, training, or
product authority remain explicitly false in the V2 authority ceiling. No new
repository-wide pass is claimed.

## Why this is workflow work, not Git configuration

The historical 1,800-second noncompletion was not caused by Git configuration.
The accepted Release evidence later completed 891 XCTest cases and 12 Swift
Testing cases, while the earlier Debug path exposed repeated historical
validation and stale package-description work. The remaining durability gap
is execution orchestration: inventory-first planning, bounded shards, exact
observed-set reconciliation, resumable immutable receipts, and truthful
incomplete outcomes.

V2 preserves the accepted 891/12 inventory anchors. New secure-child assertions
are folded into existing root test cases rather than creating new root test
identifiers. Live process behavior is exercised by the nested integration
executable, so the planned root inventory is not silently made stale by the
workflow implementation itself.

## V2 planning and receipt truth

The V2 run intent binds the source snapshot, package lock, driver and Swift
executables, companion commit, required MLX metallib, exact accepted inventory,
phase budgets, optional-skip policy, and disjoint private workspace roots. Its
13-entry intent environment overlay binds private HOME/CFFIXED_USER_HOME,
TMPDIR, compiler and SwiftPM module caches, deterministic time settings, the
exact companion root, the planned pinned-metallib path, and all four required
historical source gates. The admission launch separately derives a 13-entry
toolchain/workspace execution base and merges it with the overlay by exact
duplicate equality to form a sorted 19-entry replacement environment.

Planning uses the maintained SwiftPM command surface. Inventory uses terminal
`swift test ... list` commands for XCTest and Swift Testing separately. XCTest
and Swift Testing filters retain the different Swift 6.3.3 regular-expression
forms observed from live list/run probes; exact observed test sets remain the
authority, so a zero-match or over-match cannot become a pass.

The plan assigns the complete reference inventory to the three evidence lanes.
It assigns the candidate inventory to deterministic sorted-suite contiguous
next-fit shards, with at most 32 tests and 16 KiB of filter text per shard. The
known slow V20 suite remains dedicated. Parallel and sequential XCTest use the
same shard partition, and sequential XCTest remains skip authority.

The future-completion receipt kernel binds raw wait status, exact returned PID,
session and process group, signal attempts, process-group membership and final
emptiness, bounded stdout/stderr audits, result/stream path separation,
semantic result sets, phase budgets, and exact shard identities. A phase
ledger requires a contiguous prefix whose predecessor hash is the actual
preceding terminal receipt; gaps, reordering, substitution, or continuation
after failure or incompleteness are rejected. Bundle-tree receipts reject
missing parents and file-as-directory topology, and private workspace roots
reject both ancestor/descendant overlap and duplicate claimed device/inode
identities.

Those mechanics are not yet public completion authority. Public validation of
a complete shard, arm aggregate, paired receipt, or final receipt fails with an
authority violation until a later executor derives semantic results by
reparsing the bound raw xUnit or sequential-transcript bytes. Public resume can
start work that is provably absent; it cannot reuse a claimed completed phase
or shard in this slice. This prevents a caller-constructed semantic array or
orphan terminal hash from synthesizing a pass.

## Secure-child fixture boundary

PrimeCore reuses the existing Darwin suspended-spawn, mapped-executable join,
session/process-group containment, exact wait, and cleanup mechanics. The new
public facade cannot accept an arbitrary command, argument, environment,
timeout, result name, or stream cap. It accepts only eight closed fixture
modes:

1. pass;
2. nonzero exit;
3. bounded stdout/stderr;
4. stream overflow;
5. wall-clock hang;
6. self-signal;
7. a descendant retaining inherited streams; and
8. exit without a result.

The first-party arm64 Release fixture is linked with the maintained linker
`-S` option to remove timestamp-bearing debug symbols. Two builds at disjoint
absolute paths and a forced recompilation were byte-identical. The launchable
binary retains the content-derived Mach-O UUID
`E84D1551-8A67-339F-846C-4A0EA37ABAFB`, is 88,976 bytes, and has SHA-256
`470a32c4387b838e6f4a6540c2729cec03963767ad7d418912121b4d01e5267e`.
Removing `LC_UUID` produced a byte-stable, codesign-valid binary that dyld
rejected on macOS 26.5; that option and its earlier hash were rejected before
publication. The exact fixture pin therefore binds reproducibility and actual
launch behavior, not hashing theater.

The kernel retains descriptors for the executable, private roots, capture
files, and result. It verifies descriptor/path joins, file identities, modes,
sizes, hashes, namespace ledgers, APFS locality, mapped executable identity,
EOF, exact wait/reap, and empty process group. Files and namespace transitions
are synchronized. Same-name executable, capture, and result replacement
mutations fail closed. The one-shot capability is enforced under both
sequential reuse and a barriered two-caller race.

## Focused evidence

The V2 DriverCore focused suite covers the public planning and conservative
receipt-admission paths plus an internal generated production-cardinality
kernel with 891 XCTest and 12 Swift Testing identities through aggregation,
paired comparison, and final disposition. The exact captured 114,060-byte
XCTest list and 1,287-byte Swift Testing list are package test resources; a
public-path test admits them through run intent, build receipt, inventory
receipt, execution-plan construction, validation, and identity. Partition,
receipt, semantic-result, phase-chain, tree, path-overlap, alias, and artifact
name mutations are rejected. The internal completion helper does not weaken
the public path: public inventory and execution-plan validation require the
exact frozen list byte counts and SHA-256 anchors, while public completion
validation remains closed.

The separate Release integration passes all eight fixture modes, sequential
and concurrent one-shot enforcement, bounded and overflowing stream capture,
wall-clock and retained-stream cleanup, exact descendant membership, missing
result behavior, and exact pre-spawn executable replacement rejection.

The foundation slice's recorded focused DriverCore run completed 33 tests with
zero failures. The current build-backed inventory replay remained
byte-identical to the frozen resources: 891 lines and 114,060 bytes for
XCTest, plus 12 lines and 1,287 bytes for Swift Testing. The focused root
lifecycle and capture run completed 20 tests with zero failures and one
expected Debug-only skip of the separate Release canary.

The actual Release-only two-role package-description capture then passed twice
against the resealed 62,895-byte output with SHA-256
`04ff83a02c32bb900b0735b63aa724bd334b6dc3116f29dc572a3f48d1e9e3af`.

These focused results do not constitute a current 891/12 repository-wide
execution receipt. The full suite was intentionally not rerun in this slice.

## Longer executor arc

The longer arc may add closed Swift execution capabilities for the already
planned SwiftPM invocations. It must:

1. acquire one exclusive workflow lease and materialize the frozen intent;
2. bind the resolved Xcode developer directory, Swift toolchain/version, SDK,
   and launcher behavior rather than treating `/usr/bin/swift` alone as the
   compiler identity;
3. create and verify canonical, descriptor-joined, disjoint private roots,
   including per-arm or per-shard mutable state isolation;
4. execute the build through the shared secure-child mechanics;
5. bind the clean companion tree, authenticate the build-generated metallib
   and immutable test bundle, and publish the exact build receipt;
6. execute the two inventory commands through the same mechanics, then parse
   and bind their actual output while reverifying every phase-available source,
   lock, metallib, bundle, and companion identity before and after use;
7. refuse to create an execution plan unless the accepted 891/12 list anchors
   match exactly;
8. execute reference and candidate shards within per-child and aggregate phase
   budgets, enforce the declared concurrency maximum, and publish immutable
   start and terminal receipts;
9. derive semantic results only from reparsed raw xUnit/transcript artifacts;
10. validate the complete phase ledger and paired comparison before publishing
   a final receipt; and
11. publish through the separately bound evidence root and preserve incomplete
   or failed state durably so a later invocation can run
   only work that was provably never started.

Only after that executor and its mutation gates pass should Prime spend another
repository-wide run. No generic EnginePropose/Derive/Dispose runtime currently
exists in this repository. A future typed Prime critic may propose cases and
dispose unsupported conclusions, but it cannot certify its own output or turn
missing execution evidence into a pass.

## Admission-only follow-on

The next slice has now been narrowed and implemented as a non-executing
admission boundary. DriverCore can bind the exact policy, static toolchain,
supervisor, repository, staging declarations, and logical-to-physical
pre-shard launch plan—including the physical image, `argv[0]`, arguments,
19-entry replacement environment, and repository-root cwd path—while keeping
every execution observation `unobserved`. PrimeCore can retain real root
descriptors, a complete source-value snapshot, the exact `Package.resolved`
value/hash binding, lease, Xcode/SDK files, the direct `swift-package` image,
and its two personalities in a non-Codable one-shot prerequisite. It does not
yet retain `Package.resolved` or every source file by descriptor, nor arm a
source watch window. It cannot restore that capability from bytes, run a
child, or mint a Driver V2 receipt.

The descriptor-backed source closure/watch window, supervisor image, Git and
Swift process probes, durable artifact staging, build, and the two inventories
remain the immediate closed pre-shard boundary. The exact authority split and
remaining eleven missing authorities are recorded in
`PRIME-SWIFT-VALIDATION-EXECUTOR-ADMISSION-2026-08-02.md`.
