# Ergentics Private Compute

A native SwiftUI macOS application for the fixed, offline **static** JSON/CBOR verification and graph join. It runs on this Mac, not in remote cloud infrastructure or a virtual machine.

Open `ErgenticsPrivateCompute.xcodeproj`, select the `ErgenticsPrivateCompute` scheme and My Mac, then build. The project uses only native targets and installed Apple frameworks; it has no package downloads or build scripts. Three static library targets reference the existing, unchanged authority/reconstructor sources.

## Application boundary

- App Sandbox is enabled. No network, iCloud, app-group, broad-file-access or helper entitlements are requested. The application checks its signed sandbox/network entitlement values at entry.
- Two separately pinned bundled candidates are decoded and verified independently, reconstructed, and joined in process. Algorithmic independence is not process isolation.
- No command execution, child process, signal, process census, old launcher or live Gate E role is present.
- The normal GUI environment is allowed. Only its entry count and presence of the known CoreFoundation encoding key are recorded; no values are collected. This does not diagnose the earlier silent CLI failure.
- The UI distinguishes mathematical verification from successful receipt persistence. The displayed graph comes from the actual joined bytes.

## Retention and reopening

The app creates `ErgenticsPrivateCompute/native-static-177403f-r1` inside its sandbox's user Application Support directory. It uses exclusive native descriptor-rooted writes, exact leaf names, readback comparison and checked synchronization. Twelve raw input, output and journal leaves are retained. The terminal manifest hashes every earlier leaf, not itself.

There is no rerun button. An existing run directory prevents new computation or replacement. Reopening the app can validate and display retained bytes read-only. Incomplete or rejected state is preserved, never cleaned, chmodded, repaired or retried.

The interface shows the actual retention path and can reveal it in Finder. This is durable local retention, not a remote backup, encrypted vault or unconditional power-loss guarantee. Named-path observations are not continuous watchers or mapped-image admission. Filesystem I/O can block; there is no subprocess-containment loop. Closing the last app window exits the app.

## Meaning of a pass

`STATIC PASS` means the fixed candidate, independent reconstructions and graph join passed. Source subject is the pinned historical `04c5324` candidate—not a fresh admission of dirty/current Prime. Authority vector remains `00000000`; Gate E remains `ABSTAIN`. The consumed bootstrap result is unchanged.

Timing uses raw `mach_absolute_time` ticks and the exact integer timebase. It excludes system sleep and is not CPU time. Energy in ergs remains **not measured**.

The hostless `PrivateComputeCoreTests` target tests only the pure algorithms and timing arithmetic. It does not start the app or create application receipts.
