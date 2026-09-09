import Darwin
import Dispatch
import Foundation

/// A PrimeCore-owned, per-child SwiftPM scratch namespace.
///
/// The namespace is intentionally not removed by this type. Recursive,
/// path-based cleanup after releasing held descriptors would turn a
/// non-authoritative scratch path into deletion authority.
final class PrimeNativeNeuralGateSecureScratchNamespace {
    private typealias DarwinKevent = Darwin.kevent

    struct LaunchConfiguration:
        Equatable,
        Sendable
    {
        let arguments: [String]
        let orderedEnvironment: [(String, String)]

        static func == (
            lhs: Self,
            rhs: Self
        ) -> Bool {
            lhs.arguments == rhs.arguments
                && lhs.orderedEnvironment.map {
                    [$0.0, $0.1]
                } == rhs.orderedEnvironment.map {
                    [$0.0, $0.1]
                }
        }
    }

    private struct FilesystemIdentity:
        Equatable
    {
        let typeName: String
        let fsidWord0: Int32
        let fsidWord1: Int32
    }

    private struct HeldDirectory {
        let name: String
        let absolutePath: String
        var descriptor: Int32
        let initialStatus: stat
    }

    private struct AuditResult {
        let fileCount: Int
        let directoryCount: Int
        let aggregateByteCount: UInt64
        let textEncodingObservedCount: Int
        let cacheEmpty: Bool
        let configEmpty: Bool
        let securityEmpty: Bool
        let resolutionResiduePathCount:
            Int
    }

    static let exactDirectoryNames = [
        "work",
        "cache",
        "config",
        "security",
        "home",
        "tmp",
        "module-cache",
    ]
    static let maximumPostAuditFileCount =
        65_536
    static let maximumPostAuditDirectoryCount =
        8_192
    static let maximumPostAuditAggregateByteCount:
        UInt64 = 1_073_741_824
    static let maximumPostAuditRelativeDepth =
        32
    static let maximumPostAuditSeconds:
        UInt64 = 2
    static let destructiveVnodeNoteMask =
        UInt32(NOTE_DELETE)
        | UInt32(NOTE_ATTRIB)
        | UInt32(NOTE_RENAME)
        | UInt32(NOTE_REVOKE)

    let role:
        PrimeNativeNeuralGateReleaseProcessRole
    let runRootAbsolutePath: String
    private(set) var runRootDescriptor: Int32
    private let sourceFilesystemIdentity:
        FilesystemIdentity
    private let scratchFilesystemIdentity:
        FilesystemIdentity
    private let runRootInitialStatus: stat
    private var heldDirectories:
        [String: HeldDirectory] = [:]
    private var queueDescriptor: Int32 = -1
    private var registrationReceiptCount = 0
    private var registrationReceiptErrorCount = 0
    private var watchersArmedMonotonicNanoseconds:
        UInt64 = 0
    private var preResumeValidationMonotonicNanoseconds:
        UInt64?
    private var postReapValidationMonotonicNanoseconds:
        UInt64?
    private var preResumeDestructiveEventCount:
        Int?
    private var postReapDestructiveEventCount:
        Int?
    private var postAudit: AuditResult?
    private var postAuditStartedMonotonicNanoseconds:
        UInt64?
    private var postAuditCompletedMonotonicNanoseconds:
        UInt64?
    private var poisoned = false
    private var closed = false

