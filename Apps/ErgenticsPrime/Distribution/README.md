# Local app and distribution history

## Build 21 — integrated Ergentics Prime

Source `fbe358c` builds one app with Workspace, local Git, VM setup, Prime GPU runtime and retained evidence. It is installed at `/Applications/Ergentics Prime.app` and archived in Xcode as `Ergentics Prime 1.0 (21)`. Build 19 is retained as a byte-verified backup. The Release suite passed 989 tests with four fixture-dependent skips; all 12 focused process/model cases, 15 native lease cases and 15 independent packaging checks passed. Both archived and installed app GPU checks passed.

This is a local Apple Development build. Model checkpoint loading/generation, real-guest acceptance and external TestFlight remain pending. Visible content may be captured; Git previews are unredacted. The app does not claim end-to-end secret containment. See [the saved receipt](LocalArchive-1.0.21-receipt.json).

## Build 16 — bounded H8 retained provenance

The signed standalone app and matching archive are saved in the September 5 Build 11 continuation task’s `outputs/Build16` and `outputs/Ergentics Provenance 1.0 (16).xcarchive`. Portable app: `outputs/Ergentics-Provenance-1.0-16.zip`. Full suites passed: 927 Release and 974 Debug tests, zero failures; 22 new H8 cases cover retention, transitive lineage, malformed streams, replay, cancellation, publication faults, separate read destinations, expiry, revocation and the H7 → Save lifecycle.

The actual signed app passed H7 Run, H8 Save, selected-file reopen, revocation, normal Quit, restart/reopen and 60-second read expiry. Retained bytes stayed unchanged. An independent Ruby reconstruction on the same Mac reproduced canonical JSON/CBOR and all four displayed lineage roots. Executable SHA-256 `7bf7df72a997a531ddb21e6bf0b82749cce9e3311525ce835ee97ecc53f0f8bc`; app/dSYM UUID `45032EC4-25B3-3217-9201-21F6D0ACDAEA`. Strict signature, unchanged three entitlements, four resources and all 190 source checksums verified; the ZIP was unpacked and reverified. Detailed evidence: `outputs/Build16/Verification.json`.

Build 15 is preserved as a candidate that caught the H7 lifecycle marking a verified completion as recovery, which blocked H8 Save before file creation. Build 16 corrects that transition. Save creates a new private H8 file; reopen never restores a live execution capability. This is local fixed-function evidence, not independent OS attestation, physical erasure, general noninterference or trusted-egress admission.

The user stopped the App Store route. Nothing was installed, no macOS settings changed, and no new upload occurred. Existing TestFlight history below remains historical; updated delivery is deferred. Independent OS attestation remains parked separately. See `../ROADMAP.md`.

## Build 14 — bounded H7 execution

Signed Release archive: `outputs/Ergentics Provenance 1.0 (14).xcarchive` in the September 5 Build 11 continuation task. Executable SHA-256 `9ec89281870d6bc5b07c3e84d2db1fe2a1cb01c2f6353aac2d62120dc4dea54e`; app/dSYM UUID `5B148F36-31A4-3379-9C1E-5D00BF826BBF`. All 905 Release and 952 Debug tests passed (20 new H7 cases). Signature, the unchanged three entitlements, embedded resources and 188 source checksums verified. The actual archived H7 run passed 42→43 and teardown; its 6,216-character Accessibility tree exposed the bounded result/local epoch without native diagnostic or H3 receipt dumps. Live epoch `782c7b74-3732-4336-beb3-3544d1b8a717`. Verification is saved in that task's `outputs/Build14/Verification.json`. No upload or independent OS attestation occurred. Fixed-function execution only; no arbitrary program, shared-corpus retrieval, physical erasure or general timing-privacy claim.

## Prior local archive — Build 13

Build **1.0 (13)** contains H5 repeated resume comparison and removes the full
native diagnostic from the ordinary app/Accessibility view. Signed Release
archiving succeeded and a fresh full Release suite passed **885 tests, zero
failures**. Strict signature verification, the exact three entitlements,
app/dSYM UUID matching, four embedded source/license/privacy records and all
186 SPDX checksums passed inspection. Existing compiler warnings remain.

Archive: `/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Ergentics Provenance 1.0 (13).xcarchive`.
Executable SHA-256: `518d6fb4fc488621f13ae11491e0c5fc0ce45af689a74f426031e8726a9a7fb5`.
App/dSYM UUID: `E8BC1533-DDFF-3CEA-A031-2E1D302274AD`.

The exact archived app has now passed live H3 and H5 runs, and the successful
H3 Accessibility surface passed inspection with all receipt streams expanded.
The removed raw native diagnostic was absent. Both the preceding Release
Build 12 and archived Build 13 H5 receipt roots were independently reproduced.
The archive remains byte-identical and strictly signed after execution. It
has not been uploaded. See the live-check note under `Control/hypervisor-local-v1/`.
The
TestFlight app already exists as **Hyper-Visor**, ID **6807235450**, with the
prior build-2/build-3 uploads described below. Delivered-signature compatibility
remains unfinished; OS attestation is parked separately. See `../ROADMAP.md`.


