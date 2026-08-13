// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
import PrimeCore

public enum PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case weightsV2 = "weights_v2"
    case optimizerMoments = "optimizer_moments"
    case controlStateManifest = "control_state_manifest"
    case commitManifest = "commit_manifest"
}

public enum PrimeNativeDecoderTrajectoryCheckpointFaultV1:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case duringWeights = "during_weights_leaf_publication"
    case afterWeights = "after_weights_leaf_publication"
    case duringOptimizerMoments = "during_optimizer_moments_leaf_publication"
    case afterOptimizerMoments = "after_optimizer_moments_leaf_publication"
    case duringControlState = "during_control_state_leaf_publication"
    case afterControlState = "after_control_state_leaf_publication"
    case duringCommitManifest = "during_final_commit_manifest_publication"
}

public struct PrimeNativeDecoderTrajectoryLeafBindingV1:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1
    public let publicationOrdinal: Int
    public let artifact: PrimeArtifactBinding

    public init(
        role: PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1,
        publicationOrdinal: Int,
        artifact: PrimeArtifactBinding
    ) {
        self.role = role
        self.publicationOrdinal = publicationOrdinal
        self.artifact = artifact
    }

    private enum CodingKeys: String, CodingKey {
        case role
        case publicationOrdinal = "publication_ordinal"
        case artifact
    }
}

public struct PrimeNativeDecoderTrajectoryCommitManifestV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let stateScope: String
    public let precommitLeafBindings:
        [PrimeNativeDecoderTrajectoryLeafBindingV1]
    public let finalCommitManifestIsExclusiveCommitPoint: Bool
    public let partialPrecommitLeavesAreAuthoritative: Bool
    public let loadRequiresExternallySuppliedExactCommitBinding: Bool

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case stateScope = "state_scope"
        case precommitLeafBindings = "precommit_leaf_bindings"
        case finalCommitManifestIsExclusiveCommitPoint =
            "final_commit_manifest_is_exclusive_commit_point"
        case partialPrecommitLeavesAreAuthoritative =
            "partial_precommit_leaves_are_authoritative"
        case loadRequiresExternallySuppliedExactCommitBinding =
            "load_requires_externally_supplied_exact_commit_binding"
    }
}

public struct PrimeNativeDecoderTrajectoryExternalCommitBindingV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let directory: String
    public let orderedLeafBindings:
        [PrimeNativeDecoderTrajectoryLeafBindingV1]
    public let commitManifestCanonicalByteCount: UInt64
    public let commitManifestCanonicalSHA256: String

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case directory
        case orderedLeafBindings = "ordered_leaf_bindings"
        case commitManifestCanonicalByteCount =
            "commit_manifest_canonical_byte_count"
        case commitManifestCanonicalSHA256 =
            "commit_manifest_canonical_sha256"
    }
}

public struct PrimeNativeDecoderTrajectoryQuarantineV1:
    Codable,
    Equatable,
    Sendable
{
    public let directory: String
    public let fault: PrimeNativeDecoderTrajectoryCheckpointFaultV1
    public let publishedLeafBindings:
        [PrimeNativeDecoderTrajectoryLeafBindingV1]

    public init(
        directory: String,
        fault: PrimeNativeDecoderTrajectoryCheckpointFaultV1,
        publishedLeafBindings:
            [PrimeNativeDecoderTrajectoryLeafBindingV1]
    ) {
        self.directory = directory
        self.fault = fault
        self.publishedLeafBindings = publishedLeafBindings
    }

    private enum CodingKeys: String, CodingKey {
        case directory
        case fault
        case publishedLeafBindings = "published_leaf_bindings"
    }
}

public struct PrimeNativeDecoderTrajectoryLoadedCheckpointV1:
    Equatable,
    Sendable
{
    public let weightsSafetensors: Data
    public let optimizerMomentsSafetensors: Data
    public let controlState: Data

    public init(
        weightsSafetensors: Data,
        optimizerMomentsSafetensors: Data,
        controlState: Data
    ) {
        self.weightsSafetensors = weightsSafetensors
        self.optimizerMomentsSafetensors = optimizerMomentsSafetensors
        self.controlState = controlState
    }
}