    init(
        role:
            PrimeNativeNeuralGateReleaseProcessRole,
        sourceRootDescriptor: Int32
    ) throws {
        self.role = role
        sourceFilesystemIdentity =
            try Self.requireLocalAPFS(
                descriptor:
                    sourceRootDescriptor,
                context:
                    "scratch_source_filesystem"
            )
        let parentPath =
            try Self.darwinUserTemporaryDirectory()
        let parentDescriptor =
            try Self.openDirectory(
                absolutePath:
                    parentPath,
                context:
                    "scratch_parent"
            )
        defer {
            _ = Darwin.close(
                parentDescriptor
            )
        }
        let parentFilesystem =
            try Self.requireLocalAPFS(
                descriptor:
                    parentDescriptor,
                context:
                    "scratch_parent_filesystem"
            )
        guard parentFilesystem
                == sourceFilesystemIdentity
        else {
            throw Self.rejected(
                "scratch_parent_source_fsid"
            )
        }

        let template =
            parentPath
            + (
                parentPath.hasSuffix("/")
                ? ""
                : "/"
            )
            + "ergentics-prime-neural-gate-"
            + role.rawValue
            + "-XXXXXX"
        var templateBytes =
            template.utf8.map {
                CChar(bitPattern: $0)
            }
        templateBytes.append(0)
        let created =
            templateBytes
            .withUnsafeMutableBufferPointer {
                buffer -> Bool in
                guard let base =
                        buffer.baseAddress
                else {
                    return false
                }
                return mkdtemp(base) != nil
            }
        guard created else {
            throw Self.rejected(
                "scratch_run_root_create_\(errno)"
            )
        }
        runRootAbsolutePath =
            templateBytes.withUnsafeBufferPointer {
                String(
                    cString:
                        $0.baseAddress!
                )
            }
        let openedRunRootDescriptor =
            try Self.openDirectory(
                absolutePath:
                    runRootAbsolutePath,
                context:
                    "scratch_run_root"
            )
        var openedRunRootNeedsClose =
            true
        defer {
            if openedRunRootNeedsClose {
                _ = Darwin.close(
                    openedRunRootDescriptor
                )
            }
        }
        var rootStatus = stat()
        guard fstat(
            openedRunRootDescriptor,
            &rootStatus
        ) == 0,
        rootStatus.st_mode
            & mode_t(S_IFMT)
            == mode_t(S_IFDIR),
        rootStatus.st_uid == geteuid(),
        rootStatus.st_gid == getegid(),
        rootStatus.st_mode
            & mode_t(0o7777)
            == mode_t(0o700),
        rootStatus.st_nlink >= 2,
        rootStatus.st_ino > 0,
        fcntl(
            openedRunRootDescriptor,
            F_GETFD
        ) & FD_CLOEXEC != 0
        else {
            throw Self.rejected(
                "scratch_run_root_descriptor"
            )
        }
        let observedScratchFilesystemIdentity =
            try Self.requireLocalAPFS(
                descriptor:
                    openedRunRootDescriptor,
                context:
                    "scratch_run_root_filesystem"
            )
        guard observedScratchFilesystemIdentity
                == sourceFilesystemIdentity
        else {
            throw Self.rejected(
                "scratch_run_root_source_fsid"
            )
        }
        _ = try Self.requireSafeExtendedMetadata(
            descriptor:
                openedRunRootDescriptor,
            relativePath: "",
            status: rootStatus,
            context:
                "scratch_run_root_metadata"
        )
        runRootDescriptor =
            openedRunRootDescriptor
        runRootInitialStatus = rootStatus
        scratchFilesystemIdentity =
            observedScratchFilesystemIdentity
        openedRunRootNeedsClose = false

        do {
            guard try Self.directoryEntries(
                descriptor:
                    runRootDescriptor,
                context:
                    "scratch_run_root_initial"
            ).isEmpty
            else {
                throw Self.rejected(
                    "scratch_run_root_not_empty"
                )
            }
            heldDirectories[""] =
                HeldDirectory(
                    name: "",
                    absolutePath:
                        runRootAbsolutePath,
                    descriptor:
                        runRootDescriptor,
                    initialStatus:
                        rootStatus
                )
            for name in
                Self.exactDirectoryNames
            {
                guard mkdirat(
                    runRootDescriptor,
                    name,
                    mode_t(0o700)
                ) == 0
                else {
                    throw Self.rejected(
                        "scratch_directory_create_\(name)_\(errno)"
                    )
                }
                let descriptor =
                    try Self.openRelativeDirectory(
                        parentDescriptor:
                            runRootDescriptor,
                        name: name,
                        context:
                            "scratch_directory_\(name)"
                    )
                var descriptorTransferred =
                    false
                defer {
                    if !descriptorTransferred {
                        _ = Darwin.close(
                            descriptor
                        )
                    }
                }
                var status = stat()
                guard fstat(
                    descriptor,
                    &status
                ) == 0,
                status.st_mode
                    & mode_t(S_IFMT)
                    == mode_t(S_IFDIR),
                status.st_uid == geteuid(),
                status.st_gid == getegid(),
                status.st_mode
                    & mode_t(0o7777)
                    == mode_t(0o700),
                status.st_nlink >= 2,
                status.st_ino > 0,
                fcntl(
                    descriptor,
                    F_GETFD
                ) & FD_CLOEXEC != 0,
                try Self.requireLocalAPFS(
                    descriptor:
                        descriptor,
                    context:
                        "scratch_directory_filesystem_\(name)"
                ) == sourceFilesystemIdentity,
                try Self.directoryEntries(
                    descriptor:
                        descriptor,
                    context:
                        "scratch_directory_initial_\(name)"
                ).isEmpty
                else {
                    throw Self.rejected(
                        "scratch_directory_descriptor_\(name)"
                    )
                }
                _ = try Self.requireSafeExtendedMetadata(
                    descriptor:
                        descriptor,
                    relativePath: name,
                    status: status,
                    context:
                        "scratch_directory_metadata_\(name)"
                )
                heldDirectories[name] =
                    HeldDirectory(
                        name: name,
                        absolutePath:
                            runRootAbsolutePath
                            + "/"
                            + name,
                        descriptor:
                            descriptor,
                        initialStatus:
                            status
                    )
                descriptorTransferred = true
            }
            let rootEntries =
                try Self.directoryEntries(
                    descriptor:
                        runRootDescriptor,
                    context:
                        "scratch_run_root_pre_watch"
                )
            guard rootEntries
                    == Self.exactDirectoryNames
                    .sorted()
            else {
                throw Self.rejected(
                    "scratch_run_root_inventory"
                )
            }
            queueDescriptor =
                try Self.normalizedDescriptor(
                    Darwin.kqueue(),
                    context:
                        "scratch_kqueue"
                )
            for name in
                heldDirectories.keys.sorted()
            {
                guard let held =
                        heldDirectories[name]
                else {
                    throw Self.rejected(
                        "scratch_watcher_state"
                    )
                }
                try registerWatcher(
                    descriptor:
                        held.descriptor
                )
            }
            watchersArmedMonotonicNanoseconds =
                Self.monotonicNanoseconds()
            guard try firstPendingDestructiveEvent()
                    == nil
            else {
                poisoned = true
                throw Self.rejected(
                    "scratch_initial_event"
                )
            }
            try requirePathsRejoin(
                context: "initial"
            )
        } catch {
            close()
            throw error
        }
    }

    deinit {
        close()
    }

    var launchConfiguration:
        LaunchConfiguration
    {
        get throws {
            guard !poisoned,
                  !closed,
                  watchersArmedMonotonicNanoseconds
                    > 0,
                  preResumeValidationMonotonicNanoseconds
                    == nil,
                  postReapValidationMonotonicNanoseconds
                    == nil
            else {
                throw Self.rejected(
                    "scratch_launch_state"
                )
            }
            let contract =
                PrimeNativeNeuralGateSourceExecutionBindingContract
                .frozenV6
            let arguments =
                try contract
                .expandedSwiftPackageDescribeArguments(
                    scratchRootAbsolutePath:
                        runRootAbsolutePath
                )
            let environment =
                try contract
                .expandedSwiftPackageDescribeEnvironment(
                    scratchRootAbsolutePath:
                        runRootAbsolutePath
                )
            return LaunchConfiguration(
                arguments: arguments,
                orderedEnvironment:
                    contract
                    .swiftPackageDescribeExactEnvironmentKeys
                    .map {
                        (
                            $0,
                            environment[$0]!
                        )
                    }
            )
        }
    }

    func directoryAbsolutePath(
        named name: String
    ) throws -> String {
        guard !poisoned,
              !closed,
              watchersArmedMonotonicNanoseconds
                > 0,
              preResumeValidationMonotonicNanoseconds
                == nil,
              postReapValidationMonotonicNanoseconds
                == nil,
              let directory =
                heldDirectories[name],
              !name.isEmpty
        else {
            throw Self.rejected(
                "scratch_directory_name"
            )
        }
        return directory.absolutePath
    }

