import Foundation
import XCTest
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateRoleArtifactReferenceContracts
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
@testable import PrimeNativeNeuralGateRoleArtifactReferenceAuthority

final class PrimeNativeNeuralGateRoleArtifactReferenceAuthorityTests:
    XCTestCase
{
    typealias Authority =
        PrimeNativeNeuralGateRoleArtifactReferenceAuthority
    typealias Contract =
        PrimeNativeNeuralGateRoleArtifactReferenceAuthorityContract

    func testFrozenAuthorityIsSupervisorOnlyAndNonauthorizing()
        throws
    {
        let contract = Contract.frozenV1
        try contract.validate()
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_retained_delivery_role_artifact_reference_authority_v1"
        )
        XCTAssertTrue(
            contract.retainedPreProjectionRecaptureRequired
        )
        XCTAssertTrue(
            contract.retainedPostProjectionRecaptureRequired
        )
        XCTAssertTrue(
            contract.commonCaptureScheduleReferenceDerived
        )
        XCTAssertTrue(
            contract.branchCandidateIdentityReferenceDerived
        )
        XCTAssertTrue(
            contract
                .boundedUntrustedScalarHeaderPreflightBeforeRetainedBinding
        )
        XCTAssertTrue(
            contract
                .trustedExpectedHeaderBoundBeforeFramedRecordCallbacks
        )
        XCTAssertTrue(contract.captureBoundStreamDecoderImplemented)
        XCTAssertTrue(
            contract.exactStreamAdmissionReconciliationRequired
        )
        XCTAssertTrue(
            contract.retainedPostAdmissionRecaptureRequired
        )
        XCTAssertTrue(
            contract.captureBoundStreamAdmissionImplemented
        )
        XCTAssertFalse(
            contract.realizedRoleArtifactContentReferenceProduced
        )
        XCTAssertFalse(contract.sourcePinningObserved)
        XCTAssertFalse(contract.processDeliveryObserved)
        XCTAssertFalse(contract.workerMaterialized)
        XCTAssertFalse(contract.executionObserved)
        XCTAssertFalse(contract.evaluationPerformed)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.terminalReceiptAuthorized)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertFalse(contract.scientificAuthorityAuthorized)
        XCTAssertFalse(contract.productAuthorityAuthorized)

        let object = try XCTUnwrap(
            try JSONSerialization.jsonObject(
                with: JSONEncoder().encode(contract)
            ) as? [String: Any]
        )
        XCTAssertEqual(
            object["retained_pre_projection_recapture_required"]
                as? Bool,
            true
        )
        XCTAssertEqual(
            object["source_pinning_observed"] as? Bool,
            false
        )
        XCTAssertEqual(
            object["terminal_receipt_authorized"] as? Bool,
            false
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateCaptureBoundScheduleStreamAdmission
                .self is any Encodable.Type
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateCaptureBoundScheduleStreamAdmission
                .self is any Decodable.Type
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle
                .self is any Encodable.Type
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle
                .self is any Decodable.Type
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateCaptureBoundScheduleStreamDecoder
                .self is any Encodable.Type
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateCaptureBoundScheduleStreamDecoder
                .self is any Decodable.Type
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        XCTAssertEqual(
            PrimeNativeNeuralGateInvariantCodec.sha256(
                try encoder.encode(contract)
            ),
            "ca0d27932e76d1b8b75cac65d9ff32413762bc377ed408ad16b065941facc830"
        )
    }

    func testPreparedReferenceProjectionAcceptsOnlyOneExactBinding()
        throws
    {
        let common = try makeCommon()
        let branch = try makeBranch(common: common)
        try validate(
            common: common,
            branch: branch
        )

        XCTAssertThrowsError(
            try validate(
                common: common,
                branch: branch,
                expectedBranch: .verifier
            )
        )
        XCTAssertThrowsError(
            try validate(
                common: common,
                branch: branch,
                expectedInvocationRole: .verifier
            )
        )
        XCTAssertThrowsError(
            try validate(
                common: common,
                branch: branch,
                expectedCapture: digest("0")
            )
        )
        XCTAssertThrowsError(
            try validate(
                common: common,
                branch: branch,
                expectedPrompt: digest("0")
            )
        )
        XCTAssertThrowsError(
            try validate(
                common: common,
                branch: branch,
                expectedSchedule: digest("0")
            )
        )
        XCTAssertThrowsError(
            try validate(
                common: common,
                branch: branch,
                expectedRaw: digest("0")
            )
        )
        XCTAssertThrowsError(
            try validate(
                common: common,
                branch: branch,
                expectedOuter: digest("0")
            )
        )
        XCTAssertThrowsError(
            try validate(
                common: common,
                branch: branch,
                expectedDelivery: digest("0")
            )
        )
    }

    func testPreparedReferenceProjectionRejectsSplitCommonAndCandidateEpochs()
        throws
    {
        let common = try makeCommon()
        let branch = try makeBranch(common: common)
        let otherCommon = try PrimeNativeNeuralGateCommonCaptureScheduleReference(
            captureIdentitySHA256: digest("9"),
            sourceRootIdentity: rootIdentity(),
            promptSourceBindingSHA256: digest("b"),
            scheduleIdentitySHA256: digest("c")
        )
        XCTAssertThrowsError(
            try validate(
                common: otherCommon,
                branch: branch,
                expectedCapture: digest("9")
            )
        )

        let otherBranch = try PrimeNativeNeuralGateBranchScheduleReference(
            branch: .probe,
            invocationRole: .probe,
            commonReferenceIdentitySHA256:
                common.referenceIdentitySHA256,
            rawCandidateIdentitySHA256: digest("7"),
            outerCandidateIdentitySHA256: digest("e"),
            deliveryIdentitySHA256: digest("f")
        )
        XCTAssertThrowsError(
            try validate(
                common: common,
                branch: otherBranch
            )
        )
    }

    func testTrustedHeaderAndFullStreamAdmissionJoinExactSchedule()
        throws
    {
        typealias RawSlot =
            PrimeNativeNeuralGateTargetFreeRawScheduleSlot
        typealias OuterSlot =
            PrimeNativeNeuralGateTargetFreeOuterScheduleSlot
        let contract =
            PrimeNativeNeuralGateTargetFreeScheduleStreamContract
            .frozenV2
        let exact = contract.exactScheduleRowCount
        var rawSlots = [RawSlot]()
        var outerSlots = [OuterSlot]()
        rawSlots.reserveCapacity(exact)
        outerSlots.reserveCapacity(exact)
        for ordinal in 0 ..< exact {
            let input = try
                PrimeNativeNeuralGatePromptOnlyExecutionInput
                .derive(
                    promptText: "authority stream prompt \(ordinal)"
                )
            let tokenIDs = try input.promptTokenIDs.map {
                try XCTUnwrap(UInt16(exactly: $0))
            }
            let correlationID = try
                PrimeNativeNeuralGateReplayCorrelationIdentity
                .derive(
                    executionIndex: UInt32(ordinal),
                    primeCPI2PromptBindingSHA256:
                        input.bindingSHA256
                )
            let raw = try RawSlot(
                executionIndex: UInt32(ordinal),
                promptTokenIDs: tokenIDs,
                canonicalPrompt:
                    "authority stream prompt \(ordinal)",
                primeCPI2PromptBindingSHA256:
                    input.bindingSHA256,
                correlationID: correlationID
            )
            rawSlots.append(raw)
            outerSlots.append(
                try OuterSlot(
                    executionIndex: raw.executionIndex,
                    correlationID: raw.correlationID
                )
            )
        }
        let promptSource = digest("2")
        let schedule = digest("3")
        let rawCandidate = try
            PrimeNativeNeuralGateTargetFreeRawScheduleCandidate(
                invocationRole: .probe,
                promptSourceBindingSHA256: promptSource,
                scheduleIdentitySHA256: schedule,
                orderedSlots: rawSlots
            )
        let outerCandidate = try
            PrimeNativeNeuralGateTargetFreeOuterScheduleCandidate(
                invocationRole: .probe,
                promptSourceBindingSHA256: promptSource,
                scheduleIdentitySHA256: schedule,
                orderedSlots: outerSlots
            )
        let pair = try
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePair(
                rawSchedule: rawCandidate,
                outerSchedule: outerCandidate
            )
        let common = try
            PrimeNativeNeuralGateCommonCaptureScheduleReference(
                captureIdentitySHA256: digest("a"),
                sourceRootIdentity: rootIdentity(),
                promptSourceBindingSHA256: promptSource,
                scheduleIdentitySHA256: schedule
            )
        let branch = try
            PrimeNativeNeuralGateBranchScheduleReference(
                branch: .probe,
                invocationRole: .probe,
                commonReferenceIdentitySHA256:
                    common.referenceIdentitySHA256,
                rawCandidateIdentitySHA256:
                    rawCandidate.candidateIdentitySHA256,
                outerCandidateIdentitySHA256:
                    outerCandidate.candidateIdentitySHA256,
                deliveryIdentitySHA256:
                    pair.deliveryIdentitySHA256
            )
        let header = try
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader(
                expectedCandidatePair: pair
            )
        try Authority.validateExpectedStreamHeader(
            header,
            candidatePair: pair,
            commonReference: common,
            branchReference: branch
        )
        let mismatchedHeader = try
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader(
                invocationRole: .verifier,
                promptSourceBindingSHA256: promptSource,
                scheduleIdentitySHA256: schedule,
                rawOrderedSlotsSHA256:
                    rawCandidate.orderedSlotsSHA256,
                outerOrderedSlotsSHA256:
                    outerCandidate.orderedSlotsSHA256
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateTargetFreeScheduleCandidatePairStreamDecoder(
                headerJSON: mismatchedHeader.canonicalJSON(),
                expectedHeader: header
            )
        )
        XCTAssertEqual(
            try Authority.decodeUntrustedHeaderBeforeRetainedBinding(
                header.canonicalJSON()
            ),
            header
        )
        XCTAssertThrowsError(
            try Authority.decodeUntrustedHeaderBeforeRetainedBinding(
                Data(
                    repeating: 0x20,
                    count:
                        contract.maximumHeaderJSONByteCount + 1
                )
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateRoleArtifactReferenceAuthorityError,
                .captureBoundStreamProjectionRejected
            )
        }
        XCTAssertThrowsError(
            try Authority.decodeUntrustedHeaderBeforeRetainedBinding(
                Data("{}".utf8)
            )
        )
        let phaseDecoder = try
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePairStreamDecoder(
                headerJSON: header.canonicalJSON(),
                expectedHeader: header
            )
        XCTAssertThrowsError(
            try phaseDecoder.consumeOuter(Data())
        )
        let decoder = try
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePairStreamDecoder(
                headerJSON: header.canonicalJSON(),
                expectedHeader: header
            )
        try feed(try handFramedGlobal(rawSlots)) {
            try decoder.consumeRaw($0)
        }
        try decoder.finishRawAtEOF()
        try feed(try handFramedGlobal(outerSlots)) {
            try decoder.consumeOuter($0)
        }
        let admission = try decoder.finishAtEOF()
        try Authority.validateCaptureBoundStreamAdmission(
            admission,
            expectedHeader: header,
            candidatePair: pair,
            commonReference: common,
            branchReference: branch
        )
        XCTAssertEqual(admission.orderedSlotCount, exact)
        XCTAssertEqual(
            admission.rawCandidateIdentitySHA256,
            branch.rawCandidateIdentitySHA256
        )
        XCTAssertEqual(
            admission.deliveryIdentitySHA256,
            branch.deliveryIdentitySHA256
        )
        XCTAssertFalse(admission.processDeliveryObserved)
        XCTAssertFalse(admission.modelExecutionEstablished)
        XCTAssertFalse(admission.mechanicsPassAuthorized)
        XCTAssertFalse(admission.terminalReceiptAuthorized)

        let splitBranch = try
            PrimeNativeNeuralGateBranchScheduleReference(
                branch: .probe,
                invocationRole: .probe,
                commonReferenceIdentitySHA256:
                    common.referenceIdentitySHA256,
                rawCandidateIdentitySHA256: digest("0"),
                outerCandidateIdentitySHA256:
                    branch.outerCandidateIdentitySHA256,
                deliveryIdentitySHA256:
                    branch.deliveryIdentitySHA256
            )
        XCTAssertThrowsError(
            try Authority.validateCaptureBoundStreamAdmission(
                admission,
                expectedHeader: header,
                candidatePair: pair,
                commonReference: common,
                branchReference: splitBranch
            )
        )
    }

    private func validate(
        common:
            PrimeNativeNeuralGateCommonCaptureScheduleReference,
        branch:
            PrimeNativeNeuralGateBranchScheduleReference,
        expectedBranch:
            PrimeNativeNeuralGateCorrectedProcessBranch = .probe,
        expectedInvocationRole:
            PrimeNativeNeuralGateTargetFreeScheduleInvocationRole = .probe,
        expectedCapture: String? = nil,
        expectedPrompt: String? = nil,
        expectedSchedule: String? = nil,
        expectedRaw: String? = nil,
        expectedOuter: String? = nil,
        expectedDelivery: String? = nil
    ) throws {
        try Authority.validatePreparedReferences(
            commonReference: common,
            branchReference: branch,
            expectedBranch: expectedBranch,
            expectedInvocationRole: expectedInvocationRole,
            expectedCaptureIdentitySHA256:
                expectedCapture ?? digest("a"),
            expectedPromptSourceBindingSHA256:
                expectedPrompt ?? digest("b"),
            expectedScheduleIdentitySHA256:
                expectedSchedule ?? digest("c"),
            expectedRawCandidateIdentitySHA256:
                expectedRaw ?? digest("d"),
            expectedOuterCandidateIdentitySHA256:
                expectedOuter ?? digest("e"),
            expectedDeliveryIdentitySHA256:
                expectedDelivery ?? digest("f")
        )
    }

    private func makeCommon() throws
        -> PrimeNativeNeuralGateCommonCaptureScheduleReference
    {
        try PrimeNativeNeuralGateCommonCaptureScheduleReference(
            captureIdentitySHA256: digest("a"),
            sourceRootIdentity: rootIdentity(),
            promptSourceBindingSHA256: digest("b"),
            scheduleIdentitySHA256: digest("c")
        )
    }

    private func makeBranch(
        common:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws -> PrimeNativeNeuralGateBranchScheduleReference {
        try PrimeNativeNeuralGateBranchScheduleReference(
            branch: .probe,
            invocationRole: .probe,
            commonReferenceIdentitySHA256:
                common.referenceIdentitySHA256,
            rawCandidateIdentitySHA256: digest("d"),
            outerCandidateIdentitySHA256: digest("e"),
            deliveryIdentitySHA256: digest("f")
        )
    }

    private func rootIdentity()
        -> PrimeNativeNeuralGateTargetFreeSourceRootIdentity
    {
        PrimeNativeNeuralGateTargetFreeSourceRootIdentity(
            deviceID: 1,
            inode: 2,
            ownerUserID: 501,
            ownerGroupID: 20,
            actualMode: 0o700,
            linkCount: 2,
            modificationSeconds: 10,
            modificationNanoseconds: 20,
            statusChangeSeconds: 30,
            statusChangeNanoseconds: 40
        )
    }

    private func digest(_ character: Character) -> String {
        String(repeating: String(character), count: 64)
    }

    private func handFramedGlobal<Slot: Encodable>(
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

    private func feed(
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

    private func append(
        _ value: UInt64,
        to data: inout Data
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.append(contentsOf: $0)
        }
    }
}
