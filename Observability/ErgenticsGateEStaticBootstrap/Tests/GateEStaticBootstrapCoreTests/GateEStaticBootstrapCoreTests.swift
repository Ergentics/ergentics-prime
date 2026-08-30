import Testing
@testable import GateEStaticBootstrapCore

// These are pure synthetic receipt and state-machine tests, with no worker entry
// or runtime admission token. PASS strings below are test fixtures, never receipts
// observed from a process or claims of production authority.
@Suite("Gate E static bootstrap pure boundaries")
struct GateEStaticBootstrapCoreTests {
    @Test("frozen independent candidate streams retain exact bytes and anchors")
    func frozenCandidateAnchors() {
        #expect(StaticPins.jsonBytes.count == 1_405)
        #expect(StaticPins.cborBytes.count == 1_239)
        #expect(bootstrapSHA256(StaticPins.jsonBytes) == frozenJSONHash)
        #expect(bootstrapSHA256(StaticPins.cborBytes) == frozenCBORHash)
        #expect(Codec.json.candidateHash == frozenJSONHash)
        #expect(Codec.cbor.candidateHash == frozenCBORHash)
        #expect(Codec.json.candidateHash != Codec.cbor.candidateHash)
        #expect(StaticPins.semanticRoot == frozenSemanticRoot)

        let length: UInt64 = UInt64(StaticPins.jsonBytes.count)
        let encodedLength = (0..<8).reversed().map {
            UInt8(truncatingIfNeeded: length >> ($0 * 8))
        }
        let preimage = Array("ERGENTICS-GATE-E-STATIC-SEMANTIC-V1".utf8)
            + [0] + encodedLength + StaticPins.jsonBytes
        #expect(bootstrapSHA256(preimage) == frozenSemanticRoot)
    }

    @Test("SHA256 is checked against independently fixed known answers")
    func hashKnownAnswers() {
        #expect(bootstrapSHA256([])
            == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        #expect(bootstrapSHA256(Array("abc".utf8))
            == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
    }

    @Test("each codec binds canonical verifier and independent reconstruction")
    func canonicalProjectorBindings() throws {
        for codec in [Codec.json, Codec.cbor] {
            let fixture = ProjectorFixture(codec: codec)
            #expect(canonical(fixture.verifierFields).count == 442)
            #expect(canonical(fixture.roundTripFields).count == 752)
            let binding = try fixture.bind()
            #expect(binding.frameHash == bootstrapSHA256(fixture.graph))
            #expect(binding.merkleRoot == syntheticMerkle)
            #expect(binding == (try fixture.bind()))
        }
    }

    @Test("projector verifier binds every external anchor and fixed literal")
    func projectorVerifierFieldMutations() {
        for codec in [Codec.json, Codec.cbor] {
            let fixture = ProjectorFixture(codec: codec)
            let mutations: Fields = [
                ("candidate_sha256", wrongHash),
                ("graph_frame_sha256", wrongHash),
                ("graph_merkle_root", wrongHash),
                ("result", "FAIL"),
                ("schema", "ergentics.gate-e.static.verifier-receipt.v2"),
                ("semantic_root", wrongHash),
                ("source_authority", codec == .json ? "CBOR" : "JSON"),
            ]
            for (key, value) in mutations {
                rejects {
                    _ = try fixture.bind(verifier: canonical(
                        replacing(fixture.verifierFields, key: key, value: value)
                    ))
                }
            }
        }
    }

    @Test("roundtrip independently binds original and reconstructed identities")
    func roundTripFieldMutations() {
        for codec in [Codec.json, Codec.cbor] {
            let fixture = ProjectorFixture(codec: codec)
            let mutations: Fields = [
                ("candidate_sha256", wrongHash),
                ("graph_frame_sha256", wrongHash),
                ("graph_merkle_root", wrongHash),
                ("original_semantic_root", wrongHash),
                ("reconstructed_candidate_sha256", wrongHash),
                ("reconstructed_graph_frame_sha256", wrongHash),
                ("reconstructed_semantic_root", wrongHash),
                ("result", "ABSTAIN"),
                ("schema", "ergentics.gate-e.static.round-trip-receipt.v2"),
                ("source_authority", codec == .json ? "CBOR" : "JSON"),
            ]
            for (key, value) in mutations {
                rejects {
                    _ = try fixture.bind(roundTrip: canonical(
                        replacing(fixture.roundTripFields, key: key, value: value)
                    ))
                }
            }
        }
    }

