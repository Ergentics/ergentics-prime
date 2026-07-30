import Foundation
#if canImport(Darwin)
    import Darwin
    import MachO
#endif

public enum PrimeNative3BLoadedExecutableVnodeError:
    Error,
    Equatable,
    Sendable
{
    case unsupportedPlatform
    case mainImageUnavailable
    case regionQueryFailed(errno: Int32)
    case invalidMainImageRegion
    case identityMismatch(
        expectedDeviceID: UInt64,
        expectedInode: UInt64,
        observedDeviceID: UInt64,
        observedInode: UInt64
    )
}

/// Descriptor-comparable identity for the vnode that backs the process's
/// loaded main Mach-O image.
///
/// `_NSGetExecutablePath` and `proc_pidpath` return names. A name can be
/// replaced after `exec` and restored before verification, so those APIs
/// cannot prove that a staged pathname still names the image which was
/// actually mapped. This observation asks the Darwin process API for the
/// vnode backing the region containing the loaded main Mach-O header.
public struct PrimeNative3BLoadedExecutableVnode:
    Equatable,
    Sendable
{
    public let deviceID: UInt64
    public let inode: UInt64

    public init(
        deviceID: UInt64,
        inode: UInt64
    ) {
        self.deviceID = deviceID
        self.inode = inode
    }

    public static func observeCurrentProcess() throws
        -> Self
    {
        #if os(macOS)
            guard let header =
                    _dyld_get_image_header(0) else {
                throw
                    PrimeNative3BLoadedExecutableVnodeError
                    .mainImageUnavailable
            }
            let address = UInt64(
                UInt(
                    bitPattern:
                        UnsafeRawPointer(header)
                )
            )
            var region = proc_regionwithpathinfo()
            errno = 0
            let result = withUnsafeMutablePointer(
                to: &region
            ) {
                proc_pidinfo(
                    getpid(),
                    PROC_PIDREGIONPATHINFO,
                    address,
                    $0,
                    Int32(
                        MemoryLayout<
                            proc_regionwithpathinfo
                        >.size
                    )
                )
            }
            guard result
                    == Int32(
                        MemoryLayout<
                            proc_regionwithpathinfo
                        >.size
                    ) else {
                throw
                    PrimeNative3BLoadedExecutableVnodeError
                    .regionQueryFailed(errno: errno)
            }
            let status =
                region.prp_vip.vip_vi.vi_stat
            guard status.vst_mode
                    & UInt16(S_IFMT)
                    == UInt16(S_IFREG),
                  status.vst_dev != 0,
                  status.vst_ino > 0 else {
                throw
                    PrimeNative3BLoadedExecutableVnodeError
                    .invalidMainImageRegion
            }
            return Self(
                deviceID:
                    UInt64(
                        bitPattern:
                            Int64(status.vst_dev)
                    ),
                inode: status.vst_ino
            )
        #else
            throw
                PrimeNative3BLoadedExecutableVnodeError
                .unsupportedPlatform
        #endif
    }

    public func requireMatches(
        deviceID expectedDeviceID: UInt64,
        inode expectedInode: UInt64
    ) throws {
        guard deviceID == expectedDeviceID,
              inode == expectedInode else {
            throw
                PrimeNative3BLoadedExecutableVnodeError
                .identityMismatch(
                    expectedDeviceID:
                        expectedDeviceID,
                    expectedInode: expectedInode,
                    observedDeviceID: deviceID,
                    observedInode: inode
                )
        }
    }

    public func requireMatches(
        _ artifact: PrimeVerifiedArtifact
    ) throws {
        try requireMatches(
            deviceID: artifact.deviceID,
            inode: artifact.inode
        )
    }
}

/// The three fresh processes used by the bounded exact-3B interruption gate.
public enum PrimeNative3BMetalContinuationWorkerRole:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case control
    case writer
    case restorer
}

public enum PrimeNative3BContinuationCatalogLabel {
    public static let initialModel = "initial_model"
    public static let poisonModel = "poison_model"
    public static let clippedGradient = "clipped_gradient"
    public static let model = "model"
    public static let firstMoment = "adam_first_moment"
    public static let secondMoment = "adam_second_moment"
    public static let fixedLogits = "fixed_logits"
}

/// One frozen tensor slot in the maintained MLXLLM Llama parameter tree.
public struct PrimeNative3BContinuationTensorTopologyEntry:
    Equatable,
    Sendable
{
    public let path: String
    public let shape: [Int]
    public let dtype: String
    public let byteCount: UInt64

    fileprivate init(
        path: String,
        shape: [Int],
        dtype: String = "float32",
        byteCount: UInt64? = nil
    ) {
        self.path = path
        self.shape = shape
        self.dtype = dtype
        let shapeByteCount =
            shape.reduce(UInt64(1)) {
                $0 * UInt64($1)
            } * 4
        self.byteCount = byteCount ?? shapeByteCount
    }
}

public enum PrimeNative3BMetalContinuationContract {
    public static let schemaVersion = 1
    public static let artifactKind =
        "prime_native_3b_metal_continuation"
    public static let fixedEvaluationSequenceLength = 128
    public static let trainingInputContract =
        "seed_bound_collision_free_128_of_256_odd_stride_modular_schedule"
    public static let trainingTokenLowerBound = 256
    public static let trainingTokenDomainSize = 256
    public static let trainingStepOffsetStride = 73
    public static let requiredPrimeSourceRelativePaths:
        Set<String> = [
            "Sources/PrimeCore/PrimeDurableArtifacts.swift",
            "Sources/PrimeCore/PrimeNative3BMetalContinuation.swift",
            "Sources/PrimeCore/PrimeNative3BProfile.swift",
            "Sources/PrimeCore/PrimeNativeArcContinuity.swift",
            "Sources/PrimeNative3BMetalContinuationProbe/PrimeNative3BMetalContinuationProbeMain.swift",
        ]

    /// Logical FP32 bytes in one exact-3B model or Adam moment family.
    public static let fullStateLogicalByteCount =
        UInt64(PrimeNativeProfiles.exact3B.parameterCount) * 4
    /// Hard admission cap for each independently stored model or Adam
    /// checkpoint component. The writer and descriptor loader use this same
    /// value so an oversized artifact is rejected before materialization.
    public static let checkpointComponentMaximumByteCount:
        UInt64 = 12 * 1024 * 1024 * 1024
    /// Successful worker output must remain fully captured within this bound.
    public static let childOutputMaximumByteCount:
        UInt64 = 64 * 1024

