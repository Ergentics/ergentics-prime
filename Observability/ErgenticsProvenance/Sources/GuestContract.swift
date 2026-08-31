import CryptoKit
import Foundation

enum GuestContract {
    static let schema = "ergentics.hypervisor.guest.snapshot.v1"
    // Independently extracted from assembled __TEXT,__text and byte-compared
    // with HypervisorGuest.c. The Mach-O container is never loaded as a guest.
    static let expectedGuestSHA256 = "67290a73b53047374096142356a35338f6722d724586cc10373dfecab9a4cc44"
    static let request = frame([1, 1, 19, 23])
    static let reply = frame([1, 1, 42, 0])

    static func frame(_ words: [UInt64]) -> Data {
        var result = Data()
        for var word in words.map(\.littleEndian) {
            withUnsafeBytes(of: &word) { result.append(contentsOf: $0) }
        }
        return result
    }

    static func hash(_ bytes: Data) -> String {
        SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }

    static func snapshotLeaves(image: Data, request: Data, reply: Data) -> [GenesisLeaf] {
        [GenesisLeaf(label: "guest_image", payload: image),
         GenesisLeaf(label: "reply", payload: reply),
         GenesisLeaf(label: "request", payload: request),
         GenesisLeaf(label: "schema", payload: Data(schema.utf8))]
    }

    static func validateSnapshot(image: Data, request: Data, reply: Data, expectedRoot: String) throws -> Bool {
        guard hash(image) == expectedGuestSHA256,
              request == Self.request, reply == Self.reply else { return false }
        return try MerkleGenesis.verify(snapshotLeaves(image: image, request: request, reply: reply),
                                        expectedRoot: expectedRoot)
    }
}
