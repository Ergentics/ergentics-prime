// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityError:
    Error, Equatable, Sendable
{
    case contractDrift
    case nonCanonicalEncoding
}

public struct PrimeNativeDecoderStage5SwiftNumericsRepairExactMainRunV1:
    Codable, Equatable, Sendable
{
    public let repository: String
    public let ref: String
    public let mergeRevision: String
    public let mergeTree: String
    public let orderedParentRevisions: [String]
    public let stage5AuthorityCanonicalSHA256: String
    public let stage5AuthoritySourceGitBlob: String
    public let stage5AuthoritySourceSHA256: String
    public let stage5AuthorityTestGitBlob: String
    public let stage5AuthorityTestSHA256: String
    public let workflowRunID: Int
    public let workflowRunNumber: Int
    public let checkSuiteID: Int
    public let runAttempt: Int
    public let previousAttemptAbsent: Bool
    public let exactHeadPushRunCount: Int
    public let rerunCount: Int
    public let artifactCount: Int
    public let activeJobID: Int
    public let activeJobConclusion: String
    public let reviewedJobID: Int
    public let reviewedJobConclusion: String
    public let reviewedFailedStepIndex: Int
    public let reviewedFailedStepName: String
    public let terminalConclusion: String
}

public struct PrimeNativeDecoderStage5SwiftNumericsRepairReviewedLogV1:
    Codable, Equatable, Sendable
{
    public let encoding: String
    public let byteCount: Int
    public let lineFeedCount: Int
    public let byteOrderMarkPresent: Bool
    public let endsWithLineFeed: Bool
    public let sha256: String
    public let focusedStepStartedUTC: String
    public let swiftNumericsFailureFetchStartedUTC: String
    public let swiftNumericsCloneErrorUTC: String
    public let fatalErrorUTC: String
    public let focusedStepCompletedUTC: String
    public let reviewedJobCompletedUTC: String
    public let processExitCode: Int
}

public struct PrimeNativeDecoderStage5SwiftNumericsRepairSecureFetchV1:
    Codable, Equatable, Sendable
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

public struct PrimeNativeDecoderStage5SwiftNumericsRepairPackageAttemptV1:
    Codable, Equatable, Sendable
{
    public let order: Int
    public let packagePath: String
    public let expectedTestCount: Int
    public let swiftTestInvocationCount: Int
    public let swiftNumericsFetchAnnouncementCount: Int
    public let swiftNumericsCacheFetchCount: Int
    public let swiftNumericsWorkingCopyCreationCount: Int
    public let swiftNumericsResolutionCount: Int
    public let publicCloneAttemptCount: Int
    public let buildCompleted: Bool
    public let testExecutionStarted: Bool
    public let testSuiteCompleted: Bool
    public let executedTestCount: Int
    public let failureCount: Int
    public let skipCount: Int
    public let dnsFailureCount: Int
    public let commandConclusion: String
    public let processExitCode: Int
}

public struct PrimeNativeDecoderStage5SwiftNumericsRepairFailureV1:
    Codable, Equatable, Sendable
{
    public let rootSwiftTestInvocationCount: Int
    public let rootBuildCompleted: Bool
    public let rootExecutedTestCount: Int
    public let rootFailureCount: Int
    public let rootSkipCount: Int
    public let stage5AuthorityTestExecutedCount: Int
    public let rootSwiftNumericsFetchAnnouncementCount: Int
    public let rootSwiftNumericsCacheFetchCount: Int
    public let rootSwiftNumericsWorkingCopyCreationCount: Int
    public let rootSwiftNumericsResolutionCount: Int
    public let isolatedAttempts: [PrimeNativeDecoderStage5SwiftNumericsRepairPackageAttemptV1]
    public let expectedIsolatedTestCount: Int
    public let completedIsolatedTestCount: Int
    public let observedWholeTestCount: Int
    public let totalSwiftNumericsFetchAnnouncementCount: Int
    public let totalSwiftNumericsCacheFetchCount: Int
    public let totalSwiftNumericsWorkingCopyCreationCount: Int
    public let totalSwiftNumericsResolutionCount: Int
    public let totalPublicCloneAttemptCount: Int
    public let totalDNSFailureCount: Int
    public let dependencyIdentity: String
    public let dependencyLocation: String
    public let dependencyRevision: String
    public let dependencyVersion: String
    public let failureClass: String
    public let failedPackagePath: String
    public let failedScratchRepositoryPath: String
    public let exactCloneError: String
    public let exactDNSDiagnostic: String
    public let publicDependencyTLSFailureCount: Int
    public let publicDependencyTLSVerificationBypassCount: Int
    public let workflowAuthoredRetryCount: Int
    public let gitInternalRetryScheduledCount: Int
    public let metalLauncherInvocationCount: Int
    public let maintainedRuntimeLauncherInvocationCount: Int
    public let tokenizerLauncherInvocationCount: Int
    public let stage5LauncherInvocationCount: Int
    public let stage5ReceiptCount: Int
}