    /// Returns one seed-bound synthetic mechanics input without repeated token
    /// IDs. MLX's maintained gather VJP accumulates repeated embedding rows
    /// through floating-point Metal atomics, whose arrival order is not a
    /// byte-exact replay contract. This schedule removes that contention path;
    /// it does not claim arbitrary repeated-token training determinism.
    public static func collisionFreeTrainingTokens(
        seed: UInt64,
        ordinal: Int
    ) throws -> [Int32] {
        let tokenCount =
            fixedEvaluationSequenceLength
        let domain = trainingTokenDomainSize
        guard ordinal >= 0,
              ordinal < 3,
              tokenCount > 0,
              tokenCount <= domain,
              trainingTokenLowerBound >= 0,
              trainingTokenLowerBound + domain
                <= PrimeNativeProfiles.exact3B
                    .vocabularySize,
              trainingStepOffsetStride > 0,
              trainingStepOffsetStride < domain,
              trainingStepOffsetStride % 2 == 1
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B collision-free training schedule contract is invalid"
                )
        }
        let baseOffset =
            Int(seed % UInt64(domain))
        let positionStride =
            2
            * Int(
                (seed >> 8)
                    % UInt64(domain / 2)
            )
            + 1
        let stepOffset =
            (
                baseOffset
                    + ordinal
                    * trainingStepOffsetStride
            ) % domain
        let tokens = (0 ..< tokenCount).map {
            Int32(
                trainingTokenLowerBound
                    + (
                        stepOffset
                            + $0
                            * positionStride
                    ) % domain
            )
        }
        guard tokens.count == tokenCount,
              Set(tokens).count == tokenCount,
              tokens.allSatisfy({
                  $0 >= Int32(
                      trainingTokenLowerBound
                  )
                      && $0
                          < Int32(
                              trainingTokenLowerBound
                                  + domain
                          )
              }) else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B training schedule contains a repeated or out-of-domain token"
                )
        }
        return tokens
    }

    /// Exact flattened topology of the maintained tied-embedding Llama model.
    ///
    /// Linear weights use MLX's `[output, input]` layout. The tied language
    /// head contributes no separate parameter tensor.
    public static let fullStateTopology:
        [PrimeNative3BContinuationTensorTopologyEntry] =
    {
        let profile = PrimeNativeProfiles.exact3B
        let dimension = profile.modelDimension
        let queryWidth =
            profile.attentionHeads
            * profile.headDimension
        let keyValueWidth =
            profile.keyValueHeads
            * profile.headDimension
        let feedForward =
            profile.feedForwardDimension
        var entries = [
            PrimeNative3BContinuationTensorTopologyEntry(
                path: "model.embed_tokens.weight",
                shape: [
                    profile.vocabularySize,
                    dimension,
                ]
            ),
        ]
        entries.reserveCapacity(
            2 + profile.layerCount * 9
        )
        for layer in 0 ..< profile.layerCount {
            let prefix = "model.layers.\(layer)"
            entries.append(
                PrimeNative3BContinuationTensorTopologyEntry(
                    path:
                        "\(prefix).input_layernorm.weight",
                    shape: [dimension]
                )
            )
            entries.append(
                PrimeNative3BContinuationTensorTopologyEntry(
                    path:
                        "\(prefix).mlp.down_proj.weight",
                    shape: [
                        dimension,
                        feedForward,
                    ]
                )
            )
            entries.append(
                PrimeNative3BContinuationTensorTopologyEntry(
                    path:
                        "\(prefix).mlp.gate_proj.weight",
                    shape: [
                        feedForward,
                        dimension,
                    ]
                )
            )
            entries.append(
                PrimeNative3BContinuationTensorTopologyEntry(
                    path:
                        "\(prefix).mlp.up_proj.weight",
                    shape: [
                        feedForward,
                        dimension,
                    ]
                )
            )
            entries.append(
                PrimeNative3BContinuationTensorTopologyEntry(
                    path:
                        "\(prefix).post_attention_layernorm.weight",
                    shape: [dimension]
                )
            )
            entries.append(
                PrimeNative3BContinuationTensorTopologyEntry(
                    path:
                        "\(prefix).self_attn.k_proj.weight",
                    shape: [
                        keyValueWidth,
                        dimension,
                    ]
                )
            )
            entries.append(
                PrimeNative3BContinuationTensorTopologyEntry(
                    path:
                        "\(prefix).self_attn.o_proj.weight",
                    shape: [
                        dimension,
                        queryWidth,
                    ]
                )
            )
            entries.append(
                PrimeNative3BContinuationTensorTopologyEntry(
                    path:
                        "\(prefix).self_attn.q_proj.weight",
                    shape: [
                        queryWidth,
                        dimension,
                    ]
                )
            )
            entries.append(
                PrimeNative3BContinuationTensorTopologyEntry(
                    path:
                        "\(prefix).self_attn.v_proj.weight",
                    shape: [
                        keyValueWidth,
                        dimension,
                    ]
                )
            )
        }
        entries.append(
            PrimeNative3BContinuationTensorTopologyEntry(
                path: "model.norm.weight",
                shape: [dimension]
            )
        )
        entries.sort { $0.path < $1.path }
        precondition(
            entries.reduce(UInt64(0)) {
                $0 + $1.byteCount
            } == fullStateLogicalByteCount,
            "exact 3B Llama topology must equal the frozen profile parameter count"
        )
        return entries
    }()

    public static let fixedLogitsTopology = [
        PrimeNative3BContinuationTensorTopologyEntry(
            path: "logits",
            shape: [
                1,
                fixedEvaluationSequenceLength,
                PrimeNativeProfiles.exact3B
                    .vocabularySize,
            ]
        ),
    ]

    public static let fixedLogitsLogicalByteCount =
        fixedLogitsTopology[0].byteCount

    public static func frozenSeeds()
        throws -> PrimeExecutionSeeds
    {
        try PrimeExecutionSeeds
            .initialFactorizedCalibrationTriple()
    }
}

/// One logical, evaluated FP32 tensor.
///
/// `sha256` binds the tensor's logical row-major bytes, not a container-file
/// encoding or safetensors entry order.
public struct PrimeNative3BContinuationTensorEntry:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let shape: [Int]
    public let dtype: String
    public let byteCount: UInt64
    public let sha256: String
    public let finite: Bool
    public let nonzero: Bool

    public init(
        path: String,
        shape: [Int],
        dtype: String,
        byteCount: UInt64,
        sha256: String,
        finite: Bool,
        nonzero: Bool
    ) {
        self.path = path
        self.shape = shape
        self.dtype = dtype
        self.byteCount = byteCount
        self.sha256 = sha256
        self.finite = finite
        self.nonzero = nonzero
    }

    public func validate() throws {
        guard !path.isEmpty,
              path.utf8.allSatisfy({
                  $0 >= 0x21 && $0 <= 0x7e
              }),
              dtype == "float32",
              !shape.isEmpty,
              shape.allSatisfy({ $0 > 0 }),
              PrimeNative3BContinuationValidation
                .isSHA256(sha256),
              finite,
              nonzero else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B tensor identity, FP32 type, finiteness, or nonzero witness is invalid"
                )
        }

        var elementCount: UInt64 = 1
        for dimension in shape {
            let product =
                elementCount.multipliedReportingOverflow(
                    by: UInt64(dimension)
                )
            guard !product.overflow else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "native 3B tensor shape overflows"
                    )
            }
            elementCount = product.partialValue
        }
        let bytes =
            elementCount.multipliedReportingOverflow(by: 4)
        guard !bytes.overflow,
              bytes.partialValue == byteCount else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B tensor byte count does not equal its FP32 shape"
                )
        }
    }
}

/// A canonically path-ordered collection of logical tensor witnesses.
///
/// The aggregate is the SHA-256 of canonical JSON for `entries`. This makes
/// the aggregate reproducible without depending on a checkpoint container's
/// header or entry ordering.
public struct PrimeNative3BContinuationTensorCatalog:
    Codable,
    Equatable,
    Sendable
{
    public let label: String
    public let entries:
        [PrimeNative3BContinuationTensorEntry]
    public let aggregateSHA256: String

    public init(
        label: String,
        entries:
            [PrimeNative3BContinuationTensorEntry],
        aggregateSHA256: String
    ) {
        self.label = label
        self.entries = entries
        self.aggregateSHA256 = aggregateSHA256
    }

    public init(
        label: String,
        entries:
            [PrimeNative3BContinuationTensorEntry]
    ) throws {
        self.init(
            label: label,
            entries: entries,
            aggregateSHA256:
                try PrimeNative3BContinuationReconciler
                    .aggregateSHA256(for: entries)
        )
    }

    public func validate(
        expectedLabel: String? = nil,
        expectedLogicalByteCount: UInt64? = nil
    ) throws {
        guard !label.isEmpty,
              label.utf8.allSatisfy({
                  $0 >= 0x21 && $0 <= 0x7e
              }),
              expectedLabel == nil
                || label == expectedLabel,
              !entries.isEmpty,
              PrimeNative3BContinuationValidation
                .isSHA256(aggregateSHA256),
              entries.map(\.path)
                == entries.map(\.path).sorted(),
              Set(entries.map(\.path)).count
                == entries.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B tensor catalog label or canonical path order is invalid"
                )
        }

        var total: UInt64 = 0
        for entry in entries {
            try entry.validate()
            let sum = total.addingReportingOverflow(
                entry.byteCount
            )
            guard !sum.overflow else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "native 3B tensor catalog byte count overflows"
                    )
            }
            total = sum.partialValue
        }
        guard expectedLogicalByteCount == nil
                || total == expectedLogicalByteCount,
              aggregateSHA256
                == (try PrimeNative3BContinuationReconciler
                    .aggregateSHA256(for: entries))
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B tensor catalog byte count or aggregate hash is invalid"
                )
        }

        if let expectedLabel {
            let expectedTopology:
                [
                    PrimeNative3BContinuationTensorTopologyEntry
                ]?
            switch expectedLabel {
            case PrimeNative3BContinuationCatalogLabel
                    .initialModel,
                 PrimeNative3BContinuationCatalogLabel
                    .poisonModel,
                 PrimeNative3BContinuationCatalogLabel
                    .clippedGradient,
                 PrimeNative3BContinuationCatalogLabel.model,
                 PrimeNative3BContinuationCatalogLabel
                    .firstMoment,
                 PrimeNative3BContinuationCatalogLabel
                    .secondMoment:
                expectedTopology =
                    PrimeNative3BMetalContinuationContract
                    .fullStateTopology
            case PrimeNative3BContinuationCatalogLabel
                    .fixedLogits:
                expectedTopology =
                    PrimeNative3BMetalContinuationContract
                    .fixedLogitsTopology
            default:
                expectedTopology = nil
            }
            if let expectedTopology {
                guard PrimeNative3BContinuationValidation
                        .topology(of: self)
                        == expectedTopology else {
                    throw PrimeDurableArtifactError
                        .invalidSemantics(
                            "native 3B tensor catalog topology differs from its frozen contract"
                        )
                }
            }
        }
    }
}

