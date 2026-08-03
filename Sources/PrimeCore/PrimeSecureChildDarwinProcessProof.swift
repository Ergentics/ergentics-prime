// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation

/// Neutral, PrimeCore-internal Darwin proof mechanics for a child that is
/// still suspended. The inputs are snapshots of already-held capabilities;
/// this type does not accept paths as optional fallbacks, command authority,
/// or query callbacks.
enum PrimeSecureChildDarwinProcessProof {
    struct Rejection: Error, Equatable, Sendable {
        let detail: String
    }

    /// Closed mapping to the rejection details already emitted by the two
    /// current secure-child capabilities.
    enum HeldDirectoryContext: Equatable, Sendable {
        case neuralSourceRoot
        case validationWorkingDirectory

        fileprivate var changedDetail: String {
            switch self {
            case .neuralSourceRoot:
                "source_root_changed"
            case .validationWorkingDirectory:
                "working_directory_changed"
            }
        }
    }

    /// Non-owning snapshot of an already-admitted directory descriptor.
    /// Keeping the descriptor in this value does not transfer or duplicate
    /// ownership; its original capability must outlive every proof operation.
    struct HeldDirectorySnapshot: Equatable, Sendable {
        let descriptor: Int32
        let deviceID: UInt64
        let inode: UInt64
        let byteCount: Int64
        let ownerUserID: UInt32
        let ownerGroupID: UInt32
        let mode: UInt16
        let linkCount: UInt64
        let modificationTimeSeconds: Int64
        let modificationTimeNanoseconds: Int64
        let statusChangeTimeSeconds: Int64
        let statusChangeTimeNanoseconds: Int64
        let openedWithNoSymbolicLinksInPath: Bool
        let context: HeldDirectoryContext
    }

    /// The exact `PROC_PIDVNODEPATHINFO` value presented to the deterministic
    /// evaluator. Production obtains this value directly from `proc_pidinfo`.
    struct CurrentDirectoryQueryResult: Equatable, Sendable {
        let returnedByteCount: Int32
        let queryErrno: Int32
        let deviceID: UInt64
        let inode: UInt64
        let mode: UInt16
    }

    struct SuspendedWorkingDirectoryProof: Equatable, Sendable {
        let descriptorDeviceID: UInt64
        let descriptorInode: UInt64
        let descriptorOwnerUserID: UInt32
        let descriptorOwnerGroupID: UInt32
        let descriptorPermissionMode: UInt16
        let descriptorLinkCount: UInt64
        let descriptorIsDirectory: Bool
        let descriptorOpenedWithNoSymbolicLinksInPath: Bool
        let descriptorCloseOnExec: Bool
        let procPIDVnodePathInfoFlavor: Int32
        let procVnodePathInfoByteCount: Int
        let suspendedChildCurrentDirectoryDeviceID: UInt64
        let suspendedChildCurrentDirectoryInode: UInt64
        let exactDescriptorJoinObserved: Bool
    }

    /// Identity and mandatory canonical name of an already-admitted executable
    /// descriptor. The name is telemetry joined to the descriptor vnode; it
    /// never substitutes for the device/inode authority.
    struct HeldExecutableSnapshot: Equatable, Sendable {
        let deviceID: UInt64
        let inode: UInt64
        let expectedCanonicalAbsolutePath: String
    }

    struct MappedRegion: Equatable, Sendable {
        let address: UInt64
        let byteCount: UInt64
        let fileOffset: UInt64
        let protection: UInt32
        let deviceID: UInt64
        let inode: UInt64
    }

    /// One exact `PROC_PIDREGIONPATHINFO` result. `queryAddress` is retained so
    /// injected transcripts cannot skip, reorder, or replay an address.
    struct MappedRegionQueryResult: Equatable, Sendable {
        let queryAddress: UInt64
        let returnedByteCount: Int32
        let queryErrno: Int32
        let region: MappedRegion?
        let mappedVnodePath: String?
    }

