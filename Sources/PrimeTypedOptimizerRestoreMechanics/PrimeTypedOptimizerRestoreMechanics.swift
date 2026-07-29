import Foundation
import MLX
import MLXNN
import MLXOptimizers
import PrimeCore

public enum PrimeTypedOptimizerMechanicsError:
    Error,
    Equatable,
    Sendable
{
    case nonCPUExecution(String)
    case invalidStep(Int)
    case unexpectedParameterPaths(
        expected: [String],
        observed: [String]
    )
    case tensorMismatch(String)
    case checkpointKeyMismatch(
        expected: [String],
        observed: [String]
    )
    case duplicateCheckpointStorageKey(String)
    case unsupportedStateMutation
    case expectedImportRejection
    case stateDidNotProgress
    case gradientWasZeroOrNonfinite(String)
    case nonFiniteTensor(String)
}

public struct PrimeTypedOptimizerBatch {
    public let inputs: MLXArray
    public let targets: MLXArray

    public init(
        inputs: MLXArray,
        targets: MLXArray
    ) {
        self.inputs = inputs
        self.targets = targets
    }
}

public enum PrimeTypedOptimizerModel {
    case flat(Linear)
    case nested(Sequential)

    public func parameters() -> ModuleParameters {
        switch self {
        case let .flat(model):
            model.parameters()
        case let .nested(model):
            model.parameters()
        }
    }

    public func trainableParameters()
        -> ModuleParameters
    {
        switch self {
        case let .flat(model):
            model.trainableParameters()
        case let .nested(model):
            model.trainableParameters()
        }
    }

    public func update(
        parameters: ModuleParameters
    ) throws {
        switch self {
        case let .flat(model):
            try model.update(
                parameters: parameters,
                verify: .all
            )
        case let .nested(model):
            try model.update(
                parameters: parameters,
                verify: .all
            )
        }
    }

    public func output(_ inputs: MLXArray)
        -> MLXArray
    {
        switch self {
        case let .flat(model):
            model(inputs)
        case let .nested(model):
            model(inputs)
        }
    }
}

public struct PrimeTypedOptimizerStepResult {
    public let fixture: PrimeTypedOptimizerFixture
    public let stepIndex: Int
    public let loss: MLXArray
    public let output: MLXArray
    public let gradients: ModuleParameters
    public let modelParameters: ModuleParameters
    public let optimizerState: AdamOptimizerState
    public let entries:
        [PrimeTypedOptimizerTensorEntry]

    public init(
        fixture: PrimeTypedOptimizerFixture,
        stepIndex: Int,
        loss: MLXArray,
        output: MLXArray,
        gradients: ModuleParameters,
        modelParameters: ModuleParameters,
        optimizerState: AdamOptimizerState,
        entries:
            [PrimeTypedOptimizerTensorEntry]
    ) {
        self.fixture = fixture
        self.stepIndex = stepIndex
        self.loss = loss
        self.output = output
        self.gradients = gradients
        self.modelParameters = modelParameters
        self.optimizerState = optimizerState
        self.entries = entries
    }
}

public struct PrimeTypedOptimizerCheckpoint {
    public let fixture: PrimeTypedOptimizerFixture
    public let stepIndex: Int
    public let modelParameters: ModuleParameters
    public let optimizerState: AdamOptimizerState
    public let modelStoragePairs:
        [(String, MLXArray)]
    public let optimizerStoragePairs:
        [(String, MLXArray)]

    public init(
        fixture: PrimeTypedOptimizerFixture,
        stepIndex: Int,
        modelParameters: ModuleParameters,
        optimizerState: AdamOptimizerState,
        modelStoragePairs:
            [(String, MLXArray)],
        optimizerStoragePairs:
            [(String, MLXArray)]
    ) {
        self.fixture = fixture
        self.stepIndex = stepIndex
        self.modelParameters = modelParameters
        self.optimizerState = optimizerState
        self.modelStoragePairs =
            modelStoragePairs
        self.optimizerStoragePairs =
            optimizerStoragePairs
    }
}

public struct PrimeTypedOptimizerTrajectory {
    public let first:
        [PrimeTypedOptimizerTensorEntry]
    public let second:
        PrimeTypedOptimizerStepResult
    public let manifest:
        PrimeTypedOptimizerExecutionManifest

    public init(
        first:
            [PrimeTypedOptimizerTensorEntry],
        second:
            PrimeTypedOptimizerStepResult,
        manifest:
            PrimeTypedOptimizerExecutionManifest
    ) {
        self.first = first
        self.second = second
        self.manifest = manifest
    }
}

public enum PrimeTypedOptimizerStateMutation:
    Equatable,
    Sendable
{
    case momentsSwapped
    case sameShapePathSwap
    case missingFirstMoment
    case extraSecondMoment
    case firstMomentShapeMismatch
    case secondMomentDTypeMismatch
}

