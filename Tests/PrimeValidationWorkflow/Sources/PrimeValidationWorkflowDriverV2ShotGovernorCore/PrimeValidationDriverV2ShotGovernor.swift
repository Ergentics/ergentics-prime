// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
@_spi(PrimeValidationDriverV2OuterContinuity) import PrimeCore
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowDriverCore

@_silgen_name("_NSGetArgc")
private func primeDriverV2GovernorNSGetArgc() -> UnsafeMutablePointer<Int32>

@_silgen_name("_NSGetArgv")
private func primeDriverV2GovernorNSGetArgv()
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
    package static let buildArtifactKind =
        "prime_driver_v2_gate_f_shot_capsule_v1"
    package static let inventoryArtifactKind =
        "prime_driver_v2_gate_g_shot_capsule_v1"
    package static let executionArtifactKind =
        "prime_driver_v2_gate_h_shot_capsule_v1"

    package let schemaVersion: Int
    package let artifactKind: String
    package let attempt: Int
    package let rerunAuthorized: Bool
    package let localOnly: Bool
    package let networkOperationCount: Int?
    package let dependencyFetchCount: Int?
    package let githubOperationCount: Int?
    package var dependencyResolutionPolicy: String? = nil
    package let fixtureExecutionCount: Int
    package let swiftPMBuildExecutionCount: Int
    package let artifactStagingExecutionCount: Int
    package let inventoryExecutionCount: Int
    package let gateFAuthorized: Bool
    package let gateGAuthorized: Bool
    package var gateHAuthorized: Bool? = nil
    package var executionGoScopeData: Data? = nil
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

    package var terminalGate: PrimeValidationDriverV2TerminalGate {
        if artifactKind == Self.executionArtifactKind { return .gateH }
        if artifactKind == Self.inventoryArtifactKind { return .gateG }
        return artifactKind == Self.buildArtifactKind ? .gateF : .gateE
    }

    fileprivate var outerJournalLeaf: String {
        if terminalGate == .gateH { return "gate-h-shot-governor-journal" }
        if terminalGate == .gateG { return "gate-g-shot-governor-journal" }
        return terminalGate == .gateF ? "gate-f-shot-governor-journal"
            : PrimeValidationDriverV2GovernorJournal.rootLeaf
    }

    fileprivate var runsBuildAndStaging: Bool {
        terminalGate == .gateF || terminalGate == .gateG || terminalGate == .gateH
    }

    fileprivate var outerDurationNanoseconds: UInt64 {
        get throws {
            if terminalGate == .gateH {
                return try PrimeValidationDriverV2TerminalGate.gateHOuterDurationNanoseconds(intent: intent)
            }
            if terminalGate == .gateG { return 1_260_000_000_000 }
            return terminalGate == .gateF ? 960_000_000_000
                : PrimeValidationDriverV2GovernorDeadline.durationNanoseconds
        }
    }

    fileprivate var outerStartSchema: String {
        if terminalGate == .gateH { return "prime_driver_v2_gate_h_outer_start_v1" }
        if terminalGate == .gateG { return "prime_driver_v2_gate_g_outer_start_v1" }
        return terminalGate == .gateF ? "prime_driver_v2_gate_f_outer_start_v1"
            : "prime_driver_v2_gate_e_outer_start_v1"
    }

    fileprivate var outerTerminalSchema: String {
        if terminalGate == .gateH { return "prime_driver_v2_gate_h_outer_terminal_v1" }
        if terminalGate == .gateG { return "prime_driver_v2_gate_g_outer_terminal_v1" }
        return terminalGate == .gateF ? "prime_driver_v2_gate_f_outer_terminal_v1"
            : "prime_driver_v2_gate_e_outer_terminal_v1"
    }

    package func validate(exactCanonicalBytes: Data) throws {
        let phaseFieldsMatch: Bool
        if artifactKind == Self.executionArtifactKind {
            phaseFieldsMatch = gateFAuthorized && gateGAuthorized && gateHAuthorized == true
                && executionGoScopeData != nil
                && swiftPMBuildExecutionCount == 1 && artifactStagingExecutionCount == 1
                && inventoryExecutionCount == 2 && networkOperationCount == nil
                && dependencyFetchCount == nil && githubOperationCount == nil
                && dependencyResolutionPolicy == "locked_package_resolved"
        } else if artifactKind == Self.inventoryArtifactKind {
            phaseFieldsMatch = gateFAuthorized && gateGAuthorized
                && swiftPMBuildExecutionCount == 1
                && artifactStagingExecutionCount == 1
                && inventoryExecutionCount == 2
                && networkOperationCount == nil
                && dependencyFetchCount == nil
                && githubOperationCount == nil
                && dependencyResolutionPolicy == "locked_package_resolved"
        } else if artifactKind == Self.buildArtifactKind {
            phaseFieldsMatch = gateFAuthorized
                && !gateGAuthorized
                && inventoryExecutionCount == 0
                && swiftPMBuildExecutionCount == 1
                && artifactStagingExecutionCount == 1
                && networkOperationCount == nil
                && dependencyFetchCount == nil
                && githubOperationCount == nil
                && dependencyResolutionPolicy == "locked_package_resolved"
        } else {
            phaseFieldsMatch = artifactKind == Self.artifactKind
                && !gateFAuthorized
                && !gateGAuthorized
                && inventoryExecutionCount == 0
                && swiftPMBuildExecutionCount == 0
                && artifactStagingExecutionCount == 0
                && networkOperationCount == 0
                && dependencyFetchCount == 0
                && githubOperationCount == 0
                && dependencyResolutionPolicy == nil
        }
        guard schemaVersion == Self.schemaVersion,
              phaseFieldsMatch,
              terminalGate == .gateH || (gateHAuthorized == nil && executionGoScopeData == nil),
              attempt == 1,
              !rerunAuthorized,
              localOnly,
              fixtureExecutionCount == 0,
              primeAdmittedFileCount == PrimeValidationDriverV2SealedSourceTopology.primeAdmittedFileCount,
              sourceIdentityRecordCount == PrimeValidationDriverV2SealedSourceTopology.sourceIdentityRecordCount,
              primeAuthorityDirectoryCount == PrimeValidationDriverV2SealedSourceTopology.primeAuthorityDirectoryCount,
              combinedWatcherDescriptorCount == PrimeValidationDriverV2SealedSourceTopology.combinedWatcherDescriptorCount,
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
        guard terminalGate == .gateH || intent.phaseBudgets
            != PrimeValidationExecutorAdmissionPolicyV2.currentSourceExecutionV1.phaseBudgets else {
            throw governorRejected(PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "non_H_execution_budget")
        }
        if terminalGate == .gateH {
            guard let executionGoScopeData else {
                throw governorRejected(PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport, "H_missing_scope")
            }
            let declaredScope = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2DeclaredExecutionScopeV1.self,
                from: executionGoScopeData)
            let expectedScope = try PrimeValidationDriverV2DeclaredExecutionScopeV1(
                intent: intent, sourceCommit: sourceCommit, sourceTree: sourceTree,
                sourceTreeReplaySHA256: declaredScope.sourceTreeReplaySHA256,
                sourceIdentitySHA256: sourceIdentitySHA256, governorExecutable: governorExecutable,
                supervisorExecutable: supervisorExecutable)
            guard executionGoScopeData == (try PrimeCanonicalJSON.encode(expectedScope)) else {
                throw governorRejected(PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                    "H_declared_go_scope")
            }
        }
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
            productionBase.absolutePath + "/" + outerJournalLeaf,
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
        case dependencyResolutionPolicy = "dependency_resolution_policy"
        case fixtureExecutionCount = "fixture_execution_count"
        case swiftPMBuildExecutionCount =
            "swiftpm_build_execution_count"
        case artifactStagingExecutionCount =
            "artifact_staging_execution_count"
        case inventoryExecutionCount = "inventory_execution_count"
        case gateFAuthorized = "gate_f_authorized"
        case gateGAuthorized = "gate_g_authorized"
        case gateHAuthorized = "gate_h_authorized"
        case executionGoScopeData = "execution_go_scope_data"
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

struct PrimeValidationDriverV2GovernorDeadline {
    static let durationNanoseconds: UInt64 = 60_000_000_000
    let startedAt: UInt64
    let expiresAt: UInt64

    init(
        durationNanoseconds: UInt64 = Self.durationNanoseconds,
        startedAt: UInt64 = DispatchTime.now().uptimeNanoseconds
    ) throws {
        self.startedAt = startedAt
        let value = startedAt.addingReportingOverflow(durationNanoseconds)
        guard !value.overflow else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "deadline_overflow"
            )
        }
        expiresAt = value.partialValue
    }

    func requireTime(
        _ coordinate: String,
        observedAt: UInt64 = DispatchTime.now().uptimeNanoseconds
    ) throws {
        guard observedAt >= startedAt, observedAt < expiresAt else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                coordinate
            )
        }
    }

    /// The checkpoint can consume the last phase time. No spawn is admitted
    /// from the observation made before it.
    func afterCheckpointBeforeSpawn<Value>(
        checkpoint: () throws -> Void,
        now: () -> UInt64 = { DispatchTime.now().uptimeNanoseconds },
        spawn: () throws -> Value
    ) throws -> Value {
        try requireTime("supervisor_spawn_deadline", observedAt: now())
        try checkpoint()
        try requireTime("supervisor_spawn_deadline", observedAt: now())
        return try spawn()
    }

    var dispatchDeadline: DispatchTime {
        DispatchTime(uptimeNanoseconds: expiresAt)
    }
}

/// Rejection-only ownership of an already spawned child. Reuses the existing
/// five-second containment reserve; it never authorizes phase work or resume.
/// One instance retains one endpoint across reap, conservation, and both drains.
struct PrimeValidationDriverV2GovernorCleanupBudget {
    static let durationNanoseconds: UInt64 = 5_000_000_000
    private var retained: PrimeValidationDriverV2GovernorDeadline?

    mutating func deadline(
        now: UInt64 = DispatchTime.now().uptimeNanoseconds
    ) throws -> PrimeValidationDriverV2GovernorDeadline {
        if let retained { return retained }
        let created = try PrimeValidationDriverV2GovernorDeadline(
            durationNanoseconds: Self.durationNanoseconds, startedAt: now
        )
        retained = created
        return created
    }
}

/// Exact owned-child reap only. Exit notification does not authorize a blocking
/// wait. Both the caller's existing endpoint and the fixed attempt cap apply.
/// The cap may reject before a longer caller deadline, including after an exit
/// notification; it avoids relying on clock progress and cannot renew time.
/// Its nominal polling interval is not an atomic wall-clock duration guarantee.
enum PrimeValidationDriverV2GovernorExactReap {
    static let pollIntervalMicroseconds: UInt32 = 1_000
    static let maximumPollCount = Int(
        PrimeValidationDriverV2GovernorCleanupBudget.durationNanoseconds / 1_000_000
    )

