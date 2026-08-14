// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreGraphics
import Darwin
import Foundation
import Metal
import MLX
import MLXNN
import MLXOptimizers
import PrimeCore
import PrimeNativeDecoder

public enum PrimeNativeDecoderNative300MResourceOnlyOneStepProbe {
    public static let receiptPrefix =
        "PRIME_NATIVE_DECODER_STAGE6_NATIVE300M_RESOURCE_ONLY_ONE_STEP_RECEIPT="
    public static let receiptSchemaID =
        "ergentics_prime_native_decoder_native300m_resource_only_one_step_probe_receipt_v1"
    public static let phaseNames = [
        "preflight",
        "post_model_materialization",
        "post_forward_backward",
        "post_norm_clip",
        "post_adam_update_full_evaluation",
        "post_lexical_deallocation_and_clear_cache",
    ]
    public static let classificationDomain = [
        "pass", "worker_spawn_failure", "preflight_floor", "lease_busy",
        "oom", "timeout", "signal", "nonfinite", "topology_dtype",
        "no_update", "executor_receipt_drift",
    ]
    public static let operationCountKeys = [
        "adamw_update_count", "backward_count",
        "checked_evaluation_barrier_count", "cross_entropy_count",
        "evaluation_forward_pass_count", "forward_loss_count",
        "full_graph_evaluation_count",
        "gpu_synchronization_barrier_count", "gradient_clip_count",
        "gradient_norm_count", "kv_cache_allocation_count",
        "memory_clear_cache_count", "mlx_peak_memory_reset_count",
        "model_allocation_count", "model_materialization_count",
        "optimizer_step_count", "postflight_device_reenumeration_count",
        "training_logits_count", "value_and_grad_count",
    ]

    public static let environmentVariableNames = [
        "PRIME_NATIVE_DECODER_STAGE6_METAL_LEASE_PATH",
        "PRIME_NATIVE_DECODER_STAGE6_EXACT_MLX_REVISION",
        "PRIME_NATIVE_DECODER_STAGE6_METALLIB_PATH",
        "PRIME_NATIVE_DECODER_STAGE6_METALLIB_BYTES",
        "PRIME_NATIVE_DECODER_STAGE6_METALLIB_SHA256",
        "PRIME_NATIVE_DECODER_STAGE6_OPERATING_SYSTEM_BUILD",
        "PRIME_NATIVE_DECODER_STAGE6_KERNEL_IDENTITY",
        "PRIME_NATIVE_DECODER_STAGE6_SWIFT_TOOLCHAIN",
        "PRIME_NATIVE_DECODER_STAGE6_XCODE_TOOLCHAIN",
        "PRIME_NATIVE_DECODER_STAGE6_MACOS_SDK",
        "PRIME_NATIVE_DECODER_STAGE6_BUILD_CONFIGURATION",
        "PRIME_NATIVE_DECODER_STAGE6_MLX_GRAPH_COMPILE_MODE",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_ID",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CANONICAL_SHA256",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_SOURCE_IDENTITY_JSON",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_TEST_IDENTITY_JSON",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_BASE_REVISION",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_BASE_TREE",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_REVISION",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_TREE",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_RUN_ID",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_RUN_NUMBER",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_RUN_ATTEMPT",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_CHECK_SUITE_ID",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_ACTIVE_JOB_ID",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_ACTIVE_JOB_CONCLUSION",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_REVIEWED_JOB_ID",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_REVIEWED_JOB_CONCLUSION",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_EVENT",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_REF",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_STATUS",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_CONCLUSION",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_ARTIFACT_COUNT",
        "PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_RERUN_COUNT",
        "PRIME_NATIVE_DECODER_STAGE6_MECHANICS_EXECUTED_REVISION",
        "PRIME_NATIVE_DECODER_STAGE6_MECHANICS_EXECUTED_TREE",
        "PRIME_NATIVE_DECODER_STAGE6_MECHANICS_FIRST_PARENT",
        "PRIME_NATIVE_DECODER_STAGE6_MECHANICS_SECOND_PARENT",
        "PRIME_NATIVE_DECODER_STAGE6_MECHANICS_EVENT",
        "PRIME_NATIVE_DECODER_STAGE6_MECHANICS_REF",
        "PRIME_NATIVE_DECODER_STAGE6_MECHANICS_RUN_ID",
        "PRIME_NATIVE_DECODER_STAGE6_MECHANICS_RUN_NUMBER",
        "PRIME_NATIVE_DECODER_STAGE6_MECHANICS_RUN_ATTEMPT",
        "PRIME_NATIVE_DECODER_STAGE6_EXACT_CHANGED_SOURCE_IDENTITIES_JSON",
        "PRIME_NATIVE_DECODER_STAGE6_PROVENANCE_SOURCE_IDENTITIES_JSON",
        "PRIME_NATIVE_DECODER_STAGE6_EMBEDDED_SOURCE_IDENTITY_SHA256",
    ]

    private static let workerArgument =
        "--prime-stage6-native300m-resource-worker-v1"
    private static let workerFrameDescriptor = Int32(19)
    fileprivate static let maximumFrameByteCount = 1_048_576
    private static let workerActiveTimeoutNanoseconds: UInt64 =
        1_200_000_000_000
    private static let supervisorTimeoutNanoseconds: UInt64 =
        1_500_000_000_000
    private static let terminationGraceNanoseconds: UInt64 =
        10_000_000_000

    public static func validatePureContractV1() throws {
        let authority =
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1
                .frozenV1
        try authority.validateExactV1()
        try require(
            receiptPrefix == authority.futureProbe.receiptPrefix,
            "receipt prefix")
        try require(
            receiptSchemaID == authority.receiptContract.schemaID,
            "receipt schema")
        try require(
            phaseNames == authority.futureProbe.resourceMeasurementBoundaries,
            "phase names")
        try require(
            classificationDomain == authority.receiptContract.classificationDomain,
            "classification domain")
        try require(
            operationCountKeys == authority.receiptContract.operationCountKeys,
            "operation count keys")
        try require(
            authority.configuration.batchTokenIDs == [probeTokenIDs],
            "token algorithm")
        try require(
            authority.configuration.batchCompletionMask
                == [[false] + Array(repeating: true, count: 127)],
            "completion mask")
        try require(
            authority.configuration.learningRateFloat32BitPattern
                == Float32(1e-4).bitPattern,
            "AdamW learning rate")
        try require(
            authority.configuration.maximumGradientNormFloat32BitPattern
                == Float32(1).bitPattern,
            "gradient norm maximum")
        try require(
            authority.configuration.gradientNormEpsilonFloat32BitPattern
                == Float32(1e-6).bitPattern,
            "gradient norm epsilon")
        try require(
            authority.futureProbe.checkedEvaluationBarrierCount == 5
                && authority.futureProbe.gpuSynchronizationBarrierCount == 5,
            "barrier counts")
        try require(
            authority.resourceEnvelope.minimumStatePlusGradientByteCount
                == 4_337_713_152
                && authority.resourceEnvelope.minimumAvailableFilesystemByteCount
                    == 12_884_901_888,
            "resource floors")
        try require(
            environmentVariableNames.count == 46
                && Set(environmentVariableNames).count == 46,
            "launcher environment vocabulary")
        try require(
            workerActiveTimeoutNanoseconds
                == UInt64(authority.futureProbe.workerActiveTimeoutSeconds)
                    * 1_000_000_000
                && supervisorTimeoutNanoseconds
                    == UInt64(
                        authority.futureProbe.supervisorEndToEndTimeoutSeconds)
                        * 1_000_000_000
                && terminationGraceNanoseconds
                    == UInt64(authority.futureProbe.terminationGraceSeconds)
                        * 1_000_000_000,
            "timeout caps")
        try require(
            authority.receiptContract.workerFrameMaximumByteCount
                == maximumFrameByteCount
                && authority.receiptContract.workerFrameSchemaVersion == 1,
            "worker framing")
        try require(
            isExplicitOutOfMemorySignature(
                "[metal::malloc] Resource limit (17179869184) exceeded.")
                && isExplicitOutOfMemorySignature(
                    "[malloc] Unable to allocate 4096 bytes.")
                && !isExplicitOutOfMemorySignature(
                    "memory policy validation failed")
                && !isExplicitOutOfMemorySignature(
                    "allocator catalog mismatch"),
            "pinned allocator OOM signatures")
        try require(
            candidateRequiresExecutorReceiptDrift(
                observedCandidateCount: 1,
                candidateAccepted: false)
                && !candidateRequiresExecutorReceiptDrift(
                    observedCandidateCount: 1,
                    candidateAccepted: true)
                && !candidateRequiresExecutorReceiptDrift(
                    observedCandidateCount: 0,
                    candidateAccepted: false),
            "candidate drift priority")
    }

    public static func runSupervisor() {
        let processEntryEpoch = stage6Now()
        if CommandLine.arguments.contains(workerArgument) {
            runWorkerProcess(epoch: processEntryEpoch)
        }
        do {
            let bindings = try LauncherBindings(
                environment: ProcessInfo.processInfo.environment)
            try runBoundedSupervisor(bindings: bindings)
        } catch {
            let message = "Stage-6 supervisor failed before a valid terminal receipt: \(error)\n"
            message.withCString { pointer in
                _ = fputs(pointer, stderr)
            }
            _exit(2)
        }
    }

    private static var probeTokenIDs: [Int] {
        [1] + (0 ..< 127).map { 2 + (($0 * 73 + 44) % 510) }
    }
}

private enum Stage6ProbeError: Error, CustomStringConvertible {
    case contract(String)
    case posix(String, Int32)

    var description: String {
        switch self {
        case .contract(let detail):
            return "contract drift: \(detail)"
        case .posix(let operation, let code):
            return "\(operation): \(String(cString: strerror(code)))"
        }
    }
}

private func require(_ condition: @autoclosure () -> Bool, _ detail: String)
    throws
{
    guard condition() else {
        throw Stage6ProbeError.contract(detail)
    }
}

private typealias Stage6Instant = ContinuousClock.Instant

private func stage6Now() -> Stage6Instant {
    ContinuousClock().now
}

private func checkedElapsedNanoseconds(
    from start: Stage6Instant,
    through end: Stage6Instant
) throws -> UInt64 {
    let components = start.duration(to: end).components
    guard components.seconds >= 0,
          components.attoseconds >= 0,
          let seconds = UInt64(exactly: components.seconds),
          let attoseconds = UInt64(exactly: components.attoseconds)
    else {
        throw Stage6ProbeError.contract(
            "ContinuousClock elapsed nonnegative representable components")
    }
    let whole = seconds.multipliedReportingOverflow(by: 1_000_000_000)
    let fractional = attoseconds / 1_000_000_000
    let total = whole.partialValue.addingReportingOverflow(fractional)
    try require(!whole.overflow && !total.overflow,
        "ContinuousClock elapsed nanosecond overflow")
    return total.partialValue
}

private func checkedElapsedNanoseconds(
    from start: Stage6Instant
) throws -> UInt64 {
    try checkedElapsedNanoseconds(from: start, through: stage6Now())
}

private struct LauncherBindings {
    let leasePath: String
    let exactMLXRevision: String
    let metallibPath: String
    let metallibBytes: UInt64
    let metallibSHA256: String
    let operatingSystemBuild: String
    let kernelIdentity: String
    let swiftToolchain: String
    let xcodeToolchain: String
    let macOSSDK: String
    let buildConfiguration: String
    let mlxGraphCompileMode: String

    let authorityID: String
    let authorityCanonicalSHA256: String
    let authoritySourceIdentity: [String: Any]
    let authorityTestIdentity: [String: Any]
    let authorityBaseRevision: String
    let authorityBaseTree: String

    let authorityClosureRevision: String
    let authorityClosureTree: String
    let authorityClosureRunID: UInt64
    let authorityClosureRunNumber: UInt64
    let authorityClosureRunAttempt: UInt64
    let authorityClosureCheckSuiteID: UInt64
    let authorityClosureActiveJobID: UInt64
    let authorityClosureActiveJobConclusion: String
    let authorityClosureReviewedJobID: UInt64
    let authorityClosureReviewedJobConclusion: String
    let authorityClosureEvent: String
    let authorityClosureRef: String
    let authorityClosureStatus: String
    let authorityClosureConclusion: String
    let authorityClosureArtifactCount: UInt64
    let authorityClosureRerunCount: UInt64

    let mechanicsRevision: String
    let mechanicsTree: String
    let mechanicsFirstParent: String
    let mechanicsSecondParent: String
    let mechanicsEvent: String
    let mechanicsRef: String
    let mechanicsRunID: UInt64
    let mechanicsRunNumber: UInt64
    let mechanicsRunAttempt: UInt64
    let exactChangedSourceIdentities: [[String: Any]]
    let provenanceSourceIdentities: [String: Any]
    let embeddedSourceIdentitySHA256: String

    init(environment: [String: String]) throws {
        func value(_ suffix: String) throws -> String {
            let key = "PRIME_NATIVE_DECODER_STAGE6_" + suffix
            guard let value = environment[key], !value.isEmpty else {
                throw Stage6ProbeError.contract("missing \(key)")
            }
            return value
        }
        func number(_ suffix: String) throws -> UInt64 {
            let string = try value(suffix)
            guard let result = UInt64(string) else {
                throw Stage6ProbeError.contract("non-UInt64 \(suffix)")
            }
            return result
        }
        func object(_ suffix: String) throws -> [String: Any] {
            let string = try value(suffix)
            guard let result = try canonicalJSONObject(string) as? [String: Any]
            else {
                throw Stage6ProbeError.contract("non-object \(suffix)")
            }
            return result
        }
        func array(_ suffix: String) throws -> [[String: Any]] {
            let string = try value(suffix)
            guard let result = try canonicalJSONObject(string) as? [[String: Any]]
            else {
                throw Stage6ProbeError.contract("non-array \(suffix)")
            }
            return result
        }

        leasePath = try value("METAL_LEASE_PATH")
        exactMLXRevision = try value("EXACT_MLX_REVISION")
        metallibPath = try value("METALLIB_PATH")
        metallibBytes = try number("METALLIB_BYTES")
        metallibSHA256 = try value("METALLIB_SHA256")
        operatingSystemBuild = try value("OPERATING_SYSTEM_BUILD")
        kernelIdentity = try value("KERNEL_IDENTITY")
        swiftToolchain = try value("SWIFT_TOOLCHAIN")
        xcodeToolchain = try value("XCODE_TOOLCHAIN")
        macOSSDK = try value("MACOS_SDK")
        buildConfiguration = try value("BUILD_CONFIGURATION")
        mlxGraphCompileMode = try value("MLX_GRAPH_COMPILE_MODE")

        authorityID = try value("AUTHORITY_ID")
        authorityCanonicalSHA256 = try value("AUTHORITY_CANONICAL_SHA256")
        authoritySourceIdentity = try object("AUTHORITY_SOURCE_IDENTITY_JSON")
        authorityTestIdentity = try object("AUTHORITY_TEST_IDENTITY_JSON")
        authorityBaseRevision = try value("AUTHORITY_BASE_REVISION")
        authorityBaseTree = try value("AUTHORITY_BASE_TREE")

        authorityClosureRevision = try value("AUTHORITY_CLOSURE_REVISION")
        authorityClosureTree = try value("AUTHORITY_CLOSURE_TREE")
        authorityClosureRunID = try number("AUTHORITY_CLOSURE_RUN_ID")
        authorityClosureRunNumber = try number("AUTHORITY_CLOSURE_RUN_NUMBER")
        authorityClosureRunAttempt = try number("AUTHORITY_CLOSURE_RUN_ATTEMPT")
        authorityClosureCheckSuiteID = try number("AUTHORITY_CLOSURE_CHECK_SUITE_ID")
        authorityClosureActiveJobID = try number("AUTHORITY_CLOSURE_ACTIVE_JOB_ID")
        authorityClosureActiveJobConclusion =
            try value("AUTHORITY_CLOSURE_ACTIVE_JOB_CONCLUSION")
        authorityClosureReviewedJobID =
            try number("AUTHORITY_CLOSURE_REVIEWED_JOB_ID")
        authorityClosureReviewedJobConclusion =
            try value("AUTHORITY_CLOSURE_REVIEWED_JOB_CONCLUSION")
        authorityClosureEvent = try value("AUTHORITY_CLOSURE_EVENT")
        authorityClosureRef = try value("AUTHORITY_CLOSURE_REF")
        authorityClosureStatus = try value("AUTHORITY_CLOSURE_STATUS")
        authorityClosureConclusion = try value("AUTHORITY_CLOSURE_CONCLUSION")
        authorityClosureArtifactCount =
            try number("AUTHORITY_CLOSURE_ARTIFACT_COUNT")
        authorityClosureRerunCount =
            try number("AUTHORITY_CLOSURE_RERUN_COUNT")

        mechanicsRevision = try value("MECHANICS_EXECUTED_REVISION")
        mechanicsTree = try value("MECHANICS_EXECUTED_TREE")
        mechanicsFirstParent = try value("MECHANICS_FIRST_PARENT")
        mechanicsSecondParent = try value("MECHANICS_SECOND_PARENT")
        mechanicsEvent = try value("MECHANICS_EVENT")
        mechanicsRef = try value("MECHANICS_REF")
        mechanicsRunID = try number("MECHANICS_RUN_ID")
        mechanicsRunNumber = try number("MECHANICS_RUN_NUMBER")
        mechanicsRunAttempt = try number("MECHANICS_RUN_ATTEMPT")
        exactChangedSourceIdentities =
            try array("EXACT_CHANGED_SOURCE_IDENTITIES_JSON")
        provenanceSourceIdentities =
            try object("PROVENANCE_SOURCE_IDENTITIES_JSON")
        embeddedSourceIdentitySHA256 =
            try value("EMBEDDED_SOURCE_IDENTITY_SHA256")

        try validate(environment: environment)
    }

    private func validate(environment: [String: String]) throws {
        let authority =
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1
                .frozenV1
        try authority.validateExactV1()
        try require(
            environment["MLX_ENABLE_TF32"] == "0",
            "MLX_ENABLE_TF32")
        try require(
            authorityID == authority.authorityID
                && authorityCanonicalSHA256
                    == PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1
                        .canonicalSHA256,
            "authority identity")
        try require(
            authorityBaseRevision == authority.repository.authorityBaseRevision
                && authorityBaseTree == authority.repository.authorityBaseTree,
            "authority base")
        try require(
            exactMLXRevision == authority.environment.exactMLXRevision,
            "MLX revision")
        try require(buildConfiguration == "release", "Release build")
        try require(
            PrimeEmbeddedBuildProvenance.buildConfiguration == "release",
            "embedded Release build")
        try require(
            PrimeEmbeddedBuildProvenance.sourceIdentitySHA256
                == embeddedSourceIdentitySHA256,
            "embedded source identity binding")
        try require(
            mlxGraphCompileMode == "eager_uncompiled_no_compile_transform",
            "MLX compile mode")
        try require(
            authorityClosureRevision
                == "7dd21f2b8c79ebe53f62eab1945ac41b104c2b27"
                && authorityClosureTree
                    == "5124b8a75ca753d1e7659a2535242aa909329c44"
                && authorityClosureRunID == 31_773_463_958
                && authorityClosureRunNumber == 109
                && authorityClosureRunAttempt == 1
                && authorityClosureCheckSuiteID == 86_198_647_430
                && authorityClosureActiveJobID == 94_683_934_560
                && authorityClosureReviewedJobID == 94_684_324_255,
            "green authority closure")
        try require(
            authorityClosureActiveJobConclusion == "success"
                && authorityClosureReviewedJobConclusion == "success"
                && authorityClosureEvent == "push"
                && authorityClosureRef == "refs/heads/main"
                && authorityClosureStatus == "completed"
                && authorityClosureConclusion == "success"
                && authorityClosureArtifactCount == 0
                && authorityClosureRerunCount == 0,
            "green authority closure policy")
        try require(
            mechanicsFirstParent == authorityClosureRevision
                && mechanicsEvent == "push"
                && mechanicsRef == "refs/heads/main"
                && mechanicsRunAttempt == 1,
            "mechanics run lineage")
        try require(
            isLowercaseHex(mechanicsRevision, count: 40)
                && isLowercaseHex(mechanicsTree, count: 40)
                && isLowercaseHex(mechanicsSecondParent, count: 40),
            "mechanics identities")
        try require(
            exactChangedSourceIdentities.count == 8,
            "exact-eight source identities")
        try validateIdentities(exactChangedSourceIdentities)
        let exactPaths = exactChangedSourceIdentities.compactMap { $0["path"] as? String }
        try require(
            exactPaths == authority.successorScope.exactChangedPaths,
            "exact-eight paths")
        try validateIdentity(
            authoritySourceIdentity,
            expectedPath:
                "Sources/PrimeCore/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthority.swift")
        try validateIdentity(
            authorityTestIdentity,
            expectedPath:
                "Tests/PrimeCoreTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityTests.swift")
        try require(
            Set(provenanceSourceIdentities.keys)
                == ["embedded_source_identity_sha256", "identities"],
            "provenance object keys")
        try require(
            provenanceSourceIdentities["embedded_source_identity_sha256"] as? String
                == embeddedSourceIdentitySHA256,
            "embedded provenance digest")
        guard let provenanceIdentities =
                provenanceSourceIdentities["identities"] as? [[String: Any]]
        else {
            throw Stage6ProbeError.contract("provenance identities")
        }
        try require(provenanceIdentities.count == 7, "seven provenance identities")
        try validateIdentities(provenanceIdentities)
        try require(
            isLowercaseHex(embeddedSourceIdentitySHA256, count: 64)
                && isLowercaseHex(metallibSHA256, count: 64)
                && metallibBytes > 0
                && metallibPath.hasPrefix("/")
                && leasePath.hasPrefix("/")
                && !kernelIdentity.isEmpty,
            "runtime identity values")
    }
}

