#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation
import PrimeCore
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateLogitSidecarMechanics
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateReplayTransport

/// Value-free failures from descriptor-rooted Stage-B source binding.
///
/// Untrusted paths, bytes, hashes, and decoded values are intentionally not
/// reflected through this error surface.
public enum PrimeNativeNeuralGateReplaySourceBindingError:
    Error,
    Equatable,
    Sendable
{
    case artifactVerificationFailed
    case rootIdentityChanged
    case manifestRejected
    case invalidStreamHeader
    case invalidStreamCount
    case invalidChunkOrdinal
    case recordByteLimitExceeded
    case truncatedStream
    case trailingStreamBytes
    case noncanonicalRecordOrder
    case globalChunkRecordMismatch
    case recordRejected
    case sidecarRejected
    case sourceBindingFailed
}

/// Frozen source-reader policy. These constants describe a reader only; they
/// do not promote any replay, mechanics, model, or product claim.
public enum PrimeNativeNeuralGateReplaySourceBindingPolicy {
    public static let serializationContractID =
        "prime_stage_b_descriptor_rooted_exact_source_binding_v1"
    public static let descriptorFeedMaximumByteCount =
        64 * 1_024
    public static let descriptorTraversalDelegatedToPrimeCore = true
    public static let writableArtifactHandlesOpened = false
}

/// Frozen proof that successful source binding has no authority promotion
/// path.
public enum PrimeNativeNeuralGateReplaySourceBindingAuthority {
    public static let publicationAuthorized = false
    public static let sourceBindingV7Issued = false
    public static let correctedFixtureIdentityEstablished = false
    public static let durableArtifactOriginEstablished = false
    public static let promptContentTargetIndependenceEstablished = false
    public static let modelExecutionEstablished = false
    public static let mutationDetectionAuthorized = false
    public static let mechanicsPassAuthorized = false
    public static let terminalReceiptAuthorized = false
    public static let scientificAuthorityAuthorized = false
    public static let productAuthorityAuthorized = false
}

public typealias PrimeNativeNeuralGateSourceRootIdentity =
    PrimeArtifactRootIdentity

/// A stable observation of one exact immutable artifact descriptor.
public struct PrimeNativeNeuralGateSourceFileObservation:
    Equatable,
    Sendable
{
    public let relativePath: String
    public let sha256: String
    public let byteCount: UInt64
    public let deviceID: UInt64
    public let inode: UInt64
    public let actualMode: UInt16
    public let linkCount: UInt64
    public let modificationSeconds: Int64
    public let modificationNanoseconds: Int64
    public let statusChangeSeconds: Int64
    public let statusChangeNanoseconds: Int64

    fileprivate init(
        binding: PrimeArtifactBinding,
        snapshot: DescriptorSnapshot
    ) {
        relativePath = binding.relativePath
        sha256 = binding.sha256
        byteCount = binding.byteCount
        deviceID = snapshot.deviceID
        inode = snapshot.inode
        actualMode = snapshot.actualMode
        linkCount = snapshot.linkCount
        modificationSeconds =
            snapshot.modificationSeconds
        modificationNanoseconds =
            snapshot.modificationNanoseconds
        statusChangeSeconds =
            snapshot.statusChangeSeconds
        statusChangeNanoseconds =
            snapshot.statusChangeNanoseconds
    }
}

public struct PrimeNativeNeuralGateSourceBoundPromptRecord:
    Equatable,
    Sendable
{
    public let row: PrimeNativeNeuralGateReplayPromptRow
    public let canonicalRecordSHA256: String

    fileprivate init(
        row: PrimeNativeNeuralGateReplayPromptRow,
        canonicalRecordSHA256: String
    ) {
        self.row = row
        self.canonicalRecordSHA256 =
            canonicalRecordSHA256
    }
}

/// Sealed, non-Codable capability for an exact prompt record source.
public struct PrimeNativeNeuralGateValidatedPromptRecordStream:
    Equatable,
    Sendable
{
    public let rootIdentity:
        PrimeNativeNeuralGateSourceRootIdentity
    public let fileObservations:
        [PrimeNativeNeuralGateSourceFileObservation]
    public let sourceBindingSHA256: String
    public let globalStreamSHA256: String
    public let records:
        [PrimeNativeNeuralGateSourceBoundPromptRecord]

    public let sourceStreamBindingEstablished = true
    public let correctedFixtureIdentityEstablished = false
    public let durableArtifactOriginEstablished = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    fileprivate init(
        rootIdentity:
            PrimeNativeNeuralGateSourceRootIdentity,
        fileObservations:
            [PrimeNativeNeuralGateSourceFileObservation],
        sourceBindingSHA256: String,
        globalStreamSHA256: String,
        records:
            [PrimeNativeNeuralGateSourceBoundPromptRecord]
    ) {
        self.rootIdentity = rootIdentity
        self.fileObservations = fileObservations
        self.sourceBindingSHA256 =
            sourceBindingSHA256
        self.globalStreamSHA256 =
            globalStreamSHA256
        self.records = records
    }
}

/// Sealed, non-Codable capability for an exact outer-evaluation source.
public struct PrimeNativeNeuralGateValidatedOuterEvaluationRecordStream:
    Equatable,
    Sendable
{
    public let rootIdentity:
        PrimeNativeNeuralGateSourceRootIdentity
    public let fileObservations:
        [PrimeNativeNeuralGateSourceFileObservation]
    public let sourceBindingSHA256: String
    public let globalStreamSHA256: String
    public let records:
        [PrimeNativeNeuralGateReplayOuterEvaluationRow]

    public let sourceStreamBindingEstablished = true
    public let correctedFixtureIdentityEstablished = false
    public let durableArtifactOriginEstablished = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    fileprivate init(
        rootIdentity:
            PrimeNativeNeuralGateSourceRootIdentity,
        fileObservations:
            [PrimeNativeNeuralGateSourceFileObservation],
        sourceBindingSHA256: String,
        globalStreamSHA256: String,
        records:
            [PrimeNativeNeuralGateReplayOuterEvaluationRow]
    ) {
        self.rootIdentity = rootIdentity
        self.fileObservations = fileObservations
        self.sourceBindingSHA256 =
            sourceBindingSHA256
        self.globalStreamSHA256 =
            globalStreamSHA256
        self.records = records
    }
}

