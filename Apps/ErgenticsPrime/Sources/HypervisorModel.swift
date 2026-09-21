import AppKit
import Combine
import Darwin
import Foundation

/// Swift lifetime bridges one retained native reservation. Requests before the
/// worker acquires its native token remain sticky; no raw pointer escapes this
/// owner except during a call made while this owner is strongly retained.
private final class GuestRunReservation: @unchecked Sendable {
    private let lock = NSLock()
    private var token: OpaquePointer?
    private var requested = false
    private let policy: H3QualificationReservationStateMachine.Policy
    private var state: H3QualificationReservationStateMachine
    private let productChecked: Bool
    private var productReleaseCompleted = false

    init(policy: H3QualificationReservationStateMachine.Policy = .ordinaryDeinit,
         productChecked: Bool = false) {
        self.productChecked = productChecked
        self.policy = productChecked ? .qualificationChecked : policy
        state = H3QualificationReservationStateMachine(policy: self.policy)
    }

    func prepare() throws {
        try checkCancellation()
        var error: Int32 = 0
        let owned = epr_guest_reserve(&error)
        lock.lock()
        token = owned
        do { try state.recordReserve(tokenPresent: owned != nil, error: error) }
        catch { lock.unlock(); throw error }
        let acquired = state.state == .acquired
        let canceled = requested
        lock.unlock()
        guard let owned, acquired else {
            throw ProvenanceFailure("Native run reservation rejected (\(error))")
        }
        if canceled { epr_guest_reservation_request_cancel(owned) }
        try checkCancellation()
    }

    func checkCancellation() throws {
        lock.lock(); let canceled = requested; lock.unlock()
        if canceled { throw CancellationError() }
    }

    func requestCancellation() {
        lock.lock()
        requested = true
        if productChecked {
            // Keep the atomic write inside the token lock so cancellation
            // cannot retain a pointer across the checked-release boundary.
            if state.state == .acquired, !productReleaseCompleted, let token {
                epr_guest_reservation_request_cancel(token)
            }
            lock.unlock()
            return
        }
        #if EPR_H3_QUALIFICATION
        let owned = H3QualificationCancellationEventPolicy.mayStartHelper(policy: policy,
            state: state.state, tokenPresent: token != nil) ? token : nil
        #else
        let owned = policy == .ordinaryDeinit || state.state == .acquired ? token : nil
        #endif
        lock.unlock()
        guard let owned else { return }
        // Atomic flag only: never wait on an HV call on the UI thread.
        epr_guest_reservation_request_cancel(owned)
        Thread.detachNewThread { [self] in
            // This closure retains the reservation through the native call.
            lock.lock(); let held = token; lock.unlock()
            if let held { _ = epr_guest_reservation_cancel(held) }
        }
    }

    func releaseForProduct() -> Int32 {
        lock.lock(); defer { lock.unlock() }
        guard productChecked else { return EINVAL }
        return GuestProductReservationRelease.finish(state: &state, token: &token,
            completed: &productReleaseCompleted, release: epr_guest_reservation_release)
    }

    func runBaseline() -> EPRGuestResult {
        lock.lock(); let owned = token; lock.unlock()
        return epr_guest_run_reserved(owned)
    }

    func runRust() -> EPRRustGuestResult {
        lock.lock(); let owned = token; lock.unlock()
        return epr_rust_guest_run_reserved(owned)
    }

    func runH3CursorResume() -> EPRGuestH3CursorResumeResult {
        lock.lock(); let owned = token; lock.unlock()
        return epr_guest_h3_cursor_resume_run_reserved(owned)
    }

    func runH3WithPersistenceHandoff() -> GuestH3LivePersistence.Completion {
        lock.lock(); let owned = token; lock.unlock()
        return GuestH3LivePersistence.runReserved(owned)
    }

    #if EPR_H3_QUALIFICATION
    func qualificationState() -> H3QualificationReservationStateMachine {
        lock.lock(); defer { lock.unlock() }
        return state
    }

    func releaseChecked() throws -> H3QualificationReservationStateMachine {
        lock.lock(); defer { lock.unlock() }
        switch try state.beginCheckedRelease(tokenPresent: token != nil) {
        case .noCall: return state
        case .callToken:
            guard let owned = token else { throw H3QualificationFailure.invariant("missing release token") }
            token = nil
            let status = epr_guest_reservation_release(owned)
            try state.finishCheckedRelease(status: status)
            return state
        }
    }
    #endif

    deinit {
        if let decision = try? state.deinitDecision(tokenPresent: token != nil),
           decision == .callToken, let token { _ = epr_guest_reservation_release(token) }
    }
}

/// H5/H7 deadline and reservations with checked release before reuse.
/// Cancellation only sets the native atomic flag; the existing native
/// watchdog and application Stop fallback bound an in-flight HV interval.
private final class GuestCheckpointDeadline: @unchecked Sendable {
    private let item: DispatchWorkItem
    init(controller: AppLifecycleController, identity: UUID, seconds: Int = HypervisorStageH5Repeat.workSeconds) {
        item = DispatchWorkItem { controller.requestStop(for: identity) }
        DispatchQueue.global(qos: .userInitiated).asyncAfter(
            deadline: .now() + .seconds(seconds), execute: item)
    }
    func cancel() { item.cancel() }
}

private final class GuestCheckpointNativeOwner: @unchecked Sendable {
    private let lock = NSLock()
    private var token: OpaquePointer?
    private var canceled = false
    // A failed release is retained without retry or deinit cleanup.
    private var retainedFailedToken: OpaquePointer?

    func cancel() {
        lock.lock(); defer { lock.unlock() }
        canceled = true
        if let token { epr_guest_reservation_request_cancel(token) }
    }

    func attempt() -> GuestH5RepeatWorker.Attempt {
        lock.lock(); let allowed = !canceled && retainedFailedToken == nil; lock.unlock()
        guard allowed else { return .init(native: nil, released: true) }
        var error: Int32 = 0
        guard let owned = epr_guest_reserve(&error) else { return .init(native: nil, released: true) }
        lock.lock()
        token = owned
        if canceled { epr_guest_reservation_request_cancel(owned) }
        lock.unlock()
        let native = epr_guest_h3_cursor_resume_run_reserved(owned)
        // Clear the cancellation target under the same lock before release.
        // No cancellation callback can retain a pointer past this boundary.
        lock.lock(); token = nil; lock.unlock()
        let released = epr_guest_reservation_release(owned) == 0
        if !released { lock.lock(); retainedFailedToken = owned; lock.unlock() }
        return .init(native: native, released: released)
    }
}


// Owned only by the dedicated Rust worker thread. No journal, descriptor or
// native resource handle crosses into the completion; the typed return is
// retained before any throwing work and is never serialized as struct bytes.
private final class RustBootCapture {
    var nativeDisposition: DevelopmentRustNativeDisposition = .notEntered
    private var nativeReturn: EPRRustGuestResult?
    var rawFields: [String: GuestCBORValue] = [:]
    var events: [GuestJournalEvent] = []
    var journalVerified = false
    var journalRetainsAllEvidence = false

    func returned(_ value: EPRRustGuestResult) {
        nativeReturn = value
        nativeDisposition = value.base.teardown_pass == 1 && value.base.resources_quarantined == 0
            ? .returnedConserved : .returnedUnconserved
    }

    func completion(runID: String, presentation: GuestPresentation,
                    completedTicks: UInt64) -> DevelopmentRustBootCompletion {
        DevelopmentRustBootCompletion(runID: runID, nativeDisposition: nativeDisposition,
            rawFields: rawFields, events: events, journalVerified: journalVerified,
            journalRetainsAllEvidence: journalRetainsAllEvidence, status: presentation.status,
            detail: presentation.detail, journalCompletedTicks: completedTicks)
    }
}

#if EPR_H3_QUALIFICATION
private struct H3QualificationWorkerValue: Sendable {
    let outcome: H3QualificationWorkerOutcome
    let presentation: GuestH3Presentation?
    let events: H3QualificationExecutionEventStateMachine
}
#endif

