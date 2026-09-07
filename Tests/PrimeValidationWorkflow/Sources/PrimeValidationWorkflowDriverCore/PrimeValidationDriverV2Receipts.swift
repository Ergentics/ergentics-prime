// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore
import PrimeValidationWorkflowContracts

public enum PrimeValidationPhaseTerminalDispositionV2:
    String,
    Codable,
    Sendable
{
    case succeeded
    case failed
    case incomplete
}

public struct PrimeValidationPhaseStartV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let runID: String
    public let intentSHA256: String
    public let phase: PrimeValidationDriverPhaseV2
    public let phaseOrdinal: Int
    public let predecessorTerminalSHA256: String

    public init(
        runID: String,
        intentSHA256: String,
        phase: PrimeValidationDriverPhaseV2,
        phaseOrdinal: Int,
        predecessorTerminalSHA256: String
    ) {
        schemaVersion = 2
        self.runID = runID
        self.intentSHA256 = intentSHA256
        self.phase = phase
        self.phaseOrdinal = phaseOrdinal
        self.predecessorTerminalSHA256 = predecessorTerminalSHA256
    }

    public func validate(against intent: PrimeValidationRunIntentV2) throws {
        try intent.validate()
        let expectedOrdinal = try Self.ordinal(of: phase)
        guard schemaVersion == 2,
              runID == intent.runID,
              intentSHA256 == (try intent.identitySHA256()),
              phaseOrdinal == expectedOrdinal
        else {
            throw PrimeValidationDriverV2Error.invalidPhaseReceipt
        }
        try PrimeValidationDriverV2Validation.requireSHA256(
            predecessorTerminalSHA256
        )
        if phaseOrdinal == 0 {
            guard predecessorTerminalSHA256
                    == PrimeValidationDriverV2Validation.genesisSHA256
            else {
                throw PrimeValidationDriverV2Error.invalidPhaseReceipt
            }
        } else {
            guard predecessorTerminalSHA256
                    != PrimeValidationDriverV2Validation.genesisSHA256
            else {
                throw PrimeValidationDriverV2Error.invalidPhaseReceipt
            }
        }
    }

    public func identitySHA256(
        against intent: PrimeValidationRunIntentV2
    ) throws -> String {
        try validate(against: intent)
        return try PrimeValidationDriverV2Validation.identity(self)
    }

    private static func ordinal(
        of phase: PrimeValidationDriverPhaseV2
    ) throws -> Int {
        guard let index = PrimeValidationDriverPhaseV2.allCases.firstIndex(
            of: phase
        ) else {
            throw PrimeValidationDriverV2Error.invalidPhaseReceipt
        }
        return index
    }
}

public struct PrimeValidationPhaseTerminalReceiptV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let runID: String
    public let intentSHA256: String
    public let phase: PrimeValidationDriverPhaseV2
    public let phaseStartSHA256: String
    public let disposition: PrimeValidationPhaseTerminalDispositionV2
    public let activeNanoseconds: UInt64
    public let outputArtifacts: [PrimeValidationDriverArtifactBindingV2]

    public init(
        runID: String,
        intentSHA256: String,
        phase: PrimeValidationDriverPhaseV2,
        phaseStartSHA256: String,
        disposition: PrimeValidationPhaseTerminalDispositionV2,
        activeNanoseconds: UInt64,
        outputArtifacts: [PrimeValidationDriverArtifactBindingV2]
    ) {
        schemaVersion = 2
        self.runID = runID
        self.intentSHA256 = intentSHA256
        self.phase = phase
        self.phaseStartSHA256 = phaseStartSHA256
        self.disposition = disposition
        self.activeNanoseconds = activeNanoseconds
        self.outputArtifacts = outputArtifacts.sorted {
            $0.name < $1.name
        }
    }

    public func validate(
        start: PrimeValidationPhaseStartV2,
        intent: PrimeValidationRunIntentV2
    ) throws {
        try start.validate(against: intent)
        guard schemaVersion == 2,
              runID == intent.runID,
              intentSHA256 == (try intent.identitySHA256()),
              phase == start.phase,
              phaseStartSHA256
                == (try start.identitySHA256(against: intent)),
              activeNanoseconds > 0,
              activeNanoseconds
                <= intent.phaseBudgets.first(where: {
                    $0.phase == phase
                })!.maximumActiveNanoseconds,
              outputArtifacts.map(\.name)
                == outputArtifacts.map(\.name).sorted(),
              Set(outputArtifacts.map(\.name)).count
                == outputArtifacts.count,
              Set(outputArtifacts.map(\.relativePath)).count
                == outputArtifacts.count,
              disposition == .succeeded
                ? !outputArtifacts.isEmpty : true
        else {
            throw PrimeValidationDriverV2Error.invalidPhaseReceipt
        }
        try outputArtifacts.forEach {
            try $0.validate(permitsEmpty: true)
        }
    }

    public func identitySHA256(
        start: PrimeValidationPhaseStartV2,
        intent: PrimeValidationRunIntentV2
    ) throws -> String {
        try validate(start: start, intent: intent)
        return try PrimeValidationDriverV2Validation.identity(self)
    }

}

public enum PrimeValidationResumeDecisionV2:
    Equatable,
    Sendable
{
    case executeNeverStarted
    case reuseSucceededTerminal
    case reuseFailedTerminal
    case permanentlyIncomplete
}

public struct PrimeValidationPhaseLedgerEntryV2:
    Codable,
    Equatable,
    Sendable
{
    public let start: PrimeValidationPhaseStartV2
    public let terminal: PrimeValidationPhaseTerminalReceiptV2?

    public init(
        start: PrimeValidationPhaseStartV2,
        terminal: PrimeValidationPhaseTerminalReceiptV2?
    ) {
        self.start = start
        self.terminal = terminal
    }
}

