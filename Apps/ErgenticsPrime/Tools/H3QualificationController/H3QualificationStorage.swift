#if EPR_H3_QUALIFICATION
import Foundation
import CryptoKit
import Darwin

typealias H3QValue = H3QualificationJSONValue

func h3qHash(_ bytes: Data) -> String {
    SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
}

struct H3QualificationFileSnapshot: Equatable, Sendable {
    let device: Int32
    let inode: UInt64
    let generation: UInt32
    let owner: UInt32
    let group: UInt32
    let mode: UInt16
    let links: UInt16
    let size: Int64
    let flags: UInt32
    let modifiedSeconds: Int64
    let modifiedNanos: Int64
    let changedSeconds: Int64
    let changedNanos: Int64

    init(_ value: stat) {
        device = value.st_dev; inode = value.st_ino; generation = value.st_gen
        owner = value.st_uid; group = value.st_gid; mode = value.st_mode
        links = value.st_nlink; size = value.st_size; flags = value.st_flags
        modifiedSeconds = Int64(value.st_mtimespec.tv_sec)
        modifiedNanos = Int64(value.st_mtimespec.tv_nsec)
        changedSeconds = Int64(value.st_ctimespec.tv_sec)
        changedNanos = Int64(value.st_ctimespec.tv_nsec)
    }

    var wire: H3QValue {
        .object([
            "device": .string(String(UInt32(bitPattern: device))),
            "generation": .integer(Int64(generation)), "inode": .string(String(inode)),
            // Wire joins use permission/special bits (0600/0700), matching
            // the seal's stat projection. Keep full st_mode in this snapshot
            // for the independent regular/directory and identity admissions.
            "link_count": .string(String(links)), "mode": .integer(Int64(mode & 0o7777)),
            "owner": .integer(Int64(owner))
        ])
    }

    func sameIdentity(as other: Self) -> Bool {
        device == other.device && inode == other.inode && generation == other.generation &&
        owner == other.owner && group == other.group && mode == other.mode && links == other.links
    }
}

final class H3QualificationDescriptor {
    private(set) var value: Int32
    init(_ value: Int32) throws {
        guard value >= 0 else { throw H3QualificationControllerFailure.system("open", errno) }
        self.value = value
    }
    func close() throws {
        guard value >= 0 else { throw H3QualificationControllerFailure.rejected("duplicate close") }
        let original = value
        value = -1 // A failed close is never retried against a possibly reused descriptor number.
        guard Darwin.close(original) == 0 else {
            throw H3QualificationControllerFailure.system("close", errno)
        }
    }
    func take() throws -> Int32 {
        guard value >= 0 else { throw H3QualificationControllerFailure.rejected("closed descriptor") }
        let result = value; value = -1; return result
    }
    func relocateAboveControlSlots() throws {
        guard value >= 0 else { throw H3QualificationControllerFailure.rejected("closed descriptor") }
        if value > 4 { return }
        let replacement = Darwin.fcntl(value, F_DUPFD_CLOEXEC, 5)
        guard replacement > 4 else { throw H3QualificationControllerFailure.system("relocate", errno) }
        do { try close() } catch { Darwin.close(replacement); throw error }
        value = replacement
    }
    deinit { if value >= 0 { Darwin.close(value) } }
}

enum H3QualificationStorage {
    static let readFlags = O_RDONLY | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC
    static let directoryFlags = O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC

    static func snapshot(_ descriptor: Int32) throws -> H3QualificationFileSnapshot {
        var value = stat()
        guard Darwin.fstat(descriptor, &value) == 0 else {
            throw H3QualificationControllerFailure.system("fstat", errno)
        }
        return H3QualificationFileSnapshot(value)
    }

