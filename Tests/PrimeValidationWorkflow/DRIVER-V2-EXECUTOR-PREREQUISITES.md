<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime Validation Driver V2 executor prerequisites

Date: 2026-08-02

The V2 package currently implements contracts, deterministic planning, and
internal reconciliation kernels. It does not authorize process execution,
durable resume, or complete arm/final receipts. Public completion remains
fail-closed until an executor supplies all of the following.

- Time and concurrency authority: monotonic active and wall-clock accounting,
  deadline escalation receipts, and enforced per-arm/global concurrency caps.
- Staging TOCTOU controls: descriptor-relative no-follow traversal, identity
  checks before and after use, private creation modes, atomic publication, and
  durable file and directory synchronization.
- Per-arm isolation: distinct scratch, cache, configuration, security, home,
  temporary, output, and evidence trees with no shared mutable build state.
- Companion admission: the exact pinned commit, a clean tracked and untracked
  tree, and descriptor-bound package/metallib content before each invocation.
- Toolchain admission: the resolved Xcode build, SDK path/version, target
  triple, Swift executable content, and linker/runtime configuration—not only
  an ambient `swift` path.
- Semantic evidence: maintained framework parsers must derive exact per-test
  terminals from the bound xUnit/transcript bytes. Caller-supplied semantic
  arrays are not completion authority.

These are implementation prerequisites, not claims that the current schema
already observes or enforces the corresponding operating-system behavior.
The repository-level disposition and evidence are recorded in
`docs/PRIME-SWIFT-VALIDATION-DRIVER-V2-FOUNDATION-2026-08-02.md`.
