import CryptoKit
import Darwin
import Dispatch
import Foundation
import SQLite3

private let authorityVector = "00000000"
private let controlCommit = "cdf2195b2bfa493c17b5762efdb023e03106a613"
private let controlTree = "86553fdd88e7ffd4449dbc9ba0ac1f82028b67d2"
private let controlBlob = "f17f0880e252b6c3fb3cbc3d42474b55416a98f8"
private let controlSHA256 =
    "e09d282d7d30f7207e2c2e6040253c32881a1c8b23ecdb75ba634e9abdf33261"
private let controlDevice = dev_t(16_777_231)
private let controlInode = ino_t(17_418_556)
private let controlBytes = 1_298_425
private let controlSourcePath =
    "/Users/ergentics/Documents/Codex/2026-08-09/" +
    "resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/" +
    "docs/PRIME-SWIFT-VALIDATION-DRIVER-V2-DURABLE-PHASE-CONTROL-2026-08-22.md"
private let observationRootPath =
    "/Users/ergentics/Documents/Codex/2026-08-09/" +
    "resume-latin-roadmap-pr45/r19-observability-eaf9b76-v1"
private let journalLeaf = "r19-observations.v1.jsonl"
private let databaseLeaf = "r19-observations.v1.sqlite3"
private let frameSchema = "prime_driver_v2_r19_observability_frame_v1"
private let payloadHashRule =
    "SHA256_COMPACT_RECURSIVE_LEXICOGRAPHIC_KEYS_UTF8_NO_TRAILING_LF"
private let intervalNanoseconds: UInt64 = 5_000_000_000
private let sampleRoundCount = 2
private let maximumSourceBytes = 4 * 1_024 * 1_024
private let maximumJournalBytes = 1 * 1_024 * 1_024
private let expectedUID = uid_t(501)
private let expectedGID = gid_t(20)
private let procPIDUniqueIdentifierInfo = Int32(17)

private struct Target: Equatable {
    let label: String
    let pid: pid_t
    let uniqueID: UInt64
    let idVersion: Int32
    let sessionID: pid_t
    let processGroupID: pid_t
}

private let targets = [
    Target(
        label: "wrapper",
        pid: 21_600,
        uniqueID: 8_930_175,
        idVersion: 17_456_015,
        sessionID: 21_600,
        processGroupID: 21_600),
    Target(
        label: "guardian",
        pid: 21_601,
        uniqueID: 8_930_176,
        idVersion: 17_456_018,
        sessionID: 21_601,
        processGroupID: 21_601),
    Target(
        label: "fixture",
        pid: 21_660,
        uniqueID: 8_930_235,
        idVersion: 17_456_153,
        sessionID: 21_660,
        processGroupID: 21_660),
]

private enum ObserverError: Error, CustomStringConvertible {
    case contract(String)
    case posix(String, Int32)
    case sqlite(String, Int32, String)

    var description: String {
        switch self {
        case .contract(let message):
            return message
        case .posix(let operation, let code):
            return "\(operation): errno=\(code) \(String(cString: strerror(code)))"
        case .sqlite(let operation, let code, let message):
            return "\(operation): sqlite=\(code) \(message)"
        }
    }
}

@inline(__always)
private func require(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    guard condition() else { throw ObserverError.contract(message) }
}

private indirect enum JSONValue {
    case object([String: JSONValue])
    case array([JSONValue])
    case string(String)
    case uint(UInt64)
    case int(Int64)
    case bool(Bool)
    case null

    func encoded() -> Data {
        var bytes: [UInt8] = []
        append(to: &bytes)
        return Data(bytes)
    }

    private func append(to bytes: inout [UInt8]) {
        switch self {
        case .object(let object):
            bytes.append(UInt8(ascii: "{"))
            for (index, key) in object.keys.sorted().enumerated() {
                if index > 0 { bytes.append(UInt8(ascii: ",")) }
                JSONValue.string(key).append(to: &bytes)
                bytes.append(UInt8(ascii: ":"))
                object[key]!.append(to: &bytes)
            }
            bytes.append(UInt8(ascii: "}"))
        case .array(let array):
            bytes.append(UInt8(ascii: "["))
            for (index, value) in array.enumerated() {
                if index > 0 { bytes.append(UInt8(ascii: ",")) }
                value.append(to: &bytes)
            }
            bytes.append(UInt8(ascii: "]"))
        case .string(let value):
            bytes.append(UInt8(ascii: "\""))
            for scalar in value.unicodeScalars {
                switch scalar.value {
                case 0x22:
                    bytes.append(contentsOf: [0x5c, 0x22])
                case 0x5c:
                    bytes.append(contentsOf: [0x5c, 0x5c])
                case 0x08:
                    bytes.append(contentsOf: [0x5c, 0x62])
                case 0x0c:
                    bytes.append(contentsOf: [0x5c, 0x66])
                case 0x0a:
                    bytes.append(contentsOf: [0x5c, 0x6e])
                case 0x0d:
                    bytes.append(contentsOf: [0x5c, 0x72])
                case 0x09:
                    bytes.append(contentsOf: [0x5c, 0x74])
                case 0x00...0x1f:
                    let escaped = String(format: "\\u%04x", scalar.value)
                    bytes.append(contentsOf: escaped.utf8)
                default:
                    bytes.append(contentsOf: String(scalar).utf8)
                }
            }
            bytes.append(UInt8(ascii: "\""))
        case .uint(let value):
            bytes.append(contentsOf: String(value).utf8)
        case .int(let value):
            bytes.append(contentsOf: String(value).utf8)
        case .bool(let value):
            bytes.append(contentsOf: value ? Array("true".utf8) : Array("false".utf8))
        case .null:
            bytes.append(contentsOf: "null".utf8)
        }
    }
}

private func sha256(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

private func iso8601Now() -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: Date())
}

private func decimalScaled(_ value: UInt64, places: Int) -> String {
    let digits = String(value)
    if places == 0 { return digits }
    if digits.count <= places {
        return "0." + String(repeating: "0", count: places - digits.count) + digits
    }
    let split = digits.index(digits.endIndex, offsetBy: -places)
    return String(digits[..<split]) + "." + String(digits[split...])
}

private func ratio(_ numerator: UInt64, _ denominator: UInt64, multiplier: Double = 1) -> String {
    guard denominator > 0 else { return "UNAVAILABLE" }
    return String(format: "%.12g", (Double(numerator) / Double(denominator)) * multiplier)
}

private func writeAll(_ descriptor: Int32, _ data: Data) throws {
    try data.withUnsafeBytes { raw in
        guard let base = raw.baseAddress else { return }
        var offset = 0
        while offset < raw.count {
            let result = Darwin.write(descriptor, base.advanced(by: offset), raw.count - offset)
            if result > 0 {
                offset += result
            } else if result < 0 && errno == EINTR {
                continue
            } else {
                throw ObserverError.posix("write", errno)
            }
        }
    }
}

private func preadExact(_ descriptor: Int32, count: Int, offset: off_t) throws -> Data {
    var data = Data(count: count)
    var completed = 0
    try data.withUnsafeMutableBytes { raw in
        guard let base = raw.baseAddress else { return }
        while completed < count {
            let result = Darwin.pread(
                descriptor,
                base.advanced(by: completed),
                count - completed,
                offset + off_t(completed))
            if result > 0 {
                completed += result
            } else if result < 0 && errno == EINTR {
                continue
            } else if result == 0 {
                throw ObserverError.contract("unexpected EOF")
            } else {
                throw ObserverError.posix("pread", errno)
            }
        }
    }
    return data
}

private func fullSync(_ descriptor: Int32) throws {
    guard fsync(descriptor) == 0 else { throw ObserverError.posix("fsync", errno) }
    guard fcntl(descriptor, F_FULLFSYNC) == 0 else {
        throw ObserverError.posix("F_FULLFSYNC", errno)
    }
}

private func configureNoSIGPIPE(_ descriptor: Int32) throws {
    guard fcntl(descriptor, F_SETNOSIGPIPE, 1) == 0 else {
        throw ObserverError.posix("F_SETNOSIGPIPE", errno)
    }
}

private func sameSourceState(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev &&
        lhs.st_ino == rhs.st_ino &&
        lhs.st_mode == rhs.st_mode &&
        lhs.st_nlink == rhs.st_nlink &&
        lhs.st_uid == rhs.st_uid &&
        lhs.st_gid == rhs.st_gid &&
        lhs.st_size == rhs.st_size &&
        lhs.st_gen == rhs.st_gen &&
        lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
        lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
        lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
        lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}

private final class HeldControlSource {
    let descriptor: Int32
    let initialState: stat
    let data: Data

    init() throws {
        let opened = open(controlSourcePath, O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard opened >= 0 else { throw ObserverError.posix("open control source", errno) }
        descriptor = opened
        var closeOnFailure = true
        defer { if closeOnFailure { _ = close(opened) } }
        var before = stat()
        guard fstat(descriptor, &before) == 0 else {
            throw ObserverError.posix("fstat control source", errno)
        }
        try require((before.st_mode & S_IFMT) == S_IFREG, "control source type")
        try require((before.st_mode & 0o7777) == 0o644, "control source mode")
        try require(before.st_nlink == 1, "control source link count")
        try require(before.st_uid == expectedUID && before.st_gid == expectedGID, "control source owner")
        try require(before.st_dev == controlDevice && before.st_ino == controlInode, "control source vnode")
        try require(before.st_size == off_t(controlBytes), "control source exact size")
        try require(before.st_size <= off_t(maximumSourceBytes), "control source size cap")
        let snapshot = try preadExact(descriptor, count: controlBytes, offset: 0)
        var after = stat()
        guard fstat(descriptor, &after) == 0 else {
            throw ObserverError.posix("fstat control source after read", errno)
        }
        try require(sameSourceState(before, after), "control source moved during read")
        initialState = before
        data = snapshot
        try revalidate()
        closeOnFailure = false
    }

    deinit { _ = close(descriptor) }

    func revalidate() throws {
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0 else {
            throw ObserverError.posix("fstat held control source", errno)
        }
        guard lstat(controlSourcePath, &named) == 0 else {
            throw ObserverError.posix("lstat named control source", errno)
        }
        try require(sameSourceState(initialState, held), "held control source drift")
        try require(sameSourceState(held, named), "named control source rebound")
    }
}

private struct UniqueIdentifierInfo: Equatable {
    var uuidWord0: UInt64 = 0
    var uuidWord1: UInt64 = 0
    var uniqueID: UInt64 = 0
    var parentUniqueID: UInt64 = 0
    var idVersion: Int32 = 0
    var originalParentIDVersion: Int32 = 0
    var reserve2: UInt64 = 0
    var reserve3: UInt64 = 0

    var uuidHex: String {
        var copy = self
        return withUnsafeBytes(of: &copy) { raw in
            raw.prefix(16).map { String(format: "%02x", $0) }.joined()
        }
    }
}

private struct ShortBSD: Equatable {
    let pid: UInt32
    let parentPID: UInt32
    let processGroupID: UInt32
    let status: UInt32
    let commandHex: String
    let flags: UInt32
    let uid: UInt32
    let gid: UInt32
    let realUID: UInt32
    let realGID: UInt32
    let savedUID: UInt32
    let savedGID: UInt32
    let reserved: UInt32
}

private struct ProcessJoin: Equatable {
    let unique: UniqueIdentifierInfo
    let short: ShortBSD
    let sessionID: pid_t
    let processGroupID: pid_t
}

private struct Usage: Equatable {
    let uuidHex: String
    let userTime: UInt64
    let systemTime: UInt64
    let physicalFootprint: UInt64
    let processStartAbstime: UInt64
    let processExitAbstime: UInt64
    let instructions: UInt64
    let cycles: UInt64
    let runnableTime: UInt64
    let userPTime: UInt64
    let systemPTime: UInt64
    let pInstructions: UInt64
    let pCycles: UInt64
    let energyNJ: UInt64
    let pEnergyNJ: UInt64
}

private struct ProcessObservation {
    let target: Target
    let observedUTC: String
    let monotonicBefore: UInt64
    let monotonicAfter: UInt64
    let availability: String
    let error: String?
    let join: ProcessJoin?
    let usage: Usage?
}

private struct IntervalObservation {
    let valid: Bool
    let reason: String
    let energyInterpretationValid: Bool
    let energyInterpretation: String
    let elapsedEstimate: UInt64?
    let elapsedMinimum: UInt64?
    let elapsedMaximum: UInt64?
    let deltaCPU: UInt64?
    let deltaEnergy: UInt64?
    let deltaInstructions: UInt64?
    let deltaCycles: UInt64?
    let joules: String?
    let ergs: String?
    let powerEstimate: String?
    let powerLower: String?
    let powerUpper: String?
    let cpuPercentEstimate: String?
    let cpuPercentLower: String?
    let cpuPercentUpper: String?

