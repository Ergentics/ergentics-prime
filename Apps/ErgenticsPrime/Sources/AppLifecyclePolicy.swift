import Foundation

/// Value-only Stop/Quit policy. The coordinator supplies mach_continuous_time
/// samples and owns cancellation, timers and exit. These effects are requests,
/// not evidence of cancellation, conservation, persistence or process exit.
struct AppLifecyclePolicy: Sendable {
    enum Intent: Equatable, Sendable { case stop, quit, quitNow }
    enum Completion: Equatable, Sendable {
        case conserved
        /// Native H3 completed and conserved; its expected in-memory result
        /// may continue only into an explicitly admitted persistence action.
        case conservedVolatile
        /// A read-only inspection returned and closed its resources, whether
        /// the selected evidence was accepted or rejected. Never guest admission.
        case inspected
        case recoveryVolatile
        case quarantined
    }
    enum WorkState: Equatable, Sendable {
        case idle
        case running
        /// The complete owner/journal attempt has returned, not merely the
        /// native vCPU call. Failure outcomes do not prevent a requested Quit.
        case completed(Completion)
    }
    enum Effect: Equatable, Sendable {
        case requestCancellation(runID: UUID)
        case finishStop(runID: UUID?)
        case terminateNormally
        case forceSelfExit70
    }
    enum BeginError: Error, Equatable {
        case workUnsettled
        case exitAlreadyRequested
        case recoveryRequiresAttention
        case duplicateRunID
    }
    enum ForceReason: Equatable, Sendable {
        case graceExpired
        case readinessHorizonExpired
        case clockRegressed
        case invalidTimebase
        case explicitQuitNow
    }

    enum ReadinessPhase: String, Equatable, Sendable {
        case working = "working"
        case grace = "grace"
        case completedAwaitingExit = "completed_awaiting_exit"
        case forced = "forced"
    }
    /// Observed lifecycle state only. In particular, workCompleted does not
    /// assert output, persistence, conservation or eventual process exit.
    struct ReadinessSnapshot: Equatable, Sendable {
        let runID: UUID
        let phase: ReadinessPhase
        let workBudgetExpired: Bool
        let canceled: Bool
        let workCompleted: Bool
        let startTicks: UInt64
        let observationTicks: UInt64
        let timebaseNumerator: UInt32
        let timebaseDenominator: UInt32
        let clockValid: Bool
        let fallbackArmed: Bool
    }
    struct ReadinessUpdate: Equatable, Sendable {
        let snapshot: ReadinessSnapshot
        let effects: [Effect]
    }
    enum ReadinessError: Error, Equatable {
        case notAdmitted
        case staleRunID
        case alreadyAdmitted
        case alreadyCompleted
    }

    static let graceNanoseconds: UInt64 = 5_000_000_000
    static let readinessWorkNanoseconds: UInt64 = 10_000_000_000
    static let readinessHorizonNanoseconds: UInt64 = 15_000_000_000
    let timebaseNumerator: UInt32
    let timebaseDenominator: UInt32
    private(set) var runID: UUID?
    private(set) var workState: WorkState = .idle
    private(set) var pendingIntent: Intent?
    private(set) var graceStartedTicks: UInt64?
    private(set) var forceReason: ForceReason?
    private var lastObservedTicks: UInt64?
    private var cancellationRequested = false
    private var stopDelivered = false
    private var exitRequested = false
    private var forceExitRequested = false
    private var usedRunIDs: Set<UUID> = []
    private var persistenceOnly = false
    private var readinessStartedTicks: UInt64?
    private var readinessObservationTicks: UInt64?
    private var readinessWorkBudgetExpired = false
    private var readinessCanceled = false
    private var readinessWorkCompleted = false

    init(timebaseNumerator: UInt32, timebaseDenominator: UInt32) {
        self.timebaseNumerator = timebaseNumerator
        self.timebaseDenominator = timebaseDenominator
    }

    var hasPendingDeadline: Bool {
        guard !forceExitRequested else { return false }
        // Unlike normal interactive work, readiness always has an exit
        // fallback, including after its work or normal-exit request returns.
        if readinessStartedTicks != nil { return true }
        guard graceStartedTicks != nil else { return false }
        // A normal termination request is not observed process exit. Quit
        // retains its deadline even when the owner is idle/returned or AppKit
        // has been asked to terminate. Only a completed Stop disarms grace.
        return pendingIntent == .quit || (workState == .running && !exitRequested)
    }

    /// An explicit new user run only; the policy never emits a restart effect.
    /// Failed recovery/quarantine stays available for inspection until exit.
    mutating func beginRun(_ id: UUID) throws {
        try begin(id, persistence: false)
    }

    mutating func beginPersistence(_ id: UUID) throws {
        guard workState == .completed(.conservedVolatile) else {
            throw BeginError.recoveryRequiresAttention
        }
        try begin(id, persistence: true)
    }