/// Sealed, non-Codable capability for an exact raw-execution source.
public struct PrimeNativeNeuralGateValidatedRawExecutionRecordStream:
    Equatable,
    Sendable
{
    public let rootIdentity:
        PrimeNativeNeuralGateSourceRootIdentity
    public let fileObservations:
        [PrimeNativeNeuralGateSourceFileObservation]
    public let sourceBindingSHA256: String
    public let globalStreamSHA256: String
    public let replicateSeed:
        PrimeNativeNeuralGateArtifactSeed
    public let records:
        [PrimeNativeNeuralGateReplayRawExecutionReference]

    public let sourceStreamBindingEstablished = true
    public let correctedFixtureIdentityEstablished = false
    public let durableArtifactOriginEstablished = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    fileprivate init(
        rootIdentity:
            PrimeNativeNeuralGateSourceRootIdentity,
        fileObservations:
            [PrimeNativeNeuralGateSourceFileObservation],
        sourceBindingSHA256: String,
        globalStreamSHA256: String,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed,
        records:
            [PrimeNativeNeuralGateReplayRawExecutionReference]
    ) {
        self.rootIdentity = rootIdentity
        self.fileObservations = fileObservations
        self.sourceBindingSHA256 =
            sourceBindingSHA256
        self.globalStreamSHA256 =
            globalStreamSHA256
        self.replicateSeed = replicateSeed
        self.records = records
    }
}

/// Sealed, non-Codable capability for one complete source-bound logit
/// sidecar. Validation is delegated to the existing frozen sidecar codec.
public struct PrimeNativeNeuralGateSourceBoundLogitSidecar:
    Equatable,
    Sendable
{
    public let rootIdentity:
        PrimeNativeNeuralGateSourceRootIdentity
    public let fileObservations:
        [PrimeNativeNeuralGateSourceFileObservation]
    public let sourceBindingSHA256: String
    public let replicateSeed:
        PrimeNativeNeuralGateArtifactSeed
    public let validatedSidecar:
        PrimeNativeNeuralGateValidatedLogitSidecar

    public let sourceStreamBindingEstablished = true
    public let correctedFixtureIdentityEstablished = false
    public let durableArtifactOriginEstablished = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    fileprivate init(
        rootIdentity:
            PrimeNativeNeuralGateSourceRootIdentity,
        fileObservations:
            [PrimeNativeNeuralGateSourceFileObservation],
        sourceBindingSHA256: String,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed,
        validatedSidecar:
            PrimeNativeNeuralGateValidatedLogitSidecar
    ) {
        self.rootIdentity = rootIdentity
        self.fileObservations = fileObservations
        self.sourceBindingSHA256 =
            sourceBindingSHA256
        self.replicateSeed = replicateSeed
        self.validatedSidecar = validatedSidecar
    }
}

public enum PrimeNativeNeuralGateReplaySourceBinding {
    private typealias Error =
        PrimeNativeNeuralGateReplaySourceBindingError
    private typealias Contract =
        PrimeNativeNeuralGateReplayArtifactOutputContract
    private typealias Decoder =
        PrimeNativeNeuralGateReplayTransportDecoder

    public static func bindPromptRecords(
        rootDirectoryURL: URL
    ) throws
        -> PrimeNativeNeuralGateValidatedPromptRecordStream
    {
        try translated {
            let root = try PrimeArtifactRoot(
                directoryURL: rootDirectoryURL
            )
            return try bindPromptRecords(
                artifactRoot: root
            )
        }
    }

    public static func bindPromptRecords(
        artifactRoot: PrimeArtifactRoot
    ) throws
        -> PrimeNativeNeuralGateValidatedPromptRecordStream
    {
        try translated {
            try withStableRoot(artifactRoot) {
                rootIdentity in
                let source = try bindRecordStream(
                    artifactRoot: artifactRoot,
                    manifestKey:
                        .promptOnlyFixtureManifest
                ) { data in
                    let row: PrimeNativeNeuralGateReplayPromptRow
                    do {
                        row = try Decoder.decodePromptOnlyRow(
                            from: data
                        )
                    } catch {
                        throw Error.recordRejected
                    }
                    return PrimeNativeNeuralGateSourceBoundPromptRecord(
                        row: row,
                        canonicalRecordSHA256:
                            PrimeSHA256.hexDigest(of: data)
                    )
                }
                return PrimeNativeNeuralGateValidatedPromptRecordStream(
                    rootIdentity: rootIdentity,
                    fileObservations:
                        source.fileObservations,
                    sourceBindingSHA256:
                        sourceBindingSHA256(
                            domain: "prompt_records",
                            rootIdentity: rootIdentity,
                            observations:
                                source.fileObservations
                        ),
                    globalStreamSHA256:
                        source.globalStreamSHA256,
                    records: source.records
                )
            }
        }
    }

    public static func bindOuterEvaluationRecords(
        rootDirectoryURL: URL
    ) throws
        -> PrimeNativeNeuralGateValidatedOuterEvaluationRecordStream
    {
        try translated {
            let root = try PrimeArtifactRoot(
                directoryURL: rootDirectoryURL
            )
            return try bindOuterEvaluationRecords(
                artifactRoot: root
            )
        }
    }

