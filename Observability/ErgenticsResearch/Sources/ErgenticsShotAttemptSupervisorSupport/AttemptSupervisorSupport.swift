import CryptoKit
import Darwin

package enum AttemptSupervisorSupportError: Error, Equatable, Sendable {
    case arithmeticOverflow
    case counterLimitExceeded
    case invalidFrame
    case invalidTimebase
    case invalidTransition
    case reversedTicks
    case truncatedInput
    case trailingInput
}

package enum AttemptSHA256 {
    package static func digest(_ bytes: [UInt8]) -> [UInt8] {
        var hasher = SHA256()
        bytes.withUnsafeBytes { buffer in
            hasher.update(bufferPointer: buffer)
        }
        return Array(hasher.finalize())
    }

    package static func digestHex(_ bytes: [UInt8]) -> String {
        lowercaseHex(digest(bytes))
    }

    package static func lowercaseHex(_ bytes: [UInt8]) -> String {
        let alphabet: [UInt8] = Array("0123456789abcdef".utf8)
        var encoded: [UInt8] = []
        encoded.reserveCapacity(bytes.count * 2)
        for byte in bytes {
            encoded.append(alphabet[Int(byte >> 4)])
            encoded.append(alphabet[Int(byte & 0x0f)])
        }
        return String(decoding: encoded, as: UTF8.self)
    }
}

package struct AttemptByteCursor: Sendable {
    private let bytes: [UInt8]
    package private(set) var offset: Int

    package init(bytes: [UInt8]) {
        self.bytes = bytes
        offset = 0
    }

    package var remaining: Int { bytes.count - offset }

    package mutating func read(count: Int) throws -> [UInt8] {
        guard count >= 0, offset <= bytes.count, count <= bytes.count - offset else {
            throw AttemptSupervisorSupportError.truncatedInput
        }
        let end = offset + count
        let result = Array(bytes[offset..<end])
        offset = end
        return result
    }

    package mutating func readUInt16BigEndian() throws -> UInt16 {
        let value = try read(count: 2)
        return (UInt16(value[0]) << 8) | UInt16(value[1])
    }

    package mutating func readUInt32BigEndian() throws -> UInt32 {
        let value = try read(count: 4)
        return value.reduce(UInt32.zero) { ($0 << 8) | UInt32($1) }
    }

    package mutating func readUInt64BigEndian() throws -> UInt64 {
        let value = try read(count: 8)
        return value.reduce(UInt64.zero) { ($0 << 8) | UInt64($1) }
    }

    package func requireEOF() throws {
        guard remaining == 0 else {
            throw AttemptSupervisorSupportError.trailingInput
        }
    }
}

