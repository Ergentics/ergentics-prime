import CryptoKit
import Foundation
import GateEJSONAuthority
import GateECBORAuthority
import GateEDualGraphJoin

public struct PrivateComputeFailure: Error, Equatable, Sendable, CustomStringConvertible {
    public let description: String
    public init(_ description: String) { self.description = description }
}

public struct StaticInputs: Sendable {
    public let json: Data
    public let cbor: Data
    public init(json: Data, cbor: Data) { self.json = json; self.cbor = cbor }
}

public struct StaticComputation: Sendable {
    public let artifacts: [String: Data]
    public let semanticRoot: String
    public let merkleRoot: String
    public let graphHash: String
}

public enum PrivateComputeCore {
    public static let jsonHash = "cda57fec7b6ee67d308eddc1f19d6a844d7f72f7d02aea487ee73e265039961e"
    public static let cborHash = "c7242f65b69d16f05c67425241297e4e5d598eecc4155aca01c73e40af817636"
    public static let semanticRoot = "093b6e90214704a3e8fdf28cf430a8c4cd106d695e621887b77db489fc5cd9bb"
    public static let sourceCommit = "04c5324ccfc6984ad7c407e93238cc44f9ce22dd"
    public static let sourceTree = "10615a2d66720b70ecafa891ab26e96ac9ee812e"
    public static let sourceIdentity = "2c25246de1b50148d8193167880828815b17c80e8ee66a09dec45b1430178fc1"

    public static func sha256(_ bytes: Data) -> String {
        SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }

    // Fixed independent carriers, not a JSON-to-CBOR conversion.
    public static func admitCarriers(json: Data, cbor: Data) throws -> StaticInputs {
        guard sha256(json) == "15006935c6ad4933d8084e646c9c7254878923f4889fca85e50496d0c507cee8",
              sha256(cbor) == "9e77f8b16c24da21ba1582e4464c6954aa548340a8c4d6edd6100be13859b84a"
        else { throw PrivateComputeFailure("Bundled carrier identity mismatch") }
        let inputs = StaticInputs(json: try decodeHex(json), cbor: try decodeHex(cbor))
        try admitInputs(inputs)
        return inputs
    }

    public static func decodeHex(_ carrier: Data) throws -> Data {
        var bytes = Array(carrier)
        guard bytes.count <= 8_193, bytes.last == 10 else {
            throw PrivateComputeFailure("Hex carrier requires one terminal LF and bounded size")
        }
        bytes.removeLast()
        guard !bytes.isEmpty, bytes.count.isMultiple(of: 2) else {
            throw PrivateComputeFailure("Hex carrier has invalid framing")
        }
        func nibble(_ byte: UInt8) throws -> UInt8 {
            switch byte {
            case 48...57: return byte - 48
            case 97...102: return byte - 87
            default: throw PrivateComputeFailure("Hex carrier is not lowercase ASCII")
            }
        }
        var decoded = Data()
        for index in stride(from: 0, to: bytes.count, by: 2) {
            decoded.append(try (nibble(bytes[index]) << 4) | nibble(bytes[index + 1]))
        }
        return decoded
    }

    private static func admitInputs(_ inputs: StaticInputs) throws {
        guard inputs.json.count == 1_405, sha256(inputs.json) == jsonHash,
              inputs.cbor.count == 1_239, sha256(inputs.cbor) == cborHash else {
            throw PrivateComputeFailure("Fixed candidate bytes do not match the separate pins")
        }
    }

    public static func compute(_ inputs: StaticInputs) throws -> StaticComputation {
        try admitInputs(inputs)
        let json = try GateEJSONAuthority.projectAndVerify(candidate: Array(inputs.json))
        let jsonRoundTrip = try GateEJSONReconstructor.reconstructAndReceipt(
            candidate: Array(inputs.json), graphFrame: json.graphFrame)
        let cbor = try GateECBORAuthority.projectAndVerify(candidate: Array(inputs.cbor))
        let cborRoundTrip = try GateECBORReconstructor.reconstructAndReceipt(
            candidate: Array(inputs.cbor), graphFrame: cbor.graphFrame)
        let joined = try GateEDualGraphJoin.join(
            jsonGraph: json.graphFrame, jsonVerifier: json.verifierReceipt,
            jsonRoundTrip: jsonRoundTrip, cborGraph: cbor.graphFrame,
            cborVerifier: cbor.verifierReceipt, cborRoundTrip: cborRoundTrip)
        let artifacts: [String: Data] = [
            "candidate-json.bin": inputs.json, "candidate-cbor.bin": inputs.cbor,
            "10-json-verifier.json": Data(json.verifierReceipt),
            "11-json-graph.json": Data(json.graphFrame),
            "12-json-roundtrip.json": Data(jsonRoundTrip),
            "20-cbor-verifier.json": Data(cbor.verifierReceipt),
            "21-cbor-graph.json": Data(cbor.graphFrame),
            "22-cbor-roundtrip.json": Data(cborRoundTrip),
            "30-join-receipt.json": Data(joined.joinReceipt),
            "31-authoritative-graph.json": Data(joined.authoritativeGraph),
        ]
        return try inspectValidatedArtifacts(artifacts)
    }