    @Test("receipt canonical grammar rejects whitespace and structural drift")
    func canonicalReceiptGrammar() {
        let fixture = ProjectorFixture(codec: .json)
        for variant in malformedVariants(fixture.verifierFields) {
            rejects { _ = try fixture.bind(verifier: variant) }
        }
        for variant in malformedVariants(fixture.roundTripFields) {
            rejects { _ = try fixture.bind(roundTrip: variant) }
        }
    }

    @Test("receipt digest grammar is exactly lowercase hexadecimal")
    func digestGrammar() {
        let fixture = ProjectorFixture(codec: .json)
        for invalid in [
            String(repeating: "A", count: 64),
            String(repeating: "g", count: 64),
            String(repeating: "a", count: 63),
            String(repeating: "a", count: 65),
            "",
        ] {
            let verifier = canonical(replacing(
                fixture.verifierFields, key: "graph_merkle_root", value: invalid
            ))
            let roundTrip = canonical(replacing(
                fixture.roundTripFields, key: "graph_merkle_root", value: invalid
            ))
            rejects { _ = try fixture.bind(verifier: verifier, roundTrip: roundTrip) }
        }
    }

    @Test("missing receipts and changed graph bytes cannot be rebound")
    func absentOrReboundOutput() {
        let fixture = ProjectorFixture(codec: .json)
        rejects { _ = try fixture.bind(verifier: []) }
        rejects { _ = try fixture.bind(roundTrip: []) }
        var changedGraph = fixture.graph
        changedGraph[0] ^= 1
        rejects {
            _ = try ReceiptBinding.projector(
                codec: .json,
                graph: changedGraph,
                verifier: canonical(fixture.verifierFields),
                roundTrip: canonical(fixture.roundTripFields)
            )
        }
        rejects {
            _ = try ReceiptBinding.projector(
                codec: .cbor,
                graph: fixture.graph,
                verifier: canonical(fixture.verifierFields),
                roundTrip: canonical(fixture.roundTripFields)
            )
        }
    }

    @Test("dual join preserves distinct carrier identities and identical graphs")
    func canonicalDualJoin() throws {
        let json = ProjectorFixture(codec: .json)
        let cbor = ProjectorFixture(codec: .cbor)
        let jsonBinding = try json.bind()
        let cborBinding = try cbor.bind()
        let receipt = canonical(joinFields(json: jsonBinding, cbor: cborBinding))
        #expect(receipt.count == 500)
        try ReceiptBinding.join(
            graph: syntheticGraph, jsonGraph: json.graph, cborGraph: cbor.graph,
            receipt: receipt, json: jsonBinding, cbor: cborBinding
        )
    }

    @Test("dual join binds every field and cannot write an authority bit")
    func dualJoinFieldMutations() throws {
        let json = try ProjectorFixture(codec: .json).bind()
        let cbor = try ProjectorFixture(codec: .cbor).bind()
        let fields = joinFields(json: json, cbor: cbor)
        let mutations: Fields = [
            ("authority_vector", "00000001"),
            ("cbor_graph_frame_sha256", wrongHash),
            ("graph_merkle_root", wrongHash),
            ("json_graph_frame_sha256", wrongHash),
            ("projection_write_mask", "10000000"),
            ("result", "FAIL"),
            ("schema", "ergentics.gate-e.static.dual-graph-join-receipt.v2"),
            ("semantic_root", wrongHash),
        ]
        for (key, value) in mutations {
            rejects {
                try ReceiptBinding.join(
                    graph: syntheticGraph, jsonGraph: syntheticGraph,
                    cborGraph: syntheticGraph,
                    receipt: canonical(replacing(fields, key: key, value: value)),
                    json: json, cbor: cbor
                )
            }
        }
        for receipt in malformedVariants(fields) {
            rejects {
                try ReceiptBinding.join(
                    graph: syntheticGraph, jsonGraph: syntheticGraph,
                    cborGraph: syntheticGraph, receipt: receipt,
                    json: json, cbor: cbor
                )
            }
        }
    }

