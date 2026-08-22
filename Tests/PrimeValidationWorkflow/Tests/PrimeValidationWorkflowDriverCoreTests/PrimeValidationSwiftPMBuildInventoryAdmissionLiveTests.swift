// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) @testable import PrimeCore
import PrimeValidationWorkflowContracts
import PrimeValidationWorkflowDriverCore
import XCTest

final class PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests:
    XCTestCase
{
    func testPublicReleaseAdmissionUsesEmbeddedSourceAuthority()
        throws
    {
        #if DEBUG
            throw XCTSkip("public embedded-source admission is Release-only")
        #else
            guard let companionPath = ProcessInfo.processInfo.environment[
                "PRIME_PMHNP_COMPANION_ROOT"
            ], companionPath.hasPrefix("/") else {
                throw XCTSkip(
                    "set PRIME_PMHNP_COMPANION_ROOT for the public live gate"
                )
            }
            var primeRepository = URL(fileURLWithPath: #filePath)
            for _ in 0 ..< 5 {
                primeRepository.deleteLastPathComponent()
            }
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
        capability = nil
        assertLeaseBusy(fixture.lockURL)

        prerequisite = nil
        let reacquired = try PrimeMetalDeviceLease.acquire(
            at: fixture.lockURL
        )
        XCTAssertTrue(reacquired.isHeld)
        reacquired.release()
    }

    func testGuardedPreExecutorClosesOnlyPrimeSourceAuthorities()
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

    func testAdmissionRequiresDriverV2RoleFacadeSource() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        try FileManager.default.removeItem(
            at: fixture.prime.appendingPathComponent(
                "Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift"
            )
        )

        XCTAssertThrowsError(try fixture.admit()) {
            XCTAssertEqual(
                $0 as? PrimeSwiftSourceProvenanceError,
                .incompleteSourceSnapshot
            )
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

    func testFixedRoleFacadeSourceHasNoExecutionOrRoleIssuingSurface()
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
                "fileprivate struct PrimeValidationDriverV2ClosedRolePolicy"
        )
        XCTAssertFalse(facadeSource.contains("public init("))
        XCTAssertFalse(facadeSource.contains("package init("))
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
                separatedBy: ".roleContext(from: intent)"
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
        )

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
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .rejected("directory_path_overlap")
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
        try Data("mutation".utf8).write(
            to: fixture.companion.appendingPathComponent("unexpected")
        )

        XCTAssertThrowsError(try capability.consumePrerequisites())
        XCTAssertThrowsError(try capability.consumePrerequisites()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .capabilityAlreadyConsumed
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
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .rejected("companion_declaration")
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
            through: "        .testTarget("
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

private enum FixtureError: Error {
    case invalid(String)
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
            evidence,
            lease,
            companion,
        ] {
            try Self.createDirectory(directory)
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
                "PrimeValidationSwiftPMBuildInventoryAdmission.swift":
                Data("// fixture admission\n".utf8),
            "Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift":
                Data("// fixture Driver V2 role facade\n".utf8),
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
                        "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2RoleFacade.swift",
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
                    "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                "Sources/PrimeCore/" +
                    "PrimeValidationDriverV2RoleFacade.swift",
                "Package.resolved",
            ],
            expectation: expectation
        )
        return expectation
    }
}