public enum PrimeTypedOptimizerMechanics {
    public static func makeModel(
        fixture: PrimeTypedOptimizerFixture,
        perturbed: Bool = false
    ) throws -> PrimeTypedOptimizerModel {
        let offset: Float = perturbed ? 10 : 0
        switch fixture {
        case .flat:
            let model = Linear(
                weight: MLXArray(
                    [
                        Float(0.125) + offset,
                        -0.25 + offset,
                        -0.75 + offset,
                        0.375 + offset,
                    ],
                    [2, 2]
                ),
                bias: MLXArray(
                    [
                        Float(0.03125) + offset,
                        -0.15625 + offset,
                    ],
                    [2]
                )
            )
            try checkedEval(model)
            return .flat(model)

        case .nestedSameShape:
            let model = Sequential(
                layers: Linear(
                    weight: MLXArray(
                        [
                            Float(0.20) + offset,
                            -0.30 + offset,
                            0.40 + offset,
                            0.50 + offset,
                        ],
                        [2, 2]
                    ),
                    bias: MLXArray(
                        [
                            Float(0.10) + offset,
                            -0.20 + offset,
                        ],
                        [2]
                    )
                ),
                Linear(
                    weight: MLXArray(
                        [
                            Float(-0.60) + offset,
                            0.70 + offset,
                            0.80 + offset,
                            -0.90 + offset,
                        ],
                        [2, 2]
                    ),
                    bias: MLXArray(
                        [
                            Float(0.05) + offset,
                            0.15 + offset,
                        ],
                        [2]
                    )
                )
            )
            try checkedEval(model)
            return .nested(model)
        }
    }

    public static func makeOptimizer() -> AdamW {
        let configuration =
            PrimeTypedOptimizerConfiguration
                .frozenAdamW
        return AdamW(
            learningRate:
                configuration.learningRate,
            betas: (
                configuration.beta1,
                configuration.beta2
            ),
            eps: configuration.epsilon,
            weightDecay:
                configuration.weightDecay
        )
    }

    public static func batches(
        fixture: PrimeTypedOptimizerFixture
    ) -> (
        first: PrimeTypedOptimizerBatch,
        second: PrimeTypedOptimizerBatch
    ) {
        switch fixture {
        case .flat:
            return (
                PrimeTypedOptimizerBatch(
                    inputs: MLXArray(
                        [
                            Float(0.25), -0.5,
                            1.0, 0.125,
                        ],
                        [2, 2]
                    ),
                    targets: MLXArray(
                        [
                            Float(0.5), -0.125,
                            0.25, 0.75,
                        ],
                        [2, 2]
                    )
                ),
                PrimeTypedOptimizerBatch(
                    inputs: MLXArray(
                        [
                            Float(-0.4), 1.3,
                            2.1, -0.8,
                        ],
                        [2, 2]
                    ),
                    targets: MLXArray(
                        [
                            Float(-0.5), 0.9,
                            1.4, -1.2,
                        ],
                        [2, 2]
                    )
                )
            )

        case .nestedSameShape:
            return (
                PrimeTypedOptimizerBatch(
                    inputs: MLXArray(
                        [
                            Float(1.0), 2.0,
                            -1.0, 0.5,
                        ],
                        [2, 2]
                    ),
                    targets: MLXArray(
                        [
                            Float(0.3), -0.2,
                            0.7, 1.1,
                        ],
                        [2, 2]
                    )
                ),
                PrimeTypedOptimizerBatch(
                    inputs: MLXArray(
                        [
                            Float(-0.2), 0.7,
                            1.5, -1.1,
                        ],
                        [2, 2]
                    ),
                    targets: MLXArray(
                        [
                            Float(0.8), -0.4,
                            -0.6, 1.2,
                        ],
                        [2, 2]
                    )
                )
            )
        }
    }

