import CryptoKit
import Foundation
@testable import DisposalProjectionCore
import XCTest

final class DisposalR19OBS11ProjectionChainTests: XCTestCase {
    func testFrozenRealSourceDerivesEveryPrefixAndNamespaceWithoutWriting() throws {
        let source = try exactFixture()
        XCTAssertEqual(source.count, DisposalR19OBS11FrozenPlan.sourceBytes)
        XCTAssertEqual(disposalSHA256(source), DisposalR19OBS11FrozenPlan.sourceSHA256)

        let decoded = try DisposalProjectionSourceAdapter.decode(source)
        XCTAssertEqual(decoded.frames.count, 8)
        for plan in DisposalR19OBS11FrozenPlan.steps {
            let prefix = Data(source.prefix(plan.bytes))
            XCTAssertEqual(prefix.count, plan.bytes)
            XCTAssertEqual(disposalSHA256(prefix), plan.prefixSHA256)
            XCTAssertEqual(
                decoded.frames[plan.step - 1].rawWithLFSHA256,
                plan.tailFrameLFSHA256)
            XCTAssertEqual(
                DisposalSealedArtifactSet.stagingPath(for: plan.finalRoot),
                plan.stagingRoot)
            XCTAssertEqual(plan.predecessorStep, plan.step == 1 ? nil : plan.step - 1)
            XCTAssertEqual(plan.sourceSealed, plan.step == 8)
            XCTAssertFalse(plan.terminal)
        }
    }

    func testReceiptCodecBindsCanonicalPayloadLeafOrdinalAndImmediatePrevious() throws {
        let start = try DisposalR19OBS11ReceiptCodec.make(
            chainOrdinal: 0,
            leafName: DisposalR19OBS11FrozenPlan.ordinaryLeaves[0],
            previousFrameWithLFSHA256: nil,
            payloadMembers: [
                "receipt_kind": disposalJSONString("START"),
                "authority_vector": disposalJSONString("00000000"),
            ])
        let intent = try DisposalR19OBS11ReceiptCodec.make(
            chainOrdinal: 1,
            leafName: DisposalR19OBS11FrozenPlan.ordinaryLeaves[1],
            previousFrameWithLFSHA256: start.frameWithLFSHA256,
            payloadMembers: [
                "receipt_kind": disposalJSONString("STEP_INTENT"),
                "step": disposalJSONNumber(1),
            ])

        XCTAssertEqual(start.bytesWithLF.last, 0x0a)
        XCTAssertEqual(intent.previousFrameWithLFSHA256, start.frameWithLFSHA256)
        XCTAssertEqual(disposalSHA256(start.payload), start.payloadSHA256)
        XCTAssertEqual(disposalSHA256(start.bytesWithoutLF), start.frameSHA256)
        XCTAssertEqual(disposalSHA256(start.bytesWithLF), start.frameWithLFSHA256)

        var parser = DisposalCanonicalJSONParser(
            data: intent.bytesWithoutLF,
            frameOrdinal: 1,
            journalByteOffset: 0)
        let parsed = try parser.parse()
        XCTAssertEqual(parsed.canonicalData(), intent.bytesWithoutLF)
        guard case .object(let members, _) = parsed else {
            return XCTFail("receipt was not an object")
        }
        XCTAssertEqual(Set(members.map(\.key)), Set([
            "chain_ordinal", "payload", "payload_hash_rule", "payload_sha256",
            "previous_frame_with_lf_sha256", "receipt_leaf_name", "schema",
        ]))

        XCTAssertThrowsError(try DisposalR19OBS11ReceiptCodec.make(
            chainOrdinal: 1,
            leafName: DisposalR19OBS11FrozenPlan.ordinaryLeaves[2],
            previousFrameWithLFSHA256: start.frameWithLFSHA256,
            payloadMembers: [:])) { error in
                XCTAssertEqual(
                    (error as? DisposalProjectionRejection)?.code,
                    "OBS11_RECEIPT_LEAF_ORDINAL_JOIN")
            }
    }

