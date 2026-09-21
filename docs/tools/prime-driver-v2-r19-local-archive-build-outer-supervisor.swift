// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin

@_silgen_name("_NSGetEnviron")
private func primeR19NSGetEnviron()
    -> UnsafeMutablePointer<UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?>?

@_silgen_name("prime_r19_open_runtime_parent_v1")
private func primeR19OpenRuntimeParent(
    _ ordinal: UInt32,
    _ outErrno: UnsafeMutablePointer<Int32>
) -> Int32

@_silgen_name("prime_r19_mkdir_runtime_root_at_v1")
private func primeR19MkdirRuntimeRoot(
    _ parent: Int32,
    _ ordinal: UInt32,
    _ outErrno: UnsafeMutablePointer<Int32>
) -> Int32

@_silgen_name("prime_r19_open_runtime_root_at_v1")
private func primeR19OpenRuntimeRoot(
    _ parent: Int32,
    _ ordinal: UInt32,
    _ outErrno: UnsafeMutablePointer<Int32>
) -> Int32

@_silgen_name("prime_r19_create_journal_at_v1")
private func primeR19CreateJournal(
    _ root: Int32,
    _ ordinal: UInt32,
    _ outErrno: UnsafeMutablePointer<Int32>
) -> Int32

@_silgen_name("prime_r19_create_fifo_at_v1")
private func primeR19CreateFIFO(
    _ root: Int32,
    _ ordinal: UInt32,
    _ outErrno: UnsafeMutablePointer<Int32>
) -> Int32

@_silgen_name("prime_r19_open_fifo_read_at_v1")
private func primeR19OpenFIFORead(
    _ root: Int32,
    _ ordinal: UInt32,
    _ outErrno: UnsafeMutablePointer<Int32>
) -> Int32

@_silgen_name("prime_r19_open_ruby_image_v1")
private func primeR19OpenRubyImage(
    _ ordinal: UInt32,
    _ outErrno: UnsafeMutablePointer<Int32>
) -> Int32

@_silgen_name("prime_r19_open_controller_source_v1")
private func primeR19OpenControllerSource(
    _ ordinal: UInt32,
    _ outErrno: UnsafeMutablePointer<Int32>
) -> Int32

@_silgen_name("prime_r19_open_cwd_root_v1")
private func primeR19OpenCWDRoot(
    _ ordinal: UInt32,
    _ outErrno: UnsafeMutablePointer<Int32>
) -> Int32

@_silgen_name("prime_r19_fullfsync_v1")
private func primeR19FullFSync(
    _ descriptor: Int32,
    _ ordinal: UInt32,
    _ outErrno: UnsafeMutablePointer<Int32>
) -> Int32

// The C declaration uses prime_r19_rusage_v6_capture_v1 *. A raw pointer has
// the same C calling convention while keeping the exact C layout authoritative.
@_silgen_name("prime_r19_capture_rusage_v6_v1")
private func primeR19CaptureRusageV6(
    _ pid: pid_t,
    _ ordinal: UInt32,
    _ outCapture: UnsafeMutableRawPointer
) -> Int32

// These two C wrappers own the fixed syscall names, flags, attribute bitmap,
// capacities, and ordinal domains. Swift retains their complete raw structs.
@_silgen_name("prime_r19_capture_runtime_root_inventory_raw_v1")
private func primeR19CaptureRuntimeRootInventoryRaw(
    _ root: Int32,
    _ ordinal: UInt32,
    _ outCapture: UnsafeMutableRawPointer
) -> Int32

@_silgen_name("prime_r19_capture_boot_session_uuid_v1")
private func primeR19CaptureBootSessionUUID(
    _ ordinal: UInt32,
    _ outCapture: UnsafeMutableRawPointer
) -> Int32

private enum PrimeR19Failure: Error {
    case rejected
}

private enum PrimeR19Fixed {
    static let controlCommit = "4ec07e1bc123b7918ef6cbe14144f9a072b770c8"
    static let controlTree = "16aa44548abec28216cd32bf75903f10a3ce304b"
    static let controlFrameWithLF =
        "ac64f2f42331a718b5dfc2aff1fe3ac6def6a5ef5b82ad945ee2be640b8d10b6"
    static let payloadHashRule =
        "SHA256_COMPACT_RECURSIVE_LEXICOGRAPHIC_KEYS_UTF8_NO_TRAILING_LF"
    static let runtimeRoot =
        "/private/tmp/r19-local-archive-build-outer-supervisor-4e7d6406-861da2f4"
    static let runtimeRootLeaf =
        "r19-local-archive-build-outer-supervisor-4e7d6406-861da2f4"
    static let journalLeaf = "00-child-supervisor.v1.jsonl"
    static let fifoLeaf = "01-child-go.v1.fifo"
    static let rubyPath = "/usr/bin/ruby"
    static let controllerPath =
        "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/docs/tools/prime-driver-v2-r19-local-archive-build-controller.rb"
    static let supervisorBuildAProduct =
        "/private/tmp/prime-driver-v2-r19-local-archive-build-outer-supervisor-build-a-4e7d6406-861da2f4/PrimeDriverV2R19LocalArchiveBuildOuterSupervisor"
    static let controllerSHA256 =
        "8b85f6320621bc6a5b9c755d983ffcecabf11ea87610b3c5aeaf4359dd194009"
    static let controllerBytes: UInt64 = 55_263
    static let token = Array(
        "PRIME_R19_CRS27_CHILD_GO_4E7D6406_861DA2F4\n".utf8
    )
    static let tokenSHA256 =
        "5861505c461f4f7af080de38ec2243c4c95deae80de883e18a6f0ca833c77c3f"
    static let buildNamespaces = [
        "/private/tmp/prime-driver-v2-r19-local-archive-publisher-source-repair1-build-a-a9129484-d2f23691",
        "/private/tmp/prime-driver-v2-r19-local-archive-publisher-source-repair1-build-b-a9129484-d2f23691",
    ]
    static let archiveNamespaces = [
        "/Users/ergentics/Documents/.PrimeValidationLocalArchive-R19-ce8e584e-f6a03155d136-staging",
        "/Users/ergentics/Documents/PrimeValidationLocalArchive-R19-ce8e584e-f6a03155d136",
    ]
}

private enum PrimeR19ContinuityPhase: String {
    case preEffect = "PRE_EFFECT"
    case effectsMayExist = "EFFECTS_MAY_EXIST"
    case terminalSeal = "TERMINAL_SEAL"
}

private indirect enum PrimeR19JSON {
    case object([(String, PrimeR19JSON)])
    case array([PrimeR19JSON])
    case string(String)
    case unsigned(UInt64)
    case signed(Int64)
    case boolean(Bool)
    case null

    func encoded() throws -> [UInt8] {
        var bytes = [UInt8]()
        try append(to: &bytes)
        return bytes
    }

    private func append(to bytes: inout [UInt8]) throws {
        switch self {
        case let .object(members):
            var seen = Set<String>()
            for member in members where !seen.insert(member.0).inserted {
                throw PrimeR19Failure.rejected
            }
            bytes.append(0x7b)
            let ordered = members.sorted { Array($0.0.utf8).lexicographicallyPrecedes(Array($1.0.utf8)) }
            for index in ordered.indices {
                if index != ordered.startIndex { bytes.append(0x2c) }
                try Self.appendString(ordered[index].0, to: &bytes)
                bytes.append(0x3a)
                try ordered[index].1.append(to: &bytes)
            }
            bytes.append(0x7d)
        case let .array(values):
            bytes.append(0x5b)
            for index in values.indices {
                if index != values.startIndex { bytes.append(0x2c) }
                try values[index].append(to: &bytes)
            }
            bytes.append(0x5d)
        case let .string(value):
            try Self.appendString(value, to: &bytes)
        case let .unsigned(value):
            bytes.append(contentsOf: String(value).utf8)
        case let .signed(value):
            bytes.append(contentsOf: String(value).utf8)
        case let .boolean(value):
            bytes.append(contentsOf: value ? [0x74, 0x72, 0x75, 0x65] : [0x66, 0x61, 0x6c, 0x73, 0x65])
        case .null:
            bytes.append(contentsOf: [0x6e, 0x75, 0x6c, 0x6c])
        }
    }

    private static func appendString(
        _ value: String,
        to bytes: inout [UInt8]
    ) throws {
        bytes.append(0x22)
        for byte in value.utf8 {
            switch byte {
            case 0x22: bytes.append(contentsOf: [0x5c, 0x22])
            case 0x5c: bytes.append(contentsOf: [0x5c, 0x5c])
            case 0x08: bytes.append(contentsOf: [0x5c, 0x62])
            case 0x0c: bytes.append(contentsOf: [0x5c, 0x66])
            case 0x0a: bytes.append(contentsOf: [0x5c, 0x6e])
            case 0x0d: bytes.append(contentsOf: [0x5c, 0x72])
            case 0x09: bytes.append(contentsOf: [0x5c, 0x74])
            case 0x00...0x1f:
                let alphabet = Array("0123456789abcdef".utf8)
                bytes.append(contentsOf: [
                    0x5c, 0x75, 0x30, 0x30,
                    alphabet[Int(byte >> 4)], alphabet[Int(byte & 0x0f)],
                ])
            default:
                bytes.append(byte)
            }
        }
        bytes.append(0x22)
    }
}

private enum PrimeR19Bytes {
    private static let alphabet = Array("0123456789abcdef".utf8)

    static func sha256(_ bytes: [UInt8]) -> String {
        var hasher = SHA256()
        bytes.withUnsafeBytes { hasher.update(bufferPointer: $0) }
        return hex(Array(hasher.finalize()))
    }

    static func hex(_ bytes: [UInt8]) -> String {
        var encoded = [UInt8]()
        encoded.reserveCapacity(bytes.count * 2)
        for byte in bytes {
            encoded.append(alphabet[Int(byte >> 4)])
            encoded.append(alphabet[Int(byte & 0x0f)])
        }
        return String(decoding: encoded, as: UTF8.self)
    }

    static func little32(_ bytes: [UInt8], _ offset: Int) throws -> UInt32 {
        guard offset >= 0, offset <= bytes.count - 4 else {
            throw PrimeR19Failure.rejected
        }
        return UInt32(bytes[offset])
            | UInt32(bytes[offset + 1]) << 8
            | UInt32(bytes[offset + 2]) << 16
            | UInt32(bytes[offset + 3]) << 24
    }

    static func little64(_ bytes: [UInt8], _ offset: Int) throws -> UInt64 {
        UInt64(try little32(bytes, offset))
            | UInt64(try little32(bytes, offset + 4)) << 32
    }

    static func readFile(_ descriptor: Int32, expected: UInt64? = nil) throws -> [UInt8] {
        var metadata = stat()
        guard descriptor >= 3,
              fstat(descriptor, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              metadata.st_size >= 0,
              UInt64(metadata.st_size) <= 33_554_432
        else {
            throw PrimeR19Failure.rejected
        }
        let count = UInt64(metadata.st_size)
        if let expected, count != expected { throw PrimeR19Failure.rejected }
        var bytes = [UInt8](repeating: 0, count: Int(count))
        var offset = 0
        while offset < bytes.count {
            let remaining = bytes.count - offset
            errno = 0
            let returned = bytes.withUnsafeMutableBytes {
                pread(
                    descriptor,
                    $0.baseAddress!.advanced(by: offset),
                    remaining,
                    off_t(offset)
                )
            }
            guard returned > 0 else { throw PrimeR19Failure.rejected }
            offset += returned
        }
        var extra: UInt8 = 0
        errno = 0
        guard pread(descriptor, &extra, 1, off_t(offset)) == 0 else {
            throw PrimeR19Failure.rejected
        }
        return bytes
    }
}

private struct PrimeR19ClockSample {
    let ticks: UInt64
    let timebaseReturn: kern_return_t
    let numerator: UInt32
    let denominator: UInt32

    static func capture() -> PrimeR19ClockSample {
        var info = mach_timebase_info_data_t()
        let result = mach_timebase_info(&info)
        return PrimeR19ClockSample(
            ticks: mach_absolute_time(),
            timebaseReturn: result,
            numerator: info.numer,
            denominator: info.denom
        )
    }

    var json: PrimeR19JSON {
        .object([
            ("denominator", .unsigned(UInt64(denominator))),
            ("numerator", .unsigned(UInt64(numerator))),
            ("return", .signed(Int64(timebaseReturn))),
            ("ticks", .unsigned(ticks)),
        ])
    }
}

private struct PrimeR19FileIdentity: Equatable {
    let device: UInt64
    let inode: UInt64
    let mode: UInt32
    let nlink: UInt64
    let uid: UInt32
    let gid: UInt32
    let flags: UInt32
    let size: UInt64

    init(_ value: stat) throws {
        guard value.st_size >= 0 else { throw PrimeR19Failure.rejected }
        device = UInt64(UInt32(bitPattern: value.st_dev))
        inode = UInt64(value.st_ino)
        mode = UInt32(value.st_mode)
        nlink = UInt64(value.st_nlink)
        uid = value.st_uid
        gid = value.st_gid
        flags = value.st_flags
        size = UInt64(value.st_size)
    }

    var kind: mode_t { mode_t(mode) & mode_t(S_IFMT) }

    var json: PrimeR19JSON {
        .object([
            ("device", .unsigned(device)),
            ("flags", .unsigned(UInt64(flags))),
            ("gid", .unsigned(UInt64(gid))),
            ("inode", .unsigned(inode)),
            ("mode_decimal", .unsigned(UInt64(mode))),
            ("nlink", .unsigned(nlink)),
            ("size", .unsigned(size)),
            ("uid", .unsigned(UInt64(uid))),
        ])
    }
}

private struct PrimeR19HeldFile {
    let descriptor: Int32
    let path: String
    let initial: PrimeR19FileIdentity
    let expectedKind: mode_t
    let expectedPermissions: mode_t?
    let expectedSHA256: String?
    let expectedBytes: UInt64?
    let contentSHA256: String?

    init(
        descriptor: Int32,
        path: String,
        expectedKind: mode_t,
        expectedPermissions: mode_t? = nil,
        expectedSHA256: String? = nil,
        expectedBytes: UInt64? = nil
    ) throws {
        guard descriptor >= 3 else { throw PrimeR19Failure.rejected }
        let descriptorFlags = fcntl(descriptor, F_GETFD)
        guard descriptorFlags >= 0,
              descriptorFlags & FD_CLOEXEC != 0
        else { throw PrimeR19Failure.rejected }
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              path.withCString({ fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW) }) == 0
        else { throw PrimeR19Failure.rejected }
        let heldIdentity = try PrimeR19FileIdentity(held)
        let namedIdentity = try PrimeR19FileIdentity(named)
        guard heldIdentity == namedIdentity,
              heldIdentity.kind == expectedKind,
              heldIdentity.nlink == 1 || expectedKind == mode_t(S_IFDIR)
        else { throw PrimeR19Failure.rejected }
        if let expectedPermissions,
           mode_t(heldIdentity.mode) & mode_t(0o7777) != expectedPermissions {
            throw PrimeR19Failure.rejected
        }
        var observedSHA256: String?
        if expectedKind == mode_t(S_IFREG) {
            let bytes = try PrimeR19Bytes.readFile(descriptor, expected: expectedBytes)
            observedSHA256 = PrimeR19Bytes.sha256(bytes)
            if let expectedSHA256,
               observedSHA256 != expectedSHA256 {
                throw PrimeR19Failure.rejected
            }
        }
        self.descriptor = descriptor
        self.path = path
        initial = heldIdentity
        self.expectedKind = expectedKind
        self.expectedPermissions = expectedPermissions
        self.expectedSHA256 = expectedSHA256
        self.expectedBytes = expectedBytes
        contentSHA256 = observedSHA256
    }

    func rejoin() throws {
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              path.withCString({ fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW) }) == 0
        else { throw PrimeR19Failure.rejected }
        let heldIdentity = try PrimeR19FileIdentity(held)
        let namedIdentity = try PrimeR19FileIdentity(named)
        if expectedKind == mode_t(S_IFDIR) {
            guard heldIdentity.device == initial.device,
                  heldIdentity.inode == initial.inode,
                  heldIdentity.mode == initial.mode,
                  heldIdentity.uid == initial.uid,
                  heldIdentity.gid == initial.gid,
                  heldIdentity.flags == initial.flags,
                  namedIdentity.device == initial.device,
                  namedIdentity.inode == initial.inode,
                  namedIdentity.mode == initial.mode,
                  namedIdentity.uid == initial.uid,
                  namedIdentity.gid == initial.gid,
                  namedIdentity.flags == initial.flags
            else { throw PrimeR19Failure.rejected }
        } else {
            guard heldIdentity == initial,
                  namedIdentity == initial
            else { throw PrimeR19Failure.rejected }
        }
        if expectedKind == mode_t(S_IFREG) {
            let bytes = try PrimeR19Bytes.readFile(descriptor, expected: expectedBytes)
            guard PrimeR19Bytes.sha256(bytes) == contentSHA256 else {
                throw PrimeR19Failure.rejected
            }
        }
    }

    var json: PrimeR19JSON {
        .object([
            ("identity", initial.json),
            ("path", .string(path)),
            ("sha256", contentSHA256.map(PrimeR19JSON.string) ?? .null),
        ])
    }
}

private struct PrimeR19UniqueIdentity: Equatable {
    let uuid: [UInt8]
    let uniqueID: UInt64
    let parentUniqueID: UInt64
    let idVersion: UInt32
    let originalParentIDVersion: UInt32
}

private struct PrimeR19ShortIdentity: Equatable {
    let pid: UInt32
    let parentPID: UInt32
    let processGroup: UInt32
    let status: UInt32
    let command: [UInt8]
    let uid: UInt32
    let gid: UInt32
    let realUID: UInt32
    let realGID: UInt32
    let savedUID: UInt32
    let savedGID: UInt32

    func sameIdentity(as other: Self) -> Bool {
        pid == other.pid && parentPID == other.parentPID
            && processGroup == other.processGroup && command == other.command
            && uid == other.uid && gid == other.gid
            && realUID == other.realUID && realGID == other.realGID
            && savedUID == other.savedUID && savedGID == other.savedGID
    }
}

