# Prime safe first-party AI R&D charter

Status: internal research-and-development governance
Effective snapshot: 2026-07-29
Framework orientation: NIST AI 100-1, AI RMF 1.0
Review cadence: before a new executor, interoperability exception, sensitive
data admission, or publication decision, and at least quarterly
Repository status: private and proprietary
Scope: Ergentics Prime research execution and its bounded observers

## Purpose and claim boundary

Prime exists to find how far Ergentics can advance a first-party,
Swift-first learning system on Apple silicon without confusing an experiment
with a product, scientific result, safety proof, or regulatory determination.

This charter is oriented toward the safe, secure, and trustworthy posture of
the voluntary NIST AI Risk Management Framework and the earlier Ergentics
monitoring charter in
`pmhnp-companion-ergentics/docs/PMHNP-PRIME-AI-SAFETY-SCOPE.md`. It is not a
claim of NIST, AI.gov, federal, clinical, scientific, security, or regulatory
compliance. The NIST framework's Govern, Map, Measure, and Manage functions
are planning lenses; Prime's executable contracts and receipts are the only
evidence of controls actually implemented here.

The repository's current `LICENSE` is proprietary and grants no open-source
rights. Open-source code, publicly released weights, redistributable data, and
public evidence are four separate future decisions. None is authorized by this
document.

## Operating principles

1. **Verify, preserve, or abstain.** Missing, contradictory, stale, or
   unbound evidence produces `ABSTAIN`; it is not filled in by prose,
   generated values, or optimistic defaults.
2. **Swift owns Prime evidence.** Compiled, source-bound Swift validators and
   supervisors create and dispose Prime R&D receipts. A shell may launch a
   build during development, but it does not become scientific authority.
3. **Use maintained math.** Prime composes maintained MLX Swift
   differentiation and optimizer primitives. It does not hand-roll a second
   AdamW merely to cross an access-control boundary.
4. **Bind the supply chain.** Code, dependency revision, executable, Metal
   library, configuration, data, tokenizer, checkpoint, evaluator, and raw
   observations are distinct identities.
5. **Keep authority narrow.** A mechanics result authorizes only the next
   bounded mechanics experiment. It does not authorize long training, model
   quality, product use, or an external release.
6. **Independent disposal matters.** EnginePropose/Derive/Dispose can generate
   cases, derive declared expectations, replay observations, and dispose
   unsupported claims. It cannot certify its own proposal or replace a
   separately bound executable verifier.
7. **Make correction durable.** Invalid evidence is quarantined. A correction
   is a new immutable record that identifies what it supersedes; historical
   evidence is not silently overwritten.

## Authority map

| Actor or layer | Permitted role | Not authorized |
| --- | --- | --- |
| Prime compiled Swift supervisor and validators | Freeze a declared experiment, launch exact bounded workers, verify raw artifacts, run mutations, and publish immutable R&D receipts | Product, clinical, regulatory, or scientific authority beyond the receipt's exact scope |
| Maintained MLX Swift | Tensor execution, autodiff, and optimizer arithmetic under a pinned dependency identity | Ergentics experiment selection, evidence interpretation, or product promotion |
| EnginePropose/Derive/Dispose | Propose bounded hypotheses, derive declared expectations, enumerate mutations, replay, and reject unsupported conclusions | Self-certification, hidden parameter selection, claims of independence without a separately bound verifier, or conversion of an `ABSTAIN` into success |
| Codex and bounded development agents | Audit, plan, implement, test, and orchestrate work within explicit repository and release authority | Mint evidence from summaries, expose secrets or private artifacts, authorize costly runs, publish or disclose private work without explicit human authorization, or make product/scientific claims |
| Ergentics Workstation | Observe Prime receipts and, after a typed bounded adapter exists, request declared diagnostics | Own Prime evidence through today's free-form command runner |
| Logic, Algebra, Geometry, NeuralKit, MasteryKit, AgentContractKit | Donor or downstream contracts with separately audited boundaries | Implicit dependency or inherited authority merely because code exists elsewhere |
| Product consumers | Challenge an authoritative engine in a shadow lane after a Prime checkpoint and adapter are admitted | Treat R&D mechanics, local files, or a neural response as released product truth |

Workstation remains an outer observer today. Its safety routing, corpus
refusals, command allowlists, preflight, and run ledger are useful controls,
but its general process runner inherits an environment and does not yet bind a
Prime executable, runtime, resource budget, filesystem/network sandbox, or
complete raw evidence. String-classified policy is not an operating-system
security boundary. Workstation may own Prime evidence only after a separate
typed invocation and receipt-inspection contract closes those gaps.