    func testReceiptMerkleUsesOneLengthFramedHashAndRFC6962Split() throws {
        let digests = (1...8).map {
            referenceLengthFramedID("obs11-test-result", [String($0)])
        }
        let expectedLeaves = digests.enumerated().map { index, digest in
            referenceLengthFramedID(
                DisposalR19OBS11ReceiptMerkle.leafDomain,
                [
                    DisposalR19OBS11ReceiptMerkle.chainDomain,
                    String(index + 1),
                    digest,
                ])
        }
        XCTAssertEqual(
            try DisposalR19OBS11ReceiptMerkle.root(
                resultFrameWithLFSHA256: digests),
            referenceMerkleRoot(expectedLeaves))
    }

    func testDurableValidatorRejectsPolicyDriftAndEarlySuccess() throws {
        let start = try DisposalR19OBS11ReceiptCodec.make(
            chainOrdinal: 0,
            leafName: DisposalR19OBS11FrozenPlan.ordinaryLeaves[0],
            previousFrameWithLFSHA256: nil,
            payloadMembers: frozenPayload(.start))
        XCTAssertEqual(
            try DisposalR19OBS11ReceiptCodec.validateExact(
                frameWithLF: start.bytesWithLF,
                chainOrdinal: 0,
                leafName: DisposalR19OBS11FrozenPlan.ordinaryLeaves[0],
                previousFrameWithLFSHA256: nil),
            start.frameWithLFSHA256)

        var driftedPayload = frozenPayload(.start)
        driftedPayload["authority_vector"] = disposalJSONString("10000000")
        let drifted = try DisposalR19OBS11ReceiptCodec.make(
            chainOrdinal: 0,
            leafName: DisposalR19OBS11FrozenPlan.ordinaryLeaves[0],
            previousFrameWithLFSHA256: nil,
            payloadMembers: driftedPayload)
        XCTAssertThrowsError(try DisposalR19OBS11ReceiptCodec.validateExact(
            frameWithLF: drifted.bytesWithLF,
            chainOrdinal: 0,
            leafName: DisposalR19OBS11FrozenPlan.ordinaryLeaves[0],
            previousFrameWithLFSHA256: nil)) { error in
                XCTAssertEqual(
                    (error as? DisposalProjectionRejection)?.code,
                    "OBS11_RECEIPT_PAYLOAD_POLICY")
            }

        let prior = String(repeating: "0", count: 64)
        let earlySuccess = try DisposalR19OBS11ReceiptCodec.make(
            chainOrdinal: 1,
            leafName: DisposalR19OBS11FrozenPlan.terminalLeaf,
            previousFrameWithLFSHA256: prior,
            payloadMembers: frozenPayload(.terminalSuccess))
        XCTAssertThrowsError(try DisposalR19OBS11ReceiptCodec.validateExact(
            frameWithLF: earlySuccess.bytesWithLF,
            chainOrdinal: 1,
            leafName: DisposalR19OBS11FrozenPlan.terminalLeaf,
            previousFrameWithLFSHA256: prior)) { error in
                XCTAssertEqual(
                    (error as? DisposalProjectionRejection)?.code,
                    "OBS11_RECEIPT_PAYLOAD_POLICY")
            }
    }