    static func canonical(_ path: String) throws {
        guard path.utf8.count > 1, path.utf8.count <= 4096, path.first == "/",
              !path.utf8.contains(0), !path.contains("\\"), !path.contains("//"),
              !path.split(separator: "/").contains(where: { $0 == "." || $0 == ".." }) else {
            throw H3QualificationControllerFailure.rejected("canonical path grammar")
        }
        var buffer = [CChar](repeating: 0, count: 4097)
        guard realpath(path, &buffer) != nil, let end = buffer.firstIndex(of: 0),
              let resolved = String(bytes: buffer[..<end].map { UInt8(bitPattern: $0) }, encoding: .utf8),
              resolved == path else {
            throw H3QualificationControllerFailure.rejected("canonical path identity")
        }
    }

    /// Each component is acquired relative to the preceding no-follow directory.
    static func openAbsolute(_ path: String, directory: Bool) throws -> H3QualificationDescriptor {
        try canonical(path)
        let components = path.split(separator: "/").map(String.init)
        guard !components.isEmpty, components.count <= 32 else {
            throw H3QualificationControllerFailure.rejected("component bound")
        }
        var held = try H3QualificationDescriptor(Darwin.open("/", directoryFlags))
        for (index, component) in components.enumerated() {
            let flags = index == components.count - 1 && !directory ? readFlags : directoryFlags
            let next = try H3QualificationDescriptor(Darwin.openat(held.value, component, flags))
            try held.close()
            held = next
        }
        return held
    }

    static func admitRegular(_ value: H3QualificationFileSnapshot, maximum: Int,
                             device: Int32?, executable: Bool = false) throws {
        // Preserve the original short-circuit boundary: reject type before the
        // existing geteuid observation, then evaluate only copied scalar values.
        guard H3QualificationRegularReadAdmission.isRegular(mode: value.mode) else {
            throw H3QualificationControllerFailure.rejected("regular leaf policy")
        }
        try H3QualificationRegularReadAdmission.validate(.init(mode: value.mode, owner: value.owner,
            links: value.links, size: value.size, device: value.device), maximum: maximum,
            expectedOwner: geteuid(), device: device, executable: executable)
    }

    struct Capture {
        let bytes: Data
        let sha256: String
        let snapshot: H3QualificationFileSnapshot
    }

    /// One admitted-size allocation, one bounded content pass and one EOF probe.
    static func read(_ descriptor: Int32, maximum: Int, device: Int32?,
                     executable: Bool = false, retain: Bool = true,
                     seek: Bool = false) throws -> Capture {
        let before = try snapshot(descriptor)
        try admitRegular(before, maximum: maximum, device: device, executable: executable)
        if seek && Darwin.lseek(descriptor, 0, SEEK_SET) != 0 {
            throw H3QualificationControllerFailure.system("seek", errno)
        }
        var policy = try H3QualificationReadPolicy(expected: Int(before.size), executable: executable, retain: retain)
        var data = Data()
        if retain { data.reserveCapacity(policy.expected) }
        var digest = SHA256()
        var buffer = [UInt8](repeating: 0, count: 65536)
        while !policy.eof {
            let request = try policy.nextRequest()
            let amount = Darwin.read(descriptor, &buffer, request)
            let error = amount < 0 ? errno : 0
            switch try policy.observe(amount: amount, error: error) {
            case .interrupted: continue
            case .eof: break
            case .bytes(let count, let retained):
                buffer.withUnsafeBytes { raw in digest.update(bufferPointer: UnsafeRawBufferPointer(rebasing: raw[..<count])) }
                // Only the policy-admitted prefix is retained when hashing a
                // product executable; the full executable is never allocated.
                if retained > 0 { data.append(contentsOf: buffer[..<retained]) }
            }
        }
        guard try snapshot(descriptor) == before else {
            throw H3QualificationControllerFailure.rejected("held leaf changed")
        }
        return Capture(bytes: data,
                       sha256: digest.finalize().map { String(format: "%02x", $0) }.joined(),
                       snapshot: before)
    }

