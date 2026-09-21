// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore

public enum PrimeValidationXCTestTerminal:
    String,
    Codable,
    Equatable,
    Sendable
{
    case passed
    case failed
    case skipped
}

public struct PrimeValidationXCTestSkip:
    Codable,
    Equatable,
    Sendable
{
    public let rawID: String
    public let exactReason: String
}

/// The exact XCTest top-level frame expected by a known invocation. Selecting
/// a mode never supplies test IDs, process facts, or permission to execute.
public enum PrimeValidationXCTestTopLevelSuite: String, Sendable {
    case allTests = "All tests"
    case selectedTests = "Selected tests"
}

private enum PrimeValidationTopLevelXCTestEvent {

    case started
    case passed
    case failed
}

public struct PrimeValidationSequentialXCTestObservation:
    Codable,
    Equatable,
    Sendable
{
    private static let maximumTranscriptBytes = 128 * 1024 * 1024
    private static let maximumLineBytes = 64 * 1024
    private static let maximumTestCount = 1_000_000
    private static let maximumSkipReasonBytes = 2 * 1024

    public let contentBinding: PrimeValidationContentBinding
    public let observedRawIDs: [String]
    public let passedRawIDs: [String]
    public let failedRawIDs: [String]
    public let skips: [PrimeValidationXCTestSkip]
    public let declaredExecutedCount: Int
    public let declaredSkippedCount: Int
    public let declaredFailureCount: Int
    public let declaredUnexpectedFailureCount: Int

    public var skippedRawIDs: [String] {
        skips.map(\.rawID)
    }

    public static func parse(_ data: Data,
        expectedTopLevelSuite: PrimeValidationXCTestTopLevelSuite = .allTests
    ) throws -> Self {
        guard data.count <= maximumTranscriptBytes,
              !data.contains(0),
              !data.contains(13),
              !data.contains(27),
              let source = String(data: data, encoding: .utf8)
        else {
            throw PrimeValidationContractError.invalidUTF8
        }

        var active: String?
        var activeSkipReason: String?
        var terminals: [String: PrimeValidationXCTestTerminal] = [:]
        var skipReasons: [String: String] = [:]
        var started = Set<String>()
        var topLevelStartObserved = false
        var topLevelTerminal: PrimeValidationTopLevelXCTestEvent?
        var topLevelTerminalLine = -1
        var topLevelSummary: (
            line: Int,
            executed: Int,
            skipped: Int,
            failures: Int,
            unexpected: Int
        )?
        var lastEventLine = -1

        for (lineIndex, line) in source.components(separatedBy: "\n")
            .enumerated()
        {
            guard line.utf8.count <= maximumLineBytes else {
                throw PrimeValidationContractError.invalidListFraming
            }
            if let suiteEvent = try parseTopLevelSuiteEvent(line, expected: expectedTopLevelSuite) {
                switch suiteEvent {
                case .started:
                    guard !topLevelStartObserved,
                          topLevelTerminal == nil,
                          started.isEmpty
                    else {
                        throw PrimeValidationContractError
                            .unknownTransition(line)
                    }
                    topLevelStartObserved = true
                case .passed, .failed:
                    guard topLevelStartObserved,
                          topLevelTerminal == nil,
                          active == nil,
                          !started.isEmpty,
                          started.count == terminals.count
                    else {
                        throw PrimeValidationContractError
                            .unknownTransition(line)
                    }
                    topLevelTerminal = suiteEvent
                    topLevelTerminalLine = lineIndex
                }
            } else if line.hasPrefix("Test Case ") {
                guard topLevelStartObserved,
                      topLevelTerminal == nil,
                      topLevelSummary == nil
                else {
                    throw PrimeValidationContractError
                        .unknownTransition(line)
                }
                let event = try parseEvent(line)
                lastEventLine = lineIndex
                switch event.terminal {
                case nil:
                    guard active == nil else {
                        throw PrimeValidationContractError
                            .interleavedTransition(event.rawID)
                    }
                    guard started.count < maximumTestCount,
                          !started.contains(event.rawID)
                    else {
                        throw PrimeValidationContractError
                            .duplicateTransition(event.rawID)
                    }
                    active = event.rawID
                    activeSkipReason = nil
                    started.insert(event.rawID)
                case let terminal?:
                    guard started.contains(event.rawID) else {
                        throw PrimeValidationContractError
                            .terminalBeforeStart(event.rawID)
                    }
                    guard active == event.rawID else {
                        throw PrimeValidationContractError
                            .unknownTransition(event.rawID)
                    }
                    guard terminals[event.rawID] == nil else {
                        throw PrimeValidationContractError
                            .duplicateTransition(event.rawID)
                    }
                    if terminal == .skipped {
                        guard let activeSkipReason else {
                            throw PrimeValidationContractError
                                .unknownTransition(event.rawID)
                        }
                        skipReasons[event.rawID] = activeSkipReason
                    } else if activeSkipReason != nil {
                        throw PrimeValidationContractError
                            .unknownTransition(event.rawID)
                    }
                    terminals[event.rawID] = terminal
                    active = nil
                    activeSkipReason = nil
                }
            } else if let skip = try parseSkipReasonCandidate(line) {
                guard topLevelTerminal == nil,
                      active == skip.rawID,
                      activeSkipReason == nil
                else {
                    throw PrimeValidationContractError
                        .unknownTransition(skip.rawID)
                }
                activeSkipReason = skip.exactReason
            } else if let summary = try parseSummaryCandidate(line) {
                if topLevelTerminal != nil {
                    guard topLevelSummary == nil else {
                        throw PrimeValidationContractError
                            .terminalSummaryMismatch
                    }
                    topLevelSummary = (
                        lineIndex,
                        summary.executed,
                        summary.skipped,
                        summary.failures,
                        summary.unexpected
                    )
                }
            } else if topLevelTerminal != nil,
                      topLevelSummary == nil,
                      !line.trimmingCharacters(in: .whitespaces).isEmpty
            {
                throw PrimeValidationContractError.missingTerminalSummary
            } else if line.contains("Test Case '-[")
                || line.contains("Test skipped -")
                || line.hasPrefix("Test Suite 'All tests' ")
            {
                throw PrimeValidationContractError.unknownTransition(line)
            }
        }

        if let active {
            throw PrimeValidationContractError.unfinishedTransition(active)
        }
        guard !started.isEmpty,
              started.count == terminals.count,
              topLevelStartObserved,
              let topLevelTerminal,
              let summary = topLevelSummary,
              topLevelTerminalLine > lastEventLine,
              summary.line > topLevelTerminalLine
        else {
            throw PrimeValidationContractError.missingTerminalSummary
        }

        let observed = started.sorted()
        let passed = terminals.compactMap {
            $0.value == .passed ? $0.key : nil
        }.sorted()
        let failed = terminals.compactMap {
            $0.value == .failed ? $0.key : nil
        }.sorted()
        let skips = skipReasons.map {
            PrimeValidationXCTestSkip(
                rawID: $0.key,
                exactReason: $0.value
            )
        }.sorted { $0.rawID < $1.rawID }

        guard summary.executed == observed.count,
              summary.skipped == skips.count,
              summary.failures >= failed.count,
              summary.unexpected <= summary.failures,
              (summary.failures == 0) == failed.isEmpty,
              (topLevelTerminal == .passed) == failed.isEmpty
        else {
            throw PrimeValidationContractError.terminalSummaryMismatch
        }

        let observation = Self(
            contentBinding: .init(data: data),
            observedRawIDs: observed,
            passedRawIDs: passed,
            failedRawIDs: failed,
            skips: skips,
            declaredExecutedCount: summary.executed,
            declaredSkippedCount: summary.skipped,
            declaredFailureCount: summary.failures,
            declaredUnexpectedFailureCount: summary.unexpected
        )
        try observation.validate()
        return observation
    }

    public func validate() throws {
        try contentBinding.validate()
        let observed = Set(observedRawIDs)
        let passed = Set(passedRawIDs)
        let failed = Set(failedRawIDs)
        let skipped = Set(skippedRawIDs)
        guard !observed.isEmpty,
              observedRawIDs == observedRawIDs.sorted(),
              observed.count == observedRawIDs.count,
              passedRawIDs == passedRawIDs.sorted(),
              passed.count == passedRawIDs.count,
              failedRawIDs == failedRawIDs.sorted(),
              failed.count == failedRawIDs.count,
              skippedRawIDs == skippedRawIDs.sorted(),
              skipped.count == skippedRawIDs.count,
              skips.allSatisfy({
                  !$0.exactReason.isEmpty
                      && $0.exactReason
                        == $0.exactReason.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                      && $0.exactReason.utf8.count
                        <= Self.maximumSkipReasonBytes
              }),
              passed.isDisjoint(with: failed),
              passed.isDisjoint(with: skipped),
              failed.isDisjoint(with: skipped),
              passed.union(failed).union(skipped) == observed,
              declaredExecutedCount == observed.count,
              declaredSkippedCount == skipped.count,
              declaredFailureCount >= failed.count,
              declaredUnexpectedFailureCount >= 0,
              declaredUnexpectedFailureCount <= declaredFailureCount,
              (declaredFailureCount == 0) == failed.isEmpty
        else {
            throw PrimeValidationContractError.terminalSummaryMismatch
        }
    }

    private static func parseEvent(
        _ line: String
    ) throws -> (rawID: String, terminal: PrimeValidationXCTestTerminal?) {
        let prefix = "Test Case '-["
        guard line.hasPrefix(prefix),
              let close = line.range(of: "]' "),
              close.upperBound < line.endIndex
        else {
            throw PrimeValidationContractError.unknownTransition(line)
        }
        let identityStart = line.index(
            line.startIndex,
            offsetBy: prefix.count
        )
        let identity = String(line[identityStart..<close.lowerBound])
        guard let separator = identity.lastIndex(of: " "),
              !identity[..<separator].contains(" "),
              !identity[identity.index(after: separator)...].contains(" ")
        else {
            throw PrimeValidationContractError.unknownTransition(line)
        }
        let rawID = String(identity[..<separator])
            + "/"
            + String(identity[identity.index(after: separator)...])
        _ = try PrimeValidationTestID.parse(rawID, framework: .xctest)
        let tail = String(line[close.upperBound...])
        if tail == "started." {
            return (rawID, nil)
        }
        for terminal in [
            PrimeValidationXCTestTerminal.passed,
            .failed,
            .skipped,
        ] {
            let terminalPrefix = terminal.rawValue + " ("
            let suffix = " seconds)."
            if tail.hasPrefix(terminalPrefix), tail.hasSuffix(suffix) {
                let durationStart = tail.index(
                    tail.startIndex,
                    offsetBy: terminalPrefix.count
                )
                let durationEnd = tail.index(
                    tail.endIndex,
                    offsetBy: -suffix.count
                )
                let duration = String(tail[durationStart..<durationEnd])
                guard isNonnegativeDecimal(duration) else {
                    throw PrimeValidationContractError
                        .unknownTransition(line)
                }
                return (rawID, terminal)
            }
        }
        throw PrimeValidationContractError.unknownTransition(line)
    }

    private static func parseTopLevelSuiteEvent(
        _ line: String, expected: PrimeValidationXCTestTopLevelSuite
    ) throws -> PrimeValidationTopLevelXCTestEvent? {
        let prefix = "Test Suite '\(expected.rawValue)' "
        let other = expected == .allTests ? "Selected tests" : "All tests"
        guard !line.hasPrefix("Test Suite '\(other)' ") else {
            throw PrimeValidationContractError.unknownTransition(line)
        }
        guard line.hasPrefix(prefix) else { return nil }
        let tail = String(line.dropFirst(prefix.count))
        let candidates: [(String, PrimeValidationTopLevelXCTestEvent)] = [
            ("started at ", .started),
            ("passed at ", .passed),
            ("failed at ", .failed),
        ]
        for (eventPrefix, event) in candidates
        where tail.hasPrefix(eventPrefix) {
            let timestamp = String(tail.dropFirst(eventPrefix.count))
            guard !timestamp.isEmpty,
                  timestamp.utf8.count <= 256,
                  timestamp.utf8.allSatisfy({
                      $0 >= 0x20 && $0 <= 0x7e
                  })
            else {
                throw PrimeValidationContractError.unknownTransition(line)
            }
            return event
        }
        throw PrimeValidationContractError.unknownTransition(line)
    }

    private static func parseSkipReasonCandidate(
        _ line: String
    ) throws -> PrimeValidationXCTestSkip? {
        let marker = " : Test skipped - "
        guard line.contains("Test skipped -") else { return nil }
        guard let markerRange = line.range(of: marker, options: .backwards),
              line.range(of: marker) == markerRange
        else {
            throw PrimeValidationContractError.unknownTransition(line)
        }
        let prefix = line[..<markerRange.lowerBound]
        guard prefix.hasSuffix("]"),
              let identityStart = prefix.range(of: "-[", options: .backwards),
              prefix[..<identityStart.lowerBound].contains(":"),
              identityStart.upperBound < prefix.index(before: prefix.endIndex)
        else {
            throw PrimeValidationContractError.unknownTransition(line)
        }
        let identityEnd = prefix.index(before: prefix.endIndex)
        let identity = String(prefix[identityStart.upperBound..<identityEnd])
        guard let separator = identity.lastIndex(of: " ") else {
            throw PrimeValidationContractError.unknownTransition(line)
        }
        let rawID = String(identity[..<separator])
            + "/"
            + String(identity[identity.index(after: separator)...])
        _ = try PrimeValidationTestID.parse(rawID, framework: .xctest)
        let reason = String(line[markerRange.upperBound...])
        guard !reason.isEmpty,
              reason == reason.trimmingCharacters(
                  in: .whitespacesAndNewlines
              ),
              reason.utf8.count <= maximumSkipReasonBytes,
              reason.utf8.allSatisfy({ $0 >= 0x20 && $0 <= 0x7e })
        else {
            throw PrimeValidationContractError.unknownTransition(line)
        }
        return .init(rawID: rawID, exactReason: reason)
    }

    private static func parseSummaryCandidate(
        _ line: String
    ) throws -> (executed: Int, skipped: Int, failures: Int, unexpected: Int)? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("Executed ") else { return nil }
        let pattern = #"^Executed ([0-9]+) tests?, with (?:([0-9]+) tests? skipped and )?([0-9]+) failures? \(([0-9]+) unexpected\) in ([0-9]+(?:\.[0-9]+)?) \(([0-9]+(?:\.[0-9]+)?)\) seconds$"#
        let expression = try NSRegularExpression(pattern: pattern)
        guard let match = expression.firstMatch(
            in: trimmed,
            range: NSRange(trimmed.startIndex..., in: trimmed)
        ),
            match.range == NSRange(trimmed.startIndex..., in: trimmed)
        else {
            throw PrimeValidationContractError.terminalSummaryMismatch
        }
        func value(_ group: Int, default defaultValue: Int? = nil) -> Int? {
            let matchRange = match.range(at: group)
            guard matchRange.location != NSNotFound,
                  let range = Range(matchRange, in: trimmed)
            else { return defaultValue }
            guard let parsed = Int(trimmed[range]),
                  parsed >= 0,
                  parsed <= maximumTestCount
            else { return nil }
            return parsed
        }
        guard let executed = value(1),
              let skipped = value(2, default: 0),
              let failures = value(3),
              let unexpected = value(4),
              let firstDurationRange = Range(match.range(at: 5), in: trimmed),
              let secondDurationRange = Range(match.range(at: 6), in: trimmed),
              isNonnegativeDecimal(String(trimmed[firstDurationRange])),
              isNonnegativeDecimal(String(trimmed[secondDurationRange]))
        else {
            throw PrimeValidationContractError.terminalSummaryMismatch
        }
        return (executed, skipped, failures, unexpected)
    }

    private static func isNonnegativeDecimal(_ raw: String) -> Bool {
        guard !raw.isEmpty,
              raw.utf8.count <= 64,
              raw.utf8.allSatisfy({ ($0 >= 48 && $0 <= 57) || $0 == 46 }),
              raw.utf8.filter({ $0 == 46 }).count <= 1,
              raw != ".",
              let value = Decimal(
                string: raw,
                locale: Locale(identifier: "en_US_POSIX")
              ),
              value >= 0
        else { return false }
        return true
    }
}

