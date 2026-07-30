# Prime native full-corpus transplant and replay

Date: 2026-07-30

Status: source contract implemented; no canonical outcome is claimed here

## Decision

Prime is implementing the next prerequisite from the native-contract
compatibility plan:

`source_pinned_full_swift_corpus_generator_transplant_replay`

This is a Swift-owned corpus/regrade-authority and deterministic-replay gate.
The fixed `/usr/bin/git` transport is used only to observe source state; no
shell or Python process is corpus, regrade, or scientific authority. This is
not model execution, a training run, NeuralKit integration, quantization,
language-capability evidence, or product authorization.

The gate must:

1. compile the exact historical tokenizer and corpus source blobs inside an
   isolated Prime target;
2. regenerate all eight declared splits and all 155,648 rows;
3. compare every declared count and aggregate hash with frozen historical
   values, rather than accepting a merely self-consistent new corpus;
4. invoke the embedded text regrader for every row;
5. bind the positive probe process identifier into the incomplete candidate;
6. reject a verifier whose positive process identifier is absent or equal to
   the probe identifier before replay or verifier-artifact publication;
7. repeat the complete replay in that distinct Release verifier process; and
8. publish the final receipt only after the two observations are byte-exact.

No physical row shards are published in this slice. The source-bound generator
is losslessly replayable, and the receipt binds the distinct positive probe
and verifier process identifiers together with byte-exact ordered per-row and
per-regrade aggregates. `fresh_process_replay_exact` is derived from both
facts; it is not an unconditional receipt constant. Physical immutable shards
remain a later trainer or external-audit boundary.

## Exact source boundary

Companion commit:
`163fc100710ece48119bc25954452d10f6a84f7f`

Companion tree:
`9009daa4f8a07fbd5897e00b9571cef44ec292db`

| Role | Donor path | Git blob | Bytes | SHA-256 | Prime policy |
| --- | --- | --- | ---: | --- | --- |
| Tokenizer | `prime-runtime/Sources/ErgenticsPrimeRuntime/PrimeNativeByteTokenizer.swift` | `27f5d4f61864499027d3e65516ae4c5cfe1ff5d1` | 21,320 | `9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721` | byte-exact source |
| Corpus and embedded regrader | `prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift` | `b2a087c9410a71f2bc99debade752ff779d7a8a8` | 177,032 | `4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210` | byte-exact source |
| Consensus-seed lineage | `prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift` | `027a25b49dde1acfb4cd8af970e05ecd8241f427` | 216,815 | `8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f` | explicit three-integer bridge |

The two-file donor set does not compile by itself. The corpus reaches
`ErgenticsNativeLanguageCanary.frozenSeeds`, whose full compile closure would
pull 441,453 unrelated bytes of scale recommendation, run configuration, and
executor failure policy into this bounded corpus gate. Prime therefore keeps
the two intended files byte-exact and supplies only:

```swift
ErgenticsNativeLanguageCanary.frozenSeeds == [1618, 2718, 3141]
```

The replay plan independently requires equality with
`PrimeNativeEvaluationContract.frozenV1.multiSeedConsensusSeeds`. These values
are evaluation metadata; they are not corpus-generation entropy.

The historical corpus manifest names the companion implementation path. Prime
preserves that field to reproduce the exact historical manifest. Actual Prime
execution is bound separately by the Prime source snapshot and the exact
probe and verifier executables.

## Golden artifacts

| Artifact | Git blob | Bytes | Whole-file SHA-256 | Internal manifest SHA-256 |
| --- | --- | ---: | --- | --- |
| Tokenizer manifest | `c2661016dd5a3af21fd6a998f286184ebdd7a196` | 4,790 | `5e3db93d26535cbb66b14f0170b1e04882aa942560af3c8b571d76dfaaa9f302` | `f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7` |
| Corpus manifest | `a01344ad4105d755cfd97324092b15a1b31dc542` | 44,803 | `fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031` | `7f42e6f0504e3751fca24bcce35f17fa361b4efcbd577f679fff7577f3e98ba7` |

Global ordered-corpus SHA-256:
`db7c62b9f1297c5b4fe020053548d1fdc46fde69b37cf59d4d822d01d0c1fb65`

Falsifier SHA-256:
`95d3241959b02b4a4cc57aa824078150f3059811f2e7745d84b7e8e16d3e104a`

Canonical full-replay observation SHA-256:
`520b9669d61d414463cccde512d39f9d631fae1ef6f44062aaf940e72f35fcb1`

Required global counts:

- eight splits;
- 155,648 rows;
- 155,648 unique sequences;
- 155,648 unique semantic combinations;
- 38,506,757 sequence-token instances;
- 62 observed token types; and
- maximum sequence length 512.

## Frozen split identities

Each row below records:

`split | rows | ordered rows | ordered evaluation rows | semantic set | prompt set | sequence set | embedded regrade`

```text
train | 131072 | c03b316f571f101ca45b75c440c83b6b0a264f9ced73ba96a61bbaf65a9e9813 | 248461a1bd27fd289df677ec98e0fe13bcf94df8be7affec72345752c8e02493 | c1fa09804d89733aa818b51e9079d4fdea3002297d5e365c3541caf6304fb6a0 | 7e9694c6b8d62c6e77630389c24ed984816d891730cf693bcbdd8e2f6e3650ef | d7259ac8f558f574ecc75464f9f3678d3da2100abec5fc9404365dd9974f517f | 82da3e4164bbab0a01d931b015f1d3cff41ad95c861fefc1f3cccc48ccafd906
refusal_train | 4096 | 699dfe19924f09d15e3e0cd6fac1c511813d1223592a86b7a577095327011359 | d37679915d36aa9fde3da88a737d988b59ef8326096a9ada46abb3bf537d3410 | 40599a219f4ee69dd1ae1e28ff9c8b74952b2605c12f6c4a1db9d293c4612c3d | f219ba49ede0247f16e58ce96800176ef664d5f35b93d81b77c492a7985d6c49 | 7ce0e2d87c0acf3192895bb297fdd1f2148fe56f23b0b5261152d2c4ca59ad3e | d85f3c36e37faafdabacc9d322ce805412aa4a57654c14e414d6c0ac386e20be
validation | 4096 | b113836b0f299acd60d9390948bb1cdc163478973a15953f05b7035e26ccf24b | 8d1da3aa5923078f95cf4389364dba9e7554fd69afbf8807ffdb13f429a11f6b | 34d7925a5f51f692d9c3803faf72f8e44024d458379187ef66d8419c4b772eb3 | 7f15781c4fcb5d6c79a0b6c41d0c08ef73cfba6e74d22a5e4d946ebfc19d5043 | 1944ef76a5754a7995cfd9d5bc0db163c06ab09c0ed99a3a0b8c952654aecd22 | 99c9eaec0aed1445a4193bf3511be75e1d20d491bf19af5332feb90d417d5a26
refusal_validation | 2048 | 51482b1b7eb8bd0d4afeed7e153a7e866220778ba76d6521bcb59251a4cfc567 | 05f476eb53486f45241a871bd35ea3467de8ea9c39e7e18b4eaec3a15986272b | a83a624c4cbad88665bb3363dc8d30019ab168c59be19ac850bcbca89a6aca5d | 592269ca87c03531602a980937ee01b01bf6ad27792dd2c76cdf941f6d73c1a1 | 7c63ccd5c8b717ed308e0547bac820123b891c476e79ad771eb8a6b6cefec675 | 4181e7fb1628a922bf3515afa49a4e95c41ac1db35ce85a1ad01749e7018572d
combination_holdout | 4096 | dc087b4ef26e7b43d86e3982a067f128abda150f456941509cca2ca60ccbe810 | f1cfbeccf8daacbee95689fb46ee00395cada3d6dee3eafe6e838fca69dd4d4a | 3bf449d7bd5131a91cd6445200642a0c9cc4ddc3970edcfaf13e53881e5a41ef | a10c3eb643d14f54f1c7a2a330fac3117bb0bf593fe2c6b34d6ff6b9a54cef44 | fb9463d8f782e833253386d2d78108a120ee9c691e2434757a1885bb2f9e7f19 | 92f008acb09e94b2d30a0dc1283d323261072c47a4e6c1e1dc7bd041978e2732
ood | 4096 | 5ec1b747579a985637c30ff6c880f50668eddd0203bec0f580f78f30fc3edeea | 82f5c29dc6cb50c23a661838adf45157840aef0cdefae6a1eb82f56862c100db | 58bff8b5be51d10d0004a5c5712472c1e5bcfdc635fb5c61757c3fdd1cda965c | 1a52f78d5262280c94ea6872e210a1b0d6a99d26aead85eac7bdcef7873e78ef | d4f7c4a48dc9a0c4d7c1eccc0f448cca16d61844c71285783ef6f3697f3b0b92 | 0c8da4892e3cb7483886f2f48386680fa214f9c93da424057acd36df8e515f42
mutation | 4096 | 5c7700ea8e52a61dcdb07b1b148c0993c2541b3e23c28801250ed08c2c6c9391 | f2a043157e70725f91d9d1126f22ec2dbfc011c32650e778e41054b4b7e290b5 | 40f2411445180c15c8dea0005aaa906746fd0974c1a5b60d8390eb59c059fa94 | c8cbfc219371f30de7f05d6deca46ad91429942c38b6203a5962d04e7e1231ef | e02be8198569d23fb222a12ab229c8105edcee984fd41294b4ae4f63deb611c3 | 150161a3c63194e1ad3807dd8692b51431aca59ce1be68da3a229e7d1bed2199
abstention | 2048 | bd63a9592b03a5493de0b67036dce027031f239fa692f3d588272be807d7135f | 17e999ba61f0380e6ae1f91b944b75f48537d36d425e916372d18aeb4f24b684 | 12dd719ebada4e1691d86324d55fc46e956acd283bea6ad4480150de8363a35e | 9072066b3d6d85c771dcdc3ee8eb435e581e66957c033afce52c50a9e07122c9 | 59dd9308b4c3d9d273db74e106ce3babdf0da4e2a5b28cafff641283dcbd2637 | 604fcb2aa939a3a8fb932a33f8c4e5398d9d087e179d60186932f39237a8cee8
```

