// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
@_spi(PrimeValidationDriverV2OuterContinuity) import PrimeCore
import PrimeValidationWorkflowDriverCore

@_silgen_name("_NSGetEnviron")
private func primeDriverV2GovernorNSGetEnviron()
    -> UnsafeMutablePointer<
        UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
    >

package enum PrimeValidationDriverV2ShotGovernorStatus {
    package static let success: Int32 = 0
    package static let capsuleTransport: Int32 = 65
    package static let admission: Int32 = 66
    package static let durableBoundary: Int32 = 67
    package static let suspendedJoin: Int32 = 68
    package static let postReapRejection: Int32 = 69
    package static let containmentUncertain: Int32 = 70
    package static let containedNonzero: Int32 = 71
    package static let terminalPublication: Int32 = 72
}

private struct PrimeValidationDriverV2PreliminarySupervisorStopObservation:
    Equatable,
    Sendable
{
    let returnValue: Int32
    let errorNumber: Int32
    let deathEventCheckPerformed: Bool
    let deathEventObserved: Bool
}

private struct PrimeValidationDriverV2ShotGovernorFailure: Error {
    let status: Int32
    let coordinate: String
    let preliminarySupervisorStopObservation:
        PrimeValidationDriverV2PreliminarySupervisorStopObservation?
}

private func governorRejected(
    _ status: Int32,
    _ coordinate: String,
    preliminarySupervisorStopObservation:
        PrimeValidationDriverV2PreliminarySupervisorStopObservation? = nil
) -> PrimeValidationDriverV2ShotGovernorFailure {
    .init(
        status: status,
        coordinate: coordinate,
        preliminarySupervisorStopObservation:
            preliminarySupervisorStopObservation
    )
}

/// Canonical data only. Decoding this value cannot recover a descriptor,
/// lease, watch, process, or execution capability.
package struct PrimeValidationDriverV2ShotCapsuleV1:
    Codable,
    Equatable,
    Sendable
{
    package static let schemaVersion = 1
    package static let artifactKind =
        "prime_driver_v2_gate_e_shot_capsule_v1"

    package let schemaVersion: Int
    package let artifactKind: String
    package let attempt: Int
    package let rerunAuthorized: Bool
    package let localOnly: Bool
    package let networkOperationCount: Int
    package let dependencyFetchCount: Int
    package let githubOperationCount: Int
    package let fixtureExecutionCount: Int
    package let swiftPMBuildExecutionCount: Int
    package let artifactStagingExecutionCount: Int
    package let inventoryExecutionCount: Int
    package let gateFAuthorized: Bool
    package let gateGAuthorized: Bool
    package let controlCommit: String
    package let controlTree: String
    package let sourceCommit: String
    package let sourceTree: String
    package let companionCommit: String
    package let companionTree: String
    package let sourceIdentitySHA256: String
    package let primeAdmittedFileCount: Int
    package let sourceIdentityRecordCount: Int
    package let primeAuthorityDirectoryCount: Int
    package let combinedWatcherDescriptorCount: Int
    package let governorExecutable: PrimeValidationExecutableBindingV2
    package let supervisorExecutable: PrimeValidationExecutableBindingV2
    package let gitExecutable: PrimeValidationExecutableBindingV2
    package let swiftExecutable: PrimeValidationExecutableBindingV2
    package let productionBase: PrimeValidationDirectoryBindingV2
    package let productionBaseEntryNamesBefore: [String]
    package let privateWorkingDirectory: PrimeValidationDirectoryBindingV2
    package let leaseDirectoryAbsolutePath: String
    package let forbiddenAbsentAbsolutePaths: [String]
    package let intent: PrimeValidationRunIntentV2

    package func validate(exactCanonicalBytes: Data) throws {
        guard schemaVersion == Self.schemaVersion,
              artifactKind == Self.artifactKind,
              attempt == 1,
              !rerunAuthorized,
              localOnly,
              networkOperationCount == 0,
              dependencyFetchCount == 0,
              githubOperationCount == 0,
              fixtureExecutionCount == 0,
              swiftPMBuildExecutionCount == 0,
              artifactStagingExecutionCount == 0,
              inventoryExecutionCount == 0,
              !gateFAuthorized,
              !gateGAuthorized,
              primeAdmittedFileCount == 548,
              sourceIdentityRecordCount == 547,
              primeAuthorityDirectoryCount == 155,
              combinedWatcherDescriptorCount == 2_163,
              exactCanonicalBytes.count <= 262_144,
              exactCanonicalBytes.last != 0x0a,
              try PrimeCanonicalJSON.encode(self) == exactCanonicalBytes,
              Self.isGitObjectName(controlCommit),
              Self.isGitObjectName(controlTree),
              Self.isGitObjectName(sourceCommit),
              Self.isGitObjectName(sourceTree),
              Self.isGitObjectName(companionCommit),
              Self.isGitObjectName(companionTree),
              Self.isSHA256(sourceIdentitySHA256),
              sourceIdentitySHA256
                == PrimeEmbeddedBuildProvenance.sourceIdentitySHA256,
              companionCommit
                == PrimeValidationRunIntentV2.requiredCompanionCommit
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "capsule_fixed_fields"
            )
        }
        try intent.validate()
        try governorExecutable.validate()
        try supervisorExecutable.validate()
        try gitExecutable.validate()
        try swiftExecutable.validate()
        try productionBase.validate(requirePrivateMode: true)
        try privateWorkingDirectory.validate(requirePrivateMode: true)
        let requestedSwiftDirectory = (intent.swiftExecutable.absolutePath
            as NSString).deletingLastPathComponent
        guard supervisorExecutable == intent.driverExecutable,
              swiftExecutable.absolutePath
                == requestedSwiftDirectory + "/swift-frontend",
              swiftExecutable.content == intent.swiftExecutable.content,
              intent.companionCommit == companionCommit,
              Self.isSafeAbsolutePath(leaseDirectoryAbsolutePath),
              Self.isDescendant(
                  privateWorkingDirectory.absolutePath,
                  of: productionBase.absolutePath
              ),
              Self.isDescendant(
                  intent.roots.workspaceRoot.absolutePath,
                  of: productionBase.absolutePath
              ),
              Self.isDescendant(
                  intent.roots.evidenceRoot.absolutePath,
                  of: productionBase.absolutePath
              ),
              Self.isDescendant(
                  leaseDirectoryAbsolutePath,
                  of: productionBase.absolutePath
              ),
              forbiddenAbsentAbsolutePaths
                == forbiddenAbsentAbsolutePaths.sorted(),
              Set(forbiddenAbsentAbsolutePaths).count
                == forbiddenAbsentAbsolutePaths.count,
              forbiddenAbsentAbsolutePaths.allSatisfy(Self.isSafeAbsolutePath),
              productionBaseEntryNamesBefore
                == productionBaseEntryNamesBefore.sorted(),
              Set(productionBaseEntryNamesBefore).count
                == productionBaseEntryNamesBefore.count,
              productionBaseEntryNamesBefore.allSatisfy(Self.isSafeLeaf)
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "capsule_declarations"
            )
        }
        let requiredAbsent = Set([
            productionBase.absolutePath + "/gate-e-shot-governor-journal",
            productionBase.absolutePath + "/outer-supervisor-stdout.bin",
            productionBase.absolutePath + "/outer-supervisor-stderr.bin",
        ])
        guard requiredAbsent.isSubset(of: Set(forbiddenAbsentAbsolutePaths))
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "capsule_absent_declarations"
            )
        }
    }

    private static func isGitObjectName(_ value: String) -> Bool {
        value.utf8.count == 40 && isLowerHex(value)
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64 && isLowerHex(value)
    }

    private static func isLowerHex(_ value: String) -> Bool {
        value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    fileprivate static func isSafeAbsolutePath(_ value: String) -> Bool {
        guard value.hasPrefix("/"),
              value != "/",
              !value.contains("\\"),
              !value.contains("\0"),
              value.utf8.count < Int(PATH_MAX)
        else { return false }
        return value.split(
            separator: "/",
            omittingEmptySubsequences: false
        ).dropFirst().allSatisfy {
            !$0.isEmpty && $0 != "." && $0 != ".."
        }
    }

    private static func isDescendant(
        _ candidate: String,
        of root: String
    ) -> Bool {
        candidate.hasPrefix(root + "/")
    }

    private static func isSafeLeaf(_ value: String) -> Bool {
        !value.isEmpty
            && value != "."
            && value != ".."
            && !value.contains("/")
            && !value.contains("\0")
            && value.utf8.count <= Int(MAXNAMLEN)
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case attempt
        case rerunAuthorized = "rerun_authorized"
        case localOnly = "local_only"
        case networkOperationCount = "network_operation_count"
        case dependencyFetchCount = "dependency_fetch_count"
        case githubOperationCount = "github_operation_count"
        case fixtureExecutionCount = "fixture_execution_count"
        case swiftPMBuildExecutionCount =
            "swiftpm_build_execution_count"
        case artifactStagingExecutionCount =
            "artifact_staging_execution_count"
        case inventoryExecutionCount = "inventory_execution_count"
        case gateFAuthorized = "gate_f_authorized"
        case gateGAuthorized = "gate_g_authorized"
        case controlCommit = "control_commit"
        case controlTree = "control_tree"
        case sourceCommit = "source_commit"
        case sourceTree = "source_tree"
        case companionCommit = "companion_commit"
        case companionTree = "companion_tree"
        case sourceIdentitySHA256 = "source_identity_sha256"
        case primeAdmittedFileCount = "prime_admitted_file_count"
        case sourceIdentityRecordCount = "source_identity_record_count"
        case primeAuthorityDirectoryCount =
            "prime_authority_directory_count"
        case combinedWatcherDescriptorCount =
            "combined_watcher_descriptor_count"
        case governorExecutable = "governor_executable"
        case supervisorExecutable = "supervisor_executable"
        case gitExecutable = "git_executable"
        case swiftExecutable = "swift_executable"
        case productionBase = "production_base"
        case productionBaseEntryNamesBefore =
            "production_base_entry_names_before"
        case privateWorkingDirectory = "private_working_directory"
        case leaseDirectoryAbsolutePath =
            "lease_directory_absolute_path"
        case forbiddenAbsentAbsolutePaths =
            "forbidden_absent_absolute_paths"
        case intent
    }
}

private struct PrimeValidationDriverV2GovernorDeadline {
    static let durationNanoseconds: UInt64 = 60_000_000_000
    let startedAt: UInt64
    let expiresAt: UInt64

    init(durationNanoseconds: UInt64 = Self.durationNanoseconds) throws {
        startedAt = DispatchTime.now().uptimeNanoseconds
        let value = startedAt.addingReportingOverflow(durationNanoseconds)
        guard !value.overflow else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "deadline_overflow"
            )
        }
        expiresAt = value.partialValue
    }

    func requireTime(_ coordinate: String) throws {
        guard DispatchTime.now().uptimeNanoseconds < expiresAt else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                coordinate
            )
        }
    }

    var dispatchDeadline: DispatchTime {
        DispatchTime(uptimeNanoseconds: expiresAt)
    }
}

private struct PrimeValidationDriverV2GovernorMetadata: Equatable {
    let deviceID: UInt64
    let inode: UInt64
    let byteCount: UInt64
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let permissionMode: UInt16
    let linkCount: UInt64
    let flags: UInt32
    let modificationSeconds: Int64
    let modificationNanoseconds: Int64
    let statusChangeSeconds: Int64
    let statusChangeNanoseconds: Int64

    init(_ value: stat) throws {
        guard value.st_size >= 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "negative_file_size"
            )
        }
        deviceID = UInt64(bitPattern: Int64(value.st_dev))
        inode = UInt64(value.st_ino)
        byteCount = UInt64(value.st_size)
        ownerUserID = value.st_uid
        ownerGroupID = value.st_gid
        permissionMode = UInt16(value.st_mode & mode_t(0o7777))
        linkCount = UInt64(value.st_nlink)
        flags = value.st_flags
        modificationSeconds = Int64(value.st_mtimespec.tv_sec)
        modificationNanoseconds = Int64(value.st_mtimespec.tv_nsec)
        statusChangeSeconds = Int64(value.st_ctimespec.tv_sec)
        statusChangeNanoseconds = Int64(value.st_ctimespec.tv_nsec)
    }
}

private struct PrimeValidationDriverV2GovernorXattrs: Equatable {
    let provenance: Data?

    static func capture(
        _ descriptor: Int32,
        coordinate: String
    ) throws -> Self {
        errno = 0
        if let acl = acl_get_fd_np(descriptor, ACL_TYPE_EXTENDED) {
            acl_free(UnsafeMutableRawPointer(acl))
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_acl"
            )
        }
        guard errno == ENOENT else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_acl_query"
            )
        }
        let size = flistxattr(descriptor, nil, 0, 0)
        guard size >= 0, size <= 65_536 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_xattr_size"
            )
        }
        guard size > 0 else { return .init(provenance: nil) }
        var names = [CChar](repeating: 0, count: size)
        let returned = names.withUnsafeMutableBufferPointer {
            flistxattr(descriptor, $0.baseAddress, $0.count, 0)
        }
        guard returned == size else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_xattr_inventory"
            )
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
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    coordinate + "_xattr_name"
                )
            }
            observed.append(name)
            start = index + 1
        }
        guard start == bytes.endIndex,
              observed == ["com.apple.provenance"]
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_xattr_policy"
            )
        }
        let valueSize = "com.apple.provenance".withCString {
            fgetxattr(descriptor, $0, nil, 0, 0, 0)
        }
        guard valueSize >= 0, valueSize <= 65_536 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_provenance_size"
            )
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
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_provenance_read"
            )
        }
        return .init(provenance: value)
    }
}

private enum PrimeValidationDriverV2GovernorIO {
    static func readExact(
        descriptor: Int32,
        byteCount: Int,
        coordinate: String
    ) throws -> Data {
        guard byteCount >= 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_size"
            )
        }
        var result = Data(count: byteCount)
        var offset = 0
        try result.withUnsafeMutableBytes { bytes in
            while offset < byteCount {
                let count = Darwin.pread(
                    descriptor,
                    bytes.baseAddress!.advanced(by: offset),
                    byteCount - offset,
                    off_t(offset)
                )
                if count < 0, errno == EINTR { continue }
                guard count > 0 else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus.admission,
                        coordinate + "_read"
                    )
                }
                offset += count
            }
        }
        var trailing: UInt8 = 0
        let trailingCount = Darwin.pread(
            descriptor,
            &trailing,
            1,
            off_t(byteCount)
        )
        guard trailingCount == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_trailing"
            )
        }
        return result
    }

    static func writeAll(
        _ data: Data,
        descriptor: Int32,
        coordinate: String
    ) throws {
        var offset = 0
        try data.withUnsafeBytes { bytes in
            while offset < bytes.count {
                let count = Darwin.write(
                    descriptor,
                    bytes.baseAddress!.advanced(by: offset),
                    bytes.count - offset
                )
                if count < 0, errno == EINTR { continue }
                guard count > 0 else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                        coordinate + "_write"
                    )
                }
                offset += count
            }
        }
    }

    static func writeAllPositioned(
        _ data: Data,
        descriptor: Int32,
        coordinate: String
    ) throws {
        var offset = 0
        try data.withUnsafeBytes { bytes in
            while offset < bytes.count {
                let count = Darwin.pwrite(
                    descriptor,
                    bytes.baseAddress!.advanced(by: offset),
                    bytes.count - offset,
                    off_t(offset)
                )
                if count < 0, errno == EINTR { continue }
                guard count > 0 else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus
                            .durableBoundary,
                        coordinate + "_pwrite"
                    )
                }
                offset += count
            }
        }
    }

    static func synchronize(
        _ descriptor: Int32,
        coordinate: String
    ) throws {
        guard fsync(descriptor) == 0,
              fcntl(descriptor, F_FULLFSYNC) == 0
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                coordinate + "_sync"
            )
        }
    }

    static func canonicalPath(_ path: String) throws -> String {
        guard PrimeValidationDriverV2ShotCapsuleV1
                .isSafeAbsolutePath(path)
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "absolute_path"
            )
        }
        var storage = [CChar](repeating: 0, count: Int(PATH_MAX))
        let pointer = path.withCString { realpath($0, &storage) }
        guard pointer != nil,
              let canonical = String(
                  bytes: storage.prefix { $0 != 0 }.map {
                      UInt8(bitPattern: $0)
                  },
                  encoding: .utf8
              ),
              canonical == path
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "canonical_path"
            )
        }
        return canonical
    }

    static func pathForDescriptor(
        _ descriptor: Int32,
        coordinate: String
    ) throws -> String {
        var information = vnode_fdinfowithpath()
        let expected = MemoryLayout<vnode_fdinfowithpath>.size
        let returned = withUnsafeMutablePointer(to: &information) {
            proc_pidfdinfo(
                getpid(),
                descriptor,
                PROC_PIDFDVNODEPATHINFO,
                $0,
                Int32(expected)
            )
        }
        var storage = information.pvip.vip_path
        let value: String? = withUnsafeBytes(of: &storage) { bytes in
            guard let terminator = bytes.firstIndex(of: 0),
                  terminator > bytes.startIndex,
                  terminator < bytes.endIndex
            else { return nil }
            return String(
                bytes: bytes[..<terminator],
                encoding: .utf8
            )
        }
        guard returned == Int32(expected),
              let value,
              PrimeValidationDriverV2ShotCapsuleV1
                .isSafeAbsolutePath(value)
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate
            )
        }
        do {
            guard try canonicalPath(value) == value else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    coordinate
                )
            }
        } catch {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate
            )
        }
        return value
    }

    static func inventory(
        directory descriptor: Int32,
        coordinate: String
    ) throws -> [String] {
        let duplicate = fcntl(descriptor, F_DUPFD_CLOEXEC, 3)
        guard duplicate >= 3,
              lseek(duplicate, 0, SEEK_SET) >= 0,
              let directory = fdopendir(duplicate)
        else {
            if duplicate >= 0 { _ = Darwin.close(duplicate) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_inventory_open"
            )
        }
        defer { _ = closedir(directory) }
        var values = [String]()
        errno = 0
        while let entry = readdir(directory) {
            let name = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(
                    to: CChar.self,
                    capacity: Int(MAXNAMLEN) + 1
                ) { String(cString: $0) }
            }
            if name != "." && name != ".." { values.append(name) }
            errno = 0
        }
        guard errno == 0,
              Set(values).count == values.count
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_inventory_read"
            )
        }
        return values.sorted()
    }

    static func requireLocalAPFS(
        _ descriptor: Int32,
        sameAs expected: fsid_t? = nil,
        coordinate: String
    ) throws -> fsid_t {
        var information = statfs()
        guard fstatfs(descriptor, &information) == 0,
              information.f_flags & UInt32(MNT_LOCAL) != 0
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_filesystem"
            )
        }
        let type = withUnsafePointer(to: &information.f_fstypename) {
            $0.withMemoryRebound(to: CChar.self, capacity: 16) {
                String(cString: $0)
            }
        }
        guard type == "apfs",
              expected.map({
                  $0.val.0 == information.f_fsid.val.0
                      && $0.val.1 == information.f_fsid.val.1
              }) ?? true
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_apfs_join"
            )
        }
        return information.f_fsid
    }
}

private final class PrimeValidationDriverV2GovernorHeldDirectory {
    let absolutePath: String
    private(set) var descriptor: Int32
    private let identity: PrimeValidationDriverV2GovernorMetadata
    private let xattrs: PrimeValidationDriverV2GovernorXattrs

    var deviceID: UInt64 { identity.deviceID }
    var inode: UInt64 { identity.inode }
    var binding: PrimeValidationDirectoryBindingV2 {
        PrimeValidationDirectoryBindingV2(
            absolutePath: absolutePath,
            deviceID: identity.deviceID,
            inode: identity.inode,
            ownerUserID: identity.ownerUserID,
            mode: identity.permissionMode
        )
    }

    init(
        binding: PrimeValidationDirectoryBindingV2,
        requireEmpty: Bool,
        coordinate: String
    ) throws {
        try binding.validate(requirePrivateMode: binding.mode == 0o700)
        absolutePath = try PrimeValidationDriverV2GovernorIO
            .canonicalPath(binding.absolutePath)
        descriptor = Darwin.open(
            absolutePath,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard descriptor >= 3 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_open"
            )
        }
        do {
            var status = stat()
            guard fstat(descriptor, &status) == 0,
                  status.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
                  UInt64(bitPattern: Int64(status.st_dev)) == binding.deviceID,
                  UInt64(status.st_ino) == binding.inode,
                  status.st_uid == binding.ownerUserID,
                  UInt16(status.st_mode & mode_t(0o7777)) == binding.mode,
                  status.st_flags == 0,
                  fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    coordinate + "_metadata"
                )
            }
            identity = try PrimeValidationDriverV2GovernorMetadata(status)
            xattrs = try PrimeValidationDriverV2GovernorXattrs.capture(
                descriptor,
                coordinate: coordinate
            )
            if requireEmpty {
                guard try PrimeValidationDriverV2GovernorIO.inventory(
                    directory: descriptor,
                    coordinate: coordinate
                ).isEmpty else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus.admission,
                        coordinate + "_not_empty"
                    )
                }
            }
            try revalidate(coordinate: coordinate)
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw error
        }
    }

    init(
        absolutePath: String,
        requirePrivate: Bool,
        requireEmpty: Bool,
        coordinate: String
    ) throws {
        self.absolutePath = try PrimeValidationDriverV2GovernorIO
            .canonicalPath(absolutePath)
        descriptor = Darwin.open(
            self.absolutePath,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard descriptor >= 3 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_open"
            )
        }
        do {
            var status = stat()
            guard fstat(descriptor, &status) == 0,
                  status.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
                  status.st_uid == geteuid(),
                  (!requirePrivate
                    || status.st_mode & mode_t(0o7777) == mode_t(0o700)),
                  status.st_flags == 0,
                  fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    coordinate + "_metadata"
                )
            }
            identity = try PrimeValidationDriverV2GovernorMetadata(status)
            xattrs = try PrimeValidationDriverV2GovernorXattrs.capture(
                descriptor,
                coordinate: coordinate
            )
            if requireEmpty {
                guard try PrimeValidationDriverV2GovernorIO.inventory(
                    directory: descriptor,
                    coordinate: coordinate
                ).isEmpty else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus.admission,
                        coordinate + "_not_empty"
                    )
                }
            }
            try revalidate(coordinate: coordinate)
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw error
        }
    }

    init(
        duplicatingTestDescriptor source: Int32,
        requirePrivate: Bool,
        requireEmpty: Bool,
        coordinate: String
    ) throws {
        descriptor = fcntl(source, F_DUPFD_CLOEXEC, 3)
        guard descriptor >= 3 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_duplicate"
            )
        }
        do {
            absolutePath = try PrimeValidationDriverV2GovernorIO
                .pathForDescriptor(
                    descriptor,
                    coordinate: coordinate + "_path"
                )
            var status = stat()
            guard fstat(descriptor, &status) == 0,
                  status.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
                  status.st_uid == geteuid(),
                  (!requirePrivate
                    || status.st_mode & mode_t(0o7777) == mode_t(0o700)),
                  status.st_flags == 0,
                  fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    coordinate + "_metadata"
                )
            }
            identity = try PrimeValidationDriverV2GovernorMetadata(status)
            xattrs = try PrimeValidationDriverV2GovernorXattrs.capture(
                descriptor,
                coordinate: coordinate
            )
            if requireEmpty {
                guard try PrimeValidationDriverV2GovernorIO.inventory(
                    directory: descriptor,
                    coordinate: coordinate
                ).isEmpty else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus.admission,
                        coordinate + "_not_empty"
                    )
                }
            }
            try revalidate(coordinate: coordinate)
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw error
        }
    }

    deinit {
        if descriptor >= 3 { _ = Darwin.close(descriptor) }
    }

    func revalidate(coordinate: String) throws {
        var held = stat()
        var named = stat()
        guard descriptor >= 3,
              fstat(descriptor, &held) == 0,
              lstat(absolutePath, &named) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              UInt64(bitPattern: Int64(held.st_dev)) == identity.deviceID,
              UInt64(held.st_ino) == identity.inode,
              held.st_uid == identity.ownerUserID,
              held.st_gid == identity.ownerGroupID,
              UInt16(held.st_mode & mode_t(0o7777))
                == identity.permissionMode,
              held.st_flags == 0,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0,
              try PrimeValidationDriverV2GovernorXattrs.capture(
                  descriptor,
                  coordinate: coordinate
              ) == xattrs
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_changed"
            )
        }
    }

    func requireEmpty(coordinate: String) throws {
        try revalidate(coordinate: coordinate)
        guard try PrimeValidationDriverV2GovernorIO.inventory(
            directory: descriptor,
            coordinate: coordinate
        ).isEmpty else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                coordinate + "_not_empty"
            )
        }
    }
}