    static func wait(
        supervisorPID: pid_t,
        deadline: PrimeValidationDriverV2GovernorDeadline,
        now: () -> UInt64 = { DispatchTime.now().uptimeNanoseconds },
        poll: (pid_t, Int32) -> (returnedPID: pid_t, rawStatus: Int32, errorNumber: Int32),
        advance: () -> Void = { _ = Darwin.usleep(pollIntervalMicroseconds) }
    ) throws -> (rawStatus: Int32, returnedAt: UInt64) {
        guard supervisorPID > 0 else {
            throw governorRejected(70, "exact_supervisor_wait_pid")
        }
        for _ in 0..<maximumPollCount {
            try deadline.requireTime("exact_supervisor_wait_deadline", observedAt: now())
            let result = poll(supervisorPID, WNOHANG)
            if result.returnedPID == supervisorPID {
                let signal = result.rawStatus & 0x7f
                guard result.rawStatus >= 0, result.rawStatus <= 0xffff,
                      signal == 0 || (signal > 0 && signal < NSIG)
                else { throw governorRejected(70, "exact_supervisor_wait_nonterminal") }
                // Return the consumed terminal wait even after expiry. Callers
                // acknowledge exact reap before their post-return deadline check.
                return (result.rawStatus, now())
            }
            if result.returnedPID == 0
                || (result.returnedPID == -1 && result.errorNumber == EINTR) {
                advance()
                continue
            }
            throw governorRejected(70, "exact_supervisor_wait_\(result.errorNumber)")
        }
        throw governorRejected(70, "exact_supervisor_wait_poll_limit")
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
    fileprivate let identity: PrimeValidationDriverV2GovernorMetadata
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
    private enum MetadataPolicy {
        case processImage
        case systemTool

        func admits(_ status: stat) -> Bool {
            switch self {
            case .processImage:
                return status.st_flags == 0
            case .systemTool:
                // Xcode can ship transparently compressed executables. Keep
                // their exact flags in the retained metadata and reject drift.
                return status.st_uid == 0 && status.st_gid == 0
                    && (status.st_flags == 0
                        || status.st_flags == UInt32(UF_COMPRESSED))
            }
        }
    }

    let binding: PrimeValidationExecutableBindingV2
    let absolutePath: String
    private(set) var descriptor: Int32
    let identity: PrimeValidationDriverV2GovernorMetadata
    private let xattrs: PrimeValidationDriverV2GovernorXattrs

    init(
        binding: PrimeValidationExecutableBindingV2,
        requiredLeaf: String?,
        coordinate: String,
        systemTool: Bool = false
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
            O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC | O_NONBLOCK
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
                  (systemTool ? MetadataPolicy.systemTool : .processImage)
                    .admits(status),
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

    /// The F executable has one derived location in the already-admitted
    /// frontend's fixed toolchain directory. No caller supplies another path.
    static func fixedSwiftPackage(
        beside frontend: PrimeValidationDriverV2GovernorHeldExecutable
    ) throws -> PrimeValidationDriverV2GovernorHeldExecutable {
        try frontend.revalidate(coordinate: "build_frontend_before")
        let parentPath = URL(fileURLWithPath: frontend.absolutePath)
            .deletingLastPathComponent().path
        let parent = open(parentPath, O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC)
        guard parent >= 3 else {
            if parent >= 0 { close(parent) }
            throw governorRejected(PrimeValidationDriverV2ShotGovernorStatus.admission,
                                   "swift_package_parent_open")
        }
        defer { close(parent) }
        var directory = stat()
        guard fstat(parent, &directory) == 0,
              directory.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              directory.st_uid == 0, directory.st_gid == 0,
              directory.st_mode & 0o022 == 0, directory.st_flags == 0
        else {
            throw governorRejected(PrimeValidationDriverV2ShotGovernorStatus.admission,
                                   "swift_package_parent_metadata")
        }
        let fd = openat(parent, "swift-package", O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK)
        guard fd >= 3 else {
            if fd >= 0 { close(fd) }
            throw governorRejected(PrimeValidationDriverV2ShotGovernorStatus.admission,
                                   "swift_package_measure_open")
        }
        defer { close(fd) }
        var measured = stat()
        guard fstat(fd, &measured) == 0,
              measured.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              measured.st_nlink == 1,
              measured.st_size > 0, measured.st_size <= 64 * 1024 * 1024,
              MetadataPolicy.systemTool.admits(measured),
              measured.st_mode & 0o022 == 0, measured.st_mode & 0o111 != 0,
              fcntl(fd, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw governorRejected(PrimeValidationDriverV2ShotGovernorStatus.admission,
                                   "swift_package_measure_metadata")
        }
        let fs = try PrimeValidationDriverV2GovernorIO.requireLocalAPFS(
            frontend.descriptor, coordinate: "build_frontend_filesystem")
        _ = try PrimeValidationDriverV2GovernorIO.requireLocalAPFS(
            fd, sameAs: fs, coordinate: "swift_package_filesystem")
        let metadata = try PrimeValidationDriverV2GovernorMetadata(measured)
        let data = try PrimeValidationDriverV2GovernorIO.readExact(
            descriptor: fd, byteCount: Int(measured.st_size), coordinate: "swift_package_measure")
        let package = try PrimeValidationDriverV2GovernorHeldExecutable(
            binding: .init(absolutePath: parentPath + "/swift-package", content: .init(data: data)),
            requiredLeaf: "swift-package", coordinate: "swift_package_image", systemTool: true)
        var after = stat(); var named = stat()
        guard fstat(fd, &after) == 0,
              fstatat(parent, "swift-package", &named, AT_SYMLINK_NOFOLLOW) == 0,
              try PrimeValidationDriverV2GovernorMetadata(after) == metadata,
              try PrimeValidationDriverV2GovernorMetadata(named) == metadata,
              package.identity == metadata
        else {
            throw governorRejected(PrimeValidationDriverV2ShotGovernorStatus.admission,
                                   "swift_package_measure_join")
        }
        try frontend.revalidate(coordinate: "build_frontend_after")
        return package
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
    private let selectedRootLeaf: String
    private let publicationCaps: [Int]
    private(set) var descriptor: Int32 = -1
    private let rootDeviceID: UInt64
    private let rootInode: UInt64
    private let rootOwnerUserID: UInt32
    private let rootOwnerGroupID: UInt32
    private let rootXattrs: PrimeValidationDriverV2GovernorXattrs
    private var heldLeaves = [PrimeValidationDriverV2GovernorHeldJournalLeaf]()

    init(
        base: PrimeValidationDriverV2GovernorHeldDirectory,
        filesystem: fsid_t,
        rootLeaf: String = PrimeValidationDriverV2GovernorJournal.rootLeaf
    ) throws {
        guard rootLeaf == Self.rootLeaf
                || rootLeaf == "gate-f-shot-governor-journal"
                || rootLeaf == "gate-g-shot-governor-journal"
                || rootLeaf == "gate-h-shot-governor-journal"
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "outer_journal_leaf"
            )
        }
        selectedRootLeaf = rootLeaf
        publicationCaps = rootLeaf == "gate-h-shot-governor-journal"
            ? [Self.caps[0], Self.caps[1], Self.caps[2], PrimeValidationDriverV2TerminalGate.gateHOuterTerminalMaximumBytes]
            : Self.caps
        baseDescriptor = base.descriptor
        baseAbsolutePath = base.absolutePath
        let result = selectedRootLeaf.withCString {
            mkdirat(base.descriptor, $0, mode_t(0o700))
        }
        guard result == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.admission,
                "outer_journal_create_\(errno)"
            )
        }
        descriptor = selectedRootLeaf.withCString {
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
              data.count <= publicationCaps[ordinal],
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
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK
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
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK
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
        let namedResult = selectedRootLeaf.withCString {
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
                    O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK
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

/// Retains monotone SID evidence and the single scan budget across exact reap
/// and any fail-stop post-reap continuation for one spawned supervisor.
private final class PrimeValidationDriverV2GovernorSessionLifecycleState {
    let supervisorPID: pid_t
    private(set) var capturedGenerations =
        [String: PrimeValidationDriverV2GovernorSessionMember]()
    private(set) var proofProcessGroups: Set<Int32>
    private(set) var completedScanCount = 0

    init(supervisorPID: pid_t) {
        self.supervisorPID = supervisorPID
        proofProcessGroups = [supervisorPID]
    }

    func recordCompletedScan(
        _ members: [PrimeValidationDriverV2GovernorSessionMember]
    ) {
        completedScanCount += 1
        for member in members {
            if capturedGenerations[member.generationKey] == nil {
                capturedGenerations[member.generationKey] = member
            }
            proofProcessGroups.insert(member.processGroupIdentifier)
        }
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
        // Keep a fixed interval inside the same outer deadline for exact reap
        // and retained session-conservation work.
        let containmentReserve =
            PrimeValidationDriverV2GovernorCleanupBudget.durationNanoseconds
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
        sessionIdentifier: pid_t,
        deadline: PrimeValidationDriverV2GovernorDeadline
    ) throws -> [PrimeValidationDriverV2GovernorSessionMember] {
        try deadline.requireTime("session_census_nonconvergent_query")
        var identifiers = [Int32](repeating: 0, count: pidCapacity)
        let byteCapacity = identifiers.count * MemoryLayout<Int32>.size
        errno = 0
        let returned = identifiers.withUnsafeMutableBytes {
            proc_listpids(
                UInt32(PROC_ALL_PIDS),
                0,
                $0.baseAddress,
                Int32($0.count)
            )
        }
        try deadline.requireTime("session_census_nonconvergent_query")
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
        var members = [PrimeValidationDriverV2GovernorSessionMember]()
        for pid in positive.sorted() {
            if let member = try joinedMemberIfInTargetSession(
                pid: pid,
                sessionIdentifier: sessionIdentifier,
                deadline: deadline
            ) {
                members.append(member)
            }
        }
        guard Set(members.map(\.generationKey)).count == members.count else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "session_census_duplicate_generation"
            )
        }
        return members.sorted {
            $0.processIdentifier < $1.processIdentifier
        }
    }

    static func recordedScan(
        lifecycleState:
            PrimeValidationDriverV2GovernorSessionLifecycleState,
        deadline: PrimeValidationDriverV2GovernorDeadline,
        exhaustionCoordinate: String
    ) throws -> [PrimeValidationDriverV2GovernorSessionMember] {
        guard lifecycleState.completedScanCount < maximumScans else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                exhaustionCoordinate
            )
        }
        let members = try scan(
            sessionIdentifier: lifecycleState.supervisorPID,
            deadline: deadline
        )
        lifecycleState.recordCompletedScan(members)
        return members
    }

    private static func joinedMemberIfInTargetSession(
        pid: pid_t,
        sessionIdentifier: pid_t,
        deadline: PrimeValidationDriverV2GovernorDeadline
    ) throws -> PrimeValidationDriverV2GovernorSessionMember? {
        // Exclude a positively identified foreign session before requesting
        // protected process metadata. Target members still require the full
        // generation, session, group and mapped-image joins below.
        try deadline.requireTime("session_census_nonconvergent_query")
        errno = 0
        let preliminarySession = Darwin.getsid(pid)
        let preliminarySessionErrno = errno
        try deadline.requireTime("session_census_nonconvergent_query")
        if preliminarySession < 0, preliminarySessionErrno == ESRCH {
            return nil
        }
        guard preliminarySession >= 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus
                    .containmentUncertain,
                "session_census_getsid_\(preliminarySessionErrno)"
            )
        }
        guard preliminarySession == sessionIdentifier else { return nil }
        let expected = MemoryLayout<proc_bsdinfo>.size
        for _ in 0 ..< 4 {
            try deadline.requireTime("session_census_nonconvergent_query")
            var firstGeneration = proc_bsdinfo()
            errno = 0
            let firstCount = withUnsafeMutablePointer(
                to: &firstGeneration
            ) {
                proc_pidinfo(
                    pid,
                    PROC_PIDTBSDINFO,
                    0,
                    $0,
                    Int32(expected)
                )
            }
            let firstErrno = errno
            try deadline.requireTime("session_census_nonconvergent_query")
            if firstCount <= 0, firstErrno == ESRCH { return nil }
            guard firstCount == Int32(expected) else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "session_census_bsdinfo_\(firstErrno)"
                )
            }
            guard firstGeneration.pbi_pid == UInt32(pid) else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "session_census_bsdinfo_\(firstErrno)"
                )
            }

            errno = 0
            let observedSession = Darwin.getsid(pid)
            let sessionErrno = errno
            try deadline.requireTime("session_census_nonconvergent_query")
            if observedSession < 0, sessionErrno == ESRCH { return nil }
            guard observedSession >= 0 else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "session_census_getsid_\(sessionErrno)"
                )
            }

            var observedGroup: pid_t? = nil
            var mapped:
                (deviceID: UInt64, inode: UInt64, path: String)? = nil
            if observedSession == sessionIdentifier {
                errno = 0
                let group = Darwin.getpgid(pid)
                let groupErrno = errno
                try deadline.requireTime("session_census_nonconvergent_query")
                if group < 0, groupErrno == ESRCH { return nil }
                guard group > 0 else {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus
                            .containmentUncertain,
                        "session_census_getpgid_\(groupErrno)"
                    )
                }
                observedGroup = group
                mapped = try mappedIdentityIfAvailable(
                    pid: pid,
                    deadline: deadline
                )
            }

            var secondGeneration = proc_bsdinfo()
            errno = 0
            let secondCount = withUnsafeMutablePointer(
                to: &secondGeneration
            ) {
                proc_pidinfo(
                    pid,
                    PROC_PIDTBSDINFO,
                    0,
                    $0,
                    Int32(expected)
                )
            }
            let secondErrno = errno
            try deadline.requireTime("session_census_nonconvergent_query")
            if secondCount <= 0, secondErrno == ESRCH { return nil }
            guard secondCount == Int32(expected) else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "session_census_bsdinfo_\(secondErrno)"
                )
            }
            guard secondGeneration.pbi_pid == UInt32(pid) else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "session_census_bsdinfo_\(secondErrno)"
                )
            }
            guard firstGeneration.pbi_start_tvsec
                    == secondGeneration.pbi_start_tvsec,
                  firstGeneration.pbi_start_tvusec
                    == secondGeneration.pbi_start_tvusec
            else {
                continue
            }
            guard observedSession == sessionIdentifier else { return nil }
            guard let observedGroup else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "session_census_getpgid_0"
                )
            }
            return .init(
                processIdentifier: pid,
                parentProcessIdentifier:
                    Int32(secondGeneration.pbi_ppid),
                sessionIdentifier: observedSession,
                processGroupIdentifier: observedGroup,
                ownerUserID: secondGeneration.pbi_uid,
                kernelStatus: secondGeneration.pbi_status,
                startSeconds: secondGeneration.pbi_start_tvsec,
                startMicroseconds: secondGeneration.pbi_start_tvusec,
                mappedDeviceID: mapped?.deviceID,
                mappedInode: mapped?.inode,
                mappedPathTelemetry: mapped?.path
            )
        }
        throw governorRejected(
            PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
            "session_census_nonconvergent_query"
        )
    }

    static func contain(
        lifecycleState:
            PrimeValidationDriverV2GovernorSessionLifecycleState,
        deathWatcher: PrimeValidationDriverV2GovernorDeathWatcher,
        deadline: PrimeValidationDriverV2GovernorDeadline,
        onExactReap: () -> Void
    ) throws -> (
        wait: PrimeValidationDriverV2GovernorWaitObservation,
        conservation: PrimeValidationDriverV2GovernorConservation
    ) {
        let supervisorPID = lifecycleState.supervisorPID
        if deathWatcher.hasObservedExit() {
            return try reapNormallyAfterExit(
                lifecycleState: lifecycleState,
                deathWatcher: deathWatcher,
                deadline: deadline,
                onExactReap: onExactReap
            )
        }

        let stopTarget = -supervisorPID
        try deadline.requireTime("containment_stopped_fixed_point_deadline")
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
            if stopErrno == ESRCH, deathEventObserved {
                return try reapNormallyAfterExit(
                    lifecycleState: lifecycleState,
                    deathWatcher: deathWatcher,
                    deadline: deadline,
                    onExactReap: onExactReap
                )
            }
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

        var previous: [PrimeValidationDriverV2GovernorSessionMember]?
        var fixedPointMembers = [PrimeValidationDriverV2GovernorSessionMember]()
        var stableCount = 0
        while lifecycleState.completedScanCount < maximumScans {
            try deadline.requireTime("containment_stopped_fixed_point_deadline")
            let members = try recordedScan(
                lifecycleState: lifecycleState,
                deadline: deadline,
                exhaustionCoordinate: "session_stopped_fixed_point"
            )
            for group in Set(members.map(\.processGroupIdentifier)) {
                try deadline.requireTime(
                    "containment_stopped_fixed_point_deadline"
                )
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
            if stableCount >= 1 {
                fixedPointMembers = members
                break
            }
            previous = members
            _ = Darwin.usleep(1_000)
        }
        guard stableCount >= 1 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "session_stopped_fixed_point"
            )
        }

        let fixedPointGroups = Set(
            fixedPointMembers.map(\.processGroupIdentifier)
        )
        for group in fixedPointGroups.sorted() where group != supervisorPID {
            try deadline.requireTime(
                "containment_stopped_fixed_point_deadline"
            )
            errno = 0
            if Darwin.kill(-group, SIGKILL) != 0, errno != ESRCH {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                    "session_non_supervisor_kill"
                )
            }
        }
        if fixedPointGroups.contains(supervisorPID) {
            try deadline.requireTime(
                "containment_stopped_fixed_point_deadline"
            )
            errno = 0
            if Darwin.kill(-supervisorPID, SIGKILL) != 0,
               !(errno == ESRCH && deathWatcher.hasObservedExit())
            {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "session_supervisor_kill"
                )
            }
        }
        let wait = try exactWait(
            supervisorPID: supervisorPID,
            deathWatcher: deathWatcher,
            deadline: deadline
        )
        onExactReap()
        try deadline.requireTime("exact_supervisor_wait_return_deadline")
        var emptyCount = 0
        while lifecycleState.completedScanCount < maximumScans,
              emptyCount < 2
        {
            try deadline.requireTime("containment_empty_scan_deadline")
            let members = try recordedScan(
                lifecycleState: lifecycleState,
                deadline: deadline,
                exhaustionCoordinate: "session_not_empty"
            )
            if members.isEmpty { emptyCount += 1 } else {
                emptyCount = 0
                for member in members {
                    try deadline.requireTime(
                        "containment_empty_scan_deadline"
                    )
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
        for member in lifecycleState.capturedGenerations.values {
            try deadline.requireTime("containment_empty_scan_deadline")
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
        for group in lifecycleState.proofProcessGroups {
            try deadline.requireTime("containment_empty_scan_deadline")
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
                capturedMembers:
                    lifecycleState.capturedGenerations.values.sorted {
                    $0.processIdentifier < $1.processIdentifier
                },
                capturedProcessGroups:
                    lifecycleState.proofProcessGroups.sorted(),
                completeScanCount: lifecycleState.completedScanCount,
                finalEmptyScanCount: emptyCount,
                capturedGenerationsAbsent: true,
                capturedGroupsAbsent: true,
                sessionEmpty: true,
                ordinaryExitPath: false
            )
        )
    }

    static func reapNormallyAfterExit(
        lifecycleState:
            PrimeValidationDriverV2GovernorSessionLifecycleState,
        deathWatcher: PrimeValidationDriverV2GovernorDeathWatcher,
        deadline: PrimeValidationDriverV2GovernorDeadline,
        onExactReap: () -> Void
    ) throws -> (
        wait: PrimeValidationDriverV2GovernorWaitObservation,
        conservation: PrimeValidationDriverV2GovernorConservation
    ) {
        let supervisorPID = lifecycleState.supervisorPID
        guard deathWatcher.hasObservedExit() else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "normal_reap_without_death"
            )
        }
        let wait = try exactWait(
            supervisorPID: supervisorPID,
            deathWatcher: deathWatcher,
            deadline: deadline
        )
        onExactReap()
        try deadline.requireTime("exact_supervisor_wait_return_deadline")
        let first = try recordedScan(
            lifecycleState: lifecycleState,
            deadline: deadline,
            exhaustionCoordinate: "post_reap_session_not_empty"
        )
        if !first.isEmpty {
            return (
                wait,
                try containSessionAfterSupervisorReaped(
                    lifecycleState: lifecycleState,
                    deadline: deadline,
                    initialMembers: first
                )
            )
        }
        let second = try recordedScan(
            lifecycleState: lifecycleState,
            deadline: deadline,
            exhaustionCoordinate: "post_reap_session_not_empty"
        )
        if !second.isEmpty {
            return (
                wait,
                try containSessionAfterSupervisorReaped(
                    lifecycleState: lifecycleState,
                    deadline: deadline,
                    initialMembers: second
                )
            )
        }
        for member in lifecycleState.capturedGenerations.values {
            try deadline.requireTime(
                "post_reap_containment_empty_scan_deadline"
            )
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
        for group in lifecycleState.proofProcessGroups {
            try deadline.requireTime(
                "post_reap_containment_empty_scan_deadline"
            )
            errno = 0
            guard Darwin.kill(-group, 0) == -1, errno == ESRCH else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "post_reap_captured_group_present"
                )
            }
        }
        return (
            wait,
            .init(
                supervisorSessionIdentifier: supervisorPID,
                capturedMembers:
                    lifecycleState.capturedGenerations.values.sorted {
                    $0.processIdentifier < $1.processIdentifier
                },
                capturedProcessGroups:
                    lifecycleState.proofProcessGroups.sorted(),
                completeScanCount: lifecycleState.completedScanCount,
                finalEmptyScanCount: 2,
                capturedGenerationsAbsent: true,
                capturedGroupsAbsent: true,
                sessionEmpty: true,
                ordinaryExitPath: true
            )
        )
    }

    /// Continues retained SID/group conservation after exact supervisor reap.
    /// It has no waitpid path, actuates only current complete joined groups,
    /// and proves every cumulative generation and proof group absent. A new
    /// invocation resets only its local fixed-point and empty-scan counters.
    static func containSessionAfterSupervisorReaped(
        lifecycleState:
            PrimeValidationDriverV2GovernorSessionLifecycleState,
        deadline: PrimeValidationDriverV2GovernorDeadline
    ) throws -> PrimeValidationDriverV2GovernorConservation {
        return try containSessionAfterSupervisorReaped(
            lifecycleState: lifecycleState,
            deadline: deadline,
            initialMembers: []
        )
    }

    private static func containSessionAfterSupervisorReaped(
        lifecycleState:
            PrimeValidationDriverV2GovernorSessionLifecycleState,
        deadline: PrimeValidationDriverV2GovernorDeadline,
        initialMembers: [PrimeValidationDriverV2GovernorSessionMember]
    ) throws -> PrimeValidationDriverV2GovernorConservation {
        let supervisorPID = lifecycleState.supervisorPID
        var previous: [PrimeValidationDriverV2GovernorSessionMember]?
        var fixedPointMembers = [PrimeValidationDriverV2GovernorSessionMember]()
        var stableCount = 0

        if !initialMembers.isEmpty {
            for group in Set(initialMembers.map(\.processGroupIdentifier)) {
                try deadline.requireTime(
                    "post_reap_containment_stopped_fixed_point_deadline"
                )
                errno = 0
                if Darwin.kill(-group, SIGSTOP) != 0, errno != ESRCH {
                    throw governorRejected(
                        PrimeValidationDriverV2ShotGovernorStatus
                            .containmentUncertain,
                        "post_reap_session_group_stop_\(errno)"
                    )
                }
            }
            previous = initialMembers
        }

        while lifecycleState.completedScanCount < maximumScans {
            try deadline.requireTime(
                "post_reap_containment_stopped_fixed_point_deadline"
            )
            let members = try recordedScan(
                lifecycleState: lifecycleState,
                deadline: deadline,
                exhaustionCoordinate:
                    "post_reap_session_stopped_fixed_point"
            )
            for group in Set(members.map(\.processGroupIdentifier)) {
                try deadline.requireTime(
                    "post_reap_containment_stopped_fixed_point_deadline"
                )
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
            if stableCount >= 1 {
                fixedPointMembers = members
                break
            }
            previous = members
            _ = Darwin.usleep(1_000)
        }
        guard stableCount >= 1 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
                "post_reap_session_stopped_fixed_point"
            )
        }

        let fixedPointGroups = Set(
            fixedPointMembers.map(\.processGroupIdentifier)
        )
        for group in fixedPointGroups.sorted() {
            try deadline.requireTime(
                "post_reap_containment_stopped_fixed_point_deadline"
            )
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
        while lifecycleState.completedScanCount < maximumScans,
              emptyCount < 2
        {
            try deadline.requireTime(
                "post_reap_containment_empty_scan_deadline"
            )
            let members = try recordedScan(
                lifecycleState: lifecycleState,
                deadline: deadline,
                exhaustionCoordinate: "post_reap_session_not_empty"
            )
            if members.isEmpty {
                emptyCount += 1
            } else {
                emptyCount = 0
                for member in members {
                    try deadline.requireTime(
                        "post_reap_containment_empty_scan_deadline"
                    )
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
        for member in lifecycleState.capturedGenerations.values {
            try deadline.requireTime(
                "post_reap_containment_empty_scan_deadline"
            )
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
        for group in lifecycleState.proofProcessGroups {
            try deadline.requireTime(
                "post_reap_containment_empty_scan_deadline"
            )
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
            capturedMembers:
                lifecycleState.capturedGenerations.values.sorted {
                $0.processIdentifier < $1.processIdentifier
            },
            capturedProcessGroups:
                lifecycleState.proofProcessGroups.sorted(),
            completeScanCount: lifecycleState.completedScanCount,
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
        let result = try PrimeValidationDriverV2GovernorExactReap.wait(
            supervisorPID: supervisorPID,
            deadline: deadline,
            poll: { pid, options in
                var raw: Int32 = 0
                errno = 0
                let returned = Darwin.waitpid(pid, &raw, options)
                return (returned, raw, errno)
            }
        )
        return .init(
            pid: supervisorPID,
            rawStatus: result.rawStatus,
            waitOptions: WNOHANG,
            returnedAt: result.returnedAt
        )
    }

    private static func bsdInfoIfPresent(pid: pid_t) throws -> proc_bsdinfo? {
        var value = proc_bsdinfo()
        let size = MemoryLayout<proc_bsdinfo>.size
        errno = 0
        let returned = withUnsafeMutablePointer(to: &value) {
            proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, $0, Int32(size))
        }
        if returned == Int32(size) {
            guard value.pbi_pid == UInt32(pid) else {
                throw governorRejected(
                    PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    "captured_generation_query_\(errno)"
                )
            }
            return value
        }
        if returned <= 0, errno == ESRCH { return nil }
        throw governorRejected(
            PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain,
            "captured_generation_query_\(errno)"
        )
    }

    private static func mappedIdentityIfAvailable(
        pid: pid_t,
        deadline: PrimeValidationDriverV2GovernorDeadline
    ) throws -> (deviceID: UInt64, inode: UInt64, path: String)? {
        var address: UInt64 = 0
        for _ in 0 ..< 256 {
            try deadline.requireTime("session_census_nonconvergent_query")
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
            try deadline.requireTime("session_census_nonconvergent_query")
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
    let lifecycleState: PrimeValidationDriverV2GovernorSessionLifecycleState
    let appliedFlags: UInt16
    let spawnedAtUptimeNanoseconds: UInt64
    let cwdProof: PrimeValidationDriverV2GovernorCWDProof
    let mappedImageProof: PrimeValidationDriverV2GovernorMappedImageProof
    let deathWatcher: PrimeValidationDriverV2GovernorDeathWatcher
    let stdoutDrain: PrimeValidationDriverV2GovernorDrain
    let stderrDrain: PrimeValidationDriverV2GovernorDrain
    let containmentGuard: PrimeValidationDriverV2GovernorSpawnContainmentGuard

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

/// Pure ownership-transition coordinator. Cleanup cannot authorize a resume or
/// spawn; its single endpoint and terminal result cannot be renewed by retry.
final class PrimeValidationDriverV2GovernorCleanupTransition {
    enum Disposition: Equatable { case contained, mustFailStop }
    private enum State { case armed, exactReapCompleted, conservationCompleted, drainsCompleted, failed }
    private var state: State = .armed
    private var budget = PrimeValidationDriverV2GovernorCleanupBudget()
    private let contain: (PrimeValidationDriverV2GovernorDeadline, () -> Void) throws -> Void
    private let conserve: (PrimeValidationDriverV2GovernorDeadline) throws -> Void
    private let stdout: (PrimeValidationDriverV2GovernorDeadline) throws -> Void
    private let stderr: (PrimeValidationDriverV2GovernorDeadline) throws -> Void

    init(contain: @escaping (PrimeValidationDriverV2GovernorDeadline, () -> Void) throws -> Void,
         conserve: @escaping (PrimeValidationDriverV2GovernorDeadline) throws -> Void,
         stdout: @escaping (PrimeValidationDriverV2GovernorDeadline) throws -> Void,
         stderr: @escaping (PrimeValidationDriverV2GovernorDeadline) throws -> Void) {
        self.contain = contain; self.conserve = conserve
        self.stdout = stdout; self.stderr = stderr
    }
    func acceptExactReap() { if case .armed = state { state = .exactReapCompleted } }
    func acceptConservation() { if case .exactReapCompleted = state { state = .conservationCompleted } }
    func acceptFinishedDrains() { if case .conservationCompleted = state { state = .drainsCompleted } }

    func cleanup(now: UInt64 = DispatchTime.now().uptimeNanoseconds) -> Disposition {
        if case .drainsCompleted = state { return .contained }
        if case .failed = state { return .mustFailStop }
        let deadline: PrimeValidationDriverV2GovernorDeadline
        do { deadline = try budget.deadline(now: now) }
        catch { state = .failed; return .mustFailStop }
        let containment = Result<Void, Error> {
            if case .armed = state {
                do {
                    try contain(deadline, acceptExactReap)
                    // The operation must acknowledge its sole exact reap.
                    guard case .exactReapCompleted = state else {
                        throw governorRejected(70, "cleanup_exact_reap_unacknowledged")
                    }
                    state = .conservationCompleted
                } catch {
                    guard case .exactReapCompleted = state else { throw error }
                    try conserve(deadline)
                    state = .conservationCompleted
                }
            } else if case .exactReapCompleted = state {
                try conserve(deadline)
                state = .conservationCompleted
            }
        }
        // Request/finish both drains even if containment or the first fails.
        let output = Result { try stdout(deadline) }
        let error = Result { try stderr(deadline) }
        guard case .success = containment, case .success = output, case .success = error else {
            state = .failed; return .mustFailStop
        }
        state = .drainsCompleted
        return .contained
    }
}

/// Armed before fallible post-spawn proof, and transferred with the spawned
/// value. A failed cleanup never escapes as an ordinary thrown rejection.
private final class PrimeValidationDriverV2GovernorSpawnContainmentGuard {
    private let transition: PrimeValidationDriverV2GovernorCleanupTransition
    init(lifecycleState: PrimeValidationDriverV2GovernorSessionLifecycleState,
         deathWatcher: PrimeValidationDriverV2GovernorDeathWatcher,
         stdoutDrain: PrimeValidationDriverV2GovernorDrain,
         stderrDrain: PrimeValidationDriverV2GovernorDrain) {
        transition = .init(contain: { deadline, onReap in
            _ = try PrimeValidationDriverV2GovernorSessionCensus.contain(
                lifecycleState: lifecycleState, deathWatcher: deathWatcher,
                deadline: deadline, onExactReap: onReap)
        }, conserve: { deadline in
            _ = try PrimeValidationDriverV2GovernorSessionCensus.containSessionAfterSupervisorReaped(
                lifecycleState: lifecycleState, deadline: deadline)
        }, stdout: { deadline in _ = try stdoutDrain.finish(deadline: deadline) },
           stderr: { deadline in _ = try stderrDrain.finish(deadline: deadline) })
    }
    func acceptExactReap() { transition.acceptExactReap() }
    func acceptConservation() { transition.acceptConservation() }
    func acceptFinishedDrains() { transition.acceptFinishedDrains() }
    deinit {
        if transition.cleanup() == .mustFailStop {
            // Containment is uncertain: diagnostics must not delay exit.
            Darwin._exit(PrimeValidationDriverV2ShotGovernorStatus.containmentUncertain)
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
        let spawnResult = try deadline.afterCheckpointBeforeSpawn(
            checkpoint: preSpawnContinuityCheckpoint
        ) {
            try arguments.withUnsafeMutableBufferPointer { argv in
                try environment.withUnsafeMutableBufferPointer { envp in
                    try deadline.requireTime("supervisor_immediately_before_spawn")
                    return posix_spawn(
                        &pid,
                        executable.absolutePath,
                        &actions,
                        &attributes,
                        argv.baseAddress!,
                        envp.baseAddress!
                    )
                }
            }
        }
        let spawnedAt = DispatchTime.now().uptimeNanoseconds
        guard spawnResult == 0, pid > 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "supervisor_spawn_\(spawnResult)"
            )
        }
        let lifecycleState =
            PrimeValidationDriverV2GovernorSessionLifecycleState(
                supervisorPID: pid
            )
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
        let containmentGuard = PrimeValidationDriverV2GovernorSpawnContainmentGuard(
            lifecycleState: lifecycleState, deathWatcher: deathWatcher,
            stdoutDrain: stdoutDrain, stderrDrain: stderrDrain)
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
                lifecycleState: lifecycleState,
                appliedFlags: supervisorFlags,
                spawnedAtUptimeNanoseconds: spawnedAt,
                cwdProof: cwd,
                mappedImageProof: mapped,
                deathWatcher: deathWatcher,
                stdoutDrain: stdoutDrain,
                stderrDrain: stderrDrain,
                containmentGuard: containmentGuard
            )
        } catch {
            // Keeping the guard live through the initiating error preserves
            // that error only if bounded cleanup certifies containment.
            withExtendedLifetime(containmentGuard) {}
            throw error
        }
    }
}

/// Post-reap observation only. Every child is acquired relative to a retained
/// admitted root; decoded records never recover a build or staging capability.
private final class PrimeValidationDriverV2GovernorBuildSnapshot {
    private struct Prestart: Codable {
        let schema: String
        let runID: String
        let deadlineStartedAtUptimeNanoseconds: UInt64
        let deadlineExpiresAtUptimeNanoseconds: UInt64
        let executableAbsolutePath: String
        let executableSHA256: String
        let logicalArgumentZero: String
        let physicalArgumentZero: String?
        let arguments: [String]
        let orderedEnvironment: [[String]]
        let workingDirectoryAbsolutePath: String
    }
    private struct Start: Codable {
        let schema: String
        let prestartSHA256: String
        let processIdentifier: Int32
        let sessionIdentifier: Int32
        let processGroupIdentifier: Int32
        let appliedSpawnFlags: UInt16
        let spawnReturnedUptimeNanoseconds: UInt64
        let mappedExecutablePathTelemetry: String
        let exactSuspendedWorkingDirectoryJoin: Bool
    }
    private struct Terminal: Codable {
        let schema: String
        let startSHA256: String
        let process: PrimeValidationDriverV2BuildProcessObservation
    }
    // These two projections are read only after the complete Gate E frames
    // have passed their existing typed canonical validator.
    private struct EDeadline: Decodable {
        let deadlineExpiresAtUptimeNanoseconds: UInt64
    }
    private struct ELastWait: Decodable {
        let waitReturnedUptimeNanoseconds: UInt64
    }

    fileprivate final class Node {
        private(set) var descriptor: Int32 = -1
        let parent: Int32
        let leaf: String
        let directory: Bool
        let metadata: PrimeValidationDriverV2GovernorMetadata
        let xattrs: PrimeValidationDriverV2GovernorXattrs
        let data: Data?
        let entries: [String]?
        let deadline: PrimeValidationDriverV2GovernorDeadline

        init(parent: Int32, leaf: String, directory: Bool,
             owner: PrimeValidationDriverV2GovernorMetadata,
             maximumBytes: UInt64 = 0, entries: [String]? = nil,
             deadline: PrimeValidationDriverV2GovernorDeadline) throws {
            try deadline.requireTime("build_readback_deadline")
            guard !leaf.isEmpty, leaf != ".", leaf != "..",
                  !leaf.contains("/"), !leaf.utf8.contains(0)
            else { throw Self.rejected("leaf") }
            let fd = openat(parent, leaf, O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK
                | (directory ? O_DIRECTORY : 0))
            guard fd >= 3 else {
                if fd >= 0 { close(fd) }
                throw Self.rejected("open_" + leaf)
            }
            do {
                var status = stat()
                guard fstat(fd, &status) == 0,
                      status.st_mode & mode_t(S_IFMT)
                        == mode_t(directory ? S_IFDIR : S_IFREG),
                      status.st_uid == owner.ownerUserID,
                      status.st_gid == owner.ownerGroupID,
                      status.st_mode & 0o7777 == (directory ? 0o700 : 0o444),
                      status.st_flags == 0,
                      directory || status.st_nlink == 1,
                      status.st_size >= 0,
                      directory || UInt64(status.st_size) <= maximumBytes,
                      fcntl(fd, F_GETFD) & FD_CLOEXEC != 0
                else { throw Self.rejected("metadata_" + leaf) }
                let parentFS = try PrimeValidationDriverV2GovernorIO
                    .requireLocalAPFS(parent, coordinate: "build_readback_parent")
                _ = try PrimeValidationDriverV2GovernorIO.requireLocalAPFS(
                    fd, sameAs: parentFS, coordinate: "build_readback_node")
                self.descriptor = fd; self.parent = parent; self.leaf = leaf
                self.directory = directory; self.deadline = deadline
                self.metadata = try PrimeValidationDriverV2GovernorMetadata(status)
                self.xattrs = try PrimeValidationDriverV2GovernorXattrs.capture(
                    fd, coordinate: "build_readback_" + leaf)
                self.entries = entries
                self.data = directory ? nil : try PrimeValidationDriverV2GovernorIO
                    .readExact(descriptor: fd, byteCount: Int(status.st_size),
                               coordinate: "build_readback_" + leaf)
                try revalidate()
            } catch { close(fd); descriptor = -1; throw error }
        }

        deinit { if descriptor >= 3 { close(descriptor) } }

        func revalidate() throws {
            try deadline.requireTime("build_readback_revalidate_deadline")
            var held = stat(); var named = stat()
            guard fstat(descriptor, &held) == 0,
                  fstatat(parent, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0,
                  held.st_mode & mode_t(S_IFMT)
                    == mode_t(directory ? S_IFDIR : S_IFREG),
                  named.st_mode == held.st_mode,
                  try PrimeValidationDriverV2GovernorMetadata(held) == metadata,
                  try PrimeValidationDriverV2GovernorMetadata(named) == metadata,
                  fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0,
                  try PrimeValidationDriverV2GovernorXattrs.capture(
                    descriptor, coordinate: "build_readback_" + leaf) == xattrs
            else { throw Self.rejected("changed_" + leaf) }
            if let entries {
                guard try PrimeValidationDriverV2GovernorIO.inventory(
                    directory: descriptor, coordinate: "build_readback_" + leaf
                ) == entries else { throw Self.rejected("inventory_" + leaf) }
            }
            if let data {
                guard try PrimeValidationDriverV2GovernorIO.readExact(
                    descriptor: descriptor, byteCount: data.count,
                    coordinate: "build_readback_" + leaf
                ) == data else { throw Self.rejected("bytes_" + leaf) }
            }
            try deadline.requireTime("build_readback_revalidate_finished")
        }

        private static func rejected(_ coordinate: String)
            -> PrimeValidationDriverV2ShotGovernorFailure {
            governorRejected(PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                             "build_readback_" + coordinate)
        }
    }

    private let prime: PrimeValidationDriverV2GovernorHeldDirectory
    private let workspace: PrimeValidationDriverV2GovernorHeldDirectory
    private let evidence: PrimeValidationDriverV2GovernorHeldDirectory
    private let swiftPackageImage: PrimeValidationDriverV2GovernorHeldExecutable
    private let runID: String
    private let directories: [Node]
    private let files: [Node]
    private let artifacts: PrimeValidationDriverV2BuildArtifactsReadback
    private let pinnedBundle: PrimeValidationDriverV2PinnedBundleReadback
    private let pinnedBundleInput: PrimeValidationDriverV2PinnedBundleInputReadback
    private let lockedDependencies: PrimeValidationDriverV2LockedDependencyReadback
    let envelope: PrimeValidationDriverV2BuildDurableBindingEnvelopeV1
    let bindingSHA256: String
    let binding: PrimeArtifactBinding
    let leaves: [PrimeValidationDriverV2GovernorInnerLeaf]
    let vnodes: [PrimeValidationDriverV2GovernorVnodeRecord]
    private static let workspaceLeaves = [
        "cache", "clang-module-cache", "config", "home", "output",
        "root-release-build", "security", "swiftpm-module-cache", "temporary",
    ]
    private static let buildLeaves = [
        "binding.json", "prestart.json", "start.json", "stderr.log", "stdout.log",
        "terminal.json",
    ]

    init(prime: PrimeValidationDriverV2GovernorHeldDirectory,
         workspace: PrimeValidationDriverV2GovernorHeldDirectory,
         evidence: PrimeValidationDriverV2GovernorHeldDirectory,
         swiftPackageImage: PrimeValidationDriverV2GovernorHeldExecutable,
         pinnedBundleInput: PrimeValidationDriverV2PinnedBundleInputReadback,
         lockedDependencies: PrimeValidationDriverV2LockedDependencyReadback,
         intent: PrimeValidationRunIntentV2,
         supervisorPID: Int32, supervisorWaitUptime: UInt64,
         predecessor: PrimeValidationDriverV2GovernorInnerSnapshot,
         terminalGate: PrimeValidationDriverV2TerminalGate = .gateF,
         deadline: PrimeValidationDriverV2GovernorDeadline) throws {
        self.prime = prime
        self.workspace = workspace; self.evidence = evidence; self.runID = intent.runID
        self.swiftPackageImage = swiftPackageImage
        self.pinnedBundleInput = pinnedBundleInput
        self.lockedDependencies = lockedDependencies
        guard terminalGate == .gateF || terminalGate == .gateG || terminalGate == .gateH,
              predecessor.complete, predecessor.durableFrames.count == 34,
              let rawTerminalSHA256 = predecessor.rawTerminalSHA256
        else { throw Self.rejected("predecessor") }
        try prime.revalidate(coordinate: "build_prime")
        try workspace.revalidate(coordinate: "build_workspace")
        try evidence.revalidate(coordinate: "build_evidence")
        try Self.requireRootEntries(workspace: workspace, evidence: evidence, runID: runID)
        var heldDirectories: [Node] = []
        for leaf in Self.workspaceLeaves {
            heldDirectories.append(try Node(
                parent: workspace.descriptor, leaf: leaf, directory: true,
                owner: workspace.identity, deadline: deadline))
        }
        let run = try Node(parent: evidence.descriptor, leaf: runID, directory: true,
                           owner: evidence.identity,
                           entries: terminalGate == .gateH ? ["artifacts", "build", "execution", "inventory"]
                            : terminalGate == .gateG ? ["artifacts", "build", "inventory"] : ["artifacts", "build"],
                           deadline: deadline)
        heldDirectories.append(run)
        let build = try Node(parent: run.descriptor, leaf: "build", directory: true,
                             owner: evidence.identity, entries: Self.buildLeaves,
                             deadline: deadline)
        heldDirectories.append(build)
        let artifactRoot = try Node(parent: run.descriptor, leaf: "artifacts",
                                    directory: true, owner: evidence.identity,
                                    entries: ["default.metallib", "test-bundle"],
                                    deadline: deadline)
        heldDirectories.append(artifactRoot)
        var heldFiles: [Node] = []
        for leaf in Self.buildLeaves {
            heldFiles.append(try Node(
                parent: build.descriptor, leaf: leaf, directory: false,
                owner: evidence.identity,
                maximumBytes: leaf == "binding.json" || leaf.hasSuffix(".log")
                    ? 16 * 1024 * 1024 : 256 * 1024,
                deadline: deadline))
        }
        guard Set(heldDirectories.map { "\($0.metadata.deviceID):\($0.metadata.inode)" })
                .count == heldDirectories.count,
              Set(heldFiles.map { "\($0.metadata.deviceID):\($0.metadata.inode)" })
                .count == heldFiles.count
        else { throw Self.rejected("aliased_nodes") }
        let byName = Dictionary(uniqueKeysWithValues: heldFiles.map { ($0.leaf, $0) })
        let bindingData = byName["binding.json"]!.data!
        let envelope = try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2BuildDurableBindingEnvelopeV1.self, from: bindingData)
        try envelope.validate(intent: intent, expectedSupervisorPID: supervisorPID,
                              expectedPredecessorRawTerminalSHA256: rawTerminalSHA256)
        guard try pinnedBundleInput.revalidate() == envelope.pinnedBundle.input
        else { throw Self.rejected("pinned_bundle_prelaunch_input_join") }
        let prestart = try PrimeCanonicalJSON.decode(Prestart.self,
            from: byName["prestart.json"]!.data!)
        let start = try PrimeCanonicalJSON.decode(Start.self, from: byName["start.json"]!.data!)
        let terminal = try PrimeCanonicalJSON.decode(Terminal.self,
            from: byName["terminal.json"]!.data!)
        let p = envelope.process
        let executable = envelope.toolchain.swiftPackageExecutable
        guard executable.requestedAbsolutePath == swiftPackageImage.absolutePath,
              executable.canonicalAbsolutePath == swiftPackageImage.absolutePath,
              executable.content == swiftPackageImage.binding.content,
              executable.deviceID == swiftPackageImage.identity.deviceID,
              executable.inode == swiftPackageImage.identity.inode,
              p.executableAbsolutePath == swiftPackageImage.absolutePath,
              p.executableByteCount == swiftPackageImage.identity.byteCount,
              p.executableSHA256 == swiftPackageImage.binding.content.sha256,
              p.executableDeviceID == swiftPackageImage.identity.deviceID,
              p.executableInode == swiftPackageImage.identity.inode
        else { throw Self.rejected("swift_package_image_join") }
        let eDeadline = try JSONDecoder().decode(EDeadline.self,
            from: predecessor.durableFrames[0].framedBytes)
        let lastEWait = try JSONDecoder().decode(ELastWait.self,
            from: predecessor.durableFrames[32].framedBytes)
        guard prestart.schema == "prime_driver_v2_gate_f_build_prestart_v1",
              prestart.runID == intent.runID,
              prestart.deadlineStartedAtUptimeNanoseconds == p.deadlineStartedAtUptimeNanoseconds,
              prestart.deadlineExpiresAtUptimeNanoseconds == p.deadlineExpiresAtUptimeNanoseconds,
              prestart.executableAbsolutePath == p.executableAbsolutePath,
              prestart.executableSHA256 == p.executableSHA256,
              prestart.logicalArgumentZero == p.logicalArgumentZero,
              prestart.physicalArgumentZero == p.physicalArgumentZero,
              prestart.arguments == p.arguments,
              prestart.orderedEnvironment == p.orderedEnvironment,
              prestart.workingDirectoryAbsolutePath == p.workingDirectoryAbsolutePath,
              start.schema == "prime_driver_v2_gate_f_build_start_v1",
              start.prestartSHA256 == PrimeSHA256.hexDigest(of: byName["prestart.json"]!.data!),
              start.processIdentifier == p.processIdentifier,
              start.sessionIdentifier == p.sessionIdentifier,
              start.processGroupIdentifier == p.processGroupIdentifier,
              start.appliedSpawnFlags == p.appliedSpawnFlags,
              start.spawnReturnedUptimeNanoseconds == p.spawnReturnedUptimeNanoseconds,
              start.mappedExecutablePathTelemetry == p.executableAbsolutePath,
              start.exactSuspendedWorkingDirectoryJoin == p.exactSuspendedWorkingDirectoryJoin,
              terminal.schema == "prime_driver_v2_gate_f_build_terminal_v1",
              terminal.startSHA256 == PrimeSHA256.hexDigest(of: byName["start.json"]!.data!),
              terminal.process == p,
              p.deadlineStartedAtUptimeNanoseconds >= lastEWait.waitReturnedUptimeNanoseconds,
              p.deadlineStartedAtUptimeNanoseconds < eDeadline.deadlineExpiresAtUptimeNanoseconds,
              p.deadlineExpiresAtUptimeNanoseconds < deadline.expiresAt,
              envelope.artifacts.captureCompletedAtUptimeNanoseconds <= supervisorWaitUptime,
              !predecessor.recordedChildProcessGroups.contains(p.processGroupIdentifier)
        else { throw Self.rejected("journal_process_join") }
        for (leaf, stream) in [("stdout.log", p.standardOutput), ("stderr.log", p.standardError)] {
            let file = byName[leaf]!
            guard file.metadata.deviceID == stream.outputDeviceID,
                  file.metadata.inode == stream.outputInode,
                  file.metadata.byteCount == stream.outputByteCount,
                  file.metadata.permissionMode == stream.outputPermissionMode,
                  PrimeSHA256.hexDigest(of: file.data!) == stream.outputSHA256
            else { throw Self.rejected("stream_join_" + leaf) }
        }
        self.envelope = envelope
        self.bindingSHA256 = PrimeSHA256.hexDigest(of: bindingData)
        self.binding = .init(relativePath: "binding.json",
            sha256: PrimeSHA256.hexDigest(of: bindingData),
            byteCount: UInt64(bindingData.count), purpose: .immutableData)
        self.leaves = heldFiles.map {
            .init(leaf: $0.leaf, byteCount: $0.metadata.byteCount,
                  sha256: PrimeSHA256.hexDigest(of: $0.data!))
        }
        self.vnodes = heldFiles.map { .init($0.metadata) }
        self.directories = heldDirectories; self.files = heldFiles
        self.pinnedBundle = try PrimeValidationDriverV2PinnedBundleReadback.capture(
            primeRootDescriptor: prime.descriptor, workspaceRootDescriptor: workspace.descriptor,
            expected: envelope.pinnedBundle, deadlineNanoseconds: deadline.expiresAt)
        // The inputs were held before the supervisor started. Join the one
        // derived mirror file after F and keep that same owner through publication.
        try lockedDependencies.bindExistingMirrors(workspaceRootDescriptor: workspace.descriptor)
        self.artifacts = try PrimeValidationDriverV2BuildArtifactsReadback.capture(
            workspaceRootDescriptor: workspace.descriptor,
            artifactRootDescriptor: artifactRoot.descriptor,
            expected: envelope.artifacts, deadlineNanoseconds: deadline.expiresAt)
        try revalidate()
    }

    func revalidate() throws {
        try prime.revalidate(coordinate: "build_prime_after")
        try swiftPackageImage.revalidate(coordinate: "swift_package_build_readback")
        try workspace.revalidate(coordinate: "build_workspace_after")
        try evidence.revalidate(coordinate: "build_evidence_after")
        try Self.requireRootEntries(workspace: workspace, evidence: evidence, runID: runID)
        for directory in directories { try directory.revalidate() }
        for file in files { try file.revalidate() }
        try lockedDependencies.revalidateBoundMirrors()
        guard try pinnedBundleInput.revalidate() == envelope.pinnedBundle.input
        else { throw Self.rejected("pinned_bundle_input_changed") }
        guard try pinnedBundle.revalidate() == envelope.pinnedBundle
        else { throw Self.rejected("pinned_bundle_changed") }
        guard try artifacts.revalidate() == envelope.artifacts
        else { throw Self.rejected("artifacts_changed") }
        for directory in directories { try directory.revalidate() }
        guard try pinnedBundle.revalidate() == envelope.pinnedBundle
        else { throw Self.rejected("pinned_bundle_changed_after_artifacts") }
        guard try pinnedBundleInput.revalidate() == envelope.pinnedBundle.input
        else { throw Self.rejected("pinned_bundle_input_changed_after_artifacts") }
        try prime.revalidate(coordinate: "build_prime_final")
        try lockedDependencies.revalidateBoundMirrors()
    }

    private static func requireRootEntries(
        workspace: PrimeValidationDriverV2GovernorHeldDirectory,
        evidence: PrimeValidationDriverV2GovernorHeldDirectory, runID: String
    ) throws {
        guard try PrimeValidationDriverV2GovernorIO.inventory(
                directory: workspace.descriptor, coordinate: "build_workspace") == workspaceLeaves,
              try PrimeValidationDriverV2GovernorIO.inventory(
                directory: evidence.descriptor, coordinate: "build_evidence") == [runID]
        else { throw rejected("root_inventory") }
    }

    private static func rejected(_ coordinate: String)
        -> PrimeValidationDriverV2ShotGovernorFailure {
        governorRejected(PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                         "build_readback_" + coordinate)
    }
}

/// G observes the exact files below retained evidence descriptors after reap.
/// The decoded inventory envelope cannot recreate an inventory or H owner.
private final class PrimeValidationDriverV2GovernorInventorySnapshot {
    private typealias Node = PrimeValidationDriverV2GovernorBuildSnapshot.Node
    private let evidence: PrimeValidationDriverV2GovernorHeldDirectory
    private let build: PrimeValidationDriverV2GovernorBuildSnapshot
    private let directories: [Node]
    private let files: [Node]
    let envelope: PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1
    let bindingSHA256: String
    let receiptIdentitySHA256: String
    let leaves: [PrimeValidationDriverV2GovernorInnerLeaf]
    let vnodes: [PrimeValidationDriverV2GovernorVnodeRecord]
    private static let inventoryLeaves = [
        "01-xctest-prestart.json", "01-xctest-start.json", "01-xctest-terminal.json",
        "02-swift-testing-prestart.json", "02-swift-testing-start.json", "02-swift-testing-terminal.json",
        "binding.json", "swift-testing-list.stderr.log", "swift-testing-list.stdout.log",
        "terminal.json", "xctest-list.stderr.log", "xctest-list.stdout.log",
    ]

    init(evidence: PrimeValidationDriverV2GovernorHeldDirectory,
         build: PrimeValidationDriverV2GovernorBuildSnapshot,
         intent: PrimeValidationRunIntentV2,
         supervisorPID: Int32, supervisorWaitUptime: UInt64,
         predecessorProcessGroups: Set<Int32>,
         terminalGate: PrimeValidationDriverV2TerminalGate = .gateG,
         deadline: PrimeValidationDriverV2GovernorDeadline) throws {
        self.evidence = evidence; self.build = build
        try build.revalidate()
        try evidence.revalidate(coordinate: "inventory_evidence")
        let run = try Node(parent: evidence.descriptor, leaf: intent.runID,
            directory: true, owner: evidence.identity,
            entries: terminalGate == .gateH ? ["artifacts", "build", "execution", "inventory"]
                : ["artifacts", "build", "inventory"], deadline: deadline)
        let inventory = try Node(parent: run.descriptor, leaf: "inventory",
            directory: true, owner: evidence.identity,
            entries: Self.inventoryLeaves, deadline: deadline)
        let files = try Self.inventoryLeaves.map { leaf in
            try Node(parent: inventory.descriptor, leaf: leaf, directory: false,
                owner: evidence.identity,
                maximumBytes: leaf == "binding.json" || leaf.hasSuffix(".log")
                    ? 16 * 1024 * 1024 : 256 * 1024,
                deadline: deadline)
        }
        guard Set(files.map { "\($0.metadata.deviceID):\($0.metadata.inode)" }).count == files.count,
              run.metadata.inode != inventory.metadata.inode
                || run.metadata.deviceID != inventory.metadata.deviceID
        else { throw Self.rejected("aliased_nodes") }
        let byName = Dictionary(uniqueKeysWithValues: files.map { ($0.leaf, $0) })
        let bindingData = byName["binding.json"]!.data!
        let envelope = try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.self, from: bindingData)
        try envelope.validate(intent: intent, expectedSupervisorPID: supervisorPID,
            build: build.envelope, expectedBuildBinding: build.binding)
        guard envelope.children.count == 2,
              envelope.children.map(\.role) == ["list_xctest", "list_swift_testing"],
              envelope.predecessorBuildBinding == build.binding,
              envelope.receipt.xctestListData == byName["xctest-list.stdout.log"]!.data!,
              envelope.receipt.swiftTestingListData == byName["swift-testing-list.stdout.log"]!.data!
        else { throw Self.rejected("envelope_joins") }
        let sequence = try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2InventorySequenceTerminalV1.self,
            from: byName["terminal.json"]!.data!)
        guard sequence.schema == "prime_driver_v2_gate_g_inventory_terminal_v1",
              sequence.runID == intent.runID,
              sequence.predecessorBuildBindingSHA256 == build.bindingSHA256,
              sequence.orderedChildTerminalSHA256Values
                == envelope.children.map { $0.terminalBinding.sha256 },
              envelope.terminalBinding == Self.binding(byName["terminal.json"]!)
        else { throw Self.rejected("sequence_terminal") }
        var predecessorSHA256 = build.bindingSHA256
        var previousWait = build.envelope.artifacts.captureCompletedAtUptimeNanoseconds
        let first = envelope.children[0].process
        guard first.deadlineStartedAtUptimeNanoseconds >= previousWait,
              first.deadlineStartedAtUptimeNanoseconds
                < build.envelope.process.deadlineExpiresAtUptimeNanoseconds,
              first.deadlineExpiresAtUptimeNanoseconds > first.deadlineStartedAtUptimeNanoseconds,
              first.deadlineExpiresAtUptimeNanoseconds - first.deadlineStartedAtUptimeNanoseconds
                == 300_000_000_000,
              first.deadlineExpiresAtUptimeNanoseconds < deadline.expiresAt
        else { throw Self.rejected("transferred_phase_deadline") }
        let childLayouts = [
            ("01-xctest", "xctest-list"),
            ("02-swift-testing", "swift-testing-list"),
        ]
        var groups = predecessorProcessGroups
        groups.insert(build.envelope.process.processGroupIdentifier)
        for (index, child) in envelope.children.enumerated() {
            let (prefix, streamPrefix) = childLayouts[index]
            let preNode = byName[prefix + "-prestart.json"]!
            let startNode = byName[prefix + "-start.json"]!
            let terminalNode = byName[prefix + "-terminal.json"]!
            let pre = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2InventoryPrestartV1.self,
                from: preNode.data!)
            let start = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2InventoryStartV1.self,
                from: startNode.data!)
            let terminal = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2InventoryTerminalV1.self,
                from: terminalNode.data!)
            let p = child.process
            let executable = build.envelope.process
            guard pre.schema == "prime_driver_v2_gate_g_inventory_prestart_v1",
                  pre.runID == intent.runID, pre.ordinal == index + 1, pre.role == child.role,
                  pre.predecessorSHA256 == predecessorSHA256,
                  pre.deadlineStartedAtUptimeNanoseconds == p.deadlineStartedAtUptimeNanoseconds,
                  pre.deadlineExpiresAtUptimeNanoseconds == p.deadlineExpiresAtUptimeNanoseconds,
                  pre.executableAbsolutePath == p.executableAbsolutePath,
                  pre.executableSHA256 == p.executableSHA256,
                  pre.logicalArgumentZero == p.logicalArgumentZero,
                  pre.physicalArgumentZero == p.physicalArgumentZero,
                  pre.arguments == p.arguments, pre.orderedEnvironment == p.orderedEnvironment,
                  pre.workingDirectoryAbsolutePath == p.workingDirectoryAbsolutePath,
                  start.schema == "prime_driver_v2_gate_g_inventory_start_v1",
                  start.role == child.role,
                  start.prestartSHA256 == PrimeSHA256.hexDigest(of: preNode.data!),
                  start.processIdentifier == p.processIdentifier,
                  start.sessionIdentifier == p.sessionIdentifier,
                  start.processGroupIdentifier == p.processGroupIdentifier,
                  start.appliedSpawnFlags == p.appliedSpawnFlags,
                  start.spawnReturnedUptimeNanoseconds == p.spawnReturnedUptimeNanoseconds,
                  start.mappedExecutablePathTelemetry == p.executableAbsolutePath,
                  start.exactSuspendedWorkingDirectoryJoin == p.exactSuspendedWorkingDirectoryJoin,
                  terminal.schema == "prime_driver_v2_gate_g_inventory_child_terminal_v1",
                  terminal.role == child.role,
                  terminal.startSHA256 == PrimeSHA256.hexDigest(of: startNode.data!),
                  terminal.process == p,
                  child.prestartBinding == Self.binding(preNode),
                  child.startBinding == Self.binding(startNode),
                  child.terminalBinding == Self.binding(terminalNode),
                  p.executableAbsolutePath == executable.executableAbsolutePath,
                  p.executableSHA256 == executable.executableSHA256,
                  p.executableByteCount == executable.executableByteCount,
                  p.executableDeviceID == executable.executableDeviceID,
                  p.executableInode == executable.executableInode,
                  p.sessionIdentifier == supervisorPID,
                  p.parentProcessIdentifier == supervisorPID,
                  p.deadlineStartedAtUptimeNanoseconds == first.deadlineStartedAtUptimeNanoseconds,
                  p.deadlineExpiresAtUptimeNanoseconds == first.deadlineExpiresAtUptimeNanoseconds,
                  p.spawnReturnedUptimeNanoseconds >= previousWait,
                  p.waitReturnedUptimeNanoseconds <= supervisorWaitUptime,
                  groups.insert(p.processGroupIdentifier).inserted
            else { throw Self.rejected("child_journal_process_join_\(index + 1)") }
            for (suffix, stream, declared) in [
                ("stdout.log", p.standardOutput, child.standardOutputBinding),
                ("stderr.log", p.standardError, child.standardErrorBinding),
            ] {
                let file = byName[streamPrefix + "." + suffix]!
                guard declared == Self.binding(file),
                      file.metadata.deviceID == stream.outputDeviceID,
                      file.metadata.inode == stream.outputInode,
                      file.metadata.byteCount == stream.outputByteCount,
                      file.metadata.permissionMode == stream.outputPermissionMode,
                      PrimeSHA256.hexDigest(of: file.data!) == stream.outputSHA256
                else { throw Self.rejected("stream_join_" + file.leaf) }
            }
            predecessorSHA256 = child.terminalBinding.sha256
            previousWait = p.waitReturnedUptimeNanoseconds
        }
        self.envelope = envelope
        self.bindingSHA256 = PrimeSHA256.hexDigest(of: bindingData)
        self.receiptIdentitySHA256 = try envelope.receipt.identitySHA256(
            intent: intent, buildReceipt: build.envelope.receipt)
        self.leaves = files.map { .init(leaf: $0.leaf, byteCount: $0.metadata.byteCount,
            sha256: PrimeSHA256.hexDigest(of: $0.data!)) }
        self.vnodes = files.map { .init($0.metadata) }
        self.directories = [run, inventory]; self.files = files
        try revalidate()
    }

    func revalidate() throws {
        try build.revalidate()
        try evidence.revalidate(coordinate: "inventory_evidence_after")
        for directory in directories { try directory.revalidate() }
        for file in files { try file.revalidate() }
        try build.revalidate()
        for directory in directories { try directory.revalidate() }
    }

    private static func binding(_ node: Node) -> PrimeArtifactBinding {
        .init(relativePath: node.leaf, sha256: PrimeSHA256.hexDigest(of: node.data!),
              byteCount: node.metadata.byteCount, purpose: .immutableData)
    }

    private static func rejected(_ coordinate: String) -> PrimeValidationDriverV2ShotGovernorFailure {
        governorRejected(PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                         "inventory_readback_" + coordinate)
    }
}