package struct AttemptReadinessFrame: Equatable, Sendable {
    package struct Field: Equatable, Sendable {
        package let key: String
        package let value: String
    }

    package static let magic = Array("ERGATF10".utf8)
    package static let maximumBytes = 32_768
    package static let orderedKeys = [
        "schema",
        "control_freeze_sha256",
        "source_commit",
        "source_tree",
        "build_readiness_sha256",
        "build_result_sha256",
        "supervisor_sha256",
        "supervisor_bytes",
        "supervisor_uuid",
        "supervisor_cdhash",
        "supervisor_device",
        "supervisor_inode",
        "comparator_sha256",
        "checker_sha256",
        "runner_source_sha256",
        "ruby_sha256",
        "build_a_bundle_sha256",
        "build_a_bundle_uuid",
        "hypothesis_registration_sha256",
        "hypothesis_registration_bytes",
        "hypothesis_report_payload_sha256",
        "hypothesis_report_file_sha256",
        "hypothesis_report_bytes",
        "hypothesis_merkle_root",
        "hypothesis_merkle_leaf_count",
        "owner_root_absolute_path",
        "raw_combined_absolute_path",
        "capture_root_absolute_path",
        "launch_contract_sha256",
    ]

    package static let controlFreezeSHA256 =
        "c96b4b746ce6fe1069dc9044a1734f5f6f7c7e620cb26dd9c7500a220a09990c"
    package static let runnerSourceSHA256 =
        "ef865cca24d43e8d354a6cd247b17c1573c87b8a80496e91590551f5bf94e0d8"
    package static let rubySHA256 =
        "9d6ff3e289c7d908e3c785e0bedd6692d1d6a3377965c88c04d847104b7c892c"
    package static let buildABundleSHA256 =
        "09b8f7d5cb6104e13e2cbc0d3731e81031287f1d6e3436c14e0ef3937d5a0c71"
    package static let buildABundleUUID = "0371C336-3A6F-338E-9CD4-9349603C9F44"
    package static let ownerRootAbsolutePath =
        "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" +
        ".phase-a-v2-fixture-identity-restore-only-staging/artifacts/" +
        "r19-obs11-retained-r19-projection-chain-2026-08-26/" +
        "r19-obs11-c2-attempt-owner.v10"
    package static let rawCombinedAbsolutePath =
        "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" +
        ".phase-a-v2-fixture-identity-restore-only-staging/artifacts/" +
        "r19-obs11-retained-r19-projection-chain-2026-08-26/" +
        "r19-obs11-c2-runner-outer-combined.v9.bin"
    package static let captureRootAbsolutePath =
        "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" +
        ".phase-a-v2-fixture-identity-restore-only-staging/artifacts/" +
        "r19-obs11-retained-r19-projection-chain-2026-08-26/" +
        "r19-obs11-c2-preconsumption-prefix-capture.v9"

    package let fields: [Field]
    package let prefixSHA256: String
    package let byteCount: Int

    private init(fields: [Field], prefixSHA256: String, byteCount: Int) {
        self.fields = fields
        self.prefixSHA256 = prefixSHA256
        self.byteCount = byteCount
    }

    package static func parse(_ bytes: [UInt8]) throws -> Self {
        guard bytes.count <= maximumBytes else {
            throw AttemptSupervisorSupportError.invalidFrame
        }
        var cursor = AttemptByteCursor(bytes: bytes)
        guard try cursor.read(count: magic.count) == magic,
              try cursor.readUInt16BigEndian() == UInt16(orderedKeys.count)
        else {
            throw AttemptSupervisorSupportError.invalidFrame
        }

        var fields: [Field] = []
        fields.reserveCapacity(orderedKeys.count)
        for expectedKey in orderedKeys {
            let keyLength = Int(try cursor.readUInt16BigEndian())
            guard (1...64).contains(keyLength) else {
                throw AttemptSupervisorSupportError.invalidFrame
            }
            let keyBytes = try cursor.read(count: keyLength)
            guard isVisibleASCII(keyBytes) else {
                throw AttemptSupervisorSupportError.invalidFrame
            }
            let key = String(decoding: keyBytes, as: UTF8.self)
            guard key == expectedKey else {
                throw AttemptSupervisorSupportError.invalidFrame
            }

            let valueLength32 = try cursor.readUInt32BigEndian()
            guard valueLength32 >= 1, valueLength32 <= 4_096 else {
                throw AttemptSupervisorSupportError.invalidFrame
            }
            let valueBytes = try cursor.read(count: Int(valueLength32))
            guard isVisibleASCII(valueBytes) else {
                throw AttemptSupervisorSupportError.invalidFrame
            }
            fields.append(Field(
                key: key,
                value: String(decoding: valueBytes, as: UTF8.self)))
        }

        let prefixByteCount = cursor.offset
        let trailer = try cursor.read(count: 32)
        try cursor.requireEOF()
        let prefix = Array(bytes[0..<prefixByteCount])
        guard AttemptSHA256.digest(prefix) == trailer else {
            throw AttemptSupervisorSupportError.invalidFrame
        }
        try validate(fields)
        return Self(
            fields: fields,
            prefixSHA256: AttemptSHA256.lowercaseHex(trailer),
            byteCount: bytes.count)
    }

    package func value(for key: String) -> String? {
        fields.first(where: { $0.key == key })?.value
    }

    private static func validate(_ fields: [Field]) throws {
        func value(_ key: String) -> String {
            fields.first(where: { $0.key == key })!.value
        }

        guard value("schema") == "ERGENTICS_R19_OBS11_C2_ATTEMPT_READINESS_V10",
              value("control_freeze_sha256") == controlFreezeSHA256,
              value("runner_source_sha256") == runnerSourceSHA256,
              value("ruby_sha256") == rubySHA256,
              value("build_a_bundle_sha256") == buildABundleSHA256,
              value("build_a_bundle_uuid") == buildABundleUUID,
              value("owner_root_absolute_path") == ownerRootAbsolutePath,
              value("raw_combined_absolute_path") == rawCombinedAbsolutePath,
              value("capture_root_absolute_path") == captureRootAbsolutePath
        else {
            throw AttemptSupervisorSupportError.invalidFrame
        }

        for key in [
            "control_freeze_sha256",
            "build_readiness_sha256",
            "build_result_sha256",
            "supervisor_sha256",
            "comparator_sha256",
            "checker_sha256",
            "runner_source_sha256",
            "ruby_sha256",
            "build_a_bundle_sha256",
            "hypothesis_registration_sha256",
            "hypothesis_report_payload_sha256",
            "hypothesis_report_file_sha256",
            "hypothesis_merkle_root",
            "launch_contract_sha256",
        ] where !isLowercaseHex(value(key), count: 64) {
            throw AttemptSupervisorSupportError.invalidFrame
        }
        for key in ["source_commit", "source_tree", "supervisor_cdhash"]
        where !isLowercaseHex(value(key), count: 40) {
            throw AttemptSupervisorSupportError.invalidFrame
        }
        for key in ["supervisor_uuid", "build_a_bundle_uuid"]
        where !isCanonicalUUID(value(key)) {
            throw AttemptSupervisorSupportError.invalidFrame
        }
        for key in [
            "supervisor_bytes",
            "supervisor_device",
            "supervisor_inode",
            "hypothesis_registration_bytes",
            "hypothesis_report_bytes",
            "hypothesis_merkle_leaf_count",
        ] {
            guard let integer = parseUnsignedDecimal(value(key)), integer > 0 else {
                throw AttemptSupervisorSupportError.invalidFrame
            }
        }
    }

    private static func isVisibleASCII(_ bytes: [UInt8]) -> Bool {
        bytes.allSatisfy { (0x20...0x7e).contains($0) }
    }

    private static func isLowercaseHex(_ value: String, count: Int) -> Bool {
        let bytes = Array(value.utf8)
        return bytes.count == count && bytes.allSatisfy {
            (0x30...0x39).contains($0) || (0x61...0x66).contains($0)
        }
    }

    private static func isCanonicalUUID(_ value: String) -> Bool {
        let bytes = Array(value.utf8)
        guard bytes.count == 36 else { return false }
        for index in bytes.indices {
            if index == 8 || index == 13 || index == 18 || index == 23 {
                guard bytes[index] == 0x2d else { return false }
            } else {
                let byte = bytes[index]
                guard (0x30...0x39).contains(byte) || (0x41...0x46).contains(byte) else {
                    return false
                }
            }
        }
        return true
    }

    private static func parseUnsignedDecimal(_ value: String) -> UInt64? {
        let bytes = Array(value.utf8)
        guard !bytes.isEmpty, bytes.count == 1 || bytes[0] != 0x30 else { return nil }
        var result: UInt64 = 0
        for byte in bytes {
            guard (0x30...0x39).contains(byte) else { return nil }
            let digit = UInt64(byte - 0x30)
            let multiplied = result.multipliedReportingOverflow(by: 10)
            guard !multiplied.overflow else { return nil }
            let added = multiplied.partialValue.addingReportingOverflow(digit)
            guard !added.overflow else { return nil }
            result = added.partialValue
        }
        return result
    }
}

