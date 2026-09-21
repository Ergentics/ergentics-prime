import Combine
import Darwin
import Foundation
import XCTest

/// Synthetic UI lifecycle tests. This session never launches a model/helper.
@MainActor
private final class SyntheticPrimeTextSession: ErgenticsPrimeTextSession {
    var question = ""
    var checkpointRoot: URL? = URL(fileURLWithPath: "/synthetic/unused-checkpoint")
    var busy = false
    @Published var output = ""
    @Published var status = "Ready"
    var failure: String?
    var report: PrimePromptReport?
    var sends = 0
    var cancellations = 0
    var outputEvents: AnyPublisher<String, Never> { $output.eraseToAnyPublisher() }
    var statusEvents: AnyPublisher<String, Never> { $status.eraseToAnyPublisher() }

    func send() {
        sends += 1
        report = nil; failure = nil; output = ""
        busy = true; status = "Loading Prime…"
    }
    func cancel() {
        guard busy else { return }
        cancellations += 1
        status = "Stopping…"
    }
    func finish(_ text: String) {
        // Match production ordering: busy becomes false before report/final status.
        busy = false
        report = PrimePromptReport(renderedOutput: text, decodedText: text,
            generatedTokenIDs: [100, 101], elapsedSeconds: 0.25, nativeEvidence: Data(),
            resultJSON: Data(), sessionRoot: URL(fileURLWithPath: "/synthetic/not-evidence"))
        output = text
        status = "Finished · 2 tokens · 0.3 seconds"
    }
    func stopped() { busy = false; status = "Stopped" }
}