/// Exact durable phase chain. A prefix may end with one started-but-not-
/// terminal phase, but no work may follow it or a failed/incomplete terminal.
public struct PrimeValidationPhaseLedgerV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let runID: String
    public let intentSHA256: String
    public let entries: [PrimeValidationPhaseLedgerEntryV2]

    public init(
        runID: String,
        intentSHA256: String,
        entries: [PrimeValidationPhaseLedgerEntryV2]
    ) {
        schemaVersion = 2
        self.runID = runID
        self.intentSHA256 = intentSHA256
        self.entries = entries
    }

    public func validate(intent: PrimeValidationRunIntentV2) throws {
        try intent.validate()
        guard schemaVersion == 2,
              runID == intent.runID,
              intentSHA256 == (try intent.identitySHA256()),
              entries.count <= PrimeValidationDriverPhaseV2.allCases.count
        else {
            throw PrimeValidationDriverV2Error.invalidPhaseReceipt
        }

        var predecessorSHA = PrimeValidationDriverV2Validation.genesisSHA256
        for (index, entry) in entries.enumerated() {
            let expectedPhase = PrimeValidationDriverPhaseV2.allCases[index]
            guard entry.start.phase == expectedPhase,
                  entry.start.phaseOrdinal == index,
                  entry.start.predecessorTerminalSHA256 == predecessorSHA
            else {
                throw PrimeValidationDriverV2Error.invalidPhaseReceipt
            }
            try entry.start.validate(against: intent)
            guard let terminal = entry.terminal else {
                guard index == entries.index(before: entries.endIndex) else {
                    throw PrimeValidationDriverV2Error.invalidPhaseReceipt
                }
                continue
            }
            try terminal.validate(start: entry.start, intent: intent)
            predecessorSHA = try terminal.identitySHA256(
                start: entry.start,
                intent: intent
            )
            if terminal.disposition != .succeeded {
                guard index == entries.index(before: entries.endIndex) else {
                    throw PrimeValidationDriverV2Error.invalidPhaseReceipt
                }
            }
        }
    }

    public func identitySHA256(
        intent: PrimeValidationRunIntentV2
    ) throws -> String {
        try validate(intent: intent)
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

public enum PrimeValidationResumeStateMachineV2 {
    public static func decidePhase(
        start: PrimeValidationPhaseStartV2?,
        terminal: PrimeValidationPhaseTerminalReceiptV2?,
        intent: PrimeValidationRunIntentV2
    ) throws -> PrimeValidationResumeDecisionV2 {
        guard start == nil, terminal == nil else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        try intent.validate()
        return .executeNeverStarted
    }

    static func decidePhasePairMechanics(
        start: PrimeValidationPhaseStartV2?,
        terminal: PrimeValidationPhaseTerminalReceiptV2?,
        intent: PrimeValidationRunIntentV2
    ) throws -> PrimeValidationResumeDecisionV2 {
        switch (start, terminal) {
        case (nil, nil):
            try intent.validate()
            return .executeNeverStarted
        case (nil, .some):
            throw PrimeValidationDriverV2Error.invalidPhaseReceipt
        case let (.some(start), nil):
            try start.validate(against: intent)
            return .permanentlyIncomplete
        case let (.some(start), .some(terminal)):
            try terminal.validate(start: start, intent: intent)
            switch terminal.disposition {
            case .succeeded:
                return .reuseSucceededTerminal
            case .failed:
                return .reuseFailedTerminal
            case .incomplete:
                return .permanentlyIncomplete
            }
        }
    }
}

public enum PrimeValidationDeadlineDispositionV2:
    String,
    Codable,
    Sendable
{
    case completed
    case timedOut = "timed_out"
}

public enum PrimeValidationWaitTerminationV2:
    Codable,
    Equatable,
    Sendable
{
    case exited(Int32)
    case signaled(Int32)
    case unobserved
}

public enum PrimeValidationSignalDeliveryAuditV2:
    Codable,
    Equatable,
    Sendable
{
    case notAttempted
    case attempted(signal: Int32, result: Int32, errorNumber: Int32)

    func validate(expectedSignal: Int32) throws {
        switch self {
        case .notAttempted:
            return
        case let .attempted(signal, result, errorNumber):
            guard signal == expectedSignal,
                  result == 0 || result == -1,
                  (result == 0 ? errorNumber == 0 : errorNumber > 0)
            else {
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            }
        }
    }
}

public struct PrimeValidationStreamAuditV2:
    Codable,
    Equatable,
    Sendable
{
    public let eofObserved: Bool
    public let totalByteCount: UInt64
    public let capturedByteCount: UInt64
    public let overflowObserved: Bool
    public let readErrorNumber: Int32
    public let writeErrorNumber: Int32

    public init(
        eofObserved: Bool,
        totalByteCount: UInt64,
        capturedByteCount: UInt64,
        overflowObserved: Bool,
        readErrorNumber: Int32,
        writeErrorNumber: Int32
    ) {
        self.eofObserved = eofObserved
        self.totalByteCount = totalByteCount
        self.capturedByteCount = capturedByteCount
        self.overflowObserved = overflowObserved
        self.readErrorNumber = readErrorNumber
        self.writeErrorNumber = writeErrorNumber
    }

    public func validate(content: PrimeValidationContentBinding) throws {
        try content.validate()
        guard capturedByteCount <= totalByteCount,
              content.byteCount == capturedByteCount,
              readErrorNumber >= 0,
              writeErrorNumber >= 0,
              overflowObserved
                ? totalByteCount > capturedByteCount
                : totalByteCount == capturedByteCount
        else {
            throw PrimeValidationDriverV2Error.invalidShardReceipt
        }
    }

    public var complete: Bool {
        eofObserved
            && !overflowObserved
            && readErrorNumber == 0
            && writeErrorNumber == 0
    }
}

public struct PrimeValidationProcessAuditV2:
    Codable,
    Equatable,
    Sendable
{
    public let processIdentifier: Int32
    public let sessionIdentifier: Int32
    public let processGroupIdentifier: Int32
    public let deadlineDisposition: PrimeValidationDeadlineDispositionV2
    public let sigtermDelivery: PrimeValidationSignalDeliveryAuditV2
    public let sigkillDelivery: PrimeValidationSignalDeliveryAuditV2
    public let preReapProcessGroupMembers: [Int32]
    public let exactReturnedProcessIdentifier: Int32
    public let rawWaitStatus: Int32
    public let waitTermination: PrimeValidationWaitTerminationV2
    public let processGroupEmptyAfterReap: Bool
    public let standardOutput: PrimeValidationStreamAuditV2
    public let standardError: PrimeValidationStreamAuditV2
    public let matchedTestCount: Int
    public let supervisorSessionIdentifier: Int32?

    public init(
        processIdentifier: Int32,
        sessionIdentifier: Int32,
        processGroupIdentifier: Int32,
        deadlineDisposition: PrimeValidationDeadlineDispositionV2,
        sigtermDelivery: PrimeValidationSignalDeliveryAuditV2,
        sigkillDelivery: PrimeValidationSignalDeliveryAuditV2,
        preReapProcessGroupMembers: [Int32],
        exactReturnedProcessIdentifier: Int32,
        rawWaitStatus: Int32,
        waitTermination: PrimeValidationWaitTerminationV2,
        processGroupEmptyAfterReap: Bool,
        standardOutput: PrimeValidationStreamAuditV2,
        standardError: PrimeValidationStreamAuditV2,
        matchedTestCount: Int,
        supervisorSessionIdentifier: Int32? = nil
    ) {
        self.processIdentifier = processIdentifier
        self.sessionIdentifier = sessionIdentifier
        self.processGroupIdentifier = processGroupIdentifier
        self.deadlineDisposition = deadlineDisposition
        self.sigtermDelivery = sigtermDelivery
        self.sigkillDelivery = sigkillDelivery
        self.preReapProcessGroupMembers = preReapProcessGroupMembers
        self.exactReturnedProcessIdentifier = exactReturnedProcessIdentifier
        self.rawWaitStatus = rawWaitStatus
        self.waitTermination = waitTermination
        self.processGroupEmptyAfterReap = processGroupEmptyAfterReap
        self.standardOutput = standardOutput
        self.standardError = standardError
        self.matchedTestCount = matchedTestCount
        self.supervisorSessionIdentifier = supervisorSessionIdentifier
    }

    public func validate(
        standardOutputContent: PrimeValidationContentBinding,
        standardErrorContent: PrimeValidationContentBinding
    ) throws {
        try standardOutput.validate(content: standardOutputContent)
        try standardError.validate(content: standardErrorContent)
        try sigtermDelivery.validate(expectedSignal: 15)
        try sigkillDelivery.validate(expectedSignal: 9)
        if let supervisorSessionIdentifier {
            guard supervisorSessionIdentifier > 0,
                  supervisorSessionIdentifier != processIdentifier,
                  supervisorSessionIdentifier == sessionIdentifier
            else {
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            }
        }
        guard processIdentifier > 0,
              sessionIdentifier > 0,
              processGroupIdentifier > 0,
              rawWaitStatus >= 0,
              matchedTestCount >= 0,
              preReapProcessGroupMembers
                == preReapProcessGroupMembers.sorted(),
              Set(preReapProcessGroupMembers).count
                == preReapProcessGroupMembers.count,
              preReapProcessGroupMembers.allSatisfy({ $0 > 0 })
        else {
            throw PrimeValidationDriverV2Error.invalidShardReceipt
        }

        switch deadlineDisposition {
        case .completed:
            guard sigtermDelivery == .notAttempted,
                  sigkillDelivery == .notAttempted
            else {
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            }
        case .timedOut:
            guard case .attempted = sigtermDelivery else {
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            }
        }

        switch waitTermination {
        case let .exited(code):
            guard code >= 0,
                  code <= 255,
                  exactReturnedProcessIdentifier == processIdentifier,
                  rawWaitStatus & 0x7f == 0,
                  (rawWaitStatus >> 8) & 0xff == code
            else {
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            }
        case let .signaled(signal):
            guard signal > 0,
                  signal < 0x7f,
                  exactReturnedProcessIdentifier == processIdentifier,
                  rawWaitStatus & 0x7f == signal
            else {
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            }
        case .unobserved:
            guard exactReturnedProcessIdentifier == 0,
                  rawWaitStatus == 0
            else {
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            }
        }
    }

    public var completeSafetyObserved: Bool {
        deadlineDisposition == .completed
            && (supervisorSessionIdentifier.map {
                $0 > 0 && $0 != processIdentifier && $0 == sessionIdentifier
            } ?? (sessionIdentifier == processIdentifier))
            && processGroupIdentifier == processIdentifier
            && preReapProcessGroupMembers.contains(processIdentifier)
            && exactReturnedProcessIdentifier == processIdentifier
            && waitTermination != .unobserved
            && processGroupEmptyAfterReap
            && standardOutput.complete
            && standardError.complete
    }

    public var exitCode: Int32? {
        guard case let .exited(code) = waitTermination else { return nil }
        return code
    }
}

public enum PrimeValidationObservedPrimaryResultV2:
    Codable,
    Equatable,
    Sendable
{
    case none
    case standardOutput
    case file(PrimeValidationDriverArtifactBindingV2)
}

/// A content-bound observation of one planned child invocation. This is a
/// receipt schema only; the V2 slice does not claim to implement supervision.
public struct PrimeValidationObservedChildReceiptV2:
    Codable,
    Equatable,
    Sendable
{
    public let invocation: PrimeValidationInvocationV2
    public let primaryResult: PrimeValidationObservedPrimaryResultV2
    public let standardOutputArtifact:
        PrimeValidationDriverArtifactBindingV2
    public let standardErrorArtifact:
        PrimeValidationDriverArtifactBindingV2
    public let process: PrimeValidationProcessAuditV2
    public let activeNanoseconds: UInt64

    public init(
        invocation: PrimeValidationInvocationV2,
        primaryResult: PrimeValidationObservedPrimaryResultV2,
        standardOutputArtifact:
            PrimeValidationDriverArtifactBindingV2,
        standardErrorArtifact:
            PrimeValidationDriverArtifactBindingV2,
        process: PrimeValidationProcessAuditV2,
        activeNanoseconds: UInt64
    ) {
        self.invocation = invocation
        self.primaryResult = primaryResult
        self.standardOutputArtifact = standardOutputArtifact
        self.standardErrorArtifact = standardErrorArtifact
        self.process = process
        self.activeNanoseconds = activeNanoseconds
    }

    public func validate(
        expectedInvocation: PrimeValidationInvocationV2,
        maximumActiveNanoseconds: UInt64
    ) throws {
        guard invocation == expectedInvocation,
              process.supervisorSessionIdentifier == nil
                || [.build, .listXCTest, .listSwiftTesting, .shard].contains(invocation.role),
              activeNanoseconds > 0,
              activeNanoseconds <= maximumActiveNanoseconds,
              standardOutputArtifact.name == "standard_output",
              standardErrorArtifact.name == "standard_error",
              standardOutputArtifact.relativePath
                == invocation.standardOutputRelativePath,
              standardErrorArtifact.relativePath
                == invocation.standardErrorRelativePath,
              standardOutputArtifact.relativePath
                != standardErrorArtifact.relativePath
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "observed_child"
            )
        }
        try invocation.validate()
        try standardOutputArtifact.validate(permitsEmpty: true)
        try standardErrorArtifact.validate(permitsEmpty: true)
        try process.validate(
            standardOutputContent: standardOutputArtifact.content,
            standardErrorContent: standardErrorArtifact.content
        )

        switch (invocation.primaryResult, primaryResult) {
        case (.none, .none),
             (.standardOutput, .standardOutput):
            break
        case let (.file(expectedRelativePath), .file(artifact)):
            guard artifact.name == "primary_result",
                  artifact.relativePath == expectedRelativePath,
                  artifact.relativePath
                    != standardOutputArtifact.relativePath,
                  artifact.relativePath
                    != standardErrorArtifact.relativePath
            else {
                throw PrimeValidationDriverV2Error.invalidBinding(
                    "observed_primary_result"
                )
            }
            try artifact.validate(permitsEmpty: true)
        default:
            throw PrimeValidationDriverV2Error.invalidBinding(
                "observed_primary_result"
            )
        }
    }

    public func requireCompleteSuccess(
        expectedMatchedTestCount: Int
    ) throws {
        guard process.completeSafetyObserved,
              process.exitCode == 0,
              process.matchedTestCount == expectedMatchedTestCount
        else {
            throw PrimeValidationDriverV2Error.invalidBinding(
                "observed_child_not_successful"
            )
        }
    }

    public var primaryContent: PrimeValidationContentBinding? {
        switch primaryResult {
        case .none:
            return nil
        case .standardOutput:
            return standardOutputArtifact.content
        case let .file(artifact):
            return artifact.content
        }
    }
}

