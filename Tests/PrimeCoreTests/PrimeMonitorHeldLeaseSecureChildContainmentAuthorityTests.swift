// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeMonitorHeldLeaseSecureChildContainmentAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeMonitorHeldLeaseSecureChildContainmentAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        requireSendable(Authority.self)
        let authority = Authority.frozenV1

        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.schemaID,
            "prime_monitor_held_lease_secure_child_containment_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityID,
            "ergentics_prime_monitor_held_lease_secure_child_containment_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityKind,
            "pure_authority_for_later_closed_monitor_held_lease_secure_child_containment_composition"
        )
        XCTAssertEqual(
            authority.status,
            "AUTHORITY_ONLY_future_additive_exact5_nested_capture_composition_no_mechanics_continuity_mlx_durable_false"
        )

        XCTAssertEqual(authority.predecessorFiles.count, 5)
        assertFile(
            authority.predecessorFiles[0],
            path: ".github/scripts/prime-ci-active-root-quarantine.sh",
            status: "M",
            mode: "100755",
            blob: "879f938fbe9f93d891db8d5dc4ef997ac91cc6a5",
            bytes: 1_278_954,
            lines: 21_065,
            sha256:
                "d72302871539522c17ecacec0237a057e72e90046ef6bfb6481544450a4a65e3"
        )
        assertFile(
            authority.predecessorFiles[1],
            path: ".github/workflows/prime-active-root-quarantine.yml",
            status: "M",
            mode: "100644",
            blob: "533217661d78441be6e76d702836d3a060bb7e63",
            bytes: 153_404,
            lines: 710,
            sha256:
                "8b3addced346429f5f7d35dc3943761b3cd9d030b7afc1501f20fdb6f97094f3"
        )
        assertFile(
            authority.predecessorFiles[2],
            path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
            status: "M",
            mode: "100644",
            blob: "9f101b32c2c5bc2df889b97f5d8545a5b62a29f5",
            bytes: 546,
            lines: 13,
            sha256:
                "c07a9647804b30abdaeb771df72b3c72995498acd4e1f916929b1ae7912e552f"
        )
        assertFile(
            authority.predecessorFiles[3],
            path: "Sources/PrimeCore/PrimeExclusiveResourceLease.swift",
            status: "A",
            mode: "100644",
            blob: "d5e98f2264102ee81840121399c7438082f6a077",
            bytes: 791,
            lines: 24,
            sha256:
                "2d57ca21d1fdc17bd235a5be19a548c476d1a7c42e68040474ac03bb7fef8885"
        )
        assertFile(
            authority.predecessorFiles[4],
            path: "Tests/PrimeCoreTests/PrimeExclusiveResourceLeaseTests.swift",
            status: "A",
            mode: "100644",
            blob: "2dcf7af7b9a5689bfbe932bc0140c33dd1ee05e2",
            bytes: 1_298,
            lines: 37,
            sha256:
                "b87c694a1481a81815fc4df4abf42ef3a021b5b84c90295e59c1c0b54cb32424"
        )
        XCTAssertEqual(Set(authority.predecessorFiles.map(\.path)).count, 5)
        XCTAssertEqual(
            authority.predecessorFiles.map(\.gitStatus),
            ["M", "M", "M", "A", "A"]
        )

        let repository = authority.predecessorRepositoryClosure
        XCTAssertEqual(repository.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(repository.pullRequestNumber, 126)
        XCTAssertEqual(
            repository.baseRevision,
            "e1d90e3f2ae6c4d3c279bf5fb64ce3baafc1f540"
        )
        XCTAssertEqual(
            repository.baseTree,
            "569963ff059acf9c444c964eb224b2c8d96d3c93"
        )
        XCTAssertEqual(
            repository.reviewedHeadRevision,
            "c2a42ca4a3bd1c31f06560dd1bff970039dcc7f0"
        )
        XCTAssertEqual(
            repository.reviewedHeadTree,
            "127dc50e07e192e5868ef734cd27f74d59c63de6"
        )
        XCTAssertEqual(
            repository.reviewedHeadSoleParentRevision,
            repository.baseRevision
        )
        XCTAssertEqual(
            repository.mergeRevision,
            "ef64686e76d2d67e46deb696bfeef18ea96c96a2"
        )
        XCTAssertEqual(repository.mergeTree, repository.reviewedHeadTree)
        XCTAssertEqual(
            repository.orderedMergeParentRevisions,
            [repository.baseRevision, repository.reviewedHeadRevision]
        )
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.reviewedHeadIsSoleChildOfBase)
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.githubSignatureVerified)
        XCTAssertEqual(repository.githubSignatureReason, "valid")
        XCTAssertEqual(
            repository.githubSignatureVerifiedAt,
            "2026-08-20T04:42:17Z"
        )

        assertRun(
            authority.predecessorPullRequestRun,
            id: 32_332_270_879,
            number: 151,
            suite: 87_648_317_872,
            event: "pull_request",
            ref: "refs/pull/126/merge",
            head: repository.reviewedHeadRevision,
            activeJob: 96_315_061_445,
            reviewedJob: 96_315_665_367,
            reviewedConclusion: "skipped",
            reviewedSteps: 0,
            root: 0,
            isolated: [],
            focused: 0,
            live: 0,
            aggregate: 0,
            soleTestStarts: 0
        )
        assertRun(
            authority.predecessorPushMainRun,
            id: 32_332_846_929,
            number: 152,
            suite: 87_649_771_967,
            event: "push",
            ref: "refs/heads/main",
            head: repository.mergeRevision,
            activeJob: 96_316_657_574,
            reviewedJob: 96_317_291_067,
            reviewedConclusion: "success",
            reviewedSteps: 7,
            root: 82,
            isolated: [1, 1, 2, 2],
            focused: 88,
            live: 46,
            aggregate: 134,
            soleTestStarts: 1
        )
        XCTAssertEqual(
            authority.predecessorPushMainRun.retainedMetalTestCount,
            44
        )
        XCTAssertEqual(
            authority.predecessorPushMainRun
                .retainedMaintainedRuntimeTestCount,
            1
        )
        XCTAssertEqual(
            authority.predecessorPushMainRun.retainedTokenizerTestCount,
            1
        )

        assertLog(
            authority.predecessorPullRequestActiveRootLog,
            jobID: 96_315_061_445,
            bytes: 334_036,
            lines: 1_894,
            sha256:
                "f6287c8ab27e18c784736009936b43e9436c8b9c47e1693430e16066d52bb3ae"
        )
        assertLog(
            authority.predecessorPushMainActiveRootLog,
            jobID: 96_316_657_574,
            bytes: 334_048,
            lines: 1_894,
            sha256:
                "5e4cf4e2f5760bc39f79109dcc1a5f34a6ebf836810cd3164c15891b26b530da"
        )
        assertLog(
            authority.predecessorPushMainReviewedMainLog,
            jobID: 96_317_291_067,
            bytes: 10_331_433,
            lines: 79_005,
            sha256:
                "64222d296afef53df0dc9e2b827a0762932af62e798a8fcb5b8dcc34c34f57b2"
        )

        let a1 = authority.a1Contract
        XCTAssertEqual(a1.neutralLeaseType, "PrimeExclusiveResourceLease")
        XCTAssertEqual(a1.neutralErrorType, "PrimeExclusiveResourceLeaseError")
        XCTAssertEqual(
            a1.exactNeutralLeaseAliasDeclaration,
            "public typealias PrimeExclusiveResourceLease = PrimeMetalDeviceLease"
        )
        XCTAssertEqual(
            a1.exactNeutralErrorAliasDeclaration,
            "public typealias PrimeExclusiveResourceLeaseError = PrimeMetalDeviceLeaseError"
        )
        XCTAssertEqual(
            a1.exactMarkerProtocolDeclaration,
            "protocol PrimeExclusiveResourceLeaseCapability: AnyObject, Sendable {}"
        )
        XCTAssertEqual(
            a1.exactConcreteConformanceDeclaration,
            "extension PrimeMetalDeviceLease: PrimeExclusiveResourceLeaseCapability {}"
        )
        XCTAssertEqual(
            a1.exactTypedRetentionStoredDeclaration,
            "private let lease: any PrimeExclusiveResourceLeaseCapability"
        )
        XCTAssertEqual(
            a1.exactTypedRetentionInitializerDeclaration,
            "init(_ lease: any PrimeExclusiveResourceLeaseCapability)"
        )
        XCTAssertEqual(
            a1.exactTypedRetentionIdentityMethodDeclaration,
            "func retains(_ candidate: any PrimeExclusiveResourceLeaseCapability) -> Bool"
        )
        XCTAssertTrue(a1.aliasExposesPublicRelease)
        XCTAssertTrue(
            a1.retainingExternallySuppliedAliasProvesObjectLifetimeOnly
        )
        XCTAssertFalse(
            a1.retainingExternallySuppliedAliasProvesKernelLockContinuity
        )
        XCTAssertTrue(a1.callerMayReleaseExternallySuppliedAlias)
        XCTAssertFalse(a1.mechanicsAddedByA1)
        XCTAssertEqual(
            [
                a1.leaseAcquireInvocationCountInA1Patch,
                a1.leaseReleaseInvocationCountInA1Patch,
                a1.processInvocationCountInA1Patch,
            ],
            [0, 0, 0]
        )

        let future = authority.futureCompositionContract
        XCTAssertEqual(
            future.implementationType,
            "PrimeMonitorHeldLeaseSecureChildContainment"
        )
        assertExactFive(
            future.exactOrderedPaths,
            source:
                "Sources/PrimeCore/PrimeMonitorHeldLeaseSecureChildContainment.swift",
            test:
                "Tests/PrimeCoreTests/PrimeMonitorHeldLeaseSecureChildContainmentTests.swift"
        )
        XCTAssertEqual(future.exactPathCount, 5)
        XCTAssertTrue(future.dependencyFree)
        XCTAssertEqual(
            future.publicCapabilityScope,
            "closed_validation_workflow_fixture_child_only"
        )
        XCTAssertEqual(
            future.exactAcceptedClosedAPIInputs,
            [
                "trustedLeaseDirectoryURL",
                "executableURL",
                "privateWorkingDirectoryURL",
                "privateResultDirectoryURL",
                "mode",
            ]
        )
        XCTAssertEqual(
            future.acceptedLeaseDirectoryParameter,
            "trustedLeaseDirectoryURL"
        )
        XCTAssertEqual(
            future.fixedPrivateLeaseLeaf,
            "prime-secure-child-monitor-held-resource-lease-v1.lock"
        )
        XCTAssertTrue(
            future.executableURLIsLocatorForFixedAuthenticatedFixtureOnly
        )
        XCTAssertFalse(future.callerSuppliedFullLeaseFileURLAccepted)
        XCTAssertFalse(future.callerSuppliedResourceIdentifierAccepted)
        XCTAssertFalse(future.callerSuppliedLeaseObjectAccepted)
        XCTAssertFalse(future.genericChildAccepted)
        XCTAssertFalse(future.leaseObjectReturned)
        XCTAssertFalse(future.releaseHandleReturned)
        XCTAssertEqual(future.exactLeaseType, "PrimeExclusiveResourceLease")
        XCTAssertEqual(
            future.productionAcquireCall,
            "PrimeExclusiveResourceLease.acquire(at:)"
        )
        XCTAssertEqual(future.productionAcquireCount, 1)
        XCTAssertTrue(future.acquisitionMustPrecedePlanConstruction)
        XCTAssertTrue(future.acquisitionMustPrecedePreparedFixtureConstruction)
        XCTAssertTrue(future.rawLeaseReferenceMustRemainPrivateAndNonescaping)
        XCTAssertEqual(future.explicitReleaseCallCount, 0)
        XCTAssertEqual(future.leaseReacquisitionCount, 0)
        XCTAssertEqual(future.descriptorTransferCount, 0)
        XCTAssertEqual(future.workerInheritedLeaseDescriptorCount, 0)
        XCTAssertEqual(future.workerLeaseAcquisitionCount, 0)
        XCTAssertEqual(future.workerLeaseReleaseCount, 0)
        XCTAssertEqual(
            future.monitorOwnsLeasePolicy,
            "closed_monitor_owns_private_lease_policy_only"
        )
        XCTAssertTrue(future.existingSupervisorOwnsChildLifecycleOnly)
        XCTAssertFalse(future.monitorOwnsChildLifecycle)
        XCTAssertFalse(future.existingSupervisorOwnsLease)
        XCTAssertEqual(
            future.orderedOwnershipChain,
            [
                "PrimeExclusiveResourceLease",
                "PrimeExclusiveResourceLeaseRetention",
                "PrimeSecureChildLeaseRetention",
                "PrimeTrustedSecureChildProcessCapture.State",
                "PrimeTrustedSecureChildProcessCapture.Consumption",
                "PrimeTrustedSecureChildProcessCapture.Consumption.ExecutionClaim",
                "PrimeSecureChildExecutionKernel.Result",
            ]
        )
        XCTAssertTrue(future.ownershipChainMustRemainInBand)
        XCTAssertEqual(
            future.existingClosedPlanFactory,
            "PrimeSecureChildProcessPlanV1.validationWorkflowFixture(mode:)"
        )
        XCTAssertEqual(
            future.existingPreparedFixtureType,
            "PrimeSecureChildPreparedFixture"
        )
        XCTAssertEqual(
            future.existingCaptureType,
            "PrimeTrustedSecureChildProcessCapture"
        )
        XCTAssertEqual(
            future.existingExecutionKernelType,
            "PrimeSecureChildExecutionKernel"
        )
        XCTAssertFalse(future.arbitraryExecutableAccepted)
        XCTAssertFalse(future.arbitraryArgumentsAccepted)
        XCTAssertFalse(future.arbitraryEnvironmentAccepted)
        XCTAssertTrue(
            future
                .ordinaryLeaseDestructionOnlyAfterTerminalContainedReturnOrUnwind
        )
        XCTAssertTrue(future.preSpawnFailureMayReleaseBecauseNoChildExists)
        XCTAssertTrue(future.failStopPreservesNonreturningContainmentFailure)
        XCTAssertTrue(future.layerABytesMustRemainByteIdentical)
        XCTAssertEqual(
            future.layerATelemetryScope,
            "cooperating_host_path_local"
        )
        XCTAssertTrue(future.layerATelemetryAdvisory)
        XCTAssertTrue(future.layerATelemetryOwnerMustRemainLive)
        XCTAssertTrue(future.layerATelemetryRetentionIsInBandWithinCapture)
        XCTAssertTrue(
            future
                .layerATelemetryLabelExternallyOwnedAdvisoryIsNotOwnershipProof
        )
        XCTAssertFalse(future.layerATelemetryProvesExclusiveOwnership)
        XCTAssertFalse(future.childLifetimeContinuityEstablished)
        XCTAssertFalse(future.mlxDeviceIdentityEstablished)
        XCTAssertFalse(future.physicalMetalReservationEstablished)
        XCTAssertFalse(future.durableEvidenceEstablished)
        XCTAssertTrue(future.pureInMemoryFakeTestOnly)
        XCTAssertEqual(
            future.pureFakeMayProveOnly,
            [
                "identity",
                "strong_object_lifetime",
                "ordered_ownership_topology",
            ]
        )
        XCTAssertFalse(future.actualKernelLockContinuityCanaryIncluded)
        XCTAssertTrue(
            future.actualKernelLockContinuityCanaryRequiresSeparateAuthority
        )

        let scope = authority.authorityScope
        assertExactFive(
            scope.exactOrderedPaths,
            source:
                "Sources/PrimeCore/PrimeMonitorHeldLeaseSecureChildContainmentAuthority.swift",
            test:
                "Tests/PrimeCoreTests/PrimeMonitorHeldLeaseSecureChildContainmentAuthorityTests.swift"
        )
        XCTAssertEqual(scope.exactPathCount, 5)
        XCTAssertEqual(scope.activeRootLatinTestCount, 116)
        XCTAssertEqual(scope.rootTestCount, 83)
        XCTAssertEqual(scope.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(scope.isolatedTestCount, 6)
        XCTAssertEqual(scope.focusedWholeTestCount, 89)
        XCTAssertEqual(scope.rootTestCount + scope.isolatedTestCount, 89)
        XCTAssertEqual(scope.retainedLiveTestCount, 46)
        XCTAssertEqual(scope.aggregateTestCount, 135)
        XCTAssertEqual(
            scope.focusedWholeTestCount + scope.retainedLiveTestCount,
            scope.aggregateTestCount
        )
        XCTAssertEqual(scope.embeddedProvenanceRecordCount, 517)
        XCTAssertEqual(
            scope.soleAuthorityTestClassName,
            "PrimeMonitorHeldLeaseSecureChildContainmentAuthorityTests"
        )
        XCTAssertEqual(
            scope.soleAuthorityTestMethodName,
            "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling"
        )
        XCTAssertEqual(scope.soleAuthorityTestExpectedStartCount, 1)
        XCTAssertEqual(scope.soleAuthorityTestExpectedPassCount, 1)
        XCTAssertEqual(
            scope.addedProofOnlyHistoricalWant,
            repository.baseRevision
        )
        XCTAssertEqual(scope.addedProofOnlyWantCountPerExistingFetch, 1)
        XCTAssertTrue(scope.exactPrimeFetchInvocationCountPerCheckoutRemainsOne)
        XCTAssertTrue(scope.fetchDepthRemainsTwo)
        XCTAssertTrue(scope.workflowJobAndStepTopologyMustRemainUnchanged)
        XCTAssertTrue(scope.retainedLiveCommandsMustRemainByteIdentical)
        XCTAssertTrue(scope.packageManifestMustRemainByteIdentical)
        XCTAssertTrue(scope.packageLockMustRemainByteIdentical)
        XCTAssertTrue(scope.readmeMustRemainByteIdentical)
        XCTAssertTrue(scope.legacyLeasePairMustRemainByteIdentical)
        XCTAssertTrue(scope.a1PairMustRemainByteIdentical)
        XCTAssertTrue(scope.layerABytesMustRemainByteIdentical)
        XCTAssertTrue(scope.bMLXModelCheckpointBytesMustRemainByteIdentical)
        XCTAssertTrue(scope.canaryLauncherMustRemainByteIdentical)
        XCTAssertFalse(scope.implementationIncludedInThisPatch)
        XCTAssertTrue(
            scope.implementationAuthorizedOnlyAfterAuthorityExactMainGreen
        )
        XCTAssertFalse(scope.authorityExactMainGreenObservedAtAuthoring)

        XCTAssertTrue(authorityFalseClaims(authority.authorityCeiling).allSatisfy {
            !$0
        })
        let pin = authority.optionalFixturePINBoundary
        XCTAssertFalse(pin.requestedByThisAuthority)
        XCTAssertTrue(pin.deferred)
        XCTAssertFalse(pin.authorizedByThisAuthority)
        XCTAssertFalse(pin.requiredForA2)
        XCTAssertTrue(pin.distinctAuthorityRequired)
        XCTAssertEqual(
            authority.orderedRequiredSeparateActions,
            [
                "merge_and_close_this_pure_exact5_monitor_held_lease_secure_child_containment_authority",
                "separately_implement_only_the_additive_exact5_closed_nested_capture_composition",
                "close_that_implementation_on_exact_main_without_invoking_new_mechanics",
                "separately_authorize_one_shot_real_lease_and_containment_canary",
                "observe_and_irrevocably_retire_that_canary_before_durable_layer_b",
                "separately_authorize_and_implement_durable_transaction_layer_b",
                "separately_authorize_lease_containment_and_durability_transactional_composition",
                "only_then_review_any_mlx_metal_native300_or_cpp_adapter",
            ]
        )

        XCTAssertNoThrow(try authority.validate())
        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(authority))
        XCTAssertEqual(canonical.count, Authority.canonicalByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Authority.canonicalSHA256
        )
        XCTAssertNoThrow(try authority.validateExactV1())
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 250)
        XCTAssertGreaterThan(dictionaryPaths.count, 15)
        XCTAssertGreaterThan(scalarPaths.count, 180)

        var mutationCount = 0
        var nullCount = 0
        var removalCount = 0
        var looseDecodedDriftCount = 0
        for path in valuePaths {
            let mutationData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue),
                label: "mutated \(pathLabel(path))"
            )
            mutationCount += 1
            if assertLooseDecodedDriftRejects(
                mutationData,
                comparedTo: authority
            ) {
                looseDecodedDriftCount += 1
            }

            let nullData = try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { value in
                        if value is NSNull { return "__null_mutation" }
                        return NSNull()
                    }
                ),
                label: "null \(pathLabel(path))"
            )
            nullCount += 1
            _ = assertLooseDecodedDriftRejects(nullData, comparedTo: authority)

            let removedData = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))"
            )
            removalCount += 1
            _ = assertLooseDecodedDriftRejects(
                removedData,
                comparedTo: authority
            )
        }
        XCTAssertEqual(mutationCount, valuePaths.count)
        XCTAssertEqual(nullCount, valuePaths.count)
        XCTAssertEqual(removalCount, valuePaths.count)
        XCTAssertGreaterThan(looseDecodedDriftCount, 180)

        var reorderedArrayCount = 0
        for path in allArrayPaths(in: object) {
            var didReorder = false
            let reordered = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var array = value as! [Any]
                    guard array.count >= 2 else { return array }
                    for left in 0 ..< array.count {
                        for right in (left + 1) ..< array.count
                        where canonicalJSONFragment(array[left])
                            != canonicalJSONFragment(array[right])
                        {
                            array.swapAt(left, right)
                            didReorder = true
                            return array
                        }
                    }
                    return array
                }
            )
            if didReorder {
                let data = try assertCanonicalRejects(
                    reordered,
                    label: "reordered \(pathLabel(path))"
                )
                XCTAssertTrue(
                    assertLooseDecodedDriftRejects(data, comparedTo: authority)
                )
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 6)

        var unknownFieldCount = 0
        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_monitor_authority_field_\(index)"] = true
                    return dictionary
                }
            )
            let data = try assertCanonicalRejects(
                unknown,
                label: "unknown \(pathLabel(path))"
            )
            XCTAssertEqual(
                try JSONDecoder().decode(Authority.self, from: data),
                authority
            )
            unknownFieldCount += 1
        }
        XCTAssertEqual(unknownFieldCount, dictionaryPaths.count)

        try assertNoncanonicalEncodingsReject(canonical, object: object)

        let oversized = Data(repeating: 0x20, count: 131_073)
        XCTAssertThrowsError(try Authority.decodeCanonical(oversized)) { error in
            XCTAssertEqual(
                error as?
                    PrimeMonitorHeldLeaseSecureChildContainmentAuthorityError,
                .oversizedEncoding
            )
        }
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)

        var label: String {
            switch self {
            case let .key(key): return key
            case let .index(index): return "[\(index)]"
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

    private func allArrayPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allArrayPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(
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
        guard let component = path.first else { return transform(value) }
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
        let remainder = Array(path.dropFirst())
        switch path[0] {
        case let .key(key):
            var object = value as! [String: Any]
            if remainder.isEmpty {
                object.removeValue(forKey: key)
            } else {
                object[key] = removingValue(in: object[key]!, at: remainder)
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(in: array[index], at: remainder)
            }
            return array
        }
    }

    private func canonicalJSONFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes]
        )) ?? Data()
    }

    private func canonicalJSONData(_ value: Any) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: value,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if value is NSNull { return "__was_null_mutation" }
        if let string = value as? String { return string + "__mutation" }
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
        let data = try canonicalJSONData(object)
        XCTAssertThrowsError(
            try Authority.decodeCanonical(data),
            label,
            file: file,
            line: line
        )
        return data
    }

    @discardableResult
    private func assertLooseDecodedDriftRejects(
        _ data: Data,
        comparedTo authority: Authority,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        guard let loose = try? JSONDecoder().decode(Authority.self, from: data),
              loose != authority
        else {
            return false
        }
        XCTAssertThrowsError(try loose.validate(), file: file, line: line)
        XCTAssertThrowsError(try loose.validateExactV1(), file: file, line: line)
        return true
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        var prefixed = Data([0x20])
        prefixed.append(canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(prefixed))

        var suffixed = canonical
        suffixed.append(0x0A)
        XCTAssertThrowsError(try Authority.decodeCanonical(suffixed))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        let slashData = try XCTUnwrap(slashEscaped.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(slashData))

        var reordered = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let opening = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(contentsOf: schemaField, at: reordered.index(after: opening))
        let reorderedData = try XCTUnwrap(reordered.data(using: .utf8))
        XCTAssertNotEqual(reorderedData, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening)
        )
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(duplicateData))
    }

    private func assertFile(
        _ identity: Authority.FileIdentity,
        path: String,
        status: String,
        mode: String,
        blob: String,
        bytes: Int,
        lines: Int,
        sha256: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(identity.path, path, file: file, line: line)
        XCTAssertEqual(identity.gitStatus, status, file: file, line: line)
        XCTAssertEqual(identity.gitMode, mode, file: file, line: line)
        XCTAssertEqual(identity.gitBlob, blob, file: file, line: line)
        XCTAssertEqual(identity.byteCount, bytes, file: file, line: line)
        XCTAssertEqual(identity.lfByteCount, lines, file: file, line: line)
        XCTAssertEqual(identity.sha256, sha256, file: file, line: line)
        XCTAssertFalse(identity.role.isEmpty, file: file, line: line)
        XCTAssertTrue(isLowercaseHex(blob, count: 40), file: file, line: line)
        XCTAssertTrue(isLowercaseHex(sha256, count: 64), file: file, line: line)
    }

    private func assertRun(
        _ run: Authority.WorkflowClosure,
        id: Int,
        number: Int,
        suite: Int,
        event: String,
        ref: String,
        head: String,
        activeJob: Int,
        reviewedJob: Int,
        reviewedConclusion: String,
        reviewedSteps: Int,
        root: Int,
        isolated: [Int],
        focused: Int,
        live: Int,
        aggregate: Int,
        soleTestStarts: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(run.workflowName, "Prime active-root quarantine", file: file, line: line)
        XCTAssertEqual(run.runID, id, file: file, line: line)
        XCTAssertEqual(run.runNumber, number, file: file, line: line)
        XCTAssertEqual(run.runAttempt, 1, file: file, line: line)
        XCTAssertEqual(run.checkSuiteID, suite, file: file, line: line)
        XCTAssertEqual(run.event, event, file: file, line: line)
        XCTAssertEqual(run.ref, ref, file: file, line: line)
        XCTAssertEqual(run.headSHA, head, file: file, line: line)
        XCTAssertEqual(run.status, "completed", file: file, line: line)
        XCTAssertEqual(run.conclusion, "success", file: file, line: line)
        XCTAssertNil(run.previousAttemptURL, file: file, line: line)
        XCTAssertEqual(run.matchingRunCountForHead, 1, file: file, line: line)
        XCTAssertEqual(run.retryCount, 0, file: file, line: line)
        XCTAssertEqual(run.rerunCount, 0, file: file, line: line)
        XCTAssertEqual(run.actionsArtifactCount, 0, file: file, line: line)
        XCTAssertEqual(run.activeRootJobID, activeJob, file: file, line: line)
        XCTAssertEqual(run.activeRootJobConclusion, "success", file: file, line: line)
        XCTAssertEqual(run.reviewedMainJobID, reviewedJob, file: file, line: line)
        XCTAssertEqual(run.reviewedMainJobConclusion, reviewedConclusion, file: file, line: line)
        XCTAssertEqual(run.reviewedMainJobStepCount, reviewedSteps, file: file, line: line)
        XCTAssertEqual(run.activeRootLatinTestCount, 116, file: file, line: line)
        XCTAssertEqual(run.rootTestCount, root, file: file, line: line)
        XCTAssertEqual(run.isolatedGroupTestCounts, isolated, file: file, line: line)
        XCTAssertEqual(run.isolatedTestCount, isolated.reduce(0, +), file: file, line: line)
        XCTAssertEqual(run.focusedWholeTestCount, focused, file: file, line: line)
        XCTAssertEqual(run.retainedLiveTestCount, live, file: file, line: line)
        XCTAssertEqual(run.aggregateTestCount, aggregate, file: file, line: line)
        XCTAssertEqual(run.failureCount, 0, file: file, line: line)
        XCTAssertEqual(run.skipCount, 0, file: file, line: line)
        XCTAssertEqual(run.soleA1TestStartCount, soleTestStarts, file: file, line: line)
        XCTAssertEqual(run.soleA1TestPassCount, soleTestStarts, file: file, line: line)
    }

    private func assertLog(
        _ identity: Authority.ConnectorDecodedUTF8JobLogIdentity,
        jobID: Int,
        bytes: Int,
        lines: Int,
        sha256: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(identity.jobID, jobID, file: file, line: line)
        XCTAssertEqual(
            identity.bindingKind,
            "github_connector_decoded_utf8_job_log_aggregate_identity",
            file: file,
            line: line
        )
        XCTAssertEqual(
            identity.representation,
            "github_connector_decoded_utf8_job_log_aggregate_not_raw_zip",
            file: file,
            line: line
        )
        XCTAssertEqual(identity.byteCount, bytes, file: file, line: line)
        XCTAssertEqual(identity.lfByteCount, lines, file: file, line: line)
        XCTAssertEqual(identity.crByteCount, 0, file: file, line: line)
        XCTAssertEqual(identity.sha256, sha256, file: file, line: line)
        XCTAssertTrue(identity.utf8BOMPresent, file: file, line: line)
        XCTAssertTrue(identity.terminalLFPresent, file: file, line: line)
        XCTAssertTrue(identity.repeatFetchExactlyEqual, file: file, line: line)
        XCTAssertFalse(identity.rawArchiveBytesBound, file: file, line: line)
        XCTAssertFalse(identity.rawArchiveRetained, file: file, line: line)
        XCTAssertTrue(isLowercaseHex(sha256, count: 64), file: file, line: line)
    }

    private func assertExactFive(
        _ paths: [Authority.PathContract],
        source: String,
        test: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(paths.count, 5, file: file, line: line)
        XCTAssertEqual(paths.map(\.ordinal), Array(1 ... 5), file: file, line: line)
        XCTAssertEqual(
            paths.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                source,
                test,
            ],
            file: file,
            line: line
        )
        XCTAssertEqual(
            paths.map(\.gitStatus),
            ["M", "M", "M", "A", "A"],
            file: file,
            line: line
        )
        XCTAssertEqual(
            paths.map(\.gitMode),
            ["100755", "100644", "100644", "100644", "100644"],
            file: file,
            line: line
        )
        XCTAssertEqual(Set(paths.map(\.path)).count, 5, file: file, line: line)
        XCTAssertTrue(paths.allSatisfy { !$0.role.isEmpty }, file: file, line: line)
    }

    private func authorityFalseClaims(
        _ ceiling: Authority.AuthorityCeiling
    ) -> [Bool] {
        [
            ceiling.implementationPerformed,
            ceiling.implementationSourceAdded,
            ceiling.implementationTestAdded,
            ceiling.leaseAcquisitionAuthorized,
            ceiling.leaseAcquisitionPerformed,
            ceiling.leaseReleaseAuthorized,
            ceiling.leaseReleasePerformed,
            ceiling.leaseReacquisitionAuthorized,
            ceiling.leaseFileCreationAuthorized,
            ceiling.leaseFileMutationAuthorized,
            ceiling.descriptorInspectionAuthorized,
            ceiling.descriptorTransferAuthorized,
            ceiling.filesystemWriteAuthorized,
            ceiling.processExecutionAuthorized,
            ceiling.fixtureExecutionAuthorized,
            ceiling.launcherExecutionAuthorized,
            ceiling.canaryExecutionAuthorized,
            ceiling.canaryRetryAuthorized,
            ceiling.canaryRerunAuthorized,
            ceiling.networkAuthorized,
            ceiling.layerAMutationAuthorized,
            ceiling.durableTransactionLayerBAuthorized,
            ceiling.durableEvidenceEstablished,
            ceiling.childLifetimeContinuityEstablished,
            ceiling.physicalMetalReservationEstablished,
            ceiling.mlxDeviceIdentityEstablished,
            ceiling.mlxExecutionAuthorized,
            ceiling.metalExecutionAuthorized,
            ceiling.native300MExecutionAuthorized,
            ceiling.pythonAuthorized,
            ceiling.cppAuthorized,
            ceiling.checkpointAdmissionGranted,
            ceiling.generalTrainingResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private func isLowercaseHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count
            && value.unicodeScalars.allSatisfy {
                ($0.value >= 48 && $0.value <= 57)
                    || ($0.value >= 97 && $0.value <= 102)
            }
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
