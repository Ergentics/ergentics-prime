// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) @testable import PrimeCore
import PrimeValidationWorkflowContracts
import PrimeValidationWorkflowDriverCore
import PrimeValidationWorkflowDriverV2ShotGovernorCore
import XCTest

final class PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests:
    XCTestCase
{
    func testBuildAndInventoryOuterJournalsUseExplicitGateAndRetainExactLeaves() throws {
        guard #available(macOS 26.0, *) else { throw XCTSkip("native admission requires macOS 26") }
        for (gate, journalName) in [
            (PrimeValidationDriverV2TerminalGate.gateF, "gate-f-shot-governor-journal"),
            (.gateG, "gate-g-shot-governor-journal"),
        ] {
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            let guarded = try preparedGuard(for: fixture)
            let transfer = try roleTransferInputs(fixture: fixture, guarded: guarded)
            let working = try fixture.makeDirectory("outer-explicit-gate-working")
            let baseFD = Darwin.open(fixture.base.path,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC)
            guard baseFD >= 3 else { throw FixtureError.invalid("gate_journal_base_open") }
            defer { _ = Darwin.close(baseFD) }
            let workingFD = Darwin.open(working.path,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC)
            guard workingFD >= 3 else { throw FixtureError.invalid("gate_journal_working_open") }
            defer { _ = Darwin.close(workingFD) }
            let facade = try PrimeValidationDriverV2OuterJournalMechanicsFacade(
                heldBaseDirectoryDescriptor: baseFD,
                heldWorkingDirectoryDescriptor: workingFD,
                intent: transfer.intent,
                terminalGate: gate)
            let observed = try facade.consume()
            let journal = fixture.base.appendingPathComponent(journalName)
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: journal.path).sorted(),
                observed.orderedLeaves.map(\.leaf).sorted())
            let requestData = try Data(contentsOf: journal.appendingPathComponent("01-supervisor-request.json"))
            let request = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2SupervisorLaunchRequestV1.self,
                from: requestData, artifact: "explicit_gate_journal_test")
            XCTAssertEqual(request.terminalGate, gate)
            for leaf in observed.orderedLeaves {
                let path = journal.appendingPathComponent(leaf.leaf).path
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                var metadata = stat()
                XCTAssertEqual(lstat(path, &metadata), 0)
                XCTAssertEqual(UInt64(metadata.st_ino), leaf.inode)
                XCTAssertEqual(metadata.st_mode & 0o7777, 0o400)
                XCTAssertEqual(UInt64(data.count), leaf.byteCount)
                XCTAssertEqual(PrimeSHA256.hexDigest(of: data), leaf.sha256)
            }
            XCTAssertEqual(observed.spawnedProcessCount, 0)
            XCTAssertFalse(observed.productionStatusEligible)
            try facade.revalidateRetainedTerminal()
            XCTAssertThrowsError(try facade.consume())
            try facade.revalidateRetainedTerminal()
        }
    }

    func testPublicReleaseAdmissionUsesEmbeddedSourceAuthority()
        throws
    {
        #if DEBUG
            throw XCTSkip("public embedded-source admission is Release-only")
        #else
            let environment = ProcessInfo.processInfo.environment
            guard let primePath = environment[
                "PRIME_DRIVER_V2_GATE_E_PRIME_ROOT"
            ], primePath.hasPrefix("/") else {
                throw FixtureError.invalid(
                    "PRIME_DRIVER_V2_GATE_E_PRIME_ROOT"
                )
            }
            guard let companionPath = environment[
                "PRIME_PMHNP_COMPANION_ROOT"
            ], companionPath.hasPrefix("/") else {
                throw FixtureError.invalid(
                    "PRIME_PMHNP_COMPANION_ROOT"
                )
            }
            let primeRepository = URL(
                fileURLWithPath: primePath,
                isDirectory: true
            )
            let base = URL(
                fileURLWithPath:
                    "/private/tmp/prime-validation-public-admission-"
                    + UUID().uuidString,
                isDirectory: true
            )
            defer { try? FileManager.default.removeItem(at: base) }
            let workspace = base.appendingPathComponent(
                "workspace",
                isDirectory: true
            )
            let evidence = base.appendingPathComponent(
                "evidence",
                isDirectory: true
            )
            let lease = base.appendingPathComponent(
                "lease",
                isDirectory: true
            )
            for directory in [base, workspace, evidence, lease] {
                try makePrivateDirectory(directory)
            }

            let capability = try
                PrimeValidationSwiftPMBuildInventoryAdmission
                .admitPrerequisites(
                    primeRepositoryURL: primeRepository,
                    workspaceRootURL: workspace,
                    evidenceRootURL: evidence,
                    leaseDirectoryURL: lease,
                    companionRepositoryURL: URL(
                        fileURLWithPath: companionPath,
                        isDirectory: true
                    ),
                    companionDeclaration: .init(
                        expectedPinnedHEAD:
                            PrimeValidationRunIntentV2
                            .requiredCompanionCommit,
                        declaredObservedHEAD:
                            PrimeValidationRunIntentV2
                            .requiredCompanionCommit,
                        declaredPorcelainV2Status: Data()
                    ),
                    developerDirectoryURL: URL(
                        fileURLWithPath: Fixture.developerPath,
                        isDirectory: true
                    )
                )
            let prerequisite = try capability.consumePrerequisites()
            XCTAssertEqual(
                prerequisite.sourceIdentitySHA256,
                PrimeEmbeddedBuildProvenance.sourceIdentitySHA256
            )
            XCTAssertEqual(
                prerequisite.missingAuthorities,
                PrimeValidationSwiftPMMissingAuthority.allCases
            )
            XCTAssertEqual(
                prerequisite.processExecutionObservation,
                .unobserved
            )
            XCTAssertFalse(prerequisite.completionAuthorized)
            let guarded = try prerequisite.prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
            try guarded.revalidateGuards()
            XCTAssertEqual(guarded.guardState, .prepared)
            XCTAssertTrue(guarded.sourceDescriptorClosureHeld)
            XCTAssertTrue(guarded.sourceWatchWindowArmed)
            XCTAssertTrue(guarded.companionSourceDescriptorClosureHeld)
            XCTAssertTrue(guarded.companionSourceWatchWindowArmed)
            XCTAssertEqual(
                guarded.combinedSourceWatcherDescriptorCount,
                2_232
            )
            XCTAssertTrue(
                guarded.missingAuthorities.contains(
                    .supervisorExecutableImage
                )
            )
            XCTAssertThrowsError(try capability.consumePrerequisites())
            withExtendedLifetime(guarded) {}
        #endif
    }

    func testRealToolchainPrerequisiteIsExplicitlyNotPreparedExecutor()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capability = try fixture.admit()
        try assertAdmissionOnly(
            capability,
            fixture: fixture
        )
        fixture.cleanup()
    }

    private func assertAdmissionOnly(
        _ capability:
            PrimeValidationSwiftPMBuildInventoryAdmissionCapability,
        fixture: Fixture
    ) throws {
        let prerequisite = try capability.consumePrerequisites()

        XCTAssertEqual(
            prerequisite.authorityCeiling,
            .retainedInputsOnlyNoPreparedExecutor
        )
        XCTAssertEqual(
            prerequisite.missingAuthorities,
            PrimeValidationSwiftPMMissingAuthority.allCases
        )
        XCTAssertEqual(
            prerequisite.processExecutionObservation,
            .unobserved
        )
        XCTAssertEqual(
            prerequisite.buildExecutionObservation,
            .unobserved
        )
        XCTAssertEqual(
            prerequisite.inventoryExecutionObservation,
            .unobserved
        )
        XCTAssertFalse(prerequisite.completionAuthorized)
        XCTAssertTrue(
            prerequisite.companionDeclaration
                .processObservationMissing
        )
        XCTAssertTrue(
            prerequisite.toolchain
                .swiftVersionProcessObservationMissing
        )
        XCTAssertTrue(
            prerequisite.toolchain
                .swiftTargetInfoProcessObservationMissing
        )
        XCTAssertEqual(
            prerequisite.toolchain.swiftPackageExecutable
                .canonicalAbsolutePath,
            Fixture.swiftPackagePath
        )
        XCTAssertGreaterThan(
            prerequisite.toolchain.swiftPackageExecutable.byteCount,
            0
        )
        XCTAssertEqual(
            prerequisite.toolchain.swiftBuildPersonality
                .symbolicLinkTarget,
            "swift-package"
        )
        XCTAssertEqual(
            prerequisite.toolchain.swiftTestPersonality
                .symbolicLinkTarget,
            "swift-package"
        )
        XCTAssertEqual(
            prerequisite.toolchain.sdkRoot.canonicalAbsolutePath,
            Fixture.sdkPath
        )
        XCTAssertEqual(
            prerequisite.toolchain.sdkRoot.filesystemType,
            "apfs"
        )
        XCTAssertTrue(
            prerequisite.toolchain.sdkRoot.localFilesystemObserved
        )
        XCTAssertTrue(
            prerequisite.toolchain.sdkRoot.filesystemIDWord0 != 0
                || prerequisite.toolchain.sdkRoot.filesystemIDWord1 != 0
        )
        XCTAssertEqual(
            prerequisite.packageResolvedBinding.relativePath,
            "Package.resolved"
        )
        XCTAssertEqual(
            prerequisite.sourceIdentitySHA256,
            fixture.sourceExpectation.sourceIdentitySHA256
        )

        let keys = prerequisite.toolchain
            .orderedDeterministicBaseEnvironment.map(\.key)
        XCTAssertEqual(
            keys,
            [
                "CFFIXED_USER_HOME",
                "CLANG_MODULE_CACHE_PATH",
                "DEVELOPER_DIR",
                "HOME",
                "LANG",
                "LC_ALL",
                "PATH",
                "SDKROOT",
                "SOURCE_DATE_EPOCH",
                "SWIFTPM_MODULECACHE_OVERRIDE",
                "TERM",
                "TMPDIR",
                "TZ",
            ]
        )
        XCTAssertFalse(keys.contains(where: { $0.hasPrefix("DYLD_") }))
        let environment = Dictionary(
            uniqueKeysWithValues: prerequisite.toolchain
                .orderedDeterministicBaseEnvironment.map {
                    ($0.key, $0.value)
                }
        )
        XCTAssertEqual(
            environment["TMPDIR"],
            fixture.workspace.path + "/temporary"
        )
        XCTAssertEqual(
            environment["CFFIXED_USER_HOME"],
            fixture.workspace.path + "/home"
        )
        XCTAssertEqual(
            environment["PATH"],
            Fixture.developerPath
                + "/Toolchains/XcodeDefault.xctoolchain/usr/bin:"
                + "/usr/bin:/bin"
        )

        XCTAssertThrowsError(try capability.consumePrerequisites()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .capabilityAlreadyConsumed
            )
        }
        withExtendedLifetime(prerequisite) {}
    }

    func testConsumedPrerequisiteRetainsExclusiveLease() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        var capability:
            PrimeValidationSwiftPMBuildInventoryAdmissionCapability? =
                try fixture.admit()
        assertLeaseBusy(fixture.lockURL)

        var prerequisite = try capability?.consumePrerequisites()
        XCTAssertNotNil(prerequisite)
        XCTAssertEqual(
            prerequisite?.processExecutionObservation,
            .unobserved
        )
        XCTAssertEqual(
            prerequisite?.missingAuthorities,
            PrimeValidationSwiftPMMissingAuthority.allCases
        )
        XCTAssertEqual(prerequisite?.completionAuthorized, false)
        capability = nil
        assertLeaseBusy(fixture.lockURL)

        prerequisite = nil
        let reacquired = try PrimeMetalDeviceLease.acquire(
            at: fixture.lockURL
        )
        XCTAssertTrue(reacquired.isHeld)
        reacquired.release()
    }

    func testGuardedPreExecutorClosesDualSourceContinuityOnly()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capability = try fixture.admit()
        let prerequisite = try capability.consumePrerequisites()
        let guarded = try prerequisite.prepareGuardedPreExecutor(
            allowRootOwnedCurrentProcessForTesting: true
        )

        try guarded.revalidateGuards()
        XCTAssertEqual(guarded.guardState, .prepared)
        XCTAssertEqual(
            guarded.authorityCeiling,
            .sourceGuardsPreparedOnly
        )
        XCTAssertTrue(guarded.sourceDescriptorClosureHeld)
        XCTAssertTrue(guarded.sourceWatchWindowArmed)
        XCTAssertTrue(guarded.companionSourceDescriptorClosureHeld)
        XCTAssertTrue(guarded.companionSourceWatchWindowArmed)
        XCTAssertEqual(
            guarded.combinedSourceWatcherDescriptorCount,
            45
        )
        XCTAssertTrue(guarded.currentProcessExecutableImageHeld)
        XCTAssertEqual(
            guarded.missingAuthorities,
            [
                .supervisorExecutableImage,
                .primeGitHEADAndCleanProcessObservation,
                .companionGitHEADAndCleanProcessObservation,
                .swiftVersionProcessObservation,
                .swiftTargetInfoProcessObservation,
                .swiftPMBuildExecution,
                .xctestInventoryExecution,
                .swiftTestingInventoryExecution,
                .artifactStaging,
            ]
        )
        XCTAssertEqual(guarded.processExecutionObservation, .unobserved)
        XCTAssertEqual(guarded.buildExecutionObservation, .unobserved)
        XCTAssertEqual(guarded.inventoryExecutionObservation, .unobserved)
        XCTAssertEqual(guarded.artifactStagingObservation, .unobserved)
        XCTAssertEqual(guarded.shardCompletionObservation, .unobserved)
        XCTAssertFalse(guarded.completionAuthorized)
        XCTAssertGreaterThan(
            guarded.currentProcessExecutable.byteCount,
            0
        )
        XCTAssertEqual(
            guarded.currentProcessExecutable.sha256.count,
            64
        )
        XCTAssertTrue(
            guarded.currentProcessExecutable.canonicalAbsolutePath
                .hasPrefix("/")
        )
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.workspace.path
            ),
            []
        )
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.evidence.path
            ),
            []
        )
        XCTAssertThrowsError(
            try prerequisite.prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .prerequisiteAlreadyConsumed
            )
        }
        withExtendedLifetime(guarded) {}
    }

    func testConcurrentGuardPreparationHasExactlyOneWinner() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let prerequisite = try fixture.admit().consumePrerequisites()
        let race = GuardPreparationRace()
        let ready = DispatchGroup()
        let done = DispatchGroup()
        let start = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(
            label: "prime.validation.guard-preparation-race",
            attributes: .concurrent
        )

        for _ in 0 ..< 2 {
            ready.enter()
            done.enter()
            queue.async {
                ready.leave()
                start.wait()
                race.record {
                    try prerequisite.prepareGuardedPreExecutor(
                        allowRootOwnedCurrentProcessForTesting: true
                    )
                }
                done.leave()
            }
        }
        XCTAssertEqual(ready.wait(timeout: .now() + 5), .success)
        start.signal()
        start.signal()
        XCTAssertEqual(done.wait(timeout: .now() + 30), .success)

        XCTAssertEqual(race.values.count, 1)
        XCTAssertEqual(race.errors.count, 1)
        XCTAssertEqual(
            race.errors.first as?
                PrimeValidationSwiftPMBuildInventoryAdmissionError,
            .prerequisiteAlreadyConsumed
        )
        try race.values.first?.revalidateGuards()
        race.releaseValues()
    }

    func testDriverV2ImageMatchTransfersGuardAndRetainsMappedJoin()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        let expected = try expectation(for: guarded)

        let image = try guarded
            .bindDriverV2SupervisorImageAllowingTestHost(
                expecting: expected
            )

        XCTAssertEqual(guarded.guardState, .transferred)
        XCTAssertEqual(guarded.authorityCeiling, .transferredNoAuthority)
        XCTAssertEqual(
            guarded.missingAuthorities,
            PrimeValidationSwiftPMMissingAuthority.allCases
        )
        XCTAssertFalse(guarded.sourceDescriptorClosureHeld)
        XCTAssertFalse(guarded.sourceWatchWindowArmed)
        XCTAssertFalse(guarded.companionSourceDescriptorClosureHeld)
        XCTAssertFalse(guarded.companionSourceWatchWindowArmed)
        XCTAssertEqual(guarded.combinedSourceWatcherDescriptorCount, 0)
        XCTAssertFalse(guarded.currentProcessExecutableImageHeld)
        XCTAssertFalse(image.productionSupervisorImageEligible)
        XCTAssertEqual(image.imageState, .bound)
        XCTAssertTrue(image.observation.mappedImageJoined)
        XCTAssertEqual(
            image.observation.deviceID,
            image.observation.loadedImageDeviceID
        )
        XCTAssertEqual(
            image.observation.inode,
            image.observation.loadedImageInode
        )
        XCTAssertEqual(
            image.observation.canonicalAbsolutePath,
            expected.canonicalAbsolutePath
        )
        XCTAssertEqual(image.observation.byteCount, expected.byteCount)
        XCTAssertEqual(image.observation.sha256, expected.sha256)
        try image.revalidate()
        XCTAssertThrowsError(try guarded.revalidateGuards()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorTransferred
            )
        }
    }

    func testPostGuardCompanionMutationPermanentlyPoisonsGuard()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        XCTAssertEqual(guarded.combinedSourceWatcherDescriptorCount, 45)

        try Data("mutated companion\n".utf8).write(
            to: fixture.companion.appendingPathComponent(
                "Sources/Companion.swift"
            )
        )
        XCTAssertThrowsError(try guarded.revalidateGuards())
        XCTAssertEqual(guarded.guardState, .poisoned)
        XCTAssertEqual(guarded.authorityCeiling, .poisonedNoAuthority)
        XCTAssertEqual(
            guarded.missingAuthorities,
            PrimeValidationSwiftPMMissingAuthority.allCases
        )
        XCTAssertFalse(guarded.sourceDescriptorClosureHeld)
        XCTAssertFalse(guarded.sourceWatchWindowArmed)
        XCTAssertFalse(guarded.companionSourceDescriptorClosureHeld)
        XCTAssertFalse(guarded.companionSourceWatchWindowArmed)
        XCTAssertEqual(guarded.combinedSourceWatcherDescriptorCount, 0)
        XCTAssertThrowsError(try guarded.revalidateGuards()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned
            )
        }
    }

    func testDriverV2ImageMismatchPermanentlyPoisonsGuard() throws {
        enum Mutation: CaseIterable {
            case path
            case malformedPath
            case byteCount
            case sha256
        }

        for mutation in Mutation.allCases {
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            let guarded = try fixture.admit()
                .consumePrerequisites()
                .prepareGuardedPreExecutor(
                    allowRootOwnedCurrentProcessForTesting: true
                )
            let exact = try expectation(for: guarded)
            let mutated =
                PrimeValidationSwiftPMDriverV2ExecutableExpectation(
                    canonicalAbsolutePath: mutation == .path
                        ? "/private/tmp/not-the-mapped-supervisor"
                        : mutation == .malformedPath
                            ? "/private/tmp/../not-canonical"
                        : exact.canonicalAbsolutePath,
                    byteCount: mutation == .byteCount
                        ? exact.byteCount + 1
                        : exact.byteCount,
                    sha256: mutation == .sha256
                        ? String(repeating: "0", count: 64)
                        : exact.sha256
                )

            XCTAssertThrowsError(
                try guarded
                    .bindDriverV2SupervisorImageAllowingTestHost(
                        expecting: mutated
                    )
            ) {
                XCTAssertEqual(
                    $0 as?
                        PrimeValidationSwiftPMBuildInventoryAdmissionError,
                    mutation == .malformedPath
                        ? .rejected(
                            "driver_v2_supervisor_expectation"
                        )
                        : .rejected(
                            "driver_v2_supervisor_image_binding"
                        )
                )
            }
            XCTAssertEqual(guarded.guardState, .poisoned)
            XCTAssertEqual(
                guarded.authorityCeiling,
                .poisonedNoAuthority
            )
            XCTAssertEqual(
                guarded.missingAuthorities,
                PrimeValidationSwiftPMMissingAuthority.allCases
            )
            XCTAssertThrowsError(
                try guarded
                    .bindDriverV2SupervisorImageAllowingTestHost(
                        expecting: exact
                    )
            ) {
                XCTAssertEqual(
                    $0 as?
                        PrimeValidationSwiftPMBuildInventoryAdmissionError,
                    .guardedPreExecutorPoisoned
                )
            }
        }
    }

    func testConcurrentDriverV2ImageMatchHasExactlyOneWinner()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        let expected = try expectation(for: guarded)
        let race = DriverV2ImageBindingRace()
        let ready = DispatchGroup()
        let done = DispatchGroup()
        let start = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(
            label: "prime.validation.driver-v2-image-binding-race",
            attributes: .concurrent
        )

        for _ in 0 ..< 2 {
            ready.enter()
            done.enter()
            queue.async {
                ready.leave()
                start.wait()
                race.record {
                    try guarded
                        .bindDriverV2SupervisorImageAllowingTestHost(
                            expecting: expected
                        )
                }
                done.leave()
            }
        }
        XCTAssertEqual(ready.wait(timeout: .now() + 5), .success)
        start.signal()
        start.signal()
        XCTAssertEqual(done.wait(timeout: .now() + 30), .success)

        XCTAssertEqual(race.values.count, 1)
        XCTAssertEqual(race.errors.count, 1)
        XCTAssertEqual(
            race.errors.first as?
                PrimeValidationSwiftPMBuildInventoryAdmissionError,
            .guardedPreExecutorTransferred
        )
        try race.values.first?.revalidate()
        race.releaseValues()
    }

    func testProductionDriverV2BridgeRejectsXCTestHost() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        let imageData = try Data(
            contentsOf: URL(
                fileURLWithPath:
                    guarded.currentProcessExecutable
                    .canonicalAbsolutePath
            )
        )
        let intent = try fixture.makeIntent(
            guarded: guarded,
            driverImageData: imageData
        )

        XCTAssertThrowsError(
            try PrimeValidationDriverV2SupervisorImageBridge.bind(
                intent: intent,
                guardedPreExecutor: guarded
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .rejected("driver_v2_supervisor_executable_role")
            )
        }
        XCTAssertEqual(guarded.guardState, .poisoned)
        XCTAssertEqual(
            guarded.missingAuthorities,
            PrimeValidationSwiftPMMissingAuthority.allCases
        )
    }

    func testDriverV2LaunchRequestIsCanonicalTransportOnly()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        let imageData = try Data(
            contentsOf: URL(
                fileURLWithPath:
                    guarded.currentProcessExecutable
                    .canonicalAbsolutePath
            )
        )
        let intent = try fixture.makeIntent(
            guarded: guarded,
            driverImageData: imageData
        )
        let exact = PrimeValidationDriverV2SupervisorLaunchRequestV1(
            intent: intent,
            leaseDirectoryAbsolutePath: fixture.lease.path
        )
        try exact.validate()
        let canonical = try PrimeCanonicalJSON.encode(exact)
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                PrimeValidationDriverV2SupervisorLaunchRequestV1.self,
                from: canonical
            ),
            exact
        )

        var noncanonical = canonical
        noncanonical.append(0x0a)
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                PrimeValidationDriverV2SupervisorLaunchRequestV1.self,
                from: noncanonical
            )
        )

        for invalidLease in [
            fixture.prime.path,
            fixture.base.path,
            fixture.workspace.appendingPathComponent("nested").path,
        ] {
            XCTAssertThrowsError(
                try PrimeValidationDriverV2SupervisorLaunchRequestV1(
                    intent: intent,
                    leaseDirectoryAbsolutePath: invalidLease
                ).validate()
            )
        }
    }

    func testMatchedDriverV2ImagePoisonsAfterSourceMutation()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        let image = try guarded
            .bindDriverV2SupervisorImageAllowingTestHost(
                expecting: try expectation(for: guarded)
            )

        try Data("mutated\n".utf8).write(
            to: fixture.prime.appendingPathComponent("README.md")
        )
        XCTAssertThrowsError(try image.revalidate())
        XCTAssertEqual(image.imageState, .poisoned)
        XCTAssertThrowsError(try image.revalidate()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned
            )
        }
    }

    func testGuardPreparationFailurePoisonsOneShotTransition() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let prerequisite = try fixture.admit().consumePrerequisites()
        try Data("occupied".utf8).write(
            to: fixture.workspace.appendingPathComponent("unexpected")
        )

        XCTAssertThrowsError(
            try prerequisite.prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        )
        XCTAssertThrowsError(
            try prerequisite.prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .prerequisiteAlreadyConsumed
            )
        }
    }

    func testPostGuardSourceMutationPermanentlyPoisonsGuard() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        try guarded.revalidateGuards()

        try Data("mutated\n".utf8).write(
            to: fixture.prime.appendingPathComponent("README.md")
        )
        XCTAssertThrowsError(try guarded.revalidateGuards())
        XCTAssertEqual(guarded.guardState, .poisoned)
        XCTAssertEqual(guarded.authorityCeiling, .poisonedNoAuthority)
        XCTAssertEqual(
            guarded.missingAuthorities,
            PrimeValidationSwiftPMMissingAuthority.allCases
        )
        XCTAssertFalse(guarded.sourceDescriptorClosureHeld)
        XCTAssertFalse(guarded.sourceWatchWindowArmed)
        XCTAssertFalse(guarded.currentProcessExecutableImageHeld)
        XCTAssertThrowsError(try guarded.revalidateGuards()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned
            )
        }
    }

    func testRetainedRootOwnedXCTestImageIsExplicitlyTestOnly()
        throws
    {
        let held = try PrimeSecureRunningExecutableCapture
            .heldExecutableAllowingRootOwnerForTesting()
        XCTAssertGreaterThan(held.byteCount, 0)
        XCTAssertEqual(held.linkCount, 1)
        try held.revalidate()
    }

    func testAdmissionRequiresEveryGateCPrimeCoreSource() throws {
        try [
            "Sources/PrimeCore/" +
                "PrimeNativeNeuralGateHeldSourceClosure.swift",
            "Sources/PrimeCore/PrimeSecureHeldSourceWatch.swift",
            "Sources/PrimeCore/" +
                "PrimeValidationDriverV2IsolatedSpawnCanary.swift",
            "Sources/PrimeCore/" +
                "PrimeValidationDriverV2FixedProbeExecutor.swift",
            "Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift",
            "Sources/PrimeCore/" +
                "PrimeValidationDriverV2TrackedTreeHeldEntry.swift",
            "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverCore/" +
                "PrimeValidationDriverV2TrackedTreeManifest.swift",
            "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverCore/" +
                "PrimeValidationDriverV2FixedProbeBinding.swift",
        ].forEach { relativePath in
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            try FileManager.default.removeItem(
                at: fixture.prime.appendingPathComponent(relativePath)
            )

            XCTAssertThrowsError(try fixture.admit()) {
                XCTAssertEqual(
                    $0 as?
                        PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite,
                    .sourceSnapshot,
                    relativePath
                )
            }
        }
    }

    @available(macOS 26.0, *)
    func testRoleBridgeRejectsNonfrozenPhaseBudgetBeforeTransfer() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try preparedGuard(for: fixture)
        let exact = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        ).intent
        let changedBudgets = exact.phaseBudgets.map { budget in
            PrimeValidationPhaseBudgetV2(
                phase: budget.phase,
                maximumActiveNanoseconds:
                    budget.maximumActiveNanoseconds
                    + (budget.phase == .build ? 1 : 0)
            )
        }
        let changed = copyIntent(
            exact,
            phaseBudgets: changedBudgets
        )

        XCTAssertThrowsError(
            try PrimeValidationDriverV2RoleBridge.roleContext(from: changed)
        ) {
            XCTAssertEqual(
                $0 as? PrimeValidationDriverV2Error,
                .invalidIntent
            )
        }
        XCTAssertEqual(guarded.guardState, .prepared)
    }

    @available(macOS 26.0, *)
    func testFixedRoleFacadeIsPositionedAtBuildWithExactClosedPolicySequence()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        let inputs = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        )

        let facade = try image.transferDriverV2RoleFacade(
            context: inputs.context
        )
        XCTAssertEqual(facade.continuityState, .dualRootGuarded)
        XCTAssertTrue(facade.primeSourceDescriptorClosureHeld)
        XCTAssertTrue(facade.companionSourceDescriptorClosureHeld)
        XCTAssertTrue(facade.primeSourceWatchWindowArmed)
        XCTAssertTrue(facade.companionSourceWatchWindowArmed)
        XCTAssertEqual(facade.combinedSourceWatcherDescriptorCount, 45)
        try facade.revalidateContinuity()
        XCTAssertEqual(facade.continuityState, .dualRootGuarded)
        let policies = facade.fixedPolicyObservations
        XCTAssertEqual(
            policies.map(\.role),
            [
                .build,
                .listXCTest,
                .listSwiftTesting,
            ]
        )
        XCTAssertEqual(facade.positionedRole, .build)
        XCTAssertEqual(facade.positionedPolicy, policies[0])
        XCTAssertEqual(facade.processExecutionObservation, .unobserved)
        XCTAssertEqual(facade.buildExecutionObservation, .unobserved)
        XCTAssertEqual(facade.inventoryExecutionObservation, .unobserved)
        XCTAssertFalse(facade.completionAuthorized)

        let context = inputs.context
        let intent = inputs.intent
        XCTAssertEqual(
            context.repositoryRootAbsolutePath,
            intent.roots.repositoryRoot.absolutePath
        )
        XCTAssertEqual(
            context.companionRootAbsolutePath,
            intent.roots.companionRoot.absolutePath
        )
        XCTAssertEqual(
            context.workspaceRootAbsolutePath,
            intent.roots.workspaceRoot.absolutePath
        )
        XCTAssertEqual(
            context.evidenceRootAbsolutePath,
            intent.roots.evidenceRoot.absolutePath
        )
        XCTAssertEqual(
            context.scratchAbsolutePath,
            intent.roots.scratchAbsolutePath
        )
        XCTAssertEqual(
            context.cacheAbsolutePath,
            intent.roots.cacheAbsolutePath
        )
        XCTAssertEqual(
            context.configAbsolutePath,
            intent.roots.configAbsolutePath
        )
        XCTAssertEqual(
            context.securityAbsolutePath,
            intent.roots.securityAbsolutePath
        )
        XCTAssertEqual(
            context.clangModuleCacheAbsolutePath,
            intent.roots.clangModuleCacheAbsolutePath
        )
        XCTAssertEqual(
            context.outputAbsolutePath,
            intent.roots.outputAbsolutePath
        )
        XCTAssertEqual(
            context.homeAbsolutePath,
            intent.roots.homeAbsolutePath
        )
        XCTAssertEqual(
            context.swiftPMModuleCacheAbsolutePath,
            intent.roots.swiftPMModuleCacheAbsolutePath
        )
        XCTAssertEqual(
            context.temporaryAbsolutePath,
            intent.roots.temporaryAbsolutePath
        )
        XCTAssertEqual(
            context.requiredPinnedMetallibAbsolutePath,
            context.workspaceRootAbsolutePath + "/"
                + intent.requiredPinnedMetallib.relativePath
        )
        for (mapped, declared) in [
            (context.repositoryRoot, intent.roots.repositoryRoot),
            (context.companionRoot, intent.roots.companionRoot),
            (context.workspaceRoot, intent.roots.workspaceRoot),
            (context.evidenceRoot, intent.roots.evidenceRoot),
        ] {
            XCTAssertEqual(mapped.absolutePath, declared.absolutePath)
            XCTAssertEqual(mapped.deviceID, declared.deviceID)
            XCTAssertEqual(mapped.inode, declared.inode)
            XCTAssertEqual(mapped.ownerUserID, declared.ownerUserID)
            XCTAssertEqual(mapped.permissionMode, declared.mode)
        }

        let commonArguments = [
            "-Xswiftc", "-enable-testing",
            "--package-path", context.repositoryRootAbsolutePath,
            "--scratch-path", context.scratchAbsolutePath,
            "--cache-path", context.cacheAbsolutePath,
            "--config-path", context.configAbsolutePath,
            "--security-path", context.securityAbsolutePath,
        ]
        XCTAssertEqual(
            policies.map(\.physicalArguments),
            [
                commonArguments + [
                    "--configuration", "release",
                    "--build-tests",
                    "--force-resolved-versions",
                    "--jobs", "2",
                    "--disable-build-manifest-caching",
                    "-Xswiftc", "-num-threads", "-Xswiftc", "2",
                ],
                commonArguments + [
                    "--configuration", "release",
                    "--skip-build",
                    "--force-resolved-versions",
                    "--disable-swift-testing", "list",
                ],
                commonArguments + [
                    "--configuration", "release",
                    "--skip-build",
                    "--force-resolved-versions",
                    "--disable-xctest", "list",
                ],
            ]
        )
        XCTAssertTrue(
            policies.allSatisfy {
                $0.physicalArguments.first != "build"
                    && $0.physicalArguments.first != "test"
            }
        )
        XCTAssertEqual(
            policies.map(\.logicalArgumentZero),
            ["swift-build", "swift-test", "swift-test"]
        )
        XCTAssertEqual(
            policies.map(\.physicalExecutableAbsolutePath),
            Array(
                repeating:
                    guarded.toolchain.swiftPackageExecutable
                    .canonicalAbsolutePath,
                count: 3
            )
        )
        XCTAssertEqual(
            policies.map(\.physicalWorkingDirectoryAbsolutePath),
            Array(repeating: context.repositoryRootAbsolutePath, count: 3)
        )
        XCTAssertEqual(
            policies.map(\.maximumWallNanoseconds),
            [
                900 * 1_000_000_000,
                300 * 1_000_000_000,
                300 * 1_000_000_000,
            ]
        )
        XCTAssertEqual(
            policies.map(\.standardInputPolicy),
            Array(repeating: .endOfFile, count: 3)
        )
        XCTAssertEqual(
            policies.map(\.standardOutputMaximumByteCount),
            Array(repeating: 16 * 1024 * 1024, count: 3)
        )
        XCTAssertEqual(
            policies.map(\.standardErrorMaximumByteCount),
            Array(repeating: 16 * 1024 * 1024, count: 3)
        )
        XCTAssertEqual(
            policies.map(\.drainChunkByteCount),
            Array(repeating: 64 * 1024, count: 3)
        )
        XCTAssertEqual(
            policies.map(\.primaryResult),
            [.none, .standardOutput, .standardOutput]
        )

        let developer = guarded.toolchain.developerDirectory
            .canonicalAbsolutePath
        let expectedEnvironment = [
            "CFFIXED_USER_HOME=" + context.homeAbsolutePath,
            "CLANG_MODULE_CACHE_PATH="
                + context.clangModuleCacheAbsolutePath,
            "DEVELOPER_DIR=" + developer,
            "HOME=" + context.homeAbsolutePath,
            "LANG=C",
            "LC_ALL=C",
            "PATH=" + developer
                + "/Toolchains/XcodeDefault.xctoolchain/usr/bin:"
                + "/usr/bin:/bin",
            "PRIME_PMHNP_COMPANION_ROOT="
                + context.companionRootAbsolutePath,
            "PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE=1",
            "PRIME_REQUIRE_V11_HISTORICAL_FIXTURE_SOURCE_GATE=1",
            "PRIME_REQUIRE_V12_HISTORICAL_EVIDENCE_EXPORT_SOURCE_GATE=1",
            "PRIME_REQUIRE_V9_PINNED_DONOR_GATE=1",
            "PRIME_TEST_PINNED_MLX_METALLIB="
                + context.requiredPinnedMetallibAbsolutePath,
            "SDKROOT="
                + guarded.toolchain.sdkRoot.canonicalAbsolutePath,
            "SOURCE_DATE_EPOCH=0",
            "SWIFTPM_MODULECACHE_OVERRIDE="
                + context.swiftPMModuleCacheAbsolutePath,
            "TERM=dumb",
            "TMPDIR=" + context.temporaryAbsolutePath,
            "TZ=UTC",
        ]
        for policy in policies {
            XCTAssertEqual(
                policy.completeReplacementEnvironment.map {
                    $0.key + "=" + $0.value
                },
                expectedEnvironment
            )
            XCTAssertEqual(
                policy.completeReplacementEnvironmentKeys,
                expectedEnvironment.map {
                    String($0.prefix { $0 != "=" })
                }
            )
        }
        assertLeaseBusy(fixture.lockURL)
        withExtendedLifetime(facade) {}
    }

    @available(macOS 26.0, *)
    func testFixedRoleFacadeTransferIsSequentiallyOneShot() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        let inputs = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        )

        let facade = try image.transferDriverV2RoleFacade(
            context: inputs.context
        )
        XCTAssertEqual(image.imageState, .transferred)
        XCTAssertThrowsError(
            try image.transferDriverV2RoleFacade(
                context: inputs.context
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorTransferred
            )
        }
        assertLeaseBusy(fixture.lockURL)
        withExtendedLifetime(facade) {}
    }

    @available(macOS 26.0, *)
    func testFixedRoleFacadeDisposalReleasesLeaseWithoutRestoringAuthority()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        let context = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        ).context

        var facade: PrimeValidationDriverV2RoleFacade? =
            try image.transferDriverV2RoleFacade(context: context)
        XCTAssertNotNil(facade)
        assertLeaseBusy(fixture.lockURL)
        facade = nil

        // Reacquisition is only a disposal diagnostic. The consumed image
        // remains transferred and cannot restore the retired authority.
        let diagnostic = try PrimeMetalDeviceLease.acquire(
            at: fixture.lockURL
        )
        XCTAssertTrue(diagnostic.isHeld)
        diagnostic.release()
        XCTAssertEqual(image.imageState, .transferred)
        XCTAssertThrowsError(
            try image.transferDriverV2RoleFacade(context: context)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorTransferred
            )
        }
    }

    @available(macOS 26.0, *)
    func testConcurrentFixedRoleFacadeTransferHasExactlyOneWinner()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        let context = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        ).context
        let race = DriverV2RoleFacadeTransferRace()
        let ready = DispatchGroup()
        let done = DispatchGroup()
        let start = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(
            label: "prime.validation.driver-v2-role-facade-race",
            attributes: .concurrent
        )

        for _ in 0 ..< 2 {
            ready.enter()
            done.enter()
            queue.async {
                ready.leave()
                start.wait()
                race.record {
                    try image.transferDriverV2RoleFacade(
                        context: context
                    )
                }
                done.leave()
            }
        }
        XCTAssertEqual(ready.wait(timeout: .now() + 5), .success)
        start.signal()
        start.signal()
        XCTAssertEqual(done.wait(timeout: .now() + 30), .success)
        XCTAssertEqual(race.values.count, 1)
        XCTAssertEqual(race.errors.count, 1)
        XCTAssertEqual(
            race.errors.first as?
                PrimeValidationSwiftPMBuildInventoryAdmissionError,
            .guardedPreExecutorTransferred
        )
        XCTAssertEqual(image.imageState, .transferred)
        assertLeaseBusy(fixture.lockURL)
        race.releaseValues()
    }

    @available(macOS 26.0, *)
    func testFixedRoleFacadeContextMismatchPoisonsAndCannotRetry()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        let exact = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        ).context
        let mismatch = copyRoleContext(
            exact,
            scratchAbsolutePath:
                exact.workspaceRootAbsolutePath + "/wrong-scratch"
        )

        XCTAssertThrowsError(
            try image.transferDriverV2RoleFacade(context: mismatch)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .rejected("driver_v2_role_context")
            )
        }
        XCTAssertEqual(image.imageState, .poisoned)
        XCTAssertThrowsError(
            try image.transferDriverV2RoleFacade(context: exact)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned
            )
        }
        let diagnostic = try PrimeMetalDeviceLease.acquire(
            at: fixture.lockURL
        )
        XCTAssertTrue(diagnostic.isHeld)
        diagnostic.release()
        XCTAssertEqual(image.imageState, .poisoned)
    }

    @available(macOS 26.0, *)
    func testFixedRoleFacadeRootIdentityMismatchPoisonsAndCannotRetry()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        let exact = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        ).context
        let declared = exact.repositoryRoot
        let mismatchRoot = PrimeValidationDriverV2RoleRootContext(
            absolutePath: declared.absolutePath,
            deviceID: declared.deviceID,
            inode: declared.inode + 1,
            ownerUserID: declared.ownerUserID,
            permissionMode: declared.permissionMode
        )
        let mismatch = copyRoleContext(
            exact,
            repositoryRoot: mismatchRoot
        )

        XCTAssertThrowsError(
            try image.transferDriverV2RoleFacade(context: mismatch)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .rejected("driver_v2_role_context")
            )
        }
        XCTAssertEqual(image.imageState, .poisoned)
        XCTAssertThrowsError(
            try image.transferDriverV2RoleFacade(context: exact)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned
            )
        }
    }

    @available(macOS 26.0, *)
    func testFixedRoleFacadeSourceMutationPoisonsAndCannotRetry()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        let context = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        ).context
        try Data("role-facade-mutation\n".utf8).write(
            to: fixture.prime.appendingPathComponent(
                "Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift"
            )
        )

        XCTAssertThrowsError(
            try image.transferDriverV2RoleFacade(context: context)
        ) { error in
            guard let provenanceError =
                    error as? PrimeSwiftSourceProvenanceError,
                  case .sourceIdentityMismatch = provenanceError
            else {
                return XCTFail("unexpected source-mutation error: \(error)")
            }
        }
        XCTAssertEqual(image.imageState, .poisoned)
        XCTAssertThrowsError(
            try image.transferDriverV2RoleFacade(context: context)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned
            )
        }
    }

    @available(macOS 26.0, *)
    func testFixedRoleFacadeContinuityMutationMatrixPermanentlyPoisons()
        throws
    {
        try assertFacadeContinuityPoison(
            "prime_file_write",
            mutate: { fixture in
                try Data("mutated prime\n".utf8).write(
                    to: fixture.prime.appendingPathComponent("README.md")
                )
            },
            restore: { fixture in
                try Data("fixture\n".utf8).write(
                    to: fixture.prime.appendingPathComponent("README.md")
                )
            }
        )
        try assertFacadeContinuityPoison(
            "companion_file_write",
            mutate: { fixture in
                try Data("mutated companion\n".utf8).write(
                    to: fixture.companion.appendingPathComponent(
                        "Sources/Companion.swift"
                    )
                )
            },
            restore: { fixture in
                try Data("// companion source\n".utf8).write(
                    to: fixture.companion.appendingPathComponent(
                        "Sources/Companion.swift"
                    )
                )
            }
        )
        try assertFacadeContinuityPoison(
            "companion_same_bytes_new_inode",
            mutate: { fixture in
                let original = fixture.companion.appendingPathComponent(
                    "Sources/Companion.swift"
                )
                let saved = fixture.base.appendingPathComponent(
                    "Companion.original"
                )
                let bytes = try Data(contentsOf: original)
                try FileManager.default.moveItem(at: original, to: saved)
                try bytes.write(to: original)
                var savedStatus = stat()
                var replacementStatus = stat()
                guard lstat(saved.path, &savedStatus) == 0,
                      lstat(original.path, &replacementStatus) == 0,
                      savedStatus.st_ino != replacementStatus.st_ino
                else {
                    throw FixtureError.invalid("replacement_inode")
                }
            },
            restore: { fixture in
                let replacement = fixture.companion.appendingPathComponent(
                    "Sources/Companion.swift"
                )
                let saved = fixture.base.appendingPathComponent(
                    "Companion.original"
                )
                try FileManager.default.removeItem(at: replacement)
                try FileManager.default.moveItem(at: saved, to: replacement)
            }
        )
        try assertFacadeContinuityPoison(
            "companion_rename_away_and_back",
            mutate: { fixture in
                let original = fixture.companion.appendingPathComponent(
                    "Sources/Companion.swift"
                )
                let moved = fixture.companion.appendingPathComponent(
                    "Sources/Companion.moved"
                )
                try FileManager.default.moveItem(at: original, to: moved)
                try FileManager.default.moveItem(at: moved, to: original)
            }
        )
        try assertFacadeContinuityPoison(
            "companion_transient_create_unlink",
            mutate: { fixture in
                let transient = fixture.companion.appendingPathComponent(
                    "transient"
                )
                try Data("transient\n".utf8).write(to: transient)
                try FileManager.default.removeItem(at: transient)
            }
        )
        try assertFacadeContinuityPoison(
            "companion_hidden_file_write",
            mutate: { fixture in
                try Data("mutated hidden\n".utf8).write(
                    to: fixture.companion.appendingPathComponent(
                        ".hidden/config"
                    )
                )
            },
            restore: { fixture in
                try Data("hidden fixture\n".utf8).write(
                    to: fixture.companion.appendingPathComponent(
                        ".hidden/config"
                    )
                )
            }
        )
        try assertFacadeContinuityPoison(
            "companion_preexisting_empty_directory_insertion",
            mutate: { fixture in
                let transient = fixture.companion.appendingPathComponent(
                    "Empty/later"
                )
                try Data("later\n".utf8).write(to: transient)
                try FileManager.default.removeItem(at: transient)
            }
        )
        try assertFacadeContinuityPoison(
            "companion_root_git_rename_away_and_back",
            mutate: { fixture in
                let original = fixture.companion.appendingPathComponent(
                    ".git",
                    isDirectory: true
                )
                let moved = fixture.companion.appendingPathComponent(
                    ".git-moved",
                    isDirectory: true
                )
                try FileManager.default.moveItem(at: original, to: moved)
                try FileManager.default.moveItem(at: moved, to: original)
            }
        )
        try assertFacadeContinuityPoison(
            "companion_root_git_replacement",
            mutate: { fixture in
                let original = fixture.companion.appendingPathComponent(
                    ".git",
                    isDirectory: true
                )
                let saved = fixture.companion.appendingPathComponent(
                    ".git-original",
                    isDirectory: true
                )
                try FileManager.default.moveItem(at: original, to: saved)
                try FileManager.default.createDirectory(
                    at: original,
                    withIntermediateDirectories: false
                )
                guard chmod(original.path, 0o700) == 0 else {
                    throw FixtureError.invalid("replacement_git_mode")
                }
            },
            restore: { fixture in
                let replacement = fixture.companion.appendingPathComponent(
                    ".git",
                    isDirectory: true
                )
                let saved = fixture.companion.appendingPathComponent(
                    ".git-original",
                    isDirectory: true
                )
                try FileManager.default.removeItem(at: replacement)
                try FileManager.default.moveItem(at: saved, to: replacement)
            }
        )
        try assertFacadeContinuityPoison(
            "companion_root_git_removal",
            mutate: { fixture in
                try FileManager.default.moveItem(
                    at: fixture.companion.appendingPathComponent(
                        ".git",
                        isDirectory: true
                    ),
                    to: fixture.companion.appendingPathComponent(
                        ".git-removed",
                        isDirectory: true
                    )
                )
            },
            restore: { fixture in
                try FileManager.default.moveItem(
                    at: fixture.companion.appendingPathComponent(
                        ".git-removed",
                        isDirectory: true
                    ),
                    to: fixture.companion.appendingPathComponent(
                        ".git",
                        isDirectory: true
                    )
                )
            }
        )
    }

    @available(macOS 26.0, *)
    func testFixedRoleFacadeExcludesOnlyRootGitDescendantChurn()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        let context = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        ).context
        let facade = try image.transferDriverV2RoleFacade(context: context)
        let head = fixture.companion.appendingPathComponent(".git/HEAD")

        try Data("ref: refs/heads/main\n".utf8).write(to: head)
        try facade.revalidateContinuity()
        try Data("ref: refs/heads/other\n".utf8).write(to: head)
        try facade.revalidateContinuity()

        XCTAssertEqual(facade.continuityState, .dualRootGuarded)
        XCTAssertEqual(facade.combinedSourceWatcherDescriptorCount, 45)
        XCTAssertEqual(facade.processExecutionObservation, .unobserved)
        XCTAssertEqual(facade.buildExecutionObservation, .unobserved)
        XCTAssertEqual(facade.inventoryExecutionObservation, .unobserved)
        XCTAssertFalse(facade.completionAuthorized)
    }

    @available(macOS 26.0, *)
    func testIsolatedSpawnCanaryClosesOnlyContainmentMechanics()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let facade = try testCanaryFacade(fixture: fixture)

        XCTAssertEqual(facade.isolatedSpawnCanaryState, .available)
        XCTAssertNil(facade.isolatedSpawnCanaryObservation)
        try facade.spawnIsolatedContainmentCanary()

        XCTAssertEqual(facade.isolatedSpawnCanaryState, .observed)
        let observation = try XCTUnwrap(
            facade.isolatedSpawnCanaryObservation
        )
        XCTAssertEqual(observation.appliedSpawnFlags, 0x448c)
        XCTAssertEqual(
            observation.sessionIdentifier,
            observation.processIdentifier
        )
        XCTAssertEqual(
            observation.processGroupIdentifier,
            observation.processIdentifier
        )
        XCTAssertEqual(
            observation.executableByteCount,
            PrimeValidationDriverV2IsolatedSpawnCanaryHeldExecutable
                .expectedByteCount
        )
        XCTAssertEqual(
            observation.executableSHA256,
            PrimeValidationDriverV2IsolatedSpawnCanaryHeldExecutable
                .expectedSHA256
        )
        XCTAssertTrue(observation.mappedImageJoined)
        XCTAssertEqual(
            observation.exactPIDWait.requestedProcessIdentifier,
            observation.processIdentifier
        )
        XCTAssertEqual(
            observation.exactPIDWait.returnedProcessIdentifier,
            observation.processIdentifier
        )
        XCTAssertEqual(observation.exactPIDWait.waitOptions, 0)
        XCTAssertTrue(observation.exactPIDWait.exitedNormally)
        XCTAssertEqual(observation.exactPIDWait.exitStatus, 0)
        XCTAssertEqual(observation.exactPIDWait.terminationSignal, 0)
        XCTAssertFalse(observation.exactPIDWait.coreDumped)
        XCTAssertEqual(observation.standardOutputByteCount, 0)
        XCTAssertEqual(observation.standardErrorByteCount, 0)
        XCTAssertTrue(observation.standardOutputReachedEOF)
        XCTAssertTrue(observation.standardErrorReachedEOF)
        XCTAssertTrue(observation.processGroupEmptyAfterReap)
        XCTAssertEqual(
            observation.combinedSourceWatcherDescriptorCount,
            45
        )
        XCTAssertTrue(observation.workspaceEmptyAfterReap)
        XCTAssertFalse(observation.productionSupervisorImageEligible)
        XCTAssertEqual(facade.processExecutionObservation, .unobserved)
        XCTAssertEqual(facade.buildExecutionObservation, .unobserved)
        XCTAssertEqual(facade.inventoryExecutionObservation, .unobserved)
        XCTAssertFalse(facade.completionAuthorized)

        let journalEntries = try FileManager.default
            .contentsOfDirectory(atPath: fixture.canaryJournal.path)
        XCTAssertEqual(
            Set(journalEntries),
            [
                "v2-spawn-01-start.json",
                "v2-spawn-01-terminal.json",
            ]
        )
        let startURL = fixture.canaryJournal.appendingPathComponent(
            "v2-spawn-01-start.json"
        )
        let terminalURL = fixture.canaryJournal.appendingPathComponent(
            "v2-spawn-01-terminal.json"
        )
        let startData = try Data(contentsOf: startURL)
        let terminalData = try Data(contentsOf: terminalURL)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: startData),
            observation.startLeafSHA256
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: terminalData),
            observation.terminalLeafSHA256
        )
        let startJSON = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: startData)
                as? [String: Any]
        )
        let terminalJSON = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: terminalData)
                as? [String: Any]
        )
        XCTAssertNil(startJSON["start_leaf_sha256"])
        XCTAssertNil(startJSON["terminal_leaf_sha256"])
        XCTAssertEqual(
            terminalJSON["start_leaf_sha256"] as? String,
            observation.startLeafSHA256
        )
        XCTAssertNil(terminalJSON["terminal_leaf_sha256"])
        for url in [startURL, terminalURL] {
            var status = stat()
            XCTAssertEqual(lstat(url.path, &status), 0)
            XCTAssertEqual(
                status.st_mode & mode_t(0o7777),
                mode_t(0o400)
            )
            XCTAssertEqual(status.st_nlink, 1)
        }
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.workspace.path
            ),
            []
        )
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.evidence.path
            ),
            []
        )
        try facade.revalidateContinuity()
        XCTAssertThrowsError(
            try facade.spawnIsolatedContainmentCanary()
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorTransferred
            )
        }
        XCTAssertEqual(facade.isolatedSpawnCanaryState, .observed)
    }

    @available(macOS 26.0, *)
    func testConcurrentIsolatedSpawnCanaryHasExactlyOneWinner()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        var emptyJournalStatus = stat()
        XCTAssertEqual(
            lstat(fixture.canaryJournal.path, &emptyJournalStatus),
            0
        )
        XCTAssertEqual(emptyJournalStatus.st_nlink, 2)
        let interlock =
            PrimeValidationDriverV2IsolatedSpawnCanaryTestInterlock()
        let facade = try testCanaryFacade(
            fixture: fixture,
            interlock: interlock
        )
        let race = DriverV2IsolatedSpawnCanaryRace()
        let ready = DispatchGroup()
        let done = DispatchGroup()
        let start = DispatchSemaphore(value: 0)
        for _ in 0 ..< 2 {
            ready.enter()
            done.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                ready.leave()
                start.wait()
                race.record {
                    try facade.spawnIsolatedContainmentCanary()
                }
                done.leave()
            }
        }
        ready.wait()
        start.signal()
        start.signal()
        guard interlock.waitForDurableStartPublication() else {
            interlock.permitResume()
            _ = done.wait(timeout: .now() + .seconds(10))
            return XCTFail("canary did not publish durable start")
        }
        XCTAssertEqual(facade.isolatedSpawnCanaryState, .running)
        var startedJournalStatus = stat()
        XCTAssertEqual(
            lstat(fixture.canaryJournal.path, &startedJournalStatus),
            0
        )
        XCTAssertEqual(
            startedJournalStatus.st_dev,
            emptyJournalStatus.st_dev
        )
        XCTAssertEqual(
            startedJournalStatus.st_ino,
            emptyJournalStatus.st_ino
        )
        XCTAssertEqual(
            startedJournalStatus.st_uid,
            emptyJournalStatus.st_uid
        )
        XCTAssertEqual(
            startedJournalStatus.st_gid,
            emptyJournalStatus.st_gid
        )
        XCTAssertEqual(
            startedJournalStatus.st_mode,
            emptyJournalStatus.st_mode
        )
        XCTAssertEqual(startedJournalStatus.st_nlink, 3)
        interlock.permitResume()
        XCTAssertEqual(
            done.wait(timeout: .now() + .seconds(10)),
            .success
        )
        XCTAssertEqual(race.successCount, 1)
        XCTAssertEqual(race.errors.count, 1)
        XCTAssertEqual(
            race.errors.first as?
                PrimeValidationSwiftPMBuildInventoryAdmissionError,
            .guardedPreExecutorTransferred
        )
        XCTAssertEqual(facade.isolatedSpawnCanaryState, .observed)
        var terminalJournalStatus = stat()
        XCTAssertEqual(
            lstat(fixture.canaryJournal.path, &terminalJournalStatus),
            0
        )
        XCTAssertEqual(
            terminalJournalStatus.st_dev,
            emptyJournalStatus.st_dev
        )
        XCTAssertEqual(
            terminalJournalStatus.st_ino,
            emptyJournalStatus.st_ino
        )
        XCTAssertEqual(
            terminalJournalStatus.st_uid,
            emptyJournalStatus.st_uid
        )
        XCTAssertEqual(
            terminalJournalStatus.st_gid,
            emptyJournalStatus.st_gid
        )
        XCTAssertEqual(
            terminalJournalStatus.st_mode,
            emptyJournalStatus.st_mode
        )
        XCTAssertEqual(terminalJournalStatus.st_nlink, 4)
        XCTAssertEqual(
            Set(
                try FileManager.default.contentsOfDirectory(
                    atPath: fixture.canaryJournal.path
                )
            ),
            [
                "v2-spawn-01-start.json",
                "v2-spawn-01-terminal.json",
            ]
        )
    }

    @available(macOS 26.0, *)
    func testPrimeMutationDuringIsolatedSpawnCanaryPoisonsFacade()
        throws
    {
        try assertIsolatedSpawnCanaryMutationPoisons { fixture in
            try Data("canary-prime-mutation\n".utf8).write(
                to: fixture.prime.appendingPathComponent(
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2RoleFacade.swift"
                )
            )
        }
    }

    @available(macOS 26.0, *)
    func testCompanionMutationDuringIsolatedSpawnCanaryPoisonsFacade()
        throws
    {
        try assertIsolatedSpawnCanaryMutationPoisons { fixture in
            try Data("canary-companion-mutation\n".utf8).write(
                to: fixture.companion.appendingPathComponent(
                    "Sources/Companion.swift"
                )
            )
        }
    }

    @available(macOS 26.0, *)
    func testIsolatedSpawnCanaryJournalCollisionPoisonsBeforeSpawn()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let collision = fixture.canaryJournal.appendingPathComponent(
            "v2-spawn-01-start.json"
        )
        let bytes = Data("preexisting\n".utf8)
        try bytes.write(to: collision)
        let facade = try testCanaryFacade(fixture: fixture)

        XCTAssertThrowsError(
            try facade.spawnIsolatedContainmentCanary()
        )
        XCTAssertEqual(facade.isolatedSpawnCanaryState, .poisoned)
        XCTAssertNil(facade.isolatedSpawnCanaryObservation)
        XCTAssertEqual(try Data(contentsOf: collision), bytes)
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.canaryJournal.path
            ),
            ["v2-spawn-01-start.json"]
        )
        XCTAssertThrowsError(
            try facade.spawnIsolatedContainmentCanary()
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned
            )
        }
    }

    @available(macOS 26.0, *)
    func testIsolatedSpawnCanaryPostSpawnJournalCollisionContainsAndPoisons()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let interlock =
            PrimeValidationDriverV2IsolatedSpawnCanaryTestInterlock()
        let facade = try testCanaryFacade(
            fixture: fixture,
            interlock: interlock
        )
        let race = DriverV2IsolatedSpawnCanaryRace()
        let done = DispatchGroup()
        done.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            race.record {
                try facade.spawnIsolatedContainmentCanary()
            }
            done.leave()
        }
        guard interlock.waitForDurableStartPublication() else {
            interlock.permitResume()
            _ = done.wait(timeout: .now() + .seconds(10))
            return XCTFail("canary did not publish durable start")
        }
        let collision = fixture.canaryJournal.appendingPathComponent(
            "v2-spawn-01-terminal.json"
        )
        try Data("collision\n".utf8).write(to: collision)
        interlock.permitResume()
        XCTAssertEqual(
            done.wait(timeout: .now() + .seconds(10)),
            .success
        )
        XCTAssertEqual(race.successCount, 0)
        XCTAssertEqual(race.errors.count, 1)
        try assertCanaryPIDContained(
            try canaryStartProcessIdentifier(fixture: fixture)
        )
        XCTAssertEqual(facade.isolatedSpawnCanaryState, .poisoned)
        XCTAssertNil(facade.isolatedSpawnCanaryObservation)
        XCTAssertEqual(
            Set(
                try FileManager.default.contentsOfDirectory(
                    atPath: fixture.canaryJournal.path
                )
            ),
            [
                "v2-spawn-01-start.json",
                "v2-spawn-01-terminal.json",
            ]
        )
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.workspace.path
            ),
            []
        )
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.evidence.path
            ),
            []
        )
        XCTAssertThrowsError(
            try facade.spawnIsolatedContainmentCanary()
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned
            )
        }
    }

    func testIsolatedSpawnCanarySourceAndManifestAreClosed() throws {
        var repositoryRoot = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 5 { repositoryRoot.deleteLastPathComponent() }
        var nestedRoot = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 3 { nestedRoot.deleteLastPathComponent() }
        let childURL = nestedRoot.appendingPathComponent(
            "Sources/PrimeValidationWorkflowDriverV2SpawnCanary/" +
                "main.swift"
        )
        let childData = try Data(contentsOf: childURL)
        XCTAssertEqual(childData.count, 381)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: childData),
            "052b27259c5bf39748bafbc22eeafb205fb1b3e00e247cda3e368c8ff2dbdd9c"
        )
        let childSource = try XCTUnwrap(
            String(data: childData, encoding: .utf8)
        )
        XCTAssertTrue(childSource.contains("import Darwin"))
        XCTAssertTrue(childSource.contains("Darwin._exit(0)"))
        for forbidden in [
            "CommandLine",
            "STDIN_FILENO",
            "STDOUT_FILENO",
            "STDERR_FILENO",
            "FileManager",
            "Process(",
            "posix_spawn",
            "fork(",
            "exec",
            "URLSession",
            "import Foundation",
        ] {
            XCTAssertFalse(childSource.contains(forbidden), forbidden)
        }
        let helperSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/PrimeCore/" +
                    "PrimeValidationDriverV2IsolatedSpawnCanary.swift"
            ),
            encoding: .utf8
        )
        XCTAssertEqual(
            helperSource.components(
                separatedBy:
                    "PrimeSecureChildDarwinSubstrate.spawnSuspended("
            ).count - 1,
            1
        )
        XCTAssertFalse(helperSource.contains("public func"))
        XCTAssertFalse(helperSource.contains("public init"))
        XCTAssertFalse(helperSource.contains("CommandLine"))
        XCTAssertFalse(helperSource.contains("Process("))
        XCTAssertFalse(helperSource.contains("swift-package"))
        let deadlineIndex = try XCTUnwrap(
            helperSource.range(
                of: "let deadline: PrimeSecureChildPhaseDeadline"
            )
        ).lowerBound
        let continuityIndex = try XCTUnwrap(
            helperSource.range(of: "try retainedState.revalidate()")
        ).lowerBound
        let journalIndex = try XCTUnwrap(
            helperSource.range(
                of:
                    "let journal = try PrimeValidationDriverV2CanaryJournal("
            )
        ).lowerBound
        let spawnIndex = try XCTUnwrap(
            helperSource.range(
                of: "PrimeSecureChildDarwinSubstrate.spawnSuspended("
            )
        ).lowerBound
        XCTAssertLessThan(deadlineIndex, continuityIndex)
        XCTAssertLessThan(continuityIndex, journalIndex)
        XCTAssertLessThan(journalIndex, spawnIndex)
        let manifest = try String(
            contentsOf: Fixture.nestedManifestURL,
            encoding: .utf8
        )
        let canaryTarget = try slice(
            manifest,
            from:
                ".executableTarget(\n            name: \"PrimeValidationWorkflowDriverV2SpawnCanary\"",
            through:
                "        .target(\n            name: \"PrimeValidationWorkflowDriverV2ShotGovernorCore\""
        )
        XCTAssertEqual(
            manifest.components(
                separatedBy:
                    ".executable(\n            name: \"PrimeValidationWorkflowDriverV2SpawnCanary\""
            ).count - 1,
            1
        )
        XCTAssertEqual(
            manifest.components(
                separatedBy:
                    ".executableTarget(\n            name: \"PrimeValidationWorkflowDriverV2SpawnCanary\""
            ).count - 1,
            1
        )
        XCTAssertFalse(canaryTarget.contains("dependencies:"))
        XCTAssertTrue(canaryTarget.contains("\"-Xlinker\", \"-S\""))
    }

    func testFixedRoleFacadeSourceHasOnlyClosedCanaryExecutionSurface()
        throws
    {
        var repositoryRoot = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 5 { repositoryRoot.deleteLastPathComponent() }
        var nestedRoot = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 3 { nestedRoot.deleteLastPathComponent() }
        let coreSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift"
            ),
            encoding: .utf8
        )
        let coreAdmissionSource = try String(
            contentsOf: Fixture.admissionSourceURL,
            encoding: .utf8
        )
        let driverBridgeSource = try String(
            contentsOf: nestedRoot.appendingPathComponent(
                "Sources/PrimeValidationWorkflowDriverCore/"
                    + "PrimeValidationDriverV2RoleBridge.swift"
            ),
            encoding: .utf8
        )
        let driverImageSource = try String(
            contentsOf: Fixture.supervisorBridgeSourceURL,
            encoding: .utf8
        )

        XCTAssertTrue(
            coreAdmissionSource.contains(
                "public func transferDriverV2RoleFacade(\n"
                    + "        context: PrimeValidationDriverV2RoleContext"
            )
        )
        XCTAssertTrue(
            coreAdmissionSource.contains(
                "func transferDriverV2RoleFacadeAllowingTestCanary("
            )
        )
        XCTAssertFalse(
            coreAdmissionSource.contains(
                "public func " +
                    "transferDriverV2RoleFacadeAllowingTestCanary("
            )
        )
        XCTAssertTrue(
            coreSource.contains(
                "make(role: .build, context: context, toolchain: toolchain),\n"
                    + "            make(role: .listXCTest, context: context, "
                    + "toolchain: toolchain),\n"
                    + "            make(role: .listSwiftTesting, context: "
                    + "context, toolchain: toolchain),"
            )
        )
        let facadeSource = try slice(
            coreSource,
            from: "public final class PrimeValidationDriverV2RoleFacade",
            through:
                "struct PrimeValidationDriverV2ClosedRolePolicy"
        )
        XCTAssertFalse(facadeSource.contains("public init("))
        XCTAssertFalse(facadeSource.contains("package init("))
        XCTAssertEqual(
            facadeSource.components(
                separatedBy: "public func revalidateContinuity() throws"
            ).count - 1,
            1
        )
        XCTAssertEqual(
            facadeSource.components(
                separatedBy: "func revalidateContinuity("
            ).count - 1,
            1
        )
        XCTAssertEqual(
            facadeSource.components(
                separatedBy:
                    "public func spawnIsolatedContainmentCanary() throws"
            ).count - 1,
            1
        )
        for forbidden in [
            "func execute",
            "func takeNextRole",
            "func nextRole",
            "func advance",
            "spawnSuspended",
            "PrimeSecureChildDarwinSubstrate",
            "PrimeSecureChildSupervisionCapability",
            "posix_spawn",
            "Process(",
            "fork(",
            "execve(",
            "import Darwin",
            "CommandLine",
            "restore(",
        ] {
            XCTAssertFalse(coreSource.contains(forbidden), forbidden)
        }

        XCTAssertEqual(
            driverImageSource.components(
                separatedBy: "package func consumeFixedRoleFacade()"
            ).count - 1,
            1
        )
        XCTAssertEqual(
            driverImageSource.components(
                separatedBy: ".roleContext(from: intent, terminalGate: terminalGate, executionGoScopeData: executionGoScopeData)"
            ).count - 1,
            1
        )
        XCTAssertTrue(
            driverImageSource.contains(
                "private let roleContext: PrimeValidationDriverV2RoleContext"
            )
        )
        let forwarding = try slice(
            driverImageSource,
            from: "package func consumeFixedRoleFacade()",
            through:
                "/// The only DriverCore transition that can close Gate A."
        )
        XCTAssertTrue(
            forwarding.contains(
                ".transferDriverV2RoleFacade(\n"
                    + "                context: roleContext\n"
                    + "            )"
            )
        )
        for forbidden in [
            "observation.",
            "fixedPolicyObservations",
            "positionedPolicy",
            "nextRoleIndex",
            "roleOrder",
            "execute(",
            "spawn",
            "Process(",
            "CommandLine",
            "FileManager",
        ] {
            XCTAssertFalse(forwarding.contains(forbidden), forbidden)
        }
        XCTAssertTrue(
            driverBridgeSource.contains(
                "package static func roleContext(\n"
                    + "        from intent: PrimeValidationRunIntentV2"
            )
        )
        for forbidden in [
            "class ",
            "NSLock",
            "var state",
            "nextRoleIndex",
            "observation",
            "execute(",
            "spawn",
            "Process(",
        ] {
            XCTAssertFalse(driverBridgeSource.contains(forbidden), forbidden)
        }
    }

    @available(macOS 26.0, *)
    private func testCanaryFacade(
        fixture: Fixture,
        interlock:
            PrimeValidationDriverV2IsolatedSpawnCanaryTestInterlock? = nil
    ) throws -> PrimeValidationDriverV2RoleFacade {
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        guard !image.productionSupervisorImageEligible else {
            throw FixtureError.invalid(
                "test_canary_production_image"
            )
        }
        let context = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        ).context
        let descriptor = try fixture.openPinnedSpawnCanaryExecutable()
        defer { _ = Darwin.close(descriptor) }
        return try image
            .transferDriverV2RoleFacadeAllowingTestCanary(
                context: context,
                heldCanaryExecutableDescriptor: descriptor,
                testInterlock: interlock
            )
    }

    @available(macOS 26.0, *)
    private func assertIsolatedSpawnCanaryMutationPoisons(
        mutate: (Fixture) throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let interlock =
            PrimeValidationDriverV2IsolatedSpawnCanaryTestInterlock()
        let facade = try testCanaryFacade(
            fixture: fixture,
            interlock: interlock
        )
        let race = DriverV2IsolatedSpawnCanaryRace()
        let done = DispatchGroup()
        done.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            race.record {
                try facade.spawnIsolatedContainmentCanary()
            }
            done.leave()
        }
        guard interlock.waitForDurableStartPublication() else {
            interlock.permitResume()
            _ = done.wait(timeout: .now() + .seconds(10))
            return XCTFail(
                "canary did not publish durable start",
                file: file,
                line: line
            )
        }
        do {
            try mutate(fixture)
        } catch {
            interlock.permitResume()
            _ = done.wait(timeout: .now() + .seconds(10))
            throw error
        }
        interlock.permitResume()
        XCTAssertEqual(
            done.wait(timeout: .now() + .seconds(10)),
            .success,
            file: file,
            line: line
        )
        XCTAssertEqual(race.successCount, 0, file: file, line: line)
        XCTAssertEqual(race.errors.count, 1, file: file, line: line)
        try assertCanaryPIDContained(
            try canaryStartProcessIdentifier(fixture: fixture),
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.isolatedSpawnCanaryState,
            .poisoned,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.continuityState,
            .poisoned,
            file: file,
            line: line
        )
        XCTAssertNil(
            facade.isolatedSpawnCanaryObservation,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.combinedSourceWatcherDescriptorCount,
            0,
            file: file,
            line: line
        )
        XCTAssertThrowsError(
            try facade.spawnIsolatedContainmentCanary(),
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned,
                file: file,
                line: line
            )
        }
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.canaryJournal.path
            ),
            ["v2-spawn-01-start.json"],
            file: file,
            line: line
        )
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.workspace.path
            ),
            [],
            file: file,
            line: line
        )
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.evidence.path
            ),
            [],
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.processExecutionObservation,
            .unobserved,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.buildExecutionObservation,
            .unobserved,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.inventoryExecutionObservation,
            .unobserved,
            file: file,
            line: line
        )
        XCTAssertFalse(
            facade.completionAuthorized,
            file: file,
            line: line
        )
    }

    private func canaryStartProcessIdentifier(
        fixture: Fixture
    ) throws -> Int32 {
        let data = try Data(
            contentsOf: fixture.canaryJournal.appendingPathComponent(
                "v2-spawn-01-start.json"
            )
        )
        guard let object = try JSONSerialization.jsonObject(with: data)
                as? [String: Any],
              let number = object["process_identifier"] as? NSNumber,
              number.int64Value > 0,
              number.int64Value <= Int64(Int32.max)
        else {
            throw FixtureError.invalid("canary_start_pid")
        }
        return number.int32Value
    }

    private func assertCanaryPIDContained(
        _ processIdentifier: Int32,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        var status: Int32 = 0
        errno = 0
        XCTAssertEqual(
            waitpid(processIdentifier, &status, WNOHANG),
            -1,
            file: file,
            line: line
        )
        XCTAssertEqual(errno, ECHILD, file: file, line: line)
        errno = 0
        XCTAssertEqual(
            Darwin.kill(-processIdentifier, 0),
            -1,
            file: file,
            line: line
        )
        XCTAssertEqual(errno, ESRCH, file: file, line: line)
    }

    @available(macOS 26.0, *)
    private func preparedGuard(
        for fixture: Fixture
    ) throws -> PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor {
        try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
    }

    @available(macOS 26.0, *)
    private func boundTestImage(
        for guarded:
            PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor
    ) throws -> PrimeValidationSwiftPMDriverV2SupervisorImageCapability {
        try guarded.bindDriverV2SupervisorImageAllowingTestHost(
            expecting: try expectation(for: guarded)
        )
    }

    private func roleTransferInputs(
        fixture: Fixture,
        guarded:
            PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor
    ) throws -> (
        intent: PrimeValidationRunIntentV2,
        context: PrimeValidationDriverV2RoleContext
    ) {
        let imageData = try Data(
            contentsOf: URL(
                fileURLWithPath:
                    guarded.currentProcessExecutable.canonicalAbsolutePath
            )
        )
        let intent = try fixture.makeIntent(
            guarded: guarded,
            driverImageData: imageData
        )
        return (
            intent,
            try PrimeValidationDriverV2RoleBridge.roleContext(from: intent)
        )
    }

    private func copyRoleContext(
        _ context: PrimeValidationDriverV2RoleContext,
        repositoryRoot:
            PrimeValidationDriverV2RoleRootContext? = nil,
        scratchAbsolutePath: String? = nil
    ) -> PrimeValidationDriverV2RoleContext {
        PrimeValidationDriverV2RoleContext(
            repositoryRoot: repositoryRoot ?? context.repositoryRoot,
            companionRoot: context.companionRoot,
            workspaceRoot: context.workspaceRoot,
            evidenceRoot: context.evidenceRoot,
            scratchAbsolutePath:
                scratchAbsolutePath ?? context.scratchAbsolutePath,
            cacheAbsolutePath: context.cacheAbsolutePath,
            configAbsolutePath: context.configAbsolutePath,
            securityAbsolutePath: context.securityAbsolutePath,
            clangModuleCacheAbsolutePath:
                context.clangModuleCacheAbsolutePath,
            outputAbsolutePath: context.outputAbsolutePath,
            homeAbsolutePath: context.homeAbsolutePath,
            swiftPMModuleCacheAbsolutePath:
                context.swiftPMModuleCacheAbsolutePath,
            temporaryAbsolutePath: context.temporaryAbsolutePath,
            requiredPinnedMetallibAbsolutePath:
                context.requiredPinnedMetallibAbsolutePath
        )
    }

    private func copyIntent(
        _ intent: PrimeValidationRunIntentV2,
        phaseBudgets: [PrimeValidationPhaseBudgetV2]
    ) -> PrimeValidationRunIntentV2 {
        PrimeValidationRunIntentV2(
            runID: intent.runID,
            authority: intent.authority,
            roots: intent.roots,
            sourceSnapshot: intent.sourceSnapshot,
            packageLock: intent.packageLock,
            driverExecutable: intent.driverExecutable,
            swiftExecutable: intent.swiftExecutable,
            companionCommit: intent.companionCommit,
            requiredPinnedMetallib: intent.requiredPinnedMetallib,
            baseline: intent.baseline,
            build: intent.build,
            shardPolicy: intent.shardPolicy,
            phaseBudgets: phaseBudgets,
            resumePolicy: intent.resumePolicy,
            environmentPolicy: intent.environmentPolicy,
            optionalSkipPolicySHA256: intent.optionalSkipPolicySHA256
        )
    }

    func testConcurrentConsumeHasExactlyOneWinner() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capability = try fixture.admit()
        let race = ConsumeRace()
        let ready = DispatchGroup()
        let done = DispatchGroup()
        let start = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(
            label: "prime.validation.admission.consume-race",
            attributes: .concurrent
        )

        for _ in 0 ..< 2 {
            ready.enter()
            done.enter()
            queue.async {
                ready.leave()
                start.wait()
                race.record {
                    try capability.consumePrerequisites()
                }
                done.leave()
            }
        }
        XCTAssertEqual(ready.wait(timeout: .now() + 5), .success)
        start.signal()
        start.signal()
        XCTAssertEqual(done.wait(timeout: .now() + 30), .success)

        XCTAssertEqual(race.prerequisites.count, 1)
        XCTAssertEqual(race.errors.count, 1)
        XCTAssertEqual(
            race.errors.first as?
                PrimeValidationSwiftPMBuildInventoryAdmissionError,
            .capabilityAlreadyConsumed
        )
        assertLeaseBusy(fixture.lockURL)
        race.releasePrerequisites()
    }

    func testCanonicalAliasAndAncestorOverlapAreRejected() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let alias = URL(
            fileURLWithPath:
                fixture.workspace.path.replacingOccurrences(
                    of: "/private/tmp/",
                    with: "/tmp/"
                ),
            isDirectory: true
        )
        XCTAssertThrowsError(
            try fixture.admit(workspace: alias)
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite,
                .workspaceRoot
            )
        }

        let parent = try fixture.makeDirectory("overlap-parent")
        let child = try fixture.makeDirectory(
            "overlap-parent/workspace"
        )
        XCTAssertThrowsError(
            try fixture.admit(
                workspace: child,
                companion: parent
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite,
                .rootTopology
            )
        }
    }

    func testSymlinkLooseModeAndNonemptyRootsAreRejected() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }

        let target = try fixture.makeDirectory("symlink-target")
        let linked = fixture.base.appendingPathComponent(
            "linked-workspace"
        )
        try FileManager.default.createSymbolicLink(
            at: linked,
            withDestinationURL: target
        )
        XCTAssertThrowsError(try fixture.admit(workspace: linked))

        let loose = try fixture.makeDirectory("loose-workspace")
        XCTAssertEqual(chmod(loose.path, 0o755), 0)
        XCTAssertThrowsError(try fixture.admit(workspace: loose))

        let nonempty = try fixture.makeDirectory("nonempty-workspace")
        try Data("prior-run".utf8).write(
            to: nonempty.appendingPathComponent("prior")
        )
        XCTAssertThrowsError(try fixture.admit(workspace: nonempty))
    }

    func testPostAdmissionCompanionMutationPoisonsCapability()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capability = try fixture.admit()
        try Data("mutation\n".utf8).write(
            to: fixture.companion.appendingPathComponent(
                "Sources/Companion.swift"
            )
        )

        XCTAssertThrowsError(try capability.consumePrerequisites()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .rejected("companion_content_replay")
            )
        }
        XCTAssertThrowsError(try capability.consumePrerequisites()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .capabilityAlreadyConsumed
            )
        }
    }

    func testPostAdmissionPrimeByteRestorationCannotRebaselineBeforeWatch()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let prerequisite = try fixture.admit().consumePrerequisites()
        let readme = fixture.prime.appendingPathComponent("README.md")
        let admitted = try Data(contentsOf: readme)
        try Data("mutated before Prime watch\n".utf8).write(to: readme)
        try admitted.write(to: readme)

        XCTAssertThrowsError(
            try prerequisite.prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .rejected("prime_source_identity_replay")
            )
        }
        XCTAssertThrowsError(
            try prerequisite.prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .prerequisiteAlreadyConsumed
            )
        }
    }

    func testPostAdmissionCompanionSameBytesNewInodeCannotRebaseline()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let prerequisite = try fixture.admit().consumePrerequisites()
        let original = fixture.companion.appendingPathComponent(
            "Sources/Companion.swift"
        )
        let saved = fixture.base.appendingPathComponent(
            "Companion.original"
        )
        let bytes = try Data(contentsOf: original)
        try FileManager.default.moveItem(at: original, to: saved)
        try bytes.write(to: original)
        var savedStatus = stat()
        var replacementStatus = stat()
        XCTAssertEqual(lstat(saved.path, &savedStatus), 0)
        XCTAssertEqual(lstat(original.path, &replacementStatus), 0)
        XCTAssertNotEqual(savedStatus.st_ino, replacementStatus.st_ino)

        XCTAssertThrowsError(
            try prerequisite.prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .rejected("companion_content_replay")
            )
        }
        XCTAssertThrowsError(
            try prerequisite.prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .prerequisiteAlreadyConsumed
            )
        }
    }

    func testPostAdmissionTransientCompanionMutationCannotRebaseline()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capability = try fixture.admit()
        let transient = fixture.companion.appendingPathComponent(
            "Empty/transient-before-watch"
        )
        try Data("transient\n".utf8).write(to: transient)
        try FileManager.default.removeItem(at: transient)

        XCTAssertThrowsError(try capability.consumePrerequisites()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .rejected("companion_content_replay")
            )
        }
        XCTAssertThrowsError(try capability.consumePrerequisites()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .capabilityAlreadyConsumed
            )
        }
    }

    func testCompanionCompleteTopologyAllowsNoFilesAndHoldsEmptyDirectory()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let minimal = try fixture.makeDirectory("minimal-companion")
        try makePrivateDirectory(
            minimal.appendingPathComponent(".git", isDirectory: true)
        )
        try makePrivateDirectory(
            minimal.appendingPathComponent("Empty", isDirectory: true)
        )

        let guarded = try fixture.admit(companion: minimal)
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        try guarded.revalidateGuards()
        XCTAssertTrue(guarded.companionSourceDescriptorClosureHeld)
        XCTAssertTrue(guarded.companionSourceWatchWindowArmed)
        XCTAssertEqual(guarded.combinedSourceWatcherDescriptorCount, 35)
    }

    func testCompanionAdmissionSnapshotCarriesCompleteVnodeTopology()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let ignoredGitDescendant = fixture.companion.appendingPathComponent(
            ".git/HEAD"
        )
        try Data("ref: refs/heads/main\n".utf8).write(
            to: ignoredGitDescendant
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: ignoredGitDescendant.path
            )
        )
        let descriptor = open(
            fixture.companion.path,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard descriptor >= 3 else {
            throw FixtureError.invalid("companion_snapshot_open_\(errno)")
        }
        defer { _ = Darwin.close(descriptor) }
        let snapshot = try PrimeSecureHeldWorkingTreeSnapshot.capture(
            rootDescriptor: descriptor
        )

        XCTAssertEqual(
            Set(snapshot.directoryRelativePaths),
            Set(["", ".hidden", "Empty", "Sources"])
        )
        XCTAssertEqual(
            Set(snapshot.directoryIdentities.keys),
            Set(snapshot.directoryRelativePaths)
        )
        XCTAssertEqual(
            Set(snapshot.files.map(\.relativePath)),
            Set([
                ".gitignore",
                ".hidden/config",
                "Package.swift",
                "Sources/Companion.swift",
            ])
        )
        XCTAssertEqual(
            Set(snapshot.fileIdentities.keys),
            Set(snapshot.files.map(\.relativePath))
        )

        var emptyStatus = stat()
        XCTAssertEqual(
            lstat(
                fixture.companion.appendingPathComponent("Empty").path,
                &emptyStatus
            ),
            0
        )
        XCTAssertEqual(
            snapshot.directoryIdentities["Empty"]?.deviceID,
            Int32(emptyStatus.st_dev)
        )
        XCTAssertEqual(
            snapshot.directoryIdentities["Empty"]?.inode,
            UInt64(emptyStatus.st_ino)
        )

        var fileStatus = stat()
        XCTAssertEqual(
            lstat(
                fixture.companion.appendingPathComponent(
                    "Sources/Companion.swift"
                ).path,
                &fileStatus
            ),
            0
        )
        XCTAssertEqual(
            snapshot.fileIdentities["Sources/Companion.swift"]?.deviceID,
            Int32(fileStatus.st_dev)
        )
        XCTAssertEqual(
            snapshot.fileIdentities["Sources/Companion.swift"]?.inode,
            UInt64(fileStatus.st_ino)
        )

        var gitStatus = stat()
        XCTAssertEqual(
            lstat(
                fixture.companion.appendingPathComponent(".git").path,
                &gitStatus
            ),
            0
        )
        XCTAssertEqual(
            snapshot.excludedRootGitDirectoryDeviceID,
            Int32(gitStatus.st_dev)
        )
        XCTAssertEqual(
            snapshot.excludedRootGitDirectoryInode,
            UInt64(gitStatus.st_ino)
        )
        XCTAssertFalse(
            snapshot.directoryRelativePaths.contains(where: {
                $0 == ".git" || $0.hasPrefix(".git/")
            })
        )
        XCTAssertFalse(
            snapshot.files.contains(where: {
                $0.relativePath == ".git"
                    || $0.relativePath.hasPrefix(".git/")
            })
        )
        XCTAssertEqual(snapshot.identitySHA256.count, 64)
    }

    func testCompanionCaptureRejectsSymlinkFIFORootGitFile()
        throws
    {
        try ["symlink", "fifo", "root_git_file"].forEach { mutation in
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            switch mutation {
            case "symlink":
                try FileManager.default.createSymbolicLink(
                    at: fixture.companion.appendingPathComponent("linked"),
                    withDestinationURL:
                        fixture.companion.appendingPathComponent(".gitignore")
                )
            case "fifo":
                let path = fixture.companion.appendingPathComponent("fifo")
                guard mkfifo(path.path, 0o600) == 0 else {
                    throw FixtureError.invalid("mkfifo_\(errno)")
                }
            case "root_git_file":
                let git = fixture.companion.appendingPathComponent(
                    ".git",
                    isDirectory: true
                )
                try FileManager.default.removeItem(at: git)
                try Data("gitdir: elsewhere\n".utf8).write(to: git)
            default:
                throw FixtureError.invalid("unknown_mutation")
            }

            XCTAssertThrowsError(try fixture.admit(), mutation) { error in
                XCTAssertEqual(
                    error as?
                        PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite,
                    .companionContentSnapshot,
                    mutation
                )
            }
        }
    }

    func testCompanionTopologyLimitsAreFrozenAndRejectDepthAndFileBytes()
        throws
    {
        XCTAssertEqual(
            PrimeSecureHeldWorkingTreeSnapshot.maximumFileCount,
            4_096
        )
        XCTAssertEqual(
            PrimeSecureHeldWorkingTreeSnapshot.maximumDirectoryCount,
            4_096
        )
        XCTAssertEqual(
            PrimeSecureHeldWorkingTreeSnapshot.maximumFileByteCount,
            64 * 1024 * 1024
        )
        XCTAssertEqual(
            PrimeSecureHeldWorkingTreeSnapshot.maximumAggregateByteCount,
            512 * 1024 * 1024
        )
        XCTAssertEqual(
            PrimeSecureHeldWorkingTreeSnapshot.maximumRelativeDepth,
            32
        )
        XCTAssertEqual(
            PrimeSecureHeldWorkingTreeSnapshot.maximumDirectoryEntryCount,
            16_384
        )
        XCTAssertEqual(
            PrimeSecureHeldWorkingTreeSnapshot
                .maximumAggregateDirectoryEntryCount,
            65_536
        )
        XCTAssertEqual(
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
                .maximumCombinedSourceWatcherDescriptorCount,
            4_096
        )

        let deepFixture = try Fixture()
        defer { deepFixture.cleanup() }
        let tooDeep = (1 ... 33).map { "d\($0)" }.joined(separator: "/")
        try FileManager.default.createDirectory(
            at: deepFixture.companion.appendingPathComponent(
                tooDeep,
                isDirectory: true
            ),
            withIntermediateDirectories: true
        )
        XCTAssertThrowsError(try deepFixture.admit()) { error in
            XCTAssertEqual(
                error as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite,
                .companionContentSnapshot
            )
        }

        let largeFixture = try Fixture()
        defer { largeFixture.cleanup() }
        let oversized = largeFixture.companion.appendingPathComponent(
            "oversized"
        )
        let descriptor = open(
            oversized.path,
            O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC,
            0o600
        )
        guard descriptor >= 3 else {
            throw FixtureError.invalid("oversized_open_\(errno)")
        }
        defer { _ = Darwin.close(descriptor) }
        guard ftruncate(descriptor, 64 * 1024 * 1024 + 1) == 0 else {
            throw FixtureError.invalid("oversized_truncate_\(errno)")
        }
        XCTAssertThrowsError(try largeFixture.admit()) { error in
            XCTAssertEqual(
                error as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite,
                .companionContentSnapshot
            )
        }
    }

    func testCallerDeclaredGitMismatchIsRejectedBeforeAdmission()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let mismatched = PrimeValidationSwiftPMCompanionDeclaration(
            expectedPinnedHEAD: Fixture.commit,
            declaredObservedHEAD: String(repeating: "b", count: 40),
            declaredPorcelainV2Status: Data()
        )
        XCTAssertThrowsError(
            try fixture.admit(declaration: mismatched)
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite,
                .companionDeclaration
            )
        }
    }

    func testCapabilitySurfaceHasNoCodecPublicInitializerOrSpawn()
        throws
    {
        let source = try String(
            contentsOf: Fixture.admissionSourceURL,
            encoding: .utf8
        )
        for forbidden in [
            "posix_spawn",
            "Process(",
            "fork(",
            "execve(",
            "/usr/bin/swift",
        ] {
            XCTAssertFalse(source.contains(forbidden), forbidden)
        }

        let rejectionSiteSource = try slice(
            source,
            from:
                "@frozen\npublic enum PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite",
            through:
                "extension PrimeValidationSwiftPMBuildInventoryAdmissionError"
        )
        XCTAssertTrue(rejectionSiteSource.contains("Error,"))
        XCTAssertTrue(rejectionSiteSource.contains("Equatable,"))
        XCTAssertTrue(rejectionSiteSource.contains("Sendable"))
        XCTAssertEqual(
            rejectionSiteSource.components(separatedBy: "    case ")
                .count - 1,
            17
        )
        let rejectionSiteNames = [
            "companionDeclaration",
            "primeRepository",
            "workspaceRoot",
            "workspacePrivateAndEmpty",
            "evidenceRoot",
            "evidencePrivateAndEmpty",
            "companionRepository",
            "leaseDirectory",
            "leasePrivateAndEmpty",
            "rootTopology",
            "exclusiveLease",
            "postLeaseDirectory",
            "sourceSnapshot",
            "packageResolvedBinding",
            "primeSourceIdentitySnapshot",
            "companionContentSnapshot",
            "heldToolchain",
        ]
        let rejectionSiteCaseLines = rejectionSiteSource
            .split(separator: "\n")
            .map {
                String($0).trimmingCharacters(in: .whitespaces)
            }
            .filter { $0.hasPrefix("case ") }
        XCTAssertEqual(
            rejectionSiteCaseLines,
            rejectionSiteNames.map { "case \($0)" }
        )
        var rejectionSiteCursor = rejectionSiteSource.startIndex
        for siteName in rejectionSiteNames {
            let range = try XCTUnwrap(
                rejectionSiteSource.range(
                    of: "case \(siteName)",
                    range:
                        rejectionSiteCursor ..< rejectionSiteSource.endIndex
                )
            )
            rejectionSiteCursor = range.upperBound
        }
        for forbidden in [
            "Codable",
            "RawRepresentable",
            "rawValue",
            "String",
            "Int32",
            "URL",
            "Data",
            "public init(",
        ] {
            XCTAssertFalse(rejectionSiteSource.contains(forbidden), forbidden)
        }
        XCTAssertEqual(
            source.components(
                separatedBy: "public static func admitPrerequisites("
            ).count - 1,
            1
        )
        XCTAssertEqual(
            source.components(
                separatedBy: "static func admitPrerequisites("
            ).count - 1,
            2
        )
        XCTAssertFalse(source.contains("observationEnabled"))
        XCTAssertFalse(source.contains("observeAdmission"))

        let rejectionHelperSource = try slice(
            source,
            from: "private static func atRejectionSite<Value>(",
            through: "    /// Admits only live prerequisites."
        )
        let normalizedRejectionHelper = rejectionHelperSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        XCTAssertEqual(
            normalizedRejectionHelper,
            "private static func atRejectionSite<Value>( " +
                "_ site: " +
                "PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite, " +
                "_ operation: () throws -> Value ) throws -> Value " +
                "{ do { return try operation() } catch { throw site } }"
        )

        let admissionBodySource = try slice(
            source,
            from:
                "    /// Internal only: permits isolated tests to seal a synthetic complete",
            through:
                "    private static func validateCompanionDeclaration("
        )
        let normalizedAdmissionBody = admissionBodySource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
            .replacingOccurrences(of: "( ", with: "(")
            .replacingOccurrences(of: " )", with: ")")
        XCTAssertEqual(
            normalizedAdmissionBody.components(
                separatedBy: "atRejectionSite("
            ).count - 1,
            17
        )
        var admissionSiteCursor = normalizedAdmissionBody.startIndex
        for siteName in rejectionSiteNames {
            let range = try XCTUnwrap(
                normalizedAdmissionBody.range(
                    of: "atRejectionSite(.\(siteName))",
                    range:
                        admissionSiteCursor ..< normalizedAdmissionBody.endIndex
                )
            )
            admissionSiteCursor = range.upperBound
        }
        let admissionOperationAnchors: [(String, [String])] = [
            (
                "companionDeclaration",
                ["validateCompanionDeclaration(companionDeclaration)"]
            ),
            (
                "primeRepository",
                [
                    "PrimeValidationSwiftPMHeldUserDirectory(",
                    "url: primeRepositoryURL",
                ]
            ),
            (
                "workspaceRoot",
                [
                    "PrimeValidationSwiftPMHeldUserDirectory(",
                    "url: workspaceRootURL",
                ]
            ),
            (
                "workspacePrivateAndEmpty",
                ["workspaceRoot.requirePrivateAndEmpty()"]
            ),
            (
                "evidenceRoot",
                [
                    "PrimeValidationSwiftPMHeldUserDirectory(",
                    "url: evidenceRootURL",
                ]
            ),
            (
                "evidencePrivateAndEmpty",
                ["evidenceRoot.requirePrivateAndEmpty()"]
            ),
            (
                "companionRepository",
                [
                    "PrimeValidationSwiftPMHeldUserDirectory(",
                    "url: companionRepositoryURL",
                ]
            ),
            (
                "leaseDirectory",
                [
                    "PrimeValidationSwiftPMHeldUserDirectory(",
                    "url: leaseDirectoryURL",
                ]
            ),
            (
                "leasePrivateAndEmpty",
                ["initialLeaseDirectory.requirePrivateAndEmpty()"]
            ),
            (
                "rootTopology",
                [
                    "requireDisjointAndNonNested([",
                    "initialLeaseDirectory.observation",
                ]
            ),
            (
                "exclusiveLease",
                ["PrimeMetalDeviceLease.acquire(at: leaseURL)"]
            ),
            (
                "postLeaseDirectory",
                [
                    "PrimeValidationSwiftPMHeldUserDirectory(",
                    "url: leaseDirectoryURL",
                ]
            ),
            (
                "sourceSnapshot",
                [
                    "if let sourceExpectation",
                    "PrimeSwiftSourceProvenance.capture(",
                    "expectation: sourceExpectation",
                ]
            ),
            (
                "packageResolvedBinding",
                [
                    "sourceSnapshot.files.first(where:",
                    "binding.validateDeclaration()",
                ]
            ),
            (
                "primeSourceIdentitySnapshot",
                ["captureLegacyPrimeSourceIdentity("]
            ),
            (
                "companionContentSnapshot",
                ["PrimeSecureHeldWorkingTreeSnapshot.capture("]
            ),
            (
                "heldToolchain",
                ["PrimeValidationSwiftPMHeldToolchain("]
            ),
        ]
        XCTAssertEqual(
            admissionOperationAnchors.map { $0.0 },
            rejectionSiteNames
        )
        for index in admissionOperationAnchors.indices {
            let siteName = admissionOperationAnchors[index].0
            let start = try XCTUnwrap(
                normalizedAdmissionBody.range(
                    of: "atRejectionSite(.\(siteName))"
                )
            ).lowerBound
            let end: String.Index
            if index + 1 < admissionOperationAnchors.count {
                let nextSiteName = admissionOperationAnchors[index + 1].0
                end = try XCTUnwrap(
                    normalizedAdmissionBody.range(
                        of: "atRejectionSite(.\(nextSiteName))",
                        range: start ..< normalizedAdmissionBody.endIndex
                    )
                ).lowerBound
            } else {
                end = normalizedAdmissionBody.endIndex
            }
            let segment = normalizedAdmissionBody[start ..< end]
            for anchor in admissionOperationAnchors[index].1 {
                XCTAssertTrue(segment.contains(anchor), "\(siteName):\(anchor)")
            }
        }

        let capabilitySource = try slice(
            source,
            from:
                "public final class PrimeValidationSwiftPMBuildInventoryAdmissionCapability",
            through:
                "public enum PrimeValidationSwiftPMBuildInventoryAdmission"
        )
        XCTAssertFalse(capabilitySource.contains(": Codable"))
        XCTAssertFalse(capabilitySource.contains("public init("))
        XCTAssertFalse(capabilitySource.contains("arguments:"))
        XCTAssertFalse(capabilitySource.contains("environment:"))

        let prerequisiteSource = try slice(
            source,
            from:
                "public final class PrimeValidationSwiftPMBuildInventoryPrerequisite",
            through:
                "/// Live input guards for a future fixed-role executor."
        )
        XCTAssertFalse(prerequisiteSource.contains(": Codable"))
        XCTAssertFalse(prerequisiteSource.contains("public init("))

        let guardedSource = try slice(
            source,
            from:
                "public final class PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor",
            through:
                "private enum PrimeValidationSwiftPMDriverV2SupervisorRole"
        )
        XCTAssertFalse(guardedSource.contains(": Codable"))
        XCTAssertFalse(guardedSource.contains("public init("))
        XCTAssertFalse(guardedSource.contains("arguments:"))
        XCTAssertFalse(guardedSource.contains("environment:"))
        XCTAssertFalse(guardedSource.contains("posix_spawn"))
        XCTAssertFalse(guardedSource.contains("Process("))
        XCTAssertFalse(guardedSource.contains("createDirectory"))

        let imageCapabilitySource = try slice(
            source,
            from:
                "public final class PrimeValidationSwiftPMDriverV2SupervisorImageCapability",
            through:
                "/// A single-use live capability for inputs needed by a future SwiftPM"
        )
        XCTAssertFalse(imageCapabilitySource.contains(": Codable"))
        XCTAssertFalse(imageCapabilitySource.contains("public init("))
        XCTAssertFalse(imageCapabilitySource.contains("arguments:"))
        XCTAssertFalse(imageCapabilitySource.contains("environment:"))
        XCTAssertFalse(imageCapabilitySource.contains("posix_spawn"))
        XCTAssertFalse(imageCapabilitySource.contains("Process("))
        XCTAssertFalse(imageCapabilitySource.contains("restore("))
        XCTAssertFalse(imageCapabilitySource.contains("execute("))

        let bridgeSource = try String(
            contentsOf: Fixture.supervisorBridgeSourceURL,
            encoding: .utf8
        )
        let liveBridgeSource = try slice(
            bridgeSource,
            from:
                "package final class PrimeValidationDriverV2SupervisorImageCapability",
            through:
                "/// The only DriverCore transition that can close Gate A."
        )
        XCTAssertFalse(liveBridgeSource.contains(": Codable"))
        XCTAssertFalse(liveBridgeSource.contains("public init("))
        XCTAssertFalse(liveBridgeSource.contains("restore("))
        XCTAssertFalse(liveBridgeSource.contains("Process("))
        XCTAssertFalse(liveBridgeSource.contains("posix_spawn"))
        XCTAssertFalse(liveBridgeSource.contains("arguments:"))
        XCTAssertFalse(liveBridgeSource.contains("environment:"))
        XCTAssertTrue(
            liveBridgeSource.contains(".driverExecutableOnly")
        )
        XCTAssertFalse(liveBridgeSource.contains("intentSHA256"))
        XCTAssertFalse(liveBridgeSource.contains("runID"))

        let supervisorSource = try String(
            contentsOf: Fixture.supervisorSourceURL,
            encoding: .utf8
        )
        for forbidden in [
            "ProcessInfo",
            ".environment",
            "dropFirst",
            "posix_spawn",
            "Process(",
            "fork(",
            "execve(",
            "createDirectory",
            "FileManager",
            ".github",
        ] {
            XCTAssertFalse(
                supervisorSource.contains(forbidden),
                forbidden
            )
        }
        XCTAssertTrue(
            supervisorSource.contains(
                "guard CommandLine.arguments.count == 1"
            )
        )
        XCTAssertTrue(
            supervisorSource.contains("STDIN_FILENO")
        )
        XCTAssertTrue(
            supervisorSource.contains("CLOCK_MONOTONIC_RAW")
        )
        XCTAssertTrue(
            supervisorSource.contains(
                "requestReadTimeoutNanoseconds"
            )
        )
        XCTAssertFalse(supervisorSource.contains("STDOUT_FILENO"))
        XCTAssertFalse(supervisorSource.contains("STDERR_FILENO"))

        let manifest = try String(
            contentsOf: Fixture.nestedManifestURL,
            encoding: .utf8
        )
        let target = try slice(
            manifest,
            from:
                ".executableTarget(\n            name: \"PrimeValidationWorkflowDriverV2Supervisor\"",
            through:
                "        .executableTarget(\n            name: \"PrimeValidationWorkflowDriverV2SpawnCanary\""
        )
        XCTAssertTrue(
            target.contains("PrimeValidationWorkflowDriverCore")
        )
        XCTAssertFalse(
            target.contains("PrimeValidationWorkflowFixtureChild")
        )
        XCTAssertFalse(
            target.contains(
                "PrimeValidationWorkflowSecureChildIntegration"
            )
        )
        XCTAssertEqual(PrimeValidationBaselineAnchorV2.xctestCount, 892)
        XCTAssertEqual(
            PrimeValidationBaselineAnchorV2.swiftTestingCount,
            12
        )
    }

    @available(macOS 26.0, *)
    func testGateEJournalChainOneWinnerAndPoisonAreExact() throws {
        let executor = try gateEProductionSource(
            "Sources/PrimeCore/" +
                "PrimeValidationDriverV2FixedProbeExecutor.swift"
        )
        let governor = try gateEProductionSource(
            "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverV2ShotGovernorCore/" +
                "PrimeValidationDriverV2ShotGovernor.swift"
        )
        let governorMain = try gateEProductionSource(
            "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverV2ShotGovernor/main.swift"
        )
        let liveTestsSource = try String(
            contentsOf: URL(fileURLWithPath: #filePath),
            encoding: .utf8
        )
        let selectedTestIdentifier =
            "func testGateEJournalChain" +
            "OneWinnerAndPoisonAreExact() throws"
        XCTAssertEqual(
            liveTestsSource.components(
                separatedBy: selectedTestIdentifier
            ).count - 1,
            1
        )
        let expectedLeaves = gateEExpectedJournalLeaves()
        XCTAssertEqual(expectedLeaves.count, 34)
        XCTAssertEqual(Set(expectedLeaves).count, 34)
        for required in [
            "O_EXCL | O_NOFOLLOW | O_CLOEXEC",
            "data.append(0x0a)",
            "fchmod(opened, mode_t(0o400))",
            "current.linkCount == UInt64(2 + leaves.count)",
            "leaf == Self.allowedLeaves[leaves.count]",
            "preResumeContinuityCheckpointUptimeNanoseconds:",
            "gate-e-raw-terminal.json",
        ] {
            XCTAssertTrue(executor.contains(required), required)
        }
        let resumeOrder = [
            "let startPublishedAt = try clock.observeCompletion(",
            "let preResumeContinuityCheckpointUptimeNanoseconds = try\n" +
                "                lightweightCheckpoint(",
            "switch try supervision.resume(",
            "notBeforeUptimeNanoseconds:\n" +
                "                    " +
                "preResumeContinuityCheckpointUptimeNanoseconds",
        ]
        let resumeOrderPositions = resumeOrder.compactMap {
            executor.range(of: $0)?.lowerBound
        }
        XCTAssertEqual(resumeOrderPositions.count, resumeOrder.count)
        XCTAssertEqual(
            resumeOrderPositions,
            resumeOrderPositions.sorted()
        )

        let causalFixtureBytes = try PrimeValidationDriverV2ShotGovernor
            .sessionFixtureCausalFailStopV2CanonicalFixtureForTesting()
        let expectedCausalJSON = [
            "{\"admittedDeviceID\":1",
            ",\"admittedInode\":2",
            ",\"containmentState\":\"armed\"",
            ",\"containmentStopAttemptSequence\":1",
            ",\"containmentStopDeathEventCheckPerformed\":false",
            ",\"containmentStopDeathEventObserved\":false",
            ",\"containmentStopErrno\":1",
            ",\"containmentStopReturn\":-1",
            ",\"deadlineExpired\":false",
            ",\"deathEventObservedAtContainmentFailure\":true",
            ",\"deathWaitReturned\":true",
            ",\"executionPhase\":\"orphan_initial_census\"",
            ",\"failureCoordinate\":\"supervisor_stop\"",
            ",\"failureStatus\":70",
            ",\"fixedFailStopStatus\":70",
            ",\"fixtureMode\":\"orphan_transition\"",
            ",\"initiatingFailureCoordinate\":" +
                "\"session_census_nonconvergent_query\"",
            ",\"initiatingFailureStatus\":70",
            ",\"schema\":" +
                "\"prime_driver_v2_session_fixture_fail_stop_v2\"",
            ",\"sourceIdentitySHA256\":\"" +
                PrimeEmbeddedBuildProvenance.sourceIdentitySHA256 +
                "\"}",
        ].joined()
        let expectedCausalBytes = Data(expectedCausalJSON.utf8)
        XCTAssertEqual(causalFixtureBytes, expectedCausalBytes)
        XCTAssertFalse(causalFixtureBytes.isEmpty)
        XCTAssertEqual(causalFixtureBytes.count, 738)
        XCTAssertLessThanOrEqual(causalFixtureBytes.count, 1_024)
        XCTAssertNotEqual(causalFixtureBytes.last, 0x0a)
        let causalFixture = try PrimeCanonicalJSON.decode(
            GateESessionFixtureCausalFailStopV2Record.self,
            from: causalFixtureBytes
        )
        XCTAssertEqual(
            try PrimeCanonicalJSON.encode(causalFixture),
            causalFixtureBytes
        )
        let causalObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: causalFixtureBytes)
                as? [String: Any]
        )
        XCTAssertEqual(
            Set(causalObject.keys),
            Set([
                "admittedDeviceID",
                "admittedInode",
                "containmentState",
                "containmentStopAttemptSequence",
                "containmentStopDeathEventCheckPerformed",
                "containmentStopDeathEventObserved",
                "containmentStopErrno",
                "containmentStopReturn",
                "deadlineExpired",
                "deathEventObservedAtContainmentFailure",
                "deathWaitReturned",
                "executionPhase",
                "failureCoordinate",
                "failureStatus",
                "fixedFailStopStatus",
                "fixtureMode",
                "initiatingFailureCoordinate",
                "initiatingFailureStatus",
                "schema",
                "sourceIdentitySHA256",
            ])
        )
        XCTAssertEqual(causalObject.count, 20)
        XCTAssertEqual(causalFixture.admittedDeviceID, 1)
        XCTAssertEqual(causalFixture.admittedInode, 2)
        XCTAssertEqual(causalFixture.containmentState, "armed")
        XCTAssertEqual(causalFixture.containmentStopAttemptSequence, 1)
        XCTAssertFalse(
            causalFixture.containmentStopDeathEventCheckPerformed
        )
        XCTAssertFalse(causalFixture.containmentStopDeathEventObserved)
        XCTAssertEqual(causalFixture.containmentStopErrno, 1)
        XCTAssertEqual(causalFixture.containmentStopReturn, -1)
        XCTAssertFalse(causalFixture.deadlineExpired)
        XCTAssertTrue(
            causalFixture.deathEventObservedAtContainmentFailure
        )
        XCTAssertTrue(causalFixture.deathWaitReturned)
        XCTAssertEqual(
            causalFixture.executionPhase,
            "orphan_initial_census"
        )
        XCTAssertEqual(
            causalFixture.failureCoordinate,
            "supervisor_stop"
        )
        XCTAssertEqual(causalFixture.failureStatus, 70)
        XCTAssertEqual(causalFixture.fixedFailStopStatus, 70)
        XCTAssertEqual(causalFixture.fixtureMode, "orphan_transition")
        XCTAssertEqual(
            causalFixture.initiatingFailureCoordinate,
            "session_census_nonconvergent_query"
        )
        XCTAssertEqual(causalFixture.initiatingFailureStatus, 70)
        XCTAssertEqual(
            causalFixture.schema,
            "prime_driver_v2_session_fixture_fail_stop_v2"
        )
        XCTAssertEqual(
            causalFixture.sourceIdentitySHA256,
            PrimeEmbeddedBuildProvenance.sourceIdentitySHA256
        )
        XCTAssertTrue(
            !causalFixture.deathWaitReturned ||
                causalFixture.deathEventObservedAtContainmentFailure
        )
        XCTAssertTrue(
            !causalFixture.containmentStopDeathEventObserved ||
                causalFixture.deathEventObservedAtContainmentFailure
        )
        XCTAssertTrue(
            !(causalFixture.deathWaitReturned &&
                causalFixture
                    .containmentStopDeathEventCheckPerformed) ||
                causalFixture.containmentStopDeathEventObserved
        )
        XCTAssertEqual(
            causalFixture.failureCoordinate == "supervisor_stop",
            causalFixture.containmentStopReturn == -1 &&
                !(causalFixture.containmentStopErrno == ESRCH &&
                    causalFixture
                        .containmentStopDeathEventCheckPerformed &&
                    causalFixture.containmentStopDeathEventObserved)
        )

        let causalSeamName =
            "sessionFixtureCausalFailStopV2CanonicalFixture" +
            "ForTesting"
        XCTAssertEqual(
            governor.components(separatedBy: causalSeamName).count - 1,
            1
        )
        XCTAssertEqual(
            liveTestsSource.components(
                separatedBy: causalSeamName
            ).count - 1,
            1
        )
        XCTAssertFalse(governorMain.contains(causalSeamName))
        let normalizedGovernor = governor
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        XCTAssertTrue(
            normalizedGovernor.contains(
                "package extension " +
                    "PrimeValidationDriverV2ShotGovernor { " +
                    "static func " + causalSeamName +
                    "() throws -> Data"
            )
        )
        let causalPackageExtensionPrefix = try slice(
            governor,
            from:
                "package extension " +
                "PrimeValidationDriverV2ShotGovernor {",
            through: causalSeamName + "()"
        )
        XCTAssertTrue(
            causalPackageExtensionPrefix.contains(
                "package extension " +
                    "PrimeValidationDriverV2ShotGovernor {"
            )
        )
        XCTAssertFalse(
            governor.contains("public static func " + causalSeamName)
        )
        XCTAssertTrue(
            liveTestsSource.contains("." + causalSeamName + "()")
        )
        let causalSeamSource = try slice(
            governor,
            from: causalSeamName + "()",
            through: "static func exerciseSessionFixtureForTesting("
        )
        for forbidden in [
            "Darwin.open(",
            "openat(",
            "posix_spawn(",
            "Process(",
            "Darwin.kill(",
            "waitpid(",
            "DispatchSource",
            "FileManager",
            "URL(",
            "CommandLine",
            "descriptor",
            "absolutePath",
            "argv",
            "environment",
            "callback",
            "timeout",
            "publishBestEffort(",
            "consume(",
            "execute(",
        ] {
            XCTAssertFalse(causalSeamSource.contains(forbidden), forbidden)
        }
        let normalizedCausalSeam = causalSeamSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        for required in [
            "try requireRejected { try makeRecord(" +
                "stopAttemptSequence: 0) }",
            "try requireRejected { try makeRecord(" +
                "stopAttemptSequence: 2) }",
            "try makeRecord(stopReturn: 0, stopErrno: 1)",
            "try makeRecord(stopReturn: -1, stopErrno: 0)",
            "try makeRecord(stopDeathEventObserved: true)",
            "stopDeathEventCheckPerformed: true, " +
                "stopDeathEventObserved: true",
            "stopErrno: ESRCH, " +
                "stopDeathEventCheckPerformed: false",
            "stopErrno: ESRCH, " +
                "stopDeathEventCheckPerformed: true, " +
                "stopDeathEventObserved: true",
            "try makeRecord( " +
                "deathEventObservedAtContainmentFailure: false )",
            "stopErrno: ESRCH, " +
                "stopDeathEventCheckPerformed: true, " +
                "stopDeathEventObserved: true, " +
                "deathWaitReturned: false, " +
                "deathEventObservedAtContainmentFailure: false",
            "\"session_census_unknown\"",
            "\"session_census_getsid_\"",
            "\"session_census_bsdinfo_-1\"",
            "\"session_census_getpgid_03\"",
            "\"session_census_getsid_x\"",
            "\"session_census_bsdinfo_2147483648\"",
            "\"session_census_getsid_3\"",
            "\"session_census_getpgid_3\"",
            "let canonical = try PrimeCanonicalJSON.encode(record)",
            "PrimeCanonicalJSON.decode( " +
                "PrimeValidationDriverV2SessionFixtureFailStopV2.self",
        ] {
            XCTAssertTrue(
                normalizedCausalSeam.contains(required),
                required
            )
        }
        let causalRecordSource = try slice(
            governor,
            from:
                "private struct " +
                "PrimeValidationDriverV2SessionFixtureFailStopV2:",
            through:
                "private final class " +
                "PrimeValidationDriverV2SessionFixtureFailStopLeaf"
        )
        let normalizedCausalRecord = causalRecordSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        XCTAssertEqual(
            governor.components(
                separatedBy:
                    "prime_driver_v2_session_fixture_fail_stop_v2"
            ).count - 1,
            1
        )
        XCTAssertFalse(
            governor.contains(
                "prime_driver_v2_session_fixture_fail_stop_v1"
            )
        )
        for required in [
            "static let maximumByteCount = 1_024",
            "static let maximumCoordinateByteCount = 128",
            "fixtureMode == .orphanTransition",
            "executionPhase == .orphanInitialCensus",
            "containmentState == .armed",
            "deathWaitReturned",
            "containmentStopAttemptSequence == 1",
            "containmentFailure.coordinate == \"supervisor_stop\"",
            "Self.initiatingCoordinateIsClosedCensus( " +
                "initiatingFailure.coordinate )",
            "stop.deathEventCheckPerformed == ( " +
                "stop.returnValue == -1 && stop.errorNumber == ESRCH )",
            "stop.deathEventCheckPerformed || " +
                "!stop.deathEventObserved",
            "!deathWaitReturned || " +
                "deathEventObservedAtContainmentFailure",
            "!stop.deathEventObserved || " +
                "deathEventObservedAtContainmentFailure",
            "!(deathWaitReturned && " +
                "stop.deathEventCheckPerformed) || " +
                "stop.deathEventObserved",
            "(containmentFailure.coordinate == \"supervisor_stop\") " +
                "== ( stop.returnValue == -1",
            "sourceIdentitySHA256 = " +
                "PrimeEmbeddedBuildProvenance.sourceIdentitySHA256",
        ] {
            XCTAssertTrue(
                normalizedCausalRecord.contains(required),
                required
            )
        }
        func requireSourceOrder(
            _ markers: [String],
            in source: String,
            coordinate: String
        ) throws {
            var cursor = source.startIndex
            for marker in markers {
                guard let range = source.range(
                    of: marker,
                    range: cursor ..< source.endIndex
                ) else {
                    throw FixtureError.invalid(
                        coordinate + "_" + marker
                    )
                }
                cursor = range.upperBound
            }
        }
        let preliminaryStopSource = try slice(
            governor,
            from: "let stopTarget = -supervisorPID",
            through:
                "var previous: " +
                "[PrimeValidationDriverV2GovernorSessionMember]?"
        )
        let normalizedPreliminaryStop = preliminaryStopSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        try requireSourceOrder(
            [
                "let stopTarget = -supervisorPID",
                "errno = 0",
                "let stopReturn = Darwin.kill(stopTarget, SIGSTOP)",
                "let stopErrno = errno",
                "if stopReturn == -1, stopErrno == ESRCH",
                "deathEventCheckPerformed = true",
                "deathEventObserved = deathWatcher.hasObservedExit()",
                "if stopReturn != 0",
                "if stopErrno == ESRCH, deathEventObserved",
                "return try reapNormallyAfterExit(",
                "throw governorRejected(",
                "preliminarySupervisorStopObservation: .init(",
                "returnValue: stopReturn",
                "errorNumber: stopErrno",
                "deathEventCheckPerformed: deathEventCheckPerformed",
                "deathEventObserved: deathEventObserved",
            ],
            in: normalizedPreliminaryStop,
            coordinate: "causal_stop_order"
        )
        let exerciseMarker =
            "static func exerciseSessionFixtureForTesting("
        let exerciseStart = try XCTUnwrap(
            governor.range(of: exerciseMarker)?.lowerBound
        )
        let sessionExerciseSource = String(governor[exerciseStart...])
        let normalizedSessionExercise = sessionExerciseSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        try requireSourceOrder(
            [
                "var initiatingFailure: " +
                    "PrimeValidationDriverV2SessionFixtureInitiatingFailure?",
                "var deathWaitReturned = false",
                "defer { do { switch containmentState",
                "if let containmentFailure = error as? " +
                    "PrimeValidationDriverV2ShotGovernorFailure",
                "failStopDiagnostic.publishBestEffort(",
                "containmentFailure: containmentFailure",
                "initiatingFailure: initiatingFailure",
                "deathWaitReturned: deathWaitReturned",
                "deathEventObservedAtContainmentFailure: " +
                    "deathWatcher.hasObservedExit()",
                "Darwin._exit(",
                "do { guard Darwin.getpgid(pid) == pid",
                "let waitReturned = deathWatcher.wait(deadline: deadline)",
                "deathWaitReturned = waitReturned",
                "guard waitReturned else",
                "executionPhase = .orphanInitialCensus",
                "resultObservation = try " +
                    "PrimeValidationDriverV2GovernorSessionCensus " +
                    ".reapNormallyAfterExit(",
                "executionPhase = .primaryContainment",
                "} catch { if let failure = error as? " +
                    "PrimeValidationDriverV2ShotGovernorFailure",
                "initiatingFailure = .init(",
                "status: failure.status",
                "coordinate: failure.coordinate",
                "throw error",
            ],
            in: normalizedSessionExercise,
            coordinate: "causal_session_order"
        )
        let orphanCaptureSource = try slice(
            sessionExerciseSource,
            from: "executionPhase = .orphanDeathWait",
            through: "executionPhase = .primaryContainment"
        )
        XCTAssertFalse(orphanCaptureSource.contains("hasObservedExit()"))
        XCTAssertEqual(
            sessionExerciseSource.components(
                separatedBy:
                    "PrimeValidationDriverV2GovernorDeathWatcher(pid: pid)"
            ).count - 1,
            1
        )
        XCTAssertFalse(
            sessionExerciseSource.contains(
                "DispatchSource.makeProcessSource"
            )
        )

        let censusSource = try slice(
            governor,
            from:
                "private enum " +
                "PrimeValidationDriverV2GovernorSessionCensus {",
            through:
                "private enum PrimeValidationDriverV2GovernorSpawner {"
        )
        let normalizedCensus = censusSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        XCTAssertTrue(
            normalizedCensus.contains("static let maximumScans = 256")
        )
        XCTAssertTrue(
            normalizedCensus.contains("static let pidCapacity = 131_072")
        )
        XCTAssertEqual(
            censusSource.components(separatedBy: "proc_listpids(")
                .count - 1,
            1
        )
        XCTAssertEqual(
            normalizedCensus.components(
                separatedBy:
                    "for group in lifecycleState.proofProcessGroups { " +
                    "try deadline.requireTime("
            ).count - 1,
            3
        )
        XCTAssertEqual(
            governor.components(separatedBy: "scan(").count - 1,
            2
        )
        XCTAssertEqual(
            governor.components(
                separatedBy:
                    "PrimeValidationDriverV2GovernorSessionLifecycleState("
            ).count - 1,
            2
        )
        XCTAssertFalse(
            governor.contains(
                "sessionCensusRepairModelCanonicalFixtureForTesting"
            )
        )
        XCTAssertFalse(censusSource.contains("EPERM"))

        let censusScanSource = try slice(
            censusSource,
            from: "static func scan(",
            through: "static func recordedScan("
        )
        let normalizedCensusScan = censusScanSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        XCTAssertTrue(
            normalizedCensusScan.contains(
                "static func scan( sessionIdentifier: pid_t, " +
                    "deadline: " +
                    "PrimeValidationDriverV2GovernorDeadline ) throws"
            )
        )
        XCTAssertFalse(censusScanSource.contains("for _ in 0 ..< 4"))
        XCTAssertFalse(censusScanSource.contains("var retry"))
        try requireSourceOrder(
            [
                "try deadline.requireTime(" +
                    "\"session_census_nonconvergent_query\")",
                "proc_listpids(",
                "try deadline.requireTime(" +
                    "\"session_census_nonconvergent_query\")",
                "guard Set(positive).count == positive.count",
                "for pid in positive.sorted()",
                "joinedMemberIfInTargetSession(",
                "members.append(member)",
                "guard Set(members.map(\\.generationKey)).count " +
                    "== members.count",
                "return members.sorted",
            ],
            in: censusScanSource,
            coordinate: "r13_census_sample_order"
        )

        let lifecycleStateSource = try slice(
            governor,
            from:
                "private final class " +
                "PrimeValidationDriverV2GovernorSessionLifecycleState {",
            through:
                "private struct " +
                "PrimeValidationDriverV2GovernorWaitObservation:"
        )
        let normalizedLifecycleState = lifecycleStateSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        for required in [
            "let supervisorPID: pid_t",
            "private(set) var capturedGenerations = " +
                "[String: PrimeValidationDriverV2GovernorSessionMember]()",
            "private(set) var proofProcessGroups: Set<Int32>",
            "private(set) var completedScanCount = 0",
            "proofProcessGroups = [supervisorPID]",
            "completedScanCount += 1",
            "if capturedGenerations[member.generationKey] == nil",
            "capturedGenerations[member.generationKey] = member",
            "proofProcessGroups.insert(member.processGroupIdentifier)",
        ] {
            XCTAssertTrue(normalizedLifecycleState.contains(required), required)
        }
        for forbidden in [
            "capturedGenerations.remove",
            "capturedGenerations = [:]",
            "proofProcessGroups.remove",
            "proofProcessGroups.removeAll",
            "completedScanCount -=",
            "completedScanCount = 0",
        ] {
            if forbidden == "completedScanCount = 0" {
                XCTAssertEqual(
                    lifecycleStateSource.components(
                        separatedBy: forbidden
                    ).count - 1,
                    1
                )
            } else {
                XCTAssertFalse(lifecycleStateSource.contains(forbidden))
            }
        }
        let recordedScanSource = try slice(
            censusSource,
            from: "static func recordedScan(",
            through: "private static func joinedMemberIfInTargetSession("
        )
        let normalizedRecordedScan = recordedScanSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        XCTAssertEqual(
            governor.components(separatedBy: "recordedScan(").count - 1,
            8
        )
        try requireSourceOrder(
            [
                "guard lifecycleState.completedScanCount < maximumScans",
                "let members = try scan(",
                "sessionIdentifier: lifecycleState.supervisorPID",
                "deadline: deadline",
                "lifecycleState.recordCompletedScan(members)",
                "return members",
            ],
            in: normalizedRecordedScan,
            coordinate: "r13_recorded_scan_atomic_order"
        )

        let joinedMemberSource = try slice(
            censusSource,
            from: "private static func joinedMemberIfInTargetSession(",
            through: "static func contain("
        )
        let normalizedJoinedMember = joinedMemberSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        XCTAssertEqual(
            joinedMemberSource.components(
                separatedBy: "for _ in 0 ..< 4"
            ).count - 1,
            1
        )
        for required in [
            "if firstCount <= 0, firstErrno == ESRCH { return nil }",
            "if observedSession < 0, sessionErrno == ESRCH { " +
                "return nil }",
            "if group < 0, groupErrno == ESRCH { return nil }",
            "if secondCount <= 0, secondErrno == ESRCH { return nil }",
            "guard firstCount == Int32(expected) else",
            "guard observedSession >= 0 else",
            "guard group > 0 else",
            "guard secondCount == Int32(expected) else",
            "session_census_bsdinfo_\\(firstErrno)",
            "session_census_bsdinfo_\\(secondErrno)",
            "session_census_getpgid_0",
            "session_census_nonconvergent_query",
            "var observedGroup: pid_t? = nil",
            "var mapped: (deviceID: UInt64, inode: UInt64, " +
                "path: String)? = nil",
            "parentProcessIdentifier: " +
                "Int32(secondGeneration.pbi_ppid)",
            "ownerUserID: secondGeneration.pbi_uid",
            "kernelStatus: secondGeneration.pbi_status",
            "startSeconds: secondGeneration.pbi_start_tvsec",
            "startMicroseconds: secondGeneration.pbi_start_tvusec",
            "mappedDeviceID: mapped?.deviceID",
            "mappedInode: mapped?.inode",
            "mappedPathTelemetry: mapped?.path",
        ] {
            XCTAssertTrue(normalizedJoinedMember.contains(required), required)
        }
        XCTAssertEqual(
            joinedMemberSource.components(separatedBy: "continue")
                .count - 1,
            1
        )
        try requireSourceOrder(
            [
                "for _ in 0 ..< 4",
                "try deadline.requireTime(" +
                    "\"session_census_nonconvergent_query\")",
                "var firstGeneration = proc_bsdinfo()",
                "proc_pidinfo(",
                "let firstErrno = errno",
                "try deadline.requireTime(" +
                    "\"session_census_nonconvergent_query\")",
                "firstGeneration.pbi_pid == UInt32(pid)",
                "let observedSession = Darwin.getsid(pid)",
                "let sessionErrno = errno",
                "try deadline.requireTime(" +
                    "\"session_census_nonconvergent_query\")",
                "if observedSession == sessionIdentifier",
                "let group = Darwin.getpgid(pid)",
                "let groupErrno = errno",
                "try deadline.requireTime(" +
                    "\"session_census_nonconvergent_query\")",
                "mapped = try mappedIdentityIfAvailable(",
                "var secondGeneration = proc_bsdinfo()",
                "proc_pidinfo(",
                "let secondErrno = errno",
                "try deadline.requireTime(" +
                    "\"session_census_nonconvergent_query\")",
                "secondGeneration.pbi_pid == UInt32(pid)",
                "firstGeneration.pbi_start_tvsec",
                "== secondGeneration.pbi_start_tvsec",
                "firstGeneration.pbi_start_tvusec",
                "== secondGeneration.pbi_start_tvusec",
                "continue",
                "guard observedSession == sessionIdentifier else",
                "guard let observedGroup else",
                "return .init(",
            ],
            in: joinedMemberSource,
            coordinate: "r13_generation_join_order"
        )

        let mappedTelemetrySource = try slice(
            censusSource,
            from: "private static func mappedIdentityIfAvailable(",
            through:
                "private struct " +
                "PrimeValidationDriverV2GovernorSpawnedSupervisor {"
        )
        let normalizedMappedTelemetry = mappedTelemetrySource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        XCTAssertTrue(
            normalizedMappedTelemetry.contains(
                "pid: pid_t, deadline: " +
                    "PrimeValidationDriverV2GovernorDeadline ) throws"
            )
        )
        XCTAssertEqual(
            mappedTelemetrySource.components(
                separatedBy: "for _ in 0 ..< 256"
            ).count - 1,
            1
        )
        try requireSourceOrder(
            [
                "for _ in 0 ..< 256",
                "try deadline.requireTime(" +
                    "\"session_census_nonconvergent_query\")",
                "proc_pidinfo(",
                "try deadline.requireTime(" +
                    "\"session_census_nonconvergent_query\")",
            ],
            in: mappedTelemetrySource,
            coordinate: "r13_mapped_telemetry_deadline_order"
        )
        let containEntrySource = try slice(
            censusSource,
            from: "static func contain(",
            through: "static func reapNormallyAfterExit("
        )
        let normalizedContainEntry = containEntrySource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        try requireSourceOrder(
            [
                "let supervisorPID = lifecycleState.supervisorPID",
                "if deathWatcher.hasObservedExit()",
                "return try reapNormallyAfterExit(",
                "lifecycleState: lifecycleState",
                "let stopTarget = -supervisorPID",
                "let stopReturn = Darwin.kill(stopTarget, SIGSTOP)",
                "if stopReturn == -1, stopErrno == ESRCH",
                "deathEventObserved = deathWatcher.hasObservedExit()",
                "if stopReturn != 0",
                "if stopErrno == ESRCH, deathEventObserved",
                "return try reapNormallyAfterExit(",
                "lifecycleState: lifecycleState",
                "throw governorRejected(",
            ],
            in: normalizedContainEntry,
            coordinate: "r13_reap_first_entry_order"
        )
        try requireSourceOrder(
            [
                "let wait = try exactWait(",
                "onExactReap()",
                "try deadline.requireTime(" +
                    "\"exact_supervisor_wait_return_deadline\")",
                "let members = try recordedScan(",
                "lifecycleState: lifecycleState",
            ],
            in: normalizedContainEntry,
            coordinate: "r13_contain_atomic_reap_order"
        )

        let normalReapSource = try slice(
            censusSource,
            from: "static func reapNormallyAfterExit(",
            through: "static func containSessionAfterSupervisorReaped("
        )
        let normalizedNormalReap = normalReapSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        let beforePostReapScan = try slice(
            normalReapSource,
            from: "static func reapNormallyAfterExit(",
            through: "onExactReap()"
        )
        XCTAssertFalse(beforePostReapScan.contains("recordedScan("))
        XCTAssertFalse(beforePostReapScan.contains("Darwin.kill("))
        try requireSourceOrder(
            [
                "let supervisorPID = lifecycleState.supervisorPID",
                "guard deathWatcher.hasObservedExit() else",
                "let wait = try exactWait(",
                "onExactReap()",
                "try deadline.requireTime(" +
                    "\"exact_supervisor_wait_return_deadline\")",
                "let first = try recordedScan(",
                "lifecycleState: lifecycleState",
                "deadline: deadline",
                "if !first.isEmpty",
                "containSessionAfterSupervisorReaped(",
                "lifecycleState: lifecycleState",
                "initialMembers: first",
                "let second = try recordedScan(",
                "lifecycleState: lifecycleState",
                "deadline: deadline",
                "if !second.isEmpty",
                "containSessionAfterSupervisorReaped(",
                "lifecycleState: lifecycleState",
                "initialMembers: second",
                "for member in lifecycleState.capturedGenerations.values",
                "for group in lifecycleState.proofProcessGroups",
                "finalEmptyScanCount: 2",
                "ordinaryExitPath: true",
            ],
            in: normalizedNormalReap,
            coordinate: "r13_exact_reap_then_two_empty_order"
        )

        let postReapContainmentSource = try slice(
            censusSource,
            from:
                "private static func " +
                "containSessionAfterSupervisorReaped(",
            through: "private static func exactWait("
        )
        let normalizedPostReapContainment = postReapContainmentSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        XCTAssertFalse(
            postReapContainmentSource.contains(
                "Darwin.kill(-supervisorPID, SIGSTOP)"
            )
        )
        XCTAssertFalse(
            postReapContainmentSource.contains(
                "Darwin.kill(-supervisorPID, SIGKILL)"
            )
        )
        for required in [
            "for group in Set(initialMembers.map(" +
                "\\.processGroupIdentifier)) { " +
                "try deadline.requireTime( " +
                "\"post_reap_containment_stopped_fixed_point_deadline\" " +
                ") errno = 0 if Darwin.kill(-group, SIGSTOP)",
            "for group in Set(members.map(" +
                "\\.processGroupIdentifier)) { " +
                "try deadline.requireTime( " +
                "\"post_reap_containment_stopped_fixed_point_deadline\" " +
                ") errno = 0 if Darwin.kill(-group, SIGSTOP)",
            "for group in fixedPointGroups.sorted() { " +
                "try deadline.requireTime( " +
                "\"post_reap_containment_stopped_fixed_point_deadline\" " +
                ") errno = 0 if Darwin.kill(-group, SIGKILL)",
            "for member in members { " +
                "try deadline.requireTime( " +
                "\"post_reap_containment_empty_scan_deadline\" ) " +
                "errno = 0 if Darwin.kill(" +
                "-member.processGroupIdentifier, SIGKILL)",
            "for member in " +
                "lifecycleState.capturedGenerations.values { " +
                "try deadline.requireTime( " +
                "\"post_reap_containment_empty_scan_deadline\" ) " +
                "if let current = try bsdInfoIfPresent(",
            "for group in lifecycleState.proofProcessGroups { " +
                "try deadline.requireTime( " +
                "\"post_reap_containment_empty_scan_deadline\" ) " +
                "errno = 0 guard Darwin.kill(-group, 0)",
        ] {
            XCTAssertTrue(
                normalizedPostReapContainment.contains(required),
                required
            )
        }
        try requireSourceOrder(
            [
                "let supervisorPID = lifecycleState.supervisorPID",
                "for group in Set(initialMembers.map(" +
                    "\\.processGroupIdentifier))",
                "Darwin.kill(-group, SIGSTOP)",
                "while lifecycleState.completedScanCount < maximumScans",
                "let members = try recordedScan(",
                "for group in Set(members.map(" +
                    "\\.processGroupIdentifier))",
                "members.allSatisfy(\\.stoppedOrZombie)",
                "fixedPointMembers = members",
                "let fixedPointGroups = Set(",
                "for group in fixedPointGroups.sorted()",
                "Darwin.kill(-group, SIGKILL)",
                "while lifecycleState.completedScanCount < maximumScans, " +
                    "emptyCount < 2",
                "let members = try recordedScan(",
                "guard emptyCount == 2 else",
                "for member in " +
                    "lifecycleState.capturedGenerations.values",
                "for group in lifecycleState.proofProcessGroups",
                "guard Darwin.kill(-group, 0) == -1, " +
                    "errno == ESRCH else",
                "capturedMembers: " +
                    "lifecycleState.capturedGenerations.values.sorted",
                "capturedProcessGroups: " +
                    "lifecycleState.proofProcessGroups.sorted()",
                "completeScanCount: lifecycleState.completedScanCount",
            ],
            in: normalizedPostReapContainment,
            coordinate: "r13_member_group_actuation_and_proof_order"
        )

        let sessionFixtureModeSource = try slice(
            sessionExerciseSource,
            from:
                "var firstMembers = " +
                "[PrimeValidationDriverV2GovernorSessionMember]()",
            through: "return .init("
        )
        let prepublicationContainmentSource = try slice(
            sessionFixtureModeSource,
            from: "case .prepublicationHeld:",
            through: "case .orphanTransition:"
        )
        XCTAssertTrue(prepublicationContainmentSource.contains(".contain("))
        XCTAssertFalse(
            prepublicationContainmentSource.contains(
                ".reapNormallyAfterExit("
            )
        )
        let orphanReapSource = try slice(
            sessionFixtureModeSource,
            from: "case .orphanTransition:",
            through: "try failStopDiagnostic.revalidateEmpty()"
        )
        XCTAssertFalse(orphanReapSource.contains(".recordedScan("))
        try requireSourceOrder(
            [
                "executionPhase = .orphanDeathWait",
                "let waitReturned = deathWatcher.wait(deadline: deadline)",
                "guard waitReturned else",
                "executionPhase = .orphanInitialCensus",
                ".reapNormallyAfterExit(",
                "onExactReap: { containmentState = .exactReaped }",
                "executionPhase = .primaryContainment",
                "containmentState = .conservationComplete",
            ],
            in: orphanReapSource,
            coordinate: "r13_orphan_reap_first_order"
        )
        let productionDeathRoute = try slice(
            governor,
            from: "if spawned.deathWatcher.wait(deadline: deadline) {",
            through: "containmentGuard.acceptConservation()"
        )
        try requireSourceOrder(
            [
                "if spawned.deathWatcher.wait(deadline: deadline)",
                ".reapNormallyAfterExit(",
                "} else {",
                ".contain(",
            ],
            in: productionDeathRoute,
            coordinate: "r13_production_death_route_order"
        )
        let spawnedSupervisorSource = try slice(
            governor,
            from:
                "private struct " +
                "PrimeValidationDriverV2GovernorSpawnedSupervisor {",
            through:
                "private final class " +
                "PrimeValidationDriverV2GovernorSpawnContainmentGuard"
        )
        XCTAssertTrue(
            spawnedSupervisorSource.contains(
                "let lifecycleState: " +
                    "PrimeValidationDriverV2GovernorSessionLifecycleState"
            )
        )
        let containmentGuardSource = try slice(
            governor,
            from:
                "private final class " +
                "PrimeValidationDriverV2GovernorSpawnContainmentGuard",
            through:
                "private enum PrimeValidationDriverV2GovernorSpawner {"
        )
        XCTAssertEqual(
            containmentGuardSource.components(
                separatedBy: "lifecycleState: spawned.lifecycleState"
            ).count - 1,
            3
        )

        let spawnerSource = try slice(
            governor,
            from: "static func spawnSupervisor(",
            through:
                "private struct " +
                "PrimeValidationDriverV2GovernorStartRecordV1:"
        )
        try requireSourceOrder(
            [
                "guard spawnResult == 0, pid > 0 else",
                "let lifecycleState =",
                "PrimeValidationDriverV2GovernorSessionLifecycleState(",
                "return .init(",
                "lifecycleState: lifecycleState",
                "var suspendedJoinExactReaped = false",
                ".contain(",
                "lifecycleState: lifecycleState",
                "onExactReap:",
                "suspendedJoinExactReaped = true",
                "guard suspendedJoinExactReaped else",
                ".containSessionAfterSupervisorReaped(",
                "lifecycleState: lifecycleState",
            ],
            in: spawnerSource,
            coordinate: "r13_suspended_join_retained_state_order"
        )

        try requireSourceOrder(
            [
                "guard result == 0, pid > 0 else",
                "let lifecycleState =",
                "PrimeValidationDriverV2GovernorSessionLifecycleState(",
                "defer {",
                ".contain(",
                "lifecycleState: lifecycleState",
                ".containSessionAfterSupervisorReaped(",
                "lifecycleState: lifecycleState",
                "do { guard Darwin.getpgid(pid) == pid",
                "switch mode",
                ".recordedScan(",
                "lifecycleState: lifecycleState",
                ".contain(",
                "lifecycleState: lifecycleState",
                ".reapNormallyAfterExit(",
                "lifecycleState: lifecycleState",
            ],
            in: normalizedSessionExercise,
            coordinate: "r13_fixture_retained_state_order"
        )

        let exactWaitSource = try slice(
            censusSource,
            from: "private static func exactWait(",
            through: "private static func bsdInfoIfPresent("
        )
        XCTAssertEqual(
            exactWaitSource.components(
                separatedBy:
                    "Darwin.waitpid(supervisorPID, &raw, 0)"
            ).count - 1,
            1
        )
        XCTAssertFalse(
            exactWaitSource.contains(
                "exact_supervisor_wait_return_deadline"
            )
        )
        XCTAssertFalse(
            normalizedCensus.contains(
                "onExactReap: () -> Void ="
            )
        )
        XCTAssertEqual(
            censusSource.components(
                separatedBy: "onExactReap: () -> Void"
            ).count - 1,
            2
        )
        let capturedGenerationQuerySource = try slice(
            censusSource,
            from: "private static func bsdInfoIfPresent(",
            through: "private static func mappedIdentityIfAvailable("
        )
        try requireSourceOrder(
            [
                "if returned == Int32(size)",
                "guard value.pbi_pid == UInt32(pid) else",
                "throw governorRejected(",
                "return value",
            ],
            in: capturedGenerationQuerySource,
            coordinate: "r13_captured_generation_pid_join_order"
        )

        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let journal = URL(
            fileURLWithPath:
                fixture.workspace.path +
                ".driver-v2-gate-e-journal",
            isDirectory: true
        )
        try makePrivateDirectory(journal)
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        XCTAssertFalse(image.productionSupervisorImageEligible)
        let transfer = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        )
        let facade = try image.transferDriverV2RoleFacade(
            context: transfer.context
        )
        let race = GateEJournalMechanicsRace()
        let ready = DispatchGroup()
        let done = DispatchGroup()
        let start = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(
            label: "prime.validation.gate-e-facade-race",
            attributes: .concurrent
        )
        for _ in 0 ..< 2 {
            ready.enter()
            done.enter()
            queue.async {
                ready.leave()
                start.wait()
                race.record {
                    try facade.exerciseFixedProbeJournalMechanicsForTesting()
                }
                done.leave()
            }
        }
        XCTAssertEqual(ready.wait(timeout: .now() + 5), .success)
        start.signal()
        start.signal()
        XCTAssertEqual(done.wait(timeout: .now() + 30), .success)
        let observation = try XCTUnwrap(race.values.first)
        XCTAssertEqual(race.values.count, 1)
        XCTAssertEqual(race.errors.count, 1)
        let raceError = race.errors.first as?
            PrimeValidationSwiftPMBuildInventoryAdmissionError
        XCTAssertTrue(
            raceError == .guardedPreExecutorTransferred
                || raceError == .guardedPreExecutorPoisoned
        )
        race.releaseValues()
        XCTAssertEqual(
            observation.orderedLeaves.map(\.leaf),
            expectedLeaves
        )
        XCTAssertEqual(observation.rootLinkCount, 36)
        XCTAssertEqual(observation.heldLeafDescriptorCount, 34)
        XCTAssertEqual(observation.spawnedChildCount, 0)
        XCTAssertTrue(observation.leafPermissionModes.allSatisfy {
            $0 == 0o400
        })
        XCTAssertTrue(observation.leafLinkCounts.allSatisfy { $0 == 1 })
        XCTAssertEqual(
            Set(observation.orderedLeaves.map {
                "\($0.deviceID):\($0.inode)"
            }).count,
            34
        )
        XCTAssertEqual(facade.continuityState, .poisoned)
        XCTAssertEqual(facade.processExecutionObservation, .unobserved)
        XCTAssertThrowsError(
            try facade.exerciseFixedProbeJournalMechanicsForTesting()
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned
            )
        }
        XCTAssertEqual(
            Set(
                try FileManager.default.contentsOfDirectory(
                    atPath: journal.path
                )
            ),
            Set(expectedLeaves)
        )
        var predecessorSHA256 = String(repeating: "0", count: 64)
        for (index, pair) in zip(
            expectedLeaves,
            observation.orderedLeaves
        ).enumerated() {
            let (leaf, leafObservation) = pair
            let url = journal.appendingPathComponent(leaf)
            let data = try Data(contentsOf: url)
            var status = stat()
            XCTAssertEqual(lstat(url.path, &status), 0, leaf)
            XCTAssertEqual(
                status.st_mode & mode_t(S_IFMT),
                mode_t(S_IFREG),
                leaf
            )
            XCTAssertEqual(status.st_mode & mode_t(0o7777), 0o400, leaf)
            XCTAssertEqual(status.st_nlink, 1, leaf)
            XCTAssertEqual(data.last, 0x0a, leaf)
            XCTAssertLessThanOrEqual(data.count, 64 * 1024, leaf)
            XCTAssertEqual(
                UInt64(data.count),
                leafObservation.byteCount,
                leaf
            )
            XCTAssertEqual(
                PrimeSHA256.hexDigest(of: data),
                leafObservation.sha256,
                leaf
            )
            XCTAssertNil(
                data.range(of: Data(leafObservation.sha256.utf8)),
                leaf
            )
            let canonical = Data(data.dropLast())
            let record = try PrimeCanonicalJSON.decode(
                GateEJournalMechanicsRecord.self,
                from: canonical
            )
            XCTAssertEqual(
                try PrimeCanonicalJSON.encode(record),
                canonical,
                leaf
            )
            XCTAssertEqual(
                record.schema,
                "prime_driver_v2_gate_e_journal_mechanics_test_v1",
                leaf
            )
            XCTAssertEqual(record.ordinal, index + 1, leaf)
            XCTAssertEqual(record.leaf, leaf, leaf)
            XCTAssertEqual(
                record.predecessorSHA256,
                predecessorSHA256,
                leaf
            )
            predecessorSHA256 = leafObservation.sha256
        }

        // A pre-existing first leaf rejects before any journal publication or
        // child and permanently poisons a separate test-host facade.
        let collisionFixture = try Fixture()
        defer { collisionFixture.cleanup() }
        let collisionJournal = URL(
            fileURLWithPath:
                collisionFixture.workspace.path +
                ".driver-v2-gate-e-journal",
            isDirectory: true
        )
        try makePrivateDirectory(collisionJournal)
        let collision = collisionJournal.appendingPathComponent(
            "gate-e-prestart.json"
        )
        try Data("collision\n".utf8).write(to: collision)
        guard chmod(collision.path, 0o400) == 0 else {
            throw FixtureError.invalid("gate_e_collision_mode")
        }
        let collisionGuarded = try preparedGuard(for: collisionFixture)
        let collisionImage = try boundTestImage(for: collisionGuarded)
        XCTAssertFalse(collisionImage.productionSupervisorImageEligible)
        let collisionContext = try roleTransferInputs(
            fixture: collisionFixture,
            guarded: collisionGuarded
        ).context
        let collisionFacade = try collisionImage.transferDriverV2RoleFacade(
            context: collisionContext
        )
        XCTAssertThrowsError(
            try collisionFacade.exerciseFixedProbeJournalMechanicsForTesting()
        )
        XCTAssertEqual(collisionFacade.continuityState, .poisoned)
        XCTAssertEqual(
            collisionFacade.processExecutionObservation,
            .unobserved
        )
        XCTAssertThrowsError(
            try collisionFacade.exerciseFixedProbeJournalMechanicsForTesting()
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned
            )
        }
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: collisionJournal.path
            ),
            ["gate-e-prestart.json"]
        )

        for required in [
            "prime_driver_v2_gate_e_shot_capsule_v1",
            "prime_driver_v2_gate_e_outer_start_v1",
            "prime_driver_v2_gate_e_outer_terminal_v1",
            "00-capsule.json",
            "01-supervisor-request.json",
            "02-outer-start.json",
            "03-outer-terminal.json",
            "O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC",
            "independentRequestInputDescriptor()",
            "posix_spawn_file_actions_addfchdir(",
            "private static let emptySHA256",
            "static let pidCapacity = 131_072",
            "static let maximumScans = 256",
            "kernelStatus == 4 || kernelStatus == 5",
            "Darwin.waitpid(supervisorPID, &raw, 0)",
            "PrimeValidationDriverV2GovernorSessionCensus.contain(",
            "containSessionAfterSupervisorReaped(",
            "case conservationCompleted",
            "onExactReap: containmentGuard.acceptExactReap",
            "PrimeValidationDriverV2OuterSourceContinuity.capture(",
            "PrimeValidationDriverV2FixedProbeDurableJournalValidatorV2",
            "sourceIdentitySHA256\n" +
                "                == PrimeEmbeddedBuildProvenance" +
                ".sourceIdentitySHA256",
        ] {
            XCTAssertTrue(governor.contains(required), required)
        }
        for forbidden in [
            "Process(",
            "swift-package",
            "list_xctest",
            "list_swift_testing",
            "WUNTRACED",
            "waitpid(supervisorPID, &raw, WNOHANG)",
        ] {
            XCTAssertFalse(governor.contains(forbidden), forbidden)
        }

        func outerMechanicsFacade(
            fixture: Fixture,
            intent: PrimeValidationRunIntentV2,
            mutation: PrimeValidationDriverV2OuterJournalMechanicsMutation
                = .canonical
        ) throws -> PrimeValidationDriverV2OuterJournalMechanicsFacade {
            let working = try fixture.makeDirectory(
                "outer-mechanics-working-" + UUID().uuidString
            )
            let baseDescriptor = Darwin.open(
                fixture.base.path,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
            guard baseDescriptor >= 3 else {
                if baseDescriptor >= 0 { _ = Darwin.close(baseDescriptor) }
                throw FixtureError.invalid("outer_mechanics_base_open")
            }
            defer { _ = Darwin.close(baseDescriptor) }
            let workingDescriptor = Darwin.open(
                working.path,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
            guard workingDescriptor >= 3 else {
                if workingDescriptor >= 0 {
                    _ = Darwin.close(workingDescriptor)
                }
                throw FixtureError.invalid("outer_mechanics_working_open")
            }
            defer { _ = Darwin.close(workingDescriptor) }
            return try PrimeValidationDriverV2OuterJournalMechanicsFacade(
                heldBaseDirectoryDescriptor: baseDescriptor,
                heldWorkingDirectoryDescriptor: workingDescriptor,
                intent: intent,
                mutation: mutation
            )
        }

        func outerDurableSnapshot(
            fixture: Fixture
        ) throws -> (
            bytes: [String: Data],
            vnodes: [String: String]
        ) {
            let journalRoot = fixture.base.appendingPathComponent(
                "gate-e-shot-governor-journal",
                isDirectory: true
            )
            let names = [
                "00-capsule.json",
                "01-supervisor-request.json",
                "02-outer-start.json",
                "03-outer-terminal.json",
                "../outer-supervisor-stdout.bin",
                "../outer-supervisor-stderr.bin",
            ]
            var bytes = [String: Data]()
            var vnodes = [String: String]()
            for name in names {
                let url = journalRoot.appendingPathComponent(name)
                    .standardizedFileURL
                var status = stat()
                guard lstat(url.path, &status) == 0 else {
                    throw FixtureError.invalid(
                        "outer_durable_snapshot_\(name)"
                    )
                }
                bytes[name] = try Data(contentsOf: url)
                vnodes[name] =
                    "\(UInt64(bitPattern: Int64(status.st_dev))):" +
                    "\(UInt64(status.st_ino))"
            }
            return (bytes, vnodes)
        }

        let outerFacade = try outerMechanicsFacade(
            fixture: fixture,
            intent: transfer.intent
        )
        let outer = try outerFacade.consume()
        XCTAssertEqual(
            outer.orderedLeaves.map(\.leaf),
            [
                "00-capsule.json",
                "01-supervisor-request.json",
                "02-outer-start.json",
                "03-outer-terminal.json",
            ]
        )
        XCTAssertEqual(
            Set(outer.orderedLeaves.map {
                "\($0.deviceID):\($0.inode)"
            }).count,
            4
        )
        XCTAssertEqual(outer.rootLinkCount, 6)
        XCTAssertTrue(outer.requestReachedFiniteEOF)
        XCTAssertEqual(outer.standardOutputByteCount, 0)
        XCTAssertTrue(outer.standardOutputReachedEOF)
        XCTAssertFalse(outer.standardOutputOverflowed)
        XCTAssertEqual(outer.standardErrorByteCount, 65_536)
        XCTAssertTrue(outer.standardErrorReachedEOF)
        XCTAssertTrue(outer.standardErrorOverflowed)
        XCTAssertTrue(outer.retainedTerminalRevalidated)
        XCTAssertEqual(outer.spawnedProcessCount, 0)
        XCTAssertEqual(outer.gitOrSwiftProbeCount, 0)
        XCTAssertFalse(outer.productionStatusEligible)
        XCTAssertEqual(outer.authorityVector, "00000000")
        try outerFacade.revalidateRetainedTerminal()
        XCTAssertThrowsError(try outerFacade.consume())
        XCTAssertThrowsError(try outerFacade.consume())
        XCTAssertTrue(outerFacade.permanentlyPoisoned)
        try outerFacade.revalidateRetainedTerminal()

        // A second owner cannot absorb an already-published durable root or
        // its capture outputs as a fresh baseline.
        let durableBeforeSecondOwner = try outerDurableSnapshot(
            fixture: fixture
        )
        let existingOutputsFacade = try outerMechanicsFacade(
            fixture: fixture,
            intent: transfer.intent
        )
        XCTAssertThrowsError(try existingOutputsFacade.consume())
        XCTAssertTrue(existingOutputsFacade.permanentlyPoisoned)
        let durableAfterSecondOwner = try outerDurableSnapshot(
            fixture: fixture
        )
        XCTAssertEqual(
            durableAfterSecondOwner.bytes,
            durableBeforeSecondOwner.bytes
        )
        XCTAssertEqual(
            durableAfterSecondOwner.vnodes,
            durableBeforeSecondOwner.vnodes
        )

        for mutation in [
            PrimeValidationDriverV2OuterJournalMechanicsMutation.trailingLF,
            .leadingWhitespace,
            .oversized,
        ] {
            let rejectedFixture = try Fixture()
            defer { rejectedFixture.cleanup() }
            let rejectedGuarded = try preparedGuard(for: rejectedFixture)
            let rejectedIntent = try roleTransferInputs(
                fixture: rejectedFixture,
                guarded: rejectedGuarded
            ).intent
            let rejected = try outerMechanicsFacade(
                fixture: rejectedFixture,
                intent: rejectedIntent,
                mutation: mutation
            )
            XCTAssertThrowsError(try rejected.consume())
            XCTAssertTrue(rejected.permanentlyPoisoned)
            XCTAssertFalse(
                FileManager.default.fileExists(
                    atPath: rejectedFixture.base.appendingPathComponent(
                        "gate-e-shot-governor-journal"
                    ).path
                )
            )
        }

        let concurrentFixture = try Fixture()
        defer { concurrentFixture.cleanup() }
        let concurrentGuarded = try preparedGuard(for: concurrentFixture)
        let concurrentIntent = try roleTransferInputs(
            fixture: concurrentFixture,
            guarded: concurrentGuarded
        ).intent
        let concurrentFacade = try outerMechanicsFacade(
            fixture: concurrentFixture,
            intent: concurrentIntent
        )
        let outerRace = GateEOuterJournalMechanicsRace()
        let outerReady = DispatchGroup()
        let outerDone = DispatchGroup()
        let outerStart = DispatchSemaphore(value: 0)
        let outerQueue = DispatchQueue(
            label: "prime.validation.gate-e-outer-mechanics-race",
            attributes: .concurrent
        )
        for _ in 0 ..< 2 {
            outerReady.enter()
            outerDone.enter()
            outerQueue.async {
                outerReady.leave()
                outerStart.wait()
                outerRace.record { try concurrentFacade.consume() }
                outerDone.leave()
            }
        }
        XCTAssertEqual(outerReady.wait(timeout: .now() + 5), .success)
        outerStart.signal()
        outerStart.signal()
        XCTAssertEqual(outerDone.wait(timeout: .now() + 30), .success)
        XCTAssertEqual(outerRace.values.count, 1)
        XCTAssertEqual(outerRace.errors.count, 1)
        XCTAssertTrue(concurrentFacade.permanentlyPoisoned)
        outerRace.releaseValues()

        let terminalCollisionFixture = try Fixture()
        defer { terminalCollisionFixture.cleanup() }
        let terminalCollisionGuarded = try preparedGuard(
            for: terminalCollisionFixture
        )
        let terminalCollisionIntent = try roleTransferInputs(
            fixture: terminalCollisionFixture,
            guarded: terminalCollisionGuarded
        ).intent
        let terminalCollisionFacade = try outerMechanicsFacade(
            fixture: terminalCollisionFixture,
            intent: terminalCollisionIntent,
            mutation: .terminalCollision
        )
        XCTAssertThrowsError(try terminalCollisionFacade.consume())
        XCTAssertEqual(terminalCollisionFacade.failurePrefixCount, 3)
        XCTAssertTrue(terminalCollisionFacade.permanentlyPoisoned)
        XCTAssertEqual(
            Set(
                try FileManager.default.contentsOfDirectory(
                    atPath: terminalCollisionFixture.base
                        .appendingPathComponent(
                            "gate-e-shot-governor-journal"
                        ).path
                )
            ),
            Set([
                "00-capsule.json",
                "01-supervisor-request.json",
                "02-outer-start.json",
                "03-outer-terminal.json",
            ])
        )
        let collisionTerminal = terminalCollisionFixture.base
            .appendingPathComponent(
                "gate-e-shot-governor-journal/03-outer-terminal.json"
            )
        let collisionBytesBefore = try Data(contentsOf: collisionTerminal)
        var collisionStatusBefore = stat()
        XCTAssertEqual(
            lstat(collisionTerminal.path, &collisionStatusBefore),
            0
        )
        XCTAssertThrowsError(try terminalCollisionFacade.consume())
        XCTAssertEqual(terminalCollisionFacade.failurePrefixCount, 3)
        let collisionBytesAfter = try Data(contentsOf: collisionTerminal)
        var collisionStatusAfter = stat()
        XCTAssertEqual(
            lstat(collisionTerminal.path, &collisionStatusAfter),
            0
        )
        XCTAssertEqual(collisionBytesAfter, collisionBytesBefore)
        XCTAssertEqual(collisionStatusAfter.st_dev, collisionStatusBefore.st_dev)
        XCTAssertEqual(collisionStatusAfter.st_ino, collisionStatusBefore.st_ino)

        let reboundFixture = try Fixture()
        defer { reboundFixture.cleanup() }
        let reboundGuarded = try preparedGuard(for: reboundFixture)
        let reboundIntent = try roleTransferInputs(
            fixture: reboundFixture,
            guarded: reboundGuarded
        ).intent
        let reboundFacade = try outerMechanicsFacade(
            fixture: reboundFixture,
            intent: reboundIntent,
            mutation: .terminalSameBytesNewInode
        )
        XCTAssertThrowsError(try reboundFacade.consume())
        XCTAssertEqual(reboundFacade.failurePrefixCount, 4)
        XCTAssertTrue(reboundFacade.permanentlyPoisoned)
        let rebound = try XCTUnwrap(reboundFacade.reboundObservation)
        XCTAssertTrue(rebound.exactBytesEqual)
        XCTAssertEqual(
            rebound.replacementDeviceID,
            rebound.retainedDeviceID
        )
        XCTAssertNotEqual(
            rebound.replacementInode,
            rebound.retainedInode
        )
        XCTAssertThrowsError(try reboundFacade.revalidateRetainedTerminal())

        let failStopDiagnostic = try
            GateESessionFixtureFailStopDiagnosticLeaf(base: fixture.base)
        try failStopDiagnostic.revalidateUnchangedEmpty()
        let sessionFixtureDescriptor = try fixture
            .openPinnedSessionFixtureExecutable()
        defer { _ = Darwin.close(sessionFixtureDescriptor) }
        let workingDescriptor = Darwin.open(
            fixture.workspace.path,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard workingDescriptor >= 3 else {
            if workingDescriptor >= 0 { _ = Darwin.close(workingDescriptor) }
            throw FixtureError.invalid("session_fixture_cwd_open")
        }
        defer { _ = Darwin.close(workingDescriptor) }
        let prepublication = try PrimeValidationDriverV2ShotGovernor
            .exerciseSessionFixtureForTesting(
                heldSessionFixtureDescriptor: sessionFixtureDescriptor,
                heldWorkingDirectoryDescriptor: workingDescriptor,
                heldFailStopDiagnosticDescriptor:
                    failStopDiagnostic.descriptor,
                mode: .prepublicationHeld
            )
        try failStopDiagnostic.revalidateUnchangedEmpty()
        XCTAssertEqual(
            prepublication.supervisorProcessIdentifier,
            prepublication.supervisorSessionIdentifier
        )
        XCTAssertEqual(
            prepublication.supervisorProcessIdentifier,
            prepublication.supervisorProcessGroupIdentifier
        )
        XCTAssertEqual(prepublication.appliedSupervisorSpawnFlags, 0x448c)
        XCTAssertTrue(prepublication.mappedFixtureImageJoined)
        XCTAssertTrue(prepublication.workingDirectoryJoined)
        XCTAssertTrue(prepublication.discoveredDedicatedChildGroup)
        XCTAssertTrue(prepublication.finalSessionEmpty)
        XCTAssertTrue(prepublication.finalGroupsEmpty)
        XCTAssertEqual(
            prepublication.exactSupervisorWait.requestedProcessIdentifier,
            prepublication.exactSupervisorWait.returnedProcessIdentifier
        )

        let orphan = try PrimeValidationDriverV2ShotGovernor
            .exerciseSessionFixtureForTesting(
                heldSessionFixtureDescriptor: sessionFixtureDescriptor,
                heldWorkingDirectoryDescriptor: workingDescriptor,
                heldFailStopDiagnosticDescriptor:
                    failStopDiagnostic.descriptor,
                mode: .orphanTransition
            )
        try failStopDiagnostic.revalidateUnchangedEmpty()
        XCTAssertTrue(
            orphan.discoveredDedicatedChildGroup
                || orphan.acceptedOrphanAlreadyEmpty
        )
        XCTAssertTrue(orphan.finalSessionEmpty)
        XCTAssertTrue(orphan.finalGroupsEmpty)
        XCTAssertEqual(
            orphan.exactSupervisorWait.requestedProcessIdentifier,
            orphan.exactSupervisorWait.returnedProcessIdentifier
        )
    }

    @available(macOS 26.0, *)
    func testGateEHeldProjectionRejectsSetSymlinkGitlinkAndVnodeDrift()
        throws
    {
        let projectionFixture = try Fixture()
        defer { projectionFixture.cleanup() }
        let projectionGuarded = try preparedGuard(for: projectionFixture)
        let projectionImage = try boundTestImage(for: projectionGuarded)
        XCTAssertFalse(projectionImage.productionSupervisorImageEligible)
        let projectionContext = try roleTransferInputs(
            fixture: projectionFixture,
            guarded: projectionGuarded
        ).context
        let projectionFacade = try projectionImage
            .transferDriverV2RoleFacade(context: projectionContext)
        let projection = try projectionFacade
            .exerciseFixedProbeHeldProjectionForTesting()
        XCTAssertGreaterThan(projection.primeHeldEntryCount, 0)
        XCTAssertGreaterThan(projection.companionHeldEntryCount, 0)
        XCTAssertEqual(
            projection.combinedSourceWatcherDescriptorCountBefore,
            45
        )
        XCTAssertEqual(
            projection.combinedSourceWatcherDescriptorCountAfter,
            45
        )
        XCTAssertEqual(projection.primeHeldEntriesSHA256.count, 64)
        XCTAssertEqual(projection.companionHeldEntriesSHA256.count, 64)
        XCTAssertTrue(projection.allProjectedEntriesRegular)
        XCTAssertTrue(projection.regularTreeAccepted)
        XCTAssertTrue(projection.symbolicLinkTreeRejected)
        XCTAssertTrue(projection.gitlinkTreeRejected)
        XCTAssertEqual(projection.spawnedChildCount, 0)
        XCTAssertEqual(projectionFacade.processExecutionObservation, .unobserved)
        let replay = try projectionFacade
            .exerciseFixedProbeHeldProjectionForTesting()
        XCTAssertEqual(
            replay.primeHeldEntryCount,
            projection.primeHeldEntryCount
        )
        XCTAssertEqual(
            replay.companionHeldEntryCount,
            projection.companionHeldEntryCount
        )
        XCTAssertEqual(
            replay.primeHeldEntriesSHA256,
            projection.primeHeldEntriesSHA256
        )
        XCTAssertEqual(
            replay.companionHeldEntriesSHA256,
            projection.companionHeldEntriesSHA256
        )
        XCTAssertEqual(
            replay.combinedSourceWatcherDescriptorCountAfter,
            projection.combinedSourceWatcherDescriptorCountAfter
        )
        XCTAssertEqual(replay.spawnedChildCount, 0)

        let original = projectionFixture.prime.appendingPathComponent(
            "README.md"
        )
        let saved = projectionFixture.base.appendingPathComponent(
            "README.held-projection-original"
        )
        let originalBytes = try Data(contentsOf: original)
        try FileManager.default.moveItem(at: original, to: saved)
        try originalBytes.write(to: original)
        XCTAssertThrowsError(
            try projectionFacade
                .exerciseFixedProbeHeldProjectionForTesting()
        )
        XCTAssertEqual(projectionFacade.continuityState, .poisoned)
        XCTAssertThrowsError(
            try projectionFacade
                .exerciseFixedProbeHeldProjectionForTesting()
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned
            )
        }

        let bytes = Data("held\n".utf8)
        let path = Data("Sources/Held.swift".utf8)
        let identity = PrimeValidationDriverV2TrackedTreeHeldIdentity(
            deviceID: 91,
            inode: 92,
            ownerUserID: 501,
            ownerGroupID: 20,
            permissionMode: 0o644,
            linkCount: 1,
            byteCount: UInt64(bytes.count),
            posixFileType: .regularFile
        )
        let held = try PrimeValidationDriverV2TrackedTreeHeldEntry(
            validatingRawPathBytes: path,
            kind: .regularFile,
            openedIdentity: identity,
            postReadDescriptorIdentity: identity,
            namedPathReboundIdentity: identity,
            contents: bytes
        )
        var raw = Data("100644 blob \(held.gitBlobSHA1)\t".utf8)
        raw.append(path)
        raw.append(0)
        let accepted = try PrimeValidationTrackedTreeManifestBuilderV2
            .repository(
                objectFormatOutput: Data("sha1\n".utf8),
                rawTreeOutput: raw,
                heldEntries: [held]
            )
        XCTAssertEqual(accepted.manifest.entries.count, 1)
        XCTAssertThrowsError(
            try PrimeValidationTrackedTreeManifestBuilderV2.repository(
                objectFormatOutput: Data("sha1\n".utf8),
                rawTreeOutput: raw,
                heldEntries: []
            )
        )
        XCTAssertThrowsError(
            try PrimeValidationTrackedTreeManifestBuilderV2.repository(
                objectFormatOutput: Data("sha1\n".utf8),
                rawTreeOutput: raw,
                heldEntries: [held, held]
            )
        )
        let secondPath = Data("Tests/HeldTests.swift".utf8)
        let secondIdentity = PrimeValidationDriverV2TrackedTreeHeldIdentity(
            deviceID: identity.deviceID,
            inode: identity.inode + 2,
            ownerUserID: identity.ownerUserID,
            ownerGroupID: identity.ownerGroupID,
            permissionMode: identity.permissionMode,
            linkCount: identity.linkCount,
            byteCount: identity.byteCount,
            posixFileType: .regularFile
        )
        let secondHeld = try PrimeValidationDriverV2TrackedTreeHeldEntry(
            validatingRawPathBytes: secondPath,
            kind: .regularFile,
            openedIdentity: secondIdentity,
            postReadDescriptorIdentity: secondIdentity,
            namedPathReboundIdentity: secondIdentity,
            contents: bytes
        )
        var orderedRaw = raw
        orderedRaw.append(
            Data("100644 blob \(secondHeld.gitBlobSHA1)\t".utf8)
        )
        orderedRaw.append(secondPath)
        orderedRaw.append(0)
        XCTAssertThrowsError(
            try PrimeValidationTrackedTreeManifestBuilderV2.repository(
                objectFormatOutput: Data("sha1\n".utf8),
                rawTreeOutput: orderedRaw,
                heldEntries: [secondHeld, held]
            )
        )

        let rebound = PrimeValidationDriverV2TrackedTreeHeldIdentity(
            deviceID: identity.deviceID,
            inode: identity.inode + 1,
            ownerUserID: identity.ownerUserID,
            ownerGroupID: identity.ownerGroupID,
            permissionMode: identity.permissionMode,
            linkCount: identity.linkCount,
            byteCount: identity.byteCount,
            posixFileType: .regularFile
        )
        XCTAssertThrowsError(
            try PrimeValidationDriverV2TrackedTreeHeldEntry(
                validatingRawPathBytes: path,
                kind: .regularFile,
                openedIdentity: identity,
                postReadDescriptorIdentity: identity,
                namedPathReboundIdentity: rebound,
                contents: bytes
            )
        )

        let symlinkBytes = Data("../Held.swift".utf8)
        let symlinkIdentity = PrimeValidationDriverV2TrackedTreeHeldIdentity(
            deviceID: 91,
            inode: 93,
            ownerUserID: 501,
            ownerGroupID: 20,
            permissionMode: 0o777,
            linkCount: 1,
            byteCount: UInt64(symlinkBytes.count),
            posixFileType: .symbolicLink
        )
        let symlink = try PrimeValidationDriverV2TrackedTreeHeldEntry(
            validatingRawPathBytes: Data("Sources/link".utf8),
            kind: .symbolicLink,
            openedIdentity: symlinkIdentity,
            postReadDescriptorIdentity: symlinkIdentity,
            namedPathReboundIdentity: symlinkIdentity,
            contents: symlinkBytes
        )
        var symlinkRaw = Data("120000 blob \(symlink.gitBlobSHA1)\t".utf8)
        symlinkRaw.append(symlink.rawPathBytes)
        symlinkRaw.append(0)
        _ = try PrimeValidationTrackedTreeManifestBuilderV2.repository(
            objectFormatOutput: Data("sha1\n".utf8),
            rawTreeOutput: symlinkRaw,
            heldEntries: [symlink]
        )
        try PrimeValidationDriverV2FixedProbeSemanticTestSeam
            .requireRegularHeldEntryKinds(
                prime: [held],
                companion: [held]
            )
        XCTAssertThrowsError(
            try PrimeValidationDriverV2FixedProbeSemanticTestSeam
                .requireRegularHeldEntryKinds(
                    prime: [symlink],
                    companion: [held]
                )
        )
        XCTAssertThrowsError(
            try PrimeValidationDriverV2FixedProbeSemanticTestSeam
                .requireRegularHeldEntryKinds(
                    prime: [held],
                    companion: [symlink]
                )
        )

        var gitlink = Data(
            ("160000 commit " + String(repeating: "1", count: 40) + "\t").utf8
        )
        gitlink.append(Data("submodule".utf8))
        gitlink.append(0)
        XCTAssertThrowsError(
            try PrimeValidationTrackedTreeManifestBuilderV2.repository(
                objectFormatOutput: Data("sha1\n".utf8),
                rawTreeOutput: gitlink,
                heldEntries: []
            )
        )
    }

    @available(macOS 26.0, *)
    func testGateELightweightContinuityPoisonsOnEitherRootMutation()
        throws
    {
        try assertGateELightweightEventHistoryPoisons(
            "prime_event_history"
        ) { fixture in
            let transient = fixture.prime.appendingPathComponent(
                "Sources/PrimeCore/GateETransient.swift"
            )
            try Data("transient\n".utf8).write(to: transient)
            try FileManager.default.removeItem(at: transient)
        }
        try assertGateELightweightEventHistoryPoisons(
            "companion_event_history"
        ) { fixture in
            let transient = fixture.companion.appendingPathComponent(
                "Sources/GateETransient.swift"
            )
            try Data("transient\n".utf8).write(to: transient)
            try FileManager.default.removeItem(at: transient)
        }
    }

    @available(macOS 26.0, *)
    func testGateEXCTestHostCannotConstructProductionFixedProbeBinding()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        let imageData = try Data(
            contentsOf: URL(
                fileURLWithPath:
                    guarded.currentProcessExecutable.canonicalAbsolutePath
            )
        )
        let intent = try fixture.makeIntent(
            guarded: guarded,
            driverImageData: imageData
        )
        XCTAssertThrowsError(
            try PrimeValidationDriverV2SupervisorImageBridge.bind(
                intent: intent,
                guardedPreExecutor: guarded
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .rejected("driver_v2_supervisor_executable_role")
            )
        }
        XCTAssertEqual(guarded.guardState, .poisoned)
        XCTAssertEqual(guarded.authorityCeiling, .poisonedNoAuthority)
        XCTAssertEqual(
            guarded.missingAuthorities,
            PrimeValidationSwiftPMMissingAuthority.allCases
        )
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath:
                    fixture.workspace.path +
                    ".driver-v2-gate-e-journal"
            )
        )

        // Even a package-internal test-host facade cannot enter the public
        // production transition. Rejection occurs before the executor can
        // open a journal or launch any fixed child.
        let directFixture = try Fixture()
        defer { directFixture.cleanup() }
        let directGuarded = try preparedGuard(for: directFixture)
        let directImage = try boundTestImage(for: directGuarded)
        XCTAssertFalse(directImage.productionSupervisorImageEligible)
        let directContext = try roleTransferInputs(
            fixture: directFixture,
            guarded: directGuarded
        ).context
        let directFacade = try directImage.transferDriverV2RoleFacade(
            context: directContext
        )
        XCTAssertThrowsError(
            try directFacade.observeFixedGitAndSwiftProbes()
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .rejected("driver_v2_fixed_probe_production_image")
            )
        }
        XCTAssertEqual(directFacade.continuityState, .poisoned)
        XCTAssertEqual(
            directFacade.processExecutionObservation,
            .unobserved
        )
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath:
                    directFixture.workspace.path +
                    ".driver-v2-gate-e-journal"
            )
        )

        let binding = try gateEProductionSource(
            "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverCore/" +
                "PrimeValidationDriverV2FixedProbeBinding.swift"
        )
        XCTAssertTrue(binding.contains("raw.productionSupervisorImageEligible"))
        XCTAssertTrue(binding.contains("boundLifetime.productionSupervisorImageEligible"))
        XCTAssertFalse(binding.contains("allowRootOwnedCurrentProcessForTesting"))
        let facadeSource = try gateEProductionSource(
            "Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift"
        )
        for seam in [
            "exerciseFixedProbeJournalMechanicsForTesting()",
            "exerciseFixedProbeHeldProjectionForTesting()",
            "revalidateFixedProbeLightweightContinuityForTesting()",
        ] {
            let start = try XCTUnwrap(facadeSource.range(of: seam))
            let next = try XCTUnwrap(
                facadeSource.range(
                    of: "\n    ///",
                    range: start.upperBound ..< facadeSource.endIndex
                )
            )
            let body = facadeSource[start.lowerBound ..< next.lowerBound]
            XCTAssertTrue(
                body.contains("!value.productionSupervisorImageEligible"),
                seam
            )
        }

        let supervisorSource = try gateEProductionSource(
            "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverV2Supervisor/main.swift"
        )
        let admissionSiteStatuses = [
            ("companionDeclaration", "admissionCompanionDeclaration", 74),
            ("primeRepository", "admissionPrimeRepository", 75),
            ("workspaceRoot", "admissionWorkspaceRoot", 76),
            (
                "workspacePrivateAndEmpty",
                "admissionWorkspacePrivateAndEmpty",
                77
            ),
            ("evidenceRoot", "admissionEvidenceRoot", 78),
            (
                "evidencePrivateAndEmpty",
                "admissionEvidencePrivateAndEmpty",
                79
            ),
            ("companionRepository", "admissionCompanionRepository", 80),
            ("leaseDirectory", "admissionLeaseDirectory", 81),
            (
                "leasePrivateAndEmpty",
                "admissionLeasePrivateAndEmpty",
                82
            ),
            ("rootTopology", "admissionRootTopology", 83),
            ("exclusiveLease", "admissionExclusiveLease", 84),
            ("postLeaseDirectory", "admissionPostLeaseDirectory", 85),
            ("sourceSnapshot", "admissionSourceSnapshot", 86),
            (
                "packageResolvedBinding",
                "admissionPackageResolvedBinding",
                87
            ),
            (
                "primeSourceIdentitySnapshot",
                "admissionPrimeSourceIdentitySnapshot",
                88
            ),
            (
                "companionContentSnapshot",
                "admissionCompanionContentSnapshot",
                89
            ),
            ("heldToolchain", "admissionHeldToolchain", 90),
        ]
        XCTAssertEqual(admissionSiteStatuses.count, 17)
        XCTAssertEqual(
            Set(admissionSiteStatuses.map { $0.0 }).count,
            17
        )
        XCTAssertEqual(
            Set(admissionSiteStatuses.map { $0.1 }).count,
            17
        )
        XCTAssertEqual(
            Set(admissionSiteStatuses.map { $0.2 }).count,
            17
        )
        XCTAssertEqual(
            admissionSiteStatuses.map { $0.2 },
            Array(74 ... 90)
        )
        let phaseStatuses = [
            "static let transport: Int32 = 65",
            "static let developerDirectory: Int32 = 66",
            "static let prerequisiteAdmission: Int32 = 71",
        ] + admissionSiteStatuses.map {
            "static let \($0.1): Int32 = \($0.2)"
        } + [
            "static let prerequisiteConsume: Int32 = 72",
            "static let guardPreparation: Int32 = 73",
            "static let supervisorImage: Int32 = 67",
            "static let fixedProbes: Int32 = 68",
            "static let finalRevalidation: Int32 = 69",
        ]
        let phaseStatusOffsets = try phaseStatuses.map { value in
            XCTAssertEqual(
                supervisorSource.components(separatedBy: value).count - 1,
                1,
                value
            )
            return try XCTUnwrap(supervisorSource.range(of: value))
                .lowerBound
        }
        XCTAssertEqual(phaseStatusOffsets, phaseStatusOffsets.sorted())
        let phaseBoundaries = [
            "request = try requestFromStandardInput()",
            "developerDirectoryURL = try developerDirectory(",
            "admission = try",
            "prerequisite = try admission.consumePrerequisites()",
            "guarded = try prerequisite.prepareGuardedPreExecutor()",
            "let bound: PrimeValidationDriverV2SupervisorImageCapability",
            "guard #available(macOS 26.0, *)",
            "try fixedProbeBinding.revalidate()",
        ]
        let phaseBoundaryOffsets = try phaseBoundaries.map {
            try XCTUnwrap(supervisorSource.range(of: $0)).lowerBound
        }
        XCTAssertEqual(
            phaseBoundaryOffsets,
            phaseBoundaryOffsets.sorted()
        )
        for (reference, count) in [
            (".transport", 1),
            (".developerDirectory", 1),
            (".prerequisiteAdmission", 1),
            (".prerequisiteConsume", 1),
            (".guardPreparation", 1),
            (".supervisorImage", 1),
            (".fixedProbes", 2),
            (".finalRevalidation", 1),
        ] {
            XCTAssertEqual(
                supervisorSource.components(
                    separatedBy: reference
                ).count - 1,
                count,
                reference
            )
        }
        for (_, statusName, _) in admissionSiteStatuses {
            let reference = ".\(statusName)"
            XCTAssertEqual(
                supervisorSource.components(
                    separatedBy: reference
                ).count - 1,
                1,
                reference
            )
        }
        let admissionMapperSource = try slice(
            supervisorSource,
            from:
                "private static func prerequisiteAdmissionExitStatus(",
            through: "private static func requestFromStandardInput() throws"
        )
        XCTAssertTrue(
            admissionMapperSource.contains(
                "error as?\n                PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite"
            )
        )
        let normalizedAdmissionMapper = admissionMapperSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        XCTAssertTrue(
            normalizedAdmissionMapper.contains(
                "guard let site = error as? " +
                    "PrimeValidationSwiftPMBuildInventoryAdmissionRejectionSite " +
                    "else { return nil }"
            )
        )
        var mapperCursor = admissionMapperSource.startIndex
        for (siteName, statusName, _) in admissionSiteStatuses {
            let siteRange = try XCTUnwrap(
                admissionMapperSource.range(
                    of: "case .\(siteName):",
                    range: mapperCursor ..< admissionMapperSource.endIndex
                )
            )
            let statusRange = try XCTUnwrap(
                admissionMapperSource.range(
                    of: ".\(statusName)",
                    range:
                        siteRange.upperBound ..<
                        admissionMapperSource.endIndex
                )
            )
            XCTAssertLessThan(siteRange.lowerBound, statusRange.lowerBound)
            mapperCursor = statusRange.upperBound
        }
        XCTAssertFalse(admissionMapperSource.contains("String(describing:"))
        XCTAssertFalse(admissionMapperSource.contains("localizedDescription"))
        XCTAssertFalse(admissionMapperSource.contains("NSError"))
        XCTAssertFalse(admissionMapperSource.contains("errno"))
        let admissionCatchSource = try slice(
            supervisorSource,
            from: "        let admission:",
            through: "        let prerequisite:"
        )
        let normalizedAdmissionCatch = admissionCatchSource
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        let normalizedCatchStart = try XCTUnwrap(
            normalizedAdmissionCatch.range(
                of: "} catch {",
                options: .backwards
            )
        ).lowerBound
        XCTAssertEqual(
            String(normalizedAdmissionCatch[normalizedCatchStart...]),
            "} catch { let status = " +
                "prerequisiteAdmissionExitStatus( for: error ) ?? " +
                "PrimeValidationDriverV2SupervisorExitStatus " +
                ".prerequisiteAdmission Darwin._exit( status ) }"
        )
        XCTAssertEqual(
            admissionCatchSource.components(
                separatedBy: "prerequisiteAdmissionExitStatus("
            ).count - 1,
            1
        )
        XCTAssertEqual(
            admissionCatchSource.components(
                separatedBy: ".prerequisiteAdmission"
            ).count - 1,
            1
        )
        XCTAssertEqual(
            admissionCatchSource.components(
                separatedBy: "Darwin._exit("
            ).count - 1,
            1
        )
        XCTAssertTrue(
            admissionCatchSource.contains(
                "Darwin._exit(\n                status\n            )"
            )
        )
        let exitReferenceSequence = [
            ".transport",
            ".developerDirectory",
            ".prerequisiteAdmission",
            ".prerequisiteConsume",
            ".guardPreparation",
            ".supervisorImage",
            ".fixedProbes",
            ".fixedProbes",
            ".finalRevalidation",
        ]
        var exitReferenceCursor = supervisorSource.startIndex
        let exitReferenceOffsets = try exitReferenceSequence.map {
            reference in
            let range = try XCTUnwrap(
                supervisorSource.range(
                    of: reference,
                    range: exitReferenceCursor ..< supervisorSource.endIndex
                )
            )
            exitReferenceCursor = range.upperBound
            return range.lowerBound
        }
        XCTAssertEqual(
            exitReferenceOffsets,
            exitReferenceOffsets.sorted()
        )
        XCTAssertEqual(
            supervisorSource.components(
                separatedBy: "Darwin._exit("
            ).count - 1,
            exitReferenceSequence.count
        )
        XCTAssertEqual(
            supervisorSource.components(
                separatedBy: "} catch {"
            ).count - 1,
            8
        )
        XCTAssertEqual(
            supervisorSource.components(
                separatedBy: "catch"
            ).count - 1,
            8
        )
        XCTAssertLessThan(phaseBoundaryOffsets[0], exitReferenceOffsets[0])
        XCTAssertLessThan(exitReferenceOffsets[0], phaseBoundaryOffsets[1])
        XCTAssertLessThan(phaseBoundaryOffsets[1], exitReferenceOffsets[1])
        XCTAssertLessThan(exitReferenceOffsets[1], phaseBoundaryOffsets[2])
        XCTAssertLessThan(phaseBoundaryOffsets[2], exitReferenceOffsets[2])
        XCTAssertLessThan(exitReferenceOffsets[2], phaseBoundaryOffsets[3])
        XCTAssertLessThan(phaseBoundaryOffsets[3], exitReferenceOffsets[3])
        XCTAssertLessThan(exitReferenceOffsets[3], phaseBoundaryOffsets[4])
        XCTAssertLessThan(phaseBoundaryOffsets[4], exitReferenceOffsets[4])
        XCTAssertLessThan(exitReferenceOffsets[4], phaseBoundaryOffsets[5])
        XCTAssertLessThan(phaseBoundaryOffsets[5], exitReferenceOffsets[5])
        XCTAssertLessThan(exitReferenceOffsets[5], phaseBoundaryOffsets[6])
        XCTAssertLessThan(phaseBoundaryOffsets[6], exitReferenceOffsets[6])
        XCTAssertLessThan(exitReferenceOffsets[6], exitReferenceOffsets[7])
        XCTAssertLessThan(exitReferenceOffsets[7], phaseBoundaryOffsets[7])
        XCTAssertLessThan(phaseBoundaryOffsets[7], exitReferenceOffsets[8])
        for conserved in [
            "guard CommandLine.arguments.count == 1",
            "private static let maximumRequestByteCount = 256 * 1024",
            "UInt64 = 5_000_000_000",
            "let requestData = try readCanonicalRequest()",
            "PrimeCanonicalJSON.decode(",
            "try request.validate()",
            "STDIN_FILENO",
            "if count == 0 { break }",
            "guard data.count <= maximumRequestByteCount - count",
        ] {
            XCTAssertTrue(supervisorSource.contains(conserved), conserved)
        }
        XCTAssertFalse(supervisorSource.contains("Darwin._exit(70)"))
        XCTAssertFalse(supervisorSource.contains("Darwin._exit(0)"))
        XCTAssertFalse(supervisorSource.contains("STDOUT_FILENO"))
        XCTAssertFalse(supervisorSource.contains("STDERR_FILENO"))
        XCTAssertFalse(supervisorSource.contains("ProcessInfo"))
        XCTAssertFalse(supervisorSource.contains(".environment"))
        XCTAssertFalse(supervisorSource.contains("print("))
        XCTAssertFalse(supervisorSource.contains("String(describing:"))
        XCTAssertFalse(supervisorSource.contains("catch let"))
    }

    func testGateEReleaseSupervisorRequiresLiveFourAuthorityBindingBeforeExit()
        throws
    {
        for status in Int32(65) ... Int32(90) {
            XCTAssertNotEqual(
                gateEReleasePhaseLabel(status),
                "unknown",
                "historical supervisor status \(status)"
            )
        }
        throw XCTSkip(
            "retired: production Gate E is now one direct local governor shot"
        )
        #if DEBUG
            throw XCTSkip("Gate E production proof is Release-only")
        #else
            let environment = ProcessInfo.processInfo.environment
            let primePath = try XCTUnwrap(environment[
                "PRIME_DRIVER_V2_GATE_E_PRIME_ROOT"
            ], "PRIME_DRIVER_V2_GATE_E_PRIME_ROOT is required")
            let companionPath = try XCTUnwrap(environment[
                "PRIME_PMHNP_COMPANION_ROOT"
            ], "PRIME_PMHNP_COMPANION_ROOT is required")
            guard primePath.hasPrefix("/"),
                  companionPath.hasPrefix("/") else {
                throw FixtureError.invalid("gate_e_release_clone_paths")
            }
            let prime = URL(
                fileURLWithPath: primePath,
                isDirectory: true
            ).resolvingSymlinksInPath().standardizedFileURL
            let companion = URL(
                fileURLWithPath: companionPath,
                isDirectory: true
            ).resolvingSymlinksInPath().standardizedFileURL
            let snapshot = try PrimeSwiftSourceProvenance.capture(
                at: prime,
                requiredRelativePaths: [
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2FixedProbeExecutor.swift",
                    "Tests/PrimeValidationWorkflow/Sources/" +
                        "PrimeValidationWorkflowDriverCore/" +
                        "PrimeValidationDriverV2FixedProbeBinding.swift",
                ]
            )

            var nestedRoot = URL(fileURLWithPath: #filePath)
            for _ in 0 ..< 3 { nestedRoot.deleteLastPathComponent() }
            let supervisor = nestedRoot.appendingPathComponent(
                ".build/arm64-apple-macosx/release/" +
                    "PrimeValidationWorkflowDriverV2Supervisor"
            ).resolvingSymlinksInPath().standardizedFileURL
            let supervisorData = try Data(contentsOf: supervisor)
            guard !supervisorData.isEmpty else {
                throw FixtureError.invalid("gate_e_supervisor_image")
            }

            let base = URL(
                fileURLWithPath:
                    "/private/tmp/prime-driver-v2-gate-e-release-" +
                    snapshot.sourceIdentitySHA256,
                isDirectory: true
            )
            if Darwin.mkdir(base.path, mode_t(0o700)) != 0 {
                let creationError = errno
                let disposition = creationError == EEXIST
                    ? "occupied"
                    : "create_" + String(creationError)
                throw FixtureError.invalid(
                    "gate_e_release_root_" + disposition +
                        "_base_" + base.path
                )
            }
            var baseStatus = stat()
            guard lstat(base.path, &baseStatus) == 0,
                  baseStatus.st_mode & mode_t(S_IFMT)
                    == mode_t(S_IFDIR),
                  baseStatus.st_mode & mode_t(0o7777) == 0o700,
                  baseStatus.st_uid == Darwin.geteuid(),
                  baseStatus.st_nlink == 2 else {
                throw FixtureError.invalid(
                    "gate_e_release_root_metadata_base_" + base.path
                )
            }
            let workspace = base.appendingPathComponent(
                "workspace",
                isDirectory: true
            )
            let evidence = base.appendingPathComponent(
                "evidence",
                isDirectory: true
            )
            let lease = base.appendingPathComponent(
                "lease",
                isDirectory: true
            )
            let journal = URL(
                fileURLWithPath:
                    workspace.path + ".driver-v2-gate-e-journal",
                isDirectory: true
            )
            for directory in [workspace, evidence, lease, journal] {
                try makePrivateDirectory(directory)
            }

            let roots = PrimeValidationDriverRootLayoutV2(
                repositoryRoot: try gateERootBinding(prime),
                companionRoot: try gateERootBinding(companion),
                workspaceRoot: try gateERootBinding(workspace),
                evidenceRoot: try gateERootBinding(evidence),
                scratchRelativePath: "root-release-build",
                cacheRelativePath: "cache",
                configRelativePath: "config",
                securityRelativePath: "security",
                clangModuleCacheRelativePath: "clang-module-cache",
                homeRelativePath: "home",
                swiftPMModuleCacheRelativePath: "swiftpm-module-cache",
                temporaryRelativePath: "temporary",
                outputRelativePath: "output"
            )
            let sourceData = try PrimeCanonicalJSON.encode(snapshot)
            let packageLockData = try Data(
                contentsOf: prime.appendingPathComponent("Package.resolved")
            )
            let swift = URL(
                fileURLWithPath:
                    Fixture.developerPath +
                    "/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift"
            ).standardizedFileURL
            let swiftData = try Data(contentsOf: swift)
            let metallib = PrimeValidationRequiredMetallibV2(
                relativePath:
                    "root-release-build/arm64-apple-macosx/release/" +
                    "mlx-swift_Cmlx.bundle/Contents/Resources/" +
                    "default.metallib",
                content: .init(data: Data("gate-e-metallib-pin".utf8))
            )
            let intent = PrimeValidationRunIntentV2(
                runID:
                    "gate-e-release-fixed-probes-" +
                    snapshot.sourceIdentitySHA256,
                roots: roots,
                sourceSnapshot: .init(data: sourceData),
                packageLock: .init(data: packageLockData),
                driverExecutable: .init(
                    absolutePath: supervisor.path,
                    content: .init(data: supervisorData)
                ),
                swiftExecutable: .init(
                    absolutePath: swift.path,
                    content: .init(data: swiftData)
                ),
                companionCommit:
                    PrimeValidationRunIntentV2.requiredCompanionCommit,
                requiredPinnedMetallib: metallib,
                baseline: .init(),
                phaseBudgets:
                    PrimeValidationExecutorAdmissionPolicyV2
                    .frozenV1.phaseBudgets,
                environmentPolicy: .make(
                    roots: roots,
                    pinnedMetallib: metallib
                ),
                optionalSkipPolicySHA256:
                    try PrimeValidationOptionalSkipPolicy.identitySHA256()
            )
            try intent.validate()
            let request = PrimeValidationDriverV2SupervisorLaunchRequestV1(
                intent: intent,
                leaseDirectoryAbsolutePath: lease.path
            )
            try request.validate()
            let requestData = try PrimeCanonicalJSON.encode(request)
            guard requestData.count <= 256 * 1024 else {
                throw FixtureError.invalid(
                    "gate_e_release_request_size_base_" + base.path
                )
            }

            let launch: GateEReleaseLaunchObservation
            do {
                launch = try gateELaunchReleaseSupervisor(
                    executable: supervisor,
                    request: requestData,
                    captureRoot: base
                )
            } catch {
                throw FixtureError.invalid(
                    "gate_e_release_outer_launch_base_" + base.path +
                        "_error_" + String(describing: error)
                )
            }
            guard launch.exitStatus == 0 else {
                throw FixtureError.invalid(
                    "gate_e_release_supervisor_exit_" +
                        String(launch.exitStatus) + "_phase_" +
                        gateEReleasePhaseLabel(launch.exitStatus) +
                        "_base_" + base.path
                )
            }
            guard launch.standardOutput.isEmpty,
                  launch.standardError.isEmpty else {
                throw FixtureError.invalid(
                    "gate_e_release_supervisor_stdio_base_" + base.path
                )
            }

            let leaves = try FileManager.default.contentsOfDirectory(
                atPath: journal.path
            ).sorted()
            guard leaves == gateEExpectedJournalLeaves().sorted() else {
                throw FixtureError.invalid(
                    "gate_e_release_journal_inventory_base_" + base.path
                )
            }
            var journalStatus = stat()
            guard lstat(journal.path, &journalStatus) == 0,
                  journalStatus.st_nlink == 36 else {
                throw FixtureError.invalid(
                    "gate_e_release_journal_metadata_base_" + base.path
                )
            }
            for leaf in leaves {
                let url = journal.appendingPathComponent(leaf)
                let data = try Data(contentsOf: url)
                var status = stat()
                guard lstat(url.path, &status) == 0,
                      status.st_mode & mode_t(S_IFMT)
                        == mode_t(S_IFREG),
                      status.st_mode & mode_t(0o7777) == 0o400,
                      status.st_nlink == 1,
                      data.count <= 64 * 1024,
                      data.last == 0x0a else {
                    throw FixtureError.invalid(
                        "gate_e_release_journal_leaf_" + leaf +
                            "_base_" + base.path
                    )
                }
            }
            guard try FileManager.default.contentsOfDirectory(
                    atPath: workspace.path
                  ).isEmpty,
                  try FileManager.default.contentsOfDirectory(
                    atPath: evidence.path
                  ).isEmpty else {
                throw FixtureError.invalid(
                    "gate_e_release_nonempty_root_base_" + base.path
                )
            }
        #endif
    }

    private func gateERootBinding(_ url: URL) throws
        -> PrimeValidationDirectoryBindingV2
    {
        let canonical = url.resolvingSymlinksInPath().standardizedFileURL
        var status = stat()
        guard canonical.path == url.standardizedFileURL.path,
              lstat(canonical.path, &status) == 0,
              status.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR)
        else {
            throw FixtureError.invalid("gate_e_root_binding")
        }
        return PrimeValidationDirectoryBindingV2(
            absolutePath: canonical.path,
            deviceID: UInt64(bitPattern: Int64(status.st_dev)),
            inode: UInt64(status.st_ino),
            ownerUserID: status.st_uid,
            mode: UInt16(status.st_mode & mode_t(0o7777))
        )
    }

    private struct GateEReleaseLaunchObservation {
        let exitStatus: Int32
        let standardOutput: Data
        let standardError: Data
    }

    private func gateEReleasePhaseLabel(_ exitStatus: Int32) -> String {
        switch exitStatus {
        case 65: "transport"
        case 66: "developer_directory"
        case 67: "supervisor_image"
        case 68: "fixed_probes_and_semantic_binding"
        case 69: "final_binding_revalidation"
        case 70: "containment_fail_stop"
        case 71: "admit_prerequisites"
        case 72: "consume_prerequisites"
        case 73: "prepare_guarded_pre_executor"
        case 74: "admission_companion_declaration"
        case 75: "admission_prime_repository"
        case 76: "admission_workspace_root"
        case 77: "admission_workspace_private_and_empty"
        case 78: "admission_evidence_root"
        case 79: "admission_evidence_private_and_empty"
        case 80: "admission_companion_repository"
        case 81: "admission_lease_directory"
        case 82: "admission_lease_private_and_empty"
        case 83: "admission_root_topology"
        case 84: "admission_exclusive_lease"
        case 85: "admission_post_lease_directory"
        case 86: "admission_source_snapshot"
        case 87: "admission_package_resolved_binding"
        case 88: "admission_prime_source_identity_snapshot"
        case 89: "admission_companion_content_snapshot"
        case 90: "admission_held_toolchain"
        default: "unknown"
        }
    }

    private struct GateEJournalMechanicsRecord:
        Codable,
        Equatable
    {
        let schema: String
        let ordinal: Int
        let leaf: String
        let predecessorSHA256: String
    }

    private struct GateESessionFixtureCausalFailStopV2Record:
        Codable,
        Equatable
    {
        let admittedDeviceID: UInt64
        let admittedInode: UInt64
        let containmentState: String
        let containmentStopAttemptSequence: UInt64
        let containmentStopDeathEventCheckPerformed: Bool
        let containmentStopDeathEventObserved: Bool
        let containmentStopErrno: Int32
        let containmentStopReturn: Int32
        let deadlineExpired: Bool
        let deathEventObservedAtContainmentFailure: Bool
        let deathWaitReturned: Bool
        let executionPhase: String
        let failureCoordinate: String
        let failureStatus: Int32
        let fixedFailStopStatus: Int32
        let fixtureMode: String
        let initiatingFailureCoordinate: String
        let initiatingFailureStatus: Int32
        let schema: String
        let sourceIdentitySHA256: String
    }

    private func gateELaunchReleaseSupervisor(
        executable: URL,
        request: Data,
        captureRoot: URL
    ) throws -> GateEReleaseLaunchObservation {
        var input = [Int32](repeating: -1, count: 2)
        guard pipe(&input) == 0 else {
            throw FixtureError.invalid("gate_e_outer_stdin_pipe")
        }
        defer {
            for descriptor in input where descriptor >= 0 {
                _ = Darwin.close(descriptor)
            }
        }
        let stdoutPath = captureRoot.appendingPathComponent(
            "outer-supervisor-stdout.bin"
        ).path
        let stderrPath = captureRoot.appendingPathComponent(
            "outer-supervisor-stderr.bin"
        ).path
        let stdout = Darwin.open(
            stdoutPath,
            O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC,
            mode_t(0o600)
        )
        guard stdout >= 3 else {
            if stdout >= 0 { _ = Darwin.close(stdout) }
            throw FixtureError.invalid("gate_e_outer_stdout_open")
        }
        defer { _ = Darwin.close(stdout) }
        let stderr = Darwin.open(
            stderrPath,
            O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC,
            mode_t(0o600)
        )
        guard stderr >= 3 else {
            if stderr >= 0 { _ = Darwin.close(stderr) }
            throw FixtureError.invalid("gate_e_outer_stderr_open")
        }
        defer { _ = Darwin.close(stderr) }

        var actions: posix_spawn_file_actions_t?
        guard posix_spawn_file_actions_init(&actions) == 0 else {
            throw FixtureError.invalid("gate_e_outer_actions_init")
        }
        defer { posix_spawn_file_actions_destroy(&actions) }
        for result in [
            posix_spawn_file_actions_addclose(&actions, input[1]),
            posix_spawn_file_actions_adddup2(
                &actions,
                input[0],
                STDIN_FILENO
            ),
            posix_spawn_file_actions_addclose(&actions, input[0]),
            posix_spawn_file_actions_adddup2(
                &actions,
                stdout,
                STDOUT_FILENO
            ),
            posix_spawn_file_actions_addclose(&actions, stdout),
            posix_spawn_file_actions_adddup2(
                &actions,
                stderr,
                STDERR_FILENO
            ),
            posix_spawn_file_actions_addclose(&actions, stderr),
        ] where result != 0 {
            throw FixtureError.invalid("gate_e_outer_actions")
        }

        var attributes: posix_spawnattr_t?
        guard posix_spawnattr_init(&attributes) == 0 else {
            throw FixtureError.invalid("gate_e_outer_attributes_init")
        }
        defer { posix_spawnattr_destroy(&attributes) }
        var defaultSignals = sigset_t()
        var emptyMask = sigset_t()
        guard sigemptyset(&defaultSignals) == 0,
              sigemptyset(&emptyMask) == 0 else {
            throw FixtureError.invalid("gate_e_outer_signal_sets")
        }
        for signal in 1 ..< NSIG where signal != SIGKILL && signal != SIGSTOP {
            guard sigaddset(&defaultSignals, signal) == 0 else {
                throw FixtureError.invalid("gate_e_outer_signal_default")
            }
        }
        let flags = UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
            | UInt16(POSIX_SPAWN_SETSID)
            | UInt16(POSIX_SPAWN_SETSIGDEF)
            | UInt16(POSIX_SPAWN_SETSIGMASK)
        guard posix_spawnattr_setsigdefault(
            &attributes,
            &defaultSignals
        ) == 0,
        posix_spawnattr_setsigmask(&attributes, &emptyMask) == 0,
        posix_spawnattr_setflags(
            &attributes,
            Int16(bitPattern: flags)
        ) == 0 else {
            throw FixtureError.invalid("gate_e_outer_spawn_policy")
        }
        guard let argumentZero = strdup(executable.path) else {
            throw FixtureError.invalid("gate_e_outer_argument_zero")
        }
        defer { free(argumentZero) }
        var arguments: [UnsafeMutablePointer<CChar>?] = [argumentZero, nil]
        var environment: [UnsafeMutablePointer<CChar>?] = [nil]
        var processIdentifier: pid_t = 0
        let spawnResult = arguments.withUnsafeMutableBufferPointer {
            argumentBuffer in
            environment.withUnsafeMutableBufferPointer {
                environmentBuffer in
                posix_spawn(
                    &processIdentifier,
                    executable.path,
                    &actions,
                    &attributes,
                    argumentBuffer.baseAddress,
                    environmentBuffer.baseAddress
                )
            }
        }
        guard spawnResult == 0, processIdentifier > 0 else {
            throw FixtureError.invalid("gate_e_outer_spawn_\(spawnResult)")
        }
        _ = Darwin.close(input[0])
        input[0] = -1
        do {
            try gateEWriteAll(request, descriptor: input[1])
        } catch {
            _ = Darwin.kill(-processIdentifier, SIGKILL)
            var rejectedStatus: Int32 = 0
            _ = Darwin.waitpid(processIdentifier, &rejectedStatus, 0)
            throw error
        }
        _ = Darwin.close(input[1])
        input[1] = -1

        let expires = DispatchTime.now().uptimeNanoseconds
            + 60_000_000_000
        var rawStatus: Int32 = 0
        while true {
            let waited = Darwin.waitpid(
                processIdentifier,
                &rawStatus,
                WNOHANG
            )
            if waited == processIdentifier { break }
            if waited < 0, errno == EINTR { continue }
            guard waited == 0,
                  DispatchTime.now().uptimeNanoseconds < expires else {
                _ = Darwin.kill(-processIdentifier, SIGKILL)
                _ = Darwin.waitpid(processIdentifier, &rawStatus, 0)
                throw FixtureError.invalid("gate_e_outer_reap")
            }
            _ = Darwin.usleep(10_000)
        }
        guard rawStatus & 0x7f == 0 else {
            throw FixtureError.invalid("gate_e_outer_signal")
        }
        let standardOutput = try gateEReadBoundedCapture(stdout)
        let standardError = try gateEReadBoundedCapture(stderr)
        return GateEReleaseLaunchObservation(
            exitStatus: (rawStatus >> 8) & 0xff,
            standardOutput: standardOutput,
            standardError: standardError
        )
    }

    private func gateEWriteAll(_ data: Data, descriptor: Int32) throws {
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let result = Darwin.write(
                    descriptor,
                    bytes.baseAddress!.advanced(by: offset),
                    bytes.count - offset
                )
                if result < 0, errno == EINTR { continue }
                guard result > 0 else {
                    throw FixtureError.invalid("gate_e_outer_stdin_write")
                }
                offset += result
            }
        }
    }

    private func gateEReadBoundedCapture(_ descriptor: Int32) throws
        -> Data
    {
        guard lseek(descriptor, 0, SEEK_SET) == 0 else {
            throw FixtureError.invalid("gate_e_outer_capture_seek")
        }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 16 * 1024)
        while true {
            let count = buffer.withUnsafeMutableBytes {
                Darwin.read(descriptor, $0.baseAddress, $0.count)
            }
            if count < 0, errno == EINTR { continue }
            guard count >= 0 else {
                throw FixtureError.invalid("gate_e_outer_capture_read")
            }
            if count == 0 { break }
            guard data.count <= 64 * 1024 - count else {
                throw FixtureError.invalid("gate_e_outer_capture_overflow")
            }
            data.append(contentsOf: buffer.prefix(count))
        }
        return data
    }

    private func gateEProductionSource(_ relativePath: String) throws
        -> String
    {
        var root = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 5 { root.deleteLastPathComponent() }
        return try String(
            contentsOf: root.appendingPathComponent(relativePath),
            encoding: .utf8
        )
    }

    private func gateEExpectedJournalLeaves() -> [String] {
        let bases = [
            "01-prime-head-pre", "02-prime-object-format",
            "03-prime-status-pre", "04-prime-tree-discovery",
            "05-prime-tree-replay", "06-prime-status-post",
            "07-prime-head-post", "08-companion-head-pre",
            "09-companion-object-format", "10-companion-status-pre",
            "11-companion-tree-discovery", "12-companion-tree-replay",
            "13-companion-status-post", "14-companion-head-post",
            "15-swift-version", "16-swift-target-info",
        ]
        return ["gate-e-prestart.json"]
            + bases.flatMap { ["\($0)-start.json", "\($0)-terminal.json"] }
            + ["gate-e-raw-terminal.json"]
    }

    @available(macOS 26.0, *)
    private func assertGateELightweightEventHistoryPoisons(
        _ label: String,
        mutateAndRestore: (Fixture) throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        XCTAssertFalse(
            image.productionSupervisorImageEligible,
            file: file,
            line: line
        )
        let context = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        ).context
        let facade = try image.transferDriverV2RoleFacade(context: context)
        let clean = try facade
            .revalidateFixedProbeLightweightContinuityForTesting()
        XCTAssertEqual(
            clean.combinedSourceWatcherDescriptorCountBefore,
            45,
            label,
            file: file,
            line: line
        )
        XCTAssertEqual(
            clean.combinedSourceWatcherDescriptorCountAfter,
            45,
            label,
            file: file,
            line: line
        )
        XCTAssertEqual(
            clean.spawnedChildCount,
            0,
            label,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.processExecutionObservation,
            .unobserved,
            label,
            file: file,
            line: line
        )

        try mutateAndRestore(fixture)
        XCTAssertThrowsError(
            try facade.revalidateFixedProbeLightweightContinuityForTesting(),
            label,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.continuityState,
            .poisoned,
            label,
            file: file,
            line: line
        )
        XCTAssertFalse(
            facade.primeSourceDescriptorClosureHeld,
            label,
            file: file,
            line: line
        )
        XCTAssertFalse(
            facade.companionSourceDescriptorClosureHeld,
            label,
            file: file,
            line: line
        )
        XCTAssertFalse(
            facade.primeSourceWatchWindowArmed,
            label,
            file: file,
            line: line
        )
        XCTAssertFalse(
            facade.companionSourceWatchWindowArmed,
            label,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.combinedSourceWatcherDescriptorCount,
            0,
            label,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.processExecutionObservation,
            .unobserved,
            label,
            file: file,
            line: line
        )
        XCTAssertThrowsError(
            try facade.revalidateFixedProbeLightweightContinuityForTesting(),
            label,
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned,
                label,
                file: file,
                line: line
            )
        }
    }

    private func expectation(
        for guarded:
            PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> PrimeValidationSwiftPMDriverV2ExecutableExpectation {
        let observed = guarded.currentProcessExecutable
        let data = try Data(
            contentsOf: URL(
                fileURLWithPath: observed.canonicalAbsolutePath
            )
        )
        XCTAssertEqual(
            UInt64(data.count),
            observed.byteCount,
            file: file,
            line: line
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: data),
            observed.sha256,
            file: file,
            line: line
        )
        return PrimeValidationSwiftPMDriverV2ExecutableExpectation(
            canonicalAbsolutePath: observed.canonicalAbsolutePath,
            byteCount: UInt64(data.count),
            sha256: PrimeSHA256.hexDigest(of: data)
        )
    }

    @available(macOS 26.0, *)
    private func assertFacadeContinuityPoison(
        _ label: String,
        mutate: (Fixture) throws -> Void,
        restore: ((Fixture) throws -> Void)? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try preparedGuard(for: fixture)
        let image = try boundTestImage(for: guarded)
        let context = try roleTransferInputs(
            fixture: fixture,
            guarded: guarded
        ).context
        let facade = try image.transferDriverV2RoleFacade(context: context)
        try facade.revalidateContinuity()
        assertLeaseBusy(fixture.lockURL, file: file, line: line)

        try mutate(fixture)
        XCTAssertThrowsError(
            try facade.revalidateContinuity(),
            label,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.continuityState,
            .poisoned,
            label,
            file: file,
            line: line
        )
        XCTAssertFalse(
            facade.primeSourceDescriptorClosureHeld,
            label,
            file: file,
            line: line
        )
        XCTAssertFalse(
            facade.companionSourceDescriptorClosureHeld,
            label,
            file: file,
            line: line
        )
        XCTAssertFalse(
            facade.primeSourceWatchWindowArmed,
            label,
            file: file,
            line: line
        )
        XCTAssertFalse(
            facade.companionSourceWatchWindowArmed,
            label,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.combinedSourceWatcherDescriptorCount,
            0,
            label,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.processExecutionObservation,
            .unobserved,
            label,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.buildExecutionObservation,
            .unobserved,
            label,
            file: file,
            line: line
        )
        XCTAssertEqual(
            facade.inventoryExecutionObservation,
            .unobserved,
            label,
            file: file,
            line: line
        )
        XCTAssertFalse(
            facade.completionAuthorized,
            label,
            file: file,
            line: line
        )

        try restore?(fixture)
        XCTAssertThrowsError(
            try facade.revalidateContinuity(),
            label,
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorPoisoned,
                label,
                file: file,
                line: line
            )
        }
        let diagnostic = try PrimeMetalDeviceLease.acquire(
            at: fixture.lockURL
        )
        XCTAssertTrue(diagnostic.isHeld, label, file: file, line: line)
        diagnostic.release()
    }

    private func assertLeaseBusy(
        _ url: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeMetalDeviceLease.acquire(at: url),
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as? PrimeMetalDeviceLeaseError,
                .busy,
                file: file,
                line: line
            )
        }
    }

    private func makePrivateDirectory(_ url: URL) throws {
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )
        guard chmod(url.path, 0o700) == 0 else {
            throw FixtureError.invalid("directory_mode")
        }
    }

    private func slice(
        _ source: String,
        from start: String,
        through end: String
    ) throws -> String {
        guard let lower = source.range(of: start)?.lowerBound,
              let upper = source.range(
                  of: end,
                  range: lower ..< source.endIndex
              )?.lowerBound else {
            throw FixtureError.invalid("source_slice")
        }
        return String(source[lower ..< upper])
    }
}

