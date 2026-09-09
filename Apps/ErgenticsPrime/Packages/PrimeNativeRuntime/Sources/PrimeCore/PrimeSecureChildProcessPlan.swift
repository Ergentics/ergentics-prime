// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

/// A closed, non-serializable plan for the first-party validation fixture.
///
/// The plan deliberately carries no executable, descriptor, arbitrary
/// argument, arbitrary environment, or caller-selected resource bound. Those
/// capabilities remain in the fixture adapter's prepared context.
final class PrimeSecureChildProcessPlanV1: @unchecked Sendable {
    enum StandardInputPolicy: Equatable, Sendable {
        case devNull
    }

    let validationWorkflowFixtureMode:
        PrimeValidationWorkflowFixtureChildMode
    let maximumWallNanoseconds: UInt64
    let standardOutputMaximumByteCount: UInt64
    let standardErrorMaximumByteCount: UInt64
    let standardInputPolicy: StandardInputPolicy
    let orderedEnvironment: [(String, String)]

    private init(
        validationWorkflowFixtureMode:
            PrimeValidationWorkflowFixtureChildMode,
        maximumWallNanoseconds: UInt64
    ) {
        self.validationWorkflowFixtureMode =
            validationWorkflowFixtureMode
        self.maximumWallNanoseconds = maximumWallNanoseconds
        standardOutputMaximumByteCount =
            PrimeSecureChildFixtureInvocation.streamPrefixLimit
        standardErrorMaximumByteCount =
            PrimeSecureChildFixtureInvocation.streamPrefixLimit
        standardInputPolicy = .devNull
        orderedEnvironment = []
    }

    static func validationWorkflowFixture(
        mode: PrimeValidationWorkflowFixtureChildMode
    ) throws -> PrimeSecureChildProcessPlanV1 {
        let maximumWallNanoseconds: UInt64
        switch mode {
        case .hang, .descendantRetainsStreams:
            maximumWallNanoseconds = 1_000_000_000
        case .pass, .logicalArgumentZero, .nonzeroExit,
             .boundedStreams, .overflow, .selfSignal,
             .exitWithoutResult:
            maximumWallNanoseconds = 10_000_000_000
        }
        guard maximumWallNanoseconds > 0,
              maximumWallNanoseconds <= 10_000_000_000,
              PrimeSecureChildFixtureInvocation.streamPrefixLimit > 0,
              PrimeSecureChildFixtureInvocation.streamPrefixLimit
                <= 65_536
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_plan_bounds")
        }
        return PrimeSecureChildProcessPlanV1(
            validationWorkflowFixtureMode: mode,
            maximumWallNanoseconds: maximumWallNanoseconds
        )
    }

    func argumentZero(
        physicalExecutableAbsolutePath: String
    ) throws -> String {
        let value = validationWorkflowFixtureMode
            == .logicalArgumentZero
            ? PrimeSecureChildArgumentZeroPolicy.swiftBuildCanaryValue
            : physicalExecutableAbsolutePath
        try PrimeSecureChildDarwinSubstrate.requireArgumentZero(value)
        guard validationWorkflowFixtureMode == .logicalArgumentZero
                || Self.isCanonicalAbsolutePath(
                    physicalExecutableAbsolutePath
                )
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_executable_path")
        }
        return value
    }

    func exactArguments(
        resultAbsolutePath: String
    ) throws -> [String] {
        let mode = validationWorkflowFixtureMode
        let expectsResult = mode != .exitWithoutResult
        if expectsResult {
            try Self.requireResultPath(resultAbsolutePath)
        } else if !resultAbsolutePath.isEmpty {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("unexpected_fixture_result_path")
        }

        var arguments = ["--mode", mode.rawValue]
        if expectsResult {
            arguments += ["--result-path", resultAbsolutePath]
        }
        switch mode {
        case .nonzeroExit:
            arguments += ["--exit-code", "23"]
        case .boundedStreams:
            arguments += [
                "--stdout-bytes", "4096",
                "--stderr-bytes", "2048",
            ]
        case .overflow:
            arguments += [
                "--stdout-bytes", "131072",
                "--stderr-bytes", "131072",
            ]
        case .pass, .logicalArgumentZero, .hang, .selfSignal,
             .descendantRetainsStreams, .exitWithoutResult:
            break
        }
        guard arguments.count <= 10,
              arguments.count.isMultiple(of: 2),
              orderedEnvironment.isEmpty
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_plan_shape")
        }
        return arguments
    }

    private static func requireResultPath(_ path: String) throws {
        guard isCanonicalAbsolutePath(path),
              path != "/",
              !path.hasSuffix("/")
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_result_path")
        }
    }

    private static func isCanonicalAbsolutePath(_ path: String) -> Bool {
        path.hasPrefix("/")
            && path.utf8.count <= 4_096
            && path.utf8.allSatisfy { $0 >= 0x21 && $0 <= 0x7e }
            && !path.contains("\\")
            && !path.contains("//")
            && !path.split(separator: "/").contains(".")
            && !path.split(separator: "/").contains("..")
    }
}