    public static func runStep(
        model: PrimeTypedOptimizerModel,
        optimizer: AdamW,
        batch: PrimeTypedOptimizerBatch,
        fixture: PrimeTypedOptimizerFixture,
        stepIndex: Int
    ) throws -> PrimeTypedOptimizerStepResult {
        guard stepIndex == 1 || stepIndex == 2 else {
            throw PrimeTypedOptimizerMechanicsError
                .invalidStep(stepIndex)
        }
        try requireCPUDefault()
        try requireExpectedPaths(
            model.trainableParameters(),
            fixture: fixture
        )
        let modelBefore =
            snapshot(model.parameters())
        let optimizerBefore:
            AdamOptimizerState?
        do {
            optimizerBefore =
                try snapshot(
                    optimizer.parameters()
                )
        } catch AdamOptimizerStateError.emptyState {
            optimizerBefore = nil
        }
        guard (stepIndex == 1)
                == (optimizerBefore == nil) else {
            throw PrimeTypedOptimizerMechanicsError
                .tensorMismatch(
                    "optimizer initialization/step mismatch"
                )
        }

        let result: (
            loss: MLXArray,
            output: MLXArray,
            gradients: ModuleParameters
        )
        switch model {
        case let .flat(concrete):
            let lossAndGradient = valueAndGrad(
                model: concrete
            ) { model, inputs, targets in
                mean(
                    square(
                        model(inputs) - targets
                    )
                )
            }
            let output = concrete(batch.inputs)
            let (loss, gradients) =
                lossAndGradient(
                    concrete,
                    batch.inputs,
                    batch.targets
                )
            result = (loss, output, gradients)

        case let .nested(concrete):
            let lossAndGradient = valueAndGrad(
                model: concrete
            ) { model, inputs, targets in
                mean(
                    square(
                        model(inputs) - targets
                    )
                )
            }
            let output = concrete(batch.inputs)
            let (loss, gradients) =
                lossAndGradient(
                    concrete,
                    batch.inputs,
                    batch.targets
                )
            result = (loss, output, gradients)
        }

        try requireExpectedPaths(
            result.gradients,
            fixture: fixture
        )
        try requireFiniteNonzeroGradients(
            result.gradients
        )
        switch model {
        case let .flat(concrete):
            optimizer.update(
                model: concrete,
                gradients: result.gradients
            )
        case let .nested(concrete):
            optimizer.update(
                model: concrete,
                gradients: result.gradients
            )
        }

        let modelParameters =
            snapshot(model.parameters())
        let optimizerState =
            try snapshot(optimizer.parameters())
        try checkedEval(
            [result.loss, result.output]
                + result.gradients
                .flattenedValues()
                + modelParameters
                .flattenedValues()
                + optimizerState.firstMoment
                .flattenedValues()
                + optimizerState.secondMoment
                .flattenedValues()
        )
        try requireEveryTensorChanged(
            from: modelBefore,
            to: modelParameters,
            scope: "model"
        )
        if let optimizerBefore {
            try requireEveryTensorChanged(
                from:
                    optimizerBefore.firstMoment,
                to: optimizerState.firstMoment,
                scope: "first moment"
            )
            try requireEveryTensorChanged(
                from:
                    optimizerBefore.secondMoment,
                to: optimizerState.secondMoment,
                scope: "second moment"
            )
        } else {
            try requireEveryTensorNonzero(
                optimizerState.firstMoment,
                scope: "first moment"
            )
            try requireEveryTensorNonzero(
                optimizerState.secondMoment,
                scope: "second moment"
            )
        }

        let entries = try makeEntries(
            fixture: fixture,
            stepIndex: stepIndex,
            loss: result.loss,
            output: result.output,
            gradients: result.gradients,
            modelParameters: modelParameters,
            optimizerState: optimizerState
        )
        return PrimeTypedOptimizerStepResult(
            fixture: fixture,
            stepIndex: stepIndex,
            loss: result.loss,
            output: result.output,
            gradients: snapshot(result.gradients),
            modelParameters: modelParameters,
            optimizerState: optimizerState,
            entries: entries
        )
    }

    public static func makeManifest(
        role: PrimeTypedOptimizerWorkerRole,
        fixture: PrimeTypedOptimizerFixture,
        steps:
            [PrimeTypedOptimizerTensorEntry]
    ) throws
        -> PrimeTypedOptimizerExecutionManifest
    {
        let manifest =
            PrimeTypedOptimizerExecutionManifest(
                workerRole: role,
                fixture: fixture,
                trainablePaths:
                    fixture.trainablePaths,
                frozenPaths: [],
                missingGradientPolicy: .reject,
                semanticObservations: .confirmed,
                entries: steps.sorted {
                    entryIdentity($0)
                        < entryIdentity($1)
                }
            )
        try manifest.validate()
        return manifest
    }

    public static func runControl(
        fixture: PrimeTypedOptimizerFixture
    ) throws -> PrimeTypedOptimizerTrajectory {
        try Device.withDefaultDevice(.cpu) {
            let model = try makeModel(
                fixture: fixture
            )
            let optimizer = makeOptimizer()
            let controlledBatches =
                batches(fixture: fixture)
            let first = try runStep(
                model: model,
                optimizer: optimizer,
                batch: controlledBatches.first,
                fixture: fixture,
                stepIndex: 1
            )
            let second = try runStep(
                model: model,
                optimizer: optimizer,
                batch: controlledBatches.second,
                fixture: fixture,
                stepIndex: 2
            )
            try requireStateProgress(
                from: first.entries,
                to: second.entries
            )
            return PrimeTypedOptimizerTrajectory(
                first: first.entries,
                second: second,
                manifest: try makeManifest(
                    role: .control,
                    fixture: fixture,
                    steps:
                        first.entries
                        + second.entries
                )
            )
        }
    }

