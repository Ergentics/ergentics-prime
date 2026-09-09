import CryptoKit
import Foundation

struct GenesisLeaf: Sendable {
    let label: String
    let payload: Data
}

struct GenesisCommitment: Equatable, Sendable {
    let root: String
    let leafHashes: [String: String]
    let leafCount: Int
}

enum GenesisFailure: Error, Equatable {
    case emptySet
    case tooManyLeaves
    case emptyLabel
    case duplicateLabel
    case missingSchema
    case tooManyBytes
}

// Pure commitment of exact caller-provided bytes. This neither creates a VM
// nor gives those bytes authority. The returned root is outside the leaf set.
enum MerkleGenesis {
    static let maximumLeaves = 128
    // Counts the UTF-8 labels plus payloads, excluding fixed framing overhead.
    static let maximumBytes = 1_048_576

    static func commit(_ leaves: [GenesisLeaf]) throws -> GenesisCommitment {
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
        return GenesisCommitment(root: hex(Data(SHA256.hash(data: rootFrame))),
            leafHashes: leafHashes, leafCount: ordered.count)
    }

    // Independent tree reconstruction: it does not call commit or its framing
    // helper. Only bounded input admission and SHA-256 are shared. Invalid root
    // encodings compare false; invalid leaf sets throw before reconstruction.
    static func verify(_ leaves: [GenesisLeaf], expectedRoot: String) throws -> Bool {
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

    private static func admitted(_ leaves: [GenesisLeaf]) throws -> [GenesisLeaf] {
        guard !leaves.isEmpty else { throw GenesisFailure.emptySet }
        guard leaves.count <= maximumLeaves else { throw GenesisFailure.tooManyLeaves }
        var names = Set<String>()
        var total = 0
        for leaf in leaves {
            let labelCount = leaf.label.utf8.count
            guard labelCount > 0 else { throw GenesisFailure.emptyLabel }
            // String-key equivalence also rejects composed/decomposed aliases:
            // the public leafHashes dictionary cannot represent both safely.
            // Accepted labels retain their original UTF-8 bytes unchanged.
            guard names.insert(leaf.label).inserted else { throw GenesisFailure.duplicateLabel }
            guard labelCount <= maximumBytes - total else { throw GenesisFailure.tooManyBytes }
            total += labelCount
            guard leaf.payload.count <= maximumBytes - total else { throw GenesisFailure.tooManyBytes }
            total += leaf.payload.count
        }
        guard names.contains("schema") else { throw GenesisFailure.missingSchema }
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
