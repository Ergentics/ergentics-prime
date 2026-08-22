<!--
SPDX-FileCopyrightText: 2026 Ergentics, LLC
SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
-->

# Prime Swift validation Driver V2 durable phase control

Date: 2026-08-22

Status: active working control for local implementation; not a Prime receipt,
execution authority, scientific result, CI gate, or product claim

## Control record

| Field | Bound value |
| --- | --- |
| Control role | Data-first implementation and restart procedure |
| Exact source base | commit a6f76bd3f246a443ef96e21fa4c769499a62b875 |
| Exact source tree | f4f826e42f928f17cc4854a183b912b56f265e0c |
| Base worktree state at capture | clean |
| Highest implemented code ceiling | source_guards_prepared_only |
| Live capability retained by this file | none |
| Missing live authority enum cases | 9 |
| Next implementation gate | A — dedicated supervisor image and live intent bridge |
| GitHub execution authorized | false |
| Root 904-test spend authorized by this file | false |
| Stage-7 or Metal execution authorized | false |
| Off-device durability claimed | false |

This file coordinates development. It cannot restore a lease, descriptor,
source watch, mapped executable, child obligation, or other live capability.
After any process exit, a later invocation must acquire those operating-system
resources fresh, consult the validated durable ledger, and reestablish the
exact accepted source checkpoint. It never restores or continues a consumed
capability.

## Bound reconciliation inputs

| Input | SHA-256 at the exact source base |
| --- | --- |
| Pasted A–H Driver V2 proposal | e400ed8355cb58758957eeb0af36fa521d88e7d72a9f44c04be88f942d108019 |
| PRIME-AI-RD-GOVERNANCE.md | 54fd329af4268b080307b736d282fc1b27db926d22a9dbbd15b32f2735a80494 |
| PRIME-SWIFT-VALIDATION-EVIDENCE-CONTRACT-2026-08-02.md | 3141890bc02ae545604d0b923d3d7915481c683fc7bb79e2eacd6318c0cb0ca5 |
| PRIME-SWIFT-VALIDATION-DRIVER-V2-FOUNDATION-2026-08-02.md | 6bd51d4446ea31f0f819e7f8aa522f3c6af5f6a075b9a34869cceb652bc6ef8b |
| PRIME-SWIFT-VALIDATION-EXECUTOR-ADMISSION-2026-08-02.md | 1c133898af6574cdcb5a6abd8f7d338147e3f2047bebaf2a48b5f7a4c923dabc |
| PRIME-SWIFT-VALIDATION-GUARDED-SOURCE-2026-08-03.md | 19f0b5ae57ae5d9db83e73a71311af36002e1e56bef8fd3e2b18a94034ed893a |
| PRIME-SECURE-CHILD-DARWIN-SPAWN-TRANSPORT-2026-08-03.md | dbfd4769f8a8180a8539343bf074ec638c5ab7800cdd16031e95020d17ab372b |
| PRIME-SECURE-CHILD-SUPERVISION-2026-08-03.md | fea4a0e516212432d2b3f029d7dedcda17e91e2df861aa286799d0eeb761611f |

If one of these inputs changes, this control is stale until its comparison and
base bindings are reviewed again.

## Authority precedence

| Rank | Source | Effect |
| ---: | --- | --- |
| 1 | Governance and frozen V2 contracts, schemas, policies, anchors, and mutation gates | Bounds what an implementation is permitted to claim |
| 2 | Compiled Swift validators, live capabilities, raw evidence, and immutable receipts at an exact source tree | Determines whether a permitted fact was actually observed |
| 3 | Latest implementation-boundary documents and source at the bound tree | Records implemented versus missing mechanics |
| 4 | This phase-control file | Orders work and stop/go decisions only |
| 5 | Pasted plans, agent summaries, issues, shell output, and hosted workflow prose | Proposals or observations only |

Missing, stale, contradictory, or unbound evidence remains ABSTAIN.
No prose in this file may promote unobserved into observed truth.

## Plan reconciliation

| Question | Pasted A–H plan | Earlier conversational direction | Reconciled decision |
| --- | --- | --- | --- |
| Supervisor scope | Dedicated closed local Driver V2 supervisor | Reusable local-lab supervisor pattern, with a possible Stage-7 front end | Use the dedicated Driver V2 supervisor only. The earlier shared-lab framing is rejected for this phase |
| Process model | Reuse the already-extracted Darwin substrate | Add a new neutral supervisor chassis | Neutral transport and supervision already exist at the base tree. Add only Driver-V2-specific live ownership and closed role policy |
| API surface | No generic command API | Shared kernel with multiple closed front ends | No new generic API, argv, environment, callback, or command surface. The only additive cross-module surface is an opaque validation-specific capability transfer |
| GitHub | Not the lab | Optional review CI | GitHub is outside the implementation and evidence path. No Actions run is a gate for A–H |
| Stage 7 | Explicitly excluded | Separate future Stage-7 supervisor | Stage 7, run 129, Metal, checkpoint science, and hosted unique-shot contracts are unrelated frozen history and are excluded |
| Schemas | Preserve existing intent, planner, receipt, and admission types | Add a local-lab authority | Preserve all frozen V2 values. Add a live non-restorable capability and, at H, an outer publication envelope without mutating the frozen inner types |
| Durability | Phase ledger, receipt-last, resume only never-started | One-shot experiment ledger | Use the existing validation phase/shard state machine. Do not import Stage-7 one-shot semantics |
| Cost | No 904-test spend before live 892/12 admission | Preflight before a costly shot | A–G use focused local proofs. H requires a separate human go/no-go |

