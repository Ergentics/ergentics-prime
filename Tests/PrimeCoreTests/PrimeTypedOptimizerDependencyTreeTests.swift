import Darwin
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeTypedOptimizerDependencyTreeTests:
    XCTestCase
{
    func testLiveDependencyBuildInputTreeMatchesContinuationIdentity()
        throws
    {
        let layout = try PrimeCurrentTestBuildLayout.capture(testClass: Self.self, sourceFilePath: #filePath)
        let checkout = try layout.dependencyCheckout(PrimeTypedOptimizerDependencyTree.checkoutDirectoryName)
        let evidence =
            try PrimeTypedOptimizerDependencyTree
            .capture(at: checkout)
        try PrimeTypedOptimizerDependencyTree
            .validateStructure(evidence)
        let plan =
            PrimeNative3BContinuationDependencyPlan
                .frozenV1
        try plan.validate()
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of:
                    try PrimeCanonicalJSON
                    .encode(evidence)
            ),
            plan.dependencyTreeManifestSHA256
        )
        try layout.revalidate()
    }

    func testHistoricalTypedRestoreEvidenceMatchesFrozenIdentity()
        throws
    {
        let evidenceURL = URL(
            fileURLWithPath:
                FileManager.default
                .currentDirectoryPath,
            isDirectory: true
        )
        .appendingPathComponent(
            "artifacts/typed-optimizer-restore-6465beb-20260729T184600Z/content-staging/evidence/mlx-swift/dependency-source-tree.v1.json"
        )
        let evidence = try JSONDecoder().decode(
            PrimeTypedOptimizerDependencyTreeEvidence
                .self,
            from: Data(contentsOf: evidenceURL)
        )
        try PrimeTypedOptimizerDependencyTree
            .validateFrozen(evidence)
    }

    func testTreeStructureRejectsPathAndDigestMutations()
        throws
    {
        let entry =
            PrimeTypedOptimizerDependencyTreeEntry(
                relativePath: "Package.swift",
                sha256:
                    PrimeSHA256.hexDigest(
                        of: Data("manifest".utf8)
                    ),
                byteCount: 8
            )
        let validRoot =
            PrimeSHA256.hexDigest(
                of:
                    try PrimeCanonicalJSON
                    .encode([entry])
            )
        let structurallyValid =
            PrimeTypedOptimizerDependencyTreeEvidence(
                treeSHA256: validRoot,
                fileCount: 1,
                totalByteCount: 8,
                entries: [entry]
            )
        XCTAssertNoThrow(
            try PrimeTypedOptimizerDependencyTree
                .validateStructure(
                    structurallyValid
                )
        )

        let unsafeEntry =
            PrimeTypedOptimizerDependencyTreeEntry(
                relativePath:
                    "Source/../Package.swift",
                sha256: entry.sha256,
                byteCount: entry.byteCount
            )
        XCTAssertThrowsError(
            try PrimeTypedOptimizerDependencyTree
                .validateStructure(
                    PrimeTypedOptimizerDependencyTreeEvidence(
                        treeSHA256: validRoot,
                        fileCount: 1,
                        totalByteCount: 8,
                        entries: [unsafeEntry]
                    )
                )
        )
        XCTAssertThrowsError(
            try PrimeTypedOptimizerDependencyTree
                .validateStructure(
                    PrimeTypedOptimizerDependencyTreeEvidence(
                        treeSHA256:
                            String(
                                repeating: "0",
                                count: 64
                            ),
                        fileCount: 1,
                        totalByteCount: 8,
                        entries: [entry]
                    )
                )
        )
    }

    func testRegularGitMetadataDoesNotSkipLaterSourceSiblings()
        throws
    {
        let root = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(
                UUID().uuidString,
                isDirectory: true
            )
        let nestedSource = root
            .appendingPathComponent(
                "Source/Nested",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: nestedSource,
            withIntermediateDirectories: true
        )
        defer {
            try? FileManager.default
                .removeItem(at: root)
        }
        try Data("// manifest\n".utf8).write(
            to: root.appendingPathComponent(
                "Package.swift"
            )
        )
        try Data("gitdir: ../../.git/modules/nested\n".utf8)
            .write(
                to: nestedSource
                    .appendingPathComponent(".git")
            )
        try Data("public let before = 1\n".utf8)
            .write(
                to: nestedSource
                    .appendingPathComponent(
                        "A.swift"
                    )
            )
        try Data("public let after = 2\n".utf8)
            .write(
                to: nestedSource
                    .appendingPathComponent(
                        "Z.swift"
                    )
            )

        let evidence =
            try PrimeTypedOptimizerDependencyTree
            .capture(at: root)
        XCTAssertEqual(
            evidence.entries.map(\.relativePath),
            [
                "Package.swift",
                "Source/Nested/A.swift",
                "Source/Nested/Z.swift",
            ]
        )
    }
}

