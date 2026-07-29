import Foundation
import XCTest

@testable import PrimeCore

final class PrimeTypedOptimizerRestoreContractTests:
    XCTestCase
{
    private let digest = String(repeating: "a", count: 64)

    func testFrozenPlanIsRDScopeOnly() throws {
        let plan =
            PrimeTypedOptimizerRestorePlan.frozenSchemaV2
        try plan.validate()
        XCTAssertTrue(plan.researchAndDevelopmentOnly)
        XCTAssertFalse(
            plan.scientificAuthorityClaimAuthorized
        )
        XCTAssertFalse(plan.productPromotionAuthorized)
        XCTAssertFalse(plan.longTrainingAuthorized)
        XCTAssertFalse(plan.pythonExecutionAuthorized)
        XCTAssertEqual(
            plan.firstPartyForkRepository,
            "https://github.com/Ergentics/ergentics-mlx-swift"
        )
        XCTAssertEqual(
            plan.firstPartyForkRevision,
            "68904d54b72871f26968261ae05d4fbb7c5e3142"
        )
        XCTAssertEqual(
            plan.firstPartyForkRemoteStatus,
            "private_remote_authenticated_fresh_clone_observed"
        )
        XCTAssertEqual(
            PrimeTypedOptimizerDependencyTree
                .swiftPackageIdentity,
            "ergentics-mlx-swift"
        )
        XCTAssertEqual(
            plan.typedStateSourceSHA256,
            "3ee01b6d2b84606258bbd6e1e913a6fbc09acec66e0a8bcb38fcc1f964868676"
        )
        XCTAssertEqual(
            plan.optimizerSourceSHA256,
            "f2a36919b73cbec5f3fac6ea23022832474a7aca04b7bfc4ce63bd1f201f6e2d"
        )
    }

    func testManifestRejectsDuplicateBeforeDictionaryMaterialization()
        throws
    {
        let baseline = entries(
            fixture: .flat,
            steps: [1]
        )
        let duplicate =
            PrimeTypedOptimizerExecutionManifest(
                workerRole: .writer,
                fixture: .flat,
                trainablePaths:
                    PrimeTypedOptimizerFixture
                        .flat.trainablePaths,
                frozenPaths: [],
                missingGradientPolicy: .reject,
                semanticObservations: .confirmed,
                entries: (baseline + [baseline[0]])
                    .sorted { identity($0) < identity($1) }
            )
        XCTAssertThrowsError(try duplicate.validate())
    }

    func testExactThreeProcessReceiptValidates()
        throws
    {
        let receipt = makeReceipt()
        try receipt.validateStructure()
        XCTAssertEqual(
            receipt.mutationSweep.count,
            PrimeTypedOptimizerRestoreMutation
                .allCases.count
        )
        XCTAssertTrue(
            receipt.mutationSweep.allSatisfy {
                $0.detectorExecuted
                    && !$0
                    .independentScientificOracleClaimed
            }
        )
        XCTAssertTrue(
            receipt.processTranscript
                .allSatisfy {
                    $0.workerEnvironmentKeyCount == 0
                        && $0.boundedOutput
                            == .emptySuccess
                }
        )
    }

    func testReceiptRejectsRestoredNPlusOneByteDivergence()
        throws
    {
        let baseline = makeReceipt()
        var changedWorkers = baseline.workers
        let restorer = changedWorkers[2]
        var manifests = restorer.manifests
        var changedEntries = manifests[0].entries
        let index = changedEntries.firstIndex {
            $0.stepIndex == 2
                && $0.role == .modelParameter
        }!
        let entry = changedEntries[index]
        changedEntries[index] =
            PrimeTypedOptimizerTensorEntry(
                fixture: entry.fixture,
                stepIndex: entry.stepIndex,
                role: entry.role,
                path: entry.path,
                storageKey: entry.storageKey,
                dtype: entry.dtype,
                shape: entry.shape,
                byteCount: entry.byteCount,
                logicalSHA256:
                    String(repeating: "b", count: 64)
            )
        manifests[0] =
            PrimeTypedOptimizerExecutionManifest(
                workerRole: .restorer,
                fixture: manifests[0].fixture,
                trainablePaths:
                    manifests[0].trainablePaths,
                frozenPaths: [],
                missingGradientPolicy: .reject,
                semanticObservations: .confirmed,
                entries: changedEntries
            )
        changedWorkers[2] =
            PrimeTypedOptimizerWorkerRecord(
                role: .restorer,
                processIdentifier:
                    restorer.processIdentifier,
                executable: restorer.executable,
                sourceEvidence:
                    restorer.sourceEvidence,
                manifests: manifests,
                writerRecord: baseline.writerRecord,
                publicTypedRestoreAPIUsed: true
            )
        let changed =
            PrimeTypedOptimizerRestoreReceipt(
                outcome: .exactTypedRestore,
                recordedAtUTC: baseline.recordedAtUTC,
                primeSourceSnapshot:
                    baseline.primeSourceSnapshot,
                runtimeImage:
                    baseline.runtimeImage,
                controlRecord: baseline.controlRecord,
                writerRecord: baseline.writerRecord,
                restorerRecord: baseline.restorerRecord,
                workers: changedWorkers,
                processTranscript:
                    baseline.processTranscript,
                mutationSweep: baseline.mutationSweep
            )
        XCTAssertThrowsError(
            try changed.validateStructure()
        )
    }

    func testAuthoritativeSuccessRequiresLiveArtifacts()
        throws
    {
        try withArtifactRoot { root in
            XCTAssertThrowsError(
                try makeReceipt().validate(in: root)
            )
        }
    }

    func testFailureReceiptLiveVerifiesAvailableArtifacts()
        throws
    {
        try withArtifactRoot { root in
            let published = try root.publish(
                Data("failure-evidence".utf8),
                at: "evidence.bin",
                purpose: .immutableData
            )
            let failure =
                PrimeTypedOptimizerRestoreFailureReceipt(
                    recordedAtUTC:
                        "2026-07-29T20:00:00Z",
                    stage: .preflight,
                    reasonCode: "DependencyUnavailable",
                    failureDetailSHA256:
                        PrimeSHA256.hexDigest(
                            of: Data(
                                "detail".utf8
                            )
                        ),
                    availableArtifacts: [
                        published,
                    ]
                )
            try failure.validate(in: root)
            let tampered =
                PrimeArtifactBinding(
                    relativePath:
                        published.relativePath,
                    sha256:
                        String(
                            repeating: "0",
                            count: 64
                        ),
                    byteCount:
                        published.byteCount,
                    purpose: .immutableData
                )
            let changed =
                PrimeTypedOptimizerRestoreFailureReceipt(
                    recordedAtUTC:
                        "2026-07-29T20:00:00Z",
                    stage: .preflight,
                    reasonCode: "DependencyUnavailable",
                    failureDetailSHA256:
                        PrimeSHA256.hexDigest(
                            of: Data(
                                "detail".utf8
                            )
                        ),
                    availableArtifacts: [
                        tampered,
                    ]
                )
            XCTAssertThrowsError(
                try changed.validate(in: root)
            )
        }
    }

    private func makeReceipt()
        -> PrimeTypedOptimizerRestoreReceipt
    {
        let executable = artifact(
            "content-staging/typed.executable",
            purpose: .executable
        )
        let controlBinding = artifact(
            "content-staging/control.v2.json"
        )
        let writerBinding = artifact(
            "content-staging/writer.v2.json"
        )
        let restorerBinding = artifact(
            "content-staging/restorer.v2.json"
        )
        let evidence = sourceEvidence()
        let control =
            PrimeTypedOptimizerWorkerRecord(
                role: .control,
                processIdentifier: 11,
                executable: executable,
                sourceEvidence: evidence,
                manifests: manifests(
                    role: .control,
                    steps: [1, 2]
                ),
                publicTypedRestoreAPIUsed: false
            )
        let writer =
            PrimeTypedOptimizerWorkerRecord(
                role: .writer,
                processIdentifier: 12,
                executable: executable,
                sourceEvidence: evidence,
                manifests: manifests(
                    role: .writer,
                    steps: [1]
                ),
                checkpoints:
                    PrimeTypedOptimizerFixture
                        .allCases.sorted().map {
                            PrimeTypedOptimizerCheckpointBindings(
                                fixture: $0,
                                model: artifact(
                                    "content-staging/\($0.rawValue)-model.safetensors"
                                ),
                                optimizerState: artifact(
                                    "content-staging/\($0.rawValue)-optimizer.safetensors"
                                )
                            )
                        },
                publicTypedRestoreAPIUsed: false
            )
        let restorer =
            PrimeTypedOptimizerWorkerRecord(
                role: .restorer,
                processIdentifier: 13,
                executable: executable,
                sourceEvidence: evidence,
                manifests:
                    PrimeTypedOptimizerFixture
                        .allCases.sorted().map {
                            fixture in
                            let restoredN = entries(
                                fixture: fixture,
                                steps: [1]
                            ).filter {
                                $0.role == .modelParameter
                                    || $0.role
                                        == .firstMoment
                                    || $0.role
                                        == .secondMoment
                            }
                            return PrimeTypedOptimizerExecutionManifest(
                                workerRole: .restorer,
                                fixture: fixture,
                                trainablePaths:
                                    fixture.trainablePaths,
                                frozenPaths: [],
                                missingGradientPolicy: .reject,
                                semanticObservations:
                                    .confirmed,
                                entries: (
                                    restoredN
                                        + entries(
                                            fixture: fixture,
                                            steps: [2]
                                        )
                                ).sorted {
                                    identity($0)
                                        < identity($1)
                                }
                            )
                        },
                writerRecord: writerBinding,
                publicTypedRestoreAPIUsed: true
            )
        return PrimeTypedOptimizerRestoreReceipt(
            outcome: .exactTypedRestore,
            recordedAtUTC:
                "2026-07-29T20:00:00Z",
            primeSourceSnapshot: artifact(
                "content-staging/prime-source.v2.json"
            ),
            runtimeImage: runtimeImage(),
            controlRecord: controlBinding,
            writerRecord: writerBinding,
            restorerRecord: restorerBinding,
            workers: [control, writer, restorer],
            processTranscript: [
                PrimeTypedOptimizerProcessObservation(
                    role: .control,
                    processIdentifier: 11,
                    terminationReason: "exit",
                    terminationStatus: 0,
                    workerEnvironmentKeyCount: 0,
                    standardInputClosed: true,
                    boundedOutput: .emptySuccess,
                    record: controlBinding
                ),
                PrimeTypedOptimizerProcessObservation(
                    role: .writer,
                    processIdentifier: 12,
                    terminationReason: "exit",
                    terminationStatus: 0,
                    workerEnvironmentKeyCount: 0,
                    standardInputClosed: true,
                    boundedOutput: .emptySuccess,
                    record: writerBinding
                ),
                PrimeTypedOptimizerProcessObservation(
                    role: .restorer,
                    processIdentifier: 13,
                    terminationReason: "exit",
                    terminationStatus: 0,
                    workerEnvironmentKeyCount: 0,
                    standardInputClosed: true,
                    boundedOutput: .emptySuccess,
                    record: restorerBinding
                ),
            ],
            mutationSweep:
                PrimeTypedOptimizerRestoreMutation
                    .allCases.map {
                        PrimeTypedOptimizerMutationDisposition(
                            mutation: $0,
                            detectorID:
                                $0.detectorID,
                            proposedEvidenceSHA256:
                                PrimeSHA256
                                .hexDigest(
                                    of: Data(
                                        "proposal|\($0.rawValue)"
                                            .utf8
                                    )
                                ),
                            detectorEvidenceSHA256:
                                PrimeSHA256
                                .hexDigest(
                                    of: Data(
                                        "derived|\($0.rawValue)"
                                            .utf8
                                    )
                                ),
                            proposalMaterialized: true,
                            detectorExecuted: true,
                            independentScientificOracleClaimed:
                                false,
                            disposed: true,
                            reason:
                                "rejected by exact schema-v2 contract"
                        )
                    }
        )
    }

    private func manifests(
        role: PrimeTypedOptimizerWorkerRole,
        steps: [Int]
    ) -> [PrimeTypedOptimizerExecutionManifest] {
        PrimeTypedOptimizerFixture
            .allCases.sorted().map { fixture in
                PrimeTypedOptimizerExecutionManifest(
                    workerRole: role,
                    fixture: fixture,
                    trainablePaths:
                        fixture.trainablePaths,
                    frozenPaths: [],
                    missingGradientPolicy: .reject,
                    semanticObservations:
                        .confirmed,
                    entries: entries(
                        fixture: fixture,
                        steps: steps
                    )
                )
            }
    }

    private func entries(
        fixture: PrimeTypedOptimizerFixture,
        steps: [Int]
    ) -> [PrimeTypedOptimizerTensorEntry] {
        var result =
            [PrimeTypedOptimizerTensorEntry]()
        for step in steps {
            result.append(
                entry(
                    fixture: fixture,
                    step: step,
                    role: .loss,
                    path: "loss",
                    shape: []
                )
            )
            result.append(
                entry(
                    fixture: fixture,
                    step: step,
                    role: .output,
                    path: "output",
                    shape: [2, 2]
                )
            )
            for path in fixture.trainablePaths {
                let shape =
                    path.hasSuffix("weight")
                    ? [2, 2] : [2]
                for role:
                    PrimeTypedOptimizerTensorRole in [
                        .gradient,
                        .modelParameter,
                        .firstMoment,
                        .secondMoment,
                    ]
                {
                    result.append(
                        entry(
                            fixture: fixture,
                            step: step,
                            role: role,
                            path: path,
                            shape: shape
                        )
                    )
                }
            }
        }
        return result.sorted {
            identity($0) < identity($1)
        }
    }

    private func entry(
        fixture: PrimeTypedOptimizerFixture,
        step: Int,
        role: PrimeTypedOptimizerTensorRole,
        path: String,
        shape: [Int]
    ) -> PrimeTypedOptimizerTensorEntry {
        let checkpointRole =
            role == .modelParameter
                || role == .firstMoment
                || role == .secondMoment
        let count = shape.reduce(1, *)
        return PrimeTypedOptimizerTensorEntry(
            fixture: fixture,
            stepIndex: step,
            role: role,
            path: path,
            storageKey:
                checkpointRole
                ? "\(role.rawValue).\(path)" : nil,
            dtype: "float32",
            shape: shape,
            byteCount: UInt64(count * 4),
            logicalSHA256:
                PrimeSHA256.hexDigest(
                    of: Data(
                        "\(fixture.rawValue)|\(step)|\(role.rawValue)|\(path)"
                            .utf8
                    )
                )
        )
    }

    private func identity(
        _ entry: PrimeTypedOptimizerTensorEntry
    ) -> String {
        [
            entry.fixture.rawValue,
            String(entry.stepIndex),
            String(
                PrimeTypedOptimizerTensorRole
                    .allCases.firstIndex(
                        of: entry.role
                    )!
            ),
            entry.path,
        ].joined(separator: "\u{1f}")
    }

    private func artifact(
        _ path: String,
        purpose: PrimeArtifactPurpose =
            .immutableData
    ) -> PrimeArtifactBinding {
        PrimeArtifactBinding(
            relativePath: path,
            sha256: digest,
            byteCount: 1,
            purpose: purpose
        )
    }

    private func sourceEvidence()
        -> PrimeTypedOptimizerSourceEvidence
    {
        PrimeTypedOptimizerSourceEvidence(
            packageManifest: artifact(
                "content-staging/evidence/Package.swift"
            ),
            packageResolution: artifact(
                "content-staging/evidence/Package.resolved"
            ),
            mirrorConfiguration: artifact(
                "content-staging/evidence/mirrors.json"
            ),
            dependencyTreeManifest: artifact(
                "content-staging/evidence/mlx-swift/dependency-source-tree.v1.json"
            ),
            license: sourceArtifact(
                "content-staging/evidence/mlx-swift/LICENSE",
                sha256:
                    PrimeTypedOptimizerRestorePlan
                    .frozenSchemaV2
                    .dependencyLicenseSHA256
            ),
            typedStateSource: sourceArtifact(
                "content-staging/evidence/mlx-swift/AdamOptimizerState.swift",
                sha256:
                    PrimeTypedOptimizerRestorePlan
                    .frozenSchemaV2
                    .typedStateSourceSHA256
            ),
            optimizerSource: sourceArtifact(
                "content-staging/evidence/mlx-swift/Optimizers.swift",
                sha256:
                    PrimeTypedOptimizerRestorePlan
                    .frozenSchemaV2
                    .optimizerSourceSHA256
            )
        )
    }

    private func runtimeImage()
        -> PrimePinnedMLXMetallibBinding
    {
        PrimePinnedMLXMetallibBinding(
            mlxSwiftVersion:
                PrimePinnedMLXMetallib
                .mlxSwiftVersion,
            sourceBundleRelativePath:
                PrimePinnedMLXMetallib
                .sourceBundleRelativePath,
            artifact: PrimeArtifactBinding(
                relativePath:
                    PrimePinnedMLXMetallib
                    .artifactRelativePath,
                sha256:
                    PrimePinnedMLXMetallib
                    .expectedSHA256,
                byteCount:
                    PrimePinnedMLXMetallib
                    .expectedByteCount,
                purpose: .immutableData
            ),
            infoPlistSourceRelativePath:
                PrimePinnedMLXMetallib
                .infoPlistSourceRelativePath,
            infoPlistArtifact:
                PrimeArtifactBinding(
                    relativePath:
                        PrimePinnedMLXMetallib
                        .infoPlistArtifactRelativePath,
                    sha256:
                        PrimePinnedMLXMetallib
                        .expectedInfoPlistSHA256,
                    byteCount:
                        PrimePinnedMLXMetallib
                        .expectedInfoPlistByteCount,
                    purpose: .immutableData
                ),
            runtimeEnvironmentPolicy:
                PrimeMLXRuntimeEnvironmentPolicy
                .declaration,
            runtimeImageLayout:
                PrimeMLXRuntimeImageLayout
                .typedOptimizerRestoreProbe,
            releaseInstrumentationPolicy:
                PrimeReleaseInstrumentationAdmissionPolicy
                .declaration
        )
    }

    private func sourceArtifact(
        _ path: String,
        sha256: String
    ) -> PrimeArtifactBinding {
        PrimeArtifactBinding(
            relativePath: path,
            sha256: sha256,
            byteCount: 1,
            purpose: .immutableData
        )
    }

    private func withArtifactRoot(
        _ body: (PrimeArtifactRoot) throws
            -> Void
    ) throws {
        let directory = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(
                "PrimeTypedContract-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: false,
            attributes: [
                .posixPermissions: NSNumber(
                    value: 0o700
                ),
            ]
        )
        defer {
            try? FileManager.default.removeItem(
                at: directory
            )
        }
        try body(
            try PrimeArtifactRoot(
                directoryURL: directory
            )
        )
    }
}
