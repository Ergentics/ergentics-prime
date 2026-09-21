# Prime domain inference, guest feedback and geometry Metal

Three retained Prime domain-policy checkpoints now run in native Swift/Metal with either host control or actual ARM vCPU control. ABI2 carries two earlier model predictions into the final input. Every prediction is a full-vocabulary neural argmax; scoring labels remain separate. No training occurred.

The complete original evaluation contains 470 holdout and 470 mutation cases per seed. Host and guest agree byte for byte on all 11,280 paired logit vectors. Both summary steps are correct on all 940 cases per seed. The direct and final predictions also match every corresponding historical Python result.

| Prime seed | Direct correct / 940 | Stepwise final correct / 940 |
|---|---:|---:|
| 1618 | 812 | 888 |
| 2718 | 860 | 879 |
| 3141 | 822 | 886 |

Across both execution modes, the run completed 22,560 model forwards and 2,820 VMs with 14,100 guest entries. The independent reviewer verified every retained logit hash, finite value, unrestricted argmax, probability and feedback source. Original Python versus Swift probes agree on all 192 predictions; their maximum logit difference is 0.000003814697265625. These first-party Prime weights use a Llama-compatible architecture, but are distinct from the older imported Llama fine-tune.

`ABSTAIN` is model token 224 in this finite language. On the original evaluation, every such prediction occurred on malformed input; no valid input produced224. All three seeds abstained on all 64 malformed final questions. Seed1618 missed one malformed direct question. The original three-seed report’s separate overall `ABSTAIN` decision remains unchanged: repeating its predictions does not revise its original promotion criteria.

## Requested generator follow-up: n = 1024

Each Prime checkpoint completed 1,024 valid generated cases in both host and guest modes. Any token 224 on this valid-only set would be an unexpected abstention. There were none across any of the four steps.

| Prime seed | Direct correct | Stepwise final correct | ABSTAIN per execution |
|---|---:|---:|---:|
| 1618 | 966/1024 | 986/1024 | 0/4096 |
| 2718 | 958/1024 | 970/1024 | 0/4096 |
| 3141 | 953/1024 | 1008/1024 | 0/4096 |

The expansion toggles only the original generator’s supported neutral CONTEXT4 marker. All 1,024 complete input arrays are new exact combinations, but all 1,024 semantic requests are reused:614 original training, 205 validation and 205 holdout rows. Both component summary inputs already occur in training for every case. This is context invariance evidence, not unseen-semantic generalization. It adds 24,576 actual forwards and 3,072 VMs. [Generation and overlap audit](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-Domain-03/Generator/INPUT-AUDIT.json), [full numerical review](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-Domain-03/Review/GENERATOR-NUMERICAL-REVIEW.json).


## Older Llama comparison

All 32 cases were selected by input strata and deterministic input hashes before scoring:20 valid and12 malformed, split evenly between holdout and mutation. Llama received the original policy in explicit English rules with its saved tokenizer/chat template. Its actual output was `128` on all 128 inference calls, including every final answer. Direct and final accuracy were each0/32; it produced neither numeric224 nor literal `ABSTAIN`. Both actual predicted 128 summaries were fed to the final step unchanged. Their equal bands have no defined conditional combiner rule in the frozen task, so that separate conditional grade is left undefined.

On those same32 inputs, Prime final accuracy was 30/32,31/32 and32/32 for seeds 1618,2718 and3141 respectively. This compares learned finite-policy execution with a fresh English rule prompt. It is not an equal-training or general intelligence benchmark, and it does not override the earlier plain-arithmetic results. [Exact raw examples](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-Domain-03/Review/examples.md), [complete comparison review](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-Domain-03/Review/LLAMA-REVIEW.json).

## Geometry component

The actual `geometry-app` host Metal field kernel was preserved and run on 200 deterministic points with 12 nodes. It passed all CPU potential/gradient and finite-difference comparisons. Maximum potential error was 5.362635326910947e-7 and maximum gradient error 5.100295865645421e-7. Fourteen malformed numeric inputs were rejected before GPU submission; the one valid dispatch completed without a CPU fallback.

The adapter adds finite bounds, command-buffer failure checks and output validation. Geometry’s repository contains no custom vGPU transport. Its float-vector results require a separate typed request/reply before they can be served through a guest; the current guest API returns a model token ID. This run establishes a reusable host Metal component, not additional neural geometry knowledge or a virtual GPU device. [Source and kernel patch](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-Domain-03/GeometryMetal/README.md), [live results](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-Domain-03/GeometryMetal/Live/native/result.json).

## Durable builds and replay

Runtime 0009 is the signed native ABI2 helper. Checkpoint builds 0010–0012 retain the exact original seed1618/2718/3141 weights. These are experiment build numbers; installed Provenance remains Build 22. The ARM guest controls progression and feedback while Swift/Metal computes the model on the host. Model weights are not inside the guest.

From this saved directory, execute a fresh offline run:

```sh
python3 Runtime/replay.py /absolute/fresh/results --seed all --execution both
python3 Runtime/replay.py /absolute/fresh/generated-results --suite generator --seed all --execution both
```

The replay uses the signed durable runtime and saved checkpoint copies, refuses to overwrite results, and runs workers serially with bounded process supervision. Compilation reuses retained local MLX objects; no dependencies were upgraded or installed. Six new ABI mechanism checks passed, separately labeled as fixtures. They establish two-source insertion, invalid-binding rejection, token 224 transport and invalid-second-binding behavior; they are not substituted model outputs.

Full input arrays, model/tokenizer identities, logits, generated Llama tokens/text, process receipts and independent reviews are retained here. [Native numerical review](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-Domain-03/Review/NATIVE-NUMERICAL-REVIEW.json), [Python parity](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-Domain-03/Review/PYTHON-SWIFT-PARITY.json), [file snapshot](/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-Domain-03/SNAPSHOT-INDEX.json). Earlier sealed builds and unrelated Prime work are preserved. No app replacement, upload or formal authority change occurred.
