import CryptoKit
import Foundation

struct ProvenanceFailure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

struct ReceiptEntry: Codable, Identifiable, Sendable {
    let name: String
    let bytes: Int
    let sha256: String
    var id: String { name }
}

struct HistoricalSnapshot: Sendable {
    let entries: [ReceiptEntry]
    let graph: Data
    let merkleRoot: String
    let semanticRoot: String
    let graphHash: String
    let elapsed: String
    let originalImageHash: String
}

// Read-only integrity verification of one historical result. No projector,
// reconstructor, execution facade, source admission or receipt writer is linked.
enum ReceiptVerifier {
    static let runID = "native-static-177403f-r1"
    static let terminalHash = "1a4c92297c28f9e686bbe9930b54453d909a2102e3cde1d95dee9f1556e24568"
    static let graphHash = "5b5fcf3fa73b968b47ab6904eed3a6fc93b1cabbd3a6f36c4052e1fa98840bbd"
    static let names: Set<String> = [
        "00-start.json", "candidate-json.bin", "candidate-cbor.bin",
        "10-json-verifier.json", "11-json-graph.json", "12-json-roundtrip.json",
        "20-cbor-verifier.json", "21-cbor-graph.json", "22-cbor-roundtrip.json",
        "30-join-receipt.json", "31-authoritative-graph.json", "90-terminal.json",
    ]

    static func hash(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    static func verify(_ leaves: [String: Data]) throws -> HistoricalSnapshot {
        guard Set(leaves.keys) == names,
              leaves.values.allSatisfy({ $0.count <= 65_536 }),
              let terminal = leaves["90-terminal.json"],
              hash(terminal) == terminalHash else {
            throw ProvenanceFailure("Exact inventory or pinned historical terminal mismatch")
        }
        let object = try dictionary(terminal)
        guard object["schema"] as? String == "ergentics.private-compute.terminal.v1",
              object["run_id"] as? String == runID,
              object["result"] as? String == "STATIC_PASS_LOCAL",
              object["authority_vector"] as? String == "00000000",
              object["projection_write_mask"] as? String == "00000000",
              object["gate_e"] as? String == "ABSTAIN",
              object["live_gate_e_roles_executed"] as? Bool == false,
              object["source_subject_commit"] as? String == "04c5324ccfc6984ad7c407e93238cc44f9ce22dd",
              object["source_subject_tree"] as? String == "10615a2d66720b70ecafa891ab26e96ac9ee812e",
              object["source_subject_identity"] as? String == "2c25246de1b50148d8193167880828815b17c80e8ee66a09dec45b1430178fc1",
              object["scope_sha256"] as? String == "01eec8c9e0cd2ce613c349f6f9737075a4e88106b51d675ac02b77f1dd4acf58",
              let image = object["application_image_sha256"] as? String,
              image == "e2e55968f9d7e9778af58f015f2904430e869868a2d44aae342d09ea6de6f65a",
              let manifestObject = object["artifacts"] else {
            throw ProvenanceFailure("Historical identity or authority boundary mismatch")
        }
        let entries = try JSONDecoder().decode([ReceiptEntry].self,
            from: JSONSerialization.data(withJSONObject: manifestObject))
        let earlier = leaves.filter { $0.key != "90-terminal.json" }
        try validateManifest(entries, leaves: earlier)
        guard let graph = earlier["31-authoritative-graph.json"],
              graph == earlier["11-json-graph.json"], graph == earlier["21-cbor-graph.json"],
              hash(graph) == graphHash, object["graph_frame_sha256"] as? String == graphHash,
              let merkle = object["graph_merkle_root"] as? String,
              merkle == "ddfe414abae6918391ee34ee36166f68163e431e58d4182437f56a0839869810",
              let semantic = object["semantic_root"] as? String,
              semantic == "093b6e90214704a3e8fdf28cf430a8c4cd106d695e621887b77db489fc5cd9bb",
              let startBytes = earlier["00-start.json"] else {
            throw ProvenanceFailure("Retained graph byte equality or commitment mismatch")
        }
        let start = try dictionary(startBytes)
        let startClock = try clock(start["clock_start"])
        let terminalStart = try clock(object["clock_start"])
        let endClock = try clock(object["clock_end"])
        guard start["run_id"] as? String == runID,
              start["utc_start"] as? String == object["utc_start"] as? String,
              startClock == terminalStart,
              startClock.numerator == endClock.numerator,
              startClock.denominator == endClock.denominator else {
            throw ProvenanceFailure("Historical start/end join mismatch")
        }
        let elapsed = try rationalInterval(start: startClock.ticks, end: endClock.ticks,
                                           numerator: startClock.numerator, denominator: startClock.denominator)
        guard object["exact_elapsed_nanoseconds"] as? String == elapsed else {
            throw ProvenanceFailure("Historical timebase arithmetic mismatch")
        }
        return HistoricalSnapshot(entries: (entries + [ReceiptEntry(name: "90-terminal.json",
            bytes: terminal.count, sha256: terminalHash)]).sorted { $0.name < $1.name },
            graph: graph, merkleRoot: merkle, semanticRoot: semantic,
            graphHash: graphHash, elapsed: elapsed, originalImageHash: image)
    }

    // Pure, independently testable manifest kernel. The production entry first
    // binds the exact terminal digest and inventory; callers cannot change a pin.
    static func validateManifest(_ entries: [ReceiptEntry], leaves: [String: Data]) throws {
        guard entries.count == leaves.count,
              Set(entries.map(\.name)).count == entries.count,
              Set(entries.map(\.name)) == Set(leaves.keys) else {
            throw ProvenanceFailure("Manifest inventory mismatch or duplicate")
        }
        for entry in entries {
            guard !entry.name.isEmpty, !entry.name.contains("/"),
                  entry.name != ".", entry.name != "..", !entry.name.contains("\0"),
                  entry.bytes >= 0, entry.bytes <= 65_536,
                  let data = leaves[entry.name], data.count == entry.bytes,
                  hash(data) == entry.sha256 else {
                throw ProvenanceFailure("Manifest size/hash mismatch: " + entry.name)
            }
        }
    }

    static func rationalInterval(start: UInt64, end: UInt64, numerator: UInt64, denominator: UInt64) throws -> String {
        guard end >= start, numerator > 0, denominator > 0 else {
            throw ProvenanceFailure("Invalid rational time interval")
        }
        let (product, overflow) = (end - start).multipliedReportingOverflow(by: numerator)
        guard !overflow else { throw ProvenanceFailure("Interval exceeds UInt64; no rounded replacement") }
        return "\(product) / \(denominator) ns"
    }

    private struct Clock: Equatable { let ticks: UInt64; let numerator: UInt64; let denominator: UInt64 }
    private static func clock(_ object: Any?) throws -> Clock {
        guard let value = object as? [String: Any], value["raw_error"] as? Int == 0,
              let t = (value["ticks"] as? String).flatMap(UInt64.init),
              let n = (value["numerator"] as? String).flatMap(UInt64.init),
              let d = (value["denominator"] as? String).flatMap(UInt64.init) else {
            throw ProvenanceFailure("Malformed raw clock")
        }
        return Clock(ticks: t, numerator: n, denominator: d)
    }
    private static func dictionary(_ bytes: Data) throws -> [String: Any] {
        guard let value = try JSONSerialization.jsonObject(with: bytes) as? [String: Any] else {
            throw ProvenanceFailure("Expected JSON object")
        }
        return value
    }
}