    func validateBeforeResume() throws
        -> UInt64
    {
        guard !poisoned,
              !closed,
              preResumeValidationMonotonicNanoseconds
                == nil,
              postReapValidationMonotonicNanoseconds
                == nil
        else {
            throw Self.rejected(
                "scratch_pre_resume_state"
            )
        }
        // Every admitted validation attempt is fail-closed. Success is the
        // only path that clears this provisional poison.
        poisoned = true
        let first =
            try firstPendingDestructiveEvent()
        preResumeDestructiveEventCount =
            first == nil ? 0 : 1
        guard first == nil else {
            poisoned = true
            throw Self.rejected(
                "scratch_pre_resume_event"
            )
        }
        try requirePathsRejoin(
            context: "pre_resume"
        )
        let rootEntries =
            try Self.directoryEntries(
                descriptor:
                    runRootDescriptor,
                context:
                    "scratch_pre_resume_root"
            )
        guard rootEntries
                == Self.exactDirectoryNames
                .sorted(),
              try Self.exactDirectoryNames
                .allSatisfy({
                    guard let held =
                            heldDirectories[$0]
                    else {
                        return false
                    }
                    return try Self
                        .directoryEntries(
                            descriptor:
                                held.descriptor,
                            context:
                                "scratch_pre_resume_\($0)"
                        )
                        .isEmpty
                })
        else {
            poisoned = true
            throw Self.rejected(
                "scratch_pre_resume_inventory"
            )
        }
        let second =
            try firstPendingDestructiveEvent()
        preResumeDestructiveEventCount! +=
            second == nil ? 0 : 1
        guard second == nil else {
            poisoned = true
            throw Self.rejected(
                "scratch_pre_resume_event"
            )
        }
        let now =
            Self.monotonicNanoseconds(
                strictlyAfter:
                    watchersArmedMonotonicNanoseconds
            )
        preResumeValidationMonotonicNanoseconds =
            now
        poisoned = false
        return now
    }

    func validateAfterReap(
        outerDeadlineMonotonicNanoseconds:
            UInt64
    ) throws
        -> UInt64
    {
        guard !poisoned,
              !closed,
              preResumeValidationMonotonicNanoseconds
                != nil,
              postReapValidationMonotonicNanoseconds
                == nil
        else {
            throw Self.rejected(
                "scratch_post_reap_state"
            )
        }
        // The namespace cannot be repaired and retried after a failed
        // post-reap audit. Success is the only path that clears this
        // provisional poison.
        poisoned = true
        let first =
            try firstPendingDestructiveEvent()
        postReapDestructiveEventCount =
            first == nil ? 0 : 1
        guard first == nil else {
            poisoned = true
            throw Self.rejected(
                "scratch_post_reap_event"
            )
        }
        try requirePathsRejoin(
            context: "post_reap"
        )
        let auditStarted =
            Self.monotonicNanoseconds()
        let auditDuration =
            Self.maximumPostAuditSeconds
            .multipliedReportingOverflow(
                by: 1_000_000_000
            )
        let localAuditDeadline =
            auditStarted
            .addingReportingOverflow(
                auditDuration.partialValue
            )
        guard !auditDuration.overflow,
              !localAuditDeadline.overflow
        else {
            throw Self.rejected(
                "scratch_post_audit_deadline_overflow"
            )
        }
        let auditDeadline =
            min(
                outerDeadlineMonotonicNanoseconds,
                localAuditDeadline.partialValue
            )
        guard auditStarted < auditDeadline
        else {
            poisoned = true
            throw Self.rejected(
                "scratch_post_audit_deadline"
            )
        }
        postAuditStartedMonotonicNanoseconds =
            auditStarted
        let audit =
            try auditNamespace(
                deadlineMonotonicNanoseconds:
                    auditDeadline
            )
        let second =
            try firstPendingDestructiveEvent()
        postReapDestructiveEventCount! +=
            second == nil ? 0 : 1
        guard second == nil else {
            poisoned = true
            throw Self.rejected(
                "scratch_post_reap_event"
            )
        }
        let auditCompleted =
            Self.monotonicNanoseconds()
        guard auditCompleted
                <= auditDeadline
        else {
            poisoned = true
            throw Self.rejected(
                "scratch_post_audit_deadline"
            )
        }
        postAudit = audit
        postAuditCompletedMonotonicNanoseconds =
            auditCompleted
        let now =
            Self.monotonicNanoseconds(
                strictlyAfter:
                    auditCompleted
            )
        postReapValidationMonotonicNanoseconds =
            now
        poisoned = false
        return now
    }

