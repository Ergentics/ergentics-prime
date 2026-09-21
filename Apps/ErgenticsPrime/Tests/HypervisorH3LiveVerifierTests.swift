import Darwin
import Foundation
import SQLite3
import XCTest

// Fabricated native values only; no VM or native owner. H4 cases use bounded
// private temporary SQLite fixtures, never the user's retained evidence.
final class HypervisorH3LiveVerifierTests: XCTestCase {
    private let pageBytes = 16_384
    private let sourceGeneration: UInt64 = 9
    private let targetGeneration: UInt64 = 10

    private var image: Data {
        let words: [UInt32] = [
            0xd2880000, 0xf2a20000, 0xd2900001, 0xf2a20001,
            0xd2980003, 0xf2a20003, 0xc8dffc04, 0xf100049f,
            0x54000321, 0xf9400405, 0xf10004bf, 0x540002c1,
            0xf9400806, 0xf9400c07, 0x8b0700c6, 0xf9000425,
            0xf9000826, 0xf9000c3f, 0xc89ffc24, 0xd5033f9f,
            0xb9000064, 0xf100a8df, 0x54000161, 0xf9400828,
            0xf100a91f, 0x54000101, 0x91000508, 0xf9000c28,
            0xd2800044, 0xc89ffc24, 0xd5033f9f, 0xb9000064,
            0xd43bd5a0, 0xd42175a0,
        ]
        return Data(words.flatMap { word in
            (0..<4).map { UInt8(truncatingIfNeeded: word >> ($0 * 8)) }
        })
    }

    private func page(_ prefix: Data) -> Data {
        var result = Data(repeating: 0, count: pageBytes)
        result.replaceSubrange(0..<prefix.count, with: prefix)
        return result
    }

    private func appendBE(_ value: UInt64, to data: inout Data) {
        for index in (0..<8).reversed() {
            data.append(UInt8(truncatingIfNeeded: value >> (index * 8)))
        }
    }

    private func bytes(_ hex: String) -> Data {
        let characters = Array(hex.utf8)
        func nibble(_ value: UInt8) -> UInt8 { value <= 57 ? value - 48 : value - 87 }
        return Data(stride(from: 0, to: characters.count, by: 2).map {
            (nibble(characters[$0]) << 4) | nibble(characters[$0 + 1])
        })
    }

    private func store<T>(_ data: Data, in tuple: inout T) {
        withUnsafeMutableBytes(of: &tuple) { destination in
            XCTAssertEqual(destination.count, data.count)
            destination.copyBytes(from: data)
        }
    }

    private func load<T>(_ tuple: inout T) -> Data {
        withUnsafeBytes(of: &tuple) { Data($0) }
    }

    private func phase(generation: UInt64, pc: UInt64, x4: UInt64,
                       reads: UInt32, entry: UInt64, exit: UInt64) -> EPRGuestH3PhaseResult {
        var result = EPRGuestH3PhaseResult()
        result.run_entries = 1
        result.mappings_entered = 3
        result.register_set_calls = 36
        result.register_read_calls = reads
        result.conserved = 1
        result.generation = generation
        result.entry_ticks = entry
        result.exit_ticks = exit
        result.exception_reason = 1
        result.syndrome = 0x9384_0044
        result.pc = pc
        result.fault_ipa = 0x1000_c000
        result.fault_virtual_address = 0x1000_c000
        result.x4 = x4
        return result
    }

    private func setCheckpointPass(_ result: inout EPRGuestH3CursorResumeResult) {
        result.checkpoint_diagnostic.schema_version = 1
        result.checkpoint_diagnostic.required_mask = 0x1ff
        result.checkpoint_diagnostic.evaluated_mask = 0x1ff
        result.checkpoint_diagnostic.passed_mask = 0x1ff
        result.checkpoint_diagnostic.gpr_mismatch_mask = 0
        result.checkpoint_diagnostic.reserved_zero = 0
        result.checkpoint_diagnostic.checkpoint_sequence = 1
        result.checkpoint_diagnostic.gprs = (
            0x1000_4000, 0x1000_8000, 0, 0x1000_c000, 1, 1, 42, 23,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0
        )
        result.checkpoint_diagnostic.cpsr = 0x6000_03c5
        result.checkpoint_diagnostic.sctlr = 0x30d0_0980
        result.checkpoint_diagnostic.sp = 0x1000_bff0
        result.checkpoint_diagnostic.vbar = 0
        result.checkpoint_diagnostic.page_witnesses.0.first_mismatch_offset = UInt32.max
        result.checkpoint_diagnostic.page_witnesses.1.first_mismatch_offset = UInt32.max
        result.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = UInt32.max
    }

    private func setSCTLRTransitionFull(_ result: inout EPRGuestH3CursorResumeResult,
                                         pre: UInt64 = 0x30d0_0980,
                                         post: UInt64 = 0x30d0_0980) {
        result.sctlr_transition_diagnostic.schema_version = 1
        result.sctlr_transition_diagnostic.sampled_mask = 0x7
        result.sctlr_transition_diagnostic.source_pre_entry_read_entries = 1
        result.sctlr_transition_diagnostic.source_post_exit_read_entries = 1
        result.sctlr_transition_diagnostic.source_pre_entry_read_status = 0
        result.sctlr_transition_diagnostic.source_post_exit_read_status = 0
        result.sctlr_transition_diagnostic.reserved_zero_0 = 0
        result.sctlr_transition_diagnostic.reserved_zero_1 = 0
        result.sctlr_transition_diagnostic.requested = 0x30d0_0980
        result.sctlr_transition_diagnostic.source_pre_entry = pre
        result.sctlr_transition_diagnostic.source_post_exit = post
    }

    private func setSCTLRTransitionZero(_ result: inout EPRGuestH3CursorResumeResult) {
        result.sctlr_transition_diagnostic = EPRGuestH3SCTLRTransitionDiagnostic()
    }

    private func setCheckpointNotEvaluated(_ result: inout EPRGuestH3CursorResumeResult) {
        result.checkpoint_valid = 0
        result.checkpoint_diagnostic = EPRGuestH3CheckpointDiagnostic()
        result.checkpoint_diagnostic.schema_version = 1
        result.checkpoint_diagnostic.required_mask = 0x1ff
        result.checkpoint_diagnostic.page_witnesses.0.first_mismatch_offset = UInt32.max
        result.checkpoint_diagnostic.page_witnesses.1.first_mismatch_offset = UInt32.max
        result.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = UInt32.max
    }