public struct PrimeValidationInputArtifactSet:
    Codable,
    Equatable,
    Sendable
{
    public static let requiredRoles: Set<PrimeValidationArtifactRole> = [
        .sourceSnapshot,
        .packageLock,
        .testBundle,
        .xctestList,
        .swiftTestingList,
    ]

    public let bindings: [PrimeValidationArtifactBinding]

    public init(bindings: [PrimeValidationArtifactBinding]) {
        self.bindings = bindings.sorted {
            $0.role.rawValue < $1.role.rawValue
        }
    }

    public func binding(
        for role: PrimeValidationArtifactRole
    ) -> PrimeValidationArtifactBinding? {
        bindings.first { $0.role == role }
    }

    public func validate() throws {
        guard bindings.map(\.role.rawValue)
                == bindings.map(\.role.rawValue).sorted(),
              Set(bindings.map(\.role)).count == bindings.count,
              Set(bindings.map(\.relativePath)).count == bindings.count,
              Set(bindings.map(\.role)) == Self.requiredRoles
        else {
            throw PrimeValidationContractError.invalidArtifactSet
        }
        try bindings.forEach { try $0.validate() }
    }
}

public struct PrimeValidationWorkflowPlan:
    Codable,
    Equatable,
    Sendable
{
    public let runID: String
    public let expectedInventorySHA256: String
    public let expectedInputArtifacts: PrimeValidationInputArtifactSet
    public let expectedInvocations: PrimeValidationLaneInvocationSet
    public let optionalSkipPolicySHA256: String
    public let authority: PrimeValidationAuthorityCeiling

    public init(
        runID: String,
        expectedInventorySHA256: String,
        expectedInputArtifacts: PrimeValidationInputArtifactSet,
        expectedInvocations: PrimeValidationLaneInvocationSet,
        optionalSkipPolicySHA256: String,
        authority: PrimeValidationAuthorityCeiling = .frozenV1
    ) {
        self.runID = runID
        self.expectedInventorySHA256 = expectedInventorySHA256
        self.expectedInputArtifacts = expectedInputArtifacts
        self.expectedInvocations = expectedInvocations
        self.optionalSkipPolicySHA256 = optionalSkipPolicySHA256
        self.authority = authority
    }

    public func validate() throws {
        guard !runID.isEmpty,
              runID.utf8.count <= 128,
              runID.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 65 && $0 <= 90)
                      || ($0 >= 97 && $0 <= 122)
                      || $0 == 45 || $0 == 95
              }),
              PrimeValidationContentBinding.isSHA256(
                expectedInventorySHA256
              ),
              PrimeValidationContentBinding.isSHA256(
                optionalSkipPolicySHA256
              ),
              optionalSkipPolicySHA256
                == (try PrimeValidationOptionalSkipPolicy.identitySHA256())
        else {
            throw PrimeValidationContractError.invalidArtifactSet
        }
        try expectedInputArtifacts.validate()
        try expectedInvocations.validate()
        guard let testBundle = expectedInputArtifacts.binding(
            for: .testBundle
        ),
            expectedInvocations.all.allSatisfy({
                $0.testBundleContent == testBundle.content
            })
        else {
            throw PrimeValidationContractError.invalidArtifactSet
        }
        try authority.validate()
    }
}

