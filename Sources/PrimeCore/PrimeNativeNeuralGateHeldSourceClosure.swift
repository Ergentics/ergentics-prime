import Darwin
import Foundation

/// PrimeCore-internal descriptor and vnode-event authority for the exact
/// source snapshot admitted by the native neural-gate child factory.
///
/// This type is internal so Swift tests can calibrate Darwin vnode behavior,
/// but callers cannot inject it into the public capture result or construct a
/// trusted child-capture capability from it.
final class PrimeNativeNeuralGateHeldSourceClosure {
    private typealias DarwinKevent =
        Darwin.kevent

    struct VnodeEvent: Equatable, Sendable {
        let relativePath: String
        let isDirectory: Bool
        let noteMask: UInt32
    }

    private struct LocalAPFSFilesystemIdentity:
        Equatable
    {
        // Darwin's two-word fsid identifies the mounted filesystem. Preserve
        // both signed words exactly; do not collapse it to st_dev or a
        // presentation string.
        let typeName: String
        let fsidWord0: Int32
        let fsidWord1: Int32
    }

    private struct HeldFile {
        let snapshot: PrimeSwiftSourceFileSnapshot
        let descriptor: Int32
        let initialStatus: stat
    }

    private struct DirectoryEntryRecord:
        Codable,
        Equatable
    {
        let name: String
        let inode: UInt64
        let fileType: UInt8

        private enum CodingKeys: String, CodingKey {
            case name
            case inode
            case fileType = "file_type"
        }
    }

    private static let maximumDirectoryEntryCount =
        16_384
    private static let maximumAggregateDirectoryEntryCount =
        65_536
    private static let expectedVnodeFilter =
        Int16(EVFILT_VNODE)
    private static let vnodeNoteMask =
        UInt32(NOTE_DELETE)
        | UInt32(NOTE_WRITE)
        | UInt32(NOTE_EXTEND)
        | UInt32(NOTE_ATTRIB)
        | UInt32(NOTE_LINK)
        | UInt32(NOTE_RENAME)
        | UInt32(NOTE_REVOKE)
    private static let registrationFlags =
        UInt16(EV_ADD)
        | UInt16(EV_ENABLE)
        | UInt16(EV_CLEAR)
        | UInt16(EV_RECEIPT)
    private static let testingEventBatchCount = 64
    static let productionPendingEventMaximumCount =
        1
    static let maximumProductionPollAttemptCount =
        8
    private static let maximumTestingEventCount =
        4_096
    private static let maximumTestingEventCollectionNanoseconds:
        UInt64 = 1_000_000_000
    private static let readChunkByteCount =
        64 * 1024

    private let sourceSnapshot:
        PrimeSwiftSourceSnapshot
    private let sourceSnapshotSHA256: String
    private let aggregateFileByteCount: UInt64
    private let sourceAdmissionMaximumSeconds:
        UInt64
    private let sourceAdmissionStartedMonotonicNanoseconds:
        UInt64
    private var sourceAdmissionCompletedMonotonicNanoseconds:
        UInt64 = 0
    private let filesystemType: String
    private let rootFilesystemIdentity:
        LocalAPFSFilesystemIdentity
    private var queueDescriptor: Int32 = -1
    private var directoryDescriptors:
        [String: Int32] = [:]
    private var directoryInitialStatuses:
        [String: stat] = [:]
    private var directoryInitialInventories:
        [String: [DirectoryEntryRecord]] = [:]
    private var fileRecords: [HeldFile] = []
    private var watcherPathByDescriptor:
        [Int32: (relativePath: String, isDirectory: Bool)] = [:]
    private var registrationReceiptCount = 0
    private var registrationReceiptErrorCount = 0
    private var watchersArmedMonotonicNanoseconds:
        UInt64 = 0
    private var initialValidationMonotonicNanoseconds:
        UInt64 = 0
    private var preResumeValidationMonotonicNanoseconds:
        UInt64?
    private var postReapValidationMonotonicNanoseconds:
        UInt64?
    private var initialPendingEventCount = 0
    private var preResumePendingEventCount:
        Int?
    private var postReapPendingEventCount:
        Int?
    private var poisoned = false
    private var closed = false

