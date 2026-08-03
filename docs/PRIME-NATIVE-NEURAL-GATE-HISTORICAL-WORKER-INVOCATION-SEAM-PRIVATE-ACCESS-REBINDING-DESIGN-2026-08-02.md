<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime historical-worker invocation-seam private-access rebinding design

Date: 2026-08-02

Status: V26 design-only, source not rebound, Prime ABSTAIN

## Purpose

V26 freezes the only worker-source mutation V27 may perform: replace the raw
historical-worker invocation seam's access token from 'internal' to 'private'.
V26 does not edit the worker, add a caller, or create a runtime path.

The design contract is:

- ID:
  prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_private_access_rebinding_security_design_v26
- canonical SHA-256:
  58bd67d365c38337b1eda6d2ca8e28422125f424ff7eccec72ca151a91dd4f8e

The additive topology is:

- ID:
  prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_private_access_rebinding_security_design_topology_v26
- canonical SHA-256:
  dfbba4e7adecac57febd8ab0946ab34f698d63d6b55d3fe119fe53c029c8da63

V26 preserves the V25 source contract
21f5a3805c6a5404072caa79d4c6c3463556c4a780d215e03fe570cd26d5a9d5
and V25 topology
a5907c0d1505c004a4fbd67193d2b1f7f640cd8c8906fdd94cdbed6eab667ba3.

## Current checked-in truth

The checked-in worker source remains:

Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift

- 14,175 bytes
- SHA-256
  bac6238644345afea2fb3404a0e073885d232380c31d3f4ce02f53936abe47a8
- raw seam access: internal
- V25 nonpayload boundary access: internal
- checked-in executable raw-seam callers: one, the same-file V25 discard
  consumer
- callers of the V25 nonpayload boundary: zero
- main: unconditional status 78

Package.swift, the four-file worker inventory, seven direct local
dependencies, one package-lock resource, import inventory, target graph, and
forbidden reachability are unchanged.

## Exact V27 mutation geometry

V27 may replace only the half-open zero-based byte range
12_555..<12_563:

    internal static func

becomes:

    private static func

| Component | Bytes | SHA-256 |
| --- | ---: | --- |
| unchanged prefix | 12,555 | 4a2a86438cb47eb1026d4492791b500f40814af91a59380bbb8ce54df8f0a59d |
| current token internal | 8 | 3bed2cb3a3acf7b6a8ef408420cc682d5520e26976d354254f528c965612054f |
| projected token private | 7 | 715dc8493c36579a5b116995100f635e3572fdf8703e708ef1a08d943b36774e |
| unchanged suffix | 1,612 | db1118db558590f644eef151677d12f447a8ec6e8055098365a86da60f93a239 |
| projected V27 source | 14,174 | 767cc0101c52a311d40acc1dbba1747b7e3cdf7430f73d69a168ab62d1290e15 |
| projected pre-V25 segment | 13,226 | 1e2f3119d903c6819ebf916da1d5f3006d4bed0636a834a3caaaf9d31e519480 |
| unchanged V25 suffix | 948 | ed9c1527b23190fb8c8e3d2ce2144929cf8e6d551d3b6a3c4dad6f4b9e08f626 |

Every other byte is frozen. V27 may not alter a declaration name, signature,
body, call, disposition, boundary, comment, whitespace byte, import, package
edge, worker target-graph edge, or forbidden-reachability edge.

The V23 prefix cannot remain byte-exact after V27 because the token lies
inside it. Historical V23 through V26 contracts and topologies therefore
remain immutable records, while their source-integrity tests must evolve to
explicit historical-before/current-after reconstruction.

## Compiler evidence

Two independent checks streamed the exact one-token projected worker source
to the Swift frontend while reading the other three real worker sources, the
existing generated resource accessor, and existing Release-built dependency
modules. Both exited zero. This is frontend typecheck evidence, not a clean
SwiftPM Release product build, link, launch, or execution.

A reduced same-file extension of the raw seam's declaring nested type could
call its private method. A separate two-physical-file canary was rejected by
Swift because the private method was inaccessible. No checked-in worker
source was modified for either check; task-scoped compiler caches were under
/tmp.

V27 must repeat the positive and negative access checks and perform a clean
Release build of the worker after the checked-in source binding.

## Narrow security effect

After V27, ordinary Swift code in another file, main, and an @testable import
cannot directly name the private raw seam. The V25 internal nonpayload
boundary remains the sole checked-in raw-seam caller and the ordinary
cross-file path.

