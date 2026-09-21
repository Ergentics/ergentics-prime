// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin
import Dispatch
import Foundation

@_silgen_name("_NSGetEnviron")
private func primeR19ControllerSupervisorNSGetEnviron()
    -> UnsafeMutablePointer<
        UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
    >

private enum PrimeR19ControllerSupervisorFailure: Error {
    case rejected
}

private struct PrimeR19ReadinessArtifact: Codable, Equatable {
    let controlPredecessorCommit: String
    let controlPredecessorTree: String
    let controllerARawSHA256: String
    let kind: String

    enum CodingKeys: String, CodingKey {
        case controlPredecessorCommit = "control_predecessor_commit"
        case controlPredecessorTree = "control_predecessor_tree"
        case controllerARawSHA256 = "controller_a_raw_sha256"
        case kind
    }
}

private struct PrimeR19ReadinessInvocation: Codable, Equatable {
    let attempt: UInt64
    let id: String
    let journalRoot: String

    enum CodingKeys: String, CodingKey {
        case attempt
        case id
        case journalRoot = "journal_root"
    }
}

private struct PrimeR19SupervisorExpectedIdentity: Codable, Equatable {
    let architecture: String
    let codeDirectoryFullSHA256: String
    let device: UInt64
    let entryoff: UInt64
    let filetype: String
    let flags: UInt32
    let gid: UInt32
    let inode: UInt64
    let lcCodeSignatureOffset: UInt64
    let lcCodeSignatureSize: UInt64
    let loadCommandCount: UInt32
    let loadCommandsSizeBytes: UInt32
    let mode: String
    let nlink: UInt64
    let path: String
    let rawSHA256: String
    let sizeBytes: UInt64
    let uid: UInt32
    let uuid: String

    enum CodingKeys: String, CodingKey {
        case architecture
        case codeDirectoryFullSHA256 = "code_directory_full_sha256"
        case device
        case entryoff
        case filetype
        case flags
        case gid
        case inode
        case lcCodeSignatureOffset = "lc_code_signature_offset"
        case lcCodeSignatureSize = "lc_code_signature_size"
        case loadCommandCount = "load_command_count"
        case loadCommandsSizeBytes = "load_commands_size_bytes"
        case mode
        case nlink
        case path
        case rawSHA256 = "raw_sha256"
        case sizeBytes = "size_bytes"
        case uid
        case uuid
    }
}

private struct PrimeR19ReadinessFrame: Codable, Equatable {
    let artifact: PrimeR19ReadinessArtifact
    let invocation: PrimeR19ReadinessInvocation
    let schema: String
    let supervisorAExpectedIdentity: PrimeR19SupervisorExpectedIdentity

    enum CodingKeys: String, CodingKey {
        case artifact
        case invocation
        case schema
        case supervisorAExpectedIdentity = "supervisor_a_expected_identity"
    }
}

private struct PrimeR19AcceptedReadiness {
    let bytes: Data
    let sha256: String
    let frame: PrimeR19ReadinessFrame
}

private enum PrimeR19CanonicalJSON {
    static func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(value)
    }

    static func sha256Hex(_ data: Data) -> String {
        let alphabet = Array("0123456789abcdef".utf8)
        var result = [UInt8]()
        result.reserveCapacity(64)
        for byte in SHA256.hash(data: data) {
            result.append(alphabet[Int(byte >> 4)])
            result.append(alphabet[Int(byte & 0x0F)])
        }
        return String(decoding: result, as: UTF8.self)
    }

    static func requireLowerHex(_ value: String, count: Int) throws {
        guard value.utf8.count == count,
              value.utf8.allSatisfy({
                  ($0 >= 0x30 && $0 <= 0x39) || ($0 >= 0x61 && $0 <= 0x66)
              })
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    static func requireUpperUUID(_ value: String) throws {
        let bytes = Array(value.utf8)
        let hyphens = Set([8, 13, 18, 23])
        guard bytes.count == 36 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        for index in bytes.indices {
            if hyphens.contains(index) {
                guard bytes[index] == 0x2D else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
            } else {
                let byte = bytes[index]
                guard (byte >= 0x30 && byte <= 0x39)
                        || (byte >= 0x41 && byte <= 0x46)
                else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
            }
        }
    }
}

private enum PrimeR19ReadinessIngress {
    static let maximumBytes = 262_144
    static let readDeadlineNanoseconds: UInt64 = 5_000_000_000

    static func accept() throws -> PrimeR19AcceptedReadiness {
        let bytes = try readExactFrameToEOF()
        let decoder = JSONDecoder()
        let frame = try decoder.decode(PrimeR19ReadinessFrame.self, from: bytes)

        // This raw-byte equality is the duplicate/extra/type/order/escaping gate:
        // JSONDecoder alone is deliberately not treated as canonical authority.
        let canonical = try PrimeR19CanonicalJSON.encode(frame)
        guard canonical == bytes else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        try requireLiterals(frame)
        return PrimeR19AcceptedReadiness(
            bytes: bytes,
            sha256: PrimeR19CanonicalJSON.sha256Hex(bytes),
            frame: frame
        )
    }

    private static func readExactFrameToEOF() throws -> Data {
        let start = DispatchTime.now().uptimeNanoseconds
        let sum = start.addingReportingOverflow(readDeadlineNanoseconds)
        guard !sum.overflow else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let deadline = sum.partialValue
        var result = Data()
        result.reserveCapacity(4_096)
        var buffer = [UInt8](repeating: 0, count: 16_384)
        while true {
            let now = DispatchTime.now().uptimeNanoseconds
            guard now < deadline else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            let remaining = deadline - now
            let roundedMilliseconds = (remaining + 999_999) / 1_000_000
            let timeout = Int32(min(roundedMilliseconds, UInt64(Int32.max)))
            var item = pollfd(
                fd: STDIN_FILENO,
                events: Int16(POLLIN | POLLHUP),
                revents: 0
            )
            errno = 0
            let polled = withUnsafeMutablePointer(to: &item) {
                Darwin.poll($0, 1, timeout)
            }
            if polled < 0, errno == EINTR { continue }
            guard polled == 1,
                  item.revents & Int16(POLLNVAL | POLLERR) == 0,
                  item.revents & Int16(POLLIN | POLLHUP) != 0
            else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            errno = 0
            let count = buffer.withUnsafeMutableBytes {
                Darwin.read(STDIN_FILENO, $0.baseAddress, $0.count)
            }
            if count < 0, errno == EINTR { continue }
            guard count >= 0 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            if count == 0 { break }
            guard result.count <= maximumBytes - count else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            result.append(contentsOf: buffer[0..<count])
        }
        guard !result.isEmpty, result.count <= maximumBytes else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return result
    }

    private static func requireLiterals(_ frame: PrimeR19ReadinessFrame) throws {
        let artifact = frame.artifact
        let invocation = frame.invocation
        let identity = frame.supervisorAExpectedIdentity
        guard frame.schema ==
                "prime_driver_v2_r19_native_leaf_controller_runtime_supervisor_readiness_v1",
              artifact.controlPredecessorCommit ==
                "22015509362f35c7060bc5fa7934d8b583845ba3",
              artifact.controlPredecessorTree ==
                "d577abc8b84d475e6f1d1c90a34058becce2a251",
              artifact.controllerARawSHA256 ==
                "01a8e82d49b5c6c696aceb5ec07172836819d39e2cf1f8d9cc792ff7dd8b9016",
              artifact.kind ==
                "R19_NATIVE_LEAF_CONTROLLER_RUNTIME_SUPERVISOR_22015509_D577ABC8",
              invocation.attempt == 1,
              invocation.id ==
                "r19-native-leaf-controller-runtime-supervisor-22015509-d577abc8",
              invocation.journalRoot ==
                "/private/tmp/r19-native-leaf-controller-runtime-supervisor-22015509-d577abc8",
              identity.architecture == "arm64",
              identity.filetype == "MH_EXECUTE",
              identity.mode == "0700",
              identity.path.first == "/",
              !identity.path.contains("\0"),
              identity.sizeBytes > 0,
              identity.nlink > 0,
              identity.lcCodeSignatureSize > 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        try PrimeR19CanonicalJSON.requireLowerHex(
            identity.codeDirectoryFullSHA256,
            count: 64
        )
        try PrimeR19CanonicalJSON.requireLowerHex(identity.rawSHA256, count: 64)
        try PrimeR19CanonicalJSON.requireUpperUUID(identity.uuid)
    }
}

private struct PrimeR19ExecutableExpectation: Equatable, Sendable {
    let path: String
    let device: UInt64
    let inode: UInt64
    let uid: UInt32
    let gid: UInt32
    let permissions: UInt16
    let links: UInt64
    let flags: UInt32
    let byteCount: UInt64
    let rawSHA256: String
    let uuid: String
    let loadCommandCount: UInt32
    let loadCommandsSize: UInt32
    let entryOffset: UInt64
    let codeSignatureOffset: UInt64
    let codeSignatureSize: UInt64
    let codeDirectorySHA256: String

    init(supervisorA identity: PrimeR19SupervisorExpectedIdentity) throws {
        guard identity.architecture == "arm64",
              identity.filetype == "MH_EXECUTE",
              identity.mode == "0700"
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        try PrimeR19CanonicalJSON.requireLowerHex(identity.rawSHA256, count: 64)
        try PrimeR19CanonicalJSON.requireLowerHex(
            identity.codeDirectoryFullSHA256,
            count: 64
        )
        try PrimeR19CanonicalJSON.requireUpperUUID(identity.uuid)
        self.init(
            path: identity.path,
            device: identity.device,
            inode: identity.inode,
            uid: identity.uid,
            gid: identity.gid,
            permissions: 0o700,
            links: identity.nlink,
            flags: identity.flags,
            byteCount: identity.sizeBytes,
            rawSHA256: identity.rawSHA256,
            uuid: identity.uuid,
            loadCommandCount: identity.loadCommandCount,
            loadCommandsSize: identity.loadCommandsSizeBytes,
            entryOffset: identity.entryoff,
            codeSignatureOffset: identity.lcCodeSignatureOffset,
            codeSignatureSize: identity.lcCodeSignatureSize,
            codeDirectorySHA256: identity.codeDirectoryFullSHA256
        )
        try requireWellFormed()
    }

    private init(
        path: String,
        device: UInt64,
        inode: UInt64,
        uid: UInt32,
        gid: UInt32,
        permissions: UInt16,
        links: UInt64,
        flags: UInt32,
        byteCount: UInt64,
        rawSHA256: String,
        uuid: String,
        loadCommandCount: UInt32,
        loadCommandsSize: UInt32,
        entryOffset: UInt64,
        codeSignatureOffset: UInt64,
        codeSignatureSize: UInt64,
        codeDirectorySHA256: String
    ) {
        self.path = path
        self.device = device
        self.inode = inode
        self.uid = uid
        self.gid = gid
        self.permissions = permissions
        self.links = links
        self.flags = flags
        self.byteCount = byteCount
        self.rawSHA256 = rawSHA256
        self.uuid = uuid
        self.loadCommandCount = loadCommandCount
        self.loadCommandsSize = loadCommandsSize
        self.entryOffset = entryOffset
        self.codeSignatureOffset = codeSignatureOffset
        self.codeSignatureSize = codeSignatureSize
        self.codeDirectorySHA256 = codeDirectorySHA256
    }

    static let controllerA = PrimeR19ExecutableExpectation(
        path: "/private/tmp/prime-driver-v2-r19-native-leaf-admission-controller-repair1-build-a-cfa948e2/PrimeDriverV2R19NativeLeafAdmissionController",
        device: 16_777_231,
        inode: 17_483_372,
        uid: 501,
        gid: 0,
        permissions: 0o700,
        links: 1,
        flags: 0,
        byteCount: 185_056,
        rawSHA256:
            "01a8e82d49b5c6c696aceb5ec07172836819d39e2cf1f8d9cc792ff7dd8b9016",
        uuid: "A9FD612B-DB03-3C61-B03E-4435ED3524FF",
        loadCommandCount: 30,
        loadCommandsSize: 3_536,
        entryOffset: 22_644,
        codeSignatureOffset: 183_456,
        codeSignatureSize: 1_600,
        codeDirectorySHA256:
            "feaced540dbc2d8c9e566b733958f2bcf70c5164ba220680c4775e7055b71972"
    )

