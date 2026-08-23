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
from this record. A successor requires a new source identity and a separately
frozen, non-executing discrimination plan; prose may not promote this
incomplete observation to a Gate E conclusion.

A post-shot read-only metadata audit observed canonical paths equal to every
declared Prime, companion, workspace, evidence, and lease path. All five
device/inode pairs were distinct and stable across two reads; Prime and
companion were UID `501`, mode `0755`, and the three private roots were UID
`501`, mode `0700`. The inspected roots had no ACL and only the permitted
`com.apple.provenance` extended attribute. Those later observations make an
ordinary visible root-metadata rejection less likely, but cannot reconstruct
the exact in-process failure or exclude a transient pre-leaf lease error.
