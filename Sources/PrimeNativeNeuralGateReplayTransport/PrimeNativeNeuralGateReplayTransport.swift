import Foundation
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics

/// Fail-closed failures emitted by the bounded Stage-B transport.
///
/// Success means only that bytes matched a frozen, bounded transport shape.
/// It cannot create mechanics, capability, mutation-detection, or receipt
/// authority.
public enum PrimeNativeNeuralGateReplayTransportError:
    Error,
    Equatable,
    Sendable
{
    case artifactTooLarge(maximumBytes: UInt64)
    case emptyArtifact
    case byteOrderMarkForbidden
    case invalidUTF8
    case rootObjectRequired
    case malformedLexicalStructure
    case nestingDepthExceeded(maximumDepth: Int)
    case stringTokenTooLarge(maximumBytes: Int)
    case structuralTokenLimitExceeded(maximumCount: Int)
    case invalidJSON
    case noncanonicalJSON
    case invalidSchemaVersion
    case invalidArtifactKind
    case unexpectedArtifactKey
    case unexpectedArtifactPath
    case invalidBinding
    case invalidManifest
    case invalidReplicateSeed
    case forbiddenPromptOnlyField(String)
    case invalidPromptTokens
    case invalidExecutionIndex
    case invalidCorrelationID
    case invalidExpectedCompletion
    case invalidSHA256(String)
    case invalidTermination
    case invalidGeneratedTokens
    case authorizingClaimForbidden(String)
    case descriptorStreamingDecoderRequired
    case sourceBoundCodecRequired
    case schemaDeferred
}

public enum PrimeNativeNeuralGateReplayTermination:
    String,
    Equatable,
    Sendable
{
    case eos
    case fixedCap = "fixed_cap"
}

/// Frozen proof that this target has no transport-success promotion path.
public enum PrimeNativeNeuralGateReplayTransportAuthority {
    public static let mechanicsPassAuthorized = false
    public static let groundedVerdictAuthorized = false
    public static let mutationDetectionAuthorized = false
    public static let terminalReceiptAuthorized = false
    public static let scientificAuthorityAuthorized = false
    public static let productAuthorityAuthorized = false
}

public struct PrimeNativeNeuralGateReplayArtifactBinding:
    Equatable,
    Sendable
{
    public let relativePath: String
    public let sha256: String
    public let byteCount: UInt64

    fileprivate init(
        relativePath: String,
        sha256: String,
        byteCount: UInt64
    ) {
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
    }
}

public struct PrimeNativeNeuralGateReplayChunkBinding:
    Equatable,
    Sendable
{
    public let ordinal: UInt32
    public let recordCount: UInt32
    public let artifact:
        PrimeNativeNeuralGateReplayArtifactBinding

    fileprivate init(
        ordinal: UInt32,
        recordCount: UInt32,
        artifact:
            PrimeNativeNeuralGateReplayArtifactBinding
    ) {
        self.ordinal = ordinal
        self.recordCount = recordCount
        self.artifact = artifact
    }
}

/// A bounded JSON envelope that binds, but never materializes, a large
/// descriptor-streamed ordered record set.
public struct PrimeNativeNeuralGateReplayRecordManifest:
    Equatable,
    Sendable
{
    public let artifactKey:
        PrimeNativeNeuralGateArtifactKey
    public let relativePath: String
    public let recordSchemaID: String
    public let recordCount: UInt32
    public let globalStream:
        PrimeNativeNeuralGateReplayArtifactBinding
    public let orderedChunks:
        [PrimeNativeNeuralGateReplayChunkBinding]

    public let recordsMaterialized = false
    public let mechanicsPassAuthorized = false

    fileprivate init(
        artifactKey:
            PrimeNativeNeuralGateArtifactKey,
        relativePath: String,
        recordSchemaID: String,
        recordCount: UInt32,
        globalStream:
            PrimeNativeNeuralGateReplayArtifactBinding,
        orderedChunks:
            [PrimeNativeNeuralGateReplayChunkBinding]
    ) {
        self.artifactKey = artifactKey
        self.relativePath = relativePath
        self.recordSchemaID = recordSchemaID
        self.recordCount = recordCount
        self.globalStream = globalStream
        self.orderedChunks = orderedChunks
    }
}