private let sourceIdentityKeySet: Set<String> = [
    "byte_count", "git_blob", "mode", "path", "sha256",
]

private func validateIdentities(_ values: [[String: Any]]) throws {
    var paths = [String]()
    for value in values {
        try validateIdentity(value, expectedPath: nil)
        paths.append(value["path"] as! String)
    }
    try require(paths == paths.sorted(), "identity UTF-8 path order")
    try require(Set(paths).count == paths.count, "duplicate identity path")
}

private func validateIdentity(
    _ value: [String: Any],
    expectedPath: String?
) throws {
    try require(Set(value.keys) == sourceIdentityKeySet, "source identity keys")
    guard let path = value["path"] as? String,
          let mode = value["mode"] as? String,
          let blob = value["git_blob"] as? String,
          let sha256 = value["sha256"] as? String,
          let bytesValue = value["byte_count"],
          let bytes = exactJSONUInt64(bytesValue)
    else {
        throw Stage6ProbeError.contract("source identity types")
    }
    try require(!path.isEmpty && !path.hasPrefix("/"), "source path")
    if let expectedPath {
        try require(path == expectedPath, "source identity path")
    }
    try require(mode == "100644" || mode == "100755", "source mode")
    try require(isLowercaseHex(blob, count: 40), "source git blob")
    try require(isLowercaseHex(sha256, count: 64), "source SHA-256")
    try require(bytes > 0, "source byte count")
}

private func exactJSONUInt64(_ value: Any) -> UInt64? {
    guard let number = value as? NSNumber else { return nil }
    let type = String(cString: number.objCType)
    guard ["q", "Q", "i", "I", "s", "S", "l", "L"].contains(type)
    else { return nil }
    return UInt64(number.stringValue)
}

private func exactJSONInt64(_ value: Any) -> Int64? {
    guard let number = value as? NSNumber else { return nil }
    let type = String(cString: number.objCType)
    guard ["q", "i", "s", "l"].contains(type) else { return nil }
    return Int64(number.stringValue)
}

private func exactJSONBool(_ value: Any) -> Bool? {
    guard let number = value as? NSNumber,
          CFGetTypeID(number) == CFBooleanGetTypeID()
    else { return nil }
    return number.boolValue
}

private func isLowercaseHex(_ value: String, count: Int) -> Bool {
    value.utf8.count == count
        && value.utf8.allSatisfy {
            ($0 >= Character("0").asciiValue! && $0 <= Character("9").asciiValue!)
                || ($0 >= Character("a").asciiValue!
                    && $0 <= Character("f").asciiValue!)
        }
}

private func canonicalJSONObject(_ string: String) throws -> Any {
    guard let data = string.data(using: .utf8) else {
        throw Stage6ProbeError.contract("non-UTF8 JSON")
    }
    let object = try JSONSerialization.jsonObject(with: data)
    let rebound = try canonicalJSONData(object)
    try require(rebound == data, "noncanonical JSON binding")
    return object
}

private func canonicalJSONData(_ object: Any) throws -> Data {
    guard JSONSerialization.isValidJSONObject(object) else {
        throw Stage6ProbeError.contract("invalid JSON object")
    }
    return try JSONSerialization.data(
        withJSONObject: object,
        options: [.sortedKeys, .withoutEscapingSlashes])
}

private func canonicalJSONLine(_ object: Any) throws -> Data {
    var data = try canonicalJSONData(object)
    data.append(0x0a)
    return data
}

private struct OperationCounts {
    var values: [String: Int]

    init() {
        values = Dictionary(
            uniqueKeysWithValues:
                PrimeNativeDecoderNative300MResourceOnlyOneStepProbe
                    .operationCountKeys.map { ($0, 0) })
    }

    mutating func increment(_ key: String) throws {
        guard let old = values[key] else {
            throw Stage6ProbeError.contract("unknown operation count \(key)")
        }
        values[key] = old + 1
    }

    subscript(_ key: String) -> Int {
        values[key] ?? 0
    }
}

private struct WorkerPayload {
    var environment: [String: Any]
    var lease: [String: Any]
    var limits: [String: Any]
    var outcome: [String: Any]
    var phaseMetrics: [[String: Any]]
    var operationCounts: OperationCounts

    init(bindings: LauncherBindings) {
        environment = staticEnvironment(bindings: bindings)
        lease = [
            "acquired_before_coregraphics_metal_or_mlx": false,
            "acquired_nonblocking": true,
            "held_through_candidate_flush": false,
            "held_through_postflight": false,
            "lease_path": bindings.leasePath,
            "supervisor_reacquire_release_proved": false,
            "type": "PrimeMetalDeviceLease",
            "worker_owned": false,
        ]
        limits = staticLimits()
        operationCounts = OperationCounts()
        outcome = [:]
        phaseMetrics = []
        setOutcome(
            status: "ABSTAIN",
            classification: "executor_receipt_drift",
            candidatePresent: false)
    }

    mutating func setOutcome(
        status: String,
        classification: String,
        candidatePresent: Bool
    ) {
        let modelAttempted = operationCounts["model_allocation_count"] == 1
        let unified = environment["metal_device_has_unified_memory"] as? Bool
        let capacityObserved = phaseMetrics.contains { phase in
            !(phase["physical_memory_capacity_bytes"] is NSNull)
        }
        let runnerCapacity = unified == true && capacityObserved
        let pass = status == "PASS" && classification == "pass"
        outcome = [
            "classification": classification,
            "gradient_clip_scale_float32_bits":
                outcome["gradient_clip_scale_float32_bits"] ?? NSNull(),
            "loss_float32_bits": outcome["loss_float32_bits"] ?? NSNull(),
            "one_shot_consumed": true,
            "operation_counts": operationCounts.values,
            "parameter_fingerprint_after":
                outcome["parameter_fingerprint_after"] ?? NSNull(),
            "parameter_fingerprint_before":
                outcome["parameter_fingerprint_before"] ?? NSNull(),
            "parameter_fingerprint_sample_count":
                outcome["parameter_fingerprint_sample_count"] ?? NSNull(),
            "parameter_fingerprint_sample_plan_sha256":
                outcome["parameter_fingerprint_sample_plan_sha256"]
                    ?? NSNull(),
            "postflight_device_identity_matches_preflight":
                outcome["postflight_device_identity_matches_preflight"]
                    ?? NSNull(),
            "postflight_mlx_policy_and_limits_match_preflight":
                outcome["postflight_mlx_policy_and_limits_match_preflight"]
                    ?? NSNull(),
            "raw_gradient_norm_float32_bits":
                outcome["raw_gradient_norm_float32_bits"] ?? NSNull(),
            "resource_clearance_established": pass,
            "resource_envelope_established": pass,
            "resource_probe_executed": modelAttempted,
            "runner_memory_capacity_established": runnerCapacity,
            "status": status,
            "update_occurred": outcome["update_occurred"] ?? NSNull(),
            "worker_candidate_present": candidatePresent,
        ]
    }

    mutating func finishPhases(
        classification: String,
        fatal: Bool
    ) {
        let observed = phaseMetrics.count
        if observed < PrimeNativeDecoderNative300MResourceOnlyOneStepProbe
            .phaseNames.count
        {
            let availability: String
            if observed == 0
                && (classification == "worker_spawn_failure"
                    || classification == "lease_busy")
            {
                availability = "unavailable_before_probe_start"
            } else if fatal {
                availability = "unavailable_after_fatal"
            } else {
                availability = "unavailable_after_classification"
            }
            for phase in PrimeNativeDecoderNative300MResourceOnlyOneStepProbe
                .phaseNames.dropFirst(observed)
            {
                phaseMetrics.append(unavailablePhase(
                    phase: phase,
                    availability: availability,
                    reason: classification))
            }
        }
    }

    func framePayload() -> [String: Any] {
        [
            "environment": environment,
            "lease": lease,
            "limits": limits,
            "outcome": outcome,
            "phase_metrics": phaseMetrics,
        ]
    }
}

private func staticEnvironment(bindings: LauncherBindings) -> [String: Any] {
    [
        "metal_device_count": NSNull(),
        "metal_device_index": NSNull(),
        "metal_device_is_default": NSNull(),
        "metal_device_max_buffer_length_bytes": NSNull(),
        "metal_device_max_recommended_working_set_bytes": NSNull(),
        "metal_device_has_unified_memory": NSNull(),
        "metal_device_name": NSNull(),
        "metal_device_registry_id": NSNull(),
        "mlx_compile_transform_invocation_count": 0,
        "mlx_cpu_fallback_used": NSNull(),
        "mlx_default_device_is_supplied_device": NSNull(),
        "mlx_default_stream_is_gpu": NSNull(),
        "mlx_device_constructor_index": NSNull(),
        "mlx_device_type": NSNull(),
        "mlx_enable_tf32": "0",
        "mlx_revision": bindings.exactMLXRevision,
        "operating_system_build": bindings.operatingSystemBuild,
        "filesystem_observation_fsid": NSNull(),
        "filesystem_observation_path": NSNull(),
        "runtime_metallib_byte_count": bindings.metallibBytes,
        "runtime_metallib_path": bindings.metallibPath,
        "runtime_metallib_sha256": bindings.metallibSHA256,
        "swift_sdk": bindings.macOSSDK,
        "swift_version": bindings.swiftToolchain,
        "swiftpm_build_configuration": bindings.buildConfiguration,
        "xcode_version": bindings.xcodeToolchain,
    ]
}

private func staticLimits() -> [String: Any] {
    [
        "available_filesystem_floor_bytes": UInt64(12_884_901_888),
        "configured_cache_limit_bytes": UInt64(0),
        "configured_cache_limit_readback_bytes": NSNull(),
        "configured_memory_limit_bytes": NSNull(),
        "configured_memory_limit_formula":
            "min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)",
        "configured_memory_limit_readback_bytes": NSNull(),
        "container_headers_and_manifests_included_in_minimum": false,
        "duplicate_materializations_graphs_and_temporary_buffers_included_in_minimum":
            false,
        "gradient_logical_bytes": UInt64(1_084_428_288),
        "minimum_committed_tensor_state_bytes": UInt64(3_253_284_864),
        "minimum_memory_limit_floor_bytes": UInt64(4_337_713_152),
        "minimum_state_plus_gradient_bytes": UInt64(4_337_713_152),
        "mlx_limit_is_not_rss_limit": true,
        "optimizer_moment_logical_bytes": UInt64(2_168_856_576),
        "optimizer_moment_tensor_count": 436,
        "statfs_is_observational_only": true,
        "supervisor_end_to_end_timeout_seconds": 1_500,
        "termination_grace_seconds": 10,
        "three_times_committed_state_disk_comparator_bytes":
            UInt64(9_759_854_592),
        "validated_first_moment_tensor_count": NSNull(),
        "validated_gradient_logical_bytes": NSNull(),
        "validated_gradient_path_count": NSNull(),
        "validated_optimizer_moment_logical_bytes": NSNull(),
        "validated_parameter_path_count": NSNull(),
        "validated_second_moment_tensor_count": NSNull(),
        "validated_unique_parameter_count": NSNull(),
        "validated_weights_logical_bytes": NSNull(),
        "weights_logical_bytes": UInt64(1_084_428_288),
        "worker_active_timeout_seconds": 1_200,
    ]
}

private func unavailablePhase(
    phase: String,
    availability: String,
    reason: String
) -> [String: Any] {
    [
        "phase": phase,
        "availability": availability,
        "unavailable_reason": reason,
        "cumulative_worker_probe_elapsed_nanoseconds": NSNull(),
        "physical_memory_capacity_bytes": NSNull(),
        "task_resident_bytes": NSNull(),
        "task_physical_footprint_bytes": NSNull(),
        "getrusage_max_rss_bytes": NSNull(),
        "mlx_active_bytes": NSNull(),
        "mlx_cache_bytes": NSNull(),
        "mlx_peak_bytes": NSNull(),
        "metal_current_allocated_bytes": NSNull(),
        "filesystem_capacity_bytes": NSNull(),
        "filesystem_available_bytes": NSNull(),
    ]
}

private final class WorkerFrameWriter {
    let descriptor: Int32
    private var nextSequence: UInt64 = 0

    init(descriptor: Int32) {
        self.descriptor = descriptor
    }

    func write(kind: String, payload: [String: Any]) throws {
        let frame: [String: Any] = [
            "frame_schema_version": 1,
            "kind": kind,
            "payload": payload,
            "sequence": nextSequence,
        ]
        let bytes = try canonicalJSONLine(frame)
        try require(
            bytes.count
                <= PrimeNativeDecoderNative300MResourceOnlyOneStepProbe
                    .maximumFrameByteCount,
            "worker frame size")
        try rawWriteAll(bytes, to: descriptor)
        nextSequence += 1
    }
}

private func rawWriteAll(_ data: Data, to descriptor: Int32) throws {
    try data.withUnsafeBytes { rawBuffer in
        guard let base = rawBuffer.baseAddress else {
            return
        }
        var offset = 0
        while offset < rawBuffer.count {
            let result = Darwin.write(
                descriptor,
                base.advanced(by: offset),
                rawBuffer.count - offset)
            if result > 0 {
                offset += result
            } else if result < 0 && errno == EINTR {
                continue
            } else {
                throw Stage6ProbeError.posix("worker frame write", errno)
            }
        }
    }
}

private final class FrameAccumulator: @unchecked Sendable {
    private let lock = NSLock()
    private var buffer = Data()
    private(set) var progressFrameCount = 0
    private(set) var candidateFrameCount = 0
    private(set) var lastCompleteSequence: UInt64?
    private(set) var lastProgressPayload: [String: Any]?
    private(set) var candidatePayload: [String: Any]?
    private(set) var transportDrift = false
    private(set) var trailingPartial = false
    private var drainFinished = false
    private var expectedSequence: UInt64 = 0
    private var terminalCandidateSeen = false
    private var discardingOversizedFrame = false

    func drain(descriptor: Int32) {
        defer {
            lock.lock()
            drainFinished = true
            lock.unlock()
        }
        var readBuffer = [UInt8](repeating: 0, count: 32_768)
        while true {
            let count = Darwin.read(descriptor, &readBuffer, readBuffer.count)
            if count > 0 {
                consume(Data(readBuffer[0 ..< count]))
            } else if count == 0 {
                finishEOF()
                return
            } else if errno == EINTR {
                continue
            } else {
                lock.lock()
                transportDrift = true
                lock.unlock()
                return
            }
        }
    }

    func isDrainFinished() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return drainFinished
    }

    func snapshot() -> FrameSnapshot {
        lock.lock()
        defer { lock.unlock() }
        return FrameSnapshot(
            progressFrameCount: progressFrameCount,
            candidateFrameCount: candidateFrameCount,
            lastCompleteSequence: lastCompleteSequence,
            lastProgressPayload: lastProgressPayload,
            candidatePayload: candidatePayload,
            transportDrift: transportDrift,
            trailingPartial: trailingPartial)
    }

    private func consume(_ data: Data) {
        lock.lock()
        defer { lock.unlock() }
        let maximumJSONBytes =
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbe
                .maximumFrameByteCount - 1
        for byte in data {
            if discardingOversizedFrame {
                if byte == 0x0a {
                    discardingOversizedFrame = false
                }
                continue
            }
            if byte == 0x0a {
                accept(buffer)
                buffer.removeAll(keepingCapacity: true)
            } else if buffer.count < maximumJSONBytes {
                buffer.append(byte)
            } else {
                transportDrift = true
                buffer.removeAll(keepingCapacity: true)
                discardingOversizedFrame = true
            }
        }
    }

    private func accept(_ line: Data) {
        do {
            let object = try JSONSerialization.jsonObject(with: line)
            let canonical = try canonicalJSONData(object)
            try require(canonical == line, "frame canonical JSON")
            guard let frame = object as? [String: Any],
                  Set(frame.keys)
                    == ["frame_schema_version", "kind", "payload", "sequence"],
                  exactJSONUInt64(frame["frame_schema_version"] as Any) == 1,
                  let kind = frame["kind"] as? String,
                  let payload = frame["payload"] as? [String: Any],
                  let sequence = exactJSONUInt64(frame["sequence"] as Any)
            else {
                throw Stage6ProbeError.contract("worker frame shape")
            }
            switch kind {
            case "progress":
                progressFrameCount += 1
            case "candidate":
                candidateFrameCount += 1
            default:
                throw Stage6ProbeError.contract("frame kind")
            }
            try require(sequence == expectedSequence, "frame sequence")
            try require(!terminalCandidateSeen, "post-candidate frame")
            expectedSequence += 1
            lastCompleteSequence = sequence
            if kind == "progress" {
                lastProgressPayload = payload
            } else {
                terminalCandidateSeen = true
                candidatePayload = payload
            }
        } catch {
            transportDrift = true
        }
    }

    private func finishEOF() {
        lock.lock()
        defer { lock.unlock() }
        if !buffer.isEmpty || discardingOversizedFrame {
            trailingPartial = true
            buffer.removeAll(keepingCapacity: false)
            discardingOversizedFrame = false
        }
    }
}

private struct FrameSnapshot {
    let progressFrameCount: Int
    let candidateFrameCount: Int
    let lastCompleteSequence: UInt64?
    let lastProgressPayload: [String: Any]?
    let candidatePayload: [String: Any]?
    let transportDrift: Bool
    let trailingPartial: Bool
}

private struct SpawnResult {
    let processIdentifier: pid_t?
    let errorCode: Int32?
    let workerStart: Stage6Instant?

    init(
        processIdentifier: pid_t?,
        errorCode: Int32?,
        workerStart: Stage6Instant? = nil
    ) {
        self.processIdentifier = processIdentifier
        self.errorCode = errorCode
        self.workerStart = workerStart
    }
}

private struct WaitObservation {
    let exitCode: Int?
    let signal: Int?
    let workerElapsedNanoseconds: UInt64?
    let workerTimeoutTriggered: Bool
    let workerTimeoutTriggerNanoseconds: UInt64?
    let supervisorTimeoutTriggered: Bool
    let supervisorTimeoutTriggerNanoseconds: UInt64?

    func addingSupervisorTimeout(trigger: UInt64) -> Self {
        Self(
            exitCode: exitCode,
            signal: signal,
            workerElapsedNanoseconds: workerElapsedNanoseconds,
            workerTimeoutTriggered: workerTimeoutTriggered,
            workerTimeoutTriggerNanoseconds: workerTimeoutTriggerNanoseconds,
            supervisorTimeoutTriggered: true,
            supervisorTimeoutTriggerNanoseconds:
                supervisorTimeoutTriggerNanoseconds ?? trigger)
    }
}

private struct TerminalDecision {
    let classification: String
    let candidateAccepted: Bool
    let payload: [String: Any]
}

private struct TerminalDecisionEvidence {
    let candidateCanPass: Bool
    let baseClassification: String
    let candidatePayload: [String: Any]?
    let lastProgressPayload: [String: Any]?
}

