// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore

public enum PrimeValidationContractError: Error, Equatable, Sendable {
    case invalidUTF8
    case inventoryByteLimitExceeded
    case inventoryLineLimitExceeded
    case inventoryTestCountLimitExceeded
    case invalidListFraming
    case invalidTestID(String)
    case duplicateTestID(String)
    case crossFrameworkDuplicate(String)
    case zeroInventory
    case invalidSHA256(String)
    case invalidArtifactPath(String)
    case invalidArtifactSet
    case invalidDuration
    case invalidProcessObservation
    case unsafeXML
    case malformedXML
    case invalidXUnitShape
    case invalidXUnitCount
    case unknownTransition(String)
    case duplicateTransition(String)
    case interleavedTransition(String)
    case terminalBeforeStart(String)
    case unfinishedTransition(String)
    case missingTerminalSummary
    case terminalSummaryMismatch
    case authorityViolation
}

public enum PrimeValidationFramework: String, Codable, CaseIterable, Sendable {
    case xctest
    case swiftTesting = "swift_testing"
}

public struct PrimeValidationContentBinding: Codable, Equatable, Sendable {
    public let byteCount: UInt64
    public let sha256: String

    public init(data: Data) {
        byteCount = UInt64(data.count)
        sha256 = PrimeSHA256.hexDigest(of: data)
    }

    public func validate() throws {
        guard Self.isSHA256(sha256) else {
            throw PrimeValidationContractError.invalidSHA256(sha256)
        }
    }

    static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
            }
    }
}

public struct PrimeValidationTestID:
    Codable,
    Comparable,
    Hashable,
    Sendable
{
    public let framework: PrimeValidationFramework
    public let rawValue: String

    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.framework.rawValue != rhs.framework.rawValue {
            return lhs.framework.rawValue < rhs.framework.rawValue
        }
        return lhs.rawValue < rhs.rawValue
    }

    public static func parse(
        _ rawValue: String,
        framework: PrimeValidationFramework
    ) throws -> Self {
        guard !rawValue.isEmpty,
              rawValue == rawValue.trimmingCharacters(in: .whitespacesAndNewlines),
              rawValue.utf8.allSatisfy({ $0 >= 0x21 && $0 <= 0x7e })
        else {
            throw PrimeValidationContractError.invalidTestID(rawValue)
        }

        let canonical: String
        if rawValue.contains("/") {
            canonical = rawValue
        } else if framework == .swiftTesting,
                  let separator = rawValue.lastIndex(of: ".") {
            canonical = String(rawValue[..<separator])
                + "/"
                + String(rawValue[rawValue.index(after: separator)...])
        } else {
            throw PrimeValidationContractError.invalidTestID(rawValue)
        }

        let components = canonical.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        guard components.count == 2,
              components[0].contains("."),
              !components[0].hasPrefix("."),
              !components[0].hasSuffix("."),
              !components[1].isEmpty,
              !components[0].contains(".."),
              (framework == .swiftTesting
                  ? components[1].hasSuffix("()")
                  : !components[1].hasSuffix("()"))
        else {
            throw PrimeValidationContractError.invalidTestID(rawValue)
        }
        return Self(framework: framework, rawValue: canonical)
    }

    private init(
        framework: PrimeValidationFramework,
        rawValue: String
    ) {
        self.framework = framework
        self.rawValue = rawValue
    }
}

public struct PrimeValidationInventory: Codable, Equatable, Sendable {
    static let maximumListBytes = 16 * 1024 * 1024
    static let maximumLineBytes = 16 * 1024
    static let maximumTestCount = 100_000

    public let xctestListBinding: PrimeValidationContentBinding
    public let swiftTestingListBinding: PrimeValidationContentBinding
    public let xctestIDs: [PrimeValidationTestID]
    public let swiftTestingIDs: [PrimeValidationTestID]

