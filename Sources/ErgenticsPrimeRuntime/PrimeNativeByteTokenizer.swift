import CryptoKit
import Foundation

/// First-party text tokenizer for the native Prime line.
///
/// This is deliberately a fixed, reversible byte tokenizer rather than a
/// hand-written BPE trainer. Unicode normalization is the only text transform;
/// whitespace and line endings are data. IDs `0...255` are reserved for
/// structural and symbolic controls; the byte vocabulary occupies `256...511`.
public enum PrimeNativeByteTokenizer {
    public static let schemaVersion = "1"
    public static let tokenizerID = "ergentics_prime_nfc_utf8_byte_v1"
    public static let relativeManifestPath =
        "content-staging/prime-native-byte-tokenizer-manifest.v1.json"

    public static let padTokenID = 0
    public static let beginningOfSequenceTokenID = 1
    public static let endOfSequenceTokenID = 70
    public static let reservedSymbolicTokenRange = 0 ... 255
    public static let byteTokenBase = 256
    public static let byteTokenRange = 256 ... 511
    public static let tokenSpaceSize = 512

    /// Exact vocabulary size of the native byte profile.
    public static let boundModelVocabularySize = 512

    public struct TokenRange: Codable, Equatable, Sendable {
        public let lowerBound: Int
        public let upperBound: Int

        enum CodingKeys: String, CodingKey {
            case lowerBound = "lower_bound"
            case upperBound = "upper_bound"
        }
    }

    public struct SpecialToken: Codable, Equatable, Sendable {
        public let name: String
        public let tokenID: Int

        enum CodingKeys: String, CodingKey {
            case name
            case tokenID = "token_id"
        }
    }

    public struct ReplayProbe: Codable, Equatable, Sendable {
        public let id: String
        public let sourceUTF8SHA256: String
        public let canonicalUTF8SHA256: String
        public let tokenIDsSHA256: String
        public let foundationDataTokenIDsSHA256: String
        public let independentPathsAgree: Bool
        public let tokenCount: Int

        enum CodingKeys: String, CodingKey {
            case id
            case sourceUTF8SHA256 = "source_utf8_sha256"
            case canonicalUTF8SHA256 = "canonical_utf8_sha256"
            case tokenIDsSHA256 = "token_ids_sha256"
            case foundationDataTokenIDsSHA256 =
                "foundation_data_token_ids_sha256"
            case independentPathsAgree = "independent_paths_agree"
            case tokenCount = "token_count"
        }
    }

