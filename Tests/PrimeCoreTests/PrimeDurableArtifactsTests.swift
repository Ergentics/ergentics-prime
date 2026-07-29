import Darwin
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeDurableArtifactsTests: XCTestCase {
    private struct SeedDocument: Codable {
        let initialization: UInt64
        let trainingSchedule: UInt64
        let evaluation: UInt64

        private enum CodingKeys: String, CodingKey {
            case initialization
            case trainingSchedule = "training_schedule"
            case evaluation
        }
    }

    private struct Fixture {
        let root: PrimeArtifactRoot
        let seeds: PrimeExecutionSeeds
        let executable: PrimeArtifactBinding
        let source: PrimeArtifactBinding
        let configuration: PrimeArtifactBinding
        let artifacts: PrimeExecutionArtifactBindings
        let calibration: PrimeArtifactBinding
        let exclusionReason: String

        var authorization: PrimeRunAuthorization {
            PrimeRunAuthorization(
                seeds: seeds,
                artifacts: artifacts,
                calibrationReceipt: calibration,
                externalExecutionExclusionReason:
                    exclusionReason
            )
        }
    }

    private var temporaryURL: URL!

    override func setUpWithError() throws {
        temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "ergentics-prime-durable-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: temporaryURL,
            withIntermediateDirectories: false
        )
        guard chmod(temporaryURL.path, 0o700) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
    }

    override func tearDownWithError() throws {
        if let temporaryURL {
            try? FileManager.default.removeItem(
                at: temporaryURL
            )
        }
    }

    func testCanonicalObservationPreservesNullVersusFalse() throws {
        let unavailable =
            PrimeBooleanObservation.unavailable
        let observedFalse =
            PrimeBooleanObservation.observed(false)

        let unavailableData =
            try PrimeCanonicalJSON.encode(unavailable)
        let falseData =
            try PrimeCanonicalJSON.encode(observedFalse)

        XCTAssertNotEqual(unavailableData, falseData)
        XCTAssertEqual(
            String(decoding: unavailableData, as: UTF8.self),
            #"{"observation_available":false,"value":null}"#
        )
        XCTAssertEqual(
            String(decoding: falseData, as: UTF8.self),
            #"{"observation_available":true,"value":false}"#
        )
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                PrimeBooleanObservation.self,
                from: unavailableData
            ),
            unavailable
        )
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                PrimeBooleanObservation.self,
                from: falseData
            ),
            observedFalse
        )

        let missingValue = Data(
            #"{"observation_available":false}"#.utf8
        )
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                PrimeBooleanObservation.self,
                from: missingValue
            )
        )
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.encode(
                PrimeBooleanObservation(
                    observationAvailable: false,
                    value: false
                )
            )
        )
    }

    func testImmutablePublicationVerifiesExactAndRejectsOverwrite()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let original = Data("first".utf8)
        let first = try root.publish(
            original,
            at: "artifact.bin",
            purpose: .immutableData
        )
        let repeated = try root.publish(
            original,
            at: "artifact.bin",
            purpose: .immutableData
        )
        XCTAssertEqual(first, repeated)
        XCTAssertEqual(
            try root.readVerified(first),
            original
        )

        XCTAssertThrowsError(
            try root.publish(
                Data("second".utf8),
                at: "artifact.bin",
                purpose: .immutableData
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .conflictingArtifact("artifact.bin")
            )
        }
        XCTAssertEqual(
            try root.readVerified(first),
            original
        )
    }

    func testPrivateDirectoryAndOutputPreflightUseTrustedRoot()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        try root.ensurePrivateDirectory(
            at: "content-staging"
        )
        var metadata = stat()
        let directoryURL = temporaryURL
            .appendingPathComponent(
                "content-staging",
                isDirectory: true
            )
        XCTAssertEqual(
            lstat(directoryURL.path, &metadata),
            0
        )
        XCTAssertEqual(
            metadata.st_mode & mode_t(0o777),
            mode_t(0o700)
        )

        XCTAssertNoThrow(
            try root.requireAbsent(at: "receipt.json")
        )
        _ = try root.publish(
            Data("receipt".utf8),
            at: "receipt.json",
            purpose: .immutableData
        )
        XCTAssertThrowsError(
            try root.requireAbsent(at: "receipt.json")
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .conflictingArtifact("receipt.json")
            )
        }
    }

    func testArtifactRootRejectsUnapprovedExtendedAttribute()
        throws
    {
        try addUnapprovedExtendedAttribute(
            at: temporaryURL,
            isDirectory: true
        )

        XCTAssertThrowsError(
            try PrimeArtifactRoot(
                directoryURL: temporaryURL
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .untrustedDirectory(temporaryURL.path)
            )
        }
    }

    func testOpenArtifactRootRejectsLaterUnapprovedExtendedAttribute()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        try addUnapprovedExtendedAttribute(
            at: temporaryURL,
            isDirectory: true
        )

        XCTAssertThrowsError(
            try root.requireAbsent(at: "receipt.json")
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .untrustedDirectory(temporaryURL.path)
            )
        }
    }

    func testNestedDirectoryRejectsUnapprovedExtendedAttribute()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        try root.ensurePrivateDirectory(at: "nested")
        let nestedURL = temporaryURL.appendingPathComponent(
            "nested",
            isDirectory: true
        )
        try addUnapprovedExtendedAttribute(
            at: nestedURL,
            isDirectory: true
        )

        XCTAssertThrowsError(
            try root.publish(
                Data("blocked".utf8),
                at: "nested/artifact.bin",
                purpose: .immutableData
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .untrustedDirectory(
                    "nested/artifact.bin"
                )
            )
        }
    }

    func testArtifactRejectsUnapprovedExtendedAttribute()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let binding = try root.publish(
            Data("immutable".utf8),
            at: "artifact.bin",
            purpose: .immutableData
        )
        let artifactURL = temporaryURL.appendingPathComponent(
            binding.relativePath
        )
        XCTAssertEqual(chmod(artifactURL.path, 0o600), 0)
        try addUnapprovedExtendedAttribute(
            at: artifactURL,
            isDirectory: false
        )
        XCTAssertEqual(chmod(artifactURL.path, 0o444), 0)

        XCTAssertThrowsError(
            try root.verify(binding)
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .unsafeArtifact(binding.relativePath)
            )
        }
    }

    func testArtifactRootRejectsSpecialModeBits()
        throws
    {
        XCTAssertEqual(chmod(temporaryURL.path, 0o1700), 0)
        defer {
            _ = chmod(temporaryURL.path, 0o700)
        }

        XCTAssertThrowsError(
            try PrimeArtifactRoot(
                directoryURL: temporaryURL
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .untrustedDirectory(temporaryURL.path)
            )
        }
    }

    func testPublicationAndResolutionRejectSymbolicLinks()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let target = temporaryURL.appendingPathComponent(
            "target"
        )
        try Data("target".utf8).write(to: target)
        let link = temporaryURL.appendingPathComponent(
            "linked"
        )
        try FileManager.default.createSymbolicLink(
            at: link,
            withDestinationURL: target
        )

        XCTAssertThrowsError(
            try root.publish(
                Data("target".utf8),
                at: "linked",
                purpose: .immutableData
            )
        )

        let binding = PrimeArtifactBinding(
            relativePath: "linked",
            sha256: PrimeSHA256.hexDigest(
                of: Data("target".utf8)
            ),
            byteCount: 6,
            purpose: .immutableData
        )
        XCTAssertThrowsError(try root.verify(binding))
    }

    func testResolvedAuthorizationVerifiesFilesAndSemantics()
        throws
    {
        let fixture = try makeFixture()
        let resolved = try fixture.authorization.resolve(
            in: fixture.root
        )
        XCTAssertEqual(
            resolved.executable.binding,
            fixture.executable
        )
        XCTAssertEqual(
            resolved.configuration.binding,
            fixture.configuration
        )
        XCTAssertGreaterThan(resolved.executable.inode, 0)
    }

    func testAuthorizationRejectsDeclaredHashWithoutMatchingFile()
        throws
    {
        let fixture = try makeFixture()
        let wrongExecutable = PrimeArtifactBinding(
            relativePath:
                fixture.executable.relativePath,
            sha256: String(repeating: "0", count: 64),
            byteCount: fixture.executable.byteCount,
            purpose: .executable
        )
        let artifacts = PrimeExecutionArtifactBindings(
            executable: wrongExecutable,
            configuration: fixture.configuration,
            sourceSnapshot: fixture.source,
            mlxDefaultMetallib:
                fixture.artifacts
                    .mlxDefaultMetallib
        )
        let authorization = PrimeRunAuthorization(
            seeds: fixture.seeds,
            artifacts: artifacts,
            calibrationReceipt: fixture.calibration,
            externalExecutionExclusionReason:
                fixture.exclusionReason
        )
        XCTAssertThrowsError(
            try authorization.resolve(in: fixture.root)
        ) { error in
            guard case .hashMismatch =
                    error as? PrimeDurableArtifactError else {
                return XCTFail("unexpected error: \(error)")
            }
        }
    }

    func testAuthorizationRejectsTamperedArtifact()
        throws
    {
        let fixture = try makeFixture()
        let executableURL = temporaryURL
            .appendingPathComponent(
                fixture.executable.relativePath
            )
        XCTAssertEqual(chmod(executableURL.path, 0o755), 0)
        try Data("tampered-executable".utf8).write(
            to: executableURL
        )
        XCTAssertEqual(chmod(executableURL.path, 0o555), 0)

        XCTAssertThrowsError(
            try fixture.authorization.resolve(
                in: fixture.root
            )
        )
    }

    func testAuthorizationRejectsCorrectlyHashedSemanticTamper()
        throws
    {
        let fixture = try makeFixture()
        let changed = PrimeNative3BFP32ExecutionConfiguration(
            seeds: fixture.seeds,
            executable: fixture.executable,
            sourceSnapshot: fixture.source,
            mlxDefaultMetallib:
                fixture.artifacts
                    .mlxDefaultMetallib,
            pythonExecutionAuthorized: true,
            externalExecutionExclusionReason:
                fixture.exclusionReason
        )
        let changedBinding =
            try fixture.root.publishCanonical(
                changed,
                at: "semantic-tamper.json"
            )
        let artifacts = PrimeExecutionArtifactBindings(
            executable: fixture.executable,
            configuration: changedBinding,
            sourceSnapshot: fixture.source,
            mlxDefaultMetallib:
                fixture.artifacts
                    .mlxDefaultMetallib
        )
        let authorization = PrimeRunAuthorization(
            seeds: fixture.seeds,
            artifacts: artifacts,
            calibrationReceipt: fixture.calibration,
            externalExecutionExclusionReason:
                fixture.exclusionReason
        )

        XCTAssertThrowsError(
            try authorization.resolve(in: fixture.root)
        ) { error in
            guard case .invalidSemantics =
                    error as? PrimeDurableArtifactError else {
                return XCTFail("unexpected error: \(error)")
            }
        }
    }

    func testAuthorizationResolvesSeedProvenanceNotJustHex()
        throws
    {
        let fixture = try makeFixture()
        let wrongProvenance =
            PrimeHistoricalFieldProvenance(
                kind: .historicalArtifactField,
                artifactPath: "seed-provenance.json",
                artifactSHA256:
                    String(repeating: "f", count: 64),
                fieldPath: "initialization"
            )
        let wrongInitialization =
            PrimeHistoricalSeedRecord(
                domain: .initialization,
                value: fixture.seeds.initialization.value,
                provenance: wrongProvenance
            )
        let wrongSeeds = try PrimeExecutionSeeds(
            initialization: wrongInitialization,
            trainingSchedule:
                fixture.seeds.trainingSchedule,
            evaluation: fixture.seeds.evaluation
        )
        let changed = PrimeNative3BFP32ExecutionConfiguration(
            seeds: wrongSeeds,
            executable: fixture.executable,
            sourceSnapshot: fixture.source,
            mlxDefaultMetallib:
                fixture.artifacts
                    .mlxDefaultMetallib,
            externalExecutionExclusionReason:
                fixture.exclusionReason
        )
        let changedBinding =
            try fixture.root.publishCanonical(
                changed,
                at: "wrong-provenance-config.json"
            )
        let authorization = PrimeRunAuthorization(
            seeds: wrongSeeds,
            artifacts: PrimeExecutionArtifactBindings(
                executable: fixture.executable,
                configuration: changedBinding,
                sourceSnapshot: fixture.source,
                mlxDefaultMetallib:
                    fixture.artifacts
                        .mlxDefaultMetallib
            ),
            calibrationReceipt: fixture.calibration,
            externalExecutionExclusionReason:
                fixture.exclusionReason
        )

        XCTAssertThrowsError(
            try authorization.resolve(in: fixture.root)
        ) { error in
            guard case .hashMismatch =
                    error as? PrimeDurableArtifactError else {
                return XCTFail("unexpected error: \(error)")
            }
        }
    }

    private func makeFixture() throws -> Fixture {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let seedDocument = SeedDocument(
            initialization: 1_618,
            trainingSchedule: 2_718,
            evaluation: 3_141
        )
        let seedBinding = try root.publishCanonical(
            seedDocument,
            at: "seed-provenance.json"
        )
        let seeds = try PrimeExecutionSeeds(
            initialization: seedRecord(
                domain: .initialization,
                value: seedDocument.initialization,
                field: "initialization",
                binding: seedBinding
            ),
            trainingSchedule: seedRecord(
                domain: .trainingSchedule,
                value: seedDocument.trainingSchedule,
                field: "training_schedule",
                binding: seedBinding
            ),
            evaluation: seedRecord(
                domain: .evaluation,
                value: seedDocument.evaluation,
                field: "evaluation",
                binding: seedBinding
            )
        )
        let executable = try root.publish(
            Data("Mach-O-test-fixture".utf8),
            at: "PrimeGPUCalibration",
            purpose: .executable
        )
        let source = try root.publish(
            Data("source-snapshot".utf8),
            at: "source.snapshot",
            purpose: .immutableData
        )
        let metallib =
            try PinnedMLXMetallibTestSupport
                .publish(in: root)
        let reason =
            PrimeSwiftExecutionBoundary.strictExclusionReason
        let configuration =
            PrimeNative3BFP32ExecutionConfiguration(
                seeds: seeds,
                executable: executable,
                sourceSnapshot: source,
                mlxDefaultMetallib: metallib,
                externalExecutionExclusionReason: reason
            )
        let configurationBinding =
            try root.publishCanonical(
                configuration,
                at: "calibration-config.json"
            )
        let artifacts = PrimeExecutionArtifactBindings(
            executable: executable,
            configuration: configurationBinding,
            sourceSnapshot: source,
            mlxDefaultMetallib: metallib
        )
        let evidence = PrimeExecutionReceiptEvidence(
            seeds: seeds,
            artifacts: artifacts,
            stopReason: .mechanicsCompleted,
            gpu: PrimeGPUObservations(
                deviceName: .observed("Device(gpu,0)"),
                metalExecution: .observed(true)
            ),
            memory: PrimeMemoryObservations(
                peakActiveBytes:
                    .observed(69_202_999_904),
                peakCacheBytes: .unavailable
            ),
            timing: PrimeTimingObservations(
                endToEndWallSeconds: .observed(60),
                processedPaddedPositionsPerSecond:
                    .observed(100),
                processedPaddedPositions:
                    .observed(6_000),
                supervisedTargetTokens:
                    .observed(5_900)
            ),
            pythonExecution: .observed(false),
            shellScientificAuthority:
                .observed(false),
            externalExecutionExclusionReason: reason
        )
        let receipt = PrimeCalibrationReceipt(
            receiptID: "calibration-1",
            recordedAtUTC: "2026-07-29T00:00:00Z",
            verdict: .feasible,
            evidence: evidence
        )
        let receiptBinding = try root.publishCanonical(
            receipt,
            at: "calibration-receipt.json"
        )
        return Fixture(
            root: root,
            seeds: seeds,
            executable: executable,
            source: source,
            configuration: configurationBinding,
            artifacts: artifacts,
            calibration: receiptBinding,
            exclusionReason: reason
        )
    }

    private func seedRecord(
        domain: PrimeSeedDomain,
        value: UInt64,
        field: String,
        binding: PrimeArtifactBinding
    ) -> PrimeHistoricalSeedRecord {
        PrimeHistoricalSeedRecord(
            domain: domain,
            value: value,
            provenance: PrimeHistoricalFieldProvenance(
                kind: .historicalArtifactField,
                artifactPath: binding.relativePath,
                artifactSHA256: binding.sha256,
                fieldPath: field
            )
        )
    }

    private func addUnapprovedExtendedAttribute(
        at url: URL,
        isDirectory: Bool
    ) throws {
        let flags = isDirectory
            ? O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            : O_RDWR | O_NOFOLLOW | O_CLOEXEC
        let descriptor = open(url.path, flags)
        guard descriptor >= 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        defer {
            close(descriptor)
        }

        let name =
            "com.ergentics.prime.unapproved-metadata"
        let value: [UInt8] = [1]
        let result = name.withCString { namePointer in
            value.withUnsafeBytes { valueBuffer in
                fsetxattr(
                    descriptor,
                    namePointer,
                    valueBuffer.baseAddress,
                    valueBuffer.count,
                    0,
                    0
                )
            }
        }
        guard result == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
    }

}
