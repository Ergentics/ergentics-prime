import Foundation

/// H4-C is a pure, in-memory representation boundary. JSON is projected from
/// the H4-B internal-receipt exit while CBOR is projected independently from
/// the SQLite-preparation exit. Both streams decode and round-trip separately
/// before their minimal typed semantics are compared.
///
/// A successful codec result proves representation consistency only. H4-D's
/// production entry additionally requires the unforgeable dispatcher-owned
/// input below; the codec still performs no persistence, hashing, Merkle work,
/// process/VM action, clock read, or authority transition.
enum HypervisorStageH4CanonicalStreams {
    typealias H4 = HypervisorStageH4Privacy

    static let semanticSchema =
        "com.ergentics.provenance.hypervisor.h4.canonical-receipt.v1"
    static let reconstructionSchema =
        "com.ergentics.provenance.hypervisor.h4.canonical-reconstruction.v1"
    /// Exact maximum of either admitted v1 stream. Canonical JSON at the
    /// maximum predicate count (4096) is 158 bytes; canonical CBOR is smaller.
    static let maximumStreamBytes = 158

    enum Failure: Error, Equatable, Sendable {
        case sourceSemantic
        case jsonBound
        case jsonMalformed
        case jsonNoncanonical
        case jsonSemantic
        case cborBound
        case cborMalformed
        case cborNoncanonical
        case cborSemantic
        case semanticMismatch
    }

    struct Semantic: Equatable, Sendable {
        let schema: String
        let claimState: H4.ClaimState
        let predicateCount: UInt32
        let authorityVector: String

        fileprivate init(
            schema: String,
            claimState: H4.ClaimState,
            predicateCount: UInt32,
            authorityVector: String
        ) {
            self.schema = schema
            self.claimState = claimState
            self.predicateCount = predicateCount
            self.authorityVector = authorityVector
        }
    }

    /// Successful construction means both decoders reconstructed exactly the
    /// same minimal semantics and each stream re-encoded to identical bytes.
    /// The booleans are explicit structural predicates, not authority bits.
    struct ReconstructionReceipt: Equatable, Sendable {
        let schema: String
        let semantic: Semantic
        let jsonRoundTripExact: Bool
        let cborRoundTripExact: Bool
        let semanticJoinExact: Bool

        fileprivate init(semantic: Semantic) {
            schema = HypervisorStageH4CanonicalStreams.reconstructionSchema
            self.semantic = semantic
            jsonRoundTripExact = true
            cborRoundTripExact = true
            semanticJoinExact = true
        }
    }

    /// D2c's deliberately weaker restart-side result. The retained v2 row has
    /// exact CBOR bytes and checked scalar indexes, but no independently
    /// retained JSON bytes. Successful construction therefore proves only a
    /// canonical-CBOR/index join and can never stand in for ReconstructionReceipt.
    struct RetainedCBORInspectionReceipt: Equatable, Sendable, CustomReflectable {
        fileprivate init() {}

        var schema: String {
            "com.ergentics.provenance.hypervisor.h4.retained-cbor-inspection.v1"
        }
        var canonicalCBORExact: Bool { true }
        var indexedFieldsExact: Bool { true }
        var independentJSONPresent: Bool { false }
        var dualStreamJoinExact: Bool { false }
        var admitted: Bool { false }

        var customMirror: Mirror {
            Mirror(
                self,
                children: EmptyCollection<(label: String?, value: Any)>(),
                displayStyle: .struct
            )
        }
    }

    struct Projection: Equatable, Sendable {
        let json: Data
        let cbor: Data
        let reconstruction: ReconstructionReceipt

        fileprivate init(
            json: Data,
            cbor: Data,
            reconstruction: ReconstructionReceipt
        ) {
            self.json = json
            self.cbor = cbor
            self.reconstruction = reconstruction
        }
    }