    public static func bindOuterEvaluationRecords(
        artifactRoot: PrimeArtifactRoot
    ) throws
        -> PrimeNativeNeuralGateValidatedOuterEvaluationRecordStream
    {
        try translated {
            try withStableRoot(artifactRoot) {
                rootIdentity in
                let source = try bindRecordStream(
                    artifactRoot: artifactRoot,
                    manifestKey:
                        .outerEvaluationManifest
                ) { data in
                    do {
                        return try Decoder
                            .decodeOuterEvaluationRow(
                                from: data
                            )
                    } catch {
                        throw Error.recordRejected
                    }
                }
                return PrimeNativeNeuralGateValidatedOuterEvaluationRecordStream(
                    rootIdentity: rootIdentity,
                    fileObservations:
                        source.fileObservations,
                    sourceBindingSHA256:
                        sourceBindingSHA256(
                            domain:
                                "outer_evaluation_records",
                            rootIdentity: rootIdentity,
                            observations:
                                source.fileObservations
                        ),
                    globalStreamSHA256:
                        source.globalStreamSHA256,
                    records: source.records
                )
            }
        }
    }

    public static func bindRawExecutionRecords(
        rootDirectoryURL: URL,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed
    ) throws
        -> PrimeNativeNeuralGateValidatedRawExecutionRecordStream
    {
        try translated {
            let root = try PrimeArtifactRoot(
                directoryURL: rootDirectoryURL
            )
            return try bindRawExecutionRecords(
                artifactRoot: root,
                replicateSeed: replicateSeed
            )
        }
    }

    public static func bindRawExecutionRecords(
        artifactRoot: PrimeArtifactRoot,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed
    ) throws
        -> PrimeNativeNeuralGateValidatedRawExecutionRecordStream
    {
        try translated {
            try withStableRoot(artifactRoot) {
                rootIdentity in
                let source = try bindRecordStream(
                    artifactRoot: artifactRoot,
                    manifestKey:
                        .rawExecutionManifest(
                            replicateSeed
                        )
                ) { data in
                    do {
                        return try Decoder
                            .decodeRawExecutionReference(
                                expectedSeed:
                                    replicateSeed,
                                from: data
                            )
                    } catch {
                        throw Error.recordRejected
                    }
                }
                return PrimeNativeNeuralGateValidatedRawExecutionRecordStream(
                    rootIdentity: rootIdentity,
                    fileObservations:
                        source.fileObservations,
                    sourceBindingSHA256:
                        sourceBindingSHA256(
                            domain:
                                "raw_execution_records_\(replicateSeed.rawValue)",
                            rootIdentity: rootIdentity,
                            observations:
                                source.fileObservations
                        ),
                    globalStreamSHA256:
                        source.globalStreamSHA256,
                    replicateSeed: replicateSeed,
                    records: source.records
                )
            }
        }
    }

    public static func bindLogitSidecar(
        rootDirectoryURL: URL,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed
    ) throws
        -> PrimeNativeNeuralGateSourceBoundLogitSidecar
    {
        try translated {
            let root = try PrimeArtifactRoot(
                directoryURL: rootDirectoryURL
            )
            return try bindLogitSidecar(
                artifactRoot: root,
                replicateSeed: replicateSeed
            )
        }
    }

    public static func bindLogitSidecar(
        artifactRoot: PrimeArtifactRoot,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed
    ) throws
        -> PrimeNativeNeuralGateSourceBoundLogitSidecar
    {
        try translated {
            try withStableRoot(artifactRoot) {
                rootIdentity in
                let contract = Contract.frozenV4
                try contract.validate()
                let context = try
                    PrimeNativeNeuralGateCorrectedReplicateContext(
                        evaluationSeed:
                            replicateSeed.rawValue
                    )

                let manifestSpec = try contract.spec(
                    for: .logitManifest(replicateSeed)
                )
                let manifestLoaded = try loadDiscoveredData(
                    artifactRoot: artifactRoot,
                    relativePath:
                        manifestSpec.relativePath,
                    maximumByteCount:
                        manifestSpec.maximumByteCount
                )
                let decodedManifest:
                    PrimeNativeNeuralGateValidatedLogitManifest
                do {
                    decodedManifest = try
                        PrimeNativeNeuralGateLogitSidecarCodec
                        .decodeManifest(
                            manifestLoaded.data,
                            expectedReplicateContext:
                                context
                        )
                } catch {
                    throw Error.sidecarRejected
                }

                let dictionarySpec = try contract.spec(
                    for: .logitDictionary(replicateSeed)
                )
                guard decodedManifest.dictionaryByteCount
                        <= dictionarySpec.maximumByteCount
                else {
                    throw Error.sidecarRejected
                }
                let dictionaryBinding = PrimeArtifactBinding(
                    relativePath:
                        dictionarySpec.relativePath,
                    sha256:
                        decodedManifest.dictionarySHA256,
                    byteCount:
                        decodedManifest.dictionaryByteCount,
                    purpose: .immutableData
                )
                let dictionaryLoaded = try loadBoundData(
                    artifactRoot: artifactRoot,
                    binding: dictionaryBinding,
                    maximumByteCount:
                        dictionarySpec.maximumByteCount
                )

                var chunkData = [Data]()
                var chunkObservations =
                    [PrimeNativeNeuralGateSourceFileObservation]()
                chunkData.reserveCapacity(
                    decodedManifest.chunkBindings.count
                )
                chunkObservations.reserveCapacity(
                    decodedManifest.chunkBindings.count
                )
                for source in
                    decodedManifest.chunkBindings
                {
                    guard let ordinal = UInt32(
                        exactly: source.ordinal
                    ) else {
                        throw Error.sidecarRejected
                    }
                    let spec = try contract.spec(
                        for: .logitChunk(
                            replicateSeed,
                            ordinal
                        )
                    )
                    guard source.byteCount
                            <= spec.maximumByteCount
                    else {
                        throw Error.sidecarRejected
                    }
                    let binding = PrimeArtifactBinding(
                        relativePath: spec.relativePath,
                        sha256: source.sha256,
                        byteCount: source.byteCount,
                        purpose: .immutableData
                    )
                    let loaded = try loadBoundData(
                        artifactRoot: artifactRoot,
                        binding: binding,
                        maximumByteCount:
                            spec.maximumByteCount
                    )
                    chunkData.append(loaded.data)
                    chunkObservations.append(
                        loaded.observation
                    )
                }

                let validated:
                    PrimeNativeNeuralGateValidatedLogitSidecar
                do {
                    validated = try
                        PrimeNativeNeuralGateLogitSidecarCodec
                        .validateCompleteSidecar(
                            dictionaryData:
                                dictionaryLoaded.data,
                            chunkData: chunkData,
                            manifestData:
                                manifestLoaded.data,
                            expectedReplicateContext:
                                context
                        )
                } catch {
                    throw Error.sidecarRejected
                }
                let observations =
                    [
                        manifestLoaded.observation,
                        dictionaryLoaded.observation,
                    ] + chunkObservations
                return PrimeNativeNeuralGateSourceBoundLogitSidecar(
                    rootIdentity: rootIdentity,
                    fileObservations: observations,
                    sourceBindingSHA256:
                        sourceBindingSHA256(
                            domain:
                                "logit_sidecar_\(replicateSeed.rawValue)",
                            rootIdentity: rootIdentity,
                            observations: observations
                        ),
                    replicateSeed: replicateSeed,
                    validatedSidecar: validated
                )
            }
        }
    }

