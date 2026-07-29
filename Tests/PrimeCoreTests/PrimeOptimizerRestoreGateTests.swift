import Darwin
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeOptimizerRestoreGateTests:
    XCTestCase
{
    private struct SourceIdentityRecord:
        Codable
    {
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

    private struct Fixture {
        let root: PrimeArtifactRoot
        let rootURL: URL
        let receipt: PrimeOptimizerRestoreReceipt
        let writerRecord:
            PrimeOptimizerRestoreWriterRecord
        let verifierRecord:
            PrimeOptimizerRestoreVerifierRecord
        let transcript:
            PrimeOptimizerRestoreExecutionTranscript
        let primeSourceSnapshot:
            PrimeSwiftSourceSnapshot
        let sourceProvenanceExpectation:
            PrimeSwiftSourceProvenanceExpectation
    }

    private var temporaryURL: URL!

    override func setUpWithError() throws {
        temporaryURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(
                "ergentics-prime-optimizer-restore-\(UUID().uuidString)",
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

    func testAuthoritativeReplayAdmitsCanonicalAbstain()
        throws
    {
        let fixture = try makeFixture()

        XCTAssertNoThrow(
            try validate(
                fixture.receipt,
                in: fixture
            )
        )
        XCTAssertEqual(
            fixture.receipt.outcome,
            .abstain
        )
        XCTAssertFalse(
            fixture.receipt.longTrainingAuthorized
        )
        XCTAssertEqual(
            fixture.writerRecord.cpuExecution
                .defaultDeviceType,
            .observed("cpu")
        )
        XCTAssertEqual(
            fixture.verifierRecord.cpuExecution
                .defaultStreamWasCPU,
            .observed(true)
        )
        XCTAssertEqual(
            fixture.transcript.writerRecord,
            fixture.receipt.artifacts.writerRecord
        )
        XCTAssertEqual(
            fixture.transcript.verifierRecord,
            fixture.receipt.artifacts.verifierRecord
        )
    }

    func testPromotionLongTrainingAndNullFalseMutationsFailReplay()
        throws
    {
        let fixture = try makeFixture()
        let mutations = [
            receipt(
                from: fixture,
                outcome: .grounded
            ),
            receipt(
                from: fixture,
                longTrainingAuthorized: true
            ),
            receipt(
                from: fixture,
                observations: observations(
                    supportedTypedOptimizerRestoreAPI:
                        .unavailable
                )
            ),
            receipt(
                from: fixture,
                observations: observations(
                    implementationDetailMutationUsed:
                        .observed(true)
                )
            ),
            receipt(
                from: fixture,
                observations: observations(
                    exactTrajectoryContinuation:
                        .observed(false)
                )
            ),
        ]

        for mutation in mutations {
            XCTAssertThrowsError(
                try validate(mutation, in: fixture)
            )
        }

        let falseData = try PrimeCanonicalJSON.encode(
            PrimeBooleanObservation.observed(false)
        )
        let nullData = try PrimeCanonicalJSON.encode(
            PrimeBooleanObservation.unavailable
        )
        XCTAssertNotEqual(falseData, nullData)
        XCTAssertTrue(
            String(decoding: falseData, as: UTF8.self)
                .contains("\"value\":false")
        )
        XCTAssertTrue(
            String(decoding: nullData, as: UTF8.self)
                .contains("\"value\":null")
        )
    }

    func testChildRecordByteTamperFailsReplay()
        throws
    {
        let fixture = try makeFixture()
        let binding =
            fixture.receipt.artifacts.verifierRecord
        let url = fixture.rootURL
            .appendingPathComponent(
                binding.relativePath
            )
        guard chmod(url.path, 0o600) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        try Data("tampered-verifier".utf8).write(
            to: url
        )
        guard chmod(url.path, 0o444) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }

        XCTAssertThrowsError(
            try validate(
                fixture.receipt,
                in: fixture
            )
        )
    }

    func testFabricatedVerifierSemanticsFailReplay()
        throws
    {
        let fixture = try makeFixture(
            verifierModelRestore:
                .observed(false)
        )

        XCTAssertThrowsError(
            try validate(
                fixture.receipt,
                in: fixture
            )
        )
    }

    func testTranscriptCannotSubstituteChildRecordBinding()
        throws
    {
        let fixture = try makeFixture(
            transcriptUsesVerifierAsWriter: true
        )

        XCTAssertThrowsError(
            try validate(
                fixture.receipt,
                in: fixture
            )
        )
    }

    func testCPUExecutionObservationsAreFailClosed()
        throws
    {
        let unavailableDevice = cpuExecution(
            defaultDeviceType: .unavailable
        )
        let falseStream = cpuExecution(
            defaultStreamWasCPU:
                .observed(false)
        )
        let emptyDescription = cpuExecution(
            defaultStreamDescription:
                .observed("")
        )
        let contradictoryDescription = cpuExecution(
            defaultStreamDescription:
                .observed("Stream(gpu,0)")
        )

        for mutation in [
            unavailableDevice,
            falseStream,
            emptyDescription,
            contradictoryDescription,
        ] {
            XCTAssertThrowsError(
                try mutation.validate()
            )
        }
    }

    func testNestedSourceAndMetallibRoleMutationsFailReplay()
        throws
    {
        let fixture = try makeFixture()
        let frozen =
            PrimeOptimizerRestoreSourceEvidence
                .frozenMLXSwift0313
        let nestedMutation =
            PrimeOptimizerRestoreSourceAPIBinding(
                repositoryRelativePath:
                    frozen.nestedStructure
                        .repositoryRelativePath,
                apiDeclarations:
                    frozen.nestedStructure
                        .apiDeclarations,
                sourceArtifact: PrimeArtifactBinding(
                    relativePath:
                        frozen.nestedStructure
                            .sourceArtifact
                            .relativePath,
                    sha256: digest("wrong-nested"),
                    byteCount:
                        frozen.nestedStructure
                            .sourceArtifact.byteCount,
                    purpose: .immutableData
                )
            )
        let mutatedSource = sourceEvidence(
            nestedStructure: nestedMutation
        )
        XCTAssertThrowsError(
            try validate(
                receipt(
                from: fixture,
                sourceEvidence: mutatedSource
                ),
                in: fixture
            )
        )

        let crossRole = mlxBinding(
            from: fixture.receipt.artifacts
                .mlxDefaultMetallib,
            runtimeImageLayout:
                PrimeMLXRuntimeImageLayout
                    .calibration
        )
        let crossRoleArtifacts = artifacts(
            from: fixture.receipt.artifacts,
            mlxDefaultMetallib: crossRole
        )
        XCTAssertThrowsError(
            try validate(
                receipt(
                from: fixture,
                artifacts: crossRoleArtifacts
                ),
                in: fixture
            )
        )
    }

    func testTensorCatalogMutationsFailReplay()
        throws
    {
        let fixture = try makeFixture()
        var badHash = fixture.receipt.tensorCatalog
        badHash[0] =
            PrimeOptimizerTensorCatalogEntry(
                role: .modelParameter,
                key: "bias",
                dtype: "float32",
                shape: [2],
                nbytes: 8,
                logicalSHA256: "not-a-sha"
            )
        let badCount = Array(
            fixture.receipt.tensorCatalog.dropLast()
        )
        let badOrder = Array(
            fixture.receipt.tensorCatalog.reversed()
        )

        for mutation in [
            badHash,
            badCount,
            badOrder,
        ] {
            XCTAssertThrowsError(
                try validate(
                    receipt(
                    from: fixture,
                    tensorCatalog: mutation
                    ),
                    in: fixture
                )
            )
        }
    }

    func testPrimeSourceContentAndBuildMutationsFailReplay()
        throws
    {
        let fixture = try makeFixture()
        var mutatedFiles =
            fixture.primeSourceSnapshot.files
        let gateIndex = try XCTUnwrap(
            mutatedFiles.firstIndex(where: {
                $0.relativePath
                    == "Sources/PrimeCore/PrimeOptimizerRestoreGate.swift"
            })
        )
        let gate = mutatedFiles[gateIndex]
        mutatedFiles[gateIndex] =
            PrimeSwiftSourceFileSnapshot(
                relativePath: gate.relativePath,
                sha256: gate.sha256,
                byteCount: gate.byteCount,
                contents:
                    Data("mutated-gate-source".utf8)
            )
        let contentMutation =
            PrimeSwiftSourceSnapshot(
                sourceIdentitySHA256:
                    fixture.primeSourceSnapshot
                        .sourceIdentitySHA256,
                embeddedSourceIdentitySHA256:
                    fixture.primeSourceSnapshot
                        .embeddedSourceIdentitySHA256,
                buildConfiguration:
                    fixture.primeSourceSnapshot
                        .buildConfiguration,
                files: mutatedFiles
            )
        let contentBinding =
            try fixture.root.publishCanonical(
                contentMutation,
                at:
                    "content-staging/prime-swift-source-content-mutation.v1.json"
            )
        XCTAssertThrowsError(
            try validate(
                receipt(
                    from: fixture,
                    artifacts: artifacts(
                        from:
                            fixture.receipt
                                .artifacts,
                        primeSourceSnapshot:
                            contentBinding
                    )
                ),
                in: fixture
            )
        )

        let buildMutation =
            PrimeSwiftSourceSnapshot(
                sourceIdentitySHA256:
                    fixture.primeSourceSnapshot
                        .sourceIdentitySHA256,
                embeddedSourceIdentitySHA256:
                    fixture.primeSourceSnapshot
                        .embeddedSourceIdentitySHA256,
                buildConfiguration: "debug",
                files:
                    fixture.primeSourceSnapshot
                        .files
            )
        let buildBinding =
            try fixture.root.publishCanonical(
                buildMutation,
                at:
                    "content-staging/prime-swift-source-build-mutation.v1.json"
            )
        XCTAssertThrowsError(
            try validate(
                receipt(
                    from: fixture,
                    artifacts: artifacts(
                        from:
                            fixture.receipt
                                .artifacts,
                        primeSourceSnapshot:
                            buildBinding
                    )
                ),
                in: fixture
            )
        )
    }

    private func makeFixture(
        verifierModelRestore:
            PrimeBooleanObservation =
                .observed(true),
        transcriptUsesVerifierAsWriter:
            Bool = false
    ) throws -> Fixture {
        let rootURL = temporaryURL
            .appendingPathComponent(
                UUID().uuidString,
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: rootURL,
            withIntermediateDirectories: false
        )
        guard chmod(rootURL.path, 0o700) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        let root = try PrimeArtifactRoot(
            directoryURL: rootURL
        )
        try root.ensurePrivateDirectory(
            at: "content-staging"
        )

        let executable = try root.publish(
            Data("optimizer-probe-executable".utf8),
            at:
                PrimeMLXRuntimeImageLayout
                    .optimizerRestoreProbe
                    .stagedExecutableRelativePath,
            purpose: .executable
        )
        let modelCheckpoint = try root.publish(
            Data("model-checkpoint-fixture".utf8),
            at:
                "content-staging/model-after-step-1.safetensors",
            purpose: .immutableData
        )
        let optimizerCheckpoint = try root.publish(
            Data("optimizer-checkpoint-fixture".utf8),
            at:
                "content-staging/optimizer-state-after-step-1.safetensors",
            purpose: .immutableData
        )
        let mlxDefaultMetallib =
            try PinnedMLXMetallibTestSupport.publish(
                in: root,
                runtimeRole: .optimizerRestoreProbe
            )
        let dependencyAPIEvidence =
            try publishFrozenSourceEvidence(in: root)
        let primeSource =
            try makePrimeSourceSnapshot()
        let primeSourceSnapshotBinding =
            try root.publishCanonical(
                primeSource.snapshot,
                at:
                    "content-staging/prime-swift-source-snapshot.v1.json"
            )
        let catalog = tensorCatalog()
        let cpu = cpuExecution()

        let writerRecord =
            PrimeOptimizerRestoreWriterRecord(
                processIdentifier: 17,
                executable: executable,
                cpuExecution: cpu,
                modelCheckpoint: modelCheckpoint,
                optimizerStateCheckpoint:
                    optimizerCheckpoint,
                tensorCatalog: catalog
            )
        let writerBinding =
            try root.publishCanonical(
                writerRecord,
                at:
                    "content-staging/optimizer-restore-writer.v1.json"
            )
        let verifierRecord =
            PrimeOptimizerRestoreVerifierRecord(
                writerRecord: writerBinding,
                writerProcessIdentifier: 17,
                verifierProcessIdentifier: 23,
                executable: executable,
                cpuExecution: cpu,
                modelCheckpoint: modelCheckpoint,
                optimizerStateCheckpoint:
                    optimizerCheckpoint,
                modelSupportedTypedRestoreExact:
                    verifierModelRestore,
                optimizerStateSafetensorsRoundTripExact:
                    .observed(true)
            )
        let verifierBinding =
            try root.publishCanonical(
                verifierRecord,
                at:
                    "content-staging/optimizer-restore-verifier.v1.json"
            )
        let observations =
            PrimeOptimizerRestoreObservations
                .pinnedAPILimit
        let transcript =
            PrimeOptimizerRestoreExecutionTranscript(
                writerPID: 17,
                verifierPID: 23,
                writerExecutable: executable,
                verifierExecutable: executable,
                modelCheckpoint: modelCheckpoint,
                optimizerStateCheckpoint:
                    optimizerCheckpoint,
                mlxDefaultMetallib:
                    mlxDefaultMetallib,
                writerRecord:
                    transcriptUsesVerifierAsWriter
                        ? verifierBinding
                        : writerBinding,
                verifierRecord: verifierBinding,
                tensorCatalog: catalog,
                observations: observations
            )
        let transcriptBinding =
            try root.publishCanonical(
                transcript,
                at:
                    "content-staging/optimizer-restore-execution-transcript.v1.json"
            )
        let artifacts =
            PrimeOptimizerRestoreArtifactBindings(
                executable: executable,
                dependencyAPIEvidence:
                    dependencyAPIEvidence,
                primeSourceSnapshot:
                    primeSourceSnapshotBinding,
                modelCheckpoint: modelCheckpoint,
                optimizerStateCheckpoint:
                    optimizerCheckpoint,
                mlxDefaultMetallib:
                    mlxDefaultMetallib,
                writerRecord: writerBinding,
                verifierRecord: verifierBinding,
                executionTranscript:
                    transcriptBinding
            )
        let receipt = PrimeOptimizerRestoreReceipt(
            outcome: .abstain,
            recordedAtUTC: "2026-07-29T20:00:00Z",
            artifacts: artifacts,
            tensorCatalog: catalog,
            observations: observations
        )
        return Fixture(
            root: root,
            rootURL: rootURL,
            receipt: receipt,
            writerRecord: writerRecord,
            verifierRecord: verifierRecord,
            transcript: transcript,
            primeSourceSnapshot:
                primeSource.snapshot,
            sourceProvenanceExpectation:
                primeSource.expectation
        )
    }

    private func makePrimeSourceSnapshot()
        throws -> (
            snapshot: PrimeSwiftSourceSnapshot,
            expectation:
                PrimeSwiftSourceProvenanceExpectation
        )
    {
        let relativePaths = [
            ".gitignore",
            ".swiftpm/configuration/mirrors.json",
            "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration/mirrors.json",
            "LICENSE",
            "Package.swift",
            "Package.resolved",
            "README.md",
            "THIRD_PARTY_NOTICES.md",
            "Sources/PrimeCore/PrimeOptimizerRestoreGate.swift",
            "Sources/PrimeOptimizerRestoreProbe/PrimeOptimizerRestoreProbeMain.swift",
        ]
        var files =
            relativePaths.map { relativePath in
                let contents = Data(
                    "optimizer-restore-source-fixture:\(relativePath)"
                        .utf8
                )
                return PrimeSwiftSourceFileSnapshot(
                    relativePath: relativePath,
                    sha256:
                        PrimeSHA256.hexDigest(
                            of: contents
                        ),
                    byteCount:
                        UInt64(contents.count),
                    contents: contents
                )
            }
        files.sort {
            $0.relativePath < $1.relativePath
        }
        let records = files.map {
            SourceIdentityRecord(
                relativePath: $0.relativePath,
                sha256: $0.sha256,
                byteCount: $0.byteCount
            )
        }
        let sourceIdentity =
            PrimeSHA256.hexDigest(
                of:
                    try PrimeCanonicalJSON
                        .encode(records)
            )
        let embeddedContents =
            PrimeSwiftSourceProvenance
                .canonicalEmbeddedProvenanceSource(
                    sourceIdentitySHA256:
                        sourceIdentity
                )
        files.append(
            PrimeSwiftSourceFileSnapshot(
                relativePath:
                    PrimeSwiftSourceProvenance
                        .embeddedProvenanceRelativePath,
                sha256:
                    PrimeSHA256.hexDigest(
                        of: embeddedContents
                    ),
                byteCount:
                    UInt64(embeddedContents.count),
                contents: embeddedContents
            )
        )
        files.sort {
            $0.relativePath < $1.relativePath
        }
        let expectation =
            PrimeSwiftSourceProvenanceExpectation(
                sourceIdentitySHA256:
                    sourceIdentity,
                buildConfiguration: "release"
            )
        let snapshot = PrimeSwiftSourceSnapshot(
            sourceIdentitySHA256:
                sourceIdentity,
            embeddedSourceIdentitySHA256:
                sourceIdentity,
            buildConfiguration: "release",
            files: files
        )
        try PrimeSwiftSourceProvenance.validate(
            snapshot,
            requiredRelativePaths:
                PrimeOptimizerRestoreReceipt
                    .requiredPrimeSourceRelativePaths,
            expectation: expectation
        )
        return (
            snapshot: snapshot,
            expectation: expectation
        )
    }

    private func publishFrozenSourceEvidence(
        in root: PrimeArtifactRoot
    ) throws -> PrimeArtifactBinding {
        let evidence =
            PrimeOptimizerRestoreSourceEvidence
                .frozenMLXSwift0313
        try evidence.validate()
        for directory in [
            "evidence",
            "evidence/mlx-swift",
            "evidence/mlx-swift/Source",
            "evidence/mlx-swift/Source/MLX",
            "evidence/mlx-swift/Source/MLXNN",
            "evidence/mlx-swift/Source/MLXOptimizers",
        ] {
            try root.ensurePrivateDirectory(
                at: directory
            )
        }

        let repository = URL(
            fileURLWithPath:
                FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        let checkout = repository
            .appendingPathComponent(".build")
            .appendingPathComponent("checkouts")
            .appendingPathComponent(
                PrimeTypedOptimizerDependencyTree
                    .checkoutDirectoryName
            )
        let publications: [
            (
                data: Data,
                binding: PrimeArtifactBinding
            )
        ] = [
            (
                frozenDependencyResolutionData(),
                evidence.dependencyResolution
            ),
            try sourcePublication(
                repositoryRelativePath: "LICENSE",
                artifact: evidence.licenseArtifact,
                checkout: checkout
            ),
            try sourcePublication(
                evidence.optimizer,
                checkout: checkout
            ),
            try sourcePublication(
                evidence.updatableProtocol,
                checkout: checkout
            ),
            try sourcePublication(
                evidence.arrayMutation,
                checkout: checkout
            ),
            try sourcePublication(
                evidence.nestedStructure,
                checkout: checkout
            ),
            try sourcePublication(
                evidence.tensorIO,
                checkout: checkout
            ),
            try sourcePublication(
                evidence.moduleRestore,
                checkout: checkout
            ),
        ]
        for publication in publications {
            let observed = try root.publish(
                publication.data,
                at: publication.binding.relativePath,
                purpose: .immutableData
            )
            XCTAssertEqual(
                observed,
                publication.binding
            )
        }
        return try root.publishCanonical(
            evidence,
            at:
                "content-staging/optimizer-restore-api-evidence.v1.json"
        )
    }

    private func sourcePublication(
        _ binding:
            PrimeOptimizerRestoreSourceAPIBinding,
        checkout: URL
    ) throws -> (
        data: Data,
        binding: PrimeArtifactBinding
    ) {
        try sourcePublication(
            repositoryRelativePath:
                binding.repositoryRelativePath,
            artifact: binding.sourceArtifact,
            checkout: checkout
        )
    }

    private func sourcePublication(
        repositoryRelativePath: String,
        artifact: PrimeArtifactBinding,
        checkout: URL
    ) throws -> (
        data: Data,
        binding: PrimeArtifactBinding
    ) {
        (
            try Data(
                contentsOf:
                    checkout.appendingPathComponent(
                        repositoryRelativePath
                    )
            ),
            artifact
        )
    }

    private func frozenDependencyResolutionData()
        -> Data
    {
        Data(
            (
                """
                {
                  "originHash" : "246faf1a10ea04cf6f3f626caf50db0e2c2a64bf4b309079da451a7ea1f00ea7",
                  "pins" : [
                    {
                      "identity" : "mlx-swift",
                      "kind" : "remoteSourceControl",
                      "location" : "https://github.com/ml-explore/mlx-swift",
                      "state" : {
                        "revision" : "61b9e011e09a62b489f6bd647958f1555bdf2896",
                        "version" : "0.31.3"
                      }
                    },
                    {
                      "identity" : "mlx-swift-lm",
                      "kind" : "remoteSourceControl",
                      "location" : "https://github.com/ml-explore/mlx-swift-lm",
                      "state" : {
                        "revision" : "1c05248bb0899e2a7a4962b84d319cf12f4e12aa",
                        "version" : "3.31.3"
                      }
                    },
                    {
                      "identity" : "swift-numerics",
                      "kind" : "remoteSourceControl",
                      "location" : "https://github.com/apple/swift-numerics",
                      "state" : {
                        "revision" : "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
                        "version" : "1.1.1"
                      }
                    },
                    {
                      "identity" : "swift-syntax",
                      "kind" : "remoteSourceControl",
                      "location" : "https://github.com/swiftlang/swift-syntax.git",
                      "state" : {
                        "revision" : "0687f71944021d616d34d922343dcef086855920",
                        "version" : "600.0.1"
                      }
                    }
                  ],
                  "version" : 3
                }
                """
                    + "\n"
            ).utf8
        )
    }

    private func receipt(
        from fixture: Fixture,
        outcome: PrimeOptimizerRestoreOutcome =
            .abstain,
        sourceEvidence:
            PrimeOptimizerRestoreSourceEvidence =
                .frozenMLXSwift0313,
        artifacts:
            PrimeOptimizerRestoreArtifactBindings? = nil,
        tensorCatalog:
            [PrimeOptimizerTensorCatalogEntry]? = nil,
        observations:
            PrimeOptimizerRestoreObservations? = nil,
        longTrainingAuthorized: Bool = false
    ) -> PrimeOptimizerRestoreReceipt {
        PrimeOptimizerRestoreReceipt(
            outcome: outcome,
            recordedAtUTC: "2026-07-29T20:00:00Z",
            sourceEvidence: sourceEvidence,
            artifacts:
                artifacts ?? fixture.receipt.artifacts,
            tensorCatalog:
                tensorCatalog
                    ?? fixture.receipt.tensorCatalog,
            observations:
                observations
                    ?? fixture.receipt.observations,
            longTrainingAuthorized:
                longTrainingAuthorized
        )
    }

    private func artifacts(
        from baseline:
            PrimeOptimizerRestoreArtifactBindings,
        mlxDefaultMetallib:
            PrimePinnedMLXMetallibBinding? = nil,
        primeSourceSnapshot:
            PrimeArtifactBinding? = nil
    ) -> PrimeOptimizerRestoreArtifactBindings {
        PrimeOptimizerRestoreArtifactBindings(
            executable: baseline.executable,
            dependencyAPIEvidence:
                baseline.dependencyAPIEvidence,
            primeSourceSnapshot:
                primeSourceSnapshot
                    ?? baseline.primeSourceSnapshot,
            modelCheckpoint: baseline.modelCheckpoint,
            optimizerStateCheckpoint:
                baseline.optimizerStateCheckpoint,
            mlxDefaultMetallib:
                mlxDefaultMetallib
                    ?? baseline.mlxDefaultMetallib,
            writerRecord: baseline.writerRecord,
            verifierRecord: baseline.verifierRecord,
            executionTranscript:
                baseline.executionTranscript
        )
    }

    private func validate(
        _ receipt: PrimeOptimizerRestoreReceipt,
        in fixture: Fixture
    ) throws {
        try receipt.validate(
            in: fixture.root,
            sourceProvenanceExpectation:
                fixture.sourceProvenanceExpectation
        )
    }

    private func mlxBinding(
        from baseline:
            PrimePinnedMLXMetallibBinding,
        runtimeImageLayout:
            PrimeMLXRuntimeImageLayoutDeclaration
    ) -> PrimePinnedMLXMetallibBinding {
        PrimePinnedMLXMetallibBinding(
            mlxSwiftVersion:
                baseline.mlxSwiftVersion,
            sourceBundleRelativePath:
                baseline.sourceBundleRelativePath,
            artifact: baseline.artifact,
            infoPlistSourceRelativePath:
                baseline.infoPlistSourceRelativePath,
            infoPlistArtifact:
                baseline.infoPlistArtifact,
            runtimeEnvironmentPolicy:
                baseline.runtimeEnvironmentPolicy,
            runtimeImageLayout:
                runtimeImageLayout,
            releaseInstrumentationPolicy:
                baseline
                    .releaseInstrumentationPolicy
        )
    }

    private func sourceEvidence(
        nestedStructure:
            PrimeOptimizerRestoreSourceAPIBinding
    ) -> PrimeOptimizerRestoreSourceEvidence {
        let frozen =
            PrimeOptimizerRestoreSourceEvidence
                .frozenMLXSwift0313
        return PrimeOptimizerRestoreSourceEvidence(
            dependencyResolution:
                frozen.dependencyResolution,
            licenseArtifact:
                frozen.licenseArtifact,
            optimizer: frozen.optimizer,
            updatableProtocol:
                frozen.updatableProtocol,
            arrayMutation: frozen.arrayMutation,
            nestedStructure: nestedStructure,
            tensorIO: frozen.tensorIO,
            moduleRestore: frozen.moduleRestore,
            typedOptimizerRestoreAPIDeclared:
                frozen
                    .typedOptimizerRestoreAPIDeclared,
            implementationDetailMutationWarning:
                frozen
                    .implementationDetailMutationWarning
        )
    }

    private func tensorCatalog()
        -> [PrimeOptimizerTensorCatalogEntry]
    {
        [
            tensor(.modelParameter, "bias", [2]),
            tensor(.adamFirstMoment, "bias", [2]),
            tensor(.adamSecondMoment, "bias", [2]),
            tensor(.modelParameter, "weight", [2, 2]),
            tensor(.adamFirstMoment, "weight", [2, 2]),
            tensor(.adamSecondMoment, "weight", [2, 2]),
        ]
    }

    private func tensor(
        _ role: PrimeOptimizerTensorRole,
        _ key: String,
        _ shape: [Int]
    ) -> PrimeOptimizerTensorCatalogEntry {
        PrimeOptimizerTensorCatalogEntry(
            role: role,
            key: key,
            dtype: "float32",
            shape: shape,
            nbytes: UInt64(shape.reduce(1, *) * 4),
            logicalSHA256: digest(
                "\(key):\(role.rawValue)"
            )
        )
    }

    private func cpuExecution(
        defaultDeviceType:
            PrimeObservation<String> =
                .observed("cpu"),
        defaultStreamDescription:
            PrimeObservation<String> =
                .observed("Stream(cpu,0)"),
        defaultStreamWasCPU:
            PrimeBooleanObservation =
                .observed(true)
    ) -> PrimeOptimizerRestoreCPUExecutionObservations {
        PrimeOptimizerRestoreCPUExecutionObservations(
            defaultDeviceType: defaultDeviceType,
            defaultStreamDescription:
                defaultStreamDescription,
            defaultStreamWasCPU:
                defaultStreamWasCPU
        )
    }

    private func observations(
        supportedTypedOptimizerRestoreAPI:
            PrimeBooleanObservation =
                .observed(false),
        implementationDetailMutationUsed:
            PrimeBooleanObservation =
                .observed(false),
        exactTrajectoryContinuation:
            PrimeBooleanObservation =
                .unavailable
    ) -> PrimeOptimizerRestoreObservations {
        PrimeOptimizerRestoreObservations(
            modelSafetensorsSave: .observed(true),
            modelSupportedTypedRestore:
                .observed(true),
            optimizerStateSafetensorsRoundTrip:
                .observed(true),
            supportedTypedOptimizerRestoreAPI:
                supportedTypedOptimizerRestoreAPI,
            implementationDetailMutationUsed:
                implementationDetailMutationUsed,
            exactTrajectoryContinuation:
                exactTrajectoryContinuation,
            freshProcessOptimizerContinuationExact:
                .unavailable,
            checkpointWriterExitedCleanly:
                .observed(true),
            restoreVerifierWasFreshProcess:
                .observed(true)
        )
    }

    private func digest(_ value: String) -> String {
        PrimeSHA256.hexDigest(
            of: Data(value.utf8)
        )
    }
}
