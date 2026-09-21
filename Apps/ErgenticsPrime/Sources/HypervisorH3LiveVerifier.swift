import Darwin
import Foundation

#if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
extension GuestH3LiveVerifier {
    private typealias QualificationValue = H3QualificationJSONValue
    private static func qualificationOuter(_ value: EPRGuestH3CursorResumeResult) -> QualificationValue {
        .object([
            "abi_version": .integer(Int64(value.abi_version)),
            "outcome": .integer(Int64(value.outcome)),
            "execution_pass": .integer(Int64(value.execution_pass)),
            "teardown_pass": .integer(Int64(value.teardown_pass)),
            "signing_admitted": .integer(Int64(value.signing_admitted)),
            "cursor_sealed": .integer(Int64(value.cursor_sealed)),
            "cursor_decoded": .integer(Int64(value.cursor_decoded)),
            "cursor_restored": .integer(Int64(value.cursor_restored)),
            "checkpoint_valid": .integer(Int64(value.checkpoint_valid)),
            "terminal_valid": .integer(Int64(value.terminal_valid)),
            "source_conserved": .integer(Int64(value.source_conserved)),
            "target_conserved": .integer(Int64(value.target_conserved)),
            "cancellation_requested": .integer(Int64(value.cancellation_requested)),
            "cancellation_calls": .integer(Int64(value.cancellation_calls)),
            "watchdog_fired": .integer(Int64(value.watchdog_fired)),
            "watchdog_create_entries": .integer(Int64(value.watchdog_create_entries)),
            "watchdog_join_entries": .integer(Int64(value.watchdog_join_entries)),
            "resources_quarantined": .integer(Int64(value.resources_quarantined)),
            "timebase_numer": .integer(Int64(value.timebase_numer)),
            "timebase_denom": .integer(Int64(value.timebase_denom)),
            "failure_stage": .integer(Int64(value.failure_stage)),
            "first_error": .integer(Int64(value.first_error)),
            "signing_error": .integer(Int64(value.signing_error)),
            "cancellation_status": .integer(Int64(value.cancellation_status)),
            "watchdog_create_status": .integer(Int64(value.watchdog_create_status)),
            "watchdog_join_status": .integer(Int64(value.watchdog_join_status)),
            "watchdog_wait_status": .integer(Int64(value.watchdog_wait_status)),
            "start_ticks": .string(String(value.start_ticks)),
            "end_ticks": .string(String(value.end_ticks)),
            "cursor_evidence_byte_count": .integer(Int64(value.cursor_evidence.byte_count))
        ])
    }
    private static func qualificationPhase(_ value: EPRGuestH3PhaseResult) -> QualificationValue {
        .object([
            "run_entries": .integer(Int64(value.run_entries)),
            "mappings_entered": .integer(Int64(value.mappings_entered)),
            "register_set_calls": .integer(Int64(value.register_set_calls)),
            "register_read_calls": .integer(Int64(value.register_read_calls)),
            "conserved": .integer(Int64(value.conserved)),
            "vm_create_status": .integer(Int64(value.vm_create_status)),
            "map_statuses": .array([.integer(Int64(value.map_status.0)), .integer(Int64(value.map_status.1)), .integer(Int64(value.map_status.2))]),
            "vcpu_create_status": .integer(Int64(value.vcpu_create_status)),
            "register_status": .integer(Int64(value.register_status)),
            "run_status": .integer(Int64(value.run_status)),
            "read_register_status": .integer(Int64(value.read_register_status)),
            "vcpu_destroy_status": .integer(Int64(value.vcpu_destroy_status)),
            "unmap_statuses": .array([.integer(Int64(value.unmap_status.0)), .integer(Int64(value.unmap_status.1)), .integer(Int64(value.unmap_status.2))]),
            "vm_destroy_status": .integer(Int64(value.vm_destroy_status)),
            "host_unmap_statuses": .array([.integer(Int64(value.host_unmap_status.0)), .integer(Int64(value.host_unmap_status.1)), .integer(Int64(value.host_unmap_status.2))]),
            "generation": .string(String(value.generation)),
            "entry_ticks": .string(String(value.entry_ticks)),
            "exit_ticks": .string(String(value.exit_ticks)),
            "exception_reason": .string(String(value.exception_reason)),
            "syndrome": .string(String(value.syndrome)),
            "pc": .string(String(value.pc)),
            "fault_ipa": .string(String(value.fault_ipa)),
            "fault_virtual_address": .string(String(value.fault_virtual_address)),
            "x4": .string(String(value.x4))
        ])
    }
    private static func qualificationCheckpoint(_ value: EPRGuestH3CheckpointDiagnostic) -> QualificationValue {
        .object([
            "schema_version": .integer(Int64(value.schema_version)),
            "required_mask": .integer(Int64(value.required_mask)),
            "evaluated_mask": .integer(Int64(value.evaluated_mask)),
            "passed_mask": .integer(Int64(value.passed_mask)),
            "gpr_mismatch_mask": .integer(Int64(value.gpr_mismatch_mask)),
            "reserved_zero": .integer(Int64(value.reserved_zero)),
            "checkpoint_sequence": .string(String(value.checkpoint_sequence)),
            "gprs": .array([.string(String(value.gprs.0)), .string(String(value.gprs.1)), .string(String(value.gprs.2)), .string(String(value.gprs.3)), .string(String(value.gprs.4)), .string(String(value.gprs.5)), .string(String(value.gprs.6)), .string(String(value.gprs.7)), .string(String(value.gprs.8)), .string(String(value.gprs.9)), .string(String(value.gprs.10)), .string(String(value.gprs.11)), .string(String(value.gprs.12)), .string(String(value.gprs.13)), .string(String(value.gprs.14)), .string(String(value.gprs.15)), .string(String(value.gprs.16)), .string(String(value.gprs.17)), .string(String(value.gprs.18)), .string(String(value.gprs.19)), .string(String(value.gprs.20)), .string(String(value.gprs.21)), .string(String(value.gprs.22)), .string(String(value.gprs.23)), .string(String(value.gprs.24)), .string(String(value.gprs.25)), .string(String(value.gprs.26)), .string(String(value.gprs.27)), .string(String(value.gprs.28)), .string(String(value.gprs.29)), .string(String(value.gprs.30))]),
            "cpsr": .string(String(value.cpsr)),
            "sctlr": .string(String(value.sctlr)),
            "sp": .string(String(value.sp)),
            "vbar": .string(String(value.vbar)),
            "pages": .array([qualificationPage(value.page_witnesses.0, role: "code"), qualificationPage(value.page_witnesses.1, role: "request"), qualificationPage(value.page_witnesses.2, role: "reply")])
        ])
    }
    private static func qualificationSCTLR(_ value: EPRGuestH3SCTLRTransitionDiagnostic) -> QualificationValue {
        .object([
            "schema_version": .integer(Int64(value.schema_version)),
            "sampled_mask": .integer(Int64(value.sampled_mask)),
            "source_pre_entry_read_entries": .integer(Int64(value.source_pre_entry_read_entries)),
            "source_post_exit_read_entries": .integer(Int64(value.source_post_exit_read_entries)),
            "source_pre_entry_read_status": .integer(Int64(value.source_pre_entry_read_status)),
            "source_post_exit_read_status": .integer(Int64(value.source_post_exit_read_status)),
            "reserved_zero_0": .integer(Int64(value.reserved_zero_0)),
            "reserved_zero_1": .integer(Int64(value.reserved_zero_1)),
            "requested": .string(String(value.requested)),
            "source_pre_entry": .string(String(value.source_pre_entry)),
            "source_post_exit": .string(String(value.source_post_exit))
        ])
    }
    private static func qualificationPage(_ value: EPRGuestH3PageMismatchWitness, role: String) -> QualificationValue {
        .object(["role": .string(role), "first_mismatch_offset": .integer(Int64(value.first_mismatch_offset)),
            "observed_byte": .integer(Int64(value.observed_byte)), "expected_byte": .integer(Int64(value.expected_byte)),
            "reserved_zero": .integer(Int64(value.reserved_zero))])
    }

