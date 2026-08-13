// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case nonCanonicalEncoding
}

public struct PrimeNativeDecoderStage4MechanicsExecutionRunV1:
    Codable,
    Equatable,
    Sendable
{
    public let mergeRevision: String
    public let mergeTree: String
    public let orderedParentRevisions: [String]
    public let workflowRunID: Int
    public let workflowRunNumber: Int
    public let checkSuiteID: Int
    public let runAttempt: Int
    public let activeJobID: Int
    public let reviewedJobID: Int
    public let activeJobConclusion: String
    public let reviewedJobConclusion: String
    public let exactHeadPushRunCount: Int
    public let rerunCount: Int
    public let artifactCount: Int
    public let terminalConclusion: String
}

public struct PrimeNativeDecoderStage4MechanicsExecutionPredecessorV1:
    Codable,
    Equatable,
    Sendable
{
    public let focusedRootTestCount: Int
    public let focusedIsolatedTestCount: Int
    public let focusedWholeTestCount: Int
    public let metalTestCount: Int
    public let maintainedRuntimeTestCount: Int
    public let tokenizerTestCount: Int
    public let preStage4TotalTestCount: Int
    public let exactLiveOrder: [String]
    public let allPassed: Bool
}

public struct PrimeNativeDecoderStage4MechanicsExecutionMetallibV1:
    Codable,
    Equatable,
    Sendable
{
    public let byteCount: Int
    public let sha256: String
    public let sourceCandidateCount: Int
    public let stagedCopyCount: Int
    public let stagedPermissionMode: String
    public let loadedPathInferred: Bool
    public let independentlyObservedLoadedIdentity: Bool
    public let retainedAfterJob: Bool
    public let artifactProvenanceEstablished: Bool
}

public struct PrimeNativeDecoderStage4MechanicsExecutionSecureFetchV1:
    Codable,
    Equatable,
    Sendable
{
    public let stepConclusion: String
    public let invocationCount: Int
    public let completionCount: Int
    public let authenticatedDepthOneFetchCount: Int
    public let submoduleUpdateInvocationCount: Int
    public let mlxCloneCount: Int
    public let mlxCCloneCount: Int
    public let workflowAuthoredRetryCount: Int
    public let gitInternalRetryScheduledCount: Int
    public let tlsFailureCount: Int
    public let tlsVerificationBypassCount: Int
    public let customCAInstallationCount: Int
}

public struct PrimeNativeDecoderStage4MechanicsExecutionReceiptV1:
    Codable,
    Equatable,
    Sendable
{
    public let authorityCanonicalSHA256: String
    public let repairAuthorityCanonicalSHA256: String
    public let receiptID: String
    public let receiptPrefixOccurrenceCount: Int
    public let rawJSONByteCount: Int
    public let rawJSONSHA256: String
    public let rawJSONWasCanonical: Bool
    public let status: String
    public let embeddedSourceIdentitySHA256: String
    public let buildCount: Int
    public let directXCTestCount: Int
    public let testClass: String
    public let testMethod: String
    public let testFilter: String
    public let startedCount: Int
    public let passedCount: Int
    public let failureCount: Int
    public let skipCount: Int
    public let durationMilliseconds: Int
    public let totalTestCountAfterStage4: Int
    public let publishedFileCount: Int
    public let exactPublicationOrder: [String]
    public let injectedFailureCount: Int
    public let finalCommitManifestPublishedLast: Bool
    public let externallySuppliedExactCommitBindingRequired: Bool
    public let everyPartialPrecommitInventoryQuarantined: Bool
    public let exactStage3SnapshotRoundTripEstablished: Bool
}

public struct PrimeNativeDecoderStage4MechanicsExecutionArtifactV1:
    Codable,
    Equatable,
    Sendable
{
    public let ephemeralPrivateRoot: Bool
    public let initiallyEmpty: Bool
    public let reclaimedAfterTest: Bool
    public let retainedArtifactEstablished: Bool
    public let artifactUploadInvoked: Bool
}