/// Independent post-reap H observation. Every file is read relative to held
/// roots; the original raw parsers run again, without reconstructing an owner.
private final class PrimeValidationDriverV2GovernorExecutionSnapshot {
    private typealias Node = PrimeValidationDriverV2GovernorBuildSnapshot.Node
    private final class Tree {
        let root: Node
        let directories: [String: Node]
        let files: [String: Node]
        init(parent: Int32, leaf: String, paths: Set<String>, owner: PrimeValidationDriverV2GovernorMetadata,
            deadline: PrimeValidationDriverV2GovernorDeadline) throws {
            var directoryPaths = Set<String>()
            for path in paths {
                let parts = path.split(separator: "/")
                for count in 1..<parts.count { directoryPaths.insert(parts.prefix(count).joined(separator: "/")) }
            }
            let all = paths.union(directoryPaths)
            func children(_ parent: String) -> [String] {
                all.filter { ($0 as NSString).deletingLastPathComponent == parent }
                    .map { ($0 as NSString).lastPathComponent }.sorted()
            }
            let root = try Node(parent: parent, leaf: leaf, directory: true, owner: owner,
                entries: children(""), deadline: deadline)
            var directories: [String: Node] = [:]
            for path in directoryPaths.sorted(by: { ($0.split(separator: "/").count, $0) < ($1.split(separator: "/").count, $1) }) {
                let parentPath = (path as NSString).deletingLastPathComponent
                directories[path] = try Node(parent: parentPath.isEmpty ? root.descriptor : directories[parentPath]!.descriptor,
                    leaf: (path as NSString).lastPathComponent, directory: true, owner: owner,
                    entries: children(path), deadline: deadline)
            }
            var files: [String: Node] = [:]
            for path in paths.sorted() {
                let parentPath = (path as NSString).deletingLastPathComponent
                files[path] = try Node(parent: parentPath.isEmpty ? root.descriptor : directories[parentPath]!.descriptor,
                    leaf: (path as NSString).lastPathComponent, directory: false, owner: owner,
                    maximumBytes: 16 * 1024 * 1024, deadline: deadline)
            }
            self.root = root; self.directories = directories; self.files = files
        }
        func revalidate() throws {
            try root.revalidate()
            for node in directories.values { try node.revalidate() }
            for node in files.values { try node.revalidate() }
        }
        func bytes(_ path: String) throws -> Data {
            guard let data = files[path]?.data else { throw PrimeValidationDriverV2GovernorExecutionSnapshot.rejected("missing_" + path) }; return data
        }
        func binding(_ path: String, scoped: Bool = false) throws -> PrimeArtifactBinding {
            let data = try bytes(path)
            return .init(relativePath: (scoped ? "execution/" : "") + path,
                sha256: PrimeSHA256.hexDigest(of: data), byteCount: UInt64(data.count), purpose: .immutableData)
        }
    }
    private let evidence: PrimeValidationDriverV2GovernorHeldDirectory
    private let build: PrimeValidationDriverV2GovernorBuildSnapshot
    private let inventory: PrimeValidationDriverV2GovernorInventorySnapshot
    private let run: Node
    private let execution: Tree
    private let outputs: Tree
    private let namespace: PrimeValidationDriverV2PublicationNamespaceReadback
    let envelope: PrimeValidationDriverV2OuterPublicationEnvelopeV1
    let envelopeSHA256: String
    let manifestSHA256: String
    let recordedGroups: Set<Int32>
    let immutablePrefixBindings: [PrimeArtifactBinding]
    let observedStartBindings: [PrimeArtifactBinding]
    let observedTerminalBindings: [PrimeArtifactBinding]
    let leaves: [PrimeValidationDriverV2GovernorInnerLeaf]
    let vnodes: [PrimeValidationDriverV2GovernorVnodeRecord]

