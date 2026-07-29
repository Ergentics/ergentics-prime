import XCTest
@testable import PrimeCore

final class PrimeFactorizedExecutionTests: XCTestCase {
    private let discovery3BHash =
        "79761ac349b75a999a551a327e16db1744be470f2f3aecba0c59738e0debb6c1"

    private func provenance(
        path: String,
        hash: String,
        field: String,
        kind: PrimeHistoricalProvenanceKind =
            .historicalArtifactField
    ) -> PrimeHistoricalFieldProvenance {
        PrimeHistoricalFieldProvenance(
            kind: kind,
            artifactPath: path,
            artifactSHA256: hash,
            fieldPath: field
        )
    }

    private func historicalSeeds() throws
        -> PrimeExecutionSeeds
    {
        try PrimeExecutionSeeds
            .initialFactorizedCalibrationTriple()
    }

    private func replacementRecord(
        for domain: PrimeSeedDomain
    ) -> PrimeHistoricalSeedRecord {
        let evidence: (
            path: String,
            hash: String
        )
        switch domain {
        case .initialization:
            evidence = (
                "native-mechanics-swift-canary/" +
                "prime-native-mechanics-canary.json",
                "2211ab9640a8a7a36fa2eac982969a9ff3c82f0e3467b377d05054b0cf11422f"
            )
        case .trainingSchedule:
            evidence = (
                "native-mechanics-swift-canary-1200/" +
                "prime-native-mechanics-canary.json",
                "b951c43b1e9af07b7adf333f189fc99e58f4f821415b20b2738ce30dbf3eee06"
            )
        case .evaluation:
            evidence = (
                "native-mechanics-swift-canary-1200-w2/" +
                "prime-native-mechanics-canary.json",
                "686bc619ca2019e0960a887b35a8e7dc853172b0d24d27cfbba01e5624c7360c"
            )
        }
        return PrimeHistoricalSeedRecord(
            domain: domain,
            value: 1_729,
            provenance: provenance(
                path: evidence.path,
                hash: evidence.hash,
                field: "$.training.seed"
            )
        )
    }

    private func baseCalibration(
        wallSeconds: Double? = 838.8606909513474,
        maximumBlocks: Int? = nil,
        patienceBlocks: Int? = nil,
        minimumImprovement: Double? = nil
    ) throws -> PrimeExecutionCalibration {
        let sourcePath =
            "native-language-canary-v4/profile_probe/discovery/" +
            "ergentics_prime_native_3b_gqa_v1/lr-0p0001/" +
            "seed-1618/prime-native-language-" +
            "ergentics_prime_native_3b_gqa_v1-" +
            "discovery-lr0p0001-seed1618.json"

        func observation<T>(
            _ value: T?,
            field: String
        ) -> PrimeCalibrationObservation<T>
        where T: Codable & Equatable & Sendable {
            PrimeCalibrationObservation(
                value: value,
                provenance: value == nil
                    ? nil
                    : provenance(
                        path: sourcePath,
                        hash: discovery3BHash,
                        field: field
                    )
            )
        }

        return try PrimeExecutionCalibration(
            curriculumBlockPositions: observation(
                147_456,
                field:
                    "$.training.processed_padded_token_positions"
            ),
            optimizerStepsPerBlock: observation(
                36,
                field: "$.training.requested_steps"
            ),
            matchedActiveWallSeconds: observation(
                wallSeconds,
                field:
                    "$.training.measured_total_executor_wall_seconds"
            ),
            convergenceMaximumCurriculumBlocks:
                observation(
                    maximumBlocks,
                    field:
                        "$.test_calibration.maximum_curriculum_blocks"
                ),
            convergencePatienceCurriculumBlocks:
                observation(
                    patienceBlocks,
                    field:
                        "$.test_calibration.patience_curriculum_blocks"
                ),
            convergenceMinimumLossImprovement:
                observation(
                    minimumImprovement,
                    field:
                        "$.test_calibration.minimum_loss_improvement"
                )
        )
    }

    private func progress(
        steps: Int,
        wall: Double? = nil,
        losses: [Double]? = nil
    ) -> PrimeExecutionProgress {
        PrimeExecutionProgress(
            completedOptimizerSteps: steps,
            processedPaddedPositions: steps * 4_096,
            activeMonotonicWallSeconds: wall,
            validationLossByCompletedBlock: losses
        )
    }

