import CryptoKit
import Foundation
import XCTest

// Pure fixture/encoding checks only. This suite never opens a journal, touches
// the filesystem, invokes a native accessor, creates a VM or enters a guest.
final class HypervisorContractTests: XCTestCase {
    private let request = Data([
        1, 0, 0, 0, 0, 0, 0, 0,
        1, 0, 0, 0, 0, 0, 0, 0,
        19, 0, 0, 0, 0, 0, 0, 0,
        23, 0, 0, 0, 0, 0, 0, 0
    ])
    private let reply = Data([
        1, 0, 0, 0, 0, 0, 0, 0,
        1, 0, 0, 0, 0, 0, 0, 0,
        42, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
    ])
    private let snapshotSchema = Data("ergentics.hypervisor.guest.snapshot.v1".utf8)

    // Independent test copy of the reviewed 23-instruction image. The emitted
    // guest's build/disassembly comparison remains a separate build check.
    private var reviewedImage: Data {
        let instructions: [UInt32] = [
            0xd2880000, 0xf2a20000, 0xd2900001, 0xf2a20001,
            0xd2980003, 0xf2a20003, 0xc8dffc04, 0xf100049f,
            0x540001c1, 0xf9400405, 0xf10004bf, 0x54000161,
            0xf9400806, 0xf9400c07, 0x8b0700c6, 0xf9000425,
            0xf9000826, 0xf9000c3f, 0xc89ffc24, 0xd5033f9f,
            0xb9000064, 0xd43bd5a0, 0xd42175a0
        ]
        var bytes = Data()
        for var instruction in instructions.map(\.littleEndian) {
            withUnsafeBytes(of: &instruction) { bytes.append(contentsOf: $0) }
        }
        return bytes
    }

    private func word(_ bytes: Data, at offset: Int) -> UInt64 {
        var value: UInt64 = 0
        for index in 0..<8 { value |= UInt64(bytes[offset + index]) << (index * 8) }
        return value
    }

    func testFixedArithmeticFramesAreFourLittleEndianWords() {
        XCTAssertEqual(request.count, 32)
        XCTAssertEqual(reply.count, 32)
        XCTAssertEqual(stride(from: 0, to: 32, by: 8).map { word(request, at: $0) }, [1, 1, 19, 23])
        XCTAssertEqual(stride(from: 0, to: 32, by: 8).map { word(reply, at: $0) }, [1, 1, 42, 0])
        let addition = word(request, at: 16).addingReportingOverflow(word(request, at: 24))
        XCTAssertFalse(addition.overflow)
        XCTAssertEqual(addition.partialValue, word(reply, at: 16))
    }

    func testProductionContractMatchesIndependentFramesAndSchema() {
        XCTAssertEqual(GuestContract.request, request)
        XCTAssertEqual(GuestContract.reply, reply)
        XCTAssertEqual(Data(GuestContract.schema.utf8), snapshotSchema)
        XCTAssertEqual(GuestContract.frame([1, 1, 19, 23]), request)
        XCTAssertEqual(GuestContract.frame([1, 1, 42, 0]), reply)
    }

    func testReviewedImagePinAndDoorbellInstructionAreSealed() {
        XCTAssertEqual(reviewedImage.count, 92)
        XCTAssertEqual(Data(reviewedImage[80..<84]), Data([0x64, 0x00, 0x00, 0xb9]))
        let expected = SHA256.hash(data: reviewedImage).map { String(format: "%02x", $0) }.joined()
        XCTAssertEqual(GuestContract.expectedGuestSHA256, expected)
        XCTAssertEqual(GuestContract.hash(reviewedImage), expected)
        XCTAssertEqual(GuestContract.expectedGuestSHA256.utf8.count, 64)
    }

    func testProductionSnapshotAcceptsOnlyExactFixedInputs() throws {
        let leaves = GuestContract.snapshotLeaves(image: reviewedImage, request: request, reply: reply)
        let commitment = try MerkleGenesis.commit(leaves)
        XCTAssertEqual(leaves.map(\.label), ["guest_image", "reply", "request", "schema"])
        XCTAssertEqual(leaves.map(\.payload), [reviewedImage, reply, request, snapshotSchema])
        XCTAssertTrue(try GuestContract.validateSnapshot(image: reviewedImage, request: request,
            reply: reply, expectedRoot: commitment.root))
    }