## Implemented controls and open work

This table is descriptive, not aspirational. A control moves to “implemented”
only with repository-local code and tests.

| Control | Current state |
| --- | --- |
| Swift source and Release executable identity | Implemented and receipt-bound |
| Pinned dependency and MLX metallib identity | Implemented for admitted existing runtimes |
| Complete admitted MLX Swift package manifest/source tree | Implemented for `Package.swift` plus all `Source/**`; the exact private revision is remotely resolvable and authenticated cache-empty clone resolution was observed. `swift-numerics` is pinned but not separately tree-bound, so full transitive build-source closure remains pending |
| Instrumentation and loader checks | Implemented for admitted existing runtimes |
| Private descriptor-rooted artifacts, no-replace publication, pre/post verification | Implemented with a documented same-user concurrency limitation |
| Fresh role processes and observed PIDs | Implemented for admitted existing probes |
| Empty worker environment, stdin bound to EOF, bounded output capture, and observed timeout escalation | Implemented for the typed optimizer candidate |
| MLX mechanics/security-test process isolation | Implemented; an exact Swift stager supplies the isolated XCTest resource without weakening loader-shadow admission |
| Fail-closed `ABSTAIN` and immutable receipts | Implemented for admitted existing probes |
| General Python or shell scientific authority | Explicitly not implemented or authorized |
| Public typed Adam/AdamW state transport | Implemented in private derivative revision `68904d54b72871f26968261ae05d4fbb7c5e3142`; authenticated cache-empty clone resolution is observed, while public/upstream acceptance and CI credentialing are not claimed |
| Exact typed optimizer `N -> checkpoint -> fresh process -> N+1` gate | Canonical Release evidence bound to private revision `68904d54b72871f26968261ae05d4fbb7c5e3142` observed exact continuation across three fresh worker processes and disposed all 19 declared structural mutations; fresh full evidence root is repository-durable at `3481ffc` |
| Interrupted exact-3B two-step Metal resume gate | Operator-selected bounded mechanics gate; historical profile/scale verdict remains `ABSTAIN`; execution follows CPU evidence durability and byte-verification of only the four current Prime-owned exact-3B/CPU bindings |
| Corpus, tokenizer, model, and evaluator cards | Frozen companion/NeuralKit fixtures exist; exact Prime adapter and accepted checkpoint card remain pending |
| PMHNP companion dependency | Historical read-only migration oracle only; new Prime runtime and evidence stay in `ergentics-prime` |
| Full independent functional evaluator, statistical battery, triadic audit, SZ fingerprint, and mutation synthesis | Existing NeuralKit research-gate evidence is inventoried by the continuity plan; cross-repository resolution and real trained-checkpoint execution remain pending |
| SBOM, `SECURITY.md`, `CODEOWNERS`, repository CI, and release/signing policy | Pending |
| Off-device automation and artifact durability | Pending |
| Same-user adversary isolation | Not claimed |
| Network, privacy, and secret review for any future networked executor | Pending; current scientific executor must remain local and bounded |

## Swift-first implementation policy

Prime's training mechanics, experiment configuration, raw-record validation,
mutation disposal, and receipt publication are Swift-first. “Swift-first”
does not mean replacing maintained mathematical implementations with
Ergentics hand-rolls. It means that the authority-bearing path is typed,
compiled, inspectable Swift while maintained upstream libraries perform their
declared primitives.

Custom Metal work requires all of the following:

- profiler evidence identifying a material bottleneck;
- a frozen operation and numerical contract;
- at least one API-disjoint reference implementation;
- forward and, where applicable, backward and optimizer-integration tests;
- determinism, bounds, device, and metallib identity checks;
- a measured gain large enough to justify the maintenance and security cost.

A custom kernel is not an independent evidence family merely because it uses
different GPU code. It remains part of the same device and toolchain family
unless the comparison contract demonstrates otherwise.

The same rule applies to mutation machinery. The current typed optimizer
proposal/detector/disposal sweep is a same-process structural self-check. It
records that no independent scientific oracle is claimed. A later
learning-quality result requires a disjoint evaluator process and evidence
contract; relabeling a self-check as “independent” is not admissible.

### Swift ecosystem R&D horizon

Core ML and the preliminary Core AI framework are deployment/inference
comparators, not substitutes for Prime's training or evaluation authority.
Where Apple currently supplies model authoring, conversion, or optimization
through Python/PyTorch tooling, Ergentics may research a Swift-native path
only from public, licensed formats and APIs. Each candidate must:

- name the exact Python function or interchange step it intends to replace;
- preserve rather than reinterpret model semantics and metadata;
- compare against Apple's maintained tool on pinned fixtures;
- pass independent Swift loading, inference parity, mutation, and device tests;
- retain the maintained tool as an explicit fallback until the Swift path is
  demonstrably equivalent and supportable;
- avoid reverse engineering private frameworks or bypassing platform security.

This is an ecosystem contribution horizon, not a claim that a maintained Swift
authoring API already exists. A successful converter also does not promote the
converted model or make deployment parity a learning-quality result.

## Narrow Python interoperability policy

There is no general Python fallback and no pre-approved Python waiver.
Apple's maintained Core ML Tools authoring and conversion path is a Python
package, and current model-conversion guidance starts from frameworks such as
PyTorch. A future conversion, interchange, or diagnostic may therefore need a
per-tool exception even when Prime training and evaluation remain
Swift-authoritative. A different language or runtime is not itself an
independent oracle: the decision must declare algorithm, data, model,
conversion, and toolchain dependencies. The diagnostic is an independent
evidence leg only when those dependencies are disjoint enough for the exact
claim; otherwise it is a cross-runtime parity check.

Each exception requires explicit approval from the human repository owner
before execution. Codex, EnginePropose/Derive/Dispose, and other agents cannot
self-waive this policy. The approval must be a durable, committed decision
record bound to the exact tool/version, purpose, scope, owner, approval time,
expiry or retirement condition, and the following controls:

- the exact task that lacks a supported Swift primitive;
- interpreter, package, source-model, converter, and operating-system
  identities;
- typed or canonical input and raw output hashes;
- declared filesystem, network, credential, secret, and data access;
- a private working root, timeout, memory/compute budget, and output limit;
- preserved raw logs and artifacts without Python-authored Prime verdicts;
- an independent Swift regrade and, for deployment conversion, device parity;
- mutations that prove missing, malformed, substituted, or stale output
  fails closed;
- a retirement condition: adopt a maintained Swift path or contribute one
  upstream when practical.

Python can transform a specifically admitted artifact; it cannot silently
select training truth, mutate evaluation labels, summarize away raw output,
or mint a Prime `GROUNDED` result. If Swift cannot independently validate the
result, Prime remains `ABSTAIN`.

Do not create a general waiver registry before the first real exception. The
first exception should establish the smallest schema demanded by an actual
tool rather than normalizing hypothetical access.

## Source, model, data, and checkpoint provenance

“First-party” must identify the layer being discussed:

- Ergentics-authored Prime code and controlled corpus generators can be
  first-party.
- Ergentics-owned architecture semantics and an Ergentics-owned decoder
  implementation are separate claims. A first-party profile geometry over a
  third-party decoder implementation does not satisfy the latter.
- An Ergentics modification of `ml-explore/mlx-swift` is a derivative work
  under the upstream MIT license, not clean-room or wholly first-party code.
- A model initialized from third-party weights inherits the base model's
  identity and license even if Ergentics, LLC owns its adapters, corpus, or
  evaluation.
- A random-initialized Ergentics architecture does not become a functional
  language model without admitted data, learning, and held-out evaluation.

For the current native lane, the exact Ergentics Logic source is a read-only
architecture/reference donor and must not execute. The authoritative decoder
candidate is a Prime-owned Swift mechanical port over maintained MLX
primitives. The completed `MLXLLM.LlamaModel` receipts remain historical
mechanics evidence only and cannot select the future decoder. See
`PRIME-NATIVE-DECODER-AUTHORITY-CORRECTION-2026-08-03.md`.

Every admitted corpus must record origin, ownership/license, redistribution
rights, PII/PHI review, deterministic transforms, split construction,
generator/oracle versions, and canonical hashes. Training, validation, and
holdout must be separated before materialization, and held-out tests must
include unseen combinations and leakage mutations.

Every checkpoint must bind initialization, architecture, tokenizer,
corpus/splits, training configuration, optimizer and complete optimizer state,
global step/schedule, random domains, data cursor, precision, executor,
dependency, hardware observation, and parent checkpoint. A checkpoint file
without that record is a local artifact, not an accepted Prime model.

## Security, privacy, and incident response

- Do not place credentials, private corpora, user telemetry, PHI, PII, or
  local machine secrets in source, prompts, receipts, logs, or public issues.