    init(
        rootDescriptor: Int32,
        sourceSnapshot:
            PrimeSwiftSourceSnapshot,
        sourceAdmissionStartedMonotonicNanoseconds:
            UInt64,
        sourceAdmissionMaximumSeconds:
            UInt64
    ) throws {
        try Self.requireCalibratedKqueueABI()
        guard sourceAdmissionStartedMonotonicNanoseconds
                > 0,
              sourceAdmissionMaximumSeconds
                == 30
        else {
            throw Self.rejected(
                "source_admission_contract"
            )
        }
        let rootFilesystemIdentity =
            try Self.localAPFSFilesystemIdentity(
                descriptor:
                    rootDescriptor,
                context:
                    "source_root_filesystem"
            )
        let snapshotData =
            try PrimeCanonicalJSON.encode(
                sourceSnapshot
            )
        let aggregate =
            try Self.validateAdmission(
                sourceSnapshot
            )
        self.sourceSnapshot =
            sourceSnapshot
        sourceSnapshotSHA256 =
            PrimeSHA256.hexDigest(
                of: snapshotData
            )
        aggregateFileByteCount =
            aggregate
        self.sourceAdmissionMaximumSeconds =
            sourceAdmissionMaximumSeconds
        self.sourceAdmissionStartedMonotonicNanoseconds =
            sourceAdmissionStartedMonotonicNanoseconds
        self.filesystemType =
            rootFilesystemIdentity
            .typeName
        self.rootFilesystemIdentity =
            rootFilesystemIdentity
        do {
            queueDescriptor =
                try Self.normalizedDescriptor(
                    Darwin.kqueue(),
                    context: "source_kqueue"
                )
            let heldRoot =
                try Self.duplicateDescriptor(
                    rootDescriptor,
                    context:
                        "source_root_duplicate"
                )
            try admitDirectory(
                relativePath: "",
                descriptor: heldRoot
            )

            let directoryPaths =
                Self.authorityDirectoryPaths(
                    for: sourceSnapshot
                )
            for path in directoryPaths
                where !path.isEmpty
            {
                guard let parent =
                        Self.parentRelativePath(
                            of: path
                        ),
                      let parentDescriptor =
                        directoryDescriptors[
                            parent
                        ]
                else {
                    throw Self.rejected(
                        "source_directory_parent"
                    )
                }
                let descriptor =
                    try Self.openRelativeLeaf(
                        directory: parentDescriptor,
                        leaf:
                            Self.leafName(
                                of: path
                            ),
                        isDirectory: true
                    )
                try admitDirectory(
                    relativePath: path,
                    descriptor: descriptor
                )
            }

            for file in sourceSnapshot.files {
                let parent =
                    Self.parentRelativePath(
                        of: file.relativePath
                    ) ?? ""
                guard let directoryDescriptor =
                        directoryDescriptors[
                            parent
                        ]
                else {
                    throw Self.rejected(
                        "source_file_parent"
                    )
                }
                let descriptor =
                    try Self.openRelativeLeaf(
                        directory:
                            directoryDescriptor,
                        leaf:
                            Self.leafName(
                                of:
                                    file.relativePath
                            ),
                        isDirectory: false
                    )
                try admitFile(
                    snapshot: file,
                    descriptor: descriptor
                )
            }

            watchersArmedMonotonicNanoseconds =
                Self.monotonicNanoseconds()
            let before =
                try pollFirstPendingEvent()
            initialPendingEventCount =
                before == nil ? 0 : 1
            guard before == nil else {
                poisoned = true
                throw Self.rejected(
                    "source_event_before_initial_validation"
                )
            }
            try establishInitialState()
            let after =
                try pollFirstPendingEvent()
            initialPendingEventCount +=
                after == nil ? 0 : 1
            guard after == nil else {
                poisoned = true
                throw Self.rejected(
                    "source_event_during_initial_validation"
                )
            }
            initialValidationMonotonicNanoseconds =
                Self.monotonicNanoseconds(
                    strictlyAfter:
                        watchersArmedMonotonicNanoseconds
                )
            sourceAdmissionCompletedMonotonicNanoseconds =
                initialValidationMonotonicNanoseconds
            let duration =
                sourceAdmissionMaximumSeconds
                .multipliedReportingOverflow(
                    by: 1_000_000_000
                )
            let deadline =
                sourceAdmissionStartedMonotonicNanoseconds
                .addingReportingOverflow(
                    duration.partialValue
                )
            guard !duration.overflow,
                  !deadline.overflow,
                  sourceAdmissionCompletedMonotonicNanoseconds
                    <= deadline.partialValue
            else {
                throw Self.rejected(
                    "source_admission_deadline"
                )
            }
        } catch {
            close()
            throw error
        }
    }

    convenience init(
        rootDescriptor: Int32,
        sourceSnapshot:
            PrimeSwiftSourceSnapshot
    ) throws {
        let started =
            Self.monotonicNanoseconds()
        try self.init(
            rootDescriptor: rootDescriptor,
            sourceSnapshot: sourceSnapshot,
            sourceAdmissionStartedMonotonicNanoseconds:
                started,
            sourceAdmissionMaximumSeconds:
                30
        )
    }

    deinit {
        close()
    }

    static func requireLocalAPFS(
        rootDescriptor: Int32
    ) throws -> String {
        try localAPFSFilesystemIdentity(
            descriptor: rootDescriptor,
            context:
                "source_filesystem"
        ).typeName
    }

    static func requireSameLocalAPFSFilesystemForTesting(
        rootDescriptor: Int32,
        candidateDescriptor: Int32
    ) throws {
        let rootIdentity =
            try localAPFSFilesystemIdentity(
                descriptor:
                    rootDescriptor,
                context:
                    "source_test_root_filesystem"
            )
        try requireFilesystemIdentity(
            descriptor:
                candidateDescriptor,
            expected:
                rootIdentity,
            context:
                "source_test_candidate_filesystem"
        )
    }

    private static func localAPFSFilesystemIdentity(
        descriptor: Int32,
        context: String
    ) throws -> LocalAPFSFilesystemIdentity {
        guard descriptor >= 3,
              fcntl(
                  descriptor,
                  F_GETFD
              ) & FD_CLOEXEC != 0
        else {
            throw rejected(
                "\(context)_descriptor"
            )
        }
        var filesystem = statfs()
        errno = 0
        guard fstatfs(
            descriptor,
            &filesystem
        ) == 0
        else {
            throw rejected(
                "\(context)_statfs_\(errno)"
            )
        }
        guard filesystem.f_flags
                & UInt32(MNT_LOCAL)
                != 0
        else {
            throw rejected(
                "\(context)_local"
            )
        }
        var typeField =
            filesystem.f_fstypename
        let typeData =
            withUnsafeBytes(
                of: &typeField
            ) {
                Data(
                    $0.prefix {
                        $0 != 0
                    }
                )
            }
        guard let type =
                String(
                    data: typeData,
                    encoding: .utf8
                ),
              type == "apfs"
        else {
            throw rejected(
                "\(context)_type"
            )
        }
        return LocalAPFSFilesystemIdentity(
            typeName: type,
            fsidWord0:
                filesystem.f_fsid.val.0,
            fsidWord1:
                filesystem.f_fsid.val.1
        )
    }

    private static func requireFilesystemIdentity(
        descriptor: Int32,
        expected:
            LocalAPFSFilesystemIdentity,
        context: String
    ) throws {
        let observed =
            try localAPFSFilesystemIdentity(
                descriptor: descriptor,
                context: context
            )
        guard observed == expected else {
            throw rejected(
                "\(context)_identity"
            )
        }
    }