## Frozen inputs that are not reopened

| Frozen item | Required value or behavior |
| --- | --- |
| Run intent | PrimeValidationRunIntentV2 and its existing identity |
| Authority ceiling | PrimeValidationDriverAuthorityCeilingV2.frozenPlannerV2 remains byte- and meaning-identical |
| Companion revision | 163fc100710ece48119bc25954452d10f6a84f7f |
| Root inventory | 892 XCTest identifiers and 12 Swift Testing identifiers |
| XCTest list | 114,186 bytes; SHA-256 93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b |
| Swift Testing list | 1,287 bytes; SHA-256 487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3 |
| Sharding | Sorted-suite contiguous next-fit; at most 32 tests and 16 KiB filter text; V20 dedicated |
| Evidence lanes | Parallel XCTest, sequential XCTest, and Swift Testing; sequential XCTest owns skip truth |
| Phase order | source_admission, build, inventory, execution_plan, reference_execution, candidate_execution, reconciliation, comparison, publication |
| Resume policy | resume_only_never_started_v1 |
| Child environment | Exact role-derived replacement environments; no inherited extras |
| Outcome input | Semantic results come only from reparsed bound raw xUnit or transcript bytes |
| Missing state | unobserved is distinct from observed false and cannot become PASS |

The executor implementation must not change frozenPlannerV2 to claim process,
build, or resume authority. A new live capability can prove those facts without
rewriting the historical planner ceiling.

## Current implementation truth

| Boundary | State at the exact base | Consequence |
| --- | --- | --- |
| V2 schema, planner, receipts, comparator | implemented, with public completion intentionally fail-closed | Reuse; do not reopen |
| Closed nine-mode fixture | implemented | Mechanics proof only |
| Neutral physical spawn and logical argv[0] transport | implemented internally | Reuse through a closed validation facade |
| Neutral deadlines, mapped-image/cwd proof, containment, exact reap, group-empty proof, and EOF drains | implemented internally | Do not redesign the process model |
| Admission prerequisite | implemented, non-Codable, one-shot, retains lease and descriptors | Cannot execute or mint a receipt |
| Prime source guard | implemented for the prepared no-child state | Must be extended across the live sequence |
| Current-process image retention | implemented but non-authoritative under XCTest | Does not close supervisor image |
| Companion content closure/watch | not implemented live | Root identity and caller declarations are insufficient |
| Dedicated Driver V2 executable product | absent | Gate A |
| Non-restorable DriverCore intent bridge | absent | Gate A |
| Canonical tracked-tree manifest mechanics | absent | Gate D |
| Fixed Git/Swift observations | absent | Gate E |
| Staging, build, and generated artifact binding | absent | Gate F |
| Live list execution and anchor admission | absent | Gate G |
| Parser-authorized shard execution and durable publication | absent | Gate H |

### Nine missing live authorities

| Authority enum case | Closing gate | State |
| --- | --- | --- |
| supervisor_executable_image | A | NOT_STARTED |
| prime_git_head_and_clean_process_observation | E | NOT_STARTED |
| companion_git_head_and_clean_process_observation | E | NOT_STARTED |
| swift_version_process_observation | E | NOT_STARTED |
| swift_target_info_process_observation | E | NOT_STARTED |
| swiftpm_build_execution | F | NOT_STARTED |
| artifact_staging | F | NOT_STARTED |
| xctest_inventory_execution | G | NOT_STARTED |
| swift_testing_inventory_execution | G | NOT_STARTED |

Gates B, C, and D are mandatory integrity prerequisites. They do not fabricate
additional enum cases or reduce the missing count by themselves.

## Module and capability shape

~~~text
PrimeValidationWorkflowDriverV2Supervisor executable
    |
    +-- PrimeValidationWorkflowDriverCore
    |      frozen intent/planner/receipts/parsers
    |      narrow non-restorable intent bridge
    |
    +-- PrimeCore
           admission lease/descriptors/source watches
           mapped-current-image proof
           neutral secure-child substrate
           opaque fixed-role Driver V2 live capability
~~~

The nested executable depends on DriverCore and PrimeCore. PrimeCore does not
depend on DriverCore. The bridge therefore has two halves:

1. PrimeCore atomically consumes the guarded pre-executor, compares its retained
   mapped image against an exact expected path/content binding, and returns an
   opaque non-Codable validation capability that retains the live resources.
2. DriverCore derives that expected binding from the already-validated run
   intent and retains the opaque PrimeCore capability behind a validation-
   specific, non-restorable bridge.

The equality proof occurs inside PrimeCore because its held descriptors, image
bytes, source watch, and lease are module-internal. Raw descriptors, process
handles, arbitrary paths, argv, environments, timeouts, and callbacks do not
cross the boundary.

