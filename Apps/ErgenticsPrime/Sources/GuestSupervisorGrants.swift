import Darwin
import Foundation

// Presentation values are not capabilities, live native results, or authority.
struct GuestEventDisplay: Identifiable, Sendable {
    let id: Int
    let kind: String
    let digest: String
    let byteCount: Int
}

struct GuestPresentation: Identifiable, Sendable {
    let id: String
    let status: String
    let detail: String
    let root: String
    let elapsed: String
    let events: [GuestEventDisplay]
    let quarantined: Bool
    var volatileObservation: Data? = nil
}

/// The journal worker releases its reservation before publishing completion.
/// A failed release preserves the native token and all journal observations;
/// neither retry nor deinit is a second opportunity to claim conservation.
enum GuestProductReservationRelease {
    static func finish(state: inout H3QualificationReservationStateMachine,
                       token: inout OpaquePointer?, completed: inout Bool,
                       release: (OpaquePointer) -> Int32) -> Int32 {
        guard !completed, state.policy == .qualificationChecked else { return EINVAL }
        completed = true
        if state.state == .unprepared, token == nil { return 0 }
        let decision: H3QualificationReservationStateMachine.ReleaseDecision
        do { decision = try state.beginCheckedRelease(tokenPresent: token != nil) }
        catch { return EINVAL }
        guard decision == .callToken else { return 0 }
        guard let owned = token else { return EINVAL }
        token = nil
        let status = release(owned)
        if status != 0 { token = owned }
        do { try state.finishCheckedRelease(status: status) }
        catch { return status == 0 ? EINVAL : status }
        return status
    }

    static func presentation(_ observed: GuestPresentation, releaseStatus: Int32) -> GuestPresentation {
        guard releaseStatus != 0 else { return observed }
        return GuestPresentation(id: observed.id, status: "INCOMPLETE",
            detail: "Native reservation release failed (\(releaseStatus)). The recorded result was \(observed.status): \(observed.detail) This launch is quarantined without retry; recorded evidence is preserved.",
            root: observed.root, elapsed: observed.elapsed, events: observed.events,
            quarantined: true, volatileObservation: observed.volatileObservation)
    }
}

struct GuestRetentionProvisionFailure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

struct GuestRetentionAncestry: Equatable, Sendable {
    let epochID: String
    let genesisSHA256: String
}

/// Launch-local policy only. Kernel creation and the held-root lock remain the
/// cross-process authorities. This one state machine makes Create and Open
/// mutually exclusive, rejects late completions, and consumes every failure.
struct GuestStorageTransition: Sendable {
    private enum State: Sendable {
        case inert, creating(UInt64), opening(UInt64), liveReady, historyReady, failed
    }
    private var state: State = .inert
    private var nextTicket: UInt64 = 1

    var canBegin: Bool { if case .inert = state { true } else { false } }
    var attempted: Bool { if case .inert = state { false } else { true } }
    var creating: Bool { if case .creating = state { true } else { false } }
    var opening: Bool { if case .opening = state { true } else { false } }

    mutating func beginCreate() -> UInt64? {
        guard case .inert = state else { return nil }
        let ticket = nextTicket
        nextTicket &+= 1
        state = .creating(ticket)
        return ticket
    }

    mutating func beginOpen() -> UInt64? {
        guard case .inert = state else { return nil }
        let ticket = nextTicket
        nextTicket &+= 1
        state = .opening(ticket)
        return ticket
    }

    mutating func completeCreate(ticket: UInt64, accepted: Bool) -> Bool {
        guard case .creating(let current) = state, current == ticket else { return false }
        state = accepted ? .liveReady : .failed
        return true
    }

    mutating func completeOpen(ticket: UInt64, accepted: Bool) -> Bool {
        guard case .opening(let current) = state, current == ticket else { return false }
        state = accepted ? .historyReady : .failed
        return true
    }
}

/// A process-local capability seal. It retains the exact newly created journal
/// root and its immutable genesis leaf; a later named-path reopen must join both
/// held vnodes before SQLite can be opened. It is not a sandbox boundary, path
/// loader, persistence locator, or authority that crosses an app relaunch.
final class GuestRetentionDirectorySeal: @unchecked Sendable {
    let rootPath: String
    let epochID: String
    let genesisDigest: String
    private let directoryFD: Int32
    private let genesisFD: Int32
    private let genesisBytes: Data
    private let rootDevice: dev_t
    private let rootInode: ino_t
    private let genesisDevice: dev_t
    private let genesisInode: ino_t

    init(adoptingDirectoryFD: Int32, adoptingGenesisFD: Int32,
         rootPath: String, epochID: String, genesisBytes: Data,
         rootMetadata: stat, genesisMetadata: stat) {
        directoryFD = adoptingDirectoryFD
        genesisFD = adoptingGenesisFD
        self.rootPath = rootPath
        self.epochID = epochID
        self.genesisBytes = genesisBytes
        genesisDigest = GuestContract.hash(genesisBytes)
        rootDevice = rootMetadata.st_dev
        rootInode = rootMetadata.st_ino
        genesisDevice = genesisMetadata.st_dev
        genesisInode = genesisMetadata.st_ino
    }

    deinit {
        _ = Darwin.close(genesisFD)
        _ = Darwin.close(directoryFD)
    }

