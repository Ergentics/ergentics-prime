import Swift
import Darwin
import SQLite3

private struct R19PureTestFailure: Error, CustomStringConvertible {
    let description: String
}

@inline(__always)
private func testRequire(_ condition: @autoclosure () throws -> Bool, _ message: String) throws {
    if try !condition() { throw R19PureTestFailure(description: message) }
}

private func expectContract(_ operation: String? = nil, _ body: () throws -> Void) throws {
    do {
        try body()
        throw R19PureTestFailure(description: "expected contract rejection")
    } catch R19OverlayError.contract(let actual) {
        if let operation { try testRequire(actual == operation, "wrong rejection: " + actual) }
    }
}

private func expectPosix(
    _ operation: String, _ code: Int32, _ body: () throws -> Void
) throws {
    do {
        try body()
        throw R19PureTestFailure(description: "expected POSIX rejection")
    } catch R19OverlayError.posix(let actualOperation, let actualCode) {
        try testRequire(actualOperation == operation && actualCode == code,
                        "wrong POSIX rejection")
    }
}

private func writeTestLine(_ descriptor: Int32, _ line: String) {
    _ = line.withCString { pointer in
        Darwin.write(descriptor, pointer, strlen(pointer))
    }
}

private func inputFrame(
    ordinal: Int,
    kind: String,
    payload: R19JSONValue,
    previous: String?,
    byteOffset: Int
) -> R19ParsedFrame {
    let payloadHash = r19SHA256(payload.encoded())
    let value = R19JSONValue.object([
        "frame_kind": .string(kind),
        "ordinal": .number(String(ordinal)),
        "payload": payload,
        "payload_hash_rule": .string(r19PayloadHashRule),
        "payload_sha256": .string(payloadHash),
        "previous_frame_sha256": previous.map(R19JSONValue.string) ?? .null,
        "schema": .string(r19InputFrameSchema),
        "session_id": .string(r19InputSessionID),
    ])
    let raw = value.encoded() + [0x0a]
    return .init(
        ordinal: ordinal,
        kind: kind,
        sessionID: r19InputSessionID,
        payload: payload,
        payloadSHA256: payloadHash,
        previousFrameSHA256: previous,
        frameSHA256: r19SHA256(raw),
        rawWithLF: raw,
        byteOffset: byteOffset)
}

private func intervalPayload(
    round: Int,
    deltaCPU: UInt64?,
    deltaEnergy: UInt64?,
    elapsedMinimum: UInt64?,
    elapsedEstimate: UInt64?,
    elapsedMaximum: UInt64?
) -> R19JSONValue {
    let present = round == 1
    let cpuText = deltaCPU.map(String.init)
    let joules = deltaEnergy.map { r19ScaledDecimal($0, places: 9) }
    let ergs = deltaEnergy.map { r19ScaledDecimal($0, places: 2) }
    func number(_ value: UInt64?) -> R19JSONValue {
        value.map { .number(String($0)) } ?? .null
    }
    func string(_ value: String?) -> R19JSONValue {
        value.map(R19JSONValue.string) ?? .null
    }
    return .object([
        "average_power_at_estimated_interval_w_approx": string(present ? "0" : nil),
        "average_power_at_maximum_interval_w_approx": string(present ? "0" : nil),
        "average_power_at_minimum_interval_w_approx": string(present ? "0" : nil),
        "cpu_percent_at_estimated_interval_approx": string(cpuText),
        "cpu_percent_at_maximum_interval_approx": string(cpuText),
        "cpu_percent_at_minimum_interval_approx": string(cpuText),
        "delta_cpu_ns": number(deltaCPU),
        "delta_energy_nj": number(deltaEnergy),
        "delta_ergs": string(ergs),
        "delta_joules": string(joules),
        "elapsed_estimate_ns": number(elapsedEstimate),
        "elapsed_maximum_ns": number(elapsedMaximum),
        "elapsed_minimum_ns": number(elapsedMinimum),
        "energy_interpretation": .string(
            present ? "SYNTHETIC_COUNTER_INTERVAL" : "NO_PREDECESSOR"),
        "energy_interpretation_valid": .bool(present),
        "reason": .string(present ? "MONOTONIC_GENERATION_JOINED_COUNTER_INTERVAL_VALID" :
            "NO_PREDECESSOR"),
        "valid": .bool(present),
    ])
}

private struct SyntheticTarget {
    let label: String
    let pid: UInt64
    let uniqueID: UInt64
    let idVersion: UInt64
    let sid: UInt64
    let pgid: UInt64
    let uuid: String
    let start: UInt64
    let beforeUser: UInt64
    let beforeSystem: UInt64
    let beforeEnergy: UInt64
    let afterUser: UInt64
    let afterSystem: UInt64
    let afterEnergy: UInt64
    let elapsedMinimum: UInt64
    let elapsedEstimate: UInt64
    let elapsedMaximum: UInt64
}