    init(evidence: PrimeValidationDriverV2GovernorHeldDirectory,
        workspace: PrimeValidationDriverV2GovernorHeldDirectory,
        build: PrimeValidationDriverV2GovernorBuildSnapshot,
        inventory: PrimeValidationDriverV2GovernorInventorySnapshot,
        predecessor: PrimeValidationDriverV2GovernorInnerSnapshot,
        capsule: PrimeValidationDriverV2ShotCapsuleV1, capsuleSHA256: String,
        swiftPackageImage: PrimeValidationDriverV2GovernorHeldExecutable,
        supervisorPID: Int32, supervisorWaitUptime: UInt64,
        deadline: PrimeValidationDriverV2GovernorDeadline) throws {
        guard capsule.terminalGate == .gateH, let declaredScope = capsule.executionGoScopeData else { throw Self.rejected("scope") }
        try build.revalidate(); try inventory.revalidate(); try predecessor.revalidate()
        let plan = try PrimeValidationExecutionPlanV2.make(intent: capsule.intent,
            buildReceipt: build.envelope.receipt, inventoryReceipt: inventory.envelope.receipt)
        let run = try Node(parent: evidence.descriptor, leaf: capsule.intent.runID, directory: true,
            owner: evidence.identity, entries: ["artifacts", "build", "execution", "inventory"], deadline: deadline)
        var paths = Set(["plan.json", "go.json", "phase-04-start.json", "phase-04-terminal.json",
            "predecessor-e-start.json", "predecessor-e-terminal.json", "predecessor-e-readback.json",
            "phase-history.json", "evidence-manifest.json", "final-receipt.json", "publication-envelope.json"])
        for ordinal in 1...8 { paths.insert(String(format: "phase-ledger-%02d.json", ordinal)) }
        for ordinal in 7...8 { for suffix in ["start", "result", "terminal"] { paths.insert(String(format: "phase-%02d-%@.json", ordinal, suffix)) } }
        var outputPaths = Set<String>()
        for shard in plan.shards {
            let root = PrimeValidationDriverV2NativeExecutionValidation.shardRoot(shard)
            for name in ["prestart.json", "start.json", "terminal.json", "stdout.log", "stderr.log", "binding.json"] { paths.insert(root + "/" + name) }
            if shard.key.lane != .sequentialXCTest { paths.insert(root + "/result.xml"); outputPaths.insert(root + "/result.xml") }
        }
        let execution = try Tree(parent: run.descriptor, leaf: "execution", paths: paths,
            owner: evidence.identity, deadline: deadline)
        let outputs = try Tree(parent: workspace.descriptor, leaf: "output", paths: outputPaths,
            owner: workspace.identity, deadline: deadline)
        let planning = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2ExecutionPlanObservation.self,
            from: execution.bytes("go.json"))
        guard planning.declaredExecutionGoScopeData == declaredScope,
              try execution.bytes("plan.json") == PrimeCanonicalJSON.encode(plan) else { throw Self.rejected("plan_bytes") }
        try PrimeValidationDriverV2NativeExecutionValidation.validatePlan(planning,
            intent: capsule.intent, build: build.envelope, inventory: inventory.envelope, plan: plan)
        guard try execution.binding("phase-04-start.json") == planning.planningStartBinding else {
            throw Self.rejected("planning_start_actual_binding")
        }
        try Self.validateEIdentity(predecessor, capsule: capsule)
        guard try execution.bytes("predecessor-e-start.json") == predecessor.durableFrames[0].framedBytes,
              try execution.bytes("predecessor-e-terminal.json") == predecessor.durableFrames[33].framedBytes else {
            throw Self.rejected("E_copied_frames")
        }
        let parser = try PrimeValidationDriverV2ExecutionBinding(intent: capsule.intent,
            build: build.envelope.receipt, inventory: inventory.envelope.receipt, plan: plan)
        var parsed: [PrimeValidationDriverV2ParsedShardEvidence] = []
        var rawShards: [PrimeValidationDriverV2ShardRawObservation] = []
        var acceptanceBindings: [PrimeArtifactBinding] = []
        var predecessorHash = PrimeSHA256.hexDigest(of: try execution.bytes("go.json"))
        var groups = Set<Int32>()
        for (index, shard) in plan.shards.enumerated() {
            try deadline.requireTime("H_parser_readback")
            let root = PrimeValidationDriverV2NativeExecutionValidation.shardRoot(shard)
            let terminal = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2InventoryTerminalV1.self,
                from: execution.bytes(root + "/terminal.json"))
            var fields: [String: Any] = ["shard": try Self.object(planning.schedule.shards[index]),
                "executionPlanSHA256": parser.planSHA256, "process": try Self.object(terminal.process),
                "prestartBinding": try Self.object(execution.binding(root + "/prestart.json")),
                "startBinding": try Self.object(execution.binding(root + "/start.json")),
                "terminalBinding": try Self.object(execution.binding(root + "/terminal.json")),
                "standardOutputBinding": try Self.object(execution.binding(root + "/stdout.log")),
                "standardErrorBinding": try Self.object(execution.binding(root + "/stderr.log")),
                "standardOutputData": try execution.bytes(root + "/stdout.log").base64EncodedString(),
                "standardErrorData": try execution.bytes(root + "/stderr.log").base64EncodedString()]
            if shard.key.lane != .sequentialXCTest {
                fields["resultBinding"] = try Self.object(execution.binding(root + "/result.xml"))
                fields["resultData"] = try execution.bytes(root + "/result.xml").base64EncodedString()
                guard try outputs.bytes(root + "/result.xml") == execution.bytes(root + "/result.xml"),
                      (outputs.files[root + "/result.xml"]!.metadata.deviceID != execution.files[root + "/result.xml"]!.metadata.deviceID
                        || outputs.files[root + "/result.xml"]!.metadata.inode != execution.files[root + "/result.xml"]!.metadata.inode)
                else { throw Self.rejected("original_result_copy") }
            }
            let raw = try JSONDecoder().decode(PrimeValidationDriverV2ShardRawObservation.self,
                from: JSONSerialization.data(withJSONObject: fields))
            let child = try PrimeValidationDriverV2NativeExecutionValidation.validateShard(raw, index: index,
                intent: capsule.intent, build: build.envelope, plan: plan, planning: planning,
                previous: rawShards.last, predecessorSHA256: predecessorHash)
            guard raw.process.waitReturnedUptimeNanoseconds <= supervisorWaitUptime else { throw Self.rejected("wait_before_supervisor") }
            groups.insert(raw.process.processGroupIdentifier)
            for (leaf, stream) in [("stdout.log", raw.process.standardOutput), ("stderr.log", raw.process.standardError)] {
                let actual = execution.files[root + "/" + leaf]!.metadata
                guard actual.deviceID == stream.outputDeviceID, actual.inode == stream.outputInode else { throw Self.rejected("stream_vnode") }
            }
            let stdout = try PrimeValidationDriverV2NativeExecutionValidation.bound(raw.standardOutputBinding,
                name: "standard_output", path: root + "/stdout.log", data: raw.standardOutputData)
            let stderr = try PrimeValidationDriverV2NativeExecutionValidation.bound(raw.standardErrorBinding,
                name: "standard_error", path: root + "/stderr.log", data: raw.standardErrorData)
            let result = try PrimeValidationDriverV2NativeExecutionValidation.bound(
                raw.resultBinding ?? raw.standardOutputBinding, name: "result",
                path: shard.key.lane == .sequentialXCTest ? root + "/stdout.log" : root + "/result.xml",
                data: raw.resultData ?? raw.standardOutputData)
            let accepted = try parser.admit(start: .init(runID: plan.runID, executionPlanSHA256: parser.planSHA256,
                shard: shard), observedChild: child, result: result, standardOutput: stdout, standardError: stderr)
            parsed.append(accepted)
            let transition = try parser.transition(after: parsed)
            guard transition != .stoppedAtFailedTerminal else { throw Self.rejected("failed_prefix") }
            let expected = try PrimeValidationDriverV2NativeExecutionValidation.acceptance(raw, transition: transition,
                nextOriginalShardID: index + 1 < plan.shards.count ? plan.shards[index + 1].shardID : "")
            guard try execution.bytes(root + "/binding.json") == expected else { throw Self.rejected("parsed_acceptance") }
            acceptanceBindings.append(try execution.binding(root + "/binding.json"))
            rawShards.append(raw); predecessorHash = PrimeSHA256.hexDigest(of: expected)
        }
        let conclusion = try parser.conclude(parsed)
        let history = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2PublicationPhaseHistoryV1.self,
            from: execution.bytes("phase-history.json"))
        try history.validate(intent: capsule.intent, requireComplete: true)
        try Self.validateHistory(history, execution: execution, raw: rawShards,
            planning: planning, build: build, inventory: inventory, predecessor: predecessor,
            conclusion: conclusion, supervisorWaitUptime: supervisorWaitUptime)
        let innerData = try execution.bytes("final-receipt.json")
        guard innerData == (try PrimeCanonicalJSON.encode(conclusion.finalReceipt)) else { throw Self.rejected("raw_final_receipt") }
        let manifestData = try execution.bytes("evidence-manifest.json")
        let envelopeData = try execution.bytes("publication-envelope.json")
        let manifest = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2EvidenceManifestV1.self, from: manifestData)
        let envelope = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2OuterPublicationEnvelopeV1.self, from: envelopeData)
        let source = PrimeValidationDriverV2PublicationSourceV1(sourceCommit: capsule.sourceCommit,
            sourceTree: capsule.sourceTree,
            sourceTreeReplaySHA256: try PrimeCanonicalJSON.decode(PrimeValidationDriverV2DeclaredExecutionScopeV1.self,
                from: declaredScope).sourceTreeReplaySHA256,
            sourceIdentitySHA256: capsule.sourceIdentitySHA256,
            sourceSnapshotSHA256: capsule.intent.sourceSnapshot.sha256,
            governorExecutable: capsule.governorExecutable, supervisorExecutable: capsule.supervisorExecutable,
            swiftPackageExecutable: swiftPackageImage.binding)
        try source.validateDeclaredScope(declaredScope, intent: capsule.intent)
        let excluded: Set<String> = ["phase-history.json", "evidence-manifest.json", "final-receipt.json", "publication-envelope.json"]
        let originalBindings = try execution.files.keys.filter { !excluded.contains($0) }.sorted().map { try execution.binding($0) }
        let identity = PrimeValidationDriverV2PublicationAdmissionIdentityV1(
            intentSHA256: try capsule.intent.identitySHA256(), sourceSnapshotSHA256: capsule.intent.sourceSnapshot.sha256,
            declaredExecutionGoScopeSHA256: PrimeSHA256.hexDigest(of: declaredScope),
            packageResolvedBinding: planning.packageResolvedBinding, inventoryBinding: planning.predecessorInventoryBinding,
            planBinding: try execution.binding("plan.json"), goBinding: try execution.binding("go.json"),
            shardIdentifiers: plan.shards.map(\.shardID), terminalBindings: rawShards.map(\.terminalBinding),
            acceptanceBindings: acceptanceBindings, artifactBindings: originalBindings,
            phaseHistorySHA256: PrimeSHA256.hexDigest(of: try execution.bytes("phase-history.json")),
            phasePrefixBindings: history.immutablePrefixBindings,
            publicationStartedAt: envelope.publicationStartedAtUptimeNanoseconds)
        try envelope.validate(intent: capsule.intent, build: build.envelope.receipt,
            inventory: inventory.envelope.receipt, plan: plan, conclusion: conclusion,
            history: history, manifest: manifest,
            expectedLiveAdmissionIdentitySHA256: PrimeSHA256.hexDigest(of: PrimeCanonicalJSON.encode(identity)),
            expectedAcceptedCapsuleSHA256: capsuleSHA256, expectedSource: source)
        guard envelope.publicationDeadlineUptimeNanoseconds < deadline.expiresAt,
              envelope.publicationStartedAtUptimeNanoseconds <= supervisorWaitUptime,
              supervisorWaitUptime < envelope.publicationDeadlineUptimeNanoseconds else { throw Self.rejected("publication_wait_budget") }
        let namespace = try PrimeValidationDriverV2PublicationNamespaceReadback.capture(
            evidenceRootDescriptor: evidence.descriptor, runID: capsule.intent.runID,
            manifestData: manifestData, outerEnvelopeData: envelopeData, deadlineNanoseconds: deadline.expiresAt)
        guard Set(namespace.entries.map(\.relativePath)) == manifest.finalNamespacePaths else { throw Self.rejected("exact_manifest_namespace") }
        self.evidence = evidence; self.build = build; self.inventory = inventory; self.run = run
        self.execution = execution; self.outputs = outputs; self.namespace = namespace
        self.envelope = envelope; envelopeSHA256 = PrimeSHA256.hexDigest(of: envelopeData)
        manifestSHA256 = PrimeSHA256.hexDigest(of: manifestData); recordedGroups = groups
        immutablePrefixBindings = history.immutablePrefixBindings
        observedStartBindings = try rawShards.map { try execution.binding($0.startBinding.relativePath, scoped: true) }
        observedTerminalBindings = try rawShards.map { try execution.binding($0.terminalBinding.relativePath, scoped: true) }
        let ordered = execution.files.keys.sorted()
        leaves = ordered.map { .init(leaf: "execution/" + $0, byteCount: execution.files[$0]!.metadata.byteCount,
            sha256: PrimeSHA256.hexDigest(of: execution.files[$0]!.data!)) }
        vnodes = ordered.map { .init(execution.files[$0]!.metadata) }
        try revalidate()
    }

    func revalidate() throws {
        try build.revalidate(); try inventory.revalidate(); try evidence.revalidate(coordinate: "H_evidence")
        try run.revalidate(); try execution.revalidate(); try outputs.revalidate(); try namespace.revalidate()
    }

    private static func validateHistory(_ history: PrimeValidationDriverV2PublicationPhaseHistoryV1,
        execution: Tree, raw: [PrimeValidationDriverV2ShardRawObservation],
        planning: PrimeValidationDriverV2ExecutionPlanObservation,
        build: PrimeValidationDriverV2GovernorBuildSnapshot,
        inventory: PrimeValidationDriverV2GovernorInventorySnapshot,
        predecessor: PrimeValidationDriverV2GovernorInnerSnapshot,
        conclusion: PrimeValidationDriverV2ParsedExecutionConclusion,
        supervisorWaitUptime: UInt64) throws {
        struct PlanTerminal: Codable {
            let schema: String; let phase: String; let startSHA256: String
            let completedAtUptimeNanoseconds: UInt64; let planSHA256: String; let goSHA256: String; let disposition: String
        }
        struct Start: Codable {
            let schema: String; let phase: String; let runID: String
            let startedAtUptimeNanoseconds: UInt64; let expiresAtUptimeNanoseconds: UInt64; let predecessorPrefixSHA256: String
        }
        struct Terminal: Codable {
            let schema: String; let phase: String; let startSHA256: String; let resultSHA256: String
            let completedAtUptimeNanoseconds: UInt64; let disposition: String
        }
        struct Reconciliation: Codable { let reference: PrimeValidationArmAggregateV2; let candidate: PrimeValidationArmAggregateV2 }
        struct Comparison: Codable { let comparison: PrimeValidationPairedComparisonReceiptV2; let finalReceipt: PrimeValidationDriverFinalReceiptV2 }
        func binding(_ path: String, _ leaves: [PrimeValidationDriverV2GovernorInnerLeaf]) throws -> PrimeArtifactBinding {
            let leaf = (path as NSString).lastPathComponent
            guard let value = leaves.first(where: { $0.leaf == leaf }) else { throw rejected("history_predecessor_leaf") }
            return .init(relativePath: path, sha256: value.sha256, byteCount: value.byteCount, purpose: .immutableData)
        }
        let firstFrame = predecessor.durableFrames[0], lastFrame = predecessor.durableFrames[33]
        let readback = try PrimeValidationDriverV2PublicationEProjectionV1.validate(
            readbackData: execution.bytes("predecessor-e-readback.json"),
            prestart: firstFrame, lastChildTerminal: predecessor.durableFrames[32], rawTerminal: lastFrame,
            buildStartedAtUptimeNanoseconds: build.envelope.process.deadlineStartedAtUptimeNanoseconds,
            planningStartedAtUptimeNanoseconds: planning.planningStartedAtUptimeNanoseconds,
            planningExpiresAtUptimeNanoseconds: planning.planningExpiresAtUptimeNanoseconds,
            prefixRecordedAtUptimeNanoseconds: history.prefixes[0].recordedAtUptimeNanoseconds,
            supervisorWaitUptimeNanoseconds: supervisorWaitUptime)
        let eStart = readback.observedDeadlineStartedAtUptimeNanoseconds
        let eEnd = readback.observedExecutorTerminalUptimeNanoseconds
        let entries = history.prefixes.last!.entries
        func join(_ ordinal: Int, start: PrimeArtifactBinding, terminal: PrimeArtifactBinding,
            outputs: [PrimeArtifactBinding], started: UInt64, ended: UInt64) throws {
            let entry = entries[ordinal]
            guard ended > started, entry.start == start, entry.terminal == terminal,
                  entry.acceptedOutputBindings == outputs.sorted(by: { $0.relativePath < $1.relativePath }),
                  entry.activeNanoseconds == ended - started,
                  ended <= history.prefixes[ordinal].recordedAtUptimeNanoseconds,
                  history.prefixes[ordinal].recordedAtUptimeNanoseconds <= supervisorWaitUptime else { throw rejected("history_interval_\(ordinal)") }
        }
        try join(0, start: execution.binding("predecessor-e-start.json", scoped: true),
            terminal: execution.binding("predecessor-e-terminal.json", scoped: true),
            outputs: [execution.binding("predecessor-e-readback.json", scoped: true)], started: eStart, ended: eEnd)
        try join(1, start: binding("build/start.json", build.leaves), terminal: binding("build/terminal.json", build.leaves),
            outputs: [binding("build/binding.json", build.leaves)],
            started: build.envelope.process.deadlineStartedAtUptimeNanoseconds,
            ended: build.envelope.process.waitReturnedUptimeNanoseconds)
        try join(2, start: binding("inventory/01-xctest-start.json", inventory.leaves),
            terminal: binding("inventory/terminal.json", inventory.leaves),
            outputs: [binding("inventory/binding.json", inventory.leaves)],
            started: inventory.envelope.children[0].process.deadlineStartedAtUptimeNanoseconds,
            ended: inventory.envelope.children[1].process.waitReturnedUptimeNanoseconds)
        let planTerminal = try PrimeCanonicalJSON.decode(PlanTerminal.self, from: execution.bytes("phase-04-terminal.json"))
        guard planTerminal.schema == "prime_driver_v2_gate_h_phase_terminal_v1", planTerminal.phase == "execution_plan",
              planTerminal.startSHA256 == (try execution.binding("phase-04-start.json").sha256),
              planTerminal.planSHA256 == (try execution.binding("plan.json").sha256),
              planTerminal.goSHA256 == (try execution.binding("go.json").sha256), planTerminal.disposition == "succeeded",
              planTerminal.completedAtUptimeNanoseconds < planning.planningExpiresAtUptimeNanoseconds,
              planTerminal.completedAtUptimeNanoseconds <= raw[0].process.deadlineStartedAtUptimeNanoseconds else { throw rejected("history_plan") }
        try join(3, start: execution.binding("phase-04-start.json", scoped: true),
            terminal: execution.binding("phase-04-terminal.json", scoped: true),
            outputs: [execution.binding("go.json", scoped: true), execution.binding("plan.json", scoped: true)],
            started: planning.planningStartedAtUptimeNanoseconds, ended: planTerminal.completedAtUptimeNanoseconds)
        for (ordinal, arm) in [(4, "reference"), (5, "candidate")] {
            let values = raw.filter { $0.shard.arm == arm }
            guard let first = values.first, let last = values.last else { throw rejected("history_arm_empty") }
            let started = first.process.deadlineStartedAtUptimeNanoseconds
            let ended = started.addingReportingOverflow(entries[ordinal].activeNanoseconds)
            guard !ended.overflow, ended.partialValue >= last.process.waitReturnedUptimeNanoseconds,
                  ended.partialValue < first.process.deadlineExpiresAtUptimeNanoseconds else { throw rejected("history_arm_time") }
            func scoped(_ value: PrimeArtifactBinding) -> PrimeArtifactBinding {
                .init(relativePath: "execution/" + value.relativePath, sha256: value.sha256,
                    byteCount: value.byteCount, purpose: value.purpose)
            }
            let outputs = try values.map { value in
                try execution.binding(String(value.terminalBinding.relativePath.dropLast("terminal.json".count)) + "binding.json", scoped: true)
            }
            try join(ordinal, start: scoped(first.prestartBinding), terminal: scoped(last.terminalBinding),
                outputs: outputs, started: started, ended: ended.partialValue)
            if ordinal == 4 {
                guard let candidate = raw.first(where: { $0.shard.arm == "candidate" }),
                      candidate.process.deadlineStartedAtUptimeNanoseconds >= ended.partialValue else { throw rejected("history_arm_transfer") }
            }
        }
        let reconciliation = Reconciliation(reference: conclusion.reference, candidate: conclusion.candidate)
        let comparison = Comparison(comparison: conclusion.comparison, finalReceipt: conclusion.finalReceipt)
        guard try execution.bytes("phase-07-result.json") == PrimeCanonicalJSON.encode(reconciliation),
              try execution.bytes("phase-08-result.json") == PrimeCanonicalJSON.encode(comparison) else { throw rejected("history_semantic_results") }
        for (ordinal, phase, duration) in [(6, "reconciliation", UInt64(120_000_000_000)), (7, "comparison", UInt64(60_000_000_000))] {
            let prefix = String(format: "phase-%02d", ordinal + 1)
            let start = try PrimeCanonicalJSON.decode(Start.self, from: execution.bytes(prefix + "-start.json"))
            let terminal = try PrimeCanonicalJSON.decode(Terminal.self, from: execution.bytes(prefix + "-terminal.json"))
            guard start.schema == "prime_driver_v2_gate_h_phase_start_v1", start.phase == phase,
                  start.runID == history.runID, start.predecessorPrefixSHA256 == history.immutablePrefixBindings[ordinal - 1].sha256,
                  start.startedAtUptimeNanoseconds >= history.prefixes[ordinal - 1].recordedAtUptimeNanoseconds,
                  start.expiresAtUptimeNanoseconds > start.startedAtUptimeNanoseconds,
                  start.expiresAtUptimeNanoseconds - start.startedAtUptimeNanoseconds == duration,
                  terminal.schema == "prime_driver_v2_gate_h_phase_terminal_v1", terminal.phase == phase,
                  terminal.startSHA256 == (try execution.binding(prefix + "-start.json").sha256),
                  terminal.resultSHA256 == (try execution.binding(prefix + "-result.json").sha256),
                  terminal.disposition == "succeeded", terminal.completedAtUptimeNanoseconds < start.expiresAtUptimeNanoseconds else { throw rejected("history_final_phase") }
            try join(ordinal, start: execution.binding(prefix + "-start.json", scoped: true),
                terminal: execution.binding(prefix + "-terminal.json", scoped: true),
                outputs: [execution.binding(prefix + "-result.json", scoped: true)],
                started: start.startedAtUptimeNanoseconds, ended: terminal.completedAtUptimeNanoseconds)
        }
        for (index, prefix) in history.prefixes.enumerated() {
            guard try execution.binding(String(format: "phase-ledger-%02d.json", index + 1), scoped: true) == history.immutablePrefixBindings[index],
                  try execution.bytes(String(format: "phase-ledger-%02d.json", index + 1)) == PrimeCanonicalJSON.encode(prefix) else { throw rejected("history_prefix_bytes") }
        }
    }

    private static func validateEIdentity(_ snapshot: PrimeValidationDriverV2GovernorInnerSnapshot,
        capsule: PrimeValidationDriverV2ShotCapsuleV1) throws {
        struct Output: Decodable { let role: String; let standardOutputByteCount: UInt64; let standardOutputSHA256: String }
        let expected = ["prime_head_pre": capsule.sourceCommit, "prime_head_post": capsule.sourceCommit,
            "companion_head_pre": capsule.companionCommit, "companion_head_post": capsule.companionCommit]
        guard let scopeData = capsule.executionGoScopeData else { throw rejected("missing_scope") }
        let scope = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2DeclaredExecutionScopeV1.self, from: scopeData)
        var seen = Set<String>()
        var treeCounts: [UInt64] = []
        for index in stride(from: 2, through: 32, by: 2) {
            let value = try JSONDecoder().decode(Output.self, from: snapshot.durableFrames[index].framedBytes)
            if let object = expected[value.role] {
                guard seen.insert(value.role).inserted, value.standardOutputByteCount == 41,
                      value.standardOutputSHA256 == PrimeSHA256.hexDigest(of: Data((object + "\n").utf8)) else { throw rejected("E_git_tree_join") }
            }
            if ["prime_tree_discovery", "prime_tree_replay"].contains(value.role) {
                guard value.standardOutputByteCount > 0,
                      value.standardOutputSHA256 == scope.sourceTreeReplaySHA256 else { throw rejected("E_tree_replay_hash") }
                treeCounts.append(value.standardOutputByteCount)
            }
        }
        guard seen == Set(expected.keys), treeCounts.count == 2, treeCounts[0] == treeCounts[1] else { throw rejected("E_git_roles") }
    }
    private static func object<T: Encodable>(_ value: T) throws -> [String: Any] {
        guard let fields = try JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(value)) as? [String: Any] else { throw rejected("object") }; return fields
    }
    private static func rejected(_ reason: String) -> PrimeValidationDriverV2ShotGovernorFailure {
        governorRejected(PrimeValidationDriverV2ShotGovernorStatus.postReapRejection, "H_readback_" + reason)
    }
}