private struct PrimeR19JoinedProcess: Equatable {
    let unique: PrimeR19UniqueIdentity
    let short: PrimeR19ShortIdentity
    let session: pid_t
    let processGroup: pid_t

    func sameGeneration(as other: Self) -> Bool {
        unique == other.unique && short.sameIdentity(as: other.short)
            && session == other.session && processGroup == other.processGroup
    }

    var json: PrimeR19JSON {
        .object([
            ("command_hex", .string(PrimeR19Bytes.hex(short.command))),
            ("gid", .unsigned(UInt64(short.gid))),
            ("idversion", .unsigned(UInt64(unique.idVersion))),
            ("parent_pid", .unsigned(UInt64(short.parentPID))),
            ("parent_uniqueid", .unsigned(unique.parentUniqueID)),
            ("pgid", .signed(Int64(processGroup))),
            ("pid", .unsigned(UInt64(short.pid))),
            ("process_uuid_hex", .string(PrimeR19Bytes.hex(unique.uuid))),
            ("session", .signed(Int64(session))),
            ("status", .unsigned(UInt64(short.status))),
            ("uid", .unsigned(UInt64(short.uid))),
            ("uniqueid", .unsigned(unique.uniqueID)),
        ])
    }
}

private enum PrimeR19ProcessProof {
    static func requireStoppedChild(
        _ joined: PrimeR19JoinedProcess,
        pid: pid_t,
        owner: PrimeR19JoinedProcess
    ) throws {
        let uid = UInt32(geteuid())
        let gid = UInt32(getegid())
        guard joined.short.pid == UInt32(pid),
              joined.short.parentPID == UInt32(getpid()),
              joined.unique.parentUniqueID == owner.unique.uniqueID,
              joined.unique.originalParentIDVersion == owner.unique.idVersion,
              joined.short.processGroup == UInt32(pid),
              joined.short.status == 4,
              joined.session == pid,
              joined.processGroup == pid,
              joined.short.uid == uid,
              joined.short.realUID == uid,
              joined.short.savedUID == uid,
              joined.short.gid == gid,
              joined.short.realGID == gid,
              joined.short.savedGID == gid
        else { throw PrimeR19Failure.rejected }
    }

}

private struct PrimeR19MappedInspection {
    let device: UInt64
    let inode: UInt64
    let regionCount: Int
    let queryCount: Int
    let executableOffsetZero: Bool

    var json: PrimeR19JSON {
        .object([
            ("device", .unsigned(device)),
            ("executable_offset_zero", .boolean(executableOffsetZero)),
            ("inode", .unsigned(inode)),
            ("query_count", .unsigned(UInt64(queryCount))),
            ("region_count", .unsigned(UInt64(regionCount))),
        ])
    }
}

private enum PrimeR19MappedImage {
    private static let regionBytes = 1_272
    private static let queryCap = 65_536

    static func discoverAndHoldSelf() throws -> PrimeR19HeldFile {
        guard MemoryLayout<proc_regionwithpathinfo>.size == regionBytes else {
            throw PrimeR19Failure.rejected
        }
        let exactPath = Array(PrimeR19Fixed.supervisorBuildAProduct.utf8)
        var address: UInt64 = 0
        var candidatePath: [UInt8]?
        var candidateDevice: UInt32?
        var candidateInode: UInt64?
        var reachedEnd = false
        for _ in 0..<queryCap {
            let record = try region(pid: getpid(), address: address)
            if record.end {
                reachedEnd = true
                break
            }
            guard record.next > address else { throw PrimeR19Failure.rejected }
            address = record.next
            if record.path == exactPath,
               record.fileOffset == 0,
               record.protection & UInt32(VM_PROT_EXECUTE) != 0 {
                guard candidatePath == nil else { throw PrimeR19Failure.rejected }
                candidatePath = record.path
                candidateDevice = record.device
                candidateInode = record.inode
            }
        }
        guard reachedEnd,
              let bytes = candidatePath,
              let device = candidateDevice,
              let inode = candidateInode
        else { throw PrimeR19Failure.rejected }
        let path = String(decoding: bytes, as: UTF8.self)
        let descriptor = path.withCString {
            Darwin.open($0, O_RDONLY | O_CLOEXEC | O_NOFOLLOW)
        }
        guard descriptor >= 3 else { throw PrimeR19Failure.rejected }
        do {
            let held = try PrimeR19HeldFile(
                descriptor: descriptor,
                path: path,
                expectedKind: mode_t(S_IFREG)
            )
            guard held.initial.device == UInt64(device),
                  held.initial.inode == inode
            else { throw PrimeR19Failure.rejected }
            _ = try inspect(pid: getpid(), held: held)
            return held
        } catch {
            _ = Darwin.close(descriptor)
            throw error
        }
    }

    static func inspect(
        pid: pid_t,
        held: PrimeR19HeldFile
    ) throws -> PrimeR19MappedInspection {
        guard held.expectedKind == mode_t(S_IFREG) else {
            throw PrimeR19Failure.rejected
        }
        let expectedPath = Array(held.path.utf8)
        var address: UInt64 = 0
        var count = 0
        var queries = 0
        var executableOffsetZero = false
        var reachedEnd = false
        while queries < queryCap {
            let record = try region(pid: pid, address: address)
            queries += 1
            if record.end {
                reachedEnd = true
                break
            }
            guard record.next > address else { throw PrimeR19Failure.rejected }
            address = record.next
            let pathMatches = record.path == expectedPath
            let vnodeMatches = UInt64(record.device) == held.initial.device
                && record.inode == held.initial.inode
            if pathMatches || vnodeMatches {
                guard pathMatches, vnodeMatches else {
                    throw PrimeR19Failure.rejected
                }
                count += 1
                if record.fileOffset == 0,
                   record.protection & UInt32(VM_PROT_EXECUTE) != 0 {
                    executableOffsetZero = true
                }
            }
        }
        guard reachedEnd, count > 0, executableOffsetZero
        else { throw PrimeR19Failure.rejected }
        return PrimeR19MappedInspection(
            device: held.initial.device,
            inode: held.initial.inode,
            regionCount: count,
            queryCount: queries,
            executableOffsetZero: true
        )
    }

    private struct Region {
        let end: Bool
        let next: UInt64
        let protection: UInt32
        let fileOffset: UInt64
        let device: UInt32
        let inode: UInt64
        let path: [UInt8]
    }

    private static func region(pid: pid_t, address: UInt64) throws -> Region {
        var bytes = [UInt8](repeating: 0, count: regionBytes)
        errno = 0
        let returned = bytes.withUnsafeMutableBytes {
            proc_pidinfo(
                pid, PROC_PIDREGIONPATHINFO, address,
                $0.baseAddress, Int32($0.count)
            )
        }
        let callErrno = errno
        if returned == 0 {
            guard callErrno == EINVAL else { throw PrimeR19Failure.rejected }
            return Region(
                end: true, next: address, protection: 0,
                fileOffset: 0, device: 0, inode: 0, path: []
            )
        }
        guard returned == Int32(regionBytes) else {
            throw PrimeR19Failure.rejected
        }
        let regionAddress = try PrimeR19Bytes.little64(bytes, 80)
        let regionSize = try PrimeR19Bytes.little64(bytes, 88)
        let following = regionAddress.addingReportingOverflow(regionSize)
        guard regionAddress >= address,
              regionSize > 0,
              !following.overflow,
              following.partialValue > regionAddress
        else { throw PrimeR19Failure.rejected }
        let pathField = bytes[248..<regionBytes]
        guard let terminator = pathField.firstIndex(of: 0) else {
            throw PrimeR19Failure.rejected
        }
        return Region(
            end: false,
            next: following.partialValue,
            protection: try PrimeR19Bytes.little32(bytes, 0),
            fileOffset: try PrimeR19Bytes.little64(bytes, 16),
            device: try PrimeR19Bytes.little32(bytes, 96),
            inode: try PrimeR19Bytes.little64(bytes, 104),
            path: Array(pathField[..<terminator])
        )
    }
}

private struct PrimeR19CWDInspection {
    let device: UInt64
    let inode: UInt64

    var json: PrimeR19JSON {
        .object([
            ("device", .unsigned(device)),
            ("inode", .unsigned(inode)),
        ])
    }
}

private enum PrimeR19ChildInspection {
    static func cwd(pid: pid_t, heldRoot: PrimeR19HeldFile) throws -> PrimeR19CWDInspection {
        guard MemoryLayout<proc_vnodepathinfo>.size == 2_352 else {
            throw PrimeR19Failure.rejected
        }
        var raw = [UInt8](repeating: 0, count: 2_352)
        errno = 0
        let returned = raw.withUnsafeMutableBytes {
            proc_pidinfo(
                pid, PROC_PIDVNODEPATHINFO, 0,
                $0.baseAddress, Int32($0.count)
            )
        }
        guard returned == 2_352,
              try PrimeR19Bytes.little32(raw, 0)
                == UInt32(heldRoot.initial.device),
              try PrimeR19Bytes.little64(raw, 8) == heldRoot.initial.inode,
              try PrimeR19Bytes.little32(raw, 4) & UInt32(S_IFMT)
                == UInt32(S_IFDIR),
              raw[152] == 0x2f,
              raw[153] == 0
        else { throw PrimeR19Failure.rejected }
        return PrimeR19CWDInspection(
            device: heldRoot.initial.device,
            inode: heldRoot.initial.inode
        )
    }

}

private final class PrimeR19DurableAdmissionToken {
    let rawSHA256: String
    let frameSHA256: String
    private init(rawSHA256: String, frameSHA256: String) {
        self.rawSHA256 = rawSHA256
        self.frameSHA256 = frameSHA256
    }
    fileprivate static func issue(
        rawSHA256: String,
        frameSHA256: String
    ) -> PrimeR19DurableAdmissionToken {
        PrimeR19DurableAdmissionToken(
            rawSHA256: rawSHA256,
            frameSHA256: frameSHA256
        )
    }
}

private struct PrimeR19ChildAdmissionRaw {
    private struct Call {
        let bytes: [UInt8]
        let returned: Int32
        let callErrno: Int32
        var json: PrimeR19JSON {
            .object([
                ("errno_non_authoritative_when_return_positive", .signed(Int64(callErrno))),
                ("raw_hex", .string(PrimeR19Bytes.hex(bytes))),
                ("return_bytes", .signed(Int64(returned))),
            ])
        }
    }

    let child: pid_t
    let generation0: PrimeR19RawProcessAttempt
    let generation1: PrimeR19RawProcessAttempt
    private let list: Call
    private let cwd: Call
    private let childFD0: Call
    private let childFD1: Call
    private let childFD2: Call
    private let parentStdout: Call
    private let parentStderr: Call

    static func capture(
        child: pid_t,
        stdoutRead: Int32,
        stderrRead: Int32
    ) -> PrimeR19ChildAdmissionRaw {
        func pidInfo(_ flavor: Int32, _ argument: UInt64, _ count: Int) -> Call {
            var bytes = [UInt8](repeating: 0, count: count)
            errno = 0
            let returned = bytes.withUnsafeMutableBytes {
                proc_pidinfo(
                    child, flavor, argument,
                    $0.baseAddress, Int32($0.count)
                )
            }
            return Call(bytes: bytes, returned: returned, callErrno: errno)
        }
        func fdInfo(_ pid: pid_t, _ descriptor: Int32, _ flavor: Int32, _ count: Int) -> Call {
            var bytes = [UInt8](repeating: 0, count: count)
            errno = 0
            let returned = bytes.withUnsafeMutableBytes {
                proc_pidfdinfo(
                    pid, descriptor, flavor,
                    $0.baseAddress, Int32($0.count)
                )
            }
            return Call(bytes: bytes, returned: returned, callErrno: errno)
        }
        let generation0 = PrimeR19RawProcessAttempt.capture(pid: child)
        let list = pidInfo(PROC_PIDLISTFDS, 0, 32)
        let cwd = pidInfo(PROC_PIDVNODEPATHINFO, 0, 2_352)
        let fd0 = fdInfo(child, STDIN_FILENO, PROC_PIDFDVNODEPATHINFO, 1_200)
        let fd1 = fdInfo(child, STDOUT_FILENO, PROC_PIDFDPIPEINFO, 184)
        let fd2 = fdInfo(child, STDERR_FILENO, PROC_PIDFDPIPEINFO, 184)
        let parentOut = fdInfo(getpid(), stdoutRead, PROC_PIDFDPIPEINFO, 184)
        let parentErr = fdInfo(getpid(), stderrRead, PROC_PIDFDPIPEINFO, 184)
        let generation1 = PrimeR19RawProcessAttempt.capture(pid: child)
        return PrimeR19ChildAdmissionRaw(
            child: child,
            generation0: generation0,
            generation1: generation1,
            list: list,
            cwd: cwd,
            childFD0: fd0,
            childFD1: fd1,
            childFD2: fd2,
            parentStdout: parentOut,
            parentStderr: parentErr
        )
    }

    private var canonicalRaw: [UInt8] {
        var value = [UInt8]()
        for bytes in [
            list.bytes, cwd.bytes, childFD0.bytes, childFD1.bytes,
            childFD2.bytes, parentStdout.bytes, parentStderr.bytes,
            generation0.unique0, generation0.short0,
            generation0.short1, generation0.unique1,
            generation1.unique0, generation1.short0,
            generation1.short1, generation1.unique1,
        ] { value.append(contentsOf: bytes) }
        return value
    }

    var rawSHA256: String { PrimeR19Bytes.sha256(canonicalRaw) }

    var rawJSON: PrimeR19JSON {
        .object([
            ("child_fd0_vnode_1200", childFD0.json),
            ("child_fd1_pipe_184", childFD1.json),
            ("child_fd2_pipe_184", childFD2.json),
            ("child_pidlistfds_32", list.json),
            ("child_vnodepath_2352", cwd.json),
            ("generation0", generation0.rawJSON),
            ("generation1", generation1.rawJSON),
            ("parent_stderr_read_pipe_184", parentStderr.json),
            ("parent_stdout_read_pipe_184", parentStdout.json),
            ("proc_pidfdinfo_calls_exact", .unsigned(5)),
            ("raw_sha256", .string(rawSHA256)),
        ])
    }

    func decode(
        token: PrimeR19DurableAdmissionToken,
        expected: PrimeR19JoinedProcess,
        owner: PrimeR19JoinedProcess,
        controller: PrimeR19HeldFile,
        root: PrimeR19HeldFile,
        stdoutReadFD: Int32,
        stderrReadFD: Int32
    ) throws -> PrimeR19JSON {
        guard token.rawSHA256 == rawSHA256,
              token.frameSHA256.count == 64,
              list.returned == 24,
              cwd.returned == 2_352,
              childFD0.returned == 1_200,
              childFD1.returned == 184,
              childFD2.returned == 184,
              parentStdout.returned == 184,
              parentStderr.returned == 184
        else { throw PrimeR19Failure.rejected }
        let joined0 = try generation0.decode(
            expectedUniqueID: expected.unique.uniqueID
        )
        let joined1 = try generation1.decode(
            expectedUniqueID: expected.unique.uniqueID
        )
        guard joined0.sameGeneration(as: joined1),
              joined1.sameGeneration(as: expected)
        else { throw PrimeR19Failure.rejected }
        try PrimeR19ProcessProof.requireStoppedChild(
            joined1, pid: child, owner: owner
        )

        var listed = [(Int32, UInt32)]()
        for offset in stride(from: 0, to: 24, by: 8) {
            listed.append((
                Int32(bitPattern: try PrimeR19Bytes.little32(list.bytes, offset)),
                try PrimeR19Bytes.little32(list.bytes, offset + 4)
            ))
        }
        let sorted = listed.sorted(by: { $0.0 < $1.0 })
        guard sorted.count == 3,
              sorted[0].0 == 0, sorted[0].1 == 1,
              sorted[1].0 == 1, sorted[1].1 == 6,
              sorted[2].0 == 2, sorted[2].1 == 6
        else { throw PrimeR19Failure.rejected }

        func cString(_ bytes: [UInt8], at offset: Int) throws -> [UInt8] {
            guard offset < bytes.count,
                  let end = bytes[offset...].firstIndex(of: 0)
            else { throw PrimeR19Failure.rejected }
            return Array(bytes[offset..<end])
        }
        guard try cString(cwd.bytes, at: 152) == [0x2f],
              try PrimeR19Bytes.little32(cwd.bytes, 0) == UInt32(root.initial.device),
              try PrimeR19Bytes.little64(cwd.bytes, 8) == root.initial.inode,
              try PrimeR19Bytes.little32(childFD0.bytes, 0) & UInt32(O_ACCMODE)
                == UInt32(O_RDONLY),
              try PrimeR19Bytes.little32(childFD0.bytes, 4) & UInt32(PROC_FP_CLEXEC) == 0,
              try PrimeR19Bytes.little64(childFD0.bytes, 8) == 0,
              try PrimeR19Bytes.little32(childFD0.bytes, 16) == 1,
              try PrimeR19Bytes.little32(childFD0.bytes, 24)
                == UInt32(controller.initial.device),
              try PrimeR19Bytes.little64(childFD0.bytes, 32)
                == controller.initial.inode,
              try cString(childFD0.bytes, at: 176)
                == Array(PrimeR19Fixed.controllerPath.utf8)
        else { throw PrimeR19Failure.rejected }

        func pipe(_ call: Call, write: Bool) throws -> (
            device: UInt32, inode: UInt64, handle: UInt64, peer: UInt64
        ) {
            guard try PrimeR19Bytes.little32(call.bytes, 0) & UInt32(O_ACCMODE)
                    == UInt32(write ? O_WRONLY : O_RDONLY),
                  try PrimeR19Bytes.little32(call.bytes, 4)
                    & UInt32(PROC_FP_CLEXEC) == (write ? 0 : UInt32(PROC_FP_CLEXEC)),
                  try PrimeR19Bytes.little32(call.bytes, 16) == 6,
                  try PrimeR19Bytes.little32(call.bytes, 180) == 0
            else { throw PrimeR19Failure.rejected }
            return (
                try PrimeR19Bytes.little32(call.bytes, 24),
                try PrimeR19Bytes.little64(call.bytes, 32),
                try PrimeR19Bytes.little64(call.bytes, 160),
                try PrimeR19Bytes.little64(call.bytes, 168)
            )
        }
        let childOut = try pipe(childFD1, write: true)
        let childErr = try pipe(childFD2, write: true)
        let parentOut = try pipe(parentStdout, write: false)
        let parentErr = try pipe(parentStderr, write: false)
        guard childOut.handle == parentOut.peer,
              childOut.peer == parentOut.handle,
              childErr.handle == parentErr.peer,
              childErr.peer == parentErr.handle,
              Set([childOut.handle, childOut.peer]).isDisjoint(
                with: Set([childErr.handle, childErr.peer])
              ),
              childOut.device != childErr.device || childOut.inode != childErr.inode,
              stdoutReadFD >= 3,
              stderrReadFD >= 3,
              stdoutReadFD != stderrReadFD
        else { throw PrimeR19Failure.rejected }
        return .object([
            ("child", joined1.json),
            ("cwd_exact_slash", .boolean(true)),
            ("fd0_controller_exact", .boolean(true)),
            ("fd1_fd2_cross_joined_parent_reads", .boolean(true)),
            ("pipe_sets_disjoint", .boolean(true)),
            ("raw_frame_sha256", .string(token.frameSHA256)),
        ])
    }
}