    static func qualificationCapture(_ returned: EPRGuestH3CursorResumeResult) -> H3QualificationNativeCapture {
        var value = returned
        let evidence = withUnsafeBytes(of: &value.cursor_evidence.bytes) { Data($0) }
        let cursor = withUnsafeBytes(of: &value.cursor_sha256) { Data($0) }
        let checkpointReply = withUnsafeBytes(of: &value.checkpoint_reply) { Data($0) }
        let finalReply = withUnsafeBytes(of: &value.final_reply) { Data($0) }
        let checkpointMerkle = withUnsafeBytes(of: &value.checkpoint_merkle) { Data($0) }
        let terminalMerkle = withUnsafeBytes(of: &value.terminal_merkle) { Data($0) }
        return H3QualificationNativeCapture(wire: .object([
            "disposition": .string("RETURNED"), "outer": qualificationOuter(value),
            "source": qualificationPhase(value.source), "target": qualificationPhase(value.target),
            "checkpoint": qualificationCheckpoint(value.checkpoint_diagnostic),
            "sctlr_transition": qualificationSCTLR(value.sctlr_transition_diagnostic),
            "cursor_evidence_hex": .string(evidence.hex),
            "cursor_evidence_sha256": .string(GuestContract.hash(evidence)),
            "cursor_sha256": .string(cursor.hex), "checkpoint_reply_hex": .string(checkpointReply.hex),
            "final_reply_hex": .string(finalReply.hex), "checkpoint_merkle_hex": .string(checkpointMerkle.hex),
            "terminal_merkle_hex": .string(terminalMerkle.hex)
        ]))
    }
    private static func qualificationDiagnostic(_ value: GuestH3CheckpointPageWitness) -> QualificationValue {
        .object([
            "role": .string(value.role),
            "firstMismatchOffset": .integer(Int64(value.firstMismatchOffset)),
            "observedByte": .integer(Int64(value.observedByte)),
            "expectedByte": .integer(Int64(value.expectedByte)),
            "reservedZero": .integer(Int64(value.reservedZero))
        ])
    }
    private static func qualificationDiagnostic(_ value: GuestH3CheckpointPredicateDiagnostic) -> QualificationValue {
        .object([
            "schemaVersion": .integer(Int64(value.schemaVersion)),
            "requiredMask": .integer(Int64(value.requiredMask)),
            "evaluatedMask": .integer(Int64(value.evaluatedMask)),
            "passedMask": .integer(Int64(value.passedMask)),
            "gprMismatchMask": .integer(Int64(value.gprMismatchMask)),
            "reservedZero": .integer(Int64(value.reservedZero)),
            "checkpointSequence": .string(String(value.checkpointSequence)),
            "gprs": .array(value.gprs.map { .string(String($0)) }),
            "cpsr": .string(String(value.cpsr)),
            "sctlr": .string(String(value.sctlr)),
            "sp": .string(String(value.sp)),
            "vbar": .string(String(value.vbar)),
            "pages": .array(value.pages.map { qualificationDiagnostic($0) })
        ])
    }
    private static func qualificationDiagnostic(_ value: GuestH3SCTLRTransitionDiagnostic) -> QualificationValue {
        .object([
            "schemaVersion": .integer(Int64(value.schemaVersion)),
            "sampledMask": .integer(Int64(value.sampledMask)),
            "sourcePreEntryReadEntries": .integer(Int64(value.sourcePreEntryReadEntries)),
            "sourcePostExitReadEntries": .integer(Int64(value.sourcePostExitReadEntries)),
            "sourcePreEntryReadStatus": .integer(Int64(value.sourcePreEntryReadStatus)),
            "sourcePostExitReadStatus": .integer(Int64(value.sourcePostExitReadStatus)),
            "reservedZero0": .integer(Int64(value.reservedZero0)),
            "reservedZero1": .integer(Int64(value.reservedZero1)),
            "requested": .string(String(value.requested)),
            "sourcePreEntry": .string(String(value.sourcePreEntry)),
            "sourcePostExit": .string(String(value.sourcePostExit))
        ])
    }
    private static func qualificationDiagnostic(_ value: GuestH3NativePhaseDiagnostic) -> QualificationValue {
        .object([
            "generation": .string(String(value.generation)),
            "runEntries": .integer(Int64(value.runEntries)),
            "mappingsEntered": .integer(Int64(value.mappingsEntered)),
            "registerSetCalls": .integer(Int64(value.registerSetCalls)),
            "registerReadCalls": .integer(Int64(value.registerReadCalls)),
            "conserved": .integer(Int64(value.conserved)),
            "vmCreateStatus": .integer(Int64(value.vmCreateStatus)),
            "mapStatuses": .array(value.mapStatuses.map { .integer(Int64($0)) }),
            "vcpuCreateStatus": .integer(Int64(value.vcpuCreateStatus)),
            "registerStatus": .integer(Int64(value.registerStatus)),
            "runStatus": .integer(Int64(value.runStatus)),
            "readRegisterStatus": .integer(Int64(value.readRegisterStatus)),
            "vcpuDestroyStatus": .integer(Int64(value.vcpuDestroyStatus)),
            "unmapStatuses": .array(value.unmapStatuses.map { .integer(Int64($0)) }),
            "vmDestroyStatus": .integer(Int64(value.vmDestroyStatus)),
            "hostUnmapStatuses": .array(value.hostUnmapStatuses.map { .integer(Int64($0)) }),
            "entryTicks": .string(String(value.entryTicks)),
            "exitTicks": .string(String(value.exitTicks)),
            "exceptionReason": .string(String(value.exceptionReason)),
            "syndrome": .string(String(value.syndrome)),
            "pc": .string(String(value.pc)),
            "faultIPA": .string(String(value.faultIPA)),
            "faultVirtualAddress": .string(String(value.faultVirtualAddress)),
            "x4": .string(String(value.x4))
        ])
    }
    private static func qualificationDiagnostic(_ value: GuestH3NativeDiagnostic) -> QualificationValue {
        .object([
            "classification": .string(value.classification),
            "verifierError": .string(value.verifierError),
            "abiVersion": .integer(Int64(value.abiVersion)),
            "outcome": .integer(Int64(value.outcome)),
            "executionPass": .integer(Int64(value.executionPass)),
            "teardownPass": .integer(Int64(value.teardownPass)),
            "signingAdmitted": .integer(Int64(value.signingAdmitted)),
            "cursorSealed": .integer(Int64(value.cursorSealed)),
            "cursorDecoded": .integer(Int64(value.cursorDecoded)),
            "cursorRestored": .integer(Int64(value.cursorRestored)),
            "cursorEvidenceByteCount": .integer(Int64(value.cursorEvidenceByteCount)),
            "checkpointValid": .integer(Int64(value.checkpointValid)),
            "terminalValid": .integer(Int64(value.terminalValid)),
            "sourceConserved": .integer(Int64(value.sourceConserved)),
            "targetConserved": .integer(Int64(value.targetConserved)),
            "cancellationRequested": .integer(Int64(value.cancellationRequested)),
            "cancellationCalls": .integer(Int64(value.cancellationCalls)),
            "watchdogFired": .integer(Int64(value.watchdogFired)),
            "watchdogCreateEntries": .integer(Int64(value.watchdogCreateEntries)),
            "watchdogJoinEntries": .integer(Int64(value.watchdogJoinEntries)),
            "resourcesQuarantined": .integer(Int64(value.resourcesQuarantined)),
            "failureStage": .integer(Int64(value.failureStage)),
            "failureStageName": .string(value.failureStageName),
            "firstError": .integer(Int64(value.firstError)),
            "signingError": .integer(Int64(value.signingError)),
            "cancellationStatus": .integer(Int64(value.cancellationStatus)),
            "watchdogCreateStatus": .integer(Int64(value.watchdogCreateStatus)),
            "watchdogJoinStatus": .integer(Int64(value.watchdogJoinStatus)),
            "watchdogWaitStatus": .integer(Int64(value.watchdogWaitStatus)),
            "startTicks": .string(String(value.startTicks)),
            "endTicks": .string(String(value.endTicks)),
            "timebaseNumer": .integer(Int64(value.timebaseNumer)),
            "timebaseDenom": .integer(Int64(value.timebaseDenom)),
            "source": qualificationDiagnostic(value.source),
            "target": qualificationDiagnostic(value.target),
            "checkpoint": qualificationDiagnostic(value.checkpoint),
            "sctlrTransition": qualificationDiagnostic(value.sctlrTransition),
            "checkpointIntegrity": .string(value.checkpointIntegrity),
            "checkpointFailures": .array(value.checkpointFailures.map { .string($0) }),
            "sctlrTransitionIntegrity": .string(value.sctlrTransitionIntegrity),
            "sctlrTransitionFailures": .array(value.sctlrTransitionFailures.map { .string($0) }),
            "requestedXORPreEntry": value.requestedXORPreEntry.map { .string(String($0)) } ?? .null,
            "preEntryXORPostExit": value.preEntryXORPostExit.map { .string(String($0)) } ?? .null
        ])
    }
    static func qualificationPresentation(_ value: GuestH3Presentation,
                                         returned: EPRGuestH3CursorResumeResult? = nil) -> H3QualificationPresentation {
        let diagnostic = value.nativeDiagnostic ?? returned.map { nativeDiagnostic($0, error: ProvenanceFailure("")) }
        let readinessRoot = value.status == "PASS"
            ? ((try? HypervisorStageH3Cursor.verifyContract(HypervisorStageH3Cursor.runContract()).receiptRoot) ?? "") : ""
        let wire: QualificationValue = .object([
            "checkpoint_failures": .array((diagnostic?.checkpointFailures ?? []).map { .string($0) }),
            "checkpoint_integrity": .string(diagnostic?.checkpointIntegrity ?? (value.status == "PASS" ? "VALID_PASS" : "VALID_NOT_EVALUATED")),
            "checkpoint_root": .string(value.checkpointRoot), "detail_sha256": .string(GuestContract.hash(Data(value.detail.utf8))),
            "disposition": .string(value.verificationDisposition), "durable": .bool(value.durable),
            "graph_root": .string(value.graphRoot), "h4_entered": .bool(value.h4Entered),
            "pre_entry_xor_post_exit": diagnostic?.preEntryXORPostExit.map { .string(String($0)) } ?? .null,
            "projection_root": .string(value.projectionRoot), "quarantined": .bool(value.quarantined),
            "readiness_receipt_root": .string(readinessRoot),
            "requested_xor_pre_entry": diagnostic?.requestedXORPreEntry.map { .string(String($0)) } ?? .null,
            "sctlr_transition_failures": .array((diagnostic?.sctlrTransitionFailures ?? []).map { .string($0) }),
            "sctlr_transition_integrity": .string(diagnostic?.sctlrTransitionIntegrity ?? (value.status == "PASS" ? "VALID_FULL" : "VALID_NOT_SAMPLED")),
            "status": .string(value.status), "terminal_root": .string(value.terminalRoot),
            "verifier_error_sha256": .string(GuestContract.hash(Data((value.nativeDiagnostic?.verifierError ?? "").utf8)))
        ])
        return H3QualificationPresentation(wire: wire,
            status: value.status, verificationDisposition: value.verificationDisposition, detail: value.detail,
            cursorSHA256: value.cursorSHA256, checkpointRoot: value.checkpointRoot, terminalRoot: value.terminalRoot,
            elapsed: value.elapsed, sourceGeneration: value.sourceGeneration, targetGeneration: value.targetGeneration,
            sourceRunEntries: value.sourceRunEntries, targetRunEntries: value.targetRunEntries, gateE: value.gateE,
            authorityVector: value.authorityVector, quarantined: value.quarantined, projectionRoot: value.projectionRoot,
            graphRoot: value.graphRoot, durable: value.durable, h4Entered: value.h4Entered,
            nativeDiagnostic: value.nativeDiagnostic.map(qualificationDiagnostic))
    }
}
#endif


struct GuestH3CheckpointPageWitness: Equatable, Sendable {
    let role: String
    let firstMismatchOffset: UInt32
    let observedByte: UInt8
    let expectedByte: UInt8
    let reservedZero: UInt16

    fileprivate func rendered() -> String {
        "checkpoint.page role=\(role) first_mismatch_offset=\(firstMismatchOffset) observed_byte=\(observedByte) expected_byte=\(expectedByte) reserved_zero=\(reservedZero)"
    }
}

/// Owned value-only copy of the ABI-v4 checkpoint witness. The fixed guest
/// IPAs in the GPR vector are observations, not host pointers or capabilities.
struct GuestH3CheckpointPredicateDiagnostic: Equatable, Sendable {
    let schemaVersion: UInt32
    let requiredMask: UInt32
    let evaluatedMask: UInt32
    let passedMask: UInt32
    let gprMismatchMask: UInt32
    let reservedZero: UInt32
    let checkpointSequence: UInt64
    let gprs: [UInt64]
    let cpsr: UInt64
    let sctlr: UInt64
    let sp: UInt64
    let vbar: UInt64
    let pages: [GuestH3CheckpointPageWitness]

    fileprivate init(_ value: EPRGuestH3CheckpointDiagnostic) {
        schemaVersion = value.schema_version
        requiredMask = value.required_mask
        evaluatedMask = value.evaluated_mask
        passedMask = value.passed_mask
        gprMismatchMask = value.gpr_mismatch_mask
        reservedZero = value.reserved_zero
        checkpointSequence = value.checkpoint_sequence
        gprs = [
            value.gprs.0, value.gprs.1, value.gprs.2, value.gprs.3,
            value.gprs.4, value.gprs.5, value.gprs.6, value.gprs.7,
            value.gprs.8, value.gprs.9, value.gprs.10, value.gprs.11,
            value.gprs.12, value.gprs.13, value.gprs.14, value.gprs.15,
            value.gprs.16, value.gprs.17, value.gprs.18, value.gprs.19,
            value.gprs.20, value.gprs.21, value.gprs.22, value.gprs.23,
            value.gprs.24, value.gprs.25, value.gprs.26, value.gprs.27,
            value.gprs.28, value.gprs.29, value.gprs.30,
        ]
        cpsr = value.cpsr
        sctlr = value.sctlr
        sp = value.sp
        vbar = value.vbar
        pages = [
            Self.page(value.page_witnesses.0, role: "code"),
            Self.page(value.page_witnesses.1, role: "request"),
            Self.page(value.page_witnesses.2, role: "reply"),
        ]
    }

    private static func page(_ value: EPRGuestH3PageMismatchWitness,
                             role: String) -> GuestH3CheckpointPageWitness {
        GuestH3CheckpointPageWitness(role: role,
            firstMismatchOffset: value.first_mismatch_offset,
            observedByte: value.observed_byte, expectedByte: value.expected_byte,
            reservedZero: value.reserved_zero)
    }

    fileprivate func rendered() -> String {
        let registers = gprs.enumerated().map {
            "x\($0.offset)=\($0.element)/0x\(String(format: "%016llx", $0.element))"
        }.joined(separator: " ")
        return ([
            String(format: "checkpoint.witness schema=%u required=0x%08x evaluated=0x%08x passed=0x%08x gpr_mismatch=0x%08x reserved_zero=%u",
                   schemaVersion, requiredMask, evaluatedMask, passedMask,
                   gprMismatchMask, reservedZero),
            "checkpoint.sequence=\(checkpointSequence)",
            "checkpoint.gprs \(registers)",
            String(format: "checkpoint.system cpsr=%llu/0x%016llx sctlr=%llu/0x%016llx sp=%llu/0x%016llx vbar=%llu/0x%016llx",
                   cpsr, cpsr, sctlr, sctlr, sp, sp, vbar, vbar),
        ] + pages.map { $0.rendered() }).joined(separator: "\n")
    }
}

/// Owned value-only copy of the ABI-v5 SCTLR sampling chronology. The sampled
/// values are observations only; they carry no VM handle or replay authority.
struct GuestH3SCTLRTransitionDiagnostic: Equatable, Sendable {
    let schemaVersion: UInt32
    let sampledMask: UInt32
    let sourcePreEntryReadEntries: UInt32
    let sourcePostExitReadEntries: UInt32
    let sourcePreEntryReadStatus: Int32
    let sourcePostExitReadStatus: Int32
    let reservedZero0: UInt32
    let reservedZero1: UInt32
    let requested: UInt64
    let sourcePreEntry: UInt64
    let sourcePostExit: UInt64

    fileprivate init(_ value: EPRGuestH3SCTLRTransitionDiagnostic) {
        schemaVersion = value.schema_version
        sampledMask = value.sampled_mask
        sourcePreEntryReadEntries = value.source_pre_entry_read_entries
        sourcePostExitReadEntries = value.source_post_exit_read_entries
        sourcePreEntryReadStatus = value.source_pre_entry_read_status
        sourcePostExitReadStatus = value.source_post_exit_read_status
        reservedZero0 = value.reserved_zero_0
        reservedZero1 = value.reserved_zero_1
        requested = value.requested
        sourcePreEntry = value.source_pre_entry
        sourcePostExit = value.source_post_exit
    }