public struct PrimeNativeDecoderStage5SwiftNumericsResolutionRepairV1:
    Codable, Equatable, Sendable
{
    public let workflowPath: String
    public let repairActivationPoint: String
    public let rootScratchPath: String
    public let rootSwiftNumericsCheckoutPath: String
    public let rootSwiftNumericsCacheRepositoryPath: String
    public let sourceCheckoutRepositoryRootExpectedPath: String
    public let sourceCheckoutAbsoluteGitDirectoryExpectedPath: String
    public let sourceCheckoutIsBare: Bool
    public let sourceCheckoutExactRemoteNames: [String]
    public let sourceCheckoutOriginURLValueCount: Int
    public let sourceCheckoutExpectedOrigin: String
    public let sourceCheckoutMustExistAsPhysicalDirectory: Bool
    public let sourceCheckoutSymlinkAuthorized: Bool
    public let sourceCheckoutRepositoryRootValidated: Bool
    public let sourceCheckoutOriginValidated: Bool
    public let sourceCheckoutExactRevision: String
    public let sourceCheckoutCleanStatusRequired: Bool
    public let sourceCheckoutValidatedAfterSuccessfulRootTests: Bool
    public let sourceCheckoutOriginEqualsCacheRepositoryPathRequired: Bool
    public let cacheRepositoryMustExistAsPhysicalDirectory: Bool
    public let cacheRepositorySymlinkAuthorized: Bool
    public let cacheRepositoryAbsoluteGitDirectoryExpectedPath: String
    public let cacheRepositoryIsBare: Bool
    public let cacheRepositoryExactRemoteNames: [String]
    public let cacheRepositoryOriginURLValueCount: Int
    public let cacheRepositoryExpectedOrigin: String
    public let cacheRepositoryOriginValidated: Bool
    public let cacheRepositoryContainsExactRevision: Bool
    public let cacheRepositoryExactRevisionObjectType: String
    public let cacheRepositoryPeeledCommitEqualsExactRevision: Bool
    public let cacheRepositoryPinnedVersionTag: String
    public let cacheRepositoryPinnedVersionTagPeeledCommitEqualsExactRevision: Bool
    public let cacheRepositoryHEADMustEqualExactRevision: Bool
    public let cacheRepositoryWorkingTreeCleanStatusApplicable: Bool
    public let mappingActivatedBeforeFirstIsolatedBuild: Bool
    public let mappedIsolatedSwiftTestInvocationCount: Int
    public let exactMappedOrigin: String
    public let localMappingSource: String
    public let localMappingTemplate: String
    public let localMappingAppliesOnlyToExactOrigin: Bool
    public let fileProtocolRequired: Bool
    public let gitConfigCountAfterRepair: Int
    public let gitConfigKeyOrder: [String]
    public let gitConfigValueOrder: [String]
    public let existingMLXMappingPreserved: Bool
    public let existingFileProtocolSettingPreserved: Bool
    public let allLaterIsolatedBuildsMapped: Bool
    public let mappingRemovedAfterFinalIsolatedBuild: Bool
    public let publicSwiftNumericsFetchAfterMappingAuthorized: Bool
    public let rootPublicSwiftNumericsResolutionPreserved: Bool
    public let mappingCarriesCredential: Bool
    public let packageManifestMutationAuthorized: Bool
    public let packageResolvedMutationAuthorized: Bool
    public let packageResolvedBytePreservationRequired: Bool
    public let securePrivateFetchMutationAuthorized: Bool
    public let workflowJobTopologyMutationAuthorized: Bool
    public let workflowTimeoutMutationAuthorized: Bool
    public let activeCheckoutMutationAuthorized: Bool
    public let reviewedCheckoutMutationAuthorized: Bool
    public let activeCheckoutDepth: Int
    public let reviewedCheckoutDepth: Int
    public let activeJobTimeoutMinutes: Int
    public let reviewedJobTimeoutMinutes: Int
}

public struct PrimeNativeDecoderStage5SwiftNumericsRepairScopeV1:
    Codable, Equatable, Sendable
{
    public let exactAuthorityClosurePaths: [String]
    public let exactAuthorityClosurePathCount: Int
    public let sourceAndTestAreOnlyNewPaths: Bool
    public let authorityRootTestCount: Int
    public let isolatedTestCount: Int
    public let authorityFocusedWholeTestCount: Int
    public let metalTestCount: Int
    public let maintainedRuntimeTestCount: Int
    public let maintainedRuntimeReceiptCount: Int
    public let tokenizerTestCount: Int
    public let tokenizerReceiptCount: Int
    public let preStage5TestCount: Int
    public let metalLauncherInvocationCount: Int
    public let maintainedRuntimeLauncherInvocationCount: Int
    public let tokenizerLauncherInvocationCount: Int
    public let stage5LauncherInvocationCount: Int
    public let stage5ReceiptCount: Int
    public let authorityClosureLiveOrder: [String]
    public let exactFutureMechanicsPaths: [String]
    public let exactFutureMechanicsPathCount: Int
    public let futureMechanicsScopeUnchanged: Bool
    public let futureStage5DirectXCTestCount: Int
    public let futureMechanicsTotalTestCount: Int
}