/// Test-only discovery of the build that contains this running XCTest bundle.
/// The fixed SwiftPM description must join the compiler's source path. This
/// never supplies a production execution capability or a replacement test pin.
final class PrimeCurrentTestBuildLayout {
    private struct Held {
        let path: String
        let descriptor: Int32
        let status: stat
        let data: Data?
    }
    let products: URL
    private let scratch: URL
    private let sourceRoot: String
    private var held: [Held] = []
    private var commands: [[String: Any]] = []

    private init(products: String, scratch: String, sourceRoot: String) {
        self.products = URL(fileURLWithPath: products, isDirectory: true)
        self.scratch = URL(fileURLWithPath: scratch, isDirectory: true)
        self.sourceRoot = sourceRoot
    }
    deinit { for node in held { _ = close(node.descriptor) } }

    static func capture(testClass: AnyClass, sourceFilePath: String) throws -> PrimeCurrentTestBuildLayout {
        let sourceRoot = "/" + sourceFilePath.split(separator: "/").dropLast(3).joined(separator: "/")
        guard try PrimeSecureChildPath.canonicalPath(sourceRoot) == sourceRoot,
              sourceFilePath.hasPrefix(sourceRoot + "/Tests/PrimeCoreTests/") else { throw rejected("source") }
        // Bundle discovery is a host observation; canonicalize its platform
        // alias once, then open every admitted path with O_NOFOLLOW_ANY.
        let bundle = try PrimeSecureChildPath.canonicalPath(Bundle(for: testClass).bundleURL.path)
        var parts = bundle.split(separator: "/").map(String.init)
        guard parts.popLast() == "ErgenticsPrimePackageTests.xctest" else { throw rejected("bundle") }
        let productPath = "/" + parts.joined(separator: "/")
        #if DEBUG
        let expectedConfiguration = "debug"
        #else
        let expectedConfiguration = "release"
        #endif
        guard parts.popLast() == expectedConfiguration,
              parts.popLast() == "arm64-apple-macosx",
              let scratchName = parts.last, [".build", "root-release-build"].contains(scratchName) else {
            throw rejected("build_layout")
        }
        let layout = PrimeCurrentTestBuildLayout(products: productPath,
            scratch: "/" + parts.joined(separator: "/"), sourceRoot: sourceRoot)
        try layout.holdDirectory(sourceRoot)
        try layout.holdDirectory(layout.scratch.path)
        try layout.holdDirectory(productPath)
        try layout.holdDirectory(bundle)
        let data = try layout.holdFile(productPath + "/description.json", maximum: 32 * 1024 * 1024)
        guard let description = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let commandMap = description["swiftCommands"] as? [String: [String: Any]] else {
            throw rejected("description")
        }
        layout.commands = Array(commandMap.values)
        let matches = layout.commands.filter { $0["moduleName"] as? String == "PrimeCoreTests" }
        guard matches.count == 1, let sources = matches[0]["sources"] as? [String],
              sources.contains(sourceFilePath),
              matches[0]["moduleOutputPath"] as? String == productPath + "/Modules/PrimeCoreTests.swiftmodule" else {
            throw rejected("test_source_build_join")
        }
        return layout
    }

    func dependencyCheckout(_ name: String) throws -> URL {
        guard name == PrimeTypedOptimizerDependencyTree.checkoutDirectoryName else { throw Self.rejected("dependency") }
        let url = scratch.appendingPathComponent("checkouts/" + name, isDirectory: true)
        try holdDirectory(url.path)
        return url
    }

