# Prime versus older Ergentics Llama: live host execution

The retained Swift-trained Prime checkpoints now run through a native inference executable, with fresh predictions fed into later steps. The older Ergentics Llama checkpoint ran the same program cases in both direct and iterative modes. All model work used local Metal, with unchanged saved weights and no training.

| Model | Correct direct final | Correct iterative final | Every intermediate and final correct |
|---|---:|---:|---:|
| Prime10M, seed1618, 4,000 training steps | 8/80 | 54/80 | 48/80 |
| Prime10M, seed1618, 8,000 training steps | 15/80 | 61/80 | 48/80 |
| Older Ergentics Llama 3.2 3B fine-tune | 5/80 | 0/80 | 0/80 |

Prime benefits from repeated model calls with explicit state feedback. Both checkpoints produced completely correct traces on all 48 base, alternate-alphabet and neutral-context cases. Both failed complete traces on all 32 unseen-codebook cases. Some final answers recovered despite earlier errors: six at 4,000 steps and thirteen at 8,000. Final accuracy therefore overstates complete reasoning-path accuracy.

Llama received English descriptions of the same symbol mappings, using its original saved tokenizer and chat template. Twenty-two direct answers were valid value symbols; five were correct. Every iterative case eventually produced an invalid value or format, so none completed. All raw text and generated token IDs remain saved, including rejected outputs.

This is a controlled diagnostic of two semantic programs—increment/negate/increment and increment/increment/increment/decrement—across five binding/context conditions and eight starting values. It is not 80 independent problems, a general language benchmark, or a fair estimate of overall model intelligence. Prime was trained in this symbolic language; Llama receives its meaning through a text prompt. The two Prime checkpoints share one seed and architecture.

## Plain arithmetic and output format

A separate 16-case control removed the symbolic codebooks and asked Llama the same arithmetic in ordinary words and numbers. Its strict single-integer score was 0/16 direct and 3/16 for complete iterative traces. A separate descriptive audit found eight direct responses with correct worked final expressions and one with a complete correct state sequence; six had wrong final values and one was ambiguous. Thus nine contained an unambiguous correct final answer despite failing the required format. The [control review](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-v-Llama-01/Plain-Arithmetic-Control/LIVE-REVIEW.json) and [every direct raw answer](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-v-Llama-01/Plain-Arithmetic-Control/SCORES.json) preserve both observations. Nothing extracted during scoring was fed back to a model.

## What actually ran

- The main suite made 720 native forward calls and 189 Llama generations across 20 supervised processes. The plain control added 56 Llama generations in one process. Successful pilots are retained separately; the initial native startup trap generated no predictions.
- Prime used the original 74-tensor, 10,227,968-parameter architecture and exact original checkpoint bytes. Its low-level Swift type is named `LlamaModel`; that class name does not select the older Llama weights. This Prime model consumes structured native symbols and has no prose tokenizer.
- Each model received only case inputs. The next step used its own fresh prediction. Reference answers were used only afterward for scoring. Invalid values stopped continuation; their raw outputs were retained. There was no answer substitution, masked argmax, training, model download or dependency installation.
- The native executable was built from cached local Swift/MLX objects. Its first pilot exposed a lazy-clock initialization overflow; the repaired build completed all native calls. The old executable, failure receipt and root cause remain saved.
- This comparison uses host process supervision and Metal. HypervisorModel.swift's fixed ARM microguest, VM boot, app integration, and formal Driver/OS authority were not exercised. The broader Prime system comparison remains open beyond this host execution result.

The 80 inputs were reconstructed from retained original v1 execution reports. Historical prediction slots were removed, and static input templates agreed across both reports. The original full manifest is unavailable: its recorded hash has not been reproduced. [Input audit](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-v-Llama-01/References/input-audit.json), [independent live review](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-v-Llama-01/LIVE-REVIEW.json), [independent scoring](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-v-Llama-01/INDEPENDENT-SCORE.json), and [case-level CSV](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-v-Llama-01/case-results.csv) preserve that boundary.

## Saved builds and running again

[Build0006](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/0006-prime-swift-variable-depth-4000/BUILD.json) and [Build0007](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/0007-prime-swift-variable-depth-8000/BUILD.json) contain their own exact weights, native executable, metallib, source and result binding. The older Llama model remains in [Build0002](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/0002-older-llama/BUILD.json). These are experiment IDs, separate from installed application Build22.

From this directory, verify the saved bytes without running a model:

```sh
/usr/bin/python3 Runtime/verify_snapshot.py
```

To execute the fixed main suite again, supply a new absolute output directory:

```sh
/usr/bin/python3 Runtime/replay.py /absolute/path/to/a/new-comparison
```

Replay uses the retained local runtime and model paths in RUN-CONFIG.json, needs this Mac's Metal access, and saves fresh raw results. It does not replace this run or silently transfer its review to a later run. Direct native requests can also be sent to each build's Runtime/Prime10MInference; its schema is documented in Source/README.md.

The retained three-seed domain-policy trace checkpoints are the next broader comparison candidate; their locations and mixed historical results are saved in References/native-readiness.json. They have not been relabeled as passed, retrained, or substituted into these results.

The commands above are run from the saved comparison directory: `/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-v-Llama-01`.