private final class ConsumeRace: @unchecked Sendable {
    private let lock = NSLock()
    private(set) var prerequisites:
        [PrimeValidationSwiftPMBuildInventoryPrerequisite] = []
    private(set) var errors: [Error] = []

    func record(
        _ operation: () throws
            -> PrimeValidationSwiftPMBuildInventoryPrerequisite
    ) {
        do {
            let value = try operation()
            lock.lock()
            prerequisites.append(value)
            lock.unlock()
        } catch {
            lock.lock()
            errors.append(error)
            lock.unlock()
        }
    }

    func releasePrerequisites() {
        lock.lock()
        prerequisites.removeAll()
        lock.unlock()
    }
}

private final class GuardPreparationRace: @unchecked Sendable {
    private let lock = NSLock()
    private(set) var values:
        [PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor] = []
    private(set) var errors: [Error] = []

    func record(
        _ operation: () throws
            -> PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor
    ) {
        do {
            let value = try operation()
            lock.lock()
            values.append(value)
            lock.unlock()
        } catch {
            lock.lock()
            errors.append(error)
            lock.unlock()
        }
    }

    func releaseValues() {
        lock.lock()
        values.removeAll()
        lock.unlock()
    }
}

private final class DriverV2ImageBindingRace:
    @unchecked Sendable
{
    private let lock = NSLock()
    private(set) var values:
        [PrimeValidationSwiftPMDriverV2SupervisorImageCapability] = []
    private(set) var errors: [Error] = []

    func record(
        _ operation: () throws
            -> PrimeValidationSwiftPMDriverV2SupervisorImageCapability
    ) {
        do {
            let value = try operation()
            lock.lock()
            values.append(value)
            lock.unlock()
        } catch {
            lock.lock()
            errors.append(error)
            lock.unlock()
        }
    }

    func releaseValues() {
        lock.lock()
        values.removeAll()
        lock.unlock()
    }
}

