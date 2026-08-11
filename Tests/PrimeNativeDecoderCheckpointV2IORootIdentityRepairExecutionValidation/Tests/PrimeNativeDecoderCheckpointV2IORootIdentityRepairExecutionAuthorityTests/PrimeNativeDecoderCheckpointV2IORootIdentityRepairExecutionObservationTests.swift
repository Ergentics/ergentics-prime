// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
import XCTest

import PrimeCore
import PrimeNativeDecoderCheckpoint

final class PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionObservationTests:
    XCTestCase
{
    func testExecutionObservationIsExactExhaustedRetiredAndPure() throws {
        typealias Observation =
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservationV1
        typealias ObservationError =
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservationError
        typealias Evidence =
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidenceV1

        let observation = Observation.frozenV1
        try observation.validateExactV1()

        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_observation_v1")
        XCTAssertEqual(
            observation.observationKind,
            "github_reviewed_main_exact_one_shot_checkpoint_v2_io_root_identity_repair_success_observation")
        XCTAssertTrue(observation.predecessorAuthorityRemainsFrozen)
        XCTAssertTrue(observation.predecessorAuthorityRequiredForConsumption)
        XCTAssertTrue(observation.predecessorAuthorityValidated)
        XCTAssertEqual(observation.predecessorBaseSourceBindingCount, 12)
        XCTAssertEqual(observation.predecessorNewExecutionSourceBindingCount, 6)

        XCTAssertEqual(
            observation.authoritativeRepository,
            "Ergentics/ergentics-prime")
        XCTAssertEqual(observation.observedPullRequestNumber, 79)
        XCTAssertEqual(
            observation.observedPullRequestURL,
            "https://github.com/Ergentics/ergentics-prime/pull/79")
        XCTAssertEqual(observation.observedRef, "refs/heads/main")
        XCTAssertEqual(
            observation.observedRevision,
            "44cfa2caa3af5bb44ad53294de33ba2d0faa9a59")
        XCTAssertEqual(
            observation.observedOrderedParentRevisions,
            [
                "1a69407a8fbd5f141e8ece584066b8dcfa6f606f",
                "7314b8a85c5f134c9521b84d2d51d12d3d5084bb",
            ])
        XCTAssertEqual(
            observation.observedTree,
            "fbd57cd9de786e38121fa02b0664b1fb4fcd3d3c")
        XCTAssertEqual(
            observation.reviewedPullRequestHeadRevision,
            "7314b8a85c5f134c9521b84d2d51d12d3d5084bb")
        XCTAssertEqual(
            observation.reviewedPullRequestHeadTree,
            observation.observedTree)
        XCTAssertEqual(
            observation.observedEmbeddedSourceIdentitySHA256,
            "d1aa5b2352ebcf3595b5221f9bb784c610175ce3acc27d963d833cef85c57a90")
        XCTAssertTrue(observation.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(observation.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(observation.exactDirectSuccessorOfAuthorizedBaseObserved)

        let expectedSources = [
            (
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthority.swift",
                gitMode: "100644",
                gitBlob: "244328c77fd20fb0338453e8d0ce9818e3470903",
                byteCount: 63_136,
                sha256:
                    "df689547c1a60ec904ad4cf320581cd6740fca6e797fc2a7fc17a3d9f7ac9f2e"
            ),
            (
                path:
                    "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidence.swift",
                gitMode: "100644",
                gitBlob: "6edb77813df76adb8d7c84d8faf451e325634433",
                byteCount: 62_078,
                sha256:
                    "3bd2fa7bd7ada430b05e16e28242e452ebcd8bd0fb8165ee17723efd44096de8"
            ),
            (
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.swift",
                gitMode: "100644",
                gitBlob: "1cc830db123defbf6a8c0f1362d6d2bb9d754d34",
                byteCount: 2_226,
                sha256:
                    "0caa578cf38870dec6b12cced51859ebb5e3a75ecd30257b76e94c520690c1a4"
            ),
            (
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.resolved",
                gitMode: "100644",
                gitBlob: "315cda0e2afccd6fd0acac96e6a0b9bf76afbeca",
                byteCount: 645,
                sha256:
                    "b93b010098821b26f2efe368e71d1fcf6a2dcb83403962140dfb61f2f70b4c34"
            ),
            (
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe/main.swift",
                gitMode: "100644",
                gitBlob: "61f029352f7a27fa95b4a7b7238d58f1db834387",
                byteCount: 41_866,
                sha256:
                    "bac43ad7e9e44cc02b3b2e51ecf17d1ffb184a086e3c0c5854c8f2ba67b7a504"
            ),
            (
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests.swift",
                gitMode: "100644",
                gitBlob: "8a7bbb1c147555a04e77937eda47b9938c6f742d",
                byteCount: 41_659,
                sha256:
                    "07575be036b7901ac9c8adba11d1d35a71df453a00bf62e2a8435a6af3e86373"
            ),
            (
                path:
                    ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh",
                gitMode: "100755",
                gitBlob: "ed7852704219f61bc29841641257da697389458c",
                byteCount: 66_828,
                sha256:
                    "f56adf9d50d96fc8d06bfbf1bbebd9ce054f4de4f2577e778fc5afb24bd93f7b"
            ),
            (
                path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitMode: "100755",
                gitBlob: "50ee76136a5d11a24119dc78053b357ab21cd1a3",
                byteCount: 200_218,
                sha256:
                    "303658f5ffb680bf1536eb2ff76ec6d4b0994dd0c24cdd0ab887979387811f96"
            ),
            (
                path: ".github/workflows/prime-active-root-quarantine.yml",
                gitMode: "100644",
                gitBlob: "f6d64634d66734a73061c9b93823ab7098776904",
                byteCount: 33_497,
                sha256:
                    "0d98ca3634658693492e822a84b94f02f43850ecb54d5e690a94e5cd027407b6"
            ),
            (
                path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                gitMode: "100644",
                gitBlob: "610eb14185e746dcb24c26b780f56d70925f3af7",
                byteCount: 546,
                sha256:
                    "df3efa4ef8242674a1fe85220ddf13af8f05cb465a1cf08ba67518010503e31c"
            ),
        ]
        XCTAssertEqual(
            observation.observedSourceBindings.count,
            expectedSources.count)
        XCTAssertEqual(
            Set(observation.observedSourceBindings.map(\.path)).count,
            expectedSources.count)
        for (actual, expected) in zip(
            observation.observedSourceBindings,
            expectedSources)
        {
            try actual.validate()
            XCTAssertEqual(actual.path, expected.path)
            XCTAssertEqual(actual.gitMode, expected.gitMode)
            XCTAssertEqual(actual.gitBlob, expected.gitBlob)
            XCTAssertEqual(actual.byteCount, expected.byteCount)
            XCTAssertEqual(actual.sha256, expected.sha256)
            XCTAssertFalse(actual.path.hasPrefix("/"))
        }

        XCTAssertEqual(observation.workflowID, 329_017_041)
        XCTAssertEqual(observation.workflowName, "Prime active-root quarantine")
        XCTAssertEqual(
            observation.workflowPath,
            ".github/workflows/prime-active-root-quarantine.yml")
        XCTAssertEqual(observation.runID, 31_484_642_403)
        XCTAssertEqual(observation.runNumber, 55)
        XCTAssertEqual(observation.runAttempt, 1)
        XCTAssertEqual(observation.runEvent, "push")
        XCTAssertEqual(observation.runActor, "psyop-archivist")
        XCTAssertEqual(observation.runTriggeringActor, observation.runActor)
        XCTAssertEqual(observation.runRef, "refs/heads/main")
        XCTAssertEqual(
            observation.runURL,
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31484642403")
        XCTAssertEqual(observation.runCreatedAt, "2026-08-11T10:59:42Z")
        XCTAssertEqual(observation.runStartedAt, "2026-08-11T10:59:42Z")
        XCTAssertEqual(observation.runUpdatedAt, "2026-08-11T11:42:44Z")
        XCTAssertEqual(observation.runStatus, "completed")
        XCTAssertEqual(observation.runConclusion, "success")

        XCTAssertEqual(observation.activeRootJobID, 93_757_136_546)
        XCTAssertEqual(
            observation.activeRootJobName,
            "First-party MLX / active-root quarantine")
        XCTAssertEqual(
            observation.activeRootJobURL,
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31484642403/job/93757136546")
        XCTAssertEqual(
            observation.activeRootJobStartedAt,
            "2026-08-11T10:59:45Z")
        XCTAssertEqual(
            observation.activeRootJobCompletedAt,
            "2026-08-11T11:02:15Z")
        XCTAssertEqual(observation.activeRootJobStatus, "completed")
        XCTAssertEqual(observation.activeRootJobConclusion, "success")
        XCTAssertEqual(observation.activeRootRunnerLabel, "macos-15")
        XCTAssertEqual(
            observation.activeRootOrderedStepNames,
            [
                "Set up job",
                "Check out the exact Prime revision",
                "Validate active metadata and preserved history",
                "Parse the changed Swift contracts without dependencies",
                "Validate isolated Latin capture and observation contracts",
                "Record the authority ceiling",
                "Complete job",
            ])
        XCTAssertEqual(
            observation.activeRootOrderedStepConclusions,
            Array(repeating: "success", count: 7))

        XCTAssertEqual(observation.reviewedMainJobID, 93_757_733_456)
        XCTAssertEqual(
            observation.reviewedMainJobName,
            "Reviewed main / focused source contracts")
        XCTAssertEqual(
            observation.reviewedMainJobURL,
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31484642403/job/93757733456")
        XCTAssertEqual(
            observation.reviewedMainJobStartedAt,
            "2026-08-11T11:02:18Z")
        XCTAssertEqual(
            observation.reviewedMainJobCompletedAt,
            "2026-08-11T11:42:43Z")
        XCTAssertEqual(observation.reviewedMainJobStatus, "completed")
        XCTAssertEqual(observation.reviewedMainJobConclusion, "success")
        XCTAssertEqual(observation.reviewedMainRunnerLabel, "macos-26")
        XCTAssertEqual(
            observation.reviewedMainOrderedStepNames,
            [
                "Set up job",
                "Record the hosted Apple toolchain",
                "Check out reviewed main exactly",
                "Fetch the exact private dependency without evaluating Prime",
                "Compile and run the focused contracts without a credential",
                "Run the Prime-owned decoder on live Metal",
                "Complete job",
            ])
        XCTAssertEqual(
            observation.reviewedMainOrderedStepConclusions,
            Array(repeating: "success", count: 7))
        XCTAssertTrue(observation.reviewedMainRanAfterActiveRootSuccess)
        XCTAssertEqual(
            observation.liveStepName,
            "Run the Prime-owned decoder on live Metal")
        XCTAssertEqual(
            observation.liveStepStartedAt,
            "2026-08-11T11:15:26Z")
        XCTAssertEqual(
            observation.liveStepCompletedAt,
            "2026-08-11T11:42:37Z")
        XCTAssertEqual(observation.liveStepConclusion, "success")

        XCTAssertEqual(
            observation.consumedLiveLauncherPath,
            ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh")
        XCTAssertEqual(
            observation.consumedLiveLauncherCommand,
            "bash .github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh")
        XCTAssertTrue(observation.liveRepairCommandRetired)
        XCTAssertTrue(observation.retiredLauncherSourceRemainsFrozen)
        XCTAssertFalse(observation.consumedLiveExecutionReexecutionAuthorized)
        XCTAssertEqual(
            observation.reviewedMainTimeoutDuringObservedExecutionMinutes,
            90)
        XCTAssertEqual(
            observation.reviewedMainTimeoutRestoredAfterObservationMinutes,
            45)
        XCTAssertTrue(
            observation.reviewedMainTimeoutRestoredToOrdinary45Minutes)
        XCTAssertEqual(
            observation.reviewedMainCheckoutFetchDepthDuringObservedExecution,
            2)
        XCTAssertEqual(
            observation.reviewedMainCheckoutFetchDepthRestoredAfterObservation,
            1)
        XCTAssertTrue(observation.reviewedMainCheckoutDepthRestoredToOne)

        XCTAssertEqual(
            observation.activeJobTransportDecodedUTF8LogByteCount,
            225_372)
        XCTAssertEqual(
            observation.activeJobTransportDecodedUTF8LogSplitLineCount,
            1_717)
        XCTAssertEqual(
            observation.activeJobTransportDecodedUTF8LogSHA256,
            "a6f948b106edb307a3a826af74bdc82398afba6b1961359e77ec79bb9f069de8")
        XCTAssertEqual(
            observation.reviewedMainJobTransportDecodedUTF8LogByteCount,
            10_348_719)
        XCTAssertEqual(
            observation.reviewedMainJobTransportDecodedUTF8LogSplitLineCount,
            78_565)
        XCTAssertEqual(
            observation.reviewedMainJobTransportDecodedUTF8LogSHA256,
            "caa3e223077cca02d917d2814668a2dc4e36d5e8eed3f60c76689821ed53e588")
        XCTAssertEqual(
            observation.decodedJobLogBindingKind,
            "github_connector_transport_decoded_utf8_text_bom_included_response_wrapper_excluded")
        XCTAssertTrue(observation.decodedJobLogsIncludedUTF8BOM)
        XCTAssertTrue(observation.connectorResponseWrapperExcludedFromLogIdentity)
        XCTAssertTrue(observation.decodedJobLogsBound)
        XCTAssertFalse(observation.rawGitHubLogArchiveBytesBound)
        XCTAssertFalse(observation.jobLogsRetainedInRepository)
        XCTAssertFalse(observation.durableJobLogPublicationEstablished)
        XCTAssertEqual(observation.reviewedMainErrorAnnotationCount, 0)
        XCTAssertEqual(observation.publishedWorkflowArtifactCount, 0)
        XCTAssertFalse(observation.checkpointArtifactUploaded)

        XCTAssertEqual(observation.runnerVersion, "2.336.0")
        XCTAssertEqual(observation.runnerProvisionerVersion, "20260707.563")
        XCTAssertEqual(
            observation.runnerProvisionerCommit,
            "02667638d2b423fbc733a8e32a88b44996a3ba6e")
        XCTAssertEqual(observation.activeRunnerImage, "macos-15-arm64")
        XCTAssertEqual(
            observation.activeRunnerImageVersion,
            "20260727.0256.1")
        XCTAssertEqual(observation.activeOperatingSystemVersion, "15.7.7")
        XCTAssertEqual(observation.activeOperatingSystemBuild, "24G720")
        XCTAssertEqual(observation.reviewedRunnerImage, "macos-26-arm64")
        XCTAssertEqual(
            observation.reviewedRunnerImageVersion,
            "20260728.0273.1")
        XCTAssertEqual(observation.reviewedOperatingSystemVersion, "26.5.2")
        XCTAssertEqual(observation.reviewedOperatingSystemBuild, "25F84")
        XCTAssertEqual(observation.reviewedArchitecture, "arm64")
        XCTAssertEqual(observation.xcodeVersion, "26.6")
        XCTAssertEqual(observation.xcodeBuildVersion, "17F113")
        XCTAssertEqual(
            observation.swiftVersion,
            "Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)")
        XCTAssertEqual(observation.swiftTarget, "arm64-apple-macosx26.0")
        XCTAssertEqual(observation.macOSSDKVersion, "26.5")
        XCTAssertEqual(observation.swiftDriverVersion, "1.148.6")
        XCTAssertTrue(observation.exactHostedRunnerImagesRecorded)
        XCTAssertFalse(observation.exactPhysicalRunnerIdentityRecorded)

        XCTAssertEqual(observation.receiptBeginMarkerCount, 1)
        XCTAssertEqual(observation.receiptChunkMarkerCount, 26)
        XCTAssertEqual(observation.receiptEndMarkerCount, 1)
        XCTAssertEqual(observation.receiptFirstChunkOrdinal, "000000")
        XCTAssertEqual(observation.receiptLastChunkOrdinal, "000025")
        XCTAssertEqual(observation.receiptChunkCharacterCount, 4_096)
        XCTAssertEqual(observation.receiptFinalChunkCharacterCount, 540)
        XCTAssertEqual(observation.receiptBase64CharacterCount, 102_940)
        XCTAssertEqual(observation.receiptCanonicalByteCount, 77_205)
        XCTAssertEqual(
            observation.receiptCanonicalSHA256,
            "b4aec02aa666433fa7bff5e913629e51f06f5388d21bf9e86d7801ca00dd67bf")
        XCTAssertEqual(
            observation.compatibilityIdentityCanonicalByteCount,
            30_553)
        XCTAssertEqual(
            observation.compatibilityIdentitySHA256,
            "aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843")
        XCTAssertEqual(observation.tensorBindingsCanonicalByteCount, 35_184)
        XCTAssertEqual(
            observation.tensorBindingsSHA256,
            "7cc7aec0d990a0bb6bb1748de396b84c85af06dea918610343e2f6560c926566")
        XCTAssertEqual(observation.manifestCanonicalByteCount, 66_373)
        XCTAssertEqual(
            observation.manifestCanonicalSHA256,
            "6b42dac70d522b248b02d564c8e850f82a28ca12fcfab4ca4db91ea8cc9098e3")
        XCTAssertEqual(observation.externalBindingCanonicalByteCount, 66_854)
        XCTAssertEqual(
            observation.externalBindingCanonicalSHA256,
            "c5a9b8a8aa4301f2dde0ab199bc39771298b1842009836537a085ba4b676d961")
        XCTAssertTrue(observation.receiptTransportWasOrderedContiguousAndFinal)

        let evidence = observation.receiptEvidence
        try evidence.validate()
        XCTAssertEqual(
            evidence.evidenceID,
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_evidence_v1")
        XCTAssertEqual(
            evidence.authorityID,
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_authority_v1")
        XCTAssertEqual(evidence.executedRevision, observation.observedRevision)
        XCTAssertEqual(
            evidence.executedOrderedParentRevisions,
            observation.observedOrderedParentRevisions)
        XCTAssertEqual(evidence.executedTree, observation.observedTree)
        XCTAssertEqual(evidence.executionRunAttempt, 1)
        XCTAssertEqual(evidence.executionEvent, "push")
        XCTAssertEqual(evidence.executionRef, "refs/heads/main")
        XCTAssertEqual(
            evidence.executionRepository,
            "Ergentics/ergentics-prime")
        XCTAssertEqual(evidence.initializationSeed, 43)
        XCTAssertEqual(evidence.predecessorValidatedLogCount, 10)
        XCTAssertEqual(evidence.predecessorValidatedReceiptCount, 2)
        XCTAssertEqual(
            evidence.knownRunnerTemporaryReclamationPathCount,
            32)
        XCTAssertEqual(
            evidence.availableFilesystemBytesAfterReclamation,
            102_455_418_880)
        XCTAssertEqual(
            evidence.availableFilesystemBytesAfterBuild,
            101_145_567_232)
        XCTAssertEqual(evidence.requiredFreeSpaceMultiplier, 3)
        XCTAssertTrue(evidence.freeSpacePreflightPassed)
        XCTAssertEqual(evidence.metallibByteCount, 6_292_732)
        XCTAssertEqual(
            evidence.metallibSHA256,
            "d4e858ce07e26d7c82f8218fc7964d05f307db95620242348699cfff33e0d52f")

        let beforeWrite = evidence.artifactRootIdentityBeforeWrite
        let afterWrite = evidence.artifactRootIdentityAfterWrite
        let afterLoad = evidence.artifactRootIdentityAfterLoad
        XCTAssertEqual(beforeWrite.deviceID, 16_777_230)
        XCTAssertEqual(beforeWrite.inode, 2_970_995)
        XCTAssertEqual(beforeWrite.ownerUserID, 501)
        XCTAssertEqual(beforeWrite.ownerGroupID, 20)
        XCTAssertEqual(beforeWrite.permissionMode, 0o700)
        XCTAssertEqual(beforeWrite.linkCount, 2)
        XCTAssertEqual(beforeWrite.modificationTimeSeconds, 1_786_448_484)
        XCTAssertEqual(beforeWrite.modificationTimeNanoseconds, 733_729_583)
        XCTAssertEqual(beforeWrite.changeTimeSeconds, 1_786_448_484)
        XCTAssertEqual(beforeWrite.changeTimeNanoseconds, 735_646_374)
        XCTAssertEqual(afterWrite.deviceID, beforeWrite.deviceID)
        XCTAssertEqual(afterWrite.inode, beforeWrite.inode)
        XCTAssertEqual(afterWrite.ownerUserID, beforeWrite.ownerUserID)
        XCTAssertEqual(afterWrite.ownerGroupID, beforeWrite.ownerGroupID)
        XCTAssertEqual(afterWrite.permissionMode, beforeWrite.permissionMode)
        XCTAssertEqual(afterWrite.linkCount, 3)
        XCTAssertEqual(afterWrite.modificationTimeSeconds, 1_786_448_532)
        XCTAssertEqual(afterWrite.modificationTimeNanoseconds, 850_740_833)
        XCTAssertEqual(afterWrite.changeTimeSeconds, 1_786_448_532)
        XCTAssertEqual(afterWrite.changeTimeNanoseconds, 850_740_833)
        XCTAssertEqual(afterLoad, afterWrite)
        XCTAssertTrue(
            beforeWrite.publicationStableObjectFieldsEqual(to: afterWrite))
        XCTAssertTrue(afterWrite.readOnlyFullIdentityEqual(to: afterLoad))
        XCTAssertEqual(evidence.artifactRootEntryNamesBeforeWrite, [])
        XCTAssertEqual(
            evidence.artifactRootEntryNamesAfterWrite,
            [
                "checkpoint-v2-native300m-seed43-root-identity-repair.safetensors",
            ])
        XCTAssertEqual(evidence.artifactRootEntryCountAfterWrite, 1)
        XCTAssertTrue(evidence.publicationStableFiveFieldsMatched)
        XCTAssertTrue(evidence.publicationRootLinkCountsPositive)
        XCTAssertTrue(evidence.readOnlyFullRootIdentityMatched)

        let externalBinding = evidence.externalBinding
        try externalBinding.validate()
        let artifact = externalBinding.artifactBinding
        XCTAssertEqual(
            artifact.relativePath,
            "checkpoint-v2-native300m-seed43-root-identity-repair.safetensors")
        XCTAssertEqual(artifact.purpose, .immutableData)
        XCTAssertEqual(artifact.byteCount, 1_084_525_304)
        XCTAssertEqual(
            artifact.sha256,
            "a6dae67b9a24e3d0220d22e3060bb43bab7d8cd027d97ea635db8580774cd538")
        XCTAssertEqual(evidence.publishedArtifactMode, 0o444)
        XCTAssertEqual(evidence.publishedArtifactLinkCount, 1)
        XCTAssertTrue(evidence.publishedArtifactIsRegularFile)
        XCTAssertFalse(evidence.publishedArtifactIsSymbolicLink)
        XCTAssertTrue(evidence.publishedArtifactDeviceMatchedRoot)
        XCTAssertTrue(evidence.publishedArtifactOwnerMatchedEffectiveUser)

        let manifest = externalBinding.manifest
        try manifest.validate()
        XCTAssertEqual(manifest.tensorBindings.count, 218)
        XCTAssertEqual(evidence.tensorBindingCount, 218)
        XCTAssertEqual(evidence.observedParameterCount, 271_107_072)
        XCTAssertEqual(evidence.observedParameterByteCount, 1_084_428_288)
        XCTAssertEqual(
            manifest.compatibilityIdentity.totalParameterCount,
            evidence.observedParameterCount)
        XCTAssertEqual(
            manifest.compatibilityIdentity.totalParameterByteCount,
            evidence.observedParameterByteCount)
        XCTAssertEqual(
            manifest.tensorBindings.map(\.path),
            manifest.compatibilityIdentity.parameterCatalog.map(\.path))
        XCTAssertTrue(manifest.tensorBindings.allSatisfy(\.allValuesFinite))
        XCTAssertFalse(manifest.optimizerStateIncluded)
        XCTAssertFalse(manifest.rngStateIncluded)
        XCTAssertFalse(manifest.dataCursorIncluded)
        XCTAssertFalse(manifest.kvCacheStateIncluded)

        XCTAssertEqual(evidence.publicCheckpointWriteInvocationCount, 1)
        XCTAssertEqual(evidence.publicCheckpointWriteCompletionCount, 1)
        XCTAssertEqual(evidence.publicCheckpointLoadInvocationCount, 1)
        XCTAssertEqual(evidence.publicCheckpointLoadCompletionCount, 1)
        XCTAssertEqual(
            evidence.cumulativePublicWriteCompletionCountSourceInferredAfterSuccess,
            2)
        XCTAssertEqual(
            evidence.cumulativePublicLoadCompletionCountSourceInferredAfterSuccess,
            1)
        XCTAssertTrue(evidence.native300MModelAllocationObserved)
        XCTAssertTrue(evidence.native300MCheckpointWriteObserved)
        XCTAssertTrue(evidence.native300MCheckpointLoadObserved)
        XCTAssertTrue(evidence.checkpointIOObserved)
        XCTAssertTrue(evidence.checkpointArtifactAvailableDuringProcess)
        XCTAssertTrue(evidence.checkpointContainerHashBound)
        XCTAssertTrue(evidence.checkpointDurabilityMechanicsCompleted)
        XCTAssertTrue(evidence.logicalParameterRoundTripViaPinnedCodecObserved)

        XCTAssertEqual(
            observation.exactParentPostReceiptVerificationSourceLineRange,
            [1_156, 1_175])
        XCTAssertEqual(observation.exactParentArtifactUnlinkSourceLine, 1_176)
        XCTAssertEqual(
            observation.exactParentArtifactRootRmdirSourceLine,
            1_177)
        XCTAssertEqual(
            observation.exactParentCleanupAbsencePostconditionSourceLineRange,
            [1_178, 1_180])
        XCTAssertEqual(
            observation.receiptEndObservedAt,
            "2026-08-11T11:42:37.6029040Z")
        XCTAssertEqual(
            observation.parentCleanupSuccessObservedAt,
            "2026-08-11T11:42:37.8067580Z")
        XCTAssertEqual(
            observation.exactParentCleanupSuccessLine,
            "OK: exact reviewed-main one-shot Native-300M V2 checkpoint public write/load passed; the fixed artifact and 0700 root were removed after receipt validation")
        XCTAssertTrue(observation.receiptEndPrecededParentCleanup)
        XCTAssertTrue(observation.parentReceiptVerificationCompleted)
        XCTAssertTrue(observation.parentArtifactUnlinkCompleted)
        XCTAssertTrue(observation.parentArtifactRootRmdirCompleted)
        XCTAssertTrue(observation.parentLiteralCleanupPostconditionCompleted)
        XCTAssertTrue(
            observation.parentCleanupBindingIsExactSourceAndTerminalLogControlFlow)
        XCTAssertFalse(
            observation.parentCleanupWasIndependentRetainedFilesystemObservation)
        XCTAssertFalse(observation.failureTrapCleanupEstablishedSuccess)

        XCTAssertTrue(observation.predecessorAuthorityAttemptConsumed)
        XCTAssertTrue(observation.predecessorAuthorityExhausted)
        XCTAssertFalse(observation.rerunObserved)
        XCTAssertFalse(observation.rerunAuthorized)
        XCTAssertFalse(observation.replacementExecutionAuthorityEstablished)
        XCTAssertTrue(observation.executionReceiptSourceAndRunBindingEstablished)
        XCTAssertTrue(observation.native300MModelAllocationObserved)
        XCTAssertTrue(observation.native300MCheckpointWriteObserved)
        XCTAssertTrue(observation.native300MCheckpointLoadObserved)
        XCTAssertTrue(observation.checkpointIOObserved)
        XCTAssertTrue(observation.checkpointArtifactAvailableDuringProcess)
        XCTAssertTrue(observation.checkpointContainerHashBound)
        XCTAssertTrue(observation.checkpointDurabilityMechanicsCompleted)
        XCTAssertTrue(
            observation.logicalParameterRoundTripViaPinnedCodecObserved)
        XCTAssertTrue(observation.publicationStableFiveFieldsMatched)
        XCTAssertTrue(observation.publicationRootLinkCountTransitionObserved)
        XCTAssertTrue(observation.readOnlyFullRootIdentityMatched)

        let falseCeilings = [
            "checkpointArtifactAvailabilityBeyondProcessEstablished":
                observation
                    .checkpointArtifactAvailabilityBeyondProcessEstablished,
            "checkpointArtifactRetentionEstablished":
                observation.checkpointArtifactRetentionEstablished,
            "checkpointArtifactProvenanceEstablished":
                observation.checkpointArtifactProvenanceEstablished,
            "checkpointAdmissionGranted":
                observation.checkpointAdmissionGranted,
            "existingCheckpointArtifactCompatibilityObserved":
                observation.existingCheckpointArtifactCompatibilityObserved,
            "atomicCheckpointReplacementEstablished":
                observation.atomicCheckpointReplacementEstablished,
            "failedCheckpointWriteRecoveryObserved":
                observation.failedCheckpointWriteRecoveryObserved,
            "independentPostLoadTensorHashReplayObserved":
                observation.independentPostLoadTensorHashReplayObserved,
            "independentCodecComparatorObserved":
                observation.independentCodecComparatorObserved,
            "independentPostLoadArtifactRootVerifyObserved":
                observation.independentPostLoadArtifactRootVerifyObserved,
            "checkpointLoadedForwardObserved":
                observation.checkpointLoadedForwardObserved,
            "checkpointRoundTripBehaviorParityEstablished":
                observation.checkpointRoundTripBehaviorParityEstablished,
            "optimizerStateIncluded": observation.optimizerStateIncluded,
            "rngStateIncluded": observation.rngStateIncluded,
            "dataCursorIncluded": observation.dataCursorIncluded,
            "kvCacheStateIncluded": observation.kvCacheStateIncluded,
            "decoderForwardObserved": observation.decoderForwardObserved,
            "decoderKVCacheUsed": observation.decoderKVCacheUsed,
            "backwardInvoked": observation.backwardInvoked,
            "lossObserved": observation.lossObserved,
            "optimizerStepObserved": observation.optimizerStepObserved,
            "generationInvoked": observation.generationInvoked,
            "trainEvaluateSurfaceEstablished":
                observation.trainEvaluateSurfaceEstablished,
            "trainingResumeEstablished":
                observation.trainingResumeEstablished,
            "trainingExecutionObserved":
                observation.trainingExecutionObserved,
            "modelQualityEstablished": observation.modelQualityEstablished,
            "candidateAdmissionGranted":
                observation.candidateAdmissionGranted,
            "trialAuthorized": observation.trialAuthorized,
            "canaryReplacementAuthorized":
                observation.canaryReplacementAuthorized,
            "quantizationAuthorized": observation.quantizationAuthorized,
            "productUseAuthorized": observation.productUseAuthorized,
            "publicationAuthorized": observation.publicationAuthorized,
        ]
        XCTAssertEqual(falseCeilings.count, 32)
        for key in falseCeilings.keys.sorted() {
            XCTAssertFalse(
                try XCTUnwrap(falseCeilings[key]),
                "observation widened ceiling: \(key)")
        }
        XCTAssertEqual(
            observation.status,
            "ABSTAIN_exact_reviewed_main_seed43_native300m_v2_checkpoint_root_identity_repair_one_public_write_one_public_fresh_load_parent_verified_ephemeral_cleanup_observed_no_artifact_retention_provenance_or_admission")
        XCTAssertEqual(
            observation.orderedNextActions,
            [
                "define_generic_prime_owned_train_evaluate_surfaces_and_exact_optimizer_rng_data_cursor_state",
                "require_separate_authority_and_retained_artifact_provenance_before_training_or_checkpoint_admission",
            ])

        let receiptData = try evidence.canonicalReceiptData()
        XCTAssertEqual(receiptData.count, observation.receiptCanonicalByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: receiptData),
            observation.receiptCanonicalSHA256)
        XCTAssertEqual(try PrimeCanonicalJSON.encode(evidence), receiptData)
        let decodedReceipt = try Evidence.decodeCanonicalReceipt(
            from: receiptData)
        XCTAssertEqual(decodedReceipt, evidence)
        try decodedReceipt.validate()
        XCTAssertEqual(
            try decodedReceipt.canonicalReceiptData(),
            receiptData)

        let encodedObservation = try JSONEncoder().encode(observation)
        let decodedObservation = try JSONDecoder().decode(
            Observation.self,
            from: encodedObservation)
        XCTAssertEqual(decodedObservation, observation)
        try decodedObservation.validateExactV1()

        let canonicalObservation = try PrimeCanonicalJSON.encode(observation)
        let canonicalDecodedObservation = try JSONDecoder().decode(
            Observation.self,
            from: canonicalObservation)
        XCTAssertEqual(canonicalDecodedObservation, observation)
        XCTAssertEqual(
            try PrimeCanonicalJSON.encode(canonicalDecodedObservation),
            canonicalObservation)
        try canonicalDecodedObservation.validateExactV1()

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonicalObservation)
                as? [String: Any])
        let mutations = recursiveScalarAndArrayMutations(
            of: object,
            path: "$root")
        XCTAssertGreaterThan(mutations.count, 2_500)
        XCTAssertTrue(mutations.contains { $0.0.hasSuffix(".boolean") })
        XCTAssertTrue(mutations.contains { $0.0.hasSuffix(".number") })
        XCTAssertTrue(mutations.contains { $0.0.hasSuffix(".string") })
        XCTAssertTrue(
            mutations.contains {
                $0.0.hasSuffix(".array-drop")
                    || $0.0.hasSuffix(".array-add")
            })
        XCTAssertTrue(
            mutations.contains { $0.0.hasSuffix(".array-duplicate") })
        XCTAssertTrue(
            mutations.contains { $0.0.hasSuffix(".array-reorder") })

        var rejectedAfterDecodeCount = 0
        var rejectedAtDecodeCount = 0
        for (label, mutatedObject) in mutations {
            let data = try JSONSerialization.data(
                withJSONObject: mutatedObject,
                options: [.sortedKeys])
            do {
                let mutated = try JSONDecoder().decode(
                    Observation.self,
                    from: data)
                rejectedAfterDecodeCount += 1
                XCTAssertThrowsError(
                    try mutated.validateExactV1(),
                    "observation mutation accepted: \(label)"
                ) { error in
                    XCTAssertEqual(
                        error as? ObservationError,
                        .contractDrift,
                        "unexpected mutation error for \(label)")
                }
            } catch is DecodingError {
                rejectedAtDecodeCount += 1
            }
        }
        XCTAssertGreaterThan(rejectedAfterDecodeCount, 2_500)
        XCTAssertGreaterThan(rejectedAtDecodeCount, 0)
        XCTAssertEqual(
            rejectedAfterDecodeCount + rejectedAtDecodeCount,
            mutations.count)
    }

    private func recursiveScalarAndArrayMutations(
        of value: Any,
        path: String
    ) -> [(String, Any)] {
        if let dictionary = value as? [String: Any] {
            var result = [(String, Any)]()
            for key in dictionary.keys.sorted() {
                guard let child = dictionary[key] else { continue }
                for (childLabel, childMutation) in
                    recursiveScalarAndArrayMutations(
                        of: child,
                        path: "\(path).\(key)")
                {
                    var copy = dictionary
                    copy[key] = childMutation
                    result.append((childLabel, copy))
                }
            }
            return result
        }
        if let array = value as? [Any] {
            var result = [(String, Any)]()
            for index in array.indices {
                for (childLabel, childMutation) in
                    recursiveScalarAndArrayMutations(
                        of: array[index],
                        path: "\(path)[\(index)]")
                {
                    var copy = array
                    copy[index] = childMutation
                    result.append((childLabel, copy))
                }
            }
            if array.isEmpty {
                result.append(
                    ("\(path).array-add", ["__mutated_empty_array__"]))
            } else {
                var dropped = array
                dropped.removeLast()
                result.append(("\(path).array-drop", dropped))

                var duplicated = array
                duplicated.append(array[0])
                result.append(("\(path).array-duplicate", duplicated))

                if array.count > 1,
                   !jsonValuesAreEqual(array[0], array[1])
                {
                    var reordered = array
                    reordered.swapAt(0, 1)
                    result.append(("\(path).array-reorder", reordered))
                }
            }
            return result
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return [("\(path).boolean", !number.boolValue)]
            }
            return [
                (
                    "\(path).number",
                    NSNumber(value: number.int64Value + 1)
                ),
            ]
        }
        if let string = value as? String {
            return [("\(path).string", string + "_mutated")]
        }
        return [("\(path).string", "__mutated_unknown_scalar__")]
    }

    private func jsonValuesAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        let lhsData = try? JSONSerialization.data(
            withJSONObject: ["value": lhs],
            options: [.sortedKeys])
        let rhsData = try? JSONSerialization.data(
            withJSONObject: ["value": rhs],
            options: [.sortedKeys])
        return lhsData == rhsData
    }
}
