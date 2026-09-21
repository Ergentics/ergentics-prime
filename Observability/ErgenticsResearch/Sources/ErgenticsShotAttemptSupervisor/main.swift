import CryptoKit
import Darwin
import ErgenticsShotAttemptSupervisorSupport

private let ownerExitIncomplete: Int32 = 70
private let ownerExitUsage: Int32 = 64

private let oCloseOnExec = Int32(0x0100_0000)
private let oDirectory = Int32(0x0010_0000)
private let oNoFollowAny = Int32(0x2000_0000)
private let atFDCWD = Int32(-2)
private let atSymlinkNoFollow = Int32(0x0020)
private let atSymlinkNoFollowAny = Int32(0x0800)
private let fFullFSync = Int32(51)
private let procPIDTBSDInfo = Int32(3)
private let procPIDRegionPathInfo = Int32(8)
private let procBSDInfoBytes = 136
private let procRegionPathInfoBytes = 1_272
private let procPIDPathInfoMaximum = 4_096
private let vmProtectionExecute = UInt32(0x4)
private let posixSpawnCloseOnExecDefault = Int16(0x4000)
private let rawRetainedByteCap = 65_536
private let captureLeafByteCap = 262_144
private let executableByteCap = 64 * 1_024 * 1_024
private let ordinaryLeafByteCap = 262_144

@_silgen_name("proc_pidinfo")
private func ownerProcPIDInfo(
    _ pid: Int32,
    _ flavor: Int32,
    _ argument: UInt64,
    _ buffer: UnsafeMutableRawPointer?,
    _ bufferSize: Int32
) -> Int32

@_silgen_name("proc_pidpath")
private func ownerProcPIDPath(
    _ pid: Int32,
    _ buffer: UnsafeMutableRawPointer?,
    _ bufferSize: UInt32
) -> Int32

@_silgen_name("_dyld_get_image_name")
private func ownerDyldGetImageName(_ index: UInt32) -> UnsafePointer<CChar>?

@_silgen_name("_dyld_get_image_header")
private func ownerDyldGetImageHeader(_ index: UInt32) -> UnsafeRawPointer?

private enum OwnerPaths {
    static let repository =
        "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" +
        ".phase-a-v2-fixture-identity-restore-only-staging"
    static let artifactParent = repository +
        "/artifacts/r19-obs11-retained-r19-projection-chain-2026-08-26"
    static let controlFreeze = artifactParent +
        "/r19-obs11-c2-attempt-supervisor-control-freeze.v10.json"
    static let runnerSource = repository +
        "/docs/tools/ergentics-r19-obs11-c2-prefix-capture-runner.v9.rb"
    static let runtimeReadiness = artifactParent +
        "/r19-obs11-c2-prefix-harness-readiness.v9.frame"
    static let buildReadiness = artifactParent +
        "/r19-obs11-c2-attempt-supervisor-build-readiness.v10.json"
    static let buildResult = artifactParent +
        "/r19-obs11-c2-attempt-supervisor-build-result.v10.json"
    static let hypothesisRegistration = artifactParent +
        "/r19-obs11-c2-d3-hypothesis-registration.v1.json"
    static let hypothesisReport = artifactParent +
        "/r19-obs11-c2-d3-hypothesis-report.v1.json"
    static let ownerRoot = AttemptReadinessFrame.ownerRootAbsolutePath
    static let ownerRootLeaf = "r19-obs11-c2-attempt-owner.v10"
    static let rawCombined = AttemptReadinessFrame.rawCombinedAbsolutePath
    static let rawCombinedLeaf = "r19-obs11-c2-runner-outer-combined.v9.bin"
    static let captureRoot = AttemptReadinessFrame.captureRootAbsolutePath
    static let captureRootLeaf = "r19-obs11-c2-preconsumption-prefix-capture.v9"
    static let canonicalResultLeaf = "r19-obs11-c2-runner-result.v9.json"
    static let runnerOuterObservationLeaf =
        "r19-obs11-c2-runner-outer-observation.v9.json"
    static let supervisorOuterCombinedLeaf =
        "r19-obs11-c2-attempt-supervisor-outer-combined.v10.bin"
    static let supervisorOuterObservationLeaf =
        "r19-obs11-c2-attempt-supervisor-outer-observation.v10.json"
    static let resultObservationLeaf = "r19-obs11-c2-d3-result-observation.v1.json"
    static let resultDeltaLeaf = "r19-obs11-c2-d3-result-delta.v1.json"
    static let comparatorOuterCombinedLeaf =
        "r19-obs11-c2-d3-result-comparator-outer-combined.v1.bin"
    static let comparatorOuterObservationLeaf =
        "r19-obs11-c2-d3-result-comparator-outer-observation.v1.json"
    static let ruby = "/usr/bin/ruby"
    static let null = "/dev/null"
    static let cwd = "/private/var/empty"
    static let buildAParent = "/private/tmp"
    static let buildARootLeaf =
        "ergentics-r19-obs11-c2-fchmod-bundle-v9-build-a-79e4211-00e9242e"
    static let buildARoot = buildAParent + "/" + buildARootLeaf
    static let buildAObjectLeaf = "ergentics-r19-obs11-c2-fchmod-v7.o"
    static let buildABundleLeaf = "libergentics-r19-obs11-c2-fchmod-v7.bundle"
    static let buildAObject = buildARoot + "/" + buildAObjectLeaf
    static let buildABundle = buildARoot + "/" + buildABundleLeaf
}

private enum OwnerIdentity {
    static let controlFreezeSHA256 =
        "c96b4b746ce6fe1069dc9044a1734f5f6f7c7e620cb26dd9c7500a220a09990c"
    static let runnerSourceSHA256 =
        "ef865cca24d43e8d354a6cd247b17c1573c87b8a80496e91590551f5bf94e0d8"
    static let rubySHA256 =
        "9d6ff3e289c7d908e3c785e0bedd6692d1d6a3377965c88c04d847104b7c892c"
    static let rubyUUID = "EB2540B7-E132-36BE-B719-619D0FBF7203"
    static let rubyMappedFileOffset: UInt64 = 65_536
    static let rubyDevice: Int64 = 16_777_231
    static let rubyInode: UInt64 = 1_152_921_500_312_572_705
    static let buildABundleSHA256 =
        "09b8f7d5cb6104e13e2cbc0d3731e81031287f1d6e3436c14e0ef3937d5a0c71"
    static let buildABundleUUID = "0371C336-3A6F-338E-9CD4-9349603C9F44"
    static let buildAObjectSHA256 =
        "20502bf5d7958d9367712a01ba30c305840d65574d5bdd9f0c12d70a6d37a728"
    static let artifactParentDevice: Int64 = 16_777_231
    static let artifactParentInode: UInt64 = 17_940_458
    static let buildAParentDevice: Int64 = 16_777_231
    static let buildAParentInode: UInt64 = 774_813
    static let buildARootInode: UInt64 = 18_009_932
    static let buildAObjectInode: UInt64 = 18_009_934
    static let buildABundleInode: UInt64 = 18_009_935
    static let buildAObjectBytes: Int64 = 728
    static let buildABundleBytes: Int64 = 33_496
}

private struct OwnerFailure: Error {
    let code: String
    let errnoValue: Int32?

    init(_ code: String, errnoValue: Int32? = nil) {
        self.code = code
        self.errnoValue = errnoValue
    }
}

private func ownerRequire(_ predicate: Bool, _ code: String) throws {
    guard predicate else { throw OwnerFailure(code) }
}

private func unsignedDecimal(_ value: String) -> UInt64? {
    let bytes = Array(value.utf8)
    guard !bytes.isEmpty, bytes.count == 1 || bytes[0] != 0x30 else { return nil }
    var result: UInt64 = 0
    for byte in bytes {
        guard (0x30...0x39).contains(byte) else { return nil }
        let product = result.multipliedReportingOverflow(by: 10)
        guard !product.overflow else { return nil }
        let sum = product.partialValue.addingReportingOverflow(UInt64(byte - 0x30))
        guard !sum.overflow else { return nil }
        result = sum.partialValue
    }
    return result
}

private func octalMode(_ value: UInt16) -> String {
    let text = String(value & 0o7777, radix: 8)
    if text.count >= 4 { return text }
    return String(repeating: "0", count: 4 - text.count) + text
}

private func paddedDecimal(_ value: Int32, width: Int) -> String {
    let text = String(value)
    if text.count >= width { return text }
    return String(repeating: "0", count: width - text.count) + text
}

private func containsBytes(_ haystack: [UInt8], _ needle: [UInt8]) -> Bool {
    guard !needle.isEmpty, needle.count <= haystack.count else { return false }
    if needle.count == haystack.count { return haystack == needle }
    for start in 0...(haystack.count - needle.count) {
        var equal = true
        for offset in needle.indices where haystack[start + offset] != needle[offset] {
            equal = false
            break
        }
        if equal { return true }
    }
    return false
}

private indirect enum OwnerJSON {
    case array([OwnerJSON])
    case bool(Bool)
    case int(Int64)
    case null
    case object([(String, OwnerJSON)])
    case string(String)
    case uint(UInt64)

    func encoded() throws -> [UInt8] {
        switch self {
        case .array(let values):
            var bytes: [UInt8] = [0x5b]
            for index in values.indices {
                if index != values.startIndex { bytes.append(0x2c) }
                bytes.append(contentsOf: try values[index].encoded())
            }
            bytes.append(0x5d)
            return bytes
        case .bool(let value):
            return Array((value ? "true" : "false").utf8)
        case .int(let value):
            return Array(String(value).utf8)
        case .null:
            return Array("null".utf8)
        case .object(let entries):
            var seen = Set<String>()
            for entry in entries {
                guard seen.insert(entry.0).inserted else {
                    throw OwnerFailure("JSON_DUPLICATE_KEY")
                }
            }
            let ordered = entries.sorted {
                Array($0.0.utf8).lexicographicallyPrecedes(Array($1.0.utf8))
            }
            var bytes: [UInt8] = [0x7b]
            for index in ordered.indices {
                if index != ordered.startIndex { bytes.append(0x2c) }
                bytes.append(contentsOf: Self.quoted(ordered[index].0))
                bytes.append(0x3a)
                bytes.append(contentsOf: try ordered[index].1.encoded())
            }
            bytes.append(0x7d)
            return bytes
        case .string(let value):
            return Self.quoted(value)
        case .uint(let value):
            return Array(String(value).utf8)
        }
    }

    private static func quoted(_ value: String) -> [UInt8] {
        let hexadecimal = Array("0123456789abcdef".utf8)
        var result: [UInt8] = [0x22]
        for byte in value.utf8 {
            switch byte {
            case 0x22:
                result.append(contentsOf: [0x5c, 0x22])
            case 0x5c:
                result.append(contentsOf: [0x5c, 0x5c])
            case 0x08:
                result.append(contentsOf: [0x5c, 0x62])
            case 0x09:
                result.append(contentsOf: [0x5c, 0x74])
            case 0x0a:
                result.append(contentsOf: [0x5c, 0x6e])
            case 0x0c:
                result.append(contentsOf: [0x5c, 0x66])
            case 0x0d:
                result.append(contentsOf: [0x5c, 0x72])
            case 0x00...0x1f:
                result.append(contentsOf: [
                    0x5c, 0x75, 0x30, 0x30,
                    hexadecimal[Int(byte >> 4)], hexadecimal[Int(byte & 0x0f)],
                ])
            default:
                result.append(byte)
            }
        }
        result.append(0x22)
        return result
    }
}

private struct VNodeIdentity: Equatable {
    let bytes: Int64
    let changeNanoseconds: Int64
    let changeSeconds: Int64
    let device: Int64
    let flags: UInt32
    let gid: UInt32
    let inode: UInt64
    let mode: UInt16
    let nlink: UInt16
    let type: String
    let uid: UInt32

    init(_ value: Darwin.stat) {
        bytes = Int64(value.st_size)
        changeNanoseconds = Int64(value.st_ctimespec.tv_nsec)
        changeSeconds = Int64(value.st_ctimespec.tv_sec)
        device = Int64(value.st_dev)
        flags = UInt32(value.st_flags)
        gid = UInt32(value.st_gid)
        inode = UInt64(value.st_ino)
        mode = UInt16(value.st_mode)
        nlink = UInt16(value.st_nlink)
        uid = UInt32(value.st_uid)
        switch mode & UInt16(S_IFMT) {
        case UInt16(S_IFDIR): type = "DIRECTORY"
        case UInt16(S_IFREG): type = "REGULAR"
        case UInt16(S_IFIFO): type = "FIFO"
        case UInt16(S_IFCHR): type = "CHARACTER"
        default: type = "OTHER"
        }
    }

    var permissionMode: UInt16 { mode & 0o7777 }

    var json: OwnerJSON {
        .object([
            ("bytes", .int(bytes)),
            ("device", .int(device)),
            ("flags", .uint(UInt64(flags))),
            ("gid", .uint(UInt64(gid))),
            ("inode", .uint(inode)),
            ("mode", .string(octalMode(permissionMode))),
            ("nlink", .uint(UInt64(nlink))),
            ("type", .string(type)),
            ("uid", .uint(UInt64(uid))),
        ])
    }

    var mutationStampJSON: OwnerJSON {
        .object([
            ("change_nanoseconds", .int(changeNanoseconds)),
            ("change_seconds", .int(changeSeconds)),
            ("device", .int(device)),
            ("inode", .uint(inode)),
        ])
    }
}

private struct HeldBytes {
    let bytes: [UInt8]
    let before: VNodeIdentity
    let after: VNodeIdentity
    let sha256: String
}

private func countedIncrement(_ value: inout UInt64, _ code: String) throws {
    let next = value.addingReportingOverflow(1)
    guard !next.overflow else { throw OwnerFailure(code) }
    value = next.partialValue
}

private final class IOAccounting {
    var fsyncCallEntries: UInt64 = 0
    var fsyncEINTRContinuations: UInt64 = 0
    var fullFSyncCallEntries: UInt64 = 0
    var fullFSyncEINTRContinuations: UInt64 = 0
    var pwriteCallEntries: UInt64 = 0
    var pwriteEINTRContinuations: UInt64 = 0
    var pwritePartialContinuations: UInt64 = 0
    var readCallEntries: UInt64 = 0
    var readEINTRContinuations: UInt64 = 0
    var readPartialContinuations: UInt64 = 0
    var writeCallEntries: UInt64 = 0
    var writeEINTRContinuations: UInt64 = 0
    var writePartialContinuations: UInt64 = 0

    var json: OwnerJSON {
        .object([
            ("fsync_call_entries", .uint(fsyncCallEntries)),
            ("fsync_eintr_continuations", .uint(fsyncEINTRContinuations)),
            ("full_fsync_call_entries", .uint(fullFSyncCallEntries)),
            ("full_fsync_eintr_continuations", .uint(fullFSyncEINTRContinuations)),
            ("pwrite_call_entries", .uint(pwriteCallEntries)),
            ("pwrite_eintr_continuations", .uint(pwriteEINTRContinuations)),
            ("pwrite_partial_continuations", .uint(pwritePartialContinuations)),
            ("read_call_entries", .uint(readCallEntries)),
            ("read_eintr_continuations", .uint(readEINTRContinuations)),
            ("read_partial_continuations", .uint(readPartialContinuations)),
            ("write_call_entries", .uint(writeCallEntries)),
            ("write_eintr_continuations", .uint(writeEINTRContinuations)),
            ("write_partial_continuations", .uint(writePartialContinuations)),
        ])
    }
}

private func sameDirectoryAuthority(
    _ current: VNodeIdentity,
    _ baseline: VNodeIdentity
) -> Bool {
    current.type == "DIRECTORY" && baseline.type == "DIRECTORY" &&
        current.device == baseline.device && current.inode == baseline.inode &&
        current.uid == baseline.uid && current.gid == baseline.gid &&
        current.permissionMode == baseline.permissionMode &&
        current.flags == baseline.flags
}

private struct MachOIdentity {
    let cdhash: String
    let codeDirectorySHA256: String
    let commands: [UInt32]
    let sliceOffset: UInt64
    let uuid: String
}

private struct ProcessIdentity {
    let pid: Int32
    let ppid: Int32
    let pgid: Int32
    let session: Int32
    let uid: UInt32
    let gid: UInt32
    let ruid: UInt32
    let rgid: UInt32
    let startSeconds: UInt64
    let startMicroseconds: UInt64

    var json: OwnerJSON {
        .object([
            ("gid", .uint(UInt64(gid))),
            ("pgid", .int(Int64(pgid))),
            ("pid", .int(Int64(pid))),
            ("ppid", .int(Int64(ppid))),
            ("rgid", .uint(UInt64(rgid))),
            ("ruid", .uint(UInt64(ruid))),
            ("session", .int(Int64(session))),
            ("start_microseconds", .uint(startMicroseconds)),
            ("start_seconds", .uint(startSeconds)),
            ("uid", .uint(UInt64(uid))),
        ])
    }
}

private struct MappedIdentity {
    let address: UInt64
    let device: Int64
    let fileOffset: UInt64
    let inode: UInt64
    let path: String
    let protection: UInt32
    let size: UInt64

    var json: OwnerJSON {
        .object([
            ("address", .uint(address)),
            ("device", .int(device)),
            ("file_offset", .uint(fileOffset)),
            ("inode", .uint(inode)),
            ("path", .string(path)),
            ("protection", .uint(UInt64(protection))),
            ("size", .uint(size)),
        ])
    }
}

private struct StartBoundaryReceipt {
    let errnoValue: Int32
    let mkdirResult: Int32
    let ticks: UInt64
}

private struct EndBoundaryReceipt {
    let matched: Bool
    let ticks: UInt64
}

private struct BoundaryVNode {
    let bytes: Int64
    let changeNanoseconds: Int64
    let changeSeconds: Int64
    let device: Int64
    let flags: UInt32
    let gid: UInt32
    let inode: UInt64
    let mode: UInt16
    let nlink: UInt16
    let uid: UInt32

    init(_ value: VNodeIdentity) {
        bytes = value.bytes
        changeNanoseconds = value.changeNanoseconds
        changeSeconds = value.changeSeconds
        device = value.device
        flags = value.flags
        gid = value.gid
        inode = value.inode
        mode = value.mode
        nlink = value.nlink
        uid = value.uid
    }
}

private struct BoundaryLeafJoin {
    let descriptor: Int32
    let nameOffset: Int
    let expected: BoundaryVNode
}

@inline(__always)
private func boundaryStatMatches(
    _ value: Darwin.stat,
    _ expected: BoundaryVNode
) -> Bool {
    Int64(value.st_size) == expected.bytes &&
        Int64(value.st_ctimespec.tv_nsec) == expected.changeNanoseconds &&
        Int64(value.st_ctimespec.tv_sec) == expected.changeSeconds &&
        Int64(value.st_dev) == expected.device &&
        UInt32(value.st_flags) == expected.flags &&
        UInt32(value.st_gid) == expected.gid &&
        UInt64(value.st_ino) == expected.inode &&
        UInt16(value.st_mode) == expected.mode &&
        UInt16(value.st_nlink) == expected.nlink &&
        UInt32(value.st_uid) == expected.uid
}

@inline(never)
private func ownerStartBoundary(
    parentFD: Int32,
    rootLeaf: UnsafePointer<CChar>
) -> StartBoundaryReceipt {
    let ticks = mach_continuous_time()
    let result = Darwin.mkdirat(parentFD, rootLeaf, mode_t(0o700))
    let savedErrno = result == 0 ? Int32(0) : errno
    return StartBoundaryReceipt(errnoValue: savedErrno, mkdirResult: result, ticks: ticks)
}

@inline(never)
private func ownerEndBoundary(
    parentFD: Int32,
    rawFD: Int32,
    rawLeaf: UnsafePointer<CChar>,
    rawAbsolutePath: UnsafePointer<CChar>,
    rawExpected: BoundaryVNode,
    captureRootFD: Int32,
    captureRootLeaf: UnsafePointer<CChar>,
    captureRootAbsolutePath: UnsafePointer<CChar>,
    captureRootExpected: BoundaryVNode,
    captureLeafJoins: UnsafePointer<BoundaryLeafJoin>?,
    captureLeafCount: Int,
    captureNameArena: UnsafePointer<CChar>?
) -> EndBoundaryReceipt {
    var rawHeld = Darwin.stat()
    var rawRelative = Darwin.stat()
    var rawNamed = Darwin.stat()
    guard Darwin.fstat(rawFD, &rawHeld) == 0,
          Darwin.fstatat(parentFD, rawLeaf, &rawRelative, atSymlinkNoFollow) == 0,
          Darwin.fstatat(
              atFDCWD, rawAbsolutePath, &rawNamed, atSymlinkNoFollowAny) == 0,
          boundaryStatMatches(rawHeld, rawExpected),
          boundaryStatMatches(rawRelative, rawExpected),
          boundaryStatMatches(rawNamed, rawExpected)
    else { return EndBoundaryReceipt(matched: false, ticks: 0) }

    guard captureLeafCount == 0 ||
            (captureLeafJoins != nil && captureNameArena != nil)
    else { return EndBoundaryReceipt(matched: false, ticks: 0) }
    var index = 0
    while index < captureLeafCount {
        let join = captureLeafJoins![index]
        var held = Darwin.stat()
        var relative = Darwin.stat()
        guard Darwin.fstat(join.descriptor, &held) == 0,
              Darwin.fstatat(
                  captureRootFD,
                  captureNameArena!.advanced(by: join.nameOffset),
                  &relative,
                  atSymlinkNoFollow) == 0,
              boundaryStatMatches(held, join.expected),
              boundaryStatMatches(relative, join.expected)
        else { return EndBoundaryReceipt(matched: false, ticks: 0) }
        index += 1
    }

    // The capture root is deliberately the final identity comparison. Its full
    // ctime stamp detects any directory-entry replacement after the content pass.
    var rootHeld = Darwin.stat()
    var rootRelative = Darwin.stat()
    var rootNamed = Darwin.stat()
    guard Darwin.fstat(captureRootFD, &rootHeld) == 0,
          Darwin.fstatat(
              parentFD, captureRootLeaf, &rootRelative, atSymlinkNoFollow) == 0,
          Darwin.fstatat(
              atFDCWD, captureRootAbsolutePath, &rootNamed,
              atSymlinkNoFollowAny) == 0,
          boundaryStatMatches(rootHeld, captureRootExpected),
          boundaryStatMatches(rootRelative, captureRootExpected),
          boundaryStatMatches(rootNamed, captureRootExpected)
    else { return EndBoundaryReceipt(matched: false, ticks: 0) }
    let ticks = mach_continuous_time()
    return EndBoundaryReceipt(matched: true, ticks: ticks)
}

private func fdStat(_ descriptor: Int32, _ code: String) throws -> VNodeIdentity {
    var value = Darwin.stat()
    guard Darwin.fstat(descriptor, &value) == 0 else {
        throw OwnerFailure(code, errnoValue: errno)
    }
    return VNodeIdentity(value)
}

