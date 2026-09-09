import CryptoKit
import Darwin
import Foundation
import XCTest

final class VMWorkspaceTests: XCTestCase {
    private func withFolder(_ body: (URL) throws -> Void) throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("VMWorkspaceTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false,
                                               attributes: [.posixPermissions: 0o700])
        defer { try? FileManager.default.removeItem(at: url) }
        try body(url)
    }
    private func installer(_ root: URL) throws -> URL {
        let url = root.appendingPathComponent("arm64-linux.iso")
        var data = Data(repeating: 0, count: 65_536)
        data.replaceSubrange(32_769..<32_774, with: Data("CD001".utf8))
        try data.write(to: url)
        return url
    }
    private func prepare(_ root: URL) throws -> (VMWorkspaceStore, VMWorkspace) {
        let store = try VMWorkspaceStore(root: root.appendingPathComponent("VMs"))
        let workspace = try store.prepare(setup: VMWorkspaceSetup(name: "Fixture", cpuCount: 2,
            memoryGiB: 2, diskGiB: 16), iso: installer(root), machineIdentifier: Data([1, 2, 3])) { _ in }
        let efi = store.efiURL(for: workspace.id)
        try Data([0, 1, 2, 3]).write(to: efi)
        XCTAssertEqual(chmod(efi.path, 0o600), 0)
        try store.save(workspace)
        return (store, workspace)
    }

    func testVMWorkspaceImportCopiesBytesAndCreatesSparseBoundedDisk() throws {
        try withFolder { root in
            let (store, workspace) = try prepare(root)
            let source = try Data(contentsOf: root.appendingPathComponent("arm64-linux.iso"))
            XCTAssertEqual(try Data(contentsOf: store.installerURL(for: workspace.id)), source)
            XCTAssertEqual(workspace.installerSHA256, SHA256.hash(data: source).map { String(format: "%02x", $0) }.joined())
            XCTAssertEqual(workspace.installerBytes, 65_536)
            var info = stat()
            XCTAssertEqual(lstat(store.diskURL(for: workspace.id).path, &info), 0)
            XCTAssertEqual(info.st_size, 16 * VMWorkspaceStore.gib)
            XCTAssertLessThan(info.st_blocks * 512, 1_048_576)
            XCTAssertEqual(info.st_mode & 0o777, 0o600)
            XCTAssertEqual(try store.load(workspace.id), workspace)
            XCTAssertNoThrow(try store.validateFiles(workspace))
        }
    }

    func testVMWorkspaceLockExcludesAnotherOwnerAndReleasesOnClose() throws {
        try withFolder { root in
            let (store, workspace) = try prepare(root)
            var lease: VMWorkspaceLease? = try VMWorkspaceLease(directory: store.directory(for: workspace.id))
            XCTAssertNotNil(lease)
            XCTAssertThrowsError(try VMWorkspaceLease(directory: store.directory(for: workspace.id)))
            lease = nil
            XCTAssertNoThrow(try VMWorkspaceLease(directory: store.directory(for: workspace.id)))
        }
    }

    func testVMWorkspaceRejectsSourceSymlinkAndPreservesPartialDirectory() throws {
        try withFolder { root in
            let source = try installer(root)
            let link = root.appendingPathComponent("link.iso")
            try FileManager.default.createSymbolicLink(at: link, withDestinationURL: source)
            let store = try VMWorkspaceStore(root: root.appendingPathComponent("VMs"))
            XCTAssertThrowsError(try store.prepare(setup: .init(), iso: link, machineIdentifier: Data([1])) { _ in })
            let listing = try store.list()
            XCTAssertTrue(listing.workspaces.isEmpty)
            XCTAssertEqual(listing.warnings.count, 1)
            XCTAssertEqual(try Data(contentsOf: source).count, 65_536)
        }
    }

    func testVMWorkspaceRejectsNonISOAndDoesNotAdoptPartialFiles() throws {
        try withFolder { root in
            let source = root.appendingPathComponent("wrong.iso")
            try Data(repeating: 0, count: 65_536).write(to: source)
            let store = try VMWorkspaceStore(root: root.appendingPathComponent("VMs"))
            XCTAssertThrowsError(try store.prepare(setup: .init(), iso: source, machineIdentifier: Data([1])) { _ in })
            XCTAssertTrue(try store.list().workspaces.isEmpty)
        }
    }

    func testVMWorkspaceRejectsTraversingAndMalformedSuspendedStateNames() throws {
        XCTAssertFalse(VMWorkspaceStore.validStateName("../outside.vzsave"))
        XCTAssertFalse(VMWorkspaceStore.validStateName("State-../../outside.vzsave"))
        XCTAssertFalse(VMWorkspaceStore.validStateName("State-\(UUID().uuidString).vzsave"))
        XCTAssertTrue(VMWorkspaceStore.validStateName("State-\(UUID().uuidString.lowercased()).vzsave"))
        try withFolder { root in
            let (store, original) = try prepare(root)
            var changed = original
            changed.suspendedState = "../outside.vzsave"
            try store.save(changed)
            XCTAssertThrowsError(try store.load(changed.id))
            XCTAssertThrowsError(try store.stateURL(for: changed))
        }
    }

    func testVMWorkspaceRejectsWritableFilesReplacedByLinksOrWrongSizes() throws {
        try withFolder { root in
            let (store, workspace) = try prepare(root)
            let disk = store.diskURL(for: workspace.id)
            let original = disk.appendingPathExtension("retained")
            try FileManager.default.moveItem(at: disk, to: original)
            try FileManager.default.createSymbolicLink(at: disk, withDestinationURL: original)
            XCTAssertThrowsError(try store.validateFiles(workspace))
            try FileManager.default.removeItem(at: disk)
            try Data([1]).write(to: disk)
            XCTAssertEqual(chmod(disk.path, 0o600), 0)
            XCTAssertThrowsError(try store.validateFiles(workspace))
        }
    }

    func testVMWorkspaceRejectsSharedConfigurationAndInvalidResourceBudget() throws {
        XCTAssertThrowsError(try VMWorkspaceSetup(name: "bad", cpuCount: 9, memoryGiB: 2, diskGiB: 16).validate())
        XCTAssertThrowsError(try VMWorkspaceSetup(name: "bad", cpuCount: 2, memoryGiB: 17, diskGiB: 16).validate())
        XCTAssertThrowsError(try VMWorkspaceSetup(name: "bad", cpuCount: 2, memoryGiB: 2, diskGiB: 129).validate())
        XCTAssertThrowsError(try VMWorkspaceSetup(name: "\n", cpuCount: 2, memoryGiB: 2, diskGiB: 16).validate())
        try withFolder { root in
            let (store, workspace) = try prepare(root)
            let config = store.directory(for: workspace.id).appendingPathComponent("Workspace.json")
            XCTAssertEqual(chmod(config.path, 0o644), 0)
            XCTAssertThrowsError(try store.load(workspace.id))
        }
    }

    func testVMWorkspaceNewSuspendFileNeverOverwritesPreviousState() throws {
        try withFolder { root in
            let (store, workspace) = try prepare(root)
            let first = try store.newStateURL(workspace)
            try Data([42]).write(to: first)
            let second = try store.newStateURL(workspace)
            XCTAssertNotEqual(first, second)
            XCTAssertEqual(try Data(contentsOf: first), Data([42]))
        }
    }

    func testVMWorkspaceActivityAppendsAndPreservesEarlierErrors() throws {
        try withFolder { root in
            let (store, workspace) = try prepare(root)
            try store.record("Error: installer unavailable", workspace: workspace)
            let url = store.directory(for: workspace.id).appendingPathComponent("Activity.jsonl")
            let earlier = try Data(contentsOf: url)
            try store.record("Retried by user", workspace: workspace)
            let later = try Data(contentsOf: url)
            XCTAssertTrue(later.starts(with: earlier))
            XCTAssertEqual(String(decoding: later, as: UTF8.self).split(separator: "\n").count, 2)
        }
    }
}

