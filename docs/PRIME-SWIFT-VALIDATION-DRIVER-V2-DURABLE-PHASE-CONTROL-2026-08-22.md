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

### B0.1 transfer-seam amendment

Status: `FROZEN_BOUNDED_AMENDMENT`

Source inspection found one concrete module-boundary gap in the B0
predecessor. The exact DriverCore launch declarations are separated from the
PrimeCore descriptor, watch, lease, and secure-child substrate by two private
stored properties:

| Owner | Frozen predecessor fact | Consequence |
| --- | --- | --- |
| `PrimeValidationDriverV2SupervisorImageCapability` | `liveImage` is `private` | A new DriverCore file cannot forward the Gate A live token |
| `PrimeValidationSwiftPMDriverV2SupervisorImageCapability` | its retained guarded state is `private` | A new PrimeCore file cannot transfer the held descriptors, source watch, or lease into B |

Keeping both files byte-frozen would leave only an arbitrary command surface,
reflection, or reopening unjoined paths. All three are rejected. The B0 blob
values remain the exact predecessor pins; this amendment authorizes only the
smallest additive typed transfer through those two owners. It does not reopen
Gate A image admission or the stdin frame.

The exact Gate B mutation allowlist is:

1. `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift` —
   one-shot transfer of the retained guarded state; no admission weakening;
2. `Sources/PrimeCore/PrimeSecureChildDarwinProcessProof.swift` — one named
   Driver V2 repository-directory proof context only;
3. `Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift` — new closed
   three-role facade over the existing substrate;
4. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore/PrimeValidationDriverV2SupervisorImageBridge.swift`
   — one package-scoped forwarding transition from the private Gate A token;
5. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore/PrimeValidationDriverV2RoleBridge.swift`
   — new typed mapping from the already-frozen admission launch declarations;
6. focused nested-package role-policy tests only; and
7. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` only for the final
   source-identity reseal.

The fixed Gate B role set is exactly `build`, `list_xctest`, and
`list_swift_testing`, in that order. `shard` remains unavailable because its
validated execution plan depends on the live inventories admitted only at
Gate G; shard execution remains Gate H work.

`main.swift` remains byte-identical to blob
`1b5582ac9a40dce9ea06b94a82c9985978069b76`. Contracts, planner, receipts,
package manifests, inventory resources, root test identifiers, `.github`, and
Stage-7 paths remain outside the allowlist. Gate B may prove policy shape,
one-shot transfer, poison, disposal, and containment routing, but it may not
run Git, SwiftPM build/list roles, or claim process-derived authority.

## Gate B local checkpoint — successor record

Status: `CHECKPOINTED`

This section supersedes only Gate B's earlier `NOT_STARTED` development state.
It records a local source checkpoint, not a live capability, Prime receipt,
process result, scientific result, or off-device publication.

### Exact checkpoint identity

| Datum | Observed value |
| --- | --- |
| Gate | B — fixed Driver V2 role facade |
| Predecessor commit | `8bfb27f2475ed336e4343150cd02dffb5cc0cc9d` |
| Predecessor tree | `5c8d30c0f666d2d7c0f86bff78e532b4d31fb25e` |
| Candidate commit | `40b5bb31fc7040c72c8c46af66944b60507033c7` |
| Candidate tree | `326da31d21a41c4f7342ad2b07ccbbd909bde806` |
| Local branch | `agent/prime-validation-driver-v2-gate-b` |
| Worktree after checkpoint | clean |
| Embedded Prime source identity | `e797f22c992cc3f5624958c08c7417fb563d69a6b4c50f55639be460fa96c959` |
| Provenance source bytes | 546 |
| Provenance source SHA-256 | `c725f846f9a18ef184baa3a2791e3320873d929ea6904929505dd973b0e001ce` |
| Provenance Git blob | `8ce4329ad720097f4416088bf6d7807529a6904c` |
| GitHub or off-device execution | none |
| Driver V2 child launches | zero |
| Prime receipt or scientific outcome | none; `ABSTAIN` |

The source identity was recomputed from the complete admitted fixed paths plus
all non-hidden regular files below `Sources`, `Tests`, and `docs`, excluding
only the canonical embedded-provenance source. Recomputing after the one-line
reseal produced the same `e797f22c...c959` identity. Relative paths were sorted
and the canonical records bound `byte_count`, `relative_path`, and `sha256`.

### Exact changed paths

| Status | Path |
| --- | --- |
| M | `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` |
| A | `Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift` |
| M | `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift` |
| A | `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore/PrimeValidationDriverV2RoleBridge.swift` |
| M | `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore/PrimeValidationDriverV2SupervisorImageBridge.swift` |
| M | `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` |

The allowlisted `PrimeSecureChildDarwinProcessProof.swift` extension was not
needed and did not change. No package manifest, lock, inventory resource,
supervisor `main.swift`, `.github`, Stage-7, Native-300M, Metal, training,
product, or root-test path entered the checkpoint.

### Frozen-input conservation

| Input | Exact conserved result |
| --- | --- |
| Supervisor `main.swift` Git blob | `1b5582ac9a40dce9ea06b94a82c9985978069b76` |
| Root `Package.swift` Git blob | `8e14c10aded588b3902a042341bca7acc842bcc6` |
| Root `Package.resolved` Git blob | `14d804bb4291720477240c27e24de6fbdc876b3b` |
| Nested `Package.swift` Git blob | `5c658c1e9006b9111a49789816a826467b3da9c1` |
| Nested `Package.resolved` Git blob | `69919288b1a5da256ff408a4d65106b23abc8f89` |
| All repository manifests and lock files | 29 paths checked; parent-to-candidate drift 0 |
| Root XCTest inventory | 892 lines; 114,186 bytes; SHA-256 `93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b` |
| Root Swift Testing inventory | 12 lines; 1,287 bytes; SHA-256 `487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3` |
| `git diff --cached --check` | pass before commit |
| `git write-tree` | `326da31d21a41c4f7342ad2b07ccbbd909bde806` |

The provenance delta from Gate A is exactly the embedded identity value
`5f98c788...6819` to `e797f22c...c959`; the canonical template is otherwise
byte-identical.

### Closed facade and transfer data

| Contract datum | Candidate result |
| --- | --- |
| DriverCore consume surface | exactly zero-argument `consumeFixedRoleFacade()` |
| Consume-time role/argv/env/cwd/deadline input | none |
| Role order | `build`, `list_xctest`, `list_swift_testing` |
| Physical executable | retained direct `swift-package` |
| Logical argument zero | `swift-build`, then `swift-test`, `swift-test` |
| Replacement environment | exact sorted 19-entry table |
| Role deadlines | 900 seconds, 300 seconds, 300 seconds |
| stdin | EOF for every role |
| stdout/stderr ceilings | independent 16 MiB each |
| Drain chunk | 64 KiB |
| Primary result | none, stdout, stdout |
| Initial facade position | build |
| Execution/advance/spawn surface | absent |
| Retained ownership | lease, descriptors, source watch, mapped image, and held toolchain remain inside PrimeCore |
| DriverCore ownership | opaque token only; no observation scraping or second owner |

DriverCore validates the complete frozen admission policy before deriving the
semantic role context. PrimeCore then compares the repository, companion,
workspace, and evidence path/device/inode/owner/mode tuples with its retained
observations before transferring ownership. A second retained-state
revalidation occurs before the original image token becomes permanently
`transferred`.

The logical intent binding and physical SwiftPM image remain deliberately
separate:

| Binding | Meaning |
| --- | --- |
| `intent.swiftExecutable` | logical `/swift` request, canonically the `swift-frontend` probe binding |
| retained `swiftPackageExecutable` | descriptor-backed direct physical `swift-package` |
| `intent.driverExecutable` | dedicated Driver V2 supervisor image correlated by the Gate A bridge |

Equating `intent.swiftExecutable` with retained `swift-package` would reject
the frozen planner/receipt contract and is forbidden. Physical role policies
correctly use the retained `swift-package` while preserving the separate
intent-to-toolchain Swift binding.

### Focused proof

All accepted proof commands ran from:

`/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-b-staging`

Debug build:

~~~text
CLANG_MODULE_CACHE_PATH=/private/tmp/prime-driver-v2-gate-b-clang-module-cache SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/prime-driver-v2-gate-b-swiftpm-module-cache swift build --disable-sandbox --disable-automatic-resolution --package-path Tests/PrimeValidationWorkflow --scratch-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-a-staging/Tests/PrimeValidationWorkflow/.build
~~~

Result: exit 0; build complete in 8.48 seconds.

Focused Debug tests:

~~~text
CLANG_MODULE_CACHE_PATH=/private/tmp/prime-driver-v2-gate-b-clang-module-cache SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/prime-driver-v2-gate-b-swiftpm-module-cache swift test --disable-sandbox --disable-automatic-resolution --package-path Tests/PrimeValidationWorkflow --scratch-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-a-staging/Tests/PrimeValidationWorkflow/.build --filter PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests
~~~

Result: exit 0; 30 executed; 29 passed; one intentional Release-only skip;
zero failures; 4.254 seconds. An earlier pre-candidate compile stopped before
running tests because one new test needed the existing macOS 26 availability
annotation. The annotation was added and the complete focused command above
was the accepted rerun.

Focused Release source-admission proof:

~~~text
CLANG_MODULE_CACHE_PATH=/private/tmp/prime-driver-v2-gate-b-clang-module-cache SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/prime-driver-v2-gate-b-swiftpm-module-cache PRIME_PMHNP_COMPANION_ROOT=/Users/ergentics/Documents/Codex/2026-08-03/the-hard-authority-bind-is-corrected/work/prime-driver-v2-final-canonical.x8nPI1/companion swift test --disable-sandbox --disable-automatic-resolution -c release --package-path Tests/PrimeValidationWorkflow --scratch-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-a-staging/Tests/PrimeValidationWorkflow/.build --filter PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.testPublicReleaseAdmissionUsesEmbeddedSourceAuthority
~~~

Result: exit 0; Release build complete in 175.46 seconds; one selected test
passed with zero failures in 0.571 seconds. The companion root was clean at
commit `163fc100710ece48119bc25954452d10f6a84f7f`, canonical, mode `0755`, and
owned by `501:20`.

The reused scratch directory held already-materialized local dependencies;
automatic resolution was disabled. It is a compilation cache, not authority
or evidence. No dependency fetch, Actions job, root 904-test suite, Git/SwiftPM
role, shard, or Driver V2 child was run.

### Mutation and lifetime result matrix

| Proof | Result |
| --- | --- |
| Explicit PrimeCore test-host bind | passed; `productionSupervisorImageEligible == false` |
| Mapped image join on the test-host token | passed; device and inode equal their loaded-image values |
| Production DriverCore bind under Apple `xctest` | rejected and permanently poisoned |
| Sequential facade consume | exactly one winner; second consume rejected |
| Concurrent facade consume | exactly one winner; loser rejected |
| Frozen role-policy table | exact role order, arguments, environment, deadlines, streams, and results |
| Frozen phase budget +1 mutation | rejected by DriverCore before transfer; guarded source owner remained prepared |
| Root inode mismatch at transfer | rejected; image token poisoned; exact retry rejected |
| Missing required role-facade source | incomplete source snapshot rejection |
| Role-facade source mutation | source-identity mismatch; image token poisoned; no retry |
| Facade disposal | kernel lease released for diagnosis; original token remained transferred and authority was not restored |
| Static production-source scan | no new spawn implementation, Foundation `Process`, shell, Python, command language, role selector, execute, next-role, advance, or restore surface |

XCTest proves only owner mechanics. It does not prove production supervisor
identity. The test-host image token stays explicitly ineligible for production
and cannot close `supervisor_executable_image`. The production DriverCore
entry remains unreachable from the test seam and rejects the Apple host. A
future live invocation must still bind the exact dedicated Release self-image
against `intent.driverExecutable`; no XCTest success substitutes for that
dynamic proof.

### Exact-tree independent audit

| Luna audit | Bound candidate | Result |
| --- | --- | --- |
| Current-code ownership/security audit | commit `40b5bb31...33c7`; tree `326da31d...e806`; six paths | no blocker; implementation matched the reviewed tree plus only the canonical provenance reseal |
| Swift contract and conservation audit | same exact commit/tree | no blocker; `/swift` versus physical `swift-package`, 29 manifest/lock paths, 892/12 inventories, main, and provenance all conserved |

Both final audits were read-only. No Llama, build, test, network, GitHub, or
source edit was delegated to either audit.

### Authority after Gate B

| Observation or authority | Gate B terminal value |
| --- | --- |
| Test-host production image eligibility | false |
| Process execution | `UNOBSERVED` |
| Build execution | `UNOBSERVED` |
| XCTest inventory execution | `UNOBSERVED` |
| Swift Testing inventory execution | `UNOBSERVED` |
| Completion authorized | false |
| Scientific/product conclusion | `ABSTAIN` |
| Additional missing-authority enum cases closed by B | zero |

Gate B preserves Gate A's dedicated production-image prerequisite but creates
no serializable or lasting live authority. Eight live authority enum cases
remain missing after the Gate A predecessor checkpoint. The facade dies with
its owning process; a later invocation begins from fresh admission and cannot
restore it from this record, a lock leaf, or any public observation.

### Next permitted direction

Gate C is the only permitted successor. It must start from a fresh predecessor
freeze naming commit `40b5bb31fc7040c72c8c46af66944b60507033c7` and tree
`326da31d21a41c4f7342ad2b07ccbbd909bde806`. Its bounded purpose is gapless,
descriptor-held Prime and companion content continuity across the fixed role
sequence, with mutation at every boundary poisoning permanently.

Gate C must not enlarge `main.swift`, add a generic command/argv/environment/
cwd/deadline/role API, restore authority from facade observations, or launch a
child before both content closures and watches are continuously armed. Gate D
and later work, the root 904-test spend, GitHub, Stage 7, Metal, training, and
publication remain unauthorized by this checkpoint.

## C0 predecessor freeze

Status: `FROZEN_FOR_GATE_C_IMPLEMENTATION`

This record authorizes only the non-executing Gate C continuity slice. The
source predecessor is the Gate B implementation commit, not this rank-4
control branch. No child, Git probe, Swift probe, role advance, receipt, or
scientific observation is authorized.

### Exact predecessor split

| Pin | Exact value |
| --- | --- |
| Gate C source predecessor commit | `40b5bb31fc7040c72c8c46af66944b60507033c7` |
| Gate C source predecessor tree | `326da31d21a41c4f7342ad2b07ccbbd909bde806` |
| Direct Gate A parent commit | `8bfb27f2475ed336e4343150cd02dffb5cc0cc9d` |
| Direct Gate A parent tree | `5c8d30c0f666d2d7c0f86bff78e532b4d31fb25e` |
| Gate B durable-record commit | `fed39cfb3ea917f5d0e636c60d4c02833d189c3c` |
| Gate B durable-record tree | `d1dcfe1719209ea3cc8097ff3c30d648eb2e292b` |
| Durable record in source ancestry | false |
| Gate B source worktree at freeze | clean |
| Frozen supervisor main blob | `1b5582ac9a40dce9ea06b94a82c9985978069b76` |
| Frozen Gate B facade blob | `58f82888e7af1fdff798e9dd43db9e90acfc2f23` |
| Frozen admission blob | `8e4619b850d50f1f722c9c3a0ea8f3083a00dee5` |
| Frozen source-watch wrapper blob | `7b4f6c632b430d9391769cf86937b2ca0ea6bcda` |
| Frozen held-watch implementation blob | `1c7f8160b2c81fad00bfb6770d0d1721dd9fd9a5` |

Local source refs are sufficient for this implementation checkpoint. Their
absence from `origin` is not missing scientific evidence because neither GitHub
nor a released product claim is in scope.

### Gate C mutation allowlist

1. `Sources/PrimeCore/PrimeNativeNeuralGateHeldSourceClosure.swift` — add one
   closed complete-working-tree topology/limit policy while preserving the
   legacy Prime-source policy;
2. `Sources/PrimeCore/PrimeSecureHeldSourceWatch.swift` — internal bounded,
   descriptor-relative companion working-tree snapshot and neutral watch
   construction;
3. `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift` —
   retain the companion baseline and second watch, enforce combined capacity,
   and revalidate both roots;
4. `Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift` — one
   lock-protected, zero-argument `revalidateContinuity() -> Void` transition
   with permanent poison;
5. the existing isolated
   `PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` only; and
6. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` only for the final
   canonical source-identity reseal.

DriverCore, supervisor `main.swift`, package manifests, lock files, inventory
resources, root tests, `.github`, Stage 7, Metal, MLX/training, and product
paths are outside the allowlist.

### Closed companion working-tree policy

| Datum | Frozen value |
| --- | --- |
| Root kind | full local APFS checkout |
| Root `.git` entry | required real owner-safe directory; entry identity retained in the root inventory |
| `.git` descendants | excluded from Gate C content authority |
| Other hidden entries | included |
| Accepted node kinds | regular files and directories only |
| Symlink, FIFO, socket, or device | reject |
| Path components | printable ASCII, no slash/NUL/dot/dot-dot; raw-UTF-8 order |
| Maximum regular files | 4,096 |
| Maximum held directories | 4,096 |
| Maximum one-file bytes | 64 MiB |
| Maximum aggregate file bytes | 512 MiB |
| Maximum relative depth | 32 |
| Maximum entries per directory | 16,384 |
| Maximum aggregate directory entries | 65,536 |
| Capture/arm deadline | 30 seconds |
| Maximum combined Prime-plus-companion watchers | 4,096 |

The canonical companion measured at freeze has 1,306 regular files, 154
directories, 66,812,637 aggregate bytes, and a largest file of 32,833,664
bytes. Its complete non-`.git` topology requires 1,460 watches. The exact
Gate B Prime snapshot requires 539 file watches and 151 parent-directory
watches, for 690. The combined predecessor requirement is therefore 2,150,
which is below the frozen 4,096 ceiling. Prime's 8 MiB per-file provenance
limit remains unchanged and cannot be reused for companion files.

Every captured non-`.git` directory, including an empty directory, is an
explicit held directory with its own vnode registration and exact parent
inventory membership. An empty directory is never dropped merely because no
file path names it. A directory or file appearing after capture cannot become
part of the initial baseline: the complete topology join rejects it before the
guarded owner is published.

The companion snapshot is internal continuity state only. It is not a Git
HEAD, cleanliness, tracked-tree, manifest, or process observation. Gate D
owns canonical tracked-tree semantics; Gate E owns bounded live Git output and
must not cite the excluded `.git` subtree as watched by C.

### Gapless no-child ordering

~~~text
admission/root/toolchain replay
    -> arm Prime watch
    -> arm companion watch with complete topology join
    -> retain current supervisor/test-host image
    -> admission replay
    -> Prime watch checkpoint
    -> companion watch checkpoint
    -> publish guarded owner
    -> Gate B image bind and facade transfer
    -> zero-argument dual-root continuity checkpoints only
~~~

Both watch objects remain inside the same retained PrimeCore state. A failure
while arming the second watch drops the first through normal lifetime cleanup.
Any later error drops the facade's retained owner, sets it permanently
poisoned, and rejects retry even if bytes are restored.

### Required focused mutations

| Mutation | Required result |
| --- | --- |
| Prime file write or replacement | facade poisons; retry rejected |
| Companion regular-file write | facade poisons; retry rejected |
| Companion rename-away and restoration | poison remains permanent |
| Transient companion create/unlink | poison remains permanent |
| Hidden non-`.git` file mutation | poison remains permanent |
| Root `.git` replacement/removal | reject or poison |
| Pre-existing empty non-`.git` directory | retained and watched as explicit topology |
| New or transient empty directory after capture | reject or poison; never rebaseline |
| Symlink, `.git` file, FIFO, socket, or device | reject before guarded owner |
| Excess depth/count/bytes | bounded rejection |
| Mutation after admission and before watch construction | rejection; no rebaseline |

Gate C closes no process-derived authority and launches zero Driver V2
children. The first spawn remains a separately frozen isolated facade canary
after C, before Gate E and before any 904-test spend.

## Gate C continuity-only checkpoint

Status: `COMPLETE_CONTINUITY_ONLY`

This checkpoint records the closed, local Gate C source tree. It authorizes no
child launch, role advance, Git observation, root 904-test run, GitHub action,
or scientific/product conclusion.

### Exact source identity

| Pin | Exact value |
| --- | --- |
| Gate B predecessor commit | `40b5bb31fc7040c72c8c46af66944b60507033c7` |
| Gate B predecessor tree | `326da31d21a41c4f7342ad2b07ccbbd909bde806` |
| Gate C implementation commit | `129322d07aad8adae156f35b474608027ca1344a` |
| Gate C implementation tree | `84ae91c9324f0a5e566440c360bae723a6c2bb93` |
| Gate C implementation parent | `40b5bb31fc7040c72c8c46af66944b60507033c7` |
| Source commit time | `2026-08-22T10:45:26-07:00` |
| Changed path count | 6 |
| Embedded Prime source identity | `2dd8118749ca80eed4c35a6b645b29a493c27c44ace2352dc56fb3435b9c9f1b` |
| Canonical identity records | 538 |
| Canonical source snapshot files | 539, including the excluded embedded-provenance file |
| Source worktree after commit | clean |

| Allowed changed path | Gate C blob |
| --- | --- |
| `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` | `bd6d91d0d1483151513af6d34b20e70e633fc6f4` |
| `Sources/PrimeCore/PrimeNativeNeuralGateHeldSourceClosure.swift` | `73156c1baeaa64f902b12ac54032160b703ceca5` |
| `Sources/PrimeCore/PrimeSecureHeldSourceWatch.swift` | `14c08c0dd11f6ce7318f2486d9ba29ccce359f4b` |
| `Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift` | `67582c0a74c3019d92c0acdeff479c27d26929ea` |
| `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift` | `4aaafc965ad0405277a01eebb7a370d009872f54` |
| `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` | `f38cef7703e5d4c5dc8adec543fedde9bc3edb21` |

### Closed continuity data

| Gate C datum | Terminal value |
| --- | --- |
| Companion non-`.git` files | 1,306 held regular files |
| Companion non-`.git` directories | 154 held directories, including root and empty directories |
| Companion aggregate bytes | 66,812,637 |
| Companion largest file | 32,833,664 bytes |
| Companion watcher requirement | 1,460 |
| Prime watcher requirement | 539 files + 151 file-derived directories = 690 |
| Combined watcher requirement | 2,150 of 4,096 maximum |
| Root `.git` | recorded entry; descriptor-rejoined by device and inode |
| Root `.git` descendants | excluded; descendant churn accepted |
| Other hidden entries | included and held |
| Empty companion directories | explicit admission nodes and held watches |
| File and directory join | canonical path + device + inode + bounded metadata/content identity |
| Same bytes on a new inode | replacement; reject or permanently poison |
| Admission-to-watch mutation | reject before guarded owner publication; never rebaseline |
| Prime topology | unchanged legacy file-derived allowlist |
| Prime per-file ceiling | unchanged at 8 MiB |
| Companion per-file ceiling | 64 MiB |
| Revalidation surface | one zero-argument `revalidateContinuity() throws` operation |
| Failure state | permanent poison; retained owner dropped; retry rejected |
| Driver V2 children launched by the candidate | 0 |
| Git/Swift subprocess surface exposed by the facade | none |

The combined watch ceiling is checked before either watch set is published,
and the constructed watcher count must equal the preflight count. Both roots
are replayed around image retention in the frozen order: admission, Prime
watch, companion watch, image, admission, Prime watch, companion watch.

### Non-vacuous verification

| Verification | Exact result |
| --- | --- |
| Nested Debug focused class | 40 executed; 39 passed; 1 expected Release-only skip; 0 failures; 10.177 seconds |
| Canonical Release source-admission case | 1 executed; 1 passed; 0 failures; 1.808 seconds; Release build 179.98 seconds |
| Root held-source closure class | 8 executed; 8 passed; 0 failures; 0.010 seconds |
| `git diff --check` | clean |
| Final authority/security audit | PASS; no blocking finding |
| Final boundary/conservation audit | PASS; no blocking finding |
| Final focused-test audit | PASS; no remaining finding |

The Debug command was:

~~~text
swift test --package-path Tests/PrimeValidationWorkflow --filter PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests
~~~

The Release proof selected only
`PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.testPublicReleaseAdmissionUsesEmbeddedSourceAuthority`
with `-c release` and the clean canonical companion root at
`163fc100710ece48119bc25954452d10f6a84f7f`. Its exact companion path was:

~~~text
/Users/ergentics/Documents/Codex/2026-08-03/the-hard-authority-bind-is-corrected/work/prime-driver-v2-final-canonical.x8nPI1/companion
~~~

The Release case asserted the exact 2,150 combined watchers. It remained an
XCTest source-admission proof: the test-host token was production-ineligible,
production DriverCore bind against Apple `xctest` rejected and poisoned, and
`supervisor_executable_image` was not closed by the test seam.

| Required Gate C case | Observed result |
| --- | --- |
| Admission metadata includes a pre-existing empty directory | passed; exact directory set and vnode identity asserted |
| Admission metadata includes the root `.git` entry | passed; device and inode asserted; descendants absent |
| Companion same-bytes/new-inode replacement after admission | rejected; no rebaseline |
| Prime bytes restored before watch construction | rejected; no rebaseline |
| Companion transient create/unlink before watch construction | rejected; no rebaseline |
| Prime file mutation after facade transfer | permanently poisoned |
| Companion write, rename-away/back, transient entry, hidden entry, or empty-directory insertion | permanently poisoned |
| Root `.git` rename, replacement, or removal | rejected or permanently poisoned |
| Root `.git` descendant-only churn | accepted |
| Symlink, FIFO, or root `.git` file | rejected before guarded owner |
| Depth 33 or file bytes 64 MiB + 1 | bounded rejection |
| Sequential and concurrent one-shot transitions | exactly one winner |
| Production DriverCore bind under Apple `xctest` | rejected and permanently poisoned |
| Facade source scan | no spawn, process, argv, environment, cwd, timeout, role selector, or second owner surface |

### Conservation anchors

| Conserved object | Exact value |
| --- | --- |
| Supervisor `main.swift` blob | `1b5582ac9a40dce9ea06b94a82c9985978069b76` |
| Root `Package.swift` blob | `8e14c10aded588b3902a042341bca7acc842bcc6` |
| Root `Package.resolved` blob | `14d804bb4291720477240c27e24de6fbdc876b3b` |
| Nested validation `Package.swift` blob | `5c658c1e9006b9111a49789816a826467b3da9c1` |
| Nested validation `Package.resolved` blob | `69919288b1a5da256ff408a4d65106b23abc8f89` |
| DriverCore changed paths from Gate B | 0 |
| XCTest inventory blob | `5cde9d386b851673ac864321a75ae713cd136feb` |
| XCTest inventory | 892 lines; 114,186 bytes; SHA-256 `93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b` |
| Swift Testing inventory blob | `69515eee4fe6a11d99f708de81f10e2fbc4fbced` |
| Swift Testing inventory | 12 lines; 1,287 bytes; SHA-256 `487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3` |

### Authority boundary after Gate C

| Observation or authority | Gate C terminal value |
| --- | --- |
| Prime content continuity | closed for the unchanged legacy file-derived topology |
| Companion content continuity | closed for the complete non-`.git` topology plus root `.git` entry identity |
| Test-host production supervisor identity | false |
| Production `supervisor_executable_image` closure from XCTest | false |
| Driver V2 child execution | `UNOBSERVED` |
| Driver V2 build-role execution | `UNOBSERVED` |
| Gate E Git observation | `UNOBSERVED` |
| 892/12 root inventory execution | `UNOBSERVED` |
| Scientific/product conclusion | `ABSTAIN` |

Named residual: pre-existing empty directories inside Prime's legacy
`Sources`/`Tests`/`docs` roots remain outside its file-derived directory set.
Gate C did not widen Prime's topology or identity schema to absorb them. This
residual does not apply to the companion policy.

The only recommended successor is a new, separately frozen isolated facade
spawn canary on commit `129322d07aad8adae156f35b474608027ca1344a` and tree
`84ae91c9324f0a5e566440c360bae723a6c2bb93`. This checkpoint does not authorize
that spawn. Gate E, the root 904-test spend, GitHub, and publication remain
outside Gate C.

## V2-SPAWN-01 predecessor freeze — isolated facade spawn canary

Status: `FROZEN_FOR_V2_SPAWN_01_IMPLEMENTATION`

This is a separately named local containment-mechanics slice after Gate C. It
is not Gate C.1, D, E, F, G, H, or a 904-test authorization. It may create one
new closed child product and one zero-argument facade transition only. It
closes none of the eight live authorities that remained after Gate A.

### Exact predecessor split

| Pin | Exact value |
| --- | --- |
| Source predecessor commit | `129322d07aad8adae156f35b474608027ca1344a` |
| Source predecessor tree | `84ae91c9324f0a5e566440c360bae723a6c2bb93` |
| Source predecessor parent | `40b5bb31fc7040c72c8c46af66944b60507033c7` |
| Source predecessor worktree | clean |
| Durable-control predecessor commit | `5d2fce150dba636aea324f6e4a2bc699fe58bdc7` |
| Durable-control predecessor tree | `4ca2d398af9f02a83f2bca4ce9a8d81f3955a9c6` |
| Durable-control predecessor parent | `66abaf3db26ed40cdba49d3083c5552869cecdf1` |
| Durable-control predecessor worktree | clean |
| Durable control in source ancestry | false |
| GitHub or off-device execution | none authorized |

The aggregate source diff from the Gate C implementation commit to the source
candidate must be exactly the seven-path allowlist below. If the candidate is
one implementation commit, it is a direct child; if build-only pinning needs
an intermediate source commit, every intermediate and the aggregate remain on
that same bounded source lineage. This rank-4 control lineage remains separate
and is not a source predecessor. The worktree-clean value above records the
historical predecessor checkpoint, not the later implementation worktree.

### Exact source mutation allowlist

1. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` — final canonical
   source-identity reseal only;
2. `Sources/PrimeCore/PrimeValidationDriverV2IsolatedSpawnCanary.swift` — one
   new closed canary image/root holder, development-only start/terminal
   journal, and typed containment coordinator;
3. `Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift` — exactly one
   public zero-argument `spawnIsolatedContainmentCanary() throws` one-shot and
   its retained running/terminal/poison states; the fixed build/list policy
   table remains byte-for-byte unchanged;
4. `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift` —
   require the new PrimeCore source and add only a package-internal test-host
   transfer seam that consumes an already-opened no-follow executable
   descriptor, never a path;
5. `Tests/PrimeValidationWorkflow/Package.swift` — exactly one dependency-free
   executable product and target named
   `PrimeValidationWorkflowDriverV2SpawnCanary`, with linker stripping `-S`;
6. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2SpawnCanary/main.swift`
   — one new `@main` program that returns zero, parses no inputs, emits no
   bytes, writes no files, and creates no descendant; and
7. the existing focused
   `PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` only.

There is no fallback expansion. If the implementation requires a change to
the supervisor stdin frame, DriverCore, the frozen role table, the neutral
Darwin spawn owner, lifecycle, drains, FixtureChild, SecureChildIntegration,
Gate-D parsers, root tests, inventory resources, or a lock file, work stops for
a new freeze.

### Frozen custom-child policy

| Datum | Exact frozen value |
| --- | --- |
| Product, target, and image leaf | `PrimeValidationWorkflowDriverV2SpawnCanary` |
| Production image locator | exact sibling of the already-bound dedicated supervisor image |
| Test image locator | none; package-internal seam consumes an already-opened `O_NOFOLLOW_ANY` descriptor and derives its canonical name internally |
| Logical `argv[0]` | `prime-driver-v2-spawn-canary-v1` |
| Additional argv | none |
| Replacement environment | empty |
| Standard input | `/dev/null`, immediate EOF |
| Working directory | the already-held, private, empty Driver V2 workspace root |
| Child writes | none |
| Maximum wall time | 5,000,000,000 nanoseconds, established before spawn |
| Standard-output cap | 4,096 bytes; terminal accepted value is exact zero bytes plus EOF |
| Standard-error cap | 4,096 bytes; terminal accepted value is exact zero bytes plus EOF |
| Spawn implementation | existing `PrimeSecureChildDarwinSubstrate.spawnSuspended` only |
| Caller-supplied role/path/argv/env/cwd/deadline/cap | none |

The held child image must bind canonical path, descriptor, device, inode,
owner, mode, link count, exact bytes, exact byte count, and SHA-256. The
suspended mapped-main-image proof must join the same device and inode. A path
or matching byte string without the vnode join is rejection, not authority.

The workspace descriptor already retained by Gate C is the cwd authority. No
directory is created below it, and the workspace must be exactly empty before
spawn and after reap. Prime, companion, evidence, lease, and canary-journal
roots are never the child's cwd.

### New-image measurement barrier

The new product has no predecessor executable identity. Before its first
launch, implementation must:

1. build the dependency-free child without executing it in two disjoint
   scratch roots;
2. require byte-for-byte equality and record its byte count, SHA-256, Mach-O
   UUID, platform, minimum OS, and SDK fields;
3. embed the exact byte-count and SHA-256 pin in PrimeCore;
4. reseal the Prime embedded source identity and checkpoint the resulting
   source candidate; and
5. rebuild from that exact candidate and require the held binary to match the
   embedded pin before the first `posix_spawn`.

Build-only identity measurement is authorized by this freeze. Executing an
unmeasured, unpinned, dirty-tree, or post-checkpoint-different child is a hard
stop. Building or locating the child at Driver V2 runtime through SwiftPM is
forbidden.

### Development-only durable canary journal

The general hard stop forbids resuming any child before its start is durably
published. V2-SPAWN-01 therefore owns exactly two fixed leaves in one new
pre-existing, private `0700`, initially empty journal root at the exact
internally derived sibling path
`workspaceRoot.absolutePath + ".v2-spawn-01-journal"`:

- `v2-spawn-01-start.json`
- `v2-spawn-01-terminal.json`

The journal root must be canonical, local APFS, a real no-symlink directory,
owned by the effective user, group-consistent with the workspace, mode `0700`,
link count two while empty, descriptor-held, named-path rebound by device and
inode, and disjoint/non-nested with Prime, companion, workspace, evidence, and
lease roots.

Each leaf is exclusive/no-replace, bounded canonical sorted JSON plus one LF,
fully written, file-synchronized and full-synchronized, changed to exact
read-only mode `0400`, synchronized again after chmod, directory-synchronized,
reopened without following links, read back, identity-joined, and SHA-256
verified. An existing leaf rejects. A start without a terminal is incomplete
and permanently nonretryable under that journal root. `0400` is not claimed
as filesystem immutability; integrity derives from the held descriptor,
exclusive namespace, vnode/name join, exact bytes, and repeated readback.

The start record binds at least the schema/stage, embedded Prime source
identity, held canary byte count/hash/device/inode, held workspace
device/inode, child PID/session/group, spawn flags/return time, absolute
deadline bounds, suspended cwd join, and suspended mapped-image join. The
complete canonical start bytes are hashed only after durable readback. The
terminal binds that external full-start-leaf SHA-256, exact-PID wait, exit
status, independent drain terminal facts, process-group emptiness, post-reap
continuity, and workspace emptiness. The complete canonical terminal bytes are
then hashed after durable readback and retained as the external terminal
binding. Neither leaf attempts an undefined fixed-point self-hash.

These two leaves are local development containment evidence only. They are
not the Driver V2 evidence ledger, a Gate-H writer, a phase/shard/final
receipt, an outer publication envelope, a restorable capability, or released
product truth. No Prime execution, completion, PASS, GROUNDED, scientific, or
product authority can be decoded or minted from them.

### Required one-child ordering

~~~text
consume one-shot canary transition
    -> establish absolute deadline
    -> revalidate Gate C Prime + companion continuity
    -> revalidate held child image and empty held workspace
    -> require the private canary journal root empty and identity-stable
    -> posix_spawn the pinned child suspended, exactly once
    -> adopt both memory drains and the exact-child obligation
    -> prove SID == PGID == PID
    -> prove suspended cwd device/inode join
    -> prove suspended mapped-image device/inode join
    -> revalidate Gate C continuity and all held inputs
    -> exclusively publish, sync, reopen, and verify durable start
    -> revalidate Gate C continuity and all held inputs again
    -> deliver SIGCONT exactly once, after start publication
    -> observe death and complete independent bounded EOF drains
    -> require pre-reap group membership == [PID]
    -> exact waitpid(PID) exactly once
    -> require process_group_empty
    -> revalidate Gate C continuity
    -> require workspace still empty and both frozen root names rebound
    -> exclusively publish, sync, reopen, and verify terminal
    -> retain Gate C continuity owner in a canary-complete, non-advancing facade
~~~

Every error after spawn transfers through the existing cleanup authority. The
method may return an error only after exact containment and closed drains are
proven; a cleanup result of `mustFailStop` terminates the abandoning process
through the established exit-70 path. No second spawn, shell, `Process`,
`fork`, `exec`, callback, or cleanup by caller-supplied path is allowed.

### Required focused proof

| Proof | Required terminal fact |
| --- | --- |
| Source surface | exactly one public zero-argument canary method returning `Void`; no generic execution inputs or role advance |
| Child source | no argv/stdin/env parsing, output, file operation, process creation, Git/SwiftPM, network, or product/science code |
| Image | two disjoint build-only outputs identical; exact embedded pin; held descriptor and suspended mapping join |
| Cwd | held workspace descriptor joins the suspended child and remains empty after reap |
| Start order | durable start readback completes before the sole `SIGCONT` delivery |
| Success | exit 0; exact PID reap; group empty; both streams zero-byte EOF and closed |
| Continuity interval | both Gate C watches remain armed; Prime or companion mutation permanently poisons after containment |
| One shot | sequential and concurrent calls produce at most one PID and one start leaf; retry rejected |
| Journal collision/failure | no second child; after-spawn failures contain before return or fail-stop |
| XCTest boundary | test-host token remains production-ineligible and cannot close `supervisor_executable_image` |
| Role conservation | role remains `build`; build/list policies and observations remain unchanged and unobserved |
| Scope | no Driver V2 build/list/Git child, no staging tree, no 904 tests, no GitHub |

XCTest may exercise mechanics through the PrimeCore-only held-descriptor and
fixed-interlock seams. Such a seam is a concrete canary test mechanism, not a
generic callback or production image loader. It cannot establish production
supervisor identity. A later optional Release self-image proof must use an
excluded harness; the frozen supervisor `main.swift` is not enlarged here.

### Predecessor conservation anchors

| Conserved object | Exact predecessor value |
| --- | --- |
| Supervisor `main.swift` blob | `1b5582ac9a40dce9ea06b94a82c9985978069b76` |
| DriverCore supervisor-image bridge blob | `6842674b7b29b45d7cb3cc0753f6ab2f1b4b9c10` |
| DriverCore role bridge blob | `15bb266ea5bad4cac96c54fdfabe4d9508e5301d` |
| Root `Package.swift` blob | `8e14c10aded588b3902a042341bca7acc842bcc6` |
| Root `Package.resolved` blob | `14d804bb4291720477240c27e24de6fbdc876b3b` |
| Nested `Package.swift` predecessor blob | `5c658c1e9006b9111a49789816a826467b3da9c1`; sole authorized manifest drift |
| Nested `Package.resolved` blob | `69919288b1a5da256ff408a4d65106b23abc8f89` |
| Sole `posix_spawn` owner blob | `a0a63e9e44b787aaa84cce7381e3af9f4b67fb49` |
| Existing secure-child kernel blob | `bfa381796b9647863e704006dbaa1406c533c7c5` |
| Existing supervision blob | `13d882363479143d2a207375ac3eb84971fabb35` |
| Existing FixtureChild source blob | `5e45832ed046da7bfd4541ad362018fad97371f5` |
| Existing SecureChildIntegration source blob | `cce94e857f770f8108d7a694675ca75386a40ddb` |
| Gate C held-source closure blob | `73156c1baeaa64f902b12ac54032160b703ceca5` |
| Gate C held-source watch blob | `14c08c0dd11f6ce7318f2486d9ba29ccce359f4b` |
| Gate C admission predecessor blob | `4aaafc965ad0405277a01eebb7a370d009872f54` |
| Gate C facade predecessor blob | `67582c0a74c3019d92c0acdeff479c27d26929ea` |
| Gate C embedded identity | `2dd8118749ca80eed4c35a6b645b29a493c27c44ace2352dc56fb3435b9c9f1b` |
| Gate C provenance blob | `bd6d91d0d1483151513af6d34b20e70e633fc6f4` |
| Root XCTest inventory | 892 lines; 114,186 bytes; SHA-256 `93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b` |
| Root Swift Testing inventory | 12 lines; 1,287 bytes; SHA-256 `487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3` |

Adding the nested product intentionally changes the nested manifest; it must
be recorded as an exact old-to-new blob transition, never reported unchanged.
Both lock files and the root package graph remain unchanged. The new PrimeCore
coordinator and nested child source add two snapshot files; the child also
adds one file-derived directory. With the exact allowlist and no deletions,
the required expected candidate values are 541 snapshot files, 540 canonical
identity records, 541 Prime file watches plus 152 Prime directory watches =
693 Prime watches, and 693 + 1,460 = 2,153 combined watches. These values must
still be recomputed from the candidate and resealed; any mismatch is a hard
stop, not an inferred correction. Companion topology and the 1,460 companion
watches remain unchanged. Prime's legacy topology policy and 8 MiB per-file
ceiling remain unchanged.

### Authority ceiling after a passing canary

Only the local test-host development fact
`test_host_isolated_facade_spawn_canary_observed` may become true for the exact
pinned candidate and journal. It is not added to the production
missing-authority enum and cannot satisfy another gate. Because frozen
supervisor `main.swift` has no call edge to this transition, production
supervisor-to-canary composition and public process execution remain
`UNOBSERVED`.

The following remain exactly as before this slice:

- `prime_git_head_and_clean_process_observation`: `UNOBSERVED`;
- `companion_git_head_and_clean_process_observation`: `UNOBSERVED`;
- `swift_version_process_observation`: `UNOBSERVED`;
- `swift_target_info_process_observation`: `UNOBSERVED`;
- `swiftpm_build_execution`: `UNOBSERVED`;
- `artifact_staging`: `UNOBSERVED`;
- `xctest_inventory_execution`: `UNOBSERVED`;
- `swift_testing_inventory_execution`: `UNOBSERVED`;
- completion, shard, receipt publication, science, and product: unauthorized
  or `ABSTAIN`.

After a checkpointed and independently audited canary, Gate D's pure
manifest/parser mechanics is the only permitted next freeze. Gate E may be
frozen only after a separate accepted Gate D checkpoint. This freeze itself
authorizes neither successor.

## V2-SPAWN-01 durable containment-canary checkpoint

Status: `CHECKPOINTED_LOCAL_CONTAINMENT_MECHANICS_ONLY`

### Frozen result identity

| Field | Exact value |
| --- | --- |
| Classification | local, bounded, isolated containment canary; not D, E, F, G, H, or 904 |
| Gate C source predecessor | `129322d07aad8adae156f35b474608027ca1344a` |
| Gate C source predecessor tree | `84ae91c9324f0a5e566440c360bae723a6c2bb93` |
| Initial contained-incomplete source | `5b76bee7c60f317730996196c105e255442cc649` |
| Initial contained-incomplete tree | `bbbccb903ea20fc305142c8713c47bbc950043d6` |
| Final repaired source | `9f7d95a5bebd492827f71fa0bb340d5af1859a90` |
| Final repaired source tree | `f3f4a244e7557227b40d390b1d7246ced41b21d1` |
| Final source parent | `5b76bee7c60f317730996196c105e255442cc649` |
| Freeze / corrected freeze | `294321188acfd9a7def37536cd217908f21064dc` / `6e2648469b55f822bc67079dbf3408c355e035d6` |
| Durable-control predecessor tree | `154507359294e76273cfeeaca6b90338c4350aa6` |
| Embedded Prime source identity | `faeafa93ed8a9331aa8608769ab7a2304c8b20764dc584279f84ca9b85d0c4e6` |
| Source topology | 541 snapshot files; 540 canonical identity records; 152 Prime authority directories |
| Watch topology | 541 Prime files + 152 Prime directories = 693; companion = 1,460; combined = 2,153 / 4,096 |
| Source aggregate from Gate C | exactly the frozen seven paths; no expansion |
| Final source worktree | clean |
| Durable control in source ancestry | false |

### Exact final source blobs

| Path | Final blob |
| --- | --- |
| `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` | `1085823f9705a8ec566ec28aa4ad0824ad352c97` |
| `Sources/PrimeCore/PrimeValidationDriverV2IsolatedSpawnCanary.swift` | `1c174ffd12173f492e9bab68aff07ef2df5b74d7` |
| `Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift` | `5c59eaaa5831bbd058f358ab99e028f54d393739` |
| `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift` | `446e044b02451252e9c258f156cc32339581f053` |
| `Tests/PrimeValidationWorkflow/Package.swift` | `b8c29f2530efa863b99f0ddc7b32a363e7b525ed` |
| `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2SpawnCanary/main.swift` | `a3a37f5782d9f7c904737a91d29718f839f2072a` |
| `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` | `0f577c505a24576eca5e1e7d258ba57c97e2fcb8` |

All conserved predecessor anchors outside the exact mutation allowlist
remained exact. In particular, supervisor `main.swift`, both DriverCore
bridges, the frozen role-policy suffix, root package files, both lock files,
the Darwin spawn owner, the child kernel and supervision owner, both Gate C
source-watch owners, the fixture children, and the 892/12 inventories did not
change.

### Pinned child identity and build-only evidence

| Field | Exact value |
| --- | --- |
| Product, target, and image leaf | `PrimeValidationWorkflowDriverV2SpawnCanary` |
| Child source byte count | 381 |
| Child source SHA-256 | `052b27259c5bf39748bafbc22eeafb205fb1b3e00e247cda3e368c8ff2dbdd9c` |
| Release image byte count | 33,784 |
| Release image SHA-256 | `ced48ad5cb41a3a2e13c779f57ca008b213425d6e02ea7dc827bdd6ddfd6988e` |
| Mach-O UUID | `2970B4C8-7A39-30C2-B576-383FF950C1D3` |
| Platform / minimum OS / SDK | macOS / 14.0 / 26.5 |
| Frozen load-command transcript SHA-256 | `7b1ba98f32973d7c9a2ec356fcbadb0d4601d599261f4eee692c041dfc256474` |
| Two disjoint prelaunch Release builds | byte-identical PASS; child not executed |
| Fresh Release build from final source | byte-identical PASS in `/private/tmp/v2-spawn-01-repaired-offline.Gqrt3o` |
| Final Release `PrimeCore` compile | PASS |
| Final Debug nested test-bundle compile | PASS; tests not run by the build command |

Fresh scratch SwiftPM planning first failed closed on blocked GitHub dependency
and MLX-submodule resolution. No network permission was granted and no remote
dependency was accepted. The final fresh build used the already-present local
repository cache. A transient Git environment mapping redirected the two MLX
submodule URLs to the already-present local submodule repositories; no
persistent checkout configuration changed and no fetch succeeded. GitHub
Actions, a hosted runner, and an admitted-tree Driver V2 SwiftPM child were not
used.

### Consumed incomplete attempt

| Field | Recorded result |
| --- | --- |
| Source / tree | `5b76bee7c60f317730996196c105e255442cc649` / `bbbccb903ea20fc305142c8713c47bbc950043d6` |
| Classification | `INCOMPLETE` / `ABSTAIN` |
| First rejection | `driver_v2_isolated_spawn_canary_journal_authorized_root` |
| Child state at rejection | created suspended; never received `SIGCONT` |
| Root transition | the synchronized, reopened start leaf changed local APFS directory `st_nlink` from 2 to 3 |
| Cleanup | returned only after the existing containment path reaped the exact child and closed drains |
| Terminal | none; no success authority; journal identity permanently nonretryable |

The repaired source permits only the two fixed authorized root transitions:
empty-to-start is exactly `2 -> 3`, and start-to-terminal is exactly `3 -> 4`.
Device, inode, owner, group, and mode remain equal across publication. Exact
inventory, held leaf descriptors, leaf vnode/metadata/bytes/hash, full
post-publication identity stability, and named-path rebound remain mandatory.
The full accepted post-publication identity becomes the next exact read-only
baseline.

### Final focused evidence

All rows below ran as separate focused filters on final source
`9f7d95a5bebd492827f71fa0bb340d5af1859a90`. Aggregate result: 9 selected
tests, 9 passed, 0 failed. No broad class filter and no 904-test inventory ran.

| Individual test | Result | Closed fact | Explicit non-claim |
| --- | --- | --- | --- |
| `testIsolatedSpawnCanarySourceAndManifestAreClosed` | PASS | exact silent child bytes; one dependency-free product/target; deadline, continuity, journal, then sole spawn ordering | no runtime authority |
| `testFixedRoleFacadeSourceHasOnlyClosedCanaryExecutionSurface` | PASS | one public zero-argument canary transition; no generic command inputs | no build/list advance |
| `testProductionDriverV2BridgeRejectsXCTestHost` | PASS | production DriverCore bind against Apple `xctest` rejects and poisons | XCTest does not close `supervisor_executable_image` |
| `testIsolatedSpawnCanaryClosesOnlyContainmentMechanics` | PASS | held image and cwd joins; durable start before resume; silent exit 0; exact reap; empty group; post-reap test-host fixture continuity; terminal binds start | no process/build/inventory role observation |
| `testConcurrentIsolatedSpawnCanaryHasExactlyOneWinner` | PASS | two simultaneous entrants; one winner; journal root observed at exact link counts 2, 3, and 4 on one vnode/mode/owner | no retry authority |
| `testPrimeMutationDuringIsolatedSpawnCanaryPoisonsFacade` | PASS | Prime mutation poisons after containment; `ECHILD`, group `ESRCH`, empty workspace/evidence | no terminal success |
| `testCompanionMutationDuringIsolatedSpawnCanaryPoisonsFacade` | PASS | companion mutation poisons with the same containment postconditions | no terminal success |
| `testIsolatedSpawnCanaryJournalCollisionPoisonsBeforeSpawn` | PASS | preexisting start leaf poisons before spawn without overwrite | no child and no retry |
| `testIsolatedSpawnCanaryPostSpawnJournalCollisionContainsAndPoisons` | PASS | terminal collision contains exact child/group and poisons; workspace/evidence empty | collision leaf is not terminal authority |

Across the passing clean interval, the deadline was established before spawn;
the held child descriptor joined the suspended mapped vnode; SID, PGID, and
PID were equal; the held workspace joined the suspended cwd; the fully synced
and reopened start leaf preceded the sole resume; stdout and stderr each
reached zero-byte EOF and closed independently; the exact PID exited 0 and was
reaped once; the process group was empty; both test-host fixture Gate C
continuity mechanisms survived; the workspace stayed empty; and the terminal
leaf bound the complete external start-leaf SHA-256. Fixture journals were
throwaway local mechanics evidence and were disposed after assertions; they
are not released product artifacts.

### Authority ceiling and successor

| Authority | State after this checkpoint |
| --- | --- |
| `test_host_isolated_facade_spawn_canary_observed` | true, for this exact source/image and mechanics only |
| Production supervisor-to-canary composition | `UNOBSERVED` |
| Public production process execution | `UNOBSERVED` |
| Driver V2 Prime Git HEAD + clean process observation | `UNOBSERVED` |
| Driver V2 companion Git HEAD + clean process observation | `UNOBSERVED` |
| Driver V2 Swift version process observation | `UNOBSERVED` |
| Driver V2 Swift target-info process observation | `UNOBSERVED` |
| Driver V2 SwiftPM build-role execution | `UNOBSERVED` |
| Driver V2 artifact staging | `UNOBSERVED` |
| Driver V2 XCTest inventory-role execution | `UNOBSERVED` |
| Driver V2 Swift Testing inventory-role execution | `UNOBSERVED` |
| Completion, shard, Driver V2 evidence-ledger publication, science, product, release | unauthorized or `ABSTAIN` |

Outer workstation build and focused-test harness activity does not close or
populate any of those Driver V2 role observations.

The facade remains positioned at frozen `build`; no build/list role advanced
or was consumed. Gate D is the sole permitted successor on source
`9f7d95a5bebd492827f71fa0bb340d5af1859a90` and tree
`f3f4a244e7557227b40d390b1d7246ced41b21d1`: tracked-tree manifest/parser
mechanics only, no live Git and no child, under a separately frozen allowlist.
This durable-control commit is prose rank 4 and is not Gate D's source
predecessor. Gate E remains the first named Git/Swift process and is not
authorized by this checkpoint.

## Gate D0 predecessor freeze — canonical tracked-tree bytes and held join

Status: `FROZEN_NOT_EXECUTED`

### Exact predecessor and rank

| Field | Exact value |
| --- | --- |
| Gate | D only; canonical tracked-tree parser, manifest, and held-entry join mechanics |
| Source predecessor | `9f7d95a5bebd492827f71fa0bb340d5af1859a90` |
| Source predecessor tree | `f3f4a244e7557227b40d390b1d7246ced41b21d1` |
| Source predecessor parent | `5b76bee7c60f317730996196c105e255442cc649` |
| Embedded source identity | `faeafa93ed8a9331aa8608769ab7a2304c8b20764dc584279f84ca9b85d0c4e6` |
| Durable-control predecessor | `623192cd2a65908dc7e956135f264b99380ed480` |
| Durable-control predecessor tree | `dc4dd338d1c91ddbcb5c83bd6a7317a03080d4eb` |
| Worktree requirement | clean before the first source mutation |
| Durable-control rank | prose rank 4; never a source predecessor or execution fact |

Gate D closes only
`canonical_tracked_tree_parser_manifest_and_held_join_mechanics`. It closes
zero `PrimeValidationSwiftPMMissingAuthority` cases. Both live Git process
observations, both production tracked-tree bindings, all Swift/build/list
roles, completion, science, product, and release remain `UNOBSERVED` or
`ABSTAIN`.

### Exact source mutation allowlist

| Ordinal | Path | Permitted mutation |
| --- | --- | --- |
| 1 | `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` | exact source-identity reseal only |
| 2 | `Sources/PrimeCore/PrimeValidationDriverV2TrackedTreeHeldEntry.swift` | new non-Codable held-entry observation and vnode/name-join mechanics |
| 3 | `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift` | add both new Gate D source owners to every existing required/replay source list only |
| 4 | `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore/PrimeValidationDriverV2TrackedTreeManifest.swift` | new pure raw-byte parser, canonical manifest, and declaration-binding mechanics |
| 5 | `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationDriverV2AdmissionTests.swift` | pure fixture bytes, canonical digest fixtures, binding mutations, and source contract checks only |
| 6 | `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` | synthetic source fixture and required-source-list reseal only |

No package manifest, lock file, resource, supervisor `main.swift`, facade,
spawn canary, process substrate, C watch owner, receipt schema, planner, role
bridge, Git transport, `.github`, root test, inventory list, or documentation
path is in the source allowlist. A changed path outside these six is a hard
stop.

The two new source files add two files and no directory. With no deletion or
rename, the candidate must measure exactly 543 source-snapshot files, 542
canonical identity records, and 152 Prime authority directories. The watch
topology must be 543 Prime files plus 152 Prime directories = 695 Prime
watches; companion remains 1,460; combined must be 2,155 / 4,096. Prime's
8 MiB source-provenance per-file ceiling and legacy allowlisted topology do
not change. Any measured mismatch stops the slice and requires a corrected
freeze.

### Frozen module and authority split

| Owner | Gate D responsibility | Explicit non-authority |
| --- | --- | --- |
| PrimeCore | construct an immutable, non-Codable held-entry observation only after descriptor-read identity and named-path rebound identities agree | no public path loader, descriptor input, root selector, facade transition, or restorable capability |
| DriverCore | parse bounded caller-supplied fixture bytes, join them one-for-one to PrimeCore held observations, emit canonical manifest bytes, and bind the two computed digests to the existing declaration fields | no filesystem, Git, Swift, process, environment, cwd, timeout, callback, child, or receipt-minting authority |

`PrimeValidationRepositoryAdmissionReceiptV2`, its existing
`repositoryTrackedTreeSHA256` and `companionTrackedTreeSHA256` fields, and its
Codable layout remain unchanged. Its current validation remains declaration
and chain-shape validation only. Gate D adds a non-Codable binding value that
requires both canonical manifests, their recomputed SHA-256 values, and the
exact repository receipt identity. A bare receipt or a well-formed arbitrary
64-hex digest cannot construct or validate that binding. Every future live or
positive path must accept the bound form plus a retained PrimeCore live
capability; Gate E owns that composition.

### Frozen raw byte grammar and limits

The future Gate E Git role supplies exact bytes equivalent to:

~~~text
git rev-parse --show-object-format
git ls-tree -r -z --full-tree <exact-commit> --
~~~

Gate D launches neither command. Its fixtures must satisfy:

| Item | Exact Gate D rule |
| --- | --- |
| Object-format stdout | exactly five bytes: `sha1` plus one LF; no CR, extra LF, prefix, suffix, or `sha256` |
| Tree record | `mode SP blob SP lowercase-40-hex-object-id TAB path-bytes NUL` |
| Tree output framing | nonempty and at most 16 MiB; every record is NUL-terminated, the final byte is NUL, and an extra trailing NUL/empty record rejects |
| Entry count | 1 through 4,096 inclusive |
| Accepted modes | `100644`, `100755`, and `120000` only; `040000`, `160000`, and every other mode/type reject |
| Git object identity | exact lowercase nonzero SHA-1 object ID; SHA-1 is repository compatibility identity only, not authenticity or collision resistance |
| Path representation | raw bytes remain authoritative and are encoded as Foundation `Data` in canonical JSON; never `String(cString:)`, lossy UTF-8, locale, or Unicode normalization |
| Path safety | relative, nonempty, at most 1,023 bytes, at most 32 components, each component 1 through 255 bytes; no NUL, empty, `.` or `..` component; root `.git` and `.git/**` reject |
| Ordering | strictly increasing unsigned raw-path byte order; duplicate and blob/ancestor prefix collision reject |
| Per-file bytes | Prime 8 MiB; companion 64 MiB; fixed by manifest role, never caller-selected |
| Aggregate held bytes | at most 512 MiB with checked arithmetic |
| Canonical manifest bytes | at most 64 MiB |

Tabs, line feeds, carriage returns, invalid UTF-8, and backslashes inside an
otherwise safe path component are data, not separators, because NUL frames
the path and JSON carries its raw bytes. Tests must prove that these bytes are
preserved rather than normalized.

`100644` and `100755` require a held regular-file observation with matching
executable-bit semantics. `120000` requires an explicitly held no-follow
symlink observation whose target bytes, symlink vnode, post-read descriptor
identity, and named-path rebound identity agree. A caller-declared target is
not admitted. Before construction, the raw target bytes must lexically resolve
against the raw link-path parent without following or Unicode conversion;
absolute or NUL-bearing targets, empty or dot components, traversal above the
admitted root, fixed-limit overflow, and a resolved root `.git` entry reject.
Gate C's current production closures construct no symlink-held
observation, so a live tracked symlink in Gate E is a fail-closed `ABSTAIN`
pending a separately frozen no-follow acquisition slice. Pure D symlink
mechanics do not claim that live support exists. Gitlinks always reject.

### Held join and stable canonical manifest

For every parsed Git entry, Gate D requires exactly one held observation at
the same raw path and in the same canonical order. PrimeCore's observation
must bind:

- held kind and POSIX file type;
- opened, post-read descriptor, and post-read named-path device/inode/owner/
  group/mode/link-count/byte-count identities, all equal;
- link count exactly one;
- descriptor-read content or no-follow symlink-target bytes;
- exact byte count and SHA-256; and
- Git blob SHA-1 recomputed over `blob <decimal-byte-count> NUL <exact-bytes>`.

Missing, extra, renamed, reordered, replaced, duplicate, unsafe, unheld,
wrong-kind, mode-mismatched, hash-mismatched, or same-bytes/new-inode entries
reject. The join returns no live descriptor and cannot be decoded into one.

The canonical manifest contains only stable evidence data:

| Canonical field | Bound value |
| --- | --- |
| `artifact_kind` | exact Driver V2 tracked-tree-manifest V1 literal |
| `schema_version` | `1` |
| `root_role` | exactly `repository` or `companion` |
| `object_format` | `sha1` |
| raw tree | exact bytes, byte count, and SHA-256 |
| entries | canonical raw-path order; path bytes, Git mode/type/object ID, held kind, byte count, held SHA-256 |

Host-local vnode IDs prove the live join but are deliberately excluded from
the durable manifest digest. The tracked-tree SHA-256 is the hash of exact
`PrimeCanonicalJSON` bytes which do not contain that digest. Decode must fully
validate, re-encode, and require byte equality; unknown/duplicate keys,
alternate key order, whitespace, trailing LF, and noncanonical encodings
reject rather than normalize.

### Focused proof and source-candidate discipline

Before the source candidate exists, only compile, source-contract inspection,
topology recount, and provenance reseal are authorized. No test is run to
define the candidate. After one clean source commit/tree exists, run only the
individually named nested Gate D fixture tests covering:

1. golden regular/executable canonical bytes and digest;
2. raw non-UTF-8/control path preservation and deterministic re-encoding;
3. every proper prefix, terminal-NUL, separator, object-format, mode/type, and
   object-ID rejection class;
4. unsafe, duplicate, noncanonical-order, and file/ancestor path rejection;
5. missing, extra, rename, executable-bit, held-kind, SHA-1, SHA-256, count,
   and fixed-cap rejection;
6. same-bytes/new-inode and any other vnode/name-rebound rejection;
7. conditional held-symlink mechanics plus unheld symlink and all gitlink
   rejection; and
8. canonical decode/re-encode, self-hash exclusion, receipt-digest binding,
   arbitrary-digest rejection, and source-surface exclusions.

No broad test target/class filter, live admission proof, Git/Swift command,
Driver V2 child, build/list role, staged root, inventory run, 904, GitHub,
network request, or dependency fetch is authorized. Outer local compilation
and Git worktree/commit bookkeeping are not Driver V2 observations.

### Conserved predecessor data and successor

The following predecessor blobs must remain exact: supervisor `main.swift`
`1b5582ac9a40dce9ea06b94a82c9985978069b76`; DriverCore contracts/planner/
admission `25daa69226aab8ca88894c6c93834aa42313e33d` /
`38d703b86a98d08cc8b88e0dd23d828464ece46b` /
`c4e15ff38a0697e724a0d1208e3824aba15691dd`; role and image bridges
`15bb266ea5bad4cac96c54fdfabe4d9508e5301d` /
`6842674b7b29b45d7cb3cc0753f6ab2f1b4b9c10`; facade and isolated canary
`5c59eaaa5831bbd058f358ab99e028f54d393739` /
`1c174ffd12173f492e9bab68aff07ef2df5b74d7`; C held-source closure/watch
`73156c1baeaa64f902b12ac54032160b703ceca5` /
`14c08c0dd11f6ce7318f2486d9ba29ccce359f4b`; forbidden Process-based Git
transport `a2159438ed945e8cfd9cfe1fec5f86a6046c5832`; and the Darwin spawn,
secure-child, and supervision owners already frozen above. Both package
manifests, both lock files, the exact spawn-canary source/image pin, and the
892/12 root inventories remain unchanged.

On a passing source checkpoint, Gate E alone may be frozen on Gate D's exact
implementation commit/tree. Gate E is the first live Git/Swift process slice
and must provide bounded raw bytes plus a gapless retained PrimeCore join.
This D0 freeze authorizes neither Gate E source nor any process execution.

## Gate D durable checkpoint — canonical tracked-tree mechanics

Status: `CHECKPOINTED_LOCAL_PURE_MECHANICS_ONLY`

### Exact result identity

| Field | Exact value |
| --- | --- |
| Source predecessor | `9f7d95a5bebd492827f71fa0bb340d5af1859a90` |
| Source predecessor tree | `f3f4a244e7557227b40d390b1d7246ced41b21d1` |
| Gate D source | `272baaba5e4e3be3f17f6c1704e4622b514b12d8` |
| Gate D source tree | `fdbf508d3a461f4e5ba5098453c6c1f8351f75b1` |
| Gate D source parent | `9f7d95a5bebd492827f71fa0bb340d5af1859a90` |
| Initial / corrected freeze | `ba5da9206284a0e5487fc79f88fd7742df366efc` / `b0945df265f0c379cdf300a1ea1972b8545b258e` |
| Corrected freeze tree | `a75421ce4dc97cbda3dd43bb746ac910806f83e2` |
| Embedded Prime source identity | `36fed0d96845ea8f5304cd762f21cbf487d278fd00c90080e4b35ffffbcb18c0` |
| Source topology | 543 snapshot files; 542 canonical identity records; 152 Prime authority directories |
| Watch topology | 543 Prime files + 152 Prime directories = 695; companion = 1,460; combined = 2,155 / 4,096 |
| Root inventories | 892 / 12 unchanged; exact byte counts and SHA-256 unchanged |
| Source worktree after proof | clean |
| Durable control in source ancestry | false |

The first freeze was corrected before the source candidate commit to require
raw-byte lexical symlink-target containment. The accepted source is a single
commit directly on the V2-SPAWN-01 checkpoint; neither durable-control commit
is in its ancestry.

### Exact six source blobs

| Path | Gate D blob |
| --- | --- |
| `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` | `a9bde6d8af34491251695ff4d231300bde54198c` |
| `Sources/PrimeCore/PrimeValidationDriverV2TrackedTreeHeldEntry.swift` | `be1f825bde835b6c8d4f76a217ec49391a601085` |
| `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift` | `746bc90e74a916953ea2ea4d8a39f972eaedd25e` |
| `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore/PrimeValidationDriverV2TrackedTreeManifest.swift` | `340c65f658f3a03a5f4991dfcd88b44b963bee7f` |
| `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationDriverV2AdmissionTests.swift` | `3c34467d8a2b7d98df4b0582820efed8416de911` |
| `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` | `d82f2f16c972eaf3e2910e4f44ab8e361b523f7b` |

The commit contains exactly those six paths: two additions, four mutations,
1,929 insertions, and 6 deletions. The new PrimeCore owner is 8,487 bytes;
the new DriverCore owner is 22,906 bytes. All conserved predecessor anchors
named by the freeze remained exact, including `frozenPlannerV2`, supervisor
`main.swift`, both bridges, facade and role table, isolated spawn canary and
child pin, C closure/watch owners, Darwin/process owners, Process-based Git
transport, both package manifests, both lock files, and both inventory
resources.

### Closed mechanics

The accepted implementation establishes these pure data transitions:

1. exact five-byte `sha1` object-format framing and strict NUL-record parsing;
2. raw-path byte preservation, unsigned byte order, fixed limits, and
   duplicate/unsafe/ancestor rejection without lossy Unicode conversion;
3. exact Git mode/type/lowercase object-ID parsing and Git blob SHA-1
   recomputation over descriptor-read bytes;
4. one-to-one held-entry join across opened, post-read descriptor, and
   post-read named-path identities, including same-bytes/new-inode rejection;
5. owner-execute-bit agreement for Git `100644` / `100755`;
6. conditional no-follow `120000` mechanics with byte-wise, root-contained,
   non-`.git`, 1,023-byte/32-component target resolution; and unconditional
   gitlink rejection;
7. a stable canonical manifest whose digest excludes host vnode IDs and does
   not hash itself; and
8. a non-Codable binding which requires repository and companion manifests,
   both computed digest fields, and the exact complete repository-receipt
   identity.

The stable repository golden fixture is exact:

| Item | Exact value |
| --- | --- |
| Raw tree byte count | 131 |
| Raw tree SHA-256 | `c39e939477b4417019298b4637206ec700aae744786ee8083a8978e467a87a6e` |
| Canonical manifest byte count | 975 |
| Canonical manifest SHA-256 | `9372e53a7d6b704fd0c40ffdc63d8aecdc10589f108212694afa9a740a33fd5c` |
| Entry modes | `100644`, `100755` |
| First blob object ID | `67bbe3ba8e768c60a01fd1ece2faa2a3b5791f69` |
| Second blob object ID | `98975b256fb01bb13924496db833b4122e26bb31` |

The legacy Codable repository receipt remains declaration/chain-shape data;
its schema is unchanged. Happy fixtures now carry digests computed from exact
canonical manifests. An otherwise well-formed `b...` / `c...` declaration
still validates only as a declaration and fails to construct the new binding.
An otherwise-valid alternate receipt with the same two manifest digests also
fails an existing binding because its full receipt identity differs.

### Compile and focused proof

Before the source commit, nested `swift build --build-tests` compiled PrimeCore,
DriverCore, and the test bundle without running a test. Existing nested
executables were linked as ordinary build products; none of those products,
including the Driver V2 child, was launched. After source commit
`272baaba...`, each row below ran as a separate exact filter. Aggregate: 8
selected tests, 8 passed, 0 failed.

| Exact focused test | Result | Data established |
| --- | --- | --- |
| `testGateDGoldenRegularAndExecutableManifestIsCanonical` | PASS | exact raw/canonical bytes, hashes, modes, held kinds, deterministic encoding |
| `testGateDRawPathBytesPreserveInvalidUTF8AndControls` | PASS | invalid UTF-8 plus tab/LF/CR/backslash path bytes survive parsing and canonical decode exactly |
| `testGateDRejectsPrefixesFramingObjectFormatModeTypeAndObjectID` | PASS | every proper prefix and malformed format/header/mode/type/OID class rejects |
| `testGateDRejectsUnsafeDuplicateUnorderedAndAncestorPaths` | PASS | absolute/dot/empty/over-limit/`.git`, duplicate, order, and ancestor collisions reject |
| `testGateDRejectsHeldSetHashCountAndFixedCapDrift` | PASS | missing/extra/rename/kind/mode/hash/count/per-file/aggregate limits reject; owner-execute semantics admit exact valid cases |
| `testGateDRejectsSameBytesNewInodeAndIdentityReboundDrift` | PASS | descriptor or named-path vnode drift rejects even with identical bytes |
| `testGateDSymlinkMechanicsAreConditionalAndGitlinksReject` | PASS | in-root relative target admits mechanically; escape/absolute/`.git`/empty/combined-limit targets and gitlinks reject |
| `testGateDCanonicalDecodeReceiptBindingAndSourceSurfaceAreClosed` | PASS | canonical-only decode, self-hash exclusion, complete receipt-identity binding, arbitrary-digest rejection, exact source-owner admission, and forbidden surface absence |

The final focused test re-captured and validated the complete Release source
snapshot against embedded identity
`36fed0d96845ea8f5304cd762f21cbf487d278fd00c90080e4b35ffffbcb18c0`.
The topology and provenance values were also independently recomputed by
three read-only audits. No broad class/target filter, live admission test,
root test, or 904 inventory ran.

### Authority ceiling and successor

Gate D closes no live process or staging authority. The eight post-A missing
authorities remain missing: Prime Git, companion Git, Swift version, Swift
target info, SwiftPM build, artifact staging, XCTest inventory, and Swift
Testing inventory. The facade remains at frozen `build`; no role advanced or
was consumed. `frozenPlannerV2` and the existing missing-authority enum were
unchanged.

In particular, Gate D observed no live Git bytes, `.git`/object database,
retained production tracked-entry closure, production symlink holder, child,
process group, build, inventory, evidence publication, science, product, or
release fact. A decoded manifest or declaration cannot restore a descriptor
or satisfy Gate E. XCTest proved pure mechanics only.

Outer local Swift compilation, exact filtered test harness activity, and Git
commit/worktree bookkeeping are workstation observations, not Driver V2
process evidence. GitHub Actions, hosted runners, network permission,
dependency fetches, and remote publication were not used.

Gate E is the only permitted successor, separately frozen on exact source
`272baaba5e4e3be3f17f6c1704e4622b514b12d8` and tree
`fdbf508d3a461f4e5ba5098453c6c1f8351f75b1`. It must supply the first fixed
live Git/Swift process bytes while retaining C continuity and performing the
PrimeCore held join. This durable checkpoint is rank-4 prose and is not Gate
E's source predecessor. No Gate E source or process is authorized here.

## Gate D1 / E0 predecessor freeze — corrected live scope and fixed probes

Status: `FROZEN_NOT_EXECUTED`

### Exact predecessor and data correction

| Field | Exact value |
| --- | --- |
| Gate | E only; fixed live Prime Git, companion Git, Swift version, and Swift target-info observations |
| Source predecessor | `272baaba5e4e3be3f17f6c1704e4622b514b12d8` |
| Source predecessor tree | `fdbf508d3a461f4e5ba5098453c6c1f8351f75b1` |
| Source predecessor parent | `9f7d95a5bebd492827f71fa0bb340d5af1859a90` |
| Embedded source identity | `36fed0d96845ea8f5304cd762f21cbf487d278fd00c90080e4b35ffffbcb18c0` |
| Durable-control predecessor | `ab26e6dd00202f5fd963e970ba5481986f0ddd91` |
| Durable-control predecessor tree | `1dff8d74d72521c3e28dc561a1126325336b7495` |
| Source worktree requirement | clean before the first source mutation |
| Durable-control rank | prose rank 4; never a source predecessor or execution fact |

The D0 phrase `Prime tracked tree` was too broad for the live Gate C owner.
The measured predecessor data are authoritative over that phrase:

| Prime scope at `272baaba...` | Tracked paths | Aggregate blob bytes | Largest blob | Blobs over the frozen 8 MiB Prime cap |
| --- | ---: | ---: | ---: | ---: |
| Full Git tree | 658 | 176,428,530 | 34,828,304 | 4 |
| Retained legacy source authority | 543 | 21,779,231 | 604,772 | 0 |
| Outside the Gate C authority | 115 | 154,649,299 | — | 4 |

The full Prime Git tree therefore cannot join Gate C and cannot satisfy Gate
D's Prime per-file cap. D1 corrects only the future live Prime scope:

- `repositoryTrackedTreeSHA256` binds the exact retained legacy Prime source
  authority path set, not every tracked path in the repository;
- `companionTrackedTreeSHA256` continues to bind the complete companion Git
  tree outside `.git/**`; and
- both whole-root clean-status observations include ignored entries and remain
  exact and empty, so every tracked change and every nonempty untracked or
  ignored entry Git reports outside Prime's manifest scope rejects Gate E.

Git does not represent empty untracked directories. Outside Prime's legacy C
roots, such a directory is a named residual rather than something prose calls
clean; it closes no tracked-content fact. Inside Prime's C roots and throughout
the companion working tree, C topology continuity remains authoritative.

No Gate D source, Codable schema, receipt field, canonical grammar, cap,
golden fixture, or checkpoint identity changes. A Gate D manifest alone does
not carry this scope or restore live authority. The Gate E non-Codable binding
must require the live Prime raw path set to equal the retained Gate C source
snapshot one-for-one.

An outer-workstation measurement using the exact fixed Prime pathspecs below
produced 543 NUL records, 77,819 raw bytes, and SHA-256
`57ee1fa93231d5e85f4b17cd7713f0af56feb470bf4a8e4c79cf6a2778da2e41`.
This is a predecessor measurement, not a frozen future manifest digest or a
Driver V2 observation. The companion predecessor remains 1,306 files,
66,812,637 aggregate held bytes, largest file 32,833,664 bytes, and pinned
HEAD `163fc100710ece48119bc25954452d10f6a84f7f`.

### Exact source mutation allowlist

| Ordinal | Path | Permitted mutation |
| --- | --- | --- |
| 1 | `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` | exact source-identity reseal only |
| 2 | `Sources/PrimeCore/PrimeValidationDriverV2FixedProbeExecutor.swift` | new fixed 16-child executor, raw observation, held executable policy, and private Gate E journal |
| 3 | `Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift` | add one zero-argument one-shot fixed-probe transition and retained success state only |
| 4 | `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift` | retain and revalidate fixed Git and Swift physical images/personalities; add the two new source owners to existing source lists |
| 5 | `Sources/PrimeCore/PrimeNativeNeuralGateHeldSourceClosure.swift` | project Gate D held-entry values from the existing Gate C descriptors after exact revalidation; no second owner |
| 6 | `Sources/PrimeCore/PrimeSecureHeldSourceWatch.swift` | internal forwarding seam for the existing retained watch owner only |
| 7 | `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore/PrimeValidationDriverV2Admission.swift` | make the existing target-info parser module-internal and correct only the repository receipt's fixed Git path policy from `/usr/bin/git` to exact `<validated-DEVELOPER_DIR>/usr/bin/git`; Codable fields/layout stay unchanged |
| 8 | `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore/PrimeValidationDriverV2FixedProbeBinding.swift` | new non-Codable raw-to-manifest/toolchain/repository binding which retains the facade |
| 9 | `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2Supervisor/main.swift` | after the unchanged decoded frame binds the supervisor, unconditionally consume and run the zero-argument Gate E transition; no transport growth |
| 10 | `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationDriverV2AdmissionTests.swift` | pure binding, parser, mutation, source-surface, and production-host-rejection cases only |
| 11 | `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` | Gate E retained-owner and local Release supervisor cases only |
| 12 | `Sources/PrimeCore/PrimeSecureRunningExecutableCapture.swift` | add only a module-internal zero-argument identity-only revalidation on the existing held supervisor-image owner: held-descriptor `fstat` against the admitted tuple, `FD_CLOEXEC`, loaded-vnode join, and nofollow named rebound; no byte read, descriptor escape, initializer, or public API |

No package manifest, lock file, product, target, resource, inventory list,
planner, contract, missing-authority enum, receipt schema, B role table, role
bridge, image bridge, Gate D manifest owner, tracked-held-entry mechanics,
spawn canary or pin, process substrate, supervision owner, Git blob transport,
staging owner, `.github`, root test, science, or product path is in this
allowlist. A change outside the twelve paths is a hard stop.

The two new source files add two files and no directory. With no deletion or
rename, the candidate must measure exactly 545 source-snapshot files, 544
canonical identity records, and 152 Prime authority directories. The watch
topology must be 545 Prime files plus 152 directories = 697 Prime watches;
companion remains 1,460; combined must be exactly 2,157 / 4,096. Prime's
8 MiB per-file limit and companion's 64 MiB per-file limit remain unchanged.

### Closed facade transition and authority split

Gate E adds exactly one public SPI operation to the existing opaque facade:

~~~swift
facade.observeFixedGitAndSwiftProbes()
    throws -> PrimeValidationDriverV2FixedProbeRawCapability
~~~

It accepts zero arguments and exposes no role ID, path, descriptor, argv,
environment, cwd, timeout, cap, output sink, callback, or retry selector. It
is one-winner under sequential and concurrent calls. Any acquisition,
continuity, journal, spawn, drain, containment, raw-validation, or DriverCore
binding failure permanently poisons and releases the live capability; it is
not repaired, decoded, or retried. The already-frozen B role table remains
exactly `build`, `list_xctest`, `list_swift_testing`, still positioned at
`build`, and none of those roles executes or advances in E.

The return is an opaque, non-Codable, one-shot raw capability, not an evidence
value that can be reconstructed. The shared state transition is exact:

~~~text
facade guarded -> probes_running -> awaiting_one_binding
raw owner awaiting_one_binding -> bound_lifetime | poisoned
facade/raw owner after either terminal transition -> never reusable
~~~

On process success the facade transfers the sole retained C/lease/image
lifetime into the raw capability and remains permanently consumed. Its
read-only raw observation is descriptor-free and may be copied only as data;
the authority object is unique. After independently validating every semantic
field, DriverCore calls exactly one zero-argument internal/SPI
`consumeValidatedBindingLifetime()` on that raw owner. It either transfers the
same live state into the non-Codable bound lifetime or rejects as already
consumed. Dropping or explicitly rejecting an awaiting raw owner invokes its
fail-only zero-argument poison transition and releases the retained resources.
No Boolean success input, callback, facade observation property, or second
owner exists. The successful DriverCore binding retains the consumed facade
identity plus the bound lifetime.

The ownership split is exact:

| Owner | Gate E responsibility | Explicit non-authority |
| --- | --- | --- |
| PrimeCore | retain C watches/descriptors/lease/image, hold fixed Git/Swift images, execute the fixed sequence, contain each child, project held entries from the existing C owner, and return one non-Codable raw observation | no semantic repository/toolchain receipt, completion, build/list/staging/inventory, generic command API, or durable product truth |
| DriverCore | reparse every raw byte sequence, construct the two existing Gate D manifests and complete repository receipt, construct a new non-Codable partial Swift-probe binding, bind those identities to the retained raw lifetime, and expose the reduced missing-authority set | no complete toolchain receipt before `swift-package` maps in F; no filesystem, image opening, process, journal writer, argv/env/cwd selection, role advance, staging, build, inventory, shard, or completion authority |
| Dedicated Release supervisor | consume the canonical stdin request, bind its own image, run the fixed transition, require DriverCore binding, revalidate continuity, retain the live owner through silent exit 0 | no new request field, JSON path loader, environment protocol, command language, child selector, or public receipt |

PrimeCore raw success closes no Driver V2 semantic authority. Only a successful
non-Codable DriverCore binding backed by the retained facade removes exactly:

- `prime_git_head_and_clean_process_observation`;
- `companion_git_head_and_clean_process_observation`;
- `swift_version_process_observation`; and
- `swift_target_info_process_observation`.

Build execution, artifact staging, XCTest inventory, and Swift Testing
inventory remain missing. `frozenPlannerV2`, every Codable field/layout, the
toolchain receipt validation, missing-authority enum, and current admission
chain remain unchanged. The repository receipt's fixed Git-path validation
policy is corrected to the Xcode Git image actually executed; its shape and
encoding do not change.

### Exact Git roots, scope, and entry join

Both production roots must have a root `.git` directory entry. Companion C
already captured its no-follow device/inode/type identity while excluding its
descendants. Prime's legacy C topology deliberately did not include `.git`;
Gate E therefore opens that one Prime root entry no-follow exactly once before
the first child, retains its descriptor and initial identity for the complete
sequence, and never enters a descendant. Gate E also opens the companion entry
no-follow exactly once and must join it to C's recorded excluded-root-`.git`
device/inode identity before retaining it; C recorded that namespace entry but
did not watch descendants or supply a Git-content descriptor. This does not
create a second companion working-tree content closure. Both entries are
revalidated before and after every child and at terminal. `.git/**`
descendants remain excluded from the C watches. A root `.git` file, deletion,
rename, replacement, type change, or identity rebound rejects production Gate
E. A Release harness may create a clean local clone at the exact source
commit/tree to provide a real `.git` directory; it uses no network and does
not make Git the scientific authority.

For each `.git` entry, E retains exact no-follow directory type, device,
inode, uid, gid, and permission mode from the first descriptor-relative open.
The device must equal the held repository-root device, uid must equal the
effective user, and mode must be nonzero with no group/world write bits. The
companion device/inode/type must also equal C's recorded excluded-entry
identity. Before and after every child and at terminal, E requires the held
descriptor tuple unchanged and a descriptor-relative no-follow named rebound
to that tuple. Directory size, link count, mtime, and ctime are deliberately
not identity fields because accepted `.git/**` descendant churn can change
them; they cannot substitute for the frozen tuple.

Prime uses exactly these ten literal pathspecs, in this unsigned ASCII order,
fixed inside PrimeCore and never supplied by the caller:

1. `.gitignore`
2. `.swiftpm/configuration/mirrors.json`
3. `LICENSE`
4. `Package.resolved`
5. `Package.swift`
6. `README.md`
7. `Sources`
8. `THIRD_PARTY_NOTICES.md`
9. `Tests`
10. `docs`

The parsed live Prime path set must equal the retained
`PrimeSwiftSourceSnapshot.files` raw UTF-8 path set exactly. The parsed live
companion path set must equal the retained complete non-`.git` file snapshot
exactly. A hidden tracked entry that C did not retain, any symlink, any
gitlink, missing/extra/reordered path, or same-bytes/new-inode replacement is
fail-closed `ABSTAIN`; E does not widen C or add a symlink holder.

For every regular-file entry, the existing Gate C owner—not an absolute/root
reopen or a second retained closure—constructs
`PrimeValidationDriverV2TrackedTreeHeldEntry` after checking its original
admission identity, held descriptor identity, post-read identity, exact
bytes/hash, and current named-path rebound. The rebound is descriptor-relative
through the already-held C directory chain using no-follow `fstatat` or a
transient no-follow `openat`; it is identity-checked and not retained as a
second owner. The projection returns evidence data but no descriptor.
Continuity is polled again after the complete local join.

### Exact fixed process sequence

Gate E executes exactly 16 children in this order under one facade call:

| Ordinal | Fixed role | Root / cwd | Required stdout |
| ---: | --- | --- | --- |
| 01 | `prime_head_pre` | held Prime root | exactly 40 lowercase hex bytes plus LF |
| 02 | `prime_object_format` | held Prime root | exactly `sha1` plus LF |
| 03 | `prime_status_pre` | held Prime root | exactly empty |
| 04 | `prime_tree_discovery` | held Prime root | bounded Gate D raw tree bytes |
| — | local held-entry join | existing Prime C owner | no child |
| 05 | `prime_tree_replay` | held Prime root | byte-for-byte equal to discovery |
| 06 | `prime_status_post` | held Prime root | exactly empty |
| 07 | `prime_head_post` | held Prime root | byte-for-byte equal to HEAD pre |
| 08 | `companion_head_pre` | held companion root | exactly 40 lowercase hex bytes plus LF |
| 09 | `companion_object_format` | held companion root | exactly `sha1` plus LF |
| 10 | `companion_status_pre` | held companion root | exactly empty |
| 11 | `companion_tree_discovery` | held companion root | bounded Gate D raw tree bytes |
| — | local held-entry join | existing companion C owner | no child |
| 12 | `companion_tree_replay` | held companion root | byte-for-byte equal to discovery |
| 13 | `companion_status_post` | held companion root | exactly empty |
| 14 | `companion_head_post` | held companion root | byte-for-byte equal to HEAD pre and the pinned companion commit |
| 15 | `swift_version` | held Prime root | bounded exact Swift version bytes |
| 16 | `swift_target_info` | held Prime root | bounded exact target-info JSON bytes |

For each root, discovery/replay exact equality, HEAD pre/post exact equality,
both exact-empty statuses, exact SHA-1 object format, held-entry join, and C
continuity are one indivisible observation. The replay tree supplies Gate D's
manifest input. Because `.git/**` is intentionally unwatched, these bookends
prove bounded endpoint agreement; they do not claim detection of Git-admin
state which changes and restores wholly between endpoints.

### Exact Git and Swift invocation policy

The Git physical image is the already-held no-follow regular executable at
exact `<held-DEVELOPER_DIR>/usr/bin/git`, capped at 64 MiB, with logical
`argv[0]` exactly `git`. A dry measurement established that `/usr/bin/git`
emits a Darwin temporary-directory warning under the frozen five-entry
environment, while the Xcode Git image emits exact empty stderr; `/usr/bin/git`
is therefore not the Gate E image. Every Git child receives this fixed common
prefix:

~~~text
--no-pager
--no-optional-locks
--no-replace-objects
--no-lazy-fetch
--literal-pathspecs
--git-dir=.git
--work-tree=.
-c core.fsmonitor=false
-c core.untrackedCache=false
-c submodule.recurse=false
-c core.hooksPath=/dev/null
~~~

The suffixes are exact:

~~~text
rev-parse --verify HEAD^{commit}
rev-parse --show-object-format
status --porcelain=v2 -z --untracked-files=all --ignored=matching --ignore-submodules=none --no-renames
ls-tree -r -z --full-tree <validated-HEAD-pre> -- <ten-fixed-Prime-pathspecs>
ls-tree -r -z --full-tree <validated-HEAD-pre> --
~~~

The final tree form is companion-only. The commit argument is derived inside
PrimeCore from the exact validated pre-HEAD bytes; it never crosses the
facade. HEAD stdout is capped at 128 bytes, object format at 5 bytes, status
and tree stdout independently at 16 MiB, and every Git stderr at 64 KiB.
Every independent memory drain uses exact 64 KiB chunks. Success requires
exact exit 0, EOF, no overflow, and empty stderr.
`--no-lazy-fetch` is mandatory: missing local objects reject rather than
hydrating a partial clone. No command has network authority.
The fixed relative `--git-dir=.git` and `--work-tree=.` are resolved only after
the suspended cwd join. They prevent ancestor discovery or repository
`core.worktree` configuration from redirecting the observation away from the
held root and held `.git` entry.

Admission also holds the physical Xcode `swift-frontend` image with a 512 MiB
cap and the no-follow `swift -> swift-frontend` and
`swiftc -> swift-frontend` personalities. Their physical image, symlink
metadata/target, canonical path, device/inode, exact bytes/count/hash, owner,
mode, link count, and mapped-image join must agree. Both Swift children use
the physical held `swift-frontend`, logical `argv[0]` exactly `swift`, held
Prime cwd, and respectively exact argument lists `--version` and
`-print-target-info`. Stdout caps are 16 KiB and 64 KiB respectively; stderr
is independently capped at 64 KiB and must be empty.

All 16 children use stdin `/dev/null` / immediate EOF and this complete,
sorted, five-entry replacement environment derived from retained admission:

~~~text
DEVELOPER_DIR=<held canonical developer directory>
LANG=C
LC_ALL=C
SDKROOT=<held canonical SDK root>
TERM=dumb
~~~

There is no inherited environment, `PATH`, `HOME`, Git environment, SwiftPM
19-entry environment, or staging overlay.

### One deadline, containment, and continuity ordering

Git, `swift-frontend`, `swift`, and `swiftc` are acquired and retained during
the existing prerequisite admission, before the facade exists. At facade
entry, before opening the Gate E journal, acquiring either `.git` entry, or
spawning a child, Gate E establishes one checked absolute deadline using the
existing `DispatchTime.now().uptimeNanoseconds` /
`PrimeSecureChildPhaseDeadline` clock authority. The limit is exactly
30,000,000,000 nanoseconds and is never reset per root or child. Every pre-held
image is revalidated under that deadline. Exhaustion before a spawn rejects
without that spawn; exhaustion after a spawn invokes exact containment. No
deadline or supervision owner is mutated by E.

The same endpoint covers the whole semantic transition, not only child wall
time. Nonregressing uptime checks are required through every lightweight and
full validation, every journal publication/readback, raw-terminal publication,
DriverCore parse/binding work, and the final raw-owner transfer. The
zero-argument `consumeValidatedBindingLifetime()` performs the last
`PrimeSecureChildPhaseDeadline.acceptsCompletion` check; no successful bound
lifetime may cross the deadline. Expiration with a live child contains it.
Expiration after reap poisons and leaves Gate E semantically incomplete and
nonretryable; whatever exact journal prefix already exists remains immutable,
without pretending child cleanup is still needed.

The measured retained Prime-plus-companion content is 88,591,868 bytes per
paired held-byte pass. Calling the current full retained-state revalidation
three times around each of 16 children would force at least 4.25 GiB of reread
work, and the current double-pass wrapper would be still larger. E does not
hide that cost inside the 30-second pin. Full admission/held-byte validation
occurs exactly at Gate E entry, after each of the two local tracked-entry
joins, and at Gate E terminal.

The implementation audit found the same anti-pattern on the separately held
supervisor image: its 46,722,904-byte production image would be read twice by
each of 68 lightweight checkpoints, totaling 6,354,314,944 bytes (5.92 GiB)
inside the same 30-second deadline. The count includes the required suspended
post-start-publication checkpoint for each of the 16 children. The twelfth
allowlisted owner path closes that defect at its existing descriptor owner.
Its identity-only operation
must compare the held descriptor with the admission `stat`, retain
`FD_CLOEXEC`, join the loaded main-image vnode, and reopen the canonical named
image with `O_NOFOLLOW` for the same exact identity and metadata. It reads no
image bytes. The four full entry/join/terminal passes continue to call the
existing byte-authoritative `revalidate()`; this correction changes neither
their count nor any topology count.

The raw capability transfer and DriverCore's final live-binding accept must
not create a fifth full pass. After the terminal pass, the retained lifetime
therefore exposes only a zero-argument transferred-continuity checkpoint: C
kqueue poll, held lease, admitted repository/private-root identities and
emptiness, identity-only complete toolchain set, identity-only held/loaded/
named supervisor image, then a second C kqueue poll. That operation carries
the same nonregressing deadline and poisons on failure. It does not reread
source, toolchain, or supervisor bytes and retains no Gate E `.git` or journal
owner. DriverCore's final revalidation ends with that checkpoint.

Paths 5 and 6 may add one zero-argument lightweight, non-rebaselining
checkpoint on the existing C owner. It does exactly one thing: poll both
continuously armed C kqueues and reject any event, read error, or unexpected
event count. No path, descriptor, callback, selector, or E-owned object crosses
that seam; it does not reread source contents, reopen a root, replace a
descriptor, clear a baseline, or create a second owner. Immediately after that
zero-argument poll, the executor privately revalidates the lease,
admission-held roots/cwd/images, and E-owned `.git` and journal descriptors plus
named identities. Any poll failure, lease loss, or identity drift poisons.
The heavy entry/join/terminal checks remain the byte authority.

Before child 1, Gate E performs the full entry validation, derives all held E
views, publishes and verifies `gate-e-prestart.json`, and then begins the fixed
sequence. Every child uses only the existing Darwin suspended-spawn substrate
and supervision kernel. The per-child requirements are:

1. run the lightweight checkpoint under the one deadline;
2. spawn the one fixed child suspended, adopt both independent memory drains
   and the exact-child obligation, and prove `SID == PGID == PID`;
3. join the suspended cwd device/inode and the mapped physical executable
   device/inode;
4. run the lightweight checkpoint again and publish/verify that child's
   durable start;
5. while the child remains suspended, run the lightweight checkpoint a third
   time after durable start readback; bind its monotonic completion in the
   live raw observation and child-terminal leaf, and require that completion
   to follow start publication and precede resume;
6. deliver exactly one `SIGCONT` only after both the durable start and that
   post-publication continuity checkpoint;
7. observe death, reach independent bounded EOF on stdout and stderr, reject
   overflow rather than truncate, require the fixed semantic raw framing,
   prove pre-reap group membership contains the exact child, call
   `waitpid(PID, 0)` exactly once, and require `process_group_empty`;
8. run the lightweight checkpoint again, then publish/verify that child's
   terminal; and
9. only then begin the next never-started fixed role.

After each discovery tree, the corresponding existing-owner held-entry join
and its full paired validation complete before that root's replay child. After
child 16, the final full paired validation and root/name rebound complete
before `gate-e-raw-terminal.json` and before DriverCore binding.

Fixed Git or Swift implementations may transiently create helpers. E claims
only isolated session/process-group containment and an empty terminal group,
not that no descendant ever existed. Every post-spawn rejection contains,
drains, reaps, and proves group empty before throwing. If cleanup returns the
existing `mustFailStop` result, the dedicated supervisor exits 70. `Process`,
shell, `fork`, a second cleanup spawn, detach, caller callback, and
`PrimeNativeGitBlobTransport` are forbidden.

### Private Gate E durability journal

The general live-execution rule forbids resuming a child before its start is
durable. E therefore owns one new pre-existing, canonical, local-APFS, private
`0700`, initially empty root at the exact derived sibling path:

~~~text
workspaceRoot.absolutePath + ".driver-v2-gate-e-journal"
~~~

It is a real no-symlink directory, effective-user owned, group-consistent
with the workspace, link count two while empty, descriptor-held,
device/inode named-path rebound, and disjoint/non-nested with Prime,
companion, workspace, evidence, and lease roots. It is not the Driver V2
evidence ledger, staging tree, product receipt, or release truth. Workspace
and evidence remain empty throughout E.

Local APFS changes this journal directory's observed link count from `2+n` to
`2+n+1` when the next authorized regular leaf is published. For every exact
prefix `n = 0...34`, the journal implementation must require inventory count
and names equal that prefix and root link count exactly `2+n`. Device, inode,
type, uid, gid, and mode never change. Root mtime/ctime and link count may
transition only around the single exclusive publication of the next expected
leaf; after sync/readback they are recaptured, named-path rebound, checked
stable across a second read, and become the sole expected identity for the
next prefix. Any other root transition rejects. This generalizes the measured
canary `2 -> 3 -> 4` rule rather than repeating its off-by-one failure.

The exact 34 exclusive/no-replace canonical JSON-plus-LF leaves are:

- `gate-e-prestart.json`;
- for each ordinal/role base `01-prime-head-pre`,
  `02-prime-object-format`, `03-prime-status-pre`,
  `04-prime-tree-discovery`, `05-prime-tree-replay`,
  `06-prime-status-post`, `07-prime-head-post`,
  `08-companion-head-pre`, `09-companion-object-format`,
  `10-companion-status-pre`, `11-companion-tree-discovery`,
  `12-companion-tree-replay`, `13-companion-status-post`,
  `14-companion-head-post`, `15-swift-version`, and
  `16-swift-target-info`: exact `<base>-start.json` and
  `<base>-terminal.json`; and
- `gate-e-raw-terminal.json`.

Each leaf is at most 64 KiB, encoded from fields that exclude its own digest,
written completely, synchronized, changed to mode `0400`, synchronized again,
parent-directory full-synchronized, reopened no-follow, read back, canonical
byte-equal, identity-joined, and SHA-256 verified while held. An existing or
unexpected leaf rejects. A start without terminal is permanently incomplete;
the same journal is never reused or repaired.

The prestart binds the source identity, journal/root/image identities, fixed
policy digest, complete five-entry environment digest, one absolute deadline,
and the exact 16-role order. Each child start binds its ordinal/role, prestart
hash, predecessor kind/hash, PID/session/group, spawn flags and return time,
deadline, held cwd and physical image, suspended cwd join, mapped-image join,
and pre-resume continuity state. Ordinal 1 encodes predecessor kind exact
`prestart` plus the prestart leaf hash; every later ordinal encodes predecessor
kind exact `child_terminal` plus the immediately prior child-terminal hash.
There is no absent/null predecessor and absence is never treated as evidence.
Each child terminal binds its
complete external start-leaf hash, raw stdout/stderr counts and SHA-256 values,
the post-start-publication continuity-check completion time, EOF and overflow
facts, exact completion/reap/group-empty facts, and post-reap continuity.
DriverCore must reject unless that checkpoint time is at or after the durable
start publication, before resume, and within the one Gate E deadline. Both
ordering edges are production-shared mutation-matrix facts rather than a
source-text-only assertion. The raw terminal binds every ordered terminal
hash plus the two
HEAD agreements, four empty statuses, two object-format values, two tree
replay equalities, both held-join summaries, and both Swift raw bindings.
None attempts a self-hashing fixed point.

These leaves prove only local start ordering, containment, and raw sequence
durability. Decoding them restores no capability and closes no semantic Gate
E authority. Missing `gate-e-raw-terminal.json` is incomplete even if all
children exited. The DriverCore non-Codable binding must succeed in the same
live process before silent supervisor exit 0.

### DriverCore semantic binding

After PrimeCore returns the retained raw owner, DriverCore must independently:

1. validate the canonical intent and exact dedicated supervisor observation;
2. parse both HEAD bookends, both `sha1\n` values, all four statuses, both
   discovery/replay pairs, Swift version, and Swift target-info bytes;
3. require Prime HEAD stability, companion HEAD stability and equality to
   `PrimeValidationRunIntentV2.requiredCompanionCommit`, exact empty statuses,
   exact tree replay equality, and exact process/journal lifecycle facts;
4. construct both existing Gate D manifests from the replay bytes and the
   PrimeCore-held entries, with Prime's path set exactly equal to the retained
   source authority and companion's path set exactly equal to the complete C
   closure;
5. construct the complete repository receipt from both live Git observations
   and manifest digests, using exact artifact paths
   `admission/repository_head.bin`, `admission/repository_status.bin`,
   `admission/companion_head.bin`, and
   `admission/companion_status.bin`; validate its corrected Xcode Git path and
   bind its complete identity to both Gate D manifests;
6. construct a non-Codable partial toolchain-probe binding from held developer
   and SDK observations, mapped `swift-frontend`, both no-follow `swift` and
   `swiftc` personality joins, and live artifacts at exact paths
   `admission/swift_version.bin` and
   `admission/swift_target_info.bin`. The existing derived Xcode/SDK artifacts
   are pinned as `admission/xcode_version.bin`, `admission/sdk_path.bin`, and
   `admission/sdk_version.bin`; they remain projections from held plist/path
   observations, not newly claimed process evidence;
7. require the intent's Swift executable bytes/path and companion declaration
   to join those live values. The held but unmapped `swift-package` declaration
   remains explicit: E must not set `mappedExecutableJoined` true, instantiate
   a complete `PrimeValidationToolchainAdmissionReceiptV2`, or claim its
   identity. Gate F first maps `swift-package` and is the earliest gate that
   may complete that receipt from this retained partial binding; and
8. retain the bound lifetime in a new non-Codable Gate E binding which binds
   the partial toolchain-probe identity, complete repository receipt identity,
   both canonical manifest identities, supervisor identity, intent identity,
   and exact expected four-authority reduction.

No raw field, durable leaf, Codable receipt, or observation member can be
scraped to open a second owner. Any parse or semantic bind failure invokes the
awaiting raw owner's zero-argument fail-only poison transition (or dropping it
triggers that same transition) and releases the retained capability. The
already-consumed facade has no callable post-transfer transition. Success
remains before `build` and authorizes no subsequent role in this gate.

### Candidate discipline and required proof

Before one clean source candidate commit/tree exists, only source inspection,
topology recount, provenance reseal, and compilation are authorized. No live
Git/Swift Gate E sequence runs to define the candidate. After the candidate
commit exists, each focused test is run separately by exact test name; no
broad target/class filter is used. Required cases are:

1. corrected Prime scope equals the retained source authority while full-root
   clean status remains independent;
2. exact fixed policy/order/caps/five-entry environment and absence of every
   caller execution parameter or B role-table mutation;
3. pure raw parsing and manifest/partial-toolchain/repository fixtures compute
   the expected four-authority reduction, while a test-host live construction
   still rejects because it cannot close `supervisor_executable_image`;
4. every HEAD, status, object-format, tree replay, Swift framing, stderr,
   overflow, exit, and pinned-companion mutation rejects and poisons;
5. missing/extra/reordered/unheld/symlink/gitlink and same-bytes/new-inode held
   joins reject without reopening a second C owner;
6. journal no-replace, canonical readback, self-hash exclusion, start-before-
   resume, missing-terminal incompleteness, one-winner, and permanent poison;
7. Prime or companion mutation during a child interval poisons and cannot be
   retried; and
8. an Apple `xctest` production bind still rejects and poisons, while any
   package-internal test-host seam closes no `supervisor_executable_image`.

The exact focused method names are frozen before source:

| Ordinal | Exact method | Configuration / authority |
| ---: | --- | --- |
| 1 | `testGateEPrimeScopeAndFixedPolicyAreExact` | Debug; pure data/source policy |
| 2 | `testGateERawParsersAndPartialBindingsAreClosed` | Debug; pure data and expected reduction only |
| 3 | `testGateERejectsEveryRawProcessAndRepositoryMutation` | Debug; pure mutation matrix |
| 4 | `testGateEJournalChainOneWinnerAndPoisonAreExact` | Debug; test-host mechanics only |
| 5 | `testGateEHeldProjectionRejectsSetSymlinkGitlinkAndVnodeDrift` | Debug; test-host existing-owner mechanics only |
| 6 | `testGateELightweightContinuityPoisonsOnEitherRootMutation` | Debug; test-host watch mechanics only |
| 7 | `testGateEXCTestHostCannotConstructProductionFixedProbeBinding` | Debug; exact production rejection |
| 8 | `testGateEReleaseSupervisorRequiresLiveFourAuthorityBindingBeforeExit` | Release; outer observation of dedicated production child |

Each method is invoked in a separate `swift test --filter <exact-method>`
command against the candidate. Method 8 is the sole positive production
proof; methods 1 through 7 cannot close production Gate E.

The only positive production proof is a separately launched Release
dedicated supervisor built from the exact candidate. Before the measured
invocation, outer workstation preparation may create clean local clones at
the exact Prime and pinned companion commits plus the four private roots,
lease root, and empty Gate E journal. That preparation is not part of Gate E
and uses no network. The excluded measured harness consumes those pre-existing
roots, uses the unchanged canonical stdin frame, and launches no child other
than the dedicated supervisor. Success is exact exit 0 with empty supervisor
stdout and stderr, 34 verified journal leaves, 16 exact child terminals, both
C watches still armed, and the dedicated child having required in process
that its production DriverCore binding is live and its missing-authority set
is exactly build, staging, XCTest inventory, and Swift Testing inventory before
permitting exit 0. The outer XCTest independently asserts only child exit,
empty stdio, and journal mechanics; it does not derive semantics from
`gate-e-raw-terminal.json` or a dead token. XCTest is not production
supervisor identity and never owns the child's live token.

No broad root test, 904 inventory, SwiftPM build/list role, staging creation,
GitHub runner, network request, dependency fetch, or remote publication is
authorized by this freeze.

### Conserved predecessor data and successor

All Gate D conserved blobs and data remain exact except the twelve allowlisted
paths. In particular, the Gate D manifest/held-entry implementations, both
bridges, contracts/planner, every receipt field/layout/encoding, B role table,
isolated canary/child pin, Darwin substrate/supervision owners, forbidden
Process Git transport, package manifests, locks, 892/12 inventories, and
`main.swift` framing/schema/argc/256-KiB/5-second rules are conserved. The
only receipt-validation policy change is the truthful fixed Git path in the
allowlisted Admission owner. `main.swift` may only add the unconditional
post-bind zero-argument transition described above.

A passing Gate E checkpoint closes only the four named live probe
authorities. Gate F is then the sole permitted successor: descriptor-relative
private staging plus exactly the fixed `build` role. Gate E authorizes no
Gate F source or execution, and Gate G inventory remains later. This control
record is prose rank 4 and cannot certify that E ran or passed.

## Gate E1 recovery freeze — silent phase discrimination and durable harness

This successor freeze is based only on source commit
`781e38f82a774b5583ca4254196773b0400c220d`, tree
`19d319f844259628d71188322477f4345f6187a3`. That commit binds the Release
run ID to the embedded source identity but is not a passing Gate E checkpoint.

The consumed `22a040a3a89276f8695d681bc34df1493c1cc886` attempt exited normally with
status 65 in approximately 0.986 seconds, emitted zero stdout and stderr
bytes, and left the outer-created journal at link count two with zero leaves.
It therefore published no prestart, launched no Gate E child, and identifies
no exact internal rejecting guard. The cause remains `ABSTAIN`. In particular,
the intent's `.../usr/bin/swift` path is correct: it is the no-follow logical
personality mapped to held `swift-frontend`. `swift-package` remains the
unmapped Gate F/G image and must not replace it.

Two non-executing Release admission proofs completed before this freeze. A
throwaway standalone Prime clone at `22a040a...` plus the standalone pinned
companion clone admitted and revalidated exactly 2,157 held watchers in 2.768
seconds; the source candidate plus the same companion repeated that result in
2.759 seconds. Each invocation selected one existing admission-only test,
passed with zero failures, and launched no Gate E child. The exact preserved
production-proof clones also have real no-follow `.git` directories, clean
status, the expected commits and trees, 697 Prime watchers, and 1,460
companion watchers. These data rule out changing Core admission, topology,
Git-directory, or Swift-personality semantics to explain the consumed 65.

The next candidate may change only these three already allowlisted paths:

| Path | Exact recovery scope |
| --- | --- |
| `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2Supervisor/main.swift` | keep the Gate A frame byte-for-byte in policy while assigning fixed silent exit statuses only after phase boundaries |
| `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` | candidate-bound one-shot root, failure preservation, exit/base reporting, and static phase-code assertions inside an existing Gate E method |
| `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` | canonical identity reseal only |

No PrimeCore executor, facade, watch, journal, DriverCore binding, role table,
manifest, planner, request type, package manifest, lock, inventory, or child
policy may change. The fixed silent process statuses are:

| Status | Last phase entered |
| ---: | --- |
| 65 | argc/stdin timeout and cap, canonical decode, request validation |
| 66 | developer-directory derivation, prerequisite admission, consume, and dual-root guard preparation |
| 67 | dedicated mapped supervisor-image bind and image revalidation |
| 68 | Gate E facade consumption, fixed probes, raw transfer, and DriverCore semantic bind |
| 69 | final retained four-authority revalidation |
| 70 | existing post-spawn containment fail-stop; unchanged and never translated |
| 0 | all prior phases accepted and the live binding remained retained through return |

The supervisor remains silent. This adds no stdout, stderr, environment read,
path loader, request field, argv command, cwd, timeout selector, role ID,
process API, or authority. All Gate A transport failures remain status 65;
argc one, canonical stdin-only framing, the 256-KiB cap, five-second EOF
deadline, and request schema remain unchanged.

The Release harness replaces its random base with the exact candidate-bound
leaf
`/private/tmp/prime-driver-v2-gate-e-release-<source-identity-sha256>` and
requires that path to be absent before creating it. It must not unconditionally
delete that root. A nonzero supervisor status throws with both the exact status
and absolute base path while preserving the private root, lease, journal, and
0600 outer captures. A fully verified success is likewise retained until a
separate durable control record binds its identities; cleanup may occur only
after that record and must name the exact path. An occupied candidate-bound
root forbids another launch under the same source identity.

After the successor source commit and clean tree exist, run the seven frozen
Debug Gate E methods separately, then the existing one-test Release admission
proof, then exactly one Release method-8 invocation against the two standalone
clean clones. Any nonzero result is incomplete, is classified only by its
fixed status plus durable journal prefix, and consumes that candidate-bound
root. No GitHub, network, fetch, broad test, 904 inventory, build/list role,
or Gate F source is authorized. This recovery freeze is prose rank 4 and
cannot certify a run or scientific outcome.

## Gate E1 candidate checkpoint — consumed incomplete at admission/guards

| Field | Observed value |
| --- | --- |
| Measured XCTest interval | `2026-08-23T00:16:18.849Z` through `2026-08-23T00:16:19.821Z` |
| Scientific outcome | `INCOMPLETE` |
| Exact cause | `ABSTAIN` within the frozen status-66 phase |
| Source commit | `aba540a3009c4218b75fc065188dddce330f4b50` |
| Source tree | `ee13a67abb0853e15e2da7745bc6def11cae5f6f` |
| Source parent | `781e38f82a774b5583ca4254196773b0400c220d` |
| Embedded/source identity | `afb3c46461736ddf7b275d797d054000d260eeebc0c6c50a7a94451ef1c97a19` |
| Durable-control predecessor | `79b70c7c538e85082c723d0d6dfb1bf7d24098ce` / tree `734e79ab8527cb4485405140e34bc6c8200b435f` |
| Prime standalone commit/tree | `aba540a3009c4218b75fc065188dddce330f4b50` / `ee13a67abb0853e15e2da7745bc6def11cae5f6f` |
| Companion standalone commit/tree | `163fc100710ece48119bc25954452d10f6a84f7f` / `9009daa4f8a07fbd5897e00b9571cef44ec292db` |
| Pre-shot status bytes | source `0`; Prime clone `0`; companion clone `0` |
| Pre-shot Release supervisor metadata | regular; UID `501`; mode `0755`; link count `1`; `47,675,784` bytes |
| Post-shot Release supervisor SHA-256 | `09fb981b6350e630443998024eba11e4877e633bc5ff2f87b90d6513d75ff909` |
| Executed-image authentication | not established; status `66` preceded supervisor-image binding |
| Candidate root before shot | absent |
| Measured invocation count | `1` |
| Selected test count | `1` |
| Selected method | `testGateEReleaseSupervisorRequiresLiveFourAuthorityBindingBeforeExit` |
| XCTest result | `1` executed / `1` unexpected failure / `0` pass |
| Measured test elapsed | `0.972` seconds |
| Supervisor termination | normal exit `66` (`admission_and_guards`) |
| Supervisor stdout/stderr | `0` / `0` bytes |
| Journal | link count `2`; `0` leaves; no prestart |
| Lease/workspace/evidence entries | `0` / `0` / `0` |
| Post-shot status bytes | source `0`; Prime clone `0`; companion clone `0` |
| Dedicated supervisor launches | `1` |
| Fixed-probe child processes | `0` |
| Retry authorization | `false`; this source identity is consumed |
| Gate E closure | `false` |
| Gate F authorization | `false` |

The exact preserved root is
`/private/tmp/prime-driver-v2-gate-e-release-afb3c46461736ddf7b275d797d054000d260eeebc0c6c50a7a94451ef1c97a19`.
It is a caller-owned APFS directory at device `16777231`, inode `17321558`,
mode `0700`, UID `501`, link count `8`. Its two retained regular captures are
mode `0600`, link count `1`, and SHA-256
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
The empty workspace, evidence, lease, and journal directories are mode `0700`,
UID `501`, link count `2`; the root plus its six children remain in place.

The root compile-only gate used `swift build --target PrimeCore` with
`--disable-automatic-resolution --disable-sandbox`; it exited `0` after a
9.99-second build. The nested `Tests/PrimeValidationWorkflow` compile-only
gate used `swift build --build-tests` with the same two flags; it exited `0`
after a 10.47-second build. Both used separate module caches under
`/private/tmp`; neither ran a test or child. The seven
frozen Debug Gate E methods then passed separately, one selected test per
invocation, with elapsed test times `0.031`, `0.978`, `1.305`, `5.770`,
`2.242`, `4.440`, and `3.432` seconds. The one-test Release embedded-source
admission proof passed in `2.766` seconds. That proof re-admitted the exact
545-file/544-record identity and the previously frozen 2,157-watch topology;
it launched no Gate E child.

Status `66` proves that the canonical Gate A request frame and intent
validation completed. Because the status-66 lexical phase contains
developer-directory derivation, prerequisite admission, prerequisite consume,
and guarded-pre-executor preparation, the retained empty lease and journal do
not identify one exact rejecting operation. No supervisor-image bind, Gate E
facade transfer, Git process, Swift process, semantic binding, or final
revalidation occurred. No retry, cleanup, source repair, Gate F work, GitHub
operation, network request, dependency fetch, or remote publication follows
from this record. A production successor requires a new source identity; any
non-executing diagnostic requires a separate freeze. Prose may not promote
this incomplete observation to a Gate E conclusion.

A post-shot read-only metadata audit observed canonical paths equal to every
declared Prime, companion, workspace, evidence, and lease path. All five
device/inode pairs were distinct and stable across two reads; Prime and
companion were UID `501`, mode `0755`, and the three private roots were UID
`501`, mode `0700`. The inspected roots had no ACL and only the permitted
`com.apple.provenance` extended attribute. Those later observations make an
ordinary visible root-metadata rejection less likely, but cannot reconstruct
the exact in-process failure or exclude a transient pre-leaf lease error.

## Gate E1.1 freeze — standalone admission discrimination only

| Field | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | `04242ec9c957b8c2afef445bfc8fdbf01a2deac5` / tree `69dfc47e709e6fc338d143f5be2b2d85d58f605b` |
| Source commit/tree | `aba540a3009c4218b75fc065188dddce330f4b50` / `ee13a67abb0853e15e2da7745bc6def11cae5f6f` |
| Source identity | consumed `afb3c46461736ddf7b275d797d054000d260eeebc0c6c50a7a94451ef1c97a19`; no relaunch |
| Diagnostic Prime clone | `/private/tmp/gate-e-preflight-prime.IBJAfD/prime` |
| Companion clone | `/private/tmp/gate-e-companion-measure.pMGSXT/companion` at `163fc100710ece48119bc25954452d10f6a84f7f` / tree `9009daa4f8a07fbd5897e00b9571cef44ec292db` |
| Selected method | `testPublicReleaseAdmissionUsesEmbeddedSourceAuthority` |
| Authorized selected-test invocations | `1` |
| Production supervisor invocations | `0` |
| Fixed-probe child processes | `0` |
| Source edits/commits | `0` |

The disposable diagnostic clone may be updated by a local-only Git fetch and
detached checkout to the exact source commit above. Its existing ignored
SwiftPM checkouts and repositories may be reused. The clone and companion
must be clean immediately before the selected test. With separate module
caches under `/private/tmp`, run exactly:

`swift test -c release --filter testPublicReleaseAdmissionUsesEmbeddedSourceAuthority --disable-automatic-resolution --disable-sandbox`

Set only `PRIME_PMHNP_COMPANION_ROOT` for test input. No network access,
dependency fetch, method 8, dedicated supervisor launch, fixed Git/Swift
probe, consumed-root mutation, broad suite, Gate F role, or cleanup of the
preserved incomplete root is authorized.

The existing Release test may admit and consume the public prerequisite,
prepare and revalidate 2,157 watchers, and prove its fresh lease mechanics on
a standalone clone. Its current-process image capture uses the explicit
XCTest-only seam, and its developer directory is supplied directly from the
frozen fixture. A pass therefore cannot close `supervisor_executable_image`,
cannot exercise the supervisor's private developer-directory derivation, and
cannot reproduce the exact consumed workspace/evidence/lease inodes. It only
discriminates whether the same source tree and a standalone clone can pass
the shared public admission/consume/guard path without a production child.

## Gate E1.1 result — standalone admission passed without authority

| Field | Observed value |
| --- | --- |
| Result | `PASS_DIAGNOSTIC_NON_AUTHORITY` |
| Durable-control predecessor | `f5b9eeb58d35aea6a666c86b4d9357219ca1be02` / tree `796647bb6c1c044adb59efefc42d4db5da1a9561` |
| Measured XCTest interval | `2026-08-23T00:34:32.341Z` through `2026-08-23T00:34:35.055Z` |
| Diagnostic Prime commit/tree | `aba540a3009c4218b75fc065188dddce330f4b50` / `ee13a67abb0853e15e2da7745bc6def11cae5f6f` |
| Diagnostic Prime status bytes before/after | `0` / `0` |
| Companion status bytes before/after | `0` / `0` |
| Release build | exit `0`; `187.37` seconds |
| Selected XCTest | `1` executed / `1` pass / `0` failures; `2.714` seconds |
| Combined watcher descriptors | `2,157` |
| Production supervisor invocations | `0` |
| Fixed-probe child processes | `0` |
| Consumed Gate E root mutation | none; inode `17321558`, mtime `1787444179`, link count `8` unchanged |
| Consumed lease/journal entries after diagnostic | `0` / `0` |

This exact-tree standalone test passed the current public
`admitPrerequisites`, prerequisite consume, dual-root watch preparation, and
guard revalidation with fresh lease acquisition under the XCTest-only
current-image seam. It shows that those shared mechanics can pass for this
exact source tree on this standalone clone under the XCTest-only image seam;
it does not rule out clone-, root-, filesystem-, or invocation-specific
rejection. It does not replay the consumed root inodes, the supervisor's
private developer-directory derivation, or production running-image capture,
and it closes no Gate E authority.

The source bytes of `developerDirectory(swiftExecutableAbsolutePath:)` have
SHA-256
`902d48325db710ef48447fc1746c8606d0ec1dbf320ed20f2db51d47aeaa1351`
at both the passing Gate A candidate `8bfb27f2475ed336e4343150cd02dffb5cc0cc9d`
and the consumed Gate E candidate. Gate A's exact Release image/request canary
exited `0` and retained one lease entry. That conserved historical pass makes
a systematic developer-path regression less likely, but it cannot identify
what the later process observed. The exact Gate E1 rejection remains
`ABSTAIN`; the residual is an invocation-specific developer-path or early
admission/lease-prefix failure.

## Gate E1.2 freeze — phase-local admission discrimination

| Field | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | `bd11d779bd19813cbfba9e070c20be11e6dcbbb4` / tree `8c2aa495fcde674b003040455637c7ce0750956a` |
| Source predecessor | `aba540a3009c4218b75fc065188dddce330f4b50` / tree `ee13a67abb0853e15e2da7745bc6def11cae5f6f` |
| Consumed source identity | `afb3c46461736ddf7b275d797d054000d260eeebc0c6c50a7a94451ef1c97a19`; no relaunch |
| Authorized successor source commits | `1` |
| Authorized production method-8 invocations | at most `1`, only after the pre-shot floor |
| New authority | none |
| New process or role | none |
| Gate F authorization | `false` |

The successor may change only these three paths:

1. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2Supervisor/main.swift`
2. `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift`
3. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift`

`main.swift` may only replace the status-66 lexical block with four sequential
typed assignments and fixed phase-local catches. It may not inspect an error
type, associated value, string, errno, path, or child state. The exact silent
status map is:

| Status | Last operation entered |
| ---: | --- |
| `65` | Gate A argc/stdin/canonical decode/request validation |
| `66` | private developer-directory derivation |
| `71` | public `admitPrerequisites` call |
| `72` | one-shot prerequisite consume |
| `73` | guarded-preexecutor preparation |
| `67` | dedicated supervisor-image bind and revalidation |
| `68` | Gate E fixed probes and semantic bind |
| `69` | final retained-binding revalidation |
| `70` | existing Core containment fail-stop; unchanged and untranslatable |
| `0` | complete retained Gate E binding through normal return |

The existing Gate E static method must bind all nine `_exit` references to
those exact operation boundaries and conserve the Gate A frame, silence, and
absence of explicit exit `0` or `70`. Method 8 may only update its fixed
status-to-label table. Its source-identity root, exclusive creation, retention,
metadata checks, one-invocation rule, and journal verification remain exact.
The provenance file changes only by canonical reseal.

Every PrimeCore admission, lease, source/watch, executor, facade, process,
journal, and containment path is immutable. DriverCore bindings, requests,
contracts, planner, role table, package manifests, locks, inventories,
`Package.resolved`, `.github`, and Gate F remain immutable. The consumed root
at `/private/tmp/prime-driver-v2-gate-e-release-afb3c46461736ddf7b275d797d054000d260eeebc0c6c50a7a94451ef1c97a19`
must remain retained and unmodified.

Before execution, require a clean successor commit/tree and canonical
545-file/544-record reseal, both compile-only gates, the seven frozen Debug
methods separately, and exactly one Release admission proof from an exact
standalone successor clone under the existing XCTest-only seam. Update the
standalone Prime production-proof clone locally to the exact successor; keep
the pinned companion clean. The new identity-bound candidate root must be
absent. Record the Release supervisor's regular-file metadata, byte count, and
SHA-256 before method 8. Then run exactly one existing Release method-8
invocation. No simultaneous clone inspection, network, dependency fetch,
GitHub operation, broad suite, production retry, or cleanup is authorized.
Any unexpected path delta, identity/count mismatch, dirty status, clone
commit/tree mismatch, consumed-root drift, occupied successor root, or
compile/test/admission failure is a hard stop before method 8. Any nonzero
production result consumes the new identity and must be recorded with status,
phase, retained-root inventory, and `ABSTAIN` for any cause not proved by
those data. Only exit `0` plus the complete verified journal can checkpoint
Gate E and permit a later Gate F freeze.

## Gate E1.2 pre-shot interruption — manifest cache denial

| Field | Observed value |
| --- | --- |
| Result | `PRE_SHOT_FLOOR_BLOCKED_NON_AUTHORITY` |
| Durable-control predecessor | `cbe1ea75d41ff0b0460f5f679517ca3463fc31ba` / tree `74d111e46b1608e29269d9cedeff2fa35f3e8808` |
| Source commit/tree | `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Source predecessor/tree | `aba540a3009c4218b75fc065188dddce330f4b50` / `ee13a67abb0853e15e2da7745bc6def11cae5f6f` |
| Embedded/source identity | `194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f` |
| Canonical source cardinality | 545 admitted files / 544 identity records |
| Root / nested compile-only gates | exit `0` / `0`; wall `9.359` / `12.413` seconds |
| Seven separate Debug methods | all exit `0`; each exactly 1 XCTest / 0 failures |
| Debug test elapsed seconds | `0.030`, `1.004`, `1.388`, `5.756`, `2.239`, `4.432`, `3.458` |
| Diagnostic Prime clone | clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Companion clone | clean `163fc100710ece48119bc25954452d10f6a84f7f` / `9009daa4f8a07fbd5897e00b9571cef44ec292db` |
| Release-admission SwiftPM harness attempts | `1` |
| Shell result | exit `1` during package-manifest compilation |
| Exact observed blocker | write below `/Users/ergentics/.cache/clang/ModuleCache` denied with `Operation not permitted` |
| Test-runner markers | `Selected tests=0`; `Test Suite=0`; `Test Case=0`; `Test run started=0` |
| Selected-test executions | `0` |
| Production method-8 invocations | `0` |
| Supervisor / fixed-probe children | `0` / `0` |
| Identity-bound production root | absent |
| Consumed prior root | retained at device `16777231`, inode `17321558`, mtime `1787444179`, link count `8` |
| Candidate consumption | `false` |
| Gate E outcome | `NOT_RUN`; no authority or scientific conclusion |

The command stopped in outer SwiftPM manifest compilation before XCTest
started. Ignored build state may have changed, but the committed source/tree,
canonical identity, and both standalone clone worktrees remained clean. No
production root, lease, or journal was created, and no Driver V2 supervisor
or fixed-probe child process was launched. The E1.2 floor hard stop therefore
blocks method 8 under the prior freeze, but the source identity is not
consumed.

## Gate E1.2 cache-only Release-admission recovery freeze

| Field | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Source commit/tree | `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Source identity | unconsumed `194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f` |
| Source edits / commits | `0` / `0` |
| Authorized corrected Release-admission attempts | exactly `1` |
| Authorized production invocations during recovery | `0` |
| Production method-8 budget after a passing recovery | still the original first invocation; no retry added |
| Gate F authorization | `false` |

This freeze supersedes only the Release-admission floor hard stop caused by
the sandbox-blocked default module-cache path. Every other E1.2 boundary and
hard stop remains exact. These interruption and recovery sections must first
exist in a clean control commit/tree descended directly from
`cbe1ea75d41ff0b0460f5f679517ca3463fc31ba`; creating either cache directory
or invoking the corrected command before that commit is a hard stop.

Use the clean successor clone
`/private/tmp/gate-e-preflight-prime.IBJAfD/prime` and clean pinned companion
`/private/tmp/gate-e-companion-measure.pMGSXT/companion`. The only corrected
inputs are these fresh, empty, nonsymlink, UID-501, mode-0700 build-harness
cache directories:

- `CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-2-release-admission-clang-module-cache-194cf7141172ee06`
- `SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-2-release-admission-swiftpm-module-cache-194cf7141172ee06`

Create each exact leaf once with an exclusive `mkdir`; `EEXIST` is a hard
stop rather than reuse. Before invocation, open each leaf
`O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC`, join its descriptor
device/inode to an `lstat` path readback, and require directory type, UID
`501`, mode `0700`, link count `2`, zero entries, and no ACL. Any
symlink, ACL marker/entry, ownership or mode mismatch, rebound path, or
preexisting content is a hard stop.

Use exact working directory
`/private/tmp/gate-e-preflight-prime.IBJAfD/prime` and run exactly:

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-2-release-admission-clang-module-cache-194cf7141172ee06 SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-2-release-admission-swiftpm-module-cache-194cf7141172ee06 PRIME_PMHNP_COMPANION_ROOT=/private/tmp/gate-e-companion-measure.pMGSXT/companion swift test --package-path /private/tmp/gate-e-preflight-prime.IBJAfD/prime/Tests/PrimeValidationWorkflow --configuration release --disable-automatic-resolution --disable-sandbox --filter PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.testPublicReleaseAdmissionUsesEmbeddedSourceAuthority
```

No extra or missing CLI argument or inline environment assignment is
permitted. Do not set `HOME` or an external scratch path.

Before the command, require both clone statuses empty, both cache paths fresh
and private, the successor production root absent, and the consumed
`afb3c464…` root unchanged. A pass requires shell exit `0`, exactly one
selected XCTest pass, 2,157 watchers, zero supervisor/fixed-probe children,
clean post-statuses, and the production root still absent. The cache variables
are outer compilation controls, not Driver V2 request inputs. The selected
test does not read them, and no Driver V2 child is authorized.

Any source edit, dependency fetch, network access, broad selection,
production supervisor, method 8, fixed probe, candidate-root creation,
consumed-root mutation, cache-path mismatch, or nonpassing corrected result is
a hard stop. It authorizes neither another admission attempt nor method 8. A
passing recovery satisfies only the blocked admission floor; every remaining
E1.2 pre-shot condition must be revalidated before the candidate's first and
only production method-8 invocation.

## Gate E1.2 cache-only Release-admission recovery result

| Field | Observed value |
| --- | --- |
| Result | `PASS_PRE_SHOT_FLOOR_NON_AUTHORITY` |
| Durable-control predecessor | `992e57c4ccd6b2d9172d8a75646d71e14933e881` / tree `9dc99acbac8374e31c55fa9e2c3d00545ffdf154` |
| Source commit/tree | `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Embedded/source identity | `194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f` |
| Corrected command result | exit `0`; Release build `187.24` seconds |
| Measured XCTest interval | `2026-08-23T01:04:24.759Z` through `2026-08-23T01:04:27.510Z` |
| Selected XCTest | exactly `1` executed / `1` pass / `0` failures |
| Selected-test elapsed | `2.751` seconds |
| Combined watcher assertion | `2,157` |
| Total Release-admission SwiftPM harness attempts | `2`: one manifest denial plus one corrected pass |
| Selected-test executions across both attempts | `1` |
| Production method-8 invocations | `0` |
| Driver V2 supervisor / fixed-probe launches | `0` / `0` |
| Cache descriptor/path joins before command | device `16777231`; inodes `17325697` / `17325698`; UID `501`; mode `0700`; link count `2`; empty; ACL-free |
| Cache leaves after command | same inodes; link counts `3` / `10`; retained |
| Post-command statuses | source, diagnostic Prime, companion, and control: `0` bytes |
| Identity-bound production root | absent |
| Consumed prior root | unchanged at device `16777231`, inode `17321558`, mtime `1787444179`, link count `8` |
| Candidate consumption | `false` |
| Gate E outcome | `NOT_RUN`; no new authority or scientific conclusion |

The passing selected test re-established only the existing public
admission/consume/dual-watch floor under the XCTest-only current-image seam.
It did not close `supervisor_executable_image`, execute fixed Git/Swift
probes, or authorize Gate F. The earlier failed SwiftPM command remains
recorded and is not rewritten as a test execution.

## Gate E1.2 source-worktree Release supervisor build freeze

| Field | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | `992e57c4ccd6b2d9172d8a75646d71e14933e881` / tree `9dc99acbac8374e31c55fa9e2c3d00545ffdf154` |
| Source worktree | `/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging` |
| Source commit/tree | clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Production-proof Prime clone | `/private/tmp/gate-e-prime-proof.lJ0uQj/prime`; clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Companion clone | clean `163fc100710ece48119bc25954452d10f6a84f7f` / `9009daa4f8a07fbd5897e00b9571cef44ec292db` |
| Authorized build commands | exactly `1` |
| Authorized tests / production invocations | `0` / `0` |
| Source edits / commits | `0` / `0` |
| Gate F authorization | `false` |

Method 8 derives the supervisor image from its compile-time `#filePath`.
Therefore the required product belongs to the source worktree's nested
package, not either standalone Prime clone. This build command has no Prime
clone environment input. The conserved later method-8 binding is
`PRIME_DRIVER_V2_GATE_E_PRIME_ROOT=/private/tmp/gate-e-prime-proof.lJ0uQj/prime`;
the diagnostic `gate-e-preflight-prime.IBJAfD` clone is ineligible for that
production invocation.

The current source-worktree image is a pre-successor artifact and is a hard
stop: device `16777231`, inode `17321155`, UID `501`, mode `0755`,
link count `1`, byte count `47,675,784`, mtime `1787444101`, SHA-256
`09fb981b6350e630443998024eba11e4877e633bc5ff2f87b90d6513d75ff909`.
Immediately before the command, require that exact device, inode, byte count,
mtime, and SHA-256 preimage again; any drift is a hard stop.

These exact cache leaves must be absent before this control section is
committed:

- `CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-2-source-release-supervisor-clang-module-cache-194cf7141172ee06`
- `SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-2-source-release-supervisor-swiftpm-module-cache-194cf7141172ee06`

After this section exists in a clean control commit directly descended from
`992e57c4ccd6b2d9172d8a75646d71e14933e881`, create each leaf once with
exclusive `mkdir`; `EEXIST` is a hard stop. Before the build, open each
leaf `O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC`, join its descriptor
device/inode to `lstat` before and after an empty-directory read, and require
directory type, UID `501`, mode `0700`, link count `2`, zero entries, no
ACL, and local APFS device `16777231`.

Use exact working directory
`/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging`
and run exactly:

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-2-source-release-supervisor-clang-module-cache-194cf7141172ee06 SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-2-source-release-supervisor-swiftpm-module-cache-194cf7141172ee06 swift build --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow --configuration release --product PrimeValidationWorkflowDriverV2Supervisor --disable-automatic-resolution --disable-sandbox
```

No extra or missing CLI argument or inline environment assignment is
permitted. Do not set `HOME`, a companion input, or an external scratch path.
The exact expected product is
`/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowDriverV2Supervisor`.

A pass requires shell exit `0`; explicit recompilation of the changed
PrimeCore provenance input and supervisor `main.swift`; relinking of
`PrimeValidationWorkflowDriverV2Supervisor`; and no XCTest/Swift-Testing
runner markers. A no-op build is a hard stop. Record the build-start epoch and
require the exact product's mtime and ctime to advance beyond it.

Open the resulting image `O_RDONLY|O_NOFOLLOW|O_CLOEXEC`; join descriptor and
path device/inode before and after the read; and require a regular arm64 Mach-O
with UID `501`, mode `0755`, link count `1`, no ACL, safe file flags,
specifically numeric file flags `0`, only the permitted
`com.apple.provenance` extended attribute, and stable
nonzero bytes. Compute SHA-256 from the held descriptor, require it to differ
from the pre-successor hash, and require the bytes to contain sealed identity
`194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`
but not predecessor identity
`afb3c46461736ddf7b275d797d054000d260eeebc0c6c50a7a94451ef1c97a19`.

Source and both clone statuses must remain clean; `Package.resolved` and all
manifests must remain unchanged; the successor production root must remain
absent; and the consumed prior root must remain unchanged. Compiler and linker
descendants are expected and confer no Driver V2 authority. This build
authorizes no test, image bind, fixed probe, journal, production supervisor
launch, Gate E conclusion, or Gate F work.

Any cache mismatch, source/clone drift, dependency fetch, network access,
unexpected runner marker, missing or unchanged product, occupied production
root, consumed-root mutation, or nonzero build result is a hard stop. It
authorizes neither another build attempt nor method 8. A passing build must be
recorded with its exact product metadata and hash before the remaining
pre-shot floor may be declared ready.

## Gate E1.2 source-worktree Release supervisor build result

| Field | Observed value |
| --- | --- |
| Result | `PASS_COMPILE_ONLY_NON_AUTHORITY` |
| Durable-control predecessor | `542839d36a8d710613cc1883d03ced0f4ab5b86c` / tree `bd24fa9abba7569d99b2fc9a95af4ac378119185` |
| Source commit/tree | clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Build start | `2026-08-23T01:13:54Z`; epoch `1787447634` |
| SwiftPM result | exit `0`; `185.16` seconds |
| Transcript | PrimeCore and supervisor compilation; supervisor relink; no XCTest/Swift-Testing marker |
| Build-cache pre-admission | device `16777231`; inodes `17334168` / `17334169`; UID `501`; mode `0700`; link count `2`; empty; ACL-free |
| Build-cache post-state | same inodes; link counts `3` / `10`; retained |
| Supervisor device/inode | `16777231` / `17335100`; descriptor/path joined and stable |
| Supervisor owner/mode/link count | UID `501`; GID `20`; `0755`; `1` |
| Supervisor bytes/time/flags | `45,596,744`; mtime/ctime `1787447820`; flags `0` |
| Supervisor SHA-256 | `342cd64bcb2e01ce4d037293ef11cc64386bfa0e5a9f05e6ba05292eca3b1b53` |
| Supervisor image | regular arm64 Mach-O; ACL-free; only `com.apple.provenance` xattr |
| Embedded identity | current `194cf714…` present; predecessor `afb3c464…` absent |
| Post-build statuses | source, production Prime clone, diagnostic Prime clone, companion, and control: `0` bytes |
| Production method-8 invocations | `0` |
| Successor root | absent |
| Prior consumed root | unchanged at device `16777231`, inode `17321558`, mtime `1787444179`, link count `8` |
| Candidate consumption | `false` |
| Gate E outcome | `NOT_RUN`; no authority |

The exact product build replaced only ignored build output and populated its
two frozen module caches. It did not run XCTest, launch the supervisor, bind
its image, create a production root, or close any Gate E authority.

The required source-worktree Release XCTest executable remained stale after
that product-only command:

| Field | Observed preimage |
| --- | --- |
| XCTest executable | `Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowPackageTests.xctest/Contents/MacOS/PrimeValidationWorkflowPackageTests` |
| Device/inode | `16777231` / `17321182`; descriptor/path joined |
| Owner/mode/link count | UID `501`; GID `20`; `0755`; `1` |
| Byte count | `56,482,224` |
| mtime/ctime/flags | `1787444108` / `1787444108` / `0` |
| Image metadata | regular arm64 Mach-O bundle executable; ACL-free; only `com.apple.provenance` xattr |
| SHA-256 | `6ac8a09f4d6df5b1fef612e631b90c770e848ba44e4bed68a925222b2302d73d` |
| Embedded identity | predecessor `afb3c464…` present; current `194cf714…` absent |

That XCTest executable is ineligible to run method 8.

## Gate E1.2 freeze — one compile-only Release test-bundle build

| Field | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | `542839d36a8d710613cc1883d03ced0f4ab5b86c` / tree `bd24fa9abba7569d99b2fc9a95af4ac378119185` |
| Source commit/tree | clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Production-proof Prime clone | `/private/tmp/gate-e-prime-proof.lJ0uQj/prime`; same clean commit/tree |
| Companion clone | `/private/tmp/gate-e-companion-measure.pMGSXT/companion`; clean `163fc100710ece48119bc25954452d10f6a84f7f` / `9009daa4f8a07fbd5897e00b9571cef44ec292db` |
| Authorized build commands | exactly `1` |
| Authorized XCTest executions / built-product launches | `0` / `0` |
| Source edits / commits | `0` / `0` |
| Production method-8 invocations | `0` |
| Gate F authorization | `false` |

This result and freeze must first exist in a clean control commit directly
descended from `542839d36a8d710613cc1883d03ced0f4ab5b86c`. Before
that commit, cache creation or the command is forbidden.

Create exactly once with exclusive `mkdir` these currently absent leaves:

- `CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-2-source-release-build-tests-clang-module-cache-194cf7141172ee06`
- `SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-2-source-release-build-tests-swiftpm-module-cache-194cf7141172ee06`

`EEXIST` is a hard stop. Apply the same no-follow descriptor/path join, UID
`501`, mode `0700`, empty/link-count-two, ACL-free, and APFS device
`16777231` checks frozen for the product build. These fresh leaves may be
populated only by the exact command below and must remain retained afterward;
later reuse, if any, requires a separate final-shot-readiness freeze.

Immediately before the command, require source and both production clones
clean at their exact commits/trees; canonical identity `194cf714…`; the
supervisor preimage exactly at SHA-256 `342cd64b…` with its recorded
metadata; the XCTest preimage exactly at SHA-256 `6ac8a09f…` with its
recorded metadata; the successor production root absent; and the prior
consumed root unchanged.

Use exact working directory
`/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging`
and run exactly once:

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-2-source-release-build-tests-clang-module-cache-194cf7141172ee06 SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-2-source-release-build-tests-swiftpm-module-cache-194cf7141172ee06 swift build --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow --configuration release --build-tests --disable-automatic-resolution --disable-sandbox
```

No extra or missing argument or inline environment assignment is permitted.
Do not set `HOME`, companion input, or external scratch path.

A pass requires shell exit `0`; explicit compilation of the changed live
test target and relinking of
`PrimeValidationWorkflowPackageTests.xctest`; no XCTest/Swift-Testing runner
marker; and no execution of either the exact XCTest bundle executable or
`PrimeValidationWorkflowDriverV2Supervisor`. Manifest, compiler, and linker
subprocesses are expected and non-authoritative. A no-op test-bundle build is
a hard stop. Record the build-start epoch and require the XCTest executable's
mtime/ctime to advance beyond it.

Walk every XCTest bundle path component no-follow and reject any symlink or
rebound directory. Open the final executable
`O_RDONLY|O_NOFOLLOW|O_CLOEXEC`, join descriptor/path device and inode before
and after a stable read, and require a regular arm64 Mach-O bundle executable,
UID `501`, GID `20`, mode `0755`, link count `1`, flags `0`, no ACL,
only the permitted `com.apple.provenance` xattr, and stable nonzero bytes.
Its SHA-256 must differ from `6ac8a09f…`; current identity `194cf714…` and
the exact source-worktree `#filePath` must be present; predecessor identity
`afb3c464…` must be absent.

The exact command may leave the supervisor untouched or rebuild/relink it as
a dependency. Walk its path components no-follow, reopen the final supervisor,
and repeat every prior vnode, stable-read, regular arm64 Mach-O, UID `501`,
GID `20`, mode, link-count, flags, ACL, xattr,
current-identity-present, and predecessor-identity-absent check.
If its inode, timestamps, or bytes changed, require the mutation within the
measured build interval and a matching supervisor compile/relink transcript.
Any unexplained mutation is a hard stop.

All tracked statuses must remain clean; manifests and `Package.resolved`
must remain unchanged; the successor root must remain absent; and the prior
root must remain unchanged. Any failure, no-op, dependency fetch, network
access, runner marker, built-product execution, cache mismatch, unexpected
artifact mutation, identity mismatch, root drift, or extra invocation forbids
another build and method 8.

Even a passing `--build-tests` command authorizes no production launch. Its
exact result, final XCTest hash/metadata, final supervisor hash/metadata,
complete pre-shot floor, clean statuses, and both root states must be recorded
in a separate clean final-shot-readiness checkpoint before any later freeze
may authorize the first method-8 invocation.

## Gate E1.2 Release test-bundle build interruption

| Field | Observed value |
| --- | --- |
| Result | `PRE_SHOT_BUILD_BLOCKED_NON_AUTHORITY` |
| Durable-control predecessor | `14e90e7068da73bfd1444cd5654383ccb99be9a1` / tree `39fc231dd20b6bd8d73a7e5b8f2a61bf65d74ea4` |
| Source commit/tree | clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Build start | `2026-08-23T01:29:34Z`; epoch `1787448574` |
| Shell result | exit `1`; `2.903` seconds |
| Exact Swift diagnostic | `module 'PrimeValidationWorkflowContracts' was not compiled for testing` at the ContractsTests `@testable import` |
| Transcript prefix | SpawnCanary compile/link and ContractsTests compile; no XCTest/Swift-Testing runner marker |
| Selected XCTest executions | `0` |
| Production method-8 invocations | `0` |
| Driver V2 supervisor / fixed-probe launches | `0` / `0` |
| Supervisor after failure | unchanged inode `17335100`; SHA-256 `342cd64bcb2e01ce4d037293ef11cc64386bfa0e5a9f05e6ba05292eca3b1b53` |
| XCTest executable after failure | unchanged inode `17321182`; stale SHA-256 `6ac8a09f4d6df5b1fef612e631b90c770e848ba44e4bed68a925222b2302d73d` |
| Failed-build cache leaves | device `16777231`; inodes `17335574` / `17335575`; UID `501`; mode `0700`; post link counts `3` / `10`; retained and ineligible for reuse |
| Post-command statuses | source, production Prime clone, companion, and control: `0` bytes |
| Successor production root | absent |
| Prior consumed root | unchanged at device `16777231`, inode `17321558`, mtime `1787444179`, link count `8` |
| Candidate consumption | `false` |
| Gate E outcome | `NOT_RUN`; no authority or scientific conclusion |

The failure occurred in SwiftPM's test-build transaction before a runner
started. The available Release Contracts module was not compiled for testing;
the transcript does not establish why SwiftPM supplied that module. Neither
definitive artifact changed, so the source identity remains unconsumed. The
frozen compile-only command is exhausted and may not be retried.

## Gate E1.2 freeze — one Release test-enabled structural recovery

| Field | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | `14e90e7068da73bfd1444cd5654383ccb99be9a1` / tree `39fc231dd20b6bd8d73a7e5b8f2a61bf65d74ea4` |
| Source commit/tree | clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Authorized SwiftPM recovery invocations | exactly `1` |
| Authorized XCTest runner invocations | exactly `1`, loading only the exact bundle and selected method |
| Authorized selected XCTest executions | exactly `1` |
| Exact selected method | `PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.testCapabilitySurfaceHasNoCodecPublicInitializerOrSpawn` |
| Every other package-product / child / runner execution | `0` |
| Authorized production supervisor / fixed-probe launches | `0` / `0` |
| Production method-8 invocations | `0` |
| Source edits / commits | `0` / `0` |
| Gate F authorization | `false` |

The exact selected method is source-only: it reads the committed admission,
DriverCore bridge, supervisor-main, and nested-manifest sources and asserts
the absence of codecs, public initializers, raw process/spawn surfaces, caller
arguments/environment, and fixture-child dependencies. It constructs no
fixture, root, lease, watch, journal, process, environment input, request, or
live capability. It is not Debug-only. Its sole purpose in this recovery is
to make SwiftPM compile the Release test graph with testable dependencies,
relink the current package XCTest executable, and execute one
non-authoritative structural assertion set.

This interruption and recovery freeze must first exist in a clean control
commit directly descended from
`14e90e7068da73bfd1444cd5654383ccb99be9a1`. Before that commit, cache
creation or the recovery command is forbidden.

Immediately before cache creation and again immediately before the recovery
command, require the control worktree clean at that direct-child commit,
whose only predecessor delta is this interruption and freeze in the one
durable-control path. Any control HEAD, tree, tracked-status, or uncommitted
document drift is a hard stop.

Create exactly once with exclusive `mkdir` these currently absent leaves:

- `CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-2-source-release-structural-test-clang-module-cache-194cf7141172ee06`
- `SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-2-source-release-structural-test-swiftpm-module-cache-194cf7141172ee06`

`EEXIST` is a hard stop. Apply the same no-follow descriptor/path join, UID
`501`, mode `0700`, empty/link-count-two, ACL-free, and APFS device
`16777231` checks. The product-build and failed-build cache leaves are not
inputs to this command.

Both recovery-cache leaves must remain retained after the command. The four
earlier product-build and failed-build cache leaves remain retained,
unchanged, and ineligible for input, reuse, cleanup, or mutation:

- `/private/tmp/gate-e1-2-source-release-supervisor-clang-module-cache-194cf7141172ee06`
- `/private/tmp/gate-e1-2-source-release-supervisor-swiftpm-module-cache-194cf7141172ee06`
- `/private/tmp/gate-e1-2-source-release-build-tests-clang-module-cache-194cf7141172ee06`
- `/private/tmp/gate-e1-2-source-release-build-tests-swiftpm-module-cache-194cf7141172ee06`

Disappearance, path/inode rebound, reuse, cleanup, or unexplained mutation of
any of these six retained leaves is a hard stop.

Immediately before the command, require source, production Prime clone, and
companion clean at their exact commits/trees; the successor production root
absent; and the prior consumed root unchanged. Re-admit both Release artifacts
with the complete no-follow component walk, held `O_NOFOLLOW | O_CLOEXEC`
descriptors, descriptor/path device-and-inode joins, stable descriptor reads,
regular arm64 Mach-O checks, and every previously recorded type, UID/GID,
mode, link-count, flags, ACL, xattr, size, timestamp, identity, and hash fact.
The supervisor must remain device `16777231`, inode `17335100`, size
`45596744`, mtime/ctime `1787447820`, and SHA-256
`342cd64bcb2e01ce4d037293ef11cc64386bfa0e5a9f05e6ba05292eca3b1b53`,
with current identity present and predecessor absent. The stale XCTest
executable must remain device `16777231`, inode `17321182`, size `56482224`,
mtime/ctime `1787444108`, and SHA-256
`6ac8a09f4d6df5b1fef612e631b90c770e848ba44e4bed68a925222b2302d73d`,
with predecessor identity
`afb3c46461736ddf7b275d797d054000d260eeebc0c6c50a7a94451ef1c97a19`
present and current identity
`194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`
absent. The supervisor has the inverse identity membership.

Use exact working directory
`/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging`
and run exactly once:

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-2-source-release-structural-test-clang-module-cache-194cf7141172ee06 SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-2-source-release-structural-test-swiftpm-module-cache-194cf7141172ee06 swift test --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow --configuration release --disable-automatic-resolution --disable-sandbox --disable-swift-testing --filter PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.testCapabilitySurfaceHasNoCodecPublicInitializerOrSpawn
```

No extra or missing argument or inline environment assignment is permitted.
Do not set `HOME`, Prime or companion inputs, an external scratch path, or
`--skip-build`.

A pass requires shell exit `0`; a test-enabled Release build; explicit
DriverCoreTests compilation and package XCTest relink; exactly one selected
XCTest execution and pass; and no method-8 selection. The execution whitelist
is SwiftPM/compiler/linker/manifest tooling plus exactly one XCTest runner
loading the exact bundle and selector. Authorized launches are zero for
`PrimeValidationWorkflowFixtureChild`, SecureChildIntegration children,
`PrimeValidationWorkflowDriverV2SpawnCanary`,
`PrimeValidationWorkflowDriverV2Supervisor`, every Git/Swift fixed-probe
child, every other package-built executable, and any additional XCTest or
Swift-Testing runner. Compilation or linking of package targets does not
authorize their execution.

Afterward, perform the complete no-follow component walk, descriptor/path
join, stable-read, arm64 Mach-O, UID/GID/mode/link-count, flags, ACL, xattr,
and identity checks on both final artifacts. The XCTest executable must have
mtime/ctime after recovery start, a new SHA-256 differing from
`6ac8a09f4d6df5b1fef612e631b90c770e848ba44e4bed68a925222b2302d73d`,
current identity
`194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`
and the exact source-worktree `#filePath` present, and predecessor
`afb3c46461736ddf7b275d797d054000d260eeebc0c6c50a7a94451ef1c97a19`
absent. The supervisor may be unchanged or explainably relinked inside the
recovery interval, but its final image must contain current identity, exclude
predecessor identity, and pass every prior image check.

All tracked statuses and clone identities must remain exact; manifests and
`Package.resolved` must remain unchanged; the successor root must remain
absent; and the prior root must remain unchanged. Any failure, wrong test
count, non-whitelisted child or runner execution, production selection or
launch, dependency fetch, network access, cache mismatch, unexplained artifact
mutation, identity mismatch, root drift, or extra invocation forbids another
recovery attempt and method 8.

Even a pass authorizes no production launch. Its exact selected-test result,
final XCTest and supervisor hashes/metadata, complete floor, clean statuses,
and root states must be committed in a separate final-shot-readiness
checkpoint before the candidate's first method-8 invocation can be
authorized.

## Gate E1.2 structural-recovery result and final-shot readiness checkpoint

| Field | Observed value |
| --- | --- |
| Result | `PASS_TEST_ENABLED_STRUCTURAL_RECOVERY_NON_AUTHORITY` |
| Checkpoint disposition | `READY_PENDING_SEPARATE_SHOT_FREEZE` |
| Durable-control predecessor | `4eb757fb9d1246f57e334dc41fbb8ea9b5d8ca22` / tree `f3915baa1c6818c30ad111b7d42be7614f875bad` |
| Source commit/tree | clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Source identity | unconsumed `194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f` |
| Measured interval | `2026-08-23T01:46:16Z` / epoch `1787449576` through `2026-08-23T01:49:53Z` / epoch `1787449793` |
| SwiftPM result | exit `0`; build complete in `193.37` seconds |
| Exact selector | `PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.testCapabilitySurfaceHasNoCodecPublicInitializerOrSpawn` |
| Selected XCTest | exactly `1` execution / `1` pass / `0` failures or unexpected failures; case `0.016` seconds; selected suite `0.017` seconds |
| Swift Testing | disabled; no Swift-Testing runner |
| Production supervisor / fixed-probe launch markers and effects | `0` / `0`; direct process census `ABSTAIN` |
| Production method-8 invocations | `0` |
| Candidate consumption | `false` |
| Gate E outcome | `NOT_RUN`; no new authority or scientific conclusion |
| Authorized next production action | `0`; only a later control-only shot freeze may be authored |
| Gate F authorization | `false` |

The Release transcript crossed the earlier Contracts testability stop, then
compiled DriverCoreTests and relinked both definitive artifacts. The exact
selected method read only the four committed source/manifest inputs and
constructed no fixture, capability, request, process, root, lease, watch, or
journal. Build products including SpawnCanary, FixtureChild,
SecureChildIntegration, and the supervisor were compiled or linked but not
selected; the exact transcript and closed selector contain no
non-whitelisted launch marker or launch path.

| Final supervisor fact | Observed value |
| --- | --- |
| Absolute path | `/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowDriverV2Supervisor` |
| Device/inode | `16777231` / `17337418`; descriptor/path joined before and after stable read |
| UID/GID/mode/nlink/flags | `501` / `20` / `0755` / `1` / `0` |
| Size; mtime/ctime | `47,675,784`; `1787449777` / `1787449777` |
| Image | regular arm64 `MH_EXECUTE`; UUID `6A097D4D-B7F2-32FD-B77C-012BE54EDD0E`; ACL-free; only `com.apple.provenance` xattr |
| SHA-256 | `fda8ab7c8f06a94c4f957f879312a6911d7e32015a344ea5b9ad63bbd04215ff` |
| Identity membership | current identity exactly once; predecessor identity absent |

| Final XCTest executable fact | Observed value |
| --- | --- |
| Absolute path | `/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowPackageTests.xctest/Contents/MacOS/PrimeValidationWorkflowPackageTests` |
| Device/inode | `16777231` / `17337446`; descriptor/path joined before and after stable read |
| UID/GID/mode/nlink/flags | `501` / `20` / `0755` / `1` / `0` |
| Size; mtime/ctime | `56,490,080`; `1787449784` / `1787449784` |
| Image | regular arm64 `MH_BUNDLE`; UUID `B65DABC8-28A9-3EE9-ABCC-4DB026D7FC39`; ACL-free; only `com.apple.provenance` xattr |
| SHA-256 | `b3cf7e6aee0a73b05b493ff279b435f7b81b73c24c24b1731986d0adc0f534d5` |
| Identity/path membership | current identity exactly once; predecessor identity absent; exact source-worktree `#filePath` exactly once |
| Test-build evidence | DriverCoreTests module mtime `1787449779`; selected live-test object mtime `1787449784` |

The complete pre-shot floor is now data-closed:

| Floor item | Observed value |
| --- | --- |
| Canonical source reseal | `545` admitted files / `544` identity records; identity `194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f` |
| Root / nested compile-only gates | exit `0` / `0`; `9.359` / `12.413` seconds |
| Seven frozen Debug selectors | `7` executions / `7` passes / `0` failures; each exactly one XCTest |
| Debug elapsed seconds | `0.030`, `1.004`, `1.388`, `5.756`, `2.239`, `4.432`, `3.458` |
| Release public-admission proof | exactly `1` execution / `1` pass / `0` failures; `2.751` seconds; `2,157` watchers; XCTest-only image seam |
| Release test-enabled structural recovery | exactly `1` execution / `1` pass / `0` failures; both final artifacts refreshed and re-admitted |
| Nested manifest | plugin-free; tracked bytes unchanged |
| Root and nested `Package.resolved` / manifests | tracked bytes unchanged |
| Production method 8 | not invoked |

All eight retained module-cache leaves remain on device `16777231`, UID
`501`, mode `0700`, ACL-free, and provenance-xattr-only:

| Cache role and exact leaf | Inode / nlink | mtime / ctime |
| --- | --- | --- |
| Release admission clang `/private/tmp/gate-e1-2-release-admission-clang-module-cache-194cf7141172ee06` | `17325697` / `3` | `1787446879` / `1787446879` |
| Release admission SwiftPM `/private/tmp/gate-e1-2-release-admission-swiftpm-module-cache-194cf7141172ee06` | `17325698` / `10` | `1787446876` / `1787446876` |
| Product build clang `/private/tmp/gate-e1-2-source-release-supervisor-clang-module-cache-194cf7141172ee06` | `17334168` / `3` | `1787447637` / `1787447637` |
| Product build SwiftPM `/private/tmp/gate-e1-2-source-release-supervisor-swiftpm-module-cache-194cf7141172ee06` | `17334169` / `10` | `1787447635` / `1787447635` |
| Failed test build clang `/private/tmp/gate-e1-2-source-release-build-tests-clang-module-cache-194cf7141172ee06` | `17335574` / `3` | `1787448577` / `1787448577` |
| Failed test build SwiftPM `/private/tmp/gate-e1-2-source-release-build-tests-swiftpm-module-cache-194cf7141172ee06` | `17335575` / `10` | `1787448574` / `1787448574` |
| Structural recovery clang `/private/tmp/gate-e1-2-source-release-structural-test-clang-module-cache-194cf7141172ee06` | `17336716` / `3` | `1787449594` / `1787449594` |
| Structural recovery SwiftPM `/private/tmp/gate-e1-2-source-release-structural-test-swiftpm-module-cache-194cf7141172ee06` | `17336718` / `10` | `1787449591` / `1787449591` |

The six predecessor-leaf mtimes/ctimes predate recovery start. The structural
recovery leaf mtimes/ctimes `1787449594` and `1787449591` fall within the
measured interval after their exclusive empty admission. Those leaves were the
only cache inputs authorized for the exact command; the timestamps do not
independently attribute every contained write to a process. None is authorized
as a later command input by this checkpoint.

| Conserved repository/root fact | Observed value |
| --- | --- |
| Control before this checkpoint | clean `4eb757fb9d1246f57e334dc41fbb8ea9b5d8ca22` / `f3915baa1c6818c30ad111b7d42be7614f875bad` |
| Source worktree | clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Production Prime clone | `/private/tmp/gate-e-prime-proof.lJ0uQj/prime`; same clean source commit/tree |
| Diagnostic Prime clone | `/private/tmp/gate-e-preflight-prime.IBJAfD/prime`; same clean source commit/tree |
| Companion clone | `/private/tmp/gate-e-companion-measure.pMGSXT/companion`; clean `163fc100710ece48119bc25954452d10f6a84f7f` / `9009daa4f8a07fbd5897e00b9571cef44ec292db` |
| Successor production root | `/private/tmp/prime-driver-v2-gate-e-release-194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`; absent |
| Prior consumed root | device `16777231`; inode `17321558`; UID `501`; mode `0700`; nlink `8`; mtime `1787444179`; unchanged |

The post-command process census is `ABSTAIN`: `/bin/ps` was sandbox-denied,
and a later census could not prove absence of already-reaped children anyway.
The bounded evidence is the exact source-only selector, plugin-free manifest,
disabled Swift Testing, one XCTest execution/pass, exact build transcript,
zero production-root or journal creation, and no supervisor or fixed-probe
launch marker or closed-selector launch path.
Disposition:
`NO_NON_WHITELISTED_LAUNCH_EVIDENCED; POST_RUN_PS_UNAVAILABLE_SANDBOX_DENIED`.

This checkpoint authorizes no production launch, no cache reuse, no retry of
any prior command, no source edit, no GitHub or network operation, and no Gate
F work. A later clean direct-child control commit must bind this checkpoint's
commit/tree, both final artifact hashes and vnodes, exact roots, one explicit
cache policy, one exact method-8 command/environment, and permanent no-retry
terms before the first production invocation is authorized.

## Gate E1.2 freeze — first and only production method-8 shot

| Field | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | `baf55fb1939f96c949b906178ec4945c1742fa2a` / tree `4820b1705a1f3dad32591b4ba660c490f90a8411` |
| Permitted predecessor delta | this freeze only, in this one durable-control path |
| Source commit/tree | clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Source identity/cardinality | unconsumed `194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`; `545` files / `544` records |
| Authorized SwiftPM shot commands | at most `1`; success requires exactly `1` |
| Authorized method-8 executions | at most `1`; success requires exactly `1` |
| Exact selector | `PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.testGateEReleaseSupervisorRequiresLiveFourAuthorityBindingBeforeExit` |
| Source edits / package builds / relinks | `0` / `0` / `0` |
| Retry or relaunch after command start | permanently `false` |
| Gate F authorization | `false` |

This freeze must first exist in a clean control commit directly descended from
`baf55fb1939f96c949b906178ec4945c1742fa2a`, with this section as its
only predecessor delta. Cache creation or command execution before that commit
is a hard stop. After the commit and immediately before cache creation, require
the control worktree clean at that exact direct-child commit/tree. Repeat that
control check immediately before the command.

### Frozen harness and executable preimages

| Artifact | Required preimage |
| --- | --- |
| Outer Swift harness | `/usr/bin/swift`; device `16777231`; inode `1152921500312571585`; UID/GID `0`/`0`; mode `0755`; nlink `78`; flags `524320` (`restricted,compressed`); size `118928`; mtime/ctime `1782354543`; universal Mach-O UUIDs `091206DD-5D8E-3B10-A6BE-B9CE23E2C670` (`x86_64`) / `108866E5-077A-3BE9-8E2C-0DADD00E2F09` (`arm64e`); SHA-256 `179301dcb41ea78accc3fa0048a7e6f6710d891945a751a34addd622020c1818`; ACL-free and xattr-free |
| Supervisor path | `/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowDriverV2Supervisor` |
| Supervisor vnode | device `16777231`; inode `17337418`; UID/GID `501`/`20`; mode `0755`; nlink `1`; flags `0`; size `47,675,784`; mtime/ctime `1787449777` |
| Supervisor image/hash | arm64 `MH_EXECUTE`; UUID `6A097D4D-B7F2-32FD-B77C-012BE54EDD0E`; SHA-256 `fda8ab7c8f06a94c4f957f879312a6911d7e32015a344ea5b9ad63bbd04215ff` |
| XCTest path | `/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowPackageTests.xctest/Contents/MacOS/PrimeValidationWorkflowPackageTests` |
| XCTest vnode | device `16777231`; inode `17337446`; UID/GID `501`/`20`; mode `0755`; nlink `1`; flags `0`; size `56,490,080`; mtime/ctime `1787449784` |
| XCTest image/hash | arm64 `MH_BUNDLE`; UUID `B65DABC8-28A9-3EE9-ABCC-4DB026D7FC39`; SHA-256 `b3cf7e6aee0a73b05b493ff279b435f7b81b73c24c24b1731986d0adc0f534d5` |

Walk every path component no-follow. Open the two Release images on held
`O_RDONLY | O_NOFOLLOW | O_CLOEXEC` descriptors and repeat the readiness
checkpoint's descriptor/path joins, stable reads, Mach-O type/architecture,
ownership, mode, link-count, flags, ACL, xattr, UUID, hash, and byte-membership
checks. Both images must contain current identity
`194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`
exactly once and exclude predecessor identity
`afb3c46461736ddf7b275d797d054000d260eeebc0c6c50a7a94451ef1c97a19`;
the XCTest image must contain the exact source-worktree `#filePath` and exact
selected method once. Only `com.apple.provenance` is permitted as an xattr.

Immediately before and after the shot, separately open `/usr/bin/swift` on a
held `O_RDONLY | O_NOFOLLOW | O_CLOEXEC` descriptor. Join descriptor/path
device and inode before and after a stable descriptor hash, and require its
complete table tuple, regular universal-Mach-O type, both recorded UUIDs,
flags, ACL-free/xattr-free state, and SHA-256 unchanged.

`--skip-build` is mandatory. Any package-target compile or link marker, or
any pre/post artifact inode, timestamp, size, UUID, hash, permission, identity,
ACL, flag, or xattr drift, is a hard stop.

### Frozen roots, repositories, and predecessor evidence

| Item | Frozen value |
| --- | --- |
| Production Prime clone | `/private/tmp/gate-e-prime-proof.lJ0uQj/prime`; device/inode `16777231`/`17289159`; UID `501`; mode `0755`; clean source commit/tree above |
| Diagnostic Prime clone | `/private/tmp/gate-e-preflight-prime.IBJAfD/prime`; conserved clean at the same source commit/tree; not a command input |
| Companion clone | `/private/tmp/gate-e-companion-measure.pMGSXT/companion`; device/inode `16777231`/`17279918`; UID `501`; mode `0755`; clean `163fc100710ece48119bc25954452d10f6a84f7f` / tree `9009daa4f8a07fbd5897e00b9571cef44ec292db` |
| Successor root | `/private/tmp/prime-driver-v2-gate-e-release-194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`; must be absent by no-follow `lstat` |
| Prior consumed root | retained device/inode `16777231`/`17321558`; UID `501`; mode `0700`; nlink `8`; mtime `1787444179` |
| Prior-root direct inventory | exactly `workspace`, `evidence`, `lease`, `workspace.driver-v2-gate-e-journal`, `outer-supervisor-stdout.bin`, `outer-supervisor-stderr.bin`; all six retained at their recorded empty pre-authority state |

Require clean control, source, all three clone statuses, exact commits/trees,
canonical identity/cardinality, unchanged manifests and `Package.resolved`,
the complete prior-root inventory, and all eight readiness-cache tuples. No
simultaneous clone, artifact, root, or process inspection is permitted while
the measured runner/supervisor hierarchy is live. Repeat read-only checks only
after the command and all descendants have terminated.

### One-use outer-cache policy

The eight readiness-checkpoint cache leaves remain retained, unchanged, and
ineligible as command inputs. These two final-shot leaves are currently absent:

- `/private/tmp/gate-e1-2-final-shot-clang-module-cache-194cf7141172ee06`
- `/private/tmp/gate-e1-2-final-shot-swiftpm-module-cache-194cf7141172ee06`

After the shot-freeze commit, create each once with exclusive `mkdir`;
`EEXIST` is a permanent hard stop. Open each
`O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC`, join descriptor/path device
and inode before and after an empty read, and require local APFS device
`16777231`, directory type, UID/GID `501`/`0`, mode `0700`, nlink `2`, flags
`0`, empty inventory, no ACL, and exact xattr set `{com.apple.provenance}`.
These are the only external cache leaves authorized as command inputs. Retain
both after the command at their admitted path/inodes and record final metadata;
no cache cleanup or later reuse is authorized.

### Exact one-shot command

Use exact working directory
`/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging`
and run exactly once:

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-2-final-shot-clang-module-cache-194cf7141172ee06 SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-2-final-shot-swiftpm-module-cache-194cf7141172ee06 PRIME_DRIVER_V2_GATE_E_PRIME_ROOT=/private/tmp/gate-e-prime-proof.lJ0uQj/prime PRIME_PMHNP_COMPANION_ROOT=/private/tmp/gate-e-companion-measure.pMGSXT/companion /usr/bin/swift test --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow --configuration release --skip-build --disable-automatic-resolution --disable-sandbox --disable-swift-testing --filter PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.testGateEReleaseSupervisorRequiresLiveFourAuthorityBindingBeforeExit
```

No extra or missing CLI argument or inline environment assignment is
permitted. Do not set `HOME`, `DEVELOPER_DIR`, a scratch path, the diagnostic
clone, or another `PRIME_DRIVER_V2_*` / `PRIME_PMHNP_*` input. No network,
dependency fetch, GitHub operation, source mutation, cleanup, broad selection,
other test, build, list, or inventory role is authorized. The two outer cache
variables and root selectors are harness inputs; the dedicated supervisor is
spawned with argument zero only and an empty replacement environment.

### Exhaustive process and role ceiling

| Process or role | Authorized count |
| --- | ---: |
| Exact SwiftPM shot command | at most `1`; success requires exactly `1` |
| SwiftPM manifest compiler/linker/evaluator descendants | only those necessary to evaluate the pinned plugin-free manifests under the exact `--skip-build` command; package-target/test compilation or relinking remains `0` |
| XCTest runner / exact selected method | at most `1` / `1`; success requires exactly `1` / `1` |
| Dedicated production supervisor | at most `1`; success requires exactly `1` |
| Fixed-probe children | at most `16`; success requires exactly `16`, each role once in frozen order |
| Additional XCTest or Swift-Testing runner | `0` |
| FixtureChild, SecureChildIntegration, SpawnCanary, or another package executable | `0` |
| Build, staging, XCTest-inventory, or Swift-Testing-inventory Driver roles | `0` |

The frozen role order is:

1. `prime_head_pre`
2. `prime_object_format`
3. `prime_status_pre`
4. `prime_tree_discovery`
5. `prime_tree_replay`
6. `prime_status_post`
7. `prime_head_post`
8. `companion_head_pre`
9. `companion_object_format`
10. `companion_status_pre`
11. `companion_tree_discovery`
12. `companion_tree_replay`
13. `companion_status_post`
14. `companion_head_post`
15. `swift_version`
16. `swift_target_info`

The first 14 use the frozen Git image; the final two use the frozen physical
Swift frontend with logical argument zero `swift`. Every role is sequential,
one-shot, and internally owns its argv, root, image, five-entry environment
(`DEVELOPER_DIR`, `LANG=C`, `LC_ALL=C`, `SDKROOT`, `TERM=dumb`), output caps,
and the single absolute 30-second deadline. The outer supervisor containment
deadline is 60 seconds. Every child must prove suspended cwd/image joins,
durable start before resume, exact PID reap, independent EOF drains, and
`process_group_empty`. No seventeenth or retried role is authorized.

### Required result and retained evidence

A production pass requires all of these data:

- shell exit `0`; exactly one selected XCTest pass and no other test/runner;
- one supervisor normal exit `0` with retained empty stdout/stderr captures;
- exactly 16 successful fixed-role terminals in frozen order;
- successor base device `16777231`, UID/GID `501`/`0`, mode `0700`, nlink `8`,
  flags `0`, ACL-free/provenance-only, retained with exact direct inventory
  `workspace`, `evidence`, `lease`,
  `workspace.driver-v2-gate-e-journal`,
  `outer-supervisor-stdout.bin`, `outer-supervisor-stderr.bin`;
- both outer captures regular mode `0600`, nlink `1`, zero bytes, and SHA-256
  `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`;
- empty workspace and evidence directories;
- lease inventory containing only regular zero-byte mode-`0600`, nlink-`1`
  `prime-validation-swiftpm-build-inventory.lock`;
- journal nlink `36` and exactly 34 unique regular leaves: prestart, sixteen
  ordered start/terminal pairs, and raw terminal;
- every leaf no-follow admitted, UID `501`, mode `0400`, nlink `1`, at most
  64 KiB, newline-terminated canonical JSON, and individually hashed;
- canonical JSON framing, SHA chain, leaf schemas/names/ordinals, metadata,
  hashes, and internal self-consistency of recorded fields validated from the
  retained bytes; status, replay/agreement, and raw-terminal fields recorded as
  retained claims, not independent proof of missing raw child stdout or live
  semantic agreement;
- the retained four-authority binding and both source watches live through
  normal supervisor return, established in-process by exit `0` rather than
  reconstructed from a dead journal token;
- final repositories, artifacts, manifests, prior root, and eight predecessor
  caches unchanged; both final-shot cache roots retained at admitted vnodes.

Record the command interval and result, exact root descriptor/path identity,
complete direct/descendant inventories, all present journal leaf names,
metadata and hashes, lease/capture facts, artifact pre/post identities, clone
statuses, cache metadata, supervisor phase/status, and observed fixed-role
prefix. Do not clean any root, capture, lease, journal leaf, or cache.

### Failure, consumption, and no-retry disposition

Any pre-shot mismatch forbids the command and authorizes no repair or
execution. Once the exact SwiftPM command starts, its command budget is
permanently exhausted whether or not SwiftPM, XCTest, method 8, or the
supervisor starts. Once exclusive creation of the successor base succeeds,
source identity `194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`
is permanently consumed regardless of later result.

On any nonpass, signal, timeout, unexpected process/mutation, or missing
postcondition, retain all created caches, roots, captures, lease state, and
journal leaves. Record which layers started, exact status/signal and fixed
phase, root and journal prefix, observed role prefix, stdio hashes, artifact
states, and all available metadata. Classify the scientific result
`INCOMPLETE`; use `ABSTAIN` for causality not proved by the fixed status or
durable prefix. No retry, cleanup, source repair, replacement build, or
production relaunch is authorized for this identity.

The frozen nonzero phase map is: `65` transport; `66` developer directory;
`71` prerequisite admission; `72` prerequisite consume; `73` guarded
pre-executor preparation; `67` supervisor-image bind; `68` fixed probes or
semantic binding; `69` final retained-binding revalidation; `70` untranslated
Core containment fail-stop. Signal or the outer 60-second containment timeout
remains signal/reap evidence, not a narrower phase. No postmortem prose may
narrow a phase beyond the fixed status and durable prefix.

Even fully verified exit `0` authorizes no Gate F execution. A separate clean
Gate E result checkpoint must bind this freeze commit/tree and all retained
evidence before any later Gate F proposal. SwiftPM build, artifact staging,
XCTest inventory, and Swift-Testing inventory remain missing and forbidden.

## Gate E1.2 result — spent and incomplete at prerequisite admission

| Field | Observed value |
| --- | --- |
| Result | `INCOMPLETE_GATE_E_STATUS_71` |
| Scientific cause | `ABSTAIN_WITHIN_ADMIT_PREREQUISITES_BEFORE_SUCCESSFUL_LEASE_LEAF_OPEN` |
| Shot-freeze predecessor | `f77422bb9ba63645a8a061ef1acb1ae2f55a5ec8` / tree `d68b8d1817b9dc2e53a2a5aaf4051a347730363b` |
| Source commit/tree | clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Source identity | consumed `194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f` |
| Pre-invocation observation boundary | `2026-08-23T02:20:41Z`; epoch `1787451641` |
| Exact XCTest interval | `2026-08-23T02:20:58.005Z` through `2026-08-23T02:20:58.906Z`; `0.901` seconds |
| Post-invocation observation boundary | `2026-08-23T02:21:12Z`; epoch `1787451672` |
| SwiftPM command execution elapsed | `3.342625959` seconds |
| Exact frozen SwiftPM commands | `1`; budget permanently exhausted |
| Shell result | exit `1` |
| Selected XCTest | exactly `1` started / `0` passed / `1` unexpected failure |
| Exact method-8 executions | `1` |
| Dedicated supervisor launches | `1` |
| Supervisor termination | normal exit `71`; fixed phase `admit_prerequisites`; no signal or timeout |
| Supervisor stdout/stderr | `0` / `0` bytes |
| Fixed-probe children | `0` |
| Journal leaves | `0`; journal nlink `2` |
| Package-target compiles/relinks | `0` / `0`; transcript contained `[0/1] Planning build` only |
| Other tests or runners | `0`; Swift Testing disabled |
| Gate E closure | `false` |
| Gate F authorization | `false` |
| Retry/relaunch/repair/rebuild/cleanup | permanently `false` |

The exact frozen command was the command embedded in the predecessor freeze,
with no extra or missing inline environment assignment or argument. The
selected test reported this exact error payload at
`PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift:4209`:

```text
invalid("gate_e_release_supervisor_exit_71_phase_admit_prerequisites_base_/private/tmp/prime-driver-v2-gate-e-release-194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f")
```

The observation boundaries enclose the invocation but are not represented as
exact command start and stop times. The XCTest timestamps and measured SwiftPM
execution elapsed are the narrower process observations.

### Retained consumed root

| Item | Observed value |
| --- | --- |
| Base | `/private/tmp/prime-driver-v2-gate-e-release-194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f` |
| Base vnode | device `16777231`; inode `17338584`; UID/GID `501`/`0`; mode `0700`; nlink `8`; flags `0`; size `256`; mtime/ctime `1787451658` |
| Direct inventory | exactly `workspace`, `evidence`, `lease`, `workspace.driver-v2-gate-e-journal`, `outer-supervisor-stdout.bin`, `outer-supervisor-stderr.bin` |
| Workspace | inode `17338585`; mode `0700`; nlink `2`; empty |
| Evidence | inode `17338586`; mode `0700`; nlink `2`; empty |
| Lease | inode `17338587`; mode `0700`; nlink `2`; empty; fixed lease leaf absent |
| Journal | inode `17338588`; mode `0700`; nlink `2`; empty; `0/34` frozen leaves |
| Supervisor stdout capture | inode `17338589`; mode `0600`; nlink `1`; zero bytes; SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| Supervisor stderr capture | inode `17338590`; mode `0600`; nlink `1`; zero bytes; same empty SHA-256 |

The base and all six children are on device `16777231`, have UID/GID
`501`/`0`, flags `0`, mtime/ctime `1787451658`, are ACL-free and
provenance-xattr-only, and remain retained. Exclusive creation of the base
permanently consumed the source identity. No root, child, or capture cleanup is
authorized.

### Retained final-shot caches

| Cache | Retained poststate |
| --- | --- |
| Clang | `/private/tmp/gate-e1-2-final-shot-clang-module-cache-194cf7141172ee06`; device/inode `16777231`/`17338343`; UID/GID `501`/`0`; mode `0700`; nlink `2`; flags `0`; size `64`; mtime/ctime `1787451543`; empty |
| SwiftPM | `/private/tmp/gate-e1-2-final-shot-swiftpm-module-cache-194cf7141172ee06`; device/inode `16777231`/`17338345`; UID/GID `501`/`0`; mode `0700`; nlink `10`; flags `0`; size `320`; mtime/ctime `1787451655`; eight top-level entries |

The SwiftPM cache's exact retained top-level inventory is
`3T5H2677C6X26`, `JFWOF8FH7S6X`,
`PackageDescription-1ZB4AC7ND68BU.swiftmodule`,
`Swift-1IEYM950OGIQC.swiftmodule`,
`SwiftOnoneSupport-1TBU3EV6ADR6U.swiftmodule`,
`_Concurrency-2ADZMZE46FIUY.swiftmodule`,
`_StringProcessing-1FL9YJ9FR6ZV0.swiftmodule`, and `modules.timestamp`.
Both cache leaves are ACL-free and provenance-xattr-only. They remain retained
and are ineligible for cleanup or reuse.

### Conserved harness, artifacts, repositories, and predecessor evidence

| Item | Post-shot observation |
| --- | --- |
| Outer Swift harness | unchanged device/inode `16777231`/`1152921500312571585`; SHA-256 `179301dcb41ea78accc3fa0048a7e6f6710d891945a751a34addd622020c1818`; universal UUIDs `091206DD-5D8E-3B10-A6BE-B9CE23E2C670` / `108866E5-077A-3BE9-8E2C-0DADD00E2F09` |
| Supervisor image | unchanged device/inode `16777231`/`17337418`; SHA-256 `fda8ab7c8f06a94c4f957f879312a6911d7e32015a344ea5b9ad63bbd04215ff`; UUID `6A097D4D-B7F2-32FD-B77C-012BE54EDD0E` |
| XCTest image | unchanged device/inode `16777231`/`17337446`; SHA-256 `b3cf7e6aee0a73b05b493ff279b435f7b81b73c24c24b1731986d0adc0f534d5`; UUID `B65DABC8-28A9-3EE9-ABCC-4DB026D7FC39` |
| Control before this result | clean shot-freeze predecessor commit/tree above |
| Source, production Prime, diagnostic Prime | each clean at `1d341a529c442e63369c361b1e5ac95ca464fdf7` / `e787b3573bd44259606536860dc980720d73d64f` |
| Companion | clean `163fc100710ece48119bc25954452d10f6a84f7f` / `9009daa4f8a07fbd5897e00b9571cef44ec292db` |
| Prior consumed root | unchanged device/inode `16777231`/`17321558`; mtime `1787444179`; nlink `8`; exact six-entry empty inventory retained |
| Eight predecessor cache leaves | all retained with every checkpointed inode, nlink, mtime, and ctime unchanged |
| Manifests and `Package.resolved` | unchanged |
| GitHub/dependency-fetch commands or transcript markers | `0` / `0`; no network marker or effect observed; direct network census not claimed |

### Causal boundary and remaining roadmap state

| Supported boundary | Result |
| --- | --- |
| Canonical request transport | completed before status `71` |
| Private developer-directory derivation | completed before status `71` |
| `admitPrerequisites` | entered and threw before returning a capability |
| Persistent lease-leaf creation | did not complete successfully; fixed lease directory remains empty |
| Admission capability / guarded owner / production image bind | not reached |
| Journal prestart / fixed Git or Swift child | not reached; zero leaves and zero children |
| Exact rejecting guard or errno | `ABSTAIN` |

`PrimeMetalDeviceLease` does not unlink the fixed lease leaf after a successful
`openat(O_CREAT)` return. Its absence therefore bounds the failure to the
admission prefix at or before a successful lease-file open. It does not prove
that the lease parent was never opened or locked, and it does not distinguish
companion declaration validation, held-directory admission, private/empty or
disjointness checks, lease-parent validation/locking, or the lease-file open.
No errno, rejected guard, associated error, or narrower source location crossed
the silent status boundary. The earlier standalone XCTest-seam admission pass
does not resolve this production-invocation-specific rejection.

| Still-missing authority | Gate |
| --- | --- |
| `prime_git_head_and_clean_process_observation` | E |
| `companion_git_head_and_clean_process_observation` | E |
| `swift_version_process_observation` | E |
| `swift_target_info_process_observation` | E |
| `swiftpm_build_execution` | F |
| `artifact_staging` | F |
| `xctest_inventory_execution` | G |
| `swift_testing_inventory_execution` | G |

The durable roadmap ledger still records the same eight authorities as
unclosed. The terminated status-71 process left no live capability, binding,
watch, lease, or authority token; its status, retained root, and captures are
historical evidence only. Gate E is not closed; Gates F and G remain forbidden.
The command budget and source identity are independently spent. This spent
freeze/result authorizes only this clean control checkpoint and read-only
retained-evidence analysis; the consumed identity itself grants no authority.
Any future production work requires separately governed authorization, a new
source identity, and a new freeze; it cannot reuse or reinterpret this shot.

## Gate E1.3 recovery freeze — typed prerequisite-admission rejection site

| Field | Frozen value |
| --- | --- |
| Status | `FROZEN_SOURCE_EDIT_NOT_IMPLEMENTED` |
| Durable-control predecessor | `49686576043fdade64c5e58a090dedf59d51fa0e` / tree `adfec0eb7f4cd01ac0f722518a3b04805a911b59` |
| Source predecessor | clean `1d341a529c442e63369c361b1e5ac95ca464fdf7` / tree `e787b3573bd44259606536860dc980720d73d64f` |
| Consumed predecessor identity | `194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`; permanently no-retry |
| Authorized successor source commits | exactly `1`, a direct child of the source predecessor |
| Authorized source paths | exactly `4` |
| New child/process/role/command surface | `0` / `0` / `0` / `0` |
| Production supervisor or method-8 invocation | `0` in this source-edit slice |
| Gate F/G authorization | `false` / `false` |

The four-path mutation allowlist is:

1. `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift` —
   one closed payload-free rejection-site observation seam around the existing
   top-level prerequisite-admission operations in the existing sole public
   admission entry; no new observation-specific overload, flag, callback, or
   second entry;
2. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2Supervisor/main.swift` —
   one private exhaustive rejection-site-to-status projection in the existing
   prerequisite-admission catch; generic status `71` remains fail-closed;
3. `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` —
   focused mechanics and structural assertions inside the nine exact existing
   methods frozen below; no new or renamed test identifier or inventory entry;
   and
4. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` — canonical source
   identity reseal only after the first three paths are final.

The new PrimeCore observation is an `@frozen`, ordinary public, non-raw,
non-Codable `Error & Equatable & Sendable` enum with no associated value and no
public initializer beyond its closed cases. The existing public
`admitPrerequisites` remains the sole production admission entry and always
replaces an underlying failure at one of the listed top-level operations with
that operation's site. The existing internal synthetic-source seam follows the
same site projection. No observation-enabled flag, new observation-specific
overload, callback, SPI admission entry, or new capability-returning path is
permitted. The
pre-existing internal `sourceExpectation` overload remains the sole synthetic
test seam and gains no caller-selectable observation policy. The site value is
failure evidence only: it contains no descriptor, lease, watch, capability,
path, errno, string, UID, mode, or retry authority.

| Status | Rejection site entered |
| ---: | --- |
| `74` | companion declaration validation |
| `75` | Prime repository hold |
| `76` | workspace-root hold |
| `77` | workspace private-and-empty check |
| `78` | evidence-root hold |
| `79` | evidence private-and-empty check |
| `80` | companion repository hold |
| `81` | lease-directory hold |
| `82` | lease private-and-empty check |
| `83` | root disjointness and non-nesting check |
| `84` | exclusive lease acquisition |
| `85` | post-lease directory rebind |
| `86` | Prime source snapshot capture |
| `87` | `Package.resolved` binding |
| `88` | Prime held source-identity snapshot |
| `89` | companion held-content snapshot |
| `90` | held toolchain admission |

Status `71` remains `admit_prerequisites_unclassified`. Statuses `74...90`
mean only that every preceding top-level operation returned and the named
operation entered and threw. They do not expose or prove the underlying guard,
associated value, errno, or source line. In particular, status `84` plus an
absent never-unlinked lease leaf means failure at or before successful lease
file creation only when the separately frozen pre-shot absence and
no-other-mutator/root-conservation evidence also hold; it does not identify a
lease subguard. Statuses `85...90` prove that lease acquisition returned and
the fixed name existed then. Post-observation retention additionally requires
the separately recorded no-other-mutator evidence.

The supervisor must remain silent and keep the Gate A stdin frame, argc-one
rule, canonical request schema, 256-KiB cap, five-second EOF deadline,
developer-directory derivation, zero-argument facade transition, role order,
deadlines, environment tables, roots, journal, image bind, final revalidation,
and every process policy unchanged. It may not inspect raw error text,
associated values, errno, paths, `NSError`, `localizedDescription`, stdout,
stderr, a request field, environment variable, callback, file descriptor, or
child state. It must retain eight lexical catches and nine `_exit` calls; the
existing admission catch performs the only typed site projection and otherwise
exits `71`.

Only these nine existing XCTest identifiers may change inside the sole test
path; the frozen inventory remains exactly `892` XCTest / `12` Swift Testing:

1. `testAdmissionRequiresEveryGateCPrimeCoreSource`;
2. `testCanonicalAliasAndAncestorOverlapAreRejected`;
3. `testCompanionCaptureRejectsSymlinkFIFORootGitFile`;
4. `testCompanionTopologyLimitsAreFrozenAndRejectDepthAndFileBytes`;
5. `testCallerDeclaredGitMismatchIsRejectedBeforeAdmission`;
6. `testConsumedPrerequisiteRetainsExclusiveLease`;
7. `testGateEXCTestHostCannotConstructProductionFixedProbeBinding`;
8. `testCapabilitySurfaceHasNoCodecPublicInitializerOrSpawn`; and
9. `testPublicReleaseAdmissionUsesEmbeddedSourceAuthority`.

Focused mechanics may use the internal synthetic-source seam to prove that
representative real failures become their entered site while an observed
success returns the same one-shot descriptor/lease-retaining capability and
exposes no process authority. Static assertions must bind all 17 unique
statuses, their order, generic `71`, silence, frame conservation, and absence
of codec, arbitrary input, spawn, process, or retry surfaces. The Release-only
method must require an absolute `PRIME_DRIVER_V2_GATE_E_PRIME_ROOT`, fail if it
is missing, and use that exact future production-clone root instead of deriving
Prime from `#filePath`; `PRIME_PMHNP_COMPANION_ROOT` remains the exact companion
input. These are test-harness inputs only and do not enter the dedicated
supervisor environment. XCTest remains production-ineligible and cannot close
`supervisor_executable_image` or any Gate E authority.

This source-edit freeze authorizes only the four allowlisted edits, two
independent read-only calculations of the complete canonical source identity,
the exact canonical provenance reseal, and one clean source commit. Source
cardinality must remain `545` admitted files / `544` identity records and the
watch baseline remains `2,157`; any count change is a hard stop. No Swift
build, test, production supervisor, method 8, Git/Swift fixed probe, network,
GitHub, dependency fetch, root/cache cleanup, or consumed-evidence mutation is
authorized by this slice.

After the clean source commit exists, a separate clean control checkpoint must
bind its exact commit/tree, four-path diff, predecessor exclusion, identity,
cardinality, and canonical-template equality before any build or test. A later
readiness freeze must separately bind fresh cache leaves, exact focused
selectors, the production clone, Release images, absent identity-bound root,
and one-shot accounting before a replacement Gate E invocation can be
authorized. Gate F build/staging and Gate G inventory remain missing and
forbidden even if that later Gate E invocation succeeds.

## Gate E1.3 source-edit checkpoint — typed admission rejection sites

| Field | Recorded value |
| --- | --- |
| Status | `SOURCE_COMMITTED_NO_BUILD_OR_TEST` |
| Durable-control predecessor | `a0082053e33d8a908738e1a00f2cfa8d648f646f` / tree `ba8deecc8792e86faabf1df9cb9e25427f2c0f12` |
| Source predecessor | `1d341a529c442e63369c361b1e5ac95ca464fdf7` / tree `e787b3573bd44259606536860dc980720d73d64f` |
| Source commit | `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` |
| Source tree | `0077ac10f1dbba50680502a31084f7280c2c2f65` |
| Parent edge | exactly one direct parent: `1d341a529c442e63369c361b1e5ac95ca464fdf7` |
| Control-prose ancestry exclusion | `a0082053e33d8a908738e1a00f2cfa8d648f646f` is not an ancestor of the source commit (`git merge-base --is-ancestor` exit `1`) |
| Changed-path set | exactly `4`, all tracked modifications; no add, delete, rename, or mode change |
| Changed XCTest methods | exactly the frozen `9`; no new or renamed identifier |
| Source worktree after commit | clean |
| New canonical source identity | `474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52` |
| Consumed predecessor identity | `194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`; not reused and permanently no-retry |
| Canonical cardinality | `545` admitted files / `544` identity records / `111,620` canonical JSON bytes |
| Watch arithmetic | `545` Prime files + `152` authority directories = `697`; companion `1,460`; combined `2,157 / 4,096` |
| Embedded canonical template | exact equality; `546` bytes; SHA-256 `4e2b4b81ea8d7ffade440ddcdcd6d1462e7c163380f49facdecea901b2a159d7` |
| Static conservation | `17` payload-free sites; statuses `74...90`; `8` lexical catches; `9` `_exit` calls; `git diff --check` clean |
| Swift build / test / production supervisor / method 8 | `0 / 0 / 0 / 0` |
| Network / GitHub / dependency fetch | `0 / 0 / 0` |
| Gate F / Gate G authorization | `false / false` |

The exact four committed path identities are:

| Path | Git blob | Byte count | Raw SHA-256 |
| --- | --- | ---: | --- |
| `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` | `8cba2df196ce65f7c83cf2aa4444faf01b8b336b` | `546` | `4e2b4b81ea8d7ffade440ddcdcd6d1462e7c163380f49facdecea901b2a159d7` |
| `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift` | `dc37b1f041031fa2994b4156630085940e3a512a` | `97,844` | `ab6ebf4bc7629ca901b6bbe5643a556b82995d302b269464c94ffad65b128fb2` |
| `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2Supervisor/main.swift` | `c5c3e09d936e7fcb34b9939242c4dba090a271d6` | `14,458` | `a6ee17b234abcd789d839abadd5f5a551ecabe99d731186c566422f46e6276d2` |
| `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` | `686a199b270666b01106ce1c941b249a041705a3` | `212,136` | `41f5c3ec45489a856d800ec9737ef4af440559fcf10b474fac599c254c38c59f` |

The identity instruments were independently checked before they were trusted.
A Ruby `Find` + ordered JSON implementation and a Perl `File::Find` +
canonical `JSON::PP` implementation each measured the archived predecessor as
`545 / 544 / 111,620` and reproduced its embedded identity
`194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`.
The same two implementations independently measured the successor, both
before and after the excluded provenance-file reseal, as
`545 / 544 / 111,620` with identity
`474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52`.
The predecessor measurement copy remains at
`/private/tmp/prime-gate-e-identity-base.QnZgnL`; neither source worktree nor
any consumed evidence root was mutated by either calculation.

Three independent static Sol audits accepted the final four-path candidate.
Those audits are rank-4 source review, not execution evidence. This checkpoint
records only the new source identity and its closed typed observation seam. It
does not authorize a Swift build, selected test, production supervisor,
method-8 invocation, fixed probe, retry, or cleanup. The only next admissible
work is a separate control-only readiness freeze binding new identity-scoped
cache leaves, exact selectors, production-clone and companion roots, Release
image replacement and predecessor-identity exclusion, an absent fresh
identity-bound shot root, and one-shot accounting. Until that freeze is cleanly
committed, every Swift or production invocation remains forbidden.

## Gate E1.3 readiness freeze — finite Release proof set

| Field | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | `b13ecb9fac9701da5e415501717ea1076f6b2b79` / tree `b99155cbfdffb1612a73d7bc1679b3addf5d60af` |
| Permitted control delta | this freeze only, in this one durable-control path |
| Source commit/tree | clean `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` / `0077ac10f1dbba50680502a31084f7280c2c2f65` |
| Source identity/cardinality | unconsumed `474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52`; `545` files / `544` records / `111,620` canonical bytes |
| Authorized local clone commands | exactly `1` |
| Authorized namespace preparation | exactly `7` ordered exclusive `mkdir` operations under one absent identity-bound epoch root |
| Authorized cache creations | exactly `2` absent leaves inside that epoch root, one exclusive creation each |
| Authorized SwiftPM readiness commands | at most `2`, ordered; success requires exactly `2` |
| Selected XCTest methods | exact finite set `15`; Release; one runner |
| Production method 8 / supervisor / fixed children | `0 / 0 / 0` |
| Source edits / dependency resolution or fetch / network / GitHub | `0 / 0 / 0 / 0` |
| Gate F / Gate G authorization | `false / false` |

Data precedence is explicit: the finite sets, hashes, vnode tuples,
cardinalities, command/environment maps, and equality predicates below are the
authority. Prose may explain them but cannot relax, replace, or reinterpret a
mismatch; any data/prose contradiction is a hard stop.

This freeze explicitly supersedes only the E1.2 readiness instrumentation
rules that required Debug configuration, two Debug compile-only commands, and
one SwiftPM process per focused method. Those were rank-4 attribution policy,
not a live authority invariant. It conserves every prior Gate E regression
method and every E1.3 changed method, moves their proof to the production
configuration, and leaves production method 8 separately isolated. No source,
role, capability, process policy, or roadmap authority is amended.

Define the exact accepted method-name set as
`Sigma = Sigma_E1.2 union Sigma_E1.3`, where `|Sigma_E1.2| = 7`,
`|Sigma_E1.3| = 9`, their sole overlap is
`testGateEXCTestHostCannotConstructProductionFixedProbeBinding`, and therefore
`|Sigma| = 7 + 9 - 1 = 15`. The authoritative acceptance predicate is:

`multiset(observed XCTest method names) = Sigma`, exactly `15` executions,
exactly `15` passes, zero skips, zero failures, one XCTest runner, zero Swift
Testing runners, and zero production-product launches. A filter match claim or
suite summary without the exact observed-name equality is insufficient.

| Ordinal | Exact canonical XCTest identifier |
| ---: | --- |
| 1 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationDriverV2AdmissionTests/testGateEPrimeScopeAndFixedPolicyAreExact` |
| 2 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationDriverV2AdmissionTests/testGateERawParsersAndPartialBindingsAreClosed` |
| 3 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationDriverV2AdmissionTests/testGateERejectsEveryRawProcessAndRepositoryMutation` |
| 4 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEJournalChainOneWinnerAndPoisonAreExact` |
| 5 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEHeldProjectionRejectsSetSymlinkGitlinkAndVnodeDrift` |
| 6 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateELightweightContinuityPoisonsOnEitherRootMutation` |
| 7 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEXCTestHostCannotConstructProductionFixedProbeBinding` |
| 8 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testAdmissionRequiresEveryGateCPrimeCoreSource` |
| 9 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testCanonicalAliasAndAncestorOverlapAreRejected` |
| 10 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testCompanionCaptureRejectsSymlinkFIFORootGitFile` |
| 11 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testCompanionTopologyLimitsAreFrozenAndRejectDepthAndFileBytes` |
| 12 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testCallerDeclaredGitMismatchIsRejectedBeforeAdmission` |
| 13 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testConsumedPrerequisiteRetainsExclusiveLease` |
| 14 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testCapabilitySurfaceHasNoCodecPublicInitializerOrSpawn` |
| 15 | `PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testPublicReleaseAdmissionUsesEmbeddedSourceAuthority` |

All 14 configuration-independent bodies have no Debug-only branch. The one
configuration-gated member is the public-admission proof, whose live branch is
Release. The production method
`testGateEReleaseSupervisorRequiresLiveFourAuthorityBindingBeforeExit` is not
in `Sigma` and must not be selected, entered, or launched during readiness.

### Frozen preparation roots and cache epoch

| Item | Frozen value |
| --- | --- |
| Readiness epoch root | `/private/tmp/gate-e1-3-readiness-474008bdffccf410`; absent by no-follow `lstat` before this freeze |
| Fresh production Prime clone | `/private/tmp/gate-e1-3-readiness-474008bdffccf410/prime`; absent because the epoch root is absent |
| Clone source | exact clean source worktree above; local file transport only |
| Pinned companion input | `/private/tmp/gate-e-companion-measure.pMGSXT/companion`; device/inode `16777231` / `17279918`; clean `163fc100710ece48119bc25954452d10f6a84f7f` / tree `9009daa4f8a07fbd5897e00b9571cef44ec292db` |
| Isolated home | `/private/tmp/gate-e1-3-readiness-474008bdffccf410/home`; absent with the epoch root |
| Isolated temporary root | `/private/tmp/gate-e1-3-readiness-474008bdffccf410/tmp`; absent with the epoch root |
| Empty Git template/hooks root | `/private/tmp/gate-e1-3-readiness-474008bdffccf410/git-template`; absent with the epoch root |
| Readiness Clang cache | `/private/tmp/gate-e1-3-readiness-474008bdffccf410/clang-module-cache`; absent with the epoch root |
| Readiness SwiftPM cache | `/private/tmp/gate-e1-3-readiness-474008bdffccf410/swiftpm-module-cache`; absent with the epoch root |
| Reserved production root | `/private/tmp/prime-driver-v2-gate-e-release-474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52`; absent and forbidden throughout readiness |
| Reserved shot Clang cache | `/private/tmp/gate-e1-3-final-shot-clang-module-cache-474008bdffccf410`; absent and forbidden throughout readiness |
| Reserved shot SwiftPM cache | `/private/tmp/gate-e1-3-final-shot-swiftpm-module-cache-474008bdffccf410`; absent and forbidden throughout readiness |

The clone source is a linked worktree and is admitted as such, not as a path
string. Its canonical root is directory vnode `16777231/17154421`; its `.git`
is regular vnode `16777231/17154423`, `146` bytes, SHA-256
`2bf2c672f62ce5b46ed4a2befa9c421caf871e9c8ca77277ab37b6a936f9386d`.
That file names exact worktree Git directory
`/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.stage6-retirement-staging/.git/worktrees/-driver-v2-gate-c-staging`,
directory vnode `16777231/17154419`. Its `gitdir` backlink is regular vnode
`16777231/17154422`, `101` bytes, SHA-256
`69d2a94ba3ca0dd77f540c9c80ebc2f8234ec2dbb3a11232fb3e16b92c6ae721`.
Its `HEAD` is a `56`-byte regular file with SHA-256
`a86308744aebc9d6f2ab7bf2521be7e6995040de2642875656f8aaac489ee58d`;
its six-byte `commondir` has SHA-256
`340ddcb67a6204f742cd1e28e5b462622dde7daaa8ee36001897196aacdc6d47`.
Its current index is regular vnode `16777231/17347639`, `115,271` bytes,
SHA-256
`ffe5131d4789668336944aa1c99b99f523377e28a6aff3e6fd8664a97eb2c3b7`;
that dynamic index fact is re-recorded after the freeze commit. The resolved
common Git root is directory vnode `16777231/15175114`. The common config is
regular vnode `16777231/17066134`, `4,154` bytes,
SHA-256
`123369fa4a5cf94653a1da3d298c97113f4aa8d9b601202843f35c89b2afd109`;
the selected branch-ref file is regular vnode `16777231/17347671`, `41`
bytes, SHA-256
`0559d479da9baefaf50900dd9c2b9047bb796756cc30b46cf8cca5a14305d65d`
and contains exactly source commit
`2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3`. The common object root is
directory vnode `16777231/15175142`. Common `packed-refs` is a `46`-byte
regular file with SHA-256
`6110899c7adc374885f9552bddfb76a28a7f7ca3c05fb8b74471a457e1e57c8`.
Repository/object/ref formats are exact SHA-1/files. Source alternates, HTTP alternates,
shallow state, promisor state, replacement/graft state, worktree config,
config-include closure, tracked `.gitattributes`, and `.gitmodules` are all
absent. Before clone, run strict no-lazy-fetch reachable-object validation for
the selected commit and require source/ref/config/index/object-root quiescence
through clone completion. The common config's
GitHub remote is not destination authority and must not be copied as a second
destination remote. Because committing this self-excluding freeze appends
objects to the common store, re-record all source Git-path joins and the object
root metadata after that commit; those post-commit observations enter
`B_before`.

After this freeze is committed, run these seven `mkdir` commands in exact
order. Each target must be absent by a no-follow parent-relative lookup, each
`mkdir` must be the sole successful creator of its leaf, and any nonzero result
is a permanent readiness stop. Retain every created directory.

```sh
/bin/mkdir -m 0700 /private/tmp/gate-e1-3-readiness-474008bdffccf410
/bin/mkdir -m 0700 /private/tmp/gate-e1-3-readiness-474008bdffccf410/home
/bin/mkdir -m 0700 /private/tmp/gate-e1-3-readiness-474008bdffccf410/tmp
/bin/mkdir -m 0700 /private/tmp/gate-e1-3-readiness-474008bdffccf410/git-template
/bin/mkdir -m 0700 /private/tmp/gate-e1-3-readiness-474008bdffccf410/clang-module-cache
/bin/mkdir -m 0700 /private/tmp/gate-e1-3-readiness-474008bdffccf410/swiftpm-module-cache
/bin/mkdir -m 0700 /private/tmp/gate-e1-3-readiness-474008bdffccf410/prime
```

Immediately after the first `mkdir`, require the epoch parent to be a held,
canonical, non-symlinked directory on local APFS device `16777231`, owned
`501/0`, mode `0700`, nlink `2`, flags `0`, empty, ACL-free, and with exact
xattr set `{com.apple.provenance}`. Open it
`O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC`. Create and rejoin each child relative to
that parent; each child must initially be nlink `2` and empty. After all six
children exist, require parent nlink `8` and exact direct inventory
`{clang-module-cache, git-template, home, prime, swiftpm-module-cache, tmp}`.
Hold the parent and `prime` directory descriptors and rejoin their
path/device/inode tuples before and after every absolute-path creation and the
clone. No concurrent same-UID namespace mutation is permitted from the first
parent creation through post-clone admission. The parent and all child
directory device/inode values are recorded after creation and rejoined before
every later operation. The pre-created `prime` directory is the exclusive
destination primitive: Git may populate that exact held empty vnode, not
choose or create a destination name. The outer clone launcher has umask `077`,
stdin `/dev/null`, and exact cwd
`/private/tmp/gate-e1-3-readiness-474008bdffccf410`.

Create the production clone exactly once with the following completely
scrubbed environment and the admitted Xcode Git image. The empty template path
is both the clone template and the only hooks path; the only admitted transport
protocol is `file`.

```sh
umask 077
/usr/bin/env -i \
  HOME=/private/tmp/gate-e1-3-readiness-474008bdffccf410/home \
  CFFIXED_USER_HOME=/private/tmp/gate-e1-3-readiness-474008bdffccf410/home \
  XDG_CONFIG_HOME=/private/tmp/gate-e1-3-readiness-474008bdffccf410/home \
  TMPDIR=/private/tmp/gate-e1-3-readiness-474008bdffccf410/tmp/ \
  USER=ergentics LOGNAME=ergentics LANG=C.UTF-8 LC_ALL=C.UTF-8 \
  TZ=UTC TERM=dumb NO_COLOR=1 \
  PATH=/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:/usr/bin:/bin \
  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
  GIT_EXEC_PATH=/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core \
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_ATTR_NOSYSTEM=1 \
  GIT_CONFIG_COUNT=6 \
  GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/private/tmp/gate-e1-3-readiness-474008bdffccf410/git-template \
  GIT_CONFIG_KEY_1=init.templateDir GIT_CONFIG_VALUE_1=/private/tmp/gate-e1-3-readiness-474008bdffccf410/git-template \
  GIT_CONFIG_KEY_2=core.attributesFile GIT_CONFIG_VALUE_2=/dev/null \
  GIT_CONFIG_KEY_3=checkout.workers GIT_CONFIG_VALUE_3=1 \
  GIT_CONFIG_KEY_4=maintenance.auto GIT_CONFIG_VALUE_4=false \
  GIT_CONFIG_KEY_5=gc.auto GIT_CONFIG_VALUE_5=0 \
  GIT_ALLOW_PROTOCOL=file GIT_PROTOCOL_FROM_USER=0 GIT_OPTIONAL_LOCKS=0 \
  GIT_TERMINAL_PROMPT=0 GIT_LFS_SKIP_SMUDGE=1 \
  GIT_NO_LAZY_FETCH=1 GIT_NO_REPLACE_OBJECTS=1 \
  /Applications/Xcode.app/Contents/Developer/usr/bin/git clone \
  --local --no-hardlinks --no-tags --single-branch \
  --branch=agent/prime-validation-driver-v2-gate-c --origin=origin \
  --template=/private/tmp/gate-e1-3-readiness-474008bdffccf410/git-template \
  --no-recurse-submodules --reject-shallow --ref-format=files --no-progress \
  -- \
  /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging \
  /private/tmp/gate-e1-3-readiness-474008bdffccf410/prime </dev/null
```

Any clone failure, a different commit/tree, a non-directory `.git`, an object
alternate, a symlinked path component, dirty porcelain-v2 state,
source-identity mismatch, template/hook mutation, or network/fetch marker is a
permanent readiness hard stop. After clone completion, record and bind the
canonical clone root and real `.git` directory path/device/inode,
UID/GID/mode/nlink/flags, ACL, and xattr tuples. The accepted clone is retained
and must measure the exact `545 / 544 / 111,620` identity above. Clone
configuration must expose exactly one remote named `origin`, whose URL is the
exact canonical local source-worktree path and whose only fetch refspec is the
selected branch; no GitHub URL, extra remote, alternate, HTTP alternate,
shallow/promisor state, replace ref, graft, submodule, hook, or nonempty
template entry may exist. The clone's branch/HEAD/commit/tree, clean
porcelain-v2 status, source identity, `.git` vnode, config bytes, selected ref,
index, and object-root vnode are recorded after clone and then immutable.
Clone
preparation is outer workstation mechanics and closes no Gate E Git authority.
Every prior Prime clone remains retained, unchanged, and ineligible as an
E1.3 command input.

The empty home, temporary, template, and cache leaves are already exclusively
created by the ordered namespace preparation. Rejoin each no-follow path to
its recorded directory device/inode before, between, and after the two SwiftPM
commands. This single fresh cache pair is authorized only as the shared
non-authority cache epoch for the exact ordered sequence. Retain the entire
epoch after the sequence and never reuse any child for a later readiness
command or production shot.

### Frozen manifests and dependency-store admission

The four source manifest/lock inputs are exact regular, one-link, mode `0644`,
flags-`0`, ACL-free, provenance-xattr-only vnodes on device `16777231`, owned
`501/20`:

| Path | inode / bytes | Git blob / SHA-256 |
| --- | --- | --- |
| `Package.swift` | `17154460` / `32,843` | `8e14c10aded588b3902a042341bca7acc842bcc6` / `fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81` |
| `Package.resolved` | `17154459` / `645` | `14d804bb4291720477240c27e24de6fbdc876b3b` / `bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375` |
| `Tests/PrimeValidationWorkflow/Package.swift` | `17155065` / `3,668` | `b8c29f2530efa863b99f0ddc7b32a363e7b525ed` / `8dc77c80ee6a13d5ce184d1c7886701b3d317c07abda0f7ab38d21ef7eef8d35` |
| `Tests/PrimeValidationWorkflow/Package.resolved` | `17155064` / `645` | `69919288b1a5da256ff408a4d65106b23abc8f89` / `d70a43567cbd3be75083ab147020b86b055513020d95632f8286f60913c9374a` |

The nested `Package.resolved` origin hash is
`99354cfc3da2d75ac960d1c704257656eec563bc17344d694678626ae9c1f518`.
It selects only MLX revision `d37885a278f1c37484a94d0f401a418735e66519`
and swift-numerics revision
`0c0290ff6b24942dadb83a929ffaaa1481df04a2`. Automatic resolution is
disabled; any manifest/lock drift or resolution/fetch attempt stops the epoch.
The existing `.build/workspace-state.json` is a separate immutable input:
regular vnode `16777231/17182550`, owned `501/20`, mode `0644`, one link,
flags `0`, `1,704` bytes, mtime/ctime `1787423069/1787423069`, SHA-256
`8eeb391d590b20e5eec603ab9d078757f2106a29467a7ff079194278bba921bf`.
It names exactly the source worktree and the two revisions above. It is
excluded from the mutable `.build` partition and must remain byte- and
vnode-identical.

The existing nested dependency store is input authority, not an undifferenced
`.build` output. Its exact admitted roots are:

| Kind / path | Frozen identity |
| --- | --- |
| MLX checkout `.build/checkouts/ergentics-mlx-swift` | root `16777231/17179559`, real `.git` `16777231/17179560`; clean commit/tree `d37885a278f1c37484a94d0f401a418735e66519` / `5310749549cca107fc1bb07d82dacf043bc02b9e`; alternate-file SHA-256 `bf4e1b8a9f7ed6d872e06349fcdc0900733d12cb72d8e6c246a68e640530b78c` |
| numerics checkout `.build/checkouts/swift-numerics` | root `16777231/17182551`, real `.git` `16777231/17182552`; clean commit/tree `0c0290ff6b24942dadb83a929ffaaa1481df04a2` / `4560bfb65f2c26cbd159c3e1a9cbf01600bace1b`; alternate-file SHA-256 `53a3fd5c98ba9221ccfa6c7a44534b7161cfb8e2f62f1d080157cffec898a2c7` |
| MLX object store `.build/repositories/ergentics-mlx-swift-4670e397` | root `16777231/17179430`; no alternate; full strict fsck passes; contains the admitted MLX commit/tree |
| numerics object store `.build/repositories/swift-numerics-d936ec6c` | root `16777231/17179521`; no alternate; full strict fsck passes; contains the admitted numerics commit/tree |

All six checkout/object-store roots are directories owned `501/20`, mode
`0755`, flags `0`, ACL-free, and provenance-xattr-only. In addition to the Git
identities, bind these whole-tree continuity commitments before command 1 and
require exact equality between and after the commands:

| Root | entry count / continuity SHA-256 |
| --- | --- |
| MLX checkout | `2,089` / `7f9d0bcaa4f6f949cc32682bbaf0dc49f0451334ec9aeef5674bda3fa92aa433` |
| numerics checkout | `129` / `54bb366aea88fef2a17dc9925277b25f8c3b38c896ccd2a0ed7a87a3c478fda3` |
| MLX object store | `88` / `cd21b849d5ae60048adfe423148b54b6ae0349f4f60ea72f54a2d7b45649b63d` |
| numerics object store | `38` / `0db4dd07e6d79e3c8a22837e42fd560346f52ff4a6bd1742f6b7d4f50adb1108` |

The commitment is SHA-256 over every root and descendant sorted by raw
relative-path bytes. Each entry frame is an unsigned 64-bit big-endian path
length, raw path, one kind byte, eleven unsigned 64-bit big-endian values
`(device, inode, uid, gid, mode, nlink, size, mtime seconds, mtime
nanoseconds, ctime seconds, ctime nanoseconds)`, then 32 bytes: SHA-256 of
regular-file bytes, SHA-256 of the symlink target, or zeroes for a directory.
The root path is `.` and is included. Thus same bytes on a replacement vnode do
not satisfy continuity. `GIT_OPTIONAL_LOCKS=0` is mandatory for every outer
status observation so observation cannot refresh an index.

The readiness base-continuity tuple is:

`B = (committed control commit/tree, control/source root and Git-link vnodes,
source commit/tree/identity, four manifest/lock vnode+blob+byte identities,
workspace-state vnode+bytes,
admitted Git/Swift/toolchain/SDK images, epoch and child root vnodes,
production-clone root+.git security tuples and commit/tree/identity, companion
root+.git security tuples and commit/tree, four dependency-store commitments,
reserved-path absences)`.

Record the self-excluding control commit/tree after this freeze is committed,
then require `B_before = B_between = B_after`. The only admitted mutation
regions are: each cache subtree including root metadata and descendants; the
isolated home and temporary subtrees including root metadata and descendants;
the existing nested `.build` output partition excluding the four immutable
checkout/object-store roots above; and, during command 2 only, exact canonical
UUID leaves under `/private/tmp/prime-validation-public-admission-` and
`/private/tmp/prime-validation-admission-tests-`. Require the two prefix
inventories before command 2 to equal their post-command inventories exactly,
with no newly retained canonical-UUID root. The existing unrelated
`/private/tmp/prime-validation-admission-tests-20260803-c` vnode
`16777231/11306865` is conserved. The epoch parent and all child root
path/device/inode joins remain stable; the Git template stays empty. Cache,
home, temporary, and `.build` mutations are outputs, not scientific authority.
The production clone is immutable after clone admission. The reserved
production root and two reserved shot-cache paths are rechecked absent before
command 1, between commands, and after command 2.

No observer may inspect clone, image, dependency, or root state concurrently
with a live SwiftPM/XCTest hierarchy; perform joins only before, between, and
after complete process termination.

Mutable build artifacts are deliberately outside equality-conserved `B` and
follow a separate ordered transition relation. `A0` is the exact stale
supervisor, XCTest, and four object preimages frozen below. Command 1 must
produce `A1`: all three command-1 objects and the Release supervisor are
replaced inside that command's measured interval, while the live-test object
and XCTest image remain `A0` unless the transcript proves an otherwise
authorized test build (which command 1 does not request). Command 2 must
produce `A2`: the live-test object and XCTest image are replaced inside its
interval; every command-1 artifact either retains its admitted `A1` identity
or has a later compile/relink explicitly named by the complete command-2
transcript and is re-admitted. Formally, acceptance requires exactly
`A0 --command1--> A1 --command2--> A2`; artifact equality across these states
is a failure, not continuity. No artifact transition outside its owning live
command interval is authorized.

### Frozen tool and stale-artifact preimages

| Item | Frozen preimage |
| --- | --- |
| Environment scrubber `/usr/bin/env` | device/inode `16777231/1152921500312571972`; UID/GID `0/0`; mode `0755`; nlink `1`; flags `524320`; size `102,368`; UUIDs `50197F43-49AC-365C-B80F-BB43B6ACC0E1` / `06C17BB1-EC06-36E0-B820-C066F5791770`; SHA-256 `6e506aec3c0cff703ac1e66cedc6f1945354ad41339a38db4425c7c88227128f` |
| Exclusive creator `/bin/mkdir` | device/inode `16777231/1152921500312571416`; UID/GID `0/0`; mode `0755`; nlink `1`; flags `524320`; size `101,472`; UUIDs `CC05F45B-1B8B-36A2-9FE4-E6A862E056F0` / `D38EAF6F-D883-343D-BAD9-5FA846104514`; SHA-256 `08a20adeeff9bea14bae05c0a7f3c77c638b2b83fc3ab37e1c646e047bac7002` |
| Name-bound developer-tool dispatcher | `/usr/bin/git` and `/usr/bin/swift` are hard links to device/inode `16777231/1152921500312571585`; UID/GID `0/0`; mode `0755`; nlink `78`; flags `524320`; size `118,928`; UUIDs `091206DD-5D8E-3B10-A6BE-B9CE23E2C670` / `108866E5-077A-3BE9-8E2C-0DADD00E2F09`; SHA-256 `179301dcb41ea78accc3fa0048a7e6f6710d891945a751a34addd622020c1818`. Exact commands use direct Xcode paths; any explicit fallback through the dispatcher is admitted only with the frozen `DEVELOPER_DIR` and must resolve to the same images below. |
| Admitted Xcode Git | `/Applications/Xcode.app/Contents/Developer/usr/bin/git`; device/inode `16777231/928699`; UID/GID `0/0`; mode `0755`; nlink `1`; flags `32`; size `3,704,880`; mtime/ctime `1781596690/1784881438`; arm64 UUID `E3C74406-2163-3D84-B409-1D2A20A35F27`; SHA-256 `10f9c1df894525ae4c7454258febab6d3d25071062b42cb48dbb1842cdffd2a9` |
| Admitted Git helper root | `/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core`; directory vnode `16777231/928717`, owned `0/0`, mode `0755`, nlink `174`, flags `0`; `197` entries; continuity SHA-256 `2492a25a6d248e78c3d7716c96a55e1248628fda2c405368f9bfcfbf164ee31d` under the same raw framed algorithm used for dependency roots |
| Admitted Xcode Swift launcher | `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift`; symlink vnode `16777231/1118417`, UID/GID `0/0`, mode `0755`, flags `0`, exact target `swift-frontend`; target is the next row |
| Xcode `swift-frontend` | `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend`; device/inode `16777231/1118375`; UID/GID `0/0`; mode `0755`; nlink `1`; flags `32`; size `171,036,592`; arm64 UUID `9A364091-58FE-3AAD-A4D9-9454EF63DDBF`; SHA-256 `2ed38571e92c0283091838c1649e27650ad9c99950288e883c7b2dc6c4ce89fb` |
| Developer/SDK roots | canonical Developer directory `16777231/928517`; `SDKROOT` is canonical directory `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk`, vnode `16777231/1009705`; the versioned `MacOSX26.5.sdk` link is not an input |
| Stale Release supervisor | absolute path `/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowDriverV2Supervisor`; regular arm64 executable; device/inode `16777231/17337418`; UID/GID `501/20`; mode `0755`; nlink `1`; flags `0`; size `47,675,784`; mtime/ctime `1787449777/1787449777`; UUID `6A097D4D-B7F2-32FD-B77C-012BE54EDD0E`; SHA-256 `fda8ab7c8f06a94c4f957f879312a6911d7e32015a344ea5b9ad63bbd04215ff` |
| Stale Release XCTest | absolute path `/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowPackageTests.xctest/Contents/MacOS/PrimeValidationWorkflowPackageTests`; regular arm64 Mach-O bundle; device/inode `16777231/17337446`; UID/GID `501/20`; mode `0755`; nlink `1`; flags `0`; size `56,490,080`; mtime/ctime `1787449784/1787449784`; UUID `B65DABC8-28A9-3EE9-ABCC-4DB026D7FC39`; SHA-256 `b3cf7e6aee0a73b05b493ff279b435f7b81b73c24c24b1731986d0adc0f534d5` |
| Stale image membership | each stale image contains consumed identity `194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f` exactly once and new identity `474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52` zero times |

All admitted tools and final-image/object preimages are ACL-free and have no
xattr other than `com.apple.provenance`. Every listed path is joined component
by component without following an unexpected symlink; the one allowed final
symlink is the frozen Xcode `swift -> swift-frontend` edge. Because `/usr/bin`
is later in the exact `PATH`, the developer-tool shim is not the Git or Swift
image selected by these commands. `env -i` makes all `DYLD_*`, `LD_*`, proxy,
credential-agent, SSH-agent, toolchain-override, and ambient user-configuration
variables absent.

Both stale final images and these four unambiguous absolute Release objects
must be replaced by data, not inferred from a successful command:

| Command owner | Absolute object path | Frozen preimage |
| --- | --- | --- |
| command 1 | `/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeCore.build/PrimeEmbeddedBuildProvenance.swift.o` | device/inode `16777231/17334921`; `501/20`; mode `0644`; nlink `1`; flags `0`; `12,816` bytes; mtime/ctime `1787447795/1787447795`; SHA-256 `886c9db18bf95f4c3a3d09531c725c5cfaff9b16ef72d0f0761ea1a016a3866c` |
| command 1 | `/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeCore.build/PrimeValidationSwiftPMBuildInventoryAdmission.swift.o` | device/inode `16777231/17337350`; `501/20`; mode `0644`; nlink `1`; flags `0`; `730,080` bytes; mtime/ctime `1787449759/1787449759`; SHA-256 `7db95394ff9dcf33686b7a43b902490e50a8f9e28946623b0a00e8f2c0b89c0a` |
| command 1 | `/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowDriverV2Supervisor.build/main.swift.o` | device/inode `16777231/17337413`; `501/20`; mode `0644`; nlink `1`; flags `0`; `67,240` bytes; mtime/ctime `1787449777/1787449777`; SHA-256 `0de811c5c8cb03a73a8c6edc4811e6e91563acd1b9aeb3b2f46c31b956da2a73` |
| command 2 | `/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowDriverCoreTests.build/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift.o` | device/inode `16777231/17337428`; `501/20`; mode `0644`; nlink `1`; flags `0`; `2,496,096` bytes; mtime/ctime `1787449784/1787449784`; SHA-256 `6b8ea82c637e9f8eabe735f66507226d3bde184eb7b2647ed389cd8d15a259b7` |

Each successor object must have a different hash and mtime/ctime inside its
assigned command interval. A later command-2 replacement of a command-1 object
is accepted only when the complete build transcript names that later compile
and the post-command object is re-admitted; otherwise it is unexplained drift.

### Exact ordered readiness commands

Use exact working directory
`/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging`.
Command 2 is forbidden unless command 1 exits `0` and all between-command base
joins pass. Run command 1 exactly once:

```sh
umask 077
/usr/bin/env -i \
  HOME=/private/tmp/gate-e1-3-readiness-474008bdffccf410/home \
  CFFIXED_USER_HOME=/private/tmp/gate-e1-3-readiness-474008bdffccf410/home \
  XDG_CONFIG_HOME=/private/tmp/gate-e1-3-readiness-474008bdffccf410/home \
  TMPDIR=/private/tmp/gate-e1-3-readiness-474008bdffccf410/tmp/ \
  USER=ergentics LOGNAME=ergentics LANG=C.UTF-8 LC_ALL=C.UTF-8 \
  TZ=UTC TERM=dumb NO_COLOR=1 \
  PATH=/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:/usr/bin:/bin \
  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
  GIT_EXEC_PATH=/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core \
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_ATTR_NOSYSTEM=1 \
  GIT_CONFIG_COUNT=6 \
  GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/private/tmp/gate-e1-3-readiness-474008bdffccf410/git-template \
  GIT_CONFIG_KEY_1=init.templateDir GIT_CONFIG_VALUE_1=/private/tmp/gate-e1-3-readiness-474008bdffccf410/git-template \
  GIT_CONFIG_KEY_2=core.attributesFile GIT_CONFIG_VALUE_2=/dev/null \
  GIT_CONFIG_KEY_3=checkout.workers GIT_CONFIG_VALUE_3=1 \
  GIT_CONFIG_KEY_4=maintenance.auto GIT_CONFIG_VALUE_4=false \
  GIT_CONFIG_KEY_5=gc.auto GIT_CONFIG_VALUE_5=0 \
  GIT_ALLOW_PROTOCOL=file GIT_PROTOCOL_FROM_USER=0 GIT_OPTIONAL_LOCKS=0 \
  GIT_TERMINAL_PROMPT=0 GIT_LFS_SKIP_SMUDGE=1 \
  GIT_NO_LAZY_FETCH=1 GIT_NO_REPLACE_OBJECTS=1 \
  CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-3-readiness-474008bdffccf410/clang-module-cache \
  SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-3-readiness-474008bdffccf410/swiftpm-module-cache \
  /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift build \
  --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow \
  --configuration release --disable-automatic-resolution --disable-sandbox \
  --product PrimeValidationWorkflowDriverV2Supervisor </dev/null
```

Then run command 2 exactly once with this exact anchored filter:

```sh
umask 077
/usr/bin/env -i \
  HOME=/private/tmp/gate-e1-3-readiness-474008bdffccf410/home \
  CFFIXED_USER_HOME=/private/tmp/gate-e1-3-readiness-474008bdffccf410/home \
  XDG_CONFIG_HOME=/private/tmp/gate-e1-3-readiness-474008bdffccf410/home \
  TMPDIR=/private/tmp/gate-e1-3-readiness-474008bdffccf410/tmp/ \
  USER=ergentics LOGNAME=ergentics LANG=C.UTF-8 LC_ALL=C.UTF-8 \
  TZ=UTC TERM=dumb NO_COLOR=1 \
  PATH=/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:/usr/bin:/bin \
  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
  GIT_EXEC_PATH=/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core \
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_ATTR_NOSYSTEM=1 \
  GIT_CONFIG_COUNT=6 \
  GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/private/tmp/gate-e1-3-readiness-474008bdffccf410/git-template \
  GIT_CONFIG_KEY_1=init.templateDir GIT_CONFIG_VALUE_1=/private/tmp/gate-e1-3-readiness-474008bdffccf410/git-template \
  GIT_CONFIG_KEY_2=core.attributesFile GIT_CONFIG_VALUE_2=/dev/null \
  GIT_CONFIG_KEY_3=checkout.workers GIT_CONFIG_VALUE_3=1 \
  GIT_CONFIG_KEY_4=maintenance.auto GIT_CONFIG_VALUE_4=false \
  GIT_CONFIG_KEY_5=gc.auto GIT_CONFIG_VALUE_5=0 \
  GIT_ALLOW_PROTOCOL=file GIT_PROTOCOL_FROM_USER=0 GIT_OPTIONAL_LOCKS=0 \
  GIT_TERMINAL_PROMPT=0 GIT_LFS_SKIP_SMUDGE=1 \
  GIT_NO_LAZY_FETCH=1 GIT_NO_REPLACE_OBJECTS=1 \
  CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-3-readiness-474008bdffccf410/clang-module-cache \
  SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-3-readiness-474008bdffccf410/swiftpm-module-cache \
  PRIME_DRIVER_V2_GATE_E_PRIME_ROOT=/private/tmp/gate-e1-3-readiness-474008bdffccf410/prime \
  PRIME_PMHNP_COMPANION_ROOT=/private/tmp/gate-e-companion-measure.pMGSXT/companion \
  /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift test \
  --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow \
  --configuration release --disable-automatic-resolution --disable-sandbox \
  --disable-swift-testing \
  --filter '^(PrimeValidationWorkflowDriverCoreTests\.PrimeValidationDriverV2AdmissionTests/testGateEPrimeScopeAndFixedPolicyAreExact|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationDriverV2AdmissionTests/testGateERawParsersAndPartialBindingsAreClosed|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationDriverV2AdmissionTests/testGateERejectsEveryRawProcessAndRepositoryMutation|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEJournalChainOneWinnerAndPoisonAreExact|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEHeldProjectionRejectsSetSymlinkGitlinkAndVnodeDrift|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateELightweightContinuityPoisonsOnEitherRootMutation|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEXCTestHostCannotConstructProductionFixedProbeBinding|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testAdmissionRequiresEveryGateCPrimeCoreSource|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testCanonicalAliasAndAncestorOverlapAreRejected|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testCompanionCaptureRejectsSymlinkFIFORootGitFile|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testCompanionTopologyLimitsAreFrozenAndRejectDepthAndFileBytes|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testCallerDeclaredGitMismatchIsRejectedBeforeAdmission|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testConsumedPrerequisiteRetainsExclusiveLease|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testCapabilitySurfaceHasNoCodecPublicInitializerOrSpawn|PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testPublicReleaseAdmissionUsesEmbeddedSourceAuthority)$' \
  </dev/null
```

These command environments are exact finite maps created by `env -i`; no other
environment assignment or CLI argument is permitted. In particular there is
no ambient home/configuration, loader override, proxy, credential/SSH agent,
scratch path, other Prime/companion input, or Driver V2 request variable. The
public-admission environment values are outer test-harness inputs only and
never enter a dedicated supervisor; no dedicated supervisor is authorized
here.

### Readiness acceptance and failure disposition

A pass requires both shell exits `0`; exact `Sigma` set equality and `15/15`
passes; the public admission's exact `2,157` watcher proof; zero method-8,
supervisor, fixed-role, fixture-child, secure-child, or spawn-canary launches;
clean control/source/Prime/companion states; the reserved three paths absent at
all three checkpoints; exact pre/post equality of both selected-test temporary
prefix inventories; and unchanged manifests, locks, dependency-store
commitments, tool images, consumed roots, prior clones, and retained prior
caches. The epoch root and every child root must remain at its admitted vnode;
the template remains empty; the home, temporary, cache, and `.build` mutations
are completely inventoried as non-authority outputs.

After command 2, admit the final supervisor and XCTest images by no-follow held
descriptor/path joins, stable descriptor hashes, regular Mach-O type, arm64
architecture, UUID, ownership, mode, link count, flags, ACL, and xattrs. Each
must contain new identity `474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52`
exactly once and exclude consumed identities
`194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`
and `afb3c46461736ddf7b275d797d054000d260eeebc0c6c50a7a94451ef1c97a19`.
The XCTest image must contain the exact source-worktree `#filePath` and all 15
selected method names; final facts, not the intermediate product-build image,
govern the later shot.

Starting either SwiftPM command permanently spends that command's readiness
budget. An ordinary assertion failure may let the already-live single XCTest
runner finish its selected finite set so the result remains attributable. Any
forbidden production launch, extra child, containment failure, root escape, or
authority mutation instead requires immediate contain-or-fail-stop handling;
it is never permitted merely to finish the aggregate. After either nonpass
returns, no later readiness command, build, test, or shot is authorized under
this freeze. Retain the clone, entire epoch, build outputs, and all
observations; no cleanup or same-freeze retry is authorized. The production
identity may be recorded unconsumed after a failure only when postchecks prove
both that method 8 was never entered and that the identity-bound production
root remained absent throughout. If those postchecks cannot complete, the
consumption state is `ABSTAIN`, not “unconsumed.”

Even a complete readiness pass authorizes zero production action. Record it in
a separate clean result checkpoint with status
`READY_PENDING_SEPARATE_SHOT_FREEZE`. Only a later clean direct-child control
freeze may create the reserved final-shot caches and authorize one exact
`--skip-build` production method-8 command. Gate F and Gate G remain forbidden.

## Gate E1.3 readiness interruption — holder flag namespace

| Field | Observed value |
| --- | --- |
| Status | `STOPPED_BEFORE_CLONE_OR_SWIFT` |
| Executed freeze | `c8ddd1933d2a1ddec297db3cc032d982a586e57d` / tree `93bdf254fcf95d02e60cd0c46a09cf6c9780ba8d` |
| Source | clean `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` / tree `0077ac10f1dbba50680502a31084f7280c2c2f65` |
| Successful namespace operations | exactly `1`: epoch-parent `mkdir` |
| Failed outer observation | holder's composite flag guard rejected before opening the parent: `File::NOFOLLOW` exists, but `File::CLOEXEC` does not; the emitted `nofollow-unavailable` label was imprecise |
| Child-directory creations | `0` |
| Clone / Swift build / Swift test | `0 / 0 / 0` |
| XCTest / method 8 / production supervisor / fixed children | `0 / 0 / 0 / 0` |
| Source edits / dependency resolution or fetch / network / GitHub | `0 / 0 / 0 / 0` |
| Production consumption | `UNCONSUMED_PROVEN` |

The exact retained epoch parent is
`/private/tmp/gate-e1-3-readiness-474008bdffccf410`, directory vnode
`16777231/17350005`, owned `501/0`, mode `0700`, nlink `2`, flags `0`, size
`64`, mtime/ctime `1787460245/1787460245`, ACL-free, with exact xattr
`{com.apple.provenance}` and empty inventory. It is retained permanently and
is ineligible for cleanup, reuse, continuation, or a successor epoch.

The exact outer error was:

```text
-e:22:in `<main>': nofollow-unavailable (RuntimeError)
```

The controller stopped after validating the new parent and before the first
child `mkdir`. Therefore no clone target, home, temporary root, template,
module cache, or Git repository was created. The reserved production root and
both reserved final-shot caches remained absent. The identity-bound production
method was never selected or entered, so production identity
`474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52`
is proven unconsumed rather than `ABSTAIN`.

Every stored non-epoch `B` component compared byte-for-byte equal after the
stop: the three clean repository commit/tree/status tuples, five
manifest/lock/workspace-state vnodes and hashes, all four dependency-store
continuity commitments, admitted tool hashes/helper commitment, ten retained
E1.2 cache-root tuples, two consumed roots, two prior Prime clones, and the
pinned companion root. All six `A0` hashes also remained exact:

| Artifact | Unchanged SHA-256 |
| --- | --- |
| stale supervisor | `fda8ab7c8f06a94c4f957f879312a6911d7e32015a344ea5b9ad63bbd04215ff` |
| stale XCTest | `b3cf7e6aee0a73b05b493ff279b435f7b81b73c24c24b1731986d0adc0f534d5` |
| provenance object | `886c9db18bf95f4c3a3d09531c725c5cfaff9b16ef72d0f0761ea1a016a3866c` |
| admission object | `7db95394ff9dcf33686b7a43b902490e50a8f9e28946623b0a00e8f2c0b89c0a` |
| supervisor-main object | `0de811c5c8cb03a73a8c6edc4811e6e91563acd1b9aeb3b2f46c31b956da2a73` |
| live-test object | `6b8ea82c637e9f8eabe735f66507226d3bde184eb7b2647ed389cd8d15a259b7` |

This was an outer instrumentation namespace error, not a Prime, Driver V2,
Git, SwiftPM, compiler, test, containment, or production result. The current
freeze is spent and authorizes no continuation. A successor must use a new
identity-bound epoch name and freeze a holder primitive that has already
opened the retained directory successfully before any new namespace mutation.

## Gate E1.3 readiness successor freeze — closed `r2` holder

| Field | Exact value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Direct durable-control predecessor | `b3a8bf83e22bf9940a9ed228a4f246f79afcd2fe` / tree `b9231afb36128b4e5d3e7f7430d5550061836c5d` |
| Spent historical freeze | `c8ddd1933d2a1ddec297db3cc032d982a586e57d` / tree `93bdf254fcf95d02e60cd0c46a09cf6c9780ba8d`; never continued, retried, cleaned, or reused |
| Permitted successor delta | exactly this control path plus `docs/tools/prime-driver-v2-e13-readiness-holder.rb` |
| Source commit/tree | clean `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` / `0077ac10f1dbba50680502a31084f7280c2c2f65` |
| Source identity/cardinality | unconsumed `474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52`; `545 / 544 / 111,620` |
| Terminal old epoch | `/private/tmp/gate-e1-3-readiness-474008bdffccf410`; directory `16777231/17350005`, `501/0`, mode `0700`, nlink `2`, flags `0`, empty; immutable evidence, not an input |
| Successor epoch `R2` | `/private/tmp/gate-e1-3-readiness-r2-474008bdffccf410`; absent before this freeze and before the successor commit |
| Holder source | mode `100644`; `13,989` bytes; Git blob `0051aba1b5ddf2f292b07ac9767756daf1b6e477`; SHA-256 `3afc1642328529c658075fc07a46ed85b775a4de753fc590eac2bbcd8b872e20` |
| Holder invocation count | at most `1`; success requires exactly `1` |
| Holder direct child multiset | exactly `7 x /bin/mkdir`, `21 x /bin/ls`, `1 x /usr/bin/env -> Xcode Git`; `29` direct spawns total |
| Readiness SwiftPM counts | ordered `0 -> 1 -> 2`; success requires exactly one Release build and one Release test |
| Production method 8 / supervisor / fixed child | `0 / 0 / 0` |
| Network / dependency fetch / GitHub / Gate F / Gate G | `0 / 0 / 0 / 0 / 0` |

The tables, finite vectors, hashes, identities, counters, and equalities in
this section are controlling data. A narrative statement cannot promote a
failed predicate, widen a set, or turn an unobserved fact into a pass.

### Root transform and trace algebra

Let `R0 = /private/tmp/gate-e1-3-readiness-474008bdffccf410` and
`R2 = /private/tmp/gate-e1-3-readiness-r2-474008bdffccf410`. Define the sole
readiness-command transform:

`rho(p) = R2 || suffix` when `p = R0 || suffix`, including the empty suffix;
otherwise `rho(p) = p`.

`rho` is applied byte-for-byte only to the environment/path occurrences in
the exact command-1 and command-2 blocks frozen at `c8ddd193...`. No source,
companion, selector, argv option, environment key, environment value outside
`R0`, cwd, tool image, reserved production root, or shot-cache byte changes.
The transformed raw command blocks, excluding Markdown fences, are:

| Vector | Bytes | SHA-256 |
| --- | ---: | --- |
| Release command 1 | `2,181` | `9ee50ccac372989bb654eb9eb5446a2d1f0b28ce612a5ecf1ccf352ee48d0894` |
| Release command 2 | `4,522` | `f620f372015ab748f6f0f9dc0ecee66e9ed4c0a3b94a838a26f9c42779667139` |

Clone preparation deliberately uses a stronger vector than `rho` alone. The
holder first enters the already-held `prime` directory with `fchdir(2)` and
the clone destination is the single byte `.`. Canonical compact JSON for the
holder's exact `/usr/bin/env` argument vector has `55` elements, `38`
environment assignments, `2,013` bytes, and SHA-256
`b1c2da4ee8d18fb925a4b911b639b56477d25f40a53587b05a13fbd49a165a59`.
Its source is the frozen source path; its branch is
`agent/prime-validation-driver-v2-gate-c`; its only protocol is `file`; and
its exact Git options remain `--local --no-hardlinks --no-tags
--single-branch --origin=origin --no-recurse-submodules --reject-shallow
--ref-format=files --no-progress --`.

Let the spent counters be `q = (holder, command1, command2)`. The only
nonterminal trace is:

`S0(0,0,0) -> S1(1,0,0) -> S2(1,1,0) -> S3(1,1,1)`.

Every other transition enters terminal `STOP`. `STOP` has no outgoing edge.
No failed or interrupted holder, clone admission, build, test, equality, or
selector check may be retried under `R2`.

| State | Necessary data predicate |
| --- | --- |
| `S0` | clean successor commit is a direct child of `b3a8bf83...`; `R2` and the three reserved production/shot paths are absent; all six `A0` hashes below are exact; non-epoch base projection is recorded |
| `S1` | holder exits `0`; exact success JSON says only `holder_complete_pending_outer_clone_admission`; all seven held `R2` vnodes rejoin; an independent outer admission proves clone commit/tree/source identity/config/remote/ref/index/object state/cleanliness and all exclusions; all `A0` hashes remain exact |
| `S2` | command 1 exits `0`; non-epoch base and admitted `R2` input equal `B_before`; the three assigned objects and supervisor are recorded as `A1`; live-test object and XCTest retain `A0` |
| `S3` | command 2 exits `0`; `B_after = B_between = B_before`; exact `Sigma` multiset passes; live-test object and XCTest are replaced and admitted as `A2`; any later replacement of an `A1` object is transcript-named and re-admitted |

The epoch coordinate changes from absent to admitted between `S0` and `S1`,
so whole-state equality is neither claimed nor desired there. Define `pi` as
the projection that removes only the new epoch object. The conservation laws
are `pi(B_S0) = pi(B_S1)` and then
`B_before = B_between = B_after` for `S1 -> S2 -> S3`. `B` includes the
successor control commit/tree, holder and runtime closure, source/control Git
joins, manifests, locks, workspace state, dependency stores, toolchain, Git
helper root, companion, terminal old epoch, admitted `R2` vnodes/clone, prior
retained roots/caches, and continued absence of the three reserved paths.

The exact `A0` SHA-256 vector is:

| Ordinal | Artifact | SHA-256 |
| ---: | --- | --- |
| 1 | stale supervisor | `fda8ab7c8f06a94c4f957f879312a6911d7e32015a344ea5b9ad63bbd04215ff` |
| 2 | stale XCTest | `b3cf7e6aee0a73b05b493ff279b435f7b81b73c24c24b1731986d0adc0f534d5` |
| 3 | provenance object | `886c9db18bf95f4c3a3d09531c725c5cfaff9b16ef72d0f0761ea1a016a3866c` |
| 4 | admission object | `7db95394ff9dcf33686b7a43b902490e50a8f9e28946623b0a00e8f2c0b89c0a` |
| 5 | supervisor-main object | `0de811c5c8cb03a73a8c6edc4811e6e91563acd1b9aeb3b2f46c31b956da2a73` |
| 6 | live-test object | `6b8ea82c637e9f8eabe735f66507226d3bde184eb7b2647ed389cd8d15a259b7` |

### Closed holder primitive

The sole launcher, from the clean successor control root with umask `077`,
stdin `/dev/null`, and no script arguments, is:

```sh
umask 077
/usr/bin/env -i LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=UTC PATH=/usr/bin:/bin __CF_USER_TEXT_ENCODING=0x1F5:0x0:0x0 /usr/bin/ruby --disable-gems /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/docs/tools/prime-driver-v2-e13-readiness-holder.rb </dev/null
```

Canonical compact JSON for the ordered five-field holder environment is
`113` bytes with SHA-256
`c90afaf77dc9e0269394c660acf86a34c283274003da9c248b253bafc68ea219`.
The script checks `ARGV == []` and exact environment equality before loading
JSON or Fiddle. `/usr/bin/ruby` is vnode
`16777231/1152921500312572705`, root-owned mode `0555`, `135,200` bytes,
SHA-256 `9d6ff3e289c7d908e3c785e0bedd6692d1d6a3377965c88c04d847104b7c892c`,
arm64e UUID `EB2540B7-E132-36BE-B719-619D0FBF7203`. Its exact loaded JSON/Fiddle
closure is `17` files / `509,985` bytes with framed continuity SHA-256
`cf9b0cd59961fd4f7c9df824e278e2253b121cc3c7d8aacbbe557120b4a8ca9d`;
the frame is sorted absolute path bytes, with unsigned big-endian 64-bit path
length, path, unsigned big-endian 64-bit file length, and raw 32-byte file
SHA-256 for every entry.

The admitted SDK `sys/fcntl.h` is vnode `16777231/932281`, root-owned mode
`0644`, `26,949` bytes, SHA-256
`805fd8c695f8e5e1c327b6852382cc5533738bbfd8f18bc11f850531166e4fe8`.
The directory-open mask is exact `0x21100000 = O_RDONLY |
O_DIRECTORY(0x00100000) | O_CLOEXEC(0x01000000) |
O_NOFOLLOW_ANY(0x20000000)`. A read-only preflight opened and rejoined
`/private`, `/private/tmp`, the retained old epoch, and the source with this
mask. The holder pins `/private` to `16777231/773652` and `/private/tmp` to
`16777231/774813`, opens and retains every new child plus source
`16777231/17154421`, and rechecks name/vnode joins around every child process.

`/bin/ls` is the sole extended-metadata observer: vnode
`16777231/1152921500312571414`, root-owned mode `0755`, `154,624` bytes,
SHA-256 `a97c50d34f912a5ada66959c231897ec2144e3c9cb922cd8150e4f2b0c9470e7`,
arm64e UUID `51D16815-0591-3D8E-BC5A-43870D773ED3`. Each of its `21` bounded
observations requires directory mode `0700`, UID/GID `501/0`, flags `0`, no
ACL entry, and exact xattr-name set `{com.apple.provenance}`. The seven
creations still use the already-admitted `/bin/mkdir`; clone uses the
already-admitted Xcode Git and helper-root commitments from `c8ddd193...`.

Every child starts in a fresh process group with `close_others`, stdin
`/dev/null`, null output, and umask `077`. HUP, INT, QUIT, and TERM set a
terminal interruption flag, kill the active group, reap its exact leader, and
require group-empty; a normal leader exit also requires group-empty. There is
no finite timeout or error return while a process group is still observed:
the holder continues KILL-and-join until the group is empty. Before success
publication it restores all four signals to their default terminating action,
then performs one final interruption check. This
claims the exact `29` direct spawns only. It does not claim Git creates no
short-lived helpers; their executable authority remains the frozen Xcode Git
helper-root commitment. A no-write signal preflight obtained
`holder-interrupted:TERM` and an empty active-child slot.

The outer launcher captures stdout and stderr independently with a `65,536`
byte cap each. Success requires exit `0`, empty stderr, and exactly one
LF-terminated stdout JSON object with ordered key set
`{status, epoch, children, prime}` and no other byte. `status` is exactly
`holder_complete_pending_outer_clone_admission`; `epoch` and `prime` are
three-integer arrays; `children` is exactly six arrays in frozen `CHILDREN`
order, each `[leaf, device, inode]`. Every emitted device is `16777231`; every
emitted inode and link count must equal independent descriptor/path
observations. A caught failure before publication emits empty stdout and one
bounded stderr JSON object with exact key set `{status, error_class, error}`.
A default signal during final publication may instead leave only a success
prefix; any nonzero exit is terminal regardless of its output bytes.

From first `R2` creation through the holder's terminal JSON, the workstation
admits no concurrent same-UID mutation of the source, `R2`, or its children.
This is an execution exclusion premise, not a substitute for the held
descriptors and joins. Any observed persistent or transient contention is
terminal. The holder's exit `0` and JSON are never clone admission. Before any
Swift command, independent outer checks must prove the exact clone
commit/tree/identity, one local origin and one selected-branch refspec, clean
porcelain-v2 status, real `.git`, config/ref/index/object-root identities, and
absence of alternates, HTTP alternates, shallow/promisor, replace/graft,
submodule, hook, extra-remote, fetch, and network state. A failure retains all
`R2` objects and authorizes no Swift command.

### Conserved Release acceptance

After `S1` and only after a full `B_before` capture, command 1 and command 2
are the exact `rho`-transformed blocks hashed above. The `Sigma` set remains
the exact 15 canonical XCTest identifiers frozen in `c8ddd193...`; acceptance
is exact multiset equality, `15` executions, `15` passes, zero skips, zero
failures, one XCTest runner, zero Swift Testing runners, and zero production
launches. Method 8 remains outside `Sigma`.

Any nonpass is terminal and retains the epoch, clone, caches, build outputs,
and observations. Even `S3` authorizes only a separate clean result
checkpoint with status `READY_PENDING_SEPARATE_SHOT_FREEZE`. It does not
authorize the reserved production root, either reserved shot cache, method 8,
a Driver V2 production child, Gate F, or Gate G.

## Gate E1.3 `r2` readiness interruption — metadata field width

| Field | Observed value |
| --- | --- |
| Status | `STOPPED_BEFORE_CLONE_OR_SWIFT` |
| Executed freeze | `eaf857cb57cb9571a8c1a0c3f4af1f20d8a28390` / tree `7e9d6af62e49eb53a25915caf97b611a7106d77f` |
| Holder identity | SHA-256 `3afc1642328529c658075fc07a46ed85b775a4de753fc590eac2bbcd8b872e20`; blob `0051aba1b5ddf2f292b07ac9767756daf1b6e477` |
| Holder executions / exit | `1 / 70` |
| Successful namespace operations | exactly `7`: epoch plus six child `mkdir` operations |
| Extended-metadata observations | `14` started: first `13` accepted, ordinal `14` rejected |
| Local clone / Swift build / Swift test | `0 / 0 / 0` |
| XCTest / method 8 / supervisor / fixed child | `0 / 0 / 0 / 0` |
| Network / dependency fetch / GitHub | `0 / 0 / 0` |
| Production consumption | `UNCONSUMED_PROVEN` |

The holder emitted the single failure object:

```json
{"status":"failed","error_class":"RuntimeError","error":"extended-metadata:/private/tmp/gate-e1-3-readiness-r2-474008bdffccf410"}
```

The rejection occurred on the second observation of the epoch parent, after
all six children and their individual pre-clone observations passed, and
before `fchdir` or the Git spawn. The exact direct-spawn prefix was therefore
`7 x /bin/mkdir + 14 x /bin/ls + 0 x /usr/bin/env`, or `21` direct children.
Every returned group was reaped and group-empty.

The metadata itself satisfied the intended predicate. The exact rejected
xattr line bytes were:

`09 63 6f 6d 2e 61 70 70 6c 65 2e 70 72 6f 76 65 6e 61 6e 63 65 09 20 31 31 20 0a`

That is tab, `com.apple.provenance`, tab, **one leading space**, `11`, space,
LF. The frozen parser accepted `[0-9]+` immediately after the second tab and
therefore rejected the leading `0x20`. The already-accepted child line lacked
that byte:

`09 63 6f 6d 2e 61 70 70 6c 65 2e 70 72 6f 76 65 6e 61 6e 63 65 09 31 31 20 0a`

This is a human-column formatting dependency in `/bin/ls`, not an ACL, flag,
xattr-set, namespace, Git, Prime, Driver V2, SwiftPM, compiler, XCTest, or
production result. The fail-closed rejection remains binding.

The exact retained `R2` topology is:

| Entry | Device / inode | UID/GID | mode / nlink / flags / bytes | Inventory |
| --- | --- | --- | --- | --- |
| epoch | `16777231/17351796` | `501/0` | `0700 / 8 / 0 / 256` | exact six frozen children |
| `home` | `16777231/17351797` | `501/0` | `0700 / 2 / 0 / 64` | empty |
| `tmp` | `16777231/17351798` | `501/0` | `0700 / 2 / 0 / 64` | empty |
| `git-template` | `16777231/17351799` | `501/0` | `0700 / 2 / 0 / 64` | empty |
| `clang-module-cache` | `16777231/17351800` | `501/0` | `0700 / 2 / 0 / 64` | empty |
| `swiftpm-module-cache` | `16777231/17351801` | `501/0` | `0700 / 2 / 0 / 64` | empty |
| `prime` | `16777231/17351802` | `501/0` | `0700 / 2 / 0 / 64` | empty; `.git` absent |

Every entry is ACL-free with exact xattr-name set
`{com.apple.provenance}`. The entire `R2` epoch is retained permanently and
is ineligible for cleanup, reuse, continuation, or a successor launch.

The three clean repository tuples, five manifest/lock/workspace-state tuples,
four dependency-store commitments, prior cache/root tuples, and all admitted
tool hashes compared exactly equal to `S0` after the stop. All six `A0` hashes
also remained exact. The reserved production root and both reserved shot
caches remained absent. Consequently the production identity remains proven
unconsumed, but this freeze is spent and authorizes no further holder, clone,
Swift, XCTest, or production action.

Any successor must use a new epoch and a separately frozen metadata primitive.
It must not repair the `/bin/ls` regular expression. Extended metadata should
be read from held descriptors through typed Darwin APIs so flags, ACL count,
and xattr-name bytes are data fields rather than human-formatted columns.

## Gate E1.3 readiness successor freeze — typed descriptor metadata

| Field | Exact value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Direct durable-control predecessor | `f62f23cf03df800281f0a417e89e07312d33f6ab` / tree `4a0014dd7535d7386da64283067d61a62479936d` |
| Permitted successor delta | exactly this control path plus `docs/tools/prime-driver-v2-e13-readiness-holder.rb` |
| Source commit/tree/identity | clean `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` / `0077ac10f1dbba50680502a31084f7280c2c2f65` / `474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52` |
| Source cardinality | `545 / 544 / 111,620` |
| Terminal epochs | original epoch `16777231/17350005`; `R2` epoch `16777231/17351796` plus its exact six children; immutable read-only canaries only |
| Successor epoch `R3` | `/private/tmp/gate-e1-3-readiness-r3-474008bdffccf410`; absent before this freeze |
| Holder source | mode `100644`; `502` lines; `16,442` bytes; Git blob `95c9bc515a21088f889be494669d0c0274c3b8e4`; SHA-256 `55da8d5cb08798eb0a633706c612bcb3ee6b03da86f01fb11bf7fe7dca5f5d83` |
| Holder invocation count | at most `1`; success requires exactly `1` |
| Holder direct child multiset | exactly `7 x /bin/mkdir + 1 x /usr/bin/env -> Xcode Git`; `8` total |
| `/bin/ls` / shell metadata parsers | `0 / 0` |
| SwiftPM readiness commands | ordered `0 -> 1 -> 2`; success requires exactly one Release build plus one Release test |
| Production method 8 / supervisor / fixed child | `0 / 0 / 0` |
| Network / dependency fetch / GitHub / Gate F / Gate G | `0 / 0 / 0 / 0 / 0` |

The controlling form remains finite data. No prose can relax a byte vector,
identity, count, equality, transition, or rejection below.

### Typed observer contract

The holder retains its exact zero-argument, five-field `env -i`, system Ruby
`--disable-gems`, JSON/Fiddle runtime, `O_NOFOLLOW_ANY`, held-vnode,
`fchdir`, process-group, interruption, and publication contracts from
`eaf857cb...`. The only instrumentation replacement is the removal of every
`/bin/ls` child and human-text parser. Each accepted metadata observation now
takes one already-held `IO` and requires this descriptor tuple:

| Coordinate | Exact typed operation and accepted value |
| --- | --- |
| BSD flags | `fgetattrlist(fd, attrlist, out8, 8, 0) == 0`; native output `[length, flags] == [8, 0]` |
| ACL | `acl_get_fd_np(fd, ACL_TYPE_EXTENDED)` returns `NULL` and immediate `errno == ENOENT == 2` |
| caller-visible xattr names | ordered size/read pair `flistxattr(fd, NULL, 0, XATTR_SHOWCOMPRESSION) == 21 -> flistxattr(fd, buffer, 21, XATTR_SHOWCOMPRESSION) == 21`; exact bytes `636f6d2e6170706c652e70726f76656e616e636500` |
| join | descriptor device/inode and nlink equal the frozen expectation before and after all three coordinates; the named path rejoins the same descriptor |

The `attrlist` is exactly `24` bytes under native Ruby pack template
`S!S!I!I!I!I!I!`: bitmap count `5`, reserved `0`, common bitmap
`ATTR_CMN_FLAGS == 0x00040000`, and four zero group bitmaps. Output uses native
`I!I!`. `ATTR_CMN_RETURNED_ATTRS` is not requested. Xattr options are exact
`XATTR_SHOWCOMPRESSION == 0x20`; the claim is explicitly limited to names
visible to this admitted caller. Any non-NULL ACL object is freed exactly once
and rejected. Every relevant native return captures `Fiddle.last_error`
immediately; no pathname-only xattr or ACL API is admitted.

The exact admitted SDK header commitments are:

| Header | SHA-256 |
| --- | --- |
| `sys/attr.h` | `5118b9245bc932bc32dcc60084b1e40d70bb5479a360b31cdbf188ef866deefe` |
| `sys/acl.h` | `9511f84f0abe1e108e10979900d4fea8567534aef78f0984f7050c49f6c29ff7` |
| `sys/xattr.h` | `60e1518429a9df2501dbec28b09642cc3a67cf1508bef0c6d8e9c1de3e1ef408` |
| `sys/errno.h` | `109ace10e79b9467dee3b8c7890f1d5bea1102d982c521922e9d372ab9863c97` |
| `unistd.h` | `8d535079658f063bcef358ef4c1c1b52b8e88dacfc22cbf4db0f6bf8abe40637` |

Before testing `R3` absence or launching its first `mkdir`, the holder opens,
holds, rejoins, and applies the exact typed observer to all eight terminal
canaries: the empty original epoch, the `R2` parent, and all six `R2`
children. It requires their recorded identities, modes, links, inventories,
flags, ACL absence, and caller-visible xattr bytes. They never become home,
cache, template, clone, cwd, or output roots. `/private` is a positive flags
control and must return exact `[8, 1,081,344]`, not zero.

A no-write preflight against those same eight canaries passed with exact
result `8|24|636f6d2e6170706c652e70726f76656e616e636500|native_r3_preflight_pass`.
The positive flags control returned `1,081,344`; the ACL-bearing
`/Users/ergentics` control produced a non-NULL ACL and the expected
`descriptor-acl-present` rejection. Syntax passed. No `R3` path was created.

There are `29` successful-path descriptor metadata observations: `8`
terminal canaries plus the prior `21` new-epoch checkpoints. Including the
single `/private` positive control, the exact descriptor-metadata native call
counts are `30 x fgetattrlist`, `58 x flistxattr`, and
`29 x acl_get_fd_np`; successful ACL-free execution calls `acl_free` zero
times. The existing cwd/vnode join adds exactly `2 x fchdir` on the successful
holder path. The direct process count is independently `8`, not `29`.

### Exact vectors and transition

Let `rho3` replace only the old readiness-root byte string
`/private/tmp/gate-e1-3-readiness-474008bdffccf410` with
`/private/tmp/gate-e1-3-readiness-r3-474008bdffccf410` in the exact two
Release command blocks from `c8ddd193...`. No other byte changes.

| Vector | Elements / bytes | SHA-256 |
| --- | ---: | --- |
| holder clone argv JSON | `55 / 2,013` | `5f5f5b8372c4bc922ee5c74f5d57e7c27068eb4e1b1bb481e5b8a38f688e90d4` |
| Release command 1 raw block | `2,181` bytes | `f20663c81ae917029ea7161f90805b622ac7d335b73de5aecb2dc930e3b3ac86` |
| Release command 2 raw block | `4,522` bytes | `97d76d72196c3ae33d92cd9404270bc15cb8ab34961cfd50aff37c196b3fe3b8` |

Clone still enters the held `R3/prime` vnode with `fchdir` and uses destination
`.`. Its exact `38`-assignment scrubbed environment, local-file source,
branch, Git options, and outer full clone-admission boundary are unchanged.

The sole accepted counter trace remains
`S0(0,0,0) -> S1(1,0,0) -> S2(1,1,0) -> S3(1,1,1)`. Any other transition
enters terminal `STOP`, which has no outgoing edge. `S0` requires a clean
successor commit directly on `f62f23cf...`, exact `A0`, exact non-epoch `B`,
and absence of `R3` plus all three reserved production/shot paths. `S1`
requires holder exit `0`, exact one-line success framing, all `R3` vnode joins,
and independent full clone admission; holder success alone is insufficient.
`S2/S3`, the six-object `A0 -> A1 -> A2` rules, the exact 15-member `Sigma`
multiset, and `B_before = B_between = B_after` are unchanged from the prior
freeze except for `rho3` and the admitted `R3` object.

Any native preflight, holder, metadata, namespace, process, clone-admission,
`A`, `B`, command, or selector mismatch is terminal: retain `R3`, do not
clean, repair, continue, or retry. Even `S3` authorizes only a separate result
checkpoint. It authorizes no reserved production root, shot cache, method 8,
Driver V2 production child, Gate F, or Gate G.

## Gate E1.3 readiness R3 result — local typed execution

| Coordinate | Exact result |
| --- | --- |
| Status | `READY_PENDING_SEPARATE_SHOT_FREEZE` |
| Direct result predecessor | `62bca101e4e33e3aacd65400b2a508b3376f9557` / tree `5c1e68dc3960275155e02d401a8c5daec32f20d6` |
| Result mutation | this control path only; source and holder bytes unchanged |
| Accepted trace | `(0,0,0) -> (1,0,0) -> (1,1,0) -> (1,1,1)` |
| Frozen invocation counts | holder `1`; clone `1`; Release build `1`; Release test `1` |
| Production counts | method 8 `0`; supervisor launch `0`; fixed-role launch `0`; SpawnCanary / FixtureChild / SecureChildIntegration launch `0 / 0 / 0` |
| External transport | network `0`; dependency fetch `0`; GitHub `0` |
| Production identity | `474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52`; `UNCONSUMED_PROVEN` |

The four counters above are the complete readiness execution. Compilation or
linking of test dependencies is not a product launch. The selected XCTest
multiset excludes the production method, and all three reserved paths remained
absent before, between, and after the two Swift commands.

### Holder and clone result

| Coordinate | Exact result |
| --- | --- |
| Holder | exit `0`; stdout `333` bytes / SHA-256 `8905b7e27be925e0750637998b6baeb4a0ad17cd8d43b7c5a8395a69bd75e13d`; stderr `0` bytes / SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| Retained outer capture | `/private/tmp/gate-e13-r3-holder-capture.sIxqW6`; root `16777231/17353269`; stdout `17353270`; stderr `17353271`; `501/0`; root `0700`, files `0600` |
| Epoch | `/private/tmp/gate-e1-3-readiness-r3-474008bdffccf410`; `16777231/17353272`; `501/0`; `0700`; nlink `8` |
| Six children | `home=17353273`, `tmp=17353274`, `git-template=17353275`, `clang-module-cache=17353276`, `swiftpm-module-cache=17353277`, `prime=17353278` |
| Successful holder primitive vector | descriptor metadata `30 / 58 / 29 / 0` (`fgetattrlist / flistxattr / acl_get_fd_np / acl_free`); `2 x fchdir`; direct children `7 x mkdir + 1 x env->Git` |
| Clone root | `16777231/17353278`; `501/0`; `0700`; nlink `15`; flags `0`; ACL-free; exact provenance xattr |
| Clone `.git` / object root | `16777231/17353279`, nlink `9` / `16777231/17353289`, nlink `260`; both `501/0`, `0700`, flags `0`, ACL-free, provenance-xattr-only |
| Clone source authority | `545` files / `544` records / `111,620` canonical bytes / `474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52` |
| Clone Git authority | clean `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` / tree `0077ac10f1dbba50680502a31084f7280c2c2f65`; branch `refs/heads/agent/prime-validation-driver-v2-gate-c`; SHA-1 / files |
| Origin | one remote `origin`; exact local source URL; one selected-branch fetch refspec; `--no-tags` |

The clone has no alternates, HTTP alternates, shallow/promisor state, replace
refs, grafts, gitlinks, submodules, hooks, extra remote, configuration include,
or worktree configuration. Strict full Git fsck passed. Its exact admitted
Git-file coordinates are:

| File | Device/inode / bytes | SHA-256 |
| --- | --- | --- |
| `.git/config` | `16777231/17358443` / `527` | `c979a560863c0b45b8f7b64eaa0f7f595ca3b06f2a04dbf4237221deb4a206cd` |
| `.git/HEAD` | `16777231/17358431` / `56` | `a86308744aebc9d6f2ab7bf2521be7e6995040de2642875656f8aaac489ee58d` |
| `.git/index` | `16777231/17358444` / `115,271` | `7624444769b265677facd7929e53bab0b5d2dcc64d25484071ccc37ab1b39b37` |
| `.git/packed-refs` | `16777231/17358430` / `147` | `33f78c188613ab501a1e31e7ed0d6a76573f3bf1a0108649571160c012e67de5` |
| selected loose local ref | `16777231/17358434` / `41` | `0559d479da9baefaf50900dd9c2b9047bb796756cc30b46cf8cca5a14305d65d` |

### Readiness command results

| Step | Exact vector | Exit / observation |
| --- | --- | --- |
| Command 1 | `2,181` bytes / `f20663c81ae917029ea7161f90805b622ac7d335b73de5aecb2dc930e3b3ac86` | exit `0`; product build `184.01` seconds |
| Command 2 | `4,522` bytes / `97d76d72196c3ae33d92cd9404270bc15cb8ab34961cfd50aff37c196b3fe3b8` | exit `0`; test build `197.66` seconds; selected tests `20.181` seconds |
| Observed `Sigma` | sorted canonical JSON `15` elements / `2,180` bytes / `0d52e3bc5b7ab2f88b88e880dbfef2bc33629acf933cc5edc0196da759e217a9` | `15` starts / `15` passes / `0` skips / `0` failures; one XCTest runner; zero Swift Testing runners |
| Release public admission | exact selected method passed in `2.690` seconds | source asserts and observed pass closes `2,157` combined watchers while `supervisor_executable_image` remains missing |

Command 1 explicitly compiled PrimeCore, DriverCore, and supervisor main and
linked the supervisor. Command 2 explicitly compiled PrimeCore, DriverCore,
supervisor main, DriverCoreTests, and the XCTest runner and relinked both final
images. Therefore every later replacement below belongs to a named live
command interval; an unchanged coordinate is explicitly marked retained.

### Artifact transition `A0 -> A1 -> A2`

Each cell is `SHA-256 / inode / bytes`.

| Artifact | `A0` | `A1` after command 1 | `A2` after command 2 |
| --- | --- | --- | --- |
| Release supervisor | `fda8ab7c8f06a94c4f957f879312a6911d7e32015a344ea5b9ad63bbd04215ff / 17337418 / 47,675,784` | `7b52f4967d64f634fead4541496fe1e7a050757a7f586fb85e25c3b40e5bd0e1 / 17360425 / 45,600,920` | `57bae5845d7b2ad108309d623902bd7a68688c7882e1649ca23f8a93764dfafe / 17361435 / 47,679,960` |
| Release XCTest | `b3cf7e6aee0a73b05b493ff279b435f7b81b73c24c24b1731986d0adc0f534d5 / 17337446 / 56,490,080` | retained `A0` | `c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712 / 17361530 / 56,562,128` |
| provenance object | `886c9db18bf95f4c3a3d09531c725c5cfaff9b16ef72d0f0761ea1a016a3866c / 17334921 / 12,816` | `7c12dc4287c934b6180c9cd62da6be130c9ee39603efc1cb95fe062def768f6e / 17360243 / 12,760` | retained `A1` |
| admission object | `7db95394ff9dcf33686b7a43b902490e50a8f9e28946623b0a00e8f2c0b89c0a / 17337350 / 730,080` | `53a6c302bc6edf9a3c206fc5426ba64f148019697a99a99eafcd1639e5d79e0a / 17360381 / 697,632` | `ff6148c9cab8a3b24cf54bdb4c64450d9eb991276e8c033cabe049f0b9389659 / 17361015 / 754,480` |
| supervisor-main object | `0de811c5c8cb03a73a8c6edc4811e6e91563acd1b9aeb3b2f46c31b956da2a73 / 17337413 / 67,240` | `0ab783b73aff6b9ba809a2c818a42d3e629b5f05d2343c2778f014ba7ccfe258 / 17360420 / 68,120` | `a6aaafd2b64a9832a0c55c8ff3d04c6e342999de01fd8e8436076376c0b4e10e / 17361430 / 69,120` |
| live-test object | `6b8ea82c637e9f8eabe735f66507226d3bde184eb7b2647ed389cd8d15a259b7 / 17337428 / 2,496,096` | retained `A0` | `0fa3803576279a873568c33c7df793f3d3e3b81e655e62448223b985d34f2913 / 17361446 / 2,690,784` |

All `A2` paths were reopened with `O_NOFOLLOW_ANY`, held, joined to the named
device/inode before and after two stable reads, and matched the hashes above.
The two images are owner-executable mode `0700`; the four objects are mode
`0600`. All are `501/20`, regular, one-link, flags `0`, ACL-free, and
provenance-xattr-only. These modes are the exact consequence of the frozen
`umask 077`, not equality to stale preimage modes.

The final supervisor is arm64 `MH_EXECUTE`, UUID
`02CCEC13-5745-3245-AF0F-E2A49D4A68C4`; the final XCTest image is arm64
`MH_BUNDLE`, UUID `F62F4215-B00C-30C0-B7B2-43BF6924B73D`. Each contains the
current identity exactly once and both consumed identities zero times. The
XCTest image contains the exact live-test source-worktree `#filePath` once and
all fifteen selected method names.

### Conserved base result

`B_before = B_between = B_after` passed coordinate-by-coordinate:

| Conserved coordinate | Exact terminal result |
| --- | --- |
| Repositories | control `62bca101.../5c1e68dc...`; source `2d705a71.../0077ac10...`; companion `163fc100.../9009daa4...`; all porcelain-v2 streams empty |
| Manifest/lock/workspace inputs | all five original vnode and SHA-256 tuples exact |
| Dependency inputs | `2,089 / 7f9d0bc...a433`; `129 / 54bb366...fda3`; `88 / cd21b849...b63d`; `38 / 0db4dd0...1108` |
| Git helper closure | `197 / 2492a25a6d248e78c3d7716c96a55e1248628fda2c405368f9bfcfbf164ee31d` |
| Prior retained roots | all `15 / 15` exact |
| R3 held roots | parent and all six child device/inodes unchanged; clone Git coordinates and source identity unchanged; Git template empty |
| Selected-test prefix inventory | before = after = sole preexisting `/private/tmp/prime-validation-admission-tests-20260803-c`, vnode `16777231/11306865` |
| Tool/header commitments | all admitted image, helper-root, holder, and five typed-header hashes exact |
| Reserved paths | production root absent; shot Clang cache absent; shot SwiftPM cache absent |

Home, temporary, module-cache, and `.build` output mutations remain explicitly
outside conserved `B`; their root device/inodes remained joined. The source
worktree Git link, gitdir/backlink, HEAD, commondir, index, common config,
selected ref, object-root vnode, and packed-refs bytes remained exact through
both commands.

### Rank-5 observer residuals

Two read-only workstation helpers made extra assumptions that are not members
of the frozen admission relation:

| Helper-only assumption | Observed data | Authority classification |
| --- | --- | --- |
| Prime admitted-directory count guessed as `145` | frozen source tuple was already exact; non-authority directory observation was `143` | `NOT_IN_PREDICATE` |
| remote-tracking ref guessed to be a loose file | exact ref resolved at the selected commit in `.git/packed-refs`; local selected ref remained loose and exact | `NOT_IN_PREDICATE` |

Both helpers were read-only and changed no namespace, vnode, counter, command,
or frozen byte vector. A rank-5 observer cannot add an authority coordinate or
negate the exact source/Git data. They were not retries of the holder, clone,
build, or test; each of those frozen invocations remained exactly one.

### Disposition

Retain R3, the capture root, caches, home, temporary outputs, clone, and build
artifacts unchanged. This result checkpoint authorizes no production root,
shot cache, `--skip-build` command, method 8, supervisor child, Gate F, or Gate
G. The next possible action is a separately reviewed clean freeze that names
the exact final A2 images and one production-shot command. Until that new
authority exists, readiness is complete and production execution remains
closed.

## Gate E1.3 production-shot prefreeze audit — authority withheld

| Coordinate | Exact result |
| --- | --- |
| Audit predecessor | clean `3b93b69eed2e2fe1b005dbf7344b7b20b46e5957` / tree `9ab09018a17f9cc6b366af344e31a7c07591da45` |
| Source | clean `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` / tree `0077ac10f1dbba50680502a31084f7280c2c2f65` |
| Current production authority vector | `00000000` |
| Current A2 disposition | retained readiness evidence; not production-shot authority |
| Shot-freeze disposition | `BLOCK_CURRENT_METHOD8_OUTER_CONTAINMENT` |
| Production commands / method 8 / supervisor / fixed child | `0 / 0 / 0 / 0` |
| Network / fetch / GitHub | `0 / 0 / 0` |

The eight vector coordinates, in order, are
`[prime_git, companion_git, swift_version, swift_target_info,
swiftpm_build, artifact_staging, xctest_inventory, swift_testing_inventory]`.
No partial journal prefix changes this vector. A future complete Gate E result
may change it atomically from `00000000` to `11110000`; every incomplete,
nonpass, missing-terminal, or containment-uncertain result leaves it
`00000000`.

The retained A2 images remain exact:

| Image | Exact retained readiness fact |
| --- | --- |
| Supervisor | device/inode `16777231/17361435`; `47,679,960` bytes; mode `0700`; UUID `02CCEC13-5745-3245-AF0F-E2A49D4A68C4`; SHA-256 `57bae5845d7b2ad108309d623902bd7a68688c7882e1649ca23f8a93764dfafe` |
| XCTest | device/inode `16777231/17361530`; `56,562,128` bytes; mode `0700`; UUID `F62F4215-B00C-30C0-B7B2-43BF6924B73D`; SHA-256 `c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712` |

Both images contain current identity
`474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52`
once and both consumed predecessor identities zero times. Those facts remain
valid readiness data. They cannot authorize a shot because the current outer
launcher fails the following containment relation:

```text
outer supervisor process group = {S}
fixed probe process groups      = {C1}, {C2}, ... {C16}
current timeout kill(-S)        = {S}, not any live Ci
```

The excluded XCTest launcher starts `S` without
`POSIX_SPAWN_START_SUSPENDED`, without a held-cwd join, and without a mapped
supervisor-image join. Its write-failure and 60-second timeout branches kill
and reap only `S`. Every fixed probe is deliberately a distinct
start-suspended session and process-group leader. Therefore an outer kill can
orphan the one active Git or Swift role. Passing expected-path behavior cannot
repair a failure-path containment mismatch.

Three additional data gaps are conserved rather than explained away:

1. the exact canonical supervisor request is generated in memory but its
   byte count, SHA-256, and bytes are not durably retained;
2. the inner raw-terminal leaf precedes DriverCore semantic binding and final
   live continuity revalidation, so it is not a complete terminal; and
3. the old outer phase label maps `65`, `66`, `67...73`, and `70`, but not the
   typed admission statuses `74...90`.

No control prose may waive these failed coordinates. The current production
root and both reserved final-shot cache paths remain absent. The complete R3
epoch, including its Prime clone, is retained but ineligible for production
reuse by its own freeze. No production-shot freeze or invocation is
authorized on current A2.

## Gate E1.4 withdrawn draft — separately grouped shot governor

| Field | Frozen value |
| --- | --- |
| Status | `WITHDRAWN_BEFORE_COMMIT_NO_AUTHORITY` |
| Durable-control predecessor | `3b93b69eed2e2fe1b005dbf7344b7b20b46e5957` / tree `9ab09018a17f9cc6b366af344e31a7c07591da45` |
| Source predecessor | clean `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` / tree `0077ac10f1dbba50680502a31084f7280c2c2f65` |
| Authorized successor source commits | `0` |
| Authorized source paths | `0`; the five-path candidate below is historical audit input only |
| Swift build / test / governor / supervisor / fixed child | `0 / 0 / 0 / 0 / 0` in this source slice |
| Source dependency resolution / fetch / network / GitHub | `0 / 0 / 0 / 0` |
| Gate F / Gate G authorization | `false / false` |

This draft is retained to make the rejected reasoning inspectable. It is not
a freeze and authorizes no source mutation or execution. Its separately
sessioned-child design loses safe child discovery if the supervisor dies after
`posix_spawn` and before the inner start leaf exists. The authoritative
successor is the Gate E1.4-C shared-session freeze below; every conflicting
allowlist, process relation, proof claim, or successor rule in this withdrawn
section is void.

The five-path allowlist is:

1. `Tests/PrimeValidationWorkflow/Package.swift` — add exactly one executable
   product, one non-product core target named
   `PrimeValidationWorkflowDriverV2ShotGovernorCore`, and one executable target
   named `PrimeValidationWorkflowDriverV2ShotGovernor`; the core target's only
   dependencies are `PrimeValidationWorkflowDriverCore` and root-package
   `PrimeCore`, the executable depends only on the core target, and the existing
   test target gains only the core target; no plugin, external dependency,
   command plugin, resource, or new package input;
2. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernorCore/PrimeValidationDriverV2ShotGovernor.swift`
   — one new package-scoped, closed capsule/launch/containment owner in its own
   target; DriverCore remains forwarding-only and contains no spawn substrate;
3. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernor/main.swift`
   — one new silent `@main` that invokes only the closed governor and exposes
   no public or generic command surface;
4. `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift`
   — disable the old method-8 launch path before root creation, extend an
   existing selected mechanics method with the fixed governor fixture proof,
   and bind the governor source/manifest surface; no new or renamed XCTest
   identifier; and
5. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` — canonical source
   identity reseal only after the first four paths are final.

Current preimages for the three existing mutable paths are:

| Path | Lines / bytes | Git blob / SHA-256 |
| --- | ---: | --- |
| nested `Package.swift` | `122 / 3,668` | `b8c29f2530efa863b99f0ddc7b32a363e7b525ed` / `8dc77c80ee6a13d5ce184d1c7886701b3d317c07abda0f7ab38d21ef7eef8d35` |
| live-test source | `5,931 / 212,136` | `686a199b270666b01106ce1c941b249a041705a3` / `41f5c3ec45489a856d800ec9737ef4af440559fcf10b474fac599c254c38c59f` |
| embedded provenance | `13 / 546` | `8cba2df196ce65f7c83cf2aa4444faf01b8b336b` / `4e2b4b81ea8d7ffade440ddcdcd6d1462e7c163380f49facdecea901b2a159d7` |

Both new paths are absent at freeze. Adding exactly those two regular files
and the two new target directories predicts `547` admitted files, `546` source
identity records, `154` Prime authority directories, and
`547 + 154 + 1,460 = 2,161` combined watchers. Those counts are acceptance
predicates, not estimates to be silently corrected. A mismatch stops the
slice and requires a successor control record.

### Closed governor transport and authority ceiling

The governor has `argc == 1`, requires an empty replacement environment, and
accepts exactly one canonical typed capsule from standard input with a fixed
byte cap and EOF deadline. It has no JSON-path loader, environment protocol,
subcommand, role selector, caller timeout, caller cwd, caller argv, shell,
`Process`, build, list, staging, inventory, or retry surface. The capsule is a
declaration only; decoding it restores no live descriptor, lease, watch,
process, or capability. The governor opens and joins every live object itself.

The capsule canonical payload contains no self-digest. Its SHA-256 is computed
over the exact canonical payload bytes, then attached only to the separately
published outer start. A future capsule must bind the future readiness
commit/tree, source commit/tree/identity/cardinality, companion commit/tree,
fresh Prime-clone policy, exact governor and supervisor images, tools, roots,
absent paths, attempt `1`, `rerun_authorized = false`, `local_only = true`,
and `network = fetch = github = 0`. No current capsule or production command is
authorized by this source-edit freeze.

The governor directly parents the dedicated supervisor. SwiftPM and XCTest
are not members of the production-shot process hierarchy. The governor builds
the existing `PrimeValidationDriverV2SupervisorLaunchRequestV1` from the
closed capsule and newly admitted roots, validates it, and persists the exact
canonical request bytes before using those same held bytes as the
supervisor's stdin frame. The supervisor `main.swift`, DriverCore target,
request schema, DriverCore intent/image bridge, facade, fixed role table, and
the 16-role PrimeCore executor remain byte-for-byte unchanged.

### Required process-set and durable order

Let

```text
Q = (
  governor, supervisor,
  roleStart[1...16], roleTerminal[1...16],
  build, staging, listXCTest, listSwiftTesting,
  extraRunner, fixture, network, fetch, GitHub
)
```

The sole future success vector is

```text
Qsuccess = (1, 1, 1^16, 1^16, 0, 0, 0, 0, 0, 0, 0, 0, 0)
```

Fixture processes are permitted only in the package-internal mechanics seam
and are not reachable from the governor `@main`. Production success requires
fixture count `0`. The governor deadline begins before supervisor spawn. It
opens the exact supervisor image and a fixed private cwd on held no-follow
descriptors, spawns the supervisor suspended in a dedicated session/group,
proves descriptor/named-vnode equality plus suspended cwd and mapped-image
joins, and publishes an exclusive immutable outer start before exactly one
resume.

The durable order is:

```text
capsuleDurable < requestDurable < outerStartDurable < supervisorResume
  < innerPrestart
  < start[1] < terminal[1] < ... < start[16] < terminal[16]
  < innerRawTerminal < supervisorExactReap
  < supervisorGroupEmpty and everyObservedChildGroupEmpty
  < outerTerminalDurable
```

The order is strict except that each completed leaf publication time may equal
the immediately preceding observation only where the underlying monotonic
clock reports equality; it may never reverse. Role ordinals, names, hashes,
and predecessor links remain exact. `innerRawTerminal` is necessary but not a
success terminal. The outer terminal is published with exclusive no-replace,
`fsync`, `F_FULLFSYNC`, and parent-directory durability only after exact
supervisor wait, bounded independent EOF drains, complete inner journal
validation, root/image rejoins, and post-run conservation.

At most one fixed probe is live because the existing executor is sequential.
On timeout, interruption, or post-spawn rejection, the governor first stops
and confirms the supervisor, identifies zero or one live direct fixed child
using kernel process identity plus the immutable start journal, contains and
proves empty that child's dedicated group, then contains/reaps the supervisor
and proves its group empty. More than one live child, an unidentified
descendant, image/cwd mismatch, PID identity ambiguity, nonempty group, or
uncontained drain is containment uncertainty and must end in the governor's
fixed exit-70 fail-stop path; it can never become an ordinary test failure or
`PASS`.

### Mechanics proof and old-launch closure

The package-internal test seam may accept only a held, already-opened fixture
image and private throwaway roots; production accepts no caller path. Extend
the existing
`testGateEJournalChainOneWinnerAndPoisonAreExact` identifier to prove:

- exclusive capsule/request/start/terminal publication and collision poison;
- start durability before resume;
- suspended cwd and mapped-image joins;
- normal exact reap, independent EOF drains, and group-empty proof;
- timeout with one separately grouped child leaves both child and governor
  groups empty; and
- one winner under sequential and concurrent consume, permanent poison, and
  no retry.

The fixture seam must not close `supervisor_executable_image`, any Gate E
process observation, or any roadmap authority. The old
`testGateEReleaseSupervisorRequiresLiveFourAuthorityBindingBeforeExit`
identifier remains present for inventory stability but must fail closed before
production-root creation and launch zero processes. Its phase map is updated
to name all supervisor statuses `65...90` exactly, with unclassified values
remaining `unknown`; it is never the future production command.

### Conservation and successor requirement

The future execution predicate is coordinate-wise:

```text
B_before = B_preResume = B_after
A_before = A_after
M_before = 00000000
M_success = 11110000
```

`B` includes control/source/companion and fresh-clone identities; capsule and
request bytes; manifests, locks, dependency commitments and tools; governor
and supervisor images; retained prior evidence; root joins; and forbidden-path
absence. `A` is exact governor/supervisor/XCTest and object identity across a
`--skip-build`-free direct governor invocation. Only explicitly frozen
home/tmp/cache, production-root, journal, lease, and capture transitions are
outside equality. An incomplete prefix changes no `M` bit.

The source-edit slice authorizes only the five paths, two independent
canonical source-identity calculations, one provenance reseal, and one clean
source commit. It authorizes no Swift command, fixture execution, namespace
creation, clone, cache, capsule, governor, supervisor, Git/Swift probe,
production root, cleanup, or shot. After implementation, a separate clean
source checkpoint and then a fresh finite readiness freeze/result must build
and admit new images and exercise the fixture seam. Only a later direct-child
production-shot freeze may name one direct governor invocation. Gate F and
Gate G remain separate and closed.

## Gate E1.4-C freeze — conserved-session local shot governor source slice

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_SOURCE_EDIT_NOT_IMPLEMENTED` |
| Durable-control predecessor | `3b93b69eed2e2fe1b005dbf7344b7b20b46e5957` / tree `9ab09018a17f9cc6b366af344e31a7c07591da45` |
| Source predecessor | clean `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` / tree `0077ac10f1dbba50680502a31084f7280c2c2f65` |
| Authorized successor source commits | exactly `1`, a direct child of the source predecessor |
| Authorized source paths | exactly `12` |
| New regular files / new directories | exactly `3 / 3` |
| Swift build / test / executable launch | `0 / 0 / 0` in this source slice |
| Clone / root / cache / capsule creation | `0 / 0 / 0 / 0` |
| Dependency resolution / fetch / network / GitHub | `0 / 0 / 0 / 0` |
| Gate F / Gate G authorization | `false / false` |

The matrices, exact sets, hashes, counts, and equality predicates in this
section are authority. Prose explains them and cannot relax a mismatch. This
section supersedes the withdrawn five-path candidate above.

### Exact mutation set

The twelve-path allowlist is:

1. `Tests/PrimeValidationWorkflow/Package.swift`;
2. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernorCore/PrimeValidationDriverV2ShotGovernor.swift`;
3. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernor/main.swift`;
4. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2SessionFixture/main.swift`;
5. `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift`;
6. `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationDriverV2AdmissionTests.swift`;
7. `Sources/PrimeCore/PrimeSecureChildDarwinSubstrate.swift`;
8. `Sources/PrimeCore/PrimeSecureChildLifecycle.swift`;
9. `Sources/PrimeCore/PrimeSecureChildSupervision.swift`;
10. `Sources/PrimeCore/PrimeValidationDriverV2FixedProbeExecutor.swift`;
11. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore/PrimeValidationDriverV2FixedProbeBinding.swift`; and
12. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift`.

The three new paths in entries 2, 3, and 4, and their three target directories,
are absent at freeze. The nine existing preimages are exact:

| Path | Lines / bytes | Git blob / SHA-256 |
| --- | ---: | --- |
| nested `Package.swift` | `122 / 3,668` | `b8c29f2530efa863b99f0ddc7b32a363e7b525ed` / `8dc77c80ee6a13d5ce184d1c7886701b3d317c07abda0f7ab38d21ef7eef8d35` |
| Gate-E live tests | `5,931 / 212,136` | `686a199b270666b01106ce1c941b249a041705a3` / `41f5c3ec45489a856d800ec9737ef4af440559fcf10b474fac599c254c38c59f` |
| Gate-E admission tests | `2,331 / 88,036` | `5ee18564fd204ff0af2b502deead4027e0b583f4` / `8022c5aae4fd437e76101e0136f3ffe830d5ca373db8fda2fb8d7871759a4d33` |
| `PrimeSecureChildDarwinSubstrate.swift` | `726 / 21,442` | `a0a63e9e44b787aaa84cce7381e3af9f4b67fb49` / `072e8766286e0edda802f15df8137f94ff3febea7bf3f222d350d2efb776bfc5` |
| `PrimeSecureChildLifecycle.swift` | `1,000 / 26,436` | `e2b65441e015b7c4728f3bd3aaaf125ea21b137e` / `21fe130dbf1d4fc42437bfe6a9224d9f6d7f4568b7785c9dc5a0f8014538adb6` |
| `PrimeSecureChildSupervision.swift` | `842 / 24,830` | `13d882363479143d2a207375ac3eb84971fabb35` / `700f64199ccfcfac2c21cd7e0e8145d6e72d3cc85ad64ee8781a08fc7dcc6caf` |
| Gate-E fixed-probe executor | `3,114 / 125,292` | `54cccf156d55bced3de69486e66e242a4a39fda1` / `ec5f426edf48a89d11fda1df85c029de68aa09352e3cece39425c322a91101ab` |
| DriverCore Gate-E binding | `2,374 / 102,490` | `f4c3685364952d1e122644f2a4902060bea8256b` / `4765f2b055780f681311cd0ac095412dd17739d4fe868c18ced7537db07ecee9` |
| embedded provenance | `13 / 546` | `8cba2df196ce65f7c83cf2aa4444faf01b8b336b` / `4e2b4b81ea8d7ffade440ddcdcd6d1462e7c163380f49facdecea901b2a159d7` |

The manifest adds exactly two executable products, one non-product target
`PrimeValidationWorkflowDriverV2ShotGovernorCore`, and two executable targets
`PrimeValidationWorkflowDriverV2ShotGovernor` and
`PrimeValidationWorkflowDriverV2SessionFixture`. GovernorCore depends only on
`PrimeValidationWorkflowDriverCore` and the root `PrimeCore` product. The
governor executable depends only on GovernorCore. The session fixture has no
dependency. The existing DriverCore test target gains only GovernorCore. No
external dependency, plugin, command plugin, resource, or lockfile input is
added. The predecessor `PrimeValidationWorkflowFixtureChild` source, product,
target, bytes, and all authorities that pin it remain unchanged.

Only the three new source files and three target directories change topology.
The successor acceptance counts are therefore exact:

```text
Prime admitted files            = 545 + 3 = 548
source-identity records         = 544 + 3 = 547
Prime authority directories     = 152 + 3 = 155
companion file+directory watches           = 1,460
combined watcher descriptors    = 548 + 155 + 1,460 = 2,163
```

A different count is a hard stop requiring a successor control record; it is
not corrected in implementation prose.

### Conserved session and local child groups

The kernel ownership relation is:

```text
governor G: outside the production session
supervisor S: PID(S) = PGID(S) = SID(S) = S
probe Ci: PID(Ci) = PGID(Ci) = Ci; SID(Ci) = S
```

The dedicated supervisor retains its existing
`POSIX_SPAWN_START_SUSPENDED | POSIX_SPAWN_CLOEXEC_DEFAULT |
POSIX_SPAWN_SETSID | POSIX_SPAWN_SETSIGDEF |
POSIX_SPAWN_SETSIGMASK` launch. Only the Gate-E fixed-probe spawn changes.
Its exact flags are:

```text
POSIX_SPAWN_START_SUSPENDED | POSIX_SPAWN_CLOEXEC_DEFAULT |
POSIX_SPAWN_SETPGROUP | POSIX_SPAWN_SETSIGDEF |
POSIX_SPAWN_SETSIGMASK = 0x408e
```

The Gate-E-only substrate entry calls `posix_spawnattr_setpgroup(..., 0)`.
It has no caller-supplied session, group, or containment-mode parameter. It
derives `S` from the current process and rejects unless
`getpid() == getpgrp() == getsid(0)`. Before any child resume, supervision
must prove `getsid(Ci) == S` and `getpgid(Ci) == Ci`. Every other
secure-child caller retains the existing `0x448c` isolated-session entry and
semantics byte-for-byte in behavior.

Lifecycle gains a distinct internal authority state for a dedicated child
group within the held supervisor session. It must not mislabel that state as
an isolated child session. Existing group-backed signal, exact-child wait,
drain, and cleanup mechanics remain:

```text
pre-reap members = [Ci]
signal target = -Ci
wait target = Ci exactly once
post-reap kill(-Ci, 0) = -1 and errno = ESRCH
```

The fixed executor uses only the Gate-E entry, includes the containment mode
and `0x408e` in its policy identity, and records
`supervisorPID = supervisorSID = supervisorPGID = S`. Each of the 16 start
records binds `sessionIdentifier = S`,
`processGroupIdentifier = processIdentifier = Ci`, unique child PGIDs, and
the exact flags. Its prestart, start, terminal, and raw-terminal schemas are
versioned for this changed relation. Each terminal retains exact reap,
independent EOF drains, and `process_group_empty_after_reap = true`.

DriverCore does not select a session, group, path, role, argument, or command.
It validates that all 16 observations have the one recorded supervisor SID,
that no child PID equals `S`, that all child PIDs/PGIDs are positive and
unique, and that `PGID(Ci) = PID(Ci)`. Its fixed authority vector still changes
only after the complete ordered semantic bind. The existing source-contract
test is updated from the stale `0x448c` Gate-E assertion to the new exact
Gate-E relation; retaining that stale assertion is forbidden.

This relation supplies one reparent-stable discovery coordinate. PPID is
telemetry and may change; SID is authority. If `S` dies after child spawn and
before a start leaf exists, an unjournaled suspended `Ci` still has `SID=S`
and `PGID=Ci`. No unrelated process can join session `S`.

A descendant of `Ci` could deliberately call `setsid()` and escape. `Ci`
itself cannot because it is a process-group leader. This descendant residual
already exists in the predecessor design and is not widened here. The exact
admitted Git/Swift images, fixed argv, absent hooks, closed configuration, and
five-entry environment are frozen as non-daemonizing roles. Any observed
extra descendant, new session, or unexplained group is containment uncertainty
and cannot yield `PASS`. A future kernel job/container primitive is required
if descendant non-escape must become an OS theorem independent of admitted
executable behavior.

### Closed fixture and test boundaries

The new dedicated `PrimeValidationWorkflowDriverV2SessionFixture` has exactly
two closed internal modes. Both require the fixture supervisor to satisfy
`PID = PGID = SID`, spawn exactly one child with `SETPGROUP(0)` and no
`SETSID`, and prove
`SID(child) = SID(parent)` and `PGID(child) = PID(child)`:

1. `--driver-v2-shared-session-prepublication-held` leaves the child
   start-suspended while the fixture supervisor remains alive, so the governor
   must discover and stop the unjournaled child by SID before containing the
   still-live supervisor; and
2. `--driver-v2-shared-session-orphan-transition` exits the fixture
   supervisor with the child still start-suspended. POSIX may send `SIGHUP`
   followed by `SIGCONT` when that stopped process group becomes orphaned, so
   the accepted observation is either the bound child identity still in
   `SID=S` or complete session/child-group disappearance. It must never assume
   that the orphan remains suspended.

The modes are reachable only through the package-internal governor mechanics
seam. The production governor capsule has no fixture selector and production
fixture count is always zero.

No XCTest identifier is added or renamed. Extend only the existing
`testGateEJournalChainOneWinnerAndPoisonAreExact` method to prove:

- canonical capsule/request framing, exact caps, and exclusive publication;
- one winner under sequential and concurrent consume, permanent poison, and
  no retry;
- suspended supervisor cwd/mapped-image joins and durable start before resume;
- the normal `S -> Ci` shared-session/dedicated-group relation;
- prepublication SID-only discovery while stopped `S` remains alive, plus the
  abrupt-`S` orphan transition accepting either a bound surviving SID member
  or already-empty session/group, followed by exact reap of `S` and final
  session/group emptiness; and
- independent output caps, EOF drains, immutable terminal, and collision
  poison.

The fixture proves mechanics only. It closes no production supervisor image,
Gate-E observation, or roadmap authority. XCTest is not production identity.
The existing production method
`testGateEReleaseSupervisorRequiresLiveFourAuthorityBindingBeforeExit` remains
present for inventory stability but becomes a passing structural closure (or
an explicit skip) before root creation and launches zero processes. It is not
an intentional XCTest failure. Its historical supervisor phase parser names
every status `65...90`; unknown values remain `unknown`. It is never the future
production command.

### Exact outer durable boundary

The future identity-bound production base has two distinct journals:

| Relative leaf | Authority |
| --- | --- |
| `workspace.driver-v2-gate-e-journal` | unchanged inner 16-role journal |
| `gate-e-shot-governor-journal` | exact outer governor journal |

The outer journal is a held, named-vnode-joined mode-`0700` directory on the
same local APFS device as the production base, owned by the exact effective
UID/GID. The governor sets `umask(077)` before any create. The journal has
exactly these four regular leaves in success:

| Ordinal | Exact leaf | Schema / bytes / final mode |
| ---: | --- | --- |
| 0 | `00-capsule.json` | `prime_driver_v2_gate_e_shot_capsule_v1`; exact canonical stdin bytes; at most `262,144`; `0400` |
| 1 | `01-supervisor-request.json` | existing `ergentics_prime_validation_driver_v2_supervisor_launch_request_v1`; exact supervisor stdin bytes; at most `262,144`; `0400` |
| 2 | `02-outer-start.json` | `prime_driver_v2_gate_e_outer_start_v1`; at most `65,536`; `0400` |
| 3 | `03-outer-terminal.json` | `prime_driver_v2_gate_e_outer_terminal_v1`; at most `65,536`; `0400` |

All four are canonical JSON with no trailing line feed. Each publication is
exactly:

```text
openat(journalFD, leaf,
       O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0600)
-> complete write
-> fsync + F_FULLFSYNC
-> fchmod(0400)
-> fsync + F_FULLFSYNC
-> parent-directory fsync + F_FULLFSYNC
-> openat(journalFD, leaf, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
-> rebound vnode + complete bytes/hash/metadata join
-> close the original O_RDWR descriptor
-> retain only the O_RDONLY rebound descriptor
```

Existing leaves poison; there is no replace, rename-over, truncate, repair,
or retry.

Every published leaf descriptor remains held through outer-terminal
finalization. At every authorized transition and at terminal, the governor
revalidates exact descriptor bytes/hash/size/mode, UID/GID, nlink `1`, flags
`0`, no ACL, bounded xattr policy
`set in {empty, {com.apple.provenance}}` with any provenance bytes retained
and unchanged, descriptor/named-vnode equality, exact ordered inventory, and
journal-root identity. Root link count is exactly `2 + publishedLeafCount` and
therefore `6` on success. An unlink/recreate, extra leaf, lost descriptor,
metadata drift, or xattr drift poisons permanently.

No record contains its own digest. The capsule SHA-256 is over the exact bytes
of leaf 0. The request SHA-256 is over leaf 1. The start includes both hashes,
byte counts, vnodes, root/image joins, deadline, and the exact supervisor
PID/SID/PGID. The terminal includes the start SHA-256, exact supervisor wait
and drain facts, the conserved process/session result, and final revalidation.
Its outcome is discriminated: success contains exactly the complete 34-leaf
inner name/hash chain and raw-terminal hash; a contained nonzero contains the
exact immutable prefix of `0...34` leaves and a raw-terminal hash if and only
if that leaf is present; and `contained_zero_semantic_rejection` carries the
exact zero-status wait/drain facts, the same immutable-prefix rule, and the
exact failed journal, semantic, or conservation coordinate. Every incomplete
or rejected prefix leaves `M = 00000000`. The outer terminal's digest is an
external observation made after publication.

The production base also retains exactly two independent mode-`0600`,
no-follow, exclusive captures named `outer-supervisor-stdout.bin` and
`outer-supervisor-stderr.bin`, each capped at `65,536` bytes. Neither is an
authority ledger. Success requires both exact zero-byte SHA-256
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
Before supervisor resume, both output-pipe read descriptors are atomically
adopted by independent drain workers that write through the held capture
descriptors. Overflow poisons success but the affected worker continues
reading and discarding through EOF so containment cannot be blocked by a full
pipe. Final capture descriptor/named-vnode identity, metadata, byte count, and
hash are revalidated before outer-terminal publication.

The capsule frame has `argc == 1`, empty replacement environment, maximum
`262,144` bytes, EOF within `5,000,000,000` nanoseconds, canonical round-trip,
and no trailing line feed. Its fixed fields include schema/artifact kind;
attempt `1`; `rerun_authorized = false`; `local_only = true`; network, fetch,
and GitHub counts `0`; future control/source/companion commit/tree coordinates;
source identity and `548 / 547` cardinality; exact governor, supervisor, and
Git/Swift image declarations; fresh-root and absent-path declarations; and the
existing typed run intent inputs. Decoding restores no
descriptor, watch, lease, process, or capability. There is no capsule-path
loader, environment protocol, subcommand, role selector, caller argv, cwd,
timeout, shell, `Process`, build, list, staging, inventory, or retry surface.

### Governor transition and containment algorithm

The governor is a silent `@main`. Its only executable-target source calls the
closed package entry and maps these statuses exactly:

| Status | Meaning |
| ---: | --- |
| `0` | complete outer terminal and atomic Gate-E success |
| `65` | capsule transport/canonical rejection before live state |
| `66` | capsule, root, tool, or image admission rejection before spawn |
| `67` | capsule/request/start durable-boundary rejection before resume |
| `68` | supervisor spawn, cwd, mapped-image, or session join rejection before resume |
| `69` | post-reap journal, conservation, or semantic rejection |
| `71` | contained nonzero supervisor result; exact supervisor status retained in terminal |
| `72` | contained outer-terminal publication failure |
| `70` | post-spawn containment uncertainty; fixed fail-stop |

The deadline starts before supervisor spawn and is fixed at
`60,000,000,000` nanoseconds. The governor opens its own mapped image; the
exact supervisor, Git, and Swift images; production base; fixed private cwd;
inner and outer journals; captures; and declared roots on held no-follow
descriptors. It hashes and joins the Git/Swift descriptors before spawn,
retains them independently of the supervisor, and rejoins/re-hashes them after
reap to establish outer `A_after`. It
builds and validates the existing supervisor request, publishes capsule and
request exact bytes, then spawns `S` suspended with empty replacement
environment and `argv[0]` only. Before the only resume it proves descriptor
cwd, mapped supervisor-image, `PID=PGID=SID`, named-vnode, root, and start
durability joins and starts both output drains.

Supervisor stdin is the exact durable request vnode, not reconstructed by a
second writer. After leaf 1 is frozen, the governor opens one independent
`O_RDONLY | O_NOFOLLOW | O_CLOEXEC` descriptor, rejoins its vnode and complete
bytes/hash to the retained leaf, sets and verifies offset zero, and uses one
spawn file action to duplicate it to `STDIN_FILENO` and close the original
child-side descriptor. The parent copy of that second input descriptor closes
immediately after successful spawn. The read-only finite file yields EOF after
the exact canonical bytes; no pipe writer, partial write, missing close, or
post-spawn request mutation exists. The retained request-leaf authority
descriptor is the first independent O_RDONLY rebound and is never shared with
the child's file offset.

The supervisor `main.swift`, its request schema, DriverCore intent/image
bridge, facade, role table, and command ceiling remain unchanged.

Normal success requires the supervisor to exact-reap all 16 child PIDs and
prove each child PGID empty. The governor exact-reaps only its direct child
`S`; it never claims `waitpid(Ci)`. It then requires bounded independent EOF
drains, complete inner journal validation, no process with `SID=S`,
`kill(-S, 0) == -1/ESRCH`, every recorded child PGID empty, root/image rejoins,
and conservation before publishing the outer terminal.

On timeout, interruption, supervisor death, or any post-spawn rejection, the
governor retains `S` unreaped while it establishes the containment set. It
uses a fixed `131,072`-PID buffer for a complete duplicate-free
`PROC_ALL_PIDS` scan; capacity equality is uncertainty. It filters only
`getsid(pid) == S`, records PID, start generation/time, PPID, SID, PGID, UID,
and mapped-image identity when available, and groups the result by PGID.
`ESRCH` during a query forces a rescan; `EPERM`, overflow, duplicate identity,
or any other unexplained error is uncertainty.

The stopped fixed point accepts each extant session member only in kernel
status `SSTOP` or `SZOMB`; a zombie cannot and need not be stopped. Stop/death
confirmation uses `PROC_PIDTBSDINFO` plus the governor's exact direct-child
death observation. `waitpid(..., WUNTRACED)` is forbidden because it can reap
an already-exited `S`; the sole wait is the exact frozen reap below.

The failure transition is:

```text
stop and exact-confirm live S, OR confirm S already dead without reaping it
-> enumerate every PID with SID S
-> stop every distinct PGID in SID S
-> rescan to a bounded stable stopped fixed point
-> kill every non-S PGID
-> kill PGID S
-> exact waitpid(S) once
-> require two complete consecutive scans with no SID S member
-> require every captured PID generation absent
-> require kill(-pgid, 0) = -1/ESRCH for every captured PGID
-> bounded independent drains
```

`ESRCH` from the initial group stop is accepted only with an independent
death observation for the exact still-unreaped `S`; it never means
"successfully stopped." Retaining that zombie prevents PID/session reuse until
the census is captured and the one exact `waitpid(S)` occurs.

All scans, stops, kills, the exact wait, and drains remain inside the one
60-second deadline and a maximum of `256` complete scans. A journal match is
validated when present but never selects kill authority. A missing child start
leaf is a valid incomplete prepublication prefix inside `SID=S`; it closes no
authority bit. Failure containment is exact reap of `S` plus kernel-certified
session, identity, and group disappearance—not a false grandchild-reap claim.
Any uncertainty exits `70` and can never be an ordinary rejection or `PASS`.

### Authority and process predicates

The authority coordinates remain:

```text
M = [prime_git, companion_git, swift_version, swift_target_info,
     swiftpm_build, artifact_staging, xctest_inventory,
     swift_testing_inventory]
M_before = 00000000
M_success = 11110000
```

Every incomplete prefix, nonzero supervisor, missing leaf, mutation,
containment uncertainty, or publication failure leaves `M = 00000000`.
Success leaves exactly the final four Gate-F/G coordinates missing.

For

```text
Q = (governor, supervisor, roleStart[1...16], roleTerminal[1...16],
     build, staging, listXCTest, listSwiftTesting,
     extraRunner, fixture, network, fetch, GitHub)
```

the sole production success vector is:

```text
Qsuccess = (1, 1, 1^16, 1^16, 0, 0, 0, 0, 0, 0, 0, 0, 0)
```

SwiftPM and XCTest are absent from the future production-shot hierarchy.
Fixture execution is test-only and must be zero in production. The facade
still exposes zero caller execution parameters; build, list, staging,
inventory, and shard transitions remain absent or unarmed.

The conservation equations are coordinate-wise:

```text
B_before = B_preResume = B_after
A_before = A_after
M_before = 00000000
M_after in {00000000, 11110000}
```

`B` includes exact control/source/companion and fresh-clone identities;
canonical capsule/request bytes; manifests, locks, tools, roots, watches,
governor/supervisor images; prior retained evidence; absent forbidden paths;
and exact inner/outer journal prefixes. `A` is the exact admitted governor,
supervisor, Git, and Swift artifact identity across the direct invocation.
Only explicitly frozen fresh home/tmp/cache, production-root, lease, journal,
and capture transitions are outside equality.

### Source-slice terminal

This source slice authorizes only edits to the twelve paths, two independent
canonical source-identity calculations over the exact successor tree, one
embedded-provenance reseal after the other eleven paths are final, and one
clean source commit. It authorizes no Swift command, test, fixture, governor,
supervisor, Git/Swift child, clone, root, cache, capsule, cleanup, network, or
GitHub operation.

After that source commit, a separate direct-child control checkpoint must
bind its commit/tree, exact twelve-path delta, recomputed identity/cardinality,
and `2,163` watchers. A later finite readiness freeze/result may build and
exercise the package-internal fixture seam and must produce new Release
governor/supervisor/XCTest image identities. Only a still-later production
shot freeze may create one exact capsule and authorize one direct governor
invocation. Gate F and Gate G remain separate and closed.

## Gate E1.4-C1 correction — transferred-continuity watcher join

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_SOURCE_EDIT_NOT_IMPLEMENTED` |
| Durable-control predecessor | `80b873f1129016d2f6506d749594fa81ec088074` / tree `46b4c4d95fe2a75f2480cf4efa318b40eb19822c` |
| Source predecessor | clean `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` / tree `0077ac10f1dbba50680502a31084f7280c2c2f65` |
| Authorized successor source commits | exactly `1`, a direct child of the source predecessor |
| Authorized source paths | exactly `13` |
| Existing preimages / new files / new directories | exactly `10 / 3 / 3` |
| Successor files / identity records / authority directories | exactly `548 / 547 / 155` |
| Prime / companion / combined watcher descriptors | exactly `703 / 1,460 / 2,163` |
| Swift build / test / executable launch | `0 / 0 / 0` in this source slice |
| Clone / root / cache / capsule creation | `0 / 0 / 0 / 0` |
| Dependency resolution / fetch / network / GitHub | `0 / 0 / 0 / 0` |

This correction supersedes only the twelve-path count, exact mutation set,
and twelve-path wording in the E1.4-C source-slice terminal above. Every
other E1.4-C matrix, equality predicate, process ceiling, and prohibition
remains unchanged. The source successor is still one commit, not a second
source commit or a retry.

The hard-stop predicate found before source checkpoint was:

```text
W_success = 548 + 155 + 1,460 = 2,163
W_transferred_continuity_predecessor = 2,157
W_success != W_transferred_continuity_predecessor
```

`PrimeValidationSwiftPMBuildInventoryAdmissionCapability.revalidate()`
reaches `fixedProbeRevalidateTransferredContinuity()` through the retained
owner. Therefore the predecessor literal would reject every otherwise-valid
successor binding. A test cannot override that production predicate.

The corrected exact mutation set is the prior twelve-path set plus exactly:

13. `Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift`.

Its source-predecessor preimage is exact:

| Lines / bytes | Git blob / SHA-256 |
| ---: | --- |
| `2,568 / 97,844` | `dc37b1f041031fa2994b4156630085940e3a512a` / `ab6ebf4bc7629ca901b6bbe5643a556b82995d302b269464c94ffad65b128fb2` |

The authorized delta in that thirteenth path is only the production watcher
join `2_157 -> 2_163` inside
`fixedProbeRevalidateTransferredContinuity()`. The already-authorized live
test path changes its matching production-live expectation to `2_163` and
repairs two manifest source slices so each proves only its intended target:

```text
SpawnCanary target -> terminate at the following GovernorCore .target(
Supervisor target  -> terminate at the following SpawnCanary .executableTarget(
```

Those proof repairs add no product, target, source owner, watcher, authority,
or execution surface. No other active `2_157`, `2157`, `545`, `544`, or `152`
coupling requires mutation. Retired fixture manifests and historical
identities remain byte-for-byte unchanged.

The measured successor topology is:

```text
complete admitted files                    = 548
source-identity records                    = 547
held Prime parent-directory authorities    = 155
Prime watcher descriptors                  = 548 + 155 = 703
companion file+directory watcher descriptors          = 1,460
combined watcher descriptors               = 703 + 1,460 = 2,163
```

The complete `Sources` / `Tests` traversal already captures the three new
files, and the admission owner already requires itself. No required-source
list changes are authorized. After all twelve non-provenance paths are final,
two independent canonical calculations must agree on `548 / 547`, canonical
byte count, and source-identity SHA-256. Only then may the existing provenance
path (entry 12 in the prior ordering)
`PrimeEmbeddedBuildProvenance.swift` receive the matching digest reseal.

The later checkpoint must bind the exact thirteen-path delta and `2,163`
watchers. No Swift command, fixture, governor, supervisor, child, Git probe,
or shot is authorized by this correction.

## Gate E1.4-C2 correction — outer continuity and receipt authority

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_SOURCE_EDIT_NOT_CHECKPOINTED` |
| Durable-control predecessor | `035b56aadbe8a0b9005f24f91cbf645418265f87` / tree `7461b88fa8b865521036b83ed0612c9613a76d23` |
| Source predecessor | clean `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` / tree `0077ac10f1dbba50680502a31084f7280c2c2f65` |
| Authorized successor source commits | exactly `1`, the same direct child already frozen by E1.4-C/C1 |
| Authorized source paths | the same exact `13`; no new path |
| Successor files / identity records / authority directories | exactly `548 / 547 / 155` |
| Prime / companion / combined watcher descriptors | exactly `703 / 1,460 / 2,163` |
| Production authority vector before / success | `00000000 / 11110000` |
| XCTest mechanics authority vector | exactly `00000000` |
| Swift build / test / executable launch | `0 / 0 / 0` in this source slice |
| Clone / root / cache / capsule creation | `0 / 0 / 0 / 0` |
| Dependency resolution / fetch / network / GitHub | `0 / 0 / 0 / 0` |

This correction does not authorize a second source commit, new file, new test
identifier, process execution, or roadmap advance. It corrects implementation
gaps found by three independent static audits before the first source
checkpoint. The matrices and predicates below are authority. A passing test,
record, comment, or normal supervisor exit cannot override a false predicate.

### Audit blocker vector

The candidate is not checkpointable while any coordinate below is false:

```text
C_outer_terminal = governor-owned Prime and companion descriptor/watch
                   continuity remains retained and revalidated through the
                   durable outer terminal
D_one_deadline    = no deadline is created after successful posix_spawn;
                   join, containment, exact reap, and both drains use the
                   same absolute expiry
R_exact_wait      = death is independently observed, then exactly one
                   blocking waitpid(S, ..., 0), retrying EINTR only
J_inner_receipt   = all 34 exact canonical framed inner leaves are retained,
                   named-vnode joined, semantically validated, and revalidated
                   through outer-terminal publication
I_self_image      = the governor's mapped executable vnode joins its held
                   descriptor and declared bytes; proc_pidpath is telemetry
E_empty_env       = the governor's incoming environment is exactly empty
F_capsule         = EOF is observed before the fixed five-second deadline and
                   capsule.source_identity_sha256 equals embedded provenance
P_absence         = every non-authorized declared-absent path is still absent
                   after reap; only the three exact authorized leaves may
                   transition absent -> present
O_ordinary        = production success was ordinary completion and never a
                   containment transition
G_kernel_absence  = only ESRCH proves process-generation/group absence;
                   EPERM or unexplained query failure is exit 70 uncertainty
T_mechanics       = the existing named XCTest dynamically proves outer
                   canonical framing, O_EXCL publication, one-shot/poison,
                   independent caps+EOF drains, and retained terminal joins
                   while spawning zero production processes

checkpointable = C_outer_terminal * D_one_deadline * R_exact_wait
                 * J_inner_receipt * I_self_image * E_empty_env * F_capsule
                 * P_absence * O_ordinary * G_kernel_absence * T_mechanics
```

Every coordinate is Boolean and all are required. The source checkpoint is a
hard stop if any value is unknown.

### Strong primitive boundaries

The existing allowlisted
`Sources/PrimeCore/PrimeValidationDriverV2FixedProbeExecutor.swift` may add
one opaque SPI continuity owner for the separate GovernorCore package. Its
production surface is limited to capture from already-held Prime and
companion root descriptors plus the exact captured Prime source snapshot;
an immutable data-only observation; and zero-argument
`revalidateContinuity()`. It retains complete Prime legacy allowlist and
companion non-`.git` descriptors and watches inside one locked owner. It
exposes no path loader, descriptor, watch, role, argv, environment, process,
lease, facade, or retry capability. GovernorCore must independently join the
captured Prime snapshot to the capsule's exact source identity, `548 / 547`,
and embedded provenance before this owner can close `C_outer_terminal`.

The owner is independent of the supervisor process so `S` death cannot end
the outer watch window. Capture occurs before supervisor spawn; revalidation
occurs before resume, after reap, immediately before terminal publication,
and after the durable terminal join. The owner remains live through the last
check. Prime legacy topology and companion `.git/**` policy remain exactly C;
this correction does not alter the `703 + 1,460 = 2,163` descriptor count.

The existing allowlisted DriverCore binding file may add one package-internal,
value-only inner-journal receipt validator. GovernorCore supplies exact bytes
and descriptor-derived vnode/metadata observations from 34 retained O_RDONLY,
no-follow leaves. DriverCore opens no path and receives no process, facade,
binding lifetime, raw owner, or executable capability. It must strictly
decode and canonical-round-trip the frozen prestart, 16 ordered start, 16
ordered terminal, and raw-terminal schemas; validate exact names/order,
full-frame SHA-256 links, roles, fixed argv/images/roots, `0x408e`,
`PID(Ci)=PGID(Ci)`, `SID(Ci)=S`, unique positive child identities, timing,
wait/EOF/drain/group/continuity facts, output hashes and role facts, and raw
terminal agreement. Its result is non-Codable, Sendable, value-only, and has
no publicly constructible initializer. It is a journal/exit receipt, never a
second semantic binding or owner.

GovernorCore retains the 34 leaf descriptors, exact metadata, xattrs, framed
bytes, names, hashes, and unique vnode vector from first admission through the
outer terminal. It revalidates held descriptor, named vnode, metadata, xattrs,
bytes, inventory, exact prefix, and root `nlink = 36`. The outer success data
binds each inner leaf's descriptor-derived device/inode and one deterministic
journal-receipt identity. This proves post-reap admission continuity. Because
the predecessor inner schemas do not durably carry the writer-held inode
vector, this slice must not claim a stronger publisher-to-governor vnode join.
That residual cannot be papered over by a hash match.

### Exact process and failure corrections

The one outer deadline begins before `posix_spawn`. A successful spawn cannot
construct another deadline. The containment guard distinguishes `armed`,
`exact_reaped`, and `complete`: exact reap alone never disarms drain cleanup.
Both drain completions are attempted under the same deadline even if one
fails. Deinitialization contains when still armed, then finishes both drains;
any uncertainty is fixed exit 70.

The death source is the bounded precondition for the sole blocking exact wait;
the persisted wait options are exactly `0`, never `WNOHANG`. A normal path
that observes an unexpected session member transitions to containment and
sets `ordinary_completion_without_containment = false`. Such a path cannot
produce success even if the supervisor status is zero. Process-generation and
group probes distinguish ESRCH from EPERM and all other failures; only ESRCH
is absence.

The governor requires `ProcessInfo.processInfo.environment.isEmpty` before
live state, verifies time again after EOF, joins the current mapped executable
vnode to the held governor image, and requires capsule source identity equal
to `PrimeEmbeddedBuildProvenance.sourceIdentitySHA256`. After reap it checks
every declared forbidden path except exactly these authorized creations:

```text
productionBase/gate-e-shot-governor-journal
productionBase/outer-supervisor-stdout.bin
productionBase/outer-supervisor-stderr.bin
```

No derived exemption or additional absent-to-present transition is allowed.

### Mechanics-only dynamic proof

Only the existing
`testGateEJournalChainOneWinnerAndPoisonAreExact` identifier may be extended.
It uses already-held descriptors and canonical data through a package-internal
fixture in the existing GovernorCore file. It must reuse the production
capsule decoder, outer journal publisher, finite request descriptor, captures,
drains, and one-shot state machine. It must not invoke current production
identity, `spawnSupervisor`, `posix_spawn`, Git/Swift paths, or any Gate-E
role. Every observation fixes `spawned_process_count = 0`,
`git_or_swift_probe_count = 0`, `production_status_eligible = false`, and
`authority_vector = 00000000`.

The dynamic cases are exact:

1. canonical capsule/request, four distinct held/named outer leaf vnodes,
   request EOF, empty stdout, independently capped-and-drained overflowing
   stderr, immutable terminal, and retained revalidation;
2. sequential second and third consumes reject and permanently poison;
3. LF, insignificant-whitespace, and oversize frames reject before a journal;
4. concurrent consume has one body winner and one rejection, but contention
   leaves the final state permanently poisoned;
5. a new fixture on the same durable root rejects existing outputs without
   replacement;
6. deterministic terminal O_EXCL collision preserves collision bytes/inode,
   leaves only the exact three-leaf prefix, and poisons; and
7. same-byte terminal rebound on a new inode fails retained revalidation and
   poisons.

The one-shot winner may set `complete` only if locked state remains `running`;
a concurrent loser or failed retained revalidation permanently preserves
`poisoned`. The package-internal fixture neither launches the session fixture
nor closes production supervisor identity. The retired production XCTest
remains a skip before work. No new test count or production fixture count is
authorized.

### Checkpoint rule

After all twelve non-provenance paths are final, two independent canonical
calculators must agree on exact `548 / 547`, canonical byte count, and digest.
Only then may the embedded provenance digest change. Static source audits must
then independently establish every blocker coordinate above and verify the
exact thirteen-path delta. The one source commit remains a direct child of
`2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3`. A later separately frozen
readiness run, not this slice, may compile and execute the mechanics proof.
No production governor invocation is authorized by C2.

## Gate E1.4-C3 correction — physical Swift image join

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_SOURCE_EDIT_NOT_CHECKPOINTED` |
| Durable-control predecessor | `6e8bbd55e2304d2adc1340a2d076bae212988a05` / tree `5a0b7c96f3073235c26e0b4214d8beffb61bf0d9` |
| Source predecessor / successor / paths | unchanged from C2: `2d705a71...`, one direct child, exact `13` paths |
| Topology and watchers | unchanged: `548 / 547 / 155`; `703 + 1,460 = 2,163` |
| Swift build / test / executable launch | `0 / 0 / 0` in this source slice |

Static receipt integration established this false candidate equation:

```text
I_swift = intent.swift_executable
        = .../XcodeDefault.xctoolchain/usr/bin/swift

P_swift = fixed Gate-E process image
        = .../XcodeDefault.xctoolchain/usr/bin/swift-frontend

path(I_swift) != path(P_swift)
bytes(I_swift) are not authority for bytes(P_swift)
```

The existing capsule field `swift_executable` is therefore frozen as the
physical `P_swift` declaration, not a duplicate of `I_swift`. Capsule
validation must derive the exact sibling `swift-frontend` path from the
already-validated intent `/swift` path and require the physical binding's
absolute path to equal it. The governor opens, hashes, retains, mapped-vnode
joins, and rejoins that exact physical binding. The inner prestart and every
Swift role must agree with its bytes and vnode.

The intent remains byte-for-byte the logical requested Swift contract and is
still forwarded unchanged to the supervisor. It continues to derive the
developer directory, SDK, deterministic environment, and logical `argv[0] =
swift`. It is never substituted as the executed-image content authority.

Accordingly, the C2 value-only DriverCore expectation must carry both the
complete physical `swift-frontend` executable binding and its descriptor-
derived vnode observation. A vnode without the independently held content
binding is insufficient. Receipt identity includes the physical binding.
DriverCore opens no path and derives no bytes from the inner journal.

This correction changes no capsule schema key, source path, process count,
authority bit, topology, or watcher count. Any implementation retaining
`capsule.swiftExecutable == capsule.intent.swiftExecutable`, comparing a
Swift-role image hash with intent `/swift` bytes, or accepting a vnode-only
frontend expectation is a hard stop. All C2 predicates remain required.

## Gate E1.4-C4 correction — logical path, shared target bytes

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_SOURCE_EDIT_NOT_CHECKPOINTED` |
| Durable-control predecessor | `d31a0b05bb4cddda080ff857fcd0f8208665a58b` / tree `9125d204e6d2ed34e3b2b7644b5baef8e00f188c` |
| Source/path/topology/process ceilings | unchanged from C3 |

This data correction supersedes only C3's statements that the logical
intent's content is not authority for the physical frontend bytes and that
comparing those contents is forbidden. The admitted local toolchain and the
existing admission model establish instead:

```text
lstat(.../usr/bin/swift)       = symlink -> swift-frontend
path(I_swift)                  != path(P_swift)
content(I_swift)               = bytes resolved through the admitted symlink
content(P_swift)               = bytes read from the held physical target
required byte join             = content(I_swift) == content(P_swift)
required physical image join   = mapped vnode == held P_swift vnode
```

Therefore complete binding equality remains false because the absolute paths
differ. Content equality is required, but it is not vnode authority and does
not replace the independently opened no-follow physical binding. Capsule
validation requires the exact derived `/swift-frontend` path and content equal
to the intent's admitted target-byte pin. The governor must still hold,
mapped-vnode join, hash, and rejoin `P_swift`. DriverCore must receive the
complete physical binding plus its descriptor-derived vnode and require both
the content equality and every inner Swift image record to match that physical
binding.

Thus the corrected hard stops are:

```text
capsule.swiftExecutable == capsule.intent.swiftExecutable         // false: path
capsule.swiftExecutable.content != intent.swiftExecutable.content // false: bytes
physical frontend accepted without held/mapped vnode join         // false
```

All other C2/C3 predicates remain required. Prose cannot turn either the path
inequality or the content equality into the other.

## Gate E1.4 source checkpoint — conserved-session shot governor

| Coordinate | Checkpoint value |
| --- | --- |
| Record date | `2026-08-23` |
| Status | `SOURCE_CHECKPOINTED_STATIC_ONLY_NOT_EXECUTED` |
| Durable-control predecessor | `051a1af77db8b0e869e735e1787abfb09f660b2e` / tree `6b39ca269c5eece03af1f4cf40dba0a2ce9b7ee3` |
| Source predecessor | `2d705a71dc1827cf4fe6f0f9f3bc8255063e1dd3` / tree `0077ac10f1dbba50680502a31084f7280c2c2f65` |
| Source checkpoint | `4735739b10a699ebc1ef3b4dc87a209fb5189834` / tree `c44c7ae54cffa95a9d2c705191c542fa1ceda5db` |
| Source-parent relation | exactly one direct child; parent count `1` |
| Source delta | exactly `13` paths: `10` modified + `3` added, all mode `100644` |
| Swift build / test / executable launch | `0 / 0 / 0` |
| Supervisor / child / Git / Swift process count | `0 / 0 / 0 / 0` |
| Dependency resolution / fetch / network / GitHub | `0 / 0 / 0 / 0` |
| Current authority vector, with no E receipt | `00000000` |
| Runtime E scientific outcome | `ABSTAIN` — no execution evidence exists |
| Gate-E clearance granted | `0` |

The exact source delta is:

```text
M  Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift
M  Sources/PrimeCore/PrimeSecureChildDarwinSubstrate.swift
M  Sources/PrimeCore/PrimeSecureChildLifecycle.swift
M  Sources/PrimeCore/PrimeSecureChildSupervision.swift
M  Sources/PrimeCore/PrimeValidationDriverV2FixedProbeExecutor.swift
M  Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift
M  Tests/PrimeValidationWorkflow/Package.swift
M  Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore/PrimeValidationDriverV2FixedProbeBinding.swift
A  Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2SessionFixture/main.swift
A  Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernor/main.swift
A  Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernorCore/PrimeValidationDriverV2ShotGovernor.swift
M  Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationDriverV2AdmissionTests.swift
M  Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift
```

No other tracked, untracked, staged, or unstaged source path remained after
the checkpoint. The existing production supervisor `main.swift` is unchanged
from the predecessor; both bytes have SHA-256
`a6ee17b234abcd789d839abadd5f5a551ecabe99d731186c566422f46e6276d2`.

### Measured source identity and topology

Two independent implementations, Python and Ruby, traversed the frozen Prime
allowlist and independently emitted the same canonical identity data:

| Quantity | Python | Ruby | Required equality |
| --- | ---: | ---: | ---: |
| Admitted files | `548` | `548` | `548` |
| Identity records, excluding provenance | `547` | `547` | `547` |
| Canonical record bytes | `112,279` | `112,279` | `112,279` |
| Aggregate admitted source bytes | `22,457,455` | `22,457,455` | equal |
| Source identity SHA-256 | `74354d4581835d12f0624d0455e8167a4d608a5eecb8427debbe894a88a16ad2` | same | same |
| Held Prime authority directories | `155` | `155` | `155` |
| Prime watchers | `548 + 155 = 703` | same | `703` |
| Combined watchers | `703 + 1,460 = 2,163` | same | `< 4,096` |

Only after both identity calculations agreed was embedded provenance resealed.
Its exact canonical template is `546` bytes with SHA-256
`24362ede89c59ed536287c81755de5f9811d4c40279f2c5a38d87afcf90233a0`.
Both implementations rechecked the identity after reseal; the digest is
unchanged because the provenance file is the sole excluded record.

### Static closure vector

The source checkpoint and an E execution are separate mathematical objects:

```text
S_scope_identity      = 1
S_process_primitives  = 1
S_outer_continuity    = 1
S_receipt_join        = 1
S_zero_process_tests  = 1
S_reap_lifecycle      = 1

source_checkpoint = product(S_*) = 1

R_outer_terminal = ABSTAIN
R_one_deadline    = ABSTAIN
R_exact_wait      = ABSTAIN
R_inner_receipt   = ABSTAIN
R_self_image      = ABSTAIN
R_empty_env       = ABSTAIN
R_capsule         = ABSTAIN
R_absence         = ABSTAIN
R_ordinary        = ABSTAIN
R_kernel_absence  = ABSTAIN
R_mechanics       = ABSTAIN

gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted  = 0
```

Independent static audits found no remaining source blocker. In particular:

- Prime and companion continuity are owned by the governor independently of
  the supervisor and remain retained through the outer-terminal join.
- DriverCore receives value-only retained inner-journal data and cannot open a
  path or recover a process, facade, role, argv, environment, cwd, timeout,
  session, group, or command capability.
- The logical `swift` path and physical held `swift-frontend` path remain
  unequal while their admitted target bytes must be equal; mapped-image
  authority remains the held physical frontend vnode.
- The production guard is the four-state transition
  `armed -> exactReapCompleted -> conservationCompleted -> drainsCompleted`.
  The sole exact `waitpid(S, ..., 0)` marks exact reap immediately. A later
  failure enters a separate no-wait SID/group containment pass, then completes
  both drains under the original deadline. It cannot wait for `S` twice.
- The no-wait pass stops a stable `SID == S` fixed point, kills every captured
  group including `S`, requires two empty scans, and accepts only `ESRCH` for
  captured-generation and group absence. The session fixture has the same
  armed/exact-reaped/conservation-complete split.
- The existing mechanics XCTest identifier contains all seven frozen
  zero-process cases. Its observation fixes spawned/probe counts to zero,
  production eligibility false, and authority vector `00000000`. The retired
  production XCTest still skips before any root or process is created.

The final lifecycle audit anchors are:

```text
GovernorCore SHA-256 = 0c8f41eea642ce63895e8810641ab674de1c2530da4a9a6d2142efc155b44811
LiveTests SHA-256    = 4a1b89ca13afe168719acb91f5c45e58b377cd7f3bf5375bb429d8cdbf4f5d35
```

### Authority boundary and next transition

This record checkpoints source bytes only. It is not a Gate-E receipt, does
not make XCTest a production supervisor, and closes none of the eight
process-derived roadmap authorities. No governor, supervisor, session
fixture, Git probe, Swift probe, or child was launched. GitHub is neither an
actor nor a venue in this checkpoint.

The only next transition supported by this record is a separately frozen,
local, bounded readiness slice on source `4735739b10a699ebc1ef3b4dc87a209fb5189834`
and tree `c44c7ae54cffa95a9d2c705191c542fa1ceda5db`: first compile and run the
mechanics-only proof, then assess production Release-shot readiness. That
later authority must name its roots, binaries, capsule, journal leaf, deadline,
and one-shot policy before execution. It must not infer E clearance from this
source commit, and it must not use GitHub as the scientific executor.

## Gate E1.4-R0 freeze — mixed Release mechanics readiness

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | `b67601afd8d4392d96306e63113ab2476ed9f57d` / tree `94eda07cbc6e2fb12543827f7c935e3984b04a70` |
| Permitted control delta | this section only, in this one durable-control path |
| Source commit/tree | clean `4735739b10a699ebc1ef3b4dc87a209fb5189834` / `c44c7ae54cffa95a9d2c705191c542fa1ceda5db` |
| Source identity/cardinality | `74354d4581835d12f0624d0455e8167a4d608a5eecb8427debbe894a88a16ad2`; `548 / 547 / 112,279` |
| Source watcher arithmetic | `703 + 1,460 = 2,163 / 4,096` |
| Configuration/platform | Release / arm64 / macOS `26.5.2` build `25F84` |
| Authorized SwiftPM commands | exactly `2`, ordered `build-tests -> skip-build test`; one attempt each |
| Selected XCTest methods | exactly `1`; one XCTest runner; zero Swift Testing runners |
| Production governor/supervisor/fixed-role attempts | `0 / 0 / 0` |
| Dependency resolution/fetch/network/GitHub | `0 / 0 / 0 / 0` |
| Overall outer readiness ceiling | `5,400` seconds; build at most `4,800`, test at most `600` |
| Production Gate-E outcome before/after this readiness slice | `ABSTAIN / ABSTAIN` |

Data precedence is exact. In particular, the selected XCTest method is not
process-free. Its outer-journal observation is zero-process, but the enclosing
method also runs two test-only conserved-session fixture modes. The accepted
runtime topology is:

```text
SwiftPM build invocation                         = 1
SwiftPM test invocation                          = 1
XCTest runner                                    = 1
SessionFixture supervisor image instances        = 2
SessionFixture passive child image instances     = 2

production ShotGovernor launches                 = 0
production DriverV2Supervisor launches           = 0
Gate-E fixed Git/Swift role launches              = 0
DriverV2SpawnCanary launches                      = 0
FixtureChild launches                             = 0
SecureChildIntegration launches                   = 0
network/fetch/GitHub operations                   = 0
```

Each of the two fixture-seam calls performs one `posix_spawn` of a supervisor.
Each supervisor performs one `posix_spawn` of the same held image as a passive
zero-argument child in a dedicated process group. A successful full method
therefore creates exactly two fixture supervisors plus two children. Every
successfully returned `PrimeValidationDriverV2OuterJournalMechanicsObservation`
must report `spawned_process_count = 0`, `git_or_swift_probe_count = 0`,
`production_status_eligible = false`, and `authority_vector = 00000000`.
Rejection, collision, and rebound cases throw and return no observation; they
must not be described as reporting those fields.
The XCTest runner and SwiftPM infrastructure are harness processes, never
Gate-E roles. SwiftPM may invoke the admitted Xcode Git helper for read-only
local package planning against the pinned existing stores; that is harness
telemetry, not a Gate-E Git role. Fetch, network, and repository mutation
remain forbidden. Any prose calling the whole method zero-process is false.

### Frozen inputs, epoch, and build preimages

| Item | Exact frozen value |
| --- | --- |
| Readiness epoch | `/private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12`; absent before this freeze |
| Epoch children | `home`, `config`, `tmp`, `git-template`, `swiftpm-cache`, `swiftpm-config`, `swiftpm-security`, `clang-module-cache`, `swiftpm-module-cache`; all absent with the epoch |
| Reserved production root | `/private/tmp/prime-driver-v2-gate-e-release-74354d4581835d12f0624d0455e8167a4d608a5eecb8427debbe894a88a16ad2`; absent and forbidden |
| Package build root | existing default `Tests/PrimeValidationWorkflow/.build`; device/inode `16777231/17179422` |
| Workspace state | `1,704` bytes; SHA-256 `8eeb391d590b20e5eec603ab9d078757f2106a29467a7ff079194278bba921bf` |
| Release SessionFixture preimage | absent |
| Release XCTest preimage | `56,562,128` bytes; device/inode `16777231/17361530`; SHA-256 `c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712` |
| Root manifest/lock SHA-256 | `fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81` / `bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375` |
| Nested manifest/lock SHA-256 | `753f42251e768faaee3686da38e6f6bf7de048526199445f0e11c088af53dada` / `d70a43567cbd3be75083ab147020b86b055513020d95632f8286f60913c9374a` |
| MLX checkout | clean `d37885a278f1c37484a94d0f401a418735e66519` / tree `5310749549cca107fc1bb07d82dacf043bc02b9e` |
| Numerics checkout | clean `0c0290ff6b24942dadb83a929ffaaa1481df04a2` / tree `4560bfb65f2c26cbd159c3e1a9cbf01600bace1b` |
| SessionFixture source SHA-256 | `c42e91519d8a792145a7478963e56ec92ddb7bdbf709a960b363241fd88305ab` |
| LiveTests source SHA-256 | `4a1b89ca13afe168719acb91f5c45e58b377cd7f3bf5375bb429d8cdbf4f5d35` |
| GovernorCore source SHA-256 | `0c8f41eea642ce63895e8810641ab674de1c2530da4a9a6d2142efc155b44811` |

The Xcode Swift launcher is the exact symlink
`.../usr/bin/swift -> swift-frontend`. The physical frontend is device/inode
`16777231/1118375`, `171,036,592` bytes, SHA-256
`2ed38571e92c0283091838c1649e27650ad9c99950288e883c7b2dc6c4ce89fb`.
The developer directory is `/Applications/Xcode.app/Contents/Developer`; the
SDK is the canonical directory
`/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk`,
device/inode `16777231/1009705`.

No external or fresh scratch path is permitted. The explicit scratch path must
equal the package's existing default `Tests/PrimeValidationWorkflow/.build`.
The XCTest source deliberately resolves the held SessionFixture image beneath
that exact `.build/arm64-apple-macosx/release` path. Command 1 must create the
previously absent image and a fresh test bundle before command 2. The existing
checkout and repository stores are retained inputs; automatic resolution is
disabled, and any fetch marker, lock drift, checkout drift, or workspace-state
drift is a hard stop.

Before command 1, create the epoch and nine children exactly once with mode
`0700`, rejoin their no-follow path/device/inode identities, and require the
Git template empty. The pre-existing unrelated temporary root
`/private/tmp/prime-validation-admission-tests-20260803-c` is retained. Record
the exact inventories of `/private/tmp/prime-validation-admission-tests-*`
and `/private/tmp/prime-validation-public-admission-*` before and after the
test; the method's eight UUID fixture roots must all be removed before return.
No production capsule, production journal, production clone, companion root,
or production evidence root is an input or authorized output here.

### Exact ordered command environment

Both commands run from the clean source worktree with `umask 077`, stdin
`/dev/null`, and this exact finite `env -i` map:

```text
HOME=/private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/home
CFFIXED_USER_HOME=/private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/home
XDG_CONFIG_HOME=/private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/config
TMPDIR=/private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/tmp/
USER=ergentics
LOGNAME=ergentics
LANG=C.UTF-8
LC_ALL=C.UTF-8
TZ=UTC
TERM=dumb
NO_COLOR=1
PATH=/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:/usr/bin:/bin
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
GIT_EXEC_PATH=/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core
GIT_CONFIG_NOSYSTEM=1
GIT_CONFIG_GLOBAL=/dev/null
GIT_ATTR_NOSYSTEM=1
GIT_CONFIG_COUNT=6
GIT_CONFIG_KEY_0=core.hooksPath
GIT_CONFIG_VALUE_0=/private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/git-template
GIT_CONFIG_KEY_1=init.templateDir
GIT_CONFIG_VALUE_1=/private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/git-template
GIT_CONFIG_KEY_2=core.attributesFile
GIT_CONFIG_VALUE_2=/dev/null
GIT_CONFIG_KEY_3=checkout.workers
GIT_CONFIG_VALUE_3=1
GIT_CONFIG_KEY_4=maintenance.auto
GIT_CONFIG_VALUE_4=false
GIT_CONFIG_KEY_5=gc.auto
GIT_CONFIG_VALUE_5=0
GIT_ALLOW_PROTOCOL=file
GIT_PROTOCOL_FROM_USER=0
GIT_OPTIONAL_LOCKS=0
GIT_TERMINAL_PROMPT=0
GIT_LFS_SKIP_SMUDGE=1
GIT_NO_LAZY_FETCH=1
GIT_NO_REPLACE_OBJECTS=1
CLANG_MODULE_CACHE_PATH=/private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/clang-module-cache
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/swiftpm-module-cache
```

Run command 1 exactly once:

```sh
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift build \
  --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow \
  --configuration release --build-tests \
  --scratch-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build \
  --cache-path /private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/swiftpm-cache \
  --config-path /private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/swiftpm-config \
  --security-path /private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/swiftpm-security \
  --disable-netrc --disable-keychain --force-resolved-versions \
  --disable-automatic-resolution --disable-sandbox </dev/null
```

Command 2 is forbidden unless command 1 exits `0`, the Release
SessionFixture and XCTest bundle exist as newly built regular arm64 Mach-O
images, and all frozen inputs remain joined and unchanged. SessionFixture must
make the frozen `absent -> present` transition; the XCTest hash must differ
from `c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712`,
and both images' mtimes/ctimes must fall inside command 1's measured interval.
Then run command 2 exactly once:

```sh
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift test \
  --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow \
  --configuration release --skip-build \
  --scratch-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build \
  --cache-path /private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/swiftpm-cache \
  --config-path /private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/swiftpm-config \
  --security-path /private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12/swiftpm-security \
  --disable-netrc --disable-keychain --force-resolved-versions \
  --disable-automatic-resolution --disable-sandbox --disable-swift-testing \
  --filter '^PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEJournalChainOneWinnerAndPoisonAreExact$' \
  </dev/null
```

The build may compile and link all six package executable products; none may
be launched by command 1. Command 2 may evaluate the plugin-free manifests but
must contain no package-target compile or link marker. Starting either command
consumes that command's attempt. A nonzero exit, timeout, or hard-stop fact
forbids the later command or any same-epoch retry. Retain the epoch and build
outputs after any result.

### Acceptance and claim ceiling

Command 2 acceptance requires shell exit `0`; exact observed method multiset
equal to the one frozen identifier; `1` executed, `1` passed, zero failures,
zero skips; zero Swift Testing runner; 34 immutable inner leaves with root
nlink `36`; four immutable outer leaves with root nlink `6`; finite request
EOF; stdout `0`; independently drained capped stderr `65,536` with overflow
and EOF; permanent one-shot poison; same-byte/new-inode rejection; and both
fixture modes proving mapped image, held cwd, exact supervisor reap, final
session emptiness, and final captured-group absence.

After command 1 and command 2, record the SessionFixture, ShotGovernor,
DriverV2Supervisor, and XCTest images by no-follow path/device/inode join,
byte count, SHA-256, Mach-O architecture, UUID/load commands, ownership, mode,
link count, flags, ACL, and xattrs. Record all other rebuilt products as build
telemetry. Require source/control worktrees and both dependency checkouts
clean; exact manifest, lock, workspace-state, source, tool, and reserved-root
facts unchanged; the epoch roots rejoined; Git template empty; and temporary
prefix inventories restored exactly.

Only the following result transition is available after a clean pass:

```text
R_mixed_test_host_mechanics = PASS
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

It establishes Release compilation plus test-host journal and conserved-
session mechanics. It does not establish the production governor self-image,
empty environment, capsule transport, production deadline, outer production
terminal, sixteen fixed-role receipts, Git/Swift observations, or any roadmap
authority bit. Its only possible successor is a separate production
Release-shot readiness assessment and freeze; this R0 record authorizes no
production invocation.

## Gate E1.4-R0 result — Release testability stop before XCTest

| Coordinate | Observed value |
| --- | --- |
| Executed freeze | `72cc0a489bb39384e4166cc05dd76ef187c55dc0` / tree `b6f550c75772858dca32c88718421c6e6635a3e8` |
| Status | `STOPPED_COMMAND_1_BUILD_FAILURE_COMMAND_2_FORBIDDEN` |
| Command 1 / command 2 attempts | `1 / 0` |
| Command 1 exit | `1` |
| Observed bounding interval | `2026-08-23T15:53:29Z` through `2026-08-23T15:57:52Z`; at most `263` seconds |
| Frozen selector count / executed / passed / failed / skipped XTests | `1 / 0 / 0 / 0 / 0` |
| XCTest / Swift Testing runners | `0 / 0` |
| SessionFixture supervisors / children launched | `0 / 0` |
| Production governor/supervisor/fixed roles | `0 / 0 / 0` |
| Production root | absent before and after |
| Dependency fetch/network/GitHub | `0 / 0 / 0` |

The exact terminal compiler diagnostic was:

```text
PrimeValidationWorkflowContractsTests.swift:6:18: error:
module 'PrimeValidationWorkflowContracts' was not compiled for testing
@testable import PrimeValidationWorkflowContracts
```

The Release `swift build --build-tests` command compiled and linked the new
SessionFixture, then reached PrimeCore and the contracts test target. This
SwiftPM/toolchain combination did not make the Release contracts library
testable under `build --build-tests`, so compilation stopped before the live
test object, test bundle replacement, XCTest, or any fixture invocation. No
same-epoch retry and no `--skip-build` test was permitted.

Measured build outputs are:

| Image | R0 terminal fact |
| --- | --- |
| SessionFixture | frozen `absent -> present`; device/inode `16777231/17382060`; `53,072` bytes; SHA-256 `177a18c20bc42486c77b52af4c472be222dec1baabf8973ece7b2d44ea92756e`; arm64 UUID `2EBB880A-D28B-32FF-9B7E-EB868AF5D9B6`; mode `0700`; mtime/ctime `1787500441/1787500441` |
| ShotGovernor | absent |
| DriverV2Supervisor | retained pre-R0 image; SHA-256 `57bae5845d7b2ad108309d623902bd7a68688c7882e1649ca23f8a93764dfafe`; no R0 replacement |
| XCTest bundle executable | retained exact preimage `c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712`; no R0 replacement |

The source commit/tree remained clean and exact. All four manifest/lock hashes,
the `1,704`-byte workspace-state hash, three changed-source hashes, Xcode tool
facts, and both dependency commit/tree pairs remained exact. Both dependency
checkouts remained clean. The Git template remained empty; the temporary
prefix inventory before and after remained exactly the retained
`/private/tmp/prime-validation-admission-tests-20260803-c` root and no public-
admission root. The R0 epoch is retained at device/inode
`16777231/17381583`; no child root was rebound.

The only valid result vector is:

```text
R0_release_build_tests = FAIL
R0_mixed_test_host_mechanics = ABSTAIN
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

This is a readiness-command incompatibility, not a GitHub failure, production
shot, fixture failure, or Gate-E scientific result. It does not establish that
later source files compile because the compiler stopped earlier in the graph.

## Gate E1.4-R1 successor freeze — one Release `swift test`

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | R0 freeze `72cc0a489bb39384e4166cc05dd76ef187c55dc0` / tree `b6f550c75772858dca32c88718421c6e6635a3e8` plus the R0 observations immediately above |
| Permitted control delta | this combined R0 result and R1 successor freeze only |
| Source commit/tree/identity | unchanged `4735739b10a699ebc1ef3b4dc87a209fb5189834` / `c44c7ae54cffa95a9d2c705191c542fa1ceda5db` / `74354d4581835d12f0624d0455e8167a4d608a5eecb8427debbe894a88a16ad2` |
| R1 epoch | `/private/tmp/gate-e1-4-mechanics-r1-4735739b-74354d4581835d12`; absent before this freeze |
| Authorized SwiftPM commands | exactly `1`: Release `swift test`, not `build --build-tests`, not `--skip-build` |
| Selected XCTest methods | the same exact one anchored identifier |
| R1 wall ceiling | `5,400` seconds |
| Production attempts | `0` |
| Fetch/network/GitHub | `0 / 0 / 0` |

R1 corrects only the failed outer build command. `swift test` owns both the
testable Release compilation and, only if that compilation succeeds, the exact
one-method XCTest execution. No source, target, test identifier, process
policy, authority bit, or production input changes.

Create the fresh R1 epoch and the same exact nine private `0700` children as
R0. Define `rho1` as replacement of the sole root string

```text
/private/tmp/gate-e1-4-mechanics-4735739b-74354d4581835d12
```

with

```text
/private/tmp/gate-e1-4-mechanics-r1-4735739b-74354d4581835d12
```

throughout the exact R0 `env -i` map and cache/config/security CLI paths. Every
other environment key and value is byte-for-byte unchanged. The package path,
explicit default scratch path, manifests, locks, workspace state, checkouts,
Xcode tool/SDK paths, `umask 077`, stdin `/dev/null`, and reserved production-
root absence are unchanged.

Run this command exactly once:

```sh
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift test \
  --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow \
  --configuration release \
  --scratch-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build \
  --cache-path /private/tmp/gate-e1-4-mechanics-r1-4735739b-74354d4581835d12/swiftpm-cache \
  --config-path /private/tmp/gate-e1-4-mechanics-r1-4735739b-74354d4581835d12/swiftpm-config \
  --security-path /private/tmp/gate-e1-4-mechanics-r1-4735739b-74354d4581835d12/swiftpm-security \
  --disable-netrc --disable-keychain --force-resolved-versions \
  --disable-automatic-resolution --disable-sandbox --disable-swift-testing \
  --filter '^PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEJournalChainOneWinnerAndPoisonAreExact$' \
  </dev/null
```

The R0 SessionFixture image is only R1's frozen preimage, not launched-image
authority. A normal Release `swift test` may rebuild and relink it because the
test graph enables testability across package targets. There is deliberately no
outer pause between compilation and XCTest. Prelaunch image authority is the
test's internal `O_NOFOLLOW` held descriptor plus mapped-image join; the outer
observer records the final image after the complete command. The transcript
must account for either exact retention or the preimage-to-successor
transition. The XCTest bundle must replace its old
`c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712`
preimage inside R1 and contain the new source identity and exact selected
method. Any compile error prevents XCTest and yields `ABSTAIN`; it does not
authorize a retry.

R1 retains the exact R0 mixed-method process envelope: one XCTest runner, two
SessionFixture supervisors, two passive children, and zero production
Governor, production Supervisor, fixed Git/Swift role, spawn-canary,
FixtureChild, or SecureChildIntegration launches. SwiftPM may use local Git
only for read-only package planning; fetch, network, and mutation remain hard
stops. The same eight ephemeral fixture bases must restore the pre-command
temporary-prefix inventory before return.

Acceptance and the claim ceiling are otherwise exactly R0. A pass may set only
`R_mixed_test_host_mechanics = PASS` while retaining authority vector
`00000000`, production attempt count `0`, Gate-E scientific outcome `ABSTAIN`,
and Gate-E clearance `0`. R1 authorizes no production invocation.

## Gate E1.4-R1 result — ShotGovernorCore compile stop before XCTest

| Coordinate | Observed value |
| --- | --- |
| Executed freeze | `c5eb2913f6461ba94b82b4c0a64925bf55ad7622` / tree `6e129d3a7d7e6fa884469055f23439ac2b797c08` |
| Status | `STOPPED_RELEASE_SWIFT_TEST_COMPILE_FAILURE_BEFORE_XCTEST` |
| Authorized / attempted SwiftPM commands | `1 / 1` |
| Command exit | `1` |
| Observed bounding interval | `2026-08-23T16:05:30Z` through `2026-08-23T16:09:24Z`; at most `234` seconds |
| Frozen selector count / executed / passed / failed / skipped XTests | `1 / 0 / 0 / 0 / 0` |
| XCTest / Swift Testing runners | `0 / 0` |
| SessionFixture supervisors / passive children launched | `0 / 0` |
| Production governor / supervisor / fixed-role launches | `0 / 0 / 0` |
| Compiler/linker process census | `ABSTAIN`; build transcript and terminal only |
| Dependency fetch / network / GitHub | `0 / 0 / 0` |

R1's one-command invocation passed the exact R0 Release-testability failure
point, compiled the contracts test target, and then stopped in the new
ShotGovernor core at five compiler diagnostics generated by four source
constructs:

```text
line 782:  fcntl(descriptor, F_GETPATH, pointer)
           error: variadic function is unavailable
line 785:  error: nil requires a contextual type
line 1500: lhs == try rhs
           error: try cannot appear to the right of a non-assignment operator
lines 3467 and 5195:
           posix_spawn_file_actions_addfchdir is macOS 26.0+
           while the package deployment floor is macOS 14
```

The final terminal was `error: fatalError`. The package test bundle was not
rebuilt, no XCTest runner started, and the selected method's fixture calls
were unreachable. This is source compile evidence, not a mechanics failure or
a Gate-E process result. Swift compiler and linker processes are SwiftPM
harness infrastructure and are not counted as package-product launches.
The zero package-product launch counts derive from the stopped SwiftPM build
graph and absence of XCTest or product-launch markers; they are not a claim of
a complete host process census.

### R1 artifact and conservation data

| Image | Exact terminal fact |
| --- | --- |
| SessionFixture | retained R0 preimage at device/inode `16777231/17382060`; `53,072` bytes; SHA-256 `177a18c20bc42486c77b52af4c472be222dec1baabf8973ece7b2d44ea92756e`; UUID `2EBB880A-D28B-32FF-9B7E-EB868AF5D9B6`; no R1 relink |
| ShotGovernor | absent; its core did not compile |
| DriverV2Supervisor | preimage device/inode `16777231/17361435`, `47,679,960` bytes, SHA-256 `57bae5845d7b2ad108309d623902bd7a68688c7882e1649ca23f8a93764dfafe`, UUID `02CCEC13-5745-3245-AF0F-E2A49D4A68C4` -> R1 testability successor device/inode `16777231/17383408`, `48,029,880` bytes, SHA-256 `679a05556327e3cb624da7dc2b27b90d43e5520adbbd3059272c3e3ca78b7e97`, UUID `83641101-BC44-3F1C-B718-DEAC3F1B82BC`; mtime/ctime `1787501354/1787501354` |
| XCTest bundle executable | retained exact preimage at device/inode `16777231/17361530`; `56,562,128` bytes; SHA-256 `c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712`; UUID `F62F4215-B00C-30C0-B7B2-43BF6924B73D`; no R1 replacement |
| SpawnCanary build telemetry | device/inode `16777231/17383068`; `34,664` bytes; SHA-256 `3c864510bac0b80d43612b5fafddbcee13de502851b2efac38ad0dc481c3429b`; UUID `55804C6D-58CE-3059-B783-6D35AA17A8AA`; mtime/ctime `1787501167/1787501167` |
| SecureChildIntegration build telemetry | device/inode `16777231/17383340`; `51,271,120` bytes; SHA-256 `48ca1e187e6ecfc4eb9af0abadb4b16141ce799b2191f230afc7f3d8aa374f1b`; UUID `AE01FAC1-0C46-36BC-BCD7-5FD9C3CEAC5F`; mtime/ctime `1787501338/1787501338` |

All present recorded images are regular arm64 Mach-O objects with minimum OS
`14.0`, mode `0700`, one link, no flags or ACL, and the sole xattr
`com.apple.provenance`. The R1 Supervisor, SpawnCanary, and
SecureChildIntegration timestamps fall inside the measured R1 interval.

The fresh R1 epoch was created once at device/inode `16777231/17382595`, mode
`0700`, with the exact nine child inodes `17382596...17382604`. Those vnodes
remain joined and the epoch is retained. Cache, home, config, and tmp contents
changed only as authorized SwiftPM harness state; the exact Git template is
still empty. The scoped admission before/after inventory is exactly the
retained `/private/tmp/prime-validation-admission-tests-20260803-c` root; the
scoped public-admission inventory is empty. Separately, the two previously
recorded historical production roots
`/private/tmp/prime-driver-v2-gate-e-release-194cf7141172ee06b5f9734af2e9c3df498547a2f718698ccd421ef7ae961d0f`
and
`/private/tmp/prime-driver-v2-gate-e-release-afb3c46461736ddf7b275d797d054000d260eeebc0c6c50a7a94451ef1c97a19`
remain present. The exact reserved R1 production root with identity
`74354d4581835d12f0624d0455e8167a4d608a5eecb8427debbe894a88a16ad2`
was absent before and after. No statement here claims global production-root
absence.

Source stayed clean at `4735739b10a699ebc1ef3b4dc87a209fb5189834` /
tree `c44c7ae54cffa95a9d2c705191c542fa1ceda5db`. The four manifest/lock
digests, `1,704`-byte workspace state, three source digests, both dependency
commit/tree pairs, and both clean dependency worktrees remained exact. The
control worktree stayed clean at the executed freeze until this result was
written.

The only valid R1 vector is:

```text
R1_release_test_compile = FAIL
R1_selected_xctest = NOT_STARTED
R1_mixed_test_host_mechanics = ABSTAIN
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

R1's epoch and command attempt are consumed. There is no same-source retry,
no production invocation, and no inference from relinked build telemetry.

## Gate E1.4-R2 freeze — descriptor and deployment source repair

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_SOURCE_REPAIR_NOT_IMPLEMENTED` |
| Durable-control predecessor | R1 freeze `c5eb2913f6461ba94b82b4c0a64925bf55ad7622` / tree `6e129d3a7d7e6fa884469055f23439ac2b797c08` plus the exact R1 result above |
| Source predecessor | clean `4735739b10a699ebc1ef3b4dc87a209fb5189834` / tree `c44c7ae54cffa95a9d2c705191c542fa1ceda5db` |
| Authorized successor source commits | exactly `1`, a direct child of the source predecessor |
| Authorized source paths | exactly `2` |
| Swift build / test / executable launch in this slice | `0 / 0 / 0` |
| Root / cache / capsule / journal creation | `0 / 0 / 0 / 0` |
| Dependency resolution / fetch / network / GitHub | `0 / 0 / 0 / 0` |
| Authority vector before / after | `00000000 / 00000000` |

The two-path allowlist is:

1. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernorCore/PrimeValidationDriverV2ShotGovernor.swift` — only the four compiler-coordinate repairs below; and
2. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` — only the final canonical source-identity digest reseal after path 1 is final.

Their exact preimages are:

| Path | Frozen preimage |
| --- | --- |
| ShotGovernor core | `5,430` lines / `208,016` bytes; blob `1c60bdb3968b042dfc190af58cf735bccb554acc`; SHA-256 `0c8f41eea642ce63895e8810641ab674de1c2530da4a9a6d2142efc155b44811` |
| Embedded provenance | `13` lines / `546` bytes; blob `42a0154888ea44ca86160bdd5ea93ef527ec75b7`; SHA-256 `24362ede89c59ed536287c81755de5f9811d4c40279f2c5a38d87afcf90233a0` |

The authorized source repair is exact:

1. replace only the test-descriptor directory's unavailable variadic
   `F_GETPATH` use with the already-used descriptor kernel primitive
   `proc_pidfdinfo(..., PROC_PIDFDVNODEPATHINFO, ...)`; centralize a helper
   requiring the return to equal exactly
   `MemoryLayout<vnode_fdinfowithpath>.size`, the first NUL to occur after
   byte zero and before the `withUnsafeBytes` buffer count, UTF-8 decoding of
   only the preceding bytes, `isSafeAbsolutePath(value)`, and
   `canonicalPath(value) == value`;
   the helper returns only that observed path string, while the existing
   constructor-specific leaf checks and held-descriptor versus named-path
   device/inode, metadata, xattr, and content revalidation remain unchanged;
2. split the two throwing exact-byte reads at `request_input_join` into named
   values after the metadata join, then compare those values; do not weaken
   the byte equality, exact size, EOF, or rewind checks;
3. add one closed descriptor-only working-directory spawn-action helper with
   one lexical `if #available(macOS 26.0, *)`: its true branch calls only
   `posix_spawn_file_actions_addfchdir`, and its false branch calls only
   `posix_spawn_file_actions_addfchdir_np`; use it at the two existing action
   sites without compile-time platform selection, symbol lookup, a named-path
   cwd, caller input, or a second spawn; and
4. remove no admission, durability, image, cwd, deadline, drain, exact-reap,
   group-absence, continuity, poison, or exit-70 predicate.

No C shim, `@_silgen_name` fcntl declaration, `/dev/fd` path recovery,
`FileManager`, `Process`, shell, caller path, argv, environment, role,
timeout, command surface, or deployment-floor increase is permitted. The
standard/`_np` availability branch preserves the package's macOS-14 contract;
the current macOS-26 host must use the standard branch.

Successor constructor-level path-helper failures are mapped to
`coordinate + "_path"` for the held-directory seam and
`held_test_image_path` for the held-executable seam; byte or rewind mismatch
remains `request_input_join`. At both spawn-action sites the order stays

```text
addinherit_np -> exactly one descriptor fchdir action -> addclose
```

The OS branch invokes exactly one symbol and has no error fallback or retry;
its returned Darwin status remains one element of the existing all-zero action
predicate. Static successor counts are: standard symbol `1`, `_np` symbol
`1`, closed helper calls `2`, direct calls outside that helper `0`,
`F_GETPATH` `0`, and descriptor-path `proc_pidfdinfo` primitive `1`.

This changes no file/directory topology: acceptance remains `548` admitted
files, `547` source-identity records, `155` Prime authority directories,
`703` Prime watchers, and `2,163 / 4,096` combined watchers. After path 1 is
final, independent Python and Ruby canonical calculators must agree on those
counts, canonical-record byte count, aggregate admitted bytes, and the
successor source-identity SHA-256. Only then may path 2 receive that matching
digest. Both calculators must recheck the identity after the excluded
provenance reseal.

Static audit must show exactly these two changed paths; no Package.swift,
test, production supervisor `main.swift`, DriverCore, fixed-role table,
receipt schema, or control source may change. The one clean source commit is
the terminal of R2. A separately committed R3 readiness freeze is required
before any Swift compile or XCTest command. R2 itself authorizes no retry and
no production Gate-E action.

## Gate E1.4-R2 source checkpoint — Darwin primitive repair

| Coordinate | Checkpoint value |
| --- | --- |
| Status | `SOURCE_CHECKPOINTED_STATIC_ONLY_NOT_EXECUTED` |
| Durable-control authority | `98e780276798563f36695a89a9adadd2d43dc4c9` / tree `3a9dc71c81430f66b8a94f69a026ed0f24fc00af` |
| Source predecessor | `4735739b10a699ebc1ef3b4dc87a209fb5189834` / tree `c44c7ae54cffa95a9d2c705191c542fa1ceda5db` |
| Source checkpoint | `22ae3332aa75dad68e12660d43e8822f03a871a3` / tree `4ed3c124be29e5b0d194009bc0617ca2ae5ca24b` |
| Parent relation | exactly one parent, the frozen source predecessor |
| Source delta | exactly `2` modified mode-`100644` paths; `103` insertions / `64` deletions |
| Swift build / test / executable launch | `0 / 0 / 0` |
| Dependency resolution / fetch / network / GitHub | `0 / 0 / 0 / 0` |
| Authority vector / Gate-E outcome / clearance | `00000000 / ABSTAIN / 0` |

The exact successor files are:

| Path | Lines / bytes | Blob / SHA-256 |
| --- | ---: | --- |
| `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` | `13 / 546` | `06ab44fda46c03f3a00f84f9d5510a848eb4a73b` / `6ce0e7bc6699639103ef26ddf9daa14b844562018858ae33545175c8b716c547` |
| `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernorCore/PrimeValidationDriverV2ShotGovernor.swift` | `5,469 / 209,036` | `b460519eedd325b190f92bfd34874d4efe483017` / `a10477265e56e36513b2f643fef342f1b5f2839b1c35ce3f0c2c9019c88c1ac9` |

Independent Python and Ruby calculations both reproduced the predecessor
identity from its Git blob before agreeing on the successor:

| Quantity | Predecessor control | R2 successor |
| --- | ---: | ---: |
| Admitted files | `548` | `548` |
| Identity records | `547` | `547` |
| Canonical record bytes | `112,279` | `112,279` |
| Aggregate admitted bytes | `22,457,455` | `22,458,475` |
| Held Prime authority directories | `155` | `155` |
| Prime / combined watchers | `703 / 2,163` | `703 / 2,163` |
| Source identity SHA-256 | `74354d4581835d12f0624d0455e8167a4d608a5eecb8427debbe894a88a16ad2` | `689807021fe36551afcda7d65e1bfc66e12092abcb9feb097e5d53a343e9ca3b` |

Both calculators rechecked the successor after the exact excluded-provenance
reseal and returned the same identity. The capture enumerator's `146`
directory-safety count is a different quantity from the complete `155`
proper-parent authority set and does not replace the watcher arithmetic.

Three independent static audits established the frozen source vector:

```text
descriptor_path_proc_pidfdinfo_sites = 1
F_GETPATH_sites = 0
standard_addfchdir_symbols = 1
legacy_np_addfchdir_symbols = 1
working_directory_helper_definition = 1
working_directory_helper_call_sites = 2
direct_addfchdir_calls_outside_helper = 0
macOS_26_availability_partitions = 1
```

The helper takes only an action pointer and already-held descriptor. Both
call sites retain `addinherit_np -> one fchdir action -> addclose`. Path
recovery is an observation from a duplicated descriptor; constructor-specific
leaf checks and held/named vnode, metadata, xattr, byte, and continuity joins
remain the authority. The request bytes are read only after metadata equality.
No Package.swift, test, main, DriverCore, fixed-role, receipt, command, argv,
environment, cwd, timeout, retry, or process surface changed.

This checkpoint closes only the four R1 compiler constructs by static source
inspection. It makes no compilation, XCTest, fixture, production-image, or
Gate-E claim.

## Gate E1.4-R3 readiness freeze — repaired Release mechanics

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | R2 checkpoint `bd16ec70b5197d3866317ab26557a269618c4445` / tree `a4316729eb50f7e3e33d3e7332d8db63edcfbb9d` |
| Source commit/tree/identity | clean `22ae3332aa75dad68e12660d43e8822f03a871a3` / `4ed3c124be29e5b0d194009bc0617ca2ae5ca24b` / `689807021fe36551afcda7d65e1bfc66e12092abcb9feb097e5d53a343e9ca3b` |
| R3 epoch | `/private/tmp/gate-e1-4-mechanics-r3-22ae3332-689807021fe36551`; absent before freeze |
| Authorized SwiftPM commands | exactly `1`: one Release `swift test`; no `--skip-build` |
| Selected XCTest methods | exactly the existing one anchored identifier |
| Overall wall ceiling | `5,400` seconds |
| Production attempts | `0` |
| Fetch / network / GitHub | `0 / 0 / 0` |
| Authority vector before / pass / nonpass | `00000000 / 00000000 / 00000000` |

R3 is a new readiness proof on a new source identity, not an R1 retry. Create
the fresh epoch and exact nine private `0700` children `home`, `config`,
`tmp`, `git-template`, `swiftpm-cache`, `swiftpm-config`,
`swiftpm-security`, `clang-module-cache`, and `swiftpm-module-cache` once.
Rejoin every no-follow path/device/inode and require the Git template empty.

Define `rho3` as replacement of the sole R1 root string

```text
/private/tmp/gate-e1-4-mechanics-r1-4735739b-74354d4581835d12
```

with

```text
/private/tmp/gate-e1-4-mechanics-r3-22ae3332-689807021fe36551
```

throughout R1's exact finite `env -i` map and cache/config/security CLI paths.
Every other key and value, `umask 077`, stdin `/dev/null`, package path,
existing default `.build` scratch path, Xcode tool/SDK path, offline Git map,
and SwiftPM flags remain byte-for-byte unchanged.

The frozen build inputs and preimages are:

| Input | Exact R3 preimage |
| --- | --- |
| Root manifest / lock | `fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81` / `bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375` |
| Nested manifest / lock | `753f42251e768faaee3686da38e6f6bf7de048526199445f0e11c088af53dada` / `d70a43567cbd3be75083ab147020b86b055513020d95632f8286f60913c9374a` |
| Workspace state | `1,704` bytes; SHA-256 `8eeb391d590b20e5eec603ab9d078757f2106a29467a7ff079194278bba921bf` |
| MLX checkout | clean `d37885a278f1c37484a94d0f401a418735e66519` / tree `5310749549cca107fc1bb07d82dacf043bc02b9e` |
| Numerics checkout | clean `0c0290ff6b24942dadb83a929ffaaa1481df04a2` / tree `4560bfb65f2c26cbd159c3e1a9cbf01600bace1b` |
| SessionFixture | device/inode `16777231/17382060`; `53,072` bytes; SHA-256 `177a18c20bc42486c77b52af4c472be222dec1baabf8973ece7b2d44ea92756e` |
| ShotGovernor | absent |
| DriverV2Supervisor | device/inode `16777231/17383408`; `48,029,880` bytes; SHA-256 `679a05556327e3cb624da7dc2b27b90d43e5520adbbd3059272c3e3ca78b7e97` |
| XCTest bundle executable | device/inode `16777231/17361530`; `56,562,128` bytes; SHA-256 `c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712`; embeds stale identity `474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52` once, predecessor `74354d4581835d12f0624d0455e8167a4d608a5eecb8427debbe894a88a16ad2` zero times, R3 identity zero times, and the selected-method substring once |

The exact reserved production root
`/private/tmp/prime-driver-v2-gate-e-release-689807021fe36551afcda7d65e1bfc66e12092abcb9feb097e5d53a343e9ca3b`
is absent and forbidden. The two historical production roots remain retained
and are not R3 inputs. R0 and R1 epochs are retained and forbidden for reuse.

Run exactly once:

```sh
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift test \
  --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow \
  --configuration release \
  --scratch-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build \
  --cache-path /private/tmp/gate-e1-4-mechanics-r3-22ae3332-689807021fe36551/swiftpm-cache \
  --config-path /private/tmp/gate-e1-4-mechanics-r3-22ae3332-689807021fe36551/swiftpm-config \
  --security-path /private/tmp/gate-e1-4-mechanics-r3-22ae3332-689807021fe36551/swiftpm-security \
  --disable-netrc --disable-keychain --force-resolved-versions \
  --disable-automatic-resolution --disable-sandbox --disable-swift-testing \
  --filter '^PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEJournalChainOneWinnerAndPoisonAreExact$' \
  </dev/null
```

Normal `swift test` may compile or relink package products as build telemetry.
SessionFixture and XCTest preimages are not launch authority; the method opens
the final fixture image `O_NOFOLLOW_ANY`, holds and validates its descriptor,
spawns suspended, and joins its mapped image before resume. Record all final
image transitions after the complete command. ShotGovernor may make the
authorized build transition absent-to-present but must not launch.

A successful method has exactly one XCTest runner, two SessionFixture
supervisors, and two passive SessionFixture children. It launches zero
production Governor, production Supervisor, fixed Git/Swift role,
SpawnCanary, FixtureChild, or SecureChildIntegration products. SwiftPM
compiler/linker and read-only local package-planning helpers remain harness
processes, not Gate-E roles; no claim of a complete host process census is
available.

Acceptance requires exit `0`; the exact frozen method multiset; `1` XCTest
executed and passed with zero failures/skips; zero Swift Testing runner; all
outer journal and conserved-session predicates frozen by R0; source/control,
manifests, locks, workspace state, tools, checkouts, roots, and images joined;
Git template empty; scoped temporary-prefix inventories restored; and the
reserved production root still absent. The final XCTest executable must be a
regular no-follow successor with a different device/inode and SHA-256 from
the frozen
`c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712`
preimage, with its held descriptor joined to the named vnode. Its strings
must contain the R3 identity
`689807021fe36551afcda7d65e1bfc66e12092abcb9feb097e5d53a343e9ca3b`
exactly once and the selected-method substring exactly once, while containing
the stale
`474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52`
and intermediate
`74354d4581835d12f0624d0455e8167a4d608a5eecb8427debbe894a88a16ad2`
identities zero times. Any compile failure, stale XCTest image, test failure,
timeout, hard stop, or missing terminal consumes R3 and remains `ABSTAIN`.

The maximum pass transition is:

```text
R3_release_test_compile = PASS
R3_selected_xctest = PASS
R3_mixed_test_host_mechanics = PASS
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

R3 authorizes no production root, capsule, journal, Governor invocation,
fixed Git/Swift role, Gate F/G action, GitHub action, retry, or cleanup. A
clean pass permits only a separately frozen production-shot readiness
assessment.

## Gate E1.4-R3 result — initializer compile stop before XCTest

| Coordinate | Observed value |
| --- | --- |
| Executed freeze | `733098935d2deaf8c85edc31cf705e63d02ce692` / tree `300cd6287ffb83a15c874c96aafe20ca1b95ce51` |
| Status | `STOPPED_RELEASE_SWIFT_TEST_COMPILE_FAILURE_BEFORE_XCTEST` |
| Authorized / attempted SwiftPM commands | `1 / 1` |
| Command exit | `1` |
| Observed bounding interval | `2026-08-23T16:42:52Z` through `2026-08-23T16:46:33Z`; at most `221` seconds |
| Frozen selector count / executed / passed / failed / skipped XTests | `1 / 0 / 0 / 0 / 0` |
| XCTest / Swift Testing runners | `0 / 0` |
| SessionFixture supervisors / passive children launched | `0 / 0` |
| Production governor / supervisor / fixed-role launches | `0 / 0 / 0` |
| Compiler/linker process census | `ABSTAIN`; build transcript and terminal only |
| Dependency fetch / network / GitHub | `0 / 0 / 0` |

R3's sole Release `swift test` invocation cleared every R1 diagnostic and
continued to the held-executable initializer. Compilation then stopped at the
first Swift definite-initialization violation:

```text
PrimeValidationDriverV2ShotGovernor.swift:939:32: error:
'self' captured by a closure before all members were initialized
guard requiredLeaf.map({
    URL(fileURLWithPath: absolutePath).lastPathComponent == $0
}) ?? true
```

The compiler notes identify `descriptor`, `identity`, and `xattrs` as still
uninitialized. The `Optional.map` closure reads the stored `absolutePath` and
therefore captures partially initialized `self`; the canonical-path value and
leaf predicate themselves were not rejected. The retained diagnostic at
`Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowDriverV2ShotGovernorCore.build/PrimeValidationWorkflowDriverV2ShotGovernorCore.dia`
is `800` bytes with SHA-256
`f0824e54f78b9ccb053a4cc2094b1fc4307d52c3a6644f508d3405cf9fe92456`.
The final terminal was `error: fatalError`.

ShotGovernorCore emitted no object or module, ShotGovernor remained absent,
and the XCTest executable remained the stale preimage. Thus no XCTest,
SessionFixture, or package product ran. Those zero launch counts derive from
the stopped SwiftPM build graph and absence of XCTest or product-launch
markers; they are not a complete host-process census.

### R3 artifact and conservation data

| Image | Exact terminal fact |
| --- | --- |
| SessionFixture | retained device/inode `16777231/17382060`; `53,072` bytes; SHA-256 `177a18c20bc42486c77b52af4c472be222dec1baabf8973ece7b2d44ea92756e`; UUID `2EBB880A-D28B-32FF-9B7E-EB868AF5D9B6`; no R3 relink |
| ShotGovernor | absent; its core did not compile |
| DriverV2Supervisor | R3 preimage device/inode `16777231/17383408`, SHA-256 `679a05556327e3cb624da7dc2b27b90d43e5520adbbd3059272c3e3ca78b7e97` -> device/inode `16777231/17385380`; `48,029,880` bytes; SHA-256 `48f9c33813d9a20e5c9830af20263ee2d05188a06b2383d894aa09dec767fc43`; UUID `B8B64364-6315-37FD-81BA-E937BB1AB169`; mtime/ctime `1787503583/1787503583` |
| SecureChildIntegration | R3 preimage device/inode `16777231/17383340`, SHA-256 `48ca1e187e6ecfc4eb9af0abadb4b16141ce799b2191f230afc7f3d8aa374f1b` -> device/inode `16777231/17385350`; `51,271,120` bytes; SHA-256 `e458f164f0f43e2e164d6f9439b815c92e16a9225ea46b1fd3a82c04ccd2f367`; UUID `47E50C9E-7F35-3861-85CF-0DE1899A8BB5`; mtime/ctime `1787503570/1787503570` |
| XCTest bundle executable | retained device/inode `16777231/17361530`; `56,562,128` bytes; SHA-256 `c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712`; UUID `F62F4215-B00C-30C0-B7B2-43BF6924B73D`; stale identity once, R3 identity zero times, selected-method substring once |

Both R3-relinked images contain source identity
`689807021fe36551afcda7d65e1bfc66e12092abcb9feb097e5d53a343e9ca3b`
once and the stale and intermediate identities zero times. All recorded
present images remain regular arm64 Mach-O objects, mode `0700`, one link, no
flags or ACL, and with only the `com.apple.provenance` xattr. Build-image
replacement is compilation telemetry, not execution authority.

The fresh R3 epoch is retained at device/inode `16777231/17384688`, mode
`0700`, link count `11`, with the exact nine child inodes
`17384689...17384697` in the frozen order. The Git template remains empty.
The scoped admission inventory remains only
`/private/tmp/prime-validation-admission-tests-20260803-c`; the scoped public
inventory remains empty. The exact R3 reserved production root remains absent,
while the two separately named historical production roots remain retained.

Source stayed clean at `22ae3332aa75dad68e12660d43e8822f03a871a3` /
tree `4ed3c124be29e5b0d194009bc0617ca2ae5ca24b`. All four manifest/lock
digests, the `1,704`-byte workspace-state digest, admitted-source hashes, both
dependency commit/tree pairs, and both clean dependency worktrees remained
exact. No R3 root or historical root was rebound or removed.

The only valid R3 vector is:

```text
R3_release_test_compile = FAIL
R3_selected_xctest = NOT_STARTED
R3_mixed_test_host_mechanics = ABSTAIN
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

R3's epoch and command are consumed. This result is a compiler stop, not a
GitHub result, containment result, fixture result, or Gate-E scientific
outcome. It authorizes neither a same-source retry nor a production action.

## Gate E1.4-R4 freeze — held-executable initialization repair

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_SOURCE_REPAIR_NOT_IMPLEMENTED` |
| Durable-control predecessor | R3 readiness `733098935d2deaf8c85edc31cf705e63d02ce692` / tree `300cd6287ffb83a15c874c96aafe20ca1b95ce51` plus the exact R3 result above |
| Source predecessor | clean `22ae3332aa75dad68e12660d43e8822f03a871a3` / tree `4ed3c124be29e5b0d194009bc0617ca2ae5ca24b` |
| Authorized successor source commits | exactly `1`, a direct child of the source predecessor |
| Authorized source paths | exactly `2` |
| Swift build / test / executable launch in this slice | `0 / 0 / 0` |
| Root / cache / capsule / journal creation | `0 / 0 / 0 / 0` |
| Dependency resolution / fetch / network / GitHub | `0 / 0 / 0 / 0` |
| Authority vector before / after | `00000000 / 00000000` |

The exact two-path allowlist is:

1. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernorCore/PrimeValidationDriverV2ShotGovernor.swift` — one initializer hunk only; and
2. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` — only the final source-identity digest reseal after path 1 is final.

Their frozen preimages are:

| Path | Lines / bytes | Blob / SHA-256 |
| --- | ---: | --- |
| ShotGovernor core | `5,469 / 209,036` | `b460519eedd325b190f92bfd34874d4efe483017` / `a10477265e56e36513b2f643fef342f1b5f2839b1c35ce3f0c2c9019c88c1ac9` |
| Embedded provenance | `13 / 546` | `06ab44fda46c03f3a00f84f9d5510a848eb4a73b` / `6ce0e7bc6699639103ef26ddf9daa14b844562018858ae33545175c8b716c547` |

The authorized repair is exact. After `binding.validate()` and
`self.binding = binding`, bind the canonical path to a local
`canonicalAbsolutePath`. If `requiredLeaf` is nonnil, compare it directly to
`URL(fileURLWithPath: canonicalAbsolutePath).lastPathComponent` and retain the
same `coordinate + "_leaf"` rejection. Only after that check passes assign
`absolutePath = canonicalAbsolutePath`; then continue into the existing single
`Darwin.open` unchanged. The leaf check must use only the local canonical
value: it may not capture `self` or read the stored `absolutePath`. No closure
may capture partially initialized `self`.

The repair must preserve `binding.validate`, canonical-path admission, the
single `O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC` open, held-versus-named
device/inode equality, link/mode/flag/xattr/content-hash checks, descriptor
rewind, and all later revalidation. The descriptor-only test initializer at
the neighboring site is unchanged. No process, spawn, environment, cwd,
deadline, drain, reap, process-group, continuity, poison, journal, role, API,
receipt, or exit-70 surface changes.

Static successor acceptance is:

```text
changed_paths = 2
initializer_hunks = 1
requiredLeaf.map_sites = 0
local_canonical_binding_path_values = 1
nonclosure_optional_leaf_checks = 1
stored_absolutePath_assignment_before_existing_open = 1
binding_initializer_definitions/call_sites = 1/4
descriptor_test_initializer_definitions/call_sites = 1/1
leaf_rejection_sites = 2
frozen_executable_leaf_literals = 5
```

An independent whole-file initializer scan found no other partially
initialized-`self` closure: journal closures capture only parameters and
static constants; capture initialization closes only over local inputs; and
the death watcher installs its weak-self handler only after all of its stored
properties are initialized. R4 does not authorize speculative changes at
those sites.

Topology must remain exactly `548` admitted files, `547` identity records,
`112,279` canonical-record bytes, `155` held Prime authority directories,
`703` Prime watchers, and `2,163 / 4,096` combined watchers. After the single
initializer hunk is final, independent Python and Ruby calculators must agree
on the new aggregate admitted bytes and source-identity SHA-256 as well as
those invariant counts. Only then may the excluded provenance file receive
that digest, after which both calculators must reproduce it again.

The R4 terminal is one clean two-path source commit. It may be followed only
by a separately committed static source checkpoint and then a separately
committed R5 readiness freeze with a fresh epoch. R4 authorizes no Swift
command, no R3 retry, no production Gate-E action, and no cleanup.

## Gate E1.4-R4 source checkpoint — held-executable initialization repair

| Coordinate | Checkpoint value |
| --- | --- |
| Status | `SOURCE_CHECKPOINTED_STATIC_ONLY_NOT_EXECUTED` |
| Durable-control authority | `f83a9a52ce7e79217c1d62355c2e22680a8e0125` / tree `500ed0af043495fe25b5529f67dbdb32484c1641` |
| Source predecessor | `22ae3332aa75dad68e12660d43e8822f03a871a3` / tree `4ed3c124be29e5b0d194009bc0617ca2ae5ca24b` |
| Source checkpoint | `7fbd52386283295d6312b57dbcb3acd97b1b5bce` / tree `dd45c962af0683db73c1e2785e7232b243d628d9` |
| Parent relation | exactly one parent, the frozen source predecessor |
| Source delta | exactly `2` modified mode-`100644` paths; `12` insertions / `9` deletions |
| Swift build / test / executable launch | `0 / 0 / 0` |
| Dependency resolution / fetch / network / GitHub | `0 / 0 / 0 / 0` |
| Authority vector / Gate-E outcome / clearance | `00000000 / ABSTAIN / 0` |

The exact successor files are:

| Path | Lines / bytes | Blob / SHA-256 |
| --- | ---: | --- |
| `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` | `13 / 546` | `d14bc8172c2b4b2f3e67627697e5a7713f7034db` / `cb6fc1e452f7c53feeb93ee9c59c3f78d1151ce7c1b242a8209b741fa39b867f` |
| `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernorCore/PrimeValidationDriverV2ShotGovernor.swift` | `5,472 / 209,156` | `c7466665b5225260c6b0084193f44a06a44c00ea` / `216ccd2df97af811bdeb6c2625850e2c08bcd3f10bd59106751d3c2b284c3e4f` |

Independent Python and Ruby calculators each reproduced the R4 predecessor
from its Git blob, then agreed on the successor before and after the excluded
provenance reseal:

| Quantity | R4 predecessor | R4 successor |
| --- | ---: | ---: |
| Admitted files | `548` | `548` |
| Identity records | `547` | `547` |
| Canonical record bytes | `112,279` | `112,279` |
| Aggregate admitted bytes | `22,458,475` | `22,458,595` |
| Capture-enumerator directories | `146` | `146` |
| Held authority directories | `155` | `155` |
| Prime / combined watchers | `703 / 2,163` | `703 / 2,163` |
| Source identity SHA-256 | `689807021fe36551afcda7d65e1bfc66e12092abcb9feb097e5d53a343e9ca3b` | `77d5cfa3d9b9fc7054a40b0651940641d0da1d52afee197ce178b3c480446b76` |

The provenance file equals the canonical excluded template byte-for-byte and
contains the successor digest exactly once. The capture-enumerator count and
the complete proper-parent authority-directory count remain distinct; watcher
arithmetic uses the latter.

Two independent static audits established:

```text
changed_paths = 2
initializer_hunks = 1
requiredLeaf.map_sites = 0
local_canonical_binding_path_values = 1
nonclosure_optional_leaf_checks = 1
stored_absolutePath_assignment_before_existing_open = 1
binding_initializer_definitions/call_sites = 1/4
descriptor_test_initializer_definitions/call_sites = 1/1
leaf_rejection_sites = 2
frozen_executable_leaf_literals = 5
```

The leaf check now uses only the local canonical value and cannot capture
partially initialized `self`. The same rejection coordinate and all subsequent
open, descriptor, vnode, metadata, xattr, content, rewind, and revalidation
predicates remain unchanged. A whole-file initializer scan found no masked
sibling of the R3 diagnostic. No manifest, test, production `main.swift`,
DriverCore, role table, receipt, journal, API, process, or authority surface
changed.

This is a static source checkpoint only. It makes no compilation, XCTest,
fixture, production-image, process-containment, or Gate-E claim.

## Gate E1.4-R5 readiness freeze — initialization-repaired Release mechanics

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | R4 checkpoint `a872727cf1e9f857189fa60e1975320de733ef71` / tree `eae04cba9db66e1a6539583e1656fd0128f43adf` |
| Source commit/tree/identity | clean `7fbd52386283295d6312b57dbcb3acd97b1b5bce` / `dd45c962af0683db73c1e2785e7232b243d628d9` / `77d5cfa3d9b9fc7054a40b0651940641d0da1d52afee197ce178b3c480446b76` |
| R5 epoch | `/private/tmp/gate-e1-4-mechanics-r5-7fbd5238-77d5cfa3d9b9fc70`; absent before this freeze |
| Authorized SwiftPM commands | exactly `1`: one Release `swift test`; no `--skip-build` |
| Selected XCTest methods | exactly the existing one anchored identifier |
| Overall wall ceiling | `5,400` seconds |
| Production attempts | `0` |
| Fetch / network / GitHub | `0 / 0 / 0` |
| Authority vector before / pass / nonpass | `00000000 / 00000000 / 00000000` |

R5 is a new readiness proof on the R4 source identity, not a retry of R3.
After this freeze is committed, create the fresh epoch and exact nine private
`0700` children `home`, `config`, `tmp`, `git-template`, `swiftpm-cache`,
`swiftpm-config`, `swiftpm-security`, `clang-module-cache`, and
`swiftpm-module-cache` once. Record and rejoin every no-follow
path/device/inode and require the Git template empty. R0, R1, and R3 epochs
remain retained and are forbidden for reuse.

Define `rho5` as replacement of the sole R3 root string

```text
/private/tmp/gate-e1-4-mechanics-r3-22ae3332-689807021fe36551
```

with

```text
/private/tmp/gate-e1-4-mechanics-r5-7fbd5238-77d5cfa3d9b9fc70
```

throughout R3's exact finite `env -i` map and cache/config/security CLI paths.
Every other key and value, `umask 077`, stdin `/dev/null`, package path,
existing default `.build` scratch path, Xcode tool/SDK path, offline Git map,
and SwiftPM flag remains byte-for-byte unchanged.

The frozen build inputs and preimages are:

| Input | Exact R5 preimage |
| --- | --- |
| Package build root | device/inode `16777231/17179422`; existing default `Tests/PrimeValidationWorkflow/.build` only |
| Root manifest / lock | `fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81` / `bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375` |
| Nested manifest / lock | `753f42251e768faaee3686da38e6f6bf7de048526199445f0e11c088af53dada` / `d70a43567cbd3be75083ab147020b86b055513020d95632f8286f60913c9374a` |
| Workspace state | `1,704` bytes; SHA-256 `8eeb391d590b20e5eec603ab9d078757f2106a29467a7ff079194278bba921bf` |
| MLX checkout | clean `d37885a278f1c37484a94d0f401a418735e66519` / tree `5310749549cca107fc1bb07d82dacf043bc02b9e` |
| Numerics checkout | clean `0c0290ff6b24942dadb83a929ffaaa1481df04a2` / tree `4560bfb65f2c26cbd159c3e1a9cbf01600bace1b` |
| SessionFixture / LiveTests / GovernorCore source SHA-256 | `c42e91519d8a792145a7478963e56ec92ddb7bdbf709a960b363241fd88305ab` / `4a1b89ca13afe168719acb91f5c45e58b377cd7f3bf5375bb429d8cdbf4f5d35` / `216ccd2df97af811bdeb6c2625850e2c08bcd3f10bd59106751d3c2b284c3e4f` |
| Embedded provenance source | `546` bytes; SHA-256 `cb6fc1e452f7c53feeb93ee9c59c3f78d1151ce7c1b242a8209b741fa39b867f`; canonical R4 template |
| SessionFixture | device/inode `16777231/17382060`; `53,072` bytes; SHA-256 `177a18c20bc42486c77b52af4c472be222dec1baabf8973ece7b2d44ea92756e`; UUID `2EBB880A-D28B-32FF-9B7E-EB868AF5D9B6` |
| ShotGovernor | absent |
| ShotGovernorCore compile frontier | object and module absent; retained R3 diagnostic is `800` bytes, SHA-256 `f0824e54f78b9ccb053a4cc2094b1fc4307d52c3a6644f508d3405cf9fe92456`, mtime/ctime `1787503584/1787503584`; repaired GovernorCore and provenance source mtimes are later at `1787504042` and `1787504122` |
| DriverV2Supervisor | device/inode `16777231/17385380`; `48,029,880` bytes; SHA-256 `48f9c33813d9a20e5c9830af20263ee2d05188a06b2383d894aa09dec767fc43`; UUID `B8B64364-6315-37FD-81BA-E937BB1AB169` |
| SecureChildIntegration | device/inode `16777231/17385350`; `51,271,120` bytes; SHA-256 `e458f164f0f43e2e164d6f9439b815c92e16a9225ea46b1fd3a82c04ccd2f367`; UUID `47E50C9E-7F35-3861-85CF-0DE1899A8BB5` |
| XCTest bundle executable | device/inode `16777231/17361530`; `56,562,128` bytes; SHA-256 `c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712`; UUID `F62F4215-B00C-30C0-B7B2-43BF6924B73D`; contains stale identity `474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52` once, intermediate identity zero times, R3 identity zero times, R5 identity zero times, and one strings record containing the selected-method substring |

Every recorded present image is a regular arm64 Mach-O object, mode `0700`,
one link, flags `0`, and has only the `com.apple.provenance` xattr. The R3
Supervisor and SecureChildIntegration preimages contain the R3 identity once
and R5 identity zero times. These are build preimages, not launch authority.

The exact reserved production root
`/private/tmp/prime-driver-v2-gate-e-release-77d5cfa3d9b9fc7054a40b0651940641d0da1d52afee197ce178b3c480446b76`
is absent and forbidden. The two named historical production roots remain
retained and are not R5 inputs. The scoped admission inventory contains only
`/private/tmp/prime-validation-admission-tests-20260803-c`; the scoped public
inventory is empty.

Run exactly once:

```sh
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift test \
  --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow \
  --configuration release \
  --scratch-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build \
  --cache-path /private/tmp/gate-e1-4-mechanics-r5-7fbd5238-77d5cfa3d9b9fc70/swiftpm-cache \
  --config-path /private/tmp/gate-e1-4-mechanics-r5-7fbd5238-77d5cfa3d9b9fc70/swiftpm-config \
  --security-path /private/tmp/gate-e1-4-mechanics-r5-7fbd5238-77d5cfa3d9b9fc70/swiftpm-security \
  --disable-netrc --disable-keychain --force-resolved-versions \
  --disable-automatic-resolution --disable-sandbox --disable-swift-testing \
  --filter '^PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEJournalChainOneWinnerAndPoisonAreExact$' \
  </dev/null
```

Normal `swift test` may compile or relink package products as build telemetry.
The retained R3 diagnostic is a frozen preimage and must not be deleted or
cleaned before the command; on a pass it cannot remain the current compiler
diagnostic.
SessionFixture and XCTest preimages are not launch authority; the method opens
the final fixture image `O_NOFOLLOW_ANY`, holds and validates its descriptor,
spawns suspended, and joins its mapped image before resume. Record every final
image transition after the complete command. ShotGovernor may make the
authorized build transition absent-to-present but must not launch.

A successful method has exactly one XCTest runner, two SessionFixture
supervisors, and two passive SessionFixture children. It launches zero
production Governor, production Supervisor, fixed Git/Swift role,
SpawnCanary, FixtureChild, or SecureChildIntegration products. SwiftPM
compiler/linker and read-only local package-planning helpers are harness
processes, not Gate-E roles; a complete host process census remains
`ABSTAIN`.

Acceptance requires exit `0`; the exact frozen method multiset; `1` XCTest
executed and passed with zero failures/skips; zero Swift Testing runner; all
outer-journal and conserved-session predicates frozen by R0; source/control,
manifests, locks, workspace state, tools, checkouts, roots, and images joined;
Git template empty; scoped temporary-prefix inventories restored; and the
reserved production root still absent. The final XCTest executable must be a
regular no-follow successor with a different device/inode and SHA-256 from
the frozen `c3427b8c8c659a3be3e526f47adf2d5d6ed332b665ff9b967b0132e49187e712`
preimage, with its held descriptor joined to the named vnode. Its strings
must contain the R5 identity
`77d5cfa3d9b9fc7054a40b0651940641d0da1d52afee197ce178b3c480446b76`
exactly once and the selected-method substring on exactly one strings record,
while containing the stale
`474008bdffccf4102566c98088abf2799ad3a4934edadb8c0357c23190c71a52`,
intermediate
`74354d4581835d12f0624d0455e8167a4d608a5eecb8427debbe894a88a16ad2`,
and R3
`689807021fe36551afcda7d65e1bfc66e12092abcb9feb097e5d53a343e9ca3b`
identities zero times.

A pass also requires exact absent-to-present regular-file transitions for
`PrimeValidationWorkflowDriverV2ShotGovernorCore.build/PrimeValidationDriverV2ShotGovernor.swift.o`
and
`Modules/PrimeValidationWorkflowDriverV2ShotGovernorCore.swiftmodule`, with
both terminal named vnodes recorded after the command. This directly closes
the repaired compiler coordinate; their presence is build telemetry and does
not authorize or imply a ShotGovernor launch.

Any compile failure, stale XCTest image, test failure, timeout, hard stop, or
missing terminal consumes R5 and remains `ABSTAIN`. The maximum pass
transition is:

```text
R5_release_test_compile = PASS
R5_selected_xctest = PASS
R5_mixed_test_host_mechanics = PASS
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

R5 authorizes no production root, capsule, journal, Governor invocation,
fixed Git/Swift role, Gate F/G action, GitHub action, retry, or cleanup. A
clean pass permits only a separately frozen production-shot readiness
assessment.

## Gate E1.4-R5 result — selected XCTest terminated without a terminal

| Coordinate | Observed value |
| --- | --- |
| Status | `CONSUMED_XCTEST_RUNNER_TERMINATED_AFTER_SELECTED_TEST_START_WITHOUT_TEST_TERMINAL` |
| Durable-control freeze | `fac16714685206114b1d05b1d9f58e20b2881213` / tree `040437520c5c27f93211ede544c82d0b7473ef4c` |
| Source commit/tree/identity | clean `7fbd52386283295d6312b57dbcb3acd97b1b5bce` / `dd45c962af0683db73c1e2785e7232b243d628d9` / `77d5cfa3d9b9fc7054a40b0651940641d0da1d52afee197ce178b3c480446b76` |
| Authorized Release `swift test` commands consumed | `1 / 1`; no retry |
| Release build | `PASS`; `Build complete! (204.05s)` |
| Selected XCTest | started at `2026-08-23T17:13:04.926Z`; no case, suite, or command terminal |
| Outer Swift shell | exit `1`; this is not an observed inner wait status |
| Conservative observer interval | epoch born `2026-08-23T17:08:46Z` through post-observer `2026-08-23T17:13:25Z`; at most `279` seconds |
| Production attempts / authority vector | `0 / 00000000` |
| Gate-E scientific outcome / clearance | `ABSTAIN / 0` |

The wrapper's two observer-only `/usr/bin/date` calls failed because this host
provides `date` at `/bin/date`. They neither changed the exact `env -i` Swift
command nor created another Swift invocation. The one authorized Release
command was consumed. No rerun under R5 is permitted.

The build crossed the R3/R4 compile frontiers. The terminal build products
and diagnostics were:

| Product | R5 transition and terminal identity |
| --- | --- |
| SessionFixture | retained device/inode `16777231/17382060`; `53,072` bytes; SHA-256 `177a18c20bc42486c77b52af4c472be222dec1baabf8973ece7b2d44ea92756e`; UUID `2EBB880A-D28B-32FF-9B7E-EB868AF5D9B6` |
| ShotGovernor | absent to device/inode `16777231/17387463`; `48,698,952` bytes; SHA-256 `383724ac78b86b2bb0c6e5b3499b56ccd219cc2963fd2cdfd9662363333b32fb`; UUID `DD524F45-91F6-3254-BE83-6EBCE5C12CFD` |
| DriverV2Supervisor | replaced by device/inode `16777231/17387436`; `48,029,880` bytes; SHA-256 `f3df1071ba0a105825f7ae8879ecbf791de71034e190cc428a739222fc42be95`; UUID `46E79B3B-22EE-30B2-A266-82E0664716BB` |
| SecureChildIntegration | replaced by device/inode `16777231/17387405`; `51,271,120` bytes; SHA-256 `a473a1d0d22335b88059a84bc4de57459d9b7363d2d19190c418bca4fa40299b`; UUID `34144441-3267-3AE0-96A4-381BE6EBE8D8` |
| XCTest executable | replaced by device/inode `16777231/17387503`; `57,803,920` bytes; SHA-256 `d2540ec6202c5360bf930dcd951980ff52bf6dad605157f03a749903d2c7cfb1`; UUID `00C5C75A-A3B4-3C49-9F30-BE89D326A0DF` |
| GovernorCore object | absent to device/inode `16777231/17387443`; `2,185,384` bytes; SHA-256 `13c58ace3b6bc30a1c2de6143bbe3f179dd0cebde91f629b1440b8be1dc9b0b5` |
| GovernorCore module | absent to device/inode `16777231/17387439`; `279,816` bytes; SHA-256 `d0edeed6d6b7033ced04011e85bd3476986dc3bdf1909fe2189c569fe540044e` |
| GovernorCore compiler diagnostic | same retained inode `17383411`, replaced `800`-byte R3 failure by clean `268` bytes; SHA-256 `2c72d5afff8cce441f2f8299a18215b0bf79605aa7eb05839e38f7949b46c0e2` |

Each newly identity-bearing ShotGovernor, Supervisor,
SecureChildIntegration, and XCTest image contains the R5 identity exactly
once and contains the stale R0, intermediate R0, and R3 identities zero
times. The XCTest strings inventory contains the selected-method substring
on exactly one record. These are build and linkage observations. They are not
production supervisor or Gate-E launch authority.

Five R5 fixture roots remain retained and must not be cleaned:

| Retained root | Root identity and durable residue |
| --- | --- |
| `/private/tmp/prime-validation-admission-tests-9B0C29D5-BFE6-4983-A1D8-9376FB249C69` | device/inode `16777231/17387510`; born `17:13:04Z`; `65` files / `32` directories; complete `34`-leaf inner journal; `723`-byte outer terminal SHA-256 `d973b116ba5cfeffb981a5e285784749e6bb5d46eab58c6c317fb5e259038646`, spawn count `0`, Git/Swift count `0`, vector `00000000` |
| `/private/tmp/prime-validation-admission-tests-27939ACC-14D5-4C63-B420-DB1D75DDE491` | device/inode `16777231/17387598`; born `17:13:08Z`; `26` files / `29` directories; deliberate `10`-byte first-leaf collision SHA-256 `591e7ef56458a393c1831cddcecd0a3415848deb290b6ebac689d0656293e48f` |
| `/private/tmp/prime-validation-admission-tests-E2FE16A0-6601-4261-BDD3-8A31F77A082C` | device/inode `16777231/17387826`; born `17:13:13Z`; `31` files / `30` directories; `723`-byte concurrent-winner terminal SHA-256 `4d9c60c252b35eb3d69c24686cc7eac49466b09d8fcbe86ac64fe198a6de7f34` |
| `/private/tmp/prime-validation-admission-tests-74F5E773-3A1C-473B-BDEE-B3B3F7ABE846` | device/inode `16777231/17387887`; born `17:13:14Z`; `31` files / `30` directories; deliberate empty terminal SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` after the three-prefix chain |
| `/private/tmp/prime-validation-admission-tests-29D60937-15FB-4364-96F1-7EBCDA198BDF` | device/inode `16777231/17387948`; born `17:13:15Z`; `31` files / `30` directories; `723`-byte same-bytes/new-inode rebound terminal SHA-256 `d7e682d02805bf10afe6d721fa3828bed861b9ec551cb24f241e6a16c3cc860a` |

The main root's inner mechanics mutated between `17:13:07Z` and
`17:13:10Z`; the per-root birth times above overlap that interval and are not
asserted as a total order. This durable data establishes control-flow arrival through the outer
mechanics region. It does not convert the missing XCTest terminal into passed
assertions and does not prove either SessionFixture interval. SessionFixture
supervisor and passive-child counts therefore remain `ABSTAIN`.

No matching SessionFixture or XCTest image was present in the post-command
`libproc` snapshot, and `lsof` found no current handle on the five roots or
fixture/Governor images. That is a post-snapshot absence observation, not a
lifetime process census. No scoped crash, core, or xcresult artifact identifies
the stopping instruction. The source/control worktrees, manifests, locks,
workspace state, dependency checkouts, Git template, and exact absent R5
production root remained conserved. The scoped temporary-root inventory did
not restore because the five roots remain; that independently rejects R5's
pass predicate.

The next package-internal SessionFixture seam in source order contains one
explicit source-level `Darwin._exit`, its containment defer's `_exit(70)`; R5
does not prove that seam was entered. External runner, kernel, or signal
termination remains possible. The observed shape is therefore
`CONSISTENT_WITH_TEST_SEAM_CONTAINMENT_FAIL_STOP`, but neither exit `70`, the
first versus second fixture mode, nor a failure coordinate is present in a
durable R5 datum. The exact cause remains `ABSTAIN`. Static possibilities
include `session_fixture_child_discovery` exhausting the shared ten-second
budget before defer containment, `session_census_nonconvergent_query`, and the
`session_census_getsid_*` or `session_census_bsdinfo_*` syscall coordinates.
No deadline, census, or containment semantic may change without a new datum.

The terminal R5 vector is:

```text
R5_release_test_compile = PASS
R5_selected_xctest = STARTED_NO_TERMINAL
R5_mixed_test_host_mechanics = ABSTAIN
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

## Gate E1.4-R6 freeze — held-vnode fail-stop diagnostic source slice

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_STATIC_SOURCE_DIAGNOSTIC_NOT_IMPLEMENTED` |
| Durable-control predecessor | R5 readiness freeze `fac16714685206114b1d05b1d9f58e20b2881213` / tree `040437520c5c27f93211ede544c82d0b7473ef4c` |
| Source predecessor | clean `7fbd52386283295d6312b57dbcb3acd97b1b5bce` / tree `dd45c962af0683db73c1e2785e7232b243d628d9` / identity `77d5cfa3d9b9fc7054a40b0651940641d0da1d52afee197ce178b3c480446b76` |
| Purpose | expose one bounded source-internal package-test containment coordinate and its state as durable local data before the unchanged fail-stop |
| Source allowlist | exactly GovernorCore, the existing LiveTests file, and excluded embedded-provenance reseal |
| Swift build / test / executable launch | `0 / 0 / 0` |
| Production attempts / authority vector | `0 / 00000000` |
| Network / fetch / GitHub | `0 / 0 / 0` |

R6 is not an R5 retry and is not a containment repair. It changes no census,
deadline, kill, reap, process-group, spawn, or production behavior. It adds
one package-internal observation capability to the existing mechanics seam so
that a later, separately frozen source identity can distinguish the fail-stop
coordinate without promoting shell or XCTest prose to evidence authority.

The exact private leaf is
`gate-e-session-fixture-fail-stop.json`. LiveTests creates it once, after all
retained outer-mechanics and rebound cases and immediately before the first
SessionFixture call, directly
under the already-private main `Fixture.base`, never under workspace,
evidence, lease, a source root, a production root, or the Driver V2 evidence
ledger. Creation is relative to an already-held base-directory descriptor and
uses exactly
`O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC`, mode `0600`.
LiveTests retains the descriptor, initial vnode metadata, and xattr set. It
adds exactly one argument—the immediately constrained held diagnostic
descriptor—to the existing package-internal `exerciseSessionFixtureForTesting`
seam. No path, environment, argv, callback, writer object, role identifier,
timeout, or production entry is added, and the descriptor is never inherited
into SessionFixture.

GovernorCore duplicates the descriptor with `F_DUPFD_CLOEXEC` and admits only
a regular file whose frozen preimage is exact device/inode, current uid and
gid, one link, mode `0600`, size zero, `st_flags == 0`, exact xattr bytes,
descriptor offset zero, `FD_CLOEXEC` set, and access mode `O_RDWR` with append,
nonblocking, and asynchronous flags absent. The exact named leaf must join the
held descriptor before spawn. Each normal return from both frozen fixture
modes must leave the same vnode, metadata, xattrs, descriptor flags, offset,
and zero length unchanged; LiveTests checks that condition after each call. A
normal test completion publishes no diagnostic.

Only the existing containment-defer catch may publish, and only when the
caught error is the private Governor failure value with status exactly `70`.
The coordinate remains a bounded source-internal string; it is not represented
as a closed Swift enum and must not be called typed authority. Fixture mode,
execution phase, and containment state are closed source enums. The phase is
set before each existing post-spawn join, prepublication child-discovery,
orphan death-wait, orphan initial-census, and primary-containment region; this
adds observation only and does not alter their order or semantics. It is the
last body phase entered before defer unwinding and the defer must not overwrite
it. `failureCoordinate` is the private failure caught inside the defer's
containment attempt; it is not necessarily the body error that initiated
unwinding.
The canonical record has exactly these closed fields:

```text
schema = "prime_driver_v2_session_fixture_fail_stop_v1"
sourceIdentitySHA256 = PrimeEmbeddedBuildProvenance.sourceIdentitySHA256
fixtureMode = "prepublication_held" | "orphan_transition"
executionPhase = "post_spawn_join" | "prepublication_child_discovery" |
                 "orphan_death_wait" | "orphan_initial_census" |
                 "primary_containment"
containmentState = "armed" | "exact_reaped" | "conservation_complete"
deadlineExpired = <monotonic deadline comparison boolean at catch entry>
failureStatus = 70
failureCoordinate = <exact bounded internal Governor failure coordinate>
admittedDeviceID = <held diagnostic preimage device id>
admittedInode = <held diagnostic preimage inode>
fixedFailStopStatus = 70
```

The canonical bytes contain no trailing line feed, path, PID, timestamp,
localized description, prose field, or self-digest and may not exceed `1,024`
bytes. GovernorCore writes the bytes once through an EINTR-safe bounded
`pwrite`-all loop at explicit offsets so the duplicated descriptor's shared
open-file-description offset remains zero, performs `fsync` plus `F_FULLFSYNC`,
changes the mode to `0400`, synchronizes again, reads the exact bytes back,
requires canonical
byte equality, and revalidates the same device/inode, one link, owner, size,
group, flags, descriptor access/close-on-exec state, offset, and xattrs. The
postimage must be the same device/inode, uid/gid, one link, `st_flags == 0`,
mode `0400`, exact canonical size and bytes, and the exact named leaf must join
the admitted device/inode carried in the record during postmortem. Missing,
partial, unfrozen, noncanonical, unjoined, untyped-error, or non-70 data
remains `ABSTAIN`. `fixedFailStopStatus` states the source-level action that
follows publication; it is not by itself a process-terminal observation.

Diagnostic publication is best-effort only with respect to containment. Every
thrown publication or validation error is caught, after which the existing
`_exit(70)` lexically follows. There is no retry, return, thrown replacement
error, stderr record, fallback channel, or weakened containment path. No claim
is made about uncatchable traps, signals, or kernel termination.

The exact R6 source allowlist is:

1. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernorCore/PrimeValidationDriverV2ShotGovernor.swift`
2. `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift`
3. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift`

Out of scope are every manifest, SessionFixture source, production Governor or
Supervisor `main.swift`, DriverCore bridge or planner, role table, receipt,
journal schema, `.github` path, Gate D parser, Gate E production capsule, and
Gate F/G/H surface. No product, target, test case, or selected-method
identifier is added. The eight missing process-derived authorities and vector
`00000000` are unchanged.

Because R6 modifies existing files only, topology remains exactly `548`
admitted files, `547` source-identity records, `112,279` canonical-record
bytes, `155` held Prime authority directories, `703` Prime watchers, and
`2,163 / 4,096` combined watchers. After the two code paths are final,
independent calculators must agree on aggregate admitted bytes and the new
source identity; only then may the excluded provenance file be resealed, and
both calculators must reproduce the result again.

R6 terminates in one clean, three-path source commit with no Swift command,
executable launch, cleanup, or R5-root mutation. It may be followed only by a
separate static source checkpoint and then a separately frozen fresh-epoch
Release diagnostic. No execution is authorized by this freeze or by its
implementation commit.

## Gate E1.4-R6-C1 correction — inherited fixture group binding

| Coordinate | Corrected value |
| --- | --- |
| Status | `FROZEN_CONTROL_CORRECTION_NO_SOURCE_EXECUTION` |
| Durable-control predecessor | R5 result / R6 freeze `07742fedda3c9f24acc212e1fe89c792b7ac332b` / tree `93546cf6329507e23d92cd80465664e10c54c98e` |
| Measured process identity | effective UID/GID `501 / 20` |
| Retained R5 fixture identity | base and published files UID/GID `501 / 0` |
| Correct owner rule | base and leaf UID equals effective UID; leaf GID equals the held base's admitted GID; that exact GID is conserved |
| Source allowlist / commands / launches | unchanged three paths / `0` / `0` |

R6's phrase “current uid and gid” meant the current admitted vnode fields, not
an assertion that a newly created file's group equals `getegid()`. The retained
R5 APFS data makes that distinction material: the XCTest process has effective
GID `20`, while its private `/private/tmp` Fixture bases and files inherit GID
`0`. Requiring `st_gid == getegid()` would reject the measured fixture policy
before the diagnostic child interval and would replace data with an incorrect
process-identity assumption.

The corrected admission is exact, not permissive. LiveTests requires the held
base to be a UID-owned mode-`0700` directory, captures its GID, creates the leaf
relative to that descriptor, and requires the leaf GID to equal the captured
base GID. GovernorCore captures that admitted leaf GID and requires the held
and named preimages to agree. Both owners then conserve the exact captured GID
across every normal-return or frozen-postimage revalidation. An arbitrary GID,
a base/leaf GID mismatch, or later GID drift is rejection.

This correction changes no leaf name, record field, process, deadline, census,
containment, durability, topology, source allowlist, or authority vector. It
authorizes no Swift command and must precede the R6 source checkpoint.

## Gate E1.4-R6 source checkpoint — held-vnode fail-stop diagnostic

| Coordinate | Checkpoint value |
| --- | --- |
| Status | `SOURCE_CHECKPOINTED_STATIC_ONLY_NOT_EXECUTED` |
| Durable-control freeze | R6 `07742fedda3c9f24acc212e1fe89c792b7ac332b` / tree `93546cf6329507e23d92cd80465664e10c54c98e`; inherited-GID correction `93bc44f13340905fba35e5090321cf37bb1ad201` / tree `f17962ee2626fe0640dcc39b4781a75b5b518d80` |
| Source predecessor | `7fbd52386283295d6312b57dbcb3acd97b1b5bce` / tree `dd45c962af0683db73c1e2785e7232b243d628d9` |
| Source checkpoint | `d408680dec3bebe64251903c0d7526d98efab2d7` / tree `894ba2b82614a19e094a2124f1e8f936c5b7f2d5` |
| Parent relation | exactly one parent, the frozen source predecessor |
| Source delta | exactly `3` modified mode-`100644` paths; `790` insertions / `5` deletions |
| Swift build / test / executable launch | `0 / 0 / 0` |
| Dependency resolution / fetch / network / GitHub | `0 / 0 / 0 / 0` |
| Production attempts / authority vector / Gate-E clearance | `0 / 00000000 / 0` |

The exact successor files are:

| Path | Lines / bytes | Blob / SHA-256 |
| --- | ---: | --- |
| `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` | `13 / 546` | `9ea686a51515f4ed9d5519a2dfb51b411a1385a2` / `87d8b9a6719d420340bdc7501cbc8c0353b4bd4789a6dcfc90ebb3b5267c8a87` |
| `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernorCore/PrimeValidationDriverV2ShotGovernor.swift` | `5,894 / 225,620` | `da5f4c593f60f14d0d951a0d5c737d05e89b3438` / `0eaf7c7d94a073b550cdd130f968f54d5344508fea251893114fdcc9c4a125a5` |
| `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` | `6,760 / 243,977` | `53cc3cc5cb16966435384cf6483dd8715971c95a` / `66a4c527b09a3f0bfb0dbed354c8a61e7474b413ea770bb8a39608f883200af7` |

Independent Python and Ruby calculators each reproduced the R6 predecessor
identity from its immutable Git tree and then agreed on the successor before
and after the excluded provenance reseal:

| Quantity | R6 predecessor | R6 successor |
| --- | ---: | ---: |
| Admitted files | `548` | `548` |
| Identity records | `547` | `547` |
| Canonical record bytes | `112,279` | `112,279` |
| Aggregate admitted bytes | `22,458,595` | `22,488,186` |
| Capture-enumerator directories | `146` | `146` |
| Held authority directories | `155` | `155` |
| Prime / combined watchers | `703 / 2,163` | `703 / 2,163` |
| Source identity SHA-256 | `77d5cfa3d9b9fc7054a40b0651940641d0da1d52afee197ce178b3c480446b76` | `9a46327485eb257fb835bda48758267324c090731fe9ce7e2a3074b8afc4687d` |

The pinned companion independently remains clean at
`163fc100710ece48119bc25954452d10f6a84f7f` / tree
`9009daa4f8a07fbd5897e00b9571cef44ec292db`, with `1,306` held files,
`154` held directories comprising the working-tree root plus `153`
non-`.git` directories, and `1,460` watchers. The root `.git` directory is a
separately recorded and joined entry in the held root inventory; it is not a
held directory or watcher, and its descendants remain excluded. The combined
count therefore remains `2,163 / 4,096`. The provenance file equals the
canonical excluded template byte-for-byte and contains the successor digest
exactly once.

Static implementation predicates are:

```text
changed_paths = 3
session_fixture_test_seam_definitions/call_sites = 1/2
new_held_diagnostic_argument_definitions/call_sites = 1/2
fixed_leaf_literals = 2
test_empty_conservation_checks = 3
positioned_write_definitions/call_sites = 1/1
best_effort_publication_definitions/call_sites = 1/1
canonical_record_fields = 11
new_Process/new_CommandLine/new_posix_spawn/new_Darwin_exit = 0/0/0/0
```

LiveTests creates the one exact leaf by exclusive descriptor-relative open
after the retained rebound case and immediately before the first SessionFixture
call. It freezes the held base and leaf, requires UID ownership, binds the leaf
GID to the observed held-base GID, and rejoins the exact named vnode. The same
held `O_CLOEXEC` leaf enters both package-test calls; a normal return from each
must leave the full empty mode-`0600` preimage unchanged.

GovernorCore duplicates and immediately constrains that held descriptor before
spawn. It records the closed fixture mode, last body phase, containment state,
deadline-expiry bit, status-70 internal coordinate, admitted device/inode, and
fixed source-level fail-stop status. Only the existing defer-containment catch
may attempt one canonical publication. Its explicit-offset write, full sync,
mode-`0400` freeze, exact reread/decode, descriptor-state conservation, and
held/named vnode join all precede the unchanged lexical `_exit(70)`. Every
thrown publication error is caught only so the fail-stop follows; missing or
invalid data remains `ABSTAIN`.

Two independent static implementation reviews found no compile-shape blocker
after the measured inherited-GID correction. That is static source evidence,
not a compile or runtime claim. No manifest, SessionFixture source, production
`main.swift`, DriverCore, planner, role, capsule, journal, test identifier,
GitHub path, or Gate D/F/G/H surface changed. R5's epoch and five forensic roots
remain retained and unmodified.

This checkpoint authorizes no execution. A later diagnostic requires a
separately committed R7 readiness freeze on this exact source commit, tree, and
identity, a fresh private epoch, and one exact Release selected-test command.

## Gate E1.4-R7 freeze — one held-vnode Release diagnostic

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | R6 source checkpoint `71c6ac4b70c2c733ad46d77b11afb72a2119610a` / tree `c7b1324e76b6d471bc8e00ef58dc2582dfca7c0f` |
| Source commit/tree/identity | clean `d408680dec3bebe64251903c0d7526d98efab2d7` / `894ba2b82614a19e094a2124f1e8f936c5b7f2d5` / `9a46327485eb257fb835bda48758267324c090731fe9ce7e2a3074b8afc4687d` |
| R7 epoch | `/private/tmp/gate-e1-4-mechanics-r7-d408680d-9a46327485eb257f`; absent before this freeze |
| Authorized SwiftPM commands | exactly `1`: one Release `swift test`; no `--skip-build` |
| Selected XCTest methods | exactly the existing one anchored identifier |
| Overall wall ceiling | `900` seconds |
| Process credentials / initial cwd | effective UID/GID `501 / 20`; exact clean source worktree root |
| Production attempts / authority vector | `0 / 00000000` |
| Fetch / network / GitHub | `0 / 0 / 0` |

R7 is a new diagnostic on the R6 source identity, not an R5 retry and not a
containment repair. After this freeze is committed, create the fresh epoch and
require its no-follow root to be UID-owned mode `0700` with an inventory equal
to exactly the nine private mode-`0700` children `home`, `config`, `tmp`,
`git-template`, `swiftpm-cache`, `swiftpm-config`, `swiftpm-security`,
`clang-module-cache`, and `swiftpm-module-cache` once. Rejoin every no-follow
path/device/inode and require all nine children empty before the command. R0,
R1, R3, and R5 epochs
and all five R5 forensic roots remain retained and forbidden for reuse or
cleanup.

Define `rho7` as replacement of the sole R5 root string

```text
/private/tmp/gate-e1-4-mechanics-r5-7fbd5238-77d5cfa3d9b9fc70
```

with

```text
/private/tmp/gate-e1-4-mechanics-r7-d408680d-9a46327485eb257f
```

throughout R5's exact finite `env -i` map and cache/config/security CLI paths.
Every other key and value, `umask 077`, stdin `/dev/null`, package path,
existing default `.build` scratch path, Xcode tool/SDK path, offline Git map,
and SwiftPM flag remains byte-for-byte unchanged. Observer timing uses the
command runner's wall clock; timing adds no observer process or `date`
invocation and does not change the one SwiftPM command count.

The frozen inputs and R5 build preimages are:

| Input | Exact R7 preimage |
| --- | --- |
| Package build root | device/inode `16777231/17179422`; existing default `Tests/PrimeValidationWorkflow/.build` only |
| Root manifest / lock | `fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81` / `bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375` |
| Nested manifest / lock | `753f42251e768faaee3686da38e6f6bf7de048526199445f0e11c088af53dada` / `d70a43567cbd3be75083ab147020b86b055513020d95632f8286f60913c9374a` |
| Workspace state | `1,704` bytes; SHA-256 `8eeb391d590b20e5eec603ab9d078757f2106a29467a7ff079194278bba921bf` |
| MLX checkout | clean `d37885a278f1c37484a94d0f401a418735e66519` / tree `5310749549cca107fc1bb07d82dacf043bc02b9e` |
| Numerics checkout | clean `0c0290ff6b24942dadb83a929ffaaa1481df04a2` / tree `4560bfb65f2c26cbd159c3e1a9cbf01600bace1b` |
| SessionFixture source / image | SHA-256 `c42e91519d8a792145a7478963e56ec92ddb7bdbf709a960b363241fd88305ab`; image device/inode `16777231/17382060`, `53,072` bytes, SHA-256 `177a18c20bc42486c77b52af4c472be222dec1baabf8973ece7b2d44ea92756e`, UUID `2EBB880A-D28B-32FF-9B7E-EB868AF5D9B6` |
| GovernorCore source / object / module | source SHA-256 `0eaf7c7d94a073b550cdd130f968f54d5344508fea251893114fdcc9c4a125a5`; object device/inode `16777231/17387443`, `2,185,384` bytes, SHA-256 `13c58ace3b6bc30a1c2de6143bbe3f179dd0cebde91f629b1440b8be1dc9b0b5`; module device/inode `16777231/17387439`, `279,816` bytes, SHA-256 `d0edeed6d6b7033ced04011e85bd3476986dc3bdf1909fe2189c569fe540044e` |
| GovernorCore diagnostic | retained inode `17383411`; clean `268` bytes; SHA-256 `2c72d5afff8cce441f2f8299a18215b0bf79605aa7eb05839e38f7949b46c0e2` |
| LiveTests source / object / module / diagnostic | source SHA-256 `66a4c527b09a3f0bfb0dbed354c8a61e7474b413ea770bb8a39608f883200af7`; object device/inode `16777231/17387483`, `2,723,512` bytes, SHA-256 `fa02d1caf9be90c611253b169b567e556bcaae90471c09d5da82d637e15c034e`; module device/inode `16777231/17387474`, `200,924` bytes, SHA-256 `1f60edd84e7b365117705c5cd9b3b785a610806a6bb07c4c4ba11996fdeb20ae`; aggregate DriverCoreTests diagnostic `592` bytes, SHA-256 `61b5974155fa1e0fafa45b9ed0a13f808c78bebb297d00dc54b49f43339b35d0`, containing only the pre-existing unreachable-code warning |
| Embedded provenance source | `546` bytes; SHA-256 `87d8b9a6719d420340bdc7501cbc8c0353b4bd4789a6dcfc90ebb3b5267c8a87`; canonical R6 template |
| ShotGovernor | device/inode `16777231/17387463`; `48,698,952` bytes; SHA-256 `383724ac78b86b2bb0c6e5b3499b56ccd219cc2963fd2cdfd9662363333b32fb`; UUID `DD524F45-91F6-3254-BE83-6EBCE5C12CFD` |
| DriverV2Supervisor | device/inode `16777231/17387436`; `48,029,880` bytes; SHA-256 `f3df1071ba0a105825f7ae8879ecbf791de71034e190cc428a739222fc42be95`; UUID `46E79B3B-22EE-30B2-A266-82E0664716BB` |
| SecureChildIntegration | device/inode `16777231/17387405`; `51,271,120` bytes; SHA-256 `a473a1d0d22335b88059a84bc4de57459d9b7363d2d19190c418bca4fa40299b`; UUID `34144441-3267-3AE0-96A4-381BE6EBE8D8` |
| XCTest executable | device/inode `16777231/17387503`; `57,803,920` bytes; SHA-256 `d2540ec6202c5360bf930dcd951980ff52bf6dad605157f03a749903d2c7cfb1`; UUID `00C5C75A-A3B4-3C49-9F30-BE89D326A0DF`; one selected-method strings record |

Every recorded image is a regular arm64 Mach-O, mode `0700`, one link,
flags `0`, and has only the exact `com.apple.provenance` xattr. The object and
module are regular mode-`0600`, one-link, flags-`0` files with the same sole
xattr. SessionFixture contains none of the historical source identities. The
other four images contain the R5 identity
`77d5cfa3d9b9fc7054a40b0651940641d0da1d52afee197ce178b3c480446b76`
exactly once and the R7 identity zero times. These are build preimages, not
launch authority.

The exact reserved production root
`/private/tmp/prime-driver-v2-gate-e-release-9a46327485eb257fb835bda48758267324c090731fe9ce7e2a3074b8afc4687d`
is absent and forbidden. The two historical production roots remain retained
and are not R7 inputs. The scoped admission inventory before R7 is exactly the
historical `20260803-c` root plus the five named R5 forensic roots. The scoped
public-admission inventory is empty.

The command block below is argv only. It is authorized exclusively as the
child of `umask 077` and the fully resolved `rho7` finite `env -i` map frozen
above, with effective credentials `501 / 20` and initial cwd exactly
`/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging`.
An ambient-environment execution or a different cwd is forbidden. `USER` and
`LOGNAME` environment strings are not credential evidence.

Run exactly once:

```sh
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift test \
  --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow \
  --configuration release \
  --scratch-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build \
  --cache-path /private/tmp/gate-e1-4-mechanics-r7-d408680d-9a46327485eb257f/swiftpm-cache \
  --config-path /private/tmp/gate-e1-4-mechanics-r7-d408680d-9a46327485eb257f/swiftpm-config \
  --security-path /private/tmp/gate-e1-4-mechanics-r7-d408680d-9a46327485eb257f/swiftpm-security \
  --disable-netrc --disable-keychain --force-resolved-versions \
  --disable-automatic-resolution --disable-sandbox --disable-swift-testing \
  --filter '^PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEJournalChainOneWinnerAndPoisonAreExact$' \
  </dev/null
```

Starting the Swift command consumes R7. Normal SwiftPM compilation and linkage
are harness telemetry. No target executable other than the XCTest runner and
the test-held SessionFixture children may launch. ShotGovernor, production
Supervisor, fixed Git/Swift roles, SpawnCanary, FixtureChild, and
SecureChildIntegration launch counts remain zero. No retry, same-epoch reuse,
cleanup, production root, or authority promotion is authorized after any
result.

Every non-`ABSTAIN` R7 path first requires a fresh R7 build frontier. The final
GovernorCore object and module must be no-follow joined terminal files with
different SHA-256 from their frozen R5 preimages and mtime/ctime inside the R7
command interval. The final LiveTests object and DriverCoreTests module must
likewise differ from
`fa02d1caf9be90c611253b169b567e556bcaae90471c09d5da82d637e15c034e`
and `1f60edd84e7b365117705c5cd9b3b785a610806a6bb07c4c4ba11996fdeb20ae`,
with every terminal tuple and retained-versus-replaced inode transition
recorded. The final XCTest executable must be a
regular no-follow successor with a different device/inode and SHA-256 from
`16777231/17387503` and
`d2540ec6202c5360bf930dcd951980ff52bf6dad605157f03a749903d2c7cfb1`.
Its strings must contain the R7 identity
`9a46327485eb257fb835bda48758267324c090731fe9ce7e2a3074b8afc4687d`
exactly once, the R5 identity zero times, and the selected-method substring on
exactly one strings record. Record the GovernorCore and DriverCoreTests
diagnostic transitions even if their canonical diagnostic payload is
unchanged. Failure of any freshness join keeps compile, mechanics, and
diagnostic results `ABSTAIN`.

There are three disjoint R7 outcomes:

1. A normal XCTest terminal with shell exit `0`, exactly one selected test
   passed, zero failures/skips, an exact new admission-root delta of `0`, and
   all existing mechanics predicates satisfied yields
   `R7_mixed_test_host_mechanics = PASS`; no fail-stop record is expected.
2. A missing XCTest terminal may yield
   `R7_fail_stop_diagnostic = PASS` only if the exact new admission-root delta
   is `5`, comprising main, collision, concurrent, terminal-collision, and
   rebound roots, and exactly one—the main root—contains the exact leaf
   `gate-e-session-fixture-fail-stop.json`. The postmortem predicates below
   must all pass. Any additional or missing root is rejection. Mechanics
   remains `ABSTAIN`; the diagnostic closes only the failure-coordinate
   observation.
3. A compile failure, timeout, ordinary test failure, or missing/empty/partial/
   writable/noncanonical/unjoined diagnostic after a missing terminal consumes
   R7 with both mechanics and diagnostic `ABSTAIN`.

A diagnostic pass requires exact canonical bytes no larger than `1,024` and no
trailing line feed and exactly the R6 eleven-key set with no unknown key;
schema `prime_driver_v2_session_fixture_fail_stop_v1`; R7 source identity;
fixture mode `prepublication_held` or `orphan_transition`; execution phase
`post_spawn_join`, `prepublication_child_discovery`, `orphan_death_wait`,
`orphan_initial_census`, or `primary_containment`; containment state `armed`,
`exact_reaped`, or `conservation_complete`; a boolean deadline-expiry field;
failure and fixed-fail-stop statuses both `70`; a nonempty at-most-`256`-byte
`[a-z0-9_]+` coordinate; and nonzero admitted device/inode.

The leaf must be a mode-`0400`, one-link, flags-`0`, UID-owned regular file.
Its final no-follow device/inode must equal the admitted device/inode in the
canonical record and independently join the exact fixed named leaf. Its final
GID must equal the final held-parent GID, and the parent must remain a
UID-owned mode-`0700` private fixture root. The final leaf must have no extended
ACL and either no xattrs or exactly the sole `com.apple.provenance` xattr with
at most `65,536` value bytes; record the exact final xattr inventory and value
hash. A postmortem byte hash and full final metadata tuple are mandatory.

The canonical mode-`0400` leaf is externally checkable, but it is written,
synced, and frozen before GovernorCore's process-local postimage revalidation.
Therefore `R7_fail_stop_diagnostic = PASS` means only that the outer observer
independently validated the durable failure-coordinate record and final named
vnode. It does not prove that internal `revalidatePostimage` returned, recover
the original descriptor flags/offset, or externally prove admitted-to-final
xattr conservation. The record's fixed status states the source-level next
action and does not prove an observed process exit status.

After the command, record all build transitions, the complete new temporary-
root set, source/control and dependency cleanliness, manifests, locks,
workspace state, epoch identities, Git-template emptiness, reserved-root
absence, and a post-command process snapshot. Any new fixture root is retained;
none is cleaned. A valid coordinate may support only a separately frozen
semantic repair or a normal-return assessment. It cannot close a Gate-E bit or
authorize production.

The maximum transitions are:

```text
normal return:
R7_release_test_compile = PASS
R7_selected_xctest = PASS
R7_mixed_test_host_mechanics = PASS
R7_fail_stop_diagnostic = NOT_PUBLISHED_NORMAL_RETURN

durable fail-stop datum:
R7_release_test_compile = PASS
R7_selected_xctest = STARTED_NO_TERMINAL
R7_mixed_test_host_mechanics = ABSTAIN
R7_fail_stop_diagnostic = PASS

both paths:
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

## Gate E1.4-R7 result — ordinary pre-spawn XCTest failure

| Coordinate | Observed value |
| --- | --- |
| Status | `CONSUMED_ORDINARY_XCTEST_FAILURE_BEFORE_SESSION_FIXTURE_ENTRY` |
| Durable-control freeze | `d0d2872bf3722819fd376a97bfa9e56c32f31434` / tree `780bef82370b0d92d048e04e628486f7c4f95159` |
| Source commit/tree/identity | clean `d408680dec3bebe64251903c0d7526d98efab2d7` / `894ba2b82614a19e094a2124f1e8f936c5b7f2d5` / `9a46327485eb257fb835bda48758267324c090731fe9ce7e2a3074b8afc4687d` |
| Authorized Release `swift test` commands consumed | `1 / 1`; no retry |
| Release build | `PASS`; `Build complete! (195.89s)` |
| Selected XCTest | ordinary terminal `FAIL`; one test / one unexpected failure / zero skips in `10.918s` |
| Exact XCTest error | LiveTests line `6198`: `invalid("session_fail_stop_frozen_metadata")` |
| Admission-root delta / fail-stop leaves | `0 / 0` |
| SessionFixture / production attempts | `0 / 0` |
| Authority vector / Gate-E outcome / clearance | `00000000 / ABSTAIN / 0` |

The exact Release command reached a normal SwiftPM and XCTest terminal with
outer exit `1`. This is R7 outcome three: it is neither a normal mechanics
pass nor a missing-terminal fail-stop diagnostic. The source/control trees
were clean at their frozen commits; root and nested manifests and locks,
workspace state, both dependency checkouts, the empty Git template, and the
absent reserved production root remained exact. The R7 epoch remains retained
at device/inode `16777231/17390069`, UID/GID `501/0`, mode `0700`, flags `0`,
with exactly the same nine first-level children. SwiftPM populated only the
frozen cache/config/home/tmp descendants; the Git template remains empty.

The fresh-build frontier passed independently of the failed test:

| Product | R7 terminal identity |
| --- | --- |
| GovernorCore object | device/inode `16777231/17390652`; `2,344,520` bytes; SHA-256 `0c1a79690124aff8fa8b05505d559d091751d3d880a6b0b31e21d4b35e01bd9c` |
| GovernorCore module | device/inode `16777231/17390645`; `293,820` bytes; SHA-256 `f2699a9e6e90e2429556cfe481f180f792440a8d53901f3095207654ec934b6b` |
| LiveTests object | device/inode `16777231/17390684`; `2,834,488` bytes; SHA-256 `1b93706d86179fed9867c542e38b6e0722c16b9f1df95de2bc18ffce0273707f` |
| DriverCoreTests module | device/inode `16777231/17390678`; `209,764` bytes; SHA-256 `b77b99c13294628437d3d6d2f8e9add5eaa1ea9beccae2b67d6c316bf7a2de4b` |
| XCTest executable | device/inode `16777231/17390704`; `57,901,248` bytes; SHA-256 `9e98531150d3f4b79eec44e129493cf938aa03a6b47ad046fc98bd779f3e2fec`; UUID `1F69E202-7FCC-317A-9761-266D1A51DEF8` |

All five files are one-link, flags-`0`, sole-provenance-xattr successors with
timestamps inside the command interval. The four object/module hashes and the
XCTest vnode/hash differ from their frozen R5 preimages. The final XCTest
contains the R7 source identity exactly once, the R5 identity zero times, and
the selected-method substring on exactly one strings record. This closes only
R7 compilation freshness; it is not execution authority.

The scoped admission inventory after R7 is exactly the frozen historical root
plus the five R5 roots. Its sorted path-set SHA-256 is
`0c540b2d5c6845ac8c1a633d4f4caaa1d3f34dba8fb26804c7c75dbfa9d32738`.
No `gate-e-session-fixture-fail-stop.json` exists under `/private/tmp`.
Ordinary XCTest unwinding ran the five R7 `Fixture` cleanup defers, so no R7
fixture root remains. The exact error arises in
`GateESessionFixtureFailStopDiagnosticLeaf.init`, before
`openPinnedSessionFixtureExecutable()` and before either
`exerciseSessionFixtureForTesting` call. GovernorCore's publisher is therefore
unreachable in this execution, SessionFixture supervisor/passive-child launch
counts are structurally zero, and there are no diagnostic bytes or vnode to
validate. Targeted `lsof` found no retained handle; this environment denied a
global process-list snapshot, so no broader process-census claim is made.

The failing source predicate is identified independently by the held APFS
topology. The helper captures the base directory, creates exactly one regular
leaf with descriptor-relative `O_EXCL`, captures the base again, and then
requires its link count to be unchanged. Every retained R5 fixture root on
this same volume instead has exact arithmetic `st_nlink = 2 + direct entry
count`: the main root is `14 = 2 + 12`, the collision root is `9 = 2 + 7`,
and each of the remaining three is `12 = 2 + 10`. The authorized one-entry
transition therefore increments the base link count by exactly one. Requiring
equality makes the aggregate `session_fail_stop_frozen_metadata` guard false
before the diagnostic capability exists. This is not the inherited-GID rule:
the retained roots and representative files remain UID/GID `501/0`.

The terminal vector is:

```text
R7_release_test_compile = PASS
R7_selected_xctest = FAIL
R7_mixed_test_host_mechanics = ABSTAIN
R7_fail_stop_diagnostic = ABSTAIN
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

R7 is consumed. Its epoch and all R5 forensic roots remain retained. No R7
retry, cleanup, production launch, or Gate-E movement is authorized.

## Gate E1.4-R8 freeze — APFS post-create diagnostic admission repair

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_STATIC_SOURCE_REPAIR_NOT_IMPLEMENTED` |
| Durable-control predecessor | R7 result `c082059a22ab4ba86a02838787f691be1bb6f8dc` / tree `d9bf781c2b398f48b8197a9112762089ebb336b3` |
| Source predecessor | clean `d408680dec3bebe64251903c0d7526d98efab2d7` / tree `894ba2b82614a19e094a2124f1e8f936c5b7f2d5` / identity `9a46327485eb257fb835bda48758267324c090731fe9ce7e2a3074b8afc4687d` |
| Purpose | admit the exact authorized one-leaf APFS topology transition, then freeze the post-create parent/leaf state |
| Source allowlist | exactly LiveTests plus the excluded embedded-provenance reseal |
| GovernorCore / SessionFixture / manifests / production `main.swift` / DriverCore | unchanged |
| Swift build / test / executable launch | `0 / 0 / 0` during implementation |
| Production attempts / authority vector | `0 / 00000000` |
| Network / fetch / GitHub | `0 / 0 / 0` |

R8 is a test-helper admission-boundary repair, not an R7 retry and not a
containment, census, deadline, process, or production change. Preserve the
existing descriptor-relative exclusive create, exact fixed leaf, base and leaf
held descriptors, UID/GID/mode/flags/xattr policy, named-vnode join, empty
preimage, and all GovernorCore publication behavior.

Replace only the false pre-create/post-create parent link-count equality with
an overflow-safe exact `+1` transition. The pre-create and post-create base
must retain identical device/inode, owner UID/GID, directory type, mode,
flags, and admitted xattrs. The post-create base and leaf become the frozen
states for every later revalidation. The leaf must still be UID-owned, inherit
the frozen base GID, be mode `0600`, one-link, flags `0`, and empty. Do not
weaken the transition to “greater than,” permit a range, or omit the held/name
join.

Split the current compound `session_fail_stop_frozen_metadata` guard into
distinct bounded coordinates for base identity, base owner/type/mode/flags,
base link transition, base xattrs, and leaf owner/GID/mode/link/flags/size.
The coordinates are diagnostic only and must not enter the canonical
GovernorCore record schema or a production surface. No path, argv, environment,
role, callback, timeout, process API, or second owner may be added.

After implementation, independently reproduce the exact two-file diff,
recompute the complete Prime source identity, reseal the excluded provenance
template, and checkpoint the source without running Swift. A later Release
command requires its own R9 readiness freeze, fresh epoch, exact preimages, and
one-shot authorization. No command is authorized by R8 itself.

## Gate E1.4-R8 source checkpoint — APFS admission boundary repaired

| Coordinate | Checkpoint value |
| --- | --- |
| Status | `SOURCE_CHECKPOINTED_STATIC_ONLY_NOT_EXECUTED` |
| Durable-control freeze | `5c36eb948f294fe4aee835dd91ab4c071b166153` / tree `1feefbde57fbdd32d7d3b96fca120912d6dbebe9` |
| Source predecessor | `d408680dec3bebe64251903c0d7526d98efab2d7` / tree `894ba2b82614a19e094a2124f1e8f936c5b7f2d5` |
| Source checkpoint | `1bd9b9e2f30dc17e7983cb6f9bf0ae4831851efd` / tree `a2aff7d040c97c379161eec3ea0459f336cd9205` |
| Parent relation | exactly one parent, the frozen source predecessor |
| Source delta | exactly `2` modified mode-`100644` paths; `75` insertions / `19` deletions |
| Swift build / test / executable launch | `0 / 0 / 0` |
| Production attempts / authority vector | `0 / 00000000` |
| Network / fetch / GitHub | `0 / 0 / 0` |

The exact successor files are:

| Path | Lines / bytes | Blob / SHA-256 |
| --- | ---: | --- |
| `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` | `13 / 546` | `e7d2c31b569f8e9d9f902b197d3d7f10b16fd94f` / `a52048db1a099ee0e7bedfc545211d3dc664579bfac36c4dec9a1b0e54e39840` |
| `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` | `6,816 / 245,638` | `1c2c251fdd57668f939a796838ff44482447d702` / `df2e6803106d28d76d91b76a24d0d76bf887b40085c0a1936f384d3517eb73f2` |

Independent Python and Ruby calculators reproduced the R8 predecessor and
agreed on the successor:

| Quantity | R8 predecessor | R8 successor |
| --- | ---: | ---: |
| Admitted files | `548` | `548` |
| Identity records | `547` | `547` |
| Canonical record bytes | `112,279` | `112,279` |
| Aggregate admitted bytes | `22,488,186` | `22,489,847` |
| Capture-enumerator directories | `146` | `146` |
| Held authority directories | `155` | `155` |
| Prime / combined watchers | `703 / 2,163` | `703 / 2,163` |
| Source identity SHA-256 | `9a46327485eb257fb835bda48758267324c090731fe9ce7e2a3074b8afc4687d` | `e458c197935662e827596db947b5b432cf21a3001fb8b2478f8ac49d2737e128` |

The excluded provenance file is the exact canonical `546`-byte template and
contains the successor identity once and the predecessor identity zero times.
The companion pin and topology remain unchanged.

The implementation uses `UInt64.addingReportingOverflow(1)`, rejects overflow,
and admits only exact equality between the post-create base link count and the
checked partial value. Base identity, owner, type, mode, flags, link transition,
and xattrs and leaf owner, GID, mode, link count, flags, and size now each have
a bounded lowercase diagnostic coordinate. The old aggregate coordinate is
absent. Full post-create base and leaf descriptor states still become the only
later revalidation baselines, and the descriptor-relative named-vnode join is
unchanged.

Three independent static reviews found no source, scope, or likely Swift-shape
defect. GovernorCore, SessionFixture, manifests, production mains, DriverCore,
schemas, process behavior, test identifiers, and every other path equal the
predecessor. No `Process`, `CommandLine`, spawn, argv, environment, path loader,
callback, role, timeout, writer, or second authority surface was added.

This checkpoint authorizes no execution. Any R9 command must be separately
frozen on this exact source commit, tree, and identity and must use a new
private epoch. R7 remains consumed and is not retried.

## Gate E1.4-R9 freeze — repaired held-vnode Release diagnostic

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_NOT_EXECUTED` |
| Durable-control predecessor | R8 source checkpoint `727c562b4dc38eb7f771edc5c96bdd699e9dc0f1` / tree `aee169d3dadfb6dcc405ee6c0ae991d967310ff3` |
| Source commit/tree/identity | clean `1bd9b9e2f30dc17e7983cb6f9bf0ae4831851efd` / `a2aff7d040c97c379161eec3ea0459f336cd9205` / `e458c197935662e827596db947b5b432cf21a3001fb8b2478f8ac49d2737e128` |
| R9 epoch | `/private/tmp/gate-e1-4-mechanics-r9-1bd9b9e2-e458c197935662e8`; absent before this freeze |
| Authorized SwiftPM commands | exactly `1`: one Release `swift test`; no `--skip-build` |
| Selected XCTest methods | exactly the existing anchored identifier |
| Overall wall ceiling | `900` seconds |
| Process credentials / initial cwd | effective UID/GID `501 / 20`; exact clean source worktree root |
| Production attempts / authority vector | `0 / 00000000` |
| Fetch / network / GitHub | `0 / 0 / 0` |

R9 is a new diagnostic on the R8 source identity, not a retry of R7. After this
freeze is committed, create the exact R9 root once, require it UID-owned mode
`0700`, and no-follow join its path/device/inode. Its inventory must then equal
exactly the nine UID-owned mode-`0700` children `home`, `config`, `tmp`,
`git-template`, `swiftpm-cache`, `swiftpm-config`, `swiftpm-security`,
`clang-module-cache`, and `swiftpm-module-cache`; no-follow join every child and
require each child initially empty. All prior epochs and the five R5 forensic
roots remain retained and forbidden for reuse or cleanup.

Define `rho9` as replacement of the sole R7 root string

```text
/private/tmp/gate-e1-4-mechanics-r7-d408680d-9a46327485eb257f
```

with

```text
/private/tmp/gate-e1-4-mechanics-r9-1bd9b9e2-e458c197935662e8
```

throughout R7's exact finite `env -i` map and cache/config/security CLI paths.
Every other key and value, `umask 077`, stdin `/dev/null`, package path,
existing default `.build` scratch path, Xcode tool/SDK path, offline Git map,
and SwiftPM flag remains byte-for-byte unchanged. Timing adds no observer
process or `date` invocation and does not change the one SwiftPM command count.

The frozen inputs and R7 build preimages are:

| Input | Exact R9 preimage |
| --- | --- |
| Package build root | device/inode `16777231/17179422`; existing default `.build` only |
| Root manifest / lock | `fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81` / `bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375` |
| Nested manifest / lock | `753f42251e768faaee3686da38e6f6bf7de048526199445f0e11c088af53dada` / `d70a43567cbd3be75083ab147020b86b055513020d95632f8286f60913c9374a` |
| Workspace state | device/inode `16777231/17182550`; `1,704` bytes; SHA-256 `8eeb391d590b20e5eec603ab9d078757f2106a29467a7ff079194278bba921bf` |
| MLX checkout | clean `d37885a278f1c37484a94d0f401a418735e66519` / tree `5310749549cca107fc1bb07d82dacf043bc02b9e` |
| Numerics checkout | clean `0c0290ff6b24942dadb83a929ffaaa1481df04a2` / tree `4560bfb65f2c26cbd159c3e1a9cbf01600bace1b` |
| Provenance source / R7 object / R7 PrimeCore module | source SHA-256 `a52048db1a099ee0e7bedfc545211d3dc664579bfac36c4dec9a1b0e54e39840`; object `16777231/17390573`, `12,760` bytes, SHA-256 `0b4ccd026e72c1cf68d2e680c75e1aed2d10d0294f9916f370c5dac8911532d7`; module `16777231/17390522`, `22,992,744` bytes, SHA-256 `285a7d8a177a835aa720b9a9de3cdf6900735fd41c90abe7d4d31dcda3f6997b` |
| LiveTests source / R7 object / R7 module | source SHA-256 `df2e6803106d28d76d91b76a24d0d76bf887b40085c0a1936f384d3517eb73f2`; object `16777231/17390684`, `2,834,488` bytes, SHA-256 `1b93706d86179fed9867c542e38b6e0722c16b9f1df95de2bc18ffce0273707f`; module `16777231/17390678`, `209,764` bytes, SHA-256 `b77b99c13294628437d3d6d2f8e9add5eaa1ea9beccae2b67d6c316bf7a2de4b` |
| GovernorCore source / R7 object / R7 module | source SHA-256 `0eaf7c7d94a073b550cdd130f968f54d5344508fea251893114fdcc9c4a125a5`; object `16777231/17390652`, `2,344,520` bytes, SHA-256 `0c1a79690124aff8fa8b05505d559d091751d3d880a6b0b31e21d4b35e01bd9c`; module `16777231/17390645`, `293,820` bytes, SHA-256 `f2699a9e6e90e2429556cfe481f180f792440a8d53901f3095207654ec934b6b` |
| SessionFixture | `16777231/17382060`; `53,072` bytes; SHA-256 `177a18c20bc42486c77b52af4c472be222dec1baabf8973ece7b2d44ea92756e`; UUID `2EBB880A-D28B-32FF-9B7E-EB868AF5D9B6` |
| ShotGovernor | `16777231/17390669`; `48,754,152` bytes; SHA-256 `d9497cb0abd861b6499dd44a515e0fb375c34a0c70cfb65edc71653b9585b8af`; UUID `43060858-C987-3561-950B-4AC702221DEC` |
| DriverV2Supervisor | `16777231/17390643`; `48,029,880` bytes; SHA-256 `10d5ae4ba0618e91c1d46d8301a14e9878f4dfcb9ca1295e7338fa209682bf19`; UUID `A4FCB560-D340-38B4-96C1-23DCA83215FB` |
| SecureChildIntegration | `16777231/17390603`; `51,271,120` bytes; SHA-256 `8c1d8e2cae0553bde916b9b2cf0d8afbc7222d98fc3405262a9b9ffe3b762ff2`; UUID `49CD8DBD-62B8-3CBF-AA5F-6CF7ADEA9517` |
| XCTest executable | `16777231/17390704`; `57,901,248` bytes; SHA-256 `9e98531150d3f4b79eec44e129493cf938aa03a6b47ad046fc98bd779f3e2fec`; UUID `1F69E202-7FCC-317A-9761-266D1A51DEF8`; R7 identity once, R8 identity zero times, selected-method record once |
| Compiler diagnostics | PrimeCore and GovernorCore each `268` clean bytes / SHA-256 `2c72d5afff8cce441f2f8299a18215b0bf79605aa7eb05839e38f7949b46c0e2`; DriverCoreTests `592` bytes / SHA-256 `3a659c49947fa1ef3f236f4f60b2097b163d7076127510e4a7ab0122e3781dd8` |

Every listed object, module, and image is a one-link flags-`0` regular file
with only `com.apple.provenance`; images are arm64 mode `0700`, objects/modules
mode `0600`. They are build preimages, not launch authority. The scoped
admission set is exactly the historical `20260803-c` root plus the five R5
roots, the public-admission inventory is empty, and the exact R8 production
root
`/private/tmp/prime-driver-v2-gate-e-release-e458c197935662e827596db947b5b432cf21a3001fb8b2478f8ac49d2737e128`
is absent and forbidden.

Run exactly once:

```sh
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift test \
  --package-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow \
  --configuration release \
  --scratch-path /Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build \
  --cache-path /private/tmp/gate-e1-4-mechanics-r9-1bd9b9e2-e458c197935662e8/swiftpm-cache \
  --config-path /private/tmp/gate-e1-4-mechanics-r9-1bd9b9e2-e458c197935662e8/swiftpm-config \
  --security-path /private/tmp/gate-e1-4-mechanics-r9-1bd9b9e2-e458c197935662e8/swiftpm-security \
  --disable-netrc --disable-keychain --force-resolved-versions \
  --disable-automatic-resolution --disable-sandbox --disable-swift-testing \
  --filter '^PrimeValidationWorkflowDriverCoreTests\.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testGateEJournalChainOneWinnerAndPoisonAreExact$' \
  </dev/null
```

The command must be the child of `umask 077` and the exact resolved `rho9`
finite `env -i` map. Starting it consumes R9. No second Swift command, retry,
same-epoch reuse, cleanup, production root, or authority promotion is allowed.
Normal SwiftPM compiler/linker processes are harness telemetry. No target
executable other than the XCTest runner and the test-held SessionFixture
children may launch; ShotGovernor, production Supervisor, fixed Git/Swift
roles, SpawnCanary, FixtureChild, and SecureChildIntegration launch counts stay
zero.

Every non-`ABSTAIN` result requires a fresh R8 build frontier. The final
provenance object, PrimeCore module, LiveTests object, DriverCoreTests module,
and XCTest must be no-follow joined successors with timestamps inside the R9
interval and different hashes from the frozen R7 preimages. The final XCTest
must contain the R8 identity exactly once, the R7 identity zero times, and the
selected-method substring on exactly one strings record. GovernorCore and the
unchanged target images may remain exact or rebuild; record either transition.

R9 inherits R7's three disjoint outcome rules and exact postmortem predicates,
with R8 source identity
`e458c197935662e827596db947b5b432cf21a3001fb8b2478f8ac49d2737e128`
and the exact R9 epoch substituted. Normal exit `0`, one passed selected test,
no failure/skip, exact admission-root delta `0`, and all mechanics predicates
yields `R9_mixed_test_host_mechanics = PASS`. A missing XCTest terminal can
yield `R9_fail_stop_diagnostic = PASS` only for exact new-root delta `5`,
exactly one fixed mode-`0400` leaf in the main root, and an exact canonical R6
eleven-field record carrying that R8 source identity whose admitted
device/inode joins the final named vnode. Any compile failure, timeout,
ordinary test failure, wrong root delta, or invalid/missing record leaves both
mechanics and diagnostic `ABSTAIN`.

All new roots are retained. Record source/control and dependency cleanliness,
manifests, locks, workspace state, epoch inventory, Git-template emptiness,
reserved-root absence, build transitions, complete root delta, diagnostic
postimage if present, and the available post-command process/handle snapshot.
No R9 outcome can set an outer journal bit, authorize production, or grant
Gate-E clearance.

The maximum transitions are:

```text
normal return:
R9_release_test_compile = PASS
R9_selected_xctest = PASS
R9_mixed_test_host_mechanics = PASS
R9_fail_stop_diagnostic = NOT_PUBLISHED_NORMAL_RETURN

durable fail-stop datum:
R9_release_test_compile = PASS
R9_selected_xctest = STARTED_NO_TERMINAL
R9_mixed_test_host_mechanics = ABSTAIN
R9_fail_stop_diagnostic = PASS

ordinary failure or invalid postmortem:
R9_mixed_test_host_mechanics = ABSTAIN
R9_fail_stop_diagnostic = ABSTAIN

all paths:
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

## Gate E1.4-R9 result — valid fail-stop datum, frozen freshness rejection

| Coordinate | Observed value |
| --- | --- |
| Status | `CONSUMED_VALID_FAIL_STOP_RECORD_BUT_FROZEN_BUILD_FRESHNESS_REJECTED` |
| Durable-control freeze | `1c0d8a06dc59c82ab92386781e0eb38bf68f5fce` / tree `d93f7f29ff24647a8da7edde004d0b2a08346e5a` |
| Source commit/tree/identity | clean `1bd9b9e2f30dc17e7983cb6f9bf0ae4831851efd` / `a2aff7d040c97c379161eec3ea0459f336cd9205` / `e458c197935662e827596db947b5b432cf21a3001fb8b2478f8ac49d2737e128` |
| Authorized Release `swift test` commands consumed | `1 / 1`; no retry |
| Release build | `PASS`; `Build complete! (195.25s)` |
| Selected XCTest | started at `2026-08-23T18:39:50.214Z`; no XCTest case/suite or SwiftPM test terminal; the outer harness returned exit `1` |
| Outer Swift shell | exit `1`; not an observed inner status `70` |
| New admission roots / fixed leaves | exact `5 / 1` |
| Intrinsic retained-record validation | `PASS` |
| Frozen DriverCoreTests module freshness | `REJECT` |
| R9 mechanics / fail-stop diagnostic | `ABSTAIN / ABSTAIN` |
| Production attempts / authority vector / Gate-E clearance | `0 / 00000000 / 0` |

The R9 command built and linked the R8 source and entered the selected test.
It then terminated with the exact missing-XCTest-terminal shape. The scoped
admission set gained exactly five roots:

| Role | Retained R9 root | Device/inode; files / directories; residue |
| --- | --- | --- |
| Main | `/private/tmp/prime-validation-admission-tests-BFD21FC0-9AEA-4E76-A7ED-66BDD4FDCD14` | `16777231/17392535`; `66 / 32`; only root containing the fixed fail-stop leaf |
| Collision | `/private/tmp/prime-validation-admission-tests-C5AECB28-860A-46E3-AA8B-255A2353DE8B` | `16777231/17392623`; `26 / 29`; exact `10`-byte first-leaf collision SHA-256 `591e7ef56458a393c1831cddcecd0a3415848deb290b6ebac689d0656293e48f` |
| Concurrent winner | `/private/tmp/prime-validation-admission-tests-04CB7182-E6AC-46BC-BC8E-98DCA27BA43E` | `16777231/17392849`; `31 / 30`; `723`-byte terminal SHA-256 `fc92b004b31154d665c6e668a41a77e80d265a7cac187ec981b300dd7825dd79` |
| Terminal collision | `/private/tmp/prime-validation-admission-tests-54A24D44-4193-4278-9319-8BFB3A3827A3` | `16777231/17392911`; `31 / 30`; deliberate empty terminal SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| Rebound | `/private/tmp/prime-validation-admission-tests-F4D5BEA9-7A8A-4592-A01B-5C851D54135E` | `16777231/17392972`; `31 / 30`; `723`-byte rebound terminal SHA-256 `34299b6fb76f5c2fdbebe2858bba2b5c272de199a3af5eec943f8812c8d1ab72` |

All five roots are UID/GID `501/0`, mode `0700`, flags `0`. Their direct-entry
and link-count arithmetic remains exact: main `13/15`, collision `7/9`, and
the other three `10/12`. The five-root delta's sorted path-set SHA-256 is
`b5a681997e0eebb7e9207cccd9d929b35b1fd46a794f3cd3fd61b869b1864a9a`.
The complete eleven-root sorted path-set SHA-256 is
`4b7a0c36a26fa051bd58703538b60f3762b73a94e109a9b960abc743d7e66216`.

The exact retained diagnostic leaf is:

```text
/private/tmp/prime-validation-admission-tests-BFD21FC0-9AEA-4E76-A7ED-66BDD4FDCD14/gate-e-session-fixture-fail-stop.json
```

It is the exact named regular vnode `16777231/17393034`, UID/GID `501/0`,
mode `0400`, one link, flags `0`, and `408` bytes. It has no extended ACL and
only the `11`-byte `com.apple.provenance` xattr, value SHA-256
`b01372585adb6c87881e5cf3e1d7472972cdec3ef5ecd45f86d42498a2df536a`.
The parent is device/inode `16777231/17392535`, UID/GID `501/0`, mode `0700`,
and the leaf GID equals its parent GID. The file SHA-256 is
`72a4c0ab6b88c3d4deda001dcc444812245d946b91b0b968391b354606a7368d`.

Independent byte decoders agree that the leaf is compact sorted canonical
JSON, has no trailing line feed, and contains exactly the required eleven keys
with no unknowns:

```text
schema = prime_driver_v2_session_fixture_fail_stop_v1
sourceIdentitySHA256 = e458c197935662e827596db947b5b432cf21a3001fb8b2478f8ac49d2737e128
fixtureMode = orphan_transition
executionPhase = orphan_initial_census
containmentState = armed
deadlineExpired = false
failureStatus = 70
failureCoordinate = supervisor_stop
admittedDeviceID = 16777231
admittedInode = 17393034
fixedFailStopStatus = 70
```

The coordinate is `15` lowercase/underscore bytes. The admitted device/inode
joins both the final leaf and the fixed named path. These observations satisfy
every intrinsic R6/R7 record and vnode predicate. They do not prove
process-local postimage return, admitted-to-final xattr conservation, or an
observed process exit `70`.

The R8 object/link/runtime chain is present, but the complete frozen freshness
frontier is not:

| Product | R7 preimage -> R9 terminal |
| --- | --- |
| Provenance object | `17390573` / `0b4ccd02...` -> `17392418` / `9baacd40eca8c61e91e795ea32b10a18577ff6db037ffb0b255ad14ebf27dcc5` |
| PrimeCore module | `17390522` / `285a7d8a...` -> `17392356` / `61d9617eaa9f9b565ff0b31bbb2732e151aef0483687d82b0bce105afb071970` |
| LiveTests object | `17390684` / `1b93706d...` -> `17392517` / `9260a773322426ce328d24babb746d44d128c6979d0edaa438e70aebc99811ed` |
| DriverCoreTests module | exact retained `17390678`, `209,764` bytes, SHA-256 `b77b99c13294628437d3d6d2f8e9add5eaa1ea9beccae2b67d6c316bf7a2de4b`, mtime/ctime `1787508809` |
| XCTest executable | `17390704` / `9e985311...` -> `17392529`, `57,901,248` bytes, SHA-256 `4e0230361dda9fb23a8e66c751512cd10b330adae0a1e45a95ef91ccd9e95d9c`, UUID `4E968865-6BD0-3420-992B-BB777AD6CAC9` |

The provenance object, PrimeCore module, LiveTests object, and XCTest are fresh
R9 successors with timestamps inside the command interval. The XCTest contains
the R8 identity exactly once, the R7 identity zero times, and the selected
method on exactly one strings record. GovernorCore object/module and
SessionFixture remain allowed exact preimages. ShotGovernor, Supervisor, and
SecureChildIntegration rebuilt with the R8 identity once and R7 identity zero
times; their launch counts are structurally zero and no launch evidence was
observed.

The frozen R9 authority nevertheless required the DriverCoreTests
`.swiftmodule` itself to have a new hash and timestamp for every non-`ABSTAIN`
result. It remained the exact R7 file. That is normal compiler behavior for a
private test implementation-only edit: the changed object is linked into the
new XCTest while the serialized module interface remains byte-identical. It is
not evidence that R8 was stale—the object/link/runtime chain proves the
opposite—but the committed R9 condition cannot be waived after execution.
Therefore R9's formal diagnostic classification is `ABSTAIN`.

The retained record still narrows the real mechanics failure. The first
prepublication SessionFixture call returned far enough for the second
`orphan_transition` call to begin. The body advanced through the death wait to
`orphan_initial_census`; its census then began unwinding. The defer's armed
containment called the preliminary `kill(-supervisorPID, SIGSTOP)` and rejected
at `supervisor_stop` with the shared deadline still unexpired. The record names
that defer-containment error, not the initiating census coordinate and not
successful containment.

Manifests, locks, workspace state, both dependency checkouts, source/control
worktrees, the empty Git template, and reserved production-root absence remain
exact. The R9 epoch remains at `16777231/17391900` with the same exact nine
first-level children. Targeted `lsof` found no handle on the five R9 roots;
the environment still denies a global process-list snapshot, so no broader
process-census claim is made. Nothing is cleaned.

The terminal vector is:

```text
R9_release_build_telemetry = PASS
R9_release_test_compile = ABSTAIN
R9_selected_xctest = STARTED_NO_TERMINAL
R9_build_freshness = REJECT_DRIVERCORETESTS_MODULE_RETAINED
R9_retained_fail_stop_record_intrinsic_validation = PASS
R9_mixed_test_host_mechanics = ABSTAIN
R9_fail_stop_diagnostic = ABSTAIN
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

R9 is consumed. It must not be retried and none of its five roots or prior
forensic roots may be cleaned. The data-supported next action is a no-execution
freshness-sufficiency correction for private implementation-only deltas, not a
repeat build. Only after that correction may a separately frozen source slice
change orphan containment semantics.

## Gate E1.4-R10 retained-evidence sufficiency adjudication — no execution

This is a successor adjudication over R9's frozen byte observations and
retained artifact identities. Its durable
predecessor is the R9 result commit
`11a6abff40bc9b15a11f2b398c951cae81669b1a` / tree
`ee0dcb5dc0c870f59d20efd7ccbb9d84a9e1be4e`. It runs no SwiftPM command,
build, test, XCTest/target binary, or production attempt; changes no source;
mutates no retained root or leaf; and does not amend the frozen R9 contract or
result. Ordinary read-only inspection and the control-tree checkpoint are not
scientific target execution.

The exact sufficiency predicate is:

```text
R10_sufficiency =
    S_source
    AND S_object
    AND S_link
    AND S_runtime
    AND S_module_neutral
```

All five terms must be true. No prose inference can substitute for a false or
unknown term.

### `S_source` — exact private implementation delta

- the source remains the clean commit/tree/identity
  `1bd9b9e2f30dc17e7983cb6f9bf0ae4831851efd` /
  `a2aff7d040c97c379161eec3ea0459f336cd9205` /
  `e458c197935662e827596db947b5b432cf21a3001fb8b2478f8ac49d2737e128`;
- R7 source `d408680dec3bebe64251903c0d7526d98efab2d7` to R8 changes exactly
  `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` and
  `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift`,
  `+75/-19`;
- the LiveTests source is blob
  `1c2c251fdd57668f939a796838ff44482447d702`, SHA-256
  `df2e6803106d28d76d91b76a24d0d76bf887b40085c0a1936f384d3517eb73f2`;
- apart from the provenance reseal, the delta is confined to the body of the
  existing private diagnostic-leaf initializer: it adds an overflow-safe
  admitted-base link-count `+1` transition and splits one aggregate rejection
  into exact local coordinates. It changes no import, declaration signature,
  stored-property layout, conformance, test identifier, or module-visible
  surface.

`S_source = true`.

### `S_object` — compiled implementation successor

- the LiveTests object is the joined R9 successor
  `16777231/17392517`, `2,838,280` bytes, SHA-256
  `9260a773322426ce328d24babb746d44d128c6979d0edaa438e70aebc99811ed`,
  with mtime/ctime inside R9 and different from the R7 preimage;
- the provenance object is successor inode `17392418`, SHA-256
  `9baacd40eca8c61e91e795ea32b10a18577ff6db037ffb0b255ad14ebf27dcc5`;
- the PrimeCore module is successor inode `17392356`, SHA-256
  `61d9617eaa9f9b565ff0b31bbb2732e151aef0483687d82b0bce105afb071970`.

`S_object = true`.

### `S_link` — fresh linked selected XCTest

The final no-follow-joined XCTest is `16777231/17392529`, `57,901,248` bytes,
SHA-256
`4e0230361dda9fb23a8e66c751512cd10b330adae0a1e45a95ef91ccd9e95d9c`,
Mach-O UUID `4E968865-6BD0-3420-992B-BB777AD6CAC9`. It is different from the
R7 XCTest, contains the R8 identity exactly once and the R7 identity zero
times, and contains the unchanged selected-method string on exactly one
strings record.

`S_link = true`.

### `S_runtime` — R8-only post-admission reachability

The scoped retained delta is the exact five-root set with SHA-256
`b5a681997e0eebb7e9207cccd9d929b35b1fd46a794f3cd3fd61b869b1864a9a`
and exactly one fixed fail-stop leaf. The source creates that leaf at a fixed
name with `O_EXCL`; the retained final named regular vnode is
`16777231/17393034`, SHA-256
`72a4c0ab6b88c3d4deda001dcc444812245d946b91b0b968391b354606a7368d`,
and passes the canonical eleven-key/no-line-feed, metadata, xattr, fixed-name,
and admitted-vnode joins recorded in R9. Its discriminating fields are:

```text
sourceIdentitySHA256 = e458c197935662e827596db947b5b432cf21a3001fb8b2478f8ac49d2737e128
fixtureMode = orphan_transition
executionPhase = orphan_initial_census
containmentState = armed
deadlineExpired = false
failureCoordinate = supervisor_stop
```

R7 rejected the same APFS parent-link transition at
`session_fail_stop_frozen_metadata` before it could emit this record. Under the
exact R8 source, reaching this leaf requires the overflow-safe `+1` transition
to pass, the held leaf to survive its fixed-name rejoin, the prepublication
call to return, the orphan call to pass the death wait and enter
`orphan_initial_census`, and the unwind to publish through GovernorCore. This
is positive runtime discrimination for the changed private body. It is not
containment completion or the original census error.

`S_runtime = true`.

### `S_module_neutral` — interface artifact is not implementation authority

For this exact unannotated private initializer-body delta, the DriverCoreTests
`.swiftmodule` may be the exact known R7 preimage or a fully recorded joined
successor. Exact retention is neutral, not affirmative evidence: the changed
machine implementation is in the rebuilt LiveTests object joined into the new
XCTest, while this delta adds no serialized declaration or explicitly emitted
body. Requiring a changed module hash therefore conflated interface freshness
with implementation freshness for this exact case. No general claim about
`.swiftmodule` contents follows.

The observed module is the exact allowed R7 preimage `16777231/17390678`,
`209,764` bytes, SHA-256
`b77b99c13294628437d3d6d2f8e9add5eaa1ea9beccae2b67d6c316bf7a2de4b`,
mtime/ctime `1787508809`. Unknown module drift would make this term false. Any
future declaration/interface delta makes this rule inapplicable and requires a
separately frozen interface-artifact predicate.

`S_module_neutral = true`.

Therefore the retained R9 data is sufficient to establish only that the exact
R8 private implementation was compiled, linked into the selected XCTest,
crossed the repaired APFS admission boundary, and emitted the intrinsically
valid R6 fail-stop record. The terminal adjudication is:

```text
R10_swiftpm_command_count = 0
R10_build_count = 0
R10_test_count = 0
R10_xctest_or_target_binary_launch_count = 0
R10_retained_evidence_sufficiency = SUFFICIENT
R10_R8_private_implementation_build_chain = PASS
R10_R8_post_admission_runtime_reachability = PASS
R10_intrinsic_fail_stop_record_validation = PASS
R10_R9_formal_reclassification = FORBIDDEN
R9_build_freshness = REJECT_DRIVERCORETESTS_MODULE_RETAINED
R9_fail_stop_diagnostic = ABSTAIN
R10_original_orphan_census_error = UNKNOWN
R10_containment_completion = NOT_PROVED
R10_observed_inner_exit_70 = NOT_OBSERVED
R10_mixed_test_host_mechanics = ABSTAIN
outer_journal_authority_vector = 00000000
production_attempt_count = 0
gate_E_scientific_outcome = ABSTAIN
gate_E_clearance_granted = 0
```

R10 authorizes no retry, new epoch, build, test, target-binary launch, cleanup,
source mutation, production attempt, journal bit, or Gate-E clearance. A
semantic repair requires a separately committed source freeze. The next freeze
must preserve the R9 fact that the monotonic death event was observed before
`orphan_initial_census` and preserve the semantic distinction between an
initiating body failure and a defer-containment failure. R10 selects no repair.

## Gate E1.4-R11 causal fail-stop freeze — diagnostic source only

| Coordinate | Frozen value |
| --- | --- |
| Status | `FROZEN_SOURCE_DIAGNOSTIC_ONLY_NOT_IMPLEMENTED` |
| Durable-control predecessor | clean `7539d97914134d3547fde37f62064262ea2ccdcd` / tree `fc0a0e1dcc6609d86c73a8f1980c2cbc2731aba6` |
| Source predecessor | clean `1bd9b9e2f30dc17e7983cb6f9bf0ae4831851efd` / tree `a2aff7d040c97c379161eec3ea0459f336cd9205` / identity `e458c197935662e827596db947b5b432cf21a3001fb8b2478f8ac49d2737e128` |
| SwiftPM / build / test / XCTest or target launch / production attempt | `0 / 0 / 0 / 0 / 0` |
| New epoch / root / leaf | `0 / 0 / 0` |
| Retained-root mutation / cleanup | `0 / 0` |
| Authority vector before / after | `00000000 / 00000000` |
| Gate-E scientific outcome / clearance | `ABSTAIN / 0` |

R11 exists only to preserve two causally distinct failures that R9 collapsed:
the initiating `orphan_initial_census` rejection and the later defer-containment
`supervisor_stop`. It records the immediate return/errno and the exact existing
death-watcher checks around that stop. It does not repair, accept, retry, or
reorder either operation.

### Retained predecessor boundary

The eleven admission roots remain present. Their newline-delimited sorted
path-set SHA-256 is
`4b7a0c36a26fa051bd58703538b60f3762b73a94e109a9b960abc743d7e66216`.
The R9 leaf remains the named vnode `16777231/17393034`, UID/GID `501/0`, mode
`0400`, one link, flags `0`, `408` bytes, SHA-256
`72a4c0ab6b88c3d4deda001dcc444812245d946b91b0b968391b354606a7368d`:

```text
/private/tmp/prime-validation-admission-tests-BFD21FC0-9AEA-4E76-A7ED-66BDD4FDCD14/gate-e-session-fixture-fail-stop.json
```

Its parent remains `16777231/17392535`, UID/GID `501/0`, mode `0700`; its sole
`11`-byte provenance xattr still has SHA-256
`b01372585adb6c87881e5cf3e1d7472972cdec3ef5ecd45f86d42498a2df536a`.
The reserved R8 production root
`/private/tmp/prime-driver-v2-gate-e-release-e458c197935662e827596db947b5b432cf21a3001fb8b2478f8ac49d2737e128`
remains absent and public admission inventory remains empty. R11 does not touch
any of these retained facts.

### Exact source allowlist

Exactly one direct source successor may change exactly these three paths:

1. `Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverV2ShotGovernorCore/PrimeValidationDriverV2ShotGovernor.swift` — private scalar causal capture, private v2 encoding, and a zero-argument value-only test fixture;
2. `Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests.swift` — assertions folded into the existing selected method only;
3. `Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift` — canonical source-identity reseal only, after the first two paths are final.

The existing package method signature, selected XCTest identifier, fixture
modes, SessionFixture binary, role table, facade, DriverCore, PrimeCore process
substrate, supervisor `main.swift`, manifests, locks, products, targets, Git and
Swift roles, production harness, and `.github/**` remain unchanged. The sole
new package symbol is the exact zero-argument, `Data`-only test seam frozen
below. No new XCTest method, path loader, caller input, callback, command
surface, or process capability is permitted.

### Exact private v2 record

The fixed leaf name remains
`gate-e-session-fixture-fail-stop.json`. A future fresh fixture may contain only
the private schema
`prime_driver_v2_session_fixture_fail_stop_v2`. The v1 R9 leaf remains retained
as historical evidence; the successor source has no live v1 publisher and no
dual-schema acceptance path.

V2 has exactly these twenty keys:

```text
admittedDeviceID: UInt64
admittedInode: UInt64
containmentState: closed existing enum
containmentStopAttemptSequence: UInt64
containmentStopDeathEventCheckPerformed: Bool
containmentStopDeathEventObserved: Bool
containmentStopErrno: Int32
containmentStopReturn: Int32
deadlineExpired: Bool
deathEventObservedAtContainmentFailure: Bool
deathWaitReturned: Bool
executionPhase: closed existing enum
failureCoordinate: String
failureStatus: Int32
fixedFailStopStatus: Int32
fixtureMode: closed existing enum
initiatingFailureCoordinate: String
initiatingFailureStatus: Int32
schema: String
sourceIdentitySHA256: String
```

`failureStatus` and `failureCoordinate` preserve their v1 meaning: the caught
defer-containment failure. The two `initiating*` fields hold the typed body
failure captured immediately before the same error is rethrown unchanged.

The byte contract is compact sorted canonical JSON, no trailing line feed,
exact keys with no unknowns, and at most `1,024` bytes. Both coordinates are
nonempty ASCII `[a-z0-9_]+`, each at most `128` bytes. With the longest closed
enum literals, two `128`-byte coordinates, maximum admitted identifiers and
errno, sequence `2`, and longest Boolean encodings, the frozen maximum
canonical frame is `1,021` bytes. Any encoding outside that bound is rejected
before publication.

The `1,021`-byte value is the closed codec envelope, not permission for a
broader scientific result. An accepted R11 causal datum additionally requires:

```text
fixtureMode = orphan_transition
executionPhase = orphan_initial_census
containmentState = armed
deathWaitReturned = true
containmentStopAttemptSequence = 1
failureStatus = 70
failureCoordinate = supervisor_stop
initiatingFailureStatus = 70
initiatingFailureCoordinate is in the closed census grammar below
fixedFailStopStatus = 70
deathEventObservedAtContainmentFailure = true
```

The closed initiating-coordinate grammar is exactly:

```text
session_census_capacity
session_census_duplicate_pid
session_census_duplicate_generation
session_census_nonconvergent_query
session_census_getsid_<errno>
session_census_bsdinfo_<errno>
session_census_getpgid_<errno>
```

Each `<errno>` is canonical unsigned decimal in `0...Int32.max`, with no sign
and no leading zero except the single byte `0`. `ESRCH` (`3`) is excluded from
the `getsid` and `getpgid` families because those exact source branches retry
instead of throwing. The `bsdinfo` family retains the full range because a
positive short return can reach its rejection independently of the
nonpositive-`ESRCH` retry. No other `session_census_*` value is valid.

Admitted device/inode are nonzero and source identity is the new exact embedded
identity. Other well-formed v2 shapes are not R11 causal data and remain
`ABSTAIN`; the implementation may fail closed by declining their publication.
The v2 constructor enforces the stop and monotonic relations:

```text
containmentStopAttemptSequence == 1
containmentStopReturn in {0, -1}
containmentStopReturn == 0  <->  containmentStopErrno == 0
containmentStopReturn == -1 <->  containmentStopErrno in 1...Int32.max
containmentStopDeathEventCheckPerformed
    <-> containmentStopReturn == -1 AND containmentStopErrno == ESRCH
NOT containmentStopDeathEventCheckPerformed
    -> NOT containmentStopDeathEventObserved
failureCoordinate == supervisor_stop
    <-> containmentStopReturn == -1
        AND NOT (
            containmentStopErrno == ESRCH
            AND containmentStopDeathEventCheckPerformed
            AND containmentStopDeathEventObserved
        )
deathWaitReturned -> deathEventObservedAtContainmentFailure
containmentStopDeathEventObserved
    -> deathEventObservedAtContainmentFailure
deathWaitReturned AND containmentStopDeathEventCheckPerformed
    -> containmentStopDeathEventObserved
executionPhase == orphan_initial_census
    -> fixtureMode == orphan_transition AND deathWaitReturned
```

`deathEventObservedAtContainmentFailure` is a later value-only snapshot of the
same existing death watcher. It records chronology only and cannot participate
in the stop guard, containment, retry, or exit decision. It may only reject an
internally contradictory diagnostic record. A death-event sequence is
intentionally omitted as redundant for this narrow slice: the existing watcher
has one false-to-true transition, and `deathWaitReturned` plus the later snapshot
bind the two relevant points. `containmentStopAttemptSequence` is a stop-attempt
coordinate, not a death-event sequence.

### Causal capture and attempt join

Add local value-only `initiatingFailure` and `deathWaitReturned` scalars to the
existing session-fixture exercise. After the already-registered function-level
defer, place the unchanged post-spawn body inside one lexical `do/catch`. On
throw, the catch copies status/coordinate from a typed private governor failure
and rethrows the identical error. Only then does the existing function defer
run, in the same order and with the same containment state. The caught `Error`
itself is never retained. An untyped initiating error makes v2 publication
ineligible; it does not acquire a synthetic coordinate.

In the orphan branch, evaluate the existing `deathWatcher.wait` exactly once
into a local Boolean, assign that exact value to `deathWaitReturned`, and apply
the unchanged guard to the same local. Do not call `hasObservedExit()` to
synthesize this value.

Do not change the private `SessionCensus.contain` signature. Extend the existing
private thrown governor failure with an optional value-only preliminary-stop
observation. At the existing stop, instrumentation must perform exactly:

```text
target = -supervisorPID                  # existing pid > 0 makes this representable
errno = 0
stopReturn = kill(target, SIGSTOP)
stopErrno = errno                       # immediate, before any lock/call
if stopReturn == -1 AND stopErrno == ESRCH:
    deathCheckPerformed = true
    deathObserved = existingDeathWatcher.hasObservedExit()
else:
    deathCheckPerformed = false
    deathObserved = false
apply the existing acceptance guard using only these captured locals
```

No errno read after telemetry or locking may affect the guard. No `EPERM`,
`EINVAL`, or other non-`ESRCH` result becomes acceptable. The stop target local
must flow directly to the existing `kill`; the return and immediate errno plus
the existing short-circuit watcher-check results attach to the thrown
`supervisor_stop` failure. The negative target is intentionally not retained in
the twenty-key record; its derivation is certified by the exact source identity
and static flow, not asserted as runtime telemetry.

The exact accepted phase/state proves the initiating failure occurred before
the first body containment call; therefore the caught armed defer invocation is
stop attempt `1`. Any body-containment attempt would advance phase to
`primary_containment` and make the R11 record ineligible. This source-flow join,
the attached stop tuple, and fixed sequence `1` prevent an earlier attempt from
being relabeled as the defer failure without adding a mutable parameter to the
production-shared containment function.

The defer catch snapshots the same watcher's observed bit for record validation,
then passes the initiating scalars and the caught typed status-70 containment
failure to the existing held-leaf publisher. Best-effort publication remains
immediately before the lexical, unconditional `_exit(70)`.

The stop target, signal, scans, retry bounds, deadlines, wait path, reaping,
containment decisions, leaf path, descriptor admission, positioned write,
sync/full-sync, mode transition to `0400`, named-vnode join, xattr conservation,
and fixed exit remain semantically unchanged.

### Existing-method assertions and zero-capability seam

Add one zero-argument package test-data method on the existing governor type,
named
`sessionFixtureCausalFailStopV2CanonicalFixtureForTesting()`. It returns only
canonical `Data` for a fixed synthetic v2 value and accepts no status,
coordinate, descriptor, path, PID, argv, environment, role, timeout, callback,
or input bytes. It cannot open, write, spawn, signal, wait, publish, consume, or
restore a capability. It is unreachable from capsule decoding and production
entry.

The fixed synthetic datum is:

```text
admittedDeviceID / admittedInode = 1 / 2
fixtureMode / executionPhase / containmentState
    = orphan_transition / orphan_initial_census / armed
deadlineExpired = false
deathWaitReturned = true
initiatingFailureStatus / coordinate
    = 70 / session_census_nonconvergent_query
failureStatus / coordinate = 70 / supervisor_stop
containmentStopAttemptSequence = 1
containmentStopReturn / errno = -1 / 1
containmentStopDeathEventCheckPerformed / observed = false / false
deathEventObservedAtContainmentFailure = true
fixedFailStopStatus = 70
sourceIdentitySHA256 = current embedded identity
```

The method internally requires rejection of these fixed malformed values before
returning the one valid datum: stop sequence `0` and `2`; return `0` with
nonzero errno; return `-1` with zero errno; observed-without-check; check with a
non-`ESRCH` failure; `ESRCH` without the check; `supervisor_stop` paired with an
accepted `ESRCH` plus observed death; `deathWaitReturned=true` with a later
false death snapshot; death-wait-returned=true with a performed-but-false stop
death check; and stop-check-observed=true with a later false death snapshot. It
also rejects an unknown census name, a missing errno suffix, a
signed suffix, a leading-zero suffix, a nondecimal suffix, numeric overflow,
`session_census_getsid_3`, and `session_census_getpgid_3`. This is a fixed
internal self-check bundle, not an arbitrary-input validation API and not
exhaustive proof of every constructor rejection.

The existing
`testGateEJournalChainOneWinnerAndPoisonAreExact` method, and no new identifier,
uses an independent private mirror to require exact canonical bytes, twenty
keys, scalar types/values, no line feed, decode/re-encode equality, and the
`1...1,024` bound. It also statically proves that the fixture method is
the package-scoped `static func ...() throws -> Data` inside the existing
`package extension`, appears exactly once as a GovernorCore definition and once
as a LiveTests call, has no process or filesystem primitive, and has zero
reference from governor main/capsule paths.
The method proves only that the fixed self-check bundle completed and the valid
fixture matched. Source slice/order assertions—not runtime semantic proof—bind
the lexical primary catch/rethrow, the same target local flowing to `kill`,
immediate errno capture, exact armed/phase join, defer publication, and following
`_exit(70)`.

### Static checkpoint and hard stops

R11 itself authorizes source editing, independent canonical identity
calculations, provenance resealing, read-only diff/static audits, and one clean
source checkpoint only. It authorizes no Swift command, build, test, child,
fixture, governor, supervisor, target binary, new root, production process, or
cleanup. The successor remains `548 / 547` files/identity records, `146 / 155`
enumerated/authority directories, `703 / 2,163` Prime/combined watchers, with
unchanged manifests, locks, dependency trees, and test identifiers.

Hard stops are any containment/death/signal/deadline/reap semantic change; a
second watcher or death owner; record-driven control; a parameterized encoder
or callback; a second diagnostic leaf, journal, receipt, root, or schema
publisher; a new test identifier or executable; stdout/stderr/prose fallback;
an API returning a live capability; a source path outside the three-path
allowlist; any R9 retry/waiver/cleanup; or any authority-vector, production, or
Gate-E promotion.

After implementation, a clean source checkpoint must bind the exact three-path
diff and independently recomputed source identity. Any later Release build or
selected diagnostic requires a new readiness freeze and a fresh epoch. A
missing, malformed, or causally unjoined v2 record remains `ABSTAIN`; it never
authorizes an automatic retry.
