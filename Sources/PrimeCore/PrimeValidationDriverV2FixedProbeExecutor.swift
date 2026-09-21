// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

/// Data-only receipt for the independent outer Governor source-continuity
/// owner. Decoding or copying this value cannot restore either held root,
/// snapshot, kqueue, or watch.
@_spi(PrimeValidationDriverV2OuterContinuity)
public struct PrimeValidationDriverV2OuterSourceContinuityObservation:
    Codable,
    Equatable,
    Sendable
{
    public let primeSourceIdentitySHA256: String
    public let primeSourceSnapshotByteCount: UInt64
    public let primeSourceSnapshotSHA256: String
    public let primeAdmittedFileCount: Int
    public let primeSourceIdentityRecordCount: Int
    public let primeAuthorityDirectoryCount: Int
    public let companionWorkingTreeIdentitySHA256: String
    public let companionFileCount: Int
    public let companionDirectoryCount: Int
    public let primeWatcherDescriptorCount: Int
    public let companionWatcherDescriptorCount: Int
    public let combinedWatcherDescriptorCount: Int

    fileprivate init(
        primeSourceIdentitySHA256: String,
        primeSourceSnapshotByteCount: UInt64,
        primeSourceSnapshotSHA256: String,
        primeAdmittedFileCount: Int,
        primeSourceIdentityRecordCount: Int,
        primeAuthorityDirectoryCount: Int,
        companionWorkingTreeIdentitySHA256: String,
        companionFileCount: Int,
        companionDirectoryCount: Int,
        primeWatcherDescriptorCount: Int,
        companionWatcherDescriptorCount: Int,
        combinedWatcherDescriptorCount: Int
    ) {
        self.primeSourceIdentitySHA256 =
            primeSourceIdentitySHA256
        self.primeSourceSnapshotByteCount =
            primeSourceSnapshotByteCount
        self.primeSourceSnapshotSHA256 =
            primeSourceSnapshotSHA256
        self.primeAdmittedFileCount = primeAdmittedFileCount
        self.primeSourceIdentityRecordCount =
            primeSourceIdentityRecordCount
        self.primeAuthorityDirectoryCount =
            primeAuthorityDirectoryCount
        self.companionWorkingTreeIdentitySHA256 =
            companionWorkingTreeIdentitySHA256
        self.companionFileCount = companionFileCount
        self.companionDirectoryCount = companionDirectoryCount
        self.primeWatcherDescriptorCount =
            primeWatcherDescriptorCount
        self.companionWatcherDescriptorCount =
            companionWatcherDescriptorCount
        self.combinedWatcherDescriptorCount =
            combinedWatcherDescriptorCount
    }

    private enum CodingKeys: String, CodingKey {
        case primeSourceIdentitySHA256 =
            "prime_source_identity_sha256"
        case primeSourceSnapshotByteCount =
            "prime_source_snapshot_byte_count"
        case primeSourceSnapshotSHA256 =
            "prime_source_snapshot_sha256"
        case primeAdmittedFileCount =
            "prime_admitted_file_count"
        case primeSourceIdentityRecordCount =
            "prime_source_identity_record_count"
        case primeAuthorityDirectoryCount =
            "prime_authority_directory_count"
        case companionWorkingTreeIdentitySHA256 =
            "companion_working_tree_identity_sha256"
        case companionFileCount = "companion_file_count"
        case companionDirectoryCount = "companion_directory_count"
        case primeWatcherDescriptorCount =
            "prime_watcher_descriptor_count"
        case companionWatcherDescriptorCount =
            "companion_watcher_descriptor_count"
        case combinedWatcherDescriptorCount =
            "combined_watcher_descriptor_count"
    }
}

/// Source-sealed counts shared by native admission, retained checks, typed
/// readback, and the governor. Values describe this exact source closure.
@_spi(PrimeValidationDriverV2RoleFacade)
public enum PrimeValidationDriverV2SealedSourceTopology {
    public static let primeAdmittedFileCount = 663
    public static let sourceIdentityRecordCount = primeAdmittedFileCount - 1
    public static let primeAuthorityDirectoryCount = 170
    public static let combinedWatcherDescriptorCount =
        primeAdmittedFileCount + primeAuthorityDirectoryCount + 1_306 + 154
}

/// Independent outer-process owner of the two Gate C source closures.
///
/// The Governor supplies only already-held root descriptors and Prime's
/// canonical data snapshot. This owner duplicates the descriptors, joins the
/// snapshot bytes to the held Prime vnode, captures the complete companion
/// non-`.git` topology, closes both capture-to-watch gaps with vnode metadata,
/// and retains both kqueues until this opaque object is released. It exposes
/// no root, path, snapshot, descriptor, watch, spawn, or retry surface.
@_spi(PrimeValidationDriverV2OuterContinuity)
public final class PrimeValidationDriverV2OuterSourceContinuity:
    @unchecked Sendable
{
    private enum State {
        case live(
            prime: PrimeSecureHeldSourceWatch,
            companion: PrimeSecureHeldSourceWatch
        )
        case poisoned
    }

    private static let requiredPrimeSourcePaths: Set<String> = [
        "Sources/PrimeCore/" +
            "PrimeNativeNeuralGateHeldSourceClosure.swift",
        "Sources/PrimeCore/PrimeSecureHeldSourceWatch.swift",
        "Sources/PrimeCore/" +
            "PrimeValidationDriverV2FixedProbeExecutor.swift",
    ]
    private static let requiredPrimeAdmittedFileCount =
        PrimeValidationDriverV2SealedSourceTopology.primeAdmittedFileCount
    private static let requiredPrimeSourceIdentityRecordCount =
        PrimeValidationDriverV2SealedSourceTopology.sourceIdentityRecordCount
    private static let requiredPrimeAuthorityDirectoryCount =
        PrimeValidationDriverV2SealedSourceTopology.primeAuthorityDirectoryCount
    private static let requiredCompanionFileCount = 1_306
    private static let requiredCompanionDirectoryCount = 154
    private static let requiredPrimeWatcherDescriptorCount =
        requiredPrimeAdmittedFileCount + requiredPrimeAuthorityDirectoryCount
    private static let requiredCompanionWatcherDescriptorCount =
        requiredCompanionFileCount + requiredCompanionDirectoryCount
    private static let requiredCombinedWatcherDescriptorCount =
        requiredPrimeWatcherDescriptorCount + requiredCompanionWatcherDescriptorCount

    public let observation:
        PrimeValidationDriverV2OuterSourceContinuityObservation

    private let lock = NSLock()
    private var state: State

    private init(
        primeWatch: PrimeSecureHeldSourceWatch,
        companionWatch: PrimeSecureHeldSourceWatch,
        observation:
            PrimeValidationDriverV2OuterSourceContinuityObservation
    ) {
        state = .live(
            prime: primeWatch,
            companion: companionWatch
        )
        self.observation = observation
    }

    /// Captures one independent outer continuity owner. The caller retains no
    /// way to reconstruct the internal admission identities or either watch
    /// from the returned data-only observation.
    public static func capture(
        primeRootDescriptor: Int32,
        primeSourceSnapshot: PrimeSwiftSourceSnapshot,
        companionRootDescriptor: Int32
    ) throws -> PrimeValidationDriverV2OuterSourceContinuity {
        try PrimeSwiftSourceProvenance.validate(
            primeSourceSnapshot,
            requiredRelativePaths: requiredPrimeSourcePaths
        )
        let primeSnapshotCanonicalData = try PrimeCanonicalJSON.encode(
            primeSourceSnapshot
        )
        let embeddedPath =
            PrimeSwiftSourceProvenance.embeddedProvenanceRelativePath
        let embeddedRecordCount = primeSourceSnapshot.files.reduce(0) {
            $0 + ($1.relativePath == embeddedPath ? 1 : 0)
        }
        let primeSourceIdentityRecordCount =
            primeSourceSnapshot.files.count - embeddedRecordCount
        guard embeddedRecordCount == 1,
              primeSourceSnapshot.sourceIdentitySHA256
                == primeSourceSnapshot.embeddedSourceIdentitySHA256,
              primeSourceSnapshot.embeddedSourceIdentitySHA256
                == PrimeEmbeddedBuildProvenance.sourceIdentitySHA256,
              primeSourceSnapshot.buildConfiguration == "release",
              primeSourceSnapshot.files.count
                == requiredPrimeAdmittedFileCount,
              primeSourceIdentityRecordCount
                == requiredPrimeSourceIdentityRecordCount
        else {
            throw rejected("prime_source_snapshot")
        }

        let primeDescriptor = try duplicateHeldRootDescriptor(
            primeRootDescriptor,
            label: "prime"
        )
        defer { _ = Darwin.close(primeDescriptor) }
        let companionDescriptor = try duplicateHeldRootDescriptor(
            companionRootDescriptor,
            label: "companion"
        )
        defer { _ = Darwin.close(companionDescriptor) }

        var primeRootStatus = stat()
        var companionRootStatus = stat()
        guard fstat(primeDescriptor, &primeRootStatus) == 0,
              fstat(companionDescriptor, &companionRootStatus) == 0,
              primeRootStatus.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFDIR),
              companionRootStatus.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFDIR),
              primeRootStatus.st_dev != companionRootStatus.st_dev
                || primeRootStatus.st_ino != companionRootStatus.st_ino
        else {
            throw rejected("root_descriptor_identity")
        }

        // Capture both metadata baselines before registering either watch.
        // Each watch constructor then requires the exact captured identities,
        // so neither tree can absorb a mutation from this point to arming.
        let primeAdmissionIdentity = try
            PrimeSecureHeldWorkingTreeSnapshot
            .captureLegacyPrimeSourceIdentity(
                rootDescriptor: primeDescriptor,
                sourceSnapshot: primeSourceSnapshot
            )
        let companionSnapshot = try
            PrimeSecureHeldWorkingTreeSnapshot.capture(
                rootDescriptor: companionDescriptor
            )

        let expectedPrimeWatcherCount =
            PrimeSecureHeldSourceWatch.expectedWatcherDescriptorCount(
                sourceSnapshot: primeSourceSnapshot
            )
        let expectedCompanionWatcherCount =
            PrimeSecureHeldSourceWatch.expectedWatcherDescriptorCount(
                completeWorkingTreeSnapshot: companionSnapshot
            )
        let primeAuthorityDirectoryCount =
            expectedPrimeWatcherCount - primeSourceSnapshot.files.count
        let expectedCombinedWatcherCount = expectedPrimeWatcherCount
            .addingReportingOverflow(expectedCompanionWatcherCount)
        guard primeAuthorityDirectoryCount
                == requiredPrimeAuthorityDirectoryCount,
              companionSnapshot.files.count
                == requiredCompanionFileCount,
              companionSnapshot.directoryRelativePaths.count
                == requiredCompanionDirectoryCount,
              expectedPrimeWatcherCount
                == requiredPrimeWatcherDescriptorCount,
              expectedCompanionWatcherCount
                == requiredCompanionWatcherDescriptorCount,
              !expectedCombinedWatcherCount.overflow,
              expectedCombinedWatcherCount.partialValue
                == requiredCombinedWatcherDescriptorCount
        else {
            throw rejected("source_topology_count")
        }

        let primeWatch = try PrimeSecureHeldSourceWatch(
            rootDescriptor: primeDescriptor,
            sourceSnapshot: primeSourceSnapshot,
            admissionIdentitySnapshot: primeAdmissionIdentity
        )
        let companionWatch = try PrimeSecureHeldSourceWatch(
            rootDescriptor: companionDescriptor,
            completeWorkingTreeSnapshot: companionSnapshot
        )
        guard primeWatch.heldWatcherDescriptorCount
                == expectedPrimeWatcherCount,
              companionWatch.heldWatcherDescriptorCount
                == expectedCompanionWatcherCount,
              primeWatch.heldWatcherDescriptorCount
                + companionWatch.heldWatcherDescriptorCount
                == requiredCombinedWatcherDescriptorCount
        else {
            throw rejected("source_watcher_count")
        }

        let owner = PrimeValidationDriverV2OuterSourceContinuity(
            primeWatch: primeWatch,
            companionWatch: companionWatch,
            observation: .init(
                primeSourceIdentitySHA256:
                    primeSourceSnapshot.sourceIdentitySHA256,
                primeSourceSnapshotByteCount:
                    UInt64(primeSnapshotCanonicalData.count),
                primeSourceSnapshotSHA256:
                    PrimeSHA256.hexDigest(
                        of: primeSnapshotCanonicalData
                    ),
                primeAdmittedFileCount:
                    primeSourceSnapshot.files.count,
                primeSourceIdentityRecordCount:
                    primeSourceIdentityRecordCount,
                primeAuthorityDirectoryCount:
                    primeAuthorityDirectoryCount,
                companionWorkingTreeIdentitySHA256:
                    companionSnapshot.identitySHA256,
                companionFileCount: companionSnapshot.files.count,
                companionDirectoryCount:
                    companionSnapshot.directoryRelativePaths.count,
                primeWatcherDescriptorCount:
                    primeWatch.heldWatcherDescriptorCount,
                companionWatcherDescriptorCount:
                    companionWatch.heldWatcherDescriptorCount,
                combinedWatcherDescriptorCount:
                    requiredCombinedWatcherDescriptorCount
            )
        )
        try owner.revalidateContinuity()
        return owner
    }

    /// Revalidates only the two already-armed closures. Failure permanently
    /// poisons and releases both owners; there is no retry or rebaseline path.
    public func revalidateContinuity() throws {
        lock.lock()
        defer { lock.unlock() }
        guard case let .live(primeWatch, companionWatch) = state else {
            throw Self.rejected("poisoned")
        }
        do {
            _ = try primeWatch.revalidateWhilePrepared()
            _ = try companionWatch.revalidateWhilePrepared()
            try primeWatch.fixedProbeCheckpointNoPendingEvents()
            try companionWatch.fixedProbeCheckpointNoPendingEvents()
        } catch {
            state = .poisoned
            throw error
        }
    }

    private static func duplicateHeldRootDescriptor(
        _ descriptor: Int32,
        label: String
    ) throws -> Int32 {
        let flags = descriptor >= 3
            ? fcntl(descriptor, F_GETFD)
            : -1
        guard flags >= 0,
              flags & FD_CLOEXEC != 0
        else {
            throw rejected("\(label)_root_descriptor")
        }
        let duplicate = fcntl(descriptor, F_DUPFD_CLOEXEC, 3)
        guard duplicate >= 3 else {
            let failure = errno
            if duplicate >= 0 { _ = Darwin.close(duplicate) }
            throw rejected("\(label)_root_duplicate_\(failure)")
        }
        let duplicateFlags = fcntl(duplicate, F_GETFD)
        guard duplicateFlags >= 0,
              duplicateFlags & FD_CLOEXEC != 0
        else {
            let failure = errno
            _ = Darwin.close(duplicate)
            throw rejected("\(label)_root_duplicate_\(failure)")
        }
        return duplicate
    }

    private static func rejected(
        _ detail: String
    ) -> PrimeValidationSwiftPMBuildInventoryAdmissionError {
        .rejected("driver_v2_outer_source_continuity_\(detail)")
    }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public enum PrimeValidationDriverV2FixedProbeRole:
    String,
    Equatable,
    Hashable,
    Sendable
{
    case primeHeadPre = "prime_head_pre"
    case primeObjectFormat = "prime_object_format"
    case primeStatusPre = "prime_status_pre"
    case primeTreeDiscovery = "prime_tree_discovery"
    case primeTreeReplay = "prime_tree_replay"
    case primeStatusPost = "prime_status_post"
    case primeHeadPost = "prime_head_post"
    case companionHeadPre = "companion_head_pre"
    case companionObjectFormat = "companion_object_format"
    case companionStatusPre = "companion_status_pre"
    case companionTreeDiscovery = "companion_tree_discovery"
    case companionTreeReplay = "companion_tree_replay"
    case companionStatusPost = "companion_status_post"
    case companionHeadPost = "companion_head_post"
    case swiftVersion = "swift_version"
    case swiftTargetInfo = "swift_target_info"
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2FixedProbeJournalLeafObservation:
    Equatable,
    Sendable
{
    public let leaf: String
    public let byteCount: UInt64
    public let sha256: String
    public let deviceID: UInt64
    public let inode: UInt64

    fileprivate init(
        leaf: String,
        byteCount: UInt64,
        sha256: String,
        deviceID: UInt64,
        inode: UInt64
    ) {
        self.leaf = leaf
        self.byteCount = byteCount
        self.sha256 = sha256
        self.deviceID = deviceID
        self.inode = inode
    }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2FixedProbePersonalityIdentityObservation:
    Equatable,
    Sendable
{
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let mode: UInt32
    public let linkCount: UInt64
    public let byteCount: Int64
    public let modificationSeconds: Int64
    public let modificationNanoseconds: Int64
    public let statusChangeSeconds: Int64
    public let statusChangeNanoseconds: Int64

    init(_ value: PrimeValidationSwiftPMPersonalityIdentity) {
        deviceID = value.deviceID
        inode = value.inode
        ownerUserID = value.ownerUserID
        ownerGroupID = value.ownerGroupID
        mode = value.mode
        linkCount = value.linkCount
        byteCount = value.byteCount
        modificationSeconds = value.modificationSeconds
        modificationNanoseconds = value.modificationNanoseconds
        statusChangeSeconds = value.statusChangeSeconds
        statusChangeNanoseconds = value.statusChangeNanoseconds
    }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2FixedProbeProcessObservation:
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let role: PrimeValidationDriverV2FixedProbeRole
    public let logicalArgumentZero: String
    public let arguments: [String]
    public let orderedEnvironment:
        [PrimeValidationSwiftPMDeterministicEnvironmentEntry]
    public let workingDirectory: PrimeValidationSwiftPMDirectoryObservation
    public let executable: PrimeValidationSwiftPMFileObservation
    public let standardOutput: Data
    public let standardError: Data
    public let processIdentifier: Int32
    public let appliedSpawnFlags: UInt16
    public let spawnReturnCode: Int32
    public let spawnReturnedUptimeNanoseconds: UInt64
    public let sessionIdentifier: Int32
    public let processGroupIdentifier: Int32
    public let suspendedWorkingDirectoryDeviceID: UInt64
    public let suspendedWorkingDirectoryInode: UInt64
    public let exactSuspendedWorkingDirectoryJoin: Bool
    public let deathObserved: Bool
    public let deathObservedUptimeNanoseconds: UInt64
    public let preReapProcessGroupMemberIdentifiers: [Int32]
    public let startPublishedUptimeNanoseconds: UInt64
    public let preResumeContinuityCheckpointUptimeNanoseconds: UInt64
    public let resumedAtUptimeNanoseconds: UInt64
    public let startDurableBeforeResume: Bool
    public let terminalPublishedUptimeNanoseconds: UInt64
    public let mappedImageJoined: Bool
    public let requestedWaitProcessIdentifier: Int32
    public let returnedWaitProcessIdentifier: Int32
    public let waitOptions: Int32
    public let rawWaitStatus: Int32
    public let waitReturnedUptimeNanoseconds: UInt64
    public let exitedNormally: Bool
    public let exitStatus: Int32
    public let terminationSignal: Int32
    public let coreDumped: Bool
    public let standardOutputReachedEOF: Bool
    public let standardOutputTotalByteCount: UInt64
    public let standardOutputTerminalReason: String
    public let standardOutputOverflowed: Bool
    public let standardOutputWorkerFinished: Bool
    public let standardOutputReadErrorNumber: Int32
    public let standardOutputWriteErrorNumber: Int32
    public let standardOutputFinalizationErrorNumber: Int32
    public let standardOutputCloseErrorNumber: Int32
    public let standardOutputDescriptorsClosed: Bool
    public let standardErrorReachedEOF: Bool
    public let standardErrorTotalByteCount: UInt64
    public let standardErrorTerminalReason: String
    public let standardErrorOverflowed: Bool
    public let standardErrorWorkerFinished: Bool
    public let standardErrorReadErrorNumber: Int32
    public let standardErrorWriteErrorNumber: Int32
    public let standardErrorFinalizationErrorNumber: Int32
    public let standardErrorCloseErrorNumber: Int32
    public let standardErrorDescriptorsClosed: Bool
    public let processGroupEmptyAfterReap: Bool
    public let startLeaf:
        PrimeValidationDriverV2FixedProbeJournalLeafObservation
    public let terminalLeaf:
        PrimeValidationDriverV2FixedProbeJournalLeafObservation
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2FixedProbeRawObservation:
    Equatable,
    Sendable
{
    public let supervisorProcessIdentifier: Int32
    public let supervisorSessionIdentifier: Int32
    public let supervisorProcessGroupIdentifier: Int32
    public let orderedProcesses:
        [PrimeValidationDriverV2FixedProbeProcessObservation]
    public let primeHeldEntries:
        [PrimeValidationDriverV2TrackedTreeHeldEntry]
    public let companionHeldEntries:
        [PrimeValidationDriverV2TrackedTreeHeldEntry]
    public let primeHeldEntriesSHA256: String
    public let companionHeldEntriesSHA256: String
    public let primeRepository: PrimeValidationSwiftPMDirectoryObservation
    public let companionRepository:
        PrimeValidationSwiftPMDirectoryObservation
    public let workspaceRoot: PrimeValidationSwiftPMDirectoryObservation
    public let evidenceRoot: PrimeValidationSwiftPMDirectoryObservation
    public let sourceSnapshot: PrimeSwiftSourceSnapshot
    public let sourceSnapshotCanonicalData: Data
    public let sourceIdentitySHA256: String
    public let embeddedSourceIdentitySHA256: String
    public let packageResolvedBinding: PrimeArtifactBinding
    public let packageResolvedData: Data
    public let packageResolvedHeldEntry:
        PrimeValidationDriverV2TrackedTreeHeldEntry
    public let packageResolvedFileObservation:
        PrimeValidationSwiftPMFileObservation
    public let companionDeclaration:
        PrimeValidationSwiftPMCompanionDeclaration
    public let toolchain: PrimeValidationSwiftPMToolchainObservation
    public let gitExecutable: PrimeValidationSwiftPMFileObservation
    public let gitExecutableData: Data
    public let swiftFrontendExecutable:
        PrimeValidationSwiftPMFileObservation
    public let swiftFrontendExecutableData: Data
    public let swiftExecutablePersonality:
        PrimeValidationSwiftPMPersonalityObservation
    public let swiftCompilerPersonality:
        PrimeValidationSwiftPMPersonalityObservation
    public let swiftExecutablePersonalityIdentity:
        PrimeValidationDriverV2FixedProbePersonalityIdentityObservation
    public let swiftCompilerPersonalityIdentity:
        PrimeValidationDriverV2FixedProbePersonalityIdentityObservation
    public let xcodeVersionPlistData: Data
    public let sdkSettingsPlistData: Data
    public let currentProcessExecutable:
        PrimeValidationSwiftPMFileObservation
    public let prestartLeaf:
        PrimeValidationDriverV2FixedProbeJournalLeafObservation
    public let rawTerminalLeaf:
        PrimeValidationDriverV2FixedProbeJournalLeafObservation
    public let prestartPublishedUptimeNanoseconds: UInt64
    public let rawTerminalPublishedUptimeNanoseconds: UInt64
    public let deadlineStartedAtUptimeNanoseconds: UInt64
    public let deadlineExpiresAtUptimeNanoseconds: UInt64
    public let executorTerminalUptimeNanoseconds: UInt64
    public let combinedSourceWatcherDescriptorCount: Int
    public let productionSupervisorImageEligible: Bool
}

@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2FixedProbeBoundLifetime:
    @unchecked Sendable
{
    private let lock = NSLock()
    private var retainedState:
        PrimeValidationSwiftPMRetainedGuardedPreExecutorState?
    private let deadline: PrimeSecureChildPhaseDeadline
    private var lastObservedUptimeNanoseconds: UInt64
    private let context: PrimeValidationDriverV2RoleContext
    private let buildPolicy: PrimeValidationDriverV2ClosedRolePolicy
    private let executionPredecessorObservation: PrimeValidationDriverV2FixedProbeRawObservation?

    public let productionSupervisorImageEligible: Bool

    public var combinedSourceWatcherDescriptorCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return retainedState?.combinedSourceWatcherDescriptorCount ?? 0
    }

    init(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
        deadline: PrimeSecureChildPhaseDeadline,
        lastObservedUptimeNanoseconds: UInt64,
        context: PrimeValidationDriverV2RoleContext,
        buildPolicy: PrimeValidationDriverV2ClosedRolePolicy,
        executionPredecessorObservation: PrimeValidationDriverV2FixedProbeRawObservation? = nil
    ) {
        self.retainedState = retainedState
        self.deadline = deadline
        self.lastObservedUptimeNanoseconds = lastObservedUptimeNanoseconds
        self.context = context
        self.buildPolicy = buildPolicy
        self.executionPredecessorObservation = executionPredecessorObservation
        productionSupervisorImageEligible =
            retainedState.productionSupervisorImageEligible
    }

    public func revalidateContinuity() throws {
        lock.lock()
        defer { lock.unlock() }
        guard let retainedState else {
            throw primeValidationDriverV2FixedProbeRejected(
                "bound_lifetime_released"
            )
        }
        let before = DispatchTime.now().uptimeNanoseconds
        guard before >= lastObservedUptimeNanoseconds,
              try deadline.acceptsCompletion(
                  observedAtUptimeNanoseconds: before
              ) else {
            self.retainedState = nil
            throw primeValidationDriverV2FixedProbeRejected(
                "deadline_bound_revalidation"
            )
        }
        do {
            try retainedState.fixedProbeRevalidateTransferredContinuity()
            let after = DispatchTime.now().uptimeNanoseconds
            guard after >= before,
                  try deadline.acceptsCompletion(
                      observedAtUptimeNanoseconds: after
                  ) else {
                self.retainedState = nil
                throw primeValidationDriverV2FixedProbeRejected(
                    "deadline_bound_revalidation"
                )
            }
            lastObservedUptimeNanoseconds = after
        } catch {
            self.retainedState = nil
            throw error
        }
    }

    /// Consumes the live Gate E owner before its original deadline. The new
    /// deadline governs only Gate F; it never extends or revives Gate E.
    public func consumeForBuild() throws -> PrimeValidationDriverV2BuildOwner {
        lock.lock()
        defer { lock.unlock() }
        guard let retainedState else {
            throw primeValidationDriverV2FixedProbeRejected(
                "bound_lifetime_released"
            )
        }
        // Consumption is permanent even when a final checkpoint rejects.
        self.retainedState = nil
        let before = DispatchTime.now().uptimeNanoseconds
        guard retainedState.productionSupervisorImageEligible,
              buildPolicy.role == .build,
              buildPolicy.maximumWallNanoseconds == 900_000_000_000,
              try deadline.authorizesNewWork(
                  observedAtUptimeNanoseconds: before,
                  notBeforeUptimeNanoseconds: lastObservedUptimeNanoseconds
              )
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "build_transfer_precondition"
            )
        }
        try retainedState.fixedProbeRevalidateTransferredContinuity()
        let consumedAt = DispatchTime.now().uptimeNanoseconds
        guard try deadline.authorizesNewWork(
            observedAtUptimeNanoseconds: consumedAt,
            notBeforeUptimeNanoseconds: before
        ) else {
            throw primeValidationDriverV2FixedProbeRejected(
                "build_transfer_deadline"
            )
        }
        let buildDeadline = try PrimeSecureChildPhaseDeadline(
            startUptimeNanoseconds: consumedAt,
            durationNanoseconds: 900_000_000_000
        )
        return try PrimeValidationDriverV2BuildOwner(
            retainedState: retainedState,
            context: context,
            buildPolicy: buildPolicy,
            deadline: buildDeadline,
            executionPredecessorObservation: executionPredecessorObservation
        )
    }
}

