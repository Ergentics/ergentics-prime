<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime Swift validation guarded source boundary

Date: 2026-08-03

## Disposition

Prime now helps as a live source-integrity holder. It still does not supervise
a process, run SwiftPM, stage artifacts, list tests, execute a shard, or mint a
Driver V2 receipt.

The admitted one-shot prerequisite can be consumed exactly once into a
non-Codable guarded pre-executor. This transition closes only:

1. descriptor-backed closure of the complete admitted Prime source snapshot;
   and
2. its continuous prepared-state vnode watch window.

The capability ceiling is `source_guards_prepared_only`. The current process's
loaded main image is retained and revalidated, but remains a prerequisite
observation rather than Driver V2 supervisor authority.

## Live mechanics

The transition order is fail-closed:

1. revalidate the lease, canonical roots, empty workspace/evidence roots,
   complete source snapshot, package lock, and static toolchain;
2. duplicate the held Prime root descriptor and arm the maintained descriptor
   and kqueue source watch;
3. retain the current process's main-image descriptor after joining it to the
   loaded Mach-O vnode and exact bytes;
4. repeat the full admitted-input, source-watch, and image checkpoints; and
5. return the guarded capability only if every check remains equal.

The source wrapper reuses the existing maintained implementation instead of
forking descriptor traversal, directory inventories, kqueue receipts, or
mutation checks. Its new prepared checkpoint is repeatable and does not consume
the later child-resume/reap transition.

Sequential or concurrent retry loses permanently once preparation begins. A
failed guard checkpoint changes live state to `poisoned`; the ceiling becomes
`poisoned_no_authority`, source/image positive properties become false, and all
eleven authorities are again reported missing.

## Authority boundary

While prepared, nine authorities remain missing:

1. exact Driver V2 supervisor executable image;
2. Prime Git HEAD and clean-tree process observation;
3. companion Git HEAD and clean-tree process observation;
4. Swift version process observation;
5. Swift target-info process observation;
6. SwiftPM build execution;
7. XCTest inventory execution;
8. Swift Testing inventory execution; and
9. artifact staging.

The retained current-process image does not close item 1. Under the current
XCTest environment, the mapped main image is Apple's root-owned `xctest`, not
the future Driver V2 binary. Its non-writable mode plus descriptor, vnode,
path, metadata, and exact-byte revalidation establish the local integrity
observation; those checks do not establish the Driver V2 semantic role.
Production capture remains current-user-owned; root-owner admission exists
only in an internal test seam. The later dedicated Driver slice now proves
exact path/content equality against a caller-supplied precursor declaration
and the compiled source pin through a live, non-restorable DriverCore bridge.
That additive declaration is not yet a complete `PrimeValidationRunIntentV2`;
any future full intent must match its `driverExecutable` exactly.

Process, build, inventory, staging, and shard-completion states remain
`unobserved`. Completion, resume, CI, optimizer, neural, scientific, training,
and product authority remain absent. No shell, Python, Foundation `Process`,
spawn, fork, exec, generic argv, generic environment, or directory-creation
surface was added.

## Evaluation

The focused Debug live suite covers:

- one-winner sequential and concurrent consumption;
- one-winner guarded transition and permanent retry rejection;
- empty-root enforcement before preparation;
- exact source/image revalidation while prepared;
- post-guard source mutation and permanent poison;
- dynamic restoration of all missing authorities after poison;
- explicit test-only handling of the root-owned XCTest host image; and
- source-level rejection of Codable, public initialization, generic command,
  environment, staging, and child-launch surfaces.

The public Release arm additionally prepares and revalidates the source guard
against the actual embedded Prime source identity. These focused results are
not a 892/12 inventory receipt or a 904-test execution.

## Next boundary

The dedicated root Driver V2 supervisor-image bridge and the neutral
secure-child supervision substrate are now implemented as separate closed
boundaries. The supervisor token closes only exact image identity and launches
no child.

Before any process observation, the next slice must:

1. make one source-watch window gapless across every pre-build probe and the
   later build plus both list children; and
2. define canonical tracked-tree manifests for the Prime and companion SHA
   fields and bind them to descriptor-held bytes.

Only then may fixed Git/Swift probes run. Staging plus build/artifact binding
is the following group; both inventories are the group after that. Shards,
the paired execution spend, semantic completion, and durable resume remain
later.