public struct PrimeValidationParsedArtifactMaterial:
    Codable,
    Equatable,
    Sendable
{
    public let xctestList: Data
    public let swiftTestingList: Data
    public let parallelXCTestXUnit: Data
    public let sequentialXCTestTranscript: Data
    public let swiftTestingXUnit: Data

    public init(
        xctestList: Data,
        swiftTestingList: Data,
        parallelXCTestXUnit: Data,
        sequentialXCTestTranscript: Data,
        swiftTestingXUnit: Data
    ) {
        self.xctestList = xctestList
        self.swiftTestingList = swiftTestingList
        self.parallelXCTestXUnit = parallelXCTestXUnit
        self.sequentialXCTestTranscript = sequentialXCTestTranscript
        self.swiftTestingXUnit = swiftTestingXUnit
    }
}

public enum PrimeValidationExecutionLane:
    String,
    Codable,
    Equatable,
    Sendable
{
    case parallelXCTest = "parallel_xctest"
    case sequentialXCTest = "sequential_xctest"
    case swiftTesting = "swift_testing"

    var resultRole: PrimeValidationArtifactRole {
        switch self {
        case .parallelXCTest: .parallelXCTestXUnit
        case .sequentialXCTest: .sequentialXCTestTranscript
        case .swiftTesting: .swiftTestingXUnit
        }
    }

    var standardOutputRole: PrimeValidationArtifactRole {
        switch self {
        case .parallelXCTest: .parallelXCTestStandardOutputLog
        case .sequentialXCTest: .sequentialXCTestStandardOutputLog
        case .swiftTesting: .swiftTestingStandardOutputLog
        }
    }

    var standardErrorRole: PrimeValidationArtifactRole {
        switch self {
        case .parallelXCTest: .parallelXCTestStandardErrorLog
        case .sequentialXCTest: .sequentialXCTestStandardErrorLog
        case .swiftTesting: .swiftTestingStandardErrorLog
        }
    }
}