/// Internal inputs from the unique Gate E handoff. Only the opaque build
/// owner can construct this value; declarations or journal bytes cannot.
struct PrimeValidationDriverV2BuildExecutionState {
    let retainedState: PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    let context: PrimeValidationDriverV2RoleContext
    let buildPolicy: PrimeValidationDriverV2ClosedRolePolicy
    let deadline: PrimeSecureChildPhaseDeadline
    let pinnedBundleInput: PrimeValidationDriverV2PinnedBundleInput
    let executionPredecessorObservation: PrimeValidationDriverV2FixedProbeRawObservation?

    fileprivate init(
        retainedState: PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
        context: PrimeValidationDriverV2RoleContext,
        buildPolicy: PrimeValidationDriverV2ClosedRolePolicy,
        deadline: PrimeSecureChildPhaseDeadline,
        executionPredecessorObservation: PrimeValidationDriverV2FixedProbeRawObservation? = nil
    ) throws {
        guard context.requiredPinnedMetallibByteCount
                == PrimePinnedMLXMetallib.expectedByteCount,
              context.requiredPinnedMetallibSHA256
                == PrimePinnedMLXMetallib.expectedSHA256
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "build_calibration_bundle_pin"
            )
        }
        self.retainedState = retainedState
        self.context = context
        self.buildPolicy = buildPolicy
        self.deadline = deadline
        self.executionPredecessorObservation = executionPredecessorObservation
        pinnedBundleInput = try PrimeValidationDriverV2PinnedBundleInput.capture(
            primeRoot: retainedState.admission.primeRepository.root,
            deadlineNanoseconds: deadline.expiresAtUptimeNanoseconds
        )
    }
}