private final class DriverV2RoleFacadeTransferRace:
    @unchecked Sendable
{
    private let lock = NSLock()
    private(set) var values: [PrimeValidationDriverV2RoleFacade] = []
    private(set) var errors: [Error] = []

    func record(
        _ operation: () throws -> PrimeValidationDriverV2RoleFacade
    ) {
        do {
            let value = try operation()
            lock.lock()
            values.append(value)
            lock.unlock()
        } catch {
            lock.lock()
            errors.append(error)
            lock.unlock()
        }
    }

    func releaseValues() {
        lock.lock()
        values.removeAll()
        lock.unlock()
    }
}

private final class GateEJournalMechanicsRace:
    @unchecked Sendable
{
    private let lock = NSLock()
    private(set) var values:
        [PrimeValidationDriverV2FixedProbeJournalMechanicsTestObservation] = []
    private(set) var errors: [Error] = []

    func record(
        _ operation: () throws
            -> PrimeValidationDriverV2FixedProbeJournalMechanicsTestObservation
    ) {
        do {
            let value = try operation()
            lock.lock()
            values.append(value)
            lock.unlock()
        } catch {
            lock.lock()
            errors.append(error)
            lock.unlock()
        }
    }

    func releaseValues() {
        lock.lock()
        values.removeAll()
        lock.unlock()
    }
}