    static func writeAll(_ bytes: Data, descriptor: Int32, maximum: Int) throws {
        guard bytes.count <= maximum else { throw H3QualificationControllerFailure.durability }
        var offset = 0, interruptions = 0, calls = 0
        while offset < bytes.count {
            guard calls < maximum + 64, interruptions < 64 else { throw H3QualificationControllerFailure.durability }
            calls += 1
            let amount = bytes.withUnsafeBytes { raw in
                Darwin.write(descriptor, raw.baseAddress!.advanced(by: offset), bytes.count - offset)
            }
            let error = amount < 0 ? errno : 0
            if amount < 0 && error == EINTR {
                guard interruptions < 64 else { throw H3QualificationControllerFailure.durability }
                interruptions += 1; continue
            }
            guard amount > 0, amount <= bytes.count - offset else {
                throw H3QualificationControllerFailure.durability
            }
            offset += amount
        }
    }

    static func sync(_ descriptor: Int32) throws {
        // Attempt each synchronization exactly once; both results must succeed.
        let first = Darwin.fsync(descriptor)
        let second = Darwin.fcntl(descriptor, F_FULLFSYNC)
        guard first == 0, second == 0 else { throw H3QualificationControllerFailure.durability }
    }
}

final class H3QualificationDirectory {
    let path: String
    let descriptor: H3QualificationDescriptor
    let admitted: H3QualificationFileSnapshot

    init(path: String, parent: H3QualificationDirectory? = nil, basename: String? = nil) throws {
        self.path = path
        try H3QualificationStorage.canonical(path)
        if let parent, let basename {
            descriptor = try H3QualificationDescriptor(Darwin.openat(parent.descriptor.value, basename,
                                                                   H3QualificationStorage.directoryFlags))
        } else {
            descriptor = try H3QualificationStorage.openAbsolute(path, directory: true)
        }
        admitted = try H3QualificationStorage.snapshot(descriptor.value)
        guard admitted.mode & UInt16(S_IFMT) == UInt16(S_IFDIR), admitted.owner == geteuid(),
              admitted.mode & 0o7777 == 0o700, admitted.links >= 2,
              parent == nil || admitted.device == parent?.admitted.device else {
            throw H3QualificationControllerFailure.rejected("directory policy")
        }
    }

    func identityJoin() throws {
        let held = try H3QualificationStorage.snapshot(descriptor.value)
        let named = try H3QualificationStorage.openAbsolute(path, directory: true)
        let observed = try H3QualificationStorage.snapshot(named.value)
        try named.close()
        guard held.sameIdentity(as: admitted), observed.sameIdentity(as: held) else {
            throw H3QualificationControllerFailure.rejected("directory identity")
        }
    }