private struct PrimeValidationDriverV2GovernorStartRecordV1: Encodable {
    var schema = "prime_driver_v2_gate_e_outer_start_v1"
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
    var swiftPackageImageVnode: PrimeValidationDriverV2GovernorVnodeRecord? = nil
    var swiftPackageExecutable: PrimeValidationExecutableBindingV2? = nil
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
        case swiftPackageImageVnode = "swift_package_image_vnode"
        case swiftPackageExecutable = "swift_package_executable"
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

private struct PrimeValidationDriverV2GovernorBuildSuccessOutcome: Encodable {
    // A build observation does not promote the separately controlled authority
    // vector or grant the inventory transition.
    let authorityVector = "11110000"
    let completedGate = "F"
    let inventoryExecutionCount = 0
    let gateGAuthorized = false
    let predecessorJournal: [PrimeValidationDriverV2GovernorInnerLeaf]
    let predecessorJournalVnodes: [PrimeValidationDriverV2GovernorVnodeRecord]
    let predecessorDurableReceiptIdentitySHA256: String
    let predecessorRawTerminalSHA256: String
    let buildJournal: [PrimeValidationDriverV2GovernorInnerLeaf]
    let buildJournalVnodes: [PrimeValidationDriverV2GovernorVnodeRecord]
    let buildBindingSHA256: String
    let buildProcessIdentifier: Int32
    let buildProcessGroupIdentifier: Int32