    func validateBeforeResume() throws
        -> UInt64
    {
        guard preResumeValidationMonotonicNanoseconds
                == nil,
              postReapValidationMonotonicNanoseconds
                == nil
        else {
            throw Self.rejected(
                "source_pre_resume_duplicate"
            )
        }
        let checkpoint =
            try validateCheckpoint(
                context: "pre_resume"
            )
        preResumePendingEventCount =
            checkpoint.pendingEventCount
        preResumeValidationMonotonicNanoseconds =
            checkpoint.monotonicNanoseconds
        return checkpoint
            .monotonicNanoseconds
    }

    func validateAfterReap() throws
        -> UInt64
    {
        guard preResumeValidationMonotonicNanoseconds
                != nil,
              postReapValidationMonotonicNanoseconds
                == nil
        else {
            throw Self.rejected(
                "source_post_reap_order"
            )
        }
        let checkpoint =
            try validateCheckpoint(
                context: "post_reap"
            )
        postReapPendingEventCount =
            checkpoint.pendingEventCount
        postReapValidationMonotonicNanoseconds =
            checkpoint.monotonicNanoseconds
        return checkpoint
            .monotonicNanoseconds
    }

    func observation(
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) throws
        -> PrimeNativeNeuralGateSourceClosureMutationGuardObservation
    {
        guard !poisoned,
              !closed,
              watchersArmedMonotonicNanoseconds
                > 0,
              initialValidationMonotonicNanoseconds
                > 0,
              let preResumeValidationMonotonicNanoseconds,
              let postReapValidationMonotonicNanoseconds,
              let preResumePendingEventCount,
              let postReapPendingEventCount
        else {
            throw Self.rejected(
                "source_observation_incomplete"
            )
        }
        let observations =
            try directoryInitialInventories
            .keys
            .sorted()
            .map { path in
                guard let inventory =
                        directoryInitialInventories[
                            path
                        ]
                else {
                    throw Self.rejected(
                        "source_inventory_missing"
                    )
                }
                let data =
                    try PrimeCanonicalJSON
                    .encode(inventory)
                return
                    PrimeNativeNeuralGateSourceClosureDirectoryInventoryObservation(
                        relativePath: path,
                        entryCount:
                            inventory.count,
                        inventorySHA256:
                            PrimeSHA256
                            .hexDigest(
                                of: data
                            )
                    )
            }
        return
            PrimeNativeNeuralGateSourceClosureMutationGuardObservation(
                maximumFileCount:
                    PrimeSwiftSourceProvenance
                    .maximumSnapshotFileCount,
                maximumDirectoryCount:
                    PrimeSwiftSourceProvenance
                    .maximumSnapshotDirectoryCount,
                maximumAggregateByteCount:
                    PrimeSwiftSourceProvenance
                    .maximumSnapshotAggregateBytes,
                maximumRelativeDepth:
                    PrimeSwiftSourceProvenance
                    .maximumSnapshotRelativeDepth,
                sourceAdmissionMaximumSeconds:
                    sourceAdmissionMaximumSeconds,
                sourceAdmissionStartedMonotonicNanoseconds:
                    sourceAdmissionStartedMonotonicNanoseconds,
                sourceAdmissionCompletedMonotonicNanoseconds:
                    sourceAdmissionCompletedMonotonicNanoseconds,
                localFilesystemObserved:
                    true,
                filesystemType:
                    filesystemType,
                heldFileDescriptorCount:
                    fileRecords.count,
                heldDirectoryDescriptorCount:
                    directoryDescriptors.count,
                aggregateFileByteCount:
                    aggregateFileByteCount,
                sourceSnapshotSHA256:
                    sourceSnapshotSHA256,
                directoryInventories:
                    observations,
                kqueueVnodeFilter:
                    Self.expectedVnodeFilter,
                fileVnodeNoteMask:
                    Self.vnodeNoteMask,
                directoryVnodeNoteMask:
                    Self.vnodeNoteMask,
                watcherCount:
                    watcherPathByDescriptor
                    .count,
                registrationReceiptCount:
                    registrationReceiptCount,
                registrationReceiptErrorCount:
                    registrationReceiptErrorCount,
                watchersArmedMonotonicNanoseconds:
                    watchersArmedMonotonicNanoseconds,
                initialValidationMonotonicNanoseconds:
                    initialValidationMonotonicNanoseconds,
                preResumeValidationMonotonicNanoseconds:
                    preResumeValidationMonotonicNanoseconds,
                postReapValidationMonotonicNanoseconds:
                    postReapValidationMonotonicNanoseconds,
                initialPendingEventCount:
                    initialPendingEventCount,
                preResumePendingEventCount:
                    preResumePendingEventCount,
                postReapPendingEventCount:
                    postReapPendingEventCount,
                repositoryBuildDirectoryUnused:
                    true,
                allDescriptorsHeld: true,
                allFileBytesMatchedSnapshot:
                    true,
                allFileMetadataStable: true,
                allDirectoryInventoriesStable:
                    true,
                allPathsRejoinedHeldVnodes:
                    true,
                contract: contract
            )
    }

    /// Internal-only calibration hook. Observing any event poisons this
    /// instance, matching production's fail-closed behavior.
    func drainPendingEventsForTesting(
        maximumEventCount: Int,
        maximumDurationNanoseconds:
            UInt64
    ) throws
        -> [VnodeEvent]
    {
        guard !poisoned,
              maximumEventCount > 0,
              maximumEventCount
                <= Self.maximumTestingEventCount,
              maximumDurationNanoseconds > 0,
              maximumDurationNanoseconds
                <= Self
                .maximumTestingEventCollectionNanoseconds
        else {
            throw Self.rejected(
                "source_testing_event_bounds"
            )
        }
        let started =
            Self.monotonicNanoseconds()
        let deadline =
            started.addingReportingOverflow(
                maximumDurationNanoseconds
            )
        guard !deadline.overflow else {
            throw Self.rejected(
                "source_testing_event_deadline"
            )
        }
        var events: [VnodeEvent] = []
        while events.count
                < maximumEventCount,
              Self.monotonicNanoseconds()
                <= deadline.partialValue
        {
            let remaining =
                maximumEventCount
                - events.count
            let batch =
                try pollPendingEventBatch(
                    maximumEventCount:
                        min(
                            remaining,
                            Self
                            .testingEventBatchCount
                    ),
                    maximumAttemptCount:
                        Self
                        .maximumProductionPollAttemptCount
                )
            guard !batch.isEmpty else {
                break
            }
            events.append(
                contentsOf: batch
            )
        }
        if !events.isEmpty {
            poisoned = true
        }
        return events
    }