    public static func parse(
        xctestList: Data,
        swiftTestingList: Data
    ) throws -> Self {
        let xctest = try parseList(xctestList, framework: .xctest)
        let swiftTesting = try parseList(
            swiftTestingList,
            framework: .swiftTesting
        )
        let xctestRaw = Set(xctest.map(\.rawValue))
        if let duplicate = swiftTesting.first(where: {
            xctestRaw.contains($0.rawValue)
        }) {
            throw PrimeValidationContractError.crossFrameworkDuplicate(
                duplicate.rawValue
            )
        }
        let inventory = Self(
            xctestListBinding: .init(data: xctestList),
            swiftTestingListBinding: .init(data: swiftTestingList),
            xctestIDs: xctest,
            swiftTestingIDs: swiftTesting
        )
        try inventory.validate()
        return inventory
    }

    public var totalCount: Int {
        xctestIDs.count + swiftTestingIDs.count
    }

    public func identitySHA256() throws -> String {
        PrimeSHA256.hexDigest(of: try PrimeCanonicalJSON.encode(self))
    }

    public func validate() throws {
        try xctestListBinding.validate()
        try swiftTestingListBinding.validate()
        guard totalCount > 0 else {
            throw PrimeValidationContractError.zeroInventory
        }
        try Self.validateIDs(xctestIDs, framework: .xctest)
        try Self.validateIDs(swiftTestingIDs, framework: .swiftTesting)
        let xctestRaw = Set(xctestIDs.map(\.rawValue))
        guard swiftTestingIDs.allSatisfy({
            !xctestRaw.contains($0.rawValue)
        }) else {
            throw PrimeValidationContractError.invalidListFraming
        }
    }

    private static func parseList(
        _ data: Data,
        framework: PrimeValidationFramework
    ) throws -> [PrimeValidationTestID] {
        guard data.count <= maximumListBytes else {
            throw PrimeValidationContractError.inventoryByteLimitExceeded
        }

        var lineByteCount = 0
        var lineCount = 0
        for byte in data {
            guard byte != 0, byte != 13, byte != 27 else {
                throw PrimeValidationContractError.invalidUTF8
            }
            if byte == 10 {
                guard lineByteCount > 0 else {
                    throw PrimeValidationContractError.invalidListFraming
                }
                lineCount += 1
                guard lineCount <= maximumTestCount else {
                    throw PrimeValidationContractError
                        .inventoryTestCountLimitExceeded
                }
                lineByteCount = 0
            } else {
                lineByteCount += 1
                guard lineByteCount <= maximumLineBytes else {
                    throw PrimeValidationContractError
                        .inventoryLineLimitExceeded
                }
            }
        }
        if lineByteCount > 0 {
            lineCount += 1
            guard lineCount <= maximumTestCount else {
                throw PrimeValidationContractError
                    .inventoryTestCountLimitExceeded
            }
        }

        var observed = Set<String>()
        var result: [PrimeValidationTestID] = []
        result.reserveCapacity(lineCount)
        var lineStart = data.startIndex
        for index in data.indices where data[index] == 10 {
            guard let line = String(
                data: Data(data[lineStart..<index]),
                encoding: .utf8
            ) else {
                throw PrimeValidationContractError.invalidUTF8
            }
            let identifier = try PrimeValidationTestID.parse(
                line,
                framework: framework
            )
            guard observed.insert(identifier.rawValue).inserted else {
                throw PrimeValidationContractError.duplicateTestID(
                    identifier.rawValue
                )
            }
            result.append(identifier)
            lineStart = data.index(after: index)
        }
        if lineStart != data.endIndex {
            guard let line = String(
                data: Data(data[lineStart..<data.endIndex]),
                encoding: .utf8
            ) else {
                throw PrimeValidationContractError.invalidUTF8
            }
            let identifier = try PrimeValidationTestID.parse(
                line,
                framework: framework
            )
            guard observed.insert(identifier.rawValue).inserted else {
                throw PrimeValidationContractError.duplicateTestID(
                    identifier.rawValue
                )
            }
            result.append(identifier)
        }
        return result.sorted()
    }

    private static func validateIDs(
        _ identifiers: [PrimeValidationTestID],
        framework: PrimeValidationFramework
    ) throws {
        guard identifiers == identifiers.sorted(),
              Set(identifiers).count == identifiers.count,
              identifiers.allSatisfy({ $0.framework == framework })
        else {
            throw PrimeValidationContractError.invalidListFraming
        }
        for identifier in identifiers {
            guard try PrimeValidationTestID.parse(
                identifier.rawValue,
                framework: framework
            ) == identifier else {
                throw PrimeValidationContractError.invalidTestID(
                    identifier.rawValue
                )
            }
        }
    }
}

