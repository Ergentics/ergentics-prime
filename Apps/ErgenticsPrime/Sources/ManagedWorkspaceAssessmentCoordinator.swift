import AppKit
import CryptoKit
import Darwin
import Foundation
import UniformTypeIdentifiers

/// Owns one imported-snapshot assessment from lease admission through exact
/// worker return, coordinator-owned second-read postflight, resource release,
/// and final publication or discard. It never executes Git or accepts a command.
@MainActor
final class ManagedWorkspaceAssessmentCoordinator {
    enum Outcome: Equatable, Sendable {
        case completed(ManagedWorkspaceProductGUIPresentation)
        case rejected(ManagedWorkspaceGUIImportState.Rejection)
    }

    private enum WorkerFailure: Error, Equatable, Sendable {
        case cancelled
        case fileUnavailable
        case invalidSnapshot
        case changedDuringRead
        case projectionRejected
    }

    private final class ActiveOperation {
        let token: ManagedWorkspaceAssessmentLease.Token
        let grant: SnapshotReadGrant?
        let worker: Task<Result<ManagedWorkspaceProductGUIPresentation, WorkerFailure>, Never>

        init(token: ManagedWorkspaceAssessmentLease.Token, grant: SnapshotReadGrant?,
             worker: Task<Result<ManagedWorkspaceProductGUIPresentation, WorkerFailure>, Never>) {
            self.token = token
            self.grant = grant
            self.worker = worker
        }
    }

    /// One user-mediated selection. Its URL is not exposed by the typed
    /// production API, its initializer is confined to this file, and its
    /// payload can be consumed exactly once. Cancellation can be latched before
    /// assessment starts.
    @MainActor
    final class SnapshotSelection {
        private var selectedURL: URL?
        private var cancelled = false

        fileprivate init(selectedURL: URL) {
            self.selectedURL = selectedURL
        }

        fileprivate func requestCancellation() {
            cancelled = true
        }

        fileprivate func consume() -> (url: URL?, cancelled: Bool) {
            let result = (selectedURL, cancelled)
            selectedURL = nil
            return result
        }
    }

    #if EPR_MANAGED_WORKSPACE_TESTS
    struct TestHooks: Sendable {
        var beforeWorkerRead: (@Sendable () async -> Void)?
        var beforePostflight: (@Sendable () async -> Void)?
        var forcePostflightFailure = false
        var forceGrantAdmissionCleanupFailure = false

        init(beforeWorkerRead: (@Sendable () async -> Void)? = nil,
             beforePostflight: (@Sendable () async -> Void)? = nil,
             forcePostflightFailure: Bool = false,
             forceGrantAdmissionCleanupFailure: Bool = false) {
            self.beforeWorkerRead = beforeWorkerRead
            self.beforePostflight = beforePostflight
            self.forcePostflightFailure = forcePostflightFailure
            self.forceGrantAdmissionCleanupFailure = forceGrantAdmissionCleanupFailure
        }
    }
    #endif

    private struct Hooks: Sendable {
        let beforeWorkerRead: (@Sendable () async -> Void)?
        let beforePostflight: (@Sendable () async -> Void)?
        let forcePostflightFailure: Bool
        let forceGrantAdmissionCleanupFailure: Bool
    }

    private let lease = ManagedWorkspaceAssessmentLease()
    private let hooks: Hooks
    private var active: ActiveOperation?
    private var selectionInFlight = false
    private var pendingSelection: SnapshotSelection?
    private var quarantined = false

    #if EPR_MANAGED_WORKSPACE_TESTS
    private(set) var testSnapshotGrantConstructionAttempts = 0
    #endif

    init() {
        hooks = Hooks(beforeWorkerRead: nil, beforePostflight: nil,
                      forcePostflightFailure: false,
                      forceGrantAdmissionCleanupFailure: false)
    }