private final class GateEOuterJournalMechanicsRace:
    @unchecked Sendable
{
    private let lock = NSLock()
    private(set) var values:
        [PrimeValidationDriverV2OuterJournalMechanicsObservation] = []
    private(set) var errors: [Error] = []

    func record(
        _ operation: () throws
            -> PrimeValidationDriverV2OuterJournalMechanicsObservation
    ) {
        do {
            let value = try operation()
            lock.lock()
            values.append(value)
            lock.unlock()
        } catch {
            lock.lock()
            errors.append(error)
            lock.unlock()
        }
    }

    func releaseValues() {
        lock.lock()
        values.removeAll()
        lock.unlock()
    }
}

private final class DriverV2IsolatedSpawnCanaryRace:
    @unchecked Sendable
{
    private let lock = NSLock()
    private(set) var successCount = 0
    private(set) var errors: [Error] = []

    func record(_ operation: () throws -> Void) {
        do {
            try operation()
            lock.lock()
            successCount += 1
            lock.unlock()
        } catch {
            lock.lock()
            errors.append(error)
            lock.unlock()
        }
    }
}

private enum FixtureError: Error {
    case invalid(String)
}

private struct GateESessionFixtureFailStopMetadata: Equatable {
    let deviceID: UInt64
    let inode: UInt64
    let byteCount: UInt64
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let fileType: UInt16
    let permissionMode: UInt16
    let linkCount: UInt64
    let flags: UInt32
    let modificationSeconds: Int64
    let modificationNanoseconds: Int64
    let statusChangeSeconds: Int64
    let statusChangeNanoseconds: Int64

