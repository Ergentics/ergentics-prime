// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
// DRAFT: the downstream original Planner must rejoin every canonical byte
// before an ExecutionPlanRawCapability can be consumed. No owner is decoded.
import Foundation
import CoreFoundation

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2ClosedShardObservation: Codable, Equatable, Sendable {
    public let ordinal: Int
    public let arm: String
    public let lane: String
    public let index: Int
    public let shardID: String
    public let selectedIdentifiers: [String]
    public let filterPattern: String
    public let canonicalPlanData: Data
    var relativeRoot: String { "shards/\(arm)/\(lane)/\(index)-\(shardID.prefix(16))" }
    var requiresXUnit: Bool { lane != "sequential_xctest" }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2ClosedScheduleObservation: Codable, Equatable, Sendable {
    public let runID: String
    public let canonicalShardsData: Data
    public let canonicalInventoryData: Data
    public let shards: [PrimeValidationDriverV2ClosedShardObservation]
}

/// A pure frozen-list projection, with no native execution authority. This
/// lower-layer mirror preserves the original Planner's hashes and JSON schema.
@_spi(PrimeValidationDriverV2RoleFacade)
public enum PrimeValidationDriverV2ClosedShardSchedule {
    static let xCount = 892, swiftCount = 12
    static let xBytes = 114_186, swiftBytes = 1_287
    static let xSHA = "93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b"
    static let swiftSHA = "487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3"
    static let slowSuite = "PrimeCoreTests.PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionDesignContractTests"

    public static func observeFrozenLists(runID: String, xctestData: Data,
        swiftTestingData: Data) throws -> PrimeValidationDriverV2ClosedScheduleObservation {
        guard !runID.isEmpty, runID.utf8.count <= 128,
              runID.utf8.allSatisfy({ (48...57).contains($0) || (65...90).contains($0)
                  || (97...122).contains($0) || $0 == 45 || $0 == 95 }),
              xctestData.count == xBytes, swiftTestingData.count == swiftBytes,
              PrimeSHA256.hexDigest(of: xctestData) == xSHA,
              PrimeSHA256.hexDigest(of: swiftTestingData) == swiftSHA else {
            throw hRejected("frozen_inventory_bytes")
        }
        let x = try identifiers(xctestData, swift: false)
        let s = try identifiers(swiftTestingData, swift: true)
        guard x.count == xCount, s.count == swiftCount, Set(x).isDisjoint(with: s) else {
            throw hRejected("frozen_inventory_identifiers")
        }
        let xp = try partitions(x, swift: false), sp = try partitions(s, swift: true)
        var shards: [PrimeValidationDriverV2ClosedShardObservation] = []
        var objects: [[String: Any]] = []
        func append(arm: String, lane: String, index: Int, ids: [String]) throws {
            let swift = lane == "swift_testing"
            let filter = arm == "reference" ? "" : pattern(ids, swift: swift)
            var object: [String: Any] = [
                "key": ["runID": runID, "arm": arm, "lane": lane, "index": index],
                "selectionMode": arm == "reference" ? "all_inventory" : "exact_filter",
                "testIDs": ids.map { ["framework": swift ? "swift_testing" : "xctest", "rawValue": $0] },
                "filterPattern": filter,
            ]
            let id = PrimeSHA256.hexDigest(of: try HJSON.encode(object))
            object["shardID"] = id
            shards.append(.init(ordinal: shards.count + 1, arm: arm, lane: lane, index: index,
                shardID: id, selectedIdentifiers: ids, filterPattern: filter,
                canonicalPlanData: try HJSON.encode(object)))
            objects.append(object)
        }
        for lane in ["parallel_xctest", "sequential_xctest", "swift_testing"] {
            try append(arm: "reference", lane: lane, index: 0, ids: lane == "swift_testing" ? s : x)
        }
        for lane in ["parallel_xctest", "sequential_xctest", "swift_testing"] {
            for (index, ids) in (lane == "swift_testing" ? sp : xp).enumerated() {
                try append(arm: "candidate", lane: lane, index: index, ids: ids)
            }
        }
        let inventory: [String: Any] = [
            "xctestListBinding": ["byteCount": xBytes, "sha256": xSHA],
            "swiftTestingListBinding": ["byteCount": swiftBytes, "sha256": swiftSHA],
            "xctestIDs": x.map { ["framework": "xctest", "rawValue": $0] },
            "swiftTestingIDs": s.map { ["framework": "swift_testing", "rawValue": $0] },
        ]
        return .init(runID: runID, canonicalShardsData: try HJSON.encode(objects),
            canonicalInventoryData: try HJSON.encode(inventory), shards: shards)
    }

    private static func identifiers(_ data: Data, swift: Bool) throws -> [String] {
        guard let text = String(data: data, encoding: .utf8),
              data.allSatisfy({ $0 == 10 || (33...126).contains($0) }) else { throw hRejected("list_utf8") }
        var lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        if lines.last == "" { lines.removeLast() }
        let result = try lines.map { line -> String in
            var value = line
            if !value.contains("/"), swift, let dot = value.lastIndex(of: ".") {
                value = String(value[..<dot]) + "/" + String(value[value.index(after: dot)...])
            }
            let pieces = value.split(separator: "/", omittingEmptySubsequences: false)
            guard pieces.count == 2, pieces[0].contains("."), !pieces[0].hasPrefix("."),
                  !pieces[0].hasSuffix("."), !pieces[0].contains(".."), !pieces[1].isEmpty,
                  swift == pieces[1].hasSuffix("()") else { throw hRejected("list_identifier") }
            return value
        }.sorted()
        guard Set(result).count == result.count else { throw hRejected("duplicate_identifier") }
        return result
    }

    private static func pattern(_ ids: [String], swift: Bool) -> String {
        let alternatives = "(?:" + ids.sorted().map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|") + ")"
        return "(?:^|[^A-Za-z0-9_])" + alternatives + (swift ? "(?:$|[^A-Za-z0-9_])" : "$")
    }

    private static func partitions(_ ids: [String], swift: Bool) throws -> [[String]] {
        let suites = Dictionary(grouping: ids.sorted()) { String($0.prefix { $0 != "/" }) }
        var result: [[String]] = [], current: [String] = []
        func fits(_ ids: [String]) -> Bool { ids.count <= 32 && pattern(ids, swift: swift).utf8.count <= 16_384 }
        func flush() { if !current.isEmpty { result.append(current.sorted()); current.removeAll(keepingCapacity: true) } }
        for suite in suites.keys.sorted() {
            let group = suites[suite]!.sorted()
            guard fits(group) else { throw hRejected("unpartitionable_suite") }
            if suite == slowSuite { flush(); result.append(group); continue }
            let combined = current + group
            if current.isEmpty || fits(combined) { current = combined }
            else { flush(); current = group }
        }
        flush()
        guard !result.isEmpty else { throw hRejected("empty_partition") }
        return result
    }
}

