// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
// DRAFT: the downstream original Planner must rejoin every canonical byte
// before an ExecutionPlanRawCapability can be consumed. No owner is decoded.
import Foundation
import CoreFoundation

/// Closed inventory pairs. The six baseline fields, not this descriptive name,
/// are their serialized identity. Values cannot be assembled by SPI callers.
@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2InventoryProfile: Equatable, Sendable {
    public let identifier: String
    public let expectedXCTestCount: Int
    public let expectedSwiftTestingCount: Int
    public let expectedXCTestListByteCount: UInt64
    public let expectedXCTestListSHA256: String
    public let expectedSwiftTestingListByteCount: UInt64
    public let expectedSwiftTestingListSHA256: String

    private init(identifier: String, expectedXCTestCount: Int,
        expectedSwiftTestingCount: Int, expectedXCTestListByteCount: UInt64,
        expectedXCTestListSHA256: String, expectedSwiftTestingListByteCount: UInt64,
        expectedSwiftTestingListSHA256: String) {
        self.identifier = identifier
        self.expectedXCTestCount = expectedXCTestCount
        self.expectedSwiftTestingCount = expectedSwiftTestingCount
        self.expectedXCTestListByteCount = expectedXCTestListByteCount
        self.expectedXCTestListSHA256 = expectedXCTestListSHA256
        self.expectedSwiftTestingListByteCount = expectedSwiftTestingListByteCount
        self.expectedSwiftTestingListSHA256 = expectedSwiftTestingListSHA256
    }

    public static let historical904 = Self(identifier: "historical_904_v1",
        expectedXCTestCount: 892, expectedSwiftTestingCount: 12,
        expectedXCTestListByteCount: 114_186,
        expectedXCTestListSHA256: "93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b",
        expectedSwiftTestingListByteCount: 1_287,
        expectedSwiftTestingListSHA256: "487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3")

    // Both lists were captured together by native G on 3c952463 and replayed
    // by the independent Swift parser. Selection still requires the exact
    // retained intent; see the separate current-source-inventory-v1 reseal.
    public static let currentSourceInventoryV1 = Self(identifier: "current_source_inventory_v1",
        expectedXCTestCount: 1_068, expectedSwiftTestingCount: 12,
        expectedXCTestListByteCount: 139_244,
        expectedXCTestListSHA256: "7428f3e1ebc8e76eb312c54feac209d0c70d8d741e1eb38cbab8b1d5b815ece2",
        expectedSwiftTestingListByteCount: 1_287,
        expectedSwiftTestingListSHA256: "487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3")

    private static let profiles: [Self] = [.historical904, .currentSourceInventoryV1]

    public static func resolve(expectedXCTestCount: Int, expectedSwiftTestingCount: Int,
        expectedXCTestListByteCount: UInt64, expectedXCTestListSHA256: String,
        expectedSwiftTestingListByteCount: UInt64,
        expectedSwiftTestingListSHA256: String) -> Self? {
        profiles.first {
            $0.expectedXCTestCount == expectedXCTestCount
                && $0.expectedSwiftTestingCount == expectedSwiftTestingCount
                && $0.expectedXCTestListByteCount == expectedXCTestListByteCount
                && $0.expectedXCTestListSHA256 == expectedXCTestListSHA256
                && $0.expectedSwiftTestingListByteCount == expectedSwiftTestingListByteCount
                && $0.expectedSwiftTestingListSHA256 == expectedSwiftTestingListSHA256
        }
    }

    /// The native owner resolves only the exact object retained in its intent.
    /// Canonical equality rejects extra keys and numeric coercion/truncation.
    static func resolve(canonicalBaselineData: Data) throws -> Self? {
        for profile in profiles {
            if try HJSON.encode(profile.baselineObject) == canonicalBaselineData {
                return profile
            }
        }
        return nil
    }

    private var baselineObject: [String: Any] {
        ["expectedXCTestCount": expectedXCTestCount,
         "expectedSwiftTestingCount": expectedSwiftTestingCount,
         "expectedXCTestListByteCount": expectedXCTestListByteCount,
         "expectedXCTestListSHA256": expectedXCTestListSHA256,
         "expectedSwiftTestingListByteCount": expectedSwiftTestingListByteCount,
         "expectedSwiftTestingListSHA256": expectedSwiftTestingListSHA256]
    }
}

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
    static let slowSuite = "PrimeCoreTests.PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionDesignContractTests"

    public static func observeFrozenLists(runID: String, xctestData: Data,
        swiftTestingData: Data, profile: PrimeValidationDriverV2InventoryProfile = .historical904)
        throws -> PrimeValidationDriverV2ClosedScheduleObservation {
        guard !runID.isEmpty, runID.utf8.count <= 128,
              runID.utf8.allSatisfy({ (48...57).contains($0) || (65...90).contains($0)
                  || (97...122).contains($0) || $0 == 45 || $0 == 95 }),
              UInt64(xctestData.count) == profile.expectedXCTestListByteCount,
              UInt64(swiftTestingData.count) == profile.expectedSwiftTestingListByteCount,
              PrimeSHA256.hexDigest(of: xctestData) == profile.expectedXCTestListSHA256,
              PrimeSHA256.hexDigest(of: swiftTestingData) == profile.expectedSwiftTestingListSHA256 else {
            throw hRejected("frozen_inventory_bytes")
        }
        let x = try identifiers(xctestData, swift: false)
        let s = try identifiers(swiftTestingData, swift: true)
        guard x.count == profile.expectedXCTestCount,
              s.count == profile.expectedSwiftTestingCount, Set(x).isDisjoint(with: s) else {
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
            "xctestListBinding": ["byteCount": profile.expectedXCTestListByteCount,
                "sha256": profile.expectedXCTestListSHA256],
            "swiftTestingListBinding": ["byteCount": profile.expectedSwiftTestingListByteCount,
                "sha256": profile.expectedSwiftTestingListSHA256],
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