    func testHistoricalSeedsRouteDirectlyToExactLoci() throws {
        let seeds = try historicalSeeds()

        XCTAssertEqual(
            seeds.initializationWitness().domain,
            .initialization
        )
        XCTAssertEqual(
            seeds.initializationWitness().locus,
            .parameterInitialization
        )
        XCTAssertEqual(
            seeds.initializationWitness().routedValue,
            1_618
        )
        XCTAssertEqual(
            seeds.trainingScheduleWitness().domain,
            .trainingSchedule
        )
        XCTAssertEqual(
            seeds.trainingScheduleWitness().locus,
            .curriculumOrdering
        )
        XCTAssertEqual(
            seeds.trainingScheduleWitness().routedValue,
            2_718
        )
        XCTAssertEqual(
            seeds.evaluationWitness().domain,
            .evaluation
        )
        XCTAssertEqual(
            seeds.evaluationWitness().locus,
            .evaluationOrdering
        )
        XCTAssertEqual(
            seeds.evaluationWitness().routedValue,
            3_141
        )
        for locus in PrimeRandomnessLocus.allCases {
            XCTAssertEqual(
                seeds.witness(for: locus).domain,
                locus.requiredSeedDomain
            )
        }
    }

    func testInitialFactorizedCalibrationTripleHasExactStagedProvenance()
        throws
    {
        let seeds = try PrimeExecutionSeeds
            .initialFactorizedCalibrationTriple()

        XCTAssertEqual(seeds.initialization.value, 1_618)
        XCTAssertEqual(
            seeds.initialization.provenance.artifactPath,
            "content-staging/" +
                "prime-domain-trace-shadow-seed1618-" +
                "recommend.v1.json"
        )
        XCTAssertEqual(
            seeds.initialization.provenance.artifactSHA256,
            "640bfa9f4172f715c1a94e98358b6202" +
                "2793b5d83051451e151fc7e1263d7329"
        )
        XCTAssertEqual(
            seeds.initialization.provenance.fieldPath,
            "seed"
        )

        XCTAssertEqual(seeds.trainingSchedule.value, 2_718)
        XCTAssertEqual(
            seeds.trainingSchedule.provenance.artifactPath,
            "content-staging/" +
                "prime-domain-trace-shadow-seed2718-" +
                "recommend.v1.json"
        )
        XCTAssertEqual(
            seeds.trainingSchedule.provenance.artifactSHA256,
            "a55b494d9c0ba08a170fbb02edba132d" +
                "ac3f4fef2789de8d85eb9b772e46d31e"
        )
        XCTAssertEqual(
            seeds.trainingSchedule.provenance.fieldPath,
            "seed"
        )

        XCTAssertEqual(seeds.evaluation.value, 3_141)
        XCTAssertEqual(
            seeds.evaluation.provenance.artifactPath,
            "content-staging/" +
                "prime-domain-trace-shadow-seed3141-" +
                "recommend.v1.json"
        )
        XCTAssertEqual(
            seeds.evaluation.provenance.artifactSHA256,
            "03c7c1abc110202e758b826d44005c327" +
                "a7d2afa135afd70218794aaac103da5"
        )
        XCTAssertEqual(
            seeds.evaluation.provenance.fieldPath,
            "seed"
        )

        XCTAssertEqual(
            Set([
                seeds.initialization.provenance.artifactSHA256,
                seeds.trainingSchedule.provenance.artifactSHA256,
                seeds.evaluation.provenance.artifactSHA256,
            ]).count,
            3
        )
    }

    func testEachSeedMutationChangesOnlyItsOwnLocus()
        throws
    {
        let baseline = try historicalSeeds()
        let original = Dictionary(
            uniqueKeysWithValues:
                PrimeRandomnessLocus.allCases.map {
                    ($0, baseline.witness(for: $0))
                }
        )

        for domain in PrimeSeedDomain.allCases {
            let mutated = try PrimeExecutionSeeds(
                initialization: domain == .initialization
                    ? replacementRecord(for: domain)
                    : baseline.initialization,
                trainingSchedule: domain == .trainingSchedule
                    ? replacementRecord(for: domain)
                    : baseline.trainingSchedule,
                evaluation: domain == .evaluation
                    ? replacementRecord(for: domain)
                    : baseline.evaluation
            )

            for locus in PrimeRandomnessLocus.allCases {
                if locus.requiredSeedDomain == domain {
                    XCTAssertNotEqual(
                        mutated.witness(for: locus),
                        original[locus]
                    )
                } else {
                    XCTAssertEqual(
                        mutated.witness(for: locus),
                        original[locus]
                    )
                }
            }
        }
    }

