// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin
import Foundation

@_silgen_name("_NSGetEnviron")
private func primeR19ArchiveNSGetEnviron()
    -> UnsafeMutablePointer<
        UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
    >

private enum PrimeR19ArchiveFailure: Error {
    case rejected
}

private final class PrimeR19ArchiveFD {
    private(set) var rawValue: Int32

    init(_ rawValue: Int32) throws {
        guard rawValue >= 3 else {
            if rawValue >= 0 { _ = Darwin.close(rawValue) }
            throw PrimeR19ArchiveFailure.rejected
        }
        self.rawValue = rawValue
        let flags = fcntl(rawValue, F_GETFD)
        guard flags >= 0, flags & FD_CLOEXEC != 0 else {
            _ = Darwin.close(rawValue)
            self.rawValue = -1
            throw PrimeR19ArchiveFailure.rejected
        }
    }

    deinit {
        if rawValue >= 0 { _ = Darwin.close(rawValue) }
    }
}

private indirect enum PrimeR19JSON {
    case array([PrimeR19JSON])
    case boolean(Bool)
    case integer(Int)
    case object([String: PrimeR19JSON])
    case string(String)

    var canonical: Data {
        Data(canonicalString.utf8)
    }

    private var canonicalString: String {
        switch self {
        case .array(let values):
            return "[" + values.map(\.canonicalString).joined(separator: ",") + "]"
        case .boolean(let value):
            return value ? "true" : "false"
        case .integer(let value):
            return String(value)
        case .object(let values):
            let keys = values.keys.sorted {
                Array($0.utf8).lexicographicallyPrecedes(Array($1.utf8))
            }
            return "{" + keys.map {
                PrimeR19JSON.escape($0) + ":" + values[$0]!.canonicalString
            }.joined(separator: ",") + "}"
        case .string(let value):
            return Self.escape(value)
        }
    }

    private static func escape(_ value: String) -> String {
        var result = "\""
        for scalar in value.unicodeScalars {
            switch scalar.value {
            case 0x22: result += "\\\""
            case 0x5C: result += "\\\\"
            case 0x08: result += "\\b"
            case 0x0C: result += "\\f"
            case 0x0A: result += "\\n"
            case 0x0D: result += "\\r"
            case 0x09: result += "\\t"
            case 0..<0x20:
                let hex = String(scalar.value, radix: 16)
                result += "\\u" + String(repeating: "0", count: 4 - hex.count) + hex
            default:
                result.unicodeScalars.append(scalar)
            }
        }
        result += "\""
        return result
    }
}

private struct PrimeR19ArchiveAggregate: Equatable {
    let bytes: UInt64
    let directories: Int
    let files: Int
    let topInventory: [String]
}

private struct PrimeR19ArchiveFacts: Equatable {
    let bytes: UInt64?
    let device: UInt64
    let flags: UInt64?
    let gid: UInt64
    let inode: UInt64
    let mode: UInt16
    let nlink: UInt64
    let sha256: String?
    let type: String
    let uid: UInt64
    let aggregate: PrimeR19ArchiveAggregate?

    var vnode: PrimeR19ArchiveVnode {
        PrimeR19ArchiveVnode(device: device, inode: inode)
    }
}

private struct PrimeR19ArchiveVnode: Hashable {
    let device: UInt64
    let inode: UInt64
}

private struct PrimeR19ArchiveXattr: Equatable {
    let name: Data
    let value: Data
}

private struct PrimeR19ExpectedNode {
    let id: String
    let ordinal: UInt32
    let path: String
    let facts: PrimeR19ArchiveFacts
}

private final class PrimeR19HeldNode {
    let expected: PrimeR19ExpectedNode
    let descriptor: PrimeR19ArchiveFD
    let admission: PrimeR19ArchiveFacts
    let admissionBytes: Data?
    let admissionXattrs: [PrimeR19ArchiveXattr]?

    init(
        expected: PrimeR19ExpectedNode,
        descriptor: PrimeR19ArchiveFD,
        admission: PrimeR19ArchiveFacts,
        admissionBytes: Data?,
        admissionXattrs: [PrimeR19ArchiveXattr]?
    ) {
        self.expected = expected
        self.descriptor = descriptor
        self.admission = admission
        self.admissionBytes = admissionBytes
        self.admissionXattrs = admissionXattrs
    }
}

private struct PrimeR19ArchiveLeaf {
    let descriptor: PrimeR19ArchiveFD
    let facts: PrimeR19ArchiveFacts
    let ordinal: UInt32
    let relativePath: String
    let xattrs: [PrimeR19ArchiveXattr]?
}

private enum PrimeR19ArchiveConstants {
    static let parentPath = "/Users/ergentics/Documents"
    static let stagingLeaf =
        ".PrimeValidationLocalArchive-R19-ce8e584e-f6a03155d136-staging"
    static let finalLeaf =
        "PrimeValidationLocalArchive-R19-ce8e584e-f6a03155d136"
    static let stagingPath = parentPath + "/" + stagingLeaf
    static let finalPath = parentPath + "/" + finalLeaf
    static let payloadHashRule =
        "SHA256_COMPACT_RECURSIVE_LEXICOGRAPHIC_KEYS_UTF8_NO_TRAILING_LF_EXCLUDING_PAYLOAD_SHA256_FIELD"
    static let copyOriginOrdinals: [UInt32] = [2, 3, 5, 6, 7, 8, 9]
    static let copyPaths = [
        "a/owner-object.o",
        "a/owner-product.macho",
        "b/owner-object.o",
        "b/owner-product.macho",
        "source/owner-fixed-openat.c",
        "source/owner-fixed-openat.h",
        "source/owner.swift",
    ]
    static let leafPaths = copyPaths + [
        "data/00-control.json",
        "data/01-crs12-frame.json",
        "data/02-origins-a.json",
        "data/03-origins-b.json",
        "data/04-artifacts.json",
        "data/05-macho.json",
        "data/06-linked-images.json",
        "data/07-undefined-symbols.json",
        "data/08-codesign.json",
        "data/09-xattrs.json",
        "data/10-toolchain.json",
        "data/11-manifest-index.json",
    ]
    static let directoryInventories = [
        ["owner-object.o", "owner-product.macho"],
        ["owner-object.o", "owner-product.macho"],
        [
            "00-control.json", "01-crs12-frame.json", "02-origins-a.json",
            "03-origins-b.json", "04-artifacts.json", "05-macho.json",
            "06-linked-images.json", "07-undefined-symbols.json",
            "08-codesign.json", "09-xattrs.json", "10-toolchain.json",
            "11-manifest-index.json",
        ],
        ["owner-fixed-openat.c", "owner-fixed-openat.h", "owner.swift"],
    ]
    static let originEntityIDs = [
        "A_OBJECT", "A_PRODUCT", "B_OBJECT", "B_PRODUCT",
        "SOURCE_C", "SOURCE_H", "SOURCE_SWIFT",
    ]
    static let volumeUUID: [UInt8] = [
        0x82, 0x04, 0x01, 0xBD, 0x3E, 0xA5, 0x49, 0x0A,
        0x86, 0x37, 0x9B, 0x48, 0x67, 0xF9, 0xD8, 0x0F,
    ]
    static let maximumFileBytes = 1_048_576
    static let maximumXattrBytes = 1_048_576
    static let maximumXattrListBytes = 65_536
    static let maximumTreeFiles = 4_096
    static let maximumTreeDirectories = 4_096
    static let maximumTreeBytes: UInt64 = 64 * 1_024 * 1_024

    static let expectedNodes: [PrimeR19ExpectedNode] = [
        directory(
            id: "ARCHIVE_PARENT", ordinal: 0, path: parentPath,
            device: 16_777_231, inode: 341_832, uid: 501, gid: 20,
            mode: 0o700, nlink: 6, aggregate: nil
        ),
        directory(
            id: "A_ROOT", ordinal: 1,
            path: "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-a-28835567",
            device: 16_777_231, inode: 17_526_524, uid: 501, gid: 0,
            mode: 0o700, nlink: 6,
            aggregate: PrimeR19ArchiveAggregate(
                bytes: 31_848_783, directories: 3, files: 57,
                topInventory: [
                    "PrimeDriverV2R19NativeLeafSplitStreamOwner",
                    "module-cache",
                    "prime-driver-v2-r19-native-leaf-split-stream-owner-fixed-openat.o",
                    "tmp",
                ]
            )
        ),
        file(
            id: "A_OBJECT", ordinal: 2,
            path: "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-a-28835567/prime-driver-v2-r19-native-leaf-split-stream-owner-fixed-openat.o",
            bytes: 5_608, device: 16_777_231, inode: 17_526_531,
            uid: 501, gid: 0, mode: 0o600, nlink: 1, flags: 0,
            sha256: "bd3090c07b64bafacbf14bc1415d0675c734a14f3aaf3f59312cfd4480e3e387"
        ),
        file(
            id: "A_PRODUCT", ordinal: 3,
            path: "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-a-28835567/PrimeDriverV2R19NativeLeafSplitStreamOwner",
            bytes: 357_672, device: 16_777_231, inode: 17_526_690,
            uid: 501, gid: 0, mode: 0o700, nlink: 1, flags: 0,
            sha256: "f6a03155d13693bafc5ea382ef9042b5e4317d8ef560738a317fe345ce2f8894"
        ),
        directory(
            id: "B_ROOT", ordinal: 4,
            path: "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-b-28835567",
            device: 16_777_231, inode: 17_526_710, uid: 501, gid: 0,
            mode: 0o700, nlink: 6,
            aggregate: PrimeR19ArchiveAggregate(
                bytes: 31_848_783, directories: 3, files: 57,
                topInventory: [
                    "PrimeDriverV2R19NativeLeafSplitStreamOwner",
                    "module-cache",
                    "prime-driver-v2-r19-native-leaf-split-stream-owner-fixed-openat.o",
                    "tmp",
                ]
            )
        ),
        file(
            id: "B_OBJECT", ordinal: 5,
            path: "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-b-28835567/prime-driver-v2-r19-native-leaf-split-stream-owner-fixed-openat.o",
            bytes: 5_608, device: 16_777_231, inode: 17_526_717,
            uid: 501, gid: 0, mode: 0o600, nlink: 1, flags: 0,
            sha256: "bd3090c07b64bafacbf14bc1415d0675c734a14f3aaf3f59312cfd4480e3e387"
        ),
        file(
            id: "B_PRODUCT", ordinal: 6,
            path: "/private/tmp/prime-driver-v2-r19-native-leaf-split-stream-owner-repair1-build-b-28835567/PrimeDriverV2R19NativeLeafSplitStreamOwner",
            bytes: 357_672, device: 16_777_231, inode: 17_526_868,
            uid: 501, gid: 0, mode: 0o700, nlink: 1, flags: 0,
            sha256: "f6a03155d13693bafc5ea382ef9042b5e4317d8ef560738a317fe345ce2f8894"
        ),
        file(
            id: "SOURCE_C", ordinal: 7,
            path: "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/docs/tools/prime-driver-v2-r19-native-leaf-split-stream-owner-fixed-openat.c",
            bytes: 5_902, device: 16_777_231, inode: 17_523_035,
            uid: 501, gid: 20, mode: 0o644, nlink: 1, flags: 0,
            sha256: "dd8e11ef4e765ce23abd504c6bccac26ee74460d293679e064208dcb807722a6"
        ),
        file(
            id: "SOURCE_H", ordinal: 8,
            path: "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/docs/tools/prime-driver-v2-r19-native-leaf-split-stream-owner-fixed-openat.h",
            bytes: 2_475, device: 16_777_231, inode: 17_523_034,
            uid: 501, gid: 20, mode: 0o644, nlink: 1, flags: 0,
            sha256: "63725614b7afba383768e92f027eb199e795dc5fc3880639243ddd61625cb615"
        ),
        file(
            id: "SOURCE_SWIFT", ordinal: 9,
            path: "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/docs/tools/prime-driver-v2-r19-native-leaf-split-stream-owner.swift",
            bytes: 153_848, device: 16_777_231, inode: 17_523_847,
            uid: 501, gid: 20, mode: 0o644, nlink: 1, flags: 0,
            sha256: "03d494b6c4fcc2127d8b51dae5ae6eac5439e87515bb4b4d18d91081ac945a4c"
        ),
    ]

    private static func file(
        id: String, ordinal: UInt32, path: String, bytes: UInt64,
        device: UInt64, inode: UInt64, uid: UInt64, gid: UInt64,
        mode: UInt16, nlink: UInt64, flags: UInt64, sha256: String
    ) -> PrimeR19ExpectedNode {
        PrimeR19ExpectedNode(
            id: id, ordinal: ordinal, path: path,
            facts: PrimeR19ArchiveFacts(
                bytes: bytes, device: device, flags: flags, gid: gid,
                inode: inode, mode: mode, nlink: nlink, sha256: sha256,
                type: "REGULAR_FILE", uid: uid, aggregate: nil
            )
        )
    }

    private static func directory(
        id: String, ordinal: UInt32, path: String,
        device: UInt64, inode: UInt64, uid: UInt64, gid: UInt64,
        mode: UInt16, nlink: UInt64,
        aggregate: PrimeR19ArchiveAggregate?
    ) -> PrimeR19ExpectedNode {
        PrimeR19ExpectedNode(
            id: id, ordinal: ordinal, path: path,
            facts: PrimeR19ArchiveFacts(
                bytes: nil, device: device, flags: nil, gid: gid,
                inode: inode, mode: mode, nlink: nlink, sha256: nil,
                type: "DIRECTORY", uid: uid, aggregate: aggregate
            )
        )
    }