/// Exact evidence at an optimizer step boundary.
public struct PrimeNative3BContinuationStepWitness:
    Codable,
    Equatable,
    Sendable
{
    public let step: Int
    public let inputSHA256: String
    public let lossBitPattern: UInt32
    public let rawGradientNormBitPattern: UInt32
    public let clippedGradientNormBitPattern: UInt32
    public let clippedGradient:
        PrimeNative3BContinuationTensorCatalog
    public let model:
        PrimeNative3BContinuationTensorCatalog
    public let firstMoment:
        PrimeNative3BContinuationTensorCatalog
    public let secondMoment:
        PrimeNative3BContinuationTensorCatalog
    public let fixedLogits:
        PrimeNative3BContinuationTensorCatalog
    public let cursor: Int
    public let nextInputSHA256: String

    public init(
        step: Int,
        inputSHA256: String,
        lossBitPattern: UInt32,
        rawGradientNormBitPattern: UInt32,
        clippedGradientNormBitPattern: UInt32,
        clippedGradient:
            PrimeNative3BContinuationTensorCatalog,
        model:
            PrimeNative3BContinuationTensorCatalog,
        firstMoment:
            PrimeNative3BContinuationTensorCatalog,
        secondMoment:
            PrimeNative3BContinuationTensorCatalog,
        fixedLogits:
            PrimeNative3BContinuationTensorCatalog,
        cursor: Int,
        nextInputSHA256: String
    ) {
        self.step = step
        self.inputSHA256 = inputSHA256
        self.lossBitPattern = lossBitPattern
        self.rawGradientNormBitPattern =
            rawGradientNormBitPattern
        self.clippedGradientNormBitPattern =
            clippedGradientNormBitPattern
        self.clippedGradient = clippedGradient
        self.model = model
        self.firstMoment = firstMoment
        self.secondMoment = secondMoment
        self.fixedLogits = fixedLogits
        self.cursor = cursor
        self.nextInputSHA256 = nextInputSHA256
    }

    public func validate() throws {
        let fullStateBytes =
            PrimeNative3BMetalContinuationContract
                .fullStateLogicalByteCount
        guard step == 1 || step == 2,
              cursor == step,
              PrimeNative3BContinuationValidation
                .isSHA256(inputSHA256),
              PrimeNative3BContinuationValidation
                .isSHA256(nextInputSHA256),
              inputSHA256 != nextInputSHA256,
              Float(bitPattern: lossBitPattern).isFinite,
              Float(
                  bitPattern: rawGradientNormBitPattern
              ).isFinite,
              Float(
                  bitPattern:
                    clippedGradientNormBitPattern
              ).isFinite,
              Float(
                  bitPattern: rawGradientNormBitPattern
              ) >= 0,
              Float(
                  bitPattern:
                    clippedGradientNormBitPattern
              ) >= 0
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B step, input, exact loss, or schedule cursor is invalid"
                )
        }

        try clippedGradient.validate(
            expectedLabel:
                PrimeNative3BContinuationCatalogLabel
                    .clippedGradient,
            expectedLogicalByteCount: fullStateBytes
        )
        try model.validate(
            expectedLabel:
                PrimeNative3BContinuationCatalogLabel.model,
            expectedLogicalByteCount: fullStateBytes
        )
        try firstMoment.validate(
            expectedLabel:
                PrimeNative3BContinuationCatalogLabel
                    .firstMoment,
            expectedLogicalByteCount: fullStateBytes
        )
        try secondMoment.validate(
            expectedLabel:
                PrimeNative3BContinuationCatalogLabel
                    .secondMoment,
            expectedLogicalByteCount: fullStateBytes
        )
        try fixedLogits.validate(
            expectedLabel:
                PrimeNative3BContinuationCatalogLabel
                    .fixedLogits,
            expectedLogicalByteCount:
                PrimeNative3BMetalContinuationContract
                    .fixedLogitsLogicalByteCount
        )

        let expectedFullStateTopology =
            PrimeNative3BMetalContinuationContract
                .fullStateTopology
        let fullStateCatalogs = [
            clippedGradient,
            model,
            firstMoment,
            secondMoment,
        ]
        guard fullStateCatalogs.allSatisfy({
            PrimeNative3BContinuationValidation
                .topology(of: $0)
                == expectedFullStateTopology
        }),
            PrimeNative3BContinuationValidation
                .topology(of: fixedLogits)
                == PrimeNative3BMetalContinuationContract
                    .fixedLogitsTopology
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B state or fixed-logit topology differs from the frozen Llama profile"
                )
        }
    }
}

/// State independently observed by a fresh restorer at the step-1 boundary.
///
/// Loss and gradient evidence belongs to the writer's completed optimizer
/// step and is deliberately absent here. Schedule fields are named as
/// carried-forward checkpoint provenance rather than restored measurements.
public struct PrimeNative3BContinuationRestoredStateWitness:
    Codable,
    Equatable,
    Sendable
{
    public let restoredAfterStep: Int
    public let checkpointStepWitnessSHA256: String
    public let carriedForwardInputSHA256: String
    public let carriedForwardCursor: Int
    public let carriedForwardNextInputSHA256: String
    public let model:
        PrimeNative3BContinuationTensorCatalog
    public let firstMoment:
        PrimeNative3BContinuationTensorCatalog
    public let secondMoment:
        PrimeNative3BContinuationTensorCatalog
    public let fixedLogits:
        PrimeNative3BContinuationTensorCatalog

    public init(
        restoredAfterStep: Int,
        checkpointStepWitnessSHA256: String,
        carriedForwardInputSHA256: String,
        carriedForwardCursor: Int,
        carriedForwardNextInputSHA256: String,
        model:
            PrimeNative3BContinuationTensorCatalog,
        firstMoment:
            PrimeNative3BContinuationTensorCatalog,
        secondMoment:
            PrimeNative3BContinuationTensorCatalog,
        fixedLogits:
            PrimeNative3BContinuationTensorCatalog
    ) {
        self.restoredAfterStep = restoredAfterStep
        self.checkpointStepWitnessSHA256 =
            checkpointStepWitnessSHA256
        self.carriedForwardInputSHA256 =
            carriedForwardInputSHA256
        self.carriedForwardCursor =
            carriedForwardCursor
        self.carriedForwardNextInputSHA256 =
            carriedForwardNextInputSHA256
        self.model = model
        self.firstMoment = firstMoment
        self.secondMoment = secondMoment
        self.fixedLogits = fixedLogits
    }

    public func validate() throws {
        let fullStateBytes =
            PrimeNative3BMetalContinuationContract
                .fullStateLogicalByteCount
        guard restoredAfterStep == 1,
              carriedForwardCursor
                == restoredAfterStep,
              PrimeNative3BContinuationValidation
                .isSHA256(
                    checkpointStepWitnessSHA256
                ),
              PrimeNative3BContinuationValidation
                .isSHA256(
                    carriedForwardInputSHA256
                ),
              PrimeNative3BContinuationValidation
                .isSHA256(
                    carriedForwardNextInputSHA256
                ),
              carriedForwardInputSHA256
                != carriedForwardNextInputSHA256 else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B restored-state checkpoint provenance is invalid"
                )
        }
        try model.validate(
            expectedLabel:
                PrimeNative3BContinuationCatalogLabel
                    .model,
            expectedLogicalByteCount: fullStateBytes
        )
        try firstMoment.validate(
            expectedLabel:
                PrimeNative3BContinuationCatalogLabel
                    .firstMoment,
            expectedLogicalByteCount: fullStateBytes
        )
        try secondMoment.validate(
            expectedLabel:
                PrimeNative3BContinuationCatalogLabel
                    .secondMoment,
            expectedLogicalByteCount: fullStateBytes
        )
        try fixedLogits.validate(
            expectedLabel:
                PrimeNative3BContinuationCatalogLabel
                    .fixedLogits,
            expectedLogicalByteCount:
                PrimeNative3BMetalContinuationContract
                    .fixedLogitsLogicalByteCount
        )
        let fullStateTopology =
            PrimeNative3BMetalContinuationContract
                .fullStateTopology
        guard [
            model,
            firstMoment,
            secondMoment,
        ].allSatisfy({
            PrimeNative3BContinuationValidation
                .topology(of: $0)
                == fullStateTopology
        }),
            PrimeNative3BContinuationValidation
                .topology(of: fixedLogits)
                == PrimeNative3BMetalContinuationContract
                    .fixedLogitsTopology else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B restored state differs from the frozen Llama topology"
                )
        }
    }
}