    /// Sole production entry. `CanonicalStreamInput` can be initialized only by
    /// the H4-A/B dispatcher, which atomically supplies both typed values and
    /// the process-local owner/epoch anchor. H4-C never serializes that anchor.
    static func projectBound(
        _ input: H4.CanonicalStreamInput
    ) throws -> HypervisorStageH4OwnerBinding.OwnerBoundCanonicalProjection {
        let canonical = try projectUnbound(
            jsonReceipt: input.internalReceipt,
            cborJournal: input.sqliteProjection
        )
        return HypervisorStageH4OwnerBinding.OwnerBoundCanonicalProjection(
            canonical: canonical,
            input: input
        )
    }

    /// Pure codec core. Its caller-supplied pair surface is private in product
    /// builds; only the test-conditioned bridge below preserves H4-C's retired
    /// mixability vectors as diagnostic evidence.
    private static func projectUnbound(
        jsonReceipt: H4.InternalReceiptDelivery,
        cborJournal: H4.SQLiteProjectionDelivery
    ) throws -> Projection {
        let expectedJSON = try semantic(
            claimState: jsonReceipt.projection.claimState,
            predicateCount: jsonReceipt.projection.predicateCount,
            authorityVector: jsonReceipt.projection.authorityVector
        )
        let expectedCBOR = try semantic(
            claimState: cborJournal.projection.claimState,
            predicateCount: cborJournal.projection.predicateCount,
            authorityVector: cborJournal.projection.authorityVector
        )
        let json = try CanonicalJSON.encode(expectedJSON)
        let cbor = try DeterministicCBOR.encode(expectedCBOR)
        let receipt = try reconstruct(
            json: json,
            cbor: cbor,
            expectedJSON: expectedJSON,
            expectedCBOR: expectedCBOR
        )
        return Projection(json: json, cbor: cbor, reconstruction: receipt)
    }

    /// Decodes the byte streams independently and joins only the reconstructed
    /// typed values. Neither decoder consumes output from the other. The final
    /// comparisons keep a consistently tampered pair from substituting for the
    /// two destination-specific source values supplied to `project`.
    private static func reconstruct(
        json: Data,
        cbor: Data,
        expectedJSON: Semantic,
        expectedCBOR: Semantic
    ) throws -> ReconstructionReceipt {
        let receipt = try decodeAndJoin(json: json, cbor: cbor)
        guard receipt.semantic == expectedJSON,
              receipt.semantic == expectedCBOR else {
            throw Failure.semanticMismatch
        }
        return receipt
    }

    private static func decodeAndJoin(
        json: Data,
        cbor: Data
    ) throws -> ReconstructionReceipt {
        let jsonSemantic = try CanonicalJSON.decode(json)
        let cborSemantic = try DeterministicCBOR.decode(cbor)
        guard jsonSemantic == cborSemantic else { throw Failure.semanticMismatch }
        return ReconstructionReceipt(semantic: jsonSemantic)
    }

    /// D2's closed reopen join. SQLite contributes only the exact retained
    /// CBOR bytes and checked scalar columns; the independently retained
    /// in-memory JSON stream is decoded again. Agreement is representation
    /// consistency only and creates no semantic or execution authority.
    static func reconstructPersisted(
        _ reopenedInput: HypervisorStageH4Persistence.ReopenedSQLiteRowInput,
        expected: Projection
    ) throws -> ReconstructionReceipt {
        let canonicalCBOR = reopenedInput.canonicalCBOR
        let semanticSchema = reopenedInput.semanticSchema
        let claimState = reopenedInput.claimState
        let predicateCount = reopenedInput.predicateCount
        let authorityVector = reopenedInput.authorityVector
        guard predicateCount > 0, predicateCount <= 4_096,
              let state = H4.ClaimState(rawValue: claimState) else {
            throw Failure.cborSemantic
        }
        let indexed = Semantic(
            schema: semanticSchema,
            claimState: state,
            predicateCount: UInt32(predicateCount),
            authorityVector: authorityVector
        )
        try validate(indexed, failure: .cborSemantic)
        let reopened = try decodeAndJoin(
            json: expected.json,
            cbor: canonicalCBOR
        )
        guard canonicalCBOR == expected.cbor,
              reopened == expected.reconstruction,
              reopened.semantic == indexed,
              try CanonicalJSON.encode(reopened.semantic) == expected.json,
              try DeterministicCBOR.encode(reopened.semantic) == canonicalCBOR else {
            throw Failure.semanticMismatch
        }
        return reopened
    }