private func statAt(
    _ directoryFD: Int32,
    _ path: String,
    flags: Int32 = atSymlinkNoFollow
) throws -> VNodeIdentity {
    var value = Darwin.stat()
    let result = path.withCString {
        Darwin.fstatat(directoryFD, $0, &value, flags)
    }
    guard result == 0 else { throw OwnerFailure("STAT_AT", errnoValue: errno) }
    return VNodeIdentity(value)
}

private func statAtIfPresent(
    _ directoryFD: Int32,
    _ path: String,
    flags: Int32 = atSymlinkNoFollow
) throws -> VNodeIdentity? {
    var value = Darwin.stat()
    errno = 0
    let result = path.withCString {
        Darwin.fstatat(directoryFD, $0, &value, flags)
    }
    if result == 0 { return VNodeIdentity(value) }
    let savedErrno = errno
    if result == -1 && savedErrno == ENOENT { return nil }
    throw OwnerFailure("STAT_AT_OPTIONAL", errnoValue: savedErrno)
}

private func openExisting(
    _ path: String,
    flags: Int32 = O_RDONLY | oNoFollowAny | oCloseOnExec,
    code: String
) throws -> Int32 {
    errno = 0
    let descriptor = path.withCString { Darwin.open($0, flags) }
    guard descriptor >= 3 else {
        if descriptor >= 0 { _ = Darwin.close(descriptor) }
        throw OwnerFailure(code, errnoValue: errno)
    }
    let descriptorFlags = Darwin.fcntl(descriptor, F_GETFD)
    guard descriptorFlags >= 0 && descriptorFlags & FD_CLOEXEC != 0 else {
        _ = Darwin.close(descriptor)
        throw OwnerFailure(code + "_CLOEXEC")
    }
    return descriptor
}

private func openAtExisting(
    _ directoryFD: Int32,
    _ leaf: String,
    flags: Int32 = O_RDONLY | oNoFollowAny | oCloseOnExec,
    code: String
) throws -> Int32 {
    errno = 0
    let descriptor = leaf.withCString { Darwin.openat(directoryFD, $0, flags) }
    guard descriptor >= 3 else {
        if descriptor >= 0 { _ = Darwin.close(descriptor) }
        throw OwnerFailure(code, errnoValue: errno)
    }
    let descriptorFlags = Darwin.fcntl(descriptor, F_GETFD)
    guard descriptorFlags >= 0 && descriptorFlags & FD_CLOEXEC != 0 else {
        _ = Darwin.close(descriptor)
        throw OwnerFailure(code + "_CLOEXEC")
    }
    return descriptor
}

private func createAtExclusive(
    _ directoryFD: Int32,
    _ leaf: String,
    mode: mode_t,
    code: String
) throws -> Int32 {
    let flags = O_RDWR | O_CREAT | O_EXCL | oNoFollowAny | oCloseOnExec
    errno = 0
    let descriptor = leaf.withCString {
        Darwin.openat(directoryFD, $0, flags, mode)
    }
    guard descriptor >= 3 else {
        if descriptor >= 0 { _ = Darwin.close(descriptor) }
        throw OwnerFailure(code, errnoValue: errno)
    }
    let descriptorFlags = Darwin.fcntl(descriptor, F_GETFD)
    guard descriptorFlags >= 0 && descriptorFlags & FD_CLOEXEC != 0 else {
        _ = Darwin.close(descriptor)
        throw OwnerFailure(code + "_CLOEXEC")
    }
    return descriptor
}

private func closeDescriptor(_ descriptor: inout Int32) throws {
    guard descriptor >= 0 else { return }
    let closing = descriptor
    descriptor = -1
    guard Darwin.close(closing) == 0 else {
        throw OwnerFailure("CLOSE", errnoValue: errno)
    }
}

private func closeDescriptorBestEffort(_ descriptor: inout Int32) {
    guard descriptor >= 0 else { return }
    let closing = descriptor
    descriptor = -1
    _ = Darwin.close(closing)
}

private func syncDescriptor(
    _ descriptor: Int32,
    _ code: String,
    accounting: IOAccounting
) throws {
    while true {
        try countedIncrement(&accounting.fsyncCallEntries, code + "_FSYNC_CALL_COUNT")
        if Darwin.fsync(descriptor) == 0 { break }
        if errno == EINTR {
            try countedIncrement(
                &accounting.fsyncEINTRContinuations, code + "_FSYNC_EINTR_COUNT")
            continue
        }
        throw OwnerFailure(code + "_FSYNC", errnoValue: errno)
    }
    while true {
        try countedIncrement(
            &accounting.fullFSyncCallEntries, code + "_FULLFSYNC_CALL_COUNT")
        if Darwin.fcntl(descriptor, fFullFSync) == 0 { break }
        if errno == EINTR {
            try countedIncrement(
                &accounting.fullFSyncEINTRContinuations,
                code + "_FULLFSYNC_EINTR_COUNT")
            continue
        }
        throw OwnerFailure(code + "_FULLFSYNC", errnoValue: errno)
    }
}

private func writeAll(
    _ descriptor: Int32,
    _ bytes: [UInt8],
    _ code: String,
    accounting: IOAccounting
) throws {
    try bytes.withUnsafeBytes { buffer in
        guard let base = buffer.baseAddress else {
            if bytes.isEmpty { return }
            throw OwnerFailure(code + "_BASE")
        }
        var offset = 0
        while offset < buffer.count {
            try countedIncrement(
                &accounting.writeCallEntries, code + "_WRITE_CALL_COUNT")
            let written = Darwin.write(
                descriptor, base.advanced(by: offset), buffer.count - offset)
            if written < 0 {
                if errno == EINTR {
                    try countedIncrement(
                        &accounting.writeEINTRContinuations,
                        code + "_WRITE_EINTR_COUNT")
                    continue
                }
                throw OwnerFailure(code + "_WRITE", errnoValue: errno)
            }
            guard written > 0 else { throw OwnerFailure(code + "_WRITE_ZERO") }
            if written < buffer.count - offset {
                try countedIncrement(
                    &accounting.writePartialContinuations,
                    code + "_WRITE_PARTIAL_COUNT")
            }
            offset += written
        }
    }
}

private func pwriteAll(
    _ descriptor: Int32,
    _ bytes: UnsafeRawBufferPointer,
    committedBytes: inout Int,
    code: String,
    callEntries: inout UInt64,
    eintrContinuations: inout UInt64,
    partialContinuations: inout UInt64,
    accounting: IOAccounting
) throws {
    guard let base = bytes.baseAddress else {
        if bytes.isEmpty { return }
        throw OwnerFailure(code + "_BASE")
    }
    var offset = 0
    while offset < bytes.count {
        try ownerRequire(committedBytes >= 0, code + "_OFFSET_NEGATIVE")
        try countedIncrement(
            &accounting.pwriteCallEntries, code + "_AGGREGATE_CALL_COUNT")
        let nextCall = callEntries.addingReportingOverflow(1)
        guard !nextCall.overflow else { throw OwnerFailure(code + "_CALL_COUNT") }
        callEntries = nextCall.partialValue
        let written = Darwin.pwrite(
            descriptor,
            base.advanced(by: offset),
            bytes.count - offset,
            off_t(committedBytes))
        if written < 0 {
            if errno == EINTR {
                try countedIncrement(
                    &accounting.pwriteEINTRContinuations,
                    code + "_AGGREGATE_EINTR_COUNT")
                let next = eintrContinuations.addingReportingOverflow(1)
                guard !next.overflow else { throw OwnerFailure(code + "_EINTR_COUNT") }
                eintrContinuations = next.partialValue
                continue
            }
            throw OwnerFailure(code + "_PWRITE", errnoValue: errno)
        }
        guard written > 0 else { throw OwnerFailure(code + "_PWRITE_ZERO") }
        let nextCommitted = committedBytes.addingReportingOverflow(written)
        guard !nextCommitted.overflow else { throw OwnerFailure(code + "_OFFSET") }
        committedBytes = nextCommitted.partialValue
        if written < bytes.count - offset {
            try countedIncrement(
                &accounting.pwritePartialContinuations,
                code + "_AGGREGATE_PARTIAL_COUNT")
            let next = partialContinuations.addingReportingOverflow(1)
            guard !next.overflow else { throw OwnerFailure(code + "_PARTIAL_COUNT") }
            partialContinuations = next.partialValue
        }
        offset += written
    }
}

private func readHeldBytes(
    _ descriptor: Int32,
    maximumBytes: Int,
    code: String,
    accounting: IOAccounting
) throws -> HeldBytes {
    let before = try fdStat(descriptor, code + "_BEFORE")
    try ownerRequire(before.type == "REGULAR", code + "_TYPE")
    try ownerRequire(before.bytes >= 0, code + "_SIZE_NEGATIVE")
    try ownerRequire(before.bytes <= Int64(maximumBytes), code + "_SIZE_CAP")
    guard Darwin.lseek(descriptor, 0, SEEK_SET) == 0 else {
        throw OwnerFailure(code + "_SEEK", errnoValue: errno)
    }
    var result: [UInt8] = []
    result.reserveCapacity(Int(before.bytes))
    var buffer = [UInt8](repeating: 0, count: 16_384)
    while result.count < Int(before.bytes) {
        let remaining = Int(before.bytes) - result.count
        let requested = min(buffer.count, remaining)
        try countedIncrement(
            &accounting.readCallEntries, code + "_READ_CALL_COUNT")
        let count = buffer.withUnsafeMutableBytes {
            Darwin.read(descriptor, $0.baseAddress, requested)
        }
        if count < 0 {
            if errno == EINTR {
                try countedIncrement(
                    &accounting.readEINTRContinuations,
                    code + "_READ_EINTR_COUNT")
                continue
            }
            throw OwnerFailure(code + "_READ", errnoValue: errno)
        }
        guard count > 0 else { throw OwnerFailure(code + "_SHORT") }
        if count < requested {
            try countedIncrement(
                &accounting.readPartialContinuations,
                code + "_READ_PARTIAL_COUNT")
        }
        result.append(contentsOf: buffer[0..<count])
    }
    var eof = -1
    while true {
        try countedIncrement(
            &accounting.readCallEntries, code + "_EOF_CALL_COUNT")
        eof = buffer.withUnsafeMutableBytes {
            Darwin.read(descriptor, $0.baseAddress, 1)
        }
        if eof < 0 && errno == EINTR {
            try countedIncrement(
                &accounting.readEINTRContinuations,
                code + "_EOF_EINTR_COUNT")
            continue
        }
        break
    }
    guard eof == 0 else {
        throw OwnerFailure(code + (eof < 0 ? "_EOF_READ" : "_GROWTH"),
                           errnoValue: eof < 0 ? errno : nil)
    }
    let after = try fdStat(descriptor, code + "_AFTER")
    try ownerRequire(after == before, code + "_DRIFT")
    guard Darwin.lseek(descriptor, 0, SEEK_SET) == 0 else {
        throw OwnerFailure(code + "_REWIND", errnoValue: errno)
    }
    return HeldBytes(
        bytes: result,
        before: before,
        after: after,
        sha256: AttemptSHA256.digestHex(result))
}

private func rejoinHeld(
    descriptor: Int32,
    directoryFD: Int32,
    leaf: String,
    baseline: VNodeIdentity,
    code: String
) throws {
    let held = try fdStat(descriptor, code + "_HELD")
    let relative = try statAt(directoryFD, leaf)
    try ownerRequire(held == baseline && relative == baseline, code + "_IDENTITY")
}

private func rejoinHeldAbsolute(
    descriptor: Int32,
    path: String,
    baseline: VNodeIdentity,
    code: String
) throws {
    let held = try fdStat(descriptor, code + "_HELD")
    let named = try statAt(atFDCWD, path, flags: atSymlinkNoFollowAny)
    try ownerRequire(held == baseline && named == baseline, code + "_IDENTITY")
}

private func uint32LE(_ bytes: [UInt8], _ offset: Int) throws -> UInt32 {
    guard offset >= 0, offset <= bytes.count, bytes.count - offset >= 4 else {
        throw OwnerFailure("U32LE_RANGE")
    }
    return UInt32(bytes[offset]) |
        (UInt32(bytes[offset + 1]) << 8) |
        (UInt32(bytes[offset + 2]) << 16) |
        (UInt32(bytes[offset + 3]) << 24)
}

private func uint64LE(_ bytes: [UInt8], _ offset: Int) throws -> UInt64 {
    guard offset >= 0, offset <= bytes.count, bytes.count - offset >= 8 else {
        throw OwnerFailure("U64LE_RANGE")
    }
    var result: UInt64 = 0
    for index in 0..<8 { result |= UInt64(bytes[offset + index]) << UInt64(index * 8) }
    return result
}

private func uint32BE(_ bytes: [UInt8], _ offset: Int) throws -> UInt32 {
    guard offset >= 0, offset <= bytes.count, bytes.count - offset >= 4 else {
        throw OwnerFailure("U32BE_RANGE")
    }
    return (UInt32(bytes[offset]) << 24) |
        (UInt32(bytes[offset + 1]) << 16) |
        (UInt32(bytes[offset + 2]) << 8) |
        UInt32(bytes[offset + 3])
}

private func canonicalUUID(_ bytes: ArraySlice<UInt8>) throws -> String {
    try ownerRequire(bytes.count == 16, "UUID_WIDTH")
    let hexadecimal = Array("0123456789ABCDEF".utf8)
    var encoded: [UInt8] = []
    encoded.reserveCapacity(36)
    for (index, byte) in bytes.enumerated() {
        if index == 4 || index == 6 || index == 8 || index == 10 { encoded.append(0x2d) }
        encoded.append(hexadecimal[Int(byte >> 4)])
        encoded.append(hexadecimal[Int(byte & 0x0f)])
    }
    return String(decoding: encoded, as: UTF8.self)
}

private func parseMachO(
    _ fileBytes: [UInt8],
    requireExecutable: Bool,
    requireCodeDirectory: Bool,
    code: String
) throws -> MachOIdentity {
    var sliceOffset = 0
    var sliceSize = fileBytes.count
    if fileBytes.count >= 8, try uint32BE(fileBytes, 0) == 0xcafe_babe {
        let count = Int(try uint32BE(fileBytes, 4))
        try ownerRequire((1...16).contains(count), code + "_FAT_COUNT")
        try ownerRequire(fileBytes.count >= 8 + count * 20, code + "_FAT_HEADER")
        var found: (Int, Int)?
        for index in 0..<count {
            let entry = 8 + index * 20
            let cpu = try uint32BE(fileBytes, entry)
            let offset = Int(try uint32BE(fileBytes, entry + 8))
            let size = Int(try uint32BE(fileBytes, entry + 12))
            guard offset >= 0, size >= 32, offset <= fileBytes.count,
                  size <= fileBytes.count - offset else {
                throw OwnerFailure(code + "_FAT_RANGE")
            }
            if cpu == 0x0100_000c {
                try ownerRequire(found == nil, code + "_FAT_DUPLICATE_ARM64")
                found = (offset, size)
            }
        }
        guard let selected = found else { throw OwnerFailure(code + "_FAT_ARM64") }
        sliceOffset = selected.0
        sliceSize = selected.1
    }

    try ownerRequire(sliceSize >= 32, code + "_HEADER")
    try ownerRequire((try uint32LE(fileBytes, sliceOffset)) == 0xfeed_facf,
                     code + "_MAGIC")
    try ownerRequire((try uint32LE(fileBytes, sliceOffset + 4)) == 0x0100_000c,
                     code + "_CPU")
    let fileType = try uint32LE(fileBytes, sliceOffset + 12)
    if requireExecutable { try ownerRequire(fileType == 2, code + "_FILETYPE") }
    let commandCount = Int(try uint32LE(fileBytes, sliceOffset + 16))
    let commandBytes = Int(try uint32LE(fileBytes, sliceOffset + 20))
    try ownerRequire((1...256).contains(commandCount), code + "_COMMAND_COUNT")
    try ownerRequire(commandBytes <= sliceSize - 32, code + "_COMMAND_BYTES")
    var cursor = sliceOffset + 32
    let finish = cursor + commandBytes
    var commands: [UInt32] = []
    var uuid: String?
    var signature: (Int, Int)?
    for _ in 0..<commandCount {
        try ownerRequire(cursor <= finish && finish - cursor >= 8, code + "_COMMAND_HEADER")
        let command = try uint32LE(fileBytes, cursor)
        let size = Int(try uint32LE(fileBytes, cursor + 4))
        try ownerRequire(size >= 8 && size <= finish - cursor, code + "_COMMAND_SIZE")
        commands.append(command)
        if command == 0x1b {
            try ownerRequire(size == 24 && uuid == nil, code + "_UUID_COMMAND")
            uuid = try canonicalUUID(fileBytes[(cursor + 8)..<(cursor + 24)])
        } else if command == 0x1d {
            try ownerRequire(size == 16 && signature == nil, code + "_SIGNATURE_COMMAND")
            signature = (
                Int(try uint32LE(fileBytes, cursor + 8)),
                Int(try uint32LE(fileBytes, cursor + 12)))
        }
        cursor += size
    }
    try ownerRequire(cursor == finish, code + "_COMMAND_END")
    guard let parsedUUID = uuid else { throw OwnerFailure(code + "_UUID_MISSING") }
    if !requireCodeDirectory {
        return MachOIdentity(
            cdhash: "",
            codeDirectorySHA256: "",
            commands: commands,
            sliceOffset: UInt64(sliceOffset),
            uuid: parsedUUID)
    }
    guard let codeSignature = signature else {
        throw OwnerFailure(code + "_SIGNATURE_MISSING")
    }
    let signatureOffset = sliceOffset.addingReportingOverflow(codeSignature.0)
    try ownerRequire(!signatureOffset.overflow, code + "_SIGNATURE_OFFSET")
    try ownerRequire(codeSignature.1 >= 12 &&
                     codeSignature.1 <= fileBytes.count - signatureOffset.partialValue,
                     code + "_SIGNATURE_RANGE")
    let region = Array(
        fileBytes[signatureOffset.partialValue..<(signatureOffset.partialValue + codeSignature.1)])
    try ownerRequire((try uint32BE(region, 0)) == 0xfade_0cc0,
                     code + "_SUPERBLOB")
    let declared = Int(try uint32BE(region, 4))
    let count = Int(try uint32BE(region, 8))
    try ownerRequire((1...16).contains(count), code + "_SUPERBLOB_COUNT")
    try ownerRequire(12 + count * 8 <= declared && declared <= region.count,
                     code + "_SUPERBLOB_RANGE")
    let suffix = Array(region[declared..<region.count])
    try ownerRequire(suffix.count <= 1 && suffix.allSatisfy { $0 == 0 },
                     code + "_SUPERBLOB_SUFFIX")
    var codeDirectory: [UInt8]?
    for index in 0..<count {
        let slot = try uint32BE(region, 12 + index * 8)
        let offset = Int(try uint32BE(region, 16 + index * 8))
        try ownerRequire(offset >= 12 + count * 8 && offset <= declared - 8,
                         code + "_BLOB_OFFSET")
        let length = Int(try uint32BE(region, offset + 4))
        try ownerRequire(length >= 8 && length <= declared - offset,
                         code + "_BLOB_LENGTH")
        if slot == 0 {
            try ownerRequire(codeDirectory == nil, code + "_CODE_DIRECTORY_DUPLICATE")
            try ownerRequire((try uint32BE(region, offset)) == 0xfade_0c02 && length >= 44,
                             code + "_CODE_DIRECTORY_MAGIC")
            let candidate = Array(region[offset..<(offset + length)])
            try ownerRequire(candidate[36] == 32 && candidate[37] == 2,
                             code + "_CODE_DIRECTORY_HASH")
            codeDirectory = candidate
        }
    }
    guard let directory = codeDirectory else {
        throw OwnerFailure(code + "_CODE_DIRECTORY_MISSING")
    }
    let directorySHA = AttemptSHA256.digestHex(directory)
    return MachOIdentity(
        cdhash: String(directorySHA.prefix(40)),
        codeDirectorySHA256: directorySHA,
        commands: commands,
        sliceOffset: UInt64(sliceOffset),
        uuid: parsedUUID)
}

private func processIdentity(_ pid: Int32, _ code: String) throws -> ProcessIdentity {
    var bytes = [UInt8](repeating: 0, count: procBSDInfoBytes)
    let returned = bytes.withUnsafeMutableBytes {
        ownerProcPIDInfo(pid, procPIDTBSDInfo, 0, $0.baseAddress, Int32($0.count))
    }
    try ownerRequire(Int(returned) == procBSDInfoBytes, code + "_BSDINFO")
    let observedPID = Int32(bitPattern: try uint32LE(bytes, 12))
    let ppid = Int32(bitPattern: try uint32LE(bytes, 16))
    let uid = try uint32LE(bytes, 20)
    let gid = try uint32LE(bytes, 24)
    let ruid = try uint32LE(bytes, 28)
    let rgid = try uint32LE(bytes, 32)
    let pgid = Int32(bitPattern: try uint32LE(bytes, 100))
    let startSeconds = try uint64LE(bytes, 120)
    let startMicroseconds = try uint64LE(bytes, 128)
    try ownerRequire(observedPID == pid, code + "_PID")
    let session = Darwin.getsid(pid)
    try ownerRequire(session >= 0, code + "_SESSION")
    try ownerRequire(startSeconds > 0 && startMicroseconds < 1_000_000,
                     code + "_GENERATION")
    return ProcessIdentity(
        pid: observedPID,
        ppid: ppid,
        pgid: pgid,
        session: session,
        uid: uid,
        gid: gid,
        ruid: ruid,
        rgid: rgid,
        startSeconds: startSeconds,
        startMicroseconds: startMicroseconds)
}

private func processPath(_ pid: Int32, _ code: String) throws -> String {
    var bytes = [UInt8](repeating: 0, count: procPIDPathInfoMaximum)
    let returned = bytes.withUnsafeMutableBytes {
        ownerProcPIDPath(pid, $0.baseAddress, UInt32($0.count))
    }
    try ownerRequire(returned > 0 && Int(returned) < procPIDPathInfoMaximum,
                     code + "_RETURN")
    try ownerRequire(bytes[Int(returned)] == 0, code + "_NUL")
    let path = bytes.withUnsafeBufferPointer { buffer -> String? in
        guard let base = buffer.baseAddress else { return nil }
        return base.withMemoryRebound(to: CChar.self, capacity: buffer.count) {
            String(validatingCString: $0)
        }
    }
    guard let path else { throw OwnerFailure(code + "_UTF8") }
    try ownerRequire(!path.isEmpty, code + "_EMPTY")
    return path
}