/// Immutable model and typed Adam moment artifacts at the step-1 boundary.
///
/// PrimeCore is intentionally MLX-free, so this declaration validates binding
/// identity and a conservative payload-size floor. The authority-bearing
/// runtime must descriptor-load every safetensors component, materialize its
/// arrays, and reconcile its metadata and logical tensor catalog with
/// `stepOneWitness` before it publishes restore evidence.
public struct PrimeNative3BContinuationCheckpointManifest:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let plan: PrimeNativeArcContinuityPlan
    public let profile: PrimeNativeModelProfile
    public let optimizerConfiguration:
        PrimeTypedOptimizerConfiguration
    public let seeds: PrimeExecutionSeeds
    public let model: PrimeArtifactBinding
    public let firstMoment: PrimeArtifactBinding
    public let secondMoment: PrimeArtifactBinding
    public let stepOneWitness:
        PrimeNative3BContinuationStepWitness

    public var m: PrimeArtifactBinding {
        firstMoment
    }

    public var v: PrimeArtifactBinding {
        secondMoment
    }

    public var step1Witness:
        PrimeNative3BContinuationStepWitness
    {
        stepOneWitness
    }

    public init(
        seeds: PrimeExecutionSeeds,
        model: PrimeArtifactBinding,
        firstMoment: PrimeArtifactBinding,
        secondMoment: PrimeArtifactBinding,
        stepOneWitness:
            PrimeNative3BContinuationStepWitness
    ) {
        schemaVersion =
            PrimeNative3BMetalContinuationContract
                .schemaVersion
        artifactKind =
            "prime_native_3b_metal_checkpoint_manifest"
        plan = .frozenV1
        profile = PrimeNativeProfiles.exact3B
        optimizerConfiguration = .frozenAdamW
        self.seeds = seeds
        self.model = model
        self.firstMoment = firstMoment
        self.secondMoment = secondMoment
        self.stepOneWitness = stepOneWitness
    }

    public func validate() throws {
        guard schemaVersion
                == PrimeNative3BMetalContinuationContract
                    .schemaVersion,
              artifactKind
                == "prime_native_3b_metal_checkpoint_manifest",
              plan == .frozenV1,
              profile == PrimeNativeProfiles.exact3B,
              optimizerConfiguration == .frozenAdamW,
              seeds
                == (try PrimeNative3BMetalContinuationContract
                    .frozenSeeds()),
              stepOneWitness.step == 1 else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B checkpoint scope, profile, optimizer, seeds, or step is invalid"
                )
        }
        try plan.validate()
        try stepOneWitness.validate()
        let artifacts = [
            model,
            firstMoment,
            secondMoment,
        ]
        for artifact in artifacts {
            try artifact.validateDeclaration()
        }
        guard artifacts.allSatisfy({
            $0.purpose == .immutableData
                && $0.byteCount
                    >= PrimeNative3BMetalContinuationContract
                        .fullStateLogicalByteCount
                && $0.byteCount
                    <= PrimeNative3BMetalContinuationContract
                        .checkpointComponentMaximumByteCount
        }),
            Set(artifacts.map(\.relativePath)).count
                == artifacts.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B checkpoint artifacts must be three distinct immutable files large enough for their FP32 state"
                )
        }
    }
}

/// The four already-durable Prime artifacts admitted as prior evidence.
public struct PrimeNative3BContinuationPriorEvidenceBindings:
    Codable,
    Equatable,
    Sendable
{
    public let exact3BMechanicsReceipt:
        PrimeArtifactBinding
    public let exact3BExecutionConfiguration:
        PrimeArtifactBinding
    public let exact3BSourceSnapshot:
        PrimeArtifactBinding
    public let typedOptimizerRestoreReceipt:
        PrimeArtifactBinding

    public init(
        exact3BMechanicsReceipt:
            PrimeArtifactBinding,
        exact3BExecutionConfiguration:
            PrimeArtifactBinding,
        exact3BSourceSnapshot:
            PrimeArtifactBinding,
        typedOptimizerRestoreReceipt:
            PrimeArtifactBinding
    ) {
        self.exact3BMechanicsReceipt =
            exact3BMechanicsReceipt
        self.exact3BExecutionConfiguration =
            exact3BExecutionConfiguration
        self.exact3BSourceSnapshot =
            exact3BSourceSnapshot
        self.typedOptimizerRestoreReceipt =
            typedOptimizerRestoreReceipt
    }

    public var artifacts: [PrimeArtifactBinding] {
        [
            exact3BMechanicsReceipt,
            exact3BExecutionConfiguration,
            exact3BSourceSnapshot,
            typedOptimizerRestoreReceipt,
        ]
    }

    public func validate() throws {
        let plan = PrimeNativeArcContinuityPlan.frozenV1
        let expectedByID = Dictionary(
            uniqueKeysWithValues:
                plan.artifacts.map {
                    ($0.artifactID, $0)
                }
        )
        let bindingsByID: [
            (String, PrimeArtifactBinding)
        ] = [
            (
                "prime_exact_3b_fp32_mechanics_receipt",
                exact3BMechanicsReceipt
            ),
            (
                "prime_exact_3b_fp32_execution_configuration",
                exact3BExecutionConfiguration
            ),
            (
                "prime_exact_3b_fp32_source_snapshot",
                exact3BSourceSnapshot
            ),
            (
                "prime_typed_optimizer_restore_receipt",
                typedOptimizerRestoreReceipt
            ),
        ]
        guard bindingsByID.map(\.0)
                == plan.currentSliceRequiredArtifactIDs
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B prior-evidence inventory drifted"
                )
        }
        for (artifactID, binding) in bindingsByID {
            try binding.validateDeclaration()
            guard let expected =
                    expectedByID[artifactID],
                  binding.sha256 == expected.sha256,
                  binding.purpose == .immutableData,
                  binding.byteCount > 0 else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "native 3B prior evidence does not bind the frozen Prime artifact"
                    )
            }
        }
        guard Set(artifacts.map(\.relativePath)).count
                == artifacts.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B prior-evidence paths must be distinct"
                )
        }
    }
}

/// Live dependency identity for the descriptor-backed continuation seam.
///
/// This plan is intentionally separate from
/// `PrimeTypedOptimizerRestorePlan.frozenSchemaV2`: the durable CPU receipt
/// remains bound to its historical fork revision while this Metal gate may
/// advance to the narrowly reviewed descriptor-backed safetensors revision.
public struct PrimeNative3BContinuationDependencyPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let forkRepository: String
    public let forkRevision: String
    public let packageManifestSHA256: String
    public let packageResolutionSHA256: String
    public let mirrorConfigurationSHA256: String
    public let dependencyTreeManifestSHA256: String
    public let licenseSHA256: String
    public let typedStateSourceSHA256: String
    public let optimizerSourceSHA256: String
    public let ioSourceSHA256: String
    public let typedStateSourcePath: String
    public let optimizerSourcePath: String
    public let ioSourcePath: String

    /// Filled with the descriptor-backed fork commit and reviewed source
    /// hashes before an execution receipt can become durable authority.
    public static let frozenV1 = Self(
        schemaVersion: 1,
        forkRepository:
            "https://github.com/Ergentics/ergentics-mlx-swift",
        forkRevision:
            "275cf507d262c12b6f5759af209a7218810c4912",
        packageManifestSHA256:
            "8d13eeb9a464d6b6d236285fd727b1df2f6994c28a848b4966f9faef25a0e6ac",
        packageResolutionSHA256:
            "ab5eeafad74b443c52c865d297fc5e52e5696b0c666e3341fd25cbb28e83a696",
        mirrorConfigurationSHA256:
            "6124788421eab5803c52b508338ec085a95753b871582951acbb3005b1dc2cc6",
        dependencyTreeManifestSHA256:
            "e4b71d72817196af7427a0ef08c08153a0465d7aa66d0f7b2f934593c474bef7",
        licenseSHA256:
            PrimeTypedOptimizerRestorePlan
                .frozenSchemaV2
                .dependencyLicenseSHA256,
        typedStateSourceSHA256:
            PrimeTypedOptimizerRestorePlan
                .frozenSchemaV2
                .typedStateSourceSHA256,
        optimizerSourceSHA256:
            PrimeTypedOptimizerRestorePlan
                .frozenSchemaV2
                .optimizerSourceSHA256,
        ioSourceSHA256:
            "60b0f7fff4c9c2873845b506887875b920256a2a2a538020bdf846c73abdbe1d",
        typedStateSourcePath:
            "Source/MLXOptimizers/AdamOptimizerState.swift",
        optimizerSourcePath:
            "Source/MLXOptimizers/Optimizers.swift",
        ioSourcePath:
            "Source/MLX/FileDescriptorIO.swift"
    )

    public init(
        schemaVersion: Int,
        forkRepository: String,
        forkRevision: String,
        packageManifestSHA256: String,
        packageResolutionSHA256: String,
        mirrorConfigurationSHA256: String,
        dependencyTreeManifestSHA256: String,
        licenseSHA256: String,
        typedStateSourceSHA256: String,
        optimizerSourceSHA256: String,
        ioSourceSHA256: String,
        typedStateSourcePath: String,
        optimizerSourcePath: String,
        ioSourcePath: String
    ) {
        self.schemaVersion = schemaVersion
        self.forkRepository = forkRepository
        self.forkRevision = forkRevision
        self.packageManifestSHA256 =
            packageManifestSHA256
        self.packageResolutionSHA256 =
            packageResolutionSHA256
        self.mirrorConfigurationSHA256 =
            mirrorConfigurationSHA256
        self.dependencyTreeManifestSHA256 =
            dependencyTreeManifestSHA256
        self.licenseSHA256 = licenseSHA256
        self.typedStateSourceSHA256 =
            typedStateSourceSHA256
        self.optimizerSourceSHA256 =
            optimizerSourceSHA256
        self.ioSourceSHA256 = ioSourceSHA256
        self.typedStateSourcePath =
            typedStateSourcePath
        self.optimizerSourcePath =
            optimizerSourcePath
        self.ioSourcePath = ioSourcePath
    }

    public func validate() throws {
        let hashes = [
            packageManifestSHA256,
            packageResolutionSHA256,
            mirrorConfigurationSHA256,
            dependencyTreeManifestSHA256,
            licenseSHA256,
            typedStateSourceSHA256,
            optimizerSourceSHA256,
            ioSourceSHA256,
        ]
        guard self == .frozenV1,
              schemaVersion == 1,
              forkRevision.utf8.count == 40,
              forkRevision.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 97 && $0 <= 102)
              }),
              !PrimeNative3BContinuationValidation
                .isAllZeroHex(forkRevision),
              hashes.allSatisfy(
                  PrimeNative3BContinuationValidation
                    .isSHA256
              ),
              hashes.allSatisfy({
                  !PrimeNative3BContinuationValidation
                    .isAllZeroHex($0)
              }),
              typedStateSourcePath
                == "Source/MLXOptimizers/AdamOptimizerState.swift",
              optimizerSourcePath
                == "Source/MLXOptimizers/Optimizers.swift",
              ioSourcePath
                == "Source/MLX/FileDescriptorIO.swift" else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B live continuation dependency plan drifted"
                )
        }
    }
}