    /// D3's writer-side dual-stream join. Both exact retained byte streams are
    /// decoded independently and compared with the separately materialized
    /// scalar columns and the original owner-bound projection. No stream is
    /// synthesized from the other and this creates no restart authority.
    static func reconstructPersistedDual(
        _ reopenedInput:
            HypervisorStageH4DualStreamPersistence.ReopenedDualStreamRowInput,
        expected: Projection
    ) throws -> ReconstructionReceipt {
        let predicateCount = reopenedInput.predicateCount
        guard reopenedInput.canonicalJSON.count > 0,
              reopenedInput.canonicalJSON.count <= maximumStreamBytes,
              reopenedInput.canonicalCBOR.count > 0,
              reopenedInput.canonicalCBOR.count <= maximumStreamBytes,
              predicateCount > 0, predicateCount <= 4_096,
              let state = H4.ClaimState(rawValue: reopenedInput.claimState)
        else {
            throw Failure.semanticMismatch
        }
        let indexed = Semantic(
            schema: reopenedInput.semanticSchema,
            claimState: state,
            predicateCount: UInt32(predicateCount),
            authorityVector: reopenedInput.authorityVector
        )
        try validate(indexed, failure: .semanticMismatch)
        let reopened = try decodeAndJoin(
            json: reopenedInput.canonicalJSON,
            cbor: reopenedInput.canonicalCBOR
        )
        guard reopenedInput.canonicalJSON == expected.json,
              reopenedInput.canonicalCBOR == expected.cbor,
              reopened == expected.reconstruction,
              reopened.semantic == indexed,
              try CanonicalJSON.encode(reopened.semantic) ==
                reopenedInput.canonicalJSON,
              try DeterministicCBOR.encode(reopened.semantic) ==
                reopenedInput.canonicalCBOR else {
            throw Failure.semanticMismatch
        }
        return reopened
    }

    /// D2c inspection of the self-contained subset actually retained by the
    /// v2 image. No JSON is synthesized here: doing so would collapse the two
    /// H4-C producer streams into one and invent restart continuity.
    static func inspectRetainedCBOR(
        _ reopenedInput: HypervisorStageH4Persistence.ReopenedSQLiteRowInput
    ) throws -> RetainedCBORInspectionReceipt {
        let predicateCount = reopenedInput.predicateCount
        guard reopenedInput.canonicalCBOR.count > 0,
              reopenedInput.canonicalCBOR.count <= maximumStreamBytes,
              predicateCount > 0, predicateCount <= 4_096,
              let state = H4.ClaimState(rawValue: reopenedInput.claimState)
        else {
            throw Failure.cborSemantic
        }
        let indexed = Semantic(
            schema: reopenedInput.semanticSchema,
            claimState: state,
            predicateCount: UInt32(predicateCount),
            authorityVector: reopenedInput.authorityVector
        )
        try validate(indexed, failure: .cborSemantic)
        let decoded = try DeterministicCBOR.decode(reopenedInput.canonicalCBOR)
        guard decoded == indexed,
              try DeterministicCBOR.encode(decoded) == reopenedInput.canonicalCBOR else {
            throw Failure.semanticMismatch
        }
        return RetainedCBORInspectionReceipt()
    }

    #if EPR_H4_PRIVACY_TESTS
    /// Produces a different, internally consistent semantic value through the
    /// two existing independent encoders. D3 uses this only to prove that a
    /// coherent JSON/CBOR/index substitution still fails the owner-bound join.
    static func d3SelfConsistentSubstitutionTestVector(
        from expected: Projection
    ) throws -> (json: Data, cbor: Data, predicateCount: Int64) {
        let original = expected.reconstruction.semantic
        let replacementCount: UInt32
        if original.predicateCount == 4_096 {
            replacementCount = 4_095
        } else if original.predicateCount == 9 ||
                    original.predicateCount == 99 ||
                    original.predicateCount == 999 {
            replacementCount = original.predicateCount - 1
        } else {
            replacementCount = original.predicateCount + 1
        }
        let replacement = Semantic(
            schema: original.schema,
            claimState: original.claimState,
            predicateCount: replacementCount,
            authorityVector: original.authorityVector
        )
        return (
            json: try CanonicalJSON.encode(replacement),
            cbor: try DeterministicCBOR.encode(replacement),
            predicateCount: Int64(replacementCount)
        )
    }