    init(_ value: stat) throws {
        guard value.st_size >= 0 else {
            throw FixtureError.invalid(
                "session_fail_stop_negative_size"
            )
        }
        deviceID = UInt64(bitPattern: Int64(value.st_dev))
        inode = UInt64(value.st_ino)
        byteCount = UInt64(value.st_size)
        ownerUserID = value.st_uid
        ownerGroupID = value.st_gid
        fileType = UInt16(value.st_mode & mode_t(S_IFMT))
        permissionMode = UInt16(value.st_mode & mode_t(0o7777))
        linkCount = UInt64(value.st_nlink)
        flags = value.st_flags
        modificationSeconds = Int64(value.st_mtimespec.tv_sec)
        modificationNanoseconds = Int64(value.st_mtimespec.tv_nsec)
        statusChangeSeconds = Int64(value.st_ctimespec.tv_sec)
        statusChangeNanoseconds = Int64(value.st_ctimespec.tv_nsec)
    }
}

private struct GateESessionFixtureFailStopXattrs: Equatable {
    let provenance: Data?

    static func capture(
        descriptor: Int32,
        coordinate: String
    ) throws -> Self {
        errno = 0
        if let accessControlList = acl_get_fd_np(
            descriptor,
            ACL_TYPE_EXTENDED
        ) {
            acl_free(UnsafeMutableRawPointer(accessControlList))
            throw FixtureError.invalid(coordinate + "_acl")
        }
        guard errno == ENOENT else {
            throw FixtureError.invalid(coordinate + "_acl_query")
        }

        let size = flistxattr(descriptor, nil, 0, 0)
        guard size >= 0, size <= 65_536 else {
            throw FixtureError.invalid(coordinate + "_xattr_size")
        }
        guard size > 0 else { return .init(provenance: nil) }

        var names = [CChar](repeating: 0, count: size)
        let returned = names.withUnsafeMutableBufferPointer {
            flistxattr(descriptor, $0.baseAddress, $0.count, 0)
        }
        guard returned == size else {
            throw FixtureError.invalid(coordinate + "_xattr_inventory")
        }
        let bytes = names.prefix(returned).map { UInt8(bitPattern: $0) }
        var observed = [String]()
        var start = 0
        for index in bytes.indices where bytes[index] == 0 {
            guard start < index,
                  let name = String(
                      bytes: bytes[start ..< index],
                      encoding: .utf8
                  )
            else {
                throw FixtureError.invalid(coordinate + "_xattr_name")
            }
            observed.append(name)
            start = index + 1
        }
        guard start == bytes.endIndex,
              observed == ["com.apple.provenance"]
        else {
            throw FixtureError.invalid(coordinate + "_xattr_policy")
        }

        let valueSize = "com.apple.provenance".withCString {
            fgetxattr(descriptor, $0, nil, 0, 0, 0)
        }
        guard valueSize >= 0, valueSize <= 65_536 else {
            throw FixtureError.invalid(coordinate + "_xattr_value_size")
        }
        var value = Data(count: valueSize)
        let valueCount = value.withUnsafeMutableBytes { buffer in
            "com.apple.provenance".withCString {
                fgetxattr(
                    descriptor,
                    $0,
                    buffer.baseAddress,
                    buffer.count,
                    0,
                    0
                )
            }
        }
        guard valueCount == valueSize else {
            throw FixtureError.invalid(coordinate + "_xattr_value")
        }
        return .init(provenance: value)
    }
}