    private static func bindRecordStream<Record>(
        artifactRoot: PrimeArtifactRoot,
        manifestKey:
            PrimeNativeNeuralGateArtifactKey,
        decode: (Data) throws -> Record
    ) throws -> BoundRecordStream<Record> {
        let contract = Contract.frozenV4
        try contract.validate()
        let manifestSpec = try contract.spec(
            for: manifestKey
        )
        let manifestLoaded = try loadDiscoveredData(
            artifactRoot: artifactRoot,
            relativePath: manifestSpec.relativePath,
            maximumByteCount:
                manifestSpec.maximumByteCount
        )
        let manifest:
            PrimeNativeNeuralGateReplayRecordManifest
        do {
            let decoded = try Decoder.decodeArtifact(
                key: manifestKey,
                from: manifestLoaded.data
            )
            guard case let .recordManifest(value) =
                    decoded
            else {
                throw Error.manifestRejected
            }
            manifest = value
        } catch let error as Error {
            throw error
        } catch {
            throw Error.manifestRejected
        }
        guard let maximumRecordByteCount =
                PrimeNativeNeuralGateReplayRecordTransportPolicy
                .maximumCanonicalRecordByteCount(
                    for: manifest.recordSchemaID
                )
        else {
            throw Error.manifestRejected
        }

        let globalBinding = PrimeArtifactBinding(
            relativePath:
                manifest.globalStream.relativePath,
            sha256: manifest.globalStream.sha256,
            byteCount:
                manifest.globalStream.byteCount,
            purpose: .immutableData
        )
        let chunks = manifest.orderedChunks.map {
            source in
            StreamChunkPlan(
                ordinal: source.ordinal,
                recordCount: source.recordCount,
                binding: PrimeArtifactBinding(
                    relativePath:
                        source.artifact.relativePath,
                    sha256: source.artifact.sha256,
                    byteCount:
                        source.artifact.byteCount,
                    purpose: .immutableData
                )
            )
        }
        let streamed = try streamInLockstep(
            artifactRoot: artifactRoot,
            globalBinding: globalBinding,
            chunks: chunks,
            expectedRecordCount:
                manifest.recordCount,
            maximumRecordByteCount:
                maximumRecordByteCount,
            decode: decode
        )
        return BoundRecordStream(
            records: streamed.records,
            globalStreamSHA256:
                manifest.globalStream.sha256,
            fileObservations:
                [manifestLoaded.observation]
                    + [streamed.globalObservation]
                    + streamed.chunkObservations
        )
    }

