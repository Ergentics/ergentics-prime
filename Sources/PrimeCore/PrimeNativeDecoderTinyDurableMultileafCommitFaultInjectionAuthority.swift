// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case nonCanonicalEncoding
}

public enum PrimeNativeDecoderTinyDurableMultileafLeafRoleV1:
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

public enum PrimeNativeDecoderTinyDurableMultileafFaultPointV1:
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

public struct PrimeNativeDecoderTinyDurableMultileafRepositoryV1:
    Codable,
    Equatable,
    Sendable
{
    public let repository: String
    public let ref: String
    public let stage3RetirementMergeRevision: String
    public let stage3RetirementTree: String
    public let orderedParentRevisions: [String]
    public let embeddedSourceIdentitySHA256: String
    public let designAuthorityCanonicalSHA256: String
    public let designAuthoritySourceGitBlob: String
    public let designAuthoritySourceSHA256: String
    public let designAuthorityTestGitBlob: String
    public let designAuthorityTestSHA256: String
    public let stage3AuthorityCanonicalSHA256: String
    public let stage3ObservationCanonicalSHA256: String
    public let stage3ObservationSourceGitBlob: String
    public let stage3ObservationSourceSHA256: String
    public let stage3ObservationTestGitBlob: String
    public let stage3ObservationTestSHA256: String
    public let stage3LauncherGitBlob: String
    public let stage3LauncherSHA256: String
    public let stage3RetirementMergeIsCurrentAuthorityBase: Bool
    public let authorityMustMergeAndPassExactMainBeforeImplementation: Bool
    public let implementationMustBindFinalAuthorityMergeAndTree: Bool
}

public struct PrimeNativeDecoderTinyDurableMultileafPredecessorV1:
    Codable,
    Equatable,
    Sendable
{
    public let stage3ExecutionRunID: Int
    public let stage3ExecutionRunNumber: Int
    public let stage3ExecutionRunAttempt: Int
    public let stage3ExecutionRerunCount: Int
    public let stage3ExecutionArtifactCount: Int
    public let stage3ExecutionRootTestCount: Int
    public let stage3ExecutionIsolatedTestCount: Int
    public let stage3ExecutionMetalTestCount: Int
    public let stage3ExecutionRuntimeTestCount: Int
    public let stage3ExecutionTokenizerTestCount: Int
    public let stage3ExecutionStartedCount: Int
    public let stage3ExecutionPassedCount: Int
    public let stage3ExecutionFailureCount: Int
    public let stage3ExecutionSkipCount: Int
    public let stage3ReceiptSHA256: String
    public let retirementRunID: Int
    public let retirementRunNumber: Int
    public let retirementRunAttempt: Int
    public let retirementCheckSuiteID: Int
    public let retirementActiveJobID: Int
    public let retirementReviewedJobID: Int
    public let retirementExactHeadPushRunCount: Int
    public let retirementRerunCount: Int
    public let retirementArtifactCount: Int
    public let retirementRootTestCount: Int
    public let retirementMetalTestCount: Int
    public let retirementRuntimeTestCount: Int
    public let retirementTokenizerTestCount: Int
    public let retirementStage3InvocationCount: Int
    public let retirementStage3ReceiptCount: Int
    public let stage3MechanicsEstablished: Bool
    public let stage3InvocationRetired: Bool
    public let stage3LauncherPreservedForAudit: Bool
}

public struct PrimeNativeDecoderTinyDurableMultileafRoadmapV1:
    Codable,
    Equatable,
    Sendable
{
    public let stageID: String
    public let objective: String
    public let requiredPredecessorStageID: String
    public let nextStageID: String
    public let separateStage4AuthorityRequired: Bool
    public let stage5RequiresSeparateAuthority: Bool
}