private func mappedRegion(
    pid: Int32,
    address: UInt64,
    code: String
) throws -> MappedIdentity {
    var bytes = [UInt8](repeating: 0, count: procRegionPathInfoBytes)
    let returned = bytes.withUnsafeMutableBytes {
        ownerProcPIDInfo(
            pid, procPIDRegionPathInfo, address, $0.baseAddress, Int32($0.count))
    }
    try ownerRequire(Int(returned) == procRegionPathInfoBytes, code + "_RETURN")
    let protection = try uint32LE(bytes, 0)
    let fileOffset = try uint64LE(bytes, 16)
    let regionAddress = try uint64LE(bytes, 80)
    let regionSize = try uint64LE(bytes, 88)
    let device = Int64(Int32(bitPattern: try uint32LE(bytes, 96)))
    let inode = try uint64LE(bytes, 104)
    try ownerRequire(regionSize > 0, code + "_SIZE")
    let end = regionAddress.addingReportingOverflow(regionSize)
    try ownerRequire(!end.overflow, code + "_OVERFLOW")
    let pathFrame = Array(bytes[248..<1_272])
    guard let nul = pathFrame.firstIndex(of: 0) else {
        throw OwnerFailure(code + "_PATH_NUL")
    }
    var terminated = Array(pathFrame[0...nul])
    let path = terminated.withUnsafeMutableBufferPointer { buffer -> String? in
        guard let base = buffer.baseAddress else { return nil }
        return base.withMemoryRebound(to: CChar.self, capacity: buffer.count) {
            String(validatingCString: $0)
        }
    }
    guard let path else { throw OwnerFailure(code + "_PATH_UTF8") }
    return MappedIdentity(
        address: regionAddress,
        device: device,
        fileOffset: fileOffset,
        inode: inode,
        path: path,
        protection: protection,
        size: regionSize)
}

private func mappedRegionContaining(
    pid: Int32,
    address: UInt64,
    expectedPath: String,
    expected: VNodeIdentity,
    expectedFileOffset: UInt64,
    code: String
) throws -> MappedIdentity {
    let region = try mappedRegion(pid: pid, address: address, code: code)
    let end = region.address.addingReportingOverflow(region.size)
    try ownerRequire(!end.overflow && region.address <= address && address < end.partialValue,
                     code + "_CONTAINMENT")
    try ownerRequire(region.path == expectedPath, code + "_PATH")
    try ownerRequire(region.device == expected.device && region.inode == expected.inode,
                     code + "_VNODE")
    try ownerRequire(region.fileOffset == expectedFileOffset, code + "_OFFSET")
    try ownerRequire(region.protection & vmProtectionExecute != 0, code + "_PROTECTION")
    return region
}

private func findMappedExecutable(
    pid: Int32,
    expectedPath: String,
    expected: VNodeIdentity,
    expectedFileOffset: UInt64,
    code: String
) throws -> MappedIdentity {
    var queryAddress: UInt64 = 0
    for _ in 0..<4_096 {
        let region = try mappedRegion(pid: pid, address: queryAddress, code: code)
        let end = region.address.addingReportingOverflow(region.size)
        try ownerRequire(!end.overflow && end.partialValue > queryAddress,
                         code + "_ADVANCE")
        if region.path == expectedPath &&
            region.device == expected.device && region.inode == expected.inode &&
            region.fileOffset == expectedFileOffset &&
            region.protection & vmProtectionExecute != 0 {
            return region
        }
        queryAddress = end.partialValue
    }
    throw OwnerFailure(code + "_NOT_FOUND")
}

private struct DirectoryName {
    let bytes: [UInt8]
    let string: String
}

private func rawDirectoryNames(_ directoryFD: Int32, _ code: String) throws -> [DirectoryName] {
    let before = try fdStat(directoryFD, code + "_BEFORE")
    var scanFD = try openAtExisting(
        directoryFD, ".",
        flags: O_RDONLY | oDirectory | oNoFollowAny | oCloseOnExec,
        code: code + "_SCAN_OPEN")
    let scanIdentity: VNodeIdentity
    do {
        scanIdentity = try fdStat(scanFD, code + "_SCAN_IDENTITY")
    } catch {
        closeDescriptorBestEffort(&scanFD)
        throw error
    }
    guard scanIdentity == before else {
        closeDescriptorBestEffort(&scanFD)
        throw OwnerFailure(code + "_SCAN_JOIN")
    }
    guard let directory = Darwin.fdopendir(scanFD) else {
        var failed = scanFD
        closeDescriptorBestEffort(&failed)
        throw OwnerFailure(code + "_FDOPENDIR", errnoValue: errno)
    }
    scanFD = -1
    var names: [DirectoryName] = []
    var failure: OwnerFailure?
    while failure == nil {
        errno = 0
        guard let entry = Darwin.readdir(directory) else {
            if errno != 0 { failure = OwnerFailure(code + "_READDIR", errnoValue: errno) }
            break
        }
        let name = withUnsafePointer(to: &entry.pointee.d_name) { pointer -> String? in
            let capacity = MemoryLayout.size(ofValue: entry.pointee.d_name)
            return pointer.withMemoryRebound(to: CChar.self, capacity: capacity) {
                String(validatingCString: $0)
            }
        }
        guard let name else {
            failure = OwnerFailure(code + "_NAME_UTF8")
            break
        }
        if name == "." || name == ".." { continue }
        let bytes = Array(name.utf8)
        if bytes.isEmpty || bytes.contains(0) || bytes.contains(0x2f) {
            failure = OwnerFailure(code + "_NAME_SHAPE")
            break
        }
        if names.contains(where: { $0.bytes == bytes }) {
            failure = OwnerFailure(code + "_DUPLICATE")
            break
        }
        names.append(DirectoryName(bytes: bytes, string: name))
    }
    let closeResult = Darwin.closedir(directory)
    if closeResult != 0 && failure == nil {
        failure = OwnerFailure(code + "_CLOSEDIR", errnoValue: errno)
    }
    if let failure { throw failure }
    let after = try fdStat(directoryFD, code + "_AFTER")
    try ownerRequire(after == before, code + "_SCAN_DRIFT")
    return names.sorted { $0.bytes.lexicographicallyPrecedes($1.bytes) }
}

private struct LeafReceipt {
    let name: String
    let sha256: String
    let vnode: VNodeIdentity

    var json: OwnerJSON {
        .object([
            ("name", .string(name)),
            ("sha256", .string(sha256)),
            ("vnode", vnode.json),
        ])
    }
}

private struct CaptureInventory {
    let entries: [LeafReceipt]
    let root: VNodeIdentity
    let supervisorManifestSHA256: String
    let terminalState: String
    let v9TSVManifestSHA256: String

    var json: OwnerJSON {
        .object([
            ("entries", .array(entries.map { $0.json })),
            ("names", .array(entries.map { .string($0.name) })),
            ("root", root.json),
            ("root_mutation_stamp", root.mutationStampJSON),
            ("supervisor_manifest_sha256", .string(supervisorManifestSHA256)),
            ("terminal_state", .string(terminalState)),
            ("v9_tsv_manifest_sha256", .string(v9TSVManifestSHA256)),
        ])
    }
}

private struct HeldCaptureLeaf {
    var descriptor: Int32
    let receipt: LeafReceipt
}

private struct HeldCaptureInventory {
    var leaves: [HeldCaptureLeaf]
    let receipt: CaptureInventory
}

private func isRunnerStagingName(_ value: String) -> Bool {
    let prefix = Array("c2-prefix-capture.tmp.".utf8)
    let bytes = Array(value.utf8)
    guard bytes.count == prefix.count + 6, Array(bytes.prefix(prefix.count)) == prefix else {
        return false
    }
    return bytes.suffix(6).allSatisfy {
        (0x30...0x39).contains($0) || (0x41...0x5a).contains($0) ||
            (0x61...0x7a).contains($0)
    }
}

private func captureInventory(
    artifactParentFD: Int32,
    captureRootFD: Int32,
    code: String,
    accounting: IOAccounting
) throws -> HeldCaptureInventory {
    let rootBefore = try fdStat(captureRootFD, code + "_ROOT_BEFORE")
    let relative = try statAt(artifactParentFD, OwnerPaths.captureRootLeaf)
    let named = try statAt(atFDCWD, OwnerPaths.captureRoot, flags: atSymlinkNoFollowAny)
    try ownerRequire(rootBefore == relative && rootBefore == named, code + "_ROOT_JOIN")
    try ownerRequire(rootBefore.type == "DIRECTORY" &&
                     rootBefore.device == OwnerIdentity.artifactParentDevice &&
                     rootBefore.uid == 501 && rootBefore.gid == 20 && rootBefore.flags == 0 &&
                     (rootBefore.permissionMode == 0o500 || rootBefore.permissionMode == 0o700),
                     code + "_ROOT_POLICY")
    let names = try rawDirectoryNames(captureRootFD, code + "_NAMES")
    try ownerRequire(names.count <= 128, code + "_NAME_CAP")
    try ownerRequire(rootBefore.nlink == UInt16(2 + names.count), code + "_NLINK")
    let success = [
        "00-start.json", "01-stdout.bin", "02-stderr.bin", "03-result.json",
        "04-closure.json",
    ]
    let allowed = Set(success + ["99-incomplete.json"])
    var stagingCount = 0
    for name in names {
        if !allowed.contains(name.string) {
            try ownerRequire(isRunnerStagingName(name.string), code + "_NAME")
            stagingCount += 1
        }
    }
    try ownerRequire(stagingCount <= 1, code + "_STAGING_COUNT")
    let ordinaryNames = names.map(\.string).filter { success.contains($0) }
    try ownerRequire(ordinaryNames == Array(success.prefix(ordinaryNames.count)).sorted(),
                     code + "_ORDINARY_PREFIX")

    let terminalState: String
    if rootBefore.permissionMode == 0o500 {
        terminalState = "SEALED_0500"
    } else {
        terminalState = "RETAINED_INCOMPLETE_0700"
    }
    var entries: [LeafReceipt] = []
    var heldLeaves: [HeldCaptureLeaf] = []
    var transferDescriptors = false
    defer {
        if !transferDescriptors {
            for index in heldLeaves.indices {
                closeDescriptorBestEffort(&heldLeaves[index].descriptor)
            }
        }
    }
    var inodes = Set<UInt64>()
    var tsv: [UInt8] = []
    for name in names {
        var descriptor = try openAtExisting(
            captureRootFD, name.string, code: code + "_LEAF_OPEN")
        do {
            let held = try readHeldBytes(
                descriptor, maximumBytes: captureLeafByteCap,
                code: code + "_LEAF_READ", accounting: accounting)
            let relativeLeaf = try statAt(captureRootFD, name.string)
            try ownerRequire(held.after == relativeLeaf, code + "_LEAF_JOIN")
            try ownerRequire(held.after.type == "REGULAR" &&
                             held.after.device == rootBefore.device &&
                             held.after.uid == 501 && held.after.gid == 20 &&
                             held.after.nlink == 1 && held.after.flags == 0,
                             code + "_LEAF_POLICY")
            if isRunnerStagingName(name.string) {
                try ownerRequire(
                    held.after.permissionMode == 0o600 || held.after.permissionMode == 0o400,
                    code + "_STAGING_MODE")
            } else {
                try ownerRequire(held.after.permissionMode == 0o400, code + "_LEAF_MODE")
            }
            try ownerRequire(held.after.inode != rootBefore.inode &&
                             inodes.insert(held.after.inode).inserted,
                             code + "_INODE_DISTINCT")
            let receipt = LeafReceipt(
                name: name.string, sha256: held.sha256, vnode: held.after)
            entries.append(receipt)
            let row = [
                name.string,
                String(held.after.device),
                String(held.after.inode),
                octalMode(held.after.permissionMode),
                String(held.after.nlink),
                String(held.after.bytes),
                held.sha256,
            ].joined(separator: "\t") + "\n"
            tsv.append(contentsOf: row.utf8)
            heldLeaves.append(HeldCaptureLeaf(descriptor: descriptor, receipt: receipt))
            descriptor = -1
        } catch {
            closeDescriptorBestEffort(&descriptor)
            throw error
        }
    }
    let rootAfter = try fdStat(captureRootFD, code + "_ROOT_AFTER")
    let relativeAfter = try statAt(artifactParentFD, OwnerPaths.captureRootLeaf)
    let namedAfter = try statAt(
        atFDCWD, OwnerPaths.captureRoot, flags: atSymlinkNoFollowAny)
    try ownerRequire(rootAfter == rootBefore && relativeAfter == rootBefore &&
                     namedAfter == rootBefore, code + "_ROOT_DRIFT")
    let supervisorObject = OwnerJSON.object([
        ("entries", .array(entries.map { receipt in
            .object([
                ("bytes", .int(receipt.vnode.bytes)),
                ("device", .int(receipt.vnode.device)),
                ("flags", .uint(UInt64(receipt.vnode.flags))),
                ("gid", .uint(UInt64(receipt.vnode.gid))),
                ("inode", .uint(receipt.vnode.inode)),
                ("mode", .string(octalMode(receipt.vnode.permissionMode))),
                ("name", .string(receipt.name)),
                ("nlink", .uint(UInt64(receipt.vnode.nlink))),
                ("sha256", .string(receipt.sha256)),
                ("type", .string(receipt.vnode.type)),
                ("uid", .uint(UInt64(receipt.vnode.uid))),
            ])
        })),
        ("names", .array(entries.map { .string($0.name) })),
    ])
    let receipt = CaptureInventory(
        entries: entries,
        root: rootAfter,
        supervisorManifestSHA256: AttemptSHA256.digestHex(try supervisorObject.encoded()),
        terminalState: terminalState,
        v9TSVManifestSHA256: AttemptSHA256.digestHex(tsv))
    transferDescriptors = true
    return HeldCaptureInventory(leaves: heldLeaves, receipt: receipt)
}

private func utcTimestamp(_ code: String) throws -> String {
    var instant = timespec()
    guard Darwin.clock_gettime(CLOCK_REALTIME, &instant) == 0 else {
        throw OwnerFailure(code + "_CLOCK", errnoValue: errno)
    }
    var seconds = instant.tv_sec
    var brokenDown = tm()
    guard Darwin.gmtime_r(&seconds, &brokenDown) != nil else {
        throw OwnerFailure(code + "_GMTIME", errnoValue: errno)
    }
    let nanoseconds = Int32(instant.tv_nsec)
    try ownerRequire(nanoseconds >= 0 && nanoseconds < 1_000_000_000,
                     code + "_NANOSECONDS")
    return paddedDecimal(brokenDown.tm_year + 1900, width: 4) + "-" +
        paddedDecimal(brokenDown.tm_mon + 1, width: 2) + "-" +
        paddedDecimal(brokenDown.tm_mday, width: 2) + "T" +
        paddedDecimal(brokenDown.tm_hour, width: 2) + ":" +
        paddedDecimal(brokenDown.tm_min, width: 2) + ":" +
        paddedDecimal(brokenDown.tm_sec, width: 2) + "." +
        paddedDecimal(nanoseconds, width: 9) + "Z"
}

private struct RawReceipt {
    let complete: Bool
    let completeStream: Bool
    let durable: Bool
    let eofCount: UInt64
    let observedStreamBytes: UInt64
    let overflow: Bool
    let publicationError: String?
    let publicationErrno: Int32?
    let publicationStage: String
    let pwriteCallEntries: UInt64
    let pwriteEINTRContinuations: UInt64
    let pwritePartialContinuations: UInt64
    let readCallEntries: UInt64
    let readEINTRContinuations: UInt64
    let readPartialContinuations: UInt64
    let readError: Int32?
    let retainedPrefixBytes: UInt64
    let retainedPrefixLFCount: UInt64
    let retainedPrefixSHA256: String
    let vnode: VNodeIdentity?
    let writerClose: WriterCloseReceipt
    let writeError: String?

    var json: OwnerJSON {
        .object([
            ("complete_stream_bytes", completeStream ? .uint(retainedPrefixBytes) : .null),
            ("complete_stream_lf_count", completeStream ? .uint(retainedPrefixLFCount) : .null),
            ("complete_stream_sha256", completeStream ? .string(retainedPrefixSHA256) : .null),
            ("complete", .bool(complete)),
            ("durable", .bool(durable)),
            ("eof_count", .uint(eofCount)),
            ("observed_stream_bytes", .uint(observedStreamBytes)),
            ("overflow", .bool(overflow)),
            ("publication_error", publicationError.map { .string($0) } ?? .null),
            ("publication_errno", publicationErrno.map { .int(Int64($0)) } ?? .null),
            ("publication_stage", .string(publicationStage)),
            ("pwrite_call_entries", .uint(pwriteCallEntries)),
            ("pwrite_eintr_continuations", .uint(pwriteEINTRContinuations)),
            ("pwrite_partial_continuations", .uint(pwritePartialContinuations)),
            ("read_call_entries", .uint(readCallEntries)),
            ("read_eintr_continuations", .uint(readEINTRContinuations)),
            ("read_partial_continuations", .uint(readPartialContinuations)),
            ("read_errno", readError.map { .int(Int64($0)) } ?? .null),
            ("retained_prefix_bytes", .uint(retainedPrefixBytes)),
            ("retained_prefix_lf_count", .uint(retainedPrefixLFCount)),
            ("retained_prefix_sha256", .string(retainedPrefixSHA256)),
            ("vnode", vnode?.json ?? .null),
            ("writer_close", writerClose.json),
            ("write_error", writeError.map { .string($0) } ?? .null),
        ])
    }
}

private struct WaitReceipt {
    let callEntries: UInt64
    let childPID: Int32
    let eintrContinuations: UInt64
    let rawStatus: Int32?
    let waitErrorCode: String?
    let waitErrno: Int32?
    let waitedPID: Int32?

    var json: OwnerJSON {
        let exitStatus: OwnerJSON
        let exited: OwnerJSON
        let signaled: OwnerJSON
        let terminatingSignal: OwnerJSON
        if let rawStatus {
            let signal = rawStatus & 0x7f
            exitStatus = signal == 0
                ? .int(Int64((rawStatus >> 8) & 0xff)) : .null
            exited = .bool(signal == 0)
            signaled = .bool(signal != 0)
            terminatingSignal = signal == 0 ? .null : .int(Int64(signal))
        } else {
            exitStatus = .null
            exited = .null
            signaled = .null
            terminatingSignal = .null
        }
        return .object([
            ("call_entries", .uint(callEntries)),
            ("child_pid", .int(Int64(childPID))),
            ("eintr_continuations", .uint(eintrContinuations)),
            ("exit_status", exitStatus),
            ("exited", exited),
            ("raw_status", rawStatus.map { .int(Int64($0)) } ?? .null),
            ("signaled", signaled),
            ("term_signal", terminatingSignal),
            ("wait_error", waitErrorCode.map { .string($0) } ?? .null),
            ("wait_errno", waitErrno.map { .int(Int64($0)) } ?? .null),
            ("waited_pid", waitedPID.map { .int(Int64($0)) } ?? .null),
        ])
    }
}

private struct WriterCloseReceipt {
    let errnoValue: Int32?
    let result: Int32

    var json: OwnerJSON {
        .object([
            ("attempted", .bool(true)),
            ("errno", errnoValue.map { .int(Int64($0)) } ?? .null),
            ("result", .int(Int64(result))),
            ("succeeded", .bool(result == 0)),
        ])
    }
}

private struct PublishedLeaf {
    let bytes: [UInt8]
    let previousSHA256: String?
    let receipt: LeafReceipt
    let state: AttemptPublicationState
}

private struct HeldJournalLeaf {
    var descriptor: Int32
    let name: String
    let vnode: VNodeIdentity
}

private func publicationPhaseName(_ phase: AttemptPublicationPhase) -> String {
    switch phase {
    case .unentered: return "UNENTERED"
    case .exclusiveLeafOpened: return "EXCLUSIVE_LEAF_OPENED"
    case .bytesComplete: return "BYTES_COMPLETE"
    case .readbackVerified: return "READBACK_VERIFIED"
    case .firstSyncComplete: return "FIRST_SYNC_COMPLETE"
    case .modeSealed: return "MODE_SEALED"
    case .secondSyncComplete: return "SECOND_SYNC_COMPLETE"
    case .parentSyncComplete: return "PARENT_SYNC_COMPLETE"
    case .vnodeRejoined: return "VNODE_REJOINED"
    }
}

private struct PublicationFailureFact {
    let attemptedBytes: UInt64
    let attemptedSHA256: String
    let descriptorHeld: Bool
    let durableCandidate: LeafReceipt?
    let errorCode: String
    let errnoValue: Int32?
    let leaf: String
    let phase: AttemptPublicationPhase
    let previousSHA256: String?

    var json: OwnerJSON {
        .object([
            ("attempted_bytes", .uint(attemptedBytes)),
            ("attempted_sha256", .string(attemptedSHA256)),
            ("final_name_descriptor_held", .bool(descriptorHeld)),
            ("mode_sealed_candidate", durableCandidate?.json ?? .null),
            ("error", .string(errorCode)),
            ("errno", errnoValue.map { .int(Int64($0)) } ?? .null),
            ("leaf", .string(leaf)),
            ("phase", .string(publicationPhaseName(phase))),
            ("previous_leaf_sha256",
             previousSHA256.map { .string($0) } ?? .null),
        ])
    }
}

private struct SelfAdmission {
    let executableMachO: MachOIdentity
    let executablePath: String
    let executableVNode: VNodeIdentity
    let groups: [UInt32]
    let mapping: MappedIdentity
    let process: ProcessIdentity

    var json: OwnerJSON {
        .object([
            ("executable", .object([
                ("cdhash", .string(executableMachO.cdhash)),
                ("code_directory_sha256", .string(executableMachO.codeDirectorySHA256)),
                ("load_commands", .array(executableMachO.commands.map {
                    .uint(UInt64($0))
                })),
                ("path", .string(executablePath)),
                ("uuid", .string(executableMachO.uuid)),
                ("vnode", executableVNode.json),
            ])),
            ("groups", .array(groups.map { .uint(UInt64($0)) })),
            ("mapping", mapping.json),
            ("process", process.json),
        ])
    }
}

private struct ChildAdmission {
    let mapping: MappedIdentity
    let path: String
    let process: ProcessIdentity

    var json: OwnerJSON {
        .object([
            ("mapping", mapping.json),
            ("path", .string(path)),
            ("process", process.json),
        ])
    }
}

private struct PartialChildAdmission {
    var complete = false
    var mapping: MappedIdentity?
    var path: String?
    var pathJoined = false
    var process: ProcessIdentity?
    var processJoined = false

    var json: OwnerJSON {
        .object([
            ("complete", .bool(complete)),
            ("mapping", mapping?.json ?? .null),
            ("path", path.map { .string($0) } ?? .null),
            ("path_joined", .bool(pathJoined)),
            ("process", process?.json ?? .null),
            ("process_joined", .bool(processJoined)),
        ])
    }
}