    func workerCompilerInputs(expectedRelativeSources: [String]) throws -> (modules: URL, accessor: URL) {
        let name = "PrimeNativeNeuralGateHistoricalFixtureWorker"
        let modules = products.appendingPathComponent("Modules", isDirectory: true)
        let accessor = products.appendingPathComponent(name + ".build/DerivedSources/resource_bundle_accessor.swift")
        let matches = commands.filter { $0["moduleName"] as? String == name }
        guard matches.count == 1, let sources = matches[0]["sources"] as? [String],
              let arguments = matches[0]["otherArguments"] as? [String], arguments.contains("-enable-testing"),
              matches[0]["moduleOutputPath"] as? String == modules.path + "/" + name + ".swiftmodule",
              sources.sorted() == (expectedRelativeSources.map { sourceRoot + "/" + $0 } + [accessor.path]).sorted() else {
            throw Self.rejected("worker_build_join")
        }
        try holdDirectory(modules.path)
        _ = try holdFile(modules.path + "/" + name + ".swiftmodule", maximum: 16 * 1024 * 1024)
        _ = try holdFile(modules.path + "/PrimeCore.swiftmodule", maximum: 32 * 1024 * 1024)
        _ = try holdFile(accessor.path, maximum: 1_048_576)
        for source in sources where source != accessor.path { _ = try holdFile(source, maximum: 8 * 1024 * 1024) }
        return (modules, accessor)
    }

    func revalidate() throws {
        for node in held {
            var status = stat(), named = stat()
            guard fstat(node.descriptor, &status) == 0, lstat(node.path, &named) == 0,
                  Self.same(node.status, status), Self.same(node.status, named),
                  try PrimeSecureChildPath.canonicalPath(node.path) == node.path else { throw Self.rejected("changed") }
            if let expected = node.data {
                guard lseek(node.descriptor, 0, SEEK_SET) == 0,
                      try PrimeSecureChildPath.readExact(descriptor: node.descriptor, byteCount: expected.count) == expected,
                      fstat(node.descriptor, &status) == 0, lstat(node.path, &named) == 0,
                      Self.same(node.status, status), Self.same(node.status, named) else {
                    throw Self.rejected("changed_bytes")
                }
            }
        }
    }
    private func holdDirectory(_ path: String) throws { _ = try hold(path, directory: true, maximum: 0) }
    private func holdFile(_ path: String, maximum: Int) throws -> Data {
        try hold(path, directory: false, maximum: maximum)!
    }
    private func hold(_ path: String, directory: Bool, maximum: Int) throws -> Data? {
        guard try PrimeSecureChildPath.canonicalPath(path) == path else { throw Self.rejected("noncanonical") }
        let fd = open(path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY | O_NONBLOCK | (directory ? O_DIRECTORY : 0))
        guard fd >= 0 else { throw Self.rejected("open_\(errno)") }
        var retained = false
        defer { if !retained { _ = close(fd) } }
        var status = stat(), after = stat(), named = stat()
        guard fstat(fd, &status) == 0, status.st_uid == geteuid(), status.st_mode & mode_t(0o022) == 0,
              status.st_mode & mode_t(0o7000) == 0, status.st_flags == 0,
              status.st_mode & mode_t(S_IFMT) == mode_t(directory ? S_IFDIR : S_IFREG),
              directory || (status.st_nlink == 1 && status.st_size > 0 && status.st_size <= off_t(maximum)) else {
            throw Self.rejected("metadata")
        }
        let data = directory ? nil : try PrimeSecureChildPath.readExact(descriptor: fd, byteCount: Int(status.st_size))
        guard fstat(fd, &after) == 0, lstat(path, &named) == 0,
              Self.same(status, after), Self.same(status, named) else { throw Self.rejected("read_changed") }
        held.append(.init(path: path, descriptor: fd, status: status, data: data)); retained = true
        return data
    }
    private static func same(_ a: stat, _ b: stat) -> Bool {
        a.st_dev == b.st_dev && a.st_ino == b.st_ino && a.st_mode == b.st_mode && a.st_uid == b.st_uid
            && a.st_gid == b.st_gid && a.st_nlink == b.st_nlink && a.st_size == b.st_size && a.st_flags == b.st_flags
            && a.st_mtimespec.tv_sec == b.st_mtimespec.tv_sec && a.st_mtimespec.tv_nsec == b.st_mtimespec.tv_nsec
            && a.st_ctimespec.tv_sec == b.st_ctimespec.tv_sec && a.st_ctimespec.tv_nsec == b.st_ctimespec.tv_nsec
    }
    private static func rejected(_ detail: String) -> NSError {
        NSError(domain: "PrimeCurrentTestBuildLayout", code: 1, userInfo: [NSLocalizedDescriptionKey: detail])
    }
}