    #if EPR_MANAGED_WORKSPACE_TESTS
    init(testHooks: TestHooks) {
        hooks = Hooks(
            beforeWorkerRead: testHooks.beforeWorkerRead,
            beforePostflight: testHooks.beforePostflight,
            forcePostflightFailure: testHooks.forcePostflightFailure,
            forceGrantAdmissionCleanupFailure: testHooks.forceGrantAdmissionCleanupFailure
        )
    }
    #endif

    var activity: ManagedWorkspaceProductGUIPresentation.Activity {
        if quarantined { return .unavailable }
        return (try? ManagedWorkspaceProjector.productGUIActivity(leaseStatus: lease.status))
            ?? .unavailable
    }

    var canBegin: Bool {
        !quarantined && !selectionInFlight && pendingSelection == nil &&
        active == nil && !lease.isActive
    }

    /// The native panel is inside the authority owner. Callers receive only a
    /// one-use opaque value and cannot supply or inspect a path-shaped input.
    #if !EPR_MANAGED_WORKSPACE_TESTS
    func selectUserSnapshot(
        using _: ProvenanceReadOnlyImportAdmission
    ) -> SnapshotSelection? {
        reserveAndSelect {
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false
            panel.canCreateDirectories = false
            panel.resolvesAliases = false
            panel.allowedContentTypes = [.json]
            panel.message = "Open a local Prime snapshot. Only a minimized, producer-attributed presentation will reach the interface."
            panel.prompt = "Import read-only"
            guard panel.runModal() == .OK else { return nil }
            return panel.url
        }
    }
    #endif

    #if EPR_MANAGED_WORKSPACE_TESTS
    func testSelection(
        for url: URL,
        whileReserved: (() -> Void)? = nil
    ) -> SnapshotSelection? {
        reserveAndSelect {
            whileReserved?()
            return url
        }
    }

    func testCancelledSelection() -> SnapshotSelection? {
        reserveAndSelect { nil }
    }
    #endif

    private func reserveAndSelect(_ select: () -> URL?) -> SnapshotSelection? {
        guard canBegin else { return nil }
        selectionInFlight = true
        let selectedURL = select()
        let stillExclusive = selectionInFlight && !quarantined &&
            pendingSelection == nil && active == nil && !lease.isActive
        selectionInFlight = false
        guard stillExclusive, let selectedURL else { return nil }
        let selection = SnapshotSelection(selectedURL: selectedURL)
        pendingSelection = selection
        return selection
    }

    /// Requests cancellation of the one owned worker. The lease and descriptor
    /// remain held until that worker returns and postflight settles.
    func requestCancellation() {
        guard let active else {
            pendingSelection?.requestCancellation()
            return
        }
        do {
            try lease.requestCancellation(active.token)
            active.worker.cancel()
        } catch ManagedWorkspaceAssessmentLease.LeaseError.invalidPhase {
            // The worker-return boundary already won. Cleanup continues there.
        } catch ManagedWorkspaceAssessmentLease.LeaseError.staleToken {
            quarantine()
        } catch {
            quarantine()
        }
    }