extension VMWorkspaceTests {
    private func suspended(_ root: URL) throws -> (VMWorkspaceStore, VMWorkspace) {
        let (store, original) = try prepare(root)
        var workspace = original
        let state = try store.newStateURL(workspace)
        try Data([40, 41, 42]).write(to: state)
        XCTAssertEqual(chmod(state.path, 0o600), 0)
        workspace.suspendedState = state.lastPathComponent
        workspace.suspendedFiles = try store.bindSuspendedFiles(workspace)
        try store.save(workspace)
        return (store, workspace)
    }

    func testVMWorkspaceReloadsMetadataOnlyAfterExclusiveLease() throws {
        try withFolder { root in
            let (store, cached) = try prepare(root)
            do {
                let writer = try store.acquire(cached.id)
                var changed = writer.workspace
                changed.installerAttached = false
                try store.save(changed)
                XCTAssertThrowsError(try store.acquire(cached.id))
                withExtendedLifetime(writer.lease) {}
            }
            let fresh = try store.acquire(cached.id)
            XCTAssertTrue(cached.installerAttached)
            XCTAssertFalse(fresh.workspace.installerAttached)
            withExtendedLifetime(fresh.lease) {}
        }
    }

    func testVMWorkspaceSuspendedBindingSurvivesMetadataRoundtrip() throws {
        try withFolder { root in
            let (store, workspace) = try suspended(root)
            let acquired = try store.acquire(workspace.id)
            XCTAssertEqual(acquired.workspace.suspendedFiles, workspace.suspendedFiles)
            XCTAssertNoThrow(try store.verifySuspendedFiles(acquired.workspace))
            withExtendedLifetime(acquired.lease) {}
        }
    }

