import Foundation
import CryptoKit

/// Pure, owned qualification values. No system observation or capability is
/// accepted by these APIs: effect owners supply copied bytes and scalars.
enum H3QualificationFailure: Error, Equatable, Sendable {
    case malformed(String)
    case bound(String)
    case invariant(String)
    case unsupportedSchema(String)
}

indirect enum H3QualificationJSONValue: Equatable, Sendable {
    case object([String: H3QualificationJSONValue])
    case array([H3QualificationJSONValue])
    case string(String)
    case integer(Int64)
    case unsigned(UInt64)
    case bool(Bool)
    case null

    var objectValue: [String: Self]? { if case .object(let value) = self { return value }; return nil }
    var arrayValue: [Self]? { if case .array(let value) = self { return value }; return nil }
    var stringValue: String? { if case .string(let value) = self { return value }; return nil }
    var boolValue: Bool? { if case .bool(let value) = self { return value }; return nil }
    var intValue: Int64? {
        switch self { case .integer(let value): return value
        case .unsigned(let value): return Int64(exactly: value)
        default: return nil }
    }
    var uintValue: UInt64? {
        switch self { case .integer(let value): return UInt64(exactly: value)
        case .unsigned(let value): return value
        case .string(let value): return UInt64(value)
        default: return nil }
    }
    subscript(_ key: String) -> Self? { objectValue?[key] }
    func required(_ key: String) throws -> Self {
        guard let result = self[key] else { throw H3QualificationFailure.malformed("missing field \(key)") }
        return result
    }
}

enum H3QualificationCanonicalJSON {
    typealias Value = H3QualificationJSONValue
    struct Limits: Sendable {
        var nestingDepth = 32
        var totalValueTokens = 262_144
        var objectMembersEach = 8_192
        var arrayElementsEach = 4_096
        var numericTokenBytes = 21
        var singleDecodedStringBytes = 1_398_104
        var cumulativeDecodedStringBytes = 26_214_400
    }

    /// The iterative parser itself is the allocation preflight. It never hands
    /// unbounded input to JSONDecoder or JSONSerialization.
    static func decode(_ data: Data, maximumBytes: Int = 65_536,
                       limits: Limits = Limits()) throws -> Value {
        try validateLimits(limits)
        guard maximumBytes > 0, !data.isEmpty, data.count <= maximumBytes else {
            throw H3QualificationFailure.bound("JSON bytes")
        }
        guard String(data: data, encoding: .utf8) != nil else {
            throw H3QualificationFailure.malformed("UTF-8")
        }
        var parser = Parser(bytes: Array(data), limits: limits)
        let value = try parser.parse()
        guard try encode(value, maximumBytes: maximumBytes, limits: limits) == data else {
            throw H3QualificationFailure.malformed("noncanonical JSON")
        }
        return value
    }

    /// Xcode's raw settings are not canonical JSON. They still pass the same
    /// iterative duplicate-key/UTF-8/escape parser with the tighter frozen
    /// allocation limits, and permit only string/object/array value nodes.
    static func decodeBuildSettings(_ data: Data) throws -> Value {
        let limits = Limits(totalValueTokens: 65_536, singleDecodedStringBytes: 262_144,
                            cumulativeDecodedStringBytes: 2_097_152)
        guard !data.isEmpty, data.count <= 1_048_576, String(data: data, encoding: .utf8) != nil else {
            throw H3QualificationFailure.bound("raw settings bytes/UTF-8")
        }
        var parser = Parser(bytes: Array(data), limits: limits, allowsWhitespace: true)
        let value = try parser.parse()
        var pending = [value]
        while let node = pending.popLast() {
            switch node {
            case .string: break
            case .array(let values): pending.append(contentsOf: values)
            case .object(let values): pending.append(contentsOf: values.values)
            default: throw H3QualificationFailure.malformed("raw settings value type")
            }
        }
        return value
    }

    static func encode(_ value: Value, maximumBytes: Int = 65_536,
                       limits: Limits = Limits()) throws -> Data {
        try validateLimits(limits)
        guard maximumBytes > 0 else { throw H3QualificationFailure.bound("encoded JSON bytes") }
        enum Item { case value(Value, Int), bytes([UInt8]) }
        var work: [Item] = [.value(value, 0)]
        var output = Data()
        var tokens = 0
        var cumulativeStrings = 0
        func encodedString(_ string: String) throws -> [UInt8] {
            let source = Array(string.utf8)
            guard source.count <= limits.singleDecodedStringBytes,
                  cumulativeStrings <= limits.cumulativeDecodedStringBytes - source.count else {
                throw H3QualificationFailure.bound("decoded strings")
            }
            cumulativeStrings += source.count
            var result: [UInt8] = [34]
            for byte in source {
                switch byte {
                case 34: result += [92, 34]
                case 92: result += [92, 92]
                case 8: result += [92, 98]
                case 9: result += [92, 116]
                case 10: result += [92, 110]
                case 12: result += [92, 102]
                case 13: result += [92, 114]
                case 0...31:
                    let hex = Array("0123456789abcdef".utf8)
                    result += [92, 117, 48, 48, hex[Int(byte >> 4)], hex[Int(byte & 15)]]
                default: result.append(byte)
                }
            }
            result.append(34)
            return result
        }
        while let item = work.popLast() {
            switch item {
            case .bytes(let bytes):
                guard bytes.count <= maximumBytes, output.count <= maximumBytes - bytes.count else {
                    throw H3QualificationFailure.bound("encoded JSON bytes")
                }
                output.append(contentsOf: bytes)
            case .value(let next, let depth):
                tokens += 1
                guard tokens <= limits.totalValueTokens else { throw H3QualificationFailure.bound("value tokens") }
                switch next {
                case .object(let object):
                    guard depth < limits.nestingDepth, object.count <= limits.objectMembersEach else {
                        throw H3QualificationFailure.bound("object")
                    }
                    let keys = object.keys.sorted { $0.unicodeScalars.lexicographicallyPrecedes($1.unicodeScalars) }
                    work.append(.bytes([125]))
                    for index in keys.indices.reversed() {
                        let key = keys[index]
                        if index < keys.count - 1 { work.append(.bytes([44])) }
                        work.append(.value(object[key]!, depth + 1))
                        work.append(.bytes([58]))
                        work.append(.bytes(try encodedString(key)))
                    }
                    work.append(.bytes([123]))
                case .array(let array):
                    guard depth < limits.nestingDepth, array.count <= limits.arrayElementsEach else {
                        throw H3QualificationFailure.bound("array")
                    }
                    work.append(.bytes([93]))
                    for index in array.indices.reversed() {
                        if index < array.count - 1 { work.append(.bytes([44])) }
                        work.append(.value(array[index], depth + 1))
                    }
                    work.append(.bytes([91]))
                case .string(let string): work.append(.bytes(try encodedString(string)))
                case .integer(let integer): work.append(.bytes(Array(String(integer).utf8)))
                case .unsigned(let integer): work.append(.bytes(Array(String(integer).utf8)))
                case .bool(let flag): work.append(.bytes(Array((flag ? "true" : "false").utf8)))
                case .null: work.append(.bytes(Array("null".utf8)))
                }
            }
        }
        return output
    }

    private static func validateLimits(_ limits: Limits) throws {
        guard (1...32).contains(limits.nestingDepth), (1...262_144).contains(limits.totalValueTokens),
              (0...8192).contains(limits.objectMembersEach), (0...4096).contains(limits.arrayElementsEach),
              (1...21).contains(limits.numericTokenBytes),
              (0...1_398_104).contains(limits.singleDecodedStringBytes),
              (0...26_214_400).contains(limits.cumulativeDecodedStringBytes) else {
            throw H3QualificationFailure.bound("JSON structural limit")
        }
    }

    private struct Parser {
        struct Container {
            enum Kind { case object, array }
            let kind: Kind
            var object: [String: Value] = [:]
            var array: [Value] = []
            var key: String?
            var expectingMember = true
            var hasMember = false
        }
        let bytes: [UInt8]
        let limits: Limits
        var allowsWhitespace = false
        var offset = 0
        var tokens = 0
        var stringBytes = 0
        var stack: [Container] = []
        var root: Value?

        mutating func parse() throws -> Value {
            while offset < bytes.count {
                whitespace()
                if offset == bytes.count { break }
                if !stack.isEmpty {
                    let index = stack.count - 1
                    if !stack[index].expectingMember {
                        let end: UInt8 = stack[index].kind == .object ? 125 : 93
                        if bytes[offset] == end { try closeContainer(); continue }
                        guard bytes[offset] == 44 else { throw malformed("member separator") }
                        offset += 1
                        stack[index].expectingMember = true
                        continue
                    }
                    if stack[index].kind == .object, stack[index].key == nil {
                        if bytes[offset] == 125, !stack[index].hasMember { try closeContainer(); continue }
                        guard bytes[offset] == 34 else { throw malformed("object key") }
                        let key = try string()
                        whitespace()
                        guard stack[index].object[key] == nil else { throw malformed("duplicate key") }
                        guard stack[index].object.count < limits.objectMembersEach else {
                            throw H3QualificationFailure.bound("object members")
                        }
                        guard offset < bytes.count, bytes[offset] == 58 else { throw malformed("key separator") }
                        offset += 1
                        stack[index].key = key
                    } else if stack[index].kind == .array, bytes[offset] == 93,
                              !stack[index].hasMember { try closeContainer(); continue }
                } else if root != nil { throw malformed("trailing bytes") }
                whitespace()
                guard offset < bytes.count else { throw malformed("missing value") }
                tokens += 1
                guard tokens <= limits.totalValueTokens else { throw H3QualificationFailure.bound("value tokens") }
                switch bytes[offset] {
                case 123, 91:
                    guard stack.count < limits.nestingDepth else { throw H3QualificationFailure.bound("nesting depth") }
                    let kind: Container.Kind = bytes[offset] == 123 ? .object : .array
                    offset += 1
                    stack.append(Container(kind: kind))
                case 34: try attach(.string(string()))
                case 116: try literal("true"); try attach(.bool(true))
                case 102: try literal("false"); try attach(.bool(false))
                case 110: try literal("null"); try attach(.null)
                case 45, 48...57: try attach(number())
                default: throw malformed("value")
                }
            }
            guard stack.isEmpty, let root else { throw malformed("truncation") }
            return root
        }
        mutating func whitespace() {
            guard allowsWhitespace else { return }
            while offset < bytes.count, [9, 10, 13, 32].contains(bytes[offset]) { offset += 1 }
        }
        mutating func attach(_ value: Value) throws {
            guard !stack.isEmpty else {
                guard root == nil else { throw malformed("multiple roots") }
                root = value
                return
            }
            let index = stack.count - 1
            if stack[index].kind == .object {
                guard let key = stack[index].key else { throw malformed("missing object key") }
                stack[index].object[key] = value
                stack[index].key = nil
            } else {
                guard stack[index].array.count < limits.arrayElementsEach else {
                    throw H3QualificationFailure.bound("array elements")
                }
                stack[index].array.append(value)
            }
            stack[index].expectingMember = false
            stack[index].hasMember = true
        }
        mutating func closeContainer() throws {
            let top = stack.removeLast()
            guard top.key == nil, !top.expectingMember || !top.hasMember else {
                throw malformed("trailing comma")
            }
            offset += 1
            try attach(top.kind == .object ? .object(top.object) : .array(top.array))
        }
        mutating func literal(_ literal: String) throws {
            let wanted = Array(literal.utf8)
            guard wanted.count <= bytes.count - offset,
                  bytes[offset..<(offset + wanted.count)].elementsEqual(wanted) else {
                throw malformed("literal")
            }
            offset += wanted.count
        }
        mutating func number() throws -> Value {
            let start = offset
            if bytes[offset] == 45 { offset += 1 }
            guard offset < bytes.count, (48...57).contains(bytes[offset]) else { throw malformed("integer") }
            if bytes[offset] == 48 {
                offset += 1
                guard offset - start == 1 else { throw malformed("negative zero") }
            } else {
                while offset < bytes.count, (48...57).contains(bytes[offset]) {
                    offset += 1
                    guard offset - start <= limits.numericTokenBytes else { throw H3QualificationFailure.bound("integer") }
                }
            }
            if offset < bytes.count, ![44, 93, 125].contains(bytes[offset]),
               !(allowsWhitespace && [9, 10, 13, 32].contains(bytes[offset])) { throw malformed("integer spelling") }
            let token = String(decoding: bytes[start..<offset], as: UTF8.self)
            if let signed = Int64(token) { return .integer(signed) }
            if let unsigned = UInt64(token) { return .unsigned(unsigned) }
            throw H3QualificationFailure.bound("integer range")
        }
        mutating func string() throws -> String {
            offset += 1
            var decoded: [UInt8] = []
            while offset < bytes.count {
                let byte = bytes[offset]
                offset += 1
                if byte == 34 {
                    guard let result = String(bytes: decoded, encoding: .utf8) else { throw malformed("string UTF-8") }
                    return result
                }
                var next: [UInt8]
                if byte == 92 {
                    guard offset < bytes.count else { throw malformed("escape truncation") }
                    let escape = bytes[offset]
                    offset += 1
                    switch escape {
                    case 34, 92, 47: next = [escape]
                    case 98: next = [8]
                    case 102: next = [12]
                    case 110: next = [10]
                    case 114: next = [13]
                    case 116: next = [9]
                    case 117:
                        var scalar = try hexScalar()
                        if (0xd800...0xdbff).contains(scalar) {
                            guard offset + 2 <= bytes.count, bytes[offset] == 92, bytes[offset + 1] == 117 else {
                                throw malformed("unpaired surrogate")
                            }
                            offset += 2
                            let low = try hexScalar()
                            guard (0xdc00...0xdfff).contains(low) else { throw malformed("surrogate pair") }
                            scalar = 0x10000 + ((scalar - 0xd800) << 10) + low - 0xdc00
                        }
                        guard let unicode = UnicodeScalar(scalar) else { throw malformed("Unicode scalar") }
                        next = Array(String(unicode).utf8)
                    default: throw malformed("escape")
                    }
                } else {
                    guard byte >= 32 else { throw malformed("control in string") }
                    next = [byte]
                }
                guard next.count <= limits.singleDecodedStringBytes,
                      decoded.count <= limits.singleDecodedStringBytes - next.count,
                      next.count <= limits.cumulativeDecodedStringBytes,
                      stringBytes <= limits.cumulativeDecodedStringBytes - next.count else {
                    throw H3QualificationFailure.bound("decoded strings")
                }
                decoded += next
                stringBytes += next.count
            }
            throw malformed("string truncation")
        }
        mutating func hexScalar() throws -> UInt32 {
            guard bytes.count - offset >= 4 else { throw malformed("Unicode escape") }
            var scalar: UInt32 = 0
            for _ in 0..<4 {
                let byte = bytes[offset]
                offset += 1
                let digit: UInt32
                switch byte { case 48...57: digit = UInt32(byte - 48)
                case 65...70: digit = UInt32(byte - 55)
                case 97...102: digit = UInt32(byte - 87)
                default: throw malformed("Unicode escape digit") }
                scalar = (scalar << 4) | digit
            }
            return scalar
        }
        func malformed(_ detail: String) -> H3QualificationFailure { .malformed("JSON \(detail) at \(offset)") }
    }
}

enum H3QualificationMode: String, Sendable, CaseIterable { case admissionOnly = "ADMISSION_ONLY", guest = "GUEST" }
enum H3QualificationConfiguration: String, Sendable, CaseIterable { case debug = "DEBUG", release = "RELEASE" }

enum H3QualificationProtocol {
    static let sentinel = Int32.min
    static let maximumPayloadBytes = 65_536
    static let maximumFrameBytes = 65_552
    static let imageSHA256 = "3c03199c6ae993fa5c316a497cf4d59d590ee0e1a4488b598d8da385f38af8b0"
    static func hash(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }

    /// Code evidence is byte identity, not Swift's Unicode-equivalent String
    /// equality. In particular, never normalize a captured certificate CN/DR
    /// between the raw audit, static/dynamic checks and retained campaign joins.
    static func sameCodeIdentity(_ lhs: H3QualificationJSONValue?, _ rhs: H3QualificationJSONValue?) throws -> Bool {
        guard let lhs, let rhs else { return false }
        return try H3QualificationCanonicalJSON.encode(lhs) == H3QualificationCanonicalJSON.encode(rhs)
    }
    static func hex(_ data: Data) -> String { data.map { String(format: "%02x", $0) }.joined() }
    static func unhex(_ text: String, bytes count: Int) throws -> Data {
        let chars = Array(text.utf8)
        guard count >= 0, count <= Int.max / 2, chars.count == count * 2 else { throw H3QualificationFailure.malformed("hex width") }
        var result = Data(capacity: count)
        func digit(_ byte: UInt8) throws -> UInt8 {
            switch byte { case 48...57: return byte - 48; case 97...102: return byte - 87
            default: throw H3QualificationFailure.malformed("lowercase hex") }
        }
        for index in stride(from: 0, to: chars.count, by: 2) {
            result.append(try digit(chars[index]) << 4 | digit(chars[index + 1]))
        }
        return result
    }
    static func runID(mode: H3QualificationMode, configuration: H3QualificationConfiguration, nonce: String) throws -> String {
        var bytes = Data("com.ergentics.provenance.h3-qualification-run-id.v1".utf8)
        bytes.append(contentsOf: [0, mode == .admissionOnly ? 1 : 2, configuration == .debug ? 1 : 2])
        bytes.append(try unhex(nonce, bytes: 32))
        return hash(bytes)
    }
    static func gateFrame(mode: H3QualificationMode, nonce: String) throws -> Data {
        var bytes = Data("EPRH3G01".utf8)
        bytes.append(mode == .admissionOnly ? 1 : 2)
        bytes.append(try unhex(nonce, bytes: 32))
        return bytes
    }
    static func frame(payload: H3QualificationJSONValue) throws -> Data {
        let bytes = try H3QualificationCanonicalJSON.encode(payload, maximumBytes: maximumPayloadBytes)
        var result = Data("EPRH3I01".utf8)
        result.append(contentsOf: String(format: "%08x", bytes.count).utf8)
        result.append(bytes)
        return result
    }
    static func decodeFrame(_ frame: Data) throws -> H3QualificationJSONValue {
        guard (17...maximumFrameBytes).contains(frame.count), frame.prefix(8) == Data("EPRH3I01".utf8) else {
            throw H3QualificationFailure.malformed("inner frame magic/size")
        }
        let lengthBytes = frame.dropFirst(8).prefix(8)
        let lengthText = String(decoding: lengthBytes, as: UTF8.self)
        _ = try unhex(lengthText, bytes: 4)
        guard let length = Int(lengthText, radix: 16), (1...maximumPayloadBytes).contains(length),
              frame.count == 16 + length else { throw H3QualificationFailure.malformed("inner frame length") }
        let value = try H3QualificationCanonicalJSON.decode(Data(frame.dropFirst(16)), maximumBytes: maximumPayloadBytes)
        guard value.objectValue != nil else { throw H3QualificationFailure.malformed("inner frame object") }
        return value
    }
}

struct H3QualificationReservationStateMachine: Sendable, Equatable {
    enum Policy: Sendable { case ordinaryDeinit, qualificationChecked }
    enum State: Sendable { case unprepared, failedReserve, invalidReserveNoToken, invalidReserveWithToken, acquired, releasedWithoutToken, releaseAttemptedToken }
    enum ReleaseDecision: Sendable { case noCall, callToken }
    let policy: Policy
    private(set) var state: State = .unprepared
    private(set) var observedError: Int32 = 0
    private(set) var reservationEntries: UInt32 = 0
    private(set) var reservationReleaseEntries: UInt32 = 0
    private(set) var reservationReleaseStatus: Int32 = .min
    private var releasePending = false

    init(policy: Policy = .ordinaryDeinit) { self.policy = policy }
    mutating func recordReserve(tokenPresent: Bool, error: Int32) throws {
        guard state == .unprepared, !releasePending else { throw H3QualificationFailure.invariant("duplicate reserve") }
        observedError = error
        if policy == .ordinaryDeinit {
            state = tokenPresent ? .acquired : .failedReserve
            reservationEntries = tokenPresent ? 1 : 0
        } else if tokenPresent && error == 0 {
            state = .acquired
            reservationEntries = 1
        } else if !tokenPresent && error > 0 { state = .failedReserve }
        else { state = tokenPresent ? .invalidReserveWithToken : .invalidReserveNoToken }
    }
    mutating func beginCheckedRelease(tokenPresent: Bool) throws -> ReleaseDecision {
        guard policy == .qualificationChecked, !releasePending else { throw H3QualificationFailure.invariant("release policy/state") }
        switch state {
        case .failedReserve:
            guard !tokenPresent, observedError > 0, reservationEntries == 0,
                  reservationReleaseEntries == 0 else { throw H3QualificationFailure.invariant("failed reserve token") }
            state = .releasedWithoutToken
            return .noCall
        case .acquired:
            guard tokenPresent, reservationEntries == 1, reservationReleaseEntries == 0 else {
                throw H3QualificationFailure.invariant("acquired token")
            }
            releasePending = true
            reservationReleaseEntries = 1
            return .callToken
        default: throw H3QualificationFailure.invariant("release ineligible")
        }
    }
    mutating func finishCheckedRelease(status: Int32) throws {
        guard policy == .qualificationChecked, state == .acquired, releasePending,
              reservationEntries == 1, reservationReleaseEntries == 1 else {
            throw H3QualificationFailure.invariant("missing release call")
        }
        // Preserve an actual impossible native result before rejecting it: the
        // owner has already consumed the token and may never retry its release.
        reservationReleaseStatus = status
        state = .releaseAttemptedToken
        releasePending = false
        guard status >= 0 else { throw H3QualificationFailure.invariant("impossible release status") }
    }
    mutating func deinitDecision(tokenPresent: Bool) throws -> ReleaseDecision {
        if policy == .qualificationChecked { return .noCall }
        guard !releasePending else { throw H3QualificationFailure.invariant("deinit during release") }
        guard tokenPresent else { return .noCall }
        guard state == .acquired, reservationReleaseEntries == 0 else {
            throw H3QualificationFailure.invariant("ordinary duplicate release")
        }
        state = .releaseAttemptedToken
        reservationReleaseEntries = 1
        return .callToken
    }
}

struct H3QualificationTerminalStateMachine: Sendable, Equatable {
    enum Phase: Sendable { case activatedNoExport, exportSucceeded, exportFailed, terminal }
    enum ExportOutcome: Sendable { case succeeded, failed }
    private(set) var phase: Phase = .activatedNoExport
    mutating func recordExport(_ outcome: ExportOutcome) throws {
        guard phase == .activatedNoExport else { throw H3QualificationFailure.invariant("duplicate export outcome") }
        phase = outcome == .succeeded ? .exportSucceeded : .exportFailed
    }
    mutating func claim(_ code: Int32) throws {
        guard phase != .terminal,
              code == 70 || (code == 0 && phase == .exportSucceeded) || (code == 74 && phase == .exportFailed) else {
            throw H3QualificationFailure.invariant("terminal claim")
        }
        phase = .terminal
    }
}

struct H3QualificationStartupStateMachine: Sendable, Equatable {
    private(set) var activated = false
    mutating func activate() throws {
        guard !activated else { throw H3QualificationFailure.invariant("duplicate startup") }
        activated = true
    }
}

struct H3QualificationCancellationStateMachine: Sendable, Equatable {
    enum State: Sendable { case pending, operationCompleted, cancellationLatched }
    private(set) var state: State = .pending
    @discardableResult mutating func claimCompletion() -> Bool {
        guard state == .pending else { return false }; state = .operationCompleted; return true
    }
    @discardableResult mutating func latchCancellation() -> Bool {
        guard state == .pending else { return false }; state = .cancellationLatched; return true
    }
}

enum H3QualificationLifecycleDisposition: String, Sendable { case notEntered = "NOT_ENTERED", recoveryVolatile = "RECOVERY_VOLATILE", quarantined = "QUARANTINED" }
enum H3QualificationStartRejection: String, Sendable {
    case notAdmitted = "NOT_ADMITTED", modelStateRejected = "MODEL_STATE_REJECTED"
    case lifecycleNotInstalled = "LIFECYCLE_NOT_INSTALLED", lifecycleBeginRejected = "LIFECYCLE_BEGIN_REJECTED"
    case impossibleReservationTuple = "IMPOSSIBLE_RESERVATION_TUPLE"
}
struct H3QualificationNativeCapture: Sendable, Equatable { let wire: H3QualificationJSONValue }
struct H3QualificationPresentation: Sendable, Equatable {
    let wire: H3QualificationJSONValue
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
    let nativeDiagnostic: H3QualificationJSONValue?
}
enum H3QualificationWorkerOutcome: Sendable, Equatable {
    case canceledBeforeNative(reservationState: H3QualificationReservationStateMachine.State)
    case preparationFailed(preparationError: Int32, presentation: H3QualificationPresentation)
    case invalidReservation(reservationState: H3QualificationReservationStateMachine.State, observedError: Int32)
    case nativeReturned(capture: H3QualificationNativeCapture, presentation: H3QualificationPresentation)
}
enum H3QualificationH3Completion: Sendable, Equatable {
    case startRejected(H3QualificationStartRejection)
    case preparationRejected(preparationError: Int32, reservationEntries: UInt32, reservationReleaseEntries: UInt32,
                             reservationReleaseStatus: Int32, presentation: H3QualificationPresentation,
                             lifecycleDisposition: H3QualificationLifecycleDisposition)
    case nativeReturned(capture: H3QualificationNativeCapture, presentation: H3QualificationPresentation,
                        reservationEntries: UInt32, reservationReleaseEntries: UInt32,
                        reservationReleaseStatus: Int32, lifecycleDisposition: H3QualificationLifecycleDisposition)
    case releaseRejected(status: Int32)
    case cancellationWon
}

struct H3QualificationCapabilities: Sendable, Equatable {
    let hostSupported: Int32
    let supportStatus: Int32
    let supportSize: UInt64
    let supportError: Int32
    let signingAdmitted: Int32
    let signingError: Int32
    let queriesEntered: UInt32
    let vcpuStatus: Int32
    let ipaStatus: Int32
    let maxVCPUs: UInt32
    let maxIPABits: UInt32
}

enum H3QualificationSigningStatus: String, Sendable { case admitted = "ADMITTED", rejected = "REJECTED", apiError = "API_ERROR" }
enum H3QualificationInspectionIncompleteReason: String, Sendable {
    case invalidBundleIdentifier = "INVALID_BUNDLE_IDENTIFIER"
    case invalidExpectedTeam = "INVALID_EXPECTED_TEAM"
    case impossibleNativeTuple = "IMPOSSIBLE_NATIVE_TUPLE"
    case missingCachedResult = "MISSING_CACHED_RESULT"
    case unexpectedCapabilities = "UNEXPECTED_CAPABILITIES"
}
enum ProvenanceHostInspectionResult: Sendable, Equatable {
    case assessed(nativeResult: Int32, nativeError: Int32, status: H3QualificationSigningStatus,
                  capabilities: H3QualificationCapabilities?)
    case incomplete(reason: H3QualificationInspectionIncompleteReason,
                    nativeResult: Int32?, nativeError: Int32?)

    static func classify(nativeResult: Int32, nativeError: Int32,
                         queryHypervisor: Bool, capabilities: H3QualificationCapabilities?) -> Self {
        guard queryHypervisor || capabilities == nil else {
            return .incomplete(reason: .unexpectedCapabilities, nativeResult: nativeResult, nativeError: nativeError)
        }
        let status: H3QualificationSigningStatus
        switch (nativeResult, nativeError) {
        case (1, 0): status = .admitted
        case (0, 0): status = .rejected
        case (-1, let error) where error != 0: status = .apiError
        default: return .incomplete(reason: .impossibleNativeTuple, nativeResult: nativeResult, nativeError: nativeError)
        }
        return .assessed(nativeResult: nativeResult, nativeError: nativeError, status: status, capabilities: capabilities)
    }
}

struct H3QualificationHostInspectionCache: Sendable {
    private(set) var attempted = false
    private(set) var result: ProvenanceHostInspectionResult?

    /// Reserve the one inspection before the owner leaves its isolation domain.
    /// A repeated call consumes the same result; it cannot call the provider.
    mutating func begin(bundleIdentifierValid: Bool, expectedTeamValid: Bool) -> ProvenanceHostInspectionResult? {
        if attempted {
            return result ?? .incomplete(reason: .missingCachedResult, nativeResult: nil, nativeError: nil)
        }
        attempted = true
        if !bundleIdentifierValid {
            result = .incomplete(reason: .invalidBundleIdentifier, nativeResult: nil, nativeError: nil)
        } else if !expectedTeamValid {
            result = .incomplete(reason: .invalidExpectedTeam, nativeResult: nil, nativeError: nil)
        }
        return result
    }
    mutating func complete(_ value: ProvenanceHostInspectionResult) throws -> ProvenanceHostInspectionResult {
        guard attempted, result == nil else { throw H3QualificationFailure.invariant("inspection completion") }
        result = value
        return value
    }
    mutating func inspect(bundleIdentifierValid: Bool, expectedTeamValid: Bool,
                          provider: () -> ProvenanceHostInspectionResult) throws -> ProvenanceHostInspectionResult {
        if let cached = begin(bundleIdentifierValid: bundleIdentifierValid, expectedTeamValid: expectedTeamValid) { return cached }
        return try complete(provider())
    }
}

struct H3QualificationMonitorEvidence: Sendable, Equatable {
    let bytesObserved: UInt32
    let pollCalls: UInt32
    let readCalls: UInt32
    let routeCalls: UInt32
    let startedTick: UInt64
    let terminalTick: UInt64
    let fdClosed: Bool
    let taskJoined: Bool

    func validate(completionFirst: Bool) throws {
        guard pollCalls <= 1065, readCalls <= 1129, bytesObserved <= 41,
              routeCalls <= 1, startedTick > 0, terminalTick >= startedTick,
              fdClosed, taskJoined else { throw H3QualificationFailure.invariant("monitor evidence") }
        if completionFirst && (bytesObserved != 0 || routeCalls != 0) {
            throw H3QualificationFailure.invariant("completion after cancellation observation")
        }
        if !completionFirst && routeCalls != 1 { throw H3QualificationFailure.invariant("missing cancellation route") }
    }
    var wire: H3QualificationJSONValue {
        .object(["bytes_observed": .integer(Int64(bytesObserved)), "disposition": .string("COMPLETION_FIRST"),
                 "fd_closed": .bool(fdClosed), "poll_calls": .integer(Int64(pollCalls)),
                 "read_calls": .integer(Int64(readCalls)), "route_calls": .integer(Int64(routeCalls)),
                 "started_tick": .string(String(startedTick)), "task_joined": .bool(taskJoined),
                 "terminal_tick": .string(String(terminalTick))])
    }
}
enum H3QualificationCancellationDisposition: Sendable, Equatable {
    case completionFirst(H3QualificationMonitorEvidence)
    case cancellationFirst(H3QualificationMonitorEvidence)
}

enum H3QualificationWorkerPolicy {
    enum CompletionDecision: Sendable, Equatable { case releaseSentinel, releaseToken, rejectStart, cancellation, internalFailure }
    static func decision(outcome: H3QualificationWorkerOutcome,
                         reservation: H3QualificationReservationStateMachine,
                         completionFirst: Bool) -> CompletionDecision {
        guard reservation.policy == .qualificationChecked else { return .internalFailure }
        let matches: Bool
        switch outcome {
        case .canceledBeforeNative(let state): matches = (state == .unprepared || state == .acquired) && state == reservation.state
        case .preparationFailed(let error, _): matches = error > 0 && reservation.state == .failedReserve && error == reservation.observedError
        case .invalidReservation(let state, let error):
            matches = (state == .invalidReserveNoToken || state == .invalidReserveWithToken) &&
                state == reservation.state && error == reservation.observedError
        case .nativeReturned: matches = reservation.state == .acquired
        }
        guard matches else { return .internalFailure }
        if !completionFirst { return .cancellation }
        switch outcome {
        case .canceledBeforeNative: return .internalFailure
        case .preparationFailed: return .releaseSentinel
        case .invalidReservation: return .rejectStart
        case .nativeReturned: return .releaseToken
        }
    }
}

/// Pure continuous-time arithmetic shared by the application gate and monitor.
enum H3QualificationDeadline {
    static func end(start: UInt64, seconds: UInt64, numerator: UInt32, denominator: UInt32) throws -> UInt64 {
        guard start > 0, seconds > 0, numerator > 0, denominator > 0 else { throw H3QualificationFailure.invariant("clock") }
        let (nanos, overflow0) = seconds.multipliedReportingOverflow(by: 1_000_000_000)
        let (scaled, overflow1) = nanos.multipliedReportingOverflow(by: UInt64(denominator))
        let (rounded, overflow2) = scaled.addingReportingOverflow(UInt64(numerator) - 1)
        let (end, overflow3) = start.addingReportingOverflow(rounded / UInt64(numerator))
        guard !overflow0, !overflow1, !overflow2, !overflow3, end > start else {
            throw H3QualificationFailure.invariant("deadline arithmetic")
        }
        return end
    }
}

/// No clock, descriptor, callback, lock or Task is owned here. Effect owners
/// reserve a bounded call before entering the OS and report its exact result.
struct H3QualificationInputStateMachine: Sendable, Equatable {
    enum Role: Sendable { case gate, cancellation }
    enum Phase: Sendable { case pollable, polling, readable, reading, gateEOF, cancellationObserved, rejected }
    enum PollResult: Sendable { case ready, timeout, interrupted, failed }
    enum ReadResult: Sendable { case bytes(Int), eof, again, interrupted, failed }
    let role: Role
    let startTick: UInt64
    let deadline: UInt64
    private(set) var previousTick: UInt64
    private(set) var phase = Phase.pollable
    private(set) var offset = 0
    private(set) var pollCalls: UInt32 = 0
    private(set) var readCalls: UInt32 = 0
    private(set) var ordinaryPolls: UInt32 = 0
    private(set) var ordinaryReads: UInt32 = 0
    private(set) var pollInterrupts: UInt32 = 0
    private(set) var readInterrupts: UInt32 = 0
    private var requested = 0

    init(role: Role, startTick: UInt64, numerator: UInt32, denominator: UInt32) throws {
        self.role = role
        self.startTick = startTick
        self.previousTick = startTick
        self.deadline = try H3QualificationDeadline.end(start: startTick, seconds: role == .gate ? 6 : 10,
            numerator: numerator, denominator: denominator)
    }

    private mutating func reject(_ reason: String) throws -> Never {
        phase = .rejected
        throw H3QualificationFailure.invariant(reason)
    }

    mutating func observeClock(_ tick: UInt64) throws {
        guard phase != .rejected, phase != .cancellationObserved,
              tick >= previousTick, tick < deadline else { try reject("input clock/deadline") }
        previousTick = tick
    }

    mutating func beginPoll(at tick: UInt64) throws {
        guard phase == .pollable else { try reject("input poll order") }
        try observeClock(tick)
        guard ordinaryPolls < (role == .gate ? 601 : 1001),
              pollCalls < (role == .gate ? 665 : 1065), pollInterrupts < 64 else { try reject("input poll budget") }
        pollCalls += 1
        phase = .polling
    }

    mutating func finishPoll(_ result: PollResult, at tick: UInt64) throws {
        guard phase == .polling else { try reject("unreserved poll result") }
        try observeClock(tick)
        switch result {
        case .interrupted:
            pollInterrupts += 1
            phase = .pollable
        case .timeout:
            ordinaryPolls += 1
            phase = .pollable
        case .ready:
            ordinaryPolls += 1
            phase = .readable
        case .failed:
            ordinaryPolls += 1
            try reject("input poll failure")
        }
    }

    mutating func beginRead(at tick: UInt64, requested count: Int) throws {
        guard phase == .readable else { try reject("input read order") }
        try observeClock(tick)
        let remaining = role == .gate ? 42 - offset : 41
        guard count > 0, count <= remaining,
              ordinaryReads < (role == .gate ? 665 : 1065),
              readCalls < (role == .gate ? 729 : 1129), readInterrupts < 64 else { try reject("input read budget") }
        requested = count
        readCalls += 1
        phase = .reading
    }

    mutating func finishRead(_ result: ReadResult) throws {
        guard phase == .reading else { try reject("unreserved read result") }
        switch result {
        case .interrupted:
            readInterrupts += 1
            phase = .readable
        case .again:
            ordinaryReads += 1
            phase = .pollable
        case .failed:
            ordinaryReads += 1
            if role == .cancellation { phase = .cancellationObserved }
            else { try reject("input read failure") }
        case .eof:
            ordinaryReads += 1
            if role == .cancellation { phase = .cancellationObserved }
            else if offset == 41 { phase = .gateEOF }
            else { try reject("gate early EOF") }
        case .bytes(let count):
            ordinaryReads += 1
            guard count > 0, count <= requested else { try reject("input excess/zero return") }
            offset += count
            if role == .cancellation { phase = .cancellationObserved }
            else if offset <= 41 { phase = .pollable }
            else { try reject("gate trailing byte") }
        }
    }
}

/// Value-only schedule contract for the single retained monitor. Tests use
/// synthetic integer identities, never a real task/descriptor or callback.
struct H3QualificationBarrierStateMachine: Sendable, Equatable {
    enum Winner: Sendable { case completion, cancellation }
    private(set) var monitorIdentity: UInt64?
    private(set) var monitorInstalled = false
    private(set) var winner: Winner?
    private(set) var joined = false
    private var readCriticalSection = false
    private var completionClaimed = false
    private var cancellationRouted = false

    /// Reserve the one private handle slot before its task can start. This is
    /// not an installed/awaitable handle and cannot authorize completion.
    mutating func prepare(identity: UInt64) throws {
        guard identity > 0, monitorIdentity == nil, !completionClaimed else { throw H3QualificationFailure.invariant("monitor preparation") }
        monitorIdentity = identity
    }
    mutating func install(identity: UInt64) throws {
        guard identity > 0, !monitorInstalled, !completionClaimed,
              monitorIdentity == nil || monitorIdentity == identity else { throw H3QualificationFailure.invariant("monitor installation") }
        monitorIdentity = identity
        monitorInstalled = true
    }
    mutating func beginRead() throws -> Bool {
        guard monitorIdentity != nil, !readCriticalSection, !joined else { throw H3QualificationFailure.invariant("monitor read lock") }
        guard winner == nil else { return false }
        readCriticalSection = true
        return true
    }
    mutating func finishRead(cancellationObserved: Bool) throws {
        guard readCriticalSection, winner == nil else { throw H3QualificationFailure.invariant("read/latch linearization") }
        if cancellationObserved { winner = .cancellation }
        readCriticalSection = false
    }
    mutating func cancelForInternalFailure() throws {
        guard !readCriticalSection, monitorIdentity != nil, !joined else { throw H3QualificationFailure.invariant("monitor internal cancellation") }
        if winner == nil { winner = .cancellation }
    }
    mutating func claimCompletion() throws -> Winner {
        guard monitorInstalled, !readCriticalSection, !completionClaimed, !joined else { throw H3QualificationFailure.invariant("completion claim") }
        completionClaimed = true
        if winner == nil { winner = .completion }
        return winner!
    }
    mutating func routeCancellation() throws {
        guard !readCriticalSection, winner == .cancellation, !cancellationRouted, !joined else { throw H3QualificationFailure.invariant("monitor callback route") }
        cancellationRouted = true
    }
    mutating func join(identity: UInt64, fdClosed: Bool, handleCanceled: Bool) throws {
        guard !readCriticalSection, !joined, completionClaimed, identity == monitorIdentity, fdClosed,
              (winner == .completion && handleCanceled && !cancellationRouted) ||
              (winner == .cancellation && !handleCanceled && cancellationRouted) else { throw H3QualificationFailure.invariant("monitor join") }
        joined = true
    }
    var permitsReport: Bool { joined && winner == .completion }
}

/// An inert activation/lifecycle trace. Tokens represent object identity in
/// synthetic schedules; production retains and compares actual references.
struct H3QualificationActivationTrace: Sendable, Equatable {
    enum Event: Sendable {
        case entered(coordinator: UInt64, model: UInt64, lab: UInt64, owner: UInt64)
        case gateAccepted(numerator: UInt32, denominator: UInt32)
        case lifecycleInstalled(owner: UInt64, controller: UInt64, numerator: UInt32, denominator: UInt32)
        case exporterAdmitted
        case monitorInstalled(UInt64)
        case signingReturned
        case parentTaskCanceled
        case titlebarClosed
        case delegateQuit
        case ordinaryFallthrough
    }
    private(set) var entered = false
    private(set) var timebase: [UInt32]?
    private(set) var lifecycleIdentity: UInt64?
    private(set) var exporterAdmitted = false
    private(set) var monitorIdentity: UInt64?
    private(set) var signingReturned = false
    let coordinator: UInt64
    let model: UInt64
    let lab: UInt64
    let owner: UInt64
    init(coordinator: UInt64, model: UInt64, lab: UInt64, owner: UInt64) {
        self.coordinator = coordinator; self.model = model; self.lab = lab; self.owner = owner
    }
    mutating func observe(_ event: Event) throws {
        switch event {
        case .entered(let c, let m, let l, let o):
            guard !entered, c > 0, m > 0, l > 0, o > 0,
                  c == coordinator, m == model, l == lab, o == owner else { throw H3QualificationFailure.invariant("activation identities") }
            entered = true
        case .gateAccepted(let n, let d):
            guard entered, timebase == nil, n > 0, d > 0 else { throw H3QualificationFailure.invariant("activation gate") }
            timebase = [n, d]
        case .lifecycleInstalled(let o, let controller, let n, let d):
            guard entered, timebase == [n, d], o == owner, controller > 0, lifecycleIdentity == nil else {
                throw H3QualificationFailure.invariant("activation lifecycle")
            }
            lifecycleIdentity = controller
        case .exporterAdmitted:
            guard lifecycleIdentity != nil, !exporterAdmitted else { throw H3QualificationFailure.invariant("activation exporter") }
            exporterAdmitted = true
        case .monitorInstalled(let identity):
            guard exporterAdmitted, monitorIdentity == nil, identity > 0 else { throw H3QualificationFailure.invariant("activation monitor") }
            monitorIdentity = identity
        case .signingReturned:
            guard monitorIdentity != nil, !signingReturned else { throw H3QualificationFailure.invariant("activation signing") }
            signingReturned = true
        case .parentTaskCanceled, .titlebarClosed, .delegateQuit: break
        case .ordinaryFallthrough: throw H3QualificationFailure.invariant("qualification fallthrough")
        }
    }
}


// BEGIN APPLICATION EVENT POLICY — deep values only; no effects or wire fields.
#if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
enum H3QualificationApplicationEvent: Int, CaseIterable, Sendable {
    case owner, model, lab, storedModel, storedLab, coordinator, startup, gateTimebase, gateAccepted
    case lifecycleInstall, lifecycleInstance, exporterAdmission, exporterInstance, barrierInstance
    case monitorTask, monitorInstalled, signingInspection, signingTask, wrapperSigning, signingJoined
    case uuid, lifecycleBegin, workerTask, workerAwait, reserveAttempt, reserveAcquired, nativeEntry
    case barrierClaim, monitorCancel, monitorClose, monitorJoin, checkedRelease, nativeRelease
    case publication, lifecycleComplete, frame, exportAttempt, exportOutcome, terminalRequest
    case cancellationRoute, cancellationWorker, forceTimer
    case nativeSigning, nativeTimebase, watchdogCreate, watchdogJoin, vmCreate, guestRun
    case ordinaryLifecycle, extraWorker, threadDetach, childMainActorTask, continuation, retry
    case sqlite, h4, primeGit
}

struct H3QualificationApplicationEventVector: Sendable, Equatable {
    private var values = [UInt16](repeating: 0, count: H3QualificationApplicationEvent.allCases.count)
    subscript(_ event: H3QualificationApplicationEvent) -> UInt16 { values[event.rawValue] }
    @discardableResult mutating func add(_ event: H3QualificationApplicationEvent, count: UInt16 = 1) -> Bool {
        let (sum, overflow) = values[event.rawValue].addingReportingOverflow(count)
        let maximum: UInt16 = [.watchdogCreate, .watchdogJoin, .vmCreate, .guestRun].contains(event) ? 4 : 2
        guard !overflow, sum <= maximum else { return false }
        values[event.rawValue] = sum
        return true
    }
    static func sum(_ first: Self, _ second: Self) throws -> Self {
        var result = first
        for event in H3QualificationApplicationEvent.allCases {
            guard result.add(event, count: second[event]) else { throw H3QualificationFailure.bound("application campaign events") }
        }
        return result
    }
}

/// A local event record never grants a capability or authorizes a callback.
/// An invalid transition latches failure; callers must still finish their
/// existing ownership cleanup before refusing a report.
struct H3QualificationApplicationEventStateMachine: Sendable, Equatable {
    enum IdentityRole: Int, Sendable { case owner, model, lab, coordinator, lifecycle, monitor }
    private(set) var vector = H3QualificationApplicationEventVector()
    private(set) var failed = false
    private(set) var transitions: UInt16 = 0
    private(set) var inspection: ProvenanceHostInspectionResult?
    private(set) var numerator: UInt32 = 0
    private(set) var denominator: UInt32 = 0
    private var identities = [UInt64](repeating: 0, count: 6)
    let mode: H3QualificationMode
    init(mode: H3QualificationMode) { self.mode = mode }

    private mutating func reject() -> Bool { failed = true; return false }
    @discardableResult mutating func identity(_ role: IdentityRole, value: UInt64) -> Bool {
        guard value > 0 else { return reject() }
        let old = identities[role.rawValue]
        guard old == 0 || old == value else { return reject() }
        identities[role.rawValue] = value
        return true
    }
    @discardableResult mutating func record(_ event: H3QualificationApplicationEvent) -> Bool {
        guard transitions < 128 else { return reject() }
        transitions += 1
        guard vector[event] == 0 else { return reject() }
        let ready: Bool
        switch event {
        case .owner: ready = identities[IdentityRole.owner.rawValue] > 0
        case .model: ready = vector[.owner] == 1 && identities[IdentityRole.model.rawValue] > 0
        case .lab: ready = vector[.owner] == 1 && identities[IdentityRole.lab.rawValue] > 0
        case .storedModel: ready = vector[.model] == 1
        case .storedLab: ready = vector[.lab] == 1
        case .coordinator: ready = vector[.storedModel] == 1 && vector[.storedLab] == 1 && identities[IdentityRole.coordinator.rawValue] > 0
        case .startup: ready = vector[.coordinator] == 1
        case .gateTimebase: ready = vector[.startup] == 1
        case .gateAccepted: ready = vector[.gateTimebase] == 1 && numerator > 0 && denominator > 0
        case .lifecycleInstall: ready = vector[.gateAccepted] == 1
        case .lifecycleInstance: ready = vector[.lifecycleInstall] == 1 && identities[IdentityRole.lifecycle.rawValue] > 0
        case .exporterAdmission: ready = vector[.lifecycleInstance] == 1
        case .exporterInstance: ready = vector[.exporterAdmission] == 1
        case .barrierInstance: ready = vector[.exporterInstance] == 1
        case .monitorTask: ready = vector[.barrierInstance] == 1
        case .monitorInstalled: ready = vector[.monitorTask] == 1 && identities[IdentityRole.monitor.rawValue] > 0
        case .signingInspection: ready = vector[.monitorInstalled] == 1
        case .signingTask, .wrapperSigning, .signingJoined: ready = vector[.signingInspection] == 1
        case .barrierClaim: ready = inspection != nil
        case .monitorCancel: ready = vector[.barrierClaim] == 1
        case .monitorClose: ready = vector[.monitorTask] == 1
        case .monitorJoin: ready = vector[.barrierClaim] == 1 && vector[.monitorClose] == 1
        case .frame: ready = reportPrerequisites
        case .exportAttempt: ready = vector[.frame] == 1 && vector[.exporterInstance] == 1
        case .exportOutcome: ready = vector[.exportAttempt] == 1
        case .terminalRequest: ready = vector[.owner] == 1
        case .cancellationRoute: ready = vector[.monitorTask] == 1
        // Worker events enter only through the exact worker trace join.
        case .uuid, .lifecycleBegin, .workerTask, .workerAwait, .reserveAttempt, .reserveAcquired,
             .nativeEntry, .checkedRelease, .nativeRelease, .publication, .lifecycleComplete,
             .nativeSigning, .nativeTimebase, .watchdogCreate, .watchdogJoin, .vmCreate, .guestRun:
            return reject()
        case .cancellationWorker, .forceTimer:
            ready = vector[.cancellationRoute] == 1
        case .ordinaryLifecycle, .extraWorker, .threadDetach, .childMainActorTask, .continuation,
             .retry, .sqlite, .h4, .primeGit: return reject()
        }
        guard ready, vector.add(event) else { return reject() }
        return !failed
    }
    @discardableResult mutating func gate(numerator: UInt32, denominator: UInt32) -> Bool {
        guard self.numerator == 0, self.denominator == 0, numerator > 0, denominator > 0 else { return reject() }
        self.numerator = numerator; self.denominator = denominator
        return record(.gateAccepted)
    }
    @discardableResult mutating func lifecycle(owner: UInt64, stored: UInt64, returned: UInt64,
                                              numerator: UInt32, denominator: UInt32) -> Bool {
        guard owner == identities[IdentityRole.owner.rawValue], owner > 0,
              stored == returned, stored > 0, numerator == self.numerator, denominator == self.denominator,
              identities[IdentityRole.lifecycle.rawValue] == 0 else { return reject() }
        _ = identity(.lifecycle, value: stored)
        return record(.lifecycleInstance)
    }
    @discardableResult mutating func signing(_ result: ProvenanceHostInspectionResult) -> Bool {
        guard inspection == nil, vector[.signingInspection] == 1 else { return reject() }
        inspection = result
        switch result {
        case .assessed(let nativeResult, let nativeError, _, let capabilities):
            guard capabilities == nil,
                  ProvenanceHostInspectionResult.classify(nativeResult: nativeResult, nativeError: nativeError,
                    queryHypervisor: false, capabilities: nil) == result else { return reject() }
            _ = record(.signingTask); _ = record(.wrapperSigning); _ = record(.signingJoined)
        case .incomplete(let reason, _, _):
            if reason == .impossibleNativeTuple || reason == .unexpectedCapabilities {
                _ = record(.signingTask); _ = record(.wrapperSigning); _ = record(.signingJoined)
            }
        }
        return !failed
    }
    @discardableResult mutating func joinedMonitor(_ evidence: H3QualificationMonitorEvidence, completionFirst: Bool) -> Bool {
        _ = record(.barrierClaim)
        if completionFirst { _ = record(.monitorCancel) }
        if evidence.routeCalls == 1 { _ = record(.cancellationRoute) }
        if evidence.fdClosed { _ = record(.monitorClose) }
        do { try evidence.validate(completionFirst: completionFirst) }
        catch { return reject() }
        _ = record(.monitorJoin)
        return !failed
    }
    @discardableResult mutating func mergeWorker(_ worker: H3QualificationExecutionEventStateMachine) -> Bool {
        guard mode == .guest, vector[.workerTask] == 0,
              case .assessed(_, _, .admitted, nil) = inspection, worker.reportable else { return reject() }
        for event in H3QualificationExecutionEventStateMachine.workerEvents {
            guard vector[event] == 0, vector.add(event, count: worker.vector[event]) else { return reject() }
        }
        return !failed
    }
    var reportPrerequisites: Bool {
        guard !failed, vector[.monitorJoin] == 1, vector[.monitorCancel] == 1,
              vector[.cancellationRoute] == 0, vector[.signingJoined] == 1,
              case .assessed(_, _, let status, nil) = inspection else { return false }
        if mode == .admissionOnly || status != .admitted {
            return H3QualificationExecutionEventStateMachine.workerEvents.allSatisfy { vector[$0] == 0 }
        }
        return vector[.workerTask] == 1 && vector[.workerAwait] == 1 &&
            vector[.checkedRelease] == 1 && vector[.publication] == 1 && vector[.lifecycleComplete] == 1
    }
}

/// Count projection is minted only after the existing independent replay has
/// admitted the copied native prefix. No additional replay or observation.
struct H3QualificationNativeEventAssessment: Sendable, Equatable {
    let presentation: H3QualificationPresentation
    let signingCalls: UInt16
    let timebaseCalls: UInt16
    let watchdogCreates: UInt16
    let watchdogJoins: UInt16
    let vmCreates: UInt16
    let guestEntries: UInt16
    static func replay(_ capture: H3QualificationNativeCapture) throws -> Self {
        let presentation = try H3QualificationReplay.replay(capture: capture)
        let value = capture.wire
        guard let admitted = value["outer"]?["signing_admitted"]?.intValue,
              let signingError = value["outer"]?["signing_error"]?.intValue,
              let creates = value["outer"]?["watchdog_create_entries"]?.intValue,
              let joins = value["outer"]?["watchdog_join_entries"]?.intValue,
              let sourceEntries = value["source"]?["run_entries"]?.intValue,
              let targetEntries = value["target"]?["run_entries"]?.intValue else {
            throw H3QualificationFailure.invariant("admitted native event projection")
        }
        let signing: UInt16 = signingError != Int64(Int32.min) ? 1 : 0
        return Self(presentation: presentation, signingCalls: signing, timebaseCalls: admitted == 1 ? 1 : 0,
            watchdogCreates: UInt16(creates), watchdogJoins: UInt16(joins),
            vmCreates: UInt16(["source", "target"].filter { value[$0]?["vm_create_status"]?.intValue == 0 }.count),
            guestEntries: UInt16(sourceEntries + targetEntries))
    }
}

struct H3QualificationExecutionEventStateMachine: Sendable, Equatable {
    static let workerEvents: [H3QualificationApplicationEvent] = [
        .uuid, .lifecycleBegin, .workerTask, .workerAwait, .reserveAttempt, .reserveAcquired,
        .nativeEntry, .checkedRelease, .nativeRelease, .publication, .lifecycleComplete,
        .nativeSigning, .nativeTimebase, .watchdogCreate, .watchdogJoin, .vmCreate, .guestRun
    ]
    private(set) var vector = H3QualificationApplicationEventVector()
    private(set) var failed = false
    private(set) var native: H3QualificationNativeEventAssessment?
    private(set) var reservation: H3QualificationReservationStateMachine?
    private(set) var monitorJoined = false
    private(set) var completionFirst = false
    private(set) var returned = false
    private(set) var presentationMatched = false
    private var identity: UUID?
    private var owner: UInt64 = 0
    @discardableResult mutating func begin(identity: UUID, owner: UInt64) -> Bool {
        guard owner > 0, self.identity == nil, vector[.uuid] == 0 else { failed = true; return false }
        self.identity = identity; self.owner = owner
        return vector.add(.uuid)
    }
    @discardableResult mutating func record(_ event: H3QualificationApplicationEvent) -> Bool {
        guard Self.workerEvents.contains(event), vector[event] == 0 else { failed = true; return false }
        let ready: Bool
        switch event {
        case .lifecycleBegin: ready = vector[.uuid] == 1
        case .workerTask: ready = vector[.lifecycleBegin] == 1
        case .reserveAttempt: ready = vector[.workerTask] == 1
        case .nativeEntry: ready = reservation?.state == .acquired && !returned && vector[.workerTask] == 1
        case .workerAwait: ready = vector[.workerTask] == 1 && returned
        case .checkedRelease:
            ready = vector[.workerAwait] == 1 && monitorJoined && completionFirst &&
                presentationMatched &&
                (reservation?.state == .failedReserve || (reservation?.state == .acquired && native != nil))
        case .publication: ready = vector[.checkedRelease] == 1 && releaseSucceeded
        case .lifecycleComplete:
            ready = vector[.workerAwait] == 1 && monitorJoined &&
                (vector[.nativeEntry] == 0 || presentationMatched) &&
                (completionFirst ? vector[.publication] == 1 : true)
        default: ready = false
        }
        guard ready, vector.add(event) else { failed = true; return false }
        return !failed
    }
    mutating func reserveReturned(_ value: H3QualificationReservationStateMachine) {
        guard vector[.workerTask] == 1, identity != nil, owner > 0,
              reservation == nil, value.policy == .qualificationChecked,
              value.state != .releasedWithoutToken, value.state != .releaseAttemptedToken,
              value.reservationReleaseEntries == 0, value.reservationReleaseStatus == .min else { failed = true; return }
        reservation = value
        if value.state != .unprepared { _ = record(.reserveAttempt) }
        if value.state == .acquired { _ = vector.add(.reserveAcquired) }
    }
    mutating func workerReturned(native: H3QualificationNativeEventAssessment? = nil, parity: Bool = true) {
        guard !returned, reservation != nil, vector[.workerTask] == 1 else { failed = true; return }
        if let native {
            guard vector[.nativeEntry] == 1 else { failed = true; return }
            self.native = native
            for (event, count): (H3QualificationApplicationEvent, UInt16) in [
                (.nativeSigning, native.signingCalls), (.nativeTimebase, native.timebaseCalls),
                (.watchdogCreate, native.watchdogCreates), (.watchdogJoin, native.watchdogJoins),
                (.vmCreate, native.vmCreates), (.guestRun, native.guestEntries)
            ] {
                if !vector.add(event, count: count) { failed = true }
            }
        } else if vector[.nativeEntry] != 0 { failed = true }
        if !parity { failed = true }
        presentationMatched = parity
        returned = true
    }
    mutating func join(_ evidence: H3QualificationMonitorEvidence, first: Bool) {
        guard !monitorJoined, vector[.workerAwait] == 1 else { failed = true; return }
        do { try evidence.validate(completionFirst: first) } catch { failed = true; return }
        monitorJoined = true; completionFirst = first
    }
    mutating func released(_ value: H3QualificationReservationStateMachine) {
        guard vector[.checkedRelease] == 1, let prior = reservation,
              prior.policy == value.policy, prior.observedError == value.observedError,
              prior.reservationEntries == value.reservationEntries,
              (prior.state == .failedReserve && value.state == .releasedWithoutToken && value.reservationReleaseEntries == 0) ||
              (prior.state == .acquired && value.state == .releaseAttemptedToken && value.reservationReleaseEntries == 1)
        else { failed = true; return }
        if value.reservationReleaseEntries == 1 { _ = vector.add(.nativeRelease) }
        reservation = value
        if !releaseSucceeded { failed = true }
    }
    mutating func sameOwners(identity: UUID, owner: UInt64) {
        if identity != self.identity || owner != self.owner { failed = true }
    }
    private var releaseSucceeded: Bool {
        guard let reservation else { return false }
        return (reservation.state == .releasedWithoutToken && reservation.reservationReleaseEntries == 0 &&
                reservation.reservationReleaseStatus == .min) ||
            (reservation.state == .releaseAttemptedToken && reservation.reservationReleaseEntries == 1 &&
             reservation.reservationReleaseStatus == 0)
    }
    var reportable: Bool {
        !failed && completionFirst && monitorJoined && vector[.checkedRelease] == 1 &&
            vector[.publication] == 1 && vector[.lifecycleComplete] == 1 && releaseSucceeded
    }
}

/// Gate identity matching is pure and shared with the actual FD-3 owner.
enum H3QualificationGateIdentity {
    static func validate(_ frame: Data, mode: H3QualificationMode, nonce: String) throws {
        guard frame == (try H3QualificationProtocol.gateFrame(mode: mode, nonce: nonce)) else {
            throw H3QualificationFailure.malformed("gate identity")
        }
    }
}

/// The same short-circuit start decision used before any UUID/worker creation.
/// A lifecycle.beginRun error is a separate, already-counted prefix.
enum H3QualificationStartEventPolicy {
    static func rejection(lifecycleInstalled: Bool, admitted: Bool, modelEligible: Bool) -> H3QualificationStartRejection? {
        if !lifecycleInstalled { return .lifecycleNotInstalled }
        if !admitted { return .notAdmitted }
        if !modelEligible { return .modelStateRejected }
        return nil
    }
}

/// Selects only the existing owner's cancellation-helper eligibility. It
/// neither requests cancellation nor fabricates a native handle or callback.
enum H3QualificationCancellationEventPolicy {
    static func mayStartHelper(policy: H3QualificationReservationStateMachine.Policy,
                               state: H3QualificationReservationStateMachine.State, tokenPresent: Bool) -> Bool {
        tokenPresent && (policy == .ordinaryDeinit || state == .acquired)
    }
}
#endif
// END APPLICATION EVENT POLICY


enum H3QualificationWire {
    typealias Value = H3QualificationJSONValue
    private static let catalog: Value = try! H3QualificationCanonicalJSON.decode(
        h3QualificationWireCatalogBytes, maximumBytes: 262_144)

    /// Structural validation is deliberately distinct from semantic admission.
    /// Callers that need an admitted artifact must call validate, not this API.
    static func validateStructure(_ value: Value, schema: String) throws {
        guard let descriptors = catalog[schema]?.objectValue, let fields = value.objectValue,
              Set(fields.keys) == Set(descriptors.keys) else {
            throw H3QualificationFailure.malformed("\(schema) exact keys")
        }
        for key in descriptors.keys.sorted() {
            guard let descriptor = descriptors[key]?.stringValue, let field = fields[key] else {
                throw H3QualificationFailure.invariant("wire catalog")
            }
            try validateField(field, descriptor: descriptor, context: "\(schema).\(key)")
        }
    }

    static func validate(_ value: Value, schema: String) throws {
        try validateStructure(value, schema: schema)
        switch schema {
        case "inner_report_v1": try validateInner(value)
        case "inner_signing_rejected":
            let result = value["native_result"]?.intValue
            let error = value["error"]?.intValue
            let status = value["status"]?.stringValue
            guard (result == 0 && error == 0 && status == "REJECTED") ||
                  (result == -1 && error != nil && error != 0 && status == "API_ERROR") else {
                throw H3QualificationFailure.malformed("signing tuple")
            }
        case "inner_signing_admitted":
            guard H3QualificationProtocol.hash(try H3QualificationCanonicalJSON.encode(value.required("effective_entitlements"))) ==
                value["effective_entitlements_sha256"]?.stringValue else {
                throw H3QualificationFailure.malformed("entitlement digest")
            }
        case "inner_native_not_entered":
            guard let reason = value["reason"]?.stringValue, let error = value["preparation_error"]?.intValue,
                  (reason == "PREPARATION_REJECTED" ? error > 0 : error == Int64(Int32.min)) else {
                throw H3QualificationFailure.malformed("preparation tuple")
            }
        case "inner_native_returned": try validateNative(value)
        case "inner_authority", "inner_build", "effective_entitlements", "inner_effects", "inner_gate",
             "inner_process", "inner_timing", "inner_cancellation_monitor", "run_identity",
             "inner_verifier_not_entered", "inner_verifier_result", "native_checkpoint_page",
             "native_checkpoint", "native_phase", "native_outer", "native_sctlr_transition": break
        default:
            try H3QExternal.validate(value, schema: schema)
        }
    }

    private static func validateField(_ value: Value, descriptor d: String, context: String) throws {
        func reject() -> H3QualificationFailure { .malformed("wire field \(context)") }
        func integer(_ lower: Int64, _ upper: Int64) throws {
            guard let n = value.intValue, (lower...upper).contains(n) else { throw reject() }
        }
        func stringBound(_ maximum: Int, controlsAllowed: Bool = false) throws {
            guard let string = value.stringValue, string.utf8.count <= maximum,
                  controlsAllowed || !string.unicodeScalars.contains(where: { $0.value < 32 || $0.value == 127 }) else { throw reject() }
        }
        func hex(_ count: Int) throws {
            guard let text = value.stringValue else { throw reject() }
            _ = try H3QualificationProtocol.unhex(text, bytes: count)
        }
        if try H3QExternal.field(value, descriptor: d, context: context) { return }
        if d == "null or u64dec" { if value == .null { return }; try validateField(value, descriptor: "u64dec", context: context); return }
        if d == "empty string or hex64" { if value == .string("") { return }; try hex(32); return }
        if d.hasPrefix("effective_entitlements for the application") {
            if value == .null { return }; try validateStructure(value, schema: "effective_entitlements"); return
        }
        if d.hasPrefix("enum(UNKNOWN) or count2") {
            if value == .string("UNKNOWN") { return }; try integer(0, 2); return
        }
        if d.hasPrefix("const(0) for ADMISSION,") { try integer(0, 4); return }
        if d.hasPrefix("const(") || d.hasPrefix("enum(") {
            guard let end = d.firstIndex(of: ")") else { throw H3QualificationFailure.invariant("descriptor") }
            let start = d.index(after: d.firstIndex(of: "(")!)
            let choices = d[start..<end].split(separator: ",").map(String.init)
            if d.contains("null for verifier modes"), value == .null { return }
            for choice in choices {
                if choice == "true", value == .bool(true) { return }
                if choice == "false", value == .bool(false) { return }
                if choice == "null", value == .null { return }
                if choice == "[]", value == .array([]) { return }
                if choice.contains("...") {
                    let ends = choice.components(separatedBy: "...")
                    if ends.count == 2, let lo = Int64(ends[0]), let hi = Int64(ends[1]),
                       let number = value.intValue, (lo...hi).contains(number) { return }
                } else if let number = Int64(choice), String(number) == choice {
                    if value.intValue == number { return }
                } else if value == .string(choice) { return }
            }
            throw reject()
        }
        if d.hasPrefix("one_of(") {
            guard let end = d.firstIndex(of: ")") else { throw reject() }
            let names = d[d.index(d.startIndex, offsetBy: 7)..<end].split(separator: ",").map(String.init)
            var matches = 0
            for name in names { if (try? validateStructure(value, schema: name)) != nil { matches += 1 } }
            guard matches == 1 else { throw reject() }; return
        }
        if d.hasPrefix("array(") {
            guard let comma = d.firstIndex(of: ","), let values = value.arrayValue else { throw reject() }
            let type = String(d[d.index(d.startIndex, offsetBy: 6)..<comma])
            let suffix = d[d.index(after: comma)...]
            let countText = suffix.dropFirst("exactly".count).prefix(while: { $0.isNumber })
            guard let count = Int(countText), values.count == count else { throw reject() }
            for element in values { try validateField(element, descriptor: type, context: context) }
            if type == "native_checkpoint_page" {
                guard values.map({ $0["role"]?.stringValue }) == ["code", "request", "reply"] else { throw reject() }
            }
            return
        }
        if d.hasPrefix("JSON integer") {
            if d == "JSON integer in the frozen per-file bound" { try integer(0, 8_388_608); return }
            guard let range = d.range(of: #"[0-9]+\.\.\.[0-9]+"#, options: .regularExpression) else { throw reject() }
            let ends = d[range].components(separatedBy: "...")
            if d.contains("or const(4294967295)"), value.intValue == 4_294_967_295 { return }
            try integer(Int64(ends[0])!, Int64(ends[1])!); return
        }
        if d.hasPrefix("u32") {
            try integer(0, 4_294_967_295)
            if d.contains(">0"), value.intValue == 0 { throw reject() }
            if d.contains("0...1065") { try integer(0, 1065) }
            if d.contains("0...1129") { try integer(0, 1129) }
            return
        }
        if d.hasPrefix("i32") {
            if d.contains("NOT_APPLICABLE"), value == .string("NOT_APPLICABLE") { return }
            try integer(Int64(Int32.min), Int64(Int32.max)); return
        }
        if d.hasPrefix("u64dec") || d.hasPrefix("tick") {
            guard let text = value.stringValue, !text.isEmpty, text.utf8.count <= 20,
                  text.utf8.allSatisfy({ (48...57).contains($0) }), let n = UInt64(text), String(n) == text else { throw reject() }
            if d.hasPrefix("tick"), n == 0 { throw reject() }
            if d.contains(">=2"), n < 2 { throw reject() }
            if d.contains("const(1)"), n != 1 { throw reject() }
            if d.contains("1...67108864"), !(1...67_108_864).contains(n) { throw reject() }
            return
        }
        if d.hasPrefix("hex") {
            let digits = d.dropFirst(3).prefix(while: { $0.isNumber })
            guard let count = Int(digits), count % 2 == 0 else { throw reject() }
            try hex(count / 2); return
        }
        if d.hasPrefix("lowercase SHA-256") || d.hasPrefix("same exact admitted seal source hash") ||
            d.hasPrefix("the exact admitted canonical entitlement hash") { try hex(32); return }
        if d == "bit" { try integer(0, 1); return }
        if d == "count2" { try integer(0, 2); return }
        if d == "boolean" { guard value.boolValue != nil else { throw reject() }; return }
        if d == "cdhash" {
            guard let string = value.stringValue, string.count == 40 || string.count == 64 else { throw reject() }
            try hex(string.count / 2); return
        }
        if d == "uuid" {
            guard let text = value.stringValue, text.utf8.count == 36 else { throw reject() }
            let parts = text.split(separator: "-", omittingEmptySubsequences: false)
            guard parts.map(\.count) == [8, 4, 4, 4, 12] else { throw reject() }
            for part in parts { _ = try H3QualificationProtocol.unhex(String(part), bytes: part.count / 2) }; return
        }
        if d == "text256" { try stringBound(256); return }
        if d == "verifier_diagnostic_list" {
            guard let values = value.arrayValue, values.count <= 64 else { throw reject() }
            for element in values { try validateField(element, descriptor: "text256", context: context) }; return
        }
        if d.hasPrefix("exact array [APP_SANDBOX") {
            guard value == .array(["APP_SANDBOX_CONTAINER_ID", "CFFIXED_USER_HOME", "HOME", "TMPDIR", "__CF_USER_TEXT_ENCODING"].map(Value.string)) else { throw reject() }; return
        }
        let first = String(d.prefix(while: { $0 != " " && $0 != ";" }))
        if catalog[first] != nil { try validateStructure(value, schema: first); return }
        if d.hasPrefix("relpath") || d == "one exact frozen basename" {
            try stringBound(4096)
            guard let path = value.stringValue, !path.isEmpty, !path.hasPrefix("/"), !path.contains("\\"),
                  path.utf8.allSatisfy({ $0 >= 32 && $0 < 127 }),
                  path.split(separator: "/", omittingEmptySubsequences: false).count <= 8,
                  path.split(separator: "/", omittingEmptySubsequences: false).allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." }) else { throw reject() }
            if d == "one exact frozen basename", path.contains("/") { throw reject() }; return
        }
        if d.contains("absolute") || d == "the exact corresponding frozen fresh path" {
            try stringBound(4096)
            guard let path = value.stringValue, path.hasPrefix("/"), !path.contains("\\"),
                  path != "/", path.dropFirst().split(separator: "/", omittingEmptySubsequences: false).allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." }) else { throw reject() }; return
        }
        if d.hasPrefix("positive JSON integer") || d.hasPrefix("same positive JSON integer") || d.hasPrefix("the i32 returned directly") {
            try integer(d.hasPrefix("the i32") ? 0 : 1, Int64(Int32.max)); return
        }
        if d.hasPrefix("RFC4648 padded base64") {
            guard let text = value.stringValue else { throw reject() }
            if context == "captured_stream.base64" {
                let count = text.utf8.count
                guard count <= 87_384, count % 4 == 0 else { throw reject() }
                let padding = text.hasSuffix("==") ? 2 : text.hasSuffix("=") ? 1 : 0
                guard count / 4 * 3 - padding <= 65_536 else { throw reject() }
            }
            guard let decoded = Data(base64Encoded: text), decoded.base64EncodedString() == text else { throw reject() }; return
        }
        throw H3QualificationFailure.unsupportedSchema("field \(context): \(d)")
    }

    private static func validateInner(_ value: Value) throws {
        let run = try value.required("run"), native = try value.required("native"), signing = try value.required("signing")
        let effects = try value.required("effects"), verifier = try value.required("verifier")
        let gate = try value.required("gate"), timing = try value.required("timing"), monitor = try value.required("cancellation_monitor")
        guard let modeText = run["mode"]?.stringValue, let mode = H3QualificationMode(rawValue: modeText),
              let configText = run["configuration"]?.stringValue, let configuration = H3QualificationConfiguration(rawValue: configText),
              let nonce = run["nonce"]?.stringValue, value["build"]?["configuration"] == run["configuration"],
              run["run_id"] == .string(try H3QualificationProtocol.runID(mode: mode, configuration: configuration, nonce: nonce)),
              gate["frame_sha256"] == .string(H3QualificationProtocol.hash(try H3QualificationProtocol.gateFrame(mode: mode, nonce: nonce))),
              gate["mode_byte"] == .string(mode == .admissionOnly ? "01" : "02"),
              effects["signing_state"] == signing["status"] else { throw H3QualificationFailure.malformed("inner identity joins") }
        try validate(signing, schema: signing["admitted"] == .bool(true) ? "inner_signing_admitted" : "inner_signing_rejected")
        let ordered = [timing["continuous_start_tick"], gate["validated_tick"], monitor["started_tick"], monitor["terminal_tick"], timing["continuous_end_tick"]].compactMap { $0?.uintValue }
        guard ordered.count == 5, zip(ordered, ordered.dropFirst()).allSatisfy({ $0 <= $1 }) else {
            throw H3QualificationFailure.malformed("inner clock order")
        }
        if native["disposition"] == .string("NOT_ENTERED") {
            try validate(native, schema: "inner_native_not_entered")
            guard native["reason"] != .string("CANCELED_BEFORE_ENTRY"), effects["reservation_entries"]?.intValue == 0,
                  effects["reservation_release_entries"]?.intValue == 0,
                  effects["reservation_release_status"]?.intValue == Int64(Int32.min),
                  effects["hv_vm_created_count"]?.intValue == 0, effects["guest_entered_count"]?.intValue == 0 else {
                throw H3QualificationFailure.malformed("pre-native effects")
            }
            let admitted = signing["admitted"] == .bool(true)
            if mode == .admissionOnly {
                guard native["reason"] == .string(admitted ? "ADMISSION_MODE" : "SIGNING_REJECTED"),
                      effects["lifecycle_disposition"] == .string("NOT_ENTERED"),
                      verifier == .object(["disposition": .string("NOT_ENTERED")]) else {
                    throw H3QualificationFailure.malformed("admission-only effects")
                }
            } else {
                let preparation = native["reason"] == .string("PREPARATION_REJECTED")
                guard preparation == admitted,
                      native["reason"] == .string(preparation ? "PREPARATION_REJECTED" : "SIGNING_REJECTED"),
                      effects["lifecycle_disposition"] == .string(preparation ? "RECOVERY_VOLATILE" : "NOT_ENTERED") else {
                    throw H3QualificationFailure.malformed("guest pre-native mapping")
                }
                let error = preparation ? "H3 preparation failed with errno \(native["preparation_error"]!.intValue!)" : "live self-signing admission did not pass"
                guard verifier == H3QualificationReplay.preparationRejected(error: error).wire else {
                    throw H3QualificationFailure.malformed("pre-native verifier replay")
                }
            }
        } else {
            guard mode == .guest, signing["admitted"] == .bool(true), effects["reservation_entries"]?.intValue == 1,
                  effects["reservation_release_entries"]?.intValue == 1, effects["reservation_release_status"]?.intValue == 0 else {
                throw H3QualificationFailure.malformed("returned reservation")
            }
            try validateNative(native)
            let replay = try H3QualificationReplay.replay(capture: .init(wire: native))
            let source = try native.required("source"), target = try native.required("target")
            let vms = [source, target].filter { $0["vm_create_status"]?.intValue == 0 }.count
            let entries = (source["run_entries"]?.intValue ?? -1) + (target["run_entries"]?.intValue ?? -1)
            guard effects["hv_vm_created_count"]?.intValue == Int64(vms), effects["guest_entered_count"]?.intValue == entries,
                  effects["lifecycle_disposition"] == .string(replay.quarantined ? "QUARANTINED" : "RECOVERY_VOLATILE"),
                  verifier == replay.wire else { throw H3QualificationFailure.malformed("returned replay joins") }
        }
    }

    private static func validateNative(_ native: Value) throws {
        // Scalar and source-prefix admission precedes every reconstruction.
        try validateStructure(native, schema: "inner_native_returned")
        let outer = try native.required("outer")
        func n(_ key: String) -> Int64 { outer[key]?.intValue ?? -9_999_999_999 }
        let count = n("cursor_evidence_byte_count")
        guard let evidenceHex = native["cursor_evidence_hex"]?.stringValue else { throw H3QualificationFailure.malformed("cursor bytes") }
        let evidence = try H3QualificationProtocol.unhex(evidenceHex, bytes: 680)
        guard native["cursor_evidence_sha256"] == .string(H3QualificationProtocol.hash(evidence)),
              count == 680 || (count == 0 && evidence.allSatisfy({ $0 == 0 })),
              (0...23).contains(n("failure_stage")), (n("failure_stage") == 0) == (n("first_error") == 0),
              n("cancellation_calls") <= n("cancellation_requested"),
              (n("cancellation_calls") == 0) == (n("cancellation_status") == Int64(Int32.min)),
              n("watchdog_fired") == 0 || n("cancellation_requested") == 1,
              n("signing_admitted") == 0 || n("signing_error") == 0,
              n("watchdog_join_entries") <= n("watchdog_create_entries"),
              n("cursor_sealed") == (count == 680 ? 1 : 0),
              n("cursor_sealed") <= n("checkpoint_valid"),
              n("cursor_decoded") <= n("cursor_sealed"), n("cursor_decoded") <= n("source_conserved"),
              n("cursor_restored") <= n("cursor_decoded"), n("terminal_valid") <= n("cursor_restored"),
              n("execution_pass") <= n("terminal_valid"),
              n("resources_quarantined") == 0 || n("teardown_pass") == 0 else {
            throw H3QualificationFailure.malformed("native source prefix")
        }
        let numerator = n("timebase_numer"), denominator = n("timebase_denom")
        let start = outer["start_ticks"]?.uintValue ?? .max, end = outer["end_ticks"]?.uintValue ?? 0
        guard ((numerator == 0 && denominator == 0) || (numerator > 0 && denominator > 0)),
              (start == 0 && end == 0) || (start > 0 && start <= end) else { throw H3QualificationFailure.malformed("native clock prefix") }
        if n("cancellation_requested") == 0, n("execution_pass") != n("terminal_valid") {
            throw H3QualificationFailure.malformed("native terminal execution")
        }
        let creates = n("watchdog_create_entries"), joins = n("watchdog_join_entries")
        let createStatus = n("watchdog_create_status"), joinStatus = n("watchdog_join_status"), sentinel = Int64(Int32.min)
        guard creates != 0 || (createStatus == sentinel && joins == 0 && joinStatus == sentinel),
              (joins == 0) == (joinStatus == sentinel) else { throw H3QualificationFailure.malformed("watchdog untouched prefix") }
        if creates == 1 {
            guard createStatus == 0 ? joins == 1 : (createStatus > 0 && joins == 0 && joinStatus == sentinel) else { throw H3QualificationFailure.malformed("first watchdog") }
        }
        if creates == 2 {
            guard createStatus == 0 ? joins == 2 : (createStatus > 0 && joins == 1 && joinStatus == 0) else { throw H3QualificationFailure.malformed("second watchdog") }
        }
        if joins > 0 && joinStatus != 0, n("resources_quarantined") != 1 || n("teardown_pass") != 0 {
            throw H3QualificationFailure.malformed("failed watchdog join")
        }
        for role in ["source", "target"] {
            try validatePhase(try native.required(role), source: role == "source")
        }
        try validateNativeReachability(H3QCopiedResult(capture: .init(wire: native)))
    }

    private static func validatePhase(_ phase: Value, source: Bool) throws {
        func n(_ key: String) -> Int64 { phase[key]?.intValue ?? -9_999_999_999 }
        let sentinel = Int64(Int32.min)
        let maps = phase["map_statuses"]!.arrayValue!.map { $0.intValue! }
        let mappings = n("mappings_entered"), setters = n("register_set_calls"), reads = n("register_read_calls"), runs = n("run_entries")
        guard reads <= (source ? 36 : 38),
              (setters == 0) == (n("register_status") == sentinel),
              (reads == 0) == (n("read_register_status") == sentinel),
              (runs == 0) == (n("run_status") == sentinel) else { throw H3QualificationFailure.malformed("phase count/status") }
        guard n("vm_create_status") == 0 ? mappings >= 1 : mappings == 0 else { throw H3QualificationFailure.malformed("mapping admission") }
        for index in maps.indices {
            if index >= mappings { guard maps[index] == sentinel else { throw H3QualificationFailure.malformed("unattempted map") } }
            else if index + 1 < mappings { guard maps[index] == 0 else { throw H3QualificationFailure.malformed("map prefix") } }
            else { guard maps[index] != sentinel, mappings == 3 || maps[index] != 0 else { throw H3QualificationFailure.malformed("map terminal") } }
        }
        let vcpuEligible = mappings == 3 && maps.allSatisfy { $0 == 0 }
        guard (n("vcpu_create_status") != sentinel) == vcpuEligible,
              n("vcpu_create_status") == 0 || setters == 0,
              setters == 0 || setters == 36 || n("register_status") != 0,
              runs == 0 || (setters == 36 && n("register_status") == 0) else {
            throw H3QualificationFailure.malformed("register prefix")
        }
        let entry = phase["entry_ticks"]!.uintValue!, exit = phase["exit_ticks"]!.uintValue!
        guard runs == 0 ? exit == 0 : (entry > 0 && entry <= exit) else { throw H3QualificationFailure.malformed("phase ticks") }
        if source {
            guard n("run_status") == 0 ? reads > 0 : reads == 0,
                  reads == 0 || reads == 36 || n("read_register_status") != 0 else {
                throw H3QualificationFailure.malformed("source read prefix")
            }
        } else {
            guard reads == 0 || (setters == 36 && n("register_status") == 0),
                  runs == 0 ? reads <= 36 : (n("run_status") == 0 ? reads >= 37 : reads == 36),
                  reads != 37 || n("read_register_status") != 0 else {
                throw H3QualificationFailure.malformed("target read prefix")
            }
        }
    }

    // These predicates admit only a returned prefix of HypervisorGuest.c's
    // fixed H3 owner. They do not turn a coherent native non-PASS into a PASS.
    // There is no allocation counter in the ABI: before VM creation its exact
    // successful mmap prefix is witnessed by the ordered host-unmap calls.
    private struct NativePhasePrefix {
        let attempted: Bool
        let cleanupFailure: Int32?
        let cleanupError: Int32?
        let forwardFailure: Int32?
        let forwardError: Int32?
    }

    private static func nativeRequire(_ condition: Bool, _ detail: String) throws {
        guard condition else { throw H3QualificationFailure.malformed("native prefix: \(detail)") }
    }

    private static func nativeTrap(_ p: H3QCopiedPhase, source: Bool) -> Bool {
        let dfsc = p.syndrome & 63
        return p.exception_reason == 1 && (4...7).contains(dfsc) &&
            p.syndrome == (0x9384_0040 | dfsc) && p.pc == (source ? 0x1000_0050 : 0x1000_007c) &&
            p.fault_ipa == 0x1000_c000 && p.fault_virtual_address == 0x1000_c000 && p.x4 == (source ? 1 : 2)
    }

    private static func nativePhasePrefix(_ p: H3QCopiedPhase, source: Bool) throws -> NativePhasePrefix {
        let absent = Int32.min
        let allocated = p.host_unmap_status.prefix { $0 != absent }.count
        try nativeRequire(p.host_unmap_status.dropFirst(allocated).allSatisfy { $0 == absent }, "host allocation prefix")
        try nativeRequire(p.host_unmap_status.allSatisfy { [absent, -1, 0].contains($0) }, "munmap return domain")
        let vmAttempted = p.vm_create_status != absent
        let vmCreated = p.vm_create_status == 0
        let vcpuCreated = p.vcpu_create_status == 0
        let vcpuCleared = !vcpuCreated || p.vcpu_destroy_status == 0
        let kernelCleared = vcpuCleared && (!vmCreated || p.vm_destroy_status == 0)
        try nativeRequire((p.vcpu_destroy_status != absent) == vcpuCreated, "vcpu destruction entry")
        try nativeRequire((p.vm_destroy_status != absent) == (vmCreated && vcpuCleared), "VM destruction entry")
        for i in 0..<3 {
            try nativeRequire((p.unmap_status[i] != absent) == (vcpuCleared && p.map_status[i] == 0), "mapped slot cleanup \(i)")
        }
        try nativeRequire(kernelCleared ? (!vmAttempted || allocated == 3) : allocated == 0, "allocation/kernel cleanup dependency")
        let attempted = vmAttempted || allocated > 0 || p.conserved == 1
        let cleanupFailure: Int32?
        if vcpuCreated && p.vcpu_destroy_status != 0 { cleanupFailure = 14 }
        else if p.unmap_status.contains(where: { $0 != absent && $0 != 0 }) { cleanupFailure = 15 }
        else if vmCreated && p.vm_destroy_status != 0 { cleanupFailure = 16 }
        else if p.host_unmap_status.contains(-1) { cleanupFailure = 17 }
        else { cleanupFailure = nil }
        try nativeRequire(p.conserved == (attempted && kernelCleared && cleanupFailure == nil ? 1 : 0), "phase conservation result")
        if !attempted {
            try nativeRequire(p.register_set_calls == 0 && p.register_read_calls == 0 && p.run_entries == 0 &&
                p.entry_ticks == 0 && p.exit_ticks == 0, "unattempted phase")
        }
        let successfulRun = p.run_entries == 1 && p.run_status == 0
        if !successfulRun {
            try nativeRequire(p.exception_reason == .max && p.syndrome == 0 && p.fault_ipa == 0 &&
                p.fault_virtual_address == 0, "untouched exit frame")
        } else if p.exception_reason != 1 {
            try nativeRequire(p.syndrome == 0 && p.fault_ipa == 0 && p.fault_virtual_address == 0, "non-exception exit payload")
        }
        let pcRead = source ? p.register_read_calls >= 33 : p.register_read_calls >= 37
        let pcSucceeded = pcRead && (p.register_read_calls > (source ? 33 : 37) || p.read_register_status == 0)
        let x4Succeeded = p.register_read_calls == (source ? 36 : 38) && p.read_register_status == 0
        try nativeRequire(pcSucceeded || p.pc == 0, "untouched PC")
        try nativeRequire(x4Succeeded || p.x4 == 0, "untouched X4")
        let forwardFailure: Int32?
        if attempted && !vmAttempted { forwardFailure = 3 }
        else if vmAttempted && !vmCreated { forwardFailure = 4 }
        else if p.map_status.contains(where: { $0 != absent && $0 != 0 }) { forwardFailure = 5 }
        else if p.vcpu_create_status != absent && (!vcpuCreated || p.register_set_calls == 0) { forwardFailure = 6 }
        else if p.register_set_calls > 0 && p.register_status != 0 { forwardFailure = 7 }
        else if !source && p.register_read_calls > 0 && p.register_read_calls <= 36 && p.read_register_status != 0 { forwardFailure = 10 }
        else if p.run_entries == 1 && p.run_status != 0 { forwardFailure = 9 }
        else if p.register_read_calls > 0 && p.read_register_status != 0 { forwardFailure = 10 }
        else { forwardFailure = nil }
        let forwardError: Int32?
        switch forwardFailure {
        case 4: forwardError = p.vm_create_status
        case 5: forwardError = p.map_status.first { $0 != absent && $0 != 0 }
        case 6: forwardError = vcpuCreated ? 14 : p.vcpu_create_status
        case 7: forwardError = p.register_status
        case 9: forwardError = p.run_status
        case 10: forwardError = p.read_register_status
        default: forwardError = nil // errno from mmap/mprotect is not a phase field.
        }
        let cleanupError: Int32?
        switch cleanupFailure {
        case 14: cleanupError = p.vcpu_destroy_status
        case 15: cleanupError = p.unmap_status.first { $0 != absent && $0 != 0 }
        case 16: cleanupError = p.vm_destroy_status
        default: cleanupError = nil // munmap retains -1, while first_error retains errno.
        }
        return NativePhasePrefix(attempted: attempted, cleanupFailure: cleanupFailure,
            cleanupError: cleanupError, forwardFailure: forwardFailure, forwardError: forwardError)
    }

    private static func validateNativeReachability(_ v: H3QCopiedResult) throws {
        let s = v.source, t = v.target, c = v.checkpoint_diagnostic, d = v.sctlr_transition_diagnostic
        let sp = try nativePhasePrefix(s, source: true), tp = try nativePhasePrefix(t, source: false)
        let absent = Int32.min
        let zero = Data(repeating: 0, count: 32)
        try nativeRequire(v.source_conserved == s.conserved && v.target_conserved == t.conserved, "outer conservation joins")
        let immediate = v.start_ticks == 0
        if immediate {
            try nativeRequire(!sp.attempted && !tp.attempted && s.generation == 0 && t.generation == 0 &&
                v.timebase_numer == 0 && v.signing_admitted == 0 && v.signing_error == absent &&
                v.cancellation_requested == 0 && v.watchdog_create_entries == 0 && v.watchdog_fired == 0 &&
                v.watchdog_wait_status == absent && v.teardown_pass == 0, "immediate claim untouched prefix")
            try nativeRequire((v.outcome == 4 && v.resources_quarantined == 0 && v.failure_stage == 0) ||
                (v.outcome == 5 && v.resources_quarantined == 1 && v.failure_stage == 0) ||
                (v.outcome == 2 && v.resources_quarantined == 0 && v.failure_stage == 1), "immediate claim outcome")
        } else {
            let watchdogClean = v.watchdog_join_entries == 0 || v.watchdog_join_status == 0
            let clean = (!sp.attempted || s.conserved == 1) && (!tp.attempted || t.conserved == 1) && watchdogClean
            try nativeRequire(v.teardown_pass == (clean ? 1 : 0) && v.resources_quarantined == (clean ? 0 : 1), "outer teardown result")
            let pass = v.execution_pass == 1 && clean && s.conserved == 1 && t.conserved == 1 &&
                v.watchdog_create_entries == 2 && v.watchdog_join_entries == 2 && v.failure_stage == 0 && v.cancellation_requested == 0
            try nativeRequire(v.outcome == (pass ? 1 : (v.cancellation_requested == 1 ? 3 : 2)), "final outcome selection")
            try nativeRequire(pass || v.failure_stage != 0, "nonpass first failure")
        }
        if s.generation == 0 || t.generation == 0 {
            try nativeRequire(s.generation == 0 && t.generation == 0 && !sp.attempted && !tp.attempted &&
                v.signing_error == absent && (immediate || v.failure_stage == 1), "generation assignment prefix")
        } else {
            try nativeRequire(!immediate && s.generation & 1 == 1 && s.generation < UInt64.max &&
                t.generation == s.generation + 1, "role generations")
        }
        if v.signing_error == absent {
            try nativeRequire(v.signing_admitted == 0 && v.timebase_numer == 0 && !sp.attempted && !tp.attempted &&
                (immediate || v.failure_stage == 1 || (v.failure_stage == 18 && v.cancellation_requested == 1)), "signing not entered")
        } else {
            try nativeRequire(!immediate && s.generation > 0, "signing call chronology")
            if v.signing_admitted == 0 {
                try nativeRequire(v.timebase_numer == 0 && !sp.attempted && !tp.attempted && v.failure_stage == 1 &&
                    v.first_error == (v.signing_error == 0 ? 13 : v.signing_error), "signing rejection prefix")
            }
        }
        try nativeRequire(v.timebase_numer == 0 || (v.signing_admitted == 1 && s.generation > 0), "timebase signing dependency")
        try nativeRequire(!sp.attempted || (v.timebase_numer > 0 && v.signing_admitted == 1), "source preparation admission")
        try nativeRequire(tp.attempted == (v.cursor_decoded == 1), "target preparation follows decode")
        if !immediate && v.signing_admitted == 1 && !sp.attempted {
            try nativeRequire(v.failure_stage == (v.timebase_numer == 0 ? 2 : 3), "preparation predecessor failure")
        }
        for p in [s, t] {
            if p.entry_ticks > 0 { try nativeRequire(v.timebase_numer > 0 && v.start_ticks <= p.entry_ticks && p.entry_ticks <= v.end_ticks, "entry clock containment") }
            if p.exit_ticks > 0 { try nativeRequire(p.exit_ticks <= v.end_ticks, "exit clock containment") }
        }
        if t.entry_ticks > 0 { try nativeRequire(s.exit_ticks > 0 && s.exit_ticks <= t.entry_ticks, "cross-role clock order") }

        // The pre-read is unconditionally next after the source's last setter.
        let preEntered = s.register_set_calls == 36 && s.register_status == 0
        try nativeRequire((d.schema_version == 1) == preEntered, "SCTLR helper entry")
        if !preEntered {
            try nativeRequire(d.sampled_mask == 0 && d.source_pre_entry_read_entries == 0 && d.source_post_exit_read_entries == 0 &&
                d.source_pre_entry_read_status == 0 && d.source_post_exit_read_status == 0 && d.requested == 0 &&
                d.source_pre_entry == 0 && d.source_post_exit == 0, "untouched SCTLR diagnostic")
        } else {
            try nativeRequire(d.requested == 0x30d0_0980 && d.source_pre_entry_read_entries == 1 &&
                d.source_pre_entry_read_status != absent, "SCTLR pre-read result")
            let preOK = d.source_pre_entry_read_status == 0
            let postEntered = s.register_read_calls > 0
            let postOK = postEntered && d.source_post_exit_read_status == 0
            try nativeRequire(d.source_post_exit_read_entries == (postEntered ? 1 : 0) &&
                (postEntered ? d.source_post_exit_read_status != absent : d.source_post_exit_read_status == absent) &&
                d.sampled_mask == (preOK ? (postOK ? 7 : 3) : 1), "SCTLR mask/call prefix")
            try nativeRequire(preOK || (d.source_pre_entry == 0 && !postEntered && v.watchdog_create_entries == 0 && s.entry_ticks == 0), "failed SCTLR pre-read")
            try nativeRequire(postOK || d.source_post_exit == 0, "unsampled SCTLR post value")
            if s.register_read_calls == 1 { try nativeRequire(s.read_register_status == d.source_post_exit_read_status, "first source read status") }
            if s.register_read_calls > 1 { try nativeRequire(postOK, "source reads after SCTLR failure") }
            if !preOK { try nativeRequire(v.failure_stage == 7 && v.first_error == d.source_pre_entry_read_status, "SCTLR first failure") }
        }
        let sourceWatchdog = v.watchdog_create_entries > 0
        let targetWatchdog = v.watchdog_create_entries == 2
        try nativeRequire(!sourceWatchdog || (preEntered && d.source_pre_entry_read_status == 0), "source watchdog predecessor")
        try nativeRequire(!targetWatchdog || v.cursor_restored == 1, "target watchdog predecessor")
        if s.entry_ticks > 0 || s.run_entries > 0 {
            try nativeRequire(sourceWatchdog && (v.watchdog_create_entries == 2 || v.watchdog_create_status == 0), "source run watchdog")
        }
        if t.entry_ticks > 0 || t.run_entries > 0 {
            try nativeRequire(targetWatchdog && v.watchdog_create_status == 0, "target run watchdog")
        }
        if v.watchdog_wait_status != absent || v.watchdog_fired == 1 {
            try nativeRequire(v.watchdog_join_entries > 0, "watchdog observation without worker")
        }
        if v.watchdog_wait_status != absent && v.watchdog_wait_status != 0 && v.watchdog_wait_status != 60 {
            try nativeRequire(v.cancellation_requested == 1, "failed watchdog wait cancellation")
        }
        if v.cancellation_calls == 1 { try nativeRequire(s.vcpu_create_status == 0 && s.register_set_calls > 0, "cancel call before live vcpu") }
        try nativeRequire(v.cancellation_requested == 0 || v.execution_pass == 0, "cancellation clears execution")

        let sourceComplete = s.run_status == 0 && s.register_read_calls == 36 && s.read_register_status == 0 &&
            (v.watchdog_create_entries == 2 || (v.watchdog_join_entries == 1 && v.watchdog_join_status == 0))
        if c.evaluated_mask == 511 {
            try nativeRequire(sourceComplete && nativeTrap(s, source: true) && d.source_post_exit_read_status == 0 &&
                c.sctlr == d.source_post_exit && c.gprs[4] == s.x4, "checkpoint capture chronology")
        }
        let assessment = H3QReplayNative.nativeDiagnostic(v, error: H3QualificationFailure.malformed("native prefix"))
        try nativeRequire(assessment.checkpointIntegrity != "MALFORMED" && assessment.sctlrTransitionIntegrity != "MALFORMED", "checkpoint/SCTLR witness recomputation")
        if v.checkpoint_valid == 0 {
            try nativeRequire(v.checkpoint_reply == zero && v.cursor_sha256 == zero && v.checkpoint_merkle == zero, "untouched cursor buffers")
        }
        if v.cursor_sealed == 1 {
            try nativeRequire(H3QReplayNative.cursorReconstructs(v), "complete source cursor grammar and digest")
        }
        if v.cursor_restored == 1 {
            try nativeRequire(t.register_read_calls >= 36 && (t.register_read_calls > 36 || t.read_register_status == 0) &&
                t.register_set_calls == 36 && t.register_status == 0, "restore completion")
        }
        try nativeRequire(t.run_entries == 0 || v.cursor_restored == 1, "target run before restore")
        let terminalReadComplete = t.run_status == 0 && t.register_read_calls == 38 && t.read_register_status == 0 &&
            v.watchdog_join_entries == 2 && v.watchdog_join_status == 0
        if !terminalReadComplete { try nativeRequire(v.final_reply == zero && v.terminal_merkle == zero, "untouched terminal buffers") }
        let terminalHashEligible = terminalReadComplete && nativeTrap(t, source: false) && v.final_reply == H3QContract.frame([2, 1, 42, 43])
        if !terminalHashEligible { try nativeRequire(v.terminal_merkle == zero, "terminal root before predicates") }
        if v.terminal_valid == 1 { try nativeRequire(terminalHashEligible, "terminal valid without terminal prefix") }
        for (role, prefix) in [("source", sp), ("target", tp)] {
            if let failure = prefix.forwardFailure {
                try nativeRequire(v.failure_stage == failure, "\(role) first forward failure")
                if let error = prefix.forwardError { try nativeRequire(v.first_error == error, "\(role) first error status") }
            }
        }
        switch v.failure_stage {
        case 1:
            try nativeRequire(!sp.attempted && !tp.attempted && v.signing_admitted == 0 &&
                v.timebase_numer == 0, "admission failure cannot follow preparation")
            if v.signing_error == absent {
                try nativeRequire(s.generation == 0 && [Int32(22), 37, 75].contains(v.first_error), "claim/thread/generation admission failure")
            }
        case 2:
            try nativeRequire(v.terminal_valid == 0 && v.final_reply == zero && v.terminal_merkle == zero, "clock failure precedes terminal copy")
            if v.timebase_numer == 0 {
                try nativeRequire(v.first_error == 22 && !sp.attempted && !tp.attempted, "timebase failure errno")
            } else {
                let targetClock = v.cursor_restored == 1
                let phase = targetClock ? t : s
                let priorWatchdogs: UInt32 = targetClock ? 1 : 0
                try nativeRequire(targetClock || (c.evaluated_mask == 0 && !tp.attempted &&
                    d.schema_version == 1 && d.source_pre_entry_read_status == 0), "role clock predecessor")
                if v.watchdog_create_entries == priorWatchdogs {
                    try nativeRequire(v.first_error == 75 && phase.entry_ticks == 0 && phase.run_entries == 0, "watchdog clock overflow prefix")
                } else {
                    try nativeRequire(v.watchdog_create_entries == priorWatchdogs + 1 && v.watchdog_create_status == 0 &&
                        phase.entry_ticks > 0 && v.first_error == 60 && (phase.run_entries == 0 ||
                        (phase.run_status == 0 && phase.register_read_calls == (targetClock ? 38 : 36) && phase.read_register_status == 0)), "role deadline failure prefix")
                }
            }
        case 3:
            try nativeRequire(v.first_error > 0 && (sp.forwardFailure == 3 || tp.forwardFailure == 3 ||
                (!sp.attempted && !tp.attempted && v.signing_admitted == 1 && v.timebase_numer > 0 && v.first_error == 22)), "private-memory failure prefix")
        case 4, 5, 6:
            try nativeRequire(sp.forwardFailure == v.failure_stage || tp.forwardFailure == v.failure_stage, "claimed setup stage needs failed prefix")
        case 7:
            try nativeRequire(sp.forwardFailure == 7 || tp.forwardFailure == 7 ||
                (d.schema_version == 1 && d.source_pre_entry_read_status != 0), "register failure needs failed call")
        case 8:
            try nativeRequire(v.watchdog_create_entries > 0 && v.watchdog_create_status > 0 &&
                v.first_error == v.watchdog_create_status, "watchdog create failure needs exact failed call")
        case 9:
            try nativeRequire(sp.forwardFailure == 9 || tp.forwardFailure == 9, "run failure needs failed call")
        case 10:
            try nativeRequire(sp.forwardFailure == 10 || tp.forwardFailure == 10, "read failure needs failed call")
        case 11:
            try nativeRequire(sourceComplete && v.checkpoint_valid == 0 && !tp.attempted && v.first_error == 71, "checkpoint rejection prefix")
        case 12:
            // The shared numeric stage_snapshot belongs to the legacy guest
            // snapshot path. The frozen H3 owner never calls h3_fail with it.
            throw H3QualificationFailure.malformed("native prefix: legacy snapshot stage is not entered by H3")
        case 13:
            try nativeRequire(v.watchdog_join_entries > 0 && v.watchdog_join_status > 0 &&
                v.first_error == v.watchdog_join_status, "join failure needs exact failed call")
        case 19:
            try nativeRequire(v.checkpoint_valid == 1 && v.cursor_sealed == 0 && !tp.attempted && v.first_error == 5, "cursor capture failure prefix")
        case 20:
            // h3_conserve_owner can return false only after h3_fail(14...17).
            // h3_fail is first-wins, so the following stage-20 fallback can
            // never become the returned first failure in the frozen C source.
            throw H3QualificationFailure.malformed("native prefix: unreachable first source-conservation fallback")
        case 21:
            try nativeRequire(v.cursor_sealed == 1 && s.conserved == 1 && !tp.attempted && v.first_error == 71, "cursor decode failure prefix")
        case 22:
            try nativeRequire(tp.attempted && t.register_set_calls == 36 && t.register_status == 0 &&
                v.cursor_restored == 0 && t.run_entries == 0 &&
                (t.register_read_calls == 0 || t.read_register_status == 0) && v.first_error == 71, "restore semantic failure prefix")
        case 23:
            try nativeRequire(terminalReadComplete && v.terminal_valid == 0 && v.first_error == 71, "terminal rejection prefix")
        default: break
        }
        if v.failure_stage == 18 { try nativeRequire(v.cancellation_requested == 1 && v.first_error == 89, "cancellation failure without exact request errno") }
        if (14...17).contains(v.failure_stage) {
            let firstCleanup = sp.cleanupFailure == nil ? tp : sp
            try nativeRequire(firstCleanup.cleanupFailure == v.failure_stage, "cleanup failure without first failed call")
            if let error = firstCleanup.cleanupError { try nativeRequire(v.first_error == error, "cleanup first error status") }
            else { try nativeRequire(v.first_error > 0, "host-unmap errno") }
        }
    }
}


private func h3QI32(_ value: H3QualificationJSONValue, _ key: String) throws -> Int32 {
    guard let n = value[key]?.intValue, let result = Int32(exactly:n) else { throw H3QualificationFailure.malformed("i32 \(key)") }; return result
}
private func h3QU32(_ value: H3QualificationJSONValue, _ key: String) throws -> UInt32 {
    guard let n = value[key]?.intValue, let result = UInt32(exactly:n) else { throw H3QualificationFailure.malformed("u32 \(key)") }; return result
}
private func h3QU64(_ value: H3QualificationJSONValue, _ key: String) throws -> UInt64 {
    guard let text = value[key]?.stringValue, let result = UInt64(text), String(result) == text else { throw H3QualificationFailure.malformed("u64 \(key)") }; return result
}
private struct H3QCopiedPhase: Sendable {
    let conserved: UInt32
    let entry_ticks: UInt64
    let exception_reason: UInt64
    let exit_ticks: UInt64
    let fault_ipa: UInt64
    let fault_virtual_address: UInt64
    let generation: UInt64
    let host_unmap_status: [Int32]
    let map_status: [Int32]
    let mappings_entered: UInt32
    let pc: UInt64
    let read_register_status: Int32
    let register_read_calls: UInt32
    let register_set_calls: UInt32
    let register_status: Int32
    let run_entries: UInt32
    let run_status: Int32
    let syndrome: UInt64
    let unmap_status: [Int32]
    let vcpu_create_status: Int32
    let vcpu_destroy_status: Int32
    let vm_create_status: Int32
    let vm_destroy_status: Int32
    let x4: UInt64
    init(wire: H3QualificationJSONValue) throws {
        try H3QualificationWire.validateStructure(wire, schema:"native_phase")
        conserved = try h3QU32(wire, "conserved")
        entry_ticks = try h3QU64(wire, "entry_ticks")
        exception_reason = try h3QU64(wire, "exception_reason")
        exit_ticks = try h3QU64(wire, "exit_ticks")
        fault_ipa = try h3QU64(wire, "fault_ipa")
        fault_virtual_address = try h3QU64(wire, "fault_virtual_address")
        generation = try h3QU64(wire, "generation")
        host_unmap_status = try wire.required("host_unmap_statuses").arrayValue!.map { guard let n = $0.intValue, let v = Int32(exactly:n) else { throw H3QualificationFailure.malformed("i32 array") }; return v }
        map_status = try wire.required("map_statuses").arrayValue!.map { guard let n = $0.intValue, let v = Int32(exactly:n) else { throw H3QualificationFailure.malformed("i32 array") }; return v }
        mappings_entered = try h3QU32(wire, "mappings_entered")
        pc = try h3QU64(wire, "pc")
        read_register_status = try h3QI32(wire, "read_register_status")
        register_read_calls = try h3QU32(wire, "register_read_calls")
        register_set_calls = try h3QU32(wire, "register_set_calls")
        register_status = try h3QI32(wire, "register_status")
        run_entries = try h3QU32(wire, "run_entries")
        run_status = try h3QI32(wire, "run_status")
        syndrome = try h3QU64(wire, "syndrome")
        unmap_status = try wire.required("unmap_statuses").arrayValue!.map { guard let n = $0.intValue, let v = Int32(exactly:n) else { throw H3QualificationFailure.malformed("i32 array") }; return v }
        vcpu_create_status = try h3QI32(wire, "vcpu_create_status")
        vcpu_destroy_status = try h3QI32(wire, "vcpu_destroy_status")
        vm_create_status = try h3QI32(wire, "vm_create_status")
        vm_destroy_status = try h3QI32(wire, "vm_destroy_status")
        x4 = try h3QU64(wire, "x4")
    }
}
private struct H3QCopiedPage: Sendable {
    let expected_byte: UInt8
    let first_mismatch_offset: UInt32
    let observed_byte: UInt8
    let reserved_zero: UInt16
    let role: String
    init(wire: H3QualificationJSONValue) throws {
        try H3QualificationWire.validateStructure(wire, schema:"native_checkpoint_page")
        expected_byte = UInt8(try h3QU32(wire, "expected_byte"))
        first_mismatch_offset = try h3QU32(wire, "first_mismatch_offset")
        observed_byte = UInt8(try h3QU32(wire, "observed_byte"))
        reserved_zero = UInt16(try h3QU32(wire, "reserved_zero"))
        role = try wire.required("role").stringValue!
    }
}
private struct H3QCopiedCheckpoint: Sendable {
    let checkpoint_sequence: UInt64
    let cpsr: UInt64
    let evaluated_mask: UInt32
    let gpr_mismatch_mask: UInt32
    let gprs: [UInt64]
    let page_witnesses: [H3QCopiedPage]
    let passed_mask: UInt32
    let required_mask: UInt32
    let reserved_zero: UInt32
    let schema_version: UInt32
    let sctlr: UInt64
    let sp: UInt64
    let vbar: UInt64
    init(wire: H3QualificationJSONValue) throws {
        try H3QualificationWire.validateStructure(wire, schema:"native_checkpoint")
        checkpoint_sequence = try h3QU64(wire, "checkpoint_sequence")
        cpsr = try h3QU64(wire, "cpsr")
        evaluated_mask = try h3QU32(wire, "evaluated_mask")
        gpr_mismatch_mask = try h3QU32(wire, "gpr_mismatch_mask")
        gprs = try wire.required("gprs").arrayValue!.map { guard let n = $0.stringValue, let v = UInt64(n) else { throw H3QualificationFailure.malformed("u64 array") }; return v }
        page_witnesses = try wire.required("pages").arrayValue!.map { try H3QCopiedPage(wire:$0) }
        passed_mask = try h3QU32(wire, "passed_mask")
        required_mask = try h3QU32(wire, "required_mask")
        reserved_zero = try h3QU32(wire, "reserved_zero")
        schema_version = try h3QU32(wire, "schema_version")
        sctlr = try h3QU64(wire, "sctlr")
        sp = try h3QU64(wire, "sp")
        vbar = try h3QU64(wire, "vbar")
    }
}
private struct H3QCopiedTransition: Sendable {
    let requested: UInt64
    let reserved_zero_0: UInt32
    let reserved_zero_1: UInt32
    let sampled_mask: UInt32
    let schema_version: UInt32
    let source_post_exit: UInt64
    let source_post_exit_read_entries: UInt32
    let source_post_exit_read_status: Int32
    let source_pre_entry: UInt64
    let source_pre_entry_read_entries: UInt32
    let source_pre_entry_read_status: Int32
    init(wire: H3QualificationJSONValue) throws {
        try H3QualificationWire.validateStructure(wire, schema:"native_sctlr_transition")
        requested = try h3QU64(wire, "requested")
        reserved_zero_0 = try h3QU32(wire, "reserved_zero_0")
        reserved_zero_1 = try h3QU32(wire, "reserved_zero_1")
        sampled_mask = try h3QU32(wire, "sampled_mask")
        schema_version = try h3QU32(wire, "schema_version")
        source_post_exit = try h3QU64(wire, "source_post_exit")
        source_post_exit_read_entries = try h3QU32(wire, "source_post_exit_read_entries")
        source_post_exit_read_status = try h3QI32(wire, "source_post_exit_read_status")
        source_pre_entry = try h3QU64(wire, "source_pre_entry")
        source_pre_entry_read_entries = try h3QU32(wire, "source_pre_entry_read_entries")
        source_pre_entry_read_status = try h3QI32(wire, "source_pre_entry_read_status")
    }
}
private struct H3QCopiedEvidence: Sendable { let byte_count: UInt32; var bytes: Data }
private struct H3QCopiedResult: Sendable {
    let abi_version: UInt32
    let cancellation_calls: UInt32
    let cancellation_requested: UInt32
    let cancellation_status: Int32
    let checkpoint_valid: UInt32
    let cursor_decoded: UInt32
    let cursor_evidence_byte_count: UInt32
    let cursor_restored: UInt32
    let cursor_sealed: UInt32
    let end_ticks: UInt64
    let execution_pass: UInt32
    let failure_stage: Int32
    let first_error: Int32
    let outcome: UInt32
    let resources_quarantined: UInt32
    let signing_admitted: UInt32
    let signing_error: Int32
    let source_conserved: UInt32
    let start_ticks: UInt64
    let target_conserved: UInt32
    let teardown_pass: UInt32
    let terminal_valid: UInt32
    let timebase_denom: UInt32
    let timebase_numer: UInt32
    let watchdog_create_entries: UInt32
    let watchdog_create_status: Int32
    let watchdog_fired: UInt32
    let watchdog_join_entries: UInt32
    let watchdog_join_status: Int32
    let watchdog_wait_status: Int32
    let source: H3QCopiedPhase
    let target: H3QCopiedPhase
    let checkpoint_diagnostic: H3QCopiedCheckpoint
    let sctlr_transition_diagnostic: H3QCopiedTransition
    var cursor_evidence: H3QCopiedEvidence
    var cursor_sha256: Data
    var checkpoint_reply: Data
    var final_reply: Data
    var checkpoint_merkle: Data
    var terminal_merkle: Data
    init(capture: H3QualificationNativeCapture) throws {
        let native = capture.wire
        let wire = try native.required("outer")
        source = try H3QCopiedPhase(wire: native.required("source"))
        target = try H3QCopiedPhase(wire: native.required("target"))
        checkpoint_diagnostic = try H3QCopiedCheckpoint(wire: native.required("checkpoint"))
        sctlr_transition_diagnostic = try H3QCopiedTransition(wire: native.required("sctlr_transition"))
        cursor_evidence = H3QCopiedEvidence(byte_count: try h3QU32(wire, "cursor_evidence_byte_count"),
            bytes: try H3QualificationProtocol.unhex(native.required("cursor_evidence_hex").stringValue!, bytes:680))
        cursor_sha256 = try H3QualificationProtocol.unhex(native.required("cursor_sha256").stringValue!, bytes:32)
        checkpoint_reply = try H3QualificationProtocol.unhex(native.required("checkpoint_reply_hex").stringValue!, bytes:32)
        final_reply = try H3QualificationProtocol.unhex(native.required("final_reply_hex").stringValue!, bytes:32)
        checkpoint_merkle = try H3QualificationProtocol.unhex(native.required("checkpoint_merkle_hex").stringValue!, bytes:32)
        terminal_merkle = try H3QualificationProtocol.unhex(native.required("terminal_merkle_hex").stringValue!, bytes:32)
        try H3QualificationWire.validateStructure(wire, schema:"native_outer")
        abi_version = try h3QU32(wire, "abi_version")
        cancellation_calls = try h3QU32(wire, "cancellation_calls")
        cancellation_requested = try h3QU32(wire, "cancellation_requested")
        cancellation_status = try h3QI32(wire, "cancellation_status")
        checkpoint_valid = try h3QU32(wire, "checkpoint_valid")
        cursor_decoded = try h3QU32(wire, "cursor_decoded")
        cursor_evidence_byte_count = try h3QU32(wire, "cursor_evidence_byte_count")
        cursor_restored = try h3QU32(wire, "cursor_restored")
        cursor_sealed = try h3QU32(wire, "cursor_sealed")
        end_ticks = try h3QU64(wire, "end_ticks")
        execution_pass = try h3QU32(wire, "execution_pass")
        failure_stage = try h3QI32(wire, "failure_stage")
        first_error = try h3QI32(wire, "first_error")
        outcome = try h3QU32(wire, "outcome")
        resources_quarantined = try h3QU32(wire, "resources_quarantined")
        signing_admitted = try h3QU32(wire, "signing_admitted")
        signing_error = try h3QI32(wire, "signing_error")
        source_conserved = try h3QU32(wire, "source_conserved")
        start_ticks = try h3QU64(wire, "start_ticks")
        target_conserved = try h3QU32(wire, "target_conserved")
        teardown_pass = try h3QU32(wire, "teardown_pass")
        terminal_valid = try h3QU32(wire, "terminal_valid")
        timebase_denom = try h3QU32(wire, "timebase_denom")
        timebase_numer = try h3QU32(wire, "timebase_numer")
        watchdog_create_entries = try h3QU32(wire, "watchdog_create_entries")
        watchdog_create_status = try h3QI32(wire, "watchdog_create_status")
        watchdog_fired = try h3QU32(wire, "watchdog_fired")
        watchdog_join_entries = try h3QU32(wire, "watchdog_join_entries")
        watchdog_join_status = try h3QI32(wire, "watchdog_join_status")
        watchdog_wait_status = try h3QI32(wire, "watchdog_wait_status")
    }
}


private struct H3QReplayCheckpointPageWitness: Equatable, Sendable {
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
private struct H3QReplayCheckpointPredicateDiagnostic: Equatable, Sendable {
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
    let pages: [H3QReplayCheckpointPageWitness]

    fileprivate init(_ value: H3QCopiedCheckpoint) {
        schemaVersion = value.schema_version
        requiredMask = value.required_mask
        evaluatedMask = value.evaluated_mask
        passedMask = value.passed_mask
        gprMismatchMask = value.gpr_mismatch_mask
        reservedZero = value.reserved_zero
        checkpointSequence = value.checkpoint_sequence
        gprs = value.gprs
        cpsr = value.cpsr
        sctlr = value.sctlr
        sp = value.sp
        vbar = value.vbar
        pages = [
            Self.page(value.page_witnesses[0], role: "code"),
            Self.page(value.page_witnesses[1], role: "request"),
            Self.page(value.page_witnesses[2], role: "reply"),
        ]
    }

    private static func page(_ value: H3QCopiedPage,
                             role: String) -> H3QReplayCheckpointPageWitness {
        H3QReplayCheckpointPageWitness(role: role,
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
private struct H3QReplaySCTLRTransitionDiagnostic: Equatable, Sendable {
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

    fileprivate init(_ value: H3QCopiedTransition) {
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

private struct H3QReplayNativePhaseDiagnostic: Equatable, Sendable {
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

    fileprivate init(_ value: H3QCopiedPhase) {
        generation = value.generation
        runEntries = value.run_entries
        mappingsEntered = value.mappings_entered
        registerSetCalls = value.register_set_calls
        registerReadCalls = value.register_read_calls
        conserved = value.conserved
        vmCreateStatus = value.vm_create_status
        mapStatuses = [value.map_status[0], value.map_status[1], value.map_status[2]]
        vcpuCreateStatus = value.vcpu_create_status
        registerStatus = value.register_status
        runStatus = value.run_status
        readRegisterStatus = value.read_register_status
        vcpuDestroyStatus = value.vcpu_destroy_status
        unmapStatuses = [value.unmap_status[0], value.unmap_status[1], value.unmap_status[2]]
        vmDestroyStatus = value.vm_destroy_status
        hostUnmapStatuses = [value.host_unmap_status[0], value.host_unmap_status[1],
                             value.host_unmap_status[2]]
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
private struct H3QReplayNativeDiagnostic: Equatable, Sendable {
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
    let source: H3QReplayNativePhaseDiagnostic
    let target: H3QReplayNativePhaseDiagnostic
    let checkpoint: H3QReplayCheckpointPredicateDiagnostic
    let sctlrTransition: H3QReplaySCTLRTransitionDiagnostic
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

private struct H3QReplayPresentation: Sendable {
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
    let nativeDiagnostic: H3QReplayNativeDiagnostic?
}

/// Immutable in-memory projections only. These bytes describe a verified
/// result; they contain no reservation, VM handle, replay token, path or write
/// destination and cannot recreate any live capability.
private struct H3QReplayLiveProjectionReceipt: Equatable, Sendable {
    let state: H3QProjection
    let graph: H3QProjection
    let root: String
}

/// Internal (and therefore @testable) pure-verification seam: it accepts only
/// a copied value result, never the reservation or any live VM capability.
/// Product-side reconstruction of the native H3 result. Native PASS is only an
/// input: Swift independently decodes the fixed cursor, reconstructs all three
/// admitted pages and both Merkle trees, then rejoins the two conserved VM
/// intervals. No projection here is written or accepted as a capability.
private enum H3QReplayNative {
    static let fixedImage = try! H3QualificationProtocol.unhex("000088d20000a2f2010090d20100a2f2030098d20300a2f204fcdfc89f0400f121030054050440f9bf0400f1c1020054060840f9070c40f9c600078b250400f9260800f93f0c00f924fc9fc89f3f03d5640000b9dfa800f161010054280840f91fa900f10101005408050091280c00f9440080d224fc9fc89f3f03d5640000b9a0d53bd4a07521d4", bytes: 136)
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
        let source: H3QCopiedPhase
        let target: H3QCopiedPhase
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
                throw H3QReplayFailure("H3 cursor frame is truncated")
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
                throw H3QReplayFailure("H3 cursor frame has trailing bytes")
            }
        }
    }

    private static func require(_ predicate: @autoclosure () throws -> Bool, _ message: String) throws {
        guard try predicate() else { throw H3QReplayFailure(message) }
    }

    private static func checkpointTrapFailures(_ source: H3QReplayNativePhaseDiagnostic) -> [String] {
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
        let image = fixedImage
        guard H3QContract.hash(image) == imageSHA256,
              let imagePage = try? page(prefix: image),
              let requestPage = try? page(prefix: H3QContract.request),
              let replyPage = try? page(prefix: H3QContract.frame([1, 1, 42, 0])) else {
            return nil
        }
        return [imagePage, requestPage, replyPage]
    }

    private static func checkpointAssessment(
        _ checkpoint: H3QReplayCheckpointPredicateDiagnostic,
        source: H3QReplayNativePhaseDiagnostic,
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
        _ transition: H3QReplaySCTLRTransitionDiagnostic,
        checkpoint: H3QReplayCheckpointPredicateDiagnostic,
        source: H3QReplayNativePhaseDiagnostic,
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
                (outcome == UInt32(4) ||
                 outcome == UInt32(5))
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

        if outcome == UInt32(4) ||
            outcome == UInt32(5) {
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
        if failureStage == 0 && outcome != UInt32(1) {
            reject("stage_zero_outcome")
        }
        if outcome == UInt32(1) && failureStage != 0 {
            reject("pass_with_failure_stage")
        }
        if outcome == UInt32(1) &&
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

    private static func tupleBytes(_ bytes: inout Data, count: Int) throws -> Data {
        try require(bytes.count == count, "H3 imported fixed-array width changed")
        return bytes
    }

    private static func page(prefix: Data) throws -> Data {
        try require(prefix.count <= pageBytes, "H3 page prefix exceeds its fixed page")
        var result = Data(repeating: 0, count: pageBytes)
        result.replaceSubrange(0..<prefix.count, with: prefix)
        return result
    }

    private static func phase(_ value: H3QCopiedPhase, pc: UInt64,
                              x4: UInt64, registerReads: UInt32, label: String) throws {
        try require(value.run_entries == 1 && value.mappings_entered == 3 &&
            value.register_set_calls == 36 && value.register_read_calls == registerReads &&
            value.conserved == 1, "H3 \(label) entry/conservation counters rejected")
        try require(value.vm_create_status == 0 && value.map_status[0] == 0 &&
            value.map_status[1] == 0 && value.map_status[2] == 0 &&
            value.vcpu_create_status == 0 && value.register_status == 0 &&
            value.run_status == 0 && value.read_register_status == 0 &&
            value.vcpu_destroy_status == 0 && value.unmap_status[0] == 0 &&
            value.unmap_status[1] == 0 && value.unmap_status[2] == 0 &&
            value.vm_destroy_status == 0 && value.host_unmap_status[0] == 0 &&
            value.host_unmap_status[1] == 0 && value.host_unmap_status[2] == 0,
            "H3 \(label) native status rejected")
        let dfsc = value.syndrome & 63
        try require(value.generation > 0 && value.entry_ticks > 0 &&
            value.entry_ticks <= value.exit_ticks && value.exception_reason == 1 &&
            (4...7).contains(dfsc) && value.syndrome == (0x9384_0040 | dfsc) &&
            value.pc == pc && value.fault_ipa == 0x1000_c000 &&
            value.fault_virtual_address == 0x1000_c000 && value.x4 == x4,
            "H3 \(label) exit frame rejected")
    }

    private static func phaseSemantic(_ phase: H3QCopiedPhase) -> H3QCBORValue {
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
                "host_unmap": .array([phase.host_unmap_status[0], phase.host_unmap_status[1],
                                      phase.host_unmap_status[2]].map { .text(String($0)) }),
                "map": .array([phase.map_status[0], phase.map_status[1],
                                phase.map_status[2]].map { .text(String($0)) }),
                "read_register": .text(String(phase.read_register_status)),
                "register": .text(String(phase.register_status)),
                "run": .text(String(phase.run_status)),
                "unmap": .array([phase.unmap_status[0], phase.unmap_status[1],
                                  phase.unmap_status[2]].map { .text(String($0)) }),
                "vcpu_create": .text(String(phase.vcpu_create_status)),
                "vcpu_destroy": .text(String(phase.vcpu_destroy_status)),
                "vm_create": .text(String(phase.vm_create_status)),
                "vm_destroy": .text(String(phase.vm_destroy_status)),
            ]),
            "syndrome": .text(String(phase.syndrome)),
            "x4": .text(String(phase.x4)),
        ])
    }

    private static func stateSemantic(_ binding: LiveBinding) -> H3QCBORValue {
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
                                           binding: LiveBinding) -> H3QCBORValue {
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

    private static func projectionLeaves(_ projection: H3QProjection,
                                         schema: String, role: String) -> [H3QLeaf] {
        [H3QLeaf(label: "schema", payload: Data(schema.utf8)),
         H3QLeaf(label: "\(role).json", payload: projection.json),
         H3QLeaf(label: "\(role).cbor", payload: projection.cbor)]
    }

    private static func project(_ semantic: H3QCBORValue, schema: String,
                                role: String) throws -> H3QProjection {
        let json = try H3QStageJSON.encode(semantic)
        let cbor = try H3QCBOR.encode(semantic)
        try require(!json.isEmpty && !cbor.isEmpty && json.count <= maximumProjectionBytes &&
            cbor.count <= maximumProjectionBytes, "H3 live projection exceeds its bound")
        let partial = H3QProjection(json: json, cbor: cbor, root: "")
        let projection = H3QProjection(json: json, cbor: cbor,
            root: try H3QMerkle.commit(projectionLeaves(partial, schema: schema, role: role)).root)
        try require(try verifyProjection(projection, schema: schema, role: role) == semantic,
            "H3 live projection self-verification rejected")
        return projection
    }

    private static func verifyProjection(_ projection: H3QProjection,
                                         schema: String, role: String) throws -> H3QCBORValue {
        try require(!projection.json.isEmpty && !projection.cbor.isEmpty &&
            projection.json.count <= maximumProjectionBytes &&
            projection.cbor.count <= maximumProjectionBytes,
            "H3 live projection is outside its bound")
        let fromJSON = try H3QStageJSON.decode(projection.json)
        let fromCBOR = try H3QCBOR.decode(projection.cbor)
        let canonicalJSON = try H3QStageJSON.encode(fromJSON)
        let canonicalCBOR = try H3QCBOR.encode(fromCBOR)
        try require(fromJSON == fromCBOR && canonicalJSON == projection.json &&
            canonicalCBOR == projection.cbor,
            "H3 live JSON/CBOR round-trip join rejected")
        guard case .map(let values) = fromJSON else {
            throw H3QReplayFailure("H3 live projection must be a map")
        }
        try require(values["schema"] == .text(schema) &&
            H3QMerkle.verify(projectionLeaves(projection, schema: schema, role: role),
                                 expectedRoot: projection.root),
            "H3 live projection root rejected")
        return fromJSON
    }

    private static func contentRoot(_ semantic: H3QCBORValue,
                                    schema: String, role: String) throws -> String {
        try project(semantic, schema: schema, role: role).root
    }

    private static func graphSemantic(stateRoot: String,
                                      binding: LiveBinding) throws -> H3QCBORValue {
        func node(_ id: String, _ partition: String, _ type: String,
                  _ schema: String, _ root: String) -> H3QCBORValue {
            .map(["content_root": .text(root), "content_schema": .text(schema),
                  "id": .text(id), "node_type": .text(type),
                  "partition": .text(partition)])
        }
        func edge(_ from: String, _ to: String, _ position: Int,
                  _ relation: String) -> H3QCBORValue {
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
        let stateNodes: [H3QCBORValue] = [
            node("static-readiness-receipt", "state", "static-readiness-receipt",
                 H3QReadinessCursor.receiptSchema, binding.readinessReceiptRoot),
            node("static-readiness-graph", "state", "static-readiness-graph",
                 H3QReadinessCursor.graphSchema, binding.readinessGraphRoot),
            node("static-readiness-cursor", "state", "static-readiness-cursor",
                 H3QReadinessCursor.cursorSchema, binding.readinessCursorRoot),
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

    private static func receiptLeaves(_ receipt: H3QReplayLiveProjectionReceipt,
                                      binding: LiveBinding) -> [H3QLeaf] {
        [H3QLeaf(label: "schema", payload: Data(liveReceiptSchema.utf8)),
         H3QLeaf(label: "graph.json", payload: receipt.graph.json),
         H3QLeaf(label: "graph.cbor", payload: receipt.graph.cbor),
         H3QLeaf(label: "state.json", payload: receipt.state.json),
         H3QLeaf(label: "state.cbor", payload: receipt.state.cbor),
         H3QLeaf(label: "readiness_receipt_root", payload: Data(binding.readinessReceiptRoot.utf8)),
         H3QLeaf(label: "readiness_graph_root", payload: Data(binding.readinessGraphRoot.utf8)),
         H3QLeaf(label: "cursor_digest", payload: Data(binding.cursorDigest.utf8)),
         H3QLeaf(label: "checkpoint_root", payload: Data(binding.checkpointRoot.utf8)),
         H3QLeaf(label: "terminal_root", payload: Data(binding.terminalRoot.utf8))]
    }

    private static func makeLiveReceipt(_ binding: LiveBinding) throws -> H3QReplayLiveProjectionReceipt {
        let state = try project(stateSemantic(binding), schema: liveStateSchema, role: "state")
        let graph = try project(try graphSemantic(stateRoot: state.root, binding: binding),
                                schema: liveGraphSchema, role: "graph")
        let partial = H3QReplayLiveProjectionReceipt(state: state, graph: graph, root: "")
        let receipt = H3QReplayLiveProjectionReceipt(state: state, graph: graph,
            root: try H3QMerkle.commit(receiptLeaves(partial, binding: binding)).root)
        try verifyLiveReceipt(receipt, binding: binding)
        return receipt
    }

    private static func verifyBipartiteGraph(_ semantic: H3QCBORValue) throws {
        guard case .map(let graph) = semantic,
              graph["bipartite"] == .bool(true),
              graph["bipartite_rule"] == .text("STATE_TO_TRANSITION_OR_TRANSITION_TO_STATE_ONLY"),
              case .array(let nodes) = graph["nodes"],
              case .array(let edges) = graph["edges"],
              graph["node_count"] == .text(String(nodes.count)),
              graph["edge_count"] == .text(String(edges.count)) else {
            throw H3QReplayFailure("H3 live graph inventory rejected")
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
                throw H3QReplayFailure("H3 live graph node rejected")
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
                throw H3QReplayFailure("H3 live graph edge violates bipartition")
            }
        }
    }

    private static func verifyLiveReceipt(_ receipt: H3QReplayLiveProjectionReceipt,
                                          binding: LiveBinding) throws {
        let state = try verifyProjection(receipt.state, schema: liveStateSchema, role: "state")
        try require(state == stateSemantic(binding), "H3 live state projection is not exact")
        let graph = try verifyProjection(receipt.graph, schema: liveGraphSchema, role: "graph")
        try verifyBipartiteGraph(graph)
        try require(graph == graphSemantic(stateRoot: receipt.state.root, binding: binding),
            "H3 live bipartite graph is not exact")
        try require(try H3QMerkle.verify(receiptLeaves(receipt, binding: binding),
                                             expectedRoot: receipt.root),
            "H3 live receipt root rejected")
    }

    private static func binding(_ value: H3QCopiedResult,
                                readiness: H3QReadinessVerifiedResult,
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
    static func projectionForTesting(_ returned: H3QCopiedResult) throws
        -> H3QReplayLiveProjectionReceipt {
        let readinessReceipt = try H3QReadinessCursor.runContract()
        let readiness = try H3QReadinessCursor.verifyContract(readinessReceipt)
        var value = returned
        let cursorDigest = try tupleBytes(&value.cursor_sha256, count: 32)
        let checkpointRoot = try tupleBytes(&value.checkpoint_merkle, count: 32)
        let terminalRoot = try tupleBytes(&value.terminal_merkle, count: 32)
        return try makeLiveReceipt(binding(value, readiness: readiness,
            cursorDigest: cursorDigest, checkpointRoot: checkpointRoot,
            terminalRoot: terminalRoot))
    }

    /// Independently reconstructs an inert receipt against a copied result.
    /// It cannot turn a projection into an execution or persistence authority.
    static func verifyProjectionForTesting(_ receipt: H3QReplayLiveProjectionReceipt,
                                           native returned: H3QCopiedResult) throws {
        let readinessReceipt = try H3QReadinessCursor.runContract()
        let readiness = try H3QReadinessCursor.verifyContract(readinessReceipt)
        var value = returned
        let cursorDigest = try tupleBytes(&value.cursor_sha256, count: 32)
        let checkpointRoot = try tupleBytes(&value.checkpoint_merkle, count: 32)
        let terminalRoot = try tupleBytes(&value.terminal_merkle, count: 32)
        try verifyLiveReceipt(receipt, binding: binding(value, readiness: readiness,
            cursorDigest: cursorDigest, checkpointRoot: checkpointRoot,
            terminalRoot: terminalRoot))
    }

    static func verify(_ returned: H3QCopiedResult) throws -> H3QReplayPresentation {
        // This independent, effect-free contract can reject a product/schema
        // mismatch, but it cannot grant live authority or H3 completion.
        let readinessReceipt = try H3QReadinessCursor.runContract()
        let readiness = try H3QReadinessCursor.verifyContract(readinessReceipt)
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
             value.watchdog_wait_status == 60),
            "H3 outer native statuses rejected")
        try require(value.start_ticks > 0 && value.start_ticks <= value.source.entry_ticks &&
            value.source.exit_ticks <= value.target.entry_ticks &&
            value.target.exit_ticks <= value.end_ticks && value.timebase_numer > 0 &&
            value.timebase_denom > 0, "H3 two-interval clock order rejected")
        try phase(value.source, pc: 0x1000_0050, x4: 1, registerReads: 36,
                  label: "checkpoint")
        try phase(value.target, pc: 0x1000_007c, x4: 2, registerReads: 38,
                  label: "terminal")
        let checkpoint = H3QReplayCheckpointPredicateDiagnostic(value.checkpoint_diagnostic)
        let sctlrTransition = H3QReplaySCTLRTransitionDiagnostic(
            value.sctlr_transition_diagnostic)
        let sourceDiagnostic = H3QReplayNativePhaseDiagnostic(value.source)
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

        let image = fixedImage
        try require(image.count == imageBytes, "H3 fixed image metadata rejected")
        try require(H3QContract.hash(image) == imageSHA256, "H3 fixed image digest rejected")

        try require(value.cursor_evidence.byte_count == UInt32(cursorBytes),
            "H3 cursor evidence length rejected")
        let evidence = try tupleBytes(&value.cursor_evidence.bytes, count: cursorBytes)
        let cursorDigest = try tupleBytes(&value.cursor_sha256, count: 32)
        let checkpointReply = try tupleBytes(&value.checkpoint_reply, count: 32)
        let terminalReply = try tupleBytes(&value.final_reply, count: 32)
        let checkpointRoot = try tupleBytes(&value.checkpoint_merkle, count: 32)
        let terminalRoot = try tupleBytes(&value.terminal_merkle, count: 32)
        try require(checkpointReply == H3QContract.frame([1, 1, 42, 0]) &&
            terminalReply == H3QContract.frame([2, 1, 42, 43]),
            "H3 fixed reply frames rejected")

        let imagePage = try page(prefix: image)
        let requestPage = try page(prefix: H3QContract.request)
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
        try require(evidenceImageHash.hex == H3QContract.hash(imagePage) &&
            evidenceRequestHash.hex == H3QContract.hash(requestPage) &&
            evidenceReplyHash.hex == H3QContract.hash(checkpointPage),
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
            H3QContract.hash(internalCursor) == cursorDigest.hex &&
            evidenceDigest == cursorDigest,
            "H3 full internal cursor digest reconstruction rejected")

        let checkpointLeaves = [
            H3QLeaf(label: "cursor_digest", payload: cursorDigest),
            H3QLeaf(label: "guest_image", payload: image),
            H3QLeaf(label: "reply", payload: checkpointReply),
            H3QLeaf(label: "request", payload: H3QContract.request),
            H3QLeaf(label: "schema", payload: Data(checkpointSchema.utf8)),
        ]
        let terminalLeaves = [
            H3QLeaf(label: "checkpoint_reply", payload: checkpointReply),
            H3QLeaf(label: "cursor_digest", payload: cursorDigest),
            H3QLeaf(label: "final_reply", payload: terminalReply),
            H3QLeaf(label: "guest_image", payload: image),
            H3QLeaf(label: "request", payload: H3QContract.request),
            H3QLeaf(label: "schema", payload: Data(terminalSchema.utf8)),
        ]
        try require(try H3QMerkle.verify(checkpointLeaves, expectedRoot: checkpointRoot.hex),
            "H3 checkpoint Merkle reconstruction rejected")
        try require(try H3QMerkle.verify(terminalLeaves, expectedRoot: terminalRoot.hex),
            "H3 terminal Merkle reconstruction rejected")

        let liveBinding = binding(value, readiness: readiness,
            cursorDigest: cursorDigest, checkpointRoot: checkpointRoot,
            terminalRoot: terminalRoot)
        let liveReceipt = try makeLiveReceipt(liveBinding)
        // Verify a second time from only the immutable bytes and expected
        // copied facts before any presentation value can be returned.
        try verifyLiveReceipt(liveReceipt, binding: liveBinding)

        return H3QReplayPresentation(status: "PASS", verificationDisposition: "VERIFIED_PASS",
            detail: "Swift independently reconstructed the immutable checkpoint cursor at 42; the same reserved lifetime consumed it into one fresh VM/vCPU interval, reached 43, and conserved both intervals. No journal or durable receipt was opened.",
            cursorSHA256: cursorDigest.hex, checkpointRoot: checkpointRoot.hex,
            terminalRoot: terminalRoot.hex,
            elapsed: "\(value.end_ticks - value.start_ticks) ticks × \(value.timebase_numer)/\(value.timebase_denom) ns",
            sourceGeneration: value.source.generation, targetGeneration: value.target.generation,
            sourceRunEntries: value.source.run_entries, targetRunEntries: value.target.run_entries,
            gateE: "ABSTAIN", authorityVector: "00000000", quarantined: false,
            projectionRoot: liveReceipt.root, graphRoot: liveReceipt.graph.root,
            durable: false, h4Entered: false, nativeDiagnostic: nil)
    }

fileprivate static func semanticConditions(_ input: H3QCopiedResult,
                                              presentation: H3QualificationPresentation) throws -> [String: Bool] {
        var value = input
        let source = value.source, target = value.target
        let checkpoint = H3QReplayCheckpointPredicateDiagnostic(value.checkpoint_diagnostic)
        let checkpointResult = checkpointAssessment(checkpoint,
            source: H3QReplayNativePhaseDiagnostic(source),
            checkpointValid: value.checkpoint_valid, failureStage: value.failure_stage)
        let transition = sctlrTransitionAssessment(H3QReplaySCTLRTransitionDiagnostic(value.sctlr_transition_diagnostic),
            checkpoint: checkpoint, source: H3QReplayNativePhaseDiagnostic(source),
            failureStage: value.failure_stage, outcome: value.outcome)
        let readiness = try H3QReadinessCursor.verifyContract(H3QReadinessCursor.runContract())
        let cursor = try tupleBytes(&value.cursor_sha256, count: 32)
        let cp = try tupleBytes(&value.checkpoint_reply, count: 32)
        let terminal = try tupleBytes(&value.final_reply, count: 32)
        let cpRoot = try tupleBytes(&value.checkpoint_merkle, count: 32)
        let terminalRoot = try tupleBytes(&value.terminal_merkle, count: 32)
        let leaves = [
            H3QLeaf(label:"cursor_digest",payload:cursor), H3QLeaf(label:"guest_image",payload:fixedImage),
            H3QLeaf(label:"reply",payload:cp), H3QLeaf(label:"request",payload:H3QContract.request),
            H3QLeaf(label:"schema",payload:Data(checkpointSchema.utf8))
        ]
        let terminalLeaves = [
            H3QLeaf(label:"checkpoint_reply",payload:cp), H3QLeaf(label:"cursor_digest",payload:cursor),
            H3QLeaf(label:"final_reply",payload:terminal), H3QLeaf(label:"guest_image",payload:fixedImage),
            H3QLeaf(label:"request",payload:H3QContract.request), H3QLeaf(label:"schema",payload:Data(terminalSchema.utf8))
        ]
        let live = try makeLiveReceipt(binding(value, readiness:readiness,
            cursorDigest:cursor,checkpointRoot:cpRoot,terminalRoot:terminalRoot))
        func phaseStatus(_ p: H3QCopiedPhase, pc: UInt64, x4: UInt64) -> Bool {
            let statuses = [p.vm_create_status,p.vcpu_create_status,p.register_status,p.run_status,
                p.read_register_status,p.vcpu_destroy_status,p.vm_destroy_status] +
                p.map_status + p.unmap_status + p.host_unmap_status
            let dfsc = p.syndrome & 63
            return statuses.allSatisfy { $0 == 0 } && p.exception_reason == 1 &&
                (4...7).contains(dfsc) && p.syndrome == (0x9384_0040 | dfsc) &&
                p.pc == pc && p.fault_ipa == 0x1000_c000 && p.fault_virtual_address == 0x1000_c000 && p.x4 == x4
        }
        return [
            "native.abi": value.abi_version == 5,
            "native.cancellation": value.cancellation_requested == 0 && value.cancellation_calls == 0 && value.cancellation_status == .min,
            "native.chronology": value.start_ticks > 0 && value.timebase_numer > 0 && value.timebase_denom > 0 &&
                value.start_ticks <= source.entry_ticks && source.entry_ticks <= source.exit_ticks &&
                source.exit_ticks <= target.entry_ticks && target.entry_ticks <= target.exit_ticks &&
                target.exit_ticks <= value.end_ticks && source.generation > 0 && source.generation & 1 == 1 &&
                source.generation < UInt64.max && target.generation == source.generation + 1,
            "native.conservation": value.source_conserved == 1 && value.target_conserved == 1 && source.conserved == 1 && target.conserved == 1,
            "native.counts": source.run_entries == 1 && target.run_entries == 1 && source.mappings_entered == 3 &&
                target.mappings_entered == 3 && source.register_set_calls == 36 && target.register_set_calls == 36 &&
                source.register_read_calls == 36 && target.register_read_calls == 38 && source.vm_create_status == 0 && target.vm_create_status == 0,
            "native.cursor": value.cursor_sealed == 1 && value.cursor_decoded == 1 && value.cursor_restored == 1 && value.cursor_evidence.byte_count == 680,
            "native.execution": value.execution_pass == 1 && value.checkpoint_valid == 1 && value.terminal_valid == 1,
            "native.outcome": value.outcome == 1,
            "native.phase_source": phaseStatus(source, pc:0x1000_0050,x4:1),
            "native.phase_target": phaseStatus(target, pc:0x1000_007c,x4:2),
            "native.quarantine": value.resources_quarantined == 0 && !presentation.quarantined,
            "native.signing": value.signing_admitted == 1 && value.signing_error == 0,
            "native.status": value.failure_stage == 0 && value.first_error == 0,
            "native.teardown": value.teardown_pass == 1,
            "native.watchdog": value.watchdog_fired == 0 && value.watchdog_create_entries == 2 &&
                value.watchdog_join_entries == 2 && value.watchdog_create_status == 0 &&
                value.watchdog_join_status == 0 && [Int32.min,0,60].contains(value.watchdog_wait_status),
            "swift.checkpoint_diagnostic": checkpointResult.integrity == "VALID_PASS" && checkpointResult.failures.isEmpty,
            "swift.checkpoint_merkle": try H3QMerkle.verify(leaves,expectedRoot:cpRoot.hex),
            "swift.cursor_reconstruction": cursorReconstructs(value),
            "swift.fixed_image": fixedImage.count == 136 && H3QContract.hash(fixedImage) == imageSHA256,
            "swift.fixed_replies": cp == H3QContract.frame([1,1,42,0]) && terminal == H3QContract.frame([2,1,42,43]),
            "swift.live_graph": live.graph.root == presentation.graphRoot,
            "swift.live_projection": live.root == presentation.projectionRoot,
            "swift.live_receipt": live.root == presentation.projectionRoot &&
                presentation.wire["readiness_receipt_root"] == .string(readiness.receiptRoot),
            "swift.readiness_contract": readiness.outcome == "PASS_H3_CURSOR_CONTRACT_ONLY" &&
                readiness.gateE == "ABSTAIN" && readiness.authorityVector == "00000000" &&
                readiness.vmEntryCount == 0 && !readiness.stageCompleted && !readiness.liveResumeAuthorized,
            "swift.sctlr_transition": transition.integrity == "VALID_FULL" && transition.failures.isEmpty,
            "swift.terminal_merkle": try H3QMerkle.verify(terminalLeaves,expectedRoot:terminalRoot.hex)
        ]
    }
    fileprivate static func cursorReconstructs(_ input: H3QCopiedResult) -> Bool {
        var value = input
        let image = fixedImage
        do {
        try require(value.cursor_evidence.byte_count == UInt32(cursorBytes),
            "H3 cursor evidence length rejected")
        let evidence = try tupleBytes(&value.cursor_evidence.bytes, count: cursorBytes)
        let cursorDigest = try tupleBytes(&value.cursor_sha256, count: 32)
        let checkpointReply = try tupleBytes(&value.checkpoint_reply, count: 32)
        try require(checkpointReply == H3QContract.frame([1, 1, 42, 0]),
            "H3 fixed checkpoint reply rejected")

        let imagePage = try page(prefix: image)
        let requestPage = try page(prefix: H3QContract.request)
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
        try require(evidenceImageHash.hex == H3QContract.hash(imagePage) &&
            evidenceRequestHash.hex == H3QContract.hash(requestPage) &&
            evidenceReplyHash.hex == H3QContract.hash(checkpointPage),
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
            H3QContract.hash(internalCursor) == cursorDigest.hex &&
            evidenceDigest == cursorDigest,
            "H3 full internal cursor digest reconstruction rejected")


            return true
        } catch { return false }
    }

    fileprivate static func nativeDiagnostic(_ returned: H3QCopiedResult,
                                         error: Error) -> H3QReplayNativeDiagnostic {
        let names = ["none", "self-admission", "clock", "private-memory", "vm-create", "vm-map", "vcpu-create", "register-configuration", "watchdog", "vcpu-run", "exit-registers", "terminal-predicates", "snapshot-merkle", "watchdog-join", "vcpu-destroy", "vm-unmap", "vm-destroy", "host-unmap", "cancellation", "h3-cursor-capture", "h3-source-conservation", "h3-cursor-decode", "h3-restore", "h3-terminal"]
        let stageName = names.indices.contains(Int(returned.failure_stage)) ? names[Int(returned.failure_stage)] : "unknown"
        let baseClassification = returned.outcome == 1
            ? "SWIFT_RECONSTRUCTION_REJECTION" : "NATIVE_NONPASS"
        let source = H3QReplayNativePhaseDiagnostic(returned.source)
        let checkpoint = H3QReplayCheckpointPredicateDiagnostic(returned.checkpoint_diagnostic)
        let checkpointAssessment = checkpointAssessment(checkpoint, source: source,
            checkpointValid: returned.checkpoint_valid, failureStage: returned.failure_stage)
        let sctlrTransition = H3QReplaySCTLRTransitionDiagnostic(
            returned.sctlr_transition_diagnostic)
        let transitionAssessment = sctlrTransitionAssessment(sctlrTransition,
            checkpoint: checkpoint, source: source,
            failureStage: returned.failure_stage, outcome: returned.outcome)
        let classification = checkpointAssessment.integrity == "MALFORMED" ||
            transitionAssessment.integrity == "MALFORMED"
            ? "NATIVE_WITNESS_MALFORMED" : baseClassification
        return H3QReplayNativeDiagnostic(
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
            source: source, target: H3QReplayNativePhaseDiagnostic(returned.target),
            checkpoint: checkpoint, sctlrTransition: sctlrTransition,
            checkpointIntegrity: checkpointAssessment.integrity,
            checkpointFailures: checkpointAssessment.failures,
            sctlrTransitionIntegrity: transitionAssessment.integrity,
            sctlrTransitionFailures: transitionAssessment.failures,
            requestedXORPreEntry: transitionAssessment.requestedXORPreEntry,
            preEntryXORPostExit: transitionAssessment.preEntryXORPostExit)
    }

    static func rejected(_ returned: H3QCopiedResult, _ error: Error) -> H3QReplayPresentation {
        let quarantined = returned.resources_quarantined != 0 || returned.teardown_pass != 1 ||
            returned.outcome == UInt32(5)
        let status: String
        switch returned.outcome {
        case UInt32(2): status = "FAIL"
        case UInt32(3): status = "CANCELED"
        case UInt32(4): status = "BUSY"
        case UInt32(5): status = "QUARANTINED"
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
        return H3QReplayPresentation(status: status,
            verificationDisposition: diagnostic.classification,
            detail: detail,
            cursorSHA256: "", checkpointRoot: "", terminalRoot: "", elapsed: "",
            sourceGeneration: returned.source.generation, targetGeneration: returned.target.generation,
            sourceRunEntries: returned.source.run_entries, targetRunEntries: returned.target.run_entries,
            gateE: "ABSTAIN", authorityVector: "00000000", quarantined: quarantined,
            projectionRoot: "", graphRoot: "", durable: false, h4Entered: false,
            nativeDiagnostic: diagnostic)
    }

    static func rejected(_ error: Error) -> H3QReplayPresentation {
        H3QReplayPresentation(status: "INCOMPLETE", verificationDisposition: "PRE_NATIVE_REJECTION",
            detail: "H3 was rejected before a verified native result: \(error). No PASS or durable evidence was published.",
            cursorSHA256: "", checkpointRoot: "", terminalRoot: "", elapsed: "",
            sourceGeneration: 0, targetGeneration: 0, sourceRunEntries: 0, targetRunEntries: 0,
            gateE: "ABSTAIN", authorityVector: "00000000", quarantined: false,
            projectionRoot: "", graphRoot: "", durable: false, h4Entered: false,
            nativeDiagnostic: nil)
    }

    static func canceledBeforeNativeEntry() -> H3QReplayPresentation {
        H3QReplayPresentation(status: "CANCELED",
            verificationDisposition: "CANCELED_BEFORE_NATIVE_ENTRY",
            detail: "Stop was latched before H3 native entry. No cursor, VM result, or durable evidence was published.",
            cursorSHA256: "", checkpointRoot: "", terminalRoot: "", elapsed: "",
            sourceGeneration: 0, targetGeneration: 0, sourceRunEntries: 0, targetRunEntries: 0,
            gateE: "ABSTAIN", authorityVector: "00000000", quarantined: false,
            projectionRoot: "", graphRoot: "", durable: false, h4Entered: false,
            nativeDiagnostic: nil)
    }
}

private extension Data {
    var hex: String { map { String(format: "%02x", $0) }.joined() }
}

private extension H3QReplayCheckpointPageWitness {
    var wire: H3QualificationJSONValue {
        .object([
            "role": .string(role),
            "firstMismatchOffset": .integer(Int64(firstMismatchOffset)),
            "observedByte": .integer(Int64(observedByte)),
            "expectedByte": .integer(Int64(expectedByte)),
            "reservedZero": .integer(Int64(reservedZero))
        ])
    }
}

private extension H3QReplayCheckpointPredicateDiagnostic {
    var wire: H3QualificationJSONValue {
        .object([
            "schemaVersion": .integer(Int64(schemaVersion)),
            "requiredMask": .integer(Int64(requiredMask)),
            "evaluatedMask": .integer(Int64(evaluatedMask)),
            "passedMask": .integer(Int64(passedMask)),
            "gprMismatchMask": .integer(Int64(gprMismatchMask)),
            "reservedZero": .integer(Int64(reservedZero)),
            "checkpointSequence": .string(String(checkpointSequence)),
            "gprs": .array(gprs.map { .string(String($0)) }),
            "cpsr": .string(String(cpsr)),
            "sctlr": .string(String(sctlr)),
            "sp": .string(String(sp)),
            "vbar": .string(String(vbar)),
            "pages": .array(pages.map { $0.wire })
        ])
    }
}

private extension H3QReplaySCTLRTransitionDiagnostic {
    var wire: H3QualificationJSONValue {
        .object([
            "schemaVersion": .integer(Int64(schemaVersion)),
            "sampledMask": .integer(Int64(sampledMask)),
            "sourcePreEntryReadEntries": .integer(Int64(sourcePreEntryReadEntries)),
            "sourcePostExitReadEntries": .integer(Int64(sourcePostExitReadEntries)),
            "sourcePreEntryReadStatus": .integer(Int64(sourcePreEntryReadStatus)),
            "sourcePostExitReadStatus": .integer(Int64(sourcePostExitReadStatus)),
            "reservedZero0": .integer(Int64(reservedZero0)),
            "reservedZero1": .integer(Int64(reservedZero1)),
            "requested": .string(String(requested)),
            "sourcePreEntry": .string(String(sourcePreEntry)),
            "sourcePostExit": .string(String(sourcePostExit))
        ])
    }
}

private extension H3QReplayNativePhaseDiagnostic {
    var wire: H3QualificationJSONValue {
        .object([
            "generation": .string(String(generation)),
            "runEntries": .integer(Int64(runEntries)),
            "mappingsEntered": .integer(Int64(mappingsEntered)),
            "registerSetCalls": .integer(Int64(registerSetCalls)),
            "registerReadCalls": .integer(Int64(registerReadCalls)),
            "conserved": .integer(Int64(conserved)),
            "vmCreateStatus": .integer(Int64(vmCreateStatus)),
            "mapStatuses": .array(mapStatuses.map { .integer(Int64($0)) }),
            "vcpuCreateStatus": .integer(Int64(vcpuCreateStatus)),
            "registerStatus": .integer(Int64(registerStatus)),
            "runStatus": .integer(Int64(runStatus)),
            "readRegisterStatus": .integer(Int64(readRegisterStatus)),
            "vcpuDestroyStatus": .integer(Int64(vcpuDestroyStatus)),
            "unmapStatuses": .array(unmapStatuses.map { .integer(Int64($0)) }),
            "vmDestroyStatus": .integer(Int64(vmDestroyStatus)),
            "hostUnmapStatuses": .array(hostUnmapStatuses.map { .integer(Int64($0)) }),
            "entryTicks": .string(String(entryTicks)),
            "exitTicks": .string(String(exitTicks)),
            "exceptionReason": .string(String(exceptionReason)),
            "syndrome": .string(String(syndrome)),
            "pc": .string(String(pc)),
            "faultIPA": .string(String(faultIPA)),
            "faultVirtualAddress": .string(String(faultVirtualAddress)),
            "x4": .string(String(x4))
        ])
    }
}

private extension H3QReplayNativeDiagnostic {
    var wire: H3QualificationJSONValue {
        .object([
            "classification": .string(classification),
            "verifierError": .string(verifierError),
            "abiVersion": .integer(Int64(abiVersion)),
            "outcome": .integer(Int64(outcome)),
            "executionPass": .integer(Int64(executionPass)),
            "teardownPass": .integer(Int64(teardownPass)),
            "signingAdmitted": .integer(Int64(signingAdmitted)),
            "cursorSealed": .integer(Int64(cursorSealed)),
            "cursorDecoded": .integer(Int64(cursorDecoded)),
            "cursorRestored": .integer(Int64(cursorRestored)),
            "cursorEvidenceByteCount": .integer(Int64(cursorEvidenceByteCount)),
            "checkpointValid": .integer(Int64(checkpointValid)),
            "terminalValid": .integer(Int64(terminalValid)),
            "sourceConserved": .integer(Int64(sourceConserved)),
            "targetConserved": .integer(Int64(targetConserved)),
            "cancellationRequested": .integer(Int64(cancellationRequested)),
            "cancellationCalls": .integer(Int64(cancellationCalls)),
            "watchdogFired": .integer(Int64(watchdogFired)),
            "watchdogCreateEntries": .integer(Int64(watchdogCreateEntries)),
            "watchdogJoinEntries": .integer(Int64(watchdogJoinEntries)),
            "resourcesQuarantined": .integer(Int64(resourcesQuarantined)),
            "failureStage": .integer(Int64(failureStage)),
            "failureStageName": .string(failureStageName),
            "firstError": .integer(Int64(firstError)),
            "signingError": .integer(Int64(signingError)),
            "cancellationStatus": .integer(Int64(cancellationStatus)),
            "watchdogCreateStatus": .integer(Int64(watchdogCreateStatus)),
            "watchdogJoinStatus": .integer(Int64(watchdogJoinStatus)),
            "watchdogWaitStatus": .integer(Int64(watchdogWaitStatus)),
            "startTicks": .string(String(startTicks)),
            "endTicks": .string(String(endTicks)),
            "timebaseNumer": .integer(Int64(timebaseNumer)),
            "timebaseDenom": .integer(Int64(timebaseDenom)),
            "source": source.wire,
            "target": target.wire,
            "checkpoint": checkpoint.wire,
            "sctlrTransition": sctlrTransition.wire,
            "checkpointIntegrity": .string(checkpointIntegrity),
            "checkpointFailures": .array(checkpointFailures.map { .string($0) }),
            "sctlrTransitionIntegrity": .string(sctlrTransitionIntegrity),
            "sctlrTransitionFailures": .array(sctlrTransitionFailures.map { .string($0) }),
            "requestedXORPreEntry": requestedXORPreEntry.map { .string(String($0)) } ?? .null,
            "preEntryXORPostExit": preEntryXORPostExit.map { .string(String($0)) } ?? .null
        ])
    }
}

enum H3QualificationReplay {
    static func replay(capture: H3QualificationNativeCapture) throws -> H3QualificationPresentation {
        try H3QualificationWire.validate(capture.wire, schema: "inner_native_returned")
        let copied = try H3QCopiedResult(capture: capture)
        let presentation: H3QReplayPresentation
        do { presentation = try H3QReplayNative.verify(copied) }
        catch { presentation = H3QReplayNative.rejected(copied, error) }
        let diagnostic = presentation.nativeDiagnostic ?? H3QReplayNative.nativeDiagnostic(copied, error: H3QReplayFailure(""))
        let readinessRoot: String
        if presentation.status == "PASS" {
            readinessRoot = try H3QReadinessCursor.verifyContract(H3QReadinessCursor.runContract()).receiptRoot
        } else { readinessRoot = "" }
        return owned(presentation, assessment: diagnostic, readinessRoot: readinessRoot)
    }

    static func preparationRejected(error: String) -> H3QualificationPresentation {
        owned(H3QReplayNative.rejected(H3QReplayFailure(error)), assessment: nil, readinessRoot: "")
    }

    static func preparationPresentation(error: Int32) throws -> H3QualificationPresentation {
        guard error > 0 else { throw H3QualificationFailure.invariant("preparation errno") }
        return preparationRejected(error: "H3 preparation failed with errno \(error)")
    }

    static func signingRejectedPresentation() -> H3QualificationPresentation {
        preparationRejected(error: "live self-signing admission did not pass")
    }

    private static func owned(_ p: H3QReplayPresentation, assessment d: H3QReplayNativeDiagnostic?,
                              readinessRoot: String) -> H3QualificationPresentation {
        typealias V = H3QualificationJSONValue
        let wire = V.object([
            "checkpoint_failures": .array((d?.checkpointFailures ?? []).map(V.string)),
            "checkpoint_integrity": .string(d?.checkpointIntegrity ?? "VALID_NOT_EVALUATED"),
            "checkpoint_root": .string(p.checkpointRoot),
            "detail_sha256": .string(H3QualificationProtocol.hash(Data(p.detail.utf8))),
            "disposition": .string(p.verificationDisposition),
            "durable": .bool(p.durable), "graph_root": .string(p.graphRoot), "h4_entered": .bool(p.h4Entered),
            "pre_entry_xor_post_exit": d?.preEntryXORPostExit.map { .string(String($0)) } ?? .null,
            "projection_root": .string(p.projectionRoot), "quarantined": .bool(p.quarantined),
            "readiness_receipt_root": .string(readinessRoot),
            "requested_xor_pre_entry": d?.requestedXORPreEntry.map { .string(String($0)) } ?? .null,
            "sctlr_transition_failures": .array((d?.sctlrTransitionFailures ?? []).map(V.string)),
            "sctlr_transition_integrity": .string(d?.sctlrTransitionIntegrity ?? "VALID_NOT_SAMPLED"),
            "status": .string(p.status), "terminal_root": .string(p.terminalRoot),
            "verifier_error_sha256": .string(H3QualificationProtocol.hash(Data((p.nativeDiagnostic?.verifierError ?? "").utf8)))
        ])
        return H3QualificationPresentation(wire: wire, status: p.status, verificationDisposition: p.verificationDisposition,
            detail: p.detail, cursorSHA256: p.cursorSHA256, checkpointRoot: p.checkpointRoot,
            terminalRoot: p.terminalRoot, elapsed: p.elapsed, sourceGeneration: p.sourceGeneration,
            targetGeneration: p.targetGeneration, sourceRunEntries: p.sourceRunEntries, targetRunEntries: p.targetRunEntries,
            gateE: p.gateE, authorityVector: p.authorityVector, quarantined: p.quarantined,
            projectionRoot: p.projectionRoot, graphRoot: p.graphRoot, durable: p.durable, h4Entered: p.h4Entered,
            nativeDiagnostic: p.nativeDiagnostic?.wire)
    }
}

struct H3QualificationCampaignArtifactBundle: Sendable, Equatable {
    let mode: H3QualificationMode
    let artifacts: [String: Data]
}

// Immutable byte-only transcription of the committed external contract. It
// grants no capability and is never loaded from a campaign or caller path.
private let h3QualificationExternalContract: H3QualificationJSONValue = try! H3QualificationCanonicalJSON.decode(
    Data(#"{"allowlist":["ErgenticsProvenance.xcodeproj/project.pbxproj","ErgenticsProvenance.xcodeproj/xcshareddata/xcschemes/ErgenticsProvenanceH3Qualification.xcscheme","Sources/DevelopmentLaunch.swift","Sources/ProvenanceApp.swift","Sources/ProvenanceModel.swift","Sources/HypervisorModel.swift","Sources/HypervisorH3LiveVerifier.swift","Sources/DevelopmentRustBootExport.swift","Sources/H3QualificationProtocol.swift","Sources/H3QualificationCoordinator.swift","Tools/H3QualificationSeal/h3_qualification_seal.rb","Tools/H3QualificationController/main.swift","Tools/H3QualificationController/H3QualificationControllerPolicy.swift","Tools/H3QualificationController/H3QualificationProcess.swift","Tools/H3QualificationController/H3QualificationSigning.swift","Tools/H3QualificationController/H3QualificationStorage.swift","Tests/H3QualificationRunnerTests.swift"],"build_debug":["/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild","-project","/Users/ergentics/Developer/ErgenticsProvenance/ErgenticsProvenance.xcodeproj","-scheme","ErgenticsProvenanceH3Qualification","-configuration","Debug","-destination","platform=macOS,arch=arm64","-derivedDataPath","/private/tmp/ergentics-h3q-debug-v1","SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) EPR_H3_QUALIFICATION","CODE_SIGNING_ALLOWED=YES","build"],"build_release":["/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild","-project","/Users/ergentics/Developer/ErgenticsProvenance/ErgenticsProvenance.xcodeproj","-scheme","ErgenticsProvenanceH3Qualification","-configuration","Release","-destination","platform=macOS,arch=arm64","-derivedDataPath","/private/tmp/ergentics-h3q-release-v1","SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) EPR_H3_QUALIFICATION","CODE_SIGNING_ALLOWED=YES","build"],"environment":["DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer","GIT_CONFIG_GLOBAL=/dev/null","GIT_CONFIG_NOSYSTEM=1","GIT_NO_LAZY_FETCH=1","GIT_OPTIONAL_LOCKS=0","HOME=/Users/ergentics","LANG=C","LC_ALL=C","LOGNAME=ergentics","PATH=/usr/bin:/bin:/usr/sbin:/sbin","TMPDIR=/private/tmp/","USER=ergentics","__CF_USER_TEXT_ENCODING=0x1F5:0x0:0x0"],"pins":[{"git_blob":"b5fd9b2e1c72f54924269b6ff9453f87abeae5f2","path":"ErgenticsProvenance.xcodeproj/project.pbxproj","sha256":"93a0ff15e38859a9f74268861a1c18803f514f0f8be7af9bc4b22d6f59ea9561"},{"git_blob":"412b603ef4b0ca473dbae34dbd8051690e01a7b8","path":"ErgenticsProvenance.xcodeproj/xcshareddata/xcschemes/ErgenticsProvenance.xcscheme","sha256":"3a34c15f9ecb369fd18956ee671fa3b67d83414d6af35c4a9a486bcca1df4666"},{"git_blob":"d7bd491f0c772584a3bfa1b977306e3f31941bf4","path":"Entitlements.plist","sha256":"ffab5dd538d1fc0aefa6b0e7facf2dcc4f0927845db0806b2bec82a617b2dcf2"},{"git_blob":"c0814a3454b30ccf83b888ab1899c1779c2f96c8","path":"Sources/DevelopmentLaunch.swift","sha256":"c5470f01af214bd52b0f4b9048a54900de04a33e4974c53685f7da83ba4f10f6"},{"git_blob":"a857dfbd24b8f494d44b9599fadbd1e214eaf203","path":"Sources/ProvenanceApp.swift","sha256":"ce66b6846cd08a9a7058d77d9a59b2da781364544b4cf6f2460b4e0fe2cd57cb"},{"git_blob":"3c3e66a8b4ac75784f825ecf57b9c7510a6eb3c3","path":"Sources/ProvenanceModel.swift","sha256":"c4eb9d1fa4e5d69a48db70e26029090aa939e6eaf95d223cc25b86716f1ecb28"},{"git_blob":"45292fa6c53b42b600be49dce90eed82e6cb84b7","path":"Sources/ProvenanceReadOnly.c","sha256":"78c4d4e2e8e4b50ee81b5a671b127dfb2fdad2ec812b67314bf6553af37fd0c6"},{"git_blob":"e57277d21cfffbdfd6c9bc8d71151d08460971a5","path":"Sources/HypervisorModel.swift","sha256":"216a72a262f275ae9e1c6da57e3cb35ee9f76bcac41db484e7c9c80a27a36ede"},{"git_blob":"f4262e98bab43d9d649fa7a3b5d69d36f3cc3ec6","path":"Sources/HypervisorGuest.c","sha256":"006b15327db939ad930ef8594eca61b5bbd71cc243250caee9393fbf539baf87"},{"git_blob":"4630c11f629f57b7086328448fabc1c7ddb18d35","path":"Sources/HypervisorGuest.h","sha256":"d663619e58a267dce936a4551ba69a493c238fa9c6897ef68ebf003fa9dbb58d"},{"git_blob":"3e2f7504e0d16df16c2064f41a7ddf4d1fd4bef1","path":"Sources/HypervisorH3LiveVerifier.swift","sha256":"3072f6b85a310ddc8c3a7bf5eedb8fe7ef7cfcd86fedd9d7b56593e5a54666cd"},{"git_blob":"6c39514d5d617bbf95d5eef81fcb0a7ac49cd3d9","path":"Sources/DevelopmentRustBootExport.swift","sha256":"71cf5756b23e02bb139f7521d719d0620b62b1a3e1b6365bba6e5bf4fe93f1a9"},{"git_blob":"0abbf5d5cc460b6c8f042e6f80b9edf137b33182","path":"Guest/cursor-resume.S","sha256":"5c0461d4d61bf798c334e33f822ff37f9e8f0b1a3272f812d4d2154ace4197a3"}],"product_argv":[["/usr/bin/shasum","-a","256","<product_executable>"],["/usr/bin/dwarfdump","--uuid","<product_executable>"],["/usr/bin/codesign","--verify","--strict","--all-architectures","<product_bundle_or_executable>"],["/usr/bin/codesign","-d","--verbose=4","--requirements","-","--entitlements",":-","<product_bundle_or_executable>"],["/usr/bin/otool","-L","<product_executable>"],["/usr/bin/nm","-gju","<product_executable>"]],"settings":{"application_settings":{"CODE_SIGN_ENTITLEMENTS":"Entitlements.plist","ENABLE_APP_SANDBOX":"YES","EXECUTABLE_NAME":"Ergentics Provenance","EXECUTABLE_PATH":"Ergentics Provenance.app/Contents/MacOS/Ergentics Provenance","FULL_PRODUCT_NAME":"Ergentics Provenance.app","PRODUCT_BUNDLE_IDENTIFIER":"com.ergentics.provenance","PRODUCT_NAME":"Ergentics Provenance","TARGET_NAME":"ErgenticsProvenance"},"application_target":"ErgenticsProvenance","configuration_settings":{"DEBUG":{"CONFIGURATION":"Debug","SWIFT_ACTIVE_COMPILATION_CONDITIONS":"DEBUG EPR_H3_QUALIFICATION","TARGET_BUILD_DIR":"/private/tmp/ergentics-h3q-debug-v1/Build/Products/Debug"},"RELEASE":{"CONFIGURATION":"Release","SWIFT_ACTIVE_COMPILATION_CONDITIONS":"EPR_H3_QUALIFICATION","TARGET_BUILD_DIR":"/private/tmp/ergentics-h3q-release-v1/Build/Products/Release"}},"controller_settings":{"CODE_SIGN_ENTITLEMENTS":"ABSENT_KEY","CODE_SIGN_INJECT_BASE_ENTITLEMENTS":"NO","CREATE_INFOPLIST_SECTION_IN_BINARY":"YES","ENABLE_APP_SANDBOX":"NO","EXECUTABLE_NAME":"ErgenticsProvenanceH3QualificationController","EXECUTABLE_PATH":"ErgenticsProvenanceH3QualificationController","FULL_PRODUCT_NAME":"ErgenticsProvenanceH3QualificationController","GENERATE_INFOPLIST_FILE":"YES","PRODUCT_BUNDLE_IDENTIFIER":"com.ergentics.provenance.h3-qualification-controller","PRODUCT_NAME":"ErgenticsProvenanceH3QualificationController","SKIP_INSTALL":"YES","TARGET_NAME":"ErgenticsProvenanceH3QualificationController"},"controller_target":"ErgenticsProvenanceH3QualificationController","derived_path_rules":"For each record, BUILT_PRODUCTS_DIR and CONFIGURATION_BUILD_DIR equal TARGET_BUILD_DIR. TARGET_BUILD_DIR plus FULL_PRODUCT_NAME/EXECUTABLE_PATH derives exactly the frozen concrete product bundle/executable, with canonical containment below that configuration's one DerivedData path. No setting may resolve through a caller-selected path.","parse":"Read exactly 1...1048576 bytes, require strict UTF-8, and use an iterative duplicate-key-rejecting JSON parser with maximum nesting depth 32, 65536 total value tokens, 8192 members in any object, 4096 elements in any array, 262144 decoded UTF-8 bytes in any string, and 2097152 cumulative decoded string bytes. The root is an array of exactly two objects, each containing exactly action, buildSettings, and target; every key and value inside buildSettings is a string, each key is at most 1024 UTF-8 bytes, and action/target are at most 256 UTF-8 bytes. Numbers, booleans, null, invalid escapes/scalars, trailing bytes, any limit excess, arithmetic overflow, and parser recursion are rejected. action is exactly build, matching the explicit literal action in both fixed settings argv arrays; target is unique and the records are normalized to APPLICATION then CONTROLLER before comparison. Unknown buildSettings keys are retained by the raw artifact hash but may not substitute for, contradict, or suppress any required key.","required_common_settings":{"ARCHS":"arm64","CODE_SIGNING_ALLOWED":"YES","CODE_SIGNING_REQUIRED":"YES","CODE_SIGN_IDENTITY":"Apple Development","CODE_SIGN_STYLE":"Automatic","DEVELOPMENT_TEAM":"ZCQ435U8JP","ENABLE_HARDENED_RUNTIME":"YES","MACOSX_DEPLOYMENT_TARGET":"26.0","PLATFORM_NAME":"macosx","SDKROOT":"/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk","SWIFT_VERSION":"6.0"}},"source_argv":[["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","rev-parse","HEAD"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","rev-parse","HEAD^{tree}"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","rev-parse","<freeze_commit>^{tree}"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","diff","--raw","--no-abbrev","--no-renames","--no-ext-diff","--no-textconv","-z","461af031064b0529e7432b1f6cf0cfc2cbccec48..<freeze_commit>","--"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","diff","--raw","--no-abbrev","--no-renames","--no-ext-diff","--no-textconv","-z","<freeze_commit>..<implementation_commit>","--"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","-c","core.quotePath=false","diff","--no-ext-diff","--no-textconv","--name-only","--no-renames","-z","<freeze_commit>..<implementation_commit>","--"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","ls-tree","-r","-z","--full-tree","<implementation_commit>"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","cat-file","--batch"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","ls-files","--stage","-z","--"]],"toolchain_argv":[["/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild","-version"],["/usr/bin/xcrun","--sdk","macosx","--show-sdk-version"],["/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc","--version"],["/usr/bin/ruby","--disable=gems,rubyopt,did_you_mean","-v"],["/usr/bin/shasum","-a","256","/usr/bin/ruby"],["/usr/bin/codesign","-d","--verbose=4","/usr/bin/ruby"],["/usr/bin/shasum","-a","256","/usr/bin/env"],["/usr/bin/codesign","-d","--verbose=4","/usr/bin/env"],["/usr/bin/sw_vers","-buildVersion"],["/usr/bin/uname","-m"]],"vocabulary":["application.h3_preparation","application.live_self_signing_admission","native.abi","native.cancellation","native.chronology","native.conservation","native.counts","native.cursor","native.execution","native.outcome","native.phase_source","native.phase_target","native.quarantine","native.signing","native.status","native.teardown","native.watchdog","runner.application_identity","runner.authority_boundary","runner.build_identity","runner.cancellation","runner.deadline","runner.environment","runner.exit","runner.export","runner.gate","runner.inner_frame","runner.monitor","runner.run_identity","runner.signal","runner.spawn","runner.stderr","runner.timing","swift.checkpoint_diagnostic","swift.checkpoint_merkle","swift.cursor_reconstruction","swift.fixed_image","swift.fixed_replies","swift.live_graph","swift.live_projection","swift.live_receipt","swift.readiness_contract","swift.sctlr_transition","swift.terminal_merkle"]}"#.utf8), maximumBytes: 262_144)

/// Prelaunch consumes only the three fixed, held-root-relative artifacts.
private enum H3QExternal {
    typealias V = H3QualificationJSONValue
    static let freeze = "245382fb61fb94fe8ef29bcbfa00d6f39fa7d14a"
    static let emptyHash = H3QualificationProtocol.hash(Data())
    static let zeroHash = String(repeating: "0", count: 64)
    static let repository = "/Users/ergentics/Developer/ErgenticsProvenance"
    static let controllerName = "ErgenticsProvenanceH3QualificationController"
    static let controllerID = "com.ergentics.provenance.h3-qualification-controller"
    static let appID = "com.ergentics.provenance"
    static let team = "ZCQ435U8JP"
    static let leaves = ["inner-application-report.frame", "application-stderr.bin", "outer-observer-receipt.json", "manifest.json"]
    static let prelaunch = ["build-source-manifest.json", "source-state.json", "debug-build.log", "debug-build-settings.json", "debug-product-audit.json", "release-build.log", "release-build-settings.json", "release-product-audit.json"]
    static let prior = ["prior-admission-checkpoint.json", "prior-admission-verifier-supervisor.json", "prior-admission-campaign-seal.json"]
    static func require(_ condition: Bool, _ reason: String) throws {
        guard condition else { throw H3QualificationFailure.malformed(reason) }
    }
    static func strings(_ value: V?) throws -> [String] {
        guard let array = value?.arrayValue else { throw H3QualificationFailure.malformed("string array") }
        let result = array.compactMap(\.stringValue)
        try require(result.count == array.count, "string array element")
        return result
    }
    static func array(_ values: [String]) -> V { .array(values.map(V.string)) }
    static func sorted(_ values: [String]) -> [String] { values.sorted { $0.utf8.lexicographicallyPrecedes($1.utf8) } }
    static func configuration(_ value: V?) throws -> H3QualificationConfiguration {
        guard let text = value?.stringValue, let result = H3QualificationConfiguration(rawValue: text) else {
            throw H3QualificationFailure.malformed("configuration")
        }
        return result
    }
    static func mode(_ value: V?) throws -> H3QualificationMode {
        guard let text = value?.stringValue, let result = H3QualificationMode(rawValue: text) else {
            throw H3QualificationFailure.malformed("mode")
        }
        return result
    }
    static func productDirectory(_ configuration: H3QualificationConfiguration) -> String {
        "/private/tmp/ergentics-h3q-\(configuration == .debug ? "debug" : "release")-v1/Build/Products/\(configuration == .debug ? "Debug" : "Release")"
    }
    static func productPath(_ configuration: H3QualificationConfiguration, app: Bool, code: Bool = false) -> String {
        productDirectory(configuration) + (app ? "/Ergentics Provenance.app" + (code ? "" : "/Contents/MacOS/Ergentics Provenance") : "/" + controllerName)
    }
    static func root(_ mode: H3QualificationMode) -> String {
        "/private/tmp/ergentics-h3q-\(mode == .admissionOnly ? "admission" : "guest")-campaign-v1"
    }
    static func field(_ value: V, descriptor: String, context: String) throws -> Bool {
        // Prose-bearing descriptors are enumerated by their frozen field
        // context; this is not a heuristic that accepts arbitrary prose.
        let arrayTypes: [String: (String, Int, Int)] = [
            "manifest_v1.files": ("manifest_file", 3, 3),
            "build_source_manifest_v1.builds": ("build_record", 2, 2),
            "build_source_manifest_v1.products": ("product_pair", 2, 2),
            "build_source.delta_path_pins": ("source_path_pin", 1, 17),
            "build_source.frozen_input_pins": ("source_path_pin", 0, 13),
            "build_dirty_guard.allowed_tracked_dirty": ("source_path_pin", 2, 2),
            "build_toolchain.probes": ("command_probe", 10, 10),
            "product_audit_v1.probes": ("product_probe", 12, 12),
            "campaign_checkpoint_v1.runs": ("campaign_run", 2, 2),
            "campaign_seal_v1.run_supervisors": ("artifact_reference", 2, 2)]
        if let (schema, minimum, maximum) = arrayTypes[context] {
            guard let values = value.arrayValue, (minimum...maximum).contains(values.count) else {
                throw H3QualificationFailure.malformed(context)
            }
            for element in values { try H3QualificationWire.validateStructure(element, schema: schema) }
            return true
        }
        if context == "source_state_v1.probes" {
            guard let values = value.arrayValue, values.count == 9 else { throw H3QualificationFailure.malformed(context) }
            for (index, element) in values.enumerated() {
                try H3QualificationWire.validateStructure(element, schema: index == 7 ? "tracked_tree_batch_probe" : "command_probe")
            }
            return true
        }
        if context == "build_source.delta_paths" || context == "outer_classification.failed_predicates" {
            let values = try strings(value)
            try require(values == sorted(values) && Set(values).count == values.count, context + " order")
            let permitted = try strings(h3QualificationExternalContract[context.hasPrefix("build") ? "allowlist" : "vocabulary"])
            try require(values.allSatisfy(permitted.contains) && (!context.hasPrefix("build") || !values.isEmpty), context + " membership")
            return true
        }
        if descriptor.hasPrefix("exact thirteen-entry") {
            try require(value == h3QualificationExternalContract["environment"], context + " environment"); return true
        }
        if context == "outer_spawn.fd_map" {
            try require(value == .string("0=devnull-ro,1=regular-rw-0600,2=pipe,3=gate-ro,4=cancel-ro"), context); return true
        }
        if context == "build_toolchain.seal_runtime_revision" {
            try require(value == .string("67958"), context); return true
        }
        if context == "outer_evidence.effective_hypervisor_value" {
            try require(value == .string("TRUE") || value == .string("NOT_OBSERVED"), context); return true
        }
        if context == "campaign_checkpoint_v1.prior_admission" {
            if value != .null { try H3QualificationWire.validateStructure(value, schema: "prior_admission_closure") }; return true
        }
        let optionalReferences = ["seal_supervisor_receipt_v1.campaign_checkpoint", "seal_supervisor_receipt_v1.outer_receipt", "seal_supervisor_receipt_v1.run_manifest"]
        if optionalReferences.contains(context) {
            if value != .null { try H3QualificationWire.validateStructure(value, schema: "artifact_reference") }; return true
        }
        if context == "seal_supervisor_receipt_v1.controller_product_audit" {
            try H3QualificationWire.validateStructure(value, schema: "artifact_reference"); return true
        }
        if context == "tracked_tree_batch_probe.stderr" {
            try H3QualificationWire.validateStructure(value, schema: "captured_stream"); return true
        }
        let argvFields = ["outer_spawn.argv", "build_record.argv", "build_record.settings_argv", "seal_supervisor_receipt_v1.argv", "product_probe.argv", "command_probe.argv", "tracked_tree_batch_probe.argv"]
        if argvFields.contains(context) {
            let values = try strings(value)
            try require(!values.isEmpty && values.count <= 64 && values.allSatisfy { !$0.isEmpty && $0.utf8.count <= 4096 && !$0.contains("\0") }, context)
            if context == "outer_spawn.argv" { try require(values.count == 2, context) }
            return true
        }
        if context == "seal_supervisor_receipt_v1.inventory_before" || context == "seal_supervisor_receipt_v1.inventory_after_child" {
            let values = try strings(value)
            try require(values.count <= 32 && values == sorted(values) && Set(values).count == values.count, context)
            for path in values { try H3QualificationWire.validateStructure(.object(["byte_count": .integer(1), "path": .string(path.hasSuffix("/") ? String(path.dropLast()) : path), "sha256": .string(zeroHash)]), schema: "artifact_reference") }
            return true
        }
        return false
    }
    static func validate(_ value: V, schema: String) throws {
        switch schema {
        case "captured_stream": _ = try stream(value)
        case "code_identity_claim": try code(value)
        case "controller_identity_claim":
            try code(value.required("code"), app: false)
            try require(value["held_at_start"] == value["named_at_start"], "controller vnode join")
            try regular(value.required("held_at_start"))
        case "outer_application_identity":
            try code(value.required("pre_static"), app: true)
            try require(H3QualificationProtocol.sameCodeIdentity(value["dynamic"], value["pre_static"]) && H3QualificationProtocol.sameCodeIdentity(value["post_static"], value["pre_static"]) && value["proc_pidpath"] == value["pre_static"]?["executable_path"], "application code joins")
            for name in ["held_before_spawn", "held_before_gate", "named_before_spawn", "named_before_gate", "held_after_reap", "named_after_reap"] {
                try require(value[name] == value["held_before_spawn"], "application vnode joins")
            }
            try regular(value.required("held_before_spawn"))
        case "outer_application_not_launched":
            try code(value.required("pre_static"), app: true)
            for name in ["held_terminal", "named_before_spawn", "named_terminal"] { try require(value[name] == value["held_before_spawn"], "not-launched vnode") }
            try regular(value.required("held_before_spawn"))
        case "outer_receipt_v1": try outer(value)
        case "child_reaped": try child(value)
        case "successful_external_process_result", "supervised_controller_process_result": try process(value, supervised: schema.hasPrefix("supervised"))
        case "command_probe", "product_probe":
            _ = try stream(value.required("stdout")); _ = try stream(value.required("stderr"))
        case "manifest_v1":
            let files = value["files"]!.arrayValue!
            try require(files.map { $0["path"]?.stringValue } == Array(leaves.prefix(3)).map(Optional.some), "manifest leaf order")
            for (index, file) in files.enumerated() { try require(file["byte_count"]!.intValue! <= [65_552, 65_536, 131_072][index], "manifest file bound") }
        case "build_dirty_guard": try dirty(value)
        case "build_source": try source(value)
        case "source_state_v1": try sourceState(value)
        case "build_toolchain": try toolchain(value)
        case "build_source_manifest_v1": try manifest(value)
        case "product_audit_v1": try productAudit(value)
        case "build_record": try buildRecord(value)
        case "product_pair":
            let config = try configuration(value["configuration"])
            try code(value.required("application"), app: true, config: config)
            try code(value.required("controller"), app: false, config: config)
        case "seal_held_named_path_identity":
            try require(value["held"] == value["named"], "seal executable held/named")
            try validate(value.required("held"), schema: "seal_path_identity")
        case "seal_held_named_directory_identity":
            try require(value["held"] == value["named"], "seal directory held/named")
            try validate(value.required("held"), schema: "seal_directory_identity")
        case "seal_path_identity":
            try require(value["owner"] == .integer(501) && value["link_count"] == .string("1") && value["inode"]!.uintValue! > 0 && value["mode"]!.intValue! & 0o111 != 0 && value["mode"]!.intValue! & 0o022 == 0, "seal path identity")
        case "seal_directory_identity": try require(value["owner"] == .integer(501) && value["inode"]!.uintValue! > 0, "seal directory identity")
        case "seal_supervisor_receipt_v1": try supervisor(value)
        case "campaign_checkpoint_v1": try checkpoint(value)
        case "campaign_seal_v1":
            let campaign = value["campaign"]!.stringValue!
            try require(value["result"] == .string(campaign == "ADMISSION" ? "PASS_ADMISSION_CAMPAIGN" : "PASS_H3_GUEST_CAMPAIGN") || (campaign == "GUEST" && value["result"] == .string("FAIL_H3_GUEST_CAMPAIGN")), "seal campaign result")
        case "file_identity", "outer_host", "child_not_created", "outer_classification", "outer_deadlines", "outer_evidence", "outer_gate_cancel", "outer_spawn", "outer_kill", "outer_stderr", "outer_taxonomy", "manifest_file", "containment_incident_v1", "outer_taxonomy_unknown_capable", "source_path_pin", "build_audit_artifacts", "tracked_tree_batch_probe", "prior_admission_closure", "campaign_taxonomy", "artifact_reference", "large_artifact_reference", "campaign_run", "campaign_aggregates": break
        default: throw H3QualificationFailure.unsupportedSchema(schema)
        }
    }
    static func stream(_ value: V, empty: Bool = false) throws -> Data {
        try H3QualificationWire.validateStructure(value, schema: "captured_stream")
        guard let text = value["base64"]?.stringValue, let bytes = Data(base64Encoded: text) else { throw H3QualificationFailure.malformed("stream base64") }
        try require(bytes.count <= 65_536 && value["byte_count"]?.intValue == Int64(bytes.count) && value["sha256"] == .string(H3QualificationProtocol.hash(bytes)) && (!empty || bytes.isEmpty), "stream bytes/hash")
        return bytes
    }
    static func regular(_ identity: V, executable: Bool = true) throws {
        try H3QualificationWire.validateStructure(identity, schema: "file_identity")
        let mode = identity["mode"]!.intValue!
        try require(identity["owner"] == .integer(501) && identity["link_count"] == .string("1") && identity["inode"]!.uintValue! > 0 && mode & 0o022 == 0 && (!executable || mode & 0o111 != 0), "regular vnode")
    }
    static func code(_ value: V, app expectedApp: Bool? = nil, config expectedConfig: H3QualificationConfiguration? = nil) throws {
        try H3QualificationWire.validateStructure(value, schema: "code_identity_claim")
        let app = value["identifier"] == .string(appID)
        try require(expectedApp == nil || expectedApp == app, "product role")
        let config: H3QualificationConfiguration
        if let expectedConfig { config = expectedConfig }
        else if value["executable_path"] == .string(productPath(.debug, app: app)) { config = .debug }
        else { config = .release }
        try require(value["identifier"] == .string(app ? appID : controllerID) && value["team_identifier"] == .string(team) && value["runtime"] == .bool(true) && value["valid"] == .bool(true), "signed product policy")
        try require(value["executable_path"] == .string(productPath(config, app: app)) && value["code_object_path"] == .string(productPath(config, app: app, code: true)), "product paths")
        try require(!(value["designated_requirement"]?.stringValue ?? "").isEmpty, "designated requirement")
        if app { try H3QualificationWire.validateStructure(value.required("entitlements"), schema: "effective_entitlements") }
        else { try require(value["entitlements"] == .null, "controller has entitlements") }
        try require(value["entitlements_sha256"] == .string(H3QualificationProtocol.hash(try H3QualificationCanonicalJSON.encode(value.required("entitlements")))), "code entitlement hash")
    }
    static func child(_ value: V) throws {
        let wait = value["wait_status"]!.intValue!
        let signal = wait & 0x7f
        if signal == 0 { try require(value["exit"]?.intValue == (wait >> 8) & 0xff && value["signal"] == .string("NOT_APPLICABLE") && wait == ((wait >> 8) & 0xff) << 8, "normal wait tuple") }
        else { try require(signal != 0x7f && value["signal"]?.intValue == signal && value["exit"] == .string("NOT_APPLICABLE") && wait & ~0xff == 0, "signaled wait tuple") }
    }
    static func process(_ value: V, supervised: Bool) throws {
        let start = value["spawn_tick"]!.uintValue!, deadline = value["operation_deadline_tick"]!.uintValue!
        let reap = value["reap_tick"]!.uintValue!, terminal = value["terminal_tick"]!.uintValue!
        try require(start < deadline && (supervised ? start < reap : start <= reap) && start < terminal && reap <= terminal && terminal <= deadline && value["observed_pipe_eof_count"] == value["required_pipe_eof_count"] && value["wait_status"]!.intValue! == value["exit_status"]!.intValue! << 8, "external process chronology/wait")
        if supervised {
            try require(value["process_group"] == value["child_pid"], "exact supervisor group")
            _ = try stream(value.required("stdout"), empty: true); _ = try stream(value.required("stderr"), empty: true)
        }
    }
    static func reference(_ value: V, path: String, artifacts: [String: Data], maximum: Int = 1_048_576) throws {
        try H3QualificationWire.validateStructure(value, schema: maximum > 1_048_576 ? "large_artifact_reference" : "artifact_reference")
        guard let bytes = artifacts[path], !bytes.isEmpty, bytes.count <= maximum else { throw H3QualificationFailure.malformed("missing/bounded artifact \(path)") }
        try require(value["path"] == .string(path) && value["byte_count"]?.intValue == Int64(bytes.count) && value["sha256"] == .string(H3QualificationProtocol.hash(bytes)), "artifact join \(path)")
    }
    static func ref(_ path: String, _ artifacts: [String: Data]) throws -> V {
        guard let bytes = artifacts[path], !bytes.isEmpty else { throw H3QualificationFailure.malformed("missing artifact \(path)") }
        return .object(["path": .string(path), "byte_count": .integer(Int64(bytes.count)), "sha256": .string(H3QualificationProtocol.hash(bytes))])
    }
    static func decode(_ artifacts: [String: Data], _ path: String, schema: String, maximum: Int = 262_144) throws -> V {
        guard let bytes = artifacts[path] else { throw H3QualificationFailure.malformed("missing artifact \(path)") }
        let value = try H3QualificationCanonicalJSON.decode(bytes, maximumBytes: maximum)
        try H3QualificationWire.validate(value, schema: schema)
        return value
    }

    static func outer(_ value: V, enforceClassification: Bool = true) throws {
        try H3QualificationWire.validateStructure(value, schema: "outer_receipt_v1")
        let run = value["run"]!, mode = try mode(run["mode"]), config = try configuration(run["configuration"])
        let nonce = run["nonce"]!.stringValue!, noChild = value["child"]?["disposition"] == .string("NOT_CREATED")
        let gate = value["gate"]!, kill = value["kill"]!, evidence = value["evidence"]!, taxonomy = value["taxonomy"]!
        let deadlines = value["deadlines"]!, stderr = value["stderr"]!
        try require(run["run_id"] == .string(try H3QualificationProtocol.runID(mode: mode, configuration: config, nonce: nonce)), "outer run id")
        try require(value["spawn"]?["argv"] == array([mode == .admissionOnly ? "--h3-qualification-admission-once" : "--h3-qualification-guest-once", nonce]), "outer exact argv")
        try require(gate["gate_frame_sha256"] == .string(H3QualificationProtocol.hash(try H3QualificationProtocol.gateFrame(mode: mode, nonce: nonce))), "outer gate hash")
        var cancellation = Data("EPRH3C01".utf8); cancellation.append(try H3QualificationProtocol.unhex(nonce, bytes: 32))
        try require(gate["cancel_frame_sha256"] == .string(H3QualificationProtocol.hash(cancellation)), "outer cancel hash")
        try H3QualificationWire.validate(value["controller_claim"]!, schema: "controller_identity_claim")
        try code(value["controller_claim"]!["code"]!, app: false, config: config)
        try H3QualificationWire.validate(value["application"]!, schema: noChild ? "outer_application_not_launched" : "outer_application_identity")
        try code(value["application"]!["pre_static"]!, app: true, config: config)
        try regular(evidence["stdout_identity_terminal"]!, executable: false)
        try require(evidence["stdout_identity_terminal"]?["mode"] == .integer(384), "stdout mode")
        let root = evidence["root_identity"]!
        try require(root["owner"] == .integer(501) && root["mode"] == .integer(448) && root["link_count"]!.uintValue! >= 2 && root["inode"]!.uintValue! > 0 && root["device"] == evidence["stdout_identity_terminal"]?["device"], "root identity")
        try require(value["spawn"]?["spawn_return"]?.intValue == (noChild ? value["spawn"]!["spawn_return"]!.intValue! : 0) && (!noChild || value["spawn"]!["spawn_return"]!.intValue! > 0) && taxonomy["app_launched"] == .bool(!noChild), "spawn disposition")
        if !noChild { try child(value["child"]!) }
        try deadline(deadlines, gate: gate, kill: kill, noChild: noChild)
        try require(taxonomy["signals"]?.intValue == (kill["attempted"] == .bool(true) ? 1 : 0), "kill taxonomy")
        if kill["attempted"] == .bool(false) {
            try require(kill["pid"] == value["child"]?["pid"] && kill["return"] == .integer(Int64(Int32.min)) && kill["errno"] == .integer(0), "not-attempted kill")
        } else {
            try require(!noChild && kill["pid"] == value["child"]?["pid"] && ((kill["return"] == .integer(0) && kill["errno"] == .integer(0)) || (kill["return"] == .integer(-1) && kill["errno"]!.intValue! > 0)), "kill result")
        }
        for prefix in ["gate", "cancel"] {
            let writes = gate[prefix + "_writes"]!.intValue!, result = gate[prefix + "_return"]!.intValue!, error = gate[prefix + "_errno"]!.intValue!
            if writes == 0 { try require(result == Int64(Int32.min) && error == 0, "no write sentinel") }
            else { try require((result >= 0 && result <= (prefix == "gate" ? 41 : 40) && error == 0) || (result == -1 && error > 0), "write result tuple") }
        }
        let retained = stderr["retained_byte_count"]!.intValue!, total = stderr["total_byte_count"]!.intValue!
        try require(retained == min(total, 65_536) && stderr["overflow"] == .bool(total > 65_536), "stderr retention tuple")
        if retained == 0 { try require(stderr["retained_sha256"] == .string(emptyHash), "empty stderr hash") }
        if noChild {
            try require(taxonomy["signing_state"] == .string("NOT_ENTERED") && taxonomy["guest_entered_count"] == .integer(0) && taxonomy["hv_vm_created_count"] == .integer(0) && gate["gate_writes"] == .integer(0) && gate["cancel_writes"] == .integer(0) && kill["attempted"] == .bool(false), "no child effects")
            try require(evidence["inner_valid"] == .bool(false) && evidence["inner_eof"] == .bool(true) && evidence["inner_byte_count"] == .integer(0) && evidence["inner_sha256"] == .string(emptyHash) && evidence["hypervisor_support"] == .string("NOT_ENTERED") && evidence["effective_hypervisor_value"] == .string("NOT_OBSERVED") && evidence["effective_entitlements_sha256"] == .string(zeroHash), "no child evidence")
            try require(stderr["eof"] == .bool(true) && total == 0, "no child stderr")
        }
        if enforceClassification {
            let failures = try strings(value["classification"]?["failed_predicates"])
            try require(value["classification"]?["result"] == .string(noChild ? "NO_CHILD_FAILURE" : failures.isEmpty ? "RUN_CANDIDATE_PASS" : "RETAINED_NONPASS"), "outer classification result")
            if noChild { try require(failures == ["runner.spawn"], "no child predicates") }
            else if failures.isEmpty {
                try require(gate["gate_writes"] == .integer(1) && gate["gate_return"] == .integer(41) && gate["gate_errno"] == .integer(0) && gate["cancel_writes"] == .integer(0) && kill["attempted"] == .bool(false) && value["child"]?["exit"] == .integer(0), "candidate outer mechanics")
                try require(evidence["inner_valid"] == .bool(true) && evidence["inner_eof"] == .bool(true) && evidence["inner_byte_count"]!.intValue! > 16 && stderr["eof"] == .bool(true) && total == 0, "candidate transport")
                try require(taxonomy["signing_state"] == .string("ADMITTED") && taxonomy["guest_entered_count"] == .integer(mode == .guest ? 2 : 0) && taxonomy["hv_vm_created_count"] == .integer(mode == .guest ? 2 : 0) && evidence["effective_hypervisor_value"] == .string("TRUE") && evidence["effective_entitlements_sha256"] == value["application"]?["pre_static"]?["entitlements_sha256"] && evidence["hypervisor_support"] == .string(mode == .guest ? "NATIVE_ENTRY_SUCCEEDED" : "NOT_QUERIED"), "candidate admitted effects")
            }
        }
    }
    static func deadline(_ d: V, gate: V, kill: V, noChild: Bool) throws {
        let start = d["spawn_tick"]!.uintValue!, terminal = d["terminal_tick"]!.uintValue!, reap = d["reap_tick"]!.uintValue!
        let numerator = UInt32(d["timebase_numerator"]!.uintValue!), denominator = UInt32(d["timebase_denominator"]!.uintValue!)
        let fixedDeadlines: [(String, UInt64)] = [("gate_deadline_tick", 5), ("operation_deadline_tick", 10), ("kill_deadline_tick", 15), ("terminal_horizon_tick", 20)]
        for (name, seconds) in fixedDeadlines {
            try require(d[name]!.uintValue == H3QualificationDeadline.end(start: start, seconds: seconds, numerator: numerator, denominator: denominator), "fixed outer deadline")
        }
        try require(start <= terminal && terminal <= d["terminal_horizon_tick"]!.uintValue! && (noChild ? reap == 0 : start <= reap && reap <= terminal), "outer terminal chronology")
        let attempt = d["gate_attempt_tick"]!.uintValue!, returned = d["gate_return_tick"]!.uintValue!
        try require(gate["gate_writes"] == .integer(0) ? attempt == 0 && returned == 0 : start <= attempt && attempt <= returned && returned <= d["gate_deadline_tick"]!.uintValue! && returned <= reap, "gate chronology")
        let cancel = d["cancel_tick"]!.uintValue!, killed = d["kill_attempt_tick"]!.uintValue!
        try require(gate["cancel_writes"] == .integer(0) ? cancel == 0 : d["operation_deadline_tick"]!.uintValue! <= cancel && cancel <= reap, "cancel chronology")
        try require(kill["attempted"] == .bool(false) ? killed == 0 : d["kill_deadline_tick"]!.uintValue! <= killed && killed <= reap, "kill chronology")
    }
    static func predicates(_ receipt: V, inner: V?) throws -> [String] {
        try outer(receipt, enforceClassification: false)
        if receipt["child"]?["disposition"] == .string("NOT_CREATED") { try require(inner == nil, "no child inner"); return ["runner.spawn"] }
        let evidence = receipt["evidence"]!, gate = receipt["gate"]!, d = receipt["deadlines"]!, child = receipt["child"]!, run = receipt["run"]!
        let application = receipt["application"]!, taxonomy = receipt["taxonomy"]!, stderr = receipt["stderr"]!
        var conditions: [String: Bool] = [
            "runner.application_identity": true, "runner.build_identity": true, "runner.deadline": true,
            "runner.run_identity": true, "runner.spawn": true,
            "runner.cancellation": gate["cancel_writes"] == .integer(0),
            "runner.signal": receipt["kill"]?["attempted"] == .bool(false) && child["signal"] == .string("NOT_APPLICABLE"),
            "runner.exit": child["exit"] == .integer(0),
            "runner.stderr": stderr["eof"] == .bool(true) && stderr["overflow"] == .bool(false) && stderr["total_byte_count"] == .integer(0),
            "runner.inner_frame": inner != nil && evidence["inner_valid"] == .bool(true) && evidence["inner_eof"] == .bool(true),
            "runner.export": inner != nil && evidence["inner_eof"] == .bool(true) && child["exit"] == .integer(0),
            "runner.gate": gate["gate_writes"] == .integer(1) && gate["gate_return"] == .integer(41) && gate["gate_errno"] == .integer(0)]
        if let inner {
            try H3QualificationWire.validate(inner, schema: "inner_report_v1")
            let frame = try H3QualificationProtocol.frame(payload: inner)
            try require(evidence["inner_valid"] == .bool(true) && evidence["inner_byte_count"]?.intValue == Int64(frame.count) && evidence["inner_sha256"] == .string(H3QualificationProtocol.hash(frame)), "outer exact inner frame")
            if conditions["runner.inner_frame"] != true {
                return sorted(conditions.filter { !$0.value }.map(\.key))
            }
            let effects = inner["effects"]!, signing = inner["signing"]!, timing = inner["timing"]!, monitor = inner["cancellation_monitor"]!
            try require(inner["run"] == run && inner["process"]?["pid"] == child["pid"] && inner["process"]?["bundle_identifier"] == application["pre_static"]?["identifier"] && inner["process"]?["team_identifier"] == application["pre_static"]?["team_identifier"], "outer inner process joins")
            try require(timing["timebase_numerator"] == d["timebase_numerator"] && timing["timebase_denominator"] == d["timebase_denominator"] && d["spawn_tick"]!.uintValue! <= timing["continuous_start_tick"]!.uintValue! && timing["continuous_end_tick"]!.uintValue! <= d["reap_tick"]!.uintValue!, "outer inner clock joins")
            try require(inner["gate"]?["frame_sha256"] == gate["gate_frame_sha256"] && d["gate_attempt_tick"]!.uintValue! <= inner["gate"]!["validated_tick"]!.uintValue!, "outer inner gate joins")
            try require(taxonomy["signing_state"] == signing["status"] && taxonomy["guest_entered_count"] == effects["guest_entered_count"] && taxonomy["hv_vm_created_count"] == effects["hv_vm_created_count"], "outer effect joins")
            let admitted = signing["admitted"] == .bool(true)
            try require(evidence["effective_hypervisor_value"] == .string(admitted ? "TRUE" : "NOT_OBSERVED") && evidence["effective_entitlements_sha256"] == (admitted ? signing["effective_entitlements_sha256"] : .string(zeroHash)), "effective entitlement evidence")
            if admitted { try require(signing["effective_entitlements"] == application["pre_static"]?["entitlements"] && signing["effective_entitlements_sha256"] == application["pre_static"]?["entitlements_sha256"], "wrapper/static entitlements") }
            let mode = try mode(run["mode"]), native = inner["native"]!
            let support: String
            if mode == .admissionOnly { support = "NOT_QUERIED" }
            else if native["disposition"] == .string("NOT_ENTERED") { support = "NOT_ENTERED" }
            else {
                let source = native["source"]!["vm_create_status"]!.intValue!, target = native["target"]!["vm_create_status"]!.intValue!
                support = source == 0 || target == 0 ? "NATIVE_ENTRY_SUCCEEDED" : source != Int64(Int32.min) || target != Int64(Int32.min) ? "NATIVE_ENTRY_FAILED" : "NOT_ENTERED"
            }
            try require(evidence["hypervisor_support"] == .string(support), "hypervisor support derivation")
            conditions["runner.authority_boundary"] = true
            conditions["runner.environment"] = true
            conditions["runner.timing"] = true
            conditions["runner.monitor"] = monitor["disposition"] == .string("COMPLETION_FIRST") && monitor["bytes_observed"] == .integer(0) && monitor["route_calls"] == .integer(0) && monitor["fd_closed"] == .bool(true) && monitor["task_joined"] == .bool(true)
            conditions["application.live_self_signing_admission"] = admitted
            if admitted && mode == .guest {
                conditions["application.h3_preparation"] = effects["reservation_entries"] == .integer(1) && effects["reservation_release_entries"] == .integer(1) && effects["reservation_release_status"] == .integer(0) && native["disposition"] == .string("RETURNED")
                if native["disposition"] == .string("RETURNED") {
                    conditions.merge(try H3QualificationPredicateEvaluator.nativeConditions(capture: .init(wire: native))) { _, _ in false }
                }
            }
        } else {
            try require(evidence["inner_valid"] == .bool(false), "absent decoded inner")
            try require(evidence["hypervisor_support"] == .string("NOT_ENTERED") && evidence["effective_hypervisor_value"] == .string("NOT_OBSERVED") && evidence["effective_entitlements_sha256"] == .string(zeroHash), "absent inner has no effective observations")
        }
        return sorted(conditions.filter { !$0.value }.map(\.key))
    }

    static func dirty(_ value: V) throws {
        let paths = ["Control/hypervisor-local-v1/h2-live-build-plan.v1.json", "Control/hypervisor-local-v1/h2-live-build-wire.schema.v1.json"]
        let hashes = ["b0a73ca324d0c7dc4e9619b549c2c4c85cbcae1e32a021f55d282a7c150470ba", "307e614ca6940bb01a57c625ed8e2a22378269d0fc2c923b86154c2862ac79b1"]
        try require(value["allowed_tracked_dirty"] == .array(zip(paths, hashes).map { .object(["path": .string($0), "sha256": .string($1)]) }) && value["ambient_roots_sha256"] == .string("1aa7745b2bfd2f8840bb6f636c43ef9139ebfce0e10d5cc40c8beb7d305f7db8"), "frozen dirty guard")
    }
    static func source(_ value: V) throws {
        let paths = try strings(value["delta_paths"]), pins = value["delta_path_pins"]!.arrayValue!
        try require(value["freeze_commit"] == .string(freeze) && value["freeze_tree"] == .string("fc44ef370d3ff8888e4dfecbc3901fc0ec1a5600") && value["implementation_commit"] != value["freeze_commit"] && value["implementation_tree"] != value["freeze_tree"], "frozen source ancestry identities")
        try require(pins.map { $0["path"]!.stringValue! } == paths, "delta pin order")
        let frozen = h3QualificationExternalContract["pins"]!.arrayValue!.filter { !paths.contains($0["path"]!.stringValue!) }.map { V.object(["path": $0["path"]!, "sha256": $0["sha256"]!]) }
        try require(value["frozen_input_pins"] == .array(frozen), "frozen input pins")
        // These are an implementation contract, not merely a permissible delta.
        // A missing effect owner or shared protocol is not a runnable variant.
        for required in ["Sources/H3QualificationProtocol.swift", "Sources/H3QualificationCoordinator.swift", "Tools/H3QualificationSeal/h3_qualification_seal.rb", "Tools/H3QualificationController/main.swift", "Tools/H3QualificationController/H3QualificationControllerPolicy.swift", "Tools/H3QualificationController/H3QualificationProcess.swift", "Tools/H3QualificationController/H3QualificationSigning.swift", "Tools/H3QualificationController/H3QualificationStorage.swift", "Tests/H3QualificationRunnerTests.swift", "ErgenticsProvenance.xcodeproj/xcshareddata/xcschemes/ErgenticsProvenanceH3Qualification.xcscheme"] {
            try require(paths.contains(required), "missing qualification source")
        }
    }
    struct GitLeaf: Equatable { let mode: String; let oid: String }
    struct GitDelta { let path: String; let old: GitLeaf?; let new: GitLeaf }
    static func nulRecords(_ data: Data) throws -> [String] {
        guard data.last == 0, let text = String(data: data, encoding: .utf8) else { throw H3QualificationFailure.malformed("raw Git framing") }
        return text.dropLast().components(separatedBy: "\0")
    }
    static func path(_ text: String) throws {
        try require(!text.isEmpty && text.utf8.count <= 4096 && !text.hasPrefix("/") && text.utf8.allSatisfy { $0 >= 32 && $0 < 127 && $0 != 92 }, "raw Git path")
        let components = text.components(separatedBy: "/")
        try require(components.count <= 8 && components.allSatisfy { !$0.isEmpty && $0 != "." && $0 != ".." }, "raw Git path component")
    }
    static func oid(_ text: String, absent: Bool = false) throws {
        _ = try H3QualificationProtocol.unhex(text, bytes: 20)
        try require(absent || text != String(repeating: "0", count: 40), "zero Git OID")
    }
    static func listing(_ bytes: Data, index: Bool = false) throws -> [(String, GitLeaf)] {
        let records = try nulRecords(bytes)
        try require((2...254).contains(records.count), "tree entry bound")
        var result: [(String, GitLeaf)] = []
        for record in records {
            let parts = record.components(separatedBy: "\t")
            try require(parts.count == 2, "Git listing tab")
            let fields = parts[0].components(separatedBy: " ")
            try require(fields.count == 3 && ["100644", "100755"].contains(fields[0]) && fields[index ? 2 : 1] == (index ? "0" : "blob"), "Git listing tuple")
            try path(parts[1]); let hash = fields[index ? 1 : 2]; try oid(hash)
            result.append((parts[1], GitLeaf(mode: fields[0], oid: hash)))
        }
        try require(Set(result.map(\.0)).count == result.count, "duplicate Git leaf")
        _ = try tree(result) // Also validates prefix collisions and ordering.
        return result
    }
    static func deltas(_ bytes: Data) throws -> [GitDelta] {
        let records = try nulRecords(bytes)
        try require(!records.isEmpty && records.count <= 34 && records.count % 2 == 0, "delta framing")
        var result: [GitDelta] = []
        for index in stride(from: 0, to: records.count, by: 2) {
            let header = records[index].components(separatedBy: " "), name = records[index + 1]
            try require(header.count == 5 && header[0].hasPrefix(":"), "delta header")
            try path(name)
            let oldMode = String(header[0].dropFirst()), newMode = header[1], oldOID = header[2], newOID = header[3], status = header[4]
            try oid(oldOID, absent: true); try oid(newOID)
            try require(["100644", "100755"].contains(newMode), "delta new mode")
            let previous: GitLeaf?
            if status == "A" { try require(oldMode == "000000" && oldOID == String(repeating: "0", count: 40), "delta addition"); previous = nil }
            else { try require(status == "M" && ["100644", "100755"].contains(oldMode) && oldOID != String(repeating: "0", count: 40) && (oldMode != newMode || oldOID != newOID), "delta modification"); previous = .init(mode: oldMode, oid: oldOID) }
            result.append(.init(path: name, old: previous, new: .init(mode: newMode, oid: newOID)))
        }
        try require(result.map(\.path) == sorted(result.map(\.path)) && Set(result.map(\.path)).count == result.count, "delta order")
        return result
    }
    static func tree(_ leaves: [(String, GitLeaf)], requireOrder: Bool = true) throws -> String {
        try treeDetails(leaves, requireOrder: requireOrder).root
    }
    static func treeDetails(_ leaves: [(String, GitLeaf)], requireOrder: Bool = true) throws -> (root: String, summary: V) {
        // All paths are depth-bounded by their 4096-byte wire bound. Build a
        // flat directory map then hash bottom-up; no recursion or Git execution.
        var directories: [String: [(String, GitLeaf)]] = ["": []]
        var pathSet = Set<String>()
        for (name, leaf) in leaves {
            try path(name); try require(pathSet.insert(name).inserted, "duplicate leaf")
            let pieces = name.components(separatedBy: "/")
            var parent = ""
            for component in pieces.dropLast() {
                parent = parent.isEmpty ? component : parent + "/" + component
                if directories[parent] == nil {
                    try require(directories.count < 1779, "tree directory allocation bound")
                    directories[parent] = []
                }
            }
            directories[parent, default: []].append((pieces.last!, leaf))
        }
        try require(directories.count <= 1779 && directories.keys.allSatisfy { !pathSet.contains($0) }, "tree prefix collision/bound")
        var hashes: [String: String] = [:], traversal: [String] = [], treeRecords: [V] = []
        let directoryOrder = directories.keys.sorted { $0.components(separatedBy: "/").count > $1.components(separatedBy: "/").count || ($0.components(separatedBy: "/").count == $1.components(separatedBy: "/").count && $0 > $1) }
        for directory in directoryOrder {
            var entries = directories[directory]!.map { (name: $0.0, mode: $0.1.mode, oid: $0.1.oid, directory: false) }
            for (child, hash) in hashes {
                let components = child.components(separatedBy: "/"), parent = components.dropLast().joined(separator: "/")
                if parent == directory { entries.append((components.last!, "40000", hash, true)) }
            }
            entries.sort { Array(($0.name + ($0.directory ? "/" : "")).utf8).lexicographicallyPrecedes(Array(($1.name + ($1.directory ? "/" : "")).utf8)) }
            var bytes = Data()
            for entry in entries {
                bytes.append(contentsOf: (entry.mode + " " + entry.name).utf8); bytes.append(0)
                bytes.append(try H3QualificationProtocol.unhex(entry.oid, bytes: 20))
            }
            var framed = Data(("tree " + String(bytes.count)).utf8); framed.append(0); framed.append(bytes)
            hashes[directory] = Insecure.SHA1.hash(data: framed).map { String(format: "%02x", $0) }.joined()
            treeRecords.append(.object(["oid": .string(hashes[directory]!), "path": .string(directory), "payload_byte_count": .integer(Int64(bytes.count)), "payload_sha256": .string(H3QualificationProtocol.hash(bytes))]))
        }
        if requireOrder {
            // Git's recursive tree order is a depth-first traversal with each
            // directory component compared as if followed by '/'.
            var pending: [String] = [""]
            while let directory = pending.popLast() {
                if directory.hasPrefix("\0") { traversal.append(String(directory.dropFirst())); continue }
                let directLeaves = directories[directory]!.map { (path: directory.isEmpty ? $0.0 : directory + "/" + $0.0, order: $0.0, directory: false) }
                let childDirs = directories.keys.filter { !$0.isEmpty && $0.components(separatedBy: "/").dropLast().joined(separator: "/") == directory }.map { (path: $0, order: $0.components(separatedBy: "/").last! + "/", directory: true) }
                // Work items use a reserved prefix impossible in admitted paths.
                let entries = (directLeaves + childDirs).sorted { $0.order.utf8.lexicographicallyPrecedes($1.order.utf8) }
                for entry in entries.reversed() { pending.append(entry.directory ? entry.path : "\0" + entry.path) }
            }
            try require(traversal == leaves.map(\.0), "Git tree traversal order")
        }
        guard let root = hashes[""] else { throw H3QualificationFailure.malformed("missing tree root") }
        treeRecords.sort { $0["path"]!.stringValue!.utf8.lexicographicallyPrecedes($1["path"]!.stringValue!.utf8) }
        let digest = H3QualificationProtocol.hash(try H3QualificationCanonicalJSON.encode(.array(treeRecords), maximumBytes: 262_144))
        return (root, .object(["blob_count": .integer(Int64(leaves.count)), "root_oid": .string(root), "subtree_count": .integer(Int64(directories.count)), "trees_sha256": .string(digest)]))
    }
    static func sourceState(_ value: V) throws {
        try source(value["source"]!); try dirty(value["dirty_guard"]!)
        let source = value["source"]!, probes = value["probes"]!.arrayValue!, implementation = source["implementation_commit"]!.stringValue!
        let templates = h3QualificationExternalContract["source_argv"]!.arrayValue!
        for index in probes.indices {
            let expected = try strings(templates[index]).map { $0.replacingOccurrences(of: "<freeze_commit>", with: freeze).replacingOccurrences(of: "<implementation_commit>", with: implementation) }
            try require(probes[index]["argv"] == array(expected) && probes[index]["cwd"] == .string(repository), "source invocation order")
            if index != 7 { _ = try stream(probes[index]["stderr"]!, empty: true); _ = try stream(probes[index]["stdout"]!) }
        }
        for (index, key) in ["implementation_commit", "implementation_tree", "freeze_tree"].enumerated() {
            try require(try stream(probes[index]["stdout"]!) == Data((source[key]!.stringValue! + "\n").utf8), "source rev-parse join")
        }
        let listed = try listing(stream(probes[6]["stdout"]!)), indexed = try listing(stream(probes[8]["stdout"]!), index: true)
        try require(listed.map(\.0) == indexed.map(\.0) && listed.map(\.1) == indexed.map(\.1), "raw index equals tree")
        let changes = try deltas(stream(probes[4]["stdout"]!)), freezeChange = try deltas(stream(probes[3]["stdout"]!))
        let names = try nulRecords(stream(probes[5]["stdout"]!))
        try require(names == changes.map(\.path) && array(names) == source["delta_paths"], "source delta/name join")
        let freezePath = "Control/hypervisor-local-v1/h3-signed-application-qualification-runner-freeze-2026-09-04.v1.json"
        try require(freezeChange.count == 1 && freezeChange[0].path == freezePath && freezeChange[0].old == nil && freezeChange[0].new.mode == "100644" && freezeChange[0].new.oid == "75884c075c2b27a7882d35c4dd33375dd09c33b3", "sole freeze addition")
        var flat = Dictionary(uniqueKeysWithValues: listed)
        func reverse(_ deltas: [GitDelta]) throws {
            for delta in deltas.reversed() {
                try require(flat[delta.path] == delta.new, "reverse delta leaf")
                if let old = delta.old { flat[delta.path] = old } else { flat.removeValue(forKey: delta.path) }
            }
        }
        let implementationDetails = try treeDetails(listed), implementationTree = implementationDetails.root
        try reverse(changes); let freezeDetails = try treeDetails(flat.map { ($0.key, $0.value) }, requireOrder: false), freezeTree = freezeDetails.root
        try reverse(freezeChange); let predecessorDetails = try treeDetails(flat.map { ($0.key, $0.value) }, requireOrder: false), predecessorTree = predecessorDetails.root
        try require(source["implementation_tree"] == .string(implementationTree) && source["freeze_tree"] == .string(freezeTree) && predecessorTree == "829331092cdc290f1a0e651fd64a9a56dd4187d2", "reconstructed Git roots")
        let batch = probes[7]
        let snapshots = [("PREDECESSOR", predecessorDetails.summary), ("FREEZE", freezeDetails.summary), ("IMPLEMENTATION", implementationDetails.summary)].map { name, summary -> V in
            var fields = summary.objectValue!; fields["snapshot"] = .string(name); return .object(fields)
        }
        try require(batch["tree_reconstruction_join_sha256"] == .string(H3QualificationProtocol.hash(try H3QualificationCanonicalJSON.encode(.array(snapshots), maximumBytes: 262_144))), "reconstructed tree aggregate")
        try require(batch["entry_count"]?.intValue == Int64(listed.count) && batch["clean_match_count"]?.intValue == Int64(listed.count - 2) && batch["listing_sha256"] == probes[6]["stdout"]?["sha256"], "batch listing count")
        var request = Data((implementation + "\n" + freeze + "\n").utf8)
        for (_, leaf) in listed { request.append(contentsOf: (leaf.oid + "\n").utf8) }
        request.append(contentsOf: "b5fd9b2e1c72f54924269b6ff9453f87abeae5f2\n".utf8)
        try require(batch["request_byte_count"]?.intValue == Int64(request.count) && batch["request_sha256"] == .string(H3QualificationProtocol.hash(request)), "batch request bytes")
        for prefix in ["implementation", "freeze"] {
            try require(batch[prefix + "_commit_recomputed_oid"] == source[prefix + "_commit"] && batch[prefix + "_commit_tree"] == source[prefix + "_tree"] && batch[prefix + "_reconstructed_tree"] == source[prefix + "_tree"], "batch commit/tree joins")
        }
        try require(batch["implementation_commit_parent"] == source["freeze_commit"], "sole implementation parent")
        _ = try stream(batch["stderr"]!, empty: true)
    }
    static func lines(_ bytes: Data) throws -> [String] {
        guard let text = String(data: bytes, encoding: .utf8), !text.contains("\0"), text.isEmpty || text.hasSuffix("\n") else { throw H3QualificationFailure.malformed("probe lines") }
        return text.isEmpty ? [] : text.dropLast().components(separatedBy: "\n")
    }
    static func match(_ text: String, _ pattern: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern), let result = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)), result.range.length == text.utf16.count else { return nil }
        return (0..<result.numberOfRanges).map { index in Range(result.range(at: index), in: text).map { String(text[$0]) } ?? "" }
    }
    static func metadata(_ lines: [String], _ field: String) throws -> String {
        let values = lines.filter { $0.hasPrefix(field + "=") }.map { String($0.dropFirst(field.count + 1)) }
        try require(values.count == 1 && !values[0].isEmpty, "unique codesign \(field)")
        return values[0]
    }
    static func probe(_ value: V, argv: V, cwd: String = "/private/var/empty") throws -> (Data, Data) {
        try H3QualificationWire.validateStructure(value, schema: "command_probe")
        try require(value["argv"] == argv && value["cwd"] == .string(cwd), "probe invocation")
        return try (stream(value["stdout"]!), stream(value["stderr"]!))
    }
    static func toolchain(_ value: V) throws {
        let probes = value["probes"]!.arrayValue!, argv = h3QualificationExternalContract["toolchain_argv"]!.arrayValue!
        var captured: [(Data, Data)] = []
        for index in probes.indices { captured.append(try probe(probes[index], argv: argv[index])) }
        for index in [0, 1, 2, 3, 4, 6, 8, 9] { try require(captured[index].1.isEmpty, "toolchain stderr") }
        let exact: [Int: String] = [0: "Xcode 26.6\nBuild version 17F113\n", 1: "26.5\n", 3: "ruby 2.6.10p210 (2022-04-12 revision 67958) [universal.arm64e-darwin25]\n", 8: "25G83\n", 9: "arm64\n"]
        for (index, text) in exact { try require(captured[index].0 == Data(text.utf8), "toolchain output pin") }
        let swift = try lines(captured[2].0)
        let version = "Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)", target = "Target: arm64-apple-macosx26.0", driver = "swift-driver version: 1.148.6"
        try require(swift == [driver + " " + version, target] || swift == [driver, version, target], "Swift toolchain pin")
        for (index, prefix, path) in [(4, "seal_runtime", "/usr/bin/ruby"), (6, "seal_launcher", "/usr/bin/env")] {
            try require(captured[index].0 == Data((value[prefix + "_sha256"]!.stringValue! + "  " + path + "\n").utf8) && captured[index + 1].0.isEmpty, "platform hash probe")
            let observed = try lines(captured[index + 1].1)
            try require(try metadata(observed, "Executable") == path && metadata(observed, "Identifier") == value[prefix + "_identifier"]!.stringValue! && metadata(observed, "CDHash") == value[prefix + "_cdhash"]!.stringValue!, "platform codesign pin")
        }
    }
    static func requirement(_ text: String, app: Bool, leafAuthority: String) throws {
        try require(!text.isEmpty && text.utf8.count <= 256 && !text.unicodeScalars.contains { $0.value < 32 || $0.value == 127 }, "raw designated requirement text256")
        let anchor = "anchor apple generic", identifier = "identifier \"\(app ? appID : controllerID)\""
        let intermediate = "certificate 1[field.1.2.840.113635.100.6.2.1] /* exists */"
        let leafExtension = "certificate leaf[field.1.2.840.113635.100.6.1.2] /* exists */"
        let ou = "certificate leaf[subject.OU] = \"\(team)\""
        var required = [anchor, identifier, ou], optional = [intermediate, leafExtension]
        var lexicalText = text
        // The observed DR may identify the development certificate by CN. This
        // is not our separately evaluated Apple + identifier + OU Security rule.
        // Match the observed leaf Authority, not a pinned person's display name.
        // Unsupported quote/backslash escaping fails closed. The temporary
        // marker keeps a quoted name containing " and " intact for tokenization;
        // the original text is retained byte-for-byte in the product claim.
        let cn = "certificate leaf[subject.CN] = \"\(leafAuthority)\""
        if leafAuthority.hasPrefix("Apple Development: "),
           !leafAuthority.dropFirst(19).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !leafAuthority.contains("\""), !leafAuthority.contains("\\"),
           let cnRange = text.range(of: cn, options: .literal) {
            let marker = "\0H3_CAPTURED_LEAF_CN\0" // Impossible in admitted raw text.
            try require(text.range(of: cn, options: .literal, range: cnRange.upperBound..<text.endIndex) == nil, "one observed CN clause")
            lexicalText = text.replacingCharacters(in: cnRange, with: marker)
            required = [anchor, identifier, marker, intermediate]; optional = [leafExtension]
        }
        let clauses = lexicalText.components(separatedBy: " and ")
        try require(Set(clauses).count == clauses.count && required.allSatisfy(clauses.contains) && clauses.allSatisfy((required + optional).contains), "raw designated requirement closed identity conjunction")
    }
    static func entitlementEncodings(_ sourceLines: [String]) throws -> [V] {
        let source = sourceLines.filter { !$0.hasPrefix("designated => ") }
        var results: [V] = []
        if let beginning = source.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == "[Dict]" }) {
            let tail = source.dropFirst(beginning + 1).map { $0.trimmingCharacters(in: .whitespaces) }
            try require(tail.count % 3 == 0 && tail.count <= 24, "entitlement text bound/framing")
            var values: [String: V] = [:]
            for index in stride(from: 0, to: tail.count, by: 3) {
                guard let key = match(tail[index], #"\[Key\] ([A-Za-z0-9.-]+)"#)?[1] else { throw H3QualificationFailure.malformed("entitlement key") }
                try require(values[key] == nil && tail[index + 1] == "[Value]" && ["[Bool] true", "[Bool] false"].contains(tail[index + 2]), "entitlement scalar/duplicate")
                values[key] = .bool(tail[index + 2] == "[Bool] true")
            }
            results.append(.object(values))
        }
        let text = source.joined(separator: "\n") + "\n"
        if let beginning = text.range(of: "<?xml")?.lowerBound ?? text.range(of: "<plist")?.lowerBound {
            var xml = String(text[beginning...]).trimmingCharacters(in: .whitespacesAndNewlines)
            for prefix in ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>", "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"] {
                if xml.hasPrefix(prefix) { xml = String(xml.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines) }
            }
            guard xml.hasPrefix("<plist version=\"1.0\">") && xml.hasSuffix("</plist>") else { throw H3QualificationFailure.malformed("entitlement XML envelope") }
            xml = String(xml.dropFirst("<plist version=\"1.0\">".count).dropLast("</plist>".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            if xml == "<dict/>" { results.append(.object([:])) }
            else {
                try require(xml.hasPrefix("<dict>") && xml.hasSuffix("</dict>"), "entitlement XML dictionary")
                var body = String(xml.dropFirst(6).dropLast(7)).trimmingCharacters(in: .whitespacesAndNewlines), values: [String: V] = [:]
                while !body.isEmpty {
                    try require(values.count < 8 && body.hasPrefix("<key>"), "entitlement XML count/key")
                    guard let keyEnd = body.range(of: "</key>") else { throw H3QualificationFailure.malformed("entitlement XML key close") }
                    let key = String(body[body.index(body.startIndex, offsetBy: 5)..<keyEnd.lowerBound])
                    try require(match(key, #"[A-Za-z0-9.-]+"#) != nil && values[key] == nil, "entitlement XML key grammar/duplicate")
                    body = String(body[keyEnd.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                    let token = body.hasPrefix("<true/>") ? "<true/>" : "<false/>"
                    try require(body.hasPrefix(token), "entitlement XML boolean")
                    values[key] = .bool(token == "<true/>"); body = String(body.dropFirst(token.count)).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                results.append(.object(values))
            }
        }
        return results
    }
    static func productClaim(_ probes: ArraySlice<V>, config: H3QualificationConfiguration, app: Bool) throws -> V {
        let codePath = productPath(config, app: app, code: true), executable = productPath(config, app: app)
        let templates = h3QualificationExternalContract["product_argv"]!.arrayValue!
        var captured: [(Data, Data)] = []
        for (index, item) in probes.enumerated() {
            let argv = try strings(templates[index]).map { $0.replacingOccurrences(of: "<product_executable>", with: executable).replacingOccurrences(of: "<product_bundle_or_executable>", with: codePath) }
            captured.append(try probe(item, argv: array(argv)))
        }
        try require(captured.count == 6, "product probe count")
        for index in [0, 1, 4, 5] { try require(captured[index].1.isEmpty, "product stderr") }
        let hashLines = try lines(captured[0].0), uuidLines = try lines(captured[1].0)
        guard hashLines.count == 1, hashLines[0].hasSuffix("  " + executable), hashLines[0].utf8.count == 66 + executable.utf8.count,
              uuidLines.count == 1, let uuid = match(uuidLines[0], #"UUID: ([0-9a-fA-F-]{36}) \(arm64\) (.+)"#), uuid[2] == executable else { throw H3QualificationFailure.malformed("product hash/UUID probe") }
        let hash = String(hashLines[0].prefix(64)); _ = try H3QualificationProtocol.unhex(hash, bytes: 32)
        try require(captured[2].0.isEmpty && (captured[2].1.isEmpty || captured[2].1 == Data((codePath + ": valid on disk\n" + codePath + ": satisfies its Designated Requirement\n").utf8)), "strict codesign verification")
        let meta = try lines(captured[3].1), output = try lines(captured[3].0)
        let identifier = app ? appID : controllerID
        try require(try metadata(meta, "Executable") == executable && metadata(meta, "Identifier") == identifier && metadata(meta, "TeamIdentifier") == team, "product metadata identity")
        let cdhash = try metadata(meta, "CDHash")
        let directories = meta.filter { $0.hasPrefix("CodeDirectory ") }
        try require(directories.count == 1 && match(directories[0], #"CodeDirectory v=[0-9]+ size=[0-9]+ flags=0x10000\(runtime\) hashes=[0-9]+\+[0-9]+ location=embedded"#) != nil, "runtime CodeDirectory")
        let authorities = meta.filter { $0.hasPrefix("Authority=") }.map { String($0.dropFirst(10)) }
        try require(authorities.count == 3 && authorities[0].hasPrefix("Apple Development: ") && authorities[1] == "Apple Worldwide Developer Relations Certification Authority" && authorities[2] == "Apple Root CA", "Apple Development certificate chain")
        let requirements = (meta + output).filter { $0.hasPrefix("designated => ") }.map { String($0.dropFirst(14)) }
        try require(requirements.count == 1, "one designated requirement")
        try requirement(requirements[0], app: app, leafAuthority: authorities[0])
        let encodings = try entitlementEncodings(meta) + entitlementEncodings(output)
        try require(encodings.count <= 1, "multiple entitlement encodings")
        let entitlements: V
        if app {
            guard let first = encodings.first else { throw H3QualificationFailure.malformed("missing app entitlement blob") }
            try H3QualificationWire.validateStructure(first, schema: "effective_entitlements"); entitlements = first
        } else { try require(encodings.isEmpty || encodings == [.object([:])], "controller entitlement blob"); entitlements = .null }
        let loads = try lines(captured[4].0), symbols = try lines(captured[5].0)
        try require(loads.first == executable + ":", "load command header")
        for line in loads.dropFirst() { try require(match(line, #"\t[^\t\r\n]+ \(compatibility version [0-9.]+, current version [0-9.]+(?:, weak)?\)"#) != nil, "load command grammar") }
        for line in symbols { try require(match(line, #"[A-Za-z_$][A-Za-z0-9_.$]*"#) != nil, "symbol grammar") }
        if !app { try require(!loads.contains { $0.contains("Hypervisor.framework") || $0.contains("/Hypervisor ") } && !symbols.contains { $0.hasPrefix("hv_") || $0.hasPrefix("_hv_") }, "controller Hypervisor exclusion") }
        let result: V = .object(["cdhash": .string(cdhash), "code_object_path": .string(codePath), "designated_requirement": .string(requirements[0]), "entitlements": entitlements, "entitlements_sha256": .string(H3QualificationProtocol.hash(try H3QualificationCanonicalJSON.encode(entitlements))), "executable_path": .string(executable), "executable_sha256": .string(hash), "identifier": .string(identifier), "macho_uuid": .string(uuid[1].lowercased()), "runtime": .bool(true), "team_identifier": .string(team), "valid": .bool(true)])
        try code(result, app: app, config: config)
        return result
    }
    static func productAudit(_ value: V) throws {
        let config = try configuration(value["configuration"]), probes = value["probes"]!.arrayValue!
        // Swift String equality admits canonically equivalent Unicode. Product
        // observations require exact canonical JSON bytes, including raw DR text.
        let application = try productClaim(probes[0..<6], config: config, app: true)
        let controller = try productClaim(probes[6..<12], config: config, app: false)
        try require(H3QualificationProtocol.sameCodeIdentity(value["application"], application) && H3QualificationProtocol.sameCodeIdentity(value["controller"], controller), "raw product claim derivation")
    }
    static func buildRecord(_ value: V) throws {
        let config = try configuration(value["configuration"]), prefix = config == .debug ? "debug" : "release"
        let argv = h3QualificationExternalContract["build_" + prefix]!
        try require(value["argv"] == argv && value["settings_argv"] == .array(argv.arrayValue! + [.string("-showBuildSettings"), .string("-json")]) && value["derived_data_path"] == .string("/private/tmp/ergentics-h3q-\(prefix)-v1"), "frozen build argv/path")
        for (key, count, seconds) in [("build_process", 1, 900), ("settings_process", 2, 120)] {
            let process = value[key]!
            try H3QualificationWire.validate(process, schema: "successful_external_process_result")
            let start = process["spawn_tick"]!.uintValue!, (deadline, overflow) = start.addingReportingOverflow(UInt64(seconds) * 1_000_000_000)
            try require(!overflow && process["operation_deadline_tick"]!.uintValue == deadline && process["required_pipe_eof_count"] == .integer(Int64(count)), "build process horizon")
        }
        _ = try stream(value["settings_stderr"]!, empty: true)
    }
    static func settings(_ bytes: Data, configuration: H3QualificationConfiguration) throws {
        let value = try H3QualificationCanonicalJSON.decodeBuildSettings(bytes)
        guard let records = value.arrayValue, records.count == 2 else { throw H3QualificationFailure.malformed("settings target count") }
        let contract = h3QualificationExternalContract["settings"]!
        var targets = Set<String>()
        for record in records {
            guard let object = record.objectValue, Set(object.keys) == ["action", "buildSettings", "target"], let target = record["target"]?.stringValue, let fields = record["buildSettings"]?.objectValue else { throw H3QualificationFailure.malformed("settings record") }
            try require(record["action"] == .string("build") && targets.insert(target).inserted && ["ErgenticsProvenance", controllerName].contains(target), "settings target/action")
            for (key, value) in fields { try require(key.utf8.count <= 1024 && value.stringValue != nil, "settings string map") }
            var expected = contract["required_common_settings"]!.objectValue!
            expected.merge(contract["configuration_settings"]![configuration.rawValue]!.objectValue!) { _, value in value }
            expected.merge(contract[target == controllerName ? "controller_settings" : "application_settings"]!.objectValue!) { _, value in value }
            for (key, expected) in expected {
                if expected == .string("ABSENT_KEY") { try require(fields[key] == nil, "settings absent key") }
                else if key == "SWIFT_ACTIVE_COMPILATION_CONDITIONS" {
                    guard let actual = fields[key]?.stringValue else { throw H3QualificationFailure.malformed("settings conditions") }
                    let tokens = actual.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init)
                    let required = expected.stringValue!.components(separatedBy: " ")
                    try require(Set(tokens) == Set(required) && tokens.count == required.count, "qualification conditions")
                } else { try require(fields[key] == expected, "settings required \(key)") }
            }
            try require(fields["BUILT_PRODUCTS_DIR"] == fields["TARGET_BUILD_DIR"] && fields["CONFIGURATION_BUILD_DIR"] == fields["TARGET_BUILD_DIR"], "settings product directory joins")
        }
    }
    static func manifest(_ value: V) throws {
        try source(value["source"]!); try dirty(value["dirty_guard"]!); try toolchain(value["toolchain"]!)
        try require(value["source_state"] == value["artifacts"]?["source_state"], "manifest source reference")
        for (index, config) in H3QualificationConfiguration.allCases.enumerated() {
            let build = value["builds"]!.arrayValue![index], product = value["products"]!.arrayValue![index], prefix = config == .debug ? "debug" : "release"
            try require(build["configuration"] == .string(config.rawValue) && product["configuration"] == build["configuration"], "manifest configuration order")
            try buildRecord(build); try H3QualificationWire.validate(product, schema: "product_pair")
            for (field, artifact) in [("build_log", prefix + "_build_log"), ("settings", prefix + "_build_settings"), ("product_audit", prefix + "_product_audit")] { try require(build[field] == value["artifacts"]?[artifact], "build artifact reference") }
            try require(product["audit"] == build["product_audit"], "product audit reference")
        }
        let references = value["artifacts"]!.objectValue!
        for (key, ref) in references {
            let path = key.hasSuffix("build_log") ? String(key.prefix(while: { $0 != "_" })) + "-build.log" : key.replacingOccurrences(of: "_", with: "-") + ".json"
            try require(ref["path"] == .string(path) && ref["byte_count"]!.intValue! <= (key.hasSuffix("build_log") ? 8_388_608 : key.hasSuffix("build_settings") ? 1_048_576 : 262_144), "fixed artifact reference")
        }
    }
    static func supervisor(_ value: V) throws {
        let name = value["mode"]!.stringValue!, guest = name.contains("GUEST"), verifying = name.hasPrefix("VERIFY_")
        let mode: H3QualificationMode = guest ? .guest : .admissionOnly
        let config: H3QualificationConfiguration = verifying || name.hasSuffix("RELEASE") ? .release : .debug
        let prefix = config == .debug ? "debug" : "release", campaign = guest ? "GUEST" : "ADMISSION"
        let rootPath = root(mode) + (verifying ? "" : "/" + prefix)
        let expectedArgument = verifying ? (guest ? "--verify-guest-campaign" : "--verify-admission-campaign") : (guest ? "--guest" : "--admission-only")
        try require(value["argv"] == array([productPath(config, app: false), expectedArgument, rootPath]) && value["campaign"] == .string(campaign) && value["configuration"] == (verifying ? .null : .string(config.rawValue)), "supervisor mode/argv")
        try H3QualificationWire.validate(value["process"]!, schema: "supervised_controller_process_result")
        let process = value["process"]!, (deadline, overflow) = process["spawn_tick"]!.uintValue!.addingReportingOverflow(verifying ? 120_000_000_000 : 60_000_000_000)
        try require(!overflow && process["operation_deadline_tick"]!.uintValue == deadline, "supervisor fixed deadline")
        try require(value["controller_executable_before"] == value["controller_executable_after"] && value["evidence_root_before"] == value["evidence_root_after_child"], "supervisor before/after identity")
        try H3QualificationWire.validate(value["controller_executable_before"]!, schema: "seal_held_named_path_identity")
        try H3QualificationWire.validate(value["evidence_root_before"]!, schema: "seal_held_named_directory_identity")
        try require(value["controller_executable_before"]?["held"]?["path"] == .string(productPath(config, app: false)) && value["evidence_root_before"]?["held"]?["path"] == .string(rootPath), "supervisor fixed named paths")
        let result = value["result"]!.stringValue!
        try require(process["exit_status"] == .integer(result == "RETAINED_NONPASS" || result == "FAIL_H3_GUEST_CAMPAIGN" ? 65 : 0), "supervisor result/exit")
        for (key, path) in [("build_source_manifest", "build-source-manifest.json"), ("source_state", "source-state.json"), ("controller_product_audit", prefix + "-product-audit.json")] {
            try require(value[key]?["path"] == .string(path) && value[key]!["byte_count"]!.intValue! <= 262_144, "supervisor fixed reference")
        }
        if verifying {
            let checkpoint = guest ? "guest-campaign-checkpoint.json" : "admission-campaign-checkpoint.json"
            let before = sorted(prelaunch + (guest ? prior : []) + ["debug", "release"])
            try require(value["inventory_before"] == array(before) && value["inventory_after_child"] == array(sorted(before + [checkpoint])) && value["campaign_checkpoint"]?["path"] == .string(checkpoint) && value["outer_receipt"] == .null && value["run_manifest"] == .null, "verifier inventory/references")
            try require(result == (guest ? "PASS_H3_GUEST_CAMPAIGN" : "PASS_ADMISSION_CAMPAIGN") || (guest && result == "FAIL_H3_GUEST_CAMPAIGN"), "verifier result role")
        } else {
            try require(value["inventory_before"] == .array([]) && value["inventory_after_child"] == array(sorted(leaves)) && value["campaign_checkpoint"] == .null && value["outer_receipt"]?["path"] == .string("outer-observer-receipt.json") && value["run_manifest"]?["path"] == .string("manifest.json"), "run inventory/references")
            try require(result == "RUN_CANDIDATE_PASS" || result == "RETAINED_NONPASS", "run result role")
        }
    }
    static func checkpoint(_ value: V) throws {
        let guest = value["campaign"] == .string("GUEST"), result = value["result"]!.stringValue!
        try require(result == (guest ? "PASS_H3_GUEST_CAMPAIGN" : "PASS_ADMISSION_CAMPAIGN") || (guest && result == "FAIL_H3_GUEST_CAMPAIGN"), "checkpoint result mode")
        try require(guest ? value["prior_admission"] != .null : value["prior_admission"] == .null, "prior closure mode")
        try H3QualificationWire.validate(value["verifier"]!, schema: "controller_identity_claim")
        try code(value["verifier"]!["code"]!, app: false, config: .release)
        let runs = value["runs"]!.arrayValue!
        for (index, config) in H3QualificationConfiguration.allCases.enumerated() {
            let run = runs[index], prefix = config == .debug ? "debug" : "release"
            try require(run["configuration"] == .string(config.rawValue) && run["run_id"] == .string(try H3QualificationProtocol.runID(mode: guest ? .guest : .admissionOnly, configuration: config, nonce: run["nonce"]!.stringValue!)), "checkpoint run identity")
            for (key, name) in [("manifest", "manifest.json"), ("receipt", "outer-observer-receipt.json"), ("supervisor", "seal-supervisor-receipt.json")] { try require(run[key]?["path"] == .string(prefix + "/" + name), "checkpoint run path") }
        }
        try require(runs[0]["nonce"] != runs[1]["nonce"] && runs[0]["run_id"] != runs[1]["run_id"], "distinct campaign nonces")
        let aggregates = value["aggregates"]!, taxonomy = value["taxonomy"]!
        try require(aggregates["guest_entries"] == taxonomy["guest_entered_count"] && aggregates["hv_vm_creates"] == taxonomy["hv_vm_created_count"], "campaign aggregate taxonomy")
        if result != "FAIL_H3_GUEST_CAMPAIGN" {
            try require(aggregates["guest_entries"] == .integer(guest ? 4 : 0) && aggregates["hv_vm_creates"] == .integer(guest ? 4 : 0), "campaign exact successful counts")
        }
    }
    static func sourceProductJoins(_ artifacts: [String: Data], manifest: V, state: V) throws {
        try reference(manifest["source_state"]!, path: "source-state.json", artifacts: artifacts, maximum: 262_144)
        try require(state["source"] == manifest["source"] && state["dirty_guard"] == manifest["dirty_guard"], "source state/manifest equality")
    }
    static func auditJoins(_ audit: V, configuration: H3QualificationConfiguration, manifest: V, artifacts: [String: Data]) throws {
        let prefix = configuration == .debug ? "debug" : "release", index = configuration == .debug ? 0 : 1
        let pair = manifest["products"]!.arrayValue![index]
        try reference(pair["audit"]!, path: prefix + "-product-audit.json", artifacts: artifacts, maximum: 262_144)
        try require(audit["configuration"] == .string(configuration.rawValue) && H3QualificationProtocol.sameCodeIdentity(audit["application"], pair["application"]) && H3QualificationProtocol.sameCodeIdentity(audit["controller"], pair["controller"]), "manifest/product audit claims")
    }
    static func supervisorJoins(_ supervisor: V, controller: V, manifest: V, artifacts: [String: Data]) throws {
        try require(supervisor["process"]?["child_pid"] == controller["pid"] && supervisor["controller_executable_before"]?["held"]?["sha256"] == controller["code"]?["executable_sha256"], "supervisor/controller exact PID/hash")
        let held = supervisor["controller_executable_before"]!["held"]!, vnode = controller["held_at_start"]!
        for key in ["device", "inode", "link_count", "mode", "owner"] { try require(held[key] == vnode[key], "supervisor/controller vnode") }
        for (key, name) in [("build_source_manifest", "build-source-manifest.json"), ("source_state", "source-state.json")] { try reference(supervisor[key]!, path: name, artifacts: artifacts, maximum: 262_144) }
        let auditPath = supervisor["controller_product_audit"]!["path"]!.stringValue!
        try reference(supervisor["controller_product_audit"]!, path: auditPath, artifacts: artifacts, maximum: 262_144)
        let pair = manifest["products"]!.arrayValue![auditPath.hasPrefix("debug") ? 0 : 1]
        try require(H3QualificationProtocol.sameCodeIdentity(pair["controller"], controller["code"]), "supervised audited controller")
        let sealPin = manifest["source"]!["delta_path_pins"]!.arrayValue!.first { $0["path"] == .string("Tools/H3QualificationSeal/h3_qualification_seal.rb") }
        try require(supervisor["seal_source_sha256"] == sealPin?["sha256"], "supervisor seal source")
    }
    static func priorClosure(_ artifacts: [String: Data], manifest: V) throws -> V {
        let checkpoint = try decode(artifacts, prior[0], schema: "campaign_checkpoint_v1")
        let supervisor = try decode(artifacts, prior[1], schema: "seal_supervisor_receipt_v1", maximum: 131_072)
        let seal = try decode(artifacts, prior[2], schema: "campaign_seal_v1")
        try require(checkpoint["campaign"] == .string("ADMISSION") && checkpoint["result"] == .string("PASS_ADMISSION_CAMPAIGN") && supervisor["mode"] == .string("VERIFY_ADMISSION") && supervisor["result"] == checkpoint["result"] && seal["result"] == checkpoint["result"] && seal["campaign"] == .string("ADMISSION"), "prior admission result")
        try supervisorJoins(supervisor, controller: checkpoint["verifier"]!, manifest: manifest, artifacts: artifacts)
        try reference(checkpoint["build_source_manifest"]!, path: "build-source-manifest.json", artifacts: artifacts, maximum: 262_144)
        var aliased = artifacts
        aliased["admission-campaign-checkpoint.json"] = artifacts[prior[0]]
        aliased["campaign-verifier-supervisor.json"] = artifacts[prior[1]]
        try reference(supervisor["campaign_checkpoint"]!, path: "admission-campaign-checkpoint.json", artifacts: aliased, maximum: 262_144)
        for (field, name) in [("build_source_manifest", "build-source-manifest.json"), ("source_state", "source-state.json"), ("campaign_checkpoint", "admission-campaign-checkpoint.json"), ("verifier_supervisor", "campaign-verifier-supervisor.json")] {
            try reference(seal[field]!, path: name, artifacts: aliased, maximum: 262_144)
        }
        try require(seal["seal_source_sha256"] == supervisor["seal_source_sha256"] && seal["run_supervisors"] == .array(checkpoint["runs"]!.arrayValue!.map { $0["supervisor"]! }), "prior seal DAG")
        for (index, run) in checkpoint["runs"]!.arrayValue!.enumerated() {
            let pair = manifest["products"]!.arrayValue![index]
            try require(run["application_cdhash"] == pair["application"]?["cdhash"] && run["application_executable_sha256"] == pair["application"]?["executable_sha256"] && run["controller_cdhash"] == pair["controller"]?["cdhash"] && run["controller_executable_sha256"] == pair["controller"]?["executable_sha256"], "prior admission same product")
        }
        return checkpoint
    }
    static func campaign(_ bundle: H3QualificationCampaignArtifactBundle, verifierClaim: V) throws -> V {
        let artifacts = bundle.artifacts, guest = bundle.mode == .guest
        let expected = prelaunch + (guest ? prior : []) + ["debug", "release"].flatMap { prefix in (leaves + ["seal-supervisor-receipt.json"]).map { prefix + "/" + $0 } }
        try require(Set(artifacts.keys) == Set(expected) && artifacts.count == (guest ? 21 : 18), "exact campaign byte bundle")
        let manifest = try decode(artifacts, "build-source-manifest.json", schema: "build_source_manifest_v1")
        let state = try decode(artifacts, "source-state.json", schema: "source_state_v1")
        try sourceProductJoins(artifacts, manifest: manifest, state: state)
        try H3QualificationWire.validate(verifierClaim, schema: "controller_identity_claim")
        try require(H3QualificationProtocol.sameCodeIdentity(verifierClaim["code"], manifest["products"]!.arrayValue![1]["controller"]), "Release campaign verifier product")
        for (key, ref) in manifest["artifacts"]!.objectValue! {
            try reference(ref, path: ref["path"]!.stringValue!, artifacts: artifacts, maximum: key.hasSuffix("build_log") ? 8_388_608 : key.hasSuffix("build_settings") ? 1_048_576 : 262_144)
        }
        let priorCheckpoint = guest ? try priorClosure(artifacts, manifest: manifest) : nil
        var runs: [V] = [], creates: Int64 = 0, entries: Int64 = 0, anyNonpass = false
        for (index, config) in H3QualificationConfiguration.allCases.enumerated() {
            let prefix = config == .debug ? "debug" : "release"
            try settings(artifacts[prefix + "-build-settings.json"]!, configuration: config)
            let audit = try decode(artifacts, prefix + "-product-audit.json", schema: "product_audit_v1")
            try auditJoins(audit, configuration: config, manifest: manifest, artifacts: artifacts)
            let receipt = try decode(artifacts, prefix + "/outer-observer-receipt.json", schema: "outer_receipt_v1", maximum: 131_072)
            let runManifest = try decode(artifacts, prefix + "/manifest.json", schema: "manifest_v1", maximum: 65_536)
            let supervisor = try decode(artifacts, prefix + "/seal-supervisor-receipt.json", schema: "seal_supervisor_receipt_v1", maximum: 131_072)
            let innerBytes = artifacts[prefix + "/inner-application-report.frame"]!
            let inner = try H3QualificationProtocol.decodeFrame(innerBytes)
            let failures = try predicates(receipt, inner: inner)
            try require(receipt["classification"]?["failed_predicates"] == array(failures), "campaign exact recomputed predicates")
            let nonpass = !failures.isEmpty
            try require(!nonpass || (guest && H3QualificationPredicateEvaluator.validTerminalNonpass(receipt: receipt, inner: inner)), "campaign eligible run")
            anyNonpass = anyNonpass || nonpass
            try require(receipt["run"]?["mode"] == .string(bundle.mode.rawValue) && receipt["run"]?["configuration"] == .string(config.rawValue) && runManifest["mode"] == receipt["run"]?["mode"] && runManifest["configuration"] == receipt["run"]?["configuration"] && runManifest["run_id"] == receipt["run"]?["run_id"], "campaign run/configuration joins")
            try require(H3QualificationProtocol.sameCodeIdentity(receipt["application"]?["pre_static"], audit["application"]) && H3QualificationProtocol.sameCodeIdentity(receipt["controller_claim"]?["code"], audit["controller"]) && receipt["evidence"]?["build_source_manifest_sha256"] == .string(H3QualificationProtocol.hash(artifacts["build-source-manifest.json"]!)) && receipt["evidence"]?["product_audit_sha256"] == .string(H3QualificationProtocol.hash(artifacts[prefix + "-product-audit.json"]!)), "prelaunch audit hashes/product")
            try require(receipt["host"]?["macos_build"] == manifest["toolchain"]?["macos_build"] && receipt["host"]?["architecture"] == manifest["toolchain"]?["architecture"], "campaign host toolchain")
            for file in runManifest["files"]!.arrayValue! {
                let name = file["path"]!.stringValue!, bytes = artifacts[prefix + "/" + name]!
                try require(file["byte_count"]?.intValue == Int64(bytes.count) && file["sha256"] == .string(H3QualificationProtocol.hash(bytes)), "manifest raw retained bytes")
            }
            let stderrBytes = artifacts[prefix + "/application-stderr.bin"]!
            try require(stderrBytes.isEmpty && receipt["stderr"]?["retained_sha256"] == .string(H3QualificationProtocol.hash(stderrBytes)), "closed run stderr bytes")
            try supervisorJoins(supervisor, controller: receipt["controller_claim"]!, manifest: manifest, artifacts: artifacts)
            try require(supervisor["mode"] == .string("RUN_\(guest ? "GUEST" : "ADMISSION")_\(config.rawValue)") && supervisor["result"] == receipt["classification"]?["result"], "run supervisor mode/result")
            let local = Dictionary(uniqueKeysWithValues: (leaves + ["seal-supervisor-receipt.json"]).map { ($0, artifacts[prefix + "/" + $0]!) })
            try reference(supervisor["outer_receipt"]!, path: "outer-observer-receipt.json", artifacts: local, maximum: 131_072)
            try reference(supervisor["run_manifest"]!, path: "manifest.json", artifacts: local, maximum: 65_536)
            let rootIdentity = receipt["evidence"]!["root_identity"]!, sealRoot = supervisor["evidence_root_before"]!["held"]!
            for key in ["device", "inode", "link_count", "mode", "owner"] { try require(rootIdentity[key] == sealRoot[key], "run root supervisor identity") }
            creates += receipt["taxonomy"]!["hv_vm_created_count"]!.intValue!; entries += receipt["taxonomy"]!["guest_entered_count"]!.intValue!
            try require(creates <= 4 && entries <= 4, "checked campaign counts")
            let run = receipt["run"]!
            if let priorCheckpoint {
                try require(priorCheckpoint["runs"]!.arrayValue!.allSatisfy { run["nonce"] != $0["nonce"] && run["run_id"] != $0["run_id"] }, "prior cross-configuration nonce reuse")
            }
            runs.append(.object(["application_cdhash": audit["application"]!["cdhash"]!, "application_executable_sha256": audit["application"]!["executable_sha256"]!, "configuration": .string(config.rawValue), "controller_cdhash": audit["controller"]!["cdhash"]!, "controller_executable_sha256": audit["controller"]!["executable_sha256"]!, "manifest": try ref(prefix + "/manifest.json", artifacts), "nonce": run["nonce"]!, "receipt": try ref(prefix + "/outer-observer-receipt.json", artifacts), "run_id": run["run_id"]!, "supervisor": try ref(prefix + "/seal-supervisor-receipt.json", artifacts)]))
        }
        let result = guest ? (anyNonpass ? "FAIL_H3_GUEST_CAMPAIGN" : "PASS_H3_GUEST_CAMPAIGN") : "PASS_ADMISSION_CAMPAIGN"
        let closure: V = guest ? .object(["checkpoint": try ref(prior[0], artifacts), "verifier_supervisor": try ref(prior[1], artifacts), "campaign_seal": try ref(prior[2], artifacts)]) : .null
        let output: V = .object([
            "aggregates": .object(["app_launches": .integer(2), "guest_entries": .integer(entries), "helper_processes": .integer(0), "hv_vm_creates": .integer(creates), "nonces_distinct": .bool(true), "signals": .integer(0), "sqlite_opens": .integer(0)]),
            "authority": .object(["authority_effect": .string("NONE"), "authority_vector": .string("00000000"), "gate_e": .string("ABSTAIN"), "h4_entered": .bool(false), "prime_git_entered": .bool(false), "sqlite_opened": .bool(false)]),
            "build_source_manifest": try ref("build-source-manifest.json", artifacts), "campaign": .string(guest ? "GUEST" : "ADMISSION"), "prior_admission": closure, "result": .string(result), "runs": .array(runs),
            "schema": .string("com.ergentics.provenance.h3-qualification-campaign-checkpoint.v1"),
            "taxonomy": .object(["app_launched": .bool(true), "authority_effect": .string("NONE"), "guest_entered_count": .integer(entries), "helper_processes": .integer(0), "hv_vm_created_count": .integer(creates), "runner_location": .string("EVALUATED_MAC_SIGNED_CAMPAIGN_VERIFIER"), "signals": .integer(0), "signing_state": .string("ADMITTED"), "sqlite_opened": .bool(false), "subject_location": .string("TWO_EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION_RUNS")]), "verifier": verifierClaim, "version": .integer(1)])
        try H3QualificationWire.validate(output, schema: "campaign_checkpoint_v1")
        return output
    }
}

enum H3QualificationPrelaunchVerifier {
    static func verify(mode: H3QualificationMode, configuration: H3QualificationConfiguration,
                       artifacts: [String: Data], controllerClaim: H3QualificationJSONValue) throws -> H3QualificationJSONValue {
        let auditName = (configuration == .debug ? "debug" : "release") + "-product-audit.json"
        try H3QExternal.require(Set(artifacts.keys) == ["build-source-manifest.json", "source-state.json", auditName], "exact prelaunch artifact set")
        let manifest = try H3QExternal.decode(artifacts, "build-source-manifest.json", schema: "build_source_manifest_v1")
        let source = try H3QExternal.decode(artifacts, "source-state.json", schema: "source_state_v1")
        let audit = try H3QExternal.decode(artifacts, auditName, schema: "product_audit_v1")
        try H3QExternal.sourceProductJoins(artifacts, manifest: manifest, state: source)
        try H3QExternal.auditJoins(audit, configuration: configuration, manifest: manifest, artifacts: artifacts)
        try H3QualificationWire.validate(controllerClaim, schema: "controller_identity_claim")
        try H3QExternal.require(H3QualificationProtocol.sameCodeIdentity(controllerClaim["code"], audit["controller"]), "prelaunch controller product")
        return audit["application"]!
    }
}
enum H3QualificationCampaignVerifier {
    static func verify(bundle: H3QualificationCampaignArtifactBundle,
                       verifierClaim: H3QualificationJSONValue) throws -> Data {
        try H3QualificationCanonicalJSON.encode(H3QExternal.campaign(bundle, verifierClaim: verifierClaim), maximumBytes: 262_144)
    }
}
enum H3QualificationPredicateEvaluator {
    static func nativeConditions(capture: H3QualificationNativeCapture) throws -> [String: Bool] {
        let presentation = try H3QualificationReplay.replay(capture: capture)
        return try H3QReplayNative.semanticConditions(H3QCopiedResult(capture: capture), presentation: presentation)
    }

    static func evaluate(receipt: H3QualificationJSONValue, inner: H3QualificationJSONValue?) throws -> [String] {
        try H3QExternal.predicates(receipt, inner: inner)
    }
    static func validTerminalNonpass(receipt: H3QualificationJSONValue, inner: H3QualificationJSONValue) throws -> Bool {
        let failures = try evaluate(receipt: receipt, inner: inner)
        guard receipt["classification"]?["result"] == .string("RETAINED_NONPASS"),
              receipt["classification"]?["failed_predicates"] == H3QExternal.array(failures), !failures.isEmpty else { return false }
        if receipt["run"]?["mode"] == .string("ADMISSION_ONLY") {
            return failures == ["application.live_self_signing_admission"] && inner["native"]?["reason"] == .string("SIGNING_REJECTED")
        }
        guard inner["native"]?["disposition"] == .string("RETURNED"),
              inner["effects"]?["lifecycle_disposition"] == .string("RECOVERY_VOLATILE"),
              inner["native"]?["outer"]?["teardown_pass"] == .integer(1),
              inner["native"]?["outer"]?["resources_quarantined"] == .integer(0),
              inner["verifier"]?["quarantined"] == .bool(false) else { return false }
        return failures.allSatisfy { !$0.hasPrefix("runner.") && !$0.hasPrefix("application.") && $0 != "native.cancellation" && $0 != "native.quarantine" }
    }
}


// Closed field grammar transcribed from the committed 2026-09-04 freeze.
// Semantics beyond this catalog are evaluated explicitly, never inferred from
// a field's diagnostic prose or accepted merely because its type matches.

private struct H3QReplayFailure: Error, CustomStringConvertible, Sendable {
    let description: String
    init(_ description: String) { self.description = description }
}
private struct H3QProjection: Equatable, Sendable { let json: Data; let cbor: Data; let root: String }
private struct H3QNode: Equatable, Sendable { let projection: H3QProjection }
private enum H3QContract {
    static let request = frame([1, 1, 19, 23])
    static func frame(_ words: [UInt64]) -> Data {
        Data(words.flatMap { word in (0..<8).map { UInt8(truncatingIfNeeded: word >> ($0 * 8)) } })
    }
    static func hash(_ data: Data) -> String { H3QualificationProtocol.hash(data) }
}
private enum H3QStageJSON {
    static func encode(_ value: H3QCBORValue) throws -> Data {
        try H3QualificationCanonicalJSON.encode(json(value), maximumBytes: 65_536)
    }
    static func decode(_ bytes: Data) throws -> H3QCBORValue {
        try semantic(H3QualificationCanonicalJSON.decode(bytes, maximumBytes: 65_536))
    }
    private static func json(_ value: H3QCBORValue, depth: Int = 0) throws -> H3QualificationJSONValue {
        guard depth <= 16 else { throw H3QReplayFailure("JSON semantic depth") }
        switch value {
        case .text(let text): return .string(text)
        case .bool(let flag): return .bool(flag)
        case .array(let values): return .array(try values.map { try json($0, depth: depth + 1) })
        case .map(let values): return .object(try values.mapValues { try json($0, depth: depth + 1) })
        case .unsigned, .bytes: throw H3QReplayFailure("JSON semantic type")
        }
    }
    private static func semantic(_ value: H3QualificationJSONValue, depth: Int = 0) throws -> H3QCBORValue {
        guard depth <= 16 else { throw H3QReplayFailure("JSON semantic depth") }
        switch value {
        case .string(let text): return .text(text)
        case .bool(let flag): return .bool(flag)
        case .array(let values):
            guard values.count <= 256 else { throw H3QReplayFailure("JSON semantic collection") }
            return .array(try values.map { try semantic($0, depth: depth + 1) })
        case .object(let values):
            guard values.count <= 256 else { throw H3QReplayFailure("JSON semantic collection") }
            return .map(try values.mapValues { try semantic($0, depth: depth + 1) })
        default: throw H3QReplayFailure("JSON semantic type")
        }
    }
}


private indirect enum H3QCBORValue: Equatable, Sendable {
    case unsigned(UInt64)
    case text(String)
    case bytes(Data)
    case array([H3QCBORValue])
    case map([String: H3QCBORValue])
    case bool(Bool)
}

private struct H3QCBORFailure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

// RFC 8949 core deterministic encoding: shortest arguments, definite lengths,
// bytewise ordering of encoded map keys. No floating point, tags or null values.
private enum H3QCBOR {
    static let maximumBytes = 1_048_576
    static let maximumDepth = 16
    static let maximumCollectionCount = 256
    static let maximumNodes = 8_192

    static func encode(_ value: H3QCBORValue) throws -> Data {
        var encoder = Encoder()
        try encoder.put(value, depth: 0)
        return encoder.output
    }

    // Parsing independently reads CBOR arguments; it never uses the encoder's
    // framing helper. Exact re-encoding additionally rejects representational
    // aliases. UTF-8 map-key aliases that collide as Swift Strings reject.
    static func decode(_ bytes: Data) throws -> H3QCBORValue {
        guard !bytes.isEmpty, bytes.count <= maximumBytes else {
            throw H3QCBORFailure("CBOR frame size is outside the bound")
        }
        var decoder = Decoder(bytes: Array(bytes))
        let value = try decoder.take(depth: 0)
        guard decoder.offset == bytes.count, try encode(value) == bytes else {
            throw H3QCBORFailure("CBOR is trailing or not core deterministic")
        }
        return value
    }

    private struct Encoder {
        var output = Data()
        var nodes = 0

        mutating func add(_ bytes: Data) throws {
            guard bytes.count <= maximumBytes - output.count else {
                throw H3QCBORFailure("CBOR exceeds the byte bound")
            }
            output.append(bytes)
        }
        mutating func argument(_ major: UInt8, _ value: UInt64) throws {
            var frame = Data()
            if value < 24 {
                frame.append((major << 5) | UInt8(value))
            } else {
                let width: Int = value <= 0xff ? 1 : value <= 0xffff ? 2 : value <= 0xffff_ffff ? 4 : 8
                let additional: UInt8 = width == 1 ? 24 : width == 2 ? 25 : width == 4 ? 26 : 27
                frame.append((major << 5) | additional)
                for index in (0..<width).reversed() {
                    frame.append(UInt8(truncatingIfNeeded: value >> (index * 8)))
                }
            }
            try add(frame)
        }
        mutating func put(_ value: H3QCBORValue, depth: Int) throws {
            guard depth <= maximumDepth, nodes < maximumNodes else {
                throw H3QCBORFailure("CBOR nesting or node count exceeds the bound")
            }
            nodes += 1
            switch value {
            case .unsigned(let value): try argument(0, value)
            case .bool(let value): try add(Data([value ? 0xf5 : 0xf4]))
            case .bytes(let bytes):
                try argument(2, UInt64(bytes.count))
                try add(bytes)
            case .text(let text):
                guard text.utf8.count <= maximumBytes - output.count else {
                    throw H3QCBORFailure("CBOR text exceeds the byte bound")
                }
                let bytes = Data(text.utf8)
                try argument(3, UInt64(bytes.count))
                try add(bytes)
            case .array(let values):
                guard values.count <= maximumCollectionCount else {
                    throw H3QCBORFailure("CBOR array exceeds the entry bound")
                }
                try argument(4, UInt64(values.count))
                for value in values { try put(value, depth: depth + 1) }
            case .map(let values):
                guard values.count <= maximumCollectionCount else {
                    throw H3QCBORFailure("CBOR map exceeds the entry bound")
                }
                var entries: [(key: Data, value: H3QCBORValue)] = []
                var keyBytes = 0
                for (key, value) in values {
                    var keyEncoder = Encoder()
                    try keyEncoder.put(.text(key), depth: depth + 1)
                    guard keyEncoder.output.count <= maximumBytes - keyBytes else {
                        throw H3QCBORFailure("CBOR map keys exceed the byte bound")
                    }
                    keyBytes += keyEncoder.output.count
                    entries.append((keyEncoder.output, value))
                }
                entries.sort { $0.key.lexicographicallyPrecedes($1.key) }
                try argument(5, UInt64(entries.count))
                for entry in entries {
                    guard nodes < maximumNodes else { throw H3QCBORFailure("CBOR node bound") }
                    nodes += 1
                    try add(entry.key)
                    try put(entry.value, depth: depth + 1)
                }
            }
        }
    }

    private struct Decoder {
        let bytes: [UInt8]
        var offset = 0
        var nodes = 0

        mutating func argument(_ additional: UInt8) throws -> UInt64 {
            if additional < 24 { return UInt64(additional) }
            let width: Int
            switch additional {
            case 24: width = 1
            case 25: width = 2
            case 26: width = 4
            case 27: width = 8
            default: throw H3QCBORFailure("Unsupported or indefinite CBOR argument")
            }
            guard width <= bytes.count - offset else { throw H3QCBORFailure("Truncated CBOR argument") }
            var value: UInt64 = 0
            for _ in 0..<width { value = (value << 8) | UInt64(bytes[offset]); offset += 1 }
            let minimum: UInt64 = width == 1 ? 24 : width == 2 ? 256 : width == 4 ? 65_536 : 4_294_967_296
            guard value >= minimum else { throw H3QCBORFailure("Nonminimal CBOR argument") }
            return value
        }
        mutating func take(depth: Int) throws -> H3QCBORValue {
            guard depth <= maximumDepth, nodes < maximumNodes, offset < bytes.count else {
                throw H3QCBORFailure("CBOR nesting, node or input bound")
            }
            nodes += 1
            let initial = bytes[offset]
            offset += 1
            if initial == 0xf4 { return .bool(false) }
            if initial == 0xf5 { return .bool(true) }
            let major = initial >> 5
            guard major <= 5, major != 1 else { throw H3QCBORFailure("Unsupported CBOR type") }
            let count = try argument(initial & 31)
            switch major {
            case 0: return .unsigned(count)
            case 2, 3:
                guard count <= UInt64(bytes.count - offset) else { throw H3QCBORFailure("Truncated CBOR bytes") }
                let data = Data(bytes[offset..<(offset + Int(count))])
                offset += Int(count)
                if major == 2 { return .bytes(data) }
                guard let text = String(data: data, encoding: .utf8) else { throw H3QCBORFailure("Invalid CBOR UTF-8") }
                return .text(text)
            case 4:
                guard count <= UInt64(maximumCollectionCount) else { throw H3QCBORFailure("CBOR array bound") }
                var result: [H3QCBORValue] = []
                for _ in 0..<Int(count) { result.append(try take(depth: depth + 1)) }
                return .array(result)
            case 5:
                guard count <= UInt64(maximumCollectionCount) else { throw H3QCBORFailure("CBOR map bound") }
                var result: [String: H3QCBORValue] = [:]
                var previous: Data?
                for _ in 0..<Int(count) {
                    let keyStart = offset
                    guard case .text(let key) = try take(depth: depth + 1) else {
                        throw H3QCBORFailure("CBOR map key must be text")
                    }
                    let encodedKey = Data(bytes[keyStart..<offset])
                    if let previous, !previous.lexicographicallyPrecedes(encodedKey) {
                        throw H3QCBORFailure("CBOR map keys duplicate or out of order")
                    }
                    guard result[key] == nil else { throw H3QCBORFailure("Duplicate CBOR String key") }
                    previous = encodedKey
                    result[key] = try take(depth: depth + 1)
                }
                return .map(result)
            default: throw H3QCBORFailure("Unsupported CBOR major type")
            }
        }
    }
}



private struct H3QLeaf: Sendable {
    let label: String
    let payload: Data
}

private struct H3QCommitment: Equatable, Sendable {
    let root: String
    let leafHashes: [String: String]
    let leafCount: Int
}

private enum H3QMerkleFailure: Error, Equatable {
    case emptySet
    case tooManyLeaves
    case emptyLabel
    case duplicateLabel
    case missingSchema
    case tooManyBytes
}

// Pure commitment of exact caller-provided bytes. This neither creates a VM
// nor gives those bytes authority. The returned root is outside the leaf set.
private enum H3QMerkle {
    static let maximumLeaves = 128
    // Counts the UTF-8 labels plus payloads, excluding fixed framing overhead.
    static let maximumBytes = 1_048_576

    static func commit(_ leaves: [H3QLeaf]) throws -> H3QCommitment {
        let ordered = try admitted(leaves)
        var leafHashes: [String: String] = [:]
        var level: [Data] = []
        for leaf in ordered {
            let label = Data(leaf.label.utf8)
            var frame = Data([0x00])
            appendBE(UInt64(label.count), width: 4, to: &frame)
            frame.append(label)
            appendBE(UInt64(leaf.payload.count), width: 8, to: &frame)
            frame.append(leaf.payload)
            let digest = Data(SHA256.hash(data: frame))
            leafHashes[leaf.label] = hex(digest)
            level.append(digest)
        }
        while level.count > 1 {
            var next: [Data] = []
            var index = 0
            while index < level.count {
                var frame = Data([index + 1 < level.count ? 0x01 : 0x03])
                frame.append(level[index])
                if index + 1 < level.count { frame.append(level[index + 1]) }
                next.append(Data(SHA256.hash(data: frame)))
                index += 2
            }
            level = next
        }
        var rootFrame = Data([0x02])
        appendBE(UInt64(ordered.count), width: 8, to: &rootFrame)
        rootFrame.append(level[0])
        return H3QCommitment(root: hex(Data(SHA256.hash(data: rootFrame))),
            leafHashes: leafHashes, leafCount: ordered.count)
    }

    // Independent tree reconstruction: it does not call commit or its framing
    // helper. Only bounded input admission and SHA-256 are shared. Invalid root
    // encodings compare false; invalid leaf sets throw before reconstruction.
    static func verify(_ leaves: [H3QLeaf], expectedRoot: String) throws -> Bool {
        let ordered = try admitted(leaves)
        let rootBytes = Array(expectedRoot.utf8)
        guard rootBytes.count == 64,
              rootBytes.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }) else {
            return false
        }
        var widths = [ordered.count]
        while widths[widths.count - 1] > 1 {
            widths.append((widths[widths.count - 1] + 1) / 2)
        }
        func reconstruct(_ height: Int, _ index: Int) -> [UInt8] {
            var frame: [UInt8]
            if height == 0 {
                let leaf = ordered[index]
                let label = Array(leaf.label.utf8)
                let labelCount = UInt32(label.count)
                let payloadCount = UInt64(leaf.payload.count)
                frame = [0x00,
                    UInt8(truncatingIfNeeded: labelCount >> 24),
                    UInt8(truncatingIfNeeded: labelCount >> 16),
                    UInt8(truncatingIfNeeded: labelCount >> 8),
                    UInt8(truncatingIfNeeded: labelCount)]
                frame.append(contentsOf: label)
                for byteIndex in (0..<8).reversed() {
                    frame.append(UInt8(truncatingIfNeeded: payloadCount >> (byteIndex * 8)))
                }
                frame.append(contentsOf: leaf.payload)
            } else {
                let leftIndex = index * 2
                let hasRight = leftIndex + 1 < widths[height - 1]
                frame = [hasRight ? 0x01 : 0x03]
                frame.append(contentsOf: reconstruct(height - 1, leftIndex))
                if hasRight { frame.append(contentsOf: reconstruct(height - 1, leftIndex + 1)) }
            }
            return Array(SHA256.hash(data: Data(frame)))
        }
        let count = UInt64(ordered.count)
        var rootFrame: [UInt8] = [0x02]
        for byteIndex in (0..<8).reversed() {
            rootFrame.append(UInt8(truncatingIfNeeded: count >> (byteIndex * 8)))
        }
        rootFrame.append(contentsOf: reconstruct(widths.count - 1, 0))
        let digits = Array("0123456789abcdef".utf8)
        var actual: [UInt8] = []
        for byte in SHA256.hash(data: Data(rootFrame)) {
            actual.append(digits[Int(byte >> 4)])
            actual.append(digits[Int(byte & 15)])
        }
        return actual == rootBytes
    }

    private static func admitted(_ leaves: [H3QLeaf]) throws -> [H3QLeaf] {
        guard !leaves.isEmpty else { throw H3QMerkleFailure.emptySet }
        guard leaves.count <= maximumLeaves else { throw H3QMerkleFailure.tooManyLeaves }
        var names = Set<String>()
        var total = 0
        for leaf in leaves {
            let labelCount = leaf.label.utf8.count
            guard labelCount > 0 else { throw H3QMerkleFailure.emptyLabel }
            // String-key equivalence also rejects composed/decomposed aliases:
            // the public leafHashes dictionary cannot represent both safely.
            // Accepted labels retain their original UTF-8 bytes unchanged.
            guard names.insert(leaf.label).inserted else { throw H3QMerkleFailure.duplicateLabel }
            guard labelCount <= maximumBytes - total else { throw H3QMerkleFailure.tooManyBytes }
            total += labelCount
            guard leaf.payload.count <= maximumBytes - total else { throw H3QMerkleFailure.tooManyBytes }
            total += leaf.payload.count
        }
        guard names.contains("schema") else { throw H3QMerkleFailure.missingSchema }
        return leaves.sorted { $0.label.utf8.lexicographicallyPrecedes($1.label.utf8) }
    }

    private static func appendBE(_ value: UInt64, width: Int, to bytes: inout Data) {
        for index in (0..<width).reversed() {
            bytes.append(UInt8(truncatingIfNeeded: value >> (index * 8)))
        }
    }

    private static func hex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
}


private enum H3QReadinessCursorFailure: Error, Equatable, Sendable {
    case rejected(String)
}

private enum H3QReadinessPredicate: String, CaseIterable, Sendable {
    case predecessor = "h2_product_causal_lineage_exact"
    case schema = "cursor_schema_exact"
    case checkpoint = "checkpoint_state_exact"
    case nextOperation = "next_operation_exact"
    case sourceRetired = "source_owner_retired"
    case freshOwner = "fresh_owner_independent"
    case noReexecution = "resume_not_reexecution"
    case terminalEquality = "control_resume_terminal_equal"
    case oneWinner = "cursor_one_winner_no_replay"
    case semanticJoin = "json_cbor_semantic_join"
    case merkleAncestry = "merkle_ancestry_exact"
    case noEffects = "no_live_or_durable_effects"
}

private struct H3QReadinessMachineState: Equatable, Sendable {
    let left: UInt64
    let right: UInt64
    let accumulator: UInt64
    let nextOrdinal: Int
}

private struct H3QReadinessMachineOwnerSnapshot: Equatable, Sendable {
    let state: H3QReadinessMachineState
    let executedOrdinals: [Int]
    let retired: Bool
}

private struct H3QReadinessCursorFrame: Equatable, Sendable {
    let schema: String
    let profile: String
    let h2ProductSourceCommit: String
    let h2ProductSourceTree: String
    let h2ProductResultCommit: String
    let h2ProductResultTree: String
    let h2ProductResultParentCommit: String
    let h2ProductReceiptSHA256: String
    let h2ProductReceiptGitBlob: String
    let buildArchiveReceiptSHA256: String
    let buildArchiveReceiptGitBlob: String
    let h2StaticResultSHA256: String
    let h2StaticResultGitBlob: String
    let h2StaticReceiptRoot: String
    let h2StaticOutputStateRoot: String
    let h2SnapshotRoot: String
    let sourceGeneration: String
    let baseStateRoot: String
    let checkpointStateRoot: String
    let nextOrdinal: Int
    let nextOperation: String
    let state: H3QReadinessMachineState
}

private struct H3QReadinessContractReceipt: Equatable, Sendable {
    let inputState: H3QNode
    let cursor: H3QNode
    let witnesses: [H3QNode]
    let transition: H3QNode
    let outputState: H3QNode
    let graph: H3QNode
    let root: String
}

private struct H3QReadinessVerifiedResult: Equatable, Sendable {
    let outcome: String
    let receiptRoot: String
    let cursorRoot: String
    let graphRoot: String
    let gateE: String
    let authorityVector: String
    let vmEntryCount: Int
    let stageCompleted: Bool
    let liveResumeAuthorized: Bool
}

private enum H3QReadinessProjectionRole: String {
    case state
    case cursor
    case transition
    case witness
    case graph

    var jsonLabel: String { "\(rawValue).json" }
    var cborLabel: String { "\(rawValue).cbor" }
}

/// A process-local capability. Serialized projections describe what was
/// checked; they cannot reconstruct this owner or mint another consume right.
private struct H3QReadinessCursorCapability: Sendable {
    enum Disposition: Equatable { case available, claimed, consumed, poisoned }

    let frame: H3QReadinessCursorFrame
    private var disposition: Disposition = .available

    fileprivate init(frame: H3QReadinessCursorFrame) { self.frame = frame }

    func snapshotDisposition() -> Disposition {
        return disposition
    }

    mutating func consume(into target: inout H3QReadinessMachineOwner) throws {
        guard disposition == .available else {
            throw H3QReadinessCursorFailure.rejected("cursor.already_consumed")
        }
        disposition = .claimed

        do {
            try H3QReadinessCursor.validate(frame)
            try target.restoreAndConsume(frame)
            disposition = .consumed
        } catch {
            disposition = .poisoned
            throw error
        }
    }
}

/// Small value machine used to freeze cursor semantics before the native H3
/// bridge. It has no filesystem, SQLite, clock, environment, UI or VM calls.
private struct H3QReadinessMachineOwner: Sendable {
    private var storedState: H3QReadinessMachineState
    private var storedExecutedOrdinals: [Int] = []
    private var storedRetired = false

    let identity: UInt32
    init(identity: UInt32, initial: H3QReadinessMachineState = H3QReadinessCursor.initialState) {
        self.identity = identity
        storedState = initial
    }

    var state: H3QReadinessMachineState { snapshot().state }
    var executedOrdinals: [Int] { snapshot().executedOrdinals }
    var retired: Bool { snapshot().retired }

    func snapshot() -> H3QReadinessMachineOwnerSnapshot {
        return H3QReadinessMachineOwnerSnapshot(
            state: storedState, executedOrdinals: storedExecutedOrdinals,
            retired: storedRetired)
    }

    private mutating func advanceLocked() throws {
        guard !storedRetired else {
            throw H3QReadinessCursorFailure.rejected("owner.retired")
        }
        switch storedState.nextOrdinal {
        case 0:
            let sum = storedState.left.addingReportingOverflow(storedState.right)
            guard !sum.overflow else { throw H3QReadinessCursorFailure.rejected("state.overflow") }
            storedState = H3QReadinessMachineState(left: storedState.left, right: storedState.right,
                accumulator: sum.partialValue, nextOrdinal: 1)
            storedExecutedOrdinals.append(0)
        case 1:
            let sum = storedState.accumulator.addingReportingOverflow(1)
            guard !sum.overflow else { throw H3QReadinessCursorFailure.rejected("state.overflow") }
            storedState = H3QReadinessMachineState(left: storedState.left, right: storedState.right,
                accumulator: sum.partialValue, nextOrdinal: 2)
            storedExecutedOrdinals.append(1)
        default:
            throw H3QReadinessCursorFailure.rejected("state.complete")
        }
    }

    mutating func advance() throws {
        try advanceLocked()
    }

    mutating func exportCursor() throws -> H3QReadinessCursorCapability {
        guard !storedRetired, storedExecutedOrdinals == [0],
              storedState == H3QReadinessCursor.checkpointState else {
            throw H3QReadinessCursorFailure.rejected("cursor.export_state")
        }
        let frame = try H3QReadinessCursor.makeFrame(state: storedState)
        storedRetired = true
        return H3QReadinessCursorCapability(frame: frame)
    }

    fileprivate mutating func restoreAndConsume(_ frame: H3QReadinessCursorFrame) throws {
        // Frame validation touches no owner state and therefore precedes the
        // target's one mutation boundary.
        try H3QReadinessCursor.validate(frame)
        guard !storedRetired, storedExecutedOrdinals.isEmpty,
              storedState == H3QReadinessCursor.initialState else {
            throw H3QReadinessCursorFailure.rejected("target.not_fresh")
        }
        storedState = frame.state
        try advanceLocked()
        guard storedExecutedOrdinals == [1] else {
            throw H3QReadinessCursorFailure.rejected("target.trace")
        }
    }
}

/// H3 contract/readiness: explicit cursor, fresh owner and exact resumed value.
/// This is compiled product code, but it remains deliberately effect-free and
/// cannot claim the later native H3 execution or H4 durability stages.
private enum H3QReadinessCursor {
    static let stageID = "hypervisor_explicit_state_cursor_resume_v1"
    static let cursorSchema = "ergentics.provenance.hypervisor-stage.h3.cursor.v1"
    static let inputStateSchema = "ergentics.provenance.hypervisor-stage.h3.input-state.v1"
    static let outputStateSchema = "ergentics.provenance.hypervisor-stage.h3.output-state.v1"
    static let witnessSchema = "ergentics.provenance.hypervisor-stage.h3.witness.v1"
    static let transitionSchema = "ergentics.provenance.hypervisor-stage.h3.transition.v1"
    static let graphSchema = "ergentics.provenance.hypervisor-stage.h3.graph.v1"
    static let receiptSchema = "ergentics.provenance.hypervisor-stage.h3.receipt.v1"
    static let profile = "fixed-two-phase-19-plus-23-then-increment-v1"
    // H2 ran from the archive checkpoint. Its result was then committed as the
    // checkpoint's exact single-parent child. These identities are deliberately
    // separate: neither a later result commit nor the guest snapshot is the H2
    // static graph's output state.
    static let h2ProductSourceCommit = "ffefa11b412cbefb0dd5230e7eb6f6cfa6d5eb55"
    static let h2ProductSourceTree = "2b6333ba5c05a8a6b3b4e873850bd36355a5cba9"
    static let h2ProductResultCommit = "12a0ff52a81e669f135ec9ab4640ee0ba091dbc6"
    static let h2ProductResultTree = "3c06694713ceb690373a36c04922371180c06931"
    static let h2ProductResultParentCommit = h2ProductSourceCommit
    static let h2ProductReceiptSHA256 = "83a201a32114c81fa737f6edfa2b0976324e6e0ca44223f589abbffae4c6f4d4"
    static let h2ProductReceiptGitBlob = "98c037b8c82ed27f458c48fc6a1d92fc05a78e59"
    static let buildArchiveReceiptSHA256 = "fd5e58920b61750cd37b1f6d19e78d37b17824aae559f306527268feb2f7ddd2"
    static let buildArchiveReceiptGitBlob = "5b46f8e7f88895d7a1919eb325a4f6ce827806af"
    static let h2StaticResultSHA256 = "b3693a405a382bd33f8762c08147afd13669533a525856cabb7b954238853855"
    static let h2StaticResultGitBlob = "ef67768a9c895f9c9a06e12f49590b9d724e5103"
    static let h2StaticReceiptRoot = "50a3a244914f5987c3552a0d68faaedef29d17d856d7d645f6d834b5e32c20ca"
    static let h2StaticOutputStateRoot = "6b880870ce4216c9c0793ef198695920323ff23cf6e79b0d8a6cca1f2d8d5d66"
    static let h2SnapshotRoot = "37b6aa19da562bf99810c8169e091357bc4e789a82b50366e0752ffb1a9d89df"
    static let sourceGeneration = "h3-contract-source-owner-v1"
    static let nextOperation = "increment_checkpoint_once"
    static let maximumStreamBytes = 65_536

    static let initialState = H3QReadinessMachineState(
        left: 19, right: 23, accumulator: 0, nextOrdinal: 0)
    static let checkpointState = H3QReadinessMachineState(
        left: 19, right: 23, accumulator: 42, nextOrdinal: 1)
    static let terminalState = H3QReadinessMachineState(
        left: 19, right: 23, accumulator: 43, nextOrdinal: 2)

    static func runContract() throws -> H3QReadinessContractReceipt {
        var control = H3QReadinessMachineOwner(identity: 0)
        try control.advance(); try control.advance()

        var source = H3QReadinessMachineOwner(identity: 1)
        try source.advance()
        var capability = try source.exportCursor()
        let frame = capability.frame
        var target = H3QReadinessMachineOwner(identity: 2)
        guard source.identity != target.identity else {
            throw failure("owner.identity")
        }
        try capability.consume(into: &target)

        var replayTarget = H3QReadinessMachineOwner(identity: 3)
        var replayRejected = false
        do { try capability.consume(into: &replayTarget) }
        catch { replayRejected = true }

        let expectedCheckpointRoot = try stateRoot(checkpointState)
        let results: [H3QReadinessPredicate: Bool] = [
            .predecessor: predecessorExact(frame),
            .schema: frame.schema == cursorSchema && frame.profile == profile,
            .checkpoint: frame.state == checkpointState &&
                frame.checkpointStateRoot == expectedCheckpointRoot,
            .nextOperation: frame.nextOrdinal == 1 && frame.nextOperation == nextOperation,
            .sourceRetired: source.retired,
            .freshOwner: source.identity != target.identity,
            .noReexecution: source.executedOrdinals == [0] && target.executedOrdinals == [1],
            .terminalEquality: control.state == terminalState && target.state == control.state,
            .oneWinner: capability.snapshotDisposition() == .consumed && replayRejected &&
                replayTarget.state == initialState && replayTarget.executedOrdinals.isEmpty,
            .semanticJoin: try semanticJoinExact(frame),
            .merkleAncestry: try merkleAncestryExact(frame),
            .noEffects: effectsExactlyClosed(),
        ]
        guard H3QReadinessPredicate.allCases.allSatisfy({ results[$0] == true }) else {
            throw failure("predicate.internal")
        }

        let input = H3QNode(projection: try project(
            inputStateSemantic(), schema: inputStateSchema, role: .state))
        let cursor = H3QNode(projection: try project(
            cursorSemantic(frame), schema: cursorSchema, role: .cursor))
        let witnesses = try H3QReadinessPredicate.allCases.enumerated().map { index, predicate in
            H3QNode(projection: try project(
                witnessSemantic(predicate: predicate, position: index,
                                satisfied: results[predicate] == true,
                                cursorRoot: cursor.projection.root),
                schema: witnessSchema, role: .witness))
        }
        let transition = H3QNode(projection: try project(
            transitionSemantic(inputRoot: input.projection.root,
                               cursorRoot: cursor.projection.root,
                               witnesses: witnesses),
            schema: transitionSchema, role: .transition))
        let output = H3QNode(projection: try project(
            outputStateSemantic(inputRoot: input.projection.root,
                                cursorRoot: cursor.projection.root,
                                transitionRoot: transition.projection.root),
            schema: outputStateSchema, role: .state))
        let graph = H3QNode(projection: try project(
            graphSemantic(input: input, cursor: cursor, witnesses: witnesses,
                          transition: transition, output: output),
            schema: graphSchema, role: .graph))
        let partial = H3QReadinessContractReceipt(inputState: input, cursor: cursor,
            witnesses: witnesses, transition: transition, outputState: output,
            graph: graph, root: "")
        let root = try H3QMerkle.commit(receiptLeaves(partial)).root
        let receipt = H3QReadinessContractReceipt(inputState: input, cursor: cursor,
            witnesses: witnesses, transition: transition, outputState: output,
            graph: graph, root: root)
        _ = try verifyContract(receipt)
        return receipt
    }

    static func verifyContract(_ receipt: H3QReadinessContractReceipt) throws -> H3QReadinessVerifiedResult {
        let input = try verify(receipt.inputState.projection, schema: inputStateSchema, role: .state)
        guard input == inputStateSemantic() else { throw failure("input.exact") }
        let cursorValue = try verify(receipt.cursor.projection, schema: cursorSchema, role: .cursor)
        guard cursorValue == cursorSemantic(try makeFrame(state: checkpointState)) else {
            throw failure("cursor.exact")
        }
        guard receipt.witnesses.count == H3QReadinessPredicate.allCases.count else {
            throw failure("witness.count")
        }
        for (index, predicate) in H3QReadinessPredicate.allCases.enumerated() {
            let actual = try verify(receipt.witnesses[index].projection,
                                    schema: witnessSchema, role: .witness)
            let expected = witnessSemantic(predicate: predicate, position: index,
                                           satisfied: true,
                                           cursorRoot: receipt.cursor.projection.root)
            guard actual == expected else { throw failure("witness.\(index)") }
        }
        let transition = try verify(receipt.transition.projection,
                                    schema: transitionSchema, role: .transition)
        guard transition == transitionSemantic(inputRoot: receipt.inputState.projection.root,
                                                cursorRoot: receipt.cursor.projection.root,
                                                witnesses: receipt.witnesses) else {
            throw failure("transition.exact")
        }
        let output = try verify(receipt.outputState.projection,
                                schema: outputStateSchema, role: .state)
        guard output == outputStateSemantic(inputRoot: receipt.inputState.projection.root,
                                            cursorRoot: receipt.cursor.projection.root,
                                            transitionRoot: receipt.transition.projection.root) else {
            throw failure("output.exact")
        }
        let graph = try verify(receipt.graph.projection, schema: graphSchema, role: .graph)
        guard graph == graphSemantic(input: receipt.inputState, cursor: receipt.cursor,
                                     witnesses: receipt.witnesses,
                                     transition: receipt.transition,
                                     output: receipt.outputState) else {
            throw failure("graph.exact")
        }
        guard try H3QMerkle.verify(receiptLeaves(receipt), expectedRoot: receipt.root) else {
            throw failure("receipt.root")
        }
        return H3QReadinessVerifiedResult(
            outcome: "PASS_H3_CURSOR_CONTRACT_ONLY", receiptRoot: receipt.root,
            cursorRoot: receipt.cursor.projection.root,
            graphRoot: receipt.graph.projection.root, gateE: "ABSTAIN",
            authorityVector: "00000000", vmEntryCount: 0,
            stageCompleted: false, liveResumeAuthorized: false)
    }

    fileprivate static func makeFrame(state: H3QReadinessMachineState) throws -> H3QReadinessCursorFrame {
        guard state == checkpointState else { throw failure("cursor.state") }
        return H3QReadinessCursorFrame(schema: cursorSchema, profile: profile,
            h2ProductSourceCommit: h2ProductSourceCommit,
            h2ProductSourceTree: h2ProductSourceTree,
            h2ProductResultCommit: h2ProductResultCommit,
            h2ProductResultTree: h2ProductResultTree,
            h2ProductResultParentCommit: h2ProductResultParentCommit,
            h2ProductReceiptSHA256: h2ProductReceiptSHA256,
            h2ProductReceiptGitBlob: h2ProductReceiptGitBlob,
            buildArchiveReceiptSHA256: buildArchiveReceiptSHA256,
            buildArchiveReceiptGitBlob: buildArchiveReceiptGitBlob,
            h2StaticResultSHA256: h2StaticResultSHA256,
            h2StaticResultGitBlob: h2StaticResultGitBlob,
            h2StaticReceiptRoot: h2StaticReceiptRoot,
            h2StaticOutputStateRoot: h2StaticOutputStateRoot,
            h2SnapshotRoot: h2SnapshotRoot,
            sourceGeneration: sourceGeneration,
            baseStateRoot: try stateRoot(initialState),
            checkpointStateRoot: try stateRoot(state),
            nextOrdinal: 1, nextOperation: nextOperation, state: state)
    }

    static func validate(_ frame: H3QReadinessCursorFrame) throws {
        guard frame == (try makeFrame(state: checkpointState)), predecessorExact(frame) else {
            throw failure("cursor.validation")
        }
    }

    private static func predecessorExact(_ frame: H3QReadinessCursorFrame) -> Bool {
        frame.h2ProductSourceCommit == h2ProductSourceCommit &&
        frame.h2ProductSourceTree == h2ProductSourceTree &&
        frame.h2ProductResultCommit == h2ProductResultCommit &&
        frame.h2ProductResultTree == h2ProductResultTree &&
        frame.h2ProductResultParentCommit == h2ProductSourceCommit &&
        frame.h2ProductReceiptSHA256 == h2ProductReceiptSHA256 &&
        frame.h2ProductReceiptGitBlob == h2ProductReceiptGitBlob &&
        frame.buildArchiveReceiptSHA256 == buildArchiveReceiptSHA256 &&
        frame.buildArchiveReceiptGitBlob == buildArchiveReceiptGitBlob &&
        frame.h2StaticResultSHA256 == h2StaticResultSHA256 &&
        frame.h2StaticResultGitBlob == h2StaticResultGitBlob &&
        frame.h2StaticReceiptRoot == h2StaticReceiptRoot &&
        frame.h2StaticOutputStateRoot == h2StaticOutputStateRoot &&
        frame.h2SnapshotRoot == h2SnapshotRoot
    }

    private static func lowercaseHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count && value.utf8.allSatisfy {
            (48...57).contains($0) || (97...102).contains($0)
        }
    }

    private static func semanticJoinExact(_ frame: H3QReadinessCursorFrame) throws -> Bool {
        let semantic = cursorSemantic(frame)
        let json = try H3QStageJSON.encode(semantic)
        let cbor = try H3QCBOR.encode(semantic)
        let leaves = [
            H3QLeaf(label: "schema", payload: Data(cursorSchema.utf8)),
            H3QLeaf(label: H3QReadinessProjectionRole.cursor.jsonLabel, payload: json),
            H3QLeaf(label: H3QReadinessProjectionRole.cursor.cborLabel, payload: cbor),
        ]
        let root = try H3QMerkle.commit(leaves).root
        let fromJSON = try H3QStageJSON.decode(json)
        let fromCBOR = try H3QCBOR.decode(cbor)
        let jsonRoundTrip = try H3QStageJSON.encode(fromJSON)
        let cborRoundTrip = try H3QCBOR.encode(fromCBOR)
        let rootVerified = try H3QMerkle.verify(leaves, expectedRoot: root)
        return fromJSON == semantic && fromCBOR == semantic && fromJSON == fromCBOR &&
            jsonRoundTrip == json && cborRoundTrip == cbor && rootVerified
    }

    private static func merkleAncestryExact(_ frame: H3QReadinessCursorFrame) throws -> Bool {
        let baseStateRoot = try stateRoot(initialState)
        let checkpointStateRoot = try stateRoot(checkpointState)
        return predecessorExact(frame) &&
            lowercaseHex(frame.h2ProductSourceCommit, count: 40) &&
            lowercaseHex(frame.h2ProductSourceTree, count: 40) &&
            lowercaseHex(frame.h2ProductResultCommit, count: 40) &&
            lowercaseHex(frame.h2ProductResultTree, count: 40) &&
            lowercaseHex(frame.h2ProductResultParentCommit, count: 40) &&
            lowercaseHex(frame.h2ProductReceiptSHA256, count: 64) &&
            lowercaseHex(frame.h2ProductReceiptGitBlob, count: 40) &&
            lowercaseHex(frame.buildArchiveReceiptSHA256, count: 64) &&
            lowercaseHex(frame.buildArchiveReceiptGitBlob, count: 40) &&
            lowercaseHex(frame.h2StaticResultSHA256, count: 64) &&
            lowercaseHex(frame.h2StaticResultGitBlob, count: 40) &&
            lowercaseHex(frame.h2StaticReceiptRoot, count: 64) &&
            lowercaseHex(frame.h2StaticOutputStateRoot, count: 64) &&
            lowercaseHex(frame.h2SnapshotRoot, count: 64) &&
            frame.baseStateRoot == baseStateRoot &&
            frame.checkpointStateRoot == checkpointStateRoot
    }

    private static func effectsExactlyClosed() -> Bool {
        let names = Set(["clock_read", "environment_read", "file_read", "file_write",
                         "journal_open", "network", "process_launch", "sqlite_open", "vm_launch"])
        guard case .map(let effects) = effectMap(), Set(effects.keys) == names else { return false }
        return effects.values.allSatisfy { $0 == .bool(false) }
    }

    private static func stateSemantic(_ state: H3QReadinessMachineState) -> H3QCBORValue {
        .map([
            "accumulator": .text(String(state.accumulator)),
            "left": .text(String(state.left)),
            "next_ordinal": .text(String(state.nextOrdinal)),
            "right": .text(String(state.right)),
            "schema": .text("ergentics.provenance.hypervisor-stage.h3.machine-state.v1"),
        ])
    }

    private static func stateRoot(_ state: H3QReadinessMachineState) throws -> String {
        let semantic = stateSemantic(state)
        return try H3QMerkle.commit([
            H3QLeaf(label: "schema", payload: Data("ergentics.provenance.hypervisor-stage.h3.machine-state.v1".utf8)),
            H3QLeaf(label: "state.json", payload: try H3QStageJSON.encode(semantic)),
            H3QLeaf(label: "state.cbor", payload: try H3QCBOR.encode(semantic)),
        ]).root
    }

    private static func inputStateSemantic() -> H3QCBORValue {
        .map([
            "authority_vector": .text("00000000"),
            "archive_receipt_disposition": .text("EXTERNAL_COMMITTED_INPUT_PIN"),
            "build_archive_receipt_git_blob": .text(buildArchiveReceiptGitBlob),
            "build_archive_receipt_sha256": .text(buildArchiveReceiptSHA256),
            "effects": effectMap(),
            "gate_e": .text("ABSTAIN"),
            "h2_product_receipt_sha256": .text(h2ProductReceiptSHA256),
            "h2_product_receipt_git_blob": .text(h2ProductReceiptGitBlob),
            "h2_product_result_commit": .text(h2ProductResultCommit),
            "h2_product_result_parent_commit": .text(h2ProductResultParentCommit),
            "h2_product_result_tree": .text(h2ProductResultTree),
            "h2_product_source_commit": .text(h2ProductSourceCommit),
            "h2_product_source_tree": .text(h2ProductSourceTree),
            "h2_snapshot_root": .text(h2SnapshotRoot),
            "h2_static_output_state_root": .text(h2StaticOutputStateRoot),
            "h2_static_receipt_root": .text(h2StaticReceiptRoot),
            "h2_static_result_git_blob": .text(h2StaticResultGitBlob),
            "h2_static_result_sha256": .text(h2StaticResultSHA256),
            "lineage_disposition": .text("EXACT_PARENT_RESULT_COMMIT_CONTAINS_RECEIPTS"),
            "schema": .text(inputStateSchema),
            "stage_id": .text(stageID),
            "status": .text("H2_PRODUCT_LOCAL_MECHANICS_PASS"),
        ])
    }

    private static func cursorSemantic(_ frame: H3QReadinessCursorFrame) -> H3QCBORValue {
        .map([
            "base_state_root": .text(frame.baseStateRoot),
            "build_archive_receipt_git_blob": .text(frame.buildArchiveReceiptGitBlob),
            "build_archive_receipt_sha256": .text(frame.buildArchiveReceiptSHA256),
            "checkpoint_state": stateSemantic(frame.state),
            "checkpoint_state_root": .text(frame.checkpointStateRoot),
            "h2_product_receipt_sha256": .text(frame.h2ProductReceiptSHA256),
            "h2_product_receipt_git_blob": .text(frame.h2ProductReceiptGitBlob),
            "h2_product_result_commit": .text(frame.h2ProductResultCommit),
            "h2_product_result_parent_commit": .text(frame.h2ProductResultParentCommit),
            "h2_product_result_tree": .text(frame.h2ProductResultTree),
            "h2_product_source_commit": .text(frame.h2ProductSourceCommit),
            "h2_product_source_tree": .text(frame.h2ProductSourceTree),
            "h2_snapshot_root": .text(frame.h2SnapshotRoot),
            "h2_static_output_state_root": .text(frame.h2StaticOutputStateRoot),
            "h2_static_receipt_root": .text(frame.h2StaticReceiptRoot),
            "h2_static_result_git_blob": .text(frame.h2StaticResultGitBlob),
            "h2_static_result_sha256": .text(frame.h2StaticResultSHA256),
            "next_operation": .text(frame.nextOperation),
            "next_ordinal": .text(String(frame.nextOrdinal)),
            "profile": .text(frame.profile),
            "schema": .text(frame.schema),
            "source_generation": .text(frame.sourceGeneration),
        ])
    }

    private static func witnessSemantic(predicate: H3QReadinessPredicate,
                                        position: Int, satisfied: Bool,
                                        cursorRoot: String) -> H3QCBORValue {
        .map([
            "authority_delta": .text("00000000"),
            "cursor_root": .text(cursorRoot),
            "observed": .bool(satisfied),
            "outcome": .text(satisfied ? "SATISFIED" : "REJECTED"),
            "position": .text(String(position)),
            "predicate_id": .text(predicate.rawValue),
            "producer_scope": .text("PURE_PRODUCT_CONTRACT"),
            "schema": .text(witnessSchema),
            "slice_id": .text("H3_CONTRACT_READINESS"),
            "stage_id": .text(stageID),
            "vm_disposition": .text("NOT_CREATED"),
        ])
    }

    private static func transitionSemantic(inputRoot: String, cursorRoot: String,
                                           witnesses: [H3QNode]) -> H3QCBORValue {
        .map([
            "authority_delta": .text("00000000"),
            "combiner": .text("ALL_OF"),
            "cursor_root": .text(cursorRoot),
            "derived_outcome": .text("PASS_H3_CURSOR_CONTRACT_ONLY"),
            "gate_e": .text("ABSTAIN"),
            "input_state_root": .text(inputRoot),
            "output_stage": .text(stageID),
            "predicates": .array(zip(H3QReadinessPredicate.allCases, witnesses).enumerated().map {
                index, pair in .map([
                    "outcome": .text("SATISFIED"),
                    "position": .text(String(index)),
                    "predicate_id": .text(pair.0.rawValue),
                    "witness_root": .text(pair.1.projection.root),
                ])
            }),
            "schema": .text(transitionSchema),
            "successor_authorized": .bool(false),
            "vm_entry_count": .text("0"),
        ])
    }

    private static func graphSemantic(input: H3QNode,
                                      cursor: H3QNode,
                                      witnesses: [H3QNode],
                                      transition: H3QNode,
                                      output: H3QNode) -> H3QCBORValue {
        func node(_ id: String, _ partition: String, _ type: String,
                  _ schema: String, _ root: String) -> H3QCBORValue {
            .map(["content_root": .text(root), "content_schema": .text(schema),
                  "id": .text(id), "node_type": .text(type),
                  "partition": .text(partition)])
        }
        func edge(_ from: String, _ to: String, _ position: Int,
                  _ relation: String, _ predicate: String? = nil) -> H3QCBORValue {
            var value: [String: H3QCBORValue] = [
                "from": .text(from), "position": .text(String(position)),
                "relation": .text(relation), "to": .text(to),
            ]
            if let predicate { value["predicate_id"] = .text(predicate) }
            return .map(value)
        }

        var nodes: [H3QCBORValue] = [
            node("input-state", "evidence", "state", inputStateSchema,
                 input.projection.root),
            node("cursor", "evidence", "state-cursor", cursorSchema,
                 cursor.projection.root),
        ]
        nodes += zip(H3QReadinessPredicate.allCases, witnesses).enumerated().map {
            index, pair in node("witness-\(index)", "evidence", "witness",
                                witnessSchema, pair.1.projection.root)
        }
        nodes += [
            node("transition", "transition", "transition", transitionSchema,
                 transition.projection.root),
            node("output-state", "evidence", "state", outputStateSchema,
                 output.projection.root),
        ]

        var edges: [H3QCBORValue] = [
            edge("input-state", "transition", 0, "INPUT_STATE"),
            edge("cursor", "transition", 1, "CURSOR_INPUT"),
        ]
        edges += H3QReadinessPredicate.allCases.enumerated().map {
            index, predicate in edge("witness-\(index)", "transition", index + 2,
                                     "SATISFIES_PREDICATE", predicate.rawValue)
        }
        edges.append(edge("transition", "output-state", edges.count,
                          "DERIVES_OUTPUT_STATE"))
        return .map([
            "bipartite_rule": .text("EVIDENCE_TO_TRANSITION_OR_TRANSITION_TO_EVIDENCE_ONLY"),
            "edge_count": .text(String(edges.count)), "edges": .array(edges),
            "node_count": .text(String(nodes.count)), "nodes": .array(nodes),
            "schema": .text(graphSchema), "stage_id": .text(stageID),
        ])
    }

    private static func outputStateSemantic(inputRoot: String, cursorRoot: String,
                                            transitionRoot: String) -> H3QCBORValue {
        .map([
            "authority_vector": .text("00000000"),
            "cursor_root": .text(cursorRoot),
            "effects": effectMap(),
            "gate_e": .text("ABSTAIN"),
            "next_stage": .text("NONE"),
            "parent_state_roots": .array([.text(inputRoot)]),
            "schema": .text(outputStateSchema),
            "stage_complete": .bool(false),
            "slice_id": .text("H3_CONTRACT_READINESS"),
            "stage_id": .text(stageID),
            "status": .text("PASS_H3_CURSOR_CONTRACT_ONLY"),
            "successor_authorized": .bool(false),
            "transition_root": .text(transitionRoot),
            "vm_entry_count": .text("0"),
        ])
    }

    private static func effectMap() -> H3QCBORValue {
        .map([
            "clock_read": .bool(false), "environment_read": .bool(false),
            "file_read": .bool(false), "file_write": .bool(false),
            "journal_open": .bool(false), "network": .bool(false),
            "process_launch": .bool(false), "sqlite_open": .bool(false),
            "vm_launch": .bool(false),
        ])
    }

    private static func project(_ semantic: H3QCBORValue, schema: String,
                                role: H3QReadinessProjectionRole) throws -> H3QProjection {
        let json = try H3QStageJSON.encode(semantic)
        let cbor = try H3QCBOR.encode(semantic)
        guard json.count <= maximumStreamBytes, cbor.count <= maximumStreamBytes else {
            throw failure("projection.bound")
        }
        let partial = H3QProjection(json: json, cbor: cbor, root: "")
        let root = try H3QMerkle.commit(projectionLeaves(schema: schema,
            projection: partial, role: role)).root
        let projection = H3QProjection(json: json, cbor: cbor, root: root)
        guard try verify(projection, schema: schema, role: role) == semantic else {
            throw failure("projection.self_verify")
        }
        return projection
    }

    private static func verify(_ projection: H3QProjection, schema: String,
                               role: H3QReadinessProjectionRole) throws -> H3QCBORValue {
        guard !projection.json.isEmpty, !projection.cbor.isEmpty,
              projection.json.count <= maximumStreamBytes,
              projection.cbor.count <= maximumStreamBytes else { throw failure("projection.bound") }
        let json = try H3QStageJSON.decode(projection.json)
        let cbor = try H3QCBOR.decode(projection.cbor)
        guard json == cbor, case .map(let values) = json,
              values["schema"] == .text(schema),
              try H3QMerkle.verify(projectionLeaves(schema: schema,
                  projection: projection, role: role), expectedRoot: projection.root) else {
            throw failure("projection.join")
        }
        return json
    }

    private static func projectionLeaves(schema: String, projection: H3QProjection,
                                         role: H3QReadinessProjectionRole) -> [H3QLeaf] {
        [H3QLeaf(label: "schema", payload: Data(schema.utf8)),
         H3QLeaf(label: role.jsonLabel, payload: projection.json),
         H3QLeaf(label: role.cborLabel, payload: projection.cbor)]
    }

    private static func receiptLeaves(_ receipt: H3QReadinessContractReceipt) throws -> [H3QLeaf] {
        let state = H3QCBORValue.array([
            try verify(receipt.inputState.projection, schema: inputStateSchema, role: .state),
            try verify(receipt.outputState.projection, schema: outputStateSchema, role: .state),
        ])
        let cursor = try verify(receipt.cursor.projection, schema: cursorSchema, role: .cursor)
        let transition = try verify(receipt.transition.projection,
                                    schema: transitionSchema, role: .transition)
        let witnesses = H3QCBORValue.array(try receipt.witnesses.map {
            try verify($0.projection, schema: witnessSchema, role: .witness)
        })
        let graph = try verify(receipt.graph.projection, schema: graphSchema, role: .graph)
        return [
            H3QLeaf(label: "schema", payload: Data(receiptSchema.utf8)),
            H3QLeaf(label: "cursor.json", payload: try H3QStageJSON.encode(cursor)),
            H3QLeaf(label: "cursor.cbor", payload: try H3QCBOR.encode(cursor)),
            H3QLeaf(label: "graph.json", payload: try H3QStageJSON.encode(graph)),
            H3QLeaf(label: "graph.cbor", payload: try H3QCBOR.encode(graph)),
            H3QLeaf(label: "state.json", payload: try H3QStageJSON.encode(state)),
            H3QLeaf(label: "state.cbor", payload: try H3QCBOR.encode(state)),
            H3QLeaf(label: "transition.json", payload: try H3QStageJSON.encode(transition)),
            H3QLeaf(label: "transition.cbor", payload: try H3QCBOR.encode(transition)),
            H3QLeaf(label: "witnesses.json", payload: try H3QStageJSON.encode(witnesses)),
            H3QLeaf(label: "witnesses.cbor", payload: try H3QCBOR.encode(witnesses)),
        ]
    }

    private static func failure(_ predicate: String) -> H3QReadinessCursorFailure {
        .rejected(predicate)
    }
}

private let h3QualificationWireCatalogBytes = Data(#"{"artifact_reference":{"byte_count":"JSON integer 1...1048576","path":"relpath; each containing field supplies one exact fixed literal and no caller-selected path is accepted","sha256":"hex64"},"build_audit_artifacts":{"debug_build_log":"large_artifact_reference fixed to debug-build.log with byte_count<=8388608","debug_build_settings":"artifact_reference fixed to debug-build-settings.json with byte_count<=1048576","debug_product_audit":"artifact_reference fixed to debug-product-audit.json with byte_count<=262144","release_build_log":"large_artifact_reference fixed to release-build.log with byte_count<=8388608","release_build_settings":"artifact_reference fixed to release-build-settings.json with byte_count<=1048576","release_product_audit":"artifact_reference fixed to release-product-audit.json with byte_count<=262144","source_state":"artifact_reference fixed to source-state.json with byte_count<=262144"},"build_dirty_guard":{"allowed_tracked_dirty":"exactly two source_path_pin entries in frozen H2 path order and with frozen working-tree SHA-256 values","ambient_roots_count":"const(53)","ambient_roots_sha256":"hex64 over the frozen canonical root-name serialization","head_matches_implementation":"const(true)","ignored_paths_count":"const(7)","ignored_paths_sha256":"const(d06e3ba7884ccc4ed3d34ab0fa741bbf3f3c0fe1a2c3a43a0f07778054e9a0ec) over the separate frozen canonical ignored-path serialization","index_empty":"const(true)","unexpected_namespace_entries":"const(0)","workspace_structural_directories_count":"const(4)","workspace_structural_directories_sha256":"const(43240b37a01222d07606e683dc9d0970e5322d4b79f5b87ba5156d205ad337f0) over the frozen canonical directory-name serialization"},"build_record":{"argv":"exact frozen argv array for its configuration","build_log":"large_artifact_reference equal to its same-configuration artifacts build-log member","build_process":"successful_external_process_result with one required/observed merged-output EOF","configuration":"enum(DEBUG,RELEASE)","cwd":"const(/Users/ergentics/Developer/ErgenticsProvenance)","derived_data_path":"the exact corresponding frozen fresh path","environment":"exact thirteen-entry exact_execution_context.environment_in_raw_utf8_order array","product_audit":"artifact_reference equal to its same-configuration artifacts product-audit member","settings":"artifact_reference equal to its same-configuration artifacts settings member","settings_argv":"exact frozen fully expanded settings argv array for its configuration","settings_process":"successful_external_process_result with two required/observed pipe EOFs","settings_stderr":"captured_stream with empty base64, byte_count=0, sha256=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855, and truncated=false"},"build_source":{"delta_path_pins":"nonempty array of source_path_pin in exact delta_paths order","delta_paths":"nonempty array of relpath, strictly sorted by raw UTF-8 bytes with no duplicate","freeze_commit":"hex40 naming the committed form of this freeze artifact","freeze_tree":"hex40 equal to freeze_commit^{tree}","frozen_input_pins":"array of source_path_pin in pinned_source_inputs order after excluding every delta_paths member","implementation_commit":"hex40 with exactly one parent and that sole parent equal to freeze_commit","implementation_tree":"hex40 equal to implementation_commit^{tree}"},"build_source_manifest_v1":{"artifacts":"build_audit_artifacts","builds":"exactly two build_record entries ordered DEBUG,RELEASE","dirty_guard":"build_dirty_guard","products":"exactly two product_pair entries ordered DEBUG,RELEASE","schema":"const(com.ergentics.provenance.h3-qualification-build-source-manifest.v1)","source":"build_source","source_state":"artifact_reference fixed to source-state.json with byte_count<=262144 and equal to artifacts.source_state","toolchain":"build_toolchain","version":"const(1)"},"build_toolchain":{"architecture":"const(arm64)","macos_build":"const(25G83)","macos_sdk":"const(26.5)","probes":"exactly ten command_probe entries in toolchain_probe_producer order","seal_launcher_cdhash":"const(a6a8e7d5551056079e931c3b7f491ef3d41e3780)","seal_launcher_identifier":"const(com.apple.env)","seal_launcher_path":"const(/usr/bin/env)","seal_launcher_sha256":"const(75690864f0e7397db05bcc0f4439915559ce24c2d834d530e4e619c14b938556)","seal_runtime_cdhash":"const(6f4f8341f32e8e479783aa9e2fc9518693472df2)","seal_runtime_identifier":"const(com.apple.ruby)","seal_runtime_path":"const(/usr/bin/ruby)","seal_runtime_platform":"const(universal.arm64e-darwin25)","seal_runtime_revision":"const(67958)","seal_runtime_sha256":"const(4d57327e7abe67e1c3f84a0869f4239b3324a3d7ea20a70077450e688282fe4f)","seal_runtime_support_pins_sha256":"const(0273e30aa84370d5aa2440e1e870b3319f6a6a6fed81f9143f208da8f0833f2b)","seal_runtime_version":"const(2.6.10p210)","swift_build":"const(swiftlang-6.3.3.1.3 clang-2100.1.1.101)","swift_driver_version":"const(1.148.6)","swift_target":"const(arm64-apple-macosx26.0)","swift_version":"const(6.3.3)","swiftc_path":"const(/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc)","xcode_build":"const(17F113)","xcode_version":"const(26.6)","xcodebuild_path":"const(/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild)"},"campaign_aggregates":{"app_launches":"const(2)","guest_entries":"const(0) for ADMISSION, const(4) for PASS_H3_GUEST_CAMPAIGN, or exact overflow-checked sum of both validated guest receipt counts in integer 0...4 for FAIL_H3_GUEST_CAMPAIGN","helper_processes":"const(0)","hv_vm_creates":"const(0) for ADMISSION, const(4) for PASS_H3_GUEST_CAMPAIGN, or exact overflow-checked sum of both validated guest receipt counts in integer 0...4 for FAIL_H3_GUEST_CAMPAIGN","nonces_distinct":"const(true)","signals":"const(0) for every checkpoint","sqlite_opens":"const(0)"},"campaign_checkpoint_v1":{"aggregates":"campaign_aggregates","authority":"inner_authority","build_source_manifest":"artifact_reference","campaign":"enum(ADMISSION,GUEST)","prior_admission":"null for ADMISSION; prior_admission_closure for GUEST so the checkpoint hash-binds all three copied closure objects","result":"enum(PASS_ADMISSION_CAMPAIGN,PASS_H3_GUEST_CAMPAIGN,FAIL_H3_GUEST_CAMPAIGN); the FAIL literal is valid only for GUEST with two completed run artifacts and at least one valid_terminal_nonpass","runs":"exactly two campaign_run entries ordered DEBUG,RELEASE","schema":"const(com.ergentics.provenance.h3-qualification-campaign-checkpoint.v1)","taxonomy":"campaign_taxonomy","verifier":"controller_identity_claim for the exact audited Release controller executing the no-spawn verification mode","version":"const(1)"},"campaign_run":{"application_cdhash":"cdhash","application_executable_sha256":"hex64","configuration":"enum(DEBUG,RELEASE)","controller_cdhash":"cdhash","controller_executable_sha256":"hex64","manifest":"artifact_reference","nonce":"hex64","receipt":"artifact_reference","run_id":"hex64","supervisor":"artifact_reference to the same run directory's seal-supervisor-receipt.json"},"campaign_seal_v1":{"build_source_manifest":"artifact_reference to build-source-manifest.json","campaign":"enum(ADMISSION,GUEST)","campaign_checkpoint":"artifact_reference to the same campaign's fixed checkpoint","result":"enum(PASS_ADMISSION_CAMPAIGN,PASS_H3_GUEST_CAMPAIGN,FAIL_H3_GUEST_CAMPAIGN) equal checkpoint and verifier-supervisor result","run_supervisors":"exactly two artifact_reference values ordered debug/seal-supervisor-receipt.json then release/seal-supervisor-receipt.json","schema":"const(com.ergentics.provenance.h3-qualification-campaign-seal.v1)","seal_source_sha256":"same exact admitted seal source hash as both run and verifier receipts","source_state":"artifact_reference to source-state.json","verifier_supervisor":"artifact_reference to campaign-verifier-supervisor.json","version":"const(1)"},"campaign_taxonomy":{"app_launched":"const(true)","authority_effect":"const(NONE)","guest_entered_count":"const(0) for ADMISSION, const(4) for GUEST PASS, or exact overflow-checked sum of the two validated receipt counts in integer 0...4 for FAIL_H3_GUEST_CAMPAIGN","helper_processes":"const(0)","hv_vm_created_count":"const(0) for ADMISSION, const(4) for GUEST PASS, or exact overflow-checked sum of the two validated receipt counts in integer 0...4 for FAIL_H3_GUEST_CAMPAIGN","runner_location":"const(EVALUATED_MAC_SIGNED_CAMPAIGN_VERIFIER)","signals":"const(0) for every checkpoint, including FAIL_H3_GUEST_CAMPAIGN","signing_state":"const(ADMITTED) for every checkpoint and specifically the wrapper/application inner.signing observation; wrapper signing failure is incomplete rather than valid_terminal_nonpass. A GUEST native H3 signing rejection/API error remains separately encoded by native.outer.signing_admitted/signing_error and may yield FAIL_H3_GUEST_CAMPAIGN through valid_terminal_nonpass without changing this wrapper taxonomy.","sqlite_opened":"const(false)","subject_location":"const(TWO_EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION_RUNS)"},"captured_stream":{"base64":"RFC4648 padded base64 whose decoded bytes exactly match byte_count and sha256","byte_count":"JSON integer 0...65536","sha256":"hex64","truncated":"const(false)"},"child_not_created":{"disposition":"const(NOT_CREATED)","exit":"const(NOT_APPLICABLE)","pid":"const(0)","reap":"const(NOT_APPLICABLE)","signal":"const(NOT_APPLICABLE)","wait_status":"const(NOT_APPLICABLE)"},"child_reaped":{"disposition":"const(REAPED)","exit":"i32 or NOT_APPLICABLE when signaled","pid":"JSON integer in 1...2147483647","reap":"const(EXACT_PID_REAPED)","signal":"i32 or NOT_APPLICABLE when normally exited","wait_status":"i32"},"code_identity_claim":{"cdhash":"cdhash","code_object_path":"canonical absolute UTF-8 SecCodeCopyPath result <=4096 bytes; exact application bundle root for bundled application code, exact executable path for the unbundled controller","designated_requirement":"text256","entitlements":"effective_entitlements for the application; JSON null for the controller only after the raw signing observation has no entitlement blob or decodes to an exact empty dictionary, with any nonempty controller entitlement rejected","entitlements_sha256":"hex64 over exact canonical entitlements JSON bytes; the controller null representation is the four ASCII bytes null and therefore hashes to 74234e98afe7498fb5daf1f36ac2d78acc339464f950703b8c019892f982b90b","executable_path":"canonical absolute UTF-8 path <=4096 bytes naming the exact held Mach-O executable and equal proc_pidpath for a launched application","executable_sha256":"hex64","identifier":"text256","macho_uuid":"uuid","runtime":"boolean","team_identifier":"text256","valid":"boolean"},"command_probe":{"argv":"exact nonempty array of UTF-8 argv strings with no shell","cwd":"exact frozen canonical absolute path for the probe class","environment":"exact thirteen-entry exact_execution_context.environment_in_raw_utf8_order array","exit_status":"const(0)","stderr":"captured_stream","stdout":"captured_stream"},"containment_incident_v1":{"child_pid":"JSON integer in 1...2147483647","classification":"const(CONTAINMENT_UNPROVEN)","configuration":"enum(DEBUG,RELEASE)","kill_attempted":"boolean","kill_deadline_tick":"tick","kill_errno":"i32","kill_return":"i32","last_wait_errno":"i32","last_wait_return":"i32","mode":"enum(ADMISSION_ONLY,GUEST)","nonce":"hex64","operation_deadline_tick":"tick","run_id":"hex64","schema":"const(com.ergentics.provenance.h3-qualification-containment-incident.v1)","spawn_tick":"tick","taxonomy":"outer_taxonomy_unknown_capable","terminal_horizon_tick":"tick","terminal_tick":"tick","timebase_denominator":"u32 and >0","timebase_numerator":"u32 and >0","version":"const(1)"},"controller_identity_claim":{"code":"code_identity_claim with identifier com.ergentics.provenance.h3-qualification-controller and entitlements null","held_at_start":"file_identity from the read-only no-follow descriptor opened on the controller executable at startup","named_at_start":"file_identity from the canonical controller executable path at startup","pid":"positive JSON integer from getpid(), retained only for exact outer-supervisor correlation and not as authority"},"effective_entitlements":{"com.apple.security.app-sandbox":"const(true)","com.apple.security.files.user-selected.read-only":"const(true)","com.apple.security.hypervisor":"const(true)"},"file_identity":{"device":"u64dec","generation":"u32","inode":"u64dec","link_count":"u64dec","mode":"u32","owner":"u32"},"inner_authority":{"authority_effect":"const(NONE)","authority_vector":"const(00000000)","gate_e":"const(ABSTAIN)","h4_entered":"const(false)","prime_git_entered":"const(false)","sqlite_opened":"const(false)"},"inner_build":{"configuration":"enum(DEBUG,RELEASE)","guest_abi_version":"const(5)","guest_image_byte_count":"const(136)","guest_image_sha256":"const(3c03199c6ae993fa5c316a497cf4d59d590ee0e1a4488b598d8da385f38af8b0)","guest_profile_id":"const(H3_CURSOR_RESUME)","qualification_variant":"const(true)"},"inner_cancellation_monitor":{"bytes_observed":"const(0)","disposition":"const(COMPLETION_FIRST)","fd_closed":"const(true)","poll_calls":"u32 in 0...1065","read_calls":"u32 in 0...1129; any call must have produced neither a positive byte, EOF, nor non-EINTR error before completion won","route_calls":"const(0)","started_tick":"tick","task_joined":"const(true)","terminal_tick":"tick and >= started_tick"},"inner_effects":{"app_launched":"const(true)","guest_entered_count":"count2","helper_processes":"const(0)","hv_vm_created_count":"count2","lifecycle_disposition":"enum(NOT_ENTERED,RECOVERY_VOLATILE,QUARANTINED)","prime_git_entries":"const(0)","reservation_entries":"JSON integer 0...1 counting successful epr_guest_reserve acquisitions, not failed attempts","reservation_release_entries":"JSON integer 0...1 counting explicit report-path epr_guest_reservation_release calls","reservation_release_status":"i32; const(-2147483648) when reservation_release_entries=0, otherwise the actual native return","runner_location":"const(EVALUATED_MAC_EXTERNAL_CONTROLLER)","signals_observed_before_report":"const(0)","signing_state":"enum(ADMITTED,REJECTED,API_ERROR)","storage_entries":"const(0)","subject_location":"const(EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION)"},"inner_gate":{"accepted":"const(true)","frame_sha256":"hex64","mode_byte":"enum(01,02)","validated_tick":"tick"},"inner_native_not_entered":{"disposition":"const(NOT_ENTERED)","preparation_error":"i32","reason":"enum(ADMISSION_MODE,SIGNING_REJECTED,PREPARATION_REJECTED,CANCELED_BEFORE_ENTRY)"},"inner_native_returned":{"checkpoint":"native_checkpoint","checkpoint_merkle_hex":"hex64","checkpoint_reply_hex":"hex64","cursor_evidence_hex":"hex1360 copied byte-for-byte from all 680 returned EPRGuestH3CursorEvidence storage bytes regardless of byte_count","cursor_evidence_sha256":"lowercase SHA-256 of the exact 680 bytes decoded from cursor_evidence_hex","cursor_sha256":"hex64","disposition":"const(RETURNED)","final_reply_hex":"hex64","outer":"native_outer","sctlr_transition":"native_sctlr_transition","source":"native_phase","target":"native_phase","terminal_merkle_hex":"hex64"},"inner_process":{"bundle_identifier":"const(com.ergentics.provenance)","environment_count":"const(5)","environment_names":"exact array [APP_SANDBOX_CONTAINER_ID,CFFIXED_USER_HOME,HOME,TMPDIR,__CF_USER_TEXT_ENCODING] in raw UTF-8 sorted order with no values retained","environment_observation":"const(OBSERVED_AFTER_FRAMEWORK_START_FROM_EMPTY_ENVP_ORIGIN_UNATTRIBUTED)","pid":"JSON integer in 1...2147483647","team_identifier":"const(ZCQ435U8JP)"},"inner_report_v1":{"authority":"inner_authority","build":"inner_build","cancellation_monitor":"inner_cancellation_monitor","effects":"inner_effects","gate":"inner_gate","native":"one_of(inner_native_not_entered,inner_native_returned)","process":"inner_process","run":"run_identity","schema":"const(com.ergentics.provenance.h3-qualification-inner.v1)","signing":"one_of(inner_signing_admitted,inner_signing_rejected)","timing":"inner_timing","verifier":"one_of(inner_verifier_not_entered,inner_verifier_result)","version":"const(1)"},"inner_signing_admitted":{"admitted":"const(true)","effective_entitlements":"effective_entitlements","effective_entitlements_sha256":"const(f754d498901c39fbbc8f6a5cfb35cf5661174a201d24c6c37a22a3f50708336b) over the canonical effective_entitlements object bytes","error":"const(0)","native_result":"const(1)","status":"const(ADMITTED)"},"inner_signing_rejected":{"admitted":"const(false)","error":"i32","native_result":"enum(-1,0)","status":"enum(REJECTED,API_ERROR)"},"inner_timing":{"continuous_end_tick":"tick and >= continuous_start_tick","continuous_start_tick":"tick","timebase_denominator":"u32 and >0","timebase_numerator":"u32 and >0"},"inner_verifier_not_entered":{"disposition":"const(NOT_ENTERED)"},"inner_verifier_result":{"checkpoint_failures":"verifier_diagnostic_list","checkpoint_integrity":"enum(VALID_NOT_EVALUATED,VALID_PASS,VALID_FAILURE,MALFORMED)","checkpoint_root":"empty string or hex64","detail_sha256":"lowercase SHA-256 of the exact unnormalized UTF-8 bytes of deterministic pure replay's protocol-owned H3QualificationPresentation.detail, which the app-only presentation join requires to equal GuestH3Presentation.detail, with no NUL, newline, Unicode normalization, locale interpolation, or alternate spelling","disposition":"enum(PRE_NATIVE_REJECTION,CANCELED_BEFORE_NATIVE_ENTRY,VERIFIED_PASS,NATIVE_NONPASS,NATIVE_WITNESS_MALFORMED,SWIFT_RECONSTRUCTION_REJECTION)","durable":"const(false)","graph_root":"empty string or hex64","h4_entered":"const(false)","pre_entry_xor_post_exit":"null or u64dec","projection_root":"empty string or hex64","quarantined":"boolean","readiness_receipt_root":"empty string or hex64","requested_xor_pre_entry":"null or u64dec","sctlr_transition_failures":"verifier_diagnostic_list","sctlr_transition_integrity":"enum(VALID_NOT_SAMPLED,VALID_FULL,VALID_PARTIAL,MALFORMED)","status":"enum(PASS,FAIL,CANCELED,BUSY,QUARANTINED,INCOMPLETE)","terminal_root":"empty string or hex64","verifier_error_sha256":"lowercase SHA-256 of the exact unnormalized UTF-8 verifier-error bytes in protocol-owned H3QualificationPresentation's optional presentation diagnostic, required equal to the app-only GuestH3NativeDiagnostic.verifierError by the presentation join; SHA256(empty)=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 when that presentation diagnostic is nil, including PASS and every native-NOT_ENTERED presentation. The separate mandatory H3QualificationNativeCapture remains complete on PASS and is not this optional presentation diagnostic"},"large_artifact_reference":{"byte_count":"JSON integer 1...8388608","path":"relpath; each containing field supplies one exact fixed literal and no caller-selected path is accepted","sha256":"hex64"},"manifest_file":{"byte_count":"JSON integer in the frozen per-file bound","mode":"const(384) representing 0600","path":"one exact frozen basename","sha256":"hex64"},"manifest_v1":{"configuration":"enum(DEBUG,RELEASE)","files":"exactly three manifest_file entries ordered inner-application-report.frame, application-stderr.bin, outer-observer-receipt.json","mode":"enum(ADMISSION_ONLY,GUEST)","run_id":"hex64","schema":"const(com.ergentics.provenance.h3-qualification-manifest.v1)","version":"const(1)"},"native_checkpoint":{"checkpoint_sequence":"u64dec","cpsr":"u64dec","evaluated_mask":"enum(0,511)","gpr_mismatch_mask":"JSON integer 0...2147483647","gprs":"array(u64dec,exactly31)","pages":"array(native_checkpoint_page,exactly3 ordered code,request,reply)","passed_mask":"JSON integer 0...511","required_mask":"const(511)","reserved_zero":"const(0)","schema_version":"const(1)","sctlr":"u64dec","sp":"u64dec","vbar":"u64dec"},"native_checkpoint_page":{"expected_byte":"JSON integer 0...255","first_mismatch_offset":"JSON integer 0...16383 or const(4294967295)","observed_byte":"JSON integer 0...255","reserved_zero":"const(0)","role":"enum(code,request,reply)"},"native_outer":{"abi_version":"const(5)","cancellation_calls":"bit","cancellation_requested":"bit","cancellation_status":"i32","checkpoint_valid":"bit","cursor_decoded":"bit","cursor_evidence_byte_count":"enum(0,680)","cursor_restored":"bit","cursor_sealed":"bit","end_ticks":"u64dec","execution_pass":"bit","failure_stage":"i32","first_error":"i32","outcome":"enum(1,2,3,4,5)","resources_quarantined":"bit","signing_admitted":"bit","signing_error":"i32","source_conserved":"bit","start_ticks":"u64dec","target_conserved":"bit","teardown_pass":"bit","terminal_valid":"bit","timebase_denom":"u32","timebase_numer":"u32","watchdog_create_entries":"JSON integer 0...2","watchdog_create_status":"enum(-2147483648,0...2147483647)","watchdog_fired":"bit","watchdog_join_entries":"JSON integer 0...2","watchdog_join_status":"enum(-2147483648,0...2147483647)","watchdog_wait_status":"enum(-2147483648,0...2147483647)"},"native_phase":{"conserved":"bit","entry_ticks":"u64dec","exception_reason":"u64dec","exit_ticks":"u64dec","fault_ipa":"u64dec","fault_virtual_address":"u64dec","generation":"u64dec","host_unmap_statuses":"array(i32,exactly3)","map_statuses":"array(i32,exactly3)","mappings_entered":"JSON integer 0...3","pc":"u64dec","read_register_status":"i32","register_read_calls":"JSON integer 0...38 with role-specific tighter source maximum 36","register_set_calls":"JSON integer 0...36","register_status":"i32","run_entries":"JSON integer 0...1","run_status":"i32","syndrome":"u64dec","unmap_statuses":"array(i32,exactly3)","vcpu_create_status":"i32","vcpu_destroy_status":"i32","vm_create_status":"i32","vm_destroy_status":"i32","x4":"u64dec"},"native_sctlr_transition":{"requested":"u64dec","reserved_zero_0":"const(0)","reserved_zero_1":"const(0)","sampled_mask":"enum(0,1,3,7)","schema_version":"enum(0,1)","source_post_exit":"u64dec","source_post_exit_read_entries":"enum(0,1)","source_post_exit_read_status":"i32","source_pre_entry":"u64dec","source_pre_entry_read_entries":"enum(0,1)","source_pre_entry_read_status":"i32"},"outer_application_identity":{"dynamic":"code_identity_claim","held_after_reap":"file_identity observed from the retained read-only descriptor after exact child reap","held_before_gate":"file_identity","held_before_spawn":"file_identity","named_after_reap":"file_identity independently reopened without following symlinks from the canonical executable path after exact child reap","named_before_gate":"file_identity","named_before_spawn":"file_identity","post_static":"code_identity_claim from strict static validation after exact reap","pre_static":"code_identity_claim","proc_pidpath":"canonical absolute UTF-8 path <=4096 bytes"},"outer_application_not_launched":{"held_before_spawn":"file_identity","held_terminal":"file_identity","named_before_spawn":"file_identity","named_terminal":"file_identity","pre_static":"code_identity_claim"},"outer_classification":{"failed_predicates":"an exact duplicate-free raw UTF-8-sorted subset of classification_predicate_vocabulary.all_literals_in_raw_utf8_order, byte-equal to the pure recomputation required by classification_predicate_vocabulary.derivation_rule; diagnostic status/failure strings are never classification literals","result":"enum(NO_CHILD_FAILURE,RETAINED_NONPASS,RUN_CANDIDATE_PASS)"},"outer_deadlines":{"cancel_tick":"u64dec; 0 iff no cancellation attempt","gate_attempt_tick":"u64dec; exactly 0 iff no gate-write attempt, otherwise sampled immediately before that sole write","gate_deadline_tick":"tick","gate_return_tick":"u64dec; exactly 0 iff no gate-write attempt, otherwise sampled immediately after that sole write returns","kill_attempt_tick":"u64dec; 0 iff no kill attempt","kill_deadline_tick":"tick","operation_deadline_tick":"tick","reap_tick":"u64dec; exactly 0 for NOT_CREATED and a positive tick for REAPED","spawn_tick":"tick sampled immediately before the sole posix_spawn call, including a failed call","terminal_horizon_tick":"tick","terminal_tick":"tick sampled only after exact reap or NOT_CREATED disposition, required pipe EOFs, stdout readback, and all held/named/evidence-root terminal revalidations finish","timebase_denominator":"u32 and >0","timebase_numerator":"u32 and >0"},"outer_evidence":{"build_source_manifest_sha256":"hex64 from the controller's bounded held-root-relative run prelaunch read, later required to equal the campaign artifact_reference","effective_entitlements_sha256":"the exact admitted canonical entitlement hash, or const(0000000000000000000000000000000000000000000000000000000000000000) when inner signing is REJECTED/API_ERROR or the inner frame is absent","effective_hypervisor_value":"TRUE only for admitted inner signing; const(NOT_OBSERVED) for REJECTED/API_ERROR signing or an absent inner frame","hypervisor_support":"enum(NOT_QUERIED,NATIVE_ENTRY_SUCCEEDED,NATIVE_ENTRY_FAILED,NOT_ENTERED), never caller-selected: NOT_ENTERED for NOT_CREATED, absent/invalid inner frame, or valid GUEST native NOT_ENTERED; NOT_QUERIED for every valid ADMISSION_ONLY inner frame; for valid GUEST native RETURNED, NATIVE_ENTRY_SUCCEEDED iff at least one source/target vm_create_status is exactly HV_SUCCESS numeric zero, NATIVE_ENTRY_FAILED iff neither is zero and at least one is non-sentinel, otherwise NOT_ENTERED when both are INT32_MIN. Source-prefix validation separately rejects role-order-impossible combinations.","inner_byte_count":"JSON integer 0...65552","inner_eof":"boolean","inner_sha256":"hex64; SHA256(empty) if absent","inner_valid":"boolean","product_audit_sha256":"hex64 from the controller's bounded held-root-relative same-configuration product-audit read, later required to equal the campaign artifact_reference","root_identity":"file_identity","stdout_identity_terminal":"file_identity after failed posix_spawn or after exact child reap"},"outer_gate_cancel":{"cancel_errno":"i32","cancel_frame_sha256":"hex64 of expected frozen cancellation frame","cancel_return":"i32","cancel_writes":"JSON integer 0...1","gate_errno":"i32","gate_frame_sha256":"hex64 of expected frozen gate frame","gate_return":"i32","gate_writes":"JSON integer 0...1"},"outer_host":{"architecture":"const(arm64)","macos_build":"text256","macos_version":"text256"},"outer_kill":{"attempted":"boolean","errno":"i32","pid":"JSON integer 0...2147483647","return":"i32"},"outer_receipt_v1":{"application":"one_of(outer_application_not_launched,outer_application_identity)","child":"one_of(child_not_created,child_reaped)","classification":"outer_classification","controller_claim":"controller_identity_claim","deadlines":"outer_deadlines","evidence":"outer_evidence","gate":"outer_gate_cancel","host":"outer_host","kill":"outer_kill","run":"run_identity","schema":"const(com.ergentics.provenance.h3-qualification-outer-receipt.v1)","spawn":"outer_spawn","stderr":"outer_stderr","taxonomy":"outer_taxonomy","version":"const(1)"},"outer_spawn":{"argv":"exact two-element application argv excluding argv0","attributes":"const(CLOEXEC_DEFAULT_EMPTY_MASK_DEFAULT_CATCHABLE_SIGNALS)","cwd":"const(/private/var/empty)","environment_count":"const(0)","fd_map":"const(0=devnull-ro,1=regular-rw-0600,2=pipe,3=gate-ro,4=cancel-ro)","spawn_return":"the i32 returned directly by posix_spawn, never ambient errno; const(0) iff child.disposition=REAPED, or JSON integer 1...2147483647 iff child.disposition=NOT_CREATED"},"outer_stderr":{"eof":"boolean","overflow":"boolean","retained_byte_count":"JSON integer 0...65536","retained_sha256":"hex64","total_byte_count":"JSON integer 0...1048576"},"outer_taxonomy":{"app_launched":"boolean","authority_effect":"const(NONE)","guest_entered_count":"count2","helper_processes":"const(0); the controller is the runner and the application is the subject, not a helper","hv_vm_created_count":"count2","runner_location":"const(EVALUATED_MAC_EXTERNAL_CONTROLLER)","signals":"JSON integer 0...1 and equal successful-or-attempted SIGKILL call count","signing_state":"enum(NOT_ENTERED,ADMITTED,REJECTED,API_ERROR)","sqlite_opened":"const(false)","subject_location":"const(EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION)"},"outer_taxonomy_unknown_capable":{"app_launched":"const(true)","authority_effect":"const(NONE)","guest_entered_count":"enum(UNKNOWN) or count2","helper_processes":"const(0)","hv_vm_created_count":"enum(UNKNOWN) or count2","runner_location":"const(EVALUATED_MAC_EXTERNAL_CONTROLLER)","signals":"JSON integer 0...1","signing_state":"enum(UNKNOWN,NOT_ENTERED,ADMITTED,REJECTED,API_ERROR)","sqlite_opened":"enum(FALSE,UNKNOWN)","subject_location":"const(EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION)"},"prior_admission_closure":{"campaign_seal":"artifact_reference with path prior-admission-campaign-seal.json","checkpoint":"artifact_reference with path prior-admission-checkpoint.json","verifier_supervisor":"artifact_reference with path prior-admission-verifier-supervisor.json"},"product_audit_v1":{"application":"code_identity_claim independently derived from the first six probes","configuration":"enum(DEBUG,RELEASE)","controller":"code_identity_claim independently derived from the last six probes","controller_hypervisor_load_commands":"const(0)","controller_hypervisor_symbols":"const(0)","probes":"exactly twelve product_probe entries in frozen product/probe order","schema":"const(com.ergentics.provenance.h3-qualification-product-audit.v1)","version":"const(1)"},"product_pair":{"application":"code_identity_claim independently observed by the external prelaunch audit","audit":"artifact_reference equal to its same-configuration artifacts product-audit member","configuration":"enum(DEBUG,RELEASE)","controller":"code_identity_claim independently observed by the external prelaunch audit"},"product_probe":{"argv":"exact nonempty array of UTF-8 argv strings with no shell","cwd":"const(/private/var/empty)","environment":"exact thirteen-entry exact_execution_context.environment_in_raw_utf8_order array","exit_status":"const(0)","stderr":"captured_stream","stdout":"captured_stream"},"run_identity":{"configuration":"enum(DEBUG,RELEASE)","mode":"enum(ADMISSION_ONLY,GUEST)","nonce":"hex64","run_id":"hex64"},"seal_directory_identity":{"device":"u64dec from IO#stat.dev","inode":"u64dec from IO#stat.ino","link_count":"u64dec and >=2","mode":"const(448), the JSON decimal representation of mode 0700","owner":"u32 and equal seal-tool euid","path":"exact fixed canonical campaign or run absolute path for the containing mode","type":"const(DIRECTORY)"},"seal_held_named_directory_identity":{"held":"seal_directory_identity observed from the retained directory descriptor","named":"seal_directory_identity observed by a distinct componentwise no-follow reopen of the fixed path"},"seal_held_named_path_identity":{"held":"seal_path_identity observed from the retained opened descriptor","named":"seal_path_identity observed by a distinct componentwise no-follow reopen of the fixed path"},"seal_path_identity":{"device":"u64dec from IO#stat.dev","inode":"u64dec from IO#stat.ino","link_count":"u64dec and const(1) for a supervised executable","mode":"u32 from IO#stat.mode & 07777","owner":"u32 and equal seal-tool euid","path":"one exact fixed canonical absolute controller executable path","sha256":"hex64 from a complete bounded held-descriptor read under bounded_hash_read_rule.supervised_controller_executable","size":"u64dec in 1...67108864 and equal the complete held-descriptor byte count","type":"const(REGULAR)"},"seal_supervisor_receipt_v1":{"argv":"exact controller_invocation_contract.argv_exact_by_mode array","build_source_manifest":"artifact_reference to build-source-manifest.json","campaign":"enum(ADMISSION,GUEST)","campaign_checkpoint":"null for run modes; fixed checkpoint artifact_reference for verifier modes","configuration":"enum(DEBUG,RELEASE) for run modes; null for verifier modes","controller_executable_after":"seal_held_named_path_identity after exact reap, equal to before and independently pinned product claim","controller_executable_before":"seal_held_named_path_identity before spawn","controller_product_audit":"same-configuration artifact_reference; RELEASE for verifier modes","cwd":"const(/private/var/empty)","descriptor_contract":"const(STDIN_DEV_NULL_STDOUT_PIPE_STDERR_PIPE_CLOSE_OTHERS_FRESH_PGROUP)","environment":"const([]), the controller configured envp","evidence_root_after_child":"seal_held_named_directory_identity equal to before","evidence_root_before":"seal_held_named_directory_identity for the fixed run root or campaign root","inventory_after_child":"run mode exact controller_run_leaf_set; verifier mode exact prior campaign-root inventory plus its one checkpoint","inventory_before":"run mode const([]); verifier mode exact closed two-run campaign-root inventory without checkpoint/supervisor/seal","mode":"enum(RUN_ADMISSION_DEBUG,RUN_ADMISSION_RELEASE,VERIFY_ADMISSION,RUN_GUEST_DEBUG,RUN_GUEST_RELEASE,VERIFY_GUEST)","outer_receipt":"fixed outer-observer-receipt.json artifact_reference for run modes; null for verifier modes","process":"supervised_controller_process_result","result":"enum(RUN_CANDIDATE_PASS,RETAINED_NONPASS,PASS_ADMISSION_CAMPAIGN,PASS_H3_GUEST_CAMPAIGN,FAIL_H3_GUEST_CAMPAIGN) valid only for its mode","run_manifest":"fixed manifest.json artifact_reference for run modes; null for verifier modes","schema":"const(com.ergentics.provenance.h3-qualification-seal-supervisor-receipt.v1)","seal_source_sha256":"hex64 equal to build-source source.delta_path_pins for Tools/H3QualificationSeal/h3_qualification_seal.rb and runtime-admission self-hash","source_state":"artifact_reference to source-state.json","version":"const(1)"},"source_path_pin":{"path":"relpath constrained by its containing ordered path set","sha256":"hex64 over a regular nonsymlink of 0...1048576 bytes, observed under external_build_source_seal.external_process_supervisor.implementation_owner.native_bindings_exact.bounded_hash_read_rule.runtime_source_dirty whenever read internally"},"source_state_v1":{"dirty_guard":"build_dirty_guard","probes":"nonempty exact ordered array of one_of(command_probe,tracked_tree_batch_probe) containing every expanded source-state invocation once; only the fixed cat-file --batch invocation uses tracked_tree_batch_probe","schema":"const(com.ergentics.provenance.h3-qualification-source-state.v1)","source":"build_source","version":"const(1)"},"successful_external_process_result":{"child_pid":"JSON integer in 1...2147483647","exit_status":"const(0)","kill_attempted":"const(false)","kill_errno":"const(0)","kill_return":"const(-2147483648)","normal_exit":"const(true)","observed_pipe_eof_count":"JSON integer 1...2 and equal required_pipe_eof_count","operation_deadline_tick":"tick","output_overflow":"const(false)","process_group_gone":"const(true) only after two pre-reap anchor-only inventories, exact reap, and the one post-reap signal-zero probe for -child_pid returns ESRCH","reap_tick":"tick","reaped":"const(true)","required_pipe_eof_count":"enum(1,2)","signal":"const(null)","spawn_tick":"tick","terminal_tick":"tick","timebase_denominator":"const(1), denoting direct CLOCK_MONOTONIC nanoseconds","timebase_numerator":"const(1), denoting direct CLOCK_MONOTONIC nanoseconds","timed_out":"const(false)","wait_status":"i32 encoding normal exit zero"},"supervised_controller_process_result":{"child_pid":"JSON integer in 1...2147483647","exit_status":"enum(0,65) joined to the containing receipt result","kill_attempted":"const(false)","kill_errno":"const(0)","kill_return":"const(-2147483648)","normal_exit":"const(true)","observed_pipe_eof_count":"const(2)","operation_deadline_tick":"tick","output_overflow":"const(false)","process_group":"same positive JSON integer as child_pid","process_group_gone":"const(true) only after two pre-reap anchor-only inventories, exact reap, and the one post-reap kill(0,-process_group) existence probe returns -1/ESRCH","reap_tick":"tick","reaped":"const(true) for the exact child_pid","required_pipe_eof_count":"const(2)","signal":"const(null)","spawn_tick":"tick","stderr":"captured_stream fixed to exact empty bytes; semantic non-PASS is evidence, not a diagnostic stream","stdout":"captured_stream fixed to exact empty bytes","terminal_tick":"tick","timebase_denominator":"const(1), direct CLOCK_MONOTONIC nanoseconds","timebase_numerator":"const(1), direct CLOCK_MONOTONIC nanoseconds","timed_out":"const(false)","wait_status":"i32 encoding the same normal exit_status"},"tracked_tree_batch_probe":{"argv":"exact fixed git cat-file --batch argv from source_state_producer","auxiliary_object_count":"const(3): one raw implementation commit, one raw freeze commit, and one frozen PBX baseline blob in addition to every implementation-tree blob","clean_match_count":"JSON integer 0...252 equal to entry_count minus dirty_exception_count","cwd":"const(/Users/ergentics/Developer/ErgenticsProvenance)","dirty_exception_count":"const(2)","entry_count":"JSON integer 2...254 equal to the parsed implementation ls-tree entry count","entry_join_sha256":"hex64 over a canonical JSON array in tree order, each object having exactly blob_byte_count,blob_oid,blob_recomputed_oid,blob_sha256,disposition,mode,path,worktree_byte_count,worktree_sha256; blob_recomputed_oid equals blob_oid and disposition is RAW_MATCH or one path-specific FROZEN_DIRTY_EXCEPTION","environment":"exact thirteen-entry exact_execution_context.environment_in_raw_utf8_order array","exit_status":"const(0)","freeze_commit_byte_count":"JSON integer 1...1048576 equal to the raw freeze commit-object payload size","freeze_commit_parent":"const(461af031064b0529e7432b1f6cf0cfc2cbccec48) equal to the sole raw parent header","freeze_commit_parent_count":"const(1)","freeze_commit_recomputed_oid":"hex40 recomputed from the exact raw commit payload and equal to source.freeze_commit","freeze_commit_sha256":"hex64 over the exact raw freeze commit-object payload bytes","freeze_commit_tree":"hex40 equal to source.freeze_tree, the sole raw tree header, and freeze_reconstructed_tree","freeze_reconstructed_tree":"hex40 recomputed by exact bottom-up Git tree serialization of the reverse-applied freeze flat map and equal to source.freeze_tree","implementation_commit_byte_count":"JSON integer 1...1048576 equal to the raw commit-object payload size","implementation_commit_parent":"hex40 equal to source.freeze_commit and to the sole raw parent header","implementation_commit_parent_count":"const(1)","implementation_commit_recomputed_oid":"hex40 recomputed from the exact raw commit payload and equal to source.implementation_commit","implementation_commit_sha256":"hex64 over the exact raw implementation commit-object payload bytes","implementation_commit_tree":"hex40 equal to source.implementation_tree, the sole raw tree header, and implementation_reconstructed_tree","implementation_reconstructed_tree":"hex40 recomputed by exact bottom-up Git tree serialization of the implementation ls-tree flat map and equal to source.implementation_tree","listing_sha256":"hex64 equal to the immediately preceding ls-tree command_probe.stdout.sha256","pbx_baseline_blob_byte_count":"JSON integer 1...1048576 equal to the retained raw baseline PBX bytes supplied to the OpenStep validator","pbx_baseline_blob_oid":"const(b5fd9b2e1c72f54924269b6ff9453f87abeae5f2)","pbx_baseline_blob_recomputed_oid":"const(b5fd9b2e1c72f54924269b6ff9453f87abeae5f2) recomputed from the exact baseline payload","pbx_baseline_blob_sha256":"const(93a0ff15e38859a9f74268861a1c18803f514f0f8be7af9bc4b22d6f59ea9561) over the exact baseline payload","predecessor_reconstructed_tree":"const(829331092cdc290f1a0e651fd64a9a56dd4187d2) recomputed by exact bottom-up Git tree serialization after reverse-applying the sole freeze-artifact addition","request_byte_count":"JSON integer 205...10537 equal to (entry_count + 3) * 41","request_sha256":"hex64 over implementation_commit-plus-LF, freeze_commit-plus-LF, every implementation-tree blob OID-plus-LF in tree order, and the PBX baseline OID-plus-LF","response_byte_count":"JSON integer 1...29425792 over every exact commit/blob response header, payload byte, and separator LF","response_sha256":"hex64 over the complete framed cat-file stdout","stderr":"exact empty captured_stream","stdin_closed":"const(true) after the final request LF","stdout_eof":"const(true) after the final response separator","tree_reconstruction_join_sha256":"hex64 over a canonical JSON array ordered PREDECESSOR,FREEZE,IMPLEMENTATION. Each snapshot object has exactly blob_count,root_oid,snapshot,subtree_count,trees_sha256; trees_sha256 covers a canonical raw-directory-path-sorted array including root path as empty, each tree record having exactly oid,path,payload_byte_count,payload_sha256 over the locally serialized raw tree payload"}}"#.utf8)
