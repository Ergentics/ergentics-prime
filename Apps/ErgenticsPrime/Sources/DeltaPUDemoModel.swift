import Combine
import Foundation

/// Owns only volatile synthetic demonstration state. No app-admission token,
/// native handle, journal, timer or termination delegate is held here.
@MainActor
final class DeltaPUDemoModel: ObservableObject {
    enum Phase: String, Equatable {
        case idle = "Ready"
        case running = "Computing and verifying"
        case cancelling = "Cancellation requested"
        case cancelled = "Cancelled"
        case verified = "Verified CPU result"
        case failed = "Verification failed"
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var report: DeltaPUDemoReport?
    @Published private(set) var failureMessage: String?
    private var worker: Task<DeltaPUDemoReport, Error>?
    private var completion: Task<Void, Never>?
    private var cancellationRequested = false

    var busy: Bool { phase == .running || phase == .cancelling }

    /// Synchronous admission: nil means busy or already cancelled. The
    /// returned Swift task completes observation, not an execution authority.
    /// The worker is installed before this method returns. There is no
    /// alternate callback/injected executor or input beyond the closed enum.
    @discardableResult
    func run(_ scenario: DeltaPUDemoScenario) -> Task<Void, Never>? {
        guard worker == nil else { return nil }
        report = nil
        failureMessage = nil
        guard !Task.isCancelled else { phase = .cancelled; return nil }
        cancellationRequested = false
        let execution = Task.detached(priority: .userInitiated) {
            try Task.checkCancellation()
            return try await DeltaPUDemonstration.run(scenario)
        }
        worker = execution
        phase = .running
        let observation = Task { @MainActor [weak self] in
            let result = await withTaskCancellationHandler {
                await execution.result
            } onCancel: {
                // Detached tasks do not inherit later observer cancellation.
                execution.cancel()
            }
            guard let self else { return }
            self.worker = nil
            self.completion = nil
            guard !self.cancellationRequested, !execution.isCancelled, !Task.isCancelled else {
                self.phase = .cancelled
                return
            }
            switch result {
            case .success(let value):
                self.report = value
                self.phase = .verified
            case .failure(let error):
                if error is CancellationError {
                    self.phase = .cancelled
                } else {
                    self.failureMessage = String(describing: error)
                    self.phase = .failed
                }
            }
        }
        completion = observation
        return observation
    }

    func cancel() {
        guard let worker else { return }
        cancellationRequested = true
        phase = .cancelling
        worker.cancel()
        // Keep admission closed until this bounded worker returns. App Quit
        // does not call or await this method; there is no shutdown veto.
    }

    @discardableResult
    func clear() -> Bool {
        guard worker == nil else { return false }
        report = nil
        failureMessage = nil
        phase = .idle
        return true
    }
}
