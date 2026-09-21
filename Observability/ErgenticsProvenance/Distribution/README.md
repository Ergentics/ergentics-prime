# Native app → TestFlight

This directory prepares the existing macOS application for a distribution
workflow. It is not an uploaded build, an App Store Connect app record, or a
claim that a developer-signed archive is TestFlight-ready.

The app starts in its operational Hypervisor lab. It remains arm64/macOS 14,
with no virtual NIC, network-client/server entitlement, idle watchdog or
automatic Release guest launch. Icons and the privacy manifest are bundled.
The existing shared scheme archives the actual application in Release, not
the hostless test target or a report package.

## Archive and export boundary

Use Xcode Product → Archive with the ErgenticsProvenance scheme. A local
development-signed archive is a packaging check only. No account registration,
profile update, cloud signing, export or upload is performed automatically.

`ExportOptions-TestFlight.plist` selects App Store Connect, local export,
manual signing and internal testing only. It deliberately has no invented
provisioning-profile UUID or distribution certificate. Supply the actual
matching assets after they are inspected. Do not change destination to upload
without explicitly choosing that action. Build numbers are explicit, not
automatically rewritten; advance CURRENT_PROJECT_VERSION before each upload.

## Remaining distribution gates

1. Obtain/inspect the exact App Store Connect record and registered
   `com.ergentics.provenance` App ID for team `ZCQ435U8JP`, and matching Mac
   distribution identity/profile. A local development identity is not proof
   these exist.
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
   retained-result reconstruction and teardown. macOS 14/15 runtime coverage
   still requires those actual OS versions; a deployment target is not a run.

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