## Worktree isolation

The GitHub fixture-identity mechanics worktree contains unrelated uncommitted
changes at these five paths:

- .github/scripts/prime-ci-active-root-quarantine.sh
- .github/workflows/prime-active-root-quarantine.yml
- Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift
- .github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement-v2.sh
- Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluatorV2.swift

Those changes are preserved user work. They are not a Driver V2 dependency,
authority, receipt, or implementation base. Do not reset, clean, stash, rebase,
squash, delete, copy, or merge them into this phase.

Driver V2 implementation starts from the exact clean base named in the control
record, on a dedicated local branch/worktree. Every gate must begin with:

| Check | Required result |
| --- | --- |
| HEAD | exact accepted predecessor commit |
| HEAD tree | exact accepted predecessor tree |
| Worktree | clean before the gate starts |
| Changed paths | exact reviewed gate allowlist |
| .github paths in changed-path diff/allowlist | absent |
| Stage-7/native-300M paths in changed-path diff/allowlist | absent |
| Generic process surfaces | absent |

A local commit/tree is a durable development checkpoint, not a Prime execution
receipt and not off-device durability. Remote publication is not required for
the next gate.

### Live-root isolation

| Area | Required boundary |
| --- | --- |
| Development worktree | Source-development workspace only; never authority merely because files exist |
| Live Prime root | Separately resolved, clean, canonical, descriptor-bound, and equal to the accepted commit/tree/source manifest |
| Live companion root | Exact pinned commit, clean observation, canonical descriptor identity, held manifest, and active watch |
| Workspace, evidence, and lease roots | Private, initially empty, mode 0700, canonical, disjoint, non-nested APFS roots |
| Build outputs | Outside the source roots; descriptor-relative no-follow staging and authenticated publication only |
| Destructive cleanup | Forbidden as an admission technique; stop or create a fresh isolated root |

## Inventory conservation

A–G must not add, remove, or rename a compiled root XCTest or Swift Testing
identifier. New proof should live in the isolated PrimeValidationWorkflow
package or its dedicated executable/integration whenever possible.

Any allowlisted root production, test, or package-source edit changes source
identity even when it leaves the 892/12 identifier list unchanged. That edit
must receive a new exact source commit/tree/manifest and intent binding before
live proof; it may not reuse the predecessor's source or intent identity.
Additional assertions inside an existing root test identity conserve inventory,
not source identity.

If a new root test identifier is unavoidable:

1. stop the active gate;
2. keep the 892/12 anchors unchanged;
3. request a separate source-and-inventory reseal;
4. resume only after that reseal becomes the accepted predecessor.

Silently editing the list resources or expected counts to fit new tests is
forbidden.

## Gate ledger

| Gate | Development state | Closes or enables | Exit condition |
| --- | --- | --- | --- |
| P0 | COMPLETE_AT_BASE | V2 intent, planner, receipts, phase/shard ledgers | Frozen focused tests remain unchanged |
| P1 | COMPLETE_AT_BASE | Neutral Darwin spawn transport | One implementation; closed callers only |
| P2 | COMPLETE_AT_BASE | Neutral supervision substrate | Containment or exit-70 fail-stop |
| P3 | COMPLETE_AT_BASE | Admission prerequisite | One-shot live lease/descriptors; no execution |
| P4 | COMPLETE_AT_BASE | Prepared Prime source guard | source_guards_prepared_only |
| A | NOT_STARTED | Dedicated supervisor image and intent bridge | No child launched by the supervisor |
| B | NOT_STARTED | Driver-V2-specific fixed-role process facade | No generic surface; fixture mutations pass |
| C | NOT_STARTED | Gapless Prime and companion guard continuity | Mutation at any boundary poisons |
| D | NOT_STARTED | Canonical tracked-tree manifest semantics | Held-byte and Git-declared identities agree |
| E | NOT_STARTED | Four Git/Swift observations | Raw/parsed agreement and all guards revalidated |
| F | NOT_STARTED | Staging plus build and generated artifacts | Build receipt binds held metallib and bundle |
| G | NOT_STARTED | Both live inventories | Exact frozen anchors admit an execution plan |
| H | BLOCKED_ON_A_THROUGH_G_AND_HUMAN_GO | Shards, parsing, comparison, resume, publication | Outer receipt-last envelope published |

### Expected implementation surfaces

The exact changed-path allowlist is frozen at the start of each gate. The
expected ownership below is a routing constraint, not advance authorization for
every named file.

| Gate | Expected source ownership |
| --- | --- |
| A | Nested package manifest; new dedicated supervisor target; DriverCore bridge; validation-specific PrimeCore admission capability; isolated validation tests |
| B | PrimeCore fixed-role facade over the existing internal secure-child substrate; isolated role-policy tests |
| C | PrimeCore guarded pre-executor/watch state; existing live admission tests and isolated multi-root mutations |
| D | DriverCore repository-admission manifest mechanics and mutations; PrimeCore held-byte acquisition |
| E | PrimeCore closed probe roles; DriverCore raw/parsed adapters; isolated live-probe tests |
| F | PrimeCore descriptor-relative staging/build role; DriverCore build receipt adapter and artifact-binding tests |
| G | PrimeCore two closed list roles; existing public inventory parser/receipt path; isolated anchor mutations |
| H | Same-module DriverCore parsed-evidence adapter; PrimeCore durable writer; additive outer publication envelope and receipt-last mutations |

