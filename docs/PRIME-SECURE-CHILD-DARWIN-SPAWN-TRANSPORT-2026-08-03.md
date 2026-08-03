<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime secure-child Darwin spawn transport

Date: 2026-08-03

## Disposition

Prime now owns one neutral internal Darwin transport for the two existing
closed child capabilities. The neural package-description capture and the
validation fixture kernel no longer own separate or neural-named spawn and
pipe mechanics.

This is a transport-only extraction. It does not implement the complete
Driver V2 secure-child substrate, run Git or SwiftPM, close a missing
authority, or authorize repository validation.

## Implemented boundary

`PrimeSecureChildDarwinSubstrate` owns:

- the exact suspended `posix_spawn` ABI and its calibrated `0x448c` flag set;
- descriptor-rooted child working-directory selection;
- independent physical executable and logical `argv[0]` inputs;
- exact argument and replacement-environment C-string transport;
- standard input replacement with `/dev/null`;
- normalized close-on-exec pipes with nonblocking parent read ends; and
- a one-shot stream-descriptor owner that transfers both read descriptors
  once and closes an abandoned pair during deinitialization.

The physical executable path is passed only as the second `posix_spawn`
argument. The first C argument remains
`[logicalArgumentZero] + exactArguments`. Neither value becomes authority by
being accepted by this internal transport. Each closed caller still supplies
values derived from its separately held executable and role policy.

The neural facade maps neutral rejection details back into its existing error
type. The fixture kernel maps them into its existing closed fixture error.
No public type, initializer, evidence field, Codable layout, executable
product, target, or package dependency is added.

## Ownership and failure boundary

Before successful spawn, the transport owns every pipe end and closes all of
them on failure. On success it closes the parent write ends and transfers the
two read ends to a single reference owner. Both descriptors transfer as one
pair; an untransferred pair is closed automatically.

The returned child is still adopted immediately by each existing lifecycle
controller. Existing suspended cwd and mapped-image joins, death observation,
signal escalation, exact-PID reap, process-group-empty proof, bounded EOF
drains, and fail-stop behavior are unchanged. Those mechanics have not yet
been neutralized and therefore cannot be called a Driver V2 substrate.

## Evaluation boundary

The focused source and mechanics checks require:

- exactly one implementation of `posix_spawn`, in the neutral source;
- both existing closed consumers to call that source;
- separate physical path and logical `argv[0]` transport;
- rejection of empty, NUL-containing, or over-limit argument zero values;
- one-shot paired stream ownership and abandoned-pair closure;
- absence of public, `Process`, shell, Python, Codable, product, or target
  surfaces; and
- preservation of the existing lifecycle, mapped-image, fixture, and Release
  canaries.

The root Debug focused suite, root Release package-description canary, source
seal, nested validation suite, and nine-mode Release integration are the
relevant execution checks. They do not constitute a fresh 903-test run.

The completed evaluation observed:

- root Debug lifecycle plus capture: 20 tests, zero failures, and one expected
  Release-only skip;
- root Release capture: 10 tests and zero failures;
- Release source-provenance proof: one test and zero failures;
- two matching live package-description roles: 63,051 bytes with SHA-256
  `eb116603c3407c0db01ff3b8182fe9a0e26b6c4c216e2aa8bfaf0389f1e915e7`;
- isolated validation workflow: 87 tests in Debug with one expected
  Release-only skip, then 87 tests in Release against clean companion `main`,
  with zero failures in both configurations; and
- live Release fixture integration:
  `PASS modes=9 logical_argv0=PASS one_shot=PASS executable_replacement=REJECTED`.

The frozen inventory resources remain 891 XCTest entries / 114,060 bytes /
SHA-256
`583056975d443cb9195ab8af6944625833b78b848b0afa2640275811aec3f829`
and 12 Swift Testing entries / 1,287 bytes / SHA-256
`487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3`.
Those are preservation checks, not a fresh 903-test execution receipt.

## Authority ceiling and next boundary

All nine guarded-source authorities remain missing. Process, Git, Swift,
build, inventory, staging, shard, completion, resume, CI, optimizer, neural,
scientific, training, and product authority remain absent.

The next secure-child slice must neutralize the supervision layer around this
transport:

1. establish one absolute phase deadline before spawn;
2. hold and join the suspended cwd and physical mapped image with neutral
   evidence types;
3. own lifecycle, containment, exact-PID reap, process-group-empty proof, and
   both EOF drains as one non-restorable capability; and
4. prove every post-spawn rejection either returns only after complete
   containment or enters the existing fail-stop path.

Only after that independent audit should the canonical tracked-tree
manifest/held-byte mechanics and fixed Git acquisition be connected to live
process observations. The gapless build → XCTest-list → Swift-Testing-list
source-watch sequence remains later.