private struct GateESessionFixtureFailStopDescriptorState: Equatable {
    let metadata: GateESessionFixtureFailStopMetadata
    let xattrs: GateESessionFixtureFailStopXattrs
    let descriptorFlags: Int32
    let statusFlags: Int32
    let offset: Int64

    static func capture(
        descriptor: Int32,
        expectedFileType: mode_t,
        expectedAccessMode: Int32,
        coordinate: String
    ) throws -> Self {
        var status = stat()
        let descriptorFlags = fcntl(descriptor, F_GETFD)
        let statusFlags = fcntl(descriptor, F_GETFL)
        let offset = lseek(descriptor, 0, SEEK_CUR)
        guard fstat(descriptor, &status) == 0,
              status.st_mode & mode_t(S_IFMT) == expectedFileType,
              descriptorFlags >= 0,
              descriptorFlags & FD_CLOEXEC != 0,
              statusFlags >= 0,
              statusFlags & O_ACCMODE == expectedAccessMode,
              statusFlags & (O_APPEND | O_NONBLOCK | O_ASYNC) == 0,
              offset == 0
        else {
            throw FixtureError.invalid(coordinate + "_descriptor")
        }
        return try .init(
            metadata: .init(status),
            xattrs: .capture(
                descriptor: descriptor,
                coordinate: coordinate
            ),
            descriptorFlags: descriptorFlags,
            statusFlags: statusFlags,
            offset: Int64(offset)
        )
    }
}