    func observation()
        throws
        -> PrimeNativeNeuralGateScratchNamespaceObservation
    {
        guard !poisoned,
              !closed,
              let preResume =
                preResumeValidationMonotonicNanoseconds,
              let postReap =
                postReapValidationMonotonicNanoseconds,
              let preResumeEvents =
                preResumeDestructiveEventCount,
              let postReapEvents =
                postReapDestructiveEventCount,
              let postAudit,
              let postAuditStarted =
                postAuditStartedMonotonicNanoseconds,
              let postAuditCompleted =
                postAuditCompletedMonotonicNanoseconds
        else {
            throw Self.rejected(
                "scratch_observation_state"
            )
        }
        return
            PrimeNativeNeuralGateScratchNamespaceObservation(
                role: role,
                runRootAbsolutePath:
                    runRootAbsolutePath,
                sourceFilesystemType:
                    sourceFilesystemIdentity
                    .typeName,
                sourceFilesystemIDWord0:
                    sourceFilesystemIdentity
                    .fsidWord0,
                sourceFilesystemIDWord1:
                    sourceFilesystemIdentity
                    .fsidWord1,
                scratchFilesystemType:
                    scratchFilesystemIdentity
                    .typeName,
                scratchFilesystemIDWord0:
                    scratchFilesystemIdentity
                    .fsidWord0,
                scratchFilesystemIDWord1:
                    scratchFilesystemIdentity
                    .fsidWord1,
                runRootDeviceID:
                    UInt64(
                        bitPattern:
                            Int64(
                                runRootInitialStatus
                                .st_dev
                            )
                    ),
                runRootInode:
                    UInt64(
                        runRootInitialStatus
                        .st_ino
                    ),
                runRootOwnerUserID:
                    runRootInitialStatus
                    .st_uid,
                runRootOwnerGroupID:
                    runRootInitialStatus
                    .st_gid,
                runRootPermissionMode:
                    UInt16(
                        runRootInitialStatus
                        .st_mode
                            & mode_t(0o7777)
                    ),
                exactDirectoryNames:
                    Self.exactDirectoryNames,
                heldDirectoryDescriptorCount:
                    heldDirectories.count,
                allDescriptorsOpenedWithNoSymbolicLinksInPath:
                    true,
                allDescriptorsCloseOnExec:
                    true,
                allDescriptorsOnExactSourceFilesystem:
                    true,
                allACLsAbsentAndExtendedAttributesAllowlisted:
                    true,
                permittedExtendedAttributeNames:
                    Self
                    .permittedSystemExtendedAttributes
                    .sorted(),
                extendedAttributePolicyID:
                    Self
                    .extendedAttributePolicyID,
                textEncodingRelativePath:
                    Self.textEncodingRelativePath,
                textEncodingAttributeName:
                    Self.textEncodingAttributeName,
                textEncodingRequiredNodeType:
                    Self.textEncodingNodeType,
                textEncodingExactValue:
                    Self.textEncodingValue,
                textEncodingExactByteCount:
                    Self.textEncodingValueBytes
                    .count,
                textEncodingAbsencePermitted:
                    true,
                textEncodingObservedCount:
                    postAudit
                    .textEncodingObservedCount,
                allObservedTextEncodingAttributesMatchedPolicy:
                    true,
                provenanceAttributeName:
                    Self.provenanceAttributeName,
                provenanceValueOpaqueAndNonAuthoritative:
                    true,
                maximumProvenanceValueByteCount:
                    Self
                    .maximumProvenanceValueByteCount,
                rootCreatedAtomicallyAndInitiallyEmpty:
                    true,
                kqueueVnodeFilter:
                    Int16(EVFILT_VNODE),
                destructiveVnodeNoteMask:
                    Self
                    .destructiveVnodeNoteMask,
                watcherCount:
                    heldDirectories.count,
                registrationReceiptCount:
                    registrationReceiptCount,
                registrationReceiptErrorCount:
                    registrationReceiptErrorCount,
                watchersArmedMonotonicNanoseconds:
                    watchersArmedMonotonicNanoseconds,
                preResumeValidationMonotonicNanoseconds:
                    preResume,
                postReapValidationMonotonicNanoseconds:
                    postReap,
                preResumeDestructiveEventCount:
                    preResumeEvents,
                postReapDestructiveEventCount:
                    postReapEvents,
                allPathsRejoinedHeldVnodes:
                    true,
                maximumPostAuditFileCount:
                    Self
                    .maximumPostAuditFileCount,
                maximumPostAuditDirectoryCount:
                    Self
                    .maximumPostAuditDirectoryCount,
                maximumPostAuditAggregateByteCount:
                    Self
                    .maximumPostAuditAggregateByteCount,
                maximumPostAuditRelativeDepth:
                    Self
                    .maximumPostAuditRelativeDepth,
                maximumPostAuditSeconds:
                    Self
                    .maximumPostAuditSeconds,
                postAuditStartedMonotonicNanoseconds:
                    postAuditStarted,
                postAuditCompletedMonotonicNanoseconds:
                    postAuditCompleted,
                postAuditFileCount:
                    postAudit.fileCount,
                postAuditDirectoryCount:
                    postAudit.directoryCount,
                postAuditAggregateByteCount:
                    postAudit
                    .aggregateByteCount,
                cacheDirectoryEmpty:
                    postAudit.cacheEmpty,
                configDirectoryEmpty:
                    postAudit.configEmpty,
                securityDirectoryEmpty:
                    postAudit.securityEmpty,
                networkDenialEstablished:
                    false,
                dependencyResolutionPermitted:
                    false,
                resolutionResiduePathCount:
                    postAudit
                    .resolutionResiduePathCount,
                resolutionResiduesAbsent:
                    postAudit
                    .resolutionResiduePathCount == 0,
                namespaceLeftForSystemTemporaryDirectoryCleanup:
                    true
            )
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
        for name in
            heldDirectories.keys
            .filter({ !$0.isEmpty })
        {
            if let descriptor =
                    heldDirectories[name]?
                    .descriptor,
               descriptor >= 0
            {
                _ = Darwin.close(
                    descriptor
                )
            }
        }
        heldDirectories.removeAll()
        if runRootDescriptor >= 0 {
            _ = Darwin.close(
                runRootDescriptor
            )
            runRootDescriptor = -1
        }
    }

    private func registerWatcher(
        descriptor: Int32
    ) throws {
        var change =
            DarwinKevent(
                ident: UInt(descriptor),
                filter: Int16(EVFILT_VNODE),
                flags:
                    UInt16(EV_ADD)
                    | UInt16(EV_ENABLE)
                    | UInt16(EV_CLEAR)
                    | UInt16(EV_RECEIPT),
                fflags:
                    Self
                    .destructiveVnodeNoteMask,
                data: 0,
                udata: nil
            )
        var receipt = DarwinKevent()
        let returned =
            withUnsafePointer(
                to: &change
            ) {
                changes in
                withUnsafeMutablePointer(
                    to: &receipt
                ) {
                    events in
                    kevent(
                        queueDescriptor,
                        changes,
                        1,
                        events,
                        1,
                        nil
                    )
                }
            }
        registrationReceiptCount +=
            returned == 1 ? 1 : 0
        let receiptError =
            returned != 1
            || receipt.filter
                != Int16(EVFILT_VNODE)
            || receipt.flags
                & UInt16(EV_ERROR)
                == 0
            || receipt.data != 0
        if receiptError {
            registrationReceiptErrorCount += 1
            throw Self.rejected(
                "scratch_watcher_registration"
            )
        }
    }