### Gate A — supervisor identity

Required implementation:

- add one dedicated executable product and target under
  Tests/PrimeValidationWorkflow;
- do not add a root package target or repurpose FixtureChild or
  SecureChildIntegration;
- add the opaque PrimeCore live image-binding capability;
- add the DriverCore intent bridge;
- prove requested path, canonical path, held device/inode, loaded vnode, byte
  count, and SHA-256 agree with intent.driverExecutable;
- reject Apple xctest on the production path;
- preserve one-winner sequential and concurrent consumption;
- make failure permanently poison the consumed live transition; and
- expose no Codable, restore, public initializer, child-role, staging, build,
  list, shard, or receipt-publication surface yet.

Gate A proof is focused and local. Launching the dedicated executable to prove
its own image is permitted; that executable must not launch Git, SwiftPM, test,
or fixture children in A.

### Gate B — fixed Driver V2 role facade

Reuse the neutral substrate. Add only fixed internal role policies for the
already-planned operations. Every role fixes its physical executable,
logical argv[0], arguments, replacement environment, cwd, deadline, output
limits, result contract, and post-reap checks.

Acceptance requires:

- no additional posix_spawn implementation;
- no Foundation Process fallback;
- no shell or Python;
- no arbitrary command, argv, environment, cwd, timeout, or callback input;
- one absolute deadline established before spawn;
- suspended cwd and mapped-image proof;
- bounded independent stdout/stderr drains;
- exact-PID reap and process-group-empty proof; and
- every post-spawn rejection returns only after containment or terminates the
  abandoning supervisor through the established exit-70 path.

### Gate C — gapless multi-root guard

The live token must retain and revalidate both Prime and companion content,
not only directory identities or caller declarations. The Prime and companion
descriptor closures and vnode watchers remain armed across:

~~~text
pre-spawn check
    -> child resume
    -> child death
    -> exact reap
    -> EOF drains
    -> post-reap check
    -> next pre-spawn check
~~~

The build, XCTest-list, and Swift-Testing-list sequence has no unwatched
interval. The same guards are checked around the earlier Git and Swift probes.
Mutation, rename, replacement, watcher overflow, missing event accounting, or
check failure poisons the live token.

### Gate D — canonical tracked-tree manifests

Keep repositoryTrackedTreeSHA256 and companionTrackedTreeSHA256 unchanged as
schema fields. Define and test a deterministic canonical manifest that binds:

- the exact tracked path set from bounded raw Git output;
- canonical path bytes and order;
- tracked mode and Git object identity;
- held regular-file or admitted symlink identity;
- byte count and SHA-256 from descriptor-held content; and
- explicit rejection of duplicate, missing, added, renamed, replaced, unsafe,
  noncanonical, or unheld entries.

Gate D implements pure parsing/manifest mechanics and mutations. Gate E supplies
the first live Git bytes.

### Gate E — fixed Git and Swift probes

Run only the four closed observation roles:

1. Prime HEAD plus clean tracked-tree observation;
2. companion HEAD plus clean tracked-tree observation;
3. Swift version observation; and
4. Swift target-info observation.

Use the frozen five-entry probe environment, not the merged 19-entry SwiftPM
environment. Bind bounded raw bytes, parser result, physical image, logical
argv[0], cwd, process evidence, and pre/post guard state. PrimeNativeGitBlobTransport
is excluded because it uses Foundation Process and lacks the required process
proof.

### Gate F — staging and build

Create the declared private staging tree by descriptor-relative no-follow
operations. Publication is exclusive, synchronized, and reverified.

Run exactly the planned SwiftPM build personality. After complete reap and
drain, retain and authenticate:

- the generated metallib at the planned relative path/hash;
- the immutable test-bundle tree;
- the package lock and complete phase-available source/toolchain bindings; and
- the build raw output and process evidence.

The metallib is a build artifact identity. No Metal device work, model
execution, checkpoint operation, or unique shot occurs here.

### Gate G — live inventories

Run the two closed SwiftPM list roles and parse only their bounded raw bytes.
Reject non-UTF-8, NUL, carriage-return, terminal-escape, oversized input,
oversized line, duplicate, malformed, zero-match, or extra identifiers.

No execution plan may be constructed unless count, byte count, and SHA-256 all
match both frozen inventory anchors. A mismatch is not repaired in place and
does not authorize a 904-test run.

### Gate H — shards, parser authority, and publication

H remains blocked until A–G have exact accepted checkpoints and the human owner
explicitly authorizes the local repository-wide spend. The go/no-go record must
name the exact intent SHA-256, accepted source commit/tree, both live inventory
anchors, phase budgets, and reference/candidate scope immediately before the
first H child spawn. Approval is authorization, not execution evidence.

H must add a same-DriverCore-module execution adapter that:

- reparses every bound raw xUnit/transcript artifact before semantic admission;
- invokes the existing internal parsed-evidence kernels;
- never accepts caller-supplied semantic arrays;
- executes the three complete reference lanes and deterministic candidate
  shards within frozen budgets;
- preserves sequential XCTest as skip authority;
- reuses a succeeded terminal only after full parser-authorized validation;
- may reuse a failed terminal only as a terminal failed fact, never to rerun it
  or execute a successor;
- executes only work proven never started;
- never follows a failed, incomplete, or started-without-terminal item; and
- produces complete_pass, complete_fail, or incomplete without converting
  transport defects into test results.

The existing PrimeValidationDriverFinalReceiptV2 is preserved, but it does not
directly bind the phase ledger or complete evidence inventory. H therefore
adds an outer publication envelope whose exact schema must be frozen and
mutation-tested before the run. At minimum it binds:

| Envelope binding | Required identity |
| --- | --- |
| Run | exact run ID |
| Intent | intent SHA-256 |
| Admission | identity emitted by the live non-Codable bridge; decoded admission bytes alone fail closed |
| Phase history | final phase-ledger SHA-256 |
| Evidence namespace | exact pre-envelope manifest SHA-256 |
| Build | build-receipt SHA-256 |
| Inventory | inventory-receipt SHA-256 |
| Execution plan | plan SHA-256 |
| Reference/candidate | both aggregate SHA-256 values |
| Comparison | comparison-receipt SHA-256 |
| Inner terminal | PrimeValidationDriverFinalReceiptV2 SHA-256 |
| Source authority | exact source commit/tree and executable content |
| Publication | disposition plus monotonic publication sequence |

This envelope is additive. It does not mutate the frozen inner intent, planner,
receipt, or authority-ceiling values.

The inner PrimeValidationDriverFinalReceiptV2 remains a semantic-kernel value
with the frozen planner ceiling. It is not standalone execution authority and
must never be published or interpreted without the bound live-capability
evidence and outer envelope.

## Live execution durability

### Live state machine

| State | Permitted transition | Forbidden |
| --- | --- | --- |
| unavailable | fresh admission only | decode or reconstruct authority |
| prerequisite_available | consume once into guards | retry after consumption begins |
| guards_prepared | bind exact supervisor image | child execution before image binding |
| supervisor_bound | enter fixed next role | arbitrary role or parameter |
| child_suspended | publish and verify start, then resume | resume before durable start |
| child_running | supervise to terminal/containment | detach or abandon |
| child_reaped_drained | parse and publish terminal | claim semantics from exit alone |
| ready_for_next | next never-started fixed role | rerun started work |
| poisoned | dispose/fail-stop | repair, restore, or continue |
| terminal | publish outer envelope last | write another evidence-root artifact |

No serialized file transitions this live state machine. Process restart begins
again at unavailable and must validate existing durable evidence before it may
decide that a later item was never started. That decision requires a valid
ledger/manifest prefix and the exact start=nil, terminal=nil state; filesystem
absence alone is not evidence.

### Start and terminal ordering

For every phase and shard:

1. create its exact start value;
2. publish it with exclusive no-replace creation;
3. synchronize the file and parent directory;
4. read and verify the held binding;
5. only then resume the suspended child or begin the irreversible local action;
6. contain, reap, drain, synchronize, and verify every raw artifact;
7. parse raw evidence and derive the terminal value;
8. publish the terminal exclusively and verify it; and
9. publish the next immutable ledger prefix only if the terminal succeeded.

A crash after step 2 means the item started. Missing terminal is permanently
incomplete and the item is not rerun under that run ID.

If the child has already been spawned suspended and start publication,
synchronization, or verification fails, do not resume it. Contain and reap the
exact PID, drain its streams, poison the live capability, and publish no
executable terminal for that item.

### Receipt-last ordering

The terminal evidence order is:

~~~text
one item start
    -> that item's raw artifacts and process evidence
    -> that item's terminal
    -> next immutable ledger prefix
    -> repeat only for the next permitted item
    -> final complete phase ledger
    -> exact evidence manifest excluding the outer envelope
    -> inner final receipt
    -> outer publication envelope
~~~

The outer publication envelope is created exclusively, synchronized, read
back, and verified. No Prime-authored evidence-root write follows it.

## Development checkpoint durability

Development checkpoints and live execution receipts are separate state
machines.

| Development state | Meaning |
| --- | --- |
| NOT_STARTED | No implementation diff exists |
| IMPLEMENTING | Bounded allowlisted diff exists; no acceptance claim |
| LOCAL_PROOF_COMPLETE | Exact commands and outputs are retained for the exact tree |
| INDEPENDENT_AUDIT_COMPLETE | Reviewer names the exact tree and finds no open blocker |
| CHECKPOINTED | Local commit/tree records the accepted slice |
| SUPERSEDED | A later immutable record names the replacement; history remains |

Each gate checkpoint records:

| Required datum | Rule |
| --- | --- |
| Gate ID | One of A through H or an explicitly named subgate |
| Predecessor commit/tree | Exact accepted checkpoint |
| Candidate commit/tree | Exact reviewed source |
| Changed paths | Sorted, exact, no-renames list |
| Frozen-input check | All bound hashes and anchors unchanged unless separately resealed |
| Proof commands | Exact argv, cwd, environment policy, configuration, and timeout |
| Proof results | Exit, bounded raw-log bindings, test counts, and skips |
| Mutation results | Exact declared set; missing mutation means no acceptance |
| Audit result | Reviewer plus exact candidate tree |
| Authority ceiling | Exact facts closed and facts still missing |
| Next permitted gate | One bounded successor only |

The control file may be updated to point at a checkpoint, but its prose is not
proof that the checkpoint passed.

## Cost and execution ladder

| Level | Work | Authorization |
| ---: | --- | --- |
| 0 | Source-shape checks, canonical encoding, parser and mutation unit tests | Local development |
| 1 | Nested package Debug build and focused tests | Local development |
| 2 | Dedicated supervisor Release self-image proof and tiny closed fixtures | Local development |
| 3 | Fixed Git/Swift probes and tiny staging/build/list fixtures | Only after predecessor gate |
| 4 | Live build plus both inventories, stopping before shards | Only after A–F |
| 5 | Reference lanes and candidate shards over the admitted 904 tests | Explicit human go/no-go after G |
| 6 | GitHub CI, off-device automation, Stage 7, Metal, training, or product work | Not authorized by this control |

No gate uses Actions as a lab, identity oracle, retry channel, or receipt
publisher. Local source checkpoints are preferred until the executor itself can
produce the required evidence.

## Hard stop conditions

Stop without advancing the gate if any of the following occurs:

- a frozen schema, ceiling, inventory anchor, phase order, or policy must change;
- a new root test identifier appears without a separate reseal;
- a .github, Stage-7, Native-300M, Metal, training, or product path enters the
  diff;
- a generic command, argv, environment, cwd, timeout, callback, Process, shell,
  or Python execution surface appears;
- Prime or companion source content is not descriptor-held and continuously
  watched;
- the source, lock, toolchain, executable, workspace, or staged artifact has an
  unexpected, unbound, or identity-inconsistent change across a child boundary;
  declared phase outputs may transition only through the authenticated
  publication step;
- a live capability is decoded, restored, copied after consumption, repaired
  after poison, or detached from its child obligation;
- a child is resumed before its start is durably published;
- exact-PID reap, group emptiness, bounded EOF drains, or containment is not
  proven;
- semantic values are supplied instead of parsed from bound raw bytes;
- the final evidence inventory cannot be bound by the outer envelope;
- any A–G gate attempts the 904-test execution; or
- H lacks a fresh explicit human go/no-go naming the exact intent SHA-256,
  accepted source commit/tree, both inventory anchors, budgets, and
  reference/candidate scope.

The result of a hard stop is a truthful incomplete or ABSTAIN boundary, never a
synthetic PASS.

## Immediate executable slice

The only next implementation is Gate A. Its completion record must prove:

| Gate-A assertion | Required truth |
| --- | --- |
| Dedicated product | One new nested Driver V2 supervisor executable |
| Root package graph | Unchanged |
| Root 892/12 IDs | Unchanged |
| Live resource owner | The supervisor process |
| Intent bridge | Non-restorable and one-shot |
| Image proof | Exact path, device/inode, loaded vnode, bytes, and content hash |
| XCTest host | Rejected on the production path |
| Child launches | Zero |
| Generic surface | Absent |
| Durable receipt claim | Absent |
| GitHub action | Absent |

Gate B does not begin from prose or a passing fixture line. It begins only from
an exact Gate-A candidate tree with focused local proof and independent audit.

## Gate A local checkpoint — successor record

This section supersedes the earlier `NOT_STARTED` implementation state for
Gate A. It does not rewrite the base capture above, create a Prime receipt, or
authorize Gate B execution.

### Exact checkpoint identity

| Datum | Observed value |
| --- | --- |
| Gate | A — dedicated supervisor image and live intent bridge |
| Development state | CHECKPOINTED |
| Predecessor commit | a6f76bd3f246a443ef96e21fa4c769499a62b875 |
| Predecessor tree | f4f826e42f928f17cc4854a183b912b56f265e0c |
| Candidate commit | 8bfb27f2475ed336e4343150cd02dffb5cc0cc9d |
| Candidate tree | 5c8d30c0f666d2d7c0f86bff78e532b4d31fb25e |
| Local branch | agent/prime-validation-driver-v2-gate-a |
| Worktree after checkpoint | clean |
| Embedded Prime source identity | 5f98c788252351cd5bfa5b5b956089a189d393c4ee42df7f3a5a982412906819 |
| Release supervisor byte count | 46,245,048 |
| Release supervisor SHA-256 | e8cdf764391ec862bf082891e4192b89ca70e005ff1b41de50199fbe212b185a |
| GitHub or off-device execution | none |
| Prime receipt or scientific outcome | none |

### Exact changed paths

1. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift`
2. `Sources/PrimeCore/PrimeSecureRunningExecutableCapture.swift`
3. `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift`
4. `Tests/PrimeValidationWorkflow/Package.swift`
5. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore/PrimeValidationDriverV2SupervisorImageBridge.swift`
6. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2Supervisor/main.swift`
7. `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift`

Root `Package.swift`, root `Package.resolved`, and the nested lock state are
unchanged. No `.github`, Stage-7, Native-300M, Metal, MLX/training, product, or
Gate-B role-facade path entered the candidate.

### Frozen-input conservation

| Input | Count | Byte count | SHA-256 | Candidate result |
| --- | ---: | ---: | --- | --- |
| Root XCTest inventory | 892 | 114,186 | 93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b | unchanged |
| Root Swift Testing inventory | 12 | 1,287 | 487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3 | unchanged |

### Focused compiled proof

Working directory for both commands:

`/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-a-staging`

Debug command:

~~~text
CLANG_MODULE_CACHE_PATH=/private/tmp/prime-driver-v2-gate-a-clang-module-cache SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/prime-driver-v2-gate-a-swiftpm-module-cache PRIME_PMHNP_COMPANION_ROOT=/private/tmp/prime-gate-a-companion.4hdBMS swift test --disable-sandbox --package-path Tests/PrimeValidationWorkflow --filter PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests
~~~

Result: exit 0; 20 selected; 19 passed; one intentional Release-only skip;
zero failures.

Release command:

~~~text
CLANG_MODULE_CACHE_PATH=/private/tmp/prime-driver-v2-gate-a-clang-module-cache SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/prime-driver-v2-gate-a-swiftpm-module-cache PRIME_PMHNP_COMPANION_ROOT=/private/tmp/prime-gate-a-companion.4hdBMS swift test --disable-sandbox -c release --package-path Tests/PrimeValidationWorkflow --filter PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.testPublicReleaseAdmissionUsesEmbeddedSourceAuthority
~~~

Result: exit 0; one selected Release test passed; zero failures. The test
admitted the complete current Prime source snapshot against the embedded source
identity above.

`git diff --cached --check` passed before the checkpoint. The staged allowlist
contained exactly the seven paths above and `git write-tree` produced the
candidate tree recorded above.

### Direct Release supervisor canaries

Every launch used an empty replacement environment, argc exactly as stated,
private disjoint workspace/evidence/lease roots, canonical request bytes unless
the case intentionally mutated framing, and the exact Release image above.

| Case | Exit | stdout bytes | stderr bytes | Lease entries | Workspace/evidence entries |
| --- | ---: | ---: | ---: | ---: | ---: |
| Exact image/request | 0 | 0 | 0 | 1 | 0 / 0 |
| Driver path mismatch | 65 | 0 | 0 | 1 | 0 / 0 |
| Driver byte-count mismatch | 65 | 0 | 0 | 1 | 0 / 0 |
| Driver SHA-256 mismatch | 65 | 0 | 0 | 1 | 0 / 0 |
| Trailing LF | 65 | 0 | 0 | 0 | 0 / 0 |
| Truncated request | 65 | 0 | 0 | 0 | 0 / 0 |
| Request over 256 KiB | 65 | 0 | 0 | 0 | 0 / 0 |
| Extra argv element | 65 | 0 | 0 | 0 | 0 / 0 |
| Physical `/private/tmp` image in a path containing spaces | 0 | 0 | 0 | 1 | 0 / 0 |
| Parent-symlink image spelling | 65 | 0 | 0 | 1 | 0 / 0 |
| Group-writable image | 65 | 0 | 0 | 1 | 0 / 0 |
| Image with link count two | 65 | 0 | 0 | 1 | 0 / 0 |
| Stdin held open without EOF or bytes | 65 at 5.00 seconds | 0 | 0 | 0 | not entered |

The SHA-256 of every empty stdout/stderr file was
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
A direct `proc_listchildpids` monitor sampled the successful supervisor process
140,336 times: supervisor exit 0, zero observed children, zero process-list
errors, and empty stdout/stderr.

The request generator and child monitor were temporary local observation
harnesses, were excluded from the source snapshot, and were removed before the
candidate tree was written. Their output is development evidence only; it is
not a Prime-authored receipt or released product truth.

### Independent audit

| Audit | Exact candidate scope | Result |
| --- | --- | --- |
| Luna final code/security audit | Seven changed paths; embedded identity `5f98c788...6819`; executable capture, one-shot transfer/poison, bridge, and main | No Gate-A blocker |
| Luna final roadmap/conservation audit | Seven changed paths; root graph/lock and 892/12 anchors; excluded path classes | No scope or conservation blocker |

Residuals recorded by the code audit are bounded and fail-closed: unusual
non-UTF-8 executable path bytes would pass through `String(cString:)`; a failed
prerequisite preparation is represented as transferred-no-authority rather
than a separately named poison state; and toolchain developer-directory
canonicalization remains distinct from the corrected supervisor-image
`realpath` proof. None grants execution or completion authority in Gate A.

### Authority after Gate A

Gate A closes exactly `supervisor_executable_image` on top of the already
prepared descriptor-backed Prime source closure and source watch. The
DriverCore bridge correlates live authority only with
`intent.driverExecutable`. Every other intent field remains a declaration for
later gates.

The following eight live authorities remain missing:

1. `prime_git_head_and_clean_process_observation`
2. `companion_git_head_and_clean_process_observation`
3. `swift_version_process_observation`
4. `swift_target_info_process_observation`
5. `swiftpm_build_execution`
6. `artifact_staging`
7. `xctest_inventory_execution`
8. `swift_testing_inventory_execution`

Process execution, build execution, inventory execution, artifact staging,
shard completion, receipt publication, completion, scientific, training, and
product observations remain unobserved or unauthorized. Missing evidence
remains `ABSTAIN`.

### Next permitted direction

Gate B is the single next permitted implementation direction: a
Driver-V2-specific fixed-role facade over the existing internal secure-child
substrate. Gate B remains `NOT_STARTED`; it requires a fresh exact predecessor
freeze at commit `8bfb27f2475ed336e4343150cd02dffb5cc0cc9d` / tree
`5c8d30c0f666d2d7c0f86bff78e532b4d31fb25e`, its own changed-path allowlist,
focused fixtures, and a separate local checkpoint. It does not authorize the
904-test run, GitHub execution, Stage 7, Metal, MLX/training, or publication.

## B0 predecessor freeze

Status: `FROZEN_FOR_GATE_B_IMPLEMENTATION`

This record authorizes only the bounded implementation of Gate B. It does not
change Gate A, authorize a live child, or promote any observation to execution
authority.

| Pin | Exact value |
| --- | --- |
| Gate B predecessor commit | `8bfb27f2475ed336e4343150cd02dffb5cc0cc9d` |
| Gate B predecessor tree | `5c8d30c0f666d2d7c0f86bff78e532b4d31fb25e` |
| Gate A parent commit | `a6f76bd3f246a443ef96e21fa4c769499a62b875` |
| Gate A parent tree | `f4f826e42f928f17cc4854a183b912b56f265e0c` |
| Base provenance blob | `0d1176766bcc4b1eac828f286486142cd76b8432` |
| Gate A provenance blob | `311faccf662db5df35ec960251e42a5daec32e01` |
| Excluded dirty fixture provenance blob | `45d3a061b7b28cd37cba25001886284bc366bc0a` |
| Frozen supervisor main blob | `1b5582ac9a40dce9ea06b94a82c9985978069b76` |
| Frozen DriverCore image bridge blob | `7ffdfb4e5063ddc7362a0d6b07d0cbbeb8b46e15` |
| Frozen PrimeCore image admission blob | `94e678d66b77fc47d93dce50cfd05f3d33e0157b` |

The Gate A provenance-file delta is exactly its embedded identity change from
`ab9ba1c8...` to `5f98c788...`. The excluded dirty fixture worktree instead
contains `c0d2cc3e...`. No fixture-measurement script, evaluator, `.github`
change, or dirty provenance value entered the Gate A tree.

### Frozen A-to-B boundary

1. `main.swift` remains the exact closed Gate A stdin frame. Gate B must not
   add a request-path loader, environment protocol, command language, new argv,
   receipt writer, or live-authority restoration path. It remains argc one,
   canonical stdin only, bounded to 256 KiB, and subject to the fixed five-
   second read/EOF deadline.
2. Normal exit zero remains a transient self-bind canary. The live capability
   dies with the process and the exit cannot be interpreted as process,
   execution, resume, receipt, completion, or scientific authority.
3. Production success inside Apple `xctest` remains forbidden. Internal test
   seams may exercise mechanics only and must remain explicitly non-production.
4. The PrimeCore mapped-image join remains mandatory on bind and revalidation:
   `deviceID == loadedImageDeviceID`, `inode == loadedImageInode`, and
   `mappedImageJoined == true`. Path, realpath, bytes, hash, owner, mode, and
   link-count checks supplement but never replace this join.
5. Non-UTF-8 path conversion and transferred-no-authority naming remain
   fail-closed residuals. They cannot create success and are not Gate B work.

### Lease disposal and retirement

| State or artifact | Frozen meaning |
| --- | --- |
| Live parent and leaf `flock` descriptors | The only lease authority |
| Persistent lock leaf | Inert; never authority, continuity, or permission |
| Poison or rejection | Drops retained state and releases kernel locks before continuation or process end |
| Normal process exit or crash | Kernel closes descriptors and releases locks; leaf remains |
| Used lease directory | Permanently retired for admission, regardless of exit |
| Next Gate B invocation | Fresh canonical, private `0700`, empty, disjoint lease root and fresh admission |
| Unlink, replacement, or cleanup of old leaf | Administrative cleanup only; never retry or authority restoration |

Gate B must preserve the rule that a released lock, stale file, inode, text, or
PID-like content is not authority. A diagnostic may prove that a kernel lock
was released, but successful reacquisition cannot establish continuity with a
prior process or consumed capability.

### Gate B implementation ceiling

Gate B may add only a Driver-V2-specific fixed-role facade over the existing
internal neutral secure-child substrate and focused policy/disposal mutation
proofs. It must not change the frozen main or image bridge, add another spawn
implementation, expose arbitrary command/argv/environment/cwd/deadline/output
parameters, launch a repository-wide test run, or claim that a role policy is
live execution evidence. Gate B begins with source inspection and static or
closed-fixture proof; live Git/Swift observations remain Gate E.
