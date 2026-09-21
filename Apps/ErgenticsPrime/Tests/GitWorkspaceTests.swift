import Darwin
import Foundation
import XCTest
#if canImport(GitCore)
@testable import GitCore
#endif

final class GitWorkspaceTests: XCTestCase {
    func testExecutableSelectionNeverUsesSystemShimOrPathSearch() throws {
        var checked: [String] = []
        let path = try GitWorkspaceExecutable.select { candidate in
            checked.append(candidate)
            return true
        }
        XCTAssertEqual(path, "/Applications/Xcode.app/Contents/Developer/usr/bin/git")
        XCTAssertEqual(checked, [path])
        XCTAssertFalse(GitWorkspaceExecutable.candidates.contains("/usr/bin/git"))
    }

    func testExecutableSelectionFallsBackOnlyToValidatedCommandLineTools() throws {
        var checked: [String] = []
        let path = try GitWorkspaceExecutable.select { candidate in
            checked.append(candidate)
            return candidate == "/Library/Developer/CommandLineTools/usr/bin/git"
        }
        XCTAssertEqual(path, "/Library/Developer/CommandLineTools/usr/bin/git")
        XCTAssertEqual(checked, GitWorkspaceExecutable.candidates)
    }

    func testExecutableSelectionRejectsMissingOrUntrustedCandidates() {
        var checked: [String] = []
        XCTAssertThrowsError(try GitWorkspaceExecutable.select { candidate in
            checked.append(candidate)
            return false
        }) { error in
            XCTAssertTrue(error.localizedDescription.contains("Apple-signed Git"))
        }
        XCTAssertEqual(checked, GitWorkspaceExecutable.candidates)
    }

    func testInstalledExecutablePassesTheAppleGitRequirement() throws {
        let path = try GitWorkspaceExecutable.resolve()
        XCTAssertTrue(GitWorkspaceExecutable.candidates.contains(path))
        XCTAssertNotEqual(path, "/usr/bin/git")
    }

    private func fixture(_ body: (URL) throws -> Void) throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("GitWorkspaceTests-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
        defer { try? FileManager.default.removeItem(at: root) }
        _ = try git(root, ["init", "--initial-branch=main"])
        try body(root.resolvingSymlinksInPath())
    }

    @discardableResult private func git(_ root: URL, _ args: [String]) throws -> Data {
        let result = try GitWorkspaceCommand.run(root: root, arguments: args, cancellation: .init())
        XCTAssertEqual(result.status, 0, String(decoding: result.stderr, as: UTF8.self))
        return result.stdout
    }

    private func snapshot(_ root: URL) throws -> GitWorkspaceSnapshot {
        try GitWorkspaceBackend.snapshot(root: root, cancellation: .init())
    }

    func testNewEmptyRepositoryHasNoHistoryAndNoChanges() throws {
        try fixture { root in
            let value = try snapshot(root)
            XCTAssertEqual(value.branch, "main")
            XCTAssertNil(value.head)
            XCTAssertTrue(value.changes.isEmpty)
            XCTAssertTrue(value.history.isEmpty)
            XCTAssertNil(value.writeBlock)
        }
    }

    func testUnstageBeforeFirstCommitPreservesNewerWorkingFileBytes() throws {
        try fixture { root in
            let file = root.appendingPathComponent("file")
            try Data("staged\n".utf8).write(to: file)
            var current = try snapshot(root)
            current = try GitWorkspaceBackend.edit(root: root, action: .stage(current.changes[0]), cancellation: .init())
            try Data("newer working bytes\n".utf8).write(to: file)
            current = try snapshot(root)
            XCTAssertEqual(current.changes[0].code, "AM")
            current = try GitWorkspaceBackend.edit(root: root, action: .unstage(current.changes[0]), cancellation: .init())
            XCTAssertEqual(current.changes[0].code, "??")
            XCTAssertEqual(try Data(contentsOf: file), Data("newer working bytes\n".utf8))
        }
    }

