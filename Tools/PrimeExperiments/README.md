# Durable model experiment sources

Source snapshots for the five EPM-20260908 local builds. The build collection includes copied model/tokenizer assets and runnable binaries; this directory tracks the small reusable drivers and the exact shared cases in Git. No source here trains a model or routes through PMHNP’s reference-answer replacement.

- `native-main.swift`: static-linked Swift model loader/generator for the existing PMHNP, English compositional and Latin profiles; exact tokenizer identity and adjacent model-lab.
- `run-native-text.rb`, `run-llama.rb`, `run-prime-symbolic.rb`: explicit-input launchers. In a packaged build these are named run.rb and use its Runtime directory.
- `controller.rb`: previously exercised bounded process/stream controller with exact child reaping.
- `prime-symbolic-infer.py`: the retained Prime10M fixed-symbol two-pass inference implementation; no English tokenizer or gold target injection.
- `questions-only.json`: identical source-derived questions for text models. `cases.json` keeps the separate expected-answer/source references used only by review.

The build collection README records output caps, actual outcomes and the installed macOS/Command Line Tools dependencies. Native app Build22 and prior stages/gates remain separate. Model weights are copied into durable local experiment builds, not committed to source Git.

The `Expanded` directory retains the additive larger-output runtime, same nine questions, game source references and actual CPython coding checker. These are checkpoint diagnostics; the requested Prime-plus-execution-runtime comparison remains open. No hypervisor guest was used for generation.
