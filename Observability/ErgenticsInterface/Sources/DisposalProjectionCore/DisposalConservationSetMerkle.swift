import Foundation

struct DisposalConservationMerkleProofNode: Equatable, Sendable {
    let siblingPosition: String
    let siblingSHA256: String
}

enum DisposalConservationSetMerkle {
    static let schema = "ergentics-disposal-conservation-set-commitment-v1"
    static let purpose = "COMPLETE_ACTUATION_OBLIGATION_SET"
    static let scopeKind = "INVOCATION_ACTUATION_OBLIGATIONS"
    static let algorithm = "SHA256"
    static let domainTag = "ERGENTICS_DISPOSAL_CONSERVATION_SET_LENGTH_FRAMED_V1"
    static let leafOrdering = "OBLIGATION_KEY_SHA256_RAW_ASC"
    static let duplicatePolicy = "REJECT_DUPLICATE_OBLIGATION_KEY"
    static let treeShape =
        "RFC6962_LARGEST_POWER_OF_TWO_SPLIT_WITH_ERGENTICS_LENGTH_FRAMED_HASHES"
    static let oddLeafRule = "RFC6962_NO_DUPLICATION"

    static func semanticID(_ domain: String, _ components: [String]) -> String {
        var bytes = Data("ERGENTICS_DISPOSAL_MERKLE_ID_V1".utf8)
        appendUInt64BE(UInt64(domain.utf8.count), to: &bytes)
        bytes.append(contentsOf: domain.utf8)
        appendUInt64BE(UInt64(components.count), to: &bytes)
        for component in components {
            appendUInt64BE(UInt64(component.utf8.count), to: &bytes)
            bytes.append(contentsOf: component.utf8)
        }
        return disposalSHA256(bytes)
    }

    static func obligationKey(
        commitmentFrameLFSHA256: String,
        targetRole: String,
        targetForm: String,
        targetPID: Int,
        targetUniqueID: UInt64,
        targetIDVersion: UInt64,
        operation: String,
        numericArgument: Int,
        signalNumber: Int,
        budgetOrdinal: Int
    ) -> String {
        semanticID(
            "disposal-conservation-obligation-key-v1",
            [
                domainTag,
                commitmentFrameLFSHA256,
                targetRole,
                targetForm,
                String(targetPID),
                String(targetUniqueID),
                String(targetIDVersion),
                operation,
                String(numericArgument),
                String(signalNumber),
                String(budgetOrdinal),
            ])
    }

    static func leafSHA256(obligationKeySHA256: String) -> String {
        semanticID(
            "disposal-conservation-set-leaf-v1",
            [domainTag, obligationKeySHA256])
    }

    static func root(canonicalObligationKeys keys: [String]) throws -> String {
        try validateCanonicalObligationKeys(keys)
        return try subtreeRoot(keys.map {
            leafSHA256(obligationKeySHA256: $0)
        })
    }

    static func proof(
        leafOrdinal: Int,
        canonicalObligationKeys keys: [String]
    ) throws -> [DisposalConservationMerkleProofNode] {
        try validateCanonicalObligationKeys(keys)
        guard keys.indices.contains(leafOrdinal) else {
            throw DisposalProjectionRejection(code: "TYPED_MERKLE_PROOF_ORDINAL")
        }
        return try subtreeProof(
            index: leafOrdinal,
            leaves: keys.map { leafSHA256(obligationKeySHA256: $0) })
    }

    static func verify(
        leafSHA256: String,
        proof: [DisposalConservationMerkleProofNode],
        rootSHA256: String
    ) -> Bool {
        guard disposalIsLowerHex(leafSHA256, count: 64),
              disposalIsLowerHex(rootSHA256, count: 64),
              proof.allSatisfy({
                  ($0.siblingPosition == "LEFT" || $0.siblingPosition == "RIGHT") &&
                      disposalIsLowerHex($0.siblingSHA256, count: 64)
              })
        else { return false }
        let derived = proof.reduce(leafSHA256) { partial, node in
            if node.siblingPosition == "LEFT" {
                return internalSHA256(left: node.siblingSHA256, right: partial)
            }
            return internalSHA256(left: partial, right: node.siblingSHA256)
        }
        return derived == rootSHA256
    }

    static func proofSHA256(_ proof: [DisposalConservationMerkleProofNode]) -> String {
        semanticID(
            "disposal-conservation-set-proof-v1",
            [domainTag] + proof.flatMap { [$0.siblingPosition, $0.siblingSHA256] })
    }

    private static func subtreeRoot(_ leaves: [String]) throws -> String {
        if leaves.count == 1 { return leaves[0] }
        let split = largestPowerOfTwoLessThan(leaves.count)
        let left = try subtreeRoot(Array(leaves[..<split]))
        let right = try subtreeRoot(Array(leaves[split...]))
        return internalSHA256(left: left, right: right)
    }

    private static func subtreeProof(
        index: Int,
        leaves: [String]
    ) throws -> [DisposalConservationMerkleProofNode] {
        if leaves.count == 1 { return [] }
        let split = largestPowerOfTwoLessThan(leaves.count)
        if index < split {
            var result = try subtreeProof(index: index, leaves: Array(leaves[..<split]))
            result.append(.init(
                siblingPosition: "RIGHT",
                siblingSHA256: try subtreeRoot(Array(leaves[split...]))))
            return result
        }
        var result = try subtreeProof(index: index - split, leaves: Array(leaves[split...]))
        result.append(.init(
            siblingPosition: "LEFT",
            siblingSHA256: try subtreeRoot(Array(leaves[..<split]))))
        return result
    }

    private static func internalSHA256(left: String, right: String) -> String {
        semanticID("disposal-conservation-set-node-v1", [domainTag, left, right])
    }

    private static func validateCanonicalObligationKeys(_ keys: [String]) throws {
        guard !keys.isEmpty else {
            throw DisposalProjectionRejection(code: "TYPED_MERKLE_EMPTY_SET")
        }
        guard keys.allSatisfy({ disposalIsLowerHex($0, count: 64) }) else {
            throw DisposalProjectionRejection(code: "TYPED_MERKLE_OBLIGATION_KEY_SHA256")
        }
        guard Set(keys).count == keys.count else {
            throw DisposalProjectionRejection(code: "TYPED_MERKLE_DUPLICATE_OBLIGATION_KEY")
        }
        guard keys == keys.sorted(by: {
            $0.utf8.lexicographicallyPrecedes($1.utf8)
        }) else {
            throw DisposalProjectionRejection(code: "TYPED_MERKLE_OBLIGATION_KEY_ORDER")
        }
    }

    private static func largestPowerOfTwoLessThan(_ value: Int) -> Int {
        var result = 1
        while result <= (value - 1) / 2 { result *= 2 }
        return result
    }

    private static func appendUInt64BE(_ value: UInt64, to data: inout Data) {
        var encoded = value.bigEndian
        withUnsafeBytes(of: &encoded) { data.append(contentsOf: $0) }
    }
}
