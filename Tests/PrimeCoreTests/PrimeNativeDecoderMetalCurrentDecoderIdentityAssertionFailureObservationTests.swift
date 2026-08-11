// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()
        throws
    {
        let observation = Observation.frozenV1

        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_metal_current_decoder_identity_assertion_failure_observation_v1"
        )
        XCTAssertEqual(
            observation.observationKind,
            "exact_main_metal_current_decoder_identity_assertion_failure_after_root36"
        )
        XCTAssertEqual(
            observation.predecessorObservationID,
            PrimeReviewedMainPrivateDependencyTLSFailureObservationV1
                .frozenV1.observationID
        )
        XCTAssertEqual(
            observation.predecessorCanonicalSHA256,
            "44917549689204bb9aabbd24b642d491a26fa501c3828cbc82009aa5e157a35d"
        )

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.pullRequestNumber, 85)
        XCTAssertEqual(repository.ref, "refs/heads/main")
        XCTAssertEqual(
            repository.revision,
            "2d0464ca35212d3d84781654b6a4e08158f27eab"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                "e540b73f6a46cf6e0de5b932d7167f178d4ac6fb",
                "5198f5da94977d11f5fcfabf65bb55a62cb31f26",
            ]
        )
        XCTAssertEqual(
            repository.tree,
            "be66df2affb85e2d846ba6f5f51e540d17864796"
        )
        XCTAssertEqual(repository.reviewedHeadTree, repository.tree)
        XCTAssertEqual(repository.mergedAt, "2026-08-11T20:34:49Z")
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.mergeCommitSignatureVerified)
        XCTAssertEqual(repository.mergeCommitSignatureReason, "valid")
        XCTAssertTrue(repository.exactMainRefStillMatchedAtAudit)
        XCTAssertEqual(
            repository.embeddedSourceIdentitySHA256,
            "bb94b8a0e846639e2260bbe50d352b797e37b64f6318d13b28f3cbc5e1cc8f43"
        )

        XCTAssertEqual(observation.observedSourceBindings.count, 9)
        XCTAssertEqual(
            observation.observedSourceBindings.map(\.path),
            [
                ".github/workflows/prime-active-root-quarantine.yml",
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-metal.sh",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeReviewedMainPrivateDependencyTLSFailureObservation.swift",
                "Tests/PrimeCoreTests/PrimeReviewedMainPrivateDependencyTLSFailureObservationTests.swift",
                "Sources/PrimeCore/PrimeNativeDecoderMetalRepairAuthority.swift",
                "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift",
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
        XCTAssertEqual(run.runID, 31_533_658_617)
        XCTAssertEqual(run.runNumber, 67)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.headBranch, "main")
        XCTAssertEqual(run.headRevision, repository.revision)
        XCTAssertEqual(run.actor, "psyop-archivist")
        XCTAssertEqual(run.triggeringActor, run.actor)
        XCTAssertEqual(run.createdAt, "2026-08-11T20:34:52Z")
        XCTAssertEqual(run.terminalUpdatedAt, "2026-08-11T21:00:56Z")
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "failure")
        XCTAssertEqual(run.checkSuiteID, 85_540_241_762)
        XCTAssertEqual(run.exactHeadPushRunCount, 1)
        XCTAssertTrue(run.previousAttemptURLWasNull)
        XCTAssertEqual(run.secondAttemptEndpointHTTPStatus, 404)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertFalse(run.rerunObserved)
        XCTAssertFalse(run.rerunAuthorized)

        let active = observation.activeRootJob
        XCTAssertEqual(active.id, 93_919_471_247)
        XCTAssertEqual(active.conclusion, "success")
        XCTAssertEqual(active.runnerLabel, "macos-15")
        XCTAssertEqual(active.runnerName, "GitHub Actions 1000001691")
        XCTAssertEqual(active.orderedSteps.map(\.number), Array(1 ... 7))
        XCTAssertTrue(
            active.orderedSteps.allSatisfy { $0.conclusion == "success" }
        )
        XCTAssertEqual(active.checkAnnotationCount, 0)

        let reviewed = observation.reviewedMainJob
        XCTAssertEqual(reviewed.id, 93_920_049_786)
        XCTAssertEqual(reviewed.conclusion, "failure")
        XCTAssertEqual(reviewed.runnerLabel, "macos-26")
        XCTAssertEqual(reviewed.runnerName, "GitHub Actions 1000001692")
        XCTAssertEqual(
            reviewed.orderedSteps.map(\.conclusion),
            [
                "success", "success", "success", "success", "success",
                "failure", "success",
            ]
        )
        XCTAssertEqual(
            reviewed.orderedSteps[5].name,
            "Run the Prime-owned decoder on live Metal"
        )
        XCTAssertEqual(reviewed.checkAnnotationCount, 1)
        XCTAssertEqual(reviewed.checkAnnotationPath, ".github")
        XCTAssertEqual(reviewed.checkAnnotationStartLine, 74_480)
        XCTAssertEqual(reviewed.checkAnnotationEndLine, 74_480)
        XCTAssertEqual(
            reviewed.checkAnnotationMessage,
            "Process completed with exit code 2."
        )

        let toolchain = observation.runnerToolchain
        XCTAssertEqual(toolchain.runnerVersion, "2.336.0")
        XCTAssertEqual(toolchain.runnerProvisionerVersion, "20260707.563")
        XCTAssertEqual(toolchain.activeRunnerImage, "macos-15-arm64")
        XCTAssertEqual(toolchain.activeRunnerImageVersion, "20260727.0256.1")
        XCTAssertEqual(toolchain.activeOperatingSystemBuild, "24G720")
        XCTAssertEqual(toolchain.reviewedRunnerImage, "macos-26-arm64")
        XCTAssertEqual(toolchain.reviewedRunnerImageVersion, "20260728.0273.1")
        XCTAssertEqual(toolchain.reviewedOperatingSystemBuild, "25F84")
        XCTAssertEqual(toolchain.reviewedArchitecture, "arm64")
        XCTAssertEqual(toolchain.xcodeVersion, "26.6")
        XCTAssertEqual(toolchain.xcodeBuildVersion, "17F113")
        XCTAssertEqual(toolchain.swiftTarget, "arm64-apple-macosx26.0")
        XCTAssertEqual(toolchain.macOSSDKVersion, "26.5")
        XCTAssertTrue(toolchain.exactHostedRunnerImagesRecorded)
        XCTAssertFalse(toolchain.exactPhysicalRunnerIdentityRecorded)

        assertRawLog(
            observation.activeRootRawLog,
            byteCount: 232_035,
            lfByteCount: 1_740,
            sha256:
                "46187396b65c13adf6e1da20d625890eb804f6b4ba476615ed0a532a55c89682"
        )
        assertRawLog(
            observation.reviewedMainRawLog,
            byteCount: 10_192_525,
            lfByteCount: 77_932,
            sha256:
                "0b2d720a64c341dc874f3271b0e4a5792c6d7af36337f1d15f1641d27937ef16"
        )
        assertRawLog(
            observation.secureFetchStepRawLog,
            byteCount: 4_893,
            lfByteCount: 54,
            sha256:
                "7c50a7eddd18f8c8049ef431164da6175ffae284140dfd68a9062d8d0bc701a2"
        )
        assertRawLog(
            observation.focusedContractsStepRawLog,
            byteCount: 337_696,
            lfByteCount: 3_310,
            sha256:
                "f972a9fe4bf0f00c467dd90f43a60cc594f2228cec6e720d8acfd2816b6f61e1"
        )
        assertRawLog(
            observation.liveMetalStepRawLog,
            byteCount: 9_843_772,
            lfByteCount: 74_480,
            sha256:
                "343c5ae69d86eb6ba16d1ab0fe72663651c3ca3d4ae921e632c355e2f7506f6a"
        )

        let archive = observation.rawLogArchive
        XCTAssertEqual(archive.byteCount, 1_311_898)
        XCTAssertEqual(
            archive.sha256,
            "7ab28a53a38c61145065a921c53414d5ce15fe40a6db66b678c65b3c93e05736"
        )
        XCTAssertEqual(archive.memberCount, 18)
        XCTAssertEqual(archive.members.count, archive.memberCount)
        XCTAssertEqual(
            archive.members.reduce(0) { $0 + $1.byteCount },
            archive.uncompressedByteCount
        )
        XCTAssertEqual(archive.uncompressedByteCount, 20_850_557)
        XCTAssertEqual(
            Set(archive.members.map(\.path)).count,
            archive.members.count
        )
        XCTAssertTrue(archive.repeatedDownloadsWereByteIdentical)
        XCTAssertTrue(archive.memberTimestampsAreDOSZero)
        XCTAssertEqual(
            archive.assertionStepMemberFirstDiagnosticTimestamp,
            "2026-08-11T21:00:38.2311960Z"
        )
        XCTAssertEqual(
            archive.reviewedAggregateFirstDiagnosticTimestamp,
            "2026-08-11T21:00:38.2312020Z"
        )
        XCTAssertNotEqual(
            archive.assertionStepMemberFirstDiagnosticTimestamp,
            archive.reviewedAggregateFirstDiagnosticTimestamp
        )
        XCTAssertEqual(
            archive.assertionStepMemberExitTimestamp,
            "2026-08-11T21:00:44.4133280Z"
        )
        XCTAssertEqual(
            archive.reviewedAggregateExitTimestamp,
            "2026-08-11T21:00:44.4133330Z"
        )

        let execution = observation.executionBoundary
        XCTAssertTrue(execution.activeRootGatePassed)
        XCTAssertTrue(execution.dependencyFreeSwiftParsePassed)
        XCTAssertEqual(execution.latinTestInvocationCount, 1)
        XCTAssertEqual(execution.latinCompletedTestCount, 116)
        XCTAssertEqual(execution.latinFailureCount, 0)
        XCTAssertEqual(execution.latinSkipCount, 0)
        XCTAssertEqual(execution.latinFinalSummaryOccurrenceCount, 2)
        XCTAssertEqual(execution.securePrivateDependencyFetchInvocationCount, 1)
        XCTAssertTrue(execution.securePrivateDependencyFetchCompleted)
        XCTAssertEqual(
            execution.privateDependencyRevision,
            "d37885a278f1c37484a94d0f401a418735e66519"
        )
        XCTAssertEqual(execution.privateDependencySubmoduleRevisions.count, 2)
        XCTAssertEqual(execution.focusedRootRequiredTestCount, 36)
        XCTAssertEqual(execution.focusedRootInvocationCount, 1)
        XCTAssertEqual(execution.focusedRootCompletedTestCount, 36)
        XCTAssertEqual(execution.focusedRootFailureCount, 0)
        XCTAssertEqual(execution.focusedRootSkipCount, 0)
        XCTAssertEqual(execution.focusedRootSuccessSummaryCount, 2)
        XCTAssertEqual(
            execution.retainedLiveSequence,
            [
                "prime-ci-native-decoder-metal.sh",
                "prime-ci-native-decoder-runtime-closure.sh",
                "prime-ci-native-decoder-tokenizer-compatibility.sh",
            ]
        )
        XCTAssertEqual(execution.retainedLiveSequenceWorkflowCounts, [1, 1, 1])
        XCTAssertEqual(execution.retainedLiveSequenceInvocationCounts, [1, 0, 0])
        XCTAssertEqual(execution.metallibBuildInvocationCount, 1)
        XCTAssertTrue(execution.metallibBuildCompleted)
        XCTAssertEqual(execution.metallibByteCount, 6_292_732)
        XCTAssertEqual(
            execution.metallibSHA256,
            "53aa69728711f18cdf0886e2397bc1f8777b02c00d2235f83c03f71599470083"
        )
        XCTAssertEqual(execution.metalTestInvocationCount, 1)
        XCTAssertEqual(execution.metalStartedTestCount, 44)
        XCTAssertEqual(execution.metalPassedTestCount, 43)
        XCTAssertEqual(execution.metalFailedTestCount, 1)
        XCTAssertEqual(execution.metalAssertionFailureCount, 2)
        XCTAssertEqual(execution.metalSkipCount, 0)
        XCTAssertEqual(execution.metalFailureSummaryOccurrenceCount, 2)
        XCTAssertEqual(
            [
                execution.runtimeClosureInvocationCount,
                execution.runtimeAuthorityCompletedTestCount,
                execution.runtimeReceiptCount,
                execution.tokenizerCompatibilityInvocationCount,
                execution.tokenizerAuthorityCompletedTestCount,
                execution.tokenizerReceiptCount,
                execution.stage2ValidationPackageCommandCount,
                execution.stage2ValidationFilterCount,
                execution.stage2ValidationLogPathCount,
                execution.stage2ValidationScratchPathCount,
                execution.stage2ValidationBuildPathCount,
                execution.stage2ValidationCachePathCount,
                execution.stage2ValidationConfigPathCount,
                execution.stage2ValidationSecurityPathCount,
                execution.stage2InvocationCount,
                execution.retiredSeed42CheckpointCommandCount,
                execution.retiredSeed43CheckpointCommandCount,
                execution.checkpointReceiptMarkerCount,
                execution.artifactUploadStepCount,
            ],
            Array(repeating: 0, count: 19)
        )

        let drift = observation.sourceDriftBoundary
        XCTAssertEqual(
            drift.decoderSourcePath,
            "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift"
        )
        XCTAssertEqual(
            drift.frozenMetalAuthorityGitBlob,
            "835a4826549e1f28ec27e3533f746218beb3bdf2"
        )
        XCTAssertEqual(drift.frozenMetalAuthorityByteCount, 39_050)
        XCTAssertEqual(
            drift.frozenMetalAuthoritySHA256,
            "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b"
        )
        XCTAssertEqual(
            drift.currentDecoderGitBlob,
            "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f"
        )
        XCTAssertEqual(drift.currentDecoderByteCount, 39_598)
        XCTAssertEqual(
            drift.currentDecoderSHA256,
            "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994"
        )
        XCTAssertEqual(drift.currentMinusFrozenByteCount, 548)
        XCTAssertEqual(
            drift.stage2SeamIntroducingRevision,
            "f13322ebc368c639a0f04b7570af093cc57ec22b"
        )
        XCTAssertEqual(
            drift.stage2SeamMethod,
            "package func trainingLogitsNoCache(_ rankTwoTokenIDs: MLXArray) -> MLXArray"
        )
        XCTAssertEqual(drift.stage2SeamAddedLineCount, 14)
        XCTAssertTrue(drift.diffContainsOnlyStage2TrainingSeam)
        XCTAssertTrue(drift.frozenMetalAuthorityRemainsHistorical)
        XCTAssertTrue(drift.currentDecoderMatchesExactMergeTree)
        XCTAssertTrue(drift.observationMutatesNeitherIdentity)

        let assertion = observation.assertionFailureBoundary
        XCTAssertEqual(assertion.failedJobStepNumber, 6)
        XCTAssertEqual(
            assertion.failedTestMethod,
            "testMetalRepairAuthorityIsAppendOnlyAndSourceExact"
        )
        XCTAssertEqual(assertion.byteCountAssertionLine, 338)
        XCTAssertEqual(assertion.sha256AssertionLine, 339)
        XCTAssertEqual(
            assertion.exactByteCountAssertionMessage,
            "XCTAssertEqual failed: (\"39598\") is not equal to (\"39050\")"
        )
        XCTAssertEqual(
            assertion.exactSHA256AssertionMessage,
            "XCTAssertEqual failed: (\"d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994\") is not equal to (\"058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b\")"
        )
        XCTAssertEqual(assertion.failedTestCaseCount, 1)
        XCTAssertEqual(assertion.assertionFailureCount, 2)
        XCTAssertEqual(assertion.processExitCode, 2)
        XCTAssertEqual(
            assertion.exactExitMessage,
            "Process completed with exit code 2."
        )
        XCTAssertEqual(
            assertion.failureClassification,
            "metal_authority_current_decoder_identity_assertion_stale_after_stage2_package_only_seam"
        )

        let semantics = observation.failureSemantics
        XCTAssertTrue(semantics.secureDependencyFetchSuccessObserved)
        XCTAssertTrue(semantics.predecessorTLSFailureWasNotRepeated)
        XCTAssertTrue(semantics.focusedRootSuccessObserved)
        XCTAssertTrue(semantics.freshMetallibBuildObserved)
        XCTAssertTrue(semantics.frozenMetalAuthorityIdentityAssertionFailureObserved)
        XCTAssertTrue(semantics.currentDecoderStage2SeamDriftEstablished)
        XCTAssertTrue(semantics.failureLimitedToCurrentDecoderIdentityAssertion)
        XCTAssertTrue(semantics.runtimeAndTokenizerBlockedByOrderedFailClosedSequence)
        XCTAssertTrue(semantics.predecessorTLSObservationRemainsFrozen)
        XCTAssertTrue(semantics.predecessorStage2FailureObservationRemainsFrozen)
        XCTAssertTrue(semantics.predecessorStage2AttemptRemainsExhausted)
        XCTAssertTrue(semantics.separateIdentityAssertionRepairRequired)
        XCTAssertTrue(semantics.stage3RemainsBlocked)
        XCTAssertTrue(semanticFalseClaims(semantics).allSatisfy { !$0 })

        let artifacts = observation.artifactBoundary
        XCTAssertEqual(artifacts.actionsArtifactsTotalCount, 0)
        XCTAssertTrue(artifacts.actionsArtifactsArrayExactlyEmpty)
        XCTAssertEqual(artifacts.publishedWorkflowArtifactCount, 0)
        XCTAssertEqual(artifacts.artifactUploadStepCount, 0)
        XCTAssertTrue(artifacts.runLogArchiveObserved)
        XCTAssertTrue(artifactFalseClaims(artifacts).allSatisfy { !$0 })

        XCTAssertTrue(
            authorityClaims(observation.authorityCeiling).allSatisfy { !$0 }
        )
        XCTAssertTrue(observation.status.hasPrefix("ABSTAIN_exact_main"))
        XCTAssertEqual(observation.orderedRequiredSeparateActions.count, 5)
        XCTAssertTrue(
            observation.orderedRequiredSeparateActions.contains(
                "require_root37_then_metal44_then_runtime1_then_tokenizer1_before_any_success_observation"
            )
        )

        requireSendable(Observation.self)
        let canonical = try observation.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(observation))
        let canonicalHash = PrimeSHA256.hexDigest(of: canonical)
        XCTAssertEqual(
            canonicalHash,
            "7d1d90667fdba0171b4c6b98431b7fd045fe5d2c11bd640689bb4bda6dde3424"
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
        XCTAssertGreaterThan(valuePaths.count, 300)
        XCTAssertGreaterThan(dictionaryPaths.count, 25)
        XCTAssertGreaterThan(scalarPaths.count, 225)

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
        XCTAssertGreaterThan(regularDecodedDriftCount, 200)

        var unknownFieldCount = 0
        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary[
                        "unknown_metal_current_decoder_identity_failure_field_\(index)"
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
        _ log: PrimeNativeDecoderMetalIdentityFailureRawLogIdentityV1,
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
        _ semantics: PrimeNativeDecoderMetalIdentityFailureSemanticsV1
    ) -> [Bool] {
        [
            semantics.privateDependencyTLSFailureObserved,
            semantics.metallibBuildFailureObserved,
            semantics.metalFunctionalRegressionEstablished,
            semantics.frozenMetalAuthorityMutationPerformed,
            semantics.decoderSourceMutationPerformed,
            semantics.currentDecoderIdentityRepairAttempted,
            semantics.currentDecoderIdentityRepairEstablished,
            semantics.metalValidationEstablished,
            semantics.runtimeClosureEvaluated,
            semantics.runtimeClosureEstablished,
            semantics.tokenizerCompatibilityEvaluated,
            semantics.tokenizerCompatibilityEstablished,
            semantics.stage2ExecutionEvaluated,
            semantics.stage2ExecutionEstablished,
            semantics.stage2BootstrapRepairEstablished,
            semantics.stage3AuthorityEstablished,
        ]
    }

    private func artifactFalseClaims(
        _ artifacts: PrimeNativeDecoderMetalIdentityFailureArtifactBoundaryV1
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
        _ ceiling: PrimeNativeDecoderMetalIdentityFailureAuthorityCeilingV1
    ) -> [Bool] {
        [
            ceiling.rerunAuthorized,
            ceiling.replacementRunAuthorized,
            ceiling.workflowMutationAuthorized,
            ceiling.frozenMetalAuthorityMutationAuthorized,
            ceiling.decoderSourceReversionAuthorized,
            ceiling.currentDecoderIdentityAssertionRepairAuthorized,
            ceiling.currentDecoderIdentityAssertionRepairEstablished,
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