    func revalidate(openedParentFD: Int32? = nil) throws {
        var heldRoot = stat(), namedRoot = stat(), heldGenesis = stat(), namedGenesis = stat()
        guard fstat(directoryFD, &heldRoot) == 0,
              rootPath.withCString({ lstat($0, &namedRoot) }) == 0,
              fstat(genesisFD, &heldGenesis) == 0,
              GuestRetentionProvisioner.genesisLeaf.withCString({
                  fstatat(directoryFD, $0, &namedGenesis, AT_SYMLINK_NOFOLLOW)
              }) == 0 else {
            throw GuestRetentionProvisionFailure("Retention capability vnode revalidation failed (errno \(errno))")
        }
        try Self.privateDirectory(heldRoot)
        try Self.privateDirectory(namedRoot)
        try Self.privateFile(heldGenesis)
        try Self.privateFile(namedGenesis)
        let genesisFlags = fcntl(genesisFD, F_GETFL)
        guard genesisFlags >= 0, genesisFlags & O_ACCMODE == O_RDONLY,
              heldRoot.st_dev == rootDevice, heldRoot.st_ino == rootInode,
              namedRoot.st_dev == rootDevice, namedRoot.st_ino == rootInode,
              heldGenesis.st_dev == genesisDevice, heldGenesis.st_ino == genesisInode,
              namedGenesis.st_dev == genesisDevice, namedGenesis.st_ino == genesisInode else {
            throw GuestRetentionProvisionFailure("Retention root or genesis was replaced")
        }
        if let openedParentFD {
            var openedRoot = stat()
            guard fstat(openedParentFD, &openedRoot) == 0,
                  openedRoot.st_dev == rootDevice, openedRoot.st_ino == rootInode else {
                throw GuestRetentionProvisionFailure("Journal opener did not join the retained root")
            }
        }
        var readback = Data(count: genesisBytes.count)
        var offset = 0
        while offset < readback.count {
            let count = readback.withUnsafeMutableBytes { bytes in
                pread(genesisFD, bytes.baseAddress!.advanced(by: offset), bytes.count - offset, off_t(offset))
            }
            if count < 0, errno == EINTR { continue }
            guard count > 0 else {
                throw GuestRetentionProvisionFailure("Retention genesis read-back failed (errno \(errno))")
            }
            offset += count
        }
        var trailing: UInt8 = 0
        guard pread(genesisFD, &trailing, 1, off_t(readback.count)) == 0,
              readback == genesisBytes,
              GuestContract.hash(readback) == genesisDigest else {
            throw GuestRetentionProvisionFailure("Retention genesis bytes changed")
        }
    }

    private static func privateDirectory(_ value: stat) throws {
        guard value.st_mode & S_IFMT == S_IFDIR,
              value.st_mode & 0o7777 == 0o700,
              value.st_uid == geteuid() else {
            throw GuestRetentionProvisionFailure("Retention root must remain self-owned mode 0700")
        }
    }

    private static func privateFile(_ value: stat) throws {
        guard value.st_mode & S_IFMT == S_IFREG,
              value.st_mode & 0o7777 == 0o600,
              value.st_uid == geteuid(), value.st_nlink == 1 else {
            throw GuestRetentionProvisionFailure("Retention genesis must remain an unaliased self-owned mode-0600 file")
        }
    }
}

/// The only production journal provisioner. It is called after an explicit UI
/// intent, never at startup. It uses Apple's sandbox-scoped Application Support
/// location, creates one fixed private root exactly once, enumerates no parent,
/// installs no bookmark/current pointer, and retains every partial outcome. A
/// later read-only reconstruction action can address this exact root without
/// restoring execution authority; it is deliberately not implemented here.
enum GuestRetentionProvisioner {
    static let rootLeaf = "guest-journal-v1"
    static let journalLeaf = "guest-events.sqlite3"
    static let genesisLeaf = "journal-genesis.cbor"
    fileprivate static let epochPrefix = "epoch-"
    fileprivate static let genesisSchema = "com.ergentics.provenance.private-journal-genesis.v1"
    fileprivate static let genesisScope = "retention capability only; no guest execution or Gate E authority"

    static func provisionForExplicitUserAction() throws -> GuestSupervisorRetentionGrant {
        let base = try FileManager.default.url(for: .applicationSupportDirectory,
            in: .userDomainMask, appropriateFor: nil, create: true)
        return try provisionCore(applicationSupportURL: base,
            epochID: epochPrefix + UUID().uuidString.lowercased())
    }

    #if EPR_GUEST_JOURNAL_TESTS
    /// Deterministic hostless fixture seam. This entry is absent from the app
    /// binary; production supplies neither a URL nor an epoch identifier.
    static func provisionForTests(applicationSupportURL: URL, epochID: String) throws
        -> GuestSupervisorRetentionGrant {
        try provisionCore(applicationSupportURL: applicationSupportURL, epochID: epochID)
    }
    #endif

