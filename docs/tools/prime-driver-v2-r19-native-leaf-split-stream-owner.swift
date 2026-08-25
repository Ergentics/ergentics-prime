// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin
import Dispatch
import Foundation

@_silgen_name("_NSGetEnviron")
private func primeR19SplitOwnerNSGetEnviron()
    -> UnsafeMutablePointer<
        UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
    >

private enum PrimeR19SplitFailure: Error {
    case rejected
}

private enum PrimeR19SplitConstants {
    static let ownerPath =
        "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-a-28835567/PrimeDriverV2R19NativeLeafSplitStreamOwner"
    static let primitivePath =
        "/private/tmp/prime-driver-v2-r19-native-leaf-build-a-e9b6f7bd/sdk26_5_fdflags/PrimeDriverV2R19NativeLeafPrimitiveCanary"
    static let supervisorPath =
        "/private/tmp/prime-driver-v2-r19-native-leaf-controller-runtime-supervisor-repair1-build-a-1aa26d77/PrimeDriverV2R19NativeLeafControllerRuntimeSupervisor"
    static let controllerPath =
        "/private/tmp/prime-driver-v2-r19-native-leaf-admission-controller-repair1-build-a-cfa948e2/PrimeDriverV2R19NativeLeafAdmissionController"
    static let auditorPath =
        "/private/tmp/prime-driver-v2-r19-native-leaf-admission-repair1-build-a-c414eac5/PrimeDriverV2R19NativeLeafAdmission"

    static let ownerRootLeaf =
        "r19-native-leaf-split-stream-owner-6a015c11-95c54351"
    static let ownerRootPath = "/private/tmp/\(ownerRootLeaf)"
    static let primitiveRootLeaf =
        "gate-e1-4-r19-native-leaf-primitive-canary-3a46a037-17452840"
    static let supervisorRootLeaf =
        "r19-native-leaf-controller-runtime-supervisor-22015509-d577abc8"

    static let journalLeaves = [
        "00-intent.json",
        "01-owner-bound.json",
        "02-primitive-spawn-commitment.json",
        "03-primitive-action-commitment.json",
        "04-primitive-terminal.json",
        "05-supervisor-spawn-commitment.json",
        "06-supervisor-action-commitment.json",
        "07-supervisor-terminal.json",
        "08-owner-terminal.json",
    ]

    static let requestBase64 =
        "eyJhcnRpZmFjdCI6eyJjb250cm9sX3ByZWRlY2Vzc29yX2NvbW1pdCI6IjIyMDE1NTA5MzYyZjM1YzcwNjBiYzVmYTc5MzRkOGI1ODM4NDViYTMiLCJjb250cm9sX3ByZWRlY2Vzc29yX3RyZWUiOiJkNTc3YWJjOGI4NGQ0NzVlNmYxZDFjOTBhMzQwNThiZWNjZTJhMjUxIiwiY29udHJvbGxlcl9hX3Jhd19zaGEyNTYiOiIwMWE4ZTgyZDQ5YjVjNmM2OTZhY2ViNWVjMDcxNzI4MzY4MTlkMzllMmNmMWY4ZDljYzc5MmZmN2RkOGI5MDE2Iiwia2luZCI6IlIxOV9OQVRJVkVfTEVBRl9DT05UUk9MTEVSX1JVTlRJTUVfU1VQRVJWSVNPUl8yMjAxNTUwOV9ENTc3QUJDOCJ9LCJpbnZvY2F0aW9uIjp7ImF0dGVtcHQiOjEsImlkIjoicjE5LW5hdGl2ZS1sZWFmLWNvbnRyb2xsZXItcnVudGltZS1zdXBlcnZpc29yLTIyMDE1NTA5LWQ1NzdhYmM4Iiwiam91cm5hbF9yb290IjoiL3ByaXZhdGUvdG1wL3IxOS1uYXRpdmUtbGVhZi1jb250cm9sbGVyLXJ1bnRpbWUtc3VwZXJ2aXNvci0yMjAxNTUwOS1kNTc3YWJjOCJ9LCJzY2hlbWEiOiJwcmltZV9kcml2ZXJfdjJfcjE5X25hdGl2ZV9sZWFmX2NvbnRyb2xsZXJfcnVudGltZV9zdXBlcnZpc29yX3JlYWRpbmVzc192MSIsInN1cGVydmlzb3JfYV9leHBlY3RlZF9pZGVudGl0eSI6eyJhcmNoaXRlY3R1cmUiOiJhcm02NCIsImNvZGVfZGlyZWN0b3J5X2Z1bGxfc2hhMjU2IjoiMmE0MjA5ZThlMDk1ZjBhOTVmY2Q5M2MzYTdmNzZmODJmNWY0MDUzYWZjZDU1MjAzNjMwNGUxM2NhN2E0ZWIyNSIsImRldmljZSI6MTY3NzcyMzEsImVudHJ5b2ZmIjozNDA3NiwiZmlsZXR5cGUiOiJNSF9FWEVDVVRFIiwiZmxhZ3MiOjAsImdpZCI6MCwiaW5vZGUiOjE3NDk4NzY2LCJsY19jb2RlX3NpZ25hdHVyZV9vZmZzZXQiOjMzOTMxMiwibGNfY29kZV9zaWduYXR1cmVfc2l6ZSI6MjgyNCwibG9hZF9jb21tYW5kX2NvdW50IjozMCwibG9hZF9jb21tYW5kc19zaXplX2J5dGVzIjozODU2LCJtb2RlIjoiMDcwMCIsIm5saW5rIjoxLCJwYXRoIjoiL3ByaXZhdGUvdG1wL3ByaW1lLWRyaXZlci12Mi1yMTktbmF0aXZlLWxlYWYtY29udHJvbGxlci1ydW50aW1lLXN1cGVydmlzb3ItcmVwYWlyMS1idWlsZC1hLTFhYTI2ZDc3L1ByaW1lRHJpdmVyVjJSMTlOYXRpdmVMZWFmQ29udHJvbGxlclJ1bnRpbWVTdXBlcnZpc29yIiwicmF3X3NoYTI1NiI6ImRjMjc4NTFiY2EzMzRhMzczZGFkODJjZWI3NmQ2YWM0ODhjYjVkNjY3YmE3ZTVjNmI5ZTgzZmIxMjJmZDFlMmUiLCJzaXplX2J5dGVzIjozNDIxMzYsInVpZCI6NTAxLCJ1dWlkIjoiMEM3NDZGNDktQjUyNi0zQjQ0LUI0RTUtODRBQjFCOTY5QzdEIn19"
    static let requestSHA256 =
        "1d097a7b49e443dee44928b2f1c360d477c9eada1435b8a1f7ac64f7610d79b5"
    static let requestCount = 1_311
    static let streamCap = 4_096
    static let streamQuantum = 4_096
    static let frameCap = 65_536
    static let deadlineNanoseconds: UInt64 = 5_000_000_000
    static let watcherEventCap = 16
    static let groupPIDCapacity = 65_536
}

private enum PrimeR19SplitCanonical {
    static func encode(_ object: Any) throws -> Data {
        guard JSONSerialization.isValidJSONObject(object) else {
            throw PrimeR19SplitFailure.rejected
        }
        return try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
    }

    static func sha256Hex(_ data: Data) -> String {
        hex(Data(SHA256.hash(data: data)))
    }

    static func hex(_ data: Data) -> String {
        let alphabet = Array("0123456789abcdef".utf8)
        var result = [UInt8]()
        result.reserveCapacity(data.count * 2)
        for byte in data {
            result.append(alphabet[Int(byte >> 4)])
            result.append(alphabet[Int(byte & 0x0f)])
        }
        return String(decoding: result, as: UTF8.self)
    }
}

private final class PrimeR19SplitFD {
    private(set) var rawValue: Int32

    init(_ rawValue: Int32) throws {
        guard rawValue >= 3 else {
            if rawValue >= 0 { _ = Darwin.close(rawValue) }
            throw PrimeR19SplitFailure.rejected
        }
        self.rawValue = rawValue
    }

    var isOpen: Bool { rawValue >= 0 }

    @discardableResult
    func close() -> Int32 {
        guard rawValue >= 0 else { return 0 }
        let value = rawValue
        rawValue = -1
        return Darwin.close(value)
    }

    deinit { _ = close() }
}

