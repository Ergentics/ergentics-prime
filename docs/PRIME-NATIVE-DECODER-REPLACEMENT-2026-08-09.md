# Prime-native decoder replacement

Date: 2026-08-09

## Ownership

`Ergentics/ergentics-prime` owns the cross-repository native decoder asset,
its future trainer and checkpoint truth, and the evidence used for selection.
`ergentics-llm` supplied the pinned Swift GQA body/cache mechanics used by this
port. It is not a runtime package dependency. PMHNP remains a read-only
integration and oracle consumer for this arc.

Historical MLXLLM/Llama comparator sources and receipts remain immutable. The
MLXLLM dependency and its two Llama execution products are absent from the
active Prime package graph; preserved source-only historical targets remain
source-pinned for evidence continuity but cannot select the new decoder.
PrimeCore history is likewise preserved; the new authority is append-only.

## Implemented mechanics

The library-only `PrimeNativeDecoder` target depends exactly on `PrimeCore`,
`MLX`, and `MLXNN` at the existing pinned Ergentics MLX revision. It contains:

- grouped-query attention without KV-head tiling;
- RoPE, RMSNorm, SwiGLU, residual blocks, and tied output projection;
- exact checked geometry and parameter-count derivation;
- deterministic task-local seeded construction;
- full-prefix causal forward mechanics;
- an opaque, decoder-bound, revision-bound KV cache with bounded growth,
  explicit materialization, poison/reset behavior, and rectangular-batch
  semantics.

The implementation can inventory the frozen Logic-10M MHA geometry by setting
query and KV heads equal, but does not claim parity with the earlier manual
attention implementation. Native-300M GQA geometry is inventory only and is
not allocated or executed by an authority contract.

## Authority ceiling

`PrimeNativeDecoderAuthorityPlan.frozenV1` remains the frozen predecessor.
`PrimeNativeDecoderDerivedDeltaPlan.frozenV1` separately binds the exact local
LLM donor commits, tree, source blob, byte count, SHA-256, implementation ID,
derived architecture deltas, Prime product/target, and dependency closure.
The donor revisions are explicitly recorded as not observed on `origin`.

This slice authorizes source materialization, compilation, and bounded
synthetic mechanics tests. It does not establish live Metal execution, cache
parity, gradients, runtime dependency closure, runtime initialization,
checkpoint loading, training, trial authorization, canary replacement,
quantization, product use, or publication. The result remains `ABSTAIN` at
those boundaries.

## Verification and next slices

The isolated validation package compiles against the exact first-party MLX
pin. Metal-free configuration, overflow, profile-inventory, and cache
arithmetic tests run in trusted-main CI. Full forward, GQA scalar parity, gradient,
seed, and cache-parity tests require a Metal-visible process and must report no
skips before runtime readiness can be claimed.

The validation package deliberately has no repository-owned SwiftPM mirror.
Every gate supplies an isolated `--config-path`, and the quarantine gate
asserts that no package-local mirror appears. This keeps dependency remapping
outside the committed authority surface while the exact lock remains pinned.

Geometry RenderKit remains a useful Metal lifecycle and CPU/GPU parity-pattern
donor at its pinned audited revision. Prime's existing roadmap explicitly
records that Geometry field/render kernels are not language or quant kernels.
No Geometry checkout is available in this workspace for a fresh source audit,
so this slice neither imports it nor claims that it resolves the current
process's Metal-device visibility. A later test-host arc may source-bind and
adapt a neutral device/bootstrap pattern without making the app a decoder
dependency.

The remaining replacement order is:

1. run the existing mechanics suite on a Metal-capable exact-head process and
   publish a separate execution observation;
2. define a strict Prime-owned decoder/checkpoint identity and generic
   train/evaluate/load surface;
3. persist exact optimizer, RNG, and data-cursor state for trajectory-exact
   resume;
4. produce a new non-fixture candidate and separately authorize a bounded
   canary/trial;
5. migrate the read-only PMHNP canary consumer to the Prime-owned interface and
   remove its active Llama factory after single-MLX-graph reconciliation;
6. address CoreML/NeuralKit product export only after accepted checkpoint and
   parity evidence.

No training, network access, push, PR, PMHNP write, or product decision is part
of this slice.