private let syntheticTargets = [
    SyntheticTarget(
        label: "wrapper", pid: 101, uniqueID: 1_001, idVersion: 11, sid: 101, pgid: 101,
        uuid: "00000000000000000000000000000001", start: 10_001,
        beforeUser: 10, beforeSystem: 20, beforeEnergy: 0,
        afterUser: 10, afterSystem: 20, afterEnergy: 0,
        elapsedMinimum: 5_000_000_000, elapsedEstimate: 5_000_000_100,
        elapsedMaximum: 5_000_000_200),
    SyntheticTarget(
        label: "guardian", pid: 102, uniqueID: 1_002, idVersion: 12, sid: 102, pgid: 102,
        uuid: "00000000000000000000000000000002", start: 10_002,
        beforeUser: 1_000_000_000, beforeSystem: 2_000_000_000, beforeEnergy: 100,
        afterUser: 1_080_000_000, afterSystem: 2_006_666_027,
        afterEnergy: 20_815_536_540,
        elapsedMinimum: 5_018_364_083, elapsedEstimate: 5_018_377_709,
        elapsedMaximum: 5_018_391_334),
    SyntheticTarget(
        label: "fixture", pid: 103, uniqueID: 1_003, idVersion: 13, sid: 103, pgid: 103,
        uuid: "00000000000000000000000000000003", start: 10_003,
        beforeUser: 30, beforeSystem: 40, beforeEnergy: 0,
        afterUser: 30, afterSystem: 40, afterEnergy: 0,
        elapsedMinimum: 5_000_000_000, elapsedEstimate: 5_000_000_100,
        elapsedMaximum: 5_000_000_200),
]

private func samplePayload(_ target: SyntheticTarget, round: Int) -> R19JSONValue {
    let roundOne = round == 1
    let user = roundOne ? target.afterUser : target.beforeUser
    let system = roundOne ? target.afterSystem : target.beforeSystem
    let energy = roundOne ? target.afterEnergy : target.beforeEnergy
    let deltaCPU = roundOne ?
        (target.afterUser - target.beforeUser) + (target.afterSystem - target.beforeSystem) : nil
    let deltaEnergy = roundOne ? target.afterEnergy - target.beforeEnergy : nil
    return .object([
        "availability": .string("AVAILABLE_EXACT_GENERATION_SANDWICHED"),
        "interval": intervalPayload(
            round: round,
            deltaCPU: deltaCPU,
            deltaEnergy: deltaEnergy,
            elapsedMinimum: roundOne ? target.elapsedMinimum : nil,
            elapsedEstimate: roundOne ? target.elapsedEstimate : nil,
            elapsedMaximum: roundOne ? target.elapsedMaximum : nil),
        "label": .string(target.label),
        "pid": .number(String(target.pid)),
        "process": .object([
            "idversion": .number(String(target.idVersion)),
            "pgid": .number(String(target.pgid)),
            "sid": .number(String(target.sid)),
            "status": .number("2"),
            "unique_id": .number(String(target.uniqueID)),
        ]),
        "round": .number(String(round)),
        "rusage_v6": .object([
            "energy_nj": .number(String(energy)),
            "process_start_abstime": .number(String(target.start)),
            "system_time": .number(String(system)),
            "user_time": .number(String(user)),
            "uuid_hex": .string(target.uuid),
        ]),
    ])
}

private func syntheticJournal() throws -> (bytes: [UInt8], frames: [R19ParsedFrame]) {
    var frames: [R19ParsedFrame] = []
    var offset = 0
    func append(_ kind: String, _ payload: R19JSONValue) {
        let frame = inputFrame(
            ordinal: frames.count,
            kind: kind,
            payload: payload,
            previous: frames.last?.frameSHA256,
            byteOffset: offset)
        frames.append(frame)
        offset += frame.rawWithLF.count
    }
    append("session", .object(["synthetic": .bool(true)]))
    for target in syntheticTargets { append("sample", samplePayload(target, round: 0)) }
    for target in syntheticTargets { append("sample", samplePayload(target, round: 1)) }
    let prefix = frames.flatMap(\.rawWithLF)
    append("seal", .object([
        "preseal_frame_count": .number("7"),
        "preseal_journal_bytes": .number(String(prefix.count)),
        "preseal_journal_sha256": .string(r19SHA256(prefix)),
        "preseal_tail_frame_sha256": .string(frames[6].frameSHA256),
    ]))
    let bytes = frames.flatMap(\.rawWithLF)
    let parsed = try r19ParseJournal(
        bytes,
        expectedBytes: bytes.count,
        expectedSHA256: r19SHA256(bytes),
        expectedSessionID: r19InputSessionID,
        expectedSealFrameSHA256: nil)
    return (bytes, parsed)
}

private func projections(_ frames: [R19ParsedFrame]) throws -> [R19IntervalProjection] {
    [
        try r19ProjectInterval(predecessor: frames[1], current: frames[4],
                               expectedLabel: "wrapper"),
        try r19ProjectInterval(predecessor: frames[2], current: frames[5],
                               expectedLabel: "guardian"),
        try r19ProjectInterval(predecessor: frames[3], current: frames[6],
                               expectedLabel: "fixture"),
    ]
}

private func replaceFirst(_ source: [UInt8], _ needle: [UInt8], _ replacement: [UInt8]) throws
    -> [UInt8]
{
    try testRequire(!needle.isEmpty && needle.count == replacement.count, "replacement shape")
    if source.count >= needle.count {
        for start in 0...(source.count - needle.count) {
            if Array(source[start..<(start + needle.count)]) == needle {
                var result = source
                result.replaceSubrange(start..<(start + needle.count), with: replacement)
                return result
            }
        }
    }
    throw R19PureTestFailure(description: "replacement needle absent")
}

