# Next: retained domain-policy checkpoints

All three original seed checkpoints and their complete manifests are present and hash-verified. Their native inputs need at most10tokens, and direct plus trace requires four inference jobs. No new training or tokenizer is required.

The current guest ABI needs two concrete extensions before these runs: the final job must consume both earlier summary predictions, and feedback must preserve original full-vocabulary semantics, including summaries128–163 and ABSTAIN224. The existing Z8-only eight-value predicate must not silently filter those predictions. A bounded two-source feedback binding is the next implementation step.

Keep the original manifests and three-seed scope. Do not substitute teacher/gold summaries into the continuation. [Exact evidence and required changes](References/NEXT-DOMAIN-READINESS.json).