private final class PrimeValidationDriverV2GovernorHeldExecutable {
    let binding: PrimeValidationExecutableBindingV2
    let absolutePath: String
    private(set) var descriptor: Int32
    let identity: PrimeValidationDriverV2GovernorMetadata
    private let xattrs: PrimeValidationDriverV2GovernorXattrs

    init(
        binding: PrimeValidationExecutableBindingV2,
        requiredLeaf: String?,
        coordinate: String
    ) throws {
        try binding.validate()
        self.binding = binding
        let canonicalAbsolutePath = try PrimeValidationDriverV2GovernorIO
            .canonicalPath(binding.absolutePath)
        if let requiredLeaf {
            guard URL(fileURLWithPath: canonicalAbsolutePath)
                .lastPathComponent == requiredLeaf
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    coordinate + "_leaf"
                )
            }
        }
        absolutePath = canonicalAbsolutePath
        descriptor = Darwin.open(
            absolutePath,
            O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard descriptor >= 3 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_open"
            )
        }
        do {
            var status = stat()
            var named = stat()
            guard fstat(descriptor, &status) == 0,
                  lstat(absolutePath, &named) == 0,
                  status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  status.st_dev == named.st_dev,
                  status.st_ino == named.st_ino,
                  status.st_nlink == 1,
                  status.st_size > 0,
                  status.st_flags == 0,
                  status.st_mode & mode_t(0o022) == 0,
                  status.st_mode & mode_t(0o111) != 0,
                  fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    coordinate + "_metadata"
                )
            }
            identity = try PrimeValidationDriverV2GovernorMetadata(status)
            xattrs = try PrimeValidationDriverV2GovernorXattrs.capture(
                descriptor,
                coordinate: coordinate
            )
            let data = try PrimeValidationDriverV2GovernorIO.readExact(
                descriptor: descriptor,
                byteCount: Int(identity.byteCount),
                coordinate: coordinate
            )
            guard identity.byteCount == binding.content.byteCount,
                  PrimeSHA256.hexDigest(of: data)
                    == binding.content.sha256
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    coordinate + "_content"
                )
            }
            try revalidate(coordinate: coordinate, rehash: false)
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw error
        }
    }

    init(
        duplicatingTestDescriptor source: Int32,
        requiredLeaf: String,
        coordinate: String
    ) throws {
        descriptor = fcntl(source, F_DUPFD_CLOEXEC, 3)
        guard descriptor >= 3 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_duplicate"
            )
        }
        do {
            absolutePath = try PrimeValidationDriverV2GovernorIO
                .pathForDescriptor(
                    descriptor,
                    coordinate: "held_test_image_path"
                )
            guard URL(fileURLWithPath: absolutePath).lastPathComponent
                    == requiredLeaf
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    coordinate + "_leaf"
                )
            }
            var status = stat()
            guard fstat(descriptor, &status) == 0,
                  status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  status.st_nlink == 1,
                  status.st_size > 0,
                  status.st_flags == 0,
                  status.st_mode & mode_t(0o022) == 0,
                  status.st_mode & mode_t(0o111) != 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    coordinate + "_metadata"
                )
            }
            identity = try PrimeValidationDriverV2GovernorMetadata(status)
            let data = try PrimeValidationDriverV2GovernorIO.readExact(
                descriptor: descriptor,
                byteCount: Int(identity.byteCount),
                coordinate: coordinate
            )
            binding = PrimeValidationExecutableBindingV2(
                absolutePath: absolutePath,
                content: .init(data: data)
            )
            xattrs = try PrimeValidationDriverV2GovernorXattrs.capture(
                descriptor,
                coordinate: coordinate
            )
            try revalidate(coordinate: coordinate)
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw error
        }
    }

    deinit {
        if descriptor >= 3 { _ = Darwin.close(descriptor) }
    }

    func revalidate(coordinate: String, rehash: Bool = true) throws {
        var held = stat()
        var named = stat()
        guard descriptor >= 3,
              fstat(descriptor, &held) == 0,
              lstat(absolutePath, &named) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              try PrimeValidationDriverV2GovernorMetadata(held) == identity,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0,
              try PrimeValidationDriverV2GovernorXattrs.capture(
                  descriptor,
                  coordinate: coordinate
              ) == xattrs
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                coordinate + "_changed"
            )
        }
        if rehash {
            let data = try PrimeValidationDriverV2GovernorIO.readExact(
                descriptor: descriptor,
                byteCount: Int(identity.byteCount),
                coordinate: coordinate
            )
            guard PrimeSHA256.hexDigest(of: data)
                    == binding.content.sha256
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    coordinate + "_rehash"
                )
            }
        }
    }

    static func currentExecutable(
        binding: PrimeValidationExecutableBindingV2
    ) throws -> Self {
        var path = [CChar](repeating: 0, count: 4 * Int(MAXPATHLEN))
        let count = path.withUnsafeMutableBytes {
            Darwin.proc_pidpath(
                Darwin.getpid(),
                $0.baseAddress,
                UInt32($0.count)
            )
        }
        guard count > 0,
              count < path.count,
              let value = String(
                  bytes: path.prefix(Int(count)).map {
                      UInt8(bitPattern: $0)
                  },
                  encoding: .utf8
              ),
              value == binding.absolutePath
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "governor_mapped_name"
            )
        }
        let executable = try Self(
            binding: binding,
            requiredLeaf:
                "PrimeValidationWorkflowDriverV2ShotGovernor",
            coordinate: "governor_image"
        )
        do {
            _ = try PrimeValidationDriverV2GovernorProcessProof.mappedImage(
                pid: Darwin.getpid(),
                executable: executable
            )
            try executable.revalidate(coordinate: "governor_image")
        } catch {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "governor_mapped_image_join"
            )
        }
        return executable
    }

}

private struct PrimeValidationDriverV2GovernorVnodeRecord:
    Codable,
    Equatable,
    Sendable
{
    let deviceID: UInt64
    let inode: UInt64
    let byteCount: UInt64

    init(_ metadata: PrimeValidationDriverV2GovernorMetadata) {
        deviceID = metadata.deviceID
        inode = metadata.inode
        byteCount = metadata.byteCount
    }

    private enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case inode
        case byteCount = "byte_count"
    }
}

private struct PrimeValidationDriverV2GovernorJournalLeafBinding:
    Codable,
    Equatable,
    Sendable
{
    let leaf: String
    let byteCount: UInt64
    let sha256: String
    let vnode: PrimeValidationDriverV2GovernorVnodeRecord

    private enum CodingKeys: String, CodingKey {
        case leaf
        case byteCount = "byte_count"
        case sha256
        case vnode
    }
}

private struct PrimeValidationDriverV2GovernorHeldJournalLeaf {
    let binding: PrimeValidationDriverV2GovernorJournalLeafBinding
    let metadata: PrimeValidationDriverV2GovernorMetadata
    let xattrs: PrimeValidationDriverV2GovernorXattrs
    let descriptor: Int32
}

private final class PrimeValidationDriverV2GovernorJournal {
    static let rootLeaf = "gate-e-shot-governor-journal"
    static let capsuleLeaf = "00-capsule.json"
    static let requestLeaf = "01-supervisor-request.json"
    static let startLeaf = "02-outer-start.json"
    static let terminalLeaf = "03-outer-terminal.json"
    static let orderedLeaves = [
        capsuleLeaf,
        requestLeaf,
        startLeaf,
        terminalLeaf,
    ]
    static let caps = [262_144, 262_144, 65_536, 65_536]

    private let baseDescriptor: Int32
    private let baseAbsolutePath: String
    private(set) var descriptor: Int32 = -1
    private let rootDeviceID: UInt64
    private let rootInode: UInt64
    private let rootOwnerUserID: UInt32
    private let rootOwnerGroupID: UInt32
    private let rootXattrs: PrimeValidationDriverV2GovernorXattrs
    private var heldLeaves = [PrimeValidationDriverV2GovernorHeldJournalLeaf]()

    init(
        base: PrimeValidationDriverV2GovernorHeldDirectory,
        filesystem: fsid_t
    ) throws {
        baseDescriptor = base.descriptor
        baseAbsolutePath = base.absolutePath
        let result = Self.rootLeaf.withCString {
            mkdirat(base.descriptor, $0, mode_t(0o700))
        }
        guard result == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "outer_journal_create_\(errno)"
            )
        }
        descriptor = Self.rootLeaf.withCString {
            openat(
                base.descriptor,
                $0,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard descriptor >= 3 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "outer_journal_open"
            )
        }
        do {
            var status = stat()
            guard fstat(descriptor, &status) == 0,
                  status.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
                  status.st_mode & mode_t(0o7777) == mode_t(0o700),
                  status.st_uid == geteuid(),
                  status.st_nlink == 2,
                  status.st_flags == 0,
                  fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0,
                  try PrimeValidationDriverV2GovernorIO.inventory(
                      directory: descriptor,
                      coordinate: "outer_journal"
                  ).isEmpty
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    "outer_journal_metadata"
                )
            }
            _ = try PrimeValidationDriverV2GovernorIO.requireLocalAPFS(
                descriptor,
                sameAs: filesystem,
                coordinate: "outer_journal"
            )
            rootDeviceID = UInt64(bitPattern: Int64(status.st_dev))
            rootInode = UInt64(status.st_ino)
            rootOwnerUserID = status.st_uid
            rootOwnerGroupID = status.st_gid
            rootXattrs = try PrimeValidationDriverV2GovernorXattrs.capture(
                descriptor,
                coordinate: "outer_journal"
            )
            try revalidate()
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw error
        }
    }

    deinit {
        for leaf in heldLeaves where leaf.descriptor >= 3 {
            _ = Darwin.close(leaf.descriptor)
        }
        if descriptor >= 3 { _ = Darwin.close(descriptor) }
    }

    var count: Int { heldLeaves.count }
    var bindings: [PrimeValidationDriverV2GovernorJournalLeafBinding] {
        heldLeaves.map(\.binding)
    }

    func rootLinkCountForTesting() throws -> UInt64 {
        var status = stat()
        guard fstat(descriptor, &status) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_test_root_stat"
            )
        }
        return UInt64(status.st_nlink)
    }

    func publishExact(
        _ data: Data,
        expectedLeaf: String,
        beforeExclusiveOpenForTesting: (() throws -> Void)? = nil
    ) throws -> PrimeValidationDriverV2GovernorJournalLeafBinding {
        try revalidate()
        let ordinal = heldLeaves.count
        guard ordinal < Self.orderedLeaves.count,
              Self.orderedLeaves[ordinal] == expectedLeaf,
              !data.isEmpty,
              data.count <= Self.caps[ordinal],
              data.last != 0x0a
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_publication_order"
            )
        }
        try beforeExclusiveOpenForTesting?()
        let opened = expectedLeaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                mode_t(0o600)
            )
        }
        guard opened >= 3 else {
            if opened >= 0 { _ = Darwin.close(opened) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_exclusive_\(errno)"
            )
        }
        defer { _ = Darwin.close(opened) }
        try PrimeValidationDriverV2GovernorIO.writeAll(
            data,
            descriptor: opened,
            coordinate: "outer_journal_leaf"
        )
        try PrimeValidationDriverV2GovernorIO.synchronize(
            opened,
            coordinate: "outer_journal_leaf_data"
        )
        guard fchmod(opened, mode_t(0o400)) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_leaf_mode"
            )
        }
        try PrimeValidationDriverV2GovernorIO.synchronize(
            opened,
            coordinate: "outer_journal_leaf_frozen"
        )
        try PrimeValidationDriverV2GovernorIO.synchronize(
            descriptor,
            coordinate: "outer_journal_parent"
        )
        let rebound = expectedLeaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard rebound >= 3 else {
            if rebound >= 0 { _ = Darwin.close(rebound) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_rebound"
            )
        }
        var retained = false
        defer { if !retained { _ = Darwin.close(rebound) } }
        var metadata = stat()
        guard fstat(rebound, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              metadata.st_mode & mode_t(0o7777) == mode_t(0o400),
              metadata.st_uid == rootOwnerUserID,
              metadata.st_gid == rootOwnerGroupID,
              metadata.st_nlink == 1,
              metadata.st_size == off_t(data.count),
              metadata.st_flags == 0,
              fcntl(rebound, F_GETFL) & O_ACCMODE == O_RDONLY,
              fcntl(rebound, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_rebound_metadata"
            )
        }
        let frozenMetadata = try PrimeValidationDriverV2GovernorMetadata(
            metadata
        )
        let reboundData = try PrimeValidationDriverV2GovernorIO.readExact(
            descriptor: rebound,
            byteCount: data.count,
            coordinate: "outer_journal_rebound"
        )
        guard reboundData == data else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_rebound_bytes"
            )
        }
        let binding = PrimeValidationDriverV2GovernorJournalLeafBinding(
            leaf: expectedLeaf,
            byteCount: UInt64(data.count),
            sha256: PrimeSHA256.hexDigest(of: data),
            vnode: .init(frozenMetadata)
        )
        let leaf = PrimeValidationDriverV2GovernorHeldJournalLeaf(
            binding: binding,
            metadata: frozenMetadata,
            xattrs: try PrimeValidationDriverV2GovernorXattrs.capture(
                rebound,
                coordinate: "outer_journal_leaf"
            ),
            descriptor: rebound
        )
        heldLeaves.append(leaf)
        retained = true
        try revalidate()
        return binding
    }

    func publishCanonical<Value: Encodable>(
        _ value: Value,
        expectedLeaf: String
    ) throws -> PrimeValidationDriverV2GovernorJournalLeafBinding {
        let data: Data
        do {
            data = try PrimeCanonicalJSON.encode(value)
        } catch {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_canonical_encode"
            )
        }
        return try publishExact(data, expectedLeaf: expectedLeaf)
    }

    func publishCanonicalWithTerminalCollisionForTesting<Value: Encodable>(
        _ value: Value
    ) throws -> PrimeValidationDriverV2GovernorJournalLeafBinding {
        let data = try PrimeCanonicalJSON.encode(value)
        return try publishExact(
            data,
            expectedLeaf: Self.terminalLeaf,
            beforeExclusiveOpenForTesting: {
                try self.injectTerminalCollisionForTesting()
            }
        )
    }

    func independentRequestInputDescriptor() throws -> Int32 {
        guard heldLeaves.count >= 2,
              heldLeaves[1].binding.leaf == Self.requestLeaf
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "request_input_state"
            )
        }
        let opened = Self.requestLeaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard opened >= 3 else {
            if opened >= 0 { _ = Darwin.close(opened) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "request_input_open"
            )
        }
        do {
            let authority = heldLeaves[1]
            var status = stat()
            guard fstat(opened, &status) == 0,
                  try PrimeValidationDriverV2GovernorMetadata(status)
                    == authority.metadata
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                    "request_input_join"
                )
            }
            let requestBytes = try PrimeValidationDriverV2GovernorIO
                .readExact(
                    descriptor: opened,
                    byteCount: Int(authority.binding.byteCount),
                    coordinate: "request_input"
                )
            let authorityBytes = try PrimeValidationDriverV2GovernorIO
                .readExact(
                    descriptor: authority.descriptor,
                    byteCount: Int(authority.binding.byteCount),
                    coordinate: "request_authority"
                )
            guard requestBytes == authorityBytes,
                  lseek(opened, 0, SEEK_SET) == 0,
                  lseek(opened, 0, SEEK_CUR) == 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                    "request_input_join"
                )
            }
            return opened
        } catch {
            _ = Darwin.close(opened)
            throw error
        }
    }

    func injectTerminalCollisionForTesting() throws {
        guard heldLeaves.count == 3 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_test_collision_state"
            )
        }
        let opened = Self.terminalLeaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                mode_t(0o400)
            )
        }
        guard opened >= 3 else {
            if opened >= 0 { _ = Darwin.close(opened) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_test_collision_create"
            )
        }
        _ = Darwin.close(opened)
    }

    func replaceTerminalWithSameBytesForTesting() throws -> (
        retained: PrimeValidationDriverV2GovernorVnodeRecord,
        replacement: PrimeValidationDriverV2GovernorVnodeRecord,
        bytesEqual: Bool
    ) {
        guard heldLeaves.count == 4,
              let authority = heldLeaves.last,
              authority.binding.leaf == Self.terminalLeaf
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_test_rebound_state"
            )
        }
        let data = try PrimeValidationDriverV2GovernorIO.readExact(
            descriptor: authority.descriptor,
            byteCount: Int(authority.binding.byteCount),
            coordinate: "outer_journal_test_rebound_authority"
        )
        let unlinked = Self.terminalLeaf.withCString {
            unlinkat(descriptor, $0, 0)
        }
        guard unlinked == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_test_rebound_unlink"
            )
        }
        let replacement = Self.terminalLeaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                mode_t(0o600)
            )
        }
        guard replacement >= 3 else {
            if replacement >= 0 { _ = Darwin.close(replacement) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_test_rebound_create"
            )
        }
        defer { _ = Darwin.close(replacement) }
        try PrimeValidationDriverV2GovernorIO.writeAll(
            data,
            descriptor: replacement,
            coordinate: "outer_journal_test_rebound_write"
        )
        guard fchmod(replacement, mode_t(0o400)) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_test_rebound_mode"
            )
        }
        try PrimeValidationDriverV2GovernorIO.synchronize(
            replacement,
            coordinate: "outer_journal_test_rebound_data"
        )
        try PrimeValidationDriverV2GovernorIO.synchronize(
            descriptor,
            coordinate: "outer_journal_test_rebound_parent"
        )
        var replacementStatus = stat()
        guard fstat(replacement, &replacementStatus) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_test_rebound_stat"
            )
        }
        let replacementMetadata = try
            PrimeValidationDriverV2GovernorMetadata(replacementStatus)
        let replacementData = try PrimeValidationDriverV2GovernorIO.readExact(
            descriptor: replacement,
            byteCount: data.count,
            coordinate: "outer_journal_test_rebound_bytes"
        )
        guard replacementData == data,
              replacementMetadata.deviceID == authority.metadata.deviceID,
              replacementMetadata.inode != authority.metadata.inode
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_test_rebound_identity"
            )
        }
        return (
            .init(authority.metadata),
            .init(replacementMetadata),
            true
        )
    }

    func revalidate() throws {
        guard descriptor >= 3,
              heldLeaves.count <= Self.orderedLeaves.count,
              heldLeaves.map(\.binding.leaf)
                == Array(Self.orderedLeaves.prefix(heldLeaves.count)),
              try PrimeValidationDriverV2GovernorIO.inventory(
                  directory: descriptor,
                  coordinate: "outer_journal"
              ) == heldLeaves.map(\.binding.leaf).sorted()
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_inventory"
            )
        }
        var root = stat()
        var named = stat()
        let namedResult = Self.rootLeaf.withCString {
            fstatat(baseDescriptor, $0, &named, AT_SYMLINK_NOFOLLOW)
        }
        guard fstat(descriptor, &root) == 0,
              namedResult == 0,
              root.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              root.st_dev == named.st_dev,
              root.st_ino == named.st_ino,
              UInt64(bitPattern: Int64(root.st_dev)) == rootDeviceID,
              UInt64(root.st_ino) == rootInode,
              root.st_uid == rootOwnerUserID,
              root.st_gid == rootOwnerGroupID,
              root.st_mode & mode_t(0o7777) == mode_t(0o700),
              root.st_nlink == nlink_t(2 + heldLeaves.count),
              root.st_flags == 0,
              try PrimeValidationDriverV2GovernorXattrs.capture(
                  descriptor,
                  coordinate: "outer_journal"
              ) == rootXattrs
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_journal_root_changed"
            )
        }
        for leaf in heldLeaves {
            var held = stat()
            var rebound = stat()
            let reboundResult = leaf.binding.leaf.withCString {
                fstatat(descriptor, $0, &rebound, AT_SYMLINK_NOFOLLOW)
            }
            guard fstat(leaf.descriptor, &held) == 0,
                  reboundResult == 0,
                  try PrimeValidationDriverV2GovernorMetadata(held)
                    == leaf.metadata,
                  try PrimeValidationDriverV2GovernorMetadata(rebound)
                    == leaf.metadata,
                  try PrimeValidationDriverV2GovernorXattrs.capture(
                      leaf.descriptor,
                      coordinate: "outer_journal_leaf"
                  ) == leaf.xattrs,
                  PrimeSHA256.hexDigest(
                      of: try PrimeValidationDriverV2GovernorIO.readExact(
                          descriptor: leaf.descriptor,
                          byteCount: Int(leaf.binding.byteCount),
                          coordinate: "outer_journal_leaf"
                      )
                  ) == leaf.binding.sha256
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                    "outer_journal_leaf_changed"
                )
            }
        }
        _ = baseAbsolutePath
    }
}

private struct PrimeValidationDriverV2GovernorCaptureObservation:
    Codable,
    Equatable,
    Sendable
{
    let leaf: String
    let byteCount: UInt64
    let sha256: String
    let reachedEOF: Bool
    let overflowed: Bool
    let descriptorJoined: Bool

    private enum CodingKeys: String, CodingKey {
        case leaf
        case byteCount = "byte_count"
        case sha256
        case reachedEOF = "reached_eof"
        case overflowed
        case descriptorJoined = "descriptor_joined"
    }
}

private final class PrimeValidationDriverV2GovernorCapture {
    static let maximumByteCount: UInt64 = 65_536
    let leaf: String
    private let baseDescriptor: Int32
    private(set) var descriptor: Int32
    private let initial: PrimeValidationDriverV2GovernorMetadata
    private let xattrs: PrimeValidationDriverV2GovernorXattrs