enum HJSON {
    static func encode(_ object: Any) throws -> Data {
        try PrimeCanonicalJSON.encode(Value(object))
    }
    static func object(_ data: Data) throws -> [String: Any] {
        guard data.count > 1, data.count <= 16 * 1024 * 1024,
              let object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              try encode(object) == data else { throw hRejected("canonical_object") }
        return object
    }

    /// Preserve integer spellings through JSONEncoder, including uptime and
    /// UInt64.max. JSONSerialization may emit integral values in exponent form.
    private indirect enum Value: Encodable {
        case null, boolean(Bool), signed(Int64), unsigned(UInt64), string(String)
        case array([Value]), object([String: Value])
        init(_ value: Any) throws {
            if value is NSNull { self = .null }
            else if let v = value as? String { self = .string(v) }
            else if let v = value as? NSNumber {
                if CFGetTypeID(v) == CFBooleanGetTypeID() { self = .boolean(v.boolValue) }
                else if let integer = Int64(v.stringValue) { self = .signed(integer) }
                else if let integer = UInt64(v.stringValue) { self = .unsigned(integer) }
                else { throw hRejected("non_integer_json") }
            } else if let v = value as? [Any] { self = .array(try v.map(Value.init)) }
            else if let v = value as? [String: Any] { self = .object(try v.mapValues(Value.init)) }
            else { throw hRejected("non_json_value") }
        }
        func encode(to encoder: Encoder) throws {
            var c = encoder.singleValueContainer()
            switch self {
            case .null: try c.encodeNil()
            case let .boolean(v): try c.encode(v)
            case let .signed(v): try c.encode(v)
            case let .unsigned(v): try c.encode(v)
            case let .string(v): try c.encode(v)
            case let .array(v): try c.encode(v)
            case let .object(v): try c.encode(v)
            }
        }
    }
}
func hRejected(_ coordinate: String) -> PrimeDurableArtifactError {
    .invalidSemantics("driver_v2_gate_h_" + coordinate)
}
