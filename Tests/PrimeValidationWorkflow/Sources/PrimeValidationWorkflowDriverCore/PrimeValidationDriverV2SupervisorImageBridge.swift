// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowContracts

package enum PrimeValidationDriverV2TerminalGate:
    String, Codable, Equatable, Sendable
{
    case gateE = "E"
    case gateF = "F"
    case gateG = "G"
    case gateH = "H"

    /// H records 494 execution leaf/vnode pairs for the frozen 72-shard plan.
    /// Earlier gates retain their existing 64 KiB terminal limit.
    package static let gateHOuterTerminalMaximumBytes = 1_048_576

    /// The frozen nine phase budgets total 5,070 seconds. The governor adds
    /// 30 seconds for admission, held readback and terminal publication.
    package static let gateHOuterDurationNanoseconds: UInt64 =
        PrimeValidationExecutorAdmissionPolicyV2.frozenV1.phaseBudgets
            .reduce(UInt64(0)) { $0 + $1.maximumActiveNanoseconds } + 30_000_000_000

    package static func gateHOuterDurationNanoseconds(intent: PrimeValidationRunIntentV2) throws -> UInt64 {
        let profile = try PrimeValidationExecutorAdmissionPolicyV2.budgetProfile(for: intent)
        return try profile.outerMaximumActiveNanoseconds
    }
}

