# Expanded checkpoint diagnostics — September 8, 2026

All four saved text checkpoints received the **same nine underlying questions**: five unchanged Ergentics-source questions, two supplemental coding questions, and two positions derived from the actual Ur/Backgammon rules. **36 native inference processes completed**, with exact reaps, complete captured streams and no remaining owned process-group members. This extends the original 33 retained runs.

The primary user objective is **Prime with its runtime and execution capabilities versus Llama**. These are diagnostic checkpoint runs; they do not establish that combined-system comparison. The saved Prime10M symbolic model has no text codec. The native English compositional checkpoint is a separate narrow diagnostic, not a substitute for Prime. No hypervisor guest or app HypervisorModel controller participated in these generation runs.

| Saved checkpoint | Five original questions | Coding | Ur and Backgammon positions |
| --- | --- | --- | --- |
| Older Ergentics Llama fine-tune | Four correct; Christoffel word confused with Christoffel symbols | Both generated functions passed actual CPython: 15 and 12 vectors, matching the restricted interpreter | Both wrong, despite reaching EOS |
| Earlier native PMHNP | Unrelated clinical fragments | No function generated | No matching answer |
| Native English compositional diagnostic | Incorrect Result outputs | Result: -1. for both, not functions | Result: -1. for both |
| Retained ten-step Latin diagnostic | Spaces on these English questions | Spaces | Spaces |

The two correct Llama functions were extracted from a single enclosing Markdown fence without editing their code. Functional correctness and strict code-only instruction compliance are reported separately. [Actual code and checks](coding-results.json) retain 27 CPython vectors, input preservation, fresh-list behavior and interpreter agreement. The other responses were not executable functions. The original metadata-only checker correction is retained alongside the current receipts.

Native output is no longer capped at32 tokens. Each run requests512 output tokens; the native models can generate only within their actual512-token total context, so the effective budget is512 minus the complete encoded prompt. The input is never truncated. Llama receives its saved chat template and512 output tokens. Token counts are not equivalent across these different tokenizers. Every generation records its exact input tokens, output tokens and EOS/context/caller-cap stop reason. PMHNP and Latin exhausted context; English ended on EOS after2–7 tokens; Llama finished except the wrong-topic Christoffel response, which hit512.

Reference answers and coding test vectors were excluded from every model request. The game answers were computed separately by compiling the original UrKit and BackgammonKit source; their harnesses, source hashes and raw results are in References. PMHNP's application reference-answer display fallback was bypassed. Nothing was trained or installed into Build22.

[All outputs](results.json) · [Same nine questions](Inputs/questions-all.json) · [Independent execution readback](results-review.json) · [Game source connection](games-audit.json)

To run a new question independently, use a saved build's `Revisions/expanded-01/run.rb --prompt TEXT --output FRESH_ABSOLUTE_DIRECTORY` from Terminal. Keep the whole build collection together. Native Swift revisions include their copied model/tokenizer assets; Llama uses the base build's saved model and shared Python. Execution uses the Mac's Metal GPU and system dependencies, not a hosted inference API. Existing source paths and commit identities remain in the receipts; copies are not de-identified.

These selected cases are diagnostics, not a general coding, language or research benchmark. No claim of unseen training data, equal training exposure, or equal compute is made. All originals and prior failures remain saved.
