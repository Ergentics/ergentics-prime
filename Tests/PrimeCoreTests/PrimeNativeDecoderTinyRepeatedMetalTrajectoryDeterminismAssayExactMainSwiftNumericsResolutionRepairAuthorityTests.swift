// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityTests:
    XCTestCase
{
    typealias Authority =
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()
        throws
    {
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validateExactV1())
        requireSendable(Authority.self)

        let canonical = try authority.canonicalData()
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Authority.canonicalSHA256)
        XCTAssertEqual(try Authority.decodeCanonical(canonical), authority)
        XCTAssertEqual(
            try Authority.decodeCanonical(canonical).canonicalData(),
            canonical)

        XCTAssertEqual(
            authority.exactMainRun.stage5AuthorityCanonicalSHA256,
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityV1
                .canonicalSHA256)
        XCTAssertEqual(
            authority.exactMainRun.mergeRevision,
            "1193a1f11a869f89b25706dbd270520dd61b37a8")
        XCTAssertEqual(authority.exactMainRun.workflowRunID, 31_745_220_457)
        XCTAssertEqual(authority.exactMainRun.workflowRunNumber, 101)
        XCTAssertEqual(authority.exactMainRun.checkSuiteID, 86_124_999_845)
        XCTAssertEqual(authority.exactMainRun.runAttempt, 1)
        XCTAssertTrue(authority.exactMainRun.previousAttemptAbsent)
        XCTAssertEqual(authority.exactMainRun.exactHeadPushRunCount, 1)
        XCTAssertEqual(authority.exactMainRun.rerunCount, 0)
        XCTAssertEqual(authority.exactMainRun.artifactCount, 0)
        XCTAssertEqual(authority.exactMainRun.activeJobConclusion, "success")
        XCTAssertEqual(authority.exactMainRun.reviewedJobConclusion, "failure")
        XCTAssertEqual(authority.exactMainRun.reviewedFailedStepIndex, 5)
        XCTAssertEqual(authority.reviewedLog.byteCount, 316_010)
        XCTAssertEqual(authority.reviewedLog.lineFeedCount, 2_852)
        XCTAssertTrue(authority.reviewedLog.byteOrderMarkPresent)
        XCTAssertTrue(authority.reviewedLog.endsWithLineFeed)
        XCTAssertEqual(
            authority.reviewedLog.sha256,
            "67066aa642f293cc08262d3c4e40111b92d161dad00e25fff3eba02e59a1227b")
        XCTAssertEqual(authority.reviewedLog.processExitCode, 1)

        XCTAssertEqual(authority.secureFetch.stepConclusion, "success")
        XCTAssertEqual(authority.secureFetch.invocationCount, 1)
        XCTAssertEqual(authority.secureFetch.completionCount, 1)
        XCTAssertEqual(authority.secureFetch.authenticatedDepthOneFetchCount, 1)
        XCTAssertEqual(authority.secureFetch.submoduleUpdateInvocationCount, 1)
        XCTAssertEqual(authority.secureFetch.mlxCloneCount, 1)
        XCTAssertEqual(authority.secureFetch.mlxCCloneCount, 1)
        XCTAssertEqual(authority.secureFetch.workflowAuthoredRetryCount, 0)
        XCTAssertEqual(authority.secureFetch.gitInternalRetryScheduledCount, 0)
        XCTAssertEqual(authority.secureFetch.tlsFailureCount, 0)
        XCTAssertEqual(authority.secureFetch.tlsVerificationBypassCount, 0)
        XCTAssertEqual(authority.secureFetch.customCAInstallationCount, 0)

        XCTAssertEqual(authority.failure.rootExecutedTestCount, 52)
        XCTAssertEqual(authority.failure.stage5AuthorityTestExecutedCount, 1)
        XCTAssertEqual(authority.failure.isolatedAttempts.count, 4)
        XCTAssertEqual(
            authority.failure.isolatedAttempts.map(\.swiftTestInvocationCount),
            [1, 1, 1, 0])
        XCTAssertEqual(
            authority.failure.isolatedAttempts.map(\.buildCompleted),
            [true, true, false, false])
        XCTAssertEqual(
            authority.failure.isolatedAttempts.map(\.testExecutionStarted),
            [true, true, false, false])
        XCTAssertEqual(
            authority.failure.isolatedAttempts.map(\.testSuiteCompleted),
            [true, true, false, false])
        XCTAssertEqual(
            authority.failure.isolatedAttempts.map(\.executedTestCount),
            [1, 1, 0, 0])
        XCTAssertEqual(authority.failure.expectedIsolatedTestCount, 6)
        XCTAssertEqual(authority.failure.completedIsolatedTestCount, 2)
        XCTAssertEqual(authority.failure.observedWholeTestCount, 54)
        XCTAssertEqual(
            authority.failure.totalSwiftNumericsFetchAnnouncementCount,
            4)
        XCTAssertEqual(authority.failure.totalSwiftNumericsCacheFetchCount, 3)
        XCTAssertEqual(
            authority.failure.totalSwiftNumericsWorkingCopyCreationCount,
            3)
        XCTAssertEqual(authority.failure.totalSwiftNumericsResolutionCount, 3)
        XCTAssertEqual(authority.failure.totalPublicCloneAttemptCount, 1)
        XCTAssertEqual(authority.failure.totalDNSFailureCount, 1)
        XCTAssertEqual(authority.failure.publicDependencyTLSFailureCount, 0)
        XCTAssertEqual(
            authority.failure.publicDependencyTLSVerificationBypassCount,
            0)
        XCTAssertEqual(authority.failure.workflowAuthoredRetryCount, 0)
        XCTAssertEqual(authority.failure.gitInternalRetryScheduledCount, 0)
        XCTAssertEqual(authority.failure.metalLauncherInvocationCount, 0)
        XCTAssertEqual(
            authority.failure.maintainedRuntimeLauncherInvocationCount,
            0)
        XCTAssertEqual(authority.failure.tokenizerLauncherInvocationCount, 0)
        XCTAssertEqual(authority.failure.stage5LauncherInvocationCount, 0)
        XCTAssertEqual(authority.failure.stage5ReceiptCount, 0)

        XCTAssertTrue(
            authority.resolutionRepair
                .sourceCheckoutValidatedAfterSuccessfulRootTests)
        XCTAssertTrue(
            authority.resolutionRepair.sourceCheckoutRepositoryRootValidated)
        XCTAssertTrue(authority.resolutionRepair.sourceCheckoutOriginValidated)
        XCTAssertFalse(authority.resolutionRepair.sourceCheckoutIsBare)
        XCTAssertEqual(
            authority.resolutionRepair.sourceCheckoutExactRemoteNames,
            ["origin"])
        XCTAssertEqual(
            authority.resolutionRepair.sourceCheckoutOriginURLValueCount,
            1)
        XCTAssertEqual(
            authority.resolutionRepair.sourceCheckoutExpectedOrigin,
            authority.resolutionRepair.rootSwiftNumericsCacheRepositoryPath)
        XCTAssertTrue(
            authority.resolutionRepair
                .sourceCheckoutOriginEqualsCacheRepositoryPathRequired)
        XCTAssertTrue(
            authority.resolutionRepair
                .cacheRepositoryMustExistAsPhysicalDirectory)
        XCTAssertFalse(authority.resolutionRepair.cacheRepositorySymlinkAuthorized)
        XCTAssertTrue(authority.resolutionRepair.cacheRepositoryIsBare)
        XCTAssertEqual(
            authority.resolutionRepair.cacheRepositoryExactRemoteNames,
            ["origin"])
        XCTAssertEqual(
            authority.resolutionRepair.cacheRepositoryOriginURLValueCount,
            1)
        XCTAssertEqual(
            authority.resolutionRepair.cacheRepositoryExpectedOrigin,
            authority.resolutionRepair.exactMappedOrigin)
        XCTAssertTrue(authority.resolutionRepair.cacheRepositoryOriginValidated)
        XCTAssertTrue(
            authority.resolutionRepair.cacheRepositoryContainsExactRevision)
        XCTAssertEqual(
            authority.resolutionRepair.cacheRepositoryExactRevisionObjectType,
            "commit")
        XCTAssertTrue(
            authority.resolutionRepair
                .cacheRepositoryPeeledCommitEqualsExactRevision)
        XCTAssertEqual(
            authority.resolutionRepair.cacheRepositoryPinnedVersionTag,
            "refs/tags/1.1.1")
        XCTAssertTrue(
            authority.resolutionRepair
                .cacheRepositoryPinnedVersionTagPeeledCommitEqualsExactRevision)
        XCTAssertFalse(
            authority.resolutionRepair.cacheRepositoryHEADMustEqualExactRevision)
        XCTAssertFalse(
            authority.resolutionRepair
                .cacheRepositoryWorkingTreeCleanStatusApplicable)
        XCTAssertTrue(authority.resolutionRepair.mappingActivatedBeforeFirstIsolatedBuild)
        XCTAssertEqual(
            authority.resolutionRepair.mappedIsolatedSwiftTestInvocationCount,
            4)
        XCTAssertEqual(authority.resolutionRepair.gitConfigCountAfterRepair, 3)
        XCTAssertEqual(
            authority.resolutionRepair.localMappingTemplate,
            "url.file://${numerics_cache}/.insteadOf=https://github.com/apple/swift-numerics")
        XCTAssertEqual(
            authority.resolutionRepair.gitConfigKeyOrder,
            [
                "url.file://${mlx_bare}/.insteadOf",
                "url.file://${numerics_cache}/.insteadOf",
                "protocol.file.allow",
            ])
        XCTAssertTrue(authority.resolutionRepair.existingMLXMappingPreserved)
        XCTAssertTrue(
            authority.resolutionRepair.existingFileProtocolSettingPreserved)
        XCTAssertTrue(authority.resolutionRepair.allLaterIsolatedBuildsMapped)
        XCTAssertTrue(
            authority.resolutionRepair.mappingRemovedAfterFinalIsolatedBuild)
        XCTAssertFalse(
            authority.resolutionRepair
                .publicSwiftNumericsFetchAfterMappingAuthorized)
        XCTAssertFalse(authority.resolutionRepair.packageManifestMutationAuthorized)
        XCTAssertFalse(authority.resolutionRepair.packageResolvedMutationAuthorized)
        XCTAssertTrue(
            authority.resolutionRepair.packageResolvedBytePreservationRequired)
        XCTAssertFalse(authority.resolutionRepair.securePrivateFetchMutationAuthorized)
        XCTAssertFalse(authority.resolutionRepair.workflowJobTopologyMutationAuthorized)
        XCTAssertFalse(authority.resolutionRepair.workflowTimeoutMutationAuthorized)

        XCTAssertEqual(authority.repairScope.exactAuthorityClosurePathCount, 5)
        XCTAssertEqual(authority.repairScope.authorityRootTestCount, 53)
        XCTAssertEqual(authority.repairScope.isolatedTestCount, 6)
        XCTAssertEqual(authority.repairScope.authorityFocusedWholeTestCount, 59)
        XCTAssertEqual(authority.repairScope.metalTestCount, 44)
        XCTAssertEqual(authority.repairScope.maintainedRuntimeTestCount, 1)
        XCTAssertEqual(authority.repairScope.maintainedRuntimeReceiptCount, 1)
        XCTAssertEqual(authority.repairScope.tokenizerTestCount, 1)
        XCTAssertEqual(authority.repairScope.tokenizerReceiptCount, 1)
        XCTAssertEqual(authority.repairScope.preStage5TestCount, 105)
        XCTAssertEqual(authority.repairScope.stage5LauncherInvocationCount, 0)
        XCTAssertEqual(authority.repairScope.stage5ReceiptCount, 0)
        XCTAssertEqual(authority.repairScope.exactFutureMechanicsPathCount, 6)
        XCTAssertTrue(authority.repairScope.futureMechanicsScopeUnchanged)
        XCTAssertEqual(authority.repairScope.futureStage5DirectXCTestCount, 1)
        XCTAssertEqual(authority.repairScope.futureMechanicsTotalTestCount, 106)
        XCTAssertTrue(authority.ceiling.pureAuthorityNoRepairExecutionEvidence)
        XCTAssertTrue(authority.ceiling.failedRunIsAuthorityClosureFailure)
        XCTAssertFalse(authority.ceiling.failedRunIsStage5MechanicsAttempt)
        XCTAssertFalse(authority.ceiling.failedRunConsumesStage5MechanicsOpportunity)
        XCTAssertTrue(authority.ceiling.oneExactMainRepairClosureExecutionAuthorized)
        XCTAssertTrue(
            authority.ceiling
                .stage5MechanicsOpportunityPreservedAfterGreenRepairClosure)
        XCTAssertTrue(falseCeilingClaims(authority.ceiling).allSatisfy { !$0 })

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        let paths = allPaths(in: object)
        let leafPaths = paths.filter { path in
            guard let value = value(at: path, in: object) else { return false }
            return !(value is [String: Any]) && !(value is [Any])
        }
        let dictionaryPaths = paths.filter {
            value(at: $0, in: object) is [String: Any]
        }
        let arrayPaths = paths.filter {
            value(at: $0, in: object) is [Any]
        }
        XCTAssertGreaterThan(leafPaths.count, 150)
        XCTAssertGreaterThan(dictionaryPaths.count, 7)
        XCTAssertGreaterThan(arrayPaths.count, 4)

        for path in leafPaths {
            var mutated: Any = object
            let original = try XCTUnwrap(value(at: path, in: mutated))
            try setValue(mutatedScalar(original), at: path, in: &mutated)
            assertRejected(mutated, label: "scalar \(pathLabel(path))")
        }

        for (index, path) in dictionaryPaths.enumerated() {
            var unknown: Any = object
            var dictionary = try XCTUnwrap(
                value(at: path, in: unknown) as? [String: Any])
            dictionary["unknown_stage5_swift_numerics_repair_field_\(index)"] =
                index
            try setValue(dictionary, at: path, in: &unknown)
            assertRejected(unknown, label: "unknown \(pathLabel(path))")

            guard !dictionary.isEmpty,
                  let key = dictionary.keys.sorted().first(where: {
                      !$0.hasPrefix("unknown_stage5_")
                  })
            else { continue }
            var removed: Any = object
            var removedDictionary = try XCTUnwrap(
                value(at: path, in: removed) as? [String: Any])
            removedDictionary.removeValue(forKey: key)
            try setValue(removedDictionary, at: path, in: &removed)
            assertRejected(removed, label: "removed \(pathLabel(path)).\(key)")
        }

        for path in arrayPaths {
            let array = try XCTUnwrap(value(at: path, in: object) as? [Any])
            if !array.isEmpty {
                var shortened: Any = object
                var changed = array
                changed.removeLast()
                try setValue(changed, at: path, in: &shortened)
                assertRejected(shortened, label: "shortened \(pathLabel(path))")

                var extended: Any = object
                changed = array
                changed.append(array[0])
                try setValue(changed, at: path, in: &extended)
                assertRejected(extended, label: "extended \(pathLabel(path))")
            }
            if let differentIndex = firstElementDifferentFromZero(in: array) {
                var reordered: Any = object
                var changed = array
                changed.swapAt(0, differentIndex)
                try setValue(changed, at: path, in: &reordered)
                assertRejected(reordered, label: "reordered \(pathLabel(path))")
            }
        }

        var nullMutation: Any = object
        try setValue(NSNull(), at: leafPaths[0], in: &nullMutation)
        assertRejected(nullMutation, label: "null \(pathLabel(leafPaths[0]))")

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(canonical + Data([0x0a])))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(duplicateFirstTopLevelKey(in: canonical)))

        let sourceURL = repositoryRoot().appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthority.swift")
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        XCTAssertEqual(
            sourceText.components(separatedBy: "import Foundation").count - 1,
            1)
        for forbidden in [
            "import CoreGraphics",
            "import Metal",
            "import MLX",
            "import MLXNN",
            "import MLXOptimizers",
            "FileManager",
            "FileHandle",
            "URLSession",
            "Process(",
            "posix_spawn",
            "execve(",
        ] {
            XCTAssertFalse(sourceText.contains(forbidden), forbidden)
        }
        XCTAssertFalse(sourceText.contains("__CANONICAL_SHA256__"))
    }

    private func falseCeilingClaims(
        _ ceiling: PrimeNativeDecoderStage5SwiftNumericsRepairCeilingV1
    ) -> [Bool] {
        [
            ceiling.failedRunIsStage5MechanicsAttempt,
            ceiling.failedRunConsumesStage5MechanicsOpportunity,
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.genericNetworkRetryAuthorized,
            ceiling.tlsOrCARepairAuthorized,
            ceiling.secureFetchMutationAuthorized,
            ceiling.stage5MechanicsExecuted,
            ceiling.stage5ResultEstablished,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.crossDeviceClaimAuthorized,
            ceiling.stage6Authorized,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.generalTrainingAuthorized,
            ceiling.generalTrainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.candidateAdmissionGranted,
            ceiling.downstreamTrialAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private enum PathComponent: Equatable {
        case key(String)
        case index(Int)
    }

    private func allPaths(in root: Any) -> [[PathComponent]] {
        var result = [[PathComponent]]()
        func walk(_ value: Any, path: [PathComponent]) {
            result.append(path)
            if let dictionary = value as? [String: Any] {
                for key in dictionary.keys.sorted() {
                    walk(dictionary[key]!, path: path + [.key(key)])
                }
            } else if let array = value as? [Any] {
                for index in array.indices {
                    walk(array[index], path: path + [.index(index)])
                }
            }
        }
        walk(root, path: [])
        return result
    }

    private func value(at path: [PathComponent], in root: Any) -> Any? {
        var current: Any = root
        for component in path {
            switch component {
            case .key(let key):
                guard let dictionary = current as? [String: Any],
                      let next = dictionary[key]
                else { return nil }
                current = next
            case .index(let index):
                guard let array = current as? [Any],
                      array.indices.contains(index)
                else { return nil }
                current = array[index]
            }
        }
        return current
    }

    private func setValue(
        _ replacement: Any,
        at path: [PathComponent],
        in root: inout Any
    ) throws {
        guard let first = path.first else {
            root = replacement
            return
        }
        let tail = Array(path.dropFirst())
        switch first {
        case .key(let key):
            var dictionary = try XCTUnwrap(root as? [String: Any])
            var child = try XCTUnwrap(dictionary[key])
            try setValue(replacement, at: tail, in: &child)
            dictionary[key] = child
            root = dictionary
        case .index(let index):
            var array = try XCTUnwrap(root as? [Any])
            var child = array[index]
            try setValue(replacement, at: tail, in: &child)
            array[index] = child
            root = array
        }
    }

    private func mutatedScalar(_ value: Any) -> Any {
        if let string = value as? String {
            return string + "_drift"
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            if CFNumberIsFloatType(number) {
                return number.doubleValue + 1.25
            }
            return number.int64Value == Int64.max
                ? number.int64Value - 1
                : number.int64Value + 1
        }
        return "unexpected_scalar_drift"
    }

    private func firstElementDifferentFromZero(in array: [Any]) -> Int? {
        guard array.count > 1,
              let first = try? JSONSerialization.data(
                  withJSONObject: [array[0]],
                  options: [.sortedKeys, .withoutEscapingSlashes])
        else { return nil }
        return array.indices.dropFirst().first { index in
            guard let candidate = try? JSONSerialization.data(
                withJSONObject: [array[index]],
                options: [.sortedKeys, .withoutEscapingSlashes])
            else { return false }
            return candidate != first
        }
    }

    private func assertRejected(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let data = try? JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes])
        else {
            XCTFail(label, file: file, line: line)
            return
        }
        XCTAssertThrowsError(
            try Authority.decodeCanonical(data),
            label,
            file: file,
            line: line)
    }

    private func pathLabel(_ path: [PathComponent]) -> String {
        if path.isEmpty { return "$" }
        return path.reduce("$") { partial, component in
            switch component {
            case .key(let key): return partial + "." + key
            case .index(let index): return partial + "[\(index)]"
            }
        }
    }

    private func duplicateFirstTopLevelKey(in data: Data) throws -> Data {
        let text = try XCTUnwrap(String(data: data, encoding: .utf8))
        let firstQuote = try XCTUnwrap(text.firstIndex(of: "\""))
        let keyStart = text.index(after: firstQuote)
        let keyEnd = try XCTUnwrap(text[keyStart...].firstIndex(of: "\""))
        let key = String(text[keyStart ..< keyEnd])
        guard text.first == "{" else {
            throw PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityError
                .contractDrift
        }
        return Data(("{\"\(key)\":null," + text.dropFirst()).utf8)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