private final class PrimeR19FullSyncBudget {
    private var nextOrdinal: UInt32 = 1

    func synchronize(_ descriptor: Int32) throws {
        guard descriptor >= 3,
              nextOrdinal <= 96,
              fsync(descriptor) == 0
        else { throw PrimeR19Failure.rejected }
        var callErrno: Int32 = 0
        let result = primeR19FullFSync(descriptor, nextOrdinal, &callErrno)
        nextOrdinal += 1
        guard result == 0 else {
            throw PrimeR19Failure.rejected
        }
    }
}

private struct PrimeR19SupervisorFDIdentity: Equatable {
    let inputDevice: UInt32
    let inputInode: UInt64
    let inputRdev: UInt32
    let outputDevice: UInt32
    let outputInode: UInt64
    let outputHandle: UInt64
    let outputPeer: UInt64
    let errorDevice: UInt32
    let errorInode: UInt64
    let errorHandle: UInt64
    let errorPeer: UInt64

    static func capture() throws -> PrimeR19SupervisorFDIdentity {
        func fdInfo(_ descriptor: Int32, _ flavor: Int32, _ count: Int) throws -> [UInt8] {
            var raw = [UInt8](repeating: 0, count: count)
            errno = 0
            let result = raw.withUnsafeMutableBytes {
                proc_pidfdinfo(
                    getpid(), descriptor, flavor,
                    $0.baseAddress, Int32($0.count)
                )
            }
            guard result == Int32(count) else { throw PrimeR19Failure.rejected }
            return raw
        }
        func rawCString(_ raw: [UInt8], _ offset: Int) throws -> [UInt8] {
            guard let end = raw[offset...].firstIndex(of: 0) else {
                throw PrimeR19Failure.rejected
            }
            return Array(raw[offset..<end])
        }
        let input = try fdInfo(STDIN_FILENO, PROC_PIDFDVNODEPATHINFO, 1_200)
        let output = try fdInfo(STDOUT_FILENO, PROC_PIDFDPIPEINFO, 184)
        let error = try fdInfo(STDERR_FILENO, PROC_PIDFDPIPEINFO, 184)
        var namedNull = stat()
        guard "/dev/null".withCString({
                  fstatat(AT_FDCWD, $0, &namedNull, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              try PrimeR19Bytes.little32(input, 0) & UInt32(O_ACCMODE)
                == UInt32(O_RDONLY),
              try PrimeR19Bytes.little32(input, 4) & UInt32(PROC_FP_CLEXEC) == 0,
              try PrimeR19Bytes.little64(input, 8) == 0,
              try PrimeR19Bytes.little32(input, 16) == 1,
              try PrimeR19Bytes.little32(input, 24)
                == UInt32(bitPattern: namedNull.st_dev),
              try PrimeR19Bytes.little64(input, 32) == UInt64(namedNull.st_ino),
              try PrimeR19Bytes.little32(input, 140) == UInt32(namedNull.st_rdev),
              try rawCString(input, 176) == Array("/dev/null".utf8),
              try PrimeR19Bytes.little32(output, 0) & UInt32(O_ACCMODE)
                == UInt32(O_WRONLY),
              try PrimeR19Bytes.little32(error, 0) & UInt32(O_ACCMODE)
                == UInt32(O_WRONLY),
              try PrimeR19Bytes.little32(output, 4) & UInt32(PROC_FP_CLEXEC) == 0,
              try PrimeR19Bytes.little32(error, 4) & UInt32(PROC_FP_CLEXEC) == 0,
              try PrimeR19Bytes.little32(output, 16) == 6,
              try PrimeR19Bytes.little32(error, 16) == 6,
              try PrimeR19Bytes.little32(output, 180) == 0,
              try PrimeR19Bytes.little32(error, 180) == 0
        else { throw PrimeR19Failure.rejected }
        let value = PrimeR19SupervisorFDIdentity(
            inputDevice: try PrimeR19Bytes.little32(input, 24),
            inputInode: try PrimeR19Bytes.little64(input, 32),
            inputRdev: try PrimeR19Bytes.little32(input, 140),
            outputDevice: try PrimeR19Bytes.little32(output, 24),
            outputInode: try PrimeR19Bytes.little64(output, 32),
            outputHandle: try PrimeR19Bytes.little64(output, 160),
            outputPeer: try PrimeR19Bytes.little64(output, 168),
            errorDevice: try PrimeR19Bytes.little32(error, 24),
            errorInode: try PrimeR19Bytes.little64(error, 32),
            errorHandle: try PrimeR19Bytes.little64(error, 160),
            errorPeer: try PrimeR19Bytes.little64(error, 168)
        )
        guard value.outputHandle != value.errorHandle,
              value.outputPeer != value.errorPeer,
              value.outputDevice != value.errorDevice
                || value.outputInode != value.errorInode
        else { throw PrimeR19Failure.rejected }
        return value
    }

    func rejoin() throws {
        guard try Self.capture() == self else { throw PrimeR19Failure.rejected }
    }

    var json: PrimeR19JSON {
        .object([
            ("input_device", .unsigned(UInt64(inputDevice))),
            ("input_inode", .unsigned(inputInode)),
            ("input_rdev", .unsigned(UInt64(inputRdev))),
            ("stderr_handle", .unsigned(errorHandle)),
            ("stderr_inode", .unsigned(errorInode)),
            ("stderr_peerhandle", .unsigned(errorPeer)),
            ("stdout_handle", .unsigned(outputHandle)),
            ("stdout_inode", .unsigned(outputInode)),
            ("stdout_peerhandle", .unsigned(outputPeer)),
        ])
    }
}

private final class PrimeR19Authorities {
    let parent: PrimeR19HeldFile
    let root: PrimeR19HeldFile
    let journal: PrimeR19HeldFile
    let fifoInitial: PrimeR19FileIdentity
    let selfImage: PrimeR19HeldFile
    let ruby: PrimeR19HeldFile
    let controller: PrimeR19HeldFile
    let cwdRoot: PrimeR19HeldFile
    let supervisorStandardFDs: PrimeR19SupervisorFDIdentity
    let syncBudget = PrimeR19FullSyncBudget()
    private(set) var fifoDescriptor: Int32 = -1
    private var closed = false

    static func create(
        supervisorStandardFDs: PrimeR19SupervisorFDIdentity
    ) throws -> PrimeR19Authorities {
        var callErrno: Int32 = 0
        let parentFD = primeR19OpenRuntimeParent(1, &callErrno)
        guard parentFD >= 3 else { throw PrimeR19Failure.rejected }
        var owned = [parentFD]
        do {
            let parent = try PrimeR19HeldFile(
                descriptor: parentFD,
                path: "/private/tmp",
                expectedKind: mode_t(S_IFDIR),
                expectedPermissions: mode_t(0o1777)
            )
            callErrno = 0
            guard primeR19MkdirRuntimeRoot(parentFD, 1, &callErrno) == 0
            else { throw PrimeR19Failure.rejected }
            callErrno = 0
            let rootFD = primeR19OpenRuntimeRoot(parentFD, 1, &callErrno)
            guard rootFD >= 3 else { throw PrimeR19Failure.rejected }
            owned.append(rootFD)
            _ = try PrimeR19HeldFile(
                descriptor: rootFD,
                path: PrimeR19Fixed.runtimeRoot,
                expectedKind: mode_t(S_IFDIR),
                expectedPermissions: mode_t(0o700)
            )
            callErrno = 0
            let journalFD = primeR19CreateJournal(rootFD, 1, &callErrno)
            guard journalFD >= 3 else { throw PrimeR19Failure.rejected }
            owned.append(journalFD)
            let journal = try PrimeR19HeldFile(
                descriptor: journalFD,
                path: PrimeR19Fixed.runtimeRoot + "/" + PrimeR19Fixed.journalLeaf,
                expectedKind: mode_t(S_IFREG),
                expectedPermissions: mode_t(0o600),
                expectedBytes: 0
            )
            callErrno = 0
            guard primeR19CreateFIFO(rootFD, 1, &callErrno) == 0
            else { throw PrimeR19Failure.rejected }
            let fifo = try Self.namedFIFO(rootFD: rootFD)
            let root = try PrimeR19HeldFile(
                descriptor: rootFD,
                path: PrimeR19Fixed.runtimeRoot,
                expectedKind: mode_t(S_IFDIR),
                expectedPermissions: mode_t(0o700)
            )

            let selfImage = try PrimeR19MappedImage.discoverAndHoldSelf()
            owned.append(selfImage.descriptor)
            callErrno = 0
            let rubyFD = primeR19OpenRubyImage(1, &callErrno)
            guard rubyFD >= 3 else { throw PrimeR19Failure.rejected }
            owned.append(rubyFD)
            let ruby = try PrimeR19HeldFile(
                descriptor: rubyFD,
                path: PrimeR19Fixed.rubyPath,
                expectedKind: mode_t(S_IFREG)
            )
            callErrno = 0
            let controllerFD = primeR19OpenControllerSource(1, &callErrno)
            guard controllerFD >= 3 else { throw PrimeR19Failure.rejected }
            owned.append(controllerFD)
            let controller = try PrimeR19HeldFile(
                descriptor: controllerFD,
                path: PrimeR19Fixed.controllerPath,
                expectedKind: mode_t(S_IFREG),
                expectedSHA256: PrimeR19Fixed.controllerSHA256,
                expectedBytes: PrimeR19Fixed.controllerBytes
            )
            callErrno = 0
            let cwdFD = primeR19OpenCWDRoot(1, &callErrno)
            guard cwdFD >= 3 else { throw PrimeR19Failure.rejected }
            owned.append(cwdFD)
            let cwdRoot = try PrimeR19HeldFile(
                descriptor: cwdFD,
                path: "/",
                expectedKind: mode_t(S_IFDIR),
                expectedPermissions: mode_t(0o755)
            )
            guard fcntl(parentFD, F_GETFL) & O_ACCMODE == O_RDONLY,
                  fcntl(rootFD, F_GETFL) & O_ACCMODE == O_RDONLY,
                  fcntl(journalFD, F_GETFL) & O_ACCMODE == O_RDWR,
                  fcntl(selfImage.descriptor, F_GETFL) & O_ACCMODE == O_RDONLY,
                  fcntl(rubyFD, F_GETFL) & O_ACCMODE == O_RDONLY,
                  fcntl(controllerFD, F_GETFL) & O_ACCMODE == O_RDONLY,
                  fcntl(cwdFD, F_GETFL) & O_ACCMODE == O_RDONLY,
                  lseek(controllerFD, 0, SEEK_CUR) == 0
            else { throw PrimeR19Failure.rejected }
            let value = try PrimeR19Authorities(
                parent: parent,
                root: root,
                journal: journal,
                fifoInitial: fifo,
                selfImage: selfImage,
                ruby: ruby,
                controller: controller,
                cwdRoot: cwdRoot,
                supervisorStandardFDs: supervisorStandardFDs
            )
            try value.requireTargets(for: .preEffect)
            return value
        } catch {
            for descriptor in owned.reversed() { _ = Darwin.close(descriptor) }
            throw error
        }
    }

    private init(
        parent: PrimeR19HeldFile,
        root: PrimeR19HeldFile,
        journal: PrimeR19HeldFile,
        fifoInitial: PrimeR19FileIdentity,
        selfImage: PrimeR19HeldFile,
        ruby: PrimeR19HeldFile,
        controller: PrimeR19HeldFile,
        cwdRoot: PrimeR19HeldFile,
        supervisorStandardFDs: PrimeR19SupervisorFDIdentity
    ) throws {
        self.parent = parent
        self.root = root
        self.journal = journal
        self.fifoInitial = fifoInitial
        self.selfImage = selfImage
        self.ruby = ruby
        self.controller = controller
        self.cwdRoot = cwdRoot
        self.supervisorStandardFDs = supervisorStandardFDs
    }

    deinit { closeAll() }

    func closeAll() {
        if closed { return }
        closed = true
        if fifoDescriptor >= 0 { _ = Darwin.close(fifoDescriptor) }
        _ = Darwin.close(cwdRoot.descriptor)
        _ = Darwin.close(controller.descriptor)
        _ = Darwin.close(ruby.descriptor)
        _ = Darwin.close(selfImage.descriptor)
        _ = Darwin.close(journal.descriptor)
        _ = Darwin.close(root.descriptor)
        _ = Darwin.close(parent.descriptor)
    }

    func openFIFOAfterReady() throws {
        guard fifoDescriptor == -1 else { throw PrimeR19Failure.rejected }
        var callErrno: Int32 = 0
        let descriptor = primeR19OpenFIFORead(root.descriptor, 1, &callErrno)
        guard descriptor >= 3 else { throw PrimeR19Failure.rejected }
        fifoDescriptor = descriptor
        do {
            try rejoinFIFODescriptor()
        } catch {
            throw error
        }
    }

    func rejoinAll(
        includeFIFODescriptor: Bool,
        phase: PrimeR19ContinuityPhase,
        journalPrefix: Int,
        enforceContinuityCandidates: Bool = true
    ) throws {
        try parent.rejoin()
        try root.rejoin()
        try selfImage.rejoin()
        try ruby.rejoin()
        try controller.rejoin()
        try cwdRoot.rejoin()
        try supervisorStandardFDs.rejoin()
        _ = try PrimeR19ChildInspection.cwd(pid: getpid(), heldRoot: cwdRoot)
        let controllerOffset = lseek(controller.descriptor, 0, SEEK_CUR)
        switch phase {
        case .preEffect:
            guard controllerOffset == 0 else { throw PrimeR19Failure.rejected }
        case .effectsMayExist:
            if enforceContinuityCandidates {
                guard controllerOffset >= 0,
                      controllerOffset <= off_t(PrimeR19Fixed.controllerBytes)
                else { throw PrimeR19Failure.rejected }
            }
        case .terminalSeal:
            // Offset equality is a terminal candidate predicate recorded by
            // the journal. It is not an invariant that may suppress FAIL.
            break
        }
        try rejoinJournalMutable(prefix: journalPrefix)
        guard try Self.namedFIFO(rootFD: root.descriptor) == fifoInitial else {
            throw PrimeR19Failure.rejected
        }
        if includeFIFODescriptor { try rejoinFIFODescriptor() }
        _ = try PrimeR19MappedImage.inspect(pid: getpid(), held: selfImage)
        if enforceContinuityCandidates
            && (phase == .preEffect || phase == .effectsMayExist) {
            try requireTargets(for: phase)
        }
    }

    func rejoinFIFODescriptor() throws {
        guard fifoDescriptor >= 3,
              fcntl(fifoDescriptor, F_GETFD) & FD_CLOEXEC != 0,
              fcntl(fifoDescriptor, F_GETFL) & O_ACCMODE == O_RDONLY
        else { throw PrimeR19Failure.rejected }
        var held = stat()
        guard fstat(fifoDescriptor, &held) == 0,
              try PrimeR19FileIdentity(held) == fifoInitial,
              try Self.namedFIFO(rootFD: root.descriptor) == fifoInitial
        else { throw PrimeR19Failure.rejected }
    }

    func rejoinJournalMutable(prefix: Int) throws {
        var held = stat()
        var named = stat()
        guard fstat(journal.descriptor, &held) == 0,
              PrimeR19Fixed.journalLeaf.withCString({
                  fstatat(root.descriptor, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              held.st_mode & mode_t(0o7777) == mode_t(0o600),
              named.st_mode & mode_t(0o7777) == mode_t(0o600),
              held.st_uid == 501,
              named.st_uid == 501,
              held.st_gid == 20,
              named.st_gid == 20,
              held.st_flags == 0,
              named.st_flags == 0,
              held.st_nlink == 1,
              named.st_nlink == 1,
              held.st_size == off_t(prefix),
              named.st_size == off_t(prefix),
              fcntl(journal.descriptor, F_GETFD) & FD_CLOEXEC != 0,
              fcntl(journal.descriptor, F_GETFL) & O_ACCMODE == O_RDWR,
              lseek(journal.descriptor, 0, SEEK_CUR) == off_t(prefix)
        else { throw PrimeR19Failure.rejected }
    }

    func requireTargets(for phase: PrimeR19ContinuityPhase) throws {
        let requiredAbsent: [String]
        switch phase {
        case .preEffect:
            requiredAbsent = PrimeR19Fixed.buildNamespaces
                + PrimeR19Fixed.archiveNamespaces
        case .effectsMayExist, .terminalSeal:
            requiredAbsent = PrimeR19Fixed.archiveNamespaces
        }
        for path in requiredAbsent {
            var value = stat()
            errno = 0
            let result = path.withCString {
                fstatat(AT_FDCWD, $0, &value, AT_SYMLINK_NOFOLLOW)
            }
            guard result == -1, errno == ENOENT else {
                throw PrimeR19Failure.rejected
            }
        }
    }

    var fixedInputsJSON: PrimeR19JSON {
        .object([
            ("controller", controller.json),
            ("cwd_root", cwdRoot.json),
            ("fifo", fifoInitial.json),
            ("ruby", ruby.json),
            ("runtime_parent", parent.json),
            ("runtime_root", root.json),
            ("self_image", selfImage.json),
            ("supervisor_standard_fds", supervisorStandardFDs.json),
            ("pre_effect_target_namespaces_absent", .array(
                (PrimeR19Fixed.buildNamespaces + PrimeR19Fixed.archiveNamespaces)
                    .map(PrimeR19JSON.string)
            )),
        ])
    }

    private static func namedFIFO(rootFD: Int32) throws -> PrimeR19FileIdentity {
        var value = stat()
        guard PrimeR19Fixed.fifoLeaf.withCString({
            fstatat(rootFD, $0, &value, AT_SYMLINK_NOFOLLOW)
        }) == 0 else { throw PrimeR19Failure.rejected }
        let identity = try PrimeR19FileIdentity(value)
        guard identity.kind == mode_t(S_IFIFO),
              mode_t(identity.mode) & mode_t(0o7777) == mode_t(0o600),
              identity.nlink == 1,
              identity.size == 0
        else { throw PrimeR19Failure.rejected }
        return identity
    }
}

private final class PrimeR19Journal {
    private static let maximumJournalBytes = 4_194_304
    private let authorities: PrimeR19Authorities
    private var prefix = [UInt8]()
    private var previousFrameSHA256: String?
    private(set) var nextOrdinal: UInt64 = 0
    private(set) var poisoned = false
    private(set) var phase = PrimeR19ContinuityPhase.preEffect
    private(set) var terminalEvidence = false
    private(set) var exactDirectReapObserved = false
    var durablePrefixBytes: Int { prefix.count }
    private var inventoryOrdinals = Set<UInt32>()
    private(set) var terminalObservedControllerOffset: off_t?
    private(set) var terminalArchiveNamespacesAbsent = false
    private var stdoutPipe: PrimeR19Pipe?
    private var stderrPipe: PrimeR19Pipe?
    private var mappedChildPID: pid_t?
    private var mappedChildUniqueID: UInt64?

    init(authorities: PrimeR19Authorities) throws {
        self.authorities = authorities
        try authorities.rejoinAll(
            includeFIFODescriptor: false,
            phase: .preEffect,
            journalPrefix: 0
        )
        var metadata = stat()
        guard fstat(authorities.journal.descriptor, &metadata) == 0,
              metadata.st_size == 0
        else { throw PrimeR19Failure.rejected }
        try authorities.syncBudget.synchronize(authorities.root.descriptor)
        try authorities.syncBudget.synchronize(authorities.parent.descriptor)
    }

    @discardableResult
    func publish(
        schema: String,
        status: String,
        members: [(String, PrimeR19JSON)]
    ) throws -> [UInt8] {
        guard !poisoned else { throw PrimeR19Failure.rejected }
        poisoned = true
        try rejoinRegisteredRuntimeState()
        try authorities.rejoinAll(
            includeFIFODescriptor: authorities.fifoDescriptor >= 3,
            phase: phase,
            journalPrefix: prefix.count,
            enforceContinuityCandidates: !terminalEvidence
        )
        var payloadMembers = members
        payloadMembers.append(("ordinal", .unsigned(nextOrdinal)))
        payloadMembers.append((
            "previous_frame_sha256",
            previousFrameSHA256.map(PrimeR19JSON.string) ?? .null
        ))
        let payload = PrimeR19JSON.object(payloadMembers)
        let payloadBytes = try payload.encoded()
        let frame = PrimeR19JSON.object([
            ("payload", payload),
            ("payload_hash_rule", .string(PrimeR19Fixed.payloadHashRule)),
            ("payload_sha256", .string(PrimeR19Bytes.sha256(payloadBytes))),
            ("schema", .string(schema)),
            ("status", .string(status)),
        ])
        var frameBytes = try frame.encoded()
        frameBytes.append(0x0a)
        let total = prefix.count.addingReportingOverflow(frameBytes.count)
        guard !total.overflow,
              total.partialValue <= Self.maximumJournalBytes
        else { throw PrimeR19Failure.rejected }

        guard lseek(authorities.journal.descriptor, 0, SEEK_CUR)
                == off_t(prefix.count),
              lseek(authorities.journal.descriptor, 0, SEEK_END)
                == off_t(prefix.count)
        else { throw PrimeR19Failure.rejected }
        var offset = 0
        while offset < frameBytes.count {
            let remaining = frameBytes.count - offset
            errno = 0
            let returned = frameBytes.withUnsafeBytes {
                Darwin.write(
                    authorities.journal.descriptor,
                    $0.baseAddress!.advanced(by: offset),
                    remaining
                )
            }
            guard returned > 0 else { throw PrimeR19Failure.rejected }
            offset += returned
        }
        try authorities.syncBudget.synchronize(authorities.journal.descriptor)

        var expected = prefix
        expected.append(contentsOf: frameBytes)
        let readback = try readPrefix(count: expected.count)
        guard readback == expected else { throw PrimeR19Failure.rejected }
        var metadata = stat()
        guard fstat(authorities.journal.descriptor, &metadata) == 0,
              metadata.st_size == off_t(expected.count)
        else { throw PrimeR19Failure.rejected }
        try authorities.rejoinAll(
            includeFIFODescriptor: authorities.fifoDescriptor >= 3,
            phase: phase,
            journalPrefix: expected.count,
            enforceContinuityCandidates: !terminalEvidence
        )
        try rejoinRegisteredRuntimeState()
        prefix = expected
        previousFrameSHA256 = PrimeR19Bytes.sha256(frameBytes)
        nextOrdinal += 1
        poisoned = false
        return frameBytes
    }

    func validatePrefix() throws {
        try rejoinRegisteredRuntimeState()
        guard !poisoned,
              try readPrefix(count: prefix.count) == prefix,
              lseek(authorities.journal.descriptor, 0, SEEK_CUR)
                == off_t(prefix.count)
        else { throw PrimeR19Failure.rejected }
    }

    func registerInternalPipes(
        stdout: PrimeR19Pipe,
        stderr: PrimeR19Pipe
    ) throws {
        guard stdoutPipe == nil, stderrPipe == nil else {
            throw PrimeR19Failure.rejected
        }
        try stdout.rejoinCurrentEnds()
        try stderr.rejoinCurrentEnds()
        self.stdoutPipe = stdout
        self.stderrPipe = stderr
    }

    func registerMappedChild(
        pid: pid_t,
        uniqueID: UInt64
    ) throws {
        guard pid > 1,
              uniqueID != 0,
              mappedChildPID == nil,
              mappedChildUniqueID == nil
        else { throw PrimeR19Failure.rejected }
        _ = try PrimeR19MappedImage.inspect(pid: pid, held: authorities.ruby)
        mappedChildPID = pid
        mappedChildUniqueID = uniqueID
    }

    func noteMappedChildTerminal(pid: pid_t) -> Bool {
        let terminalEdge = phase == .effectsMayExist && !terminalEvidence
        let matched = terminalEdge
            && mappedChildPID == pid
            && mappedChildUniqueID != nil
        mappedChildPID = nil
        mappedChildUniqueID = nil
        if terminalEdge { terminalEvidence = true }
        return matched
    }

    private func rejoinRegisteredRuntimeState() throws {
        try stdoutPipe?.rejoinCurrentEnds()
        try stderrPipe?.rejoinCurrentEnds()
        if let pid = mappedChildPID, let uniqueID = mappedChildUniqueID {
            guard uniqueID != 0 else { throw PrimeR19Failure.rejected }
            _ = try PrimeR19MappedImage.inspect(pid: pid, held: authorities.ruby)
        }
    }

    func enterEffectsMayExist() throws {
        guard phase == .preEffect else { throw PrimeR19Failure.rejected }
        try validatePrefix()
        phase = .effectsMayExist
    }

    func noteExactDirectReap() -> Bool {
        guard phase == .effectsMayExist,
              terminalEvidence,
              !exactDirectReapObserved
        else { return false }
        exactDirectReapObserved = true
        return true
    }

    func observeTerminalCandidates() -> Bool {
        guard phase == .effectsMayExist,
              terminalEvidence,
              exactDirectReapObserved
        else { return false }
        terminalObservedControllerOffset = lseek(
            authorities.controller.descriptor, 0, SEEK_CUR
        )
        terminalArchiveNamespacesAbsent = (try? authorities.requireTargets(
            for: .terminalSeal
        )) != nil
        return terminalObservedControllerOffset
                == off_t(PrimeR19Fixed.controllerBytes)
            && terminalArchiveNamespacesAbsent
    }

    func enterTerminalSealAfterCandidateObservation() throws {
        guard phase == .effectsMayExist,
              terminalEvidence,
              exactDirectReapObserved,
              terminalObservedControllerOffset != nil,
              !poisoned
        else { throw PrimeR19Failure.rejected }
        try authorities.rejoinAll(
            includeFIFODescriptor: authorities.fifoDescriptor >= 3,
            phase: .terminalSeal,
            journalPrefix: prefix.count
        )
        phase = .terminalSeal
        terminalEvidence = false
    }

    @discardableResult
    func captureAndDecodeInventory(ordinal: UInt32) throws -> Bool {
        guard (1...5).contains(ordinal),
              inventoryOrdinals.insert(ordinal).inserted
        else { throw PrimeR19Failure.rejected }
        let sample = PrimeR19InventoryCapture.capture(
            root: authorities.root.descriptor,
            ordinal: ordinal
        )
        let rawFrame = try publish(
            schema: "prime_driver_v2_r19_runtime_root_inventory_raw_v1",
            status: "COMPLETE_RAW_INVENTORY_DURABLE_BEFORE_DECODE",
            members: [("capture", sample.rawJSON)]
        )
        let token = PrimeR19DurableInventoryToken.issue(
            ordinal: ordinal,
            rawSHA256: sample.rawSHA256,
            frameSHA256: PrimeR19Bytes.sha256(rawFrame)
        )
        let decoded: PrimeR19JSON
        do {
            decoded = try sample.decode(
                token: token,
                journal: authorities.journal.initial,
                fifo: authorities.fifoInitial,
                root: authorities.root.initial,
                fifoDescriptorHeld: authorities.fifoDescriptor >= 3
            )
        } catch {
            _ = try publish(
                schema: "prime_driver_v2_r19_runtime_root_inventory_decode_withheld_v1",
                status: "RAW_DURABLE_INVENTORY_PERMANENT_EVIDENCE_VETO",
                members: [
                    ("inventory_ordinal", .unsigned(UInt64(ordinal))),
                    ("raw_frame_sha256", .string(token.frameSHA256)),
                    ("raw_sha256", .string(token.rawSHA256)),
                ]
            )
            return false
        }
        _ = try publish(
            schema: "prime_driver_v2_r19_runtime_root_inventory_decoded_v1",
            status: "EXACT_TWO_ENTRIES_DECODED_AFTER_RAW_DURABILITY",
            members: [
                ("decoded", decoded),
                ("raw_frame_sha256", .string(token.frameSHA256)),
                ("raw_sha256", .string(token.rawSHA256)),
            ]
        )
        return true
    }

    func seal() throws {
        guard !poisoned,
              phase == .terminalSeal,
              fchmod(authorities.journal.descriptor, mode_t(0o400)) == 0,
              fchmod(authorities.root.descriptor, mode_t(0o500)) == 0
        else { throw PrimeR19Failure.rejected }
        try authorities.syncBudget.synchronize(authorities.journal.descriptor)
        try authorities.syncBudget.synchronize(authorities.root.descriptor)
        try authorities.syncBudget.synchronize(authorities.parent.descriptor)
        var journalHeld = stat()
        var journalNamed = stat()
        var rootHeld = stat()
        var rootNamed = stat()
        guard fstat(authorities.journal.descriptor, &journalHeld) == 0,
              PrimeR19Fixed.journalLeaf.withCString({
                  fstatat(
                      authorities.root.descriptor,
                      $0,
                      &journalNamed,
                      AT_SYMLINK_NOFOLLOW
                  )
              }) == 0,
              fstat(authorities.root.descriptor, &rootHeld) == 0,
              PrimeR19Fixed.runtimeRootLeaf.withCString({
                  fstatat(
                      authorities.parent.descriptor,
                      $0,
                      &rootNamed,
                      AT_SYMLINK_NOFOLLOW
                  )
              }) == 0,
              journalHeld.st_dev == journalNamed.st_dev,
              journalHeld.st_ino == journalNamed.st_ino,
              journalHeld.st_mode & mode_t(0o7777) == mode_t(0o400),
              journalNamed.st_mode & mode_t(0o7777) == mode_t(0o400),
              journalHeld.st_uid == 501,
              journalNamed.st_uid == 501,
              journalHeld.st_gid == 20,
              journalNamed.st_gid == 20,
              journalHeld.st_flags == 0,
              journalNamed.st_flags == 0,
              journalHeld.st_nlink == 1,
              journalNamed.st_nlink == 1,
              journalHeld.st_size == off_t(prefix.count),
              journalNamed.st_size == off_t(prefix.count),
              fcntl(authorities.journal.descriptor, F_GETFD) & FD_CLOEXEC != 0,
              fcntl(authorities.journal.descriptor, F_GETFL) & O_ACCMODE == O_RDWR,
              lseek(authorities.journal.descriptor, 0, SEEK_CUR)
                == off_t(prefix.count),
              rootHeld.st_dev == rootNamed.st_dev,
              rootHeld.st_ino == rootNamed.st_ino,
              rootHeld.st_mode & mode_t(0o7777) == mode_t(0o500),
              rootNamed.st_mode & mode_t(0o7777) == mode_t(0o500),
              try readPrefix(count: prefix.count) == prefix
        else { throw PrimeR19Failure.rejected }
    }

    private func readPrefix(count: Int) throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: count + 1)
        var offset = 0
        while offset < bytes.count {
            let remaining = bytes.count - offset
            errno = 0
            let returned = bytes.withUnsafeMutableBytes {
                pread(
                    authorities.journal.descriptor,
                    $0.baseAddress!.advanced(by: offset),
                    remaining,
                    off_t(offset)
                )
            }
            guard returned >= 0 else { throw PrimeR19Failure.rejected }
            if returned == 0 {
                guard offset == count else { throw PrimeR19Failure.rejected }
                return Array(bytes.prefix(count))
            }
            offset += returned
            guard offset <= count else { throw PrimeR19Failure.rejected }
        }
        throw PrimeR19Failure.rejected
    }
}

private final class PrimeR19DurableInventoryToken {
    let ordinal: UInt32
    let rawSHA256: String
    let frameSHA256: String

    private init(ordinal: UInt32, rawSHA256: String, frameSHA256: String) {
        self.ordinal = ordinal
        self.rawSHA256 = rawSHA256
        self.frameSHA256 = frameSHA256
    }

    fileprivate static func issue(
        ordinal: UInt32,
        rawSHA256: String,
        frameSHA256: String
    ) -> PrimeR19DurableInventoryToken {
        PrimeR19DurableInventoryToken(
            ordinal: ordinal,
            rawSHA256: rawSHA256,
            frameSHA256: frameSHA256
        )
    }
}

private struct PrimeR19InventoryCapture {
    private static let byteCount = 1_608
    let ordinal: UInt32
    let wrapperReturn: Int32
    let wrapperErrno: Int32
    let before: PrimeR19ClockSample
    let after: PrimeR19ClockSample
    let raw: [UInt8]

    var rawSHA256: String { PrimeR19Bytes.sha256(raw) }

    var rawJSON: PrimeR19JSON {
        .object([
            ("abi", .string("SIZE_1608_ALIGN_8_DARWIN_ARM64_LITTLE_ENDIAN")),
            ("after", after.json),
            ("before", before.json),
            ("ordinal", .unsigned(UInt64(ordinal))),
            ("raw_bytes", .unsigned(UInt64(raw.count))),
            ("raw_hex", .string(PrimeR19Bytes.hex(raw))),
            ("raw_sha256", .string(rawSHA256)),
            ("wrapper_errno_non_authoritative", .signed(Int64(wrapperErrno))),
            ("wrapper_return", .signed(Int64(wrapperReturn))),
        ])
    }

    static func capture(root: Int32, ordinal: UInt32) -> PrimeR19InventoryCapture {
        let storage = UnsafeMutableRawPointer.allocate(
            byteCount: byteCount,
            alignment: 8
        )
        storage.initializeMemory(as: UInt8.self, repeating: 0, count: byteCount)
        defer { storage.deallocate() }
        let before = PrimeR19ClockSample.capture()
        errno = 0
        let result = primeR19CaptureRuntimeRootInventoryRaw(
            root, ordinal, storage
        )
        let callErrno = errno
        let after = PrimeR19ClockSample.capture()
        return PrimeR19InventoryCapture(
            ordinal: ordinal,
            wrapperReturn: result,
            wrapperErrno: callErrno,
            before: before,
            after: after,
            raw: Array(UnsafeRawBufferPointer(start: storage, count: byteCount))
        )
    }

    func decode(
        token: PrimeR19DurableInventoryToken,
        journal: PrimeR19FileIdentity,
        fifo: PrimeR19FileIdentity,
        root: PrimeR19FileIdentity,
        fifoDescriptorHeld: Bool
    ) throws -> PrimeR19JSON {
        guard token.ordinal == ordinal,
              token.rawSHA256 == rawSHA256,
              raw.count == Self.byteCount,
              wrapperReturn == 0,
              after.ticks >= before.ticks,
              Int32(bitPattern: try PrimeR19Bytes.little32(raw, 1_536)) >= 3,
              try PrimeR19Bytes.little64(raw, 1_576) == 0x8,
              try PrimeR19Bytes.little32(raw, 1_584) == 3,
              try PrimeR19Bytes.little32(raw, 1_588) == ordinal,
              try PrimeR19Bytes.little32(raw, 1_592) == 0x82000009,
              try PrimeR19Bytes.little32(raw, 1_596) == 512,
              try PrimeR19Bytes.little32(raw, 1_600) == 3,
              try PrimeR19Bytes.little32(raw, 1_604) == 0,
              Int32(bitPattern: try PrimeR19Bytes.little32(raw, 1_568)) == 0
        else { throw PrimeR19Failure.rejected }

        let counts = try (0..<3).map {
            Int(Int32(bitPattern: try PrimeR19Bytes.little32(raw, 1_544 + $0 * 4)))
        }
        guard counts == [2, 0, 0] || counts == [1, 1, 0] else {
            throw PrimeR19Failure.rejected
        }
        var entries = [(name: String, type: UInt32, fileID: UInt64)]()
        for bufferIndex in 0..<3 {
            let base = bufferIndex * 512
            var cursor = 0
            for _ in 0..<counts[bufferIndex] {
                let length = Int(try PrimeR19Bytes.little32(raw, base + cursor))
                guard length >= 48,
                      length % 8 == 0,
                      cursor <= 512 - length,
                      try PrimeR19Bytes.little32(raw, base + cursor + 4)
                        == 0x82000009,
                      try PrimeR19Bytes.little32(raw, base + cursor + 8) == 0,
                      try PrimeR19Bytes.little32(raw, base + cursor + 12) == 0,
                      try PrimeR19Bytes.little32(raw, base + cursor + 16) == 0,
                      try PrimeR19Bytes.little32(raw, base + cursor + 20) == 0
                else { throw PrimeR19Failure.rejected }
                let reference = base + cursor + 24
                let nameOffset = Int(Int32(bitPattern:
                    try PrimeR19Bytes.little32(raw, reference)))
                let nameLength = Int(try PrimeR19Bytes.little32(raw, reference + 4))
                let nameStart = reference + nameOffset
                let recordEnd = base + cursor + length
                guard nameOffset >= 0,
                      nameLength >= 2,
                      nameStart >= base + cursor,
                      nameStart <= recordEnd - nameLength,
                      raw[nameStart + nameLength - 1] == 0,
                      !raw[nameStart..<(nameStart + nameLength - 1)].contains(0)
                else { throw PrimeR19Failure.rejected }
                entries.append((
                    name: String(
                        decoding: raw[nameStart..<(nameStart + nameLength - 1)],
                        as: UTF8.self
                    ),
                    type: try PrimeR19Bytes.little32(raw, base + cursor + 32),
                    // ATTR_CMN_FILEID follows the 32-bit objtype at its
                    // frozen four-byte alignment, not an invented 8-byte pad.
                    fileID: try PrimeR19Bytes.little64(raw, base + cursor + 36)
                ))
                cursor += length
            }
            guard raw[(base + cursor)..<(base + 512)].allSatisfy({ $0 == 0 })
            else { throw PrimeR19Failure.rejected }
        }
        guard entries.count == 2,
              Set(entries.map { $0.name }).count == 2,
              let journalEntry = entries.first(where: {
                  $0.name == PrimeR19Fixed.journalLeaf
              }),
              let fifoEntry = entries.first(where: {
                  $0.name == PrimeR19Fixed.fifoLeaf
              }),
              journalEntry.type == 1,
              fifoEntry.type == 7,
              journal.device == root.device,
              fifo.device == root.device,
              journalEntry.fileID == journal.inode,
              fifoEntry.fileID == fifo.inode,
              (ordinal < 3 || fifoDescriptorHeld)
        else { throw PrimeR19Failure.rejected }
        return .object([
            ("atomic_snapshot_claimed", .boolean(false)),
            ("entry_count", .unsigned(2)),
            ("fifo_fileid", .unsigned(fifoEntry.fileID)),
            ("journal_fileid", .unsigned(journalEntry.fileID)),
            ("same_uid_immutability_claimed", .boolean(false)),
        ])
    }
}

private struct PrimeR19RawProcessAttempt {
    let pid: pid_t
    let beforeTicks: UInt64
    let unique0: [UInt8]
    let unique0Return: Int32
    let unique0Errno: Int32
    let short0: [UInt8]
    let short0Return: Int32
    let short0Errno: Int32
    let session0: pid_t
    let session0Errno: Int32
    let group0: pid_t
    let group0Errno: Int32
    let session1: pid_t
    let session1Errno: Int32
    let group1: pid_t
    let group1Errno: Int32
    let short1: [UInt8]
    let short1Return: Int32
    let short1Errno: Int32
    let unique1: [UInt8]
    let unique1Return: Int32
    let unique1Errno: Int32
    let afterTicks: UInt64

    static func capture(pid: pid_t) -> PrimeR19RawProcessAttempt {
        func info(_ flavor: Int32, _ count: Int) -> ([UInt8], Int32, Int32) {
            var bytes = [UInt8](repeating: 0, count: count)
            errno = 0
            let result = bytes.withUnsafeMutableBytes {
                proc_pidinfo(pid, flavor, 0, $0.baseAddress, Int32($0.count))
            }
            return (bytes, result, errno)
        }
        func domain(_ session: Bool) -> (pid_t, Int32) {
            errno = 0
            let result = session ? getsid(pid) : getpgid(pid)
            return (result, errno)
        }
        let before = mach_absolute_time()
        let u0 = info(17, 56)
        let s0 = info(13, 64)
        let sid0 = domain(true)
        let pgid0 = domain(false)
        let sid1 = domain(true)
        let pgid1 = domain(false)
        let s1 = info(13, 64)
        let u1 = info(17, 56)
        let after = mach_absolute_time()
        return PrimeR19RawProcessAttempt(
            pid: pid, beforeTicks: before,
            unique0: u0.0, unique0Return: u0.1, unique0Errno: u0.2,
            short0: s0.0, short0Return: s0.1, short0Errno: s0.2,
            session0: sid0.0, session0Errno: sid0.1,
            group0: pgid0.0, group0Errno: pgid0.1,
            session1: sid1.0, session1Errno: sid1.1,
            group1: pgid1.0, group1Errno: pgid1.1,
            short1: s1.0, short1Return: s1.1, short1Errno: s1.2,
            unique1: u1.0, unique1Return: u1.1, unique1Errno: u1.2,
            afterTicks: after
        )
    }

    var rawJSON: PrimeR19JSON {
        .object([
            ("after_ticks", .unsigned(afterTicks)),
            ("before_ticks", .unsigned(beforeTicks)),
            ("getpgid0_errno", .signed(Int64(group0Errno))),
            ("getpgid0_return", .signed(Int64(group0))),
            ("getpgid1_errno", .signed(Int64(group1Errno))),
            ("getpgid1_return", .signed(Int64(group1))),
            ("getsid0_errno", .signed(Int64(session0Errno))),
            ("getsid0_return", .signed(Int64(session0))),
            ("getsid1_errno", .signed(Int64(session1Errno))),
            ("getsid1_return", .signed(Int64(session1))),
            ("pid", .signed(Int64(pid))),
            ("short0_errno", .signed(Int64(short0Errno))),
            ("short0_hex", .string(PrimeR19Bytes.hex(short0))),
            ("short0_return", .signed(Int64(short0Return))),
            ("short1_errno", .signed(Int64(short1Errno))),
            ("short1_hex", .string(PrimeR19Bytes.hex(short1))),
            ("short1_return", .signed(Int64(short1Return))),
            ("unique0_errno", .signed(Int64(unique0Errno))),
            ("unique0_hex", .string(PrimeR19Bytes.hex(unique0))),
            ("unique0_return", .signed(Int64(unique0Return))),
            ("unique1_errno", .signed(Int64(unique1Errno))),
            ("unique1_hex", .string(PrimeR19Bytes.hex(unique1))),
            ("unique1_return", .signed(Int64(unique1Return))),
        ])
    }

    func decode(expectedUniqueID: UInt64) throws -> PrimeR19JoinedProcess {
        guard pid > 1,
              afterTicks >= beforeTicks,
              unique0Return == 56,
              unique1Return == 56,
              short0Return == 64,
              short1Return == 64,
              session0 >= 0,
              session1 == session0,
              group0 >= 0,
              group1 == group0,
              unique0 == unique1,
              short0 == short1,
              try PrimeR19Bytes.little64(unique1, 16) == expectedUniqueID,
              try PrimeR19Bytes.little64(unique1, 40) == 0,
              try PrimeR19Bytes.little64(unique1, 48) == 0,
              try PrimeR19Bytes.little32(short1, 0) == UInt32(pid),
              try PrimeR19Bytes.little32(short1, 8) == UInt32(group1),
              try PrimeR19Bytes.little32(short1, 60) == 0
        else { throw PrimeR19Failure.rejected }
        return PrimeR19JoinedProcess(
            unique: PrimeR19UniqueIdentity(
                uuid: Array(unique1[0..<16]),
                uniqueID: try PrimeR19Bytes.little64(unique1, 16),
                parentUniqueID: try PrimeR19Bytes.little64(unique1, 24),
                idVersion: try PrimeR19Bytes.little32(unique1, 32),
                originalParentIDVersion: try PrimeR19Bytes.little32(unique1, 36)
            ),
            short: PrimeR19ShortIdentity(
                pid: try PrimeR19Bytes.little32(short1, 0),
                parentPID: try PrimeR19Bytes.little32(short1, 4),
                processGroup: try PrimeR19Bytes.little32(short1, 8),
                status: try PrimeR19Bytes.little32(short1, 12),
                command: Array(short1[16..<32]),
                uid: try PrimeR19Bytes.little32(short1, 36),
                gid: try PrimeR19Bytes.little32(short1, 40),
                realUID: try PrimeR19Bytes.little32(short1, 44),
                realGID: try PrimeR19Bytes.little32(short1, 48),
                savedUID: try PrimeR19Bytes.little32(short1, 52),
                savedGID: try PrimeR19Bytes.little32(short1, 56)
            ),
            session: session1,
            processGroup: group1
        )
    }
}

private final class PrimeR19DurableProcessToken {
    let expectedUniqueID: UInt64
    let rawFrameSHA256: String
    private init(expectedUniqueID: UInt64, rawFrameSHA256: String) {
        self.expectedUniqueID = expectedUniqueID
        self.rawFrameSHA256 = rawFrameSHA256
    }
    fileprivate static func issue(
        expectedUniqueID: UInt64,
        rawFrameSHA256: String
    ) -> PrimeR19DurableProcessToken {
        PrimeR19DurableProcessToken(
            expectedUniqueID: expectedUniqueID,
            rawFrameSHA256: rawFrameSHA256
        )
    }
}

private extension PrimeR19Journal {
    func durableJoin(
        pid: pid_t,
        role: String,
        expectedUniqueID: UInt64? = nil
    ) throws -> PrimeR19JoinedProcess {
        let attempt = PrimeR19RawProcessAttempt.capture(pid: pid)
        let rawFrame = try publish(
            schema: "prime_driver_v2_r19_process_generation_attempt_raw_v1",
            status: "ONE_ATTEMPT_RAW_DURABLE_NO_RETRY",
            members: [
                ("attempt", attempt.rawJSON),
                ("role", .string(role)),
            ]
        )
        let expected: UInt64
        if let expectedUniqueID {
            expected = expectedUniqueID
        } else {
            expected = try PrimeR19Bytes.little64(attempt.unique1, 16)
        }
        let token = PrimeR19DurableProcessToken.issue(
            expectedUniqueID: expected,
            rawFrameSHA256: PrimeR19Bytes.sha256(rawFrame)
        )
        guard token.rawFrameSHA256.count == 64 else {
            throw PrimeR19Failure.rejected
        }
        let decoded = try attempt.decode(expectedUniqueID: token.expectedUniqueID)
        _ = try publish(
            schema: "prime_driver_v2_r19_process_generation_decoded_v1",
            status: "DECODED_WITH_DURABLE_ONE_ATTEMPT_TOKEN",
            members: [
                ("process", decoded.json),
                ("raw_frame_sha256", .string(token.rawFrameSHA256)),
                ("role", .string(role)),
            ]
        )
        return decoded
    }
}

private final class PrimeR19DurableRusageToken {
    let ordinal: UInt32
    let rawFrameSHA256: String
    let raw464SHA256: String
    let expectedUniqueID: UInt64

    private init(
        ordinal: UInt32,
        rawFrameSHA256: String,
        raw464SHA256: String,
        expectedUniqueID: UInt64
    ) {
        self.ordinal = ordinal
        self.rawFrameSHA256 = rawFrameSHA256
        self.raw464SHA256 = raw464SHA256
        self.expectedUniqueID = expectedUniqueID
    }

    fileprivate static func issue(
        ordinal: UInt32,
        rawFrameSHA256: String,
        raw464SHA256: String,
        expectedUniqueID: UInt64
    ) -> PrimeR19DurableRusageToken {
        PrimeR19DurableRusageToken(
            ordinal: ordinal,
            rawFrameSHA256: rawFrameSHA256,
            raw464SHA256: raw464SHA256,
            expectedUniqueID: expectedUniqueID
        )
    }
}

private struct PrimeR19DecodedRusage {
    let before: PrimeR19JoinedProcess
    let after: PrimeR19JoinedProcess
    let bootUUID: [UInt8]
    let json: PrimeR19JSON
}

private struct PrimeR19RusageSample {
    let ordinal: UInt32
    let expectedUniqueID: UInt64
    let prejoin: PrimeR19RawProcessAttempt
    let postjoin: PrimeR19RawProcessAttempt
    let bootRaw: [UInt8]
    let bootWrapperReturn: Int32
    let bootWrapperErrno: Int32
    let timebaseRaw: [UInt8]
    let timebaseReturn: kern_return_t
    let beforeTicks: UInt64
    let afterTicks: UInt64
    let rusageRaw: [UInt8]
    let wrapperReturn: Int32
    let wrapperErrno: Int32

    var raw464: [UInt8] { Array(rusageRaw[0..<464]) }

    var rawJSON: PrimeR19JSON {
        .object([
            ("abi", .string("RUSAGE_472_BOOT_64_TIMEBASE_8_DARWIN_ARM64_LITTLE_ENDIAN")),
            ("after_ticks", .unsigned(afterTicks)),
            ("before_ticks", .unsigned(beforeTicks)),
            ("boot_raw_hex", .string(PrimeR19Bytes.hex(bootRaw))),
            ("boot_wrapper_errno_non_authoritative", .signed(Int64(bootWrapperErrno))),
            ("boot_wrapper_return", .signed(Int64(bootWrapperReturn))),
            ("expected_child_uniqueid", .unsigned(expectedUniqueID)),
            ("ordinal", .unsigned(UInt64(ordinal))),
            ("postjoin", postjoin.rawJSON),
            ("prejoin", prejoin.rawJSON),
            ("rusage_raw_472_hex", .string(PrimeR19Bytes.hex(rusageRaw))),
            ("rusage_raw_464_sha256", .string(PrimeR19Bytes.sha256(raw464))),
            ("timebase_raw_hex", .string(PrimeR19Bytes.hex(timebaseRaw))),
            ("timebase_return", .signed(Int64(timebaseReturn))),
            ("wrapper_errno_non_authoritative", .signed(Int64(wrapperErrno))),
            ("wrapper_return", .signed(Int64(wrapperReturn))),
        ])
    }

    static func capture(
        pid: pid_t,
        ordinal: UInt32,
        expectedUniqueID: UInt64
    ) -> PrimeR19RusageSample {
        let prejoin = PrimeR19RawProcessAttempt.capture(pid: pid)

        let bootStorage = UnsafeMutableRawPointer.allocate(byteCount: 64, alignment: 8)
        bootStorage.initializeMemory(as: UInt8.self, repeating: 0, count: 64)
        errno = 0
        let bootResult = primeR19CaptureBootSessionUUID(ordinal, bootStorage)
        let bootErrno = errno
        let bootRaw = Array(UnsafeRawBufferPointer(start: bootStorage, count: 64))
        bootStorage.deallocate()

        var timebase = mach_timebase_info_data_t()
        let timebaseResult = mach_timebase_info(&timebase)
        let timebaseRaw = withUnsafeBytes(of: &timebase) { Array($0) }
        let before = mach_absolute_time()
        let storage = UnsafeMutableRawPointer.allocate(byteCount: 472, alignment: 8)
        storage.initializeMemory(as: UInt8.self, repeating: 0, count: 472)
        errno = 0
        let result = primeR19CaptureRusageV6(pid, ordinal, storage)
        let callErrno = errno
        let after = mach_absolute_time()
        let raw = Array(UnsafeRawBufferPointer(start: storage, count: 472))
        storage.deallocate()
        let postjoin = PrimeR19RawProcessAttempt.capture(pid: pid)
        return PrimeR19RusageSample(
            ordinal: ordinal,
            expectedUniqueID: expectedUniqueID,
            prejoin: prejoin,
            postjoin: postjoin,
            bootRaw: bootRaw,
            bootWrapperReturn: bootResult,
            bootWrapperErrno: bootErrno,
            timebaseRaw: timebaseRaw,
            timebaseReturn: timebaseResult,
            beforeTicks: before,
            afterTicks: after,
            rusageRaw: raw,
            wrapperReturn: result,
            wrapperErrno: callErrno
        )
    }

    func decode(token: PrimeR19DurableRusageToken) throws -> PrimeR19DecodedRusage {
        let before = try prejoin.decode(expectedUniqueID: expectedUniqueID)
        let after = try postjoin.decode(expectedUniqueID: expectedUniqueID)
        let callReturn = Int32(bitPattern: try PrimeR19Bytes.little32(rusageRaw, 464))
        let requested = try PrimeR19Bytes.little64(bootRaw, 40)
        let returned = try PrimeR19Bytes.little64(bootRaw, 48)
        let bootCallReturn = Int32(bitPattern: try PrimeR19Bytes.little32(bootRaw, 56))
        guard token.ordinal == ordinal,
              token.expectedUniqueID == expectedUniqueID,
              token.raw464SHA256 == PrimeR19Bytes.sha256(raw464),
              token.rawFrameSHA256.count == 64,
              ordinal == 1 || ordinal == 2,
              rusageRaw.count == 472,
              bootRaw.count == 64,
              timebaseRaw.count == 8,
              wrapperReturn == 0,
              callReturn == 0,
              before.sameGeneration(as: after),
              Array(raw464[0..<16]) == before.unique.uuid,
              timebaseReturn == KERN_SUCCESS,
              try PrimeR19Bytes.little32(timebaseRaw, 0) > 0,
              try PrimeR19Bytes.little32(timebaseRaw, 4) > 0,
              afterTicks >= beforeTicks,
              bootWrapperReturn == 0,
              bootCallReturn == 0,
              requested == 37,
              returned == 37,
              bootRaw[37..<40].allSatisfy({ $0 == 0 }),
              bootRaw[36] == 0
        else { throw PrimeR19Failure.rejected }
        for index in 0..<36 {
            let value = bootRaw[index]
            if [8, 13, 18, 23].contains(index) {
                guard value == 0x2d else { throw PrimeR19Failure.rejected }
            } else {
                guard (value >= 0x30 && value <= 0x39)
                        || (value >= 0x41 && value <= 0x46)
                else { throw PrimeR19Failure.rejected }
            }
        }
        let decoded = PrimeR19JSON.object([
            ("boot_session_uuid", .string(String(
                decoding: bootRaw[0..<36], as: UTF8.self
            ))),
            ("energy_nj", .unsigned(try PrimeR19Bytes.little64(raw464, 336))),
            ("penergy_nj", .unsigned(try PrimeR19Bytes.little64(raw464, 344))),
            ("process_exit_ticks", .unsigned(try PrimeR19Bytes.little64(raw464, 88))),
            ("process_start_ticks", .unsigned(try PrimeR19Bytes.little64(raw464, 80))),
            ("process_uuid_hex", .string(PrimeR19Bytes.hex(Array(raw464[0..<16])))),
            ("raw_frame_sha256", .string(token.rawFrameSHA256)),
            ("raw_sha256", .string(token.raw464SHA256)),
            ("timebase_denominator", .unsigned(UInt64(
                try PrimeR19Bytes.little32(timebaseRaw, 4)
            ))),
            ("timebase_numerator", .unsigned(UInt64(
                try PrimeR19Bytes.little32(timebaseRaw, 0)
            ))),
        ])
        return PrimeR19DecodedRusage(
            before: before,
            after: after,
            bootUUID: Array(bootRaw[0..<37]),
            json: decoded
        )
    }
}

private final class PrimeR19Pipe {
    private struct Endpoint: Equatable {
        let descriptor: Int32
        let openFlags: UInt32
        let status: UInt32
        let device: UInt32
        let inode: UInt64
        let handle: UInt64
        let peerHandle: UInt64

        static func capture(_ descriptor: Int32, write: Bool) throws -> Endpoint {
            var raw = [UInt8](repeating: 0, count: 184)
            errno = 0
            let returned = raw.withUnsafeMutableBytes {
                proc_pidfdinfo(
                    getpid(), descriptor, PROC_PIDFDPIPEINFO,
                    $0.baseAddress, Int32($0.count)
                )
            }
            let openFlags = try PrimeR19Bytes.little32(raw, 0)
            let status = try PrimeR19Bytes.little32(raw, 4)
            guard returned == 184,
                  openFlags & UInt32(O_ACCMODE)
                    == UInt32(write ? O_WRONLY : O_RDONLY),
                  status & UInt32(PROC_FP_CLEXEC) != 0,
                  try PrimeR19Bytes.little32(raw, 16) == 6,
                  try PrimeR19Bytes.little32(raw, 180) == 0
            else { throw PrimeR19Failure.rejected }
            return Endpoint(
                descriptor: descriptor,
                openFlags: openFlags,
                status: status,
                device: try PrimeR19Bytes.little32(raw, 24),
                inode: try PrimeR19Bytes.little64(raw, 32),
                handle: try PrimeR19Bytes.little64(raw, 160),
                peerHandle: try PrimeR19Bytes.little64(raw, 168)
            )
        }

        var json: PrimeR19JSON {
            .object([
                ("descriptor", .signed(Int64(descriptor))),
                ("device", .unsigned(UInt64(device))),
                ("handle", .unsigned(handle)),
                ("inode", .unsigned(inode)),
                ("open_flags", .unsigned(UInt64(openFlags))),
                ("peerhandle", .unsigned(peerHandle)),
                ("status", .unsigned(UInt64(status))),
            ])
        }
    }

    private(set) var readFD: Int32
    private(set) var writeFD: Int32
    private var initialRead: Endpoint?
    private var initialWrite: Endpoint?

    init() throws {
        var values: [Int32] = [-1, -1]
        guard values.withUnsafeMutableBufferPointer({ Darwin.pipe($0.baseAddress) }) == 0,
              values[0] >= 3,
              values[1] >= 3,
              values[0] != values[1]
        else { throw PrimeR19Failure.rejected }
        readFD = values[0]
        writeFD = values[1]
        do {
            try Self.setCloseOnExec(readFD)
            try Self.setCloseOnExec(writeFD)
            let readFlags = fcntl(readFD, F_GETFL)
            let writeFlags = fcntl(writeFD, F_GETFL)
            guard readFlags >= 0,
                  writeFlags == O_WRONLY,
                  fcntl(readFD, F_SETFL, readFlags | O_NONBLOCK) == 0,
                  fcntl(readFD, F_GETFL) & (O_ACCMODE | O_NONBLOCK)
                    == (O_RDONLY | O_NONBLOCK)
            else { throw PrimeR19Failure.rejected }
            let readIdentity = try Endpoint.capture(readFD, write: false)
            let writeIdentity = try Endpoint.capture(writeFD, write: true)
            guard readIdentity.handle == writeIdentity.peerHandle,
                  readIdentity.peerHandle == writeIdentity.handle
            else { throw PrimeR19Failure.rejected }
            initialRead = readIdentity
            initialWrite = writeIdentity
        } catch {
            closeAll()
            throw error
        }
    }

    deinit { closeAll() }

    func closeWrite() {
        if writeFD >= 0 {
            _ = Darwin.close(writeFD)
            writeFD = -1
        }
    }

    func closeAll() {
        if readFD >= 0 {
            _ = Darwin.close(readFD)
            readFD = -1
        }
        closeWrite()
    }

    func rejoinCurrentEnds() throws {
        guard let initialRead,
              try Endpoint.capture(readFD, write: false) == initialRead
        else { throw PrimeR19Failure.rejected }
        if writeFD >= 0 {
            guard let initialWrite,
                  try Endpoint.capture(writeFD, write: true) == initialWrite
            else { throw PrimeR19Failure.rejected }
        }
    }

    var json: PrimeR19JSON {
        .object([
            ("read_fd", .signed(Int64(readFD))),
            ("read_identity", initialRead?.json ?? .null),
            ("write_fd", .signed(Int64(writeFD))),
            ("write_identity", initialWrite?.json ?? .null),
        ])
    }

    private static func setCloseOnExec(_ descriptor: Int32) throws {
        let flags = fcntl(descriptor, F_GETFD)
        guard flags >= 0,
              fcntl(descriptor, F_SETFD, flags | FD_CLOEXEC) == 0,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else { throw PrimeR19Failure.rejected }
    }
}

private struct PrimeR19StreamCapture {
    private static let retainedCap = 4_096
    private static let chunk = 16_384
    private static let readsPerTurn = 4
    private static let bytesPerTurn = 65_536

    private(set) var retained = [UInt8]()
    private(set) var total: UInt64 = 0
    private(set) var eof = false
    private(set) var overflow = false
    private var hasher = SHA256()

    mutating func drain(_ descriptor: Int32) throws {
        if eof { return }
        var buffer = [UInt8](repeating: 0, count: Self.chunk)
        var reads = 0
        var bytesThisTurn = 0
        while reads < Self.readsPerTurn,
              bytesThisTurn < Self.bytesPerTurn {
            let request = min(buffer.count, Self.bytesPerTurn - bytesThisTurn)
            errno = 0
            let returned = buffer.withUnsafeMutableBytes {
                Darwin.read(descriptor, $0.baseAddress, request)
            }
            reads += 1
            if returned > 0 {
                bytesThisTurn += returned
                let sum = total.addingReportingOverflow(UInt64(returned))
                guard !sum.overflow else { throw PrimeR19Failure.rejected }
                total = sum.partialValue
                buffer.withUnsafeBytes {
                    hasher.update(bufferPointer: UnsafeRawBufferPointer(rebasing: $0[0..<returned]))
                }
                let available = max(0, Self.retainedCap - retained.count)
                let copied = min(available, returned)
                if copied > 0 { retained.append(contentsOf: buffer[0..<copied]) }
                if copied != returned { overflow = true }
                continue
            }
            if returned == 0 {
                eof = true
                return
            }
            if errno == EAGAIN || errno == EWOULDBLOCK { return }
            throw PrimeR19Failure.rejected
        }
    }

    mutating func finishJSON() throws -> PrimeR19JSON {
        guard eof else { throw PrimeR19Failure.rejected }
        let digest = PrimeR19Bytes.hex(Array(hasher.finalize()))
        return .object([
            ("eof", .boolean(eof)),
            ("overflow", .boolean(overflow)),
            ("retained_hex", .string(PrimeR19Bytes.hex(retained))),
            ("sha256", .string(digest)),
            ("total_bytes", .unsigned(total)),
        ])
    }
}

private struct PrimeR19SpawnResult {
    let pid: pid_t
    let callReturn: Int32
    let callErrno: Int32
    let before: PrimeR19ClockSample
    let after: PrimeR19ClockSample
}

private enum PrimeR19SpawnOutcome {
    case noChild(PrimeR19SpawnResult)
    case owned(PrimeR19SpawnResult)
}

private enum PrimeR19Spawner {
    static func spawn(
        authorities: PrimeR19Authorities,
        stdout: PrimeR19Pipe,
        stderr: PrimeR19Pipe,
        queue: PrimeR19Kqueue,
        entered: inout Bool
    ) throws -> PrimeR19SpawnOutcome {
        guard !entered else { throw PrimeR19Failure.rejected }
        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        guard posix_spawn_file_actions_init(&actions) == 0 else {
            throw PrimeR19Failure.rejected
        }
        defer { _ = posix_spawn_file_actions_destroy(&actions) }
        guard posix_spawnattr_init(&attributes) == 0 else {
            throw PrimeR19Failure.rejected
        }
        defer { _ = posix_spawnattr_destroy(&attributes) }
        let actionResults = [
            posix_spawn_file_actions_addinherit_np(&actions, authorities.cwdRoot.descriptor),
            posix_spawn_file_actions_addfchdir_np(&actions, authorities.cwdRoot.descriptor),
            posix_spawn_file_actions_addclose(&actions, authorities.cwdRoot.descriptor),
            posix_spawn_file_actions_adddup2(
                &actions, authorities.controller.descriptor, STDIN_FILENO
            ),
            posix_spawn_file_actions_addclose(&actions, authorities.controller.descriptor),
            posix_spawn_file_actions_addclose(&actions, stdout.readFD),
            posix_spawn_file_actions_adddup2(&actions, stdout.writeFD, STDOUT_FILENO),
            posix_spawn_file_actions_addclose(&actions, stdout.writeFD),
            posix_spawn_file_actions_addclose(&actions, stderr.readFD),
            posix_spawn_file_actions_adddup2(&actions, stderr.writeFD, STDERR_FILENO),
            posix_spawn_file_actions_addclose(&actions, stderr.writeFD),
        ]
        guard actionResults.allSatisfy({ $0 == 0 }) else {
            throw PrimeR19Failure.rejected
        }
        var defaults = sigset_t()
        var mask = sigset_t()
        guard sigfillset(&defaults) == 0,
              sigemptyset(&mask) == 0,
              posix_spawnattr_setsigdefault(&attributes, &defaults) == 0,
              posix_spawnattr_setsigmask(&attributes, &mask) == 0
        else { throw PrimeR19Failure.rejected }
        let flags = UInt16(POSIX_SPAWN_START_SUSPENDED)
            | UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
            | UInt16(POSIX_SPAWN_SETSID)
            | UInt16(POSIX_SPAWN_SETSIGDEF)
            | UInt16(POSIX_SPAWN_SETSIGMASK)
        guard flags == 0x448c,
              posix_spawnattr_setflags(&attributes, Int16(bitPattern: flags)) == 0
        else { throw PrimeR19Failure.rejected }

        var argument0 = Array(PrimeR19Fixed.rubyPath.utf8CString)
        var argument1 = Array("--disable-gems".utf8CString)
        var argument2 = Array("-".utf8CString)
        var environment0 = Array("__CF_USER_TEXT_ENCODING=0x1F5:0x0:0x0".utf8CString)
        var child: pid_t = 0
        entered = true
        let before = PrimeR19ClockSample.capture()
        errno = 0
        let result: Int32 = argument0.withUnsafeMutableBufferPointer { arg0 in
            argument1.withUnsafeMutableBufferPointer { arg1 in
                argument2.withUnsafeMutableBufferPointer { arg2 in
                    environment0.withUnsafeMutableBufferPointer { env0 in
                        var arguments: [UnsafeMutablePointer<CChar>?] = [
                            arg0.baseAddress, arg1.baseAddress, arg2.baseAddress, nil,
                        ]
                        var environment: [UnsafeMutablePointer<CChar>?] = [
                            env0.baseAddress, nil,
                        ]
                        return arguments.withUnsafeMutableBufferPointer { argv in
                            environment.withUnsafeMutableBufferPointer { envp in
                                PrimeR19Fixed.rubyPath.withCString { path in
                                    posix_spawn(
                                        &child, path, &actions, &attributes,
                                        argv.baseAddress, envp.baseAddress
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
        let callErrno = errno
        let after = PrimeR19ClockSample.capture()
        let evidence = PrimeR19SpawnResult(
            pid: child,
            callReturn: result,
            callErrno: callErrno,
            before: before,
            after: after
        )
        if result != 0 { return .noChild(evidence) }
        guard child > 1 else { queue.parkForever() }
        // A zero return and a PID greater than one transfer ownership here.
        // Captured errno is retained only as non-authoritative evidence.
        return .owned(evidence)
    }
}

private final class PrimeR19Kqueue {
    typealias Event = Darwin.kevent
    let descriptor: Int32

    init() throws {
        descriptor = kqueue()
        guard descriptor >= 3 else { throw PrimeR19Failure.rejected }
        let flags = fcntl(descriptor, F_GETFD)
        guard flags >= 0,
              fcntl(descriptor, F_SETFD, flags | FD_CLOEXEC) == 0,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            _ = Darwin.close(descriptor)
            throw PrimeR19Failure.rejected
        }
    }

    deinit { _ = Darwin.close(descriptor) }

    func register(pid: pid_t, stdout: Int32, stderr: Int32) throws {
        var changes = [
            Event(
                ident: UInt(pid), filter: Int16(EVFILT_PROC),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE) | UInt16(EV_CLEAR)
                    | UInt16(EV_RECEIPT),
                fflags: UInt32(NOTE_EXIT), data: 0, udata: nil
            ),
            Event(
                ident: UInt(stdout), filter: Int16(EVFILT_READ),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE) | UInt16(EV_CLEAR)
                    | UInt16(EV_RECEIPT),
                fflags: 0, data: 0, udata: nil
            ),
            Event(
                ident: UInt(stderr), filter: Int16(EVFILT_READ),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE) | UInt16(EV_CLEAR)
                    | UInt16(EV_RECEIPT),
                fflags: 0, data: 0, udata: nil
            ),
        ]
        var receipts = [Event](repeating: Event(), count: changes.count)
        errno = 0
        let returned = changes.withUnsafeMutableBufferPointer { changeBuffer in
            receipts.withUnsafeMutableBufferPointer { receiptBuffer in
                kevent(
                    descriptor,
                    changeBuffer.baseAddress,
                    Int32(changeBuffer.count),
                    receiptBuffer.baseAddress,
                    Int32(receiptBuffer.count),
                    nil
                )
            }
        }
        guard returned == Int32(changes.count) else {
            throw PrimeR19Failure.rejected
        }
        for index in changes.indices {
            guard receipts[index].ident == changes[index].ident,
                  receipts[index].filter == changes[index].filter,
                  receipts[index].flags & UInt16(EV_ERROR) != 0,
                  receipts[index].data == 0
            else { throw PrimeR19Failure.rejected }
        }
    }

    func wait() throws -> [Event] {
        var events = [Event](repeating: Event(), count: 16)
        errno = 0
        let returned = events.withUnsafeMutableBufferPointer {
            kevent(descriptor, nil, 0, $0.baseAddress, Int32($0.count), nil)
        }
        guard returned > 0 else { throw PrimeR19Failure.rejected }
        return Array(events.prefix(Int(returned)))
    }

    func parkForever() -> Never {
        while true {
            var event = Event()
            _ = withUnsafeMutablePointer(to: &event) {
                kevent(descriptor, nil, 0, $0, 1, nil)
            }
        }
    }
}

private struct PrimeR19PGIDSnapshot {
    static let entryCapacity = 65_536
    let ordinal: UInt32
    let pgid: pid_t
    let before: PrimeR19ClockSample
    let after: PrimeR19ClockSample
    let raw: [UInt8]
    let callReturn: Int32
    let callErrno: Int32
    let joined: [PrimeR19JoinedProcess]
    let valid: Bool

    var isExactEmpty: Bool { valid && callReturn == 0 }

    var json: PrimeR19JSON {
        .object([
            ("after_clock", after.json),
            ("before_clock", before.json),
            ("call_errno_non_authoritative_when_nonnegative", .boolean(callReturn >= 0)),
            ("call_errno", .signed(Int64(callErrno))),
            ("call_return_bytes", .signed(Int64(callReturn))),
            ("decoded_members", .array(joined.map(\.json))),
            ("exact_empty", .boolean(isExactEmpty)),
            ("ordinal", .unsigned(UInt64(ordinal))),
            ("original_private_pgid", .signed(Int64(pgid))),
            ("raw_capacity_bytes", .unsigned(UInt64(raw.count))),
            ("raw_hex", .string(PrimeR19Bytes.hex(raw))),
            ("raw_sha256", .string(PrimeR19Bytes.sha256(raw))),
            ("valid", .boolean(valid)),
        ])
    }

    static func capture(pgid: pid_t, ordinal: UInt32) -> PrimeR19PGIDSnapshot {
        let before = PrimeR19ClockSample.capture()
        var identifiers = [pid_t](repeating: 0, count: entryCapacity)
        errno = 0
        let returned = identifiers.withUnsafeMutableBytes {
            proc_listpids(
                UInt32(PROC_PGRP_ONLY), UInt32(pgid),
                $0.baseAddress, Int32($0.count)
            )
        }
        let callErrno = errno
        let after = PrimeR19ClockSample.capture()
        let raw = identifiers.withUnsafeBytes { Array($0) }
        let capacityBytes = identifiers.count * MemoryLayout<pid_t>.stride
        var valid = (ordinal == 1 || ordinal == 2)
            && pgid > 1
            && returned >= 0
            && Int(returned) < capacityBytes
            && Int(returned) % MemoryLayout<pid_t>.stride == 0
            && after.ticks >= before.ticks
        let joined = [PrimeR19JoinedProcess]()
        if valid {
            let count = Int(returned) / MemoryLayout<pid_t>.stride
            let listed = Array(identifiers.prefix(count))
            if listed.contains(where: { $0 <= 0 })
                || Set(listed).count != listed.count {
                valid = false
            } else if !listed.isEmpty {
                // A nonempty terminal census is already a permanent veto. Its
                // complete raw PID buffer remains durable; no retrying joins
                // are allowed to replace this first observation.
                valid = false
            }
        }
        return PrimeR19PGIDSnapshot(
            ordinal: ordinal,
            pgid: pgid,
            before: before,
            after: after,
            raw: raw,
            callReturn: returned,
            callErrno: callErrno,
            joined: joined,
            valid: valid
        )
    }
}

private final class PrimeR19ChildOwner {
    private let spawn: PrimeR19SpawnResult
    private let owner: PrimeR19JoinedProcess
    private let authorities: PrimeR19Authorities
    private let journal: PrimeR19Journal
    private let stdout: PrimeR19Pipe
    private let stderr: PrimeR19Pipe
    private let queue: PrimeR19Kqueue
    private var baseline: PrimeR19JoinedProcess?
    private var stdoutCapture = PrimeR19StreamCapture()
    private var stderrCapture = PrimeR19StreamCapture()
    private var terminalObserved = false
    private var terminalSample: PrimeR19RusageSample?
    private var terminalDecoded = false
    private var baselineBootUUID: [UInt8]?
    private var resumed = false
    private var signalCalls = 0
    private var waitCalls = 0
    private var evidenceVeto = false
    private var terminalJournalFailure = false
    private var terminalCoreRejoinFailure = false

    init(
        spawn: PrimeR19SpawnResult,
        owner: PrimeR19JoinedProcess,
        authorities: PrimeR19Authorities,
        journal: PrimeR19Journal,
        stdout: PrimeR19Pipe,
        stderr: PrimeR19Pipe,
        queue: PrimeR19Kqueue
    ) {
        self.spawn = spawn
        self.owner = owner
        self.authorities = authorities
        self.journal = journal
        self.stdout = stdout
        self.stderr = stderr
        self.queue = queue
    }

    func run() -> Never {
        do {
            try queue.register(pid: spawn.pid, stdout: stdout.readFD, stderr: stderr.readFD)
            let child = try requireSuspendedChild()
            baseline = child
            let mapped = try PrimeR19MappedImage.inspect(pid: spawn.pid, held: authorities.ruby)
            let admission = PrimeR19ChildAdmissionRaw.capture(
                child: spawn.pid,
                stdoutRead: stdout.readFD,
                stderrRead: stderr.readFD
            )
            let admissionFrame = try journal.publish(
                schema: "prime_driver_v2_r19_child_suspended_admission_raw_v1",
                status: "COMPLETE_RAW_FD_CWD_PIPE_GENERATION_SANDWICH_DURABLE",
                members: [("capture", admission.rawJSON)]
            )
            let admissionToken = PrimeR19DurableAdmissionToken.issue(
                rawSHA256: admission.rawSHA256,
                frameSHA256: PrimeR19Bytes.sha256(admissionFrame)
            )
            let admissionDecoded = try admission.decode(
                token: admissionToken,
                expected: child,
                owner: owner,
                controller: authorities.controller,
                root: authorities.cwdRoot,
                stdoutReadFD: stdout.readFD,
                stderrReadFD: stderr.readFD
            )
            let afterInspection = try admission.generation1.decode(
                expectedUniqueID: child.unique.uniqueID
            )
            baseline = afterInspection
            try journal.registerMappedChild(
                pid: spawn.pid,
                uniqueID: afterInspection.unique.uniqueID
            )
            try authorities.rejoinAll(
                includeFIFODescriptor: true,
                phase: journal.phase,
                journalPrefix: journal.durablePrefixBytes
            )
            _ = try journal.publish(
                schema: "prime_driver_v2_r19_child_spawned_suspended_v1",
                status: "CHILD_SPAWNED_SUSPENDED_CERTIFIED",
                members: [
                    ("child", afterInspection.json),
                    ("admission", admissionDecoded),
                    ("mapped_ruby", mapped.json),
                    ("spawn_after", spawn.after.json),
                    ("spawn_before", spawn.before.json),
                    ("spawn_errno", .signed(Int64(spawn.callErrno))),
                    ("spawn_return", .signed(Int64(spawn.callReturn))),
                ]
            )

            let baselineRusage = PrimeR19RusageSample.capture(
                pid: spawn.pid,
                ordinal: 1,
                expectedUniqueID: afterInspection.unique.uniqueID
            )
            let baselineRawFrame = try journal.publish(
                schema: "prime_driver_v2_r19_child_baseline_rusage_raw_v1",
                status: "BASELINE_COMPLETE_RAW_PREIMAGE_DURABLE",
                members: [("sample", baselineRusage.rawJSON)]
            )
            let baselineToken = PrimeR19DurableRusageToken.issue(
                ordinal: 1,
                rawFrameSHA256: PrimeR19Bytes.sha256(baselineRawFrame),
                raw464SHA256: PrimeR19Bytes.sha256(baselineRusage.raw464),
                expectedUniqueID: afterInspection.unique.uniqueID
            )
            guard let baselineDecoded = try? baselineRusage.decode(
                token: baselineToken
            ) else {
                precontainmentReject("BASELINE_RUSAGE_NOT_DECODABLE")
            }
            baselineBootUUID = baselineDecoded.bootUUID
            _ = try journal.publish(
                schema: "prime_driver_v2_r19_child_baseline_rusage_decoded_v1",
                status: "BASELINE_DECODED_AFTER_RAW_DURABILITY",
                members: [("sample", baselineDecoded.json)]
            )

            let preAction: PrimeR19JoinedProcess
            do {
                preAction = try journal.durableJoin(
                    pid: spawn.pid,
                    role: "PRE_ACTION_CHILD",
                    expectedUniqueID: afterInspection.unique.uniqueID
                )
                guard preAction.sameGeneration(as: afterInspection) else {
                    throw PrimeR19Failure.rejected
                }
            } catch { precontainmentReject("PRE_ACTION_GENERATION_JOIN_FAILED") }
            try PrimeR19ProcessProof.requireStoppedChild(
                preAction, pid: spawn.pid, owner: owner
            )
            try authorities.rejoinAll(
                includeFIFODescriptor: true,
                phase: journal.phase,
                journalPrefix: journal.durablePrefixBytes
            )
            _ = try journal.publish(
                schema: "prime_driver_v2_r19_child_action_selection_v1",
                status: "SIGCONT_ACTION_DURABLY_SELECTED",
                members: [
                    ("action", .string("SIGCONT_POSITIVE_DIRECT_PID")),
                    ("child", preAction.json),
                    ("maximum_calls", .unsigned(1)),
                    ("signals_authorized_by_crs27", .unsigned(0)),
                ]
            )
            let immediate: PrimeR19JoinedProcess
            do {
                immediate = try journal.durableJoin(
                    pid: spawn.pid,
                    role: "IMMEDIATE_PRECONT_CHILD",
                    expectedUniqueID: preAction.unique.uniqueID
                )
                guard immediate.sameGeneration(as: preAction) else {
                    throw PrimeR19Failure.rejected
                }
            } catch { precontainmentReject("IMMEDIATE_PRECONT_JOIN_FAILED") }
            try PrimeR19ProcessProof.requireStoppedChild(
                immediate, pid: spawn.pid, owner: owner
            )
            let entered = PrimeR19ClockSample.capture()
            guard signalCalls == 0 else { queue.parkForever() }
            try journal.enterEffectsMayExist()
            signalCalls = 1
            errno = 0
            let signalReturn = Darwin.kill(spawn.pid, SIGCONT)
            let signalErrno = errno
            if signalReturn == 0 { resumed = true }
            let returned = PrimeR19ClockSample.capture()
            guard signalCalls == 1,
                  signalReturn == 0
            else { queue.parkForever() }
            if returned.ticks < entered.ticks { evidenceVeto = true }
            do {
                _ = try journal.publish(
                    schema: "prime_driver_v2_r19_child_resumed_v1",
                    status: "SIGCONT_ENTERED_ONCE",
                    members: [
                        ("call_errno", .signed(Int64(signalErrno))),
                        ("call_return", .signed(Int64(signalReturn))),
                        ("entered", entered.json),
                        ("returned", returned.json),
                        ("target_pid", .signed(Int64(spawn.pid))),
                    ]
                )
            } catch {
                terminalJournalFailure = true
            }
            try awaitTerminalAndEOF()
            finishTerminal()
        } catch {
            if !resumed {
                precontainmentReject("PRECONT_CONTRACT_FAILURE")
            }
            queue.parkForever()
        }
    }

    private func requireSuspendedChild() throws -> PrimeR19JoinedProcess {
        let child = try journal.durableJoin(
            pid: spawn.pid,
            role: "INITIAL_SUSPENDED_CHILD"
        )
        try PrimeR19ProcessProof.requireStoppedChild(
            child, pid: spawn.pid, owner: owner
        )
        return child
    }

    private func precontainmentReject(_ reason: String) -> Never {
        _ = try? journal.publish(
            schema: "prime_driver_v2_r19_child_precontainment_reject_v1",
            status: "ZERO_ACTION_INDEFINITE_RETAINED_CONTAINMENT",
            members: [
                ("reason", .string(reason)),
                ("signal_calls", .unsigned(UInt64(signalCalls))),
            ]
        )
        queue.parkForever()
    }

    private func awaitTerminalAndEOF() throws {
        var serviceStdoutFirst = true
        while !terminalObserved || !stdoutCapture.eof || !stderrCapture.eof {
            if serviceStdoutFirst {
                try stdoutCapture.drain(stdout.readFD)
                try stderrCapture.drain(stderr.readFD)
            } else {
                try stderrCapture.drain(stderr.readFD)
                try stdoutCapture.drain(stdout.readFD)
            }
            serviceStdoutFirst.toggle()
            if terminalObserved, terminalSample == nil {
                captureTerminalRusage()
            }
            if terminalObserved, stdoutCapture.eof, stderrCapture.eof { break }
            let events = try queue.wait()
            for event in events {
                guard event.flags & UInt16(EV_ERROR) == 0 else {
                    throw PrimeR19Failure.rejected
                }
                if event.filter == Int16(EVFILT_PROC),
                   event.ident == UInt(spawn.pid),
                   event.fflags & UInt32(NOTE_EXIT) != 0,
                   event.fflags & ~UInt32(NOTE_EXIT) == 0 {
                    if !terminalObserved {
                        if !journal.noteMappedChildTerminal(pid: spawn.pid) {
                            evidenceVeto = true
                        }
                    }
                    terminalObserved = true
                } else if event.filter == Int16(EVFILT_READ),
                          event.ident == UInt(stdout.readFD)
                            || event.ident == UInt(stderr.readFD) {
                    continue
                } else {
                    throw PrimeR19Failure.rejected
                }
            }
            if terminalObserved, terminalSample == nil {
                captureTerminalRusage()
            }
        }
        guard terminalObserved,
              stdoutCapture.eof,
              stderrCapture.eof,
              terminalSample != nil
        else { throw PrimeR19Failure.rejected }
    }

    private func captureTerminalRusage() {
        guard terminalObserved, terminalSample == nil else { return }
        let sample = PrimeR19RusageSample.capture(
            pid: spawn.pid,
            ordinal: 2,
            expectedUniqueID: baseline?.unique.uniqueID ?? 0
        )
        terminalSample = sample
        guard !terminalJournalFailure, !journal.poisoned else {
            terminalJournalFailure = true
            return
        }
        let rawFrame: [UInt8]
        do {
            rawFrame = try journal.publish(
                schema: "prime_driver_v2_r19_child_terminal_rusage_raw_v1",
                status: "TERMINAL_COMPLETE_RAW_PREIMAGE_DURABLE",
                members: [("sample", sample.rawJSON)]
            )
        } catch {
            terminalJournalFailure = true
            return
        }
        let token = PrimeR19DurableRusageToken.issue(
            ordinal: 2,
            rawFrameSHA256: PrimeR19Bytes.sha256(rawFrame),
            raw464SHA256: PrimeR19Bytes.sha256(sample.raw464),
            expectedUniqueID: baseline?.unique.uniqueID ?? 0
        )
        if let decoded = try? sample.decode(token: token),
           decoded.bootUUID == baselineBootUUID {
            do {
                _ = try journal.publish(
                    schema: "prime_driver_v2_r19_child_terminal_rusage_decoded_v1",
                    status: "TERMINAL_DECODED_AFTER_RAW_DURABILITY",
                    members: [("sample", decoded.json)]
                )
                terminalDecoded = true
            } catch {
                terminalJournalFailure = true
            }
        } else {
            evidenceVeto = true
            do {
                _ = try journal.publish(
                    schema: "prime_driver_v2_r19_child_terminal_rusage_decode_withheld_v1",
                    status: "PERMANENT_TERMINAL_EVIDENCE_VETO_CONTINUE_DRAIN_REAP_SNAPSHOTS",
                    members: [
                        ("raw_frame_sha256", .string(token.rawFrameSHA256)),
                        ("raw_sha256", .string(token.raw464SHA256)),
                    ]
                )
            } catch {
                terminalJournalFailure = true
            }
        }
    }

    @discardableResult
    private func publishPostExit(
        schema: String,
        status: String,
        members: [(String, PrimeR19JSON)]
    ) -> Bool {
        guard !terminalJournalFailure,
              !terminalCoreRejoinFailure,
              !journal.poisoned
        else { return false }
        do {
            _ = try journal.publish(
                schema: schema,
                status: status,
                members: members
            )
            return true
        } catch {
            terminalJournalFailure = true
            return false
        }
    }

    private func finishTerminal() -> Never {
        var rawStatus: Int32 = 0
        waitCalls += 1
        errno = 0
        let reaped = Darwin.waitpid(spawn.pid, &rawStatus, 0)
        let reapErrno = errno
        guard waitCalls == 1, reaped == spawn.pid else {
            queue.parkForever()
        }
        if !journal.noteExactDirectReap() {
            terminalCoreRejoinFailure = true
        }
        var stdoutValue = stdoutCapture
        var stderrValue = stderrCapture
        let stdoutFinished = try? stdoutValue.finishJSON()
        let stderrFinished = try? stderrValue.finishJSON()
        if stdoutFinished == nil || stderrFinished == nil { evidenceVeto = true }
        let stdoutJSON = stdoutFinished ?? .null
        let stderrJSON = stderrFinished ?? .null
        _ = publishPostExit(
            schema: "prime_driver_v2_r19_child_direct_reap_and_eof_v1",
            status: "DIRECT_CHILD_REAPED_AND_BOTH_STREAMS_EOF",
            members: [
                ("raw_wait_status", .signed(Int64(rawStatus))),
                ("reap_errno", .signed(Int64(reapErrno))),
                ("reap_return", .signed(Int64(reaped))),
                ("stderr", stderrJSON),
                ("stdout", stdoutJSON),
            ]
        )

        let snapshot1 = PrimeR19PGIDSnapshot.capture(pgid: spawn.pid, ordinal: 1)
        _ = publishPostExit(
            schema: "prime_driver_v2_r19_original_private_pgid_snapshot_v1",
            status: snapshot1.isExactEmpty
                ? "ORIGINAL_PRIVATE_PGID_EMPTY_1"
                : "ORIGINAL_PRIVATE_PGID_NONEMPTY_OR_INVALID_1",
            members: [("snapshot", snapshot1.json)]
        )
        do {
            try authorities.rejoinAll(
                includeFIFODescriptor: true,
                phase: journal.phase,
                journalPrefix: journal.durablePrefixBytes,
                enforceContinuityCandidates: false
            )
        } catch { terminalCoreRejoinFailure = true }
        let snapshot2 = PrimeR19PGIDSnapshot.capture(pgid: spawn.pid, ordinal: 2)
        _ = publishPostExit(
            schema: "prime_driver_v2_r19_original_private_pgid_snapshot_v1",
            status: snapshot2.isExactEmpty
                ? "ORIGINAL_PRIVATE_PGID_EMPTY_2"
                : "ORIGINAL_PRIVATE_PGID_NONEMPTY_OR_INVALID_2",
            members: [("snapshot", snapshot2.json)]
        )
        var undurableInventory: PrimeR19InventoryCapture?
        if !terminalJournalFailure,
           !terminalCoreRejoinFailure,
           !journal.poisoned {
            do {
                let inventoryValid = try journal.captureAndDecodeInventory(
                    ordinal: 5
                )
                if !inventoryValid {
                    evidenceVeto = true
                }
            } catch {
                terminalJournalFailure = true
            }
        } else {
            undurableInventory = PrimeR19InventoryCapture.capture(
                root: authorities.root.descriptor,
                ordinal: 5
            )
        }
        let terminalContinuity = journal.observeTerminalCandidates()
        if !terminalJournalFailure,
           !terminalCoreRejoinFailure,
           !journal.poisoned {
            do {
                try journal.enterTerminalSealAfterCandidateObservation()
            } catch {
                terminalCoreRejoinFailure = true
            }
        }
        if !terminalContinuity { evidenceVeto = true }

        let normalExit0 = rawStatus & 0x7f == 0
            && (rawStatus >> 8) & 0xff == 0
        let passed = normalExit0
            && terminalDecoded
            && stdoutCapture.total == 0
            && stderrCapture.total == 0
            && !stdoutCapture.overflow
            && !stderrCapture.overflow
            && snapshot1.isExactEmpty
            && snapshot2.isExactEmpty
            && !evidenceVeto
            && !terminalJournalFailure
            && !terminalCoreRejoinFailure
            && signalCalls == 1
            && waitCalls == 1
        if terminalJournalFailure || terminalCoreRejoinFailure || journal.poisoned {
            _ = undurableInventory?.rawSHA256
            Darwin._exit(70)
        }
        guard publishPostExit(
            schema: "prime_driver_v2_r19_child_supervisor_terminal_v1",
            status: passed
                ? "CANDIDATE_PENDING_MODE_SEAL_EXTERNAL_EXIT_AND_CONTROLLER_JOURNAL_ADMISSION"
                : "FAIL_CHILD_SCOPED_NO_RETRY",
            members: [
                ("authority_closure", .boolean(false)),
                ("descendant_and_session_conservation", .string("ABSTAIN")),
                ("direct_child_pass", .boolean(passed)),
                ("external_control_chain_cross_joined", .boolean(false)),
                ("gate_e_promotion", .boolean(false)),
                ("raw_wait_status", .signed(Int64(rawStatus))),
                ("session_escape_residual", .boolean(true)),
                ("terminal_core_rejoin_failure", .boolean(false)),
                ("terminal_evidence_veto", .boolean(evidenceVeto)),
                ("terminal_journal_failure", .boolean(false)),
                ("terminal_controller_offset_and_archive_absence", .boolean(
                    terminalContinuity
                )),
                ("terminal_controller_offset_expected", .unsigned(
                    PrimeR19Fixed.controllerBytes
                )),
                ("terminal_controller_offset_observed", journal
                    .terminalObservedControllerOffset
                    .map { PrimeR19JSON.signed(Int64($0)) } ?? .null),
                ("terminal_archive_namespaces_absent", .boolean(
                    journal.terminalArchiveNamespacesAbsent
                )),
            ]
        ) else {
            Darwin._exit(70)
        }
        guard (try? journal.seal()) != nil else { Darwin._exit(70) }
        if passed {
            Darwin._exit(0)
        }
        Darwin._exit(70)
    }
}

private enum PrimeR19Supervisor {
    static func run() throws -> Never {
        let supervisorStandardFDs = try requireIngress()
        _ = umask(mode_t(0o077))
        let authorities = try PrimeR19Authorities.create(
            supervisorStandardFDs: supervisorStandardFDs
        )
        let journal = try PrimeR19Journal(authorities: authorities)
        guard try journal.captureAndDecodeInventory(ordinal: 1) else {
            throw PrimeR19Failure.rejected
        }
        let selfProcess = try journal.durableJoin(
            pid: getpid(), role: "SUPERVISOR_OWNER_INITIAL"
        )
        guard selfProcess.short.pid == UInt32(getpid()),
              selfProcess.short.uid == 501,
              selfProcess.short.realUID == 501,
              selfProcess.short.savedUID == 501,
              selfProcess.short.gid == 20,
              selfProcess.short.realGID == 20,
              selfProcess.short.savedGID == 20
        else {
            throw PrimeR19Failure.rejected
        }
        let selfMapped = try PrimeR19MappedImage.inspect(
            pid: getpid(),
            held: authorities.selfImage
        )
        _ = try journal.publish(
            schema: "prime_driver_v2_r19_child_supervisor_bootstrap_scope_v1",
            status: "BOOTSTRAP_AND_WHOLE_INVOCATION_ABSTAIN",
            members: [
                ("authority_vector", .string("00000000")),
                ("control_commit", .string(PrimeR19Fixed.controlCommit)),
                ("control_frame_with_lf_sha256", .string(PrimeR19Fixed.controlFrameWithLF)),
                ("control_tree", .string(PrimeR19Fixed.controlTree)),
                ("root_creation_before_first_frame", .boolean(true)),
                ("supervisor_bootstrap", .string("ABSTAIN_UNPROVEN")),
                ("whole_invocation_order", .string("ABSTAIN_UNPROVEN_ABSORBING")),
            ]
        )
        _ = try journal.publish(
            schema: "prime_driver_v2_r19_child_supervisor_owner_intent_v1",
            status: "OWNER_INTENT_DURABLE_ZERO_SOURCE_SPAWN_ENTRIES_LIVE_CHILD_CENSUS_UNOBSERVED_REQUIRED_EXTERNALLY",
            members: [
                ("fixed_inputs", authorities.fixedInputsJSON),
                ("mapped_self", selfMapped.json),
                ("owner", selfProcess.json),
                ("spawn_budget", .unsigned(1)),
                ("spawn_calls", .unsigned(0)),
            ]
        )
        try authorities.rejoinAll(
            includeFIFODescriptor: false,
            phase: journal.phase,
            journalPrefix: journal.durablePrefixBytes
        )
        guard try journal.captureAndDecodeInventory(ordinal: 2) else {
            throw PrimeR19Failure.rejected
        }
        _ = try journal.publish(
            schema: "prime_driver_v2_r19_child_supervisor_ready_v1",
            status: "SUPERVISOR_READY_DURABLE_ZERO_SPAWN_CALLS_NO_FIFO_ENDPOINT",
            members: [
                ("external_live_child_census", .string("REQUIRED_SEPARATELY_UNOBSERVED_BY_THIS_FRAME")),
                ("fifo_identity", authorities.fifoInitial.json),
                ("fifo_open_endpoints_owned", .unsigned(0)),
                ("owner", selfProcess.json),
                ("spawn_calls", .unsigned(0)),
                ("token_is_approval", .boolean(false)),
                ("token_writer", .string("EXTERNAL_UNIMPLEMENTED_BY_THIS_SOURCE")),
            ]
        )

        // This is the deliberate resident boundary. With no pre-READY FIFO
        // endpoint, the descriptor-relative O_RDONLY open blocks until the
        // separately frozen writer enters.
        try authorities.openFIFOAfterReady()
        let token = try readExactToken(authorities: authorities)
        _ = try journal.publish(
            schema: "prime_driver_v2_r19_child_supervisor_token_received_v1",
            status: "TOKEN_EXACT_43_PLUS_EOF_EXTERNAL_APPROVAL_NOT_INFERRED",
            members: [
                ("bytes", .unsigned(UInt64(token.count))),
                ("external_approval_verified_by_supervisor", .boolean(false)),
                ("fifo_identity", authorities.fifoInitial.json),
                ("sender_authenticated", .boolean(false)),
                ("sha256", .string(PrimeR19Bytes.sha256(token))),
            ]
        )
        guard try journal.captureAndDecodeInventory(ordinal: 3) else {
            throw PrimeR19Failure.rejected
        }

        let stdout = try PrimeR19Pipe()
        let stderr: PrimeR19Pipe
        do {
            stderr = try PrimeR19Pipe()
        } catch {
            stdout.closeAll()
            throw error
        }
        let queue = try PrimeR19Kqueue()
        try journal.registerInternalPipes(stdout: stdout, stderr: stderr)
        try authorities.rejoinAll(
            includeFIFODescriptor: true,
            phase: journal.phase,
            journalPrefix: journal.durablePrefixBytes
        )
        try journal.validatePrefix()
        let precommitOwner = try journal.durableJoin(
            pid: getpid(),
            role: "SUPERVISOR_OWNER_PRECOMMIT",
            expectedUniqueID: selfProcess.unique.uniqueID
        )
        guard precommitOwner.sameGeneration(as: selfProcess) else {
            throw PrimeR19Failure.rejected
        }
        _ = try journal.publish(
            schema: "prime_driver_v2_r19_child_spawn_commitment_v1",
            status: "CHILD_ATTEMPT_CONSUMED_BEFORE_SOLE_POSIX_SPAWN",
            members: [
                ("argv", .array([
                    .string(PrimeR19Fixed.rubyPath),
                    .string("--disable-gems"),
                    .string("-"),
                ])),
                ("child_attempt_consumed", .boolean(true)),
                ("cwd", .string("/")),
                ("environment", .array([
                    .string("__CF_USER_TEXT_ENCODING=0x1F5:0x0:0x0"),
                ])),
                ("owner", precommitOwner.json),
                ("spawn_api", .string("DARWIN_POSIX_SPAWN_PATH_BASED")),
                ("spawn_flags_hex", .string("448c")),
                ("spawn_maximum", .unsigned(1)),
                ("stderr_pipe", stderr.json),
                ("stdin", authorities.controller.json),
                ("stdout_pipe", stdout.json),
            ]
        )
        guard try journal.captureAndDecodeInventory(ordinal: 4) else {
            throw PrimeR19Failure.rejected
        }
        try authorities.rejoinAll(
            includeFIFODescriptor: true,
            phase: journal.phase,
            journalPrefix: journal.durablePrefixBytes
        )
        try journal.validatePrefix()
        let postcommitOwner = try journal.durableJoin(
            pid: getpid(),
            role: "SUPERVISOR_OWNER_POSTCOMMIT",
            expectedUniqueID: precommitOwner.unique.uniqueID
        )
        guard postcommitOwner.sameGeneration(as: precommitOwner) else {
            throw PrimeR19Failure.rejected
        }

        let spawnOutcome: PrimeR19SpawnOutcome
        var spawnEntered = false
        do {
            spawnOutcome = try PrimeR19Spawner.spawn(
                authorities: authorities,
                stdout: stdout,
                stderr: stderr,
                queue: queue,
                entered: &spawnEntered
            )
        } catch {
            _ = try? journal.publish(
                schema: "prime_driver_v2_r19_child_spawn_failure_v1",
                status: "CONSUMED_UNKNOWN_NO_RETRY",
                members: [("spawn_entered", .boolean(spawnEntered))]
            )
            throw error
        }
        let spawn: PrimeR19SpawnResult
        switch spawnOutcome {
        case let .noChild(evidence):
            _ = try journal.publish(
                schema: "prime_driver_v2_r19_child_spawn_no_child_v1",
                status: "AUTHORITATIVE_NONZERO_RETURN_NO_CHILD_TERMINAL_FAILURE",
                members: [
                    ("after", evidence.after.json),
                    ("before", evidence.before.json),
                    ("pid_out_parameter", .signed(Int64(evidence.pid))),
                    ("spawn_errno_non_authoritative", .signed(Int64(
                        evidence.callErrno
                    ))),
                    ("spawn_return", .signed(Int64(evidence.callReturn))),
                ]
            )
            throw PrimeR19Failure.rejected
        case let .owned(value):
            spawn = value
        }
        stdout.closeWrite()
        stderr.closeWrite()
        let owner = PrimeR19ChildOwner(
            spawn: spawn,
            owner: postcommitOwner,
            authorities: authorities,
            journal: journal,
            stdout: stdout,
            stderr: stderr,
            queue: queue
        )
        owner.run()
    }

    private static func readExactToken(
        authorities: PrimeR19Authorities
    ) throws -> [UInt8] {
        guard authorities.fifoDescriptor >= 3,
              PrimeR19Fixed.token.count == 43,
              PrimeR19Bytes.sha256(PrimeR19Fixed.token)
                == PrimeR19Fixed.tokenSHA256
        else { throw PrimeR19Failure.rejected }
        var token = [UInt8]()
        token.reserveCapacity(43)
        var buffer = [UInt8](repeating: 0, count: 43)
        while token.count < 43 {
            errno = 0
            let returned = buffer.withUnsafeMutableBytes {
                Darwin.read(
                    authorities.fifoDescriptor,
                    $0.baseAddress,
                    43 - token.count
                )
            }
            guard returned > 0 else { throw PrimeR19Failure.rejected }
            token.append(contentsOf: buffer[0..<returned])
        }
        var extra: UInt8 = 0
        errno = 0
        guard Darwin.read(authorities.fifoDescriptor, &extra, 1) == 0,
              token == PrimeR19Fixed.token
        else { throw PrimeR19Failure.rejected }
        try authorities.rejoinFIFODescriptor()
        return token
    }

    private static func requireIngress() throws -> PrimeR19SupervisorFDIdentity {
        guard getpid() > 1,
              geteuid() == 501,
              getegid() == 20,
              CommandLine.argc == 1,
              let environmentAddress = primeR19NSGetEnviron(),
              let environment = environmentAddress.pointee,
              environment.pointee == nil
        else { throw PrimeR19Failure.rejected }
        #if arch(arm64)
        var endian: UInt16 = 1
        guard withUnsafeBytes(of: &endian, { $0[0] == 1 }) else {
            throw PrimeR19Failure.rejected
        }
        #else
        throw PrimeR19Failure.rejected
        #endif
        var cwd = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard cwd.withUnsafeMutableBufferPointer({ getcwd($0.baseAddress, $0.count) }) != nil,
              cwd[0] == CChar(UInt8(ascii: "/")),
              cwd[1] == 0
        else { throw PrimeR19Failure.rejected }
        var descriptors = [proc_fdinfo](repeating: proc_fdinfo(), count: 4)
        let returned = descriptors.withUnsafeMutableBufferPointer {
            proc_pidinfo(
                getpid(), PROC_PIDLISTFDS, 0,
                $0.baseAddress, Int32($0.count * MemoryLayout<proc_fdinfo>.stride)
            )
        }
        guard MemoryLayout<proc_fdinfo>.size == 8,
              MemoryLayout<proc_fdinfo>.stride == 8,
              returned == 24,
              descriptors.prefix(3).map(\.proc_fd).sorted() == [0, 1, 2]
        else { throw PrimeR19Failure.rejected }
        func fdInfo(_ descriptor: Int32, _ flavor: Int32, _ count: Int) throws -> [UInt8] {
            var raw = [UInt8](repeating: 0, count: count)
            errno = 0
            let result = raw.withUnsafeMutableBytes {
                proc_pidfdinfo(
                    getpid(), descriptor, flavor,
                    $0.baseAddress, Int32($0.count)
                )
            }
            guard result == Int32(count) else { throw PrimeR19Failure.rejected }
            return raw
        }
        func rawCString(_ raw: [UInt8], _ offset: Int) throws -> [UInt8] {
            guard let end = raw[offset...].firstIndex(of: 0) else {
                throw PrimeR19Failure.rejected
            }
            return Array(raw[offset..<end])
        }
        let inputRaw = try fdInfo(STDIN_FILENO, PROC_PIDFDVNODEPATHINFO, 1_200)
        let outputRaw = try fdInfo(STDOUT_FILENO, PROC_PIDFDPIPEINFO, 184)
        let errorRaw = try fdInfo(STDERR_FILENO, PROC_PIDFDPIPEINFO, 184)
        var namedNull = stat()
        guard "/dev/null".withCString({
                  fstatat(AT_FDCWD, $0, &namedNull, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              try PrimeR19Bytes.little32(inputRaw, 0) & UInt32(O_ACCMODE)
                == UInt32(O_RDONLY),
              try PrimeR19Bytes.little32(inputRaw, 4) & UInt32(PROC_FP_CLEXEC) == 0,
              try PrimeR19Bytes.little32(inputRaw, 16) == 1,
              try PrimeR19Bytes.little32(inputRaw, 24)
                == UInt32(bitPattern: namedNull.st_dev),
              try PrimeR19Bytes.little64(inputRaw, 32) == UInt64(namedNull.st_ino),
              try PrimeR19Bytes.little32(inputRaw, 140) == UInt32(namedNull.st_rdev),
              try rawCString(inputRaw, 176) == Array("/dev/null".utf8),
              try PrimeR19Bytes.little32(outputRaw, 0) & UInt32(O_ACCMODE)
                == UInt32(O_WRONLY),
              try PrimeR19Bytes.little32(errorRaw, 0) & UInt32(O_ACCMODE)
                == UInt32(O_WRONLY),
              try PrimeR19Bytes.little32(outputRaw, 4) & UInt32(PROC_FP_CLEXEC) == 0,
              try PrimeR19Bytes.little32(errorRaw, 4) & UInt32(PROC_FP_CLEXEC) == 0,
              try PrimeR19Bytes.little32(outputRaw, 16) == 6,
              try PrimeR19Bytes.little32(errorRaw, 16) == 6,
              try PrimeR19Bytes.little64(outputRaw, 160)
                != (try PrimeR19Bytes.little64(errorRaw, 160)),
              try PrimeR19Bytes.little32(outputRaw, 24)
                    != (try PrimeR19Bytes.little32(errorRaw, 24))
                || (try PrimeR19Bytes.little64(outputRaw, 32))
                    != (try PrimeR19Bytes.little64(errorRaw, 32))
        else { throw PrimeR19Failure.rejected }
        var byte: UInt8 = 0
        errno = 0
        guard Darwin.read(STDIN_FILENO, &byte, 1) == 0 else {
            throw PrimeR19Failure.rejected
        }
        let retained = try PrimeR19SupervisorFDIdentity.capture()
        try retained.rejoin()
        return retained
    }
}

@main
private struct PrimeDriverV2R19LocalArchiveBuildOuterSupervisor {
    static func main() {
        // Retired 2026-09-20: this historical R19 helper can retain a failed
        // process domain indefinitely. Reject before bootstrap intake or spawn.
        // Exit without output so a closed/full pipe cannot delay rejection.
        // Original Git blob: c10a40f91b916413b8208bbafa0ffccfeaa27752.
        // Existing binaries and live instances are unaffected.
        Darwin._exit(70)
        do {
            try PrimeR19Supervisor.run()
        } catch {
            Darwin._exit(70)
        }
    }
}
