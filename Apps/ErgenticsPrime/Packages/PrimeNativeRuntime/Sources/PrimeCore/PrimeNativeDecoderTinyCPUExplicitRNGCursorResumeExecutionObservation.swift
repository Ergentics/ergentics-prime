import Foundation

public enum PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationError: Error, Equatable {
    case invalid(String)
    case nonCanonicalEncoding
}

public struct PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationV1: Codable, Equatable, Sendable {
    public struct RunV1: Codable, Equatable, Sendable {
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParents: [String]
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let checkSuiteID: Int
        public let runAttempt: Int
        public let activeJobID: Int
        public let reviewedJobID: Int
        public let exactHeadPushRunCount: Int
        public let rerunCount: Int
        public let artifactCount: Int
        public let terminalConclusion: String
    }

    public struct PredecessorV1: Codable, Equatable, Sendable {
        public let focusedRootTestCount: Int
        public let focusedIsolatedTestCount: Int
        public let metalTestCount: Int
        public let maintainedRuntimeTestCount: Int
        public let tokenizerTestCount: Int
        public let exactOrder: [String]
        public let allPassed: Bool
    }

    public struct MetallibV1: Codable, Equatable, Sendable {
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

    public struct Stage3V1: Codable, Equatable, Sendable {
        public let authorityCanonicalSHA256: String
        public let receiptID: String
        public let receiptPrefixOccurrenceCount: Int
        public let receiptPayloadByteCount: Int
        public let receiptPayloadSHA256: String
        public let status: String
        public let buildCount: Int
        public let directXCTestCount: Int
        public let testClass: String
        public let testMethod: String
        public let testFilter: String
        public let startedCount: Int
        public let passedCount: Int
        public let failureCount: Int
        public let skipCount: Int
        public let typedInMemorySnapshotExportRestoreEstablished: Bool
        public let uninterruptedAndFreshRestoredStep2ExactEqualityEstablished: Bool
        public let explicitRNGKeyCounterAndNextCursorBoundaryEstablished: Bool
    }

    public struct RetirementV1: Codable, Equatable, Sendable {
        public let exactChangedPaths: [String]
        public let expectedRootTestCount: Int
        public let reviewedCheckoutDepth: Int
        public let retainedLiveOrder: [String]
        public let stage3LauncherInvocationCount: Int
        public let stage3LauncherSourcePreserved: Bool
        public let successfulAttemptConsumed: Bool
        public let retryOrRerunAuthorized: Bool
        public let checkpointIOAuthorized: Bool
        public let filesystemCapabilityAuthorized: Bool
        public let stage4Authorized: Bool
        public let native300MTrainingAuthorized: Bool
        public let productOrPublicationAuthorized: Bool
        public let exactMainRetirementClosureRequired: Bool
    }

    public let schemaVersion: Int
    public let observationID: String
    public let run: RunV1
    public let predecessor: PredecessorV1
    public let metallib: MetallibV1
    public let stage3: Stage3V1
    public let retirement: RetirementV1