package struct AttemptRationalNanoseconds: Equatable, Sendable {
    package let numerator: UInt64
    package let denominator: UInt64

    package static func checkedElapsed(
        startTicks: UInt64,
        endTicks: UInt64,
        timebaseNumerator: UInt64,
        timebaseDenominator: UInt64
    ) throws -> Self {
        guard timebaseNumerator > 0, timebaseDenominator > 0 else {
            throw AttemptSupervisorSupportError.invalidTimebase
        }
        guard endTicks >= startTicks else {
            throw AttemptSupervisorSupportError.reversedTicks
        }
        let delta = endTicks - startTicks
        let product = delta.multipliedReportingOverflow(by: timebaseNumerator)
        guard !product.overflow else {
            throw AttemptSupervisorSupportError.arithmeticOverflow
        }
        let divisor = greatestCommonDivisor(product.partialValue, timebaseDenominator)
        return Self(
            numerator: product.partialValue / divisor,
            denominator: timebaseDenominator / divisor)
    }

    private static func greatestCommonDivisor(_ left: UInt64, _ right: UInt64) -> UInt64 {
        var a = left
        var b = right
        while b != 0 {
            let remainder = a % b
            a = b
            b = remainder
        }
        return a
    }
}

package struct AttemptBoundedCounter: Equatable, Sendable {
    package let maximum: UInt64
    package private(set) var value: UInt64

    package init(maximum: UInt64, initialValue: UInt64 = 0) throws {
        guard initialValue <= maximum else {
            throw AttemptSupervisorSupportError.counterLimitExceeded
        }
        self.maximum = maximum
        value = initialValue
    }

    package mutating func increment() throws {
        try add(1)
    }

    package mutating func add(_ amount: UInt64) throws {
        let addition = value.addingReportingOverflow(amount)
        guard !addition.overflow, addition.partialValue <= maximum else {
            throw AttemptSupervisorSupportError.counterLimitExceeded
        }
        value = addition.partialValue
    }
}

