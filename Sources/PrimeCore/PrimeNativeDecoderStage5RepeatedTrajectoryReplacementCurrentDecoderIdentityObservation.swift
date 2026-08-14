// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

public struct
    PrimeNativeDecoderStage5ReplacementIdentityAuthorityClosureV1:
    Codable,
    Equatable,
    Sendable
{
    public let repository: String
    public let ref: String
    public let mergeRevision: String
    public let mergeTree: String
    public let orderedParentRevisions: [String]
    public let reviewedHeadRevision: String
    public let pullRequestNumber: Int
    public let workflowID: Int
    public let workflowName: String
    public let workflowPath: String
    public let workflowRunID: Int
    public let workflowRunNumber: Int
    public let workflowRunAttempt: Int
    public let event: String
    public let checkSuiteID: Int
    public let activeRootJobID: Int
    public let activeRootRunnerLabel: String
    public let activeRootConclusion: String
    public let reviewedMainJobID: Int
    public let reviewedMainRunnerLabel: String
    public let reviewedMainConclusion: String
    public let status: String
    public let conclusion: String
    public let previousAttemptURLWasNull: Bool
    public let exactHeadPushRunCount: Int
    public let rerunCount: Int
    public let retryCount: Int
    public let artifactCount: Int
    public let rootTestCount: Int
    public let rootFailureCount: Int
    public let isolatedGroupTestCounts: [Int]
    public let isolatedTestCount: Int
    public let isolatedFailureCount: Int
    public let focusedWholeTestCount: Int
    public let metalTestCount: Int
    public let metalFailureCount: Int
    public let maintainedRuntimeTestCount: Int
    public let maintainedRuntimeFailureCount: Int
    public let tokenizerTestCount: Int
    public let tokenizerFailureCount: Int
    public let totalTestCount: Int
    public let originalStage5LauncherInvocationCount: Int
    public let originalStage5ReceiptCount: Int
    public let replacementStage5LauncherInvocationCount: Int
    public let replacementStage5ReceiptCount: Int
    public let stage6LauncherInvocationCount: Int
    public let stage6ReceiptCount: Int
    public let executionPureAuthorityClosure: Bool
}

public struct PrimeNativeDecoderStage5ReplacementIdentitySourceBindingV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let gitMode: String
    public let gitBlob: String
    public let byteCount: Int
    public let sha256: String
    public let role: String
}

public struct PrimeNativeDecoderStage5ReplacementIdentityAuthorityBindingV1:
    Codable,
    Equatable,
    Sendable
{
    public let authorityID: String
    public let authorityCanonicalSHA256: String
    public let orderedSourceBindings:
        [PrimeNativeDecoderStage5ReplacementIdentitySourceBindingV1]
    public let successorExactChangedPathCount: Int
    public let currentIdentityObservationAuthorized: Bool
}

public struct PrimeNativeDecoderStage5ReplacementDecoderSourceIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let gitMode: String
    public let gitBlob: String
    public let byteCount: Int
    public let sha256: String
    public let identityRole: String
    public let sourceAuthorityID: String
    public let sourceAuthorityCanonicalSHA256: String
    public let authorizedMutationScope: String
}

public struct PrimeNativeDecoderStage5ReplacementCurrentDecoderIdentityCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let authorityClosureObserved: Bool
    public let currentDecoderImplementationIdentityObserved: Bool
    public let currentDecoderExecutionObserved: Bool
    public let replacementAssayExecutionObserved: Bool
    public let stage5ResultEstablished: Bool
    public let stage5ClearanceEstablished: Bool
    public let defaultGatherPathMutated: Bool
    public let publicDecoderAPIAdded: Bool
    public let checkpointAuthorityReinterpreted: Bool
    public let runtimeAuthorityReinterpreted: Bool
    public let tokenizerAuthorityReinterpreted: Bool
    public let stage6HistoricalResourceClearanceAppliesToBPath: Bool
    public let bSpecificNative300ResourceWitnessEstablished: Bool
    public let stage7AuthorityEstablished: Bool
    public let stage7Authorized: Bool
    public let candidateAdmissionGranted: Bool
    public let modelQualityEstablished: Bool
    public let canaryAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
}

