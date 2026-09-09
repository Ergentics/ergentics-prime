import Foundation

/// First-party tokenizer mechanics admitted by the resolved native contract.
///
/// NFC normalization is the only text transform. Whitespace, line endings,
/// and embedded NUL bytes remain data. Structural IDs occupy `0...255`; the
/// canonical-input UTF-8 byte vocabulary occupies `256...511`.
public enum PrimeNativeByteTokenizer {
    public static let schemaVersion = "1"
    public static let tokenizerID =
        "ergentics_prime_nfc_utf8_byte_v1"

    public static let padTokenID = 0
    public static let beginningOfSequenceTokenID = 1
    public static let endOfSequenceTokenID = 70
    public static let reservedSymbolicTokenRange = 0 ... 255
    public static let byteTokenBase = 256
    public static let byteTokenRange = 256 ... 511
    public static let tokenSpaceSize = 512
    public static let boundModelVocabularySize = 512

    public struct TokenRange:
        Codable,
        Equatable,
        Sendable
    {
        public let lowerBound: Int
        public let upperBound: Int

        public init(
            lowerBound: Int,
            upperBound: Int
        ) {
            self.lowerBound = lowerBound
            self.upperBound = upperBound
        }

        private enum CodingKeys: String, CodingKey {
            case lowerBound = "lower_bound"
            case upperBound = "upper_bound"
        }
    }

    public struct SpecialToken:
        Codable,
        Equatable,
        Sendable
    {
        public let name: String
        public let tokenID: Int

        public init(
            name: String,
            tokenID: Int
        ) {
            self.name = name
            self.tokenID = tokenID
        }

        private enum CodingKeys: String, CodingKey {
            case name
            case tokenID = "token_id"
        }
    }

    public struct ReplayProbe:
        Codable,
        Equatable,
        Sendable
    {
        public let id: String
        public let sourceUTF8SHA256: String
        public let canonicalUTF8SHA256: String
        public let tokenIDsSHA256: String
        public let foundationDataTokenIDsSHA256: String
        public let independentPathsAgree: Bool
        public let tokenCount: Int

        public init(
            id: String,
            sourceUTF8SHA256: String,
            canonicalUTF8SHA256: String,
            tokenIDsSHA256: String,
            foundationDataTokenIDsSHA256: String,
            independentPathsAgree: Bool,
            tokenCount: Int
        ) {
            self.id = id
            self.sourceUTF8SHA256 = sourceUTF8SHA256
            self.canonicalUTF8SHA256 =
                canonicalUTF8SHA256
            self.tokenIDsSHA256 = tokenIDsSHA256
            self.foundationDataTokenIDsSHA256 =
                foundationDataTokenIDsSHA256
            self.independentPathsAgree =
                independentPathsAgree
            self.tokenCount = tokenCount
        }

        private enum CodingKeys: String, CodingKey {
            case id
            case sourceUTF8SHA256 =
                "source_utf8_sha256"
            case canonicalUTF8SHA256 =
                "canonical_utf8_sha256"
            case tokenIDsSHA256 =
                "token_ids_sha256"
            case foundationDataTokenIDsSHA256 =
                "foundation_data_token_ids_sha256"
            case independentPathsAgree =
                "independent_paths_agree"
            case tokenCount = "token_count"
        }
    }