    static let crs12FrameBase64 = "eyJwYXlsb2FkIjp7ImFyY2hpdmFsX2R1cmFiaWxpdHkiOnsiYXJjaGl2ZV9leGVjdXRpb25faWRlbnRpdHkiOmZhbHNlLCJhcmNoaXZlX3Zub2RlX21heV9ub3RfcmVwbGFjZV9vd25lcl9hX3J1bnRpbWVfdm5vZGVfd2l0aG91dF9TRVBBUkFURV9BRE1JU1NJT04iOnRydWUsImN1cnJlbnRfZXhhY3RfYXJ0aWZhY3Rfc3RvcmFnZSI6IkxPQ0FMX1BSSVZBVEVfVE1QX09TX01BTkFHRURfTk9UX0FSQ0hJVkFMIiwiZ2l0X2NvbnRyb2xfcmVjb3JkX3N0b3JhZ2UiOiJMT0NBTF9XT1JLVFJFRV9BTkRfU1VDQ0VTU09SX0NPTU1JVCIsImluY2x1ZGVkX2luX2NyczExX2J1aWxkX2NvbnRyYWN0IjpmYWxzZSwibW9kdWxlX2NhY2hlX2FyY2hpdmFsX3JlcXVpcmVkIjpmYWxzZSwibmV4dF9zbGljZSI6IlNFUEFSQVRFX0xPQ0FMX0NPTlRFTlRfQUREUkVTU0VEX0FSQ0hJVkVfRlJFRVpFIn0sImF1dGhvcml0eSI6eyJhdXRob3JpdHlfY2xvc3VyZV9hdXRob3JpemVkIjpmYWxzZSwiYXV0aG9yaXR5X3ZlY3RvciI6IjAwMDAwMDAwIiwiZ2F0ZV9lX2NsZWFyYW5jZSI6MCwiZ2F0ZV9lX21lY2hhbmljc19vdXRjb21lIjoiQUJTVEFJTiIsImdhdGVfZV9wcm9tb3Rpb25fYXV0aG9yaXplZCI6ZmFsc2UsImdhdGVfZV9zY2llbnRpZmljX291dGNvbWUiOiJBQlNUQUlOIiwib2JqZWN0X2V4ZWN1dGlvbnNfYXV0aG9yaXplZCI6MCwib3duZXJfYmluYXJ5X2V4ZWN1dGlvbnNfYXV0aG9yaXplZCI6MCwicnVudGltZV9uYW1lc3BhY2VfY3JlYXRpb25zX2F1dGhvcml6ZWQiOjAsInNjaWVudGlmaWNfYXV0aG9yaXRpZXNfY2xvc2VkIjowLCJzaWduYWxzX2F1dGhvcml6ZWQiOjAsInN3aWZ0X3N3aWZ0cG1fY29tbWFuZHNfYXV0aG9yaXplZCI6MH0sImJ1aWxkX2EiOnsib2JqZWN0Ijp7ImJ5dGVzIjo1NjA4LCJkZXZpY2UiOjE2Nzc3MjMxLCJmbGFncyI6MCwiZ2lkIjowLCJpbm9kZSI6MTc1MjY1MzEsIm1vZGUiOiIwNjAwIiwibmxpbmsiOjEsInBhdGgiOiIvcHJpdmF0ZS90bXAvcHJpbWUtZHJpdmVyLXYyLXIxOS1uYXRpdmUtbGVhZi1zcGxpdC1zdHJlYW0tb3duZXItcmVwYWlyMS1idWlsZC1hLTI4ODM1NTY3L3ByaW1lLWRyaXZlci12Mi1yMTktbmF0aXZlLWxlYWYtc3BsaXQtc3RyZWFtLW93bmVyLWZpeGVkLW9wZW5hdC5vIiwic2hhMjU2IjoiYmQzMDkwYzA3YjY0YmFmYWNiZjE0YmMxNDE1ZDA2NzVjNzM0YTE0ZjNhYWYzZjU5MzEyY2ZkNDQ4MGUzZTM4NyIsInVpZCI6NTAxfSwicG9saWN5IjoiUEVSTUFORU5UX1JFVEFJTl9TVEFUSUNfSURFTlRJVFlfUEFTU19QUkVTRVJWRURfQ0FORElEQVRFX1BFTkRJTkdfQVJDSElWRV9BTkRfU0VQQVJBVEVfTEFVTkNIX1JFQURJTkVTUyIsInByb2R1Y3QiOnsiYnl0ZXMiOjM1NzY3MiwiZGV2aWNlIjoxNjc3NzIzMSwiZmxhZ3MiOjAsImdpZCI6MCwiaW5vZGUiOjE3NTI2NjkwLCJtb2RlIjoiMDcwMCIsIm5saW5rIjoxLCJwYXRoIjoiL3ByaXZhdGUvdG1wL3ByaW1lLWRyaXZlci12Mi1yMTktbmF0aXZlLWxlYWYtc3BsaXQtc3RyZWFtLW93bmVyLXJlcGFpcjEtYnVpbGQtYS0yODgzNTU2Ny9QcmltZURyaXZlclYyUjE5TmF0aXZlTGVhZlNwbGl0U3RyZWFtT3duZXIiLCJzaGEyNTYiOiJmNmEwMzE1NWQxMzY5M2JhZmM1ZWEzODJlZjkwNDJiNWU0MzE3ZDhlZjU2MDczOGEzMTdmZTM0NWNlMmY4ODk0IiwidWlkIjo1MDF9LCJyb2xlIjoiU09MRV9QUkVTRVJWRURfRlVUVVJFX0NBTkRJREFURV9OT1RfRVhFQ1VUSU9OX0FVVEhPUklaRUQiLCJyb290Ijp7ImFnZ3JlZ2F0ZV9kZXNjZW5kYW50X2ZpbGVfYnl0ZXMiOjMxODQ4NzgzLCJkZXNjZW5kYW50X2RpcmVjdG9yaWVzIjozLCJkZXNjZW5kYW50X2ZpbGVzIjo1NywiZGV2aWNlIjoxNjc3NzIzMSwiZ2lkIjowLCJpbm9kZSI6MTc1MjY1MjQsIm1vZGUiOiIwNzAwIiwicGF0aCI6Ii9wcml2YXRlL3RtcC9wcmltZS1kcml2ZXItdjItcjE5LW5hdGl2ZS1sZWFmLXNwbGl0LXN0cmVhbS1vd25lci1yZXBhaXIxLWJ1aWxkLWEtMjg4MzU1NjciLCJ1aWQiOjUwMX0sInRvcF9pbnZlbnRvcnkiOlsiUHJpbWVEcml2ZXJWMlIxOU5hdGl2ZUxlYWZTcGxpdFN0cmVhbU93bmVyIiwibW9kdWxlLWNhY2hlIiwicHJpbWUtZHJpdmVyLXYyLXIxOS1uYXRpdmUtbGVhZi1zcGxpdC1zdHJlYW0tb3duZXItZml4ZWQtb3BlbmF0Lm8iLCJ0bXAiXX0sImJ1aWxkX2IiOnsib2JqZWN0Ijp7ImJ5dGVzIjo1NjA4LCJkZXZpY2UiOjE2Nzc3MjMxLCJmbGFncyI6MCwiZ2lkIjowLCJpbm9kZSI6MTc1MjY3MTcsIm1vZGUiOiIwNjAwIiwibmxpbmsiOjEsInBhdGgiOiIvcHJpdmF0ZS90bXAvcHJpbWUtZHJpdmVyLXYyLXIxOS1uYXRpdmUtbGVhZi1zcGxpdC1zdHJlYW0tb3duZXItcmVwYWlyMS1idWlsZC1iLTI4ODM1NTY3L3ByaW1lLWRyaXZlci12Mi1yMTktbmF0aXZlLWxlYWYtc3BsaXQtc3RyZWFtLW93bmVyLWZpeGVkLW9wZW5hdC5vIiwic2hhMjU2IjoiYmQzMDkwYzA3YjY0YmFmYWNiZjE0YmMxNDE1ZDA2NzVjNzM0YTE0ZjNhYWYzZjU5MzEyY2ZkNDQ4MGUzZTM4NyIsInVpZCI6NTAxfSwicG9saWN5IjoiUEVSTUFORU5UX1JFVEFJTl9TVEFUSUNfSURFTlRJVFlfV0lUTkVTU19PTkxZX05FVkVSX0VYRUNVVEVfT1JfU1VCU1RJVFVURSIsInByb2R1Y3QiOnsiYnl0ZXMiOjM1NzY3MiwiZGV2aWNlIjoxNjc3NzIzMSwiZmxhZ3MiOjAsImdpZCI6MCwiaW5vZGUiOjE3NTI2ODY4LCJtb2RlIjoiMDcwMCIsIm5saW5rIjoxLCJwYXRoIjoiL3ByaXZhdGUvdG1wL3ByaW1lLWRyaXZlci12Mi1yMTktbmF0aXZlLWxlYWYtc3BsaXQtc3RyZWFtLW93bmVyLXJlcGFpcjEtYnVpbGQtYi0yODgzNTU2Ny9QcmltZURyaXZlclYyUjE5TmF0aXZlTGVhZlNwbGl0U3RyZWFtT3duZXIiLCJzaGEyNTYiOiJmNmEwMzE1NWQxMzY5M2JhZmM1ZWEzODJlZjkwNDJiNWU0MzE3ZDhlZjU2MDczOGEzMTdmZTM0NWNlMmY4ODk0IiwidWlkIjo1MDF9LCJyb2xlIjoiU1RBVElDX0lERU5USVRZX1dJVE5FU1NfT05MWV9ORVZFUl9FWEVDVVRBQkxFX09SX1NVQlNUSVRVVEFCTEUiLCJyb290Ijp7ImFnZ3JlZ2F0ZV9kZXNjZW5kYW50X2ZpbGVfYnl0ZXMiOjMxODQ4NzgzLCJkZXNjZW5kYW50X2RpcmVjdG9yaWVzIjozLCJkZXNjZW5kYW50X2ZpbGVzIjo1NywiZGV2aWNlIjoxNjc3NzIzMSwiZ2lkIjowLCJpbm9kZSI6MTc1MjY3MTAsIm1vZGUiOiIwNzAwIiwicGF0aCI6Ii9wcml2YXRlL3RtcC9wcmltZS1kcml2ZXItdjItcjE5LW5hdGl2ZS1sZWFmLXNwbGl0LXN0cmVhbS1vd25lci1yZXBhaXIxLWJ1aWxkLWItMjg4MzU1NjciLCJ1aWQiOjUwMX0sInRvcF9pbnZlbnRvcnkiOlsiUHJpbWVEcml2ZXJWMlIxOU5hdGl2ZUxlYWZTcGxpdFN0cmVhbU93bmVyIiwibW9kdWxlLWNhY2hlIiwicHJpbWUtZHJpdmVyLXYyLXIxOS1uYXRpdmUtbGVhZi1zcGxpdC1zdHJlYW0tb3duZXItZml4ZWQtb3BlbmF0Lm8iLCJ0bXAiXX0sImNsYXNzaWZpY2F0aW9uIjp7ImNhbmRpZGF0ZV9lbGlnaWJpbGl0eSI6IkFfUFJFU0VSVkVEX0ZPUl9TRVBBUkFURV9GVVRVUkVfTEFVTkNIX1JFQURJTkVTU19OT1RfRVhFQ1VUSU9OX0FVVEhPUklaRUQiLCJkZXZpYXRpb25fbWF0ZXJpYWxpdHkiOiJOT05NQVRFUklBTF9UT19TVEFUSUNfSURFTlRJVFlfREFUQV9NQVRFUklBTF9UT19QUk9DRURVUkFMX0NPTkZPUk1BTkNFIiwiZW50cnlfYW5kX2NvbXBsZXRpb25fcmVsYXRpdmVfb3JkZXIiOiJVTlBST1ZFTiIsImVudmVsb3BlX2NvbmZvcm1hbmNlIjoiRkFJTF9SRVFVSVJFRF9PQkpFQ1RfQ01QX0NPTVBMRVRJT05fQkFSUklFUl9BQlNFTlQiLCJnYXRlX2UiOiJBQlNUQUlOX0NMRUFSQU5DRV8wX05PX1BST01PVElPTl9OT19TQ0lFTlRJRklDX0NMT1NVUkUiLCJvYnNlcnZlZF9zZXF1ZW5jZSI6IlJBV19PQkpFQ1RfQ01QX0FORF9SQVdfUFJPRFVDVF9DTVBfSU5JVElBVEVEX1dJVEhPVVRfQ09NUExFVElPTl9CQVJSSUVSX0lOX09ORV9QUk9NSVNFX0FMTCIsInByb3NwZWN0aXZlX2FkanVkaWNhdGlvbiI6IlBSRVNFUlZFU19BX0NBTkRJREFURV9XSVRIT1VUX1JFVFJPQUNUSVZFX0VOVkVMT1BFX1dBSVZFUiIsInJlcXVpcmVkX3NlcXVlbmNlIjoiUkFXX09CSkVDVF9DTVBfTk9STUFMX0VYSVRfMF9aRVJPX09VVFBVVF9DT01QTEVURVNfQkVGT1JFX1JBV19QUk9EVUNUX0NNUF9FTlRSWSIsInJ1bnRpbWVfb3Jfc291cmNlX2RlZmVjdCI6ZmFsc2UsInN0YXRpY19pZGVudGl0eSI6IlBBU1NfUkFXX09CSkVDVF9BTkRfUFJPRFVDVF9CWVRFU19FUVVBTF9QT1NUVkVSSUZJRURfVU5DSEFOR0VEIiwic3RhdGljX3Jlc3VsdF9iYXNpcyI6WyJGSVhFRF9QQVRIX1JFQURfT05MWV9DT01QQVJJU09OUyIsIk9CSkVDVF9BTkRfUFJPRFVDVF9DT01QQVJJU09OU19IQVZFX0RJU0pPSU5UX0lOUFVUX1BBSVJTX0FORF9OT19TSEFSRURfT1VUUFVUIiwiT1BFUkFUSU9OU19DT01NVVRFIiwiQk9USF9FWElUXzBfWkVST19DQVBUVVJFRF9CWVRFUyIsIk9CSkVDVF9QUkVERUNFU1NPUl9DT05ESVRJT05fT0JTRVJWRURfVFJVRSIsIkFfQU5EX0JfT0JKRUNUX0FORF9QUk9EVUNUX0JZVEVTX1BPU1RWRVJJRklFRF9VTkNIQU5HRUQiLCJJTkRFUEVOREVOVF9TVEFUSUNfUkVWSUVXX1JFUFJPRFVDRURfRVFVQUxJVFkiXX0sImNvbnN1bWVkX2NyczExX3ByZWZpeCI6eyJhbGxfc2xvdHNfYW5kX3BhaXIiOiJDT05TVU1FRF9OT19SRVJVTiIsImNoaWxkX2RpcmVjdG9yaWVzX2NyZWF0ZWQiOjQsImNoaWxkX2RpcmVjdG9yeV9jcmVhdGlvbl90b29sX2VudHJpZXMiOjIsImNsZWFudXBfcmV0cnlfcmVwYWlyX2FsdGVybmF0ZV9vcl90aGlyZF9idWlsZF9lbnRyaWVzIjowLCJjb21wYXJpc29uX2VudHJpZXMiOjIsImNvbXBhcmlzb25fc2VxdWVuY2VfcmVzdWx0IjoiRU5WRUxPUEVfTk9OQ09ORk9STUlOR19TVEFUSUNfSURFTlRJVFlfVU5BRkZFQ1RFRCIsImNvbXBpbGVyX2NhcHR1cmVkX2J5dGVzX3Blcl9lbnRyeSI6WzAsMCwwLDBdLCJjb21waWxlcl9lbnRyaWVzIjo0LCJjb21waWxlcl9leGl0X3N0YXR1c2VzX2luX29yZGVyIjpbMCwwLDAsMF0sImV2aWRlbmNlX2NsYXNzIjoiT1JDSEVTVFJBVElPTl9PQlNFUlZFRF9OT1RfSU5ERVBFTkRFTlRMWV9SRUNPTlNUUlVDVElCTEVfRlJPTV9SRVRBSU5FRF9BUlRJRkFDVFMiLCJsbHZtX25tX2VudHJpZXMiOjIsIm9iamVjdF9vcl9wcm9kdWN0X2V4ZWN1dGlvbnNfb2JzZXJ2ZWQiOjAsInBvc3RfYW5hbHl6ZXJfb2JqZWN0X2FuZF9wcm9kdWN0X2J5dGVzX3VuY2hhbmdlZCI6dHJ1ZSwicHl0aG9uX3Byb2Nlc3NlcyI6MCwicmF3X29iamVjdF9jbXBfb2JzZXJ2ZWQiOnsiY2FwdHVyZWRfYnl0ZXMiOjAsImNsYXNzaWZpY2F0aW9uIjoiVkFMSURfU1RBVElDX0VWSURFTkNFX05PTkNPTkZPUk1JTkdfU0VRVUVOQ0UiLCJleGl0X3N0YXR1cyI6MH0sInJhd19wcm9kdWN0X2NtcF9vYnNlcnZlZCI6eyJjYXB0dXJlZF9ieXRlcyI6MCwiY2xhc3NpZmljYXRpb24iOiJWQUxJRF9TVEFUSUNfRVZJREVOQ0VfTk9OQ09ORk9STUlOR19TRVFVRU5DRSIsImV4aXRfc3RhdHVzIjowfSwicm9vdF9jcmVhdGlvbl90b29sX2VudHJpZXMiOjIsInJ1bnRpbWVfbmFtZXNwYWNlX2NyZWF0aW9uc19vYnNlcnZlZCI6MCwic2lnbmFsc19vYnNlcnZlZCI6MCwic3RhdGljX2FuYWx5emVyX2VudHJpZXMiOjI4LCJzdGF0aWNfYW5hbHl6ZXJfcmVzdWx0IjoiT0JTRVJWRURfUEFTU19BTEwifSwiY29udHJvbCI6eyJhZGp1ZGljYXRpb25fYmFzaXMiOiJVU0VSX0RBVEFfTEVBRElOR19DT1JSRUNUSU9OX1BMVVNfSU5ERVBFTkRFTlRfQ09NTVVUQVRJVklUWV9SRVZJRVciLCJiYXNlX3dvcmt0cmVlIjoiQ0xFQU5fQVRfQ1JTMTFfUkVBRElORVNTX0NPTU1JVCIsInJlYWRpbmVzc19jb21taXQiOiIzNjQ4YTBhYjBjYzk5NDlkYWIyMGRjZmY2YjU2NjdhOGVmMTU3MDQ2IiwicmVhZGluZXNzX2ZyYW1lX3dpdGhfbGZfc2hhMjU2IjoiMzBiM2NlMmI0YmI4MzEwZGMxMTNjYTRmNmFiNmJkMWE4MGMwMThlZDI1MmZiYzE0Mjg4NTY4NzUxN2YzN2Q5NCIsInJlYWRpbmVzc19wYXlsb2FkX3NoYTI1NiI6ImEwZTY0YjcwZjkzMDUzNTA5Yzg2Njk2OTFiYzBkMDdmYjRlMDg0ODc2ZDM5MDc0NTIxYzEzNzMyNGJiNTQ1N2IiLCJyZWFkaW5lc3NfdHJlZSI6IjMzMWZkNmRkYjM0NmI4OTMxZTRjYTNkNWE0NzE1NDAwYmZlOGYzMmMiLCJyZXBhaXJfY29tbWl0IjoiZTM4MWFmODBmMmQwNDUzN2Q5YTIwZDg0ZDAwNGNiZTQyZTViMzk3NCIsInJlcGFpcl90cmVlIjoiYmM1MGExNWYxMDI5MzMwNmE3NzM3MzdjOTRkODA4NWE1OTNlYTY5MiIsInN1cGVyc2VkZWRfdW5jb21taXR0ZWRfZmFpbHVyZV9kcmFmdCI6eyJmcmFtZV9zaGEyNTYiOiI1YjMyNDYwNDUwM2YxODliZjgyZGM0MDUxNDg0ZDU1NmUxNDc1NTAzNTNmY2I5NTM0Yzg4NWQ2MTc3NDMyMzhiIiwiZnJhbWVfd2l0aF9sZl9zaGEyNTYiOiJkMzdkMDFmYWNmNGExNjY1YmVhOTlkZTNiNzI0MTA5YjM1ZTRmNjI1YTE2OWU0ODQ0MmNiYjRjODU4OGU0YTg5IiwicGF5bG9hZF9zaGEyNTYiOiIyMGE2YzFiNTUyMTAzNTlhNzAyZTM1MTJlNjVjOTE5MTkyOGQxNDY1YzU1NTE4ZjU2ZDJiZDMxYWY4MTRkMmE4Iiwic3RhdGUiOiJORVZFUl9DT01NSVRURURfUkVQTEFDRURfQkVGT1JFX0NIRUNLUE9JTlQifSwidHJhY2tlZF9kZWx0YSI6IkVYQUNUX09ORV9DQU5PTklDQUxfQ09OVFJPTF9ET0NVTUVOVF9FT0ZfQVBQRU5EIn0sImN1cnJlbnRfcmVjb3ZlcmFibGVfc3RhdGljX29ic2VydmF0aW9uIjp7ImNsYXNzaWZpY2F0aW9uIjoiUEFTU19TVEFUSUNfSURFTlRJVFlfQURNSVRURURfRk9SX1BST1NQRUNUSVZFX0FfQ0FORElEQVRFX09OTFkiLCJjdXJyZW50X3J1bnRpbWVfcm9vdHNfYXRfcmV2aWV3IjpbeyJwYXRoIjoiL3ByaXZhdGUvdG1wL3IxOS1uYXRpdmUtbGVhZi1zcGxpdC1zdHJlYW0tb3duZXItNmEwMTVjMTEtOTVjNTQzNTEiLCJzdGF0ZSI6IkFCU0VOVF9FTk9FTlQifSx7InBhdGgiOiIvcHJpdmF0ZS90bXAvZ2F0ZS1lMS00LXIxOS1uYXRpdmUtbGVhZi1wcmltaXRpdmUtY2FuYXJ5LTNhNDZhMDM3LTE3NDUyODQwIiwic3RhdGUiOiJBQlNFTlRfRU5PRU5UIn0seyJwYXRoIjoiL3ByaXZhdGUvdG1wL3IxOS1uYXRpdmUtbGVhZi1jb250cm9sbGVyLXJ1bnRpbWUtc3VwZXJ2aXNvci0yMjAxNTUwOS1kNTc3YWJjOCIsInN0YXRlIjoiQUJTRU5UX0VOT0VOVCJ9XSwiaGlzdG9yaWNhbF9leGVjdXRpb25fb3Jfc2lnbmFsX2Fic2VuY2UiOiJOT1RfUFJPVkFCTEVfRlJPTV9DVVJSRU5UX0NFTlNVU19PUl9SRVRBSU5FRF9BUlRJRkFDVFMiLCJoaXN0b3JpY2FsX29wZXJhdGlvbl9jb3VudHMiOiJBQlNUQUlOX0lOREVQRU5ERU5UX1JFQ09OU1RSVUNUSU9OX09SQ0hFU1RSQVRJT05fUkVDT1JEX1JFVEFJTkVEIiwibGl2ZV9saWJwcm9jX2NlbnN1c19hdF9yZXZpZXciOiJaRVJPX0FfT1JfQl9QUk9EVUNUX0VYRUNVVEFCTEVfUEFUSFMiLCJvYmplY3QiOnsiYV9hbmRfYl92bm9kZXNfZGlzdGluY3QiOnRydWUsImJ5dGVzIjo1NjA4LCJpbmRlcGVuZGVudF9wb3N0X2ZhaWx1cmVfY21wIjoiUEFTU19DT1JST0JPUkFUSU5HX1NUQVRJQ19FVklERU5DRSIsInNoYTI1Nl9lcXVhbCI6ImJkMzA5MGMwN2I2NGJhZmFjYmYxNGJjMTQxNWQwNjc1YzczNGExNGYzYWFmM2Y1OTMxMmNmZDQ0ODBlM2UzODcifSwicHJvZHVjdCI6eyJhX2FuZF9iX3Zub2Rlc19kaXN0aW5jdCI6dHJ1ZSwiYXJjaGl0ZWN0dXJlIjoiYXJtNjQiLCJieXRlcyI6MzU3NjcyLCJjb2RlX2RpcmVjdG9yeSI6eyJleGVjdXRhYmxlX3NlZ21lbnRfbGltaXQiOjE0MDIwOCwiZmxhZ3NfaGV4IjoiMHgyMDAwMiIsImZ1bGxfc2hhMjU2IjoiNGY1OTRiMTEzYzZlNGZhOWM3ZmQxODhmYzlmYzgyZDg0MDE4YzFhNjY2YmNlYjUwNmUwNjlhYzE3NDY0MzhmZiIsInNpZ25pbmciOiJBRF9IT0NfTElOS0VSX1NJR05FRCIsInNpemVfYnl0ZXMiOjI5MTUsInZlcnNpb25faGV4IjoiMHgyMDQwMCJ9LCJlbnRyeW9mZiI6NjE3ODAsImV4dGVuZGVkX2F0dHJpYnV0ZSI6eyJuYW1lIjoiY29tLmFwcGxlLnByb3ZlbmFuY2UiLCJub3JtYWxpemVkX3N0ZG91dF9zaGEyNTYiOiJhYjMwYTY3NTBiMWNhMWY0Mjc3N2Y5OTVhMmMwOThkODJhMmZlNzQ2OWM1NTJiOWJjNjYzOWIxMjM2OTU1ZjYxIiwicmF3X2hleCI6IjAxMDIifSwiZmlsZXR5cGUiOiJNSF9FWEVDVVRFIiwiaGVhZGVyX2ZsYWdzIjpbIk5PVU5ERUZTIiwiRFlMRExJTksiLCJUV09MRVZFTCIsIlBJRSJdLCJpbmRlcGVuZGVudF9wb3N0X2ZhaWx1cmVfY21wIjoiUEFTU19DT1JST0JPUkFUSU5HX1NUQVRJQ19FVklERU5DRSIsImxjX2NvZGVfc2lnbmF0dXJlIjp7Im9mZnNldCI6MzU0NzM2LCJzaXplIjoyOTM2fSwibGlua2VkX2ltYWdlX2NvdW50X2V4Y2x1ZGluZ19wcm9kdWN0X2hlYWRlciI6MTIsImxvYWRfY29tbWFuZF9jb3VudCI6MzAsImxvYWRfY29tbWFuZHNfc2l6ZV9ieXRlcyI6Mzk2OCwibWFudWFsX2xpYnByb2NfZGVwZW5kZW5jeSI6ZmFsc2UsIm1pbmltdW1fbWFjb3MiOiIxNC4wIiwibm9ybWFsaXplZF9jb2Rlc2lnbl9kaXNwbGF5X3N0ZGVycl9zaGEyNTYiOiIyZWE2MTNmNjI5NTc1MDhhYjEwMTk4NDEyYTRkYmQ2YzFjYTRhNWRlNTFmMzhjZDEzN2E3M2Y3ZmU1NzJjMDY4Iiwibm9ybWFsaXplZF9sbHZtX25tX3Vfc3Rkb3V0X3NoYTI1NiI6ImRjMWE1ODcyMmM1MGUzMzI5MGNhOTYyMjkwOTJlMDE2OTEyMzYwNWE1NGYyMDBhM2U4MmJjNWRhZDlhNTQzODYiLCJub3JtYWxpemVkX290b29sX0xfc3Rkb3V0X3NoYTI1NiI6IjFhM2FlYTBkZGUzYzMyODM4OTk3YTg3ODFiOThhODI1YWY5N2VlYTg1NzNmOTVhNGM5ZDgzZmZlNjNkZWIzNzkiLCJub3JtYWxpemVkX290b29sX2xfc3Rkb3V0X3NoYTI1NiI6Ijc4YjQxMDQ2NmFiYTM3MTczYzgzNTE3N2Q4NTcyOWQyMDYxOWRjYzAzZGE1ZDc3ZTUwNjBhMTJjZDkyYmIwMmEiLCJub3JtYWxpemVkX291dHB1dF9ydWxlIjoiUkVQTEFDRV9FWEFDVF9DT01QTEVURV9BX09SX0JfQlVJTERfUk9PVF9XSVRIX0xJVEVSQUxfPFJPT1Q+X09OTFkiLCJyYXdfc2hhMjU2X2VxdWFsIjoiZjZhMDMxNTVkMTM2OTNiYWZjNWVhMzgyZWY5MDQyYjVlNDMxN2Q4ZWY1NjA3MzhhMzE3ZmUzNDVjZTJmODg5NCIsInNkayI6IjI2LjUiLCJzdHJpY3RfY29kZXNpZ24iOiJQQVNTX0JPVEgiLCJ1bmRlZmluZWRfc3ltYm9sX2xpbmVzX25vX2hlYWRlciI6Mjc0LCJ1dWlkIjoiNzY3MzMxNzgtMDJFOC0zNTg0LThGRjktRjVBMjc0NEVGMjI2In19LCJoYXJkX3N0b3BzIjpbIk5PX1JFUlVOX09GX0VJVEhFUl9DUlMxMV9DT01QQVJJU09OX09SX1JFQlVJTERfVU5ERVJfQ1JTMTEiLCJOT19FWEVDVVRJT05fT0ZfQlVJTERfQl9QUk9EVUNUX09SX09CSkVDVCIsIk5PX0VYRUNVVElPTl9PRl9CVUlMRF9BX0JFRk9SRV9TRVBBUkFURV9BUkNISVZFX0FORF9MQVVOQ0hfUkVBRElORVNTIiwiTk9fQ0xBSU1fVEhBVF9DUlMxMV9FWEFDVF9TRVFVRU5DRV9DT05GT1JNRUQiLCJOT19BUkNISVZFX1ZOT0RFX1NVQlNUSVRVVElPTl9BU19SVU5USU1FX0lERU5USVRZIiwiTk9fUlVOVElNRV9OQU1FU1BBQ0VfU0lHTkFMX0FVVEhPUklUWV9DTE9TVVJFX09SX0dBVEVfRV9QUk9NT1RJT04iXSwicG9zdF9yZXN1bHRfaW5kZXBlbmRlbnRfcmV2aWV3X3N1cmZhY2UiOnsiY2xhc3NpZmljYXRpb24iOiJSRUFEX09OTFlfT1VUU0lERV9DUlMxMV9CT1VOREVEX0VOVFJZX0VOVkVMT1BFX05PTkNVUkFUSVZFIiwibXV0YXRpb25fYnlfcmV2aWV3ZXJzIjpmYWxzZSwicHJvZHVjdF9leGVjdXRpb25fYnlfcmV2aWV3ZXJzIjpmYWxzZSwicmV2aWV3XzEiOnsiZXhhY3RfcHJvY2Vzc19jb3VudCI6IlVOQVZBSUxBQkxFX0ZJTkRfRVhFQ19CQVRDSElOR19EWU5BTUlDIiwicmVjb25zdHJ1Y3RlZF9leHRlcm5hbF91dGlsaXR5X2VudHJpZXNfbWluaW11bSI6MTE5LCJyZXN1bHQiOiJCTE9DS19TVUNDRVNTX0NIRUNLUE9JTlRfUkVRVUlSRV9GQUlMVVJFX1JFVElSRU1FTlQiLCJydW50aW1lX3Jvb3RfYWJzZW5jZV9jaGVjayI6Ik9SRElOQVJZX05BTUVEX1BBVEhfUExVU19GSU5BTF9DT01QT05FTlRfU1lNTElOS19HVUFSRF9OT1RfRlVMTF9QQVRIX05PRk9MTE9XIiwic2hlbGxfd3JhcHBlcl9lbnRyaWVzIjo3fSwicmV2aWV3XzIiOnsibmFtZWRfYW5hbHl6ZXJfcHJvY2Vzc2VzIjoyNSwibmFtZWRfYW5hbHl6ZXJfc2hhcGUiOiIxNl9QQUlSRURfUExVU19PTkVfRk9VUl9QQVRIX1NUQVRfUExVU184X0FfT05MWV9ESUdFU1RfUkVSVU5TIiwib3RoZXJfb2JzZXJ2YXRpb25zIjoiUkVBRF9PTkxZX1JVQllfR0lUX0xJQlBST0NfUFJPQ0VTU19DT1VOVFNfTk9UX0ZST1pFTiIsInJlc3VsdCI6IkNSUzExX0ZBSUxfU1RBVElDX0lERU5USVRZX1BBU1NfQVNfT0JTRVJWQVRJT05fSElTVE9SSUNBTF9PUEVSQVRJT05TX0FCU1RBSU4ifX0sInJldGFpbmVkX3ByaW9yX3N0YXRlIjp7ImNvbnN1bWVkX2NyczlfYV9yb290Ijp7ImFnZ3JlZ2F0ZV9kZXNjZW5kYW50X2ZpbGVfYnl0ZXMiOjMxNDg3NzA3LCJkZXNjZW5kYW50X2RpcmVjdG9yaWVzIjozLCJkZXNjZW5kYW50X2ZpbGVzIjo1NiwiZGV2aWNlIjoxNjc3NzIzMSwiaW5vZGUiOjE3NTI1NzIyLCJvYmplY3Rfc2hhMjU2IjoiMjMyZjNjODQyNGNhNDhhMzgyNmU1NGIyNDdiNGU1MWQyOGE5YjU4M2U0MzBkM2QxMTQzODhmOThiZDZjYThhOSIsInBhdGgiOiIvcHJpdmF0ZS90bXAvcHJpbWUtZHJpdmVyLXYyLXIxOS1uYXRpdmUtbGVhZi1zcGxpdC1zdHJlYW0tb3duZXItYnVpbGQtYS02YTAxNWMxMSIsInBvbGljeSI6IlBFUk1BTkVOVF9SRVRBSU5fTk9fUkVVU0VfQ0xFQU5VUF9SRVBBSVJfT1JfUFJPRFVDVF9DT01QTEVUSU9OIiwicHJvZHVjdF9zdGF0ZSI6IkFCU0VOVCJ9LCJjb25zdW1lZF9jcnM5X2Jfcm9vdCI6IkFCU0VOVF9QRVJNQU5FTlRMWV9SRVRJUkVEIn0sInJldmlldyI6eyJjYW5kaWRhdGVfYWRqdWRpY2F0aW9uIjoiQV9QUkVTRVJWRURfUFJPU1BFQ1RJVkVMWV9OT1RfRVhFQ1VUSU9OX0FVVEhPUklaRUQiLCJkYXRhX3ByZWNlZGVuY2UiOiJDQU5PTklDQUxfSlNPTl9BTkRfTUVBU1VSRURfQllURVNfQVVUSE9SSVRBVElWRSIsImVudmVsb3BlX2NvbmZvcm1hbmNlIjoiRkFJTF9PUkRFUl9PTkxZIiwibGFuZ3VhZ2VfYm91bmRhcnkiOiJTV0lGVF9QTFVTX0ZJWEVEX0NfTk9fUFlUSE9OIiwibWF0ZXJpYWxpdHkiOiJOT05NQVRFUklBTF9UT19TVEFUSUNfSURFTlRJVFlfTUFURVJJQUxfVE9fUFJPQ0VEVVJBTF9DT05GT1JNQU5DRSIsInN0YXRpY19pZGVudGl0eSI6IlBBU1NfVFdPX0lOREVQRU5ERU5UX1JFVklFV1MifSwic291cmNlX2lkZW50aXR5IjpbeyJibG9iIjoiNzI5OGFiYjQ0ZDNkNmFlNmJmM2ZhNDkyZGM2YTc0N2I1YTRmMjY5NCIsImJ5dGVzIjo1OTAyLCJnaXRfbW9kZSI6IjEwMDY0NCIsImxpbmVzIjoyMTQsInBhdGgiOiJkb2NzL3Rvb2xzL3ByaW1lLWRyaXZlci12Mi1yMTktbmF0aXZlLWxlYWYtc3BsaXQtc3RyZWFtLW93bmVyLWZpeGVkLW9wZW5hdC5jIiwic2hhMjU2IjoiZGQ4ZTExZWY0ZTc2NWNlMjNhYmQ1MDRjNmJjY2FjMjZlZTc0NDYwZDI5MzY3OWUwNjQyMDhkY2I4MDc3MjJhNiJ9LHsiYmxvYiI6IjRhMjIyNDU5ZTI2MGZkN2IwMDEyMGY0MmY5YzY0YWIzM2ZkMDJlZTMiLCJieXRlcyI6MjQ3NSwiZ2l0X21vZGUiOiIxMDA2NDQiLCJsaW5lcyI6NzIsInBhdGgiOiJkb2NzL3Rvb2xzL3ByaW1lLWRyaXZlci12Mi1yMTktbmF0aXZlLWxlYWYtc3BsaXQtc3RyZWFtLW93bmVyLWZpeGVkLW9wZW5hdC5oIiwic2hhMjU2IjoiNjM3MjU2MTRiN2FmYmEzODM3NjhlOTJmMDI3ZWIxOTllNzk1ZGM1ZmMzODgwNjM5MjQzZGRkNjE2MjVjYjYxNSJ9LHsiYmxvYiI6Ijg3ZTM3NWI0ODlmMTdlMDNhNTg2YjEzMWFlNTE2ZDFhYWRjMjZmNjEiLCJieXRlcyI6MTUzODQ4LCJnaXRfbW9kZSI6IjEwMDY0NCIsImxpbmVzIjo0MTE2LCJwYXRoIjoiZG9jcy90b29scy9wcmltZS1kcml2ZXItdjItcjE5LW5hdGl2ZS1sZWFmLXNwbGl0LXN0cmVhbS1vd25lci5zd2lmdCIsInNoYTI1NiI6IjAzZDQ5NGI2YzRmY2MyMTI3ZDhiNTFkYWU1YWU2ZWFjNTQzOWU4NzUxNWJiNGI0ZDE4ZDkxMDgxYWM5NDVhNGMifV0sInN1Y2Nlc3NvciI6eyJidWlsZF9hX2NhbmRpZGF0ZV9wcmVzZXJ2ZWQiOnRydWUsImJ1aWxkX2Jfd2l0bmVzc19vbmx5Ijp0cnVlLCJmcmVzaF9idWlsZF9wYWlyX3JlcXVpcmVkIjpmYWxzZSwiZnV0dXJlX2Z1bGxfcnVuX29yZGVyX293bmVyIjoiT05FX0NMT1NFRF9MT0NBTF9TV0lGVF9PUl9OQVRJVkVfU1RBVEVfTUFDSElORV9OT1RfQ09ERVhfVE9PTF9DQUxMX1NDSEVEVUxJTkciLCJuZXh0IjoiU0VQQVJBVEVfTE9DQUxfQVJDSElWQUxfRFVSQUJJTElUWV9GUkVFWkUiLCJ0aGVuIjoiU0VQQVJBVEVfT1dORVJfQV9MQVVOQ0hfUkVBRElORVNTX1dJVEhfSU1NRURJQVRFX05BTUVEX0FORF9IRUxEX0lERU5USVRZX1JFVkFMSURBVElPTiIsInRoaXNfcmVjb3JkX2F1dGhvcml6ZXNfYXJjaGl2ZV93cml0ZV9idWlsZF9wcm9kdWN0X2V4ZWN1dGlvbl9zaWduYWxfb3JfcnVudGltZV9uYW1lc3BhY2UiOmZhbHNlfSwidG9vbGNoYWluIjp7ImNsYW5nIjp7InBhdGgiOiIvQXBwbGljYXRpb25zL1hjb2RlLmFwcC9Db250ZW50cy9EZXZlbG9wZXIvVG9vbGNoYWlucy9YY29kZURlZmF1bHQueGN0b29sY2hhaW4vdXNyL2Jpbi9jbGFuZyIsInNoYTI1NiI6IjdkZWY5MGRkODgyOTcyNjY4NjIxM2E3NDdmYzViZmYxNTgzZGY5MzNkYWU1ZWRjNTVkNzU1NDc5ZTBiZmUwMGEifSwiaG9zdCI6Im1hY09TXzI2LjUuMl8yNUY4NF9hcm02NCIsImxkIjp7InBhdGgiOiIvQXBwbGljYXRpb25zL1hjb2RlLmFwcC9Db250ZW50cy9EZXZlbG9wZXIvVG9vbGNoYWlucy9YY29kZURlZmF1bHQueGN0b29sY2hhaW4vdXNyL2Jpbi9sZCIsInNoYTI1NiI6IjU4OTdiMjc1ZWZkOTNiMjAxYjZkZjU4MzJkZDU0MTI2MmIzZjIwZjI5MDg1OWJhNzhmMjIwMGE2YTY2ZWYzOGIifSwibGx2bV9ubSI6eyJwYXRoIjoiL0FwcGxpY2F0aW9ucy9YY29kZS5hcHAvQ29udGVudHMvRGV2ZWxvcGVyL1Rvb2xjaGFpbnMvWGNvZGVEZWZhdWx0LnhjdG9vbGNoYWluL3Vzci9iaW4vbGx2bS1ubSIsInNoYTI1NiI6ImQ5MTBmM2FjYjEwNDc5MWU1NDc1MjU0MDAwZWRlMmFhMTI5YWExYTQyZWFmY2M3ZjViZGIyN2FmZmZjNjQyZGMifSwic2RrIjp7Im5hbWVkX3BhdGgiOiIvQXBwbGljYXRpb25zL1hjb2RlLmFwcC9Db250ZW50cy9EZXZlbG9wZXIvUGxhdGZvcm1zL01hY09TWC5wbGF0Zm9ybS9EZXZlbG9wZXIvU0RLcy9NYWNPU1gyNi41LnNkayIsIm5hbWVkX3N5bWxpbmtfdGFyZ2V0IjoiTWFjT1NYLnNkayIsInNldHRpbmdzX3BhdGgiOiIvQXBwbGljYXRpb25zL1hjb2RlLmFwcC9Db250ZW50cy9EZXZlbG9wZXIvUGxhdGZvcm1zL01hY09TWC5wbGF0Zm9ybS9EZXZlbG9wZXIvU0RLcy9NYWNPU1gyNi41LnNkay9TREtTZXR0aW5ncy5qc29uIiwic2V0dGluZ3Nfc2hhMjU2IjoiZjhkMDA1ZjA5MzgxMzg5MTY3ZjllMGFlYWExNjliYzllN2RmZjE2MmVmMjJjYTJmZDhlOThkZjdmZjFhY2FmZSIsInZlcnNpb24iOiIyNi41In0sInN3aWZ0Ijp7Imxhbmd1YWdlX21vZGUiOiI2Iiwic3dpZnRfZHJpdmVyX3BhdGgiOiIvQXBwbGljYXRpb25zL1hjb2RlLmFwcC9Db250ZW50cy9EZXZlbG9wZXIvVG9vbGNoYWlucy9YY29kZURlZmF1bHQueGN0b29sY2hhaW4vdXNyL2Jpbi9zd2lmdC1kcml2ZXIiLCJzd2lmdF9kcml2ZXJfc2hhMjU2IjoiZmVhZDUyZWJlMDBlYzZlYzcwMGVjYmI0YmUzMGYwYjYyMDRkZDA1MDZjYjI3MWRkYTcyYWMyNTcyNjFiZDY0YiIsInN3aWZ0X3ZlcnNpb24iOiI2LjMuMyIsInN3aWZ0Y19uYW1lZF9wYXRoIjoiL0FwcGxpY2F0aW9ucy9YY29kZS5hcHAvQ29udGVudHMvRGV2ZWxvcGVyL1Rvb2xjaGFpbnMvWGNvZGVEZWZhdWx0LnhjdG9vbGNoYWluL3Vzci9iaW4vc3dpZnRjIiwic3dpZnRjX25hbWVkX3N5bWxpbmtfdGFyZ2V0Ijoic3dpZnQtZnJvbnRlbmQiLCJzd2lmdGNfcmVzb2x2ZWRfZnJvbnRlbmRfc2hhMjU2IjoiMmVkMzg1NzFlOTJjMDI4MzA5MTgzOGMxNjQ5ZTI3NjUwYWQ5Yzk5OTUwMjg4ZTg4M2M3YjJkYzZjNGNlODlmYiJ9LCJ0YXJnZXQiOiJhcm02NC1hcHBsZS1tYWNvc3gxNC4wIiwieGNvZGUiOiIyNi42XzE3RjExMyJ9fSwicGF5bG9hZF9oYXNoX3J1bGUiOiJTSEEyNTZfQ09NUEFDVF9SRUNVUlNJVkVfTEVYSUNPR1JBUEhJQ19LRVlTX1VURjhfTk9fVFJBSUxJTkdfTEZfRVhDTFVESU5HX1BBWUxPQURfU0hBMjU2X0ZJRUxEIiwicGF5bG9hZF9zaGEyNTYiOiJiZDZiYTUyZWI2NTY2YTM3ZGNmZTUwNGY0ZGI5NGIzY2MyN2FiZGM1YWJhZjFjM2NhMzI1ZGM0YmFkOTg2OWQ4Iiwic2NoZW1hIjoicHJpbWVfZHJpdmVyX3YyX3IxOV9uYXRpdmVfbGVhZl9zcGxpdF9zdHJlYW1fb3duZXJfZHVhbF9heGlzX2J1aWxkX3Jlc3VsdF92MSIsInN0YXR1cyI6IlBBU1NfU1RBVElDX0FSVElGQUNUX0lERU5USVRZX1dJVEhfTk9OTUFURVJJQUxfU0VRVUVOQ0VfTk9OQ09ORk9STUFOQ0UifQ=="
    static let linkedImages: [String] = [
        "/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1356.0.0)",
        "/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation (compatibility version 150.0.0, current version 5026.5.4)",
        "/System/Library/Frameworks/CryptoKit.framework/Versions/A/CryptoKit (compatibility version 1.0.0, current version 1.0.0)",
        "/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation (compatibility version 300.0.0, current version 5026.5.4)",
        "/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)",
        "/usr/lib/swift/libswiftCore.dylib (compatibility version 0.0.0, current version 0.0.0)",
        "/usr/lib/swift/libswiftCoreFoundation.dylib (compatibility version 1.0.0, current version 120.100.0, weak)",
        "/usr/lib/swift/libswiftDarwin.dylib (compatibility version 1.0.0, current version 377.120.8)",
        "/usr/lib/swift/libswiftDispatch.dylib (compatibility version 1.0.0, current version 1542.100.32)",
        "/usr/lib/swift/libswiftIOKit.dylib (compatibility version 1.0.0, current version 1.0.0, weak)",
        "/usr/lib/swift/libswiftObjectiveC.dylib (compatibility version 1.0.0, current version 951.7.0, weak)",
        "/usr/lib/swift/libswiftXPC.dylib (compatibility version 1.0.0, current version 128.120.2, weak)"
    ]
    static let undefinedSymbols: [String] = [
        "_$s10Foundation13__DataStorageC5bytes6length4copy11deallocator6offsetACSvSg_SiSbySv_SitcSgSitcfc",
        "_$s10Foundation13__DataStorageC5bytes6lengthACSVSg_Sitcfc",
        "_$s10Foundation13__DataStorageC6_bytesSvSgvg",
        "_$s10Foundation13__DataStorageC6lengthACSi_tcfc",
        "_$s10Foundation13__DataStorageC7_lengthSivg",
        "_$s10Foundation13__DataStorageC7_offsetSivg",
        "_$s10Foundation13__DataStorageCMa",
        "_$s10Foundation15ContiguousBytesP010withUnsafeC0yqd__qd__SWKXEKlFTj",
        "_$s10Foundation22_convertNSErrorToErrorys0E0_pSo0C0CSgF",
        "_$s10Foundation4DataV10LargeSliceV21ensureUniqueReferenceyyF",
        "_$s10Foundation4DataV11InlineSliceV21ensureUniqueReferenceyyF",
        "_$s10Foundation4DataV13_copyContents12initializingAC8IteratorV_SitSrys5UInt8VG_tF",
        "_$s10Foundation4DataV13base64Encoded7optionsACSgSSh_So27NSDataBase64DecodingOptionsVtcfC",
        "_$s10Foundation4DataV14RangeReferenceCMa",
        "_$s10Foundation4DataV15_RepresentationO15replaceSubrange_4with5countySnySiG_SVSgSitF",
        "_$s10Foundation4DataV15_RepresentationO6append10contentsOfySW_tF",
        "_$s10Foundation4DataV15_RepresentationON",
        "_$s10Foundation4DataV15_RepresentationOyACSnySiGcig",
        "_$s10Foundation4DataV15_RepresentationOys5UInt8VSicig",
        "_$s10Foundation4DataV19base64EncodedString7optionsSSSo27NSDataBase64EncodingOptionsV_tF",
        "_$s10Foundation4DataV36_unconditionallyBridgeFromObjectiveCyACSo6NSDataCSgFZ",
        "_$s10Foundation4DataV8IteratorV4nexts5UInt8VSgyF",
        "_$s10Foundation4DataV8IteratorVMa",
        "_$s10Foundation4DataV8IteratorVStAAMc",
        "_$s10Foundation4DataV8IteratorV_2atAeC_SitcfC",
        "_$s10Foundation4DataVAA15ContiguousBytesAAWP",
        "_$s10Foundation4DataVMn",
        "_$s10Foundation4DataVN",
        "_$s6Darwin5errnos5Int32Vvg",
        "_$s6Darwin5errnos5Int32Vvs",
        "_$s6Darwin6S_IFMTs6UInt16Vvg",
        "_$s6Darwin7S_IFCHRs6UInt16Vvg",
        "_$s6Darwin7S_IFDIRs6UInt16Vvg",
        "_$s6Darwin7S_IFIFOs6UInt16Vvg",
        "_$s6Darwin7S_IFREGs6UInt16Vvg",
        "_$s8Dispatch0A4TimeV17uptimeNanosecondss6UInt64Vvg",
        "_$s8Dispatch0A4TimeV3nowACyFZ",
        "_$s8Dispatch0A4TimeVMa",
        "_$s8RawValueSYTl",
        "_$s9CryptoKit12HashFunctionP6update13bufferPointerySW_tFTj",
        "_$s9CryptoKit12HashFunctionP8finalize6DigestQzyFTj",
        "_$s9CryptoKit12HashFunctionPxycfCTj",
        "_$s9CryptoKit12SHA256DigestV10Foundation15ContiguousBytesAAMc",
        "_$s9CryptoKit12SHA256DigestVMa",
        "_$s9CryptoKit6SHA256V8finalizeAA0C6DigestVyF",
        "_$s9CryptoKit6SHA256VAA12HashFunctionAAMc",
        "_$s9CryptoKit6SHA256VACycfC",
        "_$s9CryptoKit6SHA256VMa",
        "_$s9CryptoKit6SHA256VMn",
        "_$sBi32_WV",
        "_$sBi64_WV",
        "_$sBoWV",
        "_$sSH13_rawHashValue4seedS2i_tFTq",
        "_$sSH4hash4intoys6HasherVz_tFTq",
        "_$sSH9hashValueSivgTq",
        "_$sSHMp",
        "_$sSHSQTb",
        "_$sSQ2eeoiySbx_xtFZTq",
        "_$sSQMp",
        "_$sSS10FoundationE5bytes8encodingSSSgxh_SSAAE8EncodingVtcSTRzs5UInt8V7ElementRtzlufC",
        "_$sSS10FoundationE8EncodingV4utf8ACvgZ",
        "_$sSS10FoundationE8EncodingVMa",
        "_$sSS11utf8CStrings15ContiguousArrayVys4Int8VGvg",
        "_$sSS14validatingUTF8SSSgSPys4Int8VG_tcfC",
        "_$sSS18_fromUTF8RepairingySS6result_Sb11repairsMadetSRys5UInt8VGFZ",
        "_$sSS4hash4intoys6HasherVz_tF",
        "_$sSS6appendyySSF",
        "_$sSS8UTF8ViewV13_foreignCountSiyF",
        "_$sSS9repeating5countS2S_SitcfC",
        "_$sSSN",
        "_$sSSSHsWP",
        "_$sSSSysMc",
        "_$sSY8rawValue03RawB0QzvgTq",
        "_$sSY8rawValuexSg03RawB0Qz_tcfCTq",
        "_$sSYMp",
        "_$sSa034_makeUniqueAndReserveCapacityIfNotB0yyFyXl_Ts5",
        "_$sSa16_createNewBuffer14bufferIsUnique15minimumCapacity13growForAppendySb_SiSbtFyXl_Ts5",
        "_$sSa28_allocateBufferUninitialized15minimumCapacitys06_ArrayB0VyxGSi_tFZ",
        "_$sSa37_appendElementAssumeUniqueAndCapacity_03newB0ySi_xntFyXl_Ts5",
        "_$sSbN",
        "_$sSh15minimumCapacityShyxGSi_tcfC",
        "_$sSiN",
        "_$sSt4next7ElementQzSgyFTj",
        "_$sSy10FoundationE8containsySbqd__SyRd__lF",
        "_$ss10ArraySliceVMn",
        "_$ss10ArraySliceVyxG10Foundation15ContiguousBytesADs5UInt8VRszlMc",
        "_$ss10ArraySliceVyxGSTsMc",
        "_$ss11CommandLineO4argcs5Int32VvgZ",
        "_$ss11_SetStorageC4copy8originalAByxGs05__RawaB0C_tFZ",
        "_$ss11_SetStorageC6resize8original8capacity4moveAByxGs05__RawaB0C_SiSbtFZ",
        "_$ss11_SetStorageCMn",
        "_$ss11_StringGutsV16_foreignCopyUTF84intoSiSgSrys5UInt8VG_tF",
        "_$ss11_StringGutsV16_slowWithCStringyxxSPys4Int8VGKXEKlF",
        "_$ss11_StringGutsV4growyySiF",
        "_$ss12StaticStringVMn",
        "_$ss12_ArrayBufferV19_getElementSlowPathyyXlSiFyXl_Ts5",
        "_$ss13_StringObjectV10sharedUTF8SRys5UInt8VGvg",
        "_$ss15CollectionOfOneVMn",
        "_$ss15CollectionOfOneVyxG10Foundation15ContiguousBytesADs5UInt8VRszlMc",
        "_$ss15ContiguousArrayV28_allocateBufferUninitialized15minimumCapacitys01_abD0VyxGSi_tFZ",
        "_$ss18_CocoaArrayWrapperV8endIndexSivg",
        "_$ss18_DictionaryStorageC4copy8originalAByxq_Gs05__RawaB0C_tFZ",
        "_$ss18_DictionaryStorageC6resize8original8capacity4moveAByxq_Gs05__RawaB0C_SiSbtFZ",
        "_$ss18_DictionaryStorageC8allocate8capacityAByxq_GSi_tFZ",
        "_$ss18_DictionaryStorageCMn",
        "_$ss21_findStringSwitchCase5cases6stringSiSays06StaticB0VG_SStF",
        "_$ss22_minimumMergeRunLengthyS2iF",
        "_$ss23CustomStringConvertibleP11descriptionSSvgTj",
        "_$ss23_ContiguousArrayStorageCMn",
        "_$ss27_stringCompareWithSmolCheck__9expectingSbs11_StringGutsV_ADs01_G16ComparisonResultOtF",
        "_$ss28__ContiguousArrayStorageBaseCMa",
        "_$ss38_bridgeAnythingNonVerbatimToObjectiveCyyXlxnlF",
        "_$ss4Int8VMn",
        "_$ss4Int8VN",
        "_$ss50ELEMENT_TYPE_OF_SET_VIOLATES_HASHABLE_REQUIREMENTSys5NeverOypXpF",
        "_$ss53KEY_TYPE_OF_DICTIONARY_VIOLATES_HASHABLE_REQUIREMENTSys5NeverOypXpF",
        "_$ss5ErrorMp",
        "_$ss5ErrorP19_getEmbeddedNSErroryXlSgyFTq",
        "_$ss5ErrorP5_codeSivgTq",
        "_$ss5ErrorP7_domainSSvgTq",
        "_$ss5ErrorP9_userInfoyXlSgvgTq",
        "_$ss5ErrorPsE19_getEmbeddedNSErroryXlSgyF",
        "_$ss5ErrorPsE5_codeSivg",
        "_$ss5ErrorPsE7_domainSSvg",
        "_$ss5ErrorPsE9_userInfoyXlSgvg",
        "_$ss5Int16VMn",
        "_$ss5Int32VMn",
        "_$ss5Int32VN",
        "_$ss5Int32VSHsWP",
        "_$ss5Int64VN",
        "_$ss5Int64Vs23CustomStringConvertiblesWP",
        "_$ss5UInt8VMn",
        "_$ss5UInt8VN",
        "_$ss6HasherV5_hash4seed5bytes5countS2i_s6UInt64VSitFZ",
        "_$ss6HasherV5_seedABSi_tcfC",
        "_$ss6HasherV8_combineyySuF",
        "_$ss6HasherV9_finalizeSiyF",
        "_$ss6UInt16VMn",
        "_$ss6UInt32VMn",
        "_$ss6UInt32VN",
        "_$ss6UInt64VMn",
        "_$ss6UInt64VN",
        "_$sytWV",
        "_OBJC_CLASS_$_NSJSONSerialization",
        "_OBJC_CLASS_$_NSNull",
        "_OBJC_CLASS_$__TtCs12_SwiftObject",
        "_OBJC_METACLASS_$__TtCs12_SwiftObject",
        "__NSGetEnviron",
        "___chkstk_darwin",
        "___error",
        "___stack_chk_fail",
        "___stack_chk_guard",
        "__exit",
        "__objc_empty_cache",
        "__swiftEmptyArrayStorage",
        "__swiftEmptyDictionarySingleton",
        "__swift_FORCE_LOAD_$_swiftCoreFoundation",
        "__swift_FORCE_LOAD_$_swiftDispatch",
        "__swift_FORCE_LOAD_$_swiftFoundation",
        "__swift_FORCE_LOAD_$_swiftIOKit",
        "__swift_FORCE_LOAD_$_swiftObjectiveC",
        "__swift_FORCE_LOAD_$_swiftXPC",
        "__swift_FORCE_LOAD_$_swift_Builtin_float",
        "_acl_copy_ext",
        "_acl_free",
        "_acl_get_fd_np",
        "_acl_size",
        "_bzero",
        "_close",
        "_closedir",
        "_dup",
        "_fchmod",
        "_fcntl",
        "_fdopendir",
        "_fgetxattr",
        "_flistxattr",
        "_fpathconf",
        "_free",
        "_fstat",
        "_fstatat",
        "_fstatfs",
        "_fsync",
        "_getcwd",
        "_getegid",
        "_geteuid",
        "_getpgid",
        "_getpid",
        "_getsid",
        "_isatty",
        "_kevent",
        "_kill",
        "_kqueue",
        "_malloc_size",
        "_memcmp",
        "_memcpy",
        "_memmove",
        "_mkdirat",
        "_objc_allocWithZone",
        "_objc_msgSend",
        "_objc_opt_self",
        "_objc_release",
        "_objc_retain",
        "_objc_retainAutoreleasedReturnValue",
        "_open",
        "_openat",
        "_pipe",
        "_posix_spawn",
        "_posix_spawn_file_actions_addclose",
        "_posix_spawn_file_actions_adddup2",
        "_posix_spawn_file_actions_addfchdir_np",
        "_posix_spawn_file_actions_addinherit_np",
        "_posix_spawn_file_actions_destroy",
        "_posix_spawn_file_actions_init",
        "_posix_spawnattr_destroy",
        "_posix_spawnattr_init",
        "_posix_spawnattr_setflags",
        "_posix_spawnattr_setsigdefault",
        "_posix_spawnattr_setsigmask",
        "_pread",
        "_proc_listpids",
        "_proc_pidfdinfo",
        "_proc_pidinfo",
        "_pselect",
        "_pwrite",
        "_read",
        "_readdir",
        "_sigaddset",
        "_sigemptyset",
        "_sleep",
        "_strdup",
        "_swift_allocBox",
        "_swift_allocError",
        "_swift_allocObject",
        "_swift_allocateGenericClassMetadata",
        "_swift_arrayDestroy",
        "_swift_arrayInitWithCopy",
        "_swift_beginAccess",
        "_swift_bridgeObjectRelease",
        "_swift_bridgeObjectRelease_n",
        "_swift_bridgeObjectRetain",
        "_swift_bridgeObjectRetain_n",
        "_swift_deallocClassInstance",
        "_swift_deallocObject",
        "_swift_deallocPartialClassInstance",
        "_swift_deletedMethodError",
        "_swift_dynamicCastClass",
        "_swift_endAccess",
        "_swift_errorRelease",
        "_swift_getEnumTagSinglePayloadGeneric",
        "_swift_getForeignTypeMetadata",
        "_swift_getGenericMetadata",
        "_swift_getObjCClassMetadata",
        "_swift_getSingletonMetadata",
        "_swift_getTypeByMangledNameInContext2",
        "_swift_getTypeByMangledNameInContextInMetadataState2",
        "_swift_getWitnessTable",
        "_swift_initClassMetadata2",
        "_swift_initStackObject",
        "_swift_initStaticObject",
        "_swift_initStructMetadata",
        "_swift_isUniquelyReferenced_nonNull_native",
        "_swift_once",
        "_swift_release",
        "_swift_release_n",
        "_swift_retain",
        "_swift_setDeallocating",
        "_swift_storeEnumTagSinglePayloadGeneric",
        "_swift_unknownObjectRelease",
        "_swift_unknownObjectRetain",
        "_swift_unknownObjectRetain_n",
        "_swift_willThrow",
        "_umask",
        "_waitpid",
        "_write"
    ]
}