    /// H4-C regression bridge for the formerly production-visible two-input
    /// seam. This symbol is absent from the application binary.
    static func projectTest(
        jsonReceipt: H4.InternalReceiptDelivery,
        cborJournal: H4.SQLiteProjectionDelivery
    ) throws -> Projection {
        try projectUnbound(jsonReceipt: jsonReceipt, cborJournal: cborJournal)
    }

    /// Isolated adversarial-test bridge. This symbol is absent from the app.
    /// It proves only that two supplied byte streams reconstruct identically.
    static func reconstructTest(
        json: Data,
        cbor: Data
    ) throws -> ReconstructionReceipt {
        try decodeAndJoin(json: json, cbor: cbor)
    }

    /// Isolated source-binding test bridge. It exercises the same comparisons
    /// used by `project` without adding a production byte-ingestion surface.
    static func verifyTest(
        json: Data,
        cbor: Data,
        jsonReceipt: H4.InternalReceiptDelivery,
        cborJournal: H4.SQLiteProjectionDelivery
    ) throws -> ReconstructionReceipt {
        let expectedJSON = try semantic(
            claimState: jsonReceipt.projection.claimState,
            predicateCount: jsonReceipt.projection.predicateCount,
            authorityVector: jsonReceipt.projection.authorityVector
        )
        let expectedCBOR = try semantic(
            claimState: cborJournal.projection.claimState,
            predicateCount: cborJournal.projection.predicateCount,
            authorityVector: cborJournal.projection.authorityVector
        )
        return try reconstruct(
            json: json,
            cbor: cbor,
            expectedJSON: expectedJSON,
            expectedCBOR: expectedCBOR
        )
    }
    #endif

    private static func semantic(
        claimState: H4.ClaimState,
        predicateCount: UInt32,
        authorityVector: String
    ) throws -> Semantic {
        let value = Semantic(
            schema: semanticSchema,
            claimState: claimState,
            predicateCount: predicateCount,
            authorityVector: authorityVector
        )
        try validate(value, failure: .sourceSemantic)
        return value
    }

    private static func validate(_ value: Semantic, failure: Failure) throws {
        guard value.schema.utf8.elementsEqual(semanticSchema.utf8),
              value.claimState == .observedNonPass,
              value.predicateCount > 0,
              value.predicateCount <= 4_096,
              value.authorityVector.utf8.elementsEqual("00000000".utf8) else {
            throw failure
        }
    }

    /// Closed canonical JSON grammar for the four-field H4-C semantic value.
    /// It accepts no whitespace, escapes, alternate key order, unknown keys,
    /// duplicate keys, number aliases, or trailing bytes.
    private enum CanonicalJSON {
        static func encode(_ value: Semantic) throws -> Data {
            try validate(value, failure: .jsonSemantic)
            let text = "{\"authority_vector\":\"\(value.authorityVector)\"," +
                "\"claim_state\":\"\(value.claimState.rawValue)\"," +
                "\"predicate_count\":\(value.predicateCount)," +
                "\"schema\":\"\(value.schema)\"}"
            let bytes = Data(text.utf8)
            guard !bytes.isEmpty, bytes.count <= maximumStreamBytes else {
                throw Failure.jsonBound
            }
            return bytes
        }

        static func decode(_ bytes: Data) throws -> Semantic {
            guard !bytes.isEmpty, bytes.count <= maximumStreamBytes else {
                throw Failure.jsonBound
            }
            var parser = Parser(bytes: Array(bytes))
            let value = try parser.takeSemantic()
            try validate(value, failure: .jsonSemantic)
            guard try encode(value) == bytes else { throw Failure.jsonNoncanonical }
            return value
        }

