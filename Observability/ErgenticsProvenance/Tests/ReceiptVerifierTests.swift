import Foundation
import XCTest

final class ReceiptVerifierTests: XCTestCase {
    private let bytes = Data("retained test bytes".utf8)
    private var entry: ReceiptEntry {
        ReceiptEntry(name: "receipt.json", bytes: bytes.count, sha256: ReceiptVerifier.hash(bytes))
    }
    func testKnownSHA256() {
        XCTAssertEqual(ReceiptVerifier.hash(Data("abc".utf8)), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
    }
    func testManifestAcceptsExactBytes() throws {
        try ReceiptVerifier.validateManifest([entry], leaves: [entry.name: bytes])
    }
    func testManifestRejectsChangedBytes() {
        XCTAssertThrowsError(try ReceiptVerifier.validateManifest([entry], leaves: [entry.name: Data("different".utf8)]))
    }
    func testManifestRejectsWrongSize() {
        let bad = ReceiptEntry(name: entry.name, bytes: bytes.count + 1, sha256: entry.sha256)
        XCTAssertThrowsError(try ReceiptVerifier.validateManifest([bad], leaves: [entry.name: bytes]))
    }
    func testManifestRejectsDuplicate() {
        XCTAssertThrowsError(try ReceiptVerifier.validateManifest([entry, entry], leaves: [entry.name: bytes]))
    }
    func testManifestRejectsMissingAndExtraLeaves() {
        XCTAssertThrowsError(try ReceiptVerifier.validateManifest([entry], leaves: [:]))
        XCTAssertThrowsError(try ReceiptVerifier.validateManifest([entry], leaves: [entry.name: bytes, "extra": bytes]))
    }
    func testManifestRejectsPathTraversal() {
        for name in ["../receipt", ".", "..", "a/b", "a\0b", ""] {
            let bad = ReceiptEntry(name: name, bytes: bytes.count, sha256: entry.sha256)
            XCTAssertThrowsError(try ReceiptVerifier.validateManifest([bad], leaves: [name: bytes]))
        }
    }
    func testManifestRejectsOversizedLeaf() {
        let large = Data(repeating: 1, count: 65_537)
        let bad = ReceiptEntry(name: entry.name, bytes: large.count, sha256: ReceiptVerifier.hash(large))
        XCTAssertThrowsError(try ReceiptVerifier.validateManifest([bad], leaves: [entry.name: large]))
    }
    func testProductionEntryRejectsMissingHistory() {
        XCTAssertThrowsError(try ReceiptVerifier.verify([:]))
    }
    func testProductionEntryRejectsInventedTerminalEvenWithExactNames() {
        let fake = Dictionary(uniqueKeysWithValues: ReceiptVerifier.names.map { ($0, Data("{}".utf8)) })
        XCTAssertThrowsError(try ReceiptVerifier.verify(fake))
    }
    func testExactHistoricalRationalInterval() throws {
        XCTAssertEqual(try ReceiptVerifier.rationalInterval(start: 60_699_290_589_400, end: 60_699_290_862_862,
            numerator: 125, denominator: 3), "34182750 / 3 ns")
    }
    func testThirdNanosecondRemainsRational() throws {
        XCTAssertEqual(try ReceiptVerifier.rationalInterval(start: 0, end: 1, numerator: 125, denominator: 3), "125 / 3 ns")
    }
    func testInvalidAndOverflowingClockRejects() {
        XCTAssertThrowsError(try ReceiptVerifier.rationalInterval(start: 2, end: 1, numerator: 125, denominator: 3))
        XCTAssertThrowsError(try ReceiptVerifier.rationalInterval(start: 0, end: 1, numerator: 125, denominator: 0))
        XCTAssertThrowsError(try ReceiptVerifier.rationalInterval(start: 0, end: 1, numerator: 0, denominator: 3))
        XCTAssertThrowsError(try ReceiptVerifier.rationalInterval(start: 0, end: UInt64.max, numerator: 125, denominator: 3))
    }
}