    func close() {
        guard !closed else {
            return
        }
        closed = true
        if queueDescriptor >= 0 {
            _ = Darwin.close(
                queueDescriptor
            )
            queueDescriptor = -1
        }
        for file in fileRecords {
            if file.descriptor >= 0 {
                _ = Darwin.close(
                    file.descriptor
                )
            }
        }
        fileRecords.removeAll(
            keepingCapacity: false
        )
        for descriptor in
            directoryDescriptors.values
            where descriptor >= 0
        {
            _ = Darwin.close(
                descriptor
            )
        }
        directoryDescriptors.removeAll(
            keepingCapacity: false
        )
        watcherPathByDescriptor.removeAll(
            keepingCapacity: false
        )
    }

    private func admitDirectory(
        relativePath: String,
        descriptor: Int32
    ) throws {
        do {
            guard directoryDescriptors.count
                    < PrimeSwiftSourceProvenance
                    .maximumSnapshotDirectoryCount,
                  descriptor >= 3,
                  fcntl(
                      descriptor,
                      F_GETFD
                  ) & FD_CLOEXEC != 0
            else {
                throw Self.rejected(
                    "source_directory_descriptor"
                )
            }
            var status = stat()
            try Self.requireFilesystemIdentity(
                descriptor: descriptor,
                expected:
                    rootFilesystemIdentity,
                context:
                    "source_directory_filesystem"
            )
            guard fstat(
                descriptor,
                &status
            ) == 0,
            status.st_mode
                & mode_t(S_IFMT)
                == mode_t(S_IFDIR),
            status.st_uid == geteuid(),
            status.st_mode & mode_t(0o022)
                == 0,
            status.st_ino > 0,
            directoryDescriptors[
                relativePath
            ] == nil
            else {
                throw Self.rejected(
                    "source_directory_admission"
                )
            }
            try registerWatcher(
                descriptor: descriptor,
                relativePath: relativePath,
                isDirectory: true
            )
            directoryDescriptors[
                relativePath
            ] = descriptor
            directoryInitialStatuses[
                relativePath
            ] = status
        } catch {
            _ = Darwin.close(
                descriptor
            )
            throw error
        }
    }

    private func admitFile(
        snapshot:
            PrimeSwiftSourceFileSnapshot,
        descriptor: Int32
    ) throws {
        do {
            guard fileRecords.count
                    < PrimeSwiftSourceProvenance
                    .maximumSnapshotFileCount,
                  descriptor >= 3,
                  fcntl(
                      descriptor,
                      F_GETFD
                  ) & FD_CLOEXEC != 0
            else {
                throw Self.rejected(
                    "source_file_descriptor"
                )
            }
            var status = stat()
            try Self.requireFilesystemIdentity(
                descriptor: descriptor,
                expected:
                    rootFilesystemIdentity,
                context:
                    "source_file_filesystem"
            )
            guard fstat(
                descriptor,
                &status
            ) == 0,
            status.st_mode
                & mode_t(S_IFMT)
                == mode_t(S_IFREG),
            status.st_uid == geteuid(),
            status.st_mode & mode_t(0o022)
                == 0,
            status.st_nlink == 1,
            status.st_size >= 0,
            UInt64(status.st_size)
                == snapshot.byteCount,
            status.st_ino > 0
            else {
                throw Self.rejected(
                    "source_file_admission"
                )
            }
            try registerWatcher(
                descriptor: descriptor,
                relativePath:
                    snapshot.relativePath,
                isDirectory: false
            )
            fileRecords.append(
                HeldFile(
                    snapshot: snapshot,
                    descriptor: descriptor,
                    initialStatus: status
                )
            )
        } catch {
            _ = Darwin.close(
                descriptor
            )
            throw error
        }
    }

    private func registerWatcher(
        descriptor: Int32,
        relativePath: String,
        isDirectory: Bool
    ) throws {
        guard queueDescriptor >= 3,
              watcherPathByDescriptor[
                  descriptor
              ] == nil
        else {
            throw Self.rejected(
                "source_watcher_state"
            )
        }
        var change =
            kevent(
                ident: UInt(descriptor),
                filter:
                    Self.expectedVnodeFilter,
                flags:
                    Self.registrationFlags,
                fflags:
                    Self.vnodeNoteMask,
                data: 0,
                udata: nil
            )
        var receipt =
            kevent(
                ident: 0,
                filter: 0,
                flags: 0,
                fflags: 0,
                data: 0,
                udata: nil
            )
        errno = 0
        let returned =
            kevent(
                queueDescriptor,
                &change,
                1,
                &receipt,
                1,
                nil
            )
        guard returned == 1,
              receipt.ident
                == UInt(descriptor),
              receipt.filter
                == Self.expectedVnodeFilter,
              receipt.flags
                & UInt16(EV_ERROR)
                != 0,
              receipt.data == 0
        else {
            registrationReceiptErrorCount += 1
            throw Self.rejected(
                "source_watcher_receipt_\(returned)_\(errno)"
            )
        }
        registrationReceiptCount += 1
        watcherPathByDescriptor[
            descriptor
        ] = (
            relativePath,
            isDirectory
        )
        let pending =
            try pollFirstPendingEvent()
        guard pending == nil else {
            poisoned = true
            throw Self.rejected(
                "source_event_during_registration"
            )
        }
    }