    struct MappedRegionQueryObservation: Equatable, Sendable {
        let queryAddress: UInt64
        let returnedByteCount: Int
        let region: MappedRegion
    }

    struct MappedExecutableProof: Equatable, Sendable {
        let queries: [MappedRegionQueryObservation]
        let terminalQueryAddress: UInt64
        let terminalReturnByteCount: Int
        let terminalErrno: Int32
        let mappedExecutablePathTelemetry: String
    }

    static let mappedRegionQueryLimit = 65_536

    private static let expectedCurrentDirectoryByteCount =
        MemoryLayout<proc_vnodepathinfo>.size
    private static let expectedMappedRegionByteCount =
        MemoryLayout<proc_regionwithpathinfo>.size
    private static let mappedRegionTerminalErrno = Int32(EINVAL)

    /// Captures the baseline identity from an already-held descriptor. This
    /// does not open a path or acquire a new filesystem capability.
    static func snapshotHeldDirectory(
        descriptor: Int32,
        openedWithNoSymbolicLinksInPath: Bool,
        context: HeldDirectoryContext
    ) throws -> HeldDirectorySnapshot {
        var status = stat()
        let descriptorFlags = fcntl(descriptor, F_GETFD)
        guard descriptor >= 3,
              fstat(descriptor, &status) == 0,
              status.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              status.st_dev != 0,
              status.st_ino > 0,
              status.st_nlink > 0,
              openedWithNoSymbolicLinksInPath,
              descriptorFlags >= 0,
              descriptorFlags & FD_CLOEXEC != 0
        else {
            throw Rejection(detail: context.changedDetail)
        }
        return HeldDirectorySnapshot(
            descriptor: descriptor,
            deviceID: UInt64(bitPattern: Int64(status.st_dev)),
            inode: UInt64(status.st_ino),
            byteCount: Int64(status.st_size),
            ownerUserID: status.st_uid,
            ownerGroupID: status.st_gid,
            mode: UInt16(status.st_mode),
            linkCount: UInt64(status.st_nlink),
            modificationTimeSeconds:
                Int64(status.st_mtimespec.tv_sec),
            modificationTimeNanoseconds:
                Int64(status.st_mtimespec.tv_nsec),
            statusChangeTimeSeconds:
                Int64(status.st_ctimespec.tv_sec),
            statusChangeTimeNanoseconds:
                Int64(status.st_ctimespec.tv_nsec),
            openedWithNoSymbolicLinksInPath:
                openedWithNoSymbolicLinksInPath,
            context: context
        )
    }

    /// Revalidates the live descriptor against its captured identity without
    /// reopening or trusting a pathname.
    static func requireHeldDirectoryUnchanged(
        _ snapshot: HeldDirectorySnapshot
    ) throws {
        var status = stat()
        let descriptorFlags = fcntl(
            snapshot.descriptor,
            F_GETFD
        )
        guard snapshot.descriptor >= 3,
              fstat(snapshot.descriptor, &status) == 0,
              UInt64(bitPattern: Int64(status.st_dev))
                == snapshot.deviceID,
              UInt64(status.st_ino) == snapshot.inode,
              Int64(status.st_size) == snapshot.byteCount,
              status.st_uid == snapshot.ownerUserID,
              status.st_gid == snapshot.ownerGroupID,
              UInt16(status.st_mode) == snapshot.mode,
              UInt64(status.st_nlink) == snapshot.linkCount,
              Int64(status.st_mtimespec.tv_sec)
                == snapshot.modificationTimeSeconds,
              Int64(status.st_mtimespec.tv_nsec)
                == snapshot.modificationTimeNanoseconds,
              Int64(status.st_ctimespec.tv_sec)
                == snapshot.statusChangeTimeSeconds,
              Int64(status.st_ctimespec.tv_nsec)
                == snapshot.statusChangeTimeNanoseconds,
              status.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              snapshot.openedWithNoSymbolicLinksInPath,
              descriptorFlags >= 0,
              descriptorFlags & FD_CLOEXEC != 0
        else {
            throw Rejection(
                detail: snapshot.context.changedDetail
            )
        }
    }