    fileprivate func rendered() -> String {
        String(format: "sctlr.transition schema=%u sampled=0x%08x pre_entries=%u post_entries=%u pre_status=%d post_status=%d reserved_zero_0=%u reserved_zero_1=%u requested=%llu/0x%016llx source_pre_entry=%llu/0x%016llx source_post_exit=%llu/0x%016llx",
               schemaVersion, sampledMask, sourcePreEntryReadEntries,
               sourcePostExitReadEntries, sourcePreEntryReadStatus,
               sourcePostExitReadStatus, reservedZero0, reservedZero1,
               requested, requested, sourcePreEntry, sourcePreEntry,
               sourcePostExit, sourcePostExit)
    }
}

struct GuestH3NativePhaseDiagnostic: Equatable, Sendable {
    let generation: UInt64
    let runEntries: UInt32
    let mappingsEntered: UInt32
    let registerSetCalls: UInt32
    let registerReadCalls: UInt32
    let conserved: UInt32
    let vmCreateStatus: Int32
    let mapStatuses: [Int32]
    let vcpuCreateStatus: Int32
    let registerStatus: Int32
    let runStatus: Int32
    let readRegisterStatus: Int32
    let vcpuDestroyStatus: Int32
    let unmapStatuses: [Int32]
    let vmDestroyStatus: Int32
    let hostUnmapStatuses: [Int32]
    let entryTicks: UInt64
    let exitTicks: UInt64
    let exceptionReason: UInt64
    let syndrome: UInt64
    let pc: UInt64
    let faultIPA: UInt64
    let faultVirtualAddress: UInt64
    let x4: UInt64

    fileprivate init(_ value: EPRGuestH3PhaseResult) {
        generation = value.generation
        runEntries = value.run_entries
        mappingsEntered = value.mappings_entered
        registerSetCalls = value.register_set_calls
        registerReadCalls = value.register_read_calls
        conserved = value.conserved
        vmCreateStatus = value.vm_create_status
        mapStatuses = [value.map_status.0, value.map_status.1, value.map_status.2]
        vcpuCreateStatus = value.vcpu_create_status
        registerStatus = value.register_status
        runStatus = value.run_status
        readRegisterStatus = value.read_register_status
        vcpuDestroyStatus = value.vcpu_destroy_status
        unmapStatuses = [value.unmap_status.0, value.unmap_status.1, value.unmap_status.2]
        vmDestroyStatus = value.vm_destroy_status
        hostUnmapStatuses = [value.host_unmap_status.0, value.host_unmap_status.1,
                             value.host_unmap_status.2]
        entryTicks = value.entry_ticks
        exitTicks = value.exit_ticks
        exceptionReason = value.exception_reason
        syndrome = value.syndrome
        pc = value.pc
        faultIPA = value.fault_ipa
        faultVirtualAddress = value.fault_virtual_address
        x4 = value.x4
    }

    fileprivate func rendered(label: String) -> String {
        "\(label).generation=\(generation) run_entries=\(runEntries) mappings_entered=\(mappingsEntered) register_set_calls=\(registerSetCalls) register_read_calls=\(registerReadCalls) conserved=\(conserved)\n" +
        "\(label).status vm_create=\(vmCreateStatus) map=\(mapStatuses) vcpu_create=\(vcpuCreateStatus) register=\(registerStatus) run=\(runStatus) read=\(readRegisterStatus) vcpu_destroy=\(vcpuDestroyStatus) unmap=\(unmapStatuses) vm_destroy=\(vmDestroyStatus) host_unmap=\(hostUnmapStatuses)\n" +
        "\(label).frame entry_ticks=\(entryTicks) exit_ticks=\(exitTicks) exception_reason=\(exceptionReason) syndrome=\(syndrome) pc=\(pc) fault_ipa=\(faultIPA) fault_va=\(faultVirtualAddress) x4=\(x4)"
    }
}

/// Exact copied scalar diagnostics from a returned native H3 value. This is a
/// presentation-only observation: it contains no pointer, VM/vCPU handle,
/// reservation, path, replay token, or persistence authority.
struct GuestH3NativeDiagnostic: Equatable, Sendable {
    let classification: String
    let verifierError: String
    let abiVersion: UInt32
    let outcome: UInt32
    let executionPass: UInt32
    let teardownPass: UInt32
    let signingAdmitted: UInt32
    let cursorSealed: UInt32
    let cursorDecoded: UInt32
    let cursorRestored: UInt32
    let cursorEvidenceByteCount: UInt32
    let checkpointValid: UInt32
    let terminalValid: UInt32
    let sourceConserved: UInt32
    let targetConserved: UInt32
    let cancellationRequested: UInt32
    let cancellationCalls: UInt32
    let watchdogFired: UInt32
    let watchdogCreateEntries: UInt32
    let watchdogJoinEntries: UInt32
    let resourcesQuarantined: UInt32
    let failureStage: Int32
    let failureStageName: String
    let firstError: Int32
    let signingError: Int32
    let cancellationStatus: Int32
    let watchdogCreateStatus: Int32
    let watchdogJoinStatus: Int32
    let watchdogWaitStatus: Int32
    let startTicks: UInt64
    let endTicks: UInt64
    let timebaseNumer: UInt32
    let timebaseDenom: UInt32
    let source: GuestH3NativePhaseDiagnostic
    let target: GuestH3NativePhaseDiagnostic
    let checkpoint: GuestH3CheckpointPredicateDiagnostic
    let sctlrTransition: GuestH3SCTLRTransitionDiagnostic
    let checkpointIntegrity: String
    let checkpointFailures: [String]
    let sctlrTransitionIntegrity: String
    let sctlrTransitionFailures: [String]
    let requestedXORPreEntry: UInt64?
    let preEntryXORPostExit: UInt64?

    var rendered: String {
        [
            "failure_stage=\(failureStage) failure_stage_name=\(failureStageName) first_error=\(firstError) signing_error=\(signingError)",
            "abi=\(abiVersion) outcome=\(outcome) execution_pass=\(executionPass) teardown_pass=\(teardownPass) signing_admitted=\(signingAdmitted)",
            "cursor sealed=\(cursorSealed) decoded=\(cursorDecoded) restored=\(cursorRestored) evidence_byte_count=\(cursorEvidenceByteCount) checkpoint_valid=\(checkpointValid) terminal_valid=\(terminalValid)",
            "conservation source=\(sourceConserved) target=\(targetConserved) quarantined=\(resourcesQuarantined)",
            "cancellation requested=\(cancellationRequested) calls=\(cancellationCalls) status=\(cancellationStatus)",
            "watchdog fired=\(watchdogFired) create_entries=\(watchdogCreateEntries) join_entries=\(watchdogJoinEntries) create_status=\(watchdogCreateStatus) join_status=\(watchdogJoinStatus) wait_status=\(watchdogWaitStatus)",
            "clock start_ticks=\(startTicks) end_ticks=\(endTicks) timebase=\(timebaseNumer)/\(timebaseDenom)",
            source.rendered(label: "source"),
            target.rendered(label: "target"),
            checkpoint.rendered(),
            sctlrTransition.rendered(),
            "derived sctlr.requested_xor_pre_entry=\(Self.renderedHex(requestedXORPreEntry)) sctlr.pre_entry_xor_post_exit=\(Self.renderedHex(preEntryXORPostExit))",
            "derived classification=\(classification) checkpoint_integrity=\(checkpointIntegrity) checkpoint_failures=\(checkpointFailures) sctlr_transition_integrity=\(sctlrTransitionIntegrity) sctlr_transition_failures=\(sctlrTransitionFailures)",
            "verifier_error=\(verifierError)",
        ].joined(separator: "\n")
    }

    private static func renderedHex(_ value: UInt64?) -> String {
        guard let value else { return "unavailable" }
        return String(format: "%llu/0x%016llx", value, value)
    }
}

struct GuestH3Presentation: Sendable {
    let status: String
    let verificationDisposition: String
    let detail: String
    let cursorSHA256: String
    let checkpointRoot: String
    let terminalRoot: String
    let elapsed: String
    let sourceGeneration: UInt64
    let targetGeneration: UInt64
    let sourceRunEntries: UInt32
    let targetRunEntries: UInt32
    let gateE: String
    let authorityVector: String
    let quarantined: Bool
    let projectionRoot: String
    let graphRoot: String
    let durable: Bool
    let h4Entered: Bool
    let nativeDiagnostic: GuestH3NativeDiagnostic?
    // Copied, verified bytes for inspection only; never a live capability.
    let receipt: GuestH3LiveProjectionReceipt?
}

/// Immutable in-memory projections only. These bytes describe a verified
/// result; they contain no reservation, VM handle, replay token, path or write
/// destination and cannot recreate any live capability.
struct GuestH3LiveProjectionReceipt: Equatable, Sendable {
    let state: HypervisorStageProjection
    let graph: HypervisorStageProjection
    let root: String
}

/// Internal (and therefore @testable) pure-verification seam: it accepts only
/// a copied value result, never the reservation or any live VM capability.
/// Product-side reconstruction of the native H3 result. Native PASS is only an
/// input: Swift independently decodes the fixed cursor, reconstructs all three
/// admitted pages and both Merkle trees, then rejoins the two conserved VM
/// intervals. No projection here is written or accepted as a capability.
enum GuestH3LiveVerifier {
    private static let cursorBytes = 680
    private static let pageBytes = 16_384
    private static let imageBytes = 136
    private static let imageSHA256 = "3c03199c6ae993fa5c316a497cf4d59d590ee0e1a4488b598d8da385f38af8b0"
    private static let checkpointSchema = "ergentics.hypervisor.guest.h3.checkpoint.v2"
    private static let terminalSchema = "ergentics.hypervisor.guest.h3.terminal.v2"
    static let liveStateSchema = "ergentics.provenance.hypervisor-stage.h3.live-state.v1"
    static let liveGraphSchema = "ergentics.provenance.hypervisor-stage.h3.live-graph.v1"
    static let liveTransitionSchema = "ergentics.provenance.hypervisor-stage.h3.live-transition.v1"
    static let liveReceiptSchema = "ergentics.provenance.hypervisor-stage.h3.live-receipt.v1"
    private static let maximumProjectionBytes = 65_536
    private static let checkpointRequiredMask: UInt32 = 0x1ff
    private static let checkpointExpectedGPRs: [UInt64] = [
        0x1000_4000, 0x1000_8000, 0, 0x1000_c000, 1, 1, 42, 23,
    ] + Array(repeating: 0, count: 23)
    private static let sctlrTransitionRequiredMask: UInt32 = 0x7
    private static let requestedSCTLR: UInt64 = 0x30d0_0980

    private struct CheckpointAssessment {
        let integrity: String
        let failures: [String]
    }

    private struct SCTLRTransitionAssessment {
        let integrity: String
        let failures: [String]
        let requestedXORPreEntry: UInt64?
        let preEntryXORPostExit: UInt64?
    }

    private struct LiveBinding {
        let readinessReceiptRoot: String
        let readinessGraphRoot: String
        let readinessCursorRoot: String
        let cursorDigest: String
        let checkpointRoot: String
        let terminalRoot: String
        let imageDigest: String
        let source: EPRGuestH3PhaseResult
        let target: EPRGuestH3PhaseResult
        let abiVersion: UInt32
        let outcome: UInt32
        let executionPass: UInt32
        let teardownPass: UInt32
        let signingAdmitted: UInt32
        let cursorSealed: UInt32
        let cursorDecoded: UInt32
        let cursorRestored: UInt32
        let checkpointValid: UInt32
        let terminalValid: UInt32
        let sourceConserved: UInt32
        let targetConserved: UInt32
        let startTicks: UInt64
        let endTicks: UInt64
        let timebaseNumer: UInt32
        let timebaseDenom: UInt32
        let watchdogCreateEntries: UInt32
        let watchdogJoinEntries: UInt32
        let watchdogFired: UInt32
        let watchdogCreateStatus: Int32
        let watchdogJoinStatus: Int32
        let watchdogWaitStatus: Int32
        let cancellationRequested: UInt32
        let cancellationCalls: UInt32
        let cancellationStatus: Int32
        let resourcesQuarantined: UInt32
        let failureStage: Int32
        let firstError: Int32
        let signingError: Int32
    }

    private struct CursorReader {
        let bytes: Data
        var offset = 0