    private static func streamInLockstep<Record>(
        artifactRoot: PrimeArtifactRoot,
        globalBinding: PrimeArtifactBinding,
        chunks: [StreamChunkPlan],
        expectedRecordCount: UInt32,
        maximumRecordByteCount: Int,
        decode: (Data) throws -> Record
    ) throws -> StreamedRecords<Record> {
        guard expectedRecordCount > 0,
              maximumRecordByteCount > 0
        else {
            throw Error.invalidStreamCount
        }
        return try artifactRoot
            .withVerifiedArtifactDescriptor(
                globalBinding
            ) { globalDescriptor in
                let globalBefore = try descriptorSnapshot(
                    globalDescriptor,
                    expectedByteCount:
                        globalBinding.byteCount
                )
                var globalSource = DescriptorByteSource(
                    descriptor: globalDescriptor,
                    expectedByteCount:
                        globalBinding.byteCount
                )
                var globalReader = try framedReader(
                    kind: .global,
                    expectedRecordCount:
                        expectedRecordCount,
                    maximumRecordByteCount:
                        maximumRecordByteCount,
                    streamByteCount:
                        globalBinding.byteCount
                )
                var globalPending = PendingRecords(
                    maximumByteCount:
                        pendingByteLimit(
                            maximumRecordByteCount:
                                maximumRecordByteCount
                        )
                )

                var records = [Record]()
                records.reserveCapacity(
                    Int(expectedRecordCount)
                )
                var chunkObservations =
                    [PrimeNativeNeuralGateSourceFileObservation]()
                chunkObservations.reserveCapacity(
                    chunks.count
                )
                for (expectedOrdinal, plan) in
                    chunks.enumerated()
                {
                    let chunkResult = try artifactRoot
                        .withVerifiedArtifactDescriptor(
                            plan.binding
                        ) { chunkDescriptor in
                            let before = try descriptorSnapshot(
                                chunkDescriptor,
                                expectedByteCount:
                                    plan.binding.byteCount
                            )
                            var chunkSource = DescriptorByteSource(
                                descriptor: chunkDescriptor,
                                expectedByteCount:
                                    plan.binding.byteCount
                            )
                            var chunkReader = try framedReader(
                                kind: .chunk,
                                expectedRecordCount:
                                    plan.recordCount,
                                maximumRecordByteCount:
                                    maximumRecordByteCount,
                                streamByteCount:
                                    plan.binding.byteCount
                            )
                            var chunkPending = PendingRecords(
                                maximumByteCount:
                                    pendingByteLimit(
                                        maximumRecordByteCount:
                                            maximumRecordByteCount
                                    )
                            )

                            while !chunkSource.isAtEnd
                                || !chunkPending.isEmpty
                            {
                                var progressed = false
                                if chunkPending.isEmpty,
                                   !chunkSource.isAtEnd
                                {
                                    try feedOneBlock(
                                        source: &chunkSource,
                                        reader: &chunkReader,
                                        pending: &chunkPending
                                    )
                                    progressed = true
                                }
                                if globalPending.isEmpty,
                                   !globalSource.isAtEnd
                                {
                                    try feedOneBlock(
                                        source: &globalSource,
                                        reader: &globalReader,
                                        pending: &globalPending
                                    )
                                    progressed = true
                                }
                                while let globalRecord =
                                        globalPending.first,
                                      let chunkRecord =
                                        chunkPending.first
                                {
                                    guard globalRecord
                                            == chunkRecord
                                    else {
                                        throw Error
                                            .globalChunkRecordMismatch
                                    }
                                    globalPending.removeFirst()
                                    chunkPending.removeFirst()
                                    let decoded: Record
                                    do {
                                        decoded = try decode(
                                            globalRecord
                                        )
                                    } catch let error as Error {
                                        throw error
                                    } catch {
                                        throw Error.recordRejected
                                    }
                                    records.append(decoded)
                                    progressed = true
                                }
                                if chunkPending.isEmpty,
                                   chunkSource.isAtEnd
                                {
                                    break
                                }
                                guard progressed else {
                                    throw Error
                                        .globalChunkRecordMismatch
                                }
                            }
                            let summary = try finish(
                                &chunkReader
                            )
                            guard summary.kind == .chunk,
                                  summary.chunkOrdinal
                                    == plan.ordinal,
                                  summary.chunkOrdinal
                                    == UInt32(
                                        expectedOrdinal
                                    ),
                                  summary.declaredRecordCount
                                    == UInt64(
                                        plan.recordCount
                                    ),
                                  summary.observedRecordCount
                                    == Int(plan.recordCount),
                                  summary.streamSHA256
                                    == plan.binding.sha256,
                                  summary.byteCount
                                    == plan.binding.byteCount,
                                  chunkPending.isEmpty
                            else {
                                throw Error.invalidStreamCount
                            }
                            let after = try descriptorSnapshot(
                                chunkDescriptor,
                                expectedByteCount:
                                    plan.binding.byteCount
                            )
                            guard before == after else {
                                throw Error
                                    .artifactVerificationFailed
                            }
                            return PrimeNativeNeuralGateSourceFileObservation(
                                binding: plan.binding,
                                snapshot: after
                            )
                    } materialize: { $0 }
                    chunkObservations.append(chunkResult)
                }
                while !globalSource.isAtEnd {
                    try feedOneBlock(
                        source: &globalSource,
                        reader: &globalReader,
                        pending: &globalPending
                    )
                }
                guard globalPending.isEmpty else {
                    throw Error.invalidStreamCount
                }
                let globalSummary = try finish(
                    &globalReader
                )
                guard records.count
                        == Int(expectedRecordCount),
                      globalSummary.kind == .global,
                      globalSummary.chunkOrdinal == nil,
                      globalSummary.declaredRecordCount
                        == UInt64(expectedRecordCount),
                      globalSummary.observedRecordCount
                        == Int(expectedRecordCount),
                      globalSummary.streamSHA256
                        == globalBinding.sha256,
                      globalSummary.byteCount
                        == globalBinding.byteCount
                else {
                    throw Error.invalidStreamCount
                }
                let globalAfter = try descriptorSnapshot(
                    globalDescriptor,
                    expectedByteCount:
                        globalBinding.byteCount
                )
                guard globalBefore == globalAfter else {
                    throw Error.artifactVerificationFailed
                }
                return StreamedRecords(
                    records: records,
                    globalObservation:
                        PrimeNativeNeuralGateSourceFileObservation(
                            binding: globalBinding,
                            snapshot: globalAfter
                        ),
                    chunkObservations:
                        chunkObservations
                )
            } materialize: { $0 }
    }