private enum PrimeR19ArchiveIO {
    static func requireIngress() throws {
        guard CommandLine.argc == 1,
              let environment = primeR19ArchiveNSGetEnviron().pointee,
              environment.pointee == nil
        else { throw PrimeR19ArchiveFailure.rejected }
        var cwd = [CChar](repeating: 0, count: Int(PATH_MAX))
        let result = cwd.withUnsafeMutableBufferPointer {
            getcwd($0.baseAddress, $0.count)
        }
        guard result != nil,
              cwd[0] == CChar(UInt8(ascii: "/")), cwd[1] == 0
        else { throw PrimeR19ArchiveFailure.rejected }
        guard prime_r19_archive_validate_stdin_devnull() == 0 else {
            throw PrimeR19ArchiveFailure.rejected
        }
    }

    static func sha256(_ bytes: Data) -> String {
        let alphabet = Array("0123456789abcdef".utf8)
        var result = [UInt8]()
        result.reserveCapacity(64)
        for byte in SHA256.hash(data: bytes) {
            result.append(alphabet[Int(byte >> 4)])
            result.append(alphabet[Int(byte & 0x0F)])
        }
        return String(decoding: result, as: UTF8.self)
    }

    static func hex(_ bytes: Data) -> String {
        let alphabet = Array("0123456789abcdef".utf8)
        var result = [UInt8]()
        result.reserveCapacity(bytes.count * 2)
        for byte in bytes {
            result.append(alphabet[Int(byte >> 4)])
            result.append(alphabet[Int(byte & 0x0F)])
        }
        return String(decoding: result, as: UTF8.self)
    }