        mutating func take(_ count: Int) throws -> Data {
            guard count >= 0, offset <= bytes.count, count <= bytes.count - offset else {
                throw ProvenanceFailure("H3 cursor frame is truncated")
            }
            let value = bytes.subdata(in: offset..<(offset + count))
            offset += count
            return value
        }

        mutating func word() throws -> UInt64 {
            try take(8).reduce(UInt64(0)) { ($0 << 8) | UInt64($1) }
        }

        mutating func finish() throws {
            guard offset == bytes.count else {
                throw ProvenanceFailure("H3 cursor frame has trailing bytes")
            }
        }
    }

    private static func require(_ predicate: @autoclosure () throws -> Bool, _ message: String) throws {
        guard try predicate() else { throw ProvenanceFailure(message) }
    }

    private static func checkpointTrapFailures(_ source: GuestH3NativePhaseDiagnostic) -> [String] {
        let dfsc = source.syndrome & 63
        var failures: [String] = []
        if source.exceptionReason != 1 { failures.append("trap.exception_reason") }
        if source.syndrome != (0x9384_0040 | dfsc) || !(4...7).contains(dfsc) {
            failures.append("trap.syndrome")
        }
        if source.pc != 0x1000_0050 { failures.append("trap.pc") }
        if source.faultIPA != 0x1000_c000 { failures.append("trap.fault_ipa") }
        if source.faultVirtualAddress != 0x1000_c000 { failures.append("trap.fault_va") }
        if source.x4 != 1 { failures.append("trap.x4") }
        return failures
    }

    private static func checkpointExpectedPages() -> [Data]? {
        guard let imagePointer = epr_guest_h3_image_bytes(),
              Int(epr_guest_h3_image_size()) == imageBytes else { return nil }
        let image = Data(bytes: imagePointer, count: imageBytes)
        guard GuestContract.hash(image) == imageSHA256,
              let imagePage = try? page(prefix: image),
              let requestPage = try? page(prefix: GuestContract.request),
              let replyPage = try? page(prefix: GuestContract.frame([1, 1, 42, 0])) else {
            return nil
        }
        return [imagePage, requestPage, replyPage]
    }

    private static func checkpointAssessment(
        _ checkpoint: GuestH3CheckpointPredicateDiagnostic,
        source: GuestH3NativePhaseDiagnostic,
        checkpointValid: UInt32,
        failureStage: Int32
    ) -> CheckpointAssessment {
        var malformed: [String] = []
        var failures: [String] = []
        if checkpoint.schemaVersion != 1 { malformed.append("schema_version") }
        if checkpoint.requiredMask != checkpointRequiredMask { malformed.append("required_mask") }
        if checkpoint.reservedZero != 0 { malformed.append("reserved_zero") }
        if checkpoint.evaluatedMask & ~checkpointRequiredMask != 0 {
            malformed.append("evaluated_unknown_bits")
        }
        if checkpoint.passedMask & ~checkpoint.evaluatedMask != 0 {
            malformed.append("passed_outside_evaluated")
        }
        if checkpoint.evaluatedMask != 0 && checkpoint.evaluatedMask != checkpointRequiredMask {
            malformed.append("partial_evaluation")
        }
        if checkpoint.gprs.count != 31 || checkpoint.pages.count != 3 {
            malformed.append("fixed_array_width")
        }
        if checkpoint.gprMismatchMask & 0x8000_0000 != 0 {
            malformed.append("gpr_unknown_bit")
        }
        if checkpoint.pages.contains(where: { $0.reservedZero != 0 }) {
            malformed.append("page_reserved_zero")
        }

        let trapFailures = checkpointTrapFailures(source)
        if failureStage == 12 {
            malformed.append("h3_unreachable_snapshot_stage")
        }
        if checkpoint.evaluatedMask == 0 {
            switch failureStage {
            case 14...17, 19...23:
                malformed.append("not_evaluated_after_checkpoint_stage")
            default:
                break
            }
            let canonicalPages = checkpoint.pages.allSatisfy {
                $0.firstMismatchOffset == UInt32.max && $0.observedByte == 0 && $0.expectedByte == 0
            }
            if checkpoint.passedMask != 0 || checkpoint.gprMismatchMask != 0 ||
                checkpoint.checkpointSequence != 0 || checkpoint.gprs.contains(where: { $0 != 0 }) ||
                checkpoint.cpsr != 0 || checkpoint.sctlr != 0 || checkpoint.sp != 0 ||
                checkpoint.vbar != 0 || !canonicalPages {
                malformed.append("not_evaluated_payload")
            }
            if checkpointValid != 0 { malformed.append("not_evaluated_checkpoint_valid") }
            if failureStage == 11 {
                failures += trapFailures
                if trapFailures.isEmpty { malformed.append("predicate_stage_without_trap_witness") }
            }
            return CheckpointAssessment(
                integrity: malformed.isEmpty ? (failureStage == 11 ? "VALID_FAILURE" : "VALID_NOT_EVALUATED") : "MALFORMED",
                failures: malformed.isEmpty ? failures : malformed.map { "malformed.\($0)" } + failures)
        }

        if failureStage == 1 {
            malformed.append("evaluated_at_admission_stage")
        }
        var recomputedMask: UInt32 = 0
        if !trapFailures.isEmpty {
            malformed.append("evaluated_after_trap_failure")
        }
        if checkpoint.checkpointSequence == 1 { recomputedMask |= 1 << 0 }
        else { failures.append("checkpoint.sequence") }

        if let expectedPages = checkpointExpectedPages() {
            let pageNames = ["checkpoint.code_page", "checkpoint.request_page", "checkpoint.reply_page"]
            for index in 0..<3 {
                let witness = checkpoint.pages[index]
                let bit = UInt32(1 << (index + 1))
                if witness.firstMismatchOffset == UInt32.max {
                    if witness.observedByte == 0 && witness.expectedByte == 0 {
                        recomputedMask |= bit
                    } else {
                        malformed.append("page_exact_payload_\(index)")
                    }
                } else if witness.firstMismatchOffset < UInt32(pageBytes) {
                    let offset = Int(witness.firstMismatchOffset)
                    if witness.observedByte == witness.expectedByte ||
                        witness.expectedByte != expectedPages[index][offset] {
                        malformed.append("page_mismatch_payload_\(index)")
                    }
                    failures.append(pageNames[index])
                } else {
                    malformed.append("page_mismatch_offset_\(index)")
                }
            }
        } else {
            malformed.append("fixed_page_identity")
        }
        if checkpoint.pages.count == 3 {
            let reply = checkpoint.pages[2]
            if checkpoint.checkpointSequence != 1 {
                let firstSequenceMismatch = (0..<8).first { offset in
                    let observed = UInt8(truncatingIfNeeded:
                        checkpoint.checkpointSequence >> (UInt64(offset) * 8))
                    let expected: UInt8 = offset == 0 ? 1 : 0
                    return observed != expected
                }
                if firstSequenceMismatch == nil ||
                    reply.firstMismatchOffset != UInt32(firstSequenceMismatch!) {
                    malformed.append("sequence_reply_offset")
                } else {
                    let offset = firstSequenceMismatch!
                    let observed = UInt8(truncatingIfNeeded:
                        checkpoint.checkpointSequence >> (UInt64(offset) * 8))
                    let expected: UInt8 = offset == 0 ? 1 : 0
                    if reply.observedByte != observed || reply.expectedByte != expected {
                        malformed.append("sequence_reply_value")
                    }
                }
            } else if reply.firstMismatchOffset < 8 {
                malformed.append("sequence_reply_exact_word")
            }
        }

        var recomputedGPRMask: UInt32 = 0
        if checkpoint.gprs.count == checkpointExpectedGPRs.count {
            for index in checkpoint.gprs.indices where checkpoint.gprs[index] != checkpointExpectedGPRs[index] {
                recomputedGPRMask |= UInt32(1) << UInt32(index)
            }
        }
        if checkpoint.gprMismatchMask != recomputedGPRMask {
            malformed.append("gpr_mismatch_mask")
        }
        if recomputedGPRMask == 0 { recomputedMask |= 1 << 4 }
        else { failures.append("checkpoint.gprs") }
        if checkpoint.cpsr == 0x6000_03c5 { recomputedMask |= 1 << 5 }
        else { failures.append("checkpoint.cpsr") }
        if checkpoint.sctlr == 0x30d0_0980 { recomputedMask |= 1 << 6 }
        else { failures.append("checkpoint.sctlr") }
        if checkpoint.sp == 0x1000_bff0 { recomputedMask |= 1 << 7 }
        else { failures.append("checkpoint.sp") }
        if checkpoint.vbar == 0 { recomputedMask |= 1 << 8 }
        else { failures.append("checkpoint.vbar") }
        if checkpoint.passedMask != recomputedMask { malformed.append("passed_mask") }

        failures += trapFailures
        if source.registerSetCalls != 36 { failures.append("checkpoint.register_set_calls") }
        if source.registerReadCalls != 36 { failures.append("checkpoint.register_read_calls") }
        let totalPass = recomputedMask == checkpointRequiredMask && trapFailures.isEmpty &&
            source.registerSetCalls == 36 && source.registerReadCalls == 36
        if failureStage == 11 && totalPass {
            malformed.append("predicate_stage_without_failure")
        }
        if checkpointValid == 1 {
            if !totalPass { malformed.append("checkpoint_valid_without_pass") }
            if failureStage == 11 { malformed.append("checkpoint_valid_with_predicate_failure") }
        } else if failureStage != 11 || totalPass {
            malformed.append("checkpoint_rejection_join")
        }
        if checkpointValid > 1 { malformed.append("checkpoint_valid_domain") }
        return CheckpointAssessment(
            integrity: malformed.isEmpty ? (totalPass ? "VALID_PASS" : "VALID_FAILURE") : "MALFORMED",
            failures: malformed.isEmpty ? failures : malformed.map { "malformed.\($0)" } + failures)
    }