    init(
        base: PrimeValidationDriverV2GovernorHeldDirectory,
        leaf: String
    ) throws {
        self.leaf = leaf
        baseDescriptor = base.descriptor
        descriptor = leaf.withCString {
            openat(
                base.descriptor,
                $0,
                O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                mode_t(0o600)
            )
        }
        guard descriptor >= 3 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "capture_\(leaf)_open"
            )
        }
        do {
            var status = stat()
            guard fstat(descriptor, &status) == 0,
                  status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  status.st_mode & mode_t(0o7777) == mode_t(0o600),
                  status.st_uid == geteuid(),
                  status.st_nlink == 1,
                  status.st_size == 0,
                  status.st_flags == 0,
                  fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    "capture_\(leaf)_metadata"
                )
            }
            initial = try PrimeValidationDriverV2GovernorMetadata(status)
            xattrs = try PrimeValidationDriverV2GovernorXattrs.capture(
                descriptor,
                coordinate: "capture_\(leaf)"
            )
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw error
        }
    }

    deinit {
        if descriptor >= 3 { _ = Darwin.close(descriptor) }
    }

    func finalize(
        reachedEOF: Bool,
        overflowed: Bool
    ) throws -> PrimeValidationDriverV2GovernorCaptureObservation {
        try PrimeValidationDriverV2GovernorIO.synchronize(
            descriptor,
            coordinate: "capture_\(leaf)"
        )
        var held = stat()
        var named = stat()
        let namedResult = leaf.withCString {
            fstatat(baseDescriptor, $0, &named, AT_SYMLINK_NOFOLLOW)
        }
        guard fstat(descriptor, &held) == 0,
              namedResult == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              UInt64(bitPattern: Int64(held.st_dev)) == initial.deviceID,
              UInt64(held.st_ino) == initial.inode,
              held.st_uid == initial.ownerUserID,
              held.st_gid == initial.ownerGroupID,
              held.st_mode & mode_t(0o7777) == mode_t(0o600),
              held.st_nlink == 1,
              held.st_size >= 0,
              UInt64(held.st_size) <= Self.maximumByteCount,
              held.st_flags == 0,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0,
              try PrimeValidationDriverV2GovernorXattrs.capture(
                  descriptor,
                  coordinate: "capture_\(leaf)"
              ) == xattrs
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                "capture_\(leaf)_changed"
            )
        }
        let data = try PrimeValidationDriverV2GovernorIO.readExact(
            descriptor: descriptor,
            byteCount: Int(held.st_size),
            coordinate: "capture_\(leaf)"
        )
        return .init(
            leaf: leaf,
            byteCount: UInt64(data.count),
            sha256: PrimeSHA256.hexDigest(of: data),
            reachedEOF: reachedEOF,
            overflowed: overflowed,
            descriptorJoined: true
        )
    }
}

private final class PrimeValidationDriverV2GovernorDrain:
    @unchecked Sendable
{
    private let queue: DispatchQueue
    private let group = DispatchGroup()
    private let lock = NSLock()
    private var readDescriptor: Int32
    private let capture: PrimeValidationDriverV2GovernorCapture
    private var reachedEOF = false
    private var overflowed = false
    private var finished = false

    init(
        readDescriptor: Int32,
        capture: PrimeValidationDriverV2GovernorCapture,
        label: String
    ) {
        self.readDescriptor = readDescriptor
        self.capture = capture
        queue = DispatchQueue(label: label)
    }

    deinit {
        if readDescriptor >= 3 { _ = Darwin.close(readDescriptor) }
    }

    func start() {
        group.enter()
        queue.async { [self] in
            var buffer = [UInt8](repeating: 0, count: 16 * 1024)
            var retained: UInt64 = 0
            drainLoop: while true {
                let count = buffer.withUnsafeMutableBytes {
                    Darwin.read(readDescriptor, $0.baseAddress, $0.count)
                }
                if count < 0, errno == EINTR { continue }
                if count < 0 { break drainLoop }
                if count == 0 {
                    lock.lock()
                    reachedEOF = true
                    lock.unlock()
                    break drainLoop
                }
                let available = retained <
                    PrimeValidationDriverV2GovernorCapture.maximumByteCount
                    ? PrimeValidationDriverV2GovernorCapture
                        .maximumByteCount - retained
                    : 0
                let writing = min(UInt64(count), available)
                if writing > 0 {
                    var offset = 0
                    while offset < Int(writing) {
                        let written = buffer.withUnsafeBytes {
                            Darwin.write(
                                capture.descriptor,
                                $0.baseAddress!.advanced(by: offset),
                                Int(writing) - offset
                            )
                        }
                        if written < 0, errno == EINTR { continue }
                        guard written > 0 else { break drainLoop }
                        offset += written
                    }
                    retained += UInt64(offset)
                }
                if UInt64(count) > writing {
                    lock.lock()
                    overflowed = true
                    lock.unlock()
                }
                // After overflow, keep draining and discard through EOF.
            }
            _ = Darwin.close(readDescriptor)
            readDescriptor = -1
            lock.lock()
            finished = true
            lock.unlock()
            group.leave()
        }
    }

    func finish(
        deadline: PrimeValidationDriverV2GovernorDeadline
    ) throws -> PrimeValidationDriverV2GovernorCaptureObservation {
        guard group.wait(timeout: deadline.dispatchDeadline) == .success else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "output_drain_deadline"
            )
        }
        lock.lock()
        let eof = reachedEOF
        let overflow = overflowed
        let didFinish = finished
        lock.unlock()
        guard didFinish else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "output_drain_state"
            )
        }
        return try capture.finalize(
            reachedEOF: eof,
            overflowed: overflow
        )
    }
}

private struct PrimeValidationDriverV2GovernorInnerLeaf:
    Codable,
    Equatable,
    Sendable
{
    let leaf: String
    let byteCount: UInt64
    let sha256: String

    private enum CodingKeys: String, CodingKey {
        case leaf
        case byteCount = "byte_count"
        case sha256
    }
}

private struct PrimeValidationDriverV2GovernorHeldInnerLeaf {
    let publicValue: PrimeValidationDriverV2GovernorInnerLeaf
    let metadata: PrimeValidationDriverV2GovernorMetadata
    let xattrs: PrimeValidationDriverV2GovernorXattrs
    let data: Data
    let descriptor: Int32
}

private final class PrimeValidationDriverV2GovernorInnerSnapshot {
    let immutablePrefix: [PrimeValidationDriverV2GovernorInnerLeaf]
    let rawTerminalSHA256: String?
    let recordedChildProcessGroups: Set<Int32>
    private let journalAbsolutePath: String
    private let journalDescriptor: Int32
    private let journalAdmissionMetadata:
        PrimeValidationDriverV2GovernorMetadata
    private let journalXattrs: PrimeValidationDriverV2GovernorXattrs
    private let held: [PrimeValidationDriverV2GovernorHeldInnerLeaf]

    init(
        immutablePrefix: [PrimeValidationDriverV2GovernorInnerLeaf],
        rawTerminalSHA256: String?,
        recordedChildProcessGroups: Set<Int32>,
        journalAbsolutePath: String,
        journalDescriptor: Int32,
        journalAdmissionMetadata:
            PrimeValidationDriverV2GovernorMetadata,
        journalXattrs: PrimeValidationDriverV2GovernorXattrs,
        held: [PrimeValidationDriverV2GovernorHeldInnerLeaf]
    ) {
        self.immutablePrefix = immutablePrefix
        self.rawTerminalSHA256 = rawTerminalSHA256
        self.recordedChildProcessGroups = recordedChildProcessGroups
        self.journalAbsolutePath = journalAbsolutePath
        self.journalDescriptor = journalDescriptor
        self.journalAdmissionMetadata = journalAdmissionMetadata
        self.journalXattrs = journalXattrs
        self.held = held
    }

    deinit {
        for leaf in held where leaf.descriptor >= 3 {
            _ = Darwin.close(leaf.descriptor)
        }
    }

    var complete: Bool {
        immutablePrefix.count
            == PrimeValidationDriverV2GovernorInnerJournal.orderedLeaves.count
    }

    func revalidate() throws {
        var root = stat()
        var namedRoot = stat()
        guard fstat(journalDescriptor, &root) == 0,
              lstat(journalAbsolutePath, &namedRoot) == 0,
              root.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              namedRoot.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              root.st_dev == namedRoot.st_dev,
              root.st_ino == namedRoot.st_ino,
              UInt64(bitPattern: Int64(root.st_dev))
                == journalAdmissionMetadata.deviceID,
              UInt64(root.st_ino) == journalAdmissionMetadata.inode,
              root.st_uid == journalAdmissionMetadata.ownerUserID,
              root.st_gid == journalAdmissionMetadata.ownerGroupID,
              root.st_mode & mode_t(0o7777) == mode_t(0o700),
              root.st_nlink == nlink_t(2 + held.count),
              root.st_flags == 0,
              fcntl(journalDescriptor, F_GETFD) & FD_CLOEXEC != 0,
              try PrimeValidationDriverV2GovernorXattrs.capture(
                  journalDescriptor,
                  coordinate: "inner_journal_retained_root"
              ) == journalXattrs
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                "inner_journal_retained_root"
            )
        }
        guard immutablePrefix == held.map(\.publicValue),
              try PrimeValidationDriverV2GovernorIO.inventory(
                  directory: journalDescriptor,
                  coordinate: "inner_journal_retained"
              ) == immutablePrefix.map(\.leaf).sorted()
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                "inner_journal_retained_prefix"
            )
        }
        for leaf in held {
            var current = stat()
            var named = stat()
            let namedResult = leaf.publicValue.leaf.withCString {
                fstatat(
                    journalDescriptor,
                    $0,
                    &named,
                    AT_SYMLINK_NOFOLLOW
                )
            }
            guard fstat(leaf.descriptor, &current) == 0,
                  namedResult == 0,
                  try PrimeValidationDriverV2GovernorMetadata(current)
                    == leaf.metadata,
                  try PrimeValidationDriverV2GovernorMetadata(named)
                    == leaf.metadata,
                  try PrimeValidationDriverV2GovernorXattrs.capture(
                      leaf.descriptor,
                      coordinate: "inner_journal_retained_leaf"
                  ) == leaf.xattrs,
                  try PrimeValidationDriverV2GovernorIO.readExact(
                      descriptor: leaf.descriptor,
                      byteCount: leaf.data.count,
                      coordinate: "inner_journal_retained_leaf"
                  ) == leaf.data,
                  PrimeSHA256.hexDigest(of: leaf.data)
                    == leaf.publicValue.sha256
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .postReapRejection,
                    "inner_journal_retained_leaf"
                )
            }
        }
    }

    var durableFrames:
        [PrimeValidationDriverV2FixedProbeJournalLeafFrameV2]
    {
        held.map {
            PrimeValidationDriverV2FixedProbeJournalLeafFrameV2(
                leaf: $0.publicValue.leaf,
                framedBytes: $0.data,
                vnode: .init(
                    deviceID: $0.metadata.deviceID,
                    inode: $0.metadata.inode
                )
            )
        }
    }

    var durableVnodes: [PrimeValidationDriverV2GovernorVnodeRecord] {
        held.map { .init($0.metadata) }
    }

    var journalRootBinding: PrimeValidationDirectoryBindingV2 {
        PrimeValidationDirectoryBindingV2(
            absolutePath: journalAbsolutePath,
            deviceID: journalAdmissionMetadata.deviceID,
            inode: journalAdmissionMetadata.inode,
            ownerUserID: journalAdmissionMetadata.ownerUserID,
            mode: 0o700
        )
    }

}

private final class PrimeValidationDriverV2GovernorInnerJournal {
    static let roleBases = [
        "01-prime-head-pre", "02-prime-object-format",
        "03-prime-status-pre", "04-prime-tree-discovery",
        "05-prime-tree-replay", "06-prime-status-post",
        "07-prime-head-post", "08-companion-head-pre",
        "09-companion-object-format", "10-companion-status-pre",
        "11-companion-tree-discovery", "12-companion-tree-replay",
        "13-companion-status-post", "14-companion-head-post",
        "15-swift-version", "16-swift-target-info",
    ]
    static let orderedLeaves = ["gate-e-prestart.json"]
        + roleBases.flatMap { ["\($0)-start.json", "\($0)-terminal.json"] }
        + ["gate-e-raw-terminal.json"]

    let absolutePath: String
    private(set) var descriptor: Int32
    private let identity: PrimeValidationDriverV2GovernorMetadata
    private let xattrs: PrimeValidationDriverV2GovernorXattrs

    init(workspaceAbsolutePath: String) throws {
        absolutePath = workspaceAbsolutePath
            + ".driver-v2-gate-e-journal"
        descriptor = Darwin.open(
            absolutePath,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard descriptor >= 3 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "inner_journal_open"
            )
        }
        do {
            var status = stat()
            guard fstat(descriptor, &status) == 0,
                  status.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
                  status.st_mode & mode_t(0o7777) == mode_t(0o700),
                  status.st_uid == geteuid(),
                  status.st_nlink == 2,
                  status.st_flags == 0,
                  try PrimeValidationDriverV2GovernorIO.inventory(
                      directory: descriptor,
                      coordinate: "inner_journal"
                  ).isEmpty
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    "inner_journal_initial_state"
                )
            }
            identity = try PrimeValidationDriverV2GovernorMetadata(status)
            xattrs = try PrimeValidationDriverV2GovernorXattrs.capture(
                descriptor,
                coordinate: "inner_journal"
            )
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw error
        }
    }

    deinit {
        if descriptor >= 3 { _ = Darwin.close(descriptor) }
    }

    func snapshot() throws -> PrimeValidationDriverV2GovernorInnerSnapshot {
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              lstat(absolutePath, &named) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              UInt64(bitPattern: Int64(held.st_dev)) == identity.deviceID,
              UInt64(held.st_ino) == identity.inode,
              held.st_uid == identity.ownerUserID,
              held.st_gid == identity.ownerGroupID,
              held.st_mode & mode_t(0o7777) == mode_t(0o700),
              held.st_flags == 0,
              try PrimeValidationDriverV2GovernorXattrs.capture(
                  descriptor,
                  coordinate: "inner_journal"
              ) == xattrs
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                "inner_journal_root_changed"
            )
        }
        let inventory = try PrimeValidationDriverV2GovernorIO.inventory(
            directory: descriptor,
            coordinate: "inner_journal"
        )
        let allowed = Set(Self.orderedLeaves)
        guard Set(inventory).isSubset(of: allowed) else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                "inner_journal_extra_leaf"
            )
        }
        var prefixCount = 0
        while prefixCount < Self.orderedLeaves.count,
              inventory.contains(Self.orderedLeaves[prefixCount]) {
            prefixCount += 1
        }
        guard inventory.sorted()
                == Array(Self.orderedLeaves.prefix(prefixCount)).sorted(),
              held.st_nlink == nlink_t(2 + prefixCount)
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                "inner_journal_nonprefix"
            )
        }
        var leaves = [PrimeValidationDriverV2GovernorInnerLeaf]()
        var heldLeaves = [PrimeValidationDriverV2GovernorHeldInnerLeaf]()
        var retainHeldLeaves = false
        defer {
            if !retainHeldLeaves {
                for leaf in heldLeaves where leaf.descriptor >= 3 {
                    _ = Darwin.close(leaf.descriptor)
                }
            }
        }
        var childGroups = Set<Int32>()
        for leaf in Self.orderedLeaves.prefix(prefixCount) {
            let opened = leaf.withCString {
                openat(
                    descriptor,
                    $0,
                    O_RDONLY | O_NOFOLLOW | O_CLOEXEC
                )
            }
            guard opened >= 3 else {
                if opened >= 0 { _ = Darwin.close(opened) }
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                    "inner_journal_leaf_open"
                )
            }
            var retainOpened = false
            defer { if !retainOpened { _ = Darwin.close(opened) } }
            var status = stat()
            let leafXattrs: PrimeValidationDriverV2GovernorXattrs
            do {
                leafXattrs = try PrimeValidationDriverV2GovernorXattrs.capture(
                    opened,
                    coordinate: "inner_journal_leaf"
                )
            } catch {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .postReapRejection,
                    "inner_journal_leaf_xattrs"
                )
            }
            guard fstat(opened, &status) == 0,
                  status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  status.st_mode & mode_t(0o7777) == mode_t(0o400),
                  status.st_uid == geteuid(),
                  status.st_nlink == 1,
                  status.st_size > 0,
                  status.st_size <= 65_536,
                  status.st_flags == 0,
                  fcntl(opened, F_GETFL) & O_ACCMODE == O_RDONLY,
                  fcntl(opened, F_GETFD) & FD_CLOEXEC != 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                    "inner_journal_leaf_metadata"
                )
            }
            let data = try PrimeValidationDriverV2GovernorIO.readExact(
                descriptor: opened,
                byteCount: Int(status.st_size),
                coordinate: "inner_journal_leaf"
            )
            guard data.last == 0x0a else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                    "inner_journal_leaf_frame"
                )
            }
            let publicValue = PrimeValidationDriverV2GovernorInnerLeaf(
                leaf: leaf,
                byteCount: UInt64(data.count),
                sha256: PrimeSHA256.hexDigest(of: data)
            )
            leaves.append(publicValue)
            heldLeaves.append(
                .init(
                    publicValue: publicValue,
                    metadata:
                        try PrimeValidationDriverV2GovernorMetadata(status),
                    xattrs: leafXattrs,
                    data: data,
                    descriptor: opened
                )
            )
            retainOpened = true
            if leaf.hasSuffix("-start.json"),
               let object = try? JSONSerialization.jsonObject(
                   with: Data(data.dropLast())
               ) as? [String: Any],
               let value = (
                   object["processGroupIdentifier"]
                       ?? object["process_group_identifier"]
               ) as? NSNumber,
               value.int32Value > 0
            {
                childGroups.insert(value.int32Value)
            }
        }
        let snapshot = PrimeValidationDriverV2GovernorInnerSnapshot(
            immutablePrefix: leaves,
            rawTerminalSHA256: leaves.last?.leaf
                == "gate-e-raw-terminal.json"
                ? leaves.last?.sha256
                : nil,
            recordedChildProcessGroups: childGroups,
            journalAbsolutePath: absolutePath,
            journalDescriptor: descriptor,
            journalAdmissionMetadata: identity,
            journalXattrs: xattrs,
            held: heldLeaves
        )
        retainHeldLeaves = true
        try snapshot.revalidate()
        return snapshot
    }
}

private struct PrimeValidationDriverV2GovernorCWDProof:
    Codable,
    Equatable,
    Sendable
{
    let descriptorDeviceID: UInt64
    let descriptorInode: UInt64
    let childDeviceID: UInt64
    let childInode: UInt64
    let joined: Bool

    private enum CodingKeys: String, CodingKey {
        case descriptorDeviceID = "descriptor_device_id"
        case descriptorInode = "descriptor_inode"
        case childDeviceID = "child_device_id"
        case childInode = "child_inode"
        case joined
    }
}

private struct PrimeValidationDriverV2GovernorMappedImageProof:
    Codable,
    Equatable,
    Sendable
{
    let deviceID: UInt64
    let inode: UInt64
    let queryCount: Int
    let pathTelemetry: String
    let joined: Bool

    private enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case inode
        case queryCount = "query_count"
        case pathTelemetry = "path_telemetry"
        case joined
    }
}

private enum PrimeValidationDriverV2GovernorProcessProof {
    static func cwd(
        pid: pid_t,
        directory: PrimeValidationDriverV2GovernorHeldDirectory
    ) throws -> PrimeValidationDriverV2GovernorCWDProof {
        var held = stat()
        var raw = proc_vnodepathinfo()
        let expected = MemoryLayout<proc_vnodepathinfo>.size
        let returned = withUnsafeMutablePointer(to: &raw) {
            proc_pidinfo(
                pid,
                PROC_PIDVNODEPATHINFO,
                0,
                $0,
                Int32(expected)
            )
        }
        let current = raw.pvi_cdir.vip_vi.vi_stat
        guard fstat(directory.descriptor, &held) == 0,
              returned == Int32(expected),
              current.vst_mode & UInt16(S_IFMT) == UInt16(S_IFDIR),
              UInt64(bitPattern: Int64(current.vst_dev))
                == UInt64(bitPattern: Int64(held.st_dev)),
              current.vst_ino == UInt64(held.st_ino)
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "suspended_cwd_join"
            )
        }
        return .init(
            descriptorDeviceID: UInt64(bitPattern: Int64(held.st_dev)),
            descriptorInode: UInt64(held.st_ino),
            childDeviceID: UInt64(bitPattern: Int64(current.vst_dev)),
            childInode: current.vst_ino,
            joined: true
        )
    }

    static func mappedImage(
        pid: pid_t,
        executable: PrimeValidationDriverV2GovernorHeldExecutable
    ) throws -> PrimeValidationDriverV2GovernorMappedImageProof {
        var address: UInt64 = 0
        var queryCount = 0
        while queryCount < 4_096 {
            var raw = proc_regionwithpathinfo()
            errno = 0
            let returned = withUnsafeMutablePointer(to: &raw) {
                proc_pidinfo(
                    pid,
                    PROC_PIDREGIONPATHINFO,
                    address,
                    $0,
                    Int32(MemoryLayout<proc_regionwithpathinfo>.size)
                )
            }
            guard returned == Int32(MemoryLayout<proc_regionwithpathinfo>.size)
            else { break }
            queryCount += 1
            let region = raw.prp_prinfo
            let vnode = raw.prp_vip.vip_vi.vi_stat
            if region.pri_offset == 0,
               region.pri_protection & UInt32(VM_PROT_EXECUTE) != 0,
               UInt64(bitPattern: Int64(vnode.vst_dev))
                    == executable.identity.deviceID,
               vnode.vst_ino == executable.identity.inode
            {
                var pathStorage = raw.prp_vip.vip_path
                let telemetry = withUnsafeBytes(of: &pathStorage) { bytes in
                    String(
                        bytes: bytes.prefix { $0 != 0 },
                        encoding: .utf8
                    )
                } ?? ""
                guard telemetry == executable.absolutePath else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                        "mapped_image_name_join"
                    )
                }
                return .init(
                    deviceID: executable.identity.deviceID,
                    inode: executable.identity.inode,
                    queryCount: queryCount,
                    pathTelemetry: telemetry,
                    joined: true
                )
            }
            let end = region.pri_address.addingReportingOverflow(
                region.pri_size
            )
            guard region.pri_size > 0,
                  !end.overflow,
                  end.partialValue > address
            else { break }
            address = end.partialValue
        }
        throw governorRejected(
            PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
            "mapped_image_join"
        )
    }
}

private struct PrimeValidationDriverV2GovernorSessionMember:
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    let processIdentifier: Int32
    let parentProcessIdentifier: Int32
    let sessionIdentifier: Int32
    let processGroupIdentifier: Int32
    let ownerUserID: UInt32
    let kernelStatus: UInt32
    let startSeconds: UInt64
    let startMicroseconds: UInt64
    let mappedDeviceID: UInt64?
    let mappedInode: UInt64?
    let mappedPathTelemetry: String?

    var generationKey: String {
        "\(processIdentifier):\(startSeconds):\(startMicroseconds)"
    }

    var stoppedOrZombie: Bool {
        kernelStatus == 4 || kernelStatus == 5
    }

    private enum CodingKeys: String, CodingKey {
        case processIdentifier = "process_identifier"
        case parentProcessIdentifier = "parent_process_identifier"
        case sessionIdentifier = "session_identifier"
        case processGroupIdentifier = "process_group_identifier"
        case ownerUserID = "owner_user_id"
        case kernelStatus = "kernel_status"
        case startSeconds = "start_seconds"
        case startMicroseconds = "start_microseconds"
        case mappedDeviceID = "mapped_device_id"
        case mappedInode = "mapped_inode"
        case mappedPathTelemetry = "mapped_path_telemetry"
    }
}