    func requireInventory(_ expected: [String], maximum: Int) throws {
        let duplicate = try H3QualificationDescriptor(Darwin.fcntl(descriptor.value, F_DUPFD_CLOEXEC, 0))
        guard try H3QualificationStorage.snapshot(duplicate.value).sameIdentity(as: admitted) else {
            throw H3QualificationControllerFailure.rejected("directory duplicate identity")
        }
        guard let directory = fdopendir(duplicate.value) else {
            throw H3QualificationControllerFailure.system("fdopendir", errno)
        }
        _ = try duplicate.take()
        // dup shares the held directory's offset. Repeated inventory validation
        // starts at the beginning, never from an earlier enumeration's EOF.
        rewinddir(directory)
        var closed = false
        defer { if !closed { closedir(directory) } }
        var names = Set<String>(), dots = Set<String>(), reachedEOF = false
        for _ in 0..<(maximum + 3) {
            errno = 0
            guard let entry = readdir(directory) else {
                guard errno == 0 else { throw H3QualificationControllerFailure.system("readdir", errno) }
                reachedEOF = true; break
            }
            let length = Int(entry.pointee.d_namlen)
            guard length >= 1, length <= 255 else {
                throw H3QualificationControllerFailure.rejected("directory name bound")
            }
            let name = try withUnsafeBytes(of: entry.pointee.d_name) { raw -> String in
                guard length < raw.count, raw[length] == 0,
                      raw[..<length].allSatisfy({ $0 > 0 && $0 < 128 && $0 != 47 }),
                      let value = String(bytes: raw[..<length], encoding: .ascii) else {
                    throw H3QualificationControllerFailure.rejected("directory name")
                }
                return value
            }
            if name == "." || name == ".." {
                guard dots.insert(name).inserted else { throw H3QualificationControllerFailure.rejected("dot duplicate") }
            } else {
                guard names.count < maximum, names.insert(name).inserted, expected.contains(name) else {
                    throw H3QualificationControllerFailure.rejected("directory inventory")
                }
                // Namespace admission checks every entry's type and metadata even
                // in a run mode, which content-reads only its three prelaunch files.
                var entryStat = stat()
                guard fstatat(descriptor.value, name, &entryStat, AT_SYMLINK_NOFOLLOW) == 0 else {
                    throw H3QualificationControllerFailure.system("inventory metadata", errno)
                }
                let entryIdentity = H3QualificationFileSnapshot(entryStat)
                if name == "debug" || name == "release" {
                    guard entryIdentity.mode & UInt16(S_IFMT) == UInt16(S_IFDIR),
                          entryIdentity.owner == geteuid(), entryIdentity.mode & 0o7777 == 0o700,
                          entryIdentity.links >= 2, entryIdentity.device == admitted.device else {
                        throw H3QualificationControllerFailure.rejected("run directory inventory policy")
                    }
                } else {
                    try H3QualificationStorage.admitRegular(entryIdentity,
                        maximum: H3QualificationCampaignLoader.maximum(name), device: admitted.device)
                }
            }
        }
        let closeResult = closedir(directory); closed = true
        guard closeResult == 0, reachedEOF, dots == Set([".", ".."]), names.sorted() == expected.sorted() else {
            throw H3QualificationControllerFailure.rejected("directory terminal inventory")
        }
        try identityJoin()
    }

    func readLeaf(_ name: String, maximum: Int) throws -> H3QualificationStorage.Capture {
        let descriptor = try H3QualificationDescriptor(Darwin.openat(self.descriptor.value, name,
                                                                   H3QualificationStorage.readFlags))
        let capture = try H3QualificationStorage.read(descriptor.value, maximum: maximum, device: admitted.device)
        try descriptor.close()
        try identityOnlyLeaf(name, expected: capture.snapshot)
        return capture
    }

    func identityOnlyLeaf(_ name: String, expected: H3QualificationFileSnapshot) throws {
        let named = try H3QualificationDescriptor(Darwin.openat(descriptor.value, name,
                                                              H3QualificationStorage.readFlags))
        let snapshot = try H3QualificationStorage.snapshot(named.value)
        try named.close()
        guard snapshot == expected else { throw H3QualificationControllerFailure.rejected("named leaf changed") }
    }

    func createLeaf(_ name: String, readWrite: Bool = false) throws -> H3QualificationDescriptor {
        let flags = (readWrite ? O_RDWR : O_WRONLY) | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC
        let result = try H3QualificationDescriptor(Darwin.openat(descriptor.value, name, flags, mode_t(0o600)))
        let value = try H3QualificationStorage.snapshot(result.value)
        try H3QualificationStorage.admitRegular(value, maximum: 0, device: admitted.device)
        return result
    }