    public static func runWriter(
        fixture: PrimeTypedOptimizerFixture
    ) throws -> (
        step: PrimeTypedOptimizerStepResult,
        checkpoint: PrimeTypedOptimizerCheckpoint,
        manifest:
            PrimeTypedOptimizerExecutionManifest
    ) {
        try Device.withDefaultDevice(.cpu) {
            let model = try makeModel(
                fixture: fixture
            )
            let optimizer = makeOptimizer()
            let first = try runStep(
                model: model,
                optimizer: optimizer,
                batch:
                    batches(fixture: fixture)
                    .first,
                fixture: fixture,
                stepIndex: 1
            )
            let checkpoint =
                try makeCheckpoint(from: first)
            return (
                first,
                checkpoint,
                try makeManifest(
                    role: .writer,
                    fixture: fixture,
                    steps: first.entries
                )
            )
        }
    }

    public static func restore(
        checkpoint: PrimeTypedOptimizerCheckpoint
    ) throws -> (
        model: PrimeTypedOptimizerModel,
        optimizer: AdamW
    ) {
        try Device.withDefaultDevice(.cpu) {
            let model = try makeModel(
                fixture: checkpoint.fixture,
                perturbed: true
            )
            try model.update(
                parameters:
                    checkpoint.modelParameters
            )
            let optimizer = makeOptimizer()
            try optimizer.update(
                parameters:
                    checkpoint.optimizerState,
                matching:
                    model.trainableParameters()
            )
            let observedState =
                try snapshot(
                    optimizer.parameters()
                )
            try requireExact(
                observedState.firstMoment,
                checkpoint.optimizerState
                    .firstMoment,
                scope: "restored first moment"
            )
            try requireExact(
                observedState.secondMoment,
                checkpoint.optimizerState
                    .secondMoment,
                scope: "restored second moment"
            )
            try requireExact(
                model.parameters(),
                checkpoint.modelParameters,
                scope: "restored model"
            )
            return (model, optimizer)
        }
    }

    public static func runRestorer(
        checkpoint: PrimeTypedOptimizerCheckpoint
    ) throws -> PrimeTypedOptimizerTrajectory {
        try Device.withDefaultDevice(.cpu) {
            let restored = try restore(
                checkpoint: checkpoint
            )
            let stateEntries =
                try checkpointEntries(
                    checkpoint: checkpoint
                )
            let second = try runStep(
                model: restored.model,
                optimizer: restored.optimizer,
                batch:
                    batches(
                        fixture:
                            checkpoint.fixture
                    ).second,
                fixture: checkpoint.fixture,
                stepIndex: 2
            )
            try requireStateProgress(
                from: stateEntries,
                to: second.entries
            )
            return PrimeTypedOptimizerTrajectory(
                first: stateEntries,
                second: second,
                manifest: try makeManifest(
                    role: .restorer,
                    fixture:
                        checkpoint.fixture,
                    steps:
                        stateEntries
                        + second.entries
                )
            )
        }
    }