public struct PrimeValidationEnvironmentEntry:
    Codable,
    Equatable,
    Sendable
{
    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    public func validate() throws {
        guard !key.isEmpty,
              key.utf8.count <= 256,
              key.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 65 && $0 <= 90)
                      || ($0 >= 97 && $0 <= 122)
                      || $0 == 95
              }),
              value.utf8.count <= 32 * 1024,
              value.utf8.allSatisfy({
                  $0 >= 0x20 && $0 != 0x7f
              })
        else {
            throw PrimeValidationContractError.invalidProcessObservation
        }
    }
}

public struct PrimeValidationLaneInvocation:
    Codable,
    Equatable,
    Sendable
{
    public let lane: PrimeValidationExecutionLane
    public let executablePath: String
    public let executableContent: PrimeValidationContentBinding
    public let arguments: [String]
    public let environment: [PrimeValidationEnvironmentEntry]
    public let workingDirectoryRelativePath: String
    public let testBundleContent: PrimeValidationContentBinding

    public init(
        lane: PrimeValidationExecutionLane,
        executablePath: String,
        executableContent: PrimeValidationContentBinding,
        arguments: [String],
        environment: [PrimeValidationEnvironmentEntry],
        workingDirectoryRelativePath: String,
        testBundleContent: PrimeValidationContentBinding
    ) {
        self.lane = lane
        self.executablePath = executablePath
        self.executableContent = executableContent
        self.arguments = arguments
        self.environment = environment
        self.workingDirectoryRelativePath = workingDirectoryRelativePath
        self.testBundleContent = testBundleContent
    }

    public func validate() throws {
        try executableContent.validate()
        try testBundleContent.validate()
        guard executableContent.byteCount > 0,
              testBundleContent.byteCount > 0,
              Self.isSafePath(executablePath, mayBeAbsolute: true),
              Self.isSafePath(
                workingDirectoryRelativePath,
                mayBeAbsolute: false
              ),
              arguments.count <= 256,
              arguments.allSatisfy({
                  !$0.isEmpty
                      && $0.utf8.count <= 32 * 1024
                      && $0.utf8.allSatisfy({
                          $0 >= 0x20 && $0 != 0x7f
                      })
              }),
              environment.map(\.key)
                == environment.map(\.key).sorted(),
              Set(environment.map(\.key)).count == environment.count
        else {
            throw PrimeValidationContractError.invalidProcessObservation
        }
        try environment.forEach { try $0.validate() }
    }

    private static func isSafePath(
        _ value: String,
        mayBeAbsolute: Bool
    ) -> Bool {
        guard !value.isEmpty,
              value.utf8.count <= 16 * 1024,
              !value.contains("\\"),
              value.utf8.allSatisfy({
                  $0 >= 0x20 && $0 != 0x7f
              })
        else { return false }
        if value == "." { return !mayBeAbsolute }
        let components = value.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        if value.hasPrefix("/") {
            guard mayBeAbsolute,
                  components.first?.isEmpty == true
            else { return false }
            return components.dropFirst().allSatisfy {
                !$0.isEmpty && $0 != "." && $0 != ".."
            }
        }
        return components.allSatisfy {
            !$0.isEmpty && $0 != "." && $0 != ".."
        }
    }
}

