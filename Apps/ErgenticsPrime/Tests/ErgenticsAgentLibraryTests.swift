import CryptoKit
import Darwin
import Foundation
import XCTest

final class ErgenticsAgentLibraryTests: XCTestCase {
    private let sourceCommit = String(repeating: "a", count: 40)

    private func hash(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func makeFixture() throws -> (root: URL, catalogHash: String) {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ErgenticsAgentLibraryTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let resources: [(String, Data)] = [
            ("instructions/common.md", Data("# Ergentics C++ — instructions\n".utf8)),
            ("skills/custody.md", Data("Preserve exact evidence: café λ\n".utf8)),
            ("lessons/prime.md", Data("Prime gate lesson — admission is separate from qualification.\n".utf8)),
        ]
        for (path, data) in resources {
            let url = root.appendingPathComponent(path)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
        }
        let resourceRows = resources.map { path, data in
            ["path": path, "bytes": data.count, "sha256": hash(data)] as [String: Any]
        }
        let profiles: [[String: Any]] = [
            ["id": "ergentics_swift_c", "version": "0.1.0", "name": "Ergentics Swift + C",
             "purpose": "Swift and C boundaries", "instructionPaths": ["instructions/common.md"],
             "skillPaths": ["skills/custody.md"], "defaultLessonIDs": ["prime-gate-phase-custody"]],
            ["id": "ergentics_cpp", "version": "0.1.0", "name": "Ergentics C/C++",
             "purpose": "C/C++ ownership and checked computation", "instructionPaths": ["instructions/common.md"],
             "skillPaths": ["skills/custody.md"], "defaultLessonIDs": ["prime-gate-phase-custody"]],
        ]
        let lessons: [[String: Any]] = [[
            "id": "prime-gate-phase-custody", "version": "0.1.0", "name": "Prime gate phase custody",
            "path": "lessons/prime.md", "kind": "lesson", "profileIDs": ["ergentics_swift_c", "ergentics_cpp"],
        ]]
        let object: [String: Any] = ["schema": "ergentics.hypervisor-agent-catalog.v1", "version": "0.1.0",
                                      "owner": "Ergentics, LLC", "sourceCommit": sourceCommit,
                                      "resources": resourceRows, "profiles": profiles, "lessons": lessons]
        let catalog = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes])
        try catalog.write(to: root.appendingPathComponent("catalog.json"), options: .atomic)
        return (root, hash(catalog))
    }

    private func assertThrows(_ body: () throws -> Void) {
        XCTAssertThrowsError(try body())
    }

    func testLoadVerifiesUTF8AndPreparationIdentity() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let library = try ErgenticsAgentLibrary.load(root: fixture.root, expectedCatalogSHA256: fixture.catalogHash)
        XCTAssertEqual(library.profiles.map(\.id).sorted(), ["ergentics_cpp", "ergentics_swift_c"])
        XCTAssertTrue(try library.text(at: "skills/custody.md").contains("café λ"))
        let data = try library.prepareTask(profileID: "ergentics_cpp", task: "Review the Prime gate.",
                                           lessonIDs: ["prime-gate-phase-custody"], requestedModel: "gpt-5.6-luna")
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["schema"] as? String, "ergentics.hypervisor-agent-task.v1")
        XCTAssertEqual(object["task"] as? String, "Review the Prime gate.")
        XCTAssertEqual((object["requested"] as? [String: Any])?["model"] as? String, "gpt-5.6-luna")
        XCTAssertEqual((object["execution"] as? [String: Any])?["modelDispatch"] as? String, "NOT_PERFORMED")
        XCTAssertEqual((object["catalog"] as? [String: Any])?["sha256"] as? String, fixture.catalogHash)
        XCTAssertEqual((object["lessons"] as? [[String: Any]])?.first?["text"] as? String,
                       "Prime gate lesson — admission is separate from qualification.\n")
    }

    func testRejectsCatalogHashTraversalAndResourceDrift() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        assertThrows { _ = try ErgenticsAgentLibrary.load(root: fixture.root, expectedCatalogSHA256: String(repeating: "0", count: 64)) }

        let outside = fixture.root.deletingLastPathComponent().appendingPathComponent("outside.md")
        try Data("outside".utf8).write(to: outside)
        defer { try? FileManager.default.removeItem(at: outside) }
        let originalCatalog = try Data(contentsOf: fixture.root.appendingPathComponent("catalog.json"))
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: originalCatalog) as? [String: Any])
        object["resources"] = [["path": "../outside.md", "bytes": 7, "sha256": hash(Data("outside".utf8))]]
        let traversalCatalog = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes])
        try traversalCatalog.write(to: fixture.root.appendingPathComponent("catalog.json"), options: .atomic)
        assertThrows { _ = try ErgenticsAgentLibrary.load(root: fixture.root, expectedCatalogSHA256: hash(traversalCatalog)) }

        try originalCatalog.write(to: fixture.root.appendingPathComponent("catalog.json"), options: .atomic)
        try Data("changed".utf8).write(to: fixture.root.appendingPathComponent("skills/custody.md"), options: .atomic)
        assertThrows { _ = try ErgenticsAgentLibrary.load(root: fixture.root, expectedCatalogSHA256: hash(originalCatalog)) }

        let bounded = try makeFixture()
        defer { try? FileManager.default.removeItem(at: bounded.root) }
        var oversized = try XCTUnwrap(JSONSerialization.jsonObject(with: originalCatalog) as? [String: Any])
        oversized["resources"] = [["path": "instructions/common.md", "bytes": Int.max,
                                    "sha256": hash(Data("# Ergentics C++ — instructions\n".utf8))]]
        let oversizedCatalog = try JSONSerialization.data(withJSONObject: oversized,
                                                           options: [.sortedKeys, .withoutEscapingSlashes])
        try oversizedCatalog.write(to: bounded.root.appendingPathComponent("catalog.json"), options: .atomic)
        assertThrows { _ = try ErgenticsAgentLibrary.load(root: bounded.root, expectedCatalogSHA256: hash(oversizedCatalog)) }

        var nulPath = try XCTUnwrap(JSONSerialization.jsonObject(with: originalCatalog) as? [String: Any])
        nulPath["resources"] = [["path": "instructions/\u{0}bad.md", "bytes": 1,
                                  "sha256": hash(Data("x".utf8))]]
        let nulCatalog = try JSONSerialization.data(withJSONObject: nulPath,
                                                     options: [.sortedKeys, .withoutEscapingSlashes])
        try nulCatalog.write(to: bounded.root.appendingPathComponent("catalog.json"), options: .atomic)
        assertThrows { _ = try ErgenticsAgentLibrary.load(root: bounded.root, expectedCatalogSHA256: hash(nulCatalog)) }
    }

    func testRejectsSymlinkWrongProfileAndInputLimits() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let target = fixture.root.appendingPathComponent("lessons/prime.md")
        let replacement = fixture.root.appendingPathComponent("lessons/prime-original.md")
        try FileManager.default.moveItem(at: target, to: replacement)
        try FileManager.default.createSymbolicLink(at: target, withDestinationURL: replacement)
        assertThrows { _ = try ErgenticsAgentLibrary.load(root: fixture.root, expectedCatalogSHA256: fixture.catalogHash) }

        let fresh = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fresh.root) }
        let originalCatalog = try Data(contentsOf: fresh.root.appendingPathComponent("catalog.json"))
        var wrongProfileCatalog = try XCTUnwrap(JSONSerialization.jsonObject(with: originalCatalog) as? [String: Any])
        wrongProfileCatalog["lessons"] = [["id": "prime-gate-phase-custody", "version": "0.1.0",
                                            "name": "Prime gate phase custody", "path": "lessons/prime.md",
                                            "kind": "lesson", "profileIDs": ["ergentics_swift_c"]]]
        var wrongProfileProfiles = try XCTUnwrap(wrongProfileCatalog["profiles"] as? [[String: Any]])
        wrongProfileProfiles[1]["defaultLessonIDs"] = []
        wrongProfileCatalog["profiles"] = wrongProfileProfiles
        let wrongProfileBytes = try JSONSerialization.data(withJSONObject: wrongProfileCatalog,
                                                            options: [.sortedKeys, .withoutEscapingSlashes])
        try wrongProfileBytes.write(to: fresh.root.appendingPathComponent("catalog.json"), options: .atomic)
        let library = try ErgenticsAgentLibrary.load(root: fresh.root, expectedCatalogSHA256: hash(wrongProfileBytes))
        assertThrows { _ = try library.prepareTask(profileID: "ergentics_cpp", task: "x", lessonIDs: ["prime-gate-phase-custody"], requestedModel: "local") }
        assertThrows { _ = try library.prepareTask(profileID: "ergentics_cpp", task: "x", lessonIDs: ["unknown"], requestedModel: "local") }
        assertThrows { _ = try library.prepareTask(profileID: "ergentics_cpp", task: String(repeating: "x", count: 8193), lessonIDs: [], requestedModel: "local") }
        assertThrows { _ = try library.prepareTask(profileID: "ergentics_cpp", task: "x", lessonIDs: [], requestedModel: String(repeating: "m", count: 129)) }
    }
}