    func assess(
        selection: SnapshotSelection,
        activityChanged: @escaping @MainActor
            (ManagedWorkspaceProductGUIPresentation.Activity) -> Void
    ) async -> Outcome {
        guard pendingSelection === selection else {
            return .rejected(.assessmentUnavailable)
        }
        pendingSelection = nil
        let claim = selection.consume()
        guard !claim.cancelled, !Task.isCancelled else {
            return .rejected(.cancelled)
        }
        guard let selectedURL = claim.url,
              !quarantined, active == nil, !lease.isActive else {
            return .rejected(.assessmentUnavailable)
        }

        let token: ManagedWorkspaceAssessmentLease.Token
        do {
            token = try lease.begin(workspaceID: .prime)
        } catch {
            quarantine()
            activityChanged(.unavailable)
            return .rejected(.assessmentUnavailable)
        }

        #if EPR_MANAGED_WORKSPACE_TESTS
        testSnapshotGrantConstructionAttempts += 1
        #endif
        let grant: SnapshotReadGrant?
        let grantAdmissionCleanupConserved: Bool
        do {
            grant = try SnapshotReadGrant(
                selectedURL: selectedURL,
                forceAdmissionCleanupFailure: hooks.forceGrantAdmissionCleanupFailure
            )
            grantAdmissionCleanupConserved = true
        } catch SnapshotReadGrant.ReadFailure.cleanupUncertain {
            grant = nil
            grantAdmissionCleanupConserved = false
        } catch {
            grant = nil
            grantAdmissionCleanupConserved = true
        }
        let reader = grant?.reader
        let hooks = self.hooks
        let worker = Task.detached(priority: .userInitiated) {
            guard let reader else {
                return Result<ManagedWorkspaceProductGUIPresentation, WorkerFailure>
                    .failure(.fileUnavailable)
            }
            if let beforeWorkerRead = hooks.beforeWorkerRead {
                await beforeWorkerRead()
            }
            return Self.runWorker(reader: reader)
        }
        active = ActiveOperation(token: token, grant: grant, worker: worker)
        activityChanged(activity)

        let result = await withTaskCancellationHandler {
            await worker.value
        } onCancel: {
            worker.cancel()
        }

        if Task.isCancelled {
            requestCancellation()
        }

        let returned: ManagedWorkspaceAssessmentLease.WorkerReturnWitness
        do {
            returned = try lease.recordWorkerReturned(token)
        } catch {
            _ = await releaseWithoutPostflight(grant)
            active = nil
            quarantine()
            activityChanged(.unavailable)
            return .rejected(.assessmentUnavailable)
        }
        activityChanged(activity)

        if let beforePostflight = hooks.beforePostflight {
            await beforePostflight()
        }
        let workerProducedPresentation: Bool
        if case .success = result { workerProducedPresentation = true }
        else { workerProducedPresentation = false }
        let postflightPassed = await Task.detached(priority: .userInitiated) {
            guard let grant else { return true }
            return grant.postflightAndRelease(requireDigest: workerProducedPresentation)
        }.value && !hooks.forcePostflightFailure

        let cancelled = lease.cancellationRequested || Task.isCancelled || {
            if case .failure(.cancelled) = result { return true }
            return false
        }()
        let completed: Bool
        if case .success = result {
            completed = postflightPassed && !cancelled
        } else {
            completed = false
        }

        do {
            let settled = try lease.recordPostflightSettled(
                returned, disposition: completed ? .completed : .abandoned
            )
            try lease.release(settled)
        } catch {
            active = nil
            quarantine()
            activityChanged(.unavailable)
            return .rejected(.assessmentUnavailable)
        }
        active = nil

        guard grantAdmissionCleanupConserved else {
            quarantine()
            activityChanged(.unavailable)
            return .rejected(.assessmentUnavailable)
        }
        guard postflightPassed else {
            quarantine()
            activityChanged(.unavailable)
            return .rejected(.changedDuringRead)
        }
        activityChanged(.idle)
        if cancelled { return .rejected(.cancelled) }
        switch result {
        case .success(let presentation):
            return .completed(presentation)
        case .failure(let failure):
            return .rejected(Self.rejection(for: failure))
        }
    }

    private func quarantine() { quarantined = true }

    private func releaseWithoutPostflight(_ grant: SnapshotReadGrant?) async -> Bool {
        await Task.detached(priority: .userInitiated) {
            grant?.releaseResources() ?? true
        }.value
    }