final class ErgenticsAgentsModelTests: XCTestCase {
    @MainActor
    private static func withFixture(_ body: (ErgenticsAgentsModel, SyntheticPrimeTextSession,
                                            ErgenticsAgentTaskStore, URL) throws -> Void) throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ErgenticsAgentsModelTests-\(UUID().uuidString)", isDirectory: true)
        defer {
            _ = chmod(root.path, 0o700)
            try? FileManager.default.removeItem(at: root)
        }
        let store = ErgenticsAgentTaskStore(directory: root)
        let prime = SyntheticPrimeTextSession()
        let model = ErgenticsAgentsModel(store: store, prime: prime)
        try body(model, prime, store, root)
    }

    func testDraftRestorationAndNewTaskIsolation() async throws {
        try await MainActor.run {
            try Self.withFixture { model, prime, store, _ in
                XCTAssertTrue(model.storageReady)
                let oldID = try XCTUnwrap(model.selectedTaskID)
                model.setComposer("Unsent café λ")
                XCTAssertTrue(model.createTask())
                XCTAssertEqual(model.composerText, "")
                XCTAssertEqual(try store.load().first(where: { $0.id == oldID })?.draft, "Unsent café λ")
                model.selectTask(oldID)
                XCTAssertEqual(model.composerText, "Unsent café λ")
                model.saveLocalDraft()
                let reopened = ErgenticsAgentsModel(store: store, prime: prime)
                XCTAssertEqual(reopened.selectedTaskID, oldID)
                XCTAssertEqual(reopened.composerText, "Unsent café λ")
            }
        }
    }

    func testTerminalEventsKeepRepliesWithTheirRequestsAndIgnoreForeignRuns() async throws {
        try await MainActor.run {
            try Self.withFixture { model, prime, store, _ in
                let taskID = model.selectedTaskID
                model.setComposer("First request")
                model.sendToPrime()
                XCTAssertTrue(model.hasOwnedPrimeRun)
                XCTAssertFalse(model.createTask())
                model.selectTask(nil)
                XCTAssertEqual(model.selectedTaskID, taskID)
                prime.output = "First partial"
                prime.finish("First response")
                XCTAssertFalse(model.hasOwnedPrimeRun)
                XCTAssertEqual(model.selectedTask?.primeRuns?.first?.outcome, .completed)
                XCTAssertEqual(model.selectedTask?.primeRuns?.first?.generatedTokens, 2)
                prime.output = "Foreign response after completion"
                XCTAssertEqual(model.selectedTask?.primeRuns?.first?.output, "First response")
                model.setComposer("Second request")
                model.sendToPrime()
                prime.finish("Second response")
                let task = try XCTUnwrap(try store.load().first)
                XCTAssertEqual(task.messages.count, 2)
                XCTAssertEqual(task.primeRuns?.map(\.output), ["First response", "Second response"])
                XCTAssertEqual(task.primeRuns?.map(\.userMessageID), task.messages.map { Optional($0.id) })
                XCTAssertEqual(prime.sends, 2)
            }
        }
    }

    func testBlankUnavailableAndOversizedRequestsDoNotDispatch() async throws {
        try await MainActor.run {
            try Self.withFixture { model, prime, _, _ in
                model.setComposer(" \n ")
                model.sendToPrime()
                model.setComposer(String(repeating: "😀", count: 256))
                model.sendToPrime()
                prime.checkpointRoot = nil
                model.setComposer("Keep this draft")
                model.sendToPrime()
                XCTAssertEqual(prime.sends, 0)
                XCTAssertFalse(model.hasOwnedPrimeRun)
                XCTAssertEqual(model.selectedTask?.messages.count, 0)
                XCTAssertEqual(model.composerText, "Keep this draft")
            }
        }
    }

    func testWriteFailureDoesNotDispatchOrLoseComposer() async throws {
        try await MainActor.run {
            try Self.withFixture { model, prime, _, root in
                let original = try Data(contentsOf: root.appendingPathComponent("tasks.json"))
                XCTAssertEqual(chmod(root.path, 0o500), 0)
                model.setComposer("Retain this request")
                model.sendToPrime()
                XCTAssertEqual(prime.sends, 0)
                XCTAssertEqual(model.composerText, "Retain this request")
                XCTAssertNotNil(model.persistenceError)
                XCTAssertEqual(try Data(contentsOf: root.appendingPathComponent("tasks.json")), original)
            }
        }
    }

    func testStreamingWriteFailureCancelsOnceWithoutPublisherRecursion() async throws {
        try await MainActor.run {
            try Self.withFixture { model, prime, _, root in
                model.setComposer("Request before storage failure")
                model.sendToPrime()
                let original = try Data(contentsOf: root.appendingPathComponent("tasks.json"))
                XCTAssertEqual(chmod(root.path, 0o500), 0)
                prime.output = "Actual synthetic stream event"
                XCTAssertEqual(prime.cancellations, 1)
                XCTAssertNotNil(model.persistenceError)
                XCTAssertEqual(try Data(contentsOf: root.appendingPathComponent("tasks.json")), original)
                prime.stopped()
                XCTAssertFalse(model.hasOwnedPrimeRun)
                XCTAssertEqual(model.selectedTask?.primeRuns?.last?.outcome, .stopped)
            }
        }
    }

    func testReopenMarksUnfinishedObservationInterruptedAndPreservesCorruption() async throws {
        try await MainActor.run {
            try Self.withFixture { model, prime, store, root in
                model.setComposer("Unfinished request")
                model.sendToPrime()
                let reopened = ErgenticsAgentsModel(store: store, prime: SyntheticPrimeTextSession())
                XCTAssertEqual(reopened.selectedTask?.primeRuns?.last?.outcome, .interrupted)
                let file = root.appendingPathComponent("tasks.json")
                let corrupt = Data("retained invalid draft".utf8)
                try corrupt.write(to: file)
                XCTAssertEqual(chmod(file.path, 0o600), 0)
                let rejected = ErgenticsAgentsModel(store: store, prime: SyntheticPrimeTextSession())
                XCTAssertFalse(rejected.storageReady)
                XCTAssertFalse(rejected.createTask())
                rejected.setComposer("Do not replace prior data")
                rejected.saveLocalDraft()
                XCTAssertEqual(try Data(contentsOf: file), corrupt)
                prime.stopped()
                XCTAssertEqual(try Data(contentsOf: file), corrupt)
            }
        }
    }

    func testRecoveredStoreReopensWithoutReplacingTheOriginal() async throws {
        try await MainActor.run {
            try Self.withFixture { _, _, _, root in
                let suite = "ErgenticsAgentsRecoveryTests-\(UUID().uuidString)"
                let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
                defer { defaults.removePersistentDomain(forName: suite) }
                let file = root.appendingPathComponent("tasks.json")
                let original = Data("retained invalid store".utf8)
                try original.write(to: file)
                let factory: (UUID?) throws -> ErgenticsAgentTaskStore = { id in
                    ErgenticsAgentTaskStore(directory: id.map { root.appendingPathComponent($0.uuidString) } ?? root)
                }
                let rejected = ErgenticsAgentsModel(prime: SyntheticPrimeTextSession(), defaults: defaults, storeFactory: factory)
                XCTAssertFalse(rejected.storageReady)
                rejected.setComposer("Continue in recovery")
                rejected.startRecoveredStore()
                XCTAssertTrue(rejected.storageReady)
                XCTAssertEqual(try Data(contentsOf: file), original)
                let reopened = ErgenticsAgentsModel(prime: SyntheticPrimeTextSession(), defaults: defaults, storeFactory: factory)
                XCTAssertTrue(reopened.storageReady)
                XCTAssertEqual(reopened.selectedTaskID, rejected.selectedTaskID)
                XCTAssertEqual(reopened.composerText, "Continue in recovery")
                XCTAssertEqual(try Data(contentsOf: file), original)
            }
        }
    }

    func testReopenKeepsConversationsWhenNormalizationExceedsStorageBound() async throws {
        try await MainActor.run {
            try Self.withFixture { model, _, store, root in
                model.setComposer("Visible despite a later write failure")
                model.sendToPrime()
                var task = try XCTUnwrap(model.selectedTask)
                let compact = JSONEncoder(); compact.dateEncodingStrategy = .iso8601
                let pretty = JSONEncoder(); pretty.dateEncodingStrategy = .iso8601
                pretty.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
                var prior: Data?
                // A valid compact store can fit the read bound while the new
                // interrupted observation's pretty-printed writeback cannot.
                for _ in 0..<128 {
                    task.messages.append(ErgenticsAgentMessage(id: UUID(), author: .user,
                        text: String(repeating: "x", count: 8_192), createdAt: Date()))
                    let encoded = try compact.encode([task])
                    let expanded = try pretty.encode([task])
                    if encoded.count <= 1_048_576 && expanded.count > 1_048_576 {
                        prior = encoded; break
                    }
                }
                let retained = try XCTUnwrap(prior)
                try retained.write(to: root.appendingPathComponent("tasks.json"))
                XCTAssertEqual(try store.load().first?.messages.count, task.messages.count)
                let reopened = ErgenticsAgentsModel(store: store, prime: SyntheticPrimeTextSession())
                XCTAssertFalse(reopened.storageReady)
                XCTAssertNotNil(reopened.persistenceError)
                XCTAssertEqual(reopened.selectedTask?.messages.first?.text, "Visible despite a later write failure")
                XCTAssertEqual(reopened.selectedTask?.primeRuns?.first?.outcome, .interrupted)
                XCTAssertEqual(try Data(contentsOf: root.appendingPathComponent("tasks.json")), retained)
            }
        }
    }
}
