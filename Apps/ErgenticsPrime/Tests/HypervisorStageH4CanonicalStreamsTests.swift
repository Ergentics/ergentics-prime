import Foundation
import XCTest

final class HypervisorStageH4CanonicalStreamsTests: XCTestCase {
    private typealias H4 = HypervisorStageH4Privacy
    private typealias H4C = HypervisorStageH4CanonicalStreams

    private let epoch = "11111111-1111-4111-8111-111111111111"
    private let frozenSemanticSchema =
        "com.ergentics.provenance.hypervisor.h4.canonical-receipt.v1"
    private let frozenReconstructionSchema =
        "com.ergentics.provenance.hypervisor.h4.canonical-reconstruction.v1"

    private func source(
        predicateCount: UInt32 = 19,
        receiptRoot: String = String(repeating: "a", count: 64),
        rawDiagnostic: Data? = nil
    ) -> H4.Source {
        H4.Source(
            origin: .h3StructuralFixture,
            disposition: .contractOnly,
            subject: .h3Checkpoint,
            epoch: epoch,
            receiptRoot: receiptRoot,
            claimState: .observedNonPass,
            predicateCount: predicateCount,
            authorityVector: "00000000",
            rawDiagnostic: rawDiagnostic
        )
    }

    private func deliveries(
        predicateCount: UInt32 = 19,
        receiptRoot: String = String(repeating: "a", count: 64),
        rawDiagnostic: Data? = nil
    ) throws -> (
        internalReceipt: H4.InternalReceiptDelivery,
        sqlite: H4.SQLiteProjectionDelivery
    ) {
        let input = source(
            predicateCount: predicateCount,
            receiptRoot: receiptRoot,
            rawDiagnostic: rawDiagnostic
        )
        let capability = try XCTUnwrap(H4.issueTestCapability(
            source: input,
            validThroughTick: .max
        ))
        let dispatcher = try XCTUnwrap(H4.consumeTestDispatcher(
            capability: capability,
            request: H4.fixedRequest(epoch: epoch),
            source: input
        ))
        return (
            try dispatcher.takeInternalReceipt().get(),
            try dispatcher.takeSQLiteProjection().get()
        )
    }

    private func projection(
        predicateCount: UInt32 = 19,
        receiptRoot: String = String(repeating: "a", count: 64),
        rawDiagnostic: Data? = nil
    ) throws -> H4C.Projection {
        let value = try deliveries(
            predicateCount: predicateCount,
            receiptRoot: receiptRoot,
            rawDiagnostic: rawDiagnostic
        )
        return try H4C.projectTest(
            jsonReceipt: value.internalReceipt,
            cborJournal: value.sqlite
        )
    }

    private func expectedJSON(predicateCount: UInt32) -> Data {
        Data((
            "{\"authority_vector\":\"00000000\"," +
            "\"claim_state\":\"OBSERVED_NONPASS\"," +
            "\"predicate_count\":\(predicateCount)," +
            "\"schema\":\"\(frozenSemanticSchema)\"}"
        ).utf8)
    }

    /// Independent known-answer assembly. It deliberately does not share a
    /// generic integer or text encoder with the production implementation.
    private func expectedCBOR(predicateCount: UInt32) -> Data {
        let countBytes: [UInt8]
        switch predicateCount {
        case 1: countBytes = [0x01]
        case 19: countBytes = [0x13]
        case 20: countBytes = [0x14]
        case 23: countBytes = [0x17]
        case 24: countBytes = [0x18, 0x18]
        case 255: countBytes = [0x18, 0xff]
        case 256: countBytes = [0x19, 0x01, 0x00]
        case 4_096: countBytes = [0x19, 0x10, 0x00]
        default:
            XCTFail("Missing independent known-answer count vector")
            return Data()
        }

        var bytes = Data([0xa4])
        bytes.append(0x66)
        bytes.append(Data("schema".utf8))
        bytes.append(contentsOf: [0x78, 0x3b])
        bytes.append(Data(frozenSemanticSchema.utf8))
        bytes.append(0x6b)
        bytes.append(Data("claim_state".utf8))
        bytes.append(0x70)
        bytes.append(Data("OBSERVED_NONPASS".utf8))
        bytes.append(0x6f)
        bytes.append(Data("predicate_count".utf8))
        bytes.append(contentsOf: countBytes)
        bytes.append(0x70)
        bytes.append(Data("authority_vector".utf8))
        bytes.append(0x68)
        bytes.append(Data("00000000".utf8))
        return bytes
    }