## Current local checkpoint — September 5, 2026

**1.0 (11) is now locally archived**, development-signed, with matching dSYM
and independently reviewed packaging. It contains the working H3 v2 and H4
Save/reopen implementation at source commit
`b200f066ba176ed4614ce1621123852b81e53298`. Changes from the live-tested
predecessor are build numbering and a refreshed 92-file SPDX source package.
The full Release suite passed **869 tests, zero failures**.

See `LocalArchive-1.0.11-receipt.json` for exact hashes, source, reviews,
warnings and retained logs/results. This exact archive was not launched;
preceding live functional acceptance remains separate. It is not a warning-free
build. Existing archives, receipts and unrelated dirty files are preserved.
The historical sections below describe their original checkpoints, not the
latest build or current H3/H4 functional status.

The user selected local archiving for this step. No TestFlight installation,
export, App Store Connect validation/upload or signing-policy change occurred.
Independent OS attestation is deferred and is not an archive prerequisite.
Future TestFlight delivery has a separate compatibility task: inspect the
Apple-re-signed own-app signature/entitlements and add/test its narrow admission
branch without relaxing existing identity or capability checks. This is not
independent OS attestation. Existing internal TestFlight options are unchanged.

## Historical distribution setup and earlier checkpoints

This directory prepares the cumulative macOS Hypervisor application for a
distribution workflow. App Store Connect now contains `Hyper-Visor`, Apple app
ID `6807235450`, for bundle `com.ergentics.provenance`. No binary had been
uploaded when that record was created, and no TestFlight acceptance is implied.
The original 92-byte guest proof and Rust successor remain fixed historical
fixtures embedded in this one application; neither is a separate product.

The app starts in its thin Prime Git view; its Hypervisor lab is a separate
workspace. New builds target arm64 with a macOS 26.0 deployment minimum,
with no virtual NIC, network-client/server entitlement, idle watchdog or
automatic Release guest launch. Icons and the privacy manifest are bundled.
The existing shared scheme archives the actual application in Release, not
the hostless test target or a report package.

The macOS 26 baseline does not include Core AI, whose framework starts at
macOS 27.0. Foundation Models is available from 26.0, subject to runtime model
availability. No AI runtime is bundled. Python, including any Python/C shim,
is external approved tooling only: it is not an app component, installation
dependency, bundled runtime or authority. Each tool use requires explicit
approval and a bounded side-effect monitoring plan. No use is needed for the
current macOS 26 build; possible future use is deferred to Core AI/macOS 27
preparation. See `Control/python-external-tool-boundary-2026-08-31.json`.

The VM interface remains fixed, typed Swift/C code, not a prompt-driven runtime.
Current app-owned Stop/Quit does not require a successful evidence writer or
conservation verdict before exit. The prior signed image passed no-guest
normal/empty readiness, blocked-output fallback and ordinary Quit acceptance
in `Control/functional-readiness-live-2026-08-31.ED79CA`. Stop, Quit Now and
real guest teardown remain untested live. That record does not accept a new
macOS 26-minimum build. The historical no-abort launch envelope is not usable
for the revised lifecycle requirement.

The new macOS 26-minimum configuration now has successful unsigned Debug and
Release builds and hostless ΔPU/existing-suite tests in
`Control/deltapu-reference-2026-08-31.w2FTKY`. Neither app was launched, signed
or accepted for distribution in that slice. The successor in
Control/deltapu-demonstration-2026-08-31.7uWX7J adds an explicit bounded ΔPU
sidebar demonstration in Debug and Release. It passed 311 Debug / 289 Release /
311 empty-environment Debug hostless tests and both unsigned app builds.
That slice did not launch or accept the GUI live. ΔPU remains a synthetic
CPU reference without guest integration, new persistence or execution authority.
Prior
functional-readiness evidence includes hostless tests and signed no-guest
acceptance; its pure known-answer checks remain distinct from real guest work,
Stop, persistence/reopen and distribution results. Its frozen budget is
ten seconds of readiness work plus at most five seconds of grace anchored to
the original start, not a hard kernel deadline. Pure checks may compile in
Release; the closed readiness probe remains Debug-only. A Debug probe PASS
cannot establish that the delivered Release build runs that probe or passes
TestFlight validation.

## Archive and export boundary

The new ΔPU mounted-view readiness mode is Debug-only and tracked separately
in `Control/deltapu-gui-readiness-2026-08-31.S6BVRj`. It is a one-fixture
programmatic workflow with real view bindings, not physical interaction,
Release distribution acceptance or a guest test. Existing signing rules and
the three application entitlements are unchanged.

This successor passed builds and 322/291/322 hostless tests, but its first
signed GUI invocation exited 70 with an unidentified internal predicate
failure. Exact reap succeeded; the empty-environment case was not entered.
No signed GUI or distribution acceptance follows. Raw captures, signed image,
source and failure audit remain in that control folder. A typed failure
diagnostic is the recommended next step; no launch retry is implied.

Use Xcode Product → Archive with the ErgenticsProvenance scheme. A local
development-signed archive is a packaging check only. No account registration,
profile update, cloud signing, export or upload is performed automatically.