    func testInitialStageUnstageAndCommitPreserveDashAndNewlineNames() throws {
        try fixture { root in
            for name in ["-leading.txt", "line\nbreak.txt", ":(glob)*.txt"] {
                try Data("first\n".utf8).write(to: root.appendingPathComponent(name))
            }
            var current = try snapshot(root)
            XCTAssertEqual(Set(current.changes.map(\.path)), ["-leading.txt", "line\nbreak.txt", ":(glob)*.txt"])
            let first = try XCTUnwrap(current.changes.first)
            XCTAssertEqual(try GitWorkspaceBackend.diff(root: root, change: first, staged: false, cancellation: .init()), "first\n")
            current = try GitWorkspaceBackend.edit(root: root, action: .stage(first), cancellation: .init())
            XCTAssertEqual(current.changes.filter(\.staged).count, 1)
            current = try GitWorkspaceBackend.edit(root: root, action: .unstage(try XCTUnwrap(current.changes.first(where: \.staged))), cancellation: .init())
            XCTAssertFalse(current.changes.contains(where: \.staged))
            for name in current.changes.map(\.path) {
                let change = try XCTUnwrap(current.changes.first(where: { $0.path == name }))
                current = try GitWorkspaceBackend.edit(root: root, action: .stage(change), cancellation: .init())
            }
            current = try GitWorkspaceBackend.edit(root: root, action: .commit("Initial files", "Fixture Author", "fixture@example.invalid"), cancellation: .init())
            XCTAssertTrue(current.changes.isEmpty)
            XCTAssertEqual(current.history.count, 1)
            XCTAssertEqual(current.history[0].subject, "Initial files")
            XCTAssertEqual(current.history[0].author, "Fixture Author")
            XCTAssertNotNil(current.head)
            let shown = try GitWorkspaceBackend.commitDiff(root: root, commit: current.history[0], cancellation: .init())
            XCTAssertTrue(shown.contains("Initial files"))
            XCTAssertTrue(shown.contains("first"))
        }
    }

    func testTrackedUnstagedAndStagedDiffAndRenameRoundTrip() throws {
        try fixture { root in
            let original = "original\nname.txt", renamed = "-renamed.txt"
            try Data("one\ntwo\nthree\nfour\n".utf8).write(to: root.appendingPathComponent(original))
            var current = try snapshot(root)
            current = try GitWorkspaceBackend.edit(root: root, action: .stage(current.changes[0]), cancellation: .init())
            current = try GitWorkspaceBackend.edit(root: root, action: .commit("Base", "Fixture", "fixture@example.invalid"), cancellation: .init())
            try Data("one\ntwo\nthree\nfour\nfive\n".utf8).write(to: root.appendingPathComponent(original))
            current = try snapshot(root)
            XCTAssertTrue(try GitWorkspaceBackend.diff(root: root, change: current.changes[0], staged: false, cancellation: .init()).contains("+five"))
            current = try GitWorkspaceBackend.edit(root: root, action: .stage(current.changes[0]), cancellation: .init())
            XCTAssertTrue(try GitWorkspaceBackend.diff(root: root, change: current.changes[0], staged: true, cancellation: .init()).contains("+five"))
            current = try GitWorkspaceBackend.edit(root: root, action: .unstage(current.changes[0]), cancellation: .init())
            XCTAssertFalse(current.changes[0].staged)
            try FileManager.default.moveItem(at: root.appendingPathComponent(original), to: root.appendingPathComponent(renamed))
            _ = try git(root, ["add", "--", original, renamed])
            current = try snapshot(root)
            XCTAssertEqual(current.changes.count, 1)
            XCTAssertEqual(current.changes[0].path, renamed)
            XCTAssertEqual(current.changes[0].originalPath, original)
            current = try GitWorkspaceBackend.edit(root: root, action: .unstage(current.changes[0]), cancellation: .init())
            XCTAssertEqual(Set(current.changes.map(\.path)), [original, renamed])
            XCTAssertFalse(current.changes.contains(where: \.staged))
        }
    }