private func replacingObservationField(
    _ frame: R19ParsedFrame,
    container: String,
    key: String,
    value: R19JSONValue
) throws -> R19ParsedFrame {
    var payload = try frame.payload.object("test payload")
    if container == "payload" {
        payload[key] = value
    } else {
        var nested = try r19Member(payload, container, "test nested").object("test nested")
        nested[key] = value
        payload[container] = .object(nested)
    }
    return .init(
        ordinal: frame.ordinal, kind: frame.kind, sessionID: frame.sessionID,
        payload: .object(payload), payloadSHA256: frame.payloadSHA256,
        previousFrameSHA256: frame.previousFrameSHA256, frameSHA256: frame.frameSHA256,
        rawWithLF: frame.rawWithLF, byteOffset: frame.byteOffset)
}

private func testGuardianVector() throws {
    let fixture = try syntheticJournal()
    let guardian = try r19ProjectInterval(
        predecessor: fixture.frames[2], current: fixture.frames[5], expectedLabel: "guardian")
    try testRequire(guardian.deltaCPUTicks == 86_666_027, "guardian delta ticks")
    try testRequire(
        guardian.cpuTime == .init(
            numerator: 10_833_253_375, denominator: 3,
            floor: 3_611_084_458, remainder: 1, ceil: 3_611_084_459),
        "guardian exact CPU time")
    try testRequire(
        guardian.cpuEstimated == R19Rational(
            1_083_325_337_500, 15_055_133_127,
            unit: "aggregate_core_equivalent_percent"),
        "guardian estimated rational")
    try testRequire(try guardian.cpuEstimated.approximation() == "71.957207442899",
                    "guardian estimated percent")
    try testRequire(try guardian.cpuLower.approximation() == "71.957012078113",
                    "guardian lower percent")
    try testRequire(try guardian.cpuUpper.approximation() == "71.957402823085",
                    "guardian upper percent")
}

private func testZeroVectors() throws {
    let fixture = try syntheticJournal()
    let syntheticPins: [R19IntervalPairPin] = [
        (1, fixture.frames[1].frameSHA256, fixture.frames[1].payloadSHA256,
         4, fixture.frames[4].frameSHA256, fixture.frames[4].payloadSHA256, "wrapper"),
        (2, fixture.frames[2].frameSHA256, fixture.frames[2].payloadSHA256,
         5, fixture.frames[5].frameSHA256, fixture.frames[5].payloadSHA256, "guardian"),
        (3, fixture.frames[3].frameSHA256, fixture.frames[3].payloadSHA256,
         6, fixture.frames[6].frameSHA256, fixture.frames[6].payloadSHA256, "fixture"),
    ]
    let values = try r19BuildIntervalProjections(fixture.frames, pairPins: syntheticPins)
    for index in [0, 2] {
        let value = values[index]
        try testRequire(value.deltaCPUTicks == 0 && value.cpuTime.numerator == 0,
                        "zero CPU vector")
        try testRequire(value.cpuLower.numerator == 0 && value.cpuEstimated.numerator == 0 &&
                        value.cpuUpper.numerator == 0, "zero percent vectors")
        try testRequire(value.energy.deltaNJ == 0 &&
                        value.energy.meterStatus ==
                            "ABSTAIN_ZERO_DELTA_NO_POSITIVE_METER_SUPPORT_EVIDENCE",
                        "zero energy ABSTAIN")
    }
}

private func testEnergyVector() throws {
    let fixture = try syntheticJournal()
    let guardian = try projections(fixture.frames)[1]
    try testRequire(guardian.energy.deltaNJ == 20_815_536_440, "energy nJ")
    try testRequire(guardian.energy.joulesExact == "20.815536440", "energy joules")
    try testRequire(guardian.energy.ergsExact == "208155364.40", "energy ergs")
    let facts = try r19MetricFacts(guardian)
    guard let joules = facts.first(where: { $0.metricName == "delta_energy_joules" }),
          let ergs = facts.first(where: { $0.metricName == "delta_energy_ergs" })
    else { throw R19PureTestFailure(description: "energy metric facts") }
    try testRequire(
        joules.rational == R19Rational(520_388_411, 25_000_000, unit: "joules") &&
        ergs.rational == R19Rational(1_040_776_822, 5, unit: "ergs"),
        "exact energy rationals")
    try testRequire(
        guardian.energy.estimatedPower == R19Rational(
            20_815_536_440, 5_018_377_709, unit: "watts"),
        "estimated power rational")
    try testRequire(try guardian.energy.estimatedPower.approximation() == "4.147861649128",
                    "estimated power")
    try testRequire(try guardian.energy.lowerPower.approximation() == "4.147850387628",
                    "lower power")
    try testRequire(try guardian.energy.upperPower.approximation() == "4.147872911516",
                    "upper power")
    try testRequire(
        guardian.energy.meterStatus ==
            "POSITIVE_KERNEL_TASK_ATTRIBUTED_DELTA_OBSERVED_SCOPE_REMAINS_QUALIFIED",
        "energy scope")
}