    private func makeSCTLRCheckpointFailure(_ value: EPRGuestH3CursorResumeResult,
                                             pre: UInt64,
                                             post: UInt64) -> EPRGuestH3CursorResumeResult {
        var result = makeCheckpointFailure(value)
        result.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_SCTLR)
        result.checkpoint_diagnostic.sctlr = post
        setSCTLRTransitionFull(&result, pre: pre, post: post)
        return result
    }

    private func makeCheckpointFailure(_ value: EPRGuestH3CursorResumeResult)
        -> EPRGuestH3CursorResumeResult {
        var result = value
        result.outcome = UInt32(EPR_GUEST_FAILED)
        result.execution_pass = 0
        result.checkpoint_valid = 0
        result.failure_stage = 11
        result.first_error = EPROTO
        return result
    }

    private func makeEvidence(source: UInt64, target: UInt64) -> (Data, Data) {
        var evidence = Data([0x45, 0x50, 0x52, 0x48, 0x33, 0x45, 0x32, 0])
        let header: [UInt64] = [2, source, target, 2, 3, 31, 4, 136, 16_384,
            0x50, 0x54, 0x7c, 0x1000_c000, 4, 1, 2]
        for word in header { appendBE(word, to: &evidence) }
        let gprs: [UInt64] = [0x1000_4000, 0x1000_8000, 0, 0x1000_c000,
                              1, 1, 42, 23] + Array(repeating: 0, count: 23)
        for word in gprs { appendBE(word, to: &evidence) }
        for word in [UInt64(0x6000_03c5), 0x30d0_0980, 0x1000_bff0, 0] {
            appendBE(word, to: &evidence)
        }
        for word in [UInt64(1), 0x1000_0000, 16_384, 5,
                     2, 0x1000_4000, 16_384, 1,
                     3, 0x1000_8000, 16_384, 3] {
            appendBE(word, to: &evidence)
        }
        let checkpointReply = GuestContract.frame([1, 1, 42, 0])
        evidence.append(bytes(GuestContract.hash(page(image))))
        evidence.append(bytes(GuestContract.hash(page(GuestContract.request))))
        evidence.append(bytes(GuestContract.hash(page(checkpointReply))))
        XCTAssertEqual(evidence.count, 608)
        var internalCursor = Data("EPRCUR02".utf8)
        internalCursor.append(evidence.subdata(in: 8..<608))
        internalCursor.append(page(checkpointReply))
        XCTAssertEqual(internalCursor.count, 16_992)
        let digest = bytes(GuestContract.hash(internalCursor))
        evidence.append(checkpointReply)
        appendBE(UInt64(pageBytes - checkpointReply.count), to: &evidence)
        evidence.append(digest)
        XCTAssertEqual(evidence.count, 680)
        return (evidence, digest)
    }

    private func roots(cursorDigest: Data, checkpointReply: Data,
                       finalReply: Data) throws -> (Data, Data) {
        let checkpoint = try MerkleGenesis.commit([
            GenesisLeaf(label: "cursor_digest", payload: cursorDigest),
            GenesisLeaf(label: "guest_image", payload: image),
            GenesisLeaf(label: "reply", payload: checkpointReply),
            GenesisLeaf(label: "request", payload: GuestContract.request),
            GenesisLeaf(label: "schema", payload: Data("ergentics.hypervisor.guest.h3.checkpoint.v2".utf8)),
        ])
        let terminal = try MerkleGenesis.commit([
            GenesisLeaf(label: "checkpoint_reply", payload: checkpointReply),
            GenesisLeaf(label: "cursor_digest", payload: cursorDigest),
            GenesisLeaf(label: "final_reply", payload: finalReply),
            GenesisLeaf(label: "guest_image", payload: image),
            GenesisLeaf(label: "request", payload: GuestContract.request),
            GenesisLeaf(label: "schema", payload: Data("ergentics.hypervisor.guest.h3.terminal.v2".utf8)),
        ])
        return (bytes(checkpoint.root), bytes(terminal.root))
    }

    private func fixture(source: UInt64? = nil, target: UInt64? = nil) throws -> EPRGuestH3CursorResumeResult {
        let source = source ?? sourceGeneration
        let target = target ?? targetGeneration
        let (evidence, digest) = makeEvidence(source: source, target: target)
        let checkpointReply = GuestContract.frame([1, 1, 42, 0])
        let finalReply = GuestContract.frame([2, 1, 42, 43])
        let commitments = try roots(cursorDigest: digest, checkpointReply: checkpointReply,
                                    finalReply: finalReply)
        var result = EPRGuestH3CursorResumeResult()
        result.abi_version = 5
        result.outcome = 1
        result.execution_pass = 1
        result.teardown_pass = 1
        result.signing_admitted = 1
        result.cursor_sealed = 1
        result.cursor_decoded = 1
        result.cursor_restored = 1
        result.checkpoint_valid = 1
        result.terminal_valid = 1
        result.source_conserved = 1
        result.target_conserved = 1
        result.watchdog_create_entries = 2
        result.watchdog_join_entries = 2
        result.timebase_numer = 125
        result.timebase_denom = 3
        result.cancellation_status = Int32.min
        result.start_ticks = 1
        result.end_ticks = 6
        result.source = phase(generation: source, pc: 0x1000_0050, x4: 1,
                              reads: 36, entry: 2, exit: 3)
        result.target = phase(generation: target, pc: 0x1000_007c, x4: 2,
                              reads: 38, entry: 4, exit: 5)
        setCheckpointPass(&result)
        setSCTLRTransitionFull(&result)
        result.cursor_evidence.byte_count = 680
        store(evidence, in: &result.cursor_evidence.bytes)
        store(digest, in: &result.cursor_sha256)
        store(checkpointReply, in: &result.checkpoint_reply)
        store(finalReply, in: &result.final_reply)
        store(commitments.0, in: &result.checkpoint_merkle)
        store(commitments.1, in: &result.terminal_merkle)
        return result
    }

    private func resealEvidence(_ result: inout EPRGuestH3CursorResumeResult) throws {
        var evidence = load(&result.cursor_evidence.bytes)
        let reply = load(&result.checkpoint_reply)
        var internalCursor = Data("EPRCUR02".utf8)
        internalCursor.append(evidence.subdata(in: 8..<608))
        internalCursor.append(page(reply))
        let digest = bytes(GuestContract.hash(internalCursor))
        evidence.replaceSubrange(648..<680, with: digest)
        store(evidence, in: &result.cursor_evidence.bytes)
        store(digest, in: &result.cursor_sha256)
        let commitments = try roots(cursorDigest: digest, checkpointReply: reply,
            finalReply: load(&result.final_reply))
        store(commitments.0, in: &result.checkpoint_merkle)
        store(commitments.1, in: &result.terminal_merkle)
    }

    private func resealRoots(_ result: inout EPRGuestH3CursorResumeResult) throws {
        let commitments = try roots(cursorDigest: load(&result.cursor_sha256),
            checkpointReply: load(&result.checkpoint_reply),
            finalReply: load(&result.final_reply))
        store(commitments.0, in: &result.checkpoint_merkle)
        store(commitments.1, in: &result.terminal_merkle)
    }

    func testV2RejectsEverySCTLRBitMutationEvenWithResealedEvidence() throws {
        let expected: UInt64 = 0x30d0_0980
        for bit in 0..<64 {
            let changed = expected ^ (UInt64(1) << bit)
            var witness = try fixture()
            witness.checkpoint_diagnostic.sctlr = changed
            witness.sctlr_transition_diagnostic.source_post_exit = changed
            // A forged all-pass mask cannot excuse any changed bit.
            assertRejected(witness)

            var cursor = try fixture()
            var evidence = load(&cursor.cursor_evidence.bytes)
            var word = Data()
            appendBE(changed, to: &word)
            evidence.replaceSubrange(392..<400, with: word)
            store(evidence, in: &cursor.cursor_evidence.bytes)
            try resealEvidence(&cursor)
            assertRejected(cursor)
        }
    }

    func testV2RejectsLegacyCursorVersionAndMagicAfterResealing() throws {
        for offset in [6, 15] {
            var value = try fixture()
            var evidence = load(&value.cursor_evidence.bytes)
            evidence[offset] = offset == 6 ? 0x31 : 1
            store(evidence, in: &value.cursor_evidence.bytes)
            try resealEvidence(&value)
            assertRejected(value)
        }
    }

    func testHistoricalSCTLRRunDoesNotBecomePassUnderV2() throws {
        var value = makeCheckpointFailure(try fixture())
        value.checkpoint_diagnostic.passed_mask = 0x1bf
        value.checkpoint_diagnostic.sctlr = 0x30d0_0980
        value.sctlr_transition_diagnostic.requested = 0x30d0_0800
        value.sctlr_transition_diagnostic.source_pre_entry = 0x30d0_0800
        value.sctlr_transition_diagnostic.source_post_exit = 0x30d0_0980
        assertRejected(value)
        let presentation = GuestH3LiveVerifier.rejected(value,
            ProvenanceFailure("Retained Build 9 / September 5 legacy trace"))
        XCTAssertNotEqual(presentation.status, "PASS")
        XCTAssertTrue(try XCTUnwrap(presentation.nativeDiagnostic).rendered
            .contains("requested=818939904/0x0000000030d00800"))
        assertNoAuthority(presentation)
    }

    private func assertRejected(_ value: EPRGuestH3CursorResumeResult,
                                file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try GuestH3LiveVerifier.verify(value), file: file, line: line)
    }

    private func semanticMap(_ value: GuestCBORValue) throws -> [String: GuestCBORValue] {
        guard case .map(let map) = value else {
            throw ProvenanceFailure("Hostile projection fixture is not a map")
        }
        return map
    }

    private func liveProjection(_ semantic: GuestCBORValue,
                                schema: String, role: String) throws -> HypervisorStageProjection {
        let json = try StageCanonicalJSON.encode(semantic)
        let cbor = try GuestCBOR.encode(semantic)
        let partial = HypervisorStageProjection(json: json, cbor: cbor, root: "")
        return HypervisorStageProjection(json: json, cbor: cbor,
            root: try MerkleGenesis.commit([
                GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
                GenesisLeaf(label: "\(role).json", payload: partial.json),
                GenesisLeaf(label: "\(role).cbor", payload: partial.cbor),
            ]).root)
    }

    private func liveProjection(json: Data, cbor: Data,
                                schema: String, role: String) throws -> HypervisorStageProjection {
        let partial = HypervisorStageProjection(json: json, cbor: cbor, root: "")
        return HypervisorStageProjection(json: json, cbor: cbor,
            root: try MerkleGenesis.commit([
                GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
                GenesisLeaf(label: "\(role).json", payload: partial.json),
                GenesisLeaf(label: "\(role).cbor", payload: partial.cbor),
            ]).root)
    }

    private func reroot(_ state: HypervisorStageProjection,
                        _ graph: HypervisorStageProjection,
                        native: EPRGuestH3CursorResumeResult) throws -> GuestH3LiveProjectionReceipt {
        let readiness = try HypervisorStageH3Cursor.verifyContract(HypervisorStageH3Cursor.runContract())
        var value = native
        let cursor = load(&value.cursor_sha256).map { String(format: "%02x", $0) }.joined()
        let checkpoint = load(&value.checkpoint_merkle).map { String(format: "%02x", $0) }.joined()
        let terminal = load(&value.terminal_merkle).map { String(format: "%02x", $0) }.joined()
        let partial = GuestH3LiveProjectionReceipt(state: state, graph: graph, root: "")
        let root = try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(GuestH3LiveVerifier.liveReceiptSchema.utf8)),
            GenesisLeaf(label: "graph.json", payload: graph.json),
            GenesisLeaf(label: "graph.cbor", payload: graph.cbor),
            GenesisLeaf(label: "state.json", payload: state.json),
            GenesisLeaf(label: "state.cbor", payload: state.cbor),
            GenesisLeaf(label: "readiness_receipt_root", payload: Data(readiness.receiptRoot.utf8)),
            GenesisLeaf(label: "readiness_graph_root", payload: Data(readiness.graphRoot.utf8)),
            GenesisLeaf(label: "cursor_digest", payload: Data(cursor.utf8)),
            GenesisLeaf(label: "checkpoint_root", payload: Data(checkpoint.utf8)),
            GenesisLeaf(label: "terminal_root", payload: Data(terminal.utf8)),
        ]).root
        return GuestH3LiveProjectionReceipt(state: partial.state, graph: partial.graph, root: root)
    }

    private func assertProjectionRejected(_ receipt: GuestH3LiveProjectionReceipt,
                                          native: EPRGuestH3CursorResumeResult,
                                          file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try GuestH3LiveVerifier.verifyProjectionForTesting(
            receipt, native: native), file: file, line: line)
    }

    private func assertNoAuthority(_ result: GuestH3Presentation,
                                   file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(result.gateE, "ABSTAIN", file: file, line: line)
        XCTAssertEqual(result.authorityVector, "00000000", file: file, line: line)
        XCTAssertFalse(result.durable, file: file, line: line)
        XCTAssertFalse(result.h4Entered, file: file, line: line)
        XCTAssertTrue(result.projectionRoot.isEmpty, file: file, line: line)
        XCTAssertTrue(result.graphRoot.isEmpty, file: file, line: line)
    }

    func testCheckpointDiagnosticImportedLayoutAndOwnedSendableProjection() throws {
        XCTAssertEqual(MemoryLayout<EPRGuestH3PageMismatchWitness>.size, 8)
        XCTAssertEqual(MemoryLayout<EPRGuestH3CheckpointDiagnostic>.size, 336)
        XCTAssertEqual(MemoryLayout<EPRGuestH3SCTLRTransitionDiagnostic>.size, 56)
        XCTAssertEqual(MemoryLayout<EPRGuestH3CursorResumeResult>.size, 1_688)
        XCTAssertEqual(MemoryLayout<EPRGuestH3CursorResumeResult>.offset(
            of: \EPRGuestH3CursorResumeResult.sctlr_transition_diagnostic), 1_632)
        func requireSendable<T: Sendable>(_: T.Type) {}
        requireSendable(GuestH3CheckpointPageWitness.self)
        requireSendable(GuestH3CheckpointPredicateDiagnostic.self)
        requireSendable(GuestH3SCTLRTransitionDiagnostic.self)
        requireSendable(GuestH3NativeDiagnostic.self)

        let result = GuestH3LiveVerifier.rejected(
            makeCheckpointFailure(try fixture()), ProvenanceFailure("owned-copy"))
        let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
        XCTAssertEqual(diagnostic.checkpoint.gprs.count, 31)
        XCTAssertEqual(diagnostic.checkpoint.pages.map(\.role), ["code", "request", "reply"])
        XCTAssertEqual(diagnostic.checkpoint.schemaVersion, 1)
        XCTAssertEqual(diagnostic.checkpoint.requiredMask, 0x1ff)
        XCTAssertEqual(diagnostic.sctlrTransition.sampledMask, 0x7)
        XCTAssertEqual(diagnostic.sctlrTransition.schemaVersion, 1)
        XCTAssertEqual(diagnostic.sctlrTransition.sourcePreEntryReadEntries, 1)
        XCTAssertEqual(diagnostic.sctlrTransition.sourcePostExitReadEntries, 1)
        XCTAssertEqual(diagnostic.sctlrTransition.sourcePreEntryReadStatus, 0)
        XCTAssertEqual(diagnostic.sctlrTransition.sourcePostExitReadStatus, 0)
        XCTAssertEqual(diagnostic.sctlrTransition.reservedZero0, 0)
        XCTAssertEqual(diagnostic.sctlrTransition.reservedZero1, 0)
        XCTAssertEqual(diagnostic.sctlrTransition.sourcePreEntry, 0x30d0_0980)
        XCTAssertEqual(diagnostic.sctlrTransition.sourcePostExit, 0x30d0_0980)
        XCTAssertEqual(diagnostic.sctlrTransitionIntegrity, "VALID_FULL")
        XCTAssertTrue(diagnostic.rendered.contains("checkpoint.witness schema=1"))
        assertNoAuthority(result)
    }

    func testSCTLRTransitionFullWitnessLocalizesSetTimeAndRunTimeDeltas() throws {
        let expected: UInt64 = 0x30d0_0980
        let observed: UInt64 = 0x30d0_0800
        let cases: [(String, EPRGuestH3CursorResumeResult, UInt64, UInt64)] = [
            ("set-time", makeSCTLRCheckpointFailure(try fixture(),
                pre: observed, post: observed), 0x180, 0),
            ("run-time", makeSCTLRCheckpointFailure(try fixture(),
                pre: expected, post: observed), 0, 0x180),
        ]
        for (index, item) in cases.enumerated() {
            let result = GuestH3LiveVerifier.rejected(item.1, ProvenanceFailure(item.0))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.classification, "NATIVE_NONPASS", line: UInt(index + 1))
            XCTAssertEqual(diagnostic.checkpointIntegrity, "VALID_FAILURE", line: UInt(index + 1))
            XCTAssertEqual(diagnostic.checkpointFailures, ["checkpoint.sctlr"], line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransitionIntegrity, "VALID_FULL", line: UInt(index + 1))
            XCTAssertTrue(diagnostic.sctlrTransitionFailures.isEmpty, line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.requested, expected, line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.sourcePreEntry,
                           item.1.sctlr_transition_diagnostic.source_pre_entry,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.sourcePostExit, observed,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.requestedXORPreEntry, item.2, line: UInt(index + 1))
            XCTAssertEqual(diagnostic.preEntryXORPostExit, item.3, line: UInt(index + 1))
            assertNoAuthority(result, line: UInt(index + 1))
        }
    }

    func testSCTLRTransitionPermitsOnlyExactFailClosedPartialForms() throws {
        var early = makeCheckpointFailure(try fixture())
        early.failure_stage = 4
        setCheckpointNotEvaluated(&early)
        setSCTLRTransitionZero(&early)
        early.source.run_entries = 0
        early.source.run_status = Int32.min

        var preFailure = early
        preFailure.failure_stage = 7
        preFailure.sctlr_transition_diagnostic.schema_version = 1
        preFailure.sctlr_transition_diagnostic.sampled_mask = 1
        preFailure.sctlr_transition_diagnostic.source_pre_entry_read_entries = 1
        preFailure.sctlr_transition_diagnostic.source_pre_entry_read_status = -700
        preFailure.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
        preFailure.sctlr_transition_diagnostic.requested = 0x30d0_0980

        var runFailure = early
        runFailure.failure_stage = 9
        runFailure.sctlr_transition_diagnostic.schema_version = 1
        runFailure.sctlr_transition_diagnostic.sampled_mask = 3
        runFailure.sctlr_transition_diagnostic.source_pre_entry_read_entries = 1
        runFailure.sctlr_transition_diagnostic.source_pre_entry_read_status = 0
        runFailure.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
        runFailure.sctlr_transition_diagnostic.requested = 0x30d0_0980
        runFailure.sctlr_transition_diagnostic.source_pre_entry = 0x30d0_0800
        runFailure.source.run_entries = 1
        runFailure.source.run_status = -701

        var postFailure = runFailure
        postFailure.failure_stage = 10
        postFailure.source.run_status = 0
        postFailure.sctlr_transition_diagnostic.source_post_exit_read_entries = 1
        postFailure.sctlr_transition_diagnostic.source_post_exit_read_status = -702

        let cases: [(EPRGuestH3CursorResumeResult, String, UInt64?)] = [
            (early, "VALID_NOT_SAMPLED", nil),
            (preFailure, "VALID_PARTIAL", nil),
            (runFailure, "VALID_PARTIAL", 0x180),
            (postFailure, "VALID_PARTIAL", 0x180),
        ]
        for (index, item) in cases.enumerated() {
            let result = GuestH3LiveVerifier.rejected(item.0,
                ProvenanceFailure("partial-\(index)"))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.classification, "NATIVE_NONPASS", line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransitionIntegrity, item.1, line: UInt(index + 1))
            XCTAssertTrue(diagnostic.sctlrTransitionFailures.isEmpty, line: UInt(index + 1))
            XCTAssertEqual(diagnostic.requestedXORPreEntry, item.2, line: UInt(index + 1))
            XCTAssertNil(diagnostic.preEntryXORPostExit, line: UInt(index + 1))
            assertNoAuthority(result, line: UInt(index + 1))
        }
    }

    func testSCTLRTransitionInactiveAcceptsStageZeroClaimReturns() throws {
        let cases: [(UInt32, String)] = [
            (UInt32(EPR_GUEST_BUSY), "BUSY"),
            (UInt32(EPR_GUEST_QUARANTINED), "QUARANTINED"),
        ]
        for (index, item) in cases.enumerated() {
            var value = makeCheckpointFailure(try fixture())
            value.outcome = item.0
            value.failure_stage = 0
            value.source.run_entries = 0
            value.source.run_status = Int32.min
            setCheckpointNotEvaluated(&value)
            setSCTLRTransitionZero(&value)

            let result = GuestH3LiveVerifier.rejected(
                value, ProvenanceFailure("claim-lifetime-\(item.1.lowercased())"))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(result.status, item.1, line: UInt(index + 1))
            XCTAssertEqual(diagnostic.classification, "NATIVE_NONPASS",
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransitionIntegrity, "VALID_NOT_SAMPLED",
                           line: UInt(index + 1))
            XCTAssertTrue(diagnostic.sctlrTransitionFailures.isEmpty,
                          line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.schemaVersion, 0,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.sampledMask, 0,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.sourcePreEntryReadEntries, 0,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.sourcePostExitReadEntries, 0,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.sourcePreEntryReadStatus, 0,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.sourcePostExitReadStatus, 0,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.reservedZero0, 0,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.reservedZero1, 0,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.requested, 0,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.sourcePreEntry, 0,
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransition.sourcePostExit, 0,
                           line: UInt(index + 1))
            assertNoAuthority(result, line: UInt(index + 1))
        }

        var impossible = makeCheckpointFailure(try fixture())
        impossible.failure_stage = 0
        impossible.source.run_entries = 0
        impossible.source.run_status = Int32.min
        setCheckpointNotEvaluated(&impossible)
        setSCTLRTransitionZero(&impossible)
        let rejected = GuestH3LiveVerifier.rejected(
            impossible, ProvenanceFailure("non-claim-stage-zero"))
        let diagnostic = try XCTUnwrap(rejected.nativeDiagnostic)
        XCTAssertEqual(diagnostic.classification, "NATIVE_WITNESS_MALFORMED")
        XCTAssertTrue(diagnostic.sctlrTransitionFailures.contains(
            "malformed.sctlr_transition.zero_chronology"))
        assertNoAuthority(rejected)
    }

    func testSCTLRTransitionInactiveCoversEveryPreReadFailureStage() throws {
        for stage in [Int32(1), 2, 3, 4, 5, 6, 7, 18] {
            var value = makeCheckpointFailure(try fixture())
            value.failure_stage = stage
            value.source.run_entries = 0
            value.source.run_status = Int32.min
            setCheckpointNotEvaluated(&value)
            setSCTLRTransitionZero(&value)

            let result = GuestH3LiveVerifier.rejected(
                value, ProvenanceFailure("pre-read-stage-\(stage)"))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.classification, "NATIVE_NONPASS", line: UInt(stage))
            XCTAssertEqual(diagnostic.sctlrTransitionIntegrity, "VALID_NOT_SAMPLED",
                           line: UInt(stage))
            XCTAssertTrue(diagnostic.sctlrTransitionFailures.isEmpty, line: UInt(stage))
            assertNoAuthority(result, line: UInt(stage))
        }
    }

    func testSCTLRTransitionMaskThreeRequiresExactNativeRunChronology() throws {
        func preOnly(stage: Int32, runEntries: UInt32,
                     runStatus: Int32) throws -> EPRGuestH3CursorResumeResult {
            var value = makeCheckpointFailure(try fixture())
            value.failure_stage = stage
            value.source.run_entries = runEntries
            value.source.run_status = runStatus
            self.setCheckpointNotEvaluated(&value)
            value.sctlr_transition_diagnostic.sampled_mask = 3
            value.sctlr_transition_diagnostic.source_post_exit_read_entries = 0
            value.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
            value.sctlr_transition_diagnostic.source_post_exit = 0
            return value
        }

        let valid: [(Int32, UInt32, Int32)] = [
            (2, 0, Int32.min),
            (8, 0, Int32.min),
            (18, 0, Int32.min),
            (9, 1, -1),
        ]
        for (index, item) in valid.enumerated() {
            let result = GuestH3LiveVerifier.rejected(
                try preOnly(stage: item.0, runEntries: item.1, runStatus: item.2),
                ProvenanceFailure("valid-pre-only-\(index)"))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.classification, "NATIVE_NONPASS",
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransitionIntegrity, "VALID_PARTIAL",
                           line: UInt(index + 1))
            XCTAssertTrue(diagnostic.sctlrTransitionFailures.isEmpty,
                          line: UInt(index + 1))
            assertNoAuthority(result, line: UInt(index + 1))
        }

        let impossible: [(String, EPRGuestH3CursorResumeResult)] = [
            ("stage-one", try preOnly(stage: 1, runEntries: 0, runStatus: Int32.min)),
            ("no-run-nonsentinel", try preOnly(stage: 2, runEntries: 0, runStatus: 0)),
            ("entered-run-sentinel", try preOnly(stage: 9, runEntries: 1,
                                                  runStatus: Int32.min)),
            ("failed-run-wrong-stage", try preOnly(stage: 8, runEntries: 1,
                                                    runStatus: -1)),
            ("successful-run-stage-ten", try preOnly(stage: 10, runEntries: 1,
                                                      runStatus: 0)),
        ]
        for (index, item) in impossible.enumerated() {
            let result = GuestH3LiveVerifier.rejected(
                item.1, ProvenanceFailure(item.0))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.classification, "NATIVE_WITNESS_MALFORMED",
                           line: UInt(index + 1))
            XCTAssertTrue(diagnostic.sctlrTransitionFailures.contains(
                "malformed.sctlr_transition.pre_entry_only_chronology"),
                line: UInt(index + 1))
            assertNoAuthority(result, line: UInt(index + 1))
        }
    }

    func testSCTLRTransitionInactiveAndPreFailureRequireExactNoRunJoin() throws {
        func inactive(runEntries: UInt32,
                      runStatus: Int32) throws -> EPRGuestH3CursorResumeResult {
            var value = self.makeCheckpointFailure(try self.fixture())
            value.failure_stage = 4
            value.source.run_entries = runEntries
            value.source.run_status = runStatus
            self.setCheckpointNotEvaluated(&value)
            self.setSCTLRTransitionZero(&value)
            return value
        }
        func preFailure(runEntries: UInt32,
                        runStatus: Int32) throws -> EPRGuestH3CursorResumeResult {
            var value = try inactive(runEntries: runEntries, runStatus: runStatus)
            value.failure_stage = 7
            value.sctlr_transition_diagnostic.schema_version = 1
            value.sctlr_transition_diagnostic.sampled_mask = 1
            value.sctlr_transition_diagnostic.source_pre_entry_read_entries = 1
            value.sctlr_transition_diagnostic.source_pre_entry_read_status = -1
            value.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
            value.sctlr_transition_diagnostic.requested = 0x30d0_0980
            return value
        }

        let cases: [(EPRGuestH3CursorResumeResult, String)] = [
            (try inactive(runEntries: 2, runStatus: Int32.min),
             "malformed.sctlr_transition.zero_chronology"),
            (try inactive(runEntries: 0, runStatus: 0),
             "malformed.sctlr_transition.zero_chronology"),
            (try preFailure(runEntries: 2, runStatus: Int32.min),
             "malformed.sctlr_transition.pre_entry_failure_chronology"),
            (try preFailure(runEntries: 0, runStatus: 0),
             "malformed.sctlr_transition.pre_entry_failure_chronology"),
        ]
        for (index, item) in cases.enumerated() {
            let result = GuestH3LiveVerifier.rejected(
                item.0, ProvenanceFailure("bad-no-run-join-\(index)"))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.classification, "NATIVE_WITNESS_MALFORMED",
                           line: UInt(index + 1))
            XCTAssertTrue(diagnostic.sctlrTransitionFailures.contains(item.1),
                          line: UInt(index + 1))
            assertNoAuthority(result, line: UInt(index + 1))
        }
    }

    func testSCTLRTransitionMalformedFieldChronologyAndJoinMatrix() throws {
        func fullFailure() throws -> EPRGuestH3CursorResumeResult {
            makeSCTLRCheckpointFailure(try fixture(),
                pre: 0x30d0_0980, post: 0x30d0_0800)
        }
        let mutations: [(String, String,
            (inout EPRGuestH3CursorResumeResult) -> Void)] = [
            ("schema", "malformed.sctlr_transition.schema_version",
             { $0.sctlr_transition_diagnostic.schema_version = 2 }),
            ("unknown-mask", "malformed.sctlr_transition.sampled_unknown_bits",
             { $0.sctlr_transition_diagnostic.sampled_mask = 0xf }),
            ("mask-dependency", "malformed.sctlr_transition.sampled_dependency",
             { $0.sctlr_transition_diagnostic.sampled_mask = 2 }),
            ("reserved-0", "malformed.sctlr_transition.reserved_zero",
             { $0.sctlr_transition_diagnostic.reserved_zero_0 = 1 }),
            ("reserved-1", "malformed.sctlr_transition.reserved_zero",
             { $0.sctlr_transition_diagnostic.reserved_zero_1 = 1 }),
            ("requested", "malformed.sctlr_transition.requested",
             { $0.sctlr_transition_diagnostic.requested ^= 1 }),
            ("pre-count", "malformed.sctlr_transition.pre_entry_count_domain",
             { $0.sctlr_transition_diagnostic.source_pre_entry_read_entries = 2 }),
            ("post-count", "malformed.sctlr_transition.post_exit_count_domain",
             { $0.sctlr_transition_diagnostic.source_post_exit_read_entries = 2 }),
            ("pre-success-status", "malformed.sctlr_transition.pre_entry_success_join",
             { $0.sctlr_transition_diagnostic.source_pre_entry_read_status = -1 }),
            ("post-success-status", "malformed.sctlr_transition.post_exit_success_join",
             { $0.sctlr_transition_diagnostic.source_post_exit_read_status = -1 }),
            ("checkpoint-join", "malformed.sctlr_transition.checkpoint_sctlr_join",
             { $0.sctlr_transition_diagnostic.source_post_exit ^= 1 }),
            ("active-busy", "malformed.sctlr_transition.active_claim_outcome",
             { $0.outcome = UInt32(EPR_GUEST_BUSY) }),
            ("active-quarantined", "malformed.sctlr_transition.active_claim_outcome",
             { $0.outcome = UInt32(EPR_GUEST_QUARANTINED) }),
            ("full-admission-stage", "malformed.sctlr_transition.full_at_admission_stage",
             { $0.failure_stage = 1 }),
            ("stage-zero-nonpass", "malformed.sctlr_transition.stage_zero_outcome",
             { $0.failure_stage = 0 }),
            ("pass-with-failure-stage", "malformed.sctlr_transition.pass_with_failure_stage", {
                $0.outcome = UInt32(EPR_GUEST_PASS)
                $0.failure_stage = 10
            }),
            ("pass-partial", "malformed.sctlr_transition.pass_without_full_transition", { value in
                value.outcome = UInt32(EPR_GUEST_PASS)
                value.failure_stage = 9
                self.setCheckpointNotEvaluated(&value)
                value.sctlr_transition_diagnostic.sampled_mask = 3
                value.sctlr_transition_diagnostic.source_post_exit_read_entries = 0
                value.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
                value.sctlr_transition_diagnostic.source_post_exit = 0
                value.source.run_status = -1
            }),
            ("full-without-run", "malformed.sctlr_transition.full_without_successful_run", {
                $0.source.run_entries = 0
                $0.source.run_status = Int32.min
            }),
            ("checkpoint-without-full", "malformed.sctlr_transition.checkpoint_without_full_transition", {
                $0.sctlr_transition_diagnostic.sampled_mask = 3
                $0.sctlr_transition_diagnostic.source_post_exit_read_entries = 0
                $0.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
                $0.sctlr_transition_diagnostic.source_post_exit = 0
            }),
            ("zero-after-run", "malformed.sctlr_transition.zero_chronology", { value in
                self.setSCTLRTransitionZero(&value)
            }),
            ("pre-failure-stage", "malformed.sctlr_transition.pre_entry_failure_chronology", { value in
                self.setCheckpointNotEvaluated(&value)
                self.setSCTLRTransitionZero(&value)
                value.sctlr_transition_diagnostic.schema_version = 1
                value.sctlr_transition_diagnostic.sampled_mask = 1
                value.sctlr_transition_diagnostic.source_pre_entry_read_entries = 1
                value.sctlr_transition_diagnostic.source_pre_entry_read_status = -1
                value.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
                value.sctlr_transition_diagnostic.requested = 0x30d0_0980
            }),
            ("post-failure-stage", "malformed.sctlr_transition.post_exit_failure_chronology", { value in
                self.setCheckpointNotEvaluated(&value)
                value.sctlr_transition_diagnostic.sampled_mask = 3
                value.sctlr_transition_diagnostic.source_post_exit_read_status = -1
                value.sctlr_transition_diagnostic.source_post_exit = 0
            }),
            ("inactive-payload", "malformed.sctlr_transition.inactive_payload", { value in
                value.failure_stage = 4
                self.setCheckpointNotEvaluated(&value)
                self.setSCTLRTransitionZero(&value)
                value.sctlr_transition_diagnostic.requested = 1
                value.source.run_entries = 0
                value.source.run_status = Int32.min
            }),
            ("pre-unentered-status", "malformed.sctlr_transition.pre_entry_unentered_status", { value in
                value.failure_stage = 7
                self.setCheckpointNotEvaluated(&value)
                self.setSCTLRTransitionZero(&value)
                value.sctlr_transition_diagnostic.schema_version = 1
                value.sctlr_transition_diagnostic.sampled_mask = 1
                value.sctlr_transition_diagnostic.source_pre_entry_read_status = 0
                value.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
                value.sctlr_transition_diagnostic.requested = 0x30d0_0980
                value.source.run_entries = 0
                value.source.run_status = Int32.min
            }),
            ("pre-unsampled-value", "malformed.sctlr_transition.pre_entry_unsampled_value", { value in
                value.failure_stage = 7
                self.setCheckpointNotEvaluated(&value)
                self.setSCTLRTransitionZero(&value)
                value.sctlr_transition_diagnostic.schema_version = 1
                value.sctlr_transition_diagnostic.sampled_mask = 1
                value.sctlr_transition_diagnostic.source_pre_entry_read_status = Int32.min
                value.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
                value.sctlr_transition_diagnostic.requested = 0x30d0_0980
                value.sctlr_transition_diagnostic.source_pre_entry = 1
                value.source.run_entries = 0
                value.source.run_status = Int32.min
            }),
            ("pre-failure-status", "malformed.sctlr_transition.pre_entry_failure_status", { value in
                value.failure_stage = 7
                self.setCheckpointNotEvaluated(&value)
                self.setSCTLRTransitionZero(&value)
                value.sctlr_transition_diagnostic.schema_version = 1
                value.sctlr_transition_diagnostic.sampled_mask = 1
                value.sctlr_transition_diagnostic.source_pre_entry_read_entries = 1
                value.sctlr_transition_diagnostic.source_pre_entry_read_status = 0
                value.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
                value.sctlr_transition_diagnostic.requested = 0x30d0_0980
                value.source.run_entries = 0
                value.source.run_status = Int32.min
            }),
            ("pre-failed-value", "malformed.sctlr_transition.pre_entry_failed_value", { value in
                value.failure_stage = 7
                self.setCheckpointNotEvaluated(&value)
                self.setSCTLRTransitionZero(&value)
                value.sctlr_transition_diagnostic.schema_version = 1
                value.sctlr_transition_diagnostic.sampled_mask = 1
                value.sctlr_transition_diagnostic.source_pre_entry_read_entries = 1
                value.sctlr_transition_diagnostic.source_pre_entry_read_status = -1
                value.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
                value.sctlr_transition_diagnostic.requested = 0x30d0_0980
                value.sctlr_transition_diagnostic.source_pre_entry = 1
                value.source.run_entries = 0
                value.source.run_status = Int32.min
            }),
            ("post-unentered-status", "malformed.sctlr_transition.post_exit_unentered_status", { value in
                value.failure_stage = 9
                self.setCheckpointNotEvaluated(&value)
                value.sctlr_transition_diagnostic.sampled_mask = 3
                value.sctlr_transition_diagnostic.source_post_exit_read_entries = 0
                value.sctlr_transition_diagnostic.source_post_exit_read_status = 0
                value.sctlr_transition_diagnostic.source_post_exit = 0
                value.source.run_status = -1
            }),
            ("post-unsampled-value", "malformed.sctlr_transition.post_exit_unsampled_value", { value in
                value.failure_stage = 9
                self.setCheckpointNotEvaluated(&value)
                value.sctlr_transition_diagnostic.sampled_mask = 3
                value.sctlr_transition_diagnostic.source_post_exit_read_entries = 0
                value.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
                value.sctlr_transition_diagnostic.source_post_exit = 1
                value.source.run_status = -1
            }),
            ("post-failure-status", "malformed.sctlr_transition.post_exit_failure_status", { value in
                value.failure_stage = 10
                self.setCheckpointNotEvaluated(&value)
                value.sctlr_transition_diagnostic.sampled_mask = 3
                value.sctlr_transition_diagnostic.source_post_exit_read_entries = 1
                value.sctlr_transition_diagnostic.source_post_exit_read_status = 0
                value.sctlr_transition_diagnostic.source_post_exit = 0
            }),
            ("post-failed-value", "malformed.sctlr_transition.post_exit_failed_value", { value in
                value.failure_stage = 10
                self.setCheckpointNotEvaluated(&value)
                value.sctlr_transition_diagnostic.sampled_mask = 3
                value.sctlr_transition_diagnostic.source_post_exit_read_entries = 1
                value.sctlr_transition_diagnostic.source_post_exit_read_status = -1
                value.sctlr_transition_diagnostic.source_post_exit = 1
            }),
            ("successful-run-without-full", "malformed.sctlr_transition.successful_run_without_full_transition", { value in
                value.failure_stage = 10
                self.setCheckpointNotEvaluated(&value)
                value.sctlr_transition_diagnostic.sampled_mask = 3
                value.sctlr_transition_diagnostic.source_post_exit_read_entries = 0
                value.sctlr_transition_diagnostic.source_post_exit_read_status = Int32.min
                value.sctlr_transition_diagnostic.source_post_exit = 0
            }),
        ]
        for (index, item) in mutations.enumerated() {
            var value = try fullFailure()
            item.2(&value)
            let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure(item.0))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.classification, "NATIVE_WITNESS_MALFORMED",
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.sctlrTransitionIntegrity, "MALFORMED",
                           line: UInt(index + 1))
            XCTAssertTrue(diagnostic.sctlrTransitionFailures.contains(item.1),
                          line: UInt(index + 1))
            XCTAssertTrue(diagnostic.rendered.contains("sctlr.transition"),
                          line: UInt(index + 1))
            assertNoAuthority(result, line: UInt(index + 1))
        }
    }

    func testSCTLRTransitionRawRenderingPrecedesEveryDerivedValue() throws {
        let value = makeSCTLRCheckpointFailure(try fixture(),
            pre: 0x30d0_0800, post: 0x30d0_0800)
        let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("render-order"))
        let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
        let rendered = diagnostic.rendered
        let raw = try XCTUnwrap(rendered.range(of: "sctlr.transition schema="))
        let xor = try XCTUnwrap(rendered.range(of: "derived sctlr.requested_xor_pre_entry="))
        let classification = try XCTUnwrap(rendered.range(of: "derived classification="))
        XCTAssertLessThan(raw.lowerBound, xor.lowerBound)
        XCTAssertLessThan(xor.lowerBound, classification.lowerBound)
        XCTAssertTrue(rendered.contains("requested=818940288/0x0000000030d00980"))
        XCTAssertTrue(rendered.contains("source_pre_entry=818939904/0x0000000030d00800"))
        assertNoAuthority(result)
    }

    func testCheckpointHiddenSequenceFailureIsLocalizedWithoutAuthority() throws {
        var value = makeCheckpointFailure(try fixture())
        value.checkpoint_diagnostic.checkpoint_sequence = 2
        value.checkpoint_diagnostic.passed_mask &=
            ~(UInt32(EPR_GUEST_H3_CP_SEQUENCE) | UInt32(EPR_GUEST_H3_CP_REPLY_PAGE))
        value.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = 0
        value.checkpoint_diagnostic.page_witnesses.2.observed_byte = 2
        value.checkpoint_diagnostic.page_witnesses.2.expected_byte = 1
        let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("sequence"))
        let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
        XCTAssertEqual(diagnostic.checkpointIntegrity, "VALID_FAILURE")
        XCTAssertEqual(diagnostic.checkpointFailures,
                       ["checkpoint.sequence", "checkpoint.reply_page"])
        XCTAssertEqual(diagnostic.checkpoint.checkpointSequence, 2)
        assertNoAuthority(result)
    }

    func testEveryHiddenPredicateHasAnExactFailureProjection() throws {
        let cases: [(String, (inout EPRGuestH3CursorResumeResult) -> Void)] = [
            ("code", { value in
                value.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_CODE_PAGE)
                value.checkpoint_diagnostic.page_witnesses.0.first_mismatch_offset = 0
                value.checkpoint_diagnostic.page_witnesses.0.observed_byte = 1
                value.checkpoint_diagnostic.page_witnesses.0.expected_byte = 0
            }),
            ("request", { value in
                value.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_REQUEST_PAGE)
                value.checkpoint_diagnostic.page_witnesses.1.first_mismatch_offset = 32
                value.checkpoint_diagnostic.page_witnesses.1.observed_byte = 1
                value.checkpoint_diagnostic.page_witnesses.1.expected_byte = 0
            }),
            ("reply", { value in
                value.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_REPLY_PAGE)
                value.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = 24
                value.checkpoint_diagnostic.page_witnesses.2.observed_byte = 1
                value.checkpoint_diagnostic.page_witnesses.2.expected_byte = 0
            }),
            ("cpsr", { value in
                value.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_CPSR)
                value.checkpoint_diagnostic.cpsr ^= 1
            }),
            ("sctlr", { value in
                value.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_SCTLR)
                value.checkpoint_diagnostic.sctlr ^= 1
                value.sctlr_transition_diagnostic.source_post_exit =
                    value.checkpoint_diagnostic.sctlr
            }),
            ("sp", { value in
                value.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_SP)
                value.checkpoint_diagnostic.sp ^= 1
            }),
            ("vbar", { value in
                value.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_VBAR)
                value.checkpoint_diagnostic.vbar = 1
            }),
        ]
        let expected = ["checkpoint.code_page", "checkpoint.request_page",
                        "checkpoint.reply_page", "checkpoint.cpsr", "checkpoint.sctlr",
                        "checkpoint.sp", "checkpoint.vbar"]
        for (index, item) in cases.enumerated() {
            var value = makeCheckpointFailure(try fixture())
            item.1(&value)
            let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure(item.0))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.classification, "NATIVE_NONPASS", line: UInt(index + 1))
            XCTAssertEqual(diagnostic.checkpointIntegrity, "VALID_FAILURE", line: UInt(index + 1))
            XCTAssertEqual(diagnostic.checkpointFailures, [expected[index]], line: UInt(index + 1))
            assertNoAuthority(result, line: UInt(index + 1))
        }
        // Sequence is coupled to the reply-page witness, and GPRs are covered
        // independently by the 31-index matrix.
    }

    func testCheckpointGPRMismatchMaskCoversEveryRegister() throws {
        for index in 0..<31 {
            var value = makeCheckpointFailure(try fixture())
            withUnsafeMutableBytes(of: &value.checkpoint_diagnostic.gprs) { bytes in
                bytes.bindMemory(to: UInt64.self)[index] ^= 1
            }
            value.checkpoint_diagnostic.gpr_mismatch_mask = UInt32(1) << UInt32(index)
            value.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_GPRS)
            let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("gpr-\(index)"))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.checkpointIntegrity, "VALID_FAILURE", line: UInt(index + 1))
            XCTAssertEqual(diagnostic.checkpointFailures, ["checkpoint.gprs"], line: UInt(index + 1))
            XCTAssertEqual(diagnostic.checkpoint.gprMismatchMask,
                           UInt32(1) << UInt32(index), line: UInt(index + 1))
            assertNoAuthority(result, line: UInt(index + 1))
        }
    }

    func testCheckpointPageWitnessRetainsLowestMismatchBytes() throws {
        var value = makeCheckpointFailure(try fixture())
        value.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_REQUEST_PAGE)
        value.checkpoint_diagnostic.page_witnesses.1.first_mismatch_offset = 32
        value.checkpoint_diagnostic.page_witnesses.1.observed_byte = 7
        value.checkpoint_diagnostic.page_witnesses.1.expected_byte = 0
        let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("page"))
        let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
        XCTAssertEqual(diagnostic.checkpointIntegrity, "VALID_FAILURE")
        XCTAssertEqual(diagnostic.checkpointFailures, ["checkpoint.request_page"])
        XCTAssertEqual(diagnostic.checkpoint.pages[1].firstMismatchOffset, 32)
        XCTAssertEqual(diagnostic.checkpoint.pages[1].observedByte, 7)
        XCTAssertEqual(diagnostic.checkpoint.pages[1].expectedByte, 0)
        assertNoAuthority(result)
    }

    func testExposedCountFailureJoinsFullHiddenPassMask() throws {
        var value = makeCheckpointFailure(try fixture())
        value.source.register_read_calls = 35
        let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("count"))
        let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
        XCTAssertEqual(diagnostic.checkpoint.passedMask, 0x1ff)
        XCTAssertEqual(diagnostic.checkpointIntegrity, "VALID_FAILURE")
        XCTAssertEqual(diagnostic.checkpointFailures, ["checkpoint.register_read_calls"])
        assertNoAuthority(result)
    }

    func testFullHiddenWitnessAfterTrapFailureIsMalformed() throws {
        var value = makeCheckpointFailure(try fixture())
        value.source.pc = 0x1000_0054
        let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("trap-full"))
        let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
        XCTAssertEqual(diagnostic.checkpoint.passedMask, 0x1ff)
        XCTAssertEqual(diagnostic.classification, "NATIVE_WITNESS_MALFORMED")
        XCTAssertEqual(diagnostic.checkpointIntegrity, "MALFORMED")
        XCTAssertEqual(diagnostic.checkpointFailures,
                       ["malformed.evaluated_after_trap_failure", "trap.pc"])
        assertNoAuthority(result)
    }

    func testTrapFailureMayRejectBeforeHiddenWitnessEvaluation() throws {
        var value = makeCheckpointFailure(try fixture())
        value.checkpoint_diagnostic = EPRGuestH3CheckpointDiagnostic()
        value.checkpoint_diagnostic.schema_version = 1
        value.checkpoint_diagnostic.required_mask = 0x1ff
        value.checkpoint_diagnostic.page_witnesses.0.first_mismatch_offset = UInt32.max
        value.checkpoint_diagnostic.page_witnesses.1.first_mismatch_offset = UInt32.max
        value.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = UInt32.max
        value.source.pc = 0x1000_0054
        let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("trap"))
        let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
        XCTAssertEqual(diagnostic.checkpointIntegrity, "VALID_FAILURE")
        XCTAssertEqual(diagnostic.checkpointFailures, ["trap.pc"])
        XCTAssertEqual(diagnostic.checkpoint.evaluatedMask, 0)
        assertNoAuthority(result)
    }

    func testMalformedCheckpointWitnessPreservesRawValuesAndNoAuthority() throws {
        var value = makeCheckpointFailure(try fixture())
        value.checkpoint_diagnostic.checkpoint_sequence = 2
        // Deliberately leave the sequence PASS bit set: raw witness contradicts itself.
        let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("malformed"))
        let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
        XCTAssertEqual(diagnostic.classification, "NATIVE_WITNESS_MALFORMED")
        XCTAssertEqual(result.verificationDisposition, "NATIVE_WITNESS_MALFORMED")
        XCTAssertEqual(diagnostic.checkpointIntegrity, "MALFORMED")
        XCTAssertTrue(diagnostic.checkpointFailures.contains("malformed.passed_mask"))
        XCTAssertEqual(diagnostic.checkpoint.checkpointSequence, 2)
        XCTAssertTrue(diagnostic.rendered.contains("checkpoint.sequence=2"))
        assertNoAuthority(result)
    }

    func testEarlyFailureRetainsCanonicalNotEvaluatedWitness() throws {
        var value = makeCheckpointFailure(try fixture())
        value.failure_stage = 4
        value.first_error = -1
        value.checkpoint_diagnostic = EPRGuestH3CheckpointDiagnostic()
        value.checkpoint_diagnostic.schema_version = 1
        value.checkpoint_diagnostic.required_mask = 0x1ff
        value.checkpoint_diagnostic.page_witnesses.0.first_mismatch_offset = UInt32.max
        value.checkpoint_diagnostic.page_witnesses.1.first_mismatch_offset = UInt32.max
        value.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = UInt32.max
        let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("early"))
        let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
        XCTAssertEqual(diagnostic.classification, "NATIVE_NONPASS")
        XCTAssertEqual(diagnostic.checkpointIntegrity, "VALID_NOT_EVALUATED")
        XCTAssertTrue(diagnostic.checkpointFailures.isEmpty)
        assertNoAuthority(result)
    }

    func testCheckpointEvaluationChronologyRejectsImpossibleStageJoins() throws {
        for stage in [Int32(1), 11, 12] {
            var value = try fixture()
            value.outcome = UInt32(EPR_GUEST_FAILED)
            value.execution_pass = 0
            value.failure_stage = stage
            value.first_error = EPROTO
            let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("full-stage-\(stage)"))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.classification, "NATIVE_WITNESS_MALFORMED",
                           line: UInt(stage))
            XCTAssertEqual(diagnostic.checkpointIntegrity, "MALFORMED", line: UInt(stage))
            assertNoAuthority(result, line: UInt(stage))
        }

        for stage in [Int32(14), 15, 16, 17, 19, 20, 21, 22, 23] {
            var value = makeCheckpointFailure(try fixture())
            value.failure_stage = stage
            value.checkpoint_diagnostic = EPRGuestH3CheckpointDiagnostic()
            value.checkpoint_diagnostic.schema_version = 1
            value.checkpoint_diagnostic.required_mask = 0x1ff
            value.checkpoint_diagnostic.page_witnesses.0.first_mismatch_offset = UInt32.max
            value.checkpoint_diagnostic.page_witnesses.1.first_mismatch_offset = UInt32.max
            value.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = UInt32.max
            let result = GuestH3LiveVerifier.rejected(value,
                ProvenanceFailure("empty-stage-\(stage)"))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.classification, "NATIVE_WITNESS_MALFORMED",
                           line: UInt(stage))
            XCTAssertTrue(diagnostic.checkpointFailures.contains(
                "malformed.not_evaluated_after_checkpoint_stage"), line: UInt(stage))
            assertNoAuthority(result, line: UInt(stage))
        }
    }

    func testMalformedCheckpointWitnessMatrixNeverSuppressesRawData() throws {
        func validFailure() throws -> EPRGuestH3CursorResumeResult {
            var value = makeCheckpointFailure(try fixture())
            value.checkpoint_diagnostic.checkpoint_sequence = 2
            value.checkpoint_diagnostic.passed_mask &=
                ~(UInt32(EPR_GUEST_H3_CP_SEQUENCE) | UInt32(EPR_GUEST_H3_CP_REPLY_PAGE))
            value.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = 0
            value.checkpoint_diagnostic.page_witnesses.2.observed_byte = 2
            value.checkpoint_diagnostic.page_witnesses.2.expected_byte = 1
            return value
        }
        let mutations: [(String, (inout EPRGuestH3CursorResumeResult) -> Void)] = [
            ("schema", { $0.checkpoint_diagnostic.schema_version = 2 }),
            ("required", { $0.checkpoint_diagnostic.required_mask = 0xff }),
            ("partial", { $0.checkpoint_diagnostic.evaluated_mask = 0xff }),
            ("outside", { $0.checkpoint_diagnostic.passed_mask |= 1 << 31 }),
            ("reserved", { $0.checkpoint_diagnostic.reserved_zero = 1 }),
            ("page-reserved", { $0.checkpoint_diagnostic.page_witnesses.0.reserved_zero = 1 }),
            ("page-offset", {
                $0.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_CODE_PAGE)
                $0.checkpoint_diagnostic.page_witnesses.0.first_mismatch_offset = 16_384
            }),
            ("page-sentinel", { $0.checkpoint_diagnostic.page_witnesses.0.observed_byte = 1 }),
            ("page-equal", {
                $0.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_CODE_PAGE)
                $0.checkpoint_diagnostic.page_witnesses.0.first_mismatch_offset = 32
            }),
            ("page-expected", {
                $0.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_CODE_PAGE)
                $0.checkpoint_diagnostic.page_witnesses.0.first_mismatch_offset = 32
                $0.checkpoint_diagnostic.page_witnesses.0.observed_byte = 1
                $0.checkpoint_diagnostic.page_witnesses.0.expected_byte = 2
            }),
            ("gpr-mask", { $0.checkpoint_diagnostic.gpr_mismatch_mask = 1 }),
            ("gpr-bit31", { $0.checkpoint_diagnostic.gpr_mismatch_mask = 1 << 31 }),
            ("sequence-reply", {
                $0.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = UInt32.max
                $0.checkpoint_diagnostic.page_witnesses.2.observed_byte = 0
                $0.checkpoint_diagnostic.page_witnesses.2.expected_byte = 0
            }),
            ("reply-sequence", {
                $0.checkpoint_diagnostic.checkpoint_sequence = 1
                $0.checkpoint_diagnostic.passed_mask |= UInt32(EPR_GUEST_H3_CP_SEQUENCE)
                // Keep the offset-zero reply mismatch: impossible when the
                // independently loaded little-endian sequence is exactly one.
            }),
        ]
        for (index, item) in mutations.enumerated() {
            var value = try validFailure()
            item.1(&value)
            let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure(item.0))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(diagnostic.classification, "NATIVE_WITNESS_MALFORMED",
                           line: UInt(index + 1))
            XCTAssertEqual(diagnostic.checkpointIntegrity, "MALFORMED", line: UInt(index + 1))
            XCTAssertTrue(diagnostic.rendered.contains("checkpoint.witness"), line: UInt(index + 1))
            assertNoAuthority(result, line: UInt(index + 1))
        }
    }

    func testEveryNativeFailureStageSurvivesDiagnosticProjection() throws {
        let names = [
            "none", "self-admission", "clock", "private-memory", "vm-create", "vm-map",
            "vcpu-create", "register-configuration", "watchdog", "vcpu-run",
            "exit-registers", "terminal-predicates", "snapshot-merkle", "watchdog-join",
            "vcpu-destroy", "vm-unmap", "vm-destroy", "host-unmap", "cancellation",
            "h3-cursor-capture", "h3-source-conservation", "h3-cursor-decode",
            "h3-restore", "h3-terminal",
        ]
        for stage in 0..<names.count {
            var value = try fixture()
            value.outcome = UInt32(EPR_GUEST_FAILED)
            value.execution_pass = 0
            value.failure_stage = Int32(stage)
            if stage == 11 {
                value.checkpoint_valid = 0
                value.checkpoint_diagnostic.checkpoint_sequence = 2
                value.checkpoint_diagnostic.passed_mask &=
                    ~(UInt32(EPR_GUEST_H3_CP_SEQUENCE) | UInt32(EPR_GUEST_H3_CP_REPLY_PAGE))
                value.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = 0
                value.checkpoint_diagnostic.page_witnesses.2.observed_byte = 2
                value.checkpoint_diagnostic.page_witnesses.2.expected_byte = 1
            }
            value.first_error = Int32(-10_000 - stage)
            let result = GuestH3LiveVerifier.rejected(
                value, ProvenanceFailure("fabricated-stage-\(stage)"))
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(result.status, "FAIL", line: UInt(stage + 1))
            let classification = stage == 0 || stage == 1 || stage == 12
                ? "NATIVE_WITNESS_MALFORMED" : "NATIVE_NONPASS"
            XCTAssertEqual(result.verificationDisposition, classification, line: UInt(stage + 1))
            XCTAssertEqual(diagnostic.classification, classification, line: UInt(stage + 1))
            XCTAssertEqual(diagnostic.failureStage, Int32(stage), line: UInt(stage + 1))
            XCTAssertEqual(diagnostic.failureStageName, names[stage], line: UInt(stage + 1))
            XCTAssertEqual(diagnostic.firstError, Int32(-10_000 - stage), line: UInt(stage + 1))
            assertNoAuthority(result, line: UInt(stage + 1))
        }
    }

    func testNativeDiagnosticCopiesEveryStatusCounterAndFrameExactly() throws {
        var value = try fixture()
        value.abi_version = 31
        value.outcome = UInt32(EPR_GUEST_FAILED)
        value.execution_pass = 32
        value.teardown_pass = 33
        value.signing_admitted = 34
        value.cursor_sealed = 35
        value.cursor_decoded = 36
        value.cursor_restored = 37
        value.cursor_evidence.byte_count = 48
        value.checkpoint_valid = 38
        value.terminal_valid = 39
        value.source_conserved = 40
        value.target_conserved = 41
        value.cancellation_requested = 42
        value.cancellation_calls = 43
        value.watchdog_fired = 44
        value.watchdog_create_entries = 45
        value.watchdog_join_entries = 46
        value.resources_quarantined = 47
        value.failure_stage = 4
        value.first_error = -7001
        value.signing_error = -7002
        value.cancellation_status = Int32.min
        value.watchdog_create_status = -7003
        value.watchdog_join_status = -7004
        value.watchdog_wait_status = -7005
        value.start_ticks = 101
        value.end_ticks = 202
        value.timebase_numer = 125
        value.timebase_denom = 3
        value.source.run_entries = 11
        value.source.mappings_entered = 12
        value.source.register_set_calls = 13
        value.source.register_read_calls = 14
        value.source.conserved = 15
        value.source.vm_create_status = -101
        value.source.map_status = (-102, -103, -104)
        value.source.vcpu_create_status = -105
        value.source.register_status = -106
        value.source.run_status = -107
        value.source.read_register_status = -108
        value.source.vcpu_destroy_status = -109
        value.source.unmap_status = (-110, -111, -112)
        value.source.vm_destroy_status = -113
        value.source.host_unmap_status = (-114, -115, Int32.min)
        value.source.entry_ticks = 301
        value.source.exit_ticks = 302
        value.source.exception_reason = 303
        value.source.syndrome = 304
        value.source.pc = 305
        value.source.fault_ipa = 306
        value.source.fault_virtual_address = 307
        value.source.x4 = 308
        value.target.run_entries = 21
        value.target.mappings_entered = 22
        value.target.register_set_calls = 23
        value.target.register_read_calls = 24
        value.target.conserved = 25
        value.target.vm_create_status = -201
        value.target.map_status = (-202, -203, -204)
        value.target.vcpu_create_status = -205
        value.target.register_status = -206
        value.target.run_status = -207
        value.target.read_register_status = -208
        value.target.vcpu_destroy_status = -209
        value.target.unmap_status = (-210, -211, -212)
        value.target.vm_destroy_status = -213
        value.target.host_unmap_status = (-214, -215, -216)
        value.target.entry_ticks = 401
        value.target.exit_ticks = 402
        value.target.exception_reason = 403
        value.target.syndrome = 404
        value.target.pc = 405
        value.target.fault_ipa = 406
        value.target.fault_virtual_address = 407
        value.target.x4 = 408

        let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("exact-copy"))
        let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
        XCTAssertEqual(diagnostic.verifierError, "exact-copy")
        XCTAssertEqual(diagnostic.abiVersion, 31)
        XCTAssertEqual(diagnostic.outcome, UInt32(EPR_GUEST_FAILED))
        XCTAssertEqual(diagnostic.executionPass, 32)
        XCTAssertEqual(diagnostic.teardownPass, 33)
        XCTAssertEqual(diagnostic.signingAdmitted, 34)
        XCTAssertEqual(diagnostic.cursorSealed, 35)
        XCTAssertEqual(diagnostic.cursorDecoded, 36)
        XCTAssertEqual(diagnostic.cursorRestored, 37)
        XCTAssertEqual(diagnostic.cursorEvidenceByteCount, 48)
        XCTAssertEqual(diagnostic.checkpointValid, 38)
        XCTAssertEqual(diagnostic.terminalValid, 39)
        XCTAssertEqual(diagnostic.sourceConserved, 40)
        XCTAssertEqual(diagnostic.targetConserved, 41)
        XCTAssertEqual(diagnostic.cancellationRequested, 42)
        XCTAssertEqual(diagnostic.cancellationCalls, 43)
        XCTAssertEqual(diagnostic.watchdogFired, 44)
        XCTAssertEqual(diagnostic.watchdogCreateEntries, 45)
        XCTAssertEqual(diagnostic.watchdogJoinEntries, 46)
        XCTAssertEqual(diagnostic.resourcesQuarantined, 47)
        XCTAssertEqual(diagnostic.failureStageName, "vm-create")
        XCTAssertEqual(diagnostic.firstError, -7001)
        XCTAssertEqual(diagnostic.signingError, -7002)
        XCTAssertEqual(diagnostic.cancellationStatus, Int32.min)
        XCTAssertEqual(diagnostic.watchdogCreateStatus, -7003)
        XCTAssertEqual(diagnostic.watchdogJoinStatus, -7004)
        XCTAssertEqual(diagnostic.watchdogWaitStatus, -7005)
        XCTAssertEqual(diagnostic.startTicks, 101)
        XCTAssertEqual(diagnostic.endTicks, 202)
        XCTAssertEqual(diagnostic.timebaseNumer, 125)
        XCTAssertEqual(diagnostic.timebaseDenom, 3)
        XCTAssertEqual(diagnostic.source.generation, sourceGeneration)
        XCTAssertEqual(diagnostic.source.runEntries, 11)
        XCTAssertEqual(diagnostic.source.mappingsEntered, 12)
        XCTAssertEqual(diagnostic.source.registerSetCalls, 13)
        XCTAssertEqual(diagnostic.source.registerReadCalls, 14)
        XCTAssertEqual(diagnostic.source.conserved, 15)
        XCTAssertEqual(diagnostic.source.vmCreateStatus, -101)
        XCTAssertEqual(diagnostic.source.mapStatuses, [-102, -103, -104])
        XCTAssertEqual(diagnostic.source.vcpuCreateStatus, -105)
        XCTAssertEqual(diagnostic.source.registerStatus, -106)
        XCTAssertEqual(diagnostic.source.runStatus, -107)
        XCTAssertEqual(diagnostic.source.readRegisterStatus, -108)
        XCTAssertEqual(diagnostic.source.vcpuDestroyStatus, -109)
        XCTAssertEqual(diagnostic.source.unmapStatuses, [-110, -111, -112])
        XCTAssertEqual(diagnostic.source.vmDestroyStatus, -113)
        XCTAssertEqual(diagnostic.source.hostUnmapStatuses, [-114, -115, Int32.min])
        XCTAssertEqual(diagnostic.source.exitTicks, 302)
        XCTAssertEqual(diagnostic.source.exceptionReason, 303)
        XCTAssertEqual(diagnostic.source.syndrome, 304)
        XCTAssertEqual(diagnostic.source.pc, 305)
        XCTAssertEqual(diagnostic.source.faultIPA, 306)
        XCTAssertEqual(diagnostic.source.faultVirtualAddress, 307)
        XCTAssertEqual(diagnostic.target.generation, targetGeneration)
        XCTAssertEqual(diagnostic.target.runEntries, 21)
        XCTAssertEqual(diagnostic.target.mappingsEntered, 22)
        XCTAssertEqual(diagnostic.target.registerSetCalls, 23)
        XCTAssertEqual(diagnostic.target.registerReadCalls, 24)
        XCTAssertEqual(diagnostic.target.conserved, 25)
        XCTAssertEqual(diagnostic.target.vmCreateStatus, -201)
        XCTAssertEqual(diagnostic.target.mapStatuses, [-202, -203, -204])
        XCTAssertEqual(diagnostic.target.vcpuCreateStatus, -205)
        XCTAssertEqual(diagnostic.target.registerStatus, -206)
        XCTAssertEqual(diagnostic.target.runStatus, -207)
        XCTAssertEqual(diagnostic.target.readRegisterStatus, -208)
        XCTAssertEqual(diagnostic.target.vcpuDestroyStatus, -209)
        XCTAssertEqual(diagnostic.target.unmapStatuses, [-210, -211, -212])
        XCTAssertEqual(diagnostic.target.vmDestroyStatus, -213)
        XCTAssertEqual(diagnostic.target.hostUnmapStatuses, [-214, -215, -216])
        XCTAssertEqual(diagnostic.source.entryTicks, 301)
        XCTAssertEqual(diagnostic.source.x4, 308)
        XCTAssertEqual(diagnostic.target.entryTicks, 401)
        XCTAssertEqual(diagnostic.target.exitTicks, 402)
        XCTAssertEqual(diagnostic.target.exceptionReason, 403)
        XCTAssertEqual(diagnostic.target.syndrome, 404)
        XCTAssertEqual(diagnostic.target.pc, 405)
        XCTAssertEqual(diagnostic.target.faultIPA, 406)
        XCTAssertEqual(diagnostic.target.faultVirtualAddress, 407)
        XCTAssertEqual(diagnostic.target.x4, 408)
        XCTAssertTrue(diagnostic.rendered.contains("-214, -215, -216"))
        XCTAssertTrue(diagnostic.rendered.contains(String(Int32.min)))
        assertNoAuthority(result)
    }

    func testNativePassWithHostileEvidenceIsASeparateSwiftReconstructionRejection() throws {
        var value = try fixture()
        value.cursor_evidence.bytes.0 ^= 1
        do {
            _ = try GuestH3LiveVerifier.verify(value)
            XCTFail("hostile evidence unexpectedly passed")
        } catch {
            let result = GuestH3LiveVerifier.rejected(value, error)
            let diagnostic = try XCTUnwrap(result.nativeDiagnostic)
            XCTAssertEqual(result.verificationDisposition, "SWIFT_RECONSTRUCTION_REJECTION")
            XCTAssertEqual(diagnostic.classification, "SWIFT_RECONSTRUCTION_REJECTION")
            XCTAssertEqual(diagnostic.outcome, UInt32(EPR_GUEST_PASS))
            XCTAssertEqual(diagnostic.failureStage, 0)
            XCTAssertEqual(diagnostic.failureStageName, "none")
            assertNoAuthority(result)
        }
    }

    func testPreNativeAndCancellationPresentationsContainNoNativeDiagnostic() {
        let rejected = GuestH3LiveVerifier.rejected(ProvenanceFailure("pre-native"))
        XCTAssertEqual(rejected.verificationDisposition, "PRE_NATIVE_REJECTION")
        XCTAssertNil(rejected.nativeDiagnostic)
        assertNoAuthority(rejected)
        let canceled = GuestH3LiveVerifier.canceledBeforeNativeEntry()
        XCTAssertEqual(canceled.verificationDisposition, "CANCELED_BEFORE_NATIVE_ENTRY")
        XCTAssertNil(canceled.nativeDiagnostic)
        assertNoAuthority(canceled)
    }

    func testNativeOutcomeLabelsAndQuarantineAreFailClosed() throws {
        let cases: [(UInt32, String, Bool)] = [
            (UInt32(EPR_GUEST_NOT_ENTERED), "INCOMPLETE", false),
            (UInt32(EPR_GUEST_FAILED), "FAIL", false),
            (UInt32(EPR_GUEST_CANCELED), "CANCELED", false),
            (UInt32(EPR_GUEST_BUSY), "BUSY", false),
            (UInt32(EPR_GUEST_QUARANTINED), "QUARANTINED", true),
        ]
        // These are outcome substitutions on a full, stage-zero PASS-shaped witness.
        for (index, item) in cases.enumerated() {
            var value = try fixture()
            value.outcome = item.0
            value.execution_pass = 0
            value.teardown_pass = 1
            value.resources_quarantined = 0
            let result = GuestH3LiveVerifier.rejected(value, ProvenanceFailure("outcome"))
            XCTAssertEqual(result.status, item.1, line: UInt(index + 1))
            XCTAssertEqual(result.verificationDisposition, "NATIVE_WITNESS_MALFORMED",
                           line: UInt(index + 1))
            XCTAssertEqual(result.quarantined, item.2, line: UInt(index + 1))
            assertNoAuthority(result, line: UInt(index + 1))
        }

        var malformed = try fixture()
        malformed.outcome = UInt32(EPR_GUEST_FAILED)
        malformed.execution_pass = 0
        malformed.teardown_pass = 1
        malformed.resources_quarantined = 2
        let rejected = GuestH3LiveVerifier.rejected(malformed, ProvenanceFailure("flag"))
        XCTAssertTrue(rejected.quarantined)
        assertNoAuthority(rejected)
    }

    func testExactFabricatedValuePassesPureReconstruction() throws {
        let native = try fixture()
        let result = try GuestH3LiveVerifier.verify(native)
        XCTAssertEqual(result.status, "PASS")
        XCTAssertEqual(result.gateE, "ABSTAIN")
        XCTAssertEqual(result.authorityVector, "00000000")
        XCTAssertFalse(result.quarantined)
        XCTAssertFalse(result.durable)
        XCTAssertFalse(result.h4Entered)
        XCTAssertEqual(result.projectionRoot.count, 64)
        XCTAssertEqual(result.graphRoot.count, 64)
        let projection = try GuestH3LiveVerifier.projectionForTesting(native)
        XCTAssertEqual(try XCTUnwrap(result.receipt), projection)
        try GuestH3LiveVerifier.verifyProjectionForTesting(projection, native: native)
        XCTAssertEqual(result.projectionRoot, projection.root)
        XCTAssertEqual(result.graphRoot, projection.graph.root)
        XCTAssertEqual(try StageCanonicalJSON.decode(projection.state.json),
                       try GuestCBOR.decode(projection.state.cbor))
        XCTAssertEqual(try StageCanonicalJSON.decode(projection.graph.json),
                       try GuestCBOR.decode(projection.graph.cbor))
    }

    func testLiveProjectionRejectsCrossStreamSubstitutionWithResealedRoots() throws {
        let native = try fixture()
        let receipt = try GuestH3LiveVerifier.projectionForTesting(native)
        var state = try semanticMap(StageCanonicalJSON.decode(receipt.state.json))
        state["status"] = .text("FAIL")
        let hostileJSON = try StageCanonicalJSON.encode(.map(state))
        let crossed = try liveProjection(json: hostileJSON, cbor: receipt.state.cbor,
                                         schema: GuestH3LiveVerifier.liveStateSchema,
                                         role: "state")
        assertProjectionRejected(try reroot(crossed, receipt.graph, native: native), native: native)
    }

    func testOnlyVerifiedPassRetainsInspectableReceiptBytes() throws {
        var native = try fixture()
        let presentation = try GuestH3LiveVerifier.verify(native)
        let retained = try XCTUnwrap(presentation.receipt)
        // The UI holds owned value bytes, not a pointer into a native result.
        native.cursor_evidence.byte_count = 0
        XCTAssertEqual(presentation.receipt, retained)
        XCTAssertFalse(retained.state.json.isEmpty)
        XCTAssertFalse(retained.state.cbor.isEmpty)
        XCTAssertFalse(retained.graph.json.isEmpty)
        XCTAssertFalse(retained.graph.cbor.isEmpty)
        XCTAssertEqual(presentation.projectionRoot, retained.root)
        for rejected in [
            GuestH3LiveVerifier.rejected(native, ProvenanceFailure("hostile native PASS")),
            GuestH3LiveVerifier.rejected(makeCheckpointFailure(try fixture()), ProvenanceFailure("checkpoint")),
            GuestH3LiveVerifier.rejected(ProvenanceFailure("before native")),
            GuestH3LiveVerifier.canceledBeforeNativeEntry()
        ] {
            XCTAssertNil(rejected.receipt)
            assertNoAuthority(rejected)
        }
    }

    private func withLiveH4Root(_ body: (URL) throws -> Void) throws {
        let resolved = try XCTUnwrap(realpath(FileManager.default.temporaryDirectory.path, nil))
        let physical = String(cString: resolved)
        free(resolved)
        let root = URL(fileURLWithPath: physical, isDirectory: true)
            .appendingPathComponent("H4LiveFixture-" + UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700])
        defer { try? FileManager.default.removeItem(at: root) }
        try body(root)
    }

    private func savedH4Row(_ json: Data, _ cbor: Data) -> HypervisorStageH4DualStreamPersistence.ReopenedDualStreamRowInput {
        HypervisorStageH4DualStreamPersistence.savedRowForTest(json: json, cbor: cbor)
    }

    func testH4SavedReaderReconstructsWithoutLiveOwnerAndPreservesExactFile() throws {
        try withLiveH4Root { root in
            let saved = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistTest(rootURL: root)
            let original = try XCTUnwrap(saved.receipt)
            let url = URL(fileURLWithPath: saved.location)
            let before = try Data(contentsOf: url)
            for _ in 0..<2 {
                let opened = try HypervisorStageH4DualStreamPersistence.readSavedFile(url, budget: .init())
                XCTAssertEqual(opened.receipt.root, original.root)
                XCTAssertEqual(opened.receipt.h3.root, original.h3ReceiptRoot)
                XCTAssertEqual(opened.receipt.json, original.json)
                XCTAssertEqual(opened.receipt.cbor, original.cbor)
                XCTAssertEqual(opened.imageSHA256, GuestContract.hash(before))
                XCTAssertEqual(opened.imageBytes, before.count)
                XCTAssertEqual(try Data(contentsOf: url), before)
            }
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: root.path),
                [HypervisorStageH4DualStreamPersistence.finalLeafName])
        }
    }

    func testH4SavedReaderRejectsCorruptCopiesWithoutChangingOriginal() throws {
        try withLiveH4Root { root in
            let saved = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistTest(rootURL: root)
            let originalURL = URL(fileURLWithPath: saved.location), original = try Data(contentsOf: originalURL)
            var variants: [Data] = []
            for offset in [0, 16, 18, 28] {
                var data = original; data[offset] ^= 0xff; variants.append(data)
            }
            variants.append(Data(original.dropLast()))
            var extra = original; extra.append(0); variants.append(extra)
            var body = original; body[100] = 0xff; variants.append(body)
            variants.append(Data(repeating: 0, count: 65 * 4_096))
            for (index, bytes) in variants.enumerated() {
                let copy = root.appendingPathComponent("corrupt-\(index).sqlite")
                try bytes.write(to: copy, options: .withoutOverwriting)
                XCTAssertEqual(chmod(copy.path, 0o400), 0)
                XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(copy, budget: .init()))
                XCTAssertEqual(try Data(contentsOf: copy), bytes)
            }
            XCTAssertEqual(try Data(contentsOf: originalURL), original)
        }
    }

    func testH4SavedReaderRejectsUnsafeFileKindsModesLinksAndMissingFile() throws {
        try withLiveH4Root { root in
            let saved = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistTest(rootURL: root)
            let url = URL(fileURLWithPath: saved.location), original = try Data(contentsOf: url)
            let alias = root.appendingPathComponent("link.sqlite")
            XCTAssertEqual(symlink(url.path, alias.path), 0)
            XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(alias, budget: .init()))
            let fifo = root.appendingPathComponent("fifo.sqlite")
            XCTAssertEqual(mkfifo(fifo.path, 0o400), 0)
            XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(fifo, budget: .init()))
            XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(root, budget: .init()))
            XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(root.appendingPathComponent("absent"), budget: .init()))
            XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(URL(string: "https://invalid.example/receipt")!, budget: .init()))
            for mode: mode_t in [0o600, 0o444, 0o644] {
                let copy = root.appendingPathComponent("mode-\(mode)")
                try original.write(to: copy, options: .withoutOverwriting)
                XCTAssertEqual(chmod(copy.path, mode), 0)
                XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(copy, budget: .init()))
            }
            let linkCopy = root.appendingPathComponent("hard.sqlite")
            XCTAssertEqual(link(url.path, linkCopy.path), 0)
            XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(url, budget: .init()))
            XCTAssertEqual(try Data(contentsOf: url), original)
        }
    }

    func testH4SavedReaderCancellationAndSQLiteInstructionBudgetAreFinite() throws {
        let canceled = GuestH4SavedReceipt.Budget(); canceled.cancel()
        XCTAssertThrowsError(try canceled.check())
        XCTAssertEqual(canceled.interruptSQLite(), 1)
        let budget = GuestH4SavedReceipt.Budget()
        for _ in 0..<2_000 { XCTAssertEqual(budget.interruptSQLite(), 0) }
        XCTAssertEqual(budget.interruptSQLite(), 1)
        XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(
            URL(fileURLWithPath: "/not-opened-by-canceled-h4-read"), budget: canceled))
    }

    func testH4SavedReaderRejectsSchemaAndIndexTamperingInSeparateCopies() throws {
        try withLiveH4Root { root in
            let saved = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistTest(rootURL: root)
            let originalURL = URL(fileURLWithPath: saved.location), bytes = try Data(contentsOf: originalURL)
            let changes = [
                "UPDATE h4_dual_receipts SET predicate_count=8",
                "UPDATE h4_dual_receipts SET authority_vector='10000000'",
                "UPDATE h4_dual_receipts SET claim_state='OTHER'",
                "UPDATE h4_dual_receipts SET canonical_json=X'00'",
                "UPDATE h4_dual_receipts SET canonical_cbor=X'FF'",
                "DELETE FROM h4_dual_receipts", "CREATE TABLE extra(value TEXT)"
            ]
            for (index, change) in changes.enumerated() {
                let copy = root.appendingPathComponent("sqlite-tamper-\(index).sqlite")
                try bytes.write(to: copy, options: .withoutOverwriting)
                XCTAssertEqual(chmod(copy.path, 0o600), 0)
                var db: OpaquePointer?
                XCTAssertEqual(sqlite3_open_v2(copy.path, &db, SQLITE_OPEN_READWRITE, nil), SQLITE_OK)
                XCTAssertEqual(sqlite3_exec(db, "PRAGMA ignore_check_constraints=ON", nil, nil, nil), SQLITE_OK)
                XCTAssertEqual(sqlite3_exec(db, change, nil, nil, nil), SQLITE_OK)
                XCTAssertEqual(sqlite3_close(db), SQLITE_OK)
                XCTAssertEqual(chmod(copy.path, 0o400), 0)
                let corrupted = try Data(contentsOf: copy)
                XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(copy, budget: .init()), change)
                XCTAssertEqual(try Data(contentsOf: copy), corrupted)
            }
            XCTAssertEqual(try Data(contentsOf: originalURL), bytes)
        }
    }

    func testH4SavedReaderRejectsSameBytesReboundBeforeFinalJoin() throws {
        try withLiveH4Root { root in
            let saved = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistTest(rootURL: root)
            let url = URL(fileURLWithPath: saved.location), bytes = try Data(contentsOf: url)
            let displaced = root.appendingPathComponent("original-retained.sqlite")
            let budget = GuestH4SavedReceipt.Budget(afterCapture: {
                try FileManager.default.moveItem(at: url, to: displaced)
                try bytes.write(to: url, options: .withoutOverwriting)
                guard chmod(url.path, 0o400) == 0 else { throw ProvenanceFailure("test chmod") }
            })
            XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(url, budget: budget))
            XCTAssertEqual(try Data(contentsOf: displaced), bytes)
            XCTAssertEqual(try Data(contentsOf: url), bytes)
        }
    }

    func testH4SavedSemanticReaderRejectsNoncanonicalAndMismatchedStreams() throws {
        try withLiveH4Root { root in
            let saved = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistTest(rootURL: root)
            let p = try XCTUnwrap(saved.receipt)
            var spaced = p.json; spaced.append(0x20)
            XCTAssertThrowsError(try GuestH4SavedReceipt.decode(savedH4Row(spaced, p.cbor)))
            var trailing = p.cbor; trailing.append(0)
            XCTAssertThrowsError(try GuestH4SavedReceipt.decode(savedH4Row(p.json, trailing)))
            XCTAssertThrowsError(try GuestH4SavedReceipt.decode(savedH4Row(Data(), p.cbor)))
            XCTAssertThrowsError(try GuestH4SavedReceipt.decode(savedH4Row(Data(repeating: 0x20, count: 32_769), p.cbor)))
            var semantic = try semanticMap(StageCanonicalJSON.decode(p.json))
            semantic["authority_vector"] = .text("10000000")
            XCTAssertThrowsError(try GuestH4SavedReceipt.decode(savedH4Row(StageCanonicalJSON.encode(.map(semantic)), p.cbor)))
        }
    }

    func testH4SavedSemanticReaderRejectsChangedRootsScopeAndUnknownFields() throws {
        try withLiveH4Root { root in
            let saved = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistTest(rootURL: root)
            let p = try XCTUnwrap(saved.receipt), original = try semanticMap(StageCanonicalJSON.decode(p.json))
            for field in ["h3_receipt_root", "h3_state_root", "h3_graph_root", "predicate_scope", "authority_vector", "unknown"] {
                var changed = original; changed[field] = .text(String(repeating: "0", count: 64))
                XCTAssertThrowsError(try GuestH4SavedReceipt.decode(savedH4Row(
                    StageCanonicalJSON.encode(.map(changed)), GuestCBOR.encode(.map(changed)))), field)
            }
        }
    }

    func testH4SavedH3ReconstructionRejectsAlteredRecordedExecutionAndGraph() throws {
        let receipt = try XCTUnwrap(GuestH3LiveVerifier.verify(fixture()).receipt)
        let state = try semanticMap(StageCanonicalJSON.decode(receipt.state.json))
        let graph = try StageCanonicalJSON.decode(receipt.graph.json)
        XCTAssertEqual(try GuestH3LiveVerifier.reconstructSaved(state: .map(state), graph: graph), receipt)
        for (section, key, replacement): (String, String, GuestCBORValue) in [
            ("source", "run_entries", .text("2")), ("target", "generation", .text("9")),
            ("lifecycle", "end_ticks", .text("0")), ("lifecycle", "timebase_denom", .text("0")),
            ("native_result", "execution_pass", .text("0")), ("native_roots", "guest_image_sha256", .text("bad")),
            ("source", "generation", .text("09")), ("readiness", "receipt_root", .text("bad"))
        ] {
            var changed = state, nested = try semanticMap(state[section]!)
            nested[key] = replacement; changed[section] = .map(nested)
            XCTAssertThrowsError(try GuestH3LiveVerifier.reconstructSaved(state: .map(changed), graph: graph))
        }
        var badGraph = try semanticMap(graph); badGraph["edges"] = .array([])
        XCTAssertThrowsError(try GuestH3LiveVerifier.reconstructSaved(state: .map(state), graph: .map(badGraph)))
    }

    func testH4LiveRetainsExactDualStreamsWithSourceBindingAndOneUse() throws {
        let native = try fixture()
        let original = try XCTUnwrap(GuestH3LiveVerifier.verify(native).receipt)
        let handoff = try GuestH3LivePersistence.makeTestHandoff(native)
        try withLiveH4Root { root in
            let saved = handoff.persistTest(rootURL: root)
            XCTAssertTrue(saved.durable, saved.detail)
            let receipt = try XCTUnwrap(saved.receipt)
            XCTAssertEqual(receipt.h3ReceiptRoot, original.root)
            let value = try semanticMap(StageCanonicalJSON.decode(receipt.json))
            XCTAssertEqual(value["h3_state"], try StageCanonicalJSON.decode(original.state.json))
            XCTAssertEqual(value["h3_graph"], try GuestCBOR.decode(original.graph.cbor))
            XCTAssertEqual(try StageCanonicalJSON.decode(receipt.json), try GuestCBOR.decode(receipt.cbor))
            XCTAssertEqual(value["claim_state"], .text("OBSERVED_NATIVE_PASS"))
            XCTAssertEqual(value["authority_vector"], .text("00000000"))
            XCTAssertNil(value["raw_diagnostic"])
            var db: OpaquePointer?
            XCTAssertEqual(sqlite3_open_v2(saved.location, &db, SQLITE_OPEN_READONLY, nil), SQLITE_OK)
            defer { sqlite3_close(db) }
            var statement: OpaquePointer?
            XCTAssertEqual(sqlite3_prepare_v2(db, "SELECT canonical_json,canonical_cbor FROM h4_dual_receipts", -1, &statement, nil), SQLITE_OK)
            defer { sqlite3_finalize(statement) }
            XCTAssertEqual(sqlite3_step(statement), SQLITE_ROW)
            for (column, expected) in [(Int32(0), receipt.json), (Int32(1), receipt.cbor)] {
                let pointer = try XCTUnwrap(sqlite3_column_blob(statement, column))
                XCTAssertEqual(Data(bytes: pointer, count: Int(sqlite3_column_bytes(statement, column))), expected)
            }
            XCTAssertEqual(sqlite3_step(statement), SQLITE_DONE)
            let before = try Data(contentsOf: URL(fileURLWithPath: saved.location))
            XCTAssertFalse(handoff.persistTest(rootURL: root).durable)
            XCTAssertEqual(try Data(contentsOf: URL(fileURLWithPath: saved.location)), before)
        }
    }

    func testH4LiveNonpassAndCanceledHandoffCannotPublish() throws {
        var invalid = try fixture()
        invalid.teardown_pass = 0
        XCTAssertThrowsError(try GuestH3LivePersistence.makeTestHandoff(invalid))
        let handoff = try GuestH3LivePersistence.makeTestHandoff(fixture())
        handoff.cancel()
        try withLiveH4Root { root in
            XCTAssertFalse(handoff.persistTest(rootURL: root).durable)
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: root.path), [])
        }
    }

    func testH4LiveFaultsRetainStateWithoutIssuingDurableReceipt() throws {
        let faults: [HypervisorStageH4DualStreamPersistence.TestFault] = [
            .beforeBegin, .afterInsert, .commitResponseLost, .serializedWrongPageCount,
            .afterStagingCreation, .pwriteShort, .fsyncRejected, .fullSyncRejected,
            .stagingReadbackMismatch, .stagingSameBytesNewInode, .renameCollision,
            .renameResponseLost, .directorySyncRejected, .finalReadbackMismatch,
            .finalReboundBeforeOpen, .finalDescriptorCloseResponseLost,
        ]
        for fault in faults {
            let handoff = try GuestH3LivePersistence.makeTestHandoff(fixture())
            try withLiveH4Root { root in
                let result = handoff.persistTest(rootURL: root, fault: fault)
                XCTAssertFalse(result.durable, "\(fault): \(result.detail)")
                XCTAssertNil(result.receipt)
                let retainedNames = try FileManager.default.contentsOfDirectory(atPath: root.path).sorted()
                XCTAssertFalse(handoff.persistTest(rootURL: root).durable)
                XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: root.path).sorted(), retainedNames)
            }
        }
    }

    func testH4LiveCancellationAfterPublicationCannotMintSuccess() throws {
        let handoff = try GuestH3LivePersistence.makeTestHandoff(fixture())
        try withLiveH4Root { root in
            let result = handoff.persistTest(rootURL: root, interstice: { stage in
                if stage == .afterFinalVerificationBeforeStoreReceipt { handoff.cancel() }
            })
            XCTAssertFalse(result.durable)
            XCTAssertNil(result.receipt)
            XCTAssertTrue(FileManager.default.fileExists(atPath:
                root.appendingPathComponent(HypervisorStageH4DualStreamPersistence.finalLeafName).path))
        }
    }

    func testH4LiveExistingRootCannotBeAdoptedOrOverwritten() throws {
        try withLiveH4Root { root in
            let first = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistTest(rootURL: root)
            XCTAssertTrue(first.durable, first.detail)
            _ = try XCTUnwrap(first.receipt)
            let bytes = try Data(contentsOf: URL(fileURLWithPath: first.location))
            let second = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistTest(rootURL: root)
            XCTAssertFalse(second.durable)
            XCTAssertEqual(try Data(contentsOf: URL(fileURLWithPath: first.location)), bytes)
        }
    }

    func testH4LiveProvisioningCreatesIndependentReceiptsAndPreservesPriorBytes() throws {
        try withLiveH4Root { base in
            let first = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistProvisionedTest(baseURL: base)
            XCTAssertTrue(first.durable, first.detail)
            _ = try XCTUnwrap(first.receipt)
            let before = try Data(contentsOf: URL(fileURLWithPath: first.location))
            let second = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistProvisionedTest(baseURL: base)
            XCTAssertTrue(second.durable, second.detail)
            _ = try XCTUnwrap(second.receipt)
            XCTAssertNotEqual(first.location, second.location)
            XCTAssertEqual(try Data(contentsOf: URL(fileURLWithPath: first.location)), before)
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: base.path), [GuestH3LivePersistence.rootLeaf])
            let namespace = base.appendingPathComponent(GuestH3LivePersistence.rootLeaf)
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: namespace.path).count, 2)
            let metadata = try FileManager.default.attributesOfItem(atPath: first.location)
            XCTAssertEqual(metadata[.posixPermissions] as? Int, 0o400)
            XCTAssertLessThanOrEqual(before.count, 262_144)
        }
    }

    func testH4LiveProvisioningRejectsSymlinkAndNonPrivateNamespaceWithoutRepair() throws {
        try withLiveH4Root { base in
            let parent = base.appendingPathComponent(GuestH3LivePersistence.rootLeaf)
            try FileManager.default.createSymbolicLink(atPath: parent.path, withDestinationPath: base.path)
            let result = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistProvisionedTest(baseURL: base)
            XCTAssertFalse(result.durable)
            XCTAssertEqual(try FileManager.default.destinationOfSymbolicLink(atPath: parent.path), base.path)
        }
        try withLiveH4Root { base in
            let parent = base.appendingPathComponent(GuestH3LivePersistence.rootLeaf)
            try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: false,
                attributes: [.posixPermissions: 0o755])
            XCTAssertFalse(try GuestH3LivePersistence.makeTestHandoff(fixture()).persistProvisionedTest(baseURL: base).durable)
            XCTAssertEqual(try FileManager.default.attributesOfItem(atPath: parent.path)[.posixPermissions] as? Int, 0o755)
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: parent.path), [])
        }
    }

    func testLiveProjectionRejectsProjectionAndReceiptRootSubstitution() throws {
        let native = try fixture()
        let receipt = try GuestH3LiveVerifier.projectionForTesting(native)
        var stateRoot = Array(receipt.state.root.utf8)
        stateRoot[0] = stateRoot[0] == 48 ? 49 : 48
        let wrongState = HypervisorStageProjection(json: receipt.state.json,
            cbor: receipt.state.cbor, root: String(decoding: stateRoot, as: UTF8.self))
        assertProjectionRejected(try reroot(wrongState, receipt.graph, native: native), native: native)

        var receiptRoot = Array(receipt.root.utf8)
        receiptRoot[0] = receiptRoot[0] == 48 ? 49 : 48
        assertProjectionRejected(GuestH3LiveProjectionReceipt(state: receipt.state,
            graph: receipt.graph, root: String(decoding: receiptRoot, as: UTF8.self)), native: native)
    }

    func testLiveProjectionRejectsStaticReadinessRootSubstitutionAfterDualReseal() throws {
        let native = try fixture()
        let receipt = try GuestH3LiveVerifier.projectionForTesting(native)
        var state = try semanticMap(GuestCBOR.decode(receipt.state.cbor))
        guard case .map(var readiness) = state["readiness"] else {
            return XCTFail("missing readiness map")
        }
        readiness["receipt_root"] = .text(String(repeating: "a", count: 64))
        readiness["graph_root"] = .text(String(repeating: "b", count: 64))
        state["readiness"] = .map(readiness)
        let hostileState = try liveProjection(.map(state),
            schema: GuestH3LiveVerifier.liveStateSchema, role: "state")

        var graph = try semanticMap(GuestCBOR.decode(receipt.graph.cbor))
        guard case .array(var nodes) = graph["nodes"],
              case .map(var receiptNode) = nodes[0],
              case .map(var graphNode) = nodes[1] else {
            return XCTFail("missing graph state nodes")
        }
        receiptNode["content_root"] = .text(String(repeating: "a", count: 64))
        graphNode["content_root"] = .text(String(repeating: "b", count: 64))
        nodes[0] = .map(receiptNode); nodes[1] = .map(graphNode)
        graph["nodes"] = .array(nodes)
        let hostileGraph = try liveProjection(.map(graph),
            schema: GuestH3LiveVerifier.liveGraphSchema, role: "graph")
        assertProjectionRejected(try reroot(hostileState, hostileGraph, native: native), native: native)
    }

    func testLiveProjectionRejectsNativeGenerationAndLifecycleCounterSubstitutions() throws {
        let original = try fixture()
        let receipt = try GuestH3LiveVerifier.projectionForTesting(original)
        var generation = original
        generation.source.generation = 11
        generation.target.generation = 12
        assertProjectionRejected(receipt, native: generation)
        var counter = original
        counter.watchdog_create_entries = 1
        assertProjectionRejected(receipt, native: counter)
        var outcome = original
        outcome.outcome = 2
        assertProjectionRejected(receipt, native: outcome)
        var phaseStatus = original
        phaseStatus.target.vm_destroy_status = 1
        assertProjectionRejected(receipt, native: phaseStatus)
        var cursor = original
        cursor.cursor_sha256.0 ^= 1
        assertProjectionRejected(receipt, native: cursor)
        var checkpoint = original
        checkpoint.checkpoint_merkle.0 ^= 1
        assertProjectionRejected(receipt, native: checkpoint)
        var terminal = original
        terminal.terminal_merkle.0 ^= 1
        assertProjectionRejected(receipt, native: terminal)
    }

    func testLiveProjectionRejectsAuthorityDurabilityAndH4Substitutions() throws {
        let native = try fixture()
        let receipt = try GuestH3LiveVerifier.projectionForTesting(native)
        for mutation: (String, GuestCBORValue) in [
            ("authority_vector", .text("10000000")),
            ("durable", .bool(true)),
            ("gate_e", .text("PASS")),
            ("h4_entered", .bool(true)),
        ] {
            var state = try semanticMap(GuestCBOR.decode(receipt.state.cbor))
            state[mutation.0] = mutation.1
            let hostile = try liveProjection(.map(state),
                schema: GuestH3LiveVerifier.liveStateSchema, role: "state")
            assertProjectionRejected(try reroot(hostile, receipt.graph, native: native), native: native)

            var graph = try semanticMap(GuestCBOR.decode(receipt.graph.cbor))
            graph[mutation.0] = mutation.1
            let hostileGraph = try liveProjection(.map(graph),
                schema: GuestH3LiveVerifier.liveGraphSchema, role: "graph")
            assertProjectionRejected(try reroot(receipt.state, hostileGraph, native: native),
                                     native: native)
        }
    }

    func testLiveGraphRejectsContentAddressAndBipartiteEdgeSubstitution() throws {
        let native = try fixture()
        let receipt = try GuestH3LiveVerifier.projectionForTesting(native)
        var graph = try semanticMap(GuestCBOR.decode(receipt.graph.cbor))
        guard case .array(var nodes) = graph["nodes"], case .map(var node) = nodes[3],
              case .array(var edges) = graph["edges"], case .map(var edge) = edges[0] else {
            return XCTFail("missing graph inventory")
        }
        node["content_root"] = .text(String(repeating: "c", count: 64))
        nodes[3] = .map(node)
        // Create an explicit forbidden state-to-state edge while retaining a
        // canonical, content-addressed graph projection.
        edge["to"] = .text("native-cursor")
        edges[0] = .map(edge)
        graph["nodes"] = .array(nodes); graph["edges"] = .array(edges)
        let hostileGraph = try liveProjection(.map(graph),
            schema: GuestH3LiveVerifier.liveGraphSchema, role: "graph")
        assertProjectionRejected(try reroot(receipt.state, hostileGraph, native: native), native: native)
    }

    func testEveryHeaderWordRejectsEvenWhenAttackerResealsDigestAndRoots() throws {
        for offset in stride(from: 8, to: 136, by: 8) {
            var value = try fixture()
            var evidence = load(&value.cursor_evidence.bytes)
            evidence[offset + 7] ^= 1
            store(evidence, in: &value.cursor_evidence.bytes)
            try resealEvidence(&value)
            assertRejected(value, line: UInt(offset))
        }
    }

    func testEvidenceMagicAndDeclaredLengthReject() throws {
        var magic = try fixture()
        magic.cursor_evidence.bytes.0 ^= 1
        assertRejected(magic)
        var length = try fixture()
        length.cursor_evidence.byte_count = 679
        assertRejected(length)
    }

    func testEvidenceClassesRejectWithConsistentOuterCommitments() throws {
        for offset in [136, 384, 416, 512, 544, 576, 608, 640] {
            var value = try fixture()
            var evidence = load(&value.cursor_evidence.bytes)
            evidence[offset] ^= 1
            store(evidence, in: &value.cursor_evidence.bytes)
            try resealEvidence(&value)
            assertRejected(value, line: UInt(offset))
        }
    }

    func testCursorDigestCannotBeSubstitutedWithSelfConsistentMerkleRoots() throws {
        var value = try fixture()
        var digest = load(&value.cursor_sha256)
        digest[0] ^= 1
        store(digest, in: &value.cursor_sha256)
        var evidence = load(&value.cursor_evidence.bytes)
        evidence.replaceSubrange(648..<680, with: digest)
        store(evidence, in: &value.cursor_evidence.bytes)
        try resealRoots(&value)
        assertRejected(value)
    }

    func testNonSuccessorGenerationRejectsWithExactMatchingEvidence() throws {
        assertRejected(try fixture(source: 9, target: 11))
    }

    func testEveryPhaseCounterAndStatusClassRejects() throws {
        let mutations: [(inout EPRGuestH3CursorResumeResult) -> Void] = [
            { $0.source.run_entries = 2 }, { $0.source.mappings_entered = 2 },
            { $0.source.register_set_calls = 35 }, { $0.source.register_read_calls = 35 },
            { $0.source.conserved = 0 }, { $0.target.run_entries = 2 },
            { $0.target.mappings_entered = 2 }, { $0.target.register_set_calls = 35 },
            { $0.target.register_read_calls = 37 }, { $0.target.conserved = 0 },
            { $0.source.vm_create_status = 1 }, { $0.source.map_status.0 = 1 },
            { $0.source.map_status.1 = 1 }, { $0.source.map_status.2 = 1 },
            { $0.source.vcpu_create_status = 1 }, { $0.source.register_status = 1 },
            { $0.source.run_status = 1 }, { $0.source.read_register_status = 1 },
            { $0.source.vcpu_destroy_status = 1 }, { $0.source.unmap_status.0 = 1 },
            { $0.source.unmap_status.1 = 1 }, { $0.source.unmap_status.2 = 1 },
            { $0.source.vm_destroy_status = 1 }, { $0.source.host_unmap_status.0 = 1 },
            { $0.source.host_unmap_status.1 = 1 }, { $0.source.host_unmap_status.2 = 1 },
            { $0.target.vm_create_status = 1 }, { $0.target.map_status.0 = 1 },
            { $0.target.map_status.1 = 1 }, { $0.target.map_status.2 = 1 },
            { $0.target.vcpu_create_status = 1 }, { $0.target.register_status = 1 },
            { $0.target.run_status = 1 }, { $0.target.read_register_status = 1 },
            { $0.target.vcpu_destroy_status = 1 }, { $0.target.unmap_status.0 = 1 },
            { $0.target.unmap_status.1 = 1 }, { $0.target.unmap_status.2 = 1 },
            { $0.target.vm_destroy_status = 1 }, { $0.target.host_unmap_status.0 = 1 },
            { $0.target.host_unmap_status.1 = 1 }, { $0.target.host_unmap_status.2 = 1 },
        ]
        for (index, mutate) in mutations.enumerated() {
            var value = try fixture(); mutate(&value)
            assertRejected(value, line: UInt(index + 1))
        }
    }

    func testPhaseExitFramesAndClockOrderReject() throws {
        let mutations: [(inout EPRGuestH3CursorResumeResult) -> Void] = [
            { $0.source.pc &+= 4 }, { $0.source.x4 = 2 }, { $0.source.syndrome = 0 },
            { $0.target.pc &+= 4 }, { $0.target.x4 = 1 }, { $0.target.exception_reason = 0 },
            { $0.source.entry_ticks = 0 }, { $0.target.entry_ticks = $0.source.exit_ticks - 1 },
            { $0.end_ticks = $0.target.exit_ticks - 1 },
        ]
        for (index, mutate) in mutations.enumerated() {
            var value = try fixture(); mutate(&value)
            assertRejected(value, line: UInt(index + 1))
        }
    }

    func testMerkleReplyCancellationAndQuarantineMutationsReject() throws {
        let mutations: [(inout EPRGuestH3CursorResumeResult) throws -> Void] = [
            { $0.checkpoint_merkle.0 ^= 1 }, { $0.terminal_merkle.0 ^= 1 },
            { value in value.checkpoint_reply.0 ^= 1; try self.resealRoots(&value) },
            { value in value.final_reply.0 ^= 1; try self.resealRoots(&value) },
            { $0.cancellation_requested = 1 }, { $0.cancellation_calls = 1 },
            { $0.resources_quarantined = 1 }, { $0.teardown_pass = 0 },
            { $0.watchdog_create_entries = 1 }, { $0.watchdog_join_entries = 1 },
            { $0.watchdog_fired = 1 }, { $0.outcome = 2 },
            { $0.execution_pass = 0 }, { $0.signing_admitted = 0 },
            { $0.cursor_sealed = 0 }, { $0.cursor_decoded = 0 },
            { $0.cursor_restored = 0 }, { $0.checkpoint_valid = 0 },
            { $0.terminal_valid = 0 }, { $0.source_conserved = 0 },
            { $0.target_conserved = 0 }, { $0.failure_stage = 1 },
            { $0.first_error = 1 }, { $0.signing_error = 1 },
            { $0.cancellation_status = 0 }, { $0.watchdog_create_status = 1 },
            { $0.watchdog_join_status = 1 }, { $0.timebase_numer = 0 },
            { $0.timebase_denom = 0 },
        ]
        for (index, mutate) in mutations.enumerated() {
            var value = try fixture(); try mutate(&value)
            assertRejected(value, line: UInt(index + 1))
        }
    }
}