    @Test("join rejects changed output or either changed input graph")
    func dualJoinGraphByteEquality() throws {
        let json = try ProjectorFixture(codec: .json).bind()
        let cbor = try ProjectorFixture(codec: .cbor).bind()
        let receipt = canonical(joinFields(json: json, cbor: cbor))
        let changed = syntheticGraph + [0]
        for mutation in 0..<3 {
            rejects {
                try ReceiptBinding.join(
                    graph: mutation == 0 ? changed : syntheticGraph,
                    jsonGraph: mutation == 1 ? changed : syntheticGraph,
                    cborGraph: mutation == 2 ? changed : syntheticGraph,
                    receipt: receipt, json: json, cbor: cbor
                )
            }
        }
    }

    @Test("individually well-formed roots still must agree at the join")
    func dualJoinMerkleDisagreement() throws {
        let json = try ProjectorFixture(codec: .json).bind()
        let cbor = try ProjectorFixture(codec: .cbor, merkle: wrongHash).bind()
        #expect(json.frameHash == cbor.frameHash)
        #expect(json.merkleRoot != cbor.merkleRoot)
        rejects {
            try ReceiptBinding.join(
                graph: syntheticGraph, jsonGraph: syntheticGraph,
                cborGraph: syntheticGraph,
                receipt: canonical(joinFields(json: json, cbor: cbor)),
                json: json, cbor: cbor
            )
        }
    }

    @Test("full-boundary completeness is exact rather than a lower bound")
    func boundaryCompleteness() throws {
        try BoundaryChecks.requireComplete(
            sourceMetadata: 13, sourceDigests: 13,
            imageMetadata: 3, imageDigests: 3, endpoints: true
        )
        for field in 0..<4 {
            for delta in [-1, 1] {
                var counts = [13, 13, 3, 3]
                counts[field] += delta
                rejects {
                    try BoundaryChecks.requireComplete(
                        sourceMetadata: counts[0], sourceDigests: counts[1],
                        imageMetadata: counts[2], imageDigests: counts[3],
                        endpoints: true
                    )
                }
            }
        }
        rejects {
            try BoundaryChecks.requireComplete(
                sourceMetadata: 13, sourceDigests: 13,
                imageMetadata: 3, imageDigests: 3, endpoints: false
            )
        }
    }

    @Test("one-shot latch has exactly one sequential winner")
    func sequentialOneShot() throws {
        let latch = OneShotLatch()
        try latch.consume()
        for _ in 0..<8 {
            rejects { try latch.consume() }
        }
    }

    @Test("one-shot latch has exactly one concurrent winner")
    func concurrentOneShot() async {
        let latch = OneShotLatch()
        let winners = await withTaskGroup(of: Bool.self, returning: Int.self) { group in
            for _ in 0..<64 {
                group.addTask {
                    do {
                        try latch.consume()
                        return true
                    } catch {
                        return false
                    }
                }
            }
            var count = 0
            for await won in group {
                if won { count += 1 }
            }
            return count
        }
        #expect(winners == 1)
        rejects { try latch.consume() }
    }

    @Test("child ownership accepts only a positive direct-child identifier")
    func positiveChildIdentity() throws {
        rejects { _ = try ChildOwnership(pid: 0) }
        rejects { _ = try ChildOwnership(pid: -1) }
        rejects { _ = try ChildOwnership(pid: Int32.min) }
        let child = try ChildOwnership(pid: 42)
        #expect(!child.isReaped)
        #expect(!child.ownershipLost)
        #expect(!child.killCommitted)
    }

    @Test("running and interruption do not spend exact-child ownership")
    func interruptedWaitRetainsOwnership() throws {
        var child = try ChildOwnership(pid: 42)
        try child.observe(.running)
        try child.observe(.interrupted)
        try child.observe(.running)
        #expect(!child.isReaped)
        #expect(!child.ownershipLost)
        #expect(try child.commitKill() == 42)
        #expect(child.killCommitted)
        rejects { _ = try child.commitKill() }
        try child.observe(.reaped(9))
        #expect(child.isReaped)
        #expect(child.rawWaitStatus == 9)
        rejects { _ = try child.commitKill() }
    }

    @Test("natural exact reap removes all later actuation eligibility")
    func exactReapWithoutKill() throws {
        var child = try ChildOwnership(pid: 42)
        try child.observe(.reaped(0))
        #expect(child.isReaped)
        #expect(child.rawWaitStatus == 0)
        #expect(!child.killCommitted)
        rejects { _ = try child.commitKill() }
    }