extension PrimeNativeDecoderNative300MResourceOnlyOneStepProbe {
    fileprivate static func runBoundedSupervisor(bindings: LauncherBindings) throws {
        try validatePureContractV1()
        var descriptors = [Int32](repeating: -1, count: 2)
        guard Darwin.pipe(&descriptors) == 0 else {
            throw Stage6ProbeError.posix("pipe", errno)
        }
        var readDescriptor = descriptors[0]
        var writeDescriptor = descriptors[1]
        defer {
            if readDescriptor >= 0 { _ = Darwin.close(readDescriptor) }
            if writeDescriptor >= 0 { _ = Darwin.close(writeDescriptor) }
        }
        try setCloseOnExec(readDescriptor)
        try setCloseOnExec(writeDescriptor)

        let supervisorStart = stage6Now()
        let spawn = spawnWorker(
            executable: resolvedExecutablePath(),
            readDescriptor: readDescriptor,
            writeDescriptor: writeDescriptor)
        let accumulator = FrameAccumulator()
        var waitObservation: WaitObservation

        if let child = spawn.processIdentifier {
            _ = Darwin.close(writeDescriptor)
            writeDescriptor = -1
            let drainDescriptor = readDescriptor
            DispatchQueue.global(qos: .userInitiated).async {
                accumulator.drain(descriptor: drainDescriptor)
            }
            guard let workerStart = spawn.workerStart else {
                throw Stage6ProbeError.contract("successful spawn worker epoch")
            }
            waitObservation = try supervise(
                child: child,
                workerStart: workerStart,
                supervisorStart: supervisorStart)
            while !accumulator.isDrainFinished() {
                if try checkedElapsedNanoseconds(from: supervisorStart)
                    >= supervisorTimeoutNanoseconds
                {
                    break
                }
                usleep(10_000)
            }
            if !accumulator.isDrainFinished() {
                let trigger = try checkedElapsedNanoseconds(
                    from: supervisorStart)
                waitObservation = waitObservation.addingSupervisorTimeout(
                    trigger: trigger)
                _ = Darwin.kill(-child, SIGKILL)
                let containmentStart = stage6Now()
                while !accumulator.isDrainFinished() {
                    if try checkedElapsedNanoseconds(from: containmentStart)
                        >= 1_000_000_000
                    {
                        break
                    }
                    usleep(10_000)
                }
                guard accumulator.isDrainFinished() else {
                    throw Stage6ProbeError.contract(
                        "bounded worker pipe drain")
                }
            }
        } else {
            _ = Darwin.close(writeDescriptor)
            writeDescriptor = -1
            waitObservation = WaitObservation(
                exitCode: nil,
                signal: nil,
                workerElapsedNanoseconds: nil,
                workerTimeoutTriggered: false,
                workerTimeoutTriggerNanoseconds: nil,
                supervisorTimeoutTriggered: false,
                supervisorTimeoutTriggerNanoseconds: nil)
        }

        let frames = accumulator.snapshot()
        let leaseBusy = isValidatedLeaseBusyTerminal(
            frames: frames,
            spawn: spawn,
            wait: waitObservation,
            bindings: bindings)
        let reacquireProved: Bool
        if spawn.processIdentifier != nil
            && !leaseBusy
        {
            do {
                let lease = try PrimeMetalDeviceLease.acquire(at:
                    URL(fileURLWithPath: bindings.leasePath))
                reacquireProved = lease.isHeld
                lease.release()
            } catch {
                reacquireProved = false
            }
        } else {
            reacquireProved = false
        }
        if readDescriptor >= 0 {
            _ = Darwin.close(readDescriptor)
            readDescriptor = -1
        }

        let beforeDecisionElapsed = try checkedElapsedNanoseconds(
            from: supervisorStart)
        if beforeDecisionElapsed >= supervisorTimeoutNanoseconds
            && !waitObservation.supervisorTimeoutTriggered
        {
            waitObservation = waitObservation.addingSupervisorTimeout(
                trigger: beforeDecisionElapsed)
        }
        let decisionEvidence = analyzeTerminalDecisionEvidence(
            bindings: bindings,
            spawn: spawn,
            wait: waitObservation,
            frames: frames)
        var decision: TerminalDecision
        var supervisorElapsed: UInt64
        while true {
            decision = try makeTerminalDecision(
                evidence: decisionEvidence,
                bindings: bindings,
                spawn: spawn,
                wait: waitObservation,
                frames: frames,
                supervisorReacquireProved: reacquireProved)
            let supervisorEnd = stage6Now()
            supervisorElapsed = try checkedElapsedNanoseconds(
                from: supervisorStart,
                through: supervisorEnd)
            if supervisorElapsed >= supervisorTimeoutNanoseconds
                && !waitObservation.supervisorTimeoutTriggered
            {
                waitObservation = waitObservation.addingSupervisorTimeout(
                    trigger: supervisorElapsed)
                continue
            }
            break
        }
        let final = try makeFinalReceipt(
            bindings: bindings,
            spawn: spawn,
            wait: waitObservation,
            frames: frames,
            supervisorElapsedNanoseconds: supervisorElapsed,
            decision: decision)
        let encoded = try canonicalJSONData(final)
        let decoded = try JSONSerialization.jsonObject(with: encoded)
        let roundTrip = try canonicalJSONData(decoded)
        try require(roundTrip == encoded, "receipt round trip")
        try validateFinalReceipt(
            decoded,
            bindings: bindings,
            spawn: spawn,
            wait: waitObservation,
            frames: frames,
            supervisorElapsedNanoseconds: supervisorElapsed,
            decision: decision)
        guard let json = String(data: encoded, encoding: .utf8) else {
            throw Stage6ProbeError.contract("receipt UTF-8")
        }
        let line = receiptPrefix + json + "\n"
        let writeResult = line.withCString { fputs($0, stdout) }
        let flushResult = fflush(stdout)
        let streamError = ferror(stdout)
        guard writeResult != EOF, flushResult == 0, streamError == 0 else {
            _exit(3)
        }
        _exit(0)
    }

    private static func spawnWorker(
        executable: String,
        readDescriptor: Int32,
        writeDescriptor: Int32
    ) -> SpawnResult {
        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        var actionsInitialized = false
        var attributesInitialized = false
        defer {
            if actionsInitialized { _ = posix_spawn_file_actions_destroy(&actions) }
            if attributesInitialized { _ = posix_spawnattr_destroy(&attributes) }
        }
        var code = posix_spawn_file_actions_init(&actions)
        guard code == 0 else { return SpawnResult(processIdentifier: nil, errorCode: code) }
        actionsInitialized = true
        code = posix_spawnattr_init(&attributes)
        guard code == 0 else { return SpawnResult(processIdentifier: nil, errorCode: code) }
        attributesInitialized = true

        let actionCodes = [
            posix_spawn_file_actions_addopen(
                &actions, STDIN_FILENO, "/dev/null", O_RDONLY, 0),
            posix_spawn_file_actions_addopen(
                &actions, STDOUT_FILENO, "/dev/null", O_WRONLY, 0),
            posix_spawn_file_actions_addopen(
                &actions, STDERR_FILENO, "/dev/null", O_WRONLY, 0),
            posix_spawn_file_actions_addclose(&actions, readDescriptor),
            posix_spawn_file_actions_adddup2(
                &actions, writeDescriptor, workerFrameDescriptor),
            posix_spawn_file_actions_addclose(&actions, writeDescriptor),
        ]
        if let failure = actionCodes.first(where: { $0 != 0 }) {
            return SpawnResult(processIdentifier: nil, errorCode: failure)
        }
        code = posix_spawnattr_setpgroup(&attributes, 0)
        guard code == 0 else { return SpawnResult(processIdentifier: nil, errorCode: code) }
        let flags = UInt16(POSIX_SPAWN_SETPGROUP) | UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
        code = posix_spawnattr_setflags(&attributes, Int16(bitPattern: flags))
        guard code == 0 else { return SpawnResult(processIdentifier: nil, errorCode: code) }

        let arguments = [
            executable, workerArgument,
            "--frame-descriptor=\(workerFrameDescriptor)",
        ]
        let environment = ProcessInfo.processInfo.environment
            .map { "\($0.key)=\($0.value)" }
            .sorted()
        let optionalArgumentPointers = arguments.map { strdup($0) }
        let optionalEnvironmentPointers = environment.map { strdup($0) }
        guard optionalArgumentPointers.allSatisfy({ $0 != nil }),
              optionalEnvironmentPointers.allSatisfy({ $0 != nil })
        else {
            optionalArgumentPointers.forEach { free($0) }
            optionalEnvironmentPointers.forEach { free($0) }
            return SpawnResult(processIdentifier: nil, errorCode: ENOMEM)
        }
        let argumentPointers = optionalArgumentPointers.map { $0! }
        let environmentPointers = optionalEnvironmentPointers.map { $0! }
        defer {
            argumentPointers.forEach { free($0) }
            environmentPointers.forEach { free($0) }
        }
        var argv = argumentPointers.map(Optional.init)
        var envp = environmentPointers.map(Optional.init)
        argv.append(nil)
        envp.append(nil)
        var child: pid_t = 0
        var workerStart: Stage6Instant?
        code = argv.withUnsafeMutableBufferPointer { argvBuffer in
            envp.withUnsafeMutableBufferPointer { envBuffer in
                workerStart = stage6Now()
                return posix_spawn(
                    &child,
                    executable,
                    &actions,
                    &attributes,
                    argvBuffer.baseAddress,
                    envBuffer.baseAddress)
            }
        }
        guard code == 0, child > 0 else {
            return SpawnResult(processIdentifier: nil, errorCode: code == 0 ? ECHILD : code)
        }
        return SpawnResult(
            processIdentifier: child,
            errorCode: nil,
            workerStart: workerStart)
    }

    private static func supervise(
        child: pid_t,
        workerStart: Stage6Instant,
        supervisorStart: Stage6Instant
    ) throws -> WaitObservation {
        var status: Int32 = 0
        var workerTimeout = false
        var workerTrigger: UInt64?
        var supervisorTimeout = false
        var supervisorTrigger: UInt64?
        var terminationStarted: Stage6Instant?
        while true {
            let result = waitpid(child, &status, WNOHANG)
            let now = stage6Now()
            let workerElapsed = try checkedElapsedNanoseconds(
                from: workerStart,
                through: now)
            let supervisorElapsed = try checkedElapsedNanoseconds(
                from: supervisorStart,
                through: now)
            if !workerTimeout
                && workerElapsed >= workerActiveTimeoutNanoseconds
            {
                workerTimeout = true
                workerTrigger = workerElapsed
                if result != child {
                    terminationStarted = now
                    _ = Darwin.kill(-child, SIGTERM)
                }
            }
            if !supervisorTimeout
                && supervisorElapsed >= supervisorTimeoutNanoseconds
            {
                supervisorTimeout = true
                supervisorTrigger = supervisorElapsed
                if result != child {
                    if terminationStarted == nil { terminationStarted = now }
                    _ = Darwin.kill(-child, SIGTERM)
                }
            }
            if result == child {
                let low = Int(status & 0x7f)
                let exitCode = low == 0 ? Int((status >> 8) & 0xff) : nil
                let signal = low != 0 && low != 0x7f ? low : nil
                return WaitObservation(
                    exitCode: exitCode,
                    signal: signal,
                    workerElapsedNanoseconds: workerElapsed,
                    workerTimeoutTriggered: workerTimeout,
                    workerTimeoutTriggerNanoseconds: workerTrigger,
                    supervisorTimeoutTriggered: supervisorTimeout,
                    supervisorTimeoutTriggerNanoseconds: supervisorTrigger)
            }
            if result < 0 && errno != EINTR {
                _ = Darwin.kill(-child, SIGKILL)
                let reapedStatus = try reapAfterContainment(
                    child: child,
                    status: &status)
                let reapedAt = stage6Now()
                let reapedWorkerElapsed = try checkedElapsedNanoseconds(
                    from: workerStart,
                    through: reapedAt)
                let reapedSupervisorElapsed = try checkedElapsedNanoseconds(
                    from: supervisorStart,
                    through: reapedAt)
                if !workerTimeout
                    && reapedWorkerElapsed >= workerActiveTimeoutNanoseconds
                {
                    workerTimeout = true
                    workerTrigger = reapedWorkerElapsed
                }
                if !supervisorTimeout
                    && reapedSupervisorElapsed >= supervisorTimeoutNanoseconds
                {
                    supervisorTimeout = true
                    supervisorTrigger = reapedSupervisorElapsed
                }
                let low = Int(reapedStatus & 0x7f)
                return WaitObservation(
                    exitCode: low == 0
                        ? Int((reapedStatus >> 8) & 0xff) : nil,
                    signal: low != 0 && low != 0x7f ? low : nil,
                    workerElapsedNanoseconds: reapedWorkerElapsed,
                    workerTimeoutTriggered: workerTimeout,
                    workerTimeoutTriggerNanoseconds: workerTrigger,
                    supervisorTimeoutTriggered: supervisorTimeout,
                    supervisorTimeoutTriggerNanoseconds: supervisorTrigger)
            }
            if let terminationStarted,
               try checkedElapsedNanoseconds(
                    from: terminationStarted,
                    through: now) >= terminationGraceNanoseconds
            {
                _ = Darwin.kill(-child, SIGKILL)
            }
            usleep(50_000)
        }
    }

    private static func reapAfterContainment(
        child: pid_t,
        status: inout Int32
    ) throws -> Int32 {
        while true {
            let result = waitpid(child, &status, 0)
            if result == child { return status }
            if result < 0 && errno == EINTR { continue }
            throw Stage6ProbeError.posix(
                "terminal waitpid containment",
                result < 0 ? errno : ECHILD)
        }
    }

    private static func isValidatedLeaseBusyTerminal(
        frames: FrameSnapshot,
        spawn: SpawnResult,
        wait: WaitObservation,
        bindings: LauncherBindings
    ) -> Bool {
        guard spawn.processIdentifier != nil,
              wait.exitCode == 0,
              wait.signal == nil,
              !wait.workerTimeoutTriggered,
              !wait.supervisorTimeoutTriggered,
              frames.candidateFrameCount == 0,
              !frames.transportDrift,
              !frames.trailingPartial,
              let payload = frames.lastProgressPayload,
              isValidWorkerPayload(
                payload,
                requirePASS: false,
                bindings: bindings),
              let outcome = payload["outcome"] as? [String: Any],
              let lease = payload["lease"] as? [String: Any],
              let phases = payload["phase_metrics"] as? [[String: Any]],
              outcome["status"] as? String == "ABSTAIN",
              outcome["classification"] as? String == "lease_busy",
              exactJSONBool(lease["worker_owned"] as Any) == false,
              exactJSONBool(
                lease["acquired_before_coregraphics_metal_or_mlx"] as Any)
                == false,
              phases.count == 6
        else { return false }
        return phases.allSatisfy {
            $0["availability"] as? String
                == "unavailable_before_probe_start"
                && $0["unavailable_reason"] as? String == "lease_busy"
        }
    }

    private static func analyzeTerminalDecisionEvidence(
        bindings: LauncherBindings,
        spawn: SpawnResult,
        wait: WaitObservation,
        frames: FrameSnapshot
    ) -> TerminalDecisionEvidence {
        let candidateCanPass = frames.candidateFrameCount == 1
            && !frames.transportDrift
            && !frames.trailingPartial
            && wait.exitCode == 0
            && wait.signal == nil
            && payloadClaimsPass(
                frames.candidatePayload,
                bindings: bindings)

        let classification: String
        if spawn.processIdentifier == nil {
            classification = "worker_spawn_failure"
        } else if wait.signal != nil {
            classification = "signal"
        } else if candidateCanPass {
            classification = "pass"
        } else if frames.transportDrift || frames.trailingPartial
            || frames.candidateFrameCount > 1
            || candidateRequiresExecutorReceiptDrift(
                observedCandidateCount: frames.candidateFrameCount,
                candidateAccepted: candidateCanPass)
            || (frames.lastProgressPayload != nil
                && !isValidWorkerPayload(
                    frames.lastProgressPayload,
                    requirePASS: false,
                    bindings: bindings))
        {
            classification = "executor_receipt_drift"
        } else if let payload = frames.lastProgressPayload,
                  let outcome = payload["outcome"] as? [String: Any],
                  let claimed = outcome["classification"] as? String,
                  classificationDomain.contains(claimed), claimed != "pass"
        {
            classification = claimed
        } else {
            classification = "executor_receipt_drift"
        }
        return TerminalDecisionEvidence(
            candidateCanPass: candidateCanPass,
            baseClassification: classification,
            candidatePayload: frames.candidatePayload,
            lastProgressPayload: frames.lastProgressPayload)
    }

    private static func makeTerminalDecision(
        evidence: TerminalDecisionEvidence,
        bindings: LauncherBindings,
        spawn: SpawnResult,
        wait: WaitObservation,
        frames: FrameSnapshot,
        supervisorReacquireProved: Bool
    ) throws -> TerminalDecision {
        let timeout = wait.workerTimeoutTriggered
            || wait.supervisorTimeoutTriggered
        let candidateAccepted = evidence.candidateCanPass && !timeout
        let classification = timeout ? "timeout" : evidence.baseClassification
        let selectedPayload = candidateAccepted
            ? evidence.candidatePayload
            : evidence.lastProgressPayload
        var payload = try normalizedPayload(
            selectedPayload,
            bindings: bindings,
            classification: classification,
            fatal: classification == "oom" || classification == "timeout"
                || classification == "signal")
        var outcome = payload["outcome"] as! [String: Any]
        outcome["status"] = candidateAccepted ? "PASS" : "ABSTAIN"
        outcome["classification"] = classification
        outcome["worker_candidate_present"] = candidateAccepted
        outcome["resource_clearance_established"] = candidateAccepted
        outcome["resource_envelope_established"] = candidateAccepted
        payload["outcome"] = outcome
        var lease = payload["lease"] as! [String: Any]
        lease["supervisor_reacquire_release_proved"] = supervisorReacquireProved
        payload["lease"] = lease
        try validateTerminalDecisionPayload(
            payload,
            classification: classification,
            candidateAccepted: candidateAccepted,
            spawn: spawn,
            wait: wait,
            frames: frames,
            bindings: bindings)
        return TerminalDecision(
            classification: classification,
            candidateAccepted: candidateAccepted,
            payload: payload)
    }

    private static func makeFinalReceipt(
        bindings: LauncherBindings,
        spawn: SpawnResult,
        wait: WaitObservation,
        frames: FrameSnapshot,
        supervisorElapsedNanoseconds: UInt64,
        decision: TerminalDecision
    ) throws -> [String: Any] {
        let payload = decision.payload

        let timeoutScope: Any
        switch (wait.workerTimeoutTriggered, wait.supervisorTimeoutTriggered) {
        case (true, true): timeoutScope = "worker_active_and_supervisor_end_to_end"
        case (true, false): timeoutScope = "worker_active"
        case (false, true): timeoutScope = "supervisor_end_to_end"
        case (false, false): timeoutScope = NSNull()
        }
        let execution: [String: Any] = [
            "authority_closure_active_job_conclusion":
                bindings.authorityClosureActiveJobConclusion,
            "authority_closure_active_job_id": bindings.authorityClosureActiveJobID,
            "authority_closure_artifact_count": bindings.authorityClosureArtifactCount,
            "authority_closure_check_suite_id": bindings.authorityClosureCheckSuiteID,
            "authority_closure_conclusion": bindings.authorityClosureConclusion,
            "authority_closure_event": bindings.authorityClosureEvent,
            "authority_closure_ref": bindings.authorityClosureRef,
            "authority_closure_rerun_count": bindings.authorityClosureRerunCount,
            "authority_closure_revision": bindings.authorityClosureRevision,
            "authority_closure_reviewed_job_conclusion":
                bindings.authorityClosureReviewedJobConclusion,
            "authority_closure_reviewed_job_id":
                bindings.authorityClosureReviewedJobID,
            "authority_closure_run_attempt": bindings.authorityClosureRunAttempt,
            "authority_closure_run_id": bindings.authorityClosureRunID,
            "authority_closure_run_number": bindings.authorityClosureRunNumber,
            "authority_closure_status": bindings.authorityClosureStatus,
            "authority_closure_tree": bindings.authorityClosureTree,
            "authority_base_revision": bindings.authorityBaseRevision,
            "authority_base_tree": bindings.authorityBaseTree,
            "build_count": 1,
            "direct_executable_probe_count": 1,
            "direct_xctest_count": 1,
            "exact_changed_source_identities": bindings.exactChangedSourceIdentities,
            "launcher_invocation_count": 1,
            "mechanics_event": bindings.mechanicsEvent,
            "mechanics_head_ordered_parent_revisions": [
                bindings.mechanicsFirstParent, bindings.mechanicsSecondParent,
            ],
            "mechanics_head_revision": bindings.mechanicsRevision,
            "mechanics_head_tree": bindings.mechanicsTree,
            "mechanics_ref": bindings.mechanicsRef,
            "mechanics_run_attempt": bindings.mechanicsRunAttempt,
            "mechanics_run_id": bindings.mechanicsRunID,
            "mechanics_run_number": bindings.mechanicsRunNumber,
            "provenance_source_identities": bindings.provenanceSourceIdentities,
            "repository": "Ergentics/ergentics-prime",
            "supervisor_end_to_end_elapsed_nanoseconds":
                supervisorElapsedNanoseconds,
            "supervisor_process_count": 1,
            "worker_exit_code": wait.exitCode ?? NSNull(),
            "supervisor_timeout_trigger_elapsed_nanoseconds":
                wait.supervisorTimeoutTriggerNanoseconds ?? NSNull(),
            "supervisor_timeout_triggered": wait.supervisorTimeoutTriggered,
            "timeout_scope": timeoutScope,
            "worker_active_elapsed_nanoseconds":
                wait.workerElapsedNanoseconds ?? NSNull(),
            "worker_process_count": spawn.processIdentifier == nil ? 0 : 1,
            "worker_signal": wait.signal ?? NSNull(),
            "worker_candidate_frame_count": frames.candidateFrameCount,
            "worker_last_complete_frame_sequence":
                frames.lastCompleteSequence ?? NSNull(),
            "worker_progress_frame_count": frames.progressFrameCount,
            "worker_spawn_attempt_count": 1,
            "worker_spawn_errno": spawn.errorCode ?? NSNull(),
            "worker_spawn_succeeded": spawn.processIdentifier != nil,
            "worker_trailing_partial_frame_discarded": frames.trailingPartial,
            "worker_transport_drift_detected": frames.transportDrift,
            "worker_timeout_trigger_elapsed_nanoseconds":
                wait.workerTimeoutTriggerNanoseconds ?? NSNull(),
            "worker_timeout_triggered": wait.workerTimeoutTriggered,
        ]
        let source = bindings.authoritySourceIdentity
        let test = bindings.authorityTestIdentity
        return [
            "authority": [
                "authority_canonical_sha256": bindings.authorityCanonicalSHA256,
                "authority_id": bindings.authorityID,
                "authority_source_git_blob": source["git_blob"]!,
                "authority_source_sha256": source["sha256"]!,
                "authority_test_git_blob": test["git_blob"]!,
                "authority_test_sha256": test["sha256"]!,
            ],
            "ceiling": falseCeiling(),
            "configuration": try configurationReceipt(),
            "environment": payload["environment"]!,
            "execution": execution,
            "lease": payload["lease"]!,
            "limits": payload["limits"]!,
            "outcome": payload["outcome"]!,
            "phase_metrics": payload["phase_metrics"]!,
            "receipt_id": receiptSchemaID,
            "schema_version": 1,
        ]
    }