    mutating func beginInspection(_ id: UUID) throws {
        try begin(id, persistence: false, inspection: true)
    }

    private mutating func begin(_ id: UUID, persistence: Bool, inspection: Bool = false) throws {
        guard readinessStartedTicks == nil else { throw ReadinessError.alreadyAdmitted }
        guard !exitRequested, pendingIntent != .quit, pendingIntent != .quitNow else {
            throw BeginError.exitAlreadyRequested
        }
        guard workState != .running else { throw BeginError.workUnsettled }
        if case .completed(let outcome) = workState,
           outcome != .conserved && !(persistence && outcome == .conservedVolatile) &&
           !(inspection && outcome == .inspected) {
            throw BeginError.recoveryRequiresAttention
        }
        guard !usedRunIDs.contains(id) else { throw BeginError.duplicateRunID }
        usedRunIDs.insert(id)
        persistenceOnly = persistence || inspection
        runID = id
        workState = .running
        pendingIntent = nil
        graceStartedTicks = nil
        lastObservedTicks = nil
        cancellationRequested = false
        stopDelivered = false
        forceReason = nil
    }

    /// One fixed readiness interval per controller. The horizon is measured
    /// from this sample, never from a delayed work-budget callback.
    mutating func beginReadiness(_ id: UUID, now: UInt64) throws -> ReadinessUpdate {
        guard readinessStartedTicks == nil else { throw ReadinessError.alreadyAdmitted }
        try beginRun(id)
        readinessStartedTicks = now
        readinessObservationTicks = now
        lastObservedTicks = now
        let effects = checkDeadline(now: now)
        return ReadinessUpdate(snapshot: readinessSnapshot(id), effects: effects)
    }

    mutating func checkReadiness(_ id: UUID, now: UInt64) throws -> ReadinessUpdate {
        try requireReadiness(id)
        let effects = checkDeadline(now: now)
        return ReadinessUpdate(snapshot: readinessSnapshot(id), effects: effects)
    }

    /// Called after the coordinator's final output attempt returns. This
    /// settles only that work, not output success or observed process exit.
    mutating func completeReadiness(_ id: UUID, now: UInt64) throws -> ReadinessUpdate {
        try requireReadiness(id)
        guard !readinessWorkCompleted else { throw ReadinessError.alreadyCompleted }
        var effects = checkDeadline(now: now)
        readinessWorkCompleted = true
        // Readiness owns no native run: becoming idle here does not fabricate
        // a native .conserved outcome or permit a subsequent admission.
        workState = .idle
        if !forceExitRequested { effects += finishReturnedWork() }
        return ReadinessUpdate(snapshot: readinessSnapshot(id), effects: effects)
    }

    private func requireReadiness(_ id: UUID) throws {
        guard readinessStartedTicks != nil else { throw ReadinessError.notAdmitted }
        guard runID == id else { throw ReadinessError.staleRunID }
    }

    private func readinessSnapshot(_ id: UUID) -> ReadinessSnapshot {
        let phase: ReadinessPhase
        if forceExitRequested { phase = .forced }
        else if readinessCanceled { phase = .grace }
        else if readinessWorkCompleted { phase = .completedAwaitingExit }
        else { phase = .working }
        return ReadinessSnapshot(runID: id, phase: phase,
            workBudgetExpired: readinessWorkBudgetExpired, canceled: readinessCanceled,
            workCompleted: readinessWorkCompleted, startTicks: readinessStartedTicks!,
            observationTicks: readinessObservationTicks!, timebaseNumerator: timebaseNumerator,
            timebaseDenominator: timebaseDenominator,
            clockValid: forceReason != .invalidTimebase && forceReason != .clockRegressed,
            fallbackArmed: hasPendingDeadline)
    }

    /// This closes the coordinator's activation path after Stop/Quit. It is
    /// not a kernel reservation: the native owner must also latch cancellation
    /// against the same run before admitting a later activation.
    func mayActivate(runID id: UUID) -> Bool {
        // Readiness is observational work, never a native-run admission.
        !persistenceOnly && readinessStartedTicks == nil && runID == id && workState == .running && pendingIntent == nil && !exitRequested
    }