Every split must also have unique prompt, sequence, and semantic counts equal
to its row count and `all_rows_independently_verified: true`.

## Leakage, refusal, and mutation gates

The replay fails closed unless:

- train/evaluation prompt and semantic overlap are both zero;
- refusal-train/evaluation prompt and semantic overlap are both zero;
- refusal-train/final-abstention contract overlap is zero;
- train/combination pair overlap is zero while the three component codebooks
  and three surface forms are each observed in training;
- train/OOD codebook and surface intersections are both zero;
- all row IDs and row hashes are globally unique;
- all valid semantics are disjoint across splits;
- refusal train/tuning/final counts are exactly 4,096/2,048/2,048;
- all seven refusal reasons are taught while prompt, semantic, and
  reason-plus-mutation-plus-surface contracts remain pairwise held out;
- all mutation rows preserve their parent bindings; and
- all ten historical falsifier families detect their target mutation.

The Prime replay additionally mutates representative serialized rows and
aggregate observations. It must reject changed prompt or completion material,
changed split or parent identity, refusal-reason drift, missing or duplicated
rows, changed order, changed hashes, and a false manifest verification flag.

## Verifier limitation

The historical `NativeIndependentTextVerifier` is private and embedded in the
corpus blob. It parses rendered text independently of the generator's render
path, but it reconstructs and evaluates the same private scalar, transfer,
ordering, and relation program types used by generation.

Accordingly, this slice may claim:

- every row regenerated;
- every row regraded through the embedded parser;
- exact frozen aggregate replay; and
- separate-process determinism.

It may not claim:

- an algorithmically independent semantic implementation;
- an independent scientific oracle;
- the full NeuralKit Verify/Abstain gate;
- model capability; or
- product eligibility.

## Publication protocol

The Release probe begins only in an empty mode-`0700` Prime artifact root. It
publishes immutable source, executable, manifest, and observation bindings,
then an explicitly incomplete candidate. The candidate states that it is not
a receipt and cannot encode `PASS`.

The separate Release verifier:

1. decodes the candidate and rejects a missing, non-positive, or same-process
   identifier before verifier replay or publication;
2. descriptor-validates the candidate and every bound artifact;
3. recaptures the exact Prime source identity and its own executable;
4. regenerates and regrades all 155,648 rows;
5. requires byte-identical probe and verifier observations; and
6. derives `fresh_process_replay_exact` from the positive distinct identifiers
   plus that exact replay, then publishes the final receipt last.

Any divergence leaves no final PASS receipt.

Canonical invocation:

```zsh
.build/release/PrimeNativeCorpusReplayProbe \
  --prime-root "$PWD" \
  --artifact-root "$PWD/artifacts/native-full-corpus-replay-canonical-2026-07-30"
.build/release/PrimeNativeCorpusReplayVerifier \
  --prime-root "$PWD" \
  --artifact-root "$PWD/artifacts/native-full-corpus-replay-canonical-2026-07-30"
```

This source-hashed document deliberately does not claim a canonical result.
The `PASS` or `ABSTAIN` result, exact source revision and tree, receipt
SHA-256, and compact replay outputs must be recorded after source freeze in
the repository-durable evidence note at
`artifacts/native-full-corpus-replay-canonical-2026-07-30/README.md`. If that
note is absent, no canonical outcome is recorded.