This is direct lexical access narrowing, not a general execution or
confidentiality boundary:

- same-module and privileged code can call the internal V25 boundary;
- a future same-file extension of the raw seam's declaring nested type can
  add another direct caller;
- underscored private-source imports, compiler privilege, debugger,
  injection, dynamic lookup, reflection after wrapper possession, and unsafe
  memory routes are not prevented;
- if the internal boundary is later invoked, a caller can choose Evidence and
  context and observe returned-versus-threw plus timing, resource, and crash
  behavior;
- only Swift Errors caught through that boundary lose detail; raw callers are
  not universally forced through the mapping;
- caller, role, origin, source, capture epoch, input, and artifact lineage are
  not authenticated;
- binary-symbol absence, confidentiality, zeroization, constant-time or
  constant-resource behavior, and trap, signal, or out-of-memory containment
  are not established.

Hardened nonexporting module or process isolation, authenticated caller
policy, and crash/timing/resource policy remain mandatory before any
untrusted runtime or confidentiality claim.

## V27 source-binding requirements

V27 must:

1. apply exactly one internal to private token replacement at
   12_555..<12_563;
2. reconstruct the projected file from the frozen prefix, token, and suffix,
   and reverse-reconstruct V25;
3. bind the 14,174-byte projected source and its canonical source contract;
4. preserve every V1 through V26 canonical contract and topology;
5. evolve V23, V24, V25, and V26 integrity tests with explicit historical
   before/current after identities without rewriting their frozen contracts;
6. preserve the V25 internal disposition, boundary signature/body, sole
   checked-in caller, and error mapping;
7. reject internal, default, fileprivate, package, public, and open access
   mutations;
8. repeat positive same-file and negative two-file compiler gates and run a
   clean Release worker build;
9. preserve Package.swift, worker inventory, dependencies, resource, imports,
   main status 78, topology graph, forbidden reachability, and ABSTAIN;
10. add no main/cross-file boundary caller, request, transport, input, output,
    launch, execution, artifact I/O, publication, PASS, receipt, source
    binding V7, scientific authority, or product authority.

The exact next prerequisite is:

    source_bind_the_one_token_non_append_only_raw_v23_invocation_seam_access_rebinding_from_internal_to_private_while_preserving_every_other_v25_worker_source_byte_the_v25_internal_nonpayload_boundary_as_the_sole_checked_in_raw_seam_caller_and_the_four_file_worker_inventory_without_any_main_cross_file_caller_request_transport_launch_runtime_confidentiality_artifact_io_publication_authority_or_source_binding_v7

## Focused validation

- V26 design contract: 11/11 passed
- V26 topology: 9/9 passed
- exact current/projected/reverse byte reconstruction: passed
- exact projected worker-source frontend typecheck: passed independently
- positive same-file private-extension canary: passed
- negative two-physical-file private-access canary: compiler rejected as
  required

The earlier repository-wide suite did not finish in its 30-minute observation
window and is not counted as passing. Recursive predecessor validation in
historical V20/V21 contracts remains a separate workflow-performance issue;
V26 does not cache verdicts or weaken canonical validation to hide that cost.

## V27 source-binding result — 2026-08-02

V27 realizes this design with the sole checked-in worker mutation: internal to
private at current bytes 12_555..<12_562. The live source is 14,174 bytes /
767cc0101c52a311d40acc1dbba1747b7e3cdf7430f73d69a168ab62d1290e15;
reverse reconstruction restores the exact V25 source.

The V27 source contract is
92f6abf8417d7845d5425b973f7a45d13297bc5af736bd1a9248bc39fdc191ce
and topology V27 is
a572b5813e0410235f387222f6399c2984fcb52da69f4bd9393a5adf6869cd7c.
An isolated fresh Release build compiled and linked the actual worker without
launch. Same-file access compiled; actual fifth-file, minimal two-file, and
testable direct-name probes were rejected for private protection.

No caller, request, transport, launch, execution, artifact I/O, publication,
mechanics PASS, source-binding V7, scientific authority, or product authority
is added. Private narrows ordinary direct naming only and does not establish
authentication, confidentiality, zeroization, constant-time/resource behavior,
or crash, trap, signal, out-of-memory, timing, or resource containment. Prime
remains ABSTAIN.

The repository-wide suite remains not completed and not passing after the
bounded 1,800-second observation. Its repeated predecessor-validation cost is
separate workflow debt, not a Git-configuration issue or V27 remediation. The
next semantic boundary is design for hardened nonexporting isolation and an
authenticated fixture-only caller/observation policy.