private struct SpawnResources {
    var actions: posix_spawn_file_actions_t?
    var attributes: posix_spawnattr_t?
    var actionsInitialized = false
    var attributesInitialized = false
    var argv: [UnsafeMutablePointer<CChar>?] = []
    var environment: [UnsafeMutablePointer<CChar>?] = []

    mutating func initialize(
        sourceFD: Int32,
        nullFD: Int32,
        pipeReadFD: Int32,
        pipeWriteFD: Int32
    ) throws {
        try ownerRequire(!actionsInitialized && !attributesInitialized,
                         "SPAWN_RESOURCES_DUPLICATE")
        guard posix_spawn_file_actions_init(&actions) == 0 else {
            throw OwnerFailure("SPAWN_ACTIONS_INIT")
        }
        actionsInitialized = true
        guard posix_spawnattr_init(&attributes) == 0 else {
            throw OwnerFailure("SPAWN_ATTRIBUTES_INIT")
        }
        attributesInitialized = true
        guard posix_spawn_file_actions_adddup2(&actions, nullFD, STDIN_FILENO) == 0,
              posix_spawn_file_actions_adddup2(&actions, pipeWriteFD, STDOUT_FILENO) == 0,
              posix_spawn_file_actions_adddup2(&actions, pipeWriteFD, STDERR_FILENO) == 0,
              posix_spawn_file_actions_adddup2(&actions, sourceFD, 3) == 0,
              posix_spawn_file_actions_addclose(&actions, pipeReadFD) == 0
        else {
            throw OwnerFailure("SPAWN_ACTIONS")
        }
        guard posix_spawnattr_setflags(
            &attributes, posixSpawnCloseOnExecDefault) == 0 else {
            throw OwnerFailure("SPAWN_FLAGS")
        }
        var allocated: [UnsafeMutablePointer<CChar>] = []
        var transferred = false
        defer {
            if !transferred {
                for pointer in allocated {
                    free(UnsafeMutableRawPointer(pointer))
                }
            }
        }
        guard let argument0 = strdup(OwnerPaths.ruby) else {
            throw OwnerFailure("SPAWN_STRDUP_ARGV0")
        }
        allocated.append(argument0)
        guard let argument1 = strdup("--disable-gems") else {
            throw OwnerFailure("SPAWN_STRDUP_ARGV1")
        }
        allocated.append(argument1)
        guard let argument2 = strdup("/dev/fd/3") else {
            throw OwnerFailure("SPAWN_STRDUP_ARGV2")
        }
        allocated.append(argument2)
        guard let environment0 = strdup("__CF_USER_TEXT_ENCODING=0x1F5:0x0:0x0")
        else { throw OwnerFailure("SPAWN_STRDUP_ENV0") }
        allocated.append(environment0)
        argv = [argument0, argument1, argument2, nil]
        environment = [environment0, nil]
        transferred = true
    }

    mutating func spawn() throws -> Int32 {
        try ownerRequire(actionsInitialized && attributesInitialized,
                         "SPAWN_RESOURCES_UNINITIALIZED")
        var pid: Int32 = 0
        let result = argv.withUnsafeMutableBufferPointer { arguments in
            environment.withUnsafeMutableBufferPointer { environment in
                OwnerPaths.ruby.withCString { executable in
                    posix_spawn(
                        &pid,
                        executable,
                        &actions,
                        &attributes,
                        arguments.baseAddress,
                        environment.baseAddress)
                }
            }
        }
        guard result == 0 && pid > 0 else {
            throw OwnerFailure("POSIX_SPAWN", errnoValue: result)
        }
        return pid
    }

    mutating func destroy() {
        if actionsInitialized {
            _ = posix_spawn_file_actions_destroy(&actions)
            actionsInitialized = false
        }
        if attributesInitialized {
            _ = posix_spawnattr_destroy(&attributes)
            attributesInitialized = false
        }
        for case let pointer? in argv { free(UnsafeMutableRawPointer(pointer)) }
        for case let pointer? in environment { free(UnsafeMutableRawPointer(pointer)) }
        argv.removeAll(keepingCapacity: false)
        environment.removeAll(keepingCapacity: false)
    }
}

@main
private enum ErgenticsShotAttemptSupervisorMain {
    static func main() {
        guard CommandLine.arguments.count == 1 else { _exit(ownerExitUsage) }
        let supervisor = AttemptSupervisor()
        let result = supervisor.execute()
        _exit(result)
    }
}

private final class AttemptSupervisor {
    private let ioAccounting = IOAccounting()
    private var artifactParentFD: Int32 = -1
    private var buildAParentFD: Int32 = -1
    private var buildARootFD: Int32 = -1
    private var buildAObjectFD: Int32 = -1
    private var buildABundleFD: Int32 = -1
    private var buildReadinessFD: Int32 = -1
    private var buildResultFD: Int32 = -1
    private var captureRootFD: Int32 = -1
    private var controlFreezeFD: Int32 = -1
    private var cwdFD: Int32 = -1
    private var hypothesisRegistrationFD: Int32 = -1
    private var hypothesisReportFD: Int32 = -1
    private var nullFD: Int32 = -1
    private var ownerRootFD: Int32 = -1
    private var pipeReadFD: Int32 = -1
    private var pipeWriteFD: Int32 = -1
    private var rawFD: Int32 = -1
    private var readinessFD: Int32 = -1
    private var rubyFD: Int32 = -1
    private var runnerFD: Int32 = -1
    private var selfFD: Int32 = -1

    private var artifactParentBaseline: VNodeIdentity?
    private var buildAParentBaseline: VNodeIdentity?
    private var buildAObjectBaseline: VNodeIdentity?
    private var buildABundleBaseline: VNodeIdentity?
    private var buildARootBaseline: VNodeIdentity?
    private var buildReadinessBaseline: VNodeIdentity?
    private var buildResultBaseline: VNodeIdentity?
    private var captureInventoryAttempted = false
    private var captureInventoryError: String?
    private var captureInventoryReceipt: CaptureInventory?
    private var captureRevalidationAttempted = false
    private var captureRevalidationError: String?
    private var heldCaptureInventory: HeldCaptureInventory?
    private var childAdmission: ChildAdmission?
    private var partialChildAdmission = PartialChildAdmission()
    private var childPID: Int32 = 0
    private var durableLeaves: [PublishedLeaf] = []
    private var failureCodes: [String] = []
    private var frame: AttemptReadinessFrame?
    private var controlFreezeBaseline: VNodeIdentity?
    private var hypothesisRegistrationBaseline: VNodeIdentity?
    private var hypothesisReportBaseline: VNodeIdentity?
    private var failedIncompletePublication: PublicationFailureFact?
    private var failedIncompletePublicationFD: Int32 = -1
    private var failedIncompletePublicationBytes: [UInt8]?
    private var failedOrdinaryPublication: PublicationFailureFact?
    private var failedOrdinaryPublicationFD: Int32 = -1
    private var failedOrdinaryPublicationBytes: [UInt8]?
    private var lateDurableUnverifiedLeaf: LeafReceipt?
    private var preEndOperations: OwnerJSON?
    private var rawReceipt: RawReceipt?
    private var rawPostWaitRevalidationAttempted = false
    private var rawPostWaitRevalidationError: String?
    private var rawPreEndRevalidationAttempted = false
    private var rawPreEndRevalidationError: String?
    private var readinessBaseline: VNodeIdentity?
    private var rootCreated = false
    private var rootSealAttempted = false
    private var runnerBaseline: VNodeIdentity?
    private var rubyBaseline: VNodeIdentity?
    private var selfAdmission: SelfAdmission?
    private var waitReceipt: WaitReceipt?
    private var writerCloseReceipt: WriterCloseReceipt?

    private var knownStartTicks: UInt64?
    private var knownStartUTC: String?
    private var knownStartTimebaseDenominator: UInt64?
    private var knownStartTimebaseNumerator: UInt64?
    private var knownEndTicks: UInt64?
    private var knownEndUTC: String?
    private var knownEndTimebaseDenominator: UInt64?
    private var knownEndTimebaseNumerator: UInt64?
    private var knownElapsedDenominator: UInt64?
    private var knownElapsedNumerator: UInt64?

    private var a0Entries: UInt64 = 0
    private var combinedEOFCount: UInt64 = 0
    private var drainAttempted = false
    private var ownerEntries: UInt64 = 1
    private var runnerProvenEntries: UInt64 = 0
    private var spawnCallEntries: UInt64 = 0
    private var waitAttempted = false
    private var waitLogicalOperations: UInt64 = 0

    func execute() -> Int32 {
        do {
            try preflight()
            try liveAttempt()
            closeAllBestEffort()
            return 0
        } catch let failure as OwnerFailure {
            failureCodes.append(failure.code)
            containFailure()
            closeAllBestEffort()
            return ownerExitIncomplete
        } catch {
            failureCodes.append("UNCLASSIFIED_SWIFT_ERROR")
            containFailure()
            closeAllBestEffort()
            return ownerExitIncomplete
        }
    }

    private func preflight() throws {
        try validateInitialDescriptors()
        try validateEnvironmentAndCredentials()
        try openArtifactAuthority()
        try openAndValidateReadiness()
        try validateFreshNamespaces()
        try openAndValidateFixedFiles()
        try validateBuildA()
        try validateSelf()
        try finalPreTimingRevalidation()
        try prepareTransport()
    }

    private func validateInitialDescriptors() throws {
        let limit = Darwin.getdtablesize()
        try ownerRequire(limit >= 3, "FD_LIMIT")
        for descriptor in 0..<limit {
            errno = 0
            let result = Darwin.fcntl(descriptor, F_GETFD)
            if descriptor <= STDERR_FILENO {
                try ownerRequire(result >= 0, "FD_REQUIRED_\(descriptor)")
            } else {
                try ownerRequire(result == -1 && errno == EBADF,
                                 "FD_SURPLUS_\(descriptor)")
            }
        }
        let stdinIdentity = try fdStat(STDIN_FILENO, "STDIN")
        let nullIdentity = try statAt(atFDCWD, OwnerPaths.null, flags: atSymlinkNoFollowAny)
        try ownerRequire(stdinIdentity == nullIdentity && stdinIdentity.type == "CHARACTER",
                         "STDIN_NOT_DEV_NULL")
    }

    private func validateEnvironmentAndCredentials() throws {
        guard let first = environ.pointee else { throw OwnerFailure("ENV_EMPTY") }
        try ownerRequire(environ.advanced(by: 1).pointee == nil, "ENV_COUNT")
        try ownerRequire(
            String(cString: first) == "__CF_USER_TEXT_ENCODING=0x1F5:0x0:0x0",
            "ENV_VALUE")
        try ownerRequire(geteuid() == 501 && getuid() == 501 &&
                         getegid() == 20 && getgid() == 20,
                         "CREDENTIALS")
        var cwdBuffer = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard cwdBuffer.withUnsafeMutableBufferPointer({
            Darwin.getcwd($0.baseAddress, $0.count)
        }) != nil else {
            throw OwnerFailure("CWD_GET", errnoValue: errno)
        }
        let cwd = cwdBuffer.withUnsafeBufferPointer { buffer in
            String(cString: buffer.baseAddress!)
        }
        try ownerRequire(cwd == OwnerPaths.cwd, "CWD_PATH")
        cwdFD = try openExisting(
            OwnerPaths.cwd,
            flags: O_RDONLY | oDirectory | oNoFollowAny | oCloseOnExec,
            code: "CWD_OPEN")
        let held = try fdStat(cwdFD, "CWD_HELD")
        let named = try statAt(atFDCWD, OwnerPaths.cwd, flags: atSymlinkNoFollowAny)
        try ownerRequire(held == named && held.type == "DIRECTORY", "CWD_JOIN")
    }

    private func openArtifactAuthority() throws {
        artifactParentFD = try openExisting(
            OwnerPaths.artifactParent,
            flags: O_RDONLY | oDirectory | oNoFollowAny | oCloseOnExec,
            code: "ARTIFACT_PARENT_OPEN")
        let held = try fdStat(artifactParentFD, "ARTIFACT_PARENT")
        let named = try statAt(
            atFDCWD, OwnerPaths.artifactParent, flags: atSymlinkNoFollowAny)
        try ownerRequire(held == named && held.type == "DIRECTORY" &&
                         held.device == OwnerIdentity.artifactParentDevice &&
                         held.inode == OwnerIdentity.artifactParentInode &&
                         held.uid == 501 && held.gid == 20 &&
                         held.permissionMode == 0o755 && held.flags == 0,
                         "ARTIFACT_PARENT_IDENTITY")
        artifactParentBaseline = held
    }

    private func openAndValidateReadiness() throws {
        readinessFD = try openExisting(
            OwnerPaths.runtimeReadiness, code: "READINESS_OPEN")
        let held = try readHeldBytes(
            readinessFD,
            maximumBytes: AttemptReadinessFrame.maximumBytes,
            code: "READINESS_READ", accounting: ioAccounting)
        let parsed: AttemptReadinessFrame
        do {
            parsed = try AttemptReadinessFrame.parse(held.bytes)
        } catch {
            throw OwnerFailure("READINESS_PARSE")
        }
        try ownerRequire(
            parsed.value(for: "control_freeze_sha256") == OwnerIdentity.controlFreezeSHA256,
            "READINESS_FREEZE")
        try ownerRequire(
            parsed.value(for: "runner_source_sha256") == OwnerIdentity.runnerSourceSHA256 &&
            parsed.value(for: "ruby_sha256") == OwnerIdentity.rubySHA256 &&
            parsed.value(for: "build_a_bundle_sha256") == OwnerIdentity.buildABundleSHA256 &&
            parsed.value(for: "build_a_bundle_uuid") == OwnerIdentity.buildABundleUUID,
            "READINESS_STATIC_IDENTITY")
        try ownerRequire(
            parsed.value(for: "launch_contract_sha256") == launchContractSHA256(),
            "READINESS_LAUNCH_CONTRACT")
        readinessBaseline = held.after
        frame = parsed
        try rejoinHeldAbsolute(
            descriptor: readinessFD,
            path: OwnerPaths.runtimeReadiness,
            baseline: held.after,
            code: "READINESS_REJOIN")
    }

    private func launchContractSHA256() -> String {
        let contract =
            "schema=ERGENTICS_R19_OBS11_C2_ATTEMPT_LAUNCH_V10\n" +
            "argv=/usr/bin/ruby\\0--disable-gems\\0/dev/fd/3\n" +
            "environment=__CF_USER_TEXT_ENCODING=0x1F5:0x0:0x0\n" +
            "cwd=/private/var/empty\nstdin=/dev/null\n" +
            "stdout_stderr=one_shared_pipe_write_description\n" +
            "runner_source_fd=3\nchild_count_maximum=1\n" +
            "signals=0\ntimeouts=0\nretries=0\ncleanup=0\n"
        return AttemptSHA256.digestHex(Array(contract.utf8))
    }

    private func validateFreshNamespaces() throws {
        let absentLeaves = [
            OwnerPaths.ownerRootLeaf,
            OwnerPaths.rawCombinedLeaf,
            OwnerPaths.captureRootLeaf,
            OwnerPaths.canonicalResultLeaf,
            OwnerPaths.runnerOuterObservationLeaf,
            OwnerPaths.supervisorOuterCombinedLeaf,
            OwnerPaths.supervisorOuterObservationLeaf,
            OwnerPaths.resultObservationLeaf,
            OwnerPaths.resultDeltaLeaf,
            OwnerPaths.comparatorOuterCombinedLeaf,
            OwnerPaths.comparatorOuterObservationLeaf,
        ]
        for leaf in absentLeaves {
            let present = try statAtIfPresent(artifactParentFD, leaf)
            try ownerRequire(present == nil, "LIVE_NAMESPACE_PRESENT_\(leaf)")
        }
    }

    private func openAndValidateFixedFiles() throws {
        guard let frame else { throw OwnerFailure("FRAME_UNAVAILABLE") }
        controlFreezeFD = try openExisting(OwnerPaths.controlFreeze, code: "FREEZE_OPEN")
        let freeze = try readHeldBytes(
            controlFreezeFD, maximumBytes: 64 * 1_024,
            code: "FREEZE_READ", accounting: ioAccounting)
        try ownerRequire(freeze.sha256 == OwnerIdentity.controlFreezeSHA256,
                         "FREEZE_HASH")
        controlFreezeBaseline = freeze.after
        try rejoinHeldAbsolute(
            descriptor: controlFreezeFD, path: OwnerPaths.controlFreeze,
            baseline: freeze.after, code: "FREEZE_REJOIN")

        buildReadinessFD = try openExisting(
            OwnerPaths.buildReadiness, code: "BUILD_READINESS_OPEN")
        let buildReadiness = try readHeldBytes(
            buildReadinessFD, maximumBytes: 1_048_576,
            code: "BUILD_READINESS_READ", accounting: ioAccounting)
        try ownerRequire(
            buildReadiness.sha256 == frame.value(for: "build_readiness_sha256"),
            "BUILD_READINESS_HASH")
        buildReadinessBaseline = buildReadiness.after
        try rejoinHeldAbsolute(
            descriptor: buildReadinessFD, path: OwnerPaths.buildReadiness,
            baseline: buildReadiness.after, code: "BUILD_READINESS_REJOIN")

        buildResultFD = try openExisting(OwnerPaths.buildResult, code: "BUILD_RESULT_OPEN")
        let buildResult = try readHeldBytes(
            buildResultFD, maximumBytes: 1_048_576,
            code: "BUILD_RESULT_READ", accounting: ioAccounting)
        try ownerRequire(buildResult.sha256 == frame.value(for: "build_result_sha256"),
                         "BUILD_RESULT_HASH")
        buildResultBaseline = buildResult.after
        try rejoinHeldAbsolute(
            descriptor: buildResultFD, path: OwnerPaths.buildResult,
            baseline: buildResult.after, code: "BUILD_RESULT_REJOIN")

        runnerFD = try openExisting(OwnerPaths.runnerSource, code: "RUNNER_OPEN")
        let runner = try readHeldBytes(
            runnerFD, maximumBytes: 262_144,
            code: "RUNNER_READ", accounting: ioAccounting)
        try ownerRequire(runner.sha256 == OwnerIdentity.runnerSourceSHA256,
                         "RUNNER_HASH")
        runnerBaseline = runner.after

        rubyFD = try openExisting(OwnerPaths.ruby, code: "RUBY_OPEN")
        let ruby = try readHeldBytes(
            rubyFD, maximumBytes: executableByteCap,
            code: "RUBY_READ", accounting: ioAccounting)
        try ownerRequire(ruby.sha256 == OwnerIdentity.rubySHA256,
                         "RUBY_HASH")
        try ownerRequire(ruby.after.device == OwnerIdentity.rubyDevice &&
                         ruby.after.inode == OwnerIdentity.rubyInode &&
                         ruby.after.type == "REGULAR",
                         "RUBY_VNODE")
        let rubyMachO = try parseMachO(
            ruby.bytes, requireExecutable: true, requireCodeDirectory: false,
            code: "RUBY_MACHO")
        try ownerRequire(rubyMachO.uuid == OwnerIdentity.rubyUUID &&
                         rubyMachO.sliceOffset == OwnerIdentity.rubyMappedFileOffset,
                         "RUBY_MACHO_IDENTITY")
        rubyBaseline = ruby.after

        hypothesisRegistrationFD = try openExisting(
            OwnerPaths.hypothesisRegistration, code: "HYPOTHESIS_OPEN")
        let registration = try readHeldBytes(
            hypothesisRegistrationFD, maximumBytes: 1_048_576,
            code: "HYPOTHESIS_READ", accounting: ioAccounting)
        guard let registrationBytes = frame.value(for: "hypothesis_registration_bytes")
            .flatMap({ unsignedDecimal($0) }) else {
            throw OwnerFailure("HYPOTHESIS_FRAME_BYTES")
        }
        try ownerRequire(registration.sha256 ==
                         frame.value(for: "hypothesis_registration_sha256") &&
                         registrationBytes == UInt64(registration.bytes.count) &&
                         registration.bytes.last != 0x0a,
                         "HYPOTHESIS_IDENTITY")
        hypothesisRegistrationBaseline = registration.after
        try rejoinHeldAbsolute(
            descriptor: hypothesisRegistrationFD,
            path: OwnerPaths.hypothesisRegistration,
            baseline: registration.after, code: "HYPOTHESIS_REJOIN")

        hypothesisReportFD = try openExisting(
            OwnerPaths.hypothesisReport, code: "HYPOTHESIS_REPORT_OPEN")
        let report = try readHeldBytes(
            hypothesisReportFD, maximumBytes: 1_048_576,
            code: "HYPOTHESIS_REPORT_READ", accounting: ioAccounting)
        guard let reportBytes = frame.value(for: "hypothesis_report_bytes")
            .flatMap({ unsignedDecimal($0) }), report.bytes.last == 0x0a else {
            throw OwnerFailure("HYPOTHESIS_REPORT_FRAME")
        }
        let reportPayload = Array(report.bytes.dropLast())
        try ownerRequire(
            report.sha256 == frame.value(for: "hypothesis_report_file_sha256") &&
            AttemptSHA256.digestHex(reportPayload) ==
                frame.value(for: "hypothesis_report_payload_sha256") &&
            reportBytes == UInt64(report.bytes.count),
            "HYPOTHESIS_REPORT_IDENTITY")
        hypothesisReportBaseline = report.after
        try rejoinHeldAbsolute(
            descriptor: hypothesisReportFD, path: OwnerPaths.hypothesisReport,
            baseline: report.after, code: "HYPOTHESIS_REPORT_REJOIN")
        guard let merkle = frame.value(for: "hypothesis_merkle_root") else {
            throw OwnerFailure("HYPOTHESIS_MERKLE_FRAME")
        }
        try ownerRequire(
            containsBytes(
                reportPayload,
                Array("\"decision\":\"MODEL_CONSISTENT\"".utf8)) &&
            containsBytes(
                reportPayload,
                Array("\"merkle_root_sha256\":\"\(merkle)\"".utf8)),
            "HYPOTHESIS_REPORT_SEMANTICS")
    }