    func testRootAliasAndReusedProvenanceAreRejected()
        throws
    {
        let baseline = try historicalSeeds()
        let rootAlias = PrimeHistoricalSeedRecord(
            domain: .initialization,
            value: 99,
            provenance: provenance(
                path: "forbidden-root.json",
                hash: discovery3BHash,
                field: "$.root_seed",
                kind: .rootSeedAlias
            )
        )

        XCTAssertThrowsError(
            try PrimeExecutionSeeds(
                initialization: rootAlias,
                trainingSchedule: baseline.trainingSchedule,
                evaluation: baseline.evaluation
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeFactorizedExecutionError,
                .rootSeedAliasForbidden(.initialization)
            )
        }

        let reused = PrimeHistoricalSeedRecord(
            domain: .trainingSchedule,
            value: 2_718,
            provenance: baseline.initialization.provenance
        )
        XCTAssertThrowsError(
            try PrimeExecutionSeeds(
                initialization: baseline.initialization,
                trainingSchedule: reused,
                evaluation: baseline.evaluation
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeFactorizedExecutionError,
                .reusedSeedProvenance
            )
        }
    }

    func testContractAcceptsOnlyExact3BFP32AndSwift()
        throws
    {
        let contract = try PrimeFactorizedExecutionContract(
            target: .exactNative3BFP32,
            seeds: historicalSeeds(),
            boundary: .strictSwiftOnly,
            calibration: baseCalibration()
        )

        XCTAssertEqual(
            contract.target,
            .exactNative3BFP32
        )
        XCTAssertFalse(
            contract.boundary.pythonExecutionAuthorized
        )
        XCTAssertFalse(
            contract.boundary
                .shellScientificAuthorityAuthorized
        )
        XCTAssertEqual(
            Set(contract.boundary.authorities.map(\.language)),
            [.swift]
        )
    }

    func testContractRejects300MAndBF16Mutations()
        throws
    {
        XCTAssertThrowsError(
            try PrimeFactorizedExecutionContract(
                target: PrimeExecutionTarget(
                    profileID:
                        "ergentics_prime_native_300m_gqa_v1",
                    parameterCount: 271_107_072,
                    precision: .float32
                ),
                seeds: historicalSeeds(),
                boundary: .strictSwiftOnly,
                calibration: baseCalibration()
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeFactorizedExecutionError,
                .unsupportedProfile(
                    "ergentics_prime_native_300m_gqa_v1"
                )
            )
        }

        XCTAssertThrowsError(
            try PrimeFactorizedExecutionContract(
                target: PrimeExecutionTarget(
                    profileID:
                        PrimeNativeProfiles.exact3B.profileID,
                    parameterCount:
                        PrimeNativeProfiles.exact3B
                            .parameterCount,
                    precision: .bfloat16
                ),
                seeds: historicalSeeds(),
                boundary: .strictSwiftOnly,
                calibration: baseCalibration()
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeFactorizedExecutionError,
                .unsupportedPrecision(.bfloat16)
            )
        }
    }

