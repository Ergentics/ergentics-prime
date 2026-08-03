# Prime native decoder authority correction

Status: authority correction; no decoder implementation, training, profile
promotion, or quantization is authorized by this document

Effective snapshot: 2026-08-03

Typed authority: `PrimeNativeDecoderAuthorityPlan.frozenV1`

## Outcome

Prime's future authoritative decoder implementation is a Prime-owned Swift
mechanical port of the existing Ergentics Logic decoder semantics, executed
with maintained MLX/MLXNN/MLXOptimizers primitives on Metal.

The source donor is pinned exactly to:

- rights holder: `Ergentics, LLC`;
- license: `LicenseRef-Ergentics-Proprietary`;
- repository: `Ergentics/ergentics-logic`;
- revision: `97be84b2790b79ce79558d6bade846a532226540`;
- path: `Sources/ModelKit/model.py`;
- git blob: `fcc471205780bf742fb7d70f5d4fdb073b90f216`;
- git mode: `100644`;
- byte count: `7,189`;
- SHA-256:
  `8e28d1e19b5aea4504af62d5ff11b8d318d77c3e232670b9d8751b0996e264a2`;
- source type spelling: `ErgeticsLogicModel`.

The ownership/license assertion is independently pinned to `SEED.md` at the
same revision:

- git blob: `3ed6e27813bf61ca76e3919848ac14f14d4c4c4f`;
- git mode: `100644`;
- byte count: `23,250`;
- SHA-256:
  `e85812acc482d37643c135fd6db8dbfc0007dd5add712ed4407b7076ab978d54`.

That record names `Ergentics, LLC`, the proprietary repository license, the
ground-up architecture intent, and the prohibition on pretrained-weight
imports. It is provenance evidence, not proof that every historical claim in
the donor has been independently reproduced.

The donor is architecture and reference source only. Prime must not execute
its Python, import it as a runtime dependency, launch it as a subprocess, or
allow it to publish Prime evidence. The new implementation is Swift. The
maintained MLX stack supplies tensor operations, autodiff, optimizer
arithmetic, and Metal execution; Prime does not hand-roll those primitives.

## Correction, not erasure

`PrimeNativeArcContinuityPlan.frozenV1` truthfully records that the completed
two-step exact-3B mechanics continuation used `MLXLLM.LlamaModel`. That frozen
receipt contract remains immutable and its bounded mechanics evidence remains
valid for exactly the scope it observed.

The defect was interpreting that historical field as the implementation
authority for future functional training. It established neither first-party
decoder-source ownership nor model-family selection. The new typed authority
therefore quarantines `MLXLLM.LlamaModel` as a historical mechanics comparator
and explicitly prevents it from selecting the future decoder.

No third-party pretrained weights are authorized. No third-party decoder
implementation is authorized in the future authoritative trainer. This does
not relabel maintained MLX tensor and optimizer primitives as first-party;
their upstream and derivative licenses remain disclosed.

## Existing first-party architecture

The pinned Logic source already defines the Ergentics decoder family rather
than merely a corpus donor. Its recorded structure includes:

- token embeddings with tied output projection;
- RMS normalization;
- rotary positional embedding;
- causal self-attention;
- SwiGLU feed-forward blocks;
- residual transformer blocks;
- random initialization without imported model weights; and
- existing 10M and phase-1 300M configurations.

This correction does not authorize inventing another architecture. It
authorizes a mechanical Swift port of those pinned semantics. Exact component
behavior, tensor topology, parameter counts, initialization, masking, and
training trajectory must be derived and tested in Swift before any larger
profile is considered.

The mechanical-port boundary is narrower than the former Prime GQA profiles.
The donor uses multi-head attention with equal query and key/value head
counts, RMSNorm epsilon `1e-6`, RoPE base `10,000`, and an additive manual
attention mask. The prior Llama path used GQA in larger profiles, RMSNorm
epsilon `1e-5`, a different RoPE base at 3B, and maintained attention/cache
semantics. GQA, fused attention, cache layout, alternate normalization, or
alternate RoPE is an explicit derived delta and remains `ABSTAIN` until
separately proposed and verified. Historical checkpoints and Adam state are
not compatible with the port merely because dimensions look similar.

## Ownership layers

