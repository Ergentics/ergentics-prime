// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreGraphics
import Darwin
import Foundation
import Metal
import MLX
import MLXNN
import PrimeCore
import PrimeNativeDecoder
import PrimeNativeDecoderCheckpoint

private enum ProbeError: Error, CustomStringConvertible {
    case contractDrift(String)
    case missingEnvironmentValue(String)
    case invalidUnsignedInteger(key: String, value: String)
    case posix(operation: String, path: String, errorNumber: Int32)

    var description: String {
        switch self {
        case .contractDrift(let detail):
            "contract drift: \(detail)"
        case .missingEnvironmentValue(let key):
            "missing required environment value: \(key)"
        case .invalidUnsignedInteger(let key, let value):
            "invalid unsigned integer for \(key): \(value)"
        case .posix(let operation, let path, let errorNumber):
            "\(operation) failed for \(path): errno=\(errorNumber)"
        }
    }
}

private struct LiveParameterDescriptor: Codable, Equatable {
    let path: String
    let shape: [Int]
    let dtype: String
    let elementCount: UInt64
    let byteCount: UInt64

    private enum CodingKeys: String, CodingKey {
        case path
        case shape
        case dtype
        case elementCount = "element_count"
        case byteCount = "byte_count"
    }
}

private struct CatalogObservation {
    let descriptorCount: Int
    let canonicalByteCount: Int
    let sha256: String
    let pathSetMatches: Bool
    let pathOrderMatches: Bool
    let shapesMatch: Bool
    let dtypesMatch: Bool
    let parameterCount: UInt64
    let parameterByteCount: UInt64
}

private struct ModelObservation {
    let catalog: CatalogObservation
    let outputShape: [Int]
    let outputDType: String
    let outputElementCount: Int
    let outputByteCount: Int
    let outputFiniteValueCount: Int
    let outputFloat32BitPatternSHA256: String
}

private final class HeldMetallib {
    let url: URL
    let byteCount: UInt64
    let sha256: String

    private let descriptor: Int32
    private let deviceID: UInt64
    private let inode: UInt64

