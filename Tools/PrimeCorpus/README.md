# Prime connected sources

Executable source connectors and a repaired PMHNP record adapter, saved in the original Prime checkout. NeuralKit is reusable infrastructure; PMHNP remains one application/data profile. Existing checkpoints are preserved in separate durable experiment builds.

## Run

From the Prime checkout, supply explicit input and a fresh absolute destination:

```sh
ruby Tools/PrimeCorpus/connect.rb --registry "$PWD/Tools/PrimeCorpus/sources.connected.local.json" --output /absolute/new/candidate
ruby Tools/PrimeCorpus/connect.rb --registry "$PWD/Tools/PrimeCorpus/sources.neural-runtime.local.json" --output /absolute/new/runtime-connection
ruby Tools/PrimeCorpus/pair-pmhnp.rb --source /absolute/new/candidate/raw/pmhnp-companion-ergentics --output /absolute/new/paired-pmhnp
```

The registries pin existing file bytes and source revisions on this Mac. Relocate root paths only when their contents still match. The connector copies raw data and sidecars without treating every schema or negative label as equivalent. It never trains, replaces a tokenizer, invokes a model, or edits a source repository. Zero/missing arguments, changed pins and existing output destinations are rejected.

## What is connected

Nine repositories: algebra-app, geometry-app, music-theory-app, ergentics-logic, agentcraft-app, MasteryKit, pmhnp-rebuild, pmhnp-companion-ergentics and ergentics-llm. The base registry binds 155 files; the NeuralKit/runtime connection adds 16 code bindings within the same repositories. Large model weights remain in the durable model builds, not in Git source commits.

| Retained material | Actual coverage / handling |
| --- | --- |
| Logic corpus | All 47 exemplar files: 6,945 records; all nine decision files: 57 records; all seven audit sidecars. |
| Agentcraft | Full 890-row retained Christoffel export and three scaffold records. The 763 negative/no classifications remain intact; they are not automatically wrong-answer targets. The smaller promoted logic subset remains separate. |
| PMHNP | All 3,090 existing LM0 split rows, existing compositional exports and their manifests; current untracked generated files are labeled as such. |
| MasteryKit | Frozen engine, ContentProvider and TutorSession source. Actual current companion byte comparisons are recorded, rather than assuming every copy is identical. |
| Neural runtime | Shared loading/generation interfaces, native decoder/profiles, and explicit PMHNP framing/reference-substitution adapters. |

`pair-pmhnp.rb` preserves each full prompt and evidenceSpan together on ONE physical line. It retains the source split and excludes 195 training rows whose questions occur in evaluation: 2,268 train, 303 validation and 324 holdout. All 3,090 source records remain indexed/raw. Nine existing validation/holdout question overlaps are reported. The adapter adds no text truncation; it cannot restore text already cut by the original exporter. Actual matching SentencePiece encoding found no unknown tokens or over-512-token rows (maxima 219/228/199).

`stage.rb` remains the smaller math/music projection: 2,029 training and 527 held-out positive pairs from 22 selected files. Its declared family split is a new candidate policy; it is not an inherited historical logic execution. Both logic parsing families landed in its held-out set. All omitted corpus files remain available through the broad raw connection. This projection is not the complete Ergentics training corpus.

## Where the paths separated

`reconciliation/` contains hash-backed repository/data/model findings. The earlier PMHNP export reconstructs exactly from 2,463 records into 5,695 physical lines, but that profile's trainer treats each line as a separate training sample. Its saved model has 29,639,680 parameters and an 8,192-token PMHNP-only learned tokenizer. The larger 300M/1B/3B probes, the retained fixed-symbol Prime model and the older Llama model have different inputs and evidence.

The saved historical logic leaveout/retest recipes include later-rejected inputs; missing generated split sidecars are not reconstructed as successful prior runs. Mastery's EngineV21.swift matches current companion copies, while 13 of 17 SeatEngine files match the full frozen engine. See the actual byte-join table for the four differences.

These are connected inputs for continued work. No existing model acquired this corpus by being registered here. The next cross-domain training selection must state its actual data, record adapter, tokenizer, model output location and evaluation split.

Ur and Backgammon are connected by `sources.games.local.json`:162 additional bindings across two new repositories, existing logic game exports and independently executed rule references. The35 existing game rows are not new unique examples. This expands the connected repository count to11. No training or de-identification occurs.
