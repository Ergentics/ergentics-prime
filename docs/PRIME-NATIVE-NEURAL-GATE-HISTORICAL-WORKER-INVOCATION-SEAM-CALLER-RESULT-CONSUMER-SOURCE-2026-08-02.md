# Prime native neural-gate historical worker invocation-seam caller/result-consumer source

## Scope

V25 source-binds the V24-reviewed same-file caller and discard consumer. It is
an append-only continuation of the V23 worker source. It does not add a worker
file, import, package dependency, target, resource, cross-file caller, `main`
edge, request handler, replay transport, runtime launch, artifact I/O, or
publication path.

The worker remains unavailable from `main` and exits with status `78`. Prime
remains `ABSTAIN`.

The canonical source contract is
`prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_v25`
at SHA-256
`21f5a3805c6a5404072caa79d4c6c3463556c4a780d215e03fe570cd26d5a9d5`.
The additive topology is
`prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_source_topology_v25`
at SHA-256
`a5907c0d1505c004a4fbd67193d2b1f7f640cd8c8906fdd94cdbed6eab667ba3`.

## Exact source evolution

The evolved source is:

`Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift`

Its physical identities are:

| Part | Bytes | SHA-256 |
| --- | ---: | --- |
| Preserved V23 prefix | 13,227 | `62c0c413e25b95576a023f9b93f67b55a6c38f0cadbdfa4330dba31aea41ae54` |
| Appended V25 suffix | 948 | `ed9c1527b23190fb8c8e3d2ce2144929cf8e6d551d3b6a3c4dad6f4b9e08f626` |
| Complete V25 source | 14,175 | `bac6238644345afea2fb3404a0e073885d232380c31d3f4ce02f53936abe47a8` |

The first 13,227 bytes are byte-for-byte identical to V23. The append contains
exactly one file-scope extension of the existing nested V23 wrapper. Imports
remain unchanged and the worker still contains exactly four Swift source
files, seven direct local dependencies, and one resource.

## Materialized boundary

The suffix adds one internal nonpayload enum:

```swift
internal enum CallerResultConsumerDisposition {
    case compositionCompletedAndDiscarded
    case failedClosedWithoutDetail
}
```

It has no associated values, raw type, declared conformances, attributes,
stored properties, methods, description, reflection helper, encoding surface,
or error surface.

The same extension adds one internal, static, synchronous, nonthrowing,
nongeneric method:

```swift
internal static func
    sourceBoundUnavailableHistoricalWorkerInvocationSeamCallerAndDiscardConsumer(
        evidence:
            PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
        context:
            PrimeNativeNeuralGateHistoricalProjectionContext
    ) -> CallerResultConsumerDisposition
{
    do {
        _ = try Self
            .sourceBoundUnavailableHistoricalWorkerInvocationSeam(
                evidence: evidence,
                context: context
            )
        return .compositionCompletedAndDiscarded
    } catch {
        return .failedClosedWithoutDetail
    }
}
```

The method calls the V23 seam exactly once, through explicit `Self`
qualification, with the exact Evidence and context values in their original
order. It does not bind the returned wrapper. Success is emitted only after
the seam returns. One bare catch maps every thrown Swift `Error` to the single
failure disposition without binding, inspecting, returning, encoding, or
logging error detail.

`compositionCompletedAndDiscarded` means only that the raw seam returned and
the opaque wrapper was explicitly discarded. `failedClosedWithoutDetail`
means only that a Swift error crossed the seam. Neither case authenticates the
Evidence, caller, role, source, capture epoch, or artifact lineage. Neither is
a PASS or authority verdict.

## Compiler evidence ceiling

The exact four-file worker target builds in Release configuration with this
source. An independent reduced Swift canary also observed the expected success
and thrown-error disposition mapping.

Compilation establishes the lexical source shape and type relationships only.
The checked-in nonpayload boundary has no caller. The worker was not launched,
the composition was not exercised, and no fixture, exporter, projector,
decoder, gate, model, mutation, triad, SZ, statistics, or evaluation runtime
was executed by this slice.