    fileprivate func requireWellFormed() throws {
        guard path.first == "/",
              !path.contains("\0"),
              device > 0,
              inode > 0,
              permissions == 0o700,
              links == 1,
              byteCount > 0,
              byteCount <= UInt64(Int.max),
              loadCommandCount > 0,
              loadCommandsSize > 0,
              codeSignatureOffset <= UInt64(Int.max),
              codeSignatureSize > 0,
              codeSignatureSize <= UInt64(Int.max)
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        try PrimeR19CanonicalJSON.requireLowerHex(rawSHA256, count: 64)
        try PrimeR19CanonicalJSON.requireLowerHex(
            codeDirectorySHA256,
            count: 64
        )
        try PrimeR19CanonicalJSON.requireUpperUUID(uuid)
    }
}

private final class PrimeR19HeldExecutable {
    let descriptor: Int32
    let expectation: PrimeR19ExecutableExpectation

    static func open(
        expectation: PrimeR19ExecutableExpectation
    ) throws -> PrimeR19HeldExecutable {
        let descriptor = Darwin.open(
            expectation.path,
            O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard descriptor >= 3 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        do {
            try PrimeR19ExecutableAdmission.requireAdmitted(
                descriptor: descriptor,
                expectation: expectation
            )
            return PrimeR19HeldExecutable(
                descriptor: descriptor,
                expectation: expectation
            )
        } catch {
            _ = Darwin.close(descriptor)
            throw error
        }
    }

    private init(
        descriptor: Int32,
        expectation: PrimeR19ExecutableExpectation
    ) {
        self.descriptor = descriptor
        self.expectation = expectation
    }

    deinit {
        _ = Darwin.close(descriptor)
    }

    func revalidate() throws {
        try PrimeR19ExecutableAdmission.requireAdmitted(
            descriptor: descriptor,
            expectation: expectation
        )
    }
}

private enum PrimeR19ExecutableAdmission {
    private static let machHeaderBytes = 32
    private static let lcUUID: UInt32 = 0x1B
    private static let lcCodeSignature: UInt32 = 0x1D
    private static let lcMain: UInt32 = 0x8000_0028

    static func requireAdmitted(
        descriptor: Int32,
        expectation: PrimeR19ExecutableExpectation
    ) throws {
        try expectation.requireWellFormed()
        let descriptorFlags = fcntl(descriptor, F_GETFD)
        let statusFlags = fcntl(descriptor, F_GETFL)
        guard descriptor >= 3,
              descriptorFlags >= 0,
              descriptorFlags & FD_CLOEXEC != 0,
              statusFlags >= 0,
              statusFlags & O_ACCMODE == O_RDONLY
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }

        var held = stat()
        var named = stat()
        let namedResult = expectation.path.withCString {
            fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
        }
        guard fstat(descriptor, &held) == 0,
              namedResult == 0,
              exactMetadata(held, expectation: expectation),
              exactMetadata(named, expectation: expectation),
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }

        let bytes = try readExact(
            descriptor,
            byteCount: Int(expectation.byteCount)
        )
        guard PrimeR19CanonicalJSON.sha256Hex(bytes) == expectation.rawSHA256
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        try requireMachO(bytes, expectation: expectation)
    }

    private static func exactMetadata(
        _ value: stat,
        expectation: PrimeR19ExecutableExpectation
    ) -> Bool {
        value.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
            && UInt64(bitPattern: Int64(value.st_dev)) == expectation.device
            && UInt64(value.st_ino) == expectation.inode
            && UInt32(value.st_uid) == expectation.uid
            && UInt32(value.st_gid) == expectation.gid
            && UInt16(value.st_mode & mode_t(0o7777)) == expectation.permissions
            && UInt64(value.st_nlink) == expectation.links
            && value.st_flags == expectation.flags
            && value.st_size >= 0
            && UInt64(value.st_size) == expectation.byteCount
    }

    private static func readExact(
        _ descriptor: Int32,
        byteCount: Int
    ) throws -> Data {
        var result = Data(count: byteCount)
        var offset = 0
        try result.withUnsafeMutableBytes { raw in
            guard let base = raw.baseAddress else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            while offset < raw.count {
                errno = 0
                let count = pread(
                    descriptor,
                    base.advanced(by: offset),
                    raw.count - offset,
                    off_t(offset)
                )
                if count < 0, errno == EINTR { continue }
                guard count > 0 else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
                offset += count
            }
        }
        var extra: UInt8 = 0
        guard pread(descriptor, &extra, 1, off_t(byteCount)) == 0 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return result
    }

    private static func requireMachO(
        _ bytes: Data,
        expectation: PrimeR19ExecutableExpectation
    ) throws {
        guard bytes.count >= machHeaderBytes,
              try little32(bytes, 0) == 0xFEED_FACF,
              try little32(bytes, 4) == 0x0100_000C,
              try little32(bytes, 12) == UInt32(MH_EXECUTE),
              try little32(bytes, 16) == expectation.loadCommandCount,
              try little32(bytes, 20) == expectation.loadCommandsSize
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let commandsEnd = machHeaderBytes.addingReportingOverflow(
            Int(expectation.loadCommandsSize)
        )
        guard !commandsEnd.overflow, commandsEnd.partialValue <= bytes.count else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }

        var cursor = machHeaderBytes
        var observedUUID: String?
        var observedEntryOffset: UInt64?
        var observedSignature: (offset: UInt64, size: UInt64)?
        for _ in 0..<expectation.loadCommandCount {
            let command = try little32(bytes, cursor)
            let commandSize = Int(try little32(bytes, cursor + 4))
            guard commandSize >= 8,
                  commandSize % 8 == 0,
                  cursor <= commandsEnd.partialValue - commandSize
            else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            switch command {
            case lcUUID:
                guard commandSize == 24, observedUUID == nil else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
                observedUUID = uuidString(Array(bytes[(cursor + 8)..<(cursor + 24)]))
            case lcMain:
                guard commandSize == 24, observedEntryOffset == nil else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
                observedEntryOffset = try little64(bytes, cursor + 8)
            case lcCodeSignature:
                guard commandSize == 16, observedSignature == nil else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
                observedSignature = (
                    UInt64(try little32(bytes, cursor + 8)),
                    UInt64(try little32(bytes, cursor + 12))
                )
            default:
                break
            }
            cursor += commandSize
        }
        guard cursor == commandsEnd.partialValue,
              observedUUID == expectation.uuid,
              observedEntryOffset == expectation.entryOffset,
              observedSignature?.offset == expectation.codeSignatureOffset,
              observedSignature?.size == expectation.codeSignatureSize
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        try requireCodeDirectory(bytes, expectation: expectation)
    }

    private static func requireCodeDirectory(
        _ bytes: Data,
        expectation: PrimeR19ExecutableExpectation
    ) throws {
        let signatureOffset = Int(expectation.codeSignatureOffset)
        let signatureSize = Int(expectation.codeSignatureSize)
        guard signatureOffset >= 0,
              signatureSize >= 20,
              signatureOffset <= bytes.count - signatureSize,
              try big32(bytes, signatureOffset) == 0xFADE_0CC0,
              Int(try big32(bytes, signatureOffset + 4)) == signatureSize
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let count = Int(try big32(bytes, signatureOffset + 8))
        guard count > 0, count <= (signatureSize - 12) / 8 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        var codeDirectoryRange: Range<Int>?
        for index in 0..<count {
            let entry = signatureOffset + 12 + (index * 8)
            let type = try big32(bytes, entry)
            let relativeOffset = Int(try big32(bytes, entry + 4))
            guard relativeOffset >= 0, relativeOffset <= signatureSize - 8 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            if type == 0 {
                guard codeDirectoryRange == nil else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
                let start = signatureOffset + relativeOffset
                guard try big32(bytes, start) == 0xFADE_0C02 else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
                let length = Int(try big32(bytes, start + 4))
                guard length >= 8,
                      start >= signatureOffset,
                      start <= signatureOffset + signatureSize - length
                else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
                codeDirectoryRange = start..<(start + length)
            }
        }
        guard let range = codeDirectoryRange,
              PrimeR19CanonicalJSON.sha256Hex(Data(bytes[range])) ==
                expectation.codeDirectorySHA256
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    private static func uuidString(_ bytes: [UInt8]) -> String {
        let alphabet = Array("0123456789ABCDEF".utf8)
        var result = [UInt8]()
        result.reserveCapacity(36)
        for index in bytes.indices {
            if index == 4 || index == 6 || index == 8 || index == 10 {
                result.append(0x2D)
            }
            result.append(alphabet[Int(bytes[index] >> 4)])
            result.append(alphabet[Int(bytes[index] & 0x0F)])
        }
        return String(decoding: result, as: UTF8.self)
    }

    private static func little32(_ bytes: Data, _ offset: Int) throws -> UInt32 {
        guard offset >= 0, offset <= bytes.count - 4 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return UInt32(bytes[offset])
            | (UInt32(bytes[offset + 1]) << 8)
            | (UInt32(bytes[offset + 2]) << 16)
            | (UInt32(bytes[offset + 3]) << 24)
    }

    private static func little64(_ bytes: Data, _ offset: Int) throws -> UInt64 {
        UInt64(try little32(bytes, offset))
            | (UInt64(try little32(bytes, offset + 4)) << 32)
    }

    private static func big32(_ bytes: Data, _ offset: Int) throws -> UInt32 {
        guard offset >= 0, offset <= bytes.count - 4 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return (UInt32(bytes[offset]) << 24)
            | (UInt32(bytes[offset + 1]) << 16)
            | (UInt32(bytes[offset + 2]) << 8)
            | UInt32(bytes[offset + 3])
    }
}

private struct PrimeR19UniqueProcessIdentity: Equatable {
    let uuid: [UInt8]
    let uniqueID: UInt64
    let parentUniqueID: UInt64
    let idVersion: UInt32
    let originalParentIDVersion: UInt32
}

private struct PrimeR19ShortProcessIdentity: Equatable {
    let pid: UInt32
    let parentPID: UInt32
    let processGroup: UInt32
    let status: UInt32
    let command: [UInt8]
    let userID: UInt32
    let groupID: UInt32
    let realUserID: UInt32
    let realGroupID: UInt32
    let savedUserID: UInt32
    let savedGroupID: UInt32

    func sameIdentity(as other: Self) -> Bool {
        pid == other.pid
            && parentPID == other.parentPID
            && processGroup == other.processGroup
            && command == other.command
            && userID == other.userID
            && groupID == other.groupID
            && realUserID == other.realUserID
            && realGroupID == other.realGroupID
            && savedUserID == other.savedUserID
            && savedGroupID == other.savedGroupID
    }
}

private struct PrimeR19JoinedProcess: Equatable {
    let unique: PrimeR19UniqueProcessIdentity
    let short: PrimeR19ShortProcessIdentity
    let session: pid_t
    let processGroup: pid_t

    func sameIdentity(as other: Self) -> Bool {
        unique == other.unique
            && short.sameIdentity(as: other.short)
            && session == other.session
            && processGroup == other.processGroup
    }
}

private struct PrimeR19Deadline {
    static let durationNanoseconds: UInt64 = 30_000_000_000
    let absoluteNanoseconds: UInt64

    init() throws {
        let now = DispatchTime.now().uptimeNanoseconds
        let sum = now.addingReportingOverflow(Self.durationNanoseconds)
        guard !sum.overflow else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        absoluteNanoseconds = sum.partialValue
    }

    var expired: Bool {
        DispatchTime.now().uptimeNanoseconds >= absoluteNanoseconds
    }

}

private final class PrimeR19Pipe {
    private(set) var readDescriptor: Int32
    private(set) var writeDescriptor: Int32

