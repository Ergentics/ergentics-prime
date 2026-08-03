<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime neutral secure-child supervision

Date: 2026-08-03

## Disposition

Prime now owns one neutral internal supervision substrate above the previously
neutralized Darwin spawn transport. The two existing closed consumers retain
their separate role policies and public result types, but no longer implement
independent lifecycle, deadline, mapped-image, cwd, drain, or containment
mechanics.

This slice does not create a Driver V2 executable, execute the root test
inventory, mint a Driver V2 receipt, authorize CI, or broaden any product,
target, dependency, or public evidence surface.

## Closed supervision boundary

The substrate binds one non-restorable live-child obligation to:

- exact-PID death observation and exact-once reap;
- direct-PID authority until isolated-session and dedicated-process-group
  proof succeeds;
- checked monotonic phase deadlines and a cleanup-only timeline;
- bounded TERM-to-KILL escalation after resume and immediate KILL before
  resume;
- descriptor-rooted suspended-child cwd proof;
- full mapped-region transcript joined to a held executable identity;
- independent memory and file EOF drains; and
- process-group-empty proof before a post-proof spawn obligation can be
  discharged, with exact-PID reap sufficient while the pre-proof child remains
  suspended.

Abandonment is proof-aware. Before isolated-session and dedicated-process-group
proof, the suspended child cannot have executed and emergency containment may
signal only its exact PID. After that proof is recorded, abandonment signals
the dedicated process group and exact PID and proves the group absent after the
exact reap. Both paths terminate the abandoning supervisor with exit status 70.
The retained pre-proof test launches a fresh XCTest role with `posix_spawn`,
abandons an actual suspended substrate handle, and uses bounded parent-side
observation to prove both the hard exit and post-reap `ESRCH` state.

`HeldExecutableSnapshot` construction is restricted to its validating factory.
Both mapped-image consumers now pass through that factory, so a contextual
memberwise initializer cannot bypass positive device/inode and canonical-path
validation.

## Validation boundary

The retained fail-stop test adds one required XCTest identifier, so this scope
explicitly replaces the stale 891-entry Driver V2 resource with the live
892-entry anchor while preserving all 12 Swift Testing identifiers byte for
byte. The focused Debug checkpoint is a root build plus the lifecycle and
secure external-capture suites. Release validation additionally requires the
focused suites, live source-provenance proof, the two-role package-description
canary, nested Driver V2 Debug and Release checks, the nine-mode Release
integration, the isolated Ergentics-MLX numerical lane, and one complete
904-test root aggregate.

The expected final integration line remains:

```text
PASS modes=9 logical_argv0=PASS one_shot=PASS executable_replacement=REJECTED
```

## Remaining authority ceiling

The next scope is Driver V2 evidence completion on top of this neutral
mechanics boundary. Root test execution, inventory reconciliation, completion
and resume receipts, CI, optimizer, neural, scientific, training, and product
authority remain absent until separately implemented and evidenced.