    private static func validateFinalReceipt(
        _ object: Any,
        bindings: LauncherBindings,
        spawn: SpawnResult,
        wait: WaitObservation,
        frames: FrameSnapshot,
        supervisorElapsedNanoseconds: UInt64,
        decision: TerminalDecision
    ) throws {
        try validateFinalReceiptShape(object)
        guard let receipt = object as? [String: Any],
              let authoritySection = receipt["authority"] as? [String: Any],
              let ceiling = receipt["ceiling"] as? [String: Any],
              let configuration = receipt["configuration"] as? [String: Any],
              let environment = receipt["environment"] as? [String: Any],
              let execution = receipt["execution"] as? [String: Any],
              let lease = receipt["lease"] as? [String: Any],
              let limits = receipt["limits"] as? [String: Any],
              let outcome = receipt["outcome"] as? [String: Any],
              let phases = receipt["phase_metrics"] as? [[String: Any]]
        else {
            throw Stage6ProbeError.contract("final receipt nested types")
        }
        try require(
            receipt["receipt_id"] as? String == receiptSchemaID
                && exactJSONUInt64(receipt["schema_version"] as Any) == 1,
            "final receipt identity")

        let authoritySource = bindings.authoritySourceIdentity
        let authorityTest = bindings.authorityTestIdentity
        let expectedAuthority: [String: Any] = [
            "authority_canonical_sha256": bindings.authorityCanonicalSHA256,
            "authority_id": bindings.authorityID,
            "authority_source_git_blob": authoritySource["git_blob"]!,
            "authority_source_sha256": authoritySource["sha256"]!,
            "authority_test_git_blob": authorityTest["git_blob"]!,
            "authority_test_sha256": authorityTest["sha256"]!,
        ]
        let authorityData = try canonicalJSONData(authoritySection)
        let expectedAuthorityData = try canonicalJSONData(expectedAuthority)
        try require(
            authorityData == expectedAuthorityData,
            "final authority bindings")
        let ceilingData = try canonicalJSONData(ceiling)
        let expectedCeilingData = try canonicalJSONData(falseCeiling())
        try require(
            ceilingData == expectedCeilingData
                && ceiling.values.allSatisfy {
                    exactJSONBool($0) == false
                },
            "final false ceiling")
        let configurationData = try canonicalJSONData(configuration)
        let expectedConfigurationData = try canonicalJSONData(
            configurationReceipt())
        try require(
            configurationData == expectedConfigurationData,
            "final configuration")

        let frozenPayload: [String: Any] = [
            "environment": environment,
            "lease": lease,
            "limits": limits,
            "outcome": outcome,
            "phase_metrics": phases,
        ]
        let frozenPayloadData = try canonicalJSONData(frozenPayload)
        let decisionPayloadData = try canonicalJSONData(decision.payload)
        try require(
            frozenPayloadData == decisionPayloadData,
            "final frozen terminal payload")
        try require(
            decision.candidateAccepted
                == (outcome["status"] as? String == "PASS")
                && decision.classification
                    == outcome["classification"] as? String,
            "final decision binding")

        let expectedStaticStrings: [String: String] = [
            "authority_closure_active_job_conclusion":
                bindings.authorityClosureActiveJobConclusion,
            "authority_closure_conclusion": bindings.authorityClosureConclusion,
            "authority_closure_event": bindings.authorityClosureEvent,
            "authority_closure_ref": bindings.authorityClosureRef,
            "authority_closure_revision": bindings.authorityClosureRevision,
            "authority_closure_reviewed_job_conclusion":
                bindings.authorityClosureReviewedJobConclusion,
            "authority_closure_status": bindings.authorityClosureStatus,
            "authority_closure_tree": bindings.authorityClosureTree,
            "authority_base_revision": bindings.authorityBaseRevision,
            "authority_base_tree": bindings.authorityBaseTree,
            "mechanics_event": bindings.mechanicsEvent,
            "mechanics_head_revision": bindings.mechanicsRevision,
            "mechanics_head_tree": bindings.mechanicsTree,
            "mechanics_ref": bindings.mechanicsRef,
            "repository": "Ergentics/ergentics-prime",
        ]
        for (key, expected) in expectedStaticStrings {
            try require(execution[key] as? String == expected,
                "final execution \(key)")
        }
        let expectedStaticNumbers: [String: UInt64] = [
            "authority_closure_active_job_id":
                bindings.authorityClosureActiveJobID,
            "authority_closure_artifact_count":
                bindings.authorityClosureArtifactCount,
            "authority_closure_check_suite_id":
                bindings.authorityClosureCheckSuiteID,
            "authority_closure_rerun_count":
                bindings.authorityClosureRerunCount,
            "authority_closure_reviewed_job_id":
                bindings.authorityClosureReviewedJobID,
            "authority_closure_run_attempt": bindings.authorityClosureRunAttempt,
            "authority_closure_run_id": bindings.authorityClosureRunID,
            "authority_closure_run_number": bindings.authorityClosureRunNumber,
            "build_count": 1,
            "direct_executable_probe_count": 1,
            "direct_xctest_count": 1,
            "launcher_invocation_count": 1,
            "mechanics_run_attempt": bindings.mechanicsRunAttempt,
            "mechanics_run_id": bindings.mechanicsRunID,
            "mechanics_run_number": bindings.mechanicsRunNumber,
            "supervisor_process_count": 1,
            "worker_spawn_attempt_count": 1,
        ]
        for (key, expected) in expectedStaticNumbers {
            try require(exactJSONUInt64(execution[key] as Any) == expected,
                "final execution \(key)")
        }
        let receiptExactIdentitiesData = try canonicalJSONData(
            execution["exact_changed_source_identities"] as Any)
        let expectedExactIdentitiesData = try canonicalJSONData(
            bindings.exactChangedSourceIdentities)
        let receiptProvenanceData = try canonicalJSONData(
            execution["provenance_source_identities"] as Any)
        let expectedProvenanceData = try canonicalJSONData(
            bindings.provenanceSourceIdentities)
        try require(
            receiptExactIdentitiesData == expectedExactIdentitiesData
                && receiptProvenanceData == expectedProvenanceData
                && (execution[
                    "mechanics_head_ordered_parent_revisions"] as? [String])
                    == [
                        bindings.mechanicsFirstParent,
                        bindings.mechanicsSecondParent,
                    ],
            "final execution source identities")

        let spawned = spawn.processIdentifier != nil
        try require(
            exactJSONBool(execution["worker_spawn_succeeded"] as Any)
                == spawned
                && exactJSONUInt64(execution["worker_process_count"] as Any)
                    == (spawned ? 1 : 0),
            "final spawn disposition")
        if spawned {
            try require(execution["worker_spawn_errno"] is NSNull,
                "successful spawn errno null")
        } else {
            try require(
                exactJSONUInt64(execution["worker_spawn_errno"] as Any)
                    == UInt64(spawn.errorCode!),
                "failed spawn errno")
        }
        try require(
            exactJSONUInt64(execution["worker_progress_frame_count"] as Any)
                == UInt64(frames.progressFrameCount)
                && exactJSONUInt64(
                    execution["worker_candidate_frame_count"] as Any)
                    == UInt64(frames.candidateFrameCount)
                && exactJSONBool(
                    execution[
                        "worker_trailing_partial_frame_discarded"] as Any)
                    == frames.trailingPartial
                && exactJSONBool(
                    execution["worker_transport_drift_detected"] as Any)
                    == frames.transportDrift,
            "final transport observations")
        if let sequence = frames.lastCompleteSequence {
            try require(
                exactJSONUInt64(
                    execution["worker_last_complete_frame_sequence"] as Any)
                    == sequence,
                "final frame sequence")
        } else {
            try require(
                execution["worker_last_complete_frame_sequence"] is NSNull,
                "final null frame sequence")
        }

        try require(
            exactJSONUInt64(
                execution["supervisor_end_to_end_elapsed_nanoseconds"]
                    as Any) == supervisorElapsedNanoseconds
                && supervisorElapsedNanoseconds > 0,
            "final supervisor elapsed")
        if spawned {
            guard let workerElapsed = wait.workerElapsedNanoseconds else {
                throw Stage6ProbeError.contract("final worker elapsed missing")
            }
            try require(
                exactJSONUInt64(
                    execution["worker_active_elapsed_nanoseconds"] as Any)
                    == workerElapsed
                    && workerElapsed <= supervisorElapsedNanoseconds,
                "final worker elapsed")
            try require((wait.exitCode != nil) != (wait.signal != nil),
                "final terminal wait status")
            if let exitCode = wait.exitCode {
                try require(
                    exactJSONInt64(execution["worker_exit_code"] as Any)
                        == Int64(exitCode)
                        && execution["worker_signal"] is NSNull,
                    "final exit code")
            } else {
                try require(execution["worker_exit_code"] is NSNull
                    && exactJSONInt64(execution["worker_signal"] as Any)
                        == Int64(wait.signal!),
                    "final signal")
            }
            let observedElapsed = phases.compactMap {
                exactJSONUInt64(
                    $0["cumulative_worker_probe_elapsed_nanoseconds"] as Any)
            }
            if let lastObserved = observedElapsed.last {
                try require(lastObserved <= workerElapsed,
                    "phase elapsed within worker interval")
            }
        } else {
            try require(
                execution["worker_active_elapsed_nanoseconds"] is NSNull
                    && execution["worker_exit_code"] is NSNull
                    && execution["worker_signal"] is NSNull,
                "spawn failure worker observations null")
        }

        try require(
            exactJSONBool(execution["worker_timeout_triggered"] as Any)
                == wait.workerTimeoutTriggered
                && exactJSONBool(
                    execution["supervisor_timeout_triggered"] as Any)
                    == wait.supervisorTimeoutTriggered,
            "final timeout booleans")
        if wait.workerTimeoutTriggered {
            let trigger = wait.workerTimeoutTriggerNanoseconds!
            try require(trigger >= workerActiveTimeoutNanoseconds
                && exactJSONUInt64(
                    execution[
                        "worker_timeout_trigger_elapsed_nanoseconds"] as Any)
                    == trigger,
                "worker timeout trigger")
        } else {
            try require(
                execution[
                    "worker_timeout_trigger_elapsed_nanoseconds"] is NSNull
                    && (wait.workerElapsedNanoseconds ?? 0)
                        < workerActiveTimeoutNanoseconds,
                "worker non-timeout timing")
        }
        if wait.supervisorTimeoutTriggered {
            let trigger = wait.supervisorTimeoutTriggerNanoseconds!
            try require(trigger >= supervisorTimeoutNanoseconds
                && trigger <= supervisorElapsedNanoseconds
                && exactJSONUInt64(
                    execution[
                        "supervisor_timeout_trigger_elapsed_nanoseconds"]
                        as Any) == trigger,
                "supervisor timeout trigger")
        } else {
            try require(
                execution[
                    "supervisor_timeout_trigger_elapsed_nanoseconds"] is NSNull
                    && supervisorElapsedNanoseconds
                        < supervisorTimeoutNanoseconds,
                "supervisor non-timeout timing")
        }
        let expectedScope: String?
        switch (
            wait.workerTimeoutTriggered,
            wait.supervisorTimeoutTriggered
        ) {
        case (true, true):
            expectedScope = "worker_active_and_supervisor_end_to_end"
        case (true, false): expectedScope = "worker_active"
        case (false, true): expectedScope = "supervisor_end_to_end"
        case (false, false): expectedScope = nil
        }
        if let expectedScope {
            try require(execution["timeout_scope"] as? String == expectedScope,
                "final timeout scope")
        } else {
            try require(execution["timeout_scope"] is NSNull,
                "final null timeout scope")
        }
    }

    private static func payloadClaimsPass(
        _ payload: [String: Any]?,
        bindings: LauncherBindings
    ) -> Bool {
        isValidWorkerPayload(
            payload,
            requirePASS: true,
            bindings: bindings)
    }

    private static func normalizedPayload(
        _ source: [String: Any]?,
        bindings: LauncherBindings,
        classification: String,
        fatal: Bool
    ) throws -> [String: Any] {
        var worker = WorkerPayload(bindings: bindings)
        if let source,
           isValidWorkerPayload(
               source,
               requirePASS: false,
               bindings: bindings),
           Set(source.keys) == ["environment", "lease", "limits", "outcome", "phase_metrics"],
           let environment = source["environment"] as? [String: Any],
           let lease = source["lease"] as? [String: Any],
           let limits = source["limits"] as? [String: Any],
           let outcome = source["outcome"] as? [String: Any],
           let phases = source["phase_metrics"] as? [[String: Any]],
           let counts = outcome["operation_counts"] as? [String: Any]
        {
            worker.environment = environment
            worker.lease = lease
            worker.limits = limits
            worker.outcome = outcome
            worker.phaseMetrics = phases.filter {
                $0["availability"] as? String == "observed"
            }
            if Set(counts.keys) == Set(operationCountKeys) {
                var converted = [String: Int]()
                for (key, value) in counts {
                    if let integer = exactJSONUInt64(value), integer <= UInt64(Int.max) {
                        converted[key] = Int(integer)
                    }
                }
                if converted.count == operationCountKeys.count {
                    worker.operationCounts.values = converted
                }
            }
        }
        worker.setOutcome(
            status: classification == "pass" ? "PASS" : "ABSTAIN",
            classification: classification,
            candidatePresent: classification == "pass")
        worker.finishPhases(classification: classification, fatal: fatal)
        return worker.framePayload()
    }

    private static func validateTerminalDecisionPayload(
        _ payload: [String: Any],
        classification: String,
        candidateAccepted: Bool,
        spawn: SpawnResult,
        wait: WaitObservation,
        frames: FrameSnapshot,
        bindings: LauncherBindings
    ) throws {
        try require(
            isValidWorkerPayload(
                payload,
                requirePASS: candidateAccepted,
                bindings: bindings),
            "terminal payload semantics")
        guard let outcome = payload["outcome"] as? [String: Any],
              let lease = payload["lease"] as? [String: Any],
              let phases = payload["phase_metrics"] as? [[String: Any]],
              let counts = outcome["operation_counts"] as? [String: Any]
        else {
            throw Stage6ProbeError.contract("terminal payload types")
        }
        try require(classificationDomain.contains(classification), "terminal class")
        try require(phases.count == phaseNames.count, "terminal six phases")
        try require(
            outcome["classification"] as? String == classification,
            "terminal classification binding")
        try require(
            exactJSONBool(outcome["one_shot_consumed"] as Any) == true,
            "one shot consumed")
        try require(
            exactJSONBool(outcome["worker_candidate_present"] as Any)
                == candidateAccepted,
            "candidate transition")
        try require(
            exactJSONBool(outcome["resource_clearance_established"] as Any)
                == candidateAccepted
                && exactJSONBool(
                    outcome["resource_envelope_established"] as Any)
                    == candidateAccepted,
            "clearance transitions")

        let modelAttempts = exactJSONUInt64(
            counts["model_allocation_count"] as Any) ?? UInt64.max
        try require(modelAttempts <= 1, "model allocation attempts")
        try require(
            exactJSONBool(outcome["resource_probe_executed"] as Any)
                == (modelAttempts == 1),
            "resource probe transition")
        let expectedMaximums: [String: UInt64] = [
            "adamw_update_count": 1, "backward_count": 1,
            "checked_evaluation_barrier_count": 5,
            "cross_entropy_count": 1, "evaluation_forward_pass_count": 0,
            "forward_loss_count": 1, "full_graph_evaluation_count": 1,
            "gpu_synchronization_barrier_count": 5,
            "gradient_clip_count": 1, "gradient_norm_count": 1,
            "kv_cache_allocation_count": 0, "memory_clear_cache_count": 1,
            "mlx_peak_memory_reset_count": 1, "model_allocation_count": 1,
            "model_materialization_count": 1, "optimizer_step_count": 1,
            "postflight_device_reenumeration_count": 1,
            "training_logits_count": 1, "value_and_grad_count": 1,
        ]
        for (key, maximum) in expectedMaximums {
            guard let observed = exactJSONUInt64(counts[key] as Any) else {
                throw Stage6ProbeError.contract("terminal count \(key)")
            }
            try require(observed <= maximum, "terminal count maximum \(key)")
        }

        if candidateAccepted {
            try require(classification == "pass", "PASS classification")
            try require(outcome["status"] as? String == "PASS", "PASS status")
            try require(wait.exitCode == 0 && wait.signal == nil, "PASS wait")
            try require(!wait.workerTimeoutTriggered
                && !wait.supervisorTimeoutTriggered, "PASS timeout")
            try require(frames.candidateFrameCount == 1
                && !frames.transportDrift && !frames.trailingPartial,
                "PASS transport")
            try require(
                exactJSONBool(
                    lease["supervisor_reacquire_release_proved"] as Any)
                    == true,
                "PASS lease cleanup")
        } else {
            try require(classification != "pass", "ABSTAIN classification")
            try require(outcome["status"] as? String == "ABSTAIN", "ABSTAIN status")
            try require(
                exactJSONBool(
                    outcome["resource_clearance_established"] as Any) == false,
                "ABSTAIN clearance")
            var unavailableSeen = false
            var observedCount = 0
            for phase in phases {
                let availability = phase["availability"] as! String
                if availability == "observed" {
                    try require(!unavailableSeen, "phase observed prefix")
                    observedCount += 1
                } else {
                    unavailableSeen = true
                    try require(
                        phase["unavailable_reason"] as? String == classification,
                        "phase unavailable reason")
                }
            }
            let expectedUnavailableAvailability: String
            switch classification {
            case "worker_spawn_failure", "lease_busy":
                try require(observedCount == 0,
                    "pre-probe classification phase prefix")
                expectedUnavailableAvailability =
                    "unavailable_before_probe_start"
            case "preflight_floor":
                try require(observedCount == 1,
                    "preflight floor phase prefix")
                expectedUnavailableAvailability =
                    "unavailable_after_classification"
                let configured = exactJSONUInt64(
                    (payload["limits"] as! [String: Any])[
                        "configured_memory_limit_bytes"] as Any) ?? 0
                let disk = exactJSONUInt64(
                    phases[0]["filesystem_available_bytes"] as Any) ?? 0
                try require(configured < 4_337_713_152
                    || disk < 12_884_901_888,
                    "preflight floor predicate")
            case "oom", "timeout", "signal":
                expectedUnavailableAvailability = "unavailable_after_fatal"
            case "nonfinite":
                try require(observedCount == 2 || observedCount == 3,
                    "nonfinite boundary prefix")
                expectedUnavailableAvailability =
                    "unavailable_after_classification"
            case "no_update":
                try require(observedCount == 6,
                    "no-update completed boundary prefix")
                expectedUnavailableAvailability =
                    "unavailable_after_classification"
                try require(
                    exactJSONBool(outcome["update_occurred"] as Any) == false,
                    "no-update observation")
            case "topology_dtype", "executor_receipt_drift":
                expectedUnavailableAvailability =
                    "unavailable_after_classification"
            default:
                throw Stage6ProbeError.contract(
                    "unsupported ABSTAIN classification")
            }
            for phase in phases.dropFirst(observedCount) {
                try require(
                    phase["availability"] as? String
                        == expectedUnavailableAvailability,
                    "classification phase availability")
            }
        }

        if spawn.processIdentifier == nil {
            try require(
                classification == (wait.supervisorTimeoutTriggered
                    ? "timeout" : "worker_spawn_failure"),
                "spawn class")
            try require(wait.exitCode == nil && wait.signal == nil, "spawn wait null")
            try require(frames.progressFrameCount == 0
                && frames.candidateFrameCount == 0,
                "spawn frames")
            try require(counts.values.allSatisfy {
                exactJSONUInt64($0) == 0
            }, "spawn counts")
        } else {
            try require(
                (wait.exitCode != nil) != (wait.signal != nil),
                "terminal waitpid disposition")
            try require(wait.workerElapsedNanoseconds != nil, "worker elapsed")
        }
        let workerOwned = exactJSONBool(lease["worker_owned"] as Any) == true
        let cleanupProved = exactJSONBool(
            lease["supervisor_reacquire_release_proved"] as Any) == true
        if classification == "lease_busy" {
            try require(!workerOwned && !cleanupProved, "lease busy disposition")
        } else if spawn.processIdentifier != nil {
            try require(cleanupProved, "spawned-child cleanup proof")
        }
        try require(
            cleanupProved
                == (spawn.processIdentifier != nil
                    && classification != "lease_busy"),
            "lease cleanup disposition")
        try require(
            exactJSONBool(lease["held_through_candidate_flush"] as Any)
                == candidateAccepted,
            "candidate flush lease transition")
        try require(
            lease["lease_path"] as? String == bindings.leasePath
                && lease["type"] as? String == "PrimeMetalDeviceLease"
                && exactJSONBool(lease["acquired_nonblocking"] as Any) == true,
            "lease static fields")
        let timeout = wait.workerTimeoutTriggered
            || wait.supervisorTimeoutTriggered
        try require((classification == "timeout") == timeout,
            "timeout classification")
        if !candidateAccepted
            && frames.candidateFrameCount > 0
            && !timeout
            && wait.signal == nil
        {
            try require(classification == "executor_receipt_drift",
                "unaccepted candidate drift")
        }
        if !timeout && wait.signal != nil {
            try require(classification == "signal", "signal classification")
        }
    }

