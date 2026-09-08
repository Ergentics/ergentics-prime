# Prime arithmetic tool

A runnable connection to algebra-app's existing math engine. It evaluates explicit arithmetic expressions and reports the result as **Algebra engine output**. It does not load a model, interpret a natural-language question, or claim that algebra training was transferred into Prime weights.

From the Prime repository:

```sh
swift run --package-path Tools/PrimeArithmetic --jobs 2 PrimeArithmetic --expression '2 + 2'
```

The executable accepts up to 128 ASCII characters containing numbers, decimal points, arithmetic operators, parentheses and spaces. It returns a JSON result including the expression, numeric value, engine identity and source hash. Unsupported input, a denominator with magnitude at most 1e-12, or a non-finite result exits unsuccessfully. The current adapter uses Double evaluation; it does not claim general exact rational arithmetic.

`Sources/PrimeArithmetic/Math.swift` is an unchanged source snapshot from algebra-app, pinned by `source.json`. The small command-line adapter lives here; algebra-app remains the owner of the engine. This package has no external dependencies and does not change Prime's root package, model runtime, previous gate evidence, or installed app.

This is the intended placement: **Prime interface → explicit math tool → algebra-app engine**. Prime Git tracks source and experiment evidence. A future app adapter should display the tool's identity and keep its result distinct from raw model output. An LLM could request this tool, but that routing is not implemented by this package.

The [checkpoint comparison](../../docs/experiments/2026-09-08-checkpoint-comparison/README.md) separately records the actual native PMHNP and older Llama responses. Generating algebra exemplars, training on them, and calling this engine are three different operations.