public enum PrimeValidationSemanticTerminalV2:
    String,
    Codable,
    Sendable
{
    case passed
    case failed
    case error
    case skipped
}

public struct PrimeValidationSemanticTestResultV2:
    Codable,
    Equatable,
    Sendable
{
    public let testID: PrimeValidationTestID
    public let terminal: PrimeValidationSemanticTerminalV2
    public let exactSkipReason: String

    public init(
        testID: PrimeValidationTestID,
        terminal: PrimeValidationSemanticTerminalV2,
        exactSkipReason: String = ""
    ) {
        self.testID = testID
        self.terminal = terminal
        self.exactSkipReason = exactSkipReason
    }

    public func validate() throws {
        let canonicalTestID = try PrimeValidationTestID.parse(
            testID.rawValue,
            framework: testID.framework
        )
        guard canonicalTestID == testID else {
            throw PrimeValidationDriverV2Error.invalidAggregate
        }
        switch terminal {
        case .skipped:
            guard !exactSkipReason.isEmpty,
                  exactSkipReason
                    == exactSkipReason.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                  exactSkipReason.utf8.count <= 2 * 1024,
                  exactSkipReason.utf8.allSatisfy({
                      $0 >= 0x20 && $0 <= 0x7e
                  })
            else {
                throw PrimeValidationDriverV2Error.invalidAggregate
            }
        case .passed, .failed, .error:
            guard exactSkipReason.isEmpty else {
                throw PrimeValidationDriverV2Error.invalidAggregate
            }
        }
    }
}