@MainActor
final class HypervisorModel: ObservableObject {
    /// The ordinary app installs a MainActor check before any native run claims busy.
    /// Qualification keeps its existing isolated admission path.
    var nativeRunAdmission: @MainActor () -> Bool = { true }
    @Published private(set) var busy = false
    @Published private(set) var phase: String
    @Published private(set) var result: GuestPresentation?
    @Published private(set) var recent: [GuestPresentation] = []
    @Published private(set) var error: String?
    @Published private(set) var quarantined = false
    @Published private(set) var retentionProvisioning = false
    @Published private(set) var historyReconstructing = false
    @Published private(set) var h3Running = false
    @Published private(set) var h3Result: GuestH3Presentation?
    @Published private(set) var h5Running = false
    @Published private(set) var h5Result: GuestH5RepeatWorker.Outcome?
    @Published private(set) var h7Running = false
    @Published private(set) var h7Result: GuestH7Execution.Presentation?
    @Published private(set) var h7Attempted = false
    @Published private(set) var h8Saving = false
    @Published private(set) var h8Saved: GuestH8Provenance.Saved?
    @Published private(set) var h8Opening = false
    @Published private(set) var h8Opened: GuestH8Provenance.Snapshot?
    @Published private(set) var h8ReadStatus = "No saved-file read grant"
    private var h8Pending: GuestH8Provenance.Pending?
    private var h8ReadGrant: GuestH8Provenance.ReadGrant?
    private var h5Attempted = false
    private var checkpointNativeOwner: GuestCheckpointNativeOwner?
    @Published private(set) var h4Result: GuestH3LivePersistence.Presentation?
    @Published private(set) var h4Saving = false
    @Published private(set) var h4Opening = false
    @Published private(set) var h4Opened: GuestH4SavedReceipt.Snapshot?
    @Published private(set) var h4OpenError: String?
    private var h4HistoryMode = false
    private var h4Handoff: GuestH3LivePersistence.Handoff?
    private var h4Deadline: DispatchWorkItem?
    private var grants: GuestSupervisorGrants
    private var storageTransition: GuestStorageTransition
    private var startupHandled = false
    private enum LifecycleStorage {
        case ordinary(AppLifecycleController)
        #if EPR_H3_QUALIFICATION
        case qualificationPending(H3QualificationTerminalOwner)
        case qualificationInstalled(H3QualificationTerminalOwner, UInt32, UInt32, AppLifecycleController)
        #endif
    }
    private var lifecycleStorage: LifecycleStorage
    var lifecycle: AppLifecycleController {
        switch lifecycleStorage {
        case .ordinary(let value): return value
        #if EPR_H3_QUALIFICATION
        case .qualificationPending(let owner): owner.terminate(70)
        case .qualificationInstalled(_, _, _, let value): return value
        #endif
        }
    }
    private var currentRun: UUID?
    private var reservation: GuestRunReservation?
    private var stopRequested = false
    private var h3Attempted = false
    private enum FixedGuest: Sendable { case baseline, rustBootstrap }
    #if DEBUG
    private var developmentRustBootHandled = false
    @Published private(set) var developmentBootRunID: String?
    var developmentStartupHandled: Bool { startupHandled }
    #endif

    init() {
        lifecycleStorage = .ordinary(AppLifecycleController.live {
            Task { @MainActor in NSApplication.shared.terminate(nil) }
        })
        grants = .none
        storageTransition = GuestStorageTransition()
        phase = "Choose H3 in-memory execution, H2 with a private journal, or read-only history"
    }

    #if EPR_H3_QUALIFICATION
    private(set) var qualificationEventSnapshot: H3QualificationExecutionEventStateMachine?

    init(qualificationTerminalOwner: H3QualificationTerminalOwner) {
        lifecycleStorage = .qualificationPending(qualificationTerminalOwner)
        grants = .none
        storageTransition = GuestStorageTransition()
        phase = "Qualification pending identity gate"
    }

    func installQualificationLifecycle(timebaseNumerator numerator: UInt32, timebaseDenominator denominator: UInt32,
                                       terminalOwner: H3QualificationTerminalOwner) throws -> AppLifecycleController {
        guard case .qualificationPending(let expected) = lifecycleStorage,
              expected === terminalOwner, numerator > 0, denominator > 0 else {
            throw H3QualificationFailure.invariant("qualification lifecycle installation")
        }
        let value = AppLifecycleController(timebaseNumerator: numerator, timebaseDenominator: denominator,
            clock: { mach_continuous_time() }, forceExit: { terminalOwner.terminate(70) },
            normalExit: { terminalOwner.terminate(70) })
        lifecycleStorage = .qualificationInstalled(terminalOwner, numerator, denominator, value)
        return value
    }
    #endif

    var retentionGranted: Bool { grants.retention?.isDescriptorBound == true }
    var canProvisionRetention: Bool {
        !h4HistoryMode && !h3Attempted && !retentionGranted && !historyDisplayGranted && storageTransition.canBegin &&
            !h4Opening && !h8Opening && !retentionProvisioning && !historyReconstructing && !busy && !quarantined
    }
    var canReconstructHistory: Bool {
        !h4HistoryMode && !h3Attempted && !retentionGranted && !historyDisplayGranted && storageTransition.canBegin &&
            !h4Opening && !h8Opening && !retentionProvisioning && !historyReconstructing && !busy && !quarantined
    }
    var canRunH3CursorResume: Bool {
        nativeRunAdmission() && !h4HistoryMode && !h3Attempted && !retentionGranted && !historyDisplayGranted && storageTransition.canBegin &&
            !h4Opening && !h8Opening && !retentionProvisioning && !historyReconstructing && !busy && !quarantined
    }
    var canSaveH8: Bool { h8Pending != nil && !busy && !h8Saving && !quarantined }
    var canOpenH8: Bool {
        !busy && !h8Opening && !h4Opening && !retentionProvisioning && !historyReconstructing &&
        !retentionGranted && !historyDisplayGranted && !storageTransition.attempted && !quarantined &&
        (!h3Attempted || (h7Attempted && h8Saved?.durable == true))
    }
    var historyDisplayGranted: Bool { grants.historyDisplay != nil }
    var canSaveH4Receipt: Bool { h4Handoff != nil && !busy && !h4Saving && !h4Opening && !h8Opening && !quarantined }
    var canOpenH4Receipt: Bool {
        !h7Attempted && !h5Attempted && !busy && !h4Opening && !h8Opening && !retentionProvisioning && !historyReconstructing && !quarantined &&
        !retentionGranted && !historyDisplayGranted && !storageTransition.attempted &&
        (!h3Attempted || h4Result?.durable == true)
    }
    var h3ModeStatus: String {
        if h7Attempted { return "H7 owns this launch. Relaunch to select another run or storage mode." }
        if h5Attempted { return "H5 owns this launch's three-run batch. Relaunch to select a single H3 run or storage." }
        if h4HistoryMode { return "Saved-evidence inspection. No guest runs or Save capabilities are restored. Relaunch to run a checkpoint." }
        if h3Running { return "H3 is running two bounded native intervals; no journal is open." }
        if h3Attempted {
            return "H3's one attempt is complete or consumed. H4 below reports whether it was saved. Quit discards the in-memory view, not a saved file; no automatic rerun."
        }
        if retentionGranted || historyDisplayGranted || storageTransition.attempted {
            return "H3 is unavailable in this launch because a storage mode was selected. Relaunch to run H3 in memory; retained evidence is not removed."
        }
        return "H3 needs no journal. One explicit run checkpoints 42 and resumes to 43 in a fresh VM/vCPU. Selecting H3 excludes H2 and history for this launch."
    }
    var retentionStatus: String {
        if h4HistoryMode { return "H2 is unavailable while inspecting saved evidence. Relaunch to use its private journal." }
        if let retention = grants.retention, retention.isDescriptorBound {
            return "Private journal capability bound to epoch \(retention.retentionEpochID ?? "test-seam") · genesis \(retention.genesisDigest ?? "unbound")."
        }
        if retentionProvisioning { return "Provisioning one fresh private journal root; no VM has entered." }
        if historyReconstructing { return "Reconstructing the fixed private journal read-only; no VM or retention authority is active." }
        if h3Attempted {
            return "H2 is unavailable after selecting a checkpoint execution mode. No private journal was opened or changed. Relaunch to choose H2 or read-only history."
        }
        if storageTransition.attempted {
            return "This launch's one storage transition is closed. Existing or partial evidence remains retained; no fallback or retry is available."
        }
        return "H2 needs an explicitly created private journal. No default journal is discovered or created. H3 remains a separate in-memory option."
    }
    var historyDisplayStatus: String {
        guard let history = grants.historyDisplay else {
            return "No history-display grant. No retained runs are discovered, opened, or enumerated."
        }
        if let metadata = history.reconstruction {
            if metadata.genesisOnly {
                return "Verified genesis \(metadata.retentionAncestry.epochID); no main database was present at the bounded snapshot. Historical run existence remains ABSTAIN."
            }
            return "Immutable verified history from epoch \(metadata.retentionAncestry.epochID) · journal \(metadata.journalSHA256 ?? "invalid"). No retention or execution authority was restored."
        }
        return "Only the supervisor's fixed verified history snapshot is available. No journal is opened by this view."
    }