    private static func resolvedExecutablePath() -> String {
        URL(fileURLWithPath: CommandLine.arguments[0])
            .resolvingSymlinksInPath().standardizedFileURL.path
    }

    private static func isValidWorkerPayload(
        _ payload: [String: Any]?,
        requirePASS: Bool,
        bindings: LauncherBindings
    ) -> Bool {
        guard let payload else { return false }
        do {
            let authority =
                PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1
                    .frozenV1.receiptContract
            try require(
                Set(payload.keys)
                    == ["environment", "lease", "limits", "outcome", "phase_metrics"],
                "worker payload keys")
            guard let environment = payload["environment"] as? [String: Any],
                  let lease = payload["lease"] as? [String: Any],
                  let limits = payload["limits"] as? [String: Any],
                  let outcome = payload["outcome"] as? [String: Any],
                  let phases = payload["phase_metrics"] as? [[String: Any]],
                  let counts = outcome["operation_counts"] as? [String: Any]
            else {
                throw Stage6ProbeError.contract("worker payload types")
            }
            try require(Set(environment.keys) == Set(authority.environmentKeys), "worker environment keys")
            try require(Set(lease.keys) == Set(authority.leaseKeys), "worker lease keys")
            try require(Set(limits.keys) == Set(authority.limitsKeys), "worker limits keys")
            try require(Set(outcome.keys) == Set(authority.outcomeKeys), "worker outcome keys")
            try require(Set(counts.keys) == Set(authority.operationCountKeys), "worker operation keys")
            for value in counts.values {
                try require(exactJSONUInt64(value) != nil, "worker operation integer")
            }
            try require(phases.count <= 6, "worker phase count")
            for (index, phase) in phases.enumerated() {
                try require(Set(phase.keys) == Set(authority.phaseMetricKeys), "worker phase keys")
                try require(phase["phase"] as? String == phaseNames[index], "worker phase order")
                guard let availability = phase["availability"] as? String else {
                    throw Stage6ProbeError.contract("worker phase availability")
                }
                try require(
                    authority.phaseAvailabilityDomain.contains(availability),
                    "worker phase availability domain")
                if availability == "observed" {
                    try require(phase["unavailable_reason"] is NSNull, "observed unavailable reason")
                    for key in authority.nullableNumericMetricKeys {
                        try require(exactJSONUInt64(phase[key] as Any) != nil, "observed metric \(key)")
                    }
                } else {
                    try require(phase["unavailable_reason"] is String, "unavailable reason")
                    for key in authority.nullableNumericMetricKeys {
                        try require(phase[key] is NSNull, "unavailable metric \(key)")
                    }
                }
            }
            try validateWorkerPayloadProgressSemantics(
                environment: environment,
                lease: lease,
                limits: limits,
                outcome: outcome,
                phases: phases,
                counts: counts,
                bindings: bindings)
            if requirePASS {
                try validatePASSWorkerPayload(
                    environment: environment,
                    lease: lease,
                    limits: limits,
                    outcome: outcome,
                    phases: phases,
                    counts: counts,
                    bindings: bindings)
            }
            return true
        } catch {
            return false
        }
    }

    private static func validateWorkerPayloadProgressSemantics(
        environment: [String: Any],
        lease: [String: Any],
        limits: [String: Any],
        outcome: [String: Any],
        phases: [[String: Any]],
        counts: [String: Any],
        bindings: LauncherBindings
    ) throws {
        try require(
            exactJSONUInt64(
                environment["mlx_compile_transform_invocation_count"] as Any)
                == 0
                && environment["mlx_enable_tf32"] as? String == "0"
                && environment["mlx_revision"] as? String
                    == bindings.exactMLXRevision
                && environment["operating_system_build"] as? String
                    == bindings.operatingSystemBuild
                && environment["runtime_metallib_path"] as? String
                    == bindings.metallibPath
                && exactJSONUInt64(
                    environment["runtime_metallib_byte_count"] as Any)
                    == bindings.metallibBytes
                && environment["runtime_metallib_sha256"] as? String
                    == bindings.metallibSHA256
                && environment["swift_sdk"] as? String == bindings.macOSSDK
                && environment["swift_version"] as? String
                    == bindings.swiftToolchain
                && environment["swiftpm_build_configuration"] as? String
                    == "release"
                && environment["xcode_version"] as? String
                    == bindings.xcodeToolchain,
            "worker static environment")

        let deviceKeys = [
            "metal_device_count", "metal_device_index",
            "metal_device_is_default", "metal_device_max_buffer_length_bytes",
            "metal_device_max_recommended_working_set_bytes",
            "metal_device_has_unified_memory", "metal_device_name",
            "metal_device_registry_id",
        ]
        let deviceNullCount = deviceKeys.filter {
            environment[$0] is NSNull
        }.count
        try require(
            deviceNullCount == 0 || deviceNullCount == deviceKeys.count,
            "atomic Metal environment")
        if deviceNullCount == 0 {
            try require(
                exactJSONUInt64(environment["metal_device_count"] as Any) == 1
                    && exactJSONUInt64(
                        environment["metal_device_index"] as Any) == 0
                    && exactJSONBool(
                        environment["metal_device_is_default"] as Any) == true
                    && exactJSONUInt64(
                        environment[
                            "metal_device_max_buffer_length_bytes"] as Any)
                        != nil
                    && (exactJSONUInt64(
                        environment[
                            "metal_device_max_recommended_working_set_bytes"]
                            as Any) ?? 0) > 0
                    && exactJSONBool(
                        environment["metal_device_has_unified_memory"] as Any)
                        == true
                    && !(environment["metal_device_name"] as? String
                        ?? "").isEmpty
                    && exactJSONUInt64(
                        environment["metal_device_registry_id"] as Any) != nil,
                "observed Metal environment")
        }

        let mlxKeys = [
            "mlx_cpu_fallback_used", "mlx_default_device_is_supplied_device",
            "mlx_default_stream_is_gpu", "mlx_device_constructor_index",
            "mlx_device_type",
        ]
        let mlxNullCount = mlxKeys.filter { environment[$0] is NSNull }.count
        try require(
            mlxNullCount == 0 || mlxNullCount == mlxKeys.count,
            "atomic MLX environment")
        if mlxNullCount == 0 {
            try require(
                exactJSONBool(environment["mlx_cpu_fallback_used"] as Any)
                    == false
                    && exactJSONBool(
                        environment[
                            "mlx_default_device_is_supplied_device"] as Any)
                        == true
                    && exactJSONBool(
                        environment["mlx_default_stream_is_gpu"] as Any)
                        == true
                    && exactJSONUInt64(
                        environment["mlx_device_constructor_index"] as Any)
                        == 0
                    && environment["mlx_device_type"] as? String == "gpu",
                "observed MLX environment")
        }

        let filesystemNulls = [
            environment["filesystem_observation_path"] is NSNull,
            environment["filesystem_observation_fsid"] is NSNull,
        ]
        try require(
            filesystemNulls[0] == filesystemNulls[1],
            "atomic filesystem environment")
        if !filesystemNulls[0] {
            guard let path = environment["filesystem_observation_path"]
                    as? String,
                  path.hasPrefix("/"), path != "/",
                  let fsid = environment["filesystem_observation_fsid"]
                    as? [Any],
                  fsid.count == 2,
                  fsid.allSatisfy({ exactJSONInt64($0) != nil })
            else {
                throw Stage6ProbeError.contract(
                    "observed filesystem environment")
            }
        }

        try require(
            lease["lease_path"] as? String == bindings.leasePath
                && lease["type"] as? String == "PrimeMetalDeviceLease",
            "worker lease static")
        let leaseBooleanKeys = [
            "acquired_before_coregraphics_metal_or_mlx",
            "acquired_nonblocking", "held_through_candidate_flush",
            "held_through_postflight", "supervisor_reacquire_release_proved",
            "worker_owned",
        ]
        for key in leaseBooleanKeys {
            try require(exactJSONBool(lease[key] as Any) != nil,
                "worker lease boolean \(key)")
        }
        let acquired = exactJSONBool(
            lease["acquired_before_coregraphics_metal_or_mlx"] as Any)!
        let workerOwned = exactJSONBool(lease["worker_owned"] as Any)!
        let heldCandidate = exactJSONBool(
            lease["held_through_candidate_flush"] as Any)!
        let heldPostflight = exactJSONBool(
            lease["held_through_postflight"] as Any)!
        try require(
            exactJSONBool(lease["acquired_nonblocking"] as Any) == true
                && acquired == workerOwned
                && (!heldCandidate || workerOwned)
                && (!heldPostflight || workerOwned),
            "worker lease transitions")
        if !workerOwned {
            try require(deviceNullCount == deviceKeys.count
                && mlxNullCount == mlxKeys.count,
                "pre-lease environment remains null")
        }

        let staticLimitNumbers: [String: UInt64] = [
            "available_filesystem_floor_bytes": 12_884_901_888,
            "configured_cache_limit_bytes": 0,
            "gradient_logical_bytes": 1_084_428_288,
            "minimum_committed_tensor_state_bytes": 3_253_284_864,
            "minimum_memory_limit_floor_bytes": 4_337_713_152,
            "minimum_state_plus_gradient_bytes": 4_337_713_152,
            "optimizer_moment_logical_bytes": 2_168_856_576,
            "optimizer_moment_tensor_count": 436,
            "supervisor_end_to_end_timeout_seconds": 1_500,
            "termination_grace_seconds": 10,
            "three_times_committed_state_disk_comparator_bytes":
                9_759_854_592,
            "weights_logical_bytes": 1_084_428_288,
            "worker_active_timeout_seconds": 1_200,
        ]
        for (key, expected) in staticLimitNumbers {
            try require(exactJSONUInt64(limits[key] as Any) == expected,
                "worker static limit \(key)")
        }
        try require(
            limits["configured_memory_limit_formula"] as? String
                == "min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)"
                && exactJSONBool(
                    limits[
                        "container_headers_and_manifests_included_in_minimum"]
                        as Any) == false
                && exactJSONBool(
                    limits[
                        "duplicate_materializations_graphs_and_temporary_buffers_included_in_minimum"]
                        as Any) == false
                && exactJSONBool(
                    limits["mlx_limit_is_not_rss_limit"] as Any) == true
                && exactJSONBool(
                    limits["statfs_is_observational_only"] as Any) == true,
            "worker static limit policy")

        let configuredKeys = [
            "configured_memory_limit_bytes",
            "configured_memory_limit_readback_bytes",
            "configured_cache_limit_readback_bytes",
        ]
        try validateAtomicNullableUInt64Group(
            configuredKeys, in: limits, detail: "configured MLX limits")
        if !(limits[configuredKeys[0]] is NSNull) {
            let configured = exactJSONUInt64(limits[configuredKeys[0]] as Any)!
            try require(
                exactJSONUInt64(limits[configuredKeys[1]] as Any) == configured
                    && exactJSONUInt64(limits[configuredKeys[2]] as Any) == 0,
                "configured MLX readbacks")
            if deviceNullCount == 0 {
                let recommended = exactJSONUInt64(
                    environment[
                        "metal_device_max_recommended_working_set_bytes"]
                        as Any)!
                try require(
                    configured == min(UInt64(17_179_869_184), recommended),
                    "configured MLX formula")
            }
        }
        try validateAtomicFixedLimitGroup(
            [
                ("validated_parameter_path_count", 218),
                ("validated_unique_parameter_count", 271_107_072),
                ("validated_weights_logical_bytes", 1_084_428_288),
            ],
            limits: limits,
            detail: "model catalog")
        try validateAtomicFixedLimitGroup(
            [
                ("validated_gradient_path_count", 218),
                ("validated_gradient_logical_bytes", 1_084_428_288),
            ],
            limits: limits,
            detail: "gradient catalog")
        try validateAtomicFixedLimitGroup(
            [
                ("validated_first_moment_tensor_count", 218),
                ("validated_second_moment_tensor_count", 218),
                ("validated_optimizer_moment_logical_bytes", 2_168_856_576),
            ],
            limits: limits,
            detail: "moment catalog")

        let maxima: [String: UInt64] = [
            "adamw_update_count": 1, "backward_count": 1,
            "checked_evaluation_barrier_count": 5,
            "cross_entropy_count": 1, "evaluation_forward_pass_count": 0,
            "forward_loss_count": 1, "full_graph_evaluation_count": 1,
            "gpu_synchronization_barrier_count": 5,
            "gradient_clip_count": 1, "gradient_norm_count": 1,
            "kv_cache_allocation_count": 0, "memory_clear_cache_count": 1,
            "mlx_peak_memory_reset_count": 1, "model_allocation_count": 1,
            "model_materialization_count": 1, "optimizer_step_count": 1,
            "postflight_device_reenumeration_count": 1,
            "training_logits_count": 1, "value_and_grad_count": 1,
        ]
        var integerCounts = [String: UInt64]()
        for (key, maximum) in maxima {
            guard let value = exactJSONUInt64(counts[key] as Any) else {
                throw Stage6ProbeError.contract("worker count \(key)")
            }
            try require(value <= maximum, "worker count maximum \(key)")
            integerCounts[key] = value
        }
        let forwardAttempt = integerCounts["value_and_grad_count"]!
        try require(
            integerCounts["training_logits_count"] == forwardAttempt
                && integerCounts["cross_entropy_count"] == forwardAttempt
                && integerCounts["forward_loss_count"] == forwardAttempt
                && integerCounts["backward_count"] == forwardAttempt,
            "atomic forward/backward attempts")
        try require(
            integerCounts["adamw_update_count"]
                == integerCounts["optimizer_step_count"]
                && integerCounts["gradient_clip_count"]!
                    <= integerCounts["gradient_norm_count"]!
                && integerCounts["gradient_norm_count"]! <= forwardAttempt
                && integerCounts["model_materialization_count"]!
                    <= integerCounts["model_allocation_count"]!
                && integerCounts["full_graph_evaluation_count"]!
                    <= integerCounts["adamw_update_count"]!
                && integerCounts["memory_clear_cache_count"]!
                    <= integerCounts["full_graph_evaluation_count"]!
                && integerCounts["postflight_device_reenumeration_count"]!
                    <= integerCounts["memory_clear_cache_count"]!
                && integerCounts["gpu_synchronization_barrier_count"]!
                    <= integerCounts["checked_evaluation_barrier_count"]!,
            "attempted operation prefix")

        var observedCount = 0
        var unavailableSeen = false
        var previousElapsed: UInt64?
        var previousPeak: UInt64?
        var previousMaxRSS: UInt64?
        var physicalCapacity: UInt64?
        for phase in phases {
            if phase["availability"] as? String == "observed" {
                try require(!unavailableSeen, "observed phase prefix")
                observedCount += 1
                let elapsed = exactJSONUInt64(
                    phase["cumulative_worker_probe_elapsed_nanoseconds"]
                        as Any)!
                let peak = exactJSONUInt64(phase["mlx_peak_bytes"] as Any)!
                let maxRSS = exactJSONUInt64(
                    phase["getrusage_max_rss_bytes"] as Any)!
                let physical = exactJSONUInt64(
                    phase["physical_memory_capacity_bytes"] as Any)!
                if let previousElapsed {
                    try require(elapsed > previousElapsed,
                        "worker phase elapsed monotonic")
                }
                if let previousPeak {
                    try require(peak >= previousPeak,
                        "worker phase peak monotonic")
                }
                if let previousMaxRSS {
                    try require(maxRSS >= previousMaxRSS,
                        "worker phase maxrss monotonic")
                }
                physicalCapacity = physicalCapacity ?? physical
                previousElapsed = elapsed
                previousPeak = peak
                previousMaxRSS = maxRSS
            } else {
                unavailableSeen = true
            }
        }
        let phaseCountMinimums: [(Int, String, UInt64)] = [
            (1, "mlx_peak_memory_reset_count", 1),
            (2, "model_materialization_count", 1),
            (2, "checked_evaluation_barrier_count", 1),
            (2, "gpu_synchronization_barrier_count", 1),
            (3, "backward_count", 1),
            (3, "checked_evaluation_barrier_count", 2),
            (3, "gpu_synchronization_barrier_count", 2),
            (4, "gradient_clip_count", 1),
            (4, "checked_evaluation_barrier_count", 4),
            (4, "gpu_synchronization_barrier_count", 4),
            (5, "full_graph_evaluation_count", 1),
            (5, "checked_evaluation_barrier_count", 5),
            (5, "gpu_synchronization_barrier_count", 5),
            (6, "memory_clear_cache_count", 1),
        ]
        for (phaseFloor, key, countFloor) in phaseCountMinimums
            where observedCount >= phaseFloor
        {
            try require(integerCounts[key]! >= countFloor,
                "phase/count binding \(key)")
        }
        if observedCount >= 1 {
            try require(
                deviceNullCount == 0 && mlxNullCount == 0
                    && !filesystemNulls[0]
                    && !(limits[configuredKeys[0]] is NSNull),
                "preflight environment and limit observations")
        }
        if observedCount >= 2 {
            try require(
                !(limits["validated_parameter_path_count"] is NSNull),
                "post-model catalog observation")
        }
        if observedCount >= 3 {
            try require(
                !(limits["validated_gradient_path_count"] is NSNull),
                "post-backward gradient catalog observation")
        }
        if observedCount >= 5 {
            try require(
                !(limits["validated_first_moment_tensor_count"] is NSNull),
                "post-Adam moment catalog observation")
        }

        guard let status = outcome["status"] as? String,
              let classification = outcome["classification"] as? String,
              ["PASS", "ABSTAIN"].contains(status),
              classificationDomain.contains(classification)
        else {
            throw Stage6ProbeError.contract("worker outcome domain")
        }
        try require((status == "PASS") == (classification == "pass"),
            "worker status/classification")
        try require(
            exactJSONBool(outcome["one_shot_consumed"] as Any) == true
                && exactJSONBool(
                    outcome["resource_clearance_established"] as Any)
                    == (status == "PASS")
                && exactJSONBool(
                    outcome["resource_envelope_established"] as Any)
                    == (status == "PASS")
                && exactJSONBool(
                    outcome["resource_probe_executed"] as Any)
                    == (integerCounts["model_allocation_count"] == 1)
                && exactJSONBool(
                    outcome["runner_memory_capacity_established"] as Any)
                    == (deviceNullCount == 0
                        && exactJSONBool(
                            environment[
                                "metal_device_has_unified_memory"] as Any)
                            == true
                        && physicalCapacity != nil)
                && exactJSONBool(
                    outcome["worker_candidate_present"] as Any) != nil,
            "worker outcome transitions")

        try validateBoundaryOutcomeGroup(
            keys: [
                "parameter_fingerprint_before",
                "parameter_fingerprint_sample_plan_sha256",
                "parameter_fingerprint_sample_count",
            ],
            outcome: outcome,
            available: observedCount >= 2,
            detail: "before fingerprint")
        if observedCount >= 2 {
            try require(
                isLowercaseHex(
                    outcome["parameter_fingerprint_before"] as! String,
                    count: 64)
                    && isLowercaseHex(
                        outcome[
                            "parameter_fingerprint_sample_plan_sha256"]
                            as! String,
                        count: 64)
                    && exactJSONUInt64(
                        outcome["parameter_fingerprint_sample_count"] as Any)
                        == 654,
                "before fingerprint values")
        }
        try validateBoundaryOutcomeGroup(
            keys: ["loss_float32_bits"], outcome: outcome,
            available: observedCount >= 3, detail: "loss")
        try validateBoundaryOutcomeGroup(
            keys: [
                "raw_gradient_norm_float32_bits",
                "gradient_clip_scale_float32_bits",
            ],
            outcome: outcome,
            available: observedCount >= 4,
            detail: "clip")
        try validateBoundaryOutcomeGroup(
            keys: ["parameter_fingerprint_after", "update_occurred"],
            outcome: outcome,
            available: observedCount >= 5,
            detail: "after fingerprint")
        for key in [
            "loss_float32_bits", "raw_gradient_norm_float32_bits",
            "gradient_clip_scale_float32_bits",
        ] where !(outcome[key] is NSNull) {
            try require(
                (exactJSONUInt64(outcome[key] as Any) ?? UInt64.max)
                    <= UInt64(UInt32.max),
                "worker Float32 bits \(key)")
        }
        if !(outcome["parameter_fingerprint_after"] is NSNull) {
            try require(
                isLowercaseHex(
                    outcome["parameter_fingerprint_after"] as! String,
                    count: 64)
                    && exactJSONBool(outcome["update_occurred"] as Any) != nil,
                "after fingerprint values")
        }
        let postflightKeys = [
            "postflight_device_identity_matches_preflight",
            "postflight_mlx_policy_and_limits_match_preflight",
        ]
        let postflightNullCount = postflightKeys.filter {
            outcome[$0] is NSNull
        }.count
        try require(
            postflightNullCount == 0
                || postflightNullCount == postflightKeys.count,
            "atomic postflight outcomes")
        if postflightNullCount == 0 {
            try require(postflightKeys.allSatisfy {
                exactJSONBool(outcome[$0] as Any) != nil
            }, "postflight outcome booleans")
        }
    }

