import Foundation

public enum PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityError: Error, Equatable {
    case invalid(String)
    case nonCanonicalEncoding
}

public struct PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityV1: Codable, Equatable, Sendable {
    public struct FailureV1: Codable, Equatable, Sendable {
        public let mergeRevision: String
        public let mergeTree: String
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let checkSuiteID: Int
        public let runAttempt: Int
        public let activeJobID: Int
        public let reviewedJobID: Int
        public let rootTestCount: Int
        public let metalTestCount: Int
        public let runtimeTestCount: Int
        public let tokenizerTestCount: Int
        public let stage3LauncherInvocationCount: Int
        public let stage3BuildCount: Int
        public let stage3TestStartedCount: Int
        public let stage3ReceiptCount: Int
        public let artifactCount: Int
        public let rerunCount: Int
        public let diagnostic: String
    }

    public struct InventoryV1: Codable, Equatable, Sendable {
        public let exactSortedPaths: [String]
        public let incorrectExpectedPaths: [String]
        public let observedInventoryCount: Int
        public let incorrectOrderWasTrainingThenTinyCPU: Bool
        public let requiredOrderIsTinyCPUThenTraining: Bool
        public let packageInventoryMutationObserved: Bool
        public let failureWasBeforeStage3Build: Bool
        public let failureWasBeforeStage3Test: Bool
        public let stage3MechanicsFailureEstablished: Bool
    }

    public struct RepairV1: Codable, Equatable, Sendable {
        public let exactChangedPaths: [String]
        public let baseRevision: String
        public let baseTree: String
        public let expectedRootTestCount: Int
        public let inventoryExpectedOrderReplacementCount: Int
        public let launcherPreflightStaticAuditRequired: Bool
        public let originalAuthorityMutationAuthorized: Bool
        public let priorRepairAuthorityMutationAuthorized: Bool
        public let trainingOrValidationMutationAuthorized: Bool
        public let manifestOrLockMutationAuthorized: Bool
        public let secureFetchOrTimeoutMutationAuthorized: Bool
        public let retryOrRerunAuthorized: Bool
        public let oneDistinctDirectMainSuccessorAuthorized: Bool
    }

    public struct CeilingV1: Codable, Equatable, Sendable {
        public let priorAttemptConsumed: Bool
        public let stage3ExecutionEstablished: Bool
        public let trainingResumeEstablished: Bool
        public let filesystemCheckpointAuthorized: Bool
        public let stage4Authorized: Bool
        public let artifactAuthorized: Bool
        public let productOrPublicationAuthorized: Bool
        public let terminalOutcomeObservationRequired: Bool
    }

    public let schemaVersion: Int
    public let authorityID: String
    public let predecessorRepairAuthorityCanonicalSHA256: String
    public let failure: FailureV1
    public let inventory: InventoryV1
    public let repair: RepairV1
    public let ceiling: CeilingV1