// H5 inputs remain fabricated; these tests never reserve or enter a VM.
extension HypervisorH3LiveVerifierTests {
    private func h5Fixture(_ ordinal: Int) throws -> EPRGuestH3CursorResumeResult {
        var value = try fixture(source: UInt64(ordinal * 2 + 1), target: UInt64(ordinal * 2 + 2))
        let offset = UInt64(ordinal * 100)
        value.start_ticks += offset; value.end_ticks += offset
        value.source.entry_ticks += offset; value.source.exit_ticks += offset
        value.target.entry_ticks += offset; value.target.exit_ticks += offset
        return value
    }

    private func h5Batch() throws -> HypervisorStageH5Repeat.Batch {
        var batch = HypervisorStageH5Repeat.Batch(epoch: UUID())
        try batch.beginAttempt(); try batch.accept(h5Fixture(0))
        return batch
    }

    func testH5ThreeFreshRunsHaveEqualStateAndDistinctOriginalRoots() throws {
        var batch = HypervisorStageH5Repeat.Batch(epoch: UUID())
        for i in 0..<3 { try batch.beginAttempt(); try batch.accept(h5Fixture(i)) }
        let result = try batch.finish()
        XCTAssertEqual(result.observations.count, 3)
        XCTAssertEqual(Set(result.observations.map { $0.comparison.root }).count, 1)
        XCTAssertEqual(Set(result.observations.map { $0.presentation.receipt!.root }).count, 3)
        XCTAssertEqual(Set(result.observations.map { GuestContract.hash($0.evidence) }).count, 3)
        XCTAssertEqual(try StageCanonicalJSON.decode(result.projection.json), try GuestCBOR.decode(result.projection.cbor))
        let semantic = try XCTUnwrap(try JSONSerialization.jsonObject(with: result.projection.json) as? [String: Any])
        XCTAssertEqual(semantic["authority_vector"] as? String, "00000000")
        XCTAssertEqual(semantic["same_host_attestation"] as? String, "NOT_INDEPENDENTLY_ATTESTED")
        XCTAssertEqual(semantic["durable"] as? Bool, false)
        XCTAssertEqual(semantic["next_stage_authorized"] as? Bool, false)
        let runs = try XCTUnwrap(semantic["runs"] as? [[String: String]])
        XCTAssertEqual(runs.map { $0["cumulative_raw_cursor_bytes"]! }, ["680", "1360", "2040"])
        XCTAssertEqual(runs.map { $0["cumulative_native_intervals"]! }, ["2", "4", "6"])
        XCTAssertThrowsError(try batch.beginAttempt())
        XCTAssertThrowsError(try batch.finish())
    }