    public struct Manifest:
        Codable,
        Equatable,
        Sendable
    {
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

        public init(
            schemaVersion: String,
            tokenizerID: String,
            ownership: String,
            implementationLanguage: String,
            algorithm: String,
            unicodeNormalization: String,
            byteRepresentation: String,
            independentByteRepresentation: String,
            lowercase: Bool,
            preservesWhitespace: Bool,
            preservesLineEndings: Bool,
            trainingRequired: Bool,
            externalVocabulary: Bool,
            externalCorpus: Bool,
            tokenSpaceSize: Int,
            boundModelVocabularySize: Int,
            reservedSymbolicTokenRange: TokenRange,
            byteTokenRange: TokenRange,
            byteTokenBase: Int,
            byteTokenCount: Int,
            specialTokens: [SpecialToken],
            replayProbes: [ReplayProbe],
            replayProbeSHA256: String,
            manifestSHA256: String
        ) {
            self.schemaVersion = schemaVersion
            self.tokenizerID = tokenizerID
            self.ownership = ownership
            self.implementationLanguage =
                implementationLanguage
            self.algorithm = algorithm
            self.unicodeNormalization =
                unicodeNormalization
            self.byteRepresentation = byteRepresentation
            self.independentByteRepresentation =
                independentByteRepresentation
            self.lowercase = lowercase
            self.preservesWhitespace =
                preservesWhitespace
            self.preservesLineEndings =
                preservesLineEndings
            self.trainingRequired = trainingRequired
            self.externalVocabulary = externalVocabulary
            self.externalCorpus = externalCorpus
            self.tokenSpaceSize = tokenSpaceSize
            self.boundModelVocabularySize =
                boundModelVocabularySize
            self.reservedSymbolicTokenRange =
                reservedSymbolicTokenRange
            self.byteTokenRange = byteTokenRange
            self.byteTokenBase = byteTokenBase
            self.byteTokenCount = byteTokenCount
            self.specialTokens = specialTokens
            self.replayProbes = replayProbes
            self.replayProbeSHA256 = replayProbeSHA256
            self.manifestSHA256 = manifestSHA256
        }

        private enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case tokenizerID = "tokenizer_id"
            case ownership
            case implementationLanguage =
                "implementation_language"
            case algorithm
            case unicodeNormalization =
                "unicode_normalization"
            case byteRepresentation =
                "byte_representation"
            case independentByteRepresentation =
                "independent_byte_representation"
            case lowercase
            case preservesWhitespace =
                "preserves_whitespace"
            case preservesLineEndings =
                "preserves_line_endings"
            case trainingRequired = "training_required"
            case externalVocabulary =
                "external_vocabulary"
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
            case replayProbeSHA256 =
                "replay_probe_sha256"
            case manifestSHA256 = "manifest_sha256"
        }
    }

    public enum TokenizerError:
        Error,
        Equatable,
        LocalizedError,
        Sendable
    {
        case byteOutOfRange(Int)
        case tokenIDOutOfRange(Int)
        case tokenIDOutsideTokenSpace(Int)
        case invalidUTF8
        case invalidSequenceBoundary
        case manifestMismatch
        case manifestSHA256Mismatch
        case replayProbeMismatch

        public var errorDescription: String? {
            switch self {
            case let .byteOutOfRange(value):
                "byte value is outside 0...255: \(value)"
            case let .tokenIDOutOfRange(tokenID):
                "token ID is not a native byte token: \(tokenID)"
            case let .tokenIDOutsideTokenSpace(tokenID):
                "token ID is outside the 512-entry token space: \(tokenID)"
            case .invalidUTF8:
                "byte token sequence is not valid UTF-8"
            case .invalidSequenceBoundary:
                "sequence must contain exactly one leading BOS and trailing EOS"
            case .manifestMismatch:
                "tokenizer manifest differs from the admitted native profile"
            case .manifestSHA256Mismatch:
                "tokenizer manifest content hash differs from its declaration"
            case .replayProbeMismatch:
                "tokenizer replay probes differ from the admitted mechanics"
            }
        }
    }

    /// NFC is the only canonicalization. It does not trim text, lowercase it,
    /// or rewrite line endings.
    public static func canonicalize(
        _ text: String
    ) -> String {
        text.precomposedStringWithCanonicalMapping
    }

    public static func tokenID(
        forByte byte: Int
    ) throws -> Int {
        guard (0 ... 255).contains(byte) else {
            throw TokenizerError.byteOutOfRange(byte)
        }
        return byteTokenBase + byte
    }

    public static func byte(
        forTokenID tokenID: Int
    ) throws -> UInt8 {
        guard byteTokenRange.contains(tokenID) else {
            throw TokenizerError
                .tokenIDOutOfRange(tokenID)
        }
        return UInt8(tokenID - byteTokenBase)
    }

    public static func encode(
        _ text: String
    ) -> [Int] {
        canonicalize(text).utf8.map {
            byteTokenBase + Int($0)
        }
    }

    /// Disjoint Foundation path used to challenge the primary UTF-8 view.
    public static func encodeWithFoundationData(
        _ text: String
    ) throws -> [Int] {
        guard let data =
                canonicalize(text).data(using: .utf8)
        else {
            throw TokenizerError.invalidUTF8
        }
        return data.map {
            byteTokenBase + Int($0)
        }
    }

    public static func decode(
        _ tokenIDs: [Int]
    ) throws -> String {
        let bytes = try tokenIDs.map(byte(forTokenID:))
        let decoded = String(
            decoding: bytes,
            as: UTF8.self
        )
        guard Array(decoded.utf8) == bytes else {
            throw TokenizerError.invalidUTF8
        }
        return canonicalize(decoded)
    }

    public static func decodeWithFoundationData(
        _ tokenIDs: [Int]
    ) throws -> String {
        let bytes = try tokenIDs.map(byte(forTokenID:))
        guard let decoded = String(
            data: Data(bytes),
            encoding: .utf8
        ) else {
            throw TokenizerError.invalidUTF8
        }
        return canonicalize(decoded)
    }

    public static func encodeSequence(
        _ text: String
    ) -> [Int] {
        [beginningOfSequenceTokenID]
            + encode(text)
            + [endOfSequenceTokenID]
    }

    public static func decodeSequence(
        _ tokenIDs: [Int]
    ) throws -> String {
        guard tokenIDs.count >= 2,
              tokenIDs.first
                == beginningOfSequenceTokenID,
              tokenIDs.last
                == endOfSequenceTokenID,
              !tokenIDs.dropFirst().dropLast().contains(
                  beginningOfSequenceTokenID
              ),
              !tokenIDs.dropFirst().dropLast().contains(
                  endOfSequenceTokenID
              ) else {
            throw TokenizerError
                .invalidSequenceBoundary
        }
        return try decode(
            Array(
                tokenIDs.dropFirst().dropLast()
            )
        )
    }

    /// SHA-256 over ordered big-endian UInt32 token IDs.
    public static func tokenIDsSHA256(
        _ tokenIDs: [Int]
    ) throws -> String {
        var data = Data()
        data.reserveCapacity(
            tokenIDs.count
                * MemoryLayout<UInt32>.size
        )
        for tokenID in tokenIDs {
            guard (0 ..< tokenSpaceSize)
                    .contains(tokenID) else {
                throw TokenizerError
                    .tokenIDOutsideTokenSpace(tokenID)
            }
            var value = UInt32(tokenID).bigEndian
            withUnsafeBytes(of: &value) {
                data.append(contentsOf: $0)
            }
        }
        return PrimeSHA256.hexDigest(of: data)
    }

    public static func manifest()
        throws -> Manifest
    {
        let probes = try replayProbes()
        let replayProbeSHA256 =
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    probes
                )
            )
        let payload = ManifestPayload(
            schemaVersion: schemaVersion,
            tokenizerID: tokenizerID,
            ownership: "ergentics_first_party",
            implementationLanguage: "swift",
            algorithm: "nfc_utf8_byte_offset",
            unicodeNormalization: "NFC",
            byteRepresentation:
                "Swift.String.UTF8View",
            independentByteRepresentation:
                "Foundation.Data.UTF8",
            lowercase: false,
            preservesWhitespace: true,
            preservesLineEndings: true,
            trainingRequired: false,
            externalVocabulary: false,
            externalCorpus: false,
            tokenSpaceSize: tokenSpaceSize,
            boundModelVocabularySize:
                boundModelVocabularySize,
            reservedSymbolicTokenRange:
                TokenRange(
                    lowerBound:
                        reservedSymbolicTokenRange
                        .lowerBound,
                    upperBound:
                        reservedSymbolicTokenRange
                        .upperBound
                ),
            byteTokenRange:
                TokenRange(
                    lowerBound:
                        byteTokenRange.lowerBound,
                    upperBound:
                        byteTokenRange.upperBound
                ),
            byteTokenBase: byteTokenBase,
            byteTokenCount: 256,
            specialTokens: [
                SpecialToken(
                    name: "pad",
                    tokenID: padTokenID
                ),
                SpecialToken(
                    name: "beginning_of_sequence",
                    tokenID:
                        beginningOfSequenceTokenID
                ),
                SpecialToken(
                    name: "end_of_sequence",
                    tokenID:
                        endOfSequenceTokenID
                ),
            ],
            replayProbes: probes,
            replayProbeSHA256:
                replayProbeSHA256
        )
        return Manifest(
            schemaVersion: payload.schemaVersion,
            tokenizerID: payload.tokenizerID,
            ownership: payload.ownership,
            implementationLanguage:
                payload.implementationLanguage,
            algorithm: payload.algorithm,
            unicodeNormalization:
                payload.unicodeNormalization,
            byteRepresentation:
                payload.byteRepresentation,
            independentByteRepresentation:
                payload
                .independentByteRepresentation,
            lowercase: payload.lowercase,
            preservesWhitespace:
                payload.preservesWhitespace,
            preservesLineEndings:
                payload.preservesLineEndings,
            trainingRequired:
                payload.trainingRequired,
            externalVocabulary:
                payload.externalVocabulary,
            externalCorpus: payload.externalCorpus,
            tokenSpaceSize: payload.tokenSpaceSize,
            boundModelVocabularySize:
                payload.boundModelVocabularySize,
            reservedSymbolicTokenRange:
                payload.reservedSymbolicTokenRange,
            byteTokenRange:
                payload.byteTokenRange,
            byteTokenBase: payload.byteTokenBase,
            byteTokenCount: payload.byteTokenCount,
            specialTokens: payload.specialTokens,
            replayProbes: payload.replayProbes,
            replayProbeSHA256:
                payload.replayProbeSHA256,
            manifestSHA256:
                PrimeSHA256.hexDigest(
                    of:
                        try PrimeCanonicalJSON
                        .encode(payload)
                )
        )
    }

    public static func contentSHA256(
        of manifest: Manifest
    ) throws -> String {
        PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(
                ManifestPayload(manifest)
            )
        )
    }

    public static func verify(
        _ manifest: Manifest
    ) throws {
        guard manifest.manifestSHA256
                == (try contentSHA256(
                    of: manifest
                )) else {
            throw TokenizerError
                .manifestSHA256Mismatch
        }
        let replayHash =
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    manifest.replayProbes
                )
            )
        let expected = try self.manifest()
        guard manifest.replayProbeSHA256
                == replayHash,
              manifest.replayProbes
                == expected.replayProbes,
              manifest.replayProbes.allSatisfy(
                  \.independentPathsAgree
              ) else {
            throw TokenizerError.replayProbeMismatch
        }
        guard manifest == expected else {
            throw TokenizerError.manifestMismatch
        }

        let symbolic = Set(
            manifest
                .reservedSymbolicTokenRange
                .lowerBound
                ... manifest
                .reservedSymbolicTokenRange
                .upperBound
        )
        let bytes = Set(
            manifest.byteTokenRange.lowerBound
                ... manifest.byteTokenRange.upperBound
        )
        guard symbolic.isDisjoint(with: bytes),
              bytes.count == 256,
              bytes.max().map({
                  $0 < manifest
                    .boundModelVocabularySize
              }) == true else {
            throw TokenizerError.manifestMismatch
        }
    }

    private static func replayProbes()
        throws -> [ReplayProbe]
    {
        try replayProbeInputs.map {
            id, source in
            let canonical = canonicalize(source)
            let tokenIDs = encode(source)
            let independent =
                try encodeWithFoundationData(source)
            let primaryDecoded =
                try decode(tokenIDs)
            let independentDecoded =
                try decodeWithFoundationData(
                    independent
                )
            return ReplayProbe(
                id: id,
                sourceUTF8SHA256:
                    PrimeSHA256.hexDigest(
                        of: Data(source.utf8)
                    ),
                canonicalUTF8SHA256:
                    PrimeSHA256.hexDigest(
                        of: Data(canonical.utf8)
                    ),
                tokenIDsSHA256:
                    try tokenIDsSHA256(tokenIDs),
                foundationDataTokenIDsSHA256:
                    try tokenIDsSHA256(independent),
                independentPathsAgree:
                    tokenIDs == independent
                        && primaryDecoded == canonical
                        && independentDecoded
                            == canonical,
                tokenCount: tokenIDs.count
            )
        }
    }

    private static let replayProbeInputs:
        [(String, String)] =
    [
        ("empty", ""),
        (
            "ascii",
            "Prime evidence: retain exact semantics."
        ),
        ("nfc", "Cafe\u{301} — déjà vu"),
        (
            "multilingual",
            "証拠 · دليل · ראיה · साक्ष्य"
        ),
        ("emoji", "🧭🧠⚙️"),
        (
            "whitespace",
            " \tline one\r\nline two\n "
        ),
        ("nul", "before\u{0000}after"),
    ]

    private struct ManifestPayload:
        Codable,
        Equatable
    {
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

        init(
            schemaVersion: String,
            tokenizerID: String,
            ownership: String,
            implementationLanguage: String,
            algorithm: String,
            unicodeNormalization: String,
            byteRepresentation: String,
            independentByteRepresentation: String,
            lowercase: Bool,
            preservesWhitespace: Bool,
            preservesLineEndings: Bool,
            trainingRequired: Bool,
            externalVocabulary: Bool,
            externalCorpus: Bool,
            tokenSpaceSize: Int,
            boundModelVocabularySize: Int,
            reservedSymbolicTokenRange: TokenRange,
            byteTokenRange: TokenRange,
            byteTokenBase: Int,
            byteTokenCount: Int,
            specialTokens: [SpecialToken],
            replayProbes: [ReplayProbe],
            replayProbeSHA256: String
        ) {
            self.schemaVersion = schemaVersion
            self.tokenizerID = tokenizerID
            self.ownership = ownership
            self.implementationLanguage =
                implementationLanguage
            self.algorithm = algorithm
            self.unicodeNormalization =
                unicodeNormalization
            self.byteRepresentation =
                byteRepresentation
            self.independentByteRepresentation =
                independentByteRepresentation
            self.lowercase = lowercase
            self.preservesWhitespace =
                preservesWhitespace
            self.preservesLineEndings =
                preservesLineEndings
            self.trainingRequired = trainingRequired
            self.externalVocabulary =
                externalVocabulary
            self.externalCorpus = externalCorpus
            self.tokenSpaceSize = tokenSpaceSize
            self.boundModelVocabularySize =
                boundModelVocabularySize
            self.reservedSymbolicTokenRange =
                reservedSymbolicTokenRange
            self.byteTokenRange = byteTokenRange
            self.byteTokenBase = byteTokenBase
            self.byteTokenCount = byteTokenCount
            self.specialTokens = specialTokens
            self.replayProbes = replayProbes
            self.replayProbeSHA256 =
                replayProbeSHA256
        }

        init(_ manifest: Manifest) {
            self.init(
                schemaVersion:
                    manifest.schemaVersion,
                tokenizerID: manifest.tokenizerID,
                ownership: manifest.ownership,
                implementationLanguage:
                    manifest.implementationLanguage,
                algorithm: manifest.algorithm,
                unicodeNormalization:
                    manifest.unicodeNormalization,
                byteRepresentation:
                    manifest.byteRepresentation,
                independentByteRepresentation:
                    manifest
                    .independentByteRepresentation,
                lowercase: manifest.lowercase,
                preservesWhitespace:
                    manifest.preservesWhitespace,
                preservesLineEndings:
                    manifest.preservesLineEndings,
                trainingRequired:
                    manifest.trainingRequired,
                externalVocabulary:
                    manifest.externalVocabulary,
                externalCorpus:
                    manifest.externalCorpus,
                tokenSpaceSize:
                    manifest.tokenSpaceSize,
                boundModelVocabularySize:
                    manifest
                    .boundModelVocabularySize,
                reservedSymbolicTokenRange:
                    manifest
                    .reservedSymbolicTokenRange,
                byteTokenRange:
                    manifest.byteTokenRange,
                byteTokenBase:
                    manifest.byteTokenBase,
                byteTokenCount:
                    manifest.byteTokenCount,
                specialTokens:
                    manifest.specialTokens,
                replayProbes:
                    manifest.replayProbes,
                replayProbeSHA256:
                    manifest.replayProbeSHA256
            )
        }

        private enum CodingKeys:
            String,
            CodingKey
        {
            case schemaVersion = "schema_version"
            case tokenizerID = "tokenizer_id"
            case ownership
            case implementationLanguage =
                "implementation_language"
            case algorithm
            case unicodeNormalization =
                "unicode_normalization"
            case byteRepresentation =
                "byte_representation"
            case independentByteRepresentation =
                "independent_byte_representation"
            case lowercase
            case preservesWhitespace =
                "preserves_whitespace"
            case preservesLineEndings =
                "preserves_line_endings"
            case trainingRequired =
                "training_required"
            case externalVocabulary =
                "external_vocabulary"
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
            case replayProbeSHA256 =
                "replay_probe_sha256"
        }
    }
}
