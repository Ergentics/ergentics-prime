// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case nonCanonicalEncoding
}

public struct PrimeNativeDecoderTinyDurableMultileafPackageResolvedRepairBaseV1:
    Codable,
    Equatable,
    Sendable
{
    public let repository: String
    public let ref: String
    public let originalAuthorityCanonicalSHA256: String
    public let authorityExactMainMergeRevision: String
    public let authorityExactMainTree: String
    public let orderedParentRevisions: [String]
    public let workflowRunID: Int
    public let workflowRunNumber: Int
    public let checkSuiteID: Int
    public let runAttempt: Int
    public let activeJobID: Int
    public let reviewedJobID: Int
    public let exactHeadPushRunCount: Int
    public let rerunCount: Int
    public let artifactCount: Int
    public let terminalConclusion: String
    public let rootTestCount: Int
    public let metalTestCount: Int
    public let runtimeReceiptCount: Int
    public let tokenizerReceiptCount: Int
    public let stage4LauncherInvocationCount: Int
    public let authorityExactMainClosureEstablished: Bool
}

public struct PrimeNativeDecoderTinyDurableMultileafPackageResolvedLockV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let mode: String
    public let gitBlob: String
    public let byteCount: Int
    public let sha256: String
    public let formatVersion: Int
    public let originHash: String
    public let orderedPinIdentities: [String]
    public let mlxLocation: String
    public let mlxRevision: String
    public let swiftNumericsLocation: String
    public let swiftNumericsRevision: String
    public let swiftNumericsVersion: String
}

public struct PrimeNativeDecoderTinyDurableMultileafPackageResolutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let manifestMutation: String
    public let dependencyEdgeKind: String
    public let resolutionCommand: String
    public let successfulResolutionCount: Int
    public let beforeLockGitBlob: String
    public let afterLockGitBlob: String
    public let beforeLockSHA256: String
    public let afterLockSHA256: String
    public let pinsChanged: Bool
    public let originHashChanged: Bool
    public let lockBytesChanged: Bool
    public let externalDependencyGraphChanged: Bool
    public let packageResolvedMutationMechanicallyRequired: Bool
    public let fabricatedLockMutationAuthorized: Bool
}

public struct PrimeNativeDecoderTinyDurableMultileafPackageResolvedRepairV1:
    Codable,
    Equatable,
    Sendable
{
    public let incorrectOriginalMechanicsPaths: [String]
    public let exactRepairedMechanicsPaths: [String]
    public let removedMechanicsPath: String
    public let originalMechanicsPathCount: Int
    public let repairedMechanicsPathCount: Int
    public let exactRepairAuthorityMergePaths: [String]
    public let repairAuthorityRootTestCount: Int
    public let implementationFocusedWholeTestCount: Int
    public let predecessorMetalTestCount: Int
    public let predecessorRuntimeTestCount: Int
    public let predecessorTokenizerTestCount: Int
    public let preStage4TotalTestCount: Int
    public let stage4DirectXCTestCount: Int
    public let totalTestCount: Int
    public let packageManifestMutationAuthorized: Bool
    public let packageResolvedMutationAuthorized: Bool
    public let packageResolvedPreservationRequired: Bool
    public let checkpointSourceAdditionAuthorized: Bool
    public let trainingBridgeMutationAuthorized: Bool
    public let stage4TestAdditionAuthorized: Bool
    public let newStage4LauncherAuthorized: Bool
    public let gateWorkflowAndProvenanceMutationAuthorized: Bool
    public let validationManifestOrLockMutationAuthorized: Bool
    public let originalAuthorityMutationAuthorized: Bool
    public let oneMechanicsSuccessorAfterGreenRepairClosureAuthorized: Bool
}