    private func establishInitialState()
        throws
    {
        for file in fileRecords {
            try validate(
                file: file
            )
        }
        var totalEntries = 0
        for path in
            directoryDescriptors.keys.sorted()
        {
            guard let descriptor =
                    directoryDescriptors[path]
            else {
                throw Self.rejected(
                    "source_directory_missing"
                )
            }
            let inventory =
                try directoryInventory(
                    descriptor: descriptor
                )
            try rejectVersionSpecificRootManifest(
                relativePath: path,
                inventory: inventory
            )
            totalEntries +=
                inventory.count
            guard totalEntries
                    <= Self
                    .maximumAggregateDirectoryEntryCount
            else {
                throw Self.rejected(
                    "source_inventory_aggregate"
                )
            }
            directoryInitialInventories[
                path
            ] = inventory
        }
        try requireAllPathsRejoin()
    }

    private func validateCheckpoint(
        context: String
    ) throws
        -> (
            pendingEventCount: Int,
            monotonicNanoseconds: UInt64
        )
    {
        guard !poisoned,
              !closed
        else {
            throw Self.rejected(
                "source_monitor_poisoned"
            )
        }
        let before =
            try pollFirstPendingEvent()
        guard before == nil else {
            poisoned = true
            throw Self.rejected(
                "source_event_before_\(context)"
            )
        }
        for file in fileRecords {
            try validate(
                file: file
            )
        }
        var totalEntries = 0
        for path in
            directoryDescriptors.keys.sorted()
        {
            guard let descriptor =
                    directoryDescriptors[path],
                  let expected =
                    directoryInitialInventories[
                        path
                    ]
            else {
                throw Self.rejected(
                    "source_inventory_missing"
                )
            }
            var currentStatus = stat()
            try Self.requireFilesystemIdentity(
                descriptor: descriptor,
                expected:
                    rootFilesystemIdentity,
                context:
                    "source_directory_checkpoint_filesystem"
            )
            guard fstat(
                descriptor,
                &currentStatus
            ) == 0,
            let initialStatus =
                directoryInitialStatuses[
                    path
                ],
            Self.sameDirectoryIdentity(
                initialStatus,
                currentStatus
            )
            else {
                throw Self.rejected(
                    "source_directory_metadata_\(context)"
                )
            }
            let observed =
                try directoryInventory(
                    descriptor: descriptor
                )
            try rejectVersionSpecificRootManifest(
                relativePath: path,
                inventory: observed
            )
            totalEntries +=
                observed.count
            guard totalEntries
                    <= Self
                    .maximumAggregateDirectoryEntryCount,
                  observed == expected
            else {
                throw Self.rejected(
                    "source_directory_inventory_\(context)"
                )
            }
        }
        try requireAllPathsRejoin()
        let after =
            try pollFirstPendingEvent()
        guard after == nil else {
            poisoned = true
            throw Self.rejected(
                "source_event_during_\(context)"
            )
        }
        return (
            0,
            Self.monotonicNanoseconds()
        )
    }

    private func validate(
        file: HeldFile
    ) throws {
        var currentStatus = stat()
        try Self.requireFilesystemIdentity(
            descriptor:
                file.descriptor,
            expected:
                rootFilesystemIdentity,
            context:
                "source_file_checkpoint_filesystem"
        )
        guard fstat(
            file.descriptor,
            &currentStatus
        ) == 0,
        Self.sameRegularFileIdentity(
            file.initialStatus,
            currentStatus
        ),
        currentStatus.st_uid
            == geteuid(),
        currentStatus.st_mode
            & mode_t(0o022)
            == 0,
        currentStatus.st_nlink == 1
        else {
            throw Self.rejected(
                "source_file_metadata"
            )
        }
        let data =
            try Self.readExactDescriptor(
                file.descriptor,
                byteCount:
                    file.snapshot.byteCount
            )
        guard data
                == file.snapshot.contents,
              PrimeSHA256.hexDigest(
                  of: data
              ) == file.snapshot.sha256
        else {
            throw Self.rejected(
                "source_file_bytes"
            )
        }
        var after = stat()
        guard fstat(
            file.descriptor,
            &after
        ) == 0,
        Self.sameRegularFileIdentity(
            file.initialStatus,
            after
        )
        else {
            throw Self.rejected(
                "source_file_read_race"
            )
        }
    }

    private func directoryInventory(
        descriptor: Int32
    ) throws -> [DirectoryEntryRecord] {
        let enumerationDescriptor =
            try Self.normalizedDescriptor(
                openat(
                    descriptor,
                    ".",
                    O_RDONLY
                        | O_DIRECTORY
                        | O_NOFOLLOW_ANY
                        | O_CLOEXEC
                ),
                context:
                    "source_inventory_open"
            )
        guard let directory =
                fdopendir(
                    enumerationDescriptor
                )
        else {
            let failure = errno
            _ = Darwin.close(
                enumerationDescriptor
            )
            throw Self.rejected(
                "source_inventory_fdopendir_\(failure)"
            )
        }
        defer {
            _ = closedir(directory)
        }
        var records:
            [DirectoryEntryRecord] = []
        while true {
            errno = 0
            guard let pointer =
                    readdir(directory)
            else {
                guard errno == 0 else {
                    throw Self.rejected(
                        "source_inventory_readdir_\(errno)"
                    )
                }
                break
            }
            let entry = pointer.pointee
            let length =
                Int(entry.d_namlen)
            guard length > 0,
                  length <= Int(MAXNAMLEN)
            else {
                throw Self.rejected(
                    "source_inventory_name_length"
                )
            }
            var nameField =
                entry.d_name
            let nameData =
                withUnsafeBytes(
                    of: &nameField
                ) {
                    Data(
                        $0.prefix(length)
                    )
                }
            guard let name =
                    String(
                        data: nameData,
                        encoding: .utf8
                    ),
                  !name.isEmpty,
                  !name.contains("\0"),
                  !name.contains("/")
            else {
                throw Self.rejected(
                    "source_inventory_name"
                )
            }
            if name == "."
                || name == ".."
            {
                continue
            }
            records.append(
                DirectoryEntryRecord(
                    name: name,
                    inode:
                        UInt64(entry.d_ino),
                    fileType:
                        entry.d_type
                )
            )
            guard records.count
                    <= Self
                    .maximumDirectoryEntryCount
            else {
                throw Self.rejected(
                    "source_inventory_count"
                )
            }
        }
        records.sort {
            if $0.name != $1.name {
                return $0.name < $1.name
            }
            if $0.inode != $1.inode {
                return $0.inode
                    < $1.inode
            }
            return $0.fileType
                < $1.fileType
        }
        let names =
            records.map(\.name)
        guard Set(names).count
                == names.count
        else {
            throw Self.rejected(
                "source_inventory_duplicates"
            )
        }
        return records
    }