    private func validateBuildA() throws {
        buildAParentFD = try openExisting(
            OwnerPaths.buildAParent,
            flags: O_RDONLY | oDirectory | oNoFollowAny | oCloseOnExec,
            code: "BUILD_A_PARENT_OPEN")
        let parent = try fdStat(buildAParentFD, "BUILD_A_PARENT")
        let parentNamed = try statAt(
            atFDCWD, OwnerPaths.buildAParent, flags: atSymlinkNoFollowAny)
        try ownerRequire(parent == parentNamed && parent.type == "DIRECTORY" &&
                         parent.device == OwnerIdentity.buildAParentDevice &&
                         parent.inode == OwnerIdentity.buildAParentInode &&
                         parent.uid == 0 && parent.gid == 0 &&
                         parent.permissionMode == 0o1777 && parent.flags == 0,
                         "BUILD_A_PARENT_IDENTITY")
        buildAParentBaseline = parent
        buildARootFD = try openAtExisting(
            buildAParentFD,
            OwnerPaths.buildARootLeaf,
            flags: O_RDONLY | oDirectory | oNoFollowAny | oCloseOnExec,
            code: "BUILD_A_ROOT_OPEN")
        let root = try fdStat(buildARootFD, "BUILD_A_ROOT")
        let rootRelative = try statAt(buildAParentFD, OwnerPaths.buildARootLeaf)
        try ownerRequire(root == rootRelative && root.type == "DIRECTORY" &&
                         root.device == OwnerIdentity.buildAParentDevice &&
                         root.inode == OwnerIdentity.buildARootInode &&
                         root.uid == 501 && root.gid == 0 &&
                         root.permissionMode == 0o700 && root.nlink == 4 &&
                         root.flags == 0,
                         "BUILD_A_ROOT_IDENTITY")
        let names = try rawDirectoryNames(buildARootFD, "BUILD_A_ROOT_NAMES")
        try ownerRequire(
            names.map(\.string) == [
                OwnerPaths.buildAObjectLeaf, OwnerPaths.buildABundleLeaf,
            ].sorted(),
            "BUILD_A_ROOT_INVENTORY")

        buildAObjectFD = try openAtExisting(
            buildARootFD, OwnerPaths.buildAObjectLeaf, code: "BUILD_A_OBJECT_OPEN")
        let object = try readHeldBytes(
            buildAObjectFD, maximumBytes: 4_096,
            code: "BUILD_A_OBJECT_READ", accounting: ioAccounting)
        try ownerRequire(object.sha256 == OwnerIdentity.buildAObjectSHA256 &&
                         object.after.type == "REGULAR" &&
                         object.after.device == root.device &&
                         object.after.inode == OwnerIdentity.buildAObjectInode &&
                         object.after.uid == 501 && object.after.gid == 0 &&
                         object.after.permissionMode == 0o400 &&
                         object.after.nlink == 1 && object.after.flags == 0 &&
                         object.after.bytes == OwnerIdentity.buildAObjectBytes,
                         "BUILD_A_OBJECT_IDENTITY")
        buildAObjectBaseline = object.after

        buildABundleFD = try openAtExisting(
            buildARootFD, OwnerPaths.buildABundleLeaf, code: "BUILD_A_BUNDLE_OPEN")
        let bundle = try readHeldBytes(
            buildABundleFD, maximumBytes: 65_536,
            code: "BUILD_A_BUNDLE_READ", accounting: ioAccounting)
        try ownerRequire(bundle.sha256 == OwnerIdentity.buildABundleSHA256 &&
                         bundle.after.type == "REGULAR" &&
                         bundle.after.device == root.device &&
                         bundle.after.inode == OwnerIdentity.buildABundleInode &&
                         bundle.after.uid == 501 && bundle.after.gid == 0 &&
                         bundle.after.permissionMode == 0o400 &&
                         bundle.after.nlink == 1 && bundle.after.flags == 0 &&
                         bundle.after.bytes == OwnerIdentity.buildABundleBytes,
                         "BUILD_A_BUNDLE_IDENTITY")
        let macho = try parseMachO(
            bundle.bytes,
            requireExecutable: false,
            requireCodeDirectory: true,
            code: "BUILD_A_BUNDLE_MACHO")
        try ownerRequire(macho.uuid == OwnerIdentity.buildABundleUUID,
                         "BUILD_A_BUNDLE_UUID")
        buildABundleBaseline = bundle.after
        buildARootBaseline = root
        try ownerRequire(
            Set([root.inode, object.after.inode, bundle.after.inode]).count == 3,
            "BUILD_A_VNODE_DISTINCT")
    }

    private func validateSelf() throws {
        guard let frame else { throw OwnerFailure("FRAME_UNAVAILABLE_SELF") }
        let pid = getpid()
        let process = try processIdentity(pid, "SELF_PROCESS")
        try ownerRequire(process.pid == pid && process.ppid == getppid() &&
                         process.pgid == getpgrp() && process.session == getsid(0) &&
                         process.uid == UInt32(geteuid()) &&
                         process.gid == UInt32(getegid()) &&
                         process.ruid == UInt32(getuid()) &&
                         process.rgid == UInt32(getgid()),
                         "SELF_PROCESS_JOIN")
        let path = try processPath(pid, "SELF_PATH")
        guard let dyldNamePointer = ownerDyldGetImageName(0),
              let dyldHeader = ownerDyldGetImageHeader(0) else {
            throw OwnerFailure("SELF_DYLD")
        }
        let dyldName = String(cString: dyldNamePointer)
        try ownerRequire(path == dyldName, "SELF_PATH_DYLD")
        selfFD = try openExisting(path, code: "SELF_OPEN")
        let executable = try readHeldBytes(
            selfFD, maximumBytes: executableByteCap,
            code: "SELF_READ", accounting: ioAccounting)
        guard let expectedBytesText = frame.value(for: "supervisor_bytes"),
              let expectedBytes = unsignedDecimal(expectedBytesText),
              let expectedDeviceText = frame.value(for: "supervisor_device"),
              let expectedDevice = unsignedDecimal(expectedDeviceText),
              let expectedInodeText = frame.value(for: "supervisor_inode"),
              let expectedInode = unsignedDecimal(expectedInodeText)
        else {
            throw OwnerFailure("SELF_FRAME_NUMERIC")
        }
        try ownerRequire(executable.sha256 == frame.value(for: "supervisor_sha256") &&
                         UInt64(executable.bytes.count) == expectedBytes &&
                         executable.after.device >= 0 &&
                         UInt64(executable.after.device) == expectedDevice &&
                         executable.after.inode == expectedInode &&
                         executable.after.type == "REGULAR" &&
                         executable.after.uid == 501 &&
                         executable.after.permissionMode == 0o500 &&
                         executable.after.nlink == 1 && executable.after.flags == 0,
                         "SELF_EXECUTABLE_IDENTITY")
        let macho = try parseMachO(
            executable.bytes,
            requireExecutable: true,
            requireCodeDirectory: true,
            code: "SELF_MACHO")
        try ownerRequire(macho.sliceOffset == 0 &&
                         macho.uuid == frame.value(for: "supervisor_uuid") &&
                         macho.cdhash == frame.value(for: "supervisor_cdhash"),
                         "SELF_MACHO_IDENTITY")
        let headerAddress = UInt64(UInt(bitPattern: dyldHeader))
        let mapping = try mappedRegionContaining(
            pid: pid,
            address: headerAddress,
            expectedPath: path,
            expected: executable.after,
            expectedFileOffset: 0,
            code: "SELF_MAPPING")
        var groupCount = Darwin.getgroups(0, nil)
        try ownerRequire(groupCount >= 0 && groupCount <= 128, "SELF_GROUP_COUNT")
        var groups = [gid_t](repeating: 0, count: Int(groupCount))
        if groupCount > 0 {
            groupCount = groups.withUnsafeMutableBufferPointer {
                Darwin.getgroups(groupCount, $0.baseAddress)
            }
            try ownerRequire(Int(groupCount) == groups.count, "SELF_GROUP_READ")
        }
        selfAdmission = SelfAdmission(
            executableMachO: macho,
            executablePath: path,
            executableVNode: executable.after,
            groups: groups.map { UInt32($0) },
            mapping: mapping,
            process: process)
    }

    private func finalPreTimingRevalidation() throws {
        guard let readinessBaseline, let runnerBaseline, let rubyBaseline,
              let controlFreezeBaseline, let buildReadinessBaseline,
              let buildResultBaseline, let hypothesisRegistrationBaseline,
              let hypothesisReportBaseline, let buildAParentBaseline,
              let buildARootBaseline, let buildAObjectBaseline,
              let buildABundleBaseline, let artifactParentBaseline,
              let selfAdmission else {
            throw OwnerFailure("FINAL_REVALIDATION_BASELINE")
        }
        try validateFreshNamespaces()
        try rejoinHeldAbsolute(
            descriptor: readinessFD,
            path: OwnerPaths.runtimeReadiness,
            baseline: readinessBaseline,
            code: "FINAL_READINESS")
        try rejoinHeldAbsolute(
            descriptor: runnerFD,
            path: OwnerPaths.runnerSource,
            baseline: runnerBaseline,
            code: "FINAL_RUNNER")
        try rejoinHeldAbsolute(
            descriptor: rubyFD,
            path: OwnerPaths.ruby,
            baseline: rubyBaseline,
            code: "FINAL_RUBY")
        try rejoinHeldAbsolute(
            descriptor: controlFreezeFD, path: OwnerPaths.controlFreeze,
            baseline: controlFreezeBaseline, code: "FINAL_FREEZE")
        try rejoinHeldAbsolute(
            descriptor: buildReadinessFD, path: OwnerPaths.buildReadiness,
            baseline: buildReadinessBaseline, code: "FINAL_BUILD_READINESS")
        try rejoinHeldAbsolute(
            descriptor: buildResultFD, path: OwnerPaths.buildResult,
            baseline: buildResultBaseline, code: "FINAL_BUILD_RESULT")
        try rejoinHeldAbsolute(
            descriptor: hypothesisRegistrationFD,
            path: OwnerPaths.hypothesisRegistration,
            baseline: hypothesisRegistrationBaseline,
            code: "FINAL_HYPOTHESIS")
        try rejoinHeldAbsolute(
            descriptor: hypothesisReportFD, path: OwnerPaths.hypothesisReport,
            baseline: hypothesisReportBaseline,
            code: "FINAL_HYPOTHESIS_REPORT")
        try rejoinHeld(
            descriptor: buildAObjectFD,
            directoryFD: buildARootFD,
            leaf: OwnerPaths.buildAObjectLeaf,
            baseline: buildAObjectBaseline,
            code: "FINAL_BUILD_A_OBJECT")
        try rejoinHeld(
            descriptor: buildABundleFD,
            directoryFD: buildARootFD,
            leaf: OwnerPaths.buildABundleLeaf,
            baseline: buildABundleBaseline,
            code: "FINAL_BUILD_A_BUNDLE")
        let rootHeld = try fdStat(buildARootFD, "FINAL_BUILD_A_ROOT_HELD")
        let rootRelative = try statAt(buildAParentFD, OwnerPaths.buildARootLeaf)
        try ownerRequire(rootHeld == buildARootBaseline &&
                         rootRelative == buildARootBaseline,
                         "FINAL_BUILD_A_ROOT")
        let buildParentHeld = try fdStat(buildAParentFD, "FINAL_BUILD_A_PARENT_HELD")
        let buildParentNamed = try statAt(
            atFDCWD, OwnerPaths.buildAParent, flags: atSymlinkNoFollowAny)
        try ownerRequire(buildParentHeld == buildParentNamed &&
                         sameDirectoryAuthority(
                            buildParentHeld, buildAParentBaseline),
                         "FINAL_BUILD_A_PARENT")
        let finalBuildNames = try rawDirectoryNames(
            buildARootFD, "FINAL_BUILD_A_NAMES").map(\.string)
        try ownerRequire(
            finalBuildNames ==
                [OwnerPaths.buildAObjectLeaf, OwnerPaths.buildABundleLeaf].sorted(),
            "FINAL_BUILD_A_INVENTORY")
        let parentHeld = try fdStat(artifactParentFD, "FINAL_ARTIFACT_PARENT")
        let parentNamed = try statAt(
            atFDCWD, OwnerPaths.artifactParent, flags: atSymlinkNoFollowAny)
        try ownerRequire(parentHeld == parentNamed &&
                         parentHeld.device == artifactParentBaseline.device &&
                         parentHeld.inode == artifactParentBaseline.inode &&
                         parentHeld.uid == artifactParentBaseline.uid &&
                         parentHeld.gid == artifactParentBaseline.gid &&
                         parentHeld.permissionMode == artifactParentBaseline.permissionMode &&
                         parentHeld.flags == artifactParentBaseline.flags,
                         "FINAL_ARTIFACT_PARENT_DRIFT")
        try rejoinHeldAbsolute(
            descriptor: selfFD,
            path: selfAdmission.executablePath,
            baseline: selfAdmission.executableVNode,
            code: "FINAL_SELF")
    }

    private func prepareTransport() throws {
        var descriptors = [Int32](repeating: -1, count: 2)
        let pipeResult = descriptors.withUnsafeMutableBufferPointer {
            Darwin.pipe($0.baseAddress)
        }
        try ownerRequire(pipeResult == 0 && descriptors[0] >= 3 && descriptors[1] >= 3,
                         "PIPE_CREATE")
        pipeReadFD = descriptors[0]
        pipeWriteFD = descriptors[1]
        guard Darwin.fcntl(pipeReadFD, F_SETFD, FD_CLOEXEC) == 0,
              Darwin.fcntl(pipeWriteFD, F_SETFD, FD_CLOEXEC) == 0 else {
            throw OwnerFailure("PIPE_CLOEXEC", errnoValue: errno)
        }
        nullFD = try openExisting(OwnerPaths.null, code: "NULL_OPEN")
        try ownerRequire(runnerFD != 3 && nullFD != 3 &&
                         pipeReadFD != 3 && pipeWriteFD != 3,
                         "CHILD_FD3_SOURCE_COLLISION")
    }

    private func revalidateRawReceipt(_ receipt: RawReceipt, code: String) throws {
        guard let expected = receipt.vnode else {
            throw OwnerFailure(code + "_VNODE_MISSING")
        }
        let held = try readHeldBytes(
            rawFD, maximumBytes: rawRetainedByteCap,
            code: code + "_BYTES", accounting: ioAccounting)
        let relative = try statAt(artifactParentFD, OwnerPaths.rawCombinedLeaf)
        let named = try statAt(
            atFDCWD, OwnerPaths.rawCombined, flags: atSymlinkNoFollowAny)
        let lfCount = held.bytes.reduce(UInt64(0)) {
            $0 + ($1 == 0x0a ? 1 : 0)
        }
        try ownerRequire(
            held.before == expected && held.after == expected &&
            relative == expected && named == expected &&
            UInt64(held.bytes.count) == receipt.retainedPrefixBytes &&
            lfCount == receipt.retainedPrefixLFCount &&
            held.sha256 == receipt.retainedPrefixSHA256,
            code + "_JOIN")
    }

    private func revalidateRawAfterWaitOnce() throws {
        try ownerRequire(
            waitAttempted && !rawPostWaitRevalidationAttempted,
            "RAW_POSTWAIT_REVALIDATION_STATE")
        rawPostWaitRevalidationAttempted = true
        guard let rawReceipt else {
            rawPostWaitRevalidationError = "RAW_POSTWAIT_RECEIPT_MISSING"
            throw OwnerFailure("RAW_POSTWAIT_RECEIPT_MISSING")
        }
        do {
            try revalidateRawReceipt(rawReceipt, code: "RAW_POSTWAIT")
        } catch let failure as OwnerFailure {
            rawPostWaitRevalidationError = failure.code
            throw failure
        } catch {
            rawPostWaitRevalidationError = "RAW_POSTWAIT_UNCLASSIFIED"
            throw OwnerFailure("RAW_POSTWAIT_UNCLASSIFIED")
        }
    }

    private func revalidateHeldCaptureInventory(
        _ heldInventory: HeldCaptureInventory,
        code: String
    ) throws {
        let receipt = heldInventory.receipt
        let names = try rawDirectoryNames(captureRootFD, code + "_NAMES")
        try ownerRequire(
            names.map(\.string) == receipt.entries.map(\.name) &&
            heldInventory.leaves.count == receipt.entries.count,
            code + "_NAME_JOIN")
        var entries: [LeafReceipt] = []
        var inodes = Set<UInt64>()
        var tsv: [UInt8] = []
        for index in heldInventory.leaves.indices {
            let heldLeaf = heldInventory.leaves[index]
            let expected = receipt.entries[index]
            try ownerRequire(
                heldLeaf.descriptor >= 3 && heldLeaf.receipt.name == expected.name &&
                heldLeaf.receipt.sha256 == expected.sha256 &&
                heldLeaf.receipt.vnode == expected.vnode,
                code + "_HELD_TABLE")
            let held = try readHeldBytes(
                heldLeaf.descriptor, maximumBytes: captureLeafByteCap,
                code: code + "_LEAF_BYTES", accounting: ioAccounting)
            let relative = try statAt(captureRootFD, expected.name)
            try ownerRequire(
                held.before == expected.vnode && held.after == expected.vnode &&
                relative == expected.vnode && held.sha256 == expected.sha256 &&
                Int64(held.bytes.count) == expected.vnode.bytes &&
                expected.vnode.inode != receipt.root.inode &&
                inodes.insert(expected.vnode.inode).inserted,
                code + "_LEAF_JOIN")
            entries.append(expected)
            let row = [
                expected.name,
                String(expected.vnode.device),
                String(expected.vnode.inode),
                octalMode(expected.vnode.permissionMode),
                String(expected.vnode.nlink),
                String(expected.vnode.bytes),
                expected.sha256,
            ].joined(separator: "\t") + "\n"
            tsv.append(contentsOf: row.utf8)
        }
        let rootHeld = try fdStat(captureRootFD, code + "_ROOT_HELD")
        let rootRelative = try statAt(artifactParentFD, OwnerPaths.captureRootLeaf)
        let rootNamed = try statAt(
            atFDCWD, OwnerPaths.captureRoot, flags: atSymlinkNoFollowAny)
        let expectedMode: UInt16 = receipt.terminalState == "SEALED_0500"
            ? 0o500 : 0o700
        try ownerRequire(
            (receipt.terminalState == "SEALED_0500" ||
             receipt.terminalState == "RETAINED_INCOMPLETE_0700") &&
            rootHeld == receipt.root && rootRelative == receipt.root &&
            rootNamed == receipt.root && rootHeld.permissionMode == expectedMode &&
            rootHeld.nlink == UInt16(2 + entries.count),
            code + "_ROOT_JOIN")
        let supervisorObject = OwnerJSON.object([
            ("entries", .array(entries.map { entry in
                .object([
                    ("bytes", .int(entry.vnode.bytes)),
                    ("device", .int(entry.vnode.device)),
                    ("flags", .uint(UInt64(entry.vnode.flags))),
                    ("gid", .uint(UInt64(entry.vnode.gid))),
                    ("inode", .uint(entry.vnode.inode)),
                    ("mode", .string(octalMode(entry.vnode.permissionMode))),
                    ("name", .string(entry.name)),
                    ("nlink", .uint(UInt64(entry.vnode.nlink))),
                    ("sha256", .string(entry.sha256)),
                    ("type", .string(entry.vnode.type)),
                    ("uid", .uint(UInt64(entry.vnode.uid))),
                ])
            })),
            ("names", .array(entries.map { .string($0.name) })),
        ])
        try ownerRequire(
            AttemptSHA256.digestHex(try supervisorObject.encoded()) ==
                receipt.supervisorManifestSHA256 &&
            AttemptSHA256.digestHex(tsv) == receipt.v9TSVManifestSHA256,
            code + "_MANIFEST_JOIN")
    }

    private func closeHeldCaptureDescriptorsBestEffort() {
        guard var inventory = heldCaptureInventory else { return }
        for index in inventory.leaves.indices {
            closeDescriptorBestEffort(&inventory.leaves[index].descriptor)
        }
        heldCaptureInventory = inventory
    }

