// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore
#if canImport(PrimeValidationWorkflowRootContracts)
import PrimeValidationWorkflowRootContracts
#else
import PrimeValidationWorkflowContracts
#endif

/// A durable declaration of the exact image expected to hold the Driver V2
/// supervisor role. Decoding this value never restores live authority.
public struct PrimeValidationDriverV2SupervisorImageDeclarationV1:
    Codable,
    Equatable,
    Sendable
{
    public static let schemaVersion = 1
    public static let artifactKind =
        "ergentics_prime_validation_driver_v2_supervisor_image_declaration_v1"

    public let schemaVersion: Int
    public let artifactKind: String
    public let runID: String
    public let sourceIdentitySHA256: String
    public let executable: PrimeValidationExecutableBindingV2

    public init(
        runID: String,
        sourceIdentitySHA256: String,
        executable: PrimeValidationExecutableBindingV2
    ) {
        schemaVersion = Self.schemaVersion
        artifactKind = Self.artifactKind
        self.runID = runID
        self.sourceIdentitySHA256 = sourceIdentitySHA256
        self.executable = executable
    }

    public func validate() throws {
        guard schemaVersion == Self.schemaVersion,
              artifactKind == Self.artifactKind
        else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        guard PrimeValidationDriverV2Validation.isRunID(runID) else {
            throw PrimeValidationDriverV2Error.invalidRunID(runID)
        }
        try PrimeValidationDriverV2Validation.requireSHA256(
            sourceIdentitySHA256
        )
        try executable.validate()
    }

    public func identitySHA256() throws -> String {
        try validate()
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

package enum PrimeValidationDriverV2LiveAuthorityCeiling:
    String,
    Codable,
    Sendable
{
    case supervisorImageBoundPreExecutionOnly =
        "supervisor_image_bound_pre_execution_only"
    case poisonedNoAuthority = "poisoned_no_authority"
}

/// Package-only live authority for a mapped image that matched the declared
/// Driver V2 supervisor identity. It has no process, build, inventory,
/// staging, shard, publication, or restoration surface.
package final class PrimeValidationDriverV2BoundSupervisorImage {
    package let declaration:
        PrimeValidationDriverV2SupervisorImageDeclarationV1
    package let observation:
        PrimeValidationHeldExecutableObservationV2

    private let claimed:
        PrimeValidationSwiftPMClaimedCurrentProcessImage

    fileprivate init(
        declaration:
            PrimeValidationDriverV2SupervisorImageDeclarationV1,
        observation:
            PrimeValidationHeldExecutableObservationV2,
        claimed:
            PrimeValidationSwiftPMClaimedCurrentProcessImage
    ) {
        self.declaration = declaration
        self.observation = observation
        self.claimed = claimed
    }

    package var authorityCeiling:
        PrimeValidationDriverV2LiveAuthorityCeiling
    {
        claimed.guardState == .prepared
            ? .supervisorImageBoundPreExecutionOnly
            : .poisonedNoAuthority
    }

    package var missingAuthorities:
        [PrimeValidationSwiftPMMissingAuthority]
    {
        guard claimed.guardState == .prepared else {
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
        try declaration.validate()
        try observation.validate()
        try claimed.revalidate()
        let current = claimed.currentProcessExecutable
        guard claimed.productionSupervisorImageEligible,
              declaration.sourceIdentitySHA256
                == claimed.sourceIdentitySHA256,
              declaration.executable.absolutePath
                == current.canonicalAbsolutePath,
              declaration.executable.content.sha256 == current.sha256,
              declaration.executable.content.byteCount
                == current.byteCount,
              observation.requestedAbsolutePath
                == declaration.executable.absolutePath,
              observation.canonicalAbsolutePath
                == current.canonicalAbsolutePath,
              observation.content == declaration.executable.content,
              observation.deviceID == current.deviceID,
              observation.inode == current.inode,
              observation.fileByteCount == current.byteCount
        else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
    }
}

package enum PrimeValidationDriverV2SupervisorImageBridge {
    package static func bind(
        handoff: PrimeValidationSwiftPMCurrentProcessImageHandoff,
        declaration:
            PrimeValidationDriverV2SupervisorImageDeclarationV1
    ) throws -> PrimeValidationDriverV2BoundSupervisorImage {
        try declaration.validate()
        guard handoff.productionSupervisorImageEligible else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        let claimed = try handoff.consumeMatchingCurrentProcessImage(
            expectedCanonicalAbsolutePath:
                declaration.executable.absolutePath,
            expectedSHA256: declaration.executable.content.sha256,
            expectedByteCount: declaration.executable.content.byteCount,
            expectedSourceIdentitySHA256:
                declaration.sourceIdentitySHA256
        )
        let current = claimed.currentProcessExecutable
        let observation = PrimeValidationHeldExecutableObservationV2(
            requestedAbsolutePath:
                declaration.executable.absolutePath,
            canonicalAbsolutePath: current.canonicalAbsolutePath,
            requestedSymlinkTarget: nil,
            content: declaration.executable.content,
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
            mappedExecutableJoined: true
        )
        let bound = PrimeValidationDriverV2BoundSupervisorImage(
            declaration: declaration,
            observation: observation,
            claimed: claimed
        )
        try bound.revalidate()
        return bound
    }
}

package struct PrimeValidationDriverV2SupervisorImageCanaryRecordV1:
    Codable,
    Sendable
{
    package static let schemaVersion = 1
    package static let artifactKind =
        "ergentics_prime_validation_driver_v2_supervisor_image_canary_v1"

    package let schemaVersion: Int
    package let artifactKind: String
    package let runID: String
    package let declarationSHA256: String
    package let sourceIdentitySHA256: String
    package let executableAbsolutePath: String
    package let executableSHA256: String
    package let executableByteCount: UInt64
    package let authorityCeiling: String
    package let missingAuthorities: [String]
    package let processExecutionObservation: String
    package let buildExecutionObservation: String
    package let inventoryExecutionObservation: String
    package let artifactStagingObservation: String
    package let shardCompletionObservation: String
    package let completionAuthorized: Bool
    package let statement: String

    package init(
        bound: PrimeValidationDriverV2BoundSupervisorImage
    ) throws {
        try bound.revalidate()
        schemaVersion = Self.schemaVersion
        artifactKind = Self.artifactKind
        runID = bound.declaration.runID
        declarationSHA256 =
            try bound.declaration.identitySHA256()
        sourceIdentitySHA256 =
            bound.declaration.sourceIdentitySHA256
        executableAbsolutePath =
            bound.observation.canonicalAbsolutePath
        executableSHA256 = bound.observation.content.sha256
        executableByteCount = bound.observation.content.byteCount
        authorityCeiling = bound.authorityCeiling.rawValue
        missingAuthorities = bound.missingAuthorities.map(\.rawValue)
        processExecutionObservation =
            bound.processExecutionObservation.rawValue
        buildExecutionObservation =
            bound.buildExecutionObservation.rawValue
        inventoryExecutionObservation =
            bound.inventoryExecutionObservation.rawValue
        artifactStagingObservation =
            bound.artifactStagingObservation.rawValue
        shardCompletionObservation =
            bound.shardCompletionObservation.rawValue
        completionAuthorized = bound.completionAuthorized
        statement =
            "supervisor_image_bound_no_process_build_inventory_staging_shard_or_completion_authority"
    }
}

package struct PrimeValidationDriverV2SupervisorImageCanaryEnvelopeV1:
    Codable,
    Sendable
{
    package let record:
        PrimeValidationDriverV2SupervisorImageCanaryRecordV1
    package let recordSHA256: String

    package init(
        record:
            PrimeValidationDriverV2SupervisorImageCanaryRecordV1
    ) throws {
        self.record = record
        recordSHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(record)
        )
    }
}