    public static func rehydrateCheckpoint(
        fixture: PrimeTypedOptimizerFixture,
        modelArrays: [String: MLXArray],
        optimizerArrays: [String: MLXArray],
        writerManifest:
            PrimeTypedOptimizerExecutionManifest
    ) throws -> PrimeTypedOptimizerCheckpoint {
        try writerManifest.validate()
        guard writerManifest.workerRole == .writer,
              writerManifest.fixture == fixture else {
            throw PrimeTypedOptimizerMechanicsError
                .tensorMismatch(
                    "writer manifest role or fixture"
                )
        }
        let checkpointEntries =
            writerManifest.entries.filter {
                $0.role == .modelParameter
                    || $0.role == .firstMoment
                    || $0.role == .secondMoment
            }
        var storageKeys = Set<String>()
        for entry in checkpointEntries {
            guard let key = entry.storageKey,
                  storageKeys.insert(key).inserted
            else {
                throw PrimeTypedOptimizerMechanicsError
                    .duplicateCheckpointStorageKey(
                        entry.storageKey ?? "<missing>"
                    )
            }
        }

        let expectedModelKeys = checkpointEntries
            .filter { $0.role == .modelParameter }
            .compactMap(\.storageKey)
            .sorted()
        let expectedOptimizerKeys =
            checkpointEntries.filter {
                $0.role == .firstMoment
                    || $0.role == .secondMoment
            }.compactMap(\.storageKey).sorted()
        try requireKeys(
            observed: modelArrays.keys.sorted(),
            expected: expectedModelKeys
        )
        try requireKeys(
            observed:
                optimizerArrays.keys.sorted(),
            expected: expectedOptimizerKeys
        )

        var modelByPath =
            [String: MLXArray]()
        var firstByPath =
            [String: MLXArray]()
        var secondByPath =
            [String: MLXArray]()
        for entry in checkpointEntries {
            let arrays =
                entry.role == .modelParameter
                ? modelArrays : optimizerArrays
            guard let key = entry.storageKey,
                  let array = arrays[key] else {
                throw PrimeTypedOptimizerMechanicsError
                    .tensorMismatch(
                        entry.storageKey ?? entry.path
                    )
            }
            try requireExact(
                array: array,
                record: entry
            )
            switch entry.role {
            case .modelParameter:
                modelByPath[entry.path] =
                    snapshot(array)
            case .firstMoment:
                firstByPath[entry.path] =
                    snapshot(array)
            case .secondMoment:
                secondByPath[entry.path] =
                    snapshot(array)
            case .loss, .output, .gradient:
                throw PrimeTypedOptimizerMechanicsError
                    .tensorMismatch(entry.path)
            }
        }

        let checkpoint =
            PrimeTypedOptimizerCheckpoint(
                fixture: fixture,
                stepIndex: 1,
                modelParameters:
                    ModuleParameters
                    .unflattened(modelByPath),
                optimizerState:
                    AdamOptimizerState(
                        firstMoment:
                            ModuleParameters
                            .unflattened(
                                firstByPath
                            ),
                        secondMoment:
                            ModuleParameters
                            .unflattened(
                                secondByPath
                            )
                    ),
                modelStoragePairs:
                    expectedModelKeys.map {
                        ($0, modelArrays[$0]!)
                    },
                optimizerStoragePairs:
                    expectedOptimizerKeys.map {
                        ($0, optimizerArrays[$0]!)
                    }
            )
        try requireExpectedPaths(
            checkpoint.modelParameters,
            fixture: fixture
        )
        try requireExpectedPaths(
            checkpoint.optimizerState
                .firstMoment,
            fixture: fixture
        )
        try requireExpectedPaths(
            checkpoint.optimizerState
                .secondMoment,
            fixture: fixture
        )
        return checkpoint
    }

    public static func mutatedState(
        _ state: AdamOptimizerState,
        fixture: PrimeTypedOptimizerFixture,
        mutation:
            PrimeTypedOptimizerStateMutation
    ) throws -> AdamOptimizerState {
        var first = try uniqueCatalog(
            state.firstMoment
        )
        var second = try uniqueCatalog(
            state.secondMoment
        )
        switch mutation {
        case .momentsSwapped:
            return AdamOptimizerState(
                firstMoment:
                    ModuleParameters.unflattened(
                        second
                    ),
                secondMoment:
                    ModuleParameters.unflattened(
                        first
                    )
            )

        case .sameShapePathSwap:
            guard fixture == .nestedSameShape else {
                throw PrimeTypedOptimizerMechanicsError
                    .unsupportedStateMutation
            }
            let firstPath = "layers.0.weight"
            let secondPath = "layers.1.weight"
            let firstValue = first[firstPath]!
            first[firstPath] = first[secondPath]!
            first[secondPath] = firstValue

        case .missingFirstMoment:
            first.removeValue(
                forKey: fixture.trainablePaths[0]
            )

        case .extraSecondMoment:
            second["extra.weight"] =
                MLXArray.zeros([2, 2])

        case .firstMomentShapeMismatch:
            let path = fixture.trainablePaths
                .first {
                    $0.hasSuffix("weight")
                }!
            first[path] = MLXArray.zeros([4])

        case .secondMomentDTypeMismatch:
            let path = fixture.trainablePaths
                .first!
            second[path] =
                second[path]!.asType(.float16)
        }
        return AdamOptimizerState(
            firstMoment:
                ModuleParameters.unflattened(first),
            secondMoment:
                ModuleParameters.unflattened(
                    second
                )
        )
    }

    public static func verifyNonemptyImportRejected(
        fixture: PrimeTypedOptimizerFixture
    ) throws {
        try Device.withDefaultDevice(.cpu) {
            let writer = try runWriter(
                fixture: fixture
            )
            let optimizer = makeOptimizer()
            let model = try makeModel(
                fixture: fixture
            )
            let firstBatch =
                batches(fixture: fixture).first
            _ = try runStep(
                model: model,
                optimizer: optimizer,
                batch: firstBatch,
                fixture: fixture,
                stepIndex: 1
            )
            do {
                try optimizer.update(
                    parameters:
                        writer.checkpoint
                        .optimizerState,
                    matching:
                        model.trainableParameters()
                )
            } catch AdamOptimizerStateError
                .optimizerAlreadyInitialized {
                return
            }
            throw PrimeTypedOptimizerMechanicsError
                .expectedImportRejection
        }
    }

