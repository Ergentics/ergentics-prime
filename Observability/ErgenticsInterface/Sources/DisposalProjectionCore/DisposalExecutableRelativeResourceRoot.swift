import Darwin
import Foundation
import MachO

struct DisposalExecutableRelativeResourceLocation: Equatable, Sendable {
    let closureParentPath: String
    let closureRootPath: String
    let closureRootLeaf: String
    let executablePath: String
    let executableLeaf: String
    let resourceRootPath: String
    let resourceRootLeaf: String
}

enum DisposalExecutableRelativeResourceRoot {
    static let executableLeaf = "ErgenticsR19OBS11ProjectionChain"
    static let resourceRootLeaf = "ErgenticsR19OBS11ProjectionChain.resources.v1"
    private static let closureParentPath = "/private/tmp"
    private static let closureRootLeaf =
        "ergentics-r19-obs11-chain-runner-296d32da-execution-closure-v1"

    static func resolveFrozen() throws -> DisposalExecutableRelativeResourceLocation {
        var requiredSize: UInt32 = 0
        let sizingResult = _NSGetExecutablePath(nil, &requiredSize)
        try disposalRequireProjection(
            sizingResult == -1 && requiredSize > 1 && requiredSize <= UInt32(PATH_MAX),
            "EXECUTABLE_RELATIVE_PATH_SIZE")

        var pathBytes = [CChar](repeating: 0, count: Int(requiredSize))
        let pathResult = pathBytes.withUnsafeMutableBufferPointer { buffer in
            _NSGetExecutablePath(buffer.baseAddress, &requiredSize)
        }
        try disposalRequireProjection(
            pathResult == 0 && requiredSize <= UInt32(pathBytes.count),
            "EXECUTABLE_RELATIVE_PATH_READ")
        guard let terminator = pathBytes.firstIndex(of: 0), terminator > 0,
              let observedPath = String(
                bytes: pathBytes[..<terminator].map { UInt8(bitPattern: $0) },
                encoding: .utf8)
        else {
            throw DisposalProjectionRejection(code: "EXECUTABLE_RELATIVE_PATH_UTF8")
        }

        var canonicalBytes = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(observedPath, &canonicalBytes) != nil,
              let canonicalTerminator = canonicalBytes.firstIndex(of: 0),
              canonicalTerminator > 0,
              let canonicalPath = String(
                bytes: canonicalBytes[..<canonicalTerminator].map {
                    UInt8(bitPattern: $0)
                },
                encoding: .utf8)
        else {
            throw DisposalProjectionRejection(
                code: "EXECUTABLE_RELATIVE_REALPATH",
                detail: String(cString: strerror(errno)))
        }

        let executableURL = URL(fileURLWithPath: canonicalPath)
        let closureRootPath = executableURL.deletingLastPathComponent().path
        let closureRootURL = URL(fileURLWithPath: closureRootPath)
        let observedExecutableLeaf = executableURL.lastPathComponent
        let observedClosureRootLeaf = closureRootURL.lastPathComponent
        let expectedClosureRootPath = closureParentPath + "/" + closureRootLeaf
        try disposalRequireProjection(
            observedExecutableLeaf == executableLeaf &&
                observedClosureRootLeaf == closureRootLeaf &&
                closureRootPath == expectedClosureRootPath &&
                closureRootURL.deletingLastPathComponent().path == closureParentPath &&
                !observedClosureRootLeaf.isEmpty && observedClosureRootLeaf != "." &&
                observedClosureRootLeaf != ".." &&
                !observedClosureRootLeaf.contains("/") &&
                closureRootPath + "/" + executableLeaf == canonicalPath,
            "EXECUTABLE_RELATIVE_CLOSURE_SHAPE")
        let resourceRootPath = closureRootPath + "/" + resourceRootLeaf
        return .init(
            closureParentPath: closureParentPath,
            closureRootPath: closureRootPath,
            closureRootLeaf: observedClosureRootLeaf,
            executablePath: canonicalPath,
            executableLeaf: executableLeaf,
            resourceRootPath: resourceRootPath,
            resourceRootLeaf: resourceRootLeaf)
    }
}