public struct PrimeValidationLaneInvocationSet:
    Codable,
    Equatable,
    Sendable
{
    public let parallelXCTest: PrimeValidationLaneInvocation
    public let sequentialXCTest: PrimeValidationLaneInvocation
    public let swiftTesting: PrimeValidationLaneInvocation

    public init(
        parallelXCTest: PrimeValidationLaneInvocation,
        sequentialXCTest: PrimeValidationLaneInvocation,
        swiftTesting: PrimeValidationLaneInvocation
    ) {
        self.parallelXCTest = parallelXCTest
        self.sequentialXCTest = sequentialXCTest
        self.swiftTesting = swiftTesting
    }

    public var all: [PrimeValidationLaneInvocation] {
        [parallelXCTest, sequentialXCTest, swiftTesting]
    }

    public func invocation(
        for lane: PrimeValidationExecutionLane
    ) -> PrimeValidationLaneInvocation {
        switch lane {
        case .parallelXCTest: parallelXCTest
        case .sequentialXCTest: sequentialXCTest
        case .swiftTesting: swiftTesting
        }
    }

    public func validate() throws {
        guard parallelXCTest.lane == .parallelXCTest,
              sequentialXCTest.lane == .sequentialXCTest,
              swiftTesting.lane == .swiftTesting
        else {
            throw PrimeValidationContractError.invalidProcessObservation
        }
        try parallelXCTest.validate()
        try sequentialXCTest.validate()
        try swiftTesting.validate()
    }
}