    /// Binds a mandatory canonical name to the identity of an already-held
    /// executable descriptor. Descriptor admission and byte stability remain
    /// the responsibility of the owning closed capability.
    static func snapshotHeldExecutable(
        deviceID: UInt64,
        inode: UInt64,
        expectedCanonicalAbsolutePath: String
    ) throws -> HeldExecutableSnapshot {
        guard deviceID > 0,
              inode > 0,
              isMandatoryCanonicalAbsolutePath(
                  expectedCanonicalAbsolutePath
              )
        else {
            throw Rejection(detail: "mapped_executable_join")
        }
        return HeldExecutableSnapshot(
            deviceID: deviceID,
            inode: inode,
            expectedCanonicalAbsolutePath:
                expectedCanonicalAbsolutePath
        )
    }

    /// Concrete production capture. The held identity is checked on both
    /// sides of the suspended-child vnode query.
    static func captureSuspendedWorkingDirectory(
        processIdentifier: Int32,
        heldDirectory: HeldDirectorySnapshot
    ) throws -> SuspendedWorkingDirectoryProof {
        try requireDarwinCalibration()
        try requireHeldDirectoryUnchanged(heldDirectory)

        var raw = proc_vnodepathinfo()
        errno = 0
        let returned = withUnsafeMutablePointer(to: &raw) {
            proc_pidinfo(
                processIdentifier,
                PROC_PIDVNODEPATHINFO,
                0,
                $0,
                Int32(expectedCurrentDirectoryByteCount)
            )
        }
        let queryErrno = errno
        let status = raw.pvi_cdir.vip_vi.vi_stat
        let proof = try evaluateSuspendedWorkingDirectory(
            heldDirectory: heldDirectory,
            queryResult: CurrentDirectoryQueryResult(
                returnedByteCount: returned,
                queryErrno: queryErrno,
                deviceID:
                    UInt64(bitPattern: Int64(status.vst_dev)),
                inode: status.vst_ino,
                mode: status.vst_mode
            )
        )
        try requireHeldDirectoryUnchanged(heldDirectory)
        return proof
    }

    /// Value-only deterministic evaluator for adapter and mutation tests.
    static func evaluateSuspendedWorkingDirectory(
        heldDirectory: HeldDirectorySnapshot,
        queryResult: CurrentDirectoryQueryResult
    ) throws -> SuspendedWorkingDirectoryProof {
        try requireDarwinCalibration()
        try requireHeldDirectoryUnchanged(heldDirectory)
        guard queryResult.returnedByteCount
                == Int32(expectedCurrentDirectoryByteCount),
              queryResult.deviceID == heldDirectory.deviceID,
              queryResult.inode == heldDirectory.inode,
              queryResult.mode & UInt16(S_IFMT) == UInt16(S_IFDIR)
        else {
            throw Rejection(
                detail:
                    "child_cwd_descriptor_join_\(queryResult.queryErrno)"
            )
        }
        return SuspendedWorkingDirectoryProof(
            descriptorDeviceID: heldDirectory.deviceID,
            descriptorInode: heldDirectory.inode,
            descriptorOwnerUserID: heldDirectory.ownerUserID,
            descriptorOwnerGroupID: heldDirectory.ownerGroupID,
            descriptorPermissionMode:
                heldDirectory.mode & UInt16(0o7777),
            descriptorLinkCount: heldDirectory.linkCount,
            descriptorIsDirectory: true,
            descriptorOpenedWithNoSymbolicLinksInPath:
                heldDirectory.openedWithNoSymbolicLinksInPath,
            descriptorCloseOnExec: true,
            procPIDVnodePathInfoFlavor:
                Int32(PROC_PIDVNODEPATHINFO),
            procVnodePathInfoByteCount:
                expectedCurrentDirectoryByteCount,
            suspendedChildCurrentDirectoryDeviceID:
                queryResult.deviceID,
            suspendedChildCurrentDirectoryInode:
                queryResult.inode,
            exactDescriptorJoinObserved: true
        )
    }