    static func readAll(_ descriptor: Int32, size: UInt64) throws -> Data {
        guard size <= UInt64(PrimeR19ArchiveConstants.maximumFileBytes),
              size <= UInt64(Int.max)
        else { throw PrimeR19ArchiveFailure.rejected }
        var bytes = Data(count: Int(size))
        var offset = 0
        try bytes.withUnsafeMutableBytes { raw in
            while offset < raw.count {
                guard let base = raw.baseAddress else {
                    throw PrimeR19ArchiveFailure.rejected
                }
                let count = pread(
                    descriptor, base.advanced(by: offset), raw.count - offset,
                    off_t(offset)
                )
                if count < 0, errno == EINTR { continue }
                guard count > 0 else { throw PrimeR19ArchiveFailure.rejected }
                offset += count
            }
        }
        var trailing: UInt8 = 0
        var trailingCount: Int
        repeat {
            trailingCount = pread(descriptor, &trailing, 1, off_t(size))
        } while trailingCount < 0 && errno == EINTR
        guard trailingCount == 0 else { throw PrimeR19ArchiveFailure.rejected }
        return bytes
    }

    static func writeAll(_ bytes: Data, descriptor: Int32) throws {
        var offset = 0
        try bytes.withUnsafeBytes { raw in
            while offset < raw.count {
                guard let base = raw.baseAddress else {
                    throw PrimeR19ArchiveFailure.rejected
                }
                let count = pwrite(
                    descriptor, base.advanced(by: offset), raw.count - offset,
                    off_t(offset)
                )
                if count < 0, errno == EINTR { continue }
                guard count > 0 else { throw PrimeR19ArchiveFailure.rejected }
                offset += count
            }
        }
    }