private struct PrimeValidationDriverV2GovernorWaitObservation:
    Codable,
    Equatable,
    Sendable
{
    let requestedProcessIdentifier: Int32
    let returnedProcessIdentifier: Int32
    let waitOptions: Int32
    let rawWaitStatus: Int32
    let returnedAtUptimeNanoseconds: UInt64
    let exitedNormally: Bool
    let exitStatus: Int32
    let terminationSignal: Int32
    let coreDumped: Bool

    init(
        pid: pid_t,
        rawStatus: Int32,
        waitOptions: Int32,
        returnedAt: UInt64
    ) {
        requestedProcessIdentifier = pid
        returnedProcessIdentifier = pid
        self.waitOptions = waitOptions
        rawWaitStatus = rawStatus
        returnedAtUptimeNanoseconds = returnedAt
        exitedNormally = rawStatus & 0x7f == 0
        exitStatus = exitedNormally ? (rawStatus >> 8) & 0xff : 0
        terminationSignal = rawStatus & 0x7f
        coreDumped = rawStatus & 0x80 != 0
    }

    private enum CodingKeys: String, CodingKey {
        case requestedProcessIdentifier =
            "requested_process_identifier"
        case returnedProcessIdentifier =
            "returned_process_identifier"
        case waitOptions = "wait_options"
        case rawWaitStatus = "raw_wait_status"
        case returnedAtUptimeNanoseconds =
            "returned_at_uptime_nanoseconds"
        case exitedNormally = "exited_normally"
        case exitStatus = "exit_status"
        case terminationSignal = "termination_signal"
        case coreDumped = "core_dumped"
    }
}

private struct PrimeValidationDriverV2GovernorConservation:
    Codable,
    Equatable,
    Sendable
{
    let supervisorSessionIdentifier: Int32
    let capturedMembers: [PrimeValidationDriverV2GovernorSessionMember]
    let capturedProcessGroups: [Int32]
    let completeScanCount: Int
    let finalEmptyScanCount: Int
    let capturedGenerationsAbsent: Bool
    let capturedGroupsAbsent: Bool
    let sessionEmpty: Bool
    let ordinaryExitPath: Bool

    private enum CodingKeys: String, CodingKey {
        case supervisorSessionIdentifier =
            "supervisor_session_identifier"
        case capturedMembers = "captured_members"
        case capturedProcessGroups = "captured_process_groups"
        case completeScanCount = "complete_scan_count"
        case finalEmptyScanCount = "final_empty_scan_count"
        case capturedGenerationsAbsent = "captured_generations_absent"
        case capturedGroupsAbsent = "captured_groups_absent"
        case sessionEmpty = "session_empty"
        case ordinaryExitPath = "ordinary_exit_path"
    }
}

private final class PrimeValidationDriverV2GovernorDeathWatcher:
    @unchecked Sendable
{
    private let source: DispatchSourceProcess
    private let semaphore = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var observed = false

    init(pid: pid_t) {
        source = DispatchSource.makeProcessSource(
            identifier: pid,
            eventMask: .exit,
            queue: DispatchQueue(
                label: "prime.validation.driver-v2.governor.death"
            )
        )
        source.setEventHandler { [weak self] in
            guard let self else { return }
            self.lock.lock()
            let signal = !self.observed
            self.observed = true
            self.lock.unlock()
            if signal { self.semaphore.signal() }
        }
        source.resume()
    }

    deinit { source.cancel() }

    func hasObservedExit() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return observed
    }

    func wait(deadline: PrimeValidationDriverV2GovernorDeadline) -> Bool {
        if hasObservedExit() { return true }
        // Keep a fixed interval inside the same outer deadline for the
        // mandatory stopped-census/kill/reap transition.
        let containmentReserve: UInt64 = 5_000_000_000
        let latestOrdinaryDeath = deadline.expiresAt > containmentReserve
            ? deadline.expiresAt - containmentReserve
            : deadline.startedAt
        return semaphore.wait(
            timeout: DispatchTime(
                uptimeNanoseconds: latestOrdinaryDeath
            )
        ) == .success
    }

    func waitForContainmentDeath(
        deadline: PrimeValidationDriverV2GovernorDeadline
    ) -> Bool {
        if hasObservedExit() { return true }
        return semaphore.wait(timeout: deadline.dispatchDeadline) == .success
    }
}

private enum PrimeValidationDriverV2GovernorSessionCensus {
    static let maximumScans = 256
    static let pidCapacity = 131_072

    static func scan(
        sessionIdentifier: pid_t
    ) throws -> [PrimeValidationDriverV2GovernorSessionMember] {
        for _ in 0 ..< 4 {
            var identifiers = [Int32](repeating: 0, count: pidCapacity)
            let byteCapacity = identifiers.count
                * MemoryLayout<Int32>.size
            errno = 0
            let returned = identifiers.withUnsafeMutableBytes {
                proc_listpids(
                    UInt32(PROC_ALL_PIDS),
                    0,
                    $0.baseAddress,
                    Int32($0.count)
                )
            }
            guard returned > 0,
                  Int(returned) < byteCapacity,
                  Int(returned) % MemoryLayout<Int32>.size == 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                    "session_census_capacity"
                )
            }
            let count = Int(returned) / MemoryLayout<Int32>.size
            let positive = identifiers.prefix(count).filter { $0 > 0 }
            guard Set(positive).count == positive.count else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                    "session_census_duplicate_pid"
                )
            }
            var retry = false
            var members = [PrimeValidationDriverV2GovernorSessionMember]()
            for pid in positive.sorted() {
                errno = 0
                let observedSession = Darwin.getsid(pid)
                if observedSession < 0 {
                    if errno == ESRCH { retry = true; break }
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                        "session_census_getsid_\(errno)"
                    )
                }
                guard observedSession == sessionIdentifier else { continue }
                var first = proc_bsdinfo()
                let expected = MemoryLayout<proc_bsdinfo>.size
                errno = 0
                let firstCount = withUnsafeMutablePointer(to: &first) {
                    proc_pidinfo(
                        pid,
                        PROC_PIDTBSDINFO,
                        0,
                        $0,
                        Int32(expected)
                    )
                }
                if firstCount <= 0, errno == ESRCH {
                    retry = true
                    break
                }
                guard firstCount == Int32(expected) else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                        "session_census_bsdinfo_\(errno)"
                    )
                }
                errno = 0
                let group = Darwin.getpgid(pid)
                if group < 0, errno == ESRCH {
                    retry = true
                    break
                }
                guard group > 0 else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                        "session_census_getpgid_\(errno)"
                    )
                }
                var second = proc_bsdinfo()
                errno = 0
                let secondCount = withUnsafeMutablePointer(to: &second) {
                    proc_pidinfo(
                        pid,
                        PROC_PIDTBSDINFO,
                        0,
                        $0,
                        Int32(expected)
                    )
                }
                if secondCount <= 0, errno == ESRCH {
                    retry = true
                    break
                }
                guard secondCount == Int32(expected),
                      first.pbi_start_tvsec == second.pbi_start_tvsec,
                      first.pbi_start_tvusec == second.pbi_start_tvusec,
                      first.pbi_pid == second.pbi_pid,
                      first.pbi_pid == UInt32(pid)
                else {
                    retry = true
                    break
                }
                let mapped = mappedIdentityIfAvailable(pid: pid)
                members.append(
                    .init(
                        processIdentifier: pid,
                        parentProcessIdentifier: Int32(first.pbi_ppid),
                        sessionIdentifier: observedSession,
                        processGroupIdentifier: group,
                        ownerUserID: first.pbi_uid,
                        kernelStatus: first.pbi_status,
                        startSeconds: first.pbi_start_tvsec,
                        startMicroseconds: first.pbi_start_tvusec,
                        mappedDeviceID: mapped?.deviceID,
                        mappedInode: mapped?.inode,
                        mappedPathTelemetry: mapped?.path
                    )
                )
            }
            if retry { continue }
            guard Set(members.map(\.generationKey)).count == members.count
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                    "session_census_duplicate_generation"
                )
            }
            return members.sorted {
                $0.processIdentifier < $1.processIdentifier
            }
        }
        throw governorRejected(
            PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
            "session_census_nonconvergent_query"
        )
    }

    static func contain(
        supervisorPID: pid_t,
        deathWatcher: PrimeValidationDriverV2GovernorDeathWatcher,
        deadline: PrimeValidationDriverV2GovernorDeadline,
        onExactReap: () -> Void = {}
    ) throws -> (
        wait: PrimeValidationDriverV2GovernorWaitObservation,
        conservation: PrimeValidationDriverV2GovernorConservation
    ) {
        var scanCount = 0
        var captured = [String: PrimeValidationDriverV2GovernorSessionMember]()
        var groups = Set<Int32>([supervisorPID])

        let stopTarget = -supervisorPID
        errno = 0
        let stopReturn = Darwin.kill(stopTarget, SIGSTOP)
        let stopErrno = errno
        let deathEventCheckPerformed: Bool
        let deathEventObserved: Bool
        if stopReturn == -1, stopErrno == ESRCH {
            deathEventCheckPerformed = true
            deathEventObserved = deathWatcher.hasObservedExit()
        } else {
            deathEventCheckPerformed = false
            deathEventObserved = false
        }
        if stopReturn != 0 {
            guard stopErrno == ESRCH, deathEventObserved else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                    "supervisor_stop",
                    preliminarySupervisorStopObservation: .init(
                        returnValue: stopReturn,
                        errorNumber: stopErrno,
                        deathEventCheckPerformed: deathEventCheckPerformed,
                        deathEventObserved: deathEventObserved
                    )
                )
            }
        }

        var previous: [PrimeValidationDriverV2GovernorSessionMember]?
        var stableCount = 0
        while scanCount < maximumScans {
            try deadline.requireTime("containment_stopped_fixed_point_deadline")
            let members = try scan(sessionIdentifier: supervisorPID)
            scanCount += 1
            for member in members {
                captured[member.generationKey] = member
                groups.insert(member.processGroupIdentifier)
            }
            for group in Set(members.map(\.processGroupIdentifier)) {
                errno = 0
                if Darwin.kill(-group, SIGSTOP) != 0, errno != ESRCH {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                        "session_group_stop_\(errno)"
                    )
                }
            }
            if members.allSatisfy(\.stoppedOrZombie), members == previous {
                stableCount += 1
            } else {
                stableCount = 0
            }
            if stableCount >= 1 { break }
            previous = members
            _ = Darwin.usleep(1_000)
        }
        guard stableCount >= 1 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "session_stopped_fixed_point"
            )
        }

        for group in groups.sorted() where group != supervisorPID {
            errno = 0
            if Darwin.kill(-group, SIGKILL) != 0, errno != ESRCH {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                    "session_non_supervisor_kill"
                )
            }
        }
        errno = 0
        if Darwin.kill(-supervisorPID, SIGKILL) != 0,
           !(errno == ESRCH && deathWatcher.hasObservedExit())
        {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "session_supervisor_kill"
            )
        }
        let wait = try exactWait(
            supervisorPID: supervisorPID,
            deathWatcher: deathWatcher,
            deadline: deadline
        )
        onExactReap()
        var emptyCount = 0
        while scanCount < maximumScans, emptyCount < 2 {
            try deadline.requireTime("containment_empty_scan_deadline")
            let members = try scan(sessionIdentifier: supervisorPID)
            scanCount += 1
            if members.isEmpty { emptyCount += 1 } else {
                emptyCount = 0
                for member in members {
                    captured[member.generationKey] = member
                    groups.insert(member.processGroupIdentifier)
                    errno = 0
                    if Darwin.kill(-member.processGroupIdentifier, SIGKILL)
                        != 0, errno != ESRCH
                    {
                        throw governorRejected(
                            PrimeValidationDriverV2ShotGovernorStatus
                                .containmentUncertain,
                            "session_late_group_kill"
                        )
                    }
                }
            }
            _ = Darwin.usleep(1_000)
        }
        guard emptyCount == 2 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "session_not_empty"
            )
        }
        for member in captured.values {
            if let current = try bsdInfoIfPresent(
                pid: member.processIdentifier
            ),
               current.pbi_start_tvsec == member.startSeconds,
               current.pbi_start_tvusec == member.startMicroseconds
            {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                    "captured_generation_present"
                )
            }
        }
        for group in groups {
            errno = 0
            guard Darwin.kill(-group, 0) == -1, errno == ESRCH else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                    "captured_group_present"
                )
            }
        }
        return (
            wait,
            .init(
                supervisorSessionIdentifier: supervisorPID,
                capturedMembers: captured.values.sorted {
                    $0.processIdentifier < $1.processIdentifier
                },
                capturedProcessGroups: groups.sorted(),
                completeScanCount: scanCount,
                finalEmptyScanCount: emptyCount,
                capturedGenerationsAbsent: true,
                capturedGroupsAbsent: true,
                sessionEmpty: true,
                ordinaryExitPath: false
            )
        )
    }

    static func reapNormallyAfterExit(
        supervisorPID: pid_t,
        deathWatcher: PrimeValidationDriverV2GovernorDeathWatcher,
        deadline: PrimeValidationDriverV2GovernorDeadline,
        onExactReap: () -> Void = {}
    ) throws -> (
        wait: PrimeValidationDriverV2GovernorWaitObservation,
        conservation: PrimeValidationDriverV2GovernorConservation
    ) {
        guard deathWatcher.hasObservedExit() else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "normal_reap_without_death"
            )
        }
        let members = try scan(sessionIdentifier: supervisorPID)
        let unexpected = members.filter {
            $0.processIdentifier != supervisorPID
        }
        guard unexpected.isEmpty else {
            return try contain(
                supervisorPID: supervisorPID,
                deathWatcher: deathWatcher,
                deadline: deadline,
                onExactReap: onExactReap
            )
        }
        let captured = members
        let wait = try exactWait(
            supervisorPID: supervisorPID,
            deathWatcher: deathWatcher,
            deadline: deadline
        )
        onExactReap()
        let first = try scan(sessionIdentifier: supervisorPID)
        let second = try scan(sessionIdentifier: supervisorPID)
        guard first.isEmpty, second.isEmpty else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "normal_session_not_empty"
            )
        }
        errno = 0
        guard Darwin.kill(-supervisorPID, 0) == -1, errno == ESRCH else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "normal_supervisor_group_present"
            )
        }
        return (
            wait,
            .init(
                supervisorSessionIdentifier: supervisorPID,
                capturedMembers: captured,
                capturedProcessGroups: [supervisorPID],
                completeScanCount: 3,
                finalEmptyScanCount: 2,
                capturedGenerationsAbsent: true,
                capturedGroupsAbsent: true,
                sessionEmpty: true,
                ordinaryExitPath: true
            )
        )
    }

    /// Completes SID/group conservation after the dedicated supervisor has
    /// already been reaped. This transition deliberately has no waitpid path:
    /// it stops a fixed point, kills every captured group, proves two empty
    /// SID scans, and rejects anything other than ESRCH for every captured
    /// generation and process group.
    static func containSessionAfterSupervisorReaped(
        supervisorPID: pid_t,
        deadline: PrimeValidationDriverV2GovernorDeadline
    ) throws -> PrimeValidationDriverV2GovernorConservation {
        var scanCount = 0
        var captured = [String: PrimeValidationDriverV2GovernorSessionMember]()
        var groups = Set<Int32>([supervisorPID])
        var previous: [PrimeValidationDriverV2GovernorSessionMember]?
        var stableCount = 0

        while scanCount < maximumScans {
            try deadline.requireTime(
                "post_reap_containment_stopped_fixed_point_deadline"
            )
            let members = try scan(sessionIdentifier: supervisorPID)
            scanCount += 1
            for member in members {
                captured[member.generationKey] = member
                groups.insert(member.processGroupIdentifier)
            }
            for group in Set(members.map(\.processGroupIdentifier))
                .union([supervisorPID])
            {
                errno = 0
                if Darwin.kill(-group, SIGSTOP) != 0, errno != ESRCH {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus
                            .containmentUncertain,
                        "post_reap_session_group_stop_\(errno)"
                    )
                }
            }
            if members.allSatisfy(\.stoppedOrZombie), members == previous {
                stableCount += 1
            } else {
                stableCount = 0
            }
            if stableCount >= 1 { break }
            previous = members
            _ = Darwin.usleep(1_000)
        }
        guard stableCount >= 1 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "post_reap_session_stopped_fixed_point"
            )
        }

        for group in groups.sorted() {
            errno = 0
            if Darwin.kill(-group, SIGKILL) != 0, errno != ESRCH {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "post_reap_session_group_kill_\(errno)"
                )
            }
        }

        var emptyCount = 0
        while scanCount < maximumScans, emptyCount < 2 {
            try deadline.requireTime(
                "post_reap_containment_empty_scan_deadline"
            )
            let members = try scan(sessionIdentifier: supervisorPID)
            scanCount += 1
            if members.isEmpty {
                emptyCount += 1
            } else {
                emptyCount = 0
                for member in members {
                    captured[member.generationKey] = member
                    groups.insert(member.processGroupIdentifier)
                    errno = 0
                    if Darwin.kill(-member.processGroupIdentifier, SIGKILL)
                        != 0, errno != ESRCH
                    {
                        throw governorRejected(
                            PrimeValidationDriverV2ShotGovernorStatus
                                .containmentUncertain,
                            "post_reap_session_late_group_kill_\(errno)"
                        )
                    }
                }
            }
            _ = Darwin.usleep(1_000)
        }
        guard emptyCount == 2 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "post_reap_session_not_empty"
            )
        }
        for member in captured.values {
            if let current = try bsdInfoIfPresent(
                pid: member.processIdentifier
            ),
               current.pbi_start_tvsec == member.startSeconds,
               current.pbi_start_tvusec == member.startMicroseconds
            {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "post_reap_captured_generation_present"
                )
            }
        }
        for group in groups {
            errno = 0
            guard Darwin.kill(-group, 0) == -1, errno == ESRCH else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "post_reap_captured_group_present"
                )
            }
        }
        return .init(
            supervisorSessionIdentifier: supervisorPID,
            capturedMembers: captured.values.sorted {
                $0.processIdentifier < $1.processIdentifier
            },
            capturedProcessGroups: groups.sorted(),
            completeScanCount: scanCount,
            finalEmptyScanCount: emptyCount,
            capturedGenerationsAbsent: true,
            capturedGroupsAbsent: true,
            sessionEmpty: true,
            ordinaryExitPath: false
        )
    }

    private static func exactWait(
        supervisorPID: pid_t,
        deathWatcher: PrimeValidationDriverV2GovernorDeathWatcher,
        deadline: PrimeValidationDriverV2GovernorDeadline
    ) throws -> PrimeValidationDriverV2GovernorWaitObservation {
        guard deathWatcher.hasObservedExit()
                || deathWatcher.waitForContainmentDeath(deadline: deadline)
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "exact_supervisor_death_deadline"
            )
        }
        while true {
            try deadline.requireTime("exact_supervisor_wait_deadline")
            var raw: Int32 = 0
            errno = 0
            let returned = Darwin.waitpid(supervisorPID, &raw, 0)
            if returned == supervisorPID {
                try deadline.requireTime("exact_supervisor_wait_return_deadline")
                return .init(
                    pid: supervisorPID,
                    rawStatus: raw,
                    waitOptions: 0,
                    returnedAt: DispatchTime.now().uptimeNanoseconds
                )
            }
            if returned < 0, errno == EINTR { continue }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "exact_supervisor_wait_\(errno)"
            )
        }
    }

    private static func bsdInfoIfPresent(pid: pid_t) throws -> proc_bsdinfo? {
        var value = proc_bsdinfo()
        let size = MemoryLayout<proc_bsdinfo>.size
        errno = 0
        let returned = withUnsafeMutablePointer(to: &value) {
            proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, $0, Int32(size))
        }
        if returned == Int32(size) { return value }
        if returned <= 0, errno == ESRCH { return nil }
        throw governorRejected(
            PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
            "captured_generation_query_\(errno)"
        )
    }

    private static func mappedIdentityIfAvailable(
        pid: pid_t
    ) -> (deviceID: UInt64, inode: UInt64, path: String)? {
        var address: UInt64 = 0
        for _ in 0 ..< 256 {
            var raw = proc_regionwithpathinfo()
            let returned = withUnsafeMutablePointer(to: &raw) {
                proc_pidinfo(
                    pid,
                    PROC_PIDREGIONPATHINFO,
                    address,
                    $0,
                    Int32(MemoryLayout<proc_regionwithpathinfo>.size)
                )
            }
            guard returned == Int32(MemoryLayout<proc_regionwithpathinfo>.size)
            else { return nil }
            let region = raw.prp_prinfo
            if region.pri_offset == 0,
               region.pri_protection & UInt32(VM_PROT_EXECUTE) != 0
            {
                let vnode = raw.prp_vip.vip_vi.vi_stat
                var storage = raw.prp_vip.vip_path
                let path = withUnsafeBytes(of: &storage) {
                    String(
                        bytes: $0.prefix { $0 != 0 },
                        encoding: .utf8
                    )
                } ?? ""
                return (
                    UInt64(bitPattern: Int64(vnode.vst_dev)),
                    vnode.vst_ino,
                    path
                )
            }
            let end = region.pri_address.addingReportingOverflow(
                region.pri_size
            )
            guard region.pri_size > 0, !end.overflow else { return nil }
            address = end.partialValue
        }
        return nil
    }
}

private struct PrimeValidationDriverV2GovernorSpawnedSupervisor {
    let processIdentifier: pid_t
    let appliedFlags: UInt16
    let spawnedAtUptimeNanoseconds: UInt64
    let cwdProof: PrimeValidationDriverV2GovernorCWDProof
    let mappedImageProof: PrimeValidationDriverV2GovernorMappedImageProof
    let deathWatcher: PrimeValidationDriverV2GovernorDeathWatcher
    let stdoutDrain: PrimeValidationDriverV2GovernorDrain
    let stderrDrain: PrimeValidationDriverV2GovernorDrain

    func finishBothDrains(
        deadline: PrimeValidationDriverV2GovernorDeadline
    ) throws -> (
        stdout: PrimeValidationDriverV2GovernorCaptureObservation,
        stderr: PrimeValidationDriverV2GovernorCaptureObservation
    ) {
        let stdout = Result { try stdoutDrain.finish(deadline: deadline) }
        let stderr = Result { try stderrDrain.finish(deadline: deadline) }
        switch (stdout, stderr) {
        case let (.success(output), .success(error)):
            return (output, error)
        case let (.failure(failure), _):
            throw failure
        case let (_, .failure(failure)):
            throw failure
        }
    }
}

/// Ensures that every throw after `posix_spawn` is a contain-before-return
/// transition. Failure to certify containment is the fixed exit-70 fail-stop.
private final class PrimeValidationDriverV2GovernorSpawnContainmentGuard {
    private enum State {
        case armed
        case exactReapCompleted
        case conservationCompleted
        case drainsCompleted
    }

    private let spawned: PrimeValidationDriverV2GovernorSpawnedSupervisor
    private let deadline: PrimeValidationDriverV2GovernorDeadline
    private var state: State = .armed

