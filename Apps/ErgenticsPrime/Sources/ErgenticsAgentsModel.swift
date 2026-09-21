import AppKit
import Combine
import Foundation

/// The workspace observes the existing runner through this small interface.
/// Tests supply synthetic events; the app always uses PrimePromptModel.shared.
@MainActor
protocol ErgenticsPrimeTextSession: AnyObject {
    var question: String { get set }
    var checkpointRoot: URL? { get }
    var busy: Bool { get }
    var output: String { get }
    var status: String { get }
    var failure: String? { get }
    var report: PrimePromptReport? { get }
    var outputEvents: AnyPublisher<String, Never> { get }
    var statusEvents: AnyPublisher<String, Never> { get }
    func send()
    func cancel()
}

extension PrimePromptModel: ErgenticsPrimeTextSession {
    var outputEvents: AnyPublisher<String, Never> { $output.eraseToAnyPublisher() }
    var statusEvents: AnyPublisher<String, Never> { $status.eraseToAnyPublisher() }
}

/// Lazily retained for the app lifetime, including navigation away from Agents.
@MainActor
enum ErgenticsAgentsWorkspace {
    static let model = ErgenticsAgentsModel()
}

@MainActor
final class ErgenticsAgentsModel: ObservableObject {
    @Published private(set) var tasks: [ErgenticsAgentTask] = []
    @Published var selectedTaskID: UUID?
    @Published var composerText = ""
    @Published var expandedActivity = false
    @Published var expandedInspector = false
    @Published var expandedDefinitions = false
    @Published private(set) var persistenceError: String?
    @Published private(set) var exportStatus: String?
    @Published private(set) var libraryError: String?
    @Published private(set) var storageReady = false

    let library: ErgenticsAgentLibrary?
    private var store: ErgenticsAgentTaskStore?
    let prime: any ErgenticsPrimeTextSession
    private var subscriptions = Set<AnyCancellable>()
    private var activePrimeRun: (taskID: UUID, runID: UUID)?
    private var runPersistenceFailed = false
    private let defaults: UserDefaults
    private let storeFactory: (UUID?) throws -> ErgenticsAgentTaskStore
    private static let recoveryKey = "ErgenticsAgentsRecoveredStoreID"

    init(library: ErgenticsAgentLibrary? = nil, store: ErgenticsAgentTaskStore? = nil,
         prime: any ErgenticsPrimeTextSession = PrimePromptModel.shared,
         defaults: UserDefaults = .standard,
         storeFactory: @escaping (UUID?) throws -> ErgenticsAgentTaskStore = {
             try ErgenticsAgentTaskStore.appContainer(recoveryID: $0)
         }) {
        self.prime = prime
        self.defaults = defaults
        self.storeFactory = storeFactory
        if let library { self.library = library }
        else {
            do {
                guard let resources = Bundle.main.resourceURL else { throw ErgenticsAgentLibraryError.invalidRoot }
                self.library = try ErgenticsAgentLibrary.load(root: resources.appendingPathComponent("ErgenticsAgents", isDirectory: true),
                                                              expectedCatalogSHA256: ErgenticsAgentCatalogIdentity.sha256)
            } catch { self.library = nil; self.libraryError = error.localizedDescription }
        }
        do {
            let resolved: ErgenticsAgentTaskStore
            if let store { resolved = store }
            else {
                let recoveryID: UUID?
                if let saved = defaults.string(forKey: Self.recoveryKey) {
                    guard let id = UUID(uuidString: saved) else { throw CocoaError(.fileReadCorruptFile) }
                    recoveryID = id
                } else { recoveryID = nil }
                resolved = try storeFactory(recoveryID)
            }
            self.store = resolved
            let loaded = try resolved.load()
            let normalized = loaded.map { task -> ErgenticsAgentTask in
                var value = task
                value.primeRuns = (value.primeRuns ?? []).map { run in
                    guard run.outcome == .running else { return run }
                    var interrupted = run
                    interrupted.outcome = .interrupted
                    interrupted.status = "Interrupted before this app reopened; completion was not observed."
                    return interrupted
                }
                return value
            }
            // Keep successfully read conversations visible even if recording
            // the interrupted state fails. Saving remains held in that case.
            self.tasks = normalized
            self.selectedTaskID = normalized.first?.id
            self.composerText = normalized.first?.draft ?? ""
            if normalized != loaded { try resolved.save(normalized) }
            self.storageReady = true
        } catch {
            self.store = store
            self.persistenceError = "Saved drafts were not changed: \(error.localizedDescription) Start a recovered local store to save new work."
        }
        if storageReady && tasks.isEmpty { _ = createTask() }
        observePrime()
    }