    private static func framedReader(
        kind:
            PrimeNativeNeuralGateInvariantFramedStreamKind,
        expectedRecordCount: UInt32,
        maximumRecordByteCount: Int,
        streamByteCount: UInt64
    ) throws
        -> PrimeNativeNeuralGateInvariantFramedRecordReader
    {
        guard streamByteCount <= UInt64(Int.max),
              expectedRecordCount > 0
        else {
            throw Error.invalidStreamCount
        }
        let limits: PrimeNativeNeuralGateReplayDecodeLimits
        do {
            limits = try .bounded(
                maximumRecordCount:
                    Int(expectedRecordCount),
                maximumRecordByteCount:
                    maximumRecordByteCount,
                maximumAggregateRecordBytes:
                    Int(streamByteCount)
            )
        } catch {
            throw Error.sourceBindingFailed
        }
        return PrimeNativeNeuralGateInvariantFramedRecordReader(
            kind: kind,
            limits: limits,
            requireCanonicalOrder: true
        )
    }

    private static func feedOneBlock(
        source: inout DescriptorByteSource,
        reader: inout
            PrimeNativeNeuralGateInvariantFramedRecordReader,
        pending: inout PendingRecords
    ) throws {
        guard let bytes = try source.readNext(
            maximumByteCount:
                PrimeNativeNeuralGateReplaySourceBindingPolicy
                .descriptorFeedMaximumByteCount
        ) else {
            return
        }
        do {
            try reader.consume(bytes) { record in
                try pending.append(record)
            }
        } catch let error as Error {
            throw error
        } catch let error as
            PrimeNativeNeuralGateReplayMechanicsError
        {
            throw translatedMechanicsError(error)
        } catch {
            throw Error.sourceBindingFailed
        }
    }

    private static func finish(
        _ reader: inout
            PrimeNativeNeuralGateInvariantFramedRecordReader
    ) throws
        -> PrimeNativeNeuralGateInvariantFramedStreamSummary
    {
        do {
            return try reader.finish()
        } catch let error as
            PrimeNativeNeuralGateReplayMechanicsError
        {
            throw translatedMechanicsError(error)
        } catch {
            throw Error.sourceBindingFailed
        }
    }

    private static func translatedMechanicsError(
        _ error:
            PrimeNativeNeuralGateReplayMechanicsError
    ) -> Error {
        switch error {
        case .invalidGlobalMagic,
             .invalidChunkMagic:
            .invalidStreamHeader
        case .emptyRecordSet,
             .recordCountLimitExceeded,
             .emptyChunk,
             .chunkRecordCountLimitExceeded:
            .invalidStreamCount
        case .recordByteLimitExceeded,
             .aggregateByteLimitExceeded:
            .recordByteLimitExceeded
        case .truncatedInput:
            .truncatedStream
        case .trailingInput:
            .trailingStreamBytes
        case .noncanonicalRecordOrder:
            .noncanonicalRecordOrder
        default:
            .sourceBindingFailed
        }
    }

    private static func pendingByteLimit(
        maximumRecordByteCount: Int
    ) -> Int {
        let feed =
            PrimeNativeNeuralGateReplaySourceBindingPolicy
            .descriptorFeedMaximumByteCount
        let sum = feed.addingReportingOverflow(
            maximumRecordByteCount
        )
        return sum.overflow ? Int.max : sum.partialValue
    }

    private static func loadDiscoveredData(
        artifactRoot: PrimeArtifactRoot,
        relativePath: String,
        maximumByteCount: UInt64
    ) throws -> LoadedData {
        let binding: PrimeArtifactBinding
        do {
            binding = try artifactRoot.bindExisting(
                at: relativePath,
                purpose: .immutableData,
                maximumByteCount: maximumByteCount
            )
        } catch {
            throw Error.artifactVerificationFailed
        }
        return try loadBoundData(
            artifactRoot: artifactRoot,
            binding: binding,
            maximumByteCount: maximumByteCount
        )
    }

    private static func loadBoundData(
        artifactRoot: PrimeArtifactRoot,
        binding: PrimeArtifactBinding,
        maximumByteCount: UInt64
    ) throws -> LoadedData {
        guard binding.byteCount > 0,
              binding.byteCount <= maximumByteCount,
              binding.byteCount <= UInt64(Int.max)
        else {
            throw Error.artifactVerificationFailed
        }
        do {
            return try artifactRoot
                .withVerifiedArtifactDescriptor(
                    binding
                ) { descriptor in
                    let before = try descriptorSnapshot(
                        descriptor,
                        expectedByteCount:
                            binding.byteCount
                    )
                    var reader = DescriptorByteSource(
                        descriptor: descriptor,
                        expectedByteCount:
                            binding.byteCount
                    )
                    let data = try reader.readExactly(
                        Int(binding.byteCount)
                    )
                    try reader.requireEnd()
                    let after = try descriptorSnapshot(
                        descriptor,
                        expectedByteCount:
                            binding.byteCount
                    )
                    guard before == after else {
                        throw Error
                            .artifactVerificationFailed
                    }
                    return LoadedData(
                        data: data,
                        observation:
                            PrimeNativeNeuralGateSourceFileObservation(
                                binding: binding,
                                snapshot: after
                            )
                    )
                } materialize: { $0 }
        } catch let error as Error {
            throw error
        } catch {
            throw Error.artifactVerificationFailed
        }
    }

    private static func withStableRoot<Result>(
        _ artifactRoot: PrimeArtifactRoot,
        operation:
            (PrimeNativeNeuralGateSourceRootIdentity)
                throws -> Result
    ) throws -> Result {
        let before: PrimeArtifactRootIdentity
        do {
            before = try artifactRoot
                .verifiedRootIdentity()
        } catch {
            throw Error.artifactVerificationFailed
        }
        let result = try operation(before)
        let after: PrimeArtifactRootIdentity
        do {
            after = try artifactRoot
                .verifiedRootIdentity()
        } catch {
            throw Error.artifactVerificationFailed
        }
        guard before == after else {
            throw Error.rootIdentityChanged
        }
        return result
    }

