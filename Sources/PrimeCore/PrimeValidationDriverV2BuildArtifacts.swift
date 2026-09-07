// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin
import Dispatch
import Foundation

/// Native source metadata; access time is deliberately excluded because the
/// descriptor reads used to capture the artifact may change it on APFS.
@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2BuildArtifactMetadataObservation:
    Codable, Equatable, Sendable
{
    public let deviceID: UInt64
    public let inode: UInt64
    public let mode: UInt32
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let linkCount: UInt64
    public let specialDeviceID: UInt64
    public let byteCount: Int64
    public let allocatedBlocks: Int64
    public let blockSize: Int64
    public let flags: UInt32
    public let generation: UInt32
    public let modificationSeconds: Int64
    public let modificationNanoseconds: Int64
    public let statusChangeSeconds: Int64
    public let statusChangeNanoseconds: Int64
    public let birthSeconds: Int64
    public let birthNanoseconds: Int64

    fileprivate init(_ value: stat) {
        deviceID = UInt64(bitPattern: Int64(value.st_dev))
        inode = UInt64(value.st_ino)
        mode = UInt32(value.st_mode)
        ownerUserID = value.st_uid
        ownerGroupID = value.st_gid
        linkCount = UInt64(value.st_nlink)
        specialDeviceID = UInt64(bitPattern: Int64(value.st_rdev))
        byteCount = value.st_size
        allocatedBlocks = value.st_blocks
        blockSize = Int64(value.st_blksize)
        flags = value.st_flags
        generation = value.st_gen
        modificationSeconds = Int64(value.st_mtimespec.tv_sec)
        modificationNanoseconds = Int64(value.st_mtimespec.tv_nsec)
        statusChangeSeconds = Int64(value.st_ctimespec.tv_sec)
        statusChangeNanoseconds = Int64(value.st_ctimespec.tv_nsec)
        birthSeconds = Int64(value.st_birthtimespec.tv_sec)
        birthNanoseconds = Int64(value.st_birthtimespec.tv_nsec)
    }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2BuildArtifactEntryObservation:
    Codable, Equatable, Sendable
{
    public let relativePath: String
    public let kind: String
    public let mode: UInt16
    public let byteCount: UInt64?
    public let sha256: String?
    public let sourceMetadata:
        PrimeValidationDriverV2BuildArtifactMetadataObservation
}

/// Descriptor-free transport values. Decoding does not create a live capture
/// owner or authorize a process; consumers must join these values to native
/// observations through their already-held roots.
@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2BuildArtifactsObservation:
    Codable, Equatable, Sendable
{
    public let testBundleRelativePath: String
    public let testBundleMetadata: PrimeValidationDriverV2BuildArtifactMetadataObservation
    public let capturedBundleRelativePath: String
    public let bundleEntries:
        [PrimeValidationDriverV2BuildArtifactEntryObservation]
    public let metallibRelativePath: String
    public let metallibByteCount: UInt64
    public let metallibSHA256: String
    public let metallibMetadata: PrimeValidationDriverV2BuildArtifactMetadataObservation
    public let capturedMetallib: PrimeArtifactBinding
    public let artifactRootIdentity: PrimeArtifactRootIdentity
    public let immutableArtifactBindings: [PrimeArtifactBinding]
    public let capturedArtifactMetadata:
        [String: PrimeValidationDriverV2BuildArtifactMetadataObservation]
    public let captureStartedAtUptimeNanoseconds: UInt64
    public let captureCompletedAtUptimeNanoseconds: UInt64
    public let exclusivePublicationObserved: Bool
    public let durableSynchronizationObserved: Bool
    public let sourceNamesAndDescriptorsRejoined: Bool
}

extension PrimeValidationDriverV2BuildArtifactsObservation {
    private enum CodingKeys: String, CodingKey {
        case testBundleRelativePath, testBundleMetadata, capturedBundleRelativePath
        case bundleEntries, metallibRelativePath, metallibByteCount, metallibSHA256
        case metallibMetadata, capturedMetallib, artifactRootIdentity
        case immutableArtifactBindings, capturedArtifactMetadata
        case captureStartedAtUptimeNanoseconds, captureCompletedAtUptimeNanoseconds
        case exclusivePublicationObserved, durableSynchronizationObserved
        case sourceNamesAndDescriptorsRejoined
    }

    // A local transport projection avoids changing the general root type.
    private struct RootIdentity: Codable {
        let deviceID: UInt64
        let inode: UInt64
        let ownerUserID: UInt32
        let ownerGroupID: UInt32
        let actualMode: UInt16
        let linkCount: UInt64
        let modificationSeconds: Int64
        let modificationNanoseconds: Int64
        let statusChangeSeconds: Int64
        let statusChangeNanoseconds: Int64

        init(_ value: PrimeArtifactRootIdentity) {
            deviceID = value.deviceID; inode = value.inode
            ownerUserID = value.ownerUserID; ownerGroupID = value.ownerGroupID
            actualMode = value.actualMode; linkCount = value.linkCount
            modificationSeconds = value.modificationSeconds
            modificationNanoseconds = value.modificationNanoseconds
            statusChangeSeconds = value.statusChangeSeconds
            statusChangeNanoseconds = value.statusChangeNanoseconds
        }

        var value: PrimeArtifactRootIdentity {
            .init(deviceID: deviceID, inode: inode, ownerUserID: ownerUserID,
                ownerGroupID: ownerGroupID, actualMode: actualMode, linkCount: linkCount,
                modificationSeconds: modificationSeconds,
                modificationNanoseconds: modificationNanoseconds,
                statusChangeSeconds: statusChangeSeconds,
                statusChangeNanoseconds: statusChangeNanoseconds)
        }
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        testBundleRelativePath = try c.decode(String.self, forKey: .testBundleRelativePath)
        testBundleMetadata = try c.decode(PrimeValidationDriverV2BuildArtifactMetadataObservation.self,
            forKey: .testBundleMetadata)
        capturedBundleRelativePath = try c.decode(String.self, forKey: .capturedBundleRelativePath)
        bundleEntries = try c.decode([PrimeValidationDriverV2BuildArtifactEntryObservation].self,
            forKey: .bundleEntries)
        metallibRelativePath = try c.decode(String.self, forKey: .metallibRelativePath)
        metallibByteCount = try c.decode(UInt64.self, forKey: .metallibByteCount)
        metallibSHA256 = try c.decode(String.self, forKey: .metallibSHA256)
        metallibMetadata = try c.decode(PrimeValidationDriverV2BuildArtifactMetadataObservation.self,
            forKey: .metallibMetadata)
        capturedMetallib = try c.decode(PrimeArtifactBinding.self, forKey: .capturedMetallib)
        artifactRootIdentity = try c.decode(RootIdentity.self, forKey: .artifactRootIdentity).value
        immutableArtifactBindings = try c.decode([PrimeArtifactBinding].self,
            forKey: .immutableArtifactBindings)
        capturedArtifactMetadata = try c.decode(
            [String: PrimeValidationDriverV2BuildArtifactMetadataObservation].self,
            forKey: .capturedArtifactMetadata)
        captureStartedAtUptimeNanoseconds = try c.decode(UInt64.self,
            forKey: .captureStartedAtUptimeNanoseconds)
        captureCompletedAtUptimeNanoseconds = try c.decode(UInt64.self,
            forKey: .captureCompletedAtUptimeNanoseconds)
        exclusivePublicationObserved = try c.decode(Bool.self, forKey: .exclusivePublicationObserved)
        durableSynchronizationObserved = try c.decode(Bool.self, forKey: .durableSynchronizationObserved)
        sourceNamesAndDescriptorsRejoined = try c.decode(Bool.self,
            forKey: .sourceNamesAndDescriptorsRejoined)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(testBundleRelativePath, forKey: .testBundleRelativePath)
        try c.encode(testBundleMetadata, forKey: .testBundleMetadata)
        try c.encode(capturedBundleRelativePath, forKey: .capturedBundleRelativePath)
        try c.encode(bundleEntries, forKey: .bundleEntries)
        try c.encode(metallibRelativePath, forKey: .metallibRelativePath)
        try c.encode(metallibByteCount, forKey: .metallibByteCount)
        try c.encode(metallibSHA256, forKey: .metallibSHA256)
        try c.encode(metallibMetadata, forKey: .metallibMetadata)
        try c.encode(capturedMetallib, forKey: .capturedMetallib)
        try c.encode(RootIdentity(artifactRootIdentity), forKey: .artifactRootIdentity)
        try c.encode(immutableArtifactBindings, forKey: .immutableArtifactBindings)
        try c.encode(capturedArtifactMetadata, forKey: .capturedArtifactMetadata)
        try c.encode(captureStartedAtUptimeNanoseconds, forKey: .captureStartedAtUptimeNanoseconds)
        try c.encode(captureCompletedAtUptimeNanoseconds, forKey: .captureCompletedAtUptimeNanoseconds)
        try c.encode(exclusivePublicationObserved, forKey: .exclusivePublicationObserved)
        try c.encode(durableSynchronizationObserved, forKey: .durableSynchronizationObserved)
        try c.encode(sourceNamesAndDescriptorsRejoined, forKey: .sourceNamesAndDescriptorsRejoined)
    }
}

/// One generated-build capture below roots already owned by the F handoff.
/// It never launches a process or acquires authority through an absolute URL.
/// Source symlinks, hardlinked files, special nodes and zero-byte files reject.
/// Failed exclusive publication leaves evidence in place and is not retried.
final class PrimeValidationDriverV2BuildArtifacts: @unchecked Sendable {
    static let scratchPath = "root-release-build"
    static let testBundlePath = scratchPath
        + "/arm64-apple-macosx/release/ErgenticsPrimePackageTests.xctest"
    static let metallibPath = scratchPath
        + "/arm64-apple-macosx/release/mlx-swift_Cmlx.bundle"
        + "/Contents/Resources/default.metallib"
    private static let bundleExecutable =
        "Contents/MacOS/ErgenticsPrimePackageTests"
    private static let copiedBundle = "test-bundle"
    private static let copiedMetallib = "default.metallib"
    private static let maximumFiles = 8_192
    private static let maximumDirectories = 8_192
    private static let maximumDepth = 32
    private static let maximumFileBytes: UInt64 = 1 << 30
    private static let maximumAggregateBytes: UInt64 = 8 << 30
    private static let maximumMetallibBytes: UInt64 = 64 << 20
    private static let maximumOperationNanoseconds: UInt64 = 300_000_000_000

    let observation: PrimeValidationDriverV2BuildArtifactsObservation
    private let workspaceRoot: PrimeArtifactRoot
    private let artifactRoot: PrimeArtifactRoot
    private let sourceNodes: [Node]
    private let copiedNodes: [Node]
    private let sourceHashes: [String: String]
    private let copiedHashes: [String: String]
    private let deadlineNanoseconds: UInt64
    private let lock = NSLock()
    private var poisoned = false

    private typealias Metadata =
        PrimeValidationDriverV2BuildArtifactMetadataObservation

    private struct Filesystem: Equatable {
        let device: UInt64
        let word0: Int32
        let word1: Int32
    }

    private final class Descriptor {
        let value: Int32
        init(_ value: Int32) { self.value = value }
        deinit { _ = close(value) }
    }

    /// Parents are retained in one direction; each descriptor has one owner.
    private final class Node {
        private let heldDescriptor: Descriptor
        var descriptor: Int32 { heldDescriptor.value }
        let path: String
        let name: String?
        let parent: Node?
        let metadata: Metadata
        let filesystem: Filesystem
        let provenance: Data?
        let children: [String]?
        var directory: Bool {
            metadata.mode & UInt32(S_IFMT) == UInt32(S_IFDIR)
        }
        var executable: Bool { metadata.mode & 0o100 != 0 }

        init(descriptor: Int32, path: String, name: String?, parent: Node?,
             enumerate: Bool, deadline: UInt64) throws {
            heldDescriptor = Descriptor(descriptor)
            self.path = path
            self.name = name
            self.parent = parent
            let value = try Self.status(descriptor)
            metadata = Metadata(value)
            filesystem = try PrimeValidationDriverV2BuildArtifacts
                .filesystem(descriptor, value)
            provenance = try PrimeValidationDriverV2BuildArtifacts
                .requireMetadata(descriptor, value, path: path)
            if let parent {
                guard filesystem == parent.filesystem else {
                    throw PrimeValidationDriverV2BuildArtifacts
                        .invalid("cross_filesystem")
                }
            }
            children = enumerate
                ? try PrimeValidationDriverV2BuildArtifacts.names(
                    descriptor, deadline: deadline) : nil
            try rejoin()
        }

        func rejoin() throws {
            guard try Metadata(Self.status(descriptor)) == metadata,
                  try PrimeValidationDriverV2BuildArtifacts.filesystem(
                    descriptor, Self.status(descriptor)) == filesystem,
                  try PrimeValidationDriverV2BuildArtifacts.requireMetadata(
                    descriptor, Self.status(descriptor), path: path)
                    == provenance else {
                throw PrimeValidationDriverV2BuildArtifacts.invalid("held_metadata")
            }
            if let parent, let name {
                guard try Metadata(Self.status(parent.descriptor))
                    == parent.metadata else {
                    throw PrimeValidationDriverV2BuildArtifacts.invalid("parent_metadata")
                }
                var named = stat()
                guard name.withCString({
                    fstatat(parent.descriptor, $0, &named, AT_SYMLINK_NOFOLLOW)
                }) == 0, Metadata(named) == metadata else {
                    throw PrimeValidationDriverV2BuildArtifacts.invalid("named_rejoin")
                }
            }
            guard try Metadata(Self.status(descriptor)) == metadata else {
                throw PrimeValidationDriverV2BuildArtifacts.invalid("held_final_rejoin")
            }
        }

        private static func status(_ descriptor: Int32) throws -> stat {
            var value = stat()
            guard fstat(descriptor, &value) == 0 else {
                throw PrimeValidationDriverV2BuildArtifacts.invalid("fstat")
            }
            return value
        }
    }

    private final class CreatedDirectory {
        let descriptor: Int32
        let device: UInt64
        let inode: UInt64
        init(_ descriptor: Int32, _ status: stat) {
            self.descriptor = descriptor
            device = UInt64(bitPattern: Int64(status.st_dev))
            inode = UInt64(status.st_ino)
        }
        deinit { _ = close(descriptor) }
    }

    private init(
        observation: PrimeValidationDriverV2BuildArtifactsObservation,
        workspaceRoot: PrimeArtifactRoot, artifactRoot: PrimeArtifactRoot,
        sourceNodes: [Node], copiedNodes: [Node],
        sourceHashes: [String: String], copiedHashes: [String: String],
        deadlineNanoseconds: UInt64
    ) {
        self.observation = observation
        self.workspaceRoot = workspaceRoot
        self.artifactRoot = artifactRoot
        self.sourceNodes = sourceNodes
        self.copiedNodes = copiedNodes
        self.sourceHashes = sourceHashes
        self.copiedHashes = copiedHashes
        self.deadlineNanoseconds = deadlineNanoseconds
    }

    static func capture(
        workspaceRoot: PrimeArtifactRoot,
        scratchRelativePath: String,
        testBundleRelativePath: String,
        metallibRelativePath: String,
        expectedMetallibByteCount: UInt64,
        expectedMetallibSHA256: String,
        artifactRoot: PrimeArtifactRoot,
        deadlineNanoseconds: UInt64
    ) throws -> PrimeValidationDriverV2BuildArtifacts {
        let started = DispatchTime.now().uptimeNanoseconds
        let deadline = try operationDeadline(deadlineNanoseconds)
        guard scratchRelativePath == scratchPath,
              testBundleRelativePath == testBundlePath,
              metallibRelativePath == metallibPath,
              expectedMetallibByteCount > 0,
              expectedMetallibByteCount <= maximumMetallibBytes,
              expectedMetallibSHA256.utf8.count == 64,
              expectedMetallibSHA256.utf8.allSatisfy({
                  (48...57).contains($0) || (97...102).contains($0)
              }) else { throw invalid("declaration") }
        try workspaceRoot.requirePrivateRootMode()
        try artifactRoot.requirePrivateRootMode()
        try artifactRoot.requireEmpty()
        let destinationBefore = try artifactRoot.verifiedRootIdentity()
        let workspace = try Node(
            descriptor: normalized(
                workspaceRoot.duplicateTrustedRootDescriptorForInventory()),
            path: "", name: nil, parent: nil, enumerate: false,
            deadline: deadline)
        guard workspace.metadata.deviceID != destinationBefore.deviceID
            || workspace.metadata.inode != destinationBefore.inode else {
            throw invalid("root_alias")
        }
        var sources = [workspace]
        var indexed: [String: Node] = ["": workspace]
        let bundle = try openPath(testBundleRelativePath, root: workspace,
            nodes: &sources, indexed: &indexed, enumerateLeaf: true,
            deadline: deadline)
        guard bundle.directory else { throw invalid("bundle_type") }
        var bundleNodes = [Node]()
        var fileCount = 0
        var directoryCount = 1
        var aggregate: UInt64 = 0
        try discover(bundle, relative: "", depth: 0,
            nodes: &bundleNodes, fileCount: &fileCount,
            directoryCount: &directoryCount, aggregate: &aggregate,
            deadline: deadline)
        sources.append(contentsOf: bundleNodes)
        guard fileCount > 0,
              bundleNodes.contains(where: {
                  $0.path == testBundleRelativePath + "/" + bundleExecutable
                      && !$0.directory && $0.executable
              }) else { throw invalid("bundle_executable") }
        let metallib = try openPath(metallibRelativePath, root: workspace,
            nodes: &sources, indexed: &indexed, enumerateLeaf: false,
            deadline: deadline)
        guard !metallib.directory, !metallib.executable,
              metallib.metadata.byteCount == Int64(expectedMetallibByteCount),
              sources.allSatisfy({
                  $0.metadata.deviceID != destinationBefore.deviceID
                      || $0.metadata.inode != destinationBefore.inode
              }) else { throw invalid("metallib_or_destination_alias") }
        let (allBytes, overflow) = aggregate.addingReportingOverflow(
            expectedMetallibByteCount)
        guard !overflow, allBytes <= maximumAggregateBytes,
              fileCount < maximumFiles else { throw invalid("aggregate_cap") }

        // Hold each exclusively created directory until its final copied
        // inventory is retained. Directory baselines are taken after our own
        // writes, while source baselines are never changed.
        let destinationFD = try normalized(
            artifactRoot.duplicateTrustedRootDescriptorForInventory())
        defer { _ = close(destinationFD) }
        var created = [String: CreatedDirectory]()
        created[copiedBundle] = try createDirectory(
            parent: destinationFD, name: copiedBundle, deadline: deadline)
        let sortedBundle = bundleNodes.sorted { $0.path < $1.path }
        for node in sortedBundle where node.directory {
            try check(deadline)
            let relative = String(node.path.dropFirst(testBundleRelativePath.count + 1))
            let destination = copiedBundle + "/" + relative
            let parts = try components(destination)
            let parent = parts.dropLast().joined(separator: "/")
            guard let heldParent = created[parent] else {
                throw invalid("destination_parent")
            }
            created[destination] = try createDirectory(
                parent: heldParent.descriptor, name: parts.last!, deadline: deadline)
        }
        var bindings = [PrimeArtifactBinding]()
        var sourceHashes = [String: String]()
        var copiedHashes = [String: String]()
        var publishedInodes = [String: (UInt64, UInt64)]()
        var entries = [PrimeValidationDriverV2BuildArtifactEntryObservation]()
        for node in sortedBundle {
            let relative = String(node.path.dropFirst(testBundleRelativePath.count + 1))
            let destination = copiedBundle + "/" + relative
            if node.directory {
                entries.append(.init(relativePath: relative, kind: "directory",
                    mode: 0o700, byteCount: nil, sha256: nil,
                    sourceMetadata: node.metadata))
            } else {
                let result = try publish(node, at: destination,
                    artifactRoot: artifactRoot, deadline: deadline)
                bindings.append(result.binding)
                sourceHashes[node.path] = result.binding.sha256
                copiedHashes[destination] = result.binding.sha256
                publishedInodes[destination] = result.identity
                entries.append(.init(relativePath: relative,
                    kind: node.executable ? "executable" : "regular_file",
                    mode: node.executable ? 0o555 : 0o444,
                    byteCount: result.binding.byteCount,
                    sha256: result.binding.sha256, sourceMetadata: node.metadata))
            }
        }
        let metalResult = try publish(metallib, at: copiedMetallib,
            artifactRoot: artifactRoot, deadline: deadline)
        guard metalResult.binding.sha256 == expectedMetallibSHA256,
              metalResult.binding.byteCount == expectedMetallibByteCount else {
            throw invalid("metallib_pin")
        }
        bindings.append(metalResult.binding)
        sourceHashes[metallib.path] = metalResult.binding.sha256
        copiedHashes[copiedMetallib] = metalResult.binding.sha256
        publishedInodes[copiedMetallib] = metalResult.identity
        for path in created.keys.sorted().reversed() {
            try synchronize(created[path]!.descriptor, deadline: deadline)
        }
        try synchronize(destinationFD, deadline: deadline)

        let copiedRoot = try Node(descriptor: normalized(fcntl(
            destinationFD, F_DUPFD_CLOEXEC, 3)), path: "", name: nil,
            parent: nil, enumerate: true, deadline: deadline)
        guard copiedRoot.metadata.deviceID == destinationBefore.deviceID,
              copiedRoot.metadata.inode == destinationBefore.inode,
              copiedRoot.children == [copiedMetallib, copiedBundle].sorted()
        else { throw invalid("destination_root_rejoin") }
        var copied = [copiedRoot]
        var copiedFiles = 0
        var copiedDirectories = 0
        var copiedBytes: UInt64 = 0
        try discover(copiedRoot, relative: "", depth: 0, nodes: &copied,
            fileCount: &copiedFiles, directoryCount: &copiedDirectories,
            aggregate: &copiedBytes, deadline: deadline)
        guard copiedFiles == bindings.count,
              copiedDirectories == created.count,
              copiedBytes == allBytes else { throw invalid("copied_inventory_counts") }
        let bindingsByPath = Dictionary(uniqueKeysWithValues:
            bindings.map { ($0.relativePath, $0) })
        for node in copied.dropFirst() {
            try check(deadline)
            if node.directory {
                guard let initial = created[node.path],
                      initial.device == node.metadata.deviceID,
                      initial.inode == node.metadata.inode,
                      node.metadata.mode & 0o7777 == 0o700 else {
                    throw invalid("created_directory_rejoin")
                }
            } else {
                guard let initial = publishedInodes[node.path],
                      initial.0 == node.metadata.deviceID,
                      initial.1 == node.metadata.inode,
                      let binding = bindingsByPath[node.path],
                      node.metadata.mode & 0o7777
                        == (binding.purpose == .executable ? 0o555 : 0o444),
                      UInt64(node.metadata.byteCount) == binding.byteCount else {
                    throw invalid("published_file_rejoin")
                }
            }
        }
        try validate(nodes: sources, hashes: sourceHashes, deadline: deadline)
        try validate(nodes: copied, hashes: copiedHashes, deadline: deadline)
        let identity = try artifactRoot.verifiedRootIdentity()
        try copiedRoot.rejoin()
        try check(deadline)
        let observation = PrimeValidationDriverV2BuildArtifactsObservation(
            testBundleRelativePath: testBundleRelativePath,
            testBundleMetadata: bundle.metadata,
            capturedBundleRelativePath: copiedBundle, bundleEntries: entries,
            metallibRelativePath: metallibRelativePath,
            metallibByteCount: expectedMetallibByteCount,
            metallibSHA256: expectedMetallibSHA256,
            metallibMetadata: metallib.metadata,
            capturedMetallib: metalResult.binding, artifactRootIdentity: identity,
            immutableArtifactBindings: bindings.sorted { $0.relativePath < $1.relativePath },
            capturedArtifactMetadata: Dictionary(uniqueKeysWithValues:
                copied.dropFirst().map { ($0.path, $0.metadata) }),
            captureStartedAtUptimeNanoseconds: started,
            captureCompletedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds,
            exclusivePublicationObserved: true,
            durableSynchronizationObserved: true,
            sourceNamesAndDescriptorsRejoined: true)
        return .init(observation: observation, workspaceRoot: workspaceRoot,
            artifactRoot: artifactRoot, sourceNodes: sources, copiedNodes: copied,
            sourceHashes: sourceHashes, copiedHashes: copiedHashes,
            deadlineNanoseconds: deadlineNanoseconds)
    }

    func revalidate() throws {
        try revalidateRetainedNodes(deadlineNanoseconds: deadlineNanoseconds)
    }

    /// Only the consumed F-to-G owner uses a later phase deadline. The held
    /// descriptors, original metadata and content baselines never change.
    func revalidateAfterBuild(deadlineNanoseconds: UInt64) throws {
        try revalidateRetainedNodes(deadlineNanoseconds: deadlineNanoseconds)
    }

    private func revalidateRetainedNodes(deadlineNanoseconds: UInt64) throws {
        lock.lock()
        defer { lock.unlock() }
        guard !poisoned else { throw Self.invalid("owner_poisoned") }
        do {
            let deadline = try Self.operationDeadline(deadlineNanoseconds)
            try workspaceRoot.requirePrivateRootMode()
            try artifactRoot.requirePrivateRootMode()
            try Self.validate(nodes: sourceNodes, hashes: sourceHashes, deadline: deadline)
            try Self.validate(nodes: copiedNodes, hashes: copiedHashes, deadline: deadline)
            guard try artifactRoot.verifiedRootIdentity()
                == observation.artifactRootIdentity else {
                throw Self.invalid("artifact_root_changed")
            }
            try Self.check(deadline)
        } catch {
            poisoned = true
            throw error
        }
    }

    private static func openPath(
        _ path: String, root: Node, nodes: inout [Node],
        indexed: inout [String: Node], enumerateLeaf: Bool, deadline: UInt64
    ) throws -> Node {
        let parts = try components(path)
        var parent = root
        var prefix = ""
        for (index, part) in parts.enumerated() {
            prefix = prefix.isEmpty ? part : prefix + "/" + part
            if let existing = indexed[prefix] {
                parent = existing
                continue
            }
            let leaf = index == parts.count - 1
            let node = try openChild(parent, name: part, path: prefix,
                requireDirectory: !leaf || enumerateLeaf,
                enumerate: leaf && enumerateLeaf, deadline: deadline)
            nodes.append(node)
            indexed[prefix] = node
            parent = node
        }
        return parent
    }

    private static func openChild(
        _ parent: Node, name: String, path: String, requireDirectory: Bool,
        enumerate: Bool, deadline: UInt64
    ) throws -> Node {
        try check(deadline)
        try parent.rejoin()
        var named = stat()
        guard name.withCString({ fstatat(parent.descriptor, $0, &named,
            AT_SYMLINK_NOFOLLOW) }) == 0 else { throw invalid("child_stat") }
        let type = named.st_mode & mode_t(S_IFMT)
        guard type == mode_t(S_IFREG) || type == mode_t(S_IFDIR),
              !requireDirectory || type == mode_t(S_IFDIR) else {
            throw invalid("symlink_or_unsupported_node")
        }
        let descriptor = try normalized(name.withCString {
            openat(parent.descriptor, $0, O_RDONLY | O_NOFOLLOW | O_CLOEXEC
                | O_NONBLOCK | (type == mode_t(S_IFDIR) ? O_DIRECTORY : 0))
        })
        let node = try Node(descriptor: descriptor, path: path, name: name,
            parent: parent, enumerate: enumerate, deadline: deadline)
        guard node.metadata == Metadata(named) else { throw invalid("open_race") }
        try parent.rejoin()
        return node
    }

    private static func discover(
        _ root: Node, relative: String, depth: Int, nodes: inout [Node],
        fileCount: inout Int, directoryCount: inout Int,
        aggregate: inout UInt64, deadline: UInt64
    ) throws {
        guard depth <= maximumDepth, let children = root.children else {
            throw invalid("directory_depth_or_inventory")
        }
        for name in children {
            try check(deadline)
            let path = root.path.isEmpty ? name : root.path + "/" + name
            _ = try components(path)
            var named = stat()
            guard name.withCString({ fstatat(root.descriptor, $0, &named,
                AT_SYMLINK_NOFOLLOW) }) == 0 else { throw invalid("discovery_stat") }
            let directory = named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR)
            if directory {
                directoryCount += 1
                guard directoryCount <= maximumDirectories,
                      depth < maximumDepth else { throw invalid("directory_cap") }
            } else {
                fileCount += 1
                guard fileCount <= maximumFiles, named.st_size > 0,
                      UInt64(named.st_size) <= maximumFileBytes else {
                    throw invalid("file_cap_or_empty")
                }
                let (next, overflow) = aggregate.addingReportingOverflow(UInt64(named.st_size))
                guard !overflow, next <= maximumAggregateBytes else {
                    throw invalid("aggregate_cap")
                }
                aggregate = next
            }
            let node = try openChild(root, name: name, path: path,
                requireDirectory: directory, enumerate: directory, deadline: deadline)
            nodes.append(node)
            if directory {
                try discover(node, relative: relative.isEmpty ? name : relative + "/" + name,
                    depth: depth + 1, nodes: &nodes, fileCount: &fileCount,
                    directoryCount: &directoryCount, aggregate: &aggregate,
                    deadline: deadline)
            }
        }
        guard try names(root.descriptor, deadline: deadline) == children else {
            throw invalid("directory_changed_during_discovery")
        }
        try root.rejoin()
    }

    private static func publish(
        _ source: Node, at path: String, artifactRoot: PrimeArtifactRoot,
        deadline: UInt64
    ) throws -> (binding: PrimeArtifactBinding, identity: (UInt64, UInt64)) {
        try check(deadline)
        try source.rejoin()
        var digest: String?
        var identity: (UInt64, UInt64)?
        let binding = try artifactRoot.publishGeneratedFile(at: path,
            purpose: source.executable ? .executable : .immutableData,
            maximumByteCount: UInt64(source.metadata.byteCount)) { destination in
                var value = stat()
                guard fstat(destination, &value) == 0 else { throw invalid("copy_destination_stat") }
                identity = (UInt64(bitPattern: Int64(value.st_dev)), UInt64(value.st_ino))
                guard identity!.0 != source.metadata.deviceID
                    || identity!.1 != source.metadata.inode else { throw invalid("copy_alias") }
                digest = try hash(source, destination: destination, deadline: deadline)
            }
        guard let identity, let digest, binding.sha256 == digest,
              binding.byteCount == UInt64(source.metadata.byteCount) else {
            throw invalid("publication_content")
        }
        try source.rejoin()
        try check(deadline)
        return (binding, identity)
    }

    private static func validate(nodes: [Node], hashes: [String: String],
                                 deadline: UInt64) throws {
        for node in nodes {
            try check(deadline)
            try node.rejoin()
            if let children = node.children {
                guard try names(node.descriptor, deadline: deadline) == children else {
                    throw invalid("directory_inventory_changed")
                }
            }
            if let expected = hashes[node.path] {
                guard try hash(node, destination: nil, deadline: deadline) == expected else {
                    throw invalid("content_changed")
                }
            } else if !node.directory { throw invalid("missing_content_binding") }
            try node.rejoin()
        }
        // Rejoin every name again after the complete content pass.
        for node in nodes {
            try check(deadline)
            try node.rejoin()
        }
    }

    private static func hash(_ node: Node, destination: Int32?, deadline: UInt64) throws -> String {
        try node.rejoin()
        guard !node.directory, node.metadata.byteCount > 0,
              UInt64(node.metadata.byteCount) <= maximumFileBytes,
              lseek(node.descriptor, 0, SEEK_SET) == 0 else { throw invalid("hash_source") }
        var hasher = SHA256()
        var buffer = [UInt8](repeating: 0, count: 65_536)
        var total: UInt64 = 0
        var interrupts = 0
        while true {
            try check(deadline)
            let count = buffer.withUnsafeMutableBytes {
                read(node.descriptor, $0.baseAddress, $0.count)
            }
            if count < 0 && errno == EINTR {
                interrupts += 1
                guard interrupts < 8 else { throw invalid("read_interrupt_bound") }
                continue
            }
            guard count >= 0 else { throw invalid("read") }
            interrupts = 0
            if count == 0 { break }
            let (next, overflow) = total.addingReportingOverflow(UInt64(count))
            guard !overflow, next <= UInt64(node.metadata.byteCount) else {
                throw invalid("read_extent")
            }
            hasher.update(data: Data(buffer[0..<count]))
            if let destination {
                var offset = 0
                var writeInterrupts = 0
                while offset < count {
                    try check(deadline)
                    let written = buffer.withUnsafeBytes {
                        write(destination, $0.baseAddress!.advanced(by: offset), count - offset)
                    }
                    if written < 0 && errno == EINTR {
                        writeInterrupts += 1
                        guard writeInterrupts < 8 else { throw invalid("write_interrupt_bound") }
                        continue
                    }
                    guard written > 0 else { throw invalid("write") }
                    writeInterrupts = 0
                    offset += written
                }
            }
            total = next
        }
        guard total == UInt64(node.metadata.byteCount) else { throw invalid("read_short") }
        try node.rejoin()
        try check(deadline)
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private static func createDirectory(parent: Int32, name: String,
                                        deadline: UInt64) throws -> CreatedDirectory {
        try check(deadline)
        _ = try components(name)
        guard !name.contains("/"), name.withCString({ mkdirat(parent, $0, 0o700) }) == 0 else {
            throw invalid("directory_not_exclusive")
        }
        let descriptor = try normalized(name.withCString {
            openat(parent, $0, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        })
        do {
            var value = stat()
            var named = stat()
            guard fstat(descriptor, &value) == 0,
                  name.withCString({ fstatat(parent, $0, &named, AT_SYMLINK_NOFOLLOW) }) == 0,
                  Metadata(value) == Metadata(named),
                  value.st_mode & mode_t(0o7777) == mode_t(0o700) else {
                throw invalid("created_directory")
            }
            _ = try requireMetadata(descriptor, value, path: name)
            guard try names(descriptor, deadline: deadline).isEmpty else {
                throw invalid("created_directory_not_empty")
            }
            try synchronize(descriptor, deadline: deadline)
            try synchronize(parent, deadline: deadline)
            return CreatedDirectory(descriptor, value)
        } catch {
            _ = close(descriptor)
            throw error
        }
    }

    private static func names(_ descriptor: Int32, deadline: UInt64) throws -> [String] {
        try check(deadline)
        let duplicate = try normalized(openat(descriptor, ".",
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC))
        guard let stream = fdopendir(duplicate) else {
            _ = close(duplicate)
            throw invalid("fdopendir")
        }
        defer { _ = closedir(stream) }
        var result = [String]()
        while true {
            try check(deadline)
            errno = 0
            guard let entry = readdir(stream) else {
                guard errno == 0 else { throw invalid("readdir") }
                break
            }
            let count = Int(entry.pointee.d_namlen)
            guard count > 0, count <= Int(MAXNAMLEN) else { throw invalid("name_length") }
            let bytes = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(to: UInt8.self, capacity: Int(MAXNAMLEN) + 1) {
                    Array(UnsafeBufferPointer(start: $0, count: count))
                }
            }
            guard let name = String(bytes: bytes, encoding: .utf8),
                  Array(name.utf8) == bytes else { throw invalid("name_encoding") }
            if name == "." || name == ".." { continue }
            _ = try components(name)
            guard !name.contains("/"), result.count < maximumFiles + maximumDirectories else {
                throw invalid("directory_entry_cap")
            }
            result.append(name)
        }
        guard Set(result).count == result.count else { throw invalid("duplicate_name") }
        return result.sorted()
    }

    private static func components(_ path: String) throws -> [String] {
        let result = path.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
        guard !path.isEmpty, path.utf8.count <= 4096,
              result.count <= maximumDepth + 8,
              result.allSatisfy({ part in
                  !part.isEmpty && part != "." && part != ".." && part != ".git"
                      && part.utf8.count <= Int(MAXNAMLEN)
                      && part.utf8.allSatisfy { $0 >= 32 && $0 != 127 && $0 != 92 }
              }) else { throw invalid("relative_path") }
        return result
    }

    private static func normalized(_ descriptor: Int32) throws -> Int32 {
        guard descriptor >= 0 else { throw invalid("open_descriptor") }
        if descriptor >= 3 {
            let flags = fcntl(descriptor, F_GETFD)
            guard flags >= 0, flags & FD_CLOEXEC != 0 else {
                _ = close(descriptor)
                throw invalid("descriptor_cloexec")
            }
            return descriptor
        }
        let replacement = fcntl(descriptor, F_DUPFD_CLOEXEC, 3)
        _ = close(descriptor)
        guard replacement >= 3 else { throw invalid("duplicate_descriptor") }
        return replacement
    }

    private static func filesystem(_ descriptor: Int32, _ value: stat) throws -> Filesystem {
        var filesystem = statfs()
        guard fstatfs(descriptor, &filesystem) == 0,
              filesystem.f_flags & UInt32(MNT_LOCAL) != 0 else {
            throw invalid("filesystem_not_local")
        }
        var field = filesystem.f_fstypename
        let name = withUnsafeBytes(of: &field) {
            String(bytes: $0.prefix { $0 != 0 }, encoding: .utf8)
        }
        guard name == "apfs" else { throw invalid("filesystem_not_apfs") }
        return Filesystem(device: UInt64(bitPattern: Int64(value.st_dev)),
            word0: filesystem.f_fsid.val.0, word1: filesystem.f_fsid.val.1)
    }

    private static func requireMetadata(_ descriptor: Int32, _ value: stat,
                                        path: String) throws -> Data? {
        let directory = value.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR)
        guard value.st_uid == geteuid(), value.st_flags == 0,
              value.st_mode & mode_t(0o7022) == 0 else { throw invalid("metadata_policy") }
        if directory {
            guard value.st_mode & mode_t(0o500) == mode_t(0o500) else {
                throw invalid("directory_permissions")
            }
            try PrimeArtifactRoot.requireTrustedInventoryDirectoryDescriptor(descriptor, path: path)
        } else {
            guard value.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  value.st_nlink == 1, value.st_size > 0,
                  value.st_mode & mode_t(0o400) != 0,
                  value.st_mode & mode_t(0o011) == 0
                    || value.st_mode & mode_t(0o100) != 0 else {
                throw invalid("file_metadata_policy")
            }
            try PrimeArtifactRoot.requireTrustedInventoryArtifactDescriptor(descriptor, path: path)
        }
        let required = "com.apple.provenance".withCString {
            fgetxattr(descriptor, $0, nil, 0, 0, 0)
        }
        if required < 0 {
            guard errno == ENOATTR else { throw invalid("provenance_read") }
            return nil
        }
        guard required <= 65_536 else { throw invalid("provenance_cap") }
        var bytes = [UInt8](repeating: 0, count: max(1, required))
        let actual = "com.apple.provenance".withCString { name in
            bytes.withUnsafeMutableBytes { fgetxattr(descriptor, name, $0.baseAddress, required, 0, 0) }
        }
        let after = "com.apple.provenance".withCString {
            fgetxattr(descriptor, $0, nil, 0, 0, 0)
        }
        guard actual == required, after == required else { throw invalid("provenance_changed") }
        return Data(bytes.prefix(required))
    }

    private static func synchronize(_ descriptor: Int32, deadline: UInt64) throws {
        try check(deadline)
        guard fsync(descriptor) == 0, fcntl(descriptor, F_FULLFSYNC) == 0 else {
            throw invalid("durable_sync")
        }
        try check(deadline)
    }

    private static func operationDeadline(_ outer: UInt64) throws -> UInt64 {
        let now = DispatchTime.now().uptimeNanoseconds
        let (local, overflow) = now.addingReportingOverflow(maximumOperationNanoseconds)
        guard !overflow, now < outer else { throw invalid("deadline") }
        return min(local, outer)
    }

    private static func check(_ deadline: UInt64) throws {
        guard DispatchTime.now().uptimeNanoseconds < deadline else {
            throw invalid("deadline")
        }
    }

    /// The input is decoded data, never a build capability. Acquire only
    /// read-only duplicates of roots already held by the outer governor.
    fileprivate static func readback(
        workspaceRootDescriptor: Int32, artifactRootDescriptor: Int32,
        expected: PrimeValidationDriverV2BuildArtifactsObservation,
        deadlineNanoseconds: UInt64
    ) throws -> () throws -> PrimeValidationDriverV2BuildArtifactsObservation {
        let deadline = try operationDeadline(deadlineNanoseconds)
        guard expected.testBundleRelativePath == testBundlePath,
              expected.capturedBundleRelativePath == copiedBundle,
              expected.metallibRelativePath == metallibPath,
              expected.metallibByteCount > 0,
              expected.metallibByteCount <= maximumMetallibBytes,
              expected.metallibSHA256.utf8.count == 64,
              expected.metallibSHA256.utf8.allSatisfy({
                  (48...57).contains($0) || (97...102).contains($0)
              }),
              !expected.bundleEntries.isEmpty,
              expected.bundleEntries.count <= maximumFiles + maximumDirectories,
              expected.immutableArtifactBindings.count <= maximumFiles,
              expected.capturedArtifactMetadata.count <= maximumFiles + maximumDirectories,
              expected.exclusivePublicationObserved,
              expected.durableSynchronizationObserved,
              expected.sourceNamesAndDescriptorsRejoined,
              expected.captureStartedAtUptimeNanoseconds
                < expected.captureCompletedAtUptimeNanoseconds,
              expected.captureCompletedAtUptimeNanoseconds
                <= DispatchTime.now().uptimeNanoseconds,
              expected.captureCompletedAtUptimeNanoseconds
                - expected.captureStartedAtUptimeNanoseconds <= maximumOperationNanoseconds
        else { throw invalid("readback_declaration") }
        let workspace = try Node(descriptor: normalized(fcntl(
            workspaceRootDescriptor, F_DUPFD_CLOEXEC, 3)), path: "", name: nil,
            parent: nil, enumerate: false, deadline: deadline)
        let copiedRoot = try Node(descriptor: normalized(fcntl(
            artifactRootDescriptor, F_DUPFD_CLOEXEC, 3)), path: "", name: nil,
            parent: nil, enumerate: true, deadline: deadline)
        guard workspace.metadata.mode & 0o7777 == 0o700,
              copiedRoot.metadata.mode & 0o7777 == 0o700,
              workspace.metadata.deviceID != copiedRoot.metadata.deviceID
                || workspace.metadata.inode != copiedRoot.metadata.inode,
              rootIdentity(copiedRoot.metadata) == expected.artifactRootIdentity,
              copiedRoot.children == [copiedMetallib, copiedBundle].sorted()
        else { throw invalid("readback_roots") }
        var sources = [workspace]
        var indexed: [String: Node] = ["": workspace]
        let bundle = try openPath(testBundlePath, root: workspace, nodes: &sources,
            indexed: &indexed, enumerateLeaf: true, deadline: deadline)
        guard bundle.directory, bundle.metadata == expected.testBundleMetadata else {
            throw invalid("readback_bundle_root")
        }
        var bundleNodes = [Node]()
        var files = 0
        var directories = 1
        var aggregate: UInt64 = 0
        try discover(bundle, relative: "", depth: 0, nodes: &bundleNodes,
            fileCount: &files, directoryCount: &directories,
            aggregate: &aggregate, deadline: deadline)
        sources.append(contentsOf: bundleNodes)
        guard files > 0, files < maximumFiles else { throw invalid("readback_file_cap") }
        let metallib = try openPath(metallibPath, root: workspace, nodes: &sources,
            indexed: &indexed, enumerateLeaf: false, deadline: deadline)
        guard !metallib.directory, !metallib.executable,
              metallib.metadata == expected.metallibMetadata,
              metallib.metadata.byteCount == Int64(expected.metallibByteCount),
              sources.allSatisfy({
                  $0.metadata.deviceID != copiedRoot.metadata.deviceID
                      || $0.metadata.inode != copiedRoot.metadata.inode
              }) else { throw invalid("readback_metallib_or_alias") }
        let (allBytes, overflow) = aggregate.addingReportingOverflow(expected.metallibByteCount)
        guard !overflow, allBytes <= maximumAggregateBytes else {
            throw invalid("readback_aggregate_cap")
        }
        var sourceHashes = [String: String]()
        var copiedHashes = [String: String]()
        var entries = [PrimeValidationDriverV2BuildArtifactEntryObservation]()
        var bindings = [PrimeArtifactBinding]()
        for node in bundleNodes.sorted(by: { $0.path < $1.path }) {
            try check(deadline)
            let relative = String(node.path.dropFirst(testBundlePath.count + 1))
            let digest = node.directory ? nil : try hash(node, destination: nil, deadline: deadline)
            entries.append(.init(relativePath: relative,
                kind: node.directory ? "directory" : (node.executable ? "executable" : "regular_file"),
                mode: node.directory ? 0o700 : (node.executable ? 0o555 : 0o444),
                byteCount: node.directory ? nil : UInt64(node.metadata.byteCount),
                sha256: digest, sourceMetadata: node.metadata))
            if let digest {
                let destination = copiedBundle + "/" + relative
                sourceHashes[node.path] = digest
                copiedHashes[destination] = digest
                bindings.append(.init(relativePath: destination, sha256: digest,
                    byteCount: UInt64(node.metadata.byteCount),
                    purpose: node.executable ? .executable : .immutableData))
            }
        }
        guard entries == expected.bundleEntries,
              entries.contains(where: { $0.relativePath == bundleExecutable && $0.kind == "executable" })
        else { throw invalid("readback_source_manifest") }
        let metalHash = try hash(metallib, destination: nil, deadline: deadline)
        let metalBinding = PrimeArtifactBinding(relativePath: copiedMetallib,
            sha256: metalHash, byteCount: UInt64(metallib.metadata.byteCount), purpose: .immutableData)
        guard metalHash == expected.metallibSHA256,
              metalBinding == expected.capturedMetallib else {
            throw invalid("readback_metallib_content")
        }
        bindings.append(metalBinding)
        sourceHashes[metallib.path] = metalHash
        copiedHashes[copiedMetallib] = metalHash
        guard bindings.sorted(by: { $0.relativePath < $1.relativePath })
            == expected.immutableArtifactBindings else { throw invalid("readback_bindings") }
        var copied = [copiedRoot]
        var copiedFiles = 0
        var copiedDirectories = 0
        var copiedBytes: UInt64 = 0
        try discover(copiedRoot, relative: "", depth: 0, nodes: &copied,
            fileCount: &copiedFiles, directoryCount: &copiedDirectories,
            aggregate: &copiedBytes, deadline: deadline)
        guard copiedFiles == files + 1, copiedDirectories == directories,
              copiedBytes == allBytes,
              Dictionary(uniqueKeysWithValues: copied.dropFirst().map { ($0.path, $0.metadata) })
                == expected.capturedArtifactMetadata else { throw invalid("readback_copied_metadata") }
        let bindingsByPath = Dictionary(uniqueKeysWithValues: bindings.map { ($0.relativePath, $0) })
        let expectedDirectories = Set([copiedBundle] + entries.filter { $0.kind == "directory" }
            .map { copiedBundle + "/" + $0.relativePath })
        for node in copied.dropFirst() {
            try check(deadline)
            if node.directory {
                guard expectedDirectories.contains(node.path), node.metadata.mode & 0o7777 == 0o700
                else { throw invalid("readback_copied_directory") }
            } else {
                guard let binding = bindingsByPath[node.path],
                      UInt64(node.metadata.byteCount) == binding.byteCount,
                      node.metadata.mode & 0o7777
                        == (binding.purpose == .executable ? 0o555 : 0o444) else {
                    throw invalid("readback_copied_file")
                }
            }
        }
        try validate(nodes: sources, hashes: sourceHashes, deadline: deadline)
        try validate(nodes: copied, hashes: copiedHashes, deadline: deadline)
        try check(deadline)
        // Keep the exact descriptors observed here. Later checks never
        // replace them with new owners constructed from the decoded values.
        return {
            let nextDeadline = try operationDeadline(deadlineNanoseconds)
            try validate(nodes: sources, hashes: sourceHashes, deadline: nextDeadline)
            try validate(nodes: copied, hashes: copiedHashes, deadline: nextDeadline)
            try check(nextDeadline)
            return expected
        }
    }

    private static func rootIdentity(_ value: Metadata) -> PrimeArtifactRootIdentity {
        .init(deviceID: value.deviceID, inode: value.inode,
            ownerUserID: value.ownerUserID, ownerGroupID: value.ownerGroupID,
            actualMode: UInt16(value.mode & 0o777), linkCount: value.linkCount,
            modificationSeconds: value.modificationSeconds,
            modificationNanoseconds: value.modificationNanoseconds,
            statusChangeSeconds: value.statusChangeSeconds,
            statusChangeNanoseconds: value.statusChangeNanoseconds)
    }

    private static func invalid(_ coordinate: String)
        -> PrimeValidationSwiftPMBuildInventoryAdmissionError {
        .rejected("build_artifacts_" + coordinate)
    }
}

