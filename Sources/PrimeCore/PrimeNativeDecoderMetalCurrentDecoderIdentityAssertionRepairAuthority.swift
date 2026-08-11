// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

public struct
    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairFailureConsumptionV1:
    Codable,
    Equatable,
    Sendable
{
    public let failureObservationID: String
    public let failureObservationCanonicalSHA256: String
    public let repository: String
    public let mergeRevision: String
    public let mergeTree: String
    public let orderedParentRevisions: [String]
    public let pullRequestNumber: Int
    public let runID: Int
    public let runNumber: Int
    public let runAttempt: Int
    public let activeRootJobID: Int
    public let reviewedMainJobID: Int
    public let securePrivateDependencyFetchCompleted: Bool
    public let focusedRootRequiredTestCount: Int
    public let focusedRootCompletedTestCount: Int
    public let focusedRootFailureCount: Int
    public let focusedRootSkipCount: Int
    public let freshDefaultMetallibObserved: Bool
    public let freshDefaultMetallibByteCount: Int
    public let freshDefaultMetallibSHA256: String
    public let requiredMetalTestCount: Int
    public let completedMetalTestCount: Int
    public let passedMetalTestCaseCount: Int
    public let failedMetalTestCaseCount: Int
    public let assertionFailureCount: Int
    public let metalSkipCount: Int
    public let failedTestClass: String
    public let failedTestMethod: String
    public let staleByteCountAssertionSourceLine: Int
    public let staleSHA256AssertionSourceLine: Int
    public let observedDecoderByteCount: Int
    public let staleHistoricalExpectedDecoderByteCount: Int
    public let observedDecoderSHA256: String
    public let staleHistoricalExpectedDecoderSHA256: String
    public let runtimeInvocationCount: Int
    public let runtimeReceiptCount: Int
    public let tokenizerInvocationCount: Int
    public let tokenizerReceiptCount: Int
    public let processExitCode: Int
    public let actionsArtifactsTotalCount: Int
    public let actionsArtifactsArrayExactlyEmpty: Bool
    public let rerunCount: Int
    public let runConsumedAsTerminalFailureEvidence: Bool
    public let runRecoveryOrReinterpretationAuthorized: Bool
}

public struct
    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairHistoricalPlanV1:
    Codable,
    Equatable,
    Sendable
{
    public let authorityID: String
    public let sourcePath: String
    public let sourceGitMode: String
    public let sourceGitBlob: String
    public let sourceByteCount: Int
    public let sourceSHA256: String
    public let repairedDecoderSourcePath: String
    public let repairedDecoderSourceGitMode: String
    public let repairedDecoderSourceGitBlob: String
    public let repairedDecoderSourceByteCount: Int
    public let repairedDecoderSourceSHA256: String
    public let validateExactlyRequired: Bool
    public let remainsFrozen: Bool
    public let identityRemainsHistorical: Bool
    public let isCurrentDecoderIdentity: Bool
    public let mutationAuthorized: Bool
    public let reinterpretationAuthorized: Bool
}

public struct
    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairCurrentDecoderV1:
    Codable,
    Equatable,
    Sendable
{
    public let sourceAuthorityID: String
    public let sourceAuthorityCanonicalSHA256: String
    public let sourceAuthorityPath: String
    public let sourceAuthorityGitMode: String
    public let sourceAuthorityGitBlob: String
    public let sourceAuthorityByteCount: Int
    public let sourceAuthoritySHA256: String
    public let decoderSourcePath: String
    public let mutationScope: String
    public let expectedGitMode: String
    public let expectedGitBlob: String
    public let expectedByteCount: Int
    public let expectedSHA256: String
    public let predecessorDecoderIdentityRemainsHistoricalAndFrozen: Bool
    public let stage2SurfaceDesignIsCurrentDecoderIdentitySource: Bool
    public let packageOnlyTrainingLogitsNoCacheSeamIsSoleIdentityDelta: Bool
    public let publicDecoderAPIAdded: Bool
    public let checkpointRuntimeOrTokenizerAuthorityReinterpreted: Bool
}

