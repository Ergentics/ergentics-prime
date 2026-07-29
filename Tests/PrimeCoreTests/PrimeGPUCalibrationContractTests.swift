import Darwin
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeGPUCalibrationContractTests: XCTestCase {
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
        let artifacts: PrimeExecutionArtifactBindings
        let sourceSnapshot: PrimeSwiftSourceSnapshot
    }

    private var temporaryURL: URL!

    override func setUpWithError() throws {
        temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "ergentics-prime-gpu-contract-\(UUID().uuidString)",
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

    func testInitialAllocationPlanRejectsScientificMutations()
        throws
    {
        let mutations = [
            plan(schemaVersion: 2),
            plan(batchSize: 2),
            plan(gradientAccumulationSteps: 2),
            plan(sequenceLength: 129),
            plan(optimizerSteps: 2),
            plan(workerActiveTimeLimitSeconds: 1_799),
            plan(
                supervisorEndToEndWallLimitSeconds:
                    1_799
            ),
            plan(terminationGraceSeconds: 9),
            plan(
                requestedMLXMemoryLimitBytes:
                    95 * 1024 * 1024 * 1024
            ),
            plan(memoryCacheLimitBytes: 0),
            plan(optimizerImplementation: "AdamW"),
            plan(optimizerPackageVersion: "0.31.2"),
            plan(optimizerLearningRate: 0.0002),
            plan(optimizerBeta1: 0.8),
            plan(optimizerBeta2: 0.99),
            plan(optimizerEpsilon: 1e-7),
            plan(optimizerWeightDecay: 0),
            plan(optimizerBiasCorrectionApplied: true),
            plan(mlxSwiftLMVersion: "3.31.2"),
            plan(functionalEvaluationAuthorized: true),
            plan(longTrainingAuthorized: true),
        ]

        try PrimeGPUCalibrationPlan.initialAllocationProbe
            .validate()
        for mutation in mutations {
            XCTAssertThrowsError(try mutation.validate())
        }
    }

    func testGPUReplayRequiresFrozenPrimeSourcePaths() {
        XCTAssertEqual(
            PrimeNative3BFP32ExecutionConfiguration
                .requiredPrimeSourceRelativePaths,
            [
                "Sources/PrimeGPUCalibration/" +
                    "PrimeGPUCalibrationMain.swift",
                "Sources/PrimeCore/" +
                    "PrimeNative3BProfile.swift",
            ]
        )
    }

    func testGroundedReceiptMatchesFrozenPlanAndCounts()
        throws
    {
        let fixture = try makeFixture()
        let candidate = makeWorkerCandidate(
            fixture: fixture
        )
        XCTAssertNoThrow(
            try candidate.validateWorkerCandidate(
                in: fixture.root
            )
        )
        XCTAssertThrowsError(
            try candidate.validate(in: fixture.root)
        )
        XCTAssertNil(
            candidate.durableEvidence.timing
                .endToEndWallSeconds.value
        )
        let receipt = try finalize(
            candidate,
            fixture: fixture,
            supervisorEndToEndWallSeconds: 40
        )

        XCTAssertNoThrow(
            try receipt.validate(in: fixture.root)
        )
        XCTAssertEqual(
            receipt.processedPaddedTokenPositions,
            128
        )
        XCTAssertEqual(receipt.mechanics.stepLosses.count, 1)
        XCTAssertEqual(
            receipt.mechanics.optimizerStateArrayCount,
            receipt.mechanics.expectedOptimizerStateArrayCount
        )
        XCTAssertEqual(
            receipt.durableEvidence.timing
                .endToEndWallSeconds.value,
            40
        )
        XCTAssertEqual(
            receipt.durableEvidence.timing
                .processedPaddedPositionsPerSecond.value,
            128 / 30
        )
    }

    func testReceiptRejectsPlanAndTokenCountMutations()
        throws
    {
        let fixture = try makeFixture()
        let mutations = [
            try makeFinalizedReceipt(
                fixture: fixture,
                batchSize: 2,
                processedPaddedTokenPositions: 256
            ),
            try makeFinalizedReceipt(
                fixture: fixture,
                completedSteps: 2,
                processedPaddedTokenPositions: 256,
                stepLosses: [6.2, 6.1]
            ),
            try makeFinalizedReceipt(
                fixture: fixture,
                processedPaddedTokenPositions: 127
            ),
            try makeFinalizedReceipt(
                fixture: fixture,
                supervisedTargetTokenCount: 128
            ),
            try makeFinalizedReceipt(
                fixture: fixture,
                mechanicsActiveElapsedSeconds: 1_801
            ),
        ]

        for mutation in mutations {
            XCTAssertThrowsError(
                try mutation.validate(in: fixture.root)
            )
        }
    }

    func testReceiptRejectsAdamStateMutations() throws {
        let fixture = try makeFixture()
        let mutations = [
            try makeFinalizedReceipt(
                fixture: fixture,
                optimizerStateArrayCount: 507
            ),
            try makeFinalizedReceipt(
                fixture: fixture,
                expectedOptimizerStateArrayCount: 1,
                optimizerStateArrayCount: 1
            ),
            try makeFinalizedReceipt(
                fixture: fixture,
                optimizerStateDTypes: ["bfloat16"]
            ),
            try makeFinalizedReceipt(
                fixture: fixture,
                optimizerStateL2Norm: 0
            ),
            try makeFinalizedReceipt(
                fixture: fixture,
                optimizerBiasCorrectionApplied: true
            ),
            try makeFinalizedReceipt(
                fixture: fixture,
                optimizerStateRestoreSupported: true
            ),
        ]

        for mutation in mutations {
            XCTAssertThrowsError(
                try mutation.validate(in: fixture.root)
            )
        }
    }

    func testFailureReceiptIsDistinctAbstainEvidence()
        throws
    {
        let fixture = try makeFixture()
        let failure = PrimeGPUCalibrationFailureReceipt(
            recordedAtUTC: "2026-07-29T00:00:00Z",
            claimScope:
                "failed_exact_3b_fp32_allocation_forward_backward_adamw_update",
            seeds: fixture.seeds,
            artifacts: fixture.artifacts,
            stage: .forwardBackwardUpdate,
            reason: .outOfMemory,
            detail: "allocator refused request",
            elapsedSeconds:
                .observed(12),
            elapsedTimeScope: .workerExecution,
            peakActiveMemoryBytes: .unavailable,
            deviceArchitecture:
                .observed("Apple M5 Max"),
            deviceDescription:
                .observed("Device(gpu,0)"),
            metalExecutionBegan: .observed(true),
            boundary: PrimeGPUCalibrationBoundary(
                externalExecutionExclusionReason:
                    PrimeSwiftExecutionBoundary
                        .strictExclusionReason
            ),
            nextAction:
                "inspect_failure_receipt_before_any_repeat_or_larger_arm"
        )

        XCTAssertNoThrow(
            try failure.validate(in: fixture.root)
        )
        XCTAssertEqual(failure.outcome, .abstain)
        XCTAssertNil(
            failure.durableEvidence.timing
                .endToEndWallSeconds.value
        )
        XCTAssertNil(
            failure.durableEvidence.timing
                .processedPaddedPositions.value
        )
        XCTAssertEqual(
            failure.durableEvidence
                .shellScientificAuthority.value,
            false
        )
    }

    func testBoundaryDisclosesUntracedDependencyShellCapability()
        throws
    {
        let fixture = try makeFixture()
        let baseline =
            PrimeGPUCalibrationBoundary(
                externalExecutionExclusionReason:
                    PrimeSwiftExecutionBoundary
                        .strictExclusionReason
            )
        XCTAssertTrue(
            baseline
                .pinnedDependencyShellCapabilityPresent
        )
        XCTAssertFalse(
            baseline.dependencyShellExecution
                .observationAvailable
        )
        XCTAssertNil(
            baseline.dependencyShellExecution.value
        )
        XCTAssertNoThrow(
            try makeWorkerCandidate(
                fixture: fixture,
                boundary: baseline
            ).validateWorkerCandidate(in: fixture.root)
        )

        let hiddenCapability =
            PrimeGPUCalibrationBoundary(
                pinnedDependencyShellCapabilityPresent:
                    false,
                externalExecutionExclusionReason:
                    PrimeSwiftExecutionBoundary
                        .strictExclusionReason
            )
        let inventedNonExecution =
            PrimeGPUCalibrationBoundary(
                dependencyShellExecution:
                    .observed(false),
                externalExecutionExclusionReason:
                    PrimeSwiftExecutionBoundary
                        .strictExclusionReason
            )
        for mutation in [
            hiddenCapability,
            inventedNonExecution,
        ] {
            XCTAssertThrowsError(
                try makeWorkerCandidate(
                    fixture: fixture,
                    boundary: mutation
                ).validateWorkerCandidate(
                    in: fixture.root
                )
            )
        }
    }

    func testPinnedMLXBundleBindingRejectsIdentityMutations()
        throws
    {
        let metallib = PrimeArtifactBinding(
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
        )
        let infoPlist = PrimeArtifactBinding(
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
        )
        func binding(
            version: String =
                PrimePinnedMLXMetallib
                    .mlxSwiftVersion,
            metallibSource: String =
                PrimePinnedMLXMetallib
                    .sourceBundleRelativePath,
            metallibArtifact:
                PrimeArtifactBinding = metallib,
            infoSource: String =
                PrimePinnedMLXMetallib
                    .infoPlistSourceRelativePath,
            infoArtifact:
                PrimeArtifactBinding = infoPlist,
            runtimeEnvironmentPolicy:
                PrimeMLXRuntimeEnvironmentPolicyDeclaration =
                    PrimeMLXRuntimeEnvironmentPolicy
                    .declaration,
            runtimeImageLayout:
                PrimeMLXRuntimeImageLayoutDeclaration =
                    PrimeMLXRuntimeImageLayout
                    .declaration,
            releaseInstrumentationPolicy:
                PrimeReleaseInstrumentationAdmissionPolicyDeclaration =
                    PrimeReleaseInstrumentationAdmissionPolicy
                    .declaration
        ) -> PrimePinnedMLXMetallibBinding {
            PrimePinnedMLXMetallibBinding(
                mlxSwiftVersion: version,
                sourceBundleRelativePath:
                    metallibSource,
                artifact: metallibArtifact,
                infoPlistSourceRelativePath:
                    infoSource,
                infoPlistArtifact: infoArtifact,
                runtimeEnvironmentPolicy:
                    runtimeEnvironmentPolicy,
                runtimeImageLayout:
                    runtimeImageLayout,
                releaseInstrumentationPolicy:
                    releaseInstrumentationPolicy
            )
        }
        let changedMetallibHash =
            PrimeArtifactBinding(
                relativePath:
                    metallib.relativePath,
                sha256:
                    String(repeating: "0", count: 64),
                byteCount: metallib.byteCount,
                purpose: .immutableData
            )
        let changedMetallibSize =
            PrimeArtifactBinding(
                relativePath:
                    metallib.relativePath,
                sha256: metallib.sha256,
                byteCount:
                    metallib.byteCount - 1,
                purpose: .immutableData
            )
        let changedInfoHash =
            PrimeArtifactBinding(
                relativePath:
                    infoPlist.relativePath,
                sha256:
                    String(repeating: "f", count: 64),
                byteCount: infoPlist.byteCount,
                purpose: .immutableData
            )

        XCTAssertNoThrow(
            try binding().validateDeclaration()
        )
        XCTAssertNoThrow(
            try binding(
                runtimeImageLayout:
                    PrimeMLXRuntimeImageLayout
                    .optimizerRestoreProbe
            ).validateDeclaration()
        )
        for mutation in [
            binding(version: "0.31.2"),
            binding(
                metallibSource:
                    "mlx-swift_Cmlx.bundle/default.metallib"
            ),
            binding(
                metallibArtifact:
                    changedMetallibHash
            ),
            binding(
                metallibArtifact:
                    changedMetallibSize
            ),
            binding(
                infoSource:
                    "mlx-swift_Cmlx.bundle/Info.plist"
            ),
            binding(
                infoArtifact: changedInfoHash
            ),
            binding(
                runtimeEnvironmentPolicy:
                    PrimeMLXRuntimeEnvironmentPolicyDeclaration(
                        policyID:
                            "mutated_environment_policy",
                        policyVersion: 1,
                        forbiddenKeyPrefixes: [
                            "DYLD_",
                            "LLVM_PROFILE_",
                            "MLX_",
                        ]
                    )
            ),
            binding(
                runtimeImageLayout:
                    PrimeMLXRuntimeImageLayoutDeclaration(
                        layoutID:
                            "mutated_runtime_layout",
                        layoutVersion: 1,
                        stagedExecutableRelativePath:
                            "PrimeGPUCalibration.executable",
                        siblingBundleRelativePath:
                            PrimePinnedMLXMetallib
                                .bundleRelativePath
                    )
            ),
            binding(
                releaseInstrumentationPolicy:
                    PrimeReleaseInstrumentationAdmissionPolicyDeclaration(
                        policyID:
                            "mutated_instrumentation_policy",
                        policyVersion: 1,
                        inspectedImageScope:
                            "dyld_main_executable_image_index_zero",
                        machOInspectionAPI:
                            "Darwin._dyld_get_image_header+MachO.getsegmentdata/getsectiondata",
                        runtimeSymbolInspectionAPI:
                            "Darwin.dlopen(nil)+dlsym",
                        forbiddenMachOSegmentNames: [
                            "__LLVM_COV",
                        ],
                        searchedMachOSegmentNames: [
                            "__DATA",
                        ],
                        forbiddenMachOSectionNames: [
                            "__llvm_prf_cnts",
                        ],
                        forbiddenRuntimeSymbolNames: [
                            "__asan_init",
                        ]
                    )
            ),
        ] {
            XCTAssertThrowsError(
                try mutation.validateDeclaration()
            )
        }
    }

    func testCalibrationConfigurationRejectsOptimizerRestoreRuntimeRole()
        throws
    {
        let fixture = try makeFixture()
        let calibrationBinding =
            fixture.artifacts
                .mlxDefaultMetallib
        let restoreBinding =
            PrimePinnedMLXMetallibBinding(
                mlxSwiftVersion:
                    calibrationBinding
                    .mlxSwiftVersion,
                sourceBundleRelativePath:
                    calibrationBinding
                    .sourceBundleRelativePath,
                artifact:
                    calibrationBinding.artifact,
                infoPlistSourceRelativePath:
                    calibrationBinding
                    .infoPlistSourceRelativePath,
                infoPlistArtifact:
                    calibrationBinding
                    .infoPlistArtifact,
                runtimeEnvironmentPolicy:
                    calibrationBinding
                    .runtimeEnvironmentPolicy,
                runtimeImageLayout:
                    PrimeMLXRuntimeImageLayout
                    .optimizerRestoreProbe,
                releaseInstrumentationPolicy:
                    calibrationBinding
                    .releaseInstrumentationPolicy
            )
        XCTAssertNoThrow(
            try restoreBinding.validateDeclaration()
        )

        let configuration =
            PrimeNative3BFP32ExecutionConfiguration(
                seeds: fixture.seeds,
                executable:
                    fixture.artifacts.executable,
                sourceSnapshot:
                    fixture.artifacts
                    .sourceSnapshot,
                mlxDefaultMetallib:
                    restoreBinding,
                externalExecutionExclusionReason:
                    PrimeSwiftExecutionBoundary
                    .strictExclusionReason
            )
        XCTAssertThrowsError(
            try configuration.validate()
        )
    }

    func testReceiptReplayRejectsFabricatedAndTamperedSourceSnapshots()
        throws
    {
        let fixture = try makeFixture()
        let sourcePath =
            "Sources/PrimeGPUCalibration/" +
            "PrimeGPUCalibrationMain.swift"
        var tamperedFiles =
            fixture.sourceSnapshot.files
        let sourceIndex = try XCTUnwrap(
            tamperedFiles.firstIndex(where: {
                $0.relativePath == sourcePath
            })
        )
        let sourceFile = tamperedFiles[sourceIndex]
        tamperedFiles[sourceIndex] =
            PrimeSwiftSourceFileSnapshot(
                relativePath: sourceFile.relativePath,
                sha256: sourceFile.sha256,
                byteCount: sourceFile.byteCount,
                contents:
                    sourceFile.contents
                    + Data([0x0a])
            )
        let tampered = PrimeSwiftSourceSnapshot(
            sourceIdentitySHA256:
                fixture.sourceSnapshot
                .sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                fixture.sourceSnapshot
                .embeddedSourceIdentitySHA256,
            buildConfiguration: "release",
            files: tamperedFiles
        )
        let fabricated = PrimeSwiftSourceSnapshot(
            sourceIdentitySHA256:
                String(repeating: "0", count: 64),
            embeddedSourceIdentitySHA256:
                fixture.sourceSnapshot
                .embeddedSourceIdentitySHA256,
            buildConfiguration: "release",
            files: fixture.sourceSnapshot.files
        )

        for (index, mutation) in
            [tampered, fabricated].enumerated()
        {
            let sourceBinding =
                try fixture.root.publishCanonical(
                    mutation,
                    at:
                        "source-snapshot-mutation-\(index).json"
                )
            let configuration =
                PrimeNative3BFP32ExecutionConfiguration(
                    seeds: fixture.seeds,
                    executable:
                        fixture.artifacts.executable,
                    sourceSnapshot: sourceBinding,
                    mlxDefaultMetallib:
                        fixture.artifacts
                        .mlxDefaultMetallib,
                    externalExecutionExclusionReason:
                        PrimeSwiftExecutionBoundary
                        .strictExclusionReason
                )
            try configuration.validate()
            let configurationBinding =
                try fixture.root.publishCanonical(
                    configuration,
                    at:
                        "source-snapshot-mutation-config-\(index).json"
                )
            let artifacts =
                PrimeExecutionArtifactBindings(
                    executable:
                        fixture.artifacts.executable,
                    configuration:
                        configurationBinding,
                    sourceSnapshot: sourceBinding,
                    mlxDefaultMetallib:
                        fixture.artifacts
                        .mlxDefaultMetallib
                )
            let mutatedFixture = Fixture(
                root: fixture.root,
                seeds: fixture.seeds,
                artifacts: artifacts,
                sourceSnapshot: mutation
            )
            XCTAssertThrowsError(
                try makeWorkerCandidate(
                    fixture: mutatedFixture
                ).validateWorkerCandidate(
                    in: fixture.root
                )
            ) { error in
                XCTAssertTrue(
                    error is
                        PrimeSwiftSourceProvenanceError,
                    "unexpected error: \(error)"
                )
            }
        }
    }

    func testGroundedReceiptRejectsSupervisorMutations()
        throws
    {
        let fixture = try makeFixture()
        let candidate = makeWorkerCandidate(
            fixture: fixture
        )
        let mutations = [
            try finalize(
                candidate,
                fixture: fixture,
                supervisorEndToEndWallSeconds: 1_801
            ),
            try finalize(
                candidate,
                fixture: fixture,
                workerTerminationReason:
                    .uncaughtSignal
            ),
            try finalize(
                candidate,
                fixture: fixture,
                workerTerminationStatus: 1
            ),
            try finalize(
                candidate,
                fixture: fixture,
                hardTimeoutObserved: true
            ),
            try finalize(
                candidate,
                fixture: fixture,
                capabilityVerified: false
            ),
            try finalize(
                candidate,
                fixture: fixture,
                runAuthorityLeaseHeld: false
            ),
        ]

        for mutation in mutations {
            XCTAssertThrowsError(
                try mutation.validate(in: fixture.root)
            )
        }
    }

    func testFinalReceiptMustExactlyMatchItsCandidate()
        throws
    {
        let fixture = try makeFixture()
        let candidate = makeWorkerCandidate(
            fixture: fixture
        )
        let finalized = try finalize(
            candidate,
            fixture: fixture
        )
        let divergent = PrimeGPUCalibrationReceipt(
            outcome: finalized.outcome,
            claimScope: finalized.claimScope + "_mutated",
            recordedAtUTC: finalized.recordedAtUTC,
            expectedParameterCount:
                finalized.expectedParameterCount,
            observedParameterCount:
                finalized.observedParameterCount,
            observedParameterDTypes:
                finalized.observedParameterDTypes,
            parameterCountMatches:
                finalized.parameterCountMatches,
            allParametersFP32:
                finalized.allParametersFP32,
            seeds: finalized.seeds,
            artifacts: finalized.artifacts,
            deviceType: finalized.deviceType,
            deviceDescription:
                finalized.deviceDescription,
            deviceArchitecture:
                finalized.deviceArchitecture,
            deviceMemoryBytes:
                finalized.deviceMemoryBytes,
            deviceMaxRecommendedWorkingSetBytes:
                finalized
                    .deviceMaxRecommendedWorkingSetBytes,
            deviceMaxBufferBytes:
                finalized.deviceMaxBufferBytes,
            batchSize: finalized.batchSize,
            gradientAccumulationSteps:
                finalized.gradientAccumulationSteps,
            sequenceLength: finalized.sequenceLength,
            completedSteps: finalized.completedSteps,
            processedPaddedTokenPositions:
                finalized.processedPaddedTokenPositions,
            supervisedTargetTokenCount:
                finalized.supervisedTargetTokenCount,
            mechanicsActiveElapsedSeconds:
                finalized.mechanicsActiveElapsedSeconds,
            peakActiveMemoryBytes:
                finalized.peakActiveMemoryBytes,
            mechanics: finalized.mechanics,
            boundary: finalized.boundary,
            supervisorAttestation:
                finalized.supervisorAttestation,
            stopReason: finalized.stopReason,
            functionalAutoregressiveOutputCount:
                finalized
                    .functionalAutoregressiveOutputCount,
            longTrainingAuthorized:
                finalized.longTrainingAuthorized,
            nextAction: finalized.nextAction
        )

        XCTAssertThrowsError(
            try divergent.validate(in: fixture.root)
        )
    }

    func testTimeLimitFailureRequiresScopedThreshold()
        throws
    {
        let fixture = try makeFixture()
        func failure(
            elapsed: Double,
            scope: PrimeGPUCalibrationElapsedTimeScope
        ) -> PrimeGPUCalibrationFailureReceipt {
            PrimeGPUCalibrationFailureReceipt(
                recordedAtUTC: "2026-07-29T00:00:00Z",
                claimScope: "supervised_timeout",
                seeds: fixture.seeds,
                artifacts: fixture.artifacts,
                stage: .workerTermination,
                reason: .timeLimitObserved,
                detail: "deadline reached",
                elapsedSeconds: .observed(elapsed),
                elapsedTimeScope: scope,
                peakActiveMemoryBytes: .unavailable,
                deviceArchitecture: .unavailable,
                deviceDescription: .unavailable,
                metalExecutionBegan: .unavailable,
                boundary: PrimeGPUCalibrationBoundary(
                    externalExecutionExclusionReason:
                        PrimeSwiftExecutionBoundary
                            .strictExclusionReason
                ),
                nextAction: "inspect_timeout"
            )
        }

        let supervisor = failure(
            elapsed: 1_800,
            scope: .supervisorEndToEnd
        )
        XCTAssertNoThrow(
            try supervisor.validate(in: fixture.root)
        )
        XCTAssertEqual(
            supervisor.durableEvidence.timing
                .endToEndWallSeconds.value,
            1_800
        )
        XCTAssertThrowsError(
            try failure(
                elapsed: 1_799,
                scope: .supervisorEndToEnd
            ).validate(in: fixture.root)
        )
        let worker = failure(
            elapsed: 1_800,
            scope: .workerExecution
        )
        XCTAssertNoThrow(
            try worker.validate(in: fixture.root)
        )
        XCTAssertNil(
            worker.durableEvidence.timing
                .endToEndWallSeconds.value
        )
    }

    func testCalibrationReuseRequiresExactConfigurationAndBoundary()
        throws
    {
        let fixture = try makeFixture()
        let final = try makeFinalizedReceipt(
            fixture: fixture
        )
        try final.validate(in: fixture.root)
        let calibrationBinding =
            try fixture.root.publishCanonical(
                final.durableReceipt(
                    receiptID: "exact-calibration"
                ),
                at: "exact-calibration.json"
            )
        let baseline = PrimeRunAuthorization(
            seeds: fixture.seeds,
            artifacts: fixture.artifacts,
            calibrationReceipt: calibrationBinding,
            externalExecutionExclusionReason:
                PrimeSwiftExecutionBoundary
                    .strictExclusionReason
        )
        XCTAssertNoThrow(
            try baseline.resolve(in: fixture.root)
        )

        let changedReason =
            PrimeSwiftExecutionBoundary
                .strictExclusionReason + " changed"
        let changedConfiguration =
            PrimeNative3BFP32ExecutionConfiguration(
                seeds: fixture.seeds,
                executable:
                    fixture.artifacts.executable,
                sourceSnapshot:
                    fixture.artifacts.sourceSnapshot,
                mlxDefaultMetallib:
                    fixture.artifacts
                        .mlxDefaultMetallib,
                externalExecutionExclusionReason:
                    changedReason
            )
        try changedConfiguration.validate()
        let changedConfigurationBinding =
            try fixture.root.publishCanonical(
                changedConfiguration,
                at: "changed-calibration-config.json"
            )
        let changedArtifacts =
            PrimeExecutionArtifactBindings(
                executable:
                    fixture.artifacts.executable,
                configuration:
                    changedConfigurationBinding,
                sourceSnapshot:
                    fixture.artifacts.sourceSnapshot,
                mlxDefaultMetallib:
                    fixture.artifacts
                        .mlxDefaultMetallib
            )
        let mutation = PrimeRunAuthorization(
            seeds: fixture.seeds,
            artifacts: changedArtifacts,
            calibrationReceipt: calibrationBinding,
            externalExecutionExclusionReason:
                changedReason
        )
        XCTAssertThrowsError(
            try mutation.resolve(in: fixture.root)
        )
    }

    private func plan(
        schemaVersion: Int = 1,
        batchSize: Int = 1,
        gradientAccumulationSteps: Int = 1,
        sequenceLength: Int = 128,
        optimizerSteps: Int = 1,
        workerActiveTimeLimitSeconds: Double = 1_800,
        supervisorEndToEndWallLimitSeconds: Double =
            1_800,
        terminationGraceSeconds: Double = 10,
        requestedMLXMemoryLimitBytes: Int =
            96 * 1024 * 1024 * 1024,
        memoryCacheLimitBytes: Int = 512 * 1024 * 1024,
        optimizerImplementation: String =
            "MLXOptimizers.AdamW",
        optimizerPackageVersion: String = "0.31.3",
        optimizerLearningRate: Double = 0.0001,
        optimizerBeta1: Double = 0.9,
        optimizerBeta2: Double = 0.999,
        optimizerEpsilon: Double = 1e-8,
        optimizerWeightDecay: Double = 0.01,
        optimizerBiasCorrectionApplied: Bool = false,
        mlxSwiftLMVersion: String = "3.31.3",
        functionalEvaluationAuthorized: Bool = false,
        longTrainingAuthorized: Bool = false
    ) -> PrimeGPUCalibrationPlan {
        PrimeGPUCalibrationPlan(
            schemaVersion: schemaVersion,
            armID:
                "exact_3b_fp32_allocation_update_probe_b1_s128_a1",
            batchSize: batchSize,
            gradientAccumulationSteps:
                gradientAccumulationSteps,
            sequenceLength: sequenceLength,
            optimizerSteps: optimizerSteps,
            workerActiveTimeLimitSeconds:
                workerActiveTimeLimitSeconds,
            supervisorEndToEndWallLimitSeconds:
                supervisorEndToEndWallLimitSeconds,
            terminationGraceSeconds:
                terminationGraceSeconds,
            requestedMLXMemoryLimitBytes:
                requestedMLXMemoryLimitBytes,
            memoryCacheLimitBytes: memoryCacheLimitBytes,
            optimizerImplementation: optimizerImplementation,
            optimizerPackageVersion:
                optimizerPackageVersion,
            optimizerLearningRate: optimizerLearningRate,
            optimizerBeta1: optimizerBeta1,
            optimizerBeta2: optimizerBeta2,
            optimizerEpsilon: optimizerEpsilon,
            optimizerWeightDecay: optimizerWeightDecay,
            optimizerBiasCorrectionApplied:
                optimizerBiasCorrectionApplied,
            mlxSwiftLMVersion: mlxSwiftLMVersion,
            functionalEvaluationAuthorized:
                functionalEvaluationAuthorized,
            longTrainingAuthorized: longTrainingAuthorized
        )
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
            Data("Mach-O-calibration-fixture".utf8),
            at: "PrimeGPUCalibration",
            purpose: .executable
        )
        let sourceSnapshot =
            try PrimeSwiftSourceSnapshotTestSupport
                .currentReleaseSnapshot()
        let source = try root.publishCanonical(
            sourceSnapshot,
            at: "source.snapshot"
        )
        let metallib =
            try PinnedMLXMetallibTestSupport
                .publish(in: root)
        let configuration =
            PrimeNative3BFP32ExecutionConfiguration(
                seeds: seeds,
                executable: executable,
                sourceSnapshot: source,
                mlxDefaultMetallib: metallib,
                calibrationPlan: .initialAllocationProbe,
                externalExecutionExclusionReason:
                    PrimeSwiftExecutionBoundary
                        .strictExclusionReason
            )
        try configuration.validate()
        let configurationBinding =
            try root.publishCanonical(
                configuration,
                at: "calibration-config.json"
            )
        return Fixture(
            root: root,
            seeds: seeds,
            artifacts:
                PrimeExecutionArtifactBindings(
                    executable: executable,
                    configuration:
                        configurationBinding,
                    sourceSnapshot: source,
                    mlxDefaultMetallib: metallib
                ),
            sourceSnapshot: sourceSnapshot
        )
    }

    private func makeWorkerCandidate(
        fixture: Fixture,
        batchSize: Int = 1,
        completedSteps: Int = 1,
        processedPaddedTokenPositions: UInt64 = 128,
        supervisedTargetTokenCount: UInt64 = 127,
        mechanicsActiveElapsedSeconds: Double = 30,
        stepLosses: [Double] = [6.2],
        expectedOptimizerStateArrayCount: Int = 508,
        optimizerStateArrayCount: Int = 508,
        optimizerStateDTypes: [String] = ["float32"],
        optimizerStateL2Norm: Double = 1,
        optimizerBiasCorrectionApplied: Bool = false,
        optimizerStateRestoreSupported: Bool = false,
        boundary: PrimeGPUCalibrationBoundary? = nil
    ) -> PrimeGPUCalibrationReceipt {
        PrimeGPUCalibrationReceipt(
            outcome: .grounded,
            claimScope:
                "allocation_forward_backward_adamw_step_only_no_language_capability",
            recordedAtUTC: "2026-07-29T00:00:00Z",
            expectedParameterCount:
                PrimeNativeProfiles.exact3B.parameterCount,
            observedParameterCount:
                PrimeNativeProfiles.exact3B.parameterCount,
            observedParameterDTypes: ["float32"],
            parameterCountMatches: true,
            allParametersFP32: true,
            seeds: fixture.seeds,
            artifacts: fixture.artifacts,
            deviceType: "gpu",
            deviceDescription: "Apple M5 Max",
            deviceArchitecture: "MTL8",
            deviceMemoryBytes:
                128 * 1024 * 1024 * 1024,
            deviceMaxRecommendedWorkingSetBytes:
                107 * 1024 * 1024 * 1024,
            deviceMaxBufferBytes:
                80 * 1024 * 1024 * 1024,
            batchSize: batchSize,
            gradientAccumulationSteps: 1,
            sequenceLength: 128,
            completedSteps: completedSteps,
            processedPaddedTokenPositions:
                processedPaddedTokenPositions,
            supervisedTargetTokenCount:
                supervisedTargetTokenCount,
            mechanicsActiveElapsedSeconds:
                mechanicsActiveElapsedSeconds,
            peakActiveMemoryBytes:
                80 * 1024 * 1024 * 1024,
            mechanics: PrimeGPUCalibrationMechanics(
                forwardLogitsFinite: true,
                initialEvaluationLoss: 6.3,
                finalEvaluationLoss: 6.2,
                stepLosses: stepLosses,
                firstGradientNorm: 1,
                selectedParameterFingerprintBefore: "before",
                selectedParameterFingerprintAfter: "after",
                optimizerImplementation:
                    "MLXOptimizers.AdamW",
                optimizerPackageVersion: "0.31.3",
                optimizerLearningRate: 0.0001,
                optimizerBeta1: 0.9,
                optimizerBeta2: 0.999,
                optimizerEpsilon: 1e-8,
                optimizerWeightDecay: 0.01,
                optimizerBiasCorrectionApplied:
                    optimizerBiasCorrectionApplied,
                expectedOptimizerStateArrayCount:
                    expectedOptimizerStateArrayCount,
                optimizerStateArrayCount:
                    optimizerStateArrayCount,
                optimizerStateDTypes: optimizerStateDTypes,
                optimizerStateL2Norm:
                    optimizerStateL2Norm,
                optimizerStepChangedWeights: true,
                optimizerStateRestoreSupported:
                    optimizerStateRestoreSupported
            ),
            boundary:
                boundary
                ?? PrimeGPUCalibrationBoundary(
                    externalExecutionExclusionReason:
                        PrimeSwiftExecutionBoundary
                            .strictExclusionReason
                ),
            stopReason: .mechanicsCompleted,
            functionalAutoregressiveOutputCount: 0,
            longTrainingAuthorized: false,
            nextAction:
                "implement_and_verify_exact_maintained_optimizer_state_restore_before_long_resumable_training"
        )
    }

    private func makeFinalizedReceipt(
        fixture: Fixture,
        batchSize: Int = 1,
        completedSteps: Int = 1,
        processedPaddedTokenPositions: UInt64 = 128,
        supervisedTargetTokenCount: UInt64 = 127,
        mechanicsActiveElapsedSeconds: Double = 30,
        stepLosses: [Double] = [6.2],
        expectedOptimizerStateArrayCount: Int = 508,
        optimizerStateArrayCount: Int = 508,
        optimizerStateDTypes: [String] = ["float32"],
        optimizerStateL2Norm: Double = 1,
        optimizerBiasCorrectionApplied: Bool = false,
        optimizerStateRestoreSupported: Bool = false
    ) throws -> PrimeGPUCalibrationReceipt {
        let candidate = makeWorkerCandidate(
            fixture: fixture,
            batchSize: batchSize,
            completedSteps: completedSteps,
            processedPaddedTokenPositions:
                processedPaddedTokenPositions,
            supervisedTargetTokenCount:
                supervisedTargetTokenCount,
            mechanicsActiveElapsedSeconds:
                mechanicsActiveElapsedSeconds,
            stepLosses: stepLosses,
            expectedOptimizerStateArrayCount:
                expectedOptimizerStateArrayCount,
            optimizerStateArrayCount:
                optimizerStateArrayCount,
            optimizerStateDTypes:
                optimizerStateDTypes,
            optimizerStateL2Norm:
                optimizerStateL2Norm,
            optimizerBiasCorrectionApplied:
                optimizerBiasCorrectionApplied,
            optimizerStateRestoreSupported:
                optimizerStateRestoreSupported
        )
        return try finalize(
            candidate,
            fixture: fixture
        )
    }

    private func finalize(
        _ candidate: PrimeGPUCalibrationReceipt,
        fixture: Fixture,
        supervisorEndToEndWallSeconds: Double = 40,
        workerTerminationReason:
            PrimeGPUWorkerTerminationReason = .exit,
        workerTerminationStatus: Int32 = 0,
        hardTimeoutObserved: Bool = false,
        capabilityVerified: Bool = true,
        runAuthorityLeaseHeld: Bool = true
    ) throws -> PrimeGPUCalibrationReceipt {
        let candidateBinding =
            try fixture.root.publishCanonical(
                candidate,
                at:
                    "worker-candidate-\(UUID().uuidString).json"
            )
        return candidate.finalized(
            with: PrimeGPUSupervisorAttestation(
                workerCandidate: candidateBinding,
                supervisorEndToEndWallSeconds:
                    supervisorEndToEndWallSeconds,
                workerTerminationReason:
                    workerTerminationReason,
                workerTerminationStatus:
                    workerTerminationStatus,
                hardTimeoutObserved:
                    hardTimeoutObserved,
                capabilityVerified: capabilityVerified,
                runAuthorityLeaseHeld:
                    runAuthorityLeaseHeld
            )
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
}
