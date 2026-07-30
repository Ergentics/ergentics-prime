# Prime native full-corpus transplant replay evidence

Canonical local execution date: 2026-07-30 America/Los_Angeles

Outcome: `PASS`

Claim scope:
`source_pinned_full_swift_corpus_generator_transplant_replay_only`

Prime source revision:
`e17d031af4ec48b644a326646da7bcb8ce24388d`

Prime source tree:
`3f061674b652cca9cbc2429dc44c85a3aa803665`

Prime source identity SHA-256:
`d13a817e2918e94972174b78eb1372dd0d4395161fca08b63850e7c2bfbbb08f`

Companion source revision:
`163fc100710ece48119bc25954452d10f6a84f7f`

Companion source tree:
`9009daa4f8a07fbd5897e00b9571cef44ec292db`

Canonical receipt:
`prime-native-full-corpus-replay-receipt.v1.json`

Canonical receipt byte count: `2,965`

Canonical receipt SHA-256:
`88d243827c1aff0ce8125402f84c4ffe4012d058dedaf88f614099e975dafdc2`

Incomplete probe candidate:
`corpus-replay/probe-candidate.v1.json`

Candidate byte count: `2,011`

Candidate SHA-256:
`a9319a41b436075523c4ace314233f69370af1917725e1caea91ed36409a292f`

Probe observation:
`corpus-replay/probe-observation.v1.json`

Verifier observation:
`corpus-replay/verifier-observation.v1.json`

Each observation contains `12,909` bytes and hashes to:
`520b9669d61d414463cccde512d39f9d631fae1ef6f44062aaf940e72f35fcb1`

Historical tokenizer manifest:
`corpus-replay/prime-native-byte-tokenizer-manifest.v1.json`

Tokenizer manifest byte count: `4,790`

Tokenizer manifest SHA-256:
`5e3db93d26535cbb66b14f0170b1e04882aa942560af3c8b571d76dfaaa9f302`

Historical corpus manifest:
`corpus-replay/prime-native-text-corpus-manifest.v1.json`

Corpus manifest byte count: `44,803`

Corpus manifest SHA-256:
`fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031`

The source-sealed Swift Release probe ran as process `39320`. It regenerated
all eight splits and all `155,648` rows, regraded all `155,648` rendered rows
through the embedded text parser, reproduced every frozen donor aggregate,
and published only an incomplete candidate. Its output explicitly recorded
`receiptPublished: false`.

The separately invoked Swift Release verifier ran as process `39373`. It
revalidated the candidate and bound artifacts, recaptured the exact clean
source identity and its own Release executable, repeated the complete corpus
generation and regrade, required byte-exact equality with the probe
observation, derived `fresh_process_replay_exact: true` from the distinct
positive process identifiers plus that exact replay, and published the final
receipt last.

The two exact donor source files remained byte-exact:

- tokenizer: `9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721`;
- corpus and embedded regrader: `4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210`.

Before source freeze, the complete Swift suite executed `258` tests with zero
failures. Two existing opt-in tests were skipped by the default suite: the
large sparse-artifact test and the live pinned-companion transport test. The
full production package then built successfully.

The pre-publication audit also closed three mechanics defects:

- a same-process caller can no longer mint a fresh-process claim;
- absolute artifact roots are opened component by component with
  `openat(...O_NOFOLLOW)`, with only Apple's fixed root aliases normalized; and
- ordinary data publication reuses held-descriptor reclamation and never
  unlinks a potentially rebound temporary pathname.

This compact repository evidence includes the candidate, both observations,
both historical manifests, final receipt, and raw phase summaries. The full
local descriptor root also contains the exact source snapshot and the two
Release executables. Those larger files are omitted from the repository
archive because the source is durable at the pinned Prime revision and the
receipt binds their exact identities.

This result is deliberately narrow. The embedded parser shares semantic
evaluator structs with generation, so this is a same-implementation semantic
regrade, not an algorithmically independent scientific oracle. It publishes
deterministic aggregates rather than physical row shards. It does not execute
a model or NeuralKit, train, quantize, establish language capability, or
authorize product use.

The tracked compact artifacts may materialize as mode `0644` after checkout,
while the canonical local root published receipt-bound immutable data as mode
`0444`. The compact archive is not a substitute for the complete descriptor
root. A future canonical rerun must use a new empty mode-`0700` root and the
same source-sealed Release protocol rather than weakening verifier checks.
