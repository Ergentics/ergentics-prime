// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: MIT

import MLX
import MLXNN

/// Identifies one of the two per-parameter tensors maintained by ``Adam`` and
/// ``AdamW``.
public enum AdamMoment: String, Equatable, Sendable {
    case first
    case second
}

/// A named, typed snapshot of the per-parameter state maintained by ``Adam``
/// and ``AdamW``.
///
/// Optimizer configuration such as the learning rate, betas, epsilon, and
/// weight decay is not part of this value. Callers must checkpoint and restore
/// that configuration separately.
public struct AdamOptimizerState {
    public let firstMoment: ModuleParameters
    public let secondMoment: ModuleParameters

    public init(
        firstMoment: ModuleParameters,
        secondMoment: ModuleParameters
    ) {
        self.firstMoment = firstMoment
        self.secondMoment = secondMoment
    }
}

/// Errors produced while exporting or importing ``AdamOptimizerState``.
public enum AdamOptimizerStateError: Error, Equatable, Sendable {
    case optimizerAlreadyInitialized
    case emptyTargetParameters
    case emptyState
    case duplicatePath(moment: AdamMoment?, path: String)
    case missingPath(moment: AdamMoment, path: String)
    case extraPath(moment: AdamMoment, path: String)
    case topologyMismatch(path: String)
    case shapeMismatch(
        moment: AdamMoment,
        path: String,
        expected: [Int],
        actual: [Int]
    )
    case dtypeMismatch(
        moment: AdamMoment,
        path: String,
        expected: DType,
        actual: DType
    )
}

private func statePath(
    _ path: String,
    appending component: String
) -> String {
    path.isEmpty ? component : "\(path).\(component)"
}

private func displayPath(_ path: String) -> String {
    path.isEmpty ? "<root>" : path
}

private func isolatedArrayReference(
    _ array: MLXArray
) -> MLXArray {
    // MLXArray is a reference type and compiled functions update captured state
    // through _updateInternal. A shape-preserving view has identical logical
    // tensor values but a distinct Swift wrapper, so a later context replacement
    // cannot mutate the exported snapshot or the caller's imported value.
    array.reshaped(array.shape)
}

private func catalog(
    _ parameters: ModuleParameters,
    moment: AdamMoment?
) throws -> [String: MLXArray] {
    var result = [String: MLXArray]()
    for (path, array) in parameters.flattened() {
        guard result.updateValue(array, forKey: path) == nil else {
            throw AdamOptimizerStateError.duplicatePath(
                moment: moment,
                path: path
            )
        }
    }
    return result
}

private func validateCatalogs(
    state: AdamOptimizerState,
    matching target: ModuleParameters
) throws {
    let targetCatalog = try catalog(target, moment: nil)
    guard !targetCatalog.isEmpty else {
        throw AdamOptimizerStateError.emptyTargetParameters
    }

    let firstCatalog = try catalog(
        state.firstMoment,
        moment: .first
    )
    let secondCatalog = try catalog(
        state.secondMoment,
        moment: .second
    )
    guard !(firstCatalog.isEmpty && secondCatalog.isEmpty) else {
        throw AdamOptimizerStateError.emptyState
    }

    let targetPaths = Set(targetCatalog.keys)
    let firstPaths = Set(firstCatalog.keys)
    let secondPaths = Set(secondCatalog.keys)

    if let path = targetPaths.subtracting(firstPaths).sorted().first {
        throw AdamOptimizerStateError.missingPath(
            moment: .first,
            path: path
        )
    }
    if let path = firstPaths.subtracting(targetPaths).sorted().first {
        throw AdamOptimizerStateError.extraPath(
            moment: .first,
            path: path
        )
    }
    if let path = targetPaths.subtracting(secondPaths).sorted().first {
        throw AdamOptimizerStateError.missingPath(
            moment: .second,
            path: path
        )
    }
    if let path = secondPaths.subtracting(targetPaths).sorted().first {
        throw AdamOptimizerStateError.extraPath(
            moment: .second,
            path: path
        )
    }

    for path in targetPaths.sorted() {
        let parameter = targetCatalog[path]!
        let firstMoment = firstCatalog[path]!
        let secondMoment = secondCatalog[path]!

        guard firstMoment.shape == parameter.shape else {
            throw AdamOptimizerStateError.shapeMismatch(
                moment: .first,
                path: path,
                expected: parameter.shape,
                actual: firstMoment.shape
            )
        }
        guard secondMoment.shape == parameter.shape else {
            throw AdamOptimizerStateError.shapeMismatch(
                moment: .second,
                path: path,
                expected: parameter.shape,
                actual: secondMoment.shape
            )
        }
        guard firstMoment.dtype == parameter.dtype else {
            throw AdamOptimizerStateError.dtypeMismatch(
                moment: .first,
                path: path,
                expected: parameter.dtype,
                actual: firstMoment.dtype
            )
        }
        guard secondMoment.dtype == parameter.dtype else {
            throw AdamOptimizerStateError.dtypeMismatch(
                moment: .second,
                path: path,
                expected: parameter.dtype,
                actual: secondMoment.dtype
            )
        }
    }
}