    init() throws {
        var descriptors: [Int32] = [-1, -1]
        let result = descriptors.withUnsafeMutableBufferPointer {
            Darwin.pipe($0.baseAddress)
        }
        guard result == 0,
              descriptors[0] >= 3,
              descriptors[1] >= 3,
              descriptors[0] != descriptors[1]
        else {
            if descriptors[0] >= 0 { _ = Darwin.close(descriptors[0]) }
            if descriptors[1] >= 0 { _ = Darwin.close(descriptors[1]) }
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        readDescriptor = descriptors[0]
        writeDescriptor = descriptors[1]
        do {
            try Self.requireCloseOnExec(readDescriptor)
            try Self.requireCloseOnExec(writeDescriptor)
            let readFlags = fcntl(readDescriptor, F_GETFL)
            let writeFlags = fcntl(writeDescriptor, F_GETFL)
            guard readFlags == O_RDONLY,
                  writeFlags == O_WRONLY,
                  fcntl(readDescriptor, F_SETFL, readFlags | O_NONBLOCK) == 0,
                  fcntl(readDescriptor, F_GETFL) == (O_RDONLY | O_NONBLOCK),
                  fcntl(writeDescriptor, F_GETFL) == O_WRONLY
            else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
        } catch {
            closeAll()
            throw error
        }
    }

    func closeWriteEnd() {
        if writeDescriptor >= 0 {
            _ = Darwin.close(writeDescriptor)
            writeDescriptor = -1
        }
    }

    func closeAll() {
        if readDescriptor >= 0 {
            _ = Darwin.close(readDescriptor)
            readDescriptor = -1
        }
        closeWriteEnd()
    }

    deinit { closeAll() }

    private static func requireCloseOnExec(_ descriptor: Int32) throws {
        let existing = fcntl(descriptor, F_GETFD)
        guard existing >= 0,
              fcntl(descriptor, F_SETFD, existing | FD_CLOEXEC) == 0,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }
}

private struct PrimeR19StreamCapture {
    static let cap = 4_096
    static let chunkBytes = 16_384
    static let drainReadQuantum = 4
    static let drainByteQuantum = 65_536
    var bytes: [UInt8] = []
    var overflow = false
    var eof = false

    mutating func drain(_ descriptor: Int32) throws {
        guard !eof else { return }
        var buffer = [UInt8](repeating: 0, count: Self.chunkBytes)
        var reads = 0
        var drainedBytes = 0
        while reads < Self.drainReadQuantum,
              drainedBytes < Self.drainByteQuantum {
            let requested = min(
                buffer.count,
                Self.drainByteQuantum - drainedBytes
            )
            errno = 0
            let count = buffer.withUnsafeMutableBytes {
                Darwin.read(descriptor, $0.baseAddress, requested)
            }
            reads += 1
            if count > 0 {
                drainedBytes += count
                let available = max(0, Self.cap - bytes.count)
                let retained = min(available, count)
                if retained > 0 {
                    bytes.append(contentsOf: buffer[0..<retained])
                }
                if retained != count { overflow = true }
                continue
            }
            if count == 0 {
                eof = true
                return
            }
            if errno == EINTR { continue }
            if errno == EAGAIN || errno == EWOULDBLOCK { return }
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }
}

private final class PrimeR19HeldAuthorities {
    private static let rootPath = "/"
    private static let privateTmpPath = "/private/tmp"
    private static let nullPath = "/dev/null"

    let rootDescriptor: Int32
    let privateTmpDescriptor: Int32
    let nullDescriptor: Int32
    private let supervisor: PrimeR19HeldExecutable
    private let controller: PrimeR19HeldExecutable
    var supervisorDescriptor: Int32 { supervisor.descriptor }
    var supervisorExpectation: PrimeR19ExecutableExpectation {
        supervisor.expectation
    }
    var controllerExpectation: PrimeR19ExecutableExpectation {
        controller.expectation
    }
    var controllerDescriptor: Int32 { controller.descriptor }
    static func prepare(
        readiness: PrimeR19AcceptedReadiness,
        queue: Int32
    ) throws -> (
        authorities: PrimeR19HeldAuthorities,
        watcher: PrimeR19StickyExecutableVnodeWatcher
    ) {
        let root = Darwin.open(
            rootPath,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard root >= 3 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        var owned = [root]
        do {
            try requireRoot(root)
            let privateTmp = Darwin.open(
                privateTmpPath,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
            guard privateTmp >= 3 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            owned.append(privateTmp)
            try requirePrivateTmp(privateTmp)
            let null = Darwin.open(
                nullPath,
                O_RDONLY | O_CLOEXEC
            )
            guard null >= 3 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            owned.append(null)
            try requireNull(null)
            let supervisor = try PrimeR19HeldExecutable.open(
                expectation: PrimeR19ExecutableExpectation(
                    supervisorA: readiness.frame.supervisorAExpectedIdentity
                )
            )
            let watcher = try PrimeR19StickyExecutableVnodeWatcher(
                queue: queue,
                supervisorDescriptor: supervisor.descriptor
            )
            try supervisor.revalidate()
            _ = try PrimeR19MappedImageInspector.inspect(
                pid: getpid(),
                heldExecutable: supervisor.descriptor,
                expectedPath: supervisor.expectation.path
            )
            try watcher.drainNonblocking()
            guard watcher.stickyState.supervisor == 0 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }

            let controller = try PrimeR19HeldExecutable.open(
                expectation: .controllerA
            )
            try watcher.armController(controller.descriptor)
            try supervisor.revalidate()
            try controller.revalidate()
            try watcher.drainNonblocking()
            guard watcher.isFullyArmed, watcher.isZero else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }

            let authorities = PrimeR19HeldAuthorities(
                rootDescriptor: root,
                privateTmpDescriptor: privateTmp,
                nullDescriptor: null,
                supervisor: supervisor,
                controller: controller
            )
            return (authorities, watcher)
        } catch {
            for descriptor in owned.reversed() { _ = Darwin.close(descriptor) }
            throw error
        }
    }

    private init(
        rootDescriptor: Int32,
        privateTmpDescriptor: Int32,
        nullDescriptor: Int32,
        supervisor: PrimeR19HeldExecutable,
        controller: PrimeR19HeldExecutable
    ) {
        self.rootDescriptor = rootDescriptor
        self.privateTmpDescriptor = privateTmpDescriptor
        self.nullDescriptor = nullDescriptor
        self.supervisor = supervisor
        self.controller = controller
    }

    deinit {
        _ = Darwin.close(nullDescriptor)
        _ = Darwin.close(privateTmpDescriptor)
        _ = Darwin.close(rootDescriptor)
    }

    func revalidateBeforeResume() throws {
        try Self.requireRoot(rootDescriptor)
        try Self.requirePrivateTmp(privateTmpDescriptor)
        try Self.requireNull(nullDescriptor)
        try supervisor.revalidate()
        try controller.revalidate()
    }

    func revalidateAfterReap() throws {
        try revalidateBeforeResume()
    }

    func heldRootIdentity() throws -> PrimeR19CWDInspection {
        try Self.requireRoot(rootDescriptor)
        var value = stat()
        guard fstat(rootDescriptor, &value) == 0 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return PrimeR19CWDInspection(
            device: UInt32(bitPattern: value.st_dev),
            inode: UInt64(value.st_ino)
        )
    }