public enum PrimeValidationArtifactRole:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case sourceSnapshot = "source_snapshot"
    case packageLock = "package_lock"
    case testBundle = "test_bundle"
    case xctestList = "xctest_list"
    case swiftTestingList = "swift_testing_list"
    case parallelXCTestXUnit = "parallel_xctest_xunit"
    case sequentialXCTestTranscript = "sequential_xctest_transcript"
    case swiftTestingXUnit = "swift_testing_xunit"
    case parallelXCTestStandardOutputLog =
        "parallel_xctest_standard_output_log"
    case parallelXCTestStandardErrorLog =
        "parallel_xctest_standard_error_log"
    case sequentialXCTestStandardOutputLog =
        "sequential_xctest_standard_output_log"
    case sequentialXCTestStandardErrorLog =
        "sequential_xctest_standard_error_log"
    case swiftTestingStandardOutputLog =
        "swift_testing_standard_output_log"
    case swiftTestingStandardErrorLog =
        "swift_testing_standard_error_log"

    var permitsEmptyContent: Bool {
        switch self {
        case .parallelXCTestXUnit,
             .sequentialXCTestTranscript,
             .swiftTestingXUnit,
             .parallelXCTestStandardOutputLog,
             .parallelXCTestStandardErrorLog,
             .sequentialXCTestStandardOutputLog,
             .sequentialXCTestStandardErrorLog,
             .swiftTestingStandardOutputLog,
             .swiftTestingStandardErrorLog:
            true
        default:
            false
        }
    }
}

public struct PrimeValidationArtifactBinding:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeValidationArtifactRole
    public let relativePath: String
    public let content: PrimeValidationContentBinding

    public init(
        role: PrimeValidationArtifactRole,
        relativePath: String,
        content: PrimeValidationContentBinding
    ) {
        self.role = role
        self.relativePath = relativePath
        self.content = content
    }

    public func validate() throws {
        try content.validate()
        let components = relativePath.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        guard !relativePath.isEmpty,
              !relativePath.hasPrefix("/"),
              !relativePath.contains("\\"),
              components.allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." }),
              relativePath.utf8.allSatisfy({ $0 >= 0x21 && $0 != 0x7f }),
              content.byteCount > 0 || role.permitsEmptyContent
        else {
            throw PrimeValidationContractError.invalidArtifactPath(
                relativePath
            )
        }
    }
}

public struct PrimeValidationArtifactSet: Codable, Equatable, Sendable {
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
              Set(bindings.map(\.role))
                == Set(PrimeValidationArtifactRole.allCases)
        else {
            throw PrimeValidationContractError.invalidArtifactSet
        }
        try bindings.forEach { try $0.validate() }
    }
}

public struct PrimeValidationPhaseDurations:
    Codable,
    Equatable,
    Sendable
{
    public let leaseNanoseconds: UInt64
    public let planningNanoseconds: UInt64
    public let buildNanoseconds: UInt64
    public let stagingNanoseconds: UInt64
    public let executionNanoseconds: UInt64

    public init(
        leaseNanoseconds: UInt64,
        planningNanoseconds: UInt64,
        buildNanoseconds: UInt64,
        stagingNanoseconds: UInt64,
        executionNanoseconds: UInt64
    ) {
        self.leaseNanoseconds = leaseNanoseconds
        self.planningNanoseconds = planningNanoseconds
        self.buildNanoseconds = buildNanoseconds
        self.stagingNanoseconds = stagingNanoseconds
        self.executionNanoseconds = executionNanoseconds
    }

    public func validate() throws {
        let requiredValues = [
            leaseNanoseconds,
            planningNanoseconds,
            buildNanoseconds,
            executionNanoseconds,
        ]
        guard requiredValues.allSatisfy({ $0 > 0 }) else {
            throw PrimeValidationContractError.invalidDuration
        }
        let values = requiredValues + [stagingNanoseconds]
        var total: UInt64 = 0
        for value in values {
            let result = total.addingReportingOverflow(value)
            guard !result.overflow else {
                throw PrimeValidationContractError.invalidDuration
            }
            total = result.partialValue
        }
    }
}