    nonisolated private static func runWorker(
        reader: SnapshotReadGrant.Reader
    ) -> Result<ManagedWorkspaceProductGUIPresentation, WorkerFailure> {
        do {
            let bytes = try reader.readAndRememberDigest(checkCancellation: true)
            let observation = try ManagedWorkspaceObservationParser.primeSnapshot(bytes)
            let presentation = try ManagedWorkspaceProjector.productGUIAndAccessibility(
                observation: observation,
                leaseStatus: ManagedWorkspaceAssessmentLease.Status(
                    phase: .idle, workspaceID: nil, generation: nil
                )
            )
            return .success(presentation)
        } catch is CancellationError {
            return .failure(.cancelled)
        } catch SnapshotReadGrant.ReadFailure.changed {
            return .failure(.changedDuringRead)
        } catch is PrimeGitSnapshotError {
            return .failure(.invalidSnapshot)
        } catch is ManagedWorkspaceObservationError {
            return .failure(.invalidSnapshot)
        } catch is ManagedWorkspaceProjectionError {
            return .failure(.projectionRejected)
        } catch {
            return .failure(.fileUnavailable)
        }
    }

    nonisolated private static func rejection(
        for failure: WorkerFailure
    ) -> ManagedWorkspaceGUIImportState.Rejection {
        switch failure {
        case .cancelled: return .cancelled
        case .fileUnavailable: return .fileUnavailable
        case .invalidSnapshot: return .invalidSnapshot
        case .changedDuringRead: return .changedDuringRead
        case .projectionRejected: return .projectionRejected
        }
    }
}

/// Opaque read grant retained by the coordinator. Its named path and content
/// identity never cross into the worker result or product presentation.
private final class SnapshotReadGrant: @unchecked Sendable {
    enum ReadFailure: Error { case unavailable, changed, cleanupUncertain }

    struct Reader: Sendable {
        fileprivate let descriptor: Int32
        fileprivate let expectedCount: Int
        fileprivate let digest: DigestBox

        fileprivate func readAndRememberDigest(checkCancellation: Bool) throws -> Data {
            let bytes = try SnapshotReadGrant.readExactly(
                descriptor: descriptor,
                expectedCount: expectedCount,
                checkCancellation: checkCancellation
            )
            digest.store(Data(SHA256.hash(data: bytes)))
            return bytes
        }
    }

    private struct FileIdentity: Equatable, Sendable {
        let device: UInt64
        let inode: UInt64
        let mode: UInt32
        let size: Int64
        let links: UInt64
        let owner: UInt32
        let group: UInt32
        let modifiedSeconds: Int64
        let modifiedNanoseconds: Int64
        let changedSeconds: Int64
        let changedNanoseconds: Int64

        init(_ value: stat) {
            device = UInt64(value.st_dev)
            inode = UInt64(value.st_ino)
            mode = UInt32(value.st_mode)
            size = value.st_size
            links = UInt64(value.st_nlink)
            owner = value.st_uid
            group = value.st_gid
            modifiedSeconds = Int64(value.st_mtimespec.tv_sec)
            modifiedNanoseconds = Int64(value.st_mtimespec.tv_nsec)
            changedSeconds = Int64(value.st_ctimespec.tv_sec)
            changedNanoseconds = Int64(value.st_ctimespec.tv_nsec)
        }
    }