    func testInputAdmissionRejectsBeforeAnyReceiptOrProjectionMutation() throws {
        let source = try exactFixture()
        for (softLimit, resourceFacts, expectedCode) in [
            (
                DisposalR19OBS11FrozenPlan.minimumOpenFileSoftLimit - 1,
                DisposalR19OBS11FrozenPlan.ruleResources,
                "OBS11_DESCRIPTOR_LIMIT_INSUFFICIENT"),
            (
                DisposalR19OBS11FrozenPlan.minimumOpenFileSoftLimit,
                Array(DisposalR19OBS11FrozenPlan.ruleResources.dropLast()),
                "OBS11_RULE_RESOURCE_FACT_JOIN"),
        ] {
            let projection = FakeProjection()
            let receipts = FakeReceipts()
            let coordinator = DisposalR19OBS11ProjectionChainCoordinator(
                source: .init(
                    journal: source,
                    sqliteBytes: DisposalR19OBS11FrozenPlan.sqliteBytes,
                    sqliteSHA256: DisposalR19OBS11FrozenPlan.sqliteSHA256,
                    descriptorSoftLimit: softLimit,
                    revalidate: {}),
                projection: .init(
                    preflightAllAbsent: {
                        XCTFail("input rejection must precede namespace preflight")
                    },
                    buildAndAdmit: { try projection.build(step: $0, request: $1) },
                    revalidateAll: {},
                    observeRetainedState: {
                        DisposalR19OBS11RetainedNamespaceHold(
                            state: .init(
                                step: $0,
                                finalRootState: "NOT_APPLICABLE",
                                stagingRootState: "NOT_APPLICABLE",
                                originProof: "NOT_APPLICABLE_NO_CURRENT_STEP",
                                snapshotSHA256: nil,
                                snapshotComponents: nil),
                            revalidate: {})
                    }),
                receipts: receipts.port,
                resources: .init(facts: resourceFacts, revalidate: {}))

            XCTAssertThrowsError(try coordinator.run()) { error in
                XCTAssertEqual(
                    (error as? DisposalR19OBS11StableFailure)?.stage,
                    .frozenSource)
                XCTAssertEqual(
                    (error as? DisposalR19OBS11StableFailure)?.code,
                    expectedCode)
            }
            XCTAssertTrue(projection.requests.isEmpty)
            XCTAssertTrue(receipts.names.isEmpty)
            XCTAssertFalse(receipts.published)
        }
    }

    func testPureCoordinatorBuildsExactEightRequestsAndPublishesSuccess() throws {
        let source = try exactFixture()
        let projection = FakeProjection()
        let receipts = FakeReceipts()
        var sourceRevalidations = 0
        var resourceRevalidations = 0
        let coordinator = DisposalR19OBS11ProjectionChainCoordinator(
            source: .init(
                journal: source,
                sqliteBytes: DisposalR19OBS11FrozenPlan.sqliteBytes,
                sqliteSHA256: DisposalR19OBS11FrozenPlan.sqliteSHA256,
                descriptorSoftLimit: DisposalR19OBS11FrozenPlan.minimumOpenFileSoftLimit,
                revalidate: { sourceRevalidations += 1 }),
            projection: .init(
                preflightAllAbsent: {},
                buildAndAdmit: { try projection.build(step: $0, request: $1) },
                revalidateAll: { projection.revalidateAllCount += 1 },
                observeRetainedState: {
                    DisposalR19OBS11RetainedNamespaceHold(
                        state: self.retainedAbsentState(step: $0),
                        revalidate: {})
                }),
            receipts: receipts.port,
            resources: .init(
                facts: DisposalR19OBS11FrozenPlan.ruleResources,
                revalidate: { resourceRevalidations += 1 }))

        try coordinator.run()

        XCTAssertEqual(projection.requests.count, 8)
        for (index, request) in projection.requests.enumerated() {
            let plan = DisposalR19OBS11FrozenPlan.steps[index]
            XCTAssertEqual(request.journal.count, plan.bytes)
            XCTAssertEqual(disposalSHA256(request.journal), plan.prefixSHA256)
            XCTAssertEqual(
                request.journalLogicalPath,
                DisposalR19OBS11FrozenPlan.sourcePath)
            if index == 0 {
                XCTAssertNil(request.predecessor)
            } else {
                XCTAssertEqual(
                    request.predecessor?.rootPath,
                    DisposalR19OBS11FrozenPlan.steps[index - 1].finalRoot)
                XCTAssertEqual(
                    request.predecessor?.expectedSealSHA256,
                    projection.observations[index - 1].sealSHA256)
            }
        }
        XCTAssertEqual(
            receipts.names,
            DisposalR19OBS11FrozenPlan.ordinaryLeaves +
                [DisposalR19OBS11FrozenPlan.terminalLeaf])
        XCTAssertEqual(receipts.publishedExpectedLeaves, receipts.names)
        XCTAssertTrue(receipts.published)
        XCTAssertGreaterThan(sourceRevalidations, 8)
        XCTAssertEqual(sourceRevalidations, resourceRevalidations)
        XCTAssertGreaterThan(projection.revalidateAllCount, 8)
        XCTAssertEqual(
            projection.observations.map(\.machinePrefixJoin),
            ["NOT_APPLICABLE_GENESIS_NO_PREDECESSOR"] +
                Array(repeating: "PASS_EXACT", count: 7))
        XCTAssertTrue(receipts.frames.last.map {
            String(decoding: $0, as: UTF8.self).contains(
                "PASS_EXACT_NONAUTHORITATIVE_1_TO_8_CHAIN")
        } == true)
    }