    private enum CodingKeys: String, CodingKey {
        case authorityVector = "authority_vector"
        case completedGate = "completed_gate"
        case inventoryExecutionCount = "inventory_execution_count"
        case gateGAuthorized = "gate_g_authorized"
        case predecessorJournal = "predecessor_journal"
        case predecessorJournalVnodes = "predecessor_journal_vnodes"
        case predecessorDurableReceiptIdentitySHA256 = "predecessor_durable_receipt_identity_sha256"
        case predecessorRawTerminalSHA256 = "predecessor_raw_terminal_sha256"
        case buildJournal = "build_journal"
        case buildJournalVnodes = "build_journal_vnodes"
        case buildBindingSHA256 = "build_binding_sha256"
        case buildProcessIdentifier = "build_process_identifier"
        case buildProcessGroupIdentifier = "build_process_group_identifier"
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

private struct PrimeValidationDriverV2GovernorInventorySuccessOutcome: Encodable {
    // Native inventory admission does not promote the separately controlled
    // authority vector or authorize any H child/publication route.
    let authorityVector = "11110000"
    let completedGate = "G"
    let inventoryExecutionCount = 2
    let gateHAuthorized = false
    let predecessorJournal: [PrimeValidationDriverV2GovernorInnerLeaf]
    let predecessorJournalVnodes: [PrimeValidationDriverV2GovernorVnodeRecord]
    let predecessorDurableReceiptIdentitySHA256: String
    let predecessorRawTerminalSHA256: String
    let buildJournal: [PrimeValidationDriverV2GovernorInnerLeaf]
    let buildJournalVnodes: [PrimeValidationDriverV2GovernorVnodeRecord]
    let buildBindingSHA256: String
    let buildProcessIdentifier: Int32
    let buildProcessGroupIdentifier: Int32
    let inventoryJournal: [PrimeValidationDriverV2GovernorInnerLeaf]
    let inventoryJournalVnodes: [PrimeValidationDriverV2GovernorVnodeRecord]
    let inventoryBindingSHA256: String
    let inventoryReceiptIdentitySHA256: String
    let inventoryProcessIdentifiers: [Int32]
    let inventoryProcessGroupIdentifiers: [Int32]

