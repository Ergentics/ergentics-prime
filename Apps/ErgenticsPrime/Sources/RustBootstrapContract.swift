import Foundation

// Pure identity and data contract for the separately built Rust bootstrap.
// Nothing here loads an image, touches host/guest memory, or grants authority.
enum RustBootstrapContract {
    static let profile = "rust-bootstrap.v1"
    static let schema = "ergentics.hypervisor.rust-bootstrap.snapshot.v1"
    static let expectedGuestSHA256 = "6e1b2a92646a69ef353491b2cde8104c6d6f311bc4d03bb8cb3bd5bb28f4dfa1"
    static let imageByteCount = 164
    static let loadAddress: UInt64 = 0x10000000
    static let doorbellOffset: UInt64 = 96
    static let doorbellPC: UInt64 = 0x10000060
    static let entrySP: UInt64 = 0x10014000
    static let exitSP: UInt64 = 0x10014000
    static let request = GuestContract.frame([1, 1, 19, 23])
    static let reply = GuestContract.frame([1, 1, 42, 0])
    static let memoryContract = GuestContract.frame([
        0x10000000, 16_384, 5,
        0x10004000, 16_384, 1,
        0x10008000, 16_384, 3,
        0x10010000, 16_384, 3,
        0x1000c000, 96, 0x10014000, 16
    ])
    // Actual copied frame: saved X29=0 and BL return address=0x10000030.
    // Equality of these sixteen bytes does not prove the rest of the stack
    // was unchanged; the separate native stack_valid predicate is required.
    static let stackFrame = GuestContract.frame([0, 0x10000030])

    static func snapshotLeaves(image: Data, request: Data, reply: Data,
                               memoryContract: Data, stackFrame: Data) -> [GenesisLeaf] {
        [GenesisLeaf(label: "guest_image", payload: image),
         GenesisLeaf(label: "memory_contract", payload: memoryContract),
         GenesisLeaf(label: "reply", payload: reply),
         GenesisLeaf(label: "request", payload: request),
         GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
         GenesisLeaf(label: "stack_frame", payload: stackFrame)]
    }

    static func validateSnapshot(image: Data, request: Data, reply: Data,
                                 memoryContract: Data, stackFrame: Data,
                                 expectedRoot: String) throws -> Bool {
        guard image.count == imageByteCount, GuestContract.hash(image) == expectedGuestSHA256,
              request == Self.request, reply == Self.reply,
              memoryContract == Self.memoryContract, stackFrame == Self.stackFrame else { return false }
        return try MerkleGenesis.verify(snapshotLeaves(image: image, request: request, reply: reply,
            memoryContract: memoryContract, stackFrame: stackFrame), expectedRoot: expectedRoot)
    }
}