    private static func requireRoot(_ descriptor: Int32) throws {
        try requireDirectory(
            descriptor,
            path: rootPath,
            device: dev_t(16_777_231),
            inode: ino_t(2),
            permissions: mode_t(0o755),
            flags: 1_048_576
        )
        var filesystem = statfs()
        guard fstatfs(descriptor, &filesystem) == 0,
              filesystem.f_flags & UInt32(MNT_LOCAL) != 0,
              filesystem.f_flags & UInt32(MNT_RDONLY) != 0,
              filesystemType(filesystem) == Array("apfs".utf8)
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    private static func requirePrivateTmp(_ descriptor: Int32) throws {
        try requireDirectory(
            descriptor,
            path: privateTmpPath,
            device: dev_t(16_777_231),
            inode: ino_t(774_813),
            permissions: mode_t(0o1777),
            flags: 0
        )
        var filesystem = statfs()
        guard fstatfs(descriptor, &filesystem) == 0,
              filesystem.f_flags & UInt32(MNT_LOCAL) != 0,
              filesystemType(filesystem) == Array("apfs".utf8)
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    private static func requireDirectory(
        _ descriptor: Int32,
        path: String,
        device: dev_t,
        inode: ino_t,
        permissions: mode_t,
        flags: UInt32
    ) throws {
        try requireCloseOnExec(descriptor)
        let statusFlags = fcntl(descriptor, F_GETFL)
        var held = stat()
        var named = stat()
        guard statusFlags >= 0,
              statusFlags & O_ACCMODE == O_RDONLY,
              fstat(descriptor, &held) == 0,
              path.withCString({
                  fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              held.st_dev == device,
              named.st_dev == device,
              held.st_ino == inode,
              named.st_ino == inode,
              held.st_uid == 0,
              named.st_uid == 0,
              held.st_gid == 0,
              named.st_gid == 0,
              held.st_mode & mode_t(0o7777) == permissions,
              named.st_mode & mode_t(0o7777) == permissions,
              held.st_flags == flags,
              named.st_flags == flags
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    private static func requireNull(_ descriptor: Int32) throws {
        try requireCloseOnExec(descriptor)
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              nullPath.withCString({
                  fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFCHR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFCHR),
              UInt32(bitPattern: held.st_dev) == 3_836_289_247,
              UInt32(bitPattern: named.st_dev) == 3_836_289_247,
              held.st_ino == ino_t(336),
              named.st_ino == ino_t(336),
              held.st_rdev == dev_t(50_331_650),
              named.st_rdev == dev_t(50_331_650),
              held.st_uid == 0,
              named.st_uid == 0,
              held.st_gid == 0,
              named.st_gid == 0,
              held.st_mode & mode_t(0o7777) == mode_t(0o666),
              named.st_mode & mode_t(0o7777) == mode_t(0o666),
              fcntl(descriptor, F_GETFL) == O_RDONLY,
              isatty(descriptor) == 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    private static func requireCloseOnExec(_ descriptor: Int32) throws {
        let flags = fcntl(descriptor, F_GETFD)
        guard descriptor >= 3, flags >= 0, flags & FD_CLOEXEC != 0 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    private static func filesystemType(_ filesystem: statfs) -> [UInt8] {
        var field = filesystem.f_fstypename
        return withUnsafeBytes(of: &field) { Array($0.prefix { $0 != 0 }) }
    }
}

private enum PrimeR19ProcessProof {
    static let uniqueFlavor: Int32 = 17
    static let shortFlavor: Int32 = 13
    static let uniqueBytes = 56
    static let shortBytes = 64
    static let attempts = 4

    static func join(_ pid: pid_t) throws -> PrimeR19JoinedProcess? {
        for _ in 0..<attempts {
            guard let unique0 = try readUnique(pid),
                  let short0 = try readShort(pid),
                  let session0 = readDomain(pid, session: true),
                  let group0 = readDomain(pid, session: false),
                  let session1 = readDomain(pid, session: true),
                  let group1 = readDomain(pid, session: false),
                  let short1 = try readShort(pid),
                  let unique1 = try readUnique(pid)
            else { return nil }
            if unique0 == unique1,
               short0.sameIdentity(as: short1),
               session0 == session1,
               group0 == group1,
               group0 == pid_t(short0.processGroup),
               group1 == pid_t(short1.processGroup) {
                return PrimeR19JoinedProcess(
                    unique: unique1,
                    short: short1,
                    session: session1,
                    processGroup: group1
                )
            }
        }
        throw PrimeR19ControllerSupervisorFailure.rejected
    }

    static func requirePrivateStoppedChild(
        _ joined: PrimeR19JoinedProcess,
        pid: pid_t
    ) throws {
        let expectedUID = UInt32(geteuid())
        let expectedGID = UInt32(getegid())
        guard joined.short.pid == UInt32(pid),
              joined.short.parentPID == UInt32(getpid()),
              joined.short.processGroup == UInt32(pid),
              joined.short.status == 4,
              joined.processGroup == pid,
              joined.session == pid,
              joined.short.userID == expectedUID,
              joined.short.realUserID == expectedUID,
              joined.short.savedUserID == expectedUID,
              joined.short.groupID == expectedGID,
              joined.short.realGroupID == expectedGID,
              joined.short.savedGroupID == expectedGID
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    static func requireSamePrivateChild(
        _ joined: PrimeR19JoinedProcess,
        baseline: PrimeR19JoinedProcess,
        pid: pid_t
    ) throws {
        guard joined.sameIdentity(as: baseline),
              joined.short.pid == UInt32(pid),
              joined.short.parentPID == UInt32(getpid()),
              joined.processGroup == pid,
              joined.session == pid
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    private static func readUnique(
        _ pid: pid_t
    ) throws -> PrimeR19UniqueProcessIdentity? {
        var bytes = [UInt8](repeating: 0, count: uniqueBytes)
        errno = 0
        let returned = bytes.withUnsafeMutableBytes {
            proc_pidinfo(pid, uniqueFlavor, 0, $0.baseAddress, Int32($0.count))
        }
        let observedErrno = errno
        if returned == 0, observedErrno == ESRCH { return nil }
        guard returned == Int32(uniqueBytes),
              little64(bytes, 16) != 0,
              little64(bytes, 40) == 0,
              little64(bytes, 48) == 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return PrimeR19UniqueProcessIdentity(
            uuid: Array(bytes[0..<16]),
            uniqueID: little64(bytes, 16),
            parentUniqueID: little64(bytes, 24),
            idVersion: little32(bytes, 32),
            originalParentIDVersion: little32(bytes, 36)
        )
    }

    private static func readShort(
        _ pid: pid_t
    ) throws -> PrimeR19ShortProcessIdentity? {
        var bytes = [UInt8](repeating: 0, count: shortBytes)
        errno = 0
        let returned = bytes.withUnsafeMutableBytes {
            proc_pidinfo(pid, shortFlavor, 0, $0.baseAddress, Int32($0.count))
        }
        let observedErrno = errno
        if returned == 0, observedErrno == ESRCH { return nil }
        guard returned == Int32(shortBytes),
              little32(bytes, 0) == UInt32(pid),
              little32(bytes, 60) == 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return PrimeR19ShortProcessIdentity(
            pid: little32(bytes, 0),
            parentPID: little32(bytes, 4),
            processGroup: little32(bytes, 8),
            status: little32(bytes, 12),
            command: Array(bytes[16..<32]),
            userID: little32(bytes, 36),
            groupID: little32(bytes, 40),
            realUserID: little32(bytes, 44),
            realGroupID: little32(bytes, 48),
            savedUserID: little32(bytes, 52),
            savedGroupID: little32(bytes, 56)
        )
    }

    private static func readDomain(
        _ pid: pid_t,
        session: Bool
    ) -> pid_t? {
        errno = 0
        let result = session ? getsid(pid) : getpgid(pid)
        if result >= 0 { return result }
        return nil
    }

    static func little32(_ bytes: [UInt8], _ offset: Int) -> UInt32 {
        UInt32(bytes[offset])
            | (UInt32(bytes[offset + 1]) << 8)
            | (UInt32(bytes[offset + 2]) << 16)
            | (UInt32(bytes[offset + 3]) << 24)
    }

    static func little64(_ bytes: [UInt8], _ offset: Int) -> UInt64 {
        UInt64(little32(bytes, offset))
            | (UInt64(little32(bytes, offset + 4)) << 32)
    }
}

private struct PrimeR19MappedImageInspection: Equatable {
    let device: dev_t
    let inode: ino_t
    let mainRegionCount: Int
    let queryCount: Int
    let executableOffsetZero: Bool
}

private struct PrimeR19CWDInspection: Equatable {
    let device: UInt32
    let inode: UInt64
}

private struct PrimeR19ContObservation: Equatable {
    let enteredAtNanoseconds: UInt64
    let returnValue: Int32
    let returnedAtNanoseconds: UInt64
}

/// Binds a complete region walk to both a stable process generation and an
/// already-held executable. This deliberately accepts no path-only authority.
private enum PrimeR19MappedImageInspector {
    private static let regionBytes = 1_272
    private static let queryCap = 65_536

    static func inspect(
        pid: pid_t,
        heldExecutable: Int32,
        expectedPath: String
    ) throws -> PrimeR19MappedImageInspection {
        guard MemoryLayout<proc_regionwithpathinfo>.size == regionBytes,
              heldExecutable >= 3,
              expectedPath.utf8.count < 1_024,
              let before = try PrimeR19ProcessProof.join(pid)
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        var held = stat()
        guard fstat(heldExecutable, &held) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }

        let pathAuthority = Array(expectedPath.utf8)
        let heldDevice = UInt32(bitPattern: held.st_dev)
        let heldInode = UInt64(held.st_ino)
        var address: UInt64 = 0
        var mainRegionCount = 0
        var queryCount = 0
        var executableOffsetZero = false
        var reachedEnd = false

        while queryCount < queryCap {
            var bytes = [UInt8](repeating: 0, count: regionBytes)
            errno = 0
            let returned = bytes.withUnsafeMutableBytes {
                proc_pidinfo(
                    pid, PROC_PIDREGIONPATHINFO, address,
                    $0.baseAddress, Int32($0.count)
                )
            }
            let observedErrno = errno
            queryCount += 1
            if returned == 0 {
                guard observedErrno == EINVAL else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
                reachedEnd = true
                break
            }
            guard returned == Int32(regionBytes) else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }

            let protection = PrimeR19ProcessProof.little32(bytes, 0)
            let fileOffset = PrimeR19ProcessProof.little64(bytes, 16)
            let regionAddress = PrimeR19ProcessProof.little64(bytes, 80)
            let regionSize = PrimeR19ProcessProof.little64(bytes, 88)
            let device = PrimeR19ProcessProof.little32(bytes, 96)
            let inode = PrimeR19ProcessProof.little64(bytes, 104)
            guard regionAddress >= address, regionSize > 0 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            let following = regionAddress.addingReportingOverflow(regionSize)
            guard !following.overflow,
                  following.partialValue > regionAddress,
                  following.partialValue > address
            else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }

            let pathField = bytes[248..<regionBytes]
            guard let terminator = pathField.firstIndex(of: 0) else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            let pathMatches = Array(pathField[..<terminator]) == pathAuthority
            let vnodeMatches = device == heldDevice && inode == heldInode
            if pathMatches || vnodeMatches {
                guard pathMatches, vnodeMatches else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
                mainRegionCount += 1
                if fileOffset == 0,
                   protection & UInt32(VM_PROT_EXECUTE) != 0 {
                    executableOffsetZero = true
                }
            }
            address = following.partialValue
        }

        guard reachedEnd,
              mainRegionCount > 0,
              executableOffsetZero,
              let after = try PrimeR19ProcessProof.join(pid),
              after.sameIdentity(as: before),
              after.session == before.session,
              after.processGroup == before.processGroup
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return PrimeR19MappedImageInspection(
            device: held.st_dev,
            inode: held.st_ino,
            mainRegionCount: mainRegionCount,
            queryCount: queryCount,
            executableOffsetZero: executableOffsetZero
        )
    }
}

/// Two continuously armed executable watches sharing the controller kqueue.
/// `consume` is the child-loop hook; once observed, note bits never clear.
private final class PrimeR19StickyExecutableVnodeWatcher {
    private typealias DarwinKevent = Darwin.kevent
    private static let noteMask =
        UInt32(NOTE_ATTRIB) | UInt32(NOTE_DELETE) | UInt32(NOTE_EXTEND)
        | UInt32(NOTE_LINK) | UInt32(NOTE_RENAME) | UInt32(NOTE_REVOKE)
        | UInt32(NOTE_WRITE)

    private let queue: Int32
    private let supervisorDescriptor: Int32
    private var controllerDescriptor: Int32?
    private(set) var supervisorStickyFlags: UInt32 = 0
    private(set) var controllerStickyFlags: UInt32 = 0

    var isZero: Bool {
        controllerDescriptor != nil
            && supervisorStickyFlags == 0
            && controllerStickyFlags == 0
    }

    var isFullyArmed: Bool { controllerDescriptor != nil }

    var stickyState: (supervisor: UInt32, controller: UInt32) {
        (supervisorStickyFlags, controllerStickyFlags)
    }

    /// Arm the already mapped supervisor image first. The controller image is
    /// opened only after the supervisor has joined itself to this held vnode.
    init(
        queue: Int32,
        supervisorDescriptor: Int32
    ) throws {
        guard queue >= 3,
              supervisorDescriptor >= 3
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        self.queue = queue
        self.supervisorDescriptor = supervisorDescriptor
        controllerDescriptor = nil
        try register(supervisorDescriptor)
    }

    func armController(_ descriptor: Int32) throws {
        guard descriptor >= 3,
              descriptor != supervisorDescriptor,
              controllerDescriptor == nil
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        try register(descriptor)
        controllerDescriptor = descriptor
    }

    private func register(_ descriptor: Int32) throws {
        var change = DarwinKevent(
            ident: UInt(descriptor),
            filter: Int16(EVFILT_VNODE),
            flags: UInt16(EV_ADD) | UInt16(EV_ENABLE) | UInt16(EV_CLEAR)
                | UInt16(EV_RECEIPT),
            fflags: Self.noteMask,
            data: 0,
            udata: nil
        )
        var receipt = DarwinKevent()
        errno = 0
        let returned = withUnsafePointer(to: &change) { changes in
            withUnsafeMutablePointer(to: &receipt) { events in
                kevent(queue, changes, 1, events, 1, nil)
            }
        }
        guard returned == 1,
              receipt.ident == UInt(descriptor),
              receipt.filter == Int16(EVFILT_VNODE),
              receipt.flags & UInt16(EV_ERROR) != 0,
              receipt.data == 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    /// Returns true when the event belonged to this watcher. Receipt/error
    /// events are never accepted as runtime mutation observations.
    @discardableResult
    func consume(_ event: Darwin.kevent) throws -> Bool {
        guard event.filter == Int16(EVFILT_VNODE) else { return false }
        guard event.flags & UInt16(EV_ERROR) == 0,
              event.fflags & ~Self.noteMask == 0,
              event.fflags != 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        if event.ident == UInt(supervisorDescriptor) {
            supervisorStickyFlags |= event.fflags
            return true
        }
        if let controllerDescriptor,
           event.ident == UInt(controllerDescriptor) {
            controllerStickyFlags |= event.fflags
            return true
        }
        throw PrimeR19ControllerSupervisorFailure.rejected
    }

    /// Intended for pre-child checkpoints, when this watcher is the sole
    /// consumer. Once child filters exist, route each event through `consume`.
    func drainNonblocking() throws {
        while true {
            var events = [DarwinKevent](repeating: DarwinKevent(), count: 8)
            var timeout = timespec(tv_sec: 0, tv_nsec: 0)
            errno = 0
            let returned = events.withUnsafeMutableBufferPointer {
                kevent(queue, nil, 0, $0.baseAddress, Int32($0.count), &timeout)
            }
            if returned < 0, errno == EINTR { continue }
            guard returned >= 0 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            if returned == 0 { return }
            for event in events.prefix(Int(returned)) {
                guard try consume(event) else {
                    throw PrimeR19ControllerSupervisorFailure.rejected
                }
            }
        }
    }
}

/// Descriptor-rooted, append-only publication for the three CRS0.1 records.
/// A failed publication deliberately leaves its root and any leaf in place.
private final class PrimeR19Journal {
    private static let rootName =
        "r19-native-leaf-controller-runtime-supervisor-22015509-d577abc8"
    private static let rootPath = "/private/tmp/\(rootName)"
    private static let leafNames = [
        "00-intent.json", "01-start.json", "02-terminal.json",
    ]
    private static let maximumFrameBytes = 65_536
    private static let hashRule =
        "SHA256_COMPACT_RECURSIVE_LEXICOGRAPHIC_KEYS_UTF8_NO_TRAILING_LF_DIGEST_FIELD_EXCLUDED"

    private let parent: Int32
    let root: Int32
    private let rootIdentity: (device: dev_t, inode: ino_t)
    private var nextOrdinal: UInt32 = 0
    private var poisoned = false
    private var frames: [Data] = []
    private var leafDescriptors: [Int32] = []

    init(parentDescriptor: Int32) throws {
        guard geteuid() > 0 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        var parentMetadata = stat()
        let parentDescriptorFlags = fcntl(parentDescriptor, F_GETFD)
        let parentStatusFlags = fcntl(parentDescriptor, F_GETFL)
        guard parentDescriptor >= 3,
              parentDescriptorFlags >= 0,
              parentDescriptorFlags & FD_CLOEXEC != 0,
              parentStatusFlags >= 0,
              parentStatusFlags & O_ACCMODE == O_RDONLY,
              fstat(parentDescriptor, &parentMetadata) == 0,
              parentMetadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              UInt32(bitPattern: parentMetadata.st_dev) == 16_777_231,
              UInt64(parentMetadata.st_ino) == 774_813,
              parentMetadata.st_uid == 0,
              parentMetadata.st_gid == 0,
              parentMetadata.st_mode & mode_t(0o7777) == mode_t(0o1777),
              parentMetadata.st_flags == 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        var acceptedRoot: Int32 = -1
        do {
            guard Self.rootName.withCString({
                mkdirat(parentDescriptor, $0, mode_t(0o700))
            }) == 0 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            acceptedRoot = Self.rootName.withCString {
                Darwin.openat(
                    parentDescriptor,
                    $0,
                    O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
                )
            }
            guard acceptedRoot >= 3 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            let rootDescriptorFlags = fcntl(acceptedRoot, F_GETFD)
            let rootStatusFlags = fcntl(acceptedRoot, F_GETFL)
            var held = stat()
            var named = stat()
            guard rootDescriptorFlags >= 0,
                  rootDescriptorFlags & FD_CLOEXEC != 0,
                  rootStatusFlags >= 0,
                  rootStatusFlags & O_ACCMODE == O_RDONLY,
                  fstat(acceptedRoot, &held) == 0,
                  Self.rootName.withCString({
                      fstatat(
                          parentDescriptor,
                          $0,
                          &named,
                          AT_SYMLINK_NOFOLLOW
                      )
                  }) == 0,
                  Self.validRoot(held), Self.validRoot(named),
                  held.st_dev == named.st_dev, held.st_ino == named.st_ino,
                  held.st_dev == parentMetadata.st_dev,
                  try Self.inventory(acceptedRoot) == [],
                  Self.synchronize(acceptedRoot),
                  Self.synchronize(parentDescriptor)
            else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            parent = parentDescriptor
            root = acceptedRoot
            rootIdentity = (held.st_dev, held.st_ino)
        } catch {
            if acceptedRoot >= 0 { close(acceptedRoot) }
            throw error
        }
    }

    deinit {
        for descriptor in leafDescriptors.reversed() { close(descriptor) }
        close(root)
    }

    func canonicalRootIdentity() throws -> [String: Any] {
        var value = stat()
        guard fstat(root, &value) == 0,
              try validHeldAndNamedRoot()
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return [
            "device": UInt64(UInt32(bitPattern: value.st_dev)),
            "flags": UInt64(value.st_flags), "gid": UInt64(value.st_gid),
            "inode": UInt64(value.st_ino), "mode": "0700",
            "nlink": UInt64(value.st_nlink), "path": Self.rootPath,
            "uid": UInt64(value.st_uid),
        ]
    }

    func publishIntent(
        deadline: PrimeR19Deadline,
        readiness: PrimeR19AcceptedReadiness,
        supervisorProcess: PrimeR19JoinedProcess
    ) throws -> Data {
        try begin(ordinal: 0)
        let payload = PrimeR19JournalRecords.intent(
            deadline: deadline.absoluteNanoseconds,
            root: try canonicalRootIdentity(),
            readiness: readiness,
            supervisorProcess: supervisorProcess
        )
        return try finish(
            ordinal: 0,
            payload: payload,
            schema: PrimeR19JournalRecords.intentSchema,
            status: PrimeR19JournalRecords.intentStatus
        )
    }

    func publishStart(
        child: PrimeR19JoinedProcess,
        mapped: PrimeR19MappedImageInspection,
        cwd: PrimeR19CWDInspection,
        deadline: PrimeR19Deadline,
        watcher: PrimeR19StickyExecutableVnodeWatcher
    ) throws -> Data {
        try begin(ordinal: 1)
        guard frames.count == 1 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let payload = PrimeR19JournalRecords.start(
            child: child,
            mapped: mapped,
            cwd: cwd,
            intentFrame: frames[0],
            watcher: watcher
        )
        return try finish(
            ordinal: 1,
            payload: payload,
            schema: PrimeR19JournalRecords.startSchema,
            status: PrimeR19JournalRecords.startStatus,
            unexpiredDeadline: deadline
        )
    }

    func publishTerminal(
        cont: PrimeR19ContObservation,
        pid: pid_t,
        rawWaitStatus: Int32,
        standardOutput: PrimeR19StreamCapture,
        standardError: PrimeR19StreamCapture,
        readiness: PrimeR19AcceptedReadiness,
        watcher: PrimeR19StickyExecutableVnodeWatcher
    ) throws -> Data {
        try begin(ordinal: 2)
        guard frames.count == 2 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let payload = PrimeR19JournalRecords.terminal(
            cont: cont,
            pid: pid,
            rawWaitStatus: rawWaitStatus,
            standardOutput: standardOutput,
            standardError: standardError,
            readiness: readiness,
            startFrame: frames[1],
            watcher: watcher
        )
        return try finish(
            ordinal: 2,
            payload: payload,
            schema: PrimeR19JournalRecords.terminalSchema,
            status: PrimeR19JournalRecords.terminalStatus
        )
    }

    private func begin(ordinal: UInt32) throws {
        guard !poisoned,
              ordinal == nextOrdinal,
              ordinal < 3,
              frames.count == Int(ordinal),
              leafDescriptors.count == Int(ordinal)
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        poisoned = true
        guard try revalidatePublishedPrefix(),
              try Self.inventory(root) ==
                Array(Self.leafNames.prefix(Int(ordinal)))
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    /// Returns the exact full canonical frame, including its sole trailing LF.
    private func finish(
        ordinal: UInt32,
        payload: [String: Any],
        schema: String,
        status: String,
        unexpiredDeadline: PrimeR19Deadline? = nil
    ) throws -> Data {
        guard poisoned,
              ordinal == nextOrdinal,
              frames.count == Int(ordinal),
              leafDescriptors.count == Int(ordinal)
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let payloadBytes = try Self.canonical(payload)
        let outer: [String: Any] = [
            "payload": payload,
            "payload_hash_rule": Self.hashRule,
            "payload_sha256": PrimeR19CanonicalJSON.sha256Hex(payloadBytes),
            "schema": schema, "status": status,
        ]
        var frame = try Self.canonical(outer)
        frame.append(0x0a)
        guard frame.count <= Self.maximumFrameBytes else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        if let unexpiredDeadline, unexpiredDeadline.expired {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }

        let descriptor =
            prime_driver_v2_r19_controller_supervisor_create_poisoned_journal_leaf(
                root,
                ordinal
            )
        guard descriptor >= 3 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        var descriptorRetained = false
        defer {
            if !descriptorRetained { close(descriptor) }
        }
        var initial = stat()
        var initialNamed = stat()
        let descriptorFlags = fcntl(descriptor, F_GETFD)
        let statusFlags = fcntl(descriptor, F_GETFL)
        guard fstat(descriptor, &initial) == 0,
              Self.leafNames[Int(ordinal)].withCString({
                  fstatat(root, $0, &initialNamed, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              descriptorFlags >= 0, descriptorFlags & FD_CLOEXEC != 0,
              statusFlags >= 0, statusFlags & O_ACCMODE == O_RDWR,
              initial.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              initial.st_mode & 0o7777 == 0, initial.st_nlink == 1,
              initial.st_uid == geteuid(), initial.st_gid == 0,
              initial.st_flags == 0, initial.st_size == 0,
              initial.st_dev == rootIdentity.device,
              initialNamed.st_dev == initial.st_dev,
              initialNamed.st_ino == initial.st_ino,
              initialNamed.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              initialNamed.st_mode & mode_t(0o7777) == 0,
              initialNamed.st_nlink == 1,
              initialNamed.st_uid == geteuid(),
              initialNamed.st_gid == 0,
              initialNamed.st_flags == 0,
              initialNamed.st_size == 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        try Self.writeAll(frame, to: descriptor)
        let frameSHA256 = PrimeR19CanonicalJSON.sha256Hex(frame)
        let readback = try Self.readAll(descriptor)
        guard readback == frame,
              PrimeR19CanonicalJSON.sha256Hex(readback) == frameSHA256,
              Self.synchronize(descriptor),
              fchmod(descriptor, 0o400) == 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        var final = stat()
        var named = stat()
        guard fstat(descriptor, &final) == 0,
              Self.leafNames[Int(ordinal)].withCString({
                  fstatat(root, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              final.st_dev == initial.st_dev, final.st_ino == initial.st_ino,
              named.st_dev == initial.st_dev, named.st_ino == initial.st_ino,
              final.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              final.st_mode & 0o7777 == 0o400, final.st_nlink == 1,
              named.st_mode & 0o7777 == 0o400, named.st_nlink == 1,
              final.st_uid == geteuid(), final.st_gid == 0,
              named.st_uid == geteuid(), named.st_gid == 0,
              final.st_flags == 0, final.st_size == off_t(frame.count),
              named.st_flags == 0, named.st_size == off_t(frame.count),
              try Self.readAll(descriptor) == frame,
              try validHeldAndNamedRoot(),
              try Self.inventory(root) == Array(Self.leafNames.prefix(Int(ordinal) + 1)),
              Self.synchronize(descriptor), Self.synchronize(root)
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        nextOrdinal += 1
        frames.append(frame)
        leafDescriptors.append(descriptor)
        descriptorRetained = true
        poisoned = false
        return frame
    }

    private func revalidatePublishedPrefix() throws -> Bool {
        guard frames.count == leafDescriptors.count,
              frames.count == Int(nextOrdinal),
              try validHeldAndNamedRoot()
        else {
            return false
        }
        for index in frames.indices {
            let descriptor = leafDescriptors[index]
            let descriptorFlags = fcntl(descriptor, F_GETFD)
            let statusFlags = fcntl(descriptor, F_GETFL)
            var held = stat()
            var named = stat()
            guard descriptor >= 3,
                  descriptorFlags >= 0,
                  descriptorFlags & FD_CLOEXEC != 0,
                  statusFlags >= 0,
                  statusFlags & O_ACCMODE == O_RDWR,
                  fstat(descriptor, &held) == 0,
                  Self.leafNames[index].withCString({
                      fstatat(root, $0, &named, AT_SYMLINK_NOFOLLOW)
                  }) == 0,
                  held.st_dev == rootIdentity.device,
                  held.st_dev == named.st_dev,
                  held.st_ino == named.st_ino,
                  held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  held.st_mode & mode_t(0o7777) == mode_t(0o400),
                  named.st_mode & mode_t(0o7777) == mode_t(0o400),
                  held.st_nlink == 1,
                  named.st_nlink == 1,
                  held.st_uid == geteuid(),
                  named.st_uid == geteuid(),
                  held.st_gid == 0,
                  named.st_gid == 0,
                  held.st_flags == 0,
                  named.st_flags == 0,
                  held.st_size == off_t(frames[index].count),
                  named.st_size == off_t(frames[index].count),
                  try Self.readAll(descriptor) == frames[index]
            else {
                return false
            }
        }
        return true
    }

    private func validHeldAndNamedRoot() throws -> Bool {
        var held = stat()
        var named = stat()
        return fstat(root, &held) == 0
            && Self.rootName.withCString({
                fstatat(parent, $0, &named, AT_SYMLINK_NOFOLLOW)
            }) == 0
            && Self.validRoot(held) && Self.validRoot(named)
            && held.st_dev == rootIdentity.device && held.st_ino == rootIdentity.inode
            && named.st_dev == rootIdentity.device && named.st_ino == rootIdentity.inode
    }

    private static func validRoot(_ value: stat) -> Bool {
        value.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR)
            && value.st_mode & 0o7777 == 0o700
            && value.st_uid == geteuid() && value.st_gid == 0
            && value.st_flags == 0
    }

    private static func canonical(_ object: Any) throws -> Data {
        guard JSONSerialization.isValidJSONObject(object) else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
    }

    private static func synchronize(_ descriptor: Int32) -> Bool {
        fsync(descriptor) == 0 && fcntl(descriptor, F_FULLFSYNC) == 0
    }

    private static func writeAll(_ data: Data, to descriptor: Int32) throws {
        var offset = 0
        while offset < data.count {
            let written = data.withUnsafeBytes {
                pwrite(descriptor, $0.baseAddress!.advanced(by: offset),
                       data.count - offset, off_t(offset))
            }
            if written < 0, errno == EINTR { continue }
            guard written > 0 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            offset += written
        }
    }

    private static func readAll(_ descriptor: Int32) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: maximumFrameBytes + 1)
        var total = 0
        while total < bytes.count {
            let remaining = bytes.count - total
            let count = bytes.withUnsafeMutableBytes {
                pread(descriptor, $0.baseAddress!.advanced(by: total),
                      remaining, off_t(total))
            }
            if count < 0, errno == EINTR { continue }
            guard count >= 0 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            if count == 0 { return Data(bytes.prefix(total)) }
            total += count
        }
        throw PrimeR19ControllerSupervisorFailure.rejected
    }

    private static func inventory(_ descriptor: Int32) throws -> [String] {
        let copied = openat(
            descriptor,
            ".",
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard copied >= 3, let directory = fdopendir(copied) else {
            if copied >= 0 { close(copied) }
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        defer { closedir(directory) }
        var names: [String] = []
        errno = 0
        while let entry = readdir(directory) {
            let name = withUnsafePointer(to: &entry.pointee.d_name) {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
            }
            if name != "." && name != ".." { names.append(name) }
            guard names.count <= leafNames.count else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            errno = 0
        }
        guard errno == 0 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return names.sorted()
    }
}

/// Exact CRS0.1 record factories. No dictionary crosses this boundary from
/// readiness input or from a caller-selectable execution surface.
private enum PrimeR19JournalRecords {
    static func intent(
        deadline: UInt64,
        root: [String: Any],
        readiness: PrimeR19AcceptedReadiness,
        supervisorProcess: PrimeR19JoinedProcess
    ) -> [String: Any] {
        [
            "absolute_pre_resume_deadline_uptime_nanoseconds": deadline,
            "authority_vector": "00000000",
            "controller_a_identity": controllerAIdentity,
            "invocation_id": "r19-native-leaf-controller-runtime-supervisor-22015509-d577abc8",
            "journal_root_identity": root,
            "request_bytes": UInt64(readiness.bytes.count),
            "request_complete_bytes_stored": false,
            "request_sha256": readiness.sha256,
            "runtime_umask": "0077",
            "supervisor_a_identity": supervisorAIdentity(
                readiness.frame.supervisorAExpectedIdentity
            ),
            "supervisor_process_identity": processIdentity(
                supervisorProcess,
                child: false
            ),
        ]
    }

    static func start(
        child: PrimeR19JoinedProcess,
        mapped: PrimeR19MappedImageInspection,
        cwd: PrimeR19CWDInspection,
        intentFrame: Data,
        watcher: PrimeR19StickyExecutableVnodeWatcher
    ) -> [String: Any] {
        [
            "authority_vector": "00000000",
            "child_event_registrations": ["EVFILT_PROC_NOTE_EXIT", "EVFILT_READ_STDOUT", "EVFILT_READ_STDERR"],
            "child_identity": processIdentity(child, child: true),
            "controller_mapped_join": [
                "device": UInt64(UInt32(bitPattern: mapped.device)),
                "executable_offset_zero": mapped.executableOffsetZero,
                "inode": UInt64(mapped.inode),
                "main_region_count": UInt64(mapped.mainRegionCount),
                "query_count": UInt64(mapped.queryCount),
            ],
            "cwd_join": [
                "device": UInt64(cwd.device),
                "inode": cwd.inode,
            ],
            "deadline_unexpired_before_publication": true,
            "intent_frame_bytes": UInt64(intentFrame.count),
            "intent_frame_sha256": PrimeR19CanonicalJSON.sha256Hex(intentFrame),
            "preexisting_vnode_registrations": ["EVFILT_VNODE_SUPERVISOR_A", "EVFILT_VNODE_CONTROLLER_A"],
            "still_suspended": true,
            "vnode_state": vnodeState(watcher),
        ]
    }

    static func terminal(
        cont: PrimeR19ContObservation,
        pid: pid_t,
        rawWaitStatus: Int32,
        standardOutput: PrimeR19StreamCapture,
        standardError: PrimeR19StreamCapture,
        readiness: PrimeR19AcceptedReadiness,
        startFrame: Data,
        watcher: PrimeR19StickyExecutableVnodeWatcher
    ) -> [String: Any] {
        let output = Data(standardOutput.bytes)
        let error = Data(standardError.bytes)
        return [
            "authority_vector": "00000000",
            "cont": [
                "entered_at_uptime_nanoseconds": cont.enteredAtNanoseconds,
                "entered_calls": UInt64(1),
                "return_value": cont.returnValue,
                "returned_at_uptime_nanoseconds": cont.returnedAtNanoseconds,
            ],
            "controller_exit": [
                "exit_status": UInt64((rawWaitStatus >> 8) & 0xff),
                "exited": true,
                "note_exit_observed": true,
                "pid": Int64(pid),
                "raw_wait_status": Int64(rawWaitStatus),
                "waitpid_calls": UInt64(1),
            ],
            "drains": [
                "stderr_bytes": UInt64(error.count),
                "stderr_eof": standardError.eof,
                "stderr_hex": hex(error),
                "stderr_overflow": standardError.overflow,
                "stderr_sha256": PrimeR19CanonicalJSON.sha256Hex(error),
                "stdout_eof": standardOutput.eof,
                "stdout_overflow": standardOutput.overflow,
            ],
            "final_revalidation": [
                "controller_a_identity_equal": true,
                "controller_a_raw_sha256": PrimeR19ExecutableExpectation.controllerA.rawSHA256,
                "supervisor_a_identity_equal": true,
                "supervisor_a_raw_sha256": readiness.frame.supervisorAExpectedIdentity.rawSHA256,
            ],
            "gate_e_clearance": UInt64(0),
            "gate_e_mechanics_outcome": "ABSTAIN",
            "gate_e_scientific_outcome": "ABSTAIN",
            "group_conservation": [
                "joined_nonleader_count_after_note_exit": UInt64(0),
                "leader_only_before_reap": true,
                "post_reap_esrch_1": "ESRCH",
                "post_reap_esrch_2": "ESRCH",
                "query_saturated": false,
            ],
            "local_candidate_only": true,
            "opaque_controller_stdout": [
                "bytes": UInt64(output.count),
                "hex": hex(output),
                "sha256": PrimeR19CanonicalJSON.sha256Hex(output),
                "trailing_lf": output.last == 0x0a,
            ],
            "start_frame_bytes": UInt64(startFrame.count),
            "start_frame_sha256": PrimeR19CanonicalJSON.sha256Hex(startFrame),
            "vnode_state": vnodeState(watcher),
        ]
    }

    private static func processIdentity(
        _ joined: PrimeR19JoinedProcess,
        child: Bool
    ) -> [String: Any] {
        var result: [String: Any] = [
            "idversion": UInt64(joined.unique.idVersion),
            "pgid": Int64(joined.processGroup),
            "pid": UInt64(joined.short.pid),
            "sid": Int64(joined.session),
            "unique_id": joined.unique.uniqueID,
        ]
        if child {
            result["direct_parent"] = true
            result["parent_pid"] = UInt64(joined.short.parentPID)
            result["status"] = Int64(joined.short.status)
        }
        return result
    }

    private static func vnodeState(
        _ watcher: PrimeR19StickyExecutableVnodeWatcher
    ) -> [String: Any] {
        let state = watcher.stickyState
        return [
            "controller_a_event_flags": UInt64(state.controller),
            "sticky_poison": !watcher.isZero,
            "supervisor_a_event_flags": UInt64(state.supervisor),
        ]
    }

    private static func supervisorAIdentity(
        _ identity: PrimeR19SupervisorExpectedIdentity
    ) -> [String: Any] {
        [
            "architecture": identity.architecture,
            "code_directory_full_sha256": identity.codeDirectoryFullSHA256,
            "device": identity.device,
            "entryoff": identity.entryoff,
            "filetype": identity.filetype,
            "flags": UInt64(identity.flags),
            "gid": UInt64(identity.gid),
            "inode": identity.inode,
            "lc_code_signature_offset": identity.lcCodeSignatureOffset,
            "lc_code_signature_size": identity.lcCodeSignatureSize,
            "load_command_count": UInt64(identity.loadCommandCount),
            "load_commands_size_bytes": UInt64(identity.loadCommandsSizeBytes),
            "mode": identity.mode,
            "nlink": identity.nlink,
            "path": identity.path,
            "raw_sha256": identity.rawSHA256,
            "size_bytes": identity.sizeBytes,
            "uid": UInt64(identity.uid),
            "uuid": identity.uuid,
        ]
    }

    private static var controllerAIdentity: [String: Any] { [
        "architecture": "arm64",
        "code_directory": [
            "code_slots": UInt64(45),
            "executable_segment_flags": "0x1",
            "executable_segment_limit": UInt64(65_480),
            "flags": "0x20002",
            "full_sha256": "feaced540dbc2d8c9e566b733958f2bcf70c5164ba220680c4775e7055b71972",
            "identifier": "PrimeDriverV2R19NativeLeafAdmissionController",
            "page_bytes": UInt64(4_096),
            "signing": "AD_HOC_LINKER_SIGNED",
            "size_bytes": UInt64(1_574),
            "special_slots": UInt64(0),
            "version_hex": "0x20400",
        ],
        "device": UInt64(16_777_231),
        "entryoff": UInt64(22_644),
        "filetype": "MH_EXECUTE",
        "flags": UInt64(0),
        "gid": UInt64(0),
        "header_flags": ["NOUNDEFS", "DYLDLINK", "TWOLEVEL", "PIE"],
        "inode": UInt64(17_483_372),
        "lc_build_version": [
            "ld": "1267.0", "minimum_macos": "14.0", "sdk": "26.5",
        ],
        "lc_code_signature": [
            "offset": UInt64(183_456), "size": UInt64(1_600),
        ],
        "load_command_count": UInt64(30),
        "load_commands_size_bytes": UInt64(3_536),
        "mode": "0700",
        "nlink": UInt64(1),
        "path": "/private/tmp/prime-driver-v2-r19-native-leaf-admission-controller-repair1-build-a-cfa948e2/PrimeDriverV2R19NativeLeafAdmissionController",
        "raw_sha256": "01a8e82d49b5c6c696aceb5ec07172836819d39e2cf1f8d9cc792ff7dd8b9016",
        "role": "SOLE_COMPILED_CHILD_IDENTITY_NO_CALLER_SELECTION",
        "size_bytes": UInt64(185_056),
        "strict_codesign_verified_build_time": true,
        "uid": UInt64(501),
        "uuid": "A9FD612B-DB03-3C61-B03E-4435ED3524FF",
    ] }

    private static func hex(_ data: Data) -> String {
        let alphabet = Array("0123456789abcdef".utf8)
        var result = [UInt8]()
        result.reserveCapacity(data.count * 2)
        for byte in data {
            result.append(alphabet[Int(byte >> 4)])
            result.append(alphabet[Int(byte & 0x0f)])
        }
        return String(decoding: result, as: UTF8.self)
    }

    static let intentSchema = "prime_driver_v2_r19_native_leaf_controller_runtime_supervisor_intent_v1"
    static let intentStatus = "INTENT_DURABLE_PRESPAWN"
    static let startSchema = "prime_driver_v2_r19_native_leaf_controller_runtime_supervisor_start_v1"
    static let startStatus = "START_DURABLE_SUSPENDED_JOINED_NOT_RESUMED"
    static let terminalSchema = "prime_driver_v2_r19_native_leaf_controller_runtime_supervisor_terminal_v1"
    static let terminalStatus = "PASS_CONTROLLER_CONTAINED_OPAQUE_RUNTIME_CANDIDATE"
}

private enum PrimeR19ChildDomain: Equatable {
    case spawnedUncertified
    case preCONTStoppedCertified
    case contEntered
    case noteExitAndEOF
    case leaderOnlyProved
    case reapedUnconserved
    case conserved
}

private final class PrimeR19ChildOwner {
    private typealias DarwinKevent = Darwin.kevent
    private static let groupCapacity = 65_536

    private let pid: pid_t
    private let authorities: PrimeR19HeldAuthorities
    private let readiness: PrimeR19AcceptedReadiness
    private let journal: PrimeR19Journal
    private let watcher: PrimeR19StickyExecutableVnodeWatcher
    private let standardOutput: PrimeR19Pipe
    private let standardError: PrimeR19Pipe
    private let queue: Int32
    private let deadline: PrimeR19Deadline
    private let spawnReturnExpired: Bool

    private var outputCapture = PrimeR19StreamCapture()
    private var errorCapture = PrimeR19StreamCapture()
    private var serviceOutputFirst = true
    private var eventsRegistered = false
    private var terminalObserved = false
    private var groupBaseline: PrimeR19JoinedProcess?
    private var contEntryCommitted = false
    private var contObservation: PrimeR19ContObservation?
    private var positiveKillEntered = false
    private var waitpidCalls: UInt64 = 0
    private var rawWaitStatus: Int32?
    private var querySaturated = false
    private var joinedNonleaderCountAfterNoteExit = 0
    private var evidenceVeto = false
    private var domain = PrimeR19ChildDomain.spawnedUncertified

    init(
        pid: pid_t,
        authorities: PrimeR19HeldAuthorities,
        readiness: PrimeR19AcceptedReadiness,
        journal: PrimeR19Journal,
        watcher: PrimeR19StickyExecutableVnodeWatcher,
        standardOutput: PrimeR19Pipe,
        standardError: PrimeR19Pipe,
        queue: Int32,
        deadline: PrimeR19Deadline,
        spawnReturnExpired: Bool
    ) {
        self.pid = pid
        self.authorities = authorities
        self.readiness = readiness
        self.journal = journal
        self.watcher = watcher
        self.standardOutput = standardOutput
        self.standardError = standardError
        self.queue = queue
        self.deadline = deadline
        self.spawnReturnExpired = spawnReturnExpired
    }

    func run() throws -> Data {
        do {
            try registerEvents()
            let before = try requireInitialStoppedJoin()
            groupBaseline = before
            domain = .preCONTStoppedCertified
            let cwd = try inspectSuspendedCWD()
            let mapped = try PrimeR19MappedImageInspector.inspect(
                pid: pid,
                heldExecutable: authorities.controllerDescriptor,
                expectedPath: authorities.controllerExpectation.path
            )
            guard let after = try PrimeR19ProcessProof.join(pid) else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            try PrimeR19ProcessProof.requirePrivateStoppedChild(after, pid: pid)
            try PrimeR19ProcessProof.requireSamePrivateChild(
                after,
                baseline: before,
                pid: pid
            )
            groupBaseline = after
            try authorities.revalidateBeforeResume()
            try serviceTurn(blocking: false)
            guard !spawnReturnExpired,
                  !deadline.expired,
                  !terminalObserved,
                  watcher.isFullyArmed,
                  watcher.isZero
            else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }

            _ = try journal.publishStart(
                child: after,
                mapped: mapped,
                cwd: cwd,
                deadline: deadline,
                watcher: watcher
            )

            guard !deadline.expired,
                  let postStart = try PrimeR19ProcessProof.join(pid)
            else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            try PrimeR19ProcessProof.requirePrivateStoppedChild(
                postStart,
                pid: pid
            )
            try PrimeR19ProcessProof.requireSamePrivateChild(
                postStart,
                baseline: after,
                pid: pid
            )
            groupBaseline = postStart
            try authorities.revalidateBeforeResume()
            try serviceTurn(blocking: false)
            guard !deadline.expired,
                  !terminalObserved,
                  watcher.isZero
            else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }

            let enteredAt = DispatchTime.now().uptimeNanoseconds
            domain = .contEntered
            contEntryCommitted = true
            let returnValue = Darwin.kill(pid, SIGCONT)
            let returnedAt = DispatchTime.now().uptimeNanoseconds
            contObservation = PrimeR19ContObservation(
                enteredAtNanoseconds: enteredAt,
                returnValue: returnValue,
                returnedAtNanoseconds: returnedAt
            )
            guard returnValue == 0, returnedAt >= enteredAt else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }

            try awaitTerminalAndEOF()
            try conserveAndReap()
            try authorities.revalidateAfterReap()
            try serviceTurn(blocking: false)

            guard domain == .conserved,
                  !evidenceVeto,
                  watcher.isZero,
                  let cont = contObservation,
                  cont.returnValue == 0,
                  cont.returnedAtNanoseconds >= cont.enteredAtNanoseconds,
                  waitpidCalls == 1,
                  let status = rawWaitStatus,
                  status & 0x7f == 0,
                  (status >> 8) & 0xff == 0,
                  terminalObserved,
                  outputCapture.eof,
                  errorCapture.eof,
                  !outputCapture.overflow,
                  !errorCapture.overflow,
                  !outputCapture.bytes.isEmpty,
                  outputCapture.bytes.count <= PrimeR19StreamCapture.cap,
                  outputCapture.bytes.last == 0x0a,
                  errorCapture.bytes.isEmpty,
                  !querySaturated,
                  joinedNonleaderCountAfterNoteExit == 0
            else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }

            _ = try journal.publishTerminal(
                cont: cont,
                pid: pid,
                rawWaitStatus: status,
                standardOutput: outputCapture,
                standardError: errorCapture,
                readiness: readiness,
                watcher: watcher
            )
            return Data(outputCapture.bytes)
        } catch {
            evidenceVeto = true
            containFailure()
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    private func requireInitialStoppedJoin() throws -> PrimeR19JoinedProcess {
        guard let joined = try PrimeR19ProcessProof.join(pid) else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        try PrimeR19ProcessProof.requirePrivateStoppedChild(joined, pid: pid)
        return joined
    }

    private func inspectSuspendedCWD() throws -> PrimeR19CWDInspection {
        guard MemoryLayout<proc_vnodepathinfo>.size == 2_352 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let held = try authorities.heldRootIdentity()
        var raw = proc_vnodepathinfo()
        errno = 0
        let returned = withUnsafeMutablePointer(to: &raw) {
            proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, $0, 2_352)
        }
        let observed = raw.pvi_cdir.vip_vi.vi_stat
        guard returned == 2_352,
              observed.vst_dev == held.device,
              observed.vst_ino == held.inode,
              observed.vst_mode & UInt16(S_IFMT) == UInt16(S_IFDIR)
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return held
    }

    private func registerEvents() throws {
        var changes = [
            DarwinKevent(
                ident: UInt(pid),
                filter: Int16(EVFILT_PROC),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE)
                    | UInt16(EV_CLEAR) | UInt16(EV_RECEIPT),
                fflags: UInt32(NOTE_EXIT),
                data: 0,
                udata: nil
            ),
            DarwinKevent(
                ident: UInt(standardOutput.readDescriptor),
                filter: Int16(EVFILT_READ),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE)
                    | UInt16(EV_CLEAR) | UInt16(EV_RECEIPT),
                fflags: 0,
                data: 0,
                udata: nil
            ),
            DarwinKevent(
                ident: UInt(standardError.readDescriptor),
                filter: Int16(EVFILT_READ),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE)
                    | UInt16(EV_CLEAR) | UInt16(EV_RECEIPT),
                fflags: 0,
                data: 0,
                udata: nil
            ),
        ]
        var receipts = [DarwinKevent](repeating: DarwinKevent(), count: 3)
        errno = 0
        let returned = changes.withUnsafeMutableBufferPointer { changes in
            receipts.withUnsafeMutableBufferPointer { receipts in
                kevent(
                    queue,
                    changes.baseAddress,
                    Int32(changes.count),
                    receipts.baseAddress,
                    Int32(receipts.count),
                    nil
                )
            }
        }
        guard returned == 3 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        for index in changes.indices {
            guard receipts[index].ident == changes[index].ident,
                  receipts[index].filter == changes[index].filter,
                  receipts[index].flags & UInt16(EV_ERROR) != 0,
                  receipts[index].data == 0
            else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
        }
        eventsRegistered = true
    }

    private func serviceTurn(blocking: Bool) throws {
        var drainFailed = false
        if serviceOutputFirst {
            do {
                try outputCapture.drain(standardOutput.readDescriptor)
            } catch {
                drainFailed = true
            }
            do {
                try errorCapture.drain(standardError.readDescriptor)
            } catch {
                drainFailed = true
            }
        } else {
            do {
                try errorCapture.drain(standardError.readDescriptor)
            } catch {
                drainFailed = true
            }
            do {
                try outputCapture.drain(standardOutput.readDescriptor)
            } catch {
                drainFailed = true
            }
        }
        serviceOutputFirst.toggle()

        var events = [DarwinKevent](repeating: DarwinKevent(), count: 16)
        var timeout = blocking
            ? timespec(tv_sec: 1, tv_nsec: 0)
            : timespec(tv_sec: 0, tv_nsec: 0)
        errno = 0
        let returned = events.withUnsafeMutableBufferPointer {
            kevent(queue, nil, 0, $0.baseAddress, Int32($0.count), &timeout)
        }
        if returned < 0, errno == EINTR {
            if drainFailed {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            return
        }
        guard returned >= 0 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        for event in events.prefix(Int(returned)) {
            guard event.flags & UInt16(EV_ERROR) == 0 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
            if try watcher.consume(event) {
                evidenceVeto = true
                continue
            }
            if event.filter == Int16(EVFILT_PROC),
               event.ident == UInt(pid),
               event.fflags & UInt32(NOTE_EXIT) != 0,
               event.fflags & ~UInt32(NOTE_EXIT) == 0 {
                terminalObserved = true
                continue
            }
            if event.filter == Int16(EVFILT_READ),
               event.ident == UInt(standardOutput.readDescriptor)
                || event.ident == UInt(standardError.readDescriptor) {
                continue
            }
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        if drainFailed {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
    }

    private func awaitTerminalAndEOF() throws {
        while !terminalObserved || !outputCapture.eof || !errorCapture.eof {
            try serviceTurn(blocking: true)
        }
        domain = .noteExitAndEOF
    }

    private func leaderOnlyCensus() throws -> Bool {
        guard terminalObserved,
              outputCapture.eof,
              errorCapture.eof,
              let baseline = groupBaseline,
              let leaderBefore = try PrimeR19ProcessProof.join(pid)
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        try PrimeR19ProcessProof.requireSamePrivateChild(
            leaderBefore,
            baseline: baseline,
            pid: pid
        )

        var identifiers = [pid_t](repeating: 0, count: Self.groupCapacity)
        errno = 0
        let returned = identifiers.withUnsafeMutableBytes {
            proc_listpids(
                UInt32(PROC_PGRP_ONLY),
                UInt32(pid),
                $0.baseAddress,
                Int32($0.count)
            )
        }
        let capacityBytes = identifiers.count * MemoryLayout<pid_t>.stride
        if returned >= Int32(capacityBytes) { querySaturated = true }
        guard returned > 0,
              Int(returned) < capacityBytes,
              Int(returned) % MemoryLayout<pid_t>.stride == 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let count = Int(returned) / MemoryLayout<pid_t>.stride
        let listed = Array(identifiers.prefix(count))
        guard listed.allSatisfy({ $0 >= 0 }) else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let observed = listed.filter { $0 > 0 }
        guard !observed.isEmpty,
              Set(observed).count == observed.count,
              observed.filter({ $0 == pid }).count == 1
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }

        let nonleaders = observed.filter { $0 != pid }
        for member in nonleaders {
            guard let joined = try PrimeR19ProcessProof.join(member),
                  joined.processGroup == pid,
                  joined.session == baseline.session
            else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
        }
        guard let leaderAfter = try PrimeR19ProcessProof.join(pid) else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        try PrimeR19ProcessProof.requireSamePrivateChild(
            leaderAfter,
            baseline: baseline,
            pid: pid
        )
        guard leaderAfter.sameIdentity(as: leaderBefore) else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        joinedNonleaderCountAfterNoteExit = nonleaders.count
        return nonleaders.isEmpty
    }

    private func conserveAndReap() throws {
        while true {
            do {
                if try leaderOnlyCensus() { break }
            } catch {
                evidenceVeto = true
            }
            do {
                try serviceTurn(blocking: true)
            } catch {
                evidenceVeto = true
            }
        }
        domain = .leaderOnlyProved

        var status: Int32 = 0
        waitpidCalls += 1
        errno = 0
        let reaped = Darwin.waitpid(pid, &status, 0)
        guard waitpidCalls == 1, reaped == pid else {
            retainForever()
        }
        rawWaitStatus = status
        domain = .reapedUnconserved

        var absence = [Bool]()
        absence.reserveCapacity(2)
        for _ in 0..<2 {
            errno = 0
            let result = Darwin.kill(-pid, 0)
            let observedErrno = errno
            absence.append(result == -1 && observedErrno == ESRCH)
        }
        guard absence == [true, true] else {
            retainForever()
        }
        domain = .conserved
    }

    private func containFailure() {
        if domain == .conserved { return }
        if domain == .reapedUnconserved { retainForever() }

        while !eventsRegistered {
            do {
                try registerEvents()
            } catch {
                evidenceVeto = true
            }
        }

        if !contEntryCommitted,
           !terminalObserved,
           !positiveKillEntered {
            while !terminalObserved && !positiveKillEntered {
                do {
                    try serviceTurn(blocking: false)
                    if terminalObserved { break }
                    guard let joined = try PrimeR19ProcessProof.join(pid) else {
                        try serviceTurn(blocking: true)
                        continue
                    }
                    try PrimeR19ProcessProof.requirePrivateStoppedChild(
                        joined,
                        pid: pid
                    )
                    if let baseline = groupBaseline {
                        try PrimeR19ProcessProof.requireSamePrivateChild(
                            joined,
                            baseline: baseline,
                            pid: pid
                        )
                    } else {
                        groupBaseline = joined
                    }
                    positiveKillEntered = true
                    _ = Darwin.kill(pid, SIGKILL)
                } catch {
                    evidenceVeto = true
                    try? serviceTurn(blocking: true)
                }
            }
        }

        while !terminalObserved || !outputCapture.eof || !errorCapture.eof {
            do {
                try serviceTurn(blocking: true)
            } catch {
                evidenceVeto = true
            }
        }
        domain = .noteExitAndEOF
        do {
            try conserveAndReap()
        } catch {
            evidenceVeto = true
            retainForever()
        }
    }

    private func retainForever() -> Never {
        while true {
            do {
                try serviceTurn(blocking: true)
            } catch {
                evidenceVeto = true
            }
        }
    }
}

private enum PrimeR19ControllerSupervisor {
    private typealias DarwinKevent = Darwin.kevent

    static func run() throws -> Data {
        let readiness = try requireIngress()
        _ = umask(mode_t(0o077))
        let queue = kqueue()
        guard queue >= 3 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        defer { _ = Darwin.close(queue) }
        let queueFlags = fcntl(queue, F_GETFD)
        guard queueFlags >= 0,
              fcntl(queue, F_SETFD, queueFlags | FD_CLOEXEC) == 0,
              fcntl(queue, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }

        let prepared = try PrimeR19HeldAuthorities.prepare(
            readiness: readiness,
            queue: queue
        )
        let authorities = prepared.authorities
        let watcher = prepared.watcher
        guard let supervisorProcess = try PrimeR19ProcessProof.join(getpid()),
              supervisorProcess.short.pid == UInt32(getpid()),
              supervisorProcess.processGroup > 0,
              supervisorProcess.session > 0,
              supervisorProcess.short.processGroup ==
                UInt32(supervisorProcess.processGroup),
              watcher.isFullyArmed,
              watcher.isZero
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }

        let deadline = try PrimeR19Deadline()
        guard !deadline.expired else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let standardOutput = try PrimeR19Pipe()
        let standardError: PrimeR19Pipe
        do {
            standardError = try PrimeR19Pipe()
        } catch {
            standardOutput.closeAll()
            throw error
        }
        let journal = try PrimeR19Journal(
            parentDescriptor: authorities.privateTmpDescriptor
        )
        _ = try journal.publishIntent(
            deadline: deadline,
            readiness: readiness,
            supervisorProcess: supervisorProcess
        )
        try authorities.revalidateBeforeResume()
        try watcher.drainNonblocking()
        guard watcher.isZero, !deadline.expired else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }

        let childPID = try spawn(
            authorities: authorities,
            standardOutput: standardOutput,
            standardError: standardError,
            deadline: deadline
        )
        let spawnReturnExpired = deadline.expired
        standardOutput.closeWriteEnd()
        standardError.closeWriteEnd()
        let owner = PrimeR19ChildOwner(
            pid: childPID,
            authorities: authorities,
            readiness: readiness,
            journal: journal,
            watcher: watcher,
            standardOutput: standardOutput,
            standardError: standardError,
            queue: queue,
            deadline: deadline,
            spawnReturnExpired: spawnReturnExpired
        )
        return try owner.run()
    }

    private static func requireIngress() throws -> PrimeR19AcceptedReadiness {
        guard CommandLine.argc == 1,
              let environment = primeR19ControllerSupervisorNSGetEnviron().pointee,
              environment.pointee == nil
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        var cwd = [CChar](repeating: 0, count: Int(PATH_MAX))
        let cwdResult = cwd.withUnsafeMutableBufferPointer {
            getcwd($0.baseAddress, $0.count)
        }
        guard cwdResult != nil,
              cwd[0] == CChar(UInt8(ascii: "/")),
              cwd[1] == 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        guard MemoryLayout<proc_fdinfo>.size == 8,
              MemoryLayout<proc_fdinfo>.stride == 8
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        var snapshot = [proc_fdinfo](repeating: proc_fdinfo(), count: 4)
        let returned = snapshot.withUnsafeMutableBufferPointer {
            proc_pidinfo(
                getpid(),
                PROC_PIDLISTFDS,
                0,
                $0.baseAddress,
                Int32($0.count * MemoryLayout<proc_fdinfo>.stride)
            )
        }
        guard returned == 24,
              snapshot.prefix(3).map(\.proc_fd).sorted() ==
                [STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO]
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        var input = stat()
        var output = stat()
        var error = stat()
        guard fstat(STDIN_FILENO, &input) == 0,
              fstat(STDOUT_FILENO, &output) == 0,
              fstat(STDERR_FILENO, &error) == 0,
              input.st_mode & mode_t(S_IFMT) == mode_t(S_IFIFO),
              output.st_mode & mode_t(S_IFMT) == mode_t(S_IFIFO),
              error.st_mode & mode_t(S_IFMT) == mode_t(S_IFIFO),
              output.st_dev != error.st_dev || output.st_ino != error.st_ino,
              isatty(STDIN_FILENO) == 0,
              isatty(STDOUT_FILENO) == 0,
              isatty(STDERR_FILENO) == 0,
              fcntl(STDIN_FILENO, F_GETFL) == O_RDONLY,
              fcntl(STDOUT_FILENO, F_GETFL) == O_WRONLY,
              fcntl(STDERR_FILENO, F_GETFL) == O_WRONLY,
              fpathconf(STDIN_FILENO, _PC_PIPE_BUF) == 512,
              fpathconf(STDOUT_FILENO, _PC_PIPE_BUF) == 512,
              fpathconf(STDERR_FILENO, _PC_PIPE_BUF) == 512
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return try PrimeR19ReadinessIngress.accept()
    }

    private static func spawn(
        authorities: PrimeR19HeldAuthorities,
        standardOutput: PrimeR19Pipe,
        standardError: PrimeR19Pipe,
        deadline: PrimeR19Deadline
    ) throws -> pid_t {
        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        guard posix_spawn_file_actions_init(&actions) == 0 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        defer { _ = posix_spawn_file_actions_destroy(&actions) }
        guard posix_spawnattr_init(&attributes) == 0 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        defer { _ = posix_spawnattr_destroy(&attributes) }
        let actionResults = [
            posix_spawn_file_actions_addinherit_np(
                &actions, authorities.rootDescriptor
            ),
            posix_spawn_file_actions_addfchdir_np(
                &actions, authorities.rootDescriptor
            ),
            posix_spawn_file_actions_addclose(
                &actions, authorities.rootDescriptor
            ),
            posix_spawn_file_actions_adddup2(
                &actions, authorities.nullDescriptor, STDIN_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, authorities.nullDescriptor
            ),
            posix_spawn_file_actions_addclose(
                &actions, standardOutput.readDescriptor
            ),
            posix_spawn_file_actions_adddup2(
                &actions, standardOutput.writeDescriptor, STDOUT_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, standardOutput.writeDescriptor
            ),
            posix_spawn_file_actions_addclose(
                &actions, standardError.readDescriptor
            ),
            posix_spawn_file_actions_adddup2(
                &actions, standardError.writeDescriptor, STDERR_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, standardError.writeDescriptor
            ),
        ]
        guard actionResults.allSatisfy({ $0 == 0 }) else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        var defaults = sigset_t()
        guard sigemptyset(&defaults) == 0 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        for signal in 1..<NSIG where signal != SIGKILL && signal != SIGSTOP {
            guard sigaddset(&defaults, signal) == 0 else {
                throw PrimeR19ControllerSupervisorFailure.rejected
            }
        }
        var mask = sigset_t()
        guard sigemptyset(&mask) == 0,
              posix_spawnattr_setsigdefault(&attributes, &defaults) == 0,
              posix_spawnattr_setsigmask(&attributes, &mask) == 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let flags = UInt16(POSIX_SPAWN_START_SUSPENDED)
            | UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
            | UInt16(POSIX_SPAWN_SETSID)
            | UInt16(POSIX_SPAWN_SETSIGDEF)
            | UInt16(POSIX_SPAWN_SETSIGMASK)
        guard flags == 0x448C,
              posix_spawnattr_setflags(
                  &attributes,
                  Int16(bitPattern: flags)
              ) == 0
        else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let controllerPath = authorities.controllerExpectation.path
        guard let argumentZero = strdup(controllerPath) else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        defer { free(argumentZero) }
        var arguments: [UnsafeMutablePointer<CChar>?] = [argumentZero, nil]
        var environment: [UnsafeMutablePointer<CChar>?] = [nil]
        var child: pid_t = 0
        guard !deadline.expired else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        let result = controllerPath.withCString { path in
            arguments.withUnsafeMutableBufferPointer { argumentBuffer in
                environment.withUnsafeMutableBufferPointer { environmentBuffer in
                    posix_spawn(
                        &child,
                        path,
                        &actions,
                        &attributes,
                        argumentBuffer.baseAddress,
                        environmentBuffer.baseAddress
                    )
                }
            }
        }
        guard result == 0, child > 0 else {
            throw PrimeR19ControllerSupervisorFailure.rejected
        }
        return child
    }
}

@main
private struct PrimeDriverV2R19NativeLeafControllerRuntimeSupervisor {
    static func main() {
        // Retired 2026-09-20: this historical R19 helper can retain a failed
        // process domain indefinitely. Reject before bootstrap intake or spawn.
        // Exit without output so a closed/full pipe cannot delay rejection.
        // Original Git blob: 18f6e775f11dd3d3f7260f97caf7f4e9979ae886.
        // Existing binaries and live instances are unaffected.
        Darwin._exit(70)
        do {
            let output = try PrimeR19ControllerSupervisor.run()
            guard fcntl(STDOUT_FILENO, F_SETNOSIGPIPE, 1) == 0 else {
                Darwin._exit(70)
            }
            let written = output.withUnsafeBytes { raw in
                guard let base = raw.baseAddress else { return -1 }
                return Darwin.write(STDOUT_FILENO, base, raw.count)
            }
            guard written == output.count else {
                Darwin._exit(70)
            }
            Darwin._exit(0)
        } catch {
            Darwin._exit(70)
        }
    }
}
