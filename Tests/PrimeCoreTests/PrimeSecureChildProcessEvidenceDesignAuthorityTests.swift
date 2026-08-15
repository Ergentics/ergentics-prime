// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import XCTest
@testable import PrimeCore

final class PrimeSecureChildProcessEvidenceDesignAuthorityTests:
    XCTestCase
{
    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        typealias Authority =
            PrimeSecureChildProcessEvidenceDesignAuthorityV1
        let authority = Authority.frozenV1

        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.authorityID,
            "prime_secure_child_process_evidence_design_authority_v1")
        XCTAssertFalse(
            authority.predecessorFailure.privateCauseRecoverable)
        XCTAssertEqual(
            authority.predecessorFailure.stage7LeaseEvidence,
            "unknown")
        XCTAssertTrue(authority.predecessorFailure.orphanSleepObserved)
        XCTAssertFalse(
            authority.predecessorFailure
                .watchdogChildAttributionDirectlyObserved)
        XCTAssertTrue(
            authority.predecessorFailure
                .watchdogChildAttributionInferenceOnly)
        XCTAssertTrue(authority.predecessorFailure.oneShotConsumed)
        XCTAssertTrue(authority.predecessorFailure.oneShotExhausted)
        XCTAssertTrue(
            authority.predecessorFailure
                .failureObservationAuthorizesNothing)
        XCTAssertFalse(
            authority.predecessorFailure
                .retirementObservedAtObservationAuthoring)

        let closure = authority.retirementClosure
        XCTAssertEqual(
            closure.mergeRevision,
            "7077b6d2195e847bdff583e945e58d6c3b042d63")
        XCTAssertEqual(
            closure.mergeTree,
            "d549a876312f9d65a86b030d35fb601a981dbdc6")
        XCTAssertEqual(
            closure.orderedParents,
            [
                "88e001083c19f995f5ef5bd7c36f48356a90b997",
                "44ab4deb32e8f4c0840b39228fbb2ed71fa1b5ef",
            ])
        XCTAssertTrue(closure.signedMergeVerified)
        XCTAssertEqual(closure.workflowRunID, 31_888_756_258)
        XCTAssertEqual(closure.workflowRunNumber, 131)
        XCTAssertEqual(closure.successfulAttempt, 2)
        XCTAssertEqual(closure.checkSuiteID, 86_497_384_253)
        XCTAssertTrue(closure.previousAttemptExternallyCancelled)
        XCTAssertEqual(closure.activeJobID, 95_057_232_902)
        XCTAssertEqual(closure.reviewedJobID, 95_057_662_875)
        XCTAssertEqual(closure.activeLatinTestCount, 116)
        XCTAssertEqual(closure.rootTestCount, 63)
        XCTAssertEqual(closure.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(closure.focusedWholeTestCount, 69)
        XCTAssertEqual(closure.retainedLiveTestCount, 46)
        XCTAssertEqual(closure.aggregateTestCount, 115)
        XCTAssertEqual(closure.stage7JobCount, 0)
        XCTAssertEqual(closure.actionsArtifactCount, 0)
        XCTAssertTrue(closure.laterRetirementClosureObserved)

        let substrate = authority.existingSubstrate
        XCTAssertEqual(substrate.orderedSourceIdentities.count, 7)
        XCTAssertTrue(substrate.suspendedSpawnTransportAlreadyExists)
        XCTAssertTrue(
            substrate.executableAndWorkingDirectoryProofAlreadyExists)
        XCTAssertTrue(substrate.absoluteDeadlineAlreadyExists)
        XCTAssertTrue(substrate.boundedConcurrentDrainAlreadyExists)
        XCTAssertTrue(
            substrate.exactPIDReapAndGroupContainmentAlreadyExists)
        XCTAssertTrue(substrate.singleOwnerSupervisionAlreadyExists)
        XCTAssertTrue(
            substrate.closedNineModeFixtureCapabilityAlreadyExists)
        XCTAssertFalse(
            substrate.duplicateSpawnWaitSignalImplementationPermitted)
        XCTAssertEqual(substrate.initialImplementationTarget, "PrimeCore")
        XCTAssertFalse(substrate.newSwiftPMTargetRequired)

        let process = authority.processPlanDesign
        XCTAssertTrue(process.closedDomainAdaptersOnly)
        XCTAssertFalse(process.arbitraryPublicExecutableCapabilityPermitted)
        XCTAssertFalse(process.liveCaptureCodable)
        XCTAssertFalse(process.transportProjectionCreatesLiveAuthority)
        XCTAssertTrue(process.oneShotCapabilityRequired)
        XCTAssertTrue(process.suspendedAdmissionAndProofBeforeResumeRequired)
        XCTAssertTrue(process.absoluteMonotonicDeadlineRequired)
        XCTAssertFalse(process.deadlineRefreshAfterFirstBytePermitted)
        XCTAssertTrue(
            process.stdoutAndStderrDrainedConcurrentlyToTerminalState)
        XCTAssertTrue(process.termThenKillRequired)
        XCTAssertTrue(process.exactPIDReapRequired)
        XCTAssertTrue(process.processGroupEmptyRequired)
        XCTAssertEqual(
            process.unprovedContainmentDisposition,
            "fail_stop_no_projection")
        XCTAssertFalse(process.hostileChildSandboxEstablished)
        XCTAssertFalse(process.cleanupAfterMonitorSIGKILLGuaranteed)
        XCTAssertFalse(process.cleanupAfterKernelOrHostLossGuaranteed)

        let evidence = authority.evidenceDesign
        XCTAssertTrue(evidence.typedUnavailableDistinctFromFalse)
        XCTAssertFalse(evidence.capturedPrefixSHA256IsFullStreamSHA256)
        XCTAssertFalse(
            evidence.fullStreamSHA256MayBeClaimedWithoutFullHashing)
        XCTAssertFalse(evidence.rawPIDPermittedInHostedProjection)
        XCTAssertFalse(evidence.rawAbsolutePathPermittedInHostedProjection)
        XCTAssertFalse(evidence.rawEnvironmentPermittedInHostedProjection)
        XCTAssertFalse(evidence.rawStandardErrorPermittedInHostedProjection)
        XCTAssertFalse(
            evidence.privateScientificFramePermittedInHostedProjection)
        XCTAssertEqual(
            evidence.scientificOutcomeValueOnOperationalFailure,
            "not_established")
        XCTAssertFalse(evidence.diagnosticProjectionCreatesScientificReceipt)

        let diagnostic = authority.diagnosticDesign
        XCTAssertEqual(diagnostic.maximumCanonicalByteCount, 4_096)
        XCTAssertEqual(diagnostic.maximumHostedLineCount, 1)
        XCTAssertFalse(diagnostic.neutralLayerEmitsHostedLine)
        XCTAssertTrue(diagnostic.closedHostedAdapterRequired)
        XCTAssertFalse(diagnostic.localPersistenceAuthorized)
        XCTAssertFalse(diagnostic.fsyncPersistenceAuthorized)
        XCTAssertFalse(diagnostic.actionsArtifactUploadAuthorized)
        XCTAssertFalse(diagnostic.retentionAuthorized)
        XCTAssertFalse(
            diagnostic.successfulStreamEOFRequiredForProjection)
        XCTAssertFalse(
            diagnostic.projectionOnUnprovedContainmentPermitted)

        let lease = authority.leaseCompositionDesign
        XCTAssertEqual(
            lease.mechanism,
            "darwin_parent_and_leaf_flock")
        XCTAssertTrue(lease.parentAndLeafLocksRequired)
        XCTAssertTrue(lease.nonblockingAcquisitionRequired)
        XCTAssertTrue(lease.descriptorAndNameRevalidationRequired)
        XCTAssertFalse(lease.staleFileContentsAuthoritative)
        XCTAssertTrue(lease.advisoryCooperatingProcessScopeOnly)
        XCTAssertFalse(lease.physicalMetalReservationEstablished)
        XCTAssertFalse(lease.mlxDeviceIdentityEstablished)
        XCTAssertFalse(lease.crossHostOrCrossJobContinuityEstablished)
        XCTAssertFalse(lease.currentIsHeldPropertyIsKernelProof)
        XCTAssertEqual(lease.stage7LeaseAcquisitionEvidence, "unknown")
        XCTAssertFalse(
            lease.monitorHeldLeaseProvesWorkerLifetimeAfterMonitorLoss)
        XCTAssertTrue(lease.firstClassLeaseCompositionSeamRequired)
        XCTAssertFalse(lease.childLifetimeDescriptorTransferAuthorizedNow)
        XCTAssertFalse(lease.workerOwnedAcquisitionAuthorizedNow)
        XCTAssertFalse(lease.neutralLeaseGeneralizationAuthorizedNow)

        let scaffold = authority.scaffoldingDesign
        XCTAssertEqual(scaffold.exactOrderedChangedPaths.count, 5)
        XCTAssertEqual(scaffold.activeLatinTestCount, 116)
        XCTAssertEqual(scaffold.rootTestCount, 64)
        XCTAssertEqual(scaffold.isolatedTestCount, 6)
        XCTAssertEqual(scaffold.focusedWholeTestCount, 70)
        XCTAssertEqual(scaffold.retainedLiveTestCount, 46)
        XCTAssertEqual(scaffold.aggregateTestCount, 116)
        XCTAssertEqual(scaffold.embeddedProvenanceRecordCount, 498)
        XCTAssertEqual(
            scaffold.laterFixtureIntegrationSource.role,
            "future_closed_nine_mode_compatibility_canary_only")
        XCTAssertEqual(scaffold.laterFixtureModes.count, 9)
        XCTAssertFalse(scaffold.laterFixtureCanaryAuthorizedNow)
        XCTAssertFalse(scaffold.scaffoldItselfImplementsProcessContainment)
        XCTAssertTrue(
            scaffold.scaffoldCanValidateClosedProcessContainmentLater)
        XCTAssertFalse(scaffold.scaffoldCanRecoverHistoricalRun129)
        XCTAssertFalse(
            scaffold.scaffoldItselfImplementsKernelLeaseExclusion)
        XCTAssertFalse(scaffold.scaffoldItselfProvidesDurableEvidence)

        let language = authority.languageBoundary
        XCTAssertFalse(language.pythonPermitted)
        XCTAssertEqual(language.pythonInvocationCount, 0)
        XCTAssertEqual(language.cppInvocationCount, 0)
        XCTAssertTrue(
            language.cppFullNativeImplementationMayBeSeparatelyReviewedLater)
        XCTAssertTrue(
            language.cppSwiftCABIAdapterMayBeSeparatelyReviewedLater)
        XCTAssertFalse(language.cppImplementationAuthorizedNow)
        XCTAssertTrue(language.cppRequiresSeparateTargetOrCABISeamReview)

        let ceiling = authority.authorityCeiling
        XCTAssertTrue(ceiling.designAuthorityEstablished)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(authority.orderedSeparateSuccessorBoundaries.count, 8)

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeSecureChildProcessEvidenceDesignAuthority.swift")
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        let importLines = sourceText.split(separator: "\n").filter {
            $0.hasPrefix("import ")
        }.map(String.init)
        XCTAssertEqual(importLines, ["import Foundation"])
        for forbidden in [
            "import Darwin", "import Dispatch", "import Metal", "import MLX",
            "FileManager.", "FileHandle.", "URLSession", "Process(",
            "posix_spawn(", "waitpid(", "kill(", "flock(", "execve(",
            "python3 ", "/usr/bin/python",
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
        if Authority.canonicalSHA256 == "CANONICAL_SHA256_PLACEHOLDER" {
            XCTFail(
                "canonical freeze byte_count=\(canonical.count) sha256="
                    + PrimeSHA256.hexDigest(of: canonical))
            return
        }
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
        XCTAssertGreaterThan(valuePaths.count, 150)
        XCTAssertGreaterThan(dictionaryPaths.count, 10)

        for path in valuePaths {
            try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: mutateJSONValue))
            try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }))
            try assertCanonicalRejects(
                removingValue(in: object, at: path))
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
        XCTAssertGreaterThan(reorderedArrayCount, 5)

        for (index, path) in dictionaryPaths.enumerated() {
            let withUnknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_secure_child_field_\(index)"] = true
                    return dictionary
                })
            try assertCanonicalRejects(withUnknown)
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
        _ value: PrimeSecureChildProcessEvidenceDesignAuthorityV1
            .AuthorityCeiling
    ) -> [Bool] {
        [
            value.implementationAuthorized,
            value.diagnosticEmissionAuthorized,
            value.hostedProjectionEmissionAuthorized,
            value.customDescriptorTransportAuthorized,
            value.processExecutionAuthorized,
            value.fixtureExecutionAuthorized,
            value.filesystemWriteAuthorized,
            value.durableEvidenceEstablished,
            value.durableTransactionImplementationAuthorized,
            value.leaseAcquisitionAuthorized,
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
            try PrimeSecureChildProcessEvidenceDesignAuthorityV1
                .decodeCanonical(data),
            file: file,
            line: line)
    }
}