        private struct Parser {
            let bytes: [UInt8]
            var offset = 0

            mutating func takeSemantic() throws -> Semantic {
                try expect("{\"authority_vector\":")
                let authorityVector = try takeString()
                try expect(",\"claim_state\":")
                let claim = try takeString()
                try expect(",\"predicate_count\":")
                let count = try takeUnsigned()
                try expect(",\"schema\":")
                let schema = try takeString()
                try expect("}")
                guard offset == bytes.count else { throw Failure.jsonNoncanonical }
                guard let claimState = H4.ClaimState(rawValue: claim),
                      let predicateCount = UInt32(exactly: count) else {
                    throw Failure.jsonSemantic
                }
                return Semantic(
                    schema: schema,
                    claimState: claimState,
                    predicateCount: predicateCount,
                    authorityVector: authorityVector
                )
            }

            mutating func expect(_ literal: String) throws {
                let expected = Array(literal.utf8)
                guard expected.count <= bytes.count - offset,
                      bytes[offset..<(offset + expected.count)]
                        .elementsEqual(expected) else {
                    throw Failure.jsonMalformed
                }
                offset += expected.count
            }

            mutating func takeString() throws -> String {
                guard offset < bytes.count, bytes[offset] == 0x22 else {
                    throw Failure.jsonMalformed
                }
                offset += 1
                let start = offset
                while offset < bytes.count, bytes[offset] != 0x22 {
                    let byte = bytes[offset]
                    guard byte >= 0x20, byte <= 0x7e, byte != 0x5c,
                          offset - start < 128 else {
                        throw Failure.jsonMalformed
                    }
                    offset += 1
                }
                guard offset < bytes.count, bytes[offset] == 0x22 else {
                    throw Failure.jsonMalformed
                }
                let value = String(decoding: bytes[start..<offset], as: UTF8.self)
                offset += 1
                return value
            }

            mutating func takeUnsigned() throws -> UInt64 {
                guard offset < bytes.count, (0x30...0x39).contains(bytes[offset]) else {
                    throw Failure.jsonMalformed
                }
                if bytes[offset] == 0x30 {
                    offset += 1
                    if offset < bytes.count, (0x30...0x39).contains(bytes[offset]) {
                        throw Failure.jsonNoncanonical
                    }
                    return 0
                }
                var value: UInt64 = 0
                var digits = 0
                while offset < bytes.count, (0x30...0x39).contains(bytes[offset]) {
                    let digit = UInt64(bytes[offset] - 0x30)
                    let multiplied = value.multipliedReportingOverflow(by: 10)
                    let added = multiplied.partialValue.addingReportingOverflow(digit)
                    guard !multiplied.overflow, !added.overflow, digits < 10 else {
                        throw Failure.jsonSemantic
                    }
                    value = added.partialValue
                    digits += 1
                    offset += 1
                }
                return value
            }
        }
    }

    /// Schema-specific RFC 8949 core-deterministic CBOR. Map keys are emitted
    /// in the bytewise order of their complete deterministic encodings:
    /// schema, claim_state, predicate_count, authority_vector. This intentionally
    /// differs from the canonical JSON key order above.
    private enum DeterministicCBOR {
        static func encode(_ value: Semantic) throws -> Data {
            try validate(value, failure: .cborSemantic)
            var writer = Writer()
            try writer.argument(major: 5, value: 4)
            try writer.text("schema")
            try writer.text(value.schema)
            try writer.text("claim_state")
            try writer.text(value.claimState.rawValue)
            try writer.text("predicate_count")
            try writer.argument(major: 0, value: UInt64(value.predicateCount))
            try writer.text("authority_vector")
            try writer.text(value.authorityVector)
            return writer.output
        }