    static func unavailable(_ reason: String) -> IntervalObservation {
        .init(
            valid: false,
            reason: reason,
            energyInterpretationValid: false,
            energyInterpretation: "ABSTAIN_INTERVAL_UNAVAILABLE",
            elapsedEstimate: nil,
            elapsedMinimum: nil,
            elapsedMaximum: nil,
            deltaCPU: nil,
            deltaEnergy: nil,
            deltaInstructions: nil,
            deltaCycles: nil,
            joules: nil,
            ergs: nil,
            powerEstimate: nil,
            powerLower: nil,
            powerUpper: nil,
            cpuPercentEstimate: nil,
            cpuPercentLower: nil,
            cpuPercentUpper: nil)
    }
}

private func checkedSubtract(_ later: UInt64, _ earlier: UInt64) throws -> UInt64 {
    let value = later.subtractingReportingOverflow(earlier)
    try require(!value.overflow, "cumulative counter regression")
    return value.partialValue
}

private func readUnique(_ pid: pid_t) throws -> UniqueIdentifierInfo {
    var value = UniqueIdentifierInfo()
    let requested = MemoryLayout<UniqueIdentifierInfo>.size
    let returned = withUnsafeMutablePointer(to: &value) {
        proc_pidinfo(pid, procPIDUniqueIdentifierInfo, 0, $0, Int32(requested))
    }
    if returned != requested {
        if returned <= 0 && errno != 0 {
            throw ObserverError.posix("proc_pidinfo flavor 17", errno)
        }
        throw ObserverError.contract("proc_pidinfo flavor 17 partial return")
    }
    try require(value.uniqueID > 0, "flavor 17 zero unique ID")
    try require(value.idVersion > 0, "flavor 17 zero idversion")
    try require(value.uuidHex != String(repeating: "0", count: 32), "flavor 17 zero UUID")
    try require(value.reserve2 == 0 && value.reserve3 == 0, "flavor 17 reserved")
    return value
}

private func readShort(_ pid: pid_t) throws -> ShortBSD {
    var value = proc_bsdshortinfo()
    let requested = MemoryLayout<proc_bsdshortinfo>.size
    let returned = withUnsafeMutablePointer(to: &value) {
        proc_pidinfo(pid, PROC_PIDT_SHORTBSDINFO, 0, $0, Int32(requested))
    }
    if returned != requested {
        if returned <= 0 && errno != 0 {
            throw ObserverError.posix("proc_pidinfo flavor 13", errno)
        }
        throw ObserverError.contract("proc_pidinfo flavor 13 partial return")
    }
    var command = value.pbsi_comm
    let commandHex = withUnsafeBytes(of: &command) {
        $0.prefix { $0 != 0 }.map { String(format: "%02x", $0) }.joined()
    }
    try require(value.pbsi_rfu == 0, "flavor 13 reserved")
    return ShortBSD(
        pid: value.pbsi_pid,
        parentPID: value.pbsi_ppid,
        processGroupID: value.pbsi_pgid,
        status: value.pbsi_status,
        commandHex: commandHex,
        flags: value.pbsi_flags,
        uid: value.pbsi_uid,
        gid: value.pbsi_gid,
        realUID: value.pbsi_ruid,
        realGID: value.pbsi_rgid,
        savedUID: value.pbsi_svuid,
        savedGID: value.pbsi_svgid,
        reserved: value.pbsi_rfu)
}

private func readJoin(_ target: Target) throws -> ProcessJoin {
    errno = 0
    let uniqueA = try readUnique(target.pid)
    let shortA = try readShort(target.pid)
    let sidA = getsid(target.pid)
    guard sidA >= 0 else { throw ObserverError.posix("getsid A", errno) }
    let pgidA = getpgid(target.pid)
    guard pgidA >= 0 else { throw ObserverError.posix("getpgid A", errno) }
    let sidB = getsid(target.pid)
    guard sidB >= 0 else { throw ObserverError.posix("getsid B", errno) }
    let pgidB = getpgid(target.pid)
    guard pgidB >= 0 else { throw ObserverError.posix("getpgid B", errno) }
    let shortB = try readShort(target.pid)
    let uniqueB = try readUnique(target.pid)
    try require(uniqueA == uniqueB, "flavor 17 generation moved")
    try require(shortA == shortB, "flavor 13 identity moved")
    try require(sidA == sidB && pgidA == pgidB, "session/group moved")
    try require(shortA.pid == UInt32(target.pid), "flavor 13 PID mismatch")
    try require(shortA.processGroupID == UInt32(pgidA), "flavor 13 PGID mismatch")
    try require(uniqueA.uniqueID == target.uniqueID, "target unique ID mismatch")
    try require(uniqueA.idVersion == target.idVersion, "target idversion mismatch")
    try require(sidA == target.sessionID, "target session mismatch")
    try require(pgidA == target.processGroupID, "target group mismatch")
    return ProcessJoin(
        unique: uniqueA,
        short: shortA,
        sessionID: sidA,
        processGroupID: pgidA)
}

private func readUsage(_ pid: pid_t) throws -> Usage {
    var value = rusage_info_v6()
    errno = 0
    let returned = withUnsafeMutablePointer(to: &value) { pointer in
        pointer.withMemoryRebound(to: rusage_info_t?.self, capacity: 1) {
            proc_pid_rusage(pid, RUSAGE_INFO_V6, $0)
        }
    }
    guard returned == 0 else {
        throw ObserverError.posix("proc_pid_rusage V6", errno)
    }
    var rawUUID = value.ri_uuid
    let uuidHex = withUnsafeBytes(of: &rawUUID) {
        $0.map { String(format: "%02x", $0) }.joined()
    }
    return Usage(
        uuidHex: uuidHex,
        userTime: value.ri_user_time,
        systemTime: value.ri_system_time,
        physicalFootprint: value.ri_phys_footprint,
        processStartAbstime: value.ri_proc_start_abstime,
        processExitAbstime: value.ri_proc_exit_abstime,
        instructions: value.ri_instructions,
        cycles: value.ri_cycles,
        runnableTime: value.ri_runnable_time,
        userPTime: value.ri_user_ptime,
        systemPTime: value.ri_system_ptime,
        pInstructions: value.ri_pinstructions,
        pCycles: value.ri_pcycles,
        energyNJ: value.ri_energy_nj,
        pEnergyNJ: value.ri_penergy_nj)
}

private func observe(_ target: Target) -> ProcessObservation {
    do {
        let beforeJoin = try readJoin(target)
        let before = DispatchTime.now().uptimeNanoseconds
        let usage = try readUsage(target.pid)
        let after = DispatchTime.now().uptimeNanoseconds
        let afterJoin = try readJoin(target)
        try require(beforeJoin == afterJoin, "generation moved across rusage")
        try require(usage.uuidHex == beforeJoin.unique.uuidHex, "rusage UUID mismatch")
        try require(usage.processStartAbstime > 0, "rusage start abstime zero")
        try require(usage.pEnergyNJ <= usage.energyNJ, "partial energy exceeds total")
        return ProcessObservation(
            target: target,
            observedUTC: iso8601Now(),
            monotonicBefore: before,
            monotonicAfter: after,
            availability: "AVAILABLE_EXACT_GENERATION_SANDWICHED",
            error: nil,
            join: beforeJoin,
            usage: usage)
    } catch {
        let instant = DispatchTime.now().uptimeNanoseconds
        return ProcessObservation(
            target: target,
            observedUTC: iso8601Now(),
            monotonicBefore: instant,
            monotonicAfter: instant,
            availability: "ABSTAIN_TARGET_UNAVAILABLE_OR_UNSTABLE",
            error: String(describing: error),
            join: nil,
            usage: nil)
    }
}

private func interval(
    previous: ProcessObservation?,
    current: ProcessObservation
) -> IntervalObservation {
    guard let previous,
          let beforeJoin = previous.join,
          let afterJoin = current.join,
          let beforeUsage = previous.usage,
          let afterUsage = current.usage
    else {
        return .unavailable(previous == nil ? "NO_PREDECESSOR" : "OBSERVATION_ABSTAIN")
    }
    guard beforeJoin == afterJoin,
          beforeUsage.uuidHex == afterUsage.uuidHex,
          beforeUsage.processStartAbstime == afterUsage.processStartAbstime
    else {
        return .unavailable("GENERATION_OR_RUSAGE_IDENTITY_CHANGED")
    }
    do {
        let elapsedMinimum = try checkedSubtract(
            current.monotonicBefore, previous.monotonicAfter)
        let elapsedMaximum = try checkedSubtract(
            current.monotonicAfter, previous.monotonicBefore)
        try require(elapsedMinimum > 0 && elapsedMaximum >= elapsedMinimum, "timing bounds")
        let previousMidpoint = previous.monotonicBefore +
            ((previous.monotonicAfter - previous.monotonicBefore) / 2)
        let currentMidpoint = current.monotonicBefore +
            ((current.monotonicAfter - current.monotonicBefore) / 2)
        let elapsedEstimate = try checkedSubtract(currentMidpoint, previousMidpoint)
        let deltaUser = try checkedSubtract(afterUsage.userTime, beforeUsage.userTime)
        let deltaSystem = try checkedSubtract(afterUsage.systemTime, beforeUsage.systemTime)
        let deltaCPUResult = deltaUser.addingReportingOverflow(deltaSystem)
        try require(!deltaCPUResult.overflow, "CPU delta overflow")
        _ = try checkedSubtract(afterUsage.userPTime, beforeUsage.userPTime)
        _ = try checkedSubtract(afterUsage.systemPTime, beforeUsage.systemPTime)
        _ = try checkedSubtract(afterUsage.pInstructions, beforeUsage.pInstructions)
        _ = try checkedSubtract(afterUsage.pCycles, beforeUsage.pCycles)
        let deltaPEnergy = try checkedSubtract(afterUsage.pEnergyNJ, beforeUsage.pEnergyNJ)
        _ = try checkedSubtract(afterUsage.runnableTime, beforeUsage.runnableTime)
        let deltaEnergy = try checkedSubtract(afterUsage.energyNJ, beforeUsage.energyNJ)
        let deltaInstructions = try checkedSubtract(
            afterUsage.instructions, beforeUsage.instructions)
        let deltaCycles = try checkedSubtract(afterUsage.cycles, beforeUsage.cycles)
        let deltaCPU = deltaCPUResult.partialValue
        let energyValid =
            deltaPEnergy <= deltaEnergy && !(deltaEnergy == 0 && deltaCPU > 0)
        let energyInterpretation: String
        if deltaPEnergy > deltaEnergy {
            energyInterpretation = "ABSTAIN_PARTIAL_ENERGY_DELTA_EXCEEDS_TOTAL_DELTA"
        } else if deltaEnergy == 0 && deltaCPU > 0 {
            energyInterpretation = "ABSTAIN_ZERO_ENERGY_DELTA_WITH_POSITIVE_CPU"
        } else {
            energyInterpretation = "AVAILABLE_KERNEL_RUSAGE_V6_TASK_ENERGY_DELTA"
        }
        return IntervalObservation(
            valid: true,
            reason: "MONOTONIC_GENERATION_JOINED_COUNTER_INTERVAL_VALID",
            energyInterpretationValid: energyValid,
            energyInterpretation: energyInterpretation,
            elapsedEstimate: elapsedEstimate,
            elapsedMinimum: elapsedMinimum,
            elapsedMaximum: elapsedMaximum,
            deltaCPU: deltaCPU,
            deltaEnergy: deltaEnergy,
            deltaInstructions: deltaInstructions,
            deltaCycles: deltaCycles,
            joules: decimalScaled(deltaEnergy, places: 9),
            ergs: decimalScaled(deltaEnergy, places: 2),
            powerEstimate: ratio(deltaEnergy, elapsedEstimate),
            powerLower: ratio(deltaEnergy, elapsedMaximum),
            powerUpper: ratio(deltaEnergy, elapsedMinimum),
            cpuPercentEstimate: ratio(deltaCPU, elapsedEstimate, multiplier: 100),
            cpuPercentLower: ratio(deltaCPU, elapsedMaximum, multiplier: 100),
            cpuPercentUpper: ratio(deltaCPU, elapsedMinimum, multiplier: 100))
    } catch {
        return .unavailable("COUNTER_REGRESSION_OR_TIMING_INVALID")
    }
}

private func optionalString(_ value: String?) -> JSONValue {
    value.map(JSONValue.string) ?? .null
}

private func optionalUInt(_ value: UInt64?) -> JSONValue {
    value.map(JSONValue.uint) ?? .null
}

private func observationPayload(
    _ observation: ProcessObservation,
    round: Int,
    interval value: IntervalObservation
) -> JSONValue {
    let process: JSONValue
    if let join = observation.join {
        process = .object([
            "command_hex": .string(join.short.commandHex),
            "flags": .uint(UInt64(join.short.flags)),
            "gid": .uint(UInt64(join.short.gid)),
            "idversion": .int(Int64(join.unique.idVersion)),
            "parent_pid": .uint(UInt64(join.short.parentPID)),
            "parent_unique_id": .uint(join.unique.parentUniqueID),
            "pgid": .uint(UInt64(join.processGroupID)),
            "real_gid": .uint(UInt64(join.short.realGID)),
            "real_uid": .uint(UInt64(join.short.realUID)),
            "saved_gid": .uint(UInt64(join.short.savedGID)),
            "saved_uid": .uint(UInt64(join.short.savedUID)),
            "sid": .uint(UInt64(join.sessionID)),
            "status": .uint(UInt64(join.short.status)),
            "uid": .uint(UInt64(join.short.uid)),
            "unique_id": .uint(join.unique.uniqueID),
            "uuid_hex": .string(join.unique.uuidHex),
        ])
    } else {
        process = .null
    }
    let usage: JSONValue
    if let item = observation.usage {
        usage = .object([
            "cycles": .uint(item.cycles),
            "energy_nj": .uint(item.energyNJ),
            "instructions": .uint(item.instructions),
            "pcycles": .uint(item.pCycles),
            "penergy_nj": .uint(item.pEnergyNJ),
            "physical_footprint_bytes": .uint(item.physicalFootprint),
            "pinstructions": .uint(item.pInstructions),
            "process_exit_abstime": .uint(item.processExitAbstime),
            "process_start_abstime": .uint(item.processStartAbstime),
            "runnable_time": .uint(item.runnableTime),
            "system_ptime": .uint(item.systemPTime),
            "system_time": .uint(item.systemTime),
            "user_ptime": .uint(item.userPTime),
            "user_time": .uint(item.userTime),
            "uuid_hex": .string(item.uuidHex),
        ])
    } else {
        usage = .null
    }
    let intervalJSON = JSONValue.object([
        "average_power_at_estimated_interval_w_approx": optionalString(value.powerEstimate),
        "average_power_at_maximum_interval_w_approx": optionalString(value.powerLower),
        "average_power_at_minimum_interval_w_approx": optionalString(value.powerUpper),
        "cpu_percent_at_estimated_interval_approx": optionalString(value.cpuPercentEstimate),
        "cpu_percent_at_maximum_interval_approx": optionalString(value.cpuPercentLower),
        "cpu_percent_at_minimum_interval_approx": optionalString(value.cpuPercentUpper),
        "delta_cpu_ns": optionalUInt(value.deltaCPU),
        "delta_cycles": optionalUInt(value.deltaCycles),
        "delta_energy_nj": optionalUInt(value.deltaEnergy),
        "delta_ergs": optionalString(value.ergs),
        "delta_instructions": optionalUInt(value.deltaInstructions),
        "delta_joules": optionalString(value.joules),
        "energy_interpretation": .string(value.energyInterpretation),
        "energy_interpretation_valid": .bool(value.energyInterpretationValid),
        "elapsed_estimate_ns": optionalUInt(value.elapsedEstimate),
        "elapsed_maximum_ns": optionalUInt(value.elapsedMaximum),
        "elapsed_minimum_ns": optionalUInt(value.elapsedMinimum),
        "reason": .string(value.reason),
        "valid": .bool(value.valid),
    ])
    return .object([
        "authority_vector": .string(authorityVector),
        "availability": .string(observation.availability),
        "error": optionalString(observation.error),
        "gate_e_clearance": .uint(0),
        "gate_e_mechanics_outcome": .string("ABSTAIN"),
        "gate_e_scientific_outcome": .string("ABSTAIN"),
        "interval": intervalJSON,
        "label": .string(observation.target.label),
        "monotonic_after_ns": .uint(observation.monotonicAfter),
        "monotonic_before_ns": .uint(observation.monotonicBefore),
        "observed_utc": .string(observation.observedUTC),
        "pid": .uint(UInt64(observation.target.pid)),
        "process": process,
        "process_actuation_calls": .uint(0),
        "round": .uint(UInt64(round)),
        "rusage_v6": usage,
        "schema": .string("prime_driver_v2_r19_process_energy_observation_v1"),
        "scientific_authorities_closed": .uint(0),
        "signal_entries": .uint(0),
        "status": .string("OBSERVED_PRESENTATION_ONLY_NOT_IN_AUTHORITY_PREDICATE"),
    ])
}

private struct Frame {
    let ordinal: Int
    let kind: String
    let payloadSHA256: String
    let previousFrameSHA256: String?
    let rawWithLF: Data
    let frameSHA256: String
    let byteOffset: Int
}

private func makeFrame(
    ordinal: Int,
    kind: String,
    sessionID: String,
    payload: JSONValue,
    previous: String?,
    byteOffset: Int
) -> Frame {
    let payloadData = payload.encoded()
    let outer = JSONValue.object([
        "frame_kind": .string(kind),
        "ordinal": .uint(UInt64(ordinal)),
        "payload": payload,
        "payload_hash_rule": .string(payloadHashRule),
        "payload_sha256": .string(sha256(payloadData)),
        "previous_frame_sha256": optionalString(previous),
        "schema": .string(frameSchema),
        "session_id": .string(sessionID),
    ])
    var raw = outer.encoded()
    raw.append(0x0a)
    return Frame(
        ordinal: ordinal,
        kind: kind,
        payloadSHA256: sha256(payloadData),
        previousFrameSHA256: previous,
        rawWithLF: raw,
        frameSHA256: sha256(raw),
        byteOffset: byteOffset)
}

private final class TelemetryRoot {
    let parentDescriptor: Int32
    let rootDescriptor: Int32
    let parentPath: String
    let leaf: String
    private var expectedRootMode: mode_t = 0o700