    public static let canonicalSHA256 = "52f2619ebcbc6e8d608042ffb107411bbcb6ac4630482dba0007436f52bb03ce"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID: "ergentics_prime_native_decoder_tiny_cpu_explicit_rng_cursor_resume_validation_inventory_order_repair_v1",
        predecessorRepairAuthorityCanonicalSHA256: "34cd246fbeb754f31f7ecf3fee03d35fdc5c615e5a61c245e609a7ef03845b59",
        failure: .init(
            mergeRevision: "372248bd2e2d282bbb2b0fe39273211aee0da43a",
            mergeTree: "f4df5d9b17c216748387435ef0f1f8d14ede2f54",
            workflowRunID: 31_674_969_104,
            workflowRunNumber: 87,
            checkSuiteID: 85_926_465_475,
            runAttempt: 1,
            activeJobID: 94_367_450_259,
            reviewedJobID: 94_368_065_707,
            rootTestCount: 46,
            metalTestCount: 44,
            runtimeTestCount: 1,
            tokenizerTestCount: 1,
            stage3LauncherInvocationCount: 1,
            stage3BuildCount: 0,
            stage3TestStartedCount: 0,
            stage3ReceiptCount: 0,
            artifactCount: 0,
            rerunCount: 0,
            diagnostic: "prime-native-decoder-stage3-tiny-cpu-resume: validation package inventory changed"),
        inventory: .init(
            exactSortedPaths: [
                "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved",
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift",
            ],
            incorrectExpectedPaths: [
                "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved",
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift",
            ],
            observedInventoryCount: 4,
            incorrectOrderWasTrainingThenTinyCPU: true,
            requiredOrderIsTinyCPUThenTraining: true,
            packageInventoryMutationObserved: false,
            failureWasBeforeStage3Build: true,
            failureWasBeforeStage3Test: true,
            stage3MechanicsFailureEstablished: false),
        repair: .init(
            exactChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage3-tiny-cpu-resume.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityTests.swift",
            ],
            baseRevision: "372248bd2e2d282bbb2b0fe39273211aee0da43a",
            baseTree: "f4df5d9b17c216748387435ef0f1f8d14ede2f54",
            expectedRootTestCount: 47,
            inventoryExpectedOrderReplacementCount: 1,
            launcherPreflightStaticAuditRequired: true,
            originalAuthorityMutationAuthorized: false,
            priorRepairAuthorityMutationAuthorized: false,
            trainingOrValidationMutationAuthorized: false,
            manifestOrLockMutationAuthorized: false,
            secureFetchOrTimeoutMutationAuthorized: false,
            retryOrRerunAuthorized: false,
            oneDistinctDirectMainSuccessorAuthorized: true),
        ceiling: .init(
            priorAttemptConsumed: true,
            stage3ExecutionEstablished: false,
            trainingResumeEstablished: false,
            filesystemCheckpointAuthorized: false,
            stage4Authorized: false,
            artifactAuthorized: false,
            productOrPublicationAuthorized: false,
            terminalOutcomeObservationRequired: true))

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else { throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityError.invalid("not frozen V1") }
        guard schemaVersion == 1,
              failure.runAttempt == 1,
              failure.rootTestCount == 46,
              failure.metalTestCount == 44,
              failure.runtimeTestCount == 1,
              failure.tokenizerTestCount == 1,
              failure.stage3LauncherInvocationCount == 1,
              failure.stage3BuildCount == 0,
              failure.stage3TestStartedCount == 0,
              failure.stage3ReceiptCount == 0,
              failure.artifactCount == 0,
              failure.rerunCount == 0,
              inventory.exactSortedPaths == inventory.exactSortedPaths.sorted(),
              inventory.exactSortedPaths.count == inventory.observedInventoryCount,
              inventory.incorrectExpectedPaths != inventory.exactSortedPaths,
              inventory.incorrectOrderWasTrainingThenTinyCPU,
              inventory.requiredOrderIsTinyCPUThenTraining,
              !inventory.packageInventoryMutationObserved,
              inventory.failureWasBeforeStage3Build,
              inventory.failureWasBeforeStage3Test,
              !inventory.stage3MechanicsFailureEstablished,
              repair.exactChangedPaths == repair.exactChangedPaths.sorted(),
              repair.exactChangedPaths.count == 6,
              repair.expectedRootTestCount == 47,
              repair.inventoryExpectedOrderReplacementCount == 1,
              repair.launcherPreflightStaticAuditRequired,
              !repair.originalAuthorityMutationAuthorized,
              !repair.priorRepairAuthorityMutationAuthorized,
              !repair.trainingOrValidationMutationAuthorized,
              !repair.manifestOrLockMutationAuthorized,
              !repair.secureFetchOrTimeoutMutationAuthorized,
              !repair.retryOrRerunAuthorized,
              repair.oneDistinctDirectMainSuccessorAuthorized,
              ceiling.priorAttemptConsumed,
              !ceiling.stage3ExecutionEstablished,
              !ceiling.trainingResumeEstablished,
              !ceiling.filesystemCheckpointAuthorized,
              !ceiling.stage4Authorized,
              !ceiling.artifactAuthorized,
              !ceiling.productOrPublicationAuthorized,
              ceiling.terminalOutcomeObservationRequired else {
            throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityError.invalid("invariant failed")
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
        guard try value.canonicalData() == data else { throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityError.nonCanonicalEncoding }
        return value
    }
}