    init(
        spawned: PrimeValidationDriverV2GovernorSpawnedSupervisor,
        deadline: PrimeValidationDriverV2GovernorDeadline
    ) {
        self.spawned = spawned
        self.deadline = deadline
    }

    func acceptExactReap() { state = .exactReapCompleted }

    func acceptConservation() { state = .conservationCompleted }

    func acceptFinishedDrains() { state = .drainsCompleted }

    deinit {
        guard case .drainsCompleted = state else {
            do {
                if case .armed = state {
                    do {
                        _ = try PrimeValidationDriverV2GovernorSessionCensus
                            .contain(
                                supervisorPID: spawned.processIdentifier,
                                deathWatcher: spawned.deathWatcher,
                                deadline: deadline,
                                onExactReap: acceptExactReap
                            )
                        state = .conservationCompleted
                    } catch {
                        guard case .exactReapCompleted = state else {
                            throw error
                        }
                        _ = try PrimeValidationDriverV2GovernorSessionCensus
                            .containSessionAfterSupervisorReaped(
                                supervisorPID: spawned.processIdentifier,
                                deadline: deadline
                            )
                        state = .conservationCompleted
                    }
                } else if case .exactReapCompleted = state {
                    _ = try PrimeValidationDriverV2GovernorSessionCensus
                        .containSessionAfterSupervisorReaped(
                            supervisorPID: spawned.processIdentifier,
                            deadline: deadline
                        )
                    state = .conservationCompleted
                }
                _ = try spawned.finishBothDrains(deadline: deadline)
            } catch {
                Darwin._exit(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain
                )
            }
            return
        }
    }
}

private func primeDriverV2GovernorAddWorkingDirectoryAction(
    _ actions: UnsafeMutablePointer<posix_spawn_file_actions_t?>,
    descriptor: Int32
) -> Int32 {
    if #available(macOS 26.0, *) {
        return posix_spawn_file_actions_addfchdir(
            actions,
            descriptor
        )
    } else {
        return posix_spawn_file_actions_addfchdir_np(
            actions,
            descriptor
        )
    }
}

private enum PrimeValidationDriverV2GovernorSpawner {
    static let supervisorFlags: UInt16 = 0x448c
    static let supervisorArgumentZero =
        "prime-validation-driver-v2-supervisor"

    static func spawnSupervisor(
        executable: PrimeValidationDriverV2GovernorHeldExecutable,
        workingDirectory: PrimeValidationDriverV2GovernorHeldDirectory,
        requestInputDescriptor: Int32,
        stdoutCapture: PrimeValidationDriverV2GovernorCapture,
        stderrCapture: PrimeValidationDriverV2GovernorCapture,
        deadline: PrimeValidationDriverV2GovernorDeadline,
        preSpawnContinuityCheckpoint: () throws -> Void
    ) throws -> PrimeValidationDriverV2GovernorSpawnedSupervisor {
        var stdoutPipe = [Int32](repeating: -1, count: 2)
        var stderrPipe = [Int32](repeating: -1, count: 2)
        guard stdoutPipe.withUnsafeMutableBufferPointer({
            Darwin.pipe($0.baseAddress)
        }) == 0,
        stderrPipe.withUnsafeMutableBufferPointer({
            Darwin.pipe($0.baseAddress)
        }) == 0 else {
            for descriptor in stdoutPipe + stderrPipe where descriptor >= 0 {
                _ = Darwin.close(descriptor)
            }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "supervisor_pipe"
            )
        }
        var parentDescriptors = stdoutPipe + stderrPipe
        defer {
            for descriptor in parentDescriptors where descriptor >= 0 {
                _ = Darwin.close(descriptor)
            }
        }
        for descriptor in [stdoutPipe[0], stderrPipe[0]] {
            guard fcntl(descriptor, F_SETFD, FD_CLOEXEC) == 0 else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                    "supervisor_pipe_cloexec"
                )
            }
        }

        var actions: posix_spawn_file_actions_t?
        guard posix_spawn_file_actions_init(&actions) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "supervisor_actions_init"
            )
        }
        defer { _ = posix_spawn_file_actions_destroy(&actions) }
        let actionResults = [
            posix_spawn_file_actions_adddup2(
                &actions,
                requestInputDescriptor,
                STDIN_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions,
                requestInputDescriptor
            ),
            posix_spawn_file_actions_adddup2(
                &actions,
                stdoutPipe[1],
                STDOUT_FILENO
            ),
            posix_spawn_file_actions_addclose(&actions, stdoutPipe[0]),
            posix_spawn_file_actions_addclose(&actions, stdoutPipe[1]),
            posix_spawn_file_actions_adddup2(
                &actions,
                stderrPipe[1],
                STDERR_FILENO
            ),
            posix_spawn_file_actions_addclose(&actions, stderrPipe[0]),
            posix_spawn_file_actions_addclose(&actions, stderrPipe[1]),
            posix_spawn_file_actions_addinherit_np(
                &actions,
                workingDirectory.descriptor
            ),
            primeDriverV2GovernorAddWorkingDirectoryAction(
                &actions,
                descriptor: workingDirectory.descriptor
            ),
            posix_spawn_file_actions_addclose(
                &actions,
                workingDirectory.descriptor
            ),
        ]
        guard actionResults.allSatisfy({ $0 == 0 }) else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "supervisor_actions"
            )
        }

        var attributes: posix_spawnattr_t?
        guard posix_spawnattr_init(&attributes) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "supervisor_attributes_init"
            )
        }
        defer { _ = posix_spawnattr_destroy(&attributes) }
        var defaults = sigset_t()
        var mask = sigset_t()
        guard sigemptyset(&defaults) == 0,
              sigemptyset(&mask) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "supervisor_signal_sets"
            )
        }
        for signal in 1 ..< NSIG
        where signal != SIGKILL && signal != SIGSTOP {
            guard sigaddset(&defaults, signal) == 0 else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                    "supervisor_signal_defaults"
                )
            }
        }
        guard posix_spawnattr_setsigdefault(&attributes, &defaults) == 0,
              posix_spawnattr_setsigmask(&attributes, &mask) == 0,
              posix_spawnattr_setflags(
                  &attributes,
                  Int16(bitPattern: supervisorFlags)
              ) == 0
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "supervisor_spawn_policy"
            )
        }
        guard let argumentZero = strdup(supervisorArgumentZero) else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "supervisor_argument_zero"
            )
        }
        defer { free(argumentZero) }
        var arguments: [UnsafeMutablePointer<CChar>?] = [argumentZero, nil]
        var environment: [UnsafeMutablePointer<CChar>?] = [nil]
        var pid: pid_t = 0
        try deadline.requireTime("supervisor_spawn_deadline")
        try preSpawnContinuityCheckpoint()
        let spawnResult = arguments.withUnsafeMutableBufferPointer { argv in
            environment.withUnsafeMutableBufferPointer { envp in
                posix_spawn(
                    &pid,
                    executable.absolutePath,
                    &actions,
                    &attributes,
                    argv.baseAddress!,
                    envp.baseAddress!
                )
            }
        }
        let spawnedAt = DispatchTime.now().uptimeNanoseconds
        guard spawnResult == 0, pid > 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "supervisor_spawn_\(spawnResult)"
            )
        }
        _ = Darwin.close(stdoutPipe[1])
        parentDescriptors[1] = -1
        _ = Darwin.close(stderrPipe[1])
        parentDescriptors[3] = -1

        let deathWatcher = PrimeValidationDriverV2GovernorDeathWatcher(pid: pid)
        let stdoutDrain = PrimeValidationDriverV2GovernorDrain(
            readDescriptor: stdoutPipe[0],
            capture: stdoutCapture,
            label: "prime.validation.driver-v2.governor.stdout"
        )
        parentDescriptors[0] = -1
        let stderrDrain = PrimeValidationDriverV2GovernorDrain(
            readDescriptor: stderrPipe[0],
            capture: stderrCapture,
            label: "prime.validation.driver-v2.governor.stderr"
        )
        parentDescriptors[2] = -1
        stdoutDrain.start()
        stderrDrain.start()
        do {
            try deadline.requireTime("supervisor_spawn_return_deadline")
            guard Darwin.getpgid(pid) == pid,
                  Darwin.getsid(pid) == pid
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                    "supervisor_session_join"
                )
            }
            let cwd = try PrimeValidationDriverV2GovernorProcessProof.cwd(
                pid: pid,
                directory: workingDirectory
            )
            let mapped = try PrimeValidationDriverV2GovernorProcessProof
                .mappedImage(pid: pid, executable: executable)
            return .init(
                processIdentifier: pid,
                appliedFlags: supervisorFlags,
                spawnedAtUptimeNanoseconds: spawnedAt,
                cwdProof: cwd,
                mappedImageProof: mapped,
                deathWatcher: deathWatcher,
                stdoutDrain: stdoutDrain,
                stderrDrain: stderrDrain
            )
        } catch {
            let proofFailure = error
            let containment = Result {
                try PrimeValidationDriverV2GovernorSessionCensus.contain(
                    supervisorPID: pid,
                    deathWatcher: deathWatcher,
                    deadline: deadline
                )
            }
            let stdoutFinished = Result {
                try stdoutDrain.finish(deadline: deadline)
            }
            let stderrFinished = Result {
                try stderrDrain.finish(deadline: deadline)
            }
            guard case .success = containment,
                  case .success = stdoutFinished,
                  case .success = stderrFinished
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                    "pre_resume_containment_or_drains"
                )
            }
            throw proofFailure
        }
    }
}

private struct PrimeValidationDriverV2GovernorStartRecordV1: Encodable {
    let schema = "prime_driver_v2_gate_e_outer_start_v1"
    let capsuleSHA256: String
    let capsuleByteCount: UInt64
    let capsuleVnode: PrimeValidationDriverV2GovernorVnodeRecord
    let requestSHA256: String
    let requestByteCount: UInt64
    let requestVnode: PrimeValidationDriverV2GovernorVnodeRecord
    let governorImageVnode: PrimeValidationDriverV2GovernorVnodeRecord
    let supervisorImageVnode: PrimeValidationDriverV2GovernorVnodeRecord
    let gitImageVnode: PrimeValidationDriverV2GovernorVnodeRecord
    let swiftImageVnode: PrimeValidationDriverV2GovernorVnodeRecord
    let productionBaseDeviceID: UInt64
    let productionBaseInode: UInt64
    let workingDirectoryDeviceID: UInt64
    let workingDirectoryInode: UInt64
    let deadlineStartedAtUptimeNanoseconds: UInt64
    let deadlineExpiresAtUptimeNanoseconds: UInt64
    let supervisorProcessIdentifier: Int32
    let supervisorSessionIdentifier: Int32
    let supervisorProcessGroupIdentifier: Int32
    let appliedSpawnFlags: UInt16
    let spawnedAtUptimeNanoseconds: UInt64
    let cwdProof: PrimeValidationDriverV2GovernorCWDProof
    let mappedImageProof: PrimeValidationDriverV2GovernorMappedImageProof
    let namedVnodeJoined: Bool
    let drainsStartedBeforeResume: Bool

    private enum CodingKeys: String, CodingKey {
        case schema
        case capsuleSHA256 = "capsule_sha256"
        case capsuleByteCount = "capsule_byte_count"
        case capsuleVnode = "capsule_vnode"
        case requestSHA256 = "request_sha256"
        case requestByteCount = "request_byte_count"
        case requestVnode = "request_vnode"
        case governorImageVnode = "governor_image_vnode"
        case supervisorImageVnode = "supervisor_image_vnode"
        case gitImageVnode = "git_image_vnode"
        case swiftImageVnode = "swift_image_vnode"
        case productionBaseDeviceID = "production_base_device_id"
        case productionBaseInode = "production_base_inode"
        case workingDirectoryDeviceID = "working_directory_device_id"
        case workingDirectoryInode = "working_directory_inode"
        case deadlineStartedAtUptimeNanoseconds =
            "deadline_started_at_uptime_nanoseconds"
        case deadlineExpiresAtUptimeNanoseconds =
            "deadline_expires_at_uptime_nanoseconds"
        case supervisorProcessIdentifier =
            "supervisor_process_identifier"
        case supervisorSessionIdentifier =
            "supervisor_session_identifier"
        case supervisorProcessGroupIdentifier =
            "supervisor_process_group_identifier"
        case appliedSpawnFlags = "applied_spawn_flags"
        case spawnedAtUptimeNanoseconds =
            "spawned_at_uptime_nanoseconds"
        case cwdProof = "cwd_proof"
        case mappedImageProof = "mapped_image_proof"
        case namedVnodeJoined = "named_vnode_joined"
        case drainsStartedBeforeResume = "drains_started_before_resume"
    }
}

private struct PrimeValidationDriverV2GovernorSuccessOutcome: Encodable {
    let authorityVector = "11110000"
    let innerJournal: [PrimeValidationDriverV2GovernorInnerLeaf]
    let innerJournalVnodes: [PrimeValidationDriverV2GovernorVnodeRecord]
    let durableReceiptIdentitySHA256: String
    let rawTerminalSHA256: String

    private enum CodingKeys: String, CodingKey {
        case authorityVector = "authority_vector"
        case innerJournal = "inner_journal"
        case innerJournalVnodes = "inner_journal_vnodes"
        case durableReceiptIdentitySHA256 =
            "durable_receipt_identity_sha256"
        case rawTerminalSHA256 = "raw_terminal_sha256"
    }
}

private struct PrimeValidationDriverV2GovernorNonzeroOutcome: Encodable {
    let authorityVector = "00000000"
    let innerJournalPrefix: [PrimeValidationDriverV2GovernorInnerLeaf]
    let rawTerminalSHA256: String?
    let exactSupervisorStatus: Int32

    private enum CodingKeys: String, CodingKey {
        case authorityVector = "authority_vector"
        case innerJournalPrefix = "inner_journal_prefix"
        case rawTerminalSHA256 = "raw_terminal_sha256"
        case exactSupervisorStatus = "exact_supervisor_status"
    }
}

private struct PrimeValidationDriverV2GovernorZeroRejectionOutcome: Encodable {
    let authorityVector = "00000000"
    let innerJournalPrefix: [PrimeValidationDriverV2GovernorInnerLeaf]
    let rawTerminalSHA256: String?
    let failedCoordinate: String

    private enum CodingKeys: String, CodingKey {
        case authorityVector = "authority_vector"
        case innerJournalPrefix = "inner_journal_prefix"
        case rawTerminalSHA256 = "raw_terminal_sha256"
        case failedCoordinate = "failed_coordinate"
    }
}

private enum PrimeValidationDriverV2GovernorTerminalOutcome: Encodable {
    case success(PrimeValidationDriverV2GovernorSuccessOutcome)
    case containedNonzero(PrimeValidationDriverV2GovernorNonzeroOutcome)
    case containedZeroSemanticRejection(
        PrimeValidationDriverV2GovernorZeroRejectionOutcome
    )

    private enum CodingKeys: String, CodingKey {
        case success
        case containedNonzero = "contained_nonzero"
        case containedZeroSemanticRejection =
            "contained_zero_semantic_rejection"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .success(value):
            try container.encode(value, forKey: .success)
        case let .containedNonzero(value):
            try container.encode(value, forKey: .containedNonzero)
        case let .containedZeroSemanticRejection(value):
            try container.encode(
                value,
                forKey: .containedZeroSemanticRejection
            )
        }
    }
}

private struct PrimeValidationDriverV2GovernorTerminalRecordV1: Encodable {
    let schema = "prime_driver_v2_gate_e_outer_terminal_v1"
    let startSHA256: String
    let supervisorWait: PrimeValidationDriverV2GovernorWaitObservation
    let standardOutput: PrimeValidationDriverV2GovernorCaptureObservation
    let standardError: PrimeValidationDriverV2GovernorCaptureObservation
    let conservation: PrimeValidationDriverV2GovernorConservation
    let exactSupervisorReapCount: Int
    let allRecordedChildGroupsEmpty: Bool
    let governorImageRejoined: Bool
    let supervisorImageRejoined: Bool
    let gitImageRejoined: Bool
    let swiftImageRejoined: Bool
    let rootsRejoined: Bool
    let outerContinuityRevalidated: Bool
    let outcome: PrimeValidationDriverV2GovernorTerminalOutcome

    private enum CodingKeys: String, CodingKey {
        case schema
        case startSHA256 = "start_sha256"
        case supervisorWait = "supervisor_wait"
        case standardOutput = "standard_output"
        case standardError = "standard_error"
        case conservation
        case exactSupervisorReapCount = "exact_supervisor_reap_count"
        case allRecordedChildGroupsEmpty =
            "all_recorded_child_groups_empty"
        case governorImageRejoined = "governor_image_rejoined"
        case supervisorImageRejoined = "supervisor_image_rejoined"
        case gitImageRejoined = "git_image_rejoined"
        case swiftImageRejoined = "swift_image_rejoined"
        case rootsRejoined = "roots_rejoined"
        case outerContinuityRevalidated =
            "outer_continuity_revalidated"
        case outcome
    }
}

private final class PrimeValidationDriverV2GovernorOneShot {
    enum State { case available, running, complete, poisoned }
    private let lock = NSLock()
    private var state: State = .available

    func consume(_ body: () throws -> Int32) -> Int32 {
        lock.lock()
        guard case .available = state else {
            state = .poisoned
            lock.unlock()
            return PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport
        }
        state = .running
        lock.unlock()
        do {
            let result = try body()
            lock.lock()
            if case .running = state, result == 0 {
                state = .complete
            } else {
                // A concurrent or sequential second consumer permanently
                // poisons; the winner may not overwrite that transition.
                state = .poisoned
            }
            lock.unlock()
            return result
        } catch let failure as PrimeValidationDriverV2ShotGovernorFailure {
            lock.lock()
            state = .poisoned
            lock.unlock()
            return failure.status
        } catch {
            lock.lock()
            state = .poisoned
            lock.unlock()
            return PrimeValidationDriverV2ShotGovernorStatus
                .containmentUncertain
        }
    }

    func snapshot() -> State {
        lock.lock()
        defer { lock.unlock() }
        return state
    }

    func poison() {
        lock.lock()
        state = .poisoned
        lock.unlock()
    }
}