    private func firstPendingDestructiveEvent()
        throws -> DarwinKevent?
    {
        var event = DarwinKevent()
        var timeout =
            timespec(
                tv_sec: 0,
                tv_nsec: 0
            )
        errno = 0
        let returned =
            withUnsafeMutablePointer(
                to: &event
            ) {
                kevent(
                    queueDescriptor,
                    nil,
                    0,
                    $0,
                    1,
                    &timeout
                )
            }
        guard returned >= 0 else {
            throw Self.rejected(
                "scratch_kqueue_poll_\(errno)"
            )
        }
        guard returned == 1 else {
            return nil
        }
        guard event.filter
                == Int16(EVFILT_VNODE),
              event.flags
                & UInt16(EV_ERROR)
                == 0,
              event.fflags != 0,
              event.fflags
                & ~Self
                .destructiveVnodeNoteMask
                == 0
        else {
            throw Self.rejected(
                "scratch_kqueue_event"
            )
        }
        return event
    }

    private func requirePathsRejoin(
        context: String
    ) throws {
        var pathStatus = stat()
        var descriptorStatus = stat()
        guard lstat(
            runRootAbsolutePath,
            &pathStatus
        ) == 0,
        fstat(
            runRootDescriptor,
            &descriptorStatus
        ) == 0,
        Self.sameDirectoryIdentity(
            runRootInitialStatus,
            pathStatus
        ),
        Self.sameDirectoryIdentity(
            runRootInitialStatus,
            descriptorStatus
        )
        else {
            throw Self.rejected(
                "scratch_\(context)_run_root_rejoin"
            )
        }
        for name in
            Self.exactDirectoryNames
        {
            guard let held =
                    heldDirectories[name]
            else {
                throw Self.rejected(
                    "scratch_\(context)_directory_state"
                )
            }
            var heldStatus = stat()
            guard fstat(
                held.descriptor,
                &heldStatus
            ) == 0,
            Self.sameDirectoryIdentity(
                held.initialStatus,
                heldStatus
            )
            else {
                throw Self.rejected(
                    "scratch_\(context)_directory_held_\(name)"
                )
            }
            _ = try Self.requireSafeExtendedMetadata(
                descriptor:
                    held.descriptor,
                relativePath: name,
                status: heldStatus,
                context:
                    "scratch_\(context)_directory_metadata_\(name)"
            )
            let rejoined =
                try Self.openRelativeDirectory(
                    parentDescriptor:
                        runRootDescriptor,
                    name: name,
                    context:
                        "scratch_\(context)_directory_rejoin_\(name)"
                )
            defer {
                _ = Darwin.close(
                    rejoined
                )
            }
            var rejoinedStatus = stat()
            guard fstat(
                rejoined,
                &rejoinedStatus
            ) == 0,
            Self.sameDirectoryIdentity(
                held.initialStatus,
                rejoinedStatus
            )
            else {
                throw Self.rejected(
                    "scratch_\(context)_directory_rejoin_\(name)"
                )
            }
            _ = try Self.requireSafeExtendedMetadata(
                descriptor:
                    rejoined,
                relativePath: name,
                status: rejoinedStatus,
                context:
                    "scratch_\(context)_directory_rejoin_metadata_\(name)"
            )
        }
    }

    private func auditNamespace(
        deadlineMonotonicNanoseconds:
            UInt64
    )
        throws -> AuditResult
    {
        try requireAuditBeforeDeadline(
            deadlineMonotonicNanoseconds
        )
        let rootEntries =
            try Self.directoryEntries(
                descriptor:
                    runRootDescriptor,
                context:
                    "scratch_post_audit_root",
                deadlineMonotonicNanoseconds:
                    deadlineMonotonicNanoseconds
            )
        guard rootEntries
                == Self.exactDirectoryNames
                .sorted()
        else {
            throw Self.rejected(
                "scratch_post_audit_root_inventory"
            )
        }
        var fileCount = 0
        var directoryCount =
            1
            + Self.exactDirectoryNames.count
        var aggregateByteCount: UInt64 = 0
        var resolutionResiduePathCount = 0
        var textEncodingObservedCount = 0
        var emptiness:
            [String: Bool] = [
                "cache": true,
                "config": true,
                "security": true,
            ]
        for name in
            Self.exactDirectoryNames
        {
            guard let held =
                    heldDirectories[name]
            else {
                throw Self.rejected(
                    "scratch_post_audit_state"
                )
            }
            let entries =
                try auditDirectory(
                    descriptor:
                        held.descriptor,
                    relativePath: name,
                    depth: 1,
                    fileCount: &fileCount,
                    directoryCount:
                        &directoryCount,
                    aggregateByteCount:
                        &aggregateByteCount,
                    resolutionResiduePathCount:
                        &resolutionResiduePathCount,
                    textEncodingObservedCount:
                        &textEncodingObservedCount,
                    deadlineMonotonicNanoseconds:
                        deadlineMonotonicNanoseconds
                )
            if emptiness[name] != nil {
                emptiness[name] =
                    entries == 0
            }
        }
        guard fileCount
                <= Self
                .maximumPostAuditFileCount,
              directoryCount
                <= Self
                .maximumPostAuditDirectoryCount,
              aggregateByteCount
                <= Self
                .maximumPostAuditAggregateByteCount,
              emptiness["cache"] == true,
              emptiness["config"] == true,
              emptiness["security"] == true,
              resolutionResiduePathCount == 0,
              textEncodingObservedCount <= 1
        else {
            throw Self.rejected(
                "scratch_post_audit_bounds_or_authority_directory"
            )
        }
        return AuditResult(
            fileCount: fileCount,
            directoryCount:
                directoryCount,
            aggregateByteCount:
                aggregateByteCount,
            textEncodingObservedCount:
                textEncodingObservedCount,
            cacheEmpty:
                emptiness["cache"]!,
            configEmpty:
                emptiness["config"]!,
            securityEmpty:
                emptiness["security"]!,
            resolutionResiduePathCount:
                resolutionResiduePathCount
        )
    }