    private static func validateAtomicNullableUInt64Group(
        _ keys: [String],
        in dictionary: [String: Any],
        detail: String
    ) throws {
        let nullCount = keys.filter { dictionary[$0] is NSNull }.count
        try require(nullCount == 0 || nullCount == keys.count,
            "atomic \(detail)")
        if nullCount == 0 {
            try require(keys.allSatisfy {
                exactJSONUInt64(dictionary[$0] as Any) != nil
            }, "numeric \(detail)")
        }
    }

    private static func validateAtomicFixedLimitGroup(
        _ fields: [(String, UInt64)],
        limits: [String: Any],
        detail: String
    ) throws {
        let nullCount = fields.filter { limits[$0.0] is NSNull }.count
        try require(nullCount == 0 || nullCount == fields.count,
            "atomic \(detail)")
        if nullCount == 0 {
            for (key, expected) in fields {
                try require(exactJSONUInt64(limits[key] as Any) == expected,
                    "\(detail) \(key)")
            }
        }
    }

    private static func validateBoundaryOutcomeGroup(
        keys: [String],
        outcome: [String: Any],
        available: Bool,
        detail: String
    ) throws {
        try require(keys.allSatisfy {
            available ? !(outcome[$0] is NSNull) : outcome[$0] is NSNull
        }, "boundary outcome \(detail)")
    }

    private static func validatePASSWorkerPayload(
        environment: [String: Any],
        lease: [String: Any],
        limits: [String: Any],
        outcome: [String: Any],
        phases: [[String: Any]],
        counts: [String: Any],
        bindings: LauncherBindings
    ) throws {
        let expectedCounts: [String: UInt64] = [
            "adamw_update_count": 1, "backward_count": 1,
            "checked_evaluation_barrier_count": 5,
            "cross_entropy_count": 1, "evaluation_forward_pass_count": 0,
            "forward_loss_count": 1, "full_graph_evaluation_count": 1,
            "gpu_synchronization_barrier_count": 5,
            "gradient_clip_count": 1, "gradient_norm_count": 1,
            "kv_cache_allocation_count": 0, "memory_clear_cache_count": 1,
            "mlx_peak_memory_reset_count": 1, "model_allocation_count": 1,
            "model_materialization_count": 1, "optimizer_step_count": 1,
            "postflight_device_reenumeration_count": 1,
            "training_logits_count": 1, "value_and_grad_count": 1,
        ]
        for (key, expected) in expectedCounts {
            try require(exactJSONUInt64(counts[key] as Any) == expected, "PASS operation \(key)")
        }
        try require(
            exactJSONUInt64(
                environment["mlx_compile_transform_invocation_count"] as Any)
                == 0,
            "PASS compile transform count")
        try require(environment["mlx_enable_tf32"] as? String == "0"
            && environment["mlx_revision"] as? String
                == bindings.exactMLXRevision
            && environment["operating_system_build"] as? String
                == bindings.operatingSystemBuild
            && environment["runtime_metallib_path"] as? String
                == bindings.metallibPath
            && exactJSONUInt64(
                environment["runtime_metallib_byte_count"] as Any)
                == bindings.metallibBytes
            && environment["runtime_metallib_sha256"] as? String
                == bindings.metallibSHA256
            && environment["swift_sdk"] as? String == bindings.macOSSDK
            && environment["swift_version"] as? String
                == bindings.swiftToolchain
            && environment["swiftpm_build_configuration"] as? String
                == "release"
            && environment["xcode_version"] as? String
                == bindings.xcodeToolchain,
            "PASS static environment")
        guard let deviceName = environment["metal_device_name"] as? String,
              !deviceName.isEmpty,
              let filesystemPath =
                environment["filesystem_observation_path"] as? String,
              filesystemPath.hasPrefix("/"), filesystemPath != "/",
              let fsidValues =
                environment["filesystem_observation_fsid"] as? [Any],
              fsidValues.count == 2,
              fsidValues.allSatisfy({ value in
                  guard let integer = exactJSONInt64(value) else { return false }
                  return integer >= Int64(Int32.min)
                      && integer <= Int64(Int32.max)
              })
        else {
            throw Stage6ProbeError.contract("PASS device/filesystem identity")
        }
        guard let maxBuffer = exactJSONUInt64(
                environment["metal_device_max_buffer_length_bytes"] as Any),
              let recommended = exactJSONUInt64(
                environment[
                    "metal_device_max_recommended_working_set_bytes"] as Any),
              let registry = exactJSONUInt64(
                environment["metal_device_registry_id"] as Any),
              recommended > 0
        else {
            throw Stage6ProbeError.contract("PASS Metal numeric identity")
        }
        _ = maxBuffer
        _ = registry
        try require(phases.count == 6, "PASS six phases")
        var previousElapsed: UInt64?
        var previousPeak: UInt64?
        var previousMaxRSS: UInt64?
        var physicalCapacity: UInt64?
        for phase in phases {
            try require(phase["availability"] as? String == "observed", "PASS phase observed")
            let elapsed = exactJSONUInt64(
                phase["cumulative_worker_probe_elapsed_nanoseconds"] as Any)!
            let peak = exactJSONUInt64(phase["mlx_peak_bytes"] as Any)!
            let maxRSS = exactJSONUInt64(phase["getrusage_max_rss_bytes"] as Any)!
            let physical = exactJSONUInt64(
                phase["physical_memory_capacity_bytes"] as Any)!
            if let previousElapsed { try require(elapsed > previousElapsed, "PASS elapsed monotonic") }
            if let previousPeak { try require(peak >= previousPeak, "PASS peak monotonic") }
            if let previousMaxRSS { try require(maxRSS >= previousMaxRSS, "PASS maxrss monotonic") }
            previousElapsed = elapsed
            previousPeak = peak
            previousMaxRSS = maxRSS
            physicalCapacity = physicalCapacity ?? physical
        }
        try require(
            exactJSONUInt64(
                phases[0]["filesystem_available_bytes"] as Any)
                ?? 0 >= 12_884_901_888,
            "PASS filesystem preflight floor")
        try require(environment["metal_device_count"] as? Int == 1
            || exactJSONUInt64(environment["metal_device_count"] as Any) == 1,
            "PASS singleton Metal")
        try require(exactJSONUInt64(environment["metal_device_index"] as Any) == 0, "PASS Metal index")
        try require(exactJSONBool(environment["metal_device_is_default"] as Any) == true, "PASS default Metal")
        try require(exactJSONBool(environment["metal_device_has_unified_memory"] as Any) == true, "PASS unified memory")
        try require(exactJSONBool(environment["mlx_cpu_fallback_used"] as Any) == false, "PASS no CPU fallback")
        try require(exactJSONBool(environment["mlx_default_device_is_supplied_device"] as Any) == true, "PASS MLX device identity")
        try require(exactJSONBool(environment["mlx_default_stream_is_gpu"] as Any) == true, "PASS GPU stream")
        try require(exactJSONUInt64(environment["mlx_device_constructor_index"] as Any) == 0, "PASS MLX index")
        try require(environment["mlx_device_type"] as? String == "gpu", "PASS MLX device type")
        try require(exactJSONBool(lease["acquired_before_coregraphics_metal_or_mlx"] as Any) == true
            && exactJSONBool(lease["acquired_nonblocking"] as Any) == true
            && exactJSONBool(lease["held_through_candidate_flush"] as Any) == true
            && exactJSONBool(lease["held_through_postflight"] as Any) == true
            && exactJSONBool(lease["worker_owned"] as Any) == true,
            "PASS lease")
        let limitExpectations: [String: UInt64] = [
            "available_filesystem_floor_bytes": 12_884_901_888,
            "configured_cache_limit_bytes": 0,
            "gradient_logical_bytes": 1_084_428_288,
            "minimum_committed_tensor_state_bytes": 3_253_284_864,
            "minimum_memory_limit_floor_bytes": 4_337_713_152,
            "minimum_state_plus_gradient_bytes": 4_337_713_152,
            "optimizer_moment_logical_bytes": 2_168_856_576,
            "optimizer_moment_tensor_count": 436,
            "supervisor_end_to_end_timeout_seconds": 1_500,
            "termination_grace_seconds": 10,
            "three_times_committed_state_disk_comparator_bytes": 9_759_854_592,
            "validated_parameter_path_count": 218,
            "validated_unique_parameter_count": 271_107_072,
            "validated_weights_logical_bytes": 1_084_428_288,
            "validated_gradient_path_count": 218,
            "validated_gradient_logical_bytes": 1_084_428_288,
            "validated_first_moment_tensor_count": 218,
            "validated_second_moment_tensor_count": 218,
            "validated_optimizer_moment_logical_bytes": 2_168_856_576,
            "weights_logical_bytes": 1_084_428_288,
            "worker_active_timeout_seconds": 1_200,
        ]
        for (key, expected) in limitExpectations {
            try require(exactJSONUInt64(limits[key] as Any) == expected, "PASS limit \(key)")
        }
        let configured = exactJSONUInt64(limits["configured_memory_limit_bytes"] as Any)
        try require(configured != nil && configured! >= 4_337_713_152, "PASS memory floor")
        try require(
            exactJSONUInt64(limits["configured_memory_limit_readback_bytes"] as Any) == configured,
            "PASS memory readback")
        try require(exactJSONUInt64(limits["configured_cache_limit_readback_bytes"] as Any) == 0, "PASS cache readback")
        try require(
            configured == min(UInt64(17_179_869_184), recommended),
            "PASS memory formula result")
        try require(limits["configured_memory_limit_formula"] as? String
            == "min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)",
            "PASS memory formula")
        try require(exactJSONBool(
            limits["container_headers_and_manifests_included_in_minimum"] as Any)
            == false
            && exactJSONBool(
                limits[
                    "duplicate_materializations_graphs_and_temporary_buffers_included_in_minimum"]
                    as Any) == false
            && exactJSONBool(limits["mlx_limit_is_not_rss_limit"] as Any)
                == true
            && exactJSONBool(limits["statfs_is_observational_only"] as Any)
                == true,
            "PASS analytic limit flags")
        try require(physicalCapacity != nil, "PASS physical capacity observed")
        try require(outcome["status"] as? String == "PASS"
            && outcome["classification"] as? String == "pass"
            && exactJSONBool(outcome["one_shot_consumed"] as Any) == true
            && exactJSONBool(outcome["resource_clearance_established"] as Any) == true
            && exactJSONBool(outcome["resource_envelope_established"] as Any) == true
            && exactJSONBool(outcome["resource_probe_executed"] as Any) == true
            && exactJSONBool(outcome["runner_memory_capacity_established"] as Any) == true
            && exactJSONBool(outcome["update_occurred"] as Any) == true
            && exactJSONBool(outcome["worker_candidate_present"] as Any) == true,
            "PASS outcome flags")
        guard let before = outcome["parameter_fingerprint_before"] as? String,
              let after = outcome["parameter_fingerprint_after"] as? String,
              let plan = outcome["parameter_fingerprint_sample_plan_sha256"] as? String
        else { throw Stage6ProbeError.contract("PASS fingerprints") }
        try require(isLowercaseHex(before, count: 64) && isLowercaseHex(after, count: 64)
            && isLowercaseHex(plan, count: 64) && before != after,
            "PASS fingerprint values")
        try require(exactJSONUInt64(outcome["parameter_fingerprint_sample_count"] as Any) == 654,
            "PASS fingerprint sample count")
        guard let lossBits = exactJSONUInt64(outcome["loss_float32_bits"] as Any),
              let normBits = exactJSONUInt64(outcome["raw_gradient_norm_float32_bits"] as Any),
              let scaleBits = exactJSONUInt64(outcome["gradient_clip_scale_float32_bits"] as Any),
              lossBits <= UInt64(UInt32.max), normBits <= UInt64(UInt32.max),
              scaleBits <= UInt64(UInt32.max)
        else { throw Stage6ProbeError.contract("PASS float bits") }
        let loss = Float32(bitPattern: UInt32(lossBits))
        let norm = Float32(bitPattern: UInt32(normBits))
        let scale = Float32(bitPattern: UInt32(scaleBits))
        try require(loss.isFinite && norm.isFinite && norm > 0 && scale.isFinite && scale > 0,
            "PASS finite loss norm scale")
        let expectedScale: Float32 = norm < 1 ? 1 : 1 / (norm + Float32(1e-6))
        try require(scale.bitPattern == expectedScale.bitPattern, "PASS clip scale")
        try require(exactJSONBool(outcome["postflight_device_identity_matches_preflight"] as Any) == true
            && exactJSONBool(outcome["postflight_mlx_policy_and_limits_match_preflight"] as Any) == true,
            "PASS postflight")
    }
}

private func validateMetallibBinding(_ bindings: LauncherBindings) throws {
    let url = URL(fileURLWithPath: bindings.metallibPath)
        .resolvingSymlinksInPath().standardizedFileURL
    try require(url.path == bindings.metallibPath, "metallib physical path")
    let data = try Data(contentsOf: url, options: [.mappedIfSafe])
    try require(UInt64(data.count) == bindings.metallibBytes, "metallib byte count")
    try require(
        PrimeSHA256.hexDigest(of: data) == bindings.metallibSHA256,
        "metallib SHA-256")
}

private func observeExecutableFilesystem(
    emitter: WorkerProgressEmitter
) throws -> FilesystemObservation {
    let executable = URL(fileURLWithPath: CommandLine.arguments[0])
        .resolvingSymlinksInPath().standardizedFileURL
    let parent = executable.deletingLastPathComponent()
    let path = parent.path
    try require(executable.path.hasPrefix("/"), "executable absolute path")
    try require(path.hasPrefix("/") && path != "/", "filesystem target path")
    try require(!path.hasSuffix("/") && !path.contains("/../")
        && !path.contains("/./"), "filesystem target normalization")
    let executableStat = try statFSAtPath(
        executable.path, directory: false, emitter: emitter)
    let parentStat = try statFSAtPath(
        path, directory: true, emitter: emitter)
    let executableFSID = [
        executableStat.f_fsid.val.0,
        executableStat.f_fsid.val.1,
    ]
    let parentFSID = [parentStat.f_fsid.val.0, parentStat.f_fsid.val.1]
    try require(executableFSID == parentFSID, "executable and parent FSID")
    return try filesystemObservation(
        path: path,
        expectedFSID: parentFSID,
        emitter: emitter)
}

private func filesystemObservation(
    path: String,
    expectedFSID: [Int32],
    emitter: WorkerProgressEmitter
) throws -> FilesystemObservation {
    let information = try statFSAtPath(
        path, directory: true, emitter: emitter)
    let fsid = [information.f_fsid.val.0, information.f_fsid.val.1]
    try require(fsid == expectedFSID, "phase FSID drift")
    let blockSize = try nonnegativeUInt64(
        information.f_bsize, field: "statfs block size")
    let blocks = try nonnegativeUInt64(
        information.f_blocks, field: "statfs blocks")
    let availableBlocks = try nonnegativeUInt64(
        information.f_bavail, field: "statfs available blocks")
    let capacity = blocks.multipliedReportingOverflow(by: blockSize)
    let available = availableBlocks.multipliedReportingOverflow(by: blockSize)
    try require(!capacity.overflow && !available.overflow, "statfs multiplication")
    return FilesystemObservation(
        path: path,
        fsid: fsid,
        capacityBytes: capacity.partialValue,
        availableBytes: available.partialValue)
}

private func nonnegativeUInt64<T: BinaryInteger>(
    _ value: T,
    field: String
) throws -> UInt64 {
    guard value >= .zero, let converted = UInt64(exactly: value) else {
        throw ClassifiedProbeError(
            classification: "topology_dtype",
            detail: "\(field) nonnegative representable UInt64")
    }
    return converted
}

private func statFSAtPath(
    _ path: String,
    directory: Bool,
    emitter: WorkerProgressEmitter
) throws -> statfs {
    try emitter.emitProgress()
    let descriptor = Darwin.open(
        path,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW | (directory ? O_DIRECTORY : 0))
    guard descriptor >= 0 else {
        throw Stage6ProbeError.posix("open for fstatfs", errno)
    }
    defer { _ = Darwin.close(descriptor) }
    var information = statfs()
    try emitter.emitProgress()
    guard fstatfs(descriptor, &information) == 0 else {
        throw Stage6ProbeError.posix("fstatfs", errno)
    }
    return information
}

private func observePhase(
    named phase: String,
    epoch: Stage6Instant,
    metalDevice: any MTLDevice,
    filesystem: FilesystemObservation,
    emitter: WorkerProgressEmitter
) throws -> PhaseObservation {
    var taskInformation = task_vm_info_data_t()
    var taskInformationCount = mach_msg_type_number_t(
        MemoryLayout<task_vm_info_data_t>.size
            / MemoryLayout<natural_t>.size)
    try emitter.emitProgress()
    let taskResult: kern_return_t = withUnsafeMutablePointer(
        to: &taskInformation
    ) { pointer in
        pointer.withMemoryRebound(
            to: integer_t.self,
            capacity: Int(taskInformationCount)
        ) { rebound in
            task_info(
                mach_task_self_,
                task_flavor_t(TASK_VM_INFO),
                rebound,
                &taskInformationCount)
        }
    }
    try require(taskResult == KERN_SUCCESS, "TASK_VM_INFO")

    var usage = rusage()
    try emitter.emitProgress()
    guard getrusage(RUSAGE_SELF, &usage) == 0 else {
        throw Stage6ProbeError.posix("getrusage", errno)
    }
    try require(usage.ru_maxrss >= 0, "getrusage maxrss")
    try emitter.emitProgress()
    let active = MLX.Memory.activeMemory
    try emitter.emitProgress()
    let cache = MLX.Memory.cacheMemory
    try emitter.emitProgress()
    let peak = MLX.Memory.peakMemory
    try require(active >= 0 && cache >= 0 && peak >= 0, "MLX memory metrics")
    try emitter.emitProgress()
    let currentFilesystem = try filesystemObservation(
        path: filesystem.path,
        expectedFSID: filesystem.fsid,
        emitter: emitter)
    try emitter.emitProgress()
    let physicalMemory = ProcessInfo.processInfo.physicalMemory
    try emitter.emitProgress()
    let currentAllocatedSize = metalDevice.currentAllocatedSize
    let now = stage6Now()
    let elapsed = try checkedElapsedNanoseconds(
        from: epoch,
        through: now)
    try require(elapsed > 0, "phase elapsed")
    return PhaseObservation(
        phase: phase,
        elapsedNanoseconds: elapsed,
        physicalMemoryCapacityBytes: physicalMemory,
        taskResidentBytes: UInt64(taskInformation.resident_size),
        taskPhysicalFootprintBytes: UInt64(taskInformation.phys_footprint),
        getrusageMaxRSSBytes: UInt64(usage.ru_maxrss),
        mlxActiveBytes: UInt64(active),
        mlxCacheBytes: UInt64(cache),
        mlxPeakBytes: UInt64(peak),
        metalCurrentAllocatedBytes: UInt64(currentAllocatedSize),
        filesystemCapacityBytes: currentFilesystem.capacityBytes,
        filesystemAvailableBytes: currentFilesystem.availableBytes)
}