package enum PrimeValidationDriverV2ShotGovernor {
    private static let oneShot = PrimeValidationDriverV2GovernorOneShot()
    private static let maximumCapsuleByteCount = 262_144
    private static let capsuleReadTimeoutNanoseconds: UInt64 =
        5_000_000_000
    private static let emptySHA256 =
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

    package static func runClosedFromStandardInput() -> Int32 {
        oneShot.consume {
            if let environment = primeDriverV2GovernorNSGetEnviron().pointee,
               environment.pointee != nil
            {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                    "capsule_environment"
                )
            }
            let bytes = try readCanonicalCapsuleFromStandardInput()
            let capsule = try decodeCanonicalCapsule(exactBytes: bytes)
            return try execute(capsule: capsule, capsuleBytes: bytes)
        }
    }

    fileprivate static func decodeCanonicalCapsule(
        exactBytes: Data
    ) throws -> PrimeValidationDriverV2ShotCapsuleV1 {
        do {
            let capsule = try PrimeCanonicalJSON.decode(
                PrimeValidationDriverV2ShotCapsuleV1.self,
                from: exactBytes,
                artifact: "driver_v2_gate_e_shot_capsule"
            )
            try capsule.validate(exactCanonicalBytes: exactBytes)
            return capsule
        } catch let failure as PrimeValidationDriverV2ShotGovernorFailure {
            throw failure
        } catch {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "capsule_decode"
            )
        }
    }

    private static func readCanonicalCapsuleFromStandardInput() throws -> Data {
        guard CommandLine.arguments.count == 1 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "capsule_argc"
            )
        }
        let started = DispatchTime.now().uptimeNanoseconds
        let value = started.addingReportingOverflow(
            capsuleReadTimeoutNanoseconds
        )
        guard !value.overflow else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "capsule_deadline"
            )
        }
        var result = Data()
        var buffer = [UInt8](repeating: 0, count: 16 * 1024)
        while true {
            let now = DispatchTime.now().uptimeNanoseconds
            guard now < value.partialValue else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                    "capsule_eof_deadline"
                )
            }
            let remaining = value.partialValue - now
            let milliseconds = Int32(
                min((remaining + 999_999) / 1_000_000, UInt64(Int32.max))
            )
            var input = pollfd(
                fd: STDIN_FILENO,
                events: Int16(POLLIN | POLLHUP),
                revents: 0
            )
            let ready = Darwin.poll(&input, 1, milliseconds)
            if ready < 0, errno == EINTR { continue }
            guard ready > 0,
                  input.revents & Int16(POLLERR | POLLNVAL) == 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                    "capsule_poll"
                )
            }
            let count = buffer.withUnsafeMutableBytes {
                Darwin.read(STDIN_FILENO, $0.baseAddress, $0.count)
            }
            if count < 0, errno == EINTR { continue }
            guard count >= 0 else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                    "capsule_read"
                )
            }
            if count == 0 {
                guard DispatchTime.now().uptimeNanoseconds
                        <= value.partialValue
                else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus
                            .capsuleTransport,
                        "capsule_eof_deadline"
                    )
                }
                break
            }
            guard result.count <= maximumCapsuleByteCount - count else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                    "capsule_size"
                )
            }
            result.append(contentsOf: buffer.prefix(count))
        }
        guard !result.isEmpty, result.last != 0x0a else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "capsule_frame"
            )
        }
        return result
    }

    private static func execute(
        capsule: PrimeValidationDriverV2ShotCapsuleV1,
        capsuleBytes: Data
    ) throws -> Int32 {
        _ = Darwin.umask(mode_t(0o077))
        for path in capsule.forbiddenAbsentAbsolutePaths {
            var status = stat()
            errno = 0
            guard lstat(path, &status) == -1, errno == ENOENT else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    "declared_absent_path"
                )
            }
        }

        let base = try PrimeValidationDriverV2GovernorHeldDirectory(
            binding: capsule.productionBase,
            requireEmpty: false,
            coordinate: "production_base"
        )
        guard try PrimeValidationDriverV2GovernorIO.inventory(
            directory: base.descriptor,
            coordinate: "production_base"
        ) == capsule.productionBaseEntryNamesBefore else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "production_base_inventory_before"
            )
        }
        let baseFilesystem = try PrimeValidationDriverV2GovernorIO
            .requireLocalAPFS(
                base.descriptor,
                coordinate: "production_base"
            )
        let workingDirectory = try PrimeValidationDriverV2GovernorHeldDirectory(
            binding: capsule.privateWorkingDirectory,
            requireEmpty: true,
            coordinate: "private_working_directory"
        )
        _ = try PrimeValidationDriverV2GovernorIO.requireLocalAPFS(
            workingDirectory.descriptor,
            sameAs: baseFilesystem,
            coordinate: "private_working_directory"
        )
        let primeRoot = try PrimeValidationDriverV2GovernorHeldDirectory(
            binding: capsule.intent.roots.repositoryRoot,
            requireEmpty: false,
            coordinate: "prime_root"
        )
        let companionRoot = try PrimeValidationDriverV2GovernorHeldDirectory(
            binding: capsule.intent.roots.companionRoot,
            requireEmpty: false,
            coordinate: "companion_root"
        )
        let workspaceRoot = try PrimeValidationDriverV2GovernorHeldDirectory(
            binding: capsule.intent.roots.workspaceRoot,
            requireEmpty: true,
            coordinate: "workspace_root"
        )
        let evidenceRoot = try PrimeValidationDriverV2GovernorHeldDirectory(
            binding: capsule.intent.roots.evidenceRoot,
            requireEmpty: true,
            coordinate: "evidence_root"
        )
        let leaseRoot = try PrimeValidationDriverV2GovernorHeldDirectory(
            absolutePath: capsule.leaseDirectoryAbsolutePath,
            requirePrivate: true,
            requireEmpty: true,
            coordinate: "lease_root"
        )
        let primeSourceSnapshot = try PrimeSwiftSourceProvenance.capture(
            at: URL(
                fileURLWithPath: primeRoot.absolutePath,
                isDirectory: true
            )
        )
        let primeSourceSnapshotBytes = try PrimeCanonicalJSON.encode(
            primeSourceSnapshot
        )
        guard UInt64(primeSourceSnapshotBytes.count)
                == capsule.intent.sourceSnapshot.byteCount,
              PrimeSHA256.hexDigest(of: primeSourceSnapshotBytes)
                == capsule.intent.sourceSnapshot.sha256,
              primeSourceSnapshot.sourceIdentitySHA256
                == capsule.sourceIdentitySHA256
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "outer_source_snapshot_join"
            )
        }
        let outerContinuity = try
            PrimeValidationDriverV2OuterSourceContinuity.capture(
                primeRootDescriptor: primeRoot.descriptor,
                primeSourceSnapshot: primeSourceSnapshot,
                companionRootDescriptor: companionRoot.descriptor
            )
        guard outerContinuity.observation.primeSourceIdentitySHA256
                == capsule.sourceIdentitySHA256,
              outerContinuity.observation.primeAdmittedFileCount
                == capsule.primeAdmittedFileCount,
              outerContinuity.observation.primeSourceIdentityRecordCount
                == capsule.sourceIdentityRecordCount,
              outerContinuity.observation.primeAuthorityDirectoryCount
                == capsule.primeAuthorityDirectoryCount,
              outerContinuity.observation.combinedWatcherDescriptorCount
                == capsule.combinedWatcherDescriptorCount
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "outer_source_continuity_join"
            )
        }
        try outerContinuity.revalidateContinuity()
        let innerJournal = try PrimeValidationDriverV2GovernorInnerJournal(
            workspaceAbsolutePath:
                capsule.intent.roots.workspaceRoot.absolutePath
        )

        let governorImage = try PrimeValidationDriverV2GovernorHeldExecutable
            .currentExecutable(binding: capsule.governorExecutable)
        let supervisorImage = try PrimeValidationDriverV2GovernorHeldExecutable(
            binding: capsule.supervisorExecutable,
            requiredLeaf: "PrimeValidationWorkflowDriverV2Supervisor",
            coordinate: "supervisor_image"
        )
        let gitImage = try PrimeValidationDriverV2GovernorHeldExecutable(
            binding: capsule.gitExecutable,
            requiredLeaf: "git",
            coordinate: "git_image"
        )
        let swiftImage = try PrimeValidationDriverV2GovernorHeldExecutable(
            binding: capsule.swiftExecutable,
            requiredLeaf: "swift-frontend",
            coordinate: "swift_frontend_image"
        )

        let request = PrimeValidationDriverV2SupervisorLaunchRequestV1(
            intent: capsule.intent,
            leaseDirectoryAbsolutePath: capsule.leaseDirectoryAbsolutePath
        )
        try request.validate()
        let requestBytes = try PrimeCanonicalJSON.encode(request)
        guard requestBytes.count <= 262_144,
              requestBytes.last != 0x0a
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "supervisor_request_frame"
            )
        }

        let journal = try PrimeValidationDriverV2GovernorJournal(
            base: base,
            filesystem: baseFilesystem
        )
        let capsuleLeaf = try journal.publishExact(
            capsuleBytes,
            expectedLeaf: PrimeValidationDriverV2GovernorJournal.capsuleLeaf
        )
        let requestLeaf = try journal.publishExact(
            requestBytes,
            expectedLeaf: PrimeValidationDriverV2GovernorJournal.requestLeaf
        )
        var requestInput = try journal.independentRequestInputDescriptor()
        defer {
            if requestInput >= 3 { _ = Darwin.close(requestInput) }
        }
        let stdoutCapture = try PrimeValidationDriverV2GovernorCapture(
            base: base,
            leaf: "outer-supervisor-stdout.bin"
        )
        let stderrCapture = try PrimeValidationDriverV2GovernorCapture(
            base: base,
            leaf: "outer-supervisor-stderr.bin"
        )
        let deadline = try PrimeValidationDriverV2GovernorDeadline()
        let spawned = try PrimeValidationDriverV2GovernorSpawner
            .spawnSupervisor(
                executable: supervisorImage,
                workingDirectory: workingDirectory,
                requestInputDescriptor: requestInput,
                stdoutCapture: stdoutCapture,
                stderrCapture: stderrCapture,
                deadline: deadline,
                preSpawnContinuityCheckpoint: {
                    try outerContinuity.revalidateContinuity()
                }
            )
        let containmentGuard =
            PrimeValidationDriverV2GovernorSpawnContainmentGuard(
                spawned: spawned,
                deadline: deadline
            )
        // The finite request file is independently held by leaf 1; the
        // descriptor sharing the child's offset closes in the parent now.
        _ = Darwin.close(requestInput)
        requestInput = -1

        let startLeaf = try journal.publishCanonical(
            PrimeValidationDriverV2GovernorStartRecordV1(
                capsuleSHA256: capsuleLeaf.sha256,
                capsuleByteCount: capsuleLeaf.byteCount,
                capsuleVnode: capsuleLeaf.vnode,
                requestSHA256: requestLeaf.sha256,
                requestByteCount: requestLeaf.byteCount,
                requestVnode: requestLeaf.vnode,
                governorImageVnode: .init(governorImage.identity),
                supervisorImageVnode: .init(supervisorImage.identity),
                gitImageVnode: .init(gitImage.identity),
                swiftImageVnode: .init(swiftImage.identity),
                productionBaseDeviceID: base.deviceID,
                productionBaseInode: base.inode,
                workingDirectoryDeviceID: workingDirectory.deviceID,
                workingDirectoryInode: workingDirectory.inode,
                deadlineStartedAtUptimeNanoseconds: deadline.startedAt,
                deadlineExpiresAtUptimeNanoseconds: deadline.expiresAt,
                supervisorProcessIdentifier: spawned.processIdentifier,
                supervisorSessionIdentifier: spawned.processIdentifier,
                supervisorProcessGroupIdentifier: spawned.processIdentifier,
                appliedSpawnFlags: spawned.appliedFlags,
                spawnedAtUptimeNanoseconds:
                    spawned.spawnedAtUptimeNanoseconds,
                cwdProof: spawned.cwdProof,
                mappedImageProof: spawned.mappedImageProof,
                namedVnodeJoined: true,
                drainsStartedBeforeResume: true
            ),
            expectedLeaf: PrimeValidationDriverV2GovernorJournal.startLeaf
        )
        try journal.revalidate()
        try governorImage.revalidate(coordinate: "governor_image")
        try supervisorImage.revalidate(coordinate: "supervisor_image")
        try gitImage.revalidate(coordinate: "git_image")
        try swiftImage.revalidate(coordinate: "swift_image")
        try outerContinuity.revalidateContinuity()
        try workingDirectory.requireEmpty(
            coordinate: "private_working_directory_pre_resume"
        )
        try outerContinuity.revalidateContinuity()
        let startPublishedAt = DispatchTime.now().uptimeNanoseconds
        try deadline.requireTime("supervisor_resume_deadline")
        guard Darwin.kill(spawned.processIdentifier, SIGCONT) == 0,
              DispatchTime.now().uptimeNanoseconds >= startPublishedAt
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "supervisor_resume"
            )
        }

        let processResult: (
            wait: PrimeValidationDriverV2GovernorWaitObservation,
            conservation: PrimeValidationDriverV2GovernorConservation
        )
        if spawned.deathWatcher.wait(deadline: deadline) {
            processResult = try PrimeValidationDriverV2GovernorSessionCensus
                .reapNormallyAfterExit(
                    supervisorPID: spawned.processIdentifier,
                    deathWatcher: spawned.deathWatcher,
                    deadline: deadline,
                    onExactReap: containmentGuard.acceptExactReap
                )
        } else {
            processResult = try PrimeValidationDriverV2GovernorSessionCensus
                .contain(
                    supervisorPID: spawned.processIdentifier,
                    deathWatcher: spawned.deathWatcher,
                    deadline: deadline,
                    onExactReap: containmentGuard.acceptExactReap
                )
        }
        containmentGuard.acceptConservation()
        let drains = try spawned.finishBothDrains(deadline: deadline)
        let stdout = drains.stdout
        let stderr = drains.stderr
        containmentGuard.acceptFinishedDrains()
        try outerContinuity.revalidateContinuity()
        let inner = try innerJournal.snapshot()

        var semanticFailure: String?
        var governorImageRejoined = false
        var supervisorImageRejoined = false
        var gitImageRejoined = false
        var swiftImageRejoined = false
        var rootsRejoined = false
        var outerContinuityRejoined = false
        var innerReceiptValidated = false
        var durableReceiptIdentitySHA256: String?
        var durableReceiptJournalVnodes:
            [PrimeValidationDriverV2GovernorVnodeRecord]?
        do {
            if processResult.wait.exitedNormally,
               processResult.wait.exitStatus == 0,
               inner.complete
            {
                let durableReceipt = try
                    PrimeValidationDriverV2FixedProbeDurableJournalValidatorV2
                    .validate(
                        orderedLeaves: inner.durableFrames,
                        expectation: .init(
                            intent: capsule.intent,
                            repositoryCommit: capsule.sourceCommit,
                            sourceIdentitySHA256:
                                capsule.sourceIdentitySHA256,
                            journalRoot: inner.journalRootBinding,
                            leaseRoot: leaseRoot.binding,
                            gitExecutable: capsule.gitExecutable,
                            swiftFrontendExecutable:
                                capsule.swiftExecutable,
                            supervisorExecutableVnode: .init(
                                deviceID: supervisorImage.identity.deviceID,
                                inode: supervisorImage.identity.inode
                            ),
                            gitExecutableVnode: .init(
                                deviceID: gitImage.identity.deviceID,
                                inode: gitImage.identity.inode
                            ),
                            swiftFrontendExecutableVnode: .init(
                                deviceID: swiftImage.identity.deviceID,
                                inode: swiftImage.identity.inode
                            ),
                            supervisorProcessIdentifier:
                                spawned.processIdentifier,
                            outerDeadlineStartedAtUptimeNanoseconds:
                                deadline.startedAt,
                            outerDeadlineExpiresAtUptimeNanoseconds:
                                deadline.expiresAt
                        ),
                        supervisorExit: .init(
                            requestedProcessIdentifier:
                                processResult.wait
                                .requestedProcessIdentifier,
                            returnedProcessIdentifier:
                                processResult.wait
                                .returnedProcessIdentifier,
                            waitOptions: processResult.wait.waitOptions,
                            rawWaitStatus:
                                processResult.wait.rawWaitStatus,
                            returnedAtUptimeNanoseconds:
                                processResult.wait
                                .returnedAtUptimeNanoseconds,
                            exitedNormally:
                                processResult.wait.exitedNormally,
                            exitStatus: processResult.wait.exitStatus,
                            terminationSignal:
                                processResult.wait.terminationSignal,
                            coreDumped: processResult.wait.coreDumped
                        )
                    )
                guard durableReceipt.supervisorProcessIdentifier
                        == spawned.processIdentifier,
                      durableReceipt.orderedLeafSHA256Values
                        == inner.immutablePrefix.map(\.sha256),
                      durableReceipt.orderedLeafVnodes
                        == inner.durableFrames.map(\.vnode),
                      Set(durableReceipt
                        .orderedChildProcessGroupIdentifiers)
                        == inner.recordedChildProcessGroups,
                      durableReceipt.rawTerminalSHA256
                        == inner.rawTerminalSHA256
                else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus
                            .postReapRejection,
                        "inner_durable_receipt_join"
                    )
                }
                durableReceiptIdentitySHA256 =
                    durableReceipt.identitySHA256
                durableReceiptJournalVnodes = inner.durableVnodes
                innerReceiptValidated = true
            }
            try journal.revalidate()
            try inner.revalidate()
            try outerContinuity.revalidateContinuity()
            outerContinuityRejoined = true
            try governorImage.revalidate(coordinate: "governor_image_after")
            governorImageRejoined = true
            try supervisorImage.revalidate(
                coordinate: "supervisor_image_after"
            )
            supervisorImageRejoined = true
            try gitImage.revalidate(coordinate: "git_image_after")
            gitImageRejoined = true
            try swiftImage.revalidate(coordinate: "swift_image_after")
            swiftImageRejoined = true
            try primeRoot.revalidate(coordinate: "prime_root_after")
            try companionRoot.revalidate(coordinate: "companion_root_after")
            try workspaceRoot.requireEmpty(coordinate: "workspace_root_after")
            try evidenceRoot.requireEmpty(coordinate: "evidence_root_after")
            try leaseRoot.revalidate(coordinate: "lease_root_after")
            try workingDirectory.requireEmpty(
                coordinate: "private_working_directory_after"
            )
            try base.revalidate(coordinate: "production_base_after")
            let expectedBaseInventory = (
                capsule.productionBaseEntryNamesBefore + [
                    PrimeValidationDriverV2GovernorJournal.rootLeaf,
                    "outer-supervisor-stdout.bin",
                    "outer-supervisor-stderr.bin",
                ]
            ).sorted()
            guard try PrimeValidationDriverV2GovernorIO.inventory(
                directory: base.descriptor,
                coordinate: "production_base_after"
            ) == expectedBaseInventory else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .postReapRejection,
                    "production_base_inventory_after"
                )
            }
            let createdPaths = Set([
                base.absolutePath + "/"
                    + PrimeValidationDriverV2GovernorJournal.rootLeaf,
                base.absolutePath + "/outer-supervisor-stdout.bin",
                base.absolutePath + "/outer-supervisor-stderr.bin",
            ])
            for path in capsule.forbiddenAbsentAbsolutePaths
            where !createdPaths.contains(path) {
                var status = stat()
                errno = 0
                guard lstat(path, &status) == -1, errno == ENOENT else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus
                            .postReapRejection,
                        "declared_absent_path_after"
                    )
                }
            }
            rootsRejoined = true
        } catch let failure as PrimeValidationDriverV2ShotGovernorFailure {
            semanticFailure = failure.coordinate
        }
        let groupsEmpty = try requireGroupsEmpty(
            inner.recordedChildProcessGroups
        )
        if !groupsEmpty { semanticFailure = "inner_child_group_present" }
        if !stdout.reachedEOF || !stderr.reachedEOF {
            semanticFailure = "capture_eof"
        }
        if stdout.overflowed || stderr.overflowed {
            semanticFailure = "capture_overflow"
        }

        let outcome: PrimeValidationDriverV2GovernorTerminalOutcome
        let finalStatus: Int32
        if !processResult.wait.exitedNormally
            || processResult.wait.exitStatus != 0
        {
            outcome = .containedNonzero(
                .init(
                    innerJournalPrefix: inner.immutablePrefix,
                    rawTerminalSHA256: inner.rawTerminalSHA256,
                    exactSupervisorStatus:
                        processResult.wait.exitedNormally
                        ? processResult.wait.exitStatus
                        : -processResult.wait.terminationSignal
                )
            )
            finalStatus = PrimeValidationDriverV2ShotGovernorStatus
                .containedNonzero
        } else if semanticFailure == nil,
                  processResult.conservation.ordinaryExitPath,
                  inner.complete,
                  innerReceiptValidated,
                  outerContinuityRejoined,
                  let durableReceiptIdentitySHA256,
                  let durableReceiptJournalVnodes,
                  let rawTerminalSHA256 = inner.rawTerminalSHA256,
                  stdout.byteCount == 0,
                  stderr.byteCount == 0,
                  stdout.sha256 == emptySHA256,
                  stderr.sha256 == emptySHA256
        {
            outcome = .success(
                .init(
                    innerJournal: inner.immutablePrefix,
                    innerJournalVnodes: durableReceiptJournalVnodes,
                    durableReceiptIdentitySHA256:
                        durableReceiptIdentitySHA256,
                    rawTerminalSHA256: rawTerminalSHA256
                )
            )
            finalStatus = PrimeValidationDriverV2ShotGovernorStatus.success
        } else {
            outcome = .containedZeroSemanticRejection(
                .init(
                    innerJournalPrefix: inner.immutablePrefix,
                    rawTerminalSHA256: inner.rawTerminalSHA256,
                    failedCoordinate: semanticFailure
                        ?? "inner_journal_incomplete"
                )
            )
            finalStatus = PrimeValidationDriverV2ShotGovernorStatus
                .postReapRejection
        }
        do {
            try outerContinuity.revalidateContinuity()
            _ = try journal.publishCanonical(
                PrimeValidationDriverV2GovernorTerminalRecordV1(
                    startSHA256: startLeaf.sha256,
                    supervisorWait: processResult.wait,
                    standardOutput: stdout,
                    standardError: stderr,
                    conservation: processResult.conservation,
                    exactSupervisorReapCount: 1,
                    allRecordedChildGroupsEmpty: groupsEmpty,
                    governorImageRejoined: governorImageRejoined,
                    supervisorImageRejoined: supervisorImageRejoined,
                    gitImageRejoined: gitImageRejoined,
                    swiftImageRejoined: swiftImageRejoined,
                    rootsRejoined: rootsRejoined,
                    outerContinuityRevalidated:
                        outerContinuityRejoined,
                    outcome: outcome
                ),
                expectedLeaf:
                    PrimeValidationDriverV2GovernorJournal.terminalLeaf
            )
            try inner.revalidate()
            try outerContinuity.revalidateContinuity()
            try journal.revalidate()
        } catch {
            return PrimeValidationDriverV2ShotGovernorStatus
                .terminalPublication
        }
        return finalStatus
    }

    private static func requireGroupsEmpty(
        _ groups: Set<Int32>
    ) throws -> Bool {
        for group in groups {
            errno = 0
            let result = Darwin.kill(-group, 0)
            if result == -1, errno == ESRCH { continue }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "inner_child_group_query_\(errno)"
            )
        }
        return true
    }
}

package enum PrimeValidationDriverV2OuterJournalMechanicsMutation:
    Sendable
{
    case canonical
    case trailingLF
    case leadingWhitespace
    case oversized
    case terminalCollision
    case terminalSameBytesNewInode
}

package struct PrimeValidationDriverV2OuterJournalMechanicsLeaf:
    Equatable,
    Sendable
{
    package let leaf: String
    package let byteCount: UInt64
    package let sha256: String
    package let deviceID: UInt64
    package let inode: UInt64
}

package struct PrimeValidationDriverV2OuterJournalMechanicsObservation:
    Equatable,
    Sendable
{
    package let orderedLeaves:
        [PrimeValidationDriverV2OuterJournalMechanicsLeaf]
    package let rootLinkCount: UInt64
    package let requestReachedFiniteEOF: Bool
    package let standardOutputByteCount: UInt64
    package let standardOutputReachedEOF: Bool
    package let standardOutputOverflowed: Bool
    package let standardErrorByteCount: UInt64
    package let standardErrorReachedEOF: Bool
    package let standardErrorOverflowed: Bool
    package let retainedTerminalRevalidated: Bool
    package let spawnedProcessCount: Int
    package let gitOrSwiftProbeCount: Int
    package let productionStatusEligible: Bool
    package let authorityVector: String
}

package struct PrimeValidationDriverV2OuterJournalMechanicsFailure:
    Error,
    Equatable,
    Sendable
{
    package let status: Int32
}

package struct PrimeValidationDriverV2OuterJournalReboundObservation:
    Equatable,
    Sendable
{
    package let retainedDeviceID: UInt64
    package let retainedInode: UInt64
    package let replacementDeviceID: UInt64
    package let replacementInode: UInt64
    package let exactBytesEqual: Bool
}

private struct PrimeValidationDriverV2OuterMechanicsStart: Encodable {
    let schema = "prime_driver_v2_gate_e_outer_mechanics_start_v1"
    let capsuleSHA256: String
    let requestSHA256: String
    let spawnedProcessCount = 0

    private enum CodingKeys: String, CodingKey {
        case schema
        case capsuleSHA256 = "capsule_sha256"
        case requestSHA256 = "request_sha256"
        case spawnedProcessCount = "spawned_process_count"
    }
}

private struct PrimeValidationDriverV2OuterMechanicsTerminal: Encodable {
    let schema = "prime_driver_v2_gate_e_outer_mechanics_terminal_v1"
    let startSHA256: String
    let requestReachedFiniteEOF: Bool
    let standardOutput: PrimeValidationDriverV2GovernorCaptureObservation
    let standardError: PrimeValidationDriverV2GovernorCaptureObservation
    let spawnedProcessCount = 0
    let gitOrSwiftProbeCount = 0
    let productionStatusEligible = false
    let authorityVector = "00000000"

    private enum CodingKeys: String, CodingKey {
        case schema
        case startSHA256 = "start_sha256"
        case requestReachedFiniteEOF = "request_reached_finite_eof"
        case standardOutput = "standard_output"
        case standardError = "standard_error"
        case spawnedProcessCount = "spawned_process_count"
        case gitOrSwiftProbeCount = "git_or_swift_probe_count"
        case productionStatusEligible = "production_status_eligible"
        case authorityVector = "authority_vector"
    }
}

