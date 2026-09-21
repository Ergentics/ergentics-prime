# Recorded domain-policy outputs

32 input-matched symbolic policy cases. Llama receives fresh explicit rule prompts; three Prime checkpoints were trained on this finite task. This is not equal-training or general model-quality evidence.

The quoted strings below are verbatim model outputs. Numeric format, task-symbol validity and reference correctness are separate.

## holdout-I-V-I-r0-e2-V-r3-e2

Source split: holdout. Reference IDs: `[197, 131, 148, 197]`.

direct (expected 197):

```text
128
```

leftSummary (expected 131):

```text
128
```

rightSummary (expected 148):

```text
128
```

final (expected 197):

```text
128
```

Final prompt feedback: `[{"jobIndex": 1, "predictedSymbolID": 128}, {"jobIndex": 2, "predictedSymbolID": 128}]`. Conditional rule: `undefined_equal_band`.

## holdout-I-V-I-r1-e2-V-r3-e2

Source split: holdout. Reference IDs: `[197, 140, 148, 197]`.

direct (expected 197):

```text
128
```

leftSummary (expected 140):

```text
128
```

rightSummary (expected 148):

```text
128
```

final (expected 197):

```text
128
```

Final prompt feedback: `[{"jobIndex": 1, "predictedSymbolID": 128}, {"jobIndex": 2, "predictedSymbolID": 128}]`. Conditional rule: `undefined_equal_band`.


## Malformed input and abstention

Case `holdout-invalid-24-holdout-I-V-I-r0-e1-V-r3-e1` has expected IDs `[224, 224, 154, 224]`. Llama returned the following exact output at every job:

```text
128
```

There was no numeric `224` or literal `ABSTAIN` anywhere in the Llama run. On this same case the native checkpoint outputs were:

- 1618-guest: `[224, 224, 154, 224]`
- 1618-host: `[224, 224, 154, 224]`
- 2718-guest: `[224, 224, 154, 224]`
- 2718-host: `[224, 224, 154, 224]`
- 3141-guest: `[224, 224, 154, 224]`
- 3141-host: `[224, 224, 154, 224]`

Here numeric `224` is the actual model-predicted task ABSTAIN symbol. These IDs were carried unchanged into the final input. Across the selected12 malformed cases, each native seed predicted224 for every direct and final answer. This is a finite symbolic task learned by these checkpoints; the older Llama was given a fresh formula prompt.