    /// One explicit campaign is one application lifecycle operation. No
    /// intermediate H3 completion reopens the ordinary one-run gate.
    func runH5Repeat(admitted: Bool) {
        guard admitted, canRunH3CursorResume else { return }
        h3Attempted = true
        h5Attempted = true
        let identity = UUID()
        let worker = GuestH5RepeatWorker(epoch: identity)
        let native = GuestCheckpointNativeOwner()
        do { try lifecycle.beginRun(identity, cancel: { worker.cancel(); native.cancel() }) }
        catch { phase = "H5 batch was not admitted"; self.error = String(describing: error); return }
        currentRun = identity
        checkpointNativeOwner = native
        stopRequested = false
        busy = true
        h5Running = true
        error = nil
        phase = "H5 running three sequential checkpoint/resume pairs and comparing verified state"
        let deadline = GuestCheckpointDeadline(controller: lifecycle, identity: identity)
        Thread.detachNewThread { [weak self] in
            let outcome = worker.run { native.attempt() }
            deadline.cancel()
            Task { @MainActor [weak self] in
                guard let self, self.currentRun == identity else { return }
                self.busy = false
                self.h5Running = false
                self.currentRun = nil
                let canceledBeforeDisplay = self.stopRequested && outcome.summary != nil
                self.h5Result = canceledBeforeDisplay ? .init(attempted: outcome.attempted,
                    observations: outcome.observations, summary: nil, failure: .canceled,
                    quarantined: outcome.quarantined) : outcome
                self.quarantined = outcome.quarantined
                self.phase = self.h5Result?.summary != nil
                    ? "H5 PASS · THREE LOCAL RESUME RUNS MATCH"
                    : "H5 INCOMPLETE · \(self.h5Result?.failure?.rawValue ?? "rejected")"
                self.lifecycle.complete(identity, completion: outcome.quarantined ? .quarantined : .recoveryVolatile)
            }
        }
    }

    /// The UI supplies no namespace, receipt, operand or destination claim.
    /// A fresh supervisor context gates preparation and both screen sinks.
    func runH7Checkpoint(admitted: Bool) {
        guard admitted, canRunH3CursorResume else { return }
        h3Attempted = true
        h7Attempted = true
        let context = GuestH7Execution.Context()
        let identity = context.request.epoch
        let native = GuestCheckpointNativeOwner()
        do { try lifecycle.beginRun(identity, cancel: { context.cancel(); native.cancel() }) }
        catch { phase = "H7 unavailable"; return }
        currentRun = identity
        checkpointNativeOwner = native
        stopRequested = false
        busy = true
        h7Running = true
        error = nil
        phase = "H7 running the bounded checkpoint function"
        let deadline = GuestCheckpointDeadline(controller: lifecycle, identity: identity,
            seconds: GuestH7Execution.workSeconds)
        Thread.detachNewThread { [weak self] in
            let completion = context.run(context.request) { input in
                // The existing native function is pinned to these operands.
                guard input.left == 19, input.right == 23, input.increment == 1 else {
                    return GuestCheckpointAttempt(native: nil, released: true)
                }
                return native.attempt()
            }
            deadline.cancel()
            Task { @MainActor [weak self] in
                guard let self, self.currentRun == identity else { context.cancel(); return }
                let gui = context.take(.gui, request: context.request)
                let accessibility = context.take(.accessibility, request: context.request)
                self.h7Result = !self.stopRequested && gui == accessibility ? gui : nil
                self.h8Pending = self.h7Result != nil ? context.takePendingSave() : nil
                context.cancel()
                self.busy = false
                self.h7Running = false
                self.currentRun = nil
                self.quarantined = completion.quarantined
                self.phase = self.h7Result != nil ? "H7 PASS · BOUNDED CHECKPOINT VERIFIED" : "H7 unavailable"
                self.lifecycle.complete(identity, completion: completion.lifecycleCompletion(hasPendingSave: self.h8Pending != nil))
            }
        }
    }

    func saveH8Provenance(admitted: Bool) {
        guard admitted, canSaveH8, let pending = h8Pending else { return }
        h8Pending = nil
        let identity = UUID(), controller = lifecycle
        do { try controller.beginPersistence(identity, cancel: { pending.cancel() }) }
        catch { pending.cancel(); phase = "H8 save unavailable"; return }
        currentRun = identity; busy = true; h8Saving = true
        phase = "Saving H8 provenance and verifying read-back"
        let deadline = GuestCheckpointDeadline(controller: controller, identity: identity, seconds: 10)
        Thread.detachNewThread { [weak self] in
            let saved = pending.persist(); deadline.cancel()
            Task { @MainActor [weak self] in
                guard let self, self.currentRun == identity else { return }
                self.currentRun = nil; self.busy = false; self.h8Saving = false
                self.h8Saved = saved
                self.phase = saved.durable ? "H8 SAVED · LINEAGE VERIFIED" : "H8 save incomplete · any created evidence preserved"
                controller.complete(identity, completion: saved.durable ? .conserved : .recoveryVolatile)
            }
        }
    }

    func openH8Provenance(admitted: Bool) {
        guard admitted, canOpenH8 else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = true; panel.canChooseDirectories = false; panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false; panel.resolvesAliases = false
        panel.message = "Select one saved H8 provenance file. Opens a 60-second read grant; no execution or trusted egress."
        panel.prompt = "Inspect read-only"
        h8Opening = true
        panel.begin { [weak self] response in
            guard let self else { return }
            self.h8Opening = false
            guard response == .OK, let url = panel.url, self.canOpenH8 else { return }
            self.readSelectedH8(url)
        }
    }