    private static func provisionCore(applicationSupportURL: URL, epochID: String) throws
        -> GuestSupervisorRetentionGrant {
        guard applicationSupportURL.isFileURL, applicationSupportURL.baseURL == nil,
              applicationSupportURL.host == nil || applicationSupportURL.host == "",
              applicationSupportURL.user == nil, applicationSupportURL.password == nil,
              applicationSupportURL.port == nil, applicationSupportURL.query == nil,
              applicationSupportURL.fragment == nil, applicationSupportURL.hasDirectoryPath,
              !applicationSupportURL.path.isEmpty,
              validEpochID(epochID) else {
            throw GuestRetentionProvisionFailure("Application Support capability or fresh epoch ID is invalid")
        }
        let basePath = applicationSupportURL.path
        guard basePath.hasPrefix("/"), basePath != "/", !basePath.hasSuffix("/"),
              !basePath.contains("//"), !basePath.utf8.contains(0),
              !basePath.split(separator: "/").contains(where: { $0 == "." || $0 == ".." }) else {
            throw GuestRetentionProvisionFailure("Application Support must be an exact absolute physical path")
        }
        guard let resolved = realpath(basePath, nil) else {
            throw GuestRetentionProvisionFailure("Application Support realpath failed (errno \(errno))")
        }
        let physicalBase = String(validatingCString: resolved)
        free(resolved)
        guard let physicalBase, exact(physicalBase, basePath) else {
            throw GuestRetentionProvisionFailure("Application Support path is an alias")
        }

        var namedBase = stat()
        guard basePath.withCString({ lstat($0, &namedBase) }) == 0 else {
            throw GuestRetentionProvisionFailure("Application Support lstat failed (errno \(errno))")
        }
        let baseFD = basePath.withCString { Darwin.open($0, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC) }
        guard baseFD >= 0 else {
            throw GuestRetentionProvisionFailure("Application Support open failed (errno \(errno))")
        }
        defer { _ = Darwin.close(baseFD) }
        var heldBase = stat()
        guard fstat(baseFD, &heldBase) == 0,
              heldBase.st_mode & S_IFMT == S_IFDIR,
              heldBase.st_uid == geteuid(), heldBase.st_mode & 0o022 == 0,
              heldBase.st_dev == namedBase.st_dev, heldBase.st_ino == namedBase.st_ino else {
            throw GuestRetentionProvisionFailure("Application Support admission or vnode join failed")
        }

        guard rootLeaf.withCString({ mkdirat(baseFD, $0, mode_t(0o700)) }) == 0 else {
            throw GuestRetentionProvisionFailure("Fresh retention root creation failed (errno \(errno)); no adoption or retry")
        }
        let rootPath = basePath + "/" + rootLeaf
        let rootFD = rootLeaf.withCString {
            openat(baseFD, $0, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        }
        guard rootFD >= 0 else {
            throw GuestRetentionProvisionFailure("Fresh retention root open failed (errno \(errno)); root retained")
        }
        var rootTransferred = false
        defer { if !rootTransferred { _ = Darwin.close(rootFD) } }
        var heldRoot = stat(), namedRoot = stat()
        guard fstat(rootFD, &heldRoot) == 0,
              rootLeaf.withCString({ fstatat(baseFD, $0, &namedRoot, AT_SYMLINK_NOFOLLOW) }) == 0,
              heldRoot.st_mode & S_IFMT == S_IFDIR, heldRoot.st_mode & 0o7777 == 0o700,
              heldRoot.st_uid == geteuid(), heldRoot.st_dev == namedRoot.st_dev,
              heldRoot.st_ino == namedRoot.st_ino else {
            throw GuestRetentionProvisionFailure("Fresh retention root admission failed; root retained")
        }

        guard flock(rootFD, LOCK_EX | LOCK_NB) == 0 else {
            throw GuestRetentionProvisionFailure("Fresh retention root lock failed (errno \(errno)); root retained")
        }

        let genesisValue = expectedGenesis(epochID: epochID)
        let genesis = try GuestCBOR.encode(genesisValue)
        guard try GuestCBOR.decode(genesis) == genesisValue else {
            throw GuestRetentionProvisionFailure("Retention genesis CBOR reconstruction failed")
        }
        let genesisWriterFD = genesisLeaf.withCString {
            openat(rootFD, $0, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, mode_t(0o600))
        }
        guard genesisWriterFD >= 0 else {
            throw GuestRetentionProvisionFailure("Retention genesis creation failed (errno \(errno)); root retained")
        }
        var genesisWriterOpen = true
        defer { if genesisWriterOpen { _ = Darwin.close(genesisWriterFD) } }
        try writeAll(genesis, to: genesisWriterFD)
        guard fsync(genesisWriterFD) == 0, fcntl(genesisWriterFD, F_FULLFSYNC) == 0,
              fsync(rootFD) == 0, fsync(baseFD) == 0 else {
            throw GuestRetentionProvisionFailure("Retention genesis durability barrier failed (errno \(errno)); outcome retained")
        }
        var writtenGenesis = stat()
        guard fstat(genesisWriterFD, &writtenGenesis) == 0 else {
            throw GuestRetentionProvisionFailure("Retention genesis writer identity failed; outcome retained")
        }
        guard Darwin.close(genesisWriterFD) == 0 else {
            throw GuestRetentionProvisionFailure("Retention genesis writer close failed (errno \(errno)); outcome retained")
        }
        genesisWriterOpen = false
        let genesisFD = genesisLeaf.withCString {
            openat(rootFD, $0, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        }
        guard genesisFD >= 0 else {
            throw GuestRetentionProvisionFailure("Retention genesis read-only reopen failed (errno \(errno)); outcome retained")
        }
        var genesisTransferred = false
        defer { if !genesisTransferred { _ = Darwin.close(genesisFD) } }
        var heldGenesis = stat(), namedGenesis = stat()
        guard fstat(genesisFD, &heldGenesis) == 0,
              genesisLeaf.withCString({ fstatat(rootFD, $0, &namedGenesis, AT_SYMLINK_NOFOLLOW) }) == 0,
              heldGenesis.st_mode & S_IFMT == S_IFREG, heldGenesis.st_mode & 0o7777 == 0o600,
              heldGenesis.st_uid == geteuid(), heldGenesis.st_nlink == 1,
              heldGenesis.st_dev == writtenGenesis.st_dev, heldGenesis.st_ino == writtenGenesis.st_ino,
              heldGenesis.st_dev == namedGenesis.st_dev, heldGenesis.st_ino == namedGenesis.st_ino,
              heldGenesis.st_size == genesis.count else {
            throw GuestRetentionProvisionFailure("Retention genesis vnode join failed; outcome retained")
        }
        let seal = GuestRetentionDirectorySeal(adoptingDirectoryFD: rootFD,
            adoptingGenesisFD: genesisFD, rootPath: rootPath, epochID: epochID,
            genesisBytes: genesis, rootMetadata: heldRoot, genesisMetadata: heldGenesis)
        rootTransferred = true
        genesisTransferred = true
        try seal.revalidate()
        return try GuestSupervisorRetentionGrant(provisionedJournalURL:
            URL(fileURLWithPath: rootPath + "/" + journalLeaf, isDirectory: false), seal: seal)
    }

    fileprivate static func validEpochID(_ value: String) -> Bool {
        guard value.utf8.count == 42, value.utf8.starts(with: epochPrefix.utf8) else { return false }
        let body = String(value.dropFirst(epochPrefix.count))
        guard let uuid = UUID(uuidString: body) else { return false }
        return uuid.uuidString.lowercased().utf8.elementsEqual(body.utf8)
    }

    fileprivate static func expectedGenesis(epochID: String) -> GuestCBORValue {
        .map([
            "schema": .text(genesisSchema),
            "root_leaf": .text(rootLeaf),
            "epoch_id": .text(epochID),
            "journal_leaf": .text(journalLeaf),
            "host_bundle": .text("com.ergentics.provenance"),
            "scope": .text(genesisScope)
        ])
    }

    private static func writeAll(_ data: Data, to descriptor: Int32) throws {
        var offset = 0
        while offset < data.count {
            let count = data.withUnsafeBytes { bytes in
                Darwin.write(descriptor, bytes.baseAddress!.advanced(by: offset), bytes.count - offset)
            }
            if count < 0, errno == EINTR { continue }
            guard count > 0 else {
                throw GuestRetentionProvisionFailure("Retention genesis write failed (errno \(errno))")
            }
            offset += count
        }
    }

    private static func exact(_ left: String, _ right: String) -> Bool {
        left.utf8.elementsEqual(right.utf8)
    }
}

struct GuestHistoryReconstructionFailure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

/// Explicit, zero-argument production reconstruction of the one fixed private
/// journal. It addresses only frozen names through held directories, performs
/// no directory enumeration, and returns only immutable verified presentation.
enum GuestHistoryReconstructor {
    private static let maximumGenesisBytes = 4_096
    private static let maximumJournalBytes = 128 * 1_048_576
    private static let sidecarLeaves = [
        GuestRetentionProvisioner.journalLeaf + "-wal",
        GuestRetentionProvisioner.journalLeaf + "-shm",
        GuestRetentionProvisioner.journalLeaf + "-journal",
    ]

    private struct HeldFile {
        let descriptor: Int32
        let metadata: stat
        let bytes: Data
    }

    static func reconstructForExplicitUserAction() throws -> GuestSupervisorHistoryGrant {
        let base = try FileManager.default.url(for: .applicationSupportDirectory,
            in: .userDomainMask, appropriateFor: nil, create: false)
        return try reconstructCore(applicationSupportURL: base, beforeFinalRevalidation: nil)
    }

    #if EPR_GUEST_JOURNAL_TESTS
    /// Hostless fixed-root seam. It is absent from the production app binary.
    static func reconstructForTests(applicationSupportURL: URL,
                                    beforeFinalRevalidation: (() throws -> Void)? = nil) throws
        -> GuestSupervisorHistoryGrant {
        try reconstructCore(applicationSupportURL: applicationSupportURL,
            beforeFinalRevalidation: beforeFinalRevalidation)
    }
    #endif

    private static func reconstructCore(applicationSupportURL: URL,
                                        beforeFinalRevalidation: (() throws -> Void)?) throws
        -> GuestSupervisorHistoryGrant {
        let basePath = try validateApplicationSupportURL(applicationSupportURL)
        var namedBase = stat()
        guard basePath.withCString({ lstat($0, &namedBase) }) == 0 else {
            throw failure("Application Support lstat")
        }
        let baseFD = basePath.withCString {
            Darwin.open($0, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        }
        guard baseFD >= 0 else { throw failure("Application Support open") }
        defer { _ = Darwin.close(baseFD) }
        var heldBase = stat()
        guard fstat(baseFD, &heldBase) == 0,
              admissibleApplicationSupport(heldBase), admissibleApplicationSupport(namedBase),
              sameVnode(heldBase, namedBase), descriptorIsCloseOnExec(baseFD) else {
            throw GuestHistoryReconstructionFailure("Application Support admission or vnode join failed")
        }

        let rootFD = GuestRetentionProvisioner.rootLeaf.withCString {
            openat(baseFD, $0, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        }
        guard rootFD >= 0 else { throw failure("fixed retention root open") }
        defer { _ = Darwin.close(rootFD) }
        var heldRoot = stat(), namedRoot = stat()
        guard fstat(rootFD, &heldRoot) == 0,
              GuestRetentionProvisioner.rootLeaf.withCString({
                  fstatat(baseFD, $0, &namedRoot, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              privateDirectory(heldRoot), privateDirectory(namedRoot),
              sameVnode(heldRoot, namedRoot), descriptorIsCloseOnExec(rootFD),
              flock(rootFD, LOCK_EX | LOCK_NB) == 0 else {
            throw GuestHistoryReconstructionFailure("Fixed retention root admission or exclusive lock failed (errno \(errno))")
        }

        try requireSidecarsAbsent(rootFD)
        let genesis = try openHeldFile(rootFD, leaf: GuestRetentionProvisioner.genesisLeaf,
            minimum: 1, maximum: maximumGenesisBytes)
        defer { _ = Darwin.close(genesis.descriptor) }
        guard case .map(let genesisObject) = try GuestCBOR.decode(genesis.bytes),
              case .text(let epochID)? = genesisObject["epoch_id"],
              GuestRetentionProvisioner.validEpochID(epochID),
              GuestCBORValue.map(genesisObject) == GuestRetentionProvisioner.expectedGenesis(epochID: epochID) else {
            throw GuestHistoryReconstructionFailure("Retention genesis is not the exact canonical six-key contract")
        }
        let ancestry = GuestRetentionAncestry(epochID: epochID,
            genesisSHA256: GuestContract.hash(genesis.bytes))

        let journalFD = GuestRetentionProvisioner.journalLeaf.withCString {
            openat(rootFD, $0, O_RDONLY | O_NOFOLLOW | O_NONBLOCK | O_CLOEXEC)
        }
        if journalFD < 0 {
            guard errno == ENOENT else { throw failure("fixed journal open") }
            try beforeFinalRevalidation?()
            try requireSidecarsAbsent(rootFD)
            try revalidateBaseAndRoot(baseFD: baseFD, basePath: basePath,
                expectedBase: heldBase, rootFD: rootFD, expectedRoot: heldRoot)
            try revalidateHeldFile(rootFD, leaf: GuestRetentionProvisioner.genesisLeaf,
                held: genesis, maximum: maximumGenesisBytes)
            try requireNameAbsent(rootFD, leaf: GuestRetentionProvisioner.journalLeaf)
            try requireSidecarsAbsent(rootFD)
            try revalidateBaseAndRoot(baseFD: baseFD, basePath: basePath,
                expectedBase: heldBase, rootFD: rootFD, expectedRoot: heldRoot)
            return try GuestSupervisorHistoryGrant(reconstructedRuns: [], expectedRetention: ancestry,
                journalSHA256: nil, genesisOnly: true)
        }
        let journal: HeldFile
        do {
            journal = try admitAlreadyOpenFile(journalFD, rootFD: rootFD,
                leaf: GuestRetentionProvisioner.journalLeaf, minimum: 100,
                maximum: maximumJournalBytes)
        } catch {
            _ = Darwin.close(journalFD)
            throw error
        }
        defer { _ = Darwin.close(journal.descriptor) }
        try requireSidecarsAbsent(rootFD)
        let snapshot = try GuestJournal.reconstructReadOnlySnapshot(databaseBytes: journal.bytes)
        let grant = try GuestSupervisorHistoryGrant(reconstructedRuns: snapshot.runs,
            expectedRetention: ancestry, journalSHA256: snapshot.journalSHA256, genesisOnly: false)

        try beforeFinalRevalidation?()
        try requireSidecarsAbsent(rootFD)
        try revalidateBaseAndRoot(baseFD: baseFD, basePath: basePath,
            expectedBase: heldBase, rootFD: rootFD, expectedRoot: heldRoot)
        try revalidateHeldFile(rootFD, leaf: GuestRetentionProvisioner.genesisLeaf,
            held: genesis, maximum: maximumGenesisBytes)
        try revalidateHeldFile(rootFD, leaf: GuestRetentionProvisioner.journalLeaf,
            held: journal, maximum: maximumJournalBytes)
        try requireSidecarsAbsent(rootFD)
        try revalidateBaseAndRoot(baseFD: baseFD, basePath: basePath,
            expectedBase: heldBase, rootFD: rootFD, expectedRoot: heldRoot)
        return grant
    }

    private static func validateApplicationSupportURL(_ url: URL) throws -> String {
        guard url.isFileURL, url.baseURL == nil,
              url.host == nil || url.host == "", url.user == nil, url.password == nil,
              url.port == nil, url.query == nil, url.fragment == nil,
              url.hasDirectoryPath, !url.path.isEmpty else {
            throw GuestHistoryReconstructionFailure("Application Support capability is invalid")
        }
        let path = url.path
        guard path.hasPrefix("/"), path != "/", !path.hasSuffix("/"),
              !path.contains("//"), !path.utf8.contains(0),
              !path.split(separator: "/").contains(where: { $0 == "." || $0 == ".." }),
              let resolved = realpath(path, nil) else {
            throw GuestHistoryReconstructionFailure("Application Support is not an exact absolute physical path")
        }
        let physical = String(validatingCString: resolved)
        free(resolved)
        guard let physical, physical.utf8.elementsEqual(path.utf8) else {
            throw GuestHistoryReconstructionFailure("Application Support path is an alias")
        }
        return path
    }

    private static func openHeldFile(_ rootFD: Int32, leaf: String,
                                     minimum: Int, maximum: Int) throws -> HeldFile {
        let descriptor = leaf.withCString {
            openat(rootFD, $0, O_RDONLY | O_NOFOLLOW | O_NONBLOCK | O_CLOEXEC)
        }
        guard descriptor >= 0 else { throw failure("fixed \(leaf) open") }
        do { return try admitAlreadyOpenFile(descriptor, rootFD: rootFD,
                leaf: leaf, minimum: minimum, maximum: maximum) }
        catch { _ = Darwin.close(descriptor); throw error }
    }

    private static func admitAlreadyOpenFile(_ descriptor: Int32, rootFD: Int32,
                                              leaf: String, minimum: Int,
                                              maximum: Int) throws -> HeldFile {
        var held = stat(), named = stat()
        guard fstat(descriptor, &held) == 0,
              leaf.withCString({ fstatat(rootFD, $0, &named, AT_SYMLINK_NOFOLLOW) }) == 0,
              privateFile(held), privateFile(named), sameHeldFileMetadata(held, named),
              held.st_size >= minimum, held.st_size <= maximum,
              descriptorIsReadOnly(descriptor), descriptorIsCloseOnExec(descriptor) else {
            throw GuestHistoryReconstructionFailure("Fixed \(leaf) admission or vnode join failed")
        }
        let bytes = try readExact(descriptor, count: Int(held.st_size))
        var afterRead = stat(), namedAfterRead = stat()
        guard try bytesMatchExact(descriptor, expected: bytes),
              fstat(descriptor, &afterRead) == 0,
              leaf.withCString({ fstatat(rootFD, $0, &namedAfterRead, AT_SYMLINK_NOFOLLOW) }) == 0,
              privateFile(afterRead), privateFile(namedAfterRead),
              sameHeldFileMetadata(afterRead, held),
              sameHeldFileMetadata(afterRead, namedAfterRead) else {
            throw GuestHistoryReconstructionFailure("Fixed \(leaf) changed during stable double snapshot")
        }
        return HeldFile(descriptor: descriptor, metadata: held, bytes: bytes)
    }

    private static func revalidateHeldFile(_ rootFD: Int32, leaf: String,
                                           held: HeldFile, maximum: Int) throws {
        var current = stat(), named = stat(), afterRead = stat(), namedAfterRead = stat()
        guard fstat(held.descriptor, &current) == 0,
              leaf.withCString({ fstatat(rootFD, $0, &named, AT_SYMLINK_NOFOLLOW) }) == 0,
              privateFile(current), privateFile(named),
              sameHeldFileMetadata(current, held.metadata),
              sameHeldFileMetadata(current, named), current.st_size == held.bytes.count,
              current.st_size <= maximum, descriptorIsReadOnly(held.descriptor),
              descriptorIsCloseOnExec(held.descriptor),
              try bytesMatchExact(held.descriptor, expected: held.bytes),
              fstat(held.descriptor, &afterRead) == 0,
              leaf.withCString({ fstatat(rootFD, $0, &namedAfterRead, AT_SYMLINK_NOFOLLOW) }) == 0,
              privateFile(afterRead), privateFile(namedAfterRead),
              sameHeldFileMetadata(afterRead, held.metadata),
              sameHeldFileMetadata(afterRead, namedAfterRead) else {
            throw GuestHistoryReconstructionFailure("Fixed \(leaf) failed post-snapshot identity or byte join")
        }
    }

    private static func revalidateBaseAndRoot(baseFD: Int32, basePath: String,
                                               expectedBase: stat, rootFD: Int32,
                                               expectedRoot: stat) throws {
        var heldBase = stat(), namedBase = stat(), heldRoot = stat(), namedRoot = stat()
        guard fstat(baseFD, &heldBase) == 0,
              basePath.withCString({ lstat($0, &namedBase) }) == 0,
              fstat(rootFD, &heldRoot) == 0,
              GuestRetentionProvisioner.rootLeaf.withCString({
                  fstatat(baseFD, $0, &namedRoot, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              sameVnode(heldBase, expectedBase), sameVnode(heldBase, namedBase),
              sameVnode(heldRoot, expectedRoot), sameVnode(heldRoot, namedRoot),
              admissibleApplicationSupport(heldBase), admissibleApplicationSupport(namedBase),
              privateDirectory(heldRoot), privateDirectory(namedRoot) else {
            throw GuestHistoryReconstructionFailure("Application Support or fixed retention root was replaced")
        }
    }

    private static func requireSidecarsAbsent(_ rootFD: Int32) throws {
        for leaf in sidecarLeaves { try requireNameAbsent(rootFD, leaf: leaf) }
    }

    private static func requireNameAbsent(_ rootFD: Int32, leaf: String) throws {
        var metadata = stat()
        let status = leaf.withCString { fstatat(rootFD, $0, &metadata, AT_SYMLINK_NOFOLLOW) }
        guard status != 0, errno == ENOENT else {
            throw GuestHistoryReconstructionFailure("Forbidden fixed SQLite sidecar or unexpected journal state: \(leaf)")
        }
    }

    private static func readExact(_ descriptor: Int32, count: Int) throws -> Data {
        var result = Data(count: count)
        var offset = 0
        while offset < count {
            let amount = result.withUnsafeMutableBytes { bytes in
                pread(descriptor, bytes.baseAddress!.advanced(by: offset), count - offset, off_t(offset))
            }
            if amount < 0, errno == EINTR { continue }
            guard amount > 0 else { throw failure("descriptor snapshot read") }
            offset += amount
        }
        var trailing: UInt8 = 0
        guard pread(descriptor, &trailing, 1, off_t(count)) == 0 else {
            throw GuestHistoryReconstructionFailure("Descriptor snapshot did not end at exact EOF")
        }
        return result
    }

    private static func bytesMatchExact(_ descriptor: Int32, expected: Data) throws -> Bool {
        let chunkSize = 64 * 1_024
        var offset = 0
        var chunk = Data(count: min(chunkSize, max(expected.count, 1)))
        while offset < expected.count {
            let wanted = min(chunkSize, expected.count - offset)
            let amount = chunk.withUnsafeMutableBytes { bytes in
                pread(descriptor, bytes.baseAddress!, wanted, off_t(offset))
            }
            if amount < 0, errno == EINTR { continue }
            guard amount == wanted,
                  chunk.prefix(wanted) == expected[offset..<(offset + wanted)] else { return false }
            offset += wanted
        }
        var trailing: UInt8 = 0
        return pread(descriptor, &trailing, 1, off_t(expected.count)) == 0
    }

    private static func privateDirectory(_ value: stat) -> Bool {
        value.st_mode & S_IFMT == S_IFDIR && value.st_mode & 0o7777 == 0o700 && value.st_uid == geteuid()
    }

    private static func admissibleApplicationSupport(_ value: stat) -> Bool {
        value.st_mode & S_IFMT == S_IFDIR && value.st_uid == geteuid() && value.st_mode & 0o022 == 0
    }

    private static func privateFile(_ value: stat) -> Bool {
        value.st_mode & S_IFMT == S_IFREG && value.st_mode & 0o7777 == 0o600 &&
            value.st_uid == geteuid() && value.st_nlink == 1
    }

    private static func sameVnode(_ left: stat, _ right: stat) -> Bool {
        left.st_dev == right.st_dev && left.st_ino == right.st_ino
    }

    /// Conserves every mutation-sensitive Darwin field except access time.
    /// Directory timestamps are intentionally not compared: this predicate is
    /// only for the two fixed held files, never for the non-enumerated roots.
    private static func sameHeldFileMetadata(_ left: stat, _ right: stat) -> Bool {
        sameVnode(left, right) &&
            left.st_gen == right.st_gen &&
            left.st_mode == right.st_mode &&
            left.st_uid == right.st_uid && left.st_gid == right.st_gid &&
            left.st_nlink == right.st_nlink && left.st_size == right.st_size &&
            left.st_flags == right.st_flags &&
            left.st_birthtimespec.tv_sec == right.st_birthtimespec.tv_sec &&
            left.st_birthtimespec.tv_nsec == right.st_birthtimespec.tv_nsec &&
            left.st_mtimespec.tv_sec == right.st_mtimespec.tv_sec &&
            left.st_mtimespec.tv_nsec == right.st_mtimespec.tv_nsec &&
            left.st_ctimespec.tv_sec == right.st_ctimespec.tv_sec &&
            left.st_ctimespec.tv_nsec == right.st_ctimespec.tv_nsec
    }

    private static func descriptorIsReadOnly(_ descriptor: Int32) -> Bool {
        let flags = fcntl(descriptor, F_GETFL)
        return flags >= 0 && flags & O_ACCMODE == O_RDONLY
    }

    private static func descriptorIsCloseOnExec(_ descriptor: Int32) -> Bool {
        let flags = fcntl(descriptor, F_GETFD)
        return flags >= 0 && flags & FD_CLOEXEC != 0
    }

    private static func failure(_ operation: String) -> GuestHistoryReconstructionFailure {
        GuestHistoryReconstructionFailure("\(operation) failed (errno \(errno))")
    }
}

/// An explicit supervisor handoff, not an OS capability or a same-process
/// security boundary. It names one journal and its SQLite sidecars, permits
/// append/read-back for the model's newly owned runs, and grants no discovery,
/// history enumeration, directory creation, guest disk, or authority restoration.
/// The caller must prepare the private physical parent before supplying this
/// value; GuestJournal still validates that parent and every opened file.
struct GuestSupervisorRetentionGrant: Sendable {
    let journalURL: URL
    private let seal: GuestRetentionDirectorySeal?

    #if EPR_GUEST_JOURNAL_TESTS
    /// Hostless fixture seam. This initializer is absent from the app binary.
    init(exactJournalURL: URL) throws {
        try Self.validate(exactJournalURL)
        journalURL = exactJournalURL
        seal = nil
    }
    #endif

    fileprivate init(provisionedJournalURL: URL, seal: GuestRetentionDirectorySeal) throws {
        try Self.validate(provisionedJournalURL)
        guard provisionedJournalURL.deletingLastPathComponent().path.utf8.elementsEqual(seal.rootPath.utf8),
              provisionedJournalURL.lastPathComponent == GuestRetentionProvisioner.journalLeaf else {
            throw GuestRetentionProvisionFailure("Provisioned journal did not join its retained root and fixed leaf")
        }
        try seal.revalidate()
        journalURL = provisionedJournalURL
        self.seal = seal
    }

    var isDescriptorBound: Bool { seal != nil }
    var retentionEpochID: String? { seal?.epochID }
    var genesisDigest: String? { seal?.genesisDigest }
    var ancestry: GuestRetentionAncestry? {
        guard let epochID = seal?.epochID, let genesisSHA256 = seal?.genesisDigest else { return nil }
        return GuestRetentionAncestry(epochID: epochID, genesisSHA256: genesisSHA256)
    }

    func revalidate(openedParentFD: Int32? = nil) throws {
        guard let seal else {
            throw GuestRetentionProvisionFailure("Retention grant has no held production root")
        }
        try seal.revalidate(openedParentFD: openedParentFD)
    }

    private static func validate(_ exactJournalURL: URL) throws {
        let encodedPath = URLComponents(url: exactJournalURL,
                                        resolvingAgainstBaseURL: false)?.percentEncodedPath
        let decodedPath = encodedPath?.removingPercentEncoding
        let path = exactJournalURL.path
        let components = path.split(separator: "/", omittingEmptySubsequences: false)
        guard exactJournalURL.isFileURL, exactJournalURL.baseURL == nil,
              let encodedPath, !encodedPath.isEmpty, let decodedPath,
              decodedPath.utf8.elementsEqual(path.utf8),
              exactJournalURL.host == nil || exactJournalURL.host == "",
              exactJournalURL.user == nil, exactJournalURL.password == nil,
              exactJournalURL.port == nil, exactJournalURL.query == nil,
              exactJournalURL.fragment == nil, path.hasPrefix("/"), path != "/",
              !decodedPath.contains("\0"), !decodedPath.contains("\\"),
              !path.contains("//"), !path.hasSuffix("/"),
              !components.contains("."), !components.contains(".."),
              !exactJournalURL.hasDirectoryPath else {
            throw ProvenanceFailure("Retention grant requires one explicit absolute local journal file URL")
        }
        // Inspect the encoded form first: Foundation URL.path can otherwise
        // lose a percent-encoded NUL. Decode exactly once and require its UTF-8
        // bytes to equal URL.path before applying the lexical path rules. No
        // standardization, realpath, existence check, ambient URL lookup, or
        // file opening takes place when a grant is constructed.
    }
}

/// Explicitly selected evidence only. A run ID by itself cannot discover data.
struct GuestSupervisorRetainedRun: Sendable {
    let runID: String
    let events: [GuestJournalEvent]
}

struct GuestHistoryReconstructionMetadata: Equatable, Sendable {
    let retentionAncestry: GuestRetentionAncestry
    let journalSHA256: String?
    let genesisOnly: Bool
}

/// Bounded immutable display delegation. The supervisor supplies exact event
/// bytes; the existing verifier reconstructs each label before the grant exists.
/// This type has no path, descriptor, query, or persistence/resumption operation.
struct GuestSupervisorHistoryGrant: Sendable {
    static let maximumRuns = 20
    let presentations: [GuestPresentation]
    let reconstruction: GuestHistoryReconstructionMetadata?

    #if EPR_GUEST_JOURNAL_TESTS
    /// Explicit fabricated-evidence seam. Production reconstruction always
    /// supplies and verifies the retained genesis ancestry.
    init(runs: [GuestSupervisorRetainedRun]) throws {
        try self.init(runs: runs, expectedRetention: nil, reconstruction: nil)
    }
    #endif

    fileprivate init(reconstructedRuns runs: [GuestSupervisorRetainedRun],
                     expectedRetention: GuestRetentionAncestry,
                     journalSHA256: String?, genesisOnly: Bool) throws {
        guard genesisOnly == (journalSHA256 == nil),
              journalSHA256.map(Self.validDigest) ?? true else {
            throw ProvenanceFailure("History reconstruction metadata is inconsistent")
        }
        try self.init(runs: runs, expectedRetention: expectedRetention,
            reconstruction: GuestHistoryReconstructionMetadata(
                retentionAncestry: expectedRetention, journalSHA256: journalSHA256,
                genesisOnly: genesisOnly))
    }

    private init(runs: [GuestSupervisorRetainedRun],
                 expectedRetention: GuestRetentionAncestry?,
                 reconstruction: GuestHistoryReconstructionMetadata?) throws {
        guard runs.count <= Self.maximumRuns,
              Set(runs.map(\.runID)).count == runs.count,
              runs.allSatisfy({ !$0.runID.isEmpty && $0.runID.utf8.count <= 128 && !$0.runID.contains("\0") }) else {
            throw ProvenanceFailure("History grant requires bounded distinct explicit run IDs")
        }
        presentations = try runs.map { run in
            let verified = try GuestResultVerifier.verify(runID: run.runID, events: run.events,
                expectedRetention: expectedRetention)
            return GuestPresentation(id: run.runID, status: verified.status, detail: verified.detail,
                root: verified.root, elapsed: verified.elapsed,
                events: run.events.map {
                    GuestEventDisplay(id: $0.sequence, kind: $0.kind, digest: $0.digest, byteCount: $0.payload.count)
                }, quarantined: verified.quarantined)
        }
        self.reconstruction = reconstruction
    }

    private static func validDigest(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy {
            (48...57).contains($0) || (97...102).contains($0)
        }
    }
}

/// Independent grants, fixed for one model lifetime. Admission and the native
/// reservation/lifetime checks remain separate mandatory gates. None is issued
/// automatically by application startup, a view, a path lookup, or an old receipt.
struct GuestSupervisorGrants: Sendable {
    let retention: GuestSupervisorRetentionGrant?
    let historyDisplay: GuestSupervisorHistoryGrant?

    init() {
        retention = nil
        historyDisplay = nil
    }

    init(retention: GuestSupervisorRetentionGrant) {
        self.retention = retention
        historyDisplay = nil
    }

    init(historyDisplay: GuestSupervisorHistoryGrant) {
        retention = nil
        self.historyDisplay = historyDisplay
    }

    static let none = GuestSupervisorGrants()
}
