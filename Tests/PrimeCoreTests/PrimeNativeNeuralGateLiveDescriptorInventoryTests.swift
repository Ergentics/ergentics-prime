import Darwin
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeNeuralGateLiveDescriptorInventoryTests:
    XCTestCase
{
    private struct StageBFixture {
        let output:
            PrimeNativeNeuralGateReplayOutputContract
        let stageAArtifacts:
            [PrimeArtifactBinding]
        let historicalProbeChunks:
            [PrimeArtifactBinding]
        let historicalVerifierChunks:
            [PrimeArtifactBinding]
        let correctedChunks:
            [PrimeArtifactBinding]
        let allArtifacts:
            [PrimeArtifactBinding]
    }

    func testFullRootCaptureIsExactAndStable()
        throws
    {
        try withArtifactRoot {
            _, root in
            let artifacts =
                try publish(
                    [
                        (
                            "role/record.json",
                            "record",
                            .immutableData
                        ),
                        (
                            "role/bin/worker",
                            "worker",
                            .executable
                        ),
                    ],
                    in: root
                )
            let capability =
                try root.captureTrustedInventory(
                    expectedArtifacts:
                        artifacts
                )
            let inventory =
                capability.inventory

            XCTAssertNil(
                inventory.rootRelativePath
            )
            XCTAssertEqual(
                inventory.fileEntries
                    .map(\.artifact),
                sorted(artifacts)
            )
            XCTAssertEqual(
                inventory.directoryEntries
                    .map(\.relativePath),
                [
                    "role",
                    "role/bin",
                ]
            )
            XCTAssertTrue(
                inventory
                    .unsupportedNodeRelativePaths
                    .isEmpty
            )
            XCTAssertTrue(
                inventory
                    .enumerationIncludesAllNodeTypes
            )
            XCTAssertFalse(
                inventory.symbolicLinksFollowed
            )
            try inventory
                .validateExactNodeClosure(
                    expectedFileEntries:
                        inventory.fileEntries
                )
            XCTAssertEqual(
                try capability
                    .recaptureAndValidateUnchanged(),
                inventory
            )
            XCTAssertNoThrow(
                try capability
                    .validateCurrentInventory(
                        equals: inventory
                    )
            )
            let forgedTransport =
                PrimeNativeNeuralGateRealizedFilesystemInventory(
                    rootRelativePath:
                        inventory
                        .rootRelativePath,
                    directoryEntries:
                        inventory
                        .directoryEntries,
                    fileEntries:
                        Array(
                            inventory
                            .fileEntries
                            .dropLast()
                        ),
                    unsupportedNodeRelativePaths:
                        inventory
                        .unsupportedNodeRelativePaths,
                    enumerationIncludesAllNodeTypes:
                        inventory
                        .enumerationIncludesAllNodeTypes,
                    symbolicLinksFollowed:
                        inventory
                        .symbolicLinksFollowed
                )
            XCTAssertThrowsError(
                try capability
                    .validateCurrentInventory(
                        equals:
                            forgedTransport
                    )
            )
        }
    }

    func testRolePrefixCaptureKeepsArtifactRootRelativePaths()
        throws
    {
        try withArtifactRoot {
            _, root in
            let artifacts =
                try publish(
                    [
                        (
                            "historical/probe/record.json",
                            "record",
                            .immutableData
                        ),
                        (
                            "historical/probe/chunks/00000000.bin",
                            "chunk",
                            .immutableData
                        ),
                    ],
                    in: root
                )
            let capability =
                try root.captureTrustedInventory(
                    rolePrefix:
                        "historical/probe",
                    expectedArtifacts:
                        artifacts
                )
            let inventory =
                capability.inventory

            XCTAssertEqual(
                inventory.rootRelativePath,
                "historical/probe"
            )
            XCTAssertEqual(
                inventory.fileEntries
                    .map(\.artifact),
                sorted(artifacts)
            )
            XCTAssertEqual(
                inventory.directoryEntries
                    .map(\.relativePath),
                [
                    "historical/probe/chunks",
                ]
            )
            try inventory
                .validateExactNodeClosure(
                    expectedFileEntries:
                        inventory.fileEntries
                )
            XCTAssertEqual(
                try capability
                    .recaptureAndValidateUnchanged(),
                inventory
            )
        }
    }

    func testCaptureRejectsMissingFileAndDirectory()
        throws
    {
        try withArtifactRoot {
            url, root in
            let artifacts =
                try publish(
                    [
                        (
                            "role/missing/value.bin",
                            "value",
                            .immutableData
                        ),
                    ],
                    in: root
                )
            XCTAssertEqual(
                unlink(
                    url.appendingPathComponent(
                        "role/missing/value.bin"
                    ).path
                ),
                0
            )
            XCTAssertEqual(
                rmdir(
                    url.appendingPathComponent(
                        "role/missing"
                    ).path
                ),
                0
            )

            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts:
                    artifacts
            )
        }
    }

    func testCaptureRejectsExtraFileAndExtraDirectory()
        throws
    {
        try withArtifactRoot {
            _, root in
            let expected =
                try publish(
                    [
                        (
                            "expected.bin",
                            "expected",
                            .immutableData
                        ),
                    ],
                    in: root
                )
            _ = try publish(
                [
                    (
                        "extra.bin",
                        "extra",
                        .immutableData
                    ),
                ],
                in: root
            )

            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts:
                    expected
            )
        }

        try withArtifactRoot {
            _, root in
            let expected =
                try publish(
                    [
                        (
                            "expected.bin",
                            "expected",
                            .immutableData
                        ),
                    ],
                    in: root
                )
            try root.ensurePrivateDirectory(
                at: "extra-empty"
            )

            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts:
                    expected
            )
        }
    }

    func testCaptureRejectsExpectedPathReplacedBySymbolicLink()
        throws
    {
        try withArtifactRoot {
            url, root in
            let expected =
                try publish(
                    [
                        (
                            "target.bin",
                            "target",
                            .immutableData
                        ),
                        (
                            "expected-node",
                            "target",
                            .immutableData
                        ),
                    ],
                    in: root
                )
            XCTAssertEqual(
                unlink(
                    url.appendingPathComponent(
                        "expected-node"
                    ).path
                ),
                0
            )
            XCTAssertEqual(
                symlink(
                    "target.bin",
                    url.appendingPathComponent(
                        "expected-node"
                    ).path
                ),
                0
            )

            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts:
                    expected
            )
        }
    }

    func testCaptureRejectsExpectedPathReplacedByFIFO()
        throws
    {
        try withArtifactRoot {
            url, root in
            let expected =
                try publish(
                    [
                        (
                            "expected-node",
                            "expected",
                            .immutableData
                        ),
                    ],
                    in: root
                )
            XCTAssertEqual(
                unlink(
                    url.appendingPathComponent(
                        "expected-node"
                    ).path
                ),
                0
            )
            XCTAssertEqual(
                mkfifo(
                    url.appendingPathComponent(
                        "expected-node"
                    ).path,
                    mode_t(0o444)
                ),
                0
            )

            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts:
                    expected
            )
        }
    }

    func testCaptureRejectsExpectedPathReplacedByUnixSocketWhenPermitted()
        throws
    {
        try withArtifactRoot {
            url, root in
            let expected =
                try publish(
                    [
                        (
                            "expected-node",
                            "expected",
                            .immutableData
                        ),
                    ],
                    in: root
                )
            XCTAssertEqual(
                unlink(
                    url.appendingPathComponent(
                        "expected-node"
                    ).path
                ),
                0
            )
            let socketDescriptor: Int32
            do {
                socketDescriptor =
                    try createUnixSocket(
                        at:
                            url.appendingPathComponent(
                                "expected-node"
                            )
                    )
            } catch let error as POSIXError
                where error.code == .EPERM
                    || error.code == .EACCES
            {
                throw XCTSkip(
                    "Unix-domain socket creation is denied by the test sandbox"
                )
            }
            defer {
                _ = Darwin.close(
                    socketDescriptor
                )
            }

            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts:
                    expected
            )
        }
    }

    func testCaptureRejectsHardLinkedArtifact()
        throws
    {
        try withArtifactRoot {
            url, root in
            let original =
                try XCTUnwrap(
                    publish(
                    [
                        (
                            "original.bin",
                            "original",
                            .immutableData
                        ),
                    ],
                    in: root
                    ).first
                )
            XCTAssertEqual(
                link(
                    url.appendingPathComponent(
                        "original.bin"
                    ).path,
                    url.appendingPathComponent(
                        "alias.bin"
                    ).path
                ),
                0
            )
            let alias =
                PrimeArtifactBinding(
                    relativePath:
                        "alias.bin",
                    sha256:
                        original.sha256,
                    byteCount:
                        original.byteCount,
                    purpose:
                        original.purpose
                )

            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts:
                    sorted(
                        [
                            original,
                            alias,
                        ]
                    )
            )
        }
    }

    func testRecaptureRejectsSameSizeContentMutationAndExtraDirectory()
        throws
    {
        try withArtifactRoot {
            url, root in
            let expected =
                try publish(
                    [
                        (
                            "stable.bin",
                            "original",
                            .immutableData
                        ),
                    ],
                    in: root
                )
            let capability =
                try root.captureTrustedInventory(
                    expectedArtifacts:
                        expected
                )
            let artifactURL =
                url.appendingPathComponent(
                    "stable.bin"
                )
            XCTAssertEqual(
                chmod(
                    artifactURL.path,
                    mode_t(0o600)
                ),
                0
            )
            let descriptor =
                Darwin.open(
                    artifactURL.path,
                    O_WRONLY
                        | O_TRUNC
                        | O_CLOEXEC
                )
            XCTAssertGreaterThanOrEqual(
                descriptor,
                0
            )
            if descriptor >= 0 {
                let replacement =
                    Array("mutated!".utf8)
                let written =
                    replacement
                    .withUnsafeBytes {
                        Darwin.write(
                            descriptor,
                            $0.baseAddress,
                            $0.count
                        )
                    }
                XCTAssertEqual(
                    written,
                    replacement.count
                )
                _ = Darwin.close(
                    descriptor
                )
            }
            XCTAssertEqual(
                chmod(
                    artifactURL.path,
                    mode_t(0o444)
                ),
                0
            )

            XCTAssertThrowsError(
                try capability
                    .recaptureAndValidateUnchanged()
            )
        }

        try withArtifactRoot {
            _, root in
            let expected =
                try publish(
                    [
                        (
                            "stable.bin",
                            "stable",
                            .immutableData
                        ),
                    ],
                    in: root
                )
            let capability =
                try root.captureTrustedInventory(
                    expectedArtifacts:
                        expected
                )
            try root.ensurePrivateDirectory(
                at: "added-empty"
            )

            XCTAssertThrowsError(
                try capability
                    .recaptureAndValidateUnchanged()
            )
        }
    }

    func testRolePrefixRejectsExpectedArtifactOutsidePrefix()
        throws
    {
        try withArtifactRoot {
            _, root in
            let artifacts =
                try publish(
                    [
                        (
                            "role/inside.bin",
                            "inside",
                            .immutableData
                        ),
                        (
                            "outside.bin",
                            "outside",
                            .immutableData
                        ),
                    ],
                    in: root
                )

            XCTAssertThrowsError(
                try root.captureTrustedInventory(
                    rolePrefix: "role",
                    expectedArtifacts:
                        artifacts
                )
            )
        }
    }

    func testCaptureRejectsNonASCIIPathIdentity()
        throws
    {
        try withArtifactRoot {
            _, root in
            let artifact =
                try publish(
                    [
                        (
                            "role/café.bin",
                            "value",
                            .immutableData
                        ),
                    ],
                    in: root
                )

            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts:
                    artifact
            )
            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts: []
            )
        }
    }

    func testCaptureRejectsWrongFileAndDirectoryModes()
        throws
    {
        try withArtifactRoot {
            url, root in
            let expected =
                try publish(
                    [
                        (
                            "wrong-mode.bin",
                            "value",
                            .immutableData
                        ),
                    ],
                    in: root
                )
            XCTAssertEqual(
                chmod(
                    url.appendingPathComponent(
                        "wrong-mode.bin"
                    ).path,
                    mode_t(0o600)
                ),
                0
            )

            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts:
                    expected
            )
        }

        try withArtifactRoot {
            url, root in
            let expected =
                try publish(
                    [
                        (
                            "wrong-directory-mode/value.bin",
                            "value",
                            .immutableData
                        ),
                    ],
                    in: root
                )
            XCTAssertEqual(
                chmod(
                    url.appendingPathComponent(
                        "wrong-directory-mode"
                    ).path,
                    mode_t(0o755)
                ),
                0
            )

            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts:
                    expected
            )
        }
    }

    func testCaptureRejectsDigestAndByteCountMismatch()
        throws
    {
        try withArtifactRoot {
            _, root in
            let artifact =
                try XCTUnwrap(
                    publish(
                        [
                            (
                                "bound.bin",
                                "bound",
                                .immutableData
                            ),
                        ],
                        in: root
                    ).first
                )
            let wrongDigest =
                PrimeArtifactBinding(
                    relativePath:
                        artifact.relativePath,
                    sha256:
                        String(
                            repeating: "0",
                            count: 64
                        ),
                    byteCount:
                        artifact.byteCount,
                    purpose:
                        artifact.purpose
                )
            let wrongByteCount =
                PrimeArtifactBinding(
                    relativePath:
                        artifact.relativePath,
                    sha256:
                        artifact.sha256,
                    byteCount:
                        artifact.byteCount + 1,
                    purpose:
                        artifact.purpose
                )

            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts: [
                    wrongDigest,
                ]
            )
            assertFullRootCaptureRejected(
                root: root,
                expectedArtifacts: [
                    wrongByteCount,
                ]
            )
        }
    }

    func testLiveFullRootCaptureFeedsExactStageBValidator()
        throws
    {
        try withArtifactRoot {
            _, root in
            let fixture =
                try makeStageBFixture(
                    in: root
                )
            let capture =
                try root.captureTrustedInventory(
                    expectedArtifacts:
                        fixture.allArtifacts
                )

            XCTAssertNoThrow(
                try fixture.output
                    .validatePreReceiptRealizedPathAndMetadataInventory(
                        capture,
                        authenticatedStageACopiedArtifacts:
                            fixture
                            .stageAArtifacts,
                        historicalProbeChunks:
                            fixture
                            .historicalProbeChunks,
                        historicalVerifierChunks:
                            fixture
                            .historicalVerifierChunks,
                        correctedChunks:
                            fixture
                            .correctedChunks
                    )
            )
        }
    }

    func testLiveCaptureCannotAuthorizePrematureReceiptOrForbiddenStageAPath()
        throws
    {
        try withArtifactRoot {
            _, root in
            let fixture =
                try makeStageBFixture(
                    in: root
                )
            let receipt =
                try XCTUnwrap(
                    publish(
                        [
                            (
                                fixture.output
                                    .receiptRelativePath,
                                "premature-receipt",
                                .immutableData
                            ),
                        ],
                        in: root
                    ).first
                )
            let capture =
                try root.captureTrustedInventory(
                    expectedArtifacts:
                        sorted(
                            fixture.allArtifacts
                                + [receipt]
                        )
                )

            assertStageBInventoryRejected(
                capture,
                fixture: fixture
            )
        }

        try withArtifactRoot {
            _, root in
            let fixture =
                try makeStageBFixture(
                    in: root
                )
            let forbidden =
                try XCTUnwrap(
                    publish(
                        [
                            (
                                "neural-gate-replay/parent/stage-a/README.md",
                                "unbound-parent-file",
                                .immutableData
                            ),
                        ],
                        in: root
                    ).first
                )
            let capture =
                try root.captureTrustedInventory(
                    expectedArtifacts:
                        sorted(
                            fixture.allArtifacts
                                + [forbidden]
                        )
                )

            assertStageBInventoryRejected(
                capture,
                fixture: fixture
            )
        }
    }

    func testLiveCaptureCannotAuthorizeChunkGap()
        throws
    {
        try withArtifactRoot {
            _, root in
            let fixture =
                try makeStageBFixture(
                    in: root
                )
            let gappedChunkPath =
                chunkPath(
                    pattern:
                        fixture.output
                        .historicalProbeChunkRelativePathPattern,
                    ordinal: 2
                )
            let gappedChunk =
                try XCTUnwrap(
                    publish(
                        [
                            (
                                gappedChunkPath,
                                "gapped-chunk",
                                .immutableData
                            ),
                        ],
                        in: root
                    ).first
                )
            let capture =
                try root.captureTrustedInventory(
                    expectedArtifacts:
                        sorted(
                            fixture.allArtifacts
                                + [gappedChunk]
                        )
                )

            XCTAssertThrowsError(
                try fixture.output
                    .validatePreReceiptRealizedPathAndMetadataInventory(
                        capture,
                        authenticatedStageACopiedArtifacts:
                            fixture
                            .stageAArtifacts,
                        historicalProbeChunks:
                            fixture
                            .historicalProbeChunks
                            + [gappedChunk],
                        historicalVerifierChunks:
                            fixture
                            .historicalVerifierChunks,
                        correctedChunks:
                            fixture
                            .correctedChunks
                    )
            )
        }
    }

    func testRolePrefixCaptureCannotSubstituteForFullRootClosure()
        throws
    {
        try withArtifactRoot {
            _, root in
            let fixture =
                try makeStageBFixture(
                    in: root
                )
            let capture =
                try root.captureTrustedInventory(
                    rolePrefix:
                        "neural-gate-replay",
                    expectedArtifacts:
                        fixture.allArtifacts
                )

            XCTAssertEqual(
                capture.inventory
                    .rootRelativePath,
                "neural-gate-replay"
            )
            try capture.inventory
                .validateExactNodeClosure(
                    expectedFileEntries:
                        capture.inventory
                        .fileEntries
                )
            assertStageBInventoryRejected(
                capture,
                fixture: fixture
            )
        }
    }

    private func makeStageBFixture(
        in root: PrimeArtifactRoot
    ) throws -> StageBFixture {
        let output =
            PrimeNativeNeuralGateFixtureReplayPlan
            .frozenV3
            .outputContract
        let classifier =
            output.pathClassification
        let stageASpecifications =
            (0 ..< 36).map {
                ordinal in
                (
                    String(
                        format:
                            "neural-gate-replay/parent/stage-a/evidence-%02d.bin",
                        ordinal
                    ),
                    "stage-a-\(ordinal)",
                    ordinal < 29
                        ? PrimeArtifactPurpose
                            .immutableData
                        : .executable
                )
            }
        let fixedSpecifications =
            classifier
            .ordinaryFixedRelativePaths
            .map {
                (
                    $0,
                    "fixed:\($0)",
                    PrimeArtifactPurpose
                        .immutableData
                )
            }
            + classifier
            .runningExecutableRelativePaths
            .map {
                (
                    $0,
                    "executable:\($0)",
                    PrimeArtifactPurpose
                        .executable
                )
            }
        let historicalProbeChunkPath =
            chunkPath(
                pattern:
                    output
                    .historicalProbeChunkRelativePathPattern,
                ordinal: 0
            )
        let historicalVerifierChunkPath =
            chunkPath(
                pattern:
                    output
                    .historicalVerifierChunkRelativePathPattern,
                ordinal: 0
            )
        let correctedChunkPath =
            chunkPath(
                pattern:
                    output
                    .correctedChunkRelativePathPattern,
                ordinal: 0
            )
        let chunkSpecifications = [
            (
                historicalProbeChunkPath,
                "historical-probe-chunk",
                PrimeArtifactPurpose
                    .immutableData
            ),
            (
                historicalVerifierChunkPath,
                "historical-verifier-chunk",
                PrimeArtifactPurpose
                    .immutableData
            ),
            (
                correctedChunkPath,
                "corrected-chunk",
                PrimeArtifactPurpose
                    .immutableData
            ),
        ]

        let stageAArtifacts =
            try publish(
                stageASpecifications,
                in: root
            )
        let fixedArtifacts =
            try publish(
                fixedSpecifications,
                in: root
            )
        let chunks =
            try publish(
                chunkSpecifications,
                in: root
            )
        let historicalProbeChunks =
            chunks.filter {
                $0.relativePath
                    == historicalProbeChunkPath
            }
        let historicalVerifierChunks =
            chunks.filter {
                $0.relativePath
                    == historicalVerifierChunkPath
            }
        let correctedChunks =
            chunks.filter {
                $0.relativePath
                    == correctedChunkPath
            }

        return StageBFixture(
            output: output,
            stageAArtifacts:
                stageAArtifacts,
            historicalProbeChunks:
                historicalProbeChunks,
            historicalVerifierChunks:
                historicalVerifierChunks,
            correctedChunks:
                correctedChunks,
            allArtifacts:
                sorted(
                    stageAArtifacts
                        + fixedArtifacts
                        + chunks
                )
        )
    }

    private func assertStageBInventoryRejected(
        _ capture:
            PrimeTrustedArtifactInventoryCapture,
        fixture: StageBFixture,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try fixture.output
                .validatePreReceiptRealizedPathAndMetadataInventory(
                    capture,
                    authenticatedStageACopiedArtifacts:
                        fixture
                        .stageAArtifacts,
                    historicalProbeChunks:
                        fixture
                        .historicalProbeChunks,
                    historicalVerifierChunks:
                        fixture
                        .historicalVerifierChunks,
                    correctedChunks:
                        fixture
                        .correctedChunks
                ),
            file: file,
            line: line
        )
    }

    private func assertFullRootCaptureRejected(
        root: PrimeArtifactRoot,
        expectedArtifacts:
            [PrimeArtifactBinding],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try root.captureTrustedInventory(
                expectedArtifacts:
                    expectedArtifacts
            ),
            file: file,
            line: line
        )
    }

    private func publish(
        _ specifications:
            [
                (
                    path: String,
                    payload: String,
                    purpose:
                        PrimeArtifactPurpose
                )
            ],
        in root: PrimeArtifactRoot
    ) throws -> [PrimeArtifactBinding] {
        try ensureParentDirectories(
            specifications.map(\.path),
            in: root
        )
        var bindings =
            [PrimeArtifactBinding]()
        bindings.reserveCapacity(
            specifications.count
        )
        for specification in specifications {
            bindings.append(
                try root.publish(
                    Data(
                        specification
                            .payload.utf8
                    ),
                    at: specification.path,
                    purpose:
                        specification
                        .purpose
                )
            )
        }
        return sorted(bindings)
    }

    private func ensureParentDirectories(
        _ paths: [String],
        in root: PrimeArtifactRoot
    ) throws {
        var directories =
            Set<String>()
        for path in paths {
            var components =
                path.split(
                    separator: "/"
                ).map(String.init)
            guard components.count > 1 else {
                continue
            }
            components.removeLast()
            while !components.isEmpty {
                directories.insert(
                    components.joined(
                        separator: "/"
                    )
                )
                components.removeLast()
            }
        }
        let ordered =
            directories.sorted {
                lhs, rhs in
                let lhsDepth =
                    lhs.split(
                        separator: "/"
                    ).count
                let rhsDepth =
                    rhs.split(
                        separator: "/"
                    ).count
                if lhsDepth != rhsDepth {
                    return lhsDepth < rhsDepth
                }
                return rawUTF8Less(
                    lhs,
                    rhs
                )
            }
        for directory in ordered {
            try root.ensurePrivateDirectory(
                at: directory
            )
        }
    }

    private func sorted(
        _ artifacts: [PrimeArtifactBinding]
    ) -> [PrimeArtifactBinding] {
        artifacts.sorted {
            rawUTF8Less(
                $0.relativePath,
                $1.relativePath
            )
        }
    }

    private func rawUTF8Less(
        _ lhs: String,
        _ rhs: String
    ) -> Bool {
        lhs.utf8.lexicographicallyPrecedes(
            rhs.utf8
        )
    }

    private func chunkPath(
        pattern: String,
        ordinal: Int
    ) -> String {
        pattern.replacingOccurrences(
            of: "{ordinal_8digit}",
            with:
                String(
                    format: "%08d",
                    ordinal
                )
        )
    }

    private func createUnixSocket(
        at url: URL
    ) throws -> Int32 {
        let descriptor =
            Darwin.socket(
                AF_UNIX,
                SOCK_STREAM,
                0
            )
        guard descriptor >= 0 else {
            throw POSIXError(
                POSIXErrorCode(
                    rawValue: errno
                )!
            )
        }
        do {
            var address =
                sockaddr_un()
            address.sun_len =
                UInt8(
                    MemoryLayout<
                        sockaddr_un
                    >.size
                )
            address.sun_family =
                sa_family_t(
                    AF_UNIX
                )
            let path = url.path
            let pathCapacity =
                MemoryLayout.size(
                    ofValue:
                        address.sun_path
                )
            guard path.utf8.count
                    < pathCapacity else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "test_unix_socket_path_too_long"
                    )
            }
            withUnsafeMutablePointer(
                to: &address.sun_path
            ) {
                pointer in
                pointer.withMemoryRebound(
                    to: CChar.self,
                    capacity:
                        pathCapacity
                ) {
                    destination in
                    _ = strlcpy(
                        destination,
                        path,
                        pathCapacity
                    )
                }
            }
            let result =
                withUnsafePointer(
                    to: &address
                ) {
                    pointer in
                    pointer.withMemoryRebound(
                        to: sockaddr.self,
                        capacity: 1
                    ) {
                        Darwin.bind(
                            descriptor,
                            $0,
                            socklen_t(
                                MemoryLayout<
                                    sockaddr_un
                                >.size
                            )
                        )
                    }
                }
            guard result == 0 else {
                throw POSIXError(
                    POSIXErrorCode(
                        rawValue: errno
                    )!
                )
            }
            return descriptor
        } catch {
            _ = Darwin.close(
                descriptor
            )
            throw error
        }
    }

    private func withArtifactRoot(
        _ body:
            (URL, PrimeArtifactRoot)
            throws -> Void
    ) throws {
        let directory =
            URL(
                fileURLWithPath:
                    "/private/tmp",
                isDirectory: true
            )
            .appendingPathComponent(
                "PrimeTrustedInventory-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default
            .createDirectory(
                at: directory,
                withIntermediateDirectories:
                    false,
                attributes: [
                    .posixPermissions:
                        NSNumber(
                            value: 0o700
                        ),
                ]
            )
        guard chmod(
            directory.path,
            mode_t(0o700)
        ) == 0 else {
            throw POSIXError(
                POSIXErrorCode(
                    rawValue: errno
                )!
            )
        }
        defer {
            try? FileManager.default
                .removeItem(
                    at: directory
                )
        }
        try body(
            directory,
            try PrimeArtifactRoot(
                directoryURL: directory
            )
        )
    }
}