    fileprivate final class DigestBox: @unchecked Sendable {
        private let lock = NSLock()
        private var value: Data?

        func store(_ value: Data) {
            lock.lock()
            defer { lock.unlock() }
            self.value = value
        }

        func matches(_ candidate: Data, required: Bool) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            guard let value else { return !required }
            return value == candidate
        }
    }

    private let lock = NSLock()
    private let selectedURL: URL
    private let namedPath: String
    private let descriptor: Int32
    private let admittedIdentity: FileIdentity
    private let scoped: Bool
    private let digest = DigestBox()
    private var released = false

    var reader: Reader {
        Reader(descriptor: descriptor, expectedCount: Int(admittedIdentity.size), digest: digest)
    }

    init(selectedURL: URL, forceAdmissionCleanupFailure: Bool = false) throws {
        let path = selectedURL.path
        guard !path.isEmpty, !path.utf8.contains(0) else { throw ReadFailure.unavailable }
        let scoped = selectedURL.startAccessingSecurityScopedResource()
        let descriptor = path.withCString {
            Darwin.open($0, O_RDONLY | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK)
        }
        guard descriptor >= 0 else {
            if scoped { selectedURL.stopAccessingSecurityScopedResource() }
            throw ReadFailure.unavailable
        }
        var held = stat()
        var named = stat()
        let admitted = fstat(descriptor, &held) == 0 &&
            path.withCString({ lstat($0, &named) }) == 0 &&
            held.st_mode & S_IFMT == S_IFREG && held.st_size > 0 &&
            held.st_size <= PrimeGitSnapshot.maximumJSONBytes &&
            FileIdentity(held) == FileIdentity(named) &&
            !forceAdmissionCleanupFailure
        guard admitted else {
            let closed = Darwin.close(descriptor) == 0
            if scoped { selectedURL.stopAccessingSecurityScopedResource() }
            guard closed, !forceAdmissionCleanupFailure else {
                throw ReadFailure.cleanupUncertain
            }
            throw ReadFailure.unavailable
        }
        self.selectedURL = selectedURL
        namedPath = path
        self.descriptor = descriptor
        admittedIdentity = FileIdentity(held)
        self.scoped = scoped
    }

    deinit { _ = releaseResources() }

    func postflightAndRelease(requireDigest: Bool) -> Bool {
        let contentAndIdentityJoined: Bool
        do {
            let bytes = try Self.readExactly(
                descriptor: descriptor,
                expectedCount: Int(admittedIdentity.size),
                checkCancellation: false
            )
            var heldBefore = stat()
            var named = stat()
            var heldAfter = stat()
            contentAndIdentityJoined =
                fstat(descriptor, &heldBefore) == 0 &&
                namedPath.withCString({ lstat($0, &named) }) == 0 &&
                fstat(descriptor, &heldAfter) == 0 &&
                FileIdentity(heldBefore) == admittedIdentity &&
                FileIdentity(named) == admittedIdentity &&
                FileIdentity(heldAfter) == admittedIdentity &&
                digest.matches(Data(SHA256.hash(data: bytes)), required: requireDigest)
        } catch {
            contentAndIdentityJoined = false
        }
        return releaseResources() && contentAndIdentityJoined
    }

    @discardableResult
    func releaseResources() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard !released else { return true }
        released = true
        let closed = Darwin.close(descriptor) == 0
        if scoped { selectedURL.stopAccessingSecurityScopedResource() }
        return closed
    }

    private static func readExactly(
        descriptor: Int32,
        expectedCount: Int,
        checkCancellation: Bool
    ) throws -> Data {
        var bytes = Data()
        bytes.reserveCapacity(expectedCount)
        var buffer = [UInt8](repeating: 0, count: 16_384)
        var offset = 0
        var interruptedReads = 0
        let maximumInterruptedReads = 8
        while offset < expectedCount {
            if checkCancellation { try Task.checkCancellation() }
            let requestCount = min(buffer.count, expectedCount - offset)
            let count = buffer.withUnsafeMutableBytes {
                Darwin.pread(descriptor, $0.baseAddress, requestCount, off_t(offset))
            }
            if count < 0 {
                if errno == EINTR {
                    interruptedReads += 1
                    guard interruptedReads <= maximumInterruptedReads else {
                        throw ReadFailure.unavailable
                    }
                    continue
                }
                throw ReadFailure.unavailable
            }
            guard count > 0 else { throw ReadFailure.changed }
            bytes.append(contentsOf: buffer.prefix(count))
            offset += count
        }
        var extra: UInt8 = 0
        while true {
            if checkCancellation { try Task.checkCancellation() }
            let extraCount = Darwin.pread(descriptor, &extra, 1, off_t(expectedCount))
            if extraCount < 0, errno == EINTR {
                interruptedReads += 1
                guard interruptedReads <= maximumInterruptedReads else {
                    throw ReadFailure.unavailable
                }
                continue
            }
            guard extraCount == 0 else { throw ReadFailure.changed }
            break
        }
        return bytes
    }
}