    @discardableResult
    private func auditDirectory(
        descriptor: Int32,
        relativePath: String,
        depth: Int,
        fileCount: inout Int,
        directoryCount: inout Int,
        aggregateByteCount: inout UInt64,
        resolutionResiduePathCount:
            inout Int,
        textEncodingObservedCount:
            inout Int,
        deadlineMonotonicNanoseconds:
            UInt64
    ) throws -> Int {
        try requireAuditBeforeDeadline(
            deadlineMonotonicNanoseconds
        )
        guard depth
                <= Self
                .maximumPostAuditRelativeDepth
        else {
            throw Self.rejected(
                "scratch_post_audit_depth"
            )
        }
        let entries =
            try Self.directoryEntries(
                descriptor: descriptor,
                context:
                    "scratch_post_audit_\(relativePath)",
                deadlineMonotonicNanoseconds:
                    deadlineMonotonicNanoseconds
            )
        for name in entries {
            try requireAuditBeforeDeadline(
                deadlineMonotonicNanoseconds
            )
            if Self.resolutionResidueNames
                .contains(name)
            {
                resolutionResiduePathCount += 1
                throw Self.rejected(
                    "scratch_post_audit_resolution_residue"
                )
            }
            let opened =
                try Self.normalizedDescriptor(
                    openat(
                        descriptor,
                        name,
                        O_EVTONLY
                            | O_NONBLOCK
                            | O_NOFOLLOW_ANY
                            | O_CLOEXEC
                    ),
                    context:
                        "scratch_post_audit_open"
                )
            defer {
                _ = Darwin.close(
                    opened
                )
            }
            let filesystem =
                try Self.requireLocalAPFS(
                    descriptor:
                        opened,
                    context:
                        "scratch_post_audit_filesystem"
                )
            guard filesystem
                    == sourceFilesystemIdentity
            else {
                throw Self.rejected(
                    "scratch_post_audit_fsid"
                )
            }
            var status = stat()
            guard fstat(
                opened,
                &status
            ) == 0,
            status.st_uid == geteuid(),
            status.st_mode
                & mode_t(0o022)
                == 0,
            status.st_nlink > 0,
            fcntl(
                opened,
                F_GETFL
            ) & O_NONBLOCK != 0,
            fcntl(
                opened,
                F_GETFD
            ) & FD_CLOEXEC != 0
            else {
                throw Self.rejected(
                    "scratch_post_audit_descriptor"
                )
            }
            let kind =
                status.st_mode
                & mode_t(S_IFMT)
            guard kind == mode_t(S_IFDIR)
                    || (
                        kind == mode_t(S_IFREG)
                            && status.st_size >= 0
                            && status.st_nlink == 1
                    )
            else {
                throw Self.rejected(
                    "scratch_post_audit_file_metadata"
                )
            }
            let childRelativePath =
                relativePath
                + "/"
                + name
            textEncodingObservedCount +=
                try Self.requireSafeExtendedMetadata(
                    descriptor:
                        opened,
                    relativePath:
                        childRelativePath,
                    status: status,
                    context:
                        "scratch_post_audit_metadata"
                )
            if kind == mode_t(S_IFDIR) {
                let traversalDescriptor =
                    try Self.openRelativeDirectory(
                        parentDescriptor:
                            descriptor,
                        name: name,
                        context:
                            "scratch_post_audit_directory_open"
                    )
                defer {
                    _ = Darwin.close(
                        traversalDescriptor
                    )
                }
                var traversalStatus = stat()
                guard fstat(
                    traversalDescriptor,
                    &traversalStatus
                ) == 0,
                Self.sameDirectoryIdentity(
                    status,
                    traversalStatus
                )
                else {
                    throw Self.rejected(
                        "scratch_post_audit_directory_rejoin"
                    )
                }
                directoryCount += 1
                guard directoryCount
                        <= Self
                        .maximumPostAuditDirectoryCount
                else {
                    throw Self.rejected(
                        "scratch_post_audit_directory_count"
                    )
                }
                _ = try auditDirectory(
                    descriptor:
                        traversalDescriptor,
                    relativePath:
                        childRelativePath,
                    depth: depth + 1,
                    fileCount: &fileCount,
                    directoryCount:
                        &directoryCount,
                    aggregateByteCount:
                        &aggregateByteCount,
                    resolutionResiduePathCount:
                        &resolutionResiduePathCount,
                    textEncodingObservedCount:
                        &textEncodingObservedCount,
                    deadlineMonotonicNanoseconds:
                        deadlineMonotonicNanoseconds
                )
            } else if kind
                        == mode_t(S_IFREG)
            {
                fileCount += 1
                let next =
                    aggregateByteCount
                    .addingReportingOverflow(
                        UInt64(status.st_size)
                    )
                guard fileCount
                        <= Self
                        .maximumPostAuditFileCount,
                      !next.overflow,
                      next.partialValue
                        <= Self
                        .maximumPostAuditAggregateByteCount
                else {
                    throw Self.rejected(
                        "scratch_post_audit_file_bounds"
                    )
                }
                aggregateByteCount =
                    next.partialValue
            } else {
                throw Self.rejected(
                    "scratch_post_audit_file_type"
                )
            }
        }
        return entries.count
    }

    private func requireAuditBeforeDeadline(
        _ deadline: UInt64
    ) throws {
        guard Self.monotonicNanoseconds()
                <= deadline
        else {
            throw Self.rejected(
                "scratch_post_audit_deadline"
            )
        }
    }

    private static let resolutionResidueNames:
        Set<String> = [
            "Package.resolved",
            "checkouts",
            "repositories",
            "workspace-state.json",
            "artifacts",
            "artifacts.json",
            "registries.json",
        ]

    private static let permittedSystemExtendedAttributes:
        Set<String> = [
            "com.apple.TextEncoding",
            // APFS/macOS can attach this opaque provenance marker to
            // directories and files created by a signed process. It grants
            // no filesystem authority; ACLs and mode bits are independently
            // checked fail-closed.
            "com.apple.provenance",
        ]