public struct
    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairTestPatchV1:
    Codable,
    Equatable,
    Sendable
{
    public let sourcePath: String
    public let predecessorGitMode: String
    public let predecessorGitBlob: String
    public let predecessorByteCount: Int
    public let predecessorSHA256: String
    public let repairedGitMode: String
    public let repairedGitBlob: String
    public let repairedByteCount: Int
    public let repairedSHA256: String
    public let testClass: String
    public let repairedTestMethod: String
    public let authorityTestClassMethodCount: Int
    public let requiredMetalAuthorityTestCount: Int
    public let requiredMetalCheckpointTestCount: Int
    public let requiredMetalDecoderTestCount: Int
    public let requiredMetalTotalTestCount: Int
    public let historicalPlanValidationCallCount: Int
    public let historicalPlanRepairedDecoderLiteralAssertionCount: Int
    public let liveHistoricalPlanIdentityAssertionCount: Int
    public let liveStage2SuccessorIdentityAssertionCount: Int
    public let gitBlobObjectFormat: String
    public let gitBlobFrame: String
    public let cryptoKitSHA1ForPureGitBlobFramingAuthorized: Bool
    public let testCountChangeAuthorized: Bool
    public let testMethodAdditionAuthorized: Bool
    public let testMethodRemovalAuthorized: Bool
    public let productionTargetChangeAuthorized: Bool
}

public struct
    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let failureObservationMutationAuthorized: Bool
    public let historicalMetalRepairPlanMutationAuthorized: Bool
    public let historicalMetalRepairPlanReinterpretationAuthorized: Bool
    public let decoderSourceMutationAuthorized: Bool
    public let stage2AuthorityMutationAuthorized: Bool
    public let packageManifestMutationAuthorized: Bool
    public let packageLockMutationAuthorized: Bool
    public let workflowMutationAuthorized: Bool
    public let activeGateMutationAuthorized: Bool
    public let metalLauncherMutationAuthorized: Bool
    public let secureFetchMutationAuthorized: Bool
    public let TLSVerificationBypassAuthorized: Bool
    public let customCAInstallationAuthorized: Bool
    public let retryAuthorized: Bool
    public let rerunAuthorized: Bool
    public let failedRunRecoveryAuthorized: Bool
    public let replacementExecutionAuthorizedByThisAuthority: Bool
    public let defaultMetallibRepairAuthorized: Bool
    public let metalExecutionEstablishedByThisAuthority: Bool
    public let runtimeExecutionEstablishedByThisAuthority: Bool
    public let tokenizerExecutionEstablishedByThisAuthority: Bool
    public let stage2ExecutionAuthorized: Bool
    public let stage2BootstrapRepairAuthorized: Bool
    public let stage2SuccessEstablished: Bool
    public let stage3AuthorityEstablished: Bool
    public let checkpointReadAuthorized: Bool
    public let checkpointWriteAuthorized: Bool
    public let checkpointArtifactAuthorized: Bool
    public let checkpointResumeAuthorized: Bool
    public let metalTensorExecutionAuthorized: Bool
    public let native300MAllocationAuthorized: Bool
    public let native300MTrainingAuthorized: Bool
    public let trajectoryResumeAuthorized: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
}