    private func liveAttempt() throws {
        guard let frame, let selfAdmission,
              let artifactParentBaseline else {
            throw OwnerFailure("LIVE_PREFLIGHT_STATE")
        }
        var timebaseStart = mach_timebase_info_data_t()
        try ownerRequire(
            mach_timebase_info(&timebaseStart) == KERN_SUCCESS &&
            timebaseStart.numer > 0 && timebaseStart.denom > 0,
            "START_TIMEBASE")
        let startUTC = try utcTimestamp("START_UTC")
        knownStartTimebaseNumerator = UInt64(timebaseStart.numer)
        knownStartTimebaseDenominator = UInt64(timebaseStart.denom)
        knownStartUTC = startUTC

        var spawnResources = SpawnResources()
        defer { spawnResources.destroy() }
        try spawnResources.initialize(
            sourceFD: runnerFD,
            nullFD: nullFD,
            pipeReadFD: pipeReadFD,
            pipeWriteFD: pipeWriteFD)

        let rootLeafBytes = Array(OwnerPaths.ownerRootLeaf.utf8CString)
        let startBoundary = rootLeafBytes.withUnsafeBufferPointer {
            ownerStartBoundary(parentFD: artifactParentFD, rootLeaf: $0.baseAddress!)
        }
        a0Entries = 1
        knownStartTicks = startBoundary.ticks
        rootCreated = startBoundary.mkdirResult == 0
        try ownerRequire(startBoundary.mkdirResult == 0,
                         "A0_MKDIR_\(startBoundary.errnoValue)")
        ownerRootFD = try openAtExisting(
            artifactParentFD,
            OwnerPaths.ownerRootLeaf,
            flags: O_RDONLY | oDirectory | oNoFollowAny | oCloseOnExec,
            code: "OWNER_ROOT_OPEN")
        let initialRoot = try fdStat(ownerRootFD, "OWNER_ROOT_INITIAL")
        let initialRelative = try statAt(artifactParentFD, OwnerPaths.ownerRootLeaf)
        let initialNamed = try statAt(
            atFDCWD, OwnerPaths.ownerRoot, flags: atSymlinkNoFollowAny)
        try ownerRequire(initialRoot == initialRelative && initialRoot == initialNamed &&
                         initialRoot.type == "DIRECTORY" &&
                         initialRoot.device == artifactParentBaseline.device &&
                         initialRoot.uid == 501 && initialRoot.gid == 20 &&
                         initialRoot.permissionMode == 0o700 &&
                         initialRoot.nlink == 2 && initialRoot.flags == 0,
                         "OWNER_ROOT_INITIAL_IDENTITY")
        try syncDescriptor(
            ownerRootFD, "OWNER_ROOT_INITIAL", accounting: ioAccounting)
        try syncDescriptor(
            artifactParentFD, "ARTIFACT_PARENT_AFTER_ROOT", accounting: ioAccounting)

        try createRawLeaf()
        let startRecord = try makeStartRecord(
            frame: frame,
            selfAdmission: selfAdmission,
            startTicks: startBoundary.ticks,
            timebase: timebaseStart,
            startUTC: startUTC)
        let startLeaf = try publishOwnerLeaf(
            "00-start.json", bytes: startRecord, previousSHA256: nil)
        durableLeaves.append(startLeaf)

        spawnCallEntries = 1
        childPID = try spawnResources.spawn()
        try closeParentWriterOnce()
        closeDescriptorBestEffort(&nullFD)

        var childJoinFailure: OwnerFailure?
        do {
            childAdmission = try validateChild(childPID)
            runnerProvenEntries = 1
        } catch let failure as OwnerFailure {
            childJoinFailure = failure
            failureCodes.append(failure.code)
        } catch {
            childJoinFailure = OwnerFailure("CHILD_JOIN_UNCLASSIFIED")
            failureCodes.append("CHILD_JOIN_UNCLASSIFIED")
        }

        rawReceipt = try drainAndFinalizeRaw()
        waitReceipt = try waitForChild()
        try revalidateRawAfterWaitOnce()
        if let childJoinFailure { throw childJoinFailure }
        guard let rawReceipt, rawReceipt.complete,
              let waitReceipt, let childAdmission else {
            throw OwnerFailure("TRANSPORT_INCOMPLETE")
        }

        try finalPostChildAuthorityRevalidation()

        captureRootFD = try openAtExisting(
            artifactParentFD,
            OwnerPaths.captureRootLeaf,
            flags: O_RDONLY | oDirectory | oNoFollowAny | oCloseOnExec,
            code: "CAPTURE_ROOT_OPEN")
        captureInventoryAttempted = true
        let heldInventory: HeldCaptureInventory
        do {
            heldInventory = try captureInventory(
                artifactParentFD: artifactParentFD,
                captureRootFD: captureRootFD,
                code: "CAPTURE_FINAL",
                accounting: ioAccounting)
        } catch let failure as OwnerFailure {
            captureInventoryError = failure.code
            throw failure
        } catch {
            captureInventoryError = "CAPTURE_INVENTORY_UNCLASSIFIED"
            throw OwnerFailure("CAPTURE_INVENTORY_UNCLASSIFIED")
        }
        heldCaptureInventory = heldInventory
        let inventory = heldInventory.receipt
        captureInventoryReceipt = inventory

        var captureNameArena: [CChar] = []
        var captureLeafJoins: [BoundaryLeafJoin] = []
        for leaf in heldInventory.leaves {
            let offset = captureNameArena.count
            captureNameArena.append(contentsOf: leaf.receipt.name.utf8.map {
                CChar(bitPattern: $0)
            })
            captureNameArena.append(0)
            captureLeafJoins.append(BoundaryLeafJoin(
                descriptor: leaf.descriptor,
                nameOffset: offset,
                expected: BoundaryVNode(leaf.receipt.vnode)))
        }
        try ownerRequire(
            captureLeafJoins.count == inventory.entries.count &&
            captureLeafJoins.count <= 128,
            "CAPTURE_BOUNDARY_TABLE")
        let rawLeafBytes = Array(OwnerPaths.rawCombinedLeaf.utf8CString)
        let rawPathBytes = Array(OwnerPaths.rawCombined.utf8CString)
        let captureLeafBytes = Array(OwnerPaths.captureRootLeaf.utf8CString)
        let capturePathBytes = Array(OwnerPaths.captureRoot.utf8CString)
        guard let rawVNode = rawReceipt.vnode else {
            throw OwnerFailure("RAW_BOUNDARY_VNODE")
        }
        rawPreEndRevalidationAttempted = true
        do {
            try revalidateRawReceipt(rawReceipt, code: "RAW_PREEND")
        } catch let failure as OwnerFailure {
            rawPreEndRevalidationError = failure.code
            throw failure
        } catch {
            rawPreEndRevalidationError = "RAW_PREEND_UNCLASSIFIED"
            throw OwnerFailure("RAW_PREEND_UNCLASSIFIED")
        }
        captureRevalidationAttempted = true
        do {
            try revalidateHeldCaptureInventory(heldInventory, code: "CAPTURE_PREEND")
        } catch let failure as OwnerFailure {
            captureRevalidationError = failure.code
            throw failure
        } catch {
            captureRevalidationError = "CAPTURE_REVALIDATION_UNCLASSIFIED"
            throw OwnerFailure("CAPTURE_REVALIDATION_UNCLASSIFIED")
        }
        preEndOperations = operationCountersJSON()
        let endBoundary = rawLeafBytes.withUnsafeBufferPointer { rawLeaf in
            rawPathBytes.withUnsafeBufferPointer { rawPath in
                captureLeafBytes.withUnsafeBufferPointer { captureLeaf in
                    capturePathBytes.withUnsafeBufferPointer { capturePath in
                        captureLeafJoins.withUnsafeBufferPointer { leafJoins in
                            captureNameArena.withUnsafeBufferPointer { nameArena in
                                ownerEndBoundary(
                                    parentFD: artifactParentFD,
                                    rawFD: rawFD,
                                    rawLeaf: rawLeaf.baseAddress!,
                                    rawAbsolutePath: rawPath.baseAddress!,
                                    rawExpected: BoundaryVNode(rawVNode),
                                    captureRootFD: captureRootFD,
                                    captureRootLeaf: captureLeaf.baseAddress!,
                                    captureRootAbsolutePath: capturePath.baseAddress!,
                                    captureRootExpected: BoundaryVNode(inventory.root),
                                    captureLeafJoins: leafJoins.baseAddress,
                                    captureLeafCount: leafJoins.count,
                                    captureNameArena: nameArena.baseAddress)
                            }
                        }
                    }
                }
            }
        }
        try ownerRequire(endBoundary.matched, "END_BOUNDARY_REJOIN")
        knownEndTicks = endBoundary.ticks
        let endUTC = try utcTimestamp("END_UTC")
        knownEndUTC = endUTC
        var timebaseEnd = mach_timebase_info_data_t()
        let endTimebaseResult = mach_timebase_info(&timebaseEnd)
        if endTimebaseResult == KERN_SUCCESS {
            knownEndTimebaseNumerator = UInt64(timebaseEnd.numer)
            knownEndTimebaseDenominator = UInt64(timebaseEnd.denom)
        }
        try ownerRequire(
            endTimebaseResult == KERN_SUCCESS &&
            timebaseEnd.numer > 0 && timebaseEnd.denom > 0 &&
            timebaseEnd.numer == timebaseStart.numer &&
            timebaseEnd.denom == timebaseStart.denom,
            "END_TIMEBASE")
        let elapsed: AttemptRationalNanoseconds
        do {
            elapsed = try AttemptRationalNanoseconds.checkedElapsed(
                startTicks: startBoundary.ticks,
                endTicks: endBoundary.ticks,
                timebaseNumerator: UInt64(timebaseStart.numer),
                timebaseDenominator: UInt64(timebaseStart.denom))
        } catch {
            throw OwnerFailure("ELAPSED_RATIONAL")
        }
        knownElapsedNumerator = elapsed.numerator
        knownElapsedDenominator = elapsed.denominator
        closeHeldCaptureDescriptorsBestEffort()

        let conservationRecord = try makeConservationRecord(
            startLeaf: startLeaf,
            raw: rawReceipt,
            wait: waitReceipt,
            child: childAdmission,
            inventory: inventory)
        let conservationLeaf = try publishOwnerLeaf(
            "01-conservation.json", bytes: conservationRecord,
            previousSHA256: startLeaf.receipt.sha256)
        durableLeaves.append(conservationLeaf)
        let endRecord = try makeEndRecord(
            conservationLeaf: conservationLeaf,
            startTicks: startBoundary.ticks,
            endTicks: endBoundary.ticks,
            startUTC: startUTC,
            endUTC: endUTC,
            timebase: timebaseEnd,
            elapsed: elapsed)
        let endLeaf = try publishOwnerLeaf(
            "02-end.json", bytes: endRecord,
            previousSHA256: conservationLeaf.receipt.sha256)
        durableLeaves.append(endLeaf)
        try sealOwnerRoot(success: true)
    }

    private func finalPostChildAuthorityRevalidation() throws {
        guard let frame, let readinessBaseline, let runnerBaseline,
              let rubyBaseline, let controlFreezeBaseline,
              let buildReadinessBaseline, let buildResultBaseline,
              let hypothesisRegistrationBaseline, let hypothesisReportBaseline,
              let buildAParentBaseline, let buildARootBaseline,
              let buildAObjectBaseline, let buildABundleBaseline,
              let artifactParentBaseline, let selfAdmission else {
            throw OwnerFailure("POSTCHILD_BASELINE")
        }
        try ownerRequire(frame.fields.count == AttemptReadinessFrame.orderedKeys.count,
                         "POSTCHILD_FRAME_MEMORY")
        try rejoinHeldAbsolute(
            descriptor: readinessFD,
            path: OwnerPaths.runtimeReadiness,
            baseline: readinessBaseline,
            code: "POSTCHILD_READINESS_JOIN")

        let runner = try readHeldBytes(
            runnerFD, maximumBytes: 262_144,
            code: "POSTCHILD_RUNNER", accounting: ioAccounting)
        try ownerRequire(runner.after == runnerBaseline &&
                         runner.sha256 == OwnerIdentity.runnerSourceSHA256,
                         "POSTCHILD_RUNNER_DRIFT")
        try rejoinHeldAbsolute(
            descriptor: runnerFD,
            path: OwnerPaths.runnerSource,
            baseline: runnerBaseline,
            code: "POSTCHILD_RUNNER_JOIN")

        let ruby = try readHeldBytes(
            rubyFD, maximumBytes: executableByteCap,
            code: "POSTCHILD_RUBY", accounting: ioAccounting)
        try ownerRequire(ruby.after == rubyBaseline &&
                         ruby.sha256 == OwnerIdentity.rubySHA256,
                         "POSTCHILD_RUBY_DRIFT")
        try rejoinHeldAbsolute(
            descriptor: rubyFD,
            path: OwnerPaths.ruby,
            baseline: rubyBaseline,
            code: "POSTCHILD_RUBY_JOIN")

        let object = try readHeldBytes(
            buildAObjectFD, maximumBytes: 4_096,
            code: "POSTCHILD_BUILD_A_OBJECT", accounting: ioAccounting)
        try ownerRequire(object.after == buildAObjectBaseline &&
                         object.sha256 == OwnerIdentity.buildAObjectSHA256,
                         "POSTCHILD_BUILD_A_OBJECT_DRIFT")
        let bundle = try readHeldBytes(
            buildABundleFD, maximumBytes: 65_536,
            code: "POSTCHILD_BUILD_A_BUNDLE", accounting: ioAccounting)
        try ownerRequire(bundle.after == buildABundleBaseline &&
                         bundle.sha256 == OwnerIdentity.buildABundleSHA256,
                         "POSTCHILD_BUILD_A_BUNDLE_DRIFT")
        try rejoinHeld(
            descriptor: buildAObjectFD,
            directoryFD: buildARootFD,
            leaf: OwnerPaths.buildAObjectLeaf,
            baseline: buildAObjectBaseline,
            code: "POSTCHILD_BUILD_A_OBJECT_JOIN")
        try rejoinHeld(
            descriptor: buildABundleFD,
            directoryFD: buildARootFD,
            leaf: OwnerPaths.buildABundleLeaf,
            baseline: buildABundleBaseline,
            code: "POSTCHILD_BUILD_A_BUNDLE_JOIN")

        let executable = try readHeldBytes(
            selfFD, maximumBytes: executableByteCap,
            code: "POSTCHILD_SELF", accounting: ioAccounting)
        try ownerRequire(executable.after == selfAdmission.executableVNode &&
                         executable.sha256 == frame.value(for: "supervisor_sha256"),
                         "POSTCHILD_SELF_DRIFT")
        try rejoinHeldAbsolute(
            descriptor: selfFD,
            path: selfAdmission.executablePath,
            baseline: selfAdmission.executableVNode,
            code: "POSTCHILD_SELF_JOIN")

        let freeze = try readHeldBytes(
            controlFreezeFD, maximumBytes: 64 * 1_024,
            code: "POSTCHILD_FREEZE", accounting: ioAccounting)
        try ownerRequire(freeze.sha256 == OwnerIdentity.controlFreezeSHA256,
                         "POSTCHILD_FREEZE_DRIFT")
        let buildReadiness = try readHeldBytes(
            buildReadinessFD, maximumBytes: 1_048_576,
            code: "POSTCHILD_BUILD_READINESS", accounting: ioAccounting)
        let buildResult = try readHeldBytes(
            buildResultFD, maximumBytes: 1_048_576,
            code: "POSTCHILD_BUILD_RESULT", accounting: ioAccounting)
        try ownerRequire(
            buildReadiness.sha256 == frame.value(for: "build_readiness_sha256") &&
            buildResult.sha256 == frame.value(for: "build_result_sha256"),
            "POSTCHILD_BUILD_RECORD_DRIFT")
        let registration = try readHeldBytes(
            hypothesisRegistrationFD, maximumBytes: 1_048_576,
            code: "POSTCHILD_HYPOTHESIS", accounting: ioAccounting)
        let report = try readHeldBytes(
            hypothesisReportFD, maximumBytes: 1_048_576,
            code: "POSTCHILD_HYPOTHESIS_REPORT", accounting: ioAccounting)
        try ownerRequire(
            registration.sha256 == frame.value(for: "hypothesis_registration_sha256") &&
            report.sha256 == frame.value(for: "hypothesis_report_file_sha256"),
            "POSTCHILD_HYPOTHESIS_DRIFT")
        try rejoinHeldAbsolute(
            descriptor: controlFreezeFD, path: OwnerPaths.controlFreeze,
            baseline: controlFreezeBaseline, code: "POSTCHILD_FREEZE_JOIN")
        try rejoinHeldAbsolute(
            descriptor: buildReadinessFD, path: OwnerPaths.buildReadiness,
            baseline: buildReadinessBaseline,
            code: "POSTCHILD_BUILD_READINESS_JOIN")
        try rejoinHeldAbsolute(
            descriptor: buildResultFD, path: OwnerPaths.buildResult,
            baseline: buildResultBaseline, code: "POSTCHILD_BUILD_RESULT_JOIN")
        try rejoinHeldAbsolute(
            descriptor: hypothesisRegistrationFD,
            path: OwnerPaths.hypothesisRegistration,
            baseline: hypothesisRegistrationBaseline,
            code: "POSTCHILD_HYPOTHESIS_JOIN")
        try rejoinHeldAbsolute(
            descriptor: hypothesisReportFD, path: OwnerPaths.hypothesisReport,
            baseline: hypothesisReportBaseline,
            code: "POSTCHILD_HYPOTHESIS_REPORT_JOIN")
        let buildParentHeld = try fdStat(buildAParentFD, "POSTCHILD_BUILD_PARENT_HELD")
        let buildParentNamed = try statAt(
            atFDCWD, OwnerPaths.buildAParent, flags: atSymlinkNoFollowAny)
        try ownerRequire(buildParentHeld == buildParentNamed &&
                         sameDirectoryAuthority(
                            buildParentHeld, buildAParentBaseline),
                         "POSTCHILD_BUILD_PARENT_JOIN")
        let buildRootHeld = try fdStat(buildARootFD, "POSTCHILD_BUILD_ROOT_HELD")
        let buildRootRelative = try statAt(buildAParentFD, OwnerPaths.buildARootLeaf)
        try ownerRequire(buildRootHeld == buildARootBaseline &&
                         buildRootRelative == buildARootBaseline,
                         "POSTCHILD_BUILD_ROOT_JOIN")
        let buildNames = try rawDirectoryNames(
            buildARootFD, "POSTCHILD_BUILD_INVENTORY").map(\.string)
        try ownerRequire(
            buildNames ==
                [OwnerPaths.buildAObjectLeaf, OwnerPaths.buildABundleLeaf].sorted(),
            "POSTCHILD_BUILD_INVENTORY")
        let artifactHeld = try fdStat(artifactParentFD, "POSTCHILD_ARTIFACT_HELD")
        let artifactNamed = try statAt(
            atFDCWD, OwnerPaths.artifactParent, flags: atSymlinkNoFollowAny)
        try ownerRequire(
            artifactHeld == artifactNamed &&
            artifactHeld.device == artifactParentBaseline.device &&
            artifactHeld.inode == artifactParentBaseline.inode &&
            artifactHeld.uid == artifactParentBaseline.uid &&
            artifactHeld.gid == artifactParentBaseline.gid &&
            artifactHeld.permissionMode == artifactParentBaseline.permissionMode &&
            artifactHeld.flags == artifactParentBaseline.flags,
            "POSTCHILD_ARTIFACT_PARENT_JOIN")
    }

    private func createRawLeaf() throws {
        let existingRaw = try statAtIfPresent(
            artifactParentFD, OwnerPaths.rawCombinedLeaf)
        try ownerRequire(existingRaw == nil, "RAW_PRESENT")
        rawFD = try createAtExclusive(
            artifactParentFD,
            OwnerPaths.rawCombinedLeaf,
            mode: mode_t(0o600),
            code: "RAW_CREATE")
        let held = try fdStat(rawFD, "RAW_INITIAL_HELD")
        let relative = try statAt(artifactParentFD, OwnerPaths.rawCombinedLeaf)
        try ownerRequire(held == relative && held.type == "REGULAR" &&
                         held.device == OwnerIdentity.artifactParentDevice &&
                         held.uid == 501 && held.gid == 20 &&
                         held.permissionMode == 0o600 && held.nlink == 1 &&
                         held.flags == 0 && held.bytes == 0,
                         "RAW_INITIAL_IDENTITY")
        try syncDescriptor(
            artifactParentFD, "RAW_PARENT_CREATE", accounting: ioAccounting)
    }

    private func closeParentWriterOnce() throws {
        try ownerRequire(writerCloseReceipt == nil && pipeWriteFD >= 3,
                         "WRITER_CLOSE_STATE")
        let closing = pipeWriteFD
        pipeWriteFD = -1
        errno = 0
        let result = Darwin.close(closing)
        let savedErrno = result == 0 ? nil : errno
        let receipt = WriterCloseReceipt(errnoValue: savedErrno, result: result)
        writerCloseReceipt = receipt
        if result != 0 {
            throw OwnerFailure("PARENT_WRITER_CLOSE", errnoValue: savedErrno)
        }
    }

    private func validateChild(_ pid: Int32) throws -> ChildAdmission {
        guard let selfAdmission, let rubyBaseline, let runnerBaseline,
              let readinessBaseline, let buildAParentBaseline,
              let buildARootBaseline, let buildABundleBaseline,
              let artifactParentBaseline else {
            throw OwnerFailure("CHILD_BASELINE")
        }
        let process = try processIdentity(pid, "CHILD_PROCESS")
        partialChildAdmission.process = process
        try ownerRequire(process.pid == pid &&
                         process.ppid == selfAdmission.process.pid &&
                         process.pgid == selfAdmission.process.pgid &&
                         process.session == selfAdmission.process.session &&
                         process.uid == selfAdmission.process.uid &&
                         process.gid == selfAdmission.process.gid &&
                         process.ruid == selfAdmission.process.ruid &&
                         process.rgid == selfAdmission.process.rgid,
                         "CHILD_PROCESS_JOIN")
        partialChildAdmission.processJoined = true
        let path = try processPath(pid, "CHILD_PATH")
        partialChildAdmission.path = path
        try ownerRequire(path == OwnerPaths.ruby, "CHILD_RUBY_PATH")
        partialChildAdmission.pathJoined = true
        let mapping = try findMappedExecutable(
            pid: pid,
            expectedPath: OwnerPaths.ruby,
            expected: rubyBaseline,
            expectedFileOffset: OwnerIdentity.rubyMappedFileOffset,
            code: "CHILD_RUBY_MAPPING")
        partialChildAdmission.mapping = mapping
        try rejoinHeldAbsolute(
            descriptor: runnerFD,
            path: OwnerPaths.runnerSource,
            baseline: runnerBaseline,
            code: "CHILD_RUNNER_FD3_OWNER_REJOIN")
        try rejoinHeldAbsolute(
            descriptor: readinessFD,
            path: OwnerPaths.runtimeReadiness,
            baseline: readinessBaseline,
            code: "CHILD_READINESS_REJOIN")
        try rejoinHeldAbsolute(
            descriptor: rubyFD,
            path: OwnerPaths.ruby,
            baseline: rubyBaseline,
            code: "CHILD_RUBY_REJOIN")
        try rejoinHeld(
            descriptor: buildABundleFD,
            directoryFD: buildARootFD,
            leaf: OwnerPaths.buildABundleLeaf,
            baseline: buildABundleBaseline,
            code: "CHILD_BUNDLE_REJOIN")
        try rejoinHeldAbsolute(
            descriptor: selfFD,
            path: selfAdmission.executablePath,
            baseline: selfAdmission.executableVNode,
            code: "CHILD_SELF_REJOIN")
        let artifactHeld = try fdStat(artifactParentFD, "CHILD_ARTIFACT_PARENT_HELD")
        let artifactNamed = try statAt(
            atFDCWD, OwnerPaths.artifactParent, flags: atSymlinkNoFollowAny)
        try ownerRequire(
            artifactHeld == artifactNamed &&
            artifactHeld.device == artifactParentBaseline.device &&
            artifactHeld.inode == artifactParentBaseline.inode &&
            artifactHeld.uid == artifactParentBaseline.uid &&
            artifactHeld.gid == artifactParentBaseline.gid &&
            artifactHeld.permissionMode == artifactParentBaseline.permissionMode &&
            artifactHeld.flags == artifactParentBaseline.flags,
            "CHILD_ARTIFACT_PARENT_REJOIN")
        let buildParentHeld = try fdStat(buildAParentFD, "CHILD_BUILD_A_PARENT_HELD")
        let buildParentNamed = try statAt(
            atFDCWD, OwnerPaths.buildAParent, flags: atSymlinkNoFollowAny)
        try ownerRequire(buildParentHeld == buildParentNamed &&
                         sameDirectoryAuthority(
                            buildParentHeld, buildAParentBaseline),
                         "CHILD_BUILD_A_PARENT_REJOIN")
        let buildRootHeld = try fdStat(buildARootFD, "CHILD_BUILD_A_ROOT_HELD")
        let buildRootRelative = try statAt(buildAParentFD, OwnerPaths.buildARootLeaf)
        try ownerRequire(buildRootHeld == buildARootBaseline &&
                         buildRootRelative == buildARootBaseline,
                         "CHILD_BUILD_A_ROOT_REJOIN")
        let buildNames = try rawDirectoryNames(
            buildARootFD, "CHILD_BUILD_A_INVENTORY").map(\.string)
        try ownerRequire(
            buildNames ==
                [OwnerPaths.buildAObjectLeaf, OwnerPaths.buildABundleLeaf].sorted(),
            "CHILD_BUILD_A_INVENTORY")
        partialChildAdmission.complete = true
        return ChildAdmission(mapping: mapping, path: path, process: process)
    }