    /// Concrete production mapped-image capture. Every query is issued here;
    /// the resulting value transcript is then passed through the same
    /// deterministic evaluator used by adapters and mutation tests.
    static func captureMappedExecutable(
        processIdentifier: Int32,
        heldExecutable: HeldExecutableSnapshot
    ) throws -> MappedExecutableProof {
        try requireDarwinCalibration()
        var queryAddress: UInt64 = 0
        var results: [MappedRegionQueryResult] = []
        results.reserveCapacity(256)

        while results.count < mappedRegionQueryLimit {
            var raw = proc_regionwithpathinfo()
            errno = 0
            let returned = withUnsafeMutablePointer(to: &raw) {
                proc_pidinfo(
                    processIdentifier,
                    PROC_PIDREGIONPATHINFO,
                    queryAddress,
                    $0,
                    Int32(expectedMappedRegionByteCount)
                )
            }
            let queryErrno = errno
            let result: MappedRegionQueryResult
            if returned == Int32(expectedMappedRegionByteCount) {
                let status = raw.prp_vip.vip_vi.vi_stat
                result = MappedRegionQueryResult(
                    queryAddress: queryAddress,
                    returnedByteCount: returned,
                    queryErrno: queryErrno,
                    region: MappedRegion(
                        address: raw.prp_prinfo.pri_address,
                        byteCount: raw.prp_prinfo.pri_size,
                        fileOffset: raw.prp_prinfo.pri_offset,
                        protection: raw.prp_prinfo.pri_protection,
                        deviceID:
                            UInt64(
                                bitPattern: Int64(status.vst_dev)
                            ),
                        inode: status.vst_ino
                    ),
                    mappedVnodePath:
                        boundedVnodePath(raw.prp_vip.vip_path)
                )
            } else {
                result = MappedRegionQueryResult(
                    queryAddress: queryAddress,
                    returnedByteCount: returned,
                    queryErrno: queryErrno,
                    region: nil,
                    mappedVnodePath: nil
                )
            }
            results.append(result)

            guard returned == Int32(expectedMappedRegionByteCount),
                  queryErrno == 0,
                  let region = result.region
            else {
                break
            }
            let end = region.address.addingReportingOverflow(
                region.byteCount
            )
            guard region.address >= queryAddress,
                  region.byteCount > 0,
                  !end.overflow,
                  end.partialValue > region.address
            else {
                break
            }
            queryAddress = end.partialValue
        }
        return try evaluateMappedExecutable(
            heldExecutable: heldExecutable,
            queryResults: results
        )
    }