public struct PrimeValidationShardStartV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let runID: String
    public let executionPlanSHA256: String
    public let shard: PrimeValidationShardPlanV2

    public init(
        runID: String,
        executionPlanSHA256: String,
        shard: PrimeValidationShardPlanV2
    ) {
        schemaVersion = 2
        self.runID = runID
        self.executionPlanSHA256 = executionPlanSHA256
        self.shard = shard
    }

    public func validate(
        expectedRunID: String,
        expectedExecutionPlanSHA256: String,
        policy: PrimeValidationShardPolicyV2 = .frozenRootV1
    ) throws {
        guard schemaVersion == 2,
              runID == expectedRunID,
              executionPlanSHA256 == expectedExecutionPlanSHA256
        else {
            throw PrimeValidationDriverV2Error.invalidShardReceipt
        }
        try PrimeValidationDriverV2Validation.requireRunID(runID)
        try PrimeValidationDriverV2Validation.requireSHA256(
            executionPlanSHA256
        )
        try shard.validate(policy: policy)
    }

    public func identitySHA256(
        expectedRunID: String,
        expectedExecutionPlanSHA256: String,
        policy: PrimeValidationShardPolicyV2 = .frozenRootV1
    ) throws -> String {
        try validate(
            expectedRunID: expectedRunID,
            expectedExecutionPlanSHA256: expectedExecutionPlanSHA256,
            policy: policy
        )
        return try PrimeValidationDriverV2Validation.identity(self)
    }
}

public enum PrimeValidationShardReceiptDispositionV2:
    String,
    Codable,
    Sendable
{
    case complete
    case incomplete
}

public struct PrimeValidationShardReceiptV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let runID: String
    public let executionPlanSHA256: String
    public let shardStartSHA256: String
    public let shardID: String
    public let disposition: PrimeValidationShardReceiptDispositionV2
    public let incompleteReason: String
    public let resultArtifact: PrimeValidationDriverArtifactBindingV2
    public let standardOutputArtifact:
        PrimeValidationDriverArtifactBindingV2
    public let standardErrorArtifact:
        PrimeValidationDriverArtifactBindingV2
    public let process: PrimeValidationProcessAuditV2
    public let semanticResults: [PrimeValidationSemanticTestResultV2]
    public let activeNanoseconds: UInt64

    public init(
        runID: String,
        executionPlanSHA256: String,
        shardStartSHA256: String,
        shardID: String,
        disposition: PrimeValidationShardReceiptDispositionV2,
        incompleteReason: String,
        resultArtifact: PrimeValidationDriverArtifactBindingV2,
        standardOutputArtifact:
            PrimeValidationDriverArtifactBindingV2,
        standardErrorArtifact:
            PrimeValidationDriverArtifactBindingV2,
        process: PrimeValidationProcessAuditV2,
        semanticResults: [PrimeValidationSemanticTestResultV2],
        activeNanoseconds: UInt64
    ) {
        schemaVersion = 2
        self.runID = runID
        self.executionPlanSHA256 = executionPlanSHA256
        self.shardStartSHA256 = shardStartSHA256
        self.shardID = shardID
        self.disposition = disposition
        self.incompleteReason = incompleteReason
        self.resultArtifact = resultArtifact
        self.standardOutputArtifact = standardOutputArtifact
        self.standardErrorArtifact = standardErrorArtifact
        self.process = process
        self.semanticResults = semanticResults.sorted {
            $0.testID < $1.testID
        }
        self.activeNanoseconds = activeNanoseconds
    }

    public func validate(
        start: PrimeValidationShardStartV2,
        expectedRunID: String,
        expectedExecutionPlanSHA256: String,
        maximumActiveNanoseconds: UInt64,
        policy: PrimeValidationShardPolicyV2 = .frozenRootV1
    ) throws {
        guard disposition == .incomplete else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        try validateAssumingParsedSemanticEvidence(
            start: start,
            expectedRunID: expectedRunID,
            expectedExecutionPlanSHA256: expectedExecutionPlanSHA256,
            maximumActiveNanoseconds: maximumActiveNanoseconds,
            policy: policy
        )
    }

    func validateAssumingParsedSemanticEvidence(
        start: PrimeValidationShardStartV2,
        expectedRunID: String,
        expectedExecutionPlanSHA256: String,
        maximumActiveNanoseconds: UInt64,
        policy: PrimeValidationShardPolicyV2 = .frozenRootV1
    ) throws {
        try start.validate(
            expectedRunID: expectedRunID,
            expectedExecutionPlanSHA256: expectedExecutionPlanSHA256,
            policy: policy
        )
        guard schemaVersion == 2,
              runID == expectedRunID,
              executionPlanSHA256 == expectedExecutionPlanSHA256,
              shardStartSHA256
                == (try start.identitySHA256(
                    expectedRunID: expectedRunID,
                    expectedExecutionPlanSHA256:
                        expectedExecutionPlanSHA256,
                    policy: policy
                )),
              shardID == start.shard.shardID,
              activeNanoseconds > 0,
              activeNanoseconds <= maximumActiveNanoseconds,
              semanticResults == semanticResults.sorted(by: {
                  $0.testID < $1.testID
              }),
              Set(semanticResults.map(\.testID)).count
                == semanticResults.count,
              resultArtifact.name == "result",
              standardOutputArtifact.name == "standard_output",
              standardErrorArtifact.name == "standard_error",
              standardOutputArtifact.relativePath
                != standardErrorArtifact.relativePath,
              resultArtifact.relativePath
                != standardErrorArtifact.relativePath
        else {
            throw PrimeValidationDriverV2Error.invalidShardReceipt
        }
        try resultArtifact.validate(permitsEmpty: true)
        try standardOutputArtifact.validate(permitsEmpty: true)
        try standardErrorArtifact.validate(permitsEmpty: true)
        try process.validate(
            standardOutputContent: standardOutputArtifact.content,
            standardErrorContent: standardErrorArtifact.content
        )
        try semanticResults.forEach { try $0.validate() }

        switch start.shard.key.lane {
        case .sequentialXCTest:
            guard resultArtifact.relativePath
                    == standardOutputArtifact.relativePath,
                  resultArtifact.content == standardOutputArtifact.content
            else {
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            }
        case .parallelXCTest, .swiftTesting:
            guard resultArtifact.relativePath
                    != standardOutputArtifact.relativePath
            else {
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            }
        }

        switch disposition {
        case .complete:
            let failures = semanticResults.contains {
                $0.terminal == .failed || $0.terminal == .error
            }
            guard incompleteReason.isEmpty,
                  process.completeSafetyObserved,
                  semanticResults.map(\.testID) == start.shard.testIDs,
                  process.matchedTestCount == start.shard.testIDs.count,
                  let code = process.exitCode,
                  (failures ? code == 1 : code == 0)
            else {
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            }
        case .incomplete:
            guard PrimeValidationDriverV2Validation.isSafeName(
                incompleteReason
            ),
                  Set(semanticResults.map(\.testID)).isSubset(
                    of: Set(start.shard.testIDs)
                  )
            else {
                throw PrimeValidationDriverV2Error.invalidShardReceipt
            }
        }
    }

    public func identitySHA256(
        start: PrimeValidationShardStartV2,
        expectedRunID: String,
        expectedExecutionPlanSHA256: String,
        maximumActiveNanoseconds: UInt64,
        policy: PrimeValidationShardPolicyV2 = .frozenRootV1
    ) throws -> String {
        try validate(
            start: start,
            expectedRunID: expectedRunID,
            expectedExecutionPlanSHA256: expectedExecutionPlanSHA256,
            maximumActiveNanoseconds: maximumActiveNanoseconds,
            policy: policy
        )
        return try PrimeValidationDriverV2Validation.identity(self)
    }

    func identitySHA256AssumingParsedSemanticEvidence(
        start: PrimeValidationShardStartV2,
        expectedRunID: String,
        expectedExecutionPlanSHA256: String,
        maximumActiveNanoseconds: UInt64,
        policy: PrimeValidationShardPolicyV2 = .frozenRootV1
    ) throws -> String {
        try validateAssumingParsedSemanticEvidence(
            start: start,
            expectedRunID: expectedRunID,
            expectedExecutionPlanSHA256: expectedExecutionPlanSHA256,
            maximumActiveNanoseconds: maximumActiveNanoseconds,
            policy: policy
        )
        return try PrimeValidationDriverV2Validation.identity(self)
    }

    var hasTerminalGateFailure: Bool {
        let admissions = Dictionary(
            uniqueKeysWithValues:
                PrimeValidationOptionalSkipPolicy.admissions.map {
                    ($0.rawID, $0.exactReason)
                }
        )
        return semanticResults.contains { result in
            switch result.terminal {
            case .passed:
                return false
            case .failed, .error:
                return true
            case .skipped:
                return result.testID.framework != .xctest
                    || admissions[result.testID.rawValue]
                        != result.exactSkipReason
            }
        }
    }
}