private func validatedCatalog(
    _ parameters: ModuleParameters,
    expectedPathCount: Int,
    expectedElementCount: UInt64,
    scope: String
) throws -> [(String, MLXArray)] {
    let catalog = parameters.flattened().sorted {
        $0.0.utf8.lexicographicallyPrecedes($1.0.utf8)
    }
    try require(catalog.count == expectedPathCount, "\(scope) path count")
    try require(Set(catalog.map(\.0)).count == catalog.count, "\(scope) paths")
    var elements: UInt64 = 0
    for (path, array) in catalog {
        try require(!path.isEmpty, "\(scope) empty path")
        try require(array.dtype == .float32, "\(scope) dtype")
        try require(array.size >= 3, "\(scope) sample size")
        let addition = elements.addingReportingOverflow(UInt64(array.size))
        try require(!addition.overflow, "\(scope) element overflow")
        elements = addition.partialValue
    }
    try require(elements == expectedElementCount, "\(scope) element count")
    return catalog
}

private func validateMoments(
    _ moments: [MLXArray],
    modelCatalog: [(String, MLXArray)]
) throws {
    try require(moments.count == 436, "optimizer innerState count")
    var firstElements: UInt64 = 0
    var secondElements: UInt64 = 0
    var firstShapes = [String: Int]()
    var secondShapes = [String: Int]()
    var modelShapes = [String: Int]()
    for (_, parameter) in modelCatalog {
        modelShapes[shapeKey(parameter.shape), default: 0] += 1
    }
    for pair in 0 ..< 218 {
        let first = moments[pair * 2]
        let second = moments[pair * 2 + 1]
        try require(first.dtype == .float32 && second.dtype == .float32,
            "optimizer moment dtype")
        try require(first.shape == second.shape, "optimizer adjacent pair shape")
        firstElements += UInt64(first.size)
        secondElements += UInt64(second.size)
        firstShapes[shapeKey(first.shape), default: 0] += 1
        secondShapes[shapeKey(second.shape), default: 0] += 1
    }
    try require(firstElements == 271_107_072
        && secondElements == 271_107_072,
        "optimizer moment parity")
    try require(firstShapes == modelShapes && secondShapes == modelShapes,
        "optimizer moment shape multiset")
}

private func shapeKey(_ shape: [Int]) -> String {
    shape.map(String.init).joined(separator: "x")
}

private func makeFingerprintPlan(
    _ catalog: [(String, MLXArray)],
    emitter: WorkerProgressEmitter
) throws -> FingerprintPlan {
    var views = [MLXArray]()
    var indices = [[Int]]()
    views.reserveCapacity(catalog.count * 3)
    indices.reserveCapacity(catalog.count)
    for (_, array) in catalog {
        let samples = Array(Set([0, array.size / 2, array.size - 1])).sorted()
        try require(samples.count == 3, "fingerprint sample indices")
        try emitter.emitProgress()
        let flattened = array.flattened()
        for index in samples {
            try emitter.emitProgress()
            let sampleView = flattened[index]
            views.append(sampleView)
        }
        indices.append(samples)
    }
    try require(views.count == 654, "fingerprint sample view count")
    return FingerprintPlan(
        catalog: catalog,
        sampleViews: views,
        sampleIndices: indices)
}

private func finalizeFingerprint(
    _ plan: FingerprintPlan,
    emitter: WorkerProgressEmitter
) throws -> FingerprintResult {
    let algorithm =
        "prime_stage6_parameter_catalog_sample_f32be_sha256_v1"
    var valueStream = Data(algorithm.utf8)
    valueStream.append(0)
    var planStream = Data(algorithm.utf8)
    planStream.append(0)
    var viewIndex = 0
    for (catalogIndex, entry) in plan.catalog.enumerated() {
        let pathBytes = Array(entry.0.utf8)
        appendBigEndian(UInt64(pathBytes.count), to: &valueStream)
        appendBigEndian(UInt64(pathBytes.count), to: &planStream)
        valueStream.append(contentsOf: pathBytes)
        planStream.append(contentsOf: pathBytes)
        appendBigEndian(UInt64(entry.1.shape.count), to: &valueStream)
        appendBigEndian(UInt64(entry.1.shape.count), to: &planStream)
        for dimension in entry.1.shape {
            appendBigEndian(UInt64(dimension), to: &valueStream)
            appendBigEndian(UInt64(dimension), to: &planStream)
        }
        let samples = plan.sampleIndices[catalogIndex]
        appendBigEndian(UInt64(samples.count), to: &valueStream)
        appendBigEndian(UInt64(samples.count), to: &planStream)
        for sample in samples {
            appendBigEndian(UInt64(sample), to: &valueStream)
            appendBigEndian(UInt64(sample), to: &planStream)
            try emitter.emitProgress()
            let value = plan.sampleViews[viewIndex].item(Float32.self)
            try require(value.isFinite, "fingerprint finite sample")
            appendBigEndian(value.bitPattern, to: &valueStream)
            viewIndex += 1
        }
    }
    try require(viewIndex == 654, "fingerprint finalized sample count")
    return FingerprintResult(
        fingerprint: PrimeSHA256.hexDigest(of: valueStream),
        planSHA256: PrimeSHA256.hexDigest(of: planStream),
        sampleCount: viewIndex)
}

private func appendBigEndian<T: FixedWidthInteger>(
    _ value: T,
    to data: inout Data
) {
    var bigEndian = value.bigEndian
    withUnsafeBytes(of: &bigEndian) {
        data.append(contentsOf: $0)
    }
}

private func setCloseOnExec(_ descriptor: Int32) throws {
    let flags = fcntl(descriptor, F_GETFD)
    guard flags >= 0,
          fcntl(descriptor, F_SETFD, flags | FD_CLOEXEC) == 0
    else {
        throw Stage6ProbeError.posix("fcntl FD_CLOEXEC", errno)
    }
}

private func falseCeiling() -> [String: Any] {
    let keys = [
        "additional_execution_or_rerun_authorized",
        "artifact_upload_authorized", "broad_native300m_training_authorized",
        "candidate_admission_granted", "canary_authorized",
        "checkpoint_admission_granted", "downstream_trial_authorized",
        "durable_checkpoint_io_authorized",
        "exact_metal_gradient_bytes_established",
        "metal_determinism_established", "model_quality_established",
        "product_use_authorized", "publication_authorized",
        "quantization_authorized", "ordinary_job_fit_established",
        "repeated_trajectory_determinism_established",
        "retained_artifact_authorized", "stage5_assay_clearance_established",
        "stage5_mechanics_success_established",
        "stage5_replacement_execution_authorized",
        "stage5_result_established", "stage7_authority_established",
        "stage7_authorized", "general_training_resume_established",
        "native300m_trajectory_training_resume_established",
    ]
    return Dictionary(uniqueKeysWithValues: keys.map { ($0, false) })
}

private func configurationReceipt() throws -> [String: Any] {
    let tokens = [1] + (0 ..< 127).map { 2 + (($0 * 73 + 44) % 510) }
    let tokenHash = PrimeSHA256.hexDigest(
        of: try PrimeCanonicalJSON.encode([tokens]))
    return [
        "adamw_beta1_float32_bits": Float32(0.9).bitPattern,
        "adamw_beta2_float32_bits": Float32(0.999).bitPattern,
        "adamw_bias_correction_applied": false,
        "adamw_epsilon_float32_bits": Float32(1e-8).bitPattern,
        "adamw_learning_rate_float32_bits": Float32(1e-4).bitPattern,
        "adamw_weight_decay_float32_bits": Float32(0.01).bitPattern,
        "batch_size": 1,
        "batch_token_ids_sha256": tokenHash,
        "completion_mask_dtype": "bool",
        "cross_entropy_api":
            "MLXNN.crossEntropy(logits:targets:weights:axis:labelSmoothing:reduction:)",
        "cross_entropy_reduction": "none",
        "gradient_accumulation_count": 1,
        "gradient_clip_algorithm_id": "prime_stage6_global_norm_clip_f32_v1",
        "gradient_clip_mode": "global_l2_norm_clip_once_before_adamw_update",
        "gradient_norm_epsilon_float32_bits": Float32(1e-6).bitPattern,
        "initialization_seed": 44,
        "logits_dtype": "float32",
        "loss_dtype": "float32",
        "loss_graph_algorithm_id":
            "prime_stage6_causal_masked_mean_cross_entropy_f32_v1",
        "maximum_gradient_norm_float32_bits": Float32(1).bitPattern,
        "model_configuration_factory": "native300MInventory(vocabularySize:)",
        "model_factory": "make(configuration:seed:)",
        "optimizer_qualified_type": "MLXOptimizers.AdamW",
        "optimizer_state_inspection_api": "MLXOptimizers.AdamW.innerState()",
        "optimizer_state_pair_topology":
            "218_adjacent_[first_moment,second_moment]_pairs_from_TupleState.innerState",
        "optimizer_step_count": 1,
        "parameter_dtype": "float32",
        "parameter_path_count": 218,
        "parameter_fingerprint_algorithm_id":
            "prime_stage6_parameter_catalog_sample_f32be_sha256_v1",
        "parameter_fingerprint_expected_path_count": 218,
        "parameter_fingerprint_expected_sample_count": 654,
        "parameter_fingerprint_samples_per_path": 3,
        "per_target_loss_dtype": "float32",
        "per_target_loss_expected_element_count": 127,
        "per_target_loss_expected_shape": [1, 127],
        "raw_gradient_norm_algorithm_id":
            "prime_stage6_global_f32_l2_norm_utf8_catalog_v1",
        "selected_target_count": 127,
        "sequence_length": 128,
        "token_id_dtype": "int32",
        "training_logits_api": "PrimeNativeGQADecoder.trainingLogitsNoCache",
        "unique_parameter_count": UInt64(271_107_072),
        "valid_token_count": 128,
        "value_and_grad_api": "MLXNN.valueAndGrad(model:_:)",
        "post_model_full_state_evaluation_api":
            "checkedEval(model,before_fingerprint_sample_views)",
        "post_update_full_state_evaluation_api":
            "checkedEval(model,optimizer,after_fingerprint_sample_views)",
    ]
}

private func validateFinalReceiptShape(_ object: Any) throws {
    guard let receipt = object as? [String: Any] else {
        throw Stage6ProbeError.contract("receipt object")
    }
    let authority =
        PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1
            .frozenV1.receiptContract
    try require(Set(receipt.keys) == Set(authority.topLevelKeys), "receipt top keys")
    let nested: [(String, [String])] = [
        ("authority", authority.authorityKeys),
        ("ceiling", authority.ceilingKeys),
        ("configuration", authority.configurationKeys),
        ("environment", authority.environmentKeys),
        ("execution", authority.executionKeys),
        ("lease", authority.leaseKeys),
        ("limits", authority.limitsKeys),
        ("outcome", authority.outcomeKeys),
    ]
    for (name, keys) in nested {
        guard let value = receipt[name] as? [String: Any] else {
            throw Stage6ProbeError.contract("receipt \(name)")
        }
        try require(Set(value.keys) == Set(keys), "receipt \(name) keys")
    }
    guard let outcome = receipt["outcome"] as? [String: Any],
          let counts = outcome["operation_counts"] as? [String: Any],
          let phases = receipt["phase_metrics"] as? [[String: Any]]
    else {
        throw Stage6ProbeError.contract("receipt outcomes")
    }
    try require(Set(counts.keys) == Set(authority.operationCountKeys), "operation keys")
    try require(phases.count == 6, "six phase rows")
    for (index, phase) in phases.enumerated() {
        try require(Set(phase.keys) == Set(authority.phaseMetricKeys), "phase keys")
        try require(
            phase["phase"] as? String == authority.phaseNames[index],
            "phase order")
    }
}

private struct ClassifiedProbeError: Error {
    let classification: String
    let detail: String
}

private func isExplicitOutOfMemoryError(_ error: Error) -> Bool {
    isExplicitOutOfMemorySignature(String(describing: error))
}

private func isExplicitOutOfMemorySignature(_ description: String) -> Bool {
    let signature = description.lowercased()
    func containsUnsignedDecimal(
        prefix: String,
        suffix: String
    ) -> Bool {
        guard let prefixRange = signature.range(of: prefix) else {
            return false
        }
        let tail = signature[prefixRange.upperBound...]
        guard let suffixRange = tail.range(of: suffix) else { return false }
        let digits = tail[..<suffixRange.lowerBound]
        return !digits.isEmpty && digits.allSatisfy(\.isNumber)
    }
    return containsUnsignedDecimal(
        prefix: "[metal::malloc] resource limit (",
        suffix: ") exceeded.")
        || containsUnsignedDecimal(
            prefix: "[malloc] unable to allocate ",
            suffix: " bytes.")
}

private func candidateRequiresExecutorReceiptDrift(
    observedCandidateCount: Int,
    candidateAccepted: Bool
) -> Bool {
    observedCandidateCount > 0 && !candidateAccepted
}

private struct FilesystemObservation {
    let path: String
    let fsid: [Int32]
    let capacityBytes: UInt64
    let availableBytes: UInt64
}

private struct PhaseObservation {
    let phase: String
    let elapsedNanoseconds: UInt64
    let physicalMemoryCapacityBytes: UInt64
    let taskResidentBytes: UInt64
    let taskPhysicalFootprintBytes: UInt64
    let getrusageMaxRSSBytes: UInt64
    let mlxActiveBytes: UInt64
    let mlxCacheBytes: UInt64
    let mlxPeakBytes: UInt64
    let metalCurrentAllocatedBytes: UInt64
    let filesystemCapacityBytes: UInt64
    let filesystemAvailableBytes: UInt64

    var dictionary: [String: Any] {
        [
            "phase": phase,
            "availability": "observed",
            "unavailable_reason": NSNull(),
            "cumulative_worker_probe_elapsed_nanoseconds": elapsedNanoseconds,
            "physical_memory_capacity_bytes": physicalMemoryCapacityBytes,
            "task_resident_bytes": taskResidentBytes,
            "task_physical_footprint_bytes": taskPhysicalFootprintBytes,
            "getrusage_max_rss_bytes": getrusageMaxRSSBytes,
            "mlx_active_bytes": mlxActiveBytes,
            "mlx_cache_bytes": mlxCacheBytes,
            "mlx_peak_bytes": mlxPeakBytes,
            "metal_current_allocated_bytes": metalCurrentAllocatedBytes,
            "filesystem_capacity_bytes": filesystemCapacityBytes,
            "filesystem_available_bytes": filesystemAvailableBytes,
        ]
    }
}

private struct PureSwiftProbeObservation {
    let lossFloat32Bits: UInt32
    let rawGradientNormFloat32Bits: UInt32
    let gradientClipScaleFloat32Bits: UInt32
    let parameterFingerprintBefore: String
    let parameterFingerprintAfter: String
    let parameterFingerprintSamplePlanSHA256: String
    let parameterFingerprintSampleCount: Int
    let updateOccurred: Bool
}

private struct ModelMaterializationObservation {
    let fingerprint: String
    let samplePlanSHA256: String
    let sampleCount: Int
    let parameterPaths: [String]
}

private struct EvaluatedClippedGradientObservation {
    let clippedGradients: ModuleParameters
    let lossFloat32Bits: UInt32
    let rawGradientNormFloat32Bits: UInt32
    let gradientClipScaleFloat32Bits: UInt32
}

private final class WorkerProgressEmitter {
    let writer: WorkerFrameWriter
    var payload: WorkerPayload

    init(writer: WorkerFrameWriter, bindings: LauncherBindings) {
        self.writer = writer
        payload = WorkerPayload(bindings: bindings)
    }

    func emitProgress() throws {
        payload.setOutcome(
            status: "ABSTAIN",
            classification: "executor_receipt_drift",
            candidatePresent: false)
        try writer.write(kind: "progress", payload: payload.framePayload())
    }

    func emitTerminalProgress(
        classification: String,
        fatal: Bool
    ) throws {
        payload.setOutcome(
            status: "ABSTAIN",
            classification: classification,
            candidatePresent: false)
        payload.finishPhases(classification: classification, fatal: fatal)
        try writer.write(kind: "progress", payload: payload.framePayload())
    }
}

private struct FingerprintPlan {
    let catalog: [(String, MLXArray)]
    let sampleViews: [MLXArray]
    let sampleIndices: [[Int]]
}

private struct FingerprintResult {
    let fingerprint: String
    let planSHA256: String
    let sampleCount: Int
}

private struct LossAndGradientGraph {
    let loss: MLXArray
    let gradients: ModuleParameters
}

private final class LossShapeValidation: @unchecked Sendable {
    var exact = true
}