package enum AttemptPublicationPhase: UInt8, Equatable, Sendable {
    case unentered
    case exclusiveLeafOpened
    case bytesComplete
    case readbackVerified
    case firstSyncComplete
    case modeSealed
    case secondSyncComplete
    case parentSyncComplete
    case vnodeRejoined
}

package struct AttemptPublicationState: Equatable, Sendable {
    package private(set) var phase: AttemptPublicationPhase = .unentered
    package private(set) var failed = false

    package init() {}

    package var verified: Bool { !failed && phase == .vnodeRejoined }

    package mutating func advance(to next: AttemptPublicationPhase) throws {
        let successor = phase.rawValue.addingReportingOverflow(1)
        guard !failed, !successor.overflow, next.rawValue == successor.partialValue else {
            throw AttemptSupervisorSupportError.invalidTransition
        }
        phase = next
    }

    package mutating func fail() throws {
        guard !failed, !verified else {
            throw AttemptSupervisorSupportError.invalidTransition
        }
        failed = true
    }
}

package enum AttemptRootSealState: UInt8, Equatable, Sendable {
    case root0700PresealOrFchmodFailed
    case root0500ModeSealedSyncIncomplete
    case root0500DurableRejoinIncomplete
    case root0500TerminalVerified
}

package struct AttemptRootSealMachine: Equatable, Sendable {
    package private(set) var state: AttemptRootSealState = .root0700PresealOrFchmodFailed

    package init() {}

    package var verified: Bool { state == .root0500TerminalVerified }

    package mutating func advance(to next: AttemptRootSealState) throws {
        let successor = state.rawValue.addingReportingOverflow(1)
        guard !successor.overflow, next.rawValue == successor.partialValue else {
            throw AttemptSupervisorSupportError.invalidTransition
        }
        state = next
    }
}
