// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore

/// Dynamic, process-local evidence for the single execution authorized by
/// `PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityPlanV1`.
///
/// The full typed external binding is embedded here, including all 218
/// logical tensor bindings. When the pinned probe constructs and emits this
/// value after its successful codec calls, it records only one execution-local
/// random-initialized weights round trip. Validation alone proves schema and
/// internal consistency; the hosted source, log, and receipt binding supplies
/// execution provenance. A later append-only reviewed-main observation must
/// bind the receipt before its facts become durable repository authority.
public struct
    PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidenceV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let evidenceID: String
    public let authorityID: String

    public let executedRevision: String
    public let executedOrderedParentRevisions: [String]
    public let executedTree: String
    public let reviewedPullRequestHeadTree: String
    public let executedEmbeddedSourceIdentitySHA256: String
    public let executionEvent: String
    public let executionRef: String
    public let executionRunAttempt: Int
    public let executionRepository: String
    public let githubActions: String
    public let runnerEnvironment: String
    public let operatingSystem: String
    public let architecture: String
    public let exactRevisionMatchedGitHubSHA: Bool

    public let environmentPolicy:
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    public let launchedEnvironmentValidatedBeforeFrameworkAccess: Bool
    public let launchedEnvironmentRevalidatedAfterEvaluation: Bool
    public let releaseInstrumentationEvidenceAbsent: Bool
    public let coreGraphicsBootstrapObserved: Bool
    public let enumeratedMetalDeviceCount: Int
    public let defaultMetalDeviceMatchedIndexZero: Bool
    public let mlxDeviceType: String
    public let mlxDeviceIndex: Int
    public let metalLeaseHeldBeforeAndAfterEvaluation: Bool
    public let metallibArtifactRelativePath: String
    public let metallibByteCount: UInt64
    public let metallibSHA256: String
    public let existingMetallibCandidateCountBeforeExecution: Int
    public let existingMetallibCandidateCountAfterExecution: Int
    public let metallibPathAndDescriptorReverified: Bool
    public let metalLibraryValidatedFromExactURL: Bool
    public let focusedContractLogsValidatedBeforeReclamation: Bool
    public let frozen44MetalLogValidatedBeforeReclamation: Bool
    public let maintainedRuntimeAuthorityLogAndReceiptValidatedBeforeReclamation:
        Bool
    public let tokenizerAuthorityLogAndReceiptValidatedBeforeReclamation:
        Bool
    public let predecessorValidatedLogCount: Int
    public let predecessorValidatedReceiptCount: Int
    public let predecessorFailureObservationConsumedByAuthoritySource: Bool
    public let exhaustedSeed42PublicWriteCompletionCountSourceInferred: Int
    public let exhaustedSeed42PublicLoadCompletionCountSourceInferred: Int
    public let cumulativePublicWriteCompletionCountSourceInferredAfterSuccess:
        Int
    public let cumulativePublicLoadCompletionCountSourceInferredAfterSuccess:
        Int

    public let knownRunnerTemporaryReclamationPathCount: Int
    public let knownRunnerTemporaryPathsAbsentBeforeProbe: Bool
    public let availableFilesystemBytesAfterReclamation: UInt64
    public let availableFilesystemBytesAfterBuild: UInt64
    public let requiredFreeSpaceMultiplier: UInt64
    public let freeSpacePreflightPassed: Bool

    public let artifactRootPathIsAbsolute: Bool
    public let artifactRootOwnerMatchedEffectiveUser: Bool
    public let artifactRootInitiallyEmpty: Bool
    public let artifactRootEntryCountAfterWrite: Int
    public let artifactRootIdentityBeforeWrite:
        PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1
    public let artifactRootIdentityAfterWrite:
        PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1
    public let artifactRootIdentityAfterLoad:
        PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1
    public let artifactRootEntryNamesBeforeWrite: [String]
    public let artifactRootEntryNamesAfterWrite: [String]
    public let publishedArtifactIsRegularFile: Bool
    public let publishedArtifactIsSymbolicLink: Bool
    public let publishedArtifactDeviceMatchedRoot: Bool
    public let publishedArtifactOwnerMatchedEffectiveUser: Bool
    public let publicationStableFiveFieldsMatched: Bool
    public let publicationRootLinkCountsPositive: Bool
    public let readOnlyFullRootIdentityMatched: Bool

    public let compatibilityIdentityCanonicalByteCount: Int
    public let compatibilityIdentitySHA256: String
    public let compatibilityIdentityValidated: Bool
    public let configuration:
        PrimeNativeDecoderTokenizerModelFunctionalCompatibilityConfigurationV1
    public let initializationSeed: UInt64
    public let callerSourceModelConstructionCount: Int
    public let initialParameterMaterializationEvaluationCount: Int
    public let initialParameterMaterializationEvaluationAPI: String
    public let memoryCacheLimit: Int
    public let memoryCacheClearCount: Int
    public let cacheClearedBeforeSourceMaterialization: Bool
    public let sourceModelReferenceLexicalScopeEndedBeforePublicLoad: Bool
    public let cacheClearedBetweenSourceWriteAndPublicLoad: Bool

    public let publicCheckpointWriteInvocationCount: Int
    public let publicCheckpointWriteCompletionCount: Int
    public let publicCheckpointLoadInvocationCount: Int
    public let publicCheckpointLoadCompletionCount: Int
    public let totalDecoderConstructionCountIsSourceInferredOnly: Bool
    public let sourceInferredDecoderConstructionCount: Int
    public let containerMaterializationCountRequiredByPinnedCodec: Int
    public let freshLoadedModelConstructionRequiredByPinnedCodec: Bool

    public let externalBinding:
        PrimeNativeDecoderCheckpointExternalBindingV2
    public let externalBindingCanonicalByteCount: UInt64
    public let externalBindingCanonicalSHA256: String
    public let manifestCanonicalByteCount: UInt64
    public let manifestCanonicalSHA256: String
    public let manifestValidated: Bool
    public let tensorBindingCount: Int
    public let tensorBindingsCanonicalByteCount: UInt64
    public let tensorBindingsSHA256: String
    public let observedParameterCount: UInt64
    public let observedParameterByteCount: UInt64
    public let publishedArtifactMode: UInt16
    public let publishedArtifactLinkCount: UInt64

    public let writerHiddenDescriptorRestoreAndReinspectionCompletedViaSuccessfulPinnedCodecReturn:
        Bool
    public let loadedParameterCatalogAndLogicalHashesMatchedManifestViaPinnedCodec:
        Bool
    public let loadedStructuralParameterCatalogMatched: Bool
    public let artifactBindingVerifiedBeforeAndAfterCompleteMaterializationViaPinnedArtifactRoot:
        Bool
    public let exclusiveNoReplacePublicationCompleted: Bool
    public let generatedFileAndParentSynchronizationReturnedSuccess: Bool

    public let native300MModelAllocationObserved: Bool
    public let native300MCheckpointWriteObserved: Bool
    public let native300MCheckpointLoadObserved: Bool
    public let checkpointIOObserved: Bool
    public let checkpointArtifactAvailableDuringProcess: Bool
    public let checkpointContainerHashBound: Bool
    public let checkpointDurabilityMechanicsCompleted: Bool
    public let logicalParameterRoundTripViaPinnedCodecObserved: Bool
    public let runtimeDependencyClosurePredecessorReceiptValidatedForCheckpointIO:
        Bool

    public let callerSuppliedRevisionBindingIsIndependentObservation: Bool
    public let loadedMetallibIdentityIndependentlyObserved: Bool
    public let physicalGPUIdentityEstablished: Bool
    public let tf32StaticValueDirectlyObserved: Bool
    public let tf32DifferentialObserved: Bool
    public let deterministicSeedReplayObserved: Bool
    public let reproducibleCheckpointSerializationObserved: Bool
    public let secondIndependentWriteObserved: Bool
    public let independentPostLoadTensorHashReplayObserved: Bool
    public let independentCodecComparatorObserved: Bool
    public let independentPostLoadArtifactRootVerifyObserved: Bool
    public let sourceModelARCDeallocationObserved: Bool
    public let artifactUploadInvokedBeforeReceipt: Bool
    public let checkpointArtifactAvailabilityBeyondProcessEstablished: Bool
    public let checkpointArtifactRetentionEstablished: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let existingCheckpointArtifactCompatibilityObserved: Bool
    public let atomicCheckpointReplacementEstablished: Bool
    public let failedCheckpointWriteRecoveryObserved: Bool
    public let checkpointLoadedForwardObserved: Bool
    public let checkpointRoundTripBehaviorParityEstablished: Bool
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let kvCacheStateIncluded: Bool
    public let decoderForwardObserved: Bool
    public let decoderKVCacheUsed: Bool
    public let backwardInvoked: Bool
    public let lossObserved: Bool
    public let optimizerStepObserved: Bool
    public let generationInvoked: Bool
    public let trainEvaluateSurfaceEstablished: Bool
    public let trainingResumeEstablished: Bool
    public let trainingExecutionObserved: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let retryObserved: Bool
    public let processExitRequiredAfterReceipt: Bool
    public let cleanupRequiredAfterParentReceiptVerification: Bool
    public let successCleanupCompletedBeforeReceipt: Bool
    public let parentSuccessCleanupRequiredAfterReceipt: Bool
    public let status: String

    public init(
        executedRevision: String,
        executedOrderedParentRevisions: [String],
        executedTree: String,
        reviewedPullRequestHeadTree: String,
        executedEmbeddedSourceIdentitySHA256: String,
        executionEvent: String,
        executionRef: String,
        executionRunAttempt: Int,
        executionRepository: String,
        githubActions: String,
        runnerEnvironment: String,
        operatingSystem: String,
        architecture: String,
        exactRevisionMatchedGitHubSHA: Bool,
        environmentPolicy:
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1,
        launchedEnvironmentValidatedBeforeFrameworkAccess: Bool,
        launchedEnvironmentRevalidatedAfterEvaluation: Bool,
        releaseInstrumentationEvidenceAbsent: Bool,
        coreGraphicsBootstrapObserved: Bool,
        enumeratedMetalDeviceCount: Int,
        defaultMetalDeviceMatchedIndexZero: Bool,
        mlxDeviceType: String,
        mlxDeviceIndex: Int,
        metalLeaseHeldBeforeAndAfterEvaluation: Bool,
        metallibArtifactRelativePath: String,
        metallibByteCount: UInt64,
        metallibSHA256: String,
        existingMetallibCandidateCountBeforeExecution: Int,
        existingMetallibCandidateCountAfterExecution: Int,
        metallibPathAndDescriptorReverified: Bool,
        metalLibraryValidatedFromExactURL: Bool,
        focusedContractLogsValidatedBeforeReclamation: Bool,
        frozen44MetalLogValidatedBeforeReclamation: Bool,
        maintainedRuntimeAuthorityLogAndReceiptValidatedBeforeReclamation:
            Bool,
        tokenizerAuthorityLogAndReceiptValidatedBeforeReclamation: Bool,
        predecessorValidatedLogCount: Int,
        predecessorValidatedReceiptCount: Int,
        knownRunnerTemporaryReclamationPathCount: Int,
        knownRunnerTemporaryPathsAbsentBeforeProbe: Bool,
        availableFilesystemBytesAfterReclamation: UInt64,
        availableFilesystemBytesAfterBuild: UInt64,
        requiredFreeSpaceMultiplier: UInt64,
        freeSpacePreflightPassed: Bool,
        artifactRootPathIsAbsolute: Bool,
        artifactRootOwnerMatchedEffectiveUser: Bool,
        artifactRootInitiallyEmpty: Bool,
        artifactRootEntryCountAfterWrite: Int,
        artifactRootIdentityBeforeWrite:
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1,
        artifactRootIdentityAfterWrite:
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1,
        artifactRootIdentityAfterLoad:
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1,
        compatibilityIdentityCanonicalByteCount: Int,
        compatibilityIdentitySHA256: String,
        compatibilityIdentityValidated: Bool,
        configuration:
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityConfigurationV1,
        initializationSeed: UInt64,
        callerSourceModelConstructionCount: Int,
        initialParameterMaterializationEvaluationCount: Int,
        initialParameterMaterializationEvaluationAPI: String,
        memoryCacheLimit: Int,
        memoryCacheClearCount: Int,
        cacheClearedBeforeSourceMaterialization: Bool,
        sourceModelReferenceLexicalScopeEndedBeforePublicLoad: Bool,
        cacheClearedBetweenSourceWriteAndPublicLoad: Bool,
        publicCheckpointWriteInvocationCount: Int,
        publicCheckpointWriteCompletionCount: Int,
        publicCheckpointLoadInvocationCount: Int,
        publicCheckpointLoadCompletionCount: Int,
        externalBinding: PrimeNativeDecoderCheckpointExternalBindingV2,
        externalBindingCanonicalByteCount: UInt64,
        externalBindingCanonicalSHA256: String,
        manifestCanonicalByteCount: UInt64,
        manifestCanonicalSHA256: String,
        manifestValidated: Bool,
        tensorBindingCount: Int,
        tensorBindingsCanonicalByteCount: UInt64,
        tensorBindingsSHA256: String,
        observedParameterCount: UInt64,
        observedParameterByteCount: UInt64,
        publishedArtifactMode: UInt16,
        publishedArtifactLinkCount: UInt64,
        writerHiddenDescriptorRestoreAndReinspectionCompletedViaSuccessfulPinnedCodecReturn:
            Bool,
        loadedParameterCatalogAndLogicalHashesMatchedManifestViaPinnedCodec:
            Bool,
        loadedStructuralParameterCatalogMatched: Bool,
        artifactBindingVerifiedBeforeAndAfterCompleteMaterializationViaPinnedArtifactRoot:
            Bool,
        exclusiveNoReplacePublicationCompleted: Bool,
        generatedFileAndParentSynchronizationReturnedSuccess: Bool
    ) throws {
        let authority =
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityPlanV1
                .frozenV1
        schemaVersion = 1
        evidenceID =
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_evidence_v1"
        authorityID = authority.authorityID
        self.executedRevision = executedRevision
        self.executedOrderedParentRevisions = executedOrderedParentRevisions
        self.executedTree = executedTree
        self.reviewedPullRequestHeadTree = reviewedPullRequestHeadTree
        self.executedEmbeddedSourceIdentitySHA256 =
            executedEmbeddedSourceIdentitySHA256
        self.executionEvent = executionEvent
        self.executionRef = executionRef
        self.executionRunAttempt = executionRunAttempt
        self.executionRepository = executionRepository
        self.githubActions = githubActions
        self.runnerEnvironment = runnerEnvironment
        self.operatingSystem = operatingSystem
        self.architecture = architecture
        self.exactRevisionMatchedGitHubSHA = exactRevisionMatchedGitHubSHA
        self.environmentPolicy = environmentPolicy
        self.launchedEnvironmentValidatedBeforeFrameworkAccess =
            launchedEnvironmentValidatedBeforeFrameworkAccess
        self.launchedEnvironmentRevalidatedAfterEvaluation =
            launchedEnvironmentRevalidatedAfterEvaluation
        self.releaseInstrumentationEvidenceAbsent =
            releaseInstrumentationEvidenceAbsent
        self.coreGraphicsBootstrapObserved = coreGraphicsBootstrapObserved
        self.enumeratedMetalDeviceCount = enumeratedMetalDeviceCount
        self.defaultMetalDeviceMatchedIndexZero =
            defaultMetalDeviceMatchedIndexZero
        self.mlxDeviceType = mlxDeviceType
        self.mlxDeviceIndex = mlxDeviceIndex
        self.metalLeaseHeldBeforeAndAfterEvaluation =
            metalLeaseHeldBeforeAndAfterEvaluation
        self.metallibArtifactRelativePath = metallibArtifactRelativePath
        self.metallibByteCount = metallibByteCount
        self.metallibSHA256 = metallibSHA256
        self.existingMetallibCandidateCountBeforeExecution =
            existingMetallibCandidateCountBeforeExecution
        self.existingMetallibCandidateCountAfterExecution =
            existingMetallibCandidateCountAfterExecution
        self.metallibPathAndDescriptorReverified =
            metallibPathAndDescriptorReverified
        self.metalLibraryValidatedFromExactURL =
            metalLibraryValidatedFromExactURL
        self.focusedContractLogsValidatedBeforeReclamation =
            focusedContractLogsValidatedBeforeReclamation
        self.frozen44MetalLogValidatedBeforeReclamation =
            frozen44MetalLogValidatedBeforeReclamation
        self.maintainedRuntimeAuthorityLogAndReceiptValidatedBeforeReclamation =
            maintainedRuntimeAuthorityLogAndReceiptValidatedBeforeReclamation
        self.tokenizerAuthorityLogAndReceiptValidatedBeforeReclamation =
            tokenizerAuthorityLogAndReceiptValidatedBeforeReclamation
        self.predecessorValidatedLogCount = predecessorValidatedLogCount
        self.predecessorValidatedReceiptCount =
            predecessorValidatedReceiptCount
        predecessorFailureObservationConsumedByAuthoritySource =
            authority.predecessorFailureObservationRequiredForConsumption
        exhaustedSeed42PublicWriteCompletionCountSourceInferred =
            authority
                .exhaustedSeed42PublicWriteCompletionCountSourceInferred
        exhaustedSeed42PublicLoadCompletionCountSourceInferred =
            authority
                .exhaustedSeed42PublicLoadCompletionCountSourceInferred
        cumulativePublicWriteCompletionCountSourceInferredAfterSuccess =
            authority
                .cumulativePublicWriteCompletionCountSourceInferredAfterSuccess
        cumulativePublicLoadCompletionCountSourceInferredAfterSuccess =
            authority
                .cumulativePublicLoadCompletionCountSourceInferredAfterSuccess
        self.knownRunnerTemporaryReclamationPathCount =
            knownRunnerTemporaryReclamationPathCount
        self.knownRunnerTemporaryPathsAbsentBeforeProbe =
            knownRunnerTemporaryPathsAbsentBeforeProbe
        self.availableFilesystemBytesAfterReclamation =
            availableFilesystemBytesAfterReclamation
        self.availableFilesystemBytesAfterBuild =
            availableFilesystemBytesAfterBuild
        self.requiredFreeSpaceMultiplier = requiredFreeSpaceMultiplier
        self.freeSpacePreflightPassed = freeSpacePreflightPassed
        self.artifactRootPathIsAbsolute = artifactRootPathIsAbsolute
        self.artifactRootOwnerMatchedEffectiveUser =
            artifactRootOwnerMatchedEffectiveUser
        self.artifactRootInitiallyEmpty = artifactRootInitiallyEmpty
        self.artifactRootEntryCountAfterWrite =
            artifactRootEntryCountAfterWrite
        self.artifactRootIdentityBeforeWrite = artifactRootIdentityBeforeWrite
        self.artifactRootIdentityAfterWrite = artifactRootIdentityAfterWrite
        self.artifactRootIdentityAfterLoad = artifactRootIdentityAfterLoad
        artifactRootEntryNamesBeforeWrite =
            authority.requiredArtifactRootEntryNamesBeforeWrite
        artifactRootEntryNamesAfterWrite =
            authority.requiredArtifactRootEntryNamesAfterWrite
        publishedArtifactIsRegularFile = true
        publishedArtifactIsSymbolicLink = false
        publishedArtifactDeviceMatchedRoot = true
        publishedArtifactOwnerMatchedEffectiveUser = true
        publicationStableFiveFieldsMatched =
            artifactRootIdentityBeforeWrite
                .publicationStableObjectFieldsEqual(
                    to: artifactRootIdentityAfterWrite)
        publicationRootLinkCountsPositive =
            artifactRootIdentityBeforeWrite.linkCount > 0
                && artifactRootIdentityAfterWrite.linkCount > 0
        readOnlyFullRootIdentityMatched =
            artifactRootIdentityAfterWrite.readOnlyFullIdentityEqual(
                to: artifactRootIdentityAfterLoad)
        self.compatibilityIdentityCanonicalByteCount =
            compatibilityIdentityCanonicalByteCount
        self.compatibilityIdentitySHA256 = compatibilityIdentitySHA256
        self.compatibilityIdentityValidated = compatibilityIdentityValidated
        self.configuration = configuration
        self.initializationSeed = initializationSeed
        self.callerSourceModelConstructionCount =
            callerSourceModelConstructionCount
        self.initialParameterMaterializationEvaluationCount =
            initialParameterMaterializationEvaluationCount
        self.initialParameterMaterializationEvaluationAPI =
            initialParameterMaterializationEvaluationAPI
        self.memoryCacheLimit = memoryCacheLimit
        self.memoryCacheClearCount = memoryCacheClearCount
        self.cacheClearedBeforeSourceMaterialization =
            cacheClearedBeforeSourceMaterialization
        self.sourceModelReferenceLexicalScopeEndedBeforePublicLoad =
            sourceModelReferenceLexicalScopeEndedBeforePublicLoad
        self.cacheClearedBetweenSourceWriteAndPublicLoad =
            cacheClearedBetweenSourceWriteAndPublicLoad
        self.publicCheckpointWriteInvocationCount =
            publicCheckpointWriteInvocationCount
        self.publicCheckpointWriteCompletionCount =
            publicCheckpointWriteCompletionCount
        self.publicCheckpointLoadInvocationCount =
            publicCheckpointLoadInvocationCount
        self.publicCheckpointLoadCompletionCount =
            publicCheckpointLoadCompletionCount
        totalDecoderConstructionCountIsSourceInferredOnly = true
        sourceInferredDecoderConstructionCount =
            authority.sourceInferredDecoderConstructionCountForRepairJob
        containerMaterializationCountRequiredByPinnedCodec =
            authority.containerMaterializationCountRequiredByPinnedCodec
        freshLoadedModelConstructionRequiredByPinnedCodec = true
        self.externalBinding = externalBinding
        self.externalBindingCanonicalByteCount =
            externalBindingCanonicalByteCount
        self.externalBindingCanonicalSHA256 =
            externalBindingCanonicalSHA256
        self.manifestCanonicalByteCount = manifestCanonicalByteCount
        self.manifestCanonicalSHA256 = manifestCanonicalSHA256
        self.manifestValidated = manifestValidated
        self.tensorBindingCount = tensorBindingCount
        self.tensorBindingsCanonicalByteCount =
            tensorBindingsCanonicalByteCount
        self.tensorBindingsSHA256 = tensorBindingsSHA256
        self.observedParameterCount = observedParameterCount
        self.observedParameterByteCount = observedParameterByteCount
        self.publishedArtifactMode = publishedArtifactMode
        self.publishedArtifactLinkCount = publishedArtifactLinkCount
        self.writerHiddenDescriptorRestoreAndReinspectionCompletedViaSuccessfulPinnedCodecReturn =
            writerHiddenDescriptorRestoreAndReinspectionCompletedViaSuccessfulPinnedCodecReturn
        self.loadedParameterCatalogAndLogicalHashesMatchedManifestViaPinnedCodec =
            loadedParameterCatalogAndLogicalHashesMatchedManifestViaPinnedCodec
        self.loadedStructuralParameterCatalogMatched =
            loadedStructuralParameterCatalogMatched
        self.artifactBindingVerifiedBeforeAndAfterCompleteMaterializationViaPinnedArtifactRoot =
            artifactBindingVerifiedBeforeAndAfterCompleteMaterializationViaPinnedArtifactRoot
        self.exclusiveNoReplacePublicationCompleted =
            exclusiveNoReplacePublicationCompleted
        self.generatedFileAndParentSynchronizationReturnedSuccess =
            generatedFileAndParentSynchronizationReturnedSuccess

        native300MModelAllocationObserved = true
        native300MCheckpointWriteObserved = true
        native300MCheckpointLoadObserved = true
        checkpointIOObserved = true
        checkpointArtifactAvailableDuringProcess = true
        checkpointContainerHashBound = true
        checkpointDurabilityMechanicsCompleted = true
        logicalParameterRoundTripViaPinnedCodecObserved = true
        runtimeDependencyClosurePredecessorReceiptValidatedForCheckpointIO =
            maintainedRuntimeAuthorityLogAndReceiptValidatedBeforeReclamation

        callerSuppliedRevisionBindingIsIndependentObservation = false
        loadedMetallibIdentityIndependentlyObserved = false
        physicalGPUIdentityEstablished = false
        tf32StaticValueDirectlyObserved = false
        tf32DifferentialObserved = false
        deterministicSeedReplayObserved = false
        reproducibleCheckpointSerializationObserved = false
        secondIndependentWriteObserved = false
        independentPostLoadTensorHashReplayObserved = false
        independentCodecComparatorObserved = false
        independentPostLoadArtifactRootVerifyObserved = false
        sourceModelARCDeallocationObserved = false
        artifactUploadInvokedBeforeReceipt = false
        checkpointArtifactAvailabilityBeyondProcessEstablished = false
        checkpointArtifactRetentionEstablished = false
        checkpointArtifactProvenanceEstablished = false
        checkpointAdmissionGranted = false
        existingCheckpointArtifactCompatibilityObserved = false
        atomicCheckpointReplacementEstablished = false
        failedCheckpointWriteRecoveryObserved = false
        checkpointLoadedForwardObserved = false
        checkpointRoundTripBehaviorParityEstablished = false
        optimizerStateIncluded = false
        rngStateIncluded = false
        dataCursorIncluded = false
        kvCacheStateIncluded = false
        decoderForwardObserved = false
        decoderKVCacheUsed = false
        backwardInvoked = false
        lossObserved = false
        optimizerStepObserved = false
        generationInvoked = false
        trainEvaluateSurfaceEstablished = false
        trainingResumeEstablished = false
        trainingExecutionObserved = false
        modelQualityEstablished = false
        candidateAdmissionGranted = false
        trialAuthorized = false
        canaryReplacementAuthorized = false
        quantizationAuthorized = false
        productUseAuthorized = false
        publicationAuthorized = false
        retryObserved = false
        processExitRequiredAfterReceipt = true
        cleanupRequiredAfterParentReceiptVerification = true
        successCleanupCompletedBeforeReceipt = false
        parentSuccessCleanupRequiredAfterReceipt =
            authority.parentReceiptVerificationRequiredBeforeSuccessCleanup
        status =
            "PASS_process_local_seed43_native300m_v2_checkpoint_root_identity_repair_one_public_write_one_public_fresh_load_only"
        try validate()
    }

    public func validate() throws {
        let authority =
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityPlanV1
                .frozenV1
        let identityBytes: Data
        let manifestBytes: Data
        let tensorBindingBytes: Data
        let externalBindingBytes: Data
        do {
            try authority.validateExactV1()
            try configuration.validateExactNative300MByte512()
            try externalBinding.validate()
            try externalBinding.manifest.compatibilityIdentity.validate()
            try artifactRootIdentityBeforeWrite.validatePrivateDirectory()
            try artifactRootIdentityAfterWrite.validatePrivateDirectory()
            try artifactRootIdentityAfterLoad.validatePrivateDirectory()
            try
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityComparatorV1
                    .validatePublicationTransition(
                        beforeWrite: artifactRootIdentityBeforeWrite,
                        afterWrite: artifactRootIdentityAfterWrite)
            try
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityComparatorV1
                    .validateReadOnlyTransition(
                        afterWrite: artifactRootIdentityAfterWrite,
                        afterLoad: artifactRootIdentityAfterLoad)
            identityBytes = try PrimeCanonicalJSON.encode(
                externalBinding.manifest.compatibilityIdentity)
            manifestBytes = try PrimeCanonicalJSON.encode(
                externalBinding.manifest)
            tensorBindingBytes = try PrimeCanonicalJSON.encode(
                externalBinding.manifest.tensorBindings)
            externalBindingBytes = try PrimeCanonicalJSON.encode(
                externalBinding)
        } catch {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError
                    .contractDrift
        }

        let artifactBinding = externalBinding.artifactBinding
        guard schemaVersion == 1,
              evidenceID
                == "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_evidence_v1",
              authorityID == authority.authorityID,
              isCheckpointV2ExecutionGitObjectID(executedRevision),
              executedOrderedParentRevisions.count
                == authority.requiredExecutedCommitParentCount,
              Set(executedOrderedParentRevisions).count
                == authority.requiredExecutedCommitParentCount,
              executedOrderedParentRevisions[0]
                == authority.requiredDirectSuccessorFirstParentRevision,
              executedOrderedParentRevisions.allSatisfy(
                  isCheckpointV2ExecutionGitObjectID),
              isCheckpointV2ExecutionGitObjectID(executedTree),
              reviewedPullRequestHeadTree == executedTree,
              isCheckpointV2ExecutionSHA256(
                  executedEmbeddedSourceIdentitySHA256),
              executionEvent == authority.requiredExecutionEvent,
              executionRef == authority.requiredExecutionRef,
              executionRunAttempt == authority.requiredExecutionRunAttempt,
              executionRepository == authority.authoritativeRepository,
              githubActions == authority.requiredGitHubActionsValue,
              runnerEnvironment == authority.requiredRunnerEnvironment,
              operatingSystem == "macOS",
              architecture == "arm64",
              exactRevisionMatchedGitHubSHA,
              environmentPolicy == authority.environmentPolicy,
              launchedEnvironmentValidatedBeforeFrameworkAccess,
              launchedEnvironmentRevalidatedAfterEvaluation,
              releaseInstrumentationEvidenceAbsent,
              coreGraphicsBootstrapObserved,
              enumeratedMetalDeviceCount == 1,
              defaultMetalDeviceMatchedIndexZero,
              mlxDeviceType == "gpu",
              mlxDeviceIndex == authority.mlxGPUDeviceIndex,
              metalLeaseHeldBeforeAndAfterEvaluation,
              metallibArtifactRelativePath
                == PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .artifactRelativePath,
              metallibByteCount > 0,
              metallibByteCount
                <= PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .maximumByteCount,
              isCheckpointV2ExecutionSHA256(metallibSHA256),
              existingMetallibCandidateCountBeforeExecution == 1,
              existingMetallibCandidateCountAfterExecution == 1,
              metallibPathAndDescriptorReverified,
              metalLibraryValidatedFromExactURL,
              focusedContractLogsValidatedBeforeReclamation,
              frozen44MetalLogValidatedBeforeReclamation,
              maintainedRuntimeAuthorityLogAndReceiptValidatedBeforeReclamation,
              tokenizerAuthorityLogAndReceiptValidatedBeforeReclamation,
              predecessorValidatedLogCount
                == authority.predecessorValidatedLogCount,
              predecessorValidatedReceiptCount
                == authority.predecessorValidatedReceiptCount,
              predecessorFailureObservationConsumedByAuthoritySource,
              predecessorFailureObservationConsumedByAuthoritySource
                == authority
                    .predecessorFailureObservationRequiredForConsumption,
              exhaustedSeed42PublicWriteCompletionCountSourceInferred
                == authority
                    .exhaustedSeed42PublicWriteCompletionCountSourceInferred,
              exhaustedSeed42PublicLoadCompletionCountSourceInferred
                == authority
                    .exhaustedSeed42PublicLoadCompletionCountSourceInferred,
              cumulativePublicWriteCompletionCountSourceInferredAfterSuccess
                == authority
                    .cumulativePublicWriteCompletionCountSourceInferredAfterSuccess,
              cumulativePublicLoadCompletionCountSourceInferredAfterSuccess
                == authority
                    .cumulativePublicLoadCompletionCountSourceInferredAfterSuccess,
              knownRunnerTemporaryReclamationPathCount
                == authority.reclaimableRunnerTemporaryRelativePaths.count,
              knownRunnerTemporaryPathsAbsentBeforeProbe,
              availableFilesystemBytesAfterReclamation
                >= authority.requiredAvailableFilesystemBytesAfterBuild,
              availableFilesystemBytesAfterBuild
                >= authority.requiredAvailableFilesystemBytesAfterBuild,
              requiredFreeSpaceMultiplier
                == authority.requiredFreeSpaceMultiplier,
              freeSpacePreflightPassed,
              artifactRootPathIsAbsolute,
              artifactRootOwnerMatchedEffectiveUser,
              artifactRootInitiallyEmpty,
              artifactRootEntryCountAfterWrite
                == authority.requiredArtifactRootEntryCountAfterWrite,
              artifactRootEntryNamesBeforeWrite
                == authority.requiredArtifactRootEntryNamesBeforeWrite,
              artifactRootEntryNamesBeforeWrite.count
                == authority.requiredArtifactRootEntryCountBeforeWrite,
              artifactRootEntryNamesAfterWrite
                == authority.requiredArtifactRootEntryNamesAfterWrite,
              artifactRootEntryNamesAfterWrite.count
                == artifactRootEntryCountAfterWrite,
              publishedArtifactIsRegularFile,
              !publishedArtifactIsSymbolicLink,
              publishedArtifactDeviceMatchedRoot,
              publishedArtifactOwnerMatchedEffectiveUser,
              publicationStableFiveFieldsMatched,
              publicationStableFiveFieldsMatched
                == artifactRootIdentityBeforeWrite
                    .publicationStableObjectFieldsEqual(
                        to: artifactRootIdentityAfterWrite),
              publicationRootLinkCountsPositive,
              publicationRootLinkCountsPositive
                == (artifactRootIdentityBeforeWrite.linkCount > 0
                    && artifactRootIdentityAfterWrite.linkCount > 0),
              readOnlyFullRootIdentityMatched,
              readOnlyFullRootIdentityMatched
                == artifactRootIdentityAfterWrite
                    .readOnlyFullIdentityEqual(
                        to: artifactRootIdentityAfterLoad),
              artifactRootIdentityBeforeWrite
                .publicationStableObjectFieldsEqual(
                  to: artifactRootIdentityAfterWrite),
              artifactRootIdentityAfterWrite.readOnlyFullIdentityEqual(
                  to: artifactRootIdentityAfterLoad),
              compatibilityIdentityCanonicalByteCount
                == authority.compatibilityIdentityCanonicalByteCount,
              compatibilityIdentityCanonicalByteCount
                == identityBytes.count,
              compatibilityIdentitySHA256
                == authority.compatibilityIdentitySHA256,
              compatibilityIdentitySHA256
                == PrimeSHA256.hexDigest(of: identityBytes),
              compatibilityIdentityValidated,
              configuration == authority.configuration,
              initializationSeed == authority.initializationSeed,
              callerSourceModelConstructionCount
                == authority.requiredCallerSourceModelConstructionCount,
              initialParameterMaterializationEvaluationCount
                == authority.requiredInitialParameterMaterializationEvaluationCount,
              initialParameterMaterializationEvaluationAPI
                == authority.initialParameterMaterializationEvaluationAPI,
              memoryCacheLimit == authority.requiredMemoryCacheLimit,
              memoryCacheClearCount == authority.requiredMemoryCacheClearCount,
              cacheClearedBeforeSourceMaterialization,
              sourceModelReferenceLexicalScopeEndedBeforePublicLoad,
              cacheClearedBetweenSourceWriteAndPublicLoad,
              publicCheckpointWriteInvocationCount
                == authority.requiredPublicWriteInvocationCount,
              publicCheckpointWriteCompletionCount
                == authority.requiredPublicWriteCompletionCount,
              publicCheckpointLoadInvocationCount
                == authority.requiredPublicLoadInvocationCount,
              publicCheckpointLoadCompletionCount
                == authority.requiredPublicLoadCompletionCount,
              totalDecoderConstructionCountIsSourceInferredOnly,
              sourceInferredDecoderConstructionCount
                == authority
                    .sourceInferredDecoderConstructionCountForRepairJob,
              containerMaterializationCountRequiredByPinnedCodec
                == authority.containerMaterializationCountRequiredByPinnedCodec,
              freshLoadedModelConstructionRequiredByPinnedCodec,
              externalBindingCanonicalByteCount
                == UInt64(externalBindingBytes.count),
              externalBindingCanonicalSHA256
                == PrimeSHA256.hexDigest(of: externalBindingBytes),
              manifestCanonicalByteCount == UInt64(manifestBytes.count),
              manifestCanonicalByteCount
                == externalBinding.manifestCanonicalByteCount,
              manifestCanonicalSHA256
                == PrimeSHA256.hexDigest(of: manifestBytes),
              manifestCanonicalSHA256
                == externalBinding.manifestCanonicalSHA256,
              manifestValidated,
              tensorBindingCount == authority.parameterDescriptorCount,
              tensorBindingCount
                == externalBinding.manifest.tensorBindings.count,
              tensorBindingsCanonicalByteCount
                == UInt64(tensorBindingBytes.count),
              tensorBindingsSHA256
                == PrimeSHA256.hexDigest(of: tensorBindingBytes),
              tensorBindingsSHA256
                == externalBinding.manifest.tensorBindingsSHA256,
              observedParameterCount == authority.totalParameterCount,
              observedParameterByteCount == authority.totalParameterByteCount,
              artifactBinding.relativePath == authority.artifactRelativePath,
              artifactBinding.purpose.rawValue == authority.artifactPurpose,
              artifactBinding.byteCount > authority.totalParameterByteCount,
              artifactBinding.byteCount
                <= authority.maximumCheckpointByteCount,
              isCheckpointV2ExecutionSHA256(artifactBinding.sha256),
              publishedArtifactMode
                == authority.requiredPublishedArtifactMode,
              publishedArtifactLinkCount
                == authority.requiredPublishedArtifactLinkCount,
              writerHiddenDescriptorRestoreAndReinspectionCompletedViaSuccessfulPinnedCodecReturn,
              loadedParameterCatalogAndLogicalHashesMatchedManifestViaPinnedCodec,
              loadedStructuralParameterCatalogMatched,
              artifactBindingVerifiedBeforeAndAfterCompleteMaterializationViaPinnedArtifactRoot,
              exclusiveNoReplacePublicationCompleted,
              generatedFileAndParentSynchronizationReturnedSuccess,
              positiveClaimsAreExact,
              falseCeilingsAreExact,
              processExitRequiredAfterReceipt,
              cleanupRequiredAfterParentReceiptVerification,
              !successCleanupCompletedBeforeReceipt,
              parentSuccessCleanupRequiredAfterReceipt,
              parentSuccessCleanupRequiredAfterReceipt
                == authority
                    .parentReceiptVerificationRequiredBeforeSuccessCleanup,
              status
                == "PASS_process_local_seed43_native300m_v2_checkpoint_root_identity_repair_one_public_write_one_public_fresh_load_only"
        else {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError
                    .contractDrift
        }
    }

    public func canonicalReceiptData() throws -> Data {
        try validate()
        let data = try PrimeCanonicalJSON.encode(self)
        guard UInt64(data.count)
                <= PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityPlanV1
                    .frozenV1.maximumCanonicalReceiptByteCount
        else {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError
                    .contractDrift
        }
        return data
    }

    public static func decodeCanonicalReceipt(
        from data: Data
    ) throws -> Self {
        let result = try PrimeCanonicalJSON.decode(
            Self.self,
            from: data,
            artifact: "checkpoint-v2-container-io-execution-receipt")
        try result.validate()
        return result
    }

    private var positiveClaimsAreExact: Bool {
        predecessorFailureObservationConsumedByAuthoritySource
            && publishedArtifactIsRegularFile
            && publishedArtifactDeviceMatchedRoot
            && publishedArtifactOwnerMatchedEffectiveUser
            && publicationStableFiveFieldsMatched
            && publicationRootLinkCountsPositive
            && readOnlyFullRootIdentityMatched
            && parentSuccessCleanupRequiredAfterReceipt
            && native300MModelAllocationObserved
            && native300MCheckpointWriteObserved
            && native300MCheckpointLoadObserved
            && checkpointIOObserved
            && checkpointArtifactAvailableDuringProcess
            && checkpointContainerHashBound
            && checkpointDurabilityMechanicsCompleted
            && logicalParameterRoundTripViaPinnedCodecObserved
            && runtimeDependencyClosurePredecessorReceiptValidatedForCheckpointIO
    }

    private var falseCeilingsAreExact: Bool {
        !publishedArtifactIsSymbolicLink
            && !successCleanupCompletedBeforeReceipt
            && !callerSuppliedRevisionBindingIsIndependentObservation
            && !loadedMetallibIdentityIndependentlyObserved
            && !physicalGPUIdentityEstablished
            && !tf32StaticValueDirectlyObserved
            && !tf32DifferentialObserved
            && !deterministicSeedReplayObserved
            && !reproducibleCheckpointSerializationObserved
            && !secondIndependentWriteObserved
            && !independentPostLoadTensorHashReplayObserved
            && !independentCodecComparatorObserved
            && !independentPostLoadArtifactRootVerifyObserved
            && !sourceModelARCDeallocationObserved
            && !artifactUploadInvokedBeforeReceipt
            && !checkpointArtifactAvailabilityBeyondProcessEstablished
            && !checkpointArtifactRetentionEstablished
            && !checkpointArtifactProvenanceEstablished
            && !checkpointAdmissionGranted
            && !existingCheckpointArtifactCompatibilityObserved
            && !atomicCheckpointReplacementEstablished
            && !failedCheckpointWriteRecoveryObserved
            && !checkpointLoadedForwardObserved
            && !checkpointRoundTripBehaviorParityEstablished
            && !optimizerStateIncluded
            && !rngStateIncluded
            && !dataCursorIncluded
            && !kvCacheStateIncluded
            && !decoderForwardObserved
            && !decoderKVCacheUsed
            && !backwardInvoked
            && !lossObserved
            && !optimizerStepObserved
            && !generationInvoked
            && !trainEvaluateSurfaceEstablished
            && !trainingResumeEstablished
            && !trainingExecutionObserved
            && !modelQualityEstablished
            && !candidateAdmissionGranted
            && !trialAuthorized
            && !canaryReplacementAuthorized
            && !quantizationAuthorized
            && !productUseAuthorized
            && !publicationAuthorized
            && !retryObserved
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case evidenceID = "evidence_id"
        case authorityID = "authority_id"
        case executedRevision = "executed_revision"
        case executedOrderedParentRevisions =
            "executed_ordered_parent_revisions"
        case executedTree = "executed_tree"
        case reviewedPullRequestHeadTree =
            "reviewed_pull_request_head_tree"
        case executedEmbeddedSourceIdentitySHA256 =
            "executed_embedded_source_identity_sha256"
        case executionEvent = "execution_event"
        case executionRef = "execution_ref"
        case executionRunAttempt = "execution_run_attempt"
        case executionRepository = "execution_repository"
        case githubActions = "github_actions"
        case runnerEnvironment = "runner_environment"
        case operatingSystem = "operating_system"
        case architecture
        case exactRevisionMatchedGitHubSHA =
            "exact_revision_matched_github_sha"
        case environmentPolicy = "environment_policy"
        case launchedEnvironmentValidatedBeforeFrameworkAccess =
            "launched_environment_validated_before_framework_access"
        case launchedEnvironmentRevalidatedAfterEvaluation =
            "launched_environment_revalidated_after_evaluation"
        case releaseInstrumentationEvidenceAbsent =
            "release_instrumentation_evidence_absent"
        case coreGraphicsBootstrapObserved =
            "core_graphics_bootstrap_observed"
        case enumeratedMetalDeviceCount = "enumerated_metal_device_count"
        case defaultMetalDeviceMatchedIndexZero =
            "default_metal_device_matched_index_zero"
        case mlxDeviceType = "mlx_device_type"
        case mlxDeviceIndex = "mlx_device_index"
        case metalLeaseHeldBeforeAndAfterEvaluation =
            "metal_lease_held_before_and_after_evaluation"
        case metallibArtifactRelativePath =
            "metallib_artifact_relative_path"
        case metallibByteCount = "metallib_byte_count"
        case metallibSHA256 = "metallib_sha256"
        case existingMetallibCandidateCountBeforeExecution =
            "existing_metallib_candidate_count_before_execution"
        case existingMetallibCandidateCountAfterExecution =
            "existing_metallib_candidate_count_after_execution"
        case metallibPathAndDescriptorReverified =
            "metallib_path_and_descriptor_reverified"
        case metalLibraryValidatedFromExactURL =
            "metal_library_validated_from_exact_url"
        case focusedContractLogsValidatedBeforeReclamation =
            "focused_contract_logs_validated_before_reclamation"
        case frozen44MetalLogValidatedBeforeReclamation =
            "frozen_44_metal_log_validated_before_reclamation"
        case maintainedRuntimeAuthorityLogAndReceiptValidatedBeforeReclamation =
            "maintained_runtime_authority_log_and_receipt_validated_before_reclamation"
        case tokenizerAuthorityLogAndReceiptValidatedBeforeReclamation =
            "tokenizer_authority_log_and_receipt_validated_before_reclamation"
        case predecessorValidatedLogCount =
            "predecessor_validated_log_count"
        case predecessorValidatedReceiptCount =
            "predecessor_validated_receipt_count"
        case predecessorFailureObservationConsumedByAuthoritySource =
            "predecessor_failure_observation_consumed_by_authority_source"
        case exhaustedSeed42PublicWriteCompletionCountSourceInferred =
            "exhausted_seed42_public_write_completion_count_source_inferred"
        case exhaustedSeed42PublicLoadCompletionCountSourceInferred =
            "exhausted_seed42_public_load_completion_count_source_inferred"
        case cumulativePublicWriteCompletionCountSourceInferredAfterSuccess =
            "cumulative_public_write_completion_count_source_inferred_after_success"
        case cumulativePublicLoadCompletionCountSourceInferredAfterSuccess =
            "cumulative_public_load_completion_count_source_inferred_after_success"
        case knownRunnerTemporaryReclamationPathCount =
            "known_runner_temporary_reclamation_path_count"
        case knownRunnerTemporaryPathsAbsentBeforeProbe =
            "known_runner_temporary_paths_absent_before_probe"
        case availableFilesystemBytesAfterReclamation =
            "available_filesystem_bytes_after_reclamation"
        case availableFilesystemBytesAfterBuild =
            "available_filesystem_bytes_after_build"
        case requiredFreeSpaceMultiplier =
            "required_free_space_multiplier"
        case freeSpacePreflightPassed = "free_space_preflight_passed"
        case artifactRootPathIsAbsolute = "artifact_root_path_is_absolute"
        case artifactRootOwnerMatchedEffectiveUser =
            "artifact_root_owner_matched_effective_user"
        case artifactRootInitiallyEmpty = "artifact_root_initially_empty"
        case artifactRootEntryCountAfterWrite =
            "artifact_root_entry_count_after_write"
        case artifactRootIdentityBeforeWrite =
            "artifact_root_identity_before_write"
        case artifactRootIdentityAfterWrite =
            "artifact_root_identity_after_write"
        case artifactRootIdentityAfterLoad =
            "artifact_root_identity_after_load"
        case artifactRootEntryNamesBeforeWrite =
            "artifact_root_entry_names_before_write"
        case artifactRootEntryNamesAfterWrite =
            "artifact_root_entry_names_after_write"
        case publishedArtifactIsRegularFile =
            "published_artifact_is_regular_file"
        case publishedArtifactIsSymbolicLink =
            "published_artifact_is_symbolic_link"
        case publishedArtifactDeviceMatchedRoot =
            "published_artifact_device_matched_root"
        case publishedArtifactOwnerMatchedEffectiveUser =
            "published_artifact_owner_matched_effective_user"
        case publicationStableFiveFieldsMatched =
            "publication_stable_five_fields_matched"
        case publicationRootLinkCountsPositive =
            "publication_root_link_counts_positive"
        case readOnlyFullRootIdentityMatched =
            "read_only_full_root_identity_matched"
        case compatibilityIdentityCanonicalByteCount =
            "compatibility_identity_canonical_byte_count"
        case compatibilityIdentitySHA256 =
            "compatibility_identity_sha256"
        case compatibilityIdentityValidated =
            "compatibility_identity_validated"
        case configuration
        case initializationSeed = "initialization_seed"
        case callerSourceModelConstructionCount =
            "caller_source_model_construction_count"
        case initialParameterMaterializationEvaluationCount =
            "initial_parameter_materialization_evaluation_count"
        case initialParameterMaterializationEvaluationAPI =
            "initial_parameter_materialization_evaluation_api"
        case memoryCacheLimit = "memory_cache_limit"
        case memoryCacheClearCount = "memory_cache_clear_count"
        case cacheClearedBeforeSourceMaterialization =
            "cache_cleared_before_source_materialization"
        case sourceModelReferenceLexicalScopeEndedBeforePublicLoad =
            "source_model_reference_lexical_scope_ended_before_public_load"
        case cacheClearedBetweenSourceWriteAndPublicLoad =
            "cache_cleared_between_source_write_and_public_load"
        case publicCheckpointWriteInvocationCount =
            "public_checkpoint_write_invocation_count"
        case publicCheckpointWriteCompletionCount =
            "public_checkpoint_write_completion_count"
        case publicCheckpointLoadInvocationCount =
            "public_checkpoint_load_invocation_count"
        case publicCheckpointLoadCompletionCount =
            "public_checkpoint_load_completion_count"
        case totalDecoderConstructionCountIsSourceInferredOnly =
            "total_decoder_construction_count_is_source_inferred_only"
        case sourceInferredDecoderConstructionCount =
            "source_inferred_decoder_construction_count"
        case containerMaterializationCountRequiredByPinnedCodec =
            "container_materialization_count_required_by_pinned_codec"
        case freshLoadedModelConstructionRequiredByPinnedCodec =
            "fresh_loaded_model_construction_required_by_pinned_codec"
        case externalBinding = "external_binding"
        case externalBindingCanonicalByteCount =
            "external_binding_canonical_byte_count"
        case externalBindingCanonicalSHA256 =
            "external_binding_canonical_sha256"
        case manifestCanonicalByteCount = "manifest_canonical_byte_count"
        case manifestCanonicalSHA256 = "manifest_canonical_sha256"
        case manifestValidated = "manifest_validated"
        case tensorBindingCount = "tensor_binding_count"
        case tensorBindingsCanonicalByteCount =
            "tensor_bindings_canonical_byte_count"
        case tensorBindingsSHA256 = "tensor_bindings_sha256"
        case observedParameterCount = "observed_parameter_count"
        case observedParameterByteCount = "observed_parameter_byte_count"
        case publishedArtifactMode = "published_artifact_mode"
        case publishedArtifactLinkCount = "published_artifact_link_count"
        case writerHiddenDescriptorRestoreAndReinspectionCompletedViaSuccessfulPinnedCodecReturn =
            "writer_hidden_descriptor_restore_and_reinspection_completed_via_successful_pinned_codec_return"
        case loadedParameterCatalogAndLogicalHashesMatchedManifestViaPinnedCodec =
            "loaded_parameter_catalog_and_logical_hashes_matched_manifest_via_pinned_codec"
        case loadedStructuralParameterCatalogMatched =
            "loaded_structural_parameter_catalog_matched"
        case artifactBindingVerifiedBeforeAndAfterCompleteMaterializationViaPinnedArtifactRoot =
            "artifact_binding_verified_before_and_after_complete_materialization_via_pinned_artifact_root"
        case exclusiveNoReplacePublicationCompleted =
            "exclusive_no_replace_publication_completed"
        case generatedFileAndParentSynchronizationReturnedSuccess =
            "generated_file_and_parent_synchronization_returned_success"
        case native300MModelAllocationObserved =
            "native300m_model_allocation_observed"
        case native300MCheckpointWriteObserved =
            "native300m_checkpoint_write_observed"
        case native300MCheckpointLoadObserved =
            "native300m_checkpoint_load_observed"
        case checkpointIOObserved = "checkpoint_io_observed"
        case checkpointArtifactAvailableDuringProcess =
            "checkpoint_artifact_available_during_process"
        case checkpointContainerHashBound =
            "checkpoint_container_hash_bound"
        case checkpointDurabilityMechanicsCompleted =
            "checkpoint_durability_mechanics_completed"
        case logicalParameterRoundTripViaPinnedCodecObserved =
            "logical_parameter_round_trip_via_pinned_codec_observed"
        case runtimeDependencyClosurePredecessorReceiptValidatedForCheckpointIO =
            "runtime_dependency_closure_predecessor_receipt_validated_for_checkpoint_io"
        case callerSuppliedRevisionBindingIsIndependentObservation =
            "caller_supplied_revision_binding_is_independent_observation"
        case loadedMetallibIdentityIndependentlyObserved =
            "loaded_metallib_identity_independently_observed"
        case physicalGPUIdentityEstablished =
            "physical_gpu_identity_established"
        case tf32StaticValueDirectlyObserved =
            "tf32_static_value_directly_observed"
        case tf32DifferentialObserved = "tf32_differential_observed"
        case deterministicSeedReplayObserved =
            "deterministic_seed_replay_observed"
        case reproducibleCheckpointSerializationObserved =
            "reproducible_checkpoint_serialization_observed"
        case secondIndependentWriteObserved =
            "second_independent_write_observed"
        case independentPostLoadTensorHashReplayObserved =
            "independent_post_load_tensor_hash_replay_observed"
        case independentCodecComparatorObserved =
            "independent_codec_comparator_observed"
        case independentPostLoadArtifactRootVerifyObserved =
            "independent_post_load_artifact_root_verify_observed"
        case sourceModelARCDeallocationObserved =
            "source_model_arc_deallocation_observed"
        case artifactUploadInvokedBeforeReceipt =
            "artifact_upload_invoked_before_receipt"
        case checkpointArtifactAvailabilityBeyondProcessEstablished =
            "checkpoint_artifact_availability_beyond_process_established"
        case checkpointArtifactRetentionEstablished =
            "checkpoint_artifact_retention_established"
        case checkpointArtifactProvenanceEstablished =
            "checkpoint_artifact_provenance_established"
        case checkpointAdmissionGranted = "checkpoint_admission_granted"
        case existingCheckpointArtifactCompatibilityObserved =
            "existing_checkpoint_artifact_compatibility_observed"
        case atomicCheckpointReplacementEstablished =
            "atomic_checkpoint_replacement_established"
        case failedCheckpointWriteRecoveryObserved =
            "failed_checkpoint_write_recovery_observed"
        case checkpointLoadedForwardObserved =
            "checkpoint_loaded_forward_observed"
        case checkpointRoundTripBehaviorParityEstablished =
            "checkpoint_round_trip_behavior_parity_established"
        case optimizerStateIncluded = "optimizer_state_included"
        case rngStateIncluded = "rng_state_included"
        case dataCursorIncluded = "data_cursor_included"
        case kvCacheStateIncluded = "kv_cache_state_included"
        case decoderForwardObserved = "decoder_forward_observed"
        case decoderKVCacheUsed = "decoder_kv_cache_used"
        case backwardInvoked = "backward_invoked"
        case lossObserved = "loss_observed"
        case optimizerStepObserved = "optimizer_step_observed"
        case generationInvoked = "generation_invoked"
        case trainEvaluateSurfaceEstablished =
            "train_evaluate_surface_established"
        case trainingResumeEstablished = "training_resume_established"
        case trainingExecutionObserved = "training_execution_observed"
        case modelQualityEstablished = "model_quality_established"
        case candidateAdmissionGranted = "candidate_admission_granted"
        case trialAuthorized = "trial_authorized"
        case canaryReplacementAuthorized = "canary_replacement_authorized"
        case quantizationAuthorized = "quantization_authorized"
        case productUseAuthorized = "product_use_authorized"
        case publicationAuthorized = "publication_authorized"
        case retryObserved = "retry_observed"
        case processExitRequiredAfterReceipt =
            "process_exit_required_after_receipt"
        case cleanupRequiredAfterParentReceiptVerification =
            "cleanup_required_after_parent_receipt_verification"
        case successCleanupCompletedBeforeReceipt =
            "success_cleanup_completed_before_receipt"
        case parentSuccessCleanupRequiredAfterReceipt =
            "parent_success_cleanup_required_after_receipt"
        case status
    }
}

private func isCheckpointV2ExecutionSHA256(
    _ value: String
) -> Bool {
    isCheckpointV2ExecutionLowercaseHex(value, count: 64)
}

private func isCheckpointV2ExecutionGitObjectID(
    _ value: String
) -> Bool {
    isCheckpointV2ExecutionLowercaseHex(value, count: 40)
}

private func isCheckpointV2ExecutionLowercaseHex(
    _ value: String,
    count: Int
) -> Bool {
    value.utf8.count == count
        && value.utf8.allSatisfy { byte in
            (48 ... 57).contains(byte) || (97 ... 102).contains(byte)
        }
        && value != String(repeating: "0", count: count)
}
