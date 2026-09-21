# Prime / HyperVisor development flow

Version: **0.2.1** · Owner: **Ergentics, LLC** · Updated: **2026-09-21**

This is the continuation path for the maintained Hyper-Visor app in
`Apps/ErgenticsPrime`. It connects source custody, the two external Ergentics
profiles, scoped implementation, review and qualification. It is a
`PROVENANCE_FIX`; it changes no scientific protocol or execution permission.
EA-POLICY-001 v0.4.1 remains the adopted canonical policy. Surface has separate
work time.

## Published source and review boundaries

Repository: <https://github.com/Ergentics/ergentics-prime> (private).

| Reference | Purpose |
| --- | --- |
| `codex/prime-hypervisor-lineage-2026-09-20` at `ab4e7b8f17857c6249dcda7a3cf74df2e69319f7` | Preserved lineage and reviewed closeout merged by PR #138; the earlier closeout base `085d921` remains in history |
| `999d9f00f1950d2510a8a770bd69f69710501729`, tree `161079c5cc66c3434958d0803c73e78007200941` | Reviewed 144-file repair, Rust custody, assessment and Agent/profile source closeout |
| `codex/prime-hypervisor-closeout-2026-09-20` | Closeout review branch, including this later development-flow record |
| `main` | Separate integration destination; publication of the above branches does not update or qualify it |

At preparation, remote `main` was `a6f76bd3f246a443ef96e21fa4c769499a62b875`.
The current integration head is 340 commits ahead of that observation. The
focused closeout PR #138 merged into the lineage branch. Integration PR #139
targets main; its run 178 triggered but failed the inherited phase-specific
direct-parent admission check. It remains a separate qualification boundary.
Existing PRs #53–56 remain historical review work; their dispositions are unchanged.

These are source bindings and the intended publication layout. The publication
receipt must record successful pushes, fresh remote branch SHAs, commit/tree
readback and the actual PR URL before claiming `REMOTE_SHA_VERIFIED`. The
enclosing Git commit supplies this document's own identity; it cannot record
its own future hash. Keep the closeout commit and issued packages unchanged.

Read [the closeout](root-analysis-closeout-v1/README.md) and its
[source selection](root-analysis-closeout-v1/SOURCE-SELECTION.json) for the
earlier evidence, exclusions and validation limits. The complete evidence
archives remain in their explicitly bound local store. Source publication does
not upload those archives or make workstation-specific locators portable.

## Continue one bounded HyperVisor change

1. Read this flow, the [app roadmap](../../Apps/ErgenticsPrime/ROADMAP.md), the
   current task note and applicable policy. Record the actual repository,
   branch, full commit/tree, local delta and the question being implemented.
   Verify the remote tip before using it as a starting point. Start a new
   `codex/hypervisor-<topic>` branch from that exact verified commit; preserve
   unrelated local work and the published baseline.
2. Bind the implementation and review work through the
   [profile loader v0.1.1](../skills/ergentics-profile-loader/SKILL.md). The stable
   identities are `ergentics_swift_c` and `ergentics_cpp` in
   [Agents v0.1.0](../ergentics/agents/0.1.0/README.md), with
   [profiles v0.1.0](../ergentics/profiles/0.1.0/README.md). Give each a concrete
   partition and reviewed inputs. Use one writer per file and separate output
   directories. Choose available models for the task; record requested model
   and effort separately from observed loading and execution. Shared filesystem
   access is not isolation, and two responses do not prove model diversity.
3. State the intended behavior, affected gate family, acceptance checks and
   finite execution/output budget before changing code. Classify each material
   change as `IMPLEMENTATION_FIX`, `INSTRUMENTATION_FIX`, `PROVENANCE_FIX` or
   `PROTOCOL_AMENDMENT`. A change to frozen scientific semantics needs the
   applicable Ergentics decision. Routine authorized implementation proceeds.
4. Implement the selected change and run the relevant checks. Preserve both a
   useful benign case and a discriminating negative when changing a rejection
   boundary. Keep failed checks and later corrections. Bind the result to the
   tested source and, when applicable, the actual built image and environment.
   Do not label a parse, synthetic test or historical result as native success.
5. Reconcile the two profiles' findings against files and evidence. Preserve
   attributed originals and corrections. Record unresolved concerns and the
   next required qualification route in the existing task record. A source
   review may finish while a separately named native route remains held.
6. Review the exact selected diff, stage only its named files, and commit.
   Push the feature branch without force to this repository and read back its
   full SHA. Compare the remote commit/tree with the local source identity.
   Open or update a scoped draft PR against the intended development base,
   naming any stack dependency. Check current workflow triggers before remote
   writes; a later merge to `main` can invoke different execution routes.
7. Leave one handoff naming the verified branch/SHA/tree, PR, implemented
   behavior, checks, failures, remaining gates, evidence locations and the next
   action. Mark a PR ready or merge only within the user's applicable direction.

Repository-backed durability is recorded exactly as:

```text
LOCAL_DURABLE -> COMMITTED -> PUSHED -> REMOTE_SHA_VERIFIED
```