    private enum CodingKeys: String, CodingKey {
        case authorityVector = "authority_vector"
        case completedGate = "completed_gate"
        case inventoryExecutionCount = "inventory_execution_count"
        case gateHAuthorized = "gate_h_authorized"
        case predecessorJournal = "predecessor_journal"
        case predecessorJournalVnodes = "predecessor_journal_vnodes"
        case predecessorDurableReceiptIdentitySHA256 = "predecessor_durable_receipt_identity_sha256"
        case predecessorRawTerminalSHA256 = "predecessor_raw_terminal_sha256"
        case buildJournal = "build_journal"
        case buildJournalVnodes = "build_journal_vnodes"
        case buildBindingSHA256 = "build_binding_sha256"
        case buildProcessIdentifier = "build_process_identifier"
        case buildProcessGroupIdentifier = "build_process_group_identifier"
        case inventoryJournal = "inventory_journal"
        case inventoryJournalVnodes = "inventory_journal_vnodes"
        case inventoryBindingSHA256 = "inventory_binding_sha256"
        case inventoryReceiptIdentitySHA256 = "inventory_receipt_identity_sha256"
        case inventoryProcessIdentifiers = "inventory_process_identifiers"
        case inventoryProcessGroupIdentifiers = "inventory_process_group_identifiers"
    }
}

private struct PrimeValidationDriverV2GovernorExecutionSuccessOutcome: Encodable {
    let authorityVector = "11110000"
    let completedGate = "H"
    let publicationEnvelopeSHA256: String
    let evidenceManifestSHA256: String
    let executionPlanSHA256: String
    let inventoryBindingSHA256: String
    let innerFinalReceiptSHA256: String
    let disposition: String
    let executionJournal: [PrimeValidationDriverV2GovernorInnerLeaf]
    let executionJournalVnodes: [PrimeValidationDriverV2GovernorVnodeRecord]
    let recordedChildGroups: [Int32]
    private enum CodingKeys: String, CodingKey {
        case authorityVector = "authority_vector", completedGate = "completed_gate"
        case publicationEnvelopeSHA256 = "publication_envelope_sha256", evidenceManifestSHA256 = "evidence_manifest_sha256"
        case executionPlanSHA256 = "execution_plan_sha256", inventoryBindingSHA256 = "inventory_binding_sha256"
        case innerFinalReceiptSHA256 = "inner_final_receipt_sha256", disposition
        case executionJournal = "execution_journal", executionJournalVnodes = "execution_journal_vnodes"
        case recordedChildGroups = "recorded_child_groups"
    }
}

private enum PrimeValidationDriverV2GovernorTerminalOutcome: Encodable {
    case success(PrimeValidationDriverV2GovernorSuccessOutcome)
    case buildSuccess(PrimeValidationDriverV2GovernorBuildSuccessOutcome)
    case inventorySuccess(PrimeValidationDriverV2GovernorInventorySuccessOutcome)
    case executionSuccess(PrimeValidationDriverV2GovernorExecutionSuccessOutcome)
    case executionIncomplete(PrimeValidationDriverV2GovernorIncompleteObservationV1)
    case containedNonzero(PrimeValidationDriverV2GovernorNonzeroOutcome)
    case containedZeroSemanticRejection(
        PrimeValidationDriverV2GovernorZeroRejectionOutcome
    )

    private enum CodingKeys: String, CodingKey {
        case success
        case buildSuccess = "build_success"
        case inventorySuccess = "inventory_success"
        case executionSuccess = "execution_success"
        case executionIncomplete = "execution_incomplete"
        case containedNonzero = "contained_nonzero"
        case containedZeroSemanticRejection =
            "contained_zero_semantic_rejection"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .success(value):
            try container.encode(value, forKey: .success)
        case let .buildSuccess(value):
            try container.encode(value, forKey: .buildSuccess)
        case let .inventorySuccess(value):
            try container.encode(value, forKey: .inventorySuccess)
        case let .executionSuccess(value):
            try container.encode(value, forKey: .executionSuccess)
        case let .executionIncomplete(value):
            try container.encode(value, forKey: .executionIncomplete)
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
    var schema = "prime_driver_v2_gate_e_outer_terminal_v1"
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
    var swiftPackageImageRejoined: Bool? = nil
    let rootsRejoined: Bool
    let outerContinuityRevalidated: Bool
    var executionFailureCoordinate: String? = nil
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
        case swiftPackageImageRejoined = "swift_package_image_rejoined"
        case rootsRejoined = "roots_rejoined"
        case outerContinuityRevalidated =
            "outer_continuity_revalidated"
        case executionFailureCoordinate = "execution_failure_coordinate"
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
            do {
                return try admitCapsuleAndExecute()
            } catch let failure as PrimeValidationDriverV2ShotGovernorFailure {
                reportFailure(
                    status: failure.status,
                    coordinate: "run_closed:" + failure.coordinate
                )
                throw failure
            } catch {
                reportFailure(
                    status: PrimeValidationDriverV2ShotGovernorStatus
                        .containmentUncertain,
                    coordinate: "run_closed_generic:"
                        + String(reflecting: error)
                )
                throw error
            }
        }
    }

    fileprivate static func reportFailure(
        status: Int32,
        coordinate: String
    ) {
        guard status >= PrimeValidationDriverV2ShotGovernorStatus
                .capsuleTransport,
              status <= PrimeValidationDriverV2ShotGovernorStatus
                .terminalPublication
        else { return }
        var metadata = stat()
        let flags = fcntl(STDERR_FILENO, F_GETFL)
        guard flags >= 0, fstat(STDERR_FILENO, &metadata) == 0,
              flags & O_NONBLOCK != 0
                || metadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
        else { return }
        guard fcntl(STDERR_FILENO, F_SETNOSIGPIPE, 1) == 0 else { return }
        let coordinate = coordinate.utf8.prefix(256).map { byte in
            (byte >= 0x21 && byte <= 0x7e) ? byte : UInt8(0x5f)
        }
        let message = Array("gate_e_rejected status=\(status) coordinate=".utf8)
            + coordinate + [UInt8(0x0a)]
        // Diagnostic only: one bounded write with SIGPIPE suppressed, without
        // retry, authority promotion, or a change to the returned failure.
        _ = message.withUnsafeBytes {
            Darwin.write(STDERR_FILENO, $0.baseAddress, $0.count)
        }
    }