    func testH5EpochScopesSummaryButNotDeterministicGuestComparison() throws {
        var a = HypervisorStageH5Repeat.Batch(epoch: UUID()), b = HypervisorStageH5Repeat.Batch(epoch: UUID())
        for i in 0..<3 {
            try a.beginAttempt(); try a.accept(h5Fixture(i))
            try b.beginAttempt(); try b.accept(h5Fixture(i))
        }
        let ar = try a.finish(), br = try b.finish()
        XCTAssertNotEqual(ar.projection.root, br.projection.root)
        XCTAssertEqual(ar.observations[0].comparison, br.observations[0].comparison)
    }

    func testH5ReplayConsumesBatchAndCannotBeRetried() throws {
        var batch = try h5Batch()
        try batch.beginAttempt()
        XCTAssertThrowsError(try batch.accept(h5Fixture(0))) { XCTAssertEqual($0 as? HypervisorStageH5Repeat.Failure, .staleRun) }
        XCTAssertEqual(batch.observations.count, 1)
        XCTAssertEqual(batch.attempted, 2)
        XCTAssertThrowsError(try batch.beginAttempt())
        XCTAssertThrowsError(try batch.finish())
    }

    func testH5RejectsOverlappingOrRegressingIntervals() throws {
        for overlap in [true, false] {
            var batch = try h5Batch()
            var next = try h5Fixture(1)
            let shift: UInt64 = overlap ? 99 : 100
            next.start_ticks -= shift; next.end_ticks -= shift
            next.source.entry_ticks -= shift; next.source.exit_ticks -= shift
            next.target.entry_ticks -= shift; next.target.exit_ticks -= shift
            try batch.beginAttempt()
            XCTAssertThrowsError(try batch.accept(next)) { XCTAssertEqual($0 as? HypervisorStageH5Repeat.Failure, .staleRun) }
        }
    }

