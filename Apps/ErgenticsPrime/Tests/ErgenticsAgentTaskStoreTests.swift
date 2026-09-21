import Darwin
import Foundation
import XCTest

final class ErgenticsAgentTaskStoreTests: XCTestCase {
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ErgenticsAgentTaskStoreTests-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: root.path) { try FileManager.default.removeItem(at: root) }
    }

    func testRoundTripsBoundedUserDraft() throws {
        let store = ErgenticsAgentTaskStore(directory: root)
        var task = ErgenticsAgentTask.fresh(); task.title = "Review custody transition"
        task.messages = [ErgenticsAgentMessage(id: UUID(), author: .user, text: "Prepare the selected task packet.", createdAt: Date())]
        try store.save([task])
        let loaded = try store.load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].id, task.id)
        XCTAssertEqual(loaded[0].messages.map(\.text), ["Prepare the selected task packet."])
        XCTAssertEqual(loaded[0].messages.map(\.author), [.user])
    }

    func testCorruptDraftIsPreservedAndRejected() throws {
        let store = ErgenticsAgentTaskStore(directory: root)
        try store.save([.fresh()])
        let file = root.appendingPathComponent("tasks.json")
        let corrupt = Data("{ malformed".utf8)
        try corrupt.write(to: file, options: .atomic)
        XCTAssertEqual(chmod(file.path, 0o600), 0)
        XCTAssertThrowsError(try store.load())
        XCTAssertEqual(try Data(contentsOf: file), corrupt)
    }

    func testRejectsSymlinkWithoutFollowingIt() throws {
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        XCTAssertEqual(chmod(root.path, 0o700), 0)
        let target = root.deletingLastPathComponent().appendingPathComponent("unrelated.json")
        try Data("[]".utf8).write(to: target, options: .atomic)
        try FileManager.default.createSymbolicLink(at: root.appendingPathComponent("tasks.json"), withDestinationURL: target)
        XCTAssertThrowsError(try ErgenticsAgentTaskStore(directory: root).load()) { error in
            XCTAssertEqual(error as? ErgenticsAgentTaskStore.StoreError, .readFailed)
        }
    }

    func testRejectsOversizeBeforeDecode() throws {
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        XCTAssertEqual(chmod(root.path, 0o700), 0)
        let file = root.appendingPathComponent("tasks.json")
        try Data(repeating: 0x20, count: 1_048_577).write(to: file, options: .atomic)
        XCTAssertEqual(chmod(file.path, 0o600), 0)
        XCTAssertThrowsError(try ErgenticsAgentTaskStore(directory: root).load()) { error in
            XCTAssertEqual(error as? ErgenticsAgentTaskStore.StoreError, .readFailed)
        }
    }

    func testFailedSaveLeavesPriorDraftIntact() throws {
        let store = ErgenticsAgentTaskStore(directory: root)
        var original = ErgenticsAgentTask.fresh(); original.title = "Original"
        try store.save([original])
        XCTAssertEqual(chmod(root.path, 0o755), 0)
        var replacement = ErgenticsAgentTask.fresh(); replacement.title = "Replacement"
        XCTAssertThrowsError(try store.save([replacement]))
        XCTAssertEqual(chmod(root.path, 0o700), 0)
        XCTAssertEqual(try store.load().map(\.title), ["Original"])
    }
}