    private static func sourceBindingSHA256(
        domain: String,
        rootIdentity: PrimeArtifactRootIdentity,
        observations:
            [PrimeNativeNeuralGateSourceFileObservation]
    ) -> String {
        var data = Data("PRIMESRB1".utf8)
        appendString(
            PrimeNativeNeuralGateReplaySourceBindingPolicy
                .serializationContractID,
            to: &data
        )
        appendString(domain, to: &data)
        append(rootIdentity.deviceID, to: &data)
        append(rootIdentity.inode, to: &data)
        append(UInt64(rootIdentity.ownerUserID), to: &data)
        append(UInt64(rootIdentity.ownerGroupID), to: &data)
        append(UInt64(rootIdentity.actualMode), to: &data)
        append(rootIdentity.linkCount, to: &data)
        appendSigned(
            rootIdentity.modificationSeconds,
            to: &data
        )
        appendSigned(
            rootIdentity.modificationNanoseconds,
            to: &data
        )
        appendSigned(
            rootIdentity.statusChangeSeconds,
            to: &data
        )
        appendSigned(
            rootIdentity.statusChangeNanoseconds,
            to: &data
        )
        append(UInt64(observations.count), to: &data)
        for observation in observations {
            appendString(
                observation.relativePath,
                to: &data
            )
            appendString(observation.sha256, to: &data)
            append(observation.byteCount, to: &data)
            append(observation.deviceID, to: &data)
            append(observation.inode, to: &data)
            append(UInt64(observation.actualMode), to: &data)
            append(observation.linkCount, to: &data)
            appendSigned(
                observation.modificationSeconds,
                to: &data
            )
            appendSigned(
                observation.modificationNanoseconds,
                to: &data
            )
            appendSigned(
                observation.statusChangeSeconds,
                to: &data
            )
            appendSigned(
                observation.statusChangeNanoseconds,
                to: &data
            )
        }
        return PrimeSHA256.hexDigest(of: data)
    }

    private static func appendString(
        _ value: String,
        to data: inout Data
    ) {
        let bytes = Data(value.utf8)
        append(UInt64(bytes.count), to: &data)
        data.append(bytes)
    }

    private static func append(
        _ value: UInt64,
        to data: inout Data
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.append(contentsOf: $0)
        }
    }

    private static func appendSigned(
        _ value: Int64,
        to data: inout Data
    ) {
        append(
            UInt64(bitPattern: value),
            to: &data
        )
    }

    private static func descriptorSnapshot(
        _ descriptor: Int32,
        expectedByteCount: UInt64
    ) throws -> DescriptorSnapshot {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              metadata.st_size >= 0,
              UInt64(metadata.st_size)
                == expectedByteCount,
              metadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              metadata.st_mode & mode_t(0o7777)
                == mode_t(0o444),
              metadata.st_nlink == 1
        else {
            throw Error.artifactVerificationFailed
        }
        #if canImport(Darwin)
        let modificationSeconds =
            Int64(metadata.st_mtimespec.tv_sec)
        let modificationNanoseconds =
            Int64(metadata.st_mtimespec.tv_nsec)
        let statusChangeSeconds =
            Int64(metadata.st_ctimespec.tv_sec)
        let statusChangeNanoseconds =
            Int64(metadata.st_ctimespec.tv_nsec)
        #else
        let modificationSeconds =
            Int64(metadata.st_mtim.tv_sec)
        let modificationNanoseconds =
            Int64(metadata.st_mtim.tv_nsec)
        let statusChangeSeconds =
            Int64(metadata.st_ctim.tv_sec)
        let statusChangeNanoseconds =
            Int64(metadata.st_ctim.tv_nsec)
        #endif
        return DescriptorSnapshot(
            deviceID:
                UInt64(bitPattern: Int64(metadata.st_dev)),
            inode: UInt64(metadata.st_ino),
            actualMode:
                UInt16(metadata.st_mode & mode_t(0o777)),
            linkCount: UInt64(metadata.st_nlink),
            modificationSeconds:
                modificationSeconds,
            modificationNanoseconds:
                modificationNanoseconds,
            statusChangeSeconds:
                statusChangeSeconds,
            statusChangeNanoseconds:
                statusChangeNanoseconds
        )
    }

    private static func translated<Result>(
        _ operation: () throws -> Result
    ) throws -> Result {
        do {
            return try operation()
        } catch let error as Error {
            throw error
        } catch {
            throw Error.artifactVerificationFailed
        }
    }
}

private struct DescriptorSnapshot: Equatable {
    let deviceID: UInt64
    let inode: UInt64
    let actualMode: UInt16
    let linkCount: UInt64
    let modificationSeconds: Int64
    let modificationNanoseconds: Int64
    let statusChangeSeconds: Int64
    let statusChangeNanoseconds: Int64
}

private struct DescriptorByteSource {
    let descriptor: Int32
    let expectedByteCount: UInt64
    var consumedByteCount: UInt64 = 0

    var isAtEnd: Bool {
        consumedByteCount == expectedByteCount
    }

    mutating func readNext(
        maximumByteCount: Int
    ) throws -> Data? {
        guard maximumByteCount > 0 else {
            throw PrimeNativeNeuralGateReplaySourceBindingError
                .sourceBindingFailed
        }
        guard !isAtEnd else {
            return nil
        }
        let remaining = expectedByteCount
            - consumedByteCount
        let count = Int(
            min(UInt64(maximumByteCount), remaining)
        )
        return try readExactly(count)
    }