public struct PrimeNative3BContinuationDependencyEvidence:
    Codable,
    Equatable,
    Sendable
{
    public let packageManifest: PrimeArtifactBinding
    public let packageResolution: PrimeArtifactBinding
    public let mirrorConfiguration: PrimeArtifactBinding
    public let dependencyTreeManifest:
        PrimeArtifactBinding
    public let license: PrimeArtifactBinding
    public let typedStateSource: PrimeArtifactBinding
    public let optimizerSource: PrimeArtifactBinding
    public let ioSource: PrimeArtifactBinding

    public init(
        packageManifest: PrimeArtifactBinding,
        packageResolution: PrimeArtifactBinding,
        mirrorConfiguration: PrimeArtifactBinding,
        dependencyTreeManifest:
            PrimeArtifactBinding,
        license: PrimeArtifactBinding,
        typedStateSource: PrimeArtifactBinding,
        optimizerSource: PrimeArtifactBinding,
        ioSource: PrimeArtifactBinding
    ) {
        self.packageManifest = packageManifest
        self.packageResolution = packageResolution
        self.mirrorConfiguration =
            mirrorConfiguration
        self.dependencyTreeManifest =
            dependencyTreeManifest
        self.license = license
        self.typedStateSource = typedStateSource
        self.optimizerSource = optimizerSource
        self.ioSource = ioSource
    }

    public var artifacts: [PrimeArtifactBinding] {
        [
            packageManifest,
            packageResolution,
            mirrorConfiguration,
            dependencyTreeManifest,
            license,
            typedStateSource,
            optimizerSource,
            ioSource,
        ]
    }

    public func validate(
        plan: PrimeNative3BContinuationDependencyPlan
    ) throws {
        try plan.validate()
        let expectedHashes = [
            plan.packageManifestSHA256,
            plan.packageResolutionSHA256,
            plan.mirrorConfigurationSHA256,
            plan.dependencyTreeManifestSHA256,
            plan.licenseSHA256,
            plan.typedStateSourceSHA256,
            plan.optimizerSourceSHA256,
            plan.ioSourceSHA256,
        ]
        for artifact in artifacts {
            try artifact.validateDeclaration()
        }
        guard artifacts.map(\.sha256)
                == expectedHashes,
              artifacts.allSatisfy({
                  $0.purpose == .immutableData
                      && $0.byteCount > 0
              }),
              Set(artifacts.map(\.relativePath))
                .count == artifacts.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B live dependency evidence is incomplete or differs from the continuation plan"
                )
        }
    }
}