    public struct Manifest: Codable, Equatable, Sendable {
        public let schemaVersion: String
        public let tokenizerID: String
        public let ownership: String
        public let implementationLanguage: String
        public let algorithm: String
        public let unicodeNormalization: String
        public let byteRepresentation: String
        public let independentByteRepresentation: String
        public let lowercase: Bool
        public let preservesWhitespace: Bool
        public let preservesLineEndings: Bool
        public let trainingRequired: Bool
        public let externalVocabulary: Bool
        public let externalCorpus: Bool
        public let tokenSpaceSize: Int
        public let boundModelVocabularySize: Int
        public let reservedSymbolicTokenRange: TokenRange
        public let byteTokenRange: TokenRange
        public let byteTokenBase: Int
        public let byteTokenCount: Int
        public let specialTokens: [SpecialToken]
        public let replayProbes: [ReplayProbe]
        public let replayProbeSHA256: String
        public let manifestSHA256: String

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case tokenizerID = "tokenizer_id"
            case ownership
            case implementationLanguage = "implementation_language"
            case algorithm
            case unicodeNormalization = "unicode_normalization"
            case byteRepresentation = "byte_representation"
            case independentByteRepresentation =
                "independent_byte_representation"
            case lowercase
            case preservesWhitespace = "preserves_whitespace"
            case preservesLineEndings = "preserves_line_endings"
            case trainingRequired = "training_required"
            case externalVocabulary = "external_vocabulary"
            case externalCorpus = "external_corpus"
            case tokenSpaceSize = "token_space_size"
            case boundModelVocabularySize =
                "bound_model_vocabulary_size"
            case reservedSymbolicTokenRange =
                "reserved_symbolic_token_range"
            case byteTokenRange = "byte_token_range"
            case byteTokenBase = "byte_token_base"
            case byteTokenCount = "byte_token_count"
            case specialTokens = "special_tokens"
            case replayProbes = "replay_probes"
            case replayProbeSHA256 = "replay_probe_sha256"
            case manifestSHA256 = "manifest_sha256"
        }
    }

    private struct ManifestPayload: Codable, Equatable {
        let schemaVersion: String
        let tokenizerID: String
        let ownership: String
        let implementationLanguage: String
        let algorithm: String
        let unicodeNormalization: String
        let byteRepresentation: String
        let independentByteRepresentation: String
        let lowercase: Bool
        let preservesWhitespace: Bool
        let preservesLineEndings: Bool
        let trainingRequired: Bool
        let externalVocabulary: Bool
        let externalCorpus: Bool
        let tokenSpaceSize: Int
        let boundModelVocabularySize: Int
        let reservedSymbolicTokenRange: TokenRange
        let byteTokenRange: TokenRange
        let byteTokenBase: Int
        let byteTokenCount: Int
        let specialTokens: [SpecialToken]
        let replayProbes: [ReplayProbe]
        let replayProbeSHA256: String

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case tokenizerID = "tokenizer_id"
            case ownership
            case implementationLanguage = "implementation_language"
            case algorithm
            case unicodeNormalization = "unicode_normalization"
            case byteRepresentation = "byte_representation"
            case independentByteRepresentation =
                "independent_byte_representation"
            case lowercase
            case preservesWhitespace = "preserves_whitespace"
            case preservesLineEndings = "preserves_line_endings"
            case trainingRequired = "training_required"
            case externalVocabulary = "external_vocabulary"
            case externalCorpus = "external_corpus"
            case tokenSpaceSize = "token_space_size"
            case boundModelVocabularySize =
                "bound_model_vocabulary_size"
            case reservedSymbolicTokenRange =
                "reserved_symbolic_token_range"
            case byteTokenRange = "byte_token_range"
            case byteTokenBase = "byte_token_base"
            case byteTokenCount = "byte_token_count"
            case specialTokens = "special_tokens"
            case replayProbes = "replay_probes"
            case replayProbeSHA256 = "replay_probe_sha256"
        }
    }

    public enum TokenizerError: Error, Equatable, LocalizedError {
        case byteOutOfRange(Int)
        case tokenIDOutOfRange(Int)
        case invalidUTF8
        case invalidSequenceBoundary
        case manifestMismatch
        case manifestSHA256Mismatch
        case replayProbeMismatch
        case outputExistsWithDifferentContent(String)

        public var errorDescription: String? {
            switch self {
            case .byteOutOfRange(let value):
                "Byte value is outside 0...255: \(value)"
            case .tokenIDOutOfRange(let tokenID):
                "Token ID is not a native byte token: \(tokenID)"
            case .invalidUTF8:
                "Byte token sequence is not valid UTF-8."
            case .invalidSequenceBoundary:
                "Sequence must contain exactly one leading BOS and trailing EOS."
            case .manifestMismatch:
                "Tokenizer manifest does not match the frozen native profile."
            case .manifestSHA256Mismatch:
                "Tokenizer manifest content hash does not match."
            case .replayProbeMismatch:
                "Tokenizer replay probes do not match this runtime."
            case .outputExistsWithDifferentContent(let path):
                "Refusing to overwrite a different tokenizer manifest: \(path)"
            }
        }
    }

    /// NFC is the only canonicalization. In particular, this function does not
    /// trim text or rewrite CR/LF sequences.
    public static func canonicalize(_ text: String) -> String {
        text.precomposedStringWithCanonicalMapping
    }

    public static func tokenID(forByte byte: Int) throws -> Int {
        guard (0 ... 255).contains(byte) else {
            throw TokenizerError.byteOutOfRange(byte)
        }
        return byteTokenBase + byte
    }

    public static func byte(forTokenID tokenID: Int) throws -> UInt8 {
        guard byteTokenRange.contains(tokenID) else {
            throw TokenizerError.tokenIDOutOfRange(tokenID)
        }
        return UInt8(tokenID - byteTokenBase)
    }

    public static func encode(_ text: String) -> [Int] {
        canonicalize(text).utf8.map {
            byteTokenBase + Int($0)
        }
    }

    /// Independent replay path used to falsify drift in the primary
    /// `String.UTF8View` implementation.
    public static func encodeWithFoundationData(
        _ text: String
    ) -> [Int] {
        let data = canonicalize(text).data(using: .utf8)!
        return data.map { byteTokenBase + Int($0) }
    }

    public static func decode(_ tokenIDs: [Int]) throws -> String {
        let bytes = try tokenIDs.map(byte(forTokenID:))
        let decoded = String(decoding: bytes, as: UTF8.self)
        guard Array(decoded.utf8) == bytes else {
            throw TokenizerError.invalidUTF8
        }
        return canonicalize(decoded)
    }

    public static func decodeWithFoundationData(
        _ tokenIDs: [Int]
    ) throws -> String {
        let bytes = try tokenIDs.map(byte(forTokenID:))
        guard let decoded = String(data: Data(bytes), encoding: .utf8)
        else {
            throw TokenizerError.invalidUTF8
        }
        return canonicalize(decoded)
    }

    public static func encodeSequence(_ text: String) -> [Int] {
        [beginningOfSequenceTokenID]
            + encode(text)
            + [endOfSequenceTokenID]
    }

    public static func decodeSequence(_ tokenIDs: [Int]) throws -> String {
        guard tokenIDs.count >= 2,
              tokenIDs.first == beginningOfSequenceTokenID,
              tokenIDs.last == endOfSequenceTokenID,
              !tokenIDs.dropFirst().dropLast().contains(
                beginningOfSequenceTokenID
              ),
              !tokenIDs.dropFirst().dropLast().contains(
                endOfSequenceTokenID
              ) else {
            throw TokenizerError.invalidSequenceBoundary
        }
        return try decode(Array(tokenIDs.dropFirst().dropLast()))
    }

    public static func manifest() -> Manifest {
        let probes = replayProbes()
        let probeHash = sha256(canonicalJSONData(probes))
        let payload = ManifestPayload(
            schemaVersion: schemaVersion,
            tokenizerID: tokenizerID,
            ownership: "ergentics_first_party",
            implementationLanguage: "swift",
            algorithm: "nfc_utf8_byte_offset",
            unicodeNormalization: "NFC",
            byteRepresentation: "Swift.String.UTF8View",
            independentByteRepresentation:
                "Foundation.Data.UTF8",
            lowercase: false,
            preservesWhitespace: true,
            preservesLineEndings: true,
            trainingRequired: false,
            externalVocabulary: false,
            externalCorpus: false,
            tokenSpaceSize: tokenSpaceSize,
            boundModelVocabularySize: boundModelVocabularySize,
            reservedSymbolicTokenRange: TokenRange(
                lowerBound: reservedSymbolicTokenRange.lowerBound,
                upperBound: reservedSymbolicTokenRange.upperBound
            ),
            byteTokenRange: TokenRange(
                lowerBound: byteTokenRange.lowerBound,
                upperBound: byteTokenRange.upperBound
            ),
            byteTokenBase: byteTokenBase,
            byteTokenCount: 256,
            specialTokens: [
                SpecialToken(name: "pad", tokenID: padTokenID),
                SpecialToken(
                    name: "beginning_of_sequence",
                    tokenID: beginningOfSequenceTokenID
                ),
                SpecialToken(
                    name: "end_of_sequence",
                    tokenID: endOfSequenceTokenID
                ),
            ],
            replayProbes: probes,
            replayProbeSHA256: probeHash
        )
        return Manifest(
            schemaVersion: payload.schemaVersion,
            tokenizerID: payload.tokenizerID,
            ownership: payload.ownership,
            implementationLanguage: payload.implementationLanguage,
            algorithm: payload.algorithm,
            unicodeNormalization: payload.unicodeNormalization,
            byteRepresentation: payload.byteRepresentation,
            independentByteRepresentation:
                payload.independentByteRepresentation,
            lowercase: payload.lowercase,
            preservesWhitespace: payload.preservesWhitespace,
            preservesLineEndings: payload.preservesLineEndings,
            trainingRequired: payload.trainingRequired,
            externalVocabulary: payload.externalVocabulary,
            externalCorpus: payload.externalCorpus,
            tokenSpaceSize: payload.tokenSpaceSize,
            boundModelVocabularySize: payload.boundModelVocabularySize,
            reservedSymbolicTokenRange:
                payload.reservedSymbolicTokenRange,
            byteTokenRange: payload.byteTokenRange,
            byteTokenBase: payload.byteTokenBase,
            byteTokenCount: payload.byteTokenCount,
            specialTokens: payload.specialTokens,
            replayProbes: payload.replayProbes,
            replayProbeSHA256: payload.replayProbeSHA256,
            manifestSHA256: sha256(canonicalJSONData(payload))
        )
    }

    public static func verify(_ manifest: Manifest) throws {
        let expected = self.manifest()
        guard manifest.manifestSHA256 == contentSHA256(of: manifest)
        else {
            throw TokenizerError.manifestSHA256Mismatch
        }
        guard manifest.replayProbeSHA256
                == sha256(canonicalJSONData(manifest.replayProbes)),
              manifest.replayProbes == replayProbes(),
              manifest.replayProbes.allSatisfy(
                  \.independentPathsAgree
              ) else {
            throw TokenizerError.replayProbeMismatch
        }
        guard manifest == expected else {
            throw TokenizerError.manifestMismatch
        }

        let symbolic = Set(
            manifest.reservedSymbolicTokenRange.lowerBound
                ... manifest.reservedSymbolicTokenRange.upperBound
        )
        let bytes = Set(
            manifest.byteTokenRange.lowerBound
                ... manifest.byteTokenRange.upperBound
        )
        guard symbolic.isDisjoint(with: bytes),
              bytes.count == 256,
              bytes.max()! < manifest.boundModelVocabularySize else {
            throw TokenizerError.manifestMismatch
        }
    }

    @discardableResult
    public static func writeManifest(to url: URL) throws -> URL {
        let manifest = manifest()
        try verify(manifest)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        let encoded = try encoder.encode(manifest)
        if FileManager.default.fileExists(atPath: url.path) {
            guard try Data(contentsOf: url) == encoded else {
                throw TokenizerError.outputExistsWithDifferentContent(
                    url.path
                )
            }
            return url
        }
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try encoded.write(to: url, options: .atomic)
        return url
    }

    public static func loadManifest(from url: URL) throws -> Manifest {
        let value = try JSONDecoder().decode(
            Manifest.self,
            from: Data(contentsOf: url)
        )
        try verify(value)
        return value
    }

    public static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map {
            String(format: "%02x", $0)
        }.joined()
    }

    public static func tokenIDsSHA256(_ tokenIDs: [Int]) -> String {
        var data = Data()
        data.reserveCapacity(tokenIDs.count * MemoryLayout<UInt32>.size)
        for tokenID in tokenIDs {
            var value = UInt32(tokenID).bigEndian
            withUnsafeBytes(of: &value) {
                data.append(contentsOf: $0)
            }
        }
        return sha256(data)
    }

    private static func replayProbes() -> [ReplayProbe] {
        replayProbeInputs.map { id, source in
            let canonical = canonicalize(source)
            let tokenIDs = encode(source)
            let foundationTokenIDs = encodeWithFoundationData(source)
            let decoded = try! decode(tokenIDs)
            let foundationDecoded = try! decodeWithFoundationData(
                foundationTokenIDs
            )
            return ReplayProbe(
                id: id,
                sourceUTF8SHA256: sha256(Data(source.utf8)),
                canonicalUTF8SHA256: sha256(Data(canonical.utf8)),
                tokenIDsSHA256: tokenIDsSHA256(tokenIDs),
                foundationDataTokenIDsSHA256:
                    tokenIDsSHA256(foundationTokenIDs),
                independentPathsAgree:
                    tokenIDs == foundationTokenIDs
                        && decoded == canonical
                        && foundationDecoded == canonical,
                tokenCount: tokenIDs.count
            )
        }
    }

    private static let replayProbeInputs: [(String, String)] = [
        ("empty", ""),
        ("ascii", "Prime evidence: retain exact semantics."),
        ("nfc", "Cafe\u{301} — déjà vu"),
        ("multilingual", "証拠 · دليل · ראיה · साक्ष्य"),
        ("emoji", "🧭🧠⚙️"),
        ("whitespace", " \tline one\r\nline two\n "),
        ("nul", "before\u{0000}after"),
    ]

    /// Canonical content hash excluding the `manifest_sha256` field itself.
    /// Exposing this lets independent gates re-hash a decoded artifact without
    /// trusting the writer.
    public static func contentSHA256(
        of manifest: Manifest
    ) -> String {
        sha256(
            canonicalJSONData(
                ManifestPayload(
                    schemaVersion: manifest.schemaVersion,
                    tokenizerID: manifest.tokenizerID,
                    ownership: manifest.ownership,
                    implementationLanguage:
                        manifest.implementationLanguage,
                    algorithm: manifest.algorithm,
                    unicodeNormalization:
                        manifest.unicodeNormalization,
                    byteRepresentation: manifest.byteRepresentation,
                    independentByteRepresentation:
                        manifest.independentByteRepresentation,
                    lowercase: manifest.lowercase,
                    preservesWhitespace:
                        manifest.preservesWhitespace,
                    preservesLineEndings:
                        manifest.preservesLineEndings,
                    trainingRequired: manifest.trainingRequired,
                    externalVocabulary: manifest.externalVocabulary,
                    externalCorpus: manifest.externalCorpus,
                    tokenSpaceSize: manifest.tokenSpaceSize,
                    boundModelVocabularySize:
                        manifest.boundModelVocabularySize,
                    reservedSymbolicTokenRange:
                        manifest.reservedSymbolicTokenRange,
                    byteTokenRange: manifest.byteTokenRange,
                    byteTokenBase: manifest.byteTokenBase,
                    byteTokenCount: manifest.byteTokenCount,
                    specialTokens: manifest.specialTokens,
                    replayProbes: manifest.replayProbes,
                    replayProbeSHA256:
                        manifest.replayProbeSHA256
                )
            )
        )
    }

    private static func canonicalJSONData<T: Encodable>(
        _ value: T
    ) -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try! encoder.encode(value)
    }
}