    private func rejectVersionSpecificRootManifest(
        relativePath: String,
        inventory:
            [DirectoryEntryRecord]
    ) throws {
        guard relativePath.isEmpty else {
            return
        }
        guard !inventory.contains(where: {
            $0.name
                .hasPrefix(
                    "Package@swift-"
                )
                && $0.name
                .hasSuffix(".swift")
        }) else {
            throw Self.rejected(
                "source_root_version_specific_package_manifest"
            )
        }
    }

    private func requireAllPathsRejoin()
        throws
    {
        for path in
            directoryDescriptors.keys.sorted()
        {
            guard let heldDescriptor =
                    directoryDescriptors[path],
                  let expectedStatus =
                    directoryInitialStatuses[
                        path
                    ]
            else {
                throw Self.rejected(
                    "source_directory_rejoin_state"
                )
            }
            var heldStatus = stat()
            try Self.requireFilesystemIdentity(
                descriptor:
                    heldDescriptor,
                expected:
                    rootFilesystemIdentity,
                context:
                    "source_directory_rejoin_held_filesystem"
            )
            guard fstat(
                heldDescriptor,
                &heldStatus
            ) == 0,
            Self.sameDirectoryIdentity(
                expectedStatus,
                heldStatus
            )
            else {
                throw Self.rejected(
                    "source_directory_held_changed"
                )
            }
            let rejoined =
                try reopenFromRoot(
                    relativePath: path,
                    isDirectory: true
                )
            defer {
                _ = Darwin.close(
                    rejoined
                )
            }
            var rejoinedStatus = stat()
            try Self.requireFilesystemIdentity(
                descriptor: rejoined,
                expected:
                    rootFilesystemIdentity,
                context:
                    "source_directory_rejoin_path_filesystem"
            )
            guard fstat(
                rejoined,
                &rejoinedStatus
            ) == 0,
            Self.sameDirectoryIdentity(
                heldStatus,
                rejoinedStatus
            )
            else {
                throw Self.rejected(
                    "source_directory_path_rejoin"
                )
            }
        }

        for file in fileRecords {
            var heldStatus = stat()
            try Self.requireFilesystemIdentity(
                descriptor:
                    file.descriptor,
                expected:
                    rootFilesystemIdentity,
                context:
                    "source_file_rejoin_held_filesystem"
            )
            guard fstat(
                file.descriptor,
                &heldStatus
            ) == 0,
            Self.sameRegularFileIdentity(
                file.initialStatus,
                heldStatus
            )
            else {
                throw Self.rejected(
                    "source_file_held_changed"
                )
            }
            let rejoined =
                try reopenFromRoot(
                    relativePath:
                        file.snapshot
                        .relativePath,
                    isDirectory: false
                )
            defer {
                _ = Darwin.close(
                    rejoined
                )
            }
            var rejoinedStatus = stat()
            try Self.requireFilesystemIdentity(
                descriptor: rejoined,
                expected:
                    rootFilesystemIdentity,
                context:
                    "source_file_rejoin_path_filesystem"
            )
            guard fstat(
                rejoined,
                &rejoinedStatus
            ) == 0,
            Self.sameRegularFileIdentity(
                heldStatus,
                rejoinedStatus
            )
            else {
                throw Self.rejected(
                    "source_file_path_rejoin"
                )
            }
        }
    }

    private func reopenFromRoot(
        relativePath: String,
        isDirectory: Bool
    ) throws -> Int32 {
        guard let rootDescriptor =
                directoryDescriptors[""]
        else {
            throw Self.rejected(
                "source_rejoin_root"
            )
        }
        var current =
            try Self.duplicateDescriptor(
                rootDescriptor,
                context:
                    "source_rejoin_duplicate"
            )
        if relativePath.isEmpty {
            return current
        }
        let components =
            relativePath.split(
                separator: "/"
            )
        for (index, component) in
            components.enumerated()
        {
            let final =
                index == components.count - 1
            let next: Int32
            do {
                next =
                    try Self.openRelativeLeaf(
                        directory: current,
                        leaf:
                            String(component),
                        isDirectory:
                            final
                            ? isDirectory
                            : true
                    )
            } catch {
                _ = Darwin.close(
                    current
                )
                throw error
            }
            _ = Darwin.close(
                current
            )
            current = next
        }
        return current
    }

    private func pollFirstPendingEvent()
        throws -> VnodeEvent?
    {
        let events =
            try pollPendingEventBatch(
                maximumEventCount:
                    Self
                    .productionPendingEventMaximumCount,
                maximumAttemptCount:
                    Self
                    .maximumProductionPollAttemptCount
            )
        guard events.count <= 1 else {
            poisoned = true
            throw Self.rejected(
                "source_kqueue_production_event_bound"
            )
        }
        guard let event = events.first else {
            return nil
        }
        poisoned = true
        return event
    }