public enum PrimeNativeDecoderTrajectoryCheckpointV1Error:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case invalidDirectory
    case invalidSafetensors
    case nonCanonicalControlState
    case invalidExternalCommitBinding
    case invalidCommitManifest
    case destinationConflict
    case artifactVerificationFailed
    case publicationFailed
    case loadFailed
    case injectedFailure(PrimeNativeDecoderTrajectoryQuarantineV1)
}

/// Generic four-leaf trajectory checkpoint mechanics.
///
/// This codec treats both safetensors leaves as opaque, structurally valid
/// tiny-fixture bytes. It neither calls nor reinterprets the public
/// weights-only V2 codec; Native-300M composition remains deferred. The
/// externally supplied commit binding is the only load authority; the
/// canonical commit manifest is published last and is the exclusive commit
/// point.
public enum PrimeNativeDecoderTrajectoryCheckpointV1 {
    public static let checkpointSchemaID =
        "ergentics_prime_native_decoder_trajectory_exact_resume_checkpoint_v1"
    public static let externalCommitBindingSchemaID =
        "ergentics_prime_native_decoder_trajectory_exact_resume_external_commit_binding_v1"

    private static let weightsFileName = "weights.safetensors"
    private static let optimizerFileName = "optimizer_moments.safetensors"
    private static let controlFileName = "control_state.json"
    private static let commitFileName = "commit.json"
    private static let maximumLeafByteCount: UInt64 = 16 * 1024 * 1024

    public static func publish(
        root: PrimeArtifactRoot,
        directory: String,
        weightsSafetensors: Data,
        optimizerMomentsSafetensors: Data,
        controlState: Data,
        fault: PrimeNativeDecoderTrajectoryCheckpointFaultV1? = nil
    ) throws -> PrimeNativeDecoderTrajectoryExternalCommitBindingV1 {
        do {
            try root.requirePrivateRootMode()
            try root.requireEmpty()
            try validateDirectory(directory)
            try validateSafetensors(weightsSafetensors)
            try validateSafetensors(optimizerMomentsSafetensors)
            try validateCanonicalJSON(controlState)
            try root.ensurePrivateDirectory(at: directory)
        } catch let error as PrimeNativeDecoderTrajectoryCheckpointV1Error {
            throw error
        } catch is PrimeDurableArtifactError {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .destinationConflict
        } catch {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .contractDrift
        }

        var leaves = [PrimeNativeDecoderTrajectoryLeafBindingV1]()
        do {
            let weights = try publishLeaf(
                root: root,
                directory: directory,
                fileName: weightsFileName,
                data: weightsSafetensors,
                during: fault == .duringWeights)
            leaves.append(.init(
                role: .weightsV2,
                publicationOrdinal: 1,
                artifact: weights))
            try injectAfter(.afterWeights, selected: fault,
                            directory: directory, leaves: leaves)

            let optimizer = try publishLeaf(
                root: root,
                directory: directory,
                fileName: optimizerFileName,
                data: optimizerMomentsSafetensors,
                during: fault == .duringOptimizerMoments)
            leaves.append(.init(
                role: .optimizerMoments,
                publicationOrdinal: 2,
                artifact: optimizer))
            try injectAfter(.afterOptimizerMoments, selected: fault,
                            directory: directory, leaves: leaves)

            let control = try publishLeaf(
                root: root,
                directory: directory,
                fileName: controlFileName,
                data: controlState,
                during: fault == .duringControlState)
            leaves.append(.init(
                role: .controlStateManifest,
                publicationOrdinal: 3,
                artifact: control))
            try injectAfter(.afterControlState, selected: fault,
                            directory: directory, leaves: leaves)

            let manifest = PrimeNativeDecoderTrajectoryCommitManifestV1(
                schemaVersion: 1,
                schemaID: checkpointSchemaID,
                stateScope:
                    "tiny_stage3_snapshot_durable_multileaf_mechanics_v1",
                precommitLeafBindings: leaves,
                finalCommitManifestIsExclusiveCommitPoint: true,
                partialPrecommitLeavesAreAuthoritative: false,
                loadRequiresExternallySuppliedExactCommitBinding: true)
            let manifestData = try PrimeCanonicalJSON.encode(manifest)
            let commit = try publishLeaf(
                root: root,
                directory: directory,
                fileName: commitFileName,
                data: manifestData,
                during: fault == .duringCommitManifest)
            leaves.append(.init(
                role: .commitManifest,
                publicationOrdinal: 4,
                artifact: commit))
            let binding = PrimeNativeDecoderTrajectoryExternalCommitBindingV1(
                schemaVersion: 1,
                schemaID: externalCommitBindingSchemaID,
                directory: directory,
                orderedLeafBindings: leaves,
                commitManifestCanonicalByteCount:
                    UInt64(manifestData.count),
                commitManifestCanonicalSHA256:
                    PrimeSHA256.hexDigest(of: manifestData))
            try validate(binding)
            return binding
        } catch let error as PrimeNativeDecoderTrajectoryCheckpointV1Error {
            if case .injectedFailure = error { throw error }
            throw error
        } catch InjectedDuringPublication.failure {
            let selected = fault ?? .duringWeights
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .injectedFailure(.init(
                    directory: directory,
                    fault: selected,
                    publishedLeafBindings: leaves))
        } catch is PrimeDurableArtifactError {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .publicationFailed
        } catch {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .publicationFailed
        }
    }