public struct PrimeNativeDecoderStage5SwiftNumericsRepairCeilingV1:
    Codable, Equatable, Sendable
{
    public let pureAuthorityNoRepairExecutionEvidence: Bool
    public let failedRunIsAuthorityClosureFailure: Bool
    public let failedRunIsStage5MechanicsAttempt: Bool
    public let failedRunConsumesStage5MechanicsOpportunity: Bool
    public let oneExactMainRepairClosureExecutionAuthorized: Bool
    public let stage5MechanicsOpportunityPreservedAfterGreenRepairClosure: Bool
    public let additionalExecutionOrRerunAuthorized: Bool
    public let genericNetworkRetryAuthorized: Bool
    public let tlsOrCARepairAuthorized: Bool
    public let secureFetchMutationAuthorized: Bool
    public let stage5MechanicsExecuted: Bool
    public let stage5ResultEstablished: Bool
    public let retainedArtifactAuthorized: Bool
    public let artifactUploadAuthorized: Bool
    public let durableCheckpointIOAuthorized: Bool
    public let crossDeviceClaimAuthorized: Bool
    public let stage6Authorized: Bool
    public let native300MAllocationAuthorized: Bool
    public let native300MTrainingAuthorized: Bool
    public let generalTrainingAuthorized: Bool
    public let generalTrainingResumeEstablished: Bool
    public let modelQualityEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let candidateAdmissionGranted: Bool
    public let downstreamTrialAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
}

