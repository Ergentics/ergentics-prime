// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) @testable import PrimeCore
import XCTest

/// Filesystem qualification using byte copies of the actual tracked calibrated
/// resources. No fixture executable, Metal device, or model is ever run.
final class PrimeValidationDriverV2PinnedBundleInputTests: XCTestCase {
    func testTrackedCalibratedBytesStageFourIdenticalImmutableFilesAndReadBack() throws {
        let f = try Fixture(); defer { f.cleanup() }
        let rootFD = try f.primeRoot.duplicateTrustedRootDescriptorForInventory()
        defer { _ = close(rootFD) }
        let before = try PrimeValidationDriverV2PinnedBundleInputReadback.capture(
            primeRootDescriptor: rootFD, deadlineNanoseconds: f.deadline)
        let input = try f.capture()
        XCTAssertEqual(input.observation, before.observation)
        XCTAssertEqual(input.observation.files.count, 2)
        XCTAssertEqual(Set(input.observation.files.map(\.sha256)),
            Set([PrimePinnedMLXMetallib.expectedSHA256, PrimePinnedMLXMetallib.expectedInfoPlistSHA256]))
        let staged = try input.stage(into: f.workspaceRoot, deadlineNanoseconds: f.deadline)
        XCTAssertEqual(staged.destinations.count, 4)
        XCTAssertTrue(staged.exclusivePublicationObserved)
        XCTAssertTrue(staged.durableSynchronizationObserved)
        XCTAssertEqual(Set(staged.destinations.map { $0.metadata.inode }).count, 4)
        for file in staged.destinations {
            let expected = file.relativePath.hasSuffix("Info.plist") ? f.plist : f.metallib
            XCTAssertEqual(try Data(contentsOf: f.workspace.appendingPathComponent(file.relativePath)), expected)
            XCTAssertEqual(file.metadata.mode & 0o7777, 0o444)
            XCTAssertEqual(file.metadata.linkCount, 1)
            XCTAssertEqual(file.sha256, PrimeSHA256.hexDigest(of: expected))
        }
        let bytes = try PrimeCanonicalJSON.encode(staged)
        XCTAssertEqual(try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2PinnedBundleStagingObservation.self, from: bytes), staged)
        let workspaceFD = try f.workspaceRoot.duplicateTrustedRootDescriptorForInventory()
        defer { _ = close(workspaceFD) }
        let reader = try PrimeValidationDriverV2PinnedBundleReadback.capture(
            primeRootDescriptor: rootFD, workspaceRootDescriptor: workspaceFD,
            expected: staged, deadlineNanoseconds: f.deadline)
        XCTAssertEqual(try reader.revalidate(), staged)
        XCTAssertEqual(try before.revalidate(), staged.input)
        XCTAssertNoThrow(try input.checkpointMetadata())
        XCTAssertNoThrow(try input.revalidate())
        // The subsequent complete bundle capture can retain the staged tree.
        let artifacts = try PrimeValidationDriverV2BuildArtifacts.capture(
            workspaceRoot: f.workspaceRoot, scratchRelativePath: "root-release-build",
            testBundleRelativePath: PrimeValidationDriverV2PinnedBundleInput.testBundle,
            metallibRelativePath: PrimeValidationDriverV2PinnedBundleInput.cliBundle
                + "/Contents/Resources/default.metallib",
            expectedMetallibByteCount: PrimePinnedMLXMetallib.expectedByteCount,
            expectedMetallibSHA256: PrimePinnedMLXMetallib.expectedSHA256,
            artifactRoot: f.artifactRoot, deadlineNanoseconds: f.deadline)
        XCTAssertTrue(artifacts.observation.bundleEntries.contains {
            $0.relativePath == "Contents/Resources/mlx-swift_Cmlx.bundle/Contents/Info.plist"
                && $0.sha256 == PrimePinnedMLXMetallib.expectedInfoPlistSHA256
        })
        XCTAssertNoThrow(try input.revalidate())
        XCTAssertEqual(try Data(contentsOf: f.sourceMetallib), f.metallib)
        XCTAssertEqual(try Data(contentsOf: f.sourcePlist), f.plist)
        XCTAssertEqual(try Data(contentsOf: f.outside), f.outsideBytes)
    }

    func testMissingTrackedMetallibRejects() throws {
        let f = try Fixture(); defer { f.cleanup() }
        try FileManager.default.removeItem(at: f.sourceMetallib)
        XCTAssertThrowsError(try f.capture())
        XCTAssertFalse(FileManager.default.fileExists(atPath: f.cli.path))
    }

    func testWrongCalibratedBytesReject() throws {
        let f = try Fixture(); defer { f.cleanup() }
        var wrong = f.plist; wrong[wrong.startIndex] ^= 1
        try wrong.write(to: f.sourcePlist)
        XCTAssertThrowsError(try f.capture())
    }

    func testSourceFileSymlinkRejectsAndOutsideFileIsPreserved() throws {
        let f = try Fixture(); defer { f.cleanup() }
        try FileManager.default.removeItem(at: f.sourcePlist)
        XCTAssertEqual(symlink(f.outside.path, f.sourcePlist.path), 0)
        XCTAssertThrowsError(try f.capture())
        XCTAssertEqual(try Data(contentsOf: f.outside), f.outsideBytes)
    }

    func testSourceHardlinkRejects() throws {
        let f = try Fixture(); defer { f.cleanup() }
        let alias = f.base.appendingPathComponent("extra-plist-link")
        XCTAssertEqual(link(f.sourcePlist.path, alias.path), 0)
        XCTAssertThrowsError(try f.capture())
    }

    func testSourceMetadataDriftPoisonsRetainedInput() throws {
        let f = try Fixture(); defer { f.cleanup() }
        let input = try f.capture()
        XCTAssertEqual(chmod(f.sourceMetallib.path, 0o600), 0)
        XCTAssertThrowsError(try input.checkpointMetadata())
        XCTAssertEqual(chmod(f.sourceMetallib.path, 0o644), 0)
        XCTAssertThrowsError(try input.revalidate())
        XCTAssertThrowsError(try input.stage(into: f.workspaceRoot, deadlineNanoseconds: f.deadline))
    }

    func testPreexistingCLIBundleRejectsWithoutPublishingIntoTestBundle() throws {
        let f = try Fixture(); defer { f.cleanup() }
        let input = try f.capture()
        try FileManager.default.createDirectory(at: f.cli, withIntermediateDirectories: false,
            attributes: [.posixPermissions: NSNumber(value: 0o700)])
        XCTAssertThrowsError(try input.stage(into: f.workspaceRoot, deadlineNanoseconds: f.deadline))
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: f.cli.path), [])
        XCTAssertFalse(FileManager.default.fileExists(atPath: f.testResource.path))
        XCTAssertEqual(try Data(contentsOf: f.outside), f.outsideBytes)
    }

    func testPreexistingTestResourceBundleRejectsBeforeCreatingCLIBundle() throws {
        let f = try Fixture(); defer { f.cleanup() }
        let input = try f.capture()
        try FileManager.default.createDirectory(at: f.testResource, withIntermediateDirectories: true,
            attributes: [.posixPermissions: NSNumber(value: 0o700)])
        XCTAssertThrowsError(try input.stage(into: f.workspaceRoot, deadlineNanoseconds: f.deadline))
        XCTAssertFalse(FileManager.default.fileExists(atPath: f.cli.path))
    }

    func testSymlinkedTestResourcesParentRejectsWithoutOutsideWrites() throws {
        let f = try Fixture(); defer { f.cleanup() }
        let input = try f.capture()
        let path = f.workspace.appendingPathComponent(
            PrimeValidationDriverV2PinnedBundleInput.testBundle + "/Contents/Resources")
        XCTAssertEqual(symlink(f.base.path, path.path), 0)
        XCTAssertThrowsError(try input.stage(into: f.workspaceRoot, deadlineNanoseconds: f.deadline))
        XCTAssertFalse(FileManager.default.fileExists(atPath: f.base.appendingPathComponent("mlx-swift_Cmlx.bundle").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: f.cli.path))
    }

    func testMissingGeneratedExecutableRejectsWithoutMakingResourceBundles() throws {
        let f = try Fixture(); defer { f.cleanup() }
        let input = try f.capture()
        try FileManager.default.removeItem(at: f.executable)
        XCTAssertThrowsError(try input.stage(into: f.workspaceRoot, deadlineNanoseconds: f.deadline))
        XCTAssertFalse(FileManager.default.fileExists(atPath: f.cli.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: f.testResource.path))
    }

    func testStagingIsOneShotAndChangedDestinationRejectsRevalidation() throws {
        let f = try Fixture(); defer { f.cleanup() }
        let input = try f.capture()
        let value = try input.stage(into: f.workspaceRoot, deadlineNanoseconds: f.deadline)
        XCTAssertThrowsError(try input.stage(into: f.workspaceRoot, deadlineNanoseconds: f.deadline))
        XCTAssertNoThrow(try input.revalidate())
        let target = f.workspace.appendingPathComponent(value.destinations[0].relativePath)
        XCTAssertEqual(chmod(target.path, 0o644), 0)
        XCTAssertThrowsError(try input.revalidate())
        XCTAssertEqual(try Data(contentsOf: f.sourceMetallib), f.metallib)
    }

    func testExpiredInputOrStagingDeadlineRejects() throws {
        let f = try Fixture(); defer { f.cleanup() }
        XCTAssertThrowsError(try PrimeValidationDriverV2PinnedBundleInput.capture(
            primeRoot: f.primeRoot, deadlineNanoseconds: 0))
        let input = try f.capture()
        XCTAssertThrowsError(try input.stage(into: f.workspaceRoot, deadlineNanoseconds: 0))
        XCTAssertFalse(FileManager.default.fileExists(atPath: f.cli.path))
    }

    private final class Fixture {
        let base: URL
        let prime: URL
        let workspace: URL
        let primeRoot: PrimeArtifactRoot
        let workspaceRoot: PrimeArtifactRoot
        let artifactRoot: PrimeArtifactRoot
        let sourceMetallib: URL
        let sourcePlist: URL
        let executable: URL
        let outside: URL
        let metallib: Data
        let plist: Data
        let outsideBytes = Data("outside pinned staging; preserve\n".utf8)
        let deadline = DispatchTime.now().uptimeNanoseconds + 120_000_000_000
        var cli: URL { workspace.appendingPathComponent(PrimeValidationDriverV2PinnedBundleInput.cliBundle) }
        var testResource: URL { workspace.appendingPathComponent(PrimeValidationDriverV2PinnedBundleInput.testResourceBundle) }

        init() throws {
            var repo = URL(fileURLWithPath: #filePath)
            for _ in 0..<5 { repo.deleteLastPathComponent() }
            metallib = try Data(contentsOf: repo.appendingPathComponent(PrimeValidationDriverV2PinnedBundleInput.sourceMetallib))
            plist = try Data(contentsOf: repo.appendingPathComponent(PrimeValidationDriverV2PinnedBundleInput.sourceInfoPlist))
            guard UInt64(metallib.count) == PrimePinnedMLXMetallib.expectedByteCount,
                  PrimeSHA256.hexDigest(of: metallib) == PrimePinnedMLXMetallib.expectedSHA256,
                  UInt64(plist.count) == PrimePinnedMLXMetallib.expectedInfoPlistByteCount,
                  PrimeSHA256.hexDigest(of: plist) == PrimePinnedMLXMetallib.expectedInfoPlistSHA256 else {
                throw PrimeDurableArtifactError.invalidSemantics("tracked calibration fixture bytes do not match constants")
            }
            var pattern = Array("/private/tmp/prime-pinned-bundle-tests-XXXXXX".utf8CString)
            guard let root = mkdtemp(&pattern) else { throw POSIXError(.EIO) }
            base = URL(fileURLWithPath: String(cString: root), isDirectory: true)
            prime = base.appendingPathComponent("prime"); workspace = base.appendingPathComponent("workspace")
            outside = base.appendingPathComponent("outside")
            sourceMetallib = prime.appendingPathComponent(PrimeValidationDriverV2PinnedBundleInput.sourceMetallib)
            sourcePlist = prime.appendingPathComponent(PrimeValidationDriverV2PinnedBundleInput.sourceInfoPlist)
            executable = workspace.appendingPathComponent(PrimeValidationDriverV2PinnedBundleInput.testExecutable)
            let artifacts = base.appendingPathComponent("captured-artifacts")
            do {
                for directory in [sourceMetallib.deletingLastPathComponent(), executable.deletingLastPathComponent(), artifacts] {
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true,
                        attributes: [.posixPermissions: NSNumber(value: 0o700)])
                }
                try metallib.write(to: sourceMetallib); try plist.write(to: sourcePlist)
                try Data("filesystem executable placeholder; never run\n".utf8).write(to: executable)
                try outsideBytes.write(to: outside)
                guard chmod(sourceMetallib.path, 0o644) == 0, chmod(sourcePlist.path, 0o644) == 0,
                      chmod(executable.path, 0o755) == 0 else { throw POSIXError(.EIO) }
                primeRoot = try PrimeArtifactRoot(directoryURL: prime)
                workspaceRoot = try PrimeArtifactRoot(directoryURL: workspace)
                artifactRoot = try PrimeArtifactRoot(directoryURL: artifacts)
            } catch { try? FileManager.default.removeItem(at: base); throw error }
        }
        func capture() throws -> PrimeValidationDriverV2PinnedBundleInput {
            try .capture(primeRoot: primeRoot, deadlineNanoseconds: deadline)
        }
        func cleanup() { try? FileManager.default.removeItem(at: base) }
    }
}