    var selectedTask: ErgenticsAgentTask? { selectedTaskID.flatMap { id in tasks.first { $0.id == id } } }
    var profiles: [ErgenticsAgentProfile] { library?.profiles ?? [] }
    var selectedProfile: ErgenticsAgentProfile? { selectedTask.flatMap { task in profiles.first { $0.id == task.profileID } } }
    var eligibleLessons: [ErgenticsAgentLesson] { guard let task = selectedTask else { return [] }; return (library?.lessons ?? []).filter { $0.profileIDs.contains(task.profileID) } }
    var hasOwnedPrimeRun: Bool { activePrimeRun != nil }
    var ownedPrimeStatus: String? {
        guard let activePrimeRun, let task = tasks.first(where: { $0.id == activePrimeRun.taskID }) else { return nil }
        return task.primeRuns?.first(where: { $0.id == activePrimeRun.runID })?.status
    }

    @discardableResult func createTask() -> Bool {
        guard storageReady, !hasOwnedPrimeRun else { return false }
        guard tasks.count < 40 else { persistenceError = "The current local store already has 40 tasks."; return false }
        if let oldID = selectedTaskID {
            let savedOldDraft = commit { values in
                guard let index = values.firstIndex(where: { $0.id == oldID }) else { return }
                values[index].draft = composerText.isEmpty ? nil : String(composerText.prefix(8_192))
                values[index].updatedAt = Date()
            }
            guard savedOldDraft else { return false }
        }
        let task = ErgenticsAgentTask.fresh(profileID: profiles.first?.id ?? "ergentics_swift_c")
        let saved = commit { values in values.insert(task, at: 0) }
        if saved { selectedTaskID = task.id; composerText = "" }
        return saved
    }

    func selectTask(_ id: UUID?) {
        guard !hasOwnedPrimeRun else { return }
        if let oldID = selectedTaskID, storageReady {
            let saved = commit { values in
                guard let index = values.firstIndex(where: { $0.id == oldID }) else { return }
                values[index].draft = composerText.isEmpty ? nil : String(composerText.prefix(8_192))
                values[index].updatedAt = Date()
            }
            guard saved else { return }
        }
        selectedTaskID = id
        composerText = selectedTask?.draft ?? ""
    }

    func setComposer(_ text: String) { composerText = String(text.prefix(8_192)) }

    func saveLocalDraft() {
        guard storageReady, let id = selectedTaskID else { return }
        let saved = commit { values in
            guard let index = values.firstIndex(where: { $0.id == id }) else { return }
            values[index].draft = composerText.isEmpty ? nil : composerText
            values[index].updatedAt = Date()
        }
        exportStatus = saved ? "Local message draft saved. Sending to Prime remains a separate action." : nil
    }