public enum PrimeValidationProcessTermination:
    Codable,
    Equatable,
    Sendable
{
    case exited(Int32)
    case signaled(Int32)
    case timedOut
    case unobserved
}

public struct PrimeValidationProcessObservation:
    Codable,
    Equatable,
    Sendable
{
    public let termination: PrimeValidationProcessTermination
    public let containmentObserved: Bool
    public let exactReapObserved: Bool
    public let standardOutputDrained: Bool
    public let standardErrorDrained: Bool
    public let logOverflowObserved: Bool
    public let noTestsReported: Bool
    public let matchedTestCount: Int

    public init(
        termination: PrimeValidationProcessTermination,
        containmentObserved: Bool,
        exactReapObserved: Bool,
        standardOutputDrained: Bool,
        standardErrorDrained: Bool,
        logOverflowObserved: Bool,
        noTestsReported: Bool,
        matchedTestCount: Int
    ) {
        self.termination = termination
        self.containmentObserved = containmentObserved
        self.exactReapObserved = exactReapObserved
        self.standardOutputDrained = standardOutputDrained
        self.standardErrorDrained = standardErrorDrained
        self.logOverflowObserved = logOverflowObserved
        self.noTestsReported = noTestsReported
        self.matchedTestCount = matchedTestCount
    }

    public func validate() throws {
        guard matchedTestCount >= 0 else {
            throw PrimeValidationContractError.invalidProcessObservation
        }
        switch termination {
        case let .exited(code):
            guard code >= 0, code <= 255 else {
                throw PrimeValidationContractError.invalidProcessObservation
            }
        case let .signaled(signal):
            guard signal > 0, signal <= 128 else {
                throw PrimeValidationContractError.invalidProcessObservation
            }
        case .timedOut, .unobserved:
            break
        }
    }
}

public struct PrimeValidationAuthorityCeiling:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let processLaunchImplemented: Bool
    public let executorImplemented: Bool
    public let scientificAuthorityAuthorized: Bool
    public let trainingAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let statement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        processLaunchImplemented: false,
        executorImplemented: false,
        scientificAuthorityAuthorized: false,
        trainingAuthorityAuthorized: false,
        productAuthorityAuthorized: false,
        statement:
            "repository_validation_evidence_contract_only_no_process_launch_executor_scientific_training_or_product_authority"
    )

    public func validate() throws {
        guard self == .frozenV1 else {
            throw PrimeValidationContractError.authorityViolation
        }
    }
}

public enum PrimeValidationOptionalSkipPolicy {
    public struct Admission: Codable, Equatable, Sendable {
        public let rawID: String
        public let exactReason: String
    }

    public static let admissions: [Admission] = [
        .init(
            rawID: "PrimeCoreTests.PrimeDurableArtifactsTests/testGeneratedDescriptorPublishesSparseMultiGigabyteSafetensors",
            exactReason: "set PRIME_RUN_LARGE_ARTIFACT_TESTS=1"
        ),
        .init(
            rawID: "PrimeCoreTests.PrimeNativeContractMigrationTests/testOptInLivePinnedCompanionTransport",
            exactReason: "set PRIME_NATIVE_COMPANION_ROOT for the opt-in live pinned transport test"
        ),
    ]

    public static let allowedXCTestRawIDs = admissions.map(\.rawID)

    public static func identitySHA256() throws -> String {
        PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(admissions)
        )
    }
}

private struct PrimeParsedXUnitCase: Equatable {
    let identifier: String
    var failureObserved = false
    var errorObserved = false
    var skippedObserved = false
}

private struct PrimeParsedXUnit {
    let binding: PrimeValidationContentBinding
    let declaredTests: Int
    let declaredFailures: Int
    let declaredErrors: Int
    let declaredSkipped: Int
    let cases: [PrimeParsedXUnitCase]
}

