import CryptoKit
import Foundation
import XCTest

final class MerkleGenesisTests: XCTestCase {
    private let schema = GenesisLeaf(label: "schema", payload: Data("v1".utf8))

    private func digest(_ data: Data) -> Data { Data(SHA256.hash(data: data)) }
    private func hex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }
    private func decoded(_ text: String) -> Data {
        let characters = Array(text)
        return Data(stride(from: 0, to: characters.count, by: 2).map {
            UInt8(String(characters[$0...($0 + 1)]), radix: 16)!
        })
    }
    private func wrapped(_ top: Data, count: UInt64) -> Data {
        var bytes = Data([0x02])
        var bigEndian = count.bigEndian
        withUnsafeBytes(of: &bigEndian) { bytes.append(contentsOf: $0) }
        bytes.append(top)
        return digest(bytes)
    }

    func testSingleLeafExplicitBinaryFrameVector() throws {
        // Literal framing, independent of the production integer encoders:
        // 00 | 00000006 | "schema" | 0000000000000002 | "v1".
        let frame = Data([0x00, 0x00, 0x00, 0x00, 0x06,
            0x73, 0x63, 0x68, 0x65, 0x6d, 0x61,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x76, 0x31])
        let leaf = digest(frame)
        let result = try MerkleGenesis.commit([schema])
        XCTAssertEqual(result.leafCount, 1)
        XCTAssertEqual(result.leafHashes, ["schema": hex(leaf)])
        XCTAssertEqual(result.root, hex(wrapped(leaf, count: 1)))
        XCTAssertNotEqual(result.root, hex(leaf))
        XCTAssertTrue(try MerkleGenesis.verify([schema], expectedRoot: result.root))
    }

    func testAllFourDomainsAreDistinct() {
        let child = Data(repeating: 0x41, count: 32)
        let hashes = (UInt8(0)...UInt8(3)).map { hex(digest(Data([$0]) + child)) }
        XCTAssertEqual(Set(hashes).count, 4)
    }

    func testInputOrderDoesNotMatterAndUTF8OrderIsUsed() throws {
        let leaves = [GenesisLeaf(label: "😀", payload: Data([3])),
            GenesisLeaf(label: "z", payload: Data([1])), schema,
            GenesisLeaf(label: "é", payload: Data([2]))]
        let result = try MerkleGenesis.commit(leaves)
        XCTAssertEqual(result, try MerkleGenesis.commit(Array(leaves.reversed())))
        let hashes = ["schema", "z", "é", "😀"].map { decoded(result.leafHashes[$0]!) }
        let left = digest(Data([0x01]) + hashes[0] + hashes[1])
        let right = digest(Data([0x01]) + hashes[2] + hashes[3])
        XCTAssertEqual(result.root, hex(wrapped(digest(Data([0x01]) + left + right), count: 4)))
    }

    func testPayloadTamperFailsIndependentVerification() throws {
        let result = try MerkleGenesis.commit([schema])
        let changed = GenesisLeaf(label: "schema", payload: Data("v2".utf8))
        XCTAssertFalse(try MerkleGenesis.verify([changed], expectedRoot: result.root))
    }

    func testLabelIsCommittedAndLengthsSeparateFields() throws {
        let left = [schema, GenesisLeaf(label: "a", payload: Data("bc".utf8))]
        let right = [schema, GenesisLeaf(label: "ab", payload: Data("c".utf8))]
        XCTAssertNotEqual(try MerkleGenesis.commit(left).root, try MerkleGenesis.commit(right).root)
    }

    func testOddNodeUsesUnaryDomainNotDuplicatedLastDigest() throws {
        let leaves = [schema, GenesisLeaf(label: "a", payload: Data([1])),
            GenesisLeaf(label: "b", payload: Data([2]))]
        let result = try MerkleGenesis.commit(leaves)
        let a = decoded(result.leafHashes["a"]!)
        let b = decoded(result.leafHashes["b"]!)
        let last = decoded(result.leafHashes["schema"]!)
        let pair = digest(Data([0x01]) + a + b)
        let unary = digest(Data([0x03]) + last)
        let top = digest(Data([0x01]) + pair + unary)
        XCTAssertEqual(result.root, hex(wrapped(top, count: 3)))
        let duplicated = digest(Data([0x01]) + last + last)
        let wrongTop = digest(Data([0x01]) + pair + duplicated)
        XCTAssertNotEqual(result.root, hex(wrapped(wrongTop, count: 3)))
        XCTAssertFalse(try MerkleGenesis.verify(leaves, expectedRoot: hex(wrapped(wrongTop, count: 3))))
    }

    func testRootWrapperBindsCount() throws {
        let result = try MerkleGenesis.commit([schema])
        let leaf = decoded(result.leafHashes["schema"]!)
        let wrongCount = hex(wrapped(leaf, count: 2))
        XCTAssertNotEqual(result.root, wrongCount)
        XCTAssertFalse(try MerkleGenesis.verify([schema], expectedRoot: wrongCount))
    }

    func testRecursiveReconstructionAtOddAndPowerOfTwoBoundaries() throws {
        for count in Array(1...17) + [31, 32, 33, 63, 64, 65, 127, 128] {
            let leaves = [schema] + (1..<count).map {
                GenesisLeaf(label: "item-\($0)", payload: Data([UInt8($0)]))
            }
            let result = try MerkleGenesis.commit(leaves)
            XCTAssertEqual(result.leafCount, count)
            XCTAssertEqual(result.leafHashes.count, count)
            XCTAssertTrue(try MerkleGenesis.verify(Array(leaves.reversed()), expectedRoot: result.root), "count=\(count)")
        }
    }

    func testDuplicateLabelsReject() {
        XCTAssertThrowsError(try MerkleGenesis.commit([schema, schema])) {
            XCTAssertEqual($0 as? GenesisFailure, .duplicateLabel)
        }
    }

    func testCanonicalStringKeyAliasesRejectWithoutNormalizingBytes() {
        let leaves = [schema, GenesisLeaf(label: "é", payload: Data([1])),
            GenesisLeaf(label: "e\u{301}", payload: Data([2]))]
        XCTAssertThrowsError(try MerkleGenesis.commit(leaves)) {
            XCTAssertEqual($0 as? GenesisFailure, .duplicateLabel)
        }
    }

    func testEmptySetRejects() {
        XCTAssertThrowsError(try MerkleGenesis.commit([])) {
            XCTAssertEqual($0 as? GenesisFailure, .emptySet)
        }
    }

    func testEmptyLabelRejects() {
        XCTAssertThrowsError(try MerkleGenesis.commit([schema, GenesisLeaf(label: "", payload: Data())])) {
            XCTAssertEqual($0 as? GenesisFailure, .emptyLabel)
        }
    }

    func testMissingSchemaRejectsInBothImplementations() {
        let leaves = [GenesisLeaf(label: "subject", payload: Data([1]))]
        XCTAssertThrowsError(try MerkleGenesis.commit(leaves)) {
            XCTAssertEqual($0 as? GenesisFailure, .missingSchema)
        }
        XCTAssertThrowsError(try MerkleGenesis.verify(leaves, expectedRoot: String(repeating: "0", count: 64)))
    }

    func testLeafCountLimitRejectsBeforeHashing() {
        let leaves = [schema] + (1...128).map { GenesisLeaf(label: "item-\($0)", payload: Data()) }
        XCTAssertThrowsError(try MerkleGenesis.commit(leaves)) {
            XCTAssertEqual($0 as? GenesisFailure, .tooManyLeaves)
        }
    }

    func testByteLimitIncludesLabelsAndAllowsExactBoundary() throws {
        let exact = GenesisLeaf(label: "schema",
            payload: Data(repeating: 0, count: MerkleGenesis.maximumBytes - 6))
        XCTAssertEqual(try MerkleGenesis.commit([exact]).leafCount, 1)
        let oversized = GenesisLeaf(label: "schema",
            payload: Data(repeating: 0, count: MerkleGenesis.maximumBytes - 5))
        XCTAssertThrowsError(try MerkleGenesis.commit([oversized])) {
            XCTAssertEqual($0 as? GenesisFailure, .tooManyBytes)
        }
        let largeLabel = GenesisLeaf(label: String(repeating: "x", count: MerkleGenesis.maximumBytes), payload: Data())
        XCTAssertThrowsError(try MerkleGenesis.commit([schema, largeLabel]))
    }

    func testExpectedRootRequiresCanonicalLowercaseHex() throws {
        let result = try MerkleGenesis.commit([schema])
        for bad in ["", result.root + "\n", String(result.root.dropLast()),
                    String(repeating: "g", count: 64), result.root.uppercased()] {
            XCTAssertFalse(try MerkleGenesis.verify([schema], expectedRoot: bad))
        }
    }
}