    mutating func request(_ intent: Intent, now: UInt64) -> [Effect] {
        if intent == .quitNow { return force(.explicitQuitNow) }
        guard !forceExitRequested else { return [] }
        if exitRequested { return hasPendingDeadline ? checkDeadline(now: now) : [] }
        if readinessStartedTicks != nil { readinessCanceled = true }
        // Quit is irreversible; a later Stop cannot downgrade it.
        if pendingIntent == nil || intent == .quit { pendingIntent = intent }
        if graceStartedTicks == nil && (pendingIntent == .quit || workState == .running || readinessStartedTicks != nil) {
            graceStartedTicks = now
            // Readiness already has a clock history; do not erase a regression
            // merely because this is its first manual Stop/Quit request.
            if lastObservedTicks == nil { lastObservedTicks = now }
        }
        var effects: [Effect] = []
        if workState == .running, !cancellationRequested, let runID {
            cancellationRequested = true
            effects.append(.requestCancellation(runID: runID))
        }
        effects += hasPendingDeadline ? checkDeadline(now: now) : []
        if !forceExitRequested && workState != .running { effects += finishReturnedWork() }
        return effects
    }

    /// Ignore stale completions/timers from a different run. Completion is
    /// accepted only for the currently unsettled attempt. An idle observation
    /// cannot erase a running owner; use an explicit completed outcome.
    mutating func observe(runID id: UUID, state: WorkState, now: UInt64) -> [Effect] {
        guard runID == id, workState == .running, !exitRequested, state != .idle else { return [] }
        // Check the deadline while the previous state is still running. A
        // completion first observed at/after five seconds is not timely grace.
        let expired = hasPendingDeadline ? checkDeadline(now: now) : []
        workState = state
        if readinessStartedTicks != nil, state != .running { readinessWorkCompleted = true }
        if !expired.isEmpty { return expired }
        return state == .running ? [] : finishReturnedWork()
    }

    mutating func poll(now: UInt64) -> [Effect] {
        guard hasPendingDeadline else { return [] }
        return checkDeadline(now: now)
    }

    private mutating func finishReturnedWork() -> [Effect] {
        guard !exitRequested else { return [] }
        // A late readiness completion cannot race its caller's failure exit
        // with a newly emitted normal-success exit. Its fallback stays armed.
        if readinessStartedTicks != nil && readinessWorkBudgetExpired { return [] }
        if pendingIntent == .quit {
            exitRequested = true
            return [.terminateNormally]
        }
        if pendingIntent == .stop, !stopDelivered {
            stopDelivered = true
            // An early manual Stop may shorten readiness, but even returned
            // work must not remove that earlier bound or its original horizon.
            if readinessStartedTicks == nil {
                graceStartedTicks = nil
                lastObservedTicks = nil
            }
            return [.finishStop(runID: runID)]
        }
        return []
    }

    private mutating func checkDeadline(now: UInt64) -> [Effect] {
        guard !forceExitRequested, let start = readinessStartedTicks ?? graceStartedTicks else { return [] }
        if readinessStartedTicks != nil { readinessObservationTicks = now }
        guard timebaseNumerator != 0, timebaseDenominator != 0 else { return force(.invalidTimebase) }
        guard now >= start, lastObservedTicks.map({ now >= $0 }) ?? true else { return force(.clockRegressed) }
        lastObservedTicks = now
        if let readinessStart = readinessStartedTicks {
            readinessWorkBudgetExpired = elapsed(now - readinessStart, reaches: Self.readinessWorkNanoseconds)
            if readinessWorkBudgetExpired { readinessCanceled = true }
            if elapsed(now - readinessStart, reaches: Self.readinessHorizonNanoseconds) {
                return force(.readinessHorizonExpired)
            }
        }
        if let graceStart = graceStartedTicks {
            guard now >= graceStart else { return force(.clockRegressed) }
            if elapsed(now - graceStart, reaches: Self.graceNanoseconds) { return force(.graceExpired) }
        }
        var effects: [Effect] = []
        if readinessWorkBudgetExpired {
            // No new grace start is sampled here: even the first poll at
            // 14.9 seconds leaves only the original remaining 0.1 seconds.
            if pendingIntent == nil { pendingIntent = .quit }
            if workState == .running, !cancellationRequested, let runID {
                cancellationRequested = true
                effects.append(.requestCancellation(runID: runID))
            }
            if workState != .running { effects += finishReturnedWork() }
        }
        return effects
    }

    private func elapsed(_ ticks: UInt64, reaches nanoseconds: UInt64) -> Bool {
        // Exact two-limb rational comparison; no float, rounded raw-tick
        // deadline, or overflowing start+interval addition (macOS14-compatible).
        let value = ticks.multipliedFullWidth(by: UInt64(timebaseNumerator))
        let limit = nanoseconds.multipliedFullWidth(by: UInt64(timebaseDenominator))
        return value.high > limit.high || (value.high == limit.high && value.low >= limit.low)
    }

    private mutating func force(_ reason: ForceReason) -> [Effect] {
        guard !forceExitRequested else { return [] }
        forceExitRequested = true
        exitRequested = true
        forceReason = reason
        if readinessStartedTicks != nil { readinessCanceled = true }
        if reason == .explicitQuitNow { pendingIntent = .quitNow }
        return [.forceSelfExit70]
    }
}
