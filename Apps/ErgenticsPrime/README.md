# Current Prime app source: Build 24 candidate

The new **Agents** workspace adds saved text conversations, the two verified
Ergentics profiles, Prime custody method and eight reviewed corpus entries.
Its composer connects to the existing Ergentics Prime local checkpoint
experiment with real progress, stop and failure states. Profile/corpus task
exports remain distinct from the experimental model's input. See
[the native workspace contract](NATIVE-AGENTS.md).

Build 24 is under validation; source availability is not an installed-app or
native execution claim. This change follows ergentics-prime's existing
`prime-active-root-quarantine.yml` Actions route and repository admission.
The retained V2 phase transition remains a separate prerequisite for main
integration. No alternate workflow or Codespaces route is introduced.

## Build 23 checkpoint (historical)

The Prime page now runs the retained learned domain model and editable geometry inputs through bundled native services. Guest mode uses real ARM guest requests and host Metal; host mode is also available. The app saves inputs and raw outputs locally. The old Native-300M mechanics checkpoint is named “Stage 7 checkpoint experiment” in the Prime menu and is no longer the default interface.

The signed app executed 48 learned model forwards and four geometry dispatches through the same actions as the controls. This integrates runtime 0014 inference and runtime 0013 geometry; it does not complete model Stages 7–8, add general English knowledge, or select an OS. No training or dependency installation occurred.

For an opt-in executable app check, launch the signed app binary with only `--check-prime-services`. It runs 16 bounded local service requests, retains real results under the app's private PrimeComputeSessions and PrimeComputeChecks storage, and exits. Normal launch opens the interactive Prime workspace. Visual UI acceptance remains with the user.

---

# Ergentics Prime

Current app features, verification status and next work: see [ROADMAP.md](ROADMAP.md). The roadmap is the current status index; the sections below retain their original checkpoint dates.

One native Mac app brings together the Git workspace, virtual machines, Prime runtime and saved evidence. Open the `ErgenticsPrime` scheme in `ErgenticsProvenance.xcodeproj`; it builds the full existing application. The separate runtime-only prototype has been absorbed. The technical bundle ID and executable remain `com.ergentics.provenance` and `Ergentics Provenance` so existing signing and VM integration retain their identity.

Build 24 starts on **Agents** for text tasks and the local Prime checkpoint experiment. Use **Workspace** to open a repository, and **Git workspace**, **Virtual machines**, and **Prime** from the same window. The selected repository and runtime status are shared with Home. The separate Prime page loads three retained learned domain checkpoints and saves each run locally. VM selection is still independent; associating a repository, an OS guest and a compatible checkpoint remains open.

