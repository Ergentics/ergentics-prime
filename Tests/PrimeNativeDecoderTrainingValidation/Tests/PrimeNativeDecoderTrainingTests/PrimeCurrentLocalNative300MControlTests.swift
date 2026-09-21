import Darwin
import Dispatch
import Foundation
import XCTest
@testable import PrimeCore
@testable import PrimeNativeDecoderCheckpoint

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

    func testCurrentLocalComparatorAcceptsRecordedScientificRolesAndRejectsDirectoryAliases() throws {
        typealias Checkpoint = PrimeNativeDecoderNative300MTrajectoryCheckpointV1
        // Actual LIVE03 uninterrupted control bytes (no tensor payloads).
        // This is a pure comparator regression, not a model-execution result.
        // SHA256: 21e5844e29943aa3c6b81d0edd75d9cb23963b07bb83d1bf9b7b37eebb578026
        let left = Data(#"{"branch_role":"uninterrupted_n_plus_1","checked_evaluation_binding":{"batch_token_and_mask_sha256":"e9ed189a1a8a9204cbc4bcf873e5c8b9c25273b6b9bd2e3c22e9279d1945088e","loss_float32_bits":1086154583,"model_catalog_sha256":"12908578a8bdff34cb9bb8aa575d7ef8b2cdfa0c86c779fb105cc827371e6dab","optimizer_first_moment_sha256":"b966448a2bc80a8a04f2d0ff17f7d5598cc12505f6c00a400d3051a62d13825f","optimizer_second_moment_sha256":"423bd23fd41e52cd21f75781235b28d35ed310f3325ac52a6575b6c3047f1874","per_target_loss_sha256":"29d43db56d9e6fa65f5f0db1dfbfa12c0e412c1619802fc1fdf74a997e42d5df","training_mode_restored_true":true,"whole_logits_sha256":"28c03c164d553af12e0a31e70a4174ae7307d0f0517113429dede3f70a0fceea"},"checked_evaluation_read_only_nonmutation_binding":{"post_control_sha256":"818a80ac967340c8078037d4c4e231c853e018f4dbca17efec889f74e08e1a6d","post_model_catalog_sha256":"12908578a8bdff34cb9bb8aa575d7ef8b2cdfa0c86c779fb105cc827371e6dab","post_optimizer_catalog_sha256":"7aae7229c22230c7126c0d35db362ba073512ad9568f044f8208d6a87d2ed493","pre_control_sha256":"818a80ac967340c8078037d4c4e231c853e018f4dbca17efec889f74e08e1a6d","pre_model_catalog_sha256":"12908578a8bdff34cb9bb8aa575d7ef8b2cdfa0c86c779fb105cc827371e6dab","pre_optimizer_catalog_sha256":"7aae7229c22230c7126c0d35db362ba073512ad9568f044f8208d6a87d2ed493","training_mode_restored_true":true},"clip_scale_float32_bits":1038719164,"clipped_gradient_catalog_topology_and_sha256":{"logical_sha256":"d240cf3f3d4eee262d0da7cfe5469cc3c412d137b1ad98db81c733c764c0aa05","path_count":218,"structural_sha256":"deb8b2b2a385aa9c11ab73f8dfb6f400c6846b9f112d0655df9a7bb5920ede33"},"clipped_norm_float32_bits":1065353214,"current_learning_rate_float32_bits":953267991,"decoder_training_mode_true":true,"global_step":2,"loss_float32_bits":1087857479,"optimizer_first_moment_catalog_binding":{"logical_sha256":"b966448a2bc80a8a04f2d0ff17f7d5598cc12505f6c00a400d3051a62d13825f","path_count":218,"structural_sha256":"e4307e46969302aa1dc9d5d6e8240877af2aacc23d5da2fd7372fef9ea788495"},"optimizer_second_moment_catalog_binding":{"logical_sha256":"423bd23fd41e52cd21f75781235b28d35ed310f3325ac52a6575b6c3047f1874","path_count":218,"structural_sha256":"2c87ad2d3df2a4fb6b6f757a6070847a03427e35fa8631ec7f354d4deaf07a55"},"per_target_loss_topology_and_sha256":{"dtype":"float32","sha256":"56739096d53b80e33643a7646ebf961b1fb601797b95260d44783e5cd74c92fe","shape":[1,127]},"post_update_parameter_catalog_binding":{"logical_sha256":"12908578a8bdff34cb9bb8aa575d7ef8b2cdfa0c86c779fb105cc827371e6dab","path_count":218,"structural_sha256":"deb8b2b2a385aa9c11ab73f8dfb6f400c6846b9f112d0655df9a7bb5920ede33"},"raw_gradient_catalog_topology_and_sha256":{"logical_sha256":"4ec32717c0270c26dcff82b3e85565011289e2c2e637e44a8edadf83e7742129","path_count":218,"structural_sha256":"deb8b2b2a385aa9c11ab73f8dfb6f400c6846b9f112d0655df9a7bb5920ede33"},"raw_norm_float32_bits":1091323559,"rng_domains":[{"algorithm_id":"sha256_counter_stream_v1","consumption_sha256":"09a94232c0e287538033a198c102d21e9e66463cc753195463bd6bcea5dbf49d","counter":1,"domain_id":"model_initialization_v1","key_sha256":"81841e917219c7b5f32b1d28f346de8e200944c74db551c4d68b447d640ab7c3"},{"algorithm_id":"sha256_counter_stream_v1","consumption_sha256":"8635f63040d540b810e954758592718d7aa217a8223cd06015bcee7e7bac75cf","counter":2,"domain_id":"training_data_order_v1","key_sha256":"5dac53cfa73ddb616073eb979a105b8670e0032f9f58dcc578c200e01f9fc7e8"},{"algorithm_id":"sha256_counter_stream_v1","consumption_sha256":"63de1106d0a8ec16ea7a25f425b09ab314b6bf8613c59be058609744788845b9","counter":0,"domain_id":"augmentation_v1","key_sha256":"844e82c444546ad5e68ed6aa2b03cb4dc339bbd92890692d0bf6d82f6c101936"},{"algorithm_id":"sha256_counter_stream_v1","consumption_sha256":"be7149ab830966707309adfdf1cba38da5c1e7e5036e98d66962f8c025f0f211","counter":0,"domain_id":"evaluation_v1","key_sha256":"015098b6cc2e83b47ae326da0501cd1478d5b9b556975ef7d5775be569878088"}],"schedule_id":"constant_float32_learning_rate_v1","terminal_data_cursor":{"epoch":1,"next_batch_ordinal":2,"next_row_ids":[],"next_row_ids_sha256":"4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945","next_row_index":2,"no_next_batch_identity":"end_of_exact_two_batch_fixture_no_next_batch_v1","no_next_batch_sha256":"e060fff180d0d64ee23be9ee3a3bbcde166773ad8d207d61f074831258967d7a","schema_id":"prime_native_decoder_native300m_stage7_fixed_two_batch_cursor_v1"},"whole_logits_topology_and_sha256":{"dtype":"float32","sha256":"f582381b9f3001a3012deee8c7eb0297c4e570cffc941c4bee4ebf84895ca39e","shape":[1,128,512]}}"#.utf8)
        let original = try JSONSerialization.jsonObject(with: left) as! [String: Any]
        var resumed = original
        resumed["branch_role"] = "resumed_n_plus_1"
        let right = try encoded(resumed)
        // The recorded resumed control differs only in its scientific role.
        XCTAssertEqual(PrimeSHA256.hexDigest(of: right), "bf86627e3c23258af63add363617274d59383cce72ecc34593f18fb1b817e90c")
        let exact = try Checkpoint.compareComparatorControls(left, right)
        XCTAssertTrue(exact.exact)
        XCTAssertNil(exact.firstMismatchPath)

        XCTAssertThrowsError(try Checkpoint.compareComparatorControls(right, left))
        for role in ["uninterrupted_n_plus_1_comparator", "resumed_n_plus_1_comparator", "baseline_checkpoint", "", "unknown"] {
            var wrongLeft = original; wrongLeft["branch_role"] = role
            XCTAssertThrowsError(try Checkpoint.compareComparatorControls(encoded(wrongLeft), right), role)
            var wrongRight = resumed; wrongRight["branch_role"] = role
            XCTAssertThrowsError(try Checkpoint.compareComparatorControls(left, encoded(wrongRight)), role)
        }
        for field in original.keys where field != "branch_role" {
            var changed = resumed; changed[field] = ["changed": true]
            let mismatch = try Checkpoint.compareComparatorControls(left, encoded(changed))
            XCTAssertFalse(mismatch.exact, field)
            XCTAssertEqual(mismatch.firstMismatchPath, field)
            var missing = resumed; missing.removeValue(forKey: field)
            XCTAssertThrowsError(try Checkpoint.compareComparatorControls(left, encoded(missing)), field)
        }
        var extra = resumed; extra["unexpected_field"] = true
        XCTAssertThrowsError(try Checkpoint.compareComparatorControls(left, encoded(extra)))
        XCTAssertThrowsError(try Checkpoint.compareComparatorControls(left + Data([10]), right))
        XCTAssertThrowsError(try Checkpoint.compareComparatorControls(left, Data()))
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