    private static func makeCheckpoint(
        from step:
            PrimeTypedOptimizerStepResult
    ) throws -> PrimeTypedOptimizerCheckpoint {
        let modelCatalog = try uniqueCatalog(
            step.modelParameters
        )
        let firstCatalog = try uniqueCatalog(
            step.optimizerState.firstMoment
        )
        let secondCatalog = try uniqueCatalog(
            step.optimizerState.secondMoment
        )
        let modelPairs = step.fixture
            .trainablePaths.map { path in
                (
                    storageKey(
                        role: .modelParameter,
                        path: path
                    ),
                    snapshot(modelCatalog[path]!)
                )
            }
        let optimizerPairs =
            step.fixture.trainablePaths.flatMap {
                path in
                [
                    (
                        storageKey(
                            role: .firstMoment,
                            path: path
                        ),
                        snapshot(
                            firstCatalog[path]!
                        )
                    ),
                    (
                        storageKey(
                            role: .secondMoment,
                            path: path
                        ),
                        snapshot(
                            secondCatalog[path]!
                        )
                    ),
                ]
            }.sorted { $0.0 < $1.0 }
        return PrimeTypedOptimizerCheckpoint(
            fixture: step.fixture,
            stepIndex: step.stepIndex,
            modelParameters:
                snapshot(step.modelParameters),
            optimizerState:
                try snapshot(step.optimizerState),
            modelStoragePairs:
                modelPairs.sorted {
                    $0.0 < $1.0
                },
            optimizerStoragePairs:
                optimizerPairs
        )
    }

    private static func checkpointEntries(
        checkpoint:
            PrimeTypedOptimizerCheckpoint
    ) throws
        -> [PrimeTypedOptimizerTensorEntry]
    {
        let model = try uniqueCatalog(
            checkpoint.modelParameters
        )
        let first = try uniqueCatalog(
            checkpoint.optimizerState
                .firstMoment
        )
        let second = try uniqueCatalog(
            checkpoint.optimizerState
                .secondMoment
        )
        var entries =
            [PrimeTypedOptimizerTensorEntry]()
        for path in checkpoint.fixture
            .trainablePaths
        {
            entries.append(
                try exactRecord(
                    fixture: checkpoint.fixture,
                    stepIndex:
                        checkpoint.stepIndex,
                    role: .modelParameter,
                    path: path,
                    array: model[path]!
                )
            )
            entries.append(
                try exactRecord(
                    fixture: checkpoint.fixture,
                    stepIndex:
                        checkpoint.stepIndex,
                    role: .firstMoment,
                    path: path,
                    array: first[path]!
                )
            )
            entries.append(
                try exactRecord(
                    fixture: checkpoint.fixture,
                    stepIndex:
                        checkpoint.stepIndex,
                    role: .secondMoment,
                    path: path,
                    array: second[path]!
                )
            )
        }
        return entries.sorted {
            entryIdentity($0) < entryIdentity($1)
        }
    }

    private static func makeEntries(
        fixture: PrimeTypedOptimizerFixture,
        stepIndex: Int,
        loss: MLXArray,
        output: MLXArray,
        gradients: ModuleParameters,
        modelParameters: ModuleParameters,
        optimizerState: AdamOptimizerState
    ) throws
        -> [PrimeTypedOptimizerTensorEntry]
    {
        var entries = [
            try exactRecord(
                fixture: fixture,
                stepIndex: stepIndex,
                role: .loss,
                path: "loss",
                array: loss
            ),
            try exactRecord(
                fixture: fixture,
                stepIndex: stepIndex,
                role: .output,
                path: "output",
                array: output
            ),
        ]
        let gradientCatalog =
            try uniqueCatalog(gradients)
        let modelCatalog =
            try uniqueCatalog(modelParameters)
        let firstCatalog = try uniqueCatalog(
            optimizerState.firstMoment
        )
        let secondCatalog = try uniqueCatalog(
            optimizerState.secondMoment
        )
        for path in fixture.trainablePaths {
            entries.append(
                try exactRecord(
                    fixture: fixture,
                    stepIndex: stepIndex,
                    role: .gradient,
                    path: path,
                    array: gradientCatalog[path]!
                )
            )
            entries.append(
                try exactRecord(
                    fixture: fixture,
                    stepIndex: stepIndex,
                    role: .modelParameter,
                    path: path,
                    array: modelCatalog[path]!
                )
            )
            entries.append(
                try exactRecord(
                    fixture: fixture,
                    stepIndex: stepIndex,
                    role: .firstMoment,
                    path: path,
                    array: firstCatalog[path]!
                )
            )
            entries.append(
                try exactRecord(
                    fixture: fixture,
                    stepIndex: stepIndex,
                    role: .secondMoment,
                    path: path,
                    array: secondCatalog[path]!
                )
            )
        }
        return entries.sorted {
            entryIdentity($0) < entryIdentity($1)
        }
    }