## Leakage and security limits

The underscore assignment avoids a named wrapper binding and the method
contains no payload access. It does not prove copy elision, immediate
destruction, zeroization, memory uniqueness, or confidentiality. The private
payload can remain in process memory and generic reflection or unsafe
same-process access is outside this source contract.

The two dispositions reveal one coarse distinction: returned versus threw.
External timing, resource use, process termination, crash reports, traps,
signals, and out-of-memory behavior are not contained or equalized. The bare
catch covers Swift `Error`; it does not contain non-error termination.

The raw V23 seam remains `internal`. Other same-module sources, privileged or
`@testable` imports, dynamic tooling, debuggers, injected code, symbol or type
metadata inspection, reflection, and unsafe memory routes are not prevented
by V25. Ordinary non-testable external imports still cannot name the internal
surface.

## Exact negative boundary

V25 does not add or authorize:

- any other raw-seam caller or any caller of the new nonpayload boundary;
- any `main`, cross-file, request, transport, process, or runtime edge;
- worker input, output, sealing, launch, or execution;
- filesystem, environment, command-line, network, IPC, XPC, timing, metrics,
  logging, stdout, stderr, artifact, evidence, receipt, or publication work;
- mechanics PASS, terminal receipt, source or execution binding V7;
- scientific authority, product authority, or a claim of confidentiality.

## Next exact prerequisite

The next source step is not a runtime caller. It is a separately reviewed
design and source-binding sequence for the one-token, non-append-only access
rebinding of the raw V23 seam from `internal` to `private`, while preserving
the V25 nonpayload boundary as the sole ordinary source-level callable path.
That change is compiler-feasible but cannot be folded into V25 because it
would rewrite the prefix V24 requires to remain exact.

Even after that access rebinding, hardened non-exporting module or process
isolation, authenticated caller policy, and crash/timing/resource policy remain
mandatory before any untrusted launch, request, transport, or confidentiality
claim.

## Test-workflow note

The repository-wide suite was attempted under a bounded 30-minute window and
did not finish; it is not counted as passing. The cause is not Git
configuration. Historical V20/V21 canonical validators recursively replay
predecessor validation and repeat it through content hashing, multiplying the
same dependency DAG during mutation tests. V25 uses bounded exact V21-through-
V25 gates and the Release worker build. Validator de-recursion and isolated CI
sharding belong in a later performance-only change that preserves every
canonical identity and authority check.

## V26 private-access rebinding design update

V26 now binds the design for the exact future half-open byte replacement
12_555..<12_563 from internal to private. V26 does not edit the worker:
the checked-in raw seam remains internal, the V25 internal nonpayload
boundary remains its sole checked-in caller, main still exits 78, and Prime
remains ABSTAIN.

The projected source passed a bounded Swift frontend typecheck, but it is not
checked in and no clean Release product build, launch, execution, input,
output, I/O, publication, receipt, V7, scientific authority, or product
authority is claimed. Private will block ordinary direct cross-file naming;
it will not block indirect calls through the internal boundary, same-file
extensions of the declaring nested type, compiler/debugger privilege,
reflection after wrapper possession, unsafe access, or the conditional
returned-versus-threw/timing/resource/crash oracle.

See [the V26 design contract](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-WORKER-INVOCATION-SEAM-PRIVATE-ACCESS-REBINDING-DESIGN-2026-08-02.md).

The V27 exact prerequisite is:

`source_bind_the_one_token_non_append_only_raw_v23_invocation_seam_access_rebinding_from_internal_to_private_while_preserving_every_other_v25_worker_source_byte_the_v25_internal_nonpayload_boundary_as_the_sole_checked_in_raw_seam_caller_and_the_four_file_worker_inventory_without_any_main_cross_file_caller_request_transport_launch_runtime_confidentiality_artifact_io_publication_authority_or_source_binding_v7`