extension PrimeValidationResumeStateMachineV2 {
    public static func decideShard(
        start: PrimeValidationShardStartV2?,
        terminal: PrimeValidationShardReceiptV2?,
        expectedRunID: String,
        expectedExecutionPlanSHA256: String,
        maximumActiveNanoseconds: UInt64,
        policy: PrimeValidationShardPolicyV2 = .frozenRootV1
    ) throws -> PrimeValidationResumeDecisionV2 {
        if terminal?.disposition == .complete {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        return try decideShardAssumingParsedSemanticEvidence(
            start: start,
            terminal: terminal,
            expectedRunID: expectedRunID,
            expectedExecutionPlanSHA256: expectedExecutionPlanSHA256,
            maximumActiveNanoseconds: maximumActiveNanoseconds,
            policy: policy
        )
    }

    static func decideShardAssumingParsedSemanticEvidence(
        start: PrimeValidationShardStartV2?,
        terminal: PrimeValidationShardReceiptV2?,
        expectedRunID: String,
        expectedExecutionPlanSHA256: String,
        maximumActiveNanoseconds: UInt64,
        policy: PrimeValidationShardPolicyV2 = .frozenRootV1
    ) throws -> PrimeValidationResumeDecisionV2 {
        switch (start, terminal) {
        case (nil, nil):
            try PrimeValidationDriverV2Validation.requireRunID(
                expectedRunID
            )
            try PrimeValidationDriverV2Validation.requireSHA256(
                expectedExecutionPlanSHA256
            )
            try policy.validate()
            return .executeNeverStarted
        case (nil, .some):
            throw PrimeValidationDriverV2Error.invalidShardReceipt
        case let (.some(start), nil):
            try start.validate(
                expectedRunID: expectedRunID,
                expectedExecutionPlanSHA256:
                    expectedExecutionPlanSHA256,
                policy: policy
            )
            return .permanentlyIncomplete
        case let (.some(start), .some(terminal)):
            try terminal.validateAssumingParsedSemanticEvidence(
                start: start,
                expectedRunID: expectedRunID,
                expectedExecutionPlanSHA256:
                    expectedExecutionPlanSHA256,
                maximumActiveNanoseconds: maximumActiveNanoseconds,
                policy: policy
            )
            guard terminal.disposition == .complete else {
                return .permanentlyIncomplete
            }
            return terminal.hasTerminalGateFailure
                ? .reuseFailedTerminal : .reuseSucceededTerminal
        }
    }
}

public struct PrimeValidationShardEvidenceV2:
    Codable,
    Equatable,
    Sendable
{
    public let start: PrimeValidationShardStartV2
    public let receipt: PrimeValidationShardReceiptV2

    public init(
        start: PrimeValidationShardStartV2,
        receipt: PrimeValidationShardReceiptV2
    ) {
        self.start = start
        self.receipt = receipt
    }

    public var key: PrimeValidationShardKeyV2 { start.shard.key }

    public func validate(
        executionPlan: PrimeValidationExecutionPlanV2,
        expectedExecutionPlanSHA256: String
    ) throws {
        guard receipt.disposition == .incomplete else {
            throw PrimeValidationDriverV2Error.authorityViolation
        }
        try validateAssumingParsedSemanticEvidence(
            executionPlan: executionPlan,
            expectedExecutionPlanSHA256: expectedExecutionPlanSHA256
        )
    }

    func validateAssumingParsedSemanticEvidence(
        executionPlan: PrimeValidationExecutionPlanV2,
        expectedExecutionPlanSHA256: String
    ) throws {
        guard let index = executionPlan.shards.firstIndex(where: {
            $0.key == key
        }),
            executionPlan.shards[index] == start.shard,
            executionPlan.shardInvocations.indices.contains(index)
        else {
            throw PrimeValidationDriverV2Error.invalidAggregate
        }
        let invocation = executionPlan.shardInvocations[index]
        guard invocation.shardKey == key,
              invocation.shardID == start.shard.shardID,
              receipt.standardOutputArtifact.relativePath
                == invocation.standardOutputRelativePath,
              receipt.standardErrorArtifact.relativePath
                == invocation.standardErrorRelativePath,
              receipt.standardOutputArtifact.relativePath
                != receipt.standardErrorArtifact.relativePath
        else {
            throw PrimeValidationDriverV2Error.invalidAggregate
        }
        switch invocation.primaryResult {
        case .none:
            throw PrimeValidationDriverV2Error.invalidAggregate
        case .standardOutput:
            guard receipt.resultArtifact.relativePath
                    == receipt.standardOutputArtifact.relativePath,
                  receipt.resultArtifact.content
                    == receipt.standardOutputArtifact.content
            else {
                throw PrimeValidationDriverV2Error.invalidAggregate
            }
        case let .file(relativePath):
            guard receipt.resultArtifact.relativePath == relativePath,
                  receipt.resultArtifact.relativePath
                    != receipt.standardOutputArtifact.relativePath,
                  receipt.resultArtifact.relativePath
                    != receipt.standardErrorArtifact.relativePath
            else {
                throw PrimeValidationDriverV2Error.invalidAggregate
            }
        }
        let maximum = key.arm == .reference
            ? executionPlan.maximumReferenceShardActiveNanoseconds
            : executionPlan.maximumCandidateShardActiveNanoseconds
        try receipt.validateAssumingParsedSemanticEvidence(
            start: start,
            expectedRunID: executionPlan.runID,
            expectedExecutionPlanSHA256: expectedExecutionPlanSHA256,
            maximumActiveNanoseconds: maximum
        )
    }
}

public enum PrimeValidationArmDispositionV2:
    String,
    Codable,
    Sendable
{
    case completePass = "complete_pass"
    case completeFail = "complete_fail"
    case incomplete
}

public struct PrimeValidationArmAggregateV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let runID: String
    public let arm: PrimeValidationComparisonArmV2
    public let executionPlanSHA256: String
    public let inventorySHA256: String
    public let disposition: PrimeValidationArmDispositionV2
    public let incompleteReason: String
    public let semanticResults: [PrimeValidationSemanticTestResultV2]
    public let shardEvidence: [PrimeValidationShardEvidenceV2]

