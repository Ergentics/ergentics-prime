import Foundation
import XCTest
@testable import PrimeCore
#if canImport(Darwin)
    import Darwin
    import MachO
#endif

final class PrimeNative3BMetalContinuationContractTests:
    XCTestCase
{
    #if os(macOS)
        func testLoadedMainExecutableVnodeMatchesHeldExecutable()
            throws
        {
            var requiredSize: UInt32 = 0
            _ = _NSGetExecutablePath(
                nil,
                &requiredSize
            )
            XCTAssertGreaterThan(requiredSize, 1)
            var path = [CChar](
                repeating: 0,
                count: Int(requiredSize)
            )
            XCTAssertEqual(
                _NSGetExecutablePath(
                    &path,
                    &requiredSize
                ),
                0
            )
            let descriptor = open(
                String(cString: path),
                O_RDONLY | O_CLOEXEC
            )
            XCTAssertGreaterThanOrEqual(
                descriptor,
                0
            )
            defer {
                if descriptor >= 0 {
                    _ = close(descriptor)
                }
            }
            var metadata = stat()
            XCTAssertEqual(
                fstat(descriptor, &metadata),
                0
            )

            let observed =
                try PrimeNative3BLoadedExecutableVnode
                    .observeCurrentProcess()
            try observed.requireMatches(
                deviceID:
                    UInt64(
                        bitPattern:
                            Int64(metadata.st_dev)
                    ),
                inode: UInt64(metadata.st_ino)
            )
            XCTAssertThrowsError(
                try observed.requireMatches(
                    deviceID: observed.deviceID,
                    inode: observed.inode + 1
                )
            )
        }
    #endif

    func testExactThreeProcessReceiptValidatesAndRoundTrips()
        throws
    {
        try requireResolvedDependencyPins()
        let receipt = try makeReceipt()
        try receipt.validateStructure()

        let data = try PrimeCanonicalJSON.encode(receipt)
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                PrimeNative3BMetalContinuationReceipt
                    .self,
                from: data
            ),
            receipt
        )
        XCTAssertEqual(receipt.outcome, .pass)
        XCTAssertTrue(
            try XCTUnwrap(
                receipt.preSaveComparison.value
            ).exact
        )
        XCTAssertTrue(
            try XCTUnwrap(
                receipt.restoredAtNComparison.value
            ).exact
        )
        XCTAssertTrue(
            try XCTUnwrap(
                receipt.continuedAtNPlus1Comparison
                    .value
            ).exact
        )
    }

    func testReconcilerReportsFirstExactLogicalMismatch()
        throws
    {
        let expected = try witness(
            step: 2,
            stateToken: "step-2"
        )
        let changed = try witness(
            step: 2,
            stateToken: "changed-step-2"
        )
        let result =
            PrimeNative3BContinuationReconciler
                .compare(
                    expected: expected,
                    observed: changed
                )

        XCTAssertFalse(result.exact)
        XCTAssertEqual(
            result.firstMismatch,
            "clipped_gradient.entries[0].sha256"
        )
        try result.validate()
    }

    func testRestoredStateDoesNotClaimStepOneLossOrGradientReplay()
        throws
    {
        let writer = try witness(
            step: 1,
            stateToken: "step-1"
        )
        let restored =
            try restoredState(from: writer)
        let encoded =
            try PrimeCanonicalJSON.encode(restored)
        let json = try XCTUnwrap(
            String(data: encoded, encoding: .utf8)
        )
        XCTAssertFalse(json.contains("lossBitPattern"))
        XCTAssertFalse(
            json.contains("rawGradientNormBitPattern")
        )
        XCTAssertFalse(
            json.contains("clippedGradient")
        )
        XCTAssertTrue(
            PrimeNative3BContinuationReconciler
                .compareRestoredState(
                    expected: writer,
                    observed: restored
                )
                .exact
        )
    }

    func testPassCannotTrustSpoofedExactBooleans()
        throws
    {
        try requireResolvedDependencyPins()
        let changed = try witness(
            step: 2,
            stateToken: "changed-step-2"
        )
        let receipt = try makeReceipt(
            restorerStepTwo: changed,
            outcome: .pass,
            useComputedComparisons: false
        )

        XCTAssertThrowsError(
            try receipt.validateStructure()
        )
    }

    func testDivergenceProducesValidatedAbstain()
        throws
    {
        try requireResolvedDependencyPins()
        let changed = try witness(
            step: 2,
            stateToken: "changed-step-2"
        )
        let receipt = try makeReceipt(
            restorerStepTwo: changed,
            outcome: .abstain
        )

        try receipt.validateStructure()
        XCTAssertFalse(
            try XCTUnwrap(
                receipt.continuedAtNPlus1Comparison
                    .value
            ).exact
        )
        XCTAssertNotNil(
            receipt.continuedAtNPlus1Comparison
                .value?
                .firstMismatch
        )
    }

    func testPreSaveDivergenceSuppressesCheckpointAndRestorer()
        throws
    {
        try requireResolvedDependencyPins()
        let receipt = try makePreSaveAbstain()
        try receipt.validateStructure()

        XCTAssertEqual(receipt.outcome, .abstain)
        XCTAssertEqual(receipt.workers.count, 2)
        XCTAssertFalse(
            receipt.restorerRecord.observationAvailable
        )
        XCTAssertFalse(
            receipt.restoredAtNComparison
                .observationAvailable
        )
        XCTAssertFalse(
            receipt.continuedAtNPlus1Comparison
                .observationAvailable
        )
        XCTAssertFalse(
            try XCTUnwrap(
                receipt.preSaveComparison.value
            ).exact
        )
    }

    func testWorkersMustHaveDistinctPositivePIDs()
        throws
    {
        try requireResolvedDependencyPins()
        let receipt = try makeReceipt(
            restorerPID: 12
        )
        XCTAssertThrowsError(
            try receipt.validateStructure()
        )
    }

    func testReceiptRejectsSupervisorPIDMismatch()
        throws
    {
        try requireResolvedDependencyPins()
        let receipt = try makeReceipt(
            supervisorRestorerPID: 99
        )
        XCTAssertThrowsError(
            try receipt.validateStructure()
        )
    }

    func testRestorerRequiresDistinctPoisonModel()
        throws
    {
        try requireResolvedDependencyPins()
        let seeds =
            try PrimeNative3BMetalContinuationContract
                .frozenSeeds()
        let stepOne = try witness(
            step: 1,
            stateToken: "step-1"
        )
        let stepTwo = try witness(
            step: 2,
            stateToken: "step-2"
        )
        let checkpoint = try checkpoint(
            seeds: seeds,
            stepOne: stepOne
        )
        let initial = try fullCatalog(
            label:
                PrimeNative3BContinuationCatalogLabel
                    .initialModel,
            token: "initial"
        )
        let restorer =
            PrimeNative3BMetalContinuationWorkerRecord(
                role: .restorer,
                processIdentifier: 13,
                executable: executable(),
                runtimeImage: runtimeImage(),
                sourceSnapshot: artifact(
                    "evidence/current-source.json",
                    token: "current-source"
                ),
                priorEvidence: priorEvidence(),
                continuationDependencyEvidence:
                    dependencyEvidence(),
                seeds: seeds,
                initialModel: initial,
                checkpointManifest: checkpoint,
                writerRecord: artifact(
                    "records/writer.json",
                    token: "writer-record"
                ),
                restoredStateWitness:
                    try restoredState(
                        from: stepOne
                    ),
                witnesses: [stepTwo]
            )

        XCTAssertThrowsError(try restorer.validate())
    }

    func testCatalogRejectsForgedAggregate()
        throws
    {
        let valid = try fullCatalog(
            label:
                PrimeNative3BContinuationCatalogLabel
                    .model,
            token: "model"
        )
        let forged =
            PrimeNative3BContinuationTensorCatalog(
                label: valid.label,
                entries: valid.entries,
                aggregateSHA256:
                    String(repeating: "0", count: 64)
            )

        XCTAssertThrowsError(
            try forged.validate(
                expectedLabel:
                    PrimeNative3BContinuationCatalogLabel
                        .model,
                expectedLogicalByteCount:
                    PrimeNative3BMetalContinuationContract
                        .fullStateLogicalByteCount
            )
        )
    }

    func testFrozenLlamaTopologyMatchesExactProfile()
        throws
    {
        let topology =
            PrimeNative3BMetalContinuationContract
                .fullStateTopology
        XCTAssertEqual(
            topology.count,
            2
                + 9
                * PrimeNativeProfiles.exact3B
                    .layerCount
        )
        XCTAssertEqual(
            topology.map(\.path),
            topology.map(\.path).sorted()
        )
        XCTAssertEqual(
            topology.reduce(UInt64(0)) {
                $0 + $1.byteCount
            },
            PrimeNative3BMetalContinuationContract
                .fullStateLogicalByteCount
        )
        XCTAssertEqual(
            topology.first?.path,
            "model.embed_tokens.weight"
        )
        XCTAssertEqual(
            topology.last?.path,
            "model.norm.weight"
        )
        XCTAssertTrue(
            topology.contains(where: {
                $0.path
                    == "model.layers.27.self_attn.v_proj.weight"
                    && $0.shape
                        == [
                            1_024,
                            3_072,
                        ]
            })
        )
    }

    func testTrainingScheduleIsSeedBoundAndCollisionFree()
        throws
    {
        XCTAssertEqual(
            PrimeNative3BMetalContinuationContract
                .trainingInputContract,
            "seed_bound_collision_free_128_of_256_odd_stride_modular_schedule"
        )
        let seeds =
            try PrimeNative3BMetalContinuationContract
            .frozenSeeds()
        let schedules = try (0 ..< 3).map {
            try PrimeNative3BMetalContinuationContract
                .collisionFreeTrainingTokens(
                    seed:
                        seeds.trainingSchedule.value,
                    ordinal: $0
                )
        }
        for tokens in schedules {
            XCTAssertEqual(
                tokens.count,
                PrimeNative3BMetalContinuationContract
                    .fixedEvaluationSequenceLength
            )
            XCTAssertEqual(
                Set(tokens).count,
                tokens.count
            )
            XCTAssertTrue(
                tokens.allSatisfy {
                    $0 >= 256 && $0 < 512
                }
            )
        }
        XCTAssertEqual(
            schedules,
            try (0 ..< 3).map {
                try PrimeNative3BMetalContinuationContract
                    .collisionFreeTrainingTokens(
                        seed:
                            seeds.trainingSchedule.value,
                        ordinal: $0
                    )
            }
        )
        XCTAssertEqual(
            Set(schedules).count,
            3
        )
        XCTAssertNotEqual(
            schedules,
            try (0 ..< 3).map {
                try PrimeNative3BMetalContinuationContract
                    .collisionFreeTrainingTokens(
                        seed:
                            seeds.trainingSchedule.value
                                + 1,
                        ordinal: $0
                    )
            }
        )
        XCTAssertThrowsError(
            try PrimeNative3BMetalContinuationContract
                .collisionFreeTrainingTokens(
                    seed:
                        seeds.trainingSchedule.value,
                    ordinal: -1
                )
        )
        XCTAssertThrowsError(
            try PrimeNative3BMetalContinuationContract
                .collisionFreeTrainingTokens(
                    seed:
                        seeds.trainingSchedule.value,
                    ordinal: 3
                )
        )
    }

    func testStepWitnessRejectsSyntheticFullStateTopology()
        throws
    {
        let valid = try witness(
            step: 1,
            stateToken: "step-1"
        )
        let synthetic = try monolithicFullCatalog(
            label:
                PrimeNative3BContinuationCatalogLabel
                    .model,
            token: "synthetic-model"
        )
        let changed =
            PrimeNative3BContinuationStepWitness(
                step: valid.step,
                inputSHA256: valid.inputSHA256,
                lossBitPattern: valid.lossBitPattern,
                rawGradientNormBitPattern:
                    valid.rawGradientNormBitPattern,
                clippedGradientNormBitPattern:
                    valid
                    .clippedGradientNormBitPattern,
                clippedGradient:
                    valid.clippedGradient,
                model: synthetic,
                firstMoment: valid.firstMoment,
                secondMoment: valid.secondMoment,
                fixedLogits: valid.fixedLogits,
                cursor: valid.cursor,
                nextInputSHA256:
                    valid.nextInputSHA256
            )

        XCTAssertThrowsError(try changed.validate())
    }

    func testStepWitnessRejectsWrongFixedLogitShapeAtSameByteCount()
        throws
    {
        let valid = try witness(
            step: 1,
            stateToken: "step-1"
        )
        let topology =
            try XCTUnwrap(
                PrimeNative3BMetalContinuationContract
                    .fixedLogitsTopology.first
            )
        let wrongShape = [
            1,
            64,
            2
                * PrimeNativeProfiles.exact3B
                    .vocabularySize,
        ]
        let wrongLogits =
            try PrimeNative3BContinuationTensorCatalog(
                label:
                    PrimeNative3BContinuationCatalogLabel
                    .fixedLogits,
                entries: [
                    PrimeNative3BContinuationTensorEntry(
                        path: topology.path,
                        shape: wrongShape,
                        dtype: topology.dtype,
                        byteCount: topology.byteCount,
                        sha256: hash(
                            "wrong-logit-shape"
                        ),
                        finite: true,
                        nonzero: true
                    ),
                ]
            )
        let changed =
            PrimeNative3BContinuationStepWitness(
                step: valid.step,
                inputSHA256: valid.inputSHA256,
                lossBitPattern: valid.lossBitPattern,
                rawGradientNormBitPattern:
                    valid.rawGradientNormBitPattern,
                clippedGradientNormBitPattern:
                    valid
                    .clippedGradientNormBitPattern,
                clippedGradient:
                    valid.clippedGradient,
                model: valid.model,
                firstMoment: valid.firstMoment,
                secondMoment: valid.secondMoment,
                fixedLogits: wrongLogits,
                cursor: valid.cursor,
                nextInputSHA256:
                    valid.nextInputSHA256
            )

        XCTAssertThrowsError(try changed.validate())
    }

    func testCheckpointRejectsOneByteStateArtifact()
        throws
    {
        let seeds =
            try PrimeNative3BMetalContinuationContract
                .frozenSeeds()
        let stepOne = try witness(
            step: 1,
            stateToken: "step-1"
        )
        let valid = try checkpoint(
            seeds: seeds,
            stepOne: stepOne
        )
        let undersized =
            PrimeNative3BContinuationCheckpointManifest(
                seeds: seeds,
                model: artifact(
                    "undersized-model.safetensors",
                    token: "undersized-model"
                ),
                firstMoment: valid.firstMoment,
                secondMoment: valid.secondMoment,
                stepOneWitness: stepOne
            )

        XCTAssertThrowsError(
            try undersized.validate()
        )
    }

    func testCheckpointRejectsComponentAboveSharedCap()
        throws
    {
        let seeds =
            try PrimeNative3BMetalContinuationContract
                .frozenSeeds()
        let stepOne = try witness(
            step: 1,
            stateToken: "step-1"
        )
        let valid = try checkpoint(
            seeds: seeds,
            stepOne: stepOne
        )
        let oversized =
            PrimeNative3BContinuationCheckpointManifest(
                seeds: seeds,
                model: artifact(
                    "oversized-model.safetensors",
                    token: "oversized-model",
                    byteCount:
                        PrimeNative3BMetalContinuationContract
                        .checkpointComponentMaximumByteCount
                        + 1
                ),
                firstMoment: valid.firstMoment,
                secondMoment: valid.secondMoment,
                stepOneWitness: stepOne
            )

        XCTAssertThrowsError(
            try oversized.validate()
        )
    }

    func testDependencyPlanValidatesOnlyWhenPinsAreFinalized()
        throws
    {
        let plan =
            PrimeNative3BContinuationDependencyPlan
                .frozenV1
        XCTAssertEqual(
            plan.ioSourcePath,
            "Source/MLX/FileDescriptorIO.swift"
        )
        if dependencyPinsPending(plan) {
            XCTAssertThrowsError(try plan.validate())
        } else {
            XCTAssertNoThrow(try plan.validate())
        }
    }

    private func makeReceipt(
        restorerStepTwo:
            PrimeNative3BContinuationStepWitness? = nil,
        restorerPID: Int32 = 13,
        supervisorRestorerPID: Int32? = nil,
        outcome:
            PrimeNative3BMetalContinuationOutcome = .pass,
        useComputedComparisons: Bool = true
    ) throws -> PrimeNative3BMetalContinuationReceipt {
        let seeds =
            try PrimeNative3BMetalContinuationContract
                .frozenSeeds()
        let stepOne = try witness(
            step: 1,
            stateToken: "step-1"
        )
        let controlStepTwo = try witness(
            step: 2,
            stateToken: "step-2"
        )
        let restoredStepTwo =
            restorerStepTwo ?? controlStepTwo
        let checkpoint = try checkpoint(
            seeds: seeds,
            stepOne: stepOne
        )
        let initial = try fullCatalog(
            label:
                PrimeNative3BContinuationCatalogLabel
                    .initialModel,
            token: "initial"
        )
        let poison = try fullCatalog(
            label:
                PrimeNative3BContinuationCatalogLabel
                    .poisonModel,
            token: "poison"
        )
        let executable = executable()
        let runtime = runtimeImage()
        let source = artifact(
            "evidence/current-source.json",
            token: "current-source"
        )
        let prior = priorEvidence()
        let writerRecord = artifact(
            "records/writer.json",
            token: "writer-record"
        )
        let controlRecord = artifact(
            "records/control.json",
            token: "control-record"
        )
        let restorerRecord = artifact(
            "records/restorer.json",
            token: "restorer-record"
        )
        let workers = [
            PrimeNative3BMetalContinuationWorkerRecord(
                role: .control,
                processIdentifier: 11,
                executable: executable,
                runtimeImage: runtime,
                sourceSnapshot: source,
                priorEvidence: prior,
                continuationDependencyEvidence:
                    dependencyEvidence(),
                seeds: seeds,
                initialModel: initial,
                witnesses: [
                    stepOne,
                    controlStepTwo,
                ]
            ),
            PrimeNative3BMetalContinuationWorkerRecord(
                role: .writer,
                processIdentifier: 12,
                executable: executable,
                runtimeImage: runtime,
                sourceSnapshot: source,
                priorEvidence: prior,
                continuationDependencyEvidence:
                    dependencyEvidence(),
                seeds: seeds,
                initialModel: initial,
                checkpointManifest: checkpoint,
                witnesses: [stepOne]
            ),
            PrimeNative3BMetalContinuationWorkerRecord(
                role: .restorer,
                processIdentifier: restorerPID,
                executable: executable,
                runtimeImage: runtime,
                sourceSnapshot: source,
                priorEvidence: prior,
                continuationDependencyEvidence:
                    dependencyEvidence(),
                seeds: seeds,
                initialModel: initial,
                poisonModel: poison,
                checkpointManifest: checkpoint,
                writerRecord: writerRecord,
                restoredStateWitness:
                    try restoredState(
                        from: stepOne
                    ),
                witnesses: [restoredStepTwo]
            ),
        ]
        let exact =
            PrimeNative3BContinuationComparisonResult
                .exactMatch
        let continued =
            PrimeNative3BContinuationReconciler
                .compare(
                    expected: controlStepTwo,
                    observed: restoredStepTwo
                )
        return PrimeNative3BMetalContinuationReceipt(
            outcome: outcome,
            recordedAtUTC:
                "2026-07-29T20:00:00Z",
            seeds: seeds,
            controlRecord: controlRecord,
            writerRecord: writerRecord,
            restorerRecord: .observed(
                restorerRecord
            ),
            workers: workers,
            supervisorProcesses: [
                processObservation(
                    role: .control,
                    processIdentifier: 11,
                    workerRecord: controlRecord
                ),
                processObservation(
                    role: .writer,
                    processIdentifier: 12,
                    workerRecord: writerRecord
                ),
                processObservation(
                    role: .restorer,
                    processIdentifier:
                        supervisorRestorerPID
                        ?? restorerPID,
                    workerRecord: restorerRecord
                ),
            ],
            preSaveComparison: .observed(exact),
            restoredAtNComparison:
                .observed(exact),
            continuedAtNPlus1Comparison:
                .observed(
                    useComputedComparisons
                        ? continued
                        : exact
                )
        )
    }

    private func makePreSaveAbstain()
        throws -> PrimeNative3BMetalContinuationReceipt
    {
        let seeds =
            try PrimeNative3BMetalContinuationContract
                .frozenSeeds()
        let controlN = try witness(
            step: 1,
            stateToken: "step-1"
        )
        let writerN = try witness(
            step: 1,
            stateToken: "divergent-step-1"
        )
        let controlNPlusOne = try witness(
            step: 2,
            stateToken: "step-2"
        )
        let initial = try fullCatalog(
            label:
                PrimeNative3BContinuationCatalogLabel
                    .initialModel,
            token: "initial"
        )
        let executable = executable()
        let runtime = runtimeImage()
        let source = artifact(
            "evidence/current-source.json",
            token: "current-source"
        )
        let prior = priorEvidence()
        let controlRecord = artifact(
            "records/control.json",
            token: "control-record"
        )
        let writerRecord = artifact(
            "records/writer.json",
            token: "writer-record"
        )
        let workers = [
            PrimeNative3BMetalContinuationWorkerRecord(
                role: .control,
                processIdentifier: 11,
                executable: executable,
                runtimeImage: runtime,
                sourceSnapshot: source,
                priorEvidence: prior,
                continuationDependencyEvidence:
                    dependencyEvidence(),
                seeds: seeds,
                initialModel: initial,
                witnesses: [
                    controlN,
                    controlNPlusOne,
                ]
            ),
            PrimeNative3BMetalContinuationWorkerRecord(
                role: .writer,
                processIdentifier: 12,
                executable: executable,
                runtimeImage: runtime,
                sourceSnapshot: source,
                priorEvidence: prior,
                continuationDependencyEvidence:
                    dependencyEvidence(),
                seeds: seeds,
                initialModel: initial,
                witnesses: [writerN]
            ),
        ]
        let comparison =
            PrimeNative3BContinuationReconciler
                .compare(
                    expected: controlN,
                    observed: writerN
                )
        return PrimeNative3BMetalContinuationReceipt(
            outcome: .abstain,
            recordedAtUTC:
                "2026-07-29T20:00:00Z",
            seeds: seeds,
            controlRecord: controlRecord,
            writerRecord: writerRecord,
            restorerRecord: .unavailable,
            workers: workers,
            supervisorProcesses: [
                processObservation(
                    role: .control,
                    processIdentifier: 11,
                    workerRecord: controlRecord
                ),
                processObservation(
                    role: .writer,
                    processIdentifier: 12,
                    workerRecord: writerRecord
                ),
            ],
            preSaveComparison:
                .observed(comparison),
            restoredAtNComparison: .unavailable,
            continuedAtNPlus1Comparison:
                .unavailable
        )
    }

    private func restoredState(
        from source:
            PrimeNative3BContinuationStepWitness
    ) throws
        -> PrimeNative3BContinuationRestoredStateWitness
    {
        PrimeNative3BContinuationRestoredStateWitness(
            restoredAfterStep: source.step,
            checkpointStepWitnessSHA256:
                PrimeSHA256.hexDigest(
                    of: try PrimeCanonicalJSON.encode(
                        source
                    )
                ),
            carriedForwardInputSHA256:
                source.inputSHA256,
            carriedForwardCursor: source.cursor,
            carriedForwardNextInputSHA256:
                source.nextInputSHA256,
            model: source.model,
            firstMoment: source.firstMoment,
            secondMoment: source.secondMoment,
            fixedLogits: source.fixedLogits
        )
    }

    private func processObservation(
        role:
            PrimeNative3BMetalContinuationWorkerRole,
        processIdentifier: Int32,
        workerRecord: PrimeArtifactBinding
    ) -> PrimeNative3BSupervisorProcessObservation {
        PrimeNative3BSupervisorProcessObservation(
            role: role,
            processIdentifier: processIdentifier,
            terminationReason: .exit,
            terminationStatus: 0,
            outputByteCount: 0,
            outputSHA256: hash(""),
            outputOverflowed: false,
            outputDrainCompleted: true,
            workerRecord: workerRecord
        )
    }

    private func witness(
        step: Int,
        stateToken: String
    ) throws -> PrimeNative3BContinuationStepWitness {
        let inputToken =
            step == 1 ? "input-1" : "input-2"
        let nextToken =
            step == 1 ? "input-2" : "input-3"
        return PrimeNative3BContinuationStepWitness(
            step: step,
            inputSHA256: hash(inputToken),
            lossBitPattern:
                (Float(step) + 0.25).bitPattern,
            rawGradientNormBitPattern:
                Float(2).bitPattern,
            clippedGradientNormBitPattern:
                Float(1).bitPattern,
            clippedGradient: try fullCatalog(
                label:
                    PrimeNative3BContinuationCatalogLabel
                        .clippedGradient,
                token: "\(stateToken)-gradient"
            ),
            model: try fullCatalog(
                label:
                    PrimeNative3BContinuationCatalogLabel
                        .model,
                token: "\(stateToken)-model"
            ),
            firstMoment: try fullCatalog(
                label:
                    PrimeNative3BContinuationCatalogLabel
                        .firstMoment,
                token: "\(stateToken)-m"
            ),
            secondMoment: try fullCatalog(
                label:
                    PrimeNative3BContinuationCatalogLabel
                        .secondMoment,
                token: "\(stateToken)-v"
            ),
            fixedLogits: try logitsCatalog(
                token: "\(stateToken)-logits"
            ),
            cursor: step,
            nextInputSHA256: hash(nextToken)
        )
    }

    private func fullCatalog(
        label: String,
        token: String
    ) throws -> PrimeNative3BContinuationTensorCatalog {
        try PrimeNative3BContinuationTensorCatalog(
            label: label,
            entries:
                PrimeNative3BMetalContinuationContract
                .fullStateTopology.map {
                PrimeNative3BContinuationTensorEntry(
                    path: $0.path,
                    shape: $0.shape,
                    dtype: $0.dtype,
                    byteCount: $0.byteCount,
                    sha256: hash(
                        "\(token):\($0.path)"
                    ),
                    finite: true,
                    nonzero: true
                )
            }
        )
    }

    private func monolithicFullCatalog(
        label: String,
        token: String
    ) throws -> PrimeNative3BContinuationTensorCatalog {
        try PrimeNative3BContinuationTensorCatalog(
            label: label,
            entries: [
                PrimeNative3BContinuationTensorEntry(
                    path: "model.all_parameters",
                    shape: [
                        Int(
                            PrimeNativeProfiles.exact3B
                                .parameterCount
                        ),
                    ],
                    dtype: "float32",
                    byteCount:
                        PrimeNative3BMetalContinuationContract
                        .fullStateLogicalByteCount,
                    sha256: hash(token),
                    finite: true,
                    nonzero: true
                ),
            ]
        )
    }

    private func logitsCatalog(
        token: String
    ) throws -> PrimeNative3BContinuationTensorCatalog {
        try PrimeNative3BContinuationTensorCatalog(
            label:
                PrimeNative3BContinuationCatalogLabel
                .fixedLogits,
            entries:
                PrimeNative3BMetalContinuationContract
                .fixedLogitsTopology.map {
                PrimeNative3BContinuationTensorEntry(
                    path: $0.path,
                    shape: $0.shape,
                    dtype: $0.dtype,
                    byteCount: $0.byteCount,
                    sha256: hash(
                        "\(token):\($0.path)"
                    ),
                    finite: true,
                    nonzero: true
                )
            }
        )
    }

    private func checkpoint(
        seeds: PrimeExecutionSeeds,
        stepOne:
            PrimeNative3BContinuationStepWitness
    ) throws
        -> PrimeNative3BContinuationCheckpointManifest
    {
        PrimeNative3BContinuationCheckpointManifest(
            seeds: seeds,
            model: artifact(
                "model-after-step-1.v1.safetensors",
                token: "checkpoint-model",
                byteCount:
                    PrimeNative3BMetalContinuationContract
                    .fullStateLogicalByteCount
            ),
            firstMoment: artifact(
                "adam-first-moment-after-step-1.v1.safetensors",
                token: "checkpoint-m",
                byteCount:
                    PrimeNative3BMetalContinuationContract
                    .fullStateLogicalByteCount
            ),
            secondMoment: artifact(
                "adam-second-moment-after-step-1.v1.safetensors",
                token: "checkpoint-v",
                byteCount:
                    PrimeNative3BMetalContinuationContract
                    .fullStateLogicalByteCount
            ),
            stepOneWitness: stepOne
        )
    }

    private func priorEvidence()
        -> PrimeNative3BContinuationPriorEvidenceBindings
    {
        let plan = PrimeNativeArcContinuityPlan.frozenV1
        func binding(
            _ artifactID: String
        ) -> PrimeArtifactBinding {
            let expected = plan.artifacts.first {
                $0.artifactID == artifactID
            }!
            return PrimeArtifactBinding(
                relativePath:
                    "evidence/\(artifactID).json",
                sha256: expected.sha256,
                byteCount: 1,
                purpose: .immutableData
            )
        }
        return PrimeNative3BContinuationPriorEvidenceBindings(
            exact3BMechanicsReceipt: binding(
                "prime_exact_3b_fp32_mechanics_receipt"
            ),
            exact3BExecutionConfiguration: binding(
                "prime_exact_3b_fp32_execution_configuration"
            ),
            exact3BSourceSnapshot: binding(
                "prime_exact_3b_fp32_source_snapshot"
            ),
            typedOptimizerRestoreReceipt: binding(
                "prime_typed_optimizer_restore_receipt"
            )
        )
    }

    private func dependencyEvidence()
        -> PrimeNative3BContinuationDependencyEvidence
    {
        let plan =
            PrimeNative3BContinuationDependencyPlan
                .frozenV1
        func binding(
            _ path: String,
            _ sha256: String
        ) -> PrimeArtifactBinding {
            PrimeArtifactBinding(
                relativePath: path,
                sha256: sha256,
                byteCount: 1,
                purpose: .immutableData
            )
        }
        return PrimeNative3BContinuationDependencyEvidence(
            packageManifest: binding(
                "live-dependency/Package.swift",
                plan.packageManifestSHA256
            ),
            packageResolution: binding(
                "live-dependency/Package.resolved",
                plan.packageResolutionSHA256
            ),
            mirrorConfiguration: binding(
                "live-dependency/mirrors.json",
                plan.mirrorConfigurationSHA256
            ),
            dependencyTreeManifest: binding(
                "live-dependency/dependency-source-tree.v1.json",
                plan.dependencyTreeManifestSHA256
            ),
            license: binding(
                "live-dependency/LICENSE",
                plan.licenseSHA256
            ),
            typedStateSource: binding(
                "live-dependency/AdamOptimizerState.swift",
                plan.typedStateSourceSHA256
            ),
            optimizerSource: binding(
                "live-dependency/Optimizers.swift",
                plan.optimizerSourceSHA256
            ),
            ioSource: binding(
                "live-dependency/FileDescriptorIO.swift",
                plan.ioSourceSHA256
            )
        )
    }

    private func executable() -> PrimeArtifactBinding {
        artifact(
            "PrimeNative3BMetalContinuationProbe.executable",
            token: "executable",
            purpose: .executable
        )
    }

    private func runtimeImage()
        -> PrimePinnedMLXMetallibBinding
    {
        PrimePinnedMLXMetallibBinding(
            mlxSwiftVersion:
                PrimePinnedMLXMetallib.mlxSwiftVersion,
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
                .native3BMetalContinuationProbe,
            releaseInstrumentationPolicy:
                PrimeReleaseInstrumentationAdmissionPolicy
                .declaration
        )
    }

    private func artifact(
        _ path: String,
        token: String,
        byteCount: UInt64 = 1,
        purpose: PrimeArtifactPurpose = .immutableData
    ) -> PrimeArtifactBinding {
        PrimeArtifactBinding(
            relativePath: path,
            sha256: hash(token),
            byteCount: byteCount,
            purpose: purpose
        )
    }

    private func requireResolvedDependencyPins()
        throws
    {
        let plan =
            PrimeNative3BContinuationDependencyPlan
                .frozenV1
        if dependencyPinsPending(plan) {
            throw XCTSkip(
                "descriptor-backed MLX revision and evidence hashes are pending"
            )
        }
        try plan.validate()
    }

    private func dependencyPinsPending(
        _ plan:
            PrimeNative3BContinuationDependencyPlan
    ) -> Bool {
        let values = [
            plan.forkRevision,
            plan.packageManifestSHA256,
            plan.packageResolutionSHA256,
            plan.mirrorConfigurationSHA256,
            plan.dependencyTreeManifestSHA256,
            plan.licenseSHA256,
            plan.typedStateSourceSHA256,
            plan.optimizerSourceSHA256,
            plan.ioSourceSHA256,
        ]
        return values.contains {
            !$0.isEmpty
                && $0.allSatisfy({ $0 == "0" })
        }
    }

    private func hash(_ token: String) -> String {
        PrimeSHA256.hexDigest(of: Data(token.utf8))
    }
}