/// Package-internal, zero-process proof of the production outer durable
/// boundary. Construction accepts only already-held directory descriptors and
/// a value-only intent. Consumption has no execution parameters.
package final class PrimeValidationDriverV2OuterJournalMechanicsFacade:
    @unchecked Sendable
{
    private let oneShot = PrimeValidationDriverV2GovernorOneShot()
    private let base: PrimeValidationDriverV2GovernorHeldDirectory
    private let working: PrimeValidationDriverV2GovernorHeldDirectory
    private let exactCapsuleBytes: Data
    private let mutation: PrimeValidationDriverV2OuterJournalMechanicsMutation
    private let lock = NSLock()
    private var observation:
        PrimeValidationDriverV2OuterJournalMechanicsObservation?
    private var retainedJournal: PrimeValidationDriverV2GovernorJournal?
    private var retainedCaptures:
        [PrimeValidationDriverV2GovernorCapture] = []
    private var failurePrefixCountStorage = 0
    private var reboundObservationStorage:
        PrimeValidationDriverV2OuterJournalReboundObservation?

    package init(
        heldBaseDirectoryDescriptor: Int32,
        heldWorkingDirectoryDescriptor: Int32,
        intent: PrimeValidationRunIntentV2,
        mutation: PrimeValidationDriverV2OuterJournalMechanicsMutation
            = .canonical
    ) throws {
        try intent.validate()
        base = try PrimeValidationDriverV2GovernorHeldDirectory(
            duplicatingTestDescriptor: heldBaseDirectoryDescriptor,
            requirePrivate: true,
            requireEmpty: false,
            coordinate: "outer_mechanics_base"
        )
        working = try PrimeValidationDriverV2GovernorHeldDirectory(
            duplicatingTestDescriptor: heldWorkingDirectoryDescriptor,
            requirePrivate: true,
            requireEmpty: true,
            coordinate: "outer_mechanics_working"
        )
        let swiftDirectory = (intent.swiftExecutable.absolutePath as NSString)
            .deletingLastPathComponent
        let capsule = PrimeValidationDriverV2ShotCapsuleV1(
            schemaVersion: PrimeValidationDriverV2ShotCapsuleV1.schemaVersion,
            artifactKind: PrimeValidationDriverV2ShotCapsuleV1.artifactKind,
            attempt: 1,
            rerunAuthorized: false,
            localOnly: true,
            networkOperationCount: 0,
            dependencyFetchCount: 0,
            githubOperationCount: 0,
            fixtureExecutionCount: 0,
            swiftPMBuildExecutionCount: 0,
            artifactStagingExecutionCount: 0,
            inventoryExecutionCount: 0,
            gateFAuthorized: false,
            gateGAuthorized: false,
            controlCommit: String(repeating: "1", count: 40),
            controlTree: String(repeating: "2", count: 40),
            sourceCommit: String(repeating: "3", count: 40),
            sourceTree: String(repeating: "4", count: 40),
            companionCommit: intent.companionCommit,
            companionTree: String(repeating: "5", count: 40),
            sourceIdentitySHA256:
                PrimeEmbeddedBuildProvenance.sourceIdentitySHA256,
            primeAdmittedFileCount: 548,
            sourceIdentityRecordCount: 547,
            primeAuthorityDirectoryCount: 155,
            combinedWatcherDescriptorCount: 2_163,
            governorExecutable: intent.driverExecutable,
            supervisorExecutable: intent.driverExecutable,
            gitExecutable: intent.driverExecutable,
            swiftExecutable: .init(
                absolutePath: swiftDirectory + "/swift-frontend",
                content: intent.swiftExecutable.content
            ),
            productionBase: base.binding,
            productionBaseEntryNamesBefore:
                try PrimeValidationDriverV2GovernorIO.inventory(
                    directory: base.descriptor,
                    coordinate: "outer_mechanics_base"
                ),
            privateWorkingDirectory: working.binding,
            leaseDirectoryAbsolutePath: base.absolutePath + "/lease",
            forbiddenAbsentAbsolutePaths: [
                base.absolutePath + "/gate-e-shot-governor-journal",
                base.absolutePath + "/outer-supervisor-stderr.bin",
                base.absolutePath + "/outer-supervisor-stdout.bin",
            ].sorted(),
            intent: intent
        )
        let canonical = try PrimeCanonicalJSON.encode(capsule)
        try capsule.validate(exactCanonicalBytes: canonical)
        switch mutation {
        case .canonical, .terminalCollision, .terminalSameBytesNewInode:
            exactCapsuleBytes = canonical
        case .trailingLF:
            var bytes = canonical
            bytes.append(0x0a)
            exactCapsuleBytes = bytes
        case .leadingWhitespace:
            var bytes = Data([0x20])
            bytes.append(canonical)
            exactCapsuleBytes = bytes
        case .oversized:
            exactCapsuleBytes = Data(
                repeating: 0x20,
                count: 262_145
            )
        }
        self.mutation = mutation
    }

    package var permanentlyPoisoned: Bool {
        if case .poisoned = oneShot.snapshot() { return true }
        return false
    }

    package var failurePrefixCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return failurePrefixCountStorage
    }

    package var reboundObservation:
        PrimeValidationDriverV2OuterJournalReboundObservation?
    {
        lock.lock()
        defer { lock.unlock() }
        return reboundObservationStorage
    }

    package func consume()
        throws -> PrimeValidationDriverV2OuterJournalMechanicsObservation
    {
        let status = oneShot.consume {
            let value = try exerciseOnce()
            lock.lock()
            observation = value
            lock.unlock()
            return 0
        }
        guard status == 0 else {
            throw PrimeValidationDriverV2OuterJournalMechanicsFailure(
                status: status
            )
        }
        lock.lock()
        defer { lock.unlock() }
        guard let observation else {
            throw PrimeValidationDriverV2OuterJournalMechanicsFailure(
                status: PrimeValidationDriverV2ShotGovernorStatus
                    .containmentUncertain
            )
        }
        return observation
    }

    package func revalidateRetainedTerminal() throws {
        lock.lock()
        let journal = retainedJournal
        let captures = retainedCaptures
        lock.unlock()
        guard let journal, captures.count == 2 else {
            throw PrimeValidationDriverV2OuterJournalMechanicsFailure(
                status: PrimeValidationDriverV2ShotGovernorStatus
                    .durableBoundary
            )
        }
        try journal.revalidate()
        _ = try captures[0].finalize(reachedEOF: true, overflowed: false)
        _ = try captures[1].finalize(reachedEOF: true, overflowed: true)
    }

    private func exerciseOnce() throws
        -> PrimeValidationDriverV2OuterJournalMechanicsObservation
    {
        guard exactCapsuleBytes.count <= 262_144,
              exactCapsuleBytes.last != 0x0a
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "outer_mechanics_capsule_frame"
            )
        }
        let capsule = try PrimeValidationDriverV2ShotGovernor
            .decodeCanonicalCapsule(exactBytes: exactCapsuleBytes)
        let request = PrimeValidationDriverV2SupervisorLaunchRequestV1(
            intent: capsule.intent,
            leaseDirectoryAbsolutePath: capsule.leaseDirectoryAbsolutePath
        )
        try request.validate()
        let requestBytes = try PrimeCanonicalJSON.encode(request)
        let decodedRequest = try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2SupervisorLaunchRequestV1.self,
            from: requestBytes,
            artifact: "driver_v2_outer_mechanics_request"
        )
        try decodedRequest.validate()
        guard try PrimeCanonicalJSON.encode(decodedRequest) == requestBytes,
              requestBytes.count <= 262_144,
              requestBytes.last != 0x0a
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "outer_mechanics_request_frame"
            )
        }

        let filesystem = try PrimeValidationDriverV2GovernorIO
            .requireLocalAPFS(
                base.descriptor,
                coordinate: "outer_mechanics_base"
            )
        let journal = try PrimeValidationDriverV2GovernorJournal(
            base: base,
            filesystem: filesystem
        )
        let capsuleLeaf = try journal.publishExact(
            exactCapsuleBytes,
            expectedLeaf: PrimeValidationDriverV2GovernorJournal.capsuleLeaf
        )
        let requestLeaf = try journal.publishExact(
            requestBytes,
            expectedLeaf: PrimeValidationDriverV2GovernorJournal.requestLeaf
        )
        let requestInput = try journal.independentRequestInputDescriptor()
        defer { _ = Darwin.close(requestInput) }
        var finiteRequest = Data()
        var requestBuffer = [UInt8](repeating: 0, count: 16 * 1024)
        var reachedRequestEOF = false
        let requestDeadline = try PrimeValidationDriverV2GovernorDeadline(
            durationNanoseconds: 5_000_000_000
        )
        while true {
            try requestDeadline.requireTime("outer_mechanics_request_eof")
            let count = requestBuffer.withUnsafeMutableBytes {
                Darwin.read(requestInput, $0.baseAddress, $0.count)
            }
            if count < 0, errno == EINTR { continue }
            guard count >= 0 else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                    "outer_mechanics_request_read"
                )
            }
            if count == 0 {
                reachedRequestEOF = true
                break
            }
            finiteRequest.append(
                contentsOf: requestBuffer.prefix(count)
            )
            guard finiteRequest.count <= 262_144 else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                    "outer_mechanics_request_cap"
                )
            }
        }
        try requestDeadline.requireTime("outer_mechanics_request_post_eof")
        guard reachedRequestEOF, finiteRequest == requestBytes else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_mechanics_request_join"
            )
        }
        let start = try journal.publishCanonical(
            PrimeValidationDriverV2OuterMechanicsStart(
                capsuleSHA256: capsuleLeaf.sha256,
                requestSHA256: requestLeaf.sha256
            ),
            expectedLeaf: PrimeValidationDriverV2GovernorJournal.startLeaf
        )

        let stdoutCapture = try PrimeValidationDriverV2GovernorCapture(
            base: base,
            leaf: "outer-supervisor-stdout.bin"
        )
        let stderrCapture = try PrimeValidationDriverV2GovernorCapture(
            base: base,
            leaf: "outer-supervisor-stderr.bin"
        )
        var stdoutPipe = [Int32](repeating: -1, count: 2)
        var stderrPipe = [Int32](repeating: -1, count: 2)
        guard stdoutPipe.withUnsafeMutableBufferPointer({
            Darwin.pipe($0.baseAddress)
        }) == 0,
        stderrPipe.withUnsafeMutableBufferPointer({
            Darwin.pipe($0.baseAddress)
        }) == 0 else {
            for descriptor in stdoutPipe + stderrPipe where descriptor >= 0 {
                _ = Darwin.close(descriptor)
            }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_mechanics_pipe"
            )
        }
        defer {
            if stdoutPipe[1] >= 0 { _ = Darwin.close(stdoutPipe[1]) }
            if stderrPipe[1] >= 0 { _ = Darwin.close(stderrPipe[1]) }
        }
        let stdoutDrain = PrimeValidationDriverV2GovernorDrain(
            readDescriptor: stdoutPipe[0],
            capture: stdoutCapture,
            label: "prime.validation.driver-v2.mechanics.stdout"
        )
        let stderrDrain = PrimeValidationDriverV2GovernorDrain(
            readDescriptor: stderrPipe[0],
            capture: stderrCapture,
            label: "prime.validation.driver-v2.mechanics.stderr"
        )
        stdoutDrain.start()
        stderrDrain.start()
        _ = Darwin.close(stdoutPipe[1])
        stdoutPipe[1] = -1
        do {
            try PrimeValidationDriverV2GovernorIO.writeAll(
                Data(
                    repeating: 0x78,
                    count: Int(
                        PrimeValidationDriverV2GovernorCapture
                            .maximumByteCount + 1
                    )
                ),
                descriptor: stderrPipe[1],
                coordinate: "outer_mechanics_stderr"
            )
        } catch {
            _ = Darwin.close(stderrPipe[1])
            stderrPipe[1] = -1
            throw error
        }
        _ = Darwin.close(stderrPipe[1])
        stderrPipe[1] = -1
        let drainDeadline = try PrimeValidationDriverV2GovernorDeadline(
            durationNanoseconds: 5_000_000_000
        )
        let stdoutResult = Result {
            try stdoutDrain.finish(deadline: drainDeadline)
        }
        let stderrResult = Result {
            try stderrDrain.finish(deadline: drainDeadline)
        }
        let stdout: PrimeValidationDriverV2GovernorCaptureObservation
        let stderr: PrimeValidationDriverV2GovernorCaptureObservation
        switch (stdoutResult, stderrResult) {
        case let (.success(output), .success(error)):
            stdout = output
            stderr = error
        case let (.failure(failure), _):
            throw failure
        case let (_, .failure(failure)):
            throw failure
        }
        guard stdout.reachedEOF,
              stdout.byteCount == 0,
              !stdout.overflowed,
              stderr.reachedEOF,
              stderr.byteCount
                == PrimeValidationDriverV2GovernorCapture.maximumByteCount,
              stderr.overflowed
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                "outer_mechanics_capture"
            )
        }

        let terminal = PrimeValidationDriverV2OuterMechanicsTerminal(
            startSHA256: start.sha256,
            requestReachedFiniteEOF: reachedRequestEOF,
            standardOutput: stdout,
            standardError: stderr
        )
        if case .terminalCollision = mutation {
            lock.lock()
            failurePrefixCountStorage = journal.count
            retainedJournal = journal
            retainedCaptures = [stdoutCapture, stderrCapture]
            lock.unlock()
            _ = try journal
                .publishCanonicalWithTerminalCollisionForTesting(terminal)
        } else {
            _ = try journal.publishCanonical(
                terminal,
                expectedLeaf:
                    PrimeValidationDriverV2GovernorJournal.terminalLeaf
            )
        }
        lock.lock()
        failurePrefixCountStorage = journal.count
        retainedJournal = journal
        retainedCaptures = [stdoutCapture, stderrCapture]
        lock.unlock()
        if case .terminalSameBytesNewInode = mutation {
            let rebound = try journal
                .replaceTerminalWithSameBytesForTesting()
            lock.lock()
            reboundObservationStorage = .init(
                retainedDeviceID: rebound.retained.deviceID,
                retainedInode: rebound.retained.inode,
                replacementDeviceID: rebound.replacement.deviceID,
                replacementInode: rebound.replacement.inode,
                exactBytesEqual: rebound.bytesEqual
            )
            lock.unlock()
        }
        try journal.revalidate()
        let bindings = journal.bindings
        guard bindings.count == 4,
              Set(bindings.map { "\($0.vnode.deviceID):\($0.vnode.inode)" })
                .count == 4
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "outer_mechanics_leaf_identity"
            )
        }
        return .init(
            orderedLeaves: bindings.map {
                .init(
                    leaf: $0.leaf,
                    byteCount: $0.byteCount,
                    sha256: $0.sha256,
                    deviceID: $0.vnode.deviceID,
                    inode: $0.vnode.inode
                )
            },
            rootLinkCount: try journal.rootLinkCountForTesting(),
            requestReachedFiniteEOF: reachedRequestEOF,
            standardOutputByteCount: stdout.byteCount,
            standardOutputReachedEOF: stdout.reachedEOF,
            standardOutputOverflowed: stdout.overflowed,
            standardErrorByteCount: stderr.byteCount,
            standardErrorReachedEOF: stderr.reachedEOF,
            standardErrorOverflowed: stderr.overflowed,
            retainedTerminalRevalidated: true,
            spawnedProcessCount: 0,
            gitOrSwiftProbeCount: 0,
            productionStatusEligible: false,
            authorityVector: "00000000"
        )
    }
}

package enum PrimeValidationDriverV2SessionFixtureMode: Sendable {
    case prepublicationHeld
    case orphanTransition

    fileprivate var argument: String {
        switch self {
        case .prepublicationHeld:
            "--driver-v2-shared-session-prepublication-held"
        case .orphanTransition:
            "--driver-v2-shared-session-orphan-transition"
        }
    }
}

private enum PrimeValidationDriverV2SessionFixtureDiagnosticMode:
    String,
    Codable
{
    case prepublicationHeld = "prepublication_held"
    case orphanTransition = "orphan_transition"
}

private enum PrimeValidationDriverV2SessionFixtureExecutionPhase:
    String,
    Codable
{
    case postSpawnJoin = "post_spawn_join"
    case prepublicationChildDiscovery =
        "prepublication_child_discovery"
    case orphanDeathWait = "orphan_death_wait"
    case orphanInitialCensus = "orphan_initial_census"
    case primaryContainment = "primary_containment"
}

private enum PrimeValidationDriverV2SessionFixtureContainmentState:
    String,
    Codable
{
    case armed
    case exactReaped = "exact_reaped"
    case conservationComplete = "conservation_complete"
}

private struct PrimeValidationDriverV2SessionFixtureInitiatingFailure:
    Equatable,
    Sendable
{
    let status: Int32
    let coordinate: String
}

private struct PrimeValidationDriverV2SessionFixtureFailStopV2:
    Codable,
    Equatable
{
    static let requiredLeaf =
        "gate-e-session-fixture-fail-stop.json"
    static let schemaValue =
        "prime_driver_v2_session_fixture_fail_stop_v2"
    static let maximumByteCount = 1_024
    static let maximumCoordinateByteCount = 128

    let admittedDeviceID: UInt64
    let admittedInode: UInt64
    let containmentState:
        PrimeValidationDriverV2SessionFixtureContainmentState
    let containmentStopAttemptSequence: UInt64
    let containmentStopDeathEventCheckPerformed: Bool
    let containmentStopDeathEventObserved: Bool
    let containmentStopErrno: Int32
    let containmentStopReturn: Int32
    let deadlineExpired: Bool
    let deathEventObservedAtContainmentFailure: Bool
    let deathWaitReturned: Bool
    let executionPhase:
        PrimeValidationDriverV2SessionFixtureExecutionPhase
    let failureCoordinate: String
    let failureStatus: Int32
    let fixedFailStopStatus: Int32
    let fixtureMode:
        PrimeValidationDriverV2SessionFixtureDiagnosticMode
    let initiatingFailureCoordinate: String
    let initiatingFailureStatus: Int32
    let schema: String
    let sourceIdentitySHA256: String

    init(
        fixtureMode:
            PrimeValidationDriverV2SessionFixtureDiagnosticMode,
        executionPhase:
            PrimeValidationDriverV2SessionFixtureExecutionPhase,
        containmentState:
            PrimeValidationDriverV2SessionFixtureContainmentState,
        deadlineExpired: Bool,
        deathWaitReturned: Bool,
        initiatingFailure:
            PrimeValidationDriverV2SessionFixtureInitiatingFailure,
        containmentFailure: PrimeValidationDriverV2ShotGovernorFailure,
        containmentStopAttemptSequence: UInt64,
        deathEventObservedAtContainmentFailure: Bool,
        admittedDeviceID: UInt64,
        admittedInode: UInt64
    ) throws {
        guard let stop = containmentFailure
                .preliminarySupervisorStopObservation,
              admittedDeviceID > 0,
              admittedInode > 0,
              fixtureMode == .orphanTransition,
              executionPhase == .orphanInitialCensus,
              containmentState == .armed,
              deathWaitReturned,
              containmentStopAttemptSequence == 1,
              containmentFailure.status
                == PrimeValidationDriverV2ShotGovernorStatus
                    .containmentUncertain,
              containmentFailure.coordinate == "supervisor_stop",
              initiatingFailure.status
                == PrimeValidationDriverV2ShotGovernorStatus
                    .containmentUncertain,
              Self.coordinateIsBounded(containmentFailure.coordinate),
              Self.coordinateIsBounded(initiatingFailure.coordinate),
              Self.initiatingCoordinateIsClosedCensus(
                  initiatingFailure.coordinate
              ),
              stop.returnValue == 0 || stop.returnValue == -1,
              (stop.returnValue == 0) == (stop.errorNumber == 0),
              (stop.returnValue == -1)
                == (stop.errorNumber >= 1),
              stop.deathEventCheckPerformed
                == (
                    stop.returnValue == -1
                        && stop.errorNumber == ESRCH
                ),
              stop.deathEventCheckPerformed
                || !stop.deathEventObserved,
              deathEventObservedAtContainmentFailure,
              !deathWaitReturned
                || deathEventObservedAtContainmentFailure,
              !stop.deathEventObserved
                || deathEventObservedAtContainmentFailure,
              !(deathWaitReturned && stop.deathEventCheckPerformed)
                || stop.deathEventObserved,
              (containmentFailure.coordinate == "supervisor_stop")
                == (
                    stop.returnValue == -1
                        && !(
                            stop.errorNumber == ESRCH
                                && stop.deathEventCheckPerformed
                                && stop.deathEventObserved
                        )
                )
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "session_fixture_fail_stop_v2"
            )
        }
        self.admittedDeviceID = admittedDeviceID
        self.admittedInode = admittedInode
        self.containmentState = containmentState
        self.containmentStopAttemptSequence =
            containmentStopAttemptSequence
        containmentStopDeathEventCheckPerformed =
            stop.deathEventCheckPerformed
        containmentStopDeathEventObserved = stop.deathEventObserved
        containmentStopErrno = stop.errorNumber
        containmentStopReturn = stop.returnValue
        self.deadlineExpired = deadlineExpired
        self.deathEventObservedAtContainmentFailure =
            deathEventObservedAtContainmentFailure
        self.deathWaitReturned = deathWaitReturned
        self.executionPhase = executionPhase
        failureCoordinate = containmentFailure.coordinate
        failureStatus = containmentFailure.status
        fixedFailStopStatus =
            PrimeValidationDriverV2ShotGovernorStatus
                .containmentUncertain
        self.fixtureMode = fixtureMode
        initiatingFailureCoordinate = initiatingFailure.coordinate
        initiatingFailureStatus = initiatingFailure.status
        schema = Self.schemaValue
        sourceIdentitySHA256 =
            PrimeEmbeddedBuildProvenance.sourceIdentitySHA256
    }

    static func initiatingCoordinateIsClosedCensus(
        _ coordinate: String
    ) -> Bool {
        switch coordinate {
        case "session_census_capacity",
             "session_census_duplicate_pid",
             "session_census_duplicate_generation",
             "session_census_nonconvergent_query":
            return true
        default:
            break
        }
        let families: [(prefix: String, excludesESRCH: Bool)] = [
            ("session_census_getsid_", true),
            ("session_census_bsdinfo_", false),
            ("session_census_getpgid_", true),
        ]
        for family in families where coordinate.hasPrefix(family.prefix) {
            let suffix = coordinate.dropFirst(family.prefix.count)
            let suffixBytes = suffix.utf8
            guard !suffixBytes.isEmpty,
                  suffixBytes.allSatisfy({ $0 >= 48 && $0 <= 57 }),
                  suffixBytes.count == 1 || suffixBytes.first != 48,
                  let value = Int32(String(suffix)),
                  value >= 0,
                  !family.excludesESRCH || value != ESRCH
            else { return false }
            return true
        }
        return false
    }

    private static func coordinateIsBounded(_ coordinate: String) -> Bool {
        !coordinate.isEmpty
            && coordinate.utf8.count <= maximumCoordinateByteCount
            && coordinate.utf8.allSatisfy { byte in
                (byte >= 97 && byte <= 122)
                    || (byte >= 48 && byte <= 57)
                    || byte == 95
            }
    }
}

private final class PrimeValidationDriverV2SessionFixtureFailStopLeaf {
    private(set) var descriptor: Int32
    private let absolutePath: String
    private let admittedMetadata:
        PrimeValidationDriverV2GovernorMetadata
    private let admittedXattrs: PrimeValidationDriverV2GovernorXattrs
    private let admittedDescriptorFlags: Int32
    private let admittedStatusFlags: Int32

    var admittedDeviceID: UInt64 { admittedMetadata.deviceID }
    var admittedInode: UInt64 { admittedMetadata.inode }