    func testHooksAndSigningHelpersDoNotRunOnCommit() throws {
        try fixture { root in
            let marker = root.appendingPathComponent("hook-ran")
            let hook = root.appendingPathComponent(".git/hooks/pre-commit")
            try Data("#!/bin/sh\ntouch hook-ran\nexit 1\n".utf8).write(to: hook)
            try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: hook.path)
            _ = try git(root, ["config", "commit.gpgSign", "true"])
            _ = try git(root, ["config", "gpg.program", "/no/such/signing-helper"])
            try Data("content".utf8).write(to: root.appendingPathComponent("file"))
            var current = try snapshot(root)
            current = try GitWorkspaceBackend.edit(root: root, action: .stage(current.changes[0]), cancellation: .init())
            current = try GitWorkspaceBackend.edit(root: root, action: .commit("No helpers", "Fixture", "fixture@example.invalid"), cancellation: .init())
            XCTAssertEqual(current.history.count, 1)
            XCTAssertFalse(FileManager.default.fileExists(atPath: marker.path))
        }
    }

    func testConfiguredFiltersAndSubmodulesDenyWritesWithoutChangingIndex() throws {
        try fixture { root in
            try Data("content".utf8).write(to: root.appendingPathComponent("file"))
            _ = try git(root, ["config", "filter.trip.clean", "touch filter-ran"])
            XCTAssertThrowsError(try snapshot(root))
            let selected = GitWorkspaceChange(path: "file", originalPath: nil, index: "?", worktree: "?")
            XCTAssertThrowsError(try GitWorkspaceBackend.edit(root: root, action: .stage(selected), cancellation: .init()))
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("filter-ran").path))
            XCTAssertTrue(try git(root, ["ls-files", "-z"]).isEmpty)
            _ = try git(root, ["config", "--unset", "filter.trip.clean"])
            try Data("".utf8).write(to: root.appendingPathComponent(".gitmodules"))
            let modules = try snapshot(root)
            XCTAssertTrue(modules.writeBlock?.contains("submodules") == true)
            XCTAssertThrowsError(try GitWorkspaceBackend.edit(root: root, action: .stage(modules.changes[0]), cancellation: .init()))
        }
    }

    func testAttributeOnlyFilterAndStaleSelectionDenyWrites() throws {
        try fixture { root in
            try Data("content".utf8).write(to: root.appendingPathComponent("file"))
            let original = try XCTUnwrap(snapshot(root).changes.first)
            try Data("file filter=unknown\n".utf8).write(to: root.appendingPathComponent(".gitattributes"))
            XCTAssertThrowsError(try GitWorkspaceBackend.edit(root: root, action: .stage(original), cancellation: .init()))
            XCTAssertTrue(try git(root, ["ls-files", "-z"]).isEmpty)
            try FileManager.default.removeItem(at: root.appendingPathComponent(".gitattributes"))
            _ = try git(root, ["add", "--", "file"])
            XCTAssertThrowsError(try GitWorkspaceBackend.edit(root: root, action: .stage(original), cancellation: .init()))
        }
    }

    func testStatusAndDiffRejectCleanAndProcessFiltersBeforeTheyCanRun() throws {
        try fixture { root in
            let file = root.appendingPathComponent("file")
            try Data("old\n".utf8).write(to: file)
            var current = try snapshot(root)
            current = try GitWorkspaceBackend.edit(root: root, action: .stage(current.changes[0]), cancellation: .init())
            _ = try GitWorkspaceBackend.edit(root: root, action: .commit("Base", "Fixture", "fixture@example.invalid"), cancellation: .init())
            try Data("new and different\n".utf8).write(to: file)
            current = try snapshot(root)
            let selected = current.changes[0]
            try Data("file filter=trip\n".utf8).write(to: root.appendingPathComponent(".gitattributes"))
            for key in ["filter.trip.clean", "filter.trip.process"] {
                _ = try git(root, ["config", key, "touch filter-ran; cat"])
                XCTAssertThrowsError(try snapshot(root))
                XCTAssertThrowsError(try GitWorkspaceBackend.diff(root: root, change: selected, staged: false, cancellation: .init()))
                XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("filter-ran").path))
                _ = try git(root, ["config", "--unset", key])
            }
        }
    }

    private func configurationFixture(_ body: (URL) throws -> Void) throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("GitConfigurationTests-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
        defer { try? FileManager.default.removeItem(at: root) }
        try body(root)
    }

    private func configuration(_ root: URL, outputs: inout [GitWorkspaceCommand.Output]) throws -> [(String, String)] {
        try GitWorkspaceBackend.readRequiredConfiguration { arguments in
            // Use only these synthetic files, never the test host's Git config.
            let isolated = ["config", "--file", root.appendingPathComponent("config").path] + arguments.dropFirst()
            let output = try GitWorkspaceCommand.run(root: root, arguments: isolated, cancellation: .init(),
                environment: ["HOME": root.path, "XDG_CONFIG_HOME": root.path,
                    "GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": "/dev/null",
                    "GIT_CEILING_DIRECTORIES": root.deletingLastPathComponent().path])
            outputs.append(output)
            return output
        }
    }

    func testConfigurationReadsOnlyAuthorsAndNeverReturnsSyntheticCredentials() throws {
        try configurationFixture { root in
            try Data("""
                [credential]
                helper = SYNTHETIC_CREDENTIAL_TOKEN
                [http]
                extraHeader = Authorization: SYNTHETIC_HTTP_TOKEN
                [remote "origin"]
                url = https://fixture:SYNTHETIC_URL_TOKEN@example.invalid/repo
                [user]
                name = Included Author
                [filter "empty"]
                clean = ""
                process
                """.utf8).write(to: root.appendingPathComponent("included"))
            try Data("""
                [include]
                path = included
                [user]
                email = fixture@example.invalid
                name = Last Author
                """.utf8).write(to: root.appendingPathComponent("config"))
            var outputs: [GitWorkspaceCommand.Output] = []
            let pairs = try configuration(root, outputs: &outputs)
            XCTAssertEqual(pairs.map { $0.0 }, ["user.name", "user.email", "user.name"])
            XCTAssertEqual(pairs.map { $0.1 }, ["Included Author", "fixture@example.invalid", "Last Author"])
            XCTAssertEqual(outputs.map(\.status), [1, 0])
            XCTAssertTrue(outputs[0].stdout.isEmpty)
            for output in outputs {
                XCTAssertFalse(String(decoding: output.stdout, as: UTF8.self).contains("SYNTHETIC_"))
                XCTAssertTrue(output.stderr.isEmpty)
            }
        }
    }

    func testIncludedNonemptyFiltersRejectWithoutReturningCommands() throws {
        try configurationFixture { root in
            try Data("[include]\npath = included\n".utf8).write(to: root.appendingPathComponent("config"))
            // All occurrences remain guarded, even if a later value is empty.
            for setting in ["ClEaN = SYNTHETIC_FILTER_TOKEN", "process = \"\\n\"",
                            "clean = \" \"", "clean = SYNTHETIC_FILTER_TOKEN\nclean = \"\""] {
                try Data(("[FiLtEr \"Mixed.dot\"]\n" + setting + "\n").utf8).write(to: root.appendingPathComponent("included"))
                var outputs: [GitWorkspaceCommand.Output] = []
                XCTAssertThrowsError(try configuration(root, outputs: &outputs)) { error in
                    XCTAssertTrue(error.localizedDescription.contains("external content filters"))
                    XCTAssertFalse(error.localizedDescription.contains("SYNTHETIC_"))
                }
                XCTAssertEqual(outputs.count, 1)
                let output = try XCTUnwrap(outputs.first)
                XCTAssertEqual(output.status, 0)
                XCTAssertEqual(output.stdout, Data(("filter.Mixed.dot." + (setting.hasPrefix("process") ? "process" : "clean") + "\0").utf8))
                XCTAssertTrue(output.stderr.isEmpty)
            }
        }
    }

    func testEmptyAndMissingRequiredConfigurationRemainValid() throws {
        try configurationFixture { root in
            for contents in ["", "[filter \"empty\"]\nclean = \"\"\nprocess\nsmudge = ignored\n"] {
                try Data(contents.utf8).write(to: root.appendingPathComponent("config"))
                var outputs: [GitWorkspaceCommand.Output] = []
                XCTAssertTrue(try configuration(root, outputs: &outputs).isEmpty)
                XCTAssertEqual(outputs.map(\.status), [1, 1])
                XCTAssertTrue(outputs.allSatisfy { $0.stdout.isEmpty && $0.stderr.isEmpty })
            }
        }
    }

    func testConfigurationFailureDiagnosticsDoNotExposeRawConfigText() throws {
        let secret = Data("SYNTHETIC_CREDENTIAL_AND_HTTP_TOKEN".utf8)
        for output in [GitWorkspaceCommand.Output(status: 3, stdout: Data(), stderr: secret),
                       .init(status: 1, stdout: secret, stderr: Data()),
                       .init(status: 0, stdout: secret, stderr: Data()),
                       .init(status: 0, stdout: Data("filter.trip.clean\0".utf8), stderr: secret)] {
            XCTAssertThrowsError(try GitWorkspaceBackend.readRequiredConfiguration { _ in output }) { error in
                XCTAssertEqual(error.localizedDescription, "Git author and content-filter configuration could not be inspected.")
                XCTAssertFalse(error.localizedDescription.contains("SYNTHETIC_"))
            }
        }
    }

    func testExternalGitDirectoryAndAlternatesRejectBeforeIndexWrites() throws {
        try fixture { root in
            let worktree = root.appendingPathComponent("worktree")
            let metadata = root.appendingPathComponent("external-metadata")
            try FileManager.default.createDirectory(at: worktree, withIntermediateDirectories: false)
            _ = try git(worktree, ["init", "--initial-branch=main", "--separate-git-dir=" + metadata.path])
            try Data("content".utf8).write(to: worktree.appendingPathComponent("file"))
            XCTAssertThrowsError(try snapshot(worktree))
            XCTAssertThrowsError(try GitWorkspaceBackend.edit(root: worktree,
                action: .stage(.init(path: "file", originalPath: nil, index: "?", worktree: "?")), cancellation: .init()))
            XCTAssertFalse(FileManager.default.fileExists(atPath: metadata.appendingPathComponent("index").path))
            let alternates = root.appendingPathComponent(".git/objects/info/alternates")
            try Data((metadata.appendingPathComponent("objects").path + "\n").utf8).write(to: alternates)
            XCTAssertThrowsError(try snapshot(root))
        }
    }

    func testSymlinkedMetadataDescendantsRejectBeforeGitCanWriteOutside() throws {
        for relative in ["refs/heads", "objects/ab"] {
            try fixture { root in
                let outside = root.appendingPathComponent("outside-metadata")
                try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: false)
                let link = root.appendingPathComponent(".git/" + relative)
                if FileManager.default.fileExists(atPath: link.path) { try FileManager.default.removeItem(at: link) }
                try FileManager.default.createSymbolicLink(at: link, withDestinationURL: outside)
                XCTAssertThrowsError(try snapshot(root))
                XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: outside.path).isEmpty)
            }
        }
    }

    func testTypeChangeAndUntrackedNestedRepositoryRemainReadable() throws {
        try fixture { root in
            let file = root.appendingPathComponent("file")
            try Data("old\n".utf8).write(to: file)
            var current = try snapshot(root)
            current = try GitWorkspaceBackend.edit(root: root, action: .stage(current.changes[0]), cancellation: .init())
            _ = try GitWorkspaceBackend.edit(root: root, action: .commit("Base", "Fixture", "fixture@example.invalid"), cancellation: .init())
            try FileManager.default.removeItem(at: file)
            try FileManager.default.createSymbolicLink(atPath: file.path, withDestinationPath: "missing-target")
            let nested = root.appendingPathComponent("nested")
            try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: false)
            _ = try git(nested, ["init", "--initial-branch=main"])
            try Data("nested content".utf8).write(to: nested.appendingPathComponent("file"))
            current = try snapshot(root)
            let typeChange = try XCTUnwrap(current.changes.first(where: { $0.path == "file" }))
            XCTAssertEqual(typeChange.worktree, "T")
            XCTAssertTrue(try GitWorkspaceBackend.diff(root: root, change: typeChange, staged: false, cancellation: .init()).contains("missing-target"))
            let directory = try XCTUnwrap(current.changes.first(where: { $0.path == "nested/" }))
            XCTAssertThrowsError(try GitWorkspaceBackend.edit(root: root, action: .stage(directory), cancellation: .init()))
        }
    }

    func testReadOnlyDiffDoesNotRunTextconvOrExternalDiff() throws {
        try fixture { root in
            try Data("old\n".utf8).write(to: root.appendingPathComponent("file"))
            var current = try snapshot(root)
            current = try GitWorkspaceBackend.edit(root: root, action: .stage(current.changes[0]), cancellation: .init())
            _ = try GitWorkspaceBackend.edit(root: root, action: .commit("Base", "Fixture", "fixture@example.invalid"), cancellation: .init())
            try Data("new\n".utf8).write(to: root.appendingPathComponent("file"))
            _ = try git(root, ["config", "diff.external", "touch external-ran"])
            _ = try git(root, ["config", "diff.trip.textconv", "touch textconv-ran"])
            try Data("file diff=trip\n".utf8).write(to: root.appendingPathComponent(".gitattributes"))
            current = try snapshot(root)
            let file = try XCTUnwrap(current.changes.first(where: { $0.path == "file" }))
            XCTAssertTrue(try GitWorkspaceBackend.diff(root: root, change: file, staged: false, cancellation: .init()).contains("+new"))
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("external-ran").path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("textconv-ran").path))
        }
    }

    func testStatusDecoderRejectsTruncationRenameTruncationAndTraversal() throws {
        for bad in [" M file", "R  renamed\0", "?? ../escape\0", "?? /escape\0", "?? .git/config\0", "?? same\0?? same\0"] {
            XCTAssertThrowsError(try GitWorkspaceBackend.parseStatus(Data(bad.utf8)))
        }
        let parsed = try GitWorkspaceBackend.parseStatus(Data("R  -new\nfile\0old\nfile\0".utf8))
        XCTAssertEqual(parsed[0].path, "-new\nfile")
        XCTAssertEqual(parsed[0].originalPath, "old\nfile")
    }

    func testCanceledCommandDoesNotStartAndOutputLimitRejects() throws {
        try fixture { root in
            let token = GitWorkspaceCancellation(); token.cancel()
            XCTAssertThrowsError(try GitWorkspaceCommand.run(root: root, arguments: ["status"], cancellation: token))
            XCTAssertThrowsError(try GitWorkspaceCommand.run(root: root, arguments: ["status"], cancellation: .init(), maximumBytes: 8))
            XCTAssertTrue(try snapshot(root).changes.isEmpty)
        }
    }

    func testTimeoutReapsTheOwnedProcessGroup() throws {
        try fixture { root in
            let start = ProcessInfo.processInfo.systemUptime
            XCTAssertThrowsError(try GitWorkspaceCommand.run(root: root,
                arguments: ["-c", "alias.fixturewait=!sleep 20", "fixturewait"], cancellation: .init(), seconds: 0.1))
            XCTAssertLessThan(ProcessInfo.processInfo.systemUptime - start, 4)
            XCTAssertTrue(try snapshot(root).changes.isEmpty)
        }
    }

    func testCancellationStopsAndReapsAnActiveOwnedProcessGroup() throws {
        try fixture { root in
            let token = GitWorkspaceCancellation()
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) { token.cancel() }
            let start = ProcessInfo.processInfo.systemUptime
            XCTAssertThrowsError(try GitWorkspaceCommand.run(root: root,
                arguments: ["-c", "alias.fixturewait=!sleep 20", "fixturewait"], cancellation: token))
            XCTAssertLessThan(ProcessInfo.processInfo.systemUptime - start, 4)
            XCTAssertTrue(try snapshot(root).changes.isEmpty)
        }
    }

    func testSuccessfulGitExitAlsoRetiresBackgroundHelpersBeforeReturning() throws {
        try fixture { root in
            let output = try GitWorkspaceCommand.run(root: root,
                arguments: ["-c", "alias.fixturebackground=!sh -c 'sleep 30 >/dev/null 2>&1 & echo $!'", "fixturebackground"], cancellation: .init())
            XCTAssertEqual(output.status, 0)
            let child = try XCTUnwrap(Int32(String(decoding: output.stdout, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)))
            XCTAssertGreaterThan(child, 0)
            XCTAssertEqual(kill(child, 0), -1)
            XCTAssertEqual(errno, ESRCH)
        }
    }

    func testTransportProtocolsAreDeniedEvenForAnExplicitCommand() throws {
        try fixture { root in
            let output = try GitWorkspaceCommand.run(root: root,
                arguments: ["ls-remote", "https://example.invalid/repository.git"], cancellation: .init())
            XCTAssertNotEqual(output.status, 0)
            XCTAssertTrue(String(decoding: output.stderr, as: UTF8.self).contains("transport 'https' not allowed"))
        }
    }

    func testUntrackedSymlinkDoesNotReadTargetAndSubdirectorySelectionRejects() throws {
        try fixture { root in
            try FileManager.default.createSymbolicLink(atPath: root.appendingPathComponent("link").path, withDestinationPath: "/no/such/target")
            let current = try snapshot(root)
            XCTAssertEqual(try GitWorkspaceBackend.diff(root: root, change: current.changes[0], staged: false, cancellation: .init()), "Untracked symbolic link → /no/such/target")
            let subdir = root.appendingPathComponent("subdir")
            try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: false)
            XCTAssertThrowsError(try snapshot(subdir))
        }
    }
}