    public static func load(
        root: PrimeArtifactRoot,
        externalCommitBinding:
            PrimeNativeDecoderTrajectoryExternalCommitBindingV1
    ) throws -> PrimeNativeDecoderTrajectoryLoadedCheckpointV1 {
        do {
            try root.requirePrivateRootMode()
            try validate(externalCommitBinding)
            let leaves = externalCommitBinding.orderedLeafBindings
            let inventory = try root.captureTrustedInventory(
                rolePrefix: externalCommitBinding.directory,
                expectedArtifacts: leaves.map(\.artifact))
            for leaf in leaves {
                _ = try root.verify(leaf.artifact)
            }
            let weights = try root.readVerified(
                leaves[0].artifact,
                maximumByteCount: maximumLeafByteCount)
            let optimizer = try root.readVerified(
                leaves[1].artifact,
                maximumByteCount: maximumLeafByteCount)
            let control = try root.readVerified(
                leaves[2].artifact,
                maximumByteCount: maximumLeafByteCount)
            let manifestData = try root.readVerified(
                leaves[3].artifact,
                maximumByteCount: maximumLeafByteCount)
            guard UInt64(manifestData.count)
                    == externalCommitBinding
                        .commitManifestCanonicalByteCount,
                  PrimeSHA256.hexDigest(of: manifestData)
                    == externalCommitBinding
                        .commitManifestCanonicalSHA256
            else {
                throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                    .invalidCommitManifest
            }
            let manifest = try PrimeCanonicalJSON.decode(
                PrimeNativeDecoderTrajectoryCommitManifestV1.self,
                from: manifestData,
                artifact: leaves[3].artifact.relativePath)
            try validate(manifest, expectedPrecommit: Array(leaves.prefix(3)))
            try validateSafetensors(weights)
            try validateSafetensors(optimizer)
            try validateCanonicalJSON(control)
            _ = try inventory.recaptureAndValidateUnchanged()
            return .init(
                weightsSafetensors: weights,
                optimizerMomentsSafetensors: optimizer,
                controlState: control)
        } catch let error as PrimeNativeDecoderTrajectoryCheckpointV1Error {
            throw error
        } catch is PrimeDurableArtifactError {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .artifactVerificationFailed
        } catch {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error.loadFailed
        }
    }