    private static func admitCapsuleAndExecute() throws -> Int32 {
        // Darwin places the startup envp after the argv terminator.
        // Foundation can replace the current environ during initialization;
        // inspect the launch vector without exempting any supplied key.
        guard primeDriverV2GovernorNSGetArgc().pointee == 1,
              let arguments = primeDriverV2GovernorNSGetArgv().pointee,
              arguments[0] != nil,
              arguments[1] == nil
        else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "capsule_argc"
            )
        }
        if arguments[2] != nil {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.capsuleTransport,
                "capsule_environment"
            )
        }
        let bytes = try readCanonicalCapsuleFromStandardInput()
        let capsule = try decodeCanonicalCapsule(exactBytes: bytes)
        return try execute(capsule: capsule, capsuleBytes: bytes)
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
            coordinate: "git_image",
            systemTool: true
        )
        let swiftImage = try PrimeValidationDriverV2GovernorHeldExecutable(
            binding: capsule.swiftExecutable,
            requiredLeaf: "swift-frontend",
            coordinate: "swift_frontend_image",
            systemTool: true
        )
        let swiftPackageImage: PrimeValidationDriverV2GovernorHeldExecutable?
        if capsule.runsBuildAndStaging {
            swiftPackageImage = try PrimeValidationDriverV2GovernorHeldExecutable
                .fixedSwiftPackage(beside: swiftImage)
        } else {
            swiftPackageImage = nil
        }

        let request = PrimeValidationDriverV2SupervisorLaunchRequestV1(
            intent: capsule.intent,
            leaseDirectoryAbsolutePath: capsule.leaseDirectoryAbsolutePath,
            terminalGate: capsule.terminalGate,
            executionGoScopeData: capsule.executionGoScopeData,
            acceptedCapsuleSHA256: capsule.terminalGate == .gateH ? PrimeSHA256.hexDigest(of: capsuleBytes) : nil
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
            filesystem: baseFilesystem,
            rootLeaf: capsule.outerJournalLeaf
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
        let deadline = try PrimeValidationDriverV2GovernorDeadline(
            durationNanoseconds: capsule.outerDurationNanoseconds
        )
        let pinnedBundleInput: PrimeValidationDriverV2PinnedBundleInputReadback?
        let lockedDependencies: PrimeValidationDriverV2LockedDependencyReadback?
        if capsule.runsBuildAndStaging {
            pinnedBundleInput = try PrimeValidationDriverV2PinnedBundleInputReadback.capture(
                primeRootDescriptor: primeRoot.descriptor, deadlineNanoseconds: deadline.expiresAt)
            lockedDependencies = try PrimeValidationDriverV2LockedDependencyReadback.capture(
                primeRootDescriptor: primeRoot.descriptor,
                primeRootAbsolutePath: capsule.intent.roots.repositoryRoot.absolutePath,
                deadlineNanoseconds: deadline.expiresAt)
        } else {
            pinnedBundleInput = nil
            lockedDependencies = nil
        }
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
                    try swiftPackageImage?.revalidate(coordinate: "swift_package_before_spawn")
                    try lockedDependencies?.checkpointMetadata()
                }
            )
        let containmentGuard = spawned.containmentGuard
        // The finite request file is independently held by leaf 1; the
        // descriptor sharing the child's offset closes in the parent now.
        _ = Darwin.close(requestInput)
        requestInput = -1

        let startLeaf = try journal.publishCanonical(
            PrimeValidationDriverV2GovernorStartRecordV1(
                schema: capsule.outerStartSchema,
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
                swiftPackageImageVnode: swiftPackageImage.map { .init($0.identity) },
                swiftPackageExecutable: swiftPackageImage?.binding,
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
        _ = try pinnedBundleInput?.revalidate()
        try lockedDependencies?.revalidate()
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
                    lifecycleState: spawned.lifecycleState,
                    deathWatcher: spawned.deathWatcher,
                    deadline: deadline,
                    onExactReap: containmentGuard.acceptExactReap
                )
        } else {
            processResult = try PrimeValidationDriverV2GovernorSessionCensus
                .contain(
                    lifecycleState: spawned.lifecycleState,
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
        var swiftPackageImageRejoined: Bool? = capsule.runsBuildAndStaging ? false : nil
        var rootsRejoined = false
        var outerContinuityRejoined = false
        var innerReceiptValidated = false
        var buildSnapshot: PrimeValidationDriverV2GovernorBuildSnapshot?
        var inventorySnapshot: PrimeValidationDriverV2GovernorInventorySnapshot?
        var executionSnapshot: PrimeValidationDriverV2GovernorExecutionSnapshot?
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
                                deadline.expiresAt,
                            terminalGate: capsule.terminalGate
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
                if capsule.runsBuildAndStaging {
                    guard let swiftPackageImage, let pinnedBundleInput, let lockedDependencies else {
                        throw governorRejected(
                            PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                            "swift_package_missing_owner")
                    }
                    do {
                        buildSnapshot = try PrimeValidationDriverV2GovernorBuildSnapshot(
                            prime: primeRoot, workspace: workspaceRoot, evidence: evidenceRoot,
                            swiftPackageImage: swiftPackageImage, pinnedBundleInput: pinnedBundleInput,
                            lockedDependencies: lockedDependencies,
                            intent: capsule.intent,
                            supervisorPID: spawned.processIdentifier,
                            supervisorWaitUptime: processResult.wait.returnedAtUptimeNanoseconds,
                            predecessor: inner, terminalGate: capsule.terminalGate, deadline: deadline)
                        if capsule.terminalGate == .gateG || capsule.terminalGate == .gateH {
                            guard let buildSnapshot else {
                                throw governorRejected(
                                    PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                                    "inventory_missing_build_snapshot")
                            }
                            inventorySnapshot = try PrimeValidationDriverV2GovernorInventorySnapshot(
                                evidence: evidenceRoot, build: buildSnapshot, intent: capsule.intent,
                                supervisorPID: spawned.processIdentifier,
                                supervisorWaitUptime: processResult.wait.returnedAtUptimeNanoseconds,
                                predecessorProcessGroups: inner.recordedChildProcessGroups,
                                terminalGate: capsule.terminalGate,
                                deadline: deadline)
                            if capsule.terminalGate == .gateH {
                                guard let inventorySnapshot else {
                                    throw governorRejected(PrimeValidationDriverV2ShotGovernorStatus.postReapRejection, "H_inventory_missing")
                                }
                                executionSnapshot = try PrimeValidationDriverV2GovernorExecutionSnapshot(
                                    evidence: evidenceRoot, workspace: workspaceRoot,
                                    build: buildSnapshot, inventory: inventorySnapshot, predecessor: inner,
                                    capsule: capsule, capsuleSHA256: PrimeSHA256.hexDigest(of: capsuleBytes),
                                    swiftPackageImage: swiftPackageImage, supervisorPID: spawned.processIdentifier,
                                    supervisorWaitUptime: processResult.wait.returnedAtUptimeNanoseconds, deadline: deadline)
                            }
                        }
                    } catch let failure as PrimeValidationDriverV2ShotGovernorFailure {
                        throw failure
                    } catch {
                        throw governorRejected(
                            PrimeValidationDriverV2ShotGovernorStatus.postReapRejection,
                            "build_readback_typed_binding_\(String(describing: error))")
                    }
                }
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
            if let swiftPackageImage {
                try swiftPackageImage.revalidate(coordinate: "swift_package_image_after")
                swiftPackageImageRejoined = true
            }
            _ = try pinnedBundleInput?.revalidate()
            try lockedDependencies?.revalidate()
            try primeRoot.revalidate(coordinate: "prime_root_after")
            try companionRoot.revalidate(coordinate: "companion_root_after")
            if capsule.terminalGate == .gateE {
                try workspaceRoot.requireEmpty(coordinate: "workspace_root_after")
                try evidenceRoot.requireEmpty(coordinate: "evidence_root_after")
            } else {
                try workspaceRoot.revalidate(coordinate: "workspace_root_after")
                try evidenceRoot.revalidate(coordinate: "evidence_root_after")
                // A nonzero F exit may retain a partial known-write tree; it
                // cannot enter buildSuccess. Zero requires the full readback.
                try buildSnapshot?.revalidate()
                try inventorySnapshot?.revalidate()
            try executionSnapshot?.revalidate()
            }
            try leaseRoot.revalidate(coordinate: "lease_root_after")
            try workingDirectory.requireEmpty(
                coordinate: "private_working_directory_after"
            )
            try base.revalidate(coordinate: "production_base_after")
            let expectedBaseInventory = (
                capsule.productionBaseEntryNamesBefore + [
                    capsule.outerJournalLeaf,
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
                    + capsule.outerJournalLeaf,
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
        } catch {
            // Preserve E's existing boundary. A rejected F/G value projection
            // still permits a contained-zero rejection record after reap.
            guard capsule.runsBuildAndStaging else { throw error }
            semanticFailure = "build_post_reap_typed_\(String(describing: error))"
        }
        var recordedGroups = inner.recordedChildProcessGroups
        if let buildSnapshot {
            recordedGroups.insert(buildSnapshot.envelope.process.processGroupIdentifier)
        }
        if let inventorySnapshot {
            for child in inventorySnapshot.envelope.children {
                recordedGroups.insert(child.process.processGroupIdentifier)
            }
        }
        if let executionSnapshot { recordedGroups.formUnion(executionSnapshot.recordedGroups) }
        let groupsEmpty = try requireGroupsEmpty(recordedGroups)
        if !groupsEmpty { semanticFailure = "inner_child_group_present" }
        if !stdout.reachedEOF || !stderr.reachedEOF {
            semanticFailure = "capture_eof"
        }
        if stdout.overflowed || stderr.overflowed {
            semanticFailure = "capture_overflow"
        }

        let outcome: PrimeValidationDriverV2GovernorTerminalOutcome
        let finalStatus: Int32
        if capsule.terminalGate == .gateH,
           processResult.wait.exitedNormally, processResult.wait.exitStatus == 0,
           semanticFailure == nil, processResult.conservation.ordinaryExitPath,
           inner.complete, innerReceiptValidated, outerContinuityRejoined, rootsRejoined,
           governorImageRejoined, supervisorImageRejoined, gitImageRejoined, swiftImageRejoined,
           swiftPackageImageRejoined == true, groupsEmpty,
           let executionSnapshot, let inventorySnapshot,
           stdout.byteCount == 0, stderr.byteCount == 0,
           stdout.sha256 == emptySHA256, stderr.sha256 == emptySHA256 {
            outcome = .executionSuccess(.init(
                publicationEnvelopeSHA256: executionSnapshot.envelopeSHA256,
                evidenceManifestSHA256: executionSnapshot.manifestSHA256,
                executionPlanSHA256: executionSnapshot.envelope.executionPlanSHA256,
                inventoryBindingSHA256: inventorySnapshot.bindingSHA256,
                innerFinalReceiptSHA256: executionSnapshot.envelope.innerFinalReceiptSHA256,
                disposition: executionSnapshot.envelope.disposition.rawValue,
                executionJournal: executionSnapshot.leaves, executionJournalVnodes: executionSnapshot.vnodes,
                recordedChildGroups: executionSnapshot.recordedGroups.sorted()))
            finalStatus = PrimeValidationDriverV2ShotGovernorStatus.success
        } else if capsule.terminalGate == .gateH {
            // Preserve established readback identities even if a later join
            // rejects publication. If construction failed, empty lists mean
            // this reader did not establish those identities; they do not
            // claim no H files exist. Partial namespace acquisition is not
            // silently upgraded into a complete semantic readback.
            let knownPrefixes = executionSnapshot?.immutablePrefixBindings ?? []
            let knownStarts = executionSnapshot?.observedStartBindings ?? []
            let knownTerminals = executionSnapshot?.observedTerminalBindings ?? []
            let exitCode = processResult.wait.exitedNormally ? processResult.wait.exitStatus : nil
            let reason: PrimeValidationDriverV2GovernorIncompleteObservationV1.Reason =
                exitCode.map { $0 != 0 } == true ? .supervisorRejected : .publicationRejected
            let observedAt = DispatchTime.now().uptimeNanoseconds
            let incomplete = PrimeValidationDriverV2GovernorIncompleteObservationV1(
                schemaVersion: 1, artifactKind: "prime_driver_v2_gate_h_governor_incomplete_observation_v1",
                runID: capsule.intent.runID, intentSHA256: try capsule.intent.identitySHA256(),
                acceptedCapsuleSHA256: PrimeSHA256.hexDigest(of: capsuleBytes), disposition: .incomplete,
                reason: reason, immutablePrefixBindings: knownPrefixes, observedStartBindings: knownStarts, observedTerminalBindings: knownTerminals,
                supervisorExitCode: exitCode, observedAtUptimeNanoseconds: observedAt, successorAuthorized: false)
            try incomplete.validate(expectedRunID: capsule.intent.runID,
                expectedIntentSHA256: capsule.intent.identitySHA256(),
                expectedAcceptedCapsuleSHA256: PrimeSHA256.hexDigest(of: capsuleBytes),
                actualPrefixBindings: knownPrefixes, actualStartBindings: knownStarts, actualTerminalBindings: knownTerminals,
                actualSupervisorExitCode: exitCode, actualObservedAtUptimeNanoseconds: observedAt, actualReason: reason)
            outcome = .executionIncomplete(incomplete)
            finalStatus = processResult.wait.exitedNormally && processResult.wait.exitStatus == 0
                ? PrimeValidationDriverV2ShotGovernorStatus.postReapRejection
                : PrimeValidationDriverV2ShotGovernorStatus.containedNonzero
        } else if !processResult.wait.exitedNormally
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
        } else if capsule.terminalGate == .gateE,
                  semanticFailure == nil,
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
        } else if capsule.terminalGate == .gateG,
                  semanticFailure == nil,
                  processResult.conservation.ordinaryExitPath,
                  inner.complete, innerReceiptValidated,
                  outerContinuityRejoined, rootsRejoined,
                  swiftPackageImageRejoined == true,
                  let durableReceiptIdentitySHA256,
                  let durableReceiptJournalVnodes,
                  let rawTerminalSHA256 = inner.rawTerminalSHA256,
                  let buildSnapshot, let inventorySnapshot,
                  stdout.byteCount == 0, stderr.byteCount == 0,
                  stdout.sha256 == emptySHA256, stderr.sha256 == emptySHA256
        {
            outcome = .inventorySuccess(.init(
                predecessorJournal: inner.immutablePrefix,
                predecessorJournalVnodes: durableReceiptJournalVnodes,
                predecessorDurableReceiptIdentitySHA256: durableReceiptIdentitySHA256,
                predecessorRawTerminalSHA256: rawTerminalSHA256,
                buildJournal: buildSnapshot.leaves,
                buildJournalVnodes: buildSnapshot.vnodes,
                buildBindingSHA256: buildSnapshot.bindingSHA256,
                buildProcessIdentifier: buildSnapshot.envelope.process.processIdentifier,
                buildProcessGroupIdentifier: buildSnapshot.envelope.process.processGroupIdentifier,
                inventoryJournal: inventorySnapshot.leaves,
                inventoryJournalVnodes: inventorySnapshot.vnodes,
                inventoryBindingSHA256: inventorySnapshot.bindingSHA256,
                inventoryReceiptIdentitySHA256: inventorySnapshot.receiptIdentitySHA256,
                inventoryProcessIdentifiers: inventorySnapshot.envelope.children.map { $0.process.processIdentifier },
                inventoryProcessGroupIdentifiers: inventorySnapshot.envelope.children.map { $0.process.processGroupIdentifier }))
            finalStatus = PrimeValidationDriverV2ShotGovernorStatus.success
        } else if capsule.terminalGate == .gateF,
                  semanticFailure == nil,
                  processResult.conservation.ordinaryExitPath,
                  inner.complete, innerReceiptValidated,
                  outerContinuityRejoined, rootsRejoined,
                  swiftPackageImageRejoined == true,
                  let durableReceiptIdentitySHA256,
                  let durableReceiptJournalVnodes,
                  let rawTerminalSHA256 = inner.rawTerminalSHA256,
                  let buildSnapshot,
                  stdout.byteCount == 0, stderr.byteCount == 0,
                  stdout.sha256 == emptySHA256, stderr.sha256 == emptySHA256
        {
            outcome = .buildSuccess(.init(
                predecessorJournal: inner.immutablePrefix,
                predecessorJournalVnodes: durableReceiptJournalVnodes,
                predecessorDurableReceiptIdentitySHA256: durableReceiptIdentitySHA256,
                predecessorRawTerminalSHA256: rawTerminalSHA256,
                buildJournal: buildSnapshot.leaves,
                buildJournalVnodes: buildSnapshot.vnodes,
                buildBindingSHA256: buildSnapshot.bindingSHA256,
                buildProcessIdentifier: buildSnapshot.envelope.process.processIdentifier,
                buildProcessGroupIdentifier: buildSnapshot.envelope.process.processGroupIdentifier))
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
                    schema: capsule.outerTerminalSchema,
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
                    swiftPackageImageRejoined: swiftPackageImageRejoined,
                    rootsRejoined: rootsRejoined,
                    outerContinuityRevalidated:
                        outerContinuityRejoined,
                    executionFailureCoordinate: capsule.terminalGate == .gateH && finalStatus != 0
                        ? String((semanticFailure ?? "supervisor_terminal_rejected").prefix(128)) : nil,
                    outcome: outcome
                ),
                expectedLeaf:
                    PrimeValidationDriverV2GovernorJournal.terminalLeaf
            )
            try inner.revalidate()
            try buildSnapshot?.revalidate()
            try inventorySnapshot?.revalidate()
            try executionSnapshot?.revalidate()
            try swiftPackageImage?.revalidate(coordinate: "swift_package_after_publication")
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
        terminalGate: PrimeValidationDriverV2TerminalGate = .gateE,
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
        let runsBuild = terminalGate != .gateE
        let runsInventory = terminalGate == .gateG || terminalGate == .gateH
        let runsExecution = terminalGate == .gateH
        let journalLeaf = runsExecution ? "gate-h-shot-governor-journal"
            : runsInventory ? "gate-g-shot-governor-journal"
            : runsBuild ? "gate-f-shot-governor-journal"
            : PrimeValidationDriverV2GovernorJournal.rootLeaf
        var capsule = PrimeValidationDriverV2ShotCapsuleV1(
            schemaVersion: PrimeValidationDriverV2ShotCapsuleV1.schemaVersion,
            artifactKind: runsExecution ? PrimeValidationDriverV2ShotCapsuleV1.executionArtifactKind
                : runsInventory
                ? PrimeValidationDriverV2ShotCapsuleV1.inventoryArtifactKind
                : runsBuild ? PrimeValidationDriverV2ShotCapsuleV1.buildArtifactKind
                : PrimeValidationDriverV2ShotCapsuleV1.artifactKind,
            attempt: 1,
            rerunAuthorized: false,
            localOnly: true,
            networkOperationCount: runsBuild ? nil : 0,
            dependencyFetchCount: runsBuild ? nil : 0,
            githubOperationCount: runsBuild ? nil : 0,
            dependencyResolutionPolicy: runsBuild ? "locked_package_resolved" : nil,
            fixtureExecutionCount: 0,
            swiftPMBuildExecutionCount: runsBuild ? 1 : 0,
            artifactStagingExecutionCount: runsBuild ? 1 : 0,
            inventoryExecutionCount: runsInventory ? 2 : 0,
            gateFAuthorized: runsBuild,
            gateGAuthorized: runsInventory,
            controlCommit: String(repeating: "1", count: 40),
            controlTree: String(repeating: "2", count: 40),
            sourceCommit: String(repeating: "3", count: 40),
            sourceTree: String(repeating: "4", count: 40),
            companionCommit: intent.companionCommit,
            companionTree: String(repeating: "5", count: 40),
            sourceIdentitySHA256:
                PrimeEmbeddedBuildProvenance.sourceIdentitySHA256,
            primeAdmittedFileCount: PrimeValidationDriverV2SealedSourceTopology.primeAdmittedFileCount,
            sourceIdentityRecordCount: PrimeValidationDriverV2SealedSourceTopology.sourceIdentityRecordCount,
            primeAuthorityDirectoryCount: PrimeValidationDriverV2SealedSourceTopology.primeAuthorityDirectoryCount,
            combinedWatcherDescriptorCount: PrimeValidationDriverV2SealedSourceTopology.combinedWatcherDescriptorCount,
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
                base.absolutePath + "/" + journalLeaf,
                base.absolutePath + "/outer-supervisor-stderr.bin",
                base.absolutePath + "/outer-supervisor-stdout.bin",
            ].sorted(),
            intent: intent
        )
        if runsExecution {
            capsule.gateHAuthorized = true
            capsule.executionGoScopeData = try PrimeCanonicalJSON.encode(PrimeValidationDriverV2DeclaredExecutionScopeV1(
                intent: intent, sourceCommit: capsule.sourceCommit, sourceTree: capsule.sourceTree,
                sourceTreeReplaySHA256: String(repeating: "a", count: 64), sourceIdentitySHA256: capsule.sourceIdentitySHA256,
                governorExecutable: capsule.governorExecutable, supervisorExecutable: capsule.supervisorExecutable))
        }
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
            leaseDirectoryAbsolutePath: capsule.leaseDirectoryAbsolutePath,
            terminalGate: capsule.terminalGate,
            executionGoScopeData: capsule.executionGoScopeData,
            acceptedCapsuleSHA256: capsule.terminalGate == .gateH ? PrimeSHA256.hexDigest(of: exactCapsuleBytes) : nil
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
            filesystem: filesystem,
            rootLeaf: capsule.outerJournalLeaf
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
        let result = try arguments.withUnsafeMutableBufferPointer { argv in
            try environment.withUnsafeMutableBufferPointer { envp in
                try deadline.requireTime("session_fixture_immediately_before_spawn")
                return posix_spawn(
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
        let lifecycleState =
            PrimeValidationDriverV2GovernorSessionLifecycleState(
                supervisorPID: pid
            )
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
                var cleanupBudget = PrimeValidationDriverV2GovernorCleanupBudget()
                let cleanupDeadline = try cleanupBudget.deadline()
                switch containmentState {
                case .armed:
                    do {
                        _ = try PrimeValidationDriverV2GovernorSessionCensus
                            .contain(
                                lifecycleState: lifecycleState,
                                deathWatcher: deathWatcher,
                                deadline: cleanupDeadline,
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
                                lifecycleState: lifecycleState,
                                deadline: cleanupDeadline
                            )
                        containmentState = .conservationComplete
                    }
                case .exactReaped:
                    _ = try PrimeValidationDriverV2GovernorSessionCensus
                        .containSessionAfterSupervisorReaped(
                            lifecycleState: lifecycleState,
                            deadline: cleanupDeadline
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
        try deadline.requireTime("session_fixture_immediately_before_resume")
        guard Darwin.kill(pid, SIGCONT) == 0 else {
            throw governorRejected(
                PrimeValidationDriverV2ShotGovernorStatus.suspendedJoin,
                "session_fixture_resume"
            )
        }

        var firstMembers = [PrimeValidationDriverV2GovernorSessionMember]()
        var acceptedAlreadyEmpty = false
        let resultObservation: (
            wait: PrimeValidationDriverV2GovernorWaitObservation,
            conservation: PrimeValidationDriverV2GovernorConservation
        )
        switch mode {
        case .prepublicationHeld:
            executionPhase = .prepublicationChildDiscovery
            while firstMembers.count < 2 {
                try deadline.requireTime("session_fixture_child_discovery")
                firstMembers = try PrimeValidationDriverV2GovernorSessionCensus
                    .recordedScan(
                        lifecycleState: lifecycleState,
                        deadline: deadline,
                        exhaustionCoordinate:
                            "session_census_nonconvergent_query"
                    )
                if firstMembers.count < 2 { _ = Darwin.usleep(1_000) }
            }
            executionPhase = .primaryContainment
            resultObservation = try PrimeValidationDriverV2GovernorSessionCensus
                .contain(
                    lifecycleState: lifecycleState,
                    deathWatcher: deathWatcher,
                    deadline: deadline,
                    onExactReap: { containmentState = .exactReaped }
                )
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
            resultObservation = try PrimeValidationDriverV2GovernorSessionCensus
                .reapNormallyAfterExit(
                    lifecycleState: lifecycleState,
                    deathWatcher: deathWatcher,
                    deadline: deadline,
                    onExactReap: { containmentState = .exactReaped }
                )
            executionPhase = .primaryContainment
            firstMembers = resultObservation.conservation.capturedMembers
            acceptedAlreadyEmpty =
                resultObservation.conservation.ordinaryExitPath
        }
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
