# Prime native neural-gate historical worker/export call-edge source

Date: 2026-08-01

Current continuation: V16 additively resolves the three V15 design blockers
with a complete 44-spec namespace, lossless keyed three-seed envelope,
corrected mutation-record target split, and package-internal in-memory
projector. It does not change this V14 call edge or the status-`78` worker's
dependency list. The projector has no ReplayTransport dependency and is not
reachable from the worker; no request handling, artifact write/publication,
historical execution observation, or source/execution binding V7 exists. The
V14 and V15 prerequisite and nonauthorization statements below remain frozen
history. See [Prime Native Neural Gate Historical Evidence Semantic-Artifact
Projection Design](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-SEMANTIC-ARTIFACT-PROJECTION-DESIGN-2026-08-01.md)
and [Prime Native Neural Gate Historical Evidence Semantic-Artifact Projection
Source](PRIME-NATIVE-NEURAL-GATE-HISTORICAL-EVIDENCE-SEMANTIC-ARTIFACT-PROJECTION-SOURCE-2026-08-01.md).

## Decision

V14 source- and compile-binds one private, cross-file historical
worker-to-exporter call edge. It changes only the existing product-free
historical worker target: the exact four V11 direct dependencies remain an
ordered prefix, and the existing V13 exporter dependency is appended once.

This is not a worker-execution checkpoint. The exact V11 primary `@main`
source is unchanged, still exits unconditionally with status `78`, and cannot
name the private member declared in the separate V14 source file. The new
member is therefore lexically unreachable from `main`. Compilation proves the
types and call expression only; it does not prove runtime behavior.

## Frozen contracts

- preserved V11 worker source contract:
  `prime_source_bound_historical_fixture_worker_v11`
- preserved V11 source-contract SHA-256:
  `64f0de29eed04145db6b598f2895bf9ee9d7804b03b35971f1ca77a72f76e9fb`
- preserved V13 exporter source contract:
  `prime_source_bound_historical_evidence_export_source_v13`
- preserved V13 source-contract SHA-256:
  `ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e`
- preserved V13 topology SHA-256:
  `b1564c277a50b8bc2b2ba325809130920dcb123f0d02297efba73e3bb3aec4ea`
- V14 source contract:
  `prime_source_bound_historical_worker_evidence_export_call_edge_v14`
- V14 source-contract SHA-256:
  `8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8`
- V14 topology:
  `prime_stage_b_historical_worker_evidence_export_call_edge_source_topology_v14`
- V14 topology SHA-256:
  `4aee5e011a7db85ed74955684f885b03f306e82b8fd4d0f12422d0b791663564`

The rights holder is `Ergentics, LLC`; the license expression remains
`LicenseRef-Ergentics-Proprietary`.

## Exact worker source and resource boundary

The worker target now contains exactly two Swift source files.

The preserved primary source is:

`Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift`

It remains exactly 2,298 bytes with SHA-256
`9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df`.
It has no exporter import or symbol, and its `main` remains the unconditional
unavailable exit.

The separately pinned V14 call-edge source is:

`Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift`

It is exactly 1,512 bytes with SHA-256
`d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319`.
It contains no `@main` or other entry point.

The copied fixture resource remains unchanged at:

`Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved`

Its exact identity remains 1,949 bytes with SHA-256
`cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3`.

## Private call-edge structure

The new source extends
`PrimeNativeNeuralGateHistoricalFixtureWorker` with the private static method:

```swift
private static func sourceBoundHistoricalEvidenceExportCallEdge()
    throws
    -> PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence
```

If a later source change makes this member reachable, its frozen expression
order is:

1. resolve the copied `HistoricalFixtureEvidence/Package.resolved` through
   `Bundle.module`;
2. call
   `EngineProposesNativeLanguageVerifyAbstainFixture.materialize(packageResolvedURL:)`;
3. pass only `fixture.materials` to
   `PrimeNativeNeuralGateHistoricalEvidenceExporter.export(_:)`; and
4. return the exporter's typed, in-memory `Evidence` value.

V14 makes no such later source change. A `private` declaration is visible only
within its own Swift file, so the unchanged `main` in the other file cannot
call it. The call edge performs no request decoding, evidence encoding,
artifact write, or publication operation.

## Package topology delta

The worker's V11 direct local dependencies remain the exact ordered prefix:

1. `PrimeCore`
2. `ErgenticsPrimeRuntime`
3. `PrimeNativeNeuralGateHistoricalReplayMechanics`
4. `PrimeNativeNeuralGateReplayTransport`

V14 appends exactly one dependency:

5. `PrimeNativeNeuralGateHistoricalEvidenceExportMechanics`

The worker remains an executable target without a product declaration. The
V13 exporter target's source and exact three-dependency closure are unchanged.
Every other target, dependency, materialization state, and
forbidden-reachability rule remains exact. Only the worker's V13 prohibition
against reaching the exporter is removed; the exporter remains forbidden from
reaching the worker, so the new direction is acyclic.

## Swift-only static validation

V14 validation is bounded to source, package, contract, topology, and
compilation evidence. It establishes:

- exact source and resource identities and an exact two-file worker source
  inventory;
- preservation of the V11 primary source and unavailable exit;
- the private cross-file access boundary and exact typed call expression;
- the exact four-dependency prefix plus one appended exporter dependency;
- preservation of the V13 exporter target and every non-worker topology edge;
- preservation of the canonical V1 through V13 topology identities; and
- fail-closed rejection of decoded source-binding or reachability mutation.

The existing donor-gated suite remains the applicable cross-repository source
check. V14 adds no donor source and therefore adds no new donor environment
marker.

No V14 validation launches or executes the historical worker, handles a
request, invokes the fixture materializer or exporter, executes the historical
gate, runs a model, MLX, Metal, mutation, or evidence workload, or observes an
exported value.

## Authority ceiling and next prerequisite

V14 does not seal or launch the worker, enable request handling, execute the
fixture/exporter/worker/gate/model path, observe historical evidence, encode
or publish an artifact, establish durable publication, independent detection,
distinct implementation families, or a four-tier audit, authorize mechanics
`PASS`, issue a terminal receipt or source/execution binding V7, or establish
scientific or product authority. Prime admission remains `ABSTAIN`.

The next exact prerequisite is:

`design_and_source_bind_the_historical_evidence_carrier_to_frozen_worker_semantic_artifact_projection_without_enabling_worker_request_handling_sealing_launch_execution_or_issuing_source_binding_v7`

That later design/source slice must remain separately reviewable. This V14
checkpoint does not authorize implementation of the carrier projection,
worker request handling, sealing, launch, execution, encoding, publication,
probe/verifier acceptance, or any model-training or quantization workload.