    public static let canonicalSHA256 = "9f0d4c974eca94edc6ca9953cd9cd27fef2e53ad6850addcbfc0a80512530d8d"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID: "ergentics_prime_native_decoder_tiny_cpu_explicit_rng_cursor_resume_execution_observation_v1",
        run: .init(
            mergeRevision: "ea96f7a503adfb5e814f81f2180318f8d1f06abd",
            mergeTree: "5b097e30a979fa1847808775468e67a51c5cf2ad",
            orderedParents: [
                "372248bd2e2d282bbb2b0fe39273211aee0da43a",
                "b73618502529fd575d493d1d0e7b49694ece850f",
            ],
            workflowRunID: 31_679_144_989,
            workflowRunNumber: 89,
            checkSuiteID: 85_937_734_896,
            runAttempt: 1,
            activeJobID: 94_380_354_972,
            reviewedJobID: 94_381_165_923,
            exactHeadPushRunCount: 1,
            rerunCount: 0,
            artifactCount: 0,
            terminalConclusion: "success"),
        predecessor: .init(
            focusedRootTestCount: 47,
            focusedIsolatedTestCount: 6,
            metalTestCount: 44,
            maintainedRuntimeTestCount: 1,
            tokenizerTestCount: 1,
            exactOrder: ["metal", "maintained_runtime", "tokenizer", "stage3"],
            allPassed: true),
        metallib: .init(
            byteCount: 6_292_748,
            sha256: "1b5d6fa67453f0abcb09d05f5c31f1aa10ef2b1c6711ca28b7d111259f787f97",
            sourceCandidateCount: 1,
            stagedCopyCount: 2,
            stagedPermissionMode: "444",
            loadedPathInferred: false,
            independentlyObservedLoadedIdentity: false,
            retainedAfterJob: false,
            artifactProvenanceEstablished: false),
        stage3: .init(
            authorityCanonicalSHA256: "0ab57d5e8c71b18d03c9730da1e90399d57c05ccaa155aa31aff0c3001987fe6",
            receiptID: "prime_native_decoder_stage3_tiny_cpu_explicit_rng_cursor_resume_receipt_v1",
            receiptPrefixOccurrenceCount: 1,
            receiptPayloadByteCount: 2_842,
            receiptPayloadSHA256: "f14c68a835ff6779a4b3a3fe5ab0f66e464d2070d63538c32f19842045f7826e",
            status: "PASS_exact_main_tiny_cpu_explicit_rng_cursor_resume_one_test_zero_failure_zero_skip",
            buildCount: 1,
            directXCTestCount: 1,
            testClass: "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests",
            testMethod: "testTinyCPUExplicitRNGCursorResumeIsExactAndFailClosed",
            testFilter: "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests/testTinyCPUExplicitRNGCursorResumeIsExactAndFailClosed",
            startedCount: 1,
            passedCount: 1,
            failureCount: 0,
            skipCount: 0,
            typedInMemorySnapshotExportRestoreEstablished: true,
            uninterruptedAndFreshRestoredStep2ExactEqualityEstablished: true,
            explicitRNGKeyCounterAndNextCursorBoundaryEstablished: true),
        retirement: .init(
            exactChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservation.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationTests.swift",
            ],
            expectedRootTestCount: 48,
            reviewedCheckoutDepth: 1,
            retainedLiveOrder: ["metal", "maintained_runtime", "tokenizer"],
            stage3LauncherInvocationCount: 0,
            stage3LauncherSourcePreserved: true,
            successfulAttemptConsumed: true,
            retryOrRerunAuthorized: false,
            checkpointIOAuthorized: false,
            filesystemCapabilityAuthorized: false,
            stage4Authorized: false,
            native300MTrainingAuthorized: false,
            productOrPublicationAuthorized: false,
            exactMainRetirementClosureRequired: true))

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else { throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationError.invalid("not frozen V1") }
        guard schemaVersion == 1,
              run.orderedParents.count == 2,
              run.runAttempt == 1,
              run.exactHeadPushRunCount == 1,
              run.rerunCount == 0,
              run.artifactCount == 0,
              run.terminalConclusion == "success",
              predecessor.focusedRootTestCount == 47,
              predecessor.focusedIsolatedTestCount == 6,
              predecessor.metalTestCount == 44,
              predecessor.maintainedRuntimeTestCount == 1,
              predecessor.tokenizerTestCount == 1,
              predecessor.allPassed,
              !metallib.loadedPathInferred,
              !metallib.independentlyObservedLoadedIdentity,
              !metallib.retainedAfterJob,
              !metallib.artifactProvenanceEstablished,
              stage3.receiptPrefixOccurrenceCount == 1,
              stage3.buildCount == 1,
              stage3.directXCTestCount == 1,
              stage3.startedCount == 1,
              stage3.passedCount == 1,
              stage3.failureCount == 0,
              stage3.skipCount == 0,
              stage3.typedInMemorySnapshotExportRestoreEstablished,
              stage3.uninterruptedAndFreshRestoredStep2ExactEqualityEstablished,
              stage3.explicitRNGKeyCounterAndNextCursorBoundaryEstablished,
              retirement.exactChangedPaths == retirement.exactChangedPaths.sorted(),
              retirement.exactChangedPaths.count == 5,
              retirement.expectedRootTestCount == 48,
              retirement.reviewedCheckoutDepth == 1,
              retirement.retainedLiveOrder == ["metal", "maintained_runtime", "tokenizer"],
              retirement.stage3LauncherInvocationCount == 0,
              retirement.stage3LauncherSourcePreserved,
              retirement.successfulAttemptConsumed,
              !retirement.retryOrRerunAuthorized,
              !retirement.checkpointIOAuthorized,
              !retirement.filesystemCapabilityAuthorized,
              !retirement.stage4Authorized,
              !retirement.native300MTrainingAuthorized,
              !retirement.productOrPublicationAuthorized,
              retirement.exactMainRetirementClosureRequired else {
            throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationError.invalid("invariant failed")
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
        guard try value.canonicalData() == data else { throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationError.nonCanonicalEncoding }
        return value
    }
}