private final class PrimeValidationXUnitParserDelegate:
    NSObject,
    XMLParserDelegate
{
    private(set) var parsed: PrimeParsedXUnit?
    private(set) var failure: PrimeValidationContractError?

    private let binding: PrimeValidationContentBinding
    private var stack: [String] = []
    private var suiteCount = 0
    private var declaredTests: Int?
    private var declaredFailures: Int?
    private var declaredErrors: Int?
    private var declaredSkipped: Int?
    private var cases: [PrimeParsedXUnitCase] = []
    private var currentCase: PrimeParsedXUnitCase?
    private var nonWhitespaceText = false

    init(binding: PrimeValidationContentBinding) {
        self.binding = binding
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        guard failure == nil else { return }
        let parent = stack.last
        switch elementName {
        case "testsuites":
            guard stack.isEmpty,
                  attributeDict.isEmpty
            else {
                fail(.invalidXUnitShape)
                return
            }
        case "testsuite":
            guard parent == "testsuites",
                  suiteCount == 0,
                  allowedAttributes(
                    attributeDict,
                    names: [
                        "name", "tests", "failures", "errors",
                        "skipped", "time",
                    ]
                  ),
                  attributeDict["name"] == "TestResults",
                  let tests = boundedCount(attributeDict["tests"]),
                  let failures = boundedCount(attributeDict["failures"]),
                  let errors = boundedCount(attributeDict["errors"]),
                  let time = attributeDict["time"],
                  isNonnegativeDecimal(time)
            else {
                fail(.invalidXUnitShape)
                return
            }
            let skipped: Int
            if let rawSkipped = attributeDict["skipped"] {
                guard let parsedSkipped = boundedCount(rawSkipped) else {
                    fail(.invalidXUnitCount)
                    return
                }
                skipped = parsedSkipped
            } else {
                skipped = 0
            }
            suiteCount = 1
            declaredTests = tests
            declaredFailures = failures
            declaredErrors = errors
            declaredSkipped = skipped
        case "testcase":
            guard parent == "testsuite",
                  currentCase == nil,
                  allowedAttributes(
                    attributeDict,
                    names: ["classname", "name", "time"]
                  ),
                  let className = attributeDict["classname"],
                  let name = attributeDict["name"],
                  let time = attributeDict["time"],
                  !className.isEmpty,
                  !name.isEmpty,
                  isNonnegativeDecimal(time)
            else {
                fail(.invalidXUnitShape)
                return
            }
            currentCase = PrimeParsedXUnitCase(
                identifier: className + "/" + name
            )
        case "failure", "error", "skipped":
            guard parent == "testcase",
                  currentCase != nil,
                  allowedAttributes(
                    attributeDict,
                    names: ["message", "type"]
                  )
            else {
                fail(.invalidXUnitShape)
                return
            }
            if elementName == "failure" {
                guard currentCase?.failureObserved == false else {
                    fail(.invalidXUnitShape)
                    return
                }
                currentCase?.failureObserved = true
            } else if elementName == "error" {
                guard currentCase?.errorObserved == false else {
                    fail(.invalidXUnitShape)
                    return
                }
                currentCase?.errorObserved = true
            } else {
                guard currentCase?.skippedObserved == false else {
                    fail(.invalidXUnitShape)
                    return
                }
                currentCase?.skippedObserved = true
            }
            guard terminalChildCount(currentCase) == 1 else {
                fail(.invalidXUnitShape)
                return
            }
        default:
            fail(.invalidXUnitShape)
            return
        }
        stack.append(elementName)
    }

    func parser(
        _ parser: XMLParser,
        foundCharacters string: String
    ) {
        guard !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }
        if let element = stack.last,
           element == "failure" || element == "error" || element == "skipped" {
            return
        }
        nonWhitespaceText = true
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard failure == nil else { return }
        guard stack.last == elementName else {
            fail(.invalidXUnitShape)
            return
        }
        if elementName == "testcase" {
            guard let currentCase else {
                fail(.invalidXUnitShape)
                return
            }
            cases.append(currentCase)
            self.currentCase = nil
        }
        stack.removeLast()
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        guard failure == nil,
              stack.isEmpty,
              !nonWhitespaceText,
              suiteCount == 1,
              currentCase == nil,
              let declaredTests,
              let declaredFailures,
              let declaredErrors,
              let declaredSkipped
        else {
            fail(.invalidXUnitShape)
            return
        }
        let identifiers = cases.map(\.identifier)
        guard Set(identifiers).count == identifiers.count,
              declaredTests == cases.count,
              declaredFailures
                == cases.filter(\.failureObserved).count,
              declaredErrors
                == cases.filter(\.errorObserved).count,
              declaredSkipped
                == cases.filter(\.skippedObserved).count
        else {
            fail(.invalidXUnitCount)
            return
        }
        parsed = PrimeParsedXUnit(
            binding: binding,
            declaredTests: declaredTests,
            declaredFailures: declaredFailures,
            declaredErrors: declaredErrors,
            declaredSkipped: declaredSkipped,
            cases: cases
        )
    }

    func parser(
        _ parser: XMLParser,
        parseErrorOccurred parseError: Error
    ) {
        fail(.malformedXML)
    }

    private func fail(_ error: PrimeValidationContractError) {
        if failure == nil { failure = error }
        parserAbort()
    }

    private func parserAbort() {
        // XMLParser cannot be retained safely from delegate callbacks. The
        // failure sentinel causes all subsequent callbacks to become no-ops.
    }

    private func allowedAttributes(
        _ attributes: [String: String],
        names: Set<String>
    ) -> Bool {
        Set(attributes.keys).isSubset(of: names)
    }

    private func boundedCount(_ raw: String?) -> Int? {
        guard let raw,
              !raw.isEmpty,
              raw.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }),
              let value = Int(raw),
              value >= 0,
              value <= 1_000_000
        else { return nil }
        return value
    }

    private func isNonnegativeDecimal(_ raw: String) -> Bool {
        // SwiftPM and Swift Testing interpolate Double seconds, including
        // scientific notation for fast tests. Accept only its finite,
        // nonnegative numeric grammar; timing never supplies process facts.
        guard !raw.isEmpty, raw.utf8.count <= 64,
              let range = raw.range(of: #"^(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?$"#,
                                    options: .regularExpression),
              range == raw.startIndex..<raw.endIndex,
              let value = Double(raw), value.isFinite, value >= 0 else { return false }
        if value == 0 {
            // Reject underflow instead of silently converting a nonzero time
            // to zero. Zero with an exponent remains an exact zero.
            let mantissa = raw.split(whereSeparator: { $0 == "e" || $0 == "E" })[0]
            guard !mantissa.contains(where: { $0 >= "1" && $0 <= "9" }) else { return false }
        }
        return true
    }

    private func terminalChildCount(
        _ value: PrimeParsedXUnitCase?
    ) -> Int {
        guard let value else { return 0 }
        return [
            value.failureObserved,
            value.errorObserved,
            value.skippedObserved,
        ].filter { $0 }.count
    }
}