- Scientific workers are not authorized to use the network. The current tiny
  non-sensitive typed-restore fixture has no declared network code and gives
  workers an empty environment, but Prime does not yet enforce or observe
  operating-system-level network denial or filesystem sandboxing. Sensitive
  corpus, credential, secret, PHI, or PII work requires an admitted isolation
  boundary first. Any future network access requires a task-specific human
  review, endpoint allowlist, secret boundary, and raw audit record.
- Treat generated code, model output, repository prose, and free-form agent
  summaries as untrusted proposals until typed validation.
- Reject path traversal, symlinks, unsafe ownership/modes, replacement,
  unbounded output, environment injection, and unpinned executable or
  dependency selection at authority boundaries.
- On suspected corruption or disclosure, stop the lane, quarantine the
  artifacts, preserve evidence, rotate exposed credentials, and publish a new
  correction/revocation record that identifies every superseded artifact.

Prime's current artifact controls address accidental and persistent mutation,
not a malicious concurrent process with the same user identity. Claims must
retain that limitation until stronger process or identity isolation is
implemented and tested.

## Open-source horizon

The goal of safely contributing useful Swift ecosystem improvements does not
itself authorize publication. Before any public code release:

1. choose an explicit license for Ergentics-authored material;
2. preserve dependency licenses and copyright, create third-party notices and
   an SBOM, and bind the upstream base plus Ergentics revision;
3. scrub secrets, local paths, private repositories, user/clinical data,
   proprietary corpora, checkpoint material, internal-only evidence, and
   machine-local commit author identities;
4. provide a reproducible tagged build, tests, limitation and `ABSTAIN`
   records, and safe examples;
5. add security reporting, contribution, review, branch, CI, provenance, and
   release policies;
6. perform an explicit human security, privacy, license, and export review.

The human repository owner selected `Ergentics, LLC` as the exact legal
rights-holder spelling on 2026-07-29 before the private MLX derivative was
made authoritative for Prime. That legal entity is distinct from Git author
identity and ordinary `Ergentics` brand, package, repository, and organization
names. Any future public publication still requires the explicit human
security, privacy, license, and export review above.

Weights and data require separate license and risk decisions even if code is
released. Public evidence requires a separate privacy and claim review.
Publication must never be used as a substitute for validation.

## Admission sequence

The current authorized sequence is deliberately small:

1. bind the derivative MLX Swift patch to an explicitly authorized,
   license-preserving private remote and authenticate a cache-empty clone —
   complete at revision
   `68904d54b72871f26968261ae05d4fbb7c5e3142`;
2. prove exact typed optimizer restore on tiny CPU FP32 fixtures across fresh
   Swift processes, with the complete declared structural mutation set
   disposed — complete for both frozen fixtures and all 19 mutations;
3. preserve the generated canonical receipt in separately controlled
   off-device storage;
4. run one bounded interrupted Metal continuation canary;
5. implement the first-party tokenizer/corpus/evaluator provenance contracts;
6. only then reassess profile calibration, full-profile checkpoint
   feasibility, learning, quantization, or deployment conversion.

No step inherits authorization from the next step's desirability.

## Orientation and donor references

- [NIST AI RMF core: Govern, Map, Measure, Manage](https://airc.nist.gov/airmf-resources/airmf/5-sec-core/)
- [NIST AI 100-1, Artificial Intelligence Risk Management Framework (AI RMF 1.0)](https://doi.org/10.6028/NIST.AI.100-1)
- [NIST AI Risk Management Framework program page](https://www.nist.gov/itl/ai-risk-management-framework)
- [AI.gov](https://ai.gov/) (orientation only; no federal-compliance claim)
- [NTIA report on dual-use foundation models with widely available model weights](https://www.ntia.gov/programs-and-initiatives/artificial-intelligence/open-model-weights-report)
- [Apple Core ML Tools overview](https://apple.github.io/coremltools/docs-guides/source/overview-coremltools.html)
- [Apple Core ML Tools PyTorch conversion workflow](https://apple.github.io/coremltools/docs-guides/source/convert-pytorch-workflow.html)
- `pmhnp-companion-ergentics/docs/PMHNP-PRIME-AI-SAFETY-SCOPE.md`
- `docs/PMHNP-METAL-QUANT-ARC-RESOLUTION-2026-07-29.md`
- `ergentics-logic/docs/PROVENANCE-SCHEMA.md`
- `ergentics-logic/docs/THE-HONEST-WITNESS.md`
- `ergentics-logic/seals/SEAL-GATE-ARCHITECTURE.md`
- `ergentics-workstation/docs/CEO-AGENT-ADAPTER-BOUNDARY.md`
- `agentcraft-app/PROVENANCE.md`
- `agentcraft-app/docs/ORACLE-POLICY.md`