    private static func exactRecord(
        fixture: PrimeTypedOptimizerFixture,
        stepIndex: Int,
        role: PrimeTypedOptimizerTensorRole,
        path: String,
        array: MLXArray
    ) throws -> PrimeTypedOptimizerTensorEntry {
        try checkedEval(array)
        guard array.dtype == .float32 else {
            throw PrimeTypedOptimizerMechanicsError
                .tensorMismatch(path)
        }
        let logical =
            array.asData(access: .copy)
        guard logical.shape == array.shape,
              logical.dType == array.dtype,
              logical.data.count
                == array.size * 4
        else {
            throw PrimeTypedOptimizerMechanicsError
                .tensorMismatch(path)
        }
        guard array.asArray(Float.self)
            .allSatisfy(\.isFinite) else {
            throw PrimeTypedOptimizerMechanicsError
                .nonFiniteTensor(
                    "\(role.rawValue).\(path)"
                )
        }
        return PrimeTypedOptimizerTensorEntry(
            fixture: fixture,
            stepIndex: stepIndex,
            role: role,
            path: path,
            storageKey:
                role == .modelParameter
                    || role == .firstMoment
                    || role == .secondMoment
                ? storageKey(
                    role: role,
                    path: path
                ) : nil,
            dtype: "float32",
            shape: array.shape,
            byteCount:
                UInt64(logical.data.count),
            logicalSHA256:
                PrimeSHA256.hexDigest(
                    of: logical.data
                )
        )
    }

    private static func requireExact(
        array: MLXArray,
        record:
            PrimeTypedOptimizerTensorEntry
    ) throws {
        let observed = try exactRecord(
            fixture: record.fixture,
            stepIndex: record.stepIndex,
            role: record.role,
            path: record.path,
            array: array
        )
        guard observed == record else {
            throw PrimeTypedOptimizerMechanicsError
                .tensorMismatch(record.path)
        }
    }

    private static func requireExact(
        _ lhs: ModuleParameters,
        _ rhs: ModuleParameters,
        scope: String
    ) throws {
        let left = try uniqueCatalog(lhs)
        let right = try uniqueCatalog(rhs)
        guard left.keys.sorted()
                == right.keys.sorted() else {
            throw PrimeTypedOptimizerMechanicsError
                .tensorMismatch(scope)
        }
        for path in left.keys.sorted() {
            let lhsArray = left[path]!
            let rhsArray = right[path]!
            try checkedEval(lhsArray, rhsArray)
            guard lhsArray.shape == rhsArray.shape,
                  lhsArray.dtype == rhsArray.dtype,
                  lhsArray
                    .asData(access: .copy).data
                    == rhsArray
                    .asData(access: .copy).data else {
                throw PrimeTypedOptimizerMechanicsError
                    .tensorMismatch(
                        "\(scope).\(path)"
                    )
            }
        }
    }

    private static func requireExpectedPaths(
        _ parameters: ModuleParameters,
        fixture: PrimeTypedOptimizerFixture
    ) throws {
        let observed = try uniqueCatalog(
            parameters
        ).keys.sorted()
        guard observed == fixture.trainablePaths else {
            throw PrimeTypedOptimizerMechanicsError
                .unexpectedParameterPaths(
                    expected:
                        fixture.trainablePaths,
                    observed: observed
                )
        }
    }

    private static func requireEveryTensorChanged(
        from before: ModuleParameters,
        to after: ModuleParameters,
        scope: String
    ) throws {
        let beforeCatalog =
            try uniqueCatalog(before)
        let afterCatalog =
            try uniqueCatalog(after)
        guard beforeCatalog.keys.sorted()
                == afterCatalog.keys.sorted() else {
            throw PrimeTypedOptimizerMechanicsError
                .tensorMismatch(
                    "\(scope) path set changed"
                )
        }
        for path in beforeCatalog.keys.sorted() {
            let prior = beforeCatalog[path]!
            let current = afterCatalog[path]!
            try checkedEval(prior, current)
            guard prior.shape == current.shape,
                  prior.dtype == current.dtype,
                  prior.asData(access: .copy).data
                    != current
                    .asData(access: .copy).data else {
                throw PrimeTypedOptimizerMechanicsError
                    .tensorMismatch(
                        "\(scope).\(path) did not change"
                    )
            }
        }
    }