public struct PrimeNativeDecoderTinyDurableMultileafSnapshotV1:
    Codable,
    Equatable,
    Sendable
{
    public let sourceSnapshotType: String
    public let snapshotGlobalStep: Int
    public let modelTensorCount: Int
    public let firstMomentTensorCount: Int
    public let secondMomentTensorCount: Int
    public let optimizerMomentTensorCount: Int
    public let weightsLeafEncoding: String
    public let weightsRoleSemantics: String
    public let optimizerMomentsLeafEncoding: String
    public let controlStateLeafEncoding: String
    public let commitManifestEncoding: String
    public let tinyFixtureSafetensorsEncodingAuthorized: Bool
    public let native300MPublicV2CodecUseAuthorized: Bool
    public let publicV2CodecMutationAuthorized: Bool
    public let native300MExactV2LeafCompositionDeferred: Bool
    public let stage3SnapshotSerializationOnly: Bool
    public let exactOptimizerConfigurationStepAndScheduleRequired: Bool
    public let exactRNGDomainKeysCountersAndConsumptionRequired: Bool
    public let exactNextUnconsumedCursorRequired: Bool
    public let accumulationPhase: Int
    public let pendingGradientTensorCount: Int
    public let pendingPrefetchItemCount: Int
    public let kvCacheEntryCount: Int
}

public struct PrimeNativeDecoderTinyDurableMultileafLeafV1:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeNativeDecoderTinyDurableMultileafLeafRoleV1
    public let fileName: String
    public let encoding: String
    public let publicationOrdinal: Int
    public let required: Bool
    public let immutableNoReplace: Bool
    public let independentlyExternallyBound: Bool
    public let authoritativeBeforeFinalCommit: Bool
}

public struct PrimeNativeDecoderTinyDurableMultileafCommitDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaID: String
    public let externalCommitBindingSchemaID: String
    public let exactLeafInventory: [PrimeNativeDecoderTinyDurableMultileafLeafV1]
    public let finalCommitManifestPublishedLast: Bool
    public let finalCommitManifestIsExclusiveCommitPoint: Bool
    public let artifactRootProvidesPerFileNoReplace: Bool
    public let artifactRootProvidesAtomicMultiFileTransaction: Bool
    public let partialPrecommitLeavesAreAuthoritative: Bool
    public let partialPrecommitLeavesMustBeQuarantined: Bool
    public let loadRequiresExternallySuppliedExactCommitBinding: Bool
    public let loadRequiresExactInventoryAndEveryLeafBinding: Bool
    public let discoverAndTrustLoadAuthorized: Bool
    public let inPlaceMutationOrReplacementAuthorized: Bool
    public let failedWritePartialStateCanBePromoted: Bool
}

public struct PrimeNativeDecoderTinyDurableMultileafFaultWitnessV1:
    Codable,
    Equatable,
    Sendable
{
    public let exactFaultPoints: [PrimeNativeDecoderTinyDurableMultileafFaultPointV1]
    public let injectedFailureCount: Int
    public let everyInjectedFailureProducesNoNamedCommit: Bool
    public let everyInjectedFailureProducesNoAuthoritativeLoad: Bool
    public let everyPartialLeafInventoryIsQuarantined: Bool
    public let failedAttemptRetryOrPromotionAuthorized: Bool
    public let mutationOfPublishedLeafAuthorized: Bool
}

public struct PrimeNativeDecoderTinyDurableMultileafSuccessWitnessV1:
    Codable,
    Equatable,
    Sendable
{
    public let publishedFileCount: Int
    public let exactPublicationOrder: [PrimeNativeDecoderTinyDurableMultileafLeafRoleV1]
    public let allPublishedFilesImmutable: Bool
    public let finalCommitPublishedExactlyOnce: Bool
    public let externallySuppliedCommitBindingRequired: Bool
    public let exactInventoryAndEveryLeafBindingLoads: Bool
    public let roundTripRestoresExactStage3Snapshot: Bool
    public let directXCTestCount: Int
    public let failureCount: Int
    public let skipCount: Int
}

public struct PrimeNativeDecoderTinyDurableMultileafSuccessorScopeV1:
    Codable,
    Equatable,
    Sendable
{
    public let exactChangedPaths: [String]
    public let rootPackageManifestMutationAuthorized: Bool
    public let rootPackageResolvedMutationAuthorized: Bool
    public let trainingValidationManifestMutationAuthorized: Bool
    public let trainingValidationLockMutationAuthorized: Bool
    public let checkpointTargetDependencyForTrainingAuthorized: Bool
    public let genericCodecMustBeInCheckpointTarget: Bool
    public let trainingSourceMayOnlyBridgeStage3Snapshot: Bool
    public let stage3LauncherMutationAuthorized: Bool
    public let existingMetalLauncherMutationAuthorized: Bool
    public let secureFetchMutationAuthorized: Bool
    public let workflowTimeoutChangeAuthorized: Bool
    public let reviewedCheckoutDepth: Int
    public let newHostedLauncherRequired: Bool
}