    /// Proves the descriptor-bound partial state has no named commit and that
    /// every final-name leaf expected before the fault remains exact. Since
    /// publication requires an initially empty root and this codec is the sole
    /// writer, this is the bounded quarantine inventory for the attempt.
    public static func requireQuarantined(
        root: PrimeArtifactRoot,
        quarantine: PrimeNativeDecoderTrajectoryQuarantineV1
    ) throws {
        do {
            try validateDirectory(quarantine.directory)
            let expectedRoles = rolesPublishedBefore(quarantine.fault)
            guard quarantine.publishedLeafBindings.map(\.role)
                    == expectedRoles,
                  quarantine.publishedLeafBindings.map(\.publicationOrdinal)
                    == expectedRoles.indices.map({ $0 + 1 })
            else {
                throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                    .contractDrift
            }
            for leaf in quarantine.publishedLeafBindings {
                _ = try root.verify(leaf.artifact)
            }
            try root.requireAbsent(at: path(
                quarantine.directory,
                commitFileName))
            for role in PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1
                .allCases where !expectedRoles.contains(role)
                    && role != .commitManifest
            {
                try root.requireAbsent(at: path(
                    quarantine.directory,
                    fileName(for: role)))
            }
        } catch let error as PrimeNativeDecoderTrajectoryCheckpointV1Error {
            throw error
        } catch {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .artifactVerificationFailed
        }
    }

    public static func publishedLeafRoles(
        quarantine: PrimeNativeDecoderTrajectoryQuarantineV1
    ) -> [PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1] {
        quarantine.publishedLeafBindings.map(\.role)
    }

    private enum InjectedDuringPublication: Error {
        case failure
    }

    private static func publishLeaf(
        root: PrimeArtifactRoot,
        directory: String,
        fileName: String,
        data: Data,
        during: Bool
    ) throws -> PrimeArtifactBinding {
        let relativePath = path(directory, fileName)
        if !during {
            return try root.publishGeneratedFile(
                at: relativePath,
                purpose: .immutableData,
                maximumByteCount: maximumLeafByteCount
            ) { descriptor in
                try writeAll(data, descriptor: descriptor)
            }
        }
        return try root.publishGeneratedFile(
            at: relativePath,
            purpose: .immutableData,
            maximumByteCount: maximumLeafByteCount
        ) { descriptor in
            let prefixCount = max(1, data.count / 2)
            try writeAll(data.prefix(prefixCount), descriptor: descriptor)
            throw InjectedDuringPublication.failure
        }
    }

    private static func injectAfter(
        _ point: PrimeNativeDecoderTrajectoryCheckpointFaultV1,
        selected: PrimeNativeDecoderTrajectoryCheckpointFaultV1?,
        directory: String,
        leaves: [PrimeNativeDecoderTrajectoryLeafBindingV1]
    ) throws {
        guard selected == point else { return }
        throw PrimeNativeDecoderTrajectoryCheckpointV1Error
            .injectedFailure(.init(
                directory: directory,
                fault: point,
                publishedLeafBindings: leaves))
    }

    private static func validate(
        _ binding: PrimeNativeDecoderTrajectoryExternalCommitBindingV1
    ) throws {
        try validateDirectory(binding.directory)
        let leaves = binding.orderedLeafBindings
        guard binding.schemaVersion == 1,
              binding.schemaID == externalCommitBindingSchemaID,
              leaves.map(\.role)
                == PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1.allCases,
              leaves.map(\.publicationOrdinal) == [1, 2, 3, 4],
              leaves.map(\.artifact.relativePath) == [
                  path(binding.directory, weightsFileName),
                  path(binding.directory, optimizerFileName),
                  path(binding.directory, controlFileName),
                  path(binding.directory, commitFileName),
              ],
              leaves.allSatisfy({ $0.artifact.purpose == .immutableData }),
              binding.commitManifestCanonicalByteCount > 0,
              isLowercaseSHA256(binding.commitManifestCanonicalSHA256),
              binding.commitManifestCanonicalByteCount
                == leaves[3].artifact.byteCount,
              binding.commitManifestCanonicalSHA256
                == leaves[3].artifact.sha256
        else {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .invalidExternalCommitBinding
        }
    }