    private func readSelectedH8(_ url: URL) {
        revokeH8Read(); h4HistoryMode = true; h4Opened = nil; h4OpenError = nil
        let identity = UUID(), budget = GuestH4SavedReceipt.Budget(), controller = lifecycle
        do { try controller.beginInspection(identity, cancel: { budget.cancel() }) }
        catch { h8ReadStatus = "Read grant unavailable"; return }
        currentRun = identity; busy = true; h8Opening = true
        h8ReadStatus = "Verifying selected provenance and complete lineage"
        let deadline = GuestCheckpointDeadline(controller: controller, identity: identity, seconds: 10)
        Thread.detachNewThread { [weak self] in
            let snapshot: GuestH8Provenance.Snapshot?
            let scoped = url.startAccessingSecurityScopedResource()
            snapshot = try? HypervisorStageH4DualStreamPersistence.readH8File(url, budget: budget)
            if scoped { url.stopAccessingSecurityScopedResource() }
            deadline.cancel()
            Task { @MainActor [weak self] in
                guard let self, self.currentRun == identity else { return }
                self.currentRun = nil; self.busy = false; self.h8Opening = false
                if let snapshot, (try? budget.check()) != nil {
                    let grant = GuestH8Provenance.ReadGrant(snapshot: snapshot)
                    self.h8ReadGrant = grant
                    let gui = grant.take(.gui, id: grant.id)
                    let accessibility = grant.take(.accessibility, id: grant.id)
                    self.h8Opened = gui == accessibility ? gui : nil
                    self.h8ReadStatus = "READ GRANT ACTIVE · expires in 60 seconds"
                    let grantID = grant.id
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(GuestH8Provenance.readSeconds)) { [weak self] in
                        guard let self, self.h8ReadGrant?.id == grantID else { return }
                        self.h8Opened = nil
                        self.h8ReadStatus = "READ GRANT EXPIRED · reopen explicitly to inspect again"
                        _ = self.h8ReadGrant?.status()
                        self.h8ReadGrant = nil
                    }
                } else { self.h8ReadStatus = "READ REJECTED · selected file unchanged" }
                controller.complete(identity, completion: .inspected)
            }
        }
    }

    func revokeH8Read(deletionRequested: Bool = false) {
        h8ReadGrant?.revoke(deletionRequested: deletionRequested)
        h8ReadGrant = nil; h8Opened = nil
        h8ReadStatus = deletionRequested
            ? "RETENTION CONFLICT · read grant revoked; this app has no file-deletion grant. Saved evidence remains."
            : "READ GRANT REVOKED · saved evidence remains"
    }

    private func rejectMissingRetention() {
        phase = "H2 unavailable: no private-journal capability"
        error = "H2 requires an explicit private-journal capability before guest preparation. No native reservation or journal operation was started. H3 does not require that journal."
    }

    /// Explicit user-mediated provisioning. Application Support is first
    /// resolved here, never at startup. Failure consumes this launch-local
    /// transition without preparing a reservation or entering a VM.
    func provisionPrivateJournal(admitted: Bool) async {
        guard admitted, canProvisionRetention,
              let ticket = storageTransition.beginCreate() else { return }
        retentionProvisioning = true
        error = nil
        phase = "Creating one descriptor-bound private journal capability; no guest or VM has entered"
        do {
            let retention = try await Task.detached(priority: .userInitiated) {
                try GuestRetentionProvisioner.provisionForExplicitUserAction()
            }.value
            try retention.revalidate()
            guard storageTransition.creating, grants.retention == nil,
                  grants.historyDisplay == nil, !historyReconstructing, !busy, !quarantined else {
                throw ProvenanceFailure("Retention capability returned after the model left its idle unbound state")
            }
            guard storageTransition.completeCreate(ticket: ticket, accepted: true) else {
                throw ProvenanceFailure("Retention capability returned under a different Create ticket")
            }
            grants = GuestSupervisorGrants(retention: retention)
            phase = "Private journal capability ready; Run remains a separate explicit action"
        } catch {
            _ = storageTransition.completeCreate(ticket: ticket, accepted: false)
            phase = "Private journal capability was not admitted"
            self.error = "\(error). No reservation or VM entry occurred; any partial root remains retained."
        }
        retentionProvisioning = false
    }

    /// Explicit, zero-argument read-only reconstruction. No path or run ID is
    /// supplied by the UI; success installs presentation only and cannot enable Run.
    func reconstructPrivateJournalHistory(admitted: Bool) async {
        guard admitted, canReconstructHistory,
              let ticket = storageTransition.beginOpen() else { return }
        historyReconstructing = true
        error = nil
        phase = "Opening the fixed private journal into bounded read-only memory; no guest or VM has entered"
        do {
            let history = try await Task.detached(priority: .userInitiated) {
                try GuestHistoryReconstructor.reconstructForExplicitUserAction()
            }.value
            guard storageTransition.opening, grants.retention == nil,
                  grants.historyDisplay == nil, !retentionProvisioning, !busy, !quarantined else {
                throw ProvenanceFailure("History returned after the model left its idle unbound state")
            }
            guard storageTransition.completeOpen(ticket: ticket, accepted: true) else {
                throw ProvenanceFailure("History returned under a different Open ticket")
            }
            grants = GuestSupervisorGrants(historyDisplay: history)
            recent = history.presentations
            phase = "Verified read-only history ready; retention and Run remain unavailable"
        } catch {
            _ = storageTransition.completeOpen(ticket: ticket, accepted: false)
            phase = "Existing private journal was not admitted"
            self.error = "\(error). No reservation, VM entry, file creation, or journal mutation occurred."
        }
        historyReconstructing = false
    }

    func startup(admitted: Bool, launchMode: DevelopmentLaunch.Mode) {
        guard !startupHandled else { return }
        startupHandled = true
        guard admitted else { return }
        #if DEBUG
        // A closed development launch convenience, not a request/command loader.
        // It enters the same fixed operation as the visible button, once per launch.
        if launchMode == .fixedGuestOnce {
            run(admitted: admitted)
            return
        }
        #endif
        guard launchMode == .ordinary else { return }
        refresh()
    }

    func run(admitted: Bool) {
        begin(admitted: admitted, guest: .baseline)
    }

    // Explicit integration seam only. No UI, startup or argv dispatch selects it.
    // Both fixed guests share this model's one owner and the native lifetime lock.
    func runRustBootstrap(admitted: Bool) {
        begin(admitted: admitted, guest: .rustBootstrap)
    }

    /// Explicit product H3 mechanics. One reserved native session owns both
    /// in-memory VM intervals and its sticky cancellation. It receives no
    /// journal, path, serialized cursor, environment, role or caller policy.
    /// Starting it permanently excludes Create, Open and the H2/Rust paths for
    /// this model lifetime, regardless of its result.
    func runH3CursorResume(admitted: Bool) {
        guard admitted, canRunH3CursorResume else { return }
        h3Attempted = true
        let identity = UUID()
        let owner = GuestRunReservation()
        do { try lifecycle.beginRun(identity, cancel: { owner.requestCancellation() }) }
        catch {
            phase = "H3 in-memory cursor/resume was not admitted"
            self.error = String(describing: error)
            return
        }
        currentRun = identity
        reservation = owner
        stopRequested = false
        busy = true
        h3Running = true
        error = nil
        h3Result = nil
        phase = "H3 in-memory checkpoint → conserved fresh VM/vCPU resume; no journal or durable receipt"
        Thread.detachNewThread { [weak self] in
            let presentation: GuestH3Presentation
            var handoff: GuestH3LivePersistence.Handoff?
            do {
                try owner.prepare()
                let completion = owner.runH3WithPersistenceHandoff()
                presentation = completion.presentation
                handoff = completion.handoff
            } catch is CancellationError {
                presentation = GuestH3LiveVerifier.canceledBeforeNativeEntry()
            } catch {
                presentation = GuestH3LiveVerifier.rejected(error)
            }
            let completedHandoff = handoff
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.busy = false
                self.h3Running = false
                self.reservation = nil
                self.currentRun = nil
                self.h3Result = presentation
                self.h4Handoff = completedHandoff
                self.quarantined = presentation.quarantined
                self.phase = presentation.status
                if presentation.status != "PASS" { self.error = presentation.detail }
                // A verified volatile PASS may continue into explicit H4
                // storage, but must not enable another guest via beginRun.
                self.lifecycle.complete(identity, completion: presentation.quarantined
                    ? .quarantined : (completedHandoff != nil ? .conservedVolatile : .recoveryVolatile))
            }
        }
    }

    /// Separate explicit retention action, never automatic on native PASS.
    /// Consumes the exact live handoff; H2 and history remain excluded.
    func saveH4Receipt(admitted: Bool) {
        guard admitted, canSaveH4Receipt, let handoff = h4Handoff else { return }
        h4Handoff = nil
        let identity = UUID()
        do { try lifecycle.beginPersistence(identity, cancel: { handoff.cancel() }) }
        catch { handoff.cancel(); self.error = String(describing: error); return }
        currentRun = identity
        busy = true; h4Saving = true; error = nil
        phase = "H4 saving canonical H3 streams → private SQLite → sync → read-only verification"
        // Ten seconds of work, then the existing five-second Stop fallback.
        // Cancel this one scheduled work item on every returned completion.
        let deadline = DispatchWorkItem { [weak self] in
            guard let self, self.currentRun == identity, self.h4Saving else { return }
            self.phase = "H4 work limit reached; stopping with retained incomplete state"
            self.lifecycle.requestStop()
        }
        h4Deadline = deadline
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: deadline)
        Thread.detachNewThread { [weak self] in
            let saved = handoff.persist()
            Task { @MainActor [weak self] in
                guard let self, self.currentRun == identity else { return }
                self.h4Deadline?.cancel(); self.h4Deadline = nil
                self.currentRun = nil; self.busy = false; self.h4Saving = false
                self.h4Result = saved
                self.phase = saved.durable ? "H4 SAVED · VERIFIED READ-BACK" : "H4 NOT VERIFIED · STATE RETAINED"
                if !saved.durable { self.error = saved.detail }
                self.lifecycle.complete(identity, completion: saved.durable ? .conserved : .recoveryVolatile)
            }
        }
    }

    /// The open panel grants one selected file, never a remembered directory
    /// or automatic namespace scan. Opening cannot restore a live H3 handoff.
    func openSavedH4Receipt(admitted: Bool) {
        guard admitted, canOpenH4Receipt else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = true; panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false; panel.canCreateDirectories = false
        panel.resolvesAliases = false
        panel.message = "Choose one saved H4 SQLite receipt. Read-only; no guest, recovery, or file changes."
        panel.prompt = "Open read-only"
        h4Opening = true
        panel.begin { [weak self] response in
            guard let self else { return }
            self.h4Opening = false
            guard response == .OK, let url = panel.url, self.canOpenH4Receipt else { return }
            self.readSelectedH4(url)
        }
    }

    private func readSelectedH4(_ url: URL) {
        h4HistoryMode = true; h4Opened = nil; h4OpenError = nil
        let identity = UUID(), budget = GuestH4SavedReceipt.Budget()
        let controller = lifecycle
        do { try controller.beginInspection(identity, cancel: { budget.cancel() }) }
        catch { h4OpenError = String(describing: error); return }
        currentRun = identity; busy = true; h4Opening = true; error = nil
        phase = "Opening selected H4 receipt read-only; no guest or save"
        // Independent of the UI queue; canceled once the bounded reader returns.
        let deadline = DispatchWorkItem { controller.requestStop(for: identity) }
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 10, execute: deadline)
        Thread.detachNewThread { [weak self] in
            let result: Result<GuestH4SavedReceipt.Snapshot, Error>
            let scoped = url.startAccessingSecurityScopedResource()
            do { result = .success(try HypervisorStageH4DualStreamPersistence.readSavedFile(url, budget: budget)) }
            catch { result = .failure(error) }
            if scoped { url.stopAccessingSecurityScopedResource() }
            deadline.cancel()
            Task { @MainActor [weak self] in
                guard let self, self.currentRun == identity else { return }
                self.currentRun = nil; self.busy = false; self.h4Opening = false
                switch result {
                case .success(let snapshot):
                    do { try budget.check(); self.h4Opened = snapshot; self.phase = "H4 REOPENED · SAVED DATA VERIFIED" }
                    catch { self.h4OpenError = String(describing: error); self.phase = "H4 read canceled; no new claim" }
                case .failure(let failure):
                    self.h4OpenError = String(describing: failure)
                    self.phase = "H4 read rejected · selected evidence unchanged"
                }
                controller.complete(identity, completion: .inspected)
            }
        }
    }

    #if EPR_H3_QUALIFICATION
    func runH3CursorResumeQualification(admitted: Bool,
        completionBarrier: H3QualificationCompletionBarrier) async -> H3QualificationH3Completion {
        let installed: Bool
        if case .qualificationInstalled = lifecycleStorage { installed = true } else { installed = false }
        if let rejection = H3QualificationStartEventPolicy.rejection(lifecycleInstalled: installed,
            admitted: admitted, modelEligible: canRunH3CursorResume) {
            _ = await completionBarrier.claimCompletionAndStopMonitor()
            return .startRejected(rejection)
        }
        guard case .qualificationInstalled(let terminalOwner, _, _, let lifecycle) = lifecycleStorage else {
            _ = await completionBarrier.claimCompletionAndStopMonitor()
            return .startRejected(.lifecycleNotInstalled)
        }
        h3Attempted = true
        let identity = UUID()
        let owner = GuestRunReservation(policy: .qualificationChecked)
        var execution = H3QualificationExecutionEventStateMachine()
        execution.begin(identity: identity, owner: UInt64(UInt(bitPattern: ObjectIdentifier(owner))))
        execution.record(.lifecycleBegin)
        do { try lifecycle.beginRun(identity, cancel: { owner.requestCancellation() }) }
        catch {
            _ = await completionBarrier.claimCompletionAndStopMonitor()
            return .startRejected(.lifecycleBeginRejected)
        }
        currentRun = identity
        reservation = owner
        stopRequested = false
        busy = true
        h3Running = true
        error = nil
        h3Result = nil
        phase = "Bounded H3 qualification in progress"
        execution.record(.workerTask)
        let worker = Task.detached(priority: .userInitiated) { [owner, seed = execution] () -> H3QualificationWorkerValue in
            var trace = seed
            do { try owner.prepare() }
            catch is CancellationError {
                let observed = owner.qualificationState()
                trace.reserveReturned(observed)
                trace.workerReturned()
                return H3QualificationWorkerValue(outcome: .canceledBeforeNative(reservationState: observed.state),
                    presentation: nil, events: trace)
            } catch {
                let observed = owner.qualificationState()
                trace.reserveReturned(observed)
                guard observed.state == .failedReserve else {
                    trace.workerReturned()
                    return H3QualificationWorkerValue(outcome: .invalidReservation(reservationState: observed.state,
                        observedError: observed.observedError), presentation: nil, events: trace)
                }
                let presentation = GuestH3LiveVerifier.rejected(ProvenanceFailure("H3 preparation failed with errno \(observed.observedError)"))
                let pure = GuestH3LiveVerifier.qualificationPresentation(presentation)
                let replay = try? H3QualificationReplay.preparationPresentation(error: observed.observedError)
                trace.workerReturned(parity: replay == pure)
                return H3QualificationWorkerValue(outcome: .preparationFailed(preparationError: observed.observedError, presentation: pure),
                    presentation: replay == pure ? presentation : nil, events: trace)
            }
            trace.reserveReturned(owner.qualificationState())
            trace.record(.nativeEntry)
            let returned = owner.runH3CursorResume()
            let capture = GuestH3LiveVerifier.qualificationCapture(returned)
            let presentation: GuestH3Presentation
            do { presentation = try GuestH3LiveVerifier.verify(returned) }
            catch { presentation = GuestH3LiveVerifier.rejected(returned, error) }
            let pure = GuestH3LiveVerifier.qualificationPresentation(presentation, returned: returned)
            let assessment = try? H3QualificationNativeEventAssessment.replay(capture)
            let parity = assessment?.presentation == pure
            trace.workerReturned(native: assessment, parity: parity)
            return H3QualificationWorkerValue(outcome: .nativeReturned(capture: capture, presentation: pure),
                presentation: parity ? presentation : nil, events: trace)
        }
        let value = await worker.value
        execution = value.events
        execution.record(.workerAwait)
        let disposition = await completionBarrier.claimCompletionAndStopMonitor()
        let before = owner.qualificationState()
        let completionFirst: Bool
        if case .completionFirst = disposition { completionFirst = true } else { completionFirst = false }
        switch disposition {
        case .completionFirst(let monitor), .cancellationFirst(let monitor):
            execution.join(monitor, first: completionFirst)
        }
        let decision = H3QualificationWorkerPolicy.decision(outcome: value.outcome,
            reservation: before, completionFirst: completionFirst)
        guard decision != .internalFailure else { terminalOwner.terminate(70) }
        if case .cancellationFirst = disposition {
            guard currentRun == identity, reservation === owner else { terminalOwner.terminate(70) }
            let cancellationCompletion: AppLifecyclePolicy.Completion
            if case .nativeReturned(_, let nativePresentation) = value.outcome {
                guard value.presentation != nil else { terminalOwner.terminate(70) }
                cancellationCompletion = nativePresentation.quarantined ? .quarantined : .recoveryVolatile
            } else { cancellationCompletion = .recoveryVolatile }
            execution.sameOwners(identity: identity, owner: UInt64(UInt(bitPattern: ObjectIdentifier(owner))))
            execution.record(.lifecycleComplete)
            lifecycle.complete(identity, completion: cancellationCompletion)
            qualificationEventSnapshot = execution
            terminalOwner.terminate(70)
        }
        guard case .completionFirst = disposition, let presentation = value.presentation else { terminalOwner.terminate(70) }
        guard decision == .releaseSentinel || decision == .releaseToken else { terminalOwner.terminate(70) }
        let released: H3QualificationReservationStateMachine
        execution.record(.checkedRelease)
        do { released = try owner.releaseChecked() }
        catch { terminalOwner.terminate(70) }
        execution.released(released)
        if released.reservationReleaseEntries == 1, released.reservationReleaseStatus > 0 {
            return .releaseRejected(status: released.reservationReleaseStatus)
        }
        guard currentRun == identity, reservation === owner else { terminalOwner.terminate(70) }
        execution.sameOwners(identity: identity, owner: UInt64(UInt(bitPattern: ObjectIdentifier(owner))))
        execution.record(.publication)
        h3Result = presentation
        quarantined = presentation.quarantined
        phase = presentation.status
        if presentation.status != "PASS" { error = presentation.detail }
        let passed: H3QualificationLifecycleDisposition = presentation.quarantined ? .quarantined : .recoveryVolatile
        execution.record(.lifecycleComplete)
        lifecycle.complete(identity, completion: presentation.quarantined ? .quarantined : .recoveryVolatile)
        reservation = nil
        currentRun = nil
        busy = false
        h3Running = false
        qualificationEventSnapshot = execution
        guard execution.reportable else { terminalOwner.terminate(70) }
        switch value.outcome {
        case .preparationFailed(let observedError, let pure):
            return .preparationRejected(preparationError: observedError, reservationEntries: released.reservationEntries,
                reservationReleaseEntries: released.reservationReleaseEntries,
                reservationReleaseStatus: released.reservationReleaseStatus, presentation: pure, lifecycleDisposition: passed)
        case .nativeReturned(let capture, let pure):
            return .nativeReturned(capture: capture, presentation: pure, reservationEntries: released.reservationEntries,
                reservationReleaseEntries: released.reservationReleaseEntries,
                reservationReleaseStatus: released.reservationReleaseStatus, lifecycleDisposition: passed)
        default: terminalOwner.terminate(70)
        }
    }
    #endif

    #if DEBUG
    // The controlled coordinator owns the later evidence-export/window latch.
    // This latch is permanent for this model and excludes every manual entry.
    func runDevelopmentRustBoot(admitted: Bool) async -> DevelopmentRustBootCompletion? {
        guard admitted, nativeRunAdmission(), !h3Attempted, !developmentRustBootHandled, !busy, !quarantined else { return nil }
        guard let retention = grants.retention, retention.isDescriptorBound else {
            rejectMissingRetention(); return nil
        }
        do { try retention.revalidate() }
        catch {
            self.error = "Retention capability rejected before native reservation: \(error)"
            return nil
        }
        let identity = UUID()
        let owner = GuestRunReservation()
        do { try lifecycle.beginRun(identity, cancel: { owner.requestCancellation() }) }
        catch { self.error = String(describing: error); return nil }
        currentRun = identity; reservation = owner; stopRequested = false
        developmentRustBootHandled = true
        busy = true; error = nil
        phase = "Controlled Rust invocation in progress: preparation, native owner, then journal read-back"
        let runID = identity.uuidString.lowercased()
        developmentBootRunID = runID
        let completion: DevelopmentRustBootCompletion = await withCheckedContinuation { continuation in
            Thread.detachNewThread {
                let capture = RustBootCapture()
                let presentation: GuestPresentation
                do {
                    try owner.prepare()
                    presentation = try Self.executeRustBootstrap(runID: runID,
                        retention: retention, owner: owner, capture: capture)
                } catch {
                    presentation = GuestPresentation(id: runID, status: "INCOMPLETE",
                        detail: "\(error). Available current-run evidence remains in this completion; durable export is not yet established. No automatic rerun.",
                        root: "", elapsed: "", events: [], quarantined: true)
                }
                // Attempt-completion time, including failure, not proof of a
                // successful journal commit; the independent flags carry that.
                let completedTicks = mach_absolute_time()
                continuation.resume(returning: capture.completion(runID: runID,
                    presentation: presentation, completedTicks: completedTicks))
            }
        }
        busy = false
        // Storage failure does not manufacture native nonconservation. The
        // permanent mode latch still prevents another run in either case.
        quarantined = completion.nativeDisposition == .returnedUnconserved
        phase = completion.status
        result = GuestPresentation(id: completion.runID, status: completion.status,
            detail: completion.detail, root: "", elapsed: "",
            events: completion.events.map {
                GuestEventDisplay(id: $0.sequence, kind: $0.kind, digest: $0.digest, byteCount: $0.payload.count)
            }, quarantined: quarantined)
        if completion.status != "PASS" { error = completion.detail }
        reservation = nil; currentRun = nil
        lifecycle.complete(identity, completion: completion.nativeDisposition == .returnedUnconserved
            ? .quarantined : (completion.journalRetainsAllEvidence ? .conserved : .recoveryVolatile))
        // No ordinary refresh/second journal reader in this controlled mode.
        return completion
    }
    #endif

    private func begin(admitted: Bool, guest: FixedGuest) {
        #if DEBUG
        guard !developmentRustBootHandled else { return }
        #endif
        guard admitted, nativeRunAdmission(), !h3Attempted, !busy, !quarantined else { return }
        guard let retention = grants.retention, retention.isDescriptorBound else {
            rejectMissingRetention(); return
        }
        do { try retention.revalidate() }
        catch {
            self.error = "Retention capability rejected before native reservation: \(error)"
            return
        }
        let identity = UUID()
        let owner = GuestRunReservation(productChecked: true)
        do { try lifecycle.beginRun(identity, cancel: { owner.requestCancellation() }) }
        catch { self.error = String(describing: error); return }
        currentRun = identity; reservation = owner; stopRequested = false
        busy = true; error = nil
        phase = guest == .baseline
            ? "Preparing durable start → fixed guest → snapshot → teardown → read-back"
            : "Preparing durable start → fixed Rust bootstrap → snapshot → teardown → read-back"
        let runID = identity.uuidString.lowercased()
        // The complete synchronous native call is confined to this one OS thread.
        Thread.detachNewThread { [weak self] in
            let presentation: GuestPresentation
            do {
                try owner.prepare()
                presentation = try Self.execute(runID: runID, retention: retention, guest: guest, owner: owner)
            }
            catch is CancellationError {
                presentation = GuestPresentation(id: runID, status: "CANCELED",
                    detail: "Stop was latched before native entry. Any existing journal prefix remains unchanged; no terminal or conservation proof was invented.",
                    root: "", elapsed: "", events: [], quarantined: false)
            }
            catch {
                presentation = GuestPresentation(id: runID, status: "INCOMPLETE",
                    detail: "\(error). Inspect the retained journal prefix; no automatic rerun.",
                    root: "", elapsed: "", events: [], quarantined: true)
            }
            let completedPresentation = GuestProductReservationRelease.presentation(presentation,
                releaseStatus: owner.releaseForProduct())
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.busy = false
                self.reservation = nil; self.currentRun = nil
                self.result = completedPresentation
                self.quarantined = completedPresentation.quarantined
                self.phase = completedPresentation.status
                if completedPresentation.status != "PASS" { self.error = completedPresentation.detail }
                self.lifecycle.complete(identity, completion: completedPresentation.quarantined ? .quarantined :
                    (completedPresentation.volatileObservation == nil ? .conserved : .recoveryVolatile))
                // A completed run does not authorize discovery of older runs.
                // The separately granted history snapshot remains unchanged.
            }
        }
    }

    func cancel() {
        guard busy else { return }
        stopRequested = true
        phase = "Stop requested. Up to five seconds to finish; otherwise this app exits with incomplete evidence."
        lifecycle.requestStop()
    }

    func requestQuit() -> Bool {
        stopRequested = true
        phase = "Quitting. Up to five seconds for current work; Quit Now skips the grace period."
        return lifecycle.requestQuit()
    }

    func quitNow() { lifecycle.quitNow() }

    func refresh() {
        #if DEBUG
        guard !developmentRustBootHandled else { return }
        #endif
        // Presentation only: no path lookup, file open, SQLite mutation,
        // enumeration, or second journal owner can be introduced by refresh.
        guard !busy else { return }
        guard let history = grants.historyDisplay else { return }
        recent = history.presentations
    }

    nonisolated private static func execute(runID: String, retention: GuestSupervisorRetentionGrant,
                                            guest: FixedGuest, owner: GuestRunReservation) throws -> GuestPresentation {
        switch guest {
        case .baseline: return try executeBaseline(runID: runID, retention: retention, owner: owner)
        case .rustBootstrap: return try executeRustBootstrap(runID: runID, retention: retention, owner: owner)
        }
    }

    // Preserve the baseline journal payloads and native zero-argument entry.
    nonisolated private static func executeBaseline(runID: String, retention: GuestSupervisorRetentionGrant,
                                                    owner: GuestRunReservation) throws -> GuestPresentation {
        try owner.checkCancellation()
        let journal = try GuestJournal(retentionGrant: retention)
        guard let imagePointer = epr_guest_image_bytes() else { throw ProvenanceFailure("No fixed guest image") }
        let image = Data(bytes: imagePointer, count: epr_guest_image_size())
        guard GuestContract.hash(image) == GuestContract.expectedGuestSHA256 else {
            throw ProvenanceFailure("Guest image is not sealed to its reviewed assembly")
        }
        guard let ancestry = retention.ancestry else {
            throw ProvenanceFailure("Guest start requires retained genesis ancestry")
        }
        let startPayload: [String: GuestCBORValue] = [
            "guest_image": .bytes(image), "guest_sha256": .text(GuestContract.hash(image)),
            "request": .bytes(GuestContract.request), "expected_reply": .bytes(GuestContract.reply),
            "load_ipa": .unsigned(epr_guest_image_load_address()),
            "doorbell_instruction_offset": .unsigned(epr_guest_doorbell_instruction_offset()),
            "host_bundle": .text("com.ergentics.provenance"),
            "host_version": .text(ProcessInfo.processInfo.operatingSystemVersionString),
            "utc": .text(ISO8601DateFormatter().string(from: Date())),
            "retention_epoch_id": .text(ancestry.epochID),
            "retention_genesis_sha256": .text(ancestry.genesisSHA256),
            "scope": .text("local development transport, not DeltaPU acceleration or Gate E")
        ]
        _ = try journal.append(runID: runID, kind: "start", payload: startPayload)
        let startReadback = try journal.events(runID: runID)
        guard startReadback.count == 1, startReadback[0].kind == "start",
              case .map(let startEnvelope) = try GuestCBOR.decode(startReadback[0].payload),
              startEnvelope["payload"] == .map(startPayload) else {
            throw ProvenanceFailure("Exact committed start read-back failed before guest entry")
        }
        try owner.checkCancellation()
        var raw = owner.runBaseline()
        let request = withUnsafeBytes(of: &raw.request) { Data($0) }
        let reply = withUnsafeBytes(of: &raw.reply) { Data($0) }
        let rootBytes = withUnsafeBytes(of: &raw.snapshot_merkle) { Data($0) }
        let root = rootBytes.map { String(format: "%02x", $0) }.joined()
        let independentPass = try raw.snapshot_sealed == 1 &&
            GuestContract.validateSnapshot(image: image, request: request, reply: reply, expectedRoot: root)
        var fields = nativeFields(raw)
        fields["request"] = .bytes(request); fields["reply"] = .bytes(reply)
        fields["guest_sha256"] = .text(GuestContract.hash(image))
        fields["snapshot_merkle"] = .bytes(rootBytes)
        fields["independent_snapshot_pass"] = .bool(independentPass)
        fields["seal_scope"] = .text("volatile before teardown; durable only on this host transaction")
        let recovery = try GuestCBOR.encode(.map(fields))
        do {
        _ = try journal.append(runID: runID, kind: "observation", payload: fields)
        let passed = raw.outcome == EPR_GUEST_PASS && raw.execution_pass == 1 &&
            raw.teardown_pass == 1 && independentPass
        let status = passed ? "PASS" : (raw.outcome == EPR_GUEST_CANCELED ? "CANCELED" : "FAIL")
        let stage = String(cString: epr_guest_stage_name(raw.failure_stage))
        _ = try journal.append(runID: runID, kind: "terminal", payload: [
            "status": .text(status), "execution_pass": .bool(raw.execution_pass == 1),
            "teardown_pass": .bool(raw.teardown_pass == 1),
            "independent_snapshot_pass": .bool(independentPass),
            "resources_quarantined": .bool(raw.resources_quarantined == 1),
            "snapshot_merkle": .text(raw.snapshot_sealed == 1 ? root : ""),
            "detail": .text(passed ? "One fixed guest entry; 19 + 23 = 42; exact doorbell, independent snapshot and teardown verified." :
                "Native stage \(stage), error \(raw.first_error); execution and teardown remain separate observations."),
            "elapsed": .text("\(raw.end_ticks >= raw.start_ticks ? raw.end_ticks - raw.start_ticks : 0) ticks × \(raw.timebase_numer)/\(raw.timebase_denom) ns"),
            "energy": .text("unmeasured; ergs unavailable"),
            "gate_e": .text("ABSTAIN"), "authority_vector": .text("00000000")
        ])
        return try present(runID: runID, events: journal.events(runID: runID), retention: retention)
        } catch {
            // Keep the complete native observation in memory even when durable
            // publication or its verification fails. Never turn that failure
            // into native FAIL, a successful teardown, or permission to rerun.
            return GuestPresentation(id: runID, status: "INCOMPLETE",
                detail: "Persistence/read-back failed: \(error). Native execution=\(raw.execution_pass), teardown=\(raw.teardown_pass), quarantined=\(raw.resources_quarantined). Raw CBOR remains in this window; the retained database prefix is not rewritten.",
                root: raw.snapshot_sealed == 1 ? root : "", elapsed: "", events: [], quarantined: true,
                volatileObservation: recovery)
        }
    }

    nonisolated private static func executeRustBootstrap(runID: String, retention: GuestSupervisorRetentionGrant,
                                                        owner: GuestRunReservation,
                                                        capture: RustBootCapture? = nil) throws -> GuestPresentation {
        try owner.checkCancellation()
        let imageSize = epr_rust_guest_image_size()
        let memorySize = epr_rust_guest_memory_contract_size()
        let loadAddress = epr_rust_guest_image_load_address()
        let doorbellOffset = epr_rust_guest_doorbell_instruction_offset()
        guard imageSize == RustBootstrapContract.imageByteCount,
              memorySize == RustBootstrapContract.memoryContract.count,
              let imagePointer = epr_rust_guest_image_bytes(),
              let memoryPointer = epr_rust_guest_memory_contract_bytes() else {
            throw ProvenanceFailure("Missing or incorrectly sized fixed Rust bootstrap image/layout")
        }
        let image = Data(bytes: imagePointer, count: imageSize)
        let memoryContract = Data(bytes: memoryPointer, count: memorySize)
        guard GuestContract.hash(image) == RustBootstrapContract.expectedGuestSHA256,
              memoryContract == RustBootstrapContract.memoryContract,
              loadAddress == RustBootstrapContract.loadAddress,
              doorbellOffset == RustBootstrapContract.doorbellOffset else {
            throw ProvenanceFailure("Rust bootstrap image/layout does not match its reviewed contract")
        }
        // One journal format, with mandatory profile/layout joins in the verifier.
        // Historical baseline events retain their absent-profile representation.
        let journal = try GuestJournal(retentionGrant: retention)
        guard let ancestry = retention.ancestry else {
            throw ProvenanceFailure("Rust start requires retained genesis ancestry")
        }
        let startPayload: [String: GuestCBORValue] = [
            "profile": .text(RustBootstrapContract.profile),
            "snapshot_schema": .text(RustBootstrapContract.schema),
            "memory_contract": .bytes(memoryContract),
            "guest_image": .bytes(image), "guest_sha256": .text(GuestContract.hash(image)),
            "request": .bytes(RustBootstrapContract.request), "expected_reply": .bytes(RustBootstrapContract.reply),
            "load_ipa": .unsigned(loadAddress), "doorbell_instruction_offset": .unsigned(doorbellOffset),
            "host_bundle": .text("com.ergentics.provenance"),
            "host_version": .text(ProcessInfo.processInfo.operatingSystemVersionString),
            "utc": .text(ISO8601DateFormatter().string(from: Date())),
            "retention_epoch_id": .text(ancestry.epochID),
            "retention_genesis_sha256": .text(ancestry.genesisSHA256),
            "scope": .text("fixed Rust bootstrap development transport, not VM attestation, high-value trust or Gate E")
        ]
        let startEvent = try journal.append(runID: runID, kind: "start", payload: startPayload)
        capture?.events = [startEvent]
        let startReadback = try journal.events(runID: runID)
        capture?.events = startReadback
        guard startReadback.count == 1, startReadback[0].kind == "start",
              case .map(let startEnvelope) = try GuestCBOR.decode(startReadback[0].payload),
              startEnvelope["payload"] == .map(startPayload) else {
            throw ProvenanceFailure("Exact Rust start read-back failed before guest entry")
        }
        // Same dedicated OS thread and cancellation owner as the baseline path.
        // Commitment is not proof of a vCPU entry; only returned run_entries is.
        try owner.checkCancellation()
        capture?.nativeDisposition = .running
        var wrapper = owner.runRust()
        capture?.returned(wrapper)
        var raw = wrapper.base
        let request = withUnsafeBytes(of: &raw.request) { Data($0) }
        let reply = withUnsafeBytes(of: &raw.reply) { Data($0) }
        let rootBytes = withUnsafeBytes(of: &raw.snapshot_merkle) { Data($0) }
        let stackFrame = withUnsafeBytes(of: &wrapper.stack_frame) { Data($0) }
        let root = rootBytes.map { String(format: "%02x", $0) }.joined()
        var fields = nativeFields(raw)
        fields["profile"] = .text(RustBootstrapContract.profile)
        fields["memory_contract"] = .bytes(memoryContract)
        fields["request"] = .bytes(request)
        fields["reply"] = .bytes(reply)
        fields["guest_sha256"] = .text(GuestContract.hash(image))
        fields["snapshot_merkle"] = .bytes(rootBytes)
        fields["stack_frame"] = .bytes(stackFrame)
        fields["stack_valid"] = .unsigned(UInt64(wrapper.stack_valid))
        fields["entry_sp"] = .unsigned(wrapper.entry_sp)
        fields["exit_sp"] = .unsigned(wrapper.exit_sp)
        // Preserve an explicit, non-affirming recovery map before reconstruction
        // can throw; no padding or opaque struct representation is exported.
        fields["independent_snapshot_pass"] = .bool(false)
        fields["seal_scope"] = .text("volatile before teardown; durable only on this host transaction")
        if case .map(var statuses) = fields["native_status_decimal"] {
            statuses["map_stack"] = .text(String(wrapper.stack_map_status))
            statuses["unmap_stack"] = .text(String(wrapper.stack_unmap_status))
            statuses["host_unmap_stack"] = .text(String(wrapper.stack_host_unmap_status))
            statuses["entry_sp"] = .text(String(wrapper.entry_sp_status))
            statuses["exit_sp"] = .text(String(wrapper.exit_sp_status))
            fields["native_status_decimal"] = .map(statuses)
        }
        capture?.rawFields = fields
        let independentPass = try raw.snapshot_sealed == 1 &&
            RustBootstrapContract.validateSnapshot(image: image, request: request, reply: reply,
                memoryContract: memoryContract, stackFrame: stackFrame, expectedRoot: root)
        fields["independent_snapshot_pass"] = .bool(independentPass)
        capture?.rawFields = fields
        let recovery = try GuestCBOR.encode(.map(fields))
        do {
            let observationEvent = try journal.append(runID: runID, kind: "observation", payload: fields)
            capture?.events.append(observationEvent)
            let passed = raw.outcome == EPR_GUEST_PASS && raw.execution_pass == 1 &&
                raw.teardown_pass == 1 && wrapper.stack_valid == 1 && independentPass
            let status = passed ? "PASS" : (raw.outcome == EPR_GUEST_CANCELED ? "CANCELED" : "FAIL")
            let stage = String(cString: epr_guest_stage_name(raw.failure_stage))
            let terminalEvent = try journal.append(runID: runID, kind: "terminal", payload: [
                "profile": .text(RustBootstrapContract.profile),
                "memory_contract": .bytes(memoryContract),
                "status": .text(status), "execution_pass": .bool(raw.execution_pass == 1),
                "teardown_pass": .bool(raw.teardown_pass == 1),
                "independent_snapshot_pass": .bool(independentPass),
                "resources_quarantined": .bool(raw.resources_quarantined == 1),
                "snapshot_merkle": .text(raw.snapshot_sealed == 1 ? root : ""),
                "detail": .text(passed ? "One fixed Rust bootstrap entry; exact request/reply, stack frame, six-leaf snapshot and teardown verified. No VM attestation or high-value trust claim." :
                    "Rust native stage \(stage), error \(raw.first_error); execution and teardown remain separate observations."),
                "elapsed": .text("\(raw.end_ticks >= raw.start_ticks ? raw.end_ticks - raw.start_ticks : 0) ticks × \(raw.timebase_numer)/\(raw.timebase_denom) ns"),
                "energy": .text("unmeasured; ergs unavailable"),
                "gate_e": .text("ABSTAIN"), "authority_vector": .text("00000000")
            ])
            capture?.events.append(terminalEvent)
            let readback = try journal.events(runID: runID)
            capture?.events = readback
            let presentation = try present(runID: runID, events: readback, retention: retention)
            if let capture {
                guard readback.count == 3,
                      case .map(let observationEnvelope) = try GuestCBOR.decode(readback[1].payload),
                      observationEnvelope["payload"] == .map(fields) else {
                    throw ProvenanceFailure("Controlled Rust journal does not retain the exact native observation")
                }
                capture.journalVerified = true
                capture.journalRetainsAllEvidence = true
            }
            return presentation
        } catch {
            return GuestPresentation(id: runID, status: "INCOMPLETE",
                detail: "Rust persistence/read-back failed: \(error). Native execution=\(raw.execution_pass), teardown=\(raw.teardown_pass), stack=\(wrapper.stack_valid), quarantined=\(raw.resources_quarantined). Raw CBOR remains in this window; the retained database prefix is not rewritten.",
                root: raw.snapshot_sealed == 1 ? root : "", elapsed: "", events: [], quarantined: true,
                volatileObservation: recovery)
        }
    }

    nonisolated private static func nativeFields(_ r: EPRGuestResult) -> [String: GuestCBORValue] {
        var values: [String: GuestCBORValue] = [:]
        let flags: [(String, UInt32)] = [
            ("abi_version", r.abi_version), ("outcome", r.outcome), ("execution_pass", r.execution_pass),
            ("teardown_pass", r.teardown_pass), ("signing_admitted", r.signing_admitted),
            ("run_entries", r.run_entries), ("vcpu_created", r.vcpu_created), ("mappings_entered", r.mappings_entered),
            ("register_calls", r.register_calls), ("read_register_calls", r.read_register_calls),
            ("cancellation_requested", r.cancellation_requested), ("cancellation_calls", r.cancellation_calls),
            ("watchdog_fired", r.watchdog_fired), ("resources_quarantined", r.resources_quarantined),
            ("request_unchanged", r.request_unchanged), ("reply_valid", r.reply_valid),
            ("code_unchanged", r.code_unchanged), ("trap_valid", r.trap_valid),
            ("exception_reason", r.exception_reason), ("timebase_numer", r.timebase_numer),
            ("timebase_denom", r.timebase_denom), ("snapshot_sealed", r.snapshot_sealed)]
        for (key, value) in flags { values[key] = .unsigned(UInt64(value)) }
        let words: [(String, UInt64)] = [
            ("start_ticks", r.start_ticks), ("entry_ticks", r.entry_ticks), ("exit_ticks", r.exit_ticks),
            ("snapshot_ticks", r.snapshot_ticks), ("end_ticks", r.end_ticks), ("deadline_ticks", r.deadline_ticks),
            ("syndrome", r.syndrome), ("pc", r.pc), ("fault_ipa", r.fault_ipa),
            ("fault_virtual_address", r.fault_virtual_address), ("x4", r.x4),
            ("sctlr_el1", r.sctlr_el1), ("cpsr", r.cpsr)]
        for (key, value) in words { values[key] = .unsigned(value) }
        let statuses: [(String, Int32)] = [
            ("failure_stage", r.failure_stage), ("first_error", r.first_error), ("signing_error", r.signing_error),
            ("vm_create", r.vm_create_status), ("vcpu_create", r.vcpu_create_status),
            ("register", r.register_status), ("run", r.run_status), ("read_register", r.read_register_status),
            ("vcpu_destroy", r.vcpu_destroy_status), ("vm_destroy", r.vm_destroy_status),
            ("cancellation", r.cancellation_status), ("watchdog_create", r.watchdog_create_status),
            ("watchdog_join", r.watchdog_join_status), ("map_code", r.map_status.0),
            ("watchdog_wait", r.watchdog_wait_status),
            ("host_unmap_code", r.host_unmap_status.0), ("host_unmap_request", r.host_unmap_status.1),
            ("host_unmap_reply", r.host_unmap_status.2),
            ("map_request", r.map_status.1), ("map_reply", r.map_status.2),
            ("unmap_code", r.unmap_status.0), ("unmap_request", r.unmap_status.1), ("unmap_reply", r.unmap_status.2)]
        // Decimal strings preserve signed native status values, including the
        // INT32_MIN not-entered sentinel, without changing the unsigned CBOR profile.
        values["native_status_decimal"] = .map(Dictionary(uniqueKeysWithValues:
            statuses.map { ($0.0, .text(String($0.1))) }))
        return values
    }

    nonisolated private static func present(runID: String, events: [GuestJournalEvent],
                                            retention: GuestSupervisorRetentionGrant) throws -> GuestPresentation {
        guard let ancestry = retention.ancestry else {
            throw ProvenanceFailure("Guest presentation requires retained genesis ancestry")
        }
        let verified = try GuestResultVerifier.verify(runID: runID, events: events,
            expectedRetention: ancestry)
        return GuestPresentation(id: runID, status: verified.status, detail: verified.detail, root: verified.root, elapsed: verified.elapsed,
            events: events.map { GuestEventDisplay(id: $0.sequence, kind: $0.kind, digest: $0.digest, byteCount: $0.payload.count) },
            quarantined: verified.quarantined)
    }
}