    static func fullSync(_ descriptor: Int32) throws {
        guard prime_r19_archive_full_fsync(descriptor) == 0 else {
            throw PrimeR19ArchiveFailure.rejected
        }
    }

    static func modeString(_ mode: UInt16) -> String {
        let raw = String(mode, radix: 8)
        return String(repeating: "0", count: max(0, 4 - raw.count)) + raw
    }

    static func listNames(_ descriptor: Int32) throws -> [Data] {
        let duplicate = fcntl(descriptor, F_DUPFD_CLOEXEC, 3)
        guard duplicate >= 3, let directory = fdopendir(duplicate) else {
            if duplicate >= 0 { _ = Darwin.close(duplicate) }
            throw PrimeR19ArchiveFailure.rejected
        }
        defer { _ = closedir(directory) }
        var names = [Data]()
        while true {
            errno = 0
            guard let pointer = readdir(directory) else {
                guard errno == 0 else { throw PrimeR19ArchiveFailure.rejected }
                break
            }
            let entry = pointer.pointee
            let count = Int(entry.d_namlen)
            guard count > 0, count <= Int(MAXNAMLEN) else {
                throw PrimeR19ArchiveFailure.rejected
            }
            var field = entry.d_name
            let name = withUnsafeBytes(of: &field) { Data($0.prefix(count)) }
            if name == Data(".".utf8) || name == Data("..".utf8) { continue }
            guard !name.contains(0) else { throw PrimeR19ArchiveFailure.rejected }
            names.append(name)
        }
        return names.sorted { $0.lexicographicallyPrecedes($1) }
    }

    static func requireInventory(_ descriptor: Int32, expected: [String]) throws {
        let wanted = expected.map { Data($0.utf8) }.sorted {
            $0.lexicographicallyPrecedes($1)
        }
        guard try listNames(descriptor) == wanted else {
            throw PrimeR19ArchiveFailure.rejected
        }
    }

    static func scanRoot(_ descriptor: Int32) throws -> PrimeR19ArchiveAggregate {
        let topData = try listNames(descriptor)
        let top = try topData.map {
            guard let value = String(data: $0, encoding: .utf8) else {
                throw PrimeR19ArchiveFailure.rejected
            }
            return value
        }
        var directories = 0
        var files = 0
        var bytes: UInt64 = 0
        try scanDirectory(
            descriptor, directories: &directories, files: &files, bytes: &bytes
        )
        guard directories <= PrimeR19ArchiveConstants.maximumTreeDirectories,
              files <= PrimeR19ArchiveConstants.maximumTreeFiles,
              bytes <= PrimeR19ArchiveConstants.maximumTreeBytes
        else { throw PrimeR19ArchiveFailure.rejected }
        return PrimeR19ArchiveAggregate(
            bytes: bytes, directories: directories, files: files,
            topInventory: top
        )
    }

    private static func scanDirectory(
        _ descriptor: Int32,
        directories: inout Int,
        files: inout Int,
        bytes: inout UInt64
    ) throws {
        for name in try listNames(descriptor) {
            var terminated = name
            terminated.append(0)
            var metadata = stat()
            let statResult = terminated.withUnsafeBytes {
                fstatat(
                    descriptor, $0.baseAddress!.assumingMemoryBound(to: CChar.self),
                    &metadata, AT_SYMLINK_NOFOLLOW
                )
            }
            guard statResult == 0 else { throw PrimeR19ArchiveFailure.rejected }
            let type = metadata.st_mode & mode_t(S_IFMT)
            if type == mode_t(S_IFREG) {
                guard metadata.st_size >= 0 else {
                    throw PrimeR19ArchiveFailure.rejected
                }
                files += 1
                bytes = try adding(bytes, UInt64(metadata.st_size))
            } else if type == mode_t(S_IFDIR) {
                directories += 1
                let childRaw = terminated.withUnsafeBytes {
                    Darwin.openat(
                        descriptor,
                        $0.baseAddress!.assumingMemoryBound(to: CChar.self),
                        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY
                    )
                }
                let child = try PrimeR19ArchiveFD(childRaw)
                try scanDirectory(
                    child.rawValue, directories: &directories,
                    files: &files, bytes: &bytes
                )
            } else {
                throw PrimeR19ArchiveFailure.rejected
            }
            guard directories <= PrimeR19ArchiveConstants.maximumTreeDirectories,
                  files <= PrimeR19ArchiveConstants.maximumTreeFiles,
                  bytes <= PrimeR19ArchiveConstants.maximumTreeBytes
            else { throw PrimeR19ArchiveFailure.rejected }
        }
    }

    private static func adding(_ lhs: UInt64, _ rhs: UInt64) throws -> UInt64 {
        let (result, overflow) = lhs.addingReportingOverflow(rhs)
        guard !overflow else { throw PrimeR19ArchiveFailure.rejected }
        return result
    }

    static func xattrs(_ descriptor: Int32) throws -> [PrimeR19ArchiveXattr] {
        let first = prime_r19_archive_list_xattrs(descriptor, nil, 0)
        guard first >= 0,
              first <= Int64(PrimeR19ArchiveConstants.maximumXattrListBytes)
        else { throw PrimeR19ArchiveFailure.rejected }
        if first == 0 { return [] }
        var list = Data(count: Int(first))
        let second = list.withUnsafeMutableBytes {
            prime_r19_archive_list_xattrs(
                descriptor, $0.baseAddress, $0.count
            )
        }
        guard second == first, list.last == 0 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        var names = [Data]()
        var start = 0
        for index in list.indices where list[index] == 0 {
            guard index > start else { throw PrimeR19ArchiveFailure.rejected }
            names.append(list.subdata(in: start..<index))
            start = index + 1
        }
        guard start == list.count else { throw PrimeR19ArchiveFailure.rejected }
        names.sort { $0.lexicographicallyPrecedes($1) }
        guard Set(names).count == names.count else {
            throw PrimeR19ArchiveFailure.rejected
        }
        return try names.map { name in
            var terminated = name
            terminated.append(0)
            let size = terminated.withUnsafeBytes {
                prime_r19_archive_get_xattr(
                    descriptor,
                    $0.baseAddress!.assumingMemoryBound(to: CChar.self), nil, 0
                )
            }
            guard size >= 0,
                  size <= Int64(PrimeR19ArchiveConstants.maximumXattrBytes)
            else { throw PrimeR19ArchiveFailure.rejected }
            var value = Data(count: Int(size))
            let read = terminated.withUnsafeBytes { nameRaw in
                value.withUnsafeMutableBytes { valueRaw in
                    prime_r19_archive_get_xattr(
                        descriptor,
                        nameRaw.baseAddress!.assumingMemoryBound(to: CChar.self),
                        valueRaw.baseAddress, valueRaw.count
                    )
                }
            }
            guard read == size else { throw PrimeR19ArchiveFailure.rejected }
            return PrimeR19ArchiveXattr(name: name, value: value)
        }
    }
}

private enum PrimeR19ArchiveAdmission {
    static func openAll() throws -> [PrimeR19HeldNode] {
        var result = [PrimeR19HeldNode]()
        result.reserveCapacity(10)
        for expected in PrimeR19ArchiveConstants.expectedNodes {
            let descriptor = try PrimeR19ArchiveFD(
                prime_r19_archive_open_node(expected.ordinal)
            )
            let (facts, bytes) = try capture(
                descriptor.rawValue, expected: expected, requireNamedJoin: true
            )
            let xattrs = facts.type == "REGULAR_FILE"
                ? try PrimeR19ArchiveIO.xattrs(descriptor.rawValue) : nil
            result.append(
                PrimeR19HeldNode(
                    expected: expected, descriptor: descriptor,
                    admission: facts, admissionBytes: bytes,
                    admissionXattrs: xattrs
                )
            )
        }
        guard result.count == 10 else { throw PrimeR19ArchiveFailure.rejected }
        try requireParentFilesystem(result[0].descriptor.rawValue)
        return result
    }

