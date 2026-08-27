import Testing
@testable import ErgenticsShotAttemptSupervisorSupport

@Suite("C2 V9 timing supervisor support")
struct C2V9TimingSupervisorTests {
    @Test("elapsed ticks reduce exactly and reject reversed or overflowing inputs")
    func checkedRational() throws {
        let reduced = try AttemptRationalNanoseconds.checkedElapsed(
            startTicks: 100,
            endTicks: 101,
            timebaseNumerator: 2,
            timebaseDenominator: 6)
        #expect(reduced.numerator == 1)
        #expect(reduced.denominator == 3)

        let zero = try AttemptRationalNanoseconds.checkedElapsed(
            startTicks: 10,
            endTicks: 10,
            timebaseNumerator: 7,
            timebaseDenominator: 9)
        #expect(zero.numerator == 0)
        #expect(zero.denominator == 1)

        #expect(throws: AttemptSupervisorSupportError.self) {
            try AttemptRationalNanoseconds.checkedElapsed(
                startTicks: 2,
                endTicks: 1,
                timebaseNumerator: 1,
                timebaseDenominator: 1)
        }
        #expect(throws: AttemptSupervisorSupportError.self) {
            try AttemptRationalNanoseconds.checkedElapsed(
                startTicks: 0,
                endTicks: UInt64.max,
                timebaseNumerator: 2,
                timebaseDenominator: 1)
        }
        #expect(throws: AttemptSupervisorSupportError.self) {
            try AttemptRationalNanoseconds.checkedElapsed(
                startTicks: 0,
                endTicks: 1,
                timebaseNumerator: 1,
                timebaseDenominator: 0)
        }
    }

    @Test("fixed-width decoding is big-endian, bounded, and EOF-exact")
    func fixedEncoding() throws {
        var cursor = AttemptByteCursor(bytes: [
            0x01, 0x02,
            0x03, 0x04, 0x05, 0x06,
            0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
        ])
        #expect(try cursor.readUInt16BigEndian() == 0x0102)
        #expect(try cursor.readUInt32BigEndian() == 0x03040506)
        #expect(try cursor.readUInt64BigEndian() == 0x0708090a0b0c0d0e)
        try cursor.requireEOF()

        var truncated = AttemptByteCursor(bytes: [0x01])
        #expect(throws: AttemptSupervisorSupportError.self) {
            try truncated.readUInt16BigEndian()
        }
        var trailing = AttemptByteCursor(bytes: [0x00])
        #expect(throws: AttemptSupervisorSupportError.self) {
            try trailing.requireEOF()
        }
    }

    @Test("readiness frame enforces all ordered fields, fixed bindings, digest, and EOF")
    func readinessFrame() throws {
        let bytes = readinessFrameBytes()
        let frame = try AttemptReadinessFrame.parse(bytes)
        #expect(frame.byteCount == bytes.count)
        #expect(frame.fields.count == 29)
        #expect(frame.value(for: "control_freeze_sha256") ==
            AttemptReadinessFrame.controlFreezeSHA256)
        #expect(frame.prefixSHA256.count == 64)

        var trailing = bytes
        trailing.append(0)
        #expect(throws: AttemptSupervisorSupportError.self) {
            try AttemptReadinessFrame.parse(trailing)
        }
        #expect(throws: AttemptSupervisorSupportError.self) {
            try AttemptReadinessFrame.parse(
                Array(repeating: 0, count: AttemptReadinessFrame.maximumBytes + 1))
        }

        var damaged = bytes
        damaged[20] ^= 1
        #expect(throws: AttemptSupervisorSupportError.self) {
            try AttemptReadinessFrame.parse(damaged)
        }

        var values = readinessValues()
        let first = values[0]
        values[0] = values[1]
        values[1] = first
        #expect(throws: AttemptSupervisorSupportError.self) {
            try AttemptReadinessFrame.parse(readinessFrameBytes(values: values))
        }
    }

    @Test("counter and publication transitions fail closed without advancing")
    func checkedState() throws {
        var counter = try AttemptBoundedCounter(maximum: 1)
        try counter.increment()
        #expect(counter.value == 1)
        #expect(throws: AttemptSupervisorSupportError.self) {
            try counter.increment()
        }
        #expect(counter.value == 1)

        var publication = AttemptPublicationState()
        #expect(throws: AttemptSupervisorSupportError.self) {
            try publication.advance(to: .bytesComplete)
        }
        #expect(publication.phase == .unentered)
        for phase in [
            AttemptPublicationPhase.exclusiveLeafOpened,
            .bytesComplete,
            .readbackVerified,
            .firstSyncComplete,
            .modeSealed,
            .secondSyncComplete,
            .parentSyncComplete,
            .vnodeRejoined,
        ] {
            try publication.advance(to: phase)
        }
        #expect(publication.verified)
        #expect(throws: AttemptSupervisorSupportError.self) {
            try publication.fail()
        }
        #expect(throws: AttemptSupervisorSupportError.self) {
            try publication.advance(to: .unentered)
        }

        var failed = AttemptPublicationState()
        try failed.advance(to: .exclusiveLeafOpened)
        try failed.fail()
        #expect(!failed.verified)
        #expect(throws: AttemptSupervisorSupportError.self) {
            try failed.advance(to: .bytesComplete)
        }

        var root = AttemptRootSealMachine()
        try root.advance(to: .root0500ModeSealedSyncIncomplete)
        try root.advance(to: .root0500DurableRejoinIncomplete)
        try root.advance(to: .root0500TerminalVerified)
        #expect(root.verified)
    }

    private func readinessFrameBytes(
        values: [(key: String, value: String)]? = nil
    ) -> [UInt8] {
        let admitted = values ?? readinessValues()
        var bytes = AttemptReadinessFrame.magic
        appendUInt16(UInt16(admitted.count), to: &bytes)
        for field in admitted {
            let key = Array(field.key.utf8)
            let value = Array(field.value.utf8)
            appendUInt16(UInt16(key.count), to: &bytes)
            bytes.append(contentsOf: key)
            appendUInt32(UInt32(value.count), to: &bytes)
            bytes.append(contentsOf: value)
        }
        let trailer = AttemptSHA256.digest(bytes)
        bytes.append(contentsOf: trailer)
        return bytes
    }

    private func readinessValues() -> [(key: String, value: String)] {
        let hex64 = String(repeating: "1", count: 64)
        let hex40 = String(repeating: "2", count: 40)
        let uuid = "01234567-89AB-CDEF-0123-456789ABCDEF"
        let values: [String: String] = [
            "schema": "ERGENTICS_R19_OBS11_C2_ATTEMPT_READINESS_V10",
            "control_freeze_sha256": AttemptReadinessFrame.controlFreezeSHA256,
            "source_commit": hex40,
            "source_tree": hex40,
            "build_readiness_sha256": hex64,
            "build_result_sha256": hex64,
            "supervisor_sha256": hex64,
            "supervisor_bytes": "1",
            "supervisor_uuid": uuid,
            "supervisor_cdhash": hex40,
            "supervisor_device": "1",
            "supervisor_inode": "1",
            "comparator_sha256": hex64,
            "checker_sha256": hex64,
            "runner_source_sha256": AttemptReadinessFrame.runnerSourceSHA256,
            "ruby_sha256": AttemptReadinessFrame.rubySHA256,
            "build_a_bundle_sha256": AttemptReadinessFrame.buildABundleSHA256,
            "build_a_bundle_uuid": AttemptReadinessFrame.buildABundleUUID,
            "hypothesis_registration_sha256": hex64,
            "hypothesis_registration_bytes": "1",
            "hypothesis_report_payload_sha256": hex64,
            "hypothesis_report_file_sha256": hex64,
            "hypothesis_report_bytes": "1",
            "hypothesis_merkle_root": hex64,
            "hypothesis_merkle_leaf_count": "1",
            "owner_root_absolute_path": AttemptReadinessFrame.ownerRootAbsolutePath,
            "raw_combined_absolute_path": AttemptReadinessFrame.rawCombinedAbsolutePath,
            "capture_root_absolute_path": AttemptReadinessFrame.captureRootAbsolutePath,
            "launch_contract_sha256": hex64,
        ]
        return AttemptReadinessFrame.orderedKeys.map { key in
            (key: key, value: values[key]!)
        }
    }

    private func appendUInt16(_ value: UInt16, to bytes: inout [UInt8]) {
        bytes.append(UInt8((value >> 8) & 0xff))
        bytes.append(UInt8(value & 0xff))
    }

    private func appendUInt32(_ value: UInt32, to bytes: inout [UInt8]) {
        bytes.append(UInt8((value >> 24) & 0xff))
        bytes.append(UInt8((value >> 16) & 0xff))
        bytes.append(UInt8((value >> 8) & 0xff))
        bytes.append(UInt8(value & 0xff))
    }
}
