<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime native neural gate historical worker invocation-seam private-access rebinding source — 2026-08-02

## Disposition

V27 is source-bound and remains ABSTAIN.

This slice realizes the V26-designed one-token Swift access-control change.
It narrows ordinary direct naming of the raw historical worker invocation seam
from other physical source files and testable clients. It does not create a
caller, runtime path, confidentiality boundary, execution result, mechanics
PASS, source-binding V7, scientific authority, or product authority.

## Exact source receipt

The only checked-in worker mutation is:

| Receipt | Bytes | SHA-256 |
| --- | ---: | --- |
| V25 predecessor | 14,175 | bac6238644345afea2fb3404a0e073885d232380c31d3f4ce02f53936abe47a8 |
| V27 checked in | 14,174 | 767cc0101c52a311d40acc1dbba1747b7e3cdf7430f73d69a168ab62d1290e15 |

The source is
Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift.

- unchanged prefix: 12,555 bytes /
  4a2a86438cb47eb1026d4492791b500f40814af91a59380bbb8ce54df8f0a59d
- old token: internal, 8 bytes /
  3bed2cb3a3acf7b6a8ef408420cc682d5520e26976d354254f528c965612054f,
  at historical 12_555..<12_563
- current token: private, 7 bytes /
  715dc8493c36579a5b116995100f635e3572fdf8703e708ef1a08d943b36774e,
  at current 12_555..<12_562
- unchanged suffix: 1,612 bytes /
  db1118db558590f644eef151677d12f447a8ec6e8055098365a86da60f93a239,
  beginning at current offset 12,562
- current pre-V25 segment: 13,226 bytes /
  1e2f3119d903c6819ebf916da1d5f3006d4bed0636a834a3caaaf9d31e519480
- unchanged V25 boundary suffix: 948 bytes /
  ed9c1527b23190fb8c8e3d2ce2144929cf8e6d551d3b6a3c4dad6f4b9e08f626

Replacing current 12_555..<12_562 with the eight bytes of internal
reconstructs the V25 source exactly. Reapplying private reconstructs V27
exactly. Tests prove prefix, token, suffix, forward projection, and reverse
reconstruction byte-for-byte.

## Frozen contracts and topology

- V26 design canonical SHA-256:
  58bd67d365c38337b1eda6d2ca8e28422125f424ff7eccec72ca151a91dd4f8e
- V26 topology canonical SHA-256:
  dfbba4e7adecac57febd8ab0946ab34f698d63d6b55d3fe119fe53c029c8da63
- V27 source contract canonical SHA-256:
  92f6abf8417d7845d5425b973f7a45d13297bc5af736bd1a9248bc39fdc191ce
- V27 topology canonical SHA-256:
  a572b5813e0410235f387222f6399c2984fcb52da69f4bd9393a5adf6869cd7c

The V27 topology derives from V26. Its canonical delta is exactly six keys:

1. schema_version
2. contract_id
3. historical_worker_invocation_seam_private_access_rebinding_source_contract_binding
4. package_capture_authority
5. next_implementation_prerequisite
6. authority_statement

All target graph, forbidden reachability, status, execution flags, target
names, package authority ceilings, historical bindings, and V1–V26 canonical
identities remain exact.

## Historical-test evolution

The token lies inside the historical V23 source prefix. Four historical tests
therefore changed interpretation without changing their frozen contracts:

- V23 source contract test
- V24 caller/result-consumer design test
- V25 caller/result-consumer source test
- V26 private-rebinding design test

Each reads current V27, verifies the current identity and token, reverses only
private to internal, then runs its original historical assertions. The focused
evolved matrix passes 38/38. V22 and earlier bind the unchanged 11,354-byte
prefix and require no edit.

## Compiler and build evidence

Observed evidence:

- exact checked-in source compiles in PrimeCore/debug package construction
- an isolated archive with pinned resolution and a fresh SwiftPM scratch path
  compiled and linked the Release
  PrimeNativeNeuralGateHistoricalFixtureWorker product in 54.17 seconds
- the current same-file raw-seam caller compiles
- a baseline typecheck of the four actual worker sources succeeds
- adding an actual fifth physical Swift file that directly names the raw seam
  fails specifically for private protection
- a minimal two-physical-file same-module caller fails specifically for
  private protection
- a separate testable-import client fails specifically for private protection
- V27 source contract tests pass 11/11
- V27 topology tests pass 9/9 after pinning the observed canonical digest

Compiler canaries use bounded deadlines and file-backed output capture. They
do not use an unbounded wait with undrained pipes.

The Release artifact was not launched. Compile and link evidence is not runtime
execution evidence.

## Preserved worker boundary

The worker remains four Swift files plus one fixture resource, with seven
direct local dependencies and the same four imports in the evolved source.
Package.swift and root Package.resolved are unchanged. Main remains an
unconditional status-78 exit and names neither the raw seam nor the internal
V25 boundary.

The V25 internal nonpayload boundary remains the sole checked-in raw-seam
caller. It passes Evidence and context unchanged, discards the opaque wrapper,
and maps caught Swift errors to the two nonpayload dispositions without error
detail. No checked-in code calls that boundary.

## Security ceiling

Private access is a direct lexical restriction, not a confidentiality or
runtime-isolation boundary.

The following remain possible or unproven:

- another same-file extension of the declaring nested type could add a raw
  caller
- any same-module file, main, or testable client can still name the internal
  V25 boundary
- underscored private-source/compiler privilege, debugger, injection, dynamic,
  reflection-after-wrapper-possession, or unsafe routes are not prevented
- binary-symbol and type-metadata absence are not established
- a future boundary caller can supply Evidence and context and observe returned
  versus threw plus timing, resource, and crash behavior
- only Swift errors caught by the boundary lose detail; traps, signals, out of
  memory, timing, and resource behavior are not contained
- caller identity, role, origin, source, and artifact lineage are not
  authenticated
- confidentiality, zeroization, constant time, and constant resource use are
  not established

Hardened nonexporting isolation and an authenticated fixture-only caller and
observation policy remain prerequisites before any untrusted launch or
confidentiality claim.

## Repository-wide workflow truth

The repository-wide suite did not complete within the 1,800-second bounded
observation. It is not counted as passing.

The observed cause is repeated predecessor topology/content validation in the
V20/V21-era validation path. This is workflow/performance debt, not a Git
configuration issue and not a semantic failure established by V27. V27 does
not weaken validation, add caching, change Git settings, or claim remediation.
A later performance-only slice must preserve byte-identical V1–V27 canonical
hashes and mutation-failure behavior.

## Next boundary

The next semantic boundary is design only: hardened nonexporting fixture
isolation, authenticated caller policy, and explicit timing/resource/crash,
trap, signal, and out-of-memory containment. No caller implementation is
authorized by V27.
