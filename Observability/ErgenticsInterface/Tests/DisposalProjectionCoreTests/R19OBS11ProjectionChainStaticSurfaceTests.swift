import Foundation
import XCTest

// C1 authors this guard; executing it requires separately frozen verification authority.
final class R19OBS11ProjectionChainStaticSurfaceTests: XCTestCase {
    func testClosedRunnerHasOnlyTheFrozenZeroArgumentSeam() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let main = try String(
            contentsOf: packageRoot.appendingPathComponent(
                "Sources/ErgenticsR19OBS11ProjectionChain/main.swift"),
            encoding: .utf8)
        let coreRoot = packageRoot.appendingPathComponent("Sources/DisposalProjectionCore")
        let coreNames = [
            "DisposalDurableReceiptJournal.swift",
            "DisposalHeldR19Source.swift",
            "DisposalProjectionRuleResources.swift",
            "DisposalR19OBS11HeldNamespacePair.swift",
            "DisposalR19OBS11ProjectionChain.swift",
            "DisposalR19OBS11ReceiptFrames.swift",
        ]
        let coreFiles = coreNames.map { coreRoot.appendingPathComponent($0) }
        XCTAssertTrue(coreFiles.allSatisfy { FileManager.default.fileExists(atPath: $0.path) })
        let coreSources = try coreFiles.map {
            try String(contentsOf: $0, encoding: .utf8)
        }
        let closedSources = ([main] + coreSources).joined(separator: "\n")

        XCTAssertEqual(occurrences(of: "CommandLine.arguments", in: closedSources), 1)
        XCTAssertTrue(main.contains("guard CommandLine.arguments.count == 1"))
        XCTAssertTrue(main.contains("guard environ.pointee == nil"))
        XCTAssertEqual(occurrences(of: "environ", in: closedSources), 1)
        XCTAssertTrue(main.contains("strcmp(base, \"/private/var/empty\") == 0"))
        XCTAssertTrue(main.contains("lstat(\"/dev/null\", &nullStatus) == 0"))
        XCTAssertTrue(main.contains("fstat(STDIN_FILENO, &standardInputStatus) == 0"))
        XCTAssertFalse(main.contains("FileHandle.standardInput"))
        XCTAssertFalse(main.contains("FileHandle.standardOutput"))
        XCTAssertFalse(main.contains("FileHandle.standardError"))
        XCTAssertFalse(main.contains("print("))
        XCTAssertFalse(main.contains("readLine("))
        XCTAssertFalse(main.contains("read(STDIN_FILENO"))

        let seam = "try DisposalR19OBS11ProjectionChain.runFrozen()"
        XCTAssertEqual(occurrences(of: seam, in: main), 1)
        XCTAssertEqual(occurrences(of: "DisposalR19OBS11ProjectionChain.", in: main), 1)
        let publicFunctions = coreSources.flatMap { source in
            source.split(separator: "\n").map {
                $0.trimmingCharacters(in: .whitespaces)
            }.filter {
                $0.hasPrefix("public ") && $0.contains(" func ")
            }
        }
        XCTAssertEqual(publicFunctions.count, 0)
        XCTAssertEqual(
            occurrences(of: "package enum DisposalR19OBS11ProjectionChain", in: closedSources),
            1)
        XCTAssertEqual(
            occurrences(of: "package static func runFrozen() throws", in: closedSources),
            1)
        XCTAssertEqual(
            occurrences(
                of: "\"gate_e\": disposalJSONString(\"ABSTAIN\")",
                in: closedSources),
            1)
        XCTAssertTrue(main.contains("_exit(0)"))
        XCTAssertTrue(main.contains("_exit(64)"))
        XCTAssertTrue(main.contains("_exit(70)"))