/// Opaque, one-shot ownership of the next fixed build. Process and staging
/// operations remain internal to the closed executor.
@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2BuildOwner: @unchecked Sendable {
    private let lock = NSLock()
    private var state: PrimeValidationDriverV2BuildExecutionState?
    private var executionStarted = false
    private var lastObservedUptimeNanoseconds: UInt64

    fileprivate init(
        retainedState: PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
        context: PrimeValidationDriverV2RoleContext,
        buildPolicy: PrimeValidationDriverV2ClosedRolePolicy,
        deadline: PrimeSecureChildPhaseDeadline,
        executionPredecessorObservation: PrimeValidationDriverV2FixedProbeRawObservation? = nil
    ) throws {
        state = try PrimeValidationDriverV2BuildExecutionState(
            retainedState: retainedState,
            context: context,
            buildPolicy: buildPolicy,
            deadline: deadline,
            executionPredecessorObservation: executionPredecessorObservation
        )
        lastObservedUptimeNanoseconds = deadline.startUptimeNanoseconds
    }

    func beginExecution() throws -> PrimeValidationDriverV2BuildExecutionState {
        lock.lock()
        defer { lock.unlock() }
        guard let state, !executionStarted else {
            throw primeValidationDriverV2FixedProbeRejected(
                "build_owner_consumed"
            )
        }
        executionStarted = true
        do {
            let before = DispatchTime.now().uptimeNanoseconds
            try requireTime(before, state: state, startsNewWork: true)
            try state.retainedState.fixedProbeRevalidateTransferredContinuity()
            try state.pinnedBundleInput.revalidate()
            let after = DispatchTime.now().uptimeNanoseconds
            lastObservedUptimeNanoseconds = before
            try requireTime(after, state: state, startsNewWork: true)
            lastObservedUptimeNanoseconds = after
            return state
        } catch {
            self.state = nil
            throw error
        }
    }

    func revalidateContinuity(
        staging: PrimeValidationDriverV2BuildStaging
    ) throws {
        lock.lock()
        defer { lock.unlock() }
        guard let state, executionStarted else {
            throw primeValidationDriverV2FixedProbeRejected(
                "build_owner_unavailable"
            )
        }
        do {
            let before = DispatchTime.now().uptimeNanoseconds
            try requireTime(before, state: state, startsNewWork: false)
            try state.retainedState.buildRevalidateTransferredContinuity(
                staging: staging
            )
            try state.pinnedBundleInput.revalidate()
            let after = DispatchTime.now().uptimeNanoseconds
            lastObservedUptimeNanoseconds = before
            try requireTime(after, state: state, startsNewWork: false)
            lastObservedUptimeNanoseconds = after
        } catch {
            self.state = nil
            throw error
        }
    }

    /// Consumes F's retained state before expiry, then establishes the fixed
    /// single G deadline. The same source, staging and artifact owners survive.
    func consumeForInventory(
        staging: PrimeValidationDriverV2BuildStaging,
        artifacts: PrimeValidationDriverV2BuildArtifacts
    ) throws -> PrimeValidationDriverV2InventoryOwner {
        lock.lock()
        defer { lock.unlock() }
        guard let state, executionStarted else {
            throw primeValidationDriverV2FixedProbeRejected("build_inventory_transfer_consumed")
        }
        self.state = nil
        let before = DispatchTime.now().uptimeNanoseconds
        try requireTime(before, state: state, startsNewWork: true)
        try state.retainedState.buildRevalidateTransferredContinuity(staging: staging)
        try state.pinnedBundleInput.revalidate()
        try artifacts.revalidate()
        let consumedAt = DispatchTime.now().uptimeNanoseconds
        guard consumedAt >= before else {
            throw primeValidationDriverV2FixedProbeRejected("build_inventory_transfer_clock")
        }
        try requireTime(consumedAt, state: state, startsNewWork: true)
        let deadline = try PrimeSecureChildPhaseDeadline(
            startUptimeNanoseconds: consumedAt,
            durationNanoseconds: 300_000_000_000
        )
        return try PrimeValidationDriverV2InventoryOwner(
            buildState: state, staging: staging, artifacts: artifacts,
            deadline: deadline
        )
    }

    func poison() {
        lock.lock()
        state = nil
        lock.unlock()
    }

    private func requireTime(
        _ observed: UInt64,
        state: PrimeValidationDriverV2BuildExecutionState,
        startsNewWork: Bool
    ) throws {
        let timely: Bool
        if startsNewWork {
            timely = try state.deadline.authorizesNewWork(
                observedAtUptimeNanoseconds: observed,
                notBeforeUptimeNanoseconds: lastObservedUptimeNanoseconds
            )
        } else {
            timely = try state.deadline.acceptsCompletion(
                observedAtUptimeNanoseconds: observed,
                notBeforeUptimeNanoseconds: lastObservedUptimeNanoseconds
            )
        }
        guard timely else {
            throw primeValidationDriverV2FixedProbeRejected(
                "build_owner_deadline"
            )
        }
    }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2FixedProbeRawCapability:
    @unchecked Sendable
{
    private enum State {
        case awaiting(
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
            PrimeSecureChildPhaseDeadline,
            UInt64
        )
        case transferred
        case poisoned
    }

    public let observation: PrimeValidationDriverV2FixedProbeRawObservation
    private let lock = NSLock()
    private var state: State
    private let context: PrimeValidationDriverV2RoleContext
    private let buildPolicy: PrimeValidationDriverV2ClosedRolePolicy

    init(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
        context: PrimeValidationDriverV2RoleContext,
        buildPolicy: PrimeValidationDriverV2ClosedRolePolicy,
        deadline: PrimeSecureChildPhaseDeadline,
        lastObservedUptimeNanoseconds: UInt64,
        observation: PrimeValidationDriverV2FixedProbeRawObservation
    ) {
        state = .awaiting(
            retainedState,
            deadline,
            lastObservedUptimeNanoseconds
        )
        self.observation = observation
        self.context = context
        self.buildPolicy = buildPolicy
    }

    deinit {
        lock.lock()
        state = .poisoned
        lock.unlock()
    }

    public func consumeValidatedBindingLifetime() throws
        -> PrimeValidationDriverV2FixedProbeBoundLifetime
    {
        lock.lock()
        defer { lock.unlock() }
        switch state {
        case let .awaiting(retainedState, deadline, lastObserved):
            let now = DispatchTime.now().uptimeNanoseconds
            guard now >= lastObserved,
                  try deadline.acceptsCompletion(
                      observedAtUptimeNanoseconds: now
                  ) else {
                state = .poisoned
                throw primeValidationDriverV2FixedProbeRejected(
                    "deadline_final_binding"
                )
            }
            state = .transferred
            return PrimeValidationDriverV2FixedProbeBoundLifetime(
                retainedState: retainedState,
                deadline: deadline,
                lastObservedUptimeNanoseconds: now,
                context: context,
                buildPolicy: buildPolicy,
                executionPredecessorObservation: context.executionAuthorized ? observation : nil
            )
        case .transferred:
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorTransferred
        case .poisoned:
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError
                .guardedPreExecutorPoisoned
        }
    }

    public func rejectValidatedBindingLifetime() {
        lock.lock()
        state = .poisoned
        lock.unlock()
    }
}

struct PrimeValidationDriverV2FixedProbeExecutionResult {
    let deadline: PrimeSecureChildPhaseDeadline
    let lastObservedUptimeNanoseconds: UInt64
    let observation: PrimeValidationDriverV2FixedProbeRawObservation
}

/// Closed, evidence-only result of the XCTest journal mechanics exercise.
/// No descriptor, retained owner, process handle, or continuation escapes.
struct PrimeValidationDriverV2FixedProbeJournalMechanicsTestObservation:
    Equatable,
    Sendable
{
    let orderedLeaves:
        [PrimeValidationDriverV2FixedProbeJournalLeafObservation]
    let leafPermissionModes: [UInt16]
    let leafLinkCounts: [UInt64]
    let rootLinkCount: UInt64
    let heldLeafDescriptorCount: Int
    let spawnedChildCount: Int
}

/// Closed, evidence-only result of projecting both held trees from the
/// already-retained Gate C owner and exercising Gate E's regular-tree guard.
struct PrimeValidationDriverV2FixedProbeHeldProjectionTestObservation:
    Equatable,
    Sendable
{
    let primeHeldEntryCount: Int
    let companionHeldEntryCount: Int
    let primeHeldEntriesSHA256: String
    let companionHeldEntriesSHA256: String
    let combinedSourceWatcherDescriptorCountBefore: Int
    let combinedSourceWatcherDescriptorCountAfter: Int
    let allProjectedEntriesRegular: Bool
    let regularTreeAccepted: Bool
    let symbolicLinkTreeRejected: Bool
    let gitlinkTreeRejected: Bool
    let spawnedChildCount: Int
}

/// Closed result of the production-shared lightweight Gate E checkpoint.
struct PrimeValidationDriverV2FixedProbeLightweightCheckpointTestObservation:
    Equatable,
    Sendable
{
    let combinedSourceWatcherDescriptorCountBefore: Int
    let combinedSourceWatcherDescriptorCountAfter: Int
    let spawnedChildCount: Int
}

/// One monotonic authority joins every clock observation made by the Gate E
/// executor. Per-child supervision retains the same absolute deadline, while
/// this owner prevents one child or checkpoint from moving time backwards
/// relative to any earlier child.
private final class PrimeValidationDriverV2FixedProbeClock {
    let deadline: PrimeSecureChildPhaseDeadline
    private(set) var lastObservedUptimeNanoseconds: UInt64

    init(deadline: PrimeSecureChildPhaseDeadline) {
        self.deadline = deadline
        lastObservedUptimeNanoseconds = deadline.startUptimeNanoseconds
    }

    @discardableResult
    func observeCompletion(
        _ observedAtUptimeNanoseconds: UInt64? = nil,
        label: String
    ) throws -> UInt64 {
        let observed = observedAtUptimeNanoseconds
            ?? DispatchTime.now().uptimeNanoseconds
        guard observed >= lastObservedUptimeNanoseconds,
              try deadline.acceptsCompletion(
                  observedAtUptimeNanoseconds: observed,
                  notBeforeUptimeNanoseconds:
                    lastObservedUptimeNanoseconds
              )
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "deadline_or_clock_\(label)"
            )
        }
        lastObservedUptimeNanoseconds = observed
        return observed
    }

    @discardableResult
    func authorizeNewWork(label: String) throws -> UInt64 {
        let observed = DispatchTime.now().uptimeNanoseconds
        guard observed >= lastObservedUptimeNanoseconds,
              try deadline.authorizesNewWork(
                  observedAtUptimeNanoseconds: observed,
                  notBeforeUptimeNanoseconds:
                    lastObservedUptimeNanoseconds
              )
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "deadline_or_clock_\(label)"
            )
        }
        lastObservedUptimeNanoseconds = observed
        return observed
    }
}

private struct PrimeValidationDriverV2FixedProbePolicy {
    enum Root: Equatable {
        case prime
        case companion
    }

    enum Image: Equatable {
        case git
        case swiftFrontend
    }

    static let containmentMode =
        "dedicated_group_within_supervisor_session"
    static let requiredSpawnFlags: UInt16 = 0x408e
    static let deadlineNanoseconds: UInt64 = 30_000_000_000
    static let standardErrorMaximumByteCount: UInt64 = 64 * 1024
    static let drainChunkByteCount = 64 * 1024
    static let treeOrStatusMaximumByteCount: UInt64 = 16 * 1024 * 1024
    static let primePathspecs = [
        ".gitignore",
        ".swiftpm/configuration/mirrors.json",
        "LICENSE",
        "Package.resolved",
        "Package.swift",
        "README.md",
        "Sources",
        "THIRD_PARTY_NOTICES.md",
        "Tests",
        "docs",
    ]
    static let gitPrefix = [
        "--no-pager",
        "--no-optional-locks",
        "--no-replace-objects",
        "--no-lazy-fetch",
        "--literal-pathspecs",
        "--git-dir=.git",
        "--work-tree=.",
        "-c", "core.fsmonitor=false",
        "-c", "core.untrackedCache=false",
        "-c", "submodule.recurse=false",
        "-c", "core.hooksPath=/dev/null",
    ]

    let ordinal: Int
    let role: PrimeValidationDriverV2FixedProbeRole
    let root: Root
    let image: Image
    let logicalArgumentZero: String
    let arguments: [String]
    let standardOutputMaximumByteCount: UInt64

    var expectedStandardError: Data {
        // This pinned Swift driver reports its version on stderr, without a
        // newline. Preserve the two raw streams and reject any other text.
        role == .swiftVersion
            ? Data("swift-driver version: 1.148.6 ".utf8)
            : Data()
    }

    var leafBase: String {
        String(format: "%02d-%@", ordinal, role.rawValue.replacingOccurrences(
            of: "_", with: "-"
        ))
    }

    static func environment(
        toolchain: PrimeValidationSwiftPMToolchainObservation
    ) -> [(String, String)] {
        [
            ("DEVELOPER_DIR", toolchain.developerDirectory.canonicalAbsolutePath),
            ("LANG", "C"),
            ("LC_ALL", "C"),
            ("SDKROOT", toolchain.sdkRoot.canonicalAbsolutePath),
            ("TERM", "dumb"),
        ]
    }

    static func orderedRoles(
        primeHEAD: String?,
        companionHEAD: String?
    ) throws -> [Self] {
        func git(
            _ ordinal: Int,
            _ role: PrimeValidationDriverV2FixedProbeRole,
            _ root: Root,
            _ suffix: [String],
            _ cap: UInt64
        ) -> Self {
            Self(
                ordinal: ordinal,
                role: role,
                root: root,
                image: .git,
                logicalArgumentZero: "git",
                arguments: gitPrefix + suffix,
                standardOutputMaximumByteCount: cap
            )
        }
        func swift(
            _ ordinal: Int,
            _ role: PrimeValidationDriverV2FixedProbeRole,
            _ arguments: [String],
            _ cap: UInt64
        ) -> Self {
            Self(
                ordinal: ordinal,
                role: role,
                root: .prime,
                image: .swiftFrontend,
                logicalArgumentZero: "swift",
                arguments: arguments,
                standardOutputMaximumByteCount: cap
            )
        }
        let status = [
            "status", "--porcelain=v2", "-z",
            "--untracked-files=all", "--ignored=matching",
            "--ignore-submodules=none", "--no-renames",
        ]
        var values = [
            git(1, .primeHeadPre, .prime,
                ["rev-parse", "--verify", "HEAD^{commit}"], 128),
            git(2, .primeObjectFormat, .prime,
                ["rev-parse", "--show-object-format"], 5),
            git(3, .primeStatusPre, .prime, status,
                treeOrStatusMaximumByteCount),
        ]
        if let primeHEAD {
            values += [
                git(4, .primeTreeDiscovery, .prime,
                    ["ls-tree", "-r", "-z", "--full-tree", primeHEAD,
                     "--"] + primePathspecs,
                    treeOrStatusMaximumByteCount),
                git(5, .primeTreeReplay, .prime,
                    ["ls-tree", "-r", "-z", "--full-tree", primeHEAD,
                     "--"] + primePathspecs,
                    treeOrStatusMaximumByteCount),
                git(6, .primeStatusPost, .prime, status,
                    treeOrStatusMaximumByteCount),
                git(7, .primeHeadPost, .prime,
                    ["rev-parse", "--verify", "HEAD^{commit}"], 128),
                git(8, .companionHeadPre, .companion,
                    ["rev-parse", "--verify", "HEAD^{commit}"], 128),
                git(9, .companionObjectFormat, .companion,
                    ["rev-parse", "--show-object-format"], 5),
                git(10, .companionStatusPre, .companion, status,
                    treeOrStatusMaximumByteCount),
            ]
        }
        if let companionHEAD {
            values += [
                git(11, .companionTreeDiscovery, .companion,
                    ["ls-tree", "-r", "-z", "--full-tree", companionHEAD,
                     "--"], treeOrStatusMaximumByteCount),
                git(12, .companionTreeReplay, .companion,
                    ["ls-tree", "-r", "-z", "--full-tree", companionHEAD,
                     "--"], treeOrStatusMaximumByteCount),
                git(13, .companionStatusPost, .companion, status,
                    treeOrStatusMaximumByteCount),
                git(14, .companionHeadPost, .companion,
                    ["rev-parse", "--verify", "HEAD^{commit}"], 128),
                swift(15, .swiftVersion, ["--version"], 16 * 1024),
                swift(16, .swiftTargetInfo,
                    ["-print-target-info"], 64 * 1024),
            ]
        }
        return values
    }
}

private struct PrimeValidationDriverV2FixedProbeGitDirectoryObservation:
    Equatable,
    Encodable
{
    let absolutePath: String
    let deviceID: UInt64
    let inode: UInt64
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let permissionMode: UInt16
}

private final class PrimeValidationDriverV2FixedProbeHeldGitDirectory {
    private(set) var descriptor: Int32
    let rootDescriptor: Int32
    let observation: PrimeValidationDriverV2FixedProbeGitDirectoryObservation

    init(
        rootDescriptor: Int32,
        rootPath: String,
        requiredDeviceID: UInt64? = nil,
        requiredInode: UInt64? = nil
    ) throws {
        let opened = ".git".withCString {
            openat(
                rootDescriptor,
                $0,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard opened >= 3 else {
            if opened >= 0 { _ = Darwin.close(opened) }
            throw primeValidationDriverV2FixedProbeRejected(
                "git_directory_open_\(errno)"
            )
        }
        descriptor = opened
        self.rootDescriptor = rootDescriptor
        var status = stat()
        guard fstat(opened, &status) == 0,
              status.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              status.st_dev != 0,
              status.st_ino > 0,
              status.st_uid == geteuid(),
              status.st_mode & mode_t(0o7777) != 0,
              status.st_mode & mode_t(0o022) == 0,
              fcntl(opened, F_GETFD) & FD_CLOEXEC != 0
        else {
            _ = Darwin.close(opened)
            descriptor = -1
            throw primeValidationDriverV2FixedProbeRejected(
                "git_directory_metadata"
            )
        }
        let deviceID = UInt64(bitPattern: Int64(status.st_dev))
        guard (requiredDeviceID == nil || requiredDeviceID == deviceID),
              (requiredInode == nil || requiredInode == UInt64(status.st_ino))
        else {
            _ = Darwin.close(opened)
            descriptor = -1
            throw primeValidationDriverV2FixedProbeRejected(
                "git_directory_gate_c_join"
            )
        }
        observation = .init(
            absolutePath: rootPath + "/.git",
            deviceID: deviceID,
            inode: UInt64(status.st_ino),
            ownerUserID: status.st_uid,
            ownerGroupID: status.st_gid,
            permissionMode: UInt16(status.st_mode & mode_t(0o7777))
        )
        try revalidate()
    }

    deinit {
        if descriptor >= 3 { _ = Darwin.close(descriptor) }
    }

    func revalidate() throws {
        var held = stat()
        var named = stat()
        let namedResult = ".git".withCString {
            fstatat(rootDescriptor, $0, &named, AT_SYMLINK_NOFOLLOW)
        }
        guard descriptor >= 3,
              fstat(descriptor, &held) == 0,
              namedResult == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              UInt64(bitPattern: Int64(held.st_dev)) == observation.deviceID,
              UInt64(held.st_ino) == observation.inode,
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              held.st_uid == observation.ownerUserID,
              held.st_gid == observation.ownerGroupID,
              UInt16(held.st_mode & mode_t(0o7777))
                == observation.permissionMode,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "git_directory_revalidation"
            )
        }
    }
}

private struct PrimeValidationDriverV2FixedProbeJournalLeaf {
    let observation:
        PrimeValidationDriverV2FixedProbeJournalLeafObservation
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let permissionMode: UInt16
    let linkCount: UInt64
    let modificationTimeSeconds: Int64
    let modificationTimeNanoseconds: Int64
    let statusChangeTimeSeconds: Int64
    let statusChangeTimeNanoseconds: Int64
}

private struct PrimeValidationDriverV2FixedProbeJournalMechanicsTestRecord:
    Encodable
{
    let schema = "prime_driver_v2_gate_e_journal_mechanics_test_v1"
    let ordinal: Int
    let leaf: String
    let predecessorSHA256: String
}

private final class PrimeValidationDriverV2FixedProbeJournal {
    static let siblingSuffix = ".driver-v2-gate-e-journal"
    static let prestartLeaf = "gate-e-prestart.json"
    static let rawTerminalLeaf = "gate-e-raw-terminal.json"
    static let maximumLeafByteCount = 64 * 1024

    private let root: PrimeArtifactRoot
    private(set) var descriptor: Int32
    let absolutePath: String
    private var expectedRootIdentity: PrimeArtifactRootIdentity
    private var leaves:
        [String: PrimeValidationDriverV2FixedProbeJournalLeaf] = [:]
    private var heldLeafDescriptors: [String: Int32] = [:]