private func testCounterAndDenominatorRejections() throws {
    try expectContract("counter regression") { _ = try r19CheckedDelta(1, 2) }
    try expectContract("counter sum overflow") { _ = try r19CheckedSum(UInt64.max, 1) }
    try expectContract("rational zero denominator") {
        _ = try R19Rational(1, 0, unit: "test")
    }
    try expectContract("CPU elapsed zero") { _ = try r19CPUPercent(1, elapsedNanoseconds: 0) }
    try expectContract("power elapsed zero") { _ = try r19Power(1, elapsedNanoseconds: 0) }
    try expectContract("zero energy with positive CPU") {
        _ = try r19EnergyProjection(
            deltaEnergyNJ: 0, deltaCPUTicks: 1,
            elapsedMinimumNS: 1, elapsedEstimateNS: 1, elapsedMaximumNS: 1,
            label: "wrapper")
    }
    var enteredEINTRResults = 0
    for _ in 0..<63 { try r19RegisterEINTR(&enteredEINTRResults) }
    try testRequire(enteredEINTRResults == 63, "first 63 EINTR results retry")
    try expectPosix("byte I/O EINTR budget", EINTR) {
        try r19RegisterEINTR(&enteredEINTRResults)
    }
    var resultBudget = R19InventoryBudget()
    for _ in 0..<5 { try resultBudget.registerPositiveResult() }
    try expectContract("inventory readdir result budget") {
        try resultBudget.registerPositiveResult()
    }
    var nameBudget = R19InventoryBudget()
    try nameBudget.registerNonDotEntry()
    try nameBudget.registerNonDotEntry()
    try expectContract("inventory non-dot entry cap") {
        try nameBudget.registerNonDotEntry()
    }
}

private func testUInt128AndDivision() throws {
    try testRequire(try r19CheckedMultiply(UInt128.max, 1) == UInt128.max,
                    "UInt128 maximum product")
    try expectContract("UInt128 product overflow") {
        _ = try r19CheckedMultiply(UInt128.max, 2)
    }
    try testRequire(try R19Rational(42, 56, unit: "test") ==
                    R19Rational(3, 4, unit: "test"), "GCD reduction")
    let zero = try R19Rational(0, UInt128.max, unit: "test")
    try testRequire(zero.numerator == 0 && zero.denominator == 1, "zero normalization")
    let time = try r19CPUTime(86_666_027)
    try testRequire(time.floor == 3_611_084_458 && time.remainder == 1 &&
                    time.ceil == 3_611_084_459, "integer floor remainder ceil")
}

private func testHalfEvenFormatting() throws {
    try testRequire(try R19Rational(1, 8, unit: "test").approximation(places: 2) == "0.12",
                    "half-even down")
    try testRequire(try R19Rational(3, 8, unit: "test").approximation(places: 2) == "0.38",
                    "half-even up")
    try testRequire(
        try R19Rational(1_999, 2_000, unit: "test").approximation(places: 3) == "1.000",
        "half-even carry")
    try testRequire(
        try R19Rational(1, 8, unit: "test").approximation() == "0.125000000000",
        "leading zero fixed format")
}

private func parseCanonical(_ bytes: [UInt8], maximumDepth: Int = 64) throws -> R19JSONValue {
    var parser = R19CanonicalJSONParser(bytes, maximumDepth: maximumDepth)
    return try parser.parseCanonical()
}