/// Pure, immutable identity observation for the decoder source materialized by
/// the separately authorized Stage-5 A/B replacement successor.
///
/// The exact-main authority closure is already terminal green and remains an
/// execution-pure predecessor. This value advances only the live decoder byte
/// identity from the frozen Stage-2 successor to the package-only opt-in dense
/// one-hot implementation. It performs no MLX, Metal, filesystem, network,
/// assay, checkpoint, training, artifact, or publication operation.
public struct
    PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let authorityClosure:
        PrimeNativeDecoderStage5ReplacementIdentityAuthorityClosureV1
    public let authorityBinding:
        PrimeNativeDecoderStage5ReplacementIdentityAuthorityBindingV1
    public let predecessorDecoder:
        PrimeNativeDecoderStage5ReplacementDecoderSourceIdentityV1
    public let currentDecoder:
        PrimeNativeDecoderStage5ReplacementDecoderSourceIdentityV1
    public let packageOnlyDenseLogitsMethod: String
    public let packageOnlyEmbeddingForwardPairMethod: String
    public let predecessorDecoderIdentityRemainsHistoricalAndFrozen: Bool
    public let currentDecoderIdentityIsSoleRetainedLiveIdentity: Bool
    public let defaultGatherPathRemainsUnchanged: Bool
    public let implementationObservedByThisObservation: Bool
    public let executionObservedByThisObservation: Bool
    public let authorityCeiling:
        PrimeNativeDecoderStage5ReplacementCurrentDecoderIdentityCeilingV1
    public let status: String

    public static let canonicalSHA256 =
        "a8ecffbf0a24cb6970158982811107e216600571976c87f5e7e78f699b8d72b3"

    public static let frozenV1: Self = {
        let authority =
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                .frozenV1
        let stage2 =
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1
                .frozenV1
        let predecessorSurface = stage2.surfaceDesign

        return Self(
            schemaVersion: 1,
            observationID:
                "ergentics_prime_native_decoder_stage5_repeated_trajectory_replacement_current_decoder_identity_observation_v1",
            observationKind:
                "pure_post_authority_pre_execution_current_decoder_source_identity",
            authorityClosure: .init(
                repository: "Ergentics/ergentics-prime",
                ref: "refs/heads/main",
                mergeRevision:
                    "a0ce9561bdbc867b12f13aed7a7f54846faf3020",
                mergeTree:
                    "e7f85dcecbc82b7e74065cc1991175152f53c13f",
                orderedParentRevisions: [
                    "54635d6b58e4f9c7ddedb30a3c22fffb17d8e174",
                    "86869f59b198f99678328d86b3f9555a43be88af",
                ],
                reviewedHeadRevision:
                    "86869f59b198f99678328d86b3f9555a43be88af",
                pullRequestNumber: 109,
                workflowID: 329_017_041,
                workflowName: "Prime Active Root Quarantine",
                workflowPath:
                    ".github/workflows/prime-active-root-quarantine.yml",
                workflowRunID: 31_824_087_086,
                workflowRunNumber: 115,
                workflowRunAttempt: 1,
                event: "push",
                checkSuiteID: 86_338_204_723,
                activeRootJobID: 94_843_969_773,
                activeRootRunnerLabel: "macos-15",
                activeRootConclusion: "success",
                reviewedMainJobID: 94_844_683_376,
                reviewedMainRunnerLabel: "macos-26",
                reviewedMainConclusion: "success",
                status: "completed",
                conclusion: "success",
                previousAttemptURLWasNull: true,
                exactHeadPushRunCount: 1,
                rerunCount: 0,
                retryCount: 0,
                artifactCount: 0,
                rootTestCount: 57,
                rootFailureCount: 0,
                isolatedGroupTestCounts: [1, 1, 2, 2],
                isolatedTestCount: 6,
                isolatedFailureCount: 0,
                focusedWholeTestCount: 63,
                metalTestCount: 44,
                metalFailureCount: 0,
                maintainedRuntimeTestCount: 1,
                maintainedRuntimeFailureCount: 0,
                tokenizerTestCount: 1,
                tokenizerFailureCount: 0,
                totalTestCount: 109,
                originalStage5LauncherInvocationCount: 0,
                originalStage5ReceiptCount: 0,
                replacementStage5LauncherInvocationCount: 0,
                replacementStage5ReceiptCount: 0,
                stage6LauncherInvocationCount: 0,
                stage6ReceiptCount: 0,
                executionPureAuthorityClosure: true),
            authorityBinding: .init(
                authorityID: authority.authorityID,
                authorityCanonicalSHA256:
                    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                        .canonicalSHA256,
                orderedSourceBindings: [
                    .init(
                        path:
                            "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthority.swift",
                        gitMode: "100644",
                        gitBlob:
                            "ded305476edfc832ae4e910b1985da77c7a10cd0",
                        byteCount: 144_935,
                        sha256:
                            "634eabe81f63a570cfe2f565d95befbd8c77ea98ba7864a212f45511c7f8b5fc",
                        role: "frozen_stage5_replacement_execution_authority"),
                    .init(
                        path:
                            "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityTests.swift",
                        gitMode: "100644",
                        gitBlob:
                            "e7e240f6bb6e037f0b41f28d925ce0fcd38c42a7",
                        byteCount: 49_796,
                        sha256:
                            "71506cbc21fb8d03886bdc95500e6249f5d61a59f84569dfda95875289435e08",
                        role:
                            "frozen_exhaustive_stage5_replacement_execution_authority_test"),
                ],
                successorExactChangedPathCount:
                    authority.successorScope.exactChangedPaths.count,
                currentIdentityObservationAuthorized:
                    authority.successorScope
                        .newCurrentIdentityObservationAuthorized),
            predecessorDecoder: .init(
                path: authority.successorScope.decoderSourcePath,
                gitMode:
                    predecessorSurface.currentDecoderSuccessorExpectedGitMode,
                gitBlob:
                    predecessorSurface.currentDecoderSuccessorExpectedGitBlob,
                byteCount:
                    predecessorSurface.currentDecoderSuccessorExpectedByteCount,
                sha256:
                    predecessorSurface.currentDecoderSuccessorExpectedSHA256,
                identityRole:
                    "historical_frozen_stage2_current_decoder_successor",
                sourceAuthorityID: stage2.authorityID,
                sourceAuthorityCanonicalSHA256:
                    "3520f1a778b33be0fad8c8967318b0b4ad8ed86b4746620e0bbf0e6c385f7840",
                authorizedMutationScope:
                    predecessorSurface.currentDecoderSuccessorMutationScope),
            currentDecoder: .init(
                path: authority.successorScope.decoderSourcePath,
                gitMode: "100644",
                gitBlob:
                    "de6cff4472de55a8fafe2962c3be4ca37c972caf",
                byteCount: 43_339,
                sha256:
                    "ec869ee013814c5b9e0228674097fe4d931d52aa119d23ebbc61d40f37cc7adc",
                identityRole:
                    "current_stage5_replacement_package_only_opt_in_decoder",
                sourceAuthorityID: authority.authorityID,
                sourceAuthorityCanonicalSHA256:
                    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                        .canonicalSHA256,
                authorizedMutationScope:
                    authority.successorScope.decoderSourceMutationScope),
            packageOnlyDenseLogitsMethod:
                "trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
            packageOnlyEmbeddingForwardPairMethod:
                "trainingInputEmbeddingForwardPairForFlattenedDenseOneHotMatmulAssayV1",
            predecessorDecoderIdentityRemainsHistoricalAndFrozen: true,
            currentDecoderIdentityIsSoleRetainedLiveIdentity: true,
            defaultGatherPathRemainsUnchanged: true,
            implementationObservedByThisObservation: true,
            executionObservedByThisObservation: false,
            authorityCeiling: .init(
                authorityClosureObserved: true,
                currentDecoderImplementationIdentityObserved: true,
                currentDecoderExecutionObserved: false,
                replacementAssayExecutionObserved: false,
                stage5ResultEstablished: false,
                stage5ClearanceEstablished: false,
                defaultGatherPathMutated: false,
                publicDecoderAPIAdded: false,
                checkpointAuthorityReinterpreted: false,
                runtimeAuthorityReinterpreted: false,
                tokenizerAuthorityReinterpreted: false,
                stage6HistoricalResourceClearanceAppliesToBPath: false,
                bSpecificNative300ResourceWitnessEstablished: false,
                stage7AuthorityEstablished: false,
                stage7Authorized: false,
                candidateAdmissionGranted: false,
                modelQualityEstablished: false,
                canaryAuthorized: false,
                quantizationAuthorized: false,
                productUseAuthorized: false,
                publicationAuthorized: false),
            status:
                "OBSERVED_current_stage5_replacement_decoder_source_identity_only_no_execution_stage5_result_or_stage7_authority")
    }()

    public func canonicalData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let decoder = JSONDecoder()
        let value: Self
        do {
            value = try decoder.decode(Self.self, from: data)
            try value.validateExactV1()
        } catch let error as
            PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationError
        {
            throw error
        } catch {
            throw PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationError
                .noncanonicalEncoding
        }
        guard try value.canonicalData() == data else {
            throw PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationError
                .noncanonicalEncoding
        }
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let authority =
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                .frozenV1
        let stage2 =
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1
                .frozenV1
        let predecessorSurface = stage2.surfaceDesign
        let closure = authorityClosure
        let binding = authorityBinding
        let ceiling = authorityCeiling

        let falseCeilings = [
            ceiling.currentDecoderExecutionObserved,
            ceiling.replacementAssayExecutionObserved,
            ceiling.stage5ResultEstablished,
            ceiling.stage5ClearanceEstablished,
            ceiling.defaultGatherPathMutated,
            ceiling.publicDecoderAPIAdded,
            ceiling.checkpointAuthorityReinterpreted,
            ceiling.runtimeAuthorityReinterpreted,
            ceiling.tokenizerAuthorityReinterpreted,
            ceiling.stage6HistoricalResourceClearanceAppliesToBPath,
            ceiling.bSpecificNative300ResourceWitnessEstablished,
            ceiling.stage7AuthorityEstablished,
            ceiling.stage7Authorized,
            ceiling.candidateAdmissionGranted,
            ceiling.modelQualityEstablished,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              closure.ref == "refs/heads/main",
              closure.orderedParentRevisions.count == 2,
              closure.orderedParentRevisions[1]
                == closure.reviewedHeadRevision,
              closure.workflowRunAttempt == 1,
              closure.event == "push",
              closure.status == "completed",
              closure.conclusion == "success",
              closure.activeRootConclusion == "success",
              closure.reviewedMainConclusion == "success",
              closure.previousAttemptURLWasNull,
              closure.exactHeadPushRunCount == 1,
              closure.rerunCount == 0,
              closure.retryCount == 0,
              closure.artifactCount == 0,
              closure.rootFailureCount == 0,
              closure.isolatedTestCount
                == closure.isolatedGroupTestCounts.reduce(0, +),
              closure.isolatedFailureCount == 0,
              closure.focusedWholeTestCount
                == closure.rootTestCount + closure.isolatedTestCount,
              closure.totalTestCount
                == closure.focusedWholeTestCount
                    + closure.metalTestCount
                    + closure.maintainedRuntimeTestCount
                    + closure.tokenizerTestCount,
              closure.totalTestCount == 109,
              closure.metalFailureCount == 0,
              closure.maintainedRuntimeFailureCount == 0,
              closure.tokenizerFailureCount == 0,
              closure.originalStage5LauncherInvocationCount == 0,
              closure.originalStage5ReceiptCount == 0,
              closure.replacementStage5LauncherInvocationCount == 0,
              closure.replacementStage5ReceiptCount == 0,
              closure.stage6LauncherInvocationCount == 0,
              closure.stage6ReceiptCount == 0,
              closure.executionPureAuthorityClosure,
              binding.authorityID == authority.authorityID,
              binding.authorityCanonicalSHA256
                == PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                    .canonicalSHA256,
              binding.orderedSourceBindings.map(\.path)
                == [
                    "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthority.swift",
                    "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityTests.swift",
                ],
              binding.orderedSourceBindings.allSatisfy({ source in
                  source.gitMode == "100644"
                    && source.gitBlob.utf8.count == 40
                    && source.byteCount > 0
                    && source.sha256.utf8.count == 64
                    && !source.role.isEmpty
              }),
              binding.successorExactChangedPathCount
                == authority.successorScope.exactChangedPaths.count,
              binding.successorExactChangedPathCount == 10,
              binding.currentIdentityObservationAuthorized,
              predecessorDecoder.path
                == authority.successorScope.decoderSourcePath,
              predecessorDecoder.gitMode
                == predecessorSurface.currentDecoderSuccessorExpectedGitMode,
              predecessorDecoder.gitBlob
                == predecessorSurface.currentDecoderSuccessorExpectedGitBlob,
              predecessorDecoder.byteCount
                == predecessorSurface.currentDecoderSuccessorExpectedByteCount,
              predecessorDecoder.sha256
                == predecessorSurface.currentDecoderSuccessorExpectedSHA256,
              predecessorDecoder.sourceAuthorityID == stage2.authorityID,
              predecessorDecoder.sourceAuthorityCanonicalSHA256
                == PrimeSHA256.hexDigest(
                    of: try stage2.canonicalData()),
              predecessorDecoder.authorizedMutationScope
                == predecessorSurface.currentDecoderSuccessorMutationScope,
              currentDecoder.path == predecessorDecoder.path,
              currentDecoder.gitMode == predecessorDecoder.gitMode,
              currentDecoder.sourceAuthorityID == authority.authorityID,
              currentDecoder.sourceAuthorityCanonicalSHA256
                == binding.authorityCanonicalSHA256,
              currentDecoder.authorizedMutationScope
                == authority.successorScope.decoderSourceMutationScope,
              packageOnlyDenseLogitsMethod
                == "trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
              packageOnlyEmbeddingForwardPairMethod
                == "trainingInputEmbeddingForwardPairForFlattenedDenseOneHotMatmulAssayV1",
              predecessorDecoderIdentityRemainsHistoricalAndFrozen,
              currentDecoderIdentityIsSoleRetainedLiveIdentity,
              defaultGatherPathRemainsUnchanged,
              implementationObservedByThisObservation,
              !executionObservedByThisObservation,
              ceiling.authorityClosureObserved,
              ceiling.currentDecoderImplementationIdentityObserved,
              falseCeilings.allSatisfy({ !$0 }),
              status
                == "OBSERVED_current_stage5_replacement_decoder_source_identity_only_no_execution_stage5_result_or_stage7_authority"
        else {
            throw PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationError
                .contractDrift
        }

        guard PrimeSHA256.hexDigest(of: try canonicalData())
            == Self.canonicalSHA256
        else {
            throw PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationError
                .contractDrift
        }
    }
}
