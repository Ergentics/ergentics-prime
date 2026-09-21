import Foundation
import GateEJSONAuthority

private enum ClosedJSONProjectorFailure: Error {
    case arguments
    case environment
    case empty
    case cap
}

@main
private struct ErgenticsGateEJSONProjectorMain {
    static func main() {
        do {
            guard CommandLine.arguments.count == 1 else {
                throw ClosedJSONProjectorFailure.arguments
            }
            guard ProcessInfo.processInfo.environment.isEmpty else {
                throw ClosedJSONProjectorFailure.environment
            }
            let candidate = try readExactEOF(descriptor: 0, cap: 4 * 1024 * 1024)
            let projection = try GateEJSONAuthority.projectAndVerify(
                candidate: candidate
            )
            let roundTrip = try GateEJSONReconstructor.reconstructAndReceipt(
                candidate: candidate,
                graphFrame: projection.graphFrame
            )
            try writeAll(projection.verifierReceipt, descriptor: 1)
            try writeAll(projection.graphFrame, descriptor: 3)
            try writeAll(roundTrip, descriptor: 4)
        } catch {
            exit(70)
        }
    }

    private static func readExactEOF(
        descriptor: Int32,
        cap: Int
    ) throws -> [UInt8] {
        let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: false)
        var bytes: [UInt8] = []
        while true {
            guard let chunk = try handle.read(upToCount: 65_536), !chunk.isEmpty
            else { break }
            guard bytes.count <= cap - chunk.count else {
                throw ClosedJSONProjectorFailure.cap
            }
            bytes.append(contentsOf: chunk)
        }
        guard !bytes.isEmpty else { throw ClosedJSONProjectorFailure.empty }
        return bytes
    }

    private static func writeAll(
        _ bytes: [UInt8],
        descriptor: Int32
    ) throws {
        guard !bytes.isEmpty else { throw ClosedJSONProjectorFailure.empty }
        let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: false)
        try handle.write(contentsOf: Data(bytes))
    }
}