private enum PrimeR19SplitIngress {
    static func requireClosedOwnerIngress() throws {
        guard CommandLine.argc == 1,
              let environment = primeR19SplitOwnerNSGetEnviron().pointee,
              environment.pointee == nil
        else {
            throw PrimeR19SplitFailure.rejected
        }

        var cwd = [CChar](repeating: 0, count: Int(PATH_MAX))
        let cwdResult = cwd.withUnsafeMutableBufferPointer {
            getcwd($0.baseAddress, $0.count)
        }
        guard cwdResult != nil,
              cwd[0] == CChar(UInt8(ascii: "/")),
              cwd[1] == 0,
              MemoryLayout<proc_fdinfo>.size == 8,
              MemoryLayout<proc_fdinfo>.stride == 8
        else {
            throw PrimeR19SplitFailure.rejected
        }

        var descriptors = [proc_fdinfo](repeating: proc_fdinfo(), count: 4)
        let returned = descriptors.withUnsafeMutableBufferPointer {
            proc_pidinfo(
                getpid(), PROC_PIDLISTFDS, 0, $0.baseAddress,
                Int32($0.count * MemoryLayout<proc_fdinfo>.stride)
            )
        }
        guard returned == 24,
              descriptors.prefix(3).map(\.proc_fd).sorted() == [0, 1, 2]
        else {
            throw PrimeR19SplitFailure.rejected
        }

        try requireOuterNull(STDIN_FILENO)
        try requireOuterCapture(STDOUT_FILENO)
        try requireOuterCapture(STDERR_FILENO)
        var output = stat()
        var error = stat()
        guard fstat(STDOUT_FILENO, &output) == 0,
              fstat(STDERR_FILENO, &error) == 0,
              output.st_dev != error.st_dev || output.st_ino != error.st_ino
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func requireOuterNull(_ descriptor: Int32) throws {
        var value = stat()
        guard fstat(descriptor, &value) == 0,
              value.st_mode & mode_t(S_IFMT) == mode_t(S_IFCHR),
              UInt32(bitPattern: value.st_dev) == 3_836_289_247,
              value.st_ino == ino_t(336),
              value.st_rdev == dev_t(50_331_650),
              value.st_uid == 0,
              value.st_gid == 0,
              value.st_mode & mode_t(0o7777) == mode_t(0o666),
              prime_driver_v2_r19_split_owner_get_status_flags(descriptor) ==
                O_RDONLY,
              isatty(descriptor) == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func requireOuterCapture(_ descriptor: Int32) throws {
        var value = stat()
        guard fstat(descriptor, &value) == 0,
              value.st_mode & mode_t(S_IFMT) == mode_t(S_IFIFO),
              prime_driver_v2_r19_split_owner_get_status_flags(descriptor) ==
                O_WRONLY,
              isatty(descriptor) == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }
}

private enum PrimeR19SplitNamespace {
    static func requireAllInitiallyAbsentTwice(_ privateTmp: Int32) throws {
        guard Set([
            PrimeR19SplitConstants.ownerRootLeaf,
            PrimeR19SplitConstants.primitiveRootLeaf,
            PrimeR19SplitConstants.supervisorRootLeaf,
        ]).count == 3 else {
            throw PrimeR19SplitFailure.rejected
        }
        for _ in 0..<2 {
            try requireOwnerAbsent(privateTmp)
            try requirePrimitiveRootAbsent(privateTmp)
            try requireSupervisorRootAbsent(privateTmp)
        }
    }

    static func requirePrimitiveAbsent(_ privateTmp: Int32) throws {
        try requirePrimitiveRootAbsent(privateTmp)
    }

    static func requireSupervisorAbsent(_ privateTmp: Int32) throws {
        try requireSupervisorRootAbsent(privateTmp)
    }

    private static func requireOwnerAbsent(_ parent: Int32) throws {
        var value = stat()
        errno = 0
        let result = PrimeR19SplitConstants.ownerRootLeaf.withCString {
            fstatat(parent, $0, &value, AT_SYMLINK_NOFOLLOW)
        }
        guard result == -1, errno == ENOENT else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func requirePrimitiveRootAbsent(_ parent: Int32) throws {
        var value = stat()
        errno = 0
        let result = PrimeR19SplitConstants.primitiveRootLeaf.withCString {
            fstatat(parent, $0, &value, AT_SYMLINK_NOFOLLOW)
        }
        guard result == -1, errno == ENOENT else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func requireSupervisorRootAbsent(_ parent: Int32) throws {
        var value = stat()
        errno = 0
        let result = PrimeR19SplitConstants.supervisorRootLeaf.withCString {
            fstatat(parent, $0, &value, AT_SYMLINK_NOFOLLOW)
        }
        guard result == -1, errno == ENOENT else {
            throw PrimeR19SplitFailure.rejected
        }
    }
}

private struct PrimeR19SplitMachOIdentity: Equatable {
    let uuid: String
    let loadCommandCount: UInt32
    let loadCommandsSize: UInt32
    let entryOffset: UInt64
    let codeSignatureOffset: UInt64
    let codeSignatureSize: UInt64
    let codeDirectorySHA256: String
    let minimumOS: UInt32?
    let sdk: UInt32?
}

private struct PrimeR19SplitImageFingerprint: Equatable {
    let device: UInt64
    let inode: UInt64
    let uid: UInt32
    let gid: UInt32
    let permissions: UInt16
    let links: UInt64
    let flags: UInt32
    let byteCount: UInt64
    let modificationTimeNanoseconds: String
    let changeTimeNanoseconds: String
    let rawSHA256: String
    let machO: PrimeR19SplitMachOIdentity
    let xattrs: [String: String]
    let acl: String
}

private struct PrimeR19SplitImageExpectation {
    let fingerprint: PrimeR19SplitImageFingerprint

    static let primitive = PrimeR19SplitImageExpectation(
        fingerprint: PrimeR19SplitImageFingerprint(
            device: 16_777_231,
            inode: 17_454_586,
            uid: 501,
            gid: 0,
            permissions: 0o755,
            links: 1,
            flags: 0,
            byteCount: 89_976,
            modificationTimeNanoseconds: "",
            changeTimeNanoseconds: "",
            rawSHA256:
                "e826ff9251906e2ff92921fcbaa8b27eff32e227838ce217c62017c9461b10d3",
            machO: PrimeR19SplitMachOIdentity(
                uuid: "250D80B3-E19B-3B12-AC3A-D225B5FF5BEB",
                loadCommandCount: 0,
                loadCommandsSize: 0,
                entryOffset: 0,
                codeSignatureOffset: 0,
                codeSignatureSize: 0,
                codeDirectorySHA256:
                    "f4e81281906a06354b1cd604d178102337b47360c5cc298f6ebc2109cccc045d",
                minimumOS: 0x000e_0000,
                sdk: 0x001a_0500
            ),
            xattrs: [
                "com.apple.provenance": "01020049b5cb684f79583c",
            ],
            acl: "ABSENT"
        )
    )

    static let supervisor = PrimeR19SplitImageExpectation(
        fingerprint: PrimeR19SplitImageFingerprint(
            device: 16_777_231,
            inode: 17_498_766,
            uid: 501,
            gid: 0,
            permissions: 0o700,
            links: 1,
            flags: 0,
            byteCount: 342_136,
            modificationTimeNanoseconds: "1787627250206084872",
            changeTimeNanoseconds: "1787629803297835805",
            rawSHA256:
                "dc27851bca334a373dad82ceb76d6ac488cb5d667ba7e5c6b9e83fb122fd1e2e",
            machO: PrimeR19SplitMachOIdentity(
                uuid: "0C746F49-B526-3B44-B4E5-84AB1B969C7D",
                loadCommandCount: 30,
                loadCommandsSize: 3_856,
                entryOffset: 34_076,
                codeSignatureOffset: 339_312,
                codeSignatureSize: 2_824,
                codeDirectorySHA256:
                    "2a4209e8e095f0a95fcd93c3a7f76f82f5f4053afcd552036304e13ca7a4eb25",
                minimumOS: nil,
                sdk: nil
            ),
            xattrs: [
                "com.apple.provenance": "01020049b5cb684f79583c",
            ],
            acl: "ABSENT"
        )
    )

    static let controller = PrimeR19SplitImageExpectation(
        fingerprint: PrimeR19SplitImageFingerprint(
            device: 16_777_231,
            inode: 17_483_372,
            uid: 501,
            gid: 0,
            permissions: 0o700,
            links: 1,
            flags: 0,
            byteCount: 185_056,
            modificationTimeNanoseconds: "",
            changeTimeNanoseconds: "",
            rawSHA256:
                "01a8e82d49b5c6c696aceb5ec07172836819d39e2cf1f8d9cc792ff7dd8b9016",
            machO: PrimeR19SplitMachOIdentity(
                uuid: "A9FD612B-DB03-3C61-B03E-4435ED3524FF",
                loadCommandCount: 30,
                loadCommandsSize: 3_536,
                entryOffset: 22_644,
                codeSignatureOffset: 183_456,
                codeSignatureSize: 1_600,
                codeDirectorySHA256:
                    "feaced540dbc2d8c9e566b733958f2bcf70c5164ba220680c4775e7055b71972",
                minimumOS: nil,
                sdk: nil
            ),
            xattrs: [
                "com.apple.provenance": "01020049b5cb684f79583c",
            ],
            acl: "ABSENT"
        )
    )

    static let auditor = PrimeR19SplitImageExpectation(
        fingerprint: PrimeR19SplitImageFingerprint(
            device: 16_777_231,
            inode: 17_459_126,
            uid: 501,
            gid: 0,
            permissions: 0o700,
            links: 1,
            flags: 0,
            byteCount: 114_384,
            modificationTimeNanoseconds: "",
            changeTimeNanoseconds: "",
            rawSHA256:
                "aee14f52c66378c4fd27b2d0fe70c62ca8f3ddb7837acda9d49ff7b960f9f8a2",
            machO: PrimeR19SplitMachOIdentity(
                uuid: "A18BE2E3-3DE0-3795-96BE-1EA931C3F64B",
                loadCommandCount: 29,
                loadCommandsSize: 3_080,
                entryOffset: 5_008,
                codeSignatureOffset: 113_344,
                codeSignatureSize: 1_040,
                codeDirectorySHA256:
                    "3cc3b1ad0ea7e76167c747907cb3f75846d4dbced10f8a9cdf360787e364b87e",
                minimumOS: nil,
                sdk: nil
            ),
            xattrs: [
                "com.apple.provenance": "01020049b5cb684f79583c",
            ],
            acl: "ABSENT"
        )
    )
}

private enum PrimeR19SplitMachO {
    private static let headerBytes = 32
    private static let lcUUID: UInt32 = 0x1b
    private static let lcCodeSignature: UInt32 = 0x1d
    private static let lcMain: UInt32 = 0x8000_0028
    private static let lcBuildVersion: UInt32 = 0x32

    static func inspect(_ bytes: Data) throws -> PrimeR19SplitMachOIdentity {
        guard bytes.count >= headerBytes,
              try little32(bytes, 0) == 0xfeed_facf,
              try little32(bytes, 4) == 0x0100_000c,
              try little32(bytes, 12) == UInt32(MH_EXECUTE)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        let count = try little32(bytes, 16)
        let commandsSize = try little32(bytes, 20)
        let end = headerBytes.addingReportingOverflow(Int(commandsSize))
        guard count > 0, !end.overflow, end.partialValue <= bytes.count else {
            throw PrimeR19SplitFailure.rejected
        }

        var cursor = headerBytes
        var uuid: String?
        var entryOffset: UInt64?
        var signature: (UInt64, UInt64)?
        var minimumOS: UInt32?
        var sdk: UInt32?
        for _ in 0..<count {
            let command = try little32(bytes, cursor)
            let commandSize = Int(try little32(bytes, cursor + 4))
            guard commandSize >= 8,
                  commandSize % 8 == 0,
                  cursor <= end.partialValue - commandSize
            else {
                throw PrimeR19SplitFailure.rejected
            }
            switch command {
            case lcUUID:
                guard commandSize == 24, uuid == nil else {
                    throw PrimeR19SplitFailure.rejected
                }
                uuid = uuidString(Array(bytes[(cursor + 8)..<(cursor + 24)]))
            case lcMain:
                guard commandSize == 24, entryOffset == nil else {
                    throw PrimeR19SplitFailure.rejected
                }
                entryOffset = try little64(bytes, cursor + 8)
            case lcCodeSignature:
                guard commandSize == 16, signature == nil else {
                    throw PrimeR19SplitFailure.rejected
                }
                signature = (
                    UInt64(try little32(bytes, cursor + 8)),
                    UInt64(try little32(bytes, cursor + 12))
                )
            case lcBuildVersion:
                guard commandSize >= 24,
                      try little32(bytes, cursor + 8) == 1,
                      minimumOS == nil,
                      sdk == nil
                else {
                    throw PrimeR19SplitFailure.rejected
                }
                minimumOS = try little32(bytes, cursor + 12)
                sdk = try little32(bytes, cursor + 16)
            default:
                break
            }
            cursor += commandSize
        }
        guard cursor == end.partialValue,
              let uuid,
              let entryOffset,
              let signature
        else {
            throw PrimeR19SplitFailure.rejected
        }
        let codeDirectory = try codeDirectoryHash(
            bytes,
            offset: Int(signature.0),
            size: Int(signature.1)
        )
        return PrimeR19SplitMachOIdentity(
            uuid: uuid,
            loadCommandCount: count,
            loadCommandsSize: commandsSize,
            entryOffset: entryOffset,
            codeSignatureOffset: signature.0,
            codeSignatureSize: signature.1,
            codeDirectorySHA256: codeDirectory,
            minimumOS: minimumOS,
            sdk: sdk
        )
    }

    private static func codeDirectoryHash(
        _ bytes: Data,
        offset: Int,
        size: Int
    ) throws -> String {
        guard size >= 20,
              offset >= 0,
              offset <= bytes.count - size,
              try big32(bytes, offset) == 0xfade_0cc0
        else {
            throw PrimeR19SplitFailure.rejected
        }
        let superLength = Int(try big32(bytes, offset + 4))
        guard superLength >= 20, superLength <= size else {
            throw PrimeR19SplitFailure.rejected
        }
        if superLength < size {
            guard bytes[(offset + superLength)..<(offset + size)]
                    .allSatisfy({ $0 == 0 })
            else {
                throw PrimeR19SplitFailure.rejected
            }
        }
        let count = Int(try big32(bytes, offset + 8))
        guard count > 0, count <= (superLength - 12) / 8 else {
            throw PrimeR19SplitFailure.rejected
        }
        var found: Range<Int>?
        for index in 0..<count {
            let entry = offset + 12 + index * 8
            let type = try big32(bytes, entry)
            let relative = Int(try big32(bytes, entry + 4))
            guard relative >= 0, relative <= superLength - 8 else {
                throw PrimeR19SplitFailure.rejected
            }
            if type == 0 {
                guard found == nil else { throw PrimeR19SplitFailure.rejected }
                let start = offset + relative
                guard try big32(bytes, start) == 0xfade_0c02 else {
                    throw PrimeR19SplitFailure.rejected
                }
                let length = Int(try big32(bytes, start + 4))
                guard length >= 8,
                      start >= offset,
                      start <= offset + superLength - length
                else {
                    throw PrimeR19SplitFailure.rejected
                }
                found = start..<(start + length)
            }
        }
        guard let found else { throw PrimeR19SplitFailure.rejected }
        return PrimeR19SplitCanonical.sha256Hex(Data(bytes[found]))
    }

    private static func uuidString(_ bytes: [UInt8]) -> String {
        let alphabet = Array("0123456789ABCDEF".utf8)
        var result = [UInt8]()
        result.reserveCapacity(36)
        for index in bytes.indices {
            if index == 4 || index == 6 || index == 8 || index == 10 {
                result.append(0x2d)
            }
            result.append(alphabet[Int(bytes[index] >> 4)])
            result.append(alphabet[Int(bytes[index] & 0x0f)])
        }
        return String(decoding: result, as: UTF8.self)
    }

    private static func little32(_ bytes: Data, _ offset: Int) throws -> UInt32 {
        guard offset >= 0, offset <= bytes.count - 4 else {
            throw PrimeR19SplitFailure.rejected
        }
        return UInt32(bytes[offset])
            | UInt32(bytes[offset + 1]) << 8
            | UInt32(bytes[offset + 2]) << 16
            | UInt32(bytes[offset + 3]) << 24
    }

    private static func little64(_ bytes: Data, _ offset: Int) throws -> UInt64 {
        UInt64(try little32(bytes, offset))
            | UInt64(try little32(bytes, offset + 4)) << 32
    }

    private static func big32(_ bytes: Data, _ offset: Int) throws -> UInt32 {
        guard offset >= 0, offset <= bytes.count - 4 else {
            throw PrimeR19SplitFailure.rejected
        }
        return UInt32(bytes[offset]) << 24
            | UInt32(bytes[offset + 1]) << 16
            | UInt32(bytes[offset + 2]) << 8
            | UInt32(bytes[offset + 3])
    }
}

private enum PrimeR19SplitImageAdmission {
    static func owner(_ descriptor: Int32) throws
        -> PrimeR19SplitImageFingerprint
    {
        var named = stat()
        guard PrimeR19SplitConstants.ownerPath.withCString({
            fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
        }) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        return try capture(descriptor, named: named)
    }

    static func primitive(_ descriptor: Int32) throws
        -> PrimeR19SplitImageFingerprint
    {
        var named = stat()
        guard PrimeR19SplitConstants.primitivePath.withCString({
            fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
        }) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        let observed = try capture(descriptor, named: named)
        let expected = PrimeR19SplitImageExpectation.primitive.fingerprint
        guard observed.device == expected.device,
              observed.inode == expected.inode,
              observed.uid == expected.uid,
              observed.gid == expected.gid,
              observed.permissions == expected.permissions,
              observed.links == expected.links,
              observed.flags == expected.flags,
              observed.byteCount == expected.byteCount,
              observed.modificationTimeNanoseconds ==
                expected.modificationTimeNanoseconds ||
                expected.modificationTimeNanoseconds.isEmpty,
              observed.changeTimeNanoseconds == expected.changeTimeNanoseconds
                || expected.changeTimeNanoseconds.isEmpty,
              observed.rawSHA256 == expected.rawSHA256,
              observed.xattrs == expected.xattrs,
              observed.acl == expected.acl,
              observed.machO.uuid == expected.machO.uuid,
              observed.machO.codeDirectorySHA256 ==
                expected.machO.codeDirectorySHA256,
              observed.machO.minimumOS == expected.machO.minimumOS,
              observed.machO.sdk == expected.machO.sdk
        else {
            throw PrimeR19SplitFailure.rejected
        }
        return observed
    }

    static func supervisor(_ descriptor: Int32) throws
        -> PrimeR19SplitImageFingerprint
    {
        var named = stat()
        guard PrimeR19SplitConstants.supervisorPath.withCString({
            fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
        }) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        let observed = try capture(descriptor, named: named)
        let expected = PrimeR19SplitImageExpectation.supervisor.fingerprint
        guard observed.device == expected.device,
              observed.inode == expected.inode,
              observed.uid == expected.uid,
              observed.gid == expected.gid,
              observed.permissions == expected.permissions,
              observed.links == expected.links,
              observed.flags == expected.flags,
              observed.byteCount == expected.byteCount,
              observed.modificationTimeNanoseconds ==
                expected.modificationTimeNanoseconds,
              observed.changeTimeNanoseconds == expected.changeTimeNanoseconds,
              observed.rawSHA256 == expected.rawSHA256,
              observed.xattrs == expected.xattrs,
              observed.acl == expected.acl,
              observed.machO.uuid == expected.machO.uuid,
              observed.machO.loadCommandCount ==
                expected.machO.loadCommandCount,
              observed.machO.loadCommandsSize == expected.machO.loadCommandsSize,
              observed.machO.entryOffset == expected.machO.entryOffset,
              observed.machO.codeSignatureOffset ==
                expected.machO.codeSignatureOffset,
              observed.machO.codeSignatureSize ==
                expected.machO.codeSignatureSize,
              observed.machO.codeDirectorySHA256 ==
                expected.machO.codeDirectorySHA256
        else {
            throw PrimeR19SplitFailure.rejected
        }
        return observed
    }

    static func controller(_ descriptor: Int32) throws
        -> PrimeR19SplitImageFingerprint
    {
        var named = stat()
        guard PrimeR19SplitConstants.controllerPath.withCString({
            fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
        }) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        let observed = try capture(descriptor, named: named)
        let expected = PrimeR19SplitImageExpectation.controller.fingerprint
        guard observed.device == expected.device,
              observed.inode == expected.inode,
              observed.uid == expected.uid,
              observed.gid == expected.gid,
              observed.permissions == expected.permissions,
              observed.links == expected.links,
              observed.flags == expected.flags,
              observed.byteCount == expected.byteCount,
              expected.modificationTimeNanoseconds.isEmpty,
              expected.changeTimeNanoseconds.isEmpty,
              observed.rawSHA256 == expected.rawSHA256,
              observed.xattrs == expected.xattrs,
              observed.acl == expected.acl,
              observed.machO.uuid == expected.machO.uuid,
              observed.machO.loadCommandCount ==
                expected.machO.loadCommandCount,
              observed.machO.loadCommandsSize == expected.machO.loadCommandsSize,
              observed.machO.entryOffset == expected.machO.entryOffset,
              observed.machO.codeSignatureOffset ==
                expected.machO.codeSignatureOffset,
              observed.machO.codeSignatureSize ==
                expected.machO.codeSignatureSize,
              observed.machO.codeDirectorySHA256 ==
                expected.machO.codeDirectorySHA256
        else {
            throw PrimeR19SplitFailure.rejected
        }
        return observed
    }

    static func auditor(_ descriptor: Int32) throws
        -> PrimeR19SplitImageFingerprint
    {
        var named = stat()
        guard PrimeR19SplitConstants.auditorPath.withCString({
            fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
        }) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        let observed = try capture(descriptor, named: named)
        let expected = PrimeR19SplitImageExpectation.auditor.fingerprint
        guard observed.device == expected.device,
              observed.inode == expected.inode,
              observed.uid == expected.uid,
              observed.gid == expected.gid,
              observed.permissions == expected.permissions,
              observed.links == expected.links,
              observed.flags == expected.flags,
              observed.byteCount == expected.byteCount,
              expected.modificationTimeNanoseconds.isEmpty,
              expected.changeTimeNanoseconds.isEmpty,
              observed.rawSHA256 == expected.rawSHA256,
              observed.xattrs == expected.xattrs,
              observed.acl == expected.acl,
              observed.machO.uuid == expected.machO.uuid,
              observed.machO.loadCommandCount ==
                expected.machO.loadCommandCount,
              observed.machO.loadCommandsSize == expected.machO.loadCommandsSize,
              observed.machO.entryOffset == expected.machO.entryOffset,
              observed.machO.codeSignatureOffset ==
                expected.machO.codeSignatureOffset,
              observed.machO.codeSignatureSize ==
                expected.machO.codeSignatureSize,
              observed.machO.codeDirectorySHA256 ==
                expected.machO.codeDirectorySHA256
        else {
            throw PrimeR19SplitFailure.rejected
        }
        return observed
    }

    private static func capture(_ descriptor: Int32, named: stat) throws
        -> PrimeR19SplitImageFingerprint
    {
        let descriptorFlags =
            prime_driver_v2_r19_split_owner_get_fd_flags(descriptor)
        let statusFlags =
            prime_driver_v2_r19_split_owner_get_status_flags(descriptor)
        guard descriptor >= 3,
              descriptorFlags >= 0,
              descriptorFlags & FD_CLOEXEC != 0,
              statusFlags >= 0,
              statusFlags & O_ACCMODE == O_RDONLY
        else {
            throw PrimeR19SplitFailure.rejected
        }
        var held = stat()
        guard fstat(descriptor, &held) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              held.st_uid == named.st_uid,
              held.st_gid == named.st_gid,
              held.st_mode == named.st_mode,
              held.st_nlink == named.st_nlink,
              held.st_flags == named.st_flags,
              held.st_size == named.st_size,
              held.st_mtimespec.tv_sec == named.st_mtimespec.tv_sec,
              held.st_mtimespec.tv_nsec == named.st_mtimespec.tv_nsec,
              held.st_ctimespec.tv_sec == named.st_ctimespec.tv_sec,
              held.st_ctimespec.tv_nsec == named.st_ctimespec.tv_nsec,
              held.st_size > 0,
              held.st_size <= off_t(Int.max)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        let bytes = try readExact(descriptor, Int(held.st_size))
        let xattrs = try xattrFingerprint(descriptor)
        let acl = try aclFingerprint(descriptor)
        return PrimeR19SplitImageFingerprint(
            device: UInt64(UInt32(bitPattern: held.st_dev)),
            inode: UInt64(held.st_ino),
            uid: UInt32(held.st_uid),
            gid: UInt32(held.st_gid),
            permissions: UInt16(held.st_mode & mode_t(0o7777)),
            links: UInt64(held.st_nlink),
            flags: held.st_flags,
            byteCount: UInt64(held.st_size),
            modificationTimeNanoseconds: try nanoseconds(
                held.st_mtimespec
            ),
            changeTimeNanoseconds: try nanoseconds(held.st_ctimespec),
            rawSHA256: PrimeR19SplitCanonical.sha256Hex(bytes),
            machO: try PrimeR19SplitMachO.inspect(bytes),
            xattrs: xattrs,
            acl: acl
        )
    }

    private static func readExact(_ descriptor: Int32, _ count: Int) throws
        -> Data
    {
        var result = Data(count: count)
        var offset = 0
        try result.withUnsafeMutableBytes { raw in
            guard let base = raw.baseAddress else {
                throw PrimeR19SplitFailure.rejected
            }
            while offset < count {
                errno = 0
                let returned = pread(
                    descriptor,
                    base.advanced(by: offset),
                    count - offset,
                    off_t(offset)
                )
                if returned < 0, errno == EINTR { continue }
                guard returned > 0 else { throw PrimeR19SplitFailure.rejected }
                offset += returned
            }
        }
        var extra: UInt8 = 0
        guard pread(descriptor, &extra, 1, off_t(count)) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        return result
    }

    private static func nanoseconds(_ value: timespec) throws -> String {
        let product = Int64(value.tv_sec).multipliedReportingOverflow(
            by: 1_000_000_000
        )
        guard !product.overflow else { throw PrimeR19SplitFailure.rejected }
        let sum = product.partialValue.addingReportingOverflow(
            Int64(value.tv_nsec)
        )
        guard !sum.overflow, value.tv_nsec >= 0, value.tv_nsec < 1_000_000_000
        else {
            throw PrimeR19SplitFailure.rejected
        }
        return String(sum.partialValue)
    }

    private static func xattrFingerprint(_ descriptor: Int32) throws
        -> [String: String]
    {
        errno = 0
        let required = flistxattr(descriptor, nil, 0, 0)
        guard required >= 0, required <= 65_536 else {
            throw PrimeR19SplitFailure.rejected
        }
        if required == 0 { return [:] }
        var inventory = [CChar](repeating: 0, count: required)
        errno = 0
        let returned = inventory.withUnsafeMutableBufferPointer {
            flistxattr(descriptor, $0.baseAddress, $0.count, 0)
        }
        guard returned == required else {
            throw PrimeR19SplitFailure.rejected
        }
        let bytes = inventory.map { UInt8(bitPattern: $0) }
        var names = [String]()
        var start = 0
        for index in bytes.indices where bytes[index] == 0 {
            guard index > start else { throw PrimeR19SplitFailure.rejected }
            let nameBytes = bytes[start..<index]
            guard let name = String(bytes: nameBytes, encoding: .utf8),
                  !name.contains("\0")
            else {
                throw PrimeR19SplitFailure.rejected
            }
            names.append(name)
            start = index + 1
        }
        guard start == bytes.count,
              Set(names).count == names.count
        else {
            throw PrimeR19SplitFailure.rejected
        }
        var result = [String: String]()
        for name in names.sorted() {
            errno = 0
            let valueCount = name.withCString {
                fgetxattr(descriptor, $0, nil, 0, 0, 0)
            }
            guard valueCount >= 0, valueCount <= 65_536 else {
                throw PrimeR19SplitFailure.rejected
            }
            var value = Data(count: valueCount)
            let valueReturned = value.withUnsafeMutableBytes { raw in
                name.withCString {
                    fgetxattr(
                        descriptor, $0, raw.baseAddress, raw.count, 0, 0
                    )
                }
            }
            guard valueReturned == valueCount else {
                throw PrimeR19SplitFailure.rejected
            }
            result[name] = PrimeR19SplitCanonical.hex(value)
        }
        return result
    }

    private static func aclFingerprint(_ descriptor: Int32) throws -> String {
        errno = 0
        guard let acl = acl_get_fd_np(descriptor, ACL_TYPE_EXTENDED) else {
            guard errno == ENOENT else { throw PrimeR19SplitFailure.rejected }
            return "ABSENT"
        }
        defer { _ = acl_free(UnsafeMutableRawPointer(acl)) }
        let size = acl_size(acl)
        guard size > 0, size <= 65_536 else {
            throw PrimeR19SplitFailure.rejected
        }
        var bytes = Data(count: Int(size))
        let copied = bytes.withUnsafeMutableBytes {
            acl_copy_ext($0.baseAddress, acl, size)
        }
        guard copied == size else { throw PrimeR19SplitFailure.rejected }
        return "PRESENT_SHA256_\(PrimeR19SplitCanonical.sha256Hex(bytes))"
    }
}

private final class PrimeR19SplitHeldImageCore {
    let descriptor: PrimeR19SplitFD
    let baseline: PrimeR19SplitImageFingerprint

    init(
        descriptor: PrimeR19SplitFD,
        baseline: PrimeR19SplitImageFingerprint
    ) {
        self.descriptor = descriptor
        self.baseline = baseline
    }

    var identityWithoutPath: [String: Any] {
        [
            "device": baseline.device,
            "inode": baseline.inode,
            "raw_sha256": baseline.rawSHA256,
            "uuid": baseline.machO.uuid,
        ]
    }
}

private final class PrimeR19SplitHeldOwnerA {
    let core: PrimeR19SplitHeldImageCore
    var descriptor: PrimeR19SplitFD { core.descriptor }
    var observedIdentity: [String: Any] {
        var result = core.identityWithoutPath
        result["path"] = PrimeR19SplitConstants.ownerPath
        return result
    }

    static func open() throws -> PrimeR19SplitHeldOwnerA {
        let descriptor = try PrimeR19SplitFD(
            prime_driver_v2_r19_split_owner_open_owner_a_image()
        )
        return PrimeR19SplitHeldOwnerA(
            core: PrimeR19SplitHeldImageCore(
                descriptor: descriptor,
                baseline: try PrimeR19SplitImageAdmission.owner(
                    descriptor.rawValue
                )
            )
        )
    }
    private init(core: PrimeR19SplitHeldImageCore) { self.core = core }
    func revalidate() throws {
        guard try PrimeR19SplitImageAdmission.owner(descriptor.rawValue) ==
                core.baseline
        else { throw PrimeR19SplitFailure.rejected }
    }
}

private final class PrimeR19SplitHeldPrimitiveA {
    let core: PrimeR19SplitHeldImageCore
    var descriptor: PrimeR19SplitFD { core.descriptor }
    var observedIdentity: [String: Any] {
        var result = core.identityWithoutPath
        result["path"] = PrimeR19SplitConstants.primitivePath
        return result
    }
    static func open() throws -> PrimeR19SplitHeldPrimitiveA {
        let descriptor = try PrimeR19SplitFD(
            prime_driver_v2_r19_split_owner_open_primitive_a_image()
        )
        return PrimeR19SplitHeldPrimitiveA(
            core: PrimeR19SplitHeldImageCore(
                descriptor: descriptor,
                baseline: try PrimeR19SplitImageAdmission.primitive(
                    descriptor.rawValue
                )
            )
        )
    }
    private init(core: PrimeR19SplitHeldImageCore) { self.core = core }
    func revalidate() throws {
        guard try PrimeR19SplitImageAdmission.primitive(descriptor.rawValue) ==
                core.baseline
        else { throw PrimeR19SplitFailure.rejected }
    }
}

private final class PrimeR19SplitHeldSupervisorA {
    let core: PrimeR19SplitHeldImageCore
    var descriptor: PrimeR19SplitFD { core.descriptor }
    var observedIdentity: [String: Any] {
        var result = core.identityWithoutPath
        result["path"] = PrimeR19SplitConstants.supervisorPath
        return result
    }
    static func open() throws -> PrimeR19SplitHeldSupervisorA {
        let descriptor = try PrimeR19SplitFD(
            prime_driver_v2_r19_split_owner_open_supervisor_a_image()
        )
        return PrimeR19SplitHeldSupervisorA(
            core: PrimeR19SplitHeldImageCore(
                descriptor: descriptor,
                baseline: try PrimeR19SplitImageAdmission.supervisor(
                    descriptor.rawValue
                )
            )
        )
    }
    private init(core: PrimeR19SplitHeldImageCore) { self.core = core }
    func revalidate() throws {
        guard try PrimeR19SplitImageAdmission.supervisor(descriptor.rawValue) ==
                core.baseline
        else { throw PrimeR19SplitFailure.rejected }
    }
}

private final class PrimeR19SplitHeldControllerA {
    let core: PrimeR19SplitHeldImageCore
    var descriptor: PrimeR19SplitFD { core.descriptor }
    var observedIdentity: [String: Any] {
        var result = core.identityWithoutPath
        result["path"] = PrimeR19SplitConstants.controllerPath
        return result
    }
    static func open() throws -> PrimeR19SplitHeldControllerA {
        let descriptor = try PrimeR19SplitFD(
            prime_driver_v2_r19_split_owner_open_controller_a_image()
        )
        return PrimeR19SplitHeldControllerA(
            core: PrimeR19SplitHeldImageCore(
                descriptor: descriptor,
                baseline: try PrimeR19SplitImageAdmission.controller(
                    descriptor.rawValue
                )
            )
        )
    }
    private init(core: PrimeR19SplitHeldImageCore) { self.core = core }
    func revalidate() throws {
        guard try PrimeR19SplitImageAdmission.controller(descriptor.rawValue) ==
                core.baseline
        else { throw PrimeR19SplitFailure.rejected }
    }
}

private final class PrimeR19SplitHeldAuditorA {
    let core: PrimeR19SplitHeldImageCore
    var descriptor: PrimeR19SplitFD { core.descriptor }
    var observedIdentity: [String: Any] {
        var result = core.identityWithoutPath
        result["path"] = PrimeR19SplitConstants.auditorPath
        return result
    }
    static func open() throws -> PrimeR19SplitHeldAuditorA {
        let descriptor = try PrimeR19SplitFD(
            prime_driver_v2_r19_split_owner_open_auditor_a_image()
        )
        return PrimeR19SplitHeldAuditorA(
            core: PrimeR19SplitHeldImageCore(
                descriptor: descriptor,
                baseline: try PrimeR19SplitImageAdmission.auditor(
                    descriptor.rawValue
                )
            )
        )
    }
    private init(core: PrimeR19SplitHeldImageCore) { self.core = core }
    func revalidate() throws {
        guard try PrimeR19SplitImageAdmission.auditor(descriptor.rawValue) ==
                core.baseline
        else { throw PrimeR19SplitFailure.rejected }
    }
}

private protocol PrimeR19SplitFixedMappedType {
    static var fixedMappedPathBytes: [UInt8] { get }
}

extension PrimeR19SplitHeldOwnerA: PrimeR19SplitFixedMappedType {
    static let fixedMappedPathBytes =
        Array(PrimeR19SplitConstants.ownerPath.utf8)
}

extension PrimeR19SplitHeldPrimitiveA: PrimeR19SplitFixedMappedType {
    static let fixedMappedPathBytes =
        Array(PrimeR19SplitConstants.primitivePath.utf8)
}

extension PrimeR19SplitHeldSupervisorA: PrimeR19SplitFixedMappedType {
    static let fixedMappedPathBytes =
        Array(PrimeR19SplitConstants.supervisorPath.utf8)
}

private struct PrimeR19SplitDirectoryIdentity: Equatable {
    let device: UInt64
    let inode: UInt64
    let uid: UInt32
    let gid: UInt32
    let permissions: UInt16
    let links: UInt64
    let flags: UInt32
}

private enum PrimeR19SplitParentChain {
    static func captureOwnerBuildDirectory() throws
        -> PrimeR19SplitDirectoryIdentity
    {
        var value = stat()
        let path =
            "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-a-28835567"
        guard path.withCString({
            fstatat(AT_FDCWD, $0, &value, AT_SYMLINK_NOFOLLOW)
        }) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        return try identity(value)
    }

    static func requireFixedParents(
        ownerBuild: PrimeR19SplitDirectoryIdentity
    ) throws {
        try requirePrivateDirectory()
        try requirePrimitiveBuildDirectory()
        try requirePrimitiveSDKDirectory()
        try requireSupervisorBuildDirectory()
        try requireControllerBuildDirectory()
        try requireAuditorBuildDirectory()
        let recaptured = try captureOwnerBuildDirectory()
        guard recaptured == ownerBuild else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func requirePrivateDirectory() throws {
        var value = stat()
        guard "/private".withCString({
            fstatat(AT_FDCWD, $0, &value, AT_SYMLINK_NOFOLLOW)
        }) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        let observed = try identity(value)
        guard observed.device == 16_777_231,
              observed.inode == 773_652,
              observed.uid == 0,
              observed.gid == 0,
              observed.permissions == 0o755,
              observed.flags == 1_081_344
        else { throw PrimeR19SplitFailure.rejected }
    }

    private static func requirePrimitiveBuildDirectory() throws {
        var value = stat()
        let fixed =
            "/private/tmp/prime-driver-v2-r19-native-leaf-build-a-e9b6f7bd"
        guard fixed.withCString({
            fstatat(AT_FDCWD, $0, &value, AT_SYMLINK_NOFOLLOW)
        }) == 0 else { throw PrimeR19SplitFailure.rejected }
        let observed = try identity(value)
        guard observed.device == 16_777_231,
              observed.inode == 17_453_507,
              observed.uid == 501,
              observed.gid == 0,
              observed.permissions == 0o700,
              observed.links == 8,
              observed.flags == 0
        else { throw PrimeR19SplitFailure.rejected }
    }

    private static func requirePrimitiveSDKDirectory() throws {
        var value = stat()
        let fixed =
            "/private/tmp/prime-driver-v2-r19-native-leaf-build-a-e9b6f7bd/sdk26_5_fdflags"
        guard fixed.withCString({
            fstatat(AT_FDCWD, $0, &value, AT_SYMLINK_NOFOLLOW)
        }) == 0 else { throw PrimeR19SplitFailure.rejected }
        let observed = try identity(value)
        guard observed.device == 16_777_231,
              observed.inode == 17_454_452,
              observed.uid == 501,
              observed.gid == 0,
              observed.permissions == 0o700,
              observed.links == 6,
              observed.flags == 0
        else { throw PrimeR19SplitFailure.rejected }
    }

    private static func requireSupervisorBuildDirectory() throws {
        var value = stat()
        let fixed =
            "/private/tmp/prime-driver-v2-r19-native-leaf-controller-runtime-supervisor-repair1-build-a-1aa26d77"
        guard fixed.withCString({
            fstatat(AT_FDCWD, $0, &value, AT_SYMLINK_NOFOLLOW)
        }) == 0 else { throw PrimeR19SplitFailure.rejected }
        let observed = try identity(value)
        guard observed.device == 16_777_231,
              observed.inode == 17_498_617,
              observed.uid == 501,
              observed.gid == 0,
              observed.permissions == 0o700,
              observed.links == 6,
              observed.flags == 0
        else { throw PrimeR19SplitFailure.rejected }
    }

    private static func requireControllerBuildDirectory() throws {
        var value = stat()
        let fixed =
            "/private/tmp/prime-driver-v2-r19-native-leaf-admission-controller-repair1-build-a-cfa948e2"
        guard fixed.withCString({
            fstatat(AT_FDCWD, $0, &value, AT_SYMLINK_NOFOLLOW)
        }) == 0 else { throw PrimeR19SplitFailure.rejected }
        let observed = try identity(value)
        guard observed.device == 16_777_231,
              observed.inode == 17_483_235,
              observed.uid == 501,
              observed.gid == 0,
              observed.permissions == 0o700,
              observed.links == 5,
              observed.flags == 0
        else { throw PrimeR19SplitFailure.rejected }
    }

    private static func requireAuditorBuildDirectory() throws {
        var value = stat()
        let fixed =
            "/private/tmp/prime-driver-v2-r19-native-leaf-admission-repair1-build-a-c414eac5"
        guard fixed.withCString({
            fstatat(AT_FDCWD, $0, &value, AT_SYMLINK_NOFOLLOW)
        }) == 0 else { throw PrimeR19SplitFailure.rejected }
        let observed = try identity(value)
        guard observed.device == 16_777_231,
              observed.inode == 17_458_990,
              observed.uid == 501,
              observed.gid == 0,
              observed.permissions == 0o700,
              observed.links == 5,
              observed.flags == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func identity(_ value: stat) throws
        -> PrimeR19SplitDirectoryIdentity
    {
        guard value.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR) else {
            throw PrimeR19SplitFailure.rejected
        }
        return PrimeR19SplitDirectoryIdentity(
            device: UInt64(UInt32(bitPattern: value.st_dev)),
            inode: UInt64(value.st_ino),
            uid: UInt32(value.st_uid),
            gid: UInt32(value.st_gid),
            permissions: UInt16(value.st_mode & mode_t(0o7777)),
            links: UInt64(value.st_nlink),
            flags: value.st_flags
        )
    }
}

private struct PrimeR19SplitUniqueProcess: Equatable {
    let uuid: [UInt8]
    let uniqueID: UInt64
    let parentUniqueID: UInt64
    let idVersion: UInt32
    let originalParentIDVersion: UInt32
}

private struct PrimeR19SplitShortProcess: Equatable {
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

private struct PrimeR19SplitJoinedProcess: Equatable {
    let unique: PrimeR19SplitUniqueProcess
    let short: PrimeR19SplitShortProcess
    let session: pid_t
    let processGroup: pid_t

    func sameIdentity(as other: Self) -> Bool {
        unique == other.unique
            && short.sameIdentity(as: other.short)
            && session == other.session
            && processGroup == other.processGroup
    }
}

private enum PrimeR19SplitProcessProof {
    private static let uniqueFlavor: Int32 = 17
    private static let shortFlavor: Int32 = 13
    private static let uniqueBytes = 56
    private static let shortBytes = 64
    private static let attempts = 4

    static func join(_ pid: pid_t) throws -> PrimeR19SplitJoinedProcess? {
        for _ in 0..<attempts {
            guard let unique0 = try readUnique(pid),
                  let short0 = try readShort(pid),
                  let session0 = readDomain(pid, session: true),
                  let group0 = readDomain(pid, session: false),
                  let session1 = readDomain(pid, session: true),
                  let group1 = readDomain(pid, session: false),
                  let short1 = try readShort(pid),
                  let unique1 = try readUnique(pid)
            else {
                return nil
            }
            if unique0 == unique1,
               short0.sameIdentity(as: short1),
               session0 == session1,
               group0 == group1,
               group0 == pid_t(short0.processGroup),
               group1 == pid_t(short1.processGroup) {
                return PrimeR19SplitJoinedProcess(
                    unique: unique1,
                    short: short1,
                    session: session1,
                    processGroup: group1
                )
            }
        }
        throw PrimeR19SplitFailure.rejected
    }

    static func requireStoppedPrivateChild(
        _ joined: PrimeR19SplitJoinedProcess,
        pid: pid_t
    ) throws {
        let uid = UInt32(geteuid())
        let gid = UInt32(getegid())
        guard joined.short.pid == UInt32(pid),
              joined.short.parentPID == UInt32(getpid()),
              joined.short.processGroup == UInt32(pid),
              joined.short.status == 4,
              joined.session == pid,
              joined.processGroup == pid,
              joined.short.userID == uid,
              joined.short.realUserID == uid,
              joined.short.savedUserID == uid,
              joined.short.groupID == gid,
              joined.short.realGroupID == gid,
              joined.short.savedGroupID == gid
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    static func requireSamePrivateChild(
        _ joined: PrimeR19SplitJoinedProcess,
        baseline: PrimeR19SplitJoinedProcess,
        pid: pid_t
    ) throws {
        guard joined.sameIdentity(as: baseline),
              joined.short.pid == UInt32(pid),
              joined.short.parentPID == UInt32(getpid()),
              joined.processGroup == pid,
              joined.session == pid
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func readUnique(_ pid: pid_t) throws
        -> PrimeR19SplitUniqueProcess?
    {
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
            throw PrimeR19SplitFailure.rejected
        }
        return PrimeR19SplitUniqueProcess(
            uuid: Array(bytes[0..<16]),
            uniqueID: little64(bytes, 16),
            parentUniqueID: little64(bytes, 24),
            idVersion: little32(bytes, 32),
            originalParentIDVersion: little32(bytes, 36)
        )
    }

    private static func readShort(_ pid: pid_t) throws
        -> PrimeR19SplitShortProcess?
    {
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
            throw PrimeR19SplitFailure.rejected
        }
        return PrimeR19SplitShortProcess(
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

    private static func readDomain(_ pid: pid_t, session: Bool) -> pid_t? {
        errno = 0
        let result = session ? getsid(pid) : getpgid(pid)
        return result >= 0 ? result : nil
    }

    static func little32(_ bytes: [UInt8], _ offset: Int) -> UInt32 {
        UInt32(bytes[offset])
            | UInt32(bytes[offset + 1]) << 8
            | UInt32(bytes[offset + 2]) << 16
            | UInt32(bytes[offset + 3]) << 24
    }

    static func little64(_ bytes: [UInt8], _ offset: Int) -> UInt64 {
        UInt64(little32(bytes, offset))
            | UInt64(little32(bytes, offset + 4)) << 32
    }
}

private struct PrimeR19SplitMappedImage: Equatable {
    let device: UInt32
    let inode: UInt64
    let mainRegionCount: Int
    let queryCount: Int
    let executableOffsetZero: Bool
}

private enum PrimeR19SplitMappedInspector {
    private static let regionBytes = 1_272
    private static let queryCap = 65_536

    static func inspect<Fixed: PrimeR19SplitFixedMappedType>(
        pid: pid_t,
        descriptor: Int32,
        fixed: Fixed.Type
    ) throws -> PrimeR19SplitMappedImage {
        guard MemoryLayout<proc_regionwithpathinfo>.size == regionBytes,
              descriptor >= 3,
              Fixed.fixedMappedPathBytes.count < 1_024,
              let before = try PrimeR19SplitProcessProof.join(pid)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        var held = stat()
        guard fstat(descriptor, &held) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        let pathAuthority = Fixed.fixedMappedPathBytes
        let deviceAuthority = UInt32(bitPattern: held.st_dev)
        let inodeAuthority = UInt64(held.st_ino)
        var address: UInt64 = 0
        var mainRegions = 0
        var queries = 0
        var offsetZeroExecutable = false
        var reachedEnd = false

        while queries < queryCap {
            var bytes = [UInt8](repeating: 0, count: regionBytes)
            errno = 0
            let returned = bytes.withUnsafeMutableBytes {
                proc_pidinfo(
                    pid, PROC_PIDREGIONPATHINFO, address,
                    $0.baseAddress, Int32($0.count)
                )
            }
            let observedErrno = errno
            queries += 1
            if returned == 0 {
                guard observedErrno == EINVAL else {
                    throw PrimeR19SplitFailure.rejected
                }
                reachedEnd = true
                break
            }
            guard returned == Int32(regionBytes) else {
                throw PrimeR19SplitFailure.rejected
            }
            let protection = PrimeR19SplitProcessProof.little32(bytes, 0)
            let fileOffset = PrimeR19SplitProcessProof.little64(bytes, 16)
            let regionAddress = PrimeR19SplitProcessProof.little64(bytes, 80)
            let regionSize = PrimeR19SplitProcessProof.little64(bytes, 88)
            let device = PrimeR19SplitProcessProof.little32(bytes, 96)
            let inode = PrimeR19SplitProcessProof.little64(bytes, 104)
            guard regionAddress >= address, regionSize > 0 else {
                throw PrimeR19SplitFailure.rejected
            }
            let following = regionAddress.addingReportingOverflow(regionSize)
            guard !following.overflow,
                  following.partialValue > regionAddress,
                  following.partialValue > address
            else {
                throw PrimeR19SplitFailure.rejected
            }
            let pathStart = 248
            let pathEnd = regionBytes
            let pathField = bytes[pathStart..<pathEnd]
            guard let terminator = pathField.firstIndex(of: 0) else {
                throw PrimeR19SplitFailure.rejected
            }
            let pathMatches = Array(pathField[..<terminator]) == pathAuthority
            let vnodeMatches = device == deviceAuthority
                && inode == inodeAuthority
            if pathMatches || vnodeMatches {
                guard pathMatches, vnodeMatches else {
                    throw PrimeR19SplitFailure.rejected
                }
                mainRegions += 1
                if fileOffset == 0,
                   protection & UInt32(VM_PROT_EXECUTE) != 0 {
                    offsetZeroExecutable = true
                }
            }
            address = following.partialValue
        }
        guard reachedEnd,
              mainRegions > 0,
              offsetZeroExecutable,
              let after = try PrimeR19SplitProcessProof.join(pid),
              after.sameIdentity(as: before)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        return PrimeR19SplitMappedImage(
            device: deviceAuthority,
            inode: inodeAuthority,
            mainRegionCount: mainRegions,
            queryCount: queries,
            executableOffsetZero: offsetZeroExecutable
        )
    }
}

private struct PrimeR19SplitCWD: Equatable {
    let device: UInt32
    let inode: UInt64
}

private enum PrimeR19SplitCWDInspector {
    static func inspect(pid: pid_t, heldRoot: Int32) throws
        -> PrimeR19SplitCWD
    {
        guard MemoryLayout<proc_vnodepathinfo>.size == 2_352 else {
            throw PrimeR19SplitFailure.rejected
        }
        var root = stat()
        guard fstat(heldRoot, &root) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        let expected = PrimeR19SplitCWD(
            device: UInt32(bitPattern: root.st_dev),
            inode: UInt64(root.st_ino)
        )
        var raw = proc_vnodepathinfo()
        errno = 0
        let returned = withUnsafeMutablePointer(to: &raw) {
            proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, $0, 2_352)
        }
        let observed = raw.pvi_cdir.vip_vi.vi_stat
        guard returned == 2_352,
              observed.vst_dev == expected.device,
              observed.vst_ino == expected.inode,
              observed.vst_mode & UInt16(S_IFMT) == UInt16(S_IFDIR)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        return expected
    }
}

private final class PrimeR19SplitImageWatcher {
    private typealias DarwinKevent = Darwin.kevent
    private static let noteMask =
        UInt32(NOTE_DELETE) | UInt32(NOTE_WRITE) | UInt32(NOTE_EXTEND)
        | UInt32(NOTE_ATTRIB) | UInt32(NOTE_LINK) | UInt32(NOTE_RENAME)
        | UInt32(NOTE_REVOKE)

    private let queue: PrimeR19SplitFD
    private let descriptors: Set<Int32>
    private(set) var stickyFlags: UInt32 = 0

    init(
        owner: PrimeR19SplitHeldOwnerA,
        primitive: PrimeR19SplitHeldPrimitiveA,
        supervisor: PrimeR19SplitHeldSupervisorA,
        controller: PrimeR19SplitHeldControllerA,
        auditor: PrimeR19SplitHeldAuditorA
    ) throws {
        let all = [
            owner.descriptor.rawValue,
            primitive.descriptor.rawValue,
            supervisor.descriptor.rawValue,
            controller.descriptor.rawValue,
            auditor.descriptor.rawValue,
        ]
        guard all.allSatisfy({ $0 >= 3 }), Set(all).count == 5 else {
            throw PrimeR19SplitFailure.rejected
        }
        let queue = try PrimeR19SplitFD(kqueue())
        guard prime_driver_v2_r19_split_owner_set_cloexec(queue.rawValue) == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
        let queueFlags =
            prime_driver_v2_r19_split_owner_get_fd_flags(queue.rawValue)
        guard queueFlags >= 0, queueFlags & FD_CLOEXEC != 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        self.queue = queue
        descriptors = Set(all)
        for descriptor in all { try register(descriptor) }
        try drainNonblocking()
        guard stickyFlags == 0 else { throw PrimeR19SplitFailure.rejected }
    }

    var isZero: Bool { stickyFlags == 0 }

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
        let returned = withUnsafePointer(to: &change) { changes in
            withUnsafeMutablePointer(to: &receipt) { receipts in
                kevent(queue.rawValue, changes, 1, receipts, 1, nil)
            }
        }
        guard returned == 1,
              receipt.ident == UInt(descriptor),
              receipt.filter == Int16(EVFILT_VNODE),
              receipt.flags & UInt16(EV_ERROR) != 0,
              receipt.data == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    func drainNonblocking() throws {
        while true {
            var events = [DarwinKevent](
                repeating: DarwinKevent(),
                count: PrimeR19SplitConstants.watcherEventCap
            )
            var timeout = timespec(tv_sec: 0, tv_nsec: 0)
            errno = 0
            let returned = events.withUnsafeMutableBufferPointer {
                kevent(
                    queue.rawValue, nil, 0, $0.baseAddress,
                    Int32($0.count), &timeout
                )
            }
            if returned < 0, errno == EINTR { continue }
            guard returned >= 0 else { throw PrimeR19SplitFailure.rejected }
            if returned == 0 { return }
            for event in events.prefix(Int(returned)) {
                guard event.filter == Int16(EVFILT_VNODE),
                      descriptors.contains(Int32(event.ident)),
                      event.flags & UInt16(EV_ERROR) == 0,
                      event.fflags != 0,
                      event.fflags & ~Self.noteMask == 0
                else {
                    throw PrimeR19SplitFailure.rejected
                }
                stickyFlags |= event.fflags
            }
        }
    }
}

private final class PrimeR19SplitAuthorities {
    let root: PrimeR19SplitFD
    let privateTmp: PrimeR19SplitFD
    let null: PrimeR19SplitFD
    let owner: PrimeR19SplitHeldOwnerA
    let primitive: PrimeR19SplitHeldPrimitiveA
    let supervisor: PrimeR19SplitHeldSupervisorA
    let controller: PrimeR19SplitHeldControllerA
    let auditor: PrimeR19SplitHeldAuditorA
    let watcher: PrimeR19SplitImageWatcher
    private let ownerBuildDirectory: PrimeR19SplitDirectoryIdentity

    static func prepare() throws -> PrimeR19SplitAuthorities {
        let root = try PrimeR19SplitFD(
            prime_driver_v2_r19_split_owner_open_root_directory()
        )
        let privateTmp = try PrimeR19SplitFD(
            prime_driver_v2_r19_split_owner_open_private_tmp()
        )
        let null = try PrimeR19SplitFD(
            prime_driver_v2_r19_split_owner_open_dev_null()
        )
        try requireRoot(root.rawValue)
        try requirePrivateTmp(privateTmp.rawValue)
        try requireNull(null.rawValue)
        let ownerBuild = try PrimeR19SplitParentChain.captureOwnerBuildDirectory()
        try PrimeR19SplitParentChain.requireFixedParents(ownerBuild: ownerBuild)

        let owner = try PrimeR19SplitHeldOwnerA.open()
        let primitive = try PrimeR19SplitHeldPrimitiveA.open()
        let supervisor = try PrimeR19SplitHeldSupervisorA.open()
        let controller = try PrimeR19SplitHeldControllerA.open()
        let auditor = try PrimeR19SplitHeldAuditorA.open()
        _ = try PrimeR19SplitMappedInspector.inspect(
            pid: getpid(),
            descriptor: owner.descriptor.rawValue,
            fixed: PrimeR19SplitHeldOwnerA.self
        )
        try owner.revalidate()
        try primitive.revalidate()
        try supervisor.revalidate()
        try controller.revalidate()
        try auditor.revalidate()
        let watcher = try PrimeR19SplitImageWatcher(
            owner: owner,
            primitive: primitive,
            supervisor: supervisor,
            controller: controller,
            auditor: auditor
        )
        let result = PrimeR19SplitAuthorities(
            root: root,
            privateTmp: privateTmp,
            null: null,
            owner: owner,
            primitive: primitive,
            supervisor: supervisor,
            controller: controller,
            auditor: auditor,
            watcher: watcher,
            ownerBuildDirectory: ownerBuild
        )
        try result.revalidateAll()
        return result
    }

    private init(
        root: PrimeR19SplitFD,
        privateTmp: PrimeR19SplitFD,
        null: PrimeR19SplitFD,
        owner: PrimeR19SplitHeldOwnerA,
        primitive: PrimeR19SplitHeldPrimitiveA,
        supervisor: PrimeR19SplitHeldSupervisorA,
        controller: PrimeR19SplitHeldControllerA,
        auditor: PrimeR19SplitHeldAuditorA,
        watcher: PrimeR19SplitImageWatcher,
        ownerBuildDirectory: PrimeR19SplitDirectoryIdentity
    ) {
        self.root = root
        self.privateTmp = privateTmp
        self.null = null
        self.owner = owner
        self.primitive = primitive
        self.supervisor = supervisor
        self.controller = controller
        self.auditor = auditor
        self.watcher = watcher
        self.ownerBuildDirectory = ownerBuildDirectory
    }

    func revalidateAll() throws {
        try Self.requireRoot(root.rawValue)
        try Self.requirePrivateTmp(privateTmp.rawValue)
        try Self.requireNull(null.rawValue)
        try PrimeR19SplitParentChain.requireFixedParents(
            ownerBuild: ownerBuildDirectory
        )
        try owner.revalidate()
        try primitive.revalidate()
        try supervisor.revalidate()
        try controller.revalidate()
        try auditor.revalidate()
        try watcher.drainNonblocking()
        guard watcher.isZero else { throw PrimeR19SplitFailure.rejected }
    }

    private static func requireRoot(_ descriptor: Int32) throws {
        let descriptorFlags =
            prime_driver_v2_r19_split_owner_get_fd_flags(descriptor)
        let statusFlags =
            prime_driver_v2_r19_split_owner_get_status_flags(descriptor)
        var held = stat()
        var named = stat()
        var filesystem = statfs()
        guard descriptor >= 3,
              descriptorFlags >= 0,
              descriptorFlags & FD_CLOEXEC != 0,
              statusFlags >= 0,
              statusFlags & O_ACCMODE == O_RDONLY,
              fstat(descriptor, &held) == 0,
              "/".withCString({
                  fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              UInt64(UInt32(bitPattern: held.st_dev)) == 16_777_231,
              UInt64(held.st_ino) == 2,
              held.st_uid == 0,
              held.st_gid == 0,
              named.st_uid == 0,
              named.st_gid == 0,
              UInt16(held.st_mode & mode_t(0o7777)) == 0o755,
              UInt16(named.st_mode & mode_t(0o7777)) == 0o755,
              held.st_flags == 1_048_576,
              named.st_flags == 1_048_576,
              held.st_nlink == named.st_nlink,
              fstatfs(descriptor, &filesystem) == 0,
              filesystem.f_flags & UInt32(MNT_LOCAL) != 0,
              filesystem.f_flags & UInt32(MNT_RDONLY) != 0,
              filesystemType(filesystem) == Array("apfs".utf8)
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func requirePrivateTmp(_ descriptor: Int32) throws {
        let descriptorFlags =
            prime_driver_v2_r19_split_owner_get_fd_flags(descriptor)
        let statusFlags =
            prime_driver_v2_r19_split_owner_get_status_flags(descriptor)
        var held = stat()
        var named = stat()
        var filesystem = statfs()
        guard descriptor >= 3,
              descriptorFlags >= 0,
              descriptorFlags & FD_CLOEXEC != 0,
              statusFlags >= 0,
              statusFlags & O_ACCMODE == O_RDONLY,
              fstat(descriptor, &held) == 0,
              "/private/tmp".withCString({
                  fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              UInt64(UInt32(bitPattern: held.st_dev)) == 16_777_231,
              UInt64(held.st_ino) == 774_813,
              held.st_uid == 0,
              held.st_gid == 0,
              named.st_uid == 0,
              named.st_gid == 0,
              UInt16(held.st_mode & mode_t(0o7777)) == 0o1777,
              UInt16(named.st_mode & mode_t(0o7777)) == 0o1777,
              held.st_flags == 0,
              named.st_flags == 0,
              fstatfs(descriptor, &filesystem) == 0,
              filesystem.f_flags & UInt32(MNT_LOCAL) != 0,
              filesystemType(filesystem) == Array("apfs".utf8)
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func requireNull(_ descriptor: Int32) throws {
        let descriptorFlags =
            prime_driver_v2_r19_split_owner_get_fd_flags(descriptor)
        let statusFlags =
            prime_driver_v2_r19_split_owner_get_status_flags(descriptor)
        var held = stat()
        var named = stat()
        guard descriptor >= 3,
              descriptorFlags >= 0,
              descriptorFlags & FD_CLOEXEC != 0,
              statusFlags == O_RDONLY,
              fstat(descriptor, &held) == 0,
              "/dev/null".withCString({
                  fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFCHR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFCHR),
              UInt32(bitPattern: held.st_dev) == 3_836_289_247,
              held.st_ino == ino_t(336),
              held.st_rdev == dev_t(50_331_650),
              held.st_uid == 0,
              held.st_gid == 0,
              named.st_uid == 0,
              named.st_gid == 0,
              held.st_mode & mode_t(0o7777) == mode_t(0o666),
              named.st_mode & mode_t(0o7777) == mode_t(0o666),
              held.st_rdev == named.st_rdev,
              isatty(descriptor) == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func filesystemType(_ filesystem: statfs) -> [UInt8] {
        var field = filesystem.f_fstypename
        return withUnsafeBytes(of: &field) { Array($0.prefix { $0 != 0 }) }
    }
}

private struct PrimeR19SplitDeadline {
    let absoluteNanoseconds: UInt64

    init() throws {
        let now = DispatchTime.now().uptimeNanoseconds
        let sum = now.addingReportingOverflow(
            PrimeR19SplitConstants.deadlineNanoseconds
        )
        guard !sum.overflow else { throw PrimeR19SplitFailure.rejected }
        absoluteNanoseconds = sum.partialValue
    }

    var expired: Bool {
        DispatchTime.now().uptimeNanoseconds >= absoluteNanoseconds
    }
}

private final class PrimeR19SplitCapturePipe {
    let read: PrimeR19SplitFD
    let write: PrimeR19SplitFD

    init() throws {
        var descriptors: [Int32] = [-1, -1]
        guard descriptors.withUnsafeMutableBufferPointer({
            Darwin.pipe($0.baseAddress)
        }) == 0,
              descriptors[0] >= 3,
              descriptors[1] >= 3,
              descriptors[0] != descriptors[1]
        else {
            if descriptors[0] >= 0 { _ = Darwin.close(descriptors[0]) }
            if descriptors[1] >= 0 { _ = Darwin.close(descriptors[1]) }
            throw PrimeR19SplitFailure.rejected
        }
        let readOwner = try PrimeR19SplitFD(descriptors[0])
        let writeOwner = try PrimeR19SplitFD(descriptors[1])
        do {
            guard prime_driver_v2_r19_split_owner_set_cloexec(
                    readOwner.rawValue
                  ) == 0,
                  prime_driver_v2_r19_split_owner_set_cloexec(
                    writeOwner.rawValue
                  ) == 0,
                  prime_driver_v2_r19_split_owner_set_nonblocking(
                    readOwner.rawValue
                  ) == 0
            else {
                throw PrimeR19SplitFailure.rejected
            }
            let readFDFlags =
                prime_driver_v2_r19_split_owner_get_fd_flags(
                    readOwner.rawValue
                )
            let writeFDFlags =
                prime_driver_v2_r19_split_owner_get_fd_flags(
                    writeOwner.rawValue
                )
            guard readFDFlags >= 0,
                  writeFDFlags >= 0,
                  readFDFlags & FD_CLOEXEC != 0,
                  writeFDFlags & FD_CLOEXEC != 0,
                  prime_driver_v2_r19_split_owner_get_status_flags(
                    readOwner.rawValue
                  ) == O_RDONLY | O_NONBLOCK,
                  prime_driver_v2_r19_split_owner_get_status_flags(
                    writeOwner.rawValue
                  ) == O_WRONLY,
                  fpathconf(readOwner.rawValue, _PC_PIPE_BUF) == 512,
                  fpathconf(writeOwner.rawValue, _PC_PIPE_BUF) == 512
            else {
                throw PrimeR19SplitFailure.rejected
            }
        } catch {
            throw error
        }
        read = readOwner
        write = writeOwner
    }
}

private final class PrimeR19SplitPreparedSupervisorIngress {
    let read: PrimeR19SplitFD

    static func prepare() throws -> PrimeR19SplitPreparedSupervisorIngress {
        guard let request = Data(
            base64Encoded: PrimeR19SplitConstants.requestBase64
        ),
              request.count == PrimeR19SplitConstants.requestCount,
              request.last != 0x0a,
              PrimeR19SplitCanonical.sha256Hex(request) ==
                PrimeR19SplitConstants.requestSHA256
        else {
            throw PrimeR19SplitFailure.rejected
        }

        var descriptors: [Int32] = [-1, -1]
        guard descriptors.withUnsafeMutableBufferPointer({
            Darwin.pipe($0.baseAddress)
        }) == 0,
              descriptors[0] >= 3,
              descriptors[1] >= 3,
              descriptors[0] != descriptors[1]
        else {
            if descriptors[0] >= 0 { _ = Darwin.close(descriptors[0]) }
            if descriptors[1] >= 0 { _ = Darwin.close(descriptors[1]) }
            throw PrimeR19SplitFailure.rejected
        }
        let read = try PrimeR19SplitFD(descriptors[0])
        let write = try PrimeR19SplitFD(descriptors[1])
        do {
            guard prime_driver_v2_r19_split_owner_set_cloexec(
                    read.rawValue
                  ) == 0,
                  prime_driver_v2_r19_split_owner_set_cloexec(
                    write.rawValue
                  ) == 0,
                  prime_driver_v2_r19_split_owner_set_nonblocking(
                    write.rawValue
                  ) == 0,
                  prime_driver_v2_r19_split_owner_set_nosigpipe(
                    write.rawValue
                  ) == 0
            else {
                throw PrimeR19SplitFailure.rejected
            }
            let readFDFlags =
                prime_driver_v2_r19_split_owner_get_fd_flags(read.rawValue)
            let writeFDFlags =
                prime_driver_v2_r19_split_owner_get_fd_flags(write.rawValue)
            guard readFDFlags >= 0,
                  readFDFlags & FD_CLOEXEC != 0,
                  writeFDFlags >= 0,
                  writeFDFlags & FD_CLOEXEC != 0,
                  prime_driver_v2_r19_split_owner_get_status_flags(
                    read.rawValue
                  ) == O_RDONLY,
                  prime_driver_v2_r19_split_owner_get_status_flags(
                    write.rawValue
                  ) == O_WRONLY | O_NONBLOCK,
                  fpathconf(read.rawValue, _PC_PIPE_BUF) == 512,
                  fpathconf(write.rawValue, _PC_PIPE_BUF) == 512
            else {
                throw PrimeR19SplitFailure.rejected
            }

            // This is the sole request write entry. Short, zero, EINTR,
            // EAGAIN, or any other error is final and is never retried.
            errno = 0
            let written = request.withUnsafeBytes { raw -> Int in
                guard let base = raw.baseAddress else { return -1 }
                return Darwin.write(write.rawValue, base, request.count)
            }
            guard written == request.count else {
                throw PrimeR19SplitFailure.rejected
            }
            guard write.close() == 0 else {
                throw PrimeR19SplitFailure.rejected
            }
            return PrimeR19SplitPreparedSupervisorIngress(read: read)
        } catch {
            _ = write.close()
            _ = read.close()
            throw error
        }
    }

    private init(read: PrimeR19SplitFD) {
        self.read = read
    }
}

private struct PrimeR19SplitCaptureSnapshot {
    let retained: Data
    let totalCount: UInt64
    let sha256: String
    let overflow: Bool
    let eof: Bool

    var journalObject: [String: Any] {
        [
            "eof": eof,
            "overflow": overflow,
            "retained_base64": retained.base64EncodedString(),
            "retained_bytes": retained.count,
            "sha256": sha256,
            "total_bytes": totalCount,
        ]
    }
}

private struct PrimeR19SplitStreamCapture {
    private var retained = Data()
    private var totalCount: UInt64 = 0
    private var hasher = SHA256()
    private(set) var overflow = false
    private(set) var eof = false
    private var finalized: PrimeR19SplitCaptureSnapshot?

    mutating func drainOne(_ descriptor: Int32) throws {
        guard !eof, finalized == nil else { return }
        var buffer = [UInt8](
            repeating: 0,
            count: PrimeR19SplitConstants.streamQuantum
        )
        errno = 0
        let count = buffer.withUnsafeMutableBytes {
            Darwin.read(descriptor, $0.baseAddress, $0.count)
        }
        if count > 0 {
            let sum = totalCount.addingReportingOverflow(UInt64(count))
            guard !sum.overflow else { throw PrimeR19SplitFailure.rejected }
            totalCount = sum.partialValue
            let chunk = Data(buffer[0..<count])
            hasher.update(data: chunk)
            let available = max(
                0,
                PrimeR19SplitConstants.streamCap - retained.count
            )
            let keep = min(available, count)
            if keep > 0 { retained.append(contentsOf: buffer[0..<keep]) }
            if totalCount > UInt64(PrimeR19SplitConstants.streamCap) {
                overflow = true
            }
            return
        }
        if count == 0 {
            eof = true
            return
        }
        if errno == EAGAIN || errno == EWOULDBLOCK { return }
        throw PrimeR19SplitFailure.rejected
    }

    mutating func snapshot() throws -> PrimeR19SplitCaptureSnapshot {
        if let finalized { return finalized }
        guard eof else { throw PrimeR19SplitFailure.rejected }
        let result = PrimeR19SplitCaptureSnapshot(
            retained: retained,
            totalCount: totalCount,
            sha256: PrimeR19SplitCanonical.hex(Data(hasher.finalize())),
            overflow: overflow,
            eof: eof
        )
        finalized = result
        return result
    }
}

private final class PrimeR19SplitJournal {
    private let parent: PrimeR19SplitFD
    private let root: PrimeR19SplitFD
    private let rootDevice: dev_t
    private let rootInode: ino_t
    private var nextOrdinal: UInt32 = 0
    private var predecessor = String(repeating: "0", count: 64)
    private var leafDescriptors: [PrimeR19SplitFD] = []
    private var poisoned = false

    init(privateTmp: PrimeR19SplitFD) throws {
        guard geteuid() == 501,
              prime_driver_v2_r19_split_owner_create_owner_root(
                privateTmp.rawValue
              ) == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
        let root = try PrimeR19SplitFD(
            prime_driver_v2_r19_split_owner_open_owner_root(
                privateTmp.rawValue
            )
        )
        var held = stat()
        var named = stat()
        var parentMetadata = stat()
        guard fstat(privateTmp.rawValue, &parentMetadata) == 0,
              fstat(root.rawValue, &held) == 0,
              PrimeR19SplitConstants.ownerRootLeaf.withCString({
                  fstatat(
                      privateTmp.rawValue,
                      $0,
                      &named,
                      AT_SYMLINK_NOFOLLOW
                  )
              }) == 0,
              Self.validRoot(held, permissions: 0o700),
              Self.validRoot(named, permissions: 0o700),
              held.st_dev == named.st_dev,
              held.st_ino == named.st_ino,
              held.st_dev == parentMetadata.st_dev,
              try Self.inventory(root.rawValue).isEmpty,
              Self.synchronize(root.rawValue),
              Self.synchronize(privateTmp.rawValue)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        parent = privateTmp
        self.root = root
        rootDevice = held.st_dev
        rootInode = held.st_ino
    }

    func publish(_ ordinal: UInt32, payload: [String: Any]) throws {
        guard !poisoned,
              ordinal == nextOrdinal,
              ordinal < UInt32(PrimeR19SplitConstants.journalLeaves.count),
              try validHeldAndNamedRoot(permissions: 0o700)
        else {
            poisoned = true
            throw PrimeR19SplitFailure.rejected
        }
        let raw =
            prime_driver_v2_r19_split_owner_create_poisoned_journal_leaf(
                root.rawValue,
                ordinal
            )
        let leaf: PrimeR19SplitFD
        do {
            leaf = try PrimeR19SplitFD(raw)
        } catch {
            poisoned = true
            throw error
        }
        leafDescriptors.append(leaf)
        do {
            var initialHeld = stat()
            var initialNamed = stat()
            let leafName = PrimeR19SplitConstants.journalLeaves[Int(ordinal)]
            guard fstat(leaf.rawValue, &initialHeld) == 0,
                  leafName.withCString({
                    fstatat(root.rawValue, $0, &initialNamed, AT_SYMLINK_NOFOLLOW)
                  }) == 0,
                  Self.validPoisonedLeaf(initialHeld),
                  Self.validPoisonedLeaf(initialNamed),
                  initialHeld.st_dev == initialNamed.st_dev,
                  initialHeld.st_ino == initialNamed.st_ino
            else {
                throw PrimeR19SplitFailure.rejected
            }
            let payloadBytes = try PrimeR19SplitCanonical.encode(payload)
            let payloadDigest = PrimeR19SplitCanonical.sha256Hex(payloadBytes)
            let frameObject: [String: Any] = [
                "payload": payload,
                "payload_sha256": payloadDigest,
                "predecessor_frame_sha256": predecessor,
            ]
            var frame = try PrimeR19SplitCanonical.encode(frameObject)
            frame.append(0x0a)
            guard frame.count <= PrimeR19SplitConstants.frameCap else {
                throw PrimeR19SplitFailure.rejected
            }
            try Self.writeAndReadBack(frame, descriptor: leaf.rawValue)
            guard prime_driver_v2_r19_split_owner_full_fsync(
                    leaf.rawValue
                  ) == 0,
                  fchmod(leaf.rawValue, mode_t(0o400)) == 0
            else {
                throw PrimeR19SplitFailure.rejected
            }
            try Self.readBackExact(frame, descriptor: leaf.rawValue)
            var heldMetadata = stat()
            var namedMetadata = stat()
            guard fstat(leaf.rawValue, &heldMetadata) == 0,
                  leafName.withCString({
                      fstatat(
                          root.rawValue,
                          $0,
                          &namedMetadata,
                          AT_SYMLINK_NOFOLLOW
                      )
                  }) == 0,
                  Self.validLeaf(heldMetadata),
                  Self.validLeaf(namedMetadata),
                  heldMetadata.st_dev == namedMetadata.st_dev,
                  heldMetadata.st_ino == namedMetadata.st_ino,
                  prime_driver_v2_r19_split_owner_full_fsync(
                    leaf.rawValue
                  ) == 0,
                  Self.synchronize(root.rawValue),
                  Self.synchronize(parent.rawValue),
                  try validHeldAndNamedRoot(permissions: 0o700)
            else {
                throw PrimeR19SplitFailure.rejected
            }
            predecessor = PrimeR19SplitCanonical.sha256Hex(frame)
            nextOrdinal += 1
        } catch {
            poisoned = true
            throw error
        }
    }

    func seal() throws {
        guard !poisoned,
              nextOrdinal == 9,
              leafDescriptors.count == 9,
              try Self.inventory(root.rawValue) ==
                PrimeR19SplitConstants.journalLeaves.sorted()
        else {
            poisoned = true
            throw PrimeR19SplitFailure.rejected
        }
        for (index, leafName) in
            PrimeR19SplitConstants.journalLeaves.enumerated()
        {
            var named = stat()
            var held = stat()
            guard leafName.withCString({
                fstatat(root.rawValue, $0, &named, AT_SYMLINK_NOFOLLOW)
            }) == 0,
                  Self.validLeaf(named),
                  fstat(leafDescriptors[index].rawValue, &held) == 0,
                  Self.validLeaf(held),
                  held.st_dev == named.st_dev,
                  held.st_ino == named.st_ino
            else {
                poisoned = true
                throw PrimeR19SplitFailure.rejected
            }
        }
        guard fchmod(root.rawValue, mode_t(0o500)) == 0,
              try validHeldAndNamedRoot(permissions: 0o500),
              try Self.inventory(root.rawValue) ==
                PrimeR19SplitConstants.journalLeaves.sorted()
        else {
            poisoned = true
            throw PrimeR19SplitFailure.rejected
        }
        for (index, leafName) in
            PrimeR19SplitConstants.journalLeaves.enumerated()
        {
            var named = stat()
            var held = stat()
            guard leafName.withCString({
                fstatat(root.rawValue, $0, &named, AT_SYMLINK_NOFOLLOW)
            }) == 0,
                  fstat(leafDescriptors[index].rawValue, &held) == 0,
                  Self.validLeaf(named),
                  Self.validLeaf(held),
                  held.st_dev == named.st_dev,
                  held.st_ino == named.st_ino
            else {
                poisoned = true
                throw PrimeR19SplitFailure.rejected
            }
        }
        guard Self.synchronize(root.rawValue),
              Self.synchronize(parent.rawValue),
              try validHeldAndNamedRoot(permissions: 0o500)
        else {
            poisoned = true
            throw PrimeR19SplitFailure.rejected
        }
    }

    var rootIdentity: [String: Any] {
        [
            "device": UInt64(UInt32(bitPattern: rootDevice)),
            "inode": UInt64(rootInode),
            "path": PrimeR19SplitConstants.ownerRootPath,
        ]
    }

    private func validHeldAndNamedRoot(permissions: UInt16) throws -> Bool {
        var held = stat()
        var named = stat()
        guard fstat(root.rawValue, &held) == 0,
              PrimeR19SplitConstants.ownerRootLeaf.withCString({
                  fstatat(parent.rawValue, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0
        else {
            return false
        }
        return held.st_dev == rootDevice
            && held.st_ino == rootInode
            && held.st_dev == named.st_dev
            && held.st_ino == named.st_ino
            && Self.validRoot(held, permissions: permissions)
            && Self.validRoot(named, permissions: permissions)
    }

    private static func validRoot(_ value: stat, permissions: UInt16) -> Bool {
        value.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR)
            && value.st_uid == 501
            && value.st_gid == 0
            && UInt16(value.st_mode & mode_t(0o7777)) == permissions
            && value.st_flags == 0
    }

    private static func validLeaf(_ value: stat) -> Bool {
        value.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
            && value.st_uid == 501
            && value.st_gid == 0
            && value.st_nlink == 1
            && UInt16(value.st_mode & mode_t(0o7777)) == 0o400
            && value.st_flags == 0
            && value.st_size > 0
            && value.st_size <= off_t(PrimeR19SplitConstants.frameCap)
    }

    private static func validPoisonedLeaf(_ value: stat) -> Bool {
        value.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
            && value.st_uid == 501
            && value.st_gid == 0
            && value.st_nlink == 1
            && UInt16(value.st_mode & mode_t(0o7777)) == 0
            && value.st_flags == 0
            && value.st_size == 0
    }

    private static func inventory(_ directory: Int32) throws -> [String] {
        let duplicate = dup(directory)
        guard duplicate >= 3 else {
            if duplicate >= 0 { _ = Darwin.close(duplicate) }
            throw PrimeR19SplitFailure.rejected
        }
        guard prime_driver_v2_r19_split_owner_set_cloexec(duplicate) == 0
        else {
            _ = Darwin.close(duplicate)
            throw PrimeR19SplitFailure.rejected
        }
        let duplicateFlags =
            prime_driver_v2_r19_split_owner_get_fd_flags(duplicate)
        guard duplicateFlags >= 0, duplicateFlags & FD_CLOEXEC != 0 else {
            _ = Darwin.close(duplicate)
            throw PrimeR19SplitFailure.rejected
        }
        guard let stream = fdopendir(duplicate) else {
            _ = Darwin.close(duplicate)
            throw PrimeR19SplitFailure.rejected
        }
        defer { _ = closedir(stream) }
        var names = [String]()
        while true {
            errno = 0
            guard let entry = readdir(stream) else {
                guard errno == 0 else { throw PrimeR19SplitFailure.rejected }
                break
            }
            var nameField = entry.pointee.d_name
            let name = withUnsafePointer(to: &nameField) {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    String(validatingCString: $0)
                }
            }
            guard let name else { throw PrimeR19SplitFailure.rejected }
            if name == "." || name == ".." { continue }
            guard !name.isEmpty, !name.contains("/") else {
                throw PrimeR19SplitFailure.rejected
            }
            names.append(name)
        }
        guard Set(names).count == names.count else {
            throw PrimeR19SplitFailure.rejected
        }
        return names.sorted()
    }

    private static func writeAndReadBack(
        _ bytes: Data,
        descriptor: Int32
    ) throws {
        var offset = 0
        try bytes.withUnsafeBytes { raw in
            guard let base = raw.baseAddress else {
                throw PrimeR19SplitFailure.rejected
            }
            while offset < raw.count {
                errno = 0
                let count = pwrite(
                    descriptor,
                    base.advanced(by: offset),
                    raw.count - offset,
                    off_t(offset)
                )
                if count < 0, errno == EINTR { continue }
                guard count > 0 else { throw PrimeR19SplitFailure.rejected }
                offset += count
            }
        }
        try readBackExact(bytes, descriptor: descriptor)
    }

    private static func readBackExact(
        _ bytes: Data,
        descriptor: Int32
    ) throws {
        var observed = Data(count: bytes.count)
        var readOffset = 0
        try observed.withUnsafeMutableBytes { raw in
            guard let base = raw.baseAddress else {
                throw PrimeR19SplitFailure.rejected
            }
            while readOffset < raw.count {
                errno = 0
                let count = pread(
                    descriptor,
                    base.advanced(by: readOffset),
                    raw.count - readOffset,
                    off_t(readOffset)
                )
                if count < 0, errno == EINTR { continue }
                guard count > 0 else { throw PrimeR19SplitFailure.rejected }
                readOffset += count
            }
        }
        var extra: UInt8 = 0
        guard observed == bytes,
              pread(descriptor, &extra, 1, off_t(bytes.count)) == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func synchronize(_ descriptor: Int32) -> Bool {
        prime_driver_v2_r19_split_owner_full_fsync(descriptor) == 0
    }
}

private enum PrimeR19SplitSelectedAction: String, Equatable {
    case continued = "SIGCONT"
    case killedPreCONT = "SIGKILL_POSITIVE_PID_PRECONT"
    case terminalBeforeAction = "ZERO_SIGNAL_TERMINAL_BEFORE_ACTION"
}

private struct PrimeR19SplitActionObservation {
    let selected: PrimeR19SplitSelectedAction
    let enteredAt: UInt64?
    let returnValue: Int32?
    let returnedAt: UInt64?

    var journalObject: [String: Any] {
        [
            "entered_at_uptime_nanoseconds":
                enteredAt.map { $0 as Any } ?? NSNull(),
            "entered_signal_calls": selected == .terminalBeforeAction ? 0 : 1,
            "return_value": returnValue.map { $0 as Any } ?? NSNull(),
            "returned_at_uptime_nanoseconds":
                returnedAt.map { $0 as Any } ?? NSNull(),
            "selected_action": selected.rawValue,
        ]
    }
}

private struct PrimeR19SplitVnodeIdentity: Equatable {
    let device: UInt32
    let inode: UInt64
    let fileType: UInt16
    let rdevice: UInt32

    static func capture(_ descriptor: Int32) throws
        -> PrimeR19SplitVnodeIdentity
    {
        var value = stat()
        guard fstat(descriptor, &value) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        return PrimeR19SplitVnodeIdentity(
            device: UInt32(bitPattern: value.st_dev),
            inode: UInt64(value.st_ino),
            fileType: UInt16(value.st_mode & mode_t(S_IFMT)),
            rdevice: UInt32(bitPattern: value.st_rdev)
        )
    }
}

private protocol PrimeR19SplitFixedChildFDType {
    static var standardInputIsPipe: Bool { get }
}

private enum PrimeR19SplitChildFDInspector {
    static func requireExact<Fixed: PrimeR19SplitFixedChildFDType>(
        _ fixed: Fixed.Type,
        pid: pid_t,
        input: PrimeR19SplitVnodeIdentity,
        output: PrimeR19SplitVnodeIdentity,
        error: PrimeR19SplitVnodeIdentity
    ) throws {
        guard MemoryLayout<proc_fdinfo>.size == 8,
              let before = try PrimeR19SplitProcessProof.join(pid)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        var descriptors = [proc_fdinfo](repeating: proc_fdinfo(), count: 4)
        let returned = descriptors.withUnsafeMutableBufferPointer {
            proc_pidinfo(
                pid,
                PROC_PIDLISTFDS,
                0,
                $0.baseAddress,
                Int32($0.count * MemoryLayout<proc_fdinfo>.stride)
            )
        }
        guard returned == 24 else { throw PrimeR19SplitFailure.rejected }
        let observed = Array(descriptors.prefix(3)).sorted {
            $0.proc_fd < $1.proc_fd
        }
        guard observed.map(\.proc_fd) == [0, 1, 2],
              observed[0].proc_fdtype ==
                (Fixed.standardInputIsPipe
                    ? UInt32(PROX_FDTYPE_PIPE) : UInt32(PROX_FDTYPE_VNODE)),
              observed[1].proc_fdtype == UInt32(PROX_FDTYPE_PIPE),
              observed[2].proc_fdtype == UInt32(PROX_FDTYPE_PIPE)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        if Fixed.standardInputIsPipe {
            try requirePipe(pid: pid, fd: 0, expected: input, write: false)
        } else {
            try requireVnode(pid: pid, fd: 0, expected: input)
        }
        try requirePipe(pid: pid, fd: 1, expected: output, write: true)
        try requirePipe(pid: pid, fd: 2, expected: error, write: true)
        guard input != output,
              input != error,
              output != error,
              let after = try PrimeR19SplitProcessProof.join(pid),
              after.sameIdentity(as: before)
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func requirePipe(
        pid: pid_t,
        fd: Int32,
        expected: PrimeR19SplitVnodeIdentity,
        write: Bool
    ) throws {
        var info = pipe_fdinfo()
        let returned = withUnsafeMutablePointer(to: &info) {
            proc_pidfdinfo(
                pid,
                fd,
                PROC_PIDFDPIPEINFO,
                $0,
                Int32(MemoryLayout<pipe_fdinfo>.size)
            )
        }
        let value = info.pipeinfo.pipe_stat
        // libproc reports the kernel fileglob FREAD/FWRITE bits, not the
        // userspace O_RDONLY/O_WRONLY encoding returned by F_GETFL.
        let exactOpenFlags: UInt32 = write ? 0x2 : 0x1
        guard returned == Int32(MemoryLayout<pipe_fdinfo>.size),
              info.pfi.fi_type == PROX_FDTYPE_PIPE,
              info.pfi.fi_guardflags == 0,
              info.pfi.fi_status & UInt32(PROC_FP_CLEXEC) == 0,
              info.pfi.fi_openflags == exactOpenFlags,
              value.vst_dev == expected.device,
              value.vst_ino == expected.inode,
              value.vst_mode & UInt16(S_IFMT) == expected.fileType,
              expected.fileType == UInt16(S_IFIFO)
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private static func requireVnode(
        pid: pid_t,
        fd: Int32,
        expected: PrimeR19SplitVnodeIdentity
    ) throws {
        var info = vnode_fdinfo()
        let returned = withUnsafeMutablePointer(to: &info) {
            proc_pidfdinfo(
                pid,
                fd,
                PROC_PIDFDVNODEINFO,
                $0,
                Int32(MemoryLayout<vnode_fdinfo>.size)
            )
        }
        let value = info.pvi.vi_stat
        guard returned == Int32(MemoryLayout<vnode_fdinfo>.size),
              info.pfi.fi_type == PROX_FDTYPE_VNODE,
              info.pfi.fi_guardflags == 0,
              info.pfi.fi_status & UInt32(PROC_FP_CLEXEC) == 0,
              info.pfi.fi_openflags == 0x1,
              value.vst_dev == expected.device,
              value.vst_ino == expected.inode,
              value.vst_mode & UInt16(S_IFMT) == expected.fileType,
              value.vst_rdev == expected.rdevice,
              expected.fileType == UInt16(S_IFCHR)
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }
}

private struct PrimeR19SplitSpawnedChild {
    let pid: pid_t
    let output: PrimeR19SplitCapturePipe
    let error: PrimeR19SplitCapturePipe
    let queue: PrimeR19SplitFD
    let deadline: PrimeR19SplitDeadline
    let spawnReturnExpired: Bool
    let inputIdentity: PrimeR19SplitVnodeIdentity
    let outputIdentity: PrimeR19SplitVnodeIdentity
    let errorIdentity: PrimeR19SplitVnodeIdentity
}

private struct PrimeR19SplitDirectEvidence {
    let action: PrimeR19SplitActionObservation
    let rawWaitStatus: Int32
    let output: PrimeR19SplitCaptureSnapshot
    let error: PrimeR19SplitCaptureSnapshot
    let watcherFlags: UInt32
    let querySaturated: Bool
    let nonleaderCount: Int
    let terminalBeforeAction: Bool

    var exitedNormally: Bool { rawWaitStatus & 0x7f == 0 }
    var exitCode: Int32? {
        exitedNormally ? (rawWaitStatus >> 8) & 0xff : nil
    }

    var journalObject: [String: Any] {
        [
            "action": action.journalObject,
            "error": error.journalObject,
            "exit_code": exitCode.map { $0 as Any } ?? NSNull(),
            "exited_normally": exitedNormally,
            "joined_nonleader_count": nonleaderCount,
            "output": output.journalObject,
            "query_saturated": querySaturated,
            "raw_wait_status": rawWaitStatus,
            "terminal_before_action": terminalBeforeAction,
            "watcher_sticky_flags": watcherFlags,
        ]
    }
}

private protocol PrimeR19SplitFixedRole:
    PrimeR19SplitFixedMappedType,
    PrimeR19SplitFixedChildFDType
{
    static var name: String { get }
    static var actionOrdinal: UInt32 { get }
    static var terminalOrdinal: UInt32 { get }
}

private enum PrimeR19SplitPrimitiveRole: PrimeR19SplitFixedRole {
    static let name = "PRIMITIVE_A"
    static let actionOrdinal: UInt32 = 3
    static let terminalOrdinal: UInt32 = 4
    static let fixedMappedPathBytes =
        Array(PrimeR19SplitConstants.primitivePath.utf8)
    static let standardInputIsPipe = false
}

private enum PrimeR19SplitSupervisorRole: PrimeR19SplitFixedRole {
    static let name = "SUPERVISOR_A"
    static let actionOrdinal: UInt32 = 6
    static let terminalOrdinal: UInt32 = 7
    static let fixedMappedPathBytes =
        Array(PrimeR19SplitConstants.supervisorPath.utf8)
    static let standardInputIsPipe = true
}

private final class PrimeR19SplitDirectChild<Role: PrimeR19SplitFixedRole> {
    private typealias DarwinKevent = Darwin.kevent

    private let spawned: PrimeR19SplitSpawnedChild
    private let imageDescriptor: Int32
    private let authorities: PrimeR19SplitAuthorities
    private let journal: PrimeR19SplitJournal

    private var baseline: PrimeR19SplitJoinedProcess?
    private var outputCapture = PrimeR19SplitStreamCapture()
    private var errorCapture = PrimeR19SplitStreamCapture()
    private var outputFirst = true
    private var observersRegistered = false
    private var filtersRemoved = false
    private var terminalObserved = false
    private var action: PrimeR19SplitActionObservation?
    private var enteredSignalCalls = 0
    private var actionLeafPublished = false
    private var resumed = false
    private var waitpidEntries = 0
    private var watcherPoison = false
    private var querySaturated = false
    private var joinedNonleaderCount = 0

    init(
        spawned: PrimeR19SplitSpawnedChild,
        imageDescriptor: Int32,
        authorities: PrimeR19SplitAuthorities,
        journal: PrimeR19SplitJournal
    ) {
        self.spawned = spawned
        self.imageDescriptor = imageDescriptor
        self.authorities = authorities
        self.journal = journal
    }

    func run() throws -> PrimeR19SplitDirectEvidence {
        do {
            try registerObservers()
            try authorities.watcher.drainNonblocking()
        } catch {
            retainForever()
        }

        do {
            guard let initial = try PrimeR19SplitProcessProof.join(spawned.pid)
            else {
                retainForever()
            }
            try requirePrivateChild(initial)
            baseline = initial
            try serviceTurn(blocking: false)

            if terminalObserved {
                return try finishTerminalBeforeAction()
            }
            // A nonterminal child that is not already kernel-stopped has
            // crossed the START_SUSPENDED boundary without a safe action.
            // It is retained indefinitely; it is never allowed to run to a
            // later terminal state and be reclassified as terminal-before-
            // action.
            guard initial.short.status == 4 else { retainForever() }

            try PrimeR19SplitProcessProof.requireStoppedPrivateChild(
                initial,
                pid: spawned.pid
            )
            var certifiedReject = false
            do {
                _ = try PrimeR19SplitCWDInspector.inspect(
                    pid: spawned.pid,
                    heldRoot: authorities.root.rawValue
                )
                _ = try PrimeR19SplitMappedInspector.inspect(
                    pid: spawned.pid,
                    descriptor: imageDescriptor,
                    fixed: Role.self
                )
                try PrimeR19SplitChildFDInspector.requireExact(
                    Role.self,
                    pid: spawned.pid,
                    input: spawned.inputIdentity,
                    output: spawned.outputIdentity,
                    error: spawned.errorIdentity
                )
            } catch {
                certifiedReject = true
            }
            guard let afterJoin = try PrimeR19SplitProcessProof.join(
                spawned.pid
            ) else {
                retainForever()
            }
            try PrimeR19SplitProcessProof.requireStoppedPrivateChild(
                afterJoin,
                pid: spawned.pid
            )
            try PrimeR19SplitProcessProof.requireSamePrivateChild(
                afterJoin,
                baseline: initial,
                pid: spawned.pid
            )
            baseline = afterJoin
            do {
                try authorities.revalidateAll()
                try serviceTurn(blocking: false)
            } catch {
                certifiedReject = true
            }

            if terminalObserved {
                return try finishTerminalBeforeAction()
            }

            if spawned.spawnReturnExpired || spawned.deadline.expired {
                certifiedReject = true
            }
            if authorities.watcher.stickyFlags != 0 {
                certifiedReject = true
                watcherPoison = true
            }

            let actionPayload: [String: Any] = [
                "conditional_rule":
                    "FINAL_MONOTONIC_CHECK_SELECTS_KILL_IFF_EXPIRED_OR_CERTIFIED_PRECONT_REJECT_ELSE_CONT",
                "deadline_uptime_nanoseconds":
                    spawned.deadline.absoluteNanoseconds,
                "role": Role.name,
                "schema":
                    "prime_driver_v2_r19_split_owner_action_commitment_v1",
                "status": "DURABLE_CONDITIONAL_PRECONT_ACTION_RULE",
            ]
            do {
                try journal.publish(Role.actionOrdinal, payload: actionPayload)
                actionLeafPublished = true
            } catch {
                // Once a suspended child exists, a missing action leaf commits
                // zero signal calls and permanent ownership of the child.
                retainForever()
            }

            do {
                try authorities.revalidateAll()
                try serviceTurn(blocking: false)
            } catch {
                certifiedReject = true
            }
            if terminalObserved {
                // The conditional action leaf exists, but no action has yet
                // entered. Retain rather than write a contradictory variant.
                retainForever()
            }
            if spawned.deadline.expired { certifiedReject = true }

            guard let finalJoin = try PrimeR19SplitProcessProof.join(spawned.pid),
                  let baseline
            else {
                retainForever()
            }
            try PrimeR19SplitProcessProof.requireStoppedPrivateChild(
                finalJoin,
                pid: spawned.pid
            )
            try PrimeR19SplitProcessProof.requireSamePrivateChild(
                finalJoin,
                baseline: baseline,
                pid: spawned.pid
            )
            self.baseline = finalJoin
            do {
                try authorities.watcher.drainNonblocking()
            } catch {
                certifiedReject = true
            }
            if authorities.watcher.stickyFlags != 0 {
                watcherPoison = true
                certifiedReject = true
            }
            if spawned.deadline.expired { certifiedReject = true }

            // The selected call is committed in process-local state before
            // entering exactly one syscall. No second deadline check follows.
            let selected: PrimeR19SplitSelectedAction =
                (certifiedReject || spawned.deadline.expired)
                ? .killedPreCONT : .continued
            let enteredAt = DispatchTime.now().uptimeNanoseconds
            enteredSignalCalls += 1
            guard enteredSignalCalls == 1 else { retainForever() }
            action = PrimeR19SplitActionObservation(
                selected: selected,
                enteredAt: enteredAt,
                returnValue: nil,
                returnedAt: nil
            )
            if selected == .continued { resumed = true }
            let returnValue = Darwin.kill(
                spawned.pid,
                selected == .continued ? SIGCONT : SIGKILL
            )
            let returnedAt = DispatchTime.now().uptimeNanoseconds
            action = PrimeR19SplitActionObservation(
                selected: selected,
                enteredAt: enteredAt,
                returnValue: returnValue,
                returnedAt: returnedAt
            )
            guard returnValue == 0, returnedAt >= enteredAt else {
                retainForever()
            }

            try awaitTerminalAndEOF()
            let evidence = try reapAndConserve(terminalBeforeAction: false)
            if evidence.action.selected == .continued,
               (watcherPoison || evidence.watcherFlags != 0) {
                retainForever()
            }
            return evidence
        } catch {
            // The zero-call recovery branch is available only at the two
            // explicit points where NOTE_EXIT has already been observed.
            // Any proof, observation, or journal ambiguity before action is
            // retained indefinitely and cannot wait for a future exit to
            // manufacture a terminal-before-action classification.
            retainForever()
        }
    }

    private func finishTerminalBeforeAction() throws
        -> PrimeR19SplitDirectEvidence
    {
        guard action == nil else { retainForever() }
        guard enteredSignalCalls == 0 else { retainForever() }
        let payload: [String: Any] = [
            "entered_signal_calls": 0,
            "role": Role.name,
            "schema":
                "prime_driver_v2_r19_split_owner_action_commitment_v1",
            "selected_action":
                PrimeR19SplitSelectedAction.terminalBeforeAction.rawValue,
            "status": "TERMINAL_BEFORE_ACTION_ZERO_SIGNAL_CALLS",
        ]
        do {
            try journal.publish(Role.actionOrdinal, payload: payload)
            actionLeafPublished = true
        } catch {
            retainForever()
        }
        action = PrimeR19SplitActionObservation(
            selected: .terminalBeforeAction,
            enteredAt: nil,
            returnValue: nil,
            returnedAt: nil
        )
        try awaitTerminalAndEOF()
        return try reapAndConserve(terminalBeforeAction: true)
    }

    private func requirePrivateChild(
        _ joined: PrimeR19SplitJoinedProcess
    ) throws {
        let uid = UInt32(geteuid())
        let gid = UInt32(getegid())
        guard joined.short.pid == UInt32(spawned.pid),
              joined.short.parentPID == UInt32(getpid()),
              joined.short.processGroup == UInt32(spawned.pid),
              joined.processGroup == spawned.pid,
              joined.session == spawned.pid,
              joined.short.userID == uid,
              joined.short.realUserID == uid,
              joined.short.savedUserID == uid,
              joined.short.groupID == gid,
              joined.short.realGroupID == gid,
              joined.short.savedGroupID == gid
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private func registerObservers() throws {
        guard !observersRegistered else {
            throw PrimeR19SplitFailure.rejected
        }
        var changes = [
            DarwinKevent(
                ident: UInt(spawned.output.read.rawValue),
                filter: Int16(EVFILT_READ),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE)
                    | UInt16(EV_CLEAR) | UInt16(EV_RECEIPT),
                fflags: 0,
                data: 0,
                udata: nil
            ),
            DarwinKevent(
                ident: UInt(spawned.error.read.rawValue),
                filter: Int16(EVFILT_READ),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE)
                    | UInt16(EV_CLEAR) | UInt16(EV_RECEIPT),
                fflags: 0,
                data: 0,
                udata: nil
            ),
            DarwinKevent(
                ident: UInt(spawned.pid),
                filter: Int16(EVFILT_PROC),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE)
                    | UInt16(EV_CLEAR) | UInt16(EV_RECEIPT),
                fflags: UInt32(NOTE_EXIT),
                data: 0,
                udata: nil
            ),
        ]
        var receipts = [DarwinKevent](repeating: DarwinKevent(), count: 3)
        let returned = changes.withUnsafeMutableBufferPointer { changes in
            receipts.withUnsafeMutableBufferPointer { receipts in
                kevent(
                    spawned.queue.rawValue,
                    changes.baseAddress,
                    Int32(changes.count),
                    receipts.baseAddress,
                    Int32(receipts.count),
                    nil
                )
            }
        }
        guard returned == 3 else { throw PrimeR19SplitFailure.rejected }
        for index in changes.indices {
            guard receipts[index].ident == changes[index].ident,
                  receipts[index].filter == changes[index].filter,
                  receipts[index].flags & UInt16(EV_ERROR) != 0,
                  receipts[index].data == 0
            else {
                throw PrimeR19SplitFailure.rejected
            }
        }
        observersRegistered = true
    }

    private func serviceTurn(blocking: Bool) throws {
        if outputFirst {
            try outputCapture.drainOne(spawned.output.read.rawValue)
            try errorCapture.drainOne(spawned.error.read.rawValue)
        } else {
            try errorCapture.drainOne(spawned.error.read.rawValue)
            try outputCapture.drainOne(spawned.output.read.rawValue)
        }
        outputFirst.toggle()
        try authorities.watcher.drainNonblocking()
        if authorities.watcher.stickyFlags != 0 {
            watcherPoison = true
        }

        var events = [DarwinKevent](
            repeating: DarwinKevent(),
            count: PrimeR19SplitConstants.watcherEventCap
        )
        var timeout = blocking
            ? timespec(tv_sec: 1, tv_nsec: 0)
            : timespec(tv_sec: 0, tv_nsec: 0)
        errno = 0
        let returned = events.withUnsafeMutableBufferPointer {
            kevent(
                spawned.queue.rawValue,
                nil,
                0,
                $0.baseAddress,
                Int32($0.count),
                &timeout
            )
        }
        if returned < 0, errno == EINTR { return }
        guard returned >= 0 else { throw PrimeR19SplitFailure.rejected }
        for event in events.prefix(Int(returned)) {
            guard event.flags & UInt16(EV_ERROR) == 0 else {
                throw PrimeR19SplitFailure.rejected
            }
            if event.filter == Int16(EVFILT_PROC),
               event.ident == UInt(spawned.pid),
               event.fflags & UInt32(NOTE_EXIT) != 0,
               event.fflags & ~UInt32(NOTE_EXIT) == 0 {
                terminalObserved = true
                continue
            }
            if event.filter == Int16(EVFILT_READ),
               event.ident == UInt(spawned.output.read.rawValue)
                || event.ident == UInt(spawned.error.read.rawValue) {
                continue
            }
            throw PrimeR19SplitFailure.rejected
        }
    }

    private func awaitTerminalAndEOF() throws {
        while !terminalObserved || !outputCapture.eof || !errorCapture.eof {
            do {
                try serviceTurn(blocking: true)
            } catch {
                retainForever()
            }
        }
    }

    private func leaderOnlyCensus() throws -> Bool {
        guard terminalObserved,
              outputCapture.eof,
              errorCapture.eof,
              let baseline,
              let leaderBefore = try PrimeR19SplitProcessProof.join(spawned.pid)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        try PrimeR19SplitProcessProof.requireSamePrivateChild(
            leaderBefore,
            baseline: baseline,
            pid: spawned.pid
        )
        var identifiers = [pid_t](
            repeating: 0,
            count: PrimeR19SplitConstants.groupPIDCapacity
        )
        errno = 0
        let returned = identifiers.withUnsafeMutableBytes {
            proc_listpids(
                UInt32(PROC_PGRP_ONLY),
                UInt32(spawned.pid),
                $0.baseAddress,
                Int32($0.count)
            )
        }
        let capacity = identifiers.count * MemoryLayout<pid_t>.stride
        if returned >= Int32(capacity) { querySaturated = true }
        guard returned > 0,
              Int(returned) < capacity,
              Int(returned) % MemoryLayout<pid_t>.stride == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
        let count = Int(returned) / MemoryLayout<pid_t>.stride
        let listed = Array(identifiers.prefix(count))
        guard !listed.isEmpty,
              listed.allSatisfy({ $0 > 0 }),
              Set(listed).count == listed.count,
              listed.filter({ $0 == spawned.pid }).count == 1
        else {
            throw PrimeR19SplitFailure.rejected
        }
        let nonleaders = listed.filter { $0 != spawned.pid }
        for member in nonleaders {
            guard let joined = try PrimeR19SplitProcessProof.join(member),
                  joined.processGroup == spawned.pid,
                  joined.session == baseline.session
            else {
                throw PrimeR19SplitFailure.rejected
            }
        }
        guard let leaderAfter = try PrimeR19SplitProcessProof.join(spawned.pid)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        try PrimeR19SplitProcessProof.requireSamePrivateChild(
            leaderAfter,
            baseline: baseline,
            pid: spawned.pid
        )
        guard leaderAfter.sameIdentity(as: leaderBefore) else {
            throw PrimeR19SplitFailure.rejected
        }
        joinedNonleaderCount = nonleaders.count
        return nonleaders.isEmpty
    }

    private func reapAndConserve(terminalBeforeAction: Bool) throws
        -> PrimeR19SplitDirectEvidence
    {
        var consecutiveLeaderOnly = 0
        while consecutiveLeaderOnly < 2 {
            do {
                if try leaderOnlyCensus() {
                    consecutiveLeaderOnly += 1
                } else {
                    consecutiveLeaderOnly = 0
                }
            } catch {
                retainForever()
            }
            if consecutiveLeaderOnly < 2 {
                try serviceTurn(blocking: true)
            }
        }
        guard !querySaturated else { retainForever() }

        var status: Int32 = 0
        waitpidEntries += 1
        errno = 0
        let reaped = Darwin.waitpid(spawned.pid, &status, 0)
        guard waitpidEntries == 1, reaped == spawned.pid else {
            retainForever()
        }

        var probes = [Bool]()
        probes.reserveCapacity(2)
        for _ in 0..<2 {
            errno = 0
            let result = Darwin.kill(-spawned.pid, 0)
            let observedErrno = errno
            probes.append(result == -1 && observedErrno == ESRCH)
        }
        guard probes == [true, true] else { retainForever() }

        let output = try outputCapture.snapshot()
        let error = try errorCapture.snapshot()
        let selectedAction: PrimeR19SplitActionObservation
        if let action {
            selectedAction = action
        } else {
            retainForever()
        }
        try removeObservers()
        guard spawned.output.read.close() == 0,
              spawned.error.read.close() == 0,
              spawned.queue.close() == 0
        else {
            retainForever()
        }
        return PrimeR19SplitDirectEvidence(
            action: selectedAction,
            rawWaitStatus: status,
            output: output,
            error: error,
            watcherFlags: authorities.watcher.stickyFlags,
            querySaturated: querySaturated,
            nonleaderCount: joinedNonleaderCount,
            terminalBeforeAction: terminalBeforeAction
        )
    }

    private func removeObservers() throws {
        guard observersRegistered, !filtersRemoved else {
            throw PrimeR19SplitFailure.rejected
        }
        var changes = [
            DarwinKevent(
                ident: UInt(spawned.output.read.rawValue),
                filter: Int16(EVFILT_READ),
                flags: UInt16(EV_DELETE) | UInt16(EV_RECEIPT),
                fflags: 0,
                data: 0,
                udata: nil
            ),
            DarwinKevent(
                ident: UInt(spawned.error.read.rawValue),
                filter: Int16(EVFILT_READ),
                flags: UInt16(EV_DELETE) | UInt16(EV_RECEIPT),
                fflags: 0,
                data: 0,
                udata: nil
            ),
            DarwinKevent(
                ident: UInt(spawned.pid),
                filter: Int16(EVFILT_PROC),
                flags: UInt16(EV_DELETE) | UInt16(EV_RECEIPT),
                fflags: 0,
                data: 0,
                udata: nil
            ),
        ]
        var receipts = [DarwinKevent](repeating: DarwinKevent(), count: 3)
        let returned = changes.withUnsafeMutableBufferPointer { changes in
            receipts.withUnsafeMutableBufferPointer { receipts in
                kevent(
                    spawned.queue.rawValue,
                    changes.baseAddress,
                    Int32(changes.count),
                    receipts.baseAddress,
                    Int32(receipts.count),
                    nil
                )
            }
        }
        guard returned == 3 else { throw PrimeR19SplitFailure.rejected }
        for index in changes.indices {
            let removalAccepted = index < 2
                ? receipts[index].data == 0
                : receipts[index].data == 0
                    || receipts[index].data == Int(ENOENT)
            guard receipts[index].ident == changes[index].ident,
                  receipts[index].filter == changes[index].filter,
                  receipts[index].flags & UInt16(EV_ERROR) != 0,
                  removalAccepted
            else {
                throw PrimeR19SplitFailure.rejected
            }
        }
        filtersRemoved = true
    }

    private func retainForever() -> Never {
        while true {
            // Preserve bounded drain/watch observation without trusting the
            // child kqueue as the liveness clock. EOF, NOTE_EXIT, or a broken
            // queue can otherwise make kevent return immediately forever.
            try? serviceTurn(blocking: false)
            primeR19SplitPauseOneSecond()
        }
    }
}

private struct PrimeR19SplitPrimitiveCapability {
    fileprivate let evidence: PrimeR19SplitDirectEvidence

    var isDirectCandidate: Bool {
        evidence.action.selected == .continued
            && evidence.action.returnValue == 0
            && !evidence.terminalBeforeAction
            && evidence.exitedNormally
            && evidence.exitCode == 0
            && evidence.output.eof
            && evidence.error.eof
            && !evidence.output.overflow
            && !evidence.error.overflow
            && evidence.output.totalCount == 0
            && evidence.error.totalCount == 0
            && evidence.watcherFlags == 0
            && !evidence.querySaturated
            && evidence.nonleaderCount == 0
    }
}

private enum PrimeR19SplitSupervisorDisposition: Equatable {
    case candidate
    case knownConservedFailure
    case unsafePostCONT
}

private struct PrimeR19SplitSupervisorCapability {
    fileprivate let evidence: PrimeR19SplitDirectEvidence

    var disposition: PrimeR19SplitSupervisorDisposition {
        guard evidence.watcherFlags == 0,
              !evidence.querySaturated,
              evidence.nonleaderCount == 0,
              evidence.output.eof,
              evidence.error.eof,
              !evidence.output.overflow,
              !evidence.error.overflow
        else {
            return .unsafePostCONT
        }
        if evidence.action.selected != .continued {
            return .knownConservedFailure
        }
        guard evidence.action.returnValue == 0,
              !evidence.terminalBeforeAction,
              evidence.exitedNormally,
              let exitCode = evidence.exitCode
        else {
            return .unsafePostCONT
        }
        if exitCode == 0,
           evidence.output.totalCount >= 1,
           evidence.output.totalCount <= 4_096,
           evidence.output.retained.last == 0x0a,
           evidence.error.totalCount == 0 {
            return .candidate
        }
        if exitCode == 70 { return .knownConservedFailure }
        return .unsafePostCONT
    }
}

private enum PrimeR19SplitOwnerResult {
    case candidate
    case knownConservedFailure
}

private func primeR19SplitRetainForever() -> Never {
    while true {
        primeR19SplitPauseOneSecond()
    }
}

private func primeR19SplitPauseOneSecond() {
    while true {
        var timeout = timespec(tv_sec: 1, tv_nsec: 0)
        errno = 0
        let result = Darwin.pselect(0, nil, nil, nil, &timeout, nil)
        if result == 0 { return }
        if result < 0, errno == EINTR { continue }
        // A fixed nfds=0, valid-timespec pselect has no expected non-EINTR
        // error. Retain a second queue-independent wait rather than spinning
        // if the platform nevertheless rejects it.
        _ = Darwin.sleep(1)
        return
    }
}

private final class PrimeR19SplitOwner {
    private let journal: PrimeR19SplitJournal
    private let authorities: PrimeR19SplitAuthorities
    private var primitiveSpawnDeadline: PrimeR19SplitDeadline?
    private var supervisorSpawnDeadline: PrimeR19SplitDeadline?

    static func run() throws -> PrimeR19SplitOwnerResult {
        try PrimeR19SplitIngress.requireClosedOwnerIngress()
        _ = umask(mode_t(0o077))

        let bootstrapPrivateTmp = try PrimeR19SplitFD(
            prime_driver_v2_r19_split_owner_open_private_tmp()
        )
        try PrimeR19SplitAuthorities.requireBootstrapPrivateTmp(
            bootstrapPrivateTmp.rawValue
        )
        try PrimeR19SplitNamespace.requireAllInitiallyAbsentTwice(
            bootstrapPrivateTmp.rawValue
        )

        let journal = try PrimeR19SplitJournal(privateTmp: bootstrapPrivateTmp)
        guard let ownerProcess = try PrimeR19SplitProcessProof.join(getpid()),
              ownerProcess.short.pid == UInt32(getpid())
        else {
            throw PrimeR19SplitFailure.rejected
        }
        try journal.publish(
            0,
            payload: [
                "authority_closure_authorized": false,
                "authority_vector": "00000000",
                "direct_child_maximum": 2,
                "gate_e_clearance": 0,
                "owner_pid_generation_unique_id":
                    ownerProcess.unique.uniqueID,
                "root": journal.rootIdentity,
                "schema": "prime_driver_v2_r19_split_owner_intent_v1",
                "scientific_authorities_closed": 0,
                "status": "R19_SPLIT_STREAM_OWNER_INTENT_CONSUMED",
            ]
        )

        let authorities = try PrimeR19SplitAuthorities.prepare()
        let owner = PrimeR19SplitOwner(
            journal: journal,
            authorities: authorities
        )
        try journal.publish(
            1,
            payload: [
                "auditor_a": authorities.auditor.observedIdentity,
                "controller_a": authorities.controller.observedIdentity,
                "owner_a_observed_baseline": authorities.owner.observedIdentity,
                "primitive_a": authorities.primitive.observedIdentity,
                "schema": "prime_driver_v2_r19_split_owner_bound_v1",
                "status": "FIVE_A_IMAGES_HELD_JOINED_WATCHED",
                "supervisor_a": authorities.supervisor.observedIdentity,
                "watcher_sticky_flags": authorities.watcher.stickyFlags,
            ]
        )

        let primitive = try owner.spawnPrimitiveA()
        guard primitive.isDirectCandidate else {
            throw PrimeR19SplitFailure.rejected
        }

        let supervisor = try owner.spawnSupervisorA()
        switch supervisor.disposition {
        case .candidate:
            try authorities.revalidateAll()
            try journal.publish(
                8,
                payload: [
                    "authority_closure_authorized": false,
                    "authority_vector": "00000000",
                    "gate_e_clearance": 0,
                    "gate_e_mechanics_outcome": "ABSTAIN",
                    "gate_e_promotion_authorized": false,
                    "gate_e_scientific_outcome": "ABSTAIN",
                    "schema": "prime_driver_v2_r19_split_owner_terminal_v1",
                    "scientific_authorities_closed": 0,
                    "status": "SEALED_LOCAL_MECHANICS_SPLIT_CAPTURE_CANDIDATE_ONLY",
                ]
            )
            try authorities.revalidateAll()
            try journal.seal()
            return .candidate
        case .knownConservedFailure:
            try authorities.revalidateAll()
            try journal.publish(
                8,
                payload: [
                    "authority_closure_authorized": false,
                    "authority_vector": "00000000",
                    "gate_e_clearance": 0,
                    "gate_e_mechanics_outcome": "ABSTAIN",
                    "gate_e_promotion_authorized": false,
                    "gate_e_scientific_outcome": "ABSTAIN",
                    "schema": "prime_driver_v2_r19_split_owner_terminal_v1",
                    "scientific_authorities_closed": 0,
                    "status": "KNOWN_CONSERVED_REJECTION_NEVER_PASS",
                ]
            )
            try authorities.revalidateAll()
            try journal.seal()
            return .knownConservedFailure
        case .unsafePostCONT:
            primeR19SplitRetainForever()
        }
    }

    private init(
        journal: PrimeR19SplitJournal,
        authorities: PrimeR19SplitAuthorities
    ) {
        self.journal = journal
        self.authorities = authorities
        primitiveSpawnDeadline = nil
        supervisorSpawnDeadline = nil
    }

    private func spawnPrimitiveA() throws -> PrimeR19SplitPrimitiveCapability {
        try PrimeR19SplitNamespace.requirePrimitiveAbsent(
            authorities.privateTmp.rawValue
        )
        try authorities.revalidateAll()
        let output = try PrimeR19SplitCapturePipe()
        let error = try PrimeR19SplitCapturePipe()
        let inputIdentity = try PrimeR19SplitVnodeIdentity.capture(
            authorities.null.rawValue
        )
        let outputIdentity = try requireCapturePipeIdentity(output)
        let errorIdentity = try requireCapturePipeIdentity(error)
        guard outputIdentity != errorIdentity else {
            throw PrimeR19SplitFailure.rejected
        }
        let queue = try prepareChildQueue()
        let deadline = try PrimeR19SplitDeadline()
        guard primitiveSpawnDeadline == nil else {
            throw PrimeR19SplitFailure.rejected
        }
        primitiveSpawnDeadline = deadline
        defer { primitiveSpawnDeadline = nil }
        guard !deadline.expired else { throw PrimeR19SplitFailure.rejected }
        try journal.publish(
            2,
            payload: [
                "deadline_uptime_nanoseconds": deadline.absoluteNanoseconds,
                "image": authorities.primitive.observedIdentity,
                "role": PrimeR19SplitPrimitiveRole.name,
                "schema":
                    "prime_driver_v2_r19_split_owner_spawn_commitment_v1",
                "status": "ONE_FIXED_SUSPENDED_POSIX_SPAWN_COMMITTED",
            ]
        )
        guard !deadline.expired else { throw PrimeR19SplitFailure.rejected }

        let childPID = try spawnPrimitiveProcess(
            output: output,
            error: error
        )
        let expiredOnReturn = deadline.expired
        guard output.write.close() == 0, error.write.close() == 0 else {
            primeR19SplitRetainForever()
        }
        let spawned = PrimeR19SplitSpawnedChild(
            pid: childPID,
            output: output,
            error: error,
            queue: queue,
            deadline: deadline,
            spawnReturnExpired: expiredOnReturn,
            inputIdentity: inputIdentity,
            outputIdentity: outputIdentity,
            errorIdentity: errorIdentity
        )
        let child = PrimeR19SplitDirectChild<PrimeR19SplitPrimitiveRole>(
            spawned: spawned,
            imageDescriptor: authorities.primitive.descriptor.rawValue,
            authorities: authorities,
            journal: journal
        )
        let evidence = try child.run()
        let capability = PrimeR19SplitPrimitiveCapability(evidence: evidence)
        try authorities.revalidateAll()
        try journal.publish(
            4,
            payload: [
                "direct_evidence": evidence.journalObject,
                "role": PrimeR19SplitPrimitiveRole.name,
                "schema": "prime_driver_v2_r19_split_owner_terminal_role_v1",
                "status": capability.isDirectCandidate
                    ? "DIRECT_PRIMITIVE_CANDIDATE"
                    : "DIRECT_PRIMITIVE_CONSERVED_FAILURE",
            ]
        )
        return capability
    }

    private func spawnSupervisorA() throws
        -> PrimeR19SplitSupervisorCapability
    {
        try PrimeR19SplitNamespace.requireSupervisorAbsent(
            authorities.privateTmp.rawValue
        )
        try authorities.revalidateAll()
        let ingress: PrimeR19SplitPreparedSupervisorIngress
        do {
            ingress = try PrimeR19SplitPreparedSupervisorIngress.prepare()
        } catch {
            // The single prefill is consumed; no Supervisor spawn follows.
            throw PrimeR19SplitFailure.rejected
        }
        let output = try PrimeR19SplitCapturePipe()
        let error = try PrimeR19SplitCapturePipe()
        let inputIdentity = try PrimeR19SplitVnodeIdentity.capture(
            ingress.read.rawValue
        )
        let outputIdentity = try requireCapturePipeIdentity(output)
        let errorIdentity = try requireCapturePipeIdentity(error)
        guard outputIdentity != errorIdentity else {
            throw PrimeR19SplitFailure.rejected
        }
        let queue = try prepareChildQueue()
        let deadline = try PrimeR19SplitDeadline()
        guard supervisorSpawnDeadline == nil else {
            throw PrimeR19SplitFailure.rejected
        }
        supervisorSpawnDeadline = deadline
        defer { supervisorSpawnDeadline = nil }
        guard !deadline.expired else { throw PrimeR19SplitFailure.rejected }
        try journal.publish(
            5,
            payload: [
                "deadline_uptime_nanoseconds": deadline.absoluteNanoseconds,
                "image": authorities.supervisor.observedIdentity,
                "request_bytes": PrimeR19SplitConstants.requestCount,
                "request_sha256": PrimeR19SplitConstants.requestSHA256,
                "role": PrimeR19SplitSupervisorRole.name,
                "schema":
                    "prime_driver_v2_r19_split_owner_spawn_commitment_v1",
                "status": "ONE_FIXED_SUSPENDED_POSIX_SPAWN_COMMITTED",
            ]
        )
        guard !deadline.expired else { throw PrimeR19SplitFailure.rejected }

        let childPID = try spawnSupervisorProcess(
            ingress: ingress,
            output: output,
            error: error
        )
        let expiredOnReturn = deadline.expired
        guard ingress.read.close() == 0,
              output.write.close() == 0,
              error.write.close() == 0
        else {
            primeR19SplitRetainForever()
        }
        let spawned = PrimeR19SplitSpawnedChild(
            pid: childPID,
            output: output,
            error: error,
            queue: queue,
            deadline: deadline,
            spawnReturnExpired: expiredOnReturn,
            inputIdentity: inputIdentity,
            outputIdentity: outputIdentity,
            errorIdentity: errorIdentity
        )
        let child = PrimeR19SplitDirectChild<PrimeR19SplitSupervisorRole>(
            spawned: spawned,
            imageDescriptor: authorities.supervisor.descriptor.rawValue,
            authorities: authorities,
            journal: journal
        )
        let evidence = try child.run()
        try authorities.revalidateAll()
        let capability = PrimeR19SplitSupervisorCapability(evidence: evidence)
        try journal.publish(
            7,
            payload: [
                "direct_evidence": evidence.journalObject,
                "role": PrimeR19SplitSupervisorRole.name,
                "schema": "prime_driver_v2_r19_split_owner_terminal_role_v1",
                "status": dispositionName(capability.disposition),
            ]
        )
        if capability.disposition == .unsafePostCONT {
            primeR19SplitRetainForever()
        }
        return capability
    }

    private func prepareChildQueue() throws -> PrimeR19SplitFD {
        let queue = try PrimeR19SplitFD(kqueue())
        guard prime_driver_v2_r19_split_owner_set_cloexec(queue.rawValue) == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
        let flags = prime_driver_v2_r19_split_owner_get_fd_flags(
            queue.rawValue
        )
        guard flags >= 0, flags & FD_CLOEXEC != 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        return queue
    }

    private func requireCapturePipeIdentity(
        _ pipe: PrimeR19SplitCapturePipe
    ) throws -> PrimeR19SplitVnodeIdentity {
        let read = try PrimeR19SplitVnodeIdentity.capture(pipe.read.rawValue)
        let write = try PrimeR19SplitVnodeIdentity.capture(pipe.write.rawValue)
        guard read == write, read.fileType == UInt16(S_IFIFO) else {
            throw PrimeR19SplitFailure.rejected
        }
        return read
    }

    private func spawnPrimitiveProcess(
        output: PrimeR19SplitCapturePipe,
        error: PrimeR19SplitCapturePipe
    ) throws -> pid_t {
        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        guard posix_spawn_file_actions_init(&actions) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        defer { _ = posix_spawn_file_actions_destroy(&actions) }
        guard posix_spawnattr_init(&attributes) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        defer { _ = posix_spawnattr_destroy(&attributes) }
        let actionResults = [
            posix_spawn_file_actions_addinherit_np(
                &actions, authorities.root.rawValue
            ),
            posix_spawn_file_actions_addfchdir_np(
                &actions, authorities.root.rawValue
            ),
            posix_spawn_file_actions_addclose(
                &actions, authorities.root.rawValue
            ),
            posix_spawn_file_actions_adddup2(
                &actions, authorities.null.rawValue, STDIN_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, authorities.null.rawValue
            ),
            posix_spawn_file_actions_addclose(
                &actions, output.read.rawValue
            ),
            posix_spawn_file_actions_adddup2(
                &actions, output.write.rawValue, STDOUT_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, output.write.rawValue
            ),
            posix_spawn_file_actions_addclose(
                &actions, error.read.rawValue
            ),
            posix_spawn_file_actions_adddup2(
                &actions, error.write.rawValue, STDERR_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, error.write.rawValue
            ),
        ]
        guard actionResults.allSatisfy({ $0 == 0 }) else {
            throw PrimeR19SplitFailure.rejected
        }
        try prepareSpawnAttributes(&attributes)
        guard let argumentZero = strdup(PrimeR19SplitConstants.primitivePath)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        defer { free(argumentZero) }
        var arguments: [UnsafeMutablePointer<CChar>?] = [argumentZero, nil]
        var environment: [UnsafeMutablePointer<CChar>?] = [nil]
        var child: pid_t = 0
        guard let primitiveSpawnDeadline, !primitiveSpawnDeadline.expired else {
            throw PrimeR19SplitFailure.rejected
        }
        let result = PrimeR19SplitConstants.primitivePath.withCString { path in
            arguments.withUnsafeMutableBufferPointer { arguments in
                environment.withUnsafeMutableBufferPointer { environment in
                    posix_spawn(
                        &child,
                        path,
                        &actions,
                        &attributes,
                        arguments.baseAddress,
                        environment.baseAddress
                    )
                }
            }
        }
        guard result == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        guard child > 0 else { primeR19SplitRetainForever() }
        return child
    }

    private func spawnSupervisorProcess(
        ingress: PrimeR19SplitPreparedSupervisorIngress,
        output: PrimeR19SplitCapturePipe,
        error: PrimeR19SplitCapturePipe
    ) throws -> pid_t {
        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        guard posix_spawn_file_actions_init(&actions) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        defer { _ = posix_spawn_file_actions_destroy(&actions) }
        guard posix_spawnattr_init(&attributes) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        defer { _ = posix_spawnattr_destroy(&attributes) }
        let actionResults = [
            posix_spawn_file_actions_addinherit_np(
                &actions, authorities.root.rawValue
            ),
            posix_spawn_file_actions_addfchdir_np(
                &actions, authorities.root.rawValue
            ),
            posix_spawn_file_actions_addclose(
                &actions, authorities.root.rawValue
            ),
            posix_spawn_file_actions_adddup2(
                &actions, ingress.read.rawValue, STDIN_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, ingress.read.rawValue
            ),
            posix_spawn_file_actions_addclose(
                &actions, output.read.rawValue
            ),
            posix_spawn_file_actions_adddup2(
                &actions, output.write.rawValue, STDOUT_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, output.write.rawValue
            ),
            posix_spawn_file_actions_addclose(
                &actions, error.read.rawValue
            ),
            posix_spawn_file_actions_adddup2(
                &actions, error.write.rawValue, STDERR_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, error.write.rawValue
            ),
        ]
        guard actionResults.allSatisfy({ $0 == 0 }) else {
            throw PrimeR19SplitFailure.rejected
        }
        try prepareSpawnAttributes(&attributes)
        guard let argumentZero = strdup(PrimeR19SplitConstants.supervisorPath)
        else {
            throw PrimeR19SplitFailure.rejected
        }
        defer { free(argumentZero) }
        var arguments: [UnsafeMutablePointer<CChar>?] = [argumentZero, nil]
        var environment: [UnsafeMutablePointer<CChar>?] = [nil]
        var child: pid_t = 0
        guard let supervisorSpawnDeadline, !supervisorSpawnDeadline.expired else {
            throw PrimeR19SplitFailure.rejected
        }
        let result = PrimeR19SplitConstants.supervisorPath.withCString { path in
            arguments.withUnsafeMutableBufferPointer { arguments in
                environment.withUnsafeMutableBufferPointer { environment in
                    posix_spawn(
                        &child,
                        path,
                        &actions,
                        &attributes,
                        arguments.baseAddress,
                        environment.baseAddress
                    )
                }
            }
        }
        guard result == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        guard child > 0 else { primeR19SplitRetainForever() }
        return child
    }

    private func prepareSpawnAttributes(
        _ attributes: inout posix_spawnattr_t?
    ) throws {
        var defaults = sigset_t()
        guard sigemptyset(&defaults) == 0 else {
            throw PrimeR19SplitFailure.rejected
        }
        for signal in 1..<NSIG where signal != SIGKILL && signal != SIGSTOP {
            guard sigaddset(&defaults, signal) == 0 else {
                throw PrimeR19SplitFailure.rejected
            }
        }
        var mask = sigset_t()
        guard sigemptyset(&mask) == 0,
              posix_spawnattr_setsigdefault(&attributes, &defaults) == 0,
              posix_spawnattr_setsigmask(&attributes, &mask) == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
        let flags = UInt16(POSIX_SPAWN_START_SUSPENDED)
            | UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
            | UInt16(POSIX_SPAWN_SETSID)
            | UInt16(POSIX_SPAWN_SETSIGDEF)
            | UInt16(POSIX_SPAWN_SETSIGMASK)
        guard flags == 0x448c,
              posix_spawnattr_setflags(
                &attributes,
                Int16(bitPattern: flags)
              ) == 0
        else {
            throw PrimeR19SplitFailure.rejected
        }
    }

    private func dispositionName(
        _ disposition: PrimeR19SplitSupervisorDisposition
    ) -> String {
        switch disposition {
        case .candidate:
            return "SUPERVISOR_SPLIT_CAPTURE_CANDIDATE"
        case .knownConservedFailure:
            return "SUPERVISOR_KNOWN_CONSERVED_FAILURE"
        case .unsafePostCONT:
            return "SUPERVISOR_UNSAFE_POSTCONT_INDEFINITE"
        }
    }
}

private extension PrimeR19SplitAuthorities {
    static func requireBootstrapPrivateTmp(_ descriptor: Int32) throws {
        try requirePrivateTmp(descriptor)
    }
}

@main
private struct PrimeDriverV2R19NativeLeafSplitStreamOwner {
    static func main() {
        do {
            switch try PrimeR19SplitOwner.run() {
            case .candidate:
                Darwin._exit(0)
            case .knownConservedFailure:
                Darwin._exit(70)
            }
        } catch {
            Darwin._exit(70)
        }
    }
}