    func testH5RejectsChangedTimebaseDespiteValidIndividualRun() throws {
        var batch = try h5Batch(), next = try h5Fixture(1)
        next.timebase_numer += 1
        _ = try GuestH3LiveVerifier.verify(next)
        try batch.beginAttempt()
        XCTAssertThrowsError(try batch.accept(next)) { XCTAssertEqual($0 as? HypervisorStageH5Repeat.Failure, .clockChanged) }
    }

    func testH5DetectsIndividuallyValidTrapVariation() throws {
        var batch = try h5Batch(), next = try h5Fixture(1)
        next.source.syndrome = 0x9384_0045
        _ = try GuestH3LiveVerifier.verify(next)
        try batch.beginAttempt()
        XCTAssertThrowsError(try batch.accept(next)) { XCTAssertEqual($0 as? HypervisorStageH5Repeat.Failure, .mismatch) }
    }

    func testH5AllowsObservedTimingAndWatchdogWaitVariation() throws {
        var batch = try h5Batch(), next = try h5Fixture(1)
        next.end_ticks += 10; next.watchdog_wait_status = ETIMEDOUT
        try batch.beginAttempt(); try batch.accept(next)
        XCTAssertEqual(batch.observations[0].comparison, batch.observations[1].comparison)
        XCTAssertNotEqual(batch.observations[0].presentation.receipt?.root, batch.observations[1].presentation.receipt?.root)
    }