    static func revalidate(_ node: PrimeR19HeldNode) throws
        -> PrimeR19ArchiveFacts
    {
        let (facts, _) = try capture(
            node.descriptor.rawValue,
            expected: node.expected,
            requireNamedJoin: true
        )
        guard facts == node.admission else {
            throw PrimeR19ArchiveFailure.rejected
        }
        return facts
    }

    static func requireParentFilesystem(_ descriptor: Int32) throws {
        guard prime_r19_archive_validate_parent_filesystem(descriptor) == 0 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        var uuid = [UInt8](repeating: 0, count: 16)
        let result = uuid.withUnsafeMutableBufferPointer {
            prime_r19_archive_parent_volume_uuid(descriptor, $0.baseAddress)
        }
        guard result == 0, uuid == PrimeR19ArchiveConstants.volumeUUID else {
            throw PrimeR19ArchiveFailure.rejected
        }
    }

    static func requireParent(
        _ parent: PrimeR19HeldNode,
        requiredNlink: UInt64
    ) throws -> PrimeR19ArchiveFacts {
        var metadata = stat()
        guard fstat(parent.descriptor.rawValue, &metadata) == 0 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        let observed = try facts(metadata, descriptor: nil, aggregate: nil)
        let baseline = parent.expected.facts
        guard observed.device == baseline.device,
              observed.inode == baseline.inode,
              observed.uid == baseline.uid,
              observed.gid == baseline.gid,
              observed.mode == baseline.mode,
              observed.nlink == requiredNlink,
              observed.type == "DIRECTORY"
        else { throw PrimeR19ArchiveFailure.rejected }
        let named = try PrimeR19ArchiveFD(prime_r19_archive_open_node(0))
        var namedMetadata = stat()
        guard fstat(named.rawValue, &namedMetadata) == 0,
              vnode(metadata) == vnode(namedMetadata)
        else { throw PrimeR19ArchiveFailure.rejected }
        try requireParentFilesystem(parent.descriptor.rawValue)
        return observed
    }

    private static func capture(
        _ descriptor: Int32,
        expected: PrimeR19ExpectedNode,
        requireNamedJoin: Bool
    ) throws -> (PrimeR19ArchiveFacts, Data?) {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        let aggregate = expected.facts.aggregate == nil
            ? nil : try PrimeR19ArchiveIO.scanRoot(descriptor)
        let observed = try facts(
            metadata, descriptor: descriptor, aggregate: aggregate
        )
        guard observed == expected.facts else {
            throw PrimeR19ArchiveFailure.rejected
        }
        var bytes: Data?
        if let size = observed.bytes {
            let value = try PrimeR19ArchiveIO.readAll(descriptor, size: size)
            guard PrimeR19ArchiveIO.sha256(value) == observed.sha256 else {
                throw PrimeR19ArchiveFailure.rejected
            }
            bytes = value
        }
        if requireNamedJoin {
            let named = try PrimeR19ArchiveFD(
                prime_r19_archive_open_node(expected.ordinal)
            )
            var namedMetadata = stat()
            guard fstat(named.rawValue, &namedMetadata) == 0,
                  vnode(metadata) == vnode(namedMetadata)
            else { throw PrimeR19ArchiveFailure.rejected }
        }
        return (observed, bytes)
    }

    static func facts(
        _ metadata: stat,
        descriptor: Int32?,
        aggregate: PrimeR19ArchiveAggregate?
    ) throws -> PrimeR19ArchiveFacts {
        let rawType = metadata.st_mode & mode_t(S_IFMT)
        let type: String
        let bytes: UInt64?
        let flags: UInt64?
        let sha: String?
        if rawType == mode_t(S_IFREG) {
            guard metadata.st_size >= 0, let descriptor else {
                throw PrimeR19ArchiveFailure.rejected
            }
            type = "REGULAR_FILE"
            bytes = UInt64(metadata.st_size)
            flags = UInt64(metadata.st_flags)
            let data = try PrimeR19ArchiveIO.readAll(descriptor, size: bytes!)
            sha = PrimeR19ArchiveIO.sha256(data)
        } else if rawType == mode_t(S_IFDIR) {
            type = "DIRECTORY"
            bytes = nil
            flags = nil
            sha = nil
        } else {
            throw PrimeR19ArchiveFailure.rejected
        }
        return PrimeR19ArchiveFacts(
            bytes: bytes,
            device: UInt64(UInt32(bitPattern: metadata.st_dev)),
            flags: flags,
            gid: UInt64(metadata.st_gid),
            inode: UInt64(metadata.st_ino),
            mode: UInt16(metadata.st_mode & mode_t(0o7777)),
            nlink: UInt64(metadata.st_nlink),
            sha256: sha,
            type: type,
            uid: UInt64(metadata.st_uid),
            aggregate: aggregate
        )
    }

    static func vnode(_ metadata: stat) -> PrimeR19ArchiveVnode {
        PrimeR19ArchiveVnode(
            device: UInt64(UInt32(bitPattern: metadata.st_dev)),
            inode: UInt64(metadata.st_ino)
        )
    }
}

private enum PrimeR19ArchiveMachO {
    static func requireFrozenIdentity(_ bytes: Data) throws {
        guard bytes.count == 357_672,
              little32(bytes, 0) == 0xFEED_FACF,
              little32(bytes, 4) == 0x0100_000C,
              little32(bytes, 12) == 2,
              little32(bytes, 16) == 30,
              little32(bytes, 20) == 3_968,
              little32(bytes, 24) == 0x0020_0085
        else { throw PrimeR19ArchiveFailure.rejected }
        var cursor = 32
        var uuid: String?
        var entryoff: UInt64?
        var signature: (Int, Int)?
        var minimum: UInt32?
        var sdk: UInt32?
        for _ in 0..<30 {
            let command = little32(bytes, cursor)
            let size = Int(little32(bytes, cursor + 4))
            guard size >= 8, cursor + size <= 32 + 3_968 else {
                throw PrimeR19ArchiveFailure.rejected
            }
            switch command {
            case 0x1B:
                guard size == 24, uuid == nil else {
                    throw PrimeR19ArchiveFailure.rejected
                }
                uuid = uuidString(Data(bytes[(cursor + 8)..<(cursor + 24)]))
            case 0x8000_0028:
                guard size == 24, entryoff == nil else {
                    throw PrimeR19ArchiveFailure.rejected
                }
                entryoff = little64(bytes, cursor + 8)
            case 0x1D:
                guard size == 16, signature == nil else {
                    throw PrimeR19ArchiveFailure.rejected
                }
                signature = (
                    Int(little32(bytes, cursor + 8)),
                    Int(little32(bytes, cursor + 12))
                )
            case 0x32:
                guard size >= 24, minimum == nil, sdk == nil else {
                    throw PrimeR19ArchiveFailure.rejected
                }
                minimum = little32(bytes, cursor + 12)
                sdk = little32(bytes, cursor + 16)
            default:
                break
            }
            cursor += size
        }
        guard cursor == 32 + 3_968,
              uuid == "76733178-02E8-3584-8FF9-F5A2744EF226",
              entryoff == 61_780,
              signature?.0 == 354_736,
              signature?.1 == 2_936,
              minimum == 0x000E_0000,
              sdk == 0x001A_0500,
              let signature
        else { throw PrimeR19ArchiveFailure.rejected }
        try requireCodeDirectory(
            Data(bytes[signature.0..<(signature.0 + signature.1)])
        )
    }

    private static func requireCodeDirectory(_ signature: Data) throws {
        guard signature.count == 2_936,
              big32(signature, 0) == 0xFADE_0CC0
        else { throw PrimeR19ArchiveFailure.rejected }
        let count = Int(big32(signature, 8))
        guard count > 0, 12 + count * 8 <= signature.count else {
            throw PrimeR19ArchiveFailure.rejected
        }
        var codeDirectory: Data?
        for index in 0..<count {
            let slot = Int(big32(signature, 12 + index * 8))
            let offset = Int(big32(signature, 16 + index * 8))
            guard offset >= 0, offset + 8 <= signature.count else {
                throw PrimeR19ArchiveFailure.rejected
            }
            if slot == 0 {
                guard codeDirectory == nil,
                      big32(signature, offset) == 0xFADE_0C02
                else { throw PrimeR19ArchiveFailure.rejected }
                let length = Int(big32(signature, offset + 4))
                guard length == 2_915, offset + length <= signature.count else {
                    throw PrimeR19ArchiveFailure.rejected
                }
                codeDirectory = Data(signature[offset..<(offset + length)])
            }
        }
        guard let codeDirectory,
              big32(codeDirectory, 8) == 0x0002_0400,
              big32(codeDirectory, 12) == 0x0002_0002,
              big64(codeDirectory, 72) == 140_208,
              PrimeR19ArchiveIO.sha256(codeDirectory) ==
                "4f594b113c6e4fa9c7fd188fc9fc82d84018c1a666bceb506e069ac1746438ff"
        else { throw PrimeR19ArchiveFailure.rejected }
    }

    private static func little32(_ data: Data, _ offset: Int) -> UInt32 {
        guard offset >= 0, offset + 4 <= data.count else { return UInt32.max }
        return UInt32(data[offset]) |
            UInt32(data[offset + 1]) << 8 |
            UInt32(data[offset + 2]) << 16 |
            UInt32(data[offset + 3]) << 24
    }

    private static func little64(_ data: Data, _ offset: Int) -> UInt64 {
        guard offset >= 0, offset + 8 <= data.count else { return UInt64.max }
        var result: UInt64 = 0
        for index in 0..<8 {
            result |= UInt64(data[offset + index]) << UInt64(index * 8)
        }
        return result
    }

    private static func big32(_ data: Data, _ offset: Int) -> UInt32 {
        guard offset >= 0, offset + 4 <= data.count else { return UInt32.max }
        return UInt32(data[offset]) << 24 |
            UInt32(data[offset + 1]) << 16 |
            UInt32(data[offset + 2]) << 8 |
            UInt32(data[offset + 3])
    }

    private static func big64(_ data: Data, _ offset: Int) -> UInt64 {
        guard offset >= 0, offset + 8 <= data.count else { return UInt64.max }
        var result: UInt64 = 0
        for index in 0..<8 {
            result = result << 8 | UInt64(data[offset + index])
        }
        return result
    }

    private static func uuidString(_ bytes: Data) -> String {
        let raw = PrimeR19ArchiveIO.hex(bytes).uppercased()
        guard raw.count == 32 else { return "" }
        let cuts = [8, 12, 16, 20]
        var result = ""
        for (index, character) in raw.enumerated() {
            if cuts.contains(index) { result.append("-") }
            result.append(character)
        }
        return result
    }
}

private enum PrimeR19ArchiveIdentityJSON {
    static func file(_ facts: PrimeR19ArchiveFacts, path: String)
        -> PrimeR19JSON
    {
        .object([
            "bytes_decimal": .string(String(facts.bytes!)),
            "device_decimal": .string(String(facts.device)),
            "flags_decimal": .string(String(facts.flags!)),
            "gid_decimal": .string(String(facts.gid)),
            "inode_decimal": .string(String(facts.inode)),
            "mode": .string(PrimeR19ArchiveIO.modeString(facts.mode)),
            "named_held_join": .boolean(true),
            "nlink_decimal": .string(String(facts.nlink)),
            "path": .string(path),
            "realpath": .string(path),
            "sha256": .string(facts.sha256!),
            "type": .string("REGULAR_FILE"),
            "uid_decimal": .string(String(facts.uid)),
        ])
    }

    static func directory(_ facts: PrimeR19ArchiveFacts, path: String)
        -> PrimeR19JSON
    {
        .object([
            "device_decimal": .string(String(facts.device)),
            "gid_decimal": .string(String(facts.gid)),
            "inode_decimal": .string(String(facts.inode)),
            "mode": .string(PrimeR19ArchiveIO.modeString(facts.mode)),
            "named_held_join": .boolean(true),
            "nlink_decimal": .string(String(facts.nlink)),
            "path": .string(path),
            "realpath": .string(path),
            "type": .string("DIRECTORY"),
            "uid_decimal": .string(String(facts.uid)),
        ])
    }

    static func root(_ facts: PrimeR19ArchiveFacts, path: String)
        -> PrimeR19JSON
    {
        let aggregate = facts.aggregate!
        return .object([
            "aggregate_descendant_file_bytes_decimal":
                .string(String(aggregate.bytes)),
            "descendant_directories": .integer(aggregate.directories),
            "descendant_files": .integer(aggregate.files),
            "device_decimal": .string(String(facts.device)),
            "gid_decimal": .string(String(facts.gid)),
            "inode_decimal": .string(String(facts.inode)),
            "mode": .string(PrimeR19ArchiveIO.modeString(facts.mode)),
            "named_held_join": .boolean(true),
            "nlink_decimal": .string(String(facts.nlink)),
            "path": .string(path),
            "realpath": .string(path),
            "top_inventory": .array(aggregate.topInventory.map { .string($0) }),
            "type": .string("DIRECTORY"),
            "uid_decimal": .string(String(facts.uid)),
        ])
    }

    static func validated(
        admission: PrimeR19ArchiveFacts,
        expected: PrimeR19ExpectedNode,
        preseal: PrimeR19ArchiveFacts
    ) -> PrimeR19JSON {
        let make: (PrimeR19ArchiveFacts) -> PrimeR19JSON = { facts in
            if facts.aggregate != nil { return root(facts, path: expected.path) }
            if facts.type == "DIRECTORY" {
                return directory(facts, path: expected.path)
            }
            return file(facts, path: expected.path)
        }
        return .object([
            "admission": make(admission),
            "expected": make(expected.facts),
            "preseal": make(preseal),
        ])
    }

    static func xattrArray(_ values: [PrimeR19ArchiveXattr]) -> PrimeR19JSON {
        .array(values.map {
            .object([
                "name_hex": .string(PrimeR19ArchiveIO.hex($0.name)),
                "value_hex": .string(PrimeR19ArchiveIO.hex($0.value)),
            ])
        })
    }
}

private enum PrimeR19ArchiveLeafWriter {
    static func create(
        root: Int32,
        ordinal: UInt32,
        relativePath: String,
        bytes: Data,
        observeXattrs: Bool
    ) throws -> PrimeR19ArchiveLeaf {
        guard ordinal < 19,
              relativePath == PrimeR19ArchiveConstants.leafPaths[Int(ordinal)],
              !bytes.isEmpty,
              bytes.count <= PrimeR19ArchiveConstants.maximumFileBytes
        else { throw PrimeR19ArchiveFailure.rejected }
        let descriptor = try PrimeR19ArchiveFD(
            prime_r19_archive_create_leaf(root, ordinal)
        )
        let initial = try capture(descriptor.rawValue, expectedSize: 0)
        guard initial.mode == 0o000, initial.nlink == 1 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        try PrimeR19ArchiveIO.writeAll(bytes, descriptor: descriptor.rawValue)
        _ = PrimeR19ArchiveIO.sha256(bytes)
        try PrimeR19ArchiveIO.fullSync(descriptor.rawValue)
        guard fchmod(descriptor.rawValue, mode_t(0o400)) == 0 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        try PrimeR19ArchiveIO.fullSync(descriptor.rawValue)
        let facts = try capture(
            descriptor.rawValue, expectedSize: UInt64(bytes.count)
        )
        guard facts.mode == 0o400,
              facts.nlink == 1,
              facts.flags == 0,
              facts.sha256 == PrimeR19ArchiveIO.sha256(bytes),
              facts.uid == UInt64(geteuid()), facts.gid == 20
        else { throw PrimeR19ArchiveFailure.rejected }
        try requireNamedJoin(root: root, ordinal: ordinal, facts: facts)
        let xattrs = observeXattrs
            ? try PrimeR19ArchiveIO.xattrs(descriptor.rawValue) : nil
        return PrimeR19ArchiveLeaf(
            descriptor: descriptor, facts: facts, ordinal: ordinal,
            relativePath: relativePath, xattrs: xattrs
        )
    }

    static func revalidate(
        root: Int32,
        leaf: PrimeR19ArchiveLeaf,
        xattrs: [PrimeR19ArchiveXattr]?
    ) throws {
        let held = try capture(
            leaf.descriptor.rawValue, expectedSize: leaf.facts.bytes!
        )
        guard held == leaf.facts else { throw PrimeR19ArchiveFailure.rejected }
        try requireNamedJoin(root: root, ordinal: leaf.ordinal, facts: leaf.facts)
        if let xattrs {
            guard try PrimeR19ArchiveIO.xattrs(leaf.descriptor.rawValue) == xattrs
            else { throw PrimeR19ArchiveFailure.rejected }
        }
    }

    private static func requireNamedJoin(
        root: Int32,
        ordinal: UInt32,
        facts: PrimeR19ArchiveFacts
    ) throws {
        let named = try PrimeR19ArchiveFD(
            prime_r19_archive_open_leaf(root, ordinal)
        )
        let observed = try capture(named.rawValue, expectedSize: facts.bytes!)
        guard observed == facts else { throw PrimeR19ArchiveFailure.rejected }
    }

