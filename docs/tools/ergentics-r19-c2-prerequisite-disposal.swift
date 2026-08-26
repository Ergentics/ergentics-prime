// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin
import Foundation

@_silgen_name("_NSGetEnviron")
private func disposalEnviron()
    -> UnsafeMutablePointer<UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?>

@_silgen_name("ergentics_r19_disposal_install_containment")
private func cInstallContainment() -> Int32
@_silgen_name("ergentics_r19_disposal_open_private_tmp")
private func cOpenPrivateTmp(_ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_create_root")
private func cCreateRoot(_ parent: Int32, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_open_root")
private func cOpenRoot(_ parent: Int32, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_root_rejoin")
private func cRootRejoin(
    _ parent: Int32, _ root: Int32, _ mode: UInt32,
    _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_root_inventory")
private func cRootInventory(
    _ root: Int32, _ mask: UInt32, _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_create_leaf")
private func cCreateLeaf(
    _ root: Int32, _ ordinal: UInt32, _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_precreate_outcome")
private func cPrecreateOutcome(
    _ root: Int32, _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_outcome_rejoin")
private func cOutcomeRejoin(
    _ root: Int32, _ outcome: Int32, _ size: UInt64, _ mode: UInt32,
    _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_leaf_rejoin")
private func cLeafRejoin(
    _ root: Int32, _ leaf: Int32, _ ordinal: UInt32, _ size: UInt64,
    _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_sealed_leaf_rejoin")
private func cSealedLeafRejoin(
    _ root: Int32, _ leaf: Int32, _ ordinal: UInt32, _ size: UInt64,
    _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_seal_leaf")
private func cSealLeaf(_ leaf: Int32, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_full_fsync")
private func cFullFSync(_ descriptor: Int32, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_seal_root")
private func cSealRoot(_ root: Int32, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_open_image")
private func cOpenImage(_ ordinal: UInt32, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_open_cwd")
private func cOpenCWD(_ ordinal: UInt32, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_open_launch_cwd")
private func cOpenLaunchCWD(_ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_validate_held_image")
private func cValidateImage(
    _ descriptor: Int32, _ ordinal: UInt32, _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_validate_held_cwd")
private func cValidateCWD(
    _ descriptor: Int32, _ ordinal: UInt32, _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_validate_launch_cwd")
private func cValidateLaunchCWD(
    _ descriptor: Int32, _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_image_anchor_address")
private func cImageAnchorAddress() -> UInt64
@_silgen_name("ergentics_r19_disposal_proc_pidinfo")
private func cPIDInfo(
    _ pid: Int32, _ flavor: Int32, _ arg: UInt64, _ buffer: UnsafeMutableRawPointer,
    _ size: Int32, _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_proc_pidpath")
private func cPIDPath(
    _ pid: Int32, _ buffer: UnsafeMutableRawPointer, _ size: UInt32,
    _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_proc_listpids")
private func cListPIDs(
    _ type: UInt32, _ info: UInt32, _ buffer: UnsafeMutableRawPointer,
    _ size: Int32, _ error: UnsafeMutablePointer<Int32>
) -> Int32
@_silgen_name("ergentics_r19_disposal_getsid")
private func cGetSID(_ pid: Int32, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_getpgid")
private func cGetPGID(_ pid: Int32, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_kill_guardian")
private func cKillGuardian(_ result: UnsafeMutablePointer<Int32>, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_kill_stopped_fixture_group")
private func cKillFixture(_ result: UnsafeMutablePointer<Int32>, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_kill_awk")
private func cKillAWK(_ result: UnsafeMutablePointer<Int32>, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_guardian_signal_zero")
private func cProbeGuardian(_ result: UnsafeMutablePointer<Int32>, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_fixture_signal_zero")
private func cProbeFixture(_ result: UnsafeMutablePointer<Int32>, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_awk_signal_zero")
private func cProbeAWK(_ result: UnsafeMutablePointer<Int32>, _ error: UnsafeMutablePointer<Int32>) -> Int32
@_silgen_name("ergentics_r19_disposal_wait_quantum")
private func cWaitQuantum()
@_silgen_name("ergentics_r19_disposal_wait_recovery_quantum")
private func cWaitRecoveryQuantum()
@_silgen_name("ergentics_r19_disposal_contain_forever")
private func cContainForever() -> Never

private enum Failure: Error {
    case rejected(String)

    var coordinate: String {
        switch self { case .rejected(let coordinate): return coordinate }
    }
}

private func failureCoordinate(_ error: Error) -> String {
    guard let failure = error as? Failure else { return "UNCLASSIFIED_NON_FAILURE_ERROR" }
    let coordinate = failure.coordinate
    let admitted = coordinate.utf8.allSatisfy {
        ($0 >= 0x30 && $0 <= 0x39) || ($0 >= 0x41 && $0 <= 0x5a) ||
        ($0 >= 0x61 && $0 <= 0x7a) || $0 == 0x2d || $0 == 0x5f
        || $0 == 0x2e
    }
    return admitted && coordinate.utf8.count <= 160 ? coordinate : "INVALID_FAILURE_COORDINATE"
}

private enum Fixed {
    static let freezeCommit = "d7ecc1dab5d9bd8e2d7ae2354de10292113dd0f8"
    static let freezeTree = "3bc7b2840a1eb11806ed83be0d3c56e421ab4c4f"
    static let freezeFrameHash = "71a5e61d38b9e20e7d2c907376f63dd1b92c9ce9d6fe5b9408c54dfdcf7ce656"
    static let journalRoot = "/private/tmp/ergentics-r19-obs11-c2-prerequisite-disposal-1cb03c1-8930176-8930235-8668003-v2"
    static let buildAPath = "/private/tmp/ergentics-r19-obs11-c2-prerequisite-disposal-build-a-1cb03c1-v2/ErgenticsR19C2PrerequisiteDisposal"
    static let buildBPath = "/private/tmp/ergentics-r19-obs11-c2-prerequisite-disposal-build-b-1cb03c1-v2/ErgenticsR19C2PrerequisiteDisposal"
    static let readinessPath = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/artifacts/r19-obs11-retained-r19-projection-chain-2026-08-26/r19-obs11-c2-prerequisite-disposal-readiness.v2.frame"
    static let guardianCWD = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging"
    static let launchCWD = "/private/var/empty"
    static let leafNames = [
        "00-start.json", "01-guardian-prestate.json",
        "02-guardian-kill-commitment.json", "03-guardian-kill-result.json",
        "04-guardian-conservation.json", "05-stopped-fixture-prestate.json",
        "06-stopped-fixture-kill-commitment.json",
        "07-stopped-fixture-kill-result.json", "08-stopped-fixture-conservation.json",
        "09-awk-prestate.json", "10-awk-kill-commitment.json",
        "11-awk-kill-result.json", "12-awk-conservation.json",
        "13-natural-exit-observers.json", "14-terminal.json", "99-outcome.jsonl",
    ]
    static let receiptSchema = "ergentics-r19-obs11-c2-prerequisite-disposal-journal-v2"
    static let outcomeSchema = "ergentics-r19-obs11-c2-prerequisite-disposal-outcome-v2"
    static let merkleDomain = Data("ERGENTICS-R19-C2-PREREQUISITE-DISPOSAL-PRESTATE-MERKLE-V2".utf8)
    static let fileCap = 131_072
    static let outcomeCap = 524_288
    static let pidCapacity = 131_072
    static let uniqueSize = 56
    static let shortSize = 64
    static let regionSize = 1_272
    static let vnodePathsSize = 2_352
    static let pathSize = 4_096
    static let uniqueFlavor: Int32 = 17
    static let shortFlavor: Int32 = 13
    static let regionFlavor: Int32 = 8
    static let cwdFlavor: Int32 = 9
    static let allPIDs: UInt32 = 1
    static let pgrpOnly: UInt32 = 2
    static let esrch: Int32 = 3
}

private indirect enum J {
    case object([(String, J)]), array([J]), string(String)
    case unsigned(UInt64), signed(Int64), boolean(Bool), null

    func encoded() throws -> Data {
        var bytes = [UInt8](); try append(to: &bytes); return Data(bytes)
    }

    private func append(to bytes: inout [UInt8]) throws {
        switch self {
        case .object(let members):
            var seen = Set<String>()
            guard members.allSatisfy({ seen.insert($0.0).inserted }) else {
                throw Failure.rejected("duplicate-json-key")
            }
            bytes.append(0x7b)
            let sorted = members.sorted {
                Array($0.0.utf8).lexicographicallyPrecedes(Array($1.0.utf8))
            }
            for index in sorted.indices {
                if index != sorted.startIndex { bytes.append(0x2c) }
                Self.appendString(sorted[index].0, to: &bytes); bytes.append(0x3a)
                try sorted[index].1.append(to: &bytes)
            }
            bytes.append(0x7d)
        case .array(let values):
            bytes.append(0x5b)
            for index in values.indices {
                if index != values.startIndex { bytes.append(0x2c) }
                try values[index].append(to: &bytes)
            }
            bytes.append(0x5d)
        case .string(let string): Self.appendString(string, to: &bytes)
        case .unsigned(let value): bytes.append(contentsOf: String(value).utf8)
        case .signed(let value): bytes.append(contentsOf: String(value).utf8)
        case .boolean(let value): bytes.append(contentsOf: value ? [0x74,0x72,0x75,0x65] : [0x66,0x61,0x6c,0x73,0x65])
        case .null: bytes.append(contentsOf: [0x6e,0x75,0x6c,0x6c])
        }
    }

    private static func appendString(_ value: String, to bytes: inout [UInt8]) {
        bytes.append(0x22)
        for scalar in value.unicodeScalars {
            switch scalar.value {
            case 0x22: bytes.append(contentsOf: [0x5c,0x22])
            case 0x5c: bytes.append(contentsOf: [0x5c,0x5c])
            case 0x08: bytes.append(contentsOf: [0x5c,0x62])
            case 0x0c: bytes.append(contentsOf: [0x5c,0x66])
            case 0x0a: bytes.append(contentsOf: [0x5c,0x6e])
            case 0x0d: bytes.append(contentsOf: [0x5c,0x72])
            case 0x09: bytes.append(contentsOf: [0x5c,0x74])
            case 0..<0x20:
                bytes.append(contentsOf: String(format: "\\u%04x", scalar.value).utf8)
            default: bytes.append(contentsOf: String(scalar).utf8)
            }
        }
        bytes.append(0x22)
    }
}

private func object(_ members: (String, J)...) -> J { .object(members) }
private func hex(_ data: Data) -> String {
    let alphabet = Array("0123456789abcdef".utf8)
    var result = [UInt8](); result.reserveCapacity(data.count * 2)
    for byte in data { result += [alphabet[Int(byte >> 4)], alphabet[Int(byte & 15)]] }
    return String(decoding: result, as: UTF8.self)
}
private func sha(_ data: Data) -> Data { Data(SHA256.hash(data: data)) }
private func shaHex(_ data: Data) -> String { hex(sha(data)) }
private func frame(_ data: Data) -> Data {
    var length = UInt64(data.count).bigEndian
    return withUnsafeBytes(of: &length) { Data($0) } + data
}

private struct MerkleCommitment {
    let algorithm: String; let root: String; let leaves: Int
    var json: J { object(
        ("algorithm", .string(algorithm)),
        ("leaf_count", .unsigned(UInt64(leaves))), ("root_sha256", .string(root))
    ) }
}

private func merkle(_ leaves: [(String, J)]) throws -> MerkleCommitment {
    guard !leaves.isEmpty else { throw Failure.rejected("empty-merkle") }
    var labels = Set<String>()
    guard leaves.allSatisfy({ labels.insert($0.0).inserted }) else {
        throw Failure.rejected("duplicate-merkle-label")
    }
    let ordered = leaves.sorted {
        Array($0.0.utf8).lexicographicallyPrecedes(Array($1.0.utf8))
    }
    var level = try ordered.map { label, value -> Data in
        let payload = try value.encoded()
        return sha(Fixed.merkleDomain + Data([0]) + frame(Data(label.utf8)) + frame(payload))
    }
    while level.count > 1 {
        var next = [Data](); var index = 0
        while index < level.count {
            let right = index + 1 < level.count ? level[index + 1] : level[index]
            next.append(sha(Fixed.merkleDomain + Data([1]) + frame(level[index]) + frame(right)))
            index += 2
        }
        level = next
    }
    return MerkleCommitment(
        algorithm: "SHA256_DOMAIN_SEPARATED_LENGTH_FRAMED_BINARY_MERKLE_V1",
        root: hex(level[0]), leaves: leaves.count
    )
}

private struct Unique: Equatable {
    let uuid: String; let uniqueID, parentUniqueID: UInt64
    let idVersion, originalParentVersion: Int32
    var json: J { object(
        ("idversion", .signed(Int64(idVersion))),
        ("orig_ppidversion", .signed(Int64(originalParentVersion))),
        ("puniqueid", .unsigned(parentUniqueID)), ("uniqueid", .unsigned(uniqueID)),
        ("uuid_hex", .string(uuid))
    ) }
}

private struct ProcessRow: Equatable {
    let pid, ppid, pgid, sid: Int32; let status, flags: UInt32
    let unique: Unique; let credentials: [UInt32]
    var json: J { object(
        ("credentials", .array(credentials.map { .unsigned(UInt64($0)) })),
        ("flags", .unsigned(UInt64(flags))), ("idversion", .signed(Int64(unique.idVersion))),
        ("orig_ppidversion", .signed(Int64(unique.originalParentVersion))),
        ("pgid", .signed(Int64(pgid))), ("pid", .signed(Int64(pid))),
        ("ppid", .signed(Int64(ppid))), ("puniqueid", .unsigned(unique.parentUniqueID)),
        ("sid", .signed(Int64(sid))), ("status", .unsigned(UInt64(status))),
        ("uniqueid", .unsigned(unique.uniqueID)), ("uuid_hex", .string(unique.uuid))
    ) }
}

private struct Vnode: Equatable {
    let path: String; let device, inode: UInt64
    var json: J { object(("device", .unsigned(device)), ("inode", .unsigned(inode)), ("path", .string(path))) }
}
private struct Mapping: Equatable {
    let path: String; let device, inode, offset: UInt64
    var json: J { object(
        ("device", .unsigned(device)), ("file_offset", .unsigned(offset)),
        ("inode", .unsigned(inode)), ("path", .string(path))
    ) }
}
private struct HeldIdentity: Equatable {
    let device, inode, bytes: UInt64; let uid, gid, mode, flags: UInt32; let nlink: UInt64
    var json: J { object(
        ("bytes", .unsigned(bytes)), ("device", .unsigned(device)),
        ("gid", .unsigned(UInt64(gid))), ("inode", .unsigned(inode)),
        ("flags", .unsigned(UInt64(flags))),
        ("mode", .string(String(format: "%04o", mode))), ("nlink", .unsigned(nlink)),
        ("uid", .unsigned(UInt64(uid)))
    ) }
}

private struct Target {
    let ordinal: UInt32; let role, form: String; let pid, target, ppid, sid, pgid: Int32
    let uniqueID, parentUniqueID: UInt64; let idVersion, parentVersion: Int32
    let status: UInt32; let imagePath, imageHash, imageUUID: String
    let imageDevice, imageInode, imageBytes, mappedOffset: UInt64
    let imageMode, imageUID, imageGID, imageFlags: UInt32; let cwd: Vnode
    let cwdMode, cwdGID: UInt32; let cwdNlink: UInt64
    let preMembers: [(Int32, UInt64, Int32)]
    let preLeaf, commitmentLeaf, resultLeaf, conservationLeaf: UInt32
}

private let targets = [
    Target(
        ordinal: 0, role: "R19_GUARDIAN", form: "POSITIVE_PID_KILL",
        pid: 21_601, target: 21_601, ppid: 21_600, sid: 21_601, pgid: 21_601,
        uniqueID: 8_930_176, parentUniqueID: 8_930_175,
        idVersion: 17_456_018, parentVersion: 17_456_015, status: 2,
        imagePath: "/usr/bin/ruby",
        imageHash: "9d6ff3e289c7d908e3c785e0bedd6692d1d6a3377965c88c04d847104b7c892c",
        imageUUID: "eb2540b7e13236beb719619d0fbf7203",
        imageDevice: 16_777_231, imageInode: 1_152_921_500_312_572_705,
        imageBytes: 135_200, mappedOffset: 65_536,
        imageMode: 0o555, imageUID: 0, imageGID: 0, imageFlags: 524_320,
        cwd: Vnode(path: Fixed.guardianCWD, device: 16_777_231, inode: 17_077_237),
        cwdMode: 0o755, cwdGID: 20, cwdNlink: 17,
        preMembers: [(21_601, 8_930_176, 17_456_018)],
        preLeaf: 1, commitmentLeaf: 2, resultLeaf: 3, conservationLeaf: 4
    ),
    Target(
        ordinal: 1, role: "R19_STOPPED_FIXTURE",
        form: "NEGATIVE_SINGLETON_PGID_KILL", pid: 21_660, target: -21_660,
        ppid: 1, sid: 21_660, pgid: 21_660,
        uniqueID: 8_930_235, parentUniqueID: 8_930_233,
        idVersion: 17_456_153, parentVersion: 17_456_148, status: 4,
        imagePath: "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging/Tests/PrimeValidationWorkflow/.build/arm64-apple-macosx/release/PrimeValidationWorkflowDriverV2SessionFixture",
        imageHash: "177a18c20bc42486c77b52af4c472be222dec1baabf8973ece7b2d44ea92756e",
        imageUUID: "2ebb880ad28b32ff9b7eeb868af5d9b6",
        imageDevice: 16_777_231, imageInode: 17_382_060,
        imageBytes: 53_072, mappedOffset: 0,
        imageMode: 0o700, imageUID: 501, imageGID: 20, imageFlags: 0,
        cwd: Vnode(
            path: "/private/tmp/prime-validation-admission-tests-369E97E5-AAF3-4267-B810-BA92ADB20BD1/workspace",
            device: 16_777_231, inode: 17_447_047
        ),
        cwdMode: 0o700, cwdGID: 0, cwdNlink: 2,
        preMembers: [(21_660, 8_930_235, 17_456_153)],
        preLeaf: 5, commitmentLeaf: 6, resultLeaf: 7, conservationLeaf: 8
    ),
    Target(
        ordinal: 2, role: "GATE_C_AWK",
        form: "POSITIVE_PID_KILL_ONLY_NEVER_SHARED_NEGATIVE_PGID",
        pid: 56_518, target: 56_518, ppid: 56_508, sid: 56_508, pgid: 56_508,
        uniqueID: 8_668_003, parentUniqueID: 8_667_993,
        idVersion: 16_806_376, parentVersion: 16_806_357, status: 2,
        imagePath: "/usr/bin/awk",
        imageHash: "3693175058d0be720f941a8e9c645756f7d38848f3457abd938d8e27ba35f8ab",
        imageUUID: "b7af4730d19e35939e156bbcaafc626b",
        imageDevice: 16_777_231, imageInode: 1_152_921_500_312_571_675,
        imageBytes: 302_368, mappedOffset: 147_456,
        imageMode: 0o755, imageUID: 0, imageGID: 0, imageFlags: 524_320,
        cwd: Vnode(
            path: "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging",
            device: 16_777_231, inode: 17_154_421
        ),
        cwdMode: 0o755, cwdGID: 20, cwdNlink: 16,
        preMembers: [(56_508, 8_667_993, 16_806_357), (56_518, 8_668_003, 16_806_376)],
        preLeaf: 9, commitmentLeaf: 10, resultLeaf: 11, conservationLeaf: 12
    ),
]

private final class FD {
    private(set) var raw: Int32
    init(_ value: Int32) throws {
        guard value >= 3 else { if value >= 0 { _ = Darwin.close(value) }; throw Failure.rejected("reserved-fd") }
        raw = value
    }
    deinit { if raw >= 0 { _ = Darwin.close(raw) } }
}

private func u32(_ bytes: [UInt8], _ offset: Int) -> UInt32 {
    UInt32(bytes[offset]) | UInt32(bytes[offset + 1]) << 8 |
        UInt32(bytes[offset + 2]) << 16 | UInt32(bytes[offset + 3]) << 24
}
private func u64(_ bytes: [UInt8], _ offset: Int) -> UInt64 {
    UInt64(u32(bytes, offset)) | UInt64(u32(bytes, offset + 4)) << 32
}
private func cString(_ bytes: [UInt8], _ offset: Int, _ count: Int) throws -> String {
    let slice = bytes[offset..<(offset + count)]
    let end = slice.firstIndex(of: 0) ?? slice.endIndex
    let value = String(decoding: slice[..<end], as: UTF8.self)
    guard Array(value.utf8) == Array(slice[..<end]) else { throw Failure.rejected("invalid-utf8") }
    return value
}

private func checkedStat(_ descriptor: Int32) throws -> stat {
    var value = stat()
    guard fstat(descriptor, &value) == 0 else { throw Failure.rejected("fstat-\(errno)") }
    return value
}
private func identity(_ value: stat) -> HeldIdentity {
    HeldIdentity(
        device: UInt64(value.st_dev), inode: UInt64(value.st_ino),
        bytes: UInt64(value.st_size), uid: value.st_uid, gid: value.st_gid,
        mode: UInt32(value.st_mode & 0o7777), flags: value.st_flags,
        nlink: UInt64(value.st_nlink)
    )
}
private func fullSync(_ descriptor: Int32, _ coordinate: String) throws {
    var error: Int32 = 0
    guard cFullFSync(descriptor, &error) == 0 else {
        throw Failure.rejected("full-fsync-\(coordinate)-\(error)")
    }
}
private func readHash(_ descriptor: Int32, expectedBytes: UInt64) throws -> String {
    guard lseek(descriptor, 0, SEEK_SET) == 0 else { throw Failure.rejected("hash-seek") }
    var digest = SHA256(); var total: UInt64 = 0
    var buffer = [UInt8](repeating: 0, count: 65_536)
    while true {
        let count = buffer.withUnsafeMutableBytes {
            Darwin.read(descriptor, $0.baseAddress!, $0.count)
        }
        if count == -1 && errno == EINTR { continue }
        guard count >= 0 else { throw Failure.rejected("hash-read-\(errno)") }
        if count == 0 { break }
        total += UInt64(count); digest.update(data: Data(buffer[0..<count]))
    }
    guard total == expectedBytes, lseek(descriptor, 0, SEEK_SET) == 0 else {
        throw Failure.rejected("hash-size")
    }
    return hex(Data(digest.finalize()))
}

private struct HeldTarget {
    let image, cwd: FD; let imageIdentity, cwdIdentity: HeldIdentity
    let imageHash: String
}
private struct HeldZsh {
    let image: FD; let identity: HeldIdentity; let imageHash: String
}
private func holdZsh() throws -> HeldZsh {
    var error: Int32 = 0; let image = try FD(cOpenImage(3, &error))
    guard cValidateImage(image.raw, 3, &error) == 0 else {
        throw Failure.rejected("zsh-rejoin-\(error)")
    }
    let value = identity(try checkedStat(image.raw))
    let imageHash = try readHash(image.raw, expectedBytes: value.bytes)
    guard value.device == 16_777_231,
          value.inode == 1_152_921_500_312_571_448,
          value.bytes == 1_361_216, value.mode == 0o755,
          value.uid == 0, value.gid == 0, value.nlink == 1,
          value.flags == 524_320,
          imageHash == "1f473d234dd65157f530b4f676686517ec97fe9aa64c76d82f2611674cc44314"
    else { throw Failure.rejected("zsh-frozen-identity") }
    return HeldZsh(image: image, identity: value, imageHash: imageHash)
}
private func hold(_ target: Target) throws -> HeldTarget {
    var error: Int32 = 0
    let image = try FD(cOpenImage(target.ordinal, &error))
    guard cValidateImage(image.raw, target.ordinal, &error) == 0 else {
        throw Failure.rejected("image-rejoin-\(target.role)-\(error)")
    }
    let imageID = identity(try checkedStat(image.raw))
    let imageHash = try readHash(image.raw, expectedBytes: target.imageBytes)
    guard imageID.device == target.imageDevice, imageID.inode == target.imageInode,
          imageID.bytes == target.imageBytes, imageID.nlink == 1,
          imageID.flags == target.imageFlags, imageID.mode == target.imageMode,
          imageID.uid == target.imageUID, imageID.gid == target.imageGID,
          imageHash == target.imageHash
    else { throw Failure.rejected("image-identity-\(target.role)") }
    let cwd = try FD(cOpenCWD(target.ordinal, &error))
    guard cValidateCWD(cwd.raw, target.ordinal, &error) == 0 else {
        throw Failure.rejected("cwd-rejoin-\(target.role)-\(error)")
    }
    let cwdID = identity(try checkedStat(cwd.raw))
    guard cwdID.device == target.cwd.device, cwdID.inode == target.cwd.inode,
          cwdID.uid == 501, cwdID.gid == target.cwdGID,
          cwdID.mode == target.cwdMode, cwdID.nlink == target.cwdNlink,
          cwdID.flags == 0 else {
        throw Failure.rejected("cwd-identity-\(target.role)")
    }
    return HeldTarget(
        image: image, cwd: cwd, imageIdentity: imageID,
        cwdIdentity: cwdID, imageHash: imageHash
    )
}

private func revalidateHeldTarget(_ held: HeldTarget, _ target: Target) throws {
    var error: Int32 = 0
    guard cValidateImage(held.image.raw, target.ordinal, &error) == 0,
          cValidateCWD(held.cwd.raw, target.ordinal, &error) == 0 else {
        throw Failure.rejected("target-held-named-before-\(target.role)-\(error)")
    }
    let imageBefore = identity(try checkedStat(held.image.raw))
    let cwdBefore = identity(try checkedStat(held.cwd.raw))
    guard imageBefore == held.imageIdentity, cwdBefore == held.cwdIdentity,
          try readHash(held.image.raw, expectedBytes: target.imageBytes) == held.imageHash,
          held.imageHash == target.imageHash else {
        throw Failure.rejected("target-held-baseline-before-\(target.role)")
    }
    let imageAfter = identity(try checkedStat(held.image.raw))
    let cwdAfter = identity(try checkedStat(held.cwd.raw))
    guard imageAfter == imageBefore, cwdAfter == cwdBefore,
          cValidateImage(held.image.raw, target.ordinal, &error) == 0,
          cValidateCWD(held.cwd.raw, target.ordinal, &error) == 0 else {
        throw Failure.rejected("target-held-named-after-\(target.role)-\(error)")
    }
}

private func revalidateHeldZsh(_ held: HeldZsh) throws {
    var error: Int32 = 0
    guard cValidateImage(held.image.raw, 3, &error) == 0 else {
        throw Failure.rejected("zsh-continuity-before-\(error)")
    }
    let before = identity(try checkedStat(held.image.raw))
    guard before == held.identity,
          try readHash(held.image.raw, expectedBytes: held.identity.bytes) == held.imageHash else {
        throw Failure.rejected("zsh-content-continuity")
    }
    let after = identity(try checkedStat(held.image.raw))
    guard after == before, cValidateImage(held.image.raw, 3, &error) == 0 else {
        throw Failure.rejected("zsh-continuity-after-\(error)")
    }
}

private enum ReadValue<T> { case present(T), gone }
private func rawPIDInfo(_ pid: Int32, _ flavor: Int32, _ arg: UInt64, _ size: Int) -> (Int32, Int32, [UInt8]) {
    var bytes = [UInt8](repeating: 0, count: size); var error: Int32 = 0
    let result = bytes.withUnsafeMutableBytes {
        cPIDInfo(pid, flavor, arg, $0.baseAddress!, Int32(size), &error)
    }
    return (result, error, bytes)
}
private func readUnique(_ pid: Int32) throws -> ReadValue<Unique> {
    let (result, error, bytes) = rawPIDInfo(pid, Fixed.uniqueFlavor, 0, Fixed.uniqueSize)
    if result == 0 && error == Fixed.esrch { return .gone }
    guard result == Int32(Fixed.uniqueSize), u64(bytes, 40) == 0, u64(bytes, 48) == 0 else {
        throw Failure.rejected("unique-\(pid)-\(result)-\(error)")
    }
    let unique = Unique(
        uuid: hex(Data(bytes[0..<16])), uniqueID: u64(bytes, 16),
        parentUniqueID: u64(bytes, 24), idVersion: Int32(bitPattern: u32(bytes, 32)),
        originalParentVersion: Int32(bitPattern: u32(bytes, 36))
    )
    guard unique.uniqueID != 0 else { throw Failure.rejected("zero-generation") }
    return .present(unique)
}
private struct Short: Equatable {
    let pid, ppid, pgid: Int32; let status, flags: UInt32; let credentials: [UInt32]
}
private func readShort(_ pid: Int32) throws -> ReadValue<Short> {
    let (result, error, bytes) = rawPIDInfo(pid, Fixed.shortFlavor, 0, Fixed.shortSize)
    if result == 0 && error == Fixed.esrch { return .gone }
    guard result == Int32(Fixed.shortSize), u32(bytes, 60) == 0 else {
        throw Failure.rejected("short-\(pid)-\(result)-\(error)")
    }
    let value = Short(
        pid: Int32(bitPattern: u32(bytes, 0)), ppid: Int32(bitPattern: u32(bytes, 4)),
        pgid: Int32(bitPattern: u32(bytes, 8)), status: u32(bytes, 12), flags: u32(bytes, 32),
        credentials: [36, 40, 44, 48, 52, 56].map { u32(bytes, $0) }
    )
    guard value.pid == pid else { throw Failure.rejected("short-pid") }
    return .present(value)
}
private func readDomain(_ pid: Int32, sid: Bool) throws -> ReadValue<Int32> {
    var error: Int32 = 0; let value = sid ? cGetSID(pid, &error) : cGetPGID(pid, &error)
    if value == -1 && error == Fixed.esrch { return .gone }
    guard value >= 0 else { throw Failure.rejected("domain-\(pid)-\(error)") }
    return .present(value)
}

private enum Joined { case present(ProcessRow), gone }
private func join(_ pid: Int32) throws -> Joined {
    for attempt in 0..<4 {
        guard case .present(let u0) = try readUnique(pid) else { return .gone }
        guard case .present(let s0) = try readShort(pid),
              case .present(let sid0) = try readDomain(pid, sid: true),
              case .present(let pgid0) = try readDomain(pid, sid: false),
              case .present(let sid1) = try readDomain(pid, sid: true),
              case .present(let pgid1) = try readDomain(pid, sid: false),
              case .present(let s1) = try readShort(pid),
              case .present(let u1) = try readUnique(pid)
        else { return .gone }
        if u0 == u1, s0 == s1, sid0 == sid1, pgid0 == pgid1,
           s1.pgid == pgid1 {
            return .present(ProcessRow(
                pid: pid, ppid: s1.ppid, pgid: pgid1, sid: sid1,
                status: s1.status, flags: s1.flags, unique: u1,
                credentials: s1.credentials
            ))
        }
        if attempt != 3 { cWaitQuantum() }
    }
    throw Failure.rejected("join-unknown-\(pid)")
}

private func processPath(_ pid: Int32) throws -> String {
    var bytes = [UInt8](repeating: 0, count: Fixed.pathSize); var error: Int32 = 0
    let result = bytes.withUnsafeMutableBytes {
        cPIDPath(pid, $0.baseAddress!, UInt32($0.count), &error)
    }
    guard result > 0, Int(result) < Fixed.pathSize else {
        throw Failure.rejected("pidpath-\(pid)-\(result)-\(error)")
    }
    return try cString(bytes, 0, Int(result))
}

private func mappedImage(_ pid: Int32, path: String, offset expectedOffset: UInt64) throws -> Mapping {
    var address: UInt64 = 0
    for _ in 0..<256 {
        let (result, error, bytes) = rawPIDInfo(pid, Fixed.regionFlavor, address, Fixed.regionSize)
        guard result == Int32(Fixed.regionSize) else {
            throw Failure.rejected("mapped-\(pid)-\(result)-\(error)")
        }
        let protection = u32(bytes, 0), offset = u64(bytes, 16)
        let regionAddress = u64(bytes, 80), regionBytes = u64(bytes, 88)
        guard regionAddress >= address, regionBytes > 0,
              regionAddress <= UInt64.max - regionBytes else {
            throw Failure.rejected("mapped-region-frame")
        }
        let regionPath = try cString(bytes, 248, 1_024)
        if protection & 4 != 0, offset == expectedOffset, regionPath == path {
            return Mapping(
                path: path, device: UInt64(u32(bytes, 96)), inode: u64(bytes, 104),
                offset: offset
            )
        }
        address = regionAddress + regionBytes
    }
    throw Failure.rejected("mapped-cap-\(pid)")
}

private func processCWD(_ pid: Int32) throws -> Vnode {
    let (result, error, bytes) = rawPIDInfo(pid, Fixed.cwdFlavor, 0, Fixed.vnodePathsSize)
    guard result == Int32(Fixed.vnodePathsSize) else {
        throw Failure.rejected("cwd-\(pid)-\(result)-\(error)")
    }
    return Vnode(
        path: try cString(bytes, 152, 1_024), device: UInt64(u32(bytes, 0)),
        inode: u64(bytes, 8)
    )
}

private func listedPIDs(_ type: UInt32, _ info: UInt32, emptyAllowed: Bool) throws -> [Int32] {
    var bytes = [UInt8](repeating: 0, count: Fixed.pidCapacity * 4); var error: Int32 = 0
    let result = bytes.withUnsafeMutableBytes {
        cListPIDs(type, info, $0.baseAddress!, Int32($0.count), &error)
    }
    if result == 0, error == 0, emptyAllowed { return [] }
    guard result > 0, Int(result) < bytes.count, result % 4 == 0 else {
        throw Failure.rejected("listpids-\(type)-\(info)-\(result)-\(error)")
    }
    var pids = [Int32]()
    for offset in stride(from: 0, to: Int(result), by: 4) {
        let pid = Int32(bitPattern: u32(bytes, offset)); if pid != 0 { pids.append(pid) }
    }
    guard Set(pids).count == pids.count else { throw Failure.rejected("duplicate-pid") }
    return pids.sorted()
}

private func groupRows(_ pgid: Int32) throws -> [ProcessRow] {
    var rows = [ProcessRow]()
    for pid in try listedPIDs(Fixed.pgrpOnly, UInt32(pgid), emptyAllowed: true) {
        guard case .present(let row) = try join(pid) else { continue }
        guard row.pgid == pgid else { throw Failure.rejected("group-race-\(pgid)") }
        rows.append(row)
    }
    return rows.sorted { $0.pid < $1.pid }
}

private func sessionRows(_ sid: Int32) throws -> [ProcessRow] {
    var rows = [ProcessRow]()
    for pid in try listedPIDs(Fixed.allPIDs, 0, emptyAllowed: false) {
        guard case .present(let before) = try readDomain(pid, sid: true), before == sid else { continue }
        guard case .present(let row) = try join(pid) else { continue }
        guard case .present(let after) = try readDomain(pid, sid: true) else { continue }
        guard before == after, row.sid == sid else { throw Failure.rejected("session-race-\(sid)") }
        rows.append(row)
    }
    return rows.sorted { $0.pid < $1.pid }
}

private struct Witness: Equatable {
    let policy: String; let process: ProcessRow; let path: String?; let mapping: Mapping?
    let cwd: Vnode?; let heldImage, heldCWD: HeldIdentity?
    var json: J { object(
        ("held_image", heldImage.map { $0.json } ?? .null),
        ("held_cwd", heldCWD.map { $0.json } ?? .null),
        ("mapped_image", mapping.map { $0.json } ?? .null),
        ("cwd", cwd.map { $0.json } ?? .null),
        ("path", path.map { .string($0) } ?? .null), ("policy", .string(policy)),
        ("process", process.json)
    ) }
}

private struct Snapshot: Equatable {
    let target: ProcessRow; let path: String; let mapping: Mapping; let cwd: Vnode
    let heldImage, heldCWD: HeldIdentity; let heldImageHash: String
    let selfAuthority: SelfSnapshot
    let group, session: [ProcessRow]
    let witnesses: [Witness]
    var json: J { object(
        ("cwd", cwd.json), ("group_members", .array(group.map(\.json))),
        ("held_cwd", heldCWD.json), ("held_image", heldImage.json),
        ("held_image_sha256", .string(heldImageHash)),
        ("mapped_image", mapping.json), ("path", .string(path)),
        ("process", target.json), ("session_members", .array(session.map(\.json))),
        ("self_image_authority", selfAuthority.json),
        ("witnesses", .array(witnesses.map(\.json)))
    ) }
    func merkleLeaves(_ round: String) -> [(String, J)] {
        var result: [(String, J)] = [
            ("\(round)/target-process", target.json), ("\(round)/path", .string(path)),
            ("\(round)/mapped-image", mapping.json), ("\(round)/cwd", cwd.json),
            ("\(round)/held-image", heldImage.json),
            ("\(round)/held-image-sha256", .string(heldImageHash)),
            ("\(round)/held-cwd", heldCWD.json),
            ("\(round)/self-image-authority", selfAuthority.json),
        ]
        result += group.enumerated().map { ("\(round)/group/\($0.offset)", $0.element.json) }
        result += session.enumerated().map { ("\(round)/session/\($0.offset)", $0.element.json) }
        result += witnesses.enumerated().map { ("\(round)/witness/\($0.offset)", $0.element.json) }
        return result
    }
}

private enum Initial: Equatable { case absent, present(Snapshot) }
private func exactTarget(_ row: ProcessRow, _ target: Target) -> Bool {
    row.pid == target.pid && row.ppid == target.ppid && row.pgid == target.pgid &&
        row.sid == target.sid && row.status == target.status &&
        row.unique.uniqueID == target.uniqueID && row.unique.idVersion == target.idVersion &&
        row.unique.parentUniqueID == target.parentUniqueID &&
        row.unique.originalParentVersion == target.parentVersion &&
        row.unique.uuid == target.imageUUID && row.credentials == [501,20,501,20,501,20]
}
private func exactMembers(_ rows: [ProcessRow], _ target: Target) -> Bool {
    guard rows.count == target.preMembers.count else { return false }
    for (row, expected) in zip(rows, target.preMembers) {
        guard row.pid == expected.0, row.unique.uniqueID == expected.1,
              row.unique.idVersion == expected.2 else { return false }
    }
    return true
}

private let targetPlanDomain = Data(
    "ERGENTICS-R19-OBS11-C2-PREREQUISITE-DISPOSAL-TARGET-PLAN-MERKLE-V2".utf8
)

private func targetPlanPayload(_ target: Target) throws -> Data {
    let members = target.preMembers.map { "\($0.0):\($0.1):\($0.2)" }.joined(separator: ",")
    let witness: String
    switch target.ordinal {
    case 0: witness = "PARENT_21600_EXACT_ZSH_OBSERVE_ONLY_NEVER_SIGNAL"
    case 1: witness = "NONE"
    case 2: witness = "SHELL_56508_EXACT_ZSH_OBSERVE_ONLY_NEVER_SIGNAL"
    default: throw Failure.rejected("target-plan-ordinal")
    }
    let lines = [
        "ordinal=\(target.ordinal)", "role=\(target.role)", "form=\(target.form)",
        "pid=\(target.pid)", "actuation_target=\(target.target)", "ppid=\(target.ppid)",
        "sid=\(target.sid)", "pgid=\(target.pgid)", "uniqueid=\(target.uniqueID)",
        "puniqueid=\(target.parentUniqueID)", "idversion=\(target.idVersion)",
        "orig_ppidversion=\(target.parentVersion)", "status=\(target.status)",
        "credentials=501,20,501,20,501,20", "image_path=\(target.imagePath)",
        "image_sha256=\(target.imageHash)", "image_uuid_hex=\(target.imageUUID)",
        "image_device=\(target.imageDevice)", "image_inode=\(target.imageInode)",
        "image_bytes=\(target.imageBytes)", "mapped_offset=\(target.mappedOffset)",
        "image_mode=\(String(format: "%04o", target.imageMode))",
        "image_uid=\(target.imageUID)", "image_gid=\(target.imageGID)",
        "image_flags=\(target.imageFlags)", "cwd_path=\(target.cwd.path)",
        "cwd_device=\(target.cwd.device)", "cwd_inode=\(target.cwd.inode)",
        "cwd_mode=\(String(format: "%04o", target.cwdMode))", "cwd_uid=501",
        "cwd_gid=\(target.cwdGID)", "cwd_nlink=\(target.cwdNlink)", "cwd_flags=0",
        "pre_members=\(members)", "pre_leaf=\(target.preLeaf)",
        "commitment_leaf=\(target.commitmentLeaf)", "result_leaf=\(target.resultLeaf)",
        "conservation_leaf=\(target.conservationLeaf)", "witness_policy=\(witness)",
    ]
    let value = lines.joined(separator: "\n") + "\n"
    guard value.utf8.allSatisfy({ $0 == 0x0a || ($0 >= 0x20 && $0 <= 0x7e) }) else {
        throw Failure.rejected("target-plan-ascii")
    }
    return Data(value.utf8)
}

private func u64Frame(_ value: UInt64) -> Data {
    var big = value.bigEndian
    return withUnsafeBytes(of: &big) { Data($0) }
}

private func targetPlanMerkle() throws -> MerkleCommitment {
    guard targets.count == 3 else { throw Failure.rejected("target-plan-count") }
    let leaves = try targets.enumerated().map { index, target -> Data in
        let payload = try targetPlanPayload(target)
        return sha(
            targetPlanDomain + Data([0]) + u64Frame(UInt64(index)) +
            u64Frame(UInt64(payload.count)) + payload
        )
    }
    let left = sha(targetPlanDomain + Data([1]) + leaves[0] + leaves[1])
    let right = sha(targetPlanDomain + Data([1]) + leaves[2] + leaves[2])
    return MerkleCommitment(
        algorithm: "SHA256_DOMAIN_SEPARATED_U64BE_LENGTH_FRAMED_BINARY_MERKLE_V2",
        root: hex(sha(targetPlanDomain + Data([1]) + left + right)), leaves: 3
    )
}

private func preadFile(
    _ descriptor: Int32, cap: UInt64
) throws -> (data: Data, identity: HeldIdentity) {
    let before = identity(try checkedStat(descriptor))
    guard before.bytes > 0, before.bytes <= cap else {
        throw Failure.rejected("pread-file-cap")
    }
    var data = Data(); data.reserveCapacity(Int(before.bytes))
    var offset: UInt64 = 0
    var buffer = [UInt8](repeating: 0, count: 65_536)
    while offset < before.bytes {
        let requested = min(buffer.count, Int(before.bytes - offset))
        let count = buffer.withUnsafeMutableBytes {
            Darwin.pread(descriptor, $0.baseAddress!, requested, off_t(offset))
        }
        if count == -1 && errno == EINTR { continue }
        guard count > 0 else { throw Failure.rejected("pread-file-short") }
        data.append(contentsOf: buffer[0..<count]); offset += UInt64(count)
    }
    var trailing: UInt8 = 0
    let trailingCount = Darwin.pread(descriptor, &trailing, 1, off_t(offset))
    guard trailingCount == 0 else { throw Failure.rejected("pread-file-trailing") }
    let after = identity(try checkedStat(descriptor))
    guard before == after, UInt64(data.count) == before.bytes else {
        throw Failure.rejected("pread-file-identity-race")
    }
    return (data, before)
}

private func machoUUID(_ bytes: Data) throws -> String {
    let raw = [UInt8](bytes)
    guard raw.count >= 32, u32(raw, 0) == 0xfeedfacf,
          u32(raw, 4) == 0x0100000c, u32(raw, 12) == 2 else {
        throw Failure.rejected("macho-header")
    }
    let commandCount = Int(u32(raw, 16)), commandBytes = Int(u32(raw, 20))
    guard commandCount > 0, commandCount <= 256, commandBytes > 0,
          commandBytes <= 1_048_576, commandBytes <= raw.count - 32 else {
        throw Failure.rejected("macho-command-frame")
    }
    let end = 32 + commandBytes
    var cursor = 32, uuid: String?
    for _ in 0..<commandCount {
        guard cursor <= end - 8 else { throw Failure.rejected("macho-command-header") }
        let command = u32(raw, cursor), size = Int(u32(raw, cursor + 4))
        guard size >= 8, size % 8 == 0, cursor <= end - size else {
            throw Failure.rejected("macho-command-size")
        }
        if command == 0x1b {
            guard size == 24, uuid == nil else { throw Failure.rejected("macho-uuid-count") }
            uuid = hex(Data(raw[(cursor + 8)..<(cursor + 24)]))
        }
        cursor += size
    }
    guard cursor == end, let uuid else { throw Failure.rejected("macho-uuid-missing") }
    return uuid
}

private struct ReadinessFrame: Equatable {
    let imageBytes, cObjectBytes: UInt64
    let imageHash, imageUUID, cObjectHash: String
    let swiftHash, cHash, headerHash, targetPlanRoot, fullFrameHash: String

    var json: J { object(
        ("c_object_bytes", .unsigned(cObjectBytes)),
        ("c_object_sha256", .string(cObjectHash)),
        ("full_frame_sha256", .string(fullFrameHash)),
        ("image_bytes", .unsigned(imageBytes)), ("image_sha256", .string(imageHash)),
        ("image_uuid_hex", .string(imageUUID)),
        ("source_fixed_c_sha256", .string(cHash)),
        ("source_fixed_h_sha256", .string(headerHash)),
        ("source_swift_sha256", .string(swiftHash)),
        ("target_plan_merkle_root_sha256", .string(targetPlanRoot))
    ) }
}

private func lowerHex(_ value: Substring, count: Int) -> String? {
    guard value.utf8.count == count,
          value.utf8.allSatisfy({ ($0 >= 0x30 && $0 <= 0x39) || ($0 >= 0x61 && $0 <= 0x66) })
    else { return nil }
    return String(value)
}

private func canonicalPositiveDecimal(_ value: Substring) -> UInt64? {
    guard !value.isEmpty, value.first != "0",
          value.utf8.allSatisfy({ $0 >= 0x30 && $0 <= 0x39 }) else { return nil }
    return UInt64(value)
}

private func parseReadiness(_ data: Data) throws -> ReadinessFrame {
    guard data.count > 0, data.count <= 4_096, data.last == 0x0a,
          data.filter({ $0 == 0x0a }).count == 24,
          data.allSatisfy({ $0 == 0x0a || ($0 >= 0x20 && $0 <= 0x7e) }) else {
        throw Failure.rejected("readiness-ascii-frame")
    }
    let text = String(decoding: data, as: UTF8.self)
    guard Data(text.utf8) == data else { throw Failure.rejected("readiness-utf8") }
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
    guard lines.count == 25, lines.last?.isEmpty == true else {
        throw Failure.rejected("readiness-line-count")
    }
    let keys = [
        "schema", "control_freeze_commit", "control_freeze_tree", "control_freeze_path",
        "control_freeze_frame_bytes_decimal", "control_freeze_frame_sha256",
        "build_a_image_path", "build_b_image_path", "build_images_raw_equal",
        "image_bytes_decimal", "image_sha256", "image_macho_uuid_hex",
        "build_a_c_object_path", "build_b_c_object_path", "c_objects_raw_equal",
        "c_object_bytes_decimal", "c_object_sha256", "source_swift_sha256",
        "source_fixed_c_sha256", "source_fixed_h_sha256", "target_plan_merkle_algorithm",
        "target_plan_leaf_count_decimal", "target_plan_merkle_root_sha256", "payload_sha256",
    ]
    var values = [Substring](); values.reserveCapacity(24)
    for index in 0..<24 {
        let parts = lines[index].split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2, parts[0] == Substring(keys[index]),
              !parts[1].isEmpty, !parts[1].contains("=") else {
            throw Failure.rejected("readiness-key-order")
        }
        values.append(parts[1])
    }
    let controlPath = "artifacts/r19-obs11-retained-r19-projection-chain-2026-08-26/r19-obs11-c2-prerequisite-disposal-control-freeze.v2.json"
    let cObjectA = "/private/tmp/ergentics-r19-obs11-c2-prerequisite-disposal-build-a-1cb03c1-v2/ergentics-r19-c2-prerequisite-disposal-fixed.o"
    let cObjectB = "/private/tmp/ergentics-r19-obs11-c2-prerequisite-disposal-build-b-1cb03c1-v2/ergentics-r19-c2-prerequisite-disposal-fixed.o"
    guard values[0] == "ergentics-r19-obs11-c2-prerequisite-disposal-readiness-v2",
          values[1] == Substring(Fixed.freezeCommit), values[2] == Substring(Fixed.freezeTree),
          values[3] == Substring(controlPath), values[4] == "12111",
          values[5] == Substring(Fixed.freezeFrameHash),
          values[6] == Substring(Fixed.buildAPath), values[7] == Substring(Fixed.buildBPath),
          values[8] == "1", values[12] == Substring(cObjectA),
          values[13] == Substring(cObjectB), values[14] == "1",
          values[20] == "SHA256_DOMAIN_SEPARATED_U64BE_LENGTH_FRAMED_BINARY_MERKLE_V2",
          values[21] == "3" else { throw Failure.rejected("readiness-fixed-value") }
    guard let imageBytes = canonicalPositiveDecimal(values[9]),
          let imageHash = lowerHex(values[10], count: 64),
          let imageUUID = lowerHex(values[11], count: 32),
          let cObjectBytes = canonicalPositiveDecimal(values[15]),
          let cObjectHash = lowerHex(values[16], count: 64),
          let swiftHash = lowerHex(values[17], count: 64),
          let cHash = lowerHex(values[18], count: 64),
          let headerHash = lowerHex(values[19], count: 64),
          let targetRoot = lowerHex(values[22], count: 64),
          let payloadHash = lowerHex(values[23], count: 64) else {
        throw Failure.rejected("readiness-dynamic-value")
    }
    let payload = Data((lines[0..<23].joined(separator: "\n") + "\n").utf8)
    guard shaHex(payload) == payloadHash,
          try targetPlanMerkle().root == targetRoot else {
        throw Failure.rejected("readiness-payload-authority")
    }
    return ReadinessFrame(
        imageBytes: imageBytes, cObjectBytes: cObjectBytes,
        imageHash: imageHash, imageUUID: imageUUID, cObjectHash: cObjectHash,
        swiftHash: swiftHash, cHash: cHash, headerHash: headerHash,
        targetPlanRoot: targetRoot, fullFrameHash: shaHex(data)
    )
}

private struct AnchorMapping: Equatable {
    let address, size, offset, device, inode: UInt64
    let protection: UInt32; let path: String

    var json: J { object(
        ("address", .unsigned(address)), ("device", .unsigned(device)),
        ("file_offset", .unsigned(offset)), ("inode", .unsigned(inode)),
        ("path", .string(path)), ("protection", .unsigned(UInt64(protection))),
        ("size", .unsigned(size))
    ) }
}

private func anchorMapping(_ pid: Int32, address: UInt64) throws -> AnchorMapping {
    let (result, error, bytes) = rawPIDInfo(
        pid, Fixed.regionFlavor, address, Fixed.regionSize
    )
    guard result == Int32(Fixed.regionSize) else {
        throw Failure.rejected("self-anchor-region-\(result)-\(error)")
    }
    let protection = u32(bytes, 0), offset = u64(bytes, 16)
    let regionAddress = u64(bytes, 80), regionBytes = u64(bytes, 88)
    guard regionBytes > 0, regionAddress <= address,
          regionAddress <= UInt64.max - regionBytes,
          address < regionAddress + regionBytes, protection & 4 != 0 else {
        throw Failure.rejected("self-anchor-region-frame")
    }
    return AnchorMapping(
        address: regionAddress, size: regionBytes, offset: offset,
        device: UInt64(u32(bytes, 96)), inode: u64(bytes, 104),
        protection: protection, path: try cString(bytes, 248, 1_024)
    )
}

private struct SelfSnapshot: Equatable {
    let buildA, buildB, readiness: HeldIdentity
    let readinessFrame: ReadinessFrame
    let anchor: AnchorMapping
    let process: Unique

    var json: J { object(
        ("anchor_mapping", anchor.json), ("build_a", buildA.json),
        ("build_b", buildB.json), ("process_generation", process.json),
        ("readiness", readiness.json), ("readiness_frame", readinessFrame.json)
    ) }
}

private final class SelfAuthority {
    let buildA, buildB, readiness: FD
    private var baseline: SelfSnapshot?

    static func admit() throws -> SelfAuthority {
        var error: Int32 = 0
        let a = try FD(cOpenImage(4, &error))
        let b = try FD(cOpenImage(5, &error))
        let readiness = try FD(cOpenImage(6, &error))
        let authority = SelfAuthority(buildA: a, buildB: b, readiness: readiness)
        let snapshot = try authority.capture()
        authority.baseline = snapshot
        return authority
    }

    private init(buildA: FD, buildB: FD, readiness: FD) {
        self.buildA = buildA; self.buildB = buildB; self.readiness = readiness
    }

    private func capture() throws -> SelfSnapshot {
        var error: Int32 = 0
        guard cValidateImage(buildA.raw, 4, &error) == 0,
              cValidateImage(buildB.raw, 5, &error) == 0,
              cValidateImage(readiness.raw, 6, &error) == 0 else {
            throw Failure.rejected("self-held-named-before-\(error)")
        }
        let firstA = try preadFile(buildA.raw, cap: 16_777_216)
        let firstB = try preadFile(buildB.raw, cap: 16_777_216)
        let firstReadiness = try preadFile(readiness.raw, cap: 4_096)
        let frame = try parseReadiness(firstReadiness.data)
        guard firstA.data == firstB.data,
              UInt64(firstA.data.count) == frame.imageBytes,
              shaHex(firstA.data) == frame.imageHash,
              shaHex(firstB.data) == frame.imageHash,
              firstA.identity.device != firstB.identity.device ||
                firstA.identity.inode != firstB.identity.inode,
              firstA.identity.uid == 501, firstA.identity.gid == 20,
              firstA.identity.mode == 0o500, firstA.identity.nlink == 1,
              firstA.identity.flags == 0,
              firstB.identity.uid == 501, firstB.identity.gid == 20,
              firstB.identity.mode == 0o400, firstB.identity.nlink == 1,
              firstB.identity.flags == 0,
              firstReadiness.identity.uid == 501, firstReadiness.identity.gid == 20,
              firstReadiness.identity.mode == 0o644,
              firstReadiness.identity.nlink == 1, firstReadiness.identity.flags == 0,
              try machoUUID(firstA.data) == frame.imageUUID,
              try machoUUID(firstB.data) == frame.imageUUID else {
            throw Failure.rejected("self-content-authority")
        }
        let pid = getpid()
        guard processPath(pid) == Fixed.buildAPath,
              case .present(let before) = try readUnique(pid) else {
            throw Failure.rejected("self-process-path-generation")
        }
        let anchor = try anchorMapping(pid, address: cImageAnchorAddress())
        guard anchor.path == Fixed.buildAPath,
              anchor.device == firstA.identity.device,
              anchor.inode == firstA.identity.inode,
              case .present(let after) = try readUnique(pid), after == before,
              after.uuid == frame.imageUUID else {
            throw Failure.rejected("self-mapped-vnode-generation")
        }
        guard cValidateImage(buildA.raw, 4, &error) == 0,
              cValidateImage(buildB.raw, 5, &error) == 0,
              cValidateImage(readiness.raw, 6, &error) == 0 else {
            throw Failure.rejected("self-held-named-after-\(error)")
        }
        let secondA = try preadFile(buildA.raw, cap: 16_777_216)
        let secondB = try preadFile(buildB.raw, cap: 16_777_216)
        let secondReadiness = try preadFile(readiness.raw, cap: 4_096)
        guard secondA.identity == firstA.identity, secondA.data == firstA.data,
              secondB.identity == firstB.identity, secondB.data == firstB.data,
              secondReadiness.identity == firstReadiness.identity,
              secondReadiness.data == firstReadiness.data else {
            throw Failure.rejected("self-content-after-race")
        }
        return SelfSnapshot(
            buildA: firstA.identity, buildB: firstB.identity,
            readiness: firstReadiness.identity, readinessFrame: frame,
            anchor: anchor, process: after
        )
    }

    func revalidate() throws -> SelfSnapshot {
        let value = try capture()
        guard let baseline, value == baseline else {
            throw Failure.rejected("self-authority-baseline")
        }
        return value
    }
}

private func captureWitnesses(
    _ target: Target, group: [ProcessRow], held: HeldTarget, zsh: HeldZsh
) throws -> [Witness] {
    try revalidateHeldZsh(zsh)
    if target.ordinal == 0 {
        guard case .present(let parent) = try join(21_600),
              parent.unique.uniqueID == 8_930_175,
              parent.unique.idVersion == 17_456_015,
              parent.unique.uuid == "bf5c55bb57b33bf688fd76a935389e55",
              parent.credentials == [501,20,501,20,501,20] else {
            throw Failure.rejected("guardian-parent-witness")
        }
        let path = try processPath(21_600)
        let mapping = try mappedImage(21_600, path: "/bin/zsh", offset: 671_744)
        let cwd = try processCWD(21_600)
        guard path == "/bin/zsh", mapping.device == zsh.identity.device,
              mapping.inode == zsh.identity.inode, cwd == target.cwd,
              case .present(let parentAfter) = try join(21_600), parentAfter == parent else {
            throw Failure.rejected("guardian-parent-binding")
        }
        return [Witness(
            policy: "OBSERVE_NATURAL_EXIT_ONLY_NEVER_SIGNAL", process: parent,
            path: path, mapping: mapping, cwd: cwd,
            heldImage: zsh.identity, heldCWD: held.cwdIdentity
        )]
    }
    if target.ordinal == 2 {
        guard let shell = group.first(where: { $0.pid == 56_508 }),
              shell.unique.uniqueID == 8_667_993,
              shell.unique.idVersion == 16_806_357, shell.ppid == 1,
              shell.sid == 56_508, shell.pgid == 56_508,
              shell.unique.uuid == "bf5c55bb57b33bf688fd76a935389e55"
        else { throw Failure.rejected("awk-shell-witness") }
        let path = try processPath(56_508)
        guard path == "/bin/zsh" else { throw Failure.rejected("shell-path") }
        let mapping = try mappedImage(56_508, path: path, offset: 671_744)
        let cwd = try processCWD(56_508)
        guard mapping.device == zsh.identity.device, mapping.inode == zsh.identity.inode,
              cwd == target.cwd,
              case .present(let shellAfter) = try join(56_508), shellAfter == shell else {
            throw Failure.rejected("shell-mapped-held")
        }
        return [Witness(
            policy: "OBSERVE_NATURAL_EXIT_ONLY_NEVER_SIGNAL", process: shell,
            path: path, mapping: mapping, cwd: cwd,
            heldImage: zsh.identity, heldCWD: held.cwdIdentity
        )]
    }
    return []
}

private func capture(
    _ target: Target, held: HeldTarget, zsh: HeldZsh,
    selfAuthority: SelfAuthority
) throws -> Initial {
    let selfBefore = try selfAuthority.revalidate()
    guard case .present(let before) = try join(target.pid) else { return .absent }
    guard exactTarget(before, target) else { throw Failure.rejected("target-rebound-\(target.role)") }
    let path = try processPath(target.pid)
    guard path == target.imagePath else { throw Failure.rejected("target-path-\(target.role)") }
    let mapping = try mappedImage(target.pid, path: path, offset: target.mappedOffset)
    guard mapping.device == held.imageIdentity.device, mapping.inode == held.imageIdentity.inode else {
        throw Failure.rejected("target-mapped-held-\(target.role)")
    }
    let cwd = try processCWD(target.pid)
    guard cwd == target.cwd else { throw Failure.rejected("target-cwd-\(target.role)") }
    try revalidateHeldTarget(held, target)
    let group = try groupRows(target.pgid), session = try sessionRows(target.sid)
    guard exactMembers(group, target), exactMembers(session, target) else {
        throw Failure.rejected("target-domain-\(target.role)")
    }
    let witnesses = try captureWitnesses(target, group: group, held: held, zsh: zsh)
    try revalidateHeldTarget(held, target)
    let selfAfter = try selfAuthority.revalidate()
    guard selfAfter == selfBefore else {
        throw Failure.rejected("target-self-authority-race-\(target.role)")
    }
    guard case .present(let after) = try join(target.pid), after == before else {
        throw Failure.rejected("target-post-join-\(target.role)")
    }
    return .present(Snapshot(
        target: after, path: path, mapping: mapping, cwd: cwd,
        heldImage: held.imageIdentity, heldCWD: held.cwdIdentity,
        heldImageHash: held.imageHash,
        selfAuthority: selfAfter,
        group: group, session: session, witnesses: witnesses
    ))
}

private struct DoublePrestate {
    let first, second: Snapshot; let commitment: MerkleCommitment
    var json: J { object(
        ("first", first.json), ("merkle", commitment.json), ("second", second.json)
    ) }
}

private enum DoubleAdmission { case absent, present(DoublePrestate) }
private func doubleAdmission(
    _ target: Target, held: HeldTarget, zsh: HeldZsh,
    selfAuthority: SelfAuthority
) throws -> DoubleAdmission {
    let first = try capture(
        target, held: held, zsh: zsh, selfAuthority: selfAuthority
    )
    let second = try capture(
        target, held: held, zsh: zsh, selfAuthority: selfAuthority
    )
    guard first == second else { throw Failure.rejected("double-snapshot-race-\(target.role)") }
    switch first {
    case .absent: return .absent
    case .present(let a):
        guard case .present(let b) = second else { throw Failure.rejected("unreachable") }
        let commitment = try merkle(a.merkleLeaves("round-0") + b.merkleLeaves("round-1"))
        return .present(DoublePrestate(first: a, second: b, commitment: commitment))
    }
}

private enum OrdinaryPhase {
    case idle, creating(UInt32), materialized(UInt32), modeSealed(UInt32), terminal

    var json: J {
        switch self {
        case .idle: return object(("kind", .string("IDLE_EXACT_COMPLETE_PREFIX")))
        case .creating(let ordinal): return object(
            ("kind", .string("CREATING_NAMESPACE_RESULT_UNCERTAIN")),
            ("ordinal", .unsigned(UInt64(ordinal)))
        )
        case .materialized(let ordinal): return object(
            ("kind", .string("MATERIALIZED_OPAQUE_IN_FLIGHT_TAIL")),
            ("ordinal", .unsigned(UInt64(ordinal)))
        )
        case .modeSealed(let ordinal): return object(
            ("kind", .string("MODE_SEALED_0400_UNADMITTED_IN_FLIGHT_TAIL")),
            ("ordinal", .unsigned(UInt64(ordinal)))
        )
        case .terminal: return object(("kind", .string("TERMINAL_NO_FURTHER_PUBLICATION")))
        }
    }

    var kind: String {
        switch self {
        case .idle: return "IDLE_EXACT_COMPLETE_PREFIX"
        case .creating: return "CREATING_NAMESPACE_RESULT_UNCERTAIN"
        case .materialized: return "MATERIALIZED_OPAQUE_IN_FLIGHT_TAIL"
        case .modeSealed: return "MODE_SEALED_0400_UNADMITTED_IN_FLIGHT_TAIL"
        case .terminal: return "TERMINAL_NO_FURTHER_PUBLICATION"
        }
    }

    var ordinal: UInt32? {
        switch self {
        case .creating(let value), .materialized(let value), .modeSealed(let value): return value
        case .idle, .terminal: return nil
        }
    }
}

private final class Journal {
    private struct SealedFrame {
        let ordinal: UInt32; let descriptor: FD; let bytes: Data
        let frameHash: String; let previousFrameHash: String?
    }
    let parent: FD, root: FD, outcome: FD
    private(set) var ordinaryMask: UInt32 = 0
    private var previousLeaf: String?
    private var previousFrameHash: String?
    private(set) var phase: OrdinaryPhase = .idle
    private var sealedFrames = [SealedFrame]()
    private var outcomeBytes = Data()
    private var outcomePreviousFrameHash: String?
    private var outcomeSequence: UInt64 = 0
    private var outcomeMode: UInt32 = 0o600
    private var outcomeTerminal = false
    private var inFlightFD: FD?

    static func create(preflight: J) throws -> Journal {
        var error: Int32 = 0
        let parent = try FD(cOpenPrivateTmp(&error))
        let parentID = identity(try checkedStat(parent.raw))
        guard parentID.device == 16_777_231, parentID.inode == 774_813,
              parentID.uid == 0, parentID.gid == 0, parentID.mode == 0o1777,
              parentID.flags == 0 else { throw Failure.rejected("private-tmp-identity") }
        guard cCreateRoot(parent.raw, &error) == 0 else {
            throw Failure.rejected("exclusive-root-create-\(error)")
        }
        // The parent sync is the first locally durable evidence that this
        // one-shot root name was consumed. Failures before it remain the
        // explicitly frozen pre-root residual.
        try fullSync(parent.raw, "exclusive-root-claimed")
        let root = try FD(cOpenRoot(parent.raw, &error))
        guard cRootRejoin(parent.raw, root.raw, 0o700, &error) == 0,
              cRootInventory(root.raw, 0, &error) == 0 else {
            throw Failure.rejected("root-admission-\(error)")
        }
        try fullSync(root.raw, "admitted-empty-root")
        try fullSync(parent.raw, "admitted-empty-root-parent")
        let outcome = try FD(cPrecreateOutcome(root.raw, &error))
        guard cOutcomeRejoin(root.raw, outcome.raw, 0, 0o600, &error) == 0,
              cRootInventory(root.raw, 0, &error) == 0 else {
            throw Failure.rejected("outcome-prearm-\(error)")
        }
        let journal = Journal(parent: parent, root: root, outcome: outcome)
        try journal.appendOutcome(
            status: "ARMED_INCOMPLETE_UNLESS_EXACT_TERMINAL",
            payload: object(
                ("entry_preflight", preflight),
                ("ordinary_mask", .unsigned(0)),
                ("root_mode", .string("0700"))
            )
        )
        return journal
    }

    private init(parent: FD, root: FD, outcome: FD) {
        self.parent = parent; self.root = root; self.outcome = outcome
        sealedFrames.reserveCapacity(15); outcomeBytes.reserveCapacity(Fixed.outcomeCap)
    }

    private func readExact(_ descriptor: Int32, count: Int) throws -> [UInt8] {
        guard lseek(descriptor, 0, SEEK_SET) == 0 else {
            throw Failure.rejected("readback-seek")
        }
        var bytes = [UInt8](repeating: 0, count: count), offset = 0
        while offset < bytes.count {
            let remaining = bytes.count - offset
            let readCount = bytes.withUnsafeMutableBytes {
                Darwin.read(descriptor, $0.baseAddress!.advanced(by: offset), remaining)
            }
            if readCount == -1 && errno == EINTR { continue }
            guard readCount > 0 else { throw Failure.rejected("readback-prefix") }
            offset += readCount
        }
        var trailing: UInt8 = 0
        guard Darwin.read(descriptor, &trailing, 1) == 0 else {
            throw Failure.rejected("readback-trailing")
        }
        return bytes
    }

    private func revalidateSealedPrefix(expectedMode: UInt32) throws {
        var expectedPrevious: String? = nil; var error: Int32 = 0
        for frame in sealedFrames {
            guard frame.previousFrameHash == expectedPrevious,
                  shaHex(frame.bytes) == frame.frameHash,
                  (expectedMode == 0o000 ?
                    cLeafRejoin(
                        root.raw, frame.descriptor.raw, frame.ordinal,
                        UInt64(frame.bytes.count), &error
                    ) :
                    cSealedLeafRejoin(
                        root.raw, frame.descriptor.raw, frame.ordinal,
                        UInt64(frame.bytes.count), &error
                    )) == 0 else {
                throw Failure.rejected("sealed-prefix-rejoin-\(frame.ordinal)-\(error)")
            }
            guard try readExact(frame.descriptor.raw, count: frame.bytes.count) == Array(frame.bytes) else {
                throw Failure.rejected("sealed-prefix-bytes")
            }
            expectedPrevious = frame.frameHash
        }
        guard expectedPrevious == previousFrameHash else {
            throw Failure.rejected("sealed-prefix-chain")
        }
    }

    private func outcomeRecord(status: String, payload: J) throws -> Data {
        guard case .object(let payloadMembers) = payload else {
            throw Failure.rejected("outcome-payload-object")
        }
        let base = J.object(payloadMembers + [
            ("authority_vector", .string("00000000")),
            ("control_freeze_commit", .string(Fixed.freezeCommit)),
            ("control_freeze_frame_sha256", .string(Fixed.freezeFrameHash)),
            ("control_freeze_tree", .string(Fixed.freezeTree)),
            ("gate_e", .string("ABSTAIN")),
            ("journal_root", .string(Fixed.journalRoot)),
            ("outcome_sequence", .unsigned(outcomeSequence)),
            ("previous_outcome_frame_sha256", outcomePreviousFrameHash.map { .string($0) } ?? .null),
            ("schema", .string(Fixed.outcomeSchema)),
            ("status", .string(status)),
        ])
        let payloadHash = shaHex(try base.encoded())
        guard case .object(let baseMembers) = base else {
            throw Failure.rejected("outcome-base-object")
        }
        var frame = try J.object(baseMembers + [
            ("payload_sha256", .string(payloadHash)),
        ]).encoded()
        frame.append(0x0a)
        return frame
    }

    private func appendOutcome(status: String, payload: J) throws {
        guard !outcomeTerminal else { throw Failure.rejected("outcome-terminal") }
        let frame = try outcomeRecord(status: status, payload: payload)
        guard frame.count <= Fixed.outcomeCap,
              outcomeBytes.count <= Fixed.outcomeCap - frame.count else {
            throw Failure.rejected("outcome-cap")
        }
        var error: Int32 = 0
        guard cOutcomeRejoin(
                root.raw, outcome.raw, UInt64(outcomeBytes.count), outcomeMode, &error
              ) == 0,
              try readExact(outcome.raw, count: outcomeBytes.count) == Array(outcomeBytes),
              lseek(outcome.raw, 0, SEEK_END) == off_t(outcomeBytes.count) else {
            throw Failure.rejected("outcome-prefix-rejoin-\(error)")
        }
        var offset = 0
        while offset < frame.count {
            let written = frame.withUnsafeBytes {
                Darwin.write(outcome.raw, $0.baseAddress!.advanced(by: offset), frame.count - offset)
            }
            if written == -1 && errno == EINTR { continue }
            guard written > 0 else { throw Failure.rejected("outcome-write-\(errno)") }
            offset += written
        }
        let next = outcomeBytes + frame
        try fullSync(outcome.raw, "outcome-frame")
        guard cOutcomeRejoin(root.raw, outcome.raw, UInt64(next.count), outcomeMode, &error) == 0,
              try readExact(outcome.raw, count: next.count) == Array(next) else {
            throw Failure.rejected("outcome-readback-\(error)")
        }
        try fullSync(root.raw, "outcome-root")
        try fullSync(parent.raw, "outcome-parent")
        outcomeBytes = next
        outcomePreviousFrameHash = shaHex(frame)
        outcomeSequence += 1
    }

    func recordFailure(
        coordinate: String, killCommitments: UInt64, targetArms: UInt64,
        killCalls: UInt64, armedTargetOrdinal: UInt32?,
        pendingTarget: Target?, recovery: J?
    ) throws {
        let inFlightIdentity: J
        if let descriptor = inFlightFD,
           let value = try? checkedStat(descriptor.raw) {
            inFlightIdentity = identity(value).json
        } else {
            inFlightIdentity = .null
        }
        try appendOutcome(status: "FAILURE_TERMINAL", payload: object(
            ("fixed_coordinate", .string(coordinate)),
            ("ordinary_phase", .string(phase.kind)),
            ("in_flight_ordinal", phase.ordinal.map { .unsigned(UInt64($0)) } ?? .null),
            ("in_flight_held_identity", inFlightIdentity),
            ("kill_calls", .unsigned(killCalls)),
            ("kill_commitments", .unsigned(killCommitments)),
            ("target_arm_count", .unsigned(targetArms)),
            ("armed_target_ordinal", armedTargetOrdinal.map { .unsigned(UInt64($0)) } ?? .null),
            ("last_complete_frame_sha256", previousFrameHash.map { .string($0) } ?? .null),
            ("last_complete_mask", .unsigned(UInt64(ordinaryMask))),
            ("pending_target", pendingTarget.map(targetJSON) ?? .null),
            ("recovery_conservation", recovery ?? .null)
        ))
        outcomeTerminal = true
        phase = .terminal
    }

    func publish(_ ordinal: UInt32, payload: J) throws {
        guard case .idle = phase, ordinal < 15,
              ordinal == UInt32(sealedFrames.count), ordinaryMask & (1 << ordinal) == 0,
              case .object(let payloadMembers) = payload else {
            throw Failure.rejected("journal-publication-precondition")
        }
        try revalidateSealedPrefix(expectedMode: 0o400)
        let leaf = Fixed.leafNames[Int(ordinal)]
        let base = J.object(payloadMembers + [
            ("authority_vector", .string("00000000")),
            ("control_freeze_commit", .string(Fixed.freezeCommit)),
            ("control_freeze_frame_sha256", .string(Fixed.freezeFrameHash)),
            ("control_freeze_tree", .string(Fixed.freezeTree)),
            ("gate_e", .string("ABSTAIN")), ("journal_leaf", .string(leaf)),
            ("journal_root", .string(Fixed.journalRoot)),
            ("previous_leaf", previousLeaf.map { .string($0) } ?? .null),
            ("previous_frame_sha256", previousFrameHash.map { .string($0) } ?? .null),
            ("schema", .string(Fixed.receiptSchema)),
        ])
        let payloadHash = shaHex(try base.encoded())
        let record: J
        guard case .object(let baseMembers) = base else { throw Failure.rejected("journal-base") }
        record = .object(baseMembers + [
            ("payload_sha256", .string(payloadHash)),
        ])
        var bytes = try record.encoded(); bytes.append(0x0a)
        guard bytes.count <= Fixed.fileCap else { throw Failure.rejected("journal-cap") }
        var error: Int32 = 0
        guard cRootRejoin(parent.raw, root.raw, 0o700, &error) == 0,
              cRootInventory(root.raw, ordinaryMask, &error) == 0,
              cOutcomeRejoin(
                root.raw, outcome.raw, UInt64(outcomeBytes.count), outcomeMode, &error
              ) == 0 else {
            throw Failure.rejected("journal-prefix-before-\(error)")
        }
        phase = .creating(ordinal)
        let leafRaw = cCreateLeaf(root.raw, ordinal, &error)
        guard leafRaw >= 3 else {
            if cRootInventory(root.raw, ordinaryMask, &error) == 0,
               cOutcomeRejoin(
                root.raw, outcome.raw, UInt64(outcomeBytes.count), outcomeMode, &error
               ) == 0 {
                phase = .idle
            }
            throw Failure.rejected("journal-exclusive-create-\(leaf)-\(error)")
        }
        let leafFD = try FD(leafRaw)
        inFlightFD = leafFD
        phase = .materialized(ordinal)
        guard cLeafRejoin(root.raw, leafFD.raw, ordinal, 0, &error) == 0 else {
            throw Failure.rejected("journal-create-\(leaf)-\(error)")
        }
        var offset = 0
        while offset < bytes.count {
            let written = bytes.withUnsafeBytes {
                Darwin.write(leafFD.raw, $0.baseAddress!.advanced(by: offset), bytes.count - offset)
            }
            if written == -1 && errno == EINTR { continue }
            guard written > 0 else { throw Failure.rejected("journal-write-\(leaf)-\(errno)") }
            offset += written
        }
        try fullSync(leafFD.raw, leaf)
        guard lseek(leafFD.raw, 0, SEEK_SET) == 0 else { throw Failure.rejected("journal-seek") }
        var readback = [UInt8](repeating: 0, count: bytes.count), readOffset = 0
        while readOffset < readback.count {
            let remaining = readback.count - readOffset
            let count = readback.withUnsafeMutableBytes {
                Darwin.read(leafFD.raw, $0.baseAddress!.advanced(by: readOffset), remaining)
            }
            if count == -1 && errno == EINTR { continue }
            guard count > 0 else { throw Failure.rejected("journal-readback-\(errno)") }
            readOffset += count
        }
        guard readback == Array(bytes),
              cLeafRejoin(root.raw, leafFD.raw, ordinal, UInt64(bytes.count), &error) == 0 else {
            throw Failure.rejected("journal-leaf-rejoin-\(leaf)-\(error)")
        }
        let nextMask = ordinaryMask | (1 << ordinal)
        guard cSealLeaf(leafFD.raw, &error) == 0 else {
            throw Failure.rejected("journal-leaf-mode-seal-\(leaf)-\(error)")
        }
        phase = .modeSealed(ordinal)
        try fullSync(leafFD.raw, "journal-leaf-mode-\(leaf)")
        try fullSync(root.raw, "root-after-materialize-\(leaf)")
        try fullSync(parent.raw, "parent-after-materialize-\(leaf)")
        guard cRootRejoin(parent.raw, root.raw, 0o700, &error) == 0,
              cRootInventory(root.raw, nextMask, &error) == 0,
              cSealedLeafRejoin(
                root.raw, leafFD.raw, ordinal, UInt64(bytes.count), &error
              ) == 0,
              cOutcomeRejoin(
                root.raw, outcome.raw, UInt64(outcomeBytes.count), outcomeMode, &error
              ) == 0 else {
            throw Failure.rejected("journal-prefix-after-\(leaf)-\(error)")
        }
        let frameHash = shaHex(bytes)
        let sealedFrame = SealedFrame(
            ordinal: ordinal, descriptor: leafFD, bytes: bytes,
            frameHash: frameHash, previousFrameHash: previousFrameHash
        )
        sealedFrames.append(sealedFrame)
        ordinaryMask = nextMask; previousLeaf = leaf; previousFrameHash = frameHash
        inFlightFD = nil
        phase = .idle
    }

    func sealSuccessfulRoot() throws {
        guard case .idle = phase, ordinaryMask == 0x7fff else {
            throw Failure.rejected("pass-mask")
        }
        var error: Int32 = 0
        try revalidateSealedPrefix(expectedMode: 0o400)
        guard cRootInventory(root.raw, 0x7fff, &error) == 0,
              cOutcomeRejoin(
                root.raw, outcome.raw, UInt64(outcomeBytes.count), outcomeMode, &error
              ) == 0,
              cRootRejoin(parent.raw, root.raw, 0o700, &error) == 0 else {
            throw Failure.rejected("terminal-prefix-rejoin-\(error)")
        }
        try appendOutcome(status: "SUCCESS_CANDIDATE", payload: object(
            ("last_complete_frame_sha256", previousFrameHash.map { .string($0) } ?? .null),
            ("ordinary_mask", .unsigned(UInt64(ordinaryMask))),
            ("root_mode", .string("0700"))
        ))
        guard cSealLeaf(outcome.raw, &error) == 0 else {
            throw Failure.rejected("terminal-outcome-mode-seal-\(error)")
        }
        outcomeMode = 0o400
        try fullSync(outcome.raw, "terminal-outcome-mode")
        try fullSync(root.raw, "terminal-outcome-mode-root")
        try fullSync(parent.raw, "terminal-outcome-mode-parent")
        guard cOutcomeRejoin(
                root.raw, outcome.raw, UInt64(outcomeBytes.count), outcomeMode, &error
              ) == 0,
              cRootInventory(root.raw, 0x7fff, &error) == 0 else {
            throw Failure.rejected("terminal-all-leaves-sealed-\(error)")
        }
        guard cSealRoot(root.raw, &error) == 0 else {
            throw Failure.rejected("terminal-root-seal-\(error)")
        }
        // A successful fchmod has crossed the failure-root mode boundary.
        // From here, any inability to make the exact PASS terminal durable is
        // containment, never a mislabeled 0500 failure terminal.
        do {
            try fullSync(root.raw, "terminal-root-mode")
            try fullSync(parent.raw, "terminal-root-mode-parent")
            guard cRootRejoin(parent.raw, root.raw, 0o500, &error) == 0,
                  cRootInventory(root.raw, 0x7fff, &error) == 0 else {
                throw Failure.rejected("terminal-root-mode-rejoin-\(error)")
            }
            try appendOutcome(status: "SUCCESS_DURABLE", payload: object(
                ("last_complete_frame_sha256", previousFrameHash.map { .string($0) } ?? .null),
                ("ordinary_mask", .unsigned(UInt64(ordinaryMask))),
                ("root_mode", .string("0500_POST_FFULLFSYNC")),
                ("status_vector", .string("DISPOSAL_COMPLETE_AUTHORITY_00000000_GATE_E_ABSTAIN"))
            ))
            outcomeTerminal = true
            phase = .terminal
        } catch {
            cContainForever()
        }
    }
}

private func targetJSON(_ target: Target) -> J { object(
    ("actuation_form", .string(target.form)), ("actuation_target", .signed(Int64(target.target))),
    ("cwd", target.cwd.json), ("idversion", .signed(Int64(target.idVersion))),
    ("image_path", .string(target.imagePath)), ("mapped_text_file_offset", .unsigned(target.mappedOffset)),
    ("ordinal", .unsigned(UInt64(target.ordinal))), ("pgid", .signed(Int64(target.pgid))),
    ("pid", .signed(Int64(target.pid))), ("role", .string(target.role)),
    ("sid", .signed(Int64(target.sid))), ("uniqueid", .unsigned(target.uniqueID))
) }

private func validAWKResidual(_ rows: [ProcessRow]) -> Bool {
    if rows.isEmpty { return true }
    guard rows.count == 1, let shell = rows.first else { return false }
    return shell.pid == 56_508 && shell.ppid == 1 && shell.pgid == 56_508 &&
        shell.sid == 56_508 && shell.unique.uniqueID == 8_667_993 &&
        shell.unique.idVersion == 16_806_357 &&
        shell.unique.uuid == "bf5c55bb57b33bf688fd76a935389e55"
}

private func fixedProbe(_ target: Target) throws -> J {
    var result: Int32 = 0, error: Int32 = 0
    let wrapper: Int32
    switch target.ordinal {
    case 0: wrapper = cProbeGuardian(&result, &error)
    case 1: wrapper = cProbeFixture(&result, &error)
    case 2: wrapper = cProbeAWK(&result, &error)
    default: throw Failure.rejected("probe-ordinal")
    }
    guard wrapper == 0, result == -1, error == Fixed.esrch else {
        throw Failure.rejected("probe-not-esrch-\(target.role)-\(wrapper)-\(result)-\(error)")
    }
    return object(
        ("errno", .signed(Int64(error))), ("esrch", .boolean(true)),
        ("form", .string(target.ordinal == 1 ? "NEGATIVE_SINGLETON_PGID_SIGNAL_ZERO" : "POSITIVE_PID_SIGNAL_ZERO")),
        ("return", .signed(Int64(result)))
    )
}

private func absenceRound(_ target: Target) throws -> J {
    guard case .gone = try readUnique(target.pid) else {
        throw Failure.rejected("generation-not-esrch-\(target.role)")
    }
    let group = try groupRows(target.pgid), session = try sessionRows(target.sid)
    if target.ordinal < 2 {
        guard group.isEmpty, session.isEmpty else {
            throw Failure.rejected("positive-target-domain-not-naturally-empty-\(target.role)")
        }
    } else {
        guard validAWKResidual(group), validAWKResidual(session) else {
            throw Failure.rejected("awk-residual-domain")
        }
    }
    return object(
        ("generation", .string("PROC_PIDUNIQIDENTIFIERINFO_ESRCH")),
        ("group_members", .array(group.map(\.json))),
        ("group_semantics", .string(target.ordinal == 1 ?
            "NEGATIVE_SINGLETON_GROUP_ACTUATED_AND_EMPTY" :
            "POSITIVE_PID_TARGET_ONLY_GROUP_POSTSTATE_SEPARATELY_OBSERVED")),
        ("probe", try fixedProbe(target)),
        ("session_members", .array(session.map(\.json)))
    )
}

private func conservation(_ target: Target, afterSignal: Bool) throws -> J {
    var rounds = [J](), faults: UInt64 = 0
    while rounds.count < 2 {
        do {
            rounds.append(try absenceRound(target))
            if rounds.count == 1 { cWaitQuantum() }
        } catch {
            if !afterSignal { throw error }
            rounds.removeAll(keepingCapacity: true)
            let increment = faults.addingReportingOverflow(1)
            faults = increment.overflow ? UInt64.max : increment.partialValue
            cWaitRecoveryQuantum()
        }
    }
    return object(
        ("potentially_indefinite_after_entered_signal", .boolean(afterSignal)),
        ("rounds", .array(rounds)), ("transient_fault_count", .unsigned(faults))
    )
}

private final class ControllerState {
    var signalEverEntered = false
    var pendingTarget: Target?
    var armedTargetOrdinal: UInt32?
    var heldTarget: HeldTarget?
    var heldZsh: HeldZsh?
    var ingress: Ingress?
    var selfAuthority: SelfAuthority?
    var commitments: UInt64 = 0
    var targetArms: UInt64 = 0
    var killCalls: UInt64 = 0
    var dispositions = [J]()
}

private func finalCompactActuationGate(
    _ target: Target, held: HeldTarget, zsh: HeldZsh,
    selfAuthority: SelfAuthority
) throws -> J {
    // Put full content work before the final process-domain join. The two
    // residual intervals after this gate remain explicitly frozen.
    try revalidateHeldTarget(held, target)
    try revalidateHeldZsh(zsh)
    let selfSnapshot = try selfAuthority.revalidate()
    let group = try groupRows(target.pgid)
    let session = try sessionRows(target.sid)
    guard exactMembers(group, target), exactMembers(session, target) else {
        throw Failure.rejected("final-compact-domain-\(target.role)")
    }
    let path = try processPath(target.pid)
    let mapping = try mappedImage(target.pid, path: target.imagePath, offset: target.mappedOffset)
    let cwd = try processCWD(target.pid)
    var error: Int32 = 0
    guard path == target.imagePath,
          mapping.device == held.imageIdentity.device,
          mapping.inode == held.imageIdentity.inode,
          cwd == target.cwd,
          cValidateImage(held.image.raw, target.ordinal, &error) == 0,
          cValidateCWD(held.cwd.raw, target.ordinal, &error) == 0,
          case .present(let finalGeneration) = try join(target.pid),
          exactTarget(finalGeneration, target) else {
        throw Failure.rejected("final-compact-generation-\(target.role)-\(error)")
    }
    return object(
        ("final_generation", finalGeneration.json),
        ("group", .array(group.map(\.json))),
        ("held_cwd", held.cwdIdentity.json),
        ("held_image", held.imageIdentity.json),
        ("held_image_sha256", .string(held.imageHash)),
        ("mapping", mapping.json),
        ("path", .string(path)),
        ("same_euid_content_after_hash_residual", .boolean(true)),
        ("negative_pgid_membership_after_enumeration_residual", .boolean(target.target < 0)),
        ("self_image_authority", selfSnapshot.json),
        ("session", .array(session.map(\.json)))
    )
}

private func enterFixedKill(
    _ target: Target, held: HeldTarget, zsh: HeldZsh,
    selfAuthority: SelfAuthority, state: ControllerState
) throws -> J {
    guard state.killCalls < 3, state.targetArms < 3,
          state.armedTargetOrdinal == target.ordinal else {
        throw Failure.rejected("kill-not-exactly-armed")
    }
    let finalGate = try finalCompactActuationGate(
        target, held: held, zsh: zsh, selfAuthority: selfAuthority
    )
    var result: Int32 = 0, error: Int32 = 0
    state.targetArms += 1
    state.armedTargetOrdinal = nil
    state.pendingTarget = target
    state.signalEverEntered = true
    let wrapper: Int32
    switch target.ordinal {
    case 0: wrapper = cKillGuardian(&result, &error)
    case 1: wrapper = cKillFixture(&result, &error)
    case 2: wrapper = cKillAWK(&result, &error)
    default: throw Failure.rejected("kill-ordinal")
    }
    guard wrapper == 0 else { throw Failure.rejected("kill-wrapper-\(target.role)-\(error)") }
    state.killCalls += 1
    return object(
        ("entered", .boolean(true)), ("errno", .signed(Int64(error))),
        ("final_compact_actuation_gate", finalGate),
        ("no_retry", .boolean(true)), ("return", .signed(Int64(result))),
        ("signal", .string("SIGKILL")), ("target", .signed(Int64(target.target)))
    )
}

private func dispose(
    _ target: Target, journal: Journal, zsh: HeldZsh,
    selfAuthority: SelfAuthority, state: ControllerState
) throws {
    let held = try hold(target)
    state.heldTarget = held
    switch try doubleAdmission(
        target, held: held, zsh: zsh, selfAuthority: selfAuthority
    ) {
    case .absent:
        try journal.publish(target.preLeaf, payload: object(
            ("admission", .string("SAME_GENERATION_ABSENT_NO_SIGNAL")),
            ("role", .string(target.role))
        ))
        let selfBeforeCommitment = try selfAuthority.revalidate()
        try journal.publish(target.commitmentLeaf, payload: object(
            ("commitment", .string("DURABLE_NO_SIGNAL_CONSERVATION_ONLY")),
            ("kill_call_authorized", .boolean(false)), ("role", .string(target.role)),
            ("self_image_authority_before_commitment", selfBeforeCommitment.json)
        ))
        state.commitments += 1
        try journal.publish(target.resultLeaf, payload: object(
            ("entered", .boolean(false)), ("reason", .string("PREEXISTING_TARGET_GENERATION_ABSENCE")),
            ("role", .string(target.role))
        ))
        let conserved = try conservation(target, afterSignal: false)
        try journal.publish(target.conservationLeaf, payload: object(
            ("conservation", conserved), ("preexisting_absence", .boolean(true)),
            ("role", .string(target.role))
        ))
        state.dispositions.append(object(
            ("kill_entered", .boolean(false)), ("role", .string(target.role)),
            ("status", .string("CONSERVED_PREEXISTING_ABSENCE"))
        ))
        state.heldTarget = nil
    case .present(let prestate):
        try journal.publish(target.preLeaf, payload: object(
            ("admission", .string("EXACT_DOUBLE_PRESTATE")),
            ("double_prestate", prestate.json), ("role", .string(target.role))
        ))
        let selfBeforeCommitment = try selfAuthority.revalidate()
        try journal.publish(target.commitmentLeaf, payload: object(
            ("commitment", .string("DURABLE_BEFORE_AT_MOST_ONE_FIXED_SIGKILL_CALL")),
            ("kill_call_authorized", .boolean(true)),
            ("prestate_merkle_root_sha256", .string(prestate.commitment.root)),
            ("role", .string(target.role)),
            ("self_image_authority_before_commitment", selfBeforeCommitment.json),
            ("snapshot_to_numeric_target_race", .string("NAMED_RESIDUAL"))
        ))
        state.commitments += 1
        state.armedTargetOrdinal = target.ordinal
        // The durable publication above can take arbitrarily long. Close that
        // avoidable interval with one final full image/cwd/domain/generation
        // join. Only in-memory equality and the fixed literal wrapper separate
        // this capture's terminal generation join from the kernel call.
        guard case .present(let finalAdmission) = try capture(
            target, held: held, zsh: zsh, selfAuthority: selfAuthority
        ), finalAdmission == prestate.second else {
            throw Failure.rejected("post-commit-final-admission-\(target.role)")
        }
        let result = try enterFixedKill(
            target, held: held, zsh: zsh,
            selfAuthority: selfAuthority, state: state
        )
        try journal.publish(target.resultLeaf, payload: object(
            ("final_post_commit_admission", finalAdmission.json),
            ("kill_result", result), ("role", .string(target.role))
        ))
        let conserved = try conservation(target, afterSignal: true)
        try journal.publish(target.conservationLeaf, payload: object(
            ("conservation", conserved), ("preexisting_absence", .boolean(false)),
            ("role", .string(target.role))
        ))
        state.pendingTarget = nil
        state.dispositions.append(object(
            ("kill_entered", .boolean(true)), ("role", .string(target.role)),
            ("status", .string("EXACT_TARGET_GENERATION_CONSERVED"))
        ))
        state.heldTarget = nil
    }
}

private func naturalObserver(_ pid: Int32, _ uniqueID: UInt64, _ idVersion: Int32) -> J {
    do {
        switch try join(pid) {
        case .gone: return object(("kind", .string("NATURAL_EXIT_OBSERVED")), ("pid", .signed(Int64(pid))))
        case .present(let row):
            return object(
                ("kind", .string(row.unique.uniqueID == uniqueID && row.unique.idVersion == idVersion ?
                    "ORIGINAL_GENERATION_STILL_PRESENT" : "NUMERIC_PID_REBOUND_ORIGINAL_EXITED")),
                ("policy", .string("OBSERVE_NATURAL_EXIT_ONLY_NEVER_SIGNAL")),
                ("process", row.json)
            )
        }
    } catch {
        return object(
            ("kind", .string("NONBLOCKING_OBSERVATION_UNKNOWN")),
            ("pid", .signed(Int64(pid))),
            ("policy", .string("NOT_REQUIRED_FOR_TARGET_CONSERVATION"))
        )
    }
}

private struct Ingress {
    let receipt: J
    let launchCWD: FD
}

private struct EntryPreflight {
    let passed: Bool
    let coordinate: String?
    let receipt: J
}

private func descriptorDomain() throws -> [Int32] {
    let selfPID = getpid()
    let (returned, error, bytes) = rawPIDInfo(selfPID, 1, 0, 32)
    guard returned == 24, error == 0 else {
        throw Failure.rejected("closed-fd-list-\(returned)-\(error)")
    }
    let descriptors = stride(from: 0, to: Int(returned), by: 8).map {
        Int32(bitPattern: u32(bytes, $0))
    }.sorted()
    guard descriptors == [0, 1, 2] else {
        throw Failure.rejected("closed-fd-domain")
    }
    return descriptors
}

private func checkedEntryPreflight() throws -> J {
    guard cInstallContainment() == 0 else { throw Failure.rejected("containment-install") }
    let arguments = CommandLine.arguments
    guard CommandLine.argc == 1, arguments == [Fixed.buildAPath],
          let environment = disposalEnviron().pointee, environment.pointee == nil else {
        throw Failure.rejected("closed-zero-argument-empty-environment")
    }
    let selfPID = getpid()
    let initialFDs = try descriptorDomain()
    var input = stat(), output = stat(), diagnostic = stat()
    let inputFlags = fcntl(STDIN_FILENO, F_GETFL)
    let outputFlags = fcntl(STDOUT_FILENO, F_GETFL)
    let diagnosticFlags = fcntl(STDERR_FILENO, F_GETFL)
    guard fstat(STDIN_FILENO, &input) == 0,
          fstat(STDOUT_FILENO, &output) == 0,
          fstat(STDERR_FILENO, &diagnostic) == 0,
          UInt32(bitPattern: input.st_dev) == 3_836_289_247,
          UInt64(input.st_ino) == 336,
          input.st_rdev == dev_t(50_331_650), input.st_uid == 0, input.st_gid == 0,
          input.st_mode & mode_t(S_IFMT) == mode_t(S_IFCHR),
          input.st_mode & mode_t(0o7777) == mode_t(0o666),
          inputFlags == O_RDONLY, isatty(STDIN_FILENO) == 0,
          output.st_mode & mode_t(S_IFMT) == mode_t(S_IFIFO),
          diagnostic.st_mode & mode_t(S_IFMT) == mode_t(S_IFIFO),
          outputFlags == O_WRONLY, diagnosticFlags == O_WRONLY,
          output.st_dev != diagnostic.st_dev || output.st_ino != diagnostic.st_ino,
          isatty(STDOUT_FILENO) == 0, isatty(STDERR_FILENO) == 0,
          fpathconf(STDOUT_FILENO, _PC_PIPE_BUF) == 512,
          fpathconf(STDERR_FILENO, _PC_PIPE_BUF) == 512 else {
        throw Failure.rejected("closed-stdio-admission")
    }
    var cwdBytes = [CChar](repeating: 0, count: Int(PATH_MAX))
    let cwdResult = cwdBytes.withUnsafeMutableBufferPointer {
        getcwd($0.baseAddress, $0.count)
    }
    guard cwdResult != nil,
          String(cString: cwdBytes) == Fixed.launchCWD,
          getuid() == 501, geteuid() == 501, getgid() == 20, getegid() == 20 else {
        throw Failure.rejected("controller-static-ingress")
    }
    let expectedGroups: [UInt32] = [
        12,20,33,61,79,80,81,98,100,204,250,395,398,399,400,701,
    ]
    let groupCount = getgroups(0, nil)
    guard groupCount > 0, Int(groupCount) == expectedGroups.count else {
        throw Failure.rejected("controller-groups-count")
    }
    var groups = [gid_t](repeating: 0, count: Int(groupCount))
    let populatedGroups = groups.withUnsafeMutableBufferPointer {
        getgroups(groupCount, $0.baseAddress)
    }
    guard populatedGroups == groupCount,
          groups.map { UInt32($0) }.sorted() == expectedGroups else {
        throw Failure.rejected("controller-groups")
    }
    var sidError: Int32 = 0, pgidError: Int32 = 0
    let sid = cGetSID(selfPID, &sidError), pgid = cGetPGID(selfPID, &pgidError)
    let reserved: Set<Int32> = [21_600,21_601,21_660,56_508,56_518]
    let domains: Set<Int32> = [21_601,21_660,56_508]
    guard sidError == 0, pgidError == 0,
          !reserved.contains(selfPID), sid > 1, pgid > 1,
          !domains.contains(sid), !domains.contains(pgid) else {
        throw Failure.rejected("controller-target-domain-collision")
    }
    let finalFDs = try descriptorDomain()
    return object(
        ("argc", .unsigned(1)),
        ("argument_count_excluding_argv0", .unsigned(0)),
        ("argv", .array(arguments.map { .string($0) })),
        ("cwd", .string(Fixed.launchCWD)),
        ("descriptor_domain_at_start_of_no_new_fd_preflight", .array(initialFDs.map { .signed(Int64($0)) })),
        ("descriptor_domain_at_end_of_no_new_fd_preflight", .array(finalFDs.map { .signed(Int64($0)) })),
        ("environment_entries", .unsigned(0)), ("pgid", .signed(Int64(pgid))),
        ("pid", .signed(Int64(selfPID))), ("sid", .signed(Int64(sid))),
        ("status", .string("PASS_NO_NEW_FD_PREFLIGHT"))
    )
}

private func captureEntryPreflight() -> EntryPreflight {
    do {
        return EntryPreflight(
            passed: true, coordinate: nil,
            receipt: try checkedEntryPreflight()
        )
    } catch {
        let coordinate = failureCoordinate(error)
        return EntryPreflight(
            passed: false, coordinate: coordinate,
            receipt: object(
                ("failure_coordinate", .string(coordinate)),
                ("status", .string("REJECTED_NO_NEW_FD_PREFLIGHT"))
            )
        )
    }
}

private func completeIngress(_ preflight: EntryPreflight) throws -> Ingress {
    guard preflight.passed else {
        throw Failure.rejected(preflight.coordinate ?? "entry-preflight-rejected")
    }
    var launchError: Int32 = 0
    let launch = try FD(cOpenLaunchCWD(&launchError))
    guard cValidateLaunchCWD(launch.raw, &launchError) == 0 else {
        throw Failure.rejected("launch-cwd-rejoin-\(launchError)")
    }
    let launchID = identity(try checkedStat(launch.raw))
    guard launchID.device == 16_777_231, launchID.inode == 774_080,
          launchID.uid == 0, launchID.gid == 3, launchID.mode == 0o755,
          launchID.nlink == 2, launchID.flags == 0 else {
        throw Failure.rejected("launch-cwd-identity")
    }
    return Ingress(receipt: object(
        ("launch_cwd_identity", launchID.json),
        ("no_new_fd_preflight", preflight.receipt),
        ("status", .string("FULL_INGRESS_PASS"))
    ), launchCWD: launch)
}

private func runController() throws {
    let preflight = captureEntryPreflight()
    let journal = try Journal.create(preflight: preflight.receipt)
    let state = ControllerState()
    do {
        let ingress = try completeIngress(preflight)
        state.ingress = ingress
        let selfAuthority = try SelfAuthority.admit()
        state.selfAuthority = selfAuthority
        let selfAtStart = try selfAuthority.revalidate()
        try journal.publish(0, payload: object(
            ("actuation", .string("CONTROL_ONLY_DISPOSAL_NOT_C2_NOT_GATE_E")),
            ("fixed_targets_in_order", .array(targets.map(targetJSON))),
            ("ingress", ingress.receipt), ("kill_call_ceiling", .unsigned(3)),
            ("no_cleanup", .boolean(true)), ("no_stop_cont_retry", .boolean(true)),
            ("self_image_authority", selfAtStart.json),
            ("target_plan_merkle", try targetPlanMerkle().json),
            ("status", .string("STARTED_FULL_ADMISSION_PASS"))
        ))
        let zsh = try holdZsh() // retained through terminal _exit/containment
        state.heldZsh = zsh
        for target in targets {
            try dispose(
                target, journal: journal, zsh: zsh,
                selfAuthority: selfAuthority, state: state
            )
        }
        try journal.publish(13, payload: object(
            ("guardian_parent_21600", naturalObserver(21_600, 8_930_175, 17_456_015)),
            ("gate_c_shell_56508", naturalObserver(56_508, 8_667_993, 16_806_357)),
            ("required_for_exact_target_conservation", .boolean(false))
        ))
        let selfAtTerminal = try selfAuthority.revalidate()
        try journal.publish(14, payload: object(
            ("commitment_count", .unsigned(state.commitments)),
            ("dispositions", .array(state.dispositions)),
            ("kill_call_count", .unsigned(state.killCalls)),
            ("processes_targeted", .unsigned(3)),
            ("self_image_authority", selfAtTerminal.json),
            ("target_arm_count", .unsigned(state.targetArms)),
            ("status", .string("ALL_THREE_EXACT_TARGET_GENERATIONS_CONSERVED"))
        ))
        try withExtendedLifetime((
            state.ingress, state.selfAuthority, state.heldZsh, state.heldTarget
        )) {
            try journal.sealSuccessfulRoot()
            Darwin._exit(0)
        }
    } catch {
        let coordinate = failureCoordinate(error)
        withExtendedLifetime((
            state.ingress, state.selfAuthority, state.heldTarget, state.heldZsh
        )) {
            if let pending = state.pendingTarget {
                do {
                    let recovered = try conservation(pending, afterSignal: true)
                    try journal.recordFailure(
                        coordinate: coordinate,
                        killCommitments: state.commitments,
                        targetArms: state.targetArms,
                        killCalls: state.killCalls,
                        armedTargetOrdinal: state.armedTargetOrdinal,
                        pendingTarget: pending,
                        recovery: recovered
                    )
                    state.pendingTarget = nil
                    state.heldTarget = nil
                } catch {
                    cContainForever()
                }
            } else {
                if state.signalEverEntered {
                    do {
                        try journal.recordFailure(
                            coordinate: coordinate,
                            killCommitments: state.commitments,
                            targetArms: state.targetArms,
                            killCalls: state.killCalls,
                            armedTargetOrdinal: state.armedTargetOrdinal,
                            pendingTarget: nil,
                            recovery: nil
                        )
                    } catch {
                        cContainForever()
                    }
                } else {
                    try? journal.recordFailure(
                        coordinate: coordinate,
                        killCommitments: state.commitments,
                        targetArms: state.targetArms,
                        killCalls: state.killCalls,
                        armedTargetOrdinal: state.armedTargetOrdinal,
                        pendingTarget: nil,
                        recovery: nil
                    )
                }
            }
            Darwin._exit(70)
        }
    }
}

do {
    try runController()
} catch {
    Darwin._exit(70)
}