/// Canonical, bounded transport for the dedicated Gate A process. This outer
/// envelope is not a new run-intent or authority schema: decoding it never
/// restores or constructs live authority, and the process discards it at exit.
package struct PrimeValidationDriverV2SupervisorLaunchRequestV1:
    Codable,
    Equatable,
    Sendable
{
    package static let schemaVersion = 1
    package static let artifactKind =
        "ergentics_prime_validation_driver_v2_supervisor_launch_request_v1"

    package let schemaVersion: Int
    package let artifactKind: String
    package let intent: PrimeValidationRunIntentV2
    package let leaseDirectoryAbsolutePath: String
    package let terminalGate: PrimeValidationDriverV2TerminalGate
    package let executionGoScopeData: Data?
    package let acceptedCapsuleSHA256: String?

    package init(
        intent: PrimeValidationRunIntentV2,
        leaseDirectoryAbsolutePath: String,
        terminalGate: PrimeValidationDriverV2TerminalGate = .gateE,
        executionGoScopeData: Data? = nil,
        acceptedCapsuleSHA256: String? = nil
    ) {
        schemaVersion = Self.schemaVersion
        artifactKind = Self.artifactKind
        self.intent = intent
        self.leaseDirectoryAbsolutePath = leaseDirectoryAbsolutePath
        self.terminalGate = terminalGate
        self.executionGoScopeData = executionGoScopeData
        self.acceptedCapsuleSHA256 = acceptedCapsuleSHA256
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        artifactKind = try container.decode(String.self, forKey: .artifactKind)
        intent = try container.decode(PrimeValidationRunIntentV2.self,
                                      forKey: .intent)
        leaseDirectoryAbsolutePath = try container.decode(
            String.self, forKey: .leaseDirectoryAbsolutePath
        )
        terminalGate = try container.decodeIfPresent(
            PrimeValidationDriverV2TerminalGate.self, forKey: .terminalGate
        ) ?? .gateE
        executionGoScopeData = try container.decodeIfPresent(Data.self, forKey: .executionGoScopeData)
        acceptedCapsuleSHA256 = try container.decodeIfPresent(String.self, forKey: .acceptedCapsuleSHA256)
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(artifactKind, forKey: .artifactKind)
        try container.encode(intent, forKey: .intent)
        try container.encode(leaseDirectoryAbsolutePath,
                             forKey: .leaseDirectoryAbsolutePath)
        // Preserve the exact old E envelope. Later gates must be explicit.
        if terminalGate != .gateE {
            try container.encode(terminalGate, forKey: .terminalGate)
        }
        try container.encodeIfPresent(executionGoScopeData, forKey: .executionGoScopeData)
        try container.encodeIfPresent(acceptedCapsuleSHA256, forKey: .acceptedCapsuleSHA256)
    }

    package func validate() throws {
        guard schemaVersion == Self.schemaVersion,
              artifactKind == Self.artifactKind
        else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        try intent.validate()
        // Preserve historical declaration-only E/F/G envelope validation.
        // Their live role bridge still requires the exact frozen policy.
        guard terminalGate == .gateH || intent.phaseBudgets
            != PrimeValidationExecutorAdmissionPolicyV2.currentSourceExecutionV1.phaseBudgets else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        if terminalGate == .gateH {
            guard let executionGoScopeData, let acceptedCapsuleSHA256 else {
                throw PrimeValidationDriverV2Error.authorityViolation
            }
            let scope = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2DeclaredExecutionScopeV1.self,
                from: executionGoScopeData)
            try scope.validate(intent: intent)
            try PrimeValidationDriverV2Validation.requireSHA256(acceptedCapsuleSHA256)
        } else {
            guard executionGoScopeData == nil, acceptedCapsuleSHA256 == nil else {
                throw PrimeValidationDriverV2Error.authorityViolation
            }
        }
        try PrimeValidationDriverV2Validation.requireSafeAbsolutePath(
            leaseDirectoryAbsolutePath
        )
        let roots = [
            intent.roots.repositoryRoot.absolutePath,
            intent.roots.companionRoot.absolutePath,
            intent.roots.workspaceRoot.absolutePath,
            intent.roots.evidenceRoot.absolutePath,
        ]
        guard !roots.contains(leaseDirectoryAbsolutePath) else {
            throw PrimeValidationDriverV2Error.invalidIntent
        }
        for root in roots {
            guard !root.hasPrefix(leaseDirectoryAbsolutePath + "/"),
                  !leaseDirectoryAbsolutePath.hasPrefix(root + "/")
            else {
                throw PrimeValidationDriverV2Error.invalidIntent
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case intent
        case leaseDirectoryAbsolutePath =
            "lease_directory_absolute_path"
        case terminalGate = "terminal_gate"
        case executionGoScopeData = "execution_go_scope_data"
        case acceptedCapsuleSHA256 = "accepted_capsule_sha256"
    }
}

/// A declaration of the closed H scope, never a reconstructed live owner.
package struct PrimeValidationDriverV2DeclaredExecutionScopeV1: Codable, Equatable {
    package let schema: String
    package let intentSHA256: String
    package let sourceCommit: String
    package let sourceTree: String
    package let sourceTreeReplaySHA256: String
    package let sourceIdentitySHA256: String
    package let governorExecutable: PrimeValidationExecutableBindingV2
    package let supervisorExecutable: PrimeValidationExecutableBindingV2
    package let referenceScopes: [String]
    package let candidateScope: String
    package let referenceMaximumActiveNanoseconds: UInt64
    package let candidateMaximumActiveNanoseconds: UInt64

    package init(intent: PrimeValidationRunIntentV2, sourceCommit: String, sourceTree: String, sourceTreeReplaySHA256: String,
        sourceIdentitySHA256: String, governorExecutable: PrimeValidationExecutableBindingV2,
        supervisorExecutable: PrimeValidationExecutableBindingV2) throws {
        schema = "prime_driver_v2_gate_h_declared_execution_scope_v1"
        intentSHA256 = try intent.identitySHA256()
        self.sourceCommit = sourceCommit; self.sourceTree = sourceTree
        self.sourceTreeReplaySHA256 = sourceTreeReplaySHA256
        self.sourceIdentitySHA256 = sourceIdentitySHA256
        self.governorExecutable = governorExecutable; self.supervisorExecutable = supervisorExecutable
        referenceScopes = ["parallel_xctest", "sequential_xctest", "swift_testing"]
        candidateScope = "frozen_suite_contiguous_32_original_planner"
        let profile = try PrimeValidationExecutorAdmissionPolicyV2.budgetProfile(for: intent)
        referenceMaximumActiveNanoseconds = profile.executionArmMaximumActiveNanoseconds
        candidateMaximumActiveNanoseconds = profile.executionArmMaximumActiveNanoseconds
        try validate(intent: intent)
    }
    package func validate(intent: PrimeValidationRunIntentV2) throws {
        let profile = try PrimeValidationExecutorAdmissionPolicyV2.budgetProfile(for: intent)
        guard schema == "prime_driver_v2_gate_h_declared_execution_scope_v1",
              intentSHA256 == (try intent.identitySHA256()), supervisorExecutable == intent.driverExecutable,
              referenceScopes == ["parallel_xctest", "sequential_xctest", "swift_testing"],
              candidateScope == "frozen_suite_contiguous_32_original_planner",
              referenceMaximumActiveNanoseconds == profile.executionArmMaximumActiveNanoseconds,
              candidateMaximumActiveNanoseconds == profile.executionArmMaximumActiveNanoseconds,
              [sourceCommit, sourceTree].allSatisfy({ value in
                  value.utf8.count == 40 && value.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) })
              }) else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        try PrimeValidationDriverV2Validation.requireSHA256(sourceIdentitySHA256)
        try PrimeValidationDriverV2Validation.requireSHA256(sourceTreeReplaySHA256)
        try governorExecutable.validate(); try supervisorExecutable.validate()
    }
}