    init(
        url: URL,
        expectedByteCount: UInt64,
        expectedSHA256: String
    ) throws {
        guard url.isFileURL,
              url.path.hasPrefix("/"),
              !url.path.hasSuffix("/") else {
            throw ProbeError.contractDrift("invalid metallib URL")
        }

        var pathStatus = stat()
        errno = 0
        guard lstat(url.path, &pathStatus) == 0 else {
            throw ProbeError.posix(
                operation: "lstat metallib",
                path: url.path,
                errorNumber: errno)
        }
        guard pathStatus.st_mode & S_IFMT == S_IFREG,
              pathStatus.st_nlink == 1,
              pathStatus.st_uid == geteuid(),
              pathStatus.st_size > 0,
              UInt64(pathStatus.st_size) == expectedByteCount else {
            throw ProbeError.contractDrift("unsafe metallib path metadata")
        }

        errno = 0
        let opened = open(url.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard opened >= 0 else {
            throw ProbeError.posix(
                operation: "open metallib",
                path: url.path,
                errorNumber: errno)
        }
        var keepDescriptor = false
        defer {
            if !keepDescriptor {
                close(opened)
            }
        }

        var descriptorStatus = stat()
        errno = 0
        guard fstat(opened, &descriptorStatus) == 0 else {
            throw ProbeError.posix(
                operation: "fstat metallib",
                path: url.path,
                errorNumber: errno)
        }
        guard descriptorStatus.st_mode & S_IFMT == S_IFREG,
              descriptorStatus.st_nlink == 1,
              descriptorStatus.st_uid == geteuid(),
              descriptorStatus.st_dev == pathStatus.st_dev,
              descriptorStatus.st_ino == pathStatus.st_ino,
              descriptorStatus.st_size == pathStatus.st_size else {
            throw ProbeError.contractDrift(
                "metallib path and descriptor do not identify one file")
        }

        let data = try Self.read(
            descriptor: opened,
            byteCount: expectedByteCount,
            path: url.path)
        let observedSHA256 = PrimeSHA256.hexDigest(of: data)
        guard observedSHA256 == expectedSHA256 else {
            throw ProbeError.contractDrift("metallib SHA-256 mismatch")
        }

        self.url = url
        byteCount = expectedByteCount
        sha256 = observedSHA256
        descriptor = opened
        deviceID = UInt64(descriptorStatus.st_dev)
        inode = UInt64(descriptorStatus.st_ino)
        keepDescriptor = true
    }

    deinit {
        close(descriptor)
    }

    func revalidate() throws {
        var pathStatus = stat()
        errno = 0
        guard lstat(url.path, &pathStatus) == 0 else {
            throw ProbeError.posix(
                operation: "postflight lstat metallib",
                path: url.path,
                errorNumber: errno)
        }
        var descriptorStatus = stat()
        errno = 0
        guard fstat(descriptor, &descriptorStatus) == 0 else {
            throw ProbeError.posix(
                operation: "postflight fstat metallib",
                path: url.path,
                errorNumber: errno)
        }
        guard pathStatus.st_mode & S_IFMT == S_IFREG,
              pathStatus.st_nlink == 1,
              pathStatus.st_uid == geteuid(),
              UInt64(pathStatus.st_dev) == deviceID,
              UInt64(pathStatus.st_ino) == inode,
              descriptorStatus.st_dev == pathStatus.st_dev,
              descriptorStatus.st_ino == pathStatus.st_ino,
              descriptorStatus.st_size == pathStatus.st_size,
              UInt64(descriptorStatus.st_size) == byteCount else {
            throw ProbeError.contractDrift(
                "metallib path or descriptor changed during execution")
        }
        let data = try Self.read(
            descriptor: descriptor,
            byteCount: byteCount,
            path: url.path)
        guard PrimeSHA256.hexDigest(of: data) == sha256 else {
            throw ProbeError.contractDrift(
                "metallib bytes changed during execution")
        }
    }

    private static func read(
        descriptor: Int32,
        byteCount: UInt64,
        path: String
    ) throws -> Data {
        guard byteCount <= UInt64(Int.max) else {
            throw ProbeError.contractDrift("metallib is too large")
        }
        var result = Data()
        result.reserveCapacity(Int(byteCount))
        var offset: UInt64 = 0
        var buffer = [UInt8](repeating: 0, count: 1_048_576)
        while offset < byteCount {
            let remaining = Int(min(
                UInt64(buffer.count),
                byteCount - offset))
            errno = 0
            let observed = buffer.withUnsafeMutableBytes { bytes in
                pread(
                    descriptor,
                    bytes.baseAddress,
                    remaining,
                    off_t(offset))
            }
            guard observed > 0 else {
                if observed == 0 {
                    throw ProbeError.contractDrift(
                        "metallib descriptor ended early")
                }
                if errno == EINTR {
                    continue
                }
                throw ProbeError.posix(
                    operation: "read metallib",
                    path: path,
                    errorNumber: errno)
            }
            result.append(buffer, count: observed)
            offset += UInt64(observed)
        }
        guard result.count == Int(byteCount) else {
            throw ProbeError.contractDrift("metallib byte count changed")
        }
        return result
    }
}

private func requiredEnvironmentValue(
    _ key: String,
    environment: [String: String]
) throws -> String {
    guard let value = environment[key], !value.isEmpty else {
        throw ProbeError.missingEnvironmentValue(key)
    }
    return value
}

private func requiredUInt64(
    _ key: String,
    environment: [String: String]
) throws -> UInt64 {
    let text = try requiredEnvironmentValue(key, environment: environment)
    guard let value = UInt64(text), String(value) == text else {
        throw ProbeError.invalidUnsignedInteger(key: key, value: text)
    }
    return value
}

private func currentExecutableURL() throws -> URL {
    var capacity: UInt32 = 0
    _ = _NSGetExecutablePath(nil, &capacity)
    guard capacity > 1 else {
        throw ProbeError.contractDrift("executable path is unavailable")
    }
    var bytes = [CChar](repeating: 0, count: Int(capacity))
    guard _NSGetExecutablePath(&bytes, &capacity) == 0 else {
        throw ProbeError.contractDrift("executable path capture failed")
    }
    return URL(fileURLWithPath: String(cString: bytes))
        .resolvingSymlinksInPath()
        .standardizedFileURL
}

private func requireSameMetalDevice(
    _ lhs: any MTLDevice,
    _ rhs: any MTLDevice
) throws {
    guard lhs.registryID == rhs.registryID,
          lhs.name == rhs.name,
          lhs.architecture.name == rhs.architecture.name else {
        throw ProbeError.contractDrift(
            "default Metal device does not match index zero")
    }
}

private func existingLoaderCandidateCount(
    executableURL: URL
) throws -> Int {
    let executableDirectory = executableURL.deletingLastPathComponent()
    var paths = Set<String>()

    func append(_ url: URL) {
        paths.insert(url.standardizedFileURL.path)
    }

    func appendSwiftPMBundle(baseURL: URL) {
        let bundleURL = baseURL.appendingPathComponent(
            "mlx-swift_Cmlx.bundle",
            isDirectory: true)
        guard let bundle = Bundle(url: bundleURL),
              let resourceURL = bundle.resourceURL else {
            return
        }
        append(resourceURL.appendingPathComponent("default.metallib"))
    }

    append(executableDirectory.appendingPathComponent("mlx.metallib"))
    append(
        executableDirectory
            .appendingPathComponent("Resources", isDirectory: true)
            .appendingPathComponent("mlx.metallib"))
    appendSwiftPMBundle(baseURL: Bundle.main.bundleURL)
    for bundle in Bundle.allBundles {
        if let resourceURL = bundle.resourceURL {
            appendSwiftPMBundle(baseURL: resourceURL)
        }
    }
    for framework in Bundle.allFrameworks
    where framework.bundleIdentifier == "mlx-swift_Cmlx" {
        if let resourceURL = framework.resourceURL {
            append(resourceURL.appendingPathComponent("default.metallib"))
        }
    }
    append(
        executableDirectory
            .appendingPathComponent("Resources", isDirectory: true)
            .appendingPathComponent("default.metallib"))
    let currentDirectoryURL = URL(
        fileURLWithPath: FileManager.default.currentDirectoryPath,
        isDirectory: true)
    append(currentDirectoryURL.appendingPathComponent("default.metallib"))

    var count = 0
    for path in paths.sorted() {
        var status = stat()
        errno = 0
        if lstat(path, &status) == 0 {
            guard status.st_mode & S_IFMT == S_IFREG else {
                throw ProbeError.contractDrift(
                    "loader candidate is not a regular file: \(path)")
            }
            count += 1
        } else if errno != ENOENT {
            throw ProbeError.posix(
                operation: "lstat loader candidate",
                path: path,
                errorNumber: errno)
        }
    }
    return count
}

private func liveCatalog(
    model: PrimeNativeGQADecoder,
    identity: PrimeNativeDecoderCompatibilityIdentityV2,
    authority:
        PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1
) throws -> CatalogObservation {
    let flattened = model.parameters().flattened()
    guard flattened.count == authority.parameterDescriptorCount else {
        throw ProbeError.contractDrift("live parameter descriptor count")
    }
    var uniquePaths = Set<String>()
    for (path, _) in flattened {
        guard uniquePaths.insert(path).inserted else {
            throw ProbeError.contractDrift(
                "duplicate live parameter path: \(path)")
        }
    }

    let sorted = flattened.sorted { left, right in
        left.0.utf8.lexicographicallyPrecedes(right.0.utf8)
    }
    let expectedPaths = identity.parameterCatalog.map(\.path)
    let observedPaths = sorted.map(\.0)
    let pathSetMatches = Set(observedPaths) == Set(expectedPaths)
    let pathOrderMatches = observedPaths == expectedPaths
    guard pathSetMatches, pathOrderMatches else {
        throw ProbeError.contractDrift("live parameter paths")
    }

    var descriptors = [LiveParameterDescriptor]()
    descriptors.reserveCapacity(sorted.count)
    var shapesMatch = true
    var dtypesMatch = true
    var parameterCount: UInt64 = 0
    var parameterByteCount: UInt64 = 0
    for ((path, array), expected) in zip(
        sorted,
        identity.parameterCatalog
    ) {
        guard array.size >= 0 else {
            throw ProbeError.contractDrift("negative live parameter size")
        }
        let elementCount = UInt64(array.size)
        let bytes = elementCount.multipliedReportingOverflow(by: 4)
        guard !bytes.overflow else {
            throw ProbeError.contractDrift("live parameter byte overflow")
        }
        let nextElements = parameterCount.addingReportingOverflow(elementCount)
        let nextBytes = parameterByteCount.addingReportingOverflow(
            bytes.partialValue)
        guard !nextElements.overflow, !nextBytes.overflow else {
            throw ProbeError.contractDrift("live catalog count overflow")
        }
        parameterCount = nextElements.partialValue
        parameterByteCount = nextBytes.partialValue

        shapesMatch = shapesMatch
            && array.shape == expected.shape
            && elementCount == expected.elementCount
            && bytes.partialValue == expected.byteCount
        dtypesMatch = dtypesMatch
            && array.dtype == .float32
            && expected.dtype == "float32"
        descriptors.append(
            LiveParameterDescriptor(
                path: path,
                shape: array.shape,
                dtype: "float32",
                elementCount: elementCount,
                byteCount: bytes.partialValue))
    }
    guard shapesMatch,
          dtypesMatch,
          parameterCount == authority.totalParameterCount,
          parameterByteCount == authority.totalParameterByteCount else {
        throw ProbeError.contractDrift("live parameter metadata")
    }

    let canonical = try PrimeCanonicalJSON.encode(descriptors)
    let sha256 = PrimeSHA256.hexDigest(of: canonical)
    guard canonical.count == authority.parameterCatalogCanonicalByteCount,
          sha256 == authority.parameterCatalogSHA256 else {
        throw ProbeError.contractDrift("live parameter catalog identity")
    }
    return CatalogObservation(
        descriptorCount: descriptors.count,
        canonicalByteCount: canonical.count,
        sha256: sha256,
        pathSetMatches: pathSetMatches,
        pathOrderMatches: pathOrderMatches,
        shapesMatch: shapesMatch,
        dtypesMatch: dtypesMatch,
        parameterCount: parameterCount,
        parameterByteCount: parameterByteCount)
}

private func float32BitPatternSHA256(_ values: [Float]) -> String {
    var data = Data()
    data.reserveCapacity(values.count * MemoryLayout<UInt32>.size)
    for value in values {
        var bits = value.bitPattern.bigEndian
        withUnsafeBytes(of: &bits) { bytes in
            data.append(contentsOf: bytes)
        }
    }
    return PrimeSHA256.hexDigest(of: data)
}

private func executeModel(
    configuration: PrimeNativeGQADecoderConfiguration,
    identity: PrimeNativeDecoderCompatibilityIdentityV2,
    authority:
        PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1,
    tokenIDs: [Int],
    gpu: Device
) throws -> ModelObservation {
    try Device.withDefaultDevice(gpu) {
        try withError {
            Memory.cacheLimit = authority.requiredMemoryCacheLimit
            guard Memory.cacheLimit == authority.requiredMemoryCacheLimit else {
                throw ProbeError.contractDrift("MLX allocator cache limit")
            }

            Memory.clearCache()
            let model = PrimeNativeGQADecoder.make(
                configuration: configuration,
                seed: authority.initializationSeed)
            model.train(false)
            try checkedEval(model)
            Memory.clearCache()

            let catalog = try liveCatalog(
                model: model,
                identity: identity,
                authority: authority)
            let logits = try model.forward(tokenIDs: tokenIDs)
            Memory.clearCache()
            try checkedEval(logits)

            guard logits.shape == authority.expectedOutputShape,
                  logits.dtype == .float32,
                  logits.size == authority.expectedOutputElementCount else {
                throw ProbeError.contractDrift("forward output metadata")
            }
            let values = logits.asArray(Float.self)
            let finiteCount = values.reduce(into: 0) { count, value in
                if value.isFinite {
                    count += 1
                }
            }
            guard values.count == authority.expectedOutputElementCount,
                  finiteCount == values.count else {
                throw ProbeError.contractDrift("forward output finiteness")
            }
            let outputSHA256 = float32BitPatternSHA256(values)
            Memory.clearCache()

            return ModelObservation(
                catalog: catalog,
                outputShape: logits.shape,
                outputDType: "float32",
                outputElementCount: values.count,
                outputByteCount:
                    values.count * MemoryLayout<Float>.size,
                outputFiniteValueCount: finiteCount,
                outputFloat32BitPatternSHA256: outputSHA256)
        }
    }
}

do {
    let environmentPolicy = try
        PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEnvironmentPolicyV1
            .validateLaunchedCurrentProcess()
    let releaseInstrumentation = try
        PrimeReleaseInstrumentationAdmissionPolicy.validateCurrentProcess()
    guard !releaseInstrumentation.observation.instrumentationObserved else {
        throw ProbeError.contractDrift("release instrumentation")
    }

    let authority =
        PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1
            .frozenV1
    try authority.validateExactV1()
    guard PrimeEmbeddedBuildProvenance.buildConfiguration == "release" else {
        throw ProbeError.contractDrift("Release probe required")
    }

    let environment = ProcessInfo.processInfo.environment
    let revisionKey =
        "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_EXECUTED_REVISION"
    let treeKey =
        "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_EXECUTED_TREE"
    let metallibPathKey =
        "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_METALLIB_PATH"
    let metallibBytesKey =
        "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_METALLIB_BYTES"
    let metallibSHA256Key =
        "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_METALLIB_SHA256"
    let leasePathKey =
        "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_METAL_LEASE_PATH"
    let executedRevision = try requiredEnvironmentValue(
        revisionKey,
        environment: environment)
    let executedTree = try requiredEnvironmentValue(
        treeKey,
        environment: environment)
    let metallibPath = try requiredEnvironmentValue(
        metallibPathKey,
        environment: environment)
    let metallibByteCount = try requiredUInt64(
        metallibBytesKey,
        environment: environment)
    let metallibSHA256 = try requiredEnvironmentValue(
        metallibSHA256Key,
        environment: environment)
    let leasePath = try requiredEnvironmentValue(
        leasePathKey,
        environment: environment)
    let expectation = try
        PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1(
            byteCount: metallibByteCount,
            sha256: metallibSHA256)

    let executableURL = try currentExecutableURL()
    let expectedMetallibURL = executableURL
        .deletingLastPathComponent()
        .appendingPathComponent(expectation.artifactRelativePath)
        .standardizedFileURL
    let suppliedMetallibURL = URL(fileURLWithPath: metallibPath)
        .standardizedFileURL
    guard suppliedMetallibURL.path == expectedMetallibURL.path,
          metallibPath == suppliedMetallibURL.path else {
        throw ProbeError.contractDrift("unexpected metallib path")
    }
    let candidateCountBefore = try existingLoaderCandidateCount(
        executableURL: executableURL)
    guard candidateCountBefore == 1 else {
        throw ProbeError.contractDrift("loader candidate count before execution")
    }
    let metallib = try HeldMetallib(
        url: suppliedMetallibURL,
        expectedByteCount: expectation.byteCount,
        expectedSHA256: expectation.sha256)
    let lease = try PrimeMetalDeviceLease.acquire(
        at: URL(fileURLWithPath: leasePath))
    defer { lease.release() }
    guard lease.isHeld else {
        throw ProbeError.contractDrift("Metal lease is not held")
    }

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard colorSpace.model == .rgb else {
        throw ProbeError.contractDrift("CoreGraphics bootstrap")
    }
    let metalDevices = MTLCopyAllDevices()
    guard metalDevices.count == 1,
          let indexZero = metalDevices.first,
          let defaultDevice = MTLCreateSystemDefaultDevice() else {
        throw ProbeError.contractDrift("singleton Metal device")
    }
    try requireSameMetalDevice(indexZero, defaultDevice)
    let validatedLibrary: any MTLLibrary
    do {
        validatedLibrary = try indexZero.makeLibrary(URL: metallib.url)
    } catch {
        throw ProbeError.contractDrift(
            "exact metallib URL validation failed: \(error)")
    }

    let manifest = try PrimeNativeByteTokenizer.manifest()
    try PrimeNativeByteTokenizer.verify(manifest)
    guard manifest.manifestSHA256 == authority.tokenizerManifestSHA256,
          manifest.replayProbeSHA256
            == authority.tokenizerReplayProbeSHA256 else {
        throw ProbeError.contractDrift("tokenizer manifest")
    }
    let primaryTokenIDs = PrimeNativeByteTokenizer.encodeSequence(
        authority.sourceText)
    let independentTokenIDs = [
        PrimeNativeByteTokenizer.beginningOfSequenceTokenID,
    ] + (try PrimeNativeByteTokenizer.encodeWithFoundationData(
        authority.sourceText)) + [
        PrimeNativeByteTokenizer.endOfSequenceTokenID,
    ]
    let tokenIDsSHA256 = try PrimeNativeByteTokenizer.tokenIDsSHA256(
        primaryTokenIDs)
    let decodedText = try PrimeNativeByteTokenizer.decodeSequence(
        primaryTokenIDs)
    guard primaryTokenIDs == authority.sequenceTokenIDs,
          independentTokenIDs == authority.sequenceTokenIDs,
          primaryTokenIDs == independentTokenIDs,
          tokenIDsSHA256 == authority.sequenceTokenIDsSHA256,
          decodedText == authority.canonicalText,
          PrimeSHA256.hexDigest(of: Data(authority.sourceText.utf8))
            == authority.sourceUTF8SHA256,
          PrimeSHA256.hexDigest(of: Data(decodedText.utf8))
            == authority.canonicalUTF8SHA256 else {
        throw ProbeError.contractDrift("tokenizer fixture")
    }

    let identity = try PrimeNativeDecoderCompatibilityIdentityV2
        .native300MByte512()
    try identity.validate()
    let identityBytes = try PrimeCanonicalJSON.encode(identity)
    let identitySHA256 = PrimeSHA256.hexDigest(of: identityBytes)
    guard identityBytes.count
            == authority.compatibilityIdentityCanonicalByteCount,
          identitySHA256 == authority.compatibilityIdentitySHA256,
          identity.tokenIdentity.tokenizerID == authority.tokenizerID,
          identity.tokenIdentity.tokenizerManifestSHA256
            == manifest.manifestSHA256,
          identity.parameterCatalog.count
            == authority.parameterDescriptorCount else {
        throw ProbeError.contractDrift("V2 compatibility identity")
    }

    let configuration = try PrimeNativeGQADecoderConfiguration
        .native300MInventory(
            vocabularySize:
                PrimeNativeByteTokenizer.boundModelVocabularySize)
    guard PrimeNativeDecoderConfigurationSnapshotV1(configuration)
            == identity.configuration,
          configuration.vocabularySize
            == authority.configuration.vocabularySize,
          configuration.modelWidth == authority.configuration.modelWidth,
          configuration.layerCount == authority.configuration.layerCount,
          configuration.queryHeadCount
            == authority.configuration.queryHeadCount,
          configuration.keyValueHeadCount
            == authority.configuration.keyValueHeadCount,
          configuration.headWidth == authority.configuration.headWidth,
          configuration.intermediateWidth
            == authority.configuration.intermediateWidth,
          configuration.maximumSequenceLength
            == authority.configuration.maximumSequenceLength,
          configuration.ropeTheta.bitPattern
            == authority.configuration.ropeThetaFloat32BitPattern,
          configuration.rmsNormEpsilon.bitPattern
            == authority.configuration.rmsNormEpsilonFloat32BitPattern,
          configuration.uniqueParameterCount
            == authority.configuration.uniqueParameterCount else {
        throw ProbeError.contractDrift("Native-300M configuration")
    }

    let gpu = Device(.gpu, index: 0)
    guard gpu.deviceType == .gpu else {
        throw ProbeError.contractDrift("MLX GPU index zero")
    }
    let modelObservation = try withExtendedLifetime(validatedLibrary) {
        try executeModel(
            configuration: configuration,
            identity: identity,
            authority: authority,
            tokenIDs: primaryTokenIDs,
            gpu: gpu)
    }

    let postflightEnvironmentPolicy = try
        PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEnvironmentPolicyV1
            .validateLaunchedCurrentProcess()
    guard postflightEnvironmentPolicy == environmentPolicy else {
        throw ProbeError.contractDrift("launched environment changed")
    }
    let postflightInstrumentation = try
        PrimeReleaseInstrumentationAdmissionPolicy.validateCurrentProcess()
    guard !postflightInstrumentation.observation.instrumentationObserved else {
        throw ProbeError.contractDrift("postflight release instrumentation")
    }
    try metallib.revalidate()
    let candidateCountAfter = try existingLoaderCandidateCount(
        executableURL: executableURL)
    guard candidateCountAfter == 1,
          lease.isHeld else {
        throw ProbeError.contractDrift("postflight loader or Metal lease")
    }
    let postflightDevices = MTLCopyAllDevices()
    guard postflightDevices.count == 1,
          let postflightIndexZero = postflightDevices.first,
          let postflightDefault = MTLCreateSystemDefaultDevice() else {
        throw ProbeError.contractDrift("postflight singleton Metal device")
    }
    try requireSameMetalDevice(indexZero, postflightIndexZero)
    try requireSameMetalDevice(indexZero, postflightDefault)

    let evidence = try
        PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEvidenceV1(
            executedRevision: executedRevision,
            executedTree: executedTree,
            executedEmbeddedSourceIdentitySHA256:
                PrimeEmbeddedBuildProvenance.sourceIdentitySHA256,
            environmentPolicy: environmentPolicy,
            launchedEnvironmentValidatedBeforeFrameworkAccess: true,
            launchedEnvironmentRevalidatedAfterEvaluation: true,
            releaseInstrumentationEvidenceAbsent: true,
            coreGraphicsBootstrapObserved: true,
            enumeratedMetalDeviceCount: metalDevices.count,
            defaultMetalDeviceMatchedIndexZero: true,
            mlxDeviceType: "gpu",
            mlxDeviceIndex: 0,
            metalLeaseHeldBeforeAndAfterEvaluation: true,
            tokenizerManifestSHA256: manifest.manifestSHA256,
            tokenizerReplayProbeSHA256: manifest.replayProbeSHA256,
            tokenizerManifestAndReplayValidated: true,
            sourceText: authority.sourceText,
            sourceUTF8SHA256: authority.sourceUTF8SHA256,
            canonicalText: authority.canonicalText,
            canonicalUTF8SHA256: authority.canonicalUTF8SHA256,
            primarySequenceTokenIDs: primaryTokenIDs,
            independentSequenceTokenIDs: independentTokenIDs,
            sequenceTokenIDsSHA256: tokenIDsSHA256,
            primaryAndIndependentTokenPathsAgree: true,
            decodedText: decodedText,
            decodeRoundTripEstablished: true,
            compatibilityIdentityCanonicalByteCount: identityBytes.count,
            compatibilityIdentitySHA256: identitySHA256,
            compatibilityIdentityValidated: true,
            configuration: authority.configuration,
            initializationSeed: authority.initializationSeed,
            modelConstructionCount: 1,
            parameterDescriptorCount:
                modelObservation.catalog.descriptorCount,
            parameterCatalogCanonicalByteCount:
                modelObservation.catalog.canonicalByteCount,
            parameterCatalogSHA256: modelObservation.catalog.sha256,
            parameterPathSetMatches:
                modelObservation.catalog.pathSetMatches,
            parameterPathOrderMatches:
                modelObservation.catalog.pathOrderMatches,
            parameterPathOrder:
                "global_lexicographic_ascending_utf8_v1",
            parameterShapesMatch: modelObservation.catalog.shapesMatch,
            parameterDTypesMatch: modelObservation.catalog.dtypesMatch,
            observedParameterCount:
                modelObservation.catalog.parameterCount,
            observedParameterByteCount:
                modelObservation.catalog.parameterByteCount,
            forwardInvocationCount: 1,
            forwardMode: authority.requiredForwardMode,
            decoderKVCacheUsed: false,
            backwardInvoked: false,
            checkpointIOObserved: false,
            generationInvoked: false,
            memoryCacheLimit: Memory.cacheLimit,
            memoryCacheClearCount: 4,
            cacheClearedBeforeParameterMaterialization: true,
            parameterMaterializationEvaluationCount: 1,
            parameterMaterializationEvaluationAPI:
                authority.parameterMaterializationEvaluationAPI,
            parametersMaterializedBeforeForward: true,
            cacheClearedAfterParameterMaterialization: true,
            cacheClearedBeforeForwardOutputEvaluation: true,
            forwardOutputEvaluationCount: 1,
            forwardOutputEvaluationAPI:
                authority.forwardOutputEvaluationAPI,
            cacheClearedAfterForwardOutputEvaluation: true,
            logitsReadbackCount: 1,
            logitsReadbackAPI: authority.logitsReadbackAPI,
            outputShape: modelObservation.outputShape,
            outputDType: modelObservation.outputDType,
            outputElementCount: modelObservation.outputElementCount,
            outputByteCount: modelObservation.outputByteCount,
            outputAllFinite:
                modelObservation.outputFiniteValueCount
                    == modelObservation.outputElementCount,
            outputFiniteValueCount:
                modelObservation.outputFiniteValueCount,
            outputHashEncoding: authority.outputHashEncoding,
            outputFloat32BitPatternSHA256:
                modelObservation.outputFloat32BitPatternSHA256,
            metallibArtifactRelativePath: expectation.artifactRelativePath,
            metallibByteCount: metallib.byteCount,
            metallibSHA256: metallib.sha256,
            existingMetallibCandidateCountBeforeExecution:
                candidateCountBefore,
            existingMetallibCandidateCountAfterExecution:
                candidateCountAfter,
            metallibPathAndDescriptorReverified: true,
            metalLibraryValidatedFromExactURL: true)
    try evidence.validate()
    let receiptBytes = try PrimeCanonicalJSON.encode(evidence)
    guard let receipt = String(data: receiptBytes, encoding: .utf8) else {
        throw ProbeError.contractDrift("receipt is not UTF-8")
    }
    print(
        "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=\(receipt)")
} catch {
    fputs(
        "prime-native-decoder-tokenizer-compatibility-probe: \(error)\n",
        stderr)
    exit(2)
}
