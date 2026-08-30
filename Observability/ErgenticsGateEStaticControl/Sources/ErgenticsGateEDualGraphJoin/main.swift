import Foundation
import GateEDualGraphJoin

private enum ClosedJoinFailure: Error {
    case arguments
    case environment
    case empty
    case cap
}

@main
private struct ErgenticsGateEDualGraphJoinMain {
    static func main() {
        do {
            guard CommandLine.arguments.count == 1 else {
                throw ClosedJoinFailure.arguments
            }
            guard ProcessInfo.processInfo.environment.isEmpty else {
                throw ClosedJoinFailure.environment
            }
            let jsonGraph = try readExactEOF(descriptor: 0, cap: 16 * 1024 * 1024)
            let jsonVerifier = try readExactEOF(descriptor: 3, cap: 262_144)
            let jsonRoundTrip = try readExactEOF(descriptor: 4, cap: 262_144)
            let cborGraph = try readExactEOF(descriptor: 5, cap: 16 * 1024 * 1024)
            let cborVerifier = try readExactEOF(descriptor: 6, cap: 262_144)
            let cborRoundTrip = try readExactEOF(descriptor: 7, cap: 262_144)
            let result = try GateEDualGraphJoin.join(
                jsonGraph: jsonGraph,
                jsonVerifier: jsonVerifier,
                jsonRoundTrip: jsonRoundTrip,
                cborGraph: cborGraph,
                cborVerifier: cborVerifier,
                cborRoundTrip: cborRoundTrip
            )
            try writeAll(result.joinReceipt, descriptor: 1)
            try writeAll(result.authoritativeGraph, descriptor: 8)
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
            guard bytes.count <= cap - chunk.count else { throw ClosedJoinFailure.cap }
            bytes.append(contentsOf: chunk)
        }
        guard !bytes.isEmpty else { throw ClosedJoinFailure.empty }
        return bytes
    }

    private static func writeAll(
        _ bytes: [UInt8],
        descriptor: Int32
    ) throws {
        guard !bytes.isEmpty else { throw ClosedJoinFailure.empty }
        let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: false)
        try handle.write(contentsOf: Data(bytes))
    }
}
