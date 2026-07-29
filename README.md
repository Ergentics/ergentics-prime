# Ergentics Prime

Ergentics Prime is the first-party Swift/MLX/Metal research system for the
native Prime language model. It is split out from the PMHNP companion so model
execution, evaluation, and evidence durability can evolve without making a
product consumer the scientific authority.

## Implemented now

- exact maintained `ergentics_prime_native_3b_gqa_v1` geometry;
- random initialization and full FP32 weights;
- explicit initialization, training-schedule, and evaluation controls;
- Swift-native process supervision, mutation gates, and immutable receipts;
- MLX/Metal execution through maintained model, differentiation, optimizer,
  and device primitives.

The 512-entry profile vocabulary is only a tensor dimension today. A native
tokenizer manifest, deterministic first-party compositional corpus, full
training loop, independent evaluator, statistical battery, and SZ
fingerprinting are planned but are not implemented or claimed by the initial
mechanics slice.

The first GPU action is the frozen
`exact_3b_fp32_allocation_update_probe_b1_s128_a1`: one optimizer step at
batch 1, sequence 128, and accumulation 1. It allocates the exact 3B FP32
model, executes forward/backward, proves nonzero Adam state, and changes model
weights. It is not a language-quality result and does not authorize a long
training run. Larger activation and 4,096-position arms require this measured
memory floor first; “4,096-position” means padded positions per optimizer
step, not a 4,096-token context window.

## Language boundary

Python and shell do not generate, mutate, grade, summarize, or authorize
scientific evidence in this repository. Shell may invoke `swift build`,
`swift test`, or a compiled Swift executable during development; that is
recorded separately from shell scientific authority, which remains false.
Production orchestration launches exact hashed executables directly from
Swift.

The pinned MLX Swift binary contains an upstream CPU-JIT helper that is linked
with `popen`. Prime does not use that helper as scientific authority and the
GPU calibration does not intentionally invoke it, but this first canary does
not include child-process tracing. Receipts therefore disclose the capability
and record dependency-shell execution as unavailable; they do not claim a
mechanically observed `false`.

`PrimeLeaseHolder` is a Swift-only diagnostic used to hold the same
descriptor-anchored lease while the supervisor integration path is tested. It
does not execute MLX, select scientific parameters, or emit model evidence.

The reason no Python mutation waiver exists is concrete: every admitted
mutation operator is implemented and independently replayed in Swift. If a
future mutation truly requires an unavailable Swift primitive, the run remains
`ABSTAIN` until that primitive is implemented or a separately reviewed,
mutation-specific exception is added. There is no general Python fallback.

## AdamW

AdamW is an optimizer algorithm, not a Python component. Prime uses the
maintained `MLXOptimizers.AdamW` implementation from the Swift package.
The pinned `mlx-swift` 0.31.3 implementation intentionally omits first- and
second-moment bias correction. The receipt binds that fact plus learning rate,
betas, epsilon, weight decay, optimizer-state count, dtype, and nonzero norm.
The current upstream Swift API does not provide a supported optimizer-state
restore setter. Long interrupted/resumed training therefore remains
fail-closed until a maintained typed restore API is available and trajectory
identity is proven.

## Initial calibration

The executable accepts paths and the explicit human allocation authorization;
scientific knobs are frozen in the canonical Swift configuration:

```sh
swift build -c release --product PrimeGPUCalibration
.build/release/PrimeGPUCalibration \
  --artifact-root /private/tmp/ergentics-prime-calibration \
  --source-root "$PWD" \
  --historical-evidence-root /path/to/pmhnp-companion-ergentics \
  --lease-file /private/tmp/ergentics-prime-metal/prime-metal.lock \
  --authorize-gpu-allocation true
```

Both the artifact root and lease parent must already be private directories.
The embedded source identity must be regenerated after any admitted source
change; a debug, stale, or source-divergent executable fails before Metal.
The executable imports and independently verifies the three exact historical
seed records before it acquires Metal. It then self-snapshots the complete
Swift source and executable, publishes configuration and evidence with
descriptor-anchored no-replace semantics, and emits a canonical receipt.
The release executable is also a Swift supervisor: it launches the same
release binary as an internal worker without a shell, applies a hard
end-to-end timeout, verifies the worker receipt, and publishes a distinct
`ABSTAIN` receipt if the worker terminates through a signal, process-level
allocation failure, or other fatal path before it can write one. Missing
worker observations remain unavailable rather than being rewritten as
`false`.

The requested 96 GiB MLX memory setting is an MLX scheduler limit, not a claim
that process RSS cannot exceed 96 GiB.
`artifacts/` is intentionally gitignored; successful binary evidence must also
be copied to durable off-device storage before it can authorize a later run.

## Provenance

The initial architecture values and historical evidence were separated from
`Ergentics/pmhnp-companion-ergentics` at commit `163fc10`. Historical reports
remain in that repository; this repository owns new Prime execution.