    public init(
        runID: String,
        arm: PrimeValidationComparisonArmV2,
        executionPlanSHA256: String,
        inventorySHA256: String,
        disposition: PrimeValidationArmDispositionV2,
        incompleteReason: String,
        semanticResults: [PrimeValidationSemanticTestResultV2],
        shardEvidence: [PrimeValidationShardEvidenceV2]
    ) {
        schemaVersion = 2
        self.runID = runID
        self.arm = arm
        self.executionPlanSHA256 = executionPlanSHA256
        self.inventorySHA256 = inventorySHA256
        self.disposition = disposition
        self.incompleteReason = incompleteReason
        self.semanticResults = semanticResults.sorted {
            $0.testID < $1.testID
        }
        self.shardEvidence = shardEvidence.sorted {
            PrimeValidationArmAggregateV2.evidenceLess($0, $1)
        }
    }

    public static func make(
        arm: PrimeValidationComparisonArmV2,
        shardEvidence: [PrimeValidationShardEvidenceV2],
        executionPlan: PrimeValidationExecutionPlanV2,
        expectedExecutionPlanSHA256: String
    ) throws -> Self {
        _ = (arm, shardEvidence, executionPlan, expectedExecutionPlanSHA256)
        throw PrimeValidationDriverV2Error.authorityViolation
    }

    /// Internal semantic kernel. Its caller must first admit the execution
    /// plan, including the frozen list byte/hash anchors. It is internal so
    /// generated production-cardinality fixtures can exercise reconciliation
    /// without creating a forged public admission path.
    static func aggregateAssumingAdmittedPlan(
        arm: PrimeValidationComparisonArmV2,
        shardEvidence: [PrimeValidationShardEvidenceV2],
        executionPlan: PrimeValidationExecutionPlanV2,
        expectedExecutionPlanSHA256: String
    ) throws -> Self {
        let sortedEvidence = shardEvidence.sorted(by: evidenceLess)
        guard Set(sortedEvidence.map(\.key)).count == sortedEvidence.count,
              sortedEvidence.allSatisfy({ $0.key.arm == arm })
        else {
            throw PrimeValidationDriverV2Error.invalidAggregate
        }
        try sortedEvidence.forEach {
            try $0.validateAssumingParsedSemanticEvidence(
                executionPlan: executionPlan,
                expectedExecutionPlanSHA256: expectedExecutionPlanSHA256
            )
        }

        let expectedKeys = Set(
            executionPlan.shards.filter { $0.key.arm == arm }.map(\.key)
        )
        let observedKeys = Set(sortedEvidence.map(\.key))
        guard observedKeys.isSubset(of: expectedKeys) else {
            throw PrimeValidationDriverV2Error.invalidAggregate
        }
        guard observedKeys == expectedKeys else {
            return Self(
                runID: executionPlan.runID,
                arm: arm,
                executionPlanSHA256: expectedExecutionPlanSHA256,
                inventorySHA256: executionPlan.inventorySHA256,
                disposition: .incomplete,
                incompleteReason: "missing_shard_receipt",
                semanticResults: [],
                shardEvidence: sortedEvidence
            )
        }
        guard sortedEvidence.allSatisfy({
            $0.receipt.disposition == .complete
        }) else {
            return Self(
                runID: executionPlan.runID,
                arm: arm,
                executionPlanSHA256: expectedExecutionPlanSHA256,
                inventorySHA256: executionPlan.inventorySHA256,
                disposition: .incomplete,
                incompleteReason: "one_or_more_shards_incomplete",
                semanticResults: [],
                shardEvidence: sortedEvidence
            )
        }

        let laneResults = try resultsByLane(sortedEvidence)
        let reconciliation = reconcileXCTestLaneSemantics(
            parallel:
                laneResults[PrimeValidationExecutionLane
                    .parallelXCTest.rawValue] ?? [:],
            sequential:
                laneResults[PrimeValidationExecutionLane
                    .sequentialXCTest.rawValue] ?? [:],
            expectedIDs: executionPlan.inventory.xctestIDs
        )
        guard let reconciledXCTest = reconciliation.results else {
            return Self(
                runID: executionPlan.runID,
                arm: arm,
                executionPlanSHA256: expectedExecutionPlanSHA256,
                inventorySHA256: executionPlan.inventorySHA256,
                disposition: .incomplete,
                incompleteReason: reconciliation.reason,
                semanticResults: [],
                shardEvidence: sortedEvidence
            )
        }
        let swiftResults = laneResults[
            PrimeValidationExecutionLane.swiftTesting.rawValue
        ] ?? [:]
        guard Set(swiftResults.keys)
                == Set(executionPlan.inventory.swiftTestingIDs)
        else {
            throw PrimeValidationDriverV2Error.invalidAggregate
        }
        let semanticResults = (
            reconciledXCTest + Array(swiftResults.values)
        ).sorted { $0.testID < $1.testID }
        let disposition = derivedCompleteDisposition(
            semanticResults: semanticResults
        )
        return Self(
            runID: executionPlan.runID,
            arm: arm,
            executionPlanSHA256: expectedExecutionPlanSHA256,
            inventorySHA256: executionPlan.inventorySHA256,
            disposition: disposition,
            incompleteReason: "",
            semanticResults: semanticResults,
            shardEvidence: sortedEvidence
        )
    }

    public func validate(
        executionPlan: PrimeValidationExecutionPlanV2,
        expectedExecutionPlanSHA256: String
    ) throws {
        _ = (executionPlan, expectedExecutionPlanSHA256)
        throw PrimeValidationDriverV2Error.authorityViolation
    }

