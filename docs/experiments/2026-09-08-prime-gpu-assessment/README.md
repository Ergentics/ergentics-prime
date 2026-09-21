# Prime GPU assessment and retained text-model detour

Prime is the active GPU target. OS selection is parked at the user's request. No further text-model GPU code-generation runs are planned.

## What already works

Runtime 0009 runs retained Prime domain-policy weights in native Swift/MLX under either host or real ARM guest control. The guest requests inference, receives actual model predictions, and inserts earlier predictions into later inputs. The weights and neural computation reside on the host. These first-party Prime checkpoints use a Llama-compatible architecture; they are distinct from the older Llama fine-tune and Native English checkpoint.

Runtime 0013 adds a typed guest-to-Metal geometry service: it returns potential and gradient vectors to the guest, which checks every returned float's bits. The saved run measured 24 host/guest pairs, 5,592 returned guest floats and 48 measured GPU dispatch timestamps. All paired vectors matched exactly. This implementation was written by Codex and executed by the native runtime; no learned model generated its code. It is a real compute offload service, not a complete virtual graphics device or bootable guest OS.

The runtime 0009 and 0013 services are presently separate executables. The productive integration direction is one Prime service for learned inference and numeric GPU operations, with the existing guest feedback and vector checks retained. Asking a text model to write GPU code is not required to use either working route.

## Additive Prime measurement implementation

Runtime 0014 explicitly scopes Prime's original model and guest callbacks to one MLX GPU stream. It separates graph construction, evaluation/synchronization, float readback, scoring, encoding/hash and logits persistence. These are synchronized host wall-clock intervals; they are not GPU hardware command timestamps. The existing runtime 0009 interval included file persistence, so it could not honestly be labeled isolated inference or GPU time.

The small regression uses the first two retained cases from batches 000 and 058 for all three Prime seeds, in host and guest modes. It performs 96 real model forwards across six serial processes, with 12 guest VMs and 60 guest entries. Raw logits are checked against both the opposite execution mode and runtime 0009's saved results. These are regression inputs, not new training or novel generalization evidence. PrimeLiveReview/REVIEW.json records the actual outcome. Source, compiler/signing records, signed executable and mlx.metallib are retained in ../0014-prime-model-gpu-timing/.

This timing change does not merge the geometry service into the inference executable or expose either through the installed app. It establishes a measurable Prime model route while preserving the working components.

Replay a small pair of runs with `python3 Runtime/replay_prime.py /absolute/fresh/results --seed 1618 --execution both` from this saved assessment. Add `--seed all` for the complete six-process regression. The replay uses the signed durable runtime and retained local checkpoints, serially, with no training.

## Retained detour: actual novel request

All three text-capable checkpoints received exactly: “Design a GPU interface for an ARM64 virtual machine. Give a minimal guest request, host implementation approach, and a way to verify returned numeric results.” No reference answer was supplied.

| Checkpoint | Canonical adapter result |
|---|---|
| PMHNP native, learned SentencePiece | Repetitive clinical fragments; stopped at the remaining 464-token context limit |
| Native English compositional_v2 | `Result: -1.`; EOS after 7 tokens |
| Older Ergentics Llama fine-tune | Relevant outline and illustrative C; EOS after 1,749 tokens |

Initial 256-token diagnostics and the original 512-token adapters are retained, including the unframed Native English `ABSTAIN` output. The final Llama attempt allowed 2,048 tokens and reached EOS; its first 512 generated token IDs exactly match the shorter run. All seven runs retain raw token IDs, text, exact requests, model/tokenizer bindings and process completion receipts. Independent review verified those joins and reconstructed emitted text from the tokenizers. No oracle substituted an answer.

The single C fence was extracted unchanged and compiled with clang. Compilation exited 1: incomplete enums, undefined types and other invalid fields. No object was produced and no generated code executed. It is retained as failed proposal evidence, not promoted to a runtime build. Prime's symbolic domain checkpoint received no arbitrary English request; this detour is not a test of that checkpoint's GPU execution.

## Logic and OS boundaries

The inspected ergentics-logic checkout contains corpus/oracle tooling and an MLX inference path, but no local trained weights or matching trained tokenizer assets, and no guest GPU binding. GPU-related corpus rows do not create an execution interface. This request was not sent to an ergentics-logic learned runtime.

Ergentics-CEO is a management app that reads an organizational ERGENTICS-OS.md guide. It does not supply a bootable OS. Provenance has a separate ARM64 UEFI Linux VM configuration with a user-selected installer; that VM is not connected to these bare-metal compute helpers. OS selection and independent OS attestation remain parked. Installed app Build 22 was not changed by these experiments.

NovelRequest/ contains the raw runs, exact failed C proposal, compiler logs and independent review. LogicReview/ and CEOReview/ retain the source-bound audits. Existing sealed runtime and model builds remain unchanged; no training or dependency installation occurred.
