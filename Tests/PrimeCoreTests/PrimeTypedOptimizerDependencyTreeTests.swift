import Foundation
@testable import PrimeCore
import XCTest

final class PrimeTypedOptimizerDependencyTreeTests:
    XCTestCase
{
    func testLiveDependencyBuildInputTreeMatchesFrozenIdentity()
        throws
    {
        let checkout = URL(
            fileURLWithPath:
                FileManager.default
                .currentDirectoryPath,
            isDirectory: true
        )
        .appendingPathComponent(".build")
        .appendingPathComponent("checkouts")
        .appendingPathComponent(
            PrimeTypedOptimizerDependencyTree
                .checkoutDirectoryName,
            isDirectory: true
        )
        let evidence =
            try PrimeTypedOptimizerDependencyTree
            .capture(at: checkout)
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
