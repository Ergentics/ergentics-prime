#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation
import PrimeCore
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics
@testable import PrimeNativeNeuralGateReplaySourceBinding
import XCTest

final class PrimeNativeNeuralGateReplaySourceBindingTests:
    XCTestCase
{
    private var temporaryRoots = [URL]()

    override func tearDownWithError() throws {
        for root in temporaryRoots {
            try? FileManager.default.removeItem(
                at: root
            )
        }
        temporaryRoots.removeAll()
    }

    func testSmallStreamIsDescriptorBoundInExactLockstep()
        throws
    {
        let (rootURL, root) = try makeRoot()
        let records = [
            Data("alpha".utf8),
            Data("beta".utf8),
            Data("gamma".utf8),
        ]
        let plan = try publishPlan(
            root: root,
            records: records
        )

        let result = try
            PrimeNativeNeuralGateReplaySourceBinding
            ._bindInvariantRecordsForTesting(
                artifactRoot: root,
                plan: plan
            )

        XCTAssertEqual(result.records, records)
        XCTAssertEqual(
            result.rootIdentity,
            try root.verifiedRootIdentity()
        )
        XCTAssertEqual(result.fileObservations.count, 2)
        XCTAssertEqual(
            result.fileObservations.map(\.actualMode),
            [0o444, 0o444]
        )
        XCTAssertTrue(
            result.fileObservations.allSatisfy {
                $0.linkCount == 1
                    && $0.sha256.utf8.count == 64
                    && $0.byteCount > 0
            }
        )
        XCTAssertEqual(
            result.sourceBindingSHA256.utf8.count,
            64
        )
        XCTAssertEqual(root.directoryURL, rootURL)
    }

    func testSymlinkArtifactFailsClosed() throws {
        let (rootURL, root) = try makeRoot()
        try root.ensurePrivateDirectory(at: "streams")
        try root.ensurePrivateDirectory(
            at: "streams/chunks"
        )
        let record = Data("alpha".utf8)
        let bundle = try
            PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: [record])
        let target = try root.publish(
            bundle.globalStream,
            at: "target.bin",
            purpose: .immutableData
        )
        let chunk = try root.publish(
            bundle.chunkStreams[0],
            at: "streams/chunks/00000000.bin",
            purpose: .immutableData
        )
        try FileManager.default.createSymbolicLink(
            at: rootURL.appendingPathComponent(
                "streams/global.bin"
            ),
            withDestinationURL:
                rootURL.appendingPathComponent(
                    "target.bin"
                )
        )
        let plan =
            _PrimeNativeNeuralGateSourceBindingTestPlan(
                globalBinding: PrimeArtifactBinding(
                    relativePath: "streams/global.bin",
                    sha256: target.sha256,
                    byteCount: target.byteCount,
                    purpose: .immutableData
                ),
                chunks: [
                    .init(
                        ordinal: 0,
                        recordCount: 1,
                        binding: chunk
                    ),
                ],
                recordCount: 1,
                maximumRecordByteCount: 64
            )

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateReplaySourceBinding
                ._bindInvariantRecordsForTesting(
                    artifactRoot: root,
                    plan: plan
                )
        ) {
            XCTAssertEqual(
                $0 as? PrimeNativeNeuralGateReplaySourceBindingError,
                .artifactVerificationFailed
            )
        }
    }

    func testWritableArtifactFailsClosed() throws {
        let (rootURL, root) = try makeRoot()
        let plan = try publishPlan(
            root: root,
            records: [Data("alpha".utf8)]
        )
        let status = chmod(
            rootURL.appendingPathComponent(
                plan.globalBinding.relativePath
            ).path,
            mode_t(0o644)
        )
        XCTAssertEqual(status, 0)

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateReplaySourceBinding
                ._bindInvariantRecordsForTesting(
                    artifactRoot: root,
                    plan: plan
                )
        ) {
            XCTAssertEqual(
                $0 as? PrimeNativeNeuralGateReplaySourceBindingError,
                .artifactVerificationFailed
            )
        }
    }

    func testWrongDeclaredSizeAndHashFailClosed()
        throws
    {
        let (_, root) = try makeRoot()
        let plan = try publishPlan(
            root: root,
            records: [Data("alpha".utf8)]
        )
        let wrongSize = plan.replacingGlobalBinding(
            PrimeArtifactBinding(
                relativePath:
                    plan.globalBinding.relativePath,
                sha256: plan.globalBinding.sha256,
                byteCount:
                    plan.globalBinding.byteCount + 1,
                purpose: .immutableData
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateReplaySourceBinding
                ._bindInvariantRecordsForTesting(
                    artifactRoot: root,
                    plan: wrongSize
                )
        )

        let replacement = plan.globalBinding.sha256
            .hasPrefix("0")
            ? String(repeating: "1", count: 64)
            : String(repeating: "0", count: 64)
        let wrongHash = plan.replacingGlobalBinding(
            PrimeArtifactBinding(
                relativePath:
                    plan.globalBinding.relativePath,
                sha256: replacement,
                byteCount:
                    plan.globalBinding.byteCount,
                purpose: .immutableData
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateReplaySourceBinding
                ._bindInvariantRecordsForTesting(
                    artifactRoot: root,
                    plan: wrongHash
                )
        )
    }

    func testSingleLinkRequirementRejectsHardLink()
        throws
    {
        let (rootURL, root) = try makeRoot()
        let plan = try publishPlan(
            root: root,
            records: [Data("alpha".utf8)]
        )
        let original = rootURL.appendingPathComponent(
            plan.globalBinding.relativePath
        ).path
        let alias = rootURL.appendingPathComponent(
            "global-hardlink.bin"
        ).path
        XCTAssertEqual(link(original, alias), 0)

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateReplaySourceBinding
                ._bindInvariantRecordsForTesting(
                    artifactRoot: root,
                    plan: plan
                )
        ) {
            XCTAssertEqual(
                $0 as? PrimeNativeNeuralGateReplaySourceBindingError,
                .artifactVerificationFailed
            )
        }
    }

    func testPublicEntryReadsAndRejectsInvalidRootManifest()
        throws
    {
        let (_, root) = try makeRoot()
        try root.ensurePrivateDirectory(
            at: "neural-gate-replay"
        )
        try root.ensurePrivateDirectory(
            at: "neural-gate-replay/corrected"
        )
        try root.ensurePrivateDirectory(
            at:
                "neural-gate-replay/corrected/fixture"
        )
        let spec = try
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4.spec(
                for: .promptOnlyFixtureManifest
            )
        _ = try root.publish(
            Data("{}".utf8),
            at: spec.relativePath,
            purpose: .immutableData
        )

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateReplaySourceBinding
                .bindPromptRecords(
                    artifactRoot: root
                )
        ) {
            XCTAssertEqual(
                $0 as? PrimeNativeNeuralGateReplaySourceBindingError,
                .manifestRejected
            )
        }
    }

    func testGlobalChunkRecordMismatchFailsClosed()
        throws
    {
        let (_, root) = try makeRoot()
        let globalBundle = try
            PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records: [
                    Data("alpha".utf8),
                    Data("beta".utf8),
                ]
            )
        let chunkBundle = try
            PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records: [
                    Data("alpha".utf8),
                    Data("delta".utf8),
                ]
            )
        try root.ensurePrivateDirectory(at: "streams")
        try root.ensurePrivateDirectory(
            at: "streams/chunks"
        )
        let global = try root.publish(
            globalBundle.globalStream,
            at: "streams/global.bin",
            purpose: .immutableData
        )
        let chunk = try root.publish(
            chunkBundle.chunkStreams[0],
            at: "streams/chunks/00000000.bin",
            purpose: .immutableData
        )
        let plan =
            _PrimeNativeNeuralGateSourceBindingTestPlan(
                globalBinding: global,
                chunks: [
                    .init(
                        ordinal: 0,
                        recordCount: 2,
                        binding: chunk
                    ),
                ],
                recordCount: 2,
                maximumRecordByteCount: 64
            )

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateReplaySourceBinding
                ._bindInvariantRecordsForTesting(
                    artifactRoot: root,
                    plan: plan
                )
        ) {
            XCTAssertEqual(
                $0 as? PrimeNativeNeuralGateReplaySourceBindingError,
                .globalChunkRecordMismatch
            )
        }
    }

    func testRecordMutationIsRejectedByTypedBoundary()
        throws
    {
        let (_, root) = try makeRoot()
        let mutated = Data("mutated".utf8)
        let plan = try publishPlan(
            root: root,
            records: [mutated]
        )

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateReplaySourceBinding
                ._bindInvariantRecordsForTesting(
                    artifactRoot: root,
                    plan: plan
                ) { record in
                    guard record != mutated else {
                        throw TestMutationError.detected
                    }
                }
        ) {
            XCTAssertEqual(
                $0 as? PrimeNativeNeuralGateReplaySourceBindingError,
                .recordRejected
            )
        }
    }

    func testPerRecordBoundFailsBeforeMaterialization()
        throws
    {
        let (_, root) = try makeRoot()
        let plan = try publishPlan(
            root: root,
            records: [Data("four".utf8)],
            maximumRecordByteCount: 3
        )

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateReplaySourceBinding
                ._bindInvariantRecordsForTesting(
                    artifactRoot: root,
                    plan: plan
                )
        ) {
            XCTAssertEqual(
                $0 as? PrimeNativeNeuralGateReplaySourceBindingError,
                .recordByteLimitExceeded
            )
        }
    }

    func testAuthorityRemainsFalseAndTraversalIsDelegated()
        throws
    {
        XCTAssertTrue(
            PrimeNativeNeuralGateReplaySourceBindingPolicy
                .descriptorTraversalDelegatedToPrimeCore
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplaySourceBindingPolicy
                .writableArtifactHandlesOpened
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplaySourceBindingAuthority
                .publicationAuthorized
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplaySourceBindingAuthority
                .sourceBindingV7Issued
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplaySourceBindingAuthority
                .correctedFixtureIdentityEstablished
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplaySourceBindingAuthority
                .durableArtifactOriginEstablished
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplaySourceBindingAuthority
                .modelExecutionEstablished
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplaySourceBindingAuthority
                .mutationDetectionAuthorized
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplaySourceBindingAuthority
                .mechanicsPassAuthorized
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplaySourceBindingAuthority
                .terminalReceiptAuthorized
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplaySourceBindingAuthority
                .scientificAuthorityAuthorized
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplaySourceBindingAuthority
                .productAuthorityAuthorized
        )

        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources")
            .appendingPathComponent(
                "PrimeNativeNeuralGateReplaySourceBinding"
            )
            .appendingPathComponent(
                "PrimeNativeNeuralGateReplaySourceBinding.swift"
            )
        let source = try String(
            contentsOf: sourceURL,
            encoding: .utf8
        )
        XCTAssertTrue(
            source.contains(
                ".withVerifiedArtifactDescriptor("
            )
        )
        XCTAssertTrue(
            source.contains(".bindExisting(")
        )
        XCTAssertFalse(source.contains("openat("))
        XCTAssertFalse(source.contains("O_NOFOLLOW"))
        XCTAssertFalse(source.contains("FileManager"))
    }

    private func makeRoot() throws
        -> (URL, PrimeArtifactRoot)
    {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "prime-source-binding-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: false,
            attributes: [
                .posixPermissions: NSNumber(value: 0o700),
            ]
        )
        temporaryRoots.append(url)
        return (
            url,
            try PrimeArtifactRoot(directoryURL: url)
        )
    }

    private func publishPlan(
        root: PrimeArtifactRoot,
        records: [Data],
        maximumRecordByteCount: Int = 64
    ) throws
        -> _PrimeNativeNeuralGateSourceBindingTestPlan
    {
        try root.ensurePrivateDirectory(at: "streams")
        try root.ensurePrivateDirectory(
            at: "streams/chunks"
        )
        let bundle = try
            PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: records)
        let global = try root.publish(
            bundle.globalStream,
            at: "streams/global.bin",
            purpose: .immutableData
        )
        var chunks =
            [_PrimeNativeNeuralGateSourceBindingTestChunkPlan]()
        for (index, data) in
            bundle.chunkStreams.enumerated()
        {
            let decoded = try
                PrimeNativeNeuralGateInvariantCodec
                .decodeChunk(data)
            let binding = try root.publish(
                data,
                at: String(
                    format:
                        "streams/chunks/%08d.bin",
                    index
                ),
                purpose: .immutableData
            )
            chunks.append(
                .init(
                    ordinal: decoded.ordinal,
                    recordCount:
                        UInt32(decoded.records.count),
                    binding: binding
                )
            )
        }
        return _PrimeNativeNeuralGateSourceBindingTestPlan(
            globalBinding: global,
            chunks: chunks,
            recordCount: UInt32(records.count),
            maximumRecordByteCount:
                maximumRecordByteCount
        )
    }
}

private enum TestMutationError: Error {
    case detected
}

private extension
    _PrimeNativeNeuralGateSourceBindingTestPlan
{
    func replacingGlobalBinding(
        _ binding: PrimeArtifactBinding
    ) -> Self {
        Self(
            globalBinding: binding,
            chunks: chunks,
            recordCount: recordCount,
            maximumRecordByteCount:
                maximumRecordByteCount
        )
    }
}