    func testPythonAndShellAuthorityMutationsAreRejected()
        throws
    {
        let swift = PrimeSwiftExecutionBoundary.strictSwiftOnly
        var pythonBindings = swift.authorities
        let mutationIndex = try XCTUnwrap(
            pythonBindings.firstIndex {
                $0.locus == .mutationSynthesis
            }
        )
        pythonBindings[mutationIndex] = PrimeAuthorityBinding(
            locus: .mutationSynthesis,
            language: .python
        )
        let pythonBoundary = PrimeSwiftExecutionBoundary(
            authorities: pythonBindings,
            pythonExecutionAuthorized: true,
            shellScientificAuthorityAuthorized: false,
            exclusionReason: swift.exclusionReason
        )

        XCTAssertThrowsError(
            try PrimeFactorizedExecutionContract(
                target: .exactNative3BFP32,
                seeds: historicalSeeds(),
                boundary: pythonBoundary,
                calibration: baseCalibration()
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeFactorizedExecutionError,
                .nonSwiftAuthority(
                    locus: .mutationSynthesis,
                    language: .python
                )
            )
        }

        var shellBindings = swift.authorities
        let shellIndex = try XCTUnwrap(
            shellBindings.firstIndex {
                $0.locus == .experimentOrchestration
            }
        )
        shellBindings[shellIndex] = PrimeAuthorityBinding(
            locus: .experimentOrchestration,
            language: .shell
        )
        let shellBoundary = PrimeSwiftExecutionBoundary(
            authorities: shellBindings,
            pythonExecutionAuthorized: false,
            shellScientificAuthorityAuthorized: true,
            exclusionReason: swift.exclusionReason
        )
        XCTAssertThrowsError(
            try PrimeFactorizedExecutionContract(
                target: .exactNative3BFP32,
                seeds: historicalSeeds(),
                boundary: shellBoundary,
                calibration: baseCalibration()
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeFactorizedExecutionError,
                .nonSwiftAuthority(
                    locus: .experimentOrchestration,
                    language: .shell
                )
            )
        }
    }

    func testFixedTokenArmIsExactlyOneHistoricalBlock()
        throws
    {
        let controller = PrimeMultiFidelityController(
            calibration: try baseCalibration()
        )
        let budget = controller.budgetWitness(
            for: .fixedToken
        )

        XCTAssertEqual(
            budget.fixedPaddedPositionCap,
            147_456
        )
        XCTAssertEqual(
            budget.curriculumBlockPositions,
            147_456
        )
        XCTAssertEqual(
            budget.optimizerStepsPerBlock,
            36
        )
        XCTAssertNil(budget.matchedActiveWallCapSeconds)
        XCTAssertNil(
            budget.convergenceMaximumCurriculumBlocks
        )
        XCTAssertEqual(
            try controller.decision(
                for: .fixedToken,
                current: progress(steps: 35)
            ),
            .continueRun
        )
        XCTAssertEqual(
            try controller.decision(
                for: .fixedToken,
                current: progress(steps: 36)
            ),
            .stop(.fixedTokenCapReached)
        )
    }

    func testAbsentCalibrationsRemainNilAndUnavailable()
        throws
    {
        let calibration = try baseCalibration(
            wallSeconds: nil
        )
        let controller = PrimeMultiFidelityController(
            calibration: calibration
        )
        let wallBudget = controller.budgetWitness(
            for: .matchedActiveWall
        )
        let convergenceBudget = controller.budgetWitness(
            for: .convergenceCapped
        )

        XCTAssertNil(wallBudget.matchedActiveWallCapSeconds)
        XCTAssertNil(
            convergenceBudget
                .convergenceMaximumCurriculumBlocks
        )
        XCTAssertNil(
            convergenceBudget
                .convergenceMaximumPaddedPositions
        )
        XCTAssertNil(
            convergenceBudget
                .convergenceMaximumOptimizerSteps
        )
        XCTAssertNil(
            convergenceBudget
                .convergencePatienceCurriculumBlocks
        )
        XCTAssertNil(
            convergenceBudget
                .convergenceMinimumLossImprovement
        )
        XCTAssertEqual(
            try controller.decision(
                for: .matchedActiveWall,
                current: progress(steps: 1, wall: 1)
            ),
            .unavailable([
                .matchedActiveWallCalibration,
            ])
        )
        XCTAssertEqual(
            try controller.decision(
                for: .convergenceCapped,
                current: progress(steps: 0)
            ),
            .unavailable([
                .convergenceMaximumBlocksCalibration,
                .convergencePatienceCalibration,
                .convergenceMinimumImprovementCalibration,
            ])
        )
    }

    func testMatchedWallUsesActiveMonotonicObservation()
        throws
    {
        let controller = PrimeMultiFidelityController(
            calibration: try baseCalibration()
        )
        let before = progress(
            steps: 1,
            wall: 838
        )
        let after = progress(
            steps: 2,
            wall: 839
        )

        XCTAssertEqual(
            try controller.decision(
                for: .matchedActiveWall,
                current: before
            ),
            .continueRun
        )
        XCTAssertEqual(
            try controller.decision(
                for: .matchedActiveWall,
                previous: before,
                current: after
            ),
            .stop(.activeWallCapReached)
        )
        XCTAssertEqual(
            try controller.decision(
                for: .matchedActiveWall,
                current: progress(steps: 1, wall: nil)
            ),
            .unavailable([
                .activeMonotonicWallObservation,
            ])
        )
        XCTAssertThrowsError(
            try controller.decision(
                for: .matchedActiveWall,
                previous: progress(steps: 1, wall: 10),
                current: progress(steps: 2, wall: 9)
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeFactorizedExecutionError,
                .activeWallRegressed
            )
        }
    }

