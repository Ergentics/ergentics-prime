# Prime Native Neural Gate Trap-Disjoint Topology

Date: 2026-07-30

## Outcome

Stage B now has an implemented trap-disjoint mechanics boundary, but it still
does not have a Stage-B executor, worker, probe, verifier, process record, or
terminal receipt.

`PrimeNativeNeuralGateTrapDisjointTopologyContract.frozenV1` is the current
topology correction. Its canonical SHA-256 is
`48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5`.
Its status is `planned_not_materialized`, `executionImplemented` is false, and
source binding V7 is explicitly not issued.

The historical fixture replay plan V5 and source binding V6 remain
byte-for-byte history. The topology contract supersedes only their unsafe
future target-routing assumption. It does not relabel them as an observed
execution graph.

## Implemented package boundary

The package now has these exact local closures:

```text
PrimeNativeNeuralGateReplayMechanics
    dependencies: []
    authority: pure raw-UTF8 stream, chunk, invariant, and fingerprint mechanics

PrimeNativeNeuralGateCorrectedMechanics
    dependencies:
      - PrimeNativeNeuralGateReplayMechanics
    authority: prompt-only raw execution values and structural traces

PrimeNativeNeuralGateCorrectedEvaluationMechanics
    dependencies:
      - PrimeNativeNeuralGateReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
    authority: correlation, target feasibility, regrade, statistics,
               capability, verdict, and mutation-observation validation

PrimeNativeNeuralGateCorrectedFixtureAuthority
    dependencies:
      - PrimeNativeCorpusReplayMechanics
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGateCorrectedEvaluationMechanics
    authority: trap-bearing offline corrected-fixture derivation

PrimeNativeNeuralGatePromptSolver
    dependencies:
      - PrimeNativeNeuralGateCorrectedMechanics

PrimeNativeNeuralGateLogitSidecarMechanics
    dependencies:
      - PrimeNativeNeuralGateCorrectedMechanics

PrimeNativeNeuralGateMLXLogSoftmaxRecomputation
    dependencies:
      - PrimeNativeNeuralGateLogitSidecarMechanics
    external products:
      - MLX
      - MLXNN
```

The prompt solver and sidecar closure can no longer reach correlation,
expected completion, regrade, capability, verdict, or mutation-observation
types. The fixture authority can reach those types, but the corrected raw
executor cannot reach the fixture authority or corpus mechanics.

## Planned execution topology

The following targets are names and dependency constraints only. None exists
in `Package.swift` yet:

```text
ErgenticsPrimeRuntime
    dependencies: []

PrimeNativeNeuralGateHistoricalReplayMechanics
    dependencies:
      - ErgenticsPrimeRuntime
      - PrimeNativeNeuralGateReplayMechanics

PrimeNativeNeuralGateReplayTransport
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateReplayMechanics

PrimeNativeNeuralGateHistoricalFixtureWorker
    dependencies:
      - PrimeCore
      - ErgenticsPrimeRuntime
      - PrimeNativeNeuralGateHistoricalReplayMechanics
      - PrimeNativeNeuralGateReplayTransport

PrimeNativeNeuralGateReplayProbe
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateReplayTransport

PrimeNativeNeuralGateReplayVerifier
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateReplayTransport

PrimeNativeNeuralGateCorrectedRawWorker
    dependencies:
      - PrimeCore
      - PrimeNativeNeuralGateCorrectedMechanics
      - PrimeNativeNeuralGatePromptSolver
      - PrimeNativeNeuralGateLogitSidecarMechanics
```

No target outside the historical runtime module, its historical replay
adapter, and the historical fixture worker closure may reach
`ErgenticsPrimeRuntime` or
`PrimeNativeNeuralGateHistoricalReplayMechanics`. Probe and verifier remain
trap-free supervisors. The corrected raw worker is a separately launched
prompt-only executor and cannot compile against evaluation/regrade mechanics,
fixture authority, the historical runtime, or MLX recomputation.

The planned corrected worker adds a process role beyond the historical
six-process plan. The process-count and receipt contract must be revised
before corrected execution; it cannot be silently fit into the old topology.

## Donor routing

Adaptation proof V2 is preserved as historical evidence. Its donor gate and
verdict-carrier destinations point into the pure replay target, which is the
unsafe routing discovered by this audit.

A future adaptation proof V3 must route both into:

```text
Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/
```

The fixture prefix, transformed byte count, and SHA-256 must then be
recomputed from the pinned Swift donor bytes. No donor source is copied or
compiled by this topology slice.

## Package-capture truth

The prior 26,090-byte Release secure-capture canary, SHA-256
`53ace0b68b1f8f2cf6534be886cb93241b08a36e0ddf0e9da7f8eee33f37cb40`,
captured and parsed the actual package description. It did not reconcile that
description against source binding V6's planned target closure. V6 names
future targets that are absent from the package and assigns runtime
dependencies to the currently pure replay target.

That canary is therefore secure-capture evidence for the actual package at
that checkpoint, not a V6 selected-source execution-graph proof. After the
raw/evaluation split and topology V1 correction, the same Release canary
passed with byte-identical probe/verifier output: 27,015 bytes, SHA-256
`00dc419e101367d1f4a1d39f63bd35649b4de45417d74e4197f2376d729cdadf`.
That is the current actual-package secure-capture reseal and still is not a
V6 or V7 execution-graph proof.

Source binding V7 is reserved until every planned and deferred evidence role
is frozen and materialized, including the independent corrected mutation
producer/detector and process-scoped evaluation ownership, and a live
`PrimeNativeNeuralGateCompiledSourceClosureRecord` validates the same captured
`swift-package describe` bytes against the exact contract.

## Remaining evidence gaps

The existing 15-case corrected mutation observation is a validator over
caller-provided baseline, mutated, and restored records. It does not inject a
mutation or independently detect one.

The historical 46-case donor output exposes summary fields, not enough typed
raw material for a terminal verifier to recompute every mutation. Its private
mutators and detectors require a hash-bound source-derived seam rather than a
hand-port.

The durable output namespace also lacks typed schemas and bounded canonical
decoders for:

- source-derived prompt-only fixture rows;
- outer correlation, target, and regrade material;
- raw executions and full mutation deltas;
- historical gate materials and observations;
- logit dictionary, chunks, manifest, and MLX recomputation observations;
- statistics, verdict, process records, and terminal receipt.

Mutation identity must be `(arm, ordinal, mutation_id)` because
`target_dependent_prompt_grouping` has different meanings in the two arms.
Each mutation must bind an exact or explicitly allowed failure set; merely
containing one expected failed leg is insufficient.

## Ordered continuation

1. Implement pure typed artifact schemas, bounded canonical decoders, and
   output-namespace paths.
2. Implement the corrected 15-case producer and an independently implemented
   detector. They may not share mutation implementation code.
3. Derive the historical gate/carrier seam and 46-case raw mutation material
   from the pinned donor source.
4. Materialize role-scoped workers, probe, verifier, exact inventory, process
   records, and receipt-last composition.
5. Run the durable full-vocabulary sidecar and maintained MLX Float32
   recomputation as Stage-B evidence.

Every step remains Swift-first and Prime-owned. Python, shell scientific
authority, PMHNP runtime dependencies, new model execution, Metal authority,
and product authorization are outside this topology claim.

The separate read-only Swift Git workflow preflight remains a later workflow
slice. It does not belong in the Stage-B evidence graph, and the signed-in
GitHub app remains the PR/check/merge publication boundary.
