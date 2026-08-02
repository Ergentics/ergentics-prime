import Foundation
@testable import PrimeCore
import PrimeNativeNeuralGateCorrectedEvaluationMechanics
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateLogitSidecarMechanics
import PrimeNativeNeuralGateReplayArtifactContracts
import XCTest

final class PrimeNativeNeuralGateReplayArtifactContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateReplayArtifactOutputContract

    func testFrozenV4IsBoundedNonAuthorizingAndIncomplete()
        throws
    {
        let contract = Contract.frozenV4

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 4)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_non_authorizing_semantic_output_namespace_v4"
        )
        XCTAssertEqual(
            contract
                .preservedHistoricalOutputContractID,
            "prime_stage_b_output_path_namespace_classification_v3"
        )
        XCTAssertEqual(
            contract.admittedSeeds.map(\.rawValue),
            [1_618, 2_718, 3_141]
        )
        XCTAssertEqual(
            contract.fixedRelativePaths.count,
            35
        )
        XCTAssertEqual(
            contract.dynamicRelativePathPatterns.count,
            10
        )
        XCTAssertEqual(contract.artifactSpecs.count, 116)
        XCTAssertEqual(
            contract.historicalMutationRecordCount,
            46
        )
        XCTAssertEqual(
            contract.correctedMutationRecordCount,
            15
        )
        XCTAssertEqual(
            contract.maximumLogitDictionaryEntryCount,
            65_536
        )
        XCTAssertEqual(
            contract.maximumBoundedInMemoryByteCount,
            1_048_576
        )
        XCTAssertEqual(
            contract.maximumJSONNestingDepth,
            16
        )
        XCTAssertEqual(
            contract.maximumJSONStringByteCount,
            65_536
        )
        XCTAssertEqual(
            contract.maximumJSONStructuralTokenCount,
            700_000
        )
        XCTAssertFalse(contract.publicationAuthorized)
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertFalse(contract.finalNamespaceClosed)
        XCTAssertFalse(
            contract
                .descriptorStreamingDecoderImplemented
        )
        XCTAssertTrue(
            contract
                .processAndReceiptOwnershipDeferred
        )
        XCTAssertTrue(
            contract
                .mutationProducerDetectorDeferred
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    contract
                )
            ),
            "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1"
        )
    }

    func testTypedKeysProduceExactDisjointPathsAndModes()
        throws
    {
        let contract = Contract.frozenV4
        let promptManifest = try contract.spec(
            for: .promptOnlyFixtureManifest
        )
        XCTAssertEqual(
            promptManifest.relativePath,
            "neural-gate-replay/corrected/fixture/prompt-only-rows-manifest.v1.json"
        )
        XCTAssertEqual(
            promptManifest.decoderMode,
            .boundedCanonicalJSON
        )
        XCTAssertEqual(
            promptManifest.owner,
            .correctedFixtureAuthority
        )

        let promptGlobal = try contract.spec(
            for: .promptOnlyFixtureGlobal
        )
        XCTAssertEqual(
            promptGlobal.decoderMode,
            .descriptorStreamingRequired
        )
        XCTAssertEqual(
            promptGlobal.encoding,
            .rawUTF8InvariantGlobal
        )

        let raw = try contract.spec(
            for:
                .rawExecutionChunk(
                    .seed2718,
                    4
                )
        )
        XCTAssertEqual(
            raw.relativePath,
            "neural-gate-replay/corrected/replicates/0000000000002718/raw-execution-chunks/00000004.v1.bin"
        )
        XCTAssertEqual(
            raw.allowedReaders,
            [
                .outerEvaluation,
                .terminalVerifier,
            ]
        )
        XCTAssertThrowsError(
            try contract.spec(
                for:
                    .rawExecutionChunk(
                        .seed2718,
                        5
                    )
            )
        )

        let logit = try contract.spec(
            for:
                .logitChunk(
                    .seed3141,
                    17
                )
        )
        XCTAssertEqual(
            logit.decoderMode,
            .sourceBoundCodecRequired
        )
        XCTAssertEqual(
            logit.maximumByteCount,
            1_048_576
        )
        XCTAssertEqual(
            logit.allowedReaders,
            [
                .mlxRecomputationReaderDeferred,
                .terminalVerifier,
            ]
        )
        XCTAssertThrowsError(
            try contract.spec(
                for:
                    .logitChunk(
                        .seed3141,
                        18
                    )
            )
        )

        let receipt = try contract.spec(
            for:
                .replacementTerminalReceiptReserved
        )
        XCTAssertEqual(
            receipt.decoderMode,
            .schemaDeferred
        )
        XCTAssertEqual(
            receipt.owner,
            .terminalReceiptOwnerDeferred
        )

        let mutation = try contract.spec(
            for:
                .mutationDeltaManifest(
                    .correctedFixedCapEOS
                )
        )
        XCTAssertEqual(
            mutation.decoderMode,
            .schemaDeferred
        )
        XCTAssertEqual(
            mutation.allowedReaders,
            [
                .mutationDetectorDeferred,
                .terminalVerifier,
            ]
        )

        let mlx = try contract.spec(
            for: .mlxObservation(.seed1618)
        )
        XCTAssertEqual(mlx.decoderMode, .schemaDeferred)
        XCTAssertEqual(
            mlx.owner,
            .mlxRecomputationOwnerDeferred
        )
        XCTAssertEqual(
            mlx.allowedReaders,
            [
                .outerEvaluation,
                .terminalVerifier,
            ]
        )

        for role in
            PrimeNativeNeuralGateHistoricalArtifactRole
            .allCases
        {
            for key: PrimeNativeNeuralGateArtifactKey in [
                .historicalMaterialManifest(role),
                .historicalGateObservation(role),
                .historicalMutationObservation(role),
            ] {
                XCTAssertEqual(
                    try contract.spec(for: key)
                        .decoderMode,
                    .schemaDeferred
                )
            }
        }
        XCTAssertEqual(
            try contract.spec(
                for: .correctedStatisticsVerdict
            ).decoderMode,
            .schemaDeferred
        )

        for spec in [
            promptManifest,
            promptGlobal,
            raw,
            logit,
            mutation,
            mlx,
            receipt,
        ] {
            XCTAssertFalse(
                spec
                    .transportCanAuthorizeMechanicsPass
            )
            XCTAssertFalse(
                spec
                    .transportCanAuthorizeCapability
            )
            XCTAssertFalse(
                spec.transportCanAuthorizeReceipt
            )
        }
    }

    func testMutationIdentityIsArmOrdinalAndID()
        throws
    {
        let historical =
            try PrimeNativeNeuralGateMutationIdentity(
                arm: .historicalForensic,
                ordinal: 13,
                mutationID:
                    "target_dependent_prompt_grouping"
            )
        let corrected =
            try PrimeNativeNeuralGateMutationIdentity(
                arm: .correctedFixedCapEOS,
                ordinal: 4,
                mutationID:
                    "target_dependent_prompt_grouping"
            )

        XCTAssertNotEqual(historical, corrected)
        XCTAssertEqual(
            Set([historical, corrected]).count,
            2
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateMutationIdentity(
                arm: .correctedFixedCapEOS,
                ordinal: 0,
                mutationID: "valid_id"
            )
        )
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateMutationIdentity(
                arm: .correctedFixedCapEOS,
                ordinal: 15,
                mutationID:
                    "retained_state_changes_permuted_row_trace"
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateMutationIdentity(
                arm: .correctedFixedCapEOS,
                ordinal: 16,
                mutationID: "valid_id"
            )
        )
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateMutationIdentity(
                arm: .historicalForensic,
                ordinal: 46,
                mutationID:
                    "malformed_abstention"
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateMutationIdentity(
                arm: .historicalForensic,
                ordinal: 47,
                mutationID: "valid_id"
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateMutationIdentity(
                arm: .historicalForensic,
                ordinal: 1,
                mutationID: "Target Drift"
            )
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateReplayLegDomain
                .historicalCriticalLegIDs,
            [
                "NL1_canonical_material_reload",
                "NL2_finite_field_sz_pool_expansion",
                "NL3_foundation_tokenizer_corpus_regrade",
                "NL4_raw_executor_row_regrade",
                "NL5_causal_training_mechanics",
                "NL6_checkpoint_durability",
                "NL7_same_seed_initialization_training_result_replay",
                "NL8_frozen_exact_seed_consensus",
                "NL9_capability_and_malformed_abstention",
                "NL10_mutation_synthesis",
            ]
        )

        let historicalSequence = try
            PrimeNativeNeuralGateMutationCatalog
            .historicalEntries.map {
                try PrimeNativeNeuralGateMutationIdentity(
                    arm: .historicalForensic,
                    ordinal: $0.ordinal,
                    mutationID: $0.mutationID
                )
            }
        XCTAssertTrue(
            PrimeNativeNeuralGateMutationCatalog
                .isExactOrderedSequence(
                    historicalSequence,
                    for: .historicalForensic
                )
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateMutationCatalog
                .isExactOrderedSequence(
                    Array(historicalSequence.reversed()),
                    for: .historicalForensic
                )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateMutationIdentity(
                arm: .correctedFixedCapEOS,
                ordinal: 4,
                mutationID:
                    "fixed_cap_drift"
            )
        )
    }

    func testNamespacePathsAreSortedUniqueASCIIAndTraversalFree()
        throws
    {
        let contract = Contract.frozenV4
        let paths =
            contract.fixedRelativePaths
            + contract.dynamicRelativePathPatterns

        XCTAssertEqual(
            Set(paths).count,
            paths.count
        )
        for path in paths {
            XCTAssertFalse(path.hasPrefix("/"), path)
            XCTAssertFalse(path.contains("\\"), path)
            XCTAssertFalse(path.contains("/../"), path)
            XCTAssertFalse(path.contains("/./"), path)
            XCTAssertFalse(path.contains("/.git/"), path)
            XCTAssertTrue(
                path.utf8.allSatisfy {
                    $0 >= 0x21 && $0 <= 0x7e
                },
                path
            )
        }
    }

    func testCopiedContractValuesReconcileWithFrozenSwiftAuthorities()
        throws
    {
        let contract = Contract.frozenV4
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        let plan =
            PrimeNativeNeuralGateFixtureReplayPlan
            .frozenV5

        XCTAssertEqual(
            contract.admittedSeeds.map(\.rawValue),
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .admittedEvaluationSeeds
        )
        XCTAssertEqual(
            contract.maximumPromptTokenCount,
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .maximumPromptByteCount + 1
        )
        XCTAssertEqual(
            contract.fullVocabularyLogitCount,
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .fullVocabularyLogitCount
        )
        XCTAssertEqual(
            contract.maximumGenerationDecisions,
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .maximumGenerationDecisions
        )
        XCTAssertEqual(
            contract.exactCorrectedFixtureRowCount,
            PrimeNativeNeuralGateLogitSidecarPolicy
                .exactRowCount
        )
        XCTAssertEqual(
            contract.logitRowsPerChunk,
            PrimeNativeNeuralGateLogitSidecarPolicy
                .rowsPerChunk
        )
        XCTAssertEqual(
            contract.logitChunkCount,
            PrimeNativeNeuralGateLogitSidecarPolicy
                .exactChunkCount
        )
        XCTAssertEqual(
            contract.maximumLogitDictionaryEntryCount,
            PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumDictionaryEntryCount
        )
        XCTAssertEqual(
            try contract.spec(
                for: .logitDictionary(.seed1618)
            ).maximumByteCount,
            UInt64(
                PrimeNativeNeuralGateLogitSidecarPolicy
                    .maximumDictionaryFileByteCount
            )
        )
        XCTAssertEqual(
            try contract.spec(
                for: .logitChunk(.seed1618, 0)
            ).maximumByteCount,
            UInt64(
                PrimeNativeNeuralGateLogitSidecarPolicy
                    .maximumChunkFileByteCount
            )
        )
        XCTAssertEqual(
            try contract.spec(
                for: .logitManifest(.seed1618)
            ).maximumByteCount,
            UInt64(
                PrimeNativeNeuralGateLogitSidecarPolicy
                    .maximumManifestFileByteCount
            )
        )

        XCTAssertEqual(
            contract.historicalMutationCatalog
                .map(\.ordinal),
            projection.mutationCatalog.map {
                UInt32($0.ordinal)
            }
        )
        XCTAssertEqual(
            contract.historicalMutationCatalog
                .map(\.mutationID),
            projection.mutationCatalog
                .map(\.mutationID)
        )
        XCTAssertEqual(
            contract.historicalMutationCatalog
                .map(\.expectedFailedLegID),
            projection.mutationCatalog
                .map(\.expectedFailedLeg)
        )
        XCTAssertEqual(
            contract.historicalCriticalLegIDs,
            projection.criticalLegs.map(\.legID)
        )

        XCTAssertEqual(
            contract.correctedMutationCatalog
                .map(\.ordinal),
            plan.correctedMutationCatalog.map {
                UInt32($0.ordinal)
            }
        )
        XCTAssertEqual(
            contract.correctedMutationCatalog
                .map(\.mutationID),
            plan.correctedMutationCatalog
                .map(\.mutation.rawValue)
        )
        XCTAssertEqual(
            contract.correctedMutationCatalog
                .map(\.expectedFailedLegID),
            plan.correctedMutationCatalog
                .map(\.expectedFailedLeg)
        )
        XCTAssertEqual(
            contract.correctedMutationFailureLegIDs,
            orderedUnique(
                plan.correctedMutationCatalog
                    .map(\.expectedFailedLeg)
            )
        )
        XCTAssertEqual(
            contract.implementedRecordSchemaIDs,
            [
                PrimeNativeNeuralGateReplayRecordSchema
                    .promptOnlyRowV1,
                PrimeNativeNeuralGateReplayRecordSchema
                    .outerEvaluationRowV1,
                PrimeNativeNeuralGateReplayRecordSchema
                    .rawExecutionReferenceV1,
            ]
        )
    }

    func testHistoricalV3ReplayOutputAndPlanIdentitiesRemainExact()
        throws
    {
        XCTAssertEqual(
            try PrimeNativeNeuralGateFixtureReplayPlan
                .frozenV3.contentSHA256(),
            "9e8e9c4820fcea592f79cb4cbdc9abdd217a0ca6e00e2b715a215d8a1d315ee6"
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateReplayOutputContract
                .frozenV3
                .pathClassification
                .contractID,
            "prime_stage_b_output_path_namespace_classification_v3"
        )
    }

    func testPureContractSourceHasNoRuntimeOrAuthorityImports()
        throws
    {
        let sources = try completeSwiftSources(
            target:
                "PrimeNativeNeuralGateReplayArtifactContracts"
        )
        let forbiddenFragments = [
            "import PrimeCore",
            "import PrimeNativeNeuralGateCorrectedMechanics",
            "import PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "import PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "import PrimeNativeNeuralGatePromptSolver",
            "import PrimeNativeNeuralGateLogitSidecarMechanics",
            "import MLX",
            "import ErgenticsPrimeRuntime",
            "Foundation.Process",
            "Process(",
            "posix_spawn",
            "execve(",
            "system(",
            "popen(",
            "/bin/sh",
            "/bin/zsh",
            "\"python3\"",
            "try" + "!",
            "fatalError(",
            "precondition(",
            "preconditionFailure(",
            "FileHandle(forWriting",
            "FileHandle(forUpdating",
            "FileHandle(forReadingFrom:",
            "FileHandle.standardInput",
            "FileManager.default",
            "Data(contentsOf:",
            "String(contentsOf:",
            "InputStream(",
            "Bundle.",
            "OutputStream(",
            "URLSession",
            "import Network",
            "NWConnection",
            "CFReadStream",
            "NSFileCoordinator",
            "createFile(",
            "write(to:",
            "read(",
            "O_WRONLY",
            "O_RDWR",
            "O_CREAT",
            "O_RDONLY",
            "open(",
            "openat(",
            "fopen(",
            "mmap(",
            "stat(",
            "lstat(",
            "fstat(",
            "access(",
            "opendir(",
            "readdir(",
            "rename(",
            "unlink(",
        ]
        for (fileName, source) in sources {
            XCTAssertEqual(
                source
                    .split(separator: "\n")
                    .filter {
                        $0.hasPrefix("import ")
                    }
                    .map(String.init),
                ["import Foundation"],
                "\(fileName) must import Foundation only"
            )
            for forbidden in forbiddenFragments {
                XCTAssertFalse(
                    source.contains(forbidden),
                    "\(fileName): \(forbidden)"
                )
            }
        }
    }

    private func completeSwiftSources(
        target: String
    ) throws -> [(fileName: String, source: String)] {
        let directory =
            repositoryRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent(
                target,
                isDirectory: true
            )
        let entries = try FileManager.default
            .contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            .sorted {
                $0.lastPathComponent
                    < $1.lastPathComponent
            }
        let swiftFiles = entries.filter {
            $0.pathExtension == "swift"
        }
        XCTAssertFalse(swiftFiles.isEmpty)
        XCTAssertEqual(
            entries.map(\.lastPathComponent),
            swiftFiles.map(\.lastPathComponent),
            "pure target contains a non-Swift entry"
        )
        return try swiftFiles.map { file in
            (
                file.lastPathComponent,
                try String(
                    contentsOf: file,
                    encoding: .utf8
                )
            )
        }
    }

    private func orderedUnique(
        _ values: [String]
    ) -> [String] {
        var observed = Set<String>()
        return values.filter {
            observed.insert($0).inserted
        }
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
