# Actual checkpoint comparison, September 8

The earlier native PMHNP lab_v2 checkpoint ran through its original Swift/Metal decoder and matching 8,192-token SentencePiece model. It produced unrelated fragments for arithmetic, the capital of France, and the PMHNP abbreviation. The older Llama-based PMHNP checkpoint answered those three questions correctly. English compositional and Latin checkpoints were also run as distinct diagnostics.

[result.json](result.json) retains all 12 generated outputs, the native token IDs, checkpoint/tokenizer identities and successful process completion records. All runs were offline, sequential and capped at 32 new tokens; no training occurred. Different vocabularies and prompt formats mean this is a saved-pipeline experiment, not an isolated tokenizer comparison or broad quality ranking. The native driver links retained original debug libraries rather than claiming a fresh rebuild of the latest source HEAD.

The English compositional tokenizer maps fixed symbols to `ABSTAIN` and `Result:`. The model selected those symbols and the following bytes; no answer was supplied by a question-matching rule. The original `Answer:` separator was tested separately and made both questions produce `Result: -1.`.

Build 22 was not used for these experiments. Its installed Stage 7 mechanics checkpoint remains unsuitable for the intended language demonstration. The proposed Llama app integration was stopped and removed; no replacement was installed.

Algebra-app's current source contains a deterministic math engine and an exporter of algebra examples, not a saved neural checkpoint. The new [PrimeArithmetic tool](../../../Tools/PrimeArithmetic/README.md) makes that engine callable from this repository. This supplies a useful math capability without claiming cross-model training transfer. The historical shared-inference plan in the companion repository is explicitly marked inactive as of July 27; it is not proof that the tested checkpoints share training.
