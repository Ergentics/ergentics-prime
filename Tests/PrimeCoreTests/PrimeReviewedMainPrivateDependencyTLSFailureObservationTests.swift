// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeReviewedMainPrivateDependencyTLSFailureObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeReviewedMainPrivateDependencyTLSFailureObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()
        throws
    {
        let observation = Observation.frozenV1

        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_reviewed_main_private_dependency_tls_failure_observation_v1"
        )
        XCTAssertEqual(
            observation.predecessorObservationID,
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationV1
                .frozenV1.observationID
        )
        XCTAssertEqual(
            observation.predecessorCanonicalSHA256,
            "3822447081af914836f0c158adfb6fd5cbad611a24082ebffd516bffc0f0f002"
        )

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.pullRequestNumber, 84)
        XCTAssertEqual(repository.ref, "refs/heads/main")
        XCTAssertEqual(
            repository.revision,
            "e540b73f6a46cf6e0de5b932d7167f178d4ac6fb"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                "8d544c34a09a770198b50126f50adb766f234a8f",
                "64eed284f0b5630a23feeea1e74dcd74fe275571",
            ]
        )
        XCTAssertEqual(
            repository.tree,
            "7f983f66b05c338464662f741d410ae70b1e662a"
        )
        XCTAssertEqual(repository.reviewedHeadTree, repository.tree)
        XCTAssertEqual(repository.mergedAt, "2026-08-11T19:59:59Z")
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.mergeCommitSignatureVerified)
        XCTAssertEqual(repository.mergeCommitSignatureReason, "valid")
        XCTAssertTrue(repository.exactMainRefStillMatchedAtAudit)
        XCTAssertEqual(
            repository.embeddedSourceIdentitySHA256,
            "4790206681d2c41ffadbed2b774377fcdd2ef2e89c671f14d39026cc0018c2c8"
        )

        XCTAssertEqual(observation.observedSourceBindings.count, 7)
        XCTAssertEqual(
            observation.observedSourceBindings.map(\.path),
            [
                ".github/workflows/prime-active-root-quarantine.yml",
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                "Package.swift",
                "Package.resolved",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservation.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationTests.swift",
            ]
        )
        XCTAssertTrue(
            observation.observedSourceBindings.allSatisfy { binding in
                ["100644", "100755"].contains(binding.gitMode)
                    && binding.gitBlob.utf8.count == 40
                    && isLowercaseHex(binding.gitBlob)
                    && binding.byteCount > 0
                    && binding.sha256.utf8.count == 64
                    && isLowercaseHex(binding.sha256)
                    && !binding.claimScope.isEmpty
            }
        )

        let run = observation.runIdentity
        XCTAssertEqual(run.workflowID, 329_017_041)
        XCTAssertEqual(run.runID, 31_530_684_844)
        XCTAssertEqual(run.runNumber, 65)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.headBranch, "main")
        XCTAssertEqual(run.headRevision, repository.revision)
        XCTAssertEqual(run.actor, "psyop-archivist")
        XCTAssertEqual(run.triggeringActor, run.actor)
        XCTAssertEqual(run.createdAt, "2026-08-11T20:00:02Z")
        XCTAssertEqual(run.terminalUpdatedAt, "2026-08-11T20:03:08Z")
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "failure")
        XCTAssertEqual(run.checkSuiteID, 85_531_798_174)
        XCTAssertEqual(run.exactHeadPushRunCount, 1)
        XCTAssertTrue(run.previousAttemptURLWasNull)
        XCTAssertEqual(run.secondAttemptEndpointHTTPStatus, 404)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertFalse(run.rerunObserved)
        XCTAssertFalse(run.rerunAuthorized)

        let active = observation.activeRootJob
        XCTAssertEqual(active.id, 93_909_705_892)
        XCTAssertEqual(active.conclusion, "success")
        XCTAssertEqual(active.runnerLabel, "macos-15")
        XCTAssertEqual(active.runnerName, "GitHub Actions 1000001688")
        XCTAssertEqual(active.orderedSteps.map(\.number), Array(1 ... 7))
        XCTAssertTrue(
            active.orderedSteps.allSatisfy { $0.conclusion == "success" }
        )
        XCTAssertEqual(active.checkAnnotationCount, 0)

        let reviewed = observation.reviewedMainJob
        XCTAssertEqual(reviewed.id, 93_910_498_134)
        XCTAssertEqual(reviewed.conclusion, "failure")
        XCTAssertEqual(reviewed.runnerLabel, "macos-26")
        XCTAssertEqual(reviewed.runnerName, "GitHub Actions 1000001689")
        XCTAssertEqual(
            reviewed.orderedSteps.map(\.conclusion),
            [
                "success",
                "success",
                "success",
                "failure",
                "skipped",
                "skipped",
                "success",
            ]
        )
        XCTAssertEqual(reviewed.orderedSteps[3].name,
            "Fetch the exact private dependency without evaluating Prime")
        XCTAssertEqual(reviewed.checkAnnotationCount, 1)
        XCTAssertEqual(reviewed.checkAnnotationPath, ".github")
        XCTAssertEqual(reviewed.checkAnnotationStartLine, 46)
        XCTAssertEqual(reviewed.checkAnnotationEndLine, 46)
        XCTAssertEqual(
            reviewed.checkAnnotationMessage,
            "Process completed with exit code 128."
        )

        let toolchain = observation.runnerToolchain
        XCTAssertEqual(toolchain.runnerVersion, "2.336.0")
        XCTAssertEqual(toolchain.runnerProvisionerVersion, "20260707.563")
        XCTAssertEqual(toolchain.activeRunnerImage, "macos-15-arm64")
        XCTAssertEqual(toolchain.activeRunnerImageVersion, "20260727.0256.1")
        XCTAssertEqual(toolchain.activeOperatingSystemBuild, "24G720")
        XCTAssertEqual(toolchain.reviewedRunnerImage, "macos-26-arm64")
        XCTAssertEqual(
            toolchain.reviewedRunnerImageVersion,
            "20260728.0273.1"
        )
        XCTAssertEqual(toolchain.reviewedOperatingSystemBuild, "25F84")
        XCTAssertEqual(toolchain.xcodeVersion, "26.6")
        XCTAssertEqual(toolchain.xcodeBuildVersion, "17F113")
        XCTAssertEqual(toolchain.swiftTarget, "arm64-apple-macosx26.0")
        XCTAssertEqual(toolchain.macOSSDKVersion, "26.5")
        XCTAssertTrue(toolchain.exactHostedRunnerImagesRecorded)
        XCTAssertFalse(toolchain.exactPhysicalRunnerIdentityRecorded)

        assertRawLog(
            observation.activeRootRawLog,
            byteCount: 231_409,
            lfByteCount: 1_737,
            sha256:
                "9df1918e7a6bdd24ba52386a1878114029642d57ce1f739c7523e2071e9772a7"
        )
        assertRawLog(
            observation.reviewedMainRawLog,
            byteCount: 10_195,
            lfByteCount: 134,
            sha256:
                "763401f815fa31f7e3a8fb76468ac30b983580a84e3603b6219deaa8e3a79a2e"
        )
        assertRawLog(
            observation.failureStepRawLog,
            byteCount: 4_024,
            lfByteCount: 46,
            sha256:
                "c347aee0e6e114955166c8418967817631ef9fa5befec474fd96379a051a4da9"
        )

        let archive = observation.rawLogArchive
        XCTAssertEqual(archive.byteCount, 66_580)
        XCTAssertEqual(
            archive.sha256,
            "642d3b1d139c840c3f02a93fd96d03b3504e9ccf5340b1a05900dedda441e2fc"
        )
        XCTAssertEqual(archive.memberCount, 16)
        XCTAssertEqual(archive.members.count, archive.memberCount)
        XCTAssertEqual(
            archive.members.reduce(0) { $0 + $1.byteCount },
            archive.uncompressedByteCount
        )
        XCTAssertEqual(archive.uncompressedByteCount, 484_639)
        XCTAssertEqual(
            Set(archive.members.map(\.path)).count,
            archive.members.count
        )
        XCTAssertTrue(archive.repeatedDownloadsWereByteIdentical)
        XCTAssertTrue(archive.memberTimestampsAreDOSZero)
        XCTAssertTrue(archive.skippedReviewedStepMembersAbsent)
        XCTAssertEqual(
            archive.failureStepMemberDiagnosticTimestamp,
            "2026-08-11T20:03:04.6476270Z"
        )
        XCTAssertEqual(
            archive.reviewedAggregateDiagnosticTimestamp,
            "2026-08-11T20:03:04.6476320Z"
        )
        XCTAssertNotEqual(
            archive.failureStepMemberDiagnosticTimestamp,
            archive.reviewedAggregateDiagnosticTimestamp
        )
        XCTAssertEqual(
            archive.failureStepMemberExitTimestamp,
            "2026-08-11T20:03:04.6496520Z"
        )
        XCTAssertEqual(
            archive.reviewedAggregateExitTimestamp,
            "2026-08-11T20:03:04.6496540Z"
        )

        let execution = observation.executionBoundary
        XCTAssertTrue(execution.activeRootGatePassed)
        XCTAssertTrue(execution.dependencyFreeSwiftParsePassed)
        XCTAssertEqual(execution.latinTestInvocationCount, 1)
        XCTAssertEqual(execution.latinCompletedTestCount, 116)
        XCTAssertEqual(execution.latinFailureCount, 0)
        XCTAssertEqual(execution.latinSkipCount, 0)
        XCTAssertEqual(execution.latinFinalSummaryOccurrenceCount, 2)
        XCTAssertEqual(execution.focusedContractsStepNumber, 5)
        XCTAssertEqual(execution.focusedContractsStepConclusion, "skipped")
        XCTAssertEqual(execution.requiredFocusedRootTestCount, 35)
        XCTAssertEqual(
            [
                execution.focusedRootInvocationCount,
                execution.focusedRootCompletedTestCount,
                execution.focusedRootFailureCount,
                execution.focusedRootSkipCount,
                execution.focusedRootSuccessSummaryCount,
            ],
            Array(repeating: 0, count: 5)
        )
        XCTAssertEqual(execution.retainedLiveStepNumber, 6)
        XCTAssertEqual(execution.retainedLiveStepConclusion, "skipped")
        XCTAssertEqual(execution.retainedLiveSequenceWorkflowCounts, [1, 1, 1])
        XCTAssertEqual(execution.retainedLiveSequenceInvocationCounts, [0, 0, 0])
        XCTAssertEqual(execution.requiredMetalTestCount, 44)
        XCTAssertEqual(
            [
                execution.completedMetalTestCount,
                execution.metalFailureCount,
                execution.metalSkipCount,
                execution.runtimeReceiptCount,
                execution.tokenizerReceiptCount,
                execution.stage2ValidationPackageCommandCount,
                execution.stage2ValidationFilterCount,
                execution.stage2ValidationLogPathCount,
                execution.stage2ValidationScratchPathCount,
                execution.stage2InvocationCount,
                execution.stage2TestStartCount,
                execution.stage2CompletedPassCount,
                execution.stage2CompletedFailureCount,
                execution.stage2CompletedSkipCount,
                execution.retiredSeed42CheckpointCommandCount,
                execution.retiredSeed43CheckpointCommandCount,
                execution.checkpointReceiptMarkerCount,
                execution.artifactUploadStepCount,
            ],
            Array(repeating: 0, count: 18)
        )

        let failure = observation.failureBoundary
        XCTAssertEqual(failure.failedJobStepNumber, 4)
        XCTAssertEqual(
            failure.privateDependencyRepository,
            "https://github.com/Ergentics/ergentics-mlx-swift"
        )
        XCTAssertEqual(
            failure.privateDependencyRevision,
            "d37885a278f1c37484a94d0f401a418735e66519"
        )
        XCTAssertEqual(
            failure.exactFetchCommand,
            "git --git-dir=\"$mlx_bare\" fetch --depth=1 --no-tags origin \"$PRIME_MLX_REVISION\""
        )
        XCTAssertTrue(failure.credentialNonemptyPreconditionReturned)
        XCTAssertTrue(failure.credentialWasMaskedInLog)
        XCTAssertFalse(failure.credentialValueDisclosed)
        XCTAssertTrue(failure.bareRepositoryInitializationCompleted)
        XCTAssertTrue(failure.privateDependencyRemoteAdded)
        XCTAssertTrue(failure.credentialURLRewriteConfigured)
        XCTAssertEqual(failure.transportFetchInvocationCount, 1)
        XCTAssertFalse(failure.dependencyFetchCompleted)
        XCTAssertEqual(
            [
                failure.fetchHeadValidationCount,
                failure.pinnedReferenceUpdateCount,
                failure.dependencyWorktreeAddCount,
                failure.dependencySubmoduleUpdateCount,
                failure.dependencyPackageEvaluationCount,
                failure.credentialLeakScanCount,
            ],
            Array(repeating: 0, count: 6)
        )
        XCTAssertEqual(
            failure.exactDiagnostic,
            "fatal: unable to access 'https://github.com/Ergentics/ergentics-mlx-swift/': SSL certificate problem: self signed certificate"
        )
        XCTAssertEqual(failure.diagnosticOccurrenceCount, 2)
        XCTAssertEqual(failure.processExitCode, 128)
        XCTAssertEqual(
            failure.exactExitMessage,
            "Process completed with exit code 128."
        )
        XCTAssertTrue(failure.exactMergeCheckoutCompleted)
        XCTAssertTrue(failure.exactMergeCheckoutRemainedClean)
        XCTAssertEqual(
            failure.failureClassification,
            "git_https_tls_self_signed_certificate_before_private_dependency_fetch_completion"
        )

        let semantics = observation.failureSemantics
        XCTAssertTrue(semantics.externalTLSFailureObserved)
        XCTAssertTrue(semantics.selfSignedCertificateDiagnosticObserved)
        XCTAssertTrue(semantics.gitTransportFailureObserved)
        XCTAssertTrue(semantics.certificateVerificationFailureObserved)
        XCTAssertTrue(semantics.failurePrecedesDependencyEvaluation)
        XCTAssertTrue(semantics.failurePrecedesReviewedMainSwiftCompilation)
        XCTAssertTrue(semantics.failurePrecedesFocusedRootExecution)
        XCTAssertTrue(semantics.failurePrecedesRetainedLiveSequence)
        XCTAssertTrue(semantics.predecessorStage2ObservationRemainsFrozen)
        XCTAssertTrue(semantics.predecessorStage2AttemptRemainsExhausted)
        XCTAssertTrue(semantics.runnerTLSRepairRequiredBeforeDistinctRun)
        XCTAssertTrue(semantics.stage3RemainsBlocked)
        XCTAssertTrue(
            semantics.failureClassificationLimitedToObservedExternalTLSBoundary
        )
        XCTAssertTrue(semanticFalseClaims(semantics).allSatisfy { !$0 })

        let artifacts = observation.artifactBoundary
        XCTAssertEqual(artifacts.actionsArtifactsTotalCount, 0)
        XCTAssertTrue(artifacts.actionsArtifactsArrayExactlyEmpty)
        XCTAssertEqual(artifacts.publishedWorkflowArtifactCount, 0)
        XCTAssertEqual(artifacts.artifactUploadStepCount, 0)
        XCTAssertTrue(artifacts.runLogArchiveObserved)
        XCTAssertFalse(artifacts.runLogArchiveIsActionsArtifact)
        XCTAssertFalse(artifacts.jobLogsRetainedInRepository)
        XCTAssertFalse(artifacts.durableJobLogPublicationEstablished)
        XCTAssertTrue(artifactFalseClaims(artifacts).allSatisfy { !$0 })

        XCTAssertTrue(
            authorityClaims(observation.authorityCeiling).allSatisfy { !$0 }
        )
        XCTAssertTrue(observation.status.hasPrefix("ABSTAIN_exact_main"))
        XCTAssertEqual(observation.orderedRequiredSeparateActions.count, 5)
        XCTAssertTrue(
            observation.orderedRequiredSeparateActions.contains(
                "require_root36_then_metal44_then_runtime1_then_tokenizer1_before_any_success_observation"
            )
        )

        requireSendable(Observation.self)
        let canonical = try observation.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(observation))
        let canonicalHash = PrimeSHA256.hexDigest(of: canonical)
        XCTAssertEqual(
            canonicalHash,
            "44917549689204bb9aabbd24b642d491a26fa501c3828cbc82009aa5e157a35d"
        )
        let decoded = try Observation.decodeCanonical(canonical)
        XCTAssertEqual(decoded, observation)
        XCTAssertEqual(try decoded.canonicalData(), canonical)
        XCTAssertNoThrow(try decoded.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 275)
        XCTAssertGreaterThan(dictionaryPaths.count, 25)
        XCTAssertGreaterThan(scalarPaths.count, 200)

        var regularDecodedDriftCount = 0
        var mutationCount = 0
        var nullCount = 0
        var removalCount = 0
        for path in valuePaths {
            let mutated = replacingValue(
                in: object,
                at: path,
                with: mutateJSONValue
            )
            let mutationData = try assertCanonicalRejects(
                mutated,
                label: "mutated \(pathLabel(path))"
            )
            mutationCount += 1
            if let loose = try? JSONDecoder().decode(
                Observation.self,
                from: mutationData
            ), loose != observation {
                regularDecodedDriftCount += 1
                XCTAssertThrowsError(try loose.validateExactV1())
            }

            _ = try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }
                ),
                label: "null \(pathLabel(path))"
            )
            nullCount += 1

            _ = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))"
            )
            removalCount += 1
        }
        XCTAssertEqual(mutationCount, valuePaths.count)
        XCTAssertEqual(nullCount, valuePaths.count)
        XCTAssertEqual(removalCount, valuePaths.count)
        XCTAssertGreaterThan(regularDecodedDriftCount, 175)

        var unknownFieldCount = 0
        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary[
                        "unknown_reviewed_main_private_dependency_tls_failure_field_\(index)"
                    ] = true
                    return dictionary
                }
            )
            let unknownData = try assertCanonicalRejects(
                unknown,
                label: "unknown field at \(pathLabel(path))"
            )
            let loose = try JSONDecoder().decode(
                Observation.self,
                from: unknownData
            )
            XCTAssertEqual(loose, observation)
            unknownFieldCount += 1
        }
        XCTAssertEqual(unknownFieldCount, dictionaryPaths.count)

        try assertNoncanonicalEncodingsReject(canonical, object: object)
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)

        var label: String {
            switch self {
            case let .key(key):
                return key
            case let .index(index):
                return "[\(index)]"
            }
        }
    }

    private typealias JSONPath = [JSONPathComponent]

    private func pathLabel(_ path: JSONPath) -> String {
        path.isEmpty ? "<root>" : path.map(\.label).joined(separator: ".")
    }

    private func allValuePaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix + [.key(key)]
                return [path] + allValuePaths(in: object[key]!, prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path] + allValuePaths(in: array[index], prefix: path)
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
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)]
                )
            }
        }
        return []
    }

    private func allScalarPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allScalarPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allScalarPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)]
                )
            }
        }
        return [prefix]
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
                with: transform
            )
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index],
                at: remainder,
                with: transform
            )
            return array
        }
    }

    private func removingValue(in value: Any, at path: JSONPath) -> Any {
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
                    at: remainder
                )
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(
                    in: array[index],
                    at: remainder
                )
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
            array.append(array.first ?? "__mutation")
            return array
        }
        if var object = value as? [String: Any] {
            object["unknown_recursive_mutation"] = true
            return object
        }
        XCTFail("unsupported canonical JSON value: \(value)")
        return value
    }

    @discardableResult
    private func assertCanonicalRejects(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Data {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertThrowsError(
            try Observation.decodeCanonical(data),
            label,
            file: file,
            line: line
        )
        return data
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        var prefixed = Data([0x20])
        prefixed.append(canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(prefixed))

        var suffixed = canonical
        suffixed.append(0x0A)
        XCTAssertThrowsError(try Observation.decodeCanonical(suffixed))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        let slashEscapedData = try XCTUnwrap(
            slashEscaped.data(using: .utf8)
        )
        XCTAssertThrowsError(
            try Observation.decodeCanonical(slashEscapedData)
        )

        var reordered = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let openingBrace = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(
            contentsOf: schemaField,
            at: reordered.index(after: openingBrace)
        )
        let reorderedData = try XCTUnwrap(reordered.data(using: .utf8))
        XCTAssertNotEqual(reorderedData, canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening)
        )
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Observation.decodeCanonical(duplicateData))
    }

    private func assertRawLog(
        _ log: PrimeReviewedMainTLSFailureRawLogIdentityV1,
        byteCount: Int,
        lfByteCount: Int,
        sha256: String
    ) {
        XCTAssertEqual(log.byteCount, byteCount)
        XCTAssertEqual(log.lfByteCount, lfByteCount)
        XCTAssertEqual(log.splitLineCountExcludingTerminalEmpty, lfByteCount)
        XCTAssertEqual(
            log.newlineDelimitedComponentCountIncludingTerminalEmpty,
            lfByteCount + 1
        )
        XCTAssertEqual(log.sha256, sha256)
        XCTAssertEqual(log.utf8BOMHex, "efbbbf")
        XCTAssertTrue(log.startsWithUTF8BOM)
        XCTAssertTrue(log.usesLFOnly)
        XCTAssertTrue(log.endsWithLF)
    }

    private func semanticFalseClaims(
        _ semantics: PrimeReviewedMainTLSFailureSemanticsV1
    ) -> [Bool] {
        [
            semantics.repositorySourceDefectEstablished,
            semantics.workflowSourceDefectEstablished,
            semantics.dependencyRevisionDefectEstablished,
            semantics.dependencyRepositoryAbsenceEstablished,
            semantics.credentialAbsenceEstablished,
            semantics.credentialRejectionObserved,
            semantics.credentialValidityEstablished,
            semantics.stage2SemanticsEvaluated,
            semantics.stage2SemanticFailureObserved,
            semantics.stage2BootstrapFailureObserved,
            semantics.stage2RepairAttempted,
            semantics.stage2OutcomeEstablished,
            semantics.runnerTLSRepairEstablished,
        ]
    }

    private func artifactFalseClaims(
        _ artifacts: PrimeReviewedMainTLSFailureArtifactBoundaryV1
    ) -> [Bool] {
        [
            artifacts.runLogArchiveIsActionsArtifact,
            artifacts.jobLogsRetainedInRepository,
            artifacts.durableJobLogPublicationEstablished,
            artifacts.runtimeReceiptEmitted,
            artifacts.tokenizerReceiptEmitted,
            artifacts.checkpointReceiptEmitted,
            artifacts.checkpointArtifactCreated,
            artifacts.checkpointArtifactUploaded,
            artifacts.checkpointArtifactRetained,
            artifacts.checkpointArtifactProvenanceEstablished,
        ]
    }

    private func authorityClaims(
        _ ceiling: PrimeReviewedMainTLSFailureAuthorityCeilingV1
    ) -> [Bool] {
        [
            ceiling.rerunAuthorized,
            ceiling.replacementRunAuthorized,
            ceiling.runnerTLSRepairAuthorized,
            ceiling.TLSVerificationBypassAuthorized,
            ceiling.customCAInstallationAuthorized,
            ceiling.workflowMutationAuthorized,
            ceiling.repositorySourceCorrectionAuthorized,
            ceiling.credentialRotationAuthorized,
            ceiling.credentialMutationAuthorized,
            ceiling.dependencyRevisionChangeAuthorized,
            ceiling.focusedRootContractsEstablished,
            ceiling.metalValidationEstablished,
            ceiling.runtimeClosureEstablished,
            ceiling.tokenizerCompatibilityEstablished,
            ceiling.stage2ExecutionEstablished,
            ceiling.stage2BootstrapRepairEstablished,
            ceiling.stage2SuccessEstablished,
            ceiling.stage3AuthorityEstablished,
            ceiling.checkpointReadEstablished,
            ceiling.checkpointWriteEstablished,
            ceiling.checkpointRoundTripEstablished,
            ceiling.checkpointArtifactAvailabilityEstablished,
            ceiling.checkpointArtifactRetentionEstablished,
            ceiling.checkpointArtifactUploadAuthorized,
            ceiling.checkpointArtifactProvenanceEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.metalTensorExecutionEstablished,
            ceiling.native300MAllocationEstablished,
            ceiling.native300MTrainingEstablished,
            ceiling.trajectoryExactResumeEstablished,
            ceiling.trainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryReplacementAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private func isLowercaseHex(_ value: String) -> Bool {
        !value.isEmpty
            && value.unicodeScalars.allSatisfy {
                ($0.value >= 48 && $0.value <= 57)
                    || ($0.value >= 97 && $0.value <= 102)
            }
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