The current app's Git operations and Prime check run locally; they do not implement remote authentication or uploads. This is not a credential vault: selected file previews, patches and local Git history can contain secrets and are not automatically redacted. Visible text is readable by authorized accessibility tools and may be captured onscreen. Apple's legacy `NSWindow.SharingType.none` setting is not evidence of capture prevention; [Apple now describes it as a legacy constant macOS no longer uses](https://developer.apple.com/documentation/appkit/nswindow/sharingtype-swift.enum). Signed code and completed validation gates do not establish end-to-end secret containment.

Prime is the Ergentics model. Driver V2 gates E–H now have bounded live checkpoints, including the verified `6f656bb` F–H run. That validation does not complete model Stage 7, the quarantined StartOwner implementation, or real-OS guest acceptance. See the roadmap for those separate open items.

Git workspace requires Apple Command Line Tools or Xcode installed in its standard location. The app validates and directly uses that installation's Apple Git. Git is an external dependency, not bundled in the app; no installation or system configuration change is performed.


The maintained application source is now `Apps/ErgenticsPrime` in the authoritative Prime repository. Build 23 adds the working Prime model and geometry controls described above; the bundled native package and app-admitted service sources live in this app tree. Build 21's archive and installation observations remain historical in `Distribution/LocalArchive-1.0.21-receipt.json`. Earlier app source bundles, receipts and the StartOwner quarantine remain recovery/history inputs.

## Build the canonical app locally

Open `Apps/ErgenticsPrime/ErgenticsProvenance.xcodeproj` and select the `ErgenticsPrime` scheme. This Mac already has the ignored prerequisites beside the source: `BuildAssets.json`, `Tools/PrimeComputeNative/build02/` (both compiled services, `mlx.metallib` and their receipt), and `Resources/PrimeModel/` (the retained legacy checkpoint). The embed phase checks the recorded hashes before copying assets into the app.

`BuildAssets.json` has schema version 1 and three absolute directory paths: `taskRoot` for the retained task artifacts, `experimentCollection` for its `outputs/Prime-Experiment-Builds`, and `nativeRuntimeRoot` for the existing companion `prime-runtime` dependency cache. These machine-local paths and large assets are ignored by Git; a source checkout alone does not supply them. The three domain weights remain in the saved experiment collection and are copied into the signed app during embedding. The existing `build.py` can rebuild the services against the retained native cache; it is external build tooling and is not shipped as an app runtime.

From this app directory, use the existing local dependencies and build cache:

```sh
xcodebuild -project ErgenticsProvenance.xcodeproj -scheme ErgenticsPrime \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath '/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/work/prime-app-integration/DerivedData' \
  -jobs 2 -disableAutomaticPackageResolution -skipPackageUpdates \
  ONLY_ACTIVE_ARCH=YES build
```


This is one product lineage. The original fixed 92-byte guest proof and its
Rust successor are embedded historical execution fixtures inside the full
SwiftUI/AppKit Hypervisor host; neither is a separate application or submission.
The shipped host also contains the journal/SQLite, capability-flow, luminosity,
DeltaPU, Prime Git and lifecycle surfaces compiled by the production target.

The first-party application is governed by `LICENSE` under
`LicenseRef-Ergentics-Proprietary`. `ERGENTICS.spdx.json` is the SPDX 2.3
source-package record shipped beside that license, and
`THIRD_PARTY_NOTICES.md` records the current system-library boundary.

## Historical platform baseline — August 31, 2026

This section retains the earlier configuration and external-tool policy record. The current Build 23 build instructions are above.

The current project now targets **macOS 26.0 or later, arm64**, in both Debug
and Release. The application and hostless test targets inherit that minimum;
`Info.plist` derives `LSMinimumSystemVersion` from it. This drops macOS 14/15
support for new builds. It does not change the OS or rewrite earlier binaries,
source archives or test receipts. Xcode 26.6 is the currently selected toolchain.

Apple's [Foundation Models](https://developer.apple.com/documentation/foundationmodels)
framework starts at macOS 26.0. The newer
[Core AI](https://developer.apple.com/documentation/coreai) framework starts at
macOS 27.0 and is beta as of this 2026-08-31 check; it is not in the installed
26.6 SDK. Keep the 26 baseline: a future Core AI backend needs a supporting SDK
and an explicit runtime-availability boundary. Foundation Models availability
must also be checked at runtime; an OS version alone does not prove that its
on-device model is ready. That configuration-only checkpoint added no AI backend,
model download or network capability.

Python is **external tooling only**, not an application component, installed
dependency, bundled runtime or part of the authoritative path. Any Python/C shim
must remain on that external-tool side. Each use requires a fresh explicit
approval request naming the exact tool/source, inputs, isolated work directory,
permitted effects, monitoring coverage, finite limits and cancellation/disposal
plan. General development approval does not authorize Python execution.

No Python use is needed now. Its possible purpose is deferred to future
Core AI/macOS 27 model preparation, not the current macOS 26 build/test work.
The actual host and toolchain must be specified in that future request; no
OS upgrade or automatic launch is implied. A disposable tool environment must
not become an app dependency. Retain approved inputs, raw results and side-effect
observations before any separately approved disposal.

The stable interface is bounded, versioned artifact data, not Python execution
inside the app: native code independently validates any proposed artifact
before admission. Python cannot issue authority, close gates or control the VM.
Before approval, enumerate filesystem, process, network, environment/import and
resource effects; distinguish enforced restrictions from observations. If
relevant effects cannot be bounded and monitored, do not launch. Before/after
hashes alone do not prove the absence of transient writes. This is a required
future boundary, not an implemented monitor or a claim of complete visibility.
See `Control/python-external-tool-boundary-2026-08-31.json`, which supersedes
only the broader Python wording in the previous baseline record.

The baseline record was configuration-only. The subsequent ΔPU slice built
unsigned Debug and Release macOS 26-minimum apps and passed hostless tests;
it did not launch either app. The preceding signed no-guest acceptance remains in
`Control/functional-readiness-live-2026-08-31.ED79CA`; its tested image retains
its original macOS 14.0 minimum and its actual macOS 26.5.2 run.

## ΔPU v1: change-processing CPU reference

The first executable ΔPU computation model is now included in the application
target: `Sources/DeltaPUEngine.swift` and `Sources/DeltaPUTypes.swift`.
ΔPU means the proposed dynamic/change-processing unit, not a networking
data-processing unit. This is a pure Swift CPU reference, not accelerator
hardware, a GPU backend or a guest runtime.

One actor owns an acyclic integer graph and its cached values. Typed
insert/replace/remove batches bind to the current state ID, invalidate the
old/new dependency closure, recompute affected nodes and atomically publish
the exact output delta. Checked addition, literals and conservative select
are supported, up to 128 nodes/edits. Invalid graphs, stale bases, overflow
and observed cancellation reject without changing state. No caller restores
an arbitrary snapshot or supplies executable code.

Deterministic CBOR commits graph definitions and values through the existing
Merkle algorithm. Separate state IDs commit parent state, revision and applied
delta; returning to old content does not restore an old state ID. These are
in-memory artifacts, not a persistent ΔPU journal or a new execution authority.
That first slice added no UI action, automatic launch, process, Python or guest
path. The demonstration successor below adds an explicit UI action only.

The independent test-only full evaluator and reconstruction checks passed
alongside the existing suite: **277 Debug, 255 Release, and 277 Debug with an
empty replacement environment**, all zero failures. Both unsigned app builds
succeeded on macOS 26.5.2 / Xcode 26.6. The 26 new ΔPU tests include 160
deterministic mixed transitions, rollback, stale/concurrent one-winner,
canonical delta, minimal output and tampered/rehashed state checks.

In the sparse 64-node fixture, the engine evaluated **3 nodes** and reused 61;
the independent full evaluator evaluated 64. In the dense fixture both
evaluated 64. Values, CBOR identities and work observations matched across
all three test runs. Full-graph admission, output comparison and commitment
remain: these are reduced operation counts, not end-to-end speedup, measured
CPU cost or energy savings. Ergs are unmeasured. `invalidatedNodes` counts
surviving affected nodes, excluding removed seeds.

Raw logs, sources, products and the result are retained in
`Control/deltapu-reference-2026-08-31.w2FTKY`. No Stage 1–7 app acceptance or
Gate-E promotion follows. Guest/Rust/C ABI integration remains separate from
the application demonstration below.

## ΔPU application demonstration

At this historical checkpoint, the sidebar added **ΔPU** and Prime Git was the default page. The current app starts on Workspace. Choose
Sparse change or Dense change, then **Run selected demo**. Opening the page
does not compute. Each click constructs one fixed 64-node graph and applies
one frozen edit; no graph loader, prompt, process or guest command is exposed.

The view shows independently checked before/after values, changed definitions,
affected/cached membership, exact output edits, work counters, state ancestry
and CBOR bytes. Each immutable result keeps its own scenario label even if the
picker changes afterward. Counts appear only from a completed verified result.
The sparse result changes nodes 1, 3 and 4 and reuses 61 values; the dense
result changes all 64. Membership is dependency-derived, not a CPU trace.

A separate native verifier reconstructs both graphs with full DFS, joins the
exact fixture/edit, canonical CBOR/Merkle state, parent/revision, minimal output
and all 11 work fields. The original engine and test-only full reference remain
unchanged. Independent checking adds its own whole-graph work; this is not a
speed or energy benchmark.

Run admits one Swift worker synchronously. Repeated clicks while busy do not
queue work. Cancel and navigation away request cooperative cancellation and
suppress late publication; admission stays closed until the bounded task
returns. App Quit does not await this task. Clear removes only an idle,
in-memory result. There is no persistence, polling, watchdog or new shutdown
condition in this demonstration.

These synthetic fixtures neither require nor grant execution authority.
Existing signing/admission checks on guest and file-import paths are unchanged.
The new page is available in both Debug and Release targets, with a macOS 26.0
minimum. It has been compiled, not launched or accepted through a rendered-GUI
test in this slice.

Verification: **311 Debug, 289 Release, and 311 empty-environment Debug tests**,
all zero failures, including 34 new runner/verifier/model tests. Both unsigned
app builds succeeded. Sparse/dense state identities match the preceding ΔPU
record exactly. Sources, products, raw logs, reviews and byte checks are retained
in Control/deltapu-demonstration-2026-08-31.7uWX7J.

Energy remains unmeasured in ergs. No VM/GPU acceleration, Stage 1–7 app
acceptance, Gate-E closure or TestFlight acceptance is implied.

## Signed ΔPU readiness (development)

The separately scoped ΔPU mounted-GUI check is tracked in
`Control/deltapu-gui-readiness-2026-08-31.S6BVRj`. Its exact Debug-only
`--deltapu-readiness` entry selects ΔPU, skips guest/history/capability startup,
and programmatically runs one sparse fixture. It joins actual page, result
header and table views to the same visible window and immutable state/rows.
This is not physical mouse delivery or per-cell pixel verification. The new
probe uses the existing ten-second work/fifteen-second app-only exit policy;
normal application launches do not enable it. Its prepared FD1 frame needs
separate exact-child exit observation before acceptance. No new app journal,
authority, guest operation or energy measurement is introduced.

Observed result: builds and hostless tests passed (322 Debug, 291 Release,
322 empty-environment Debug; zero failures), but the first signed GUI check
exited 70 with only the generic INCOMPLETE diagnostic. Its exact child was
reaped after 1,641,253,000/3 nanoseconds from spawn entry; the second,
empty-environment GUI launch was skipped. No process from that invocation
remains running and no signal was sent. Image/source pins and the signed
archive still match. This is **not GUI acceptance**. The failing app predicate
is unobserved; the next change should retain bounded typed failure-stage and
predicate inputs, without guessing or relaxing a gate. No rerun is implied.

## Application-owned VM lifecycle

The VM interface is typed Swift/C code with fixed guest images, memory layouts
and mailbox operations. It is not a prompt interpreter: prose, chat approval,
environment variables and imported documents are not runtime commands. The
ordinary app owns Run, Stop, Quit, persistence and result inspection. There is
no new external guardian, generic command API or guest operating system.

The standalone lifecycle correction latches cancellation before journal
preparation and joins it to the reserved run. Stop/Quit starts one five-second
grace interval; repeats cannot extend it. Quit Now exits only this application
without waiting for a proof, journal writer or native mutex. A normal-termination
request does not remove a pending Quit fallback. Forced exit can lose volatile
memory or uncommitted writes; it is not native conservation or a successful
receipt. The policy is not a hard kernel scheduling guarantee.

See `Control/standalone-lifecycle-2026-08-31-r1` for the implemented, non-VM
verification record. Its unsigned builds and fabricated tests are not current
signed-GUI, real cancellation, timer/exit or guest-execution proof. Historical
no-abort launch envelopes remain retained but are not usable under the revised
requirement; the user does not consent to indefinite waiting.

## H3 native cursor/resume: live v2

The 2026-09-05 functional repair passed actual fixed-guest runs in signed Debug
and Release apps. Select **Hypervisor lab**, then **Run H3 cursor resume**.
The guest checkpoints 42, resumes in a fresh VM/vCPU, reaches 43, and conserves
both intervals. No guest OS, disk, network, or journal is involved. This is real
Hypervisor.framework execution, separate from the fabricated hostless tests.

H3 now explicitly initializes SCTLR to `0x30d00980`; the earlier live failure
was the `0x180` difference from the requested `0x30d00800`. Exact comparisons
remain enforced. The H3 cursor and checkpoint/terminal schemas are version 2;
H2/Rust retain their historical initialization. Old failures and frozen
qualification source pins are not rewritten or promoted by this change.

**Inspect verified H3 receipt · in memory** exposes the verified canonical
state/graph JSON and deterministic CBOR, with their Merkle identities. These
copied bytes carry no live capability. They are local product observations,
not independent OS attestation or the separate qualification-run envelope.
The H3 view is the original, pre-save observation. Its bytes remain volatile
unless the separate H4 Save action below completes; Quit discards the in-memory
view, not an already published H4 file.

H2 is the separate private-journal path; its missing retention grant does not
block H3. Choosing H3 excludes H2/Create/Open for that launch, and choosing
storage excludes H3. Relaunch to select another mode. Read-only history never
restores execution authority. The UI now labels these paths separately.

H3-only verification (preceding the H4 connection): 100 focused tests in each configuration; **895 Debug and
848 Release full-suite tests**, zero failures. Both signed builds retain the
same sandbox, user-selected-read-only, and hypervisor entitlements. Live native
intervals were approximately 6.946 ms (final Debug) and 5.640 ms (Release),
single observations rather than CPU/energy measurements or benchmarks.
Apps, raw logs, final xcresults, source copies and live observations are retained
locally outside Git in
`/Users/ergentics/Documents/Codex/2026-09-02/resume-the-existing-uncommitted-h4-d3/h3-functional-2026-09-05.LPPSFB`.

## H4 live save: functional and read-back verified

The live H3→H4 connection now works in signed Debug and Release apps. After
**Run H3 cursor resume** returns PASS, choose **Save H3 receipt to private
SQLite**. The H4 card displays **SAVED · VERIFIED READ-BACK**, the file path,
H4/source-H3 roots, and expandable exact JSON/CBOR. Saving does not run another
guest. H2/Create/Open remain excluded for that launch.

Only the successful native H3 owner can issue the one-use, in-memory save
handoff. Copied receipts, imported bytes and historical fixture capabilities
cannot issue it. Save uses the existing bounded D3 whole-image publisher with
a separate live schema and fixed `H4LiveReceipts-v1/<fresh UUID>` namespace in
the app's sandbox Application Support directory. Each stream is at most
32,768 bytes; the SQLite image is at most 64 × 4,096 bytes. Actual Debug and
Release files were each 24,576 bytes, private mode 0400, with 7,133 JSON bytes
and 6,251 CBOR bytes.

Publication checks the bounded SQLite header/allocation, holds and rejoins
directory/file identities, syncs the image and directory, reopens read-only,
and checks exact streams and indexed values against the same owner. The save
claim has a ten-second work budget, followed by the existing five-second
app-only Stop fallback if work stalls. These are application policies, not a
hard kernel latency guarantee. No automatic rerun, overwrite, recovery, cleanup
or permanent worker is added; incomplete state is retained on failure.

Final verification: **139 focused tests in each configuration, 904 full Debug
and 857 full Release tests**, zero failures. Hostless tests use fabricated
inputs and temporary private SQLite roots. Separately, actual native guest
runs and explicit saves passed in both signed apps. Independent read-only
SQLite checks returned `integrity_check = ok`; an independent calculation from
the stored streams reproduced both displayed H4 roots. Debug was also checked
after normal app Quit. The Debug file stayed unchanged through the later
Release save. Strict signature verification passed; the existing sandbox,
user-selected-read-only and `com.apple.security.hypervisor` entitlements remain.

Signed apps, both receipt copies, source snapshots, logs, xcresults and live
observations are retained outside Git in
`/Users/ergentics/Documents/Codex/2026-09-02/resume-the-existing-uncommitted-h4-d3/h4-live-2026-09-05.xclA0y`.
This is same-Mac evidence retention, not off-device backup. The completed
Release H4 result was left visible at the end of that check. The successor
below adds selected-file H4 reopening; historical/H2 readers remain separate.

The live receipt records `OBSERVED_NATIVE_PASS`; predicate count 9 identifies
the H3 source checkpoint mask `0x1ff`, not every H3 verifier check. Gate E
remains ABSTAIN and authority `00000000`. These canonical bytes are local
product observations, not independent OS attestation or promotion of the
frozen qualification campaign. Neither is required to use this functional
path. Prime Git/guest-OS storage remains a separate roadmap item.

## H4 selected-file reopen

**Hypervisor lab → Open saved H4 receipt…** now selects one existing SQLite
file read-only, including after relaunch. The view shows **REOPENED · SAVED
DATA VERIFIED**, the H4/source-H3 roots, exact JSON/CBOR, recorded timing,
SQLite file hash, and expandable H3 state/graph. H3's pre-save observation no
longer displays a contradictory current "H4 entered no" status: execution,
publication and later reopening are labeled separately.

The reader captures a self-owned mode-0400, single-link regular file through
a read-only/no-follow descriptor. It bounds the header, allocation and image
before reading, checks named/held file identity and metadata, then gives only
the captured memory image to hardened read-only SQLite. It checks exact schema,
indexes, canonical peers, recorded H3 PASS structure/timing, graph relationships
and H3/H4 Merkle commitments. It never opens SQLite against the selected path,
creates sidecars, scans directories, changes files, repairs, or retries itself.

Each read has a ten-second work budget, bounded read attempts and a SQLite
instruction budget. Its independent background deadline requests the existing
five-second app-only Stop fallback; stale callbacks cannot cancel a later
inspection. Canceling the file chooser leaves the mode unchanged. Selecting a
file enters history mode, excluding guest/create/save actions for that launch;
another explicit file selection is allowed after the reader returns. Relaunch
to choose execution again. No bookmark or selection is persisted.

Reopening verifies saved data, not a new native run or independent origin. It
does not recreate the original raw cursor/diagnostic evidence, live handoff,
execution authority, anti-rollback witness or OS attestation. A wholly replaced
internally valid receipt requires an external expected root to distinguish it.
The file identity checks are bounded observations, not a continuous ancestor
lease. Gate E remains ABSTAIN; authority `00000000`.

Signed builds and focused tests passed in Debug and Release (151 tests each).
Full suites passed **916 Debug and 869 Release tests**, zero failures. After
normal Quit of the earlier app, the new signed Debug app reopened both original
live receipts through the file chooser and displayed their exact previously
recorded H3/H4 roots, file hashes and timing. Both original files remained
byte-identical, mode 0400, with the same inode and size. This is actual Debug
GUI acceptance; Release has build/signature and automated-test verification,
not a separate GUI claim. The reopened Release-origin receipt and its H3
state/graph inspector are left visible in the Debug app. Records are retained in
`/Users/ergentics/Documents/Codex/2026-09-02/resume-the-existing-uncommitted-h4-d3/h4-reopen-2026-09-05.A83qgZ/README.md`.
The two earlier live receipts are the acceptance inputs; no new guest run is
needed for this viewer slice.

## Build 11 local archive

The working H3/H4 implementation is now packaged as a development-signed
**1.0 (11) Release archive**, with matching symbols, refreshed SPDX source
inventory and independent archive review. The packaging-only successor passed
869 Release tests with zero failures; app source and entitlements are unchanged.
This exact archive was not launched or uploaded. Compiler warnings are retained.

`Distribution/LocalArchive-1.0.11-receipt.json` joins the archive to source commit
`b200f066ba176ed4614ce1621123852b81e53298`, executable/dSYM hashes and retained
logs/results. `Distribution/README.md` identifies the current local checkpoint
while preserving earlier distribution records. TestFlight signing compatibility
and independent OS attestation remain separate unfinished work; neither prevents
this local archive from being retained and inspected.

## H5 repeated resume comparison — Build 12 development candidate

**Hypervisor lab → Run H5 · 3 resume pairs** selects one bounded batch for
the application launch. Each of three sequential attempts reserves a fresh
native lifetime, runs the unchanged H3 v2 checkpoint/resume guest, and checks
reservation release before another attempt can begin. One application lifecycle
owns the whole batch. H2, single-run H3, H4 Save and history remain excluded for
that launch; relaunch to select another mode.

Each native result passes the existing independent H3 cursor/page/register/
reply/Merkle reconstruction before H5 accepts it. H5 compares the exact verified
guest-state evidence and phase results. The two generation words and their
dependent commitments, monotonic timing and allowed watchdog-wait variation
are explicitly outside equality. Original 680-byte evidence and H3 state/graph
receipts remain intact for inspection. Fresh generations must follow the prior
pair; run intervals must not overlap or regress, and the timebase must match.
An individually valid but different trap syndrome fails the comparison.

The batch is consumed once and stops on the first failure, canceled return,
failed reservation release, stale observation, clock change or mismatch. It has
a 15-second work budget with an independent background deadline requesting the
existing five-second app-only Stop fallback. Stop/Quit remains sticky between
attempts; late callbacks cannot stop a different lifecycle operation. Native
watchdogs are unchanged. These are application policies, not hard kernel
scheduling guarantees. Failed release is quarantined without retry or cleanup.

Successful JSON/CBOR projections commit the three original H3 roots, exact
comparison root, run chronology and cumulative exposure. One random batch UUID
scopes the observations; no persistent host identifier is collected. Three
successful runs expose six native intervals and 2,040 original cursor-evidence
bytes, plus H3 receipts, to application memory and explicit GUI/Accessibility
inspection. Failed batches retain their accepted prefix and attempted count,
without claiming that every attempt entered a VM. All H5 data is volatile until
Quit. There is no H5 save, export or history-to-execution path.

This is a local product comparison in one app process, not independent same-host
attestation, an anti-rollback witness, CPU/energy measurement, or closure of the
separate H4 physical-I/O/power-loss qualification obligations. Gate E remains
ABSTAIN, authority `00000000`, and no later stage is authorized by the receipt.
Build 11's archive and historical evidence remain unchanged.

Verification: **76 focused tests per configuration, 932 full Debug and 885 full Release tests**, all with zero failures. Signed Debug and Release builds passed; all 93 SPDX files and 186 checksums were independently verified. Verification is recorded in
`Control/hypervisor-local-v1/h5-repeat-development-checkpoint-2026-09-05.v1.json`.
The initial native GUI check was blocked by the computer-control connection.
A subsequent user-requested retry succeeded in the exact signed Debug Build 12
app: **H5 PASS · THREE LOCAL RESUME RUNS MATCH**, three accepted native runs,
six VM intervals and generation pairs 1→2, 3→4, 5→6. Their original H3 roots
are distinct; all share comparison root
`834e600b023a9131394810e071aa6af703bf64c9cdda0c0364204cab514107ea`.
An independent Ruby reconstruction from the visible 2,733-byte JSON and
deterministic 2,489-byte CBOR reproduced displayed H5 root
`eca3cac85fcb9341eb146378c693291e6d1a985e59c5f9254fb8d953bbb544f2`.
That signed Debug PASS is retained as its original observation. A subsequent
live retry passed H5 in signed Release Build 12 and the exact Build 13 archive;
both receipt roots were independently reconstructed. Build 13 also passed a
live H3 run and inspection of its expanded receipt Accessibility surface,
with the removed raw native diagnostic absent. See `ROADMAP.md` and the
Build 13 live-check note for the current status.
The successor record is
`Control/hypervisor-local-v1/h5-repeat-live-debug-checkpoint-2026-09-05.v1.json`.
Independent OS attestation remains deferred.

## Historical Prime Git view (now Prime Git evidence)

This view was the initial screen at that checkpoint. The current app starts on Workspace and has a separate functional Git workspace. The retained evidence view's action buttons are intentionally inert:
there is no fetch, pull, push, stage, commit, checkout, reset or merge path.
Selecting a local checkout records a path label only. Import a local JSON
snapshot to inspect reported branch/HEAD, changes, sanitized remote information
and ahead/behind counts against **locally cached** tracking refs. This evidence view does
not execute Git or claim that an imported observation is current GitHub state.
Missing values remain unknown. A changed or unchecked observation is labeled;
schema acceptance is not a new execution receipt, source admission or independent
Git-graph verification.

Imports are bounded read-only file captures and remain in memory. The view has
no polling service, network client, persistent bookmark or background Git owner.
See `Control/prime-git-read-only-design.v1.json` for the future adapter boundary.
`env -i` testing is kept separate from the app's sandbox and network policy:
an empty environment alone establishes neither isolation nor private cloud.

`Examples/prime-git-synthetic-example.json` is an optional, clearly synthetic
import fixture, not current repository data. Nothing imports it automatically.
Snapshot JSON uses the field names in `Sources/PrimeGitSnapshot.swift`; unknown
counts are omitted or null. A reported upstream comparison must include both
HEAD and cached upstream object IDs and a pair of ahead/behind counts. Equal
object IDs require zero/zero; this necessary check does not recompute ancestry.

## Development-only GUI startup check

Debug builds accept exactly `--prime-git-readiness`. This opens the actual
Prime Git window with all controls disabled, admits the app's signing identity,
and reports visible window dimensions and idle model state before requesting
normal termination. It returns before the normal lab startup path: no capability
query, lab journal open, guest, Git operation or import is requested. Release
builds omit the observer and do not recognize this flag. Normal interactive
launches do not enter this probe.

For the development comparison, launch the same signed executable directly,
once with the normal environment and once through `/usr/bin/env -i`; do not use
LaunchServices, which may reuse another app instance. Redirect stdout and stderr
to separate retained regular files. Require exactly one readiness report joined
to the launched PID, followed by observed normal process exit. Exit zero alone
is not readiness proof. `normalQuitPlanned` is not a completed-quit observation.

The observer preserves raw hardware ticks and the exact rational timebase.
Its interval ends before report output and termination and starts after framework
startup. Environment counts are observed after framework startup, not an
independent exec-time environment measurement. Visible window state is not a
pixel-rendering test. The approximately three-second window poll is cooperative,
not a hard timeout on Security, AppKit, output or shutdown. No outer signal or
timeout is part of this check. macOS may write ordinary container/window metadata;
the check does not claim a write-free operating system or a scientific authority.

### Functional-readiness successor — implemented, hostless verified

`Control/functional-readiness-2026-08-31-r1` freezes an additive, zero-input
functional self-test using existing mailbox, canonical CBOR, Merkle and pure
receipt-verification code. Known-answer and rejection cases remain synthetic;
the self-test opens no file or SQLite connection, creates no VM, and performs
no signing, process or network operation. Its pure code can be tested in Debug
and Release, but the live probe selector remains Debug-only.

The successor emits one bounded `ERGENTICS_FUNCTIONAL_READINESS_V1 ` JSON frame
with a trailing line feed and a 65,536-byte total cap. The unchanged v2 startup
report is nested alongside separately named functionality and lifecycle
observations; a legacy `ERGENTICS_GUI_READINESS` parser must not silently accept
this different envelope. `preparedChecksPassed` describes checks observed before
output. The frame explicitly leaves guest execution, journal persistence,
output retention, process exit and host integrity unproved. Later capture and
actual exit observations must be joined separately.

The frozen readiness policy is ten seconds of work followed by at most five
seconds of cancellation/quit grace, anchored to the original readiness start.
A delayed callback cannot extend that fifteen-second policy horizon; user
Stop/Quit may shorten it. Admission precedes signing, functional work, window
polling and output preparation. Enforcement must remain independent of the UI
actor and output writer, and preparing a report must not disarm the exit
fallback. This starts inside the coordinator, not before framework initialization,
and does not promise a hard operating-system or kernel latency bound.
Lifecycle intervals use `mach_continuous_time`; the preserved startup report
uses `mach_absolute_time`. Their tick values are not interchangeable clocks.

Readiness results remain separate:

| Result | Required evidence; not an implication from another result |
| --- | --- |
| GUI startup | Current image admission, actual visible content window and idle models; process exit observed separately |
| Pure functionality | Fixed known answers and malformed-input rejection; no guest execution |
| Stop/Quit lifecycle | Actual controls, cancellation and deadline/exit behavior; fabricated tests alone are insufficient |
| Live guest | Exact selected image/profile, entry, request/reply, snapshot and teardown observations |
| Persistence/reopen | Exact committed run reconstructed after its writer closes; interrupted prefixes stay incomplete |
| Distribution | Delivered signing, Release/Finder behavior, privacy, OS coverage and TestFlight validation |

This successor is an implementation/hostless-verification slice, not a live
readiness result. Signed no-guest acceptance precedes a separate actual guest
interval and persistence/reopen checks. None of these local results closes Gate E.

Unsigned Debug and Release builds passed. Hostless tests passed 251/251 in
Debug, 251/251 with the same Debug bundle through `env -i`, and 229/229 in
Release on macOS 26.5.2. Two automatic-timer tests use a fabricated clock and
inert exit hooks, not an actual app exit. The self-test has 17 fixed cases and
explicitly labels its 92-byte assembly fixture; it does not boot the Rust guest.
See `Control/functional-readiness-2026-08-31-r1` for retained source and results.

The August 30 comparison passed on the same signed Debug image, normally and
through `env -i`, with a visible 1120 × 780 content window and normal exit in both
cases. The latter observed five environment variables after framework startup;
their origin was not measured. Debug tests passed 109/109 in both environments;
Release passed 102/102 with the probe excluded. The initial window-list probe
failure is retained separately. See `Control/gui-readiness-2026-08-30/README.md`
for raw reports, exact image UUID/SHA-256 and source/binary archives outside the
build cache. This is GUI readiness, not a guest or Gate E result.

The follow-up names-only v2 probe identifies the five post-framework keys:
`APP_SANDBOX_CONTAINER_ID`, `CFFIXED_USER_HOME`, `HOME`, `TMPDIR`, and
`__CF_USER_TEXT_ENCODING`. It retains no values or value hashes. The same signed
Debug image passed normal/empty-environment GUI checks and 112/112 tests in both
environments. See `Control/gui-environment-names-2026-08-30.t2kgKx/README.md`.
The earlier host-side Rust validator recommendation remains in
`Control/rust-security-primitives-review.v1.md`. The selected next direction is
instead a freestanding Rust execution kernel inside the Hypervisor domain, with
an explicitly separate stack and a build/inspection step before any new boot.
The build-only bootstrap is now retained in
`Control/rust-guest-bootstrap-2026-08-30.YtXTfY/README.md`: two matching 164-byte
images, independent extraction, and completed static review. Rust 1.98.0 is
installed only in a separate development-toolchain folder; no Rust host runtime
is linked into the app. Source is in `Guest/RustBootstrap`; the original
92-byte guest remains embedded.

## Rust bootstrap host integration — not yet booted

The app now also embeds the independently matched 164-byte Rust image. Its fixed
native entry uses the same owner, cancellation and quarantine as the assembly
baseline, with a separate 16-KiB RW/non-executable stack at `0x10010000`, restored
SP `0x10014000`, and doorbell instruction at `0x10000060`. The integration slice
did not activate this successor. The later controlled Debug entry can select it;
there is still no new button, path loader or caller-selected guest parameter.

Rust receipts use `rust-bootstrap.v1`; all three events must join the same
128-byte memory contract. The six-leaf snapshot commits image, memory layout,
request, reply, schema and the actual copied 16-byte stack frame. The remaining
stack prefix is checked for zero bytes by a separate native predicate, not
claimed as retained snapshot bytes. Native C and independent Swift reconstruction
must agree, including the odd-node Merkle step. Historical assembly receipts
keep their absent-profile representation and original four-leaf contract.

See `Control/rust-guest-integration-2026-08-30.fQdE42` for source/build/test records.
This slice builds the signed host and tests fabricated host-side data only. It
does not prove a Rust VM entry, live stack behavior, cancellation or teardown.
A later explicit synthetic boot must supply those observations before the new
path is presented as working live. High-value ingress/egress remains absent;
these local receipts are not independent host or VM attestation.

### Controlled first-Rust-boot entry — implemented, not launched

Debug builds now recognize exactly `--run-rust-bootstrap-once`. This is a
separately frozen synthetic boot mode, not the ordinary startup path. It requires
the actual guarded app window, existing signing admission, idle Prime Git, and
an inherited empty, self-owned mode-0600, single-link, read/write regular FD 1.
The app accepts no output path. Both manual guest entries and history refresh
stay disabled after the single attempt is latched. Release omits this entry.

Native disposition and evidence retention are separate. The same journal owner
returns the exact current-run canonical CBOR events and an explicit raw native
field snapshot; a storage or reconstruction error does not discard that return.
The bounded, canonical `ERGENTICS_RUST_BOOT_V1` report carries those original
bytes. Its prepared contents cannot prove a later write, sync or process exit.
The one-attempt FD exporter synchronizes and reads back the same descriptor;
partial or failed exports are not replaced. Typed export results/failures stay
in memory, and the later outer observer must supply its own post-exit evidence.

The historical implementation required native safety plus retained recovery
before normal quit and could defer Quit during preparation. That lifecycle is
source-superseded by the standalone correction above. Historical source,
artifacts and control records are unchanged, but their no-abort launch envelope
must not be used for the current app. Current user Stop/Quit is independent of
automatic-success/export predicates, including during preparation or incomplete
recovery. The two-second native watchdog remains distinct from the app's
five-second user-requested grace policy; neither is a hard kernel latency bound.

See `Control/rust-first-boot-controls-2026-08-30.BOCnEm` for implementation and
verification records. Hostless Debug tests passed 167/167 and Release 157/157
on macOS 26.5.2. The initial exporter failures are retained: the correction
admits Darwin's exact observed `FWASWRITTEN` flag transition after a write,
without ignoring other flag changes. This work launches hostless tests only,
not the app or VM; it does not test AppKit window closure or actual VM lifetime.
The exact one-child outer transport, signed-image readiness and first live boot
remain separate. No high-value state, network entitlement, Prime scientific
authority or Gate E promotion is enabled.

## Host integrity and high-value state

`Control/host-integrity-trust-boundary.v1.json` records the design requirement:
ordinary app and synthetic guest development remain available; high-value
ingress and trusted egress require independent, operation-bound host evidence.
Unknown or unacceptable evidence denies those transfers, not the app's existence.
This is a design contract, not implemented attestation or runtime enforcement.

Current signing admission, local guest PASS, environment checks and Merkle
reconstruction do not prove whole-host integrity. The Mac controls this guest's
backing memory; Hypervisor is not confidentiality protection against that Mac.
A relying party outside the evaluated host's control must verify trust and
withhold high-value input/keys or trusted output acceptance. No new network
entitlements, virtual NIC, enrollment, host configuration or Gate E authority
are introduced by this record.

## Open and sign

Open `ErgenticsProvenance.xcodeproj`, select the `ErgenticsProvenance` target,
then inspect Signing & Capabilities. The project selects Ergentics, LLC,
Team `ZCQ435U8JP`, from the actual public Apple Development certificate visible
with host access. The restricted identity query returned zero; the host query
returned one valid identity. No private key was exported. Bundle registration
is not inferred from the certificate. The project requests Apple Development
signing and Hardened Runtime.

The app admits its exact bundle identifier, configured nonempty Team ID,
Apple-anchored signature, and effective entitlement allowlist before enabling
file selection. It has no ad-hoc fallback. The scheme runs without a debugger;
`get-task-allow` and Xcode base-entitlement injection are disabled. Release
distribution, Developer ID signing, notarization and archiving are separate
steps, not performed or claimed by this source slice.

App Sandbox, user-selected **read-only** file access, and Hypervisor capability
access are requested. There are no network, app-group, iCloud, broad-file-access,
Virtualization-framework or PCC entitlements. Signing does not substitute for backup or
scientific authority. No credentials belong in source or chat.

The app now has a native AppIcon, bundled required-reason privacy manifest and
an app-only Release archive path. See `Distribution/README.md` for TestFlight
preparation and the remaining distribution-signature/account checks. A local
development archive is not an uploaded or validated TestFlight build.

## Normal launch does not enter a guest

Startup inspects the viewer's own signing identity, native `kern.hv_support`,
and (only after exact effective-entitlement admission) the two Hypervisor
maximum-vCPU/maximum-IPA capability getters. It does not find, import, create or
recompute a historical run. The current lab does not discover or open a journal
at startup: Application Support lookup occurs only after explicit H2 Create,
H2 Open, or H4 Save. H3 runs in memory without a journal. macOS/SwiftUI can
create container and framework metadata; this is not a claim of literally zero
operating-system writes.

Use **Open retained receipts…** to explicitly select the existing directory:

`/Users/ergentics/Library/Containers/com.ergentics.PrivateCompute/Data/Library/Application Support/ErgenticsPrivateCompute/native-static-177403f-r1`

The path above is documentation, not a runtime fallback. The sandbox grant
comes from the user's selection. Nothing is copied, moved, rewritten,
chmodded, repaired or deleted. No bookmark or selection is persisted.

The native C reader holds the root and all twelve regular-file descriptors,
checks the exact inventory, caps each file at 64 KiB, requires self-owned
0700/0600 root/files and single-link files, rejects symlinks at the admitted
root/leaves, and joins device/inode/metadata/names before and after capture.
The Swift verifier binds terminal SHA-256
`1a4c92297c28f9e686bbe9930b54453d909a2102e3cde1d95dee9f1556e24568`,
then checks all eleven manifest entries, retained graph byte equality and
historical identity/timebase joins.

The result means **historical STATIC PASS / current receipt-byte integrity**.
It does not rerun JSON/CBOR projectors, reconstruct the Merkle tree, create a
new PASS receipt, or admit today's Prime source tree. No original compute or
receipt-writer code is linked. Gate E remains `ABSTAIN`; vector `00000000`.
Energy remains unmeasured in ergs; historical rational timing is not current
CPU time, energy or viewer duration.

Snapshot checks are observations, not a filesystem transaction or continuous
watch. Ancestors are not held; transient restoration between checks and later
changes are not excluded. Read-only reads can update filesystem access-time
bookkeeping. The screen displays the captured bytes, not a live-root lease.

## Run the fixed Hypervisor guest

At the user's direction, the app links **Hypervisor.framework**, not
Virtualization.framework. Its separate capability entry calls
`sysctlbyname("kern.hv_support", ..., NULL, 0)`,
`hv_vm_get_max_vcpu_count`, and `hv_vm_config_get_max_ipa_size`. The Hypervisor
entitlement is admitted before the latter two calls, even though they are
read-only getters. Raw return codes are retained in memory; output values are
shown only on success. IPA is address width, not RAM allocated or available;
the vCPU count is a supported limit, not created CPUs or a performance score.

For the separate H2 mode, select **Hypervisor lab → Create private journal**,
then **Run fixed guest** in a fresh signed-app launch. Existing or partial
journal state is not adopted or overwritten by Create. Run creates one
VM and one vCPU on a dedicated OS thread, enters once, and tears both down.
The bundled 92-byte AArch64 image is reviewed in `Guest/doorbell.S`; its exact
bytes are embedded in the signed host, not loaded from a pathname. It reads
`[sequence=1, ABI=1, 19, 23]` and publishes `[1, 1, 42, status=0]` into separate
32-byte mailboxes. Acquire/release sequences and a fixed MMIO store form the
boundary. There is no OS, IPSW, virtual disk, network device, host mount,
SwiftPM, shell, guest command parser or external dependency.

The native owner validates the exact trap, PC/IPA/registers and every byte of
three 16-KiB slots. It computes a domain-separated Merkle snapshot **before
teardown**. Swift independently reconstructs that root from the copied bytes
after native return. A private watchdog requests vCPU exit after two seconds;
kernel return latency is not finitely guaranteed. User cancellation uses the
same protected, at-most-once exit request. No process signal is used. Failed
resource conservation blocks another run in this app process and retains
mapped backing memory while the process remains alive. It does not veto user
Quit. Stop/Quit requests cancellation with the bounded grace policy above;
Quit Now exits the current process directly. Cancellation acceptance and forced
process exit are not successful teardown observations.

Normal repeated development runs receive fresh UUIDs and retain their results.
Debug builds also accept exactly `--run-fixed-guest-once` to invoke the same
operation once on launch; no additional arguments or input loader are admitted.
Release builds have no automatic-run flag. App Sandbox, this local virtual CPU,
and Apple's Private Cloud Compute service remain different boundaries.

## H2 durable host journal and independent reconstruction

Current H2 explicitly provisions the fixed sandbox Application Support root
`guest-journal-v1`, with `guest-events.sqlite3` inside. The older
`ErgenticsProvenance/HypervisorLab/guest-events.sqlite3` path is historical,
not a current automatic discovery or migration target. Neither path is H4's
`H4LiveReceipts-v1` namespace. These are not temporary directories, and this
slice does not alter the original app's evidence.
Each run has exactly `start → observation → terminal` events on success;
interrupted prefixes remain incomplete. The start is committed and read back
before guest entry. Raw Hypervisor return codes, entry counts, full mailboxes,
image bytes, rational hardware ticks and snapshot root are retained.

Every event's deterministic CBOR envelope contains its identity and preceding
event digest. Its own SHA-256 is stored outside the envelope. SQLite atomically
stores those bytes and their indexed projection using WAL, FULL synchronous,
fullfsync and bounded busy waits. Reopening verifies schema, canonical CBOR,
digest/ancestry and the execution predicates—not just a terminal's PASS text.
The native and Swift Merkle implementations are separate; SQLite and CBOR are
**not two independent execution witnesses**. A Merkle index/graph can later be
rebuilt from this journal without becoming another mutable source of truth.

The pre-teardown Merkle seal is initially volatile. Durability begins only at
the host journal transaction. Persistence failure does not reinterpret native
execution: a retained prefix stays incomplete, available recovery CBOR is shown
while the process remains alive, and further runs may be blocked for that
process. Recovery does not prevent Quit; a forced exit may lose that volatile
CBOR. The journal
holds and rejoins its parent/file descriptors, rejects symlinks, and checks
private modes; SQLite's VFS still opens named paths. Transient replacement,
same-user tampering, rollback of a whole valid journal and power-loss behavior
beyond the filesystem's sync contract are not excluded. Back up SQLite using
a consistent SQLite backup/checkpoint workflow, not a lone database-file copy
while a WAL is active. This is local durable storage, not off-device archival.

This first guest is the transport test environment for future **ΔPU / Delta
Processing Unit** work. Its arithmetic is not a speed benchmark, incremental
state engine, GPU replacement or scientific candidate-selection result.
Energy remains unmeasured in ergs. Gate E stays `ABSTAIN`, vector `00000000`.

Apple references:

- [Hypervisor framework](https://developer.apple.com/documentation/hypervisor)
- [Hypervisor entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.hypervisor)
- [Virtualization entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.virtualization)
- [macOS VM configuration](https://developer.apple.com/documentation/virtualization/running-macos-in-a-virtual-machine-on-apple-silicon)
- [Read-only directory shares](https://developer.apple.com/documentation/virtualization/vzshareddirectory)
- [Small Business / separately granted PCC access](https://developer.apple.com/app-store/small-business-program/)

The broader requested Merkle-root inception is specified separately in
`Control/hypervisor-genesis-design.v1.md`: typed/domain-separated commitments,
historical-parent references, explicit transition predicates and independent
round trips. The live assembly lab has a fixed four-leaf snapshot and three-event
host chain; the unbooted Rust successor adds the separately typed six-leaf
contract above. Neither closes the broader scientific design.

## Historical viewer-only repository reference

The **Select local checkout reference…** control retains only a path label in
memory. It does not enumerate or hash files, call Git, fetch/push, resolve
packages, admit a source identity or mount anything into a VM.

A local candidate was found read-only at:
`/Users/ergentics/Documents/Codex/2026-07-26/you-re-in-a-clean-recoverable/work/ergentics-prime`

It was not selected for you. Its observed HEAD was
`2e065cd1eeabdd09e1f20fe5627b2ee3591a5858`; that observation is not a fresh
tracked/untracked content admission. A future integration needs an explicit
snapshot/commit/tree/content join. Guest read-only sharing would prevent guest
writes, not host-side mutation.

## Historical viewer-only verification scope

At that earlier checkpoint, the native project had no external packages or build scripts. Its hostless
tests exercise the hash/manifest/clock, guest contract, Merkle and semantic
verifiers using synthetic inputs, plus the journal on private test directories.
They do not open the original receipt directory, start the
application or run a VM. In particular they are not a positive production
signature or full native descriptor-reader proof. Unsigned build-only
verification must be reported as unsigned, never as developer-signing PASS.

The working app at that checkpoint was `/Users/ergentics/Developer/ErgenticsProvenance`, outside Codex.
No Prime source identity reseal, production Driver V2 edit, old process
observation/actuation, or change to unrelated drafts is part of this slice.
