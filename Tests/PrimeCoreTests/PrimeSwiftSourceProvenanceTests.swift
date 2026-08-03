import Foundation
import XCTest
@testable import PrimeCore

final class PrimeSwiftSourceProvenanceTests:
    XCTestCase
{
    func testLiveRepositoryMatchesEmbeddedSourceIdentity()
        throws
    {
        let root = URL(
            fileURLWithPath:
                FileManager.default
                .currentDirectoryPath,
            isDirectory: true
        )
        let expectation =
            PrimeSwiftSourceProvenanceExpectation(
                sourceIdentitySHA256:
                    PrimeEmbeddedBuildProvenance
                    .sourceIdentitySHA256,
                buildConfiguration: "release"
            )
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: root,
                requiredRelativePaths: [],
                expectation: expectation
            )
        XCTAssertEqual(
            snapshot.sourceIdentitySHA256,
            expectation.sourceIdentitySHA256
        )
    }

    func testCapturePreservesCanonicalSnapshotContract()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [
                    "Sources/Fixture.swift",
                ],
                expectation:
                    fixture.expectation
            )

        XCTAssertEqual(snapshot.schemaVersion, 1)
        XCTAssertEqual(
            snapshot.artifactKind,
            "ergentics_prime_swift_source_snapshot"
        )
        XCTAssertEqual(
            snapshot.sourceIdentitySHA256,
            fixture.expectation
                .sourceIdentitySHA256
        )
        XCTAssertEqual(
            snapshot.embeddedSourceIdentitySHA256,
            fixture.expectation
                .sourceIdentitySHA256
        )
        XCTAssertEqual(
            snapshot.buildConfiguration,
            "release"
        )
        XCTAssertEqual(
            snapshot.files.map(\.relativePath),
            snapshot.files.map(\.relativePath).sorted()
        )
        XCTAssertTrue(
            snapshot.files.contains(where: {
                $0.relativePath == ".gitignore"
            })
        )
        XCTAssertTrue(
            snapshot.files.contains(where: {
                $0.relativePath
                    == ".swiftpm/configuration/mirrors.json"
            })
        )
        XCTAssertTrue(
            snapshot.files.contains(where: {
                $0.relativePath
                    == "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration/mirrors.json"
            })
        )
        XCTAssertTrue(
            snapshot.files.contains(where: {
                $0.relativePath
                    == "Tests/PrimeNativeNeuralGateMLXValidation/.swiftpm/configuration/mirrors.json"
            })
        )
        XCTAssertTrue(
            snapshot.files.contains(where: {
                $0.relativePath
                    == "Tests/PrimeValidationWorkflow/.swiftpm/configuration/mirrors.json"
            })
        )
        XCTAssertNoThrow(
            try PrimeSwiftSourceProvenance.validate(
                snapshot,
                requiredRelativePaths: [
                    "Sources/Fixture.swift",
                ],
                expectation:
                    fixture.expectation
            )
        )

        let encoded =
            try PrimeCanonicalJSON.encode(snapshot)
        let object = try XCTUnwrap(
            try JSONSerialization.jsonObject(
                with: encoded
            ) as? [String: Any]
        )
        XCTAssertEqual(
            Set(object.keys),
            [
                "schema_version",
                "artifact_kind",
                "source_identity_sha256",
                "embedded_source_identity_sha256",
                "build_configuration",
                "files",
            ]
        )
    }

    func testArbitrarySelfConsistentReleaseSnapshotCannotCreateHistoricalAuthority()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [
                    "Sources/Fixture.swift",
                ],
                expectation:
                    fixture.expectation
            )

        for pin in [
            PrimePinnedHistoricalReleaseSource
                .nativeGenerationContractProjection20260730,
            .nativeFullCorpusReplay20260730,
            .nativeNeuralGateContractProjection20260730,
        ] {
            XCTAssertThrowsError(
                try PrimeSwiftSourceProvenance
                    .validatePinnedReleaseEvidence(
                        snapshot,
                        requiredRelativePaths: [
                            "Sources/Fixture.swift",
                        ],
                        pin: pin
                    )
            ) { error in
                guard case
                    .sourceIdentityMismatch =
                        error as?
                        PrimeSwiftSourceProvenanceError
                else {
                    return XCTFail(
                        "unexpected error: \(error)"
                    )
                }
            }
        }
    }

    func testNonEmbeddedMutationChangesIdentityAndFailsClosed()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        let files = snapshot.files.map { file in
            guard file.relativePath
                == "Sources/Fixture.swift"
            else {
                return file
            }
            let contents =
                file.contents + Data([0x0a])
            return PrimeSwiftSourceFileSnapshot(
                relativePath: file.relativePath,
                sha256:
                    PrimeSHA256.hexDigest(of: contents),
                byteCount: UInt64(contents.count),
                contents: contents
            )
        }
        let mutation = PrimeSwiftSourceSnapshot(
            sourceIdentitySHA256:
                snapshot.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                snapshot
                .embeddedSourceIdentitySHA256,
            buildConfiguration:
                snapshot.buildConfiguration,
            files: files
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.validate(
                mutation,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            guard case
                .sourceIdentityMismatch =
                    error as?
                    PrimeSwiftSourceProvenanceError
            else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
        }
    }

    func testEmbeddedMutationIsRejectedDespiteIdentityExclusion()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        let files = snapshot.files.map { file in
            guard file.relativePath
                == PrimeSwiftSourceProvenance
                .embeddedProvenanceRelativePath
            else {
                return file
            }
            let contents =
                file.contents + Data([0x0a])
            return PrimeSwiftSourceFileSnapshot(
                relativePath: file.relativePath,
                sha256:
                    PrimeSHA256.hexDigest(of: contents),
                byteCount: UInt64(contents.count),
                contents: contents
            )
        }
        let mutation = PrimeSwiftSourceSnapshot(
            sourceIdentitySHA256:
                snapshot.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                snapshot
                .embeddedSourceIdentitySHA256,
            buildConfiguration:
                snapshot.buildConfiguration,
            files: files
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.validate(
                mutation,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeSwiftSourceProvenanceError,
                .unsafeSourceFile(
                    PrimeSwiftSourceProvenance
                        .embeddedProvenanceRelativePath
                )
            )
        }
    }

    func testDependencyMirrorMutationFailsSourceIdentity()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        let files = snapshot.files.map { file in
            guard file.relativePath
                == ".swiftpm/configuration/mirrors.json"
            else {
                return file
            }
            let contents =
                file.contents + Data([0x0a])
            return PrimeSwiftSourceFileSnapshot(
                relativePath: file.relativePath,
                sha256:
                    PrimeSHA256.hexDigest(of: contents),
                byteCount: UInt64(contents.count),
                contents: contents
            )
        }
        let mutation = PrimeSwiftSourceSnapshot(
            sourceIdentitySHA256:
                snapshot.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                snapshot
                .embeddedSourceIdentitySHA256,
            buildConfiguration:
                snapshot.buildConfiguration,
            files: files
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.validate(
                mutation,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            guard case
                .sourceIdentityMismatch =
                    error as?
                    PrimeSwiftSourceProvenanceError
            else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
        }
    }

    func testMissingDependencyMirrorFailsCapture()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        try FileManager.default.removeItem(
            at: fixture.root.appendingPathComponent(
                ".swiftpm/configuration/mirrors.json"
            )
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            guard case let .unsafeSourceFile(path) =
                error as?
                    PrimeSwiftSourceProvenanceError
            else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
            XCTAssertTrue(
                path.hasSuffix(
                    ".swiftpm/configuration/mirrors.json"
                )
            )
        }
    }

    func testDebugBuildExpectationIsRejected()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let debugExpectation =
            PrimeSwiftSourceProvenanceExpectation(
                sourceIdentitySHA256:
                    fixture.expectation
                    .sourceIdentitySHA256,
                buildConfiguration: "debug"
            )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation: debugExpectation
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeSwiftSourceProvenanceError,
                .releaseBuildRequired("debug")
            )
        }
    }

    func testCaptureRejectsRelativeDepthAboveMaximum()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let relativeComponents =
            ["Sources"] +
            Array(
                repeating: "nested",
                count:
                    PrimeSwiftSourceProvenance
                    .maximumSnapshotRelativeDepth
            )
        XCTAssertEqual(
            relativeComponents.count,
            PrimeSwiftSourceProvenance
                .maximumSnapshotRelativeDepth + 1
        )
        try FileManager.default.createDirectory(
            at: fixture.root.appendingPathComponent(
                relativeComponents.joined(
                    separator: "/"
                ),
                isDirectory: true
            ),
            withIntermediateDirectories: true
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeSwiftSourceProvenanceError,
                .incompleteSourceSnapshot
            )
        }
    }

    func testCaptureRejectsFileCountAboveMaximum()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let baseline =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        let addedFileCount =
            PrimeSwiftSourceProvenance
            .maximumSnapshotFileCount + 1
            - baseline.files.count
        XCTAssertGreaterThan(addedFileCount, 0)
        XCTAssertEqual(
            baseline.files.count + addedFileCount,
            PrimeSwiftSourceProvenance
                .maximumSnapshotFileCount + 1
        )
        let docs = fixture.root.appendingPathComponent(
            "docs",
            isDirectory: true
        )
        for index in 0 ..< addedFileCount {
            try Data().write(
                to: docs.appendingPathComponent(
                    String(
                        format:
                            "limit-%04d.md",
                        index
                    )
                )
            )
        }

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            guard case let .unsafeSourceFile(path) =
                    error as?
                    PrimeSwiftSourceProvenanceError
            else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
            XCTAssertTrue(
                path.contains("/docs/limit-")
                    && path.hasSuffix(".md")
            )
        }
    }

    func testCaptureRejectsSparseFileAbovePerFileLimit()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let oversizedByteCount:
            UInt64 = 8 * 1024 * 1024 + 1
        let oversized = fixture.root
            .appendingPathComponent(
                "Sources/Oversized.swift"
            )
        XCTAssertTrue(
            FileManager.default.createFile(
                atPath: oversized.path,
                contents: Data()
            )
        )
        let handle = try FileHandle(
            forWritingTo: oversized
        )
        try handle.truncate(
            atOffset: oversizedByteCount
        )
        try handle.close()
        let attributes =
            try FileManager.default.attributesOfItem(
                atPath: oversized.path
            )
        XCTAssertEqual(
            (attributes[.size] as? NSNumber)?
                .uint64Value,
            oversizedByteCount
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            guard case let .unsafeSourceFile(path) =
                    error as?
                    PrimeSwiftSourceProvenanceError
            else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
            XCTAssertTrue(
                path.hasSuffix(
                    "/Sources/Oversized.swift"
                )
            )
        }
    }

    private struct Fixture {
        let root: URL
        let expectation:
            PrimeSwiftSourceProvenanceExpectation
    }

    private struct IdentityRecord: Codable {
        let relativePath: String
        let sha256: String
        let byteCount: UInt64

        private enum CodingKeys:
            String,
            CodingKey
        {
            case relativePath = "relative_path"
            case sha256
            case byteCount = "byte_count"
        }
    }

    private func makeFixture() throws -> Fixture {
        let root = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(
                "prime-source-provenance-" +
                    UUID().uuidString,
                isDirectory: true
            )
        for directory in [
            ".swiftpm/configuration",
            "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration",
            "Tests/PrimeNativeNeuralGateMLXValidation/.swiftpm/configuration",
            "Tests/PrimeValidationWorkflow/.swiftpm/configuration",
            "Sources/PrimeCore",
            "Tests",
            "docs",
        ] {
            try FileManager.default.createDirectory(
                at: root.appendingPathComponent(
                    directory,
                    isDirectory: true
                ),
                withIntermediateDirectories: true
            )
        }
        var contents: [String: Data] = [
            ".gitignore": Data(".build/\n".utf8),
            ".swiftpm/configuration/mirrors.json":
                Data(
                    """
                    {
                      "object" : [
                        {
                          "mirror" : "https://github.com/Ergentics/ergentics-mlx-swift",
                          "original" : "https://github.com/ml-explore/mlx-swift"
                        }
                      ],
                      "version" : 1
                    }

                    """.utf8
                ),
            "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration/mirrors.json":
                Data(
                    """
                    {
                      "object" : [
                        {
                          "mirror" : "https://github.com/Ergentics/ergentics-mlx-swift",
                          "original" : "https://github.com/ml-explore/mlx-swift"
                        }
                      ],
                      "version" : 1
                    }

                    """.utf8
                ),
            "Tests/PrimeNativeNeuralGateMLXValidation/.swiftpm/configuration/mirrors.json":
                Data(
                    """
                    {
                      "object" : [
                        {
                          "mirror" : "https://github.com/Ergentics/ergentics-mlx-swift",
                          "original" : "https://github.com/ml-explore/mlx-swift"
                        }
                      ],
                      "version" : 1
                    }

                    """.utf8
                ),
            "Tests/PrimeValidationWorkflow/.swiftpm/configuration/mirrors.json":
                Data(
                    """
                    {
                      "object" : [
                        {
                          "mirror" : "https://github.com/Ergentics/ergentics-mlx-swift",
                          "original" : "https://github.com/ml-explore/mlx-swift"
                        }
                      ],
                      "version" : 1
                    }

                    """.utf8
                ),
            "LICENSE": Data("first-party\n".utf8),
            "Package.swift":
                Data("// swift-tools-version: 5.10\n".utf8),
            "Package.resolved": Data("{}\n".utf8),
            "README.md": Data("# Fixture\n".utf8),
            "THIRD_PARTY_NOTICES.md":
                Data("# Notices\n".utf8),
            "Sources/Fixture.swift":
                Data("struct Fixture {}\n".utf8),
            "Tests/FixtureTests.swift":
                Data("import XCTest\n".utf8),
            "docs/ARCHITECTURE.md":
                Data("# Architecture\n".utf8),
        ]
        for (relativePath, data) in contents {
            try data.write(
                to: root.appendingPathComponent(
                    relativePath
                )
            )
        }
        let records = contents
            .map {
                IdentityRecord(
                    relativePath: $0.key,
                    sha256:
                        PrimeSHA256.hexDigest(
                            of: $0.value
                        ),
                    byteCount: UInt64($0.value.count)
                )
            }
            .sorted {
                $0.relativePath < $1.relativePath
            }
        let identity = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(
                records
            )
        )
        let embedded =
            PrimeSwiftSourceProvenance
                .canonicalEmbeddedProvenanceSource(
                    sourceIdentitySHA256: identity
                )
        contents[
            PrimeSwiftSourceProvenance
                .embeddedProvenanceRelativePath
        ] = embedded
        try embedded.write(
            to: root.appendingPathComponent(
                PrimeSwiftSourceProvenance
                    .embeddedProvenanceRelativePath
            )
        )
        return Fixture(
            root: root,
            expectation:
                PrimeSwiftSourceProvenanceExpectation(
                    sourceIdentitySHA256: identity,
                    buildConfiguration: "release"
                )
        )
    }
}