    func testH5InvalidResealedCursorNeverEntersComparison() throws {
        var batch = try h5Batch(), next = try h5Fixture(1)
        var evidence = load(&next.cursor_evidence.bytes)
        evidence[143] ^= 1
        store(evidence, in: &next.cursor_evidence.bytes)
        try resealEvidence(&next)
        try batch.beginAttempt()
        XCTAssertThrowsError(try batch.accept(next)) { XCTAssertEqual($0 as? HypervisorStageH5Repeat.Failure, .nativeRejected) }
        XCTAssertEqual(batch.observations.count, 1)
    }

    func testH5PartialBatchCannotFinishOrAcceptWithoutPendingAttempt() throws {
        var batch = try h5Batch()
        XCTAssertThrowsError(try batch.finish())
        XCTAssertThrowsError(try batch.accept(h5Fixture(1)))
        try batch.beginAttempt()
        XCTAssertThrowsError(try batch.beginAttempt())
    }

    func testH5CancellationRejectsLateCompletionAndEveryLaterAttempt() throws {
        var batch = try h5Batch()
        try batch.beginAttempt(); batch.cancel()
        XCTAssertThrowsError(try batch.accept(h5Fixture(1)))
        XCTAssertThrowsError(try batch.beginAttempt())
        XCTAssertThrowsError(try batch.finish())
        XCTAssertEqual(batch.failure, .canceled)
        XCTAssertEqual(batch.observations.count, 1)
    }