`ExportOptions-TestFlight.plist` selects App Store Connect, local export,
manual signing and internal testing only. It deliberately has no invented
provisioning-profile UUID or distribution certificate. Supply the actual
matching assets after they are inspected. Do not change destination to upload
without explicitly choosing that action. Build numbers are explicit, not
automatically rewritten; advance CURRENT_PROJECT_VERSION before each upload.

`ExportOptions-AppStoreConnectUpload.plist` is the separately explicit upload
path. It selects automatic App Store Connect signing, internal TestFlight only,
and does not request build-number management. Build `1.0 (2)` is the first
archive required to ship `LICENSE`, `ERGENTICS.spdx.json`, and
`THIRD_PARTY_NOTICES.md`; build `1` remains a local predecessor.

Build `1.0 (2)` was accepted by App Store Connect for upload at
2026-08-31 19:21:41 PDT and entered processing. The sanitized receipt is
`AppStoreConnect-1.0.2-upload-receipt.json`. Processing completion, TestFlight
availability, delivered-signature admission, beta review and App Review remain
separate facts; the credential-bearing Xcode distribution log is local-only.

Xcode Organizer subsequently observed build `1.0 (2)` as `VALID`,
`READY_FOR_BETA_TESTING`, `BETA_INTERNAL_TESTING`, and `INTERNAL_ONLY`, with
non-exempt encryption false. The same Organizer action then used Xcode-managed
version/build numbering and accepted a second internal-only upload from the
same build-2 archive as App Store Connect build `1.0 (3)` at
2026-08-31 19:26:56 PDT. Its sanitized receipt is
`AppStoreConnect-1.0.3-upload-receipt.json`. Build 3 processing and availability
are not yet proven. Do not upload again: select build 2 or 3 explicitly in App
Store Connect, and treat build 2 as the first known-ready delivered fixture.

The current local successor advances both source configurations directly to
`1.0 (4)`. Build 3 is already consumed by the accepted Organizer upload and is
not reusable. Build 4 adds explicit read-only reconstruction of the fixed
private journal. Its Release test action passed 399/399 and its local
development-signed archive passed the identity, dSYM, strict-signature,
entitlement, selected binary-linkage-surface and embedded-resource audit
recorded in `LocalArchive-1.0.4-receipt.json`. During this checkpoint the app
and VM were not launched, and the archive was not exported, validated with App
Store Connect or uploaded. Build 4 TestFlight availability was not checked. This
local packaging result does not close delivered-signature admission or Gate E.

SPDX regeneration is deterministic only when all six arguments are frozen.
Run `Tools/GenerateSPDX.swift` with the repository root, output path, marketing
version, build number, exact UTC creation time and a fresh lowercase UUID. Run
it a second time to a disjoint output with the same arguments and require exact
byte equality before replacing `ERGENTICS.spdx.json`. A new document must never
reuse an earlier SPDX namespace UUID.

## Remaining distribution gates

1. Join the existing App Store Connect record (`Hyper-Visor`, Apple ID
   `6807235450`) to the exact `com.ergentics.provenance` build and let Xcode's
   automatic distribution step create or select the matching Mac App Store
   identity/profile. Inspect the resulting archive/export identity; the local
   development signature alone is not that proof.
2. Add and test a narrowly scoped distribution-signature admission branch.
   The existing native rule requires the developer certificate's OU/Team.
   Apple re-signs distributed builds. Apple's documented Mac App Store leaf
   OID is `1.2.840.113635.100.6.1.9` under `anchor apple generic`; that does not
   by itself prove all delivered TestFlight identity fields. Inspect an actual
   distribution/delivered signature fixture before selecting the exact rule.
   Preserve exact bundle/Team/application identity and the zero-network
   capability policy. Do not weaken the development rule as a workaround.
3. Validate the archive with Xcode/App Store Connect, then authorize its
   upload, beta metadata, feedback contact and any compliance answers. No
   successful validation or TestFlight delivery is currently claimed.
4. On the installed TestFlight build, verify self-admission, explicit Run,
   Stop/Quit and current-process emergency exit, retained-result reconstruction
   after reopening, and teardown as separate observations. Keep synthetic
   functional checks distinct from a real guest interval. New builds no longer
   target macOS 14/15. Test the supported macOS 26 range explicitly; a deployment
   target is not a runtime test, and old receipts are not new-build acceptance.

## Privacy declaration

The app has no tracking domains or off-device data collection. File metadata
is used for its private journal (C617.1) and user-selected receipt folders
(3B52.1). The native clock measures in-app intervals and timers (35F9.1), not
fingerprinting, energy, or off-device boot-time analytics. These declarations
describe existing API use and confer no new permissions.

Primary references:

- [Apple signing requirements](https://developer.apple.com/documentation/technotes/tn3127-inside-code-signing-requirements)
- [Apple distribution re-signing](https://developer.apple.com/documentation/technotes/tn3161-inside-code-signing-certificates)
- [Required-reason APIs](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitypereasons)
- [Distribution workflow](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

Export option keys were checked against the installed Xcode's `xcodebuild -help`.