    @Test("raw wait status is retained exactly and reap is terminal")
    func rawWaitStatusAndTerminalReap() throws {
        var child = try ChildOwnership(pid: 42)
        // Live code must join waitpid's returned PID before producing this
        // observation. This pure type receives raw status, not that PID.
        try child.observe(.reaped(70 << 8))
        #expect(child.isReaped)
        #expect(child.rawWaitStatus == (70 << 8))
        rejects { try child.observe(.reaped(0)) }
        rejects { try child.observe(.running) }
        rejects { try child.observe(.interrupted) }
        rejects { _ = try child.commitKill() }
    }

    @Test("lost child ownership never permits a numeric-PID kill")
    func lostChildOwnership() throws {
        var child = try ChildOwnership(pid: 42)
        try child.observe(.lost(10))
        #expect(child.ownershipLost)
        #expect(!child.isReaped)
        rejects { try child.observe(.reaped(0)) }
        rejects { try child.observe(.running) }
        rejects { _ = try child.commitKill() }
    }

    @Test("deadline is exact at the five-second boundary")
    func exactDeadlineBoundary() throws {
        #expect(try !Deadline.expired(
            start: 17, now: 5_000_000_016, numerator: 1, denominator: 1
        ))
        #expect(try Deadline.expired(
            start: 17, now: 5_000_000_017, numerator: 1, denominator: 1
        ))
        #expect(try Deadline.expired(
            start: 17, now: 5_000_000_018, numerator: 1, denominator: 1
        ))
    }

    @Test("rational ticks are compared without nanosecond rounding")
    func rationalDeadlineBoundary() throws {
        #expect(try !Deadline.expired(
            start: 17, now: 120_000_016, numerator: 125, denominator: 3
        ))
        #expect(try Deadline.expired(
            start: 17, now: 120_000_017, numerator: 125, denominator: 3
        ))
        #expect(try !Deadline.expired(
            start: 0, now: 14_999_999_999, numerator: 1, denominator: 3
        ))
        #expect(try Deadline.expired(
            start: 0, now: 15_000_000_000, numerator: 1, denominator: 3
        ))
    }

    @Test("wide products do not overflow or truncate fractional time")
    func wideDeadlineArithmetic() throws {
        #expect(try Deadline.expired(
            start: 0, now: UInt64.max,
            numerator: UInt32.max, denominator: UInt32.max
        ))
        #expect(try !Deadline.expired(
            start: 0, now: UInt64.max, numerator: 1, denominator: UInt32.max
        ))
        #expect(try !Deadline.expired(
            start: 0, now: 1, numerator: UInt32.max, denominator: 1
        ))
        #expect(try Deadline.expired(
            start: 0, now: 2, numerator: UInt32.max, denominator: 1
        ))
    }

    @Test("invalid clocks and timebases reject instead of disabling a deadline")
    func invalidDeadlineInputs() {
        rejects {
            _ = try Deadline.expired(start: 2, now: 1, numerator: 1, denominator: 1)
        }
        rejects {
            _ = try Deadline.expired(start: 0, now: 0, numerator: 0, denominator: 1)
        }
        rejects {
            _ = try Deadline.expired(start: 0, now: 0, numerator: 1, denominator: 0)
        }
    }

    @Test("input endpoint requires read-only offset-zero parked descriptor")
    func inputEndpointAdmission() throws {
        try EndpointChecks.input(offset: 0, readOnly: true, sourceFD: 32, targetFD: 0)
        for offset in [Int64(-1), 1] {
            rejects {
                try EndpointChecks.input(
                    offset: offset, readOnly: true, sourceFD: 32, targetFD: 0
                )
            }
        }
        rejects {
            try EndpointChecks.input(offset: 0, readOnly: false, sourceFD: 32, targetFD: 0)
        }
        for source in [Int32(-1), 0, 31] {
            rejects {
                try EndpointChecks.input(
                    offset: 0, readOnly: true, sourceFD: source, targetFD: 0
                )
            }
        }
        for target in [Int32(-1), 9] {
            rejects {
                try EndpointChecks.input(
                    offset: 0, readOnly: true, sourceFD: 32, targetFD: target
                )
            }
        }
    }

    @Test("endpoint vnode equality is device and inode, not pathname")
    func endpointVnodeDisjointness() throws {
        let first = Vnode(device: 1, inode: 100)
        let next = Vnode(device: 1, inode: 101)
        let otherDevice = Vnode(device: 2, inode: 100)
        try EndpointChecks.disjoint(inputs: [first], outputs: [next, otherDevice])
        rejects { try EndpointChecks.disjoint(inputs: [first], outputs: [first]) }
        rejects { try EndpointChecks.disjoint(inputs: [first], outputs: [next, next]) }
    }

    @Test("each stage has only its frozen descriptor-target map")
    func frozenEndpointMaps() throws {
        for stage in Stage.allCases {
            let plan = endpointPlan(stage)
            try EndpointChecks.plan(stage: stage, inputs: plan.inputs, outputs: plan.outputs)
        }
        let projector = endpointPlan(.json)
        rejects {
            try EndpointChecks.plan(stage: .join, inputs: projector.inputs, outputs: projector.outputs)
        }
        let join = endpointPlan(.join)
        rejects {
            try EndpointChecks.plan(stage: .json, inputs: join.inputs, outputs: join.outputs)
        }
    }

    @Test("missing extra aliased and unparked descriptors reject per stage")
    func endpointMapMutations() {
        for stage in Stage.allCases {
            let plan = endpointPlan(stage)
            var missingInput = plan.inputs
            missingInput.removeValue(forKey: 0)
            rejects {
                try EndpointChecks.plan(stage: stage, inputs: missingInput, outputs: plan.outputs)
            }
            var extraInput = plan.inputs
            extraInput[9] = 60
            rejects {
                try EndpointChecks.plan(stage: stage, inputs: extraInput, outputs: plan.outputs)
            }
            var missingOutput = plan.outputs
            missingOutput.removeValue(forKey: 1)
            rejects {
                try EndpointChecks.plan(stage: stage, inputs: plan.inputs, outputs: missingOutput)
            }
            var extraOutput = plan.outputs
            extraOutput[9] = 61
            rejects {
                try EndpointChecks.plan(stage: stage, inputs: plan.inputs, outputs: extraOutput)
            }
            var aliasedOutput = plan.outputs
            aliasedOutput[1] = 32
            rejects {
                try EndpointChecks.plan(stage: stage, inputs: plan.inputs, outputs: aliasedOutput)
            }
            var duplicateOutputs = plan.outputs
            duplicateOutputs[2] = duplicateOutputs[1]
            rejects {
                try EndpointChecks.plan(stage: stage, inputs: plan.inputs, outputs: duplicateOutputs)
            }
            var unparkedInput = plan.inputs
            unparkedInput[0] = 31
            rejects {
                try EndpointChecks.plan(stage: stage, inputs: unparkedInput, outputs: plan.outputs)
            }
            var unparkedOutput = plan.outputs
            unparkedOutput[1] = 31
            rejects {
                try EndpointChecks.plan(stage: stage, inputs: plan.inputs, outputs: unparkedOutput)
            }
        }
    }

    @Test("stage order is JSON then CBOR then join exactly once")
    func fixedStageOrder() throws {
        var sequence = StageSequencer()
        #expect(sequence.next == .json)
        try sequence.finish(.json)
        #expect(sequence.next == .cbor)
        try sequence.finish(.cbor)
        #expect(sequence.next == .join)
        try sequence.finish(.join)
        #expect(sequence.next == nil)
        for stage in Stage.allCases {
            rejects { try sequence.finish(stage) }
        }
    }

    @Test("wrong order and explicit rejection cannot advance later stages")
    func stageRejection() throws {
        var wrongOrder = StageSequencer()
        rejects { try wrongOrder.finish(.cbor) }
        #expect(wrongOrder.next == nil)
        rejects { try wrongOrder.finish(.json) }

        var duplicate = StageSequencer()
        try duplicate.finish(.json)
        rejects { try duplicate.finish(.json) }
        #expect(duplicate.next == nil)

        var rejected = StageSequencer()
        rejected.reject()
        #expect(rejected.next == nil)
        for stage in Stage.allCases {
            rejects { try rejected.finish(stage) }
        }
    }
}