    init() throws {
        let url = URL(fileURLWithPath: observationRootPath)
        parentPath = url.deletingLastPathComponent().path
        leaf = url.lastPathComponent
        try require(!leaf.isEmpty && !leaf.contains("/"), "root leaf")
        var resolved = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(parentPath, &resolved) != nil else {
            throw ObserverError.posix("realpath observation parent", errno)
        }
        let resolvedPath = String(
            decoding: resolved.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
            as: UTF8.self)
        try require(resolvedPath == parentPath, "observation parent alias")
        parentDescriptor = open(
            parentPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard parentDescriptor >= 0 else {
            throw ObserverError.posix("open observation parent", errno)
        }
        var heldParent = stat()
        var namedParent = stat()
        guard fstat(parentDescriptor, &heldParent) == 0 else {
            throw ObserverError.posix("fstat observation parent", errno)
        }
        guard lstat(parentPath, &namedParent) == 0 else {
            throw ObserverError.posix("lstat observation parent", errno)
        }
        try require(
            heldParent.st_dev == namedParent.st_dev &&
                heldParent.st_ino == namedParent.st_ino &&
                (heldParent.st_mode & S_IFMT) == S_IFDIR &&
                (namedParent.st_mode & S_IFMT) == S_IFDIR,
            "observation parent join")
        var existing = stat()
        errno = 0
        let prior = fstatat(parentDescriptor, leaf, &existing, AT_SYMLINK_NOFOLLOW)
        if prior == 0 || errno != ENOENT {
            _ = close(parentDescriptor)
            throw ObserverError.contract("observation root is not absent")
        }
        guard mkdirat(parentDescriptor, leaf, 0o700) == 0 else {
            let code = errno
            _ = close(parentDescriptor)
            throw ObserverError.posix("mkdirat observation root", code)
        }
        rootDescriptor = openat(
            parentDescriptor,
            leaf,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard rootDescriptor >= 0 else {
            let code = errno
            _ = close(parentDescriptor)
            throw ObserverError.posix("openat observation root", code)
        }
        var state = stat()
        guard fstat(rootDescriptor, &state) == 0 else {
            throw ObserverError.posix("fstat observation root", errno)
        }
        try require((state.st_mode & S_IFMT) == S_IFDIR, "observation root type")
        try require((state.st_mode & 0o7777) == 0o700, "observation root mode")
        try require(state.st_uid == expectedUID && state.st_gid == expectedGID, "root owner")
        try fullSync(parentDescriptor)
    }

    deinit {
        _ = close(rootDescriptor)
        _ = close(parentDescriptor)
    }

    func createFile(_ leaf: String, mode: mode_t) throws -> Int32 {
        let descriptor = openat(
            rootDescriptor,
            leaf,
            O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW_ANY,
            mode)
        guard descriptor >= 0 else { throw ObserverError.posix("openat \(leaf)", errno) }
        var transferOwnership = false
        defer { if !transferOwnership { _ = close(descriptor) } }
        var state = stat()
        guard fstat(descriptor, &state) == 0 else {
            throw ObserverError.posix("fstat \(leaf)", errno)
        }
        try require((state.st_mode & S_IFMT) == S_IFREG, "\(leaf) type")
        try require((state.st_mode & 0o7777) == mode, "\(leaf) mode")
        try require(state.st_uid == expectedUID && state.st_gid == expectedGID, "\(leaf) owner")
        try require(state.st_nlink == 1, "\(leaf) link count")
        try fullSync(rootDescriptor)
        transferOwnership = true
        return descriptor
    }

    func requireAbsent(_ leaf: String) throws {
        var state = stat()
        errno = 0
        let result = fstatat(rootDescriptor, leaf, &state, AT_SYMLINK_NOFOLLOW)
        try require(result != 0 && errno == ENOENT, "unexpected \(leaf)")
    }

    func revalidate() throws {
        var heldParent = stat()
        var namedParent = stat()
        var held = stat()
        var named = stat()
        guard fstat(parentDescriptor, &heldParent) == 0 else {
            throw ObserverError.posix("fstat held parent", errno)
        }
        guard lstat(parentPath, &namedParent) == 0 else {
            throw ObserverError.posix("lstat named parent", errno)
        }
        try require(
            heldParent.st_dev == namedParent.st_dev &&
                heldParent.st_ino == namedParent.st_ino &&
                (heldParent.st_mode & S_IFMT) == S_IFDIR &&
                (namedParent.st_mode & S_IFMT) == S_IFDIR,
            "observation parent rebound")
        guard fstat(rootDescriptor, &held) == 0 else {
            throw ObserverError.posix("fstat held root", errno)
        }
        guard fstatat(parentDescriptor, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0 else {
            throw ObserverError.posix("fstatat named root", errno)
        }
        try require(
            held.st_dev == named.st_dev && held.st_ino == named.st_ino,
            "observation root rebound")
        try require((named.st_mode & 0o7777) == expectedRootMode, "observation root mode drift")
    }

    func seal() throws {
        try require(expectedRootMode == 0o700, "observation root already sealed")
        guard fchmod(rootDescriptor, 0o500) == 0 else {
            throw ObserverError.posix("fchmod observation root", errno)
        }
        expectedRootMode = 0o500
        try fullSync(rootDescriptor)
        try fullSync(parentDescriptor)
        try revalidate()
    }

    func revalidateFile(
        descriptor: Int32,
        leaf: String,
        mode: mode_t,
        bytes: Int
    ) throws {
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0 else {
            throw ObserverError.posix("fstat held \(leaf)", errno)
        }
        guard fstatat(rootDescriptor, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0 else {
            throw ObserverError.posix("fstatat named \(leaf)", errno)
        }
        try require(
            held.st_dev == named.st_dev && held.st_ino == named.st_ino,
            "\(leaf) rebound")
        try require(sameSourceState(held, named), "\(leaf) held/named metadata drift")
        try require((held.st_mode & S_IFMT) == S_IFREG, "\(leaf) type drift")
        try require((held.st_mode & 0o7777) == mode, "\(leaf) mode drift")
        try require(held.st_uid == expectedUID && held.st_gid == expectedGID, "\(leaf) owner drift")
        try require(held.st_nlink == 1, "\(leaf) link count drift")
        try require(held.st_size == off_t(bytes), "\(leaf) size drift")
    }

    func readSealedFile(_ leaf: String, mode: mode_t, bytes: Int) throws -> Data {
        let descriptor = openat(
            rootDescriptor,
            leaf,
            O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard descriptor >= 0 else { throw ObserverError.posix("openat sealed \(leaf)", errno) }
        defer { _ = close(descriptor) }
        try revalidateFile(descriptor: descriptor, leaf: leaf, mode: mode, bytes: bytes)
        return try preadExact(descriptor, count: bytes, offset: 0)
    }

    func exactInventory() throws -> [String] {
        let duplicate = dup(rootDescriptor)
        guard duplicate >= 0 else { throw ObserverError.posix("dup observation root", errno) }
        guard let directory = fdopendir(duplicate) else {
            let code = errno
            _ = close(duplicate)
            throw ObserverError.posix("fdopendir observation root", code)
        }
        defer { closedir(directory) }
        var leaves: [String] = []
        errno = 0
        while let entry = readdir(directory) {
            var name = entry.pointee.d_name
            let leaf = withUnsafeBytes(of: &name) { raw -> String in
                let bytes = raw.prefix { $0 != 0 }
                return String(decoding: bytes, as: UTF8.self)
            }
            if leaf != "." && leaf != ".." { leaves.append(leaf) }
            errno = 0
        }
        try require(errno == 0, "readdir observation root")
        return leaves.sorted()
    }
}

private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

private final class SQLiteDatabase {
    private(set) var handle: OpaquePointer?

    init(path: String) throws {
        var database: OpaquePointer?
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX
        let result = sqlite3_open_v2(path, &database, flags, nil)
        guard result == SQLITE_OK, let database else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "no handle"
            if let database { sqlite3_close(database) }
            throw ObserverError.sqlite("sqlite3_open_v2", result, message)
        }
        handle = database
        sqlite3_extended_result_codes(database, 1)
        sqlite3_busy_timeout(database, 30_000)
    }

    deinit {
        if let handle { sqlite3_close(handle) }
    }

    func close() throws {
        guard let handle else { return }
        let result = sqlite3_close(handle)
        guard result == SQLITE_OK else { throw sqliteError("sqlite3_close", result) }
        self.handle = nil
    }

    func execute(_ sql: String) throws {
        guard let handle else { throw ObserverError.contract("database closed") }
        var message: UnsafeMutablePointer<CChar>?
        let result = sqlite3_exec(handle, sql, nil, nil, &message)
        let text = message.map { String(cString: $0) } ?? String(cString: sqlite3_errmsg(handle))
        if let message { sqlite3_free(message) }
        guard result == SQLITE_OK else { throw ObserverError.sqlite("sqlite3_exec", result, text) }
    }

    func prepare(_ sql: String) throws -> OpaquePointer {
        guard let handle else { throw ObserverError.contract("database closed") }
        var statement: OpaquePointer?
        let result = sqlite3_prepare_v2(handle, sql, -1, &statement, nil)
        guard result == SQLITE_OK, let statement else {
            throw sqliteError("sqlite3_prepare_v2", result)
        }
        return statement
    }

    func stepDone(_ statement: OpaquePointer) throws {
        let result = sqlite3_step(statement)
        guard result == SQLITE_DONE else { throw sqliteError("sqlite3_step", result) }
    }

    func scalarInt(_ sql: String) throws -> Int64 {
        let statement = try prepare(sql)
        defer { sqlite3_finalize(statement) }
        let result = sqlite3_step(statement)
        guard result == SQLITE_ROW else { throw sqliteError("sqlite3_step scalar", result) }
        let value = sqlite3_column_int64(statement, 0)
        try require(sqlite3_step(statement) == SQLITE_DONE, "scalar query returned multiple rows")
        return value
    }

    func scalarText(_ sql: String) throws -> String {
        let statement = try prepare(sql)
        defer { sqlite3_finalize(statement) }
        let result = sqlite3_step(statement)
        guard result == SQLITE_ROW else { throw sqliteError("sqlite3_step text", result) }
        guard let value = sqlite3_column_text(statement, 0) else {
            throw ObserverError.contract("scalar text was NULL")
        }
        let text = String(cString: value)
        try require(sqlite3_step(statement) == SQLITE_DONE, "text query returned multiple rows")
        return text
    }

    func serialized() throws -> Data {
        guard let handle else { throw ObserverError.contract("database closed") }
        var byteCount: sqlite3_int64 = 0
        guard let pointer = sqlite3_serialize(handle, "main", &byteCount, 0) else {
            throw sqliteError("sqlite3_serialize", sqlite3_errcode(handle))
        }
        defer { sqlite3_free(pointer) }
        try require(byteCount > 0 && byteCount <= sqlite3_int64(Int32.max), "database size cap")
        return Data(bytes: pointer, count: Int(byteCount))
    }

    func sqliteError(_ operation: String, _ code: Int32) -> ObserverError {
        let message = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "closed"
        return .sqlite(operation, code, message)
    }
}

private func bindText(_ statement: OpaquePointer, _ index: Int32, _ value: String?) throws {
    let result: Int32
    if let value {
        result = sqlite3_bind_text(statement, index, value, -1, sqliteTransient)
    } else {
        result = sqlite3_bind_null(statement, index)
    }
    try require(result == SQLITE_OK, "sqlite bind text")
}

private func bindInt64(_ statement: OpaquePointer, _ index: Int32, _ value: Int64) throws {
    try require(sqlite3_bind_int64(statement, index, value) == SQLITE_OK, "sqlite bind int64")
}

private func bindBlob(_ statement: OpaquePointer, _ index: Int32, _ value: Data) throws {
    let result = value.withUnsafeBytes { raw -> Int32 in
        sqlite3_bind_blob(statement, index, raw.baseAddress, Int32(raw.count), sqliteTransient)
    }
    try require(result == SQLITE_OK, "sqlite bind blob")
}

private func bindOptionalUIntText(
    _ statement: OpaquePointer,
    _ index: Int32,
    _ value: UInt64?
) throws {
    try bindText(statement, index, value.map(String.init))
}

private func sampleProjectionValues(
    round: Int,
    observation: ProcessObservation,
    interval value: IntervalObservation
) -> [String?] {
    [
        String(round),
        observation.target.label,
        String(observation.target.pid),
        observation.availability,
        observation.join.map { String($0.unique.uniqueID) },
        observation.join.map { String($0.unique.idVersion) },
        observation.join.map { String($0.sessionID) },
        observation.join.map { String($0.processGroupID) },
        observation.join.map { String($0.short.status) },
        observation.usage.map { String($0.energyNJ) },
        value.valid ? "1" : "0",
        value.reason,
        value.energyInterpretationValid ? "1" : "0",
        value.energyInterpretation,
        value.elapsedEstimate.map(String.init),
        value.elapsedMinimum.map(String.init),
        value.elapsedMaximum.map(String.init),
        value.deltaCPU.map(String.init),
        value.deltaEnergy.map(String.init),
        value.joules,
        value.ergs,
        value.powerEstimate,
        value.powerLower,
        value.powerUpper,
        value.cpuPercentEstimate,
        value.cpuPercentLower,
        value.cpuPercentUpper,
    ]
}

private func sqliteColumnOptionalText(
    _ statement: OpaquePointer,
    _ index: Int32
) -> String? {
    if sqlite3_column_type(statement, index) == SQLITE_NULL { return nil }
    guard let value = sqlite3_column_text(statement, index) else { return nil }
    return String(cString: value)
}

private let databaseSchema = """
PRAGMA journal_mode=MEMORY;
PRAGMA synchronous=FULL;
PRAGMA temp_store=MEMORY;
PRAGMA foreign_keys=ON;
PRAGMA trusted_schema=OFF;
PRAGMA application_id=1347569202;
PRAGMA user_version=1;
CREATE TABLE metadata(key TEXT PRIMARY KEY,value TEXT NOT NULL) STRICT;
CREATE TABLE source_snapshot(
 singleton INTEGER PRIMARY KEY CHECK(singleton=1),
 logical_path TEXT NOT NULL,
 source_commit TEXT NOT NULL CHECK(length(source_commit)=40),
 source_tree TEXT NOT NULL CHECK(length(source_tree)=40),
 source_blob TEXT NOT NULL CHECK(length(source_blob)=40),
 source_sha256 TEXT NOT NULL UNIQUE CHECK(length(source_sha256)=64),
 source_bytes INTEGER NOT NULL CHECK(source_bytes>=0),
 source_lines INTEGER NOT NULL CHECK(source_lines>=0),
 raw_source BLOB NOT NULL,
 CHECK(length(raw_source)=source_bytes)
) STRICT;
CREATE TABLE source_records(
 line_number INTEGER PRIMARY KEY CHECK(line_number>0),
 byte_offset INTEGER NOT NULL CHECK(byte_offset>=0),
 byte_count INTEGER NOT NULL CHECK(byte_count>0),
 raw_sha256 TEXT NOT NULL CHECK(length(raw_sha256)=64),
 raw_json BLOB NOT NULL,
 schema_name TEXT NOT NULL,
 status TEXT NOT NULL,
 markdown_context TEXT NOT NULL CHECK(markdown_context IN('JSON_FENCE','OTHER_FENCE','OUTSIDE_FENCE')),
 validation_state TEXT NOT NULL,
 CHECK(length(raw_json)=byte_count)
) STRICT;
CREATE TABLE source_lexical_references(
 line_number INTEGER NOT NULL REFERENCES source_records(line_number),
 json_pointer TEXT NOT NULL,
 lexical_kind TEXT NOT NULL CHECK(lexical_kind IN('HEX_40','HEX_64')),
 exact_value TEXT NOT NULL,
 PRIMARY KEY(line_number,json_pointer,exact_value)
) STRICT,WITHOUT ROWID;
CREATE TABLE capture_session(
 session_id TEXT PRIMARY KEY CHECK(session_id='r19-observability-eaf9b76-v1'),
 source_sha256 TEXT NOT NULL REFERENCES source_snapshot(source_sha256),
 authority_vector TEXT NOT NULL CHECK(authority_vector='00000000'),
 mechanics_outcome TEXT NOT NULL CHECK(mechanics_outcome='ABSTAIN'),
 scientific_outcome TEXT NOT NULL CHECK(scientific_outcome='ABSTAIN'),
 scientific_authorities_closed INTEGER NOT NULL CHECK(scientific_authorities_closed=0),
 target_inventory_sha256 TEXT NOT NULL CHECK(length(target_inventory_sha256)=64),
 sample_rounds INTEGER NOT NULL CHECK(sample_rounds=2),
 interval_nanoseconds_text TEXT NOT NULL
) STRICT;
CREATE TABLE frames(
 session_id TEXT NOT NULL REFERENCES capture_session(session_id),
 ordinal INTEGER NOT NULL CHECK(ordinal>=0),
 frame_kind TEXT NOT NULL CHECK(frame_kind IN('session','sample','seal')),
 byte_offset INTEGER NOT NULL CHECK(byte_offset>=0),
 frame_bytes INTEGER NOT NULL CHECK(frame_bytes>1),
 frame_sha256 TEXT NOT NULL UNIQUE CHECK(length(frame_sha256)=64),
 previous_frame_sha256 TEXT CHECK(previous_frame_sha256 IS NULL OR length(previous_frame_sha256)=64),
 payload_sha256 TEXT NOT NULL CHECK(length(payload_sha256)=64),
 raw_frame BLOB NOT NULL,
 PRIMARY KEY(session_id,ordinal),
 UNIQUE(session_id,byte_offset),
 CHECK(length(raw_frame)=frame_bytes)
) STRICT,WITHOUT ROWID;
CREATE TABLE process_samples(
 session_id TEXT NOT NULL,
 ordinal INTEGER NOT NULL,
 sample_round INTEGER NOT NULL CHECK(sample_round IN(0,1)),
 target_label TEXT NOT NULL,
 pid INTEGER NOT NULL,
 availability TEXT NOT NULL,
 unique_id_text TEXT,
 idversion_text TEXT,
 sid_text TEXT,
 pgid_text TEXT,
 process_status_text TEXT,
 energy_nj_text TEXT,
 interval_valid INTEGER NOT NULL CHECK(interval_valid IN(0,1)),
 interval_reason TEXT NOT NULL,
 energy_interpretation_valid INTEGER NOT NULL CHECK(energy_interpretation_valid IN(0,1)),
 energy_interpretation TEXT NOT NULL,
 elapsed_estimate_ns_text TEXT,
 elapsed_minimum_ns_text TEXT,
 elapsed_maximum_ns_text TEXT,
 delta_cpu_ns_text TEXT,
 delta_energy_nj_text TEXT,
 delta_joules_text TEXT,
 delta_ergs_text TEXT,
 average_power_at_estimated_interval_w_approx_text TEXT,
 average_power_at_maximum_interval_w_approx_text TEXT,
 average_power_at_minimum_interval_w_approx_text TEXT,
 cpu_percent_at_estimated_interval_approx_text TEXT,
 cpu_percent_at_maximum_interval_approx_text TEXT,
 cpu_percent_at_minimum_interval_approx_text TEXT,
 PRIMARY KEY(session_id,ordinal),
 UNIQUE(session_id,sample_round,target_label),
 FOREIGN KEY(session_id,ordinal) REFERENCES frames(session_id,ordinal)
) STRICT,WITHOUT ROWID;
CREATE TABLE capture_seal(
 singleton INTEGER PRIMARY KEY CHECK(singleton=1),
 session_id TEXT NOT NULL REFERENCES capture_session(session_id),
 journal_bytes INTEGER NOT NULL CHECK(journal_bytes>0),
 journal_sha256 TEXT NOT NULL CHECK(length(journal_sha256)=64),
 frame_count INTEGER NOT NULL CHECK(frame_count=8),
 seal_frame_sha256 TEXT NOT NULL CHECK(length(seal_frame_sha256)=64),
 source_record_count INTEGER NOT NULL CHECK(source_record_count>=0),
 completed_utc TEXT NOT NULL
) STRICT;
CREATE VIEW process_sample_projection AS SELECT * FROM process_samples;
CREATE VIEW valid_interval_projection AS SELECT * FROM process_samples WHERE interval_valid=1;
CREATE VIEW valid_energy_interval_projection AS
 SELECT * FROM process_samples
 WHERE interval_valid=1 AND energy_interpretation_valid=1;
CREATE VIEW canonical_json_fence_hex_occurrences AS
 SELECT line_number,json_pointer,lexical_kind,exact_value
 FROM source_lexical_references;
CREATE VIEW canonical_json_fence_candidates AS
 SELECT 0 AS authoritative,line_number,byte_offset,byte_count,raw_sha256,
        schema_name,status,validation_state
 FROM source_records
 WHERE validation_state='CANONICAL_JSON_FENCE_LINE_PRESENTATION_CANDIDATE_NOT_AUTHORITY';
CREATE VIEW presentation_authority_boundary AS
 SELECT 0 AS authoritative,
        'false' AS projection_may_feed_controller,
        source_sha256,
        authority_vector,mechanics_outcome,scientific_outcome,scientific_authorities_closed
 FROM capture_session;
CREATE TRIGGER metadata_no_update BEFORE UPDATE ON metadata BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER metadata_no_delete BEFORE DELETE ON metadata BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER source_snapshot_no_update BEFORE UPDATE ON source_snapshot BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER source_snapshot_no_delete BEFORE DELETE ON source_snapshot BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER source_records_no_update BEFORE UPDATE ON source_records BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER source_records_no_delete BEFORE DELETE ON source_records BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER source_lexical_references_no_update BEFORE UPDATE ON source_lexical_references BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER source_lexical_references_no_delete BEFORE DELETE ON source_lexical_references BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER capture_session_no_update BEFORE UPDATE ON capture_session BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER capture_session_no_delete BEFORE DELETE ON capture_session BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER frames_no_update BEFORE UPDATE ON frames BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER frames_no_delete BEFORE DELETE ON frames BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER process_samples_no_update BEFORE UPDATE ON process_samples BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER process_samples_no_delete BEFORE DELETE ON process_samples BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER capture_seal_no_update BEFORE UPDATE ON capture_seal BEGIN SELECT RAISE(ABORT,'append-only'); END;
CREATE TRIGGER capture_seal_no_delete BEFORE DELETE ON capture_seal BEGIN SELECT RAISE(ABORT,'append-only'); END;
"""

private struct IndexedSourceRecord {
    let lineNumber: Int
    let byteOffset: Int
    let raw: Data
    let rawSHA256: String
    let schema: String
    let status: String
    let markdownContext: String
    let validation: String
    let lexicalReferences: [IndexedLexicalReference]
}

private struct IndexedLexicalReference {
    let jsonPointer: String
    let lexicalKind: String
    let exactValue: String
}

private func escapedJSONPointerToken(_ value: String) -> String {
    value.replacingOccurrences(of: "~", with: "~0")
        .replacingOccurrences(of: "/", with: "~1")
}

private func collectLexicalReferences(
    _ value: Any,
    pointer: String,
    into output: inout [IndexedLexicalReference]
) {
    if let dictionary = value as? [String: Any] {
        for key in dictionary.keys.sorted() {
            collectLexicalReferences(
                dictionary[key]!,
                pointer: pointer + "/" + escapedJSONPointerToken(key),
                into: &output)
        }
    } else if let array = value as? [Any] {
        for (index, item) in array.enumerated() {
            collectLexicalReferences(item, pointer: pointer + "/" + String(index), into: &output)
        }
    } else if let string = value as? String {
        let isHex = string.utf8.allSatisfy {
            ($0 >= 0x30 && $0 <= 0x39) || ($0 >= 0x61 && $0 <= 0x66)
        }
        if isHex && (string.utf8.count == 40 || string.utf8.count == 64) {
            output.append(.init(
                jsonPointer: pointer,
                lexicalKind: string.utf8.count == 40 ? "HEX_40" : "HEX_64",
                exactValue: string))
        }
    }
}

private func indexSourceRecords(_ source: Data) throws -> [IndexedSourceRecord] {
    var records: [IndexedSourceRecord] = []
    var start = 0
    var line = 1
    var fenceLanguage: String?
    let bytes = [UInt8](source)
    for end in 0...bytes.count {
        if end == bytes.count || bytes[end] == 0x0a {
            let raw = Data(bytes[start..<end])
            let lineText = String(data: raw, encoding: .utf8)
            let markdownContext: String
            if fenceLanguage == "json" {
                markdownContext = "JSON_FENCE"
            } else if fenceLanguage != nil {
                markdownContext = "OTHER_FENCE"
            } else {
                markdownContext = "OUTSIDE_FENCE"
            }
            if let lineText, lineText.hasPrefix("```") {
                if fenceLanguage == nil {
                    fenceLanguage = String(lineText.dropFirst(3)).lowercased()
                } else if lineText == "```" {
                    fenceLanguage = nil
                }
            } else if raw.first == UInt8(ascii: "{"), raw.last == UInt8(ascii: "}") {
                do {
                    let object = try JSONSerialization.jsonObject(with: raw)
                    if let dictionary = object as? [String: Any],
                       let schema = dictionary["schema"] as? String,
                       let status = dictionary["status"] as? String
                    {
                        let canonical = try JSONSerialization.data(
                            withJSONObject: dictionary,
                            options: [.sortedKeys, .withoutEscapingSlashes])
                        let validation: String
                        if canonical == raw && markdownContext == "JSON_FENCE" {
                            validation =
                                "CANONICAL_JSON_FENCE_LINE_PRESENTATION_CANDIDATE_NOT_AUTHORITY"
                        } else if canonical == raw {
                            validation =
                                "CANONICAL_JSON_OBJECT_LINE_OUTSIDE_JSON_FENCE_PRESENTATION_ONLY"
                        } else {
                            validation =
                                "PARSED_JSON_OBJECT_LINE_NONCANONICAL_PRESENTATION_ONLY"
                        }
                        var lexicalReferences: [IndexedLexicalReference] = []
                        if validation ==
                            "CANONICAL_JSON_FENCE_LINE_PRESENTATION_CANDIDATE_NOT_AUTHORITY"
                        {
                            collectLexicalReferences(
                                dictionary,
                                pointer: "",
                                into: &lexicalReferences)
                        }
                        records.append(.init(
                            lineNumber: line,
                            byteOffset: start,
                            raw: raw,
                            rawSHA256: sha256(raw),
                            schema: schema,
                            status: status,
                            markdownContext: markdownContext,
                            validation: validation,
                            lexicalReferences: lexicalReferences))
                    }
                } catch {
                    // Prose examples are intentionally not promoted into records.
                }
            }
            start = end + 1
            line += 1
        }
    }
    return records
}

private func targetInventoryJSON() -> JSONValue {
    .array(targets.map { target in
        .object([
            "idversion": .int(Int64(target.idVersion)),
            "label": .string(target.label),
            "pgid": .uint(UInt64(target.processGroupID)),
            "pid": .uint(UInt64(target.pid)),
            "sid": .uint(UInt64(target.sessionID)),
            "unique_id": .uint(target.uniqueID),
        ])
    })
}

private func bindMetadata(_ database: SQLiteDatabase, key: String, value: String) throws {
    let statement = try database.prepare("INSERT INTO metadata(key,value) VALUES(?,?)")
    defer { sqlite3_finalize(statement) }
    try bindText(statement, 1, key)
    try bindText(statement, 2, value)
    try database.stepDone(statement)
}

private func buildDatabase(
    root: TelemetryRoot?,
    source: Data,
    sourceRecords: [IndexedSourceRecord],
    sessionID: String,
    frames: [Frame],
    samples: [(Int, Int, ProcessObservation, IntervalObservation)],
    journalSHA256: String,
    completedUTC: String
) throws -> (bytes: Int, sha256: String) {
    if let root { try root.requireAbsent(databaseLeaf) }
    var reconstructedJournal = Data()
    for (index, frame) in frames.enumerated() {
        try require(frame.ordinal == index, "database frame ordinal chain")
        try require(frame.byteOffset == reconstructedJournal.count, "database frame offset chain")
        try require(frame.frameSHA256 == sha256(frame.rawWithLF), "database frame hash chain")
        try require(
            frame.previousFrameSHA256 == (index == 0 ? nil : frames[index - 1].frameSHA256),
            "database previous frame chain")
        reconstructedJournal.append(frame.rawWithLF)
    }
    try require(frames.first?.kind == "session", "database session frame")
    try require(frames.last?.kind == "seal", "database seal frame")
    try require(sha256(reconstructedJournal) == journalSHA256, "database journal hash binding")
    for (ordinal, round, observation, intervalValue) in samples {
        try require(ordinal > 0 && ordinal < frames.count - 1, "sample frame ordinal")
        let admitted = frames[ordinal]
        try require(admitted.kind == "sample", "sample frame kind")
        let reconstructed = makeFrame(
            ordinal: ordinal,
            kind: "sample",
            sessionID: sessionID,
            payload: observationPayload(observation, round: round, interval: intervalValue),
            previous: admitted.previousFrameSHA256,
            byteOffset: admitted.byteOffset)
        try require(
            reconstructed.rawWithLF == admitted.rawWithLF,
            "normalized sample source disagrees with frame bytes")
    }
    let database = try SQLiteDatabase(path: ":memory:")
    try database.execute(databaseSchema)
    try database.execute("BEGIN IMMEDIATE")
    do {
        let metadata: [String: String] = [
            "authority_vector": authorityVector,
            "canonical_control_ledger_remains_sole_authority": "true",
            "gate_e_mechanics_outcome": "ABSTAIN",
            "gate_e_scientific_outcome": "ABSTAIN",
            "external_sha256_admission_required": "true",
            "observer_children": "0",
            "process_actuation_calls": "0",
            "process_sample_projection_is_normalized_subset": "true",
            "process_sample_projection_join": "frames.session_id_ordinal_exact_raw_frame_available",
            "projection_may_feed_controller": "false",
            "projection_role":
                "PRESENTATION_SNAPSHOT_CANDIDATE_REQUIRES_FINAL_ROOT_MODE_AND_EXTERNAL_HASH_ADMISSION",
            "scientific_authorities_closed": "0",
            "same_uid_mutation_residual":
                "POINT_IN_TIME_VNODE_METADATA_HASH_AND_INVENTORY_CHECKS_NO_PRIVILEGED_IMMUTABILITY",
            "signal_entries": "0",
            "sqlite_construction": "IN_MEMORY_SERIALIZE_DIRECT_DESCRIPTOR_WRITE_NO_PATH_OPEN",
            "sqlite_consumer_open_mode": "READ_ONLY_IMMUTABLE_WITH_EXPECTED_SHA256",
        ]
        for (key, value) in metadata.sorted(by: { $0.key < $1.key }) {
            try bindMetadata(database, key: key, value: value)
        }
        let sourceStatement = try database.prepare(
            "INSERT INTO source_snapshot(" +
            "singleton,logical_path,source_commit,source_tree,source_blob," +
            "source_sha256,source_bytes,source_lines,raw_source) " +
            "VALUES(1,?,?,?,?,?,?,?,?)")
        defer { sqlite3_finalize(sourceStatement) }
        try bindText(sourceStatement, 1, "docs/PRIME-SWIFT-VALIDATION-DRIVER-V2-DURABLE-PHASE-CONTROL-2026-08-22.md")
        try bindText(sourceStatement, 2, controlCommit)
        try bindText(sourceStatement, 3, controlTree)
        try bindText(sourceStatement, 4, controlBlob)
        try bindText(sourceStatement, 5, controlSHA256)
        try bindInt64(sourceStatement, 6, Int64(source.count))
        try bindInt64(sourceStatement, 7, Int64(source.filter { $0 == 0x0a }.count))
        try bindBlob(sourceStatement, 8, source)
        try database.stepDone(sourceStatement)

        let recordStatement = try database.prepare(
            "INSERT INTO source_records(" +
            "line_number,byte_offset,byte_count,raw_sha256,raw_json,schema_name," +
            "status,markdown_context,validation_state) VALUES(?,?,?,?,?,?,?,?,?)")
        defer { sqlite3_finalize(recordStatement) }
        let referenceStatement = try database.prepare(
            "INSERT INTO source_lexical_references(" +
            "line_number,json_pointer,lexical_kind,exact_value) VALUES(?,?,?,?)")
        defer { sqlite3_finalize(referenceStatement) }
        for record in sourceRecords {
            sqlite3_reset(recordStatement)
            sqlite3_clear_bindings(recordStatement)
            try bindInt64(recordStatement, 1, Int64(record.lineNumber))
            try bindInt64(recordStatement, 2, Int64(record.byteOffset))
            try bindInt64(recordStatement, 3, Int64(record.raw.count))
            try bindText(recordStatement, 4, record.rawSHA256)
            try bindBlob(recordStatement, 5, record.raw)
            try bindText(recordStatement, 6, record.schema)
            try bindText(recordStatement, 7, record.status)
            try bindText(recordStatement, 8, record.markdownContext)
            try bindText(recordStatement, 9, record.validation)
            try database.stepDone(recordStatement)
            for reference in record.lexicalReferences {
                sqlite3_reset(referenceStatement)
                sqlite3_clear_bindings(referenceStatement)
                try bindInt64(referenceStatement, 1, Int64(record.lineNumber))
                try bindText(referenceStatement, 2, reference.jsonPointer)
                try bindText(referenceStatement, 3, reference.lexicalKind)
                try bindText(referenceStatement, 4, reference.exactValue)
                try database.stepDone(referenceStatement)
            }
        }

        let targetHash = sha256(targetInventoryJSON().encoded())
        let sessionStatement = try database.prepare(
            "INSERT INTO capture_session(" +
            "session_id,source_sha256,authority_vector,mechanics_outcome," +
            "scientific_outcome,scientific_authorities_closed," +
            "target_inventory_sha256,sample_rounds,interval_nanoseconds_text) " +
            "VALUES(?,?,?,?,?,?,?,?,?)")
        defer { sqlite3_finalize(sessionStatement) }
        try bindText(sessionStatement, 1, sessionID)
        try bindText(sessionStatement, 2, controlSHA256)
        try bindText(sessionStatement, 3, authorityVector)
        try bindText(sessionStatement, 4, "ABSTAIN")
        try bindText(sessionStatement, 5, "ABSTAIN")
        try bindInt64(sessionStatement, 6, 0)
        try bindText(sessionStatement, 7, targetHash)
        try bindInt64(sessionStatement, 8, Int64(sampleRoundCount))
        try bindText(sessionStatement, 9, String(intervalNanoseconds))
        try database.stepDone(sessionStatement)

        let frameStatement = try database.prepare(
            "INSERT INTO frames(" +
            "session_id,ordinal,frame_kind,byte_offset,frame_bytes,frame_sha256," +
            "previous_frame_sha256,payload_sha256,raw_frame) VALUES(?,?,?,?,?,?,?,?,?)")
        defer { sqlite3_finalize(frameStatement) }
        for frame in frames {
            sqlite3_reset(frameStatement)
            sqlite3_clear_bindings(frameStatement)
            try bindText(frameStatement, 1, sessionID)
            try bindInt64(frameStatement, 2, Int64(frame.ordinal))
            try bindText(frameStatement, 3, frame.kind)
            try bindInt64(frameStatement, 4, Int64(frame.byteOffset))
            try bindInt64(frameStatement, 5, Int64(frame.rawWithLF.count))
            try bindText(frameStatement, 6, frame.frameSHA256)
            try bindText(frameStatement, 7, frame.previousFrameSHA256)
            try bindText(frameStatement, 8, frame.payloadSHA256)
            try bindBlob(frameStatement, 9, frame.rawWithLF)
            try database.stepDone(frameStatement)
        }

        let sampleStatement = try database.prepare(
            "INSERT INTO process_samples(" +
            "session_id,ordinal,sample_round,target_label,pid,availability," +
            "unique_id_text,idversion_text,sid_text,pgid_text,process_status_text," +
            "energy_nj_text,interval_valid,interval_reason," +
            "energy_interpretation_valid,energy_interpretation,elapsed_estimate_ns_text," +
            "elapsed_minimum_ns_text,elapsed_maximum_ns_text,delta_cpu_ns_text," +
            "delta_energy_nj_text,delta_joules_text,delta_ergs_text," +
            "average_power_at_estimated_interval_w_approx_text," +
            "average_power_at_maximum_interval_w_approx_text," +
            "average_power_at_minimum_interval_w_approx_text," +
            "cpu_percent_at_estimated_interval_approx_text," +
            "cpu_percent_at_maximum_interval_approx_text," +
            "cpu_percent_at_minimum_interval_approx_text) VALUES(" +
            String(repeating: "?,", count: 28) + "?)")
        defer { sqlite3_finalize(sampleStatement) }
        for (ordinal, round, observation, intervalValue) in samples {
            sqlite3_reset(sampleStatement)
            sqlite3_clear_bindings(sampleStatement)
            try bindText(sampleStatement, 1, sessionID)
            try bindInt64(sampleStatement, 2, Int64(ordinal))
            try bindInt64(sampleStatement, 3, Int64(round))
            try bindText(sampleStatement, 4, observation.target.label)
            try bindInt64(sampleStatement, 5, Int64(observation.target.pid))
            try bindText(sampleStatement, 6, observation.availability)
            try bindText(sampleStatement, 7, observation.join.map { String($0.unique.uniqueID) })
            try bindText(sampleStatement, 8, observation.join.map { String($0.unique.idVersion) })
            try bindText(sampleStatement, 9, observation.join.map { String($0.sessionID) })
            try bindText(sampleStatement, 10, observation.join.map { String($0.processGroupID) })
            try bindText(sampleStatement, 11, observation.join.map { String($0.short.status) })
            try bindText(sampleStatement, 12, observation.usage.map { String($0.energyNJ) })
            try bindInt64(sampleStatement, 13, intervalValue.valid ? 1 : 0)
            try bindText(sampleStatement, 14, intervalValue.reason)
            try bindInt64(sampleStatement, 15, intervalValue.energyInterpretationValid ? 1 : 0)
            try bindText(sampleStatement, 16, intervalValue.energyInterpretation)
            try bindOptionalUIntText(sampleStatement, 17, intervalValue.elapsedEstimate)
            try bindOptionalUIntText(sampleStatement, 18, intervalValue.elapsedMinimum)
            try bindOptionalUIntText(sampleStatement, 19, intervalValue.elapsedMaximum)
            try bindOptionalUIntText(sampleStatement, 20, intervalValue.deltaCPU)
            try bindOptionalUIntText(sampleStatement, 21, intervalValue.deltaEnergy)
            try bindText(sampleStatement, 22, intervalValue.joules)
            try bindText(sampleStatement, 23, intervalValue.ergs)
            try bindText(sampleStatement, 24, intervalValue.powerEstimate)
            try bindText(sampleStatement, 25, intervalValue.powerLower)
            try bindText(sampleStatement, 26, intervalValue.powerUpper)
            try bindText(sampleStatement, 27, intervalValue.cpuPercentEstimate)
            try bindText(sampleStatement, 28, intervalValue.cpuPercentLower)
            try bindText(sampleStatement, 29, intervalValue.cpuPercentUpper)
            try database.stepDone(sampleStatement)
        }

        guard let seal = frames.last, seal.kind == "seal" else {
            throw ObserverError.contract("terminal seal frame absent")
        }
        let journalBytes = frames.reduce(0) { $0 + $1.rawWithLF.count }
        let sealStatement = try database.prepare(
            "INSERT INTO capture_seal(" +
            "singleton,session_id,journal_bytes,journal_sha256,frame_count," +
            "seal_frame_sha256,source_record_count,completed_utc) " +
            "VALUES(1,?,?,?,?,?,?,?)")
        defer { sqlite3_finalize(sealStatement) }
        try bindText(sealStatement, 1, sessionID)
        try bindInt64(sealStatement, 2, Int64(journalBytes))
        try bindText(sealStatement, 3, journalSHA256)
        try bindInt64(sealStatement, 4, Int64(frames.count))
        try bindText(sealStatement, 5, seal.frameSHA256)
        try bindInt64(sealStatement, 6, Int64(sourceRecords.count))
        try bindText(sealStatement, 7, completedUTC)
        try database.stepDone(sealStatement)

        try database.execute("COMMIT")
    } catch {
        try? database.execute("ROLLBACK")
        throw error
    }

    let quickCheck = try database.scalarText("PRAGMA quick_check")
    try require(quickCheck == "ok", "SQLite quick_check")
    let foreignKeyFailures = try database.scalarInt(
        "SELECT count(*) FROM pragma_foreign_key_check")
    try require(
        foreignKeyFailures == 0,
        "SQLite foreign key check")
    let projectedFrameCount = try database.scalarInt("SELECT count(*) FROM frames")
    try require(
        projectedFrameCount == Int64(frames.count),
        "SQLite frame count")
    let projectedSampleCount = try database.scalarInt("SELECT count(*) FROM process_samples")
    try require(
        projectedSampleCount == Int64(samples.count),
        "SQLite sample count")
    do {
        let frameRead = try database.prepare(
            "SELECT ordinal,raw_frame FROM frames ORDER BY ordinal")
        defer { sqlite3_finalize(frameRead) }
        var verifiedFrames = 0
        while true {
            let result = sqlite3_step(frameRead)
            if result == SQLITE_DONE { break }
            guard result == SQLITE_ROW else {
                throw database.sqliteError("frame verification", result)
            }
            let ordinal = Int(sqlite3_column_int64(frameRead, 0))
            try require(
                ordinal == verifiedFrames && ordinal < frames.count,
                "frame ordinal projection")
            let count = Int(sqlite3_column_bytes(frameRead, 1))
            guard let bytes = sqlite3_column_blob(frameRead, 1) else {
                throw ObserverError.contract("projected frame BLOB absent")
            }
            let projected = Data(bytes: bytes, count: count)
            try require(projected == frames[ordinal].rawWithLF, "projected frame bytes mismatch")
            verifiedFrames += 1
        }
        try require(verifiedFrames == frames.count, "projected frame verification count")
    }
    do {
        let projectionRead = try database.prepare(
            "SELECT ordinal,sample_round,target_label,pid,availability,unique_id_text," +
            "idversion_text,sid_text,pgid_text,process_status_text,energy_nj_text," +
            "interval_valid,interval_reason,energy_interpretation_valid," +
            "energy_interpretation,elapsed_estimate_ns_text,elapsed_minimum_ns_text," +
            "elapsed_maximum_ns_text,delta_cpu_ns_text,delta_energy_nj_text," +
            "delta_joules_text,delta_ergs_text," +
            "average_power_at_estimated_interval_w_approx_text," +
            "average_power_at_maximum_interval_w_approx_text," +
            "average_power_at_minimum_interval_w_approx_text," +
            "cpu_percent_at_estimated_interval_approx_text," +
            "cpu_percent_at_maximum_interval_approx_text," +
            "cpu_percent_at_minimum_interval_approx_text " +
            "FROM process_samples ORDER BY ordinal")
        defer { sqlite3_finalize(projectionRead) }
        let orderedSamples = samples.sorted { $0.0 < $1.0 }
        var row = 0
        while true {
            let result = sqlite3_step(projectionRead)
            if result == SQLITE_DONE { break }
            guard result == SQLITE_ROW else {
                throw database.sqliteError("sample projection verification", result)
            }
            try require(row < orderedSamples.count, "extra sample projection row")
            let expected = orderedSamples[row]
            try require(
                Int(sqlite3_column_int64(projectionRead, 0)) == expected.0,
                "sample projection ordinal")
            let expectedValues = sampleProjectionValues(
                round: expected.1,
                observation: expected.2,
                interval: expected.3)
            try require(expectedValues.count == 27, "sample projection value arity")
            for index in 0..<expectedValues.count {
                let projected = sqliteColumnOptionalText(
                    projectionRead,
                    Int32(index + 1))
                try require(
                    projected == expectedValues[index],
                    "sample projection field \(index) disagrees with frame source")
            }
            row += 1
        }
        try require(row == orderedSamples.count, "missing sample projection row")
    }

    let serialized = try database.serialized()
    try require(serialized.count <= 16 * 1_024 * 1_024, "serialized database size cap")
    try database.close()
    guard let root else { return (serialized.count, sha256(serialized)) }
    let descriptor = try root.createFile(databaseLeaf, mode: 0o600)
    defer { _ = close(descriptor) }
    try writeAll(descriptor, serialized)
    let serializedReadback = try preadExact(
        descriptor,
        count: serialized.count,
        offset: 0)
    try require(
        serializedReadback == serialized,
        "serialized database readback")
    try fullSync(descriptor)
    guard fchmod(descriptor, 0o400) == 0 else {
        throw ObserverError.posix("fchmod database", errno)
    }
    try fullSync(descriptor)
    try root.revalidateFile(
        descriptor: descriptor,
        leaf: databaseLeaf,
        mode: 0o400,
        bytes: serialized.count)
    let sealedDatabaseReadback = try preadExact(
        descriptor,
        count: serialized.count,
        offset: 0)
    try require(sealedDatabaseReadback == serialized, "sealed database final readback")
    try fullSync(root.rootDescriptor)
    try root.requireAbsent(databaseLeaf + "-wal")
    try root.requireAbsent(databaseLeaf + "-shm")
    try root.requireAbsent(databaseLeaf + "-journal")
    return (sealedDatabaseReadback.count, sha256(sealedDatabaseReadback))
}

#if !OBSERVABILITY_TESTING
@main
private struct PrimeDriverV2R19Observability {
    static func main() {
        do {
            try require(CommandLine.arguments.count == 1, "arguments are forbidden")
            _ = umask(0o077)
            try configureNoSIGPIPE(STDOUT_FILENO)
            try configureNoSIGPIPE(STDERR_FILENO)
            try verifyStaticABI()
            let heldSource = try HeldControlSource()
            let source = heldSource.data
            try require(sha256(source) == controlSHA256, "control source SHA-256")
            let sourceRecords = try indexSourceRecords(source)
            try require(!sourceRecords.isEmpty, "source record index empty")
            try heldSource.revalidate()
            let root = try TelemetryRoot()
            let result = try capture(
                root: root,
                source: source,
                sourceRecords: sourceRecords)
            try heldSource.revalidate()
            try writeAll(STDOUT_FILENO, result.encoded() + Data([0x0a]))
            _exit(0)
        } catch {
            let failure = JSONValue.object([
                "authority_vector": .string(authorityVector),
                "error": .string(String(describing: error)),
                "gate_e_mechanics_outcome": .string("ABSTAIN"),
                "gate_e_scientific_outcome": .string("ABSTAIN"),
                "schema": .string("prime_driver_v2_r19_observability_failure_v1"),
                "scientific_authorities_closed": .uint(0),
                "status": .string("ABSTAIN_PRESENTATION_CAPTURE_UNAVAILABLE"),
            ])
            try? writeAll(STDERR_FILENO, failure.encoded() + Data([0x0a]))
            _exit(70)
        }
    }
}
#endif

private func verifyStaticABI() throws {
    try require(MemoryLayout<UniqueIdentifierInfo>.size == 56, "flavor 17 size")
    try require(MemoryLayout<UniqueIdentifierInfo>.offset(of: \.uuidWord0) == 0, "UUID offset")
    try require(MemoryLayout<UniqueIdentifierInfo>.offset(of: \.uniqueID) == 16, "unique offset")
    try require(MemoryLayout<UniqueIdentifierInfo>.offset(of: \.parentUniqueID) == 24, "parent unique offset")
    try require(MemoryLayout<UniqueIdentifierInfo>.offset(of: \.idVersion) == 32, "idversion offset")
    try require(MemoryLayout<UniqueIdentifierInfo>.offset(of: \.originalParentIDVersion) == 36, "original parent offset")
    try require(MemoryLayout<UniqueIdentifierInfo>.offset(of: \.reserve2) == 40, "reserve2 offset")
    try require(MemoryLayout<UniqueIdentifierInfo>.offset(of: \.reserve3) == 48, "reserve3 offset")
    try require(MemoryLayout<proc_bsdshortinfo>.size == 64, "flavor 13 size")
    try require(MemoryLayout<rusage_info_v6>.size == 464, "rusage V6 size")
    try require(MemoryLayout<rusage_info_v6>.offset(of: \.ri_uuid) == 0, "rusage UUID offset")
    try require(
        MemoryLayout<rusage_info_v6>.offset(of: \.ri_proc_start_abstime) == 80,
        "rusage start offset")
    try require(
        MemoryLayout<rusage_info_v6>.offset(of: \.ri_proc_exit_abstime) == 88,
        "rusage exit offset")
    try require(
        MemoryLayout<rusage_info_v6>.offset(of: \.ri_energy_nj) == 336,
        "rusage energy offset")
    try require(
        MemoryLayout<rusage_info_v6>.offset(of: \.ri_penergy_nj) == 344,
        "rusage partial energy offset")
}

private func waitFixedInterval() throws {
    var timebase = mach_timebase_info_data_t()
    try require(mach_timebase_info(&timebase) == KERN_SUCCESS, "mach timebase")
    try require(timebase.numer > 0 && timebase.denom > 0, "mach timebase values")
    let product = intervalNanoseconds.multipliedReportingOverflow(by: UInt64(timebase.denom))
    try require(!product.overflow, "mach interval overflow")
    let rounding = product.partialValue.addingReportingOverflow(UInt64(timebase.numer) - 1)
    try require(!rounding.overflow, "mach interval rounding overflow")
    let ticks = rounding.partialValue / UInt64(timebase.numer)
    try require(ticks > 0, "mach interval ticks")
    let deadline = mach_absolute_time().addingReportingOverflow(ticks)
    try require(!deadline.overflow, "mach deadline overflow")
    try require(mach_wait_until(deadline.partialValue) == KERN_SUCCESS, "mach_wait_until")
}

private func appendFrame(
    _ frame: Frame,
    descriptor: Int32,
    journal: inout Data,
    frames: inout [Frame]
) throws {
    try require(frame.ordinal == frames.count, "frame ordinal discontinuity")
    try require(frame.byteOffset == journal.count, "frame byte offset discontinuity")
    try require(frame.previousFrameSHA256 == frames.last?.frameSHA256, "frame chain discontinuity")
    try require(
        journal.count + frame.rawWithLF.count <= maximumJournalBytes,
        "journal size cap")
    let offset = lseek(descriptor, 0, SEEK_CUR)
    try require(offset == off_t(journal.count), "held journal offset drift")
    try writeAll(descriptor, frame.rawWithLF)
    let readback = try preadExact(
        descriptor,
        count: frame.rawWithLF.count,
        offset: off_t(frame.byteOffset))
    try require(readback == frame.rawWithLF, "frame readback mismatch")
    try fullSync(descriptor)
    journal.append(frame.rawWithLF)
    frames.append(frame)
}

private func capture(
    root: TelemetryRoot,
    source: Data,
    sourceRecords: [IndexedSourceRecord]
) throws -> JSONValue {
    let captureStarted = DispatchTime.now().uptimeNanoseconds
    func requireSamplingHorizon() throws {
        let now = DispatchTime.now().uptimeNanoseconds
        let elapsed = try checkedSubtract(now, captureStarted)
        try require(elapsed <= 15_000_000_000, "target sampling horizon exceeded")
    }
    let sessionID = "r19-observability-eaf9b76-v1"
    let targetInventory = targetInventoryJSON()
    let targetHash = sha256(targetInventory.encoded())
    let journalDescriptor = try root.createFile(journalLeaf, mode: 0o600)
    defer { _ = close(journalDescriptor) }
    var journal = Data()
    var frames: [Frame] = []
    var samples: [(Int, Int, ProcessObservation, IntervalObservation)] = []

    let sessionPayload = JSONValue.object([
        "actuation_calls": .uint(0),
        "authority_vector": .string(authorityVector),
        "target_sampling_horizon_nanoseconds": .uint(15_000_000_000),
        "clock_delay_entries": .uint(1),
        "control_blob": .string(controlBlob),
        "control_commit": .string(controlCommit),
        "control_sha256": .string(controlSHA256),
        "control_tree": .string(controlTree),
        "exec_entries_inside_observer": .uint(0),
        "gate_e_clearance": .uint(0),
        "gate_e_mechanics_outcome": .string("ABSTAIN"),
        "gate_e_scientific_outcome": .string("ABSTAIN"),
        "interval_nanoseconds": .uint(intervalNanoseconds),
        "journal_leaf": .string(journalLeaf),
        "observer_children": .uint(0),
        "observation_root": .string(observationRootPath),
        "process_enumeration_calls": .uint(0),
        "process_wait_entries": .uint(0),
        "sample_rounds": .uint(UInt64(sampleRoundCount)),
        "schema": .string("prime_driver_v2_r19_observability_session_v1"),
        "scientific_authorities_closed": .uint(0),
        "signal_entries": .uint(0),
        "started_utc": .string(iso8601Now()),
        "status": .string("PRESENTATION_CAPTURE_NOT_IN_AUTHORITY_PREDICATE"),
        "target_inventory": targetInventory,
        "target_inventory_sha256": .string(targetHash),
        "target_wait_entries": .uint(0),
    ])
    var frame = makeFrame(
        ordinal: 0,
        kind: "session",
        sessionID: sessionID,
        payload: sessionPayload,
        previous: nil,
        byteOffset: 0)
    try appendFrame(
        frame,
        descriptor: journalDescriptor,
        journal: &journal,
        frames: &frames)

    var prior: [String: ProcessObservation] = [:]
    for round in 0..<sampleRoundCount {
        if round == 1 { try waitFixedInterval() }
        try requireSamplingHorizon()
        for target in targets {
            try requireSamplingHorizon()
            let observation = observe(target)
            try requireSamplingHorizon()
            let intervalValue = interval(previous: prior[target.label], current: observation)
            let ordinal = frames.count
            frame = makeFrame(
                ordinal: ordinal,
                kind: "sample",
                sessionID: sessionID,
                payload: observationPayload(observation, round: round, interval: intervalValue),
                previous: frames.last?.frameSHA256,
                byteOffset: journal.count)
            try appendFrame(
                frame,
                descriptor: journalDescriptor,
                journal: &journal,
                frames: &frames)
            samples.append((ordinal, round, observation, intervalValue))
            prior[target.label] = observation
        }
    }
    try requireSamplingHorizon()

    try require(frames.count == 7 && samples.count == 6, "preseal cardinality")
    let completedUTC = iso8601Now()
    let presealBytes = journal.count
    let presealHash = sha256(journal)
    let sealPayload = JSONValue.object([
        "authority_vector": .string(authorityVector),
        "build_entries": .uint(0),
        "completed_utc": .string(completedUTC),
        "control_sha256": .string(controlSHA256),
        "expected_final_frame_count": .uint(8),
        "expected_sample_count": .uint(6),
        "gate_e_clearance": .uint(0),
        "gate_e_mechanics_outcome": .string("ABSTAIN"),
        "gate_e_promotions": .uint(0),
        "gate_e_scientific_outcome": .string("ABSTAIN"),
        "git_entries": .uint(0),
        "observer_children": .uint(0),
        "preseal_frame_count": .uint(UInt64(frames.count)),
        "preseal_journal_bytes": .uint(UInt64(presealBytes)),
        "preseal_journal_sha256": .string(presealHash),
        "preseal_tail_frame_sha256": .string(frames.last!.frameSHA256),
        "process_actuation_calls": .uint(0),
        "recovery_entries": .uint(0),
        "sample_count": .uint(UInt64(samples.count)),
        "schema": .string("prime_driver_v2_r19_observability_seal_v1"),
        "scientific_authorities_closed": .uint(0),
        "session_id": .string(sessionID),
        "signal_entries": .uint(0),
        "source_bytes": .uint(UInt64(source.count)),
        "source_sha256": .string(controlSHA256),
        "status": .string(
            "PASS_TELEMETRY_JOURNAL_SEALED_PROJECTION_PENDING_NOT_AUTHORITY"),
        "target_inventory_sha256": .string(targetHash),
    ])
    frame = makeFrame(
        ordinal: frames.count,
        kind: "seal",
        sessionID: sessionID,
        payload: sealPayload,
        previous: frames.last?.frameSHA256,
        byteOffset: journal.count)
    try appendFrame(
        frame,
        descriptor: journalDescriptor,
        journal: &journal,
        frames: &frames)
    try require(frames.count == 8 && journal.last == 0x0a, "sealed journal shape")
    let journalReadback = try preadExact(
        journalDescriptor,
        count: journal.count,
        offset: 0)
    try require(journalReadback == journal, "sealed journal full readback")
    guard fchmod(journalDescriptor, 0o400) == 0 else {
        throw ObserverError.posix("fchmod journal", errno)
    }
    try fullSync(journalDescriptor)
    try root.revalidateFile(
        descriptor: journalDescriptor,
        leaf: journalLeaf,
        mode: 0o400,
        bytes: journal.count)
    try root.revalidate()
    try fullSync(root.rootDescriptor)
    let journalHash = sha256(journal)

    let projection = try buildDatabase(
        root: root,
        source: source,
        sourceRecords: sourceRecords,
        sessionID: sessionID,
        frames: frames,
        samples: samples,
        journalSHA256: journalHash,
        completedUTC: completedUTC)
    try root.revalidate()
    try root.revalidateFile(
        descriptor: journalDescriptor,
        leaf: journalLeaf,
        mode: 0o400,
        bytes: journal.count)
    let journalBeforeRootSeal = try root.readSealedFile(
        journalLeaf,
        mode: 0o400,
        bytes: journal.count)
    try require(
        journalBeforeRootSeal == journal && sha256(journalBeforeRootSeal) == journalHash,
        "journal changed after projection")
    let databaseBeforeRootSeal = try root.readSealedFile(
        databaseLeaf,
        mode: 0o400,
        bytes: projection.bytes)
    try require(
        sha256(databaseBeforeRootSeal) == projection.sha256,
        "database changed after publication")
    try fullSync(root.rootDescriptor)
    try fullSync(root.parentDescriptor)
    try root.seal()
    let journalAfterRootSeal = try root.readSealedFile(
        journalLeaf,
        mode: 0o400,
        bytes: journal.count)
    let databaseAfterRootSeal = try root.readSealedFile(
        databaseLeaf,
        mode: 0o400,
        bytes: projection.bytes)
    try require(
        journalAfterRootSeal == journal && sha256(journalAfterRootSeal) == journalHash,
        "journal changed across root seal")
    try require(
        sha256(databaseAfterRootSeal) == projection.sha256,
        "database changed across root seal")
    let sealedInventory = try root.exactInventory()
    try require(
        sealedInventory == [databaseLeaf, journalLeaf].sorted(),
        "sealed observation root inventory")
    let finalJournalAdmission = try root.readSealedFile(
        journalLeaf,
        mode: 0o400,
        bytes: journal.count)
    let finalDatabaseAdmission = try root.readSealedFile(
        databaseLeaf,
        mode: 0o400,
        bytes: projection.bytes)
    try require(
        finalJournalAdmission == journal && sha256(finalJournalAdmission) == journalHash,
        "final journal admission")
    try require(
        sha256(finalDatabaseAdmission) == projection.sha256,
        "final database admission")
    try root.revalidate()

    let resultRows: [JSONValue] = samples.filter { $0.1 == 1 }.map {
        let observation = $0.2
        let value = $0.3
        return .object([
            "availability": .string(observation.availability),
            "average_power_at_estimated_interval_w_approx": optionalString(value.powerEstimate),
            "average_power_at_maximum_interval_w_approx": optionalString(value.powerLower),
            "average_power_at_minimum_interval_w_approx": optionalString(value.powerUpper),
            "cpu_percent_at_estimated_interval_approx": optionalString(value.cpuPercentEstimate),
            "delta_energy_nj": optionalUInt(value.deltaEnergy),
            "delta_ergs": optionalString(value.ergs),
            "delta_joules": optionalString(value.joules),
            "energy_interpretation": .string(value.energyInterpretation),
            "energy_interpretation_valid": .bool(value.energyInterpretationValid),
            "interval_valid": .bool(value.valid),
            "label": .string(observation.target.label),
            "pid": .uint(UInt64(observation.target.pid)),
        ])
    }
    return .object([
        "authority_vector": .string(authorityVector),
        "database_bytes": .uint(UInt64(projection.bytes)),
        "database_path": .string(observationRootPath + "/" + databaseLeaf),
        "database_sha256": .string(projection.sha256),
        "frame_count": .uint(UInt64(frames.count)),
        "gate_e_clearance": .uint(0),
        "gate_e_mechanics_outcome": .string("ABSTAIN"),
        "gate_e_scientific_outcome": .string("ABSTAIN"),
        "journal_bytes": .uint(UInt64(journal.count)),
        "journal_path": .string(observationRootPath + "/" + journalLeaf),
        "journal_sha256": .string(journalHash),
        "observer_children": .uint(0),
        "process_actuation_calls": .uint(0),
        "sample_count": .uint(UInt64(samples.count)),
        "schema": .string("prime_driver_v2_r19_observability_result_v1"),
        "scientific_authorities_closed": .uint(0),
        "signal_entries": .uint(0),
        "status": .string(
            "PASS_SEALED_PRESENTATION_SNAPSHOT_COMPLETE_NOT_IN_AUTHORITY_PREDICATE"),
        "targets": .array(resultRows),
    ])
}

#if OBSERVABILITY_TESTING
func runObservabilityPureTests() throws {
    try verifyStaticABI()
    try require(
        JSONValue.object(["z": .uint(1), "a": .string("x\n")]).encoded() ==
            Data(#"{"a":"x\n","z":1}"#.utf8),
        "canonical JSON ordering or escaping")
    let testFrame = makeFrame(
        ordinal: 0,
        kind: "session",
        sessionID: "test",
        payload: .object(["value": .uint(7)]),
        previous: nil,
        byteOffset: 0)
    try require(testFrame.rawWithLF.last == 0x0a, "frame LF")
    try require(testFrame.frameSHA256 == sha256(testFrame.rawWithLF), "frame LF hash")
    try require(decimalScaled(10_000_000_000, places: 9) == "10.000000000", "joules")
    try require(decimalScaled(10_000_000_000, places: 2) == "100000000.00", "ergs")
    try require(databaseSchema.contains("PRAGMA journal_mode=MEMORY"), "SQLite memory construction")
    try require(!databaseSchema.uppercased().contains("ATTACH"), "SQLite ATTACH forbidden")
    let schemaDatabase = try SQLiteDatabase(path: ":memory:")
    try schemaDatabase.execute(databaseSchema)
    let schemaQuickCheck = try schemaDatabase.scalarText("PRAGMA quick_check")
    try require(schemaQuickCheck == "ok", "test quick_check")
    let schemaJournalMode = try schemaDatabase.scalarText("PRAGMA journal_mode")
    try require(schemaJournalMode == "memory", "test in-memory journal mode")
    func assertArity(_ table: String, _ count: Int) throws {
        let sql = "INSERT INTO \(table) VALUES(" +
            String(repeating: "?,", count: count - 1) + "?)"
        let statement = try schemaDatabase.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try require(
            sqlite3_bind_parameter_count(statement) == Int32(count),
            "\(table) insert arity")
    }
    try assertArity("source_snapshot", 9)
    try assertArity("source_records", 9)
    try assertArity("source_lexical_references", 4)
    try assertArity("capture_session", 9)
    try assertArity("frames", 9)
    try assertArity("process_samples", 29)
    try assertArity("capture_seal", 8)
    let schemaImage = try schemaDatabase.serialized()
    try require(!schemaImage.isEmpty, "serialized schema")
    try require(
        schemaImage.count >= 20 &&
            Data(schemaImage.prefix(16)) == Data("SQLite format 3\u{0}".utf8) &&
            schemaImage[18] == 1 && schemaImage[19] == 1,
        "serialized SQLite rollback-journal-format header")
    try schemaDatabase.close()

    let hash = String(repeating: "a", count: 64)
    let candidate = Data(
        ("```json\n" +
         "{\"hash\":\"\(hash)\",\"schema\":\"test/v1\",\"status\":\"FROZEN\"}\n" +
         "```\n").utf8)
    let indexed = try indexSourceRecords(candidate)
    try require(indexed.count == 1, "fenced source candidate count")
    try require(
        indexed[0].validation ==
            "CANONICAL_JSON_FENCE_LINE_PRESENTATION_CANDIDATE_NOT_AUTHORITY",
        "fenced source candidate validation")
    try require(indexed[0].lexicalReferences.count == 1, "fenced lexical reference count")
    try require(indexed[0].lexicalReferences[0].exactValue == hash, "fenced lexical value")

    let unique = UniqueIdentifierInfo(
        uuidWord0: 1,
        uuidWord1: 2,
        uniqueID: 3,
        parentUniqueID: 4,
        idVersion: 5,
        originalParentIDVersion: 6,
        reserve2: 0,
        reserve3: 0)
    let short = ShortBSD(
        pid: 99,
        parentPID: 1,
        processGroupID: 99,
        status: 2,
        commandHex: "74657374",
        flags: 0,
        uid: 501,
        gid: 20,
        realUID: 501,
        realGID: 20,
        savedUID: 501,
        savedGID: 20,
        reserved: 0)
    let join = ProcessJoin(unique: unique, short: short, sessionID: 99, processGroupID: 99)
    func usage(user: UInt64, system: UInt64, energy: UInt64) -> Usage {
        Usage(
            uuidHex: unique.uuidHex,
            userTime: user,
            systemTime: system,
            physicalFootprint: 1,
            processStartAbstime: 9,
            processExitAbstime: 0,
            instructions: user,
            cycles: user,
            runnableTime: user,
            userPTime: user,
            systemPTime: system,
            pInstructions: user,
            pCycles: user,
            energyNJ: energy,
            pEnergyNJ: energy / 2)
    }
    let target = Target(
        label: "synthetic",
        pid: 99,
        uniqueID: 3,
        idVersion: 5,
        sessionID: 99,
        processGroupID: 99)
    let before = ProcessObservation(
        target: target,
        observedUTC: "before",
        monotonicBefore: 100,
        monotonicAfter: 200,
        availability: "AVAILABLE",
        error: nil,
        join: join,
        usage: usage(user: 1_000_000_000, system: 100_000_000, energy: 1_000_000_000))
    let after = ProcessObservation(
        target: target,
        observedUTC: "after",
        monotonicBefore: 5_000_000_200,
        monotonicAfter: 5_000_000_300,
        availability: "AVAILABLE",
        error: nil,
        join: join,
        usage: usage(user: 4_000_000_000, system: 600_000_000, energy: 11_000_000_000))
    let measured = interval(previous: before, current: after)
    try require(measured.valid, "synthetic interval")
    try require(measured.elapsedMinimum == 5_000_000_000, "minimum interval")
    try require(measured.elapsedMaximum == 5_000_000_200, "maximum interval")
    try require(measured.deltaCPU == 3_500_000_000, "CPU delta")
    try require(measured.deltaEnergy == 10_000_000_000, "energy delta")
    try require(measured.joules == "10.000000000", "synthetic joules")
    try require(measured.ergs == "100000000.00", "synthetic ergs")

    let testSessionID = "r19-observability-eaf9b76-v1"
    var syntheticFrames: [Frame] = []
    var syntheticJournal = Data()
    var syntheticSamples: [(Int, Int, ProcessObservation, IntervalObservation)] = []
    func addSyntheticFrame(kind: String, payload: JSONValue) {
        let frame = makeFrame(
            ordinal: syntheticFrames.count,
            kind: kind,
            sessionID: testSessionID,
            payload: payload,
            previous: syntheticFrames.last?.frameSHA256,
            byteOffset: syntheticJournal.count)
        syntheticJournal.append(frame.rawWithLF)
        syntheticFrames.append(frame)
    }
    addSyntheticFrame(kind: "session", payload: .object(["test": .bool(true)]))
    for index in 0..<6 {
        let round = index / 3
        let template = round == 0 ? before : after
        let observation = ProcessObservation(
            target: targets[index % 3],
            observedUTC: template.observedUTC,
            monotonicBefore: template.monotonicBefore,
            monotonicAfter: template.monotonicAfter,
            availability: template.availability,
            error: nil,
            join: template.join,
            usage: template.usage)
        let value = round == 0 ? IntervalObservation.unavailable("NO_PREDECESSOR") : measured
        let ordinal = syntheticFrames.count
        addSyntheticFrame(
            kind: "sample",
            payload: observationPayload(observation, round: round, interval: value))
        syntheticSamples.append((ordinal, round, observation, value))
    }
    addSyntheticFrame(kind: "seal", payload: .object(["test_seal": .bool(true)]))
    let syntheticProjection = try buildDatabase(
        root: nil,
        source: candidate,
        sourceRecords: indexed,
        sessionID: testSessionID,
        frames: syntheticFrames,
        samples: syntheticSamples,
        journalSHA256: sha256(syntheticJournal),
        completedUTC: "test")
    try require(syntheticProjection.bytes > 0, "synthetic projection bytes")
    try require(syntheticProjection.sha256.count == 64, "synthetic projection hash")
}
#endif