public struct PrimeNativeDecoderTinyDurableMultileafSuiteV1:
    Codable,
    Equatable,
    Sendable
{
    public let authorityRootTestCount: Int
    public let implementationFocusedWholeTestCount: Int
    public let predecessorMetalTestCount: Int
    public let predecessorRuntimeTestCount: Int
    public let predecessorTokenizerTestCount: Int
    public let preStage4TotalTestCount: Int
    public let stage4DirectXCTestCount: Int
    public let totalTestCount: Int
    public let liveOrder: [String]
}

public struct PrimeNativeDecoderTinyDurableMultileafAuthorityCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let authorityOnlyNoExecutionEvidence: Bool
    public let mechanicsImplementationAuthorizedAfterGreenAuthorityClosure: Bool
    public let oneExactMainExecutionOpportunityAuthorized: Bool
    public let tinyEphemeralArtifactRootAuthorizedForMechanics: Bool
    public let stage3SnapshotLeafSerializationAuthorizedForMechanics: Bool
    public let additionalExecutionOrRerunAuthorized: Bool
    public let retainedArtifactAuthorized: Bool
    public let artifactUploadAuthorized: Bool
    public let checkpointAdmissionGranted: Bool
    public let publicV2CodecWideningAuthorized: Bool
    public let metalDeterminismEstablished: Bool
    public let stage5Authorized: Bool
    public let native300MAllocationAuthorized: Bool
    public let native300MTrainingAuthorized: Bool
    public let generalTrainingResumeEstablished: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
}

