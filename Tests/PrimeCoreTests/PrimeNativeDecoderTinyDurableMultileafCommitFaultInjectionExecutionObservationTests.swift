// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservationTests:
    XCTestCase
{
    typealias Observation =
        PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndSuccessCeiling()
        throws
    {
        let observation = Observation.frozenV1
        try observation.validateExactV1()
        let canonical = try observation.canonicalData()
        XCTAssertEqual(try Observation.decodeCanonical(canonical), observation)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Observation.canonicalSHA256)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any])
        var mutationCount = 0
        for path in leafPaths(object) {
            var copy: Any = object
            XCTAssertTrue(mutate(&copy, path))
            let data = try JSONSerialization.data(
                withJSONObject: copy,
                options: [.sortedKeys, .withoutEscapingSlashes])
            XCTAssertThrowsError(try Observation.decodeCanonical(data))
            mutationCount += 1
        }
        XCTAssertGreaterThan(mutationCount, 75)

        XCTAssertEqual(observation.run.terminalConclusion, "success")
        XCTAssertEqual(observation.run.workflowRunID, 31_726_013_984)
        XCTAssertEqual(observation.run.workflowRunNumber, 97)
        XCTAssertEqual(observation.run.runAttempt, 1)
        XCTAssertEqual(observation.run.artifactCount, 0)
        XCTAssertEqual(observation.run.rerunCount, 0)
        XCTAssertEqual(observation.predecessor.focusedRootTestCount, 50)
        XCTAssertEqual(observation.predecessor.focusedWholeTestCount, 56)
        XCTAssertEqual(observation.secureFetch.stepConclusion, "success")
        XCTAssertEqual(observation.secureFetch.invocationCount, 1)
        XCTAssertEqual(observation.secureFetch.completionCount, 1)
        XCTAssertEqual(
            observation.secureFetch.authenticatedDepthOneFetchCount,
            1)
        XCTAssertEqual(
            observation.secureFetch.submoduleUpdateInvocationCount,
            1)
        XCTAssertEqual(observation.secureFetch.mlxCloneCount, 1)
        XCTAssertEqual(observation.secureFetch.mlxCCloneCount, 1)
        XCTAssertEqual(observation.secureFetch.workflowAuthoredRetryCount, 0)
        XCTAssertEqual(
            observation.secureFetch.gitInternalRetryScheduledCount,
            0)
        XCTAssertEqual(observation.secureFetch.tlsFailureCount, 0)
        XCTAssertEqual(observation.secureFetch.tlsVerificationBypassCount, 0)
        XCTAssertEqual(observation.secureFetch.customCAInstallationCount, 0)
        XCTAssertEqual(observation.receipt.startedCount, 1)
        XCTAssertEqual(observation.receipt.passedCount, 1)
        XCTAssertEqual(observation.receipt.failureCount, 0)
        XCTAssertEqual(observation.receipt.skipCount, 0)
        XCTAssertEqual(observation.receipt.durationMilliseconds, 5_128)
        XCTAssertEqual(observation.receipt.publishedFileCount, 4)
        XCTAssertEqual(observation.receipt.injectedFailureCount, 7)
        XCTAssertTrue(observation.receipt.finalCommitManifestPublishedLast)
        XCTAssertTrue(
            observation.receipt
                .externallySuppliedExactCommitBindingRequired)
        XCTAssertTrue(
            observation.receipt.everyPartialPrecommitInventoryQuarantined)
        XCTAssertTrue(
            observation.receipt.exactStage3SnapshotRoundTripEstablished)
        XCTAssertTrue(observation.artifact.reclaimedAfterTest)
        XCTAssertFalse(observation.artifact.retainedArtifactEstablished)
        XCTAssertFalse(observation.artifact.artifactUploadInvoked)
        XCTAssertEqual(
            observation.retirement.stage4LauncherInvocationCount,
            0)
        XCTAssertEqual(observation.retirement.stage4ReceiptCount, 0)
        XCTAssertEqual(
            observation.retirement.stage4LauncherGitBlob,
            "4184e23941460fe397e284e094d782f1265d19d9")
        XCTAssertEqual(
            observation.retirement.stage4LauncherSHA256,
            "e3eb8a66340c924bbb579023eee04eaee1242a8a682f17ae668898ee8d36c6a2")
        XCTAssertTrue(observation.retirement.stage4LauncherSourcePreserved)
        XCTAssertTrue(observation.retirement.successfulAttemptConsumed)
        XCTAssertEqual(observation.retirement.expectedRootTestCount, 51)
        XCTAssertFalse(observation.ceiling.additionalExecutionOrRerunAuthorized)
        XCTAssertFalse(observation.ceiling.retainedArtifactAuthorized)
        XCTAssertFalse(observation.ceiling.artifactUploadAuthorized)
        XCTAssertFalse(observation.ceiling.checkpointAdmissionGranted)
        XCTAssertFalse(observation.ceiling.publicV2CodecWideningAuthorized)
        XCTAssertFalse(observation.ceiling.metalDeterminismEstablished)
        XCTAssertFalse(observation.ceiling.stage5Authorized)
        XCTAssertFalse(observation.ceiling.native300MTrainingAuthorized)
        XCTAssertFalse(observation.ceiling.productUseAuthorized)
        XCTAssertFalse(observation.ceiling.publicationAuthorized)
        XCTAssertTrue(
            observation.retirement.exactMainRetirementClosureRequired)
        XCTAssertThrowsError(
            try Observation.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(
            try Observation.decodeCanonical(canonical + Data([0x0a])))
    }

    private func leafPaths(
        _ value: Any,
        _ prefix: [AnyHashable] = []
    ) -> [[AnyHashable]] {
        if let dictionary = value as? [String: Any] {
            return dictionary.keys.sorted().flatMap {
                leafPaths(dictionary[$0] as Any, prefix + [$0])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap {
                leafPaths(array[$0], prefix + [$0])
            }
        }
        return [prefix]
    }

    private func mutate(
        _ value: inout Any,
        _ path: [AnyHashable]
    ) -> Bool {
        guard let head = path.first else {
            if let bool = value as? Bool {
                value = !bool
            } else if let number = value as? NSNumber {
                value = number.intValue + 1
            } else if let string = value as? String {
                value = string + "_mutation"
            } else {
                return false
            }
            return true
        }
        if let key = head as? String,
           var dictionary = value as? [String: Any],
           var child = dictionary[key]
        {
            guard mutate(&child, Array(path.dropFirst())) else {
                return false
            }
            dictionary[key] = child
            value = dictionary
            return true
        }
        if let index = head as? Int,
           var array = value as? [Any],
           array.indices.contains(index)
        {
            var child = array[index]
            guard mutate(&child, Array(path.dropFirst())) else {
                return false
            }
            array[index] = child
            value = array
            return true
        }
        return false
    }
}