private func testCanonicalJSONRejections() throws {
    let canonical = Array(#"{"a":"x\n","z":1}"#.utf8)
    try testRequire(try parseCanonical(canonical).encoded() == canonical,
                    "canonical JSON encode")
    try expectContract("JSON duplicate key") {
        _ = try parseCanonical(Array(#"{"a":1,"a":2}"#.utf8))
    }
    try expectContract("JSON invalid UTF8") {
        _ = try parseCanonical([0x22, 0xc0, 0xaf, 0x22])
    }
    try expectContract("JSON escape") {
        _ = try parseCanonical([0x22, 0x5c, 0x78, 0x22])
    }
    try expectContract("JSON surrogate pair") {
        _ = try parseCanonical(Array(#""\ud800""#.utf8))
    }
    try expectContract("JSON negative zero") { _ = try parseCanonical(Array("-0".utf8)) }
    try expectContract("JSON leading zero") { _ = try parseCanonical(Array("01".utf8)) }
    try expectContract("JSON noninteger number") { _ = try parseCanonical(Array("1.0".utf8)) }
    try expectContract("JSON trailing byte") { _ = try parseCanonical(Array("[]x".utf8)) }
    let depth64 = Array(repeating: UInt8(0x5b), count: 64) + [0x30] +
        Array(repeating: UInt8(0x5d), count: 64)
    _ = try parseCanonical(depth64)
    let depth65 = Array(repeating: UInt8(0x5b), count: 65) + [0x30] +
        Array(repeating: UInt8(0x5d), count: 65)
    try expectContract("JSON depth cap") { _ = try parseCanonical(depth65) }
}

private func parseSyntheticVariant(_ bytes: [UInt8]) throws -> [R19ParsedFrame] {
    try r19ParseJournal(
        bytes,
        expectedBytes: bytes.count,
        expectedSHA256: r19SHA256(bytes),
        expectedSessionID: r19InputSessionID,
        expectedSealFrameSHA256: nil)
}

private func testEightFrameJournal() throws {
    let fixture = try syntheticJournal()
    try testRequire(fixture.frames.count == 8 && fixture.bytes.last == 0x0a,
                    "eight LF frames")
    var offset = 0
    for frame in fixture.frames {
        try testRequire(frame.byteOffset == offset && frame.rawWithLF.last == 0x0a,
                        "frame offsets and LF")
        try testRequire(frame.frameSHA256 == r19SHA256(frame.rawWithLF), "frame hash with LF")
        try testRequire(frame.payloadSHA256 == r19SHA256(frame.payload.encoded()),
                        "payload hash without LF")
        try testRequire(frame.previousFrameSHA256 ==
                        (frame.ordinal == 0 ? nil : fixture.frames[frame.ordinal - 1].frameSHA256),
                        "frame predecessor chain")
        offset += frame.rawWithLF.count
    }
    let payloadHash = Array(fixture.frames[0].payloadSHA256.utf8)
    var changedHash = payloadHash
    changedHash[0] = changedHash[0] == 0x30 ? 0x31 : 0x30
    let payloadTamper = try replaceFirst(fixture.bytes, payloadHash, changedHash)
    try expectContract { _ = try parseSyntheticVariant(payloadTamper) }
    let previousHash = Array(fixture.frames[0].frameSHA256.utf8)
    var changedPrevious = previousHash
    changedPrevious[0] = changedPrevious[0] == 0x30 ? 0x31 : 0x30
    let chainTamper = try replaceFirst(fixture.bytes, previousHash, changedPrevious)
    try expectContract { _ = try parseSyntheticVariant(chainTamper) }
    try expectContract("input journal terminal LF") {
        _ = try parseSyntheticVariant(Array(fixture.bytes.dropLast()))
    }
    try expectContract("input journal empty frame") {
        _ = try parseSyntheticVariant(fixture.bytes + [0x0a])
    }
    let sealNeedle = Array(#""preseal_frame_count":7"#.utf8)
    let sealReplacement = Array(#""preseal_frame_count":6"#.utf8)
    let sealTamper = try replaceFirst(fixture.bytes, sealNeedle, sealReplacement)
    try expectContract { _ = try parseSyntheticVariant(sealTamper) }
}

private func testPairBindingsAndGeneration() throws {
    try testRequire(r19PairPins.count == 3, "pair pin count")
    let first = r19PairPins[0]
    let second = r19PairPins[1]
    let third = r19PairPins[2]
    try testRequire(first.0 == 1 && first.3 == 4 && first.6 == "wrapper" &&
                    second.0 == 2 && second.3 == 5 && second.6 == "guardian" &&
                    third.0 == 3 && third.3 == 6 && third.6 == "fixture",
                    "exact 1-4 2-5 3-6 pair pins")
    try testRequire(
        first.1 == "0d038102858c9e7eca6d33eee33b40c19b92818be95faf70ec89c1a53b0cc479" &&
        first.2 == "af0357467461ee7d29422d7f81081e941b743fc126834e4c0e199f629b09a8e1" &&
        first.4 == "772dbce9af1dfa2f8bb8482ce70486ea8b5ddc45b01d684ea8fa2c060e0b1809" &&
        first.5 == "6596221f97dd3417935747dc2e46079759654944a24fd34bbaaa7cbb50b12804" &&
        second.1 == "c5bf5cceca75877dfdb2613857a0753adb68f8db56abdcbd92058cb55f8c95ec" &&
        second.2 == "3828ef81a1260b63c6707c27869ab0229c57deb4b0c7bd0af39f336688799181" &&
        second.4 == "395fd45de1a1a1b896dea6c71da620d8e46f386cc43ed064b1e8f28561ad5f71" &&
        second.5 == "2bacc9cee04aabd82b377cac5cd306e624722a72b5fa81abaca3b1dec2768064" &&
        third.1 == "9da1c5798c88eaa29a9671c51c997712690b3c5d455b45a5ca2e35fa4e282405" &&
        third.2 == "a003ca19f8651f62455c06a157abeef9f10662536605e85acf4fabd8c18fdc56" &&
        third.4 == "c7d354bd8fb70b97babe7aa2ac2f509282f982c19c3a3892dbb5c4ca068788ba" &&
        third.5 == "245eae5841d6f1be97804f25fb239ac44adb6632e29d5a4f94dacc52d9d7d799",
        "exact pair frame and payload pins")
    let fixture = try syntheticJournal()
    let values = try projections(fixture.frames)
    try testRequire(values.map { ($0.predecessor.ordinal, $0.current.ordinal) }
                        .map { String($0.0) + "-" + String($0.1) } == ["1-4", "2-5", "3-6"],
                    "projected pair order")
    let current = fixture.frames[5]
    let mutations: [(String, String, R19JSONValue)] = [
        ("payload", "label", .string("fixture")),
        ("payload", "pid", .number("999")),
        ("process", "unique_id", .number("999")),
        ("process", "idversion", .number("999")),
        ("process", "sid", .number("999")),
        ("process", "pgid", .number("999")),
        ("rusage_v6", "uuid_hex", .string("ffffffffffffffffffffffffffffffff")),
        ("rusage_v6", "process_start_abstime", .number("999")),
    ]
    for mutation in mutations {
        let changed = try replacingObservationField(
            current, container: mutation.0, key: mutation.1, value: mutation.2)
        try expectContract {
            _ = try r19ProjectInterval(
                predecessor: fixture.frames[2], current: changed, expectedLabel: "guardian")
        }
    }
}

private enum InputDatabaseCorruption: Equatable {
    case none
    case rawFrame
    case normalizedCell
}

private func makeSyntheticInputDatabase(
    frames: [R19ParsedFrame], corruption: InputDatabaseCorruption
) throws -> [UInt8] {
    let connection = try R19SQLiteConnection()
    try connection.execute("PRAGMA foreign_keys=ON")
    try connection.execute(
        "CREATE TABLE frames(ordinal INTEGER PRIMARY KEY,raw_frame BLOB NOT NULL)")
    try connection.execute(
        "CREATE TABLE process_samples(" +
        "ordinal INTEGER PRIMARY KEY,sample_round TEXT,target_label TEXT,pid TEXT," +
        "availability TEXT,unique_id_text TEXT,idversion_text TEXT,sid_text TEXT," +
        "pgid_text TEXT,process_status_text TEXT,energy_nj_text TEXT,interval_valid TEXT," +
        "interval_reason TEXT,energy_interpretation_valid TEXT,energy_interpretation TEXT," +
        "elapsed_estimate_ns_text TEXT,elapsed_minimum_ns_text TEXT," +
        "elapsed_maximum_ns_text TEXT,delta_cpu_ns_text TEXT,delta_energy_nj_text TEXT," +
        "delta_joules_text TEXT,delta_ergs_text TEXT," +
        "average_power_at_estimated_interval_w_approx_text TEXT," +
        "average_power_at_maximum_interval_w_approx_text TEXT," +
        "average_power_at_minimum_interval_w_approx_text TEXT," +
        "cpu_percent_at_estimated_interval_approx_text TEXT," +
        "cpu_percent_at_maximum_interval_approx_text TEXT," +
        "cpu_percent_at_minimum_interval_approx_text TEXT)")
    try connection.execute("CREATE TABLE source_records(id INTEGER PRIMARY KEY)")
    try connection.execute("CREATE TABLE source_lexical_references(id INTEGER PRIMARY KEY)")
    try connection.execute(
        "CREATE TABLE capture_seal(singleton INTEGER PRIMARY KEY,journal_bytes INTEGER," +
        "journal_sha256 TEXT,frame_count INTEGER,seal_frame_sha256 TEXT," +
        "source_record_count INTEGER)")

    do {
        let frameInsert = try connection.prepare("INSERT INTO frames VALUES(?,?)")
        defer { sqlite3_finalize(frameInsert) }
        for frame in frames {
            try r19Reset(frameInsert)
            try r19BindInt(frameInsert, 1, Int64(frame.ordinal))
            var raw = frame.rawWithLF
            if corruption == .rawFrame && frame.ordinal == 3 { raw[0] ^= 1 }
            try r19BindBlob(frameInsert, 2, raw)
            try r19SQLiteStepDone(frameInsert)
        }
    }

    let placeholders = String(repeating: "?,", count: 27) + "?"
    do {
        let sampleInsert = try connection.prepare("INSERT INTO process_samples VALUES(" +
                                                   placeholders + ")")
        defer { sqlite3_finalize(sampleInsert) }
        for ordinal in 1...6 {
            try r19Reset(sampleInsert)
            try r19BindInt(sampleInsert, 1, Int64(ordinal))
            var values = try r19ExpectedNormalizedValues(frames[ordinal])
            if corruption == .normalizedCell && ordinal == 4 { values[3] = "BROKEN" }
            for index in values.indices {
                try r19BindText(sampleInsert, Int32(index + 2), values[index])
            }
            try r19SQLiteStepDone(sampleInsert)
        }
    }
    for index in 1...28 {
        try connection.execute("INSERT INTO source_records VALUES(" + String(index) + ")")
    }
    for index in 1...211 {
        try connection.execute(
            "INSERT INTO source_lexical_references VALUES(" + String(index) + ")")
    }
    let journal = frames.flatMap(\.rawWithLF)
    do {
        let seal = try connection.prepare("INSERT INTO capture_seal VALUES(1,?,?,?,?,?)")
        defer { sqlite3_finalize(seal) }
        try r19BindInt(seal, 1, Int64(journal.count))
        try r19BindText(seal, 2, r19SHA256(journal))
        try r19BindInt(seal, 3, 8)
        try r19BindText(seal, 4, frames[7].frameSHA256)
        try r19BindInt(seal, 5, 28)
        try r19SQLiteStepDone(seal)
    }
    let bytes = try connection.serialize()
    try connection.close()
    return bytes
}

private func inputExpectations(_ bytes: [UInt8], frames: [R19ParsedFrame])
    -> R19InputDatabaseExpectations
{
    .init(
        bytes: bytes.count,
        sha256: r19SHA256(bytes),
        journalSHA256: r19SHA256(frames.flatMap(\.rawWithLF)),
        frameCount: 8,
        sampleCount: 6,
        sourceRecordCount: 28,
        lexicalReferenceCount: 211)
}

private func testInputDatabaseReconstruction() throws {
    let fixture = try syntheticJournal()
    let validBytes = try makeSyntheticInputDatabase(frames: fixture.frames, corruption: .none)
    let valid = try r19ValidateInputDatabase(
        bytes: validBytes,
        frames: fixture.frames,
        invokeFixedWrapper: false,
        expectations: inputExpectations(validBytes, frames: fixture.frames))
    try testRequire(valid.sourceRecordCount == 28, "input source record count")
    try valid.connection.close()

    let rawMismatch = try makeSyntheticInputDatabase(
        frames: fixture.frames, corruption: .rawFrame)
    try expectContract("input database frame bytes") {
        _ = try r19ValidateInputDatabase(
            bytes: rawMismatch,
            frames: fixture.frames,
            invokeFixedWrapper: false,
            expectations: inputExpectations(rawMismatch, frames: fixture.frames))
    }
    let normalizedMismatch = try makeSyntheticInputDatabase(
        frames: fixture.frames, corruption: .normalizedCell)
    try expectContract("input normalized cell") {
        _ = try r19ValidateInputDatabase(
            bytes: normalizedMismatch,
            frames: fixture.frames,
            invokeFixedWrapper: false,
            expectations: inputExpectations(normalizedMismatch, frames: fixture.frames))
    }
}

private let testJournalArtifact = R19DatabaseArtifact(
    role: "journal", path: r19InputRootPath + "/" + r19InputJournalLeaf,
    device: 1, inode: 2, uid: 501, gid: 20, mode: "0400", nlink: 1,
    bytes: r19InputJournalBytes, sha256: r19InputJournalSHA256)

private let testDatabaseArtifact = R19DatabaseArtifact(
    role: "database", path: r19InputRootPath + "/" + r19InputDatabaseLeaf,
    device: 1, inode: 3, uid: 501, gid: 20, mode: "0400", nlink: 1,
    bytes: r19InputDatabaseBytes, sha256: r19InputDatabaseSHA256)

private let testRootArtifact = R19RootArtifact(
    path: r19InputRootPath, device: 1, inode: 1, uid: 501, gid: 20,
    mode: "0500", nlink: 4, inventory: [r19InputJournalLeaf, r19InputDatabaseLeaf])

private func makeOverlayFixture() throws
    -> (frames: [R19OverlayFrame], projections: [R19IntervalProjection])
{
    let source = try syntheticJournal()
    let projected = try projections(source.frames)
    let frames = try r19BuildPrefixFrames(
        root: testRootArtifact,
        journal: testJournalArtifact,
        database: testDatabaseArtifact,
        projections: projected)
    return (frames, projected)
}

private func sqliteColumnNames(_ connection: R19SQLiteConnection, _ table: String) throws
    -> [String]
{
    let statement = try connection.prepare("PRAGMA table_info(" + table + ")")
    defer { sqlite3_finalize(statement) }
    var names: [String] = []
    while true {
        let result = sqlite3_step(statement)
        if result == SQLITE_DONE { break }
        if result != SQLITE_ROW {
            throw R19OverlayError.sqlite("test table_info scan", result)
        }
        guard let pointer = sqlite3_column_text(statement, 1) else {
            throw R19PureTestFailure(description: "table_info null")
        }
        names.append(String(cString: pointer))
    }
    return names
}

private func sqliteTableNames(_ connection: R19SQLiteConnection) throws -> [String] {
    let statement = try connection.prepare(
        "SELECT name FROM sqlite_schema WHERE type='table' AND name NOT LIKE 'sqlite_%' " +
        "ORDER BY name")
    defer { sqlite3_finalize(statement) }
    var names: [String] = []
    while true {
        let result = sqlite3_step(statement)
        if result == SQLITE_DONE { break }
        if result != SQLITE_ROW {
            throw R19OverlayError.sqlite("test sqlite_schema scan", result)
        }
        guard let pointer = sqlite3_column_text(statement, 0) else {
            throw R19PureTestFailure(description: "sqlite_schema null")
        }
        names.append(String(cString: pointer))
    }
    return names
}

private func testDDLAndRows() throws {
    try testRequire(r19DatabaseSchemaBytes.count == 4_068, "DDL bytes")
    try testRequire(r19DatabaseSchemaBytes.last != 0x0a, "DDL trailing LF")
    try testRequire(
        r19SHA256(r19DatabaseSchemaBytes) ==
            "e5cb95990c66af7933ed213be5335ebe76a3c373ac216eadb3d048ee6c06f52b",
        "DDL SHA256")
    let connection = try R19SQLiteConnection()
    for statement in r19DatabaseSchemaStatements { try connection.execute(statement) }
    let expectedColumns: [(String, [String])] = [
        ("metadata", ["key", "value"]),
        ("input_artifacts", ["role", "path", "device", "inode", "uid", "gid", "mode",
                             "nlink", "bytes", "sha256"]),
        ("intervals", ["source_frame_ordinal", "predecessor_frame_ordinal",
                       "source_frame_sha256", "predecessor_frame_sha256",
                       "source_payload_sha256", "predecessor_payload_sha256", "target_label",
                       "sample_round", "pid", "unique_id_text", "idversion_text", "sid", "pgid",
                       "rusage_uuid_hex", "process_start_abstime_text", "delta_user_ticks_text",
                       "delta_system_ticks_text", "delta_cpu_ticks_text", "elapsed_minimum_ns_text",
                       "elapsed_estimate_ns_text", "elapsed_maximum_ns_text", "delta_energy_nj_text",
                       "generation_join_status"]),
        ("field_adjudications", ["source_frame_ordinal", "field_surface", "field_name",
                                  "source_pointer", "original_lexeme", "verdict", "reason",
                                  "replacement_metric"]),
        ("metric_facts", ["source_frame_ordinal", "metric_name", "bound_kind",
                           "numerator_text", "denominator_text", "unit", "status",
                           "source_pointer", "approximation_text"]),
        ("overlay_frames", ["ordinal", "frame_kind", "byte_offset", "frame_bytes",
                             "frame_sha256", "previous_frame_sha256", "payload_sha256",
                             "raw_frame"]),
        ("overlay_seal", ["singleton", "projection_id", "authority_vector",
                           "journal_prefix_frame_count", "journal_prefix_bytes",
                           "journal_prefix_sha256", "journal_prefix_tail_frame_sha256",
                           "input_journal_sha256", "input_database_sha256"]),
    ]
    try testRequire(
        try sqliteTableNames(connection) ==
            expectedColumns.map { $0.0 }.sorted(by: r19LexicalLess),
        "exact DDL tables")
    for entry in expectedColumns {
        try testRequire(try sqliteColumnNames(connection, entry.0) == entry.1,
                        "DDL columns " + entry.0)
    }
    try connection.close()

    let fixture = try makeOverlayFixture()
    let product = try r19BuildOverlayDatabase(
        prefixFrames: fixture.frames,
        projections: fixture.projections,
        journalArtifact: testJournalArtifact,
        databaseArtifact: testDatabaseArtifact,
        invokeFixedWrappers: false)
    let counts = [
        "metadata": 13, "input_artifacts": 2, "intervals": 3,
        "field_adjudications": 24, "metric_facts": 33,
        "overlay_frames": 5, "overlay_seal": 1,
    ]
    for item in counts {
        try testRequire(product.snapshot.tables[item.key]?.count == item.value,
                        "row count " + item.key)
    }
    try testRequire(
        product.snapshot.tables["intervals"]?.map { $0[0] } == ["I4", "I5", "I6"] &&
        product.snapshot.tables["overlay_frames"]?.map { $0[0] } ==
            ["I0", "I1", "I2", "I3", "I4"] &&
        product.snapshot.tables["field_adjudications"]?.map { $0[0] } ==
            Array(repeating: "I4", count: 8) + Array(repeating: "I5", count: 8) +
                Array(repeating: "I6", count: 8) &&
        product.snapshot.tables["metric_facts"]?.map { $0[0] } ==
            Array(repeating: "I4", count: 11) + Array(repeating: "I5", count: 11) +
                Array(repeating: "I6", count: 11),
        "primary-key ordered snapshots")
}

private func testDeterministicGoldenIdentity() throws {
    let firstFixture = try makeOverlayFixture()
    let secondFixture = try makeOverlayFixture()
    let firstPrefix = firstFixture.frames.flatMap(\.rawWithLF)
    let secondPrefix = secondFixture.frames.flatMap(\.rawWithLF)
    try testRequire(firstPrefix == secondPrefix && r19SHA256(firstPrefix) == r19SHA256(secondPrefix),
                    "golden prefix identity")
    let first = try r19BuildOverlayDatabase(
        prefixFrames: firstFixture.frames,
        projections: firstFixture.projections,
        journalArtifact: testJournalArtifact,
        databaseArtifact: testDatabaseArtifact,
        invokeFixedWrappers: false)
    let second = try r19BuildOverlayDatabase(
        prefixFrames: secondFixture.frames,
        projections: secondFixture.projections,
        journalArtifact: testJournalArtifact,
        databaseArtifact: testDatabaseArtifact,
        invokeFixedWrappers: false)
    try testRequire(first.bytes == second.bytes && first.sha256 == second.sha256 &&
                    first.sha256 == r19SHA256(first.bytes),
                    "SQLite serialization byte identity")
}

private func testPartialSourceIndexResidual() throws {
    let fixture = try syntheticJournal()
    let bytes = try makeSyntheticInputDatabase(frames: fixture.frames, corruption: .none)
    let validation = try r19ValidateInputDatabase(
        bytes: bytes,
        frames: fixture.frames,
        invokeFixedWrapper: false,
        expectations: inputExpectations(bytes, frames: fixture.frames))
    try testRequire(validation.sourceRecordCount == 28 &&
                    validation.sourceLexicalReferenceCount == 211,
                    "28-of-37 source subset accepted")
    try validation.connection.close()
    let overlay = try makeOverlayFixture()
    let product = try r19BuildOverlayDatabase(
        prefixFrames: overlay.frames,
        projections: overlay.projections,
        journalArtifact: testJournalArtifact,
        databaseArtifact: testDatabaseArtifact,
        invokeFixedWrappers: false)
    let metadataRows = product.snapshot.tables["metadata"] ?? []
    try testRequire(metadataRows.contains([
        "Tsource_index_completeness",
        "TABSTAIN_NONEXHAUSTIVE_28_OF_37_PRESENTATION_SUBSET",
    ]), "named source-index residual")
}

private func testExtraArgumentPremutation() throws {
    try testRequire(r19ArgumentPreflight(1) == nil, "zero-argument acceptance")
    var outputRootMutationEntered = false
    if r19ArgumentPreflight(2) == nil { outputRootMutationEntered = true }
    try testRequire(r19ArgumentPreflight(2) == 64 && !outputRootMutationEntered,
                    "extra argument premutation rejection")
}

@main
private struct PrimeDriverV2R19ObservabilityCPUOverlayPureTests {
    static func main() {
        do {
            try testGuardianVector()
            try testZeroVectors()
            try testEnergyVector()
            try testCounterAndDenominatorRejections()
            try testUInt128AndDivision()
            try testHalfEvenFormatting()
            try testCanonicalJSONRejections()
            try testEightFrameJournal()
            try testPairBindingsAndGeneration()
            try testInputDatabaseReconstruction()
            try testDDLAndRows()
            try testDeterministicGoldenIdentity()
            try testPartialSourceIndexResidual()
            try testExtraArgumentPremutation()
            writeTestLine(STDOUT_FILENO,
                          "PASS prime-driver-v2-r19-observability-cpu-overlay-pure-tests 14/14\n")
            _exit(0)
        } catch {
            writeTestLine(STDERR_FILENO, "FAIL " + String(describing: error) + "\n")
            _exit(1)
        }
    }
}