    private static func validate(
        _ manifest: PrimeNativeDecoderTrajectoryCommitManifestV1,
        expectedPrecommit: [PrimeNativeDecoderTrajectoryLeafBindingV1]
    ) throws {
        guard manifest.schemaVersion == 1,
              manifest.schemaID == checkpointSchemaID,
              manifest.stateScope
                == "tiny_stage3_snapshot_durable_multileaf_mechanics_v1",
              manifest.precommitLeafBindings == expectedPrecommit,
              expectedPrecommit.map(\.role)
                == [.weightsV2, .optimizerMoments, .controlStateManifest],
              manifest.finalCommitManifestIsExclusiveCommitPoint,
              !manifest.partialPrecommitLeavesAreAuthoritative,
              manifest.loadRequiresExternallySuppliedExactCommitBinding
        else {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .invalidCommitManifest
        }
    }

    private static func validateSafetensors(_ data: Data) throws {
        guard data.count >= 10 else {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .invalidSafetensors
        }
        var headerLength: UInt64 = 0
        for index in 0 ..< 8 {
            headerLength |= UInt64(data[index]) << UInt64(index * 8)
        }
        guard headerLength > 1,
              headerLength <= UInt64(data.count - 8),
              headerLength <= maximumLeafByteCount,
              let header = try? JSONSerialization.jsonObject(
                with: data.subdata(in: 8 ..< 8 + Int(headerLength)))
                    as? [String: Any],
              !header.filter({ $0.key != "__metadata__" }).isEmpty
        else {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .invalidSafetensors
        }
        let payloadCount = data.count - 8 - Int(headerLength)
        for (name, raw) in header where name != "__metadata__" {
            guard !name.isEmpty,
                  let tensor = raw as? [String: Any],
                  tensor["dtype"] is String,
                  tensor["shape"] is [Any],
                  let offsets = tensor["data_offsets"] as? [Any],
                  offsets.count == 2,
                  let start = (offsets[0] as? NSNumber)?.intValue,
                  let end = (offsets[1] as? NSNumber)?.intValue,
                  start >= 0,
                  end >= start,
                  end <= payloadCount
            else {
                throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                    .invalidSafetensors
            }
        }
    }

    private static func validateCanonicalJSON(_ data: Data) throws {
        guard let object = try? JSONSerialization.jsonObject(with: data),
              JSONSerialization.isValidJSONObject(object),
              let canonical = try? JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys, .withoutEscapingSlashes]),
              canonical == data
        else {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .nonCanonicalControlState
        }
    }

    private static func validateDirectory(_ directory: String) throws {
        guard !directory.isEmpty,
              directory.utf8.count <= 96,
              directory.utf8.allSatisfy({ byte in
                  (byte >= 48 && byte <= 57)
                      || (byte >= 65 && byte <= 90)
                      || (byte >= 97 && byte <= 122)
                      || byte == 45 || byte == 95
              })
        else {
            throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                .invalidDirectory
        }
    }

    private static func rolesPublishedBefore(
        _ fault: PrimeNativeDecoderTrajectoryCheckpointFaultV1
    ) -> [PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1] {
        switch fault {
        case .duringWeights:
            []
        case .afterWeights, .duringOptimizerMoments:
            [.weightsV2]
        case .afterOptimizerMoments, .duringControlState:
            [.weightsV2, .optimizerMoments]
        case .afterControlState, .duringCommitManifest:
            [.weightsV2, .optimizerMoments, .controlStateManifest]
        }
    }

    private static func fileName(
        for role: PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1
    ) -> String {
        switch role {
        case .weightsV2: weightsFileName
        case .optimizerMoments: optimizerFileName
        case .controlStateManifest: controlFileName
        case .commitManifest: commitFileName
        }
    }

    private static func path(_ directory: String, _ file: String) -> String {
        "\(directory)/\(file)"
    }

    private static func isLowercaseSHA256(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    private static func writeAll<D: DataProtocol>(
        _ data: D,
        descriptor: Int32
    ) throws {
        let bytes = Data(data)
        try bytes.withUnsafeBytes { raw in
            guard let base = raw.baseAddress else { return }
            var offset = 0
            while offset < raw.count {
                let written = Darwin.write(
                    descriptor,
                    base.advanced(by: offset),
                    raw.count - offset)
                if written < 0, errno == EINTR { continue }
                guard written > 0 else {
                    throw PrimeNativeDecoderTrajectoryCheckpointV1Error
                        .publicationFailed
                }
                offset += written
            }
        }
    }
}