    func testProductionSnapshotRejectsChangedImageEvenWithMatchingNewRoot() throws {
        var changed = reviewedImage
        changed[0] ^= 1
        let commitment = try MerkleGenesis.commit(
            GuestContract.snapshotLeaves(image: changed, request: request, reply: reply))
        XCTAssertFalse(try GuestContract.validateSnapshot(image: changed, request: request,
            reply: reply, expectedRoot: commitment.root))
    }

    func testProductionSnapshotRejectsChangedOrWrongLengthFramesWithFreshRoots() throws {
        var changedRequest = request
        changedRequest[16] = 20
        var changedReply = reply
        changedReply[16] = 43
        let pairs: [(Data, Data)] = [
            (changedRequest, reply), (request, changedReply),
            (Data(request.dropLast()), reply), (request + Data([0]), reply),
            (request, Data(reply.dropLast())), (request, reply + Data([0]))
        ]
        for (candidateRequest, candidateReply) in pairs {
            let commitment = try MerkleGenesis.commit(GuestContract.snapshotLeaves(image: reviewedImage,
                request: candidateRequest, reply: candidateReply))
            XCTAssertFalse(try GuestContract.validateSnapshot(image: reviewedImage,
                request: candidateRequest, reply: candidateReply, expectedRoot: commitment.root))
        }
    }

    func testProductionSnapshotRejectsWrongAndNoncanonicalRoots() throws {
        let commitment = try MerkleGenesis.commit(
            GuestContract.snapshotLeaves(image: reviewedImage, request: request, reply: reply))
        for root in ["", commitment.root.uppercased(), commitment.root + "\n", String(repeating: "0", count: 64)] {
            XCTAssertFalse(try GuestContract.validateSnapshot(image: reviewedImage,
                request: request, reply: reply, expectedRoot: root))
        }
    }

    func testNativeSignedStatusDecimalRoundTripsWithoutClamping() throws {
        let statuses: [Int32] = [Int32.min, -1, 0, 1, Int32.max]
        for status in statuses {
            let encoded = try GuestCBOR.encode(.text(String(status)))
            guard case .text(let recovered) = try GuestCBOR.decode(encoded) else {
                return XCTFail("Status did not remain a CBOR text value")
            }
            XCTAssertEqual(Int32(recovered), status)
            XCTAssertEqual(recovered, String(status))
        }
    }

    func testNotEnteredSentinelIsNotSuccessOrOmission() throws {
        let sentinel = GuestCBORValue.text(String(Int32.min))
        XCTAssertEqual(try GuestCBOR.encode(sentinel), Data([0x6b]) + Data("-2147483648".utf8))
        XCTAssertEqual(try GuestCBOR.encode(.text("-1")), Data([0x62, 0x2d, 0x31]))
        XCTAssertNotEqual(sentinel, .text("0"))
        XCTAssertNotEqual(try GuestCBOR.encode(sentinel), try GuestCBOR.encode(.text("0")))
    }

