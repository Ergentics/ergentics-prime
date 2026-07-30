import Darwin
import Foundation
import XCTest
@testable import PrimeCore

@_silgen_name("mbr_uid_to_uuid")
private func primeTestUIDToUUID(
    _ identifier: uid_t,
    _ uuid: UnsafeMutablePointer<uuid_t>
) -> Int32

final class PrimePinnedMLXMetallibTests: XCTestCase {
    private struct Fixture {
        let hostRoot: URL
        let executable: URL
        let metallib: URL
        let artifactRoot: PrimeArtifactRoot
    }

    private var temporaryURL: URL!
    private var savedDynamicLoaderEnvironment =
        [String: String]()

    override func setUpWithError() throws {
        for name in [
            "DYLD_FRAMEWORK_PATH",
            "DYLD_FALLBACK_FRAMEWORK_PATH",
            "DYLD_LIBRARY_PATH",
            "DYLD_FALLBACK_LIBRARY_PATH",
            "DYLD_INSERT_LIBRARIES",
        ] {
            if let value = getenv(name) {
                savedDynamicLoaderEnvironment[name] =
                    String(cString: value)
                unsetenv(name)
            }
        }
        temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "ergentics-prime-metallib-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: temporaryURL,
            withIntermediateDirectories: false
        )
        XCTAssertEqual(
            chmod(temporaryURL.path, 0o700),
            0
        )
    }

    override func tearDownWithError() throws {
        for (name, value)
        in savedDynamicLoaderEnvironment {
            setenv(name, value, 1)
        }
        savedDynamicLoaderEnvironment.removeAll()
        if let temporaryURL {
            try? FileManager.default.removeItem(
                at: temporaryURL
            )
        }
    }

    func testCapturePublishesExactBundleAndReverifies()
        throws
    {
        let fixture = try makeFixture()
        let binding =
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of: fixture.executable,
                    into: fixture.artifactRoot
                )
        XCTAssertEqual(
            binding.artifact.sha256,
            PrimePinnedMLXMetallib.expectedSHA256
        )
        XCTAssertEqual(
            binding.infoPlistArtifact.sha256,
            PrimePinnedMLXMetallib
                .expectedInfoPlistSHA256
        )
        XCTAssertNoThrow(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: fixture.executable,
                    matches: binding
                )
        )
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .reverifySibling(
                    of: fixture.executable,
                    matches: binding
                )
        )
        var mutated = try Data(
            contentsOf: fixture.metallib
        )
        mutated[mutated.count - 1] ^= 0xff
        try withOwnerWritableFile(
            at: fixture.metallib
        ) {
            try mutated.write(to: fixture.metallib)
        }
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: fixture.executable,
                    matches: binding
                )
        )

        let infoFixture = try makeFixture()
        let infoBinding =
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of: infoFixture.executable,
                    into: infoFixture.artifactRoot
                )
        let infoPlist = infoFixture.metallib
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Info.plist")
        var mutatedInfo = try Data(
            contentsOf: infoPlist
        )
        mutatedInfo[mutatedInfo.count - 1] ^= 0xff
        try withOwnerWritableFile(at: infoPlist) {
            try mutatedInfo.write(to: infoPlist)
        }
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: infoFixture.executable,
                    matches: infoBinding
                )
        )
    }

    func testStageExactXcodeMetallibPublishesOnlyMissingMetallibAndIsIdempotent()
        throws
    {
        let donor = try makeXcodeDonorFixture()
        let destination = try makeFixture(
            executableName:
                "PrimeTypedOptimizerRestoreProbe"
        )
        let destinationInfoPlist =
            infoPlistURL(for: destination)
        let canonicalInfoPlist = try Data(
            contentsOf: destinationInfoPlist
        )
        XCTAssertEqual(
            UInt64(canonicalInfoPlist.count),
            PrimePinnedMLXMetallib
                .expectedInfoPlistByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: canonicalInfoPlist
            ),
            PrimePinnedMLXMetallib
                .expectedInfoPlistSHA256
        )
        try FileManager.default.removeItem(
            at: destination.metallib
        )

        let first =
            try PrimePinnedMLXMetallib
                .stageExactXcodeMetallib(
                    from: donor.executable,
                    beside: destination.executable,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
        XCTAssertTrue(
            first
                .destinationMetallibInitiallyAbsent
        )
        XCTAssertEqual(
            try Data(
                contentsOf: destinationInfoPlist
            ),
            canonicalInfoPlist
        )
        let stagedMetallib = try Data(
            contentsOf: destination.metallib
        )
        XCTAssertEqual(
            UInt64(stagedMetallib.count),
            PrimePinnedMLXMetallib
                .expectedByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: stagedMetallib
            ),
            PrimePinnedMLXMetallib
                .expectedSHA256
        )
        XCTAssertNoThrow(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: destination.executable,
                    matches: first.binding,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
        )

        let second =
            try PrimePinnedMLXMetallib
                .stageExactXcodeMetallib(
                    from: donor.executable,
                    beside: destination.executable,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
        XCTAssertFalse(
            second
                .destinationMetallibInitiallyAbsent
        )
        XCTAssertEqual(second.binding, first.binding)
        XCTAssertEqual(
            try Data(
                contentsOf: destinationInfoPlist
            ),
            canonicalInfoPlist
        )
        XCTAssertEqual(
            try Data(
                contentsOf: destination.metallib
            ),
            stagedMetallib
        )
    }

    func testStageValidatesDonorEvenWhenDestinationIsExact()
        throws
    {
        let donor = try makeXcodeDonorFixture()
        let destination = try makeFixture(
            executableName:
                "PrimeTypedOptimizerRestoreProbe"
        )
        let originalDestinationMetallib =
            try Data(
                contentsOf: destination.metallib
            )
        let donorInfoPlist =
            infoPlistURL(for: donor)
        var invalidDonorInfoPlist =
            try Data(contentsOf: donorInfoPlist)
        invalidDonorInfoPlist[
            invalidDonorInfoPlist.count - 1
        ] ^= 0xff
        try withOwnerWritableFile(
            at: donorInfoPlist
        ) {
            try invalidDonorInfoPlist.write(
                to: donorInfoPlist
            )
        }

        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .stageExactXcodeMetallib(
                    from: donor.executable,
                    beside: destination.executable,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
        )
        XCTAssertEqual(
            try Data(
                contentsOf: destination.metallib
            ),
            originalDestinationMetallib
        )
    }

    func testStageAndReverifyNative3BMetalContinuationRuntimeRole()
        throws
    {
        let donor = try makeXcodeDonorFixture()
        let destination = try makeFixture(
            executableName:
                "PrimeNative3BMetalContinuationProbe"
        )
        try FileManager.default.removeItem(
            at: destination.metallib
        )

        let staged =
            try PrimePinnedMLXMetallib
                .stageExactXcodeMetallib(
                    from: donor.executable,
                    beside: destination.executable,
                    runtimeRole:
                        .native3BMetalContinuationProbe
                )
        XCTAssertTrue(
            staged.destinationMetallibInitiallyAbsent
        )
        XCTAssertEqual(
            staged.binding.runtimeImageLayout,
            PrimeMLXRuntimeImageLayout
                .native3BMetalContinuationProbe
        )
        XCTAssertNoThrow(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: destination.executable,
                    matches: staged.binding,
                    runtimeRole:
                        .native3BMetalContinuationProbe
                )
        )
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: destination.executable,
                    matches: staged.binding,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
        )
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .stageExactXcodeMetallib(
                    from: donor.executable,
                    beside: destination.executable,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
        )
    }

    func testStageRejectsWrongExistingDestinationWithoutOverwrite()
        throws
    {
        let donor = try makeXcodeDonorFixture()
        let destination = try makeFixture(
            executableName:
                "PrimeTypedOptimizerRestoreProbe"
        )
        var wrongDestinationMetallib =
            try Data(
                contentsOf: destination.metallib
            )
        wrongDestinationMetallib[
            wrongDestinationMetallib.count - 1
        ] ^= 0xff
        try withOwnerWritableFile(
            at: destination.metallib
        ) {
            try wrongDestinationMetallib.write(
                to: destination.metallib
            )
        }

        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .stageExactXcodeMetallib(
                    from: donor.executable,
                    beside: destination.executable,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
        )
        XCTAssertEqual(
            try Data(
                contentsOf: destination.metallib
            ),
            wrongDestinationMetallib
        )
    }

    func testStageRejectsSourceAndDestinationManifestRoleSubstitution()
        throws
    {
        do {
            let canonicalSource =
                try makeFixture()
            let destination = try makeFixture(
                executableName:
                    "PrimeTypedOptimizerRestoreProbe"
            )
            XCTAssertThrowsError(
                try PrimePinnedMLXMetallib
                    .stageExactXcodeMetallib(
                        from:
                            canonicalSource
                            .executable,
                        beside:
                            destination
                            .executable,
                        runtimeRole:
                            .typedOptimizerRestoreProbe
                    )
            )
        }

        do {
            let donor =
                try makeXcodeDonorFixture()
            let destination = try makeFixture(
                executableName:
                    "PrimeTypedOptimizerRestoreProbe"
            )
            try convertCanonicalInfoPlistToXcodeDonor(
                in: destination
            )
            XCTAssertThrowsError(
                try PrimePinnedMLXMetallib
                    .stageExactXcodeMetallib(
                        from: donor.executable,
                        beside:
                            destination
                            .executable,
                        runtimeRole:
                            .typedOptimizerRestoreProbe
                    )
            )
        }

        do {
            let donor =
                try makeXcodeDonorFixture()
            let destination = try makeFixture(
                executableName:
                    "PrimeTypedOptimizerRestoreProbe"
            )
            XCTAssertThrowsError(
                try PrimePinnedMLXMetallib
                    .stageExactXcodeMetallib(
                        from: donor.executable,
                        beside:
                            destination
                            .executable,
                        runtimeRole: .calibration
                    )
            )
        }
    }

    func testStageRejectsExtraXcodeDonorBundleEntry()
        throws
    {
        let donor = try makeXcodeDonorFixture()
        let destination = try makeFixture(
            executableName:
                "PrimeTypedOptimizerRestoreProbe"
        )
        let extra = donor.metallib
            .deletingLastPathComponent()
            .appendingPathComponent(
                "unadmitted.metallib"
            )
        try Data("unadmitted".utf8).write(
            to: extra
        )
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .stageExactXcodeMetallib(
                    from: donor.executable,
                    beside: destination.executable,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
        )
    }

    func testExplicitRuntimeRolesRejectCrossRoleSubstitution()
        throws
    {
        let calibrationFixture = try makeFixture()
        let calibrationBinding =
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of:
                        calibrationFixture
                        .executable,
                    into:
                        calibrationFixture
                        .artifactRoot
                )
        XCTAssertEqual(
            calibrationBinding.runtimeImageLayout,
            PrimeMLXRuntimeImageLayout
                .calibration
        )
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of:
                        calibrationFixture
                        .executable,
                    matches:
                        calibrationBinding,
                    runtimeRole:
                        .optimizerRestoreProbe
                )
        )

        let restoreFixture = try makeFixture()
        let restoreBinding =
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of: restoreFixture.executable,
                    into:
                        restoreFixture.artifactRoot,
                    runtimeRole:
                        .optimizerRestoreProbe
                )
        XCTAssertEqual(
            restoreBinding.runtimeImageLayout,
            PrimeMLXRuntimeImageLayout
                .optimizerRestoreProbe
        )
        XCTAssertNoThrow(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: restoreFixture.executable,
                    matches: restoreBinding,
                    runtimeRole:
                        .optimizerRestoreProbe
                )
        )
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: restoreFixture.executable,
                    matches: restoreBinding
                )
        )

        let typedRestoreFixture = try makeFixture()
        let typedRestoreBinding =
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of:
                        typedRestoreFixture
                        .executable,
                    into:
                        typedRestoreFixture
                        .artifactRoot,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
        XCTAssertEqual(
            typedRestoreBinding.runtimeImageLayout,
            PrimeMLXRuntimeImageLayout
                .typedOptimizerRestoreProbe
        )
        XCTAssertNoThrow(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of:
                        typedRestoreFixture
                        .executable,
                    matches:
                        typedRestoreBinding,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
        )
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of:
                        typedRestoreFixture
                        .executable,
                    matches:
                        typedRestoreBinding,
                    runtimeRole:
                        .optimizerRestoreProbe
                )
        )

        let continuationFixture = try makeFixture(
            executableName:
                "PrimeNative3BMetalContinuationProbe"
        )
        let continuationBinding =
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of: continuationFixture.executable,
                    into:
                        continuationFixture.artifactRoot,
                    runtimeRole:
                        .native3BMetalContinuationProbe
                )
        XCTAssertEqual(
            continuationBinding.runtimeImageLayout,
            PrimeMLXRuntimeImageLayout
                .native3BMetalContinuationProbe
        )
        XCTAssertNoThrow(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: continuationFixture.executable,
                    matches: continuationBinding,
                    runtimeRole:
                        .native3BMetalContinuationProbe
                )
        )
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: continuationFixture.executable,
                    matches: continuationBinding,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
        )
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: continuationFixture.executable,
                    matches: continuationBinding
                )
        )
    }

    func testCaptureRejectsSafeModeSubstitution()
        throws
    {
        let fixture = try makeFixture()
        var data = try Data(
            contentsOf: fixture.metallib
        )
        data[0] ^= 0xff
        try withOwnerWritableFile(
            at: fixture.metallib
        ) {
            try data.write(to: fixture.metallib)
        }
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of: fixture.executable,
                    into: fixture.artifactRoot
                )
        )

        let infoFixture = try makeFixture()
        let infoPlist = infoFixture.metallib
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Info.plist")
        var infoData = try Data(
            contentsOf: infoPlist
        )
        infoData[0] ^= 0xff
        try withOwnerWritableFile(at: infoPlist) {
            try infoData.write(to: infoPlist)
        }
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of: infoFixture.executable,
                    into:
                        infoFixture.artifactRoot
                )
        )
    }

    func testCaptureRejectsSymlinkModeHardlinkAndXattr()
        throws
    {
        do {
            let fixture = try makeFixture()
            let original = try PinnedMLXMetallibTestSupport
                .sourceMetallibURL()
            try FileManager.default.removeItem(
                at: fixture.metallib
            )
            try FileManager.default.createSymbolicLink(
                at: fixture.metallib,
                withDestinationURL: original
            )
            XCTAssertThrowsError(
                try PrimePinnedMLXMetallib
                    .captureSibling(
                        of: fixture.executable,
                        into: fixture.artifactRoot
                    )
            )
        }
        do {
            let fixture = try makeFixture()
            XCTAssertEqual(
                chmod(fixture.metallib.path, 0o664),
                0
            )
            XCTAssertThrowsError(
                try PrimePinnedMLXMetallib
                    .captureSibling(
                        of: fixture.executable,
                        into: fixture.artifactRoot
                    )
            )
        }
        do {
            let fixture = try makeFixture()
            let secondLink = temporaryURL
                .appendingPathComponent(
                    "metallib-hardlink"
                )
            XCTAssertEqual(
                link(
                    fixture.metallib.path,
                    secondLink.path
                ),
                0
            )
            XCTAssertThrowsError(
                try PrimePinnedMLXMetallib
                    .captureSibling(
                        of: fixture.executable,
                        into: fixture.artifactRoot
                    )
            )
        }
        do {
            let fixture = try makeFixture()
            try addUnapprovedExtendedAttribute(
                at: fixture.metallib
            )
            XCTAssertThrowsError(
                try PrimePinnedMLXMetallib
                    .captureSibling(
                        of: fixture.executable,
                        into: fixture.artifactRoot
                    )
            )
        }
    }

    func testCaptureRejectsExtendedACL() throws {
        let fixture = try makeFixture()
        try addExtendedACL(at: fixture.metallib)
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of: fixture.executable,
                    into: fixture.artifactRoot
                )
        )
    }

    func testCaptureRejectsExtraBundleEntryAndLoaderShadows()
        throws
    {
        do {
            let fixture = try makeFixture()
            let extra = fixture.metallib
                .deletingLastPathComponent()
                .appendingPathComponent("extra.metallib")
            try Data("extra".utf8).write(to: extra)
            XCTAssertThrowsError(
                try PrimePinnedMLXMetallib
                    .captureSibling(
                        of: fixture.executable,
                        into: fixture.artifactRoot
                    )
            )
        }
        for relativePath in [
            "mlx.metallib",
            "Resources/mlx.metallib",
            "Resources/default.metallib",
        ] {
            let fixture = try makeFixture()
            let shadow = fixture.hostRoot
                .appendingPathComponent(relativePath)
            try FileManager.default.createDirectory(
                at: shadow.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try Data("shadow".utf8).write(
                to: shadow
            )
            XCTAssertThrowsError(
                try PrimePinnedMLXMetallib
                    .captureSibling(
                        of: fixture.executable,
                        into: fixture.artifactRoot
                    ),
                "accepted loader shadow \(relativePath)"
            )
        }
    }

    func testCaptureRejectsDynamicLoaderOverride()
        throws
    {
        let fixture = try makeFixture()
        setenv(
            "DYLD_FRAMEWORK_PATH",
            "/private/tmp/untrusted",
            1
        )
        defer {
            unsetenv("DYLD_FRAMEWORK_PATH")
        }
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of: fixture.executable,
                    into: fixture.artifactRoot
                )
        )
    }

    func testWorkingDirectoryShadowIsRejectedButExactSourceEqualityIsAllowed()
        throws
    {
        let originalDirectory =
            FileManager.default.currentDirectoryPath
        defer {
            XCTAssertTrue(
                FileManager.default
                    .changeCurrentDirectoryPath(
                        originalDirectory
                    )
            )
        }

        do {
            let fixture = try makeFixture()
            let shadow = fixture.hostRoot
                .appendingPathComponent(
                    "default.metallib"
                )
            try Data("working-directory-shadow".utf8)
                .write(to: shadow)
            XCTAssertTrue(
                FileManager.default
                    .changeCurrentDirectoryPath(
                        fixture.hostRoot.path
                    )
            )
            XCTAssertThrowsError(
                try PrimePinnedMLXMetallib
                    .captureSibling(
                        of: fixture.executable,
                        into: fixture.artifactRoot
                    )
            )
        }

        XCTAssertTrue(
            FileManager.default
                .changeCurrentDirectoryPath(
                    originalDirectory
                )
        )
        let equalityFixture = try makeFixture()
        let resources = equalityFixture.metallib
            .deletingLastPathComponent()
        XCTAssertTrue(
            FileManager.default
                .changeCurrentDirectoryPath(
                    resources.path
                )
        )
        XCTAssertNoThrow(
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of: equalityFixture.executable,
                    into:
                        equalityFixture.artifactRoot
                )
        )
    }

    func testStagedReverificationSeparatesSupervisorContextFromTargetShadows()
        throws
    {
        let fixture = try makeFixture()
        let binding =
            try PrimePinnedMLXMetallib
                .captureSibling(
                    of: fixture.executable,
                    into: fixture.artifactRoot
                )
        let supervisorContext = temporaryURL
            .appendingPathComponent(
                "supervisor-context",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: supervisorContext,
            withIntermediateDirectories: false
        )
        try Data("supervisor-only-shadow".utf8)
            .write(
                to:
                    supervisorContext
                    .appendingPathComponent(
                        "default.metallib"
                    )
            )
        let originalDirectory =
            FileManager.default.currentDirectoryPath
        defer {
            XCTAssertTrue(
                FileManager.default
                    .changeCurrentDirectoryPath(
                        originalDirectory
                    )
            )
        }
        XCTAssertTrue(
            FileManager.default
                .changeCurrentDirectoryPath(
                    supervisorContext.path
                )
        )
        XCTAssertNoThrow(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: fixture.executable,
                    matches: binding
                )
        )

        try Data("target-local-shadow".utf8)
            .write(
                to:
                    fixture.hostRoot
                    .appendingPathComponent(
                        "mlx.metallib"
                    )
            )
        XCTAssertThrowsError(
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: fixture.executable,
                    matches: binding
                )
        )
    }

    private func makeFixture(
        executableName: String =
            "PrimeGPUCalibration"
    ) throws -> Fixture {
        let identifier = UUID().uuidString
        let hostRoot = temporaryURL
            .appendingPathComponent(
                "host-\(identifier)",
                isDirectory: true
            )
        let artifactDirectory = temporaryURL
            .appendingPathComponent(
                "artifacts-\(identifier)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: hostRoot,
            withIntermediateDirectories: false
        )
        try FileManager.default.createDirectory(
            at: artifactDirectory,
            withIntermediateDirectories: false
        )
        XCTAssertEqual(chmod(hostRoot.path, 0o700), 0)
        XCTAssertEqual(
            chmod(artifactDirectory.path, 0o700),
            0
        )

        let executable = hostRoot
            .appendingPathComponent(
                executableName
            )
        try Data("Mach-O-test-host".utf8).write(
            to: executable
        )
        XCTAssertEqual(
            chmod(executable.path, 0o500),
            0
        )

        let sourceMetallib =
            try PinnedMLXMetallibTestSupport
                .sourceMetallibURL()
        let sourceBundle = sourceMetallib
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let bundle = hostRoot.appendingPathComponent(
            PrimePinnedMLXMetallib.bundleRelativePath
        )
        try FileManager.default.copyItem(
            at: sourceBundle,
            to: bundle
        )
        let metallib = hostRoot.appendingPathComponent(
            PrimePinnedMLXMetallib
                .sourceBundleRelativePath
        )
        return Fixture(
            hostRoot: hostRoot,
            executable: executable,
            metallib: metallib,
            artifactRoot: try PrimeArtifactRoot(
                directoryURL: artifactDirectory
            )
        )
    }

    private func makeXcodeDonorFixture()
        throws -> Fixture
    {
        let fixture = try makeFixture()
        try convertCanonicalInfoPlistToXcodeDonor(
            in: fixture
        )
        return fixture
    }

    private func convertCanonicalInfoPlistToXcodeDonor(
        in fixture: Fixture
    ) throws {
        let infoPlist = infoPlistURL(
            for: fixture
        )
        let canonicalData = try Data(
            contentsOf: infoPlist
        )
        XCTAssertEqual(
            UInt64(canonicalData.count),
            PrimePinnedMLXMetallib
                .expectedInfoPlistByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: canonicalData
            ),
            PrimePinnedMLXMetallib
                .expectedInfoPlistSHA256
        )
        var contents = try XCTUnwrap(
            String(
                data: canonicalData,
                encoding: .utf8
            )
        )
        let canonicalIdentifier =
            "mlx-swift.Cmlx.resources"
        let donorIdentifier =
            "ergentics-mlx-swift.Cmlx.resources"
        XCTAssertEqual(
            contents.components(
                separatedBy:
                    canonicalIdentifier
            ).count,
            2
        )
        contents = contents.replacingOccurrences(
            of: canonicalIdentifier,
            with: donorIdentifier
        )
        let donorData = Data(contents.utf8)
        XCTAssertEqual(
            UInt64(donorData.count),
            PrimePinnedMLXMetallib
                .expectedXcodeDonorInfoPlistByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: donorData
            ),
            PrimePinnedMLXMetallib
                .expectedXcodeDonorInfoPlistSHA256
        )
        try withOwnerWritableFile(
            at: infoPlist
        ) {
            try donorData.write(
                to: infoPlist
            )
        }
    }

    private func infoPlistURL(
        for fixture: Fixture
    ) -> URL {
        fixture.metallib
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Info.plist")
    }

    private func addUnapprovedExtendedAttribute(
        at url: URL
    ) throws {
        try withOwnerWritableFile(at: url) {
            let descriptor = open(
                url.path,
                O_RDWR | O_NOFOLLOW | O_CLOEXEC
            )
            guard descriptor >= 0 else {
                throw POSIXError(
                    POSIXErrorCode(rawValue: errno)!
                )
            }
            defer {
                _ = close(descriptor)
            }
            let value: [UInt8] = [1]
            let result =
                "com.ergentics.prime.unapproved"
                    .withCString { name in
                        value.withUnsafeBytes {
                            fsetxattr(
                                descriptor,
                                name,
                                $0.baseAddress,
                                $0.count,
                                0,
                                0
                            )
                        }
                    }
            guard result == 0 else {
                throw POSIXError(
                    POSIXErrorCode(rawValue: errno)!
                )
            }
        }
    }

    private func withOwnerWritableFile(
        at url: URL,
        _ mutation: () throws -> Void
    ) throws {
        guard chmod(url.path, 0o644) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        defer {
            XCTAssertEqual(chmod(url.path, 0o444), 0)
        }
        try mutation()
    }

    private func addExtendedACL(at url: URL) throws {
        var identifier: uuid_t = (
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0
        )
        guard primeTestUIDToUUID(
            geteuid(),
            &identifier
        ) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        let text =
            "!#acl 1\nuser:" +
            "\(UUID(uuid: identifier).uuidString):" +
            "\(NSUserName()):\(geteuid()):allow:read\n"
        guard let acl = text.withCString({
            acl_from_text($0)
        }) else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        defer {
            acl_free(
                UnsafeMutableRawPointer(acl)
            )
        }
        guard acl_set_file(
            url.path,
            ACL_TYPE_EXTENDED,
            acl
        ) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
    }
}
