import Foundation

/// Launch-local execution authority for the existing fixed checkpoint
/// function. The context owns a one-record namespace, not a root directory,
/// corpus, environment, or arbitrary guest program. Handles are never
/// reconstructed from saved receipts. This assumes trusted application code.
enum GuestH7Execution {
    static let workSeconds = 15

    enum Destination: String, CaseIterable, Sendable {
        case gui, accessibility, retention, network, diagnostic, anotherAgent
    }

    struct Request: Equatable, Sendable {
        var subject: UUID
        var epoch: UUID
        var namespace: UUID
        var purpose: String
        var operation: String
        var record: String
        var fields: [String]
    }

    /// Only the pre-entry gate can construct this projection. The native
    /// adapter accepts this exact fixed function; no unprojected source or
    /// general retrieval callback is available to it.
    struct Input: Sendable {
        let left: UInt64
        let right: UInt64
        let increment: UInt64
        fileprivate init() { left = 19; right = 23; increment = 1 }
    }

    struct VerifiedSource: Sendable {
        let receipt: GuestH3LiveProjectionReceipt
        let request: Request
        fileprivate init(receipt: GuestH3LiveProjectionReceipt, request: Request) {
            self.receipt = receipt; self.request = request
        }
    }

    #if EPR_H4_PRIVACY_TESTS
    static func makeTestSource(_ native: EPRGuestH3CursorResumeResult) throws -> VerifiedSource {
        guard let receipt = try GuestH3LiveVerifier.verify(native).receipt else { throw GuestH8Provenance.Failure.invalid }
        return VerifiedSource(receipt: receipt, request: Context().request)
    }
    #endif

    struct Presentation: Equatable, Sendable {
        let epoch: UUID
        let checkpoint: UInt64
        let resumed: UInt64
        // No native diagnostics, timing, addresses, paths, content hashes,
        // saved-source bytes, or capability handles belong in this delivery.
        fileprivate init(epoch: UUID) { self.epoch = epoch; checkpoint = 42; resumed = 43 }
    }

    enum Status: String, Sendable { case verified, unavailable }
    struct Completion: Sendable {
        let status: Status
        let quarantined: Bool
        func lifecycleCompletion(hasPendingSave: Bool) -> AppLifecyclePolicy.Completion {
            if quarantined { return .quarantined }
            return status == .verified && hasPendingSave ? .conservedVolatile : .recoveryVolatile
        }
    }

    final class Context: @unchecked Sendable {
        let request: Request
        private let lock = NSLock()
        private let now: @Sendable () -> ContinuousClock.Instant
        private let deadline: ContinuousClock.Instant
        private var started = false
        private var canceled = false
        private var candidate: Presentation?
        private var pendingSave: GuestH8Provenance.Pending?
        private var remaining: Set<Destination> = []

        init() {
            now = { .now }
            deadline = .now.advanced(by: .seconds(workSeconds))
            request = Self.fixedRequest()
        }

        #if EPR_H4_PRIVACY_TESTS
        init(testClock: @escaping @Sendable () -> ContinuousClock.Instant) {
            now = testClock
            deadline = testClock().advanced(by: .seconds(workSeconds))
            request = Self.fixedRequest()
        }
        #endif

        private static func fixedRequest() -> Request {
            Request(subject: UUID(), epoch: UUID(), namespace: UUID(),
                purpose: "local-checkpoint-demonstration", operation: "fixed-cursor-resume-v1",
                record: "fixed-operands", fields: ["left", "right", "increment"])
        }

        func cancel() {
            lock.lock(); defer { lock.unlock() }
            canceled = true
            pendingSave?.cancel(); pendingSave = nil
            candidate = nil
            remaining.removeAll()
        }

        /// One exact namespace lookup and projection, before the first
        /// reservation. Unknown and unauthorized records have the same
        /// public result and both enter the native adapter zero times.
        /// Every attempt, including a rejected request, consumes the context.
        func run(_ supplied: Request, attempt: (Input) -> GuestCheckpointAttempt) -> Completion {
            lock.lock()
            let admitted = !started && !canceled && now() < deadline && supplied == request
            // A duplicate racing an admitted operation must not replace its
            // state or disclose its eventual result.
            if started { lock.unlock(); return Completion(status: .unavailable, quarantined: false) }
            started = true
            lock.unlock()
            guard admitted else { return Completion(status: .unavailable, quarantined: false) }

            let result = attempt(Input())
            let quarantined = !result.released || (result.native?.resources_quarantined ?? 0) != 0
            var verified: GuestH3Presentation?
            if !quarantined, let native = result.native {
                // Includes native signing admission, exact 42→43 semantics,
                // both interval budgets, original cursor bytes and teardown.
                verified = try? GuestH3LiveVerifier.verify(native)
            }
            lock.lock(); defer { lock.unlock() }
            guard let receipt = verified?.receipt, !canceled, now() < deadline else {
                candidate = nil
                return Completion(status: .unavailable, quarantined: quarantined)
            }
            candidate = Presentation(epoch: request.epoch)
            remaining = [.gui, .accessibility]
            pendingSave = GuestH8Provenance.Pending(source: VerifiedSource(receipt: receipt, request: request))
            return Completion(status: .verified, quarantined: false)
        }

        /// Transfer a volatile save candidate to the supervisor only after
        /// both screen gates accepted this completion. Save itself remains a
        /// separate explicit persistence action with its own budget/owner.
        func takePendingSave() -> GuestH8Provenance.Pending? {
            lock.lock(); defer { lock.unlock() }
            guard !canceled, now() < deadline, remaining.isEmpty else { return nil }
            let value = pendingSave; pendingSave = nil; return value
        }

        /// Each destination has a separate, one-use delivery. An accepted
        /// GUI delivery supplies no retention, export or cross-agent grant.
        /// Cancellation/expiration clears undelivered projections.
        func take(_ destination: Destination, request supplied: Request) -> Presentation? {
            lock.lock(); defer { lock.unlock() }
            guard !canceled, now() < deadline else {
                candidate = nil; pendingSave?.cancel(); pendingSave = nil; remaining.removeAll(); return nil
            }
            guard supplied == request, remaining.contains(destination), let value = candidate else { return nil }
            remaining.remove(destination)
            if remaining.isEmpty { candidate = nil }
            return value
        }
    }
}
