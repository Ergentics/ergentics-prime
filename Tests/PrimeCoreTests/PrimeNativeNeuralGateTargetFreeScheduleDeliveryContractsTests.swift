import Foundation
@testable import PrimeCore
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
import XCTest

final class PrimeNativeNeuralGateTargetFreeScheduleDeliveryContractsTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
    private typealias Error =
        PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
    private typealias RawSlot =
        PrimeNativeNeuralGateTargetFreeRawScheduleSlot
    private typealias OuterSlot =
        PrimeNativeNeuralGateTargetFreeOuterScheduleSlot
    private typealias RawCandidate =
        PrimeNativeNeuralGateTargetFreeRawScheduleCandidate
    private typealias OuterCandidate =
        PrimeNativeNeuralGateTargetFreeOuterScheduleCandidate
    private typealias Pair =
        PrimeNativeNeuralGateTargetFreeScheduleCandidatePair
    private typealias StreamContract =
        PrimeNativeNeuralGateTargetFreeScheduleStreamContract
    private typealias StreamHeader =
        PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader
    private typealias StreamDecoder =
        PrimeNativeNeuralGateTargetFreeScheduleCandidatePairStreamDecoder
    private typealias StreamError =
        PrimeNativeNeuralGateTargetFreeScheduleStreamError

    func testFrozenContractIsExactAndNonauthorizing()
        throws
    {
        let contract = Contract.frozenV1
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_target_free_schedule_delivery_contract_v1"
        )
        XCTAssertEqual(
            contract.correlationIdentityMagic,
            "PRIMECOR1"
        )
        XCTAssertEqual(
            contract.admittedInvocationRoles,
            [.probe, .verifier]
        )
        XCTAssertEqual(
            contract.rawSlotWireFieldAllowlist,
            [
                "canonical_prompt",
                "correlation_id",
                "execution_index",
                "primecpi2_prompt_binding_sha256",
                "prompt_token_ids",
            ]
        )
        XCTAssertEqual(
            contract.outerSlotWireFieldAllowlist,
            ["correlation_id", "execution_index"]
        )
        XCTAssertEqual(
            contract.maximumCandidateRowCount,
            18_432
        )
        XCTAssertEqual(
            contract.exactScheduleRowCount,
            18_432
        )
        XCTAssertTrue(
            contract.strictSlotUnknownKeyRejectionImplemented
        )
        XCTAssertTrue(contract.boundedSlotDecodingImplemented)
        XCTAssertFalse(
            contract.boundedCandidateDecodingImplemented
        )
        XCTAssertTrue(
            contract
                .maintainedPromptDerivationValidationImplemented
        )
        XCTAssertTrue(
            contract.primeCOR1RecomputationImplemented
        )
        XCTAssertTrue(
            contract.candidateContentBindingImplemented
        )
        XCTAssertTrue(contract.sourceScheduleReferenceIncluded)
        XCTAssertFalse(
            contract.sourceScheduleIdentityBindingImplemented
        )
        XCTAssertFalse(contract.sourceBindingEstablished)
        XCTAssertFalse(
            contract.durableArtifactOriginEstablished
        )
        XCTAssertFalse(
            contract
                .promptContentTargetIndependenceEstablished
        )
        XCTAssertFalse(contract.processOwnershipEstablished)
        XCTAssertFalse(contract.processDeliveryObserved)
        XCTAssertFalse(contract.workerMaterialized)
        XCTAssertFalse(contract.modelExecutionEstablished)
        XCTAssertFalse(contract.evaluationPerformed)
        XCTAssertFalse(
            contract.verdictPublicationAuthorized
        )
        XCTAssertFalse(contract.publicationAuthorized)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.terminalReceiptAuthorized)
        XCTAssertFalse(
            contract.scientificAuthorityAuthorized
        )
        XCTAssertFalse(contract.productAuthorityAuthorized)

        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(contract)
            ),
            "2418856c22891798954b43ef956ee1bc7b91a7b3959b7c572ad07c4e1e1d377d"
        )
    }

    func testV2StreamContractAndScalarHeaderAreStrictAndNonauthorizing()
        throws
    {
        let contract = StreamContract.frozenV2
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 2)
        XCTAssertEqual(contract.exactScheduleRowCount, 18_432)
        XCTAssertEqual(
            contract.maximumRawAggregateRecordBytes,
            301_989_888
        )
        XCTAssertEqual(
            contract.maximumOuterAggregateRecordBytes,
            18_874_368
        )
        XCTAssertEqual(
            contract.maximumRawFramedStreamBytes,
            302_137_361
        )
        XCTAssertEqual(
            contract.maximumOuterFramedStreamBytes,
            19_021_841
        )
        XCTAssertEqual(
            contract.maximumCombinedFramedStreamBytes,
            321_159_202
        )
        XCTAssertTrue(contract.exactDeclaredCountFailEarlyImplemented)
        XCTAssertTrue(contract.oneRecordAtATimeDecodingImplemented)
        XCTAssertTrue(
            contract.boundedCandidateStreamDecodingImplemented
        )
        XCTAssertTrue(contract.aggregateJSONCandidateDecodingForbidden)
        XCTAssertTrue(contract.candidateTypesRemainEncodableOnly)
        XCTAssertFalse(contract.sourceBindingEstablished)
        XCTAssertFalse(contract.durableArtifactOriginEstablished)
        XCTAssertFalse(
            contract.promptContentTargetIndependenceEstablished
        )
        XCTAssertFalse(contract.processOwnershipEstablished)
        XCTAssertFalse(contract.processDeliveryObserved)
        XCTAssertFalse(contract.workerMaterialized)
        XCTAssertFalse(contract.modelExecutionEstablished)
        XCTAssertFalse(contract.evaluationPerformed)
        XCTAssertFalse(contract.verdictPublicationAuthorized)
        XCTAssertFalse(contract.publicationAuthorized)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.terminalReceiptAuthorized)
        XCTAssertFalse(contract.scientificAuthorityAuthorized)
        XCTAssertFalse(contract.productAuthorityAuthorized)
        XCTAssertFalse(RawCandidate.self is any Decodable.Type)
        XCTAssertFalse(OuterCandidate.self is any Decodable.Type)
        XCTAssertFalse(Pair.self is any Decodable.Type)
        XCTAssertFalse(StreamHeader.self is any Decodable.Type)
        XCTAssertFalse(
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission
                .self is any Encodable.Type
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission
                .self is any Decodable.Type
        )
        XCTAssertFalse(StreamDecoder.self is any Encodable.Type)
        XCTAssertFalse(StreamDecoder.self is any Decodable.Type)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(contract)
            ),
            "ed897cba2313f25bfcf610a6eb1abcdc4c45eaee2524c758f49d515c0ca49331"
        )

        let header = try StreamHeader(
            invocationRole: .verifier,
            promptSourceBindingSHA256: Self.digest("2"),
            scheduleIdentitySHA256: Self.digest("3"),
            rawOrderedSlotsSHA256:
                "c1b7f30e70492343be15b75bfad31bb99cc1bb3112b3059c6d453e9287d7d423",
            outerOrderedSlotsSHA256:
                "91612f6be7cce4c6566063c9087f25ebd532f25c2f5fbf3df68fa8fdab6a619d"
        )
        XCTAssertEqual(
            header.rawCandidateIdentitySHA256,
            "5016b1ce11be8eb4e88b38b1b2664d24b46b8efd4dca5570a35f6ade5a78ebfa"
        )
        XCTAssertEqual(
            header.outerCandidateIdentitySHA256,
            "75e01ac9937c14c4dd0a6193e58523878fba7079c19cb7898e4e4cb8832bf015"
        )
        XCTAssertEqual(
            header.deliveryIdentitySHA256,
            "5fe3096fe56d32a4bf818bcdb36dfab5b72367eff982965556738d83c55ec014"
        )
        let canonical = try header.canonicalJSON()
        XCTAssertLessThanOrEqual(
            canonical.count,
            contract.maximumHeaderJSONByteCount
        )
        XCTAssertEqual(
            try StreamHeader.decodeBounded(from: canonical),
            header
        )

        var noncanonical = canonical
        noncanonical.append(0x0A)
        XCTAssertThrowsError(
            try StreamHeader.decodeBounded(from: noncanonical)
        ) {
            XCTAssertEqual(
                $0 as? StreamError,
                .noncanonicalHeaderEncoding
            )
        }
        let injected = try Self.inject(
            key: "target",
            into: canonical
        )
        XCTAssertThrowsError(
            try StreamHeader.decodeBounded(from: injected)
        ) {
            XCTAssertEqual(
                $0 as? StreamError,
                .unexpectedHeaderKeys(["target"])
            )
        }
        let oversized = Data(
            repeating: 0x20,
            count: contract.maximumHeaderJSONByteCount + 1
        )
        XCTAssertThrowsError(
            try StreamHeader.decodeBounded(from: oversized)
        ) {
            XCTAssertEqual(
                $0 as? StreamError,
                .headerByteLimitExceeded(
                    maximum: 4_096,
                    observed: 4_097
                )
            )
        }
    }

    func testRawAndOuterSlotsRoundTripOnlyTheirAllowlists()
        throws
    {
        let raw = try Self.rawSlot(
            executionIndex: 0,
            prompt: "derive alpha"
        )
        let outer = try OuterSlot(
            executionIndex: raw.executionIndex,
            correlationID: raw.correlationID
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let rawData = try encoder.encode(raw)
        let outerData = try encoder.encode(outer)
        XCTAssertEqual(
            try Self.keys(in: rawData),
            Set([
                "execution_index",
                "prompt_token_ids",
                "canonical_prompt",
                "primecpi2_prompt_binding_sha256",
                "correlation_id",
            ])
        )
        XCTAssertEqual(
            try Self.keys(in: outerData),
            Set([
                "execution_index",
                "correlation_id",
            ])
        )
        XCTAssertEqual(
            try RawSlot.decodeBounded(from: rawData),
            raw
        )
        XCTAssertEqual(
            try OuterSlot.decodeBounded(from: outerData),
            outer
        )
        XCTAssertFalse(raw.processDeliveryObserved)
        XCTAssertFalse(
            raw.promptContentTargetIndependenceEstablished
        )
        XCTAssertFalse(outer.processDeliveryObserved)
        XCTAssertFalse(outer.evaluationPerformed)

        var noncanonicalRaw = rawData
        noncanonicalRaw.append(0x0A)
        assertThrows(.noncanonicalSlotEncoding) {
            _ = try RawSlot.decodeBounded(
                from: noncanonicalRaw
            )
        }
        var noncanonicalOuter = outerData
        noncanonicalOuter.append(0x20)
        assertThrows(.noncanonicalSlotEncoding) {
            _ = try OuterSlot.decodeBounded(
                from: noncanonicalOuter
            )
        }
        var duplicateRawKey = Data(
            "{\"execution_index\":0,".utf8
        )
        duplicateRawKey.append(rawData.dropFirst())
        XCTAssertThrowsError(
            try RawSlot.decodeBounded(
                from: duplicateRawKey
            )
        )
    }

    func testSemanticFieldInjectionIsRejectedBeforeSlotDecoding()
        throws
    {
        let raw = try Self.rawSlot(
            executionIndex: 0,
            prompt: "derive beta"
        )
        let outer = try OuterSlot(
            executionIndex: raw.executionIndex,
            correlationID: raw.correlationID
        )
        let encoder = JSONEncoder()
        let rawData = try encoder.encode(raw)
        let outerData = try encoder.encode(outer)

        for key in [
            "target",
            "row_id",
            "split",
            "semantic_family",
            "regrade_material",
            "decision_budget",
            "termination",
        ] {
            let injectedRaw = try Self.inject(
                key: key,
                into: rawData
            )
            assertThrows(.unexpectedCodingKeys([key])) {
                _ = try RawSlot.decodeBounded(
                    from: injectedRaw
                )
            }

            let injectedOuter = try Self.inject(
                key: key,
                into: outerData
            )
            assertThrows(.unexpectedCodingKeys([key])) {
                _ = try OuterSlot.decodeBounded(
                    from: injectedOuter
                )
            }
        }

        let oversized = Data(
            repeating: 0x20,
            count:
                Contract.frozenV1
                .maximumRawSlotJSONByteCount + 1
        )
        assertThrows(
            .encodedSlotByteLimitExceeded(
                maximum:
                    Contract.frozenV1
                    .maximumRawSlotJSONByteCount,
                observed: oversized.count
            )
        ) {
            _ = try RawSlot.decodeBounded(from: oversized)
        }
    }

    func testRawSlotRederivesPromptBindingAndCorrelation()
        throws
    {
        let valid = try Self.rawSlot(
            executionIndex: 7,
            prompt: "derive gamma"
        )
        var wrongTokens = valid.promptTokenIDs
        wrongTokens[wrongTokens.count - 1] += 1
        assertThrows(.promptTokenMismatch) {
            _ = try RawSlot(
                executionIndex: valid.executionIndex,
                promptTokenIDs: wrongTokens,
                canonicalPrompt: valid.canonicalPrompt,
                primeCPI2PromptBindingSHA256:
                    valid.primeCPI2PromptBindingSHA256,
                correlationID: valid.correlationID
            )
        }
        assertThrows(.promptBindingMismatch) {
            _ = try RawSlot(
                executionIndex: valid.executionIndex,
                promptTokenIDs: valid.promptTokenIDs,
                canonicalPrompt: valid.canonicalPrompt,
                primeCPI2PromptBindingSHA256:
                    Self.digest("a"),
                correlationID: valid.correlationID
            )
        }
        assertThrows(.correlationMismatch) {
            _ = try RawSlot(
                executionIndex: valid.executionIndex,
                promptTokenIDs: valid.promptTokenIDs,
                canonicalPrompt: valid.canonicalPrompt,
                primeCPI2PromptBindingSHA256:
                    valid.primeCPI2PromptBindingSHA256,
                correlationID: Self.digest("b")
            )
        }

        let decomposed = "e\u{301}"
        let normalizedInput = try
            PrimeNativeNeuralGatePromptOnlyExecutionInput
            .derive(promptText: decomposed)
        let normalizedTokens = try normalizedInput
            .promptTokenIDs.map {
                try XCTUnwrap(UInt16(exactly: $0))
            }
        let correlation = try
            PrimeNativeNeuralGateReplayCorrelationIdentity
            .derive(
                executionIndex: 0,
                primeCPI2PromptBindingSHA256:
                    normalizedInput.bindingSHA256
            )
        assertThrows(.invalidCanonicalPrompt) {
            _ = try RawSlot(
                executionIndex: 0,
                promptTokenIDs: normalizedTokens,
                canonicalPrompt: decomposed,
                primeCPI2PromptBindingSHA256:
                    normalizedInput.bindingSHA256,
                correlationID: correlation
            )
        }
    }

    func testCandidatesRejectOrderDuplicatesAndExcessCardinality()
        throws
    {
        let first = try Self.rawSlot(
            executionIndex: 0,
            prompt: "candidate zero"
        )
        let second = try Self.rawSlot(
            executionIndex: 1,
            prompt: "candidate one"
        )
        let source = Self.digest("c")
        let schedule = Self.digest("d")

        let valid = try RawCandidate(
            invocationRole: .probe,
            promptSourceBindingSHA256: source,
            scheduleIdentitySHA256: schedule,
            orderedSlots: [first, second]
        )
        XCTAssertEqual(
            try Self.keys(in: JSONEncoder().encode(valid)),
            Set([
                "candidate_identity_sha256",
                "invocation_role",
                "ordered_slots",
                "ordered_slots_sha256",
                "prompt_source_binding_sha256",
                "schedule_identity_sha256",
            ])
        )
        let sourceSubstitution = try RawCandidate(
            invocationRole: .probe,
            promptSourceBindingSHA256: Self.digest("e"),
            scheduleIdentitySHA256: schedule,
            orderedSlots: [first, second]
        )
        XCTAssertEqual(
            valid.orderedSlotsSHA256,
            sourceSubstitution.orderedSlotsSHA256
        )
        XCTAssertNotEqual(
            valid.candidateIdentitySHA256,
            sourceSubstitution.candidateIdentitySHA256
        )
        assertThrows(.emptySchedule) {
            _ = try RawCandidate(
                invocationRole: .probe,
                promptSourceBindingSHA256: source,
                scheduleIdentitySHA256: schedule,
                orderedSlots: []
            )
        }
        assertThrows(.duplicateExecutionIndex(0)) {
            _ = try RawCandidate(
                invocationRole: .probe,
                promptSourceBindingSHA256: source,
                scheduleIdentitySHA256: schedule,
                orderedSlots: [first, first]
            )
        }
        assertThrows(
            .noncanonicalExecutionOrder(
                position: 0,
                expected: 0,
                observed: 1
            )
        ) {
            _ = try RawCandidate(
                invocationRole: .probe,
                promptSourceBindingSHA256: source,
                scheduleIdentitySHA256: schedule,
                orderedSlots: [second, first]
            )
        }
        assertThrows(
            .candidateCardinalityExceeded(
                maximum: 18_432,
                observed: 18_433
            )
        ) {
            _ = try RawCandidate(
                invocationRole: .probe,
                promptSourceBindingSHA256: source,
                scheduleIdentitySHA256: schedule,
                orderedSlots: Array(
                    repeating: first,
                    count: 18_433
                )
            )
        }

        let outerFirst = try OuterSlot(
            executionIndex: first.executionIndex,
            correlationID: first.correlationID
        )
        let outerSecond = try OuterSlot(
            executionIndex: second.executionIndex,
            correlationID: second.correlationID
        )
        assertThrows(.duplicateExecutionIndex(0)) {
            _ = try OuterCandidate(
                invocationRole: .probe,
                promptSourceBindingSHA256: source,
                scheduleIdentitySHA256: schedule,
                orderedSlots: [outerFirst, outerFirst]
            )
        }
        assertThrows(
            .noncanonicalExecutionOrder(
                position: 0,
                expected: 0,
                observed: 1
            )
        ) {
            _ = try OuterCandidate(
                invocationRole: .probe,
                promptSourceBindingSHA256: source,
                scheduleIdentitySHA256: schedule,
                orderedSlots: [outerSecond, outerFirst]
            )
        }
    }

    func testPairRejectsRoleAndSourceScheduleIdentitySubstitution()
        throws
    {
        let rawSlot = try Self.rawSlot(
            executionIndex: 0,
            prompt: "pair candidate"
        )
        let outerSlot = try OuterSlot(
            executionIndex: 0,
            correlationID: rawSlot.correlationID
        )
        let source = Self.digest("e")
        let schedule = Self.digest("f")
        let raw = try RawCandidate(
            invocationRole: .probe,
            promptSourceBindingSHA256: source,
            scheduleIdentitySHA256: schedule,
            orderedSlots: [rawSlot]
        )

        let wrongRole = try OuterCandidate(
            invocationRole: .verifier,
            promptSourceBindingSHA256: source,
            scheduleIdentitySHA256: schedule,
            orderedSlots: [outerSlot]
        )
        assertThrows(.invocationRoleMismatch) {
            _ = try Pair(
                rawSchedule: raw,
                outerSchedule: wrongRole
            )
        }

        let wrongSource = try OuterCandidate(
            invocationRole: .probe,
            promptSourceBindingSHA256:
                Self.digest("0"),
            scheduleIdentitySHA256: schedule,
            orderedSlots: [outerSlot]
        )
        assertThrows(.pairedPromptSourceBindingMismatch) {
            _ = try Pair(
                rawSchedule: raw,
                outerSchedule: wrongSource
            )
        }

        let wrongSchedule = try OuterCandidate(
            invocationRole: .probe,
            promptSourceBindingSHA256: source,
            scheduleIdentitySHA256:
                Self.digest("1"),
            orderedSlots: [outerSlot]
        )
        assertThrows(.pairedScheduleIdentityMismatch) {
            _ = try Pair(
                rawSchedule: raw,
                outerSchedule: wrongSchedule
            )
        }

        let matching = try OuterCandidate(
            invocationRole: .probe,
            promptSourceBindingSHA256: source,
            scheduleIdentitySHA256: schedule,
            orderedSlots: [outerSlot]
        )
        assertThrows(
            .exactCardinalityRequired(
                expected: 18_432,
                rawObserved: 1,
                outerObserved: 1
            )
        ) {
            _ = try Pair(
                rawSchedule: raw,
                outerSchedule: matching
            )
        }
    }

    func testExactPairValidatesAllRowsAndRejectsCorrelationSubstitution()
        throws
    {
        let exact = Contract.frozenV1.exactScheduleRowCount
        var rawSlots = [RawSlot]()
        var outerSlots = [OuterSlot]()
        rawSlots.reserveCapacity(exact)
        outerSlots.reserveCapacity(exact)
        for ordinal in 0 ..< exact {
            let raw = try Self.rawSlot(
                executionIndex: UInt32(ordinal),
                prompt: "exact prompt \(ordinal)"
            )
            rawSlots.append(raw)
            outerSlots.append(
                try OuterSlot(
                    executionIndex: raw.executionIndex,
                    correlationID: raw.correlationID
                )
            )
        }
        let source = Self.digest("2")
        let schedule = Self.digest("3")
        let raw = try RawCandidate(
            invocationRole: .verifier,
            promptSourceBindingSHA256: source,
            scheduleIdentitySHA256: schedule,
            orderedSlots: rawSlots
        )
        let outer = try OuterCandidate(
            invocationRole: .verifier,
            promptSourceBindingSHA256: source,
            scheduleIdentitySHA256: schedule,
            orderedSlots: outerSlots
        )
        let pair = try Pair(
            rawSchedule: raw,
            outerSchedule: outer
        )
        XCTAssertEqual(
            raw.orderedSlotsSHA256,
            "c1b7f30e70492343be15b75bfad31bb99cc1bb3112b3059c6d453e9287d7d423"
        )
        XCTAssertEqual(
            raw.candidateIdentitySHA256,
            "5016b1ce11be8eb4e88b38b1b2664d24b46b8efd4dca5570a35f6ade5a78ebfa"
        )
        XCTAssertEqual(
            outer.orderedSlotsSHA256,
            "91612f6be7cce4c6566063c9087f25ebd532f25c2f5fbf3df68fa8fdab6a619d"
        )
        XCTAssertEqual(
            outer.candidateIdentitySHA256,
            "75e01ac9937c14c4dd0a6193e58523878fba7079c19cb7898e4e4cb8832bf015"
        )
        XCTAssertEqual(
            pair.deliveryIdentitySHA256,
            "5fe3096fe56d32a4bf818bcdb36dfab5b72367eff982965556738d83c55ec014"
        )
        XCTAssertTrue(
            pair.deliveryIdentitySHA256.utf8.count == 64
        )
        XCTAssertNoThrow(try pair.validate())
        XCTAssertEqual(
            try Self.keys(in: JSONEncoder().encode(pair)),
            Set([
                "delivery_identity_sha256",
                "outer_schedule",
                "raw_schedule",
            ])
        )
        XCTAssertEqual(
            pair.rawSchedule.orderedSlots.count,
            exact
        )
        XCTAssertFalse(pair.processOwnershipEstablished)
        XCTAssertFalse(pair.processDeliveryObserved)
        XCTAssertFalse(pair.workerMaterialized)
        XCTAssertFalse(pair.modelExecutionEstablished)
        XCTAssertFalse(pair.evaluationPerformed)
        XCTAssertFalse(pair.verdictPublicationAuthorized)
        XCTAssertFalse(pair.mechanicsPassAuthorized)
        XCTAssertFalse(pair.terminalReceiptAuthorized)
        XCTAssertFalse(pair.scientificAuthorityAuthorized)
        XCTAssertFalse(pair.productAuthorityAuthorized)

        let streamHeader = try StreamHeader(
            expectedCandidatePair: pair
        )
        let rawStream = try Self.handFramedGlobal(rawSlots)
        let outerStream = try Self.handFramedGlobal(outerSlots)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: rawStream),
            raw.orderedSlotsSHA256
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: outerStream),
            outer.orderedSlotsSHA256
        )

        let mismatchedHeader = try StreamHeader(
            invocationRole: .probe,
            promptSourceBindingSHA256:
                streamHeader.promptSourceBindingSHA256,
            scheduleIdentitySHA256:
                streamHeader.scheduleIdentitySHA256,
            rawOrderedSlotsSHA256:
                streamHeader.rawOrderedSlotsSHA256,
            outerOrderedSlotsSHA256:
                streamHeader.outerOrderedSlotsSHA256
        )
        XCTAssertThrowsError(
            try StreamDecoder(
                headerJSON: mismatchedHeader.canonicalJSON(),
                expectedHeader: streamHeader
            )
        ) {
            XCTAssertEqual(
                $0 as? StreamError,
                .expectedCandidatePairMismatch
            )
        }

        let streamDecoder = try StreamDecoder(
            headerJSON: streamHeader.canonicalJSON(),
            expectedHeader: streamHeader
        )
        try Self.feed(rawStream) {
            try streamDecoder.consumeRaw($0)
        }
        try streamDecoder.finishRawAtEOF()
        try Self.feed(outerStream) {
            try streamDecoder.consumeOuter($0)
        }
        let admission = try streamDecoder.finishAtEOF()
        XCTAssertEqual(
            admission.deliveryIdentitySHA256,
            pair.deliveryIdentitySHA256
        )
        XCTAssertEqual(admission.orderedSlotCount, exact)
        XCTAssertEqual(
            admission.rawFramedStreamByteCount,
            UInt64(rawStream.count)
        )
        XCTAssertEqual(
            admission.outerFramedStreamByteCount,
            UInt64(outerStream.count)
        )
        XCTAssertFalse(admission.sourceBindingEstablished)
        XCTAssertFalse(admission.durableArtifactOriginEstablished)
        XCTAssertFalse(
            admission.promptContentTargetIndependenceEstablished
        )
        XCTAssertFalse(admission.processOwnershipEstablished)
        XCTAssertFalse(admission.processDeliveryObserved)
        XCTAssertFalse(admission.workerMaterialized)
        XCTAssertFalse(admission.modelExecutionEstablished)
        XCTAssertFalse(admission.evaluationPerformed)
        XCTAssertFalse(admission.verdictPublicationAuthorized)
        XCTAssertFalse(admission.publicationAuthorized)
        XCTAssertFalse(admission.mechanicsPassAuthorized)
        XCTAssertFalse(admission.terminalReceiptAuthorized)
        XCTAssertFalse(admission.scientificAuthorityAuthorized)
        XCTAssertFalse(admission.productAuthorityAuthorized)

        var wrongDeclaredCount = Data("PRIMEIRM1".utf8)
        Self.append(UInt64(18_431), to: &wrongDeclaredCount)
        let wrongCountDecoder = try StreamDecoder(
            headerJSON: streamHeader.canonicalJSON(),
            expectedHeader: streamHeader
        )
        XCTAssertThrowsError(
            try wrongCountDecoder.consumeRaw(wrongDeclaredCount)
        ) {
            XCTAssertEqual(
                $0 as? PrimeNativeNeuralGateReplayMechanicsError,
                .declaredRecordCountMismatch(
                    expected: 18_432,
                    observed: 18_431
                )
            )
        }

        let oversizedFeedDecoder = try StreamDecoder(
            headerJSON: streamHeader.canonicalJSON(),
            expectedHeader: streamHeader
        )
        XCTAssertThrowsError(
            try oversizedFeedDecoder.consumeRaw(
                Data(repeating: 0, count: 65_537)
            )
        ) {
            XCTAssertEqual(
                $0 as? StreamError,
                .feedByteLimitExceeded(
                    maximum: 65_536,
                    observed: 65_537
                )
            )
        }

        let trailingDecoder = try StreamDecoder(
            headerJSON: streamHeader.canonicalJSON(),
            expectedHeader: streamHeader
        )
        try Self.feed(rawStream) {
            try trailingDecoder.consumeRaw($0)
        }
        XCTAssertThrowsError(
            try trailingDecoder.consumeRaw(Data([0]))
        ) {
            XCTAssertEqual(
                $0 as? PrimeNativeNeuralGateReplayMechanicsError,
                .trailingInput
            )
        }

        var substitutedOuterSlots = outerSlots
        substitutedOuterSlots[exact - 1] = try OuterSlot(
            executionIndex: UInt32(exact - 1),
            correlationID: Self.digest("4")
        )
        let substitutedOuter = try OuterCandidate(
            invocationRole: .verifier,
            promptSourceBindingSHA256: source,
            scheduleIdentitySHA256: schedule,
            orderedSlots: substitutedOuterSlots
        )
        let substitutedOuterStream = try Self.handFramedGlobal(
            substitutedOuterSlots
        )
        let correlationMutationDecoder = try StreamDecoder(
            headerJSON: streamHeader.canonicalJSON(),
            expectedHeader: streamHeader
        )
        try Self.feed(rawStream) {
            try correlationMutationDecoder.consumeRaw($0)
        }
        try correlationMutationDecoder.finishRawAtEOF()
        XCTAssertThrowsError(
            try Self.feed(substitutedOuterStream) {
                try correlationMutationDecoder.consumeOuter($0)
            }
        ) {
            XCTAssertEqual(
                $0 as? Error,
                .pairedScheduleCorrelationMismatch(
                    executionIndex: UInt32(exact - 1)
                )
            )
        }
        XCTAssertNotEqual(
            substitutedOuter.orderedSlotsSHA256,
            outer.orderedSlotsSHA256
        )
        XCTAssertNotEqual(
            substitutedOuter.candidateIdentitySHA256,
            outer.candidateIdentitySHA256
        )
        assertThrows(
            .pairedScheduleCorrelationMismatch(
                executionIndex: UInt32(exact - 1)
            )
        ) {
            _ = try Pair(
                rawSchedule: raw,
                outerSchedule: substitutedOuter
            )
        }

        var substitutedRawSlots = rawSlots
        let substitutedRawSlot = try Self.rawSlot(
            executionIndex: UInt32(exact - 1),
            prompt: "exact prompt (exact - 1) changed"
        )
        substitutedRawSlots[exact - 1] = substitutedRawSlot
        var matchingOuterSlots = outerSlots
        matchingOuterSlots[exact - 1] = try OuterSlot(
            executionIndex: UInt32(exact - 1),
            correlationID: substitutedRawSlot.correlationID
        )
        let substitutedRaw = try RawCandidate(
            invocationRole: .verifier,
            promptSourceBindingSHA256: source,
            scheduleIdentitySHA256: schedule,
            orderedSlots: substitutedRawSlots
        )
        let matchingOuter = try OuterCandidate(
            invocationRole: .verifier,
            promptSourceBindingSHA256: source,
            scheduleIdentitySHA256: schedule,
            orderedSlots: matchingOuterSlots
        )
        let substitutedPair = try Pair(
            rawSchedule: substitutedRaw,
            outerSchedule: matchingOuter
        )
        XCTAssertNotEqual(
            substitutedRaw.orderedSlotsSHA256,
            raw.orderedSlotsSHA256
        )
        XCTAssertNotEqual(
            substitutedRaw.candidateIdentitySHA256,
            raw.candidateIdentitySHA256
        )
        XCTAssertNotEqual(
            matchingOuter.orderedSlotsSHA256,
            outer.orderedSlotsSHA256
        )
        XCTAssertNotEqual(
            substitutedPair.deliveryIdentitySHA256,
            pair.deliveryIdentitySHA256
        )
    }

    private static func rawSlot(
        executionIndex: UInt32,
        prompt: String
    ) throws -> RawSlot {
        let input = try
            PrimeNativeNeuralGatePromptOnlyExecutionInput
            .derive(promptText: prompt)
        let tokenIDs = try input.promptTokenIDs.map {
            try XCTUnwrap(UInt16(exactly: $0))
        }
        let correlationID = try
            PrimeNativeNeuralGateReplayCorrelationIdentity
            .derive(
                executionIndex: executionIndex,
                primeCPI2PromptBindingSHA256:
                    input.bindingSHA256
            )
        return try RawSlot(
            executionIndex: executionIndex,
            promptTokenIDs: tokenIDs,
            canonicalPrompt: prompt,
            primeCPI2PromptBindingSHA256:
                input.bindingSHA256,
            correlationID: correlationID
        )
    }

    private static func handFramedGlobal<Slot: Encodable>(
        _ slots: [Slot]
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        var stream = Data("PRIMEIRM1".utf8)
        append(UInt64(slots.count), to: &stream)
        for slot in slots {
            let record = try encoder.encode(slot)
            append(UInt64(record.count), to: &stream)
            stream.append(record)
        }
        return stream
    }

    private static func feed(
        _ data: Data,
        blockByteCount: Int = 64 * 1_024,
        consume: (Data) throws -> Void
    ) throws {
        var offset = 0
        while offset < data.count {
            let end = min(data.count, offset + blockByteCount)
            try consume(Data(data[offset ..< end]))
            offset = end
        }
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

    private static func keys(in data: Data) throws
        -> Set<String>
    {
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )
        return Set(object.keys)
    }

    private static func inject(
        key: String,
        into data: Data
    ) throws -> Data {
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )
        object[key] = "forbidden"
        return try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys]
        )
    }

    private static func digest(_ character: Character)
        -> String
    {
        String(repeating: character, count: 64)
    }

    private func assertThrows(
        _ expected: Error,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ body: () throws -> Void
    ) {
        XCTAssertThrowsError(
            try body(),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as? Error,
                expected,
                file: file,
                line: line
            )
        }
    }
}
