// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: MIT

import Foundation
import MLX
import MLXNN
import MLXOptimizers
import XCTest

final class AdamOptimizerStatePublicAPITests:
    XCTestCase
{
    private struct Batch {
        let inputs: MLXArray
        let targets: MLXArray
    }

    private final class ParameterlessChild: Module {}

    private final class ModelWithParameterlessChild:
        Module,
        UnaryLayer
    {
        @ModuleInfo
        var layers = [
            Linear(2, 2),
            Linear(2, 2),
        ]

        let rope = ParameterlessChild()

        func callAsFunction(
            _ x: MLXArray
        ) -> MLXArray {
            layers[1](layers[0](x))
        }
    }

    private let configuration = (
        learningRate: Float(0.0001),
        betas: (Float(0.9), Float(0.999)),
        eps: Float(1e-8),
        weightDecay: Float(0.01)
    )

    private func makeOptimizer() -> AdamW {
        AdamW(
            learningRate: configuration.learningRate,
            betas: configuration.betas,
            eps: configuration.eps,
            weightDecay: configuration.weightDecay
        )
    }

    private func makeModel(
        offset: Float = 0
    ) throws -> Sequential {
        let model = Sequential(
            layers: Linear(2, 2),
            Linear(2, 2)
        )
        let values: [String: MLXArray] = [
            "layers.0.weight": MLXArray(
                [
                    0.20 + offset,
                    -0.30 + offset,
                    0.40 + offset,
                    0.50 + offset,
                ],
                [2, 2]
            ),
            "layers.0.bias": MLXArray(
                [
                    0.10 + offset,
                    -0.20 + offset,
                ]
            ),
            "layers.1.weight": MLXArray(
                [
                    -0.60 + offset,
                    0.70 + offset,
                    0.80 + offset,
                    -0.90 + offset,
                ],
                [2, 2]
            ),
            "layers.1.bias": MLXArray(
                [
                    0.05 + offset,
                    0.15 + offset,
                ]
            ),
        ]
        try model.update(
            parameters: ModuleParameters.unflattened(values),
            verify: .all
        )
        try checkedEval(model)
        return model
    }

    private var firstBatch: Batch {
        Batch(
            inputs: MLXArray(
                [
                    1.0, 2.0,
                    -1.0, 0.5,
                ],
                [2, 2]
            ),
            targets: MLXArray(
                [
                    0.3, -0.2,
                    0.7, 1.1,
                ],
                [2, 2]
            )
        )
    }

    private var secondBatch: Batch {
        Batch(
            inputs: MLXArray(
                [
                    -0.4, 1.3,
                    2.1, -0.8,
                ],
                [2, 2]
            ),
            targets: MLXArray(
                [
                    -0.5, 0.9,
                    1.4, -1.2,
                ],
                [2, 2]
            )
        )
    }

    @discardableResult
    private func step<Model>(
        model: Model,
        optimizer: AdamW,
        batch: Batch
    ) throws -> (
        loss: MLXArray,
        output: MLXArray,
        gradients: ModuleParameters
    ) where Model: Module & UnaryLayer {
        let lossAndGradient = valueAndGrad(
            model: model
        ) { model, inputs, targets in
            mean(
                square(
                    model(inputs) - targets
                )
            )
        }
        let output = model(batch.inputs)
        let (loss, gradients) = lossAndGradient(
            model,
            batch.inputs,
            batch.targets
        )
        optimizer.update(
            model: model,
            gradients: gradients
        )
        try checkedEval(
            [loss, output]
                + model.parameters().flattenedValues()
                + gradients.flattenedValues()
                + optimizer.innerState()
        )
        return (loss, output, gradients)
    }

    private func exactData(
        _ array: MLXArray
    ) -> Data {
        array.asData(access: .copy).data
    }

    private func assertExact(
        _ lhs: ModuleParameters,
        _ rhs: ModuleParameters,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let lhsValues = Dictionary(
            uniqueKeysWithValues: lhs.flattened()
        )
        let rhsValues = Dictionary(
            uniqueKeysWithValues: rhs.flattened()
        )
        XCTAssertEqual(
            Set(lhsValues.keys),
            Set(rhsValues.keys),
            file: file,
            line: line
        )
        for path in lhsValues.keys.sorted() {
            let left = lhsValues[path]!
            let right = rhsValues[path]!
            XCTAssertEqual(
                left.shape,
                right.shape,
                "shape at \(path)",
                file: file,
                line: line
            )
            XCTAssertEqual(
                left.dtype,
                right.dtype,
                "dtype at \(path)",
                file: file,
                line: line
            )
            XCTAssertEqual(
                exactData(left),
                exactData(right),
                "bytes at \(path)",
                file: file,
                line: line
            )
        }
    }

    private func assertExact(
        _ lhs: AdamOptimizerState,
        _ rhs: AdamOptimizerState,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertExact(
            lhs.firstMoment,
            rhs.firstMoment,
            file: file,
            line: line
        )
        assertExact(
            lhs.secondMoment,
            rhs.secondMoment,
            file: file,
            line: line
        )
    }

    private func differs(
        _ lhs: AdamOptimizerState,
        _ rhs: AdamOptimizerState
    ) -> Bool {
        for (left, right) in zip(
            lhs.firstMoment.flattened().sorted {
                $0.0 < $1.0
            },
            rhs.firstMoment.flattened().sorted {
                $0.0 < $1.0
            }
        ) {
            if left.0 != right.0
                || exactData(left.1) != exactData(right.1)
            {
                return true
            }
        }
        for (left, right) in zip(
            lhs.secondMoment.flattened().sorted {
                $0.0 < $1.0
            },
            rhs.secondMoment.flattened().sorted {
                $0.0 < $1.0
            }
        ) {
            if left.0 != right.0
                || exactData(left.1) != exactData(right.1)
            {
                return true
            }
        }
        return false
    }

    private func snapshot(
        replacingFirstMoment values:
            [String: MLXArray],
        in state: AdamOptimizerState
    ) -> AdamOptimizerState {
        AdamOptimizerState(
            firstMoment:
                ModuleParameters.unflattened(values),
            secondMoment: state.secondMoment
        )
    }

    private func snapshot(
        replacingSecondMoment values:
            [String: MLXArray],
        in state: AdamOptimizerState
    ) -> AdamOptimizerState {
        AdamOptimizerState(
            firstMoment: state.firstMoment,
            secondMoment:
                ModuleParameters.unflattened(values)
        )
    }

    func testAdamWNamedStateRestoresExactNPlusOne()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            let controlModel = try makeModel()
            let controlOptimizer = makeOptimizer()
            _ = try step(
                model: controlModel,
                optimizer: controlOptimizer,
                batch: firstBatch
            )
            let controlAtN =
                try controlOptimizer.parameters()
            let expectedPaths = Set([
                "layers.0.bias",
                "layers.0.weight",
                "layers.1.bias",
                "layers.1.weight",
            ])
            XCTAssertEqual(
                Set(
                    controlAtN.firstMoment
                        .flattened().map(\.0)
                ),
                expectedPaths
            )
            XCTAssertEqual(
                Set(
                    controlAtN.secondMoment
                        .flattened().map(\.0)
                ),
                expectedPaths
            )

            let checkpointModel =
                controlModel.parameters().mapValues {
                    $0.reshaped($0.shape)
                }
            try checkedEval(checkpointModel)

            let restoredModel =
                try makeModel(offset: 10)
            try restoredModel.update(
                parameters: checkpointModel,
                verify: .all
            )
            let restoredOptimizer = makeOptimizer()
            try restoredOptimizer.update(
                parameters: controlAtN,
                matching:
                    restoredModel
                    .trainableParameters()
            )
            assertExact(
                controlAtN,
                try restoredOptimizer.parameters()
            )

            _ = try step(
                model: controlModel,
                optimizer: controlOptimizer,
                batch: secondBatch
            )
            _ = try step(
                model: restoredModel,
                optimizer: restoredOptimizer,
                batch: secondBatch
            )

            assertExact(
                controlModel.parameters(),
                restoredModel.parameters()
            )
            assertExact(
                try controlOptimizer.parameters(),
                try restoredOptimizer.parameters()
            )
        }
    }

    func testFlattenedStateWithParameterlessChildRestoresExactNPlusOne()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            let controlModel =
                ModelWithParameterlessChild()
            let controlOptimizer = makeOptimizer()
            _ = try step(
                model: controlModel,
                optimizer: controlOptimizer,
                batch: firstBatch
            )

            let modelAtN =
                controlModel.parameters().mapValues {
                    $0.reshaped($0.shape)
                }
            try checkedEval(modelAtN)
            let stateAtN =
                try controlOptimizer.parameters()
            let serializedState =
                AdamOptimizerState(
                    firstMoment:
                        ModuleParameters.unflattened(
                            Dictionary(
                                uniqueKeysWithValues:
                                    stateAtN.firstMoment
                                    .flattened()
                            )
                        ),
                    secondMoment:
                        ModuleParameters.unflattened(
                            Dictionary(
                                uniqueKeysWithValues:
                                    stateAtN.secondMoment
                                    .flattened()
                            )
                        )
                )

            let restoredModel =
                ModelWithParameterlessChild()
            try restoredModel.update(
                parameters: modelAtN,
                verify: .all
            )
            guard
                case .dictionary(let targetRoot) =
                    restoredModel
                    .trainableParameters().asItem(),
                case .dictionary(let emptyChild)? =
                    targetRoot["rope"],
                emptyChild.isEmpty
            else {
                return XCTFail(
                    "target omitted the parameterless child"
                )
            }
            XCTAssertNil(
                Dictionary(
                    uniqueKeysWithValues:
                        serializedState.firstMoment
                        .flattened()
                )["rope"]
            )

            let restoredOptimizer = makeOptimizer()
            try restoredOptimizer.update(
                parameters: serializedState,
                matching:
                    restoredModel.trainableParameters()
            )
            assertExact(
                stateAtN,
                try restoredOptimizer.parameters()
            )

            _ = try step(
                model: controlModel,
                optimizer: controlOptimizer,
                batch: secondBatch
            )
            _ = try step(
                model: restoredModel,
                optimizer: restoredOptimizer,
                batch: secondBatch
            )
            assertExact(
                controlModel.parameters(),
                restoredModel.parameters()
            )
            assertExact(
                try controlOptimizer.parameters(),
                try restoredOptimizer.parameters()
            )
        }
    }

    func testAdamAlsoExposesThePublicStateAPI()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            let parameter =
                MLXArray([0.2, -0.4], [1, 2])
            let gradient =
                MLXArray([0.3, 0.7], [1, 2])
            let model = Linear(2, 1, bias: false)
            try model.update(
                parameters:
                    ModuleParameters.unflattened([
                        "weight": parameter
                    ]),
                verify: .all
            )
            let optimizer = Adam(
                learningRate: 0.0001
            )
            optimizer.update(
                model: model,
                gradients:
                    ModuleParameters.unflattened([
                        "weight": gradient
                    ])
            )
            try checkedEval(model, optimizer)
            let state = try optimizer.parameters()

            let restored = Adam(
                learningRate: 0.0001
            )
            try restored.update(
                parameters: state,
                matching: model.trainableParameters()
            )
            assertExact(
                state,
                try restored.parameters()
            )
        }
    }

    func testImportRejectsInvalidStateAndAdoptsTargetTopology()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            XCTAssertThrowsError(
                try makeOptimizer().parameters()
            ) {
                XCTAssertEqual(
                    $0 as? AdamOptimizerStateError,
                    .emptyState
                )
            }

            let model = try makeModel()
            let initialized = makeOptimizer()
            _ = try step(
                model: model,
                optimizer: initialized,
                batch: firstBatch
            )
            let state = try initialized.parameters()
            let target = model.trainableParameters()

            XCTAssertThrowsError(
                try initialized.update(
                    parameters: state,
                    matching: target
                )
            ) {
                XCTAssertEqual(
                    $0 as? AdamOptimizerStateError,
                    .optimizerAlreadyInitialized
                )
            }

            XCTAssertThrowsError(
                try makeOptimizer().update(
                    parameters: AdamOptimizerState(
                        firstMoment: .init(),
                        secondMoment: .init()
                    ),
                    matching: target
                )
            ) {
                XCTAssertEqual(
                    $0 as? AdamOptimizerStateError,
                    .emptyState
                )
            }

            XCTAssertThrowsError(
                try makeOptimizer().update(
                    parameters: state,
                    matching: .init()
                )
            ) {
                XCTAssertEqual(
                    $0 as? AdamOptimizerStateError,
                    .emptyTargetParameters
                )
            }

            let path = "layers.0.weight"
            var first = Dictionary(
                uniqueKeysWithValues:
                    state.firstMoment.flattened()
            )
            first.removeValue(forKey: path)
            XCTAssertThrowsError(
                try makeOptimizer().update(
                    parameters: snapshot(
                        replacingFirstMoment: first,
                        in: state
                    ),
                    matching: target
                )
            ) {
                XCTAssertEqual(
                    $0 as? AdamOptimizerStateError,
                    .missingPath(
                        moment: .first,
                        path: path
                    )
                )
            }

            var second = Dictionary(
                uniqueKeysWithValues:
                    state.secondMoment.flattened()
            )
            second["extra.weight"] =
                MLXArray.zeros([2, 2])
            XCTAssertThrowsError(
                try makeOptimizer().update(
                    parameters: snapshot(
                        replacingSecondMoment: second,
                        in: state
                    ),
                    matching: target
                )
            ) {
                XCTAssertEqual(
                    $0 as? AdamOptimizerStateError,
                    .extraPath(
                        moment: .second,
                        path: "extra.weight"
                    )
                )
            }

            first = Dictionary(
                uniqueKeysWithValues:
                    state.firstMoment.flattened()
            )
            first[path] = MLXArray.zeros([4])
            XCTAssertThrowsError(
                try makeOptimizer().update(
                    parameters: snapshot(
                        replacingFirstMoment: first,
                        in: state
                    ),
                    matching: target
                )
            ) {
                XCTAssertEqual(
                    $0 as? AdamOptimizerStateError,
                    .shapeMismatch(
                        moment: .first,
                        path: path,
                        expected: [2, 2],
                        actual: [4]
                    )
                )
            }

            second = Dictionary(
                uniqueKeysWithValues:
                    state.secondMoment.flattened()
            )
            second[path] =
                second[path]!.asType(.float16)
            XCTAssertThrowsError(
                try makeOptimizer().update(
                    parameters: snapshot(
                        replacingSecondMoment: second,
                        in: state
                    ),
                    matching: target
                )
            ) {
                XCTAssertEqual(
                    $0 as? AdamOptimizerStateError,
                    .dtypeMismatch(
                        moment: .second,
                        path: path,
                        expected: .float32,
                        actual: .float16
                    )
                )
            }

            let value = MLXArray([1.0])
            let nestedTarget = ModuleParameters(
                values: [
                    "a": .array([.value(value)])
                ]
            )
            let flatState = ModuleParameters(
                values: [
                    "a.0": .value(MLXArray([0.0]))
                ]
            )
            let pathRestored = makeOptimizer()
            try pathRestored.update(
                parameters: AdamOptimizerState(
                    firstMoment: flatState,
                    secondMoment: flatState
                ),
                matching: nestedTarget
            )
            let pathRestoredState =
                try pathRestored.parameters()
            XCTAssertEqual(
                exactData(
                    Dictionary(
                        uniqueKeysWithValues:
                            pathRestoredState
                            .firstMoment.flattened()
                    )["a.0"]!
                ),
                exactData(MLXArray([0.0]))
            )
            guard
                case .dictionary(let root) =
                    pathRestoredState.firstMoment
                    .asItem(),
                case .array(let values)? = root["a"],
                values.count == 1,
                case .value = values[0]
            else {
                return XCTFail(
                    "restored state did not adopt target topology"
                )
            }

            let collision = ModuleParameters(
                values: [
                    "a": .dictionary([
                        "b": .value(MLXArray([0.0]))
                    ]),
                    "a.b": .value(MLXArray([0.0])),
                ]
            )
            let collisionTarget =
                ModuleParameters.unflattened([
                    "a.b": value
                ])
            XCTAssertThrowsError(
                try makeOptimizer().update(
                    parameters: AdamOptimizerState(
                        firstMoment: collision,
                        secondMoment: collisionTarget
                    ),
                    matching: collisionTarget
                )
            ) {
                XCTAssertEqual(
                    $0 as? AdamOptimizerStateError,
                    .duplicatePath(
                        moment: .first,
                        path: "a.b"
                    )
                )
            }
        }
    }

    func testExportAndImportDoNotAliasMutableWrappers()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            let model = try makeModel()
            let optimizer = makeOptimizer()
            _ = try step(
                model: model,
                optimizer: optimizer,
                batch: firstBatch
            )

            let exported = try optimizer.parameters()
            let path = "layers.0.weight"
            let exportedArray = Dictionary(
                uniqueKeysWithValues:
                    exported.firstMoment.flattened()
            )[path]!
            let expectedBytes = exactData(exportedArray)
            exportedArray._updateInternal(
                MLXArray.zeros(exportedArray.shape)
            )
            let afterExportMutation =
                try optimizer.parameters()
            XCTAssertEqual(
                exactData(
                    Dictionary(
                        uniqueKeysWithValues:
                            afterExportMutation
                            .firstMoment.flattened()
                    )[path]!
                ),
                expectedBytes
            )

            let advanceSnapshot =
                try optimizer.parameters()
            let advanceSnapshotArray = Dictionary(
                uniqueKeysWithValues:
                    advanceSnapshot.firstMoment
                    .flattened()
            )[path]!
            let advanceSnapshotBytes =
                exactData(advanceSnapshotArray)
            _ = try step(
                model: model,
                optimizer: optimizer,
                batch: secondBatch
            )
            XCTAssertEqual(
                exactData(advanceSnapshotArray),
                advanceSnapshotBytes
            )

            let clean = try optimizer.parameters()
            let restored = makeOptimizer()
            try restored.update(
                parameters: clean,
                matching: model.trainableParameters()
            )
            let cleanArray = Dictionary(
                uniqueKeysWithValues:
                    clean.firstMoment.flattened()
            )[path]!
            let cleanBytes = exactData(cleanArray)
            cleanArray._updateInternal(
                MLXArray.zeros(cleanArray.shape)
            )
            let afterImportMutation =
                try restored.parameters()
            XCTAssertEqual(
                exactData(
                    Dictionary(
                        uniqueKeysWithValues:
                            afterImportMutation
                            .firstMoment.flattened()
                    )[path]!
                ),
                cleanBytes
            )
        }
    }

    func testAdamWAPIUnusedOneStepTrajectoryMatchesPinnedBase()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            let model = Linear(
                weight: MLXArray(
                    [
                        Float(0.125), -0.25,
                        -0.75, 0.375,
                    ],
                    [2, 2]
                ),
                bias: MLXArray(
                    [Float(0.03125), -0.15625],
                    [2]
                )
            )
            let inputs = MLXArray(
                [
                    Float(0.25), -0.5,
                    1.0, 0.125,
                ],
                [2, 2]
            )
            let targets = MLXArray(
                [
                    Float(0.5), -0.125,
                    0.25, 0.75,
                ],
                [2, 2]
            )
            let optimizer = makeOptimizer()
            let lossAndGradient = valueAndGrad(
                model: model
            ) { model, inputs, targets in
                mean(
                    square(
                        model(inputs) - targets
                    )
                )
            }
            let (loss, gradients) = lossAndGradient(
                model,
                inputs,
                targets
            )
            optimizer.update(
                model: model,
                gradients: gradients
            )
            let state = optimizer.innerState()
            try checkedEval(
                [loss]
                    + model.parameters()
                    .flattenedValues()
                    + state
            )

            let parameters = Dictionary(
                uniqueKeysWithValues:
                    model.parameters().flattened()
            )
            XCTAssertEqual(
                exactData(parameters["bias"]!),
                Data([
                    0x8f, 0x4b, 0x01, 0x3d,
                    0x0f, 0xad, 0x1f, 0xbe,
                ])
            )
            XCTAssertEqual(
                exactData(parameters["weight"]!),
                Data([
                    0xdd, 0x52, 0x00, 0x3e,
                    0x6a, 0x29, 0x80, 0xbe,
                    0x3a, 0xeb, 0x3f, 0xbf,
                    0x84, 0xd6, 0xbf, 0x3e,
                ])
            )
            XCTAssertEqual(state.count, 4)
            XCTAssertEqual(
                exactData(state[0]),
                Data([
                    0x36, 0x33, 0xb3, 0xbc,
                    0x6a, 0x66, 0xce, 0xbd,
                ])
            )
            XCTAssertEqual(
                exactData(state[1]),
                Data([
                    0x90, 0xb3, 0x48, 0x38,
                    0x54, 0x20, 0x85, 0x3a,
                ])
            )
            XCTAssertEqual(
                exactData(state[2]),
                Data([
                    0x69, 0x66, 0x26, 0xbc,
                    0x6a, 0x66, 0xe6, 0x3b,
                    0x36, 0x33, 0xaf, 0xbd,
                    0xd0, 0xcc, 0xcc, 0x38,
                ])
            )
            XCTAssertEqual(
                exactData(state[3]),
                Data([
                    0xc4, 0x0d, 0x2d, 0x37,
                    0xc8, 0xe2, 0xa5, 0x36,
                    0x6f, 0xd7, 0x3f, 0x3a,
                    0x00, 0x12, 0x83, 0x30,
                ])
            )
        }
    }

    func testMomentAndSameShapePathSwapsDivergeAtNPlusOne()
        throws
    {
        try Device.withDefaultDevice(.cpu) {
            let writerModel = try makeModel()
            let writerOptimizer = makeOptimizer()
            _ = try step(
                model: writerModel,
                optimizer: writerOptimizer,
                batch: firstBatch
            )
            let modelAtN =
                writerModel.parameters().mapValues {
                    $0.reshaped($0.shape)
                }
            let stateAtN =
                try writerOptimizer.parameters()

            let controlModel = try makeModel(offset: 5)
            try controlModel.update(
                parameters: modelAtN,
                verify: .all
            )
            let controlOptimizer = makeOptimizer()
            try controlOptimizer.update(
                parameters: stateAtN,
                matching:
                    controlModel.trainableParameters()
            )
            _ = try step(
                model: controlModel,
                optimizer: controlOptimizer,
                batch: secondBatch
            )
            let control =
                try controlOptimizer.parameters()

            let momentSwapModel =
                try makeModel(offset: 6)
            try momentSwapModel.update(
                parameters: modelAtN,
                verify: .all
            )
            let momentSwapOptimizer =
                makeOptimizer()
            try momentSwapOptimizer.update(
                parameters: AdamOptimizerState(
                    firstMoment:
                        stateAtN.secondMoment,
                    secondMoment:
                        stateAtN.firstMoment
                ),
                matching:
                    momentSwapModel
                    .trainableParameters()
            )
            _ = try step(
                model: momentSwapModel,
                optimizer: momentSwapOptimizer,
                batch: secondBatch
            )
            XCTAssertTrue(
                differs(
                    control,
                    try momentSwapOptimizer
                        .parameters()
                )
            )

            let first = Dictionary(
                uniqueKeysWithValues:
                    stateAtN.firstMoment.flattened()
            )
            let second = Dictionary(
                uniqueKeysWithValues:
                    stateAtN.secondMoment.flattened()
            )
            var swappedFirst = first
            var swappedSecond = second
            swappedFirst["layers.0.weight"] =
                first["layers.1.weight"]
            swappedFirst["layers.1.weight"] =
                first["layers.0.weight"]
            swappedSecond["layers.0.weight"] =
                second["layers.1.weight"]
            swappedSecond["layers.1.weight"] =
                second["layers.0.weight"]

            let pathSwapModel =
                try makeModel(offset: 7)
            try pathSwapModel.update(
                parameters: modelAtN,
                verify: .all
            )
            let pathSwapOptimizer = makeOptimizer()
            try pathSwapOptimizer.update(
                parameters: AdamOptimizerState(
                    firstMoment:
                        ModuleParameters.unflattened(
                            swappedFirst
                        ),
                    secondMoment:
                        ModuleParameters.unflattened(
                            swappedSecond
                        )
                ),
                matching:
                    pathSwapModel.trainableParameters()
            )
            _ = try step(
                model: pathSwapModel,
                optimizer: pathSwapOptimizer,
                batch: secondBatch
            )
            XCTAssertTrue(
                differs(
                    control,
                    try pathSwapOptimizer.parameters()
                )
            )
        }
    }
}