    func finishLeaf(_ name: String, writer: H3QualificationDescriptor, bytes: Data,
                    maximum: Int) throws -> H3QualificationStorage.Capture {
        let before = try H3QualificationStorage.snapshot(writer.value)
        try H3QualificationStorage.admitRegular(before, maximum: 0, device: admitted.device)
        try H3QualificationStorage.writeAll(bytes, descriptor: writer.value, maximum: maximum)
        try H3QualificationStorage.sync(writer.value)
        let completed = try H3QualificationStorage.snapshot(writer.value)
        guard completed.sameIdentity(as: before), completed.size == Int64(bytes.count) else {
            throw H3QualificationControllerFailure.durability
        }
        try writer.close()
        let reopened = try H3QualificationDescriptor(Darwin.openat(descriptor.value, name,
                                                                 H3QualificationStorage.readFlags))
        let capture = try H3QualificationStorage.read(reopened.value, maximum: maximum, device: admitted.device)
        try reopened.close()
        guard capture.snapshot == completed, capture.bytes == bytes, capture.sha256 == h3qHash(bytes) else {
            throw H3QualificationControllerFailure.durability
        }
        return capture
    }

    func writeLeaf(_ name: String, bytes: Data, maximum: Int) throws -> H3QualificationStorage.Capture {
        try finishLeaf(name, writer: createLeaf(name), bytes: bytes, maximum: maximum)
    }

    func syncDirectory() throws {
        guard Darwin.fsync(descriptor.value) == 0 else { throw H3QualificationControllerFailure.durability }
    }
}

/// The effect adapter is compiled only into the controller. The shared policy
/// receives deep captures/observations, never this owner or its descriptors.
final class H3QualificationPrelaunchProvider {
    typealias Transaction = H3QualificationPrelaunchTransaction<H3QualificationFileSnapshot>
    typealias Role = H3QualificationPrelaunchSelection.Role
    private let campaign: H3QualificationDirectory
    private let selection: H3QualificationPrelaunchSelection
    private var active: (Role, Transaction.Acquisition, H3QualificationDescriptor)?

    init(campaign: H3QualificationDirectory, selection: H3QualificationPrelaunchSelection) throws {
        guard campaign.path == selection.campaignRoot else {
            throw H3QualificationControllerFailure.rejected("prelaunch provider owner")
        }
        self.campaign = campaign; self.selection = selection
    }

    var operations: Transaction.Operations {
        .init(begin: { try self.begin($0, $1) }, capture: { try self.capture($0) },
              observe: { try self.observe($0) }, end: { try self.end($0, $1) },
              revalidateOwner: {
                  try self.campaign.identityJoin()
                  return try H3QualificationStorage.snapshot(self.campaign.descriptor.value)
              })
    }

    private func begin(_ role: Role, _ acquisition: Transaction.Acquisition) throws {
        guard active == nil else { throw H3QualificationControllerFailure.rejected("prelaunch acquisition active") }
        // The sole fallible acquisition either fails without ownership or stores
        // the new descriptor. Nothing fallible follows a successful acquisition.
        let descriptor = try H3QualificationDescriptor(Darwin.openat(campaign.descriptor.value,
            selection.name(role), H3QualificationStorage.readFlags))
        active = (role, acquisition, descriptor)
    }

    private func descriptor(_ role: Role, _ acquisition: Transaction.Acquisition) throws -> H3QualificationDescriptor {
        guard let active, active.0 == role, active.1 == acquisition else {
            throw H3QualificationControllerFailure.rejected("prelaunch acquisition selection")
        }
        return active.2
    }

    private func capture(_ role: Role) throws -> Transaction.Capture {
        let descriptor = try descriptor(role, .content)
        let captured = try H3QualificationStorage.read(descriptor.value, maximum: 262144,
                                                       device: campaign.admitted.device)
        return .init(bytes: captured.bytes, observation: .init(role: role,
            owner: try H3QualificationStorage.snapshot(campaign.descriptor.value), identity: captured.snapshot))
    }

    private func observe(_ role: Role) throws -> Transaction.Observation {
        let descriptor = try descriptor(role, .identity)
        let identity = try H3QualificationStorage.snapshot(descriptor.value)
        return .init(role: role, owner: try H3QualificationStorage.snapshot(campaign.descriptor.value),
                     identity: identity)
    }

    private func end(_ role: Role, _ acquisition: Transaction.Acquisition) throws {
        let descriptor = try descriptor(role, acquisition)
        active = nil
        try descriptor.close()
    }
}