public struct PrimeNativeNeuralGateReplayPromptRow:
    Equatable,
    Sendable
{
    public let promptTokenIDs: [UInt16]
    public let canonicalPrompt: String

    public let dedicatedTargetFieldPresent = false
    public let dedicatedCorrelationFieldPresent = false
    public let dedicatedRegradeFieldPresent = false
    public let dedicatedCallerBudgetFieldPresent = false
    public let dedicatedCallerSupportFieldPresent = false
    public let dedicatedCallerTerminationFieldPresent = false
    public let targetIndependenceEstablished = false

    fileprivate init(
        promptTokenIDs: [UInt16],
        canonicalPrompt: String
    ) {
        self.promptTokenIDs = promptTokenIDs
        self.canonicalPrompt = canonicalPrompt
    }
}

public struct PrimeNativeNeuralGateReplayOuterEvaluationRow:
    Equatable,
    Sendable
{
    public let executionIndex: UInt32
    public let correlationID: String
    public let expectedCompletionUTF8: Data
    public let canonicalExpectedCompletion: String

    fileprivate init(
        executionIndex: UInt32,
        correlationID: String,
        expectedCompletionUTF8: Data,
        canonicalExpectedCompletion: String
    ) {
        self.executionIndex = executionIndex
        self.correlationID = correlationID
        self.expectedCompletionUTF8 = expectedCompletionUTF8
        self.canonicalExpectedCompletion = canonicalExpectedCompletion
    }
}

public struct PrimeNativeNeuralGateReplayRawExecutionReference:
    Equatable,
    Sendable
{
    public let replicateSeed:
        PrimeNativeNeuralGateArtifactSeed
    public let executionIndex: UInt32
    public let promptSHA256: String
    public let traceSHA256: String
    public let decisionCount: UInt8
    public let generatedTokenIDs: [UInt16]
    public let termination:
        PrimeNativeNeuralGateReplayTermination

    public let logitsMaterialized = false
    public let executionAuthorized = false

    fileprivate init(
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed,
        executionIndex: UInt32,
        promptSHA256: String,
        traceSHA256: String,
        decisionCount: UInt8,
        generatedTokenIDs: [UInt16],
        termination:
            PrimeNativeNeuralGateReplayTermination
    ) {
        self.replicateSeed = replicateSeed
        self.executionIndex = executionIndex
        self.promptSHA256 = promptSHA256
        self.traceSHA256 = traceSHA256
        self.decisionCount = decisionCount
        self.generatedTokenIDs = generatedTokenIDs
        self.termination = termination
    }
}

public enum PrimeNativeNeuralGateReplayDecodedArtifact:
    Equatable,
    Sendable
{
    case recordManifest(
        PrimeNativeNeuralGateReplayRecordManifest
    )
}

private enum TransportLimits {
    private static let contract =
        PrimeNativeNeuralGateReplayArtifactOutputContract
        .frozenV4

    static let maximumBytes =
        contract.maximumBoundedInMemoryByteCount
    static let maximumDepth =
        contract.maximumJSONNestingDepth
    static let maximumStringBytes =
        contract.maximumJSONStringByteCount
    static let maximumStructuralTokens =
        contract.maximumJSONStructuralTokenCount
    static let maximumPromptTokenCount =
        contract.maximumPromptTokenCount
    static let maximumGenerationDecisions =
        contract.maximumGenerationDecisions
    static let correctedFixtureRowCount: UInt32 = {
        guard let count = UInt32(
            exactly:
                contract.exactCorrectedFixtureRowCount
        ) else {
            return 0
        }
        return count
    }()
    static let byteTokenRange: ClosedRange<UInt16> =
        256 ... 511
}

private struct BindingWire: Codable {
    let relativePath: String
    let sha256: String
    let byteCount: UInt64

    enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case sha256
        case byteCount = "byte_count"
    }
}

private struct ChunkBindingWire: Codable {
    let ordinal: UInt32
    let recordCount: UInt32
    let relativePath: String
    let sha256: String
    let byteCount: UInt64

    enum CodingKeys: String, CodingKey {
        case ordinal
        case recordCount = "record_count"
        case relativePath = "relative_path"
        case sha256
        case byteCount = "byte_count"
    }
}

private struct RecordManifestWire: Codable {
    let schemaVersion: Int
    let artifactKind: String
    let recordSchemaID: String
    let recordCount: UInt32
    let globalStream: BindingWire
    let chunks: [ChunkBindingWire]
    let recordsMaterialized: Bool
    let mechanicsPassAuthorized: Bool

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case recordSchemaID = "record_schema_id"
        case recordCount = "record_count"
        case globalStream = "global_stream"
        case chunks
        case recordsMaterialized = "records_materialized"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
    }
}