public struct PrimeValidationLaneProcessEvidence:
    Codable,
    Equatable,
    Sendable
{
    public let runID: String
    public let invocation: PrimeValidationLaneInvocation
    public let resultArtifact: PrimeValidationArtifactBinding
    public let standardOutputArtifact: PrimeValidationArtifactBinding
    public let standardErrorArtifact: PrimeValidationArtifactBinding
    public let observation: PrimeValidationProcessObservation

    public init(
        runID: String,
        invocation: PrimeValidationLaneInvocation,
        resultArtifact: PrimeValidationArtifactBinding,
        standardOutputArtifact: PrimeValidationArtifactBinding,
        standardErrorArtifact: PrimeValidationArtifactBinding,
        observation: PrimeValidationProcessObservation
    ) {
        self.runID = runID
        self.invocation = invocation
        self.resultArtifact = resultArtifact
        self.standardOutputArtifact = standardOutputArtifact
        self.standardErrorArtifact = standardErrorArtifact
        self.observation = observation
    }

    public func validate() throws {
        try invocation.validate()
        try resultArtifact.validate()
        try standardOutputArtifact.validate()
        try standardErrorArtifact.validate()
        try observation.validate()
        guard !runID.isEmpty,
              runID.utf8.count <= 128,
              resultArtifact.role == invocation.lane.resultRole,
              standardOutputArtifact.role
                == invocation.lane.standardOutputRole,
              standardErrorArtifact.role
                == invocation.lane.standardErrorRole,
              Set([
                  resultArtifact.relativePath,
                  standardOutputArtifact.relativePath,
                  standardErrorArtifact.relativePath,
              ]).count == 3
        else {
            throw PrimeValidationContractError.invalidProcessObservation
        }
    }
}

public struct PrimeValidationProcessSet:
    Codable,
    Equatable,
    Sendable
{
    public let parallelXCTest: PrimeValidationLaneProcessEvidence
    public let sequentialXCTest: PrimeValidationLaneProcessEvidence
    public let swiftTesting: PrimeValidationLaneProcessEvidence

    public init(
        parallelXCTest: PrimeValidationLaneProcessEvidence,
        sequentialXCTest: PrimeValidationLaneProcessEvidence,
        swiftTesting: PrimeValidationLaneProcessEvidence
    ) {
        self.parallelXCTest = parallelXCTest
        self.sequentialXCTest = sequentialXCTest
        self.swiftTesting = swiftTesting
    }

    public func observation(
        for lane: PrimeValidationExecutionLane
    ) -> PrimeValidationProcessObservation {
        switch lane {
        case .parallelXCTest: parallelXCTest.observation
        case .sequentialXCTest: sequentialXCTest.observation
        case .swiftTesting: swiftTesting.observation
        }
    }

    public func laneEvidence(
        for lane: PrimeValidationExecutionLane
    ) -> PrimeValidationLaneProcessEvidence {
        switch lane {
        case .parallelXCTest: parallelXCTest
        case .sequentialXCTest: sequentialXCTest
        case .swiftTesting: swiftTesting
        }
    }

    public var invocations: PrimeValidationLaneInvocationSet {
        .init(
            parallelXCTest: parallelXCTest.invocation,
            sequentialXCTest: sequentialXCTest.invocation,
            swiftTesting: swiftTesting.invocation
        )
    }

    public func validate() throws {
        try parallelXCTest.validate()
        try sequentialXCTest.validate()
        try swiftTesting.validate()
    }
}

public struct PrimeValidationWorkflowEvidence:
    Codable,
    Equatable,
    Sendable
{
    public let runID: String
    public let artifacts: PrimeValidationArtifactSet
    public let parsedArtifactMaterial: PrimeValidationParsedArtifactMaterial
    public let processes: PrimeValidationProcessSet
    public let durations: PrimeValidationPhaseDurations
    public let authority: PrimeValidationAuthorityCeiling

    public init(
        runID: String,
        artifacts: PrimeValidationArtifactSet,
        parsedArtifactMaterial: PrimeValidationParsedArtifactMaterial,
        processes: PrimeValidationProcessSet,
        durations: PrimeValidationPhaseDurations,
        authority: PrimeValidationAuthorityCeiling = .frozenV1
    ) {
        self.runID = runID
        self.artifacts = artifacts
        self.parsedArtifactMaterial = parsedArtifactMaterial
        self.processes = processes
        self.durations = durations
        self.authority = authority
    }

    public func validate() throws {
        try artifacts.validate()
        try processes.validate()
        try durations.validate()
        try authority.validate()
    }
}

public enum PrimeValidationIncompleteReason:
    String,
    Codable,
    Equatable,
    Sendable
{
    case invalidPlan = "invalid_plan"
    case invalidEvidence = "invalid_evidence"
    case authorityViolation = "authority_violation"
    case staleEvidence = "stale_evidence"
    case inventoryMismatch = "inventory_mismatch"
    case artifactBindingMismatch = "artifact_binding_mismatch"
    case laneBindingMismatch = "lane_binding_mismatch"
    case parsedArtifactBindingMismatch = "parsed_artifact_binding_mismatch"
    case timeout
    case signal
    case unobservedTermination = "unobserved_termination"
    case uncontainedProcess = "uncontained_process"
    case unfinishedDrain = "unfinished_drain"
    case logOverflow = "log_overflow"
    case noTests = "no_tests"
    case unfinishedShard = "unfinished_shard"
    case resultSetMismatch = "result_set_mismatch"
    case resultDisagreement = "result_disagreement"
    case nonzeroExit = "nonzero_exit"
}

public enum PrimeValidationDisposition:
    String,
    Codable,
    Equatable,
    Sendable
{
    case completePass = "complete_pass"
    case completeFail = "complete_fail"
    case incomplete
}