/// Pure authority for the fourth trajectory stage. It freezes one later tiny,
/// ephemeral, fault-injected durable mechanics witness and performs no I/O.
public struct PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public static let canonicalSHA256 =
        "0b167685f0cc10cbf5d705d6cf67b72b54555dfa52b9f4aaebd00613e057b031"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "prime_native_decoder_tiny_durable_multileaf_commit_fault_injection_authority_v1",
        repository: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            stage3RetirementMergeRevision:
                "5cadcfb915356984f1d6496d7a255725937f9007",
            stage3RetirementTree:
                "7fa0f3c9cdcbbd68386a55414e9e08425bccbc7a",
            orderedParentRevisions: [
                "ea96f7a503adfb5e814f81f2180318f8d1f06abd",
                "0f0ce7d80922da01f3c072caee13fb18a7e18ae4",
            ],
            embeddedSourceIdentitySHA256:
                "e62013d382edf06d3462c2acd5c0986d083ab6563a7d64696f3a149d4994cd07",
            designAuthorityCanonicalSHA256:
                "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589",
            designAuthoritySourceGitBlob:
                "20bcbf28ddcfa9a6339510d53e81da02ada9953e",
            designAuthoritySourceSHA256:
                "92194cb171eb1219393008c1dcd3b1c7dfcb2fd9232f4149391dfc428a5e7969",
            designAuthorityTestGitBlob:
                "186dc546c7f889f28d700322ac06b7b8a8a4c252",
            designAuthorityTestSHA256:
                "1fc9d8a4dde9e5e4192de9c248076f218ea38094eb68c335ade6de50862eb58b",
            stage3AuthorityCanonicalSHA256:
                "0ab57d5e8c71b18d03c9730da1e90399d57c05ccaa155aa31aff0c3001987fe6",
            stage3ObservationCanonicalSHA256:
                "9f0d4c974eca94edc6ca9953cd9cd27fef2e53ad6850addcbfc0a80512530d8d",
            stage3ObservationSourceGitBlob:
                "fd32a489ea3cae08cad3e6e462434f3f97df8cab",
            stage3ObservationSourceSHA256:
                "737c91e750f7f3520a634b737c17b672d47a290e726dcce7179c5518b7745d22",
            stage3ObservationTestGitBlob:
                "fae2cc34a1f2d53dd8610e6bb93a379509742f6f",
            stage3ObservationTestSHA256:
                "3c04ec65c760d4caa92dce775bf96b7673075db3e459285806095ff8543a2807",
            stage3LauncherGitBlob:
                "f912e776309866eaec5c6a162892c096b9bc2488",
            stage3LauncherSHA256:
                "1a184b52e0055128afbb6a9ccc22c46e8a929f30b3e0f43752f6a43e48eae6bd",
            stage3RetirementMergeIsCurrentAuthorityBase: true,
            authorityMustMergeAndPassExactMainBeforeImplementation: true,
            implementationMustBindFinalAuthorityMergeAndTree: true),
        predecessor: .init(
            stage3ExecutionRunID: 31_679_144_989,
            stage3ExecutionRunNumber: 89,
            stage3ExecutionRunAttempt: 1,
            stage3ExecutionRerunCount: 0,
            stage3ExecutionArtifactCount: 0,
            stage3ExecutionRootTestCount: 47,
            stage3ExecutionIsolatedTestCount: 6,
            stage3ExecutionMetalTestCount: 44,
            stage3ExecutionRuntimeTestCount: 1,
            stage3ExecutionTokenizerTestCount: 1,
            stage3ExecutionStartedCount: 1,
            stage3ExecutionPassedCount: 1,
            stage3ExecutionFailureCount: 0,
            stage3ExecutionSkipCount: 0,
            stage3ReceiptSHA256:
                "f14c68a835ff6779a4b3a3fe5ab0f66e464d2070d63538c32f19842045f7826e",
            retirementRunID: 31_684_805_703,
            retirementRunNumber: 91,
            retirementRunAttempt: 1,
            retirementCheckSuiteID: 85_952_914_129,
            retirementActiveJobID: 94_398_267_652,
            retirementReviewedJobID: 94_398_960_848,
            retirementExactHeadPushRunCount: 1,
            retirementRerunCount: 0,
            retirementArtifactCount: 0,
            retirementRootTestCount: 48,
            retirementMetalTestCount: 44,
            retirementRuntimeTestCount: 1,
            retirementTokenizerTestCount: 1,
            retirementStage3InvocationCount: 0,
            retirementStage3ReceiptCount: 0,
            stage3MechanicsEstablished: true,
            stage3InvocationRetired: true,
            stage3LauncherPreservedForAudit: true),
        roadmap: .init(
            stageID: "tiny_durable_multileaf_commit_fault_injection_v1",
            objective:
                "prove_immutable_leaf_publication_final_commit_and_partial_write_quarantine",
            requiredPredecessorStageID:
                "tiny_cpu_explicit_rng_cursor_resume_v1",
            nextStageID:
                "tiny_repeated_metal_trajectory_determinism_assay_v1",
            separateStage4AuthorityRequired: true,
            stage5RequiresSeparateAuthority: true),
        snapshot: .init(
            sourceSnapshotType:
                "PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1",
            snapshotGlobalStep: 1,
            modelTensorCount: 20,
            firstMomentTensorCount: 20,
            secondMomentTensorCount: 20,
            optimizerMomentTensorCount: 40,
            weightsLeafEncoding: "safetensors_tiny_fixture_v1",
            weightsRoleSemantics:
                "bounded_real_tiny_mechanics_safetensors_fixture_not_native300m_exact_v2_leaf",
            optimizerMomentsLeafEncoding: "safetensors_tiny_fixture_v1",
            controlStateLeafEncoding: "canonical_json",
            commitManifestEncoding: "canonical_json",
            tinyFixtureSafetensorsEncodingAuthorized: true,
            native300MPublicV2CodecUseAuthorized: false,
            publicV2CodecMutationAuthorized: false,
            native300MExactV2LeafCompositionDeferred: true,
            stage3SnapshotSerializationOnly: true,
            exactOptimizerConfigurationStepAndScheduleRequired: true,
            exactRNGDomainKeysCountersAndConsumptionRequired: true,
            exactNextUnconsumedCursorRequired: true,
            accumulationPhase: 0,
            pendingGradientTensorCount: 0,
            pendingPrefetchItemCount: 0,
            kvCacheEntryCount: 0),
        commitDesign: .init(
            schemaID:
                "ergentics_prime_native_decoder_trajectory_exact_resume_checkpoint_v1",
            externalCommitBindingSchemaID:
                "ergentics_prime_native_decoder_trajectory_exact_resume_external_commit_binding_v1",
            exactLeafInventory: [
                .init(
                    role: .weightsV2,
                    fileName: "weights.safetensors",
                    encoding: "safetensors_tiny_fixture_v1",
                    publicationOrdinal: 1,
                    required: true,
                    immutableNoReplace: true,
                    independentlyExternallyBound: true,
                    authoritativeBeforeFinalCommit: false),
                .init(
                    role: .optimizerMoments,
                    fileName: "optimizer_moments.safetensors",
                    encoding: "safetensors_tiny_fixture_v1",
                    publicationOrdinal: 2,
                    required: true,
                    immutableNoReplace: true,
                    independentlyExternallyBound: true,
                    authoritativeBeforeFinalCommit: false),
                .init(
                    role: .controlStateManifest,
                    fileName: "control_state.json",
                    encoding: "canonical_json",
                    publicationOrdinal: 3,
                    required: true,
                    immutableNoReplace: true,
                    independentlyExternallyBound: true,
                    authoritativeBeforeFinalCommit: false),
                .init(
                    role: .commitManifest,
                    fileName: "commit.json",
                    encoding: "canonical_json",
                    publicationOrdinal: 4,
                    required: true,
                    immutableNoReplace: true,
                    independentlyExternallyBound: true,
                    authoritativeBeforeFinalCommit: false),
            ],
            finalCommitManifestPublishedLast: true,
            finalCommitManifestIsExclusiveCommitPoint: true,
            artifactRootProvidesPerFileNoReplace: true,
            artifactRootProvidesAtomicMultiFileTransaction: false,
            partialPrecommitLeavesAreAuthoritative: false,
            partialPrecommitLeavesMustBeQuarantined: true,
            loadRequiresExternallySuppliedExactCommitBinding: true,
            loadRequiresExactInventoryAndEveryLeafBinding: true,
            discoverAndTrustLoadAuthorized: false,
            inPlaceMutationOrReplacementAuthorized: false,
            failedWritePartialStateCanBePromoted: false),
        faultWitness: .init(
            exactFaultPoints:
                PrimeNativeDecoderTinyDurableMultileafFaultPointV1.allCases,
            injectedFailureCount: 7,
            everyInjectedFailureProducesNoNamedCommit: true,
            everyInjectedFailureProducesNoAuthoritativeLoad: true,
            everyPartialLeafInventoryIsQuarantined: true,
            failedAttemptRetryOrPromotionAuthorized: false,
            mutationOfPublishedLeafAuthorized: false),
        successWitness: .init(
            publishedFileCount: 4,
            exactPublicationOrder:
                PrimeNativeDecoderTinyDurableMultileafLeafRoleV1.allCases,
            allPublishedFilesImmutable: true,
            finalCommitPublishedExactlyOnce: true,
            externallySuppliedCommitBindingRequired: true,
            exactInventoryAndEveryLeafBindingLoads: true,
            roundTripRestoresExactStage3Snapshot: true,
            directXCTestCount: 1,
            failureCount: 0,
            skipCount: 0),
        successorScope: .init(
            exactChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage4-tiny-durable-multileaf.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Package.resolved",
                "Package.swift",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderTrajectoryCheckpointV1.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests.swift",
            ],
            rootPackageManifestMutationAuthorized: true,
            rootPackageResolvedMutationAuthorized: true,
            trainingValidationManifestMutationAuthorized: false,
            trainingValidationLockMutationAuthorized: false,
            checkpointTargetDependencyForTrainingAuthorized: true,
            genericCodecMustBeInCheckpointTarget: true,
            trainingSourceMayOnlyBridgeStage3Snapshot: true,
            stage3LauncherMutationAuthorized: false,
            existingMetalLauncherMutationAuthorized: false,
            secureFetchMutationAuthorized: false,
            workflowTimeoutChangeAuthorized: false,
            reviewedCheckoutDepth: 2,
            newHostedLauncherRequired: true),
        suite: .init(
            authorityRootTestCount: 49,
            implementationFocusedWholeTestCount: 55,
            predecessorMetalTestCount: 44,
            predecessorRuntimeTestCount: 1,
            predecessorTokenizerTestCount: 1,
            preStage4TotalTestCount: 101,
            stage4DirectXCTestCount: 1,
            totalTestCount: 102,
            liveOrder: ["root", "metal", "maintained_runtime", "tokenizer", "stage4"]),
        ceiling: .init(
            authorityOnlyNoExecutionEvidence: true,
            mechanicsImplementationAuthorizedAfterGreenAuthorityClosure: true,
            oneExactMainExecutionOpportunityAuthorized: true,
            tinyEphemeralArtifactRootAuthorizedForMechanics: true,
            stage3SnapshotLeafSerializationAuthorizedForMechanics: true,
            additionalExecutionOrRerunAuthorized: false,
            retainedArtifactAuthorized: false,
            artifactUploadAuthorized: false,
            checkpointAdmissionGranted: false,
            publicV2CodecWideningAuthorized: false,
            metalDeterminismEstablished: false,
            stage5Authorized: false,
            native300MAllocationAuthorized: false,
            native300MTrainingAuthorized: false,
            generalTrainingResumeEstablished: false,
            modelQualityEstablished: false,
            candidateAdmissionGranted: false,
            trialAuthorized: false,
            canaryAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false),
        status:
            "AUTHORIZED_stage4_tiny_ephemeral_durable_four_leaf_commit_fault_injection_mechanics_and_one_exact_main_witness_after_green_authority_closure_no_retention_admission_metal_native300m_rerun_or_downstream_authority")

    public let schemaVersion: Int
    public let authorityID: String
    public let repository: PrimeNativeDecoderTinyDurableMultileafRepositoryV1
    public let predecessor: PrimeNativeDecoderTinyDurableMultileafPredecessorV1
    public let roadmap: PrimeNativeDecoderTinyDurableMultileafRoadmapV1
    public let snapshot: PrimeNativeDecoderTinyDurableMultileafSnapshotV1
    public let commitDesign: PrimeNativeDecoderTinyDurableMultileafCommitDesignV1
    public let faultWitness: PrimeNativeDecoderTinyDurableMultileafFaultWitnessV1
    public let successWitness: PrimeNativeDecoderTinyDurableMultileafSuccessWitnessV1
    public let successorScope: PrimeNativeDecoderTinyDurableMultileafSuccessorScopeV1
    public let suite: PrimeNativeDecoderTinyDurableMultileafSuiteV1
    public let ceiling: PrimeNativeDecoderTinyDurableMultileafAuthorityCeilingV1
    public let status: String

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityError
                .contractDrift
        }
        let design = PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1
            .frozenV1
        let observation =
            PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationV1
                .frozenV1
        let stage3 = PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityV1
            .frozenV1
        let requiredPlan = design.orderedStages.first {
            $0.stage == .tinyDurableMultileafCommitFaultInjection
        }
        let nextPlan = design.orderedStages.first {
            $0.stage == .tinyRepeatedMetalTrajectoryDeterminismAssay
        }
        let leaves = commitDesign.exactLeafInventory
        let falseCeiling = [
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.checkpointAdmissionGranted,
            ceiling.publicV2CodecWideningAuthorized,
            ceiling.metalDeterminismEstablished,
            ceiling.stage5Authorized,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.generalTrainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
        guard schemaVersion == 1,
              authorityID
                == "prime_native_decoder_tiny_durable_multileaf_commit_fault_injection_authority_v1",
              repository.repository == "Ergentics/ergentics-prime",
              repository.ref == "refs/heads/main",
              repository.orderedParentRevisions.count == 2,
              repository.stage3RetirementMergeIsCurrentAuthorityBase,
              repository.authorityMustMergeAndPassExactMainBeforeImplementation,
              repository.implementationMustBindFinalAuthorityMergeAndTree,
              repository.designAuthorityCanonicalSHA256
                == "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589",
              repository.stage3AuthorityCanonicalSHA256
                == PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityV1
                    .canonicalSHA256,
              repository.stage3ObservationCanonicalSHA256
                == PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationV1
                    .canonicalSHA256,
              PrimeSHA256.hexDigest(of: try stage3.canonicalData())
                == repository.stage3AuthorityCanonicalSHA256,
              PrimeSHA256.hexDigest(of: try observation.canonicalData())
                == repository.stage3ObservationCanonicalSHA256,
              requiredPlan?.objective == roadmap.objective,
              requiredPlan?.requiredCompletedPredecessorStage
                == .tinyCPUExplicitRNGCursorResume,
              requiredPlan?.separatelyAuthorizedSuccessorRequired == true,
              requiredPlan?.implementationAuthorizedByThisDesignAuthority == false,
              requiredPlan?.artifactIOAuthorizedByThisDesignAuthority == false,
              nextPlan?.requiredCompletedPredecessorStage
                == .tinyDurableMultileafCommitFaultInjection,
              roadmap.stageID
                == "tiny_durable_multileaf_commit_fault_injection_v1",
              roadmap.requiredPredecessorStageID
                == "tiny_cpu_explicit_rng_cursor_resume_v1",
              roadmap.nextStageID
                == "tiny_repeated_metal_trajectory_determinism_assay_v1",
              roadmap.separateStage4AuthorityRequired,
              roadmap.stage5RequiresSeparateAuthority,
              predecessor.stage3ExecutionRunID == observation.run.workflowRunID,
              predecessor.stage3ExecutionRunNumber == observation.run.workflowRunNumber,
              predecessor.stage3ExecutionRerunCount == 0,
              predecessor.stage3ExecutionArtifactCount == 0,
              predecessor.stage3ExecutionStartedCount == 1,
              predecessor.stage3ExecutionPassedCount == 1,
              predecessor.stage3ExecutionFailureCount == 0,
              predecessor.stage3ExecutionSkipCount == 0,
              predecessor.retirementRunAttempt == 1,
              predecessor.retirementExactHeadPushRunCount == 1,
              predecessor.retirementRerunCount == 0,
              predecessor.retirementArtifactCount == 0,
              predecessor.retirementRootTestCount == 48,
              predecessor.retirementMetalTestCount == 44,
              predecessor.retirementRuntimeTestCount == 1,
              predecessor.retirementTokenizerTestCount == 1,
              predecessor.retirementStage3InvocationCount == 0,
              predecessor.retirementStage3ReceiptCount == 0,
              predecessor.stage3MechanicsEstablished,
              predecessor.stage3InvocationRetired,
              predecessor.stage3LauncherPreservedForAudit,
              snapshot.modelTensorCount == 20,
              snapshot.firstMomentTensorCount == 20,
              snapshot.secondMomentTensorCount == 20,
              snapshot.optimizerMomentTensorCount == 40,
              snapshot.tinyFixtureSafetensorsEncodingAuthorized,
              snapshot.weightsRoleSemantics
                == "bounded_real_tiny_mechanics_safetensors_fixture_not_native300m_exact_v2_leaf",
              !snapshot.native300MPublicV2CodecUseAuthorized,
              !snapshot.publicV2CodecMutationAuthorized,
              snapshot.native300MExactV2LeafCompositionDeferred,
              snapshot.stage3SnapshotSerializationOnly,
              snapshot.exactOptimizerConfigurationStepAndScheduleRequired,
              snapshot.exactRNGDomainKeysCountersAndConsumptionRequired,
              snapshot.exactNextUnconsumedCursorRequired,
              snapshot.accumulationPhase == 0,
              snapshot.pendingGradientTensorCount == 0,
              snapshot.pendingPrefetchItemCount == 0,
              snapshot.kvCacheEntryCount == 0,
              leaves.map(\.role)
                == PrimeNativeDecoderTinyDurableMultileafLeafRoleV1.allCases,
              leaves.map(\.publicationOrdinal) == [1, 2, 3, 4],
              leaves.allSatisfy({
                  $0.required && $0.immutableNoReplace
                      && $0.independentlyExternallyBound
                      && !$0.authoritativeBeforeFinalCommit
              }),
              commitDesign.finalCommitManifestPublishedLast,
              commitDesign.finalCommitManifestIsExclusiveCommitPoint,
              commitDesign.artifactRootProvidesPerFileNoReplace,
              !commitDesign.artifactRootProvidesAtomicMultiFileTransaction,
              !commitDesign.partialPrecommitLeavesAreAuthoritative,
              commitDesign.partialPrecommitLeavesMustBeQuarantined,
              commitDesign.loadRequiresExternallySuppliedExactCommitBinding,
              commitDesign.loadRequiresExactInventoryAndEveryLeafBinding,
              !commitDesign.discoverAndTrustLoadAuthorized,
              !commitDesign.inPlaceMutationOrReplacementAuthorized,
              !commitDesign.failedWritePartialStateCanBePromoted,
              faultWitness.exactFaultPoints
                == PrimeNativeDecoderTinyDurableMultileafFaultPointV1.allCases,
              faultWitness.injectedFailureCount == 7,
              faultWitness.everyInjectedFailureProducesNoNamedCommit,
              faultWitness.everyInjectedFailureProducesNoAuthoritativeLoad,
              faultWitness.everyPartialLeafInventoryIsQuarantined,
              !faultWitness.failedAttemptRetryOrPromotionAuthorized,
              !faultWitness.mutationOfPublishedLeafAuthorized,
              successWitness.publishedFileCount == 4,
              successWitness.exactPublicationOrder
                == PrimeNativeDecoderTinyDurableMultileafLeafRoleV1.allCases,
              successWitness.allPublishedFilesImmutable,
              successWitness.finalCommitPublishedExactlyOnce,
              successWitness.externallySuppliedCommitBindingRequired,
              successWitness.exactInventoryAndEveryLeafBindingLoads,
              successWitness.roundTripRestoresExactStage3Snapshot,
              successWitness.directXCTestCount == 1,
              successWitness.failureCount == 0,
              successWitness.skipCount == 0,
              successorScope.exactChangedPaths
                == successorScope.exactChangedPaths.sorted(),
              Set(successorScope.exactChangedPaths).count == 9,
              successorScope.rootPackageManifestMutationAuthorized,
              successorScope.rootPackageResolvedMutationAuthorized,
              !successorScope.trainingValidationManifestMutationAuthorized,
              !successorScope.trainingValidationLockMutationAuthorized,
              successorScope.checkpointTargetDependencyForTrainingAuthorized,
              successorScope.genericCodecMustBeInCheckpointTarget,
              successorScope.trainingSourceMayOnlyBridgeStage3Snapshot,
              !successorScope.stage3LauncherMutationAuthorized,
              !successorScope.existingMetalLauncherMutationAuthorized,
              !successorScope.secureFetchMutationAuthorized,
              !successorScope.workflowTimeoutChangeAuthorized,
              successorScope.reviewedCheckoutDepth == 2,
              successorScope.newHostedLauncherRequired,
              suite.authorityRootTestCount == 49,
              suite.implementationFocusedWholeTestCount == 55,
              suite.predecessorMetalTestCount == 44,
              suite.predecessorRuntimeTestCount == 1,
              suite.predecessorTokenizerTestCount == 1,
              suite.preStage4TotalTestCount == 101,
              suite.stage4DirectXCTestCount == 1,
              suite.totalTestCount == 102,
              suite.liveOrder
                == ["root", "metal", "maintained_runtime", "tokenizer", "stage4"],
              ceiling.authorityOnlyNoExecutionEvidence,
              ceiling.mechanicsImplementationAuthorizedAfterGreenAuthorityClosure,
              ceiling.oneExactMainExecutionOpportunityAuthorized,
              ceiling.tinyEphemeralArtifactRootAuthorizedForMechanics,
              ceiling.stage3SnapshotLeafSerializationAuthorizedForMechanics,
              falseCeiling.allSatisfy({ !$0 }),
              status
                == "AUTHORIZED_stage4_tiny_ephemeral_durable_four_leaf_commit_fault_injection_mechanics_and_one_exact_main_witness_after_green_authority_closure_no_retention_admission_metal_native300m_rerun_or_downstream_authority"
        else {
            throw PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityError
                .contractDrift
        }
    }

    public func canonicalData() throws -> Data {
        try validateExactV1()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try value.canonicalData() == data else {
            throw PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityError
                .nonCanonicalEncoding
        }
        return value
    }
}
