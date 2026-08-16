// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeSecureChildProcessEvidenceImplementationAuthorityTests:
    XCTestCase
{
    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        typealias Authority =
            PrimeSecureChildProcessEvidenceImplementationAuthorityV1
        let authority = Authority.frozenV1

        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.schemaID,
            "prime_secure_child_process_evidence_implementation_authority_schema_v1")
        XCTAssertEqual(
            authority.authorityID,
            "prime_secure_child_process_evidence_implementation_authority_v1")

        let predecessor = authority.designPredecessor
        XCTAssertEqual(
            predecessor.authorityID,
            PrimeSecureChildProcessEvidenceDesignAuthorityV1
                .frozenV1.authorityID)
        XCTAssertEqual(
            predecessor.canonicalSHA256,
            PrimeSecureChildProcessEvidenceDesignAuthorityV1
                .canonicalSHA256)
        XCTAssertTrue(predecessor.designAuthorityEstablished)
        XCTAssertFalse(predecessor.implementationAuthorizedByPredecessor)

        let closure = authority.exactMainClosure
        XCTAssertEqual(
            closure.mergeRevision,
            "bd8bd792ad77344c7c6b77de0459c1b53a6abd0b")
        XCTAssertEqual(
            closure.mergeTree,
            "4fe40b0de8e38dad1837905e15cfbe73518b612b")
        XCTAssertEqual(
            closure.orderedParents,
            [
                "7077b6d2195e847bdff583e945e58d6c3b042d63",
                "756dc967768029d5e11f46ede79e7447ae4297a9",
            ])
        XCTAssertEqual(closure.pullRequestNumber, 118)
        XCTAssertTrue(closure.signedMergeVerified)
        XCTAssertEqual(closure.workflowRunID, 31_922_080_458)
        XCTAssertEqual(closure.workflowRunNumber, 133)
        XCTAssertEqual(closure.workflowAttempt, 1)
        XCTAssertEqual(closure.checkSuiteID, 86_573_644_107)
        XCTAssertEqual(closure.event, "push")
        XCTAssertTrue(closure.previousAttemptURLIsNull)
        XCTAssertEqual(closure.workflowRerunCount, 0)
        XCTAssertEqual(closure.workflowConclusion, "success")
        XCTAssertEqual(closure.activeJobID, 95_103_468_969)
        XCTAssertEqual(closure.reviewedJobID, 95_103_856_298)
        XCTAssertEqual(closure.activeLatinTestCount, 116)
        XCTAssertEqual(closure.activeLatinFailureCount, 0)
        XCTAssertEqual(closure.rootTestCount, 64)
        XCTAssertEqual(closure.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(closure.isolatedTestCount, 6)
        XCTAssertEqual(closure.focusedWholeTestCount, 70)
        XCTAssertEqual(closure.retainedLiveTestCount, 46)
        XCTAssertEqual(closure.aggregateTestCount, 116)
        XCTAssertEqual(closure.designAuthorityMethodStartCount, 1)
        XCTAssertEqual(closure.designAuthorityMethodPassCount, 1)
        XCTAssertEqual(closure.actionsArtifactCount, 0)
        XCTAssertEqual(closure.stage7JobCount, 0)
        XCTAssertEqual(closure.stage7LauncherInvocationCount, 0)
        XCTAssertEqual(closure.stage7ProductInvocationCount, 0)
        XCTAssertEqual(closure.stage7SupervisorInvocationCount, 0)
        XCTAssertEqual(closure.stage7ReceiptCount, 0)
        XCTAssertEqual(closure.secureChildFixtureInvocationCount, 0)
        XCTAssertEqual(closure.secureChildCaptureInvocationCount, 0)
        XCTAssertEqual(closure.leaseAcquisitionInvocationCount, 0)
        XCTAssertEqual(closure.pythonInterpreterInvocationCount, 0)
        XCTAssertEqual(closure.newCppImplementationInvocationCount, 0)
        XCTAssertTrue(closure.retainedMLXCompiledExistingCppDependency)
        XCTAssertTrue(closure.retainedMLXCopiedExistingPythonResources)

        let scaffold = authority.authorityScaffold
        XCTAssertEqual(scaffold.exactOrderedChangedPaths.count, 5)
        XCTAssertEqual(scaffold.activeLatinTestCount, 116)
        XCTAssertEqual(scaffold.rootTestCount, 65)
        XCTAssertEqual(scaffold.isolatedTestCount, 6)
        XCTAssertEqual(scaffold.focusedWholeTestCount, 71)
        XCTAssertEqual(scaffold.retainedLiveTestCount, 46)
        XCTAssertEqual(scaffold.aggregateTestCount, 117)
        XCTAssertEqual(scaffold.embeddedProvenanceRecordCount, 500)
        XCTAssertEqual(scaffold.processMechanicsInvocationCount, 0)
        XCTAssertEqual(scaffold.fixtureInvocationCount, 0)
        XCTAssertEqual(scaffold.leaseInvocationCount, 0)
        XCTAssertEqual(scaffold.hostedDiagnosticEmissionCount, 0)

        let scope = authority.implementationScope
        XCTAssertEqual(scope.exactPathCount, 13)
        XCTAssertEqual(scope.exactOrderedPaths.count, 13)
        XCTAssertEqual(
            scope.exactOrderedPaths.map(\.ordinal),
            Array(1 ... 13))
        XCTAssertEqual(Set(scope.exactOrderedPaths.map(\.path)).count, 13)
        XCTAssertEqual(scope.addedSourcePathCount, 4)
        XCTAssertEqual(scope.modifiedSourcePathCount, 3)
        XCTAssertEqual(scope.addedTestPathCount, 1)
        XCTAssertEqual(scope.modifiedTestPathCount, 2)
        XCTAssertEqual(scope.integrationPathCount, 3)
        XCTAssertTrue(scope.onlyThesePathsAuthorized)
        XCTAssertTrue(scope.implementationMayBeginAfterAuthorityClosure)
        XCTAssertFalse(scope.implementationExecutionAuthorized)
        XCTAssertEqual(scope.expectedRootTestCount, 77)
        XCTAssertEqual(scope.expectedIsolatedTestCount, 6)
        XCTAssertEqual(scope.expectedFocusedWholeTestCount, 83)
        XCTAssertEqual(scope.expectedRetainedLiveTestCount, 46)
        XCTAssertEqual(scope.expectedAggregateTestCount, 129)
        XCTAssertEqual(scope.expectedEmbeddedProvenanceRecordCount, 505)

        let api = authority.apiSurface
        XCTAssertEqual(api.orderedAuthorizedInternalTypeNames.count, 7)
        XCTAssertTrue(api.newTypesInternalOnly)
        XCTAssertFalse(api.publicGenericExecutableAuthorityAdded)
        XCTAssertFalse(api.publicArbitraryArgumentAuthorityAdded)
        XCTAssertFalse(api.publicArbitraryEnvironmentAuthorityAdded)
        XCTAssertFalse(api.processPlanCodable)
        XCTAssertFalse(api.processEvidenceCodable)
        XCTAssertFalse(api.trustedCaptureCodable)
        XCTAssertTrue(api.trustedCaptureExactlyOneShot)
        XCTAssertTrue(api.closedFirstPartyAdaptersOnly)
        XCTAssertFalse(api.existingFixturePublicAPISpellingsMayChange)
        XCTAssertEqual(api.standardInputPolicy, "dev_null")
        XCTAssertFalse(api.customInheritedDescriptorsAuthorized)
        XCTAssertTrue(api.orderedUniqueEnvironmentRequired)
        XCTAssertTrue(api.exactExecutableDescriptorRequired)
        XCTAssertTrue(api.exactWorkingDirectoryDescriptorRequired)
        XCTAssertTrue(api.suspendedProofBeforeResumeRequired)
        XCTAssertTrue(api.absoluteMonotonicUptimeDeadlineRequired)
        XCTAssertFalse(api.continuousThroughSystemSleepClockEstablished)
        XCTAssertFalse(api.hostileCodeSandboxEstablished)

        let evidence = authority.evidenceContract
        XCTAssertTrue(evidence.typedUnavailableDistinctFromObservedFalse)
        XCTAssertTrue(evidence.exactPIDReapRequired)
        XCTAssertTrue(evidence.processGroupEmptyRequired)
        XCTAssertTrue(evidence.termThenKillTimelineRequired)
        XCTAssertTrue(evidence.signalSuppressionRecorded)
        XCTAssertFalse(evidence.capturedPrefixSHA256MayClaimFullStreamSHA256)
        XCTAssertTrue(
            evidence.failStopWithoutProjectionWhenContainmentUnproved)
        XCTAssertFalse(evidence.processGroupContainsHostileDaemonization)
        XCTAssertFalse(evidence.cleanupAfterKernelOrHostLossGuaranteed)

        let drains = authority.drainTerminalAdjustment
        XCTAssertTrue(drains.workerFinishedPublishedOnlyAfterDescriptorsClose)
        XCTAssertTrue(
            drains.terminalStatesDistinguishEOFReadWriteAndCleanupErrors)
        XCTAssertFalse(drains.activeOrUnsettledDrainProjectsEvidence)
        XCTAssertTrue(drains.terminalErrorMayProjectAfterProvedContainment)
        XCTAssertFalse(drains.terminalErrorMayClaimReachedEOF)
        XCTAssertTrue(drains.fixtureSuccessStillRequiresEOFAndZeroErrors)
        XCTAssertTrue(drains.overflowContinuesDrainingToTerminalState)
        XCTAssertFalse(drains.capturedPrefixDigestIsFullStreamDigest)
        XCTAssertFalse(drains.duplicateRawProcessSyscallsAuthorized)

        let diagnostic = authority.diagnosticProjection
        XCTAssertEqual(diagnostic.maximumCanonicalByteCount, 4_096)
        XCTAssertEqual(diagnostic.maximumLineCount, 1)
        XCTAssertTrue(diagnostic.constructionAuthorized)
        XCTAssertFalse(diagnostic.neutralLayerEmissionAuthorized)
        XCTAssertFalse(diagnostic.hostedEmissionAuthorized)
        XCTAssertFalse(diagnostic.localPersistenceAuthorized)
        XCTAssertFalse(diagnostic.fsyncAuthorized)
        XCTAssertFalse(diagnostic.artifactUploadAuthorized)
        XCTAssertFalse(diagnostic.retentionAuthorized)
        XCTAssertFalse(diagnostic.rawPIDIncluded)
        XCTAssertFalse(diagnostic.rawAbsolutePathIncluded)
        XCTAssertFalse(diagnostic.rawEnvironmentIncluded)
        XCTAssertFalse(diagnostic.rawStandardErrorIncluded)
        XCTAssertFalse(diagnostic.privateScientificFrameIncluded)
        XCTAssertEqual(diagnostic.scientificOutcomeValue, "not_established")

        let lease = authority.leaseComposition
        XCTAssertTrue(lease.optionalOpaqueRetentionSeamAuthorized)
        XCTAssertTrue(lease.deterministicFakeLeaseTestAuthorized)
        XCTAssertTrue(lease.externallyOwnedLeaseMayBeRetainedWhileOwnerLives)
        XCTAssertFalse(lease.seamItselfAcquiresLease)
        XCTAssertFalse(lease.concretePrimeMetalDeviceLeaseAdapterAuthorized)
        XCTAssertFalse(lease.leaseFileMutationAuthorized)
        XCTAssertFalse(lease.leaseReleaseOrReacquisitionAuthorized)
        XCTAssertFalse(lease.descriptorTransferToWorkerAuthorized)
        XCTAssertFalse(lease.workerOwnedAcquisitionAuthorized)
        XCTAssertFalse(lease.ownerDeathContinuityEstablished)
        XCTAssertFalse(lease.physicalMetalReservationEstablished)
        XCTAssertFalse(lease.mlxDeviceIdentityOrIdlenessEstablished)
        XCTAssertFalse(lease.crossHostOrCrossJobContinuityEstablished)
        XCTAssertFalse(lease.leaseTelemetryIsDurableEvidence)

        let matrix = authority.deterministicTestMatrix
        XCTAssertEqual(matrix.exactTestCount, 12)
        XCTAssertEqual(matrix.exactOrderedTests.count, 12)
        XCTAssertEqual(
            matrix.exactOrderedTests.map(\.ordinal),
            Array(1 ... 12))
        XCTAssertEqual(
            Set(matrix.exactOrderedTests.map(\.method)).count,
            12)
        XCTAssertTrue(matrix.allFaultsAreInjectedValues)
        XCTAssertTrue(
            matrix.exactOrderedTests.allSatisfy {
                !$0.invokesLiveProcess && !$0.invokesLiveLease
            })
        XCTAssertFalse(matrix.liveFixtureExecutionAuthorized)
        XCTAssertFalse(matrix.wallClockRaceRequired)
        XCTAssertFalse(matrix.networkRequired)

        let topology = authority.sourceTopology
        XCTAssertEqual(topology.exactNewCoreFiles.count, 4)
        XCTAssertTrue(topology.executionKernelMustReuseExistingPrimeSubstrate)
        XCTAssertFalse(
            topology.duplicateSpawnWaitSignalImplementationAuthorized)
        XCTAssertFalse(topology.rawProcessSyscallsAuthorizedInNewCoreFiles)
        XCTAssertFalse(topology.rawProcessSyscallsMayIncreaseInModifiedSubstrate)
        XCTAssertFalse(topology.foundationProcessAuthorized)
        XCTAssertFalse(topology.shellExecutionAuthorized)
        XCTAssertFalse(topology.pathSearchAuthorized)
        XCTAssertFalse(topology.inheritedAmbientEnvironmentAuthorized)
        XCTAssertFalse(topology.networkOrUploadAuthorized)
        XCTAssertFalse(topology.freeFormHostedPrintingAuthorized)
        XCTAssertFalse(topology.mlxMetalOrNative300ImportsAuthorized)
        XCTAssertFalse(topology.arbitraryExecutableFixtureAdapterAuthorized)

        let language = authority.languageBoundary
        XCTAssertEqual(
            language.currentImplementationLanguage,
            "swift_existing_prime_darwin_substrate")
        XCTAssertFalse(language.pythonPermitted)
        XCTAssertEqual(language.pythonInvocationCount, 0)
        XCTAssertEqual(language.pythonSourcePathCount, 0)
        XCTAssertEqual(language.cppNewImplementationInvocationCount, 0)
        XCTAssertEqual(language.cppNewSourcePathCount, 0)
        XCTAssertTrue(
            language.retainedBaselineCppDependencyCompilationObserved)
        XCTAssertTrue(
            language.cppFullNativeAlternativeSeparatelyPermissibleLater)
        XCTAssertTrue(
            language.cppSwiftCABIAlternativeSeparatelyPermissibleLater)
        XCTAssertFalse(language.cppAlternativeAuthorizedNow)
        XCTAssertTrue(language.cppAlternativeRequiresSeparateAuthority)

        let canary = authority.successorCanary
        XCTAssertTrue(canary.authorityRequiredAfterImplementationGreen)
        XCTAssertEqual(canary.orderedFixtureModes.count, 9)
        XCTAssertEqual(canary.expectedAdapterInvocationCount, 1)
        XCTAssertEqual(canary.expectedActualChildCaptureCount, 10)
        XCTAssertTrue(canary.oneShotRaceIncluded)
        XCTAssertTrue(canary.executableReplacementIncluded)
        XCTAssertFalse(canary.leaseAcquisitionIncluded)
        XCTAssertFalse(canary.mlxMetalOrNative300Included)
        XCTAssertFalse(canary.hostedDiagnosticEmissionIncluded)
        XCTAssertFalse(canary.authorizedNow)
        XCTAssertEqual(canary.disposition, "observe_once_then_retire")

        let ceiling = authority.authorityCeiling
        XCTAssertTrue(ceiling.designAuthorityEstablished)
        XCTAssertTrue(ceiling.implementationAuthorityEstablished)
        XCTAssertTrue(ceiling.deterministicExact13SourcePatchAuthorized)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(authority.orderedSuccessorBoundaries.count, 8)

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeSecureChildProcessEvidenceImplementationAuthority.swift")
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        let importLines = sourceText.split(separator: "\n").filter {
            $0.hasPrefix("import ")
        }.map(String.init)
        XCTAssertEqual(importLines, ["import Foundation"])
        for forbidden in [
            "import Darwin", "import Dispatch", "import Metal", "import MLX",
            "FileManager.", "FileHandle.", "URLSession", "Process" + "(",
            "posix_" + "spawn(", "wait" + "pid(", "kill" + "(",
            "flock" + "(", "exec" + "ve(", "python" + "3 ",
            "/usr/bin/" + "python",
        ] {
            XCTAssertFalse(sourceText.contains(forbidden), forbidden)
        }
        let testText = try String(contentsOfFile: #filePath, encoding: .utf8)
        XCTAssertEqual(
            testText.components(separatedBy: "func " + "test").count - 1,
            1)

        requireSendable(Authority.self)
        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(authority))
        XCTAssertEqual(canonical.count, Authority.canonicalByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Authority.canonicalSHA256)
        XCTAssertEqual(try Authority.decodeCanonical(canonical), authority)
        XCTAssertNoThrow(try authority.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 200)
        XCTAssertGreaterThan(dictionaryPaths.count, 15)

        for path in valuePaths {
            try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue))
            try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: { _ in NSNull() }))
            try assertCanonicalRejects(removingValue(in: object, at: path))
        }

        var reorderedArrayCount = 0
        for path in allArrayPaths(in: object) {
            var changed = false
            let reordered = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var array = value as! [Any]
                    guard array.count >= 2 else { return array }
                    for left in array.indices {
                        for right in array.indices where right > left {
                            if canonicalFragment(array[left])
                                != canonicalFragment(array[right]) {
                                array.swapAt(left, right)
                                changed = true
                                return array
                            }
                        }
                    }
                    return array
                })
            if changed {
                try assertCanonicalRejects(reordered)
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 8)

        for (index, path) in dictionaryPaths.enumerated() {
            try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { value in
                        var dictionary = value as! [String: Any]
                        dictionary["unknown_implementation_field_\(index)"] = true
                        return dictionary
                    }))
        }

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(canonical + Data([0x0a])))

        var slashEscaped = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(slashEscaped.utf8)))

        let schemaField = "\"schemaVersion\":1,"
        var reordered = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let reorderedOpening = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(
            contentsOf: schemaField,
            at: reordered.index(after: reorderedOpening))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(reordered.utf8)))

        var duplicate = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(duplicate.utf8)))
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)
    }

    private typealias JSONPath = [JSONPathComponent]

    private func authorityFalseClaims(
        _ value: PrimeSecureChildProcessEvidenceImplementationAuthorityV1
            .AuthorityCeiling
    ) -> [Bool] {
        [
            value.processExecutionAuthorized,
            value.liveFixtureExecutionAuthorized,
            value.hostedDiagnosticProjectionAuthorized,
            value.hostedDiagnosticEmissionAuthorized,
            value.customDescriptorTransportAuthorized,
            value.durableEvidenceEstablished,
            value.durableTransactionImplementationAuthorized,
            value.leaseAcquisitionAuthorized,
            value.leaseReleaseObservationAuthorized,
            value.leaseContinuityEstablished,
            value.watchdogRepairAuthorized,
            value.oldLauncherMutationAuthorized,
            value.retryAuthorized,
            value.rerunAuthorized,
            value.replacementExecutionAuthorized,
            value.mlxAuthorized,
            value.metalAuthorized,
            value.native300MExecutionAuthorized,
            value.scientificOutcomeEstablished,
            value.checkpointAdmissionGranted,
            value.stage8Authorized,
            value.stage8AuthorityEstablished,
            value.generalTrainingResumeAuthorized,
            value.modelQualityEstablished,
            value.candidateAdmissionAuthorized,
            value.downstreamTrialAuthorized,
            value.canaryAuthorized,
            value.quantizationAuthorized,
            value.productUseAuthorized,
            value.publicationAuthorized,
        ]
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}

    private func allValuePaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix + [.key(key)]
                return [path] + allValuePaths(
                    in: object[key]!,
                    prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path] + allValuePaths(
                    in: array[index],
                    prefix: path)
            }
        }
        return []
    }

    private func allDictionaryPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return [prefix] + object.keys.sorted().flatMap { key in
                allDictionaryPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func allArrayPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allArrayPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func replacingValue(
        in value: Any,
        at path: JSONPath,
        with transform: (Any) -> Any
    ) -> Any {
        guard let component = path.first else {
            return transform(value)
        }
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            object[key] = replacingValue(
                in: object[key]!,
                at: remainder,
                with: transform)
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index],
                at: remainder,
                with: transform)
            return array
        }
    }

    private func removingValue(
        in value: Any,
        at path: JSONPath
    ) -> Any {
        precondition(!path.isEmpty)
        let component = path[0]
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            if remainder.isEmpty {
                object.removeValue(forKey: key)
            } else {
                object[key] = removingValue(
                    in: object[key]!,
                    at: remainder)
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(
                    in: array[index],
                    at: remainder)
            }
            return array
        }
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if let string = value as? String {
            return string + "__mutation"
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return NSNumber(value: number.int64Value + 1)
        }
        if var array = value as? [Any] {
            array.append("__mutation")
            return array
        }
        if var object = value as? [String: Any] {
            object["__mutation"] = true
            return object
        }
        return "__mutation"
    }

    private func canonicalFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes])) ?? Data()
    }

    private func assertCanonicalRejects(
        _ object: Any,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(
            try PrimeSecureChildProcessEvidenceImplementationAuthorityV1
                .decodeCanonical(data),
            file: file,
            line: line)
    }
}