    private static func capture(
        _ descriptor: Int32,
        expectedSize: UInt64
    ) throws -> PrimeR19ArchiveFacts {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              metadata.st_size >= 0,
              UInt64(metadata.st_size) == expectedSize
        else { throw PrimeR19ArchiveFailure.rejected }
        return try PrimeR19ArchiveAdmission.facts(
            metadata, descriptor: descriptor, aggregate: nil
        )
    }
}

private enum PrimeR19ArchiveDataLeaves {
    static func wrapped(schema: String, payload: PrimeR19JSON) -> Data {
        let payloadBytes = payload.canonical
        return PrimeR19JSON.object([
            "payload": payload,
            "payload_hash_rule":
                .string(PrimeR19ArchiveConstants.payloadHashRule),
            "payload_sha256":
                .string(PrimeR19ArchiveIO.sha256(payloadBytes)),
            "schema": .string(schema),
            "status": .string("SEALED_PREPUBLICATION"),
        ]).canonical
    }

    static func control() -> Data {
        func reference(
            _ commit: String, _ tree: String, _ payload: String,
            _ frame: String, _ frameLF: String
        ) -> PrimeR19JSON {
            .object([
                "commit": .string(commit),
                "frame_sha256": .string(frame),
                "frame_with_lf_sha256": .string(frameLF),
                "payload_sha256": .string(payload),
                "tree": .string(tree),
            ])
        }
        let payload = PrimeR19JSON.object([
            "archive_scope": .string("LOCAL_APFS_STORAGE_DURABILITY_ONLY"),
            "authority": .object([
                "authority_vector": .string("00000000"),
                "gate_e": .string("ABSTAIN"),
                "scientific_authorities_closed": .integer(0),
            ]),
            "control_refs": .object([
                "crs12": reference(
                    "ce8e584e3588e40c57d57790c4edfc44a07b7c41",
                    "a3e217fb16366fb5614e74b36d5e043d2f884f5a",
                    "bd6ba52eb6566a37dcfe504f4db94b3cc27abdc5abaf1c3ca325dc4bad9869d8",
                    "f9dcb2dcec7bb953753806307786d23669f62a4c82707eda2d60f9c30b803be4",
                    "d351ac313fd8a343ac5411e95e8d2777b0e38a552aabad472ca54075d407184f"
                ),
                "crs13": reference(
                    "d1ff526a09f05422b96b11fcc3e04c1d9746f21c",
                    "0754e09c7aa838d195757d9e627065c136917202",
                    "825836ea9b93337041a362bcb5c0ef00a3260de444a28fa63e18e0e802fdbaa8",
                    "04bbb980dc60b8c49b43a6b5d9079f035315c6a69ebac7f99c36e57d314ba596",
                    "e69b39b9d2804db61328462a207129233867343aea9f56fc3a0322873c53ea65"
                ),
                "crs15": reference(
                    "ee61d20983b60d1305676b754fd6d959eb12aa46",
                    "ffeec316170041036c62c7b86fcec6d25416f853",
                    "2ca86a28d3c8067f867a02a2a6c95aaf1fae33544de1aa9bf0ee85bb8709a06a",
                    "e7dcfbb14a03ddb34b3718e065f3815a55546f918bd90a33cc9cdf28bb63aaf7",
                    "3f2a6065230878da1684da94351503ee7d601a2d62d9db58c46aa6d20a825c34"
                ),
                "crs16": reference(
                    "6209bd02ac1b5e7ba3d714a85bd8332a6f1050aa",
                    "e8cf83432ee7a53bc7a5aac62102cf8cc5728f44",
                    "47282ad29fe43b09e99789c752c5546598e53d444e6181a5bf344ed614c9eae8",
                    "17283b607283a57a688bf1dee277905a265ac01701dcd026205a7e5c652d34c7",
                    "d4dcca2fe47225ba7a3d92f54f5618cc982868f430c39311f6b4e542a14531f9"
                ),
            ]),
            "destination": .object([
                "final_leaf": .string(PrimeR19ArchiveConstants.finalLeaf),
                "parent_path": .string(PrimeR19ArchiveConstants.parentPath),
                "staging_leaf": .string(PrimeR19ArchiveConstants.stagingLeaf),
            ]),
            "hash_contract": .object([
                "data_wrapper": .string(
                    "PAYLOAD_SHA256_FOR_DATA00_AND_DATA02_THROUGH_DATA10"
                ),
                "manifest": .string(
                    "WHOLE_LEAF_SHA256_SUCCESSOR_ONLY_NO_SELF_ENTRY"
                ),
                "raw_crs12_exception": .string(
                    "EXACT_CRS12_FRAME_BYTES_UNCHANGED_NO_WRAPPER"
                ),
            ]),
            "timing": .object([
                "archive_data_observations": .string("PREPUBLICATION_ONLY"),
                "postpublication_record":
                    .string("SUCCESSOR_CONTROL_RESULT_ONLY"),
            ]),
        ])
        return wrapped(
            schema: "prime_driver_v2_r19_local_archive_control_v1",
            payload: payload
        )
    }

    static func crs12Frame() throws -> Data {
        guard let bytes = Data(
            base64Encoded: PrimeR19ArchiveConstants.crs12FrameBase64
        ),
              bytes.count == 14_470,
              PrimeR19ArchiveIO.sha256(bytes) ==
                "f9dcb2dcec7bb953753806307786d23669f62a4c82707eda2d60f9c30b803be4",
              bytes.last != 0x0A
        else { throw PrimeR19ArchiveFailure.rejected }
        return bytes
    }

    static func origins(
        label: String,
        role: String,
        root: PrimeR19HeldNode,
        object: PrimeR19HeldNode,
        product: PrimeR19HeldNode,
        preseal: [UInt32: PrimeR19ArchiveFacts],
        schema: String
    ) throws -> Data {
        guard let rootPreseal = preseal[root.expected.ordinal],
              let objectPreseal = preseal[object.expected.ordinal],
              let productPreseal = preseal[product.expected.ordinal]
        else { throw PrimeR19ArchiveFailure.rejected }
        let payload = PrimeR19JSON.object([
            "label": .string(label),
            "object": PrimeR19ArchiveIdentityJSON.validated(
                admission: object.admission, expected: object.expected,
                preseal: objectPreseal
            ),
            "product": PrimeR19ArchiveIdentityJSON.validated(
                admission: product.admission, expected: product.expected,
                preseal: productPreseal
            ),
            "role": .string(role),
            "root": PrimeR19ArchiveIdentityJSON.validated(
                admission: root.admission, expected: root.expected,
                preseal: rootPreseal
            ),
            "timing": .string("ADMISSION_AND_PRESEAL_ONLY"),
        ])
        return wrapped(schema: schema, payload: payload)
    }

    static func artifacts(
        nodes: [PrimeR19HeldNode],
        copies: [PrimeR19ArchiveLeaf],
        preseal: [UInt32: PrimeR19ArchiveFacts]
    ) throws -> Data {
        guard copies.count == 7 else { throw PrimeR19ArchiveFailure.rejected }
        var entries = [PrimeR19JSON]()
        for index in 0..<7 {
            let ordinal = PrimeR19ArchiveConstants.copyOriginOrdinals[index]
            let origin = nodes[Int(ordinal)]
            guard let originPreseal = preseal[ordinal] else {
                throw PrimeR19ArchiveFailure.rejected
            }
            entries.append(.object([
                "archive": PrimeR19ArchiveIdentityJSON.file(
                    copies[index].facts,
                    path: PrimeR19ArchiveConstants.stagingPath + "/" +
                        copies[index].relativePath
                ),
                "archive_path": .string(copies[index].relativePath),
                "content_equal": .boolean(
                    originPreseal.sha256 == copies[index].facts.sha256
                ),
                "origin": PrimeR19ArchiveIdentityJSON.validated(
                    admission: origin.admission, expected: origin.expected,
                    preseal: originPreseal
                ),
                "origin_path": .string(origin.expected.path),
                "vnode_distinct":
                    .boolean(originPreseal.vnode != copies[index].facts.vnode),
            ]))
        }
        let payload = PrimeR19JSON.object([
            "entries": .array(entries),
            "entry_count": .integer(7),
            "timing": .string(
                "AFTER_SEVEN_COPY_READBACK_MODE_SEAL_AND_ORIGIN_PRESEAL_REVALIDATION"
            ),
        ])
        return wrapped(
            schema: "prime_driver_v2_r19_local_archive_artifacts_v1",
            payload: payload
        )
    }

    static func macho() -> Data {
        let payload = PrimeR19JSON.object([
            "architecture": .string("arm64"),
            "bytes_decimal": .string("357672"),
            "entryoff_decimal": .string("61780"),
            "filetype": .string("MH_EXECUTE"),
            "header_flags": .array(
                ["NOUNDEFS", "DYLDLINK", "TWOLEVEL", "PIE"].map { .string($0) }
            ),
            "lc_code_signature": .object([
                "offset_decimal": .string("354736"),
                "size_decimal": .string("2936"),
            ]),
            "linked_image_count_excluding_product_header": .integer(12),
            "load_command_count": .integer(30),
            "load_commands_size_decimal": .string("3968"),
            "minimum_macos": .string("14.0"),
            "sdk": .string("26.5"),
            "source_frame_sha256": .string(
                "f9dcb2dcec7bb953753806307786d23669f62a4c82707eda2d60f9c30b803be4"
            ),
            "uuid": .string("76733178-02E8-3584-8FF9-F5A2744EF226"),
        ])
        return wrapped(
            schema: "prime_driver_v2_r19_local_archive_macho_v1",
            payload: payload
        )
    }

    static func linkedImages() throws -> Data {
        guard PrimeR19ArchiveConstants.linkedImages.count == 12 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        let payload = PrimeR19JSON.object([
            "linked_image_count": .integer(12),
            "linked_images": .array(
                PrimeR19ArchiveConstants.linkedImages.map { .string($0) }
            ),
            "normalization_rule": .string(
                "REPLACE_EXACT_COMPLETE_A_OR_B_BUILD_ROOT_WITH_LITERAL_<ROOT>_ONLY"
            ),
            "normalized_sha256": .string(
                "1a3aea0dde3c32838997a8781b98a825af97eea8573f95a4c9d83ffe63deb379"
            ),
            "source_controller_raw_stdout_sha256": .string(
                "fa18436818bba799918b3f7f00bd76290e597ef9e133069670736d02c0db4ec6"
            ),
        ])
        return wrapped(
            schema: "prime_driver_v2_r19_local_archive_linked_images_v1",
            payload: payload
        )
    }

    static func undefinedSymbols() throws -> Data {
        guard PrimeR19ArchiveConstants.undefinedSymbols.count == 274 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        let payload = PrimeR19JSON.object([
            "normalization_rule": .string(
                "REPLACE_EXACT_COMPLETE_A_OR_B_BUILD_ROOT_WITH_LITERAL_<ROOT>_ONLY"
            ),
            "normalized_sha256": .string(
                "dc1a58722c50e33290ca96229092e0169123605a54f200a3e82bc5dad9a54386"
            ),
            "source_controller_raw_stdout_sha256": .string(
                "fa18436818bba799918b3f7f00bd76290e597ef9e133069670736d02c0db4ec6"
            ),
            "symbol_line_count": .integer(274),
            "undefined_symbols": .array(
                PrimeR19ArchiveConstants.undefinedSymbols.map { .string($0) }
            ),
        ])
        return wrapped(
            schema: "prime_driver_v2_r19_local_archive_undefined_symbols_v1",
            payload: payload
        )
    }

    static func codesign() -> Data {
        let payload = PrimeR19JSON.object([
            "code_directory": .object([
                "executable_segment_limit_decimal": .string("140208"),
                "flags_hex": .string("0x20002"),
                "full_sha256": .string(
                    "4f594b113c6e4fa9c7fd188fc9fc82d84018c1a666bceb506e069ac1746438ff"
                ),
                "signing": .string("AD_HOC_LINKER_SIGNED"),
                "size_bytes_decimal": .string("2915"),
                "version_hex": .string("0x20400"),
            ]),
            "lc_code_signature": .object([
                "offset_decimal": .string("354736"),
                "size_decimal": .string("2936"),
            ]),
            "normalized_codesign_display_stderr_sha256": .string(
                "2ea613f62957508ab10198412a4dbd6c1ca4a5de51f38cd137a73f7fe572c068"
            ),
            "products": .array([.string("A"), .string("B")]),
            "signing": .string("AD_HOC_LINKER_SIGNED"),
            "source_frame_sha256": .string(
                "f9dcb2dcec7bb953753806307786d23669f62a4c82707eda2d60f9c30b803be4"
            ),
            "strict_codesign": .string("PASS_BOTH"),
        ])
        return wrapped(
            schema: "prime_driver_v2_r19_local_archive_codesign_v1",
            payload: payload
        )
    }

    static func xattrs(
        nodes: [PrimeR19HeldNode],
        copies: [PrimeR19ArchiveLeaf]
    ) throws -> Data {
        guard copies.count == 7 else { throw PrimeR19ArchiveFailure.rejected }
        var origins = [PrimeR19JSON]()
        var archives = [PrimeR19JSON]()
        for index in 0..<7 {
            let originOrdinal = PrimeR19ArchiveConstants.copyOriginOrdinals[index]
            guard let originXattrs = nodes[Int(originOrdinal)].admissionXattrs,
                  let archiveXattrs = copies[index].xattrs
            else { throw PrimeR19ArchiveFailure.rejected }
            origins.append(.object([
                "entity_id":
                    .string(PrimeR19ArchiveConstants.originEntityIDs[index]),
                "xattrs": PrimeR19ArchiveIdentityJSON.xattrArray(originXattrs),
            ]))
            archives.append(.object([
                "entity_id": .string(copies[index].relativePath),
                "xattrs": PrimeR19ArchiveIdentityJSON.xattrArray(archiveXattrs),
            ]))
        }
        let payload = PrimeR19JSON.object([
            "archive_copies": .array(archives),
            "archive_scope": .string(
                "SEVEN_HELD_COPY_LEAVES_AFTER_CONTENT_READBACK_AND_MODE_SEAL"
            ),
            "origin_files": .array(origins),
            "origin_scope": .string(
                "SEVEN_HELD_REGULAR_FILE_ORIGINS_ADMISSION_AND_PRESEAL_EQUALITY_REQUIRED"
            ),
            "successor_scope": .string(
                "FINAL_ROOT_FOUR_DIRECTORIES_ALL_19_FILES_PLUS_RECONFIRM_DATA09_SETS"
            ),
            "timing": .string(
                "PREPUBLICATION_ONLY_NO_SELF_OR_FUTURE_LEAF_OBSERVATION"
            ),
        ])
        return wrapped(
            schema: "prime_driver_v2_r19_local_archive_xattrs_v1",
            payload: payload
        )
    }

    static func toolchain() -> Data {
        func tool(
            bytes: String, device: String, gid: String, inode: String,
            mode: String, nlink: String, path: String, sha: String,
            uid: String
        ) -> PrimeR19JSON {
            .object([
                "bytes_decimal": .string(bytes),
                "device_decimal": .string(device),
                "gid_decimal": .string(gid),
                "inode_decimal": .string(inode),
                "mode": .string(mode),
                "nlink_decimal": .string(nlink),
                "path": .string(path),
                "realpath": .string(path),
                "sha256": .string(sha),
                "type": .string("REGULAR_FILE"),
                "uid_decimal": .string(uid),
            ])
        }
        let llvmPath =
            "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/llvm-nm"
        let llvm = tool(
            bytes: "16380560", device: "16777231", gid: "0",
            inode: "1118384", mode: "0755", nlink: "1", path: llvmPath,
            sha: "d910f3acb104791e5475254000ede2aa129aa1a42eafcc7f5bdb27afffc642dc",
            uid: "0"
        )
        let otool = tool(
            bytes: "118928", device: "16777231", gid: "0",
            inode: "1152921500312571585", mode: "0755", nlink: "78",
            path: "/usr/bin/otool",
            sha: "179301dcb41ea78accc3fa0048a7e6f6710d891945a751a34addd622020c1818",
            uid: "0"
        )
        var rubyValues: [String: PrimeR19JSON]
        if case .object(let values) = tool(
            bytes: "135200", device: "16777231", gid: "0",
            inode: "1152921500312572705", mode: "0555", nlink: "1",
            path: "/usr/bin/ruby",
            sha: "9d6ff3e289c7d908e3c785e0bedd6692d1d6a3377965c88c04d847104b7c892c",
            uid: "0"
        ) { rubyValues = values } else { rubyValues = [:] }
        rubyValues["description"] = .string(
            "ruby 2.6.10p210 (2022-04-12 revision 67958) [universal.arm64e-darwin25]"
        )
        rubyValues["platform"] = .string("universal.arm64e-darwin25")
        rubyValues["version"] = .string("2.6.10")

        func pathHash(_ path: String, _ sha: String) -> PrimeR19JSON {
            .object(["path": .string(path), "sha256": .string(sha)])
        }
        let toolchain = PrimeR19JSON.object([
            "clang": pathHash(
                "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang",
                "7def90dd8829726686213a747fc5bff1583df933dae5edc55d755479e0bfe00a"
            ),
            "ld": pathHash(
                "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld",
                "5897b275efd93b201b6df5832dd541262b3f20f290859ba78f2200a6a66ef38b"
            ),
            "llvm_nm": pathHash(
                llvmPath,
                "d910f3acb104791e5475254000ede2aa129aa1a42eafcc7f5bdb27afffc642dc"
            ),
            "sdk": .object([
                "named_path": .string(
                    "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk"
                ),
                "named_symlink_target": .string("MacOSX.sdk"),
                "settings_path": .string(
                    "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk/SDKSettings.json"
                ),
                "settings_sha256": .string(
                    "f8d005f09381389167f9e0aeaa169bc9e7dff162ef22ca2fd8e98df7ff1acafe"
                ),
                "version": .string("26.5"),
            ]),
            "swift": .object([
                "language_mode": .string("6"),
                "swift_driver_path": .string(
                    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver"
                ),
                "swift_driver_sha256": .string(
                    "fead52ebe00ec6ec700ecbb4be30f0b6204dd0506cb271dda72ac257261bd64b"
                ),
                "swift_version": .string("6.3.3"),
                "swiftc_named_path": .string(
                    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc"
                ),
                "swiftc_named_symlink_target": .string("swift-frontend"),
                "swiftc_resolved_frontend_sha256": .string(
                    "2ed38571e92c0283091838c1649e27650ad9c99950288e883c7b2dc6c4ce89fb"
                ),
            ]),
            "target": .string("arm64-apple-macosx14.0"),
            "xcode": .string("26.6_17F113"),
        ])
        let payload = PrimeR19JSON.object([
            "host": .string("macOS_26.5.2_25F84_arm64"),
            "metadata_capture_tools": .object([
                "llvm_nm": llvm,
                "otool": otool,
                "ruby": .object(rubyValues),
            ]),
            "owner_build_toolchain": toolchain,
            "source_frame_sha256": .string(
                "f9dcb2dcec7bb953753806307786d23669f62a4c82707eda2d60f9c30b803be4"
            ),
        ])
        return wrapped(
            schema: "prime_driver_v2_r19_local_archive_toolchain_v1",
            payload: payload
        )
    }