    public func identitySHA256(
        executionPlan: PrimeValidationExecutionPlanV2,
        expectedExecutionPlanSHA256: String
    ) throws -> String {
        try validate(
            executionPlan: executionPlan,
            expectedExecutionPlanSHA256: expectedExecutionPlanSHA256
        )
        return try PrimeValidationDriverV2Validation.identity(self)
    }

    private static func derivedCompleteDisposition(
        semanticResults: [PrimeValidationSemanticTestResultV2]
    ) -> PrimeValidationArmDispositionV2 {
        let admissions = Dictionary(
            uniqueKeysWithValues:
                PrimeValidationOptionalSkipPolicy.admissions.map {
                    ($0.rawID, $0.exactReason)
                }
        )
        var hasGateFailure = false
        for result in semanticResults {
            switch result.terminal {
            case .passed:
                continue
            case .failed, .error:
                hasGateFailure = true
            case .skipped:
                if result.testID.framework != .xctest
                    || admissions[result.testID.rawValue]
                        != result.exactSkipReason
                {
                    hasGateFailure = true
                }
            }
        }
        return hasGateFailure ? .completeFail : .completePass
    }

    private static func resultsByLane(
        _ evidence: [PrimeValidationShardEvidenceV2]
    ) throws -> [
        String:
            [PrimeValidationTestID: PrimeValidationSemanticTestResultV2]
    ] {
        var output: [
            String:
                [PrimeValidationTestID: PrimeValidationSemanticTestResultV2]
        ] = [:]
        for item in evidence {
            let laneKey = item.key.lane.rawValue
            var lane = output[laneKey, default: [:]]
            for result in item.receipt.semanticResults {
                guard lane[result.testID] == nil else {
                    throw PrimeValidationDriverV2Error.invalidAggregate
                }
                lane[result.testID] = result
            }
            output[laneKey] = lane
        }
        return output
    }

    static func reconcileXCTestLaneSemantics(
        parallel: [
            PrimeValidationTestID: PrimeValidationSemanticTestResultV2
        ],
        sequential: [
            PrimeValidationTestID: PrimeValidationSemanticTestResultV2
        ],
        expectedIDs: [PrimeValidationTestID]
    ) -> (
        results: [PrimeValidationSemanticTestResultV2]?,
        reason: String
    ) {
        let expected = Set(expectedIDs)
        guard Set(parallel.keys) == expected,
              Set(sequential.keys) == expected
        else {
            return (nil, "xctest_lane_result_set_mismatch")
        }
        var reconciled: [PrimeValidationSemanticTestResultV2] = []
        for identifier in expectedIDs.sorted() {
            guard let parallelResult = parallel[identifier],
                  let sequentialResult = sequential[identifier]
            else {
                return (nil, "xctest_lane_result_set_mismatch")
            }
            switch sequentialResult.terminal {
            case .passed:
                guard parallelResult.terminal == .passed else {
                    return (nil, "xctest_lane_semantic_mismatch")
                }
            case .failed, .error:
                guard parallelResult.terminal == .failed
                        || parallelResult.terminal == .error
                else {
                    return (nil, "xctest_lane_semantic_mismatch")
                }
            case .skipped:
                guard parallelResult.terminal == .passed
                        || parallelResult.terminal == .skipped
                else {
                    return (nil, "xctest_lane_semantic_mismatch")
                }
            }
            reconciled.append(sequentialResult)
        }
        return (reconciled, "")
    }

    private static func evidenceLess(
        _ lhs: PrimeValidationShardEvidenceV2,
        _ rhs: PrimeValidationShardEvidenceV2
    ) -> Bool {
        let left = lhs.key
        let right = rhs.key
        if left.lane.rawValue != right.lane.rawValue {
            return left.lane.rawValue < right.lane.rawValue
        }
        return left.index < right.index
    }
}

public enum PrimeValidationPairedComparisonDispositionV2:
    String,
    Codable,
    Sendable
{
    case equivalent
    case semanticMismatch = "semantic_mismatch"
    case incomplete
}

public struct PrimeValidationPairedComparisonReceiptV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let runID: String
    public let executionPlanSHA256: String
    public let inventorySHA256: String
    public let expectedXCTestCount: Int
    public let expectedSwiftTestingCount: Int
    public let referenceAggregateSHA256: String
    public let candidateAggregateSHA256: String
    public let disposition: PrimeValidationPairedComparisonDispositionV2
    public let detail: String

    public init(
        runID: String,
        executionPlanSHA256: String,
        inventorySHA256: String,
        expectedXCTestCount: Int,
        expectedSwiftTestingCount: Int,
        referenceAggregateSHA256: String,
        candidateAggregateSHA256: String,
        disposition: PrimeValidationPairedComparisonDispositionV2,
        detail: String
    ) {
        schemaVersion = 2
        self.runID = runID
        self.executionPlanSHA256 = executionPlanSHA256
        self.inventorySHA256 = inventorySHA256
        self.expectedXCTestCount = expectedXCTestCount
        self.expectedSwiftTestingCount = expectedSwiftTestingCount
        self.referenceAggregateSHA256 = referenceAggregateSHA256
        self.candidateAggregateSHA256 = candidateAggregateSHA256
        self.disposition = disposition
        self.detail = detail
    }
}

public enum PrimeValidationPairedSemanticComparatorV2 {
    public static func compareSemanticResults(
        reference: [PrimeValidationSemanticTestResultV2],
        candidate: [PrimeValidationSemanticTestResultV2]
    ) throws -> PrimeValidationPairedComparisonDispositionV2 {
        let sortedReference = reference.sorted { $0.testID < $1.testID }
        let sortedCandidate = candidate.sorted { $0.testID < $1.testID }
        guard Set(sortedReference.map(\.testID)).count
                == sortedReference.count,
              Set(sortedCandidate.map(\.testID)).count
                == sortedCandidate.count
        else {
            throw PrimeValidationDriverV2Error.invalidComparison
        }
        try sortedReference.forEach { try $0.validate() }
        try sortedCandidate.forEach { try $0.validate() }
        return sortedReference == sortedCandidate
            ? .equivalent : .semanticMismatch
    }

    public static func compare(
        reference: PrimeValidationArmAggregateV2,
        candidate: PrimeValidationArmAggregateV2,
        executionPlan: PrimeValidationExecutionPlanV2,
        executionPlanSHA256: String
    ) throws -> PrimeValidationPairedComparisonReceiptV2 {
        guard reference.arm == .reference,
              candidate.arm == .candidate
        else {
            throw PrimeValidationDriverV2Error.invalidComparison
        }
        try reference.validate(
            executionPlan: executionPlan,
            expectedExecutionPlanSHA256: executionPlanSHA256
        )
        try candidate.validate(
            executionPlan: executionPlan,
            expectedExecutionPlanSHA256: executionPlanSHA256
        )
        return try compareAssumingValidatedAggregates(
            reference: reference,
            candidate: candidate,
            executionPlan: executionPlan,
            executionPlanSHA256: executionPlanSHA256
        )
    }