public struct PrimeNativeDecoderStage4MechanicsExecutionRetirementV1:
    Codable,
    Equatable,
    Sendable
{
    public let exactChangedPaths: [String]
    public let expectedRootTestCount: Int
    public let reviewedCheckoutDepth: Int
    public let retainedLiveOrder: [String]
    public let stage4LauncherPath: String
    public let stage4LauncherMode: String
    public let stage4LauncherGitBlob: String
    public let stage4LauncherByteCount: Int
    public let stage4LauncherLFByteCount: Int
    public let stage4LauncherSHA256: String
    public let stage4LauncherInvocationCount: Int
    public let stage4ReceiptCount: Int
    public let stage4LauncherSourcePreserved: Bool
    public let successfulAttemptConsumed: Bool
    public let exactMainRetirementClosureRequired: Bool
}

public struct PrimeNativeDecoderStage4MechanicsExecutionCeilingV1:
    Codable,
    Equatable,
    Sendable
{
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

/// Immutable observation of the one terminal green Stage-4 mechanics attempt.
/// This value records evidence only; it performs no filesystem, checkpoint,
/// training, network, Metal, artifact, or publication operation.
public struct PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public static let canonicalSHA256 =
        "7239edc86e007b1a8b6fa7a742bfb812e8ef8caa4b1dc8dbcb32b66b5b88e5e0"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_tiny_durable_multileaf_commit_fault_injection_execution_observation_v1",
        run: .init(
            mergeRevision:
                "8c310bb61fb9b44f1e789332eb3cfc29681ee407",
            mergeTree:
                "4508cd0d62cfe6e9405ea2b9e4cfcb197965c5e5",
            orderedParentRevisions: [
                "f15f22b580aebf924c1dfc4a5636263f962a659c",
                "ef9fc40c9bc947f78910f9f8cf8a243566f63728",
            ],
            workflowRunID: 31_726_013_984,
            workflowRunNumber: 97,
            checkSuiteID: 86_069_785_338,
            runAttempt: 1,
            activeJobID: 94_534_454_341,
            reviewedJobID: 94_535_376_461,
            activeJobConclusion: "success",
            reviewedJobConclusion: "success",
            exactHeadPushRunCount: 1,
            rerunCount: 0,
            artifactCount: 0,
            terminalConclusion: "success"),
        predecessor: .init(
            focusedRootTestCount: 50,
            focusedIsolatedTestCount: 6,
            focusedWholeTestCount: 56,
            metalTestCount: 44,
            maintainedRuntimeTestCount: 1,
            tokenizerTestCount: 1,
            preStage4TotalTestCount: 102,
            exactLiveOrder: [
                "root",
                "metal",
                "maintained_runtime",
                "tokenizer",
                "stage4",
            ],
            allPassed: true),
        secureFetch: .init(
            stepConclusion: "success",
            invocationCount: 1,
            completionCount: 1,
            authenticatedDepthOneFetchCount: 1,
            submoduleUpdateInvocationCount: 1,
            mlxCloneCount: 1,
            mlxCCloneCount: 1,
            workflowAuthoredRetryCount: 0,
            gitInternalRetryScheduledCount: 0,
            tlsFailureCount: 0,
            tlsVerificationBypassCount: 0,
            customCAInstallationCount: 0),
        metallib: .init(
            byteCount: 6_292_668,
            sha256:
                "b5045fe8a1a77aaefd249a7460aca65940fde3aff7422de73da0a9fba7134fd6",
            sourceCandidateCount: 1,
            stagedCopyCount: 2,
            stagedPermissionMode: "444",
            loadedPathInferred: false,
            independentlyObservedLoadedIdentity: false,
            retainedAfterJob: false,
            artifactProvenanceEstablished: false),
        receipt: .init(
            authorityCanonicalSHA256:
                "0b167685f0cc10cbf5d705d6cf67b72b54555dfa52b9f4aaebd00613e057b031",
            repairAuthorityCanonicalSHA256:
                "6a6dfc7b30319f9ccc1d17c2f08282c266962cd500d47696cbb42b4b1b0ff826",
            receiptID:
                "prime_native_decoder_stage4_tiny_durable_multileaf_receipt_v1",
            receiptPrefixOccurrenceCount: 1,
            rawJSONByteCount: 4_147,
            rawJSONSHA256:
                "a0bbebb611b12ef1e88ffe625120b86a3a0caf7f29f0edbf20233c7fbe244fbd",
            rawJSONWasCanonical: true,
            status:
                "PASS_exact_main_tiny_ephemeral_durable_four_leaf_commit_fault_injection_one_test_zero_failure_zero_skip",
            embeddedSourceIdentitySHA256:
                "d6acf9c5e3e656e93a39d6c36529902d0b8c9ba1454dbd706a76aa53b7276ced",
            buildCount: 1,
            directXCTestCount: 1,
            testClass:
                "PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests",
            testMethod:
                "testTinyDurableMultileafCommitIsExactAndFailClosed",
            testFilter:
                "PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests/testTinyDurableMultileafCommitIsExactAndFailClosed",
            startedCount: 1,
            passedCount: 1,
            failureCount: 0,
            skipCount: 0,
            durationMilliseconds: 5_128,
            totalTestCountAfterStage4: 103,
            publishedFileCount: 4,
            exactPublicationOrder: [
                "weights_v2",
                "optimizer_moments",
                "control_state_manifest",
                "commit_manifest",
            ],
            injectedFailureCount: 7,
            finalCommitManifestPublishedLast: true,
            externallySuppliedExactCommitBindingRequired: true,
            everyPartialPrecommitInventoryQuarantined: true,
            exactStage3SnapshotRoundTripEstablished: true),
        artifact: .init(
            ephemeralPrivateRoot: true,
            initiallyEmpty: true,
            reclaimedAfterTest: true,
            retainedArtifactEstablished: false,
            artifactUploadInvoked: false),
        retirement: .init(
            exactChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservation.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservationTests.swift",
            ],
            expectedRootTestCount: 51,
            reviewedCheckoutDepth: 1,
            retainedLiveOrder: [
                "metal",
                "maintained_runtime",
                "tokenizer",
            ],
            stage4LauncherPath:
                ".github/scripts/prime-ci-native-decoder-stage4-tiny-durable-multileaf.sh",
            stage4LauncherMode: "100755",
            stage4LauncherGitBlob:
                "4184e23941460fe397e284e094d782f1265d19d9",
            stage4LauncherByteCount: 31_829,
            stage4LauncherLFByteCount: 519,
            stage4LauncherSHA256:
                "e3eb8a66340c924bbb579023eee04eaee1242a8a682f17ae668898ee8d36c6a2",
            stage4LauncherInvocationCount: 0,
            stage4ReceiptCount: 0,
            stage4LauncherSourcePreserved: true,
            successfulAttemptConsumed: true,
            exactMainRetirementClosureRequired: true),
        ceiling: .init(
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
            publicationAuthorized: false))

    public let schemaVersion: Int
    public let observationID: String
    public let run: PrimeNativeDecoderStage4MechanicsExecutionRunV1
    public let predecessor:
        PrimeNativeDecoderStage4MechanicsExecutionPredecessorV1
    public let secureFetch:
        PrimeNativeDecoderStage4MechanicsExecutionSecureFetchV1
    public let metallib: PrimeNativeDecoderStage4MechanicsExecutionMetallibV1
    public let receipt: PrimeNativeDecoderStage4MechanicsExecutionReceiptV1
    public let artifact: PrimeNativeDecoderStage4MechanicsExecutionArtifactV1
    public let retirement:
        PrimeNativeDecoderStage4MechanicsExecutionRetirementV1
    public let ceiling: PrimeNativeDecoderStage4MechanicsExecutionCeilingV1

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservationError
                .contractDrift
        }
        let falseCeilings = [
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
              observationID
                == "ergentics_prime_native_decoder_tiny_durable_multileaf_commit_fault_injection_execution_observation_v1",
              run.orderedParentRevisions.count == 2,
              run.runAttempt == 1,
              run.exactHeadPushRunCount == 1,
              run.rerunCount == 0,
              run.artifactCount == 0,
              run.terminalConclusion == "success",
              run.activeJobConclusion == "success",
              run.reviewedJobConclusion == "success",
              predecessor.focusedRootTestCount == 50,
              predecessor.focusedIsolatedTestCount == 6,
              predecessor.focusedWholeTestCount == 56,
              predecessor.focusedRootTestCount
                + predecessor.focusedIsolatedTestCount
                == predecessor.focusedWholeTestCount,
              predecessor.metalTestCount == 44,
              predecessor.maintainedRuntimeTestCount == 1,
              predecessor.tokenizerTestCount == 1,
              predecessor.preStage4TotalTestCount == 102,
              predecessor.exactLiveOrder
                == [
                    "root",
                    "metal",
                    "maintained_runtime",
                    "tokenizer",
                    "stage4",
                ],
              predecessor.allPassed,
              secureFetch.stepConclusion == "success",
              secureFetch.invocationCount == 1,
              secureFetch.completionCount == 1,
              secureFetch.authenticatedDepthOneFetchCount == 1,
              secureFetch.submoduleUpdateInvocationCount == 1,
              secureFetch.mlxCloneCount == 1,
              secureFetch.mlxCCloneCount == 1,
              secureFetch.workflowAuthoredRetryCount == 0,
              secureFetch.gitInternalRetryScheduledCount == 0,
              secureFetch.tlsFailureCount == 0,
              secureFetch.tlsVerificationBypassCount == 0,
              secureFetch.customCAInstallationCount == 0,
              metallib.byteCount > 0,
              metallib.sha256.count == 64,
              metallib.sourceCandidateCount == 1,
              metallib.stagedCopyCount == 2,
              metallib.stagedPermissionMode == "444",
              !metallib.loadedPathInferred,
              !metallib.independentlyObservedLoadedIdentity,
              !metallib.retainedAfterJob,
              !metallib.artifactProvenanceEstablished,
              receipt.receiptPrefixOccurrenceCount == 1,
              receipt.rawJSONByteCount == 4_147,
              receipt.rawJSONSHA256.count == 64,
              receipt.rawJSONWasCanonical,
              receipt.buildCount == 1,
              receipt.directXCTestCount == 1,
              receipt.startedCount == 1,
              receipt.passedCount == 1,
              receipt.failureCount == 0,
              receipt.skipCount == 0,
              receipt.durationMilliseconds == 5_128,
              receipt.totalTestCountAfterStage4 == 103,
              receipt.publishedFileCount == 4,
              receipt.exactPublicationOrder
                == [
                    "weights_v2",
                    "optimizer_moments",
                    "control_state_manifest",
                    "commit_manifest",
                ],
              receipt.injectedFailureCount == 7,
              receipt.finalCommitManifestPublishedLast,
              receipt.externallySuppliedExactCommitBindingRequired,
              receipt.everyPartialPrecommitInventoryQuarantined,
              receipt.exactStage3SnapshotRoundTripEstablished,
              artifact.ephemeralPrivateRoot,
              artifact.initiallyEmpty,
              artifact.reclaimedAfterTest,
              !artifact.retainedArtifactEstablished,
              !artifact.artifactUploadInvoked,
              retirement.exactChangedPaths
                == retirement.exactChangedPaths.sorted(),
              Set(retirement.exactChangedPaths).count == 5,
              retirement.expectedRootTestCount == 51,
              retirement.reviewedCheckoutDepth == 1,
              retirement.retainedLiveOrder
                == ["metal", "maintained_runtime", "tokenizer"],
              retirement.stage4LauncherPath
                == ".github/scripts/prime-ci-native-decoder-stage4-tiny-durable-multileaf.sh",
              retirement.stage4LauncherMode == "100755",
              retirement.stage4LauncherGitBlob.count == 40,
              retirement.stage4LauncherByteCount == 31_829,
              retirement.stage4LauncherLFByteCount == 519,
              retirement.stage4LauncherSHA256.count == 64,
              retirement.stage4LauncherInvocationCount == 0,
              retirement.stage4ReceiptCount == 0,
              retirement.stage4LauncherSourcePreserved,
              retirement.successfulAttemptConsumed,
              retirement.exactMainRetirementClosureRequired,
              falseCeilings.allSatisfy({ !$0 })
        else {
            throw PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservationError
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
            throw PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservationError
                .nonCanonicalEncoding
        }
        return value
    }
}