    private func makeStartRecord(
        frame: AttemptReadinessFrame,
        selfAdmission: SelfAdmission,
        startTicks: UInt64,
        timebase: mach_timebase_info_data_t,
        startUTC: String
    ) throws -> [UInt8] {
        let identityKeys = [
            "control_freeze_sha256", "source_commit", "source_tree",
            "build_readiness_sha256", "build_result_sha256", "supervisor_sha256",
            "supervisor_bytes", "supervisor_uuid", "supervisor_cdhash",
            "supervisor_device", "supervisor_inode", "comparator_sha256",
            "checker_sha256", "runner_source_sha256", "ruby_sha256",
            "build_a_bundle_sha256", "build_a_bundle_uuid",
            "hypothesis_registration_sha256", "hypothesis_registration_bytes",
            "hypothesis_report_payload_sha256", "hypothesis_report_file_sha256",
            "hypothesis_report_bytes", "hypothesis_merkle_root",
            "hypothesis_merkle_leaf_count", "launch_contract_sha256",
        ]
        let identities = try identityKeys.map { key -> (String, OwnerJSON) in
            guard let value = frame.value(for: key) else {
                throw OwnerFailure("START_FRAME_FIELD_\(key)")
            }
            return (key, .string(value))
        }
        let root = OwnerJSON.object([
            ("authority_vector", .string("00000000")),
            ("authoritative", .bool(false)),
            ("consumption_policy", .string("ONE_ATTEMPT_NO_RETRY_NO_REPAIR_NO_REUSE")),
            ("frame_byte_count", .uint(UInt64(frame.byteCount))),
            ("frame_prefix_sha256", .string(frame.prefixSHA256)),
            ("identities", .object(identities)),
            ("launch", .object([
                ("argv", .array([
                    .string(OwnerPaths.ruby), .string("--disable-gems"),
                    .string("/dev/fd/3"),
                ])),
                ("cwd", .string(OwnerPaths.cwd)),
                ("environment", .array([
                    .string("__CF_USER_TEXT_ENCODING=0x1F5:0x0:0x0"),
                ])),
                ("runner_source_child_fd", .uint(3)),
                ("stderr", .string("SHARED_COMBINED_PIPE_WRITE_DESCRIPTION")),
                ("stdin", .string(OwnerPaths.null)),
                ("stdout", .string("SHARED_COMBINED_PIPE_WRITE_DESCRIPTION")),
            ])),
            ("may_feed_controller", .bool(false)),
            ("named_residuals", .array([
                .string("RUBY_POSIX_SPAWN_NAMED_PATH_DETECT_NOT_CONFINE"),
                .string("BUNDLE_DLOPEN_NAMED_PATH_DETECT_NOT_CONFINE"),
                .string("NO_SIGNAL_NO_TIMEOUT_POTENTIALLY_INDEFINITE"),
            ])),
            ("operations", operationCountersJSON()),
            ("owner_root", .string(OwnerPaths.ownerRoot)),
            ("prose_may_supply_fact", .bool(false)),
            ("raw_combined", .string(OwnerPaths.rawCombined)),
            ("runner_capture_root", .string(OwnerPaths.captureRoot)),
            ("schema", .string("ergentics-r19-obs11-c2-attempt-owner-start-v10")),
            ("self_admission", selfAdmission.json),
            ("start_boundary", .string("BEFORE_FIRST_LIVE_ACTUATION")),
            ("start_boundary_implementation",
             .string("MACH_CONTINUOUS_TIME_IMMEDIATELY_BEFORE_A0")),
            ("start_continuous_ticks", .uint(startTicks)),
            ("start_utc", .string(startUTC)),
            ("status", .string("START_DURABLE_ATTEMPT_CONSUMED")),
            ("timebase_denominator", .uint(UInt64(timebase.denom))),
            ("timebase_numerator", .uint(UInt64(timebase.numer))),
            ("utc_role", .string("DISPLAY_ONLY")),
        ])
        var bytes = try root.encoded()
        bytes.append(0x0a)
        try ownerRequire(bytes.count <= ordinaryLeafByteCap, "START_RECORD_CAP")
        return bytes
    }

    private func makeConservationRecord(
        startLeaf: PublishedLeaf,
        raw: RawReceipt,
        wait: WaitReceipt,
        child: ChildAdmission,
        inventory: CaptureInventory
    ) throws -> [UInt8] {
        guard let preEndOperations else {
            throw OwnerFailure("PREEND_OPERATIONS_MISSING")
        }
        let root = OwnerJSON.object([
            ("authority_vector", .string("00000000")),
            ("authoritative", .bool(false)),
            ("child_admission", child.json),
            ("first_failed_or_unentered_transition", .null),
            ("operations", preEndOperations),
            ("previous_leaf_sha256", .string(startLeaf.receipt.sha256)),
            ("raw_combined", raw.json),
            ("raw_post_wait_revalidation", rawPostWaitRevalidationJSON()),
            ("raw_pre_end_revalidation", rawPreEndRevalidationJSON()),
            ("runner_capture_inventory", inventory.json),
            ("runner_capture_revalidation", captureRevalidationJSON()),
            ("schema", .string("ergentics-r19-obs11-c2-attempt-owner-conservation-v10")),
            ("start_leaf", startLeaf.receipt.json),
            ("status", .string("TERMINAL_CONSERVATION_COMPLETE_NO_SEMANTIC_CLASSIFICATION")),
            ("transport_semantics", .string("COMBINED_UNATTRIBUTED_ONE_TRUE_EOF")),
            ("wait", wait.json),
        ])
        var bytes = try root.encoded()
        bytes.append(0x0a)
        try ownerRequire(bytes.count <= ordinaryLeafByteCap, "CONSERVATION_RECORD_CAP")
        return bytes
    }

    private func makeEndRecord(
        conservationLeaf: PublishedLeaf,
        startTicks: UInt64,
        endTicks: UInt64,
        startUTC: String,
        endUTC: String,
        timebase: mach_timebase_info_data_t,
        elapsed: AttemptRationalNanoseconds
    ) throws -> [UInt8] {
        let root = OwnerJSON.object([
            ("authority_vector", .string("00000000")),
            ("authoritative", .bool(false)),
            ("conservation_leaf", conservationLeaf.receipt.json),
            ("elapsed_nanoseconds_denominator", .uint(elapsed.denominator)),
            ("elapsed_nanoseconds_numerator", .uint(elapsed.numerator)),
            ("end_boundary", .string("AFTER_TERMINAL_CONSERVATION")),
            ("end_continuous_ticks", .uint(endTicks)),
            ("end_utc", .string(endUTC)),
            ("gate_e", .string("ABSTAIN")),
            ("may_feed_controller", .bool(false)),
            ("previous_leaf_sha256", .string(conservationLeaf.receipt.sha256)),
            ("prose_may_supply_fact", .bool(false)),
            ("schema", .string("ergentics-r19-obs11-c2-attempt-owner-end-v10")),
            ("scientific_outcome", .string("ABSTAIN")),
            ("start_boundary", .string("BEFORE_FIRST_LIVE_ACTUATION")),
            ("start_continuous_ticks", .uint(startTicks)),
            ("start_utc", .string(startUTC)),
            ("status", .string("TIMING_COMPLETE_NONAUTHORITATIVE")),
            ("timebase_denominator", .uint(UInt64(timebase.denom))),
            ("timebase_numerator", .uint(UInt64(timebase.numer))),
            ("timing_complete", .bool(true)),
            ("utc_role", .string("DISPLAY_ONLY")),
        ])
        var bytes = try root.encoded()
        bytes.append(0x0a)
        try ownerRequire(bytes.count <= ordinaryLeafByteCap, "END_RECORD_CAP")
        return bytes
    }

    private func operationCountersJSON() -> OwnerJSON {
        .object([
            ("a0_entries", .uint(a0Entries)),
            ("cleanup_repair_or_reuse", .uint(0)),
            ("combined_eof_count", .uint(combinedEOFCount)),
            ("io", ioAccounting.json),
            ("outer_dispatch_attempts", .uint(1)),
            ("owner_entries", .uint(ownerEntries)),
            ("parent_shared_writer_close_entries",
             .uint(writerCloseReceipt == nil ? 0 : 1)),
            ("retries", .uint(0)),
            ("runner_proven_entries", .uint(runnerProvenEntries)),
            ("second_runner_or_helper_process", .uint(0)),
            ("signals", .uint(0)),
            ("spawn_call_entries", .uint(spawnCallEntries)),
            ("timeouts", .uint(0)),
            ("wait_logical_operations", .uint(waitLogicalOperations)),
            ("waitpid_call_entries", .uint(waitReceipt?.callEntries ?? 0)),
        ])
    }

    private func rawPostWaitRevalidationJSON() -> OwnerJSON {
        .object([
            ("attempted", .bool(rawPostWaitRevalidationAttempted)),
            ("error", rawPostWaitRevalidationError.map { .string($0) } ?? .null),
            ("succeeded",
             .bool(rawPostWaitRevalidationAttempted &&
                   rawPostWaitRevalidationError == nil)),
        ])
    }

    private func captureInventoryAttemptJSON() -> OwnerJSON {
        .object([
            ("attempted", .bool(captureInventoryAttempted)),
            ("error", captureInventoryError.map { .string($0) } ?? .null),
            ("receipt", captureInventoryReceipt?.json ?? .null),
            ("succeeded",
             .bool(captureInventoryAttempted && captureInventoryError == nil &&
                   captureInventoryReceipt != nil)),
        ])
    }

    private func rawPreEndRevalidationJSON() -> OwnerJSON {
        .object([
            ("attempted", .bool(rawPreEndRevalidationAttempted)),
            ("error", rawPreEndRevalidationError.map { .string($0) } ?? .null),
            ("succeeded",
             .bool(rawPreEndRevalidationAttempted &&
                   rawPreEndRevalidationError == nil)),
        ])
    }

    private func captureRevalidationJSON() -> OwnerJSON {
        .object([
            ("attempted", .bool(captureRevalidationAttempted)),
            ("error", captureRevalidationError.map { .string($0) } ?? .null),
            ("succeeded",
             .bool(captureRevalidationAttempted && captureRevalidationError == nil)),
        ])
    }

    private func publishOwnerLeaf(
        _ leaf: String,
        bytes: [UInt8],
        previousSHA256: String?
    ) throws -> PublishedLeaf {
        var state = AttemptPublicationState()
        var descriptor = -1
        var durableCandidate: LeafReceipt?
        do {
            let allowed = Set([
                "00-start.json", "01-conservation.json", "02-end.json",
                "99-incomplete.json",
            ])
            try ownerRequire(allowed.contains(leaf), "PUBLISH_LEAF_NAME")
            if leaf == "01-conservation.json" || leaf == "02-end.json" {
                try ownerRequire(previousSHA256 != nil, "PUBLISH_PREVIOUS_REQUIRED")
            }
            if leaf == "00-start.json" {
                try ownerRequire(previousSHA256 == nil, "PUBLISH_START_PREVIOUS")
            }
            let existing = try statAtIfPresent(ownerRootFD, leaf)
            try ownerRequire(existing == nil, "PUBLISH_LEAF_PRESENT")
            descriptor = try createAtExclusive(
                ownerRootFD, leaf, mode: mode_t(0o600), code: "PUBLISH_OPEN_\(leaf)")
            try state.advance(to: .exclusiveLeafOpened)
            let initial = try fdStat(descriptor, "PUBLISH_INITIAL_\(leaf)")
            try ownerRequire(initial.type == "REGULAR" && initial.uid == 501 &&
                             initial.gid == 20 && initial.permissionMode == 0o600 &&
                             initial.nlink == 1 && initial.flags == 0 && initial.bytes == 0,
                             "PUBLISH_INITIAL_IDENTITY_\(leaf)")
            try writeAll(
                descriptor, bytes, "PUBLISH_\(leaf)", accounting: ioAccounting)
            try state.advance(to: .bytesComplete)
            let readback = try readHeldBytes(
                descriptor, maximumBytes: ordinaryLeafByteCap,
                code: "PUBLISH_READBACK_\(leaf)", accounting: ioAccounting)
            try ownerRequire(readback.bytes == bytes, "PUBLISH_READBACK_MISMATCH_\(leaf)")
            try state.advance(to: .readbackVerified)
            try syncDescriptor(
                descriptor, "PUBLISH_FIRST_\(leaf)", accounting: ioAccounting)
            try state.advance(to: .firstSyncComplete)
            guard Darwin.fchmod(descriptor, mode_t(0o400)) == 0 else {
                throw OwnerFailure(
                    "PUBLISH_FCHMOD_\(leaf)", errnoValue: errno)
            }
            try state.advance(to: .modeSealed)
            let immediate = try fdStat(descriptor, "PUBLISH_MODE_\(leaf)")
            try ownerRequire(immediate.permissionMode == 0o400,
                             "PUBLISH_MODE_IDENTITY_\(leaf)")
            durableCandidate = LeafReceipt(
                name: leaf,
                sha256: AttemptSHA256.digestHex(bytes),
                vnode: immediate)
            try syncDescriptor(
                descriptor, "PUBLISH_SECOND_\(leaf)", accounting: ioAccounting)
            try state.advance(to: .secondSyncComplete)
            try syncDescriptor(
                ownerRootFD, "PUBLISH_PARENT_\(leaf)", accounting: ioAccounting)
            try state.advance(to: .parentSyncComplete)
            let held = try fdStat(descriptor, "PUBLISH_FINAL_HELD_\(leaf)")
            let relative = try statAt(ownerRootFD, leaf)
            try ownerRequire(held == relative && held.type == "REGULAR" &&
                             held.uid == 501 && held.gid == 20 &&
                             held.permissionMode == 0o400 && held.nlink == 1 &&
                             held.flags == 0 && held.bytes == Int64(bytes.count),
                             "PUBLISH_FINAL_IDENTITY_\(leaf)")
            try state.advance(to: .vnodeRejoined)
            try ownerRequire(state.verified, "PUBLISH_STATE_\(leaf)")
            let receipt = LeafReceipt(
                name: leaf,
                sha256: AttemptSHA256.digestHex(bytes),
                vnode: held)
            closeDescriptorBestEffort(&descriptor)
            return PublishedLeaf(
                bytes: bytes,
                previousSHA256: previousSHA256,
                receipt: receipt,
                state: state)
        } catch {
            let failureCode: String
            let failureErrno: Int32?
            if let failure = error as? OwnerFailure {
                failureCode = failure.code
                failureErrno = failure.errnoValue
            } else {
                failureCode = "PUBLISH_UNCLASSIFIED_\(leaf)"
                failureErrno = nil
            }
            let failedPhase = state.phase
            if leaf != "99-incomplete.json",
                state.phase == .parentSyncComplete,
                let durableCandidate {
                lateDurableUnverifiedLeaf = durableCandidate
            }
            if !state.verified { try? state.fail() }
            let fact = PublicationFailureFact(
                attemptedBytes: UInt64(bytes.count),
                attemptedSHA256: AttemptSHA256.digestHex(bytes),
                descriptorHeld: descriptor >= 3,
                durableCandidate: durableCandidate,
                errorCode: failureCode,
                errnoValue: failureErrno,
                leaf: leaf,
                phase: failedPhase,
                previousSHA256: previousSHA256)
            if leaf == "99-incomplete.json" {
                if failedIncompletePublication == nil {
                    failedIncompletePublication = fact
                    failedIncompletePublicationFD = descriptor
                    failedIncompletePublicationBytes = bytes
                    descriptor = -1
                }
            } else if failedOrdinaryPublication == nil {
                failedOrdinaryPublication = fact
                failedOrdinaryPublicationFD = descriptor
                failedOrdinaryPublicationBytes = bytes
                descriptor = -1
            }
            closeDescriptorBestEffort(&descriptor)
            throw error
        }
    }

    private func drainAndFinalizeRaw() throws -> RawReceipt {
        try ownerRequire(!drainAttempted, "RAW_DRAIN_DUPLICATE")
        guard let writerCloseReceipt else {
            throw OwnerFailure("RAW_WRITER_CLOSE_MISSING")
        }
        drainAttempted = true
        var retained = 0
        var observedStreamBytes: UInt64 = 0
        var overflow = false
        var publicationError: String?
        var publicationErrno: Int32?
        var publicationStage = "PREFIX_RETAINED_0600_UNSYNCED"
        var pwriteCallEntries: UInt64 = 0
        var pwriteEINTRContinuations: UInt64 = 0
        var pwritePartialContinuations: UInt64 = 0
        var readCallEntries: UInt64 = 0
        var readEINTRContinuations: UInt64 = 0
        var readPartialContinuations: UInt64 = 0
        var readError: Int32?
        var writeError: String?
        var buffer = [UInt8](repeating: 0, count: 16_384)
        while true {
            let nextReadCall = readCallEntries.addingReportingOverflow(1)
            try ownerRequire(!nextReadCall.overflow, "RAW_READ_CALL_COUNT")
            readCallEntries = nextReadCall.partialValue
            try countedIncrement(
                &ioAccounting.readCallEntries, "RAW_AGGREGATE_READ_CALL_COUNT")
            let count = buffer.withUnsafeMutableBytes {
                Darwin.read(pipeReadFD, $0.baseAddress, $0.count)
            }
            if count == 0 {
                combinedEOFCount = 1
                break
            }
            if count < 0 {
                if errno == EINTR {
                    let next = readEINTRContinuations.addingReportingOverflow(1)
                    try ownerRequire(!next.overflow, "RAW_READ_EINTR_COUNT")
                    readEINTRContinuations = next.partialValue
                    try countedIncrement(
                        &ioAccounting.readEINTRContinuations,
                        "RAW_AGGREGATE_READ_EINTR_COUNT")
                    continue
                }
                readError = errno
                break
            }
            let nextObserved = observedStreamBytes.addingReportingOverflow(UInt64(count))
            try ownerRequire(!nextObserved.overflow, "RAW_OBSERVED_BYTE_COUNT")
            observedStreamBytes = nextObserved.partialValue
            if count < buffer.count {
                try countedIncrement(
                    &readPartialContinuations, "RAW_READ_PARTIAL_COUNT")
                try countedIncrement(
                    &ioAccounting.readPartialContinuations,
                    "RAW_AGGREGATE_READ_PARTIAL_COUNT")
            }
            let capacity = max(0, rawRetainedByteCap - retained)
            let retaining = min(count, capacity)
            if retaining > 0 && writeError == nil {
                do {
                    try buffer.withUnsafeBytes { bytes in
                        try pwriteAll(
                            rawFD,
                            UnsafeRawBufferPointer(start: bytes.baseAddress, count: retaining),
                            committedBytes: &retained,
                            code: "RAW_PREFIX",
                            callEntries: &pwriteCallEntries,
                            eintrContinuations: &pwriteEINTRContinuations,
                            partialContinuations: &pwritePartialContinuations,
                            accounting: ioAccounting)
                    }
                } catch let failure as OwnerFailure {
                    writeError = failure.code
                } catch {
                    writeError = "RAW_WRITE_UNCLASSIFIED"
                }
            }
            if observedStreamBytes > UInt64(rawRetainedByteCap) { overflow = true }
        }
        closeDescriptorBestEffort(&pipeReadFD)

        var durable = false
        var finalVNode: VNodeIdentity?
        do {
            try syncDescriptor(rawFD, "RAW_FIRST", accounting: ioAccounting)
            publicationStage = "FIRST_FILE_SYNC_COMPLETE_0600"
            guard Darwin.fchmod(rawFD, mode_t(0o400)) == 0 else {
                throw OwnerFailure("RAW_FCHMOD", errnoValue: errno)
            }
            publicationStage = "MODE_0400_SYNC_INCOMPLETE"
            let immediate = try fdStat(rawFD, "RAW_MODE")
            try ownerRequire(immediate.permissionMode == 0o400, "RAW_MODE_IDENTITY")
            try syncDescriptor(rawFD, "RAW_SECOND", accounting: ioAccounting)
            publicationStage = "SECOND_FILE_SYNC_COMPLETE_0400"
            try syncDescriptor(
                artifactParentFD, "RAW_PARENT", accounting: ioAccounting)
            publicationStage = "PARENT_SYNC_COMPLETE_REJOIN_INCOMPLETE"
            let held = try fdStat(rawFD, "RAW_FINAL_HELD")
            let relative = try statAt(artifactParentFD, OwnerPaths.rawCombinedLeaf)
            let named = try statAt(
                atFDCWD, OwnerPaths.rawCombined, flags: atSymlinkNoFollowAny)
            try ownerRequire(held == relative && held == named &&
                             held.type == "REGULAR" && held.uid == 501 && held.gid == 20 &&
                             held.permissionMode == 0o400 && held.nlink == 1 &&
                             held.flags == 0 && held.bytes == Int64(retained),
                             "RAW_FINAL_IDENTITY")
            finalVNode = held
            durable = true
            publicationStage = "DURABLE_VERIFIED_0400"
        } catch let failure as OwnerFailure {
            failureCodes.append(failure.code)
            publicationError = failure.code
            publicationErrno = failure.errnoValue
        } catch {
            failureCodes.append("RAW_FINALIZE_UNCLASSIFIED")
            publicationError = "RAW_FINALIZE_UNCLASSIFIED"
        }
        let rawReadback = try readHeldBytes(
            rawFD, maximumBytes: rawRetainedByteCap,
            code: "RAW_HASH", accounting: ioAccounting)
        let bytes = rawReadback.bytes
        try ownerRequire(bytes.count == retained, "RAW_RETAINED_BYTE_JOIN")
        let lfCount = bytes.reduce(UInt64(0)) { $0 + ($1 == 0x0a ? 1 : 0) }
        let streamComplete = combinedEOFCount == 1 && readError == nil && !overflow &&
            observedStreamBytes == UInt64(bytes.count)
        let fullyComplete = streamComplete && writerCloseReceipt.result == 0 &&
            writeError == nil && durable
        let receipt = RawReceipt(
            complete: fullyComplete,
            completeStream: streamComplete,
            durable: durable,
            eofCount: combinedEOFCount,
            observedStreamBytes: observedStreamBytes,
            overflow: overflow,
            publicationError: publicationError,
            publicationErrno: publicationErrno,
            publicationStage: publicationStage,
            pwriteCallEntries: pwriteCallEntries,
            pwriteEINTRContinuations: pwriteEINTRContinuations,
            pwritePartialContinuations: pwritePartialContinuations,
            readCallEntries: readCallEntries,
            readEINTRContinuations: readEINTRContinuations,
            readPartialContinuations: readPartialContinuations,
            readError: readError,
            retainedPrefixBytes: UInt64(bytes.count),
            retainedPrefixLFCount: lfCount,
            retainedPrefixSHA256: AttemptSHA256.digestHex(bytes),
            vnode: finalVNode ?? rawReadback.after,
            writerClose: writerCloseReceipt,
            writeError: writeError)
        rawReceipt = receipt
        try ownerRequire(receipt.complete, "RAW_INCOMPLETE")
        return receipt
    }