    /// Value-only deterministic evaluator. The security limit and terminal
    /// errno are implementation constants, not caller-selectable policy.
    static func evaluateMappedExecutable(
        heldExecutable: HeldExecutableSnapshot,
        queryResults: [MappedRegionQueryResult]
    ) throws -> MappedExecutableProof {
        try requireDarwinCalibration()
        guard heldExecutable.deviceID > 0,
              heldExecutable.inode > 0,
              isMandatoryCanonicalAbsolutePath(
                  heldExecutable.expectedCanonicalAbsolutePath
              )
        else {
            throw Rejection(detail: "mapped_executable_join")
        }

        var queryAddress: UInt64 = 0
        var observations: [MappedRegionQueryObservation] = []
        observations.reserveCapacity(
            min(256, queryResults.count)
        )
        var matchingPathTelemetry = Set<String>()

        for result in queryResults {
            guard observations.count < mappedRegionQueryLimit else {
                throw Rejection(detail: "mapped_region_query_limit")
            }
            guard result.queryAddress == queryAddress else {
                throw Rejection(detail: "mapped_region_progress")
            }
            if result.returnedByteCount == 0 {
                guard result.queryErrno == mappedRegionTerminalErrno,
                      !observations.isEmpty else {
                    throw Rejection(
                        detail:
                            "mapped_region_terminal_\(result.queryErrno)"
                    )
                }
                let matching = observations
                    .map(\.region)
                    .filter {
                        $0.deviceID == heldExecutable.deviceID
                            && $0.inode == heldExecutable.inode
                    }
                let hasOffsetZeroExecutable = matching.contains {
                    $0.fileOffset == 0
                        && ($0.protection
                            & UInt32(VM_PROT_EXECUTE)) != 0
                }
                let hasWritableExecutable = matching.contains {
                    ($0.protection & UInt32(VM_PROT_WRITE)) != 0
                        && ($0.protection
                            & UInt32(VM_PROT_EXECUTE)) != 0
                }
                guard hasOffsetZeroExecutable,
                      !hasWritableExecutable,
                      matchingPathTelemetry.count == 1,
                      let mappedPath = matchingPathTelemetry.first,
                      mappedPath
                        == heldExecutable.expectedCanonicalAbsolutePath,
                      isMandatoryCanonicalAbsolutePath(mappedPath)
                else {
                    throw Rejection(detail: "mapped_executable_join")
                }
                return MappedExecutableProof(
                    queries: observations,
                    terminalQueryAddress: queryAddress,
                    terminalReturnByteCount:
                        Int(result.returnedByteCount),
                    terminalErrno: result.queryErrno,
                    mappedExecutablePathTelemetry: mappedPath
                )
            }
            guard result.returnedByteCount
                    == Int32(expectedMappedRegionByteCount),
                  result.queryErrno == 0,
                  let region = result.region
            else {
                throw Rejection(
                    detail:
                        "mapped_region_query_\(result.returnedByteCount)_\(result.queryErrno)"
                )
            }

            if region.deviceID == heldExecutable.deviceID,
               region.inode == heldExecutable.inode,
               let mappedPath = result.mappedVnodePath {
                matchingPathTelemetry.insert(mappedPath)
            }
            let end = region.address.addingReportingOverflow(
                region.byteCount
            )
            guard region.address >= queryAddress,
                  region.byteCount > 0,
                  !end.overflow,
                  end.partialValue > region.address
            else {
                throw Rejection(detail: "mapped_region_progress")
            }
            observations.append(
                MappedRegionQueryObservation(
                    queryAddress: queryAddress,
                    returnedByteCount:
                        Int(result.returnedByteCount),
                    region: region
                )
            )
            queryAddress = end.partialValue
        }
        throw Rejection(detail: "mapped_region_query_limit")
    }

    private static func requireDarwinCalibration() throws {
        guard PROC_PIDVNODEPATHINFO == 9,
              PROC_PIDREGIONPATHINFO == 8,
              expectedCurrentDirectoryByteCount == 2_352,
              expectedMappedRegionByteCount == 1_272,
              mappedRegionTerminalErrno == 22,
              UInt32(VM_PROT_WRITE) == 0x2,
              UInt32(VM_PROT_EXECUTE) == 0x4
        else {
            throw Rejection(detail: "darwin_capability_calibration")
        }
    }

    private static func isMandatoryCanonicalAbsolutePath(
        _ path: String
    ) -> Bool {
        guard path.hasPrefix("/"),
              path != "/",
              !path.contains("\0")
        else {
            return false
        }
        return (try? PrimeSecureChildPath.canonicalPath(path)) == path
    }

    private static func boundedVnodePath<Path>(
        _ pathStorage: Path
    ) -> String? {
        var mutableStorage = pathStorage
        return withUnsafeBytes(of: &mutableStorage) { bytes in
            guard let terminator = bytes.firstIndex(of: 0),
                  terminator > 0,
                  terminator < bytes.count
            else {
                return nil
            }
            return String(
                bytes: bytes[0 ..< terminator],
                encoding: .utf8
            )
        }
    }
}