| Layer | Authority after this correction |
| --- | --- |
| Architecture semantics | Pinned Ergentics Logic source at the exact revision above |
| Authoritative decoder implementation | Prime-owned Swift port in `ergentics-prime` |
| Tensor/autodiff/optimizer primitives | Maintained MLX Swift packages under their disclosed licenses |
| Device execution | Apple Metal through maintained MLX Swift |
| Initialization and learned weights | Prime random initialization and Prime-produced checkpoints only |
| Tokenizer, controlled corpus, and evaluator | Existing first-party Swift contracts, independently source-bound before use |
| Model/profile selection | EnginePropose/Derive/Dispose after parity and feasibility evidence; otherwise `ABSTAIN` |
| Historical Llama mechanics | Quarantined comparator evidence; no future selection authority |
| Python donor source | Read-only provenance/reference; never executed |

## Ordered implementation gates

1. Finish and admit neutral secure-child supervision. Do not mix decoder work
   into that implementation slice.
2. Finish Driver V2 raw-byte acquisition: first-party Darwin capture,
   immutable raw xUnit/transcript bytes, and verdicts derived by the existing
   first-party Swift parsers.
3. Bind the exact Logic source bytes, revision, derivation note, license, and
   independent parameter formulas into a Prime-owned source record. Reading
   the donor is permitted; executing Python is not.
4. Remove `mlx-swift-lm` from the root package before adding the authoritative
   decoder. If live-head historical replay is still demonstrably required,
   isolate the old executables in a separate, non-authoritative historical
   package with its own manifest and lock; they must not remain root products
   or current CI dependencies.
5. Implement the pinned decoder semantics in a new `PrimeNativeDecoder` Swift
   target depending only on `PrimeCore`, MLX, and MLXNN. A separate trainer
   target may add MLXOptimizers and the admitted typed optimizer-state path.
   Neither target may depend on `MLXLLM`, `mlx-swift-lm`, a Hugging Face
   loader, imported checkpoints, or a Python bridge.
6. Prove the 10M configuration first: parameter topology, component fixtures,
   causal future-token independence, finite forward/backward gradients,
   optimizer weight change, loss reduction, exact weight save/reload, exact
   optimizer-state resume, deterministic seed replay, throughput, and peak
   memory.
7. Run the first-party compositional canary with at least three independent
   confirmation replicates and the admitted Swift Verify/Abstain, statistics,
   triad, SZ, and mutation contracts. A mechanics pass is not function
   learning.
8. Compare the existing phase-1 300M configuration only after the 10M port and
   learning gates pass. EnginePropose/Derive/Dispose selects a bounded next
   profile or returns `ABSTAIN`; the earlier Llama/GQA 3B choice is not an
   inherited default.
9. Consider quantization, including whether a diagonal-Hessian leg is
   justified, only after an accepted full-precision functional checkpoint.

## Admission gates for the future Swift target

The authoritative decoder target must fail source admission if it contains or
depends on:

- `MLXLLM` or `LlamaModel`;
- `mlx-swift-lm` products;
- Hugging Face or pretrained-model loaders;
- imported model checkpoints or inherited weights;
- Python, PythonKit, a Python subprocess, or a `.py` execution path;
- hand-written AdamW, autodiff, or a whole-model Metal trainer.
- `PrimeNativeProfiles.exact3B`,
  `PrimeNative3BMetalContinuationContract`, or
  `ErgenticsNativeScaleEngineRecommend` profile reuse.

New execution evidence requires a new artifact kind and schema with typed
architecture and implementation identities, complete implementation-source
snapshot, dependency graph/lock binding, and explicit false values for
third-party decoder use and pretrained-weight import. The historical
`PrimeGPUCalibrationReceipt` and `PrimeNative3BMetalContinuationReceipt`
schemas cannot admit new decoder evidence or be relabeled as the port.

## Current limits

This correction does not claim that a Swift port exists, that the 300M profile
has completed training, that broad language capability exists, or that any
checkpoint is product eligible. It does not authorize a costly run. The
current verdict on decoder parity, function learning, profile choice, and
quantization remains `ABSTAIN` until the ordered gates produce evidence.

At this snapshot the root package still compiles two historical MLXLLM
executables. A source gate confines `import MLXLLM` and the `MLXLLM` product
edges to those exact targets, but full dependency quarantine is pending and is
the next model-boundary slice. The authoritative `PrimeNativeDecoder` target
does not yet exist. A prospective target-closure gate makes its appearance fail
unless the root Llama package is absent, the target depends exactly on
`PrimeCore`/MLX/MLXNN, its tree contains only regular Swift files, and its
source is free of the declared Llama, Python, process-launch, inherited-model,
and historical-GQA tokens.
