import MLX
import MLXNN
import MLXOptimizers
import PrimeCore
import PrimeTypedOptimizerRestoreMechanics
import XCTest

final class PrimeTypedOptimizerRestoreMechanicsTests:
    XCTestCase
{
    func testControlWriterAndTypedRestoreAreExact()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            for fixture in
                PrimeTypedOptimizerFixture
                .allCases.sorted()
            {
                let control =
                    try PrimeTypedOptimizerMechanics
                    .runControl(fixture: fixture)
                let writer =
                    try PrimeTypedOptimizerMechanics
                    .runWriter(fixture: fixture)
                let restored =
                    try PrimeTypedOptimizerMechanics
                    .runRestorer(
                        checkpoint:
                            writer.checkpoint
                    )

                XCTAssertEqual(
                    control.first,
                    writer.manifest.entries
                )
                XCTAssertEqual(
                    stateEntries(control.first),
                    restored.first
                )
                XCTAssertEqual(
                    control.second.entries,
                    restored.second.entries
                )
            }
        }
    }

    func testCheckpointRehydrationRejectsCatalogDefectsBeforeRestore()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            let writer =
                try PrimeTypedOptimizerMechanics
                .runWriter(
                    fixture: .nestedSameShape
                )
            let model = Dictionary(
                uniqueKeysWithValues:
                    writer.checkpoint
                    .modelStoragePairs
            )
            let optimizer = Dictionary(
                uniqueKeysWithValues:
                    writer.checkpoint
                    .optimizerStoragePairs
            )
            let rehydrated =
                try PrimeTypedOptimizerMechanics
                .rehydrateCheckpoint(
                    fixture: .nestedSameShape,
                    modelArrays: model,
                    optimizerArrays: optimizer,
                    writerManifest:
                        writer.manifest
                )
            let restored =
                try PrimeTypedOptimizerMechanics
                .runRestorer(
                    checkpoint: rehydrated
                )
            let control =
                try PrimeTypedOptimizerMechanics
                .runControl(
                    fixture: .nestedSameShape
                )
            XCTAssertEqual(
                control.second.entries,
                restored.second.entries
            )

            var missing = optimizer
            missing.removeValue(
                forKey:
                    writer.checkpoint
                    .optimizerStoragePairs[0].0
            )
            XCTAssertThrowsError(
                try PrimeTypedOptimizerMechanics
                    .rehydrateCheckpoint(
                        fixture:
                            .nestedSameShape,
                        modelArrays: model,
                        optimizerArrays: missing,
                        writerManifest:
                            writer.manifest
                    )
            )

            var extra = optimizer
            extra["second_moment.extra.weight"] =
                MLXArray.zeros([2, 2])
            XCTAssertThrowsError(
                try PrimeTypedOptimizerMechanics
                    .rehydrateCheckpoint(
                        fixture:
                            .nestedSameShape,
                        modelArrays: model,
                        optimizerArrays: extra,
                        writerManifest:
                            writer.manifest
                    )
            )
        }
    }

    func testInvalidTypedStatesAreRejected()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            for fixture in
                PrimeTypedOptimizerFixture
                .allCases.sorted()
            {
                let writer =
                    try PrimeTypedOptimizerMechanics
                    .runWriter(fixture: fixture)
                for mutation:
                    PrimeTypedOptimizerStateMutation in [
                        .missingFirstMoment,
                        .extraSecondMoment,
                        .firstMomentShapeMismatch,
                        .secondMomentDTypeMismatch,
                    ]
                {
                    let state =
                        try PrimeTypedOptimizerMechanics
                        .mutatedState(
                            writer.checkpoint
                                .optimizerState,
                            fixture: fixture,
                            mutation: mutation
                        )
                    XCTAssertThrowsError(
                        try PrimeTypedOptimizerMechanics
                            .restore(
                                checkpoint:
                                    replacingState(
                                        state,
                                        in:
                                            writer
                                            .checkpoint
                                    )
                            )
                    )
                }
            }
        }
    }

    func testShapeCompatibleStateSwapsImportButDiverge()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            let fixture:
                PrimeTypedOptimizerFixture =
                    .nestedSameShape
            let control =
                try PrimeTypedOptimizerMechanics
                .runControl(fixture: fixture)
            let writer =
                try PrimeTypedOptimizerMechanics
                .runWriter(fixture: fixture)
            for mutation:
                PrimeTypedOptimizerStateMutation in [
                    .momentsSwapped,
                    .sameShapePathSwap,
                ] {
                let state =
                    try PrimeTypedOptimizerMechanics
                    .mutatedState(
                        writer.checkpoint
                            .optimizerState,
                        fixture: fixture,
                        mutation: mutation
                    )
                do {
                    let trajectory =
                        try PrimeTypedOptimizerMechanics
                        .runRestorer(
                            checkpoint:
                                replacingState(
                                    state,
                                    in:
                                        writer
                                        .checkpoint
                                )
                        )
                    XCTAssertNotEqual(
                        trajectory.second.entries,
                        control.second.entries
                    )
                } catch let error
                    as PrimeTypedOptimizerMechanicsError
                {
                    guard mutation
                            == .momentsSwapped,
                          case .nonFiniteTensor =
                            error else {
                        XCTFail(
                            "unexpected shape-compatible mutation error: \(error)"
                        )
                        continue
                    }
                } catch {
                    XCTFail(
                        "unexpected shape-compatible mutation error: \(error)"
                    )
                }
            }
        }
    }

    func testInitializedOptimizerCannotBeOverwritten()
        throws
    {
        for fixture in
            PrimeTypedOptimizerFixture
            .allCases.sorted()
        {
            XCTAssertNoThrow(
                try PrimeTypedOptimizerMechanics
                    .verifyNonemptyImportRejected(
                        fixture: fixture
                    )
            )
        }
    }

    func testExportedAndImportedSnapshotsDoNotAliasLiveOptimizers()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            let fixture:
                PrimeTypedOptimizerFixture =
                    .nestedSameShape
            let model =
                try PrimeTypedOptimizerMechanics
                .makeModel(fixture: fixture)
            let source =
                PrimeTypedOptimizerMechanics
                .makeOptimizer()
            let batch =
                PrimeTypedOptimizerMechanics
                .batches(fixture: fixture)
            let first =
                try PrimeTypedOptimizerMechanics
                .runStep(
                    model: model,
                    optimizer: source,
                    batch: batch.first,
                    fixture: fixture,
                    stepIndex: 1
                )
            let exportedBefore =
                exactState(first.optimizerState)
            _ = try PrimeTypedOptimizerMechanics
                .runStep(
                    model: model,
                    optimizer: source,
                    batch: batch.second,
                    fixture: fixture,
                    stepIndex: 2
                )
            XCTAssertEqual(
                exactState(first.optimizerState),
                exportedBefore
            )

            let writer =
                try PrimeTypedOptimizerMechanics
                .runWriter(fixture: fixture)
            let firstRestore =
                try PrimeTypedOptimizerMechanics
                .restore(
                    checkpoint:
                        writer.checkpoint
                )
            let secondRestore =
                try PrimeTypedOptimizerMechanics
                .restore(
                    checkpoint:
                        writer.checkpoint
                )
            let secondBefore = exactState(
                try secondRestore.optimizer
                    .parameters()
            )
            _ = try PrimeTypedOptimizerMechanics
                .runStep(
                    model: firstRestore.model,
                    optimizer:
                        firstRestore.optimizer,
                    batch: batch.second,
                    fixture: fixture,
                    stepIndex: 2
                )
            XCTAssertEqual(
                exactState(
                    try secondRestore.optimizer
                        .parameters()
                ),
                secondBefore
            )
            XCTAssertEqual(
                exactState(
                    writer.checkpoint
                        .optimizerState
                ),
                secondBefore
            )
        }
    }

    private func replacingState(
        _ state: AdamOptimizerState,
        in checkpoint:
            PrimeTypedOptimizerCheckpoint
    ) -> PrimeTypedOptimizerCheckpoint {
        PrimeTypedOptimizerCheckpoint(
            fixture: checkpoint.fixture,
            stepIndex: checkpoint.stepIndex,
            modelParameters:
                checkpoint.modelParameters,
            optimizerState: state,
            modelStoragePairs:
                checkpoint.modelStoragePairs,
            optimizerStoragePairs:
                checkpoint.optimizerStoragePairs
        )
    }

    private func stateEntries(
        _ entries:
            [PrimeTypedOptimizerTensorEntry]
    ) -> [PrimeTypedOptimizerTensorEntry] {
        entries.filter {
            $0.role == .modelParameter
                || $0.role == .firstMoment
                || $0.role == .secondMoment
        }
    }

    private func exactState(
        _ state: AdamOptimizerState
    ) -> [String: Data] {
        var result = [String: Data]()
        for (path, array) in
            state.firstMoment.flattened()
        {
            result["first.\(path)"] =
                array.asData(access: .copy).data
        }
        for (path, array) in
            state.secondMoment.flattened()
        {
            result["second.\(path)"] =
                array.asData(access: .copy).data
        }
        return result
    }
}