private enum PrimeValidationXUnitParser {
    private static let maximumXMLBytes = 64 * 1024 * 1024

    static func parse(_ data: Data) throws -> PrimeParsedXUnit {
        guard data.count <= maximumXMLBytes,
              let source = String(data: data, encoding: .utf8)
        else {
            throw PrimeValidationContractError.invalidUTF8
        }
        let uppercase = source.uppercased()
        guard !uppercase.contains("<!DOCTYPE"),
              !uppercase.contains("<!ENTITY")
        else {
            throw PrimeValidationContractError.unsafeXML
        }
        let binding = PrimeValidationContentBinding(data: data)
        let delegate = PrimeValidationXUnitParserDelegate(binding: binding)
        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        parser.delegate = delegate
        guard parser.parse(),
              delegate.failure == nil,
              let parsed = delegate.parsed
        else {
            throw delegate.failure ?? .malformedXML
        }
        return parsed
    }
}

public struct PrimeValidationParallelXCTestXUnitObservation:
    Codable,
    Equatable,
    Sendable
{
    public let contentBinding: PrimeValidationContentBinding
    public let observedRawIDs: [String]
    public let failedRawIDs: [String]
    public let explicitSkippedRawIDs: [String]
    public let declaredTests: Int
    public let declaredFailures: Int
    public let declaredErrors: Int
    public let nonAuthoritativeSkippedElementCount: Int
    public let skipAuthorityEstablished: Bool

    public static func parse(_ data: Data) throws -> Self {
        let parsed = try PrimeValidationXUnitParser.parse(data)
        let identifiers = try parsed.cases.map {
            try PrimeValidationTestID.parse(
                $0.identifier,
                framework: .xctest
            ).rawValue
        }
        let observed = identifiers.sorted()
        let failed = parsed.cases.filter {
            $0.failureObserved || $0.errorObserved
        }.map(\.identifier).sorted()
        let explicitlySkipped = parsed.cases.filter(\.skippedObserved)
            .map(\.identifier).sorted()
        return Self(
            contentBinding: parsed.binding,
            observedRawIDs: observed,
            failedRawIDs: failed,
            explicitSkippedRawIDs: explicitlySkipped,
            declaredTests: parsed.declaredTests,
            declaredFailures: parsed.declaredFailures,
            declaredErrors: parsed.declaredErrors,
            nonAuthoritativeSkippedElementCount: parsed.declaredSkipped,
            skipAuthorityEstablished: false
        )
    }

    public func validate() throws {
        try contentBinding.validate()
        guard !skipAuthorityEstablished,
              observedRawIDs == observedRawIDs.sorted(),
              Set(observedRawIDs).count == observedRawIDs.count,
              failedRawIDs == failedRawIDs.sorted(),
              Set(failedRawIDs).isSubset(of: Set(observedRawIDs)),
              explicitSkippedRawIDs == explicitSkippedRawIDs.sorted(),
              Set(explicitSkippedRawIDs).isSubset(
                of: Set(observedRawIDs)
              ),
              Set(failedRawIDs).isDisjoint(
                with: Set(explicitSkippedRawIDs)
              ),
              declaredTests == observedRawIDs.count,
              declaredFailures + declaredErrors == failedRawIDs.count,
              nonAuthoritativeSkippedElementCount
                == explicitSkippedRawIDs.count
        else {
            throw PrimeValidationContractError.invalidXUnitCount
        }
    }
}