    private static let textEncodingAttributeName =
        "com.apple.TextEncoding"
    private static let extendedAttributePolicyID =
        "optional_exact_text_encoding_work_lock_bounded_opaque_provenance_v1"
    private static let textEncodingRelativePath =
        "work/.lock"
    private static let textEncodingNodeType =
        "regular_file"
    private static let textEncodingValue =
        "utf-8;134217984"
    private static let textEncodingValueBytes =
        Array(textEncodingValue.utf8)
    private static let textEncodingReadCapacity =
        16
    private static let provenanceAttributeName =
        "com.apple.provenance"
    private static let maximumProvenanceValueByteCount =
        4_096

    private static func requireSafeExtendedMetadata(
        descriptor: Int32,
        relativePath: String,
        status: stat,
        context: String
    ) throws -> Int {
        errno = 0
        if let accessControlList =
                acl_get_fd_np(
                    descriptor,
                    ACL_TYPE_EXTENDED
                )
        {
            _ = acl_free(
                UnsafeMutableRawPointer(
                    accessControlList
                )
            )
            throw rejected(
                "\(context)_acl"
            )
        }
        guard errno == ENOENT else {
            throw rejected(
                "\(context)_acl_\(errno)"
            )
        }
        errno = 0
        let extendedAttributeByteCount =
            flistxattr(
                descriptor,
                nil,
                0,
                0
            )
        guard extendedAttributeByteCount >= 0,
              extendedAttributeByteCount <= 65_536
        else {
            throw rejected(
                "\(context)_xattr_\(errno)"
            )
        }
        guard extendedAttributeByteCount > 0
        else {
            return 0
        }

        var names = [CChar](
            repeating: 0,
            count: extendedAttributeByteCount
        )
        errno = 0
        let actualByteCount =
            names.withUnsafeMutableBufferPointer {
                flistxattr(
                    descriptor,
                    $0.baseAddress,
                    $0.count,
                    0
                )
            }
        guard actualByteCount
                == extendedAttributeByteCount
        else {
            throw rejected(
                "\(context)_xattr_\(errno)"
            )
        }

        let bytes =
            names.prefix(
                actualByteCount
            ).map {
                UInt8(bitPattern: $0)
            }
        var start = bytes.startIndex
        var observedNames =
            Set<String>()
        for index in bytes.indices
        where bytes[index] == 0
        {
            guard start < index,
                  let name =
                    String(
                        bytes:
                            bytes[
                                start ..< index
                            ],
                        encoding: .utf8
                    )
            else {
                throw rejected(
                    "\(context)_xattr_name"
                )
            }
            observedNames.insert(name)
            start =
                bytes.index(
                    after: index
                )
        }
        guard start == bytes.endIndex,
              observedNames.isSubset(
                  of:
                    permittedSystemExtendedAttributes
              )
        else {
            throw rejected(
                "\(context)_xattr_policy"
            )
        }
        var textEncodingObservedCount = 0
        for name in observedNames {
            if name
                == provenanceAttributeName
            {
                errno = 0
                let declaredValueByteCount =
                    name.withCString {
                        attributeName in
                        fgetxattr(
                            descriptor,
                            attributeName,
                            nil,
                            0,
                            0,
                            0
                        )
                    }
                guard isPermittedOpaqueProvenanceValueByteCount(
                    declaredValueByteCount
                )
                else {
                    throw rejected(
                        "\(context)_provenance_value_size_\(errno)"
                    )
                }
                var value = [UInt8](
                    repeating: 0,
                    count:
                        maximumProvenanceValueByteCount
                )
                errno = 0
                let valueByteCount =
                    name.withCString {
                        attributeName in
                        value
                            .withUnsafeMutableBytes {
                                storage in
                                fgetxattr(
                                    descriptor,
                                    attributeName,
                                    storage.baseAddress,
                                    storage.count,
                                    0,
                                    0
                                )
                            }
                    }
                guard valueByteCount >= 0,
                      valueByteCount
                        == declaredValueByteCount
                else {
                    throw rejected(
                        "\(context)_provenance_value_\(errno)"
                    )
                }
                errno = 0
                let postReadValueByteCount =
                    name.withCString {
                        attributeName in
                        fgetxattr(
                            descriptor,
                            attributeName,
                            nil,
                            0,
                            0,
                            0
                        )
                    }
                guard postReadValueByteCount
                        == valueByteCount
                else {
                    throw rejected(
                        "\(context)_provenance_value_stability_\(errno)"
                    )
                }
                continue
            }
            guard name
                    == textEncodingAttributeName,
                  relativePath
                    == textEncodingRelativePath,
                  status.st_mode
                    & mode_t(S_IFMT)
                    == mode_t(S_IFREG),
                  status.st_nlink == 1
            else {
                throw rejected(
                    "\(context)_text_encoding_location"
                )
            }
            var value = [UInt8](
                repeating: 0,
                count:
                    textEncodingReadCapacity
            )
            errno = 0
            let valueByteCount =
                name.withCString {
                    attributeName in
                    value
                        .withUnsafeMutableBytes {
                            storage in
                            fgetxattr(
                                descriptor,
                                attributeName,
                                storage.baseAddress,
                                storage.count,
                                0,
                                0
                            )
                        }
                }
            guard valueByteCount
                    == textEncodingValueBytes
                    .count,
                  Array(
                      value.prefix(
                          valueByteCount
                      )
                  ) == textEncodingValueBytes
            else {
                throw rejected(
                    "\(context)_text_encoding_value_\(errno)"
                )
            }
            textEncodingObservedCount += 1
        }
        return textEncodingObservedCount
    }

    static func isPermittedOpaqueProvenanceValueByteCount(
        _ byteCount: Int
    ) -> Bool {
        byteCount >= 0
            && byteCount
                <= maximumProvenanceValueByteCount
    }