private struct PromptRowWire: Codable {
    let schemaVersion: Int
    let recordKind: String
    let promptTokenIDs: [UInt16]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case recordKind = "record_kind"
        case promptTokenIDs = "prompt_token_ids"
    }
}

private struct OuterEvaluationRowWire: Codable {
    let schemaVersion: Int
    let recordKind: String
    let executionIndex: UInt32
    let correlationID: String
    let expectedCompletionUTF8: [UInt8]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case recordKind = "record_kind"
        case executionIndex = "execution_index"
        case correlationID = "correlation_id"
        case expectedCompletionUTF8 =
            "expected_completion_utf8"
    }
}

private struct RawExecutionReferenceWire: Codable {
    let schemaVersion: Int
    let recordKind: String
    let replicateSeed: Int
    let executionIndex: UInt32
    let promptSHA256: String
    let traceSHA256: String
    let decisionCount: UInt8
    let generatedTokenIDs: [UInt16]
    let termination: String
    let logitsMaterialized: Bool
    let executionAuthorized: Bool

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case recordKind = "record_kind"
        case replicateSeed = "replicate_seed"
        case executionIndex = "execution_index"
        case promptSHA256 = "prompt_sha256"
        case traceSHA256 = "trace_sha256"
        case decisionCount = "decision_count"
        case generatedTokenIDs = "generated_token_ids"
        case termination
        case logitsMaterialized = "logits_materialized"
        case executionAuthorized = "execution_authorized"
    }
}

private enum BoundedCanonicalJSON {
    static func decode<Value: Codable>(
        _ type: Value.Type,
        from data: Data,
        maximumByteCount: UInt64,
        rejectPromptOnlyFields: Bool = false
    ) throws -> Value {
        try lexicalPreflight(
            data,
            maximumByteCount: maximumByteCount
        )
        let root: Any
        do {
            root = try JSONSerialization.jsonObject(
                with: data,
                options: []
            )
        } catch {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidJSON
        }
        guard let object = root as? [String: Any] else {
            throw PrimeNativeNeuralGateReplayTransportError
                .rootObjectRequired
        }
        if rejectPromptOnlyFields {
            try rejectForbiddenPromptFields(object)
        }
        let value: Value
        do {
            value = try JSONDecoder().decode(
                type,
                from: data
            )
        } catch {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidJSON
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        let canonical: Data
        do {
            canonical = try encoder.encode(value)
        } catch {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidJSON
        }
        guard canonical == data else {
            throw PrimeNativeNeuralGateReplayTransportError
                .noncanonicalJSON
        }
        return value
    }

    private static func lexicalPreflight(
        _ data: Data,
        maximumByteCount: UInt64
    ) throws {
        guard !data.isEmpty else {
            throw PrimeNativeNeuralGateReplayTransportError
                .emptyArtifact
        }
        let effectiveMaximum = min(
            maximumByteCount,
            TransportLimits.maximumBytes
        )
        guard UInt64(data.count) <= effectiveMaximum else {
            throw PrimeNativeNeuralGateReplayTransportError
                .artifactTooLarge(
                    maximumBytes: effectiveMaximum
                )
        }
        let bytes = [UInt8](data)
        if bytes.count >= 3,
           bytes[0] == 0xef,
           bytes[1] == 0xbb,
           bytes[2] == 0xbf
        {
            throw PrimeNativeNeuralGateReplayTransportError
                .byteOrderMarkForbidden
        }
        guard String(data: data, encoding: .utf8) != nil else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidUTF8
        }
        let whitespace: Set<UInt8> = [
            0x09,
            0x0a,
            0x0d,
            0x20,
        ]
        guard let first = bytes.first(
            where: { !whitespace.contains($0) }
        ),
              let last = bytes.last(
                  where: { !whitespace.contains($0) }
              ),
              first == 0x7b,
              last == 0x7d
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .rootObjectRequired
        }