    init(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    ) throws {
        let admission = retainedState.admission
        let workspace = admission.workspaceRoot.observation
        let path = workspace.canonicalAbsolutePath + Self.siblingSuffix
        let protectedPaths = [
            admission.primeRepository.observation.canonicalAbsolutePath,
            admission.companionRepository.observation.canonicalAbsolutePath,
            workspace.canonicalAbsolutePath,
            admission.evidenceRoot.observation.canonicalAbsolutePath,
            admission.leaseDirectory.observation.canonicalAbsolutePath,
        ]
        guard path.utf8.count <= Int(PATH_MAX) - 1,
              protectedPaths.allSatisfy({ Self.disjoint(path, $0) }),
              try PrimeSecureChildPath.canonicalPath(path) == path
        else {
            throw primeValidationDriverV2FixedProbeRejected("journal_path")
        }
        let openedRoot: PrimeArtifactRoot
        do {
            openedRoot = try PrimeArtifactRoot(
                directoryURL: URL(fileURLWithPath: path, isDirectory: true)
            )
            try openedRoot.requirePrivateRootMode()
            try openedRoot.requireEmpty()
        } catch {
            throw primeValidationDriverV2FixedProbeRejected("journal_root")
        }
        root = openedRoot
        absolutePath = path
        descriptor = try openedRoot
            .duplicateTrustedRootDescriptorForInventory()
        do {
            _ = try PrimeNativeNeuralGateHeldSourceClosure.requireLocalAPFS(
                rootDescriptor: descriptor
            )
            expectedRootIdentity = try openedRoot.verifiedRootIdentity()
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_filesystem_or_identity"
            )
        }
        guard expectedRootIdentity.ownerUserID == geteuid(),
              expectedRootIdentity.ownerGroupID == workspace.ownerGroupID,
              expectedRootIdentity.actualMode == UInt16(0o700),
              expectedRootIdentity.linkCount == 2,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_metadata"
            )
        }
        try revalidate()
    }

    deinit {
        for held in heldLeafDescriptors.values where held >= 3 {
            _ = Darwin.close(held)
        }
        if descriptor >= 3 { _ = Darwin.close(descriptor) }
    }

    var leafCount: Int { leaves.count }
    var rootIdentity: PrimeArtifactRootIdentity { expectedRootIdentity }

    func observation(
        for leaf: String
    ) throws -> PrimeValidationDriverV2FixedProbeJournalLeafObservation {
        guard let value = leaves[leaf] else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_missing_leaf"
            )
        }
        return value.observation
    }

    /// Publishes the exact frozen 34-leaf namespace through the production
    /// journal implementation without authorizing or materializing a child.
    func exerciseMechanicsForTesting() throws
        -> PrimeValidationDriverV2FixedProbeJournalMechanicsTestObservation
    {
        guard leaves.isEmpty, heldLeafDescriptors.isEmpty else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_test_initial_state"
            )
        }
        var predecessorSHA256 = String(repeating: "0", count: 64)
        var orderedObservations:
            [PrimeValidationDriverV2FixedProbeJournalLeafObservation] = []
        orderedObservations.reserveCapacity(Self.allowedLeaves.count)
        for (index, leaf) in Self.allowedLeaves.enumerated() {
            let observation = try publish(
                PrimeValidationDriverV2FixedProbeJournalMechanicsTestRecord(
                    ordinal: index + 1,
                    leaf: leaf,
                    predecessorSHA256: predecessorSHA256
                ),
                leaf: leaf
            )
            orderedObservations.append(observation)
            predecessorSHA256 = observation.sha256
        }
        try revalidate()
        let currentRootIdentity = try root.verifiedRootIdentity()
        let orderedStoredLeaves = try Self.allowedLeaves.map { leaf in
            guard let value = leaves[leaf] else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "journal_test_missing_leaf"
                )
            }
            return value
        }
        guard orderedObservations.count == Self.allowedLeaves.count,
              orderedObservations.count == 34,
              currentRootIdentity == expectedRootIdentity,
              currentRootIdentity.linkCount
                == UInt64(2 + orderedObservations.count),
              heldLeafDescriptors.count == orderedObservations.count
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_test_terminal_state"
            )
        }
        return PrimeValidationDriverV2FixedProbeJournalMechanicsTestObservation(
            orderedLeaves: orderedObservations,
            leafPermissionModes:
                orderedStoredLeaves.map(\.permissionMode),
            leafLinkCounts: orderedStoredLeaves.map(\.linkCount),
            rootLinkCount: currentRootIdentity.linkCount,
            heldLeafDescriptorCount: heldLeafDescriptors.count,
            spawnedChildCount: 0
        )
    }

    func publish<Value: Encodable>(
        _ value: Value,
        leaf: String
    ) throws -> PrimeValidationDriverV2FixedProbeJournalLeafObservation {
        try revalidate()
        guard Self.allowedLeaves.contains(leaf),
              leaves[leaf] == nil,
              leaf == Self.allowedLeaves[leaves.count]
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_order"
            )
        }
        var data: Data
        do {
            data = try PrimeCanonicalJSON.encode(value)
        } catch {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_canonical_encoding"
            )
        }
        data.append(0x0a)
        guard !data.isEmpty,
              data.count <= Self.maximumLeafByteCount
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_size"
            )
        }

        let opened = leaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                mode_t(0o600)
            )
        }
        guard opened >= 3 else {
            if opened >= 0 { _ = Darwin.close(opened) }
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_open_\(errno)"
            )
        }
        defer { _ = Darwin.close(opened) }
        var created = stat()
        guard fstat(opened, &created) == 0,
              created.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              created.st_uid == geteuid(),
              created.st_gid == expectedRootIdentity.ownerGroupID,
              created.st_nlink == 1,
              created.st_mode & mode_t(0o7777) == mode_t(0o600),
              created.st_size == 0,
              fcntl(opened, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_created_metadata"
            )
        }
        try Self.writeAll(data, descriptor: opened)
        try Self.synchronize(opened, detail: "journal_leaf_data")
        guard fchmod(opened, mode_t(0o400)) == 0 else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_chmod_\(errno)"
            )
        }
        try Self.synchronize(opened, detail: "journal_leaf_read_only")
        try Self.synchronize(descriptor, detail: "journal_namespace")

        var frozen = stat()
        guard fstat(opened, &frozen) == 0,
              frozen.st_dev == created.st_dev,
              frozen.st_ino == created.st_ino,
              frozen.st_uid == created.st_uid,
              frozen.st_gid == created.st_gid,
              frozen.st_nlink == 1,
              frozen.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              frozen.st_mode & mode_t(0o7777) == mode_t(0o400),
              frozen.st_size == off_t(data.count)
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_frozen_metadata"
            )
        }
        let rebound = leaf.withCString {
            openat(descriptor, $0, O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK)
        }
        guard rebound >= 3 else {
            if rebound >= 0 { _ = Darwin.close(rebound) }
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_reopen_\(errno)"
            )
        }
        var retainRebound = false
        defer {
            if !retainRebound { _ = Darwin.close(rebound) }
        }
        let reboundData: Data
        do {
            reboundData = try PrimeSecureChildPath.readExact(
                descriptor: rebound,
                byteCount: data.count
            )
        } catch {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_readback"
            )
        }
        var reboundStatus = stat()
        guard fstat(rebound, &reboundStatus) == 0,
              Self.sameLeaf(frozen, reboundStatus),
              fcntl(rebound, F_GETFL) & O_ACCMODE == O_RDONLY,
              fcntl(rebound, F_GETFD) & FD_CLOEXEC != 0,
              reboundData == data
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_rebound"
            )
        }
        let observation =
            PrimeValidationDriverV2FixedProbeJournalLeafObservation(
                leaf: leaf,
                byteCount: UInt64(data.count),
                sha256: PrimeSHA256.hexDigest(of: data),
                deviceID: UInt64(bitPattern: Int64(frozen.st_dev)),
                inode: UInt64(frozen.st_ino)
            )
        leaves[leaf] = PrimeValidationDriverV2FixedProbeJournalLeaf(
            observation: observation,
            ownerUserID: frozen.st_uid,
            ownerGroupID: frozen.st_gid,
            permissionMode:
                UInt16(frozen.st_mode & mode_t(0o7777)),
            linkCount: UInt64(frozen.st_nlink),
            modificationTimeSeconds:
                Int64(frozen.st_mtimespec.tv_sec),
            modificationTimeNanoseconds:
                Int64(frozen.st_mtimespec.tv_nsec),
            statusChangeTimeSeconds:
                Int64(frozen.st_ctimespec.tv_sec),
            statusChangeTimeNanoseconds:
                Int64(frozen.st_ctimespec.tv_nsec)
        )
        heldLeafDescriptors[leaf] = rebound
        retainRebound = true
        try acceptAuthorizedRootTransition()
        return observation
    }

    func revalidate() throws {
        guard leaves.count <= Self.allowedLeaves.count,
              Array(Self.allowedLeaves.prefix(leaves.count))
                == leaves.keys.sorted(by: Self.allowedOrder)
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_prefix"
            )
        }
        let current = try root.verifiedRootIdentity()
        guard current == expectedRootIdentity,
              current.linkCount == UInt64(2 + leaves.count),
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0,
              try inventory() == Set(leaves.keys)
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_root_revalidation"
            )
        }
        let rebound = try PrimeArtifactRoot(
            directoryURL: URL(
                fileURLWithPath: absolutePath,
                isDirectory: true
            )
        ).verifiedRootIdentity()
        guard rebound == current else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_named_rebound"
            )
        }
        for value in leaves.values { try verify(value) }
    }

    private func acceptAuthorizedRootTransition() throws {
        guard try inventory() == Set(leaves.keys),
              leaves.count == heldLeafDescriptors.count
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_transition_inventory"
            )
        }
        let before = try root.verifiedRootIdentity()
        guard Self.sameStableRoot(
            before,
            expectedRootIdentity,
            expectedLeafCount: leaves.count
        ) else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_transition_root"
            )
        }
        for value in leaves.values { try verify(value) }
        let after = try root.verifiedRootIdentity()
        let rebound = try PrimeArtifactRoot(
            directoryURL: URL(
                fileURLWithPath: absolutePath,
                isDirectory: true
            )
        ).verifiedRootIdentity()
        guard after == before, rebound == after else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_transition_unstable"
            )
        }
        expectedRootIdentity = after
    }

    private func verify(
        _ leaf: PrimeValidationDriverV2FixedProbeJournalLeaf
    ) throws {
        guard let descriptor = heldLeafDescriptors[leaf.observation.leaf]
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_descriptor"
            )
        }
        var held = stat()
        var named = stat()
        let namedResult = leaf.observation.leaf.withCString {
            fstatat(self.descriptor, $0, &named, AT_SYMLINK_NOFOLLOW)
        }
        guard fstat(descriptor, &held) == 0,
              namedResult == 0,
              Self.sameLeaf(held, named),
              UInt64(bitPattern: Int64(held.st_dev))
                == leaf.observation.deviceID,
              UInt64(held.st_ino) == leaf.observation.inode,
              held.st_uid == leaf.ownerUserID,
              held.st_gid == leaf.ownerGroupID,
              UInt16(held.st_mode & mode_t(0o7777))
                == leaf.permissionMode,
              UInt64(held.st_nlink) == leaf.linkCount,
              UInt64(held.st_size) == leaf.observation.byteCount,
              Int64(held.st_mtimespec.tv_sec)
                == leaf.modificationTimeSeconds,
              Int64(held.st_mtimespec.tv_nsec)
                == leaf.modificationTimeNanoseconds,
              Int64(held.st_ctimespec.tv_sec)
                == leaf.statusChangeTimeSeconds,
              Int64(held.st_ctimespec.tv_nsec)
                == leaf.statusChangeTimeNanoseconds,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_identity"
            )
        }
        let data = try PrimeSecureChildPath.readExact(
            descriptor: descriptor,
            byteCount: Int(leaf.observation.byteCount)
        )
        guard PrimeSHA256.hexDigest(of: data) == leaf.observation.sha256
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_leaf_digest"
            )
        }
    }

    private func inventory() throws -> Set<String> {
        let duplicate = fcntl(descriptor, F_DUPFD_CLOEXEC, 3)
        guard duplicate >= 3,
              lseek(duplicate, 0, SEEK_SET) >= 0,
              let directory = fdopendir(duplicate)
        else {
            if duplicate >= 0 { _ = Darwin.close(duplicate) }
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_inventory_open"
            )
        }
        defer { _ = closedir(directory) }
        var values = Set<String>()
        errno = 0
        while let entry = readdir(directory) {
            let name = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(
                    to: CChar.self,
                    capacity: Int(MAXNAMLEN) + 1
                ) { String(cString: $0) }
            }
            if name != "." && name != ".." {
                guard Self.allowedLeafSet.contains(name),
                      values.insert(name).inserted
                else {
                    throw primeValidationDriverV2FixedProbeRejected(
                        "journal_inventory_entry"
                    )
                }
            }
            errno = 0
        }
        guard errno == 0 else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_inventory_read_\(errno)"
            )
        }
        return values
    }

    private static let roleBases = [
        "01-prime-head-pre",
        "02-prime-object-format",
        "03-prime-status-pre",
        "04-prime-tree-discovery",
        "05-prime-tree-replay",
        "06-prime-status-post",
        "07-prime-head-post",
        "08-companion-head-pre",
        "09-companion-object-format",
        "10-companion-status-pre",
        "11-companion-tree-discovery",
        "12-companion-tree-replay",
        "13-companion-status-post",
        "14-companion-head-post",
        "15-swift-version",
        "16-swift-target-info",
    ]
    private static let allowedLeaves = [prestartLeaf]
        + roleBases.flatMap { ["\($0)-start.json", "\($0)-terminal.json"] }
        + [rawTerminalLeaf]
    private static let allowedLeafSet = Set(allowedLeaves)

    private static func allowedOrder(_ lhs: String, _ rhs: String) -> Bool {
        guard let left = allowedLeaves.firstIndex(of: lhs),
              let right = allowedLeaves.firstIndex(of: rhs)
        else { return lhs < rhs }
        return left < right
    }

    private static func sameLeaf(_ lhs: stat, _ rhs: stat) -> Bool {
        lhs.st_dev == rhs.st_dev
            && lhs.st_ino == rhs.st_ino
            && lhs.st_mode == rhs.st_mode
            && lhs.st_uid == rhs.st_uid
            && lhs.st_gid == rhs.st_gid
            && lhs.st_nlink == rhs.st_nlink
            && lhs.st_size == rhs.st_size
            && lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec
            && lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec
            && lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec
            && lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
    }

    private static func sameStableRoot(
        _ current: PrimeArtifactRootIdentity,
        _ previous: PrimeArtifactRootIdentity,
        expectedLeafCount: Int
    ) -> Bool {
        current.deviceID == previous.deviceID
            && current.inode == previous.inode
            && current.ownerUserID == previous.ownerUserID
            && current.ownerGroupID == previous.ownerGroupID
            && current.actualMode == previous.actualMode
            && current.linkCount == UInt64(2 + expectedLeafCount)
    }

    private static func writeAll(
        _ data: Data,
        descriptor: Int32
    ) throws {
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let written = Darwin.write(
                    descriptor,
                    bytes.baseAddress!.advanced(by: offset),
                    bytes.count - offset
                )
                if written < 0 && errno == EINTR { continue }
                guard written > 0 else {
                    throw primeValidationDriverV2FixedProbeRejected(
                        "journal_write_\(errno)"
                    )
                }
                offset += written
            }
        }
    }

    private static func synchronize(
        _ descriptor: Int32,
        detail: String
    ) throws {
        guard fsync(descriptor) == 0,
              fcntl(descriptor, F_FULLFSYNC) == 0
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "\(detail)_sync_\(errno)"
            )
        }
    }

    private static func disjoint(_ lhs: String, _ rhs: String) -> Bool {
        lhs != rhs
            && !lhs.hasPrefix(rhs + "/")
            && !rhs.hasPrefix(lhs + "/")
    }
}

private struct PrimeValidationDriverV2FixedProbePolicyRoleDigestRecord:
    Encodable
{
    let ordinal: Int
    let role: String
    let root: String
    let image: String
    let logicalArgumentZero: String
    let arguments: [String]
    let standardOutputMaximumByteCount: UInt64
}

private struct PrimeValidationDriverV2FixedProbePolicyDigestRecord:
    Encodable
{
    let schema = "prime_driver_v2_gate_e_fixed_policy_v2"
    let containmentMode: String
    let requiredSpawnFlags: UInt16
    let orderedRoles:
        [PrimeValidationDriverV2FixedProbePolicyRoleDigestRecord]
    let primePathspecs: [String]
    let environment: [String]
    let deadlineNanoseconds: UInt64
    let standardErrorMaximumByteCount: UInt64
    let drainChunkByteCount: Int
}

private struct PrimeValidationDriverV2FixedProbeIdentityRecord:
    Encodable
{
    let role: String
    let absolutePath: String
    let deviceID: UInt64
    let inode: UInt64
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let permissionMode: UInt16
    let linkCount: UInt64
    let byteCount: UInt64
    let sha256: String
    let modificationSeconds: Int64
    let modificationNanoseconds: Int64
    let statusChangeSeconds: Int64
    let statusChangeNanoseconds: Int64
}

