import AppKit
import Combine
import Foundation

@MainActor
final class PrimeRuntimeModel: ObservableObject {
    @Published private(set) var busy = false
    @Published private(set) var status = "Ready to check the native runtime"
    @Published private(set) var report: PrimeRuntimeReport?
    @Published private(set) var failure: String?
    private var cancellation: PrimeRuntimeCancellation?
    private var completion: Task<Void, Never>?
    private var quitPending = false
    private let checker: @Sendable (PrimeRuntimeCancellation) throws -> PrimeRuntimeReport
    private let finishQuit: @MainActor () -> Void

    init(checker: @escaping @Sendable (PrimeRuntimeCancellation) throws -> PrimeRuntimeReport = PrimeRuntimeBackend.check,
         finishQuit: @escaping @MainActor () -> Void = { NSApplication.shared.terminate(nil) }) {
        self.checker = checker
        self.finishQuit = finishQuit
    }

    @discardableResult
    func check() -> Task<Void, Never>? {
        guard !busy else { return nil }
        let cancellation = PrimeRuntimeCancellation()
        self.cancellation = cancellation
        report = nil; failure = nil; busy = true
        status = "Checking Prime on the GPU…"
        let checker = self.checker
        let worker = Task.detached(priority: .utility) { try checker(cancellation) }
        let completion = Task { [weak self] in
            let result = await worker.result
            guard let self else { return }
            self.busy = false; self.cancellation = nil; self.completion = nil
            if case .failure(let error as PrimeRuntimeBackend.CleanupFailure) = result {
                self.failure = error.localizedDescription
                self.status = "Runtime shutdown needs attention"
            } else if cancellation.isCancelled { self.status = "Cancelled" }
            else {
                switch result {
                case .success(let report): self.report = report; self.status = "Native runtime ready"
                case .failure(let error): self.failure = error.localizedDescription; self.status = "Runtime check failed"
                }
            }
            if self.quitPending { self.finishQuit() }
        }
        self.completion = completion
        return completion
    }

    func cancel() {
        guard busy else { return }
        cancellation?.cancel()
        status = "Stopping Prime…"
    }

    func saveReport() {
        guard let report, !busy else { return }
        let panel = NSSavePanel()
        panel.title = "Save Prime runtime result"
        panel.nameFieldStringValue = "Prime-runtime.json"
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try report.nativeEvidence.write(to: url, options: .atomic)
            failure = nil
        }
        catch { failure = "Could not save the runtime result: \(error.localizedDescription)" }
    }

    func requestQuit() -> Bool {
        guard busy else { return true }
        quitPending = true
        cancel()
        return false
    }
}