    func testPureCoordinatorStopsAtFirstFailureAndPublishesOnlyExactPrefix() throws {
        let projection = FakeProjection(failAtStep: 3)
        let receipts = FakeReceipts()
        var retainedNamespaceRevalidations = 0
        let coordinator = DisposalR19OBS11ProjectionChainCoordinator(
            source: .init(
                journal: try exactFixture(),
                sqliteBytes: DisposalR19OBS11FrozenPlan.sqliteBytes,
                sqliteSHA256: DisposalR19OBS11FrozenPlan.sqliteSHA256,
                descriptorSoftLimit: DisposalR19OBS11FrozenPlan.minimumOpenFileSoftLimit,
                revalidate: {}),
            projection: .init(
                preflightAllAbsent: {},
                buildAndAdmit: { try projection.build(step: $0, request: $1) },
                revalidateAll: {},
                observeRetainedState: {
                    DisposalR19OBS11RetainedNamespaceHold(
                        state: self.retainedAbsentState(step: $0),
                        revalidate: { retainedNamespaceRevalidations += 1 })
                }),
            receipts: receipts.port,
            resources: .init(
                facts: DisposalR19OBS11FrozenPlan.ruleResources,
                revalidate: {}))

        XCTAssertThrowsError(try coordinator.run()) { error in
            let expected = DisposalR19OBS11StableFailure(
                stage: .projectionBuild,
                code: "FAKE_BUILD",
                step: 3)
            XCTAssertEqual(error as? DisposalR19OBS11StableFailure, expected)
        }
        XCTAssertEqual(projection.requests.count, 3)
        XCTAssertEqual(
            receipts.names,
            Array(DisposalR19OBS11FrozenPlan.ordinaryLeaves.prefix(6)) +
                [DisposalR19OBS11FrozenPlan.terminalLeaf])
        XCTAssertEqual(receipts.publishedExpectedLeaves, receipts.names)
        XCTAssertEqual(retainedNamespaceRevalidations, 1)
        XCTAssertTrue(receipts.frames.last.map {
            String(decoding: $0, as: UTF8.self).contains(
                "FAIL_CONSUMED_RETAINED_PREFIX")
        } == true)
    }