final class H3QualificationCampaignLoader {
    static let prelaunch = ["build-source-manifest.json", "debug-build-settings.json", "debug-build.log",
                            "debug-product-audit.json", "release-build-settings.json", "release-build.log",
                            "release-product-audit.json", "source-state.json"]
    static let prior = ["prior-admission-campaign-seal.json", "prior-admission-checkpoint.json",
                        "prior-admission-verifier-supervisor.json"]
    static let closedRun = ["application-stderr.bin", "inner-application-report.frame", "manifest.json",
                            "outer-observer-receipt.json", "seal-supervisor-receipt.json"]
    private(set) var campaign: H3QualificationDirectory?
    private(set) var debug: H3QualificationDirectory?
    private(set) var release: H3QualificationDirectory?

    func close() throws {
        // Normal completion observes every close result before an exit-zero claim.
        if let release { try release.descriptor.close(); self.release = nil }
        if let debug { try debug.descriptor.close(); self.debug = nil }
        if let campaign { try campaign.descriptor.close(); self.campaign = nil }
    }

    static func rootPath(_ mode: H3QualificationMode) -> String {
        mode == .admissionOnly ? "/private/tmp/ergentics-h3q-admission-campaign-v1" :
            "/private/tmp/ergentics-h3q-guest-campaign-v1"
    }

    static func maximum(_ leaf: String) -> Int {
        switch leaf {
        case "debug-build.log", "release-build.log": return 8388608
        case "debug-build-settings.json", "release-build-settings.json": return 1048576
        case "inner-application-report.frame": return 65552
        case "application-stderr.bin", "manifest.json": return 65536
        case "outer-observer-receipt.json", "seal-supervisor-receipt.json",
             "prior-admission-verifier-supervisor.json": return 131072
        default: return 262144
        }
    }

    func admit(rootPath: String, mode: H3QualificationMode,
               running configuration: H3QualificationConfiguration?) throws {
        guard campaign == nil, rootPath == Self.rootPath(mode) else {
            throw H3QualificationControllerFailure.rejected("campaign root")
        }
        let root = try H3QualificationDirectory(path: rootPath)
        let debug = try H3QualificationDirectory(path: rootPath + "/debug", parent: root, basename: "debug")
        let release = try H3QualificationDirectory(path: rootPath + "/release", parent: root, basename: "release")
        try root.requireInventory(Self.prelaunch + (mode == .guest ? Self.prior : []) + ["debug", "release"], maximum: 16)
        try debug.requireInventory(configuration == .debug ? [] : Self.closedRun, maximum: 5)
        try release.requireInventory(configuration == nil ? Self.closedRun : [], maximum: 5)
        campaign = root; self.debug = debug; self.release = release
    }

    func load(rootPath: String, mode: H3QualificationMode) throws -> H3QualificationCampaignArtifactBundle {
        try admit(rootPath: rootPath, mode: mode, running: nil)
        guard let campaign, let debug, let release else {
            throw H3QualificationControllerFailure.rejected("loader ownership")
        }
        var artifacts: [String: Data] = [:]
        for name in Self.prelaunch + (mode == .guest ? Self.prior : []) {
            artifacts[name] = try campaign.readLeaf(name, maximum: Self.maximum(name)).bytes
        }
        for (prefix, directory) in [("debug", debug), ("release", release)] {
            for name in Self.closedRun {
                artifacts[prefix + "/" + name] = try directory.readLeaf(name, maximum: Self.maximum(name)).bytes
            }
        }
        try campaign.identityJoin(); try debug.identityJoin(); try release.identityJoin()
        guard artifacts.count == (mode == .admissionOnly ? 18 : 21) else {
            throw H3QualificationControllerFailure.rejected("bundle inventory")
        }
        return H3QualificationCampaignArtifactBundle(mode: mode, artifacts: artifacts)
    }
}
#endif