    static func compareAssumingValidatedAggregates(
        reference: PrimeValidationArmAggregateV2,
        candidate: PrimeValidationArmAggregateV2,
        executionPlan: PrimeValidationExecutionPlanV2,
        executionPlanSHA256: String
    ) throws -> PrimeValidationPairedComparisonReceiptV2 {
        guard reference.arm == .reference,
              candidate.arm == .candidate,
              reference.runID == executionPlan.runID,
              candidate.runID == executionPlan.runID,
              reference.executionPlanSHA256 == executionPlanSHA256,
              candidate.executionPlanSHA256 == executionPlanSHA256,
              reference.inventorySHA256 == executionPlan.inventorySHA256,
              candidate.inventorySHA256 == executionPlan.inventorySHA256
        else {
            throw PrimeValidationDriverV2Error.invalidComparison
        }
        let disposition: PrimeValidationPairedComparisonDispositionV2
        let detail: String
        if reference.disposition == .incomplete
            || candidate.disposition == .incomplete
        {
            disposition = .incomplete
            detail = "one_or_both_arms_incomplete"
        } else if try compareSemanticResults(
            reference: reference.semanticResults,
            candidate: candidate.semanticResults
        ) == .equivalent,
            reference.disposition == candidate.disposition
        {
            disposition = .equivalent
            detail = "exact_per_test_semantics_equivalent"
        } else {
            disposition = .semanticMismatch
            detail = "per_test_semantics_or_disposition_mismatch"
        }

        return PrimeValidationPairedComparisonReceiptV2(
            runID: executionPlan.runID,
            executionPlanSHA256: executionPlanSHA256,
            inventorySHA256: executionPlan.inventorySHA256,
            expectedXCTestCount:
                executionPlan.baseline.expectedXCTestCount,
            expectedSwiftTestingCount:
                executionPlan.baseline.expectedSwiftTestingCount,
            referenceAggregateSHA256:
                try PrimeValidationDriverV2Validation.identity(reference),
            candidateAggregateSHA256:
                try PrimeValidationDriverV2Validation.identity(candidate),
            disposition: disposition,
            detail: detail
        )
    }

    public static func validate(
        _ receipt: PrimeValidationPairedComparisonReceiptV2,
        reference: PrimeValidationArmAggregateV2,
        candidate: PrimeValidationArmAggregateV2,
        executionPlan: PrimeValidationExecutionPlanV2,
        executionPlanSHA256: String
    ) throws {
        let expected = try compare(
            reference: reference,
            candidate: candidate,
            executionPlan: executionPlan,
            executionPlanSHA256: executionPlanSHA256
        )
        guard receipt == expected else {
            throw PrimeValidationDriverV2Error.invalidComparison
        }
    }

    static func validateAssumingValidatedAggregates(
        _ receipt: PrimeValidationPairedComparisonReceiptV2,
        reference: PrimeValidationArmAggregateV2,
        candidate: PrimeValidationArmAggregateV2,
        executionPlan: PrimeValidationExecutionPlanV2,
        executionPlanSHA256: String
    ) throws {
        let expected = try compareAssumingValidatedAggregates(
            reference: reference,
            candidate: candidate,
            executionPlan: executionPlan,
            executionPlanSHA256: executionPlanSHA256
        )
        guard receipt == expected else {
            throw PrimeValidationDriverV2Error.invalidComparison
        }
    }
}

public struct PrimeValidationDriverFinalReceiptV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let runID: String
    public let comparisonReceiptSHA256: String
    public let disposition: PrimeValidationDisposition
    public let incompleteReason: String
    public let authority: PrimeValidationDriverAuthorityCeilingV2

    public init(
        runID: String,
        comparisonReceiptSHA256: String,
        disposition: PrimeValidationDisposition,
        incompleteReason: String,
        authority: PrimeValidationDriverAuthorityCeilingV2 =
            .frozenPlannerV2
    ) {
        schemaVersion = 2
        self.runID = runID
        self.comparisonReceiptSHA256 = comparisonReceiptSHA256
        self.disposition = disposition
        self.incompleteReason = incompleteReason
        self.authority = authority
    }

    public static func make(
        comparison: PrimeValidationPairedComparisonReceiptV2,
        reference: PrimeValidationArmAggregateV2,
        candidate: PrimeValidationArmAggregateV2,
        executionPlan: PrimeValidationExecutionPlanV2,
        executionPlanSHA256: String
    ) throws -> Self {
        try PrimeValidationPairedSemanticComparatorV2.validate(
            comparison,
            reference: reference,
            candidate: candidate,
            executionPlan: executionPlan,
            executionPlanSHA256: executionPlanSHA256
        )
        return try makeAssumingValidatedComparison(
            comparison: comparison,
            reference: reference,
            candidate: candidate
        )
    }

    static func makeAssumingValidatedComparison(
        comparison: PrimeValidationPairedComparisonReceiptV2,
        reference: PrimeValidationArmAggregateV2,
        candidate: PrimeValidationArmAggregateV2
    ) throws -> Self {
        guard comparison.runID == reference.runID,
              comparison.runID == candidate.runID,
              comparison.executionPlanSHA256
                == reference.executionPlanSHA256,
              comparison.executionPlanSHA256
                == candidate.executionPlanSHA256,
              comparison.inventorySHA256 == reference.inventorySHA256,
              comparison.inventorySHA256 == candidate.inventorySHA256
        else {
            throw PrimeValidationDriverV2Error.invalidFinalReceipt
        }
        let comparisonSHA = try PrimeValidationDriverV2Validation.identity(
            comparison
        )
        let disposition: PrimeValidationDisposition
        let reason: String
        if comparison.disposition != .equivalent {
            disposition = .incomplete
            reason = comparison.detail
        } else if reference.disposition == .completePass,
                  candidate.disposition == .completePass
        {
            disposition = .completePass
            reason = ""
        } else if reference.disposition == .completeFail,
                  candidate.disposition == .completeFail
        {
            disposition = .completeFail
            reason = ""
        } else {
            disposition = .incomplete
            reason = "arm_disposition_disagreement"
        }
        return Self(
            runID: comparison.runID,
            comparisonReceiptSHA256: comparisonSHA,
            disposition: disposition,
            incompleteReason: reason
        )
    }

    func validateAssumingValidatedComparison(
        comparison: PrimeValidationPairedComparisonReceiptV2,
        reference: PrimeValidationArmAggregateV2,
        candidate: PrimeValidationArmAggregateV2
    ) throws {
        try authority.validate()
        let expected = try Self.makeAssumingValidatedComparison(
            comparison: comparison,
            reference: reference,
            candidate: candidate
        )
        guard self == expected else {
            throw PrimeValidationDriverV2Error.invalidFinalReceipt
        }
    }

    public func validate(
        comparison: PrimeValidationPairedComparisonReceiptV2,
        reference: PrimeValidationArmAggregateV2,
        candidate: PrimeValidationArmAggregateV2,
        executionPlan: PrimeValidationExecutionPlanV2,
        executionPlanSHA256: String
    ) throws {
        try authority.validate()
        let expected = try Self.make(
            comparison: comparison,
            reference: reference,
            candidate: candidate,
            executionPlan: executionPlan,
            executionPlanSHA256: executionPlanSHA256
        )
        guard self == expected else {
            throw PrimeValidationDriverV2Error.invalidFinalReceipt
        }
    }
}