/// Narrow, append-only authority for correcting one stale live-source
/// assertion boundary in the frozen 44-test Metal suite.
///
/// The historical Metal repair plan remains byte-for-byte frozen and keeps
/// describing the decoder identity it originally authorized. The later
/// Stage-2 authority already introduced one package-only rank-two Int32
/// no-cache training seam and is the exact source of the current decoder
/// successor identity. The consumed hosted run proved that the old plan's
/// identity was being applied to the later live source: all 44 tests ran, and
/// the sole failed test emitted only the expected byte-count and SHA-256
/// mismatches. This authority permits repairing those live assertions and
/// adding their pure Git-blob check; it grants no source, workflow, execution,
/// retry, recovery, checkpoint, training, or downstream authority.
public struct
    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let failureConsumption:
        PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairFailureConsumptionV1
    public let historicalMetalRepairPlan:
        PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairHistoricalPlanV1
    public let currentDecoderSuccessor:
        PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairCurrentDecoderV1
    public let authorizedTestPatch:
        PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairTestPatchV1
    public let testOnlyCurrentDecoderIdentityAssertionRepairAuthorized: Bool
    public let materializedRepairSourceIdentityBound: Bool
    public let historicalPlanIdentityPreserved: Bool
    public let currentDecoderIdentityResolvedThroughStage2SurfaceDesign: Bool
    public let implementationObservedByThisAuthority: Bool
    public let executionObservedByThisAuthority: Bool
    public let authorityCeiling:
        PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairCeilingV1
    public let status: String
    public let orderedRequiredSeparateActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "ergentics_prime_native_decoder_metal_current_decoder_identity_assertion_repair_authority_v1",
        authorityKind:
            "test_only_historical_plan_to_current_stage2_decoder_identity_assertion_repair",
        failureConsumption:
            PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairFailureConsumptionV1(
                failureObservationID:
                    "ergentics_prime_native_decoder_metal_current_decoder_identity_assertion_failure_observation_v1",
                failureObservationCanonicalSHA256:
                    "7d1d90667fdba0171b4c6b98431b7fd045fe5d2c11bd640689bb4bda6dde3424",
                repository: "Ergentics/ergentics-prime",
                mergeRevision:
                    "2d0464ca35212d3d84781654b6a4e08158f27eab",
                mergeTree:
                    "be66df2affb85e2d846ba6f5f51e540d17864796",
                orderedParentRevisions: [
                    "e540b73f6a46cf6e0de5b932d7167f178d4ac6fb",
                    "5198f5da94977d11f5fcfabf65bb55a62cb31f26",
                ],
                pullRequestNumber: 85,
                runID: 31_533_658_617,
                runNumber: 67,
                runAttempt: 1,
                activeRootJobID: 93_919_471_247,
                reviewedMainJobID: 93_920_049_786,
                securePrivateDependencyFetchCompleted: true,
                focusedRootRequiredTestCount: 36,
                focusedRootCompletedTestCount: 36,
                focusedRootFailureCount: 0,
                focusedRootSkipCount: 0,
                freshDefaultMetallibObserved: true,
                freshDefaultMetallibByteCount: 6_292_732,
                freshDefaultMetallibSHA256:
                    "53aa69728711f18cdf0886e2397bc1f8777b02c00d2235f83c03f71599470083",
                requiredMetalTestCount: 44,
                completedMetalTestCount: 44,
                passedMetalTestCaseCount: 43,
                failedMetalTestCaseCount: 1,
                assertionFailureCount: 2,
                metalSkipCount: 0,
                failedTestClass: "PrimeNativeDecoderAuthorityTests",
                failedTestMethod:
                    "testMetalRepairAuthorityIsAppendOnlyAndSourceExact",
                staleByteCountAssertionSourceLine: 338,
                staleSHA256AssertionSourceLine: 339,
                observedDecoderByteCount: 39_598,
                staleHistoricalExpectedDecoderByteCount: 39_050,
                observedDecoderSHA256:
                    "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994",
                staleHistoricalExpectedDecoderSHA256:
                    "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b",
                runtimeInvocationCount: 0,
                runtimeReceiptCount: 0,
                tokenizerInvocationCount: 0,
                tokenizerReceiptCount: 0,
                processExitCode: 2,
                actionsArtifactsTotalCount: 0,
                actionsArtifactsArrayExactlyEmpty: true,
                rerunCount: 0,
                runConsumedAsTerminalFailureEvidence: true,
                runRecoveryOrReinterpretationAuthorized: false),
        historicalMetalRepairPlan:
            PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairHistoricalPlanV1(
                authorityID:
                    "ergentics_prime_native_decoder_metal_repair_v1",
                sourcePath:
                    "Sources/PrimeCore/PrimeNativeDecoderMetalRepairAuthority.swift",
                sourceGitMode: "100644",
                sourceGitBlob:
                    "f284cb6d9bfdd37add9273f3e0eecd69e13cd134",
                sourceByteCount: 26_865,
                sourceSHA256:
                    "5e88a1a191f94daac01f86e5dbad48ebfcdd50957ac17acf6f404ac8dd0a97ac",
                repairedDecoderSourcePath:
                    "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                repairedDecoderSourceGitMode: "100644",
                repairedDecoderSourceGitBlob:
                    "835a4826549e1f28ec27e3533f746218beb3bdf2",
                repairedDecoderSourceByteCount: 39_050,
                repairedDecoderSourceSHA256:
                    "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b",
                validateExactlyRequired: true,
                remainsFrozen: true,
                identityRemainsHistorical: true,
                isCurrentDecoderIdentity: false,
                mutationAuthorized: false,
                reinterpretationAuthorized: false),
        currentDecoderSuccessor:
            PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairCurrentDecoderV1(
                sourceAuthorityID:
                    "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_authority_v1",
                sourceAuthorityCanonicalSHA256:
                    "3520f1a778b33be0fad8c8967318b0b4ad8ed86b4746620e0bbf0e6c385f7840",
                sourceAuthorityPath:
                    "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthority.swift",
                sourceAuthorityGitMode: "100644",
                sourceAuthorityGitBlob:
                    "c24af7fab204b8139e4d6f919e9c04ade48bfe6b",
                sourceAuthorityByteCount: 98_327,
                sourceAuthoritySHA256:
                    "ed0f66770a3cf772af264c5bd7f592a433ee48574d80f98664bc8421c32db5e1",
                decoderSourcePath:
                    "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                mutationScope:
                    "exact_package_only_rank2_int32_no_cache_training_logits_seam_only",
                expectedGitMode: "100644",
                expectedGitBlob:
                    "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f",
                expectedByteCount: 39_598,
                expectedSHA256:
                    "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994",
                predecessorDecoderIdentityRemainsHistoricalAndFrozen: true,
                stage2SurfaceDesignIsCurrentDecoderIdentitySource: true,
                packageOnlyTrainingLogitsNoCacheSeamIsSoleIdentityDelta: true,
                publicDecoderAPIAdded: false,
                checkpointRuntimeOrTokenizerAuthorityReinterpreted: false),
        authorizedTestPatch:
            PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairTestPatchV1(
                sourcePath:
                    "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift",
                predecessorGitMode: "100644",
                predecessorGitBlob:
                    "25b7c9b99e789988fb7362b73a41d35eafba406d",
                predecessorByteCount: 34_555,
                predecessorSHA256:
                    "28b146996a0dede2e6cd8e6d8116641a3a398bc5f845051a75cbbc977e9f48fe",
                repairedGitMode: "100644",
                repairedGitBlob:
                    "329e57a8cbb2aa55879a94c88b17c391d13a1eb4",
                repairedByteCount: 35_548,
                repairedSHA256:
                    "40c65bd0169ed5af08248acb38b5b287a82894fec8e8f2c2808f348e3cd50373",
                testClass: "PrimeNativeDecoderAuthorityTests",
                repairedTestMethod:
                    "testMetalRepairAuthorityIsAppendOnlyAndSourceExact",
                authorityTestClassMethodCount: 11,
                requiredMetalAuthorityTestCount: 11,
                requiredMetalCheckpointTestCount: 14,
                requiredMetalDecoderTestCount: 19,
                requiredMetalTotalTestCount: 44,
                historicalPlanValidationCallCount: 1,
                historicalPlanRepairedDecoderLiteralAssertionCount: 3,
                liveHistoricalPlanIdentityAssertionCount: 0,
                liveStage2SuccessorIdentityAssertionCount: 3,
                gitBlobObjectFormat: "sha1",
                gitBlobFrame: "blob <byte_count>\\0<payload>",
                cryptoKitSHA1ForPureGitBlobFramingAuthorized: true,
                testCountChangeAuthorized: false,
                testMethodAdditionAuthorized: false,
                testMethodRemovalAuthorized: false,
                productionTargetChangeAuthorized: false),
        testOnlyCurrentDecoderIdentityAssertionRepairAuthorized: true,
        materializedRepairSourceIdentityBound: true,
        historicalPlanIdentityPreserved: true,
        currentDecoderIdentityResolvedThroughStage2SurfaceDesign: true,
        implementationObservedByThisAuthority: true,
        executionObservedByThisAuthority: false,
        authorityCeiling:
            PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairCeilingV1(
                failureObservationMutationAuthorized: false,
                historicalMetalRepairPlanMutationAuthorized: false,
                historicalMetalRepairPlanReinterpretationAuthorized: false,
                decoderSourceMutationAuthorized: false,
                stage2AuthorityMutationAuthorized: false,
                packageManifestMutationAuthorized: false,
                packageLockMutationAuthorized: false,
                workflowMutationAuthorized: false,
                activeGateMutationAuthorized: false,
                metalLauncherMutationAuthorized: false,
                secureFetchMutationAuthorized: false,
                TLSVerificationBypassAuthorized: false,
                customCAInstallationAuthorized: false,
                retryAuthorized: false,
                rerunAuthorized: false,
                failedRunRecoveryAuthorized: false,
                replacementExecutionAuthorizedByThisAuthority: false,
                defaultMetallibRepairAuthorized: false,
                metalExecutionEstablishedByThisAuthority: false,
                runtimeExecutionEstablishedByThisAuthority: false,
                tokenizerExecutionEstablishedByThisAuthority: false,
                stage2ExecutionAuthorized: false,
                stage2BootstrapRepairAuthorized: false,
                stage2SuccessEstablished: false,
                stage3AuthorityEstablished: false,
                checkpointReadAuthorized: false,
                checkpointWriteAuthorized: false,
                checkpointArtifactAuthorized: false,
                checkpointResumeAuthorized: false,
                metalTensorExecutionAuthorized: false,
                native300MAllocationAuthorized: false,
                native300MTrainingAuthorized: false,
                trajectoryResumeAuthorized: false,
                modelQualityEstablished: false,
                candidateAdmissionGranted: false,
                trialAuthorized: false,
                canaryReplacementAuthorized: false,
                quantizationAuthorized: false,
                productUseAuthorized: false,
                publicationAuthorized: false),
        status:
            "AUTHORIZED_test_only_metal_current_decoder_identity_assertion_repair_preserve_historical_plan_bind_stage2_successor_no_run_recovery_or_downstream_authority",
        orderedRequiredSeparateActions: [
            "preserve_run_31533658617_attempt_1_as_terminal_failure_evidence",
            "preserve_the_historical_metal_repair_plan_without_reinterpretation",
            "validate_only_the_materialized_44_test_assertion_repair_against_the_stage2_current_decoder_successor_identity",
            "require_distinct_exact_main_root38_then_metal44_then_runtime1_then_tokenizer1_before_any_new_success_observation",
            "keep_stage2_retired_and_stage3_blocked_pending_separate_default_metallib_bootstrap_repair_authority",
        ])

    public func canonicalData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw
                PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityError
                    .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let failure =
            PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationV1
                .frozenV1
        let historical = PrimeNativeDecoderMetalRepairAuthorityPlan.frozenV1
        let stage2 =
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1
                .frozenV1
        do {
            try failure.validateExactV1()
            try historical.validate()
            try stage2.validateExactV1()
        } catch {
            throw
                PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityError
                    .contractDrift
        }

        let failureHash: String
        let stage2Hash: String
        do {
            failureHash = PrimeSHA256.hexDigest(
                of: try failure.canonicalData())
            stage2Hash = PrimeSHA256.hexDigest(
                of: try stage2.canonicalData())
        } catch {
            throw
                PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityError
                    .contractDrift
        }
        let consumed = failureConsumption
        let historicalIdentity = historicalMetalRepairPlan
        let current = currentDecoderSuccessor
        let patch = authorizedTestPatch
        let stage2Surface = stage2.surfaceDesign
        let ceiling = authorityCeiling
        let falseClaims = [
            ceiling.failureObservationMutationAuthorized,
            ceiling.historicalMetalRepairPlanMutationAuthorized,
            ceiling.historicalMetalRepairPlanReinterpretationAuthorized,
            ceiling.decoderSourceMutationAuthorized,
            ceiling.stage2AuthorityMutationAuthorized,
            ceiling.packageManifestMutationAuthorized,
            ceiling.packageLockMutationAuthorized,
            ceiling.workflowMutationAuthorized,
            ceiling.activeGateMutationAuthorized,
            ceiling.metalLauncherMutationAuthorized,
            ceiling.secureFetchMutationAuthorized,
            ceiling.TLSVerificationBypassAuthorized,
            ceiling.customCAInstallationAuthorized,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.failedRunRecoveryAuthorized,
            ceiling.replacementExecutionAuthorizedByThisAuthority,
            ceiling.defaultMetallibRepairAuthorized,
            ceiling.metalExecutionEstablishedByThisAuthority,
            ceiling.runtimeExecutionEstablishedByThisAuthority,
            ceiling.tokenizerExecutionEstablishedByThisAuthority,
            ceiling.stage2ExecutionAuthorized,
            ceiling.stage2BootstrapRepairAuthorized,
            ceiling.stage2SuccessEstablished,
            ceiling.stage3AuthorityEstablished,
            ceiling.checkpointReadAuthorized,
            ceiling.checkpointWriteAuthorized,
            ceiling.checkpointArtifactAuthorized,
            ceiling.checkpointResumeAuthorized,
            ceiling.metalTensorExecutionAuthorized,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.trajectoryResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryReplacementAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              consumed.failureObservationID == failure.observationID,
              consumed.failureObservationCanonicalSHA256 == failureHash,
              consumed.orderedParentRevisions.count == 2,
              consumed.runAttempt == 1,
              consumed.securePrivateDependencyFetchCompleted,
              consumed.focusedRootRequiredTestCount == 36,
              consumed.focusedRootCompletedTestCount == 36,
              consumed.focusedRootFailureCount == 0,
              consumed.focusedRootSkipCount == 0,
              consumed.freshDefaultMetallibObserved,
              consumed.requiredMetalTestCount == 44,
              consumed.completedMetalTestCount == 44,
              consumed.passedMetalTestCaseCount == 43,
              consumed.failedMetalTestCaseCount == 1,
              consumed.assertionFailureCount == 2,
              consumed.metalSkipCount == 0,
              consumed.passedMetalTestCaseCount
                + consumed.failedMetalTestCaseCount
                == consumed.completedMetalTestCount,
              consumed.runtimeInvocationCount == 0,
              consumed.runtimeReceiptCount == 0,
              consumed.tokenizerInvocationCount == 0,
              consumed.tokenizerReceiptCount == 0,
              consumed.actionsArtifactsTotalCount == 0,
              consumed.actionsArtifactsArrayExactlyEmpty,
              consumed.rerunCount == 0,
              consumed.runConsumedAsTerminalFailureEvidence,
              !consumed.runRecoveryOrReinterpretationAuthorized,
              historicalIdentity.authorityID == historical.authorityID,
              historicalIdentity.repairedDecoderSourcePath
                == historical.repairedDecoderSourcePath,
              historicalIdentity.repairedDecoderSourceGitBlob
                == historical.repairedDecoderSourceGitBlob,
              historicalIdentity.repairedDecoderSourceByteCount
                == historical.repairedDecoderSourceByteCount,
              historicalIdentity.repairedDecoderSourceSHA256
                == historical.repairedDecoderSourceSHA256,
              historicalIdentity.validateExactlyRequired,
              historicalIdentity.remainsFrozen,
              historicalIdentity.identityRemainsHistorical,
              !historicalIdentity.isCurrentDecoderIdentity,
              !historicalIdentity.mutationAuthorized,
              !historicalIdentity.reinterpretationAuthorized,
              current.sourceAuthorityID == stage2.authorityID,
              current.sourceAuthorityCanonicalSHA256 == stage2Hash,
              current.decoderSourcePath
                == historical.repairedDecoderSourcePath,
              current.mutationScope
                == stage2Surface.currentDecoderSuccessorMutationScope,
              current.expectedGitMode
                == stage2Surface.currentDecoderSuccessorExpectedGitMode,
              current.expectedGitBlob
                == stage2Surface.currentDecoderSuccessorExpectedGitBlob,
              current.expectedByteCount
                == stage2Surface.currentDecoderSuccessorExpectedByteCount,
              current.expectedSHA256
                == stage2Surface.currentDecoderSuccessorExpectedSHA256,
              current.predecessorDecoderIdentityRemainsHistoricalAndFrozen,
              current.stage2SurfaceDesignIsCurrentDecoderIdentitySource,
              current.packageOnlyTrainingLogitsNoCacheSeamIsSoleIdentityDelta,
              !current.publicDecoderAPIAdded,
              !current.checkpointRuntimeOrTokenizerAuthorityReinterpreted,
              patch.predecessorGitMode == "100644",
              patch.repairedGitMode == patch.predecessorGitMode,
              patch.authorityTestClassMethodCount == 11,
              patch.requiredMetalAuthorityTestCount == 11,
              patch.requiredMetalCheckpointTestCount == 14,
              patch.requiredMetalDecoderTestCount == 19,
              patch.requiredMetalAuthorityTestCount
                + patch.requiredMetalCheckpointTestCount
                + patch.requiredMetalDecoderTestCount
                == patch.requiredMetalTotalTestCount,
              patch.requiredMetalTotalTestCount == 44,
              patch.historicalPlanValidationCallCount == 1,
              patch.historicalPlanRepairedDecoderLiteralAssertionCount == 3,
              patch.liveHistoricalPlanIdentityAssertionCount == 0,
              patch.liveStage2SuccessorIdentityAssertionCount == 3,
              patch.gitBlobObjectFormat == "sha1",
              patch.cryptoKitSHA1ForPureGitBlobFramingAuthorized,
              !patch.testCountChangeAuthorized,
              !patch.testMethodAdditionAuthorized,
              !patch.testMethodRemovalAuthorized,
              !patch.productionTargetChangeAuthorized,
              testOnlyCurrentDecoderIdentityAssertionRepairAuthorized,
              materializedRepairSourceIdentityBound,
              historicalPlanIdentityPreserved,
              currentDecoderIdentityResolvedThroughStage2SurfaceDesign,
              implementationObservedByThisAuthority,
              !executionObservedByThisAuthority,
              falseClaims.allSatisfy({ !$0 }),
              orderedRequiredSeparateActions.count == 5
        else {
            throw
                PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionRepairAuthorityError
                    .contractDrift
        }
    }
}