/// Pure repair authority for the exact-main Stage-5 authority closure. The
/// closure reached no Stage-5 mechanics: a fourth public Swift-Numerics
/// resolution failed on DNS before its isolated package built. This freezes
/// only reuse of the validated physical backing bare SwiftPM cache repository
/// for the exact validated root checkout across the four later isolated
/// builds; it performs no resolution, network, training, or I/O.
public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityV1:
    Codable, Equatable, Sendable
{
    public static let canonicalSHA256 =
        "a5a8e5300ea8413e738fddd4b8fed930dcc9983d5a29eea102862f9744b50fff"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_exact_main_swift_numerics_resolution_repair_authority_v1",
        exactMainRun: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            mergeRevision: "1193a1f11a869f89b25706dbd270520dd61b37a8",
            mergeTree: "d92c838b7d9714ee6e1dc4d6ba03f23df094a3d0",
            orderedParentRevisions: [
                "b198ba81f4c6958d70b56ea3a23f56f07fa90854",
                "2928711930fe7af8d8287702b966a25c440b10f8",
            ],
            stage5AuthorityCanonicalSHA256:
                "00c49e63315b2aacb439204e778f54bcf63c2fdf643282f3bd64e2b3b4094089",
            stage5AuthoritySourceGitBlob:
                "71c69d89384c5c0878f43da309353093d159d43c",
            stage5AuthoritySourceSHA256:
                "367fc5c2759382f5980ceb59d25da27f945bfbff186f61b055bccca4411758ab",
            stage5AuthorityTestGitBlob:
                "42a2c60b7179f3f8c687b6c697513433a92eac30",
            stage5AuthorityTestSHA256:
                "05f9a766860ea5c35b590b1d813a81eea0b42d1b0d941ee2b054509f0a3e7cdc",
            workflowRunID: 31_745_220_457,
            workflowRunNumber: 101,
            checkSuiteID: 86_124_999_845,
            runAttempt: 1,
            previousAttemptAbsent: true,
            exactHeadPushRunCount: 1,
            rerunCount: 0,
            artifactCount: 0,
            activeJobID: 94_598_042_972,
            activeJobConclusion: "success",
            reviewedJobID: 94_598_786_638,
            reviewedJobConclusion: "failure",
            reviewedFailedStepIndex: 5,
            reviewedFailedStepName:
                "Compile and run the focused contracts without a credential",
            terminalConclusion: "failure"),
        reviewedLog: .init(
            encoding: "UTF-8",
            byteCount: 316_010,
            lineFeedCount: 2_852,
            byteOrderMarkPresent: true,
            endsWithLineFeed: true,
            sha256:
                "67066aa642f293cc08262d3c4e40111b92d161dad00e25fff3eba02e59a1227b",
            focusedStepStartedUTC: "2026-08-13T21:24:13Z",
            swiftNumericsFailureFetchStartedUTC: "2026-08-13T21:37:21Z",
            swiftNumericsCloneErrorUTC: "2026-08-13T21:37:51Z",
            fatalErrorUTC: "2026-08-13T21:39:02Z",
            focusedStepCompletedUTC: "2026-08-13T21:39:02Z",
            reviewedJobCompletedUTC: "2026-08-13T21:39:09Z",
            processExitCode: 1),
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
        failure: .init(
            rootSwiftTestInvocationCount: 1,
            rootBuildCompleted: true,
            rootExecutedTestCount: 52,
            rootFailureCount: 0,
            rootSkipCount: 0,
            stage5AuthorityTestExecutedCount: 1,
            rootSwiftNumericsFetchAnnouncementCount: 1,
            rootSwiftNumericsCacheFetchCount: 1,
            rootSwiftNumericsWorkingCopyCreationCount: 1,
            rootSwiftNumericsResolutionCount: 1,
            isolatedAttempts: [
                .init(
                    order: 1,
                    packagePath:
                        "Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation",
                    expectedTestCount: 1,
                    swiftTestInvocationCount: 1,
                    swiftNumericsFetchAnnouncementCount: 1,
                    swiftNumericsCacheFetchCount: 1,
                    swiftNumericsWorkingCopyCreationCount: 1,
                    swiftNumericsResolutionCount: 1,
                    publicCloneAttemptCount: 0,
                    buildCompleted: true,
                    testExecutionStarted: true,
                    testSuiteCompleted: true,
                    executedTestCount: 1,
                    failureCount: 0,
                    skipCount: 0,
                    dnsFailureCount: 0,
                    commandConclusion: "success",
                    processExitCode: 0),
                .init(
                    order: 2,
                    packagePath:
                        "Tests/PrimeNativeDecoderCheckpointV2IOValidation",
                    expectedTestCount: 1,
                    swiftTestInvocationCount: 1,
                    swiftNumericsFetchAnnouncementCount: 1,
                    swiftNumericsCacheFetchCount: 1,
                    swiftNumericsWorkingCopyCreationCount: 1,
                    swiftNumericsResolutionCount: 1,
                    publicCloneAttemptCount: 0,
                    buildCompleted: true,
                    testExecutionStarted: true,
                    testSuiteCompleted: true,
                    executedTestCount: 1,
                    failureCount: 0,
                    skipCount: 0,
                    dnsFailureCount: 0,
                    commandConclusion: "success",
                    processExitCode: 0),
                .init(
                    order: 3,
                    packagePath:
                        "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation",
                    expectedTestCount: 2,
                    swiftTestInvocationCount: 1,
                    swiftNumericsFetchAnnouncementCount: 1,
                    swiftNumericsCacheFetchCount: 0,
                    swiftNumericsWorkingCopyCreationCount: 0,
                    swiftNumericsResolutionCount: 0,
                    publicCloneAttemptCount: 1,
                    buildCompleted: false,
                    testExecutionStarted: false,
                    testSuiteCompleted: false,
                    executedTestCount: 0,
                    failureCount: 0,
                    skipCount: 0,
                    dnsFailureCount: 1,
                    commandConclusion: "failure",
                    processExitCode: 1),
                .init(
                    order: 4,
                    packagePath:
                        "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation",
                    expectedTestCount: 2,
                    swiftTestInvocationCount: 0,
                    swiftNumericsFetchAnnouncementCount: 0,
                    swiftNumericsCacheFetchCount: 0,
                    swiftNumericsWorkingCopyCreationCount: 0,
                    swiftNumericsResolutionCount: 0,
                    publicCloneAttemptCount: 0,
                    buildCompleted: false,
                    testExecutionStarted: false,
                    testSuiteCompleted: false,
                    executedTestCount: 0,
                    failureCount: 0,
                    skipCount: 0,
                    dnsFailureCount: 0,
                    commandConclusion: "not_invoked",
                    processExitCode: -1),
            ],
            expectedIsolatedTestCount: 6,
            completedIsolatedTestCount: 2,
            observedWholeTestCount: 54,
            totalSwiftNumericsFetchAnnouncementCount: 4,
            totalSwiftNumericsCacheFetchCount: 3,
            totalSwiftNumericsWorkingCopyCreationCount: 3,
            totalSwiftNumericsResolutionCount: 3,
            totalPublicCloneAttemptCount: 1,
            totalDNSFailureCount: 1,
            dependencyIdentity: "swift-numerics",
            dependencyLocation: "https://github.com/apple/swift-numerics",
            dependencyRevision: "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
            dependencyVersion: "1.1.1",
            failureClass: "public_swift_numerics_clone_dns_resolution_failure",
            failedPackagePath:
                "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation",
            failedScratchRepositoryPath:
                "/Users/runner/work/_temp/prime-checkpoint-v2-io-execution-pure-build/repositories/swift-numerics-d936ec6c",
            exactCloneError:
                "error: 'swift-numerics': Failed to clone repository https://github.com/apple/swift-numerics:",
            exactDNSDiagnostic:
                "fatal: unable to access 'https://github.com/apple/swift-numerics/': Could not resolve host: github.com",
            publicDependencyTLSFailureCount: 0,
            publicDependencyTLSVerificationBypassCount: 0,
            workflowAuthoredRetryCount: 0,
            gitInternalRetryScheduledCount: 0,
            metalLauncherInvocationCount: 0,
            maintainedRuntimeLauncherInvocationCount: 0,
            tokenizerLauncherInvocationCount: 0,
            stage5LauncherInvocationCount: 0,
            stage5ReceiptCount: 0),
        resolutionRepair: .init(
            workflowPath:
                ".github/workflows/prime-active-root-quarantine.yml",
            repairActivationPoint:
                "after_successful_root_53_tests_before_first_of_four_isolated_swift_test_invocations",
            rootScratchPath: "$RUNNER_TEMP/prime-active-root-build",
            rootSwiftNumericsCheckoutPath:
                "$RUNNER_TEMP/prime-active-root-build/checkouts/swift-numerics",
            rootSwiftNumericsCacheRepositoryPath:
                "$RUNNER_TEMP/prime-active-root-build/repositories/swift-numerics-d936ec6c",
            sourceCheckoutRepositoryRootExpectedPath:
                "$RUNNER_TEMP/prime-active-root-build/checkouts/swift-numerics",
            sourceCheckoutAbsoluteGitDirectoryExpectedPath:
                "$RUNNER_TEMP/prime-active-root-build/checkouts/swift-numerics/.git",
            sourceCheckoutIsBare: false,
            sourceCheckoutExactRemoteNames: ["origin"],
            sourceCheckoutOriginURLValueCount: 1,
            sourceCheckoutExpectedOrigin:
                "$RUNNER_TEMP/prime-active-root-build/repositories/swift-numerics-d936ec6c",
            sourceCheckoutMustExistAsPhysicalDirectory: true,
            sourceCheckoutSymlinkAuthorized: false,
            sourceCheckoutRepositoryRootValidated: true,
            sourceCheckoutOriginValidated: true,
            sourceCheckoutExactRevision:
                "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
            sourceCheckoutCleanStatusRequired: true,
            sourceCheckoutValidatedAfterSuccessfulRootTests: true,
            sourceCheckoutOriginEqualsCacheRepositoryPathRequired: true,
            cacheRepositoryMustExistAsPhysicalDirectory: true,
            cacheRepositorySymlinkAuthorized: false,
            cacheRepositoryAbsoluteGitDirectoryExpectedPath:
                "$RUNNER_TEMP/prime-active-root-build/repositories/swift-numerics-d936ec6c",
            cacheRepositoryIsBare: true,
            cacheRepositoryExactRemoteNames: ["origin"],
            cacheRepositoryOriginURLValueCount: 1,
            cacheRepositoryExpectedOrigin:
                "https://github.com/apple/swift-numerics",
            cacheRepositoryOriginValidated: true,
            cacheRepositoryContainsExactRevision: true,
            cacheRepositoryExactRevisionObjectType: "commit",
            cacheRepositoryPeeledCommitEqualsExactRevision: true,
            cacheRepositoryPinnedVersionTag: "refs/tags/1.1.1",
            cacheRepositoryPinnedVersionTagPeeledCommitEqualsExactRevision:
                true,
            cacheRepositoryHEADMustEqualExactRevision: false,
            cacheRepositoryWorkingTreeCleanStatusApplicable: false,
            mappingActivatedBeforeFirstIsolatedBuild: true,
            mappedIsolatedSwiftTestInvocationCount: 4,
            exactMappedOrigin: "https://github.com/apple/swift-numerics",
            localMappingSource: "validated_bare_swiftpm_cache_repository",
            localMappingTemplate:
                "url.file://${numerics_cache}/.insteadOf=https://github.com/apple/swift-numerics",
            localMappingAppliesOnlyToExactOrigin: true,
            fileProtocolRequired: true,
            gitConfigCountAfterRepair: 3,
            gitConfigKeyOrder: [
                "url.file://${mlx_bare}/.insteadOf",
                "url.file://${numerics_cache}/.insteadOf",
                "protocol.file.allow",
            ],
            gitConfigValueOrder: [
                "https://github.com/Ergentics/ergentics-mlx-swift",
                "https://github.com/apple/swift-numerics",
                "always",
            ],
            existingMLXMappingPreserved: true,
            existingFileProtocolSettingPreserved: true,
            allLaterIsolatedBuildsMapped: true,
            mappingRemovedAfterFinalIsolatedBuild: true,
            publicSwiftNumericsFetchAfterMappingAuthorized: false,
            rootPublicSwiftNumericsResolutionPreserved: true,
            mappingCarriesCredential: false,
            packageManifestMutationAuthorized: false,
            packageResolvedMutationAuthorized: false,
            packageResolvedBytePreservationRequired: true,
            securePrivateFetchMutationAuthorized: false,
            workflowJobTopologyMutationAuthorized: false,
            workflowTimeoutMutationAuthorized: false,
            activeCheckoutMutationAuthorized: false,
            reviewedCheckoutMutationAuthorized: false,
            activeCheckoutDepth: 1,
            reviewedCheckoutDepth: 1,
            activeJobTimeoutMinutes: 45,
            reviewedJobTimeoutMinutes: 60),
        repairScope: .init(
            exactAuthorityClosurePaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityTests.swift",
            ],
            exactAuthorityClosurePathCount: 5,
            sourceAndTestAreOnlyNewPaths: true,
            authorityRootTestCount: 53,
            isolatedTestCount: 6,
            authorityFocusedWholeTestCount: 59,
            metalTestCount: 44,
            maintainedRuntimeTestCount: 1,
            maintainedRuntimeReceiptCount: 1,
            tokenizerTestCount: 1,
            tokenizerReceiptCount: 1,
            preStage5TestCount: 105,
            metalLauncherInvocationCount: 1,
            maintainedRuntimeLauncherInvocationCount: 1,
            tokenizerLauncherInvocationCount: 1,
            stage5LauncherInvocationCount: 0,
            stage5ReceiptCount: 0,
            authorityClosureLiveOrder: [
                "metal",
                "maintained_runtime",
                "tokenizer",
            ],
            exactFutureMechanicsPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift",
            ],
            exactFutureMechanicsPathCount: 6,
            futureMechanicsScopeUnchanged: true,
            futureStage5DirectXCTestCount: 1,
            futureMechanicsTotalTestCount: 106),
        ceiling: .init(
            pureAuthorityNoRepairExecutionEvidence: true,
            failedRunIsAuthorityClosureFailure: true,
            failedRunIsStage5MechanicsAttempt: false,
            failedRunConsumesStage5MechanicsOpportunity: false,
            oneExactMainRepairClosureExecutionAuthorized: true,
            stage5MechanicsOpportunityPreservedAfterGreenRepairClosure: true,
            additionalExecutionOrRerunAuthorized: false,
            genericNetworkRetryAuthorized: false,
            tlsOrCARepairAuthorized: false,
            secureFetchMutationAuthorized: false,
            stage5MechanicsExecuted: false,
            stage5ResultEstablished: false,
            retainedArtifactAuthorized: false,
            artifactUploadAuthorized: false,
            durableCheckpointIOAuthorized: false,
            crossDeviceClaimAuthorized: false,
            stage6Authorized: false,
            native300MAllocationAuthorized: false,
            native300MTrainingAuthorized: false,
            generalTrainingAuthorized: false,
            generalTrainingResumeEstablished: false,
            modelQualityEstablished: false,
            checkpointAdmissionGranted: false,
            candidateAdmissionGranted: false,
            downstreamTrialAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false),
        status:
            "AUTHORIZED_stage5_authority_exact_main_swift_numerics_dns_resolution_repair_reuse_validated_physical_backing_bare_swiftpm_cache_repository_for_exact_validated_root_checkout_across_four_isolated_builds_one_repair_closure_then_original_mechanics_opportunity_no_retry_tls_secure_fetch_scope_mechanics_stage6_native300m_training_quality_admission_retention_or_downstream_authority")

    public let schemaVersion: Int
    public let authorityID: String
    public let exactMainRun: PrimeNativeDecoderStage5SwiftNumericsRepairExactMainRunV1
    public let reviewedLog: PrimeNativeDecoderStage5SwiftNumericsRepairReviewedLogV1
    public let secureFetch: PrimeNativeDecoderStage5SwiftNumericsRepairSecureFetchV1
    public let failure: PrimeNativeDecoderStage5SwiftNumericsRepairFailureV1
    public let resolutionRepair: PrimeNativeDecoderStage5SwiftNumericsResolutionRepairV1
    public let repairScope: PrimeNativeDecoderStage5SwiftNumericsRepairScopeV1
    public let ceiling: PrimeNativeDecoderStage5SwiftNumericsRepairCeilingV1
    public let status: String

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityError
                .contractDrift
        }
        let stage5 = PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityV1
            .frozenV1
        let attempts = failure.isolatedAttempts
        let falseClaims = [
            ceiling.failedRunIsStage5MechanicsAttempt,
            ceiling.failedRunConsumesStage5MechanicsOpportunity,
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.genericNetworkRetryAuthorized,
            ceiling.tlsOrCARepairAuthorized,
            ceiling.secureFetchMutationAuthorized,
            ceiling.stage5MechanicsExecuted,
            ceiling.stage5ResultEstablished,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.crossDeviceClaimAuthorized,
            ceiling.stage6Authorized,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.generalTrainingAuthorized,
            ceiling.generalTrainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.candidateAdmissionGranted,
            ceiling.downstreamTrialAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
        guard schemaVersion == 1,
              authorityID == "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_exact_main_swift_numerics_resolution_repair_authority_v1",
              exactMainRun.repository == "Ergentics/ergentics-prime",
              exactMainRun.ref == "refs/heads/main",
              exactMainRun.orderedParentRevisions.count == 2,
              exactMainRun.stage5AuthorityCanonicalSHA256
                == PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityV1.canonicalSHA256,
              PrimeSHA256.hexDigest(of: try stage5.canonicalData())
                == exactMainRun.stage5AuthorityCanonicalSHA256,
              exactMainRun.runAttempt == 1,
              exactMainRun.previousAttemptAbsent,
              exactMainRun.exactHeadPushRunCount == 1,
              exactMainRun.rerunCount == 0,
              exactMainRun.artifactCount == 0,
              exactMainRun.activeJobConclusion == "success",
              exactMainRun.reviewedJobConclusion == "failure",
              exactMainRun.reviewedFailedStepIndex == 5,
              exactMainRun.terminalConclusion == "failure",
              reviewedLog.encoding == "UTF-8",
              reviewedLog.byteCount == 316_010,
              reviewedLog.lineFeedCount == 2_852,
              reviewedLog.byteOrderMarkPresent,
              reviewedLog.endsWithLineFeed,
              reviewedLog.processExitCode == 1,
              secureFetch == .init(
                  stepConclusion: "success", invocationCount: 1,
                  completionCount: 1, authenticatedDepthOneFetchCount: 1,
                  submoduleUpdateInvocationCount: 1, mlxCloneCount: 1,
                  mlxCCloneCount: 1, workflowAuthoredRetryCount: 0,
                  gitInternalRetryScheduledCount: 0, tlsFailureCount: 0,
                  tlsVerificationBypassCount: 0, customCAInstallationCount: 0),
              failure.rootBuildCompleted,
              failure.rootExecutedTestCount == 52,
              failure.rootFailureCount == 0,
              failure.rootSkipCount == 0,
              failure.stage5AuthorityTestExecutedCount == 1,
              attempts.count == 4,
              attempts.map(\.order) == [1, 2, 3, 4],
              attempts.map(\.expectedTestCount) == [1, 1, 2, 2],
              attempts.map(\.swiftTestInvocationCount) == [1, 1, 1, 0],
              attempts.map(\.buildCompleted) == [true, true, false, false],
              attempts.map(\.testExecutionStarted)
                == [true, true, false, false],
              attempts.map(\.testSuiteCompleted)
                == [true, true, false, false],
              attempts.map(\.executedTestCount) == [1, 1, 0, 0],
              attempts.map(\.dnsFailureCount) == [0, 0, 1, 0],
              attempts.map(\.commandConclusion)
                == ["success", "success", "failure", "not_invoked"],
              attempts.map(\.processExitCode) == [0, 0, 1, -1],
              failure.expectedIsolatedTestCount == 6,
              failure.completedIsolatedTestCount == 2,
              failure.observedWholeTestCount == 54,
              failure.totalSwiftNumericsFetchAnnouncementCount == 4,
              failure.totalSwiftNumericsCacheFetchCount == 3,
              failure.totalSwiftNumericsWorkingCopyCreationCount == 3,
              failure.totalSwiftNumericsResolutionCount == 3,
              failure.totalPublicCloneAttemptCount == 1,
              failure.totalDNSFailureCount == 1,
              failure.dependencyIdentity == "swift-numerics",
              failure.dependencyLocation == resolutionRepair.exactMappedOrigin,
              failure.dependencyRevision == resolutionRepair.sourceCheckoutExactRevision,
              failure.dependencyVersion == "1.1.1",
              failure.failureClass == "public_swift_numerics_clone_dns_resolution_failure",
              failure.publicDependencyTLSFailureCount == 0,
              failure.publicDependencyTLSVerificationBypassCount == 0,
              failure.workflowAuthoredRetryCount == 0,
              failure.gitInternalRetryScheduledCount == 0,
              failure.metalLauncherInvocationCount == 0,
              failure.maintainedRuntimeLauncherInvocationCount == 0,
              failure.tokenizerLauncherInvocationCount == 0,
              failure.stage5LauncherInvocationCount == 0,
              failure.stage5ReceiptCount == 0,
              resolutionRepair.sourceCheckoutMustExistAsPhysicalDirectory,
              !resolutionRepair.sourceCheckoutSymlinkAuthorized,
              resolutionRepair.sourceCheckoutRepositoryRootExpectedPath
                == resolutionRepair.rootSwiftNumericsCheckoutPath,
              resolutionRepair.sourceCheckoutAbsoluteGitDirectoryExpectedPath
                == resolutionRepair.rootSwiftNumericsCheckoutPath + "/.git",
              !resolutionRepair.sourceCheckoutIsBare,
              resolutionRepair.sourceCheckoutExactRemoteNames == ["origin"],
              resolutionRepair.sourceCheckoutOriginURLValueCount == 1,
              resolutionRepair.sourceCheckoutExpectedOrigin
                == resolutionRepair.rootSwiftNumericsCacheRepositoryPath,
              resolutionRepair.sourceCheckoutRepositoryRootValidated,
              resolutionRepair.sourceCheckoutOriginValidated,
              resolutionRepair.sourceCheckoutCleanStatusRequired,
              resolutionRepair.sourceCheckoutValidatedAfterSuccessfulRootTests,
              resolutionRepair
                .sourceCheckoutOriginEqualsCacheRepositoryPathRequired,
              resolutionRepair.cacheRepositoryMustExistAsPhysicalDirectory,
              !resolutionRepair.cacheRepositorySymlinkAuthorized,
              resolutionRepair.cacheRepositoryAbsoluteGitDirectoryExpectedPath
                == resolutionRepair.rootSwiftNumericsCacheRepositoryPath,
              resolutionRepair.cacheRepositoryIsBare,
              resolutionRepair.cacheRepositoryExactRemoteNames == ["origin"],
              resolutionRepair.cacheRepositoryOriginURLValueCount == 1,
              resolutionRepair.cacheRepositoryExpectedOrigin
                == resolutionRepair.exactMappedOrigin,
              resolutionRepair.cacheRepositoryOriginValidated,
              resolutionRepair.cacheRepositoryContainsExactRevision,
              resolutionRepair.cacheRepositoryExactRevisionObjectType
                == "commit",
              resolutionRepair
                .cacheRepositoryPeeledCommitEqualsExactRevision,
              resolutionRepair.cacheRepositoryPinnedVersionTag
                == "refs/tags/1.1.1",
              resolutionRepair
                .cacheRepositoryPinnedVersionTagPeeledCommitEqualsExactRevision,
              !resolutionRepair.cacheRepositoryHEADMustEqualExactRevision,
              !resolutionRepair
                .cacheRepositoryWorkingTreeCleanStatusApplicable,
              resolutionRepair.mappingActivatedBeforeFirstIsolatedBuild,
              resolutionRepair.mappedIsolatedSwiftTestInvocationCount == 4,
              resolutionRepair.localMappingSource
                == "validated_bare_swiftpm_cache_repository",
              resolutionRepair.localMappingAppliesOnlyToExactOrigin,
              resolutionRepair.fileProtocolRequired,
              resolutionRepair.gitConfigCountAfterRepair == 3,
              resolutionRepair.gitConfigKeyOrder == [
                  "url.file://${mlx_bare}/.insteadOf",
                  "url.file://${numerics_cache}/.insteadOf",
                  "protocol.file.allow",
              ],
              resolutionRepair.gitConfigValueOrder == [
                  "https://github.com/Ergentics/ergentics-mlx-swift",
                  "https://github.com/apple/swift-numerics",
                  "always",
              ],
              resolutionRepair.existingMLXMappingPreserved,
              resolutionRepair.existingFileProtocolSettingPreserved,
              resolutionRepair.allLaterIsolatedBuildsMapped,
              resolutionRepair.mappingRemovedAfterFinalIsolatedBuild,
              !resolutionRepair.publicSwiftNumericsFetchAfterMappingAuthorized,
              resolutionRepair.rootPublicSwiftNumericsResolutionPreserved,
              !resolutionRepair.mappingCarriesCredential,
              !resolutionRepair.packageManifestMutationAuthorized,
              !resolutionRepair.packageResolvedMutationAuthorized,
              resolutionRepair.packageResolvedBytePreservationRequired,
              !resolutionRepair.securePrivateFetchMutationAuthorized,
              !resolutionRepair.workflowJobTopologyMutationAuthorized,
              !resolutionRepair.workflowTimeoutMutationAuthorized,
              !resolutionRepair.activeCheckoutMutationAuthorized,
              !resolutionRepair.reviewedCheckoutMutationAuthorized,
              resolutionRepair.activeCheckoutDepth == 1,
              resolutionRepair.reviewedCheckoutDepth == 1,
              resolutionRepair.activeJobTimeoutMinutes == 45,
              resolutionRepair.reviewedJobTimeoutMinutes == 60,
              repairScope.exactAuthorityClosurePaths
                == repairScope.exactAuthorityClosurePaths.sorted(),
              Set(repairScope.exactAuthorityClosurePaths).count == 5,
              repairScope.exactAuthorityClosurePathCount == 5,
              repairScope.sourceAndTestAreOnlyNewPaths,
              repairScope.authorityRootTestCount == 53,
              repairScope.isolatedTestCount == 6,
              repairScope.authorityFocusedWholeTestCount == 59,
              repairScope.metalTestCount == 44,
              repairScope.maintainedRuntimeTestCount == 1,
              repairScope.maintainedRuntimeReceiptCount == 1,
              repairScope.tokenizerTestCount == 1,
              repairScope.tokenizerReceiptCount == 1,
              repairScope.preStage5TestCount == 105,
              repairScope.metalLauncherInvocationCount == 1,
              repairScope.maintainedRuntimeLauncherInvocationCount == 1,
              repairScope.tokenizerLauncherInvocationCount == 1,
              repairScope.stage5LauncherInvocationCount == 0,
              repairScope.stage5ReceiptCount == 0,
              repairScope.authorityClosureLiveOrder
                == ["metal", "maintained_runtime", "tokenizer"],
              repairScope.exactFutureMechanicsPaths
                == repairScope.exactFutureMechanicsPaths.sorted(),
              Set(repairScope.exactFutureMechanicsPaths).count == 6,
              repairScope.exactFutureMechanicsPathCount == 6,
              repairScope.futureMechanicsScopeUnchanged,
              repairScope.futureStage5DirectXCTestCount == 1,
              repairScope.futureMechanicsTotalTestCount == 106,
              ceiling.pureAuthorityNoRepairExecutionEvidence,
              ceiling.failedRunIsAuthorityClosureFailure,
              ceiling.oneExactMainRepairClosureExecutionAuthorized,
              ceiling.stage5MechanicsOpportunityPreservedAfterGreenRepairClosure,
              falseClaims.allSatisfy({ !$0 }),
              status == "AUTHORIZED_stage5_authority_exact_main_swift_numerics_dns_resolution_repair_reuse_validated_physical_backing_bare_swiftpm_cache_repository_for_exact_validated_root_checkout_across_four_isolated_builds_one_repair_closure_then_original_mechanics_opportunity_no_retry_tls_secure_fetch_scope_mechanics_stage6_native300m_training_quality_admission_retention_or_downstream_authority"
        else {
            throw PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityError
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
            throw PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityError
                .nonCanonicalEncoding
        }
        return value
    }
}