    private func waitForChild() throws -> WaitReceipt {
        try ownerRequire(childPID > 0 && !waitAttempted && waitReceipt == nil,
                         "WAIT_STATE")
        waitAttempted = true
        waitLogicalOperations = 1
        var status: Int32 = 0
        var callEntries: UInt64 = 0
        var continuations: UInt64 = 0
        while true {
            try countedIncrement(&callEntries, "WAIT_CALL_COUNT")
            let waited = Darwin.waitpid(childPID, &status, 0)
            if waited == childPID {
                let receipt = WaitReceipt(
                    callEntries: callEntries,
                    childPID: childPID,
                    eintrContinuations: continuations,
                    rawStatus: status,
                    waitErrorCode: nil,
                    waitErrno: nil,
                    waitedPID: waited)
                waitReceipt = receipt
                return receipt
            }
            if waited == -1 && errno == EINTR {
                let next = continuations.addingReportingOverflow(1)
                try ownerRequire(!next.overflow, "WAIT_EINTR_OVERFLOW")
                continuations = next.partialValue
                continue
            }
            let savedErrno: Int32? = waited == -1 ? errno : nil
            let errorCode = waited == -1 ? "WAITPID" : "WAITPID_UNEXPECTED_RETURN"
            waitReceipt = WaitReceipt(
                callEntries: callEntries,
                childPID: childPID,
                eintrContinuations: continuations,
                rawStatus: nil,
                waitErrorCode: errorCode,
                waitErrno: savedErrno,
                waitedPID: waited >= 0 ? waited : nil)
            throw OwnerFailure(errorCode, errnoValue: savedErrno)
        }
    }

    private func validateDurablePublishedLeaf(
        _ leaf: PublishedLeaf,
        expectedPrevious: String?,
        code: String
    ) throws -> HeldJournalLeaf {
        try ownerRequire(
            leaf.state.verified && leaf.previousSHA256 == expectedPrevious &&
            leaf.receipt.sha256 == AttemptSHA256.digestHex(leaf.bytes),
            code + "_RECEIPT")
        var descriptor = try openAtExisting(
            ownerRootFD, leaf.receipt.name, code: code + "_OPEN")
        do {
            let held = try readHeldBytes(
                descriptor, maximumBytes: ordinaryLeafByteCap,
                code: code + "_READ", accounting: ioAccounting)
            let relative = try statAt(ownerRootFD, leaf.receipt.name)
            try ownerRequire(
                held.bytes == leaf.bytes && held.sha256 == leaf.receipt.sha256 &&
                held.before == leaf.receipt.vnode && held.after == leaf.receipt.vnode &&
                relative == leaf.receipt.vnode &&
                leaf.receipt.vnode.type == "REGULAR" &&
                leaf.receipt.vnode.uid == 501 && leaf.receipt.vnode.gid == 20 &&
                leaf.receipt.vnode.permissionMode == 0o400 &&
                leaf.receipt.vnode.nlink == 1 && leaf.receipt.vnode.flags == 0,
                code + "_JOIN")
            if leaf.receipt.name == "01-conservation.json" ||
                leaf.receipt.name == "02-end.json" {
                guard let expectedPrevious else {
                    throw OwnerFailure(code + "_ANCESTRY_MISSING")
                }
                try ownerRequire(
                    containsBytes(
                        leaf.bytes,
                        Array("\"previous_leaf_sha256\":\"\(expectedPrevious)\"".utf8)),
                    code + "_ANCESTRY_CONTENT")
            } else if leaf.receipt.name == "99-incomplete.json" {
                let token = expectedPrevious.map {
                    "\"failure_previous_digest\":\"\($0)\""
                } ?? "\"failure_previous_digest\":null"
                try ownerRequire(
                    containsBytes(leaf.bytes, Array(token.utf8)),
                    code + "_FAILURE_ANCESTRY_CONTENT")
            }
            let retained = HeldJournalLeaf(
                descriptor: descriptor,
                name: leaf.receipt.name,
                vnode: leaf.receipt.vnode)
            descriptor = -1
            return retained
        } catch {
            closeDescriptorBestEffort(&descriptor)
            throw error
        }
    }

    private func validatePartialPublication(
        fact: PublicationFailureFact?,
        descriptor: Int32,
        attemptedBytes: [UInt8]?,
        code: String
    ) throws -> VNodeIdentity? {
        guard let fact else {
            try ownerRequire(descriptor < 0 && attemptedBytes == nil, code + "_ABSENT")
            return nil
        }
        guard let attemptedBytes else {
            throw OwnerFailure(code + "_ATTEMPT_BYTES_MISSING")
        }
        try ownerRequire(
            fact.attemptedBytes == UInt64(attemptedBytes.count) &&
            fact.attemptedSHA256 == AttemptSHA256.digestHex(attemptedBytes) &&
            fact.descriptorHeld == (descriptor >= 3),
            code + "_ATTEMPT_IDENTITY")
        let named = try statAtIfPresent(ownerRootFD, fact.leaf)
        if descriptor < 3 {
            try ownerRequire(
                fact.phase == .unentered && named == nil,
                code + "_UNENTERED_IDENTITY")
            return nil
        }
        guard let named else { throw OwnerFailure(code + "_NAMED_ABSENT") }
        let held = try readHeldBytes(
            descriptor, maximumBytes: ordinaryLeafByteCap,
            code: code + "_READ", accounting: ioAccounting)
        try ownerRequire(
            held.before == named && held.after == named &&
            held.bytes.count <= attemptedBytes.count &&
            held.bytes == Array(attemptedBytes.prefix(held.bytes.count)) &&
            named.type == "REGULAR" && named.uid == 501 && named.gid == 20 &&
            (named.permissionMode == 0o600 || named.permissionMode == 0o400) &&
            named.nlink == 1 && named.flags == 0,
            code + "_JOIN")
        if let durableCandidate = fact.durableCandidate {
            try ownerRequire(
                named == durableCandidate &&
                AttemptSHA256.digestHex(held.bytes) == durableCandidate.sha256,
                code + "_DURABLE_CANDIDATE_JOIN")
        }
        return named
    }

    private func validateOwnerJournalBeforeSeal(
        success: Bool
    ) throws -> (
        root: VNodeIdentity,
        leaves: [HeldJournalLeaf],
        partialOrdinary: VNodeIdentity?,
        partialIncomplete: VNodeIdentity?
    ) {
        let initialRoot = try fdStat(ownerRootFD, "OWNER_JOURNAL_ROOT_INITIAL")
        var heldJournalLeaves: [HeldJournalLeaf] = []
        var transferDescriptors = false
        defer {
            if !transferDescriptors {
                for index in heldJournalLeaves.indices {
                    closeDescriptorBestEffort(&heldJournalLeaves[index].descriptor)
                }
            }
        }
        let ordinarySequence = [
            "00-start.json", "01-conservation.json", "02-end.json",
        ]
        let ordinaryLeaves = durableLeaves.filter {
            $0.receipt.name != "99-incomplete.json"
        }
        let incompleteLeaves = durableLeaves.filter {
            $0.receipt.name == "99-incomplete.json"
        }
        try ownerRequire(
            ordinaryLeaves.count <= ordinarySequence.count &&
            ordinaryLeaves.map { $0.receipt.name } ==
                Array(ordinarySequence.prefix(ordinaryLeaves.count)) &&
            incompleteLeaves.count <= 1,
            "OWNER_JOURNAL_PREFIX")
        if success {
            try ownerRequire(
                ordinaryLeaves.count == ordinarySequence.count &&
                incompleteLeaves.isEmpty && failedOrdinaryPublication == nil &&
                failedIncompletePublication == nil,
                "OWNER_JOURNAL_SUCCESS_TOPOLOGY")
        } else if let failedOrdinaryPublication {
            try ownerRequire(
                ordinaryLeaves.count < ordinarySequence.count &&
                failedOrdinaryPublication.leaf == ordinarySequence[ordinaryLeaves.count],
                "OWNER_JOURNAL_FAILED_NEXT")
        }

        var expectedPrevious: String?
        var inodes = Set<UInt64>()
        for (index, leaf) in ordinaryLeaves.enumerated() {
            let heldLeaf = try validateDurablePublishedLeaf(
                leaf, expectedPrevious: expectedPrevious,
                code: "OWNER_JOURNAL_ORDINARY_\(index)")
            heldJournalLeaves.append(heldLeaf)
            try ownerRequire(inodes.insert(heldLeaf.vnode.inode).inserted,
                             "OWNER_JOURNAL_INODE_DISTINCT")
            expectedPrevious = leaf.receipt.sha256
        }
        let partialOrdinaryVNode = try validatePartialPublication(
            fact: failedOrdinaryPublication,
            descriptor: failedOrdinaryPublicationFD,
            attemptedBytes: failedOrdinaryPublicationBytes,
            code: "OWNER_JOURNAL_PARTIAL_ORDINARY")
        if let partialOrdinaryVNode {
            try ownerRequire(inodes.insert(partialOrdinaryVNode.inode).inserted,
                             "OWNER_JOURNAL_PARTIAL_INODE_DISTINCT")
        }
        if let incomplete = incompleteLeaves.first {
            let heldLeaf = try validateDurablePublishedLeaf(
                incomplete, expectedPrevious: expectedPrevious,
                code: "OWNER_JOURNAL_INCOMPLETE")
            heldJournalLeaves.append(heldLeaf)
            try ownerRequire(inodes.insert(heldLeaf.vnode.inode).inserted,
                             "OWNER_JOURNAL_INCOMPLETE_INODE_DISTINCT")
        }
        let partialIncompleteVNode = try validatePartialPublication(
            fact: failedIncompletePublication,
            descriptor: failedIncompletePublicationFD,
            attemptedBytes: failedIncompletePublicationBytes,
            code: "OWNER_JOURNAL_PARTIAL_INCOMPLETE")
        if let partialIncompleteVNode {
            try ownerRequire(inodes.insert(partialIncompleteVNode.inode).inserted,
                             "OWNER_JOURNAL_PARTIAL_99_INODE_DISTINCT")
        }

        var expectedNames = ordinaryLeaves.map { $0.receipt.name }
        if failedOrdinaryPublicationFD >= 3,
           let failedOrdinaryPublication {
            expectedNames.append(failedOrdinaryPublication.leaf)
        }
        if let incomplete = incompleteLeaves.first {
            expectedNames.append(incomplete.receipt.name)
        }
        if failedIncompletePublicationFD >= 3,
           let failedIncompletePublication {
            expectedNames.append(failedIncompletePublication.leaf)
        }
        let names = try rawDirectoryNames(
            ownerRootFD, "OWNER_JOURNAL_FINAL_INVENTORY").map(\.string)
        try ownerRequire(
            names == expectedNames.sorted() && Set(names).count == names.count,
            "OWNER_JOURNAL_EXACT_INVENTORY")
        let root = try fdStat(ownerRootFD, "OWNER_JOURNAL_ROOT")
        try ownerRequire(
            root == initialRoot && root.type == "DIRECTORY" &&
            root.permissionMode == 0o700 &&
            root.nlink == UInt16(2 + names.count) &&
            !inodes.contains(root.inode),
            "OWNER_JOURNAL_ROOT_TOPOLOGY")
        transferDescriptors = true
        return (
            root: root,
            leaves: heldJournalLeaves,
            partialOrdinary: partialOrdinaryVNode,
            partialIncomplete: partialIncompleteVNode)
    }

    private func sealOwnerRoot(success: Bool) throws {
        try ownerRequire(rootCreated && ownerRootFD >= 3 && !rootSealAttempted,
                         "ROOT_SEAL_STATE")
        var machine = AttemptRootSealMachine()
        var journalValidation = try validateOwnerJournalBeforeSeal(success: success)
        defer {
            for index in journalValidation.leaves.indices {
                closeDescriptorBestEffort(
                    &journalValidation.leaves[index].descriptor)
            }
        }
        let names = try rawDirectoryNames(ownerRootFD, "OWNER_PRESEAL_NAMES")
        if success {
            try ownerRequire(
                names.map(\.string) == [
                    "00-start.json", "01-conservation.json", "02-end.json",
                ],
                "OWNER_SUCCESS_NAMES")
        }
        let before = try fdStat(ownerRootFD, "OWNER_PRESEAL")
        try ownerRequire(before == journalValidation.root &&
                         before.type == "DIRECTORY" && before.uid == 501 &&
                         before.gid == 20 && before.permissionMode == 0o700 &&
                         before.flags == 0 && before.nlink == UInt16(2 + names.count),
                         "OWNER_PRESEAL_IDENTITY")
        rootSealAttempted = true
        guard Darwin.fchmod(ownerRootFD, mode_t(0o500)) == 0 else {
            throw OwnerFailure("ROOT_FCHMOD", errnoValue: errno)
        }
        try machine.advance(to: .root0500ModeSealedSyncIncomplete)
        let immediate = try fdStat(ownerRootFD, "OWNER_MODE_SEALED")
        try ownerRequire(immediate.permissionMode == 0o500, "OWNER_MODE_SEAL_JOIN")
        try syncDescriptor(
            ownerRootFD, "OWNER_ROOT_SEAL", accounting: ioAccounting)
        try syncDescriptor(
            artifactParentFD, "OWNER_PARENT_SEAL", accounting: ioAccounting)
        try machine.advance(to: .root0500DurableRejoinIncomplete)
        for leaf in journalValidation.leaves {
            let leafHeld = try fdStat(
                leaf.descriptor, "OWNER_TERMINAL_LEAF_HELD_\(leaf.name)")
            let leafRelative = try statAt(ownerRootFD, leaf.name)
            try ownerRequire(
                leafHeld == leaf.vnode && leafRelative == leaf.vnode,
                "OWNER_TERMINAL_LEAF_JOIN_\(leaf.name)")
        }
        if let expected = journalValidation.partialOrdinary,
           let fact = failedOrdinaryPublication {
            let held = try fdStat(
                failedOrdinaryPublicationFD, "OWNER_TERMINAL_PARTIAL_ORDINARY_HELD")
            let relative = try statAt(ownerRootFD, fact.leaf)
            try ownerRequire(
                held == expected && relative == expected,
                "OWNER_TERMINAL_PARTIAL_ORDINARY_JOIN")
        }
        if let expected = journalValidation.partialIncomplete,
           let fact = failedIncompletePublication {
            let held = try fdStat(
                failedIncompletePublicationFD, "OWNER_TERMINAL_PARTIAL_99_HELD")
            let relative = try statAt(ownerRootFD, fact.leaf)
            try ownerRequire(
                held == expected && relative == expected,
                "OWNER_TERMINAL_PARTIAL_99_JOIN")
        }
        let held = try fdStat(ownerRootFD, "OWNER_TERMINAL_HELD")
        let relative = try statAt(artifactParentFD, OwnerPaths.ownerRootLeaf)
        let named = try statAt(
            atFDCWD, OwnerPaths.ownerRoot, flags: atSymlinkNoFollowAny)
        try ownerRequire(held == relative && held == named &&
                         held.type == "DIRECTORY" &&
                         held.device == before.device && held.inode == before.inode &&
                         held.changeSeconds == immediate.changeSeconds &&
                         held.changeNanoseconds == immediate.changeNanoseconds &&
                         held.uid == 501 && held.gid == 20 && held.flags == 0 &&
                         held.permissionMode == 0o500 &&
                         held.nlink == UInt16(2 + names.count),
                         "OWNER_TERMINAL_JOIN")
        try machine.advance(to: .root0500TerminalVerified)
        try ownerRequire(machine.verified, "OWNER_SEAL_MACHINE")
    }

    private func containFailure() {
        defer {
            closeHeldCaptureDescriptorsBestEffort()
            closeDescriptorBestEffort(&failedOrdinaryPublicationFD)
            closeDescriptorBestEffort(&failedIncompletePublicationFD)
        }
        if rawFD >= 0 && writerCloseReceipt == nil && pipeWriteFD >= 3 {
            do {
                try closeParentWriterOnce()
            } catch let failure as OwnerFailure {
                failureCodes.append(failure.code)
            } catch {
                failureCodes.append("WRITER_CLOSE_UNCLASSIFIED")
            }
        } else {
            closeDescriptorBestEffort(&pipeWriteFD)
        }
        closeDescriptorBestEffort(&nullFD)
        if rawFD >= 0 && !drainAttempted && pipeReadFD >= 0 &&
            writerCloseReceipt != nil {
            do {
                rawReceipt = try drainAndFinalizeRaw()
            } catch let failure as OwnerFailure {
                failureCodes.append(failure.code)
            } catch {
                failureCodes.append("CONTAIN_DRAIN_UNCLASSIFIED")
            }
        }
        if childPID > 0 && !waitAttempted {
            do {
                waitReceipt = try waitForChild()
            } catch let failure as OwnerFailure {
                failureCodes.append(failure.code)
            } catch {
                failureCodes.append("CONTAIN_WAIT_UNCLASSIFIED")
            }
        }
        if waitAttempted && !rawPostWaitRevalidationAttempted {
            do {
                try revalidateRawAfterWaitOnce()
            } catch let failure as OwnerFailure {
                failureCodes.append(failure.code)
            } catch {
                failureCodes.append("RAW_CONTAIN_REJOIN_UNCLASSIFIED")
            }
        }
        guard rootCreated && ownerRootFD >= 3 else { return }
        do {
            let mode = try fdStat(ownerRootFD, "FAILURE_ROOT_MODE").permissionMode
            if mode == 0o700,
               try statAtIfPresent(ownerRootFD, "99-incomplete.json") == nil {
                let record = try failureRecord()
                let leaf = try publishOwnerLeaf(
                    "99-incomplete.json",
                    bytes: record,
                    previousSHA256: durableLeaves.last?.receipt.sha256)
                durableLeaves.append(leaf)
            }
        } catch let failure as OwnerFailure {
            failureCodes.append(failure.code)
        } catch {
            failureCodes.append("FAILURE_PUBLICATION_UNCLASSIFIED")
        }
        if !rootSealAttempted {
            do {
                try sealOwnerRoot(success: false)
            } catch let failure as OwnerFailure {
                failureCodes.append(failure.code)
            } catch {
                failureCodes.append("FAILURE_SEAL_UNCLASSIFIED")
            }
        }
    }

    private func failureRecord() throws -> [UInt8] {
        let ordinaryNames = durableLeaves.map { $0.receipt.name }.filter {
            $0 != "99-incomplete.json"
        }
        let previous = durableLeaves.last?.receipt.sha256
        let root = OwnerJSON.object([
            ("authority_vector", .string("00000000")),
            ("authoritative", .bool(false)),
            ("child_admission", partialChildAdmission.json),
            ("child_pid", childPID > 0 ? .int(Int64(childPID)) : .null),
            ("durable_ordinary_prefix", .array(durableLeaves.map {
                $0.receipt.json
            })),
            ("failed_ordinary_publication",
             failedOrdinaryPublication?.json ?? .null),
            ("failure_codes", .array(failureCodes.map { .string($0) })),
            ("first_failed_or_unentered_transition",
             failureCodes.first.map { .string($0) } ?? .null),
            ("failure_previous_digest", previous.map { .string($0) } ?? .null),
            ("failure_chain_ordinal", .uint(UInt64(ordinaryNames.count))),
            ("late_durable_unverified_leaf",
             lateDurableUnverifiedLeaf?.json ?? .null),
            ("known_timing", knownTimingJSON()),
            ("may_feed_controller", .bool(false)),
            ("operations", operationCountersJSON()),
            ("pre_end_operations", preEndOperations ?? .null),
            ("prose_may_supply_fact", .bool(false)),
            ("raw_combined", rawReceipt?.json ?? .null),
            ("raw_post_wait_revalidation", rawPostWaitRevalidationJSON()),
            ("raw_pre_end_revalidation", rawPreEndRevalidationJSON()),
            ("retry_authorized", .bool(false)),
            ("root_seal_state",
             .string("ROOT_0700_PRESEAL_OR_FCHMOD_FAILED")),
            ("runner_capture_inventory", captureInventoryReceipt?.json ?? .null),
            ("runner_capture_inventory_attempt", captureInventoryAttemptJSON()),
            ("runner_capture_revalidation", captureRevalidationJSON()),
            ("schema", .string("ergentics-r19-obs11-c2-attempt-owner-incomplete-v10")),
            ("status", .string("CONSUMED_INFRASTRUCTURE_INCOMPLETE")),
            ("wait", waitReceipt?.json ?? .null),
            ("writer_close", writerCloseReceipt?.json ?? .null),
        ])
        var bytes = try root.encoded()
        bytes.append(0x0a)
        try ownerRequire(bytes.count <= ordinaryLeafByteCap, "FAILURE_RECORD_CAP")
        return bytes
    }

    private func knownTimingJSON() -> OwnerJSON {
        .object([
            ("elapsed_nanoseconds_denominator",
             knownElapsedDenominator.map { .uint($0) } ?? .null),
            ("elapsed_nanoseconds_numerator",
             knownElapsedNumerator.map { .uint($0) } ?? .null),
            ("end_continuous_ticks", knownEndTicks.map { .uint($0) } ?? .null),
            ("end_timebase_denominator",
             knownEndTimebaseDenominator.map { .uint($0) } ?? .null),
            ("end_timebase_numerator",
             knownEndTimebaseNumerator.map { .uint($0) } ?? .null),
            ("end_utc", knownEndUTC.map { .string($0) } ?? .null),
            ("start_continuous_ticks", knownStartTicks.map { .uint($0) } ?? .null),
            ("start_timebase_denominator",
             knownStartTimebaseDenominator.map { .uint($0) } ?? .null),
            ("start_timebase_numerator",
             knownStartTimebaseNumerator.map { .uint($0) } ?? .null),
            ("start_utc", knownStartUTC.map { .string($0) } ?? .null),
            ("utc_role", .string("DISPLAY_ONLY")),
        ])
    }

    private func closeAllBestEffort() {
        closeHeldCaptureDescriptorsBestEffort()
        closeDescriptorBestEffort(&failedOrdinaryPublicationFD)
        closeDescriptorBestEffort(&failedIncompletePublicationFD)
        closeDescriptorBestEffort(&pipeWriteFD)
        closeDescriptorBestEffort(&pipeReadFD)
        closeDescriptorBestEffort(&nullFD)
        closeDescriptorBestEffort(&captureRootFD)
        closeDescriptorBestEffort(&rawFD)
        closeDescriptorBestEffort(&ownerRootFD)
        closeDescriptorBestEffort(&selfFD)
        closeDescriptorBestEffort(&hypothesisReportFD)
        closeDescriptorBestEffort(&hypothesisRegistrationFD)
        closeDescriptorBestEffort(&buildResultFD)
        closeDescriptorBestEffort(&buildReadinessFD)
        closeDescriptorBestEffort(&buildABundleFD)
        closeDescriptorBestEffort(&buildAObjectFD)
        closeDescriptorBestEffort(&buildARootFD)
        closeDescriptorBestEffort(&buildAParentFD)
        closeDescriptorBestEffort(&rubyFD)
        closeDescriptorBestEffort(&runnerFD)
        closeDescriptorBestEffort(&controlFreezeFD)
        closeDescriptorBestEffort(&readinessFD)
        closeDescriptorBestEffort(&cwdFD)
        closeDescriptorBestEffort(&artifactParentFD)
    }
}
