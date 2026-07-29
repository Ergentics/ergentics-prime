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

    private func makeFixture() throws -> Fixture {
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
                "PrimeGPUCalibration"
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