        static func decode(_ bytes: Data) throws -> Semantic {
            guard !bytes.isEmpty, bytes.count <= maximumStreamBytes else {
                throw Failure.cborBound
            }
            var parser = Parser(bytes: Array(bytes))
            let value = try parser.takeSemantic()
            try validate(value, failure: .cborSemantic)
            guard try encode(value) == bytes else { throw Failure.cborNoncanonical }
            return value
        }

        private struct Writer {
            var output = Data()

            mutating func append(_ bytes: Data) throws {
                guard bytes.count <= maximumStreamBytes - output.count else {
                    throw Failure.cborBound
                }
                output.append(bytes)
            }

            mutating func argument(major: UInt8, value: UInt64) throws {
                var frame = Data()
                if value < 24 {
                    frame.append((major << 5) | UInt8(value))
                } else {
                    let width: Int
                    let additional: UInt8
                    if value <= 0xff {
                        width = 1
                        additional = 24
                    } else if value <= 0xffff {
                        width = 2
                        additional = 25
                    } else if value <= 0xffff_ffff {
                        width = 4
                        additional = 26
                    } else {
                        width = 8
                        additional = 27
                    }
                    frame.append((major << 5) | additional)
                    for index in (0..<width).reversed() {
                        frame.append(UInt8(truncatingIfNeeded: value >> (index * 8)))
                    }
                }
                try append(frame)
            }

            mutating func text(_ value: String) throws {
                let bytes = Data(value.utf8)
                guard bytes.count <= 128 else { throw Failure.cborBound }
                try argument(major: 3, value: UInt64(bytes.count))
                try append(bytes)
            }
        }

        private struct Parser {
            let bytes: [UInt8]
            var offset = 0

            mutating func takeSemantic() throws -> Semantic {
                guard try argument(major: 5) == 4 else {
                    throw Failure.cborNoncanonical
                }
                try expectText("schema")
                let schema = try takeText()
                try expectText("claim_state")
                let claim = try takeText()
                try expectText("predicate_count")
                let count = try argument(major: 0)
                try expectText("authority_vector")
                let authorityVector = try takeText()
                guard offset == bytes.count else { throw Failure.cborNoncanonical }
                guard let claimState = H4.ClaimState(rawValue: claim),
                      let predicateCount = UInt32(exactly: count) else {
                    throw Failure.cborSemantic
                }
                return Semantic(
                    schema: schema,
                    claimState: claimState,
                    predicateCount: predicateCount,
                    authorityVector: authorityVector
                )
            }

            mutating func expectText(_ expected: String) throws {
                guard try takeText().utf8.elementsEqual(expected.utf8) else {
                    throw Failure.cborNoncanonical
                }
            }

            mutating func takeText() throws -> String {
                let count = try argument(major: 3)
                guard count <= 128, count <= UInt64(bytes.count - offset) else {
                    throw Failure.cborMalformed
                }
                let end = offset + Int(count)
                guard let value = String(
                    data: Data(bytes[offset..<end]),
                    encoding: .utf8
                ) else {
                    throw Failure.cborMalformed
                }
                offset = end
                return value
            }

            mutating func argument(major expectedMajor: UInt8) throws -> UInt64 {
                guard offset < bytes.count else { throw Failure.cborMalformed }
                let initial = bytes[offset]
                offset += 1
                guard initial >> 5 == expectedMajor else {
                    throw Failure.cborMalformed
                }
                let additional = initial & 31
                if additional < 24 { return UInt64(additional) }
                let width: Int
                switch additional {
                case 24: width = 1
                case 25: width = 2
                case 26: width = 4
                case 27: width = 8
                default: throw Failure.cborMalformed
                }
                guard width <= bytes.count - offset else {
                    throw Failure.cborMalformed
                }
                var value: UInt64 = 0
                for _ in 0..<width {
                    value = (value << 8) | UInt64(bytes[offset])
                    offset += 1
                }
                let minimum: UInt64
                switch width {
                case 1: minimum = 24
                case 2: minimum = 256
                case 4: minimum = 65_536
                default: minimum = 4_294_967_296
                }
                guard value >= minimum else { throw Failure.cborNoncanonical }
                return value
            }
        }
    }
}