package enum PrimeValidationDriverV2LiveAuthorityCeiling:
    String,
    Sendable
{
    case supervisorImageBoundNoExecution =
        "supervisor_image_bound_no_execution"
    case fixedRoleFacadeTransferredNoAuthority =
        "fixed_role_facade_transferred_no_authority"
    case poisonedNoAuthority = "poisoned_no_authority"
}

/// Gate A correlates only the intent's driver declaration with the mapped
/// supervisor image. Other intent fields remain declarations for later gates.
package enum PrimeValidationDriverV2IntentCorrelation:
    Sendable
{
    case driverExecutableOnly
}

/// Non-Codable, non-restorable DriverCore ownership of the exact image match.
/// It retains the opaque PrimeCore capability; durable values cannot recreate
/// it and it exposes no generic process, build, staging, inventory, shard, or
/// receipt operation. Gate B adds only the zero-input fixed-role transfer.
package final class PrimeValidationDriverV2SupervisorImageCapability:
    @unchecked Sendable
{
    private enum State {
        case bound
        case fixedRoleFacadeTransferred
        case poisoned
    }

    package let intentCorrelation:
        PrimeValidationDriverV2IntentCorrelation =
            .driverExecutableOnly
    package let supervisorExecutable:
        PrimeValidationHeldExecutableObservationV2
    private let roleContext: PrimeValidationDriverV2RoleContext

    private let driverExecutable:
        PrimeValidationExecutableBindingV2
    private let liveImage:
        PrimeValidationSwiftPMDriverV2SupervisorImageCapability
    private let stateLock = NSLock()
    private var state: State = .bound

    fileprivate init(
        roleContext: PrimeValidationDriverV2RoleContext,
        driverExecutable:
            PrimeValidationExecutableBindingV2,
        supervisorExecutable:
            PrimeValidationHeldExecutableObservationV2,
        liveImage:
            PrimeValidationSwiftPMDriverV2SupervisorImageCapability
    ) {
        self.roleContext = roleContext
        self.driverExecutable = driverExecutable
        self.supervisorExecutable = supervisorExecutable
        self.liveImage = liveImage
    }

    package var authorityCeiling:
        PrimeValidationDriverV2LiveAuthorityCeiling
    {
        stateLock.lock()
        defer { stateLock.unlock() }
        switch state {
        case .bound:
            return .supervisorImageBoundNoExecution
        case .fixedRoleFacadeTransferred:
            return .fixedRoleFacadeTransferredNoAuthority
        case .poisoned:
            return .poisonedNoAuthority
        }
    }

    package var missingAuthorities:
        [PrimeValidationSwiftPMMissingAuthority]
    {
        stateLock.lock()
        defer { stateLock.unlock() }
        guard case .bound = state else {
            return PrimeValidationSwiftPMMissingAuthority.allCases
        }
        let closed: Set<PrimeValidationSwiftPMMissingAuthority> = [
            .descriptorBackedSourceClosureAndMutationGuard,
            .sourceWatchWindow,
            .supervisorExecutableImage,
        ]
        return PrimeValidationSwiftPMMissingAuthority.allCases.filter {
            !closed.contains($0)
        }
    }

    package var processExecutionObservation:
        PrimeValidationSwiftPMObservationState
    {
        .unobserved
    }

    package var buildExecutionObservation:
        PrimeValidationSwiftPMObservationState
    {
        .unobserved
    }

    package var inventoryExecutionObservation:
        PrimeValidationSwiftPMObservationState
    {
        .unobserved
    }

    package var artifactStagingObservation:
        PrimeValidationSwiftPMObservationState
    {
        .unobserved
    }

    package var shardCompletionObservation:
        PrimeValidationSwiftPMObservationState
    {
        .unobserved
    }

    package var completionAuthorized: Bool { false }

    package func revalidate() throws {
        stateLock.lock()
        defer { stateLock.unlock() }
        guard case .bound = state else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        do {
            try driverExecutable.validate()
            try liveImage.revalidate()
            try supervisorExecutable.validate()
            let current = liveImage.observation
            guard liveImage.productionSupervisorImageEligible,
                  supervisorExecutable.requestedAbsolutePath
                    == driverExecutable.absolutePath,
                  supervisorExecutable.canonicalAbsolutePath
                    == current.canonicalAbsolutePath,
                  supervisorExecutable.requestedSymlinkTarget == nil,
                  supervisorExecutable.content
                    == driverExecutable.content,
                  supervisorExecutable.deviceID == current.deviceID,
                  supervisorExecutable.inode == current.inode,
                  supervisorExecutable.fileByteCount
                    == current.byteCount,
                  supervisorExecutable.mappedExecutableAbsolutePath
                    == current.canonicalAbsolutePath,
                  supervisorExecutable.descriptorJoined,
                  supervisorExecutable.pathIdentityJoined,
                  supervisorExecutable.mappedExecutableJoined,
                  current.deviceID == current.loadedImageDeviceID,
                  current.inode == current.loadedImageInode,
                  current.mappedImageJoined
            else {
                throw PrimeValidationDriverV2Error.authorityViolation
            }
        } catch {
            state = .poisoned
            throw error
        }
    }

    /// Consumes the complete Gate-A token into the fixed, ordered Driver V2
    /// role facade. Its context was derived solely from the validated intent;
    /// no command, argv, environment, cwd, deadline, or callback crosses
    /// this boundary.
    @available(macOS 26.0, *)
    package func consumeFixedRoleFacade()
        throws -> PrimeValidationDriverV2RoleFacade
    {
        stateLock.lock()
        guard case .bound = state else {
            stateLock.unlock()
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        do {
            let facade = try liveImage.transferDriverV2RoleFacade(
                context: roleContext
            )
            state = .fixedRoleFacadeTransferred
            stateLock.unlock()
            return facade
        } catch {
            state = .poisoned
            stateLock.unlock()
            throw error
        }
    }
}

/// The only DriverCore transition that can close Gate A. It validates the
/// complete typed intent for schema integrity, but correlates live evidence
/// only with `intent.driverExecutable`; later gates must bind every other
/// declared intent field. It then consumes the prior live guarded token.
package enum PrimeValidationDriverV2SupervisorImageBridge {
    package static func bind(
        intent: PrimeValidationRunIntentV2,
        guardedPreExecutor:
            PrimeValidationSwiftPMBuildInventoryGuardedPreExecutor,
        terminalGate: PrimeValidationDriverV2TerminalGate = .gateE,
        executionGoScopeData: Data = Data()
    ) throws -> PrimeValidationDriverV2SupervisorImageCapability {
        try intent.validate()
        let roleContext = try PrimeValidationDriverV2RoleBridge
            .roleContext(from: intent, terminalGate: terminalGate, executionGoScopeData: executionGoScopeData)
        let expected =
            PrimeValidationSwiftPMDriverV2ExecutableExpectation(
                canonicalAbsolutePath:
                    intent.driverExecutable.absolutePath,
                byteCount:
                    intent.driverExecutable.content.byteCount,
                sha256: intent.driverExecutable.content.sha256
            )
        let liveImage = try guardedPreExecutor
            .bindDriverV2SupervisorImage(expecting: expected)
        let current = liveImage.observation
        let observation = PrimeValidationHeldExecutableObservationV2(
            requestedAbsolutePath:
                intent.driverExecutable.absolutePath,
            canonicalAbsolutePath: current.canonicalAbsolutePath,
            requestedSymlinkTarget: nil,
            content: intent.driverExecutable.content,
            deviceID: current.deviceID,
            inode: current.inode,
            ownerUserID: current.ownerUserID,
            ownerGroupID: current.ownerGroupID,
            mode: current.permissionMode,
            linkCount: current.linkCount,
            fileByteCount: current.byteCount,
            modificationTimeSeconds: current.modificationSeconds,
            modificationTimeNanoseconds:
                current.modificationNanoseconds,
            statusChangeTimeSeconds: current.statusChangeSeconds,
            statusChangeTimeNanoseconds:
                current.statusChangeNanoseconds,
            mappedExecutableAbsolutePath:
                current.canonicalAbsolutePath,
            descriptorJoined: true,
            pathIdentityJoined: true,
            mappedExecutableJoined:
                current.deviceID == current.loadedImageDeviceID
                    && current.inode == current.loadedImageInode
        )
        let capability =
            PrimeValidationDriverV2SupervisorImageCapability(
                roleContext: roleContext,
                driverExecutable: intent.driverExecutable,
                supervisorExecutable: observation,
                liveImage: liveImage
            )
        try capability.revalidate()
        return capability
    }
}