private func makeStateStorage(
    target: NestedItem<String, MLXArray>,
    firstMoment: NestedItem<String, MLXArray>,
    secondMoment: NestedItem<String, MLXArray>,
    path: String = ""
) throws -> NestedItem<String, TupleState> {
    switch (target, firstMoment, secondMoment) {
    case (
        .none,
        .none,
        .none
    ):
        return .none

    case (
        .value,
        .value(let first),
        .value(let second)
    ):
        return .value(
            TupleState(
                isolatedArrayReference(first),
                isolatedArrayReference(second)
            )
        )

    case (
        .array(let targetValues),
        .array(let firstValues),
        .array(let secondValues)
    ):
        guard targetValues.count == firstValues.count,
            targetValues.count == secondValues.count
        else {
            throw AdamOptimizerStateError.topologyMismatch(
                path: displayPath(path)
            )
        }
        return .array(
            try targetValues.indices.map { index in
                try makeStateStorage(
                    target: targetValues[index],
                    firstMoment: firstValues[index],
                    secondMoment: secondValues[index],
                    path: statePath(
                        path,
                        appending: String(index)
                    )
                )
            }
        )

    case (
        .dictionary(let targetValues),
        .dictionary(let firstValues),
        .dictionary(let secondValues)
    ):
        let targetKeys = Set(targetValues.keys)
        guard targetKeys == Set(firstValues.keys),
            targetKeys == Set(secondValues.keys)
        else {
            throw AdamOptimizerStateError.topologyMismatch(
                path: displayPath(path)
            )
        }

        var result =
            [String: NestedItem<String, TupleState>]()
        for key in targetKeys.sorted() {
            result[key] = try makeStateStorage(
                target: targetValues[key]!,
                firstMoment: firstValues[key]!,
                secondMoment: secondValues[key]!,
                path: statePath(path, appending: key)
            )
        }
        return .dictionary(result)

    default:
        throw AdamOptimizerStateError.topologyMismatch(
            path: displayPath(path)
        )
    }
}

extension Adam {
    /// Return an evaluated, named snapshot of the optimizer's first and second
    /// moments.
    ///
    /// The optimizer must have completed at least one update.
    public func parameters() throws -> AdamOptimizerState {
        guard !stateStorage.flattened().isEmpty else {
            throw AdamOptimizerStateError.emptyState
        }

        let firstMoment = stateStorage.mapValues {
            isolatedArrayReference($0.values.0)
        }
        let secondMoment = stateStorage.mapValues {
            isolatedArrayReference($0.values.1)
        }

        _ = try catalog(firstMoment, moment: .first)
        _ = try catalog(secondMoment, moment: .second)
        try checkedEval(firstMoment, secondMoment)

        return AdamOptimizerState(
            firstMoment: firstMoment,
            secondMoment: secondMoment
        )
    }

    /// Replace an uninitialized optimizer's moments with a named snapshot after
    /// validating it against the target model's trainable parameter topology.
    ///
    /// Pass the exact `Module.trainableParameters()` tree that the optimizer
    /// will update. Import is intentionally strict and cannot replace existing
    /// optimizer state.
    public func update(
        parameters state: AdamOptimizerState,
        matching modelParameters: ModuleParameters
    ) throws {
        guard stateStorage.flattened().isEmpty else {
            throw AdamOptimizerStateError
                .optimizerAlreadyInitialized
        }

        try validateCatalogs(
            state: state,
            matching: modelParameters
        )
        let item = try makeStateStorage(
            target: modelParameters.asItem(),
            firstMoment: state.firstMoment.asItem(),
            secondMoment: state.secondMoment.asItem()
        )
        let replacement =
            NestedDictionary<String, TupleState>(item: item)
        try checkedEval(
            replacement.flattenedValues().flatMap {
                $0.innerState()
            }
        )

        stateStorage = replacement
    }
}