    private static func darwinUserTemporaryDirectory()
        throws -> String
    {
        let required =
            Darwin.confstr(
                _CS_DARWIN_USER_TEMP_DIR,
                nil,
                0
            )
        guard required > 1,
              required
                <= Int(PATH_MAX)
        else {
            throw rejected(
                "scratch_temp_confstr_size"
            )
        }
        var raw =
            [CChar](
                repeating: 0,
                count: required
            )
        let written =
            raw.withUnsafeMutableBufferPointer {
                Darwin.confstr(
                    _CS_DARWIN_USER_TEMP_DIR,
                    $0.baseAddress,
                    $0.count
                )
            }
        guard written == required
        else {
            throw rejected(
                "scratch_temp_confstr"
            )
        }
        let reported =
            raw.withUnsafeBufferPointer {
                String(
                    cString:
                        $0.baseAddress!
                )
            }
        guard reported.hasPrefix("/"),
              reported != "/",
              !reported.contains("\0")
        else {
            throw rejected(
                "scratch_temp_path"
            )
        }
        var resolved =
            [CChar](
                repeating: 0,
                count: Int(PATH_MAX)
            )
        let resolvedOK =
            reported.withCString {
                input in
                resolved
                .withUnsafeMutableBufferPointer {
                    realpath(
                        input,
                        $0.baseAddress
                    ) != nil
                }
            }
        guard resolvedOK
        else {
            throw rejected(
                "scratch_temp_realpath_\(errno)"
            )
        }
        let canonical =
            resolved.withUnsafeBufferPointer {
                String(
                    cString:
                        $0.baseAddress!
                )
            }
        guard canonical.hasPrefix("/"),
              canonical != "/",
              !canonical.contains("\0"),
              !canonical.hasSuffix("/"),
              canonical.split(
                  separator: "/",
                  omittingEmptySubsequences:
                    true
              ).allSatisfy({
                  $0 != "."
                      && $0 != ".."
              })
        else {
            throw rejected(
                "scratch_temp_canonical"
            )
        }
        return canonical
    }

    private static func openDirectory(
        absolutePath: String,
        context: String
    ) throws -> Int32 {
        try normalizedDescriptor(
            Darwin.open(
                absolutePath,
                O_RDONLY
                    | O_DIRECTORY
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC
            ),
            context: context
        )
    }

    private static func openRelativeDirectory(
        parentDescriptor: Int32,
        name: String,
        context: String
    ) throws -> Int32 {
        guard !name.isEmpty,
              name != ".",
              name != "..",
              !name.contains("/"),
              !name.contains("\0")
        else {
            throw rejected(
                "\(context)_name"
            )
        }
        return try normalizedDescriptor(
            openat(
                parentDescriptor,
                name,
                O_RDONLY
                    | O_DIRECTORY
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC
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
                "\(context)_open_\(errno)"
            )
        }
        if descriptor >= 3 {
            guard fcntl(
                descriptor,
                F_SETFD,
                FD_CLOEXEC
            ) == 0
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
        _ = Darwin.close(descriptor)
        guard normalized >= 3 else {
            throw rejected(
                "\(context)_normalize_\(failure)"
            )
        }
        return normalized
    }

    private static func requireLocalAPFS(
        descriptor: Int32,
        context: String
    ) throws -> FilesystemIdentity {
        var filesystem = statfs()
        errno = 0
        guard descriptor >= 3,
              fcntl(
                  descriptor,
                  F_GETFD
              ) & FD_CLOEXEC != 0,
              fstatfs(
                  descriptor,
                  &filesystem
              ) == 0,
              filesystem.f_flags
                & UInt32(MNT_LOCAL)
                != 0
        else {
            throw rejected(
                "\(context)_local_\(errno)"
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
        return FilesystemIdentity(
            typeName: type,
            fsidWord0:
                filesystem.f_fsid.val.0,
            fsidWord1:
                filesystem.f_fsid.val.1
        )
    }

    private static func directoryEntries(
        descriptor: Int32,
        context: String,
        deadlineMonotonicNanoseconds:
            UInt64? = nil
    ) throws -> [String] {
        if let deadlineMonotonicNanoseconds {
            guard monotonicNanoseconds()
                    <= deadlineMonotonicNanoseconds
            else {
                throw rejected(
                    "\(context)_deadline"
                )
            }
        }
        let duplicate =
            try normalizedDescriptor(
                openat(
                    descriptor,
                    ".",
                    O_RDONLY
                        | O_DIRECTORY
                        | O_NOFOLLOW_ANY
                        | O_CLOEXEC
                ),
                context:
                    "\(context)_enumeration"
            )
        guard let directory =
                fdopendir(duplicate)
        else {
            let failure = errno
            _ = Darwin.close(
                duplicate
            )
            throw rejected(
                "\(context)_fdopendir_\(failure)"
            )
        }
        defer {
            _ = closedir(directory)
        }
        var names: [String] = []
        while true {
            if let deadlineMonotonicNanoseconds {
                guard monotonicNanoseconds()
                        <= deadlineMonotonicNanoseconds
                else {
                    throw rejected(
                        "\(context)_deadline"
                    )
                }
            }
            errno = 0
            guard let pointer =
                    readdir(directory)
            else {
                guard errno == 0 else {
                    throw rejected(
                        "\(context)_readdir_\(errno)"
                    )
                }
                break
            }
            let entry = pointer.pointee
            let length =
                Int(entry.d_namlen)
            guard length > 0,
                  length
                    <= Int(MAXNAMLEN)
            else {
                throw rejected(
                    "\(context)_name_length"
                )
            }
            var field = entry.d_name
            let data =
                withUnsafeBytes(
                    of: &field
                ) {
                    Data(
                        $0.prefix(length)
                    )
                }
            guard let name =
                    String(
                        data: data,
                        encoding: .utf8
                    ),
                  !name.isEmpty,
                  !name.contains("/"),
                  !name.contains("\0")
            else {
                throw rejected(
                    "\(context)_name"
                )
            }
            if name == "."
                || name == ".."
            {
                continue
            }
            names.append(name)
            guard names.count
                    <= maximumPostAuditFileCount
                        + maximumPostAuditDirectoryCount
            else {
                throw rejected(
                    "\(context)_entry_count"
                )
            }
        }
        names.sort()
        guard Set(names).count
                == names.count
        else {
            throw rejected(
                "\(context)_duplicate_name"
            )
        }
        return names
    }

    private static func sameDirectoryIdentity(
        _ expected: stat,
        _ observed: stat
    ) -> Bool {
        expected.st_dev == observed.st_dev
            && expected.st_ino == observed.st_ino
            && expected.st_uid == observed.st_uid
            && expected.st_gid == observed.st_gid
            && expected.st_mode == observed.st_mode
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