    private func pollPendingEventBatch(
        maximumEventCount: Int,
        maximumAttemptCount: Int
    ) throws -> [VnodeEvent] {
        guard queueDescriptor >= 3,
              !closed,
              maximumEventCount > 0,
              maximumEventCount
                <= Self.testingEventBatchCount,
              maximumAttemptCount > 0
        else {
            throw Self.rejected(
                "source_kqueue_closed"
            )
        }
        var rawEvents = [
            DarwinKevent
        ](
            repeating:
                kevent(
                    ident: 0,
                    filter: 0,
                    flags: 0,
                    fflags: 0,
                    data: 0,
                    udata: nil
                ),
            count:
                maximumEventCount
        )
        for _ in 0 ..<
            maximumAttemptCount
        {
            var timeout =
                timespec(
                    tv_sec: 0,
                    tv_nsec: 0
                )
            errno = 0
            let returned =
                rawEvents
                .withUnsafeMutableBufferPointer {
                    kevent(
                        queueDescriptor,
                        nil,
                        0,
                        $0.baseAddress,
                        Int32($0.count),
                        &timeout
                    )
                }
            if returned < 0,
               errno == EINTR
            {
                continue
            }
            guard returned >= 0 else {
                poisoned = true
                throw Self.rejected(
                    "source_kqueue_poll_\(errno)"
                )
            }
            guard returned > 0 else {
                return []
            }
            var result: [VnodeEvent] = []
            result.reserveCapacity(
                Int(returned)
            )
            for event in rawEvents.prefix(
                Int(returned)
            ) {
                guard event.filter
                        == Self
                        .expectedVnodeFilter,
                      let descriptor =
                        Int32(
                            exactly:
                                event.ident
                        ),
                      let path =
                        watcherPathByDescriptor[
                            descriptor
                        ],
                      event.flags
                        & UInt16(EV_ERROR)
                        == 0,
                      event.fflags != 0
                else {
                    poisoned = true
                    throw Self.rejected(
                        "source_kqueue_event"
                    )
                }
                result.append(
                    VnodeEvent(
                        relativePath:
                            path.relativePath,
                        isDirectory:
                            path.isDirectory,
                        noteMask:
                            event.fflags
                    )
                )
            }
            return result
        }
        poisoned = true
        throw Self.rejected(
            "source_kqueue_interrupt_limit"
        )
    }

    private static func authorityDirectoryPaths(
        for snapshot:
            PrimeSwiftSourceSnapshot
    ) -> [String] {
        var paths: Set<String> = [""]
        for file in snapshot.files {
            let components =
                file.relativePath.split(
                    separator: "/"
                )
            guard components.count > 1
            else {
                continue
            }
            for count in
                1 ..< components.count
            {
                paths.insert(
                    components
                        .prefix(count)
                        .joined(
                            separator: "/"
                        )
                )
            }
        }
        return paths.sorted {
            let lhsDepth =
                $0.isEmpty
                ? 0
                : $0.split(
                    separator: "/"
                ).count
            let rhsDepth =
                $1.isEmpty
                ? 0
                : $1.split(
                    separator: "/"
                ).count
            if lhsDepth != rhsDepth {
                return lhsDepth
                    < rhsDepth
            }
            return $0 < $1
        }
    }

    private static func validateAdmission(
        _ snapshot:
            PrimeSwiftSourceSnapshot
    ) throws -> UInt64 {
        guard !snapshot.files.isEmpty,
              snapshot.files.count
                <= PrimeSwiftSourceProvenance
                .maximumSnapshotFileCount
        else {
            throw rejected(
                "source_snapshot_file_count"
            )
        }
        var aggregate: UInt64 = 0
        var paths = Set<String>()
        for file in snapshot.files {
            let components =
                file.relativePath.split(
                    separator: "/",
                    omittingEmptySubsequences:
                        false
                )
            guard !file.relativePath.isEmpty,
                  !file.relativePath
                    .hasPrefix("/"),
                  !file.relativePath
                    .contains("\0"),
                  components.count
                    <= PrimeSwiftSourceProvenance
                    .maximumSnapshotRelativeDepth,
                  components.allSatisfy({
                      !$0.isEmpty
                          && $0 != "."
                          && $0 != ".."
                  }),
                  paths.insert(
                      file.relativePath
                  ).inserted,
                  file.byteCount
                    == UInt64(
                        file.contents.count
                    ),
                  file.byteCount
                    <= 8 * 1024 * 1024,
                  file.sha256
                    == PrimeSHA256
                    .hexDigest(
                        of:
                            file.contents
                    )
            else {
                throw rejected(
                    "source_snapshot_file"
                )
            }
            let next =
                aggregate
                .addingReportingOverflow(
                    file.byteCount
                )
            guard !next.overflow,
                  next.partialValue
                    <= PrimeSwiftSourceProvenance
                    .maximumSnapshotAggregateBytes
            else {
                throw rejected(
                    "source_snapshot_aggregate"
                )
            }
            aggregate =
                next.partialValue
        }
        let ordered =
            snapshot.files
            .map(\.relativePath)
        guard ordered == ordered.sorted(),
              authorityDirectoryPaths(
                  for: snapshot
              ).count
                <= PrimeSwiftSourceProvenance
                .maximumSnapshotDirectoryCount
        else {
            throw rejected(
                "source_snapshot_order_or_directory_count"
            )
        }
        return aggregate
    }

    private static func parentRelativePath(
        of relativePath: String
    ) -> String? {
        let components =
            relativePath.split(
                separator: "/"
            )
        guard components.count > 1
        else {
            return ""
        }
        return components.dropLast()
            .joined(
                separator: "/"
            )
    }

    private static func leafName(
        of relativePath: String
    ) -> String {
        String(
            relativePath.split(
                separator: "/"
            ).last ?? ""
        )
    }