    func startRecoveredStore() {
        guard !hasOwnedPrimeRun else { return }
        do {
            let recoveryID = UUID()
            let recovered = try storeFactory(recoveryID)
            var task = ErgenticsAgentTask.fresh(profileID: selectedTask?.profileID ?? profiles.first?.id ?? "ergentics_swift_c")
            task.draft = composerText.isEmpty ? nil : composerText
            try recovered.save([task])
            // Bind reopening only after the new store has saved successfully.
            defaults.set(recoveryID.uuidString.lowercased(), forKey: Self.recoveryKey)
            store = recovered; tasks = [task]; selectedTaskID = task.id
            storageReady = true; persistenceError = nil; runPersistenceFailed = false
            exportStatus = "Recovered local store saved. Earlier files remain unchanged."
        } catch { persistenceError = error.localizedDescription }
    }

    @discardableResult func updateTask(_ transform: (inout ErgenticsAgentTask) -> Void) -> Bool {
        guard storageReady, !hasOwnedPrimeRun, let id = selectedTaskID else { return false }
        return commit { values in
            guard let index = values.firstIndex(where: { $0.id == id }) else { return }
            transform(&values[index]); values[index].updatedAt = Date()
        }
    }

    func sendToPrime() {
        let text = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, storageReady, !hasOwnedPrimeRun, !prime.busy, prime.checkpointRoot != nil else {
            exportStatus = prime.checkpointRoot == nil ? "Choose the retained Prime checkpoint before sending." : nil
            return
        }
        guard text.utf8.count <= 4_096, text.precomposedStringWithCanonicalMapping.utf8.count <= 1_023 else { exportStatus = "Prime accepts at most 4,096 input bytes and 1,023 canonical UTF-8 bytes."; return }
        guard let taskID = selectedTaskID else { return }
        let messageID = UUID()
        let run = ErgenticsAgentPrimeRun(id: UUID(), input: text, output: "", status: "Starting local Prime experiment…",
                                         outcome: .running, startedAt: Date(), completedAt: nil, generatedTokens: nil,
                                         elapsedSeconds: nil, userMessageID: messageID)
        let stored = commit { values in
            guard let index = values.firstIndex(where: { $0.id == taskID }) else { return }
            values[index].messages.append(ErgenticsAgentMessage(id: messageID, author: .user, text: text, createdAt: Date()))
            values[index].draft = nil
            values[index].primeRuns = (values[index].primeRuns ?? []) + [run]
            if values[index].title == "New local task" { values[index].title = String(text.prefix(64)) }
            values[index].updatedAt = Date()
        }
        guard stored else { return } // Composer remains intact; no inference begins without persisted input.
        composerText = ""; activePrimeRun = (taskID, run.id); runPersistenceFailed = false
        prime.question = text; prime.send()
        // A synchronous startup event can encounter a save failure before the
        // runner sets busy. Ensure that accepted work is then stopped.
        if runPersistenceFailed && prime.busy { prime.cancel() }
    }

    func stopPrime() { guard hasOwnedPrimeRun else { return }; prime.cancel() }

    func toggleLesson(_ lesson: ErgenticsAgentLesson) {
        _ = updateTask { task in
            if let index = task.selectedLessonIDs.firstIndex(of: lesson.id) { task.selectedLessonIDs.remove(at: index) }
            else if task.selectedLessonIDs.count < 8 { task.selectedLessonIDs.append(lesson.id) }
            else { exportStatus = "A task can select at most eight reviewed lessons." }
        }
    }

    func exportPreparedTask() {
        guard let library, let task = selectedTask else { libraryError = "Verified profile resources are not available in this view yet."; return }
        do {
            let visibleDraft = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
            let storedDraft = task.draft?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let preparationText = !visibleDraft.isEmpty ? visibleDraft : (!storedDraft.isEmpty ? storedDraft : task.title)
            let data = try library.prepareTask(profileID: task.profileID, task: preparationText,
                                               lessonIDs: task.selectedLessonIDs, requestedModel: task.requestedModel)
            let panel = NSSavePanel(); panel.title = "Export prepared Ergentics task"
            panel.nameFieldStringValue = "Ergentics-task-\(task.id.uuidString.prefix(8)).json"
            panel.allowedContentTypes = [.json]
            guard panel.runModal() == .OK, let destination = panel.url else { exportStatus = "Export cancelled; no file was written."; return }
            try data.write(to: destination, options: [.atomic])
            exportStatus = "Prepared task exported. Preparation does not execute a profile or model."
        } catch { exportStatus = error.localizedDescription }
    }