    private static func requireEveryTensorNonzero(
        _ parameters: ModuleParameters,
        scope: String
    ) throws {
        for (path, array) in
            try uniqueCatalog(parameters)
        {
            try checkedEval(array)
            let values = array.asArray(Float.self)
            guard values.allSatisfy(\.isFinite),
                  values.contains(where: {
                      $0 != 0
                  }) else {
                throw PrimeTypedOptimizerMechanicsError
                    .tensorMismatch(
                        "\(scope).\(path) is zero or nonfinite"
                    )
            }
        }
    }

    private static func requireFiniteNonzeroGradients(
        _ gradients: ModuleParameters
    ) throws {
        for (path, gradient) in
            try uniqueCatalog(gradients)
        {
            try checkedEval(gradient)
            let values =
                gradient.asArray(Float.self)
            guard values.allSatisfy(\.isFinite),
                  values.contains(where: {
                      $0 != 0
                  }) else {
                throw PrimeTypedOptimizerMechanicsError
                    .gradientWasZeroOrNonfinite(
                        path
                    )
            }
        }
    }

    private static func requireStateProgress(
        from first:
            [PrimeTypedOptimizerTensorEntry],
        to second:
            [PrimeTypedOptimizerTensorEntry]
    ) throws {
        let roles:
            Set<PrimeTypedOptimizerTensorRole> = [
                .modelParameter,
                .firstMoment,
                .secondMoment,
            ]
        let firstState = first.filter {
            roles.contains($0.role)
        }
        let secondState = second.filter {
            roles.contains($0.role)
        }
        let firstByIdentity = Dictionary(
            uniqueKeysWithValues:
                firstState.map {
                    (
                        "\($0.role.rawValue)\u{1f}\($0.path)",
                        $0.logicalSHA256
                    )
                }
        )
        let secondByIdentity = Dictionary(
            uniqueKeysWithValues:
                secondState.map {
                    (
                        "\($0.role.rawValue)\u{1f}\($0.path)",
                        $0.logicalSHA256
                    )
                }
        )
        guard firstByIdentity.keys.sorted()
                == secondByIdentity.keys.sorted(),
              firstByIdentity.contains(where: {
                  secondByIdentity[$0.key]
                      != $0.value
              }) else {
            throw PrimeTypedOptimizerMechanicsError
                .stateDidNotProgress
        }
    }

    private static func requireKeys(
        observed: [String],
        expected: [String]
    ) throws {
        guard observed == expected else {
            throw PrimeTypedOptimizerMechanicsError
                .checkpointKeyMismatch(
                    expected: expected,
                    observed: observed
                )
        }
    }

    private static func requireCPUDefault()
        throws
    {
        let device = Device.defaultDevice()
        let stream =
            StreamOrDevice.default.description
        guard device.deviceType == .cpu,
              stream.lowercased()
                .contains("cpu") else {
            throw PrimeTypedOptimizerMechanicsError
                .nonCPUExecution(
                    "device=\(device) stream=\(stream)"
                )
        }
    }

    private static func uniqueCatalog(
        _ parameters: ModuleParameters
    ) throws -> [String: MLXArray] {
        var result = [String: MLXArray]()
        for (path, array) in
            parameters.flattened()
        {
            guard result.updateValue(
                array,
                forKey: path
            ) == nil else {
                throw PrimeTypedOptimizerMechanicsError
                    .tensorMismatch(
                        "duplicate path \(path)"
                    )
            }
        }
        return result
    }

    private static func snapshot(
        _ parameters: ModuleParameters
    ) -> ModuleParameters {
        parameters.mapValues {
            snapshot($0)
        }
    }

    private static func snapshot(
        _ state: AdamOptimizerState
    ) throws -> AdamOptimizerState {
        let result = AdamOptimizerState(
            firstMoment:
                snapshot(state.firstMoment),
            secondMoment:
                snapshot(state.secondMoment)
        )
        try checkedEval(
            result.firstMoment,
            result.secondMoment
        )
        return result
    }

    private static func snapshot(
        _ array: MLXArray
    ) -> MLXArray {
        array.reshaped(array.shape)
    }

    private static func storageKey(
        role: PrimeTypedOptimizerTensorRole,
        path: String
    ) -> String {
        "\(role.rawValue).\(path)"
    }

    private static func entryIdentity(
        _ entry:
            PrimeTypedOptimizerTensorEntry
    ) -> String {
        let order: Int
        switch entry.role {
        case .loss: order = 0
        case .output: order = 1
        case .gradient: order = 2
        case .modelParameter: order = 3
        case .firstMoment: order = 4
        case .secondMoment: order = 5
        }
        return [
            entry.fixture.rawValue,
            String(entry.stepIndex),
            String(order),
            entry.path,
        ].joined(separator: "\u{1f}")
    }
}
