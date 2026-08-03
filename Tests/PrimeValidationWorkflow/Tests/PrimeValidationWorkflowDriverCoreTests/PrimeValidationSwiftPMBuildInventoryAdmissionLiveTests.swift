// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
@testable import PrimeCore
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

    func testCurrentProcessImageHandoffTransfersOldGuardAuthority()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )

        let handoff = try guarded.consumeCurrentProcessImageHandoff()

        XCTAssertEqual(guarded.guardState, .transferred)
        XCTAssertEqual(guarded.authorityCeiling, .transferredNoAuthority)
        XCTAssertFalse(guarded.sourceDescriptorClosureHeld)
        XCTAssertFalse(guarded.sourceWatchWindowArmed)
        XCTAssertFalse(guarded.currentProcessExecutableImageHeld)
        XCTAssertEqual(
            guarded.missingAuthorities,
            PrimeValidationSwiftPMMissingAuthority.allCases
        )
        XCTAssertThrowsError(try guarded.revalidateGuards()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorTransferred
            )
        }
        XCTAssertThrowsError(
            try guarded.consumeCurrentProcessImageHandoff()
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorTransferred
            )
        }

        XCTAssertEqual(handoff.guardState, .prepared)
        XCTAssertEqual(
            handoff.authorityCeiling,
            .sourceGuardsPreparedOnly
        )
        XCTAssertFalse(handoff.productionSupervisorImageEligible)
        XCTAssertTrue(
            handoff.missingAuthorities.contains(
                .supervisorExecutableImage
            )
        )
        XCTAssertEqual(handoff.processExecutionObservation, .unobserved)
        XCTAssertFalse(handoff.completionAuthorized)
        try handoff.revalidate()
    }

    func testConcurrentCurrentProcessImageHandoffHasOneWinner()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let guarded = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
        let race = CurrentProcessImageHandoffRace()
        let ready = DispatchGroup()
        let done = DispatchGroup()
        let start = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(
            label: "prime.validation.current-image-handoff-race",
            attributes: .concurrent
        )

        for _ in 0 ..< 2 {
            ready.enter()
            done.enter()
            queue.async {
                ready.leave()
                start.wait()
                race.record {
                    try guarded.consumeCurrentProcessImageHandoff()
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

    func testCurrentProcessImageClaimIsExactAndOneShot() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let handoff = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
            .consumeCurrentProcessImageHandoff()
        let image = handoff.currentProcessExecutable

        let claimed = try handoff.consumeMatchingCurrentProcessImage(
            expectedCanonicalAbsolutePath: image.canonicalAbsolutePath,
            expectedSHA256: image.sha256,
            expectedByteCount: image.byteCount,
            expectedSourceIdentitySHA256:
                handoff.sourceIdentitySHA256
        )

        XCTAssertEqual(handoff.guardState, .transferred)
        XCTAssertEqual(handoff.authorityCeiling, .transferredNoAuthority)
        XCTAssertEqual(
            handoff.missingAuthorities,
            PrimeValidationSwiftPMMissingAuthority.allCases
        )
        XCTAssertThrowsError(try handoff.revalidate()) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorTransferred
            )
        }
        XCTAssertEqual(claimed.guardState, .prepared)
        XCTAssertFalse(claimed.productionSupervisorImageEligible)
        XCTAssertTrue(
            claimed.missingAuthorities.contains(
                .supervisorExecutableImage
            )
        )
        XCTAssertEqual(claimed.processExecutionObservation, .unobserved)
        XCTAssertFalse(claimed.completionAuthorized)
        try claimed.revalidate()
        XCTAssertThrowsError(
            try handoff.consumeMatchingCurrentProcessImage(
                expectedCanonicalAbsolutePath:
                    image.canonicalAbsolutePath,
                expectedSHA256: image.sha256,
                expectedByteCount: image.byteCount,
                expectedSourceIdentitySHA256:
                    handoff.sourceIdentitySHA256
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeValidationSwiftPMBuildInventoryAdmissionError,
                .guardedPreExecutorTransferred
            )
        }
    }

    func testTransferredAliasesDoNotRetainLeaseAfterClaimDrops()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capability = try fixture.admit()
        let prerequisite = try capability.consumePrerequisites()
        let guarded = try prerequisite.prepareGuardedPreExecutor(
            allowRootOwnedCurrentProcessForTesting: true
        )
        let handoff = try guarded.consumeCurrentProcessImageHandoff()
        let image = handoff.currentProcessExecutable
        var claimed:
            PrimeValidationSwiftPMClaimedCurrentProcessImage? =
                try handoff.consumeMatchingCurrentProcessImage(
                    expectedCanonicalAbsolutePath:
                        image.canonicalAbsolutePath,
                    expectedSHA256: image.sha256,
                    expectedByteCount: image.byteCount,
                    expectedSourceIdentitySHA256:
                        handoff.sourceIdentitySHA256
                )

        try claimed?.revalidate()
        assertLeaseBusy(fixture.lockURL)
        XCTAssertEqual(
            prerequisite.authorityCeiling,
            .transferredNoAuthority
        )
        XCTAssertEqual(guarded.guardState, .transferred)
        XCTAssertEqual(handoff.guardState, .transferred)
        claimed = nil

        let staleAliases = (
            capability,
            prerequisite,
            guarded,
            handoff
        )
        let reacquired = try withExtendedLifetime(staleAliases) {
            try PrimeMetalDeviceLease.acquire(at: fixture.lockURL)
        }
        XCTAssertTrue(reacquired.isHeld)
        reacquired.release()
    }

    func testConcurrentCurrentProcessImageClaimHasOneWinner()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let handoff = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
            .consumeCurrentProcessImageHandoff()
        let image = handoff.currentProcessExecutable
        let race = CurrentProcessImageClaimRace()
        let ready = DispatchGroup()
        let done = DispatchGroup()
        let start = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(
            label: "prime.validation.current-image-claim-race",
            attributes: .concurrent
        )

        for _ in 0 ..< 2 {
            ready.enter()
            done.enter()
            queue.async {
                ready.leave()
                start.wait()
                race.record {
                    try handoff.consumeMatchingCurrentProcessImage(
                        expectedCanonicalAbsolutePath:
                            image.canonicalAbsolutePath,
                        expectedSHA256: image.sha256,
                        expectedByteCount: image.byteCount,
                        expectedSourceIdentitySHA256:
                            handoff.sourceIdentitySHA256
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

    func testCurrentProcessImageClaimMismatchPoisonsHandoff()
        throws
    {
        enum Mutation: Equatable {
            case path
            case hash
            case size
            case source
        }
        for mutation in [
            Mutation.path,
            .hash,
            .size,
            .source,
        ] {
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            let handoff = try fixture.admit()
                .consumePrerequisites()
                .prepareGuardedPreExecutor(
                    allowRootOwnedCurrentProcessForTesting: true
                )
                .consumeCurrentProcessImageHandoff()
            let image = handoff.currentProcessExecutable
            let path = mutation == .path
                ? "/private/tmp/not-the-current-image"
                : image.canonicalAbsolutePath
            let hash = mutation == .hash
                ? String(repeating: "0", count: 64)
                : image.sha256
            let size = mutation == .size
                ? image.byteCount + 1
                : image.byteCount
            let source = mutation == .source
                ? String(repeating: "0", count: 64)
                : handoff.sourceIdentitySHA256

            XCTAssertThrowsError(
                try handoff.consumeMatchingCurrentProcessImage(
                    expectedCanonicalAbsolutePath: path,
                    expectedSHA256: hash,
                    expectedByteCount: size,
                    expectedSourceIdentitySHA256: source
                )
            ) {
                XCTAssertEqual(
                    $0 as?
                        PrimeValidationSwiftPMBuildInventoryAdmissionError,
                    .rejected("current_process_image_binding")
                )
            }
            XCTAssertEqual(handoff.guardState, .poisoned)
            XCTAssertEqual(
                handoff.authorityCeiling,
                .poisonedNoAuthority
            )
            XCTAssertEqual(
                handoff.missingAuthorities,
                PrimeValidationSwiftPMMissingAuthority.allCases
            )
            XCTAssertThrowsError(try handoff.revalidate())
        }
    }

    func testClaimedCurrentProcessImagePoisonsAfterSourceMutation()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capability = try fixture.admit()
        let prerequisite = try capability.consumePrerequisites()
        let guarded = try prerequisite.prepareGuardedPreExecutor(
            allowRootOwnedCurrentProcessForTesting: true
        )
        let handoff = try guarded.consumeCurrentProcessImageHandoff()
        let image = handoff.currentProcessExecutable
        let claimed = try handoff.consumeMatchingCurrentProcessImage(
            expectedCanonicalAbsolutePath: image.canonicalAbsolutePath,
            expectedSHA256: image.sha256,
            expectedByteCount: image.byteCount,
            expectedSourceIdentitySHA256:
                handoff.sourceIdentitySHA256
        )

        try Data("mutated\n".utf8).write(
            to: fixture.prime.appendingPathComponent("README.md")
        )
        XCTAssertThrowsError(try claimed.revalidate())
        XCTAssertEqual(claimed.guardState, .poisoned)
        XCTAssertEqual(
            claimed.authorityCeiling,
            .poisonedNoAuthority
        )
        XCTAssertEqual(
            claimed.missingAuthorities,
            PrimeValidationSwiftPMMissingAuthority.allCases
        )

        let staleAliases = (
            capability,
            prerequisite,
            guarded,
            handoff,
            claimed
        )
        let reacquired = try withExtendedLifetime(staleAliases) {
            try PrimeMetalDeviceLease.acquire(at: fixture.lockURL)
        }
        XCTAssertTrue(reacquired.isHeld)
        reacquired.release()
    }

    func testRootOwnedXCTestImageCannotBecomeDriverSupervisor()
        throws
    {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let handoff = try fixture.admit()
            .consumePrerequisites()
            .prepareGuardedPreExecutor(
                allowRootOwnedCurrentProcessForTesting: true
            )
            .consumeCurrentProcessImageHandoff()
        let image = handoff.currentProcessExecutable
        let bytes = try Data(
            contentsOf: URL(
                fileURLWithPath: image.canonicalAbsolutePath
            )
        )
        XCTAssertEqual(UInt64(bytes.count), image.byteCount)
        XCTAssertEqual(PrimeSHA256.hexDigest(of: bytes), image.sha256)
        let declaration =
            PrimeValidationDriverV2SupervisorImageDeclarationV1(
                runID: "xctest-substitution",
                sourceIdentitySHA256:
                    handoff.sourceIdentitySHA256,
                executable: .init(
                    absolutePath: image.canonicalAbsolutePath,
                    content: .init(data: bytes)
                )
            )

        XCTAssertThrowsError(
            try PrimeValidationDriverV2SupervisorImageBridge.bind(
                handoff: handoff,
                declaration: declaration
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeValidationDriverV2Error,
                .authorityViolation
            )
        }
        XCTAssertEqual(handoff.guardState, .prepared)
        try handoff.revalidate()
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
        XCTAssertFalse(capabilitySource.contains("Codable"))
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
        XCTAssertFalse(prerequisiteSource.contains("Codable"))
        XCTAssertFalse(prerequisiteSource.contains("public init("))

        let guardedSource = try slice(
            source,
            from:
                "public final class PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor",
            through:
                "/// A neutral, one-shot live handoff for exact current-image matching."
        )
        XCTAssertFalse(guardedSource.contains("Codable"))
        XCTAssertFalse(guardedSource.contains("public init("))
        XCTAssertFalse(guardedSource.contains("arguments:"))
        XCTAssertFalse(guardedSource.contains("environment:"))
        XCTAssertFalse(guardedSource.contains("posix_spawn"))
        XCTAssertFalse(guardedSource.contains("Process("))
        XCTAssertFalse(guardedSource.contains("createDirectory"))

        let handoffSource = try slice(
            source,
            from:
                "public final class PrimeValidationSwiftPMCurrentProcessImageHandoff",
            through:
                "/// Unforgeable live proof that declared source/image values matched"
        )
        XCTAssertFalse(handoffSource.contains("Codable"))
        XCTAssertFalse(handoffSource.contains("public init("))
        XCTAssertFalse(handoffSource.contains("arguments:"))
        XCTAssertFalse(handoffSource.contains("environment:"))
        XCTAssertFalse(handoffSource.contains("posix_spawn"))
        XCTAssertFalse(handoffSource.contains("Process("))
        XCTAssertFalse(handoffSource.contains("execute("))

        let bridgeSource = try String(
            contentsOf: Fixture.supervisorBridgeSourceURL,
            encoding: .utf8
        )
        XCTAssertTrue(
            bridgeSource.contains(
                "package enum PrimeValidationDriverV2SupervisorImageBridge"
            )
        )
        XCTAssertFalse(
            bridgeSource.contains(
                "public enum PrimeValidationDriverV2SupervisorImageBridge"
            )
        )
        XCTAssertFalse(bridgeSource.contains("Process("))
        XCTAssertFalse(bridgeSource.contains("posix_spawn"))
        XCTAssertFalse(bridgeSource.contains("arguments:"))
        XCTAssertFalse(bridgeSource.contains("environment:"))
        XCTAssertFalse(bridgeSource.contains("restore("))
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

private final class CurrentProcessImageHandoffRace:
    @unchecked Sendable
{
    private let lock = NSLock()
    private(set) var values:
        [PrimeValidationSwiftPMCurrentProcessImageHandoff] = []
    private(set) var errors: [Error] = []

    func record(
        _ operation: () throws
            -> PrimeValidationSwiftPMCurrentProcessImageHandoff
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

private final class CurrentProcessImageClaimRace:
    @unchecked Sendable
{
    private let lock = NSLock()
    private(set) var values:
        [PrimeValidationSwiftPMClaimedCurrentProcessImage] = []
    private(set) var errors: [Error] = []

    func record(
        _ operation: () throws
            -> PrimeValidationSwiftPMClaimedCurrentProcessImage
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
    static let developerPath: String = {
        let selector = URL(
            fileURLWithPath:
                "/Applications/Xcode.app/Contents/Developer",
            isDirectory: true
        )
        let canonical = selector
            .resolvingSymlinksInPath()
            .standardizedFileURL.path
        precondition(
            [
                "/Applications/Xcode.app/Contents/Developer",
                "/Applications/Xcode_26.5.app/Contents/Developer",
                "/Applications/Xcode_26.6.app/Contents/Developer",
            ].contains(canonical)
        )
        return canonical
    }()
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
                "Package.resolved",
            ],
            expectation: expectation
        )
        return expectation
    }
}