public struct PrimeNative3BMetalContinuationWorkerRecord:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let role:
        PrimeNative3BMetalContinuationWorkerRole
    public let processIdentifier: Int32
    public let executable: PrimeArtifactBinding
    public let runtimeImage:
        PrimePinnedMLXMetallibBinding
    public let sourceSnapshot: PrimeArtifactBinding
    public let priorEvidence:
        PrimeNative3BContinuationPriorEvidenceBindings
    public let continuationDependencyPlan:
        PrimeNative3BContinuationDependencyPlan
    public let continuationDependencyEvidence:
        PrimeNative3BContinuationDependencyEvidence
    public let plan: PrimeNativeArcContinuityPlan
    public let profile: PrimeNativeModelProfile
    public let optimizerConfiguration:
        PrimeTypedOptimizerConfiguration
    public let seeds: PrimeExecutionSeeds
    public let initialModel:
        PrimeNative3BContinuationTensorCatalog
    public let poisonModel:
        PrimeNative3BContinuationTensorCatalog?
    public let checkpointManifest:
        PrimeNative3BContinuationCheckpointManifest?
    public let writerRecord: PrimeArtifactBinding?
    public let restoredStateWitness:
        PrimeNative3BContinuationRestoredStateWitness?
    public let witnesses:
        [PrimeNative3BContinuationStepWitness]

    public init(
        role:
            PrimeNative3BMetalContinuationWorkerRole,
        processIdentifier: Int32,
        executable: PrimeArtifactBinding,
        runtimeImage:
            PrimePinnedMLXMetallibBinding,
        sourceSnapshot: PrimeArtifactBinding,
        priorEvidence:
            PrimeNative3BContinuationPriorEvidenceBindings,
        continuationDependencyEvidence:
            PrimeNative3BContinuationDependencyEvidence,
        seeds: PrimeExecutionSeeds,
        initialModel:
            PrimeNative3BContinuationTensorCatalog,
        poisonModel:
            PrimeNative3BContinuationTensorCatalog? = nil,
        checkpointManifest:
            PrimeNative3BContinuationCheckpointManifest? = nil,
        writerRecord: PrimeArtifactBinding? = nil,
        restoredStateWitness:
            PrimeNative3BContinuationRestoredStateWitness? = nil,
        witnesses:
            [PrimeNative3BContinuationStepWitness]
    ) {
        schemaVersion =
            PrimeNative3BMetalContinuationContract
                .schemaVersion
        artifactKind =
            "prime_native_3b_metal_worker_record"
        self.role = role
        self.processIdentifier = processIdentifier
        self.executable = executable
        self.runtimeImage = runtimeImage
        self.sourceSnapshot = sourceSnapshot
        self.priorEvidence = priorEvidence
        continuationDependencyPlan = .frozenV1
        self.continuationDependencyEvidence =
            continuationDependencyEvidence
        plan = .frozenV1
        profile = PrimeNativeProfiles.exact3B
        optimizerConfiguration = .frozenAdamW
        self.seeds = seeds
        self.initialModel = initialModel
        self.poisonModel = poisonModel
        self.checkpointManifest =
            checkpointManifest
        self.writerRecord = writerRecord
        self.restoredStateWitness =
            restoredStateWitness
        self.witnesses = witnesses
    }

    public func witness(
        at step: Int
    ) -> PrimeNative3BContinuationStepWitness? {
        witnesses.first { $0.step == step }
    }

    public func validate() throws {
        let fullStateBytes =
            PrimeNative3BMetalContinuationContract
                .fullStateLogicalByteCount
        guard schemaVersion
                == PrimeNative3BMetalContinuationContract
                    .schemaVersion,
              artifactKind
                == "prime_native_3b_metal_worker_record",
              processIdentifier > 0,
              plan == .frozenV1,
              profile == PrimeNativeProfiles.exact3B,
              optimizerConfiguration == .frozenAdamW,
              continuationDependencyPlan == .frozenV1,
              seeds
                == (try PrimeNative3BMetalContinuationContract
                    .frozenSeeds()) else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B worker scope, PID, profile, optimizer, or seeds is invalid"
                )
        }
        try plan.validate()
        try executable.validateDeclaration()
        try sourceSnapshot.validateDeclaration()
        try runtimeImage.validateDeclaration()
        try PrimeMLXRuntimeImageLayout.require(
            runtimeImage.runtimeImageLayout,
            for: .native3BMetalContinuationProbe
        )
        try priorEvidence.validate()
        try continuationDependencyEvidence.validate(
            plan: continuationDependencyPlan
        )
        try initialModel.validate(
            expectedLabel:
                PrimeNative3BContinuationCatalogLabel
                    .initialModel,
            expectedLogicalByteCount: fullStateBytes
        )
        guard executable.purpose == .executable,
              sourceSnapshot.purpose == .immutableData,
              witnesses.map(\.step)
                == witnesses.map(\.step).sorted(),
              Set(witnesses.map(\.step)).count
                == witnesses.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B worker provenance or witness order is invalid"
                )
        }
        for witness in witnesses {
            try witness.validate()
            guard PrimeNative3BContinuationValidation
                    .topology(of: initialModel)
                    == PrimeNative3BContinuationValidation
                        .topology(of: witness.model)
            else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "native 3B initial and step model topologies diverge"
                    )
            }
        }
        if witnesses.count == 2 {
            guard witnesses[0].nextInputSHA256
                    == witnesses[1].inputSHA256 else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "native 3B schedule cursor does not bind the next input"
                    )
            }
        }

        switch role {
        case .control:
            guard witnesses.map(\.step) == [1, 2],
                  poisonModel == nil,
                  checkpointManifest == nil,
                  writerRecord == nil,
                  restoredStateWitness == nil else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "native 3B control worker claimed interruption-only state"
                    )
            }
        case .writer:
            guard witnesses.map(\.step) == [1],
                  poisonModel == nil,
                  writerRecord == nil,
                  restoredStateWitness == nil else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "native 3B writer checkpoint contract is invalid"
                    )
            }
            if let checkpointManifest {
                guard checkpointManifest.stepOneWitness
                        == witnesses[0] else {
                    throw PrimeDurableArtifactError
                        .invalidSemantics(
                            "native 3B writer checkpoint differs from its step-1 witness"
                        )
                }
                try checkpointManifest.validate()
            }
        case .restorer:
            guard witnesses.map(\.step) == [2],
                  let poisonModel,
                  let checkpointManifest,
                  let writerRecord,
                  let restoredStateWitness,
                  poisonModel != initialModel,
                  poisonModel.aggregateSHA256
                    != initialModel.aggregateSHA256,
                  checkpointManifest.seeds == seeds,
                  writerRecord.purpose == .immutableData,
                  restoredStateWitness
                    .carriedForwardNextInputSHA256
                    == witnesses[0].inputSHA256
            else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "native 3B restorer must bind a writer checkpoint and a distinct poison trajectory"
                    )
            }
            try restoredStateWitness.validate()
            let checkpointWitness =
                checkpointManifest.stepOneWitness
            let checkpointWitnessSHA256 =
                PrimeSHA256.hexDigest(
                    of: try PrimeCanonicalJSON.encode(
                        checkpointWitness
                    )
                )
            guard restoredStateWitness
                    .checkpointStepWitnessSHA256
                    == checkpointWitnessSHA256,
                  restoredStateWitness
                    .restoredAfterStep
                    == checkpointWitness.step,
                  restoredStateWitness
                    .carriedForwardInputSHA256
                    == checkpointWitness.inputSHA256,
                  restoredStateWitness
                    .carriedForwardCursor
                    == checkpointWitness.cursor,
                  restoredStateWitness
                    .carriedForwardNextInputSHA256
                    == checkpointWitness
                        .nextInputSHA256,
                  PrimeNative3BContinuationValidation
                    .topology(
                        of:
                            restoredStateWitness
                            .model
                    )
                    == PrimeNative3BContinuationValidation
                        .topology(of: initialModel)
            else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "native 3B restored state does not bind checkpoint provenance"
                    )
            }
            try poisonModel.validate(
                expectedLabel:
                    PrimeNative3BContinuationCatalogLabel
                        .poisonModel,
                expectedLogicalByteCount: fullStateBytes
            )
            guard PrimeNative3BContinuationValidation
                    .topology(of: poisonModel)
                    == PrimeNative3BContinuationValidation
                        .topology(of: initialModel) else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "native 3B poison model topology diverges"
                    )
            }
            try checkpointManifest.validate()
            try writerRecord.validateDeclaration()
        }
    }
}

public struct PrimeNative3BContinuationComparisonResult:
    Codable,
    Equatable,
    Sendable
{
    public let exact: Bool
    public let firstMismatch: String?

    public init(
        exact: Bool,
        firstMismatch: String?
    ) {
        self.exact = exact
        self.firstMismatch = firstMismatch
    }

    public static let exactMatch = Self(
        exact: true,
        firstMismatch: nil
    )

    public func validate() throws {
        guard exact == (firstMismatch == nil),
              firstMismatch?.isEmpty != true,
              firstMismatch?.utf8.allSatisfy({
                  $0 >= 0x20 && $0 <= 0x7e
              }) != false else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B exact comparison and first mismatch disagree"
                )
        }
    }
}

/// Exact logical comparison helpers. No tolerance-bearing API is exposed.
public enum PrimeNative3BContinuationReconciler {
    public static func aggregateSHA256(
        for entries:
            [PrimeNative3BContinuationTensorEntry]
    ) throws -> String {
        PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(entries)
        )
    }

    public static func compare(
        expected:
            PrimeNative3BContinuationStepWitness,
        observed:
            PrimeNative3BContinuationStepWitness
    ) -> PrimeNative3BContinuationComparisonResult {
        if expected.step != observed.step {
            return mismatch("step")
        }
        if expected.inputSHA256
            != observed.inputSHA256
        {
            return mismatch("input_sha256")
        }
        if expected.lossBitPattern
            != observed.lossBitPattern
        {
            return mismatch("loss_bit_pattern")
        }
        if expected.rawGradientNormBitPattern
            != observed.rawGradientNormBitPattern
        {
            return mismatch(
                "raw_gradient_norm_bit_pattern"
            )
        }
        if expected.clippedGradientNormBitPattern
            != observed.clippedGradientNormBitPattern
        {
            return mismatch(
                "clipped_gradient_norm_bit_pattern"
            )
        }
        for (
            label,
            expectedCatalog,
            observedCatalog
        ) in [
            (
                "clipped_gradient",
                expected.clippedGradient,
                observed.clippedGradient
            ),
            (
                "model",
                expected.model,
                observed.model
            ),
            (
                "first_moment",
                expected.firstMoment,
                observed.firstMoment
            ),
            (
                "second_moment",
                expected.secondMoment,
                observed.secondMoment
            ),
            (
                "fixed_logits",
                expected.fixedLogits,
                observed.fixedLogits
            ),
        ] {
            if let detail = firstMismatch(
                expected: expectedCatalog,
                observed: observedCatalog
            ) {
                return mismatch("\(label).\(detail)")
            }
        }
        if expected.cursor != observed.cursor {
            return mismatch("cursor")
        }
        if expected.nextInputSHA256
            != observed.nextInputSHA256
        {
            return mismatch("next_input_sha256")
        }
        return .exactMatch
    }

    /// Compares only state that a fresh restorer actually observes at N.
    ///
    /// Loss and clipped gradients belong to the writer's completed step and
    /// are deliberately excluded rather than copied into restore evidence.
    public static func compareRestoredState(
        expected:
            PrimeNative3BContinuationStepWitness,
        observed:
            PrimeNative3BContinuationRestoredStateWitness
    ) -> PrimeNative3BContinuationComparisonResult {
        if expected.step
            != observed.restoredAfterStep
        {
            return mismatch("step")
        }
        guard let encoded =
                try? PrimeCanonicalJSON.encode(
                    expected
                ) else {
            return mismatch(
                "checkpoint_step_witness_encoding"
            )
        }
        if PrimeSHA256.hexDigest(of: encoded)
            != observed.checkpointStepWitnessSHA256
        {
            return mismatch(
                "checkpoint_step_witness_sha256"
            )
        }
        if expected.inputSHA256
            != observed.carriedForwardInputSHA256
        {
            return mismatch(
                "carried_forward_input_sha256"
            )
        }
        if expected.cursor
            != observed.carriedForwardCursor
        {
            return mismatch(
                "carried_forward_cursor"
            )
        }
        if expected.nextInputSHA256
            != observed
            .carriedForwardNextInputSHA256
        {
            return mismatch(
                "carried_forward_next_input_sha256"
            )
        }
        for (
            label,
            expectedCatalog,
            observedCatalog
        ) in [
            (
                "model",
                expected.model,
                observed.model
            ),
            (
                "first_moment",
                expected.firstMoment,
                observed.firstMoment
            ),
            (
                "second_moment",
                expected.secondMoment,
                observed.secondMoment
            ),
            (
                "fixed_logits",
                expected.fixedLogits,
                observed.fixedLogits
            ),
        ] {
            if let detail = firstMismatch(
                expected: expectedCatalog,
                observed: observedCatalog
            ) {
                return mismatch("\(label).\(detail)")
            }
        }
        return .exactMatch
    }

    public static func compare(
        expected:
            PrimeNative3BContinuationTensorCatalog,
        observed:
            PrimeNative3BContinuationTensorCatalog
    ) -> PrimeNative3BContinuationComparisonResult {
        guard let detail = firstMismatch(
            expected: expected,
            observed: observed
        ) else {
            return .exactMatch
        }
        return mismatch(detail)
    }

    private static func firstMismatch(
        expected:
            PrimeNative3BContinuationTensorCatalog,
        observed:
            PrimeNative3BContinuationTensorCatalog
    ) -> String? {
        if expected.label != observed.label {
            return "label"
        }
        if expected.entries.count
            != observed.entries.count
        {
            return "entry_count"
        }
        for index in expected.entries.indices {
            let lhs = expected.entries[index]
            let rhs = observed.entries[index]
            let prefix = "entries[\(index)]"
            if lhs.path != rhs.path {
                return "\(prefix).path"
            }
            if lhs.shape != rhs.shape {
                return "\(prefix).shape"
            }
            if lhs.dtype != rhs.dtype {
                return "\(prefix).dtype"
            }
            if lhs.byteCount != rhs.byteCount {
                return "\(prefix).byte_count"
            }
            if lhs.sha256 != rhs.sha256 {
                return "\(prefix).sha256"
            }
            if lhs.finite != rhs.finite {
                return "\(prefix).finite"
            }
            if lhs.nonzero != rhs.nonzero {
                return "\(prefix).nonzero"
            }
        }
        if expected.aggregateSHA256
            != observed.aggregateSHA256
        {
            return "aggregate_sha256"
        }
        return nil
    }

    private static func mismatch(
        _ detail: String
    ) -> PrimeNative3BContinuationComparisonResult {
        PrimeNative3BContinuationComparisonResult(
            exact: false,
            firstMismatch: detail
        )
    }
}

