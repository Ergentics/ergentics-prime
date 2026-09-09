import Foundation

public enum PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityError: Error, Equatable {
    case invalid(String)
    case nonCanonicalEncoding
}

public struct PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityV1: Codable, Equatable, Sendable {
    public struct TerminalFailureEvidenceV1: Codable, Equatable, Sendable {
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParents: [String]
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let checkSuiteID: Int
        public let runAttempt: Int
        public let activeJobID: Int
        public let reviewedJobID: Int
        public let workflowConclusion: String
        public let rootTestCount: Int
        public let rootFailureCount: Int
        public let metalTestCount: Int
        public let runtimeTestCount: Int
        public let tokenizerTestCount: Int
        public let stage3LauncherInvocationCount: Int
        public let stage3BuildCount: Int
        public let stage3DirectXCTestCount: Int
        public let stage3TestStartedCount: Int
        public let stage3TestPassedCount: Int
        public let stage3ReceiptCount: Int
        public let artifactsCount: Int
        public let rerunCount: Int
        public let terminalDiagnostic: String
        public let liveStepStartedAt: String
        public let liveStepCompletedAt: String
    }

    public struct BindingDefectV1: Codable, Equatable, Sendable {
        public let frozenLauncherBlob: String
        public let frozenLauncherSHA256: String
        public let authoritySourceBlob: String
        public let authorityTestBlob: String
        public let canonicalSHA256: String
        public let canonicalOccurrenceCountInAuthoritySource: Int
        public let canonicalOccurrenceCountInAuthorityTest: Int
        public let failedSearchLiteral: String
        public let repairedSearchLiteral: String
        public let failureWasBeforeStage3Build: Bool
        public let failureWasBeforeStage3Test: Bool
        public let stage3MechanicsFailureEstablished: Bool
    }

    public struct RepairScopeV1: Codable, Equatable, Sendable {
        public let exactChangedPaths: [String]
        public let expectedRootTestCount: Int
        public let reviewedCheckoutDepth: Int
        public let retainedLiveLauncherOrder: [String]
        public let launcherCanonicalSearchReplacementCount: Int
        public let originalAuthorityMutationAuthorized: Bool
        public let trainingSourceMutationAuthorized: Bool
        public let resumeValidationTestMutationAuthorized: Bool
        public let manifestOrLockMutationAuthorized: Bool
        public let secureFetchMutationAuthorized: Bool
        public let timeoutMutationAuthorized: Bool
        public let uploadAuthorized: Bool
        public let retryOrRerunAuthorized: Bool
        public let distinctDirectMainSuccessorAttemptAuthorized: Bool
    }

    public struct CeilingV1: Codable, Equatable, Sendable {
        public let priorAttemptConsumed: Bool
        public let priorAttemptRecoverable: Bool
        public let stage3ExecutionEstablished: Bool
        public let trainingResumeEstablished: Bool
        public let filesystemCheckpointAuthorized: Bool
        public let checkpointCodecAuthorized: Bool
        public let artifactRootAuthorized: Bool
        public let stage4Authorized: Bool
        public let native300MTrainingAuthorized: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
        public let outcomeObservationRequired: Bool
    }

    public let schemaVersion: Int
    public let authorityID: String
    public let predecessorAuthorityID: String
    public let predecessorAuthorityCanonicalSHA256: String
    public let failure: TerminalFailureEvidenceV1
    public let defect: BindingDefectV1
    public let repair: RepairScopeV1
    public let ceiling: CeilingV1