private struct PrimeValidationDriverV2FixedProbePrestartRecord:
    Encodable
{
    let schema = "prime_driver_v2_gate_e_prestart_v2"
    let stage = "GATE-E"
    let supervisorProcessIdentifier: Int32
    let supervisorSessionIdentifier: Int32
    let supervisorProcessGroupIdentifier: Int32
    let embeddedPrimeSourceIdentitySHA256: String
    let policySHA256: String
    let environmentSHA256: String
    let journalAbsolutePath: String
    let primeRootDeviceID: UInt64
    let primeRootInode: UInt64
    let companionRootDeviceID: UInt64
    let companionRootInode: UInt64
    let primeGitDeviceID: UInt64
    let primeGitInode: UInt64
    let primeGitAbsolutePath: String
    let primeGitOwnerUserID: UInt32
    let primeGitOwnerGroupID: UInt32
    let primeGitPermissionMode: UInt16
    let companionGitDeviceID: UInt64
    let companionGitInode: UInt64
    let companionGitAbsolutePath: String
    let companionGitOwnerUserID: UInt32
    let companionGitOwnerGroupID: UInt32
    let companionGitPermissionMode: UInt16
    let gitExecutableSHA256: String
    let swiftFrontendSHA256: String
    let supervisorExecutableSHA256: String
    let journalIdentity:
        PrimeValidationDriverV2FixedProbeIdentityRecord
    let rootIdentities:
        [PrimeValidationDriverV2FixedProbeIdentityRecord]
    let imageIdentities:
        [PrimeValidationDriverV2FixedProbeIdentityRecord]
    let deadlineStartedAtUptimeNanoseconds: UInt64
    let deadlineExpiresAtUptimeNanoseconds: UInt64
    let orderedRoles: [String]
    let combinedSourceWatcherDescriptorCount: Int
}

private struct PrimeValidationDriverV2FixedProbeStartRecord:
    Encodable
{
    let schema = "prime_driver_v2_gate_e_child_start_v2"
    let stage = "GATE-E"
    let ordinal: Int
    let role: String
    let prestartSHA256: String
    let predecessorKind: String
    let predecessorSHA256: String
    let processIdentifier: Int32
    let sessionIdentifier: Int32
    let processGroupIdentifier: Int32
    let appliedSpawnFlags: UInt16
    let spawnReturnCode: Int32
    let spawnReturnedUptimeNanoseconds: UInt64
    let deadlineStartedAtUptimeNanoseconds: UInt64
    let deadlineExpiresAtUptimeNanoseconds: UInt64
    let workingDirectoryDeviceID: UInt64
    let workingDirectoryInode: UInt64
    let workingDirectoryAbsolutePath: String
    let childWorkingDirectoryDeviceID: UInt64
    let childWorkingDirectoryInode: UInt64
    let executableDeviceID: UInt64
    let executableInode: UInt64
    let executableAbsolutePath: String
    let executableByteCount: UInt64
    let executableSHA256: String
    let logicalArgumentZero: String
    let arguments: [String]
    let argumentVectorSHA256: String
    let mappedExecutablePathTelemetry: String
    let mappedExecutableQueryCount: Int
    let mappedExecutableTerminalErrno: Int32
    let exactWorkingDirectoryJoin: Bool
    let exactMappedExecutableJoin: Bool
    let preResumeContinuityChecked: Bool
}

private struct PrimeValidationDriverV2FixedProbeArgumentVectorRecord:
    Encodable
{
    let logicalArgumentZero: String
    let arguments: [String]
}

private struct PrimeValidationDriverV2FixedProbeTerminalRecord:
    Encodable
{
    let schema = "prime_driver_v2_gate_e_child_terminal_v2"
    let stage = "GATE-E"
    let ordinal: Int
    let role: String
    let startLeafSHA256: String
    let supervisorProcessIdentifier: Int32
    let supervisorSessionIdentifier: Int32
    let supervisorProcessGroupIdentifier: Int32
    let processIdentifier: Int32
    let sessionIdentifier: Int32
    let processGroupIdentifier: Int32
    let deathObservedUptimeNanoseconds: UInt64
    let preReapProcessGroupMemberIdentifiers: [Int32]
    let startPublishedUptimeNanoseconds: UInt64
    let preResumeContinuityCheckpointUptimeNanoseconds: UInt64
    let resumedAtUptimeNanoseconds: UInt64
    let requestedWaitProcessIdentifier: Int32
    let returnedWaitProcessIdentifier: Int32
    let waitOptions: Int32
    let rawWaitStatus: Int32
    let waitReturnedUptimeNanoseconds: UInt64
    let exitedNormally: Bool
    let exitStatus: Int32
    let terminationSignal: Int32
    let coreDumped: Bool
    let standardOutputByteCount: UInt64
    let standardOutputSHA256: String
    let standardOutputReachedEOF: Bool
    let standardOutputTerminalReason: String
    let standardOutputOverflowed: Bool
    let standardOutputWorkerFinished: Bool
    let standardOutputReadErrorNumber: Int32
    let standardOutputWriteErrorNumber: Int32
    let standardOutputFinalizationErrorNumber: Int32
    let standardOutputCloseErrorNumber: Int32
    let standardOutputDescriptorsClosed: Bool
    let standardErrorByteCount: UInt64
    let standardErrorSHA256: String
    let standardErrorReachedEOF: Bool
    let standardErrorTerminalReason: String
    let standardErrorOverflowed: Bool
    let standardErrorWorkerFinished: Bool
    let standardErrorReadErrorNumber: Int32
    let standardErrorWriteErrorNumber: Int32
    let standardErrorFinalizationErrorNumber: Int32
    let standardErrorCloseErrorNumber: Int32
    let standardErrorDescriptorsClosed: Bool
    let processGroupEmptyAfterReap: Bool
    let postReapContinuityChecked: Bool
}

private struct PrimeValidationDriverV2FixedProbeRawTerminalRecord:
    Encodable
{
    let schema = "prime_driver_v2_gate_e_raw_terminal_v2"
    let stage = "GATE-E"
    let supervisorProcessIdentifier: Int32
    let supervisorSessionIdentifier: Int32
    let supervisorProcessGroupIdentifier: Int32
    let orderedProcessIdentifiers: [Int32]
    let orderedSessionIdentifiers: [Int32]
    let orderedProcessGroupIdentifiers: [Int32]
    let orderedTerminalSHA256Values: [String]
    let primeHEADAgreement: Bool
    let companionHEADAgreement: Bool
    let primeStatusPreEmpty: Bool
    let primeStatusPostEmpty: Bool
    let companionStatusPreEmpty: Bool
    let companionStatusPostEmpty: Bool
    let primeObjectFormat: String
    let companionObjectFormat: String
    let primeTreeReplayEqual: Bool
    let companionTreeReplayEqual: Bool
    let primeHeldEntriesSHA256: String
    let companionHeldEntriesSHA256: String
    let swiftVersionSHA256: String
    let swiftTargetInfoSHA256: String
}

enum PrimeValidationDriverV2FixedProbeExecutor {
    /// Implementation bridge for the facade's zero-argument XCTest seam.
    /// The retained owner is never returned and production images fail closed.
    static func exerciseJournalMechanicsForTesting(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    ) throws
        -> PrimeValidationDriverV2FixedProbeJournalMechanicsTestObservation
    {
        guard !retainedState.productionSupervisorImageEligible else {
            throw primeValidationDriverV2FixedProbeRejected(
                "journal_test_production_image"
            )
        }
        try retainedState.revalidate()
        let journal = try PrimeValidationDriverV2FixedProbeJournal(
            retainedState: retainedState
        )
        let observation = try journal.exerciseMechanicsForTesting()
        try retainedState.revalidate()
        return observation
    }