public struct PrimeValidationOutcome:
    Codable,
    Equatable,
    Sendable
{
    public let disposition: PrimeValidationDisposition
    public let incompleteReason: PrimeValidationIncompleteReason?
    public let incompleteLane: PrimeValidationExecutionLane?
    public let failedRawIDs: [String]
    public let allowedSkippedRawIDs: [String]
    public let requiredSkippedRawIDs: [String]
    public let authority: PrimeValidationAuthorityCeiling

    fileprivate static func incomplete(
        _ reason: PrimeValidationIncompleteReason,
        lane: PrimeValidationExecutionLane? = nil
    ) -> Self {
        Self(
            disposition: .incomplete,
            incompleteReason: reason,
            incompleteLane: lane,
            failedRawIDs: [],
            allowedSkippedRawIDs: [],
            requiredSkippedRawIDs: [],
            authority: .frozenV1
        )
    }
}

public enum PrimeValidationReconciler {
    public static func reconcile(
        plan: PrimeValidationWorkflowPlan,
        evidence: PrimeValidationWorkflowEvidence
    ) -> PrimeValidationOutcome {
        do {
            try plan.validate()
        } catch PrimeValidationContractError.authorityViolation {
            return .incomplete(.authorityViolation)
        } catch {
            return .incomplete(.invalidPlan)
        }
        do {
            try evidence.validate()
        } catch PrimeValidationContractError.authorityViolation {
            return .incomplete(.authorityViolation)
        } catch {
            return .incomplete(.invalidEvidence)
        }
        guard plan.runID == evidence.runID else {
            return .incomplete(.staleEvidence)
        }
        guard inputBindingsMatch(plan: plan, evidence: evidence) else {
            return .incomplete(.artifactBindingMismatch)
        }
        guard laneBindingsMatch(plan: plan, evidence: evidence) else {
            return .incomplete(.laneBindingMismatch)
        }
        guard rawMaterialBindingsMatch(evidence: evidence) else {
            return .incomplete(.parsedArtifactBindingMismatch)
        }
        let orderedLanes = [
            PrimeValidationExecutionLane.parallelXCTest,
            .sequentialXCTest,
            .swiftTesting,
        ]
        if let outcome = incompleteProcessSafetyOutcome(
            evidence.processes,
            orderedLanes: orderedLanes
        ) {
            return outcome
        }

        let inventory: PrimeValidationInventory
        let parallel: PrimeValidationParallelXCTestXUnitObservation
        let sequential: PrimeValidationSequentialXCTestObservation
        let swiftTesting: PrimeValidationSwiftTestingXUnitObservation
        do {
            inventory = try .parse(
                xctestList: evidence.parsedArtifactMaterial.xctestList,
                swiftTestingList:
                    evidence.parsedArtifactMaterial.swiftTestingList
            )
            parallel = try .parse(
                evidence.parsedArtifactMaterial.parallelXCTestXUnit
            )
            sequential = try .parse(
                evidence.parsedArtifactMaterial
                    .sequentialXCTestTranscript
            )
            swiftTesting = try .parse(
                evidence.parsedArtifactMaterial.swiftTestingXUnit
            )
            try parallel.validate()
            try sequential.validate()
            try swiftTesting.validate()
        } catch {
            return .incomplete(.invalidEvidence)
        }
        guard (try? inventory.identitySHA256())
                == plan.expectedInventorySHA256
        else {
            return .incomplete(.inventoryMismatch)
        }

        let expectedXCTest = Set(inventory.xctestIDs.map(\.rawValue))
        let expectedSwiftTesting = Set(
            inventory.swiftTestingIDs.map(\.rawValue)
        )
        guard Set(parallel.observedRawIDs) == expectedXCTest,
              Set(sequential.observedRawIDs) == expectedXCTest,
              Set(swiftTesting.observedRawIDs) == expectedSwiftTesting
        else {
            return .incomplete(.resultSetMismatch)
        }
        guard parallel.failedRawIDs == sequential.failedRawIDs else {
            return .incomplete(.resultDisagreement)
        }
        guard Set(parallel.explicitSkippedRawIDs).isSubset(
            of: Set(sequential.skippedRawIDs)
        ) else {
            return .incomplete(.resultDisagreement)
        }

        let laneResults: [(
            PrimeValidationExecutionLane,
            PrimeValidationProcessObservation,
            Int,
            Bool
        )] = [
            (
                .parallelXCTest,
                evidence.processes.parallelXCTest.observation,
                parallel.observedRawIDs.count,
                !parallel.failedRawIDs.isEmpty
            ),
            (
                .sequentialXCTest,
                evidence.processes.sequentialXCTest.observation,
                sequential.observedRawIDs.count,
                !sequential.failedRawIDs.isEmpty
            ),
            (
                .swiftTesting,
                evidence.processes.swiftTesting.observation,
                swiftTesting.observedRawIDs.count,
                !swiftTesting.failedRawIDs.isEmpty
                    || !swiftTesting.errorRawIDs.isEmpty
            ),
        ]
        for (lane, process, expectedCount, hasFailures) in laneResults {
            if let outcome = incompleteExitedProcessOutcome(
                process,
                lane: lane,
                expectedCount: expectedCount,
                hasFailures: hasFailures
            ) {
                return outcome
            }
        }

        let admissionByID = Dictionary(
            uniqueKeysWithValues:
                PrimeValidationOptionalSkipPolicy.admissions.map {
                    ($0.rawID, $0.exactReason)
                }
        )
        var allowedSkipped: [String] = []
        var requiredSkipped: [String] = []
        for skip in sequential.skips {
            if admissionByID[skip.rawID] == skip.exactReason {
                allowedSkipped.append(skip.rawID)
            } else {
                requiredSkipped.append(skip.rawID)
            }
        }
        requiredSkipped.append(contentsOf: swiftTesting.skippedRawIDs)
        allowedSkipped.sort()
        requiredSkipped = Array(Set(requiredSkipped)).sorted()

        let failures = Set(
            sequential.failedRawIDs
                + swiftTesting.failedRawIDs
                + swiftTesting.errorRawIDs
        ).sorted()
        let disposition: PrimeValidationDisposition =
            failures.isEmpty && requiredSkipped.isEmpty
                ? .completePass
                : .completeFail
        return PrimeValidationOutcome(
            disposition: disposition,
            incompleteReason: nil,
            incompleteLane: nil,
            failedRawIDs: failures,
            allowedSkippedRawIDs: allowedSkipped,
            requiredSkippedRawIDs: requiredSkipped,
            authority: .frozenV1
        )
    }