    public static let canonicalSHA256 =
        "34cd246fbeb754f31f7ecf3fee03d35fdc5c615e5a61c245e609a7ef03845b59"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID: "ergentics_prime_native_decoder_tiny_cpu_explicit_rng_cursor_resume_authority_canonical_binding_repair_v1",
        predecessorAuthorityID: "ergentics_prime_native_decoder_tiny_cpu_explicit_rng_cursor_resume_v1",
        predecessorAuthorityCanonicalSHA256: "0ab57d5e8c71b18d03c9730da1e90399d57c05ccaa155aa31aff0c3001987fe6",
        failure: .init(
            mergeRevision: "e175bc5b99e89002184850d3fce5db595f2b9311",
            mergeTree: "a4234937afa62ab85d26876c84481622b0505723",
            orderedParents: [
                "90927b9e5a167e69dbb71d88e92c342f3fd0fd93",
                "5118561a98b474fd3f0faaa46784a5ca2f093aa5",
            ],
            workflowRunID: 31_671_673_260,
            workflowRunNumber: 85,
            checkSuiteID: 85_917_692_508,
            runAttempt: 1,
            activeJobID: 94_357_402_159,
            reviewedJobID: 94_357_870_549,
            workflowConclusion: "failure",
            rootTestCount: 45,
            rootFailureCount: 0,
            metalTestCount: 44,
            runtimeTestCount: 1,
            tokenizerTestCount: 1,
            stage3LauncherInvocationCount: 1,
            stage3BuildCount: 0,
            stage3DirectXCTestCount: 0,
            stage3TestStartedCount: 0,
            stage3TestPassedCount: 0,
            stage3ReceiptCount: 0,
            artifactsCount: 0,
            rerunCount: 0,
            terminalDiagnostic: "prime-native-decoder-stage3-tiny-cpu-resume: authority canonical digest changed",
            liveStepStartedAt: "2026-08-13T06:09:04Z",
            liveStepCompletedAt: "2026-08-13T06:25:26Z"),
        defect: .init(
            frozenLauncherBlob: "d81f33663118b8345226c0414b432a17cfd444d3",
            frozenLauncherSHA256: "fc052be0db48e4f2105706b97ef0a8f157af0548328cf2b09716f4e48244c159",
            authoritySourceBlob: "65cb43e09e9839c0b03cc2e5fafd1ad0b1d4f4fa",
            authorityTestBlob: "ab751cfbb2bf728054d3e91ae25d5fce1be8533a",
            canonicalSHA256: "0ab57d5e8c71b18d03c9730da1e90399d57c05ccaa155aa31aff0c3001987fe6",
            canonicalOccurrenceCountInAuthoritySource: 1,
            canonicalOccurrenceCountInAuthorityTest: 0,
            failedSearchLiteral: "grep -Fq \"$authority_canonical_sha256\" \"$authority_test\"",
            repairedSearchLiteral: "grep -Fq \"$authority_canonical_sha256\" \"$authority_source\"",
            failureWasBeforeStage3Build: true,
            failureWasBeforeStage3Test: true,
            stage3MechanicsFailureEstablished: false),
        repair: .init(
            exactChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage3-tiny-cpu-resume.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityTests.swift",
            ],
            expectedRootTestCount: 46,
            reviewedCheckoutDepth: 2,
            retainedLiveLauncherOrder: [
                "prime-ci-native-decoder-metal.sh",
                "prime-ci-native-decoder-maintained-runtime-closure.sh",
                "prime-ci-native-decoder-tokenizer-compatibility.sh",
                "prime-ci-native-decoder-stage3-tiny-cpu-resume.sh",
            ],
            launcherCanonicalSearchReplacementCount: 1,
            originalAuthorityMutationAuthorized: false,
            trainingSourceMutationAuthorized: false,
            resumeValidationTestMutationAuthorized: false,
            manifestOrLockMutationAuthorized: false,
            secureFetchMutationAuthorized: false,
            timeoutMutationAuthorized: false,
            uploadAuthorized: false,
            retryOrRerunAuthorized: false,
            distinctDirectMainSuccessorAttemptAuthorized: true),
        ceiling: .init(
            priorAttemptConsumed: true,
            priorAttemptRecoverable: false,
            stage3ExecutionEstablished: false,
            trainingResumeEstablished: false,
            filesystemCheckpointAuthorized: false,
            checkpointCodecAuthorized: false,
            artifactRootAuthorized: false,
            stage4Authorized: false,
            native300MTrainingAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false,
            outcomeObservationRequired: true))

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityError.invalid("authority differs from frozen V1")
        }
        guard schemaVersion == 1,
              failure.orderedParents.count == 2,
              failure.runAttempt == 1,
              failure.rootTestCount == 45,
              failure.rootFailureCount == 0,
              failure.metalTestCount == 44,
              failure.runtimeTestCount == 1,
              failure.tokenizerTestCount == 1,
              failure.stage3LauncherInvocationCount == 1,
              failure.stage3BuildCount == 0,
              failure.stage3DirectXCTestCount == 0,
              failure.stage3TestStartedCount == 0,
              failure.stage3TestPassedCount == 0,
              failure.stage3ReceiptCount == 0,
              failure.artifactsCount == 0,
              failure.rerunCount == 0,
              defect.canonicalOccurrenceCountInAuthoritySource == 1,
              defect.canonicalOccurrenceCountInAuthorityTest == 0,
              defect.failureWasBeforeStage3Build,
              defect.failureWasBeforeStage3Test,
              !defect.stage3MechanicsFailureEstablished,
              repair.exactChangedPaths == repair.exactChangedPaths.sorted(),
              repair.exactChangedPaths.count == 6,
              repair.expectedRootTestCount == 46,
              repair.reviewedCheckoutDepth == 2,
              repair.launcherCanonicalSearchReplacementCount == 1,
              !repair.originalAuthorityMutationAuthorized,
              !repair.trainingSourceMutationAuthorized,
              !repair.resumeValidationTestMutationAuthorized,
              !repair.manifestOrLockMutationAuthorized,
              !repair.secureFetchMutationAuthorized,
              !repair.timeoutMutationAuthorized,
              !repair.uploadAuthorized,
              !repair.retryOrRerunAuthorized,
              repair.distinctDirectMainSuccessorAttemptAuthorized,
              ceiling.priorAttemptConsumed,
              !ceiling.priorAttemptRecoverable,
              !ceiling.stage3ExecutionEstablished,
              !ceiling.trainingResumeEstablished,
              !ceiling.filesystemCheckpointAuthorized,
              !ceiling.checkpointCodecAuthorized,
              !ceiling.artifactRootAuthorized,
              !ceiling.stage4Authorized,
              !ceiling.native300MTrainingAuthorized,
              !ceiling.productUseAuthorized,
              !ceiling.publicationAuthorized,
              ceiling.outcomeObservationRequired else {
            throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityError.invalid("frozen V1 invariant failed")
        }
    }

    public func canonicalData() throws -> Data {
        try validateExactV1()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let decoder = JSONDecoder()
        let value = try decoder.decode(Self.self, from: data)
        try value.validateExactV1()
        guard try value.canonicalData() == data else {
            throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityError.nonCanonicalEncoding
        }
        return value
    }
}