    private func assertFailure(
        _ expected: H4C.Failure? = nil,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ body: () throws -> Void
    ) {
        do {
            try body()
            XCTFail("Expected closed H4-C rejection", file: file, line: line)
        } catch let failure as H4C.Failure {
            if let expected {
                XCTAssertEqual(failure, expected, file: file, line: line)
            }
        } catch {
            XCTFail("Unexpected error: \(error)", file: file, line: line)
        }
    }

    private func replacing(
        _ bytes: Data,
        range: Range<Data.Index>,
        with replacement: [UInt8]
    ) -> Data {
        var value = bytes
        value.replaceSubrange(range, with: replacement)
        return value
    }

    private func range(
        of needle: String,
        in bytes: Data,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Range<Data.Index> {
        try XCTUnwrap(
            bytes.range(of: Data(needle.utf8)),
            "Missing test vector field \(needle)",
            file: file,
            line: line
        )
    }

    func testKnownAnswerVectorsUseDifferentFrozenKeyOrders() throws {
        XCTAssertEqual(H4C.semanticSchema, frozenSemanticSchema)
        XCTAssertEqual(H4C.reconstructionSchema, frozenReconstructionSchema)
        for count: UInt32 in [1, 19, 23, 24, 255, 256, 4_096] {
            let value = try projection(predicateCount: count)
            XCTAssertEqual(value.json, expectedJSON(predicateCount: count))
            XCTAssertEqual(value.cbor, expectedCBOR(predicateCount: count))
        }

        let value = try projection(predicateCount: 19)
        let jsonSchema = try range(of: "\"schema\"", in: value.json)
        let jsonAuthority = try range(of: "\"authority_vector\"", in: value.json)
        let cborSchema = try range(of: "schema", in: value.cbor)
        let cborAuthority = try range(of: "authority_vector", in: value.cbor)
        XCTAssertLessThan(jsonAuthority.lowerBound, jsonSchema.lowerBound)
        XCTAssertLessThan(cborSchema.lowerBound, cborAuthority.lowerBound)
        XCTAssertEqual(value.json.count, 156)
        XCTAssertEqual(try projection(predicateCount: 4_096).json.count,
                       H4C.maximumStreamBytes)
        XCTAssertLessThan(value.cbor.count, H4C.maximumStreamBytes)
    }

    func testReconstructionReceiptStatesOnlyThreeStructuralPredicates() throws {
        let value = try projection()
        XCTAssertEqual(value.reconstruction.schema, frozenReconstructionSchema)
        XCTAssertEqual(value.reconstruction.semantic.schema, frozenSemanticSchema)
        XCTAssertEqual(value.reconstruction.semantic.claimState, .observedNonPass)
        XCTAssertEqual(value.reconstruction.semantic.predicateCount, 19)
        XCTAssertEqual(value.reconstruction.semantic.authorityVector, "00000000")
        XCTAssertTrue(value.reconstruction.jsonRoundTripExact)
        XCTAssertTrue(value.reconstruction.cborRoundTripExact)
        XCTAssertTrue(value.reconstruction.semanticJoinExact)
        XCTAssertEqual(
            Mirror(reflecting: value.reconstruction).children.compactMap(\.label),
            [
                "schema", "semantic", "jsonRoundTripExact",
                "cborRoundTripExact", "semanticJoinExact",
            ]
        )
    }

    func testProjectionIsDeterministicAcrossIndependentDispatchers() throws {
        let first = try projection()
        let second = try projection()
        XCTAssertEqual(first, second)
    }

    func testRawDiagnosticEpochAndReceiptRootAreAbsentFromBothStreams() throws {
        let canary = "H4C-RAW-DIAGNOSTIC-CANARY"
        let receiptRoot = String(repeating: "d", count: 64)
        let value = try projection(
            receiptRoot: receiptRoot,
            rawDiagnostic: Data(canary.utf8)
        )
        for forbidden in [canary, epoch, receiptRoot, H4.schema, H4.policyID] {
            let needle = Data(forbidden.utf8)
            XCTAssertNil(value.json.range(of: needle), forbidden)
            XCTAssertNil(value.cbor.range(of: needle), forbidden)
        }
        let semanticLabels = Mirror(reflecting: value.reconstruction.semantic)
            .children.compactMap(\.label)
        XCTAssertEqual(
            semanticLabels,
            ["schema", "claimState", "predicateCount", "authorityVector"]
        )
    }

    func testEveryTruncatedPrefixAndTrailingByteRejects() throws {
        let value = try projection()
        for end in 0..<value.json.count {
            assertFailure {
                _ = try H4C.reconstructTest(
                    json: Data(value.json.prefix(end)),
                    cbor: value.cbor
                )
            }
        }
        for end in 0..<value.cbor.count {
            assertFailure {
                _ = try H4C.reconstructTest(
                    json: value.json,
                    cbor: Data(value.cbor.prefix(end))
                )
            }
        }
        assertFailure {
            _ = try H4C.reconstructTest(
                json: value.json + Data([0x0a]),
                cbor: value.cbor
            )
        }
        assertFailure {
            _ = try H4C.reconstructTest(
                json: value.json,
                cbor: value.cbor + Data([0x00])
            )
        }
        assertFailure(.jsonBound) {
            _ = try H4C.reconstructTest(
                json: Data(repeating: 0x20, count: H4C.maximumStreamBytes + 1),
                cbor: value.cbor
            )
        }
        assertFailure(.cborBound) {
            _ = try H4C.reconstructTest(
                json: value.json,
                cbor: Data(repeating: 0x00, count: H4C.maximumStreamBytes + 1)
            )
        }
    }

    func testJSONRejectsWhitespaceAliasesOrderDuplicatesAndUnknownFields() throws {
        let value = try projection()
        let reordered = Data((
            "{\"claim_state\":\"OBSERVED_NONPASS\"," +
            "\"authority_vector\":\"00000000\"," +
            "\"predicate_count\":19," +
            "\"schema\":\"\(H4C.semanticSchema)\"}"
        ).utf8)
        let duplicate = Data((
            "{\"authority_vector\":\"00000000\"," +
            "\"authority_vector\":\"00000000\"," +
            "\"predicate_count\":19," +
            "\"schema\":\"\(H4C.semanticSchema)\"}"
        ).utf8)
        let unknown = Data((
            "{\"authority_vector\":\"00000000\"," +
            "\"unknown\":\"OBSERVED_NONPASS\"," +
            "\"predicate_count\":19," +
            "\"schema\":\"\(H4C.semanticSchema)\"}"
        ).utf8)
        let escapedAlias = Data((
            "{\"authority_vector\":\"\\u0030\"," +
            "\"claim_state\":\"OBSERVED_NONPASS\"," +
            "\"predicate_count\":19," +
            "\"schema\":\"\(H4C.semanticSchema)\"}"
        ).utf8)
        let leadingZero = Data((
            "{\"authority_vector\":\"00000000\"," +
            "\"claim_state\":\"OBSERVED_NONPASS\"," +
            "\"predicate_count\":019," +
            "\"schema\":\"\(H4C.semanticSchema)\"}"
        ).utf8)
        for grammarVector in [reordered, duplicate, unknown, escapedAlias, leadingZero] {
            XCTAssertLessThanOrEqual(grammarVector.count, H4C.maximumStreamBytes)
        }
        for candidate in [
            Data([0x20]) + value.json,
            value.json + Data([0x20]),
            reordered,
            duplicate,
            unknown,
            escapedAlias,
            leadingZero,
        ] {
            assertFailure {
                _ = try H4C.reconstructTest(json: candidate, cbor: value.cbor)
            }
        }
    }

    func testJSONRejectsCanonicalButInvalidSemanticValues() throws {
        let value = try projection()
        for count in ["0", "4097"] {
            let invalid = Data((
                "{\"authority_vector\":\"00000000\"," +
                "\"claim_state\":\"OBSERVED_NONPASS\"," +
                "\"predicate_count\":\(count)," +
                "\"schema\":\"\(H4C.semanticSchema)\"}"
            ).utf8)
            assertFailure(.jsonSemantic) {
                _ = try H4C.reconstructTest(json: invalid, cbor: value.cbor)
            }
        }

        let wrongAuthority = replacing(
            value.json,
            range: try range(of: "00000000", in: value.json),
            with: Array("10000000".utf8)
        )
        let wrongClaim = replacing(
            value.json,
            range: try range(of: "OBSERVED_NONPASS", in: value.json),
            with: Array("observed_nonpass".utf8)
        )
        let wrongSchema = replacing(
            value.json,
            range: try range(of: H4C.semanticSchema, in: value.json),
            with: Array(H4C.semanticSchema.dropLast().utf8) + [0x32]
        )
        for candidate in [wrongAuthority, wrongClaim, wrongSchema] {
            assertFailure(.jsonSemantic) {
                _ = try H4C.reconstructTest(json: candidate, cbor: value.cbor)
            }
        }
    }

    func testCBORRejectsMapAndTextAliasesBeforeSemanticJoin() throws {
        let value = try projection()
        let valid = value.cbor
        let schemaName = try range(of: "schema", in: valid)
        let claimName = try range(of: "claim_state", in: valid)
        let predicateName = try range(of: "predicate_count", in: valid)
        let authorityName = try range(of: "authority_vector", in: valid)
        let schemaPair = valid[(schemaName.lowerBound - 1)..<(claimName.lowerBound - 1)]
        let claimPair = valid[(claimName.lowerBound - 1)..<(predicateName.lowerBound - 1)]
        let predicatePair = valid[
            (predicateName.lowerBound - 1)..<(authorityName.lowerBound - 1)
        ]
        let authorityPair = valid[(authorityName.lowerBound - 1)..<valid.endIndex]
        var mapThree = valid
        mapThree[mapThree.startIndex] = 0xa3
        var mapFive = valid
        mapFive[mapFive.startIndex] = 0xa5
        let nonminimalMap = Data([0xb8, 0x04]) + Data(valid.dropFirst())
        var indefiniteMap = valid
        indefiniteMap[indefiniteMap.startIndex] = 0xbf
        let nonminimalFirstKey = Data([0xa4, 0x78, 0x06]) + Data(valid.dropFirst(2))
        var indefiniteFirstKey = valid
        indefiniteFirstKey[indefiniteFirstKey.index(after: indefiniteFirstKey.startIndex)] = 0x7f
        var invalidUTF8Key = valid
        invalidUTF8Key[invalidUTF8Key.index(invalidUTF8Key.startIndex, offsetBy: 2)] = 0xff
        var wrongCaseKey = valid
        wrongCaseKey[wrongCaseKey.index(wrongCaseKey.startIndex, offsetBy: 2)] = 0x53
        var nonTextFirstKey = valid
        nonTextFirstKey[nonTextFirstKey.index(after: nonTextFirstKey.startIndex)] = 0x46
        var invalidUTF8Schema = valid
        invalidUTF8Schema[schemaName.upperBound + 2] = 0xff
        var oversizedSchema = valid
        oversizedSchema[schemaName.upperBound + 1] = 0x80
        var schemaAsBytes = valid
        schemaAsBytes[schemaName.upperBound] = 0x58
        var reordered = Data([0xa4])
        reordered.append(claimPair)
        reordered.append(schemaPair)
        reordered.append(predicatePair)
        reordered.append(authorityPair)
        var duplicate = Data([0xa4])
        duplicate.append(schemaPair)
        duplicate.append(claimPair)
        duplicate.append(claimPair)
        duplicate.append(authorityPair)
        XCTAssertLessThanOrEqual(duplicate.count, H4C.maximumStreamBytes)

        for candidate in [
            mapThree,
            mapFive,
            nonminimalMap,
            indefiniteMap,
            nonminimalFirstKey,
            indefiniteFirstKey,
            invalidUTF8Key,
            wrongCaseKey,
            nonTextFirstKey,
            invalidUTF8Schema,
            oversizedSchema,
            schemaAsBytes,
            reordered,
            duplicate,
        ] {
            assertFailure {
                _ = try H4C.reconstructTest(json: value.json, cbor: candidate)
            }
        }
    }

    func testCBORRejectsNonminimalAndWrongMajorPredicateCounts() throws {
        let value = try projection()
        let countName = try range(of: "predicate_count", in: value.cbor)
        let countIndex = countName.upperBound
        XCTAssertEqual(value.cbor[countIndex], 0x13)

        let nonminimal = replacing(
            value.cbor,
            range: countIndex..<(countIndex + 1),
            with: [0x18, 0x13]
        )
        let substitutions: [[UInt8]] = [
            [0x33],       // negative integer
            [0x61, 0x13], // text
            [0x41, 0x13], // bytes
            [0x81, 0x13], // array
            [0xc0, 0x13], // tag
            [0xf4],       // false
            [0xf9, 0x00, 0x00], // float16
        ]
        assertFailure(.cborNoncanonical) {
            _ = try H4C.reconstructTest(json: value.json, cbor: nonminimal)
        }
        for substitution in substitutions {
            let candidate = replacing(
                value.cbor,
                range: countIndex..<(countIndex + 1),
                with: substitution
            )
            assertFailure {
                _ = try H4C.reconstructTest(json: value.json, cbor: candidate)
            }
        }
    }

    func testCBORRejectsEveryNonminimalPredicateWidthBoundary() throws {
        let vectors: [(UInt32, [UInt8])] = [
            (23, [0x18, 0x17]),
            (24, [0x19, 0x00, 0x18]),
            (255, [0x19, 0x00, 0xff]),
            (256, [0x1a, 0x00, 0x00, 0x01, 0x00]),
            (4_096, [0x1a, 0x00, 0x00, 0x10, 0x00]),
        ]
        for (count, nonminimalBytes) in vectors {
            let value = try projection(predicateCount: count)
            let countName = try range(of: "predicate_count", in: value.cbor)
            let countIndex = countName.upperBound
            let canonicalLength: Int
            switch count {
            case 23: canonicalLength = 1
            case 24, 255: canonicalLength = 2
            case 256, 4_096: canonicalLength = 3
            default: return XCTFail("Unexpected boundary vector")
            }
            let candidate = replacing(
                value.cbor,
                range: countIndex..<(countIndex + canonicalLength),
                with: nonminimalBytes
            )
            assertFailure(.cborNoncanonical) {
                _ = try H4C.reconstructTest(json: value.json, cbor: candidate)
            }
        }
    }

    func testCBORRejectsCanonicalButInvalidSemanticValues() throws {
        let value = try projection()
        let countName = try range(of: "predicate_count", in: value.cbor)
        let countIndex = countName.upperBound
        let zero = replacing(
            value.cbor,
            range: countIndex..<(countIndex + 1),
            with: [0x00]
        )
        let tooLarge = replacing(
            value.cbor,
            range: countIndex..<(countIndex + 1),
            with: [0x19, 0x10, 0x01]
        )
        assertFailure(.cborSemantic) {
            _ = try H4C.reconstructTest(json: value.json, cbor: zero)
        }
        assertFailure(.cborSemantic) {
            _ = try H4C.reconstructTest(json: value.json, cbor: tooLarge)
        }

        let schemaRange = try range(of: frozenSemanticSchema, in: value.cbor)
        let wrongSchema = replacing(
            value.cbor,
            range: schemaRange,
            with: Array(frozenSemanticSchema.dropLast().utf8) + [0x32]
        )
        let claimRange = try range(of: "OBSERVED_NONPASS", in: value.cbor)
        let wrongClaim = replacing(
            value.cbor,
            range: claimRange,
            with: Array("observed_nonpass".utf8)
        )
        let authorityRange = try range(of: "00000000", in: value.cbor)
        let wrongAuthority = replacing(
            value.cbor,
            range: authorityRange,
            with: Array("10000000".utf8)
        )
        for candidate in [wrongSchema, wrongClaim, wrongAuthority] {
            assertFailure(.cborSemantic) {
                _ = try H4C.reconstructTest(json: value.json, cbor: candidate)
            }
        }
    }

    func testIndividuallyCanonicalStreamsRejectSemanticConflict() throws {
        let nineteen = try projection(predicateCount: 19)
        let twenty = try projection(predicateCount: 20)
        assertFailure(.semanticMismatch) {
            _ = try H4C.reconstructTest(
                json: nineteen.json,
                cbor: twenty.cbor
            )
        }
    }

    func testConsistentTamperingCannotSubstituteForTypedSourceValues() throws {
        let nineteen = try deliveries(predicateCount: 19)
        let twenty = try projection(predicateCount: 20)

        let structuralOnly = try H4C.reconstructTest(
            json: twenty.json,
            cbor: twenty.cbor
        )
        XCTAssertEqual(structuralOnly.semantic.predicateCount, 20)
        assertFailure(.semanticMismatch) {
            _ = try H4C.verifyTest(
                json: twenty.json,
                cbor: twenty.cbor,
                jsonReceipt: nineteen.internalReceipt,
                cborJournal: nineteen.sqlite
            )
        }
    }

    func testDifferentDispatchersWithEqualMinimalValuesCanJoin() throws {
        let first = try deliveries(receiptRoot: String(repeating: "a", count: 64))
        let second = try deliveries(receiptRoot: String(repeating: "b", count: 64))
        let value = try H4C.projectTest(
            jsonReceipt: first.internalReceipt,
            cborJournal: second.sqlite
        )

        XCTAssertEqual(value.reconstruction.semantic.predicateCount, 19)
        XCTAssertTrue(value.reconstruction.semanticJoinExact)
        // This passing case is the explicit H4-C nonclaim: the four-field
        // semantic tuple cannot prove same dispatcher, owner, epoch, or root.
        XCTAssertNil(value.json.range(of: Data(String(repeating: "a", count: 64).utf8)))
        XCTAssertNil(value.cbor.range(of: Data(String(repeating: "b", count: 64).utf8)))
    }

    func testDistinctTypedInputsWithDifferentSemanticsReject() throws {
        let nineteen = try deliveries(predicateCount: 19)
        let twenty = try deliveries(predicateCount: 20)
        assertFailure(.semanticMismatch) {
            _ = try H4C.projectTest(
                jsonReceipt: nineteen.internalReceipt,
                cborJournal: twenty.sqlite
            )
        }
    }
}