    private static func sctlrTransitionAssessment(
        _ transition: GuestH3SCTLRTransitionDiagnostic,
        checkpoint: GuestH3CheckpointPredicateDiagnostic,
        source: GuestH3NativePhaseDiagnostic,
        failureStage: Int32,
        outcome: UInt32
    ) -> SCTLRTransitionAssessment {
        let preSampled = transition.sampledMask & 0x2 != 0
        let postSampled = transition.sampledMask & 0x4 != 0
        let requestedXORPre = preSampled
            ? transition.requested ^ transition.sourcePreEntry : nil
        let preXORPost = postSampled
            ? transition.sourcePreEntry ^ transition.sourcePostExit : nil
        var malformed: [String] = []

        func reject(_ token: String) {
            malformed.append("malformed.sctlr_transition.\(token)")
        }

        let checkpointEvaluated = checkpoint.evaluatedMask != 0
        let sourceRunEntered = source.runEntries == 1
        let sourceHasNotRun = source.runEntries == 0 && source.runStatus == Int32.min
        let sourceRunReturned = sourceRunEntered && source.runStatus == 0
        if transition.schemaVersion == 0 {
            if transition.sampledMask != 0 ||
                transition.sourcePreEntryReadEntries != 0 ||
                transition.sourcePostExitReadEntries != 0 ||
                transition.sourcePreEntryReadStatus != 0 ||
                transition.sourcePostExitReadStatus != 0 ||
                transition.reservedZero0 != 0 || transition.reservedZero1 != 0 ||
                transition.requested != 0 || transition.sourcePreEntry != 0 ||
                transition.sourcePostExit != 0 {
                reject("inactive_payload")
            }
            let stageZeroClaimReturn = failureStage == 0 &&
                (outcome == UInt32(EPR_GUEST_BUSY) ||
                 outcome == UInt32(EPR_GUEST_QUARANTINED))
            let stoppedBeforePreRead = stageZeroClaimReturn ||
                [Int32(1), 2, 3, 4, 5, 6, 7, 18].contains(failureStage)
            if !sourceHasNotRun || checkpointEvaluated || !stoppedBeforePreRead {
                reject("zero_chronology")
            }
            return SCTLRTransitionAssessment(
                integrity: malformed.isEmpty ? "VALID_NOT_SAMPLED" : "MALFORMED",
                failures: malformed, requestedXORPreEntry: nil,
                preEntryXORPostExit: nil)
        }

        if outcome == UInt32(EPR_GUEST_BUSY) ||
            outcome == UInt32(EPR_GUEST_QUARANTINED) {
            reject("active_claim_outcome")
        }
        if transition.schemaVersion != 1 { reject("schema_version") }
        if transition.sampledMask & ~sctlrTransitionRequiredMask != 0 {
            reject("sampled_unknown_bits")
        }
        if ![UInt32(1), 3, 7].contains(transition.sampledMask) {
            reject("sampled_dependency")
        }
        if transition.reservedZero0 != 0 || transition.reservedZero1 != 0 {
            reject("reserved_zero")
        }
        if transition.requested != requestedSCTLR { reject("requested") }
        if transition.sourcePreEntryReadEntries > 1 { reject("pre_entry_count_domain") }
        if transition.sourcePostExitReadEntries > 1 { reject("post_exit_count_domain") }

        if preSampled {
            if transition.sourcePreEntryReadEntries != 1 ||
                transition.sourcePreEntryReadStatus != 0 {
                reject("pre_entry_success_join")
            }
        } else if transition.sourcePreEntryReadEntries == 0 {
            if transition.sourcePreEntryReadStatus != Int32.min {
                reject("pre_entry_unentered_status")
            }
            if transition.sourcePreEntry != 0 { reject("pre_entry_unsampled_value") }
        } else {
            if transition.sourcePreEntryReadStatus == 0 ||
                transition.sourcePreEntryReadStatus == Int32.min {
                reject("pre_entry_failure_status")
            }
            if transition.sourcePreEntry != 0 { reject("pre_entry_failed_value") }
        }

        if postSampled {
            if transition.sourcePostExitReadEntries != 1 ||
                transition.sourcePostExitReadStatus != 0 {
                reject("post_exit_success_join")
            }
        } else if transition.sourcePostExitReadEntries == 0 {
            if transition.sourcePostExitReadStatus != Int32.min {
                reject("post_exit_unentered_status")
            }
            if transition.sourcePostExit != 0 { reject("post_exit_unsampled_value") }
        } else {
            if transition.sourcePostExitReadStatus == 0 ||
                transition.sourcePostExitReadStatus == Int32.min {
                reject("post_exit_failure_status")
            }
            if transition.sourcePostExit != 0 { reject("post_exit_failed_value") }
        }

        let preReadFailed = transition.sampledMask == 1 &&
            transition.sourcePreEntryReadEntries == 1 &&
            transition.sourcePreEntryReadStatus != 0 &&
            transition.sourcePreEntryReadStatus != Int32.min
        let postReadFailed = transition.sampledMask == 3 &&
            transition.sourcePreEntryReadEntries == 1 &&
            transition.sourcePreEntryReadStatus == 0 &&
            transition.sourcePostExitReadEntries == 1 &&
            transition.sourcePostExitReadStatus != 0 &&
            transition.sourcePostExitReadStatus != Int32.min

        switch transition.sampledMask {
        case 1:
            if !preReadFailed || !sourceHasNotRun || checkpointEvaluated || failureStage != 7 {
                reject("pre_entry_failure_chronology")
            }
        case 3:
            if postReadFailed {
                if !sourceRunReturned || checkpointEvaluated || failureStage != 10 {
                    reject("post_exit_failure_chronology")
                }
            } else {
                let stoppedBeforeRun = sourceHasNotRun &&
                    [Int32(2), 8, 18].contains(failureStage)
                let failedRun = source.runEntries == 1 && source.runStatus != 0 &&
                    source.runStatus != Int32.min && failureStage == 9
                let stoppedBeforePostRead = stoppedBeforeRun || failedRun
                if transition.sourcePostExitReadEntries != 0 || checkpointEvaluated ||
                    !stoppedBeforePostRead {
                    reject("pre_entry_only_chronology")
                }
            }
        case 7:
            if !sourceRunReturned { reject("full_without_successful_run") }
            if failureStage == 1 { reject("full_at_admission_stage") }
            if checkpointEvaluated && transition.sourcePostExit != checkpoint.sctlr {
                reject("checkpoint_sctlr_join")
            }
        default:
            break
        }

        if checkpointEvaluated && transition.sampledMask != sctlrTransitionRequiredMask {
            reject("checkpoint_without_full_transition")
        }
        if sourceRunReturned && transition.sampledMask != sctlrTransitionRequiredMask &&
            !postReadFailed {
            reject("successful_run_without_full_transition")
        }
        if failureStage == 0 && outcome != UInt32(EPR_GUEST_PASS) {
            reject("stage_zero_outcome")
        }
        if outcome == UInt32(EPR_GUEST_PASS) && failureStage != 0 {
            reject("pass_with_failure_stage")
        }
        if outcome == UInt32(EPR_GUEST_PASS) &&
            transition.sampledMask != sctlrTransitionRequiredMask {
            reject("pass_without_full_transition")
        }

        let integrity: String
        if !malformed.isEmpty { integrity = "MALFORMED" }
        else if transition.sampledMask == 7 { integrity = "VALID_FULL" }
        else { integrity = "VALID_PARTIAL" }
        return SCTLRTransitionAssessment(integrity: integrity, failures: malformed,
            requestedXORPreEntry: requestedXORPre,
            preEntryXORPostExit: preXORPost)
    }

    private static func tupleBytes<T>(_ tuple: inout T, count: Int) throws -> Data {
        let bytes = withUnsafeBytes(of: &tuple) { Data($0) }
        try require(bytes.count == count, "H3 imported fixed-array width changed")
        return bytes
    }

    private static func page(prefix: Data) throws -> Data {
        try require(prefix.count <= pageBytes, "H3 page prefix exceeds its fixed page")
        var result = Data(repeating: 0, count: pageBytes)
        result.replaceSubrange(0..<prefix.count, with: prefix)
        return result
    }

    private static func phase(_ value: EPRGuestH3PhaseResult, pc: UInt64,
                              x4: UInt64, registerReads: UInt32, label: String) throws {
        try require(value.run_entries == 1 && value.mappings_entered == 3 &&
            value.register_set_calls == 36 && value.register_read_calls == registerReads &&
            value.conserved == 1, "H3 \(label) entry/conservation counters rejected")
        try require(value.vm_create_status == 0 && value.map_status.0 == 0 &&
            value.map_status.1 == 0 && value.map_status.2 == 0 &&
            value.vcpu_create_status == 0 && value.register_status == 0 &&
            value.run_status == 0 && value.read_register_status == 0 &&
            value.vcpu_destroy_status == 0 && value.unmap_status.0 == 0 &&
            value.unmap_status.1 == 0 && value.unmap_status.2 == 0 &&
            value.vm_destroy_status == 0 && value.host_unmap_status.0 == 0 &&
            value.host_unmap_status.1 == 0 && value.host_unmap_status.2 == 0,
            "H3 \(label) native status rejected")
        let dfsc = value.syndrome & 63
        try require(value.generation > 0 && value.entry_ticks > 0 &&
            value.entry_ticks <= value.exit_ticks && value.exception_reason == 1 &&
            (4...7).contains(dfsc) && value.syndrome == (0x9384_0040 | dfsc) &&
            value.pc == pc && value.fault_ipa == 0x1000_c000 &&
            value.fault_virtual_address == 0x1000_c000 && value.x4 == x4,
            "H3 \(label) exit frame rejected")
    }

    private static func phaseSemantic(_ phase: EPRGuestH3PhaseResult) -> GuestCBORValue {
        .map([
            "conserved": .text(String(phase.conserved)),
            "entry_ticks": .text(String(phase.entry_ticks)),
            "exception_reason": .text(String(phase.exception_reason)),
            "exit_ticks": .text(String(phase.exit_ticks)),
            "fault_ipa": .text(String(phase.fault_ipa)),
            "fault_virtual_address": .text(String(phase.fault_virtual_address)),
            "generation": .text(String(phase.generation)),
            "mappings_entered": .text(String(phase.mappings_entered)),
            "pc": .text(String(phase.pc)),
            "register_read_calls": .text(String(phase.register_read_calls)),
            "register_set_calls": .text(String(phase.register_set_calls)),
            "run_entries": .text(String(phase.run_entries)),
            "statuses": .map([
                "host_unmap": .array([phase.host_unmap_status.0, phase.host_unmap_status.1,
                                      phase.host_unmap_status.2].map { .text(String($0)) }),
                "map": .array([phase.map_status.0, phase.map_status.1,
                                phase.map_status.2].map { .text(String($0)) }),
                "read_register": .text(String(phase.read_register_status)),
                "register": .text(String(phase.register_status)),
                "run": .text(String(phase.run_status)),
                "unmap": .array([phase.unmap_status.0, phase.unmap_status.1,
                                  phase.unmap_status.2].map { .text(String($0)) }),
                "vcpu_create": .text(String(phase.vcpu_create_status)),
                "vcpu_destroy": .text(String(phase.vcpu_destroy_status)),
                "vm_create": .text(String(phase.vm_create_status)),
                "vm_destroy": .text(String(phase.vm_destroy_status)),
            ]),
            "syndrome": .text(String(phase.syndrome)),
            "x4": .text(String(phase.x4)),
        ])
    }

    private static func stateSemantic(_ binding: LiveBinding) -> GuestCBORValue {
        .map([
            "authority_vector": .text("00000000"),
            "durable": .bool(false),
            "gate_e": .text("ABSTAIN"),
            "h4_entered": .bool(false),
            "lifecycle": .map([
                "cancellation_calls": .text(String(binding.cancellationCalls)),
                "cancellation_requested": .text(String(binding.cancellationRequested)),
                "cancellation_status": .text(String(binding.cancellationStatus)),
                "end_ticks": .text(String(binding.endTicks)),
                "resources_quarantined": .text(String(binding.resourcesQuarantined)),
                "start_ticks": .text(String(binding.startTicks)),
                "timebase_denom": .text(String(binding.timebaseDenom)),
                "timebase_numer": .text(String(binding.timebaseNumer)),
                "watchdog_create_entries": .text(String(binding.watchdogCreateEntries)),
                "watchdog_join_entries": .text(String(binding.watchdogJoinEntries)),
                "watchdog_wait_status": .text(String(binding.watchdogWaitStatus)),
            ]),
            "native_roots": .map([
                "checkpoint_merkle": .text(binding.checkpointRoot),
                "cursor_sha256": .text(binding.cursorDigest),
                "guest_image_sha256": .text(binding.imageDigest),
                "terminal_merkle": .text(binding.terminalRoot),
            ]),
            "native_result": .map([
                "abi_version": .text(String(binding.abiVersion)),
                "checkpoint_valid": .text(String(binding.checkpointValid)),
                "cursor_decoded": .text(String(binding.cursorDecoded)),
                "cursor_restored": .text(String(binding.cursorRestored)),
                "cursor_sealed": .text(String(binding.cursorSealed)),
                "execution_pass": .text(String(binding.executionPass)),
                "failure_stage": .text(String(binding.failureStage)),
                "first_error": .text(String(binding.firstError)),
                "outcome": .text(String(binding.outcome)),
                "signing_admitted": .text(String(binding.signingAdmitted)),
                "signing_error": .text(String(binding.signingError)),
                "source_conserved": .text(String(binding.sourceConserved)),
                "target_conserved": .text(String(binding.targetConserved)),
                "teardown_pass": .text(String(binding.teardownPass)),
                "terminal_valid": .text(String(binding.terminalValid)),
                "watchdog_create_status": .text(String(binding.watchdogCreateStatus)),
                "watchdog_fired": .text(String(binding.watchdogFired)),
                "watchdog_join_status": .text(String(binding.watchdogJoinStatus)),
            ]),
            "projection_disposition": .text("IN_MEMORY_PRESENTATION_ONLY"),
            "readiness": .map([
                "cursor_root": .text(binding.readinessCursorRoot),
                "graph_root": .text(binding.readinessGraphRoot),
                "outcome": .text("PASS_H3_CURSOR_CONTRACT_ONLY"),
                "receipt_root": .text(binding.readinessReceiptRoot),
            ]),
            "schema": .text(liveStateSchema),
            "source": phaseSemantic(binding.source),
            "stage_id": .text("hypervisor_explicit_state_cursor_resume_v1"),
            "status": .text("PASS"),
            "target": phaseSemantic(binding.target),
        ])
    }

    private static func transitionSemantic(id: String, relation: String,
                                           inputs: [String], outputs: [String],
                                           binding: LiveBinding) -> GuestCBORValue {
        .map([
            "authority_vector": .text("00000000"),
            "durable": .bool(false),
            "gate_e": .text("ABSTAIN"),
            "h4_entered": .bool(false),
            "id": .text(id),
            "inputs": .array(inputs.map { .text($0) }),
            "outputs": .array(outputs.map { .text($0) }),
            "predicate": .text(relation),
            "readiness_graph_root": .text(binding.readinessGraphRoot),
            "readiness_receipt_root": .text(binding.readinessReceiptRoot),
            "schema": .text(liveTransitionSchema),
        ])
    }