private typealias Fields = [(String, String)]

private let frozenJSONHash = "cda57fec7b6ee67d308eddc1f19d6a844d7f72f7d02aea487ee73e265039961e"
private let frozenCBORHash = "c7242f65b69d16f05c67425241297e4e5d598eecc4155aca01c73e40af817636"
private let frozenSemanticRoot = "093b6e90214704a3e8fdf28cf430a8c4cd106d695e621887b77db489fc5cd9bb"
private let syntheticGraph = Array("synthetic opaque graph; never live worker evidence".utf8)
private let syntheticMerkle = String(repeating: "a", count: 64)
private let wrongHash = String(repeating: "b", count: 64)

private struct ProjectorFixture {
    let codec: Codec
    let graph: [UInt8]
    let verifierFields: Fields
    let roundTripFields: Fields

    init(codec: Codec, graph: [UInt8] = syntheticGraph, merkle: String = syntheticMerkle) {
        self.codec = codec
        self.graph = graph
        let hash = bootstrapSHA256(graph)
        verifierFields = [
            ("candidate_sha256", codec.candidateHash),
            ("graph_frame_sha256", hash),
            ("graph_merkle_root", merkle),
            ("result", "PASS"),
            ("schema", "ergentics.gate-e.static.verifier-receipt.v1"),
            ("semantic_root", frozenSemanticRoot),
            ("source_authority", codec.rawValue),
        ]
        roundTripFields = [
            ("candidate_sha256", codec.candidateHash),
            ("graph_frame_sha256", hash),
            ("graph_merkle_root", merkle),
            ("original_semantic_root", frozenSemanticRoot),
            ("reconstructed_candidate_sha256", codec.candidateHash),
            ("reconstructed_graph_frame_sha256", hash),
            ("reconstructed_semantic_root", frozenSemanticRoot),
            ("result", "PASS"),
            ("schema", "ergentics.gate-e.static.round-trip-receipt.v1"),
            ("source_authority", codec.rawValue),
        ]
    }

