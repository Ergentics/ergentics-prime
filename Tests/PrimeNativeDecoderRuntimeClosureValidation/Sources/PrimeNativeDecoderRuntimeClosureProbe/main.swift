// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
import PrimeCore
import PrimeNativeDecoderRuntime

private enum PrimeNativeDecoderRuntimeClosureProbeError:
    Error,
    CustomStringConvertible
{
    case missingEnvironmentValue(String)
    case invalidMetallibByteCount(String)
    case invalidLeasePath(String)

    var description: String {
        switch self {
        case .missingEnvironmentValue(let key):
            "missing required environment value: \(key)"
        case .invalidMetallibByteCount(let value):
            "invalid metallib byte count: \(value)"
        case .invalidLeasePath(let value):
            "invalid Metal lease path: \(value)"
        }
    }
}

private func requiredEnvironmentValue(
    _ key: String,
    environment: [String: String]
) throws -> String {
    guard let value = environment[key], !value.isEmpty else {
        throw PrimeNativeDecoderRuntimeClosureProbeError
            .missingEnvironmentValue(key)
    }
    return value
}

do {
    _ = try
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
            .validateLaunchedCurrentProcess()
    let metallibByteCountKey =
        "PRIME_NATIVE_DECODER_RUNTIME_METALLIB_BYTES"
    let metallibSHA256Key =
        "PRIME_NATIVE_DECODER_RUNTIME_METALLIB_SHA256"
    let metalLeasePathKey =
        "PRIME_NATIVE_DECODER_RUNTIME_METAL_LEASE_PATH"
    let receiptPrefix =
        "PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT="
    let environment = ProcessInfo.processInfo.environment
    let byteCountText = try requiredEnvironmentValue(
        metallibByteCountKey,
        environment: environment
    )
    guard let byteCount = UInt64(byteCountText),
          String(byteCount) == byteCountText else {
        throw PrimeNativeDecoderRuntimeClosureProbeError
            .invalidMetallibByteCount(byteCountText)
    }
    let sha256 = try requiredEnvironmentValue(
        metallibSHA256Key,
        environment: environment
    )
    let leasePath = try requiredEnvironmentValue(
        metalLeasePathKey,
        environment: environment
    )
    guard leasePath.hasPrefix("/"),
          !leasePath.hasSuffix("/") else {
        throw PrimeNativeDecoderRuntimeClosureProbeError
            .invalidLeasePath(leasePath)
    }

    let expectation = try
        PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1(
            byteCount: byteCount,
            sha256: sha256
        )
    let evidence = try PrimeNativeDecoderRuntime
        .initializeCurrentProcess(
            metallibExpectation: expectation,
            metalLeaseURL: URL(fileURLWithPath: leasePath)
        )
    try evidence.validate()
    let receiptBytes = try PrimeCanonicalJSON.encode(evidence)
    guard let receipt = String(
        data: receiptBytes,
        encoding: .utf8
    ) else {
        throw CocoaError(.fileReadInapplicableStringEncoding)
    }
    print("\(receiptPrefix)\(receipt)")
} catch {
    fputs(
        "prime-native-decoder-runtime-closure-probe: \(error)\n",
        stderr
    )
    exit(2)
}
