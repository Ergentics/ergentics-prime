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
- process-group-empty proof before the spawn obligation can be discharged.

Abandoning an owned live child kills its dedicated process group and exact PID,
reaps the exact PID, proves the group absent, and terminates the abandoning
supervisor with exit status 70. The retained test executes that path with a
real child and proves both the hard exit and post-reap `ESRCH` state.

`HeldExecutableSnapshot` construction is restricted to its validating factory.
Both mapped-image consumers now pass through that factory, so a contextual
memberwise initializer cannot bypass positive device/inode and canonical-path
validation.

## Validation boundary

The frozen Driver V2 inventory resources remain unchanged. The focused Debug
checkpoint is a root build plus the lifecycle and secure external-capture
suites. Release validation additionally requires the focused suites, live
source-provenance proof, the two-role package-description canary, nested Driver
V2 Debug and Release checks, and the nine-mode Release integration. None of
those checks alone constitutes a fresh execution of the frozen 903-test root
inventory.

The expected final integration line remains:

```text
PASS modes=9 logical_argv0=PASS one_shot=PASS executable_replacement=REJECTED
```

## Remaining authority ceiling

The next scope is Driver V2 evidence completion on top of this neutral
mechanics boundary. Root test execution, inventory reconciliation, completion
and resume receipts, CI, optimizer, neural, scientific, training, and product
authority remain absent until separately implemented and evidenced.