    func testRawHardwareTicksRetainFullUInt64Precision() throws {
        let fields = GuestCBORValue.map([
            "ticks": .unsigned(UInt64.max),
            "numerator": .unsigned(125),
            "denominator": .unsigned(3)
        ])
        XCTAssertEqual(try GuestCBOR.decode(GuestCBOR.encode(fields)), fields)
        XCTAssertEqual(try GuestCBOR.encode(.unsigned(UInt64.max)),
            Data([0x1b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))
    }

    func testObservationCBORPreservesExactSnapshotBytesAndAncestry() throws {
        // Synthetic bytes exercise representation only, not guest admission.
        let image = Data([0xa1, 0xb2, 0xc3, 0xd4])
        let parent = Data(repeating: 0x71, count: 32)
        let event = GuestCBORValue.map([
            "schema": .text("ergentics.guest-journal.event.v1"),
            "run_id": .text("00000000-0000-0000-0000-000000000001"),
            "sequence": .unsigned(1),
            "parent": .bytes(parent),
            "kind": .text("observation"),
            "payload": .map([
                "guest_image": .bytes(image),
                "request": .bytes(request),
                "reply": .bytes(reply),
                "snapshot_schema": .bytes(snapshotSchema),
                "native_status_decimal": .map([
                    "run": .text("0"), "cancellation": .text("-2147483648")
                ])
            ])
        ])
        let encoded = try GuestCBOR.encode(event)
        XCTAssertEqual(try GuestCBOR.decode(encoded), event)
        XCTAssertEqual(try GuestCBOR.encode(GuestCBOR.decode(encoded)), encoded)
        XCTAssertThrowsError(try GuestCBOR.decode(encoded + Data([0x00])))
        XCTAssertThrowsError(try GuestCBOR.decode(Data(encoded.dropLast())))
    }

    func testSnapshotCommitmentBindsAllFourLabeledPayloads() throws {
        let leaves = [
            GenesisLeaf(label: "guest_image", payload: Data([0xa1, 0xb2, 0xc3, 0xd4])),
            GenesisLeaf(label: "reply", payload: reply),
            GenesisLeaf(label: "request", payload: request),
            GenesisLeaf(label: "schema", payload: snapshotSchema)
        ]
        let result = try MerkleGenesis.commit(leaves)
        XCTAssertEqual(result.leafCount, 4)
        XCTAssertEqual(Set(result.leafHashes.keys), Set(["guest_image", "reply", "request", "schema"]))
        XCTAssertTrue(try MerkleGenesis.verify(Array(leaves.reversed()), expectedRoot: result.root))
        for index in leaves.indices {
            var changed = leaves
            changed[index] = GenesisLeaf(label: leaves[index].label,
                payload: leaves[index].payload + Data([0]))
            XCTAssertFalse(try MerkleGenesis.verify(changed, expectedRoot: result.root), leaves[index].label)
        }
    }

    func testFourLeafRootMatchesIndependentLiteralLengthFraming() throws {
        let entries: [(String, Data)] = [
            ("guest_image", Data([0xa1, 0xb2, 0xc3, 0xd4])),
            ("reply", reply), ("request", request), ("schema", snapshotSchema)
        ]
        func hash(_ bytes: Data) -> Data { Data(SHA256.hash(data: bytes)) }
        let leafHashes = entries.map { label, payload -> Data in
            let labelBytes = Data(label.utf8)
            // Every fixture length is below 256; fixed literal zero prefixes
            // independently bind the 32-bit label and 64-bit payload lengths.
            var frame = Data([0, 0, 0, 0, UInt8(labelBytes.count)])
            frame.append(labelBytes)
            frame.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, UInt8(payload.count)])
            frame.append(payload)
            return hash(frame)
        }
        let left = hash(Data([1]) + leafHashes[0] + leafHashes[1])
        let right = hash(Data([1]) + leafHashes[2] + leafHashes[3])
        let top = hash(Data([1]) + left + right)
        let rootFrame = Data([2, 0, 0, 0, 0, 0, 0, 0, 4]) + top
        let expected = hash(rootFrame).map { String(format: "%02x", $0) }.joined()
        let leaves = entries.map { GenesisLeaf(label: $0.0, payload: $0.1) }
        XCTAssertEqual(try MerkleGenesis.commit(leaves).root, expected)
        XCTAssertTrue(try MerkleGenesis.verify(leaves, expectedRoot: expected))
    }

    func testExecutionAndTeardownRemainSeparateCBORPredicates() throws {
        let failedTeardown = GuestCBORValue.map([
            "execution_pass": .bool(true),
            "teardown_pass": .bool(false),
            "resources_quarantined": .bool(true),
            "native_status_decimal": .map(["run": .text("0"), "vcpu_destroy": .text("-1")])
        ])
        XCTAssertEqual(try GuestCBOR.decode(GuestCBOR.encode(failedTeardown)), failedTeardown)
        let success = GuestCBORValue.map([
            "execution_pass": .bool(true),
            "teardown_pass": .bool(true),
            "resources_quarantined": .bool(false),
            "native_status_decimal": .map(["run": .text("0"), "vcpu_destroy": .text("0")])
        ])
        XCTAssertNotEqual(try GuestCBOR.encode(failedTeardown), try GuestCBOR.encode(success))
    }
}