    mutating func readExactly(
        _ count: Int
    ) throws -> Data {
        guard count >= 0 else {
            throw PrimeNativeNeuralGateReplaySourceBindingError
                .truncatedStream
        }
        let addition = consumedByteCount
            .addingReportingOverflow(UInt64(count))
        guard !addition.overflow,
              addition.partialValue <= expectedByteCount
        else {
            throw PrimeNativeNeuralGateReplaySourceBindingError
                .truncatedStream
        }
        var data = Data(count: count)
        var offset = 0
        while offset < count {
            let readCount = data.withUnsafeMutableBytes {
                bytes -> Int in
                guard let baseAddress = bytes.baseAddress
                else {
                    return -1
                }
                return read(
                    descriptor,
                    baseAddress.advanced(by: offset),
                    count - offset
                )
            }
            if readCount < 0, errno == EINTR {
                continue
            }
            guard readCount > 0 else {
                throw PrimeNativeNeuralGateReplaySourceBindingError
                    .truncatedStream
            }
            offset += readCount
        }
        consumedByteCount = addition.partialValue
        return data
    }

    mutating func readBigEndian<
        Value: FixedWidthInteger
    >() throws -> Value {
        let bytes = try readExactly(
            MemoryLayout<Value>.size
        )
        var value: Value = 0
        for byte in bytes {
            value = (value << 8) | Value(byte)
        }
        return value
    }

    func requireEnd() throws {
        guard consumedByteCount == expectedByteCount
        else {
            throw PrimeNativeNeuralGateReplaySourceBindingError
                .trailingStreamBytes
        }
    }
}

private struct PendingRecords {
    let maximumByteCount: Int
    private let maximumRecordCount =
        PrimeNativeNeuralGateReplaySourceBindingPolicy
        .descriptorFeedMaximumByteCount / 8 + 2
    private var storage = [Data]()
    private var head = 0
    private var retainedByteCount = 0

    init(maximumByteCount: Int) {
        self.maximumByteCount = maximumByteCount
    }

    var isEmpty: Bool {
        head == storage.count
    }

    var first: Data? {
        guard !isEmpty else {
            return nil
        }
        return storage[head]
    }

    mutating func append(_ record: Data) throws {
        let nextBytes = retainedByteCount
            .addingReportingOverflow(record.count)
        let retainedRecordCount = storage.count - head
        guard !nextBytes.overflow,
              nextBytes.partialValue <= maximumByteCount,
              retainedRecordCount < maximumRecordCount
        else {
            throw PrimeNativeNeuralGateReplaySourceBindingError
                .sourceBindingFailed
        }
        storage.append(record)
        retainedByteCount = nextBytes.partialValue
    }

    mutating func removeFirst() {
        precondition(!isEmpty)
        retainedByteCount -= storage[head].count
        head += 1
        if head == storage.count {
            storage.removeAll(keepingCapacity: true)
            head = 0
        } else if head >= 1_024 {
            storage.removeFirst(head)
            head = 0
        }
    }
}

private struct StreamChunkPlan {
    let ordinal: UInt32
    let recordCount: UInt32
    let binding: PrimeArtifactBinding
}

private struct LoadedData {
    let data: Data
    let observation:
        PrimeNativeNeuralGateSourceFileObservation
}

private struct BoundRecordStream<Record> {
    let records: [Record]
    let globalStreamSHA256: String
    let fileObservations:
        [PrimeNativeNeuralGateSourceFileObservation]
}

private struct StreamedRecords<Record> {
    let records: [Record]
    let globalObservation:
        PrimeNativeNeuralGateSourceFileObservation
    let chunkObservations:
        [PrimeNativeNeuralGateSourceFileObservation]
}

// MARK: - Focused small-stream test seam

struct _PrimeNativeNeuralGateSourceBindingTestChunkPlan {
    let ordinal: UInt32
    let recordCount: UInt32
    let binding: PrimeArtifactBinding
}

struct _PrimeNativeNeuralGateSourceBindingTestPlan {
    let globalBinding: PrimeArtifactBinding
    let chunks:
        [_PrimeNativeNeuralGateSourceBindingTestChunkPlan]
    let recordCount: UInt32
    let maximumRecordByteCount: Int
}

struct _PrimeNativeNeuralGateSourceBindingTestResult {
    let rootIdentity: PrimeArtifactRootIdentity
    let records: [Data]
    let fileObservations:
        [PrimeNativeNeuralGateSourceFileObservation]
    let sourceBindingSHA256: String
}

extension PrimeNativeNeuralGateReplaySourceBinding {
    static func _bindInvariantRecordsForTesting(
        artifactRoot: PrimeArtifactRoot,
        plan:
            _PrimeNativeNeuralGateSourceBindingTestPlan,
        validateRecord: (Data) throws -> Void = { _ in }
    ) throws
        -> _PrimeNativeNeuralGateSourceBindingTestResult
    {
        try translated {
            try withStableRoot(artifactRoot) {
                rootIdentity in
                let streamed: StreamedRecords<Data> =
                    try streamInLockstep(
                        artifactRoot: artifactRoot,
                        globalBinding:
                            plan.globalBinding,
                        chunks: plan.chunks.map {
                            StreamChunkPlan(
                                ordinal: $0.ordinal,
                                recordCount:
                                    $0.recordCount,
                                binding: $0.binding
                            )
                        },
                        expectedRecordCount:
                            plan.recordCount,
                        maximumRecordByteCount:
                            plan.maximumRecordByteCount
                    ) { record in
                        do {
                            try validateRecord(record)
                        } catch {
                            throw Error.recordRejected
                        }
                        return record
                    }
                let observations =
                    [streamed.globalObservation]
                        + streamed.chunkObservations
                return _PrimeNativeNeuralGateSourceBindingTestResult(
                    rootIdentity: rootIdentity,
                    records: streamed.records,
                    fileObservations: observations,
                    sourceBindingSHA256:
                        sourceBindingSHA256(
                            domain: "test_records",
                            rootIdentity: rootIdentity,
                            observations: observations
                        )
                )
            }
        }
    }
}