private final class GateESessionFixtureFailStopDiagnosticLeaf {
    private static let leaf =
        "gate-e-session-fixture-fail-stop.json"

    private let baseDescriptor: Int32
    let descriptor: Int32
    private let frozenBase:
        GateESessionFixtureFailStopDescriptorState
    private let frozenLeaf:
        GateESessionFixtureFailStopDescriptorState

    init(base: URL) throws {
        let heldBase = Darwin.open(
            base.path,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard heldBase >= 3 else {
            if heldBase >= 0 { _ = Darwin.close(heldBase) }
            throw FixtureError.invalid(
                "session_fail_stop_base_open_\(errno)"
            )
        }
        var retainBase = false
        defer {
            if !retainBase { _ = Darwin.close(heldBase) }
        }
        let admittedBase = try
            GateESessionFixtureFailStopDescriptorState.capture(
                descriptor: heldBase,
                expectedFileType: mode_t(S_IFDIR),
                expectedAccessMode: O_RDONLY,
                coordinate: "session_fail_stop_base"
            )
        guard admittedBase.metadata.ownerUserID == Darwin.geteuid(),
              admittedBase.metadata.permissionMode == 0o700,
              admittedBase.metadata.flags == 0
        else {
            throw FixtureError.invalid(
                "session_fail_stop_base_metadata"
            )
        }

        let opened = Self.leaf.withCString {
            openat(
                heldBase,
                $0,
                O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                mode_t(0o600)
            )
        }
        guard opened >= 3 else {
            if opened >= 0 { _ = Darwin.close(opened) }
            throw FixtureError.invalid(
                "session_fail_stop_leaf_open_\(errno)"
            )
        }
        var retainLeaf = false
        defer {
            if !retainLeaf { _ = Darwin.close(opened) }
        }
        guard fchmod(opened, mode_t(0o600)) == 0,
              fsync(opened) == 0,
              fcntl(opened, F_FULLFSYNC) == 0,
              fsync(heldBase) == 0,
              fcntl(heldBase, F_FULLFSYNC) == 0
        else {
            throw FixtureError.invalid(
                "session_fail_stop_leaf_freeze_\(errno)"
            )
        }

        let frozenLeaf = try
            GateESessionFixtureFailStopDescriptorState.capture(
                descriptor: opened,
                expectedFileType: mode_t(S_IFREG),
                expectedAccessMode: O_RDWR,
                coordinate: "session_fail_stop_leaf"
            )
        let frozenBase = try
            GateESessionFixtureFailStopDescriptorState.capture(
                descriptor: heldBase,
                expectedFileType: mode_t(S_IFDIR),
                expectedAccessMode: O_RDONLY,
                coordinate: "session_fail_stop_base_frozen"
            )
        let baseLinkTransition = admittedBase.metadata.linkCount
            .addingReportingOverflow(1)
        guard frozenBase.metadata.deviceID
                == admittedBase.metadata.deviceID,
              frozenBase.metadata.inode == admittedBase.metadata.inode
        else {
            throw FixtureError.invalid(
                "session_fail_stop_base_identity_transition"
            )
        }
        guard frozenBase.metadata.ownerUserID
                == admittedBase.metadata.ownerUserID,
              frozenBase.metadata.ownerGroupID
                == admittedBase.metadata.ownerGroupID
        else {
            throw FixtureError.invalid(
                "session_fail_stop_base_owner_transition"
            )
        }
        guard frozenBase.metadata.fileType
                == admittedBase.metadata.fileType
        else {
            throw FixtureError.invalid(
                "session_fail_stop_base_type_transition"
            )
        }
        guard frozenBase.metadata.permissionMode
                == admittedBase.metadata.permissionMode
        else {
            throw FixtureError.invalid(
                "session_fail_stop_base_mode_transition"
            )
        }
        guard frozenBase.metadata.flags == admittedBase.metadata.flags else {
            throw FixtureError.invalid(
                "session_fail_stop_base_flags_transition"
            )
        }
        guard !baseLinkTransition.overflow,
              frozenBase.metadata.linkCount
                == baseLinkTransition.partialValue
        else {
            throw FixtureError.invalid(
                "session_fail_stop_base_link_transition"
            )
        }
        guard frozenBase.xattrs == admittedBase.xattrs else {
            throw FixtureError.invalid(
                "session_fail_stop_base_xattrs_transition"
            )
        }
        guard frozenLeaf.metadata.ownerUserID == Darwin.geteuid() else {
            throw FixtureError.invalid(
                "session_fail_stop_leaf_owner"
            )
        }
        guard frozenLeaf.metadata.ownerGroupID
                == frozenBase.metadata.ownerGroupID
        else {
            throw FixtureError.invalid(
                "session_fail_stop_leaf_gid"
            )
        }
        guard frozenLeaf.metadata.permissionMode == 0o600 else {
            throw FixtureError.invalid(
                "session_fail_stop_leaf_mode"
            )
        }
        guard frozenLeaf.metadata.linkCount == 1 else {
            throw FixtureError.invalid(
                "session_fail_stop_leaf_link"
            )
        }
        guard frozenLeaf.metadata.flags == 0 else {
            throw FixtureError.invalid(
                "session_fail_stop_leaf_flags"
            )
        }
        guard frozenLeaf.metadata.byteCount == 0 else {
            throw FixtureError.invalid(
                "session_fail_stop_leaf_size"
            )
        }
        let rebound = try Self.openNamedLeaf(
            baseDescriptor: heldBase,
            coordinate: "session_fail_stop_leaf_initial_rejoin"
        )
        guard rebound.metadata == frozenLeaf.metadata,
              rebound.xattrs == frozenLeaf.xattrs
        else {
            throw FixtureError.invalid(
                "session_fail_stop_leaf_initial_rebound"
            )
        }

        baseDescriptor = heldBase
        descriptor = opened
        self.frozenBase = frozenBase
        self.frozenLeaf = frozenLeaf
        retainBase = true
        retainLeaf = true
    }

    deinit {
        if descriptor >= 3 { _ = Darwin.close(descriptor) }
        if baseDescriptor >= 3 { _ = Darwin.close(baseDescriptor) }
    }

    func revalidateUnchangedEmpty() throws {
        let currentBase = try
            GateESessionFixtureFailStopDescriptorState.capture(
                descriptor: baseDescriptor,
                expectedFileType: mode_t(S_IFDIR),
                expectedAccessMode: O_RDONLY,
                coordinate: "session_fail_stop_base_revalidate"
            )
        let currentLeaf = try
            GateESessionFixtureFailStopDescriptorState.capture(
                descriptor: descriptor,
                expectedFileType: mode_t(S_IFREG),
                expectedAccessMode: O_RDWR,
                coordinate: "session_fail_stop_leaf_revalidate"
            )
        let rebound = try Self.openNamedLeaf(
            baseDescriptor: baseDescriptor,
            coordinate: "session_fail_stop_leaf_rejoin"
        )
        guard currentBase == frozenBase,
              currentLeaf == frozenLeaf,
              rebound.metadata == frozenLeaf.metadata,
              rebound.xattrs == frozenLeaf.xattrs,
              rebound.metadata.deviceID == currentLeaf.metadata.deviceID,
              rebound.metadata.inode == currentLeaf.metadata.inode,
              currentLeaf.metadata.byteCount == 0,
              currentLeaf.offset == 0,
              rebound.offset == 0
        else {
            throw FixtureError.invalid(
                "session_fail_stop_leaf_changed"
            )
        }
    }

    private static func openNamedLeaf(
        baseDescriptor: Int32,
        coordinate: String
    ) throws -> GateESessionFixtureFailStopDescriptorState {
        let rebound = leaf.withCString {
            openat(
                baseDescriptor,
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard rebound >= 3 else {
            if rebound >= 0 { _ = Darwin.close(rebound) }
            throw FixtureError.invalid(coordinate + "_open_\(errno)")
        }
        defer { _ = Darwin.close(rebound) }
        return try GateESessionFixtureFailStopDescriptorState.capture(
            descriptor: rebound,
            expectedFileType: mode_t(S_IFREG),
            expectedAccessMode: O_RDONLY,
            coordinate: coordinate
        )
    }
}

private final class Fixture {
    static let commit = String(repeating: "a", count: 40)
    static let developerPath =
        "/Applications/Xcode.app/Contents/Developer"
    static let sdkPath = developerPath
        + "/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
    static let swiftPackagePath = developerPath
        + "/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package"

    static let admissionSourceURL: URL = {
        var root = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 5 {
            root.deleteLastPathComponent()
        }
        return root.appendingPathComponent(
            "Sources/PrimeCore/" +
                "PrimeValidationSwiftPMBuildInventoryAdmission.swift"
        )
    }()

    static let supervisorBridgeSourceURL: URL = {
        var root = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 3 {
            root.deleteLastPathComponent()
        }
        return root.appendingPathComponent(
            "Sources/PrimeValidationWorkflowDriverCore/" +
                "PrimeValidationDriverV2SupervisorImageBridge.swift"
        )
    }()

    static let supervisorSourceURL: URL = {
        var root = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 3 {
            root.deleteLastPathComponent()
        }
        return root.appendingPathComponent(
            "Sources/PrimeValidationWorkflowDriverV2Supervisor/" +
                "main.swift"
        )
    }()

    static let nestedManifestURL: URL = {
        var root = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 3 {
            root.deleteLastPathComponent()
        }
        return root.appendingPathComponent("Package.swift")
    }()

    let base: URL
    let prime: URL
    let workspace: URL
    let canaryJournal: URL
    let evidence: URL
    let lease: URL
    let companion: URL
    let sourceExpectation: PrimeSwiftSourceProvenanceExpectation
    private var cleaned = false

    var lockURL: URL {
        lease.appendingPathComponent(
            "prime-validation-swiftpm-build-inventory.lock"
        )
    }

    init() throws {
        base = URL(
            fileURLWithPath:
                "/private/tmp/prime-validation-admission-tests-"
                + UUID().uuidString,
            isDirectory: true
        )
        prime = base.appendingPathComponent("prime", isDirectory: true)
        workspace = base.appendingPathComponent(
            "workspace",
            isDirectory: true
        )
        canaryJournal = URL(
            fileURLWithPath:
                workspace.path + ".v2-spawn-01-journal",
            isDirectory: true
        )
        evidence = base.appendingPathComponent(
            "evidence",
            isDirectory: true
        )
        lease = base.appendingPathComponent("lease", isDirectory: true)
        companion = base.appendingPathComponent(
            "companion",
            isDirectory: true
        )
        for directory in [
            base,
            prime,
            workspace,
            canaryJournal,
            evidence,
            lease,
            companion,
        ] {
            try Self.createDirectory(directory)
        }
        for relativePath in [
            ".git",
            ".hidden",
            "Sources",
            "Empty",
        ] {
            try Self.createDirectory(
                companion.appendingPathComponent(
                    relativePath,
                    isDirectory: true
                )
            )
        }
        for (relativePath, contents) in [
            (".gitignore", ".build/\n"),
            (".hidden/config", "hidden fixture\n"),
            ("Package.swift", "// companion fixture\n"),
            ("Sources/Companion.swift", "// companion source\n"),
        ] {
            try Data(contents.utf8).write(
                to: companion.appendingPathComponent(relativePath)
            )
        }
        sourceExpectation = try Self.sealSyntheticSource(at: prime)
    }

    deinit {
        cleanup()
    }

    func cleanup() {
        guard !cleaned else { return }
        cleaned = true
        try? FileManager.default.removeItem(at: base)
    }

    func makeDirectory(_ relativePath: String) throws -> URL {
        let url = base.appendingPathComponent(
            relativePath,
            isDirectory: true
        )
        try Self.createDirectory(url)
        return url
    }

    func openPinnedSpawnCanaryExecutable() throws -> Int32 {
        var nestedRoot = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 3 { nestedRoot.deleteLastPathComponent() }
        let executable = nestedRoot.appendingPathComponent(
            ".build/arm64-apple-macosx/release/" +
                "PrimeValidationWorkflowDriverV2SpawnCanary",
            isDirectory: false
        )
        let descriptor = Darwin.open(
            executable.path,
            O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard descriptor >= 3 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw FixtureError.invalid(
                "spawn_canary_open_\(errno)"
            )
        }
        return descriptor
    }

    func openPinnedSessionFixtureExecutable() throws -> Int32 {
        var nestedRoot = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 3 { nestedRoot.deleteLastPathComponent() }
        let executable = nestedRoot.appendingPathComponent(
            ".build/arm64-apple-macosx/release/" +
                "PrimeValidationWorkflowDriverV2SessionFixture",
            isDirectory: false
        )
        let descriptor = Darwin.open(
            executable.path,
            O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard descriptor >= 3 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw FixtureError.invalid(
                "session_fixture_open_\(errno)"
            )
        }
        return descriptor
    }

    func admit(
        workspace: URL? = nil,
        evidence: URL? = nil,
        lease: URL? = nil,
        companion: URL? = nil,
        declaration:
            PrimeValidationSwiftPMCompanionDeclaration? = nil
    ) throws
        -> PrimeValidationSwiftPMBuildInventoryAdmissionCapability
    {
        try PrimeValidationSwiftPMBuildInventoryAdmission
            .admitPrerequisites(
                primeRepositoryURL: prime,
                workspaceRootURL: workspace ?? self.workspace,
                evidenceRootURL: evidence ?? self.evidence,
                leaseDirectoryURL: lease ?? self.lease,
                companionRepositoryURL: companion ?? self.companion,
                companionDeclaration: declaration ?? .init(
                    expectedPinnedHEAD: Self.commit,
                    declaredObservedHEAD: Self.commit,
                    declaredPorcelainV2Status: Data()
                ),
                developerDirectoryURL: URL(
                    fileURLWithPath: Self.developerPath,
                    isDirectory: true
                ),
                sourceExpectation: sourceExpectation
            )
    }

    func makeIntent(
        guarded:
            PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor,
        driverImageData: Data
    ) throws -> PrimeValidationRunIntentV2 {
        let roots = PrimeValidationDriverRootLayoutV2(
            repositoryRoot: Self.rootBinding(
                guarded.primeRepository
            ),
            companionRoot: Self.rootBinding(
                guarded.companionRepository
            ),
            workspaceRoot: Self.rootBinding(
                guarded.workspaceRoot
            ),
            evidenceRoot: Self.rootBinding(
                guarded.evidenceRoot
            ),
            scratchRelativePath: "root-release-build",
            cacheRelativePath: "cache",
            configRelativePath: "config",
            securityRelativePath: "security",
            clangModuleCacheRelativePath: "clang-module-cache",
            homeRelativePath: "home",
            swiftPMModuleCacheRelativePath: "swiftpm-module-cache",
            temporaryRelativePath: "temporary",
            outputRelativePath: "output"
        )
        let metallib = PrimeValidationRequiredMetallibV2(
            relativePath:
                "root-release-build/arm64-apple-macosx/release/" +
                "mlx-swift_Cmlx.bundle/Contents/Resources/" +
                "default.metallib",
            content: .init(data: Data("gate-a-metallib".utf8))
        )
        let swiftImage = guarded.toolchain.swiftPackageExecutable
        let swiftImageData = try Data(
            contentsOf: URL(
                fileURLWithPath: swiftImage.canonicalAbsolutePath
            )
        )
        let intent = PrimeValidationRunIntentV2(
            runID: "gate-a-xctest-rejection",
            roots: roots,
            sourceSnapshot: .init(
                data: Data("gate-a-source-snapshot".utf8)
            ),
            packageLock: .init(
                data: Data("gate-a-package-lock".utf8)
            ),
            driverExecutable: .init(
                absolutePath:
                    guarded.currentProcessExecutable
                    .canonicalAbsolutePath,
                content: .init(data: driverImageData)
            ),
            swiftExecutable: .init(
                absolutePath: swiftImage.canonicalAbsolutePath,
                content: .init(data: swiftImageData)
            ),
            companionCommit:
                PrimeValidationRunIntentV2.requiredCompanionCommit,
            requiredPinnedMetallib: metallib,
            baseline: .init(),
            phaseBudgets:
                PrimeValidationExecutorAdmissionPolicyV2
                .frozenV1.phaseBudgets,
            environmentPolicy: .make(
                roots: roots,
                pinnedMetallib: metallib
            ),
            optionalSkipPolicySHA256:
                try PrimeValidationOptionalSkipPolicy.identitySHA256()
        )
        try intent.validate()
        return intent
    }

    private static func rootBinding(
        _ observation: PrimeValidationSwiftPMDirectoryObservation
    ) -> PrimeValidationDirectoryBindingV2 {
        PrimeValidationDirectoryBindingV2(
            absolutePath: observation.canonicalAbsolutePath,
            deviceID: observation.deviceID,
            inode: observation.inode,
            ownerUserID: observation.ownerUserID,
            mode: observation.permissionMode
        )
    }

    private static func createDirectory(
        _ url: URL
    ) throws {
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )
        guard chmod(url.path, 0o700) == 0 else {
            throw FixtureError.invalid("directory_mode")
        }
    }

    private static func sealSyntheticSource(
        at root: URL
    ) throws -> PrimeSwiftSourceProvenanceExpectation {
        for relativePath in [
            ".swiftpm/configuration",
            "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/" +
                ".swiftpm/configuration",
            "Tests/PrimeNativeNeuralGateMLXValidation/" +
                ".swiftpm/configuration",
            "Tests/PrimeValidationWorkflow/.swiftpm/configuration",
            "Sources/PrimeCore",
            "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverCore",
            "Tests",
            "docs",
        ] {
            try createDirectory(
                root.appendingPathComponent(relativePath)
            )
        }
        let files: [String: Data] = [
            ".gitignore": Data(".build/\n".utf8),
            ".swiftpm/configuration/mirrors.json": Data("{}\n".utf8),
            "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/" +
                ".swiftpm/configuration/mirrors.json":
                Data("{}\n".utf8),
            "Tests/PrimeNativeNeuralGateMLXValidation/" +
                ".swiftpm/configuration/mirrors.json":
                Data("{}\n".utf8),
            "Tests/PrimeValidationWorkflow/.swiftpm/configuration/" +
                "mirrors.json": Data("{}\n".utf8),
            "LICENSE": Data("fixture\n".utf8),
            "Package.swift": Data("// fixture\n".utf8),
            "Package.resolved": Data("{}\n".utf8),
            "README.md": Data("fixture\n".utf8),
            "THIRD_PARTY_NOTICES.md": Data("fixture\n".utf8),
            "Sources/PrimeCore/" +
                "PrimeNativeNeuralGateHeldSourceClosure.swift":
                Data("// fixture held closure\n".utf8),
            "Sources/PrimeCore/PrimeSecureHeldSourceWatch.swift":
                Data("// fixture secure held watch\n".utf8),
            "Sources/PrimeCore/" +
                "PrimeValidationSwiftPMBuildInventoryAdmission.swift":
                Data("// fixture admission\n".utf8),
            "Sources/PrimeCore/" +
                "PrimeValidationDriverV2IsolatedSpawnCanary.swift":
                Data("// fixture Driver V2 spawn canary\n".utf8),
            "Sources/PrimeCore/" +
                "PrimeValidationDriverV2FixedProbeExecutor.swift":
                Data("// fixture Driver V2 fixed probe executor\n".utf8),
            "Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift":
                Data("// fixture Driver V2 role facade\n".utf8),
            "Sources/PrimeCore/" +
                "PrimeValidationDriverV2TrackedTreeHeldEntry.swift":
                Data("// fixture Driver V2 tracked-tree held entry\n".utf8),
            "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverCore/" +
                "PrimeValidationDriverV2TrackedTreeManifest.swift":
                Data("// fixture Driver V2 tracked-tree manifest\n".utf8),
            "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverCore/" +
                "PrimeValidationDriverV2FixedProbeBinding.swift":
                Data("// fixture Driver V2 fixed probe binding\n".utf8),
        ]
        for (relativePath, data) in files {
            try data.write(
                to: root.appendingPathComponent(relativePath)
            )
        }

        let dummyDigest = String(repeating: "0", count: 64)
        let embeddedURL = root.appendingPathComponent(
            PrimeSwiftSourceProvenance.embeddedProvenanceRelativePath
        )
        try PrimeSwiftSourceProvenance
            .canonicalEmbeddedProvenanceSource(
                sourceIdentitySHA256: dummyDigest
            ).write(to: embeddedURL)
        let dummy = PrimeSwiftSourceProvenanceExpectation(
            sourceIdentitySHA256: dummyDigest,
            buildConfiguration: "release"
        )
        let observed: String
        do {
            _ = try PrimeSwiftSourceProvenance.capture(
                at: root,
                requiredRelativePaths: [
                    "Sources/PrimeCore/" +
                        "PrimeNativeNeuralGateHeldSourceClosure.swift",
                    "Sources/PrimeCore/PrimeSecureHeldSourceWatch.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2IsolatedSpawnCanary.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2FixedProbeExecutor.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2RoleFacade.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2TrackedTreeHeldEntry.swift",
                    "Tests/PrimeValidationWorkflow/Sources/" +
                        "PrimeValidationWorkflowDriverCore/" +
                        "PrimeValidationDriverV2TrackedTreeManifest.swift",
                    "Tests/PrimeValidationWorkflow/Sources/" +
                        "PrimeValidationWorkflowDriverCore/" +
                        "PrimeValidationDriverV2FixedProbeBinding.swift",
                    "Package.resolved",
                ],
                expectation: dummy
            )
            throw FixtureError.invalid("dummy_source_seal")
        } catch let PrimeSwiftSourceProvenanceError
            .sourceIdentityMismatch(_, actual) {
            observed = actual
        }
        try PrimeSwiftSourceProvenance
            .canonicalEmbeddedProvenanceSource(
                sourceIdentitySHA256: observed
            ).write(to: embeddedURL)
        let expectation = PrimeSwiftSourceProvenanceExpectation(
            sourceIdentitySHA256: observed,
            buildConfiguration: "release"
        )
        _ = try PrimeSwiftSourceProvenance.capture(
            at: root,
            requiredRelativePaths: [
                "Sources/PrimeCore/" +
                    "PrimeNativeNeuralGateHeldSourceClosure.swift",
                "Sources/PrimeCore/PrimeSecureHeldSourceWatch.swift",
                "Sources/PrimeCore/" +
                    "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                "Sources/PrimeCore/" +
                    "PrimeValidationDriverV2IsolatedSpawnCanary.swift",
                "Sources/PrimeCore/" +
                    "PrimeValidationDriverV2FixedProbeExecutor.swift",
                "Sources/PrimeCore/" +
                    "PrimeValidationDriverV2RoleFacade.swift",
                "Sources/PrimeCore/" +
                    "PrimeValidationDriverV2TrackedTreeHeldEntry.swift",
                "Tests/PrimeValidationWorkflow/Sources/" +
                    "PrimeValidationWorkflowDriverCore/" +
                    "PrimeValidationDriverV2TrackedTreeManifest.swift",
                "Tests/PrimeValidationWorkflow/Sources/" +
                    "PrimeValidationWorkflowDriverCore/" +
                    "PrimeValidationDriverV2FixedProbeBinding.swift",
                "Package.resolved",
            ],
            expectation: expectation
        )
        return expectation
    }
}