extension PrimeNativeDecoderNative300MResourceOnlyOneStepProbe {
    fileprivate static func runWorkerProcess(epoch: Stage6Instant) -> Never {
        // `epoch` was sampled as the first process-entry instruction, before
        // worker recognition, command-line decoding, and the lease attempt.
        let environment = ProcessInfo.processInfo.environment
        let descriptorPrefix = "--frame-descriptor="
        guard let descriptorArgument = CommandLine.arguments.first(where: {
            $0.hasPrefix(descriptorPrefix)
        }),
              let descriptor = Int32(
                descriptorArgument.dropFirst(descriptorPrefix.count)),
              descriptor == workerFrameDescriptor
        else {
            _exit(70)
        }

        do {
            let bindings = try LauncherBindings(environment: environment)
            let writer = WorkerFrameWriter(descriptor: descriptor)
            let emitter = WorkerProgressEmitter(writer: writer, bindings: bindings)
            var lease: PrimeMetalDeviceLease?
            do {
                try emitter.emitProgress()
                do {
                    lease = try PrimeMetalDeviceLease.acquire(at:
                        URL(fileURLWithPath: bindings.leasePath))
                } catch PrimeMetalDeviceLeaseError.busy {
                    try emitter.emitTerminalProgress(
                        classification: "lease_busy", fatal: false)
                    _ = Darwin.close(descriptor)
                    _exit(0)
                }
                guard let lease, lease.isHeld else {
                    throw ClassifiedProbeError(
                        classification: "topology_dtype",
                        detail: "lease not held")
                }
                emitter.payload.lease["acquired_before_coregraphics_metal_or_mlx"] = true
                emitter.payload.lease["worker_owned"] = true
                try emitter.emitProgress()

                try emitter.emitProgress()
                try validateMetallibBinding(bindings)
                try emitter.emitProgress()
                let instrumentation = try PrimeReleaseInstrumentationAdmissionPolicy
                    .observeCurrentProcess()
                try emitter.emitProgress()
                _ = try PrimeReleaseInstrumentationAdmissionPolicy.validate(
                    observation: instrumentation)
                try emitter.emitProgress()
                _ = try PrimeNativeDecoderCIMLXComputeEnvironmentPolicy
                    .validateLaunched(environment: environment)

                try emitter.emitProgress()
                let metalDevices = MTLCopyAllDevices()
                try emitter.emitProgress()
                let defaultMetalDevice = MTLCreateSystemDefaultDevice()
                guard metalDevices.count == 1,
                      let defaultMetalDevice
                else {
                    throw ClassifiedProbeError(
                        classification: "topology_dtype",
                        detail: "Metal singleton topology")
                }
                let retainedMTLDevice = metalDevices[0]
                guard retainedMTLDevice.registryID == defaultMetalDevice.registryID,
                      retainedMTLDevice.hasUnifiedMemory,
                      retainedMTLDevice.recommendedMaxWorkingSetSize > 0
                else {
                    throw ClassifiedProbeError(
                        classification: "topology_dtype",
                        detail: "Metal device identity or unified memory")
                }
                emitter.payload.environment.merge([
                    "metal_device_count": 1,
                    "metal_device_index": 0,
                    "metal_device_is_default": true,
                    "metal_device_max_buffer_length_bytes":
                        UInt64(retainedMTLDevice.maxBufferLength),
                    "metal_device_max_recommended_working_set_bytes":
                        UInt64(retainedMTLDevice.recommendedMaxWorkingSetSize),
                    "metal_device_has_unified_memory":
                        retainedMTLDevice.hasUnifiedMemory,
                    "metal_device_name": retainedMTLDevice.name,
                    "metal_device_registry_id": retainedMTLDevice.registryID,
                ], uniquingKeysWith: { _, new in new })
                try emitter.emitProgress()

                let filesystem = try observeExecutableFilesystem(
                    emitter: emitter)
                emitter.payload.environment.merge([
                    "filesystem_observation_fsid": filesystem.fsid,
                    "filesystem_observation_path": filesystem.path,
                ], uniquingKeysWith: { _, new in new })
                try emitter.emitProgress()
                let executionDevice = Device(.gpu, index: Int32(0))
                try emitter.emitProgress()
                try Device.withDefaultDevice(executionDevice) {
                    try emitter.emitProgress()
                    guard executionDevice.deviceType == .gpu,
                          Device.defaultDevice() === executionDevice,
                          Stream() == Stream.gpu
                    else {
                        throw ClassifiedProbeError(
                            classification: "topology_dtype",
                            detail: "MLX execution policy")
                    }
                    emitter.payload.environment.merge([
                        "mlx_cpu_fallback_used": false,
                        "mlx_default_device_is_supplied_device": true,
                        "mlx_default_stream_is_gpu": true,
                        "mlx_device_constructor_index": 0,
                        "mlx_device_type": "gpu",
                    ], uniquingKeysWith: { _, new in new })

                    let configuredMemoryLimit = min(
                        UInt64(17_179_869_184),
                        UInt64(retainedMTLDevice.recommendedMaxWorkingSetSize))
                    guard configuredMemoryLimit <= UInt64(Int.max) else {
                        throw ClassifiedProbeError(
                            classification: "topology_dtype",
                            detail: "memory limit conversion")
                    }
                    try emitter.emitProgress()
                    MLX.Memory.memoryLimit = Int(configuredMemoryLimit)
                    try emitter.emitProgress()
                    MLX.Memory.cacheLimit = 0
                    try emitter.emitProgress()
                    let memoryReadback = MLX.Memory.memoryLimit
                    try emitter.emitProgress()
                    let cacheReadback = MLX.Memory.cacheLimit
                    guard memoryReadback >= 0, cacheReadback == 0,
                          UInt64(memoryReadback) == configuredMemoryLimit
                    else {
                        throw ClassifiedProbeError(
                            classification: "topology_dtype",
                            detail: "MLX limit readback")
                    }
                    emitter.payload.limits["configured_memory_limit_bytes"] =
                        configuredMemoryLimit
                    emitter.payload.limits["configured_memory_limit_readback_bytes"] =
                        UInt64(memoryReadback)
                    emitter.payload.limits["configured_cache_limit_readback_bytes"] =
                        UInt64(cacheReadback)
                    try emitter.payload.operationCounts.increment(
                        "mlx_peak_memory_reset_count")
                    try emitter.emitProgress()
                    MLX.Memory.peakMemory = 0

                    let preflight = try observePhase(
                        named: phaseNames[0],
                        epoch: epoch,
                        metalDevice: retainedMTLDevice,
                        filesystem: filesystem,
                        emitter: emitter)
                    emitter.payload.phaseMetrics.append(preflight.dictionary)
                    try emitter.emitProgress()
                    guard configuredMemoryLimit >= 4_337_713_152,
                          preflight.filesystemAvailableBytes >= 12_884_901_888
                    else {
                        try emitter.emitTerminalProgress(
                            classification: "preflight_floor", fatal: false)
                        lease.release()
                        _ = Darwin.close(descriptor)
                        _exit(0)
                    }

                    let observation = try runAllocatedProbe(
                        executionDevice: executionDevice,
                        metalDevice: retainedMTLDevice,
                        filesystem: filesystem,
                        epoch: epoch,
                        emitter: emitter)

                    try emitter.payload.operationCounts.increment(
                        "memory_clear_cache_count")
                    try emitter.emitProgress()
                    MLX.Memory.clearCache()
                    let deallocated = try observePhase(
                        named: phaseNames[5],
                        epoch: epoch,
                        metalDevice: retainedMTLDevice,
                        filesystem: filesystem,
                        emitter: emitter)
                    emitter.payload.phaseMetrics.append(deallocated.dictionary)

                    try emitter.payload.operationCounts.increment(
                        "postflight_device_reenumeration_count")
                    try emitter.emitProgress()
                    let postflightDevices = MTLCopyAllDevices()
                    try emitter.emitProgress()
                    let postflightDefault = MTLCreateSystemDefaultDevice()
                    let deviceMatches = postflightDevices.count == 1
                        && postflightDefault != nil
                        && postflightDevices[0].registryID
                            == retainedMTLDevice.registryID
                        && postflightDefault!.registryID
                            == retainedMTLDevice.registryID
                        && postflightDevices[0].name == retainedMTLDevice.name
                        && postflightDevices[0].hasUnifiedMemory
                        == retainedMTLDevice.hasUnifiedMemory
                        && postflightDevices[0].maxBufferLength
                        == retainedMTLDevice.maxBufferLength
                        && postflightDevices[0].recommendedMaxWorkingSetSize
                        == retainedMTLDevice.recommendedMaxWorkingSetSize
                    let mlxMatches = executionDevice.deviceType == .gpu
                        && Device.defaultDevice() === executionDevice
                        && Stream() == Stream.gpu
                        && MLX.Memory.memoryLimit == memoryReadback
                        && MLX.Memory.cacheLimit == cacheReadback
                        && (try? PrimeNativeDecoderCIMLXComputeEnvironmentPolicy
                            .validateLaunched(environment: environment)) != nil
                    emitter.payload.outcome[
                        "postflight_device_identity_matches_preflight"] =
                        deviceMatches
                    emitter.payload.outcome[
                        "postflight_mlx_policy_and_limits_match_preflight"] =
                        mlxMatches
                    emitter.payload.lease["held_through_postflight"] = lease.isHeld
                    try emitter.emitProgress()
                    guard deviceMatches, mlxMatches, lease.isHeld else {
                        throw ClassifiedProbeError(
                            classification: "topology_dtype",
                            detail: "postflight identity")
                    }
                    guard observation.updateOccurred else {
                        throw ClassifiedProbeError(
                            classification: "no_update",
                            detail: "parameter fingerprint unchanged")
                    }
                }

                emitter.payload.lease["held_through_candidate_flush"] = lease.isHeld
                emitter.payload.setOutcome(
                    status: "PASS",
                    classification: "pass",
                    candidatePresent: true)
                guard lease.isHeld else {
                    throw ClassifiedProbeError(
                        classification: "topology_dtype",
                        detail: "lease lost before candidate")
                }
                try writer.write(kind: "candidate", payload: emitter.payload.framePayload())
                lease.release()
                _ = Darwin.close(descriptor)
                _exit(0)
            } catch {
                let classification: String
                let fatal: Bool
                if let classified = error as? ClassifiedProbeError {
                    classification = classified.classification
                    fatal = false
                } else {
                    classification = isExplicitOutOfMemoryError(error)
                        ? "oom" : "topology_dtype"
                    fatal = classification == "oom"
                }
                try? emitter.emitTerminalProgress(
                    classification: classification,
                    fatal: fatal)
                lease?.release()
                _ = Darwin.close(descriptor)
                _exit(71)
            }
        } catch {
            _ = Darwin.close(descriptor)
            _exit(72)
        }
    }

    @inline(never)
    private static func runAllocatedProbe(
        executionDevice: Device,
        metalDevice: any MTLDevice,
        filesystem: FilesystemObservation,
        epoch: Stage6Instant,
        emitter: WorkerProgressEmitter
    ) throws -> PureSwiftProbeObservation {
        try require(Device.defaultDevice() === executionDevice, "allocated device scope")
        try emitter.emitProgress()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .native300MInventory(vocabularySize: 512)
        try emitter.payload.operationCounts.increment("model_allocation_count")
        try emitter.emitProgress()
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 44)
        try emitter.emitProgress()
        model.train(true)
        try emitter.emitProgress()
        let before = try materializeModelAndFingerprint(
            model: model,
            metalDevice: metalDevice,
            filesystem: filesystem,
            epoch: epoch,
            emitter: emitter)

        let clippedObservation = try runForwardBackwardAndClip(
            model: model,
            expectedModelPaths: before.parameterPaths,
            metalDevice: metalDevice,
            filesystem: filesystem,
            epoch: epoch,
            emitter: emitter)

        try emitter.emitProgress()
        let optimizer = AdamW(
            learningRate: Float32(1e-4),
            betas: (Float32(0.9), Float32(0.999)),
            eps: Float32(1e-8),
            weightDecay: Float32(0.01))
        try emitter.emitProgress()
        guard optimizer.innerState().isEmpty else {
            throw ClassifiedProbeError(
                classification: "topology_dtype",
                detail: "nonempty optimizer state before update")
        }
        try emitter.payload.operationCounts.increment("optimizer_step_count")
        try emitter.payload.operationCounts.increment("adamw_update_count")
        try emitter.emitProgress()
        optimizer.update(
            model: model,
            gradients: clippedObservation.clippedGradients)
        try emitter.emitProgress()
        try emitter.emitProgress()
        let momentArrays = optimizer.innerState()
        try emitter.emitProgress()
        let updatedCatalog = try validatedCatalog(
            model.parameters(),
            expectedPathCount: 218,
            expectedElementCount: 271_107_072,
            scope: "updated model")
        try require(
            updatedCatalog.map(\.0) == before.parameterPaths,
            "updated module parameter paths")
        try validateMoments(momentArrays, modelCatalog: updatedCatalog)
        emitter.payload.limits["validated_first_moment_tensor_count"] = 218
        emitter.payload.limits["validated_second_moment_tensor_count"] = 218
        emitter.payload.limits["validated_optimizer_moment_logical_bytes"] =
            UInt64(2_168_856_576)
        try emitter.emitProgress()
        let afterPlan = try makeFingerprintPlan(
            updatedCatalog,
            emitter: emitter)
        let afterFingerprintSampleViews = afterPlan.sampleViews
        let final: (FingerprintResult, Bool) = try withExtendedLifetime(
            (
                model, optimizer, momentArrays,
                clippedObservation.clippedGradients, updatedCatalog,
                afterFingerprintSampleViews
            )
        ) {
            try emitter.payload.operationCounts.increment(
                "full_graph_evaluation_count")
            try emitter.payload.operationCounts.increment(
                "checked_evaluation_barrier_count")
            try emitter.emitProgress()
            try checkedEval(model, optimizer, afterFingerprintSampleViews)
            try emitter.emitProgress()
            try emitter.payload.operationCounts.increment(
                "gpu_synchronization_barrier_count")
            try emitter.emitProgress()
            Stream.gpu.synchronize()
            try emitter.emitProgress()
            let after = try finalizeFingerprint(afterPlan, emitter: emitter)
            guard after.planSHA256 == before.samplePlanSHA256,
                  after.sampleCount == before.sampleCount
            else {
                throw ClassifiedProbeError(
                    classification: "topology_dtype",
                    detail: "fingerprint plan drift")
            }
            let updateOccurred = after.fingerprint != before.fingerprint
            let postUpdate = try observePhase(
                named: phaseNames[4], epoch: epoch,
                metalDevice: metalDevice,
                filesystem: filesystem,
                emitter: emitter)
            emitter.payload.phaseMetrics.append(postUpdate.dictionary)
            emitter.payload.outcome["parameter_fingerprint_after"] =
                after.fingerprint
            emitter.payload.outcome["update_occurred"] = updateOccurred
            try emitter.emitProgress()
            return (after, updateOccurred)
        }

        return PureSwiftProbeObservation(
            lossFloat32Bits: clippedObservation.lossFloat32Bits,
            rawGradientNormFloat32Bits:
                clippedObservation.rawGradientNormFloat32Bits,
            gradientClipScaleFloat32Bits:
                clippedObservation.gradientClipScaleFloat32Bits,
            parameterFingerprintBefore: before.fingerprint,
            parameterFingerprintAfter: final.0.fingerprint,
            parameterFingerprintSamplePlanSHA256: before.samplePlanSHA256,
            parameterFingerprintSampleCount: before.sampleCount,
            updateOccurred: final.1)
    }

    @inline(never)
    private static func materializeModelAndFingerprint(
        model: PrimeNativeGQADecoder,
        metalDevice: any MTLDevice,
        filesystem: FilesystemObservation,
        epoch: Stage6Instant,
        emitter: WorkerProgressEmitter
    ) throws -> ModelMaterializationObservation {
        try emitter.emitProgress()
        let modelParameters = model.parameters()
        let modelCatalog = try validatedCatalog(
            modelParameters,
            expectedPathCount: 218,
            expectedElementCount: 271_107_072,
            scope: "model")
        let parameterPaths = modelCatalog.map(\.0)
        emitter.payload.limits["validated_parameter_path_count"] = 218
        emitter.payload.limits["validated_unique_parameter_count"] =
            UInt64(271_107_072)
        emitter.payload.limits["validated_weights_logical_bytes"] =
            UInt64(1_084_428_288)
        try emitter.emitProgress()
        let beforePlan = try makeFingerprintPlan(
            modelCatalog,
            emitter: emitter)
        let beforeFingerprintSampleViews = beforePlan.sampleViews
        let result: FingerprintResult = try withExtendedLifetime(
            (model, modelParameters, modelCatalog, beforeFingerprintSampleViews)
        ) {
            try emitter.payload.operationCounts.increment(
                "model_materialization_count")
            try emitter.payload.operationCounts.increment(
                "checked_evaluation_barrier_count")
            try emitter.emitProgress()
            try checkedEval(model, beforeFingerprintSampleViews)
            try emitter.emitProgress()
            try emitter.payload.operationCounts.increment(
                "gpu_synchronization_barrier_count")
            try emitter.emitProgress()
            Stream.gpu.synchronize()
            try emitter.emitProgress()
            let before = try finalizeFingerprint(
                beforePlan,
                emitter: emitter)
            try emitter.emitProgress()
            let postModel = try observePhase(
                named: phaseNames[1],
                epoch: epoch,
                metalDevice: metalDevice,
                filesystem: filesystem,
                emitter: emitter)
            emitter.payload.phaseMetrics.append(postModel.dictionary)
            emitter.payload.outcome["parameter_fingerprint_before"] =
                before.fingerprint
            emitter.payload.outcome[
                "parameter_fingerprint_sample_plan_sha256"] =
                before.planSHA256
            emitter.payload.outcome["parameter_fingerprint_sample_count"] =
                before.sampleCount
            try emitter.emitProgress()
            return before
        }
        return ModelMaterializationObservation(
            fingerprint: result.fingerprint,
            samplePlanSHA256: result.planSHA256,
            sampleCount: result.sampleCount,
            parameterPaths: parameterPaths)
    }

    @inline(never)
    private static func runForwardBackwardAndClip(
        model: PrimeNativeGQADecoder,
        expectedModelPaths: [String],
        metalDevice: any MTLDevice,
        filesystem: FilesystemObservation,
        epoch: Stage6Instant,
        emitter: WorkerProgressEmitter
    ) throws -> EvaluatedClippedGradientObservation {
        var tokens = [Int32(1)]
        tokens.append(contentsOf: (0 ..< 127).map { index in
            Int32(2 + ((index * 73 + 44) % 510))
        })
        let completion = [false] + Array(repeating: true, count: 127)
        try emitter.emitProgress()
        let tokenIDs = MLXArray(tokens, [1, 128])
        try emitter.emitProgress()
        let completionMask = MLXArray(completion, [1, 128])
        let shapeValidation = LossShapeValidation()
        try emitter.payload.operationCounts.increment("value_and_grad_count")
        try emitter.payload.operationCounts.increment("training_logits_count")
        try emitter.payload.operationCounts.increment("cross_entropy_count")
        try emitter.payload.operationCounts.increment("forward_loss_count")
        try emitter.payload.operationCounts.increment("backward_count")
        try emitter.emitProgress()
        let lossAndGradientFunction = valueAndGrad(model: model) {
            model, tokenIDs, completionMask in
            let logits = model.trainingLogitsNoCache(tokenIDs)
            let shiftedLogits = logits[0..., 0 ..< 127, 0...]
            let shiftedTargets = tokenIDs[0..., 1 ..< 128]
            let shiftedCompletionMask = completionMask[0..., 1 ..< 128]
            let perTargetLoss = crossEntropy(
                logits: shiftedLogits,
                targets: shiftedTargets,
                weights: nil,
                axis: -1,
                labelSmoothing: 0,
                reduction: .none)
            if logits.shape != [1, 128, 512] || logits.dtype != .float32
                || shiftedLogits.shape != [1, 127, 512]
                || shiftedTargets.shape != [1, 127]
                || shiftedCompletionMask.shape != [1, 127]
                || perTargetLoss.shape != [1, 127]
                || perTargetLoss.dtype != .float32
            {
                shapeValidation.exact = false
            }
            return MLX.sum(
                perTargetLoss
                    * shiftedCompletionMask.asType(.float32)) / Float32(127)
        }
        try emitter.emitProgress()
        let raw = lossAndGradientFunction(model, tokenIDs, completionMask)
        let lossAndGradient = LossAndGradientGraph(
            loss: raw.0,
            gradients: raw.1)
        guard shapeValidation.exact,
              lossAndGradient.loss.dtype == DType.float32,
              lossAndGradient.loss.ndim == 0
        else {
            throw ClassifiedProbeError(
                classification: "topology_dtype",
                detail: "loss graph shape or dtype")
        }
        try emitter.emitProgress()
        let gradientCatalog = try validatedCatalog(
            lossAndGradient.gradients,
            expectedPathCount: 218,
            expectedElementCount: 271_107_072,
            scope: "gradient")
        try require(
            gradientCatalog.map(\.0) == expectedModelPaths,
            "full module and gradient parameter paths")
        emitter.payload.limits["validated_gradient_path_count"] = 218
        emitter.payload.limits["validated_gradient_logical_bytes"] =
            UInt64(1_084_428_288)
        try emitter.emitProgress()

        let lossValue: Float32 = try withExtendedLifetime(
            (
                model, tokenIDs, completionMask, lossAndGradientFunction,
                lossAndGradient, gradientCatalog
            )
        ) {
            try emitter.payload.operationCounts.increment(
                "checked_evaluation_barrier_count")
            try emitter.emitProgress()
            try checkedEval(lossAndGradient.loss, lossAndGradient.gradients)
            try emitter.emitProgress()
            try emitter.payload.operationCounts.increment(
                "gpu_synchronization_barrier_count")
            try emitter.emitProgress()
            Stream.gpu.synchronize()
            try emitter.emitProgress()
            let value = lossAndGradient.loss.item(Float32.self)
            try emitter.emitProgress()
            guard value.isFinite else {
                throw ClassifiedProbeError(
                    classification: "nonfinite", detail: "loss")
            }
            let postBackward = try observePhase(
                named: phaseNames[2],
                epoch: epoch,
                metalDevice: metalDevice,
                filesystem: filesystem,
                emitter: emitter)
            emitter.payload.phaseMetrics.append(postBackward.dictionary)
            emitter.payload.outcome["loss_float32_bits"] = value.bitPattern
            try emitter.emitProgress()
            return value
        }

        try emitter.payload.operationCounts.increment("gradient_norm_count")
        try emitter.emitProgress()
        var squaredNorm = MLXArray(Float32(0))
        for (_, gradient) in gradientCatalog {
            try emitter.emitProgress()
            let floatGradient = gradient.asType(DType.float32)
            try emitter.emitProgress()
            let squaredGradient = MLX.square(floatGradient)
            try emitter.emitProgress()
            let gradientSum = MLX.sum(squaredGradient)
            try emitter.emitProgress()
            squaredNorm = squaredNorm + gradientSum
        }
        try emitter.emitProgress()
        let rawGradientNorm = MLX.sqrt(squaredNorm)
        try emitter.payload.operationCounts.increment(
            "checked_evaluation_barrier_count")
        try emitter.emitProgress()
        try checkedEval(rawGradientNorm)
        try emitter.emitProgress()
        try emitter.payload.operationCounts.increment(
            "gpu_synchronization_barrier_count")
        try emitter.emitProgress()
        Stream.gpu.synchronize()
        try emitter.emitProgress()
        let normValue = rawGradientNorm.item(Float32.self)
        try emitter.emitProgress()
        guard normValue.isFinite, normValue > 0 else {
            throw ClassifiedProbeError(
                classification: "nonfinite", detail: "gradient norm")
        }
        let clipScale: Float32 = normValue < 1
            ? 1
            : 1 / (normValue + Float32(1e-6))

        try emitter.payload.operationCounts.increment("gradient_clip_count")
        try emitter.emitProgress()
        var clippedCatalog = [(String, MLXArray)]()
        clippedCatalog.reserveCapacity(gradientCatalog.count)
        for (path, gradient) in gradientCatalog {
            if normValue < 1 {
                clippedCatalog.append((path, gradient))
            } else {
                try emitter.emitProgress()
                clippedCatalog.append((path, gradient * clipScale))
            }
        }
        try emitter.emitProgress()
        let clippedGradients = ModuleParameters.unflattened(clippedCatalog)
        try withExtendedLifetime(
            (
                model, tokenIDs, completionMask, lossAndGradientFunction,
                lossAndGradient, gradientCatalog, rawGradientNorm,
                clippedGradients
            )
        ) {
            try emitter.payload.operationCounts.increment(
                "checked_evaluation_barrier_count")
            try emitter.emitProgress()
            try checkedEval(clippedGradients)
            try emitter.emitProgress()
            try emitter.payload.operationCounts.increment(
                "gpu_synchronization_barrier_count")
            try emitter.emitProgress()
            Stream.gpu.synchronize()
            try emitter.emitProgress()
            let postClip = try observePhase(
                named: phaseNames[3],
                epoch: epoch,
                metalDevice: metalDevice,
                filesystem: filesystem,
                emitter: emitter)
            emitter.payload.phaseMetrics.append(postClip.dictionary)
            emitter.payload.outcome["raw_gradient_norm_float32_bits"] =
                normValue.bitPattern
            emitter.payload.outcome["gradient_clip_scale_float32_bits"] =
                clipScale.bitPattern
            try emitter.emitProgress()
        }
        return EvaluatedClippedGradientObservation(
            clippedGradients: clippedGradients,
            lossFloat32Bits: lossValue.bitPattern,
            rawGradientNormFloat32Bits: normValue.bitPattern,
            gradientClipScaleFloat32Bits: clipScale.bitPattern)
    }
}