If push or readback fails, preserve the actual state and failure. Do not force a
remote ref, rewrite lineage or substitute an API-created commit and claim the
same Git identity. A different publication method must explicitly preserve or
account for changed identity.

## Native Agents candidate and the existing Actions path

Build24 adds the app's text workspace and a pinned native catalog containing
the two profiles, Prime custody method and eight reviewed lessons. Read the
[native contract](../../Apps/ErgenticsPrime/NATIVE-AGENTS.md) and
[source review](../../Apps/ErgenticsPrime/Distribution/Build24-source-review.json).
The catalog installs definitions and supports explicit task preparation. Its
local Prime experiment consumes the current message only; it does not ingest
the profiles or shared corpus. Hosted profile loading, native resource loading,
prepared exports and model execution remain separately evidenced.

Publish the reviewed feature commit without force and carry it into the existing
lineage branch only as a verified fast-forward. PR139 then supplies the ordinary
`pull_request` / `synchronize` event against main through
`.github/workflows/prime-active-root-quarantine.yml`. Do not create an alternate
workflow or use Codespaces for this app change. Read back the branch SHA and the
actual Actions outcome. The inherited V2 metadata admission remains unresolved;
source publication and GitHub mergeability do not clear that gate. This workflow
does not currently build the Xcode app. Keep local source tests, signed Release
build, installation and native interaction separate.

## Output, corpus and extension

Use the selected [shared corpus v0.1.0](../ergentics/corpus/0.1.0/README.md)
through explicit per-run references. Bind purpose, recipient/processing route,
inputs, tools and finite output/intermediate limits. Keep raw outputs in each
role's attributed directory; synthesize into the current task record only after
review. Output creation does not automatically add it to the corpus or grant
another Agent access to protected H7/H8 data.

Auto Harvest finished the bounded custody harvest 012 and is OFF (5/8 releases,
222,235/16,777,216 bytes in its existing local store). See the
[custody checkpoint](custody-harvest-012/README.md) for ten reviewed profile
controls, preserved corrections and the new selected
[contribution](../ergentics/corpus/contributions/prime-gate-phase-custody/0.1.0/INDEX.json).
For Prime gate/phase work use [Prime custody v0.1.0](../skills/ergentics-prime-custody/SKILL.md).
The candidate [profile package/helper v0.1.1](../ergentics/profiles/0.1.1/README.md)
repairs UTF-8 byte verification and passed 42 regression cases; its explicit
task use leaves installed packages and logical profile identities unchanged.
For a future authorized harvest, select a reviewed lesson and its evidence, retain the
failure and golden negative, enforce the declared store budget, and review the
candidate before promotion. No watcher or automatic ingestion is established by
this flow. The [Prime assessment v0.3.0](../skills/ergentics-prime-assessment/SKILL.md)
defines the assessment, harvest and extension method.

Preserve issued Agent, profile and corpus releases. Make behavior changes in a
new version with a changelog and focused validation. Keep Agent, profile,
corpus, skill, policy, app and this flow's versions distinct. Repository source
copies do not install packages or activate a native Agent registry; a different
workstation must explicitly bind its installed packages and canonical policy.

## Qualification remains tied to its own route

The maintained app's source includes the reviewed runtime repairs. Current
repaired-app, OS/guest and Rust native results remain open. Driver V2's frozen
admission requires exact Swift 6.3.3 and its target/runtime bindings; inspected
standard Xcode/CLT tools reported Swift 6.4. Do not generalize that Driver
requirement to unrelated HyperVisor editing or invent a new toolchain rule.

For a Driver V2 attempt, follow the existing
[durable phase control](../PRIME-SWIFT-VALIDATION-DRIVER-V2-DURABLE-PHASE-CONTROL-2026-08-22.md).
H requires accepted A–G and its concrete owner go/no-go, named intent, current
source/tree and live input/inventory/budget bindings. Publication, a draft PR
and a hosted check do not provide that authorization. No automatic scientific
retry follows a failure.

HyperVisor H1–H8, Driver V2 A–H, model checkpoint/resume, static bootstrap and
OS/Rust acceptance retain separate predicates. Historical Build23 host and ARM
guest-request modes both use host Metal; retained source and archives do not
establish a current boot or guest GPU result. H7/H8 do not admit arbitrary Agent
programs, shared-corpus retrieval or trusted cross-Agent egress.

## Change record

- **0.2.1 — 2026-09-21:** bind the native Agents Build24 source candidate,
  profile/corpus boundaries and the existing PR139 synchronization trigger.
  No new CI workflow, gate amendment or installation result.
- **0.2.0 — 2026-09-21:** add Prime gate custody, reviewed corpus contribution,
  per-profile positive/golden-negative evidence and compatible helper repair.
  Record PR #138 merge and PR #139 admission failure; no gate or native authority changed.
- **0.1.0 — 2026-09-20:** source publication and bounded development handoff,
  preserving Root Analysis closeout, released profiles and existing native
  qualification boundaries. No executable helper or CI workflow added.