    func instructionText(_ path: String) -> String? { do { return try library?.text(at: path) } catch { libraryError = error.localizedDescription; return nil } }

    private func observePrime() {
        prime.outputEvents.sink { [weak self] output in self?.recordPrimeOutput(output) }.store(in: &subscriptions)
        prime.statusEvents.sink { [weak self] status in self?.recordPrimeStatus(status) }.store(in: &subscriptions)
    }

    private func recordPrimeOutput(_ output: String) {
        guard let activePrimeRun else { return }
        mutateRun(activePrimeRun, output: output, status: prime.status, outcome: .running, completion: nil)
    }

    private func recordPrimeStatus(_ status: String) {
        guard let activePrimeRun else { return }
        if !prime.busy && isTerminal(status) { completePrimeRun(status, key: activePrimeRun) }
        else { mutateRun(activePrimeRun, output: prime.output, status: status, outcome: .running, completion: nil) }
    }

    private func isTerminal(_ status: String) -> Bool {
        status == "Stopped" || status == "Shutdown needs attention" || status == "Could not complete the response" || status.hasPrefix("Finished ·")
    }

    private func completePrimeRun(_ status: String, key activePrimeRun: (taskID: UUID, runID: UUID)) {
        let outcome: ErgenticsAgentPrimeRun.Outcome
        if prime.failure != nil { outcome = .failed }
        else if status == "Stopped" { outcome = .stopped }
        else { outcome = .completed }
        let report = prime.report
        mutateRun(activePrimeRun, output: prime.output, status: prime.failure ?? status, outcome: outcome,
                  completion: (Date(), report?.generatedTokenIDs.count, report?.elapsedSeconds))
        self.activePrimeRun = nil
    }

    private func mutateRun(_ key: (taskID: UUID, runID: UUID), output: String, status: String,
                           outcome: ErgenticsAgentPrimeRun.Outcome, completion: (Date, Int?, Double?)?) {
        let change: (inout [ErgenticsAgentTask]) -> Void = { values in
            guard let taskIndex = values.firstIndex(where: { $0.id == key.taskID }),
                  let runIndex = values[taskIndex].primeRuns?.firstIndex(where: { $0.id == key.runID }) else { return }
            values[taskIndex].primeRuns?[runIndex].output = output
            values[taskIndex].primeRuns?[runIndex].status = status
            values[taskIndex].primeRuns?[runIndex].outcome = outcome
            if let completion { values[taskIndex].primeRuns?[runIndex].completedAt = completion.0; values[taskIndex].primeRuns?[runIndex].generatedTokens = completion.1; values[taskIndex].primeRuns?[runIndex].elapsedSeconds = completion.2 }
            values[taskIndex].updatedAt = Date()
        }
        if runPersistenceFailed {
            // Keep observing cleanup in memory. The visible persistence error
            // remains until a later successful explicit edit can save again.
            var observed = tasks; change(&observed); tasks = observed
            return
        }
        let saved = commit(allowDuringRun: true, change)
        if !saved {
            runPersistenceFailed = true // Set before cancel publishes another status.
            var observed = tasks; change(&observed); tasks = observed
            prime.cancel()
        }
    }

    private func commit(allowDuringRun: Bool = false, _ transform: (inout [ErgenticsAgentTask]) -> Void) -> Bool {
        guard storageReady, let store, (allowDuringRun || !hasOwnedPrimeRun) else { return false }
        var candidate = tasks; transform(&candidate)
        do { try store.save(candidate); tasks = candidate.sorted { $0.updatedAt > $1.updatedAt }; persistenceError = nil; return true }
        catch { persistenceError = error.localizedDescription; return false }
    }
}
