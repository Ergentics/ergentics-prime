import AppKit
import Combine
import Foundation

@MainActor
final class PrimePromptModel: ObservableObject {
    static let shared = PrimePromptModel()
    @Published var question = ""
    @Published var maximumNewTokens = 64
    @Published private(set) var busy = false
    @Published private(set) var output = ""
    @Published private(set) var status = "Choose the saved Prime model, then enter a question."
    @Published private(set) var failure: String?
    @Published private(set) var checkpointRoot: URL?
    @Published private(set) var report: PrimePromptReport?
    private var cancellation: PrimeRuntimeCancellation?
    private var completion: Task<Void, Never>?
    private var runID: UUID?
    private var quitPending = false

    init() {
        let bundled = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/PrimeModel", isDirectory: true)
        if FileManager.default.fileExists(atPath: bundled.appendingPathComponent("baseline_checkpoint/weights.safetensors").path) {
            checkpointRoot = bundled
            status = "Ready"
        }
    }

    func chooseCheckpoint() {
        guard !busy else { return }
        let panel = NSOpenPanel()
        panel.title = "Choose Prime model"
        panel.message = "Select the saved artifacts folder containing baseline_checkpoint."
        panel.prompt = "Use model"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if let path = UserDefaults.standard.string(forKey: "PrimePromptLastModelFolder") {
            panel.directoryURL = URL(fileURLWithPath: path, isDirectory: true)
        }
        guard panel.runModal() == .OK, let url = panel.url else { return }
        checkpointRoot = url
        UserDefaults.standard.set(url.path, forKey: "PrimePromptLastModelFolder")
        failure = nil
        status = "Ready"
    }

    func send() {
        guard !busy, let root = checkpointRoot, !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let question = question
        let limit = maximumNewTokens
        let id = UUID()
        let cancellation = PrimeRuntimeCancellation()
        let scoped = root.startAccessingSecurityScopedResource()
        self.cancellation = cancellation
        runID = id
        report = nil
        failure = nil
        output = ""
        busy = true
        status = "Loading Prime…"
        let worker = Task.detached(priority: .userInitiated) { [weak self] in
            try PrimePromptBackend.generate(question: question, maximumNewTokens: limit,
                checkpointRoot: root, cancellation: cancellation) { [weak self] text in
                Task { @MainActor [weak self] in
                    guard let self, self.busy, self.runID == id else { return }
                    self.output = text
                    if !cancellation.isCancelled { self.status = "Generating…" }
                }
            }
        }
        completion = Task { [weak self] in
            let result = await worker.result
            if scoped { root.stopAccessingSecurityScopedResource() }
            guard let self, self.runID == id else { return }
            self.busy = false
            self.cancellation = nil
            self.completion = nil
            switch result {
            case .success(let report):
                self.report = report
                self.output = report.renderedOutput
                self.status = "Finished · \(report.generatedTokenIDs.count) tokens · \(String(format: "%.1f", report.elapsedSeconds)) seconds"
            case .failure(let error as PrimeRuntimeBackend.CleanupFailure):
                self.failure = error.localizedDescription
                self.status = "Shutdown needs attention"
            case .failure(let error as PrimeRuntimeFailure):
                self.failure = error.localizedDescription
                self.status = "Could not complete the response"
            case .failure(let error):
                if cancellation.isCancelled { self.status = "Stopped" }
                else { self.failure = error.localizedDescription; self.status = "Could not complete the response" }
            }
            if self.quitPending { NSApplication.shared.terminate(nil) }
        }
    }

    func cancel() {
        guard busy else { return }
        cancellation?.cancel()
        status = "Stopping…"
    }

    func requestQuit() -> Bool {
        guard busy else { return true }
        quitPending = true
        cancel()
        return false
    }

    func saveResponse() {
        guard let report, !busy else { return }
        let panel = NSSavePanel()
        panel.title = "Save Prime response"
        panel.nameFieldStringValue = "Prime-response.jsonl"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do { try report.nativeEvidence.write(to: url, options: .atomic) }
        catch { failure = error.localizedDescription }
    }
}