    private static func openRelativeLeaf(
        directory: Int32,
        leaf: String,
        isDirectory: Bool
    ) throws -> Int32 {
        guard directory >= 3,
              !leaf.isEmpty,
              leaf != ".",
              leaf != "..",
              !leaf.contains("/"),
              !leaf.contains("\0")
        else {
            throw rejected(
                "source_relative_leaf"
            )
        }
        let flags =
            O_RDONLY
            | O_NOFOLLOW_ANY
            | O_CLOEXEC
            | (
                isDirectory
                ? O_DIRECTORY
                : 0
            )
        return try normalizedDescriptor(
            openat(
                directory,
                leaf,
                flags
            ),
            context:
                isDirectory
                ? "source_directory_open"
                : "source_file_open"
        )
    }

    private static func duplicateDescriptor(
        _ descriptor: Int32,
        context: String
    ) throws -> Int32 {
        guard descriptor >= 3 else {
            throw rejected(
                "\(context)_source"
            )
        }
        return try normalizedDescriptor(
            fcntl(
                descriptor,
                F_DUPFD_CLOEXEC,
                3
            ),
            context: context
        )
    }

    private static func normalizedDescriptor(
        _ descriptor: Int32,
        context: String
    ) throws -> Int32 {
        guard descriptor >= 0 else {
            throw rejected(
                "\(context)_\(errno)"
            )
        }
        guard descriptor < 3 else {
            guard fcntl(
                descriptor,
                F_GETFD
            ) & FD_CLOEXEC != 0
            else {
                let failure = errno
                _ = Darwin.close(
                    descriptor
                )
                throw rejected(
                    "\(context)_cloexec_\(failure)"
                )
            }
            return descriptor
        }
        let normalized =
            fcntl(
                descriptor,
                F_DUPFD_CLOEXEC,
                3
            )
        let failure = errno
        _ = Darwin.close(
            descriptor
        )
        guard normalized >= 3 else {
            throw rejected(
                "\(context)_normalize_\(failure)"
            )
        }
        return normalized
    }

    private static func readExactDescriptor(
        _ descriptor: Int32,
        byteCount: UInt64
    ) throws -> Data {
        guard byteCount
                <= UInt64(Int.max)
        else {
            throw rejected(
                "source_descriptor_size"
            )
        }
        var result = Data()
        result.reserveCapacity(
            Int(byteCount)
        )
        var buffer = [UInt8](
            repeating: 0,
            count:
                readChunkByteCount
        )
        var offset: UInt64 = 0
        while offset < byteCount {
            let remaining =
                byteCount - offset
            let requested =
                Int(
                    min(
                        UInt64(buffer.count),
                        remaining
                    )
                )
            let count =
                buffer
                .withUnsafeMutableBytes {
                    pread(
                        descriptor,
                        $0.baseAddress,
                        requested,
                        off_t(offset)
                    )
                }
            if count < 0,
               errno == EINTR
            {
                continue
            }
            guard count > 0 else {
                throw rejected(
                    "source_descriptor_read_\(errno)"
                )
            }
            result.append(
                contentsOf:
                    buffer[0 ..< count]
            )
            offset +=
                UInt64(count)
        }
        var trailing: UInt8 = 0
        let trailingCount =
            withUnsafeMutablePointer(
                to: &trailing
            ) {
                pread(
                    descriptor,
                    $0,
                    1,
                    off_t(byteCount)
                )
            }
        guard trailingCount == 0,
              result.count
                == Int(byteCount)
        else {
            throw rejected(
                "source_descriptor_trailing"
            )
        }
        return result
    }

    private static func sameRegularFileIdentity(
        _ lhs: stat,
        _ rhs: stat
    ) -> Bool {
        lhs.st_dev == rhs.st_dev
            && lhs.st_ino == rhs.st_ino
            && lhs.st_size == rhs.st_size
            && lhs.st_uid == rhs.st_uid
            && lhs.st_gid == rhs.st_gid
            && lhs.st_mode == rhs.st_mode
            && lhs.st_nlink == rhs.st_nlink
            && lhs.st_mtimespec.tv_sec
                == rhs.st_mtimespec.tv_sec
            && lhs.st_mtimespec.tv_nsec
                == rhs.st_mtimespec.tv_nsec
            && lhs.st_ctimespec.tv_sec
                == rhs.st_ctimespec.tv_sec
            && lhs.st_ctimespec.tv_nsec
                == rhs.st_ctimespec.tv_nsec
    }

    private static func sameDirectoryIdentity(
        _ lhs: stat,
        _ rhs: stat
    ) -> Bool {
        lhs.st_dev == rhs.st_dev
            && lhs.st_ino == rhs.st_ino
            && lhs.st_uid == rhs.st_uid
            && lhs.st_gid == rhs.st_gid
            && lhs.st_mode == rhs.st_mode
            && lhs.st_nlink == rhs.st_nlink
            && lhs.st_mtimespec.tv_sec
                == rhs.st_mtimespec.tv_sec
            && lhs.st_mtimespec.tv_nsec
                == rhs.st_mtimespec.tv_nsec
            && lhs.st_ctimespec.tv_sec
                == rhs.st_ctimespec.tv_sec
            && lhs.st_ctimespec.tv_nsec
                == rhs.st_ctimespec.tv_nsec
    }

    private static func requireCalibratedKqueueABI()
        throws
    {
        guard MemoryLayout<kevent>.size == 32,
              MemoryLayout<kevent>.stride == 32,
              MemoryLayout<kevent>.alignment == 4,
              expectedVnodeFilter == -4,
              vnodeNoteMask == 0x7f
        else {
            throw rejected(
                "source_kqueue_abi"
            )
        }
    }

    private static func monotonicNanoseconds(
        strictlyAfter prior: UInt64? = nil
    ) -> UInt64 {
        var observed =
            DispatchTime.now()
            .uptimeNanoseconds
        if let prior {
            while observed <= prior {
                sched_yield()
                observed =
                    DispatchTime.now()
                    .uptimeNanoseconds
            }
        }
        return observed
    }

    private static func rejected(
        _ detail: String
    ) -> PrimeNativeNeuralGateSecureExternalChildCaptureError {
        .rejected(detail)
    }
}