    func testConvergenceBudgetsAreBlockAndStepAligned()
        throws
    {
        let controller = PrimeMultiFidelityController(
            calibration: try baseCalibration(
                maximumBlocks: 4,
                patienceBlocks: 2,
                minimumImprovement: 0.1
            )
        )
        let budget = controller.budgetWitness(
            for: .convergenceCapped
        )

        XCTAssertEqual(
            budget.convergenceMaximumCurriculumBlocks,
            4
        )
        XCTAssertEqual(
            budget.convergenceMaximumPaddedPositions,
            4 * 147_456
        )
        XCTAssertEqual(
            budget.convergenceMaximumOptimizerSteps,
            4 * 36
        )
        XCTAssertEqual(
            try controller.decision(
                for: .convergenceCapped,
                current: progress(
                    steps: 2 * 36,
                    losses: [3.0, 2.8]
                )
            ),
            .continueRun
        )
        XCTAssertEqual(
            try controller.decision(
                for: .convergenceCapped,
                current: progress(
                    steps: 3 * 36,
                    losses: [3.0, 2.95, 2.94]
                )
            ),
            .stop(.convergencePatienceExhausted)
        )
        XCTAssertEqual(
            try controller.decision(
                for: .convergenceCapped,
                current: progress(
                    steps: 4 * 36,
                    losses: [3.0, 2.8, 2.6, 2.4]
                )
            ),
            .stop(.convergenceMaximumBlocksReached)
        )
    }

    func testUnalignedCalibrationAndProgressAreRejected()
        throws
    {
        let path = "historical-calibration.json"
        let positions = PrimeCalibrationObservation(
            value: 147_455,
            provenance: provenance(
                path: path,
                hash: discovery3BHash,
                field: "$.positions"
            )
        )
        let steps = PrimeCalibrationObservation(
            value: 36,
            provenance: provenance(
                path: path,
                hash: discovery3BHash,
                field: "$.steps"
            )
        )

        XCTAssertThrowsError(
            try PrimeExecutionCalibration(
                curriculumBlockPositions: positions,
                optimizerStepsPerBlock: steps,
                matchedActiveWallSeconds: .unobserved,
                convergenceMaximumCurriculumBlocks:
                    .unobserved,
                convergencePatienceCurriculumBlocks:
                    .unobserved,
                convergenceMinimumLossImprovement:
                    .unobserved
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeFactorizedExecutionError,
                .invalidCurriculumBlockPositions(147_455)
            )
        }

        let controller = PrimeMultiFidelityController(
            calibration: try baseCalibration()
        )
        XCTAssertThrowsError(
            try controller.decision(
                for: .fixedToken,
                current: PrimeExecutionProgress(
                    completedOptimizerSteps: 1,
                    processedPaddedPositions: 4_095,
                    activeMonotonicWallSeconds: nil,
                    validationLossByCompletedBlock: nil
                )
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeFactorizedExecutionError,
                .invalidProgress(
                    "optimizer_position_alignment"
                )
            )
        }
    }

    func testCodableRoundTripPreservesNilAndWitnesses()
        throws
    {
        let contract = try PrimeFactorizedExecutionContract(
            target: .exactNative3BFP32,
            seeds: historicalSeeds(),
            boundary: .strictSwiftOnly,
            calibration: baseCalibration(
                wallSeconds: nil
            )
        )
        let encoded = try JSONEncoder().encode(contract)
        let decoded = try JSONDecoder().decode(
            PrimeFactorizedExecutionContract.self,
            from: encoded
        )

        XCTAssertEqual(decoded, contract)
        XCTAssertNil(
            decoded.calibration
                .matchedActiveWallSeconds.value
        )
        XCTAssertEqual(
            decoded.seeds.evaluationWitness(),
            contract.seeds.evaluationWitness()
        )
    }
}