public enum PrimeNative3BMetalContinuationOutcome:
    String,
    Codable,
    Equatable,
    Sendable
{
    case pass = "PASS"
    case abstain = "ABSTAIN"
}

public enum PrimeNative3BChildTerminationReason:
    String,
    Codable,
    Equatable,
    Sendable
{
    case exit
    case uncaughtSignal
}

/// Facts observed by the parent supervisor rather than asserted by a worker.
///
/// The worker-record binding associates the actual launched PID and bounded
/// output with the exact immutable record decoded into the receipt.
public struct PrimeNative3BSupervisorProcessObservation:
    Codable,
    Equatable,
    Sendable
{
    public let role:
        PrimeNative3BMetalContinuationWorkerRole
    public let processIdentifier: Int32
    public let terminationReason:
        PrimeNative3BChildTerminationReason
    public let terminationStatus: Int32
    public let outputByteCount: UInt64
    public let outputSHA256: String
    public let outputOverflowed: Bool
    public let outputDrainCompleted: Bool
    public let workerRecord: PrimeArtifactBinding

    public init(
        role:
            PrimeNative3BMetalContinuationWorkerRole,
        processIdentifier: Int32,
        terminationReason:
            PrimeNative3BChildTerminationReason,
        terminationStatus: Int32,
        outputByteCount: UInt64,
        outputSHA256: String,
        outputOverflowed: Bool,
        outputDrainCompleted: Bool,
        workerRecord: PrimeArtifactBinding
    ) {
        self.role = role
        self.processIdentifier = processIdentifier
        self.terminationReason =
            terminationReason
        self.terminationStatus =
            terminationStatus
        self.outputByteCount = outputByteCount
        self.outputSHA256 = outputSHA256
        self.outputOverflowed = outputOverflowed
        self.outputDrainCompleted =
            outputDrainCompleted
        self.workerRecord = workerRecord
    }

    public func validate() throws {
        try workerRecord.validateDeclaration()
        guard processIdentifier > 0,
              terminationReason == .exit,
              terminationStatus == 0,
              outputByteCount
                <= PrimeNative3BMetalContinuationContract
                    .childOutputMaximumByteCount,
              PrimeNative3BContinuationValidation
                .isSHA256(outputSHA256),
              !outputOverflowed,
              outputDrainCompleted,
              workerRecord.purpose
                == .immutableData else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B supervisor process evidence is invalid"
                )
        }
    }
}