    func testCoordinatorRejectsFalseGenesisMachinePrefixPass() throws {
        let projection = FakeProjection(
            machinePrefixJoinOverride: (step: 1, value: "PASS_EXACT"))
        let receipts = FakeReceipts()
        let coordinator = DisposalR19OBS11ProjectionChainCoordinator(
            source: .init(
                journal: try exactFixture(),
                sqliteBytes: DisposalR19OBS11FrozenPlan.sqliteBytes,
                sqliteSHA256: DisposalR19OBS11FrozenPlan.sqliteSHA256,
                descriptorSoftLimit: DisposalR19OBS11FrozenPlan.minimumOpenFileSoftLimit,
                revalidate: {}),
            projection: .init(
                preflightAllAbsent: {},
                buildAndAdmit: { try projection.build(step: $0, request: $1) },
                revalidateAll: {},
                observeRetainedState: {
                    DisposalR19OBS11RetainedNamespaceHold(
                        state: self.retainedAbsentState(step: $0),
                        revalidate: {})
                }),
            receipts: receipts.port,
            resources: .init(
                facts: DisposalR19OBS11FrozenPlan.ruleResources,
                revalidate: {}))

        XCTAssertThrowsError(try coordinator.run()) { error in
            XCTAssertEqual(
                error as? DisposalR19OBS11StableFailure,
                .init(
                    stage: .projectionAdmission,
                    code: "OBS11_RESULT_MACHINE_PREFIX_JOIN",
                    step: 1))
        }
        XCTAssertEqual(
            receipts.names,
            Array(DisposalR19OBS11FrozenPlan.ordinaryLeaves.prefix(2)) +
                [DisposalR19OBS11FrozenPlan.terminalLeaf])
    }

    private func exactFixture() throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(
            forResource: "r19-observations.v1",
            withExtension: "jsonl",
            subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }

    private func retainedAbsentState(
        step: Int?
    ) -> DisposalR19OBS11RetainedNamespaceState {
        guard let step,
              DisposalR19OBS11FrozenPlan.steps.indices.contains(step - 1)
        else {
            return .init(
                step: nil,
                finalRootState: "NOT_APPLICABLE",
                stagingRootState: "NOT_APPLICABLE",
                originProof: "NOT_APPLICABLE_NO_CURRENT_STEP",
                snapshotSHA256: nil,
                snapshotComponents: nil)
        }
        let plan = DisposalR19OBS11FrozenPlan.steps[step - 1]
        let origin = "ABSENT_BOTH_NAMES_DESCRIPTOR_REVALIDATED"
        let components = [
            String(step),
            plan.finalRoot,
            plan.stagingRoot,
            origin,
            "FINAL", "ABSENT",
            "STAGING", "ABSENT",
        ]
        return .init(
            step: step,
            finalRootState: "ABSENT",
            stagingRootState: "ABSENT",
            originProof: origin,
            snapshotSHA256: disposalLengthFramedID(
                "ergentics-r19-obs11-retained-namespace-snapshot-v1",
                components),
            snapshotComponents: components)
    }

    private func frozenPayload(
        _ kind: DisposalR19OBS11ReceiptKind
    ) -> [String: DisposalJSONValue] {
        [
            "authoritative": disposalJSONBoolean(false),
            "authority_vector": disposalJSONString("00000000"),
            "c0_blob": disposalJSONString(DisposalR19OBS11FrozenPlan.c0Blob),
            "c0_sha256": disposalJSONString(DisposalR19OBS11FrozenPlan.c0SHA256),
            "chain_id": disposalJSONString(DisposalR19OBS11FrozenPlan.chainID),
            "checkpoint_id": disposalJSONString(DisposalR19OBS11FrozenPlan.checkpointID),
            "gate_e": disposalJSONString("ABSTAIN"),
            "may_feed_controller": disposalJSONBoolean(false),
            "prose_may_supply_fact": disposalJSONBoolean(false),
            "receipt_kind": disposalJSONString(kind.rawValue),
            "scientific_outcome": disposalJSONString("ABSTAIN"),
        ]
    }

    private func referenceLengthFramedID(
        _ domain: String,
        _ components: [String]
    ) -> String {
        var bytes = Data("ERGENTICS_DISPOSAL_LENGTH_FRAMED_ID_V1".utf8)
        appendUInt64BE(UInt64(domain.utf8.count), to: &bytes)
        bytes.append(contentsOf: domain.utf8)
        appendUInt64BE(UInt64(components.count), to: &bytes)
        for component in components {
            appendUInt64BE(UInt64(component.utf8.count), to: &bytes)
            bytes.append(contentsOf: component.utf8)
        }
        return SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }

    private func referenceMerkleRoot(_ hashes: [String]) -> String {
        if hashes.count == 1 { return hashes[0] }
        var split = 1
        while split * 2 < hashes.count { split *= 2 }
        return referenceLengthFramedID(
            DisposalR19OBS11ReceiptMerkle.nodeDomain,
            [
                DisposalR19OBS11ReceiptMerkle.chainDomain,
                referenceMerkleRoot(Array(hashes[..<split])),
                referenceMerkleRoot(Array(hashes[split...])),
            ])
    }

    private func appendUInt64BE(_ value: UInt64, to data: inout Data) {
        var encoded = value.bigEndian
        withUnsafeBytes(of: &encoded) { data.append(contentsOf: $0) }
    }
}

private final class FakeProjection {
    let failAtStep: Int?
    let machinePrefixJoinOverride: (step: Int, value: String)?
    var requests: [DisposalProjectionSetRequest] = []
    var observations: [DisposalR19OBS11StepObservation] = []
    var revalidateAllCount = 0

    init(
        failAtStep: Int? = nil,
        machinePrefixJoinOverride: (step: Int, value: String)? = nil
    ) {
        self.failAtStep = failAtStep
        self.machinePrefixJoinOverride = machinePrefixJoinOverride
    }

    func build(
        step: DisposalR19OBS11PlanStep,
        request: DisposalProjectionSetRequest
    ) throws -> DisposalR19OBS11StepObservation {
        requests.append(request)
        if step.step == failAtStep {
            throw DisposalProjectionRejection(code: "FAKE_BUILD")
        }
        let machinePrefixJoin: String
        if let override = machinePrefixJoinOverride,
           override.step == step.step
        {
            machinePrefixJoin = override.value
        } else {
            machinePrefixJoin = observations.isEmpty
                ? "NOT_APPLICABLE_GENESIS_NO_PREDECESSOR"
                : "PASS_EXACT"
        }
        let observation = DisposalR19OBS11StepObservation(
            outputRootPath: step.finalRoot,
            projectionID: disposalLengthFramedID("obs11-test-projection", [String(step.step)]),
            sealSHA256: disposalLengthFramedID("obs11-test-seal", [String(step.step)]),
            evidenceSHA256: disposalLengthFramedID("obs11-test-evidence", [String(step.step)]),
            metricsSHA256: disposalLengthFramedID("obs11-test-metrics", [String(step.step)]),
            graphSHA256: disposalLengthFramedID("obs11-test-graph", [String(step.step)]),
            evidenceBytes: 100 + step.step,
            metricsBytes: 200 + step.step,
            graphBytes: 300 + step.step,
            sourceSHA256: step.prefixSHA256,
            sourceBytes: step.bytes,
            frameCount: step.frameCount,
            tailFrameLFSHA256: step.tailFrameLFSHA256,
            predecessorProjectionID: observations.last?.projectionID,
            sourceSealed: step.sourceSealed,
            terminal: step.terminal,
            status: step.status,
            authorityVector: "00000000",
            authoritative: false,
            mayFeedController: false,
            machinePrefixJoin: machinePrefixJoin)
        observations.append(observation)
        return observation
    }
}

private final class FakeReceipts {
    var names: [String] = []
    var frames: [Data] = []
    var publishedExpectedLeaves: [String] = []
    var published = false

    var port: DisposalR19OBS11ReceiptPort {
        .init(
            appendExact: { [unowned self] leaf, frame in
                let previous = self.frames.last.map(disposalSHA256)
                let digest = try DisposalR19OBS11ReceiptCodec.validateExact(
                    frameWithLF: frame,
                    chainOrdinal: self.names.count,
                    leafName: leaf,
                    previousFrameWithLFSHA256: previous)
                self.names.append(leaf)
                self.frames.append(frame)
                return digest
            },
            durableLeafNames: { [unowned self] in self.names },
            publish: { [unowned self] expected, revalidate in
                XCTAssertEqual(self.names, expected)
                try revalidate()
                self.publishedExpectedLeaves = expected
                self.published = true
            })
    }
}