    // Read-only replay validates retained bytes. It cannot create a run or receipt.
    public static func validateRetained(_ artifacts: [String: Data]) throws -> StaticComputation {
        func required(_ leaf: String) throws -> Data {
            guard let bytes = artifacts[leaf], !bytes.isEmpty, bytes.count <= 1_048_576
            else { throw PrivateComputeFailure("Missing or oversized retained leaf: " + leaf) }
            return bytes
        }
        try admitInputs(StaticInputs(json: required("candidate-json.bin"), cbor: required("candidate-cbor.bin")))
        let joined = try GateEDualGraphJoin.join(
            jsonGraph: Array(required("11-json-graph.json")),
            jsonVerifier: Array(required("10-json-verifier.json")),
            jsonRoundTrip: Array(required("12-json-roundtrip.json")),
            cborGraph: Array(required("21-cbor-graph.json")),
            cborVerifier: Array(required("20-cbor-verifier.json")),
            cborRoundTrip: Array(required("22-cbor-roundtrip.json")))
        guard Data(joined.authoritativeGraph) == artifacts["31-authoritative-graph.json"],
              Data(joined.joinReceipt) == artifacts["30-join-receipt.json"]
        else { throw PrivateComputeFailure("Retained join output does not reproduce") }
        return try inspectValidatedArtifacts(artifacts)
    }

    private static func inspectValidatedArtifacts(_ artifacts: [String: Data]) throws -> StaticComputation {
        guard artifacts.count == 10,
              let joined = artifacts["30-join-receipt.json"],
              let graph = artifacts["31-authoritative-graph.json"],
              let receipt = try JSONSerialization.jsonObject(with: joined) as? [String: Any],
              receipt["result"] as? String == "PASS",
              receipt["authority_vector"] as? String == "00000000",
              receipt["projection_write_mask"] as? String == "00000000",
              receipt["semantic_root"] as? String == semanticRoot,
              let root = receipt["graph_merkle_root"] as? String,
              receipt["json_graph_frame_sha256"] as? String == sha256(graph),
              receipt["cbor_graph_frame_sha256"] as? String == sha256(graph),
              artifacts["11-json-graph.json"] == graph,
              artifacts["21-cbor-graph.json"] == graph
        else { throw PrivateComputeFailure("Pinned post-join data equality failed") }
        for (prefix, expected) in [("10-json-verifier.json", jsonHash), ("20-cbor-verifier.json", cborHash)] {
            guard let bytes = artifacts[prefix],
                  let verifier = try JSONSerialization.jsonObject(with: bytes) as? [String: Any],
                  verifier["candidate_sha256"] as? String == expected else {
                throw PrivateComputeFailure("Verifier does not bind the pinned input")
            }
        }
        for (leaf, expected) in [("12-json-roundtrip.json", jsonHash), ("22-cbor-roundtrip.json", cborHash)] {
            guard let bytes = artifacts[leaf],
                  let roundTrip = try JSONSerialization.jsonObject(with: bytes) as? [String: Any],
                  roundTrip["candidate_sha256"] as? String == expected,
                  roundTrip["reconstructed_candidate_sha256"] as? String == expected else {
                throw PrivateComputeFailure("Round trip does not bind the pinned input")
            }
        }
        // JSONSerialization is display/outer binding only. The independent join
        // already checked canonical bytes, graph rows, predicates and Merkle math.
        return StaticComputation(artifacts: artifacts, semanticRoot: semanticRoot,
                                 merkleRoot: root, graphHash: sha256(graph))
    }

    public static func exactNanoseconds(start: UInt64, end: UInt64,
                                        numerator: UInt32, denominator: UInt32) throws -> String {
        guard end >= start, numerator > 0, denominator > 0 else {
            throw PrivateComputeFailure("Invalid monotonic-clock frame")
        }
        let delta = end - start
        let product = delta.multipliedReportingOverflow(by: UInt64(numerator))
        if product.overflow { return "\(delta) × \(numerator) / \(denominator) ns" }
        return "\(product.partialValue) / \(denominator) ns"
    }
}