    init(duplicatingTestDescriptor source: Int32) throws {
        guard source >= 3,
              Self.descriptorPolicyIsExact(source)
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "session_fixture_fail_stop_source_descriptor"
            )
        }
        descriptor = fcntl(source, F_DUPFD_CLOEXEC, 3)
        guard descriptor >= 3 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "session_fixture_fail_stop_duplicate"
            )
        }
        do {
            absolutePath = try PrimeValidationDriverV2GovernorIO
                .pathForDescriptor(
                    descriptor,
                    coordinate: "session_fixture_fail_stop_path"
                )
            guard URL(fileURLWithPath: absolutePath).lastPathComponent
                    == PrimeValidationDriverV2SessionFixtureFailStopV2
                        .requiredLeaf,
                  Self.descriptorPolicyIsExact(descriptor)
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    "session_fixture_fail_stop_descriptor"
                )
            }
            var held = stat()
            var named = stat()
            guard fstat(descriptor, &held) == 0,
                  lstat(absolutePath, &named) == 0,
                  held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  held.st_dev == named.st_dev,
                  held.st_ino == named.st_ino,
                  held.st_uid == geteuid(),
                  held.st_nlink == 1,
                  held.st_mode & mode_t(0o7777) == mode_t(0o600),
                  held.st_size == 0,
                  held.st_flags == 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    "session_fixture_fail_stop_preimage"
                )
            }
            let heldMetadata = try PrimeValidationDriverV2GovernorMetadata(
                held
            )
            let descriptorFlags = fcntl(descriptor, F_GETFD)
            let statusFlags = fcntl(descriptor, F_GETFL)
            guard try PrimeValidationDriverV2GovernorMetadata(named)
                    == heldMetadata,
                  descriptorFlags >= 0,
                  statusFlags >= 0
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.admission,
                    "session_fixture_fail_stop_named_join"
                )
            }
            admittedMetadata = heldMetadata
            admittedDescriptorFlags = descriptorFlags
            admittedStatusFlags = statusFlags
            admittedXattrs = try PrimeValidationDriverV2GovernorXattrs
                .capture(
                    descriptor,
                    coordinate: "session_fixture_fail_stop"
                )
            _ = try PrimeValidationDriverV2GovernorIO.requireLocalAPFS(
                descriptor,
                coordinate: "session_fixture_fail_stop"
            )
            try revalidateEmpty()
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw error
        }
    }

    deinit {
        if descriptor >= 3 { _ = Darwin.close(descriptor) }
    }

    func revalidateEmpty() throws {
        var held = stat()
        var named = stat()
        guard descriptor >= 3,
              Self.descriptorPolicyIsExact(descriptor),
              fcntl(descriptor, F_GETFD) == admittedDescriptorFlags,
              fcntl(descriptor, F_GETFL) == admittedStatusFlags,
              fstat(descriptor, &held) == 0,
              lstat(absolutePath, &named) == 0,
              try PrimeValidationDriverV2GovernorMetadata(held)
                == admittedMetadata,
              try PrimeValidationDriverV2GovernorMetadata(named)
                == admittedMetadata,
              try PrimeValidationDriverV2GovernorXattrs.capture(
                  descriptor,
                  coordinate: "session_fixture_fail_stop"
              ) == admittedXattrs,
              try PrimeValidationDriverV2GovernorIO.readExact(
                  descriptor: descriptor,
                  byteCount: 0,
                  coordinate: "session_fixture_fail_stop"
              ).isEmpty
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "session_fixture_fail_stop_changed"
            )
        }
    }

    func publishBestEffort(
        containmentFailure: PrimeValidationDriverV2ShotGovernorFailure,
        initiatingFailure:
            PrimeValidationDriverV2SessionFixtureInitiatingFailure?,
        fixtureMode:
            PrimeValidationDriverV2SessionFixtureDiagnosticMode,
        executionPhase:
            PrimeValidationDriverV2SessionFixtureExecutionPhase,
        containmentState:
            PrimeValidationDriverV2SessionFixtureContainmentState,
        deadlineExpired: Bool,
        deathWaitReturned: Bool,
        deathEventObservedAtContainmentFailure: Bool
    ) {
        do {
            guard let initiatingFailure,
                  containmentFailure.status
                    == PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain
            else { return }
            let record = try PrimeValidationDriverV2SessionFixtureFailStopV2(
                fixtureMode: fixtureMode,
                executionPhase: executionPhase,
                containmentState: containmentState,
                deadlineExpired: deadlineExpired,
                deathWaitReturned: deathWaitReturned,
                initiatingFailure: initiatingFailure,
                containmentFailure: containmentFailure,
                containmentStopAttemptSequence: 1,
                deathEventObservedAtContainmentFailure:
                    deathEventObservedAtContainmentFailure,
                admittedDeviceID: admittedMetadata.deviceID,
                admittedInode: admittedMetadata.inode
            )
            let canonical = try PrimeCanonicalJSON.encode(record)
            guard !canonical.isEmpty,
                  canonical.count
                    <= PrimeValidationDriverV2SessionFixtureFailStopV2
                        .maximumByteCount,
                  canonical.last != 0x0a
            else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .durableBoundary,
                    "session_fixture_fail_stop_frame"
                )
            }
            try revalidateEmpty()
            try PrimeValidationDriverV2GovernorIO.writeAllPositioned(
                canonical,
                descriptor: descriptor,
                coordinate: "session_fixture_fail_stop"
            )
            guard lseek(descriptor, 0, SEEK_CUR) == 0 else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .durableBoundary,
                    "session_fixture_fail_stop_offset"
                )
            }
            try PrimeValidationDriverV2GovernorIO.synchronize(
                descriptor,
                coordinate: "session_fixture_fail_stop_data"
            )
            guard fchmod(descriptor, mode_t(0o400)) == 0 else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .durableBoundary,
                    "session_fixture_fail_stop_mode"
                )
            }
            try PrimeValidationDriverV2GovernorIO.synchronize(
                descriptor,
                coordinate: "session_fixture_fail_stop_frozen"
            )
            try revalidatePostimage(record: record, canonical: canonical)
        } catch {
            return
        }
    }

    private func revalidatePostimage(
        record: PrimeValidationDriverV2SessionFixtureFailStopV2,
        canonical: Data
    ) throws {
        var held = stat()
        var named = stat()
        guard descriptor >= 3,
              Self.descriptorPolicyIsExact(descriptor),
              fcntl(descriptor, F_GETFD) == admittedDescriptorFlags,
              fcntl(descriptor, F_GETFL) == admittedStatusFlags,
              fstat(descriptor, &held) == 0,
              lstat(absolutePath, &named) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              UInt64(bitPattern: Int64(held.st_dev))
                == admittedMetadata.deviceID,
              UInt64(held.st_ino) == admittedMetadata.inode,
              held.st_uid == admittedMetadata.ownerUserID,
              held.st_gid == admittedMetadata.ownerGroupID,
              held.st_nlink == 1,
              held.st_mode & mode_t(0o7777) == mode_t(0o400),
              held.st_size == off_t(canonical.count),
              held.st_flags == 0,
              try PrimeValidationDriverV2GovernorMetadata(named)
                == PrimeValidationDriverV2GovernorMetadata(held),
              try PrimeValidationDriverV2GovernorXattrs.capture(
                  descriptor,
                  coordinate: "session_fixture_fail_stop"
              ) == admittedXattrs,
              try PrimeValidationDriverV2GovernorIO.readExact(
                  descriptor: descriptor,
                  byteCount: canonical.count,
                  coordinate: "session_fixture_fail_stop"
              ) == canonical,
              try PrimeCanonicalJSON.decode(
                  PrimeValidationDriverV2SessionFixtureFailStopV2.self,
                  from: canonical
              ) == record,
              record.admittedDeviceID == admittedMetadata.deviceID,
              record.admittedInode == admittedMetadata.inode
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "session_fixture_fail_stop_postimage"
            )
        }
    }

    private static func descriptorPolicyIsExact(_ value: Int32) -> Bool {
        let descriptorFlags = fcntl(value, F_GETFD)
        let statusFlags = fcntl(value, F_GETFL)
        return descriptorFlags >= 0
            && descriptorFlags & FD_CLOEXEC != 0
            && statusFlags >= 0
            && statusFlags & O_ACCMODE == O_RDWR
            && statusFlags & (O_APPEND | O_NONBLOCK | O_ASYNC) == 0
            && lseek(value, 0, SEEK_CUR) == 0
    }
}

package struct PrimeValidationDriverV2SessionFixtureObservation:
    Equatable,
    Sendable
{
    package let supervisorProcessIdentifier: Int32
    package let supervisorSessionIdentifier: Int32
    package let supervisorProcessGroupIdentifier: Int32
    package let appliedSupervisorSpawnFlags: UInt16
    package let mappedFixtureImageJoined: Bool
    package let workingDirectoryJoined: Bool
    package let discoveredDedicatedChildGroup: Bool
    package let acceptedOrphanAlreadyEmpty: Bool
    package let capturedProcessIdentifiers: [Int32]
    package let capturedProcessGroups: [Int32]
    package let exactSupervisorWait:
        PrimeValidationDriverV2SessionFixtureWaitObservation
    package let finalSessionEmpty: Bool
    package let finalGroupsEmpty: Bool
}

package struct PrimeValidationDriverV2SessionFixtureWaitObservation:
    Equatable,
    Sendable
{
    package let requestedProcessIdentifier: Int32
    package let returnedProcessIdentifier: Int32
    package let waitOptions: Int32
    package let rawWaitStatus: Int32
}

package extension PrimeValidationDriverV2ShotGovernor {
    static func sessionFixtureCausalFailStopV2CanonicalFixtureForTesting()
        throws -> Data
    {
        func makeRecord(
            initiatingCoordinate: String =
                "session_census_nonconvergent_query",
            stopAttemptSequence: UInt64 = 1,
            stopReturn: Int32 = -1,
            stopErrno: Int32 = 1,
            stopDeathEventCheckPerformed: Bool = false,
            stopDeathEventObserved: Bool = false,
            deathWaitReturned: Bool = true,
            deathEventObservedAtContainmentFailure: Bool = true
        ) throws -> PrimeValidationDriverV2SessionFixtureFailStopV2 {
            let containmentFailure = governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus
                    .containmentUncertain,
                "supervisor_stop",
                preliminarySupervisorStopObservation: .init(
                    returnValue: stopReturn,
                    errorNumber: stopErrno,
                    deathEventCheckPerformed:
                        stopDeathEventCheckPerformed,
                    deathEventObserved: stopDeathEventObserved
                )
            )
            return try .init(
                fixtureMode: .orphanTransition,
                executionPhase: .orphanInitialCensus,
                containmentState: .armed,
                deadlineExpired: false,
                deathWaitReturned: deathWaitReturned,
                initiatingFailure: .init(
                    status: PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    coordinate: initiatingCoordinate
                ),
                containmentFailure: containmentFailure,
                containmentStopAttemptSequence: stopAttemptSequence,
                deathEventObservedAtContainmentFailure:
                    deathEventObservedAtContainmentFailure,
                admittedDeviceID: 1,
                admittedInode: 2
            )
        }

        func requireRejected(
            _ operation: () throws
                -> PrimeValidationDriverV2SessionFixtureFailStopV2
        ) throws {
            do {
                _ = try operation()
            } catch {
                return
            }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "session_fixture_fail_stop_v2_self_check"
            )
        }

        try requireRejected { try makeRecord(stopAttemptSequence: 0) }
        try requireRejected { try makeRecord(stopAttemptSequence: 2) }
        try requireRejected {
            try makeRecord(stopReturn: 0, stopErrno: 1)
        }
        try requireRejected {
            try makeRecord(stopReturn: -1, stopErrno: 0)
        }
        try requireRejected {
            try makeRecord(stopDeathEventObserved: true)
        }
        try requireRejected {
            try makeRecord(
                stopDeathEventCheckPerformed: true,
                stopDeathEventObserved: true
            )
        }
        try requireRejected {
            try makeRecord(
                stopErrno: ESRCH,
                stopDeathEventCheckPerformed: false
            )
        }
        try requireRejected {
            try makeRecord(
                stopErrno: ESRCH,
                stopDeathEventCheckPerformed: true,
                stopDeathEventObserved: true
            )
        }
        try requireRejected {
            try makeRecord(
                deathEventObservedAtContainmentFailure: false
            )
        }
        try requireRejected {
            try makeRecord(
                stopErrno: ESRCH,
                stopDeathEventCheckPerformed: true,
                stopDeathEventObserved: false
            )
        }
        try requireRejected {
            try makeRecord(
                stopErrno: ESRCH,
                stopDeathEventCheckPerformed: true,
                stopDeathEventObserved: true,
                deathWaitReturned: false,
                deathEventObservedAtContainmentFailure: false
            )
        }
        for coordinate in [
            "session_census_unknown",
            "session_census_getsid_",
            "session_census_bsdinfo_-1",
            "session_census_getpgid_03",
            "session_census_getsid_x",
            "session_census_bsdinfo_2147483648",
            "session_census_getsid_3",
            "session_census_getpgid_3",
        ] {
            try requireRejected {
                try makeRecord(initiatingCoordinate: coordinate)
            }
        }

        let record = try makeRecord()
        let canonical = try PrimeCanonicalJSON.encode(record)
        guard !canonical.isEmpty,
              canonical.count
                <= PrimeValidationDriverV2SessionFixtureFailStopV2
                    .maximumByteCount,
              canonical.last != 0x0a,
              try PrimeCanonicalJSON.decode(
                  PrimeValidationDriverV2SessionFixtureFailStopV2.self,
                  from: canonical
              ) == record
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.durableBoundary,
                "session_fixture_fail_stop_v2_fixture"
            )
        }
        return canonical
    }

    /// Package-internal mechanics only. Every input is already held; this seam
    /// has no path loader and cannot be reached by
    /// the production capsule entry.
    static func exerciseSessionFixtureForTesting(
        heldSessionFixtureDescriptor: Int32,
        heldWorkingDirectoryDescriptor: Int32,
        heldFailStopDiagnosticDescriptor: Int32,
        mode: PrimeValidationDriverV2SessionFixtureMode
    ) throws -> PrimeValidationDriverV2SessionFixtureObservation {
        let failStopDiagnostic = try
            PrimeValidationDriverV2SessionFixtureFailStopLeaf(
                duplicatingTestDescriptor:
                    heldFailStopDiagnosticDescriptor
            )
        let diagnosticMode:
            PrimeValidationDriverV2SessionFixtureDiagnosticMode
        switch mode {
        case .prepublicationHeld:
            diagnosticMode = .prepublicationHeld
        case .orphanTransition:
            diagnosticMode = .orphanTransition
        }
        let executable = try PrimeValidationDriverV2GovernorHeldExecutable(
            duplicatingTestDescriptor: heldSessionFixtureDescriptor,
            requiredLeaf: "PrimeValidationWorkflowDriverV2SessionFixture",
            coordinate: "session_fixture_image"
        )
        let workingDescriptor = fcntl(
            heldWorkingDirectoryDescriptor,
            F_DUPFD_CLOEXEC,
            3
        )
        guard workingDescriptor >= 3 else {
            if workingDescriptor >= 0 { _ = Darwin.close(workingDescriptor) }
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "session_fixture_cwd_duplicate"
            )
        }
        defer { _ = Darwin.close(workingDescriptor) }
        var heldWorking = stat()
        guard fstat(workingDescriptor, &heldWorking) == 0,
              heldWorking.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              fcntl(workingDescriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "session_fixture_cwd"
            )
        }
        let deadline = try PrimeValidationDriverV2GovernorDeadline(
            durationNanoseconds: 10_000_000_000
        )
        var actions: posix_spawn_file_actions_t?
        guard posix_spawn_file_actions_init(&actions) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "session_fixture_actions_init"
            )
        }
        defer { _ = posix_spawn_file_actions_destroy(&actions) }
        let actionsResult = [
            posix_spawn_file_actions_addopen(
                &actions, STDIN_FILENO, "/dev/null", O_RDONLY, 0
            ),
            posix_spawn_file_actions_addopen(
                &actions, STDOUT_FILENO, "/dev/null", O_WRONLY, 0
            ),
            posix_spawn_file_actions_addopen(
                &actions, STDERR_FILENO, "/dev/null", O_WRONLY, 0
            ),
            posix_spawn_file_actions_addinherit_np(
                &actions,
                workingDescriptor
            ),
            primeDriverV2GovernorAddWorkingDirectoryAction(
                &actions,
                descriptor: workingDescriptor
            ),
            posix_spawn_file_actions_addclose(
                &actions,
                workingDescriptor
            ),
        ]
        guard actionsResult.allSatisfy({ $0 == 0 }) else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "session_fixture_actions"
            )
        }
        var attributes: posix_spawnattr_t?
        guard posix_spawnattr_init(&attributes) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "session_fixture_attributes_init"
            )
        }
        defer { _ = posix_spawnattr_destroy(&attributes) }
        var defaults = sigset_t()
        var mask = sigset_t()
        guard sigemptyset(&defaults) == 0,
              sigemptyset(&mask) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "session_fixture_signal_sets"
            )
        }
        for signal in 1 ..< NSIG
        where signal != SIGKILL && signal != SIGSTOP {
            guard sigaddset(&defaults, signal) == 0 else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                    "session_fixture_signal_default"
                )
            }
        }
        let flags: UInt16 = 0x448c
        guard posix_spawnattr_setsigdefault(&attributes, &defaults) == 0,
              posix_spawnattr_setsigmask(&attributes, &mask) == 0,
              posix_spawnattr_setflags(
                  &attributes,
                  Int16(bitPattern: flags)
              ) == 0
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "session_fixture_spawn_policy"
            )
        }
        guard let argumentZero = strdup(
            "prime-validation-driver-v2-session-fixture"
        ),
        let modeArgument = strdup(mode.argument)
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "session_fixture_arguments"
            )
        }
        defer {
            free(argumentZero)
            free(modeArgument)
        }
        var arguments: [UnsafeMutablePointer<CChar>?] = [
            argumentZero, modeArgument, nil,
        ]
        var environment: [UnsafeMutablePointer<CChar>?] = [nil]
        var pid: pid_t = 0
        let result = arguments.withUnsafeMutableBufferPointer { argv in
            environment.withUnsafeMutableBufferPointer { envp in
                posix_spawn(
                    &pid,
                    executable.absolutePath,
                    &actions,
                    &attributes,
                    argv.baseAddress!,
                    envp.baseAddress!
                )
            }
        }
        guard result == 0, pid > 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "session_fixture_spawn_\(result)"
            )
        }
        var executionPhase:
            PrimeValidationDriverV2SessionFixtureExecutionPhase =
                .postSpawnJoin
        let deathWatcher = PrimeValidationDriverV2GovernorDeathWatcher(pid: pid)
        var containmentState:
            PrimeValidationDriverV2SessionFixtureContainmentState = .armed
        var initiatingFailure:
            PrimeValidationDriverV2SessionFixtureInitiatingFailure? = nil
        var deathWaitReturned = false
        defer {
            do {
                switch containmentState {
                case .armed:
                    do {
                        _ = try PrimeValidationDriverV2GovernorSessionCensus
                            .contain(
                                supervisorPID: pid,
                                deathWatcher: deathWatcher,
                                deadline: deadline,
                                onExactReap: {
                                    containmentState = .exactReaped
                                }
                            )
                        containmentState = .conservationComplete
                    } catch {
                        guard case .exactReaped = containmentState else {
                            throw error
                        }
                        _ = try PrimeValidationDriverV2GovernorSessionCensus
                            .containSessionAfterSupervisorReaped(
                                supervisorPID: pid,
                                deadline: deadline
                            )
                        containmentState = .conservationComplete
                    }
                case .exactReaped:
                    _ = try PrimeValidationDriverV2GovernorSessionCensus
                        .containSessionAfterSupervisorReaped(
                            supervisorPID: pid,
                            deadline: deadline
                        )
                    containmentState = .conservationComplete
                case .conservationComplete:
                    break
                }
            } catch {
                let deadlineExpired =
                    DispatchTime.now().uptimeNanoseconds
                        >= deadline.expiresAt
                if let containmentFailure = error
                    as? PrimeValidationDriverV2ShotGovernorFailure
                {
                    failStopDiagnostic.publishBestEffort(
                        containmentFailure: containmentFailure,
                        initiatingFailure: initiatingFailure,
                        fixtureMode: diagnosticMode,
                        executionPhase: executionPhase,
                        containmentState: containmentState,
                        deadlineExpired: deadlineExpired,
                        deathWaitReturned: deathWaitReturned,
                        deathEventObservedAtContainmentFailure:
                            deathWatcher.hasObservedExit()
                    )
                }
                Darwin._exit(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain
                )
            }
        }
        do {
        guard Darwin.getpgid(pid) == pid,
              Darwin.getsid(pid) == pid
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "session_fixture_supervisor_relation"
            )
        }
        var cwdInfo = proc_vnodepathinfo()
        let cwdSize = MemoryLayout<proc_vnodepathinfo>.size
        let cwdResult = withUnsafeMutablePointer(to: &cwdInfo) {
            proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, $0, Int32(cwdSize))
        }
        let childCWD = cwdInfo.pvi_cdir.vip_vi.vi_stat
        guard cwdResult == Int32(cwdSize),
              UInt64(bitPattern: Int64(childCWD.vst_dev))
                == UInt64(bitPattern: Int64(heldWorking.st_dev)),
              childCWD.vst_ino == UInt64(heldWorking.st_ino)
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "session_fixture_cwd_join"
            )
        }
        _ = try PrimeValidationDriverV2GovernorProcessProof.mappedImage(
            pid: pid,
            executable: executable
        )
        try executable.revalidate(coordinate: "session_fixture_image")
        guard Darwin.kill(pid, SIGCONT) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "session_fixture_resume"
            )
        }

        var firstMembers = [PrimeValidationDriverV2GovernorSessionMember]()
        var acceptedAlreadyEmpty = false
        switch mode {
        case .prepublicationHeld:
            executionPhase = .prepublicationChildDiscovery
            while firstMembers.count < 2 {
                try deadline.requireTime("session_fixture_child_discovery")
                firstMembers = try PrimeValidationDriverV2GovernorSessionCensus
                    .scan(sessionIdentifier: pid)
                if firstMembers.count < 2 { _ = Darwin.usleep(1_000) }
            }
        case .orphanTransition:
            executionPhase = .orphanDeathWait
            let waitReturned = deathWatcher.wait(deadline: deadline)
            deathWaitReturned = waitReturned
            guard waitReturned else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "session_fixture_orphan_death"
                )
            }
            executionPhase = .orphanInitialCensus
            firstMembers = try PrimeValidationDriverV2GovernorSessionCensus
                .scan(sessionIdentifier: pid)
            acceptedAlreadyEmpty = firstMembers.allSatisfy {
                $0.processIdentifier == pid
            }
        }
        executionPhase = .primaryContainment
        let resultObservation = try PrimeValidationDriverV2GovernorSessionCensus
            .contain(
                supervisorPID: pid,
                deathWatcher: deathWatcher,
                deadline: deadline,
                onExactReap: { containmentState = .exactReaped }
            )
        containmentState = .conservationComplete
        try failStopDiagnostic.revalidateEmpty()
        return .init(
            supervisorProcessIdentifier: pid,
            supervisorSessionIdentifier: pid,
            supervisorProcessGroupIdentifier: pid,
            appliedSupervisorSpawnFlags: flags,
            mappedFixtureImageJoined: true,
            workingDirectoryJoined: true,
            discoveredDedicatedChildGroup: firstMembers.contains {
                $0.processIdentifier != pid
                    && $0.processGroupIdentifier == $0.processIdentifier
            },
            acceptedOrphanAlreadyEmpty: acceptedAlreadyEmpty,
            capturedProcessIdentifiers:
                resultObservation.conservation.capturedMembers
                .map(\.processIdentifier),
            capturedProcessGroups:
                resultObservation.conservation.capturedProcessGroups,
            exactSupervisorWait: .init(
                requestedProcessIdentifier:
                    resultObservation.wait.requestedProcessIdentifier,
                returnedProcessIdentifier:
                    resultObservation.wait.returnedProcessIdentifier,
                waitOptions: resultObservation.wait.waitOptions,
                rawWaitStatus: resultObservation.wait.rawWaitStatus
            ),
            finalSessionEmpty: resultObservation.conservation.sessionEmpty,
            finalGroupsEmpty:
                resultObservation.conservation.capturedGroupsAbsent
        )
        } catch {
            if let failure = error
                as? PrimeValidationDriverV2ShotGovernorFailure
            {
                initiatingFailure = .init(
                    status: failure.status,
                    coordinate: failure.coordinate
                )
            }
            throw error
        }
    }
}