    static func manifest(_ leaves: [PrimeR19ArchiveLeaf]) throws -> Data {
        guard leaves.count == 18 else { throw PrimeR19ArchiveFailure.rejected }
        let sorted = leaves.sorted {
            Array($0.relativePath.utf8).lexicographicallyPrecedes(
                Array($1.relativePath.utf8)
            )
        }
        let expected = Array(PrimeR19ArchiveConstants.leafPaths.prefix(18)).sorted {
            Array($0.utf8).lexicographicallyPrecedes(Array($1.utf8))
        }
        guard sorted.map(\.relativePath) == expected else {
            throw PrimeR19ArchiveFailure.rejected
        }
        return PrimeR19JSON.object([
            "entries": .array(sorted.map {
                .object([
                    "bytes_decimal": .string(String($0.facts.bytes!)),
                    "path": .string($0.relativePath),
                    "sha256": .string($0.facts.sha256!),
                ])
            }),
            "entry_count": .integer(18),
            "hash_algorithm": .string("SHA-256"),
            "path_order": .string("UTF8_BYTEWISE_ASCENDING"),
            "schema": .string(
                "prime_driver_v2_r19_local_archive_manifest_index_v1"
            ),
            "status": .string("SEALED_PREPUBLICATION"),
        ]).canonical
    }
}

private enum PrimeR19ArchiveDirectoryAdmission {
    static func requireRoot(
        descriptor: Int32,
        parent: Int32,
        ordinal: UInt32,
        mode: UInt16,
        nlink: UInt64,
        inventory: [String]
    ) throws -> PrimeR19ArchiveVnode {
        let held = try requireDirectory(
            descriptor, mode: mode, nlink: nlink, inventory: inventory
        )
        let named = try PrimeR19ArchiveFD(
            prime_r19_archive_open_root(parent, ordinal)
        )
        let namedFacts = try requireDirectory(
            named.rawValue, mode: mode, nlink: nlink, inventory: inventory
        )
        guard held == namedFacts else { throw PrimeR19ArchiveFailure.rejected }
        return held
    }

    static func requireChild(
        descriptor: Int32,
        root: Int32,
        ordinal: UInt32,
        mode: UInt16,
        inventory: [String]
    ) throws {
        let held = try requireDirectory(
            descriptor, mode: mode, nlink: 2, inventory: inventory
        )
        let named = try PrimeR19ArchiveFD(
            prime_r19_archive_open_directory(root, ordinal)
        )
        let namedFacts = try requireDirectory(
            named.rawValue, mode: mode, nlink: 2, inventory: inventory
        )
        guard held == namedFacts else { throw PrimeR19ArchiveFailure.rejected }
    }

    private static func requireDirectory(
        _ descriptor: Int32,
        mode: UInt16,
        nlink: UInt64,
        inventory: [String]
    ) throws -> PrimeR19ArchiveVnode {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              UInt64(UInt32(bitPattern: metadata.st_dev)) == 16_777_231,
              metadata.st_uid == geteuid(), metadata.st_gid == 20,
              UInt16(metadata.st_mode & mode_t(0o7777)) == mode,
              UInt64(metadata.st_nlink) == nlink,
              metadata.st_flags == 0
        else { throw PrimeR19ArchiveFailure.rejected }
        try PrimeR19ArchiveIO.requireInventory(descriptor, expected: inventory)
        return PrimeR19ArchiveAdmission.vnode(metadata)
    }
}

private enum PrimeR19LocalArchivePublisher {
    static func run() throws {
        try PrimeR19ArchiveIO.requireIngress()
        _ = umask(mode_t(0o077))

        let nodes = try PrimeR19ArchiveAdmission.openAll()
        guard nodes.count == 10,
              let aProduct = nodes[3].admissionBytes,
              let bProduct = nodes[6].admissionBytes
        else { throw PrimeR19ArchiveFailure.rejected }
        try PrimeR19ArchiveMachO.requireFrozenIdentity(aProduct)
        try PrimeR19ArchiveMachO.requireFrozenIdentity(bProduct)

        let parent = nodes[0]
        _ = try PrimeR19ArchiveAdmission.requireParent(parent, requiredNlink: 6)
        for ordinal: UInt32 in [0, 1, 0, 1, 0, 1] {
            guard prime_r19_archive_destination_absent(
                parent.descriptor.rawValue, ordinal
            ) == 0 else { throw PrimeR19ArchiveFailure.rejected }
        }
        guard prime_r19_archive_create_staging_root(
            parent.descriptor.rawValue
        ) == 0 else { throw PrimeR19ArchiveFailure.rejected }

        let staging = try PrimeR19ArchiveFD(
            prime_r19_archive_open_root(parent.descriptor.rawValue, 0)
        )
        _ = try PrimeR19ArchiveDirectoryAdmission.requireRoot(
            descriptor: staging.rawValue,
            parent: parent.descriptor.rawValue,
            ordinal: 0,
            mode: 0o700,
            nlink: 2,
            inventory: []
        )
        var parentMetadata = stat()
        guard fstat(parent.descriptor.rawValue, &parentMetadata) == 0 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        let parentNlinkAfterCreation = UInt64(parentMetadata.st_nlink)
        _ = try PrimeR19ArchiveAdmission.requireParent(
            parent, requiredNlink: parentNlinkAfterCreation
        )

        var directories = [PrimeR19ArchiveFD]()
        for ordinal in UInt32(0)..<4 {
            guard prime_r19_archive_create_directory(
                staging.rawValue, ordinal
            ) == 0 else { throw PrimeR19ArchiveFailure.rejected }
            let directory = try PrimeR19ArchiveFD(
                prime_r19_archive_open_directory(staging.rawValue, ordinal)
            )
            try PrimeR19ArchiveDirectoryAdmission.requireChild(
                descriptor: directory.rawValue,
                root: staging.rawValue,
                ordinal: ordinal,
                mode: 0o700,
                inventory: []
            )
            directories.append(directory)
        }
        guard directories.count == 4 else {
            throw PrimeR19ArchiveFailure.rejected
        }

        var leaves = [PrimeR19ArchiveLeaf]()
        for index in 0..<7 {
            let originOrdinal = PrimeR19ArchiveConstants.copyOriginOrdinals[index]
            guard let bytes = nodes[Int(originOrdinal)].admissionBytes else {
                throw PrimeR19ArchiveFailure.rejected
            }
            let leaf = try PrimeR19ArchiveLeafWriter.create(
                root: staging.rawValue,
                ordinal: UInt32(index),
                relativePath: PrimeR19ArchiveConstants.copyPaths[index],
                bytes: bytes,
                observeXattrs: true
            )
            guard leaf.facts.sha256 == nodes[Int(originOrdinal)].admission.sha256,
                  leaf.facts.vnode != nodes[Int(originOrdinal)].admission.vnode
            else { throw PrimeR19ArchiveFailure.rejected }
            leaves.append(leaf)
        }

        var preseal = [UInt32: PrimeR19ArchiveFacts]()
        for index in 1..<10 {
            let node = nodes[index]
            let facts = try PrimeR19ArchiveAdmission.revalidate(node)
            if let expectedXattrs = node.admissionXattrs {
                guard try PrimeR19ArchiveIO.xattrs(node.descriptor.rawValue) ==
                        expectedXattrs
                else { throw PrimeR19ArchiveFailure.rejected }
            }
            preseal[node.expected.ordinal] = facts
        }
        guard preseal.count == 9 else { throw PrimeR19ArchiveFailure.rejected }

        let dataBytes: [Data] = try [
            PrimeR19ArchiveDataLeaves.control(),
            PrimeR19ArchiveDataLeaves.crs12Frame(),
            PrimeR19ArchiveDataLeaves.origins(
                label: "A",
                role: "SOLE_PRESERVED_PROSPECTIVE_CANDIDATE_NOT_EXECUTION_AUTHORIZED",
                root: nodes[1], object: nodes[2], product: nodes[3],
                preseal: preseal,
                schema: "prime_driver_v2_r19_local_archive_origins_a_v1"
            ),
            PrimeR19ArchiveDataLeaves.origins(
                label: "B",
                role: "STATIC_IDENTITY_WITNESS_ONLY_NEVER_EXECUTE_OR_SUBSTITUTE",
                root: nodes[4], object: nodes[5], product: nodes[6],
                preseal: preseal,
                schema: "prime_driver_v2_r19_local_archive_origins_b_v1"
            ),
            PrimeR19ArchiveDataLeaves.artifacts(
                nodes: nodes, copies: leaves, preseal: preseal
            ),
            PrimeR19ArchiveDataLeaves.macho(),
            PrimeR19ArchiveDataLeaves.linkedImages(),
            PrimeR19ArchiveDataLeaves.undefinedSymbols(),
            PrimeR19ArchiveDataLeaves.codesign(),
            PrimeR19ArchiveDataLeaves.xattrs(nodes: nodes, copies: leaves),
            PrimeR19ArchiveDataLeaves.toolchain(),
        ]
        guard dataBytes.count == 11 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        for index in 0..<11 {
            let ordinal = UInt32(index + 7)
            leaves.append(try PrimeR19ArchiveLeafWriter.create(
                root: staging.rawValue,
                ordinal: ordinal,
                relativePath: PrimeR19ArchiveConstants.leafPaths[Int(ordinal)],
                bytes: dataBytes[index],
                observeXattrs: false
            ))
        }
        let manifestBytes = try PrimeR19ArchiveDataLeaves.manifest(leaves)
        leaves.append(try PrimeR19ArchiveLeafWriter.create(
            root: staging.rawValue,
            ordinal: 18,
            relativePath: PrimeR19ArchiveConstants.leafPaths[18],
            bytes: manifestBytes,
            observeXattrs: false
        ))
        guard leaves.count == 19 else { throw PrimeR19ArchiveFailure.rejected }

        try requireCompleteTree(
            root: staging.rawValue,
            rootOrdinal: 0,
            parent: parent.descriptor.rawValue,
            rootMode: 0o700,
            directoryMode: 0o700,
            directories: directories,
            leaves: leaves,
            nodes: nodes
        )
        for ordinal in UInt32(0)..<4 {
            let directory = directories[Int(ordinal)]
            guard fchmod(directory.rawValue, mode_t(0o500)) == 0 else {
                throw PrimeR19ArchiveFailure.rejected
            }
            try PrimeR19ArchiveIO.fullSync(directory.rawValue)
            try PrimeR19ArchiveDirectoryAdmission.requireChild(
                descriptor: directory.rawValue,
                root: staging.rawValue,
                ordinal: ordinal,
                mode: 0o500,
                inventory: PrimeR19ArchiveConstants.directoryInventories[Int(ordinal)]
            )
        }
        guard fchmod(staging.rawValue, mode_t(0o500)) == 0 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        try PrimeR19ArchiveIO.fullSync(staging.rawValue)
        _ = try PrimeR19ArchiveDirectoryAdmission.requireRoot(
            descriptor: staging.rawValue,
            parent: parent.descriptor.rawValue,
            ordinal: 0,
            mode: 0o500,
            nlink: 6,
            inventory: ["a", "b", "data", "source"]
        )

        guard prime_r19_archive_publish(parent.descriptor.rawValue) == 0 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        try PrimeR19ArchiveIO.fullSync(parent.descriptor.rawValue)
        _ = try PrimeR19ArchiveAdmission.requireParent(
            parent, requiredNlink: parentNlinkAfterCreation
        )
        let final = try PrimeR19ArchiveFD(
            prime_r19_archive_open_root(parent.descriptor.rawValue, 1)
        )
        let heldVnode = try PrimeR19ArchiveDirectoryAdmission.requireRoot(
            descriptor: staging.rawValue,
            parent: parent.descriptor.rawValue,
            ordinal: 1,
            mode: 0o500,
            nlink: 6,
            inventory: ["a", "b", "data", "source"]
        )
        var finalMetadata = stat()
        guard fstat(final.rawValue, &finalMetadata) == 0,
              heldVnode == PrimeR19ArchiveAdmission.vnode(finalMetadata)
        else { throw PrimeR19ArchiveFailure.rejected }

        try requireCompleteTree(
            root: final.rawValue,
            rootOrdinal: 1,
            parent: parent.descriptor.rawValue,
            rootMode: 0o500,
            directoryMode: 0o500,
            directories: directories,
            leaves: leaves,
            nodes: nodes
        )
        _ = try PrimeR19ArchiveAdmission.requireParent(
            parent, requiredNlink: parentNlinkAfterCreation
        )
        for index in 1..<10 {
            let node = nodes[index]
            _ = try PrimeR19ArchiveAdmission.revalidate(node)
        }
        for originOrdinal in PrimeR19ArchiveConstants.copyOriginOrdinals {
            let node = nodes[Int(originOrdinal)]
            guard let expectedXattrs = node.admissionXattrs,
                  try PrimeR19ArchiveIO.xattrs(node.descriptor.rawValue) ==
                    expectedXattrs
            else { throw PrimeR19ArchiveFailure.rejected }
        }
        for index in 0..<7 {
            guard let expectedXattrs = leaves[index].xattrs else {
                throw PrimeR19ArchiveFailure.rejected
            }
            try PrimeR19ArchiveLeafWriter.revalidate(
                root: final.rawValue,
                leaf: leaves[index],
                xattrs: expectedXattrs
            )
        }
    }

    private static func requireCompleteTree(
        root: Int32,
        rootOrdinal: UInt32,
        parent: Int32,
        rootMode: UInt16,
        directoryMode: UInt16,
        directories: [PrimeR19ArchiveFD],
        leaves: [PrimeR19ArchiveLeaf],
        nodes: [PrimeR19HeldNode]
    ) throws {
        guard leaves.count == 19, directories.count == 4 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        _ = try PrimeR19ArchiveDirectoryAdmission.requireRoot(
            descriptor: root,
            parent: parent,
            ordinal: rootOrdinal,
            mode: rootMode,
            nlink: 6,
            inventory: ["a", "b", "data", "source"]
        )
        for ordinal in UInt32(0)..<4 {
            try PrimeR19ArchiveDirectoryAdmission.requireChild(
                descriptor: directories[Int(ordinal)].rawValue,
                root: root,
                ordinal: ordinal,
                mode: directoryMode,
                inventory:
                    PrimeR19ArchiveConstants.directoryInventories[Int(ordinal)]
            )
        }
        let vnodes = leaves.map(\.facts.vnode)
        guard Set(vnodes).count == 19 else {
            throw PrimeR19ArchiveFailure.rejected
        }
        let originVnodes = Set(
            PrimeR19ArchiveConstants.copyOriginOrdinals.map {
                nodes[Int($0)].admission.vnode
            }
        )
        guard vnodes.allSatisfy({ !originVnodes.contains($0) }) else {
            throw PrimeR19ArchiveFailure.rejected
        }
        for leaf in leaves {
            try PrimeR19ArchiveLeafWriter.revalidate(
                root: root, leaf: leaf, xattrs: nil
            )
        }
    }
}

@main
private struct PrimeDriverV2R19LocalArchivePublisher {
    static func main() {
        do {
            try PrimeR19LocalArchivePublisher.run()
            Darwin._exit(0)
        } catch {
            Darwin._exit(70)
        }
    }
}
