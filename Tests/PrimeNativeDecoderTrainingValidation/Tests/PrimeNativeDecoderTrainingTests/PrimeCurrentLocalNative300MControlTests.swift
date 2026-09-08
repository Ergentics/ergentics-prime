import Darwin
import Dispatch
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeCurrentLocalNative300MControlTests: XCTestCase {
    private func fixture(_ body: (URL, [String: Any]) throws -> Void) throws {
        // Foundation's resolvingSymlinksInPath may retain the /var spelling;
        // use the actual POSIX path before creating the owned fixture.
        guard let resolved = realpath(FileManager.default.temporaryDirectory.path, nil) else {
            throw Local300MError.rejected("fixture_temporary_parent_realpath")
        }
        let temporaryParent = URL(fileURLWithPath: String(cString: resolved), isDirectory: true)
        free(resolved)
        let root = temporaryParent.appendingPathComponent("prime-current-local-control-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
        defer { try? FileManager.default.removeItem(at: root) }
        let names = ["Package.swift", "Sources/Fixture/Science.swift", "Tests/PrimeNativeDecoderTrainingValidation/Package.swift", "Tests/PrimeNativeDecoderTrainingValidation/Sources/Worker/main.swift"]
        for name in names {
            let url = root.appendingPathComponent(name)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
            try Data("// exact pure fixture \(name)\n".utf8).write(to: url)
        }
        let bindings = try PrimeCurrentLocalNative300MLaunch.sourcePaths(root: root).map { name -> [String: Any] in
            let data = try Data(contentsOf: root.appendingPathComponent(name))
            return ["relativePath": name, "sha256": PrimeSHA256.hexDigest(of: data), "byteCount": data.count, "purpose": "immutable_data"]
        }
        let object: [String: Any] = [
            "schema": "prime_current_local_native300m_launch_v1", "runID": "pure-control-fixture",
            "sourceCommitDeclaration": String(repeating: "a", count: 40), "sourceRoot": root.path,
            "sourceFiles": bindings, "executableAbsolutePath": root.path + "/not-an-admitted-image",
            "executableSHA256": String(repeating: "b", count: 64), "executableByteCount": 1,
            "metallib": ["schemaVersion": 1, "artifactRelativePath": "mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib", "byteCount": 1, "sha256": String(repeating: "c", count: 64)],
            "runRoot": root.path + "/uncreated-run", "stage7WorkerSeconds": 4800,
            "stage7SupervisorSeconds": 5100, "stage8WorkerSeconds": 4800, "stage8SupervisorSeconds": 5100,
        ]
        try body(root, object)
    }

    private func encoded(_ object: [String: Any]) throws -> Data {
        try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes])
    }
    private func launch(_ object: [String: Any]) throws -> PrimeCurrentLocalNative300MLaunch {
        try PrimeCanonicalJSON.decode(PrimeCurrentLocalNative300MLaunch.self, from: encoded(object))
    }

    func testCurrentLocalLaunchRequiresExactInventoryAndFrozenFiniteBudgets() throws {
        try fixture { _, original in
            XCTAssertNoThrow(try launch(original).validateSources())
            for field in ["stage7WorkerSeconds", "stage7SupervisorSeconds", "stage8WorkerSeconds", "stage8SupervisorSeconds"] {
                for bad in [0, 4799, 5101] {
                    var changed = original; changed[field] = bad
                    XCTAssertThrowsError(try launch(changed).validateSources(), field)
                }
            }
            var missing = original
            missing["sourceFiles"] = Array((original["sourceFiles"] as! [[String: Any]]).dropLast())
            XCTAssertThrowsError(try launch(missing).validateSources())
            var duplicate = original
            var files = original["sourceFiles"] as! [[String: Any]]; files.append(files[0]); duplicate["sourceFiles"] = files
            XCTAssertThrowsError(try launch(duplicate).validateSources())
            var wrongHash = original
            files = original["sourceFiles"] as! [[String: Any]]; files[0]["sha256"] = String(repeating: "0", count: 64); wrongHash["sourceFiles"] = files
            XCTAssertThrowsError(try launch(wrongHash).validateSources())
        }
    }

    func testCurrentLocalLaunchRejectsChangedBytesExtraSourceAndSymlink() throws {
        try fixture { root, object in
            let declaration = try launch(object)
            let alias = root.appendingPathComponent("source-root-alias")
            try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: root)
            XCTAssertThrowsError(try PrimeCurrentLocalNative300MLaunch.sourcePaths(root: alias)) { error in
                guard case Local300MError.rejected("source_root_alias") = error else {
                    return XCTFail("Expected exact noncanonical root rejection, got \(error)")
                }
            }
            try FileManager.default.removeItem(at: alias)
            let path = root.appendingPathComponent("Sources/Fixture/Science.swift")
            let original = try Data(contentsOf: path)
            try Data(repeating: 0x78, count: original.count).write(to: path)
            XCTAssertThrowsError(try declaration.validateSources())
            try original.write(to: path)
            XCTAssertNoThrow(try declaration.validateSources())
            let extra = root.appendingPathComponent("Sources/Fixture/Extra.swift")
            try Data("// extra".utf8).write(to: extra)
            XCTAssertThrowsError(try declaration.validateSources())
            try FileManager.default.removeItem(at: extra)
            try FileManager.default.removeItem(at: path)
            try FileManager.default.createSymbolicLink(at: path, withDestinationURL: root.appendingPathComponent("Package.swift"))
            XCTAssertThrowsError(try declaration.validateSources())
        }
    }

    func testCurrentLocalCanonicalRequestRejectsUnknownFieldsBooleanOverflowAndDuplicateKeys() throws {
        try fixture { _, original in
            let bytes = try encoded(original)
            XCTAssertNoThrow(try PrimeCanonicalJSON.decode(PrimeCurrentLocalNative300MLaunch.self, from: bytes))
            var unknown = original; unknown["allowUnbounded"] = true
            XCTAssertThrowsError(try launch(unknown))
            var boolean = original; boolean["stage7WorkerSeconds"] = true
            XCTAssertThrowsError(try launch(boolean))
            var numeric = String(decoding: bytes, as: UTF8.self)
            numeric = numeric.replacingOccurrences(of: "\"stage7WorkerSeconds\":4800", with: "\"stage7WorkerSeconds\":18446744073709551616")
            XCTAssertThrowsError(try PrimeCanonicalJSON.decode(PrimeCurrentLocalNative300MLaunch.self, from: Data(numeric.utf8)))
            let duplicate = Data(("{\"stage7WorkerSeconds\":4800," + String(decoding: bytes.dropFirst(), as: UTF8.self)).utf8)
            XCTAssertThrowsError(try PrimeCanonicalJSON.decode(PrimeCurrentLocalNative300MLaunch.self, from: duplicate))
            XCTAssertThrowsError(try PrimeCanonicalJSON.decode(PrimeCurrentLocalNative300MLaunch.self, from: bytes + Data([10])))
        }
    }

    func testCurrentLocalControllerRejectsWrongCurrentImageBeforeCreatingRun() throws {
        guard #available(macOS 26.0, *) else { return }
        try fixture { root, object in
            let path = root.appendingPathComponent("launch.json")
            try encoded(object).write(to: path)
            try FileManager.default.setAttributes([.posixPermissions: 0o444], ofItemAtPath: path.path)
            XCTAssertThrowsError(try PrimeCurrentLocalNative300MProcessControl(launchURL: path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: object["runRoot"] as! String))
        }
    }
    func testCurrentLocalActualFileDrainRequiresReadWriteDescriptorForFinalHash() throws {
        guard #available(macOS 26.0, *) else { return }
        try fixture { root, _ in
            let bytes = Data("real pipe bytes\nretained progress\n".utf8)
            func drain(path: URL, output: Int32) throws -> PrimeSecureChildFileBackedDrainSnapshot {
                var pipes: [Int32] = [-1, -1]
                guard pipe(&pipes) == 0 else { close(output); throw Local300MError.rejected("fixture_pipe") }
                let captured = PrimeSecureChildFileBackedBoundedDrain(
                    inputDescriptor: pipes[0], outputDescriptor: output, maximumByteCount: 4096)
                let completion = DispatchGroup()
                captured.start(group: completion)
                let written = bytes.withUnsafeBytes { Darwin.write(pipes[1], $0.baseAddress, $0.count) }
                let closed = Darwin.close(pipes[1])
                XCTAssertEqual(written, bytes.count)
                XCTAssertEqual(closed, 0)
                if completion.wait(timeout: .now() + .seconds(5)) != .success {
                    captured.requestStop()
                    XCTAssertEqual(completion.wait(timeout: .now() + .seconds(5)), .success)
                    throw Local300MError.rejected("fixture_drain_timeout")
                }
                XCTAssertEqual(try Data(contentsOf: path), bytes)
                return captured.snapshot()
            }
            let fixedPath = root.appendingPathComponent("read-write-stream.log")
            let fixedFD = try PrimeCurrentLocalNative300MProcessControl.createStreamDescriptor(at: fixedPath.path)
            XCTAssertEqual(fcntl(fixedFD, F_GETFL) & O_ACCMODE, O_RDWR)
            let fixed = try drain(path: fixedPath, output: fixedFD)
            XCTAssertEqual(fixed.terminalReason, .endOfFile)
            XCTAssertTrue(fixed.reachedEOF && fixed.workerFinished && fixed.descriptorsClosed)
            XCTAssertFalse(fixed.overflowed)
            XCTAssertEqual(fixed.totalByteCount, UInt64(bytes.count))
            XCTAssertEqual(fixed.capturedByteCount, UInt64(bytes.count))
            XCTAssertEqual(fixed.outputByteCount, UInt64(bytes.count))
            XCTAssertEqual(fixed.outputSHA256, PrimeSHA256.hexDigest(of: bytes))
            XCTAssertEqual(fixed.outputPermissionMode, 0o444)
            XCTAssertTrue(fixed.outputMetadataObserved && fixed.outputDeviceID > 0 && fixed.outputInode > 0)
            XCTAssertEqual(fixed.readErrorNumber, 0)
            XCTAssertEqual(fixed.writeErrorNumber, 0)
            XCTAssertEqual(fixed.finalizationErrorNumber, 0)
            XCTAssertEqual(fixed.closeErrorNumber, 0)

            // Reproduce the real failed launch's exact wrong access mode.
            let oldPath = root.appendingPathComponent("write-only-stream.log")
            let oldFD = open(oldPath.path, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
            guard oldFD >= 0 else { throw Local300MError.rejected("fixture_write_only_open") }
            let old = try drain(path: oldPath, output: oldFD)
            XCTAssertEqual(old.terminalReason, .writeOrFinalizationError)
            XCTAssertFalse(old.reachedEOF)
            XCTAssertTrue(old.workerFinished && old.descriptorsClosed)
            XCTAssertEqual(old.totalByteCount, UInt64(bytes.count))
            XCTAssertEqual(old.capturedByteCount, UInt64(bytes.count))
            XCTAssertEqual(old.writeErrorNumber, 0)
            XCTAssertEqual(old.finalizationErrorNumber, EIO)
            XCTAssertEqual(old.outputByteCount, 0)
            XCTAssertEqual(old.outputSHA256, "")
        }
    }

}
