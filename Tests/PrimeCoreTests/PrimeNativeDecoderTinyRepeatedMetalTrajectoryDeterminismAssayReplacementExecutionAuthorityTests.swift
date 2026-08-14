// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.authorityID,
            "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_replacement_execution_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityKind,
            "separate_one_shot_stage5_ab_replacement_execution_authority"
        )

        let main = authority.currentMain
        XCTAssertEqual(main.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(main.ref, "refs/heads/main")
        XCTAssertEqual(
            main.mergeRevision,
            "54635d6b58e4f9c7ddedb30a3c22fffb17d8e174")
        XCTAssertEqual(
            main.mergeTree,
            "afd51da78370aee8851341fe46b2533450944b2f")
        XCTAssertEqual(
            main.orderedParentRevisions,
            [
                "437acb46a5af63f6c604e5f5c50f3b63eaa296f2",
                "03d31f5cc3acfddd338fd06dea5a14aa0bc10677",
            ])
        XCTAssertEqual(main.pullRequestNumber, 108)
        XCTAssertEqual(main.workflowRunID, 31_793_069_525)
        XCTAssertEqual(main.workflowRunNumber, 113)
        XCTAssertEqual(main.workflowRunAttempt, 1)
        XCTAssertEqual(main.checkSuiteID, 86_250_730_227)
        XCTAssertEqual(main.activeRootJobID, 94_744_094_754)
        XCTAssertEqual(main.reviewedMainJobID, 94_744_877_958)
        XCTAssertEqual(main.conclusion, "success")
        XCTAssertEqual(main.rootTestCount, 56)
        XCTAssertEqual(main.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(main.focusedWholeTestCount, 62)
        XCTAssertEqual(main.totalTestCount, 108)
        XCTAssertTrue(main.exactMainSealed)
        XCTAssertEqual(main.exactChangedSources.count, 5)
        XCTAssertEqual(
            main.exactChangedSources.map(\.gitBlob),
            [
                "acf57af123abeb8e7e00b9cba190aaf9e3524db5",
                "d73871ff049d9a1be36ba2a26ab1075cb91e2fb4",
                "29ee5012a771afbc8eb369ef93c1d5b676342b69",
                "f2b688b5c073a71d4179a75f0ced9651ac696025",
                "075a07a0ff9577a9b9c6f9824d2c632db2fe78bf",
            ])

        let predecessor = authority.predecessor
        XCTAssertEqual(
            predecessor.failureObservationID,
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationV1
                .frozenV1.observationID)
        XCTAssertEqual(
            predecessor.failureObservationCanonicalSHA256,
            "ac735b84948e6b9b6b492a79925d7e0770d6eb332ba4d643d7f2884a4a7f81d2")
        XCTAssertEqual(
            predecessor.designAuthorityCanonicalSHA256,
            "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589")
        XCTAssertEqual(
            predecessor.originalStage5AuthorityCanonicalSHA256,
            "00c49e63315b2aacb439204e778f54bcf63c2fdf643282f3bd64e2b3b4094089")
        XCTAssertEqual(
            predecessor.immediateRepairAuthorityCanonicalSHA256,
            "a5a8e5300ea8413e738fddd4b8fed930dcc9983d5a29eea102862f9744b50fff")
        XCTAssertEqual(
            predecessor.stage6AuthorityCanonicalSHA256,
            "2627ffc0dd6499a9a1b20fa217b7f1c4a9723a6fd6332ef24a9ee251b5b0bf56")
        XCTAssertEqual(
            predecessor.stage6ObservationCanonicalSHA256,
            "6f18f128b30565cba0e53ad4f834882d050851199639299d2aa9ecf2e0cb51bf")
        XCTAssertEqual(predecessor.failureWorkflowRunID, 31_756_331_438)
        XCTAssertEqual(predecessor.failureWorkflowRunNumber, 105)
        XCTAssertEqual(
            predecessor.exactThrownError,
            "contractDrift(\"source-step exact bytes\")")
        XCTAssertEqual(predecessor.combinedGuardConjuncts.count, 3)
        XCTAssertFalse(predecessor.failedConjunctIdentified)
        XCTAssertFalse(predecessor.failingTrialOrdinalEstablished)
        XCTAssertFalse(predecessor.sourceStepEqualityEstablished)
        XCTAssertFalse(predecessor.sourceStepEqualityDisproved)
        XCTAssertFalse(predecessor.globalStepOneEstablished)
        XCTAssertFalse(predecessor.globalStepOneDisproved)
        XCTAssertFalse(predecessor.selectedTargetCountSixEstablished)
        XCTAssertFalse(predecessor.selectedTargetCountSixDisproved)
        XCTAssertEqual(predecessor.failingTrialOrdinalMinimum, 1)
        XCTAssertEqual(predecessor.failingTrialOrdinalMaximum, 3)
        XCTAssertEqual(predecessor.priorCompletedTrialCountMinimum, 0)
        XCTAssertEqual(predecessor.priorCompletedTrialCountMaximum, 2)
        XCTAssertFalse(predecessor.priorCompletedTrialCountEstablished)
        XCTAssertEqual(predecessor.failureStage5ReceiptCount, 0)
        XCTAssertTrue(predecessor.originalOneShotConsumed)
        XCTAssertTrue(predecessor.originalOneShotExhausted)
        XCTAssertFalse(predecessor.originalLauncherMutationAuthorized)
        XCTAssertFalse(predecessor.originalLauncherRerunAuthorized)
        XCTAssertEqual(
            predecessor.originalAssayTest.gitBlob,
            "46f91f32e91870d21c46cd318972a857b8ef6e12")
        XCTAssertEqual(predecessor.originalAssayTest.byteCount, 28_292)
        XCTAssertEqual(predecessor.originalAssayTestLFByteCount, 606)
        XCTAssertEqual(
            predecessor.originalAssayTest.sha256,
            "50b19a0bfe8752d2b80c09527b70731d906e8064c8e2d49a758c8c48b48f4398")
        XCTAssertFalse(predecessor.originalAssayTestMutationAuthorized)
        XCTAssertFalse(predecessor.originalAssayTestRerunAuthorized)
        XCTAssertFalse(predecessor.stage5ResultEstablished)
        XCTAssertFalse(predecessor.repeatedTrajectoryDeterminismEstablished)
        XCTAssertEqual(
            predecessor.originalLauncher.path,
            ".github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh")
        XCTAssertEqual(
            predecessor.originalLauncher.gitBlob,
            "6547ee06663c1ea409a6256e48f6111245056020")
        XCTAssertEqual(predecessor.stage5RetirementRunID, 31_763_253_701)
        XCTAssertEqual(predecessor.stage5RetirementRunNumber, 107)
        XCTAssertTrue(predecessor.stage5InvocationRetired)
        XCTAssertTrue(predecessor.stage5LauncherPreservedForAudit)
        XCTAssertEqual(predecessor.stage6WorkflowRunID, 31_784_730_175)
        XCTAssertEqual(predecessor.stage6WorkflowRunNumber, 111)
        XCTAssertEqual(
            predecessor.stage6ReceiptSHA256,
            "104f3579f2caf19f27cbbe694f8a854cc8927d9188af055075c11b1fe1c94c55")
        XCTAssertEqual(predecessor.stage6UniqueParameterCount, 271_107_072)
        XCTAssertEqual(predecessor.stage6MLXPeakBytes, 4_781_317_844)
        XCTAssertEqual(predecessor.stage6MemoryCapBytes, 5_010_800_640)
        XCTAssertTrue(predecessor.stage6ResourceEnvelopeEstablished)
        XCTAssertTrue(predecessor.stage6ResourceClearanceEstablished)
        XCTAssertTrue(predecessor.stage6RunnerMemoryCapacityEstablished)
        XCTAssertFalse(predecessor.stage6OrdinaryJobFitEstablished)
        XCTAssertTrue(predecessor.stage6RetirementObservedOnCurrentMain)

        XCTAssertTrue(authority.replacementInheritsOriginalEnvironmentExactly)
        XCTAssertTrue(authority.replacementInheritsOriginalFixtureExactly)
        XCTAssertTrue(
            authority.replacementInheritsOriginalFreshnessAndBranchTopologyExactly)
        XCTAssertTrue(authority.replacementInheritsOriginalEqualityExactly)
        XCTAssertTrue(authority.originalReceiptAndTestIdentifiersReplaced)
        XCTAssertEqual(authority.inheritedOriginalEnvironment.mlxEnableTF32, "0")
        XCTAssertEqual(
            authority.inheritedOriginalEnvironment.exactMetalDeviceCount, 1)
        XCTAssertTrue(
            authority.inheritedOriginalEnvironment
                .explicitSynchronizeRequiredBeforeEveryByteRead)
        XCTAssertEqual(
            authority.inheritedOriginalFixture.sourceStepTokenIDs,
            [
                [1, 1, 1, 2, 3, 0],
                [4, 5, 6, 7, 8, 9],
            ])
        XCTAssertEqual(
            authority.inheritedOriginalFixture.successorStepTokenIDs,
            [
                [10, 11, 12, 13, 0, 0],
                [14, 15, 15, 15, 16, 0],
            ])
        XCTAssertEqual(
            authority.inheritedOriginalFixture.sourceSnapshotGlobalStep, 1)
        XCTAssertEqual(authority.inheritedOriginalFixture.terminalGlobalStep, 2)
        XCTAssertTrue(
            authority.inheritedOriginalAssayTopology
                .restoredBranchUsesFreshModelOptimizerRNGAndCursor)
        XCTAssertFalse(
            authority.inheritedOriginalAssayTopology
                .objectOrArrayAliasingAcrossBranchesAuthorized)
        XCTAssertTrue(
            authority.inheritedOriginalEquality
                .exactSourceStepAcrossAllTrialsRequired)
        XCTAssertTrue(
            authority.inheritedOriginalEquality
                .exactSuccessorAndTerminalAcrossAllTrialsRequired)
        XCTAssertTrue(
            authority.inheritedOriginalEquality
                .float32LittleEndianByteReadOrderRequired)

        let current = authority.currentSources
        XCTAssertEqual(
            current.decoder.gitBlob,
            "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f")
        XCTAssertEqual(
            current.training.gitBlob,
            "271b7fe4a856a76a00730954c23bdca3b33e761d")
        XCTAssertEqual(
            current.retainedAuthorityTest.gitBlob,
            "329e57a8cbb2aa55879a94c88b17c391d13a1eb4")
        XCTAssertTrue(current.decoderUsesMaintainedEmbeddingByDefault)
        XCTAssertTrue(current.defaultTrainingLogitsAPIRemainsTrainingLogitsNoCache)
        XCTAssertFalse(current.publicDecoderAPIAdditionAuthorized)
        XCTAssertFalse(current.defaultInferenceOrTrainingSemanticChangeAuthorized)

        let algorithm = authority.algorithm
        XCTAssertEqual(
            algorithm.algorithmID,
            "prime_native_decoder_flattened_dense_one_hot_matmul_input_embedding_v1")
        XCTAssertEqual(
            algorithm.selectorDeclaration,
            "PrimeNativeDecoderTinyMetalTrajectoryTrainingInputPathV1: String")
        XCTAssertEqual(
            algorithm.selectorCases,
            ["maintainedGatherV1", "denseOneHotMatmulV1"])
        XCTAssertEqual(
            algorithm.selectorRawValues,
            [
                "maintained_gather_v1",
                "flattened_dense_one_hot_matmul_input_embedding_v1",
            ])
        XCTAssertEqual(
            algorithm.orderedSelectorBindings.map(\.caseName),
            algorithm.selectorCases)
        XCTAssertEqual(
            algorithm.orderedSelectorBindings.map(\.rawValue),
            algorithm.selectorRawValues)
        XCTAssertEqual(
            algorithm.sessionSelectorProperty,
            "stage5ReplacementTrainingInputPath")
        XCTAssertEqual(
            algorithm.trainerSelectorProperty,
            algorithm.sessionSelectorProperty)
        XCTAssertTrue(algorithm.selectorImmutableAfterInitialization)
        XCTAssertEqual(algorithm.existingInitializerDefaultCase,
            "maintainedGatherV1")
        XCTAssertTrue(algorithm.existingStepAndEvaluateBehaviorRemainsGather)
        XCTAssertEqual(
            algorithm.denseModelMethod,
            "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1")
        XCTAssertEqual(
            algorithm.denseModelMethodSignature,
            "package func trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1(_ tokens: MLXArray) -> MLXArray")
        XCTAssertTrue(algorithm.denseModelMethodIsNonthrowing)
        XCTAssertEqual(
            algorithm.embeddingForwardPairMethod,
            "PrimeNativeGQADecoder.trainingInputEmbeddingForwardPairForFlattenedDenseOneHotMatmulAssayV1")
        XCTAssertEqual(
            algorithm.embeddingForwardPairMethodSignature,
            "package func trainingInputEmbeddingForwardPairForFlattenedDenseOneHotMatmulAssayV1(_ rankTwoTokenIDs: MLXArray) -> (maintainedGather: MLXArray, flattenedDenseOneHotMatmul: MLXArray)")
        XCTAssertTrue(algorithm.embeddingForwardPairMethodIsNonthrowing)
        XCTAssertTrue(algorithm.embeddingForwardPairUsesSameModelAndState)
        XCTAssertEqual(
            algorithm
                .embeddingForwardPairValidatedDenseConstructionCountPerCheck,
            1)
        XCTAssertEqual(
            algorithm
                .wholeLogitsValidatedDenseConstructionCountPerForwardCheck,
            1)
        XCTAssertEqual(
            algorithm.forwardEquivalenceMethod,
            "checkedTrainingInputPathForwardEquivalenceAtCurrentBoundaryV1")
        XCTAssertEqual(
            algorithm.forwardEquivalenceBoundaries,
            ["initial", "source_boundary", "terminal"])
        XCTAssertEqual(algorithm.flattenedTokensShapeSymbols, ["B*S", "1"])
        XCTAssertEqual(algorithm.vocabularyShapeSymbols, ["1", "V"])
        XCTAssertEqual(algorithm.oneHotShapeSymbols, ["B*S", "V"])
        XCTAssertEqual(
            algorithm.oneHotExpression,
            "(flattenedTokens .== vocabulary).asType(.float32)")
        XCTAssertEqual(algorithm.embeddingShapeSymbols, ["B*S", "W"])
        XCTAssertEqual(algorithm.restoredEmbeddingShapeSymbols, ["B", "S", "W"])
        XCTAssertEqual(algorithm.tinyOneHotElementCount, 384)
        XCTAssertEqual(algorithm.tinyOneHotByteCount, 1_536)
        XCTAssertEqual(algorithm.native300CompatibilityOneHotElementCount,
            65_536)
        XCTAssertEqual(algorithm.native300CompatibilityOneHotByteCount,
            262_144)
        XCTAssertTrue(algorithm.usesSingleFlattenedTwoDimensionalMatmul)
        XCTAssertFalse(algorithm.usesBatchedBroadcastMatmul)
        XCTAssertFalse(algorithm.usesGatherForInputEmbedding)
        XCTAssertFalse(
            algorithm.usesScatterAddForInputEmbeddingWeightVJPByConstruction)
        XCTAssertFalse(algorithm.maintainedGatherImplementationChanged)
        XCTAssertFalse(algorithm.tiedOutputProjectionChanged)
        XCTAssertTrue(algorithm.checkedExactEmbeddingForwardEquivalenceRequired)
        XCTAssertTrue(algorithm.checkedExactWholeLogitsForwardEquivalenceRequired)
        XCTAssertTrue(algorithm.tokenIDsMustBeWithinVocabularyBounds)
        XCTAssertEqual(
            algorithm.tokenBoundsPredicate,
            "all_token_ids_gte_0_and_lt_v_before_one_hot")
        XCTAssertTrue(algorithm.checkedVocabularySizeInt32ConversionRequired)
        XCTAssertEqual(
            algorithm.vocabularySizeInt32ConversionExpression,
            "guard let checkedInt32V = Int32(exactly: V) else { preconditionFailure() }")
        XCTAssertEqual(
            algorithm.tokenBoundsCombinedPredicateExpression,
            "((tokens .>= Int32(0)) .&& (tokens .< checkedInt32V)).all()")
        XCTAssertEqual(
            algorithm.tokenBoundsCheckedEvalExpression,
            "do { try checkedEval(tokenBounds) } catch { preconditionFailure() }")
        XCTAssertEqual(
            algorithm.tokenBoundsSynchronizationExpression,
            "StreamOrDevice.default.stream.synchronize()")
        XCTAssertEqual(
            algorithm.tokenBoundsHostReadExpression,
            "precondition(tokenBounds.item(Bool.self))")
        XCTAssertEqual(
            algorithm.tokenBoundsCheckedEvalFailureAction,
            "preconditionFailure")
        XCTAssertEqual(algorithm.tokenBoundsFalseFailureAction, "precondition")
        XCTAssertEqual(
            algorithm.tokenBoundsFailureClassification,
            "invalid_infrastructure_red_no_terminal_receipt")
        XCTAssertEqual(
            algorithm.tokenBoundsOperationOrder,
            [
                "checked_vocabulary_size_int32_conversion",
                "construct_combined_bounds_reduction",
                "checked_eval_combined_bounds",
                "gpu_stream_synchronize",
                "read_one_bool_item",
                "fail_closed_or_construct_one_hot",
            ])
        XCTAssertEqual(
            algorithm.tokenBoundsCheckedEvalCountPerDenseEmbeddingCall, 1)
        XCTAssertEqual(
            algorithm.tokenBoundsGPUSynchronizeCountPerDenseEmbeddingCall, 1)
        XCTAssertEqual(
            algorithm.tokenBoundsHostBoolItemCountPerDenseEmbeddingCall, 1)
        XCTAssertTrue(
            algorithm.tokenBoundsFailureOccursBeforeOneHotConstruction)
        XCTAssertEqual(authority.externalSourceBindings.count, 11)
        XCTAssertEqual(authority.armAExternalBindingKeys.count, 4)
        XCTAssertEqual(authority.armBExternalBindingKeys.count, 9)
        XCTAssertEqual(authority.exactExternalBindingOverlapKeys.count, 2)
        XCTAssertEqual(
            authority.exactExternalBindingOverlapPaths,
            ["Source/MLXNN/Embedding.swift", "mlx/primitives.cpp"])
        XCTAssertEqual(
            authority.externalSourceBindings.map(\.claimScope),
            authority.externalSourceBindings.map(\.claimScope).sorted())
        XCTAssertEqual(
            authority.externalSourceBindings.map {
                "\($0.repository)@\($0.revision):\($0.path)|\($0.gitBlob)|\($0.sha256)"
            },
            [
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/Factory.swift|913540511292660716688dbf73e8375d0683b48b|27161deb4b2207d8806e5ac629c8ae2b0d374579169822e37810bb365383331a",
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/MLXArray+Indexing.swift|9a891b5df0d6f2bdeb0df584497c2c068b65a4e9|bde9521ff694e054f05c414442df77e7bcd816c9ee8929f538d9c2bd22d3f4fa",
                "ml-explore/mlx-c@0726ca922fc902c4c61ef9c27d94132be418e945:mlx/c/ops.cpp|f5eac1b48e75ec3d0a41903816e61168b8a78967|7b3e5028628d68c4aec3dd0587eea760d245943f3a06b6dc1d11ceebe0f040ec",
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/MLXArray.swift|121955b49b4eefd2f05d117d710990f8ba15f816|0cd516b95d5d75840978e265d3069709a8f557de96264df8605f246d91b0126c",
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLXNN/Embedding.swift|dbda7607bc4580cf914b2fcd5c0ab6094165359a|43ed8569fea7af6d5c028992662d6c0cbc256fe6f3cc8342d0b4a3ded4136f12",
                "ml-explore/mlx@ce45c52505c8158ea48d2a54e8caae05efd86bfe:mlx/ops.cpp|e6554c2c4ffb198d993b98f06941647118e3c97e|3952048eb504d51f5028f261aecf47cfcb50cf18a4958fb7946c1eba1b03afc2",
                "ml-explore/mlx@ce45c52505c8158ea48d2a54e8caae05efd86bfe:mlx/primitives.cpp|92e54f99918de054fa0b521d13e4c8f415ce2fc1|3f87a0cfcf4b15cfda6c14b00401828500a7eee8c397ce30400d76d6d0c71ad5",
                "ml-explore/mlx@ce45c52505c8158ea48d2a54e8caae05efd86bfe:mlx/backend/metal/kernels/indexing/scatter.h|f0217b3369f2c87c826a963ba900773d3b59bc91|6d6d81912ce7d6b896eb0225d1ac6885d30cd30213b67d996d3efc03f4a3c292",
                "ml-explore/mlx@ce45c52505c8158ea48d2a54e8caae05efd86bfe:mlx/backend/metal/matmul.cpp|84b6ee06da379ceb73b9c3b555adbda6af0c6322|4bef524645dce8feb94300766dec1586caf93c0167fe9757409fb452c15b1361",
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/MLXArray+Ops.swift|4d950f3da8350df9c3b01af2513f75c15ae3c289|143dddcf954dd6b9f6854ffa23a0600fa1559564ef857fd3cb98cf822b41abf6",
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/Ops+Array.swift|b0b0ddbdb8fa7b1ce95dc92452cece460bf64f79|821e38aaa144cd19b0a1ae05fbddab8fdf5277d150635445cab6d40d5761ddef",
            ])
        XCTAssertFalse(
            authority.externalSourceBindings.contains(where: {
                $0.path == "Source/MLX/Ops.swift"
            }))
        XCTAssertEqual(
            authority.inheritedExecutionSupportAuthorityID,
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_authority_v1")
        XCTAssertTrue(
            authority
                .inheritedExecutionSupportBindingsExcludedFromArmABindingUnion)
        XCTAssertEqual(
            authority.inheritedExecutionSupportBindings.map {
                "\($0.repository)@\($0.revision):\($0.path)|\($0.gitBlob)|\($0.sha256)"
            },
            [
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/Transforms+Eval.swift|46fe9c593099c0b939d1d85a68f37023a6dacc24|14b867c903be78547b426305257ca70e214b7b854acf1c0dc2cf7c82333f4999",
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/Stream.swift|c276d6dec11553eafb25988ed552aaf6f6b299a1|03b4e08befc3bbe926e21b402989b1a1411050bde900dbfac5d3f6b777183f8f",
            ])
        let armABindingUnion = Set(
            authority.armAExternalBindingKeys + authority.armBExternalBindingKeys)
        let inheritedSupportKeys = Set(
            authority.inheritedExecutionSupportBindings.map {
                "\($0.repository)@\($0.revision):\($0.path)"
            })
        XCTAssertTrue(armABindingUnion.isDisjoint(with: inheritedSupportKeys))

        let assay = authority.assay
        XCTAssertEqual(assay.fixtureVocabularySize, 32)
        XCTAssertEqual(assay.fixtureWidth, 16)
        XCTAssertEqual(assay.fixtureLayerCount, 2)
        XCTAssertEqual(assay.initializationSeed, 7)
        XCTAssertEqual(assay.expectedParameterCount, 5_200)
        XCTAssertEqual(assay.expectedParameterTensorCount, 20)
        XCTAssertEqual(assay.batchSize, 2)
        XCTAssertEqual(assay.sequenceLength, 6)
        XCTAssertEqual(assay.repeatedTokenIDs, [1, 15])
        XCTAssertEqual(assay.trialCount, 3)
        XCTAssertEqual(assay.fullTrajectoryBranchCount, 9)
        XCTAssertEqual(
            assay.exactArmExecutionOrder,
            [
                "maintained_embedding_gather_diagnostic",
                "flattened_dense_one_hot_matmul_clearance",
            ])
        XCTAssertEqual(
            assay.exactArmExecutionOrder,
            [assay.armAName, assay.armBName])
        XCTAssertEqual(
            assay.branchNames,
            [
                "uninterrupted",
                "source_snapshot",
                "fresh_restored_from_source_snapshot",
            ])
        XCTAssertTrue(assay.armADiagnosticOnly)
        XCTAssertFalse(assay.armACanGateClearance)
        XCTAssertEqual(assay.armACompletedTrialCount, 3)
        XCTAssertEqual(assay.armAIndependentSourceStepDiagnosticPairCount, 3)
        XCTAssertEqual(
            assay.armAPairBranchNames,
            ["uninterrupted", "source_snapshot"])
        XCTAssertTrue(assay.armASourceStepEqualityDisaggregated)
        XCTAssertTrue(assay.armAGlobalStepOneDisaggregated)
        XCTAssertTrue(assay.armASelectedTargetCountDisaggregated)
        XCTAssertTrue(assay.armAFirstTensorMismatchCoordinateRecorded)
        XCTAssertTrue(assay.armAFirstScalarMismatchCoordinateRecorded)
        XCTAssertFalse(assay.armARestoreBranchRequired)
        XCTAssertFalse(assay.armAMeasuredMismatchThrows)
        XCTAssertTrue(assay.armAInfrastructureFailureIsInvalidInfrastructure)
        XCTAssertFalse(assay.armAMeasuredMismatchSkipsArmB)
        XCTAssertTrue(assay.armBOptInOnly)
        XCTAssertEqual(assay.armBFullTrialCount, 3)
        XCTAssertEqual(assay.armBFullTrajectoryBranchCount, 9)
        XCTAssertTrue(
            assay.armBValidMeasurementCompletesFullPlanBeforeTerminalReceipt)
        XCTAssertEqual(assay.armBExpectedReadOnlySelectorID,
            "flattened_dense_one_hot_matmul_input_embedding_v1")
        XCTAssertTrue(assay.sourceStepComparisonsDisaggregated)
        XCTAssertTrue(assay.noCombinedGuardPermitted)
        XCTAssertTrue(assay.continueAfterMeasuredMismatch)
        XCTAssertTrue(
            Set(assay.armBReplayExactComparisonDomains).isDisjoint(
                with: Set(assay.forwardEquivalenceComparisonDomains)))
        XCTAssertEqual(
            assay.deterministicFirstMismatchComparisonDomainOrder,
            assay.forwardEquivalenceComparisonDomains
                + assay.armBReplayExactComparisonDomains)
        XCTAssertTrue(assay.crossTrialExactComparisonRequired)
        XCTAssertFalse(assay.durableCheckpointIOAuthorized)
        XCTAssertFalse(assay.artifactRetentionAuthorized)

        let receipt = authority.receipt
        XCTAssertEqual(
            receipt.linePrefix,
            "PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_RECEIPT_V1=")
        XCTAssertEqual(
            receipt.terminalGreenStatuses,
            ["MEASURED_EXACT_MISMATCH", "PASS_CLEARANCE"])
        XCTAssertTrue(receipt.canonicalSortedJSONRequired)
        XCTAssertTrue(receipt.withoutEscapingSlashesRequired)
        XCTAssertTrue(receipt.encodeDecodeReencodeIdentityRequired)
        XCTAssertTrue(receipt.exactlyOneTerminalReceiptLineRequired)
        XCTAssertTrue(receipt.emittedWhileLeaseHeld)
        XCTAssertTrue(receipt.flushBeforeLeaseReleaseRequired)
        XCTAssertTrue(receipt.passRequiresAllArmBExactComparisons)
        XCTAssertTrue(receipt.passRequiresAllForwardEquivalenceChecks)
        XCTAssertFalse(receipt.armAOutcomeCanChangeTerminalStatus)
        XCTAssertTrue(receipt.measuredMismatchIsGreenMeasuredOutcome)
        XCTAssertTrue(receipt.runtimeAuthorityCanonicalSHA256ResolvesTo64LowerHex)
        XCTAssertFalse(receipt.runtimeAuthorityCanonicalSHA256MayEqualSymbolLiteral)
        XCTAssertTrue(receipt.passFirstMismatchMustBeNull)
        XCTAssertTrue(receipt.measuredMismatchFirstMismatchMustBeNonNull)
        XCTAssertTrue(
            receipt.measuredMismatchRequiresAtLeastOneGatingComparisonFalse)
        XCTAssertTrue(receipt.firstMismatchCanIdentifyForwardBoundary)
        XCTAssertFalse(receipt.armAMismatchMayPopulateBFirstMismatch)
        XCTAssertEqual(receipt.requiredBSelectorIDCount, 9)
        XCTAssertEqual(
            receipt.requiredBSelectorIDValue,
            "flattened_dense_one_hot_matmul_input_embedding_v1")
        XCTAssertEqual(receipt.expectedArmASourceStepCount, 6)
        XCTAssertEqual(receipt.expectedArmBTrainingStepCount, 15)
        XCTAssertEqual(receipt.expectedArmBSnapshotCount, 3)
        XCTAssertEqual(receipt.expectedArmBRestoreCount, 3)
        XCTAssertEqual(receipt.expectedArmBEvaluateCount, 18)
        XCTAssertEqual(receipt.expectedArmBForwardEquivalenceCheckCount, 9)
        XCTAssertEqual(receipt.expectedArmBDenseWholeLogitsCallCount, 57)
        XCTAssertEqual(receipt.expectedArmBInputEmbeddingPairSeamCount, 9)
        XCTAssertEqual(receipt.expectedArmBDenseEmbeddingConstructionCount, 66)
        XCTAssertEqual(receipt.expectedArmBTokenBoundsValidationCount, 66)
        XCTAssertEqual(receipt.expectedArmBTokenBoundsCheckedEvalCount, 66)
        XCTAssertEqual(
            receipt.expectedArmBTokenBoundsGPUSynchronizeCount, 66)
        XCTAssertEqual(receipt.expectedArmBTokenBoundsHostBoolItemCount, 66)
        XCTAssertTrue(
            receipt.requiredOperationCountKeys.contains(
                "arm_b_dense_embedding_construction_count"))
        XCTAssertTrue(
            receipt.requiredOperationCountKeys.contains(
                "arm_b_dense_whole_logits_call_count"))
        XCTAssertTrue(
            receipt.requiredOperationCountKeys.contains(
                "arm_b_input_embedding_pair_seam_count"))
        XCTAssertTrue(
            receipt.requiredOperationCountKeys.contains(
                "arm_b_token_bounds_checked_eval_count"))
        XCTAssertTrue(
            receipt.requiredOperationCountKeys.contains(
                "arm_b_token_bounds_gpu_synchronize_count"))
        XCTAssertTrue(
            receipt.requiredOperationCountKeys.contains(
                "arm_b_token_bounds_host_bool_item_count"))
        XCTAssertTrue(
            receipt.requiredOperationCountKeys.contains(
                "arm_b_token_bounds_validation_count"))
        XCTAssertTrue(
            receipt.synchronizeCountMustMatchComparedArrayAndForwardCheckPlan)
        XCTAssertEqual(
            receipt.requiredArmBFreshConstructorValue,
            assay.armBFreshConstructor)
        XCTAssertEqual(
            receipt.requiredArmBRestoreConstructorValue,
            assay.armBRestoreConstructor)
        XCTAssertTrue(
            receipt.requiredArmBOutcomeKeys.contains("fresh_constructor"))
        XCTAssertTrue(
            receipt.requiredArmBOutcomeKeys.contains("restore_constructor"))
        XCTAssertEqual(
            receipt.alwaysTrueResourceGuardCeilingKeys,
            [
                "b_specific_native300_resource_witness_requires_separate_authority",
                "stage6_resource_clearance_remains_historical",
                "stage7_requires_new_b_specific_native300_resource_witness",
                "stage7_requires_separate_authority_after_witness",
            ])
        XCTAssertFalse(receipt.invalidInfrastructureEmitsTerminalResult)
        XCTAssertTrue(receipt.invalidInfrastructureExitsNonzero)
        XCTAssertEqual(receipt.artifactUploadCount, 0)
        XCTAssertEqual(receipt.rerunCount, 0)
        XCTAssertEqual(receipt.retryCount, 0)

        let closure = authority.authorityClosureScope
        XCTAssertEqual(closure.exactChangedPaths.count, 5)
        XCTAssertEqual(closure.expectedRootTestCount, 57)
        XCTAssertEqual(closure.expectedFocusedWholeTestCount, 63)
        XCTAssertEqual(closure.expectedTotalTestCount, 109)
        XCTAssertEqual(
            closure.exactLiveOrder,
            ["metal", "maintained_runtime", "tokenizer"])
        XCTAssertEqual(closure.originalStage5LauncherInvocationCount, 0)
        XCTAssertEqual(closure.replacementStage5LauncherInvocationCount, 0)
        XCTAssertEqual(closure.stage6LauncherInvocationCount, 0)
        XCTAssertTrue(closure.authorityOnlyNoMetalOrMLX)

        let successor = authority.successorScope
        XCTAssertEqual(successor.exactChangedPaths.count, 10)
        XCTAssertEqual(
            successor.newLauncherPath,
            ".github/scripts/prime-ci-native-decoder-stage5-repeated-trajectory-replacement.sh")
        XCTAssertEqual(
            successor.newCurrentDecoderIdentityObservationSourcePath,
            "Sources/PrimeCore/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservation.swift")
        XCTAssertEqual(
            successor.newCurrentDecoderIdentityObservationTestPath,
            "Tests/PrimeCoreTests/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationTests.swift")
        XCTAssertEqual(
            successor.newAssayTestPath,
            "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests.swift")
        XCTAssertEqual(successor.expectedRootTestCount, 58)
        XCTAssertEqual(successor.expectedFocusedWholeTestCount, 64)
        XCTAssertEqual(successor.expectedPreReplacementTestCount, 110)
        XCTAssertEqual(successor.expectedReplacementTestCount, 1)
        XCTAssertEqual(successor.expectedTotalTestCount, 111)
        XCTAssertEqual(successor.replacementLauncherInvocationCount, 1)
        XCTAssertEqual(successor.replacementBuildCount, 1)
        XCTAssertEqual(successor.replacementDirectXCTestCount, 1)
        XCTAssertEqual(successor.replacementReceiptCount, 1)
        XCTAssertEqual(successor.originalLauncherInvocationCount, 0)
        XCTAssertEqual(successor.stage6LauncherInvocationCount, 0)
        XCTAssertEqual(successor.exactMainExecutionOpportunityCount, 1)
        XCTAssertFalse(successor.manifestMutationAuthorized)
        XCTAssertFalse(successor.packageLockMutationAuthorized)
        XCTAssertFalse(successor.originalStage5LauncherMutationAuthorized)
        XCTAssertFalse(successor.defaultGatherPathMutationAuthorized)
        XCTAssertTrue(successor.decoderSourceMutationAuthorized)
        XCTAssertTrue(successor.trainingSourceMutationAuthorized)
        XCTAssertFalse(successor.otherProductionSourceMutationAuthorized)
        XCTAssertTrue(successor.newPackageOnlyOptInPathAuthorized)
        XCTAssertTrue(successor.retainedAuthorityTestMutationAuthorized)
        XCTAssertEqual(successor.retainedAuthorityTestMethodCount, 11)
        XCTAssertEqual(successor.retainedGitBlobOIDOccurrenceCount, 2)
        XCTAssertEqual(successor.retainedCryptoKitSHA1FramingOccurrenceCount, 1)
        XCTAssertTrue(
            successor.retainedAllOtherAssertionsByteSemanticallyPreserved)
        XCTAssertTrue(successor.newCurrentIdentityObservationAuthorized)

        let transition = authority.outcomeTransitions
        XCTAssertTrue(transition.passClearanceEstablishesStage5Result)
        XCTAssertTrue(transition.passClearanceEstablishesStage5MechanicsSuccess)
        XCTAssertTrue(transition.passClearanceEstablishesStage5AssayClearance)
        XCTAssertTrue(
            transition.passClearanceEstablishesRepeatedSameDeviceBPathDeterminism)
        XCTAssertTrue(
            transition.passClearanceEstablishesExactSameDeviceBPathGradientBytes)
        XCTAssertFalse(transition.passClearanceEstablishesDefaultGatherDeterminism)
        XCTAssertFalse(transition.passClearanceEstablishesArbitraryTokenDeterminism)
        XCTAssertFalse(transition.passClearanceEstablishesCrossDeviceDeterminism)
        XCTAssertTrue(transition.measuredMismatchEstablishesStage5Result)
        XCTAssertTrue(transition.measuredMismatchEstablishesStage5MechanicsSuccess)
        XCTAssertFalse(transition.measuredMismatchEstablishesStage5Clearance)
        XCTAssertFalse(transition.measuredMismatchPermitsRerun)
        XCTAssertTrue(transition.eitherGreenOutcomeConsumesOneShot)
        XCTAssertTrue(transition.invalidInfrastructureConsumesExactMainOpportunity)
        XCTAssertFalse(transition.invalidInfrastructureEstablishesStage5Result)
        XCTAssertFalse(transition.stage7AuthorizedByPassClearance)
        XCTAssertTrue(
            transition.stage7RequiresNewBSpecificNative300ResourceWitness)
        XCTAssertTrue(transition.stage7RequiresSeparateAuthorityAfterWitness)

        let ceiling = authority.authorityCeiling
        XCTAssertTrue(
            ceiling.replacementMechanicsImplementationAuthorizedAfterGreenClosure)
        XCTAssertTrue(
            ceiling.oneExactMainReplacementExecutionAuthorizedAfterGreenClosure)
        XCTAssertTrue(ceiling.stage6ResourceClearanceRemainsHistorical)
        XCTAssertFalse(
            ceiling.stage6HistoricalResourceClearanceAppliesToBPath)
        XCTAssertFalse(ceiling.bSpecificNative300ResourceWitnessAuthorized)
        XCTAssertTrue(
            ceiling.bSpecificNative300ResourceWitnessRequiresSeparateAuthority)
        XCTAssertTrue(falseCeilings(authority).allSatisfy { !$0 })

        requireSendable(Authority.self)
        let canonical = try authority.canonicalData()
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Authority.canonicalSHA256)
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let arrayPaths = allArrayPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 250)
        XCTAssertGreaterThan(dictionaryPaths.count, 15)
        XCTAssertGreaterThan(arrayPaths.count, 20)
        XCTAssertGreaterThan(scalarPaths.count, 175)

        var regularDecodedDriftCount = 0
        for path in valuePaths {
            let mutatedData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue),
                label: "mutated \(pathLabel(path))")
            if let loose = try? JSONDecoder().decode(
                Authority.self,
                from: mutatedData), loose != authority
            {
                regularDecodedDriftCount += 1
                XCTAssertThrowsError(try loose.validateExactV1())
            }
            _ = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: { _ in NSNull() }),
                label: "null \(pathLabel(path))")
            _ = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))")
        }
        XCTAssertGreaterThan(regularDecodedDriftCount, 175)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(in: object, at: path) { value in
                var dictionary = value as! [String: Any]
                dictionary["unknown_stage5_replacement_field_\(index)"] = true
                return dictionary
            }
            let unknownData = try assertCanonicalRejects(
                unknown,
                label: "unknown \(pathLabel(path))")
            let loose = try JSONDecoder().decode(
                Authority.self,
                from: unknownData)
            XCTAssertEqual(loose, authority)
        }

        var reorderedArrayCount = 0
        for path in arrayPaths {
            var didReorder = false
            let reordered = replacingValue(in: object, at: path) { value in
                var array = value as! [Any]
                guard array.count >= 2 else { return array }
                for left in 0 ..< array.count {
                    for right in (left + 1) ..< array.count {
                        if canonicalJSONFragment(array[left])
                            != canonicalJSONFragment(array[right])
                        {
                            array.swapAt(left, right)
                            didReorder = true
                            return array
                        }
                    }
                }
                return array
            }
            if didReorder {
                _ = try assertCanonicalRejects(
                    reordered,
                    label: "reordered \(pathLabel(path))")
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 10)
        try assertNoncanonicalEncodingsReject(canonical, object: object)

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthority.swift")
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        XCTAssertFalse(
            sourceText.contains(
                "__PRIME_STAGE5_REPLACEMENT_AUTHORITY_CANONICAL_SHA256__"))
        XCTAssertEqual(
            sourceText.split(separator: "\n").filter {
                $0.hasPrefix("import ")
            }.map(String.init),
            ["import Foundation"])
        for forbidden in [
            "import CoreGraphics", "import Darwin", "import Metal",
            "import MLX", "import MLXNN", "import MLXOptimizers",
            "FileManager.", "FileHandle.", "URLSession", "Process(",
            "posix_spawn", "execve(", "Memory.snapshot(",
        ] {
            XCTAssertFalse(sourceText.contains(forbidden), forbidden)
        }
        let testText = try String(contentsOfFile: #filePath, encoding: .utf8)
        XCTAssertEqual(
            testText.components(separatedBy: "func " + "test").count - 1,
            1)
    }

    private func falseCeilings(_ authority: Authority) -> [Bool] {
        let ceiling = authority.authorityCeiling
        return [
            ceiling.authorityClosureExecutedReplacement,
            ceiling.authorityClosureObservedMLX,
            ceiling.authorityClosureEstablishedStage5Result,
            ceiling.authorityClosureEstablishedStage5Clearance,
            ceiling.authorityClosureEstablishedRepeatedTrajectoryDeterminism,
            ceiling.authorityClosureEstablishedExactMetalGradientBytes,
            ceiling.defaultGatherDeterminismEstablished,
            ceiling.arbitraryTokenDeterminismEstablished,
            ceiling.crossDeviceDeterminismEstablished,
            ceiling.originalFailedRunReinterpreted,
            ceiling.originalLauncherRecoveryAuthorized,
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.broadNative300TrainingAuthorized,
            ceiling.stage6HistoricalResourceClearanceAppliesToBPath,
            ceiling.bSpecificNative300ResourceWitnessEstablished,
            ceiling.stage7AuthorityEstablished,
            ceiling.stage7Authorized,
            ceiling.candidateAdmissionGranted,
            ceiling.modelQualityEstablished,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)
    }

    private typealias JSONPath = [JSONPathComponent]

    private func pathLabel(_ path: JSONPath) -> String {
        path.isEmpty ? "<root>" : path.map { component in
            switch component {
            case let .key(key): return key
            case let .index(index): return "[\(index)]"
            }
        }.joined(separator: ".")
    }

    private func allValuePaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix + [.key(key)]
                return [path] + allValuePaths(in: object[key]!, prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path] + allValuePaths(in: array[index], prefix: path)
            }
        }
        return []
    }

    private func allDictionaryPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return [prefix] + object.keys.sorted().flatMap { key in
                allDictionaryPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func allArrayPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allArrayPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func allScalarPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allScalarPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allScalarPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
            }
        }
        return [prefix]
    }

    private func replacingValue(
        in value: Any,
        at path: JSONPath,
        with transform: (Any) -> Any
    ) -> Any {
        guard let component = path.first else { return transform(value) }
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            object[key] = replacingValue(
                in: object[key]!, at: remainder, with: transform)
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index], at: remainder, with: transform)
            return array
        }
    }

    private func removingValue(in value: Any, at path: JSONPath) -> Any {
        precondition(!path.isEmpty)
        let component = path[0]
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            if remainder.isEmpty {
                object.removeValue(forKey: key)
            } else {
                object[key] = removingValue(in: object[key]!, at: remainder)
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(in: array[index], at: remainder)
            }
            return array
        }
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if let string = value as? String { return string + "__mutation" }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return NSNumber(value: number.int64Value + 1)
        }
        if var array = value as? [Any] {
            array.append(array.first ?? "__mutation")
            return array
        }
        if var object = value as? [String: Any] {
            object["unknown_recursive_mutation"] = true
            return object
        }
        XCTFail("unsupported canonical JSON value")
        return value
    }

    private func canonicalJSONFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes])) ?? Data()
    }

    @discardableResult
    private func assertCanonicalRejects(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Data {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(
            try Authority.decodeCanonical(data),
            label,
            file: file,
            line: line)
        return data
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(canonical + Data([0x0a])))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(slashEscaped.utf8)))

        var reordered = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let openingBrace = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(
            contentsOf: schemaField,
            at: reordered.index(after: openingBrace))
        let reorderedData = Data(reordered.utf8)
        XCTAssertNotEqual(reorderedData, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicate.startIndex))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(duplicate.utf8)))
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