    private static func inputBindingsMatch(
        plan: PrimeValidationWorkflowPlan,
        evidence: PrimeValidationWorkflowEvidence
    ) -> Bool {
        PrimeValidationInputArtifactSet.requiredRoles.allSatisfy { role in
            plan.expectedInputArtifacts.binding(for: role)
                == evidence.artifacts.binding(for: role)
        }
    }

    private static func laneBindingsMatch(
        plan: PrimeValidationWorkflowPlan,
        evidence: PrimeValidationWorkflowEvidence
    ) -> Bool {
        guard plan.expectedInvocations == evidence.processes.invocations
        else { return false }
        return [
            PrimeValidationExecutionLane.parallelXCTest,
            .sequentialXCTest,
            .swiftTesting,
        ].allSatisfy { lane in
            let laneEvidence = evidence.processes.laneEvidence(for: lane)
            return laneEvidence.runID == evidence.runID
                && laneEvidence.resultArtifact
                    == evidence.artifacts.binding(for: lane.resultRole)
                && laneEvidence.standardOutputArtifact
                    == evidence.artifacts.binding(
                        for: lane.standardOutputRole
                    )
                && laneEvidence.standardErrorArtifact
                    == evidence.artifacts.binding(
                        for: lane.standardErrorRole
                    )
        }
    }

    private static func rawMaterialBindingsMatch(
        evidence: PrimeValidationWorkflowEvidence
    ) -> Bool {
        let pairs: [(
            PrimeValidationArtifactRole,
            PrimeValidationContentBinding
        )] = [
            (
                .xctestList,
                .init(data: evidence.parsedArtifactMaterial.xctestList)
            ),
            (
                .swiftTestingList,
                .init(data: evidence.parsedArtifactMaterial.swiftTestingList)
            ),
            (
                .parallelXCTestXUnit,
                .init(
                    data: evidence.parsedArtifactMaterial
                        .parallelXCTestXUnit
                )
            ),
            (
                .sequentialXCTestTranscript,
                .init(
                    data: evidence.parsedArtifactMaterial
                        .sequentialXCTestTranscript
                )
            ),
            (
                .swiftTestingXUnit,
                .init(
                    data: evidence.parsedArtifactMaterial
                        .swiftTestingXUnit
                )
            ),
        ]
        return pairs.allSatisfy { role, content in
            evidence.artifacts.binding(for: role)?.content == content
        }
    }

    private static func incompleteProcessSafetyOutcome(
        _ processes: PrimeValidationProcessSet,
        orderedLanes: [PrimeValidationExecutionLane]
    ) -> PrimeValidationOutcome? {
        for lane in orderedLanes {
            let process = processes.observation(for: lane)
            guard process.containmentObserved,
                  process.exactReapObserved
            else {
                return .incomplete(.uncontainedProcess, lane: lane)
            }
        }
        for lane in orderedLanes {
            let process = processes.observation(for: lane)
            guard process.standardOutputDrained,
                  process.standardErrorDrained
            else {
                return .incomplete(.unfinishedDrain, lane: lane)
            }
        }
        for lane in orderedLanes {
            guard !processes.observation(for: lane).logOverflowObserved else {
                return .incomplete(.logOverflow, lane: lane)
            }
        }
        for lane in orderedLanes {
            switch processes.observation(for: lane).termination {
            case .timedOut:
                return .incomplete(.timeout, lane: lane)
            case .signaled:
                return .incomplete(.signal, lane: lane)
            case .unobserved:
                return .incomplete(.unobservedTermination, lane: lane)
            case .exited:
                continue
            }
        }
        return nil
    }

    private static func incompleteExitedProcessOutcome(
        _ process: PrimeValidationProcessObservation,
        lane: PrimeValidationExecutionLane,
        expectedCount: Int,
        hasFailures: Bool
    ) -> PrimeValidationOutcome? {
        guard !process.noTestsReported,
              process.matchedTestCount > 0
        else {
            return .incomplete(.noTests, lane: lane)
        }
        guard process.matchedTestCount == expectedCount else {
            return .incomplete(.unfinishedShard, lane: lane)
        }
        guard case let .exited(code) = process.termination else {
            return .incomplete(.unobservedTermination, lane: lane)
        }
        if hasFailures {
            guard code == 1 else {
                return .incomplete(.resultDisagreement, lane: lane)
            }
        } else if code != 0 {
            return .incomplete(
                code == 1 ? .resultDisagreement : .nonzeroExit,
                lane: lane
            )
        }
        return nil
    }
}