    func testVMWorkspaceRefusesSameSizedMountedFileEditsAfterSuspend() throws {
        for component in ["disk", "efi", "state", "installer"] {
            try withFolder { root in
                let (store, workspace) = try suspended(root)
                let url: URL
                switch component {
                case "disk": url = store.diskURL(for: workspace.id)
                case "efi": url = store.efiURL(for: workspace.id)
                case "installer": url = store.installerURL(for: workspace.id)
                default: url = try store.stateURL(for: workspace)
                }
                var before = stat()
                XCTAssertEqual(lstat(url.path, &before), 0)
                let fd = Darwin.open(url.path, O_WRONLY | O_NOFOLLOW | O_CLOEXEC)
                XCTAssertGreaterThanOrEqual(fd, 0)
                var byte: UInt8 = 17
                XCTAssertEqual(pwrite(fd, &byte, 1, 0), 1)
                XCTAssertEqual(fsync(fd), 0)
                close(fd)
                var after = stat()
                XCTAssertEqual(lstat(url.path, &after), 0)
                XCTAssertEqual(before.st_size, after.st_size)
                let acquired = try store.acquire(workspace.id)
                XCTAssertThrowsError(try store.verifySuspendedFiles(acquired.workspace), component)
                withExtendedLifetime(acquired.lease) {}
            }
        }
    }

    func testVMWorkspaceRefusesReplacedSuspendFileWithIdenticalBytes() throws {
        try withFolder { root in
            let (store, workspace) = try suspended(root)
            let state = try store.stateURL(for: workspace)
            let retained = state.appendingPathExtension("retained")
            try FileManager.default.moveItem(at: state, to: retained)
            try Data(contentsOf: retained).write(to: state)
            XCTAssertEqual(chmod(state.path, 0o600), 0)
            XCTAssertEqual(try Data(contentsOf: state), try Data(contentsOf: retained))
            XCTAssertThrowsError(try store.verifySuspendedFiles(workspace))
        }
    }

    func testVMWorkspaceRejectsDirectoryLinkBeforeCreatingRunLock() throws {
        try withFolder { root in
            let (store, workspace) = try prepare(root)
            let directory = store.directory(for: workspace.id)
            let retained = directory.appendingPathExtension("retained")
            let outside = root.appendingPathComponent("outside")
            try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: false,
                                                   attributes: [.posixPermissions: 0o700])
            try FileManager.default.moveItem(at: directory, to: retained)
            try FileManager.default.createSymbolicLink(at: directory, withDestinationURL: outside)
            XCTAssertThrowsError(try store.acquire(workspace.id))
            XCTAssertFalse(FileManager.default.fileExists(atPath: outside.appendingPathComponent("Run.lock").path))
        }
    }

    func testVMWorkspaceOldDraftAndUnboundSuspendMetadataStayUnadmitted() throws {
        try withFolder { root in
            let (store, original) = try prepare(root)
            var changed = original
            changed.version = 1
            try store.save(changed)
            XCTAssertThrowsError(try store.load(changed.id))
            changed.version = VMWorkspace.formatVersion
            changed.suspendedState = "State-\(UUID().uuidString.lowercased()).vzsave"
            try store.save(changed)
            XCTAssertThrowsError(try store.load(changed.id))
        }
    }

    func testVMWorkspaceDetachedInstallerIsNotPartOfSuspendedConfiguration() throws {
        try withFolder { root in
            let (store, original) = try suspended(root)
            var workspace = original
            workspace.installerAttached = false
            workspace.suspendedFiles = try store.bindSuspendedFiles(workspace)
            XCTAssertNil(workspace.suspendedFiles?.installer)
            try store.save(workspace)
            try FileManager.default.removeItem(at: store.installerURL(for: workspace.id))
            let acquired = try store.acquire(workspace.id)
            XCTAssertNoThrow(try store.verifySuspendedFiles(acquired.workspace))
            withExtendedLifetime(acquired.lease) {}
        }
    }
}