/// Final three-process receipt for the bounded two-step mechanics gate.
///
/// A PASS is derived from the embedded worker evidence. Supplied comparison
/// booleans are recomputed and cannot promote a divergent trajectory.
public struct PrimeNative3BMetalContinuationReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let outcome:
        PrimeNative3BMetalContinuationOutcome
    public let recordedAtUTC: String
    public let plan: PrimeNativeArcContinuityPlan
    public let profile: PrimeNativeModelProfile
    public let optimizerConfiguration:
        PrimeTypedOptimizerConfiguration
    public let seeds: PrimeExecutionSeeds
    public let controlRecord: PrimeArtifactBinding
    public let writerRecord: PrimeArtifactBinding
    public let restorerRecord:
        PrimeObservation<PrimeArtifactBinding>
    public let workers:
        [PrimeNative3BMetalContinuationWorkerRecord]
    public let supervisorProcesses:
        [PrimeNative3BSupervisorProcessObservation]
    public let preSaveComparison:
        PrimeObservation<
            PrimeNative3BContinuationComparisonResult
        >
    public let restoredAtNComparison:
        PrimeObservation<
            PrimeNative3BContinuationComparisonResult
        >
    public let continuedAtNPlus1Comparison:
        PrimeObservation<
            PrimeNative3BContinuationComparisonResult
        >
    public let longTrainingPerformed: Bool
    public let productPromotionClaimed: Bool
    public let profilePromotionClaimed: Bool

    public init(
        outcome:
            PrimeNative3BMetalContinuationOutcome,
        recordedAtUTC: String,
        seeds: PrimeExecutionSeeds,
        controlRecord: PrimeArtifactBinding,
        writerRecord: PrimeArtifactBinding,
        restorerRecord:
            PrimeObservation<PrimeArtifactBinding>,
        workers:
            [PrimeNative3BMetalContinuationWorkerRecord],
        supervisorProcesses:
            [PrimeNative3BSupervisorProcessObservation],
        preSaveComparison:
            PrimeObservation<
                PrimeNative3BContinuationComparisonResult
            >,
        restoredAtNComparison:
            PrimeObservation<
                PrimeNative3BContinuationComparisonResult
            >,
        continuedAtNPlus1Comparison:
            PrimeObservation<
                PrimeNative3BContinuationComparisonResult
            >
    ) {
        schemaVersion =
            PrimeNative3BMetalContinuationContract
                .schemaVersion
        artifactKind =
            PrimeNative3BMetalContinuationContract
                .artifactKind + "_receipt"
        self.outcome = outcome
        self.recordedAtUTC = recordedAtUTC
        plan = .frozenV1
        profile = PrimeNativeProfiles.exact3B
        optimizerConfiguration = .frozenAdamW
        self.seeds = seeds
        self.controlRecord = controlRecord
        self.writerRecord = writerRecord
        self.restorerRecord = restorerRecord
        self.workers = workers
        self.supervisorProcesses =
            supervisorProcesses
        self.preSaveComparison = preSaveComparison
        self.restoredAtNComparison =
            restoredAtNComparison
        self.continuedAtNPlus1Comparison =
            continuedAtNPlus1Comparison
        longTrainingPerformed = false
        productPromotionClaimed = false
        profilePromotionClaimed = false
    }

    public func validateStructure() throws {
        guard schemaVersion
                == PrimeNative3BMetalContinuationContract
                    .schemaVersion,
              artifactKind
                == "prime_native_3b_metal_continuation_receipt",
              ISO8601DateFormatter()
                .date(from: recordedAtUTC) != nil,
              plan == .frozenV1,
              profile == PrimeNativeProfiles.exact3B,
              optimizerConfiguration == .frozenAdamW,
              seeds
                == (try PrimeNative3BMetalContinuationContract
                    .frozenSeeds()),
              workers.map(\.role)
                == [.control, .writer]
                || workers.map(\.role)
                    == [.control, .writer, .restorer],
              workers.allSatisfy({
                  $0.processIdentifier > 0
              }),
              Set(workers.map(\.processIdentifier))
                .count == workers.count,
              supervisorProcesses.map(\.role)
                == workers.map(\.role),
              supervisorProcesses
                .map(\.processIdentifier)
                == workers.map(\.processIdentifier),
              Set(
                  supervisorProcesses
                    .map(\.processIdentifier)
              ).count == supervisorProcesses.count,
              !longTrainingPerformed,
              !productPromotionClaimed,
              !profilePromotionClaimed else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B continuation receipt scope, processes, or authority is invalid"
                )
        }
        try plan.validate()
        try restorerRecord.validate(
            "native 3B restorer record"
        )
        try preSaveComparison.validate(
            "native 3B pre-save comparison"
        )
        try restoredAtNComparison.validate(
            "native 3B restored-at-N comparison"
        )
        try continuedAtNPlus1Comparison.validate(
            "native 3B continued-at-N+1 comparison"
        )
        for worker in workers {
            try worker.validate()
        }
        for process in supervisorProcesses {
            try process.validate()
        }
        var records = [
            controlRecord,
            writerRecord,
        ]
        if let value = restorerRecord.value {
            records.append(value)
        }
        guard supervisorProcesses
                .map(\.workerRecord)
                == records else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B supervisor process evidence does not bind worker records"
                )
        }
        for record in records {
            try record.validateDeclaration()
        }
        guard records.allSatisfy({
            $0.purpose == .immutableData
        }),
            Set(records.map(\.relativePath)).count
                == records.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B worker record bindings are invalid"
                )
        }

        let control = workers[0]
        let writer = workers[1]
        guard control.executable == writer.executable,
              control.runtimeImage == writer.runtimeImage,
              control.sourceSnapshot
                == writer.sourceSnapshot,
              control.priorEvidence
                == writer.priorEvidence,
              control.continuationDependencyPlan
                == writer.continuationDependencyPlan,
              control.continuationDependencyEvidence
                == writer.continuationDependencyEvidence,
              control.initialModel
                == writer.initialModel,
              control.seeds == seeds,
              writer.seeds == seeds,
              let controlN =
                control.witness(at: 1),
              let controlNPlusOne =
                control.witness(at: 2),
              let writerN =
                writer.witness(at: 1)
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B workers do not share one provenance and interruption boundary"
                )
        }

        let expectedPreSave =
            PrimeNative3BContinuationReconciler
                .compare(
                    expected: controlN,
                    observed: writerN
                )
        guard preSaveComparison
                == .observed(expectedPreSave) else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B pre-save comparison was not derived from control and writer evidence"
                )
        }

        if !expectedPreSave.exact {
            guard outcome == .abstain,
                  workers.count == 2,
                  writer.checkpointManifest == nil,
                  !restorerRecord.observationAvailable,
                  !restoredAtNComparison
                    .observationAvailable,
                  !continuedAtNPlus1Comparison
                    .observationAvailable else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "native 3B pre-save divergence must suppress checkpoint and restorer claims"
                    )
            }
            return
        }

        guard workers.count == 3,
              let restorerRecordValue =
                restorerRecord.value,
              let checkpoint =
                writer.checkpointManifest else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B exact pre-save evidence must proceed through a bound fresh restorer"
                )
        }
        let restorer = workers[2]
        guard writer.executable == restorer.executable,
              writer.runtimeImage == restorer.runtimeImage,
              writer.sourceSnapshot
                == restorer.sourceSnapshot,
              writer.priorEvidence
                == restorer.priorEvidence,
              writer.continuationDependencyPlan
                == restorer.continuationDependencyPlan,
              writer.continuationDependencyEvidence
                == restorer
                    .continuationDependencyEvidence,
              writer.initialModel
                == restorer.initialModel,
              restorer.seeds == seeds,
              writer.checkpointManifest
                == restorer.checkpointManifest,
              restorer.writerRecord == writerRecord,
              restorerRecordValue.purpose
                == .immutableData,
              let restoredN =
                restorer.restoredStateWitness,
              let restoredNPlusOne =
                restorer.witness(at: 2),
              checkpoint.stepOneWitness == writerN
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B restorer does not bind the writer interruption boundary"
                )
        }

        let expectedRestoredAtN =
            PrimeNative3BContinuationReconciler
                .compareRestoredState(
                    expected:
                        checkpoint.stepOneWitness,
                    observed: restoredN
                )
        let expectedContinuedAtNPlusOne =
            PrimeNative3BContinuationReconciler
                .compare(
                    expected: controlNPlusOne,
                    observed: restoredNPlusOne
                )
        let allExact =
            expectedRestoredAtN.exact
            && expectedContinuedAtNPlusOne.exact
        guard restoredAtNComparison
                == .observed(expectedRestoredAtN),
              continuedAtNPlus1Comparison
                == .observed(
                    expectedContinuedAtNPlusOne
                ),
              outcome == (allExact ? .pass : .abstain)
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B receipt outcome does not follow all three exact comparisons"
                )
        }
    }

    /// Live artifact validation for an authoritative PASS or ABSTAIN receipt.
    public func validate(
        in root: PrimeArtifactRoot
    ) throws {
        try validateStructure()
        var decoded = [
            try root.decodeVerified(
                PrimeNative3BMetalContinuationWorkerRecord
                    .self,
                binding: controlRecord
            ),
            try root.decodeVerified(
                PrimeNative3BMetalContinuationWorkerRecord
                    .self,
                binding: writerRecord
            ),
        ]
        if let restorerRecord =
            restorerRecord.value
        {
            decoded.append(
                try root.decodeVerified(
                PrimeNative3BMetalContinuationWorkerRecord
                    .self,
                binding: restorerRecord
                )
            )
        }
        guard decoded == workers else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "native 3B worker artifacts differ from the receipt"
                )
        }
        let sourceSnapshot = try root.decodeVerified(
            PrimeSwiftSourceSnapshot.self,
            binding: workers[0].sourceSnapshot,
            maximumByteCount: 128 * 1024 * 1024
        )
        try PrimeSwiftSourceProvenance.validate(
            sourceSnapshot,
            requiredRelativePaths:
                PrimeNative3BMetalContinuationContract
                    .requiredPrimeSourceRelativePaths
        )

        var artifactsByPath =
            [String: PrimeArtifactBinding]()
        func insert(
            _ artifact: PrimeArtifactBinding
        ) throws {
            if let prior =
                artifactsByPath[artifact.relativePath]
            {
                guard prior == artifact else {
                    throw PrimeDurableArtifactError
                        .invalidSemantics(
                            "native 3B receipt reuses an artifact path with conflicting identity"
                        )
                }
            } else {
                artifactsByPath[
                    artifact.relativePath
                ] = artifact
            }
        }
        var records = [
            controlRecord,
            writerRecord,
        ]
        if let restorerRecord =
            restorerRecord.value
        {
            records.append(restorerRecord)
        }
        for record in records {
            try insert(record)
        }
        for worker in workers {
            try insert(worker.executable)
            try insert(worker.sourceSnapshot)
            try insert(worker.runtimeImage.artifact)
            try insert(
                worker.runtimeImage
                    .infoPlistArtifact
            )
            for artifact in
                worker.priorEvidence.artifacts
            {
                try insert(artifact)
            }
            for artifact in
                worker.continuationDependencyEvidence
                    .artifacts
            {
                try insert(artifact)
            }
            if let checkpoint =
                worker.checkpointManifest
            {
                try insert(checkpoint.model)
                try insert(checkpoint.firstMoment)
                try insert(checkpoint.secondMoment)
            }
            if let writerRecord =
                worker.writerRecord
            {
                try insert(writerRecord)
            }
        }
        for artifact in artifactsByPath.values {
            _ = try root.verify(artifact)
        }
    }
}

public typealias PrimeNative3BMetalContinuationTensorEntry =
    PrimeNative3BContinuationTensorEntry
public typealias PrimeNative3BMetalContinuationTensorCatalog =
    PrimeNative3BContinuationTensorCatalog
public typealias PrimeNative3BMetalContinuationStepWitness =
    PrimeNative3BContinuationStepWitness
public typealias PrimeNative3BMetalContinuationCheckpointManifest =
    PrimeNative3BContinuationCheckpointManifest
public typealias PrimeNative3BMetalContinuationComparisonResult =
    PrimeNative3BContinuationComparisonResult

private enum PrimeNative3BContinuationValidation {
    static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy({
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            })
    }

    static func isAllZeroHex(_ value: String) -> Bool {
        !value.isEmpty
            && value.utf8.allSatisfy({ $0 == 48 })
    }

    static func topology(
        of catalog:
            PrimeNative3BContinuationTensorCatalog
    ) -> [
        PrimeNative3BContinuationTensorTopologyEntry
    ] {
        catalog.entries.map {
            PrimeNative3BContinuationTensorTopologyEntry(
                path: $0.path,
                shape: $0.shape,
                dtype: $0.dtype,
                byteCount: $0.byteCount
            )
        }
    }
}