    func testH5WorkerMakesExactlyThreeCallsAndIsOneUse() throws {
        let values = try (0..<3).map(h5Fixture)
        let worker = GuestH5RepeatWorker(epoch: UUID())
        var calls = 0
        let result = worker.run { defer { calls += 1 }; return .init(native: values[calls], released: true) }
        XCTAssertEqual(calls, 3); XCTAssertNotNil(result.summary)
        XCTAssertEqual(worker.run { XCTFail("Repeated worker called native adapter"); return .init(native: nil, released: true) }.failure, .consumed)
    }

    func testH5WorkerCanceledBeforeStartEntersNoNativeAdapter() {
        let worker = GuestH5RepeatWorker(epoch: UUID()); worker.cancel()
        let result = worker.run { XCTFail("Canceled worker called native adapter"); return .init(native: nil, released: true) }
        XCTAssertEqual(result.attempted, 0); XCTAssertEqual(result.failure, .canceled)
    }

    func testH5WorkerCancellationAtEveryNativeReturnSuppressesSuccessAndLaterRuns() throws {
        let values = try (0..<3).map(h5Fixture)
        for cutoff in 0..<3 {
            let worker = GuestH5RepeatWorker(epoch: UUID())
            var calls = 0
            let result = worker.run {
                let value = values[calls]
                if calls == cutoff { worker.cancel() }
                calls += 1
                return .init(native: value, released: true)
            }
            XCTAssertEqual(calls, cutoff + 1); XCTAssertNil(result.summary)
            XCTAssertEqual(result.failure, .canceled)
            XCTAssertEqual(result.observations.count, cutoff)
        }
    }

    func testH5WorkerStopsOnEveryFailedReleaseWithoutPublishingThatRun() throws {
        let values = try (0..<3).map(h5Fixture)
        for cutoff in 0..<3 {
            let worker = GuestH5RepeatWorker(epoch: UUID())
            var calls = 0
            let result = worker.run {
                let index = calls; calls += 1
                return .init(native: values[index], released: index != cutoff)
            }
            XCTAssertEqual(calls, cutoff + 1); XCTAssertNil(result.summary)
            XCTAssertTrue(result.quarantined); XCTAssertEqual(result.observations.count, cutoff)
        }
    }

    func testH5WorkerStopsAfterReserveFailure() {
        let worker = GuestH5RepeatWorker(epoch: UUID())
        var calls = 0
        let result = worker.run { calls += 1; return .init(native: nil, released: true) }
        XCTAssertEqual(calls, 1); XCTAssertEqual(result.failure, .nativeRejected)
        XCTAssertFalse(result.quarantined); XCTAssertNil(result.summary)
    }

    func testH5WorkerStopsAfterNativeFailureAndRetainsPriorObservations() throws {
        let values = try (0..<3).map(h5Fixture)
        for cutoff in 0..<3 {
            let worker = GuestH5RepeatWorker(epoch: UUID())
            var calls = 0
            let result = worker.run {
                var value = values[calls]
                if calls == cutoff { value.execution_pass = 0 }
                calls += 1
                return .init(native: value, released: true)
            }
            XCTAssertEqual(calls, cutoff + 1); XCTAssertNil(result.summary)
            XCTAssertEqual(result.observations.count, cutoff); XCTAssertEqual(result.failure, .nativeRejected)
        }
    }
}

extension HypervisorH3LiveVerifierTests {
    private final class H7Clock: @unchecked Sendable {
        private let lock = NSLock()
        private var instant = ContinuousClock.now
        func read() -> ContinuousClock.Instant { lock.lock(); defer { lock.unlock() }; return instant }
        func expire() { lock.lock(); instant = instant.advanced(by: .seconds(16)); lock.unlock() }
    }

    func testH7ProjectsOnlyFixedInputsThenSeparatelyDeliversBothScreenDestinations() throws {
        let context = GuestH7Execution.Context(), native = try fixture()
        var calls = 0
        let result = context.run(context.request) { input in
            calls += 1
            XCTAssertEqual(input.left, 19); XCTAssertEqual(input.right, 23); XCTAssertEqual(input.increment, 1)
            return .init(native: native, released: true)
        }
        XCTAssertEqual(result.status, .verified); XCTAssertFalse(result.quarantined); XCTAssertEqual(calls, 1)
        let gui = try XCTUnwrap(context.take(.gui, request: context.request))
        XCTAssertEqual(gui.checkpoint, 42); XCTAssertEqual(gui.resumed, 43)
        XCTAssertEqual(gui.epoch, context.request.epoch)
        XCTAssertNil(context.take(.gui, request: context.request))
        XCTAssertEqual(context.take(.accessibility, request: context.request), gui)
        XCTAssertNil(context.take(.accessibility, request: context.request))
    }

    func testH7EveryMismatchedClaimIsConsumedBeforeNativeEntry() {
        let mutations: [(inout GuestH7Execution.Request) -> Void] = [
            { $0.subject = UUID() }, { $0.epoch = UUID() }, { $0.namespace = UUID() },
            { $0.purpose = "CANARY-private-purpose" }, { $0.operation = "arbitrary-program" },
            { $0.record = "CANARY-file:///private/secret" }, { $0.fields = ["left", "right"] },
            { $0.fields += ["credential-CANARY"] }, { $0.fields.reverse() },
            { $0.fields = [] }, { $0.record = "*" }, { $0.operation = "list-root" },
            { $0.operation = "search-all" }, { $0.purpose = String(repeating: "X", count: 65_537) },
        ]
        for mutate in mutations {
            let context = GuestH7Execution.Context()
            var request = context.request; mutate(&request)
            for candidate in [request, context.request] {
                let result = context.run(candidate) { _ in XCTFail("Rejected request entered native adapter"); return .init(native: nil, released: true) }
                XCTAssertEqual(result.status, .unavailable); XCTAssertFalse(result.quarantined)
            }
            for destination in GuestH7Execution.Destination.allCases { XCTAssertNil(context.take(destination, request: context.request)) }
        }
    }

    func testH7TransferredRequestCannotEnterAnotherContext() throws {
        let first = GuestH7Execution.Context(), second = GuestH7Execution.Context(), native = try fixture()
        let rejected = second.run(first.request) { _ in XCTFail("Cross-context entry"); return .init(native: nil, released: true) }
        XCTAssertEqual(rejected.status, .unavailable)
        XCTAssertEqual(first.run(first.request) { _ in .init(native: native, released: true) }.status, .verified)
        XCTAssertNil(first.take(.gui, request: second.request))
        XCTAssertNotNil(first.take(.gui, request: first.request))
    }

    func testH7UnknownAndUnauthorizedNamespacesHaveSameZeroEntryBudget() {
        for record in ["fixed-operands", "missing-record", "CANARY://private", "*"] {
            let context = GuestH7Execution.Context()
            var request = context.request; request.namespace = UUID(); request.record = record
            var entries = 0
            let completion = context.run(request) { _ in entries += 1; return .init(native: nil, released: true) }
            XCTAssertEqual(entries, 0); XCTAssertEqual(completion.status, .unavailable)
            XCTAssertNil(context.take(.gui, request: request))
        }
    }

    func testH7OutputDestinationsDoNotInheritGUIAuthority() throws {
        for denied in [GuestH7Execution.Destination.retention, .network, .diagnostic, .anotherAgent] {
            let context = GuestH7Execution.Context(), native = try fixture()
            XCTAssertEqual(context.run(context.request) { _ in .init(native: native, released: true) }.status, .verified)
            XCTAssertNil(context.take(denied, request: context.request))
            XCTAssertNotNil(context.take(.gui, request: context.request))
            XCTAssertNil(context.take(denied, request: context.request))
            XCTAssertNotNil(context.take(.accessibility, request: context.request))
        }
    }

    func testH7OutputCannotBeTakenBeforeExecution() {
        let context = GuestH7Execution.Context()
        for destination in GuestH7Execution.Destination.allCases { XCTAssertNil(context.take(destination, request: context.request)) }
    }

    func testH7ReplayedExecutionDoesNotCallNativeOrReplaceFirstResult() throws {
        let context = GuestH7Execution.Context(), native = try fixture()
        XCTAssertEqual(context.run(context.request) { _ in .init(native: native, released: true) }.status, .verified)
        XCTAssertEqual(context.run(context.request) { _ in XCTFail("Replay entered"); return .init(native: nil, released: true) }.status, .unavailable)
        XCTAssertNotNil(context.take(.gui, request: context.request))
    }

    func testH7ReentrantReplayDoesNotEnterOrConsumeFirstDelivery() throws {
        let context = GuestH7Execution.Context(), native = try fixture()
        // Reenter at the actual effect seam, after the first claim was made.
        XCTAssertEqual(context.run(context.request) { _ in
            XCTAssertEqual(context.run(context.request) { _ in XCTFail("Second native entry"); return .init(native: nil, released: true) }.status, .unavailable)
            return .init(native: native, released: true)
        }.status, .verified)
        XCTAssertNotNil(context.take(.gui, request: context.request))
    }

    func testH7CanceledBeforeStartEntersNoNativeAdapter() {
        let context = GuestH7Execution.Context(); context.cancel()
        XCTAssertEqual(context.run(context.request) { _ in XCTFail("Canceled entry"); return .init(native: nil, released: true) }.status, .unavailable)
    }

    func testH7CancellationWhileNativeRunsSuppressesDelivery() throws {
        let context = GuestH7Execution.Context(), native = try fixture()
        let completion = context.run(context.request) { _ in context.cancel(); return .init(native: native, released: true) }
        XCTAssertEqual(completion.status, .unavailable)
        for destination in GuestH7Execution.Destination.allCases { XCTAssertNil(context.take(destination, request: context.request)) }
    }

    func testH7CancellationAfterVerificationDropsQueuedOutput() throws {
        let context = GuestH7Execution.Context(), native = try fixture()
        XCTAssertEqual(context.run(context.request) { _ in .init(native: native, released: true) }.status, .verified)
        context.cancel()
        XCTAssertNil(context.take(.gui, request: context.request)); XCTAssertNil(context.take(.accessibility, request: context.request))
    }

    func testH7CancellationBetweenDestinationsDropsRemainingOutput() throws {
        let context = GuestH7Execution.Context(), native = try fixture()
        _ = context.run(context.request) { _ in .init(native: native, released: true) }
        XCTAssertNotNil(context.take(.gui, request: context.request)); context.cancel()
        XCTAssertNil(context.take(.accessibility, request: context.request))
    }

    func testH7ExpiredBeforeStartEntersNoNativeAdapter() {
        let clock = H7Clock(), context = GuestH7Execution.Context(testClock: { clock.read() })
        clock.expire()
        XCTAssertEqual(context.run(context.request) { _ in XCTFail("Expired entry"); return .init(native: nil, released: true) }.status, .unavailable)
    }

    func testH7NativeReturnBeyondDeadlineCannotPublish() throws {
        let clock = H7Clock(), context = GuestH7Execution.Context(testClock: { clock.read() }), native = try fixture()
        XCTAssertEqual(context.run(context.request) { _ in clock.expire(); return .init(native: native, released: true) }.status, .unavailable)
        XCTAssertNil(context.take(.gui, request: context.request))
    }

    func testH7DeadlineAlsoBoundsQueuedDelivery() throws {
        let clock = H7Clock(), context = GuestH7Execution.Context(testClock: { clock.read() }), native = try fixture()
        XCTAssertEqual(context.run(context.request) { _ in .init(native: native, released: true) }.status, .verified)
        clock.expire()
        XCTAssertNil(context.take(.gui, request: context.request)); XCTAssertNil(context.take(.accessibility, request: context.request))
    }

    func testH7FailedReleaseQuarantinesWithoutOutputOrRetry() throws {
        let context = GuestH7Execution.Context(), native = try fixture()
        let completion = context.run(context.request) { _ in .init(native: native, released: false) }
        XCTAssertEqual(completion.status, .unavailable); XCTAssertTrue(completion.quarantined)
        XCTAssertNil(context.take(.gui, request: context.request))
        XCTAssertEqual(context.run(context.request) { _ in XCTFail("Failed release retried"); return .init(native: nil, released: true) }.status, .unavailable)
    }

    func testH7ReserveFailureIsConsumedWithoutQuarantineOrOutput() {
        let context = GuestH7Execution.Context()
        let result = context.run(context.request) { _ in .init(native: nil, released: true) }
        XCTAssertEqual(result.status, .unavailable); XCTAssertFalse(result.quarantined)
        XCTAssertNil(context.take(.gui, request: context.request))
    }

    func testH7NativeQuarantineOverridesClaimedReleaseSuccess() throws {
        let context = GuestH7Execution.Context(); var native = try fixture(); native.resources_quarantined = 1
        let result = context.run(context.request) { _ in .init(native: native, released: true) }
        XCTAssertEqual(result.status, .unavailable); XCTAssertTrue(result.quarantined)
        XCTAssertNil(context.take(.gui, request: context.request))
    }

    func testH7RejectsNativeSigningCursorResultTimingAndTeardownFailures() throws {
        let mutations: [(inout EPRGuestH3CursorResumeResult) -> Void] = [
            { $0.signing_admitted = 0 }, { $0.execution_pass = 0 }, { $0.teardown_pass = 0 },
            { $0.cursor_restored = 0 }, { $0.target.conserved = 0 }, { $0.checkpoint_valid = 0 },
            { $0.terminal_valid = 0 }, { $0.end_ticks = $0.start_ticks }, { $0.timebase_denom = 0 },
            { $0.cancellation_requested = 1 }, { $0.cursor_evidence.byte_count = 0 },
        ]
        for mutate in mutations {
            let context = GuestH7Execution.Context(); var native = try fixture(); mutate(&native)
            XCTAssertEqual(context.run(context.request) { _ in .init(native: native, released: true) }.status, .unavailable)
            XCTAssertNil(context.take(.gui, request: context.request))
        }
    }
}

extension HypervisorH3LiveVerifierTests {
    private final class H7ParallelProbe: @unchecked Sendable {
        private let lock = NSLock()
        private let native: EPRGuestH3CursorResumeResult
        private var entries = 0
        private var completions: [GuestH7Execution.Status] = []
        init(_ native: EPRGuestH3CursorResumeResult) { self.native = native }
        func attempt(_ input: GuestH7Execution.Input) -> GuestCheckpointAttempt {
            lock.lock(); entries += 1; lock.unlock()
            return .init(native: native, released: true)
        }
        func record(_ completion: GuestH7Execution.Completion) {
            lock.lock(); completions.append(completion.status); lock.unlock()
        }
        func snapshot() -> (Int, [GuestH7Execution.Status]) {
            lock.lock(); defer { lock.unlock() }; return (entries, completions)
        }
    }