    func bind(verifier: [UInt8]? = nil, roundTrip: [UInt8]? = nil) throws -> GraphBinding {
        try ReceiptBinding.projector(
            codec: codec, graph: graph,
            verifier: verifier ?? canonical(verifierFields),
            roundTrip: roundTrip ?? canonical(roundTripFields)
        )
    }
}

private func joinFields(json: GraphBinding, cbor: GraphBinding) -> Fields {
    [
        ("authority_vector", "00000000"),
        ("cbor_graph_frame_sha256", cbor.frameHash),
        ("graph_merkle_root", json.merkleRoot),
        ("json_graph_frame_sha256", json.frameHash),
        ("projection_write_mask", "00000000"),
        ("result", "PASS"),
        ("schema", "ergentics.gate-e.static.dual-graph-join-receipt.v1"),
        ("semantic_root", frozenSemanticRoot),
    ]
}

private func canonical(_ fields: Fields) -> [UInt8] {
    Array(("{" + fields.map { "\"\($0.0)\":\"\($0.1)\"" }.joined(separator: ",") + "}").utf8)
}

private func replacing(_ fields: Fields, key: String, value: String) -> Fields {
    fields.map { ($0.0, $0.0 == key ? value : $0.1) }
}

private func malformedVariants(_ fields: Fields) -> [[UInt8]] {
    let bytes = canonical(fields)
    var reordered = fields
    reordered.swapAt(0, 1)
    var escapedKey = fields
    escapedKey[0].0 = escapeFirstASCII(escapedKey[0].0)
    var escapedValue = fields
    escapedValue[0].1 = escapeFirstASCII(escapedValue[0].1)
    return [
        [], [0x20] + bytes, bytes + [0x0a], bytes + [0],
        Array(bytes.dropLast()), bytes + bytes,
        canonical(Array(fields.dropFirst())),
        canonical(fields + [("unknown", "value")]),
        canonical([fields[0]] + fields),
        canonical(reordered), canonical(escapedKey), canonical(escapedValue),
    ]
}

private func escapeFirstASCII(_ value: String) -> String {
    let bytes = Array(value.utf8)
    let digits = Array("0123456789abcdef".utf8)
    let first = bytes[0]
    return "\\u00" + String(decoding: [digits[Int(first >> 4)], digits[Int(first & 15)]], as: UTF8.self)
        + String(decoding: bytes.dropFirst(), as: UTF8.self)
}

private func rejects(_ body: () throws -> Void) {
    do {
        try body()
        Issue.record("Expected the pure frozen boundary to reject")
    } catch { }
}

private func endpointPlan(_ stage: Stage) -> (inputs: [Int32: Int32], outputs: [Int32: Int32]) {
    switch stage {
    case .json, .cbor:
        ([0: 32], [1: 40, 2: 41, 3: 42, 4: 43])
    case .join:
        ([0: 32, 3: 33, 4: 34, 5: 35, 6: 36, 7: 37], [1: 40, 2: 41, 8: 42])
    }
}