        var stack = [UInt8]()
        stack.reserveCapacity(
            TransportLimits.maximumDepth
        )
        var inString = false
        var escaped = false
        var stringByteCount = 0
        var structuralTokenCount = 0
        for byte in bytes {
            if inString {
                if escaped {
                    escaped = false
                    stringByteCount += 1
                } else if byte == 0x5c {
                    escaped = true
                    stringByteCount += 1
                } else if byte == 0x22 {
                    inString = false
                } else {
                    stringByteCount += 1
                }
                guard stringByteCount
                        <= TransportLimits.maximumStringBytes
                else {
                    throw PrimeNativeNeuralGateReplayTransportError
                        .stringTokenTooLarge(
                            maximumBytes:
                                TransportLimits.maximumStringBytes
                        )
                }
                continue
            }
            switch byte {
            case 0x22:
                inString = true
                escaped = false
                stringByteCount = 0
                structuralTokenCount += 1
            case 0x7b, 0x5b:
                stack.append(byte)
                structuralTokenCount += 1
                guard stack.count
                        <= TransportLimits.maximumDepth
                else {
                    throw PrimeNativeNeuralGateReplayTransportError
                        .nestingDepthExceeded(
                            maximumDepth:
                                TransportLimits.maximumDepth
                        )
                }
            case 0x7d:
                guard stack.popLast() == 0x7b else {
                    throw PrimeNativeNeuralGateReplayTransportError
                        .malformedLexicalStructure
                }
                structuralTokenCount += 1
            case 0x5d:
                guard stack.popLast() == 0x5b else {
                    throw PrimeNativeNeuralGateReplayTransportError
                        .malformedLexicalStructure
                }
                structuralTokenCount += 1
            case 0x2c, 0x3a:
                structuralTokenCount += 1
            default:
                break
            }
            guard structuralTokenCount
                    <= TransportLimits.maximumStructuralTokens
            else {
                throw PrimeNativeNeuralGateReplayTransportError
                    .structuralTokenLimitExceeded(
                        maximumCount:
                            TransportLimits.maximumStructuralTokens
                    )
            }
        }
        guard !inString,
              !escaped,
              stack.isEmpty
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .malformedLexicalStructure
        }
    }

    private static func rejectForbiddenPromptFields(
        _ value: Any
    ) throws {
        if let dictionary = value as? [String: Any] {
            let fragments = [
                "target",
                "correlation",
                "regrade",
                "budget",
                "seed",
                "support",
                "termination",
                "expected",
            ]
            for (key, child) in dictionary {
                let lower = key.lowercased()
                if fragments.contains(where: {
                    lower.contains($0)
                }) {
                    throw PrimeNativeNeuralGateReplayTransportError
                        .forbiddenPromptOnlyField(key)
                }
                try rejectForbiddenPromptFields(child)
            }
        } else if let array = value as? [Any] {
            for child in array {
                try rejectForbiddenPromptFields(child)
            }
        }
    }
}

public enum PrimeNativeNeuralGateReplayTransportDecoder {
    /// Performs the mode decision before a caller reads artifact bytes.
    /// Descriptor-streamed, source-codec, and deferred schemas never return a
    /// bounded spec from this API.
    public static func requireBoundedArtifactSpec(
        for key: PrimeNativeNeuralGateArtifactKey
    ) throws -> PrimeNativeNeuralGateArtifactSpec {
        let contract =
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4
        try contract.validate()
        let spec = try contract.spec(for: key)
        switch spec.decoderMode {
        case .boundedCanonicalJSON:
            return spec
        case .descriptorStreamingRequired:
            throw PrimeNativeNeuralGateReplayTransportError
                .descriptorStreamingDecoderRequired
        case .sourceBoundCodecRequired:
            throw PrimeNativeNeuralGateReplayTransportError
                .sourceBoundCodecRequired
        case .schemaDeferred:
            throw PrimeNativeNeuralGateReplayTransportError
                .schemaDeferred
        }
    }

    /// Decodes only artifacts whose frozen V4 spec explicitly admits bounded
    /// canonical JSON. Large payload and deferred keys fail before JSON parse.
    public static func decodeArtifact(
        key: PrimeNativeNeuralGateArtifactKey,
        from data: Data
    ) throws -> PrimeNativeNeuralGateReplayDecodedArtifact {
        let contract =
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4
        let spec = try requireBoundedArtifactSpec(
            for: key
        )

        switch key {
        case .promptOnlyFixtureManifest,
             .outerEvaluationManifest,
             .rawExecutionManifest:
            return .recordManifest(
                try decodeRecordManifest(
                    key: key,
                    spec: spec,
                    data: data,
                    contract: contract
                )
            )
        default:
            throw PrimeNativeNeuralGateReplayTransportError
                .unexpectedArtifactKey
        }
    }