/// A read-only artifact observer for the outer governor. This class cannot
/// launch a process, publish a file, or produce a build receipt. Its expected
/// observation is untrusted transport data until native readback succeeds.
@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2BuildArtifactsReadback: @unchecked Sendable {
    private let validate: () throws -> PrimeValidationDriverV2BuildArtifactsObservation
    private let lock = NSLock()
    private var poisoned = false

    private init(validate: @escaping () throws -> PrimeValidationDriverV2BuildArtifactsObservation) {
        self.validate = validate
    }

    public static func capture(
        workspaceRootDescriptor: Int32, artifactRootDescriptor: Int32,
        expected: PrimeValidationDriverV2BuildArtifactsObservation,
        deadlineNanoseconds: UInt64
    ) throws -> PrimeValidationDriverV2BuildArtifactsReadback {
        let validate = try PrimeValidationDriverV2BuildArtifacts.readback(
            workspaceRootDescriptor: workspaceRootDescriptor,
            artifactRootDescriptor: artifactRootDescriptor,
            expected: expected, deadlineNanoseconds: deadlineNanoseconds)
        return .init(validate: validate)
    }

    @discardableResult
    public func revalidate() throws -> PrimeValidationDriverV2BuildArtifactsObservation {
        lock.lock()
        defer { lock.unlock() }
        guard !poisoned else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError.rejected("build_artifacts_readback_poisoned")
        }
        do { return try validate() }
        catch { poisoned = true; throw error }
    }
}