    /// Projects both trees from the original Gate C owner and exercises the
    /// same all-regular tree guards used by production Gate E. All raw-tree
    /// vectors are closed constants; no caller-controlled process input enters.
    static func exerciseHeldProjectionForTesting(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    ) throws
        -> PrimeValidationDriverV2FixedProbeHeldProjectionTestObservation
    {
        guard !retainedState.productionSupervisorImageEligible else {
            throw primeValidationDriverV2FixedProbeRejected(
                "held_projection_test_production_image"
            )
        }
        let watcherCountBefore =
            retainedState.combinedSourceWatcherDescriptorCount
        let prime = try retainedState.fixedProbePrimeHeldEntries()
        try requireAllRegularHeldEntries(prime, label: "prime")
        let companion = try retainedState.fixedProbeCompanionHeldEntries()
        try requireAllRegularHeldEntries(companion, label: "companion")

        let objectID = String(repeating: "1", count: 40)
        let regularTree = Data(
            "100644 blob \(objectID)\tfixture\u{0}".utf8
        )
        let symbolicLinkTree = Data(
            "120000 blob \(objectID)\tfixture\u{0}".utf8
        )
        let gitlinkTree = Data(
            "160000 commit \(objectID)\tfixture\u{0}".utf8
        )
        try validateRawTreeFraming(
            regularTree,
            role: .primeTreeDiscovery
        )
        let symbolicLinkRejected: Bool
        do {
            try validateRawTreeFraming(
                symbolicLinkTree,
                role: .primeTreeDiscovery
            )
            symbolicLinkRejected = false
        } catch {
            symbolicLinkRejected = true
        }
        let gitlinkRejected: Bool
        do {
            try validateRawTreeFraming(
                gitlinkTree,
                role: .primeTreeDiscovery
            )
            gitlinkRejected = false
        } catch {
            gitlinkRejected = true
        }
        let watcherCountAfter =
            retainedState.combinedSourceWatcherDescriptorCount
        guard watcherCountBefore == watcherCountAfter,
              symbolicLinkRejected,
              gitlinkRejected
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "held_projection_test_terminal_state"
            )
        }
        return PrimeValidationDriverV2FixedProbeHeldProjectionTestObservation(
            primeHeldEntryCount: prime.count,
            companionHeldEntryCount: companion.count,
            primeHeldEntriesSHA256: heldEntriesSHA256(prime),
            companionHeldEntriesSHA256: heldEntriesSHA256(companion),
            combinedSourceWatcherDescriptorCountBefore: watcherCountBefore,
            combinedSourceWatcherDescriptorCountAfter: watcherCountAfter,
            allProjectedEntriesRegular: true,
            regularTreeAccepted: true,
            symbolicLinkTreeRejected: symbolicLinkRejected,
            gitlinkTreeRejected: gitlinkRejected,
            spawnedChildCount: 0
        )
    }

    /// Invokes the production-shared retained portion of Gate E's lightweight
    /// checkpoint. It polls the original Gate C kqueues and creates no child.
    static func revalidateLightweightContinuityForTesting(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    ) throws
        -> PrimeValidationDriverV2FixedProbeLightweightCheckpointTestObservation
    {
        guard !retainedState.productionSupervisorImageEligible else {
            throw primeValidationDriverV2FixedProbeRejected(
                "lightweight_test_production_image"
            )
        }
        let watcherCountBefore =
            retainedState.combinedSourceWatcherDescriptorCount
        try lightweightRetainedCheckpoint(retainedState: retainedState)
        let watcherCountAfter =
            retainedState.combinedSourceWatcherDescriptorCount
        guard watcherCountBefore == watcherCountAfter else {
            throw primeValidationDriverV2FixedProbeRejected(
                "lightweight_test_watcher_count"
            )
        }
        return .init(
            combinedSourceWatcherDescriptorCountBefore: watcherCountBefore,
            combinedSourceWatcherDescriptorCountAfter: watcherCountAfter,
            spawnedChildCount: 0
        )
    }

    @available(macOS 26.0, *)
    static func execute(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    ) throws -> PrimeValidationDriverV2FixedProbeExecutionResult {
        let supervisorProcessIdentifier = Darwin.getpid()
        let supervisorSessionIdentifier = getsid(0)
        let supervisorProcessGroupIdentifier = getpgrp()
        guard supervisorProcessIdentifier > 0,
              supervisorSessionIdentifier == supervisorProcessIdentifier,
              supervisorProcessGroupIdentifier
                == supervisorProcessIdentifier
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "supervisor_session_identity"
            )
        }
        let deadline: PrimeSecureChildPhaseDeadline
        do {
            deadline = try PrimeSecureChildPhaseDeadline(
                startUptimeNanoseconds:
                    DispatchTime.now().uptimeNanoseconds,
                durationNanoseconds:
                    PrimeValidationDriverV2FixedProbePolicy
                    .deadlineNanoseconds
            )
        } catch {
            throw primeValidationDriverV2FixedProbeRejected(
                "deadline_overflow"
            )
        }
        let clock = PrimeValidationDriverV2FixedProbeClock(
            deadline: deadline
        )
        try clock.observeCompletion(label: "entry_before_revalidation")
        try retainedState.revalidate()
        try clock.observeCompletion(label: "entry_after_revalidation")
        let admission = retainedState.admission
        let toolchain = admission.toolchain

        let primeDescriptor = try admission.primeRepository.root
            .duplicateTrustedRootDescriptorForInventory()
        defer { _ = Darwin.close(primeDescriptor) }
        let companionDescriptor = try admission.companionRepository.root
            .duplicateTrustedRootDescriptorForInventory()
        defer { _ = Darwin.close(companionDescriptor) }
        let primeDirectory = try heldDirectory(
            descriptor: primeDescriptor
        )
        let companionDirectory = try heldDirectory(
            descriptor: companionDescriptor
        )
        let primeGit = try
            PrimeValidationDriverV2FixedProbeHeldGitDirectory(
                rootDescriptor: primeDescriptor,
                rootPath: admission.primeRepository
                    .observation.canonicalAbsolutePath,
                requiredDeviceID: primeDirectory.deviceID
            )
        let companionRecordedGitDeviceID = UInt64(
            bitPattern: Int64(
                admission.companionContentSnapshot
                    .excludedRootGitDirectoryDeviceID
            )
        )
        guard companionRecordedGitDeviceID == companionDirectory.deviceID
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "companion_git_root_device"
            )
        }
        let companionGit = try
            PrimeValidationDriverV2FixedProbeHeldGitDirectory(
                rootDescriptor: companionDescriptor,
                rootPath: admission.companionRepository
                    .observation.canonicalAbsolutePath,
                requiredDeviceID: companionRecordedGitDeviceID,
                requiredInode:
                    admission.companionContentSnapshot
                    .excludedRootGitDirectoryInode
            )
        let journal = try PrimeValidationDriverV2FixedProbeJournal(
            retainedState: retainedState
        )
        let environment =
            PrimeValidationDriverV2FixedProbePolicy.environment(
                toolchain: toolchain.observation
            )
        let environmentEntries = environment.map {
            PrimeValidationSwiftPMDeterministicEnvironmentEntry(
                key: $0.0,
                value: $0.1
            )
        }
        let frozenPolicies = try
            PrimeValidationDriverV2FixedProbePolicy.orderedRoles(
                primeHEAD: "<validated-prime-head-from-role-01>",
                companionHEAD:
                    "<validated-companion-head-from-role-08>"
            )
        let orderedRoleNames = frozenPolicies.map { $0.role.rawValue }
        guard orderedRoleNames.count == 16,
              retainedState.combinedSourceWatcherDescriptorCount
                == PrimeValidationDriverV2SealedSourceTopology.combinedWatcherDescriptorCount
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "frozen_topology_or_role_order"
            )
        }
        let policyRecord = PrimeValidationDriverV2FixedProbePolicyDigestRecord(
            containmentMode:
                PrimeValidationDriverV2FixedProbePolicy.containmentMode,
            requiredSpawnFlags:
                PrimeValidationDriverV2FixedProbePolicy.requiredSpawnFlags,
            orderedRoles: frozenPolicies.map {
                PrimeValidationDriverV2FixedProbePolicyRoleDigestRecord(
                    ordinal: $0.ordinal,
                    role: $0.role.rawValue,
                    root: $0.root == .prime ? "prime" : "companion",
                    image: $0.image == .git ? "git" : "swift_frontend",
                    logicalArgumentZero: $0.logicalArgumentZero,
                    arguments: $0.arguments,
                    standardOutputMaximumByteCount:
                        $0.standardOutputMaximumByteCount
                )
            },
            primePathspecs:
                PrimeValidationDriverV2FixedProbePolicy.primePathspecs,
            environment: environment.map { "\($0.0)=\($0.1)" },
            deadlineNanoseconds:
                PrimeValidationDriverV2FixedProbePolicy.deadlineNanoseconds,
            standardErrorMaximumByteCount:
                PrimeValidationDriverV2FixedProbePolicy
                .standardErrorMaximumByteCount,
            drainChunkByteCount:
                PrimeValidationDriverV2FixedProbePolicy.drainChunkByteCount
        )
        let policyData = try PrimeCanonicalJSON.encode(policyRecord)
        let environmentData = Data(
            environment.flatMap { "\($0.0)=\($0.1)\u{0}".utf8 }
        )
        try lightweightCheckpoint(
            retainedState: retainedState,
            clock: clock,
            primeDirectory: primeDirectory,
            companionDirectory: companionDirectory,
            primeGit: primeGit,
            companionGit: companionGit,
            journal: journal
        )
        try clock.observeCompletion(label: "prestart_before_publication")
        let prestart = try journal.publish(
            PrimeValidationDriverV2FixedProbePrestartRecord(
                supervisorProcessIdentifier: supervisorProcessIdentifier,
                supervisorSessionIdentifier: supervisorSessionIdentifier,
                supervisorProcessGroupIdentifier:
                    supervisorProcessGroupIdentifier,
                embeddedPrimeSourceIdentitySHA256:
                    PrimeEmbeddedBuildProvenance.sourceIdentitySHA256,
                policySHA256: PrimeSHA256.hexDigest(of: policyData),
                environmentSHA256:
                    PrimeSHA256.hexDigest(of: environmentData),
                journalAbsolutePath: journal.absolutePath,
                primeRootDeviceID: primeDirectory.deviceID,
                primeRootInode: primeDirectory.inode,
                companionRootDeviceID: companionDirectory.deviceID,
                companionRootInode: companionDirectory.inode,
                primeGitDeviceID: primeGit.observation.deviceID,
                primeGitInode: primeGit.observation.inode,
                primeGitAbsolutePath: primeGit.observation.absolutePath,
                primeGitOwnerUserID: primeGit.observation.ownerUserID,
                primeGitOwnerGroupID: primeGit.observation.ownerGroupID,
                primeGitPermissionMode: primeGit.observation.permissionMode,
                companionGitDeviceID: companionGit.observation.deviceID,
                companionGitInode: companionGit.observation.inode,
                companionGitAbsolutePath:
                    companionGit.observation.absolutePath,
                companionGitOwnerUserID:
                    companionGit.observation.ownerUserID,
                companionGitOwnerGroupID:
                    companionGit.observation.ownerGroupID,
                companionGitPermissionMode:
                    companionGit.observation.permissionMode,
                gitExecutableSHA256:
                    toolchain.fixedProbeGitExecutable.observation.sha256,
                swiftFrontendSHA256:
                    toolchain.swiftFrontendExecutable.observation.sha256,
                supervisorExecutableSHA256:
                    retainedState.currentProcessObservation.sha256,
                journalIdentity: identityRecord(
                    role: "journal",
                    absolutePath: journal.absolutePath,
                    identity: journal.rootIdentity
                ),
                rootIdentities: [
                    identityRecord(
                        role: "prime_root",
                        observation:
                            admission.primeRepository.observation
                    ),
                    identityRecord(
                        role: "companion_root",
                        observation:
                            admission.companionRepository.observation
                    ),
                    identityRecord(
                        role: "workspace_root",
                        observation: admission.workspaceRoot.observation
                    ),
                    identityRecord(
                        role: "evidence_root",
                        observation: admission.evidenceRoot.observation
                    ),
                    identityRecord(
                        role: "lease_root",
                        observation: admission.leaseDirectory.observation
                    ),
                ],
                imageIdentities: [
                    identityRecord(
                        role: "supervisor",
                        observation:
                            retainedState.currentProcessObservation
                    ),
                    identityRecord(
                        role: "git",
                        observation:
                            toolchain.fixedProbeGitExecutable.observation
                    ),
                    identityRecord(
                        role: "swift_frontend",
                        observation:
                            toolchain.swiftFrontendExecutable.observation
                    ),
                ],
                deadlineStartedAtUptimeNanoseconds:
                    deadline.startUptimeNanoseconds,
                deadlineExpiresAtUptimeNanoseconds:
                    deadline.expiresAtUptimeNanoseconds,
                orderedRoles: orderedRoleNames,
                combinedSourceWatcherDescriptorCount:
                    retainedState.combinedSourceWatcherDescriptorCount
            ),
            leaf: PrimeValidationDriverV2FixedProbeJournal.prestartLeaf
        )
        let prestartPublishedUptimeNanoseconds = try
            clock.observeCompletion(label: "prestart_after_publication")

        var processes:
            [PrimeValidationDriverV2FixedProbeProcessObservation] = []
        var processByRole:
            [PrimeValidationDriverV2FixedProbeRole:
                PrimeValidationDriverV2FixedProbeProcessObservation] = [:]
        var primeHEAD: String?
        var companionHEAD: String?
        var primeHeldEntries:
            [PrimeValidationDriverV2TrackedTreeHeldEntry]?
        var companionHeldEntries:
            [PrimeValidationDriverV2TrackedTreeHeldEntry]?
        var predecessorKind = "prestart"
        var predecessorSHA256 = prestart.sha256
        var childProcessIdentifiers = Set<Int32>()
        var childProcessGroupIdentifiers = Set<Int32>()

        for ordinal in 1 ... 16 {
            guard let policy = try
                PrimeValidationDriverV2FixedProbePolicy.orderedRoles(
                    primeHEAD: primeHEAD,
                    companionHEAD: companionHEAD
                ).first(where: { $0.ordinal == ordinal })
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "policy_state_\(ordinal)"
                )
            }
            let process = try executeChild(
                policy: policy,
                environment: environment,
                environmentEntries: environmentEntries,
                retainedState: retainedState,
                deadline: deadline,
                clock: clock,
                primeDirectory: primeDirectory,
                companionDirectory: companionDirectory,
                primeGit: primeGit,
                companionGit: companionGit,
                journal: journal,
                prestart: prestart,
                supervisorSessionIdentifier:
                    supervisorSessionIdentifier,
                predecessorKind: predecessorKind,
                predecessorSHA256: predecessorSHA256,
                processByRole: processByRole
            )
            guard process.processIdentifier > 0,
                  process.processIdentifier
                    != supervisorProcessIdentifier,
                  process.sessionIdentifier
                    == supervisorSessionIdentifier,
                  process.processGroupIdentifier
                    == process.processIdentifier,
                  childProcessIdentifiers.insert(
                      process.processIdentifier
                  ).inserted,
                  childProcessGroupIdentifiers.insert(
                      process.processGroupIdentifier
                  ).inserted
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "child_session_or_group_\(ordinal)"
                )
            }
            processes.append(process)
            processByRole[policy.role] = process
            predecessorKind = "child_terminal"
            predecessorSHA256 = process.terminalLeaf.sha256
            if policy.role == .primeHeadPre {
                primeHEAD = try parsedHEAD(process.standardOutput)
            } else if policy.role == .companionHeadPre {
                companionHEAD = try parsedHEAD(process.standardOutput)
            }

            if policy.role == .primeTreeDiscovery {
                try clock.observeCompletion(
                    label: "prime_join_before_projection"
                )
                let entries = try retainedState.fixedProbePrimeHeldEntries()
                try requireAllRegularHeldEntries(entries, label: "prime")
                try clock.observeCompletion(
                    label: "prime_join_after_projection"
                )
                try clock.observeCompletion(
                    label: "prime_join_before_revalidation"
                )
                try retainedState.revalidate()
                try clock.observeCompletion(
                    label: "prime_join_after_revalidation"
                )
                primeHeldEntries = entries
                try lightweightCheckpoint(
                    retainedState: retainedState,
                    clock: clock,
                    primeDirectory: primeDirectory,
                    companionDirectory: companionDirectory,
                    primeGit: primeGit,
                    companionGit: companionGit,
                    journal: journal
                )
            } else if policy.role == .companionTreeDiscovery {
                try clock.observeCompletion(
                    label: "companion_join_before_projection"
                )
                let entries = try retainedState
                    .fixedProbeCompanionHeldEntries()
                try requireAllRegularHeldEntries(
                    entries,
                    label: "companion"
                )
                try clock.observeCompletion(
                    label: "companion_join_after_projection"
                )
                try clock.observeCompletion(
                    label: "companion_join_before_revalidation"
                )
                try retainedState.revalidate()
                try clock.observeCompletion(
                    label: "companion_join_after_revalidation"
                )
                companionHeldEntries = entries
                try lightweightCheckpoint(
                    retainedState: retainedState,
                    clock: clock,
                    primeDirectory: primeDirectory,
                    companionDirectory: companionDirectory,
                    primeGit: primeGit,
                    companionGit: companionGit,
                    journal: journal
                )
            }
        }

        guard let primeHeldEntries,
              let companionHeldEntries,
              processes.count == 16,
              processByRole.count == 16,
              childProcessIdentifiers.count == 16,
              childProcessGroupIdentifiers.count == 16
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "terminal_process_set"
            )
        }
        try clock.observeCompletion(label: "terminal_before_revalidation")
        try retainedState.revalidate()
        try clock.observeCompletion(label: "terminal_after_revalidation")
        try lightweightCheckpoint(
            retainedState: retainedState,
            clock: clock,
            primeDirectory: primeDirectory,
            companionDirectory: companionDirectory,
            primeGit: primeGit,
            companionGit: companionGit,
            journal: journal
        )

        let primeHeldSHA = heldEntriesSHA256(primeHeldEntries)
        let companionHeldSHA = heldEntriesSHA256(companionHeldEntries)
        try clock.observeCompletion(label: "raw_terminal_before_publication")
        let rawTerminal = try journal.publish(
            try rawTerminalRecord(
                processByRole: processByRole,
                processes: processes,
                supervisorProcessIdentifier:
                    supervisorProcessIdentifier,
                supervisorSessionIdentifier:
                    supervisorSessionIdentifier,
                supervisorProcessGroupIdentifier:
                    supervisorProcessGroupIdentifier,
                primeHeldEntriesSHA256: primeHeldSHA,
                companionHeldEntriesSHA256: companionHeldSHA
            ),
            leaf: PrimeValidationDriverV2FixedProbeJournal.rawTerminalLeaf
        )
        let rawTerminalPublishedUptimeNanoseconds = try
            clock.observeCompletion(label: "raw_terminal_after_publication")
        try journal.revalidate()
        let executorTerminalUptimeNanoseconds = try
            clock.observeCompletion(label: "raw_terminal_complete")
        guard executorTerminalUptimeNanoseconds
                >= processes.last!.waitReturnedUptimeNanoseconds,
              journal.leafCount == 34
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "raw_terminal_or_deadline"
            )
        }

        let sourceSnapshot = admission.sourceSnapshot
        let sourceSnapshotCanonicalData = try PrimeCanonicalJSON.encode(
            sourceSnapshot
        )
        guard let packageSource = sourceSnapshot.files.first(where: {
                  $0.relativePath == "Package.resolved"
              }),
              let packageEntry = primeHeldEntries.first(where: {
                  $0.rawPathBytes == Data("Package.resolved".utf8)
              }),
              let packageIdentity = admission.primeSourceIdentitySnapshot
                .fileIdentities["Package.resolved"]
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "package_resolved_missing"
            )
        }
        let packageObservation = try packageResolvedObservation(
            identity: packageIdentity,
            entry: packageEntry,
            absolutePath: admission.primeRepository.observation
                .canonicalAbsolutePath + "/Package.resolved",
            binding: admission.packageResolvedBinding,
            source: packageSource
        )
        let finalExecutorUptimeNanoseconds = try
            clock.observeCompletion(label: "raw_observation_complete")
        let observation = PrimeValidationDriverV2FixedProbeRawObservation(
            supervisorProcessIdentifier: supervisorProcessIdentifier,
            supervisorSessionIdentifier: supervisorSessionIdentifier,
            supervisorProcessGroupIdentifier:
                supervisorProcessGroupIdentifier,
            orderedProcesses: processes,
            primeHeldEntries: primeHeldEntries,
            companionHeldEntries: companionHeldEntries,
            primeHeldEntriesSHA256: primeHeldSHA,
            companionHeldEntriesSHA256: companionHeldSHA,
            primeRepository: admission.primeRepository.observation,
            companionRepository: admission.companionRepository.observation,
            workspaceRoot: admission.workspaceRoot.observation,
            evidenceRoot: admission.evidenceRoot.observation,
            sourceSnapshot: sourceSnapshot,
            sourceSnapshotCanonicalData: sourceSnapshotCanonicalData,
            sourceIdentitySHA256: sourceSnapshot.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                sourceSnapshot.embeddedSourceIdentitySHA256,
            packageResolvedBinding: admission.packageResolvedBinding,
            packageResolvedData: packageSource.contents,
            packageResolvedHeldEntry: packageEntry,
            packageResolvedFileObservation: packageObservation,
            companionDeclaration: admission.companionDeclaration,
            toolchain: toolchain.observation,
            gitExecutable: toolchain.fixedProbeGitExecutable.observation,
            gitExecutableData: toolchain.fixedProbeGitExecutable.data,
            swiftFrontendExecutable:
                toolchain.swiftFrontendExecutable.observation,
            swiftFrontendExecutableData:
                toolchain.swiftFrontendExecutable.data,
            swiftExecutablePersonality:
                toolchain.swiftExecutablePersonality.observation,
            swiftCompilerPersonality:
                toolchain.swiftCompilerPersonality.observation,
            swiftExecutablePersonalityIdentity: .init(
                toolchain.swiftExecutablePersonality.identity
            ),
            swiftCompilerPersonalityIdentity: .init(
                toolchain.swiftCompilerPersonality.identity
            ),
            xcodeVersionPlistData: toolchain.xcodeVersionPlist.data,
            sdkSettingsPlistData: toolchain.sdkSettingsPlist.data,
            currentProcessExecutable:
                retainedState.currentProcessObservation,
            prestartLeaf: prestart,
            rawTerminalLeaf: rawTerminal,
            prestartPublishedUptimeNanoseconds:
                prestartPublishedUptimeNanoseconds,
            rawTerminalPublishedUptimeNanoseconds:
                rawTerminalPublishedUptimeNanoseconds,
            deadlineStartedAtUptimeNanoseconds:
                deadline.startUptimeNanoseconds,
            deadlineExpiresAtUptimeNanoseconds:
                deadline.expiresAtUptimeNanoseconds,
            executorTerminalUptimeNanoseconds:
                finalExecutorUptimeNanoseconds,
            combinedSourceWatcherDescriptorCount:
                retainedState.combinedSourceWatcherDescriptorCount,
            productionSupervisorImageEligible:
                retainedState.productionSupervisorImageEligible
        )
        return PrimeValidationDriverV2FixedProbeExecutionResult(
            deadline: deadline,
            lastObservedUptimeNanoseconds:
                finalExecutorUptimeNanoseconds,
            observation: observation
        )
    }

    @available(macOS 26.0, *)
    private static func executeChild(
        policy: PrimeValidationDriverV2FixedProbePolicy,
        environment: [(String, String)],
        environmentEntries:
            [PrimeValidationSwiftPMDeterministicEnvironmentEntry],
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
        deadline: PrimeSecureChildPhaseDeadline,
        clock: PrimeValidationDriverV2FixedProbeClock,
        primeDirectory:
            PrimeSecureChildDarwinProcessProof.HeldDirectorySnapshot,
        companionDirectory:
            PrimeSecureChildDarwinProcessProof.HeldDirectorySnapshot,
        primeGit: PrimeValidationDriverV2FixedProbeHeldGitDirectory,
        companionGit: PrimeValidationDriverV2FixedProbeHeldGitDirectory,
        journal: PrimeValidationDriverV2FixedProbeJournal,
        prestart:
            PrimeValidationDriverV2FixedProbeJournalLeafObservation,
        supervisorSessionIdentifier: Int32,
        predecessorKind: String,
        predecessorSHA256: String,
        processByRole:
            [PrimeValidationDriverV2FixedProbeRole:
                PrimeValidationDriverV2FixedProbeProcessObservation]
    ) throws -> PrimeValidationDriverV2FixedProbeProcessObservation {
        let workingDirectory: PrimeSecureChildDarwinProcessProof
            .HeldDirectorySnapshot
        let workingObservation: PrimeValidationSwiftPMDirectoryObservation
        switch policy.root {
        case .prime:
            workingDirectory = primeDirectory
            workingObservation =
                retainedState.admission.primeRepository.observation
        case .companion:
            workingDirectory = companionDirectory
            workingObservation =
                retainedState.admission.companionRepository.observation
        }
        let executable: PrimeValidationSwiftPMHeldSystemFile
        switch policy.image {
        case .git:
            executable = retainedState.admission.toolchain
                .fixedProbeGitExecutable
        case .swiftFrontend:
            executable = retainedState.admission.toolchain
                .swiftFrontendExecutable
        }
        try lightweightCheckpoint(
            retainedState: retainedState,
            clock: clock,
            primeDirectory: primeDirectory,
            companionDirectory: companionDirectory,
            primeGit: primeGit,
            companionGit: companionGit,
            journal: journal
        )
        try clock.authorizeNewWork(
            label: "before_spawn_\(policy.role.rawValue)"
        )
        let spawn: PrimeSecureChildSpawnHandle
        do {
            spawn = try PrimeSecureChildDarwinSubstrate
                .spawnDriverV2FixedProbeSuspended(
                executableAbsolutePath:
                    executable.observation.canonicalAbsolutePath,
                argumentZero: policy.logicalArgumentZero,
                workingDirectoryDescriptor: workingDirectory.descriptor,
                exactArguments: policy.arguments,
                orderedEnvironment: environment
            )
        } catch let rejection as PrimeSecureChildDarwinSubstrate.Rejection {
            throw primeValidationDriverV2FixedProbeRejected(
                "\(policy.role.rawValue)_\(rejection.detail)"
            )
        }
        let supervision = PrimeSecureChildSupervisionCapability.adoptMemory(
            spawn: spawn,
            phaseDeadline: deadline,
            standardOutputMaximumByteCount:
                policy.standardOutputMaximumByteCount,
            standardErrorMaximumByteCount:
                PrimeValidationDriverV2FixedProbePolicy
                .standardErrorMaximumByteCount,
            chunkByteCount:
                PrimeValidationDriverV2FixedProbePolicy.drainChunkByteCount
        )
        do {
            try clock.observeCompletion(
                supervision.spawnReturnedMonotonicNanoseconds,
                label: "spawn_return_\(policy.role.rawValue)"
            )
            guard supervision.appliedFlags
                    == PrimeValidationDriverV2FixedProbePolicy
                    .requiredSpawnFlags,
                  supervision.spawnReturnCode == 0,
                  let establishedSupervisorSessionIdentifier =
                    supervision
                    .establishDriverV2DedicatedGroupWithinSupervisorSession(),
                  establishedSupervisorSessionIdentifier
                    == supervisorSessionIdentifier
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "spawn_or_group_\(policy.role.rawValue)"
                )
            }
            let pid = supervision.processIdentifier
            guard pid > 0,
                  pid != supervisorSessionIdentifier
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "child_process_identity_\(policy.role.rawValue)"
                )
            }
            let cwdProof: PrimeSecureChildDarwinProcessProof
                .SuspendedWorkingDirectoryProof
            let mappedProof: PrimeSecureChildDarwinProcessProof
                .MappedExecutableProof
            do {
                cwdProof = try PrimeSecureChildDarwinProcessProof
                    .captureSuspendedWorkingDirectory(
                        processIdentifier: pid,
                        heldDirectory: workingDirectory
                    )
                mappedProof = try PrimeSecureChildDarwinProcessProof
                    .captureMappedExecutable(
                        processIdentifier: pid,
                        heldExecutable:
                            try PrimeSecureChildDarwinProcessProof
                            .snapshotHeldExecutable(
                                deviceID: executable.observation.deviceID,
                                inode: executable.observation.inode,
                                expectedCanonicalAbsolutePath:
                                    executable.observation
                                    .canonicalAbsolutePath
                            )
                    )
            } catch let rejection as
                PrimeSecureChildDarwinProcessProof.Rejection
            {
                throw primeValidationDriverV2FixedProbeRejected(
                    "\(policy.role.rawValue)_\(rejection.detail)"
                )
            }
            try lightweightCheckpoint(
                retainedState: retainedState,
                clock: clock,
                primeDirectory: primeDirectory,
                companionDirectory: companionDirectory,
                primeGit: primeGit,
                companionGit: companionGit,
                journal: journal
            )
            let argumentVectorSHA256 = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    PrimeValidationDriverV2FixedProbeArgumentVectorRecord(
                        logicalArgumentZero: policy.logicalArgumentZero,
                        arguments: policy.arguments
                    )
                )
            )
            try clock.observeCompletion(
                label: "start_before_publication_\(policy.role.rawValue)"
            )
            let startLeaf = try journal.publish(
                PrimeValidationDriverV2FixedProbeStartRecord(
                    ordinal: policy.ordinal,
                    role: policy.role.rawValue,
                    prestartSHA256: prestart.sha256,
                    predecessorKind: predecessorKind,
                    predecessorSHA256: predecessorSHA256,
                    processIdentifier: pid,
                    sessionIdentifier: supervisorSessionIdentifier,
                    processGroupIdentifier: pid,
                    appliedSpawnFlags: supervision.appliedFlags,
                    spawnReturnCode: supervision.spawnReturnCode,
                    spawnReturnedUptimeNanoseconds:
                        supervision.spawnReturnedMonotonicNanoseconds,
                    deadlineStartedAtUptimeNanoseconds:
                        deadline.startUptimeNanoseconds,
                    deadlineExpiresAtUptimeNanoseconds:
                        deadline.expiresAtUptimeNanoseconds,
                    workingDirectoryDeviceID:
                        workingDirectory.deviceID,
                    workingDirectoryInode:
                        workingDirectory.inode,
                    workingDirectoryAbsolutePath:
                        workingObservation.canonicalAbsolutePath,
                    childWorkingDirectoryDeviceID:
                        cwdProof.suspendedChildCurrentDirectoryDeviceID,
                    childWorkingDirectoryInode:
                        cwdProof.suspendedChildCurrentDirectoryInode,
                    executableDeviceID: executable.observation.deviceID,
                    executableInode: executable.observation.inode,
                    executableAbsolutePath:
                        executable.observation.canonicalAbsolutePath,
                    executableByteCount: executable.observation.byteCount,
                    executableSHA256: executable.observation.sha256,
                    logicalArgumentZero: policy.logicalArgumentZero,
                    arguments: policy.arguments,
                    argumentVectorSHA256: argumentVectorSHA256,
                    mappedExecutablePathTelemetry:
                        mappedProof.mappedExecutablePathTelemetry,
                    mappedExecutableQueryCount: mappedProof.queries.count,
                    mappedExecutableTerminalErrno:
                        mappedProof.terminalErrno,
                    exactWorkingDirectoryJoin:
                        cwdProof.exactDescriptorJoinObserved,
                    exactMappedExecutableJoin: true,
                    preResumeContinuityChecked: true
                ),
                leaf: policy.leafBase + "-start.json"
            )
            let startPublishedAt = try clock.observeCompletion(
                label: "start_after_publication_\(policy.role.rawValue)"
            )
            let preResumeContinuityCheckpointUptimeNanoseconds = try
                lightweightCheckpoint(
                    retainedState: retainedState,
                    clock: clock,
                    primeDirectory: primeDirectory,
                    companionDirectory: companionDirectory,
                    primeGit: primeGit,
                    companionGit: companionGit,
                    journal: journal
                )
            let resumedAt: UInt64
            switch try supervision.resume(
                notBeforeUptimeNanoseconds:
                    preResumeContinuityCheckpointUptimeNanoseconds
            ) {
            case let .resumed(deliveredAtUptimeNanoseconds):
                resumedAt = deliveredAtUptimeNanoseconds
            case .deadlineExpired:
                throw primeValidationDriverV2FixedProbeRejected(
                    "deadline_before_resume_\(policy.role.rawValue)"
                )
            case let .signalFailed(errorNumber):
                throw primeValidationDriverV2FixedProbeRejected(
                    "resume_signal_\(policy.role.rawValue)_\(errorNumber)"
                )
            case .stateRejected:
                throw primeValidationDriverV2FixedProbeRejected(
                    "resume_state_\(policy.role.rawValue)"
                )
            }
            try clock.observeCompletion(
                resumedAt,
                label: "resume_\(policy.role.rawValue)"
            )

            let deathObservedAt: UInt64
            switch try supervision.observeDeath() {
            case .observed:
                guard let observed = supervision
                    .deathObservedMonotonicNanoseconds()
                else {
                    throw primeValidationDriverV2FixedProbeRejected(
                        "death_timestamp_\(policy.role.rawValue)"
                    )
                }
                deathObservedAt = observed
            case .deadlineExpired:
                throw primeValidationDriverV2FixedProbeRejected(
                    "deadline_waiting_for_death_\(policy.role.rawValue)"
                )
            case .stateRejected:
                throw primeValidationDriverV2FixedProbeRejected(
                    "death_state_\(policy.role.rawValue)"
                )
            }
            try clock.observeCompletion(
                deathObservedAt,
                label: "death_\(policy.role.rawValue)"
            )
            let drainEvidence: PrimeSecureChildDrainEvidence
            switch try supervision.waitForPhaseDrainCompletion(
                notBeforeUptimeNanoseconds: deathObservedAt
            ) {
            case let .completed(value):
                drainEvidence = value
            case .deadlineExpired:
                throw primeValidationDriverV2FixedProbeRejected(
                    "deadline_waiting_for_drains_\(policy.role.rawValue)"
                )
            case .stateRejected:
                throw primeValidationDriverV2FixedProbeRejected(
                    "drain_state_\(policy.role.rawValue)"
                )
            }
            guard let preReapMembers =
                    supervision.processGroupMemberIdentifiers(),
                  preReapMembers == [pid]
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "pre_reap_group_\(policy.role.rawValue)"
                )
            }
            let exactWait: PrimeSecureChildExactPIDWaitObservation
            let processGroupEmptyAfterReap: Bool
            switch supervision.reapAfterObservedDeath() {
            case let .reaped(value):
                exactWait = value
                // The lifecycle returns `.reaped` only after its mandatory
                // processGroupIsEmpty proof succeeds.
                processGroupEmptyAfterReap = true
            case let .mustFailStop(reason):
                primeValidationDriverV2FixedProbeFailStop(reason)
            }
            try clock.observeCompletion(
                exactWait.returnedMonotonicNanoseconds,
                label: "reap_\(policy.role.rawValue)"
            )
            let stdout: PrimeSecureChildMemoryDrainSnapshot
            let stderr: PrimeSecureChildMemoryDrainSnapshot
            switch drainEvidence {
            case let .memory(standardOutput, standardError):
                stdout = standardOutput
                stderr = standardError
            case .fileBacked:
                throw primeValidationDriverV2FixedProbeRejected(
                    "file_backed_drain_\(policy.role.rawValue)"
                )
            }
            guard cleanEOF(stdout),
                  cleanEOF(stderr),
                  stderr.data == policy.expectedStandardError,
                  exactWait.requestedProcessIdentifier == pid,
                  exactWait.returnedProcessIdentifier == pid,
                  exactWait.waitOptions == 0,
                  exactWait.exitedNormally,
                  exactWait.exitStatus == 0,
                  exactWait.terminationSignal == 0,
                  !exactWait.coreDumped
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "terminal_process_\(policy.role.rawValue)"
                )
            }
            try validateRawOutput(
                policy.role,
                output: stdout.data,
                processByRole: processByRole,
                retainedState: retainedState
            )
            try lightweightCheckpoint(
                retainedState: retainedState,
                clock: clock,
                primeDirectory: primeDirectory,
                companionDirectory: companionDirectory,
                primeGit: primeGit,
                companionGit: companionGit,
                journal: journal
            )
            try clock.observeCompletion(
                label: "terminal_before_publication_\(policy.role.rawValue)"
            )
            let terminalLeaf = try journal.publish(
                PrimeValidationDriverV2FixedProbeTerminalRecord(
                    ordinal: policy.ordinal,
                    role: policy.role.rawValue,
                    startLeafSHA256: startLeaf.sha256,
                    supervisorProcessIdentifier:
                        supervisorSessionIdentifier,
                    supervisorSessionIdentifier:
                        supervisorSessionIdentifier,
                    supervisorProcessGroupIdentifier:
                        supervisorSessionIdentifier,
                    processIdentifier: pid,
                    sessionIdentifier: supervisorSessionIdentifier,
                    processGroupIdentifier: pid,
                    deathObservedUptimeNanoseconds: deathObservedAt,
                    preReapProcessGroupMemberIdentifiers: preReapMembers,
                    startPublishedUptimeNanoseconds: startPublishedAt,
                    preResumeContinuityCheckpointUptimeNanoseconds:
                        preResumeContinuityCheckpointUptimeNanoseconds,
                    resumedAtUptimeNanoseconds: resumedAt,
                    requestedWaitProcessIdentifier:
                        exactWait.requestedProcessIdentifier,
                    returnedWaitProcessIdentifier:
                        exactWait.returnedProcessIdentifier,
                    waitOptions: exactWait.waitOptions,
                    rawWaitStatus: exactWait.rawWaitStatus,
                    waitReturnedUptimeNanoseconds:
                        exactWait.returnedMonotonicNanoseconds,
                    exitedNormally: exactWait.exitedNormally,
                    exitStatus: exactWait.exitStatus,
                    terminationSignal: exactWait.terminationSignal,
                    coreDumped: exactWait.coreDumped,
                    standardOutputByteCount: stdout.totalByteCount,
                    standardOutputSHA256:
                        PrimeSHA256.hexDigest(of: stdout.data),
                    standardOutputReachedEOF: stdout.reachedEOF,
                    standardOutputTerminalReason:
                        stdout.terminalReason.rawValue,
                    standardOutputOverflowed: stdout.overflowed,
                    standardOutputWorkerFinished: stdout.workerFinished,
                    standardOutputReadErrorNumber: stdout.readErrorNumber,
                    standardOutputWriteErrorNumber: stdout.writeErrorNumber,
                    standardOutputFinalizationErrorNumber:
                        stdout.finalizationErrorNumber,
                    standardOutputCloseErrorNumber: stdout.closeErrorNumber,
                    standardOutputDescriptorsClosed:
                        stdout.descriptorsClosed,
                    standardErrorByteCount: stderr.totalByteCount,
                    standardErrorSHA256:
                        PrimeSHA256.hexDigest(of: stderr.data),
                    standardErrorReachedEOF: stderr.reachedEOF,
                    standardErrorTerminalReason:
                        stderr.terminalReason.rawValue,
                    standardErrorOverflowed: stderr.overflowed,
                    standardErrorWorkerFinished: stderr.workerFinished,
                    standardErrorReadErrorNumber: stderr.readErrorNumber,
                    standardErrorWriteErrorNumber: stderr.writeErrorNumber,
                    standardErrorFinalizationErrorNumber:
                        stderr.finalizationErrorNumber,
                    standardErrorCloseErrorNumber: stderr.closeErrorNumber,
                    standardErrorDescriptorsClosed:
                        stderr.descriptorsClosed,
                    processGroupEmptyAfterReap:
                        processGroupEmptyAfterReap,
                    postReapContinuityChecked: true
                ),
                leaf: policy.leafBase + "-terminal.json"
            )
            let terminalPublishedAt = try clock.observeCompletion(
                label: "terminal_after_publication_\(policy.role.rawValue)"
            )
            return PrimeValidationDriverV2FixedProbeProcessObservation(
                ordinal: policy.ordinal,
                role: policy.role,
                logicalArgumentZero: policy.logicalArgumentZero,
                arguments: policy.arguments,
                orderedEnvironment: environmentEntries,
                workingDirectory: workingObservation,
                executable: executable.observation,
                standardOutput: stdout.data,
                standardError: stderr.data,
                processIdentifier: pid,
                appliedSpawnFlags: supervision.appliedFlags,
                spawnReturnCode: supervision.spawnReturnCode,
                spawnReturnedUptimeNanoseconds:
                    supervision.spawnReturnedMonotonicNanoseconds,
                sessionIdentifier: supervisorSessionIdentifier,
                processGroupIdentifier: pid,
                suspendedWorkingDirectoryDeviceID:
                    cwdProof.suspendedChildCurrentDirectoryDeviceID,
                suspendedWorkingDirectoryInode:
                    cwdProof.suspendedChildCurrentDirectoryInode,
                exactSuspendedWorkingDirectoryJoin:
                    cwdProof.exactDescriptorJoinObserved,
                deathObserved: true,
                deathObservedUptimeNanoseconds: deathObservedAt,
                preReapProcessGroupMemberIdentifiers: preReapMembers,
                startPublishedUptimeNanoseconds: startPublishedAt,
                preResumeContinuityCheckpointUptimeNanoseconds:
                    preResumeContinuityCheckpointUptimeNanoseconds,
                resumedAtUptimeNanoseconds: resumedAt,
                startDurableBeforeResume: resumedAt > startPublishedAt,
                terminalPublishedUptimeNanoseconds: terminalPublishedAt,
                mappedImageJoined: true,
                requestedWaitProcessIdentifier:
                    exactWait.requestedProcessIdentifier,
                returnedWaitProcessIdentifier:
                    exactWait.returnedProcessIdentifier,
                waitOptions: exactWait.waitOptions,
                rawWaitStatus: exactWait.rawWaitStatus,
                waitReturnedUptimeNanoseconds:
                    exactWait.returnedMonotonicNanoseconds,
                exitedNormally: exactWait.exitedNormally,
                exitStatus: exactWait.exitStatus,
                terminationSignal: exactWait.terminationSignal,
                coreDumped: exactWait.coreDumped,
                standardOutputReachedEOF: stdout.reachedEOF,
                standardOutputTotalByteCount: stdout.totalByteCount,
                standardOutputTerminalReason:
                    stdout.terminalReason.rawValue,
                standardOutputOverflowed: stdout.overflowed,
                standardOutputWorkerFinished: stdout.workerFinished,
                standardOutputReadErrorNumber: stdout.readErrorNumber,
                standardOutputWriteErrorNumber: stdout.writeErrorNumber,
                standardOutputFinalizationErrorNumber:
                    stdout.finalizationErrorNumber,
                standardOutputCloseErrorNumber: stdout.closeErrorNumber,
                standardOutputDescriptorsClosed: stdout.descriptorsClosed,
                standardErrorReachedEOF: stderr.reachedEOF,
                standardErrorTotalByteCount: stderr.totalByteCount,
                standardErrorTerminalReason:
                    stderr.terminalReason.rawValue,
                standardErrorOverflowed: stderr.overflowed,
                standardErrorWorkerFinished: stderr.workerFinished,
                standardErrorReadErrorNumber: stderr.readErrorNumber,
                standardErrorWriteErrorNumber: stderr.writeErrorNumber,
                standardErrorFinalizationErrorNumber:
                    stderr.finalizationErrorNumber,
                standardErrorCloseErrorNumber: stderr.closeErrorNumber,
                standardErrorDescriptorsClosed: stderr.descriptorsClosed,
                processGroupEmptyAfterReap:
                    processGroupEmptyAfterReap,
                startLeaf: startLeaf,
                terminalLeaf: terminalLeaf
            )
        } catch {
            containOrFailStop(supervision)
            throw error
        }
    }

    private static func heldDirectory(
        descriptor: Int32
    ) throws -> PrimeSecureChildDarwinProcessProof.HeldDirectorySnapshot {
        do {
            return try PrimeSecureChildDarwinProcessProof
                .snapshotHeldDirectory(
                    descriptor: descriptor,
                    openedWithNoSymbolicLinksInPath: true,
                    context: .validationWorkingDirectory
                )
        } catch let rejection as PrimeSecureChildDarwinProcessProof.Rejection {
            throw primeValidationDriverV2FixedProbeRejected(
                rejection.detail
            )
        }
    }

    @discardableResult
    private static func lightweightCheckpoint(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
        clock: PrimeValidationDriverV2FixedProbeClock,
        primeDirectory:
            PrimeSecureChildDarwinProcessProof.HeldDirectorySnapshot,
        companionDirectory:
            PrimeSecureChildDarwinProcessProof.HeldDirectorySnapshot,
        primeGit: PrimeValidationDriverV2FixedProbeHeldGitDirectory,
        companionGit: PrimeValidationDriverV2FixedProbeHeldGitDirectory,
        journal: PrimeValidationDriverV2FixedProbeJournal
    ) throws -> UInt64 {
        try clock.observeCompletion(label: "checkpoint_before")
        try lightweightRetainedCheckpoint(retainedState: retainedState)
        try PrimeSecureChildDarwinProcessProof.requireHeldDirectoryUnchanged(
            primeDirectory
        )
        try PrimeSecureChildDarwinProcessProof.requireHeldDirectoryUnchanged(
            companionDirectory
        )
        try primeGit.revalidate()
        try companionGit.revalidate()
        try journal.revalidate()
        return try clock.observeCompletion(label: "checkpoint_after")
    }

    /// Production-shared retained half of every lightweight Gate E checkpoint.
    /// This polls the original Gate C kqueues and revalidates only already-held
    /// admission authority; it opens no replacement source owner.
    private static func lightweightRetainedCheckpoint(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    ) throws {
        let admission = retainedState.admission
        let expectedWatcherDescriptorCount =
            retainedState.productionSupervisorImageEligible
            ? PrimeValidationDriverV2SealedSourceTopology.combinedWatcherDescriptorCount
            : 45
        try retainedState.fixedProbeCheckpointNoPendingEvents()
        guard admission.lease.isHeld,
              retainedState.combinedSourceWatcherDescriptorCount
                == expectedWatcherDescriptorCount
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "lease_or_watcher_count"
            )
        }
        try admission.primeRepository.revalidate()
        try admission.companionRepository.revalidate()
        try admission.workspaceRoot.revalidate(requirePrivateAndEmpty: true)
        try admission.evidenceRoot.revalidate(requirePrivateAndEmpty: true)
        try admission.leaseDirectory.revalidate()
        try admission.toolchain.fixedProbeRevalidateAdmissionHeldSet()
        try retainedState.currentProcessImage.revalidateIdentityOnly()
    }

    private static func requireAllRegularHeldEntries(
        _ entries: [PrimeValidationDriverV2TrackedTreeHeldEntry],
        label: String
    ) throws {
        guard !entries.isEmpty,
              entries.allSatisfy({ entry in
                  entry.kind == .regularFile
                    && entry.openedIdentity.posixFileType == .regularFile
                    && entry.postReadDescriptorIdentity.posixFileType
                        == .regularFile
                    && entry.namedPathReboundIdentity.posixFileType
                        == .regularFile
              })
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "held_projection_nonregular_\(label)"
            )
        }
    }

    private static func cleanEOF(
        _ value: PrimeSecureChildMemoryDrainSnapshot
    ) -> Bool {
        value.terminalReason == .endOfFile
            && value.totalByteCount == UInt64(value.data.count)
            && !value.overflowed
            && value.workerFinished
            && value.reachedEOF
            && value.readErrorNumber == 0
            && value.writeErrorNumber == 0
            && value.finalizationErrorNumber == 0
            && value.closeErrorNumber == 0
            && value.descriptorsClosed
    }

    private static func validateRawOutput(
        _ role: PrimeValidationDriverV2FixedProbeRole,
        output: Data,
        processByRole:
            [PrimeValidationDriverV2FixedProbeRole:
                PrimeValidationDriverV2FixedProbeProcessObservation],
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    ) throws {
        switch role {
        case .primeHeadPre:
            _ = try parsedHEAD(output)
        case .primeObjectFormat, .companionObjectFormat:
            guard output == Data("sha1\n".utf8) else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "object_format_\(role.rawValue)"
                )
            }
        case .primeStatusPre, .primeStatusPost,
             .companionStatusPre, .companionStatusPost:
            guard output.isEmpty else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "status_\(role.rawValue)"
                )
            }
        case .primeTreeDiscovery, .companionTreeDiscovery:
            try validateRawTreeFraming(output, role: role)
        case .primeTreeReplay:
            try validateRawTreeFraming(output, role: role)
            guard output
                    == (processByRole[.primeTreeDiscovery]?.standardOutput)
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "prime_tree_replay"
                )
            }
        case .companionTreeReplay:
            try validateRawTreeFraming(output, role: role)
            guard output
                    == (processByRole[.companionTreeDiscovery]?.standardOutput)
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "companion_tree_replay"
                )
            }
        case .primeHeadPost:
            guard output == processByRole[.primeHeadPre]?.standardOutput
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "prime_head_replay"
                )
            }
        case .companionHeadPre:
            let head = try parsedHEAD(output)
            guard head == retainedState.admission.companionDeclaration
                    .expectedPinnedHEAD
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "companion_head_pin"
                )
            }
        case .companionHeadPost:
            guard output
                    == (processByRole[.companionHeadPre]?.standardOutput)
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "companion_head_replay"
                )
            }
        case .swiftVersion:
            guard !output.isEmpty,
                  output.last == 0x0a
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "swift_version_framing"
                )
            }
        case .swiftTargetInfo:
            guard !output.isEmpty,
                  output.first == 0x7b,
                  output.last == 0x0a || output.last == 0x7d
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "swift_target_info_framing"
                )
            }
        }
    }

    private static func validateRawTreeFraming(
        _ output: Data,
        role: PrimeValidationDriverV2FixedProbeRole
    ) throws {
        guard !output.isEmpty,
              output.last == 0,
              output.first != 0
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "tree_framing_\(role.rawValue)"
            )
        }
        var previousWasNUL = false
        for byte in output {
            if byte == 0 {
                guard !previousWasNUL else {
                    throw primeValidationDriverV2FixedProbeRejected(
                        "tree_empty_record_\(role.rawValue)"
                    )
                }
                previousWasNUL = true
            } else {
                previousWasNUL = false
            }
        }
        let records = output.split(
            separator: 0,
            omittingEmptySubsequences: false
        )
        guard records.last?.isEmpty == true else {
            throw primeValidationDriverV2FixedProbeRejected(
                "tree_terminal_\(role.rawValue)"
            )
        }
        let regularModes = [
            Array("100644".utf8),
            Array("100755".utf8),
        ]
        for rawRecord in records.dropLast() {
            let record = Array(rawRecord)
            guard record.count >= 54,
                  regularModes.contains(Array(record[0 ..< 6])),
                  record[6] == 0x20,
                  Array(record[7 ..< 11]) == Array("blob".utf8),
                  record[11] == 0x20,
                  record[52] == 0x09,
                  record[12 ..< 52].allSatisfy({ byte in
                      (byte >= 0x30 && byte <= 0x39)
                        || (byte >= 0x61 && byte <= 0x66)
                  }),
                  record[12 ..< 52].contains(where: { $0 != 0x30 }),
                  !record[53...].isEmpty
            else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "tree_regular_record_\(role.rawValue)"
                )
            }
        }
    }

    private static func parsedHEAD(_ output: Data) throws -> String {
        guard output.count == 41,
              output.last == 0x0a,
              output.dropLast().allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
              })
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "head_framing"
            )
        }
        return String(decoding: output.dropLast(), as: UTF8.self)
    }

    private static func rawTerminalRecord(
        processByRole:
            [PrimeValidationDriverV2FixedProbeRole:
                PrimeValidationDriverV2FixedProbeProcessObservation],
        processes:
            [PrimeValidationDriverV2FixedProbeProcessObservation],
        supervisorProcessIdentifier: Int32,
        supervisorSessionIdentifier: Int32,
        supervisorProcessGroupIdentifier: Int32,
        primeHeldEntriesSHA256: String,
        companionHeldEntriesSHA256: String
    ) throws -> PrimeValidationDriverV2FixedProbeRawTerminalRecord {
        func output(
            _ role: PrimeValidationDriverV2FixedProbeRole
        ) throws -> Data {
            guard let value = processByRole[role] else {
                throw primeValidationDriverV2FixedProbeRejected(
                    "raw_terminal_missing_\(role.rawValue)"
                )
            }
            return value.standardOutput
        }
        return PrimeValidationDriverV2FixedProbeRawTerminalRecord(
            supervisorProcessIdentifier: supervisorProcessIdentifier,
            supervisorSessionIdentifier: supervisorSessionIdentifier,
            supervisorProcessGroupIdentifier:
                supervisorProcessGroupIdentifier,
            orderedProcessIdentifiers:
                processes.map(\.processIdentifier),
            orderedSessionIdentifiers:
                processes.map(\.sessionIdentifier),
            orderedProcessGroupIdentifiers:
                processes.map(\.processGroupIdentifier),
            orderedTerminalSHA256Values:
                processes.map { $0.terminalLeaf.sha256 },
            primeHEADAgreement:
                try output(.primeHeadPre) == output(.primeHeadPost),
            companionHEADAgreement:
                try output(.companionHeadPre)
                    == output(.companionHeadPost),
            primeStatusPreEmpty: try output(.primeStatusPre).isEmpty,
            primeStatusPostEmpty: try output(.primeStatusPost).isEmpty,
            companionStatusPreEmpty:
                try output(.companionStatusPre).isEmpty,
            companionStatusPostEmpty:
                try output(.companionStatusPost).isEmpty,
            primeObjectFormat:
                String(decoding: try output(.primeObjectFormat), as: UTF8.self),
            companionObjectFormat:
                String(
                    decoding: try output(.companionObjectFormat),
                    as: UTF8.self
                ),
            primeTreeReplayEqual:
                try output(.primeTreeDiscovery) == output(.primeTreeReplay),
            companionTreeReplayEqual:
                try output(.companionTreeDiscovery)
                    == output(.companionTreeReplay),
            primeHeldEntriesSHA256: primeHeldEntriesSHA256,
            companionHeldEntriesSHA256: companionHeldEntriesSHA256,
            swiftVersionSHA256:
                PrimeSHA256.hexDigest(of: try output(.swiftVersion)),
            swiftTargetInfoSHA256:
                PrimeSHA256.hexDigest(of: try output(.swiftTargetInfo))
        )
    }

    private static func heldEntriesSHA256(
        _ entries: [PrimeValidationDriverV2TrackedTreeHeldEntry]
    ) -> String {
        var data = Data()
        for entry in entries {
            data.append(Data("\(entry.rawPathBytes.count):".utf8))
            data.append(entry.rawPathBytes)
            data.append(0)
            data.append(Data(entry.kind == .regularFile ? "f:".utf8 : "l:".utf8))
            data.append(Data("\(entry.openedIdentity.deviceID):".utf8))
            data.append(Data("\(entry.openedIdentity.inode):".utf8))
            data.append(Data("\(entry.openedIdentity.ownerUserID):".utf8))
            data.append(Data("\(entry.openedIdentity.ownerGroupID):".utf8))
            data.append(Data("\(entry.openedIdentity.permissionMode):".utf8))
            data.append(Data("\(entry.openedIdentity.linkCount):".utf8))
            data.append(Data("\(entry.byteCount):".utf8))
            data.append(Data(entry.sha256.utf8))
            data.append(0)
            data.append(Data(entry.gitBlobSHA1.utf8))
            data.append(0)
        }
        return PrimeSHA256.hexDigest(of: data)
    }

    private static func identityRecord(
        role: String,
        observation: PrimeValidationSwiftPMDirectoryObservation
    ) -> PrimeValidationDriverV2FixedProbeIdentityRecord {
        PrimeValidationDriverV2FixedProbeIdentityRecord(
            role: role,
            absolutePath: observation.canonicalAbsolutePath,
            deviceID: observation.deviceID,
            inode: observation.inode,
            ownerUserID: observation.ownerUserID,
            ownerGroupID: observation.ownerGroupID,
            permissionMode: observation.permissionMode,
            linkCount: observation.linkCount,
            byteCount: 0,
            sha256: "",
            modificationSeconds: observation.modificationSeconds,
            modificationNanoseconds: observation.modificationNanoseconds,
            statusChangeSeconds: observation.statusChangeSeconds,
            statusChangeNanoseconds: observation.statusChangeNanoseconds
        )
    }

    private static func identityRecord(
        role: String,
        observation: PrimeValidationSwiftPMFileObservation
    ) -> PrimeValidationDriverV2FixedProbeIdentityRecord {
        PrimeValidationDriverV2FixedProbeIdentityRecord(
            role: role,
            absolutePath: observation.canonicalAbsolutePath,
            deviceID: observation.deviceID,
            inode: observation.inode,
            ownerUserID: observation.ownerUserID,
            ownerGroupID: observation.ownerGroupID,
            permissionMode: observation.permissionMode,
            linkCount: observation.linkCount,
            byteCount: observation.byteCount,
            sha256: observation.sha256,
            modificationSeconds: observation.modificationSeconds,
            modificationNanoseconds: observation.modificationNanoseconds,
            statusChangeSeconds: observation.statusChangeSeconds,
            statusChangeNanoseconds: observation.statusChangeNanoseconds
        )
    }

    private static func identityRecord(
        role: String,
        absolutePath: String,
        identity: PrimeArtifactRootIdentity
    ) -> PrimeValidationDriverV2FixedProbeIdentityRecord {
        PrimeValidationDriverV2FixedProbeIdentityRecord(
            role: role,
            absolutePath: absolutePath,
            deviceID: identity.deviceID,
            inode: identity.inode,
            ownerUserID: identity.ownerUserID,
            ownerGroupID: identity.ownerGroupID,
            permissionMode: identity.actualMode,
            linkCount: identity.linkCount,
            byteCount: 0,
            sha256: "",
            modificationSeconds: identity.modificationSeconds,
            modificationNanoseconds: identity.modificationNanoseconds,
            statusChangeSeconds: identity.statusChangeSeconds,
            statusChangeNanoseconds: identity.statusChangeNanoseconds
        )
    }

    private static func packageResolvedObservation(
        identity: PrimeSecureHeldNodeIdentity,
        entry: PrimeValidationDriverV2TrackedTreeHeldEntry,
        absolutePath: String,
        binding: PrimeArtifactBinding,
        source: PrimeSwiftSourceFileSnapshot
    ) throws -> PrimeValidationSwiftPMFileObservation {
        let deviceID = UInt64(bitPattern: Int64(identity.deviceID))
        guard entry.kind == .regularFile,
              entry.openedIdentity.deviceID == deviceID,
              entry.openedIdentity.inode == identity.inode,
              entry.openedIdentity.ownerUserID == identity.ownerUserID,
              entry.openedIdentity.ownerGroupID == identity.groupID,
              entry.openedIdentity.permissionMode
                == UInt16(identity.mode & 0o7777),
              entry.openedIdentity.linkCount == identity.linkCount,
              identity.byteCount >= 0,
              entry.byteCount == UInt64(identity.byteCount),
              entry.contents == source.contents,
              entry.byteCount == source.byteCount,
              entry.sha256 == source.sha256,
              binding.relativePath == "Package.resolved",
              binding.byteCount == entry.byteCount,
              binding.sha256 == entry.sha256
        else {
            throw primeValidationDriverV2FixedProbeRejected(
                "package_resolved_join"
            )
        }
        return PrimeValidationSwiftPMFileObservation(
            canonicalAbsolutePath: absolutePath,
            deviceID: deviceID,
            inode: identity.inode,
            ownerUserID: identity.ownerUserID,
            ownerGroupID: identity.groupID,
            permissionMode: UInt16(identity.mode & 0o777),
            linkCount: identity.linkCount,
            byteCount: UInt64(identity.byteCount),
            sha256: entry.sha256,
            modificationSeconds: identity.modificationSeconds,
            modificationNanoseconds: identity.modificationNanoseconds,
            statusChangeSeconds: identity.statusChangeSeconds,
            statusChangeNanoseconds: identity.statusChangeNanoseconds
        )
    }

    private static func containOrFailStop(
        _ supervision: PrimeSecureChildSupervisionCapability
    ) {
        switch supervision.cleanupRejectedCapture() {
        case .contained:
            break
        case let .mustFailStop(reason):
            primeValidationDriverV2FixedProbeFailStop(reason)
        }
    }
}

private func primeValidationDriverV2FixedProbeFailStop(
    _ reason: PrimeSecureChildContainmentFailureReason
) -> Never {
    // Mandatory containment failure cannot depend on inherited stderr: a full
    // pipe can block and a broken pipe can replace the fixed status with SIGPIPE.
    Darwin._exit(70)
}

private func primeValidationDriverV2FixedProbeRejected(
    _ detail: String
) -> PrimeValidationSwiftPMBuildInventoryAdmissionError {
    .rejected("driver_v2_fixed_probe_\(detail)")
}