    func testH7ParallelReplayAdmitsExactlyOneNativeAttempt() throws {
        let context = GuestH7Execution.Context(), probe = H7ParallelProbe(try fixture())
        DispatchQueue.concurrentPerform(iterations: 12) { _ in
            probe.record(context.run(context.request, attempt: probe.attempt))
        }
        let (entries, completions) = probe.snapshot()
        XCTAssertEqual(entries, 1)
        XCTAssertEqual(completions.filter { $0 == .verified }.count, 1)
        XCTAssertEqual(completions.filter { $0 == .unavailable }.count, 11)
        XCTAssertNotNil(context.take(.gui, request: context.request))
        XCTAssertNotNil(context.take(.accessibility, request: context.request))
    }
}

extension HypervisorH3LiveVerifierTests {
    private final class H8Clock: @unchecked Sendable {
        private let lock = NSLock()
        private var instant = ContinuousClock.now
        func read() -> ContinuousClock.Instant { lock.lock(); defer { lock.unlock() }; return instant }
        func advance(_ seconds: Int) { lock.lock(); instant = instant.advanced(by: .seconds(seconds)); lock.unlock() }
    }
    private func h8Pending() throws -> GuestH8Provenance.Pending {
        GuestH8Provenance.Pending(source: try GuestH7Execution.makeTestSource(fixture()))
    }
    private func h8Snapshot() throws -> GuestH8Provenance.Snapshot {
        let projection = try h8Pending().claim()
        return .init(projection: projection, location: "fabricated-fixture-only",
            imageSHA256: GuestContract.hash(projection.json + projection.cbor), imageBytes: projection.json.count + projection.cbor.count)
    }

    func testH8NativeH7CompletionIssuesOnePendingSaveOnlyOnPASS() throws {
        let context = GuestH7Execution.Context(), native = try fixture()
        let completed = context.run(context.request) { _ in .init(native: native, released: true) }
        XCTAssertEqual(completed.status, .verified)
        XCTAssertNil(context.takePendingSave())
        _ = context.take(.gui, request: context.request)
        _ = context.take(.accessibility, request: context.request)
        let pending = try XCTUnwrap(context.takePendingSave())
        XCTAssertNil(context.takePendingSave())
        XCTAssertEqual(try pending.claim().epoch, context.request.epoch)
        XCTAssertThrowsError(try pending.claim())
        var failed = native; failed.execution_pass = 0
        let rejected = GuestH7Execution.Context()
        XCTAssertEqual(rejected.run(rejected.request) { _ in .init(native: failed, released: true) }.status, .unavailable)
        XCTAssertNil(rejected.takePendingSave())
    }

    func testH8CanonicalProjectionPreservesCompleteH3LineageAndDeclaredRetention() throws {
        let value = try h8Pending().claim()
        XCTAssertEqual(try GuestH8Provenance.Projection.decode(json: value.json, cbor: value.cbor), value)
        guard case .map(let fields) = try StageCanonicalJSON.decode(value.json),
              case .map(let policy) = fields["disclosure"] else { return XCTFail("Missing disclosure") }
        XCTAssertEqual(fields["h3_receipt_root"], .text(value.h3.root))
        XCTAssertEqual(fields["h3_state_root"], .text(value.h3.state.root))
        XCTAssertEqual(fields["h3_graph_root"], .text(value.h3.graph.root))
        XCTAssertEqual(fields["gate_e"], .text("ABSTAIN")); XCTAssertEqual(fields["authority_vector"], .text("00000000"))
        XCTAssertEqual(fields["execution_admission"], .text("DENIED_FROM_RETAINED_BYTES"))
        XCTAssertEqual(fields["trusted_egress"], .text("DENIED; INDEPENDENT_RELYING_PARTY_AUTHORITY_ABSENT"))
        XCTAssertEqual(policy["retention"], .text("INDEFINITE_LOCAL_EVIDENCE_UNTIL_USER_REMOVAL"))
        XCTAssertEqual(policy["protection_join"], .text("COMPLETE_H3_STATE_AND_GRAPH; NO_DECLASSIFICATION"))
    }

    func testH8RejectsReencodedAuthorityLineagePolicyAndFieldSubstitution() throws {
        let original = try h8Pending().claim()
        guard case .map(let fields) = try StageCanonicalJSON.decode(original.json) else { return XCTFail("Missing fields") }
        let edits: [(inout [String: GuestCBORValue]) -> Void] = [
            { $0["authority_vector"] = .text("10000000") }, { $0["gate_e"] = .text("PASS") },
            { $0["execution_admission"] = .text("ALLOWED") }, { $0["trusted_egress"] = .text("ALLOWED") },
            { $0["h3_receipt_root"] = .text(String(repeating: "0", count: 64)) },
            { $0["h3_state_root"] = .text(String(repeating: "0", count: 64)) },
            { $0.removeValue(forKey: "h3_graph") }, { $0["function"] = .text("other-function") },
            { $0["input"] = .map(["left": .text("CANARY-secret")]) },
            { $0["disclosure"] = .map(["retention": .text("UNDECLARED")]) },
            { $0["epoch"] = .text("not-a-uuid") }, { $0["credential"] = .text("CANARY-password") },
        ]
        for edit in edits {
            var changed = fields; edit(&changed)
            XCTAssertThrowsError(try GuestH8Provenance.Projection.decode(
                json: StageCanonicalJSON.encode(.map(changed)), cbor: GuestCBOR.encode(.map(changed))))
        }
    }

    func testH8RejectsCrossReceiptStreamSplicingAndNoncanonicalBytes() throws {
        let first = try h8Pending().claim(), second = try h8Pending().claim()
        XCTAssertNotEqual(first.epoch, second.epoch)
        XCTAssertThrowsError(try GuestH8Provenance.Projection.decode(json: first.json, cbor: second.cbor))
        XCTAssertThrowsError(try GuestH8Provenance.Projection.decode(json: first.json + Data([10]), cbor: first.cbor))
        XCTAssertThrowsError(try GuestH8Provenance.Projection.decode(json: first.json, cbor: first.cbor + Data([0])))
        XCTAssertThrowsError(try GuestH8Provenance.Projection.decode(json: Data(repeating: 0, count: 32_769), cbor: first.cbor))
    }

    func testH8CanceledPendingSaveCreatesNoDirectory() throws {
        try withLiveH4Root { base in
            let pending = try h8Pending(); pending.cancel()
            XCTAssertFalse(HypervisorStageH4DualStreamPersistence.persistH8Test(pending, baseURL: base).durable)
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: base.path), [])
        }
    }

    func testH8PendingGrantExpiresBeforeAnyPersistenceAdmission() throws {
        let clock = H8Clock(), pending = GuestH8Provenance.Pending(
            source: try GuestH7Execution.makeTestSource(fixture()), testClock: { clock.read() })
        clock.advance(300)
        XCTAssertThrowsError(try pending.claim()); XCTAssertFalse(pending.remainsLive())
    }

    func testH8SaveBudgetExpiresAfterClaimAndCannotComplete() throws {
        let clock = H8Clock(), pending = GuestH8Provenance.Pending(
            source: try GuestH7Execution.makeTestSource(fixture()), testClock: { clock.read() })
        _ = try pending.claim(); XCTAssertTrue(pending.remainsLive())
        clock.advance(10)
        XCTAssertFalse(pending.remainsLive()); XCTAssertFalse(pending.finish())
    }

    func testH8SuccessfulCompletionAndCancellationAreOneUse() throws {
        let pending = try h8Pending(); _ = try pending.claim()
        XCTAssertTrue(pending.finish()); XCTAssertFalse(pending.finish()); XCTAssertFalse(pending.remainsLive())
        let canceled = try h8Pending(); _ = try canceled.claim(); canceled.cancel()
        XCTAssertFalse(canceled.finish()); XCTAssertFalse(canceled.remainsLive())
    }

    func testH8PersistsReopensAndDoesNotOverwriteExistingEvidence() throws {
        try withLiveH4Root { base in
            let pending = try h8Pending()
            let saved = HypervisorStageH4DualStreamPersistence.persistH8Test(pending, baseURL: base)
            XCTAssertTrue(saved.durable)
            let projection = try XCTUnwrap(saved.projection)
            let url = URL(fileURLWithPath: saved.location), bytes = try Data(contentsOf: URL(fileURLWithPath: saved.location))
            let reopened = try HypervisorStageH4DualStreamPersistence.readH8File(url, budget: .init())
            XCTAssertEqual(reopened.projection, projection); XCTAssertEqual(reopened.imageSHA256, GuestContract.hash(bytes))
            XCTAssertEqual(reopened.imageBytes, bytes.count)
            XCTAssertFalse(HypervisorStageH4DualStreamPersistence.persistH8Test(pending, baseURL: base).durable)
            XCTAssertEqual(try Data(contentsOf: url), bytes)
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: base.path), [GuestH8Provenance.rootLeaf])
            XCTAssertEqual((try FileManager.default.attributesOfItem(atPath: saved.location))[.posixPermissions] as? Int, 0o400)
        }
    }

    func testH8AndH4UseSeparateNamespacesAndRejectEachOthersFiles() throws {
        try withLiveH4Root { base in
            let h4 = try GuestH3LivePersistence.makeTestHandoff(fixture()).persistProvisionedTest(baseURL: base)
            let h8 = HypervisorStageH4DualStreamPersistence.persistH8Test(try h8Pending(), baseURL: base)
            XCTAssertTrue(h4.durable); XCTAssertTrue(h8.durable)
            XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readH8File(URL(fileURLWithPath: h4.location), budget: .init()))
            XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readSavedFile(URL(fileURLWithPath: h8.location), budget: .init()))
            XCTAssertEqual(Set(try FileManager.default.contentsOfDirectory(atPath: base.path)), Set([GuestH3LivePersistence.rootLeaf, GuestH8Provenance.rootLeaf]))
        }
    }

    func testH8PersistenceFaultsNeverPublishVerifiedSuccessAndRemainConsumed() throws {
        let faults: [HypervisorStageH4DualStreamPersistence.TestFault] = [
            .beforeBegin, .commitResponseLost, .serializeRejected, .prepublicationJSONRejected,
            .prepublicationCBORRejected, .pwriteRejected, .fullSyncRejected, .stagingReadbackMismatch,
            .renameResponseLost, .directorySyncRejected, .finalJSONRejected, .finalCBORRejected,
            .finalReboundBeforeSuccess, .finalDescriptorCloseResponseLost,
        ]
        for fault in faults {
            try withLiveH4Root { base in
                let pending = try h8Pending()
                let saved = HypervisorStageH4DualStreamPersistence.persistH8Test(pending, baseURL: base, fault: fault)
                XCTAssertFalse(saved.durable, "\(fault)"); XCTAssertNil(saved.projection)
                XCTAssertThrowsError(try pending.claim())
            }
        }
    }

    func testH8ReadRejectsSymlinkDirectoryMissingAndCanceledCapture() throws {
        try withLiveH4Root { base in
            let saved = HypervisorStageH4DualStreamPersistence.persistH8Test(try h8Pending(), baseURL: base)
            let link = base.appendingPathComponent("alias")
            try FileManager.default.createSymbolicLink(atPath: link.path, withDestinationPath: saved.location)
            for url in [link, base, base.appendingPathComponent("missing")] {
                XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readH8File(url, budget: .init()))
            }
            let budget = GuestH4SavedReceipt.Budget(); budget.cancel()
            XCTAssertThrowsError(try HypervisorStageH4DualStreamPersistence.readH8File(URL(fileURLWithPath: saved.location), budget: budget))
        }
    }

    func testH8ReadGrantDoesNotTransferOrReplay() throws {
        let first = GuestH8Provenance.ReadGrant(snapshot: try h8Snapshot()), second = GuestH8Provenance.ReadGrant(snapshot: try h8Snapshot())
        XCTAssertNil(first.take(id: second.id)); XCTAssertNil(second.take(id: first.id))
        XCTAssertNotNil(first.take(id: first.id)); XCTAssertNil(first.take(id: first.id))
        XCTAssertNotNil(second.take(id: second.id))
    }

    func testH8ReadGrantExpiresAtExactDeadline() throws {
        let clock = H8Clock(), grant = GuestH8Provenance.ReadGrant(snapshot: try h8Snapshot(), testClock: { clock.read() })
        clock.advance(60)
        XCTAssertEqual(grant.status(), .expired); XCTAssertNil(grant.take(id: grant.id))
    }

    func testH8AlreadyDeliveredReadGrantExpiresWithoutClaimingErasure() throws {
        let clock = H8Clock(), grant = GuestH8Provenance.ReadGrant(snapshot: try h8Snapshot(), testClock: { clock.read() })
        let observed = try XCTUnwrap(grant.take(id: grant.id)); clock.advance(60)
        XCTAssertEqual(grant.status(), .expired); XCTAssertNil(grant.take(id: grant.id))
        XCTAssertFalse(observed.projection.root.isEmpty) // An observed copy is not erased by revocation.
    }

    func testH8RevocationAndDeletionConflictWithdrawFutureReadGrants() throws {
        for deletion in [false, true] {
            let grant = GuestH8Provenance.ReadGrant(snapshot: try h8Snapshot())
            grant.revoke(deletionRequested: deletion)
            XCTAssertEqual(grant.status(), deletion ? .retainedConflict : .revoked)
            XCTAssertNil(grant.take(id: grant.id))
        }
    }

    func testH8RevocationLeavesTheRetainedFileByteExact() throws {
        try withLiveH4Root { base in
            let saved = HypervisorStageH4DualStreamPersistence.persistH8Test(try h8Pending(), baseURL: base)
            let url = URL(fileURLWithPath: saved.location), before = try Data(contentsOf: URL(fileURLWithPath: saved.location))
            let snapshot = try HypervisorStageH4DualStreamPersistence.readH8File(url, budget: .init())
            let grant = GuestH8Provenance.ReadGrant(snapshot: snapshot)
            _ = grant.take(id: grant.id); grant.revoke(deletionRequested: true)
            XCTAssertEqual(grant.status(), .retainedConflict)
            XCTAssertEqual(try Data(contentsOf: url), before)
        }
    }
}

extension HypervisorH3LiveVerifierTests {
    func testH8UnclaimedSaveCandidateIsWithdrawnOnH7Cancellation() throws {
        let native = try fixture()
        for delivered in 0...2 {
            let context = GuestH7Execution.Context()
            XCTAssertEqual(context.run(context.request) { _ in .init(native: native, released: true) }.status, .verified)
            if delivered > 0 { _ = context.take(.gui, request: context.request) }
            if delivered > 1 { _ = context.take(.accessibility, request: context.request) }
            context.cancel()
            XCTAssertNil(context.takePendingSave())
        }
    }

    func testH8ReadDestinationsHaveSeparateClaimsAndCannotGrantOtherEffects() throws {
        let grant = GuestH8Provenance.ReadGrant(snapshot: try h8Snapshot())
        for destination in [GuestH7Execution.Destination.retention, .network, .diagnostic, .anotherAgent] {
            XCTAssertNil(grant.take(destination, id: grant.id))
        }
        let gui = try XCTUnwrap(grant.take(.gui, id: grant.id))
        XCTAssertNil(grant.take(.gui, id: grant.id))
        XCTAssertEqual(grant.take(.accessibility, id: grant.id), gui)
        XCTAssertNil(grant.take(.accessibility, id: grant.id))
        XCTAssertEqual(grant.status(), .consumed)
    }

    func testH8CancellationAfterPublicationPreservesFileWithoutVerifiedSuccess() throws {
        try withLiveH4Root { base in
            let pending = try h8Pending()
            let result = HypervisorStageH4DualStreamPersistence.persistH8Test(pending, baseURL: base,
                interstice: { boundary in if boundary == .afterFinalVerificationBeforeStoreReceipt { pending.cancel() } })
            XCTAssertFalse(result.durable); XCTAssertNil(result.projection)
            let path = base.appendingPathComponent(GuestH8Provenance.rootLeaf).appendingPathComponent(pending.leaf)
                .appendingPathComponent(HypervisorStageH4DualStreamPersistence.finalLeafName)
            XCTAssertTrue(FileManager.default.fileExists(atPath: path.path))
            XCTAssertThrowsError(try pending.claim())
        }
    }
}

extension HypervisorH3LiveVerifierTests {
    func testH8ActualLifecycleSequenceAllowsSaveThenReadButNeverAnotherGuest() throws {
        try withLiveH4Root { base in
            let context = GuestH7Execution.Context(), native = try fixture()
            var lifecycle = AppLifecyclePolicy(timebaseNumerator: 1, timebaseDenominator: 1)
            try lifecycle.beginRun(context.request.epoch)
            let completion = context.run(context.request) { _ in .init(native: native, released: true) }
            _ = context.take(.gui, request: context.request); _ = context.take(.accessibility, request: context.request)
            let pending = try XCTUnwrap(context.takePendingSave())
            _ = lifecycle.observe(runID: context.request.epoch,
                state: .completed(completion.lifecycleCompletion(hasPendingSave: true)), now: 1)
            XCTAssertThrowsError(try lifecycle.beginRun(UUID()))
            let saveID = UUID(); try lifecycle.beginPersistence(saveID)
            let saved = HypervisorStageH4DualStreamPersistence.persistH8Test(pending, baseURL: base)
            XCTAssertTrue(saved.durable)
            _ = lifecycle.observe(runID: saveID, state: .completed(saved.durable ? .conserved : .recoveryVolatile), now: 2)
            let readID = UUID(); try lifecycle.beginInspection(readID)
            let reopened = try HypervisorStageH4DualStreamPersistence.readH8File(URL(fileURLWithPath: saved.location), budget: .init())
            XCTAssertEqual(reopened.projection, saved.projection)
            _ = lifecycle.observe(runID: readID, state: .completed(.inspected), now: 3)
            XCTAssertThrowsError(try lifecycle.beginRun(UUID()))
            try lifecycle.beginInspection(UUID())
        }
    }

    func testH8LifecycleRejectsSaveWithoutVerifiedTransferredCandidate() throws {
        for (status, quarantined, transferred) in [
            (GuestH7Execution.Status.verified, false, false), (.unavailable, false, true), (.verified, true, true)
        ] {
            var lifecycle = AppLifecyclePolicy(timebaseNumerator: 1, timebaseDenominator: 1)
            let id = UUID(); try lifecycle.beginRun(id)
            let completion = GuestH7Execution.Completion(status: status, quarantined: quarantined)
            _ = lifecycle.observe(runID: id, state: .completed(completion.lifecycleCompletion(hasPendingSave: transferred)), now: 1)
            XCTAssertThrowsError(try lifecycle.beginPersistence(UUID()))
        }
    }
}