    private static func decodeRecordManifest(
        key: PrimeNativeNeuralGateArtifactKey,
        spec: PrimeNativeNeuralGateArtifactSpec,
        data: Data,
        contract:
            PrimeNativeNeuralGateReplayArtifactOutputContract
    ) throws -> PrimeNativeNeuralGateReplayRecordManifest {
        let wire = try BoundedCanonicalJSON.decode(
            RecordManifestWire.self,
            from: data,
            maximumByteCount: spec.maximumByteCount
        )
        try requireArtifactEnvelope(
            schemaVersion: wire.schemaVersion,
            artifactKind: wire.artifactKind,
            spec: spec
        )
        guard !wire.recordsMaterialized,
              !wire.mechanicsPassAuthorized
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .authorizingClaimForbidden(
                    "manifest_materialization_or_pass"
                )
        }

        let requirement = try manifestRequirement(
            for: key,
            recordCount: wire.recordCount,
            contract: contract
        )
        guard wire.recordSchemaID
                == requirement.recordSchemaID,
              wire.recordCount
                == requirement.recordCount,
              wire.chunks.count
                == requirement.chunkKeys.count
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidManifest
        }
        let globalSpec = try contract.spec(
            for: requirement.globalKey
        )
        let global = try validateBinding(
            wire.globalStream,
            expectedSpec: globalSpec
        )

        var chunks = [PrimeNativeNeuralGateReplayChunkBinding]()
        chunks.reserveCapacity(wire.chunks.count)
        var aggregateRecordCount: UInt64 = 0
        for (index, chunkWire) in wire.chunks.enumerated() {
            guard chunkWire.ordinal == UInt32(index),
                  chunkWire.recordCount
                    == requirement.chunkRecordCounts[index]
            else {
                throw PrimeNativeNeuralGateReplayTransportError
                    .invalidManifest
            }
            let chunkSpec = try contract.spec(
                for: requirement.chunkKeys[index]
            )
            let artifact = try validateBinding(
                BindingWire(
                    relativePath: chunkWire.relativePath,
                    sha256: chunkWire.sha256,
                    byteCount: chunkWire.byteCount
                ),
                expectedSpec: chunkSpec
            )
            let recordAddition = aggregateRecordCount
                .addingReportingOverflow(
                    UInt64(chunkWire.recordCount)
                )
            guard !recordAddition.overflow
            else {
                throw PrimeNativeNeuralGateReplayTransportError
                    .invalidManifest
            }
            aggregateRecordCount = recordAddition.partialValue
            chunks.append(
                PrimeNativeNeuralGateReplayChunkBinding(
                    ordinal: chunkWire.ordinal,
                    recordCount: chunkWire.recordCount,
                    artifact: artifact
                )
            )
        }
        // Global and chunk streams use different source-bound headers, so
        // their encoded byte counts are not additive. Record partition counts
        // are exact here; byte equality belongs to the future streaming codec.
        guard aggregateRecordCount == UInt64(wire.recordCount)
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidManifest
        }
        return PrimeNativeNeuralGateReplayRecordManifest(
            artifactKey: key,
            relativePath: spec.relativePath,
            recordSchemaID: wire.recordSchemaID,
            recordCount: wire.recordCount,
            globalStream: global,
            orderedChunks: chunks
        )
    }

    private struct ManifestRequirement {
        let recordSchemaID: String
        let recordCount: UInt32
        let globalKey:
            PrimeNativeNeuralGateArtifactKey
        let chunkKeys:
            [PrimeNativeNeuralGateArtifactKey]
        let chunkRecordCounts: [UInt32]
    }

    private static func manifestRequirement(
        for key: PrimeNativeNeuralGateArtifactKey,
        recordCount: UInt32,
        contract:
            PrimeNativeNeuralGateReplayArtifactOutputContract
    ) throws -> ManifestRequirement {
        let invariantCount = UInt32(
            contract.invariantRecordsPerChunk
        )
        func fixtureChunkCounts() -> [UInt32] {
            var remaining =
                TransportLimits.correctedFixtureRowCount
            var result = [UInt32]()
            while remaining > 0 {
                let next = min(remaining, invariantCount)
                result.append(next)
                remaining -= next
            }
            return result
        }
        let fixtureCounts = fixtureChunkCounts()
        switch key {
        case .promptOnlyFixtureManifest:
            return ManifestRequirement(
                recordSchemaID:
                    PrimeNativeNeuralGateReplayRecordSchema
                    .promptOnlyRowV1,
                recordCount:
                    TransportLimits.correctedFixtureRowCount,
                globalKey: .promptOnlyFixtureGlobal,
                chunkKeys: fixtureCounts.indices.map {
                    .promptOnlyFixtureChunk(UInt32($0))
                },
                chunkRecordCounts: fixtureCounts
            )
        case .outerEvaluationManifest:
            return ManifestRequirement(
                recordSchemaID:
                    PrimeNativeNeuralGateReplayRecordSchema
                    .outerEvaluationRowV1,
                recordCount:
                    TransportLimits.correctedFixtureRowCount,
                globalKey: .outerEvaluationGlobal,
                chunkKeys: fixtureCounts.indices.map {
                    .outerEvaluationChunk(UInt32($0))
                },
                chunkRecordCounts: fixtureCounts
            )
        case let .rawExecutionManifest(seed):
            return ManifestRequirement(
                recordSchemaID:
                    PrimeNativeNeuralGateReplayRecordSchema
                    .rawExecutionReferenceV1,
                recordCount:
                    TransportLimits.correctedFixtureRowCount,
                globalKey: .rawExecutionGlobal(seed),
                chunkKeys: fixtureCounts.indices.map {
                    .rawExecutionChunk(seed, UInt32($0))
                },
                chunkRecordCounts: fixtureCounts
            )
        default:
            throw PrimeNativeNeuralGateReplayTransportError
                .unexpectedArtifactKey
        }
    }

    private static func validateBinding(
        _ wire: BindingWire,
        expectedSpec: PrimeNativeNeuralGateArtifactSpec
    ) throws -> PrimeNativeNeuralGateReplayArtifactBinding {
        guard wire.relativePath == expectedSpec.relativePath,
              wire.byteCount > 0,
              wire.byteCount <= expectedSpec.maximumByteCount
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidBinding
        }
        try requireSHA256(wire.sha256)
        return PrimeNativeNeuralGateReplayArtifactBinding(
            relativePath: wire.relativePath,
            sha256: wire.sha256,
            byteCount: wire.byteCount
        )
    }

    private static func requireArtifactEnvelope(
        schemaVersion: Int,
        artifactKind: String,
        spec: PrimeNativeNeuralGateArtifactSpec
    ) throws {
        guard schemaVersion == spec.schemaVersion else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidSchemaVersion
        }
        guard artifactKind == spec.schemaID else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidArtifactKind
        }
    }

    /// Decodes one prompt-only record emitted by a future descriptor-streaming
    /// extractor. The record has no path, target, correlation, regrade,
    /// caller-selected budget/support, or termination control.
    public static func decodePromptOnlyRow(
        from data: Data
    ) throws -> PrimeNativeNeuralGateReplayPromptRow {
        let wire = try BoundedCanonicalJSON.decode(
            PromptRowWire.self,
            from: data,
            maximumByteCount: 65_536,
            rejectPromptOnlyFields: true
        )
        try requireRecordEnvelope(
            schemaVersion: wire.schemaVersion,
            recordKind: wire.recordKind,
            expectedKind:
                PrimeNativeNeuralGateReplayRecordSchema
                .promptOnlyRowV1
        )
        let tokenIDs = wire.promptTokenIDs
        guard (2 ... TransportLimits.maximumPromptTokenCount)
                .contains(tokenIDs.count),
              tokenIDs.first == 1,
              tokenIDs.dropFirst().allSatisfy(
                  TransportLimits.byteTokenRange.contains
              )
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidPromptTokens
        }
        let promptBytes = tokenIDs.dropFirst().map {
            UInt8($0 - 256)
        }
        guard let prompt = String(
            data: Data(promptBytes),
            encoding: .utf8
        ),
              prompt == prompt.precomposedStringWithCanonicalMapping
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidPromptTokens
        }
        return PrimeNativeNeuralGateReplayPromptRow(
            promptTokenIDs: tokenIDs,
            canonicalPrompt: prompt
        )
    }

    public static func decodeOuterEvaluationRow(
        from data: Data
    ) throws -> PrimeNativeNeuralGateReplayOuterEvaluationRow {
        let wire = try BoundedCanonicalJSON.decode(
            OuterEvaluationRowWire.self,
            from: data,
            maximumByteCount: 8_192
        )
        try requireRecordEnvelope(
            schemaVersion: wire.schemaVersion,
            recordKind: wire.recordKind,
            expectedKind:
                PrimeNativeNeuralGateReplayRecordSchema
                .outerEvaluationRowV1
        )
        guard wire.executionIndex
                < TransportLimits.correctedFixtureRowCount
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidExecutionIndex
        }
        let correlationBytes = Array(wire.correlationID.utf8)
        guard (1 ... 512).contains(correlationBytes.count),
              correlationBytes.allSatisfy({
                  $0 >= 0x21 && $0 <= 0x7e
              })
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidCorrelationID
        }
        guard wire.expectedCompletionUTF8.count <= 63,
              let completion = String(
                  data: Data(wire.expectedCompletionUTF8),
                  encoding: .utf8
              ),
              completion
                == completion.precomposedStringWithCanonicalMapping
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidExpectedCompletion
        }
        return PrimeNativeNeuralGateReplayOuterEvaluationRow(
            executionIndex: wire.executionIndex,
            correlationID: wire.correlationID,
            expectedCompletionUTF8:
                Data(wire.expectedCompletionUTF8),
            canonicalExpectedCompletion: completion
        )
    }

    public static func decodeRawExecutionReference(
        expectedSeed: PrimeNativeNeuralGateArtifactSeed,
        from data: Data
    ) throws -> PrimeNativeNeuralGateReplayRawExecutionReference {
        let wire = try BoundedCanonicalJSON.decode(
            RawExecutionReferenceWire.self,
            from: data,
            maximumByteCount: 8_192
        )
        try requireRecordEnvelope(
            schemaVersion: wire.schemaVersion,
            recordKind: wire.recordKind,
            expectedKind:
                PrimeNativeNeuralGateReplayRecordSchema
                .rawExecutionReferenceV1
        )
        guard let seed = PrimeNativeNeuralGateArtifactSeed(
            rawValue: wire.replicateSeed
        ),
              seed == expectedSeed
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidReplicateSeed
        }
        guard wire.executionIndex
                < TransportLimits.correctedFixtureRowCount
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidExecutionIndex
        }
        try requireSHA256(wire.promptSHA256)
        try requireSHA256(wire.traceSHA256)
        guard !wire.logitsMaterialized,
              !wire.executionAuthorized
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .authorizingClaimForbidden(
                    "raw_execution_or_logits"
                )
        }
        guard let termination =
                PrimeNativeNeuralGateReplayTermination(
                    rawValue: wire.termination
                )
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidTermination
        }
        guard wire.generatedTokenIDs.allSatisfy(
            TransportLimits.byteTokenRange.contains
        ) else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidGeneratedTokens
        }
        switch termination {
        case .eos:
            guard wire.generatedTokenIDs.count <= 63,
                  Int(wire.decisionCount)
                    == wire.generatedTokenIDs.count + 1
            else {
                throw PrimeNativeNeuralGateReplayTransportError
                    .invalidTermination
            }
        case .fixedCap:
            guard wire.generatedTokenIDs.count
                    == TransportLimits.maximumGenerationDecisions,
                  Int(wire.decisionCount)
                    == TransportLimits.maximumGenerationDecisions
            else {
                throw PrimeNativeNeuralGateReplayTransportError
                    .invalidTermination
            }
        }
        return PrimeNativeNeuralGateReplayRawExecutionReference(
            replicateSeed: seed,
            executionIndex: wire.executionIndex,
            promptSHA256: wire.promptSHA256,
            traceSHA256: wire.traceSHA256,
            decisionCount: wire.decisionCount,
            generatedTokenIDs: wire.generatedTokenIDs,
            termination: termination
        )
    }

    private static func requireRecordEnvelope(
        schemaVersion: Int,
        recordKind: String,
        expectedKind: String
    ) throws {
        guard schemaVersion == 1 else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidSchemaVersion
        }
        guard recordKind == expectedKind else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidArtifactKind
        }
    }

    private static func requireSHA256(
        _ value: String
    ) throws {
        guard value.utf8.count == 64,
              value.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
              })
        else {
            throw PrimeNativeNeuralGateReplayTransportError
                .invalidSHA256(value)
        }
    }

}