    private static func projectionLeaves(_ projection: HypervisorStageProjection,
                                         schema: String, role: String) -> [GenesisLeaf] {
        [GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
         GenesisLeaf(label: "\(role).json", payload: projection.json),
         GenesisLeaf(label: "\(role).cbor", payload: projection.cbor)]
    }

    private static func project(_ semantic: GuestCBORValue, schema: String,
                                role: String) throws -> HypervisorStageProjection {
        let json = try StageCanonicalJSON.encode(semantic)
        let cbor = try GuestCBOR.encode(semantic)
        try require(!json.isEmpty && !cbor.isEmpty && json.count <= maximumProjectionBytes &&
            cbor.count <= maximumProjectionBytes, "H3 live projection exceeds its bound")
        let partial = HypervisorStageProjection(json: json, cbor: cbor, root: "")
        let projection = HypervisorStageProjection(json: json, cbor: cbor,
            root: try MerkleGenesis.commit(projectionLeaves(partial, schema: schema, role: role)).root)
        try require(try verifyProjection(projection, schema: schema, role: role) == semantic,
            "H3 live projection self-verification rejected")
        return projection
    }

    private static func verifyProjection(_ projection: HypervisorStageProjection,
                                         schema: String, role: String) throws -> GuestCBORValue {
        try require(!projection.json.isEmpty && !projection.cbor.isEmpty &&
            projection.json.count <= maximumProjectionBytes &&
            projection.cbor.count <= maximumProjectionBytes,
            "H3 live projection is outside its bound")
        let fromJSON = try StageCanonicalJSON.decode(projection.json)
        let fromCBOR = try GuestCBOR.decode(projection.cbor)
        let canonicalJSON = try StageCanonicalJSON.encode(fromJSON)
        let canonicalCBOR = try GuestCBOR.encode(fromCBOR)
        try require(fromJSON == fromCBOR && canonicalJSON == projection.json &&
            canonicalCBOR == projection.cbor,
            "H3 live JSON/CBOR round-trip join rejected")
        guard case .map(let values) = fromJSON else {
            throw ProvenanceFailure("H3 live projection must be a map")
        }
        try require(values["schema"] == .text(schema) &&
            MerkleGenesis.verify(projectionLeaves(projection, schema: schema, role: role),
                                 expectedRoot: projection.root),
            "H3 live projection root rejected")
        return fromJSON
    }

    private static func contentRoot(_ semantic: GuestCBORValue,
                                    schema: String, role: String) throws -> String {
        try project(semantic, schema: schema, role: role).root
    }

    private static func graphSemantic(stateRoot: String,
                                      binding: LiveBinding) throws -> GuestCBORValue {
        func node(_ id: String, _ partition: String, _ type: String,
                  _ schema: String, _ root: String) -> GuestCBORValue {
            .map(["content_root": .text(root), "content_schema": .text(schema),
                  "id": .text(id), "node_type": .text(type),
                  "partition": .text(partition)])
        }
        func edge(_ from: String, _ to: String, _ position: Int,
                  _ relation: String) -> GuestCBORValue {
            .map(["from": .text(from), "position": .text(String(position)),
                  "relation": .text(relation), "to": .text(to)])
        }
        let transitions: [(String, String, [String], [String])] = [
            ("readiness-live-join", "STATIC_READINESS_JOINS_LIVE_STATE",
             [binding.readinessReceiptRoot, binding.readinessGraphRoot,
              binding.readinessCursorRoot], [stateRoot]),
            ("cursor-checkpoint", "CURSOR_DIGEST_COMMITS_CHECKPOINT",
             [binding.cursorDigest], [binding.checkpointRoot]),
            ("checkpoint-terminal", "CHECKPOINT_RESUMES_TO_TERMINAL",
             [binding.checkpointRoot], [binding.terminalRoot]),
            ("authority-boundary", "PRESENTATION_CANNOT_ELEVATE_AUTHORITY",
             [binding.terminalRoot], [stateRoot]),
        ]
        let transitionNodes = try transitions.map { item in
            node(item.0, "transition", "verified-transition", liveTransitionSchema,
                 try contentRoot(transitionSemantic(id: item.0, relation: item.1,
                     inputs: item.2, outputs: item.3, binding: binding),
                     schema: liveTransitionSchema, role: "transition"))
        }
        let stateNodes: [GuestCBORValue] = [
            node("static-readiness-receipt", "state", "static-readiness-receipt",
                 HypervisorStageH3Cursor.receiptSchema, binding.readinessReceiptRoot),
            node("static-readiness-graph", "state", "static-readiness-graph",
                 HypervisorStageH3Cursor.graphSchema, binding.readinessGraphRoot),
            node("static-readiness-cursor", "state", "static-readiness-cursor",
                 HypervisorStageH3Cursor.cursorSchema, binding.readinessCursorRoot),
            node("native-cursor", "state", "native-cursor",
                 "ergentics.hypervisor.guest.h3.cursor.v1", binding.cursorDigest),
            node("native-checkpoint", "state", "native-checkpoint",
                 checkpointSchema, binding.checkpointRoot),
            node("native-terminal", "state", "native-terminal",
                 terminalSchema, binding.terminalRoot),
            node("live-state", "state", "verified-live-state", liveStateSchema, stateRoot),
        ]
        let edges = [
            edge("static-readiness-receipt", "readiness-live-join", 0, "READINESS_RECEIPT_INPUT"),
            edge("static-readiness-graph", "readiness-live-join", 1, "READINESS_GRAPH_INPUT"),
            edge("static-readiness-cursor", "readiness-live-join", 2, "READINESS_CURSOR_INPUT"),
            edge("readiness-live-join", "live-state", 3, "VERIFIES_LIVE_STATE"),
            edge("native-cursor", "cursor-checkpoint", 4, "CURSOR_INPUT"),
            edge("cursor-checkpoint", "native-checkpoint", 5, "COMMITS_CHECKPOINT"),
            edge("native-checkpoint", "checkpoint-terminal", 6, "CHECKPOINT_INPUT"),
            edge("checkpoint-terminal", "native-terminal", 7, "DERIVES_TERMINAL"),
            edge("native-terminal", "authority-boundary", 8, "TERMINAL_INPUT"),
            edge("authority-boundary", "live-state", 9, "BOUNDS_PRESENTATION"),
        ]
        return .map([
            "authority_vector": .text("00000000"),
            "bipartite": .bool(true),
            "bipartite_rule": .text("STATE_TO_TRANSITION_OR_TRANSITION_TO_STATE_ONLY"),
            "durable": .bool(false),
            "edge_count": .text(String(edges.count)),
            "edges": .array(edges),
            "gate_e": .text("ABSTAIN"),
            "h4_entered": .bool(false),
            "node_count": .text(String(stateNodes.count + transitionNodes.count)),
            "nodes": .array(stateNodes + transitionNodes),
            "schema": .text(liveGraphSchema),
        ])
    }

    private static func receiptLeaves(_ receipt: GuestH3LiveProjectionReceipt,
                                      binding: LiveBinding) -> [GenesisLeaf] {
        [GenesisLeaf(label: "schema", payload: Data(liveReceiptSchema.utf8)),
         GenesisLeaf(label: "graph.json", payload: receipt.graph.json),
         GenesisLeaf(label: "graph.cbor", payload: receipt.graph.cbor),
         GenesisLeaf(label: "state.json", payload: receipt.state.json),
         GenesisLeaf(label: "state.cbor", payload: receipt.state.cbor),
         GenesisLeaf(label: "readiness_receipt_root", payload: Data(binding.readinessReceiptRoot.utf8)),
         GenesisLeaf(label: "readiness_graph_root", payload: Data(binding.readinessGraphRoot.utf8)),
         GenesisLeaf(label: "cursor_digest", payload: Data(binding.cursorDigest.utf8)),
         GenesisLeaf(label: "checkpoint_root", payload: Data(binding.checkpointRoot.utf8)),
         GenesisLeaf(label: "terminal_root", payload: Data(binding.terminalRoot.utf8))]
    }

    private static func makeLiveReceipt(_ binding: LiveBinding) throws -> GuestH3LiveProjectionReceipt {
        let state = try project(stateSemantic(binding), schema: liveStateSchema, role: "state")
        let graph = try project(try graphSemantic(stateRoot: state.root, binding: binding),
                                schema: liveGraphSchema, role: "graph")
        let partial = GuestH3LiveProjectionReceipt(state: state, graph: graph, root: "")
        let receipt = GuestH3LiveProjectionReceipt(state: state, graph: graph,
            root: try MerkleGenesis.commit(receiptLeaves(partial, binding: binding)).root)
        try verifyLiveReceipt(receipt, binding: binding)
        return receipt
    }

    private static func verifyBipartiteGraph(_ semantic: GuestCBORValue) throws {
        guard case .map(let graph) = semantic,
              graph["bipartite"] == .bool(true),
              graph["bipartite_rule"] == .text("STATE_TO_TRANSITION_OR_TRANSITION_TO_STATE_ONLY"),
              case .array(let nodes) = graph["nodes"],
              case .array(let edges) = graph["edges"],
              graph["node_count"] == .text(String(nodes.count)),
              graph["edge_count"] == .text(String(edges.count)) else {
            throw ProvenanceFailure("H3 live graph inventory rejected")
        }
        var partitions: [String: String] = [:]
        for node in nodes {
            guard case .map(let fields) = node,
                  case .text(let id) = fields["id"], !id.isEmpty,
                  case .text(let partition) = fields["partition"],
                  partition == "state" || partition == "transition",
                  case .text(let root) = fields["content_root"],
                  root.utf8.count == 64 && root.utf8.allSatisfy({
                      (48...57).contains($0) || (97...102).contains($0)
                  }), partitions[id] == nil else {
                throw ProvenanceFailure("H3 live graph node rejected")
            }
            partitions[id] = partition
        }
        for (position, edge) in edges.enumerated() {
            guard case .map(let fields) = edge,
                  case .text(let from) = fields["from"],
                  case .text(let to) = fields["to"],
                  fields["position"] == .text(String(position)),
                  let fromPartition = partitions[from], let toPartition = partitions[to],
                  fromPartition != toPartition else {
                throw ProvenanceFailure("H3 live graph edge violates bipartition")
            }
        }
    }

    private static func verifyLiveReceipt(_ receipt: GuestH3LiveProjectionReceipt,
                                          binding: LiveBinding) throws {
        let state = try verifyProjection(receipt.state, schema: liveStateSchema, role: "state")
        try require(state == stateSemantic(binding), "H3 live state projection is not exact")
        let graph = try verifyProjection(receipt.graph, schema: liveGraphSchema, role: "graph")
        try verifyBipartiteGraph(graph)
        try require(graph == graphSemantic(stateRoot: receipt.state.root, binding: binding),
            "H3 live bipartite graph is not exact")
        try require(try MerkleGenesis.verify(receiptLeaves(receipt, binding: binding),
                                             expectedRoot: receipt.root),
            "H3 live receipt root rejected")
    }

    private static func binding(_ value: EPRGuestH3CursorResumeResult,
                                readiness: HypervisorStageH3VerifiedResult,
                                cursorDigest: Data, checkpointRoot: Data,
                                terminalRoot: Data) -> LiveBinding {
        LiveBinding(readinessReceiptRoot: readiness.receiptRoot,
            readinessGraphRoot: readiness.graphRoot,
            readinessCursorRoot: readiness.cursorRoot,
            cursorDigest: cursorDigest.hex, checkpointRoot: checkpointRoot.hex,
            terminalRoot: terminalRoot.hex, imageDigest: imageSHA256,
            source: value.source, target: value.target,
            abiVersion: value.abi_version, outcome: value.outcome,
            executionPass: value.execution_pass, teardownPass: value.teardown_pass,
            signingAdmitted: value.signing_admitted,
            cursorSealed: value.cursor_sealed, cursorDecoded: value.cursor_decoded,
            cursorRestored: value.cursor_restored,
            checkpointValid: value.checkpoint_valid, terminalValid: value.terminal_valid,
            sourceConserved: value.source_conserved, targetConserved: value.target_conserved,
            startTicks: value.start_ticks, endTicks: value.end_ticks,
            timebaseNumer: value.timebase_numer, timebaseDenom: value.timebase_denom,
            watchdogCreateEntries: value.watchdog_create_entries,
            watchdogJoinEntries: value.watchdog_join_entries,
            watchdogFired: value.watchdog_fired,
            watchdogCreateStatus: value.watchdog_create_status,
            watchdogJoinStatus: value.watchdog_join_status,
            watchdogWaitStatus: value.watchdog_wait_status,
            cancellationRequested: value.cancellation_requested,
            cancellationCalls: value.cancellation_calls,
            cancellationStatus: value.cancellation_status,
            resourcesQuarantined: value.resources_quarantined,
            failureStage: value.failure_stage, firstError: value.first_error,
            signingError: value.signing_error)
    }