        let forbidden = [
            "CommandLine.arguments[", "CommandLine.arguments.drop", "CommandLine.arguments.first",
            "ProcessInfo", "getenv(", "setenv(", "unsetenv(", "UserDefaults",
            "Process(", "NSTask", "posix_spawn", "fork(", "vfork(", "execv(", "execve(",
            "execl(", "system(", "popen(", "waitpid(", "kill(", "signal(",
            "libproc", "proc_pid", "PROC_PID",
            "URLSession", "NWConnection", "socket(", "connect(", "getaddrinfo(",
            "/usr/bin/git", "swift-package", "swift build", "swift test", "SwiftPM",
            "GATE_E", "Gate E", "roleID", "roleId", "timeout", "deadline",
        ]
        for token in forbidden {
            XCTAssertFalse(
                closedSources.contains(token),
                "closed runner contains forbidden surface: \(token)")
        }
    }

    func testManifestAddsNoDependencyOrResourceSurface() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let manifest = try String(
            contentsOf: packageRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8)

        XCTAssertEqual(
            occurrences(of: "name: \"ErgenticsR19OBS11ProjectionChain\"", in: manifest),
            2)
        let productDeclaration = """
        .executable(
                    name: "ErgenticsR19OBS11ProjectionChain",
                    targets: ["ErgenticsR19OBS11ProjectionChain"]
                )
        """
        XCTAssertTrue(manifest.contains(productDeclaration))
        let targetDeclaration = """
        .executableTarget(
                    name: "ErgenticsR19OBS11ProjectionChain",
                    dependencies: ["DisposalProjectionCore"]
                )
        """
        XCTAssertTrue(manifest.contains(targetDeclaration))
        XCTAssertFalse(manifest.contains("R19OBS11ProjectionChainCore"))
    }

    func testFailureNamespaceRequiresBuilderOriginAndFinalRevalidation() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let coreRoot = packageRoot.appendingPathComponent("Sources/DisposalProjectionCore")
        func source(_ leaf: String) throws -> String {
            try String(
                contentsOf: coreRoot.appendingPathComponent(leaf),
                encoding: .utf8)
        }
        let builder = try source("DisposalProjectionSetBuilder.swift")
        let sealed = try source("DisposalSealedArtifactSet.swift")
        let chain = try source("DisposalR19OBS11ProjectionChain.swift")
        let heldPair = try source("DisposalR19OBS11HeldNamespacePair.swift")

        let rootAdmission = try XCTUnwrap(builder.range(
            of: "let root = try DisposalSealedArtifactSet(path: outputRootPath)"))
        let ownershipPublication = try XCTUnwrap(builder.range(
            of: "outputAdmission?(root.ownershipToken())"))
        let firstWrite = try XCTUnwrap(builder.range(
            of: "_ = try root.writeExclusive("))
        XCTAssertLessThan(rootAdmission.lowerBound, ownershipPublication.lowerBound)
        XCTAssertLessThan(ownershipPublication.lowerBound, firstWrite.lowerBound)
        XCTAssertTrue(sealed.contains("func ownershipToken() -> DisposalOutputNamespaceOwnership"))
        XCTAssertTrue(sealed.contains("finalPresent != stagingPresent && finalPresent == published"))
        XCTAssertTrue(sealed.contains("func proveDurable(finalPresent: Bool, stagingPresent: Bool)"))
        XCTAssertTrue(sealed.contains("OUTPUT_FAILURE_SNAPSHOT_NOT_DURABLY_PREPARED"))
        XCTAssertTrue(sealed.contains("try disposalSyncDirectory(rootDescriptor)"))
        XCTAssertTrue(sealed.contains("try disposalSyncDirectory(parentDescriptor)"))
        XCTAssertTrue(heldPair.contains("OBS11_RETAINED_PRESENT_ORIGIN_UNPROVEN"))
        XCTAssertTrue(heldPair.contains("try ownership.proveDurable("))
        XCTAssertTrue(heldPair.contains("try ownership?.revalidate("))
        XCTAssertTrue(chain.contains(
            "retainedNamespaceRevalidation: { try retained.revalidate() }"))
        XCTAssertTrue(chain.contains("try retainedNamespaceRevalidation()"))
    }

    private func occurrences(of needle: String, in haystack: String) -> Int {
        guard !needle.isEmpty else { return 0 }
        return haystack.components(separatedBy: needle).count - 1
    }
}