public struct PrimeValidationSwiftTestingXUnitObservation:
    Codable,
    Equatable,
    Sendable
{
    public let contentBinding: PrimeValidationContentBinding
    public let observedRawIDs: [String]
    public let failedRawIDs: [String]
    public let errorRawIDs: [String]
    public let skippedRawIDs: [String]
    public let declaredTests: Int
    public let declaredFailures: Int
    public let declaredErrors: Int
    public let declaredSkipped: Int

    public static func parse(_ data: Data) throws -> Self {
        let parsed = try PrimeValidationXUnitParser.parse(data)
        let identifierByRawID = try Dictionary(
            uniqueKeysWithValues: parsed.cases.map {
                (
                    $0.identifier,
                    try PrimeValidationTestID.parse(
                        $0.identifier,
                        framework: .swiftTesting
                    ).rawValue
                )
            }
        )
        return Self(
            contentBinding: parsed.binding,
            observedRawIDs: identifierByRawID.values.sorted(),
            failedRawIDs: parsed.cases.filter(\.failureObserved)
                .map { identifierByRawID[$0.identifier]! }.sorted(),
            errorRawIDs: parsed.cases.filter(\.errorObserved)
                .map { identifierByRawID[$0.identifier]! }.sorted(),
            skippedRawIDs: parsed.cases.filter(\.skippedObserved)
                .map { identifierByRawID[$0.identifier]! }.sorted(),
            declaredTests: parsed.declaredTests,
            declaredFailures: parsed.declaredFailures,
            declaredErrors: parsed.declaredErrors,
            declaredSkipped: parsed.declaredSkipped
        )
    }

    public func validate() throws {
        try contentBinding.validate()
        let observed = Set(observedRawIDs)
        guard observedRawIDs == observedRawIDs.sorted(),
              observed.count == observedRawIDs.count,
              failedRawIDs == failedRawIDs.sorted(),
              errorRawIDs == errorRawIDs.sorted(),
              skippedRawIDs == skippedRawIDs.sorted(),
              Set(failedRawIDs).isSubset(of: observed),
              Set(errorRawIDs).isSubset(of: observed),
              Set(skippedRawIDs).isSubset(of: observed),
              Set(failedRawIDs).isDisjoint(with: Set(errorRawIDs)),
              Set(failedRawIDs).isDisjoint(with: Set(skippedRawIDs)),
              Set(errorRawIDs).isDisjoint(with: Set(skippedRawIDs)),
              declaredTests == observedRawIDs.count,
              declaredFailures == failedRawIDs.count,
              declaredErrors == errorRawIDs.count,
              declaredSkipped == skippedRawIDs.count
        else {
            throw PrimeValidationContractError.invalidXUnitCount
        }
    }
}