    /// Value-only hostile-test seam. It reads no file and performs no native
    /// reservation/run; the input is a copied result and output is inert bytes.
    static func projectionForTesting(_ returned: EPRGuestH3CursorResumeResult) throws
        -> GuestH3LiveProjectionReceipt {
        let readinessReceipt = try HypervisorStageH3Cursor.runContract()
        let readiness = try HypervisorStageH3Cursor.verifyContract(readinessReceipt)
        var value = returned
        let cursorDigest = try tupleBytes(&value.cursor_sha256, count: 32)
        let checkpointRoot = try tupleBytes(&value.checkpoint_merkle, count: 32)
        let terminalRoot = try tupleBytes(&value.terminal_merkle, count: 32)
        return try makeLiveReceipt(binding(value, readiness: readiness,
            cursorDigest: cursorDigest, checkpointRoot: checkpointRoot,
            terminalRoot: terminalRoot))
    }

    /// Reconstructs the recorded projection, not the missing native cursor or
    /// diagnostic evidence. This cannot mint a live reservation or H4 handoff.
    static func reconstructSaved(state: GuestCBORValue, graph: GuestCBORValue) throws
        -> GuestH3LiveProjectionReceipt {
        func map(_ value: GuestCBORValue?) throws -> [String: GuestCBORValue] {
            guard case .map(let fields) = value else { throw ProvenanceFailure("Saved H3 map rejected") }
            return fields
        }
        func number<T: FixedWidthInteger>(_ fields: [String: GuestCBORValue], _ key: String,
                                          as: T.Type = T.self) throws -> T {
            guard case .text(let text) = fields[key], let value = T(text), String(value) == text else {
                throw ProvenanceFailure("Saved H3 number rejected: \(key)")
            }
            return value
        }
        func digest(_ fields: [String: GuestCBORValue], _ key: String) throws -> Data {
            guard case .text(let text) = fields[key], text.utf8.count == 64,
                  text.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }) else {
                throw ProvenanceFailure("Saved H3 digest rejected: \(key)")
            }
            let bytes = Array(text.utf8)
            func nibble(_ b: UInt8) -> UInt8 { b <= 57 ? b - 48 : b - 87 }
            return Data(stride(from: 0, to: 64, by: 2).map { nibble(bytes[$0]) * 16 + nibble(bytes[$0 + 1]) })
        }
        func recordedPhase(_ fields: [String: GuestCBORValue], terminal: Bool) throws -> EPRGuestH3PhaseResult {
            var result = EPRGuestH3PhaseResult()
            result.run_entries = 1; result.mappings_entered = 3
            result.register_set_calls = 36; result.register_read_calls = terminal ? 38 : 36
            result.conserved = 1; result.exception_reason = 1
            result.pc = terminal ? 0x1000_007c : 0x1000_0050
            result.x4 = terminal ? 2 : 1
            result.fault_ipa = 0x1000_c000; result.fault_virtual_address = 0x1000_c000
            result.generation = try number(fields, "generation")
            result.entry_ticks = try number(fields, "entry_ticks")
            result.exit_ticks = try number(fields, "exit_ticks")
            result.syndrome = try number(fields, "syndrome")
            try phase(result, pc: result.pc, x4: result.x4,
                      registerReads: result.register_read_calls, label: "saved phase")
            try require(phaseSemantic(result) == .map(fields), "Saved H3 phase differs from its fixed PASS contract")
            return result
        }
        let fields = try map(state), lifecycle = try map(fields["lifecycle"])
        let roots = try map(fields["native_roots"]), native = try map(fields["native_result"])
        var value = EPRGuestH3CursorResumeResult()
        value.abi_version = 5; value.outcome = 1; value.execution_pass = 1; value.teardown_pass = 1
        value.signing_admitted = 1; value.cursor_sealed = 1; value.cursor_decoded = 1; value.cursor_restored = 1
        value.checkpoint_valid = 1; value.terminal_valid = 1; value.source_conserved = 1; value.target_conserved = 1
        value.watchdog_create_entries = 2; value.watchdog_join_entries = 2
        value.cancellation_status = Int32.min
        value.watchdog_wait_status = try number(lifecycle, "watchdog_wait_status")
        value.start_ticks = try number(lifecycle, "start_ticks")
        value.end_ticks = try number(lifecycle, "end_ticks")
        value.timebase_numer = try number(lifecycle, "timebase_numer")
        value.timebase_denom = try number(lifecycle, "timebase_denom")
        value.source = try recordedPhase(map(fields["source"]), terminal: false)
        value.target = try recordedPhase(map(fields["target"]), terminal: true)
        try require(value.start_ticks > 0 && value.start_ticks <= value.source.entry_ticks &&
            value.source.exit_ticks <= value.target.entry_ticks && value.target.exit_ticks <= value.end_ticks &&
            value.timebase_numer > 0 && value.timebase_denom > 0 && value.source.generation & 1 == 1 &&
            value.source.generation < UInt64.max && value.target.generation == value.source.generation + 1 &&
            [Int32.min, 0, ETIMEDOUT].contains(value.watchdog_wait_status), "Saved H3 lifecycle rejected")
        // Exact reconstructed state below also rejects unknown or substituted
        // flags, statuses, image/readiness identities and source-only labels.
        _ = native
        let readiness = try HypervisorStageH3Cursor.verifyContract(HypervisorStageH3Cursor.runContract())
        let receipt = try makeLiveReceipt(binding(value, readiness: readiness,
            cursorDigest: digest(roots, "cursor_sha256"),
            checkpointRoot: digest(roots, "checkpoint_merkle"),
            terminalRoot: digest(roots, "terminal_merkle")))
        try require(StageCanonicalJSON.decode(receipt.state.json) == state &&
            StageCanonicalJSON.decode(receipt.graph.json) == graph,
            "Saved H3 state/graph is not the exact recorded projection")
        return receipt
    }

    /// Independently reconstructs an inert receipt against a copied result.
    /// It cannot turn a projection into an execution or persistence authority.
    static func verifyProjectionForTesting(_ receipt: GuestH3LiveProjectionReceipt,
                                           native returned: EPRGuestH3CursorResumeResult) throws {
        let readinessReceipt = try HypervisorStageH3Cursor.runContract()
        let readiness = try HypervisorStageH3Cursor.verifyContract(readinessReceipt)
        var value = returned
        let cursorDigest = try tupleBytes(&value.cursor_sha256, count: 32)
        let checkpointRoot = try tupleBytes(&value.checkpoint_merkle, count: 32)
        let terminalRoot = try tupleBytes(&value.terminal_merkle, count: 32)
        try verifyLiveReceipt(receipt, binding: binding(value, readiness: readiness,
            cursorDigest: cursorDigest, checkpointRoot: checkpointRoot,
            terminalRoot: terminalRoot))
    }

    static func verify(_ returned: EPRGuestH3CursorResumeResult) throws -> GuestH3Presentation {
        // This independent, effect-free contract can reject a product/schema
        // mismatch, but it cannot grant live authority or H3 completion.
        let readinessReceipt = try HypervisorStageH3Cursor.runContract()
        let readiness = try HypervisorStageH3Cursor.verifyContract(readinessReceipt)
        try require(readiness.outcome == "PASS_H3_CURSOR_CONTRACT_ONLY" &&
            readiness.gateE == "ABSTAIN" && readiness.authorityVector == "00000000" &&
            readiness.vmEntryCount == 0 && !readiness.stageCompleted &&
            !readiness.liveResumeAuthorized, "H3 static contract crossed its no-effects boundary")

        var value = returned
        try require(value.abi_version == 5 && value.outcome == 1 &&
            value.execution_pass == 1 && value.teardown_pass == 1 && value.signing_admitted == 1 &&
            value.cursor_sealed == 1 && value.cursor_decoded == 1 && value.cursor_restored == 1 &&
            value.checkpoint_valid == 1 && value.terminal_valid == 1 &&
            value.source_conserved == 1 && value.target_conserved == 1,
            "H3 native PASS predicates rejected")
        try require(value.cancellation_requested == 0 && value.cancellation_calls == 0 &&
            value.watchdog_fired == 0 && value.watchdog_create_entries == 2 &&
            value.watchdog_join_entries == 2 && value.resources_quarantined == 0,
            "H3 cancellation/watchdog predicates rejected")
        try require(value.failure_stage == 0 && value.first_error == 0 && value.signing_error == 0 &&
            value.cancellation_status == Int32.min && value.watchdog_create_status == 0 &&
            value.watchdog_join_status == 0 &&
            (value.watchdog_wait_status == Int32.min || value.watchdog_wait_status == 0 ||
             value.watchdog_wait_status == ETIMEDOUT),
            "H3 outer native statuses rejected")
        try require(value.start_ticks > 0 && value.start_ticks <= value.source.entry_ticks &&
            value.source.exit_ticks <= value.target.entry_ticks &&
            value.target.exit_ticks <= value.end_ticks && value.timebase_numer > 0 &&
            value.timebase_denom > 0, "H3 two-interval clock order rejected")
        try phase(value.source, pc: 0x1000_0050, x4: 1, registerReads: 36,
                  label: "checkpoint")
        try phase(value.target, pc: 0x1000_007c, x4: 2, registerReads: 38,
                  label: "terminal")
        let checkpoint = GuestH3CheckpointPredicateDiagnostic(value.checkpoint_diagnostic)
        let sctlrTransition = GuestH3SCTLRTransitionDiagnostic(
            value.sctlr_transition_diagnostic)
        let sourceDiagnostic = GuestH3NativePhaseDiagnostic(value.source)
        let checkpointAssessment = checkpointAssessment(checkpoint,
            source: sourceDiagnostic,
            checkpointValid: value.checkpoint_valid, failureStage: value.failure_stage)
        try require(checkpointAssessment.integrity == "VALID_PASS" &&
            checkpointAssessment.failures.isEmpty,
            "H3 checkpoint diagnostic join rejected")
        let transitionAssessment = sctlrTransitionAssessment(sctlrTransition,
            checkpoint: checkpoint, source: sourceDiagnostic,
            failureStage: value.failure_stage, outcome: value.outcome)
        try require(transitionAssessment.integrity == "VALID_FULL" &&
            transitionAssessment.failures.isEmpty,
            "H3 SCTLR transition diagnostic join rejected")
        try require(value.source.generation & 1 == 1 &&
            value.source.generation < UInt64.max &&
            value.target.generation == value.source.generation + 1,
            "H3 fresh phase-generation successor join rejected")

        guard let imagePointer = epr_guest_h3_image_bytes() else {
            throw ProvenanceFailure("H3 fixed guest image is unavailable")
        }
        let admittedImageSize = Int(epr_guest_h3_image_size())
        try require(admittedImageSize == imageBytes && epr_guest_h3_image_load_address() == 0x1000_0000 &&
            epr_guest_h3_checkpoint_instruction_offset() == 0x50 &&
            epr_guest_h3_resume_instruction_offset() == 0x54 &&
            epr_guest_h3_terminal_instruction_offset() == 0x7c,
            "H3 fixed image metadata rejected")
        let image = Data(bytes: imagePointer, count: admittedImageSize)
        try require(GuestContract.hash(image) == imageSHA256, "H3 fixed image digest rejected")

        try require(value.cursor_evidence.byte_count == UInt32(cursorBytes),
            "H3 cursor evidence length rejected")
        let evidence = try tupleBytes(&value.cursor_evidence.bytes, count: cursorBytes)
        let cursorDigest = try tupleBytes(&value.cursor_sha256, count: 32)
        let checkpointReply = try tupleBytes(&value.checkpoint_reply, count: 32)
        let terminalReply = try tupleBytes(&value.final_reply, count: 32)
        let checkpointRoot = try tupleBytes(&value.checkpoint_merkle, count: 32)
        let terminalRoot = try tupleBytes(&value.terminal_merkle, count: 32)
        try require(checkpointReply == GuestContract.frame([1, 1, 42, 0]) &&
            terminalReply == GuestContract.frame([2, 1, 42, 43]),
            "H3 fixed reply frames rejected")

        let imagePage = try page(prefix: image)
        let requestPage = try page(prefix: GuestContract.request)
        let checkpointPage = try page(prefix: checkpointReply)
        var reader = CursorReader(bytes: evidence)
        try require(try reader.take(8) == Data([0x45, 0x50, 0x52, 0x48, 0x33, 0x45, 0x32, 0]),
            "H3 evidence magic rejected")
        let header: [UInt64] = [2, value.source.generation, value.target.generation,
            2, 3, 31, 4, UInt64(imageBytes), UInt64(pageBytes), 0x50, 0x54, 0x7c,
            0x1000_c000, 4, 1, 2]
        for word in header {
            try require(try reader.word() == word, "H3 evidence header rejected")
        }
        let registers: [UInt64] = [0x1000_4000, 0x1000_8000, 0, 0x1000_c000,
                                   1, 1, 42, 23] + Array(repeating: 0, count: 23)
        for register in registers {
            try require(try reader.word() == register, "H3 checkpoint GPR rejected")
        }
        for system in [UInt64(0x6000_03c5), 0x30d0_0980, 0x1000_bff0, 0] {
            try require(try reader.word() == system, "H3 checkpoint system register rejected")
        }
        let regions: [[UInt64]] = [
            [1, 0x1000_0000, UInt64(pageBytes), 5],
            [2, 0x1000_4000, UInt64(pageBytes), 1],
            [3, 0x1000_8000, UInt64(pageBytes), 3],
        ]
        for expected in regions {
            for word in expected { try require(try reader.word() == word, "H3 region descriptor rejected") }
        }
        let evidenceImageHash = try reader.take(32)
        let evidenceRequestHash = try reader.take(32)
        let evidenceReplyHash = try reader.take(32)
        try require(evidenceImageHash.hex == GuestContract.hash(imagePage) &&
            evidenceRequestHash.hex == GuestContract.hash(requestPage) &&
            evidenceReplyHash.hex == GuestContract.hash(checkpointPage),
            "H3 exact-page digests rejected")
        let evidenceReply = try reader.take(32)
        let replyZeroTail = try reader.word()
        try require(evidenceReply == checkpointReply && replyZeroTail == UInt64(pageBytes - 32),
            "H3 evidence reply reconstruction metadata rejected")
        let evidenceDigest = try reader.take(32)
        try reader.finish()

        // The copy-only evidence is not the cursor. Reconstruct the exact
        // distinct internal frame: EPRCUR02 + canonical evidence body through
        // the page hashes + the complete checkpoint reply page.
        var internalCursor = Data("EPRCUR02".utf8)
        internalCursor.append(evidence.subdata(in: 8..<608))
        internalCursor.append(checkpointPage)
        try require(internalCursor.count == 16_992 &&
            GuestContract.hash(internalCursor) == cursorDigest.hex &&
            evidenceDigest == cursorDigest,
            "H3 full internal cursor digest reconstruction rejected")

        let checkpointLeaves = [
            GenesisLeaf(label: "cursor_digest", payload: cursorDigest),
            GenesisLeaf(label: "guest_image", payload: image),
            GenesisLeaf(label: "reply", payload: checkpointReply),
            GenesisLeaf(label: "request", payload: GuestContract.request),
            GenesisLeaf(label: "schema", payload: Data(checkpointSchema.utf8)),
        ]
        let terminalLeaves = [
            GenesisLeaf(label: "checkpoint_reply", payload: checkpointReply),
            GenesisLeaf(label: "cursor_digest", payload: cursorDigest),
            GenesisLeaf(label: "final_reply", payload: terminalReply),
            GenesisLeaf(label: "guest_image", payload: image),
            GenesisLeaf(label: "request", payload: GuestContract.request),
            GenesisLeaf(label: "schema", payload: Data(terminalSchema.utf8)),
        ]
        try require(try MerkleGenesis.verify(checkpointLeaves, expectedRoot: checkpointRoot.hex),
            "H3 checkpoint Merkle reconstruction rejected")
        try require(try MerkleGenesis.verify(terminalLeaves, expectedRoot: terminalRoot.hex),
            "H3 terminal Merkle reconstruction rejected")

        let liveBinding = binding(value, readiness: readiness,
            cursorDigest: cursorDigest, checkpointRoot: checkpointRoot,
            terminalRoot: terminalRoot)
        let liveReceipt = try makeLiveReceipt(liveBinding)
        // Verify a second time from only the immutable bytes and expected
        // copied facts before any presentation value can be returned.
        try verifyLiveReceipt(liveReceipt, binding: liveBinding)

        return GuestH3Presentation(status: "PASS", verificationDisposition: "VERIFIED_PASS",
            detail: "Swift independently reconstructed the immutable checkpoint cursor at 42; the same reserved lifetime consumed it into one fresh VM/vCPU interval, reached 43, and conserved both intervals. No journal or durable receipt was opened.",
            cursorSHA256: cursorDigest.hex, checkpointRoot: checkpointRoot.hex,
            terminalRoot: terminalRoot.hex,
            elapsed: "\(value.end_ticks - value.start_ticks) ticks × \(value.timebase_numer)/\(value.timebase_denom) ns",
            sourceGeneration: value.source.generation, targetGeneration: value.target.generation,
            sourceRunEntries: value.source.run_entries, targetRunEntries: value.target.run_entries,
            gateE: "ABSTAIN", authorityVector: "00000000", quarantined: false,
            projectionRoot: liveReceipt.root, graphRoot: liveReceipt.graph.root,
            durable: false, h4Entered: false, nativeDiagnostic: nil, receipt: liveReceipt)
    }

    private static func nativeDiagnostic(_ returned: EPRGuestH3CursorResumeResult,
                                         error: Error) -> GuestH3NativeDiagnostic {
        let stageName: String
        if let pointer = epr_guest_stage_name(returned.failure_stage) {
            stageName = String(cString: pointer)
        } else {
            stageName = "unavailable"
        }
        let baseClassification = returned.outcome == EPR_GUEST_PASS
            ? "SWIFT_RECONSTRUCTION_REJECTION" : "NATIVE_NONPASS"
        let source = GuestH3NativePhaseDiagnostic(returned.source)
        let checkpoint = GuestH3CheckpointPredicateDiagnostic(returned.checkpoint_diagnostic)
        let checkpointAssessment = checkpointAssessment(checkpoint, source: source,
            checkpointValid: returned.checkpoint_valid, failureStage: returned.failure_stage)
        let sctlrTransition = GuestH3SCTLRTransitionDiagnostic(
            returned.sctlr_transition_diagnostic)
        let transitionAssessment = sctlrTransitionAssessment(sctlrTransition,
            checkpoint: checkpoint, source: source,
            failureStage: returned.failure_stage, outcome: returned.outcome)
        let classification = checkpointAssessment.integrity == "MALFORMED" ||
            transitionAssessment.integrity == "MALFORMED"
            ? "NATIVE_WITNESS_MALFORMED" : baseClassification
        return GuestH3NativeDiagnostic(
            classification: classification, verifierError: String(describing: error),
            abiVersion: returned.abi_version, outcome: returned.outcome,
            executionPass: returned.execution_pass, teardownPass: returned.teardown_pass,
            signingAdmitted: returned.signing_admitted,
            cursorSealed: returned.cursor_sealed, cursorDecoded: returned.cursor_decoded,
            cursorRestored: returned.cursor_restored,
            cursorEvidenceByteCount: returned.cursor_evidence.byte_count,
            checkpointValid: returned.checkpoint_valid, terminalValid: returned.terminal_valid,
            sourceConserved: returned.source_conserved, targetConserved: returned.target_conserved,
            cancellationRequested: returned.cancellation_requested,
            cancellationCalls: returned.cancellation_calls,
            watchdogFired: returned.watchdog_fired,
            watchdogCreateEntries: returned.watchdog_create_entries,
            watchdogJoinEntries: returned.watchdog_join_entries,
            resourcesQuarantined: returned.resources_quarantined,
            failureStage: returned.failure_stage, failureStageName: stageName,
            firstError: returned.first_error, signingError: returned.signing_error,
            cancellationStatus: returned.cancellation_status,
            watchdogCreateStatus: returned.watchdog_create_status,
            watchdogJoinStatus: returned.watchdog_join_status,
            watchdogWaitStatus: returned.watchdog_wait_status,
            startTicks: returned.start_ticks, endTicks: returned.end_ticks,
            timebaseNumer: returned.timebase_numer, timebaseDenom: returned.timebase_denom,
            source: source, target: GuestH3NativePhaseDiagnostic(returned.target),
            checkpoint: checkpoint, sctlrTransition: sctlrTransition,
            checkpointIntegrity: checkpointAssessment.integrity,
            checkpointFailures: checkpointAssessment.failures,
            sctlrTransitionIntegrity: transitionAssessment.integrity,
            sctlrTransitionFailures: transitionAssessment.failures,
            requestedXORPreEntry: transitionAssessment.requestedXORPreEntry,
            preEntryXORPostExit: transitionAssessment.preEntryXORPostExit)
    }

    static func rejected(_ returned: EPRGuestH3CursorResumeResult, _ error: Error) -> GuestH3Presentation {
        let quarantined = returned.resources_quarantined != 0 || returned.teardown_pass != 1 ||
            returned.outcome == UInt32(EPR_GUEST_QUARANTINED)
        let status: String
        switch returned.outcome {
        case UInt32(EPR_GUEST_FAILED): status = "FAIL"
        case UInt32(EPR_GUEST_CANCELED): status = "CANCELED"
        case UInt32(EPR_GUEST_BUSY): status = "BUSY"
        case UInt32(EPR_GUEST_QUARANTINED): status = "QUARANTINED"
        default: status = "INCOMPLETE"
        }
        let diagnostic = nativeDiagnostic(returned, error: error)
        let detail: String
        switch diagnostic.classification {
        case "NATIVE_NONPASS":
            detail = "H3 native execution returned non-PASS. Exact copied diagnostic fields are shown below. No PASS or durable evidence was published."
        case "NATIVE_WITNESS_MALFORMED":
            detail = "H3 native checkpoint or SCTLR-transition witness was internally inconsistent. Raw copied values are retained below; no interpretation, PASS, or durable evidence was published."
        default:
            detail = "H3 native result did not satisfy independent Swift reconstruction: \(error). No PASS or durable evidence was published."
        }
        return GuestH3Presentation(status: status,
            verificationDisposition: diagnostic.classification,
            detail: detail,
            cursorSHA256: "", checkpointRoot: "", terminalRoot: "", elapsed: "",
            sourceGeneration: returned.source.generation, targetGeneration: returned.target.generation,
            sourceRunEntries: returned.source.run_entries, targetRunEntries: returned.target.run_entries,
            gateE: "ABSTAIN", authorityVector: "00000000", quarantined: quarantined,
            projectionRoot: "", graphRoot: "", durable: false, h4Entered: false,
            nativeDiagnostic: diagnostic, receipt: nil)
    }

    static func rejected(_ error: Error) -> GuestH3Presentation {
        GuestH3Presentation(status: "INCOMPLETE", verificationDisposition: "PRE_NATIVE_REJECTION",
            detail: "H3 was rejected before a verified native result: \(error). No PASS or durable evidence was published.",
            cursorSHA256: "", checkpointRoot: "", terminalRoot: "", elapsed: "",
            sourceGeneration: 0, targetGeneration: 0, sourceRunEntries: 0, targetRunEntries: 0,
            gateE: "ABSTAIN", authorityVector: "00000000", quarantined: false,
            projectionRoot: "", graphRoot: "", durable: false, h4Entered: false,
            nativeDiagnostic: nil, receipt: nil)
    }

    static func canceledBeforeNativeEntry() -> GuestH3Presentation {
        GuestH3Presentation(status: "CANCELED",
            verificationDisposition: "CANCELED_BEFORE_NATIVE_ENTRY",
            detail: "Stop was latched before H3 native entry. No cursor, VM result, or durable evidence was published.",
            cursorSHA256: "", checkpointRoot: "", terminalRoot: "", elapsed: "",
            sourceGeneration: 0, targetGeneration: 0, sourceRunEntries: 0, targetRunEntries: 0,
            gateE: "ABSTAIN", authorityVector: "00000000", quarantined: false,
            projectionRoot: "", graphRoot: "", durable: false, h4Entered: false,
            nativeDiagnostic: nil, receipt: nil)
    }
}

private extension Data {
    var hex: String { map { String(format: "%02x", $0) }.joined() }
}