public struct PrimeNativeDecoderTinyDurableMultileafPackageResolvedRepairCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let authorityOnlyNoMechanicsExecutionEvidence: Bool
    public let mechanicsFaultMatrixPreserved: Bool
    public let fourLeafPublicationOrderPreserved: Bool
    public let finalCommitPublishedLastPreserved: Bool
    public let partialWriteQuarantinePreserved: Bool
    public let externalExactCommitBindingPreserved: Bool
    public let tinyWeightsFixtureIsNotNative300MExactV2: Bool
    public let native300MExactV2CompositionDeferred: Bool
    public let additionalExecutionOrRerunAuthorized: Bool
    public let retainedArtifactAuthorized: Bool
    public let artifactUploadAuthorized: Bool
    public let checkpointAdmissionGranted: Bool
    public let publicV2CodecWideningAuthorized: Bool
    public let metalDeterminismEstablished: Bool
    public let stage5Authorized: Bool
    public let native300MTrainingAuthorized: Bool
    public let generalTrainingResumeEstablished: Bool
    public let productOrPublicationAuthorized: Bool
    public let terminalMechanicsOutcomeObservationRequired: Bool
}

/// Pure append-only repair for an impossible Package.resolved scope claim.
/// Canonical SwiftPM resolution proves an internal target edge leaves the root
/// lock byte-identical, so the separately scoped mechanics successor must
/// preserve that lock rather than manufacture a meaningless mutation.
public struct PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public static let canonicalSHA256 =
        "6a6dfc7b30319f9ccc1d17c2f08282c266962cd500d47696cbb42b4b1b0ff826"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "ergentics_prime_native_decoder_tiny_durable_multileaf_commit_fault_injection_package_resolved_scope_repair_authority_v1",
        base: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            originalAuthorityCanonicalSHA256:
                "0b167685f0cc10cbf5d705d6cf67b72b54555dfa52b9f4aaebd00613e057b031",
            authorityExactMainMergeRevision:
                "1cfab327cf82f2c109d1b330d6142efe8647f141",
            authorityExactMainTree:
                "2ec146f5d6604b86ebd5eef90484a56aa6be18f1",
            orderedParentRevisions: [
                "5cadcfb915356984f1d6496d7a255725937f9007",
                "86f7fa0aa4e319fafa0c33d226493d8e8c0f2730",
            ],
            workflowRunID: 31_712_088_411,
            workflowRunNumber: 93,
            checkSuiteID: 86_029_527_347,
            runAttempt: 1,
            activeJobID: 94_487_374_306,
            reviewedJobID: 94_488_415_461,
            exactHeadPushRunCount: 1,
            rerunCount: 0,
            artifactCount: 0,
            terminalConclusion: "success",
            rootTestCount: 49,
            metalTestCount: 44,
            runtimeReceiptCount: 1,
            tokenizerReceiptCount: 1,
            stage4LauncherInvocationCount: 0,
            authorityExactMainClosureEstablished: true),
        lock: .init(
            path: "Package.resolved",
            mode: "100644",
            gitBlob: "14d804bb4291720477240c27e24de6fbdc876b3b",
            byteCount: 645,
            sha256:
                "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375",
            formatVersion: 3,
            originHash:
                "bc889436fb167cc206aa87cb079da4888a7fe95e517eb7cf63cbf44b35dc27c2",
            orderedPinIdentities: [
                "ergentics-mlx-swift",
                "swift-numerics",
            ],
            mlxLocation:
                "https://github.com/Ergentics/ergentics-mlx-swift",
            mlxRevision:
                "d37885a278f1c37484a94d0f401a418735e66519",
            swiftNumericsLocation:
                "https://github.com/apple/swift-numerics",
            swiftNumericsRevision:
                "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
            swiftNumericsVersion: "1.1.1"),
        resolution: .init(
            manifestMutation:
                "add_internal_PrimeNativeDecoderCheckpoint_target_dependency_to_PrimeNativeDecoderTraining",
            dependencyEdgeKind:
                "internal_root_package_target_dependency_only",
            resolutionCommand:
                "swift package resolve --force-resolved-versions",
            successfulResolutionCount: 2,
            beforeLockGitBlob:
                "14d804bb4291720477240c27e24de6fbdc876b3b",
            afterLockGitBlob:
                "14d804bb4291720477240c27e24de6fbdc876b3b",
            beforeLockSHA256:
                "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375",
            afterLockSHA256:
                "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375",
            pinsChanged: false,
            originHashChanged: false,
            lockBytesChanged: false,
            externalDependencyGraphChanged: false,
            packageResolvedMutationMechanicallyRequired: false,
            fabricatedLockMutationAuthorized: false),
        repair: .init(
            incorrectOriginalMechanicsPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage4-tiny-durable-multileaf.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Package.resolved",
                "Package.swift",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderTrajectoryCheckpointV1.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests.swift",
            ],
            exactRepairedMechanicsPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage4-tiny-durable-multileaf.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Package.swift",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderTrajectoryCheckpointV1.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests.swift",
            ],
            removedMechanicsPath: "Package.resolved",
            originalMechanicsPathCount: 9,
            repairedMechanicsPathCount: 8,
            exactRepairAuthorityMergePaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityTests.swift",
            ],
            repairAuthorityRootTestCount: 50,
            implementationFocusedWholeTestCount: 56,
            predecessorMetalTestCount: 44,
            predecessorRuntimeTestCount: 1,
            predecessorTokenizerTestCount: 1,
            preStage4TotalTestCount: 102,
            stage4DirectXCTestCount: 1,
            totalTestCount: 103,
            packageManifestMutationAuthorized: true,
            packageResolvedMutationAuthorized: false,
            packageResolvedPreservationRequired: true,
            checkpointSourceAdditionAuthorized: true,
            trainingBridgeMutationAuthorized: true,
            stage4TestAdditionAuthorized: true,
            newStage4LauncherAuthorized: true,
            gateWorkflowAndProvenanceMutationAuthorized: true,
            validationManifestOrLockMutationAuthorized: false,
            originalAuthorityMutationAuthorized: false,
            oneMechanicsSuccessorAfterGreenRepairClosureAuthorized: true),
        ceiling: .init(
            authorityOnlyNoMechanicsExecutionEvidence: true,
            mechanicsFaultMatrixPreserved: true,
            fourLeafPublicationOrderPreserved: true,
            finalCommitPublishedLastPreserved: true,
            partialWriteQuarantinePreserved: true,
            externalExactCommitBindingPreserved: true,
            tinyWeightsFixtureIsNotNative300MExactV2: true,
            native300MExactV2CompositionDeferred: true,
            additionalExecutionOrRerunAuthorized: false,
            retainedArtifactAuthorized: false,
            artifactUploadAuthorized: false,
            checkpointAdmissionGranted: false,
            publicV2CodecWideningAuthorized: false,
            metalDeterminismEstablished: false,
            stage5Authorized: false,
            native300MTrainingAuthorized: false,
            generalTrainingResumeEstablished: false,
            productOrPublicationAuthorized: false,
            terminalMechanicsOutcomeObservationRequired: true),
        status:
            "AUTHORIZED_stage4_mechanics_scope_repair_preserve_byte_identical_package_resolved_substitute_exact_eight_paths_one_successor_after_green_repair_closure_no_rerun_retention_admission_stage5_native300m_or_downstream_authority")

    public let schemaVersion: Int
    public let authorityID: String
    public let base:
        PrimeNativeDecoderTinyDurableMultileafPackageResolvedRepairBaseV1
    public let lock:
        PrimeNativeDecoderTinyDurableMultileafPackageResolvedLockV1
    public let resolution:
        PrimeNativeDecoderTinyDurableMultileafPackageResolutionObservationV1
    public let repair:
        PrimeNativeDecoderTinyDurableMultileafPackageResolvedRepairV1
    public let ceiling:
        PrimeNativeDecoderTinyDurableMultileafPackageResolvedRepairCeilingV1
    public let status: String

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityError
                .contractDrift
        }
        let original =
            PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityV1
                .frozenV1
        let falseCeilings = [
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.checkpointAdmissionGranted,
            ceiling.publicV2CodecWideningAuthorized,
            ceiling.metalDeterminismEstablished,
            ceiling.stage5Authorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.generalTrainingResumeEstablished,
            ceiling.productOrPublicationAuthorized,
        ]
        guard schemaVersion == 1,
              authorityID
                == "ergentics_prime_native_decoder_tiny_durable_multileaf_commit_fault_injection_package_resolved_scope_repair_authority_v1",
              base.originalAuthorityCanonicalSHA256
                == PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityV1
                    .canonicalSHA256,
              PrimeSHA256.hexDigest(of: try original.canonicalData())
                == base.originalAuthorityCanonicalSHA256,
              base.orderedParentRevisions.count == 2,
              base.runAttempt == 1,
              base.exactHeadPushRunCount == 1,
              base.rerunCount == 0,
              base.artifactCount == 0,
              base.terminalConclusion == "success",
              base.rootTestCount == 49,
              base.metalTestCount == 44,
              base.runtimeReceiptCount == 1,
              base.tokenizerReceiptCount == 1,
              base.stage4LauncherInvocationCount == 0,
              base.authorityExactMainClosureEstablished,
              lock.path == "Package.resolved",
              lock.mode == "100644",
              lock.byteCount == 645,
              lock.formatVersion == 3,
              lock.orderedPinIdentities
                == ["ergentics-mlx-swift", "swift-numerics"],
              resolution.successfulResolutionCount == 2,
              resolution.beforeLockGitBlob == lock.gitBlob,
              resolution.afterLockGitBlob == lock.gitBlob,
              resolution.beforeLockSHA256 == lock.sha256,
              resolution.afterLockSHA256 == lock.sha256,
              !resolution.pinsChanged,
              !resolution.originHashChanged,
              !resolution.lockBytesChanged,
              !resolution.externalDependencyGraphChanged,
              !resolution.packageResolvedMutationMechanicallyRequired,
              !resolution.fabricatedLockMutationAuthorized,
              repair.incorrectOriginalMechanicsPaths
                == repair.incorrectOriginalMechanicsPaths.sorted(),
              Set(repair.incorrectOriginalMechanicsPaths).count == 9,
              repair.exactRepairedMechanicsPaths
                == repair.exactRepairedMechanicsPaths.sorted(),
              Set(repair.exactRepairedMechanicsPaths).count == 8,
              repair.incorrectOriginalMechanicsPaths.filter({
                  $0 != repair.removedMechanicsPath
              }) == repair.exactRepairedMechanicsPaths,
              repair.removedMechanicsPath == lock.path,
              repair.originalMechanicsPathCount == 9,
              repair.repairedMechanicsPathCount == 8,
              repair.exactRepairAuthorityMergePaths
                == repair.exactRepairAuthorityMergePaths.sorted(),
              Set(repair.exactRepairAuthorityMergePaths).count == 5,
              repair.repairAuthorityRootTestCount == 50,
              repair.implementationFocusedWholeTestCount == 56,
              repair.predecessorMetalTestCount == 44,
              repair.predecessorRuntimeTestCount == 1,
              repair.predecessorTokenizerTestCount == 1,
              repair.preStage4TotalTestCount == 102,
              repair.stage4DirectXCTestCount == 1,
              repair.totalTestCount == 103,
              repair.packageManifestMutationAuthorized,
              !repair.packageResolvedMutationAuthorized,
              repair.packageResolvedPreservationRequired,
              repair.checkpointSourceAdditionAuthorized,
              repair.trainingBridgeMutationAuthorized,
              repair.stage4TestAdditionAuthorized,
              repair.newStage4LauncherAuthorized,
              repair.gateWorkflowAndProvenanceMutationAuthorized,
              !repair.validationManifestOrLockMutationAuthorized,
              !repair.originalAuthorityMutationAuthorized,
              repair.oneMechanicsSuccessorAfterGreenRepairClosureAuthorized,
              ceiling.authorityOnlyNoMechanicsExecutionEvidence,
              ceiling.mechanicsFaultMatrixPreserved,
              ceiling.fourLeafPublicationOrderPreserved,
              ceiling.finalCommitPublishedLastPreserved,
              ceiling.partialWriteQuarantinePreserved,
              ceiling.externalExactCommitBindingPreserved,
              ceiling.tinyWeightsFixtureIsNotNative300MExactV2,
              ceiling.native300MExactV2CompositionDeferred,
              falseCeilings.allSatisfy({ !$0 }),
              ceiling.terminalMechanicsOutcomeObservationRequired,
              status
                == "AUTHORIZED_stage4_mechanics_scope_repair_preserve_byte_identical_package_resolved_substitute_exact_eight_paths_one_successor_after_green_repair_closure_no_rerun_retention_admission_stage5_native300m_or_downstream_authority"
        else {
            throw PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityError
                .contractDrift
        }
    }

    public func canonicalData() throws -> Data {
        try validateExactV1()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try value.canonicalData() == data else {
            throw PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityError
                .nonCanonicalEncoding
        }
        return value
    }
}
