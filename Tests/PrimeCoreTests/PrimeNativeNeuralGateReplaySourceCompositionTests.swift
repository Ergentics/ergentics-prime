#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation
@testable import PrimeCore
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateCorrectedFixtureAuthority
import PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
import PrimeNativeNeuralGateLogitSidecarMechanics
import PrimeNativeNeuralGatePromptTargetCrosswalkAuthority
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayCaptureInventory
import PrimeNativeNeuralGateReplayComposition
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateReplaySourceBinding
import PrimeNativeNeuralGateReplaySourceComposition
import PrimeNativeNeuralGateReplayTransport
import PrimeNativeNeuralGateRoleArtifactReferenceAuthority
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority
import XCTest

final class PrimeNativeNeuralGateReplaySourceCompositionTests:
    XCTestCase
{
    private typealias SourceComposition =
        PrimeNativeNeuralGateReplaySourceComposition
    private typealias SourceCompositionError =
        PrimeNativeNeuralGateReplaySourceCompositionError
    private typealias Codec =
        PrimeNativeNeuralGateReplayTransportCodec
    private typealias Decoder =
        PrimeNativeNeuralGateReplayTransportDecoder
    private typealias Capture =
        PrimeNativeNeuralGateReplayCaptureInventory
    private typealias CaptureError =
        PrimeNativeNeuralGateReplayCaptureInventoryError
    private typealias CrosswalkAuthority =
        PrimeNativeNeuralGatePromptTargetCrosswalkAuthority
    private typealias CrosswalkError =
        PrimeNativeNeuralGatePromptTargetCrosswalkAuthorityError
    private typealias DeliveryAuthority =
        PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority
    private typealias DeliveryAuthorityError =
        PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityError
    private typealias RoleArtifactReferenceAuthority =
        PrimeNativeNeuralGateRoleArtifactReferenceAuthority
    private typealias RoleArtifactReferenceAuthorityError =
        PrimeNativeNeuralGateRoleArtifactReferenceAuthorityError

    private static let sourceDerivedCrosswalk =
        Result<PrimeNativeNeuralGateSourceDerivedPromptTargetCrosswalk, Error> {
            try PrimeNativeNeuralGateCorrectedFixtureObservation
                .derivePromptTargetCrosswalk()
        }

    func testFrozenSourceCompositionContractIsConditionalAndNonAuthorizing()
        throws
    {
        let contract =
            PrimeNativeNeuralGateReplaySourceCompositionContract
            .frozenV1
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_descriptor_source_bound_schedule_delivery_v1"
        )
        XCTAssertEqual(
            contract.replayCompositionContractSHA256,
            "75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e"
        )
        XCTAssertTrue(
            contract.descriptorSourceBindingImplemented
        )
        XCTAssertTrue(
            contract
                .sourceBoundLogitValidationImplemented
        )
        XCTAssertTrue(
            contract
                .incrementalPromptScheduleReconstructionImplemented
        )
        XCTAssertTrue(
            contract.asymmetricRoleProjectionImplemented
        )
        XCTAssertTrue(contract.exactSourceBoundJoinImplemented)
        XCTAssertFalse(
            contract.singleSourceCaptureEpochEstablished
        )
        XCTAssertFalse(contract.processDeliveryObserved)
        XCTAssertFalse(
            contract.independentPromptTargetCrosswalkImplemented
        )
        XCTAssertFalse(
            contract
                .promptContentTargetIndependenceEstablished
        )
        XCTAssertFalse(contract.modelExecutionEstablished)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.terminalReceiptAuthorized)
        XCTAssertFalse(contract.scientificAuthorityAuthorized)
        XCTAssertFalse(contract.productAuthorityAuthorized)
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                PrimeNativeNeuralGateReplaySourceCompositionContract
                    .self,
                from: PrimeCanonicalJSON.encode(contract)
            ),
            contract
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(contract)
            ),
            "f3d0a58905065836caaae8c9d03c1b2840b07bcd1a4f0bf35f1ce638c6ac29b5"
        )
    }

    func testDescriptorCapabilitiesComposeByKeyAndRejectRootOrSeedSubstitution()
        throws
    {
        let first = try makeRoot()
        let second = try makeRoot()
        defer {
            try? FileManager.default.removeItem(
                at: first.url
            )
            try? FileManager.default.removeItem(
                at: second.url
            )
        }
        let material = try makeMaterial()
        try publishCompleteMaterial(
            material,
            to: first.root
        )
        try publishPromptMaterial(
            material.promptBundle,
            to: second.root
        )

        let prompt = try
            PrimeNativeNeuralGateReplaySourceBinding
            .bindPromptRecords(artifactRoot: first.root)
        let outerBeforeReplacement = try
            PrimeNativeNeuralGateReplaySourceBinding
            .bindOuterEvaluationRecords(
                artifactRoot: first.root
            )
        let raw = try
            PrimeNativeNeuralGateReplaySourceBinding
            .bindRawExecutionRecords(
                artifactRoot: first.root,
                replicateSeed: material.seed
            )
        let logit = try
            PrimeNativeNeuralGateReplaySourceBinding
            .bindLogitSidecar(
                artifactRoot: first.root,
                replicateSeed: material.seed
            )
        let alternateLogit = try
            PrimeNativeNeuralGateReplaySourceBinding
            .bindLogitSidecar(
                artifactRoot: first.root,
                replicateSeed: material.alternateSeed
            )

        try replaceRecordBundle(
            material.alternateOuterBundle,
            manifestKey: .outerEvaluationManifest,
            globalKey: .outerEvaluationGlobal,
            chunkKey: {
                .outerEvaluationChunk($0)
            },
            in: first
        )
        let outer = try
            PrimeNativeNeuralGateReplaySourceBinding
            .bindOuterEvaluationRecords(
                artifactRoot: first.root
            )
        XCTAssertEqual(
            outerBeforeReplacement.rootIdentity,
            outer.rootIdentity,
            "nested replacement must preserve the top-level root identity in this regression"
        )
        XCTAssertNotEqual(
            outerBeforeReplacement.sourceBindingSHA256,
            outer.sourceBindingSHA256
        )
        XCTAssertEqual(
            outerBeforeReplacement.records[0]
                .expectedCompletionUTF8,
            Data("A".utf8)
        )
        XCTAssertEqual(
            outer.records[0].expectedCompletionUTF8,
            Data("B".utf8)
        )

        let schedule = try SourceComposition
            .makePromptSchedule(promptRecords: prompt)
        XCTAssertEqual(
            schedule.schedule,
            material.schedule
        )
        XCTAssertTrue(schedule.sourceStreamBindingEstablished)
        XCTAssertFalse(
            schedule.durableArtifactOriginEstablished
        )
        XCTAssertFalse(schedule.processDeliveryObserved)
        XCTAssertEqual(
            schedule.rawDelivery.orderedSlots.count,
            18_432
        )
        XCTAssertEqual(
            schedule.outerDelivery.orderedSlots.count,
            18_432
        )
        XCTAssertFalse(
            schedule.rawDelivery.processDeliveryObserved
        )
        XCTAssertFalse(
            schedule.outerDelivery.processDeliveryObserved
        )
        let targetFreePair = try SourceComposition
            .makeTargetFreeScheduleCandidatePair(
                schedule: schedule,
                invocationRole: .probe
            )
        XCTAssertEqual(
            targetFreePair.rawSchedule.orderedSlots.count,
            18_432
        )
        XCTAssertEqual(
            targetFreePair.outerSchedule.orderedSlots.count,
            18_432
        )
        XCTAssertEqual(
            targetFreePair.rawSchedule
                .promptSourceBindingSHA256,
            schedule.promptSourceBindingSHA256
        )
        XCTAssertEqual(
            targetFreePair.outerSchedule
                .promptSourceBindingSHA256,
            schedule.promptSourceBindingSHA256
        )
        XCTAssertEqual(
            targetFreePair.rawSchedule
                .scheduleIdentitySHA256,
            schedule.schedule.scheduleIdentitySHA256
        )
        XCTAssertEqual(
            targetFreePair.outerSchedule
                .scheduleIdentitySHA256,
            schedule.schedule.scheduleIdentitySHA256
        )
        XCTAssertFalse(
            targetFreePair.processDeliveryObserved
        )
        XCTAssertFalse(
            targetFreePair.modelExecutionEstablished
        )
        XCTAssertFalse(
            targetFreePair.mechanicsPassAuthorized
        )
        XCTAssertFalse(
            targetFreePair.terminalReceiptAuthorized
        )
        XCTAssertEqual(
            Set(
                Mirror(
                    reflecting:
                        schedule.rawDelivery.orderedSlots[0]
                ).children.compactMap(\.label)
            ),
            [
                "executionIndex",
                "promptTokenIDs",
                "canonicalPrompt",
                "primeCPI2PromptBindingSHA256",
                "correlationID",
            ]
        )
        XCTAssertEqual(
            Set(
                Mirror(
                    reflecting:
                        schedule.outerDelivery.orderedSlots[0]
                ).children.compactMap(\.label)
            ),
            [
                "executionIndex",
                "correlationID",
            ]
        )
        XCTAssertNotEqual(
            Array(
                outer.records.prefix(32).map(
                    \.executionIndex
                )
            ),
            (0 ..< 32).map(UInt32.init),
            "source ordering must not become a positional join"
        )

        let joined = try SourceComposition.join(
            schedule: schedule,
            outerRecords: outer,
            rawRecords: raw,
            logitSidecar: logit
        )
        XCTAssertEqual(
            joined.joinedReplay.orderedRows.count,
            18_432
        )
        XCTAssertTrue(
            joined.exactSourceCapabilityJoinObserved
        )
        XCTAssertFalse(
            joined.durableArtifactOriginEstablished
        )
        XCTAssertFalse(
            joined.singleSourceCaptureEpochEstablished
        )
        XCTAssertFalse(
            joined
                .independentPromptTargetCrosswalkEstablished
        )
        XCTAssertFalse(
            joined
                .outerExpectedCompletionBindingEstablished
        )
        XCTAssertFalse(
            joined
                .promptContentTargetIndependenceEstablished
        )
        XCTAssertFalse(joined.processDeliveryObserved)
        XCTAssertFalse(joined.modelExecutionEstablished)
        XCTAssertFalse(joined.mechanicsPassAuthorized)
        XCTAssertFalse(joined.terminalReceiptAuthorized)
        XCTAssertFalse(joined.scientificAuthorityAuthorized)
        XCTAssertFalse(joined.productAuthorityAuthorized)

        assertThrows(.replicateSeedMismatch) {
            _ = try SourceComposition.join(
                schedule: schedule,
                outerRecords: outer,
                rawRecords: raw,
                logitSidecar: alternateLogit
            )
        }

        let otherPrompt = try
            PrimeNativeNeuralGateReplaySourceBinding
            .bindPromptRecords(artifactRoot: second.root)
        let otherSchedule = try SourceComposition
            .makePromptSchedule(
                promptRecords: otherPrompt
            )
        assertThrows(.rootIdentityMismatch) {
            _ = try SourceComposition.join(
                schedule: otherSchedule,
                outerRecords: outer,
                rawRecords: raw,
                logitSidecar: logit
            )
        }
    }

    func testSourceCompositionClosureHasNoFilesystemExecutionOrTrapAuthority()
        throws
    {
        let source = try completeSwiftSource(
            target:
                "PrimeNativeNeuralGateReplaySourceComposition"
        )
        XCTAssertTrue(
            source.contains(
                "import PrimeNativeNeuralGateReplayComposition"
            )
        )
        XCTAssertTrue(
            source.contains(
                "import PrimeNativeNeuralGateReplaySourceBinding"
            )
        )
        for forbidden in [
            "import PrimeCore",
            "import Foundation",
            "import Darwin",
            "import Glibc",
            "PrimeNativeCorpusReplayMechanics",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "PrimeNativeNeuralGateReplayCaptureInventory",
            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "PrimeNativeNeuralGatePromptSolver",
            "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            "URLSession",
            "Process(",
            "FileManager",
            "open(",
            "openat(",
            "read(",
            "write(",
            "mmap(",
            "stat(",
            "fstat(",
            "rename(",
            "unlink(",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                forbidden
            )
        }
        for typeName in [
            "PrimeNativeNeuralGateRawScheduleSlot",
            "PrimeNativeNeuralGateOuterScheduleSlot",
        ] {
            let declaration = try XCTUnwrap(
                sourceDeclaration(
                    named: typeName,
                    in: source
                )
            )
            XCTAssertFalse(
                declaration.contains("Codable"),
                typeName
            )
            XCTAssertTrue(
                declaration.contains("fileprivate init("),
                typeName
            )
        }
    }

    func testCaptureAndCrosswalkTargetsPreserveOneWayAuthorityBoundary()
        throws
    {
        let captureSource = try completeSwiftSource(
            target:
                "PrimeNativeNeuralGateReplayCaptureInventory"
        )
        for required in [
            "import PrimeCore",
            "import PrimeNativeNeuralGateReplayArtifactContracts",
            "import PrimeNativeNeuralGateReplaySourceBinding",
        ] {
            XCTAssertTrue(
                captureSource.contains(required),
                required
            )
        }
        for forbidden in [
            "import PrimeNativeCorpusReplayMechanics",
            "import PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "import PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "import PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "import PrimeNativeNeuralGatePromptSolver",
            "import PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            "import ErgenticsPrimeRuntime",
            "import PrimeNativeNeuralGateHistoricalReplayMechanics",
            "Process(",
            "URLSession",
        ] {
            XCTAssertFalse(
                captureSource.contains(forbidden),
                forbidden
            )
        }
        XCTAssertTrue(
            captureSource.contains(
                "public struct PrimeNativeNeuralGateFourSourceCaptureInventory:\n    @unchecked Sendable"
            )
        )
        XCTAssertFalse(
            captureSource.contains(
                "public struct PrimeNativeNeuralGateFourSourceCaptureInventory: Codable"
            )
        )
        XCTAssertTrue(
            captureSource.contains(
                "fileprivate init(\n        rootIdentity:"
            )
        )

        let crosswalkSource = try completeSwiftSource(
            target:
                "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority"
        )
        for required in [
            "import PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "import PrimeNativeNeuralGateReplayCaptureInventory",
            "import PrimeNativeNeuralGateReplaySourceComposition",
        ] {
            XCTAssertTrue(
                crosswalkSource.contains(required),
                required
            )
        }
        for forbidden in [
            "import PrimeNativeNeuralGatePromptSolver",
            "import PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            "import ErgenticsPrimeRuntime",
            "import PrimeNativeNeuralGateHistoricalReplayMechanics",
            "import PrimeNativeNeuralGateHistoricalFixtureWorker",
            "import PrimeNativeNeuralGateReplayProbe",
            "import PrimeNativeNeuralGateReplayVerifier",
            "import PrimeNativeNeuralGateCorrectedRawWorker",
            "Process(",
            "URLSession",
        ] {
            XCTAssertFalse(
                crosswalkSource.contains(forbidden),
                forbidden
            )
        }
        XCTAssertTrue(
            crosswalkSource.contains(
                "public struct PrimeNativeNeuralGateCrosswalkBoundReplay:\n    @unchecked Sendable"
            )
        )
        XCTAssertFalse(
            crosswalkSource.contains(
                "public struct PrimeNativeNeuralGateCrosswalkBoundReplay: Codable"
            )
        )

        let defaultBind = try XCTUnwrap(
            crosswalkSource.range(
                of: "public static func bind(\n        capturedSource:"
            )
        )
        let prederivedComment = try XCTUnwrap(
            crosswalkSource.range(
                of: "/// Accepts only the sealed, non-Codable capability",
                range:
                    defaultBind.upperBound
                        ..< crosswalkSource.endIndex
            )
        )
        let defaultBody = crosswalkSource[
            defaultBind.lowerBound
                ..< prederivedComment.lowerBound
        ]
        let initialRecapture = try XCTUnwrap(
            defaultBody.range(
                of: "validateStillUnchanged()"
            )
        )
        let derivation = try XCTUnwrap(
            defaultBody.range(
                of: "derivePromptTargetCrosswalk()"
            )
        )
        XCTAssertLessThan(
            initialRecapture.lowerBound,
            derivation.lowerBound
        )
    }

    func testHeldRootCaptureAndIndependentCrosswalkRejectTargetMutations()
        throws
    {
        let crosswalk = try Self.sourceDerivedCrosswalk.get()
        let material = try makeAuthorityMaterial(
            crosswalk: crosswalk
        )
        let exact = try makeRoot()
        let swapped = try makeRoot()
        let omitted = try makeRoot()
        defer {
            for root in [exact, swapped, omitted] {
                try? FileManager.default.removeItem(
                    at: root.url
                )
            }
        }

        try publishAuthorityMaterial(
            material,
            outerBundle: material.outerBundle,
            to: exact.root
        )
        let captured = try Capture.capture(
            artifactRoot: exact.root,
            replicateSeed: material.seed
        )
        XCTAssertEqual(captured.inventory.fileEntries.count, 41)
        XCTAssertTrue(
            captured.exactWholeRootNodeClosureEstablished
        )
        XCTAssertTrue(
            captured.singleSourceCaptureEpochEstablished
        )
        XCTAssertTrue(
            captured.durableArtifactOriginEstablished
        )
        XCTAssertFalse(
            captured
                .independentPromptTargetCrosswalkEstablished
        )
        XCTAssertEqual(
            try captured.validateStillUnchanged(),
            captured.inventory
        )

        let probeDelivery = try DeliveryAuthority.bind(
            capturedSource: captured,
            branch: .probe
        )
        let verifierDelivery = try DeliveryAuthority.bind(
            capturedSource: captured,
            branch: .verifier
        )
        XCTAssertEqual(probeDelivery.invocationRole, .probe)
        XCTAssertEqual(
            probeDelivery.rawScheduleOwnerRole,
            .probeSupervisor
        )
        XCTAssertEqual(
            probeDelivery.rawWorkerRole,
            .probeCorrectedRawWorker
        )
        XCTAssertEqual(
            probeDelivery.evaluationWorkerRole,
            .probeCorrectedEvaluationWorker
        )
        XCTAssertEqual(
            verifierDelivery.invocationRole,
            .verifier
        )
        XCTAssertNotEqual(
            probeDelivery.candidatePair.deliveryIdentitySHA256,
            verifierDelivery.candidatePair.deliveryIdentitySHA256
        )
        XCTAssertTrue(
            probeDelivery.retainedCaptureBindingEstablished
        )
        XCTAssertTrue(
            probeDelivery
                .targetFreeScheduleContentBindingEstablished
        )
        XCTAssertTrue(
            probeDelivery.declarativeBranchOwnershipBound
        )
        XCTAssertFalse(probeDelivery.processDeliveryObserved)
        XCTAssertFalse(probeDelivery.workerMaterialized)
        XCTAssertFalse(probeDelivery.modelExecutionEstablished)
        XCTAssertFalse(probeDelivery.evaluationPerformed)
        XCTAssertFalse(probeDelivery.mechanicsPassAuthorized)
        XCTAssertFalse(probeDelivery.terminalReceiptAuthorized)
        XCTAssertNoThrow(
            try probeDelivery.validateSourceStillUnchanged()
        )

        let bound = try CrosswalkAuthority.bind(
            capturedSource: captured,
            sourceDerivedCrosswalk: crosswalk
        )
        XCTAssertEqual(
            bound.sourceBoundReplay.joinedReplay
                .orderedRows.count,
            18_432
        )
        XCTAssertTrue(bound.durableArtifactOriginEstablished)
        XCTAssertTrue(
            bound.correctedFixtureIdentityEstablished
        )
        XCTAssertTrue(
            bound.independentPromptTargetCrosswalkEstablished
        )
        XCTAssertTrue(
            bound.outerExpectedCompletionBindingEstablished
        )
        XCTAssertFalse(
            bound.promptContentTargetIndependenceEstablished
        )
        XCTAssertFalse(bound.processDeliveryObserved)
        XCTAssertFalse(bound.modelExecutionEstablished)
        XCTAssertFalse(bound.mechanicsPassAuthorized)
        XCTAssertFalse(bound.terminalReceiptAuthorized)
        XCTAssertFalse(bound.scientificAuthorityAuthorized)
        XCTAssertFalse(bound.productAuthorityAuthorized)
        XCTAssertEqual(
            try bound.validateSourceStillUnchanged(),
            captured.inventory
        )

        _ = try exact.root.publish(
            Data("unexpected".utf8),
            at: "unexpected.v1.bin",
            purpose: .immutableData
        )
        assertCaptureThrows(.finalRecaptureRejected) {
            _ = try captured.validateStillUnchanged()
        }
        XCTAssertThrowsError(
            try probeDelivery.validateSourceStillUnchanged()
        ) { error in
            XCTAssertEqual(
                error as? DeliveryAuthorityError,
                .retainedSourceChanged
            )
        }
        assertCaptureThrows(.liveInventoryRejected) {
            _ = try Capture.capture(
                artifactRoot: exact.root,
                replicateSeed: material.seed
            )
        }

        try publishAuthorityMaterial(
            material,
            outerBundle: material.swappedOuterBundle,
            to: swapped.root
        )
        let swappedCapture = try Capture.capture(
            artifactRoot: swapped.root,
            replicateSeed: material.seed
        )
        assertCrosswalkThrows(.expectedCompletionMismatch) {
            _ = try CrosswalkAuthority.bind(
                capturedSource: swappedCapture,
                sourceDerivedCrosswalk: crosswalk
            )
        }

        try publishAuthorityMaterial(
            material,
            outerBundle:
                material.terminalByteOmittedOuterBundle,
            to: omitted.root
        )
        let omittedCapture = try Capture.capture(
            artifactRoot: omitted.root,
            replicateSeed: material.seed
        )
        assertCrosswalkThrows(.expectedCompletionMismatch) {
            _ = try CrosswalkAuthority.bind(
                capturedSource: omittedCapture,
                sourceDerivedCrosswalk: crosswalk
            )
        }
    }

    func testRoleArtifactReferenceAuthorityFactorySealsExactStreamAndRejectsDrift()
        throws
    {
        let crosswalk = try Self.sourceDerivedCrosswalk.get()
        let material = try makeAuthorityMaterial(
            crosswalk: crosswalk
        )
        let exact = try makeRoot()
        defer {
            try? FileManager.default.removeItem(at: exact.url)
        }

        try publishAuthorityMaterial(
            material,
            outerBundle: material.outerBundle,
            to: exact.root
        )
        let captured = try Capture.capture(
            artifactRoot: exact.root,
            replicateSeed: material.seed
        )
        let retainedDelivery = try DeliveryAuthority.bind(
            capturedSource: captured,
            branch: .probe
        )
        let pair = retainedDelivery.candidatePair
        let contract =
            PrimeNativeNeuralGateTargetFreeScheduleStreamContract
            .frozenV2
        XCTAssertEqual(
            pair.rawSchedule.orderedSlots.count,
            contract.exactScheduleRowCount
        )
        XCTAssertEqual(
            pair.outerSchedule.orderedSlots.count,
            contract.exactScheduleRowCount
        )

        let header = try
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader(
                expectedCandidatePair: pair
            )
        let headerJSON = try header.canonicalJSON()
        let rawStream = try roleArtifactFramedGlobal(
            pair.rawSchedule.orderedSlots
        )
        let outerStream = try roleArtifactFramedGlobal(
            pair.outerSchedule.orderedSlots
        )

        let successful = try RoleArtifactReferenceAuthority
            .makeCaptureBoundStreamDecoder(
                retainedDelivery: retainedDelivery,
                headerJSON: headerJSON
            )
        try feedRoleArtifactStream(rawStream) {
            try successful.consumeRaw($0)
        }
        try successful.finishRawAtEOF()
        try feedRoleArtifactStream(outerStream) {
            try successful.consumeOuter($0)
        }
        let admission = try successful.finishAtEOF()
        XCTAssertEqual(
            admission.commonReference.captureIdentitySHA256,
            retainedDelivery.captureIdentitySHA256
        )
        XCTAssertEqual(
            admission.commonReference.sourceRootIdentity,
            retainedDelivery.sourceRootIdentity
        )
        XCTAssertEqual(
            admission.branchReference.rawCandidateIdentitySHA256,
            pair.rawSchedule.candidateIdentitySHA256
        )
        XCTAssertEqual(
            admission.branchReference.outerCandidateIdentitySHA256,
            pair.outerSchedule.candidateIdentitySHA256
        )
        XCTAssertEqual(
            admission.branchReference.deliveryIdentitySHA256,
            pair.deliveryIdentitySHA256
        )
        XCTAssertEqual(
            admission.streamAdmission.orderedSlotCount,
            contract.exactScheduleRowCount
        )
        XCTAssertTrue(admission.retainedCaptureBindingEstablished)
        XCTAssertTrue(admission.boundedStreamAdmissionEstablished)
        XCTAssertFalse(admission.descriptorReadAuthorityEstablished)
        XCTAssertFalse(admission.sourcePinningObserved)
        XCTAssertFalse(
            admission.promptContentTargetIndependenceEstablished
        )
        XCTAssertFalse(admission.processDeliveryObserved)
        XCTAssertFalse(admission.workerMaterialized)
        XCTAssertFalse(admission.modelExecutionEstablished)
        XCTAssertFalse(admission.evaluationPerformed)
        XCTAssertFalse(admission.verdictPublicationAuthorized)
        XCTAssertFalse(admission.publicationAuthorized)
        XCTAssertFalse(admission.mechanicsPassAuthorized)
        XCTAssertFalse(admission.terminalReceiptAuthorized)
        XCTAssertFalse(admission.sourceBindingV7Issued)
        XCTAssertFalse(admission.scientificAuthorityAuthorized)
        XCTAssertFalse(admission.productAuthorityAuthorized)
        XCTAssertNoThrow(
            try admission.validateSourceStillUnchanged()
        )

        let drifted = try RoleArtifactReferenceAuthority
            .makeCaptureBoundStreamDecoder(
                retainedDelivery: retainedDelivery,
                headerJSON: headerJSON
            )
        try feedRoleArtifactStream(rawStream) {
            try drifted.consumeRaw($0)
        }
        try drifted.finishRawAtEOF()
        try feedRoleArtifactStream(outerStream) {
            try drifted.consumeOuter($0)
        }

        _ = try exact.root.publish(
            Data("unexpected".utf8),
            at: "unexpected.v1.bin",
            purpose: .immutableData
        )
        XCTAssertThrowsError(try drifted.finishAtEOF()) {
            XCTAssertEqual(
                $0 as? RoleArtifactReferenceAuthorityError,
                .retainedSourceChanged
            )
        }

        let oversizedHeader = Data(
            repeating: 0x20,
            count: contract.maximumHeaderJSONByteCount + 1
        )
        XCTAssertThrowsError(
            try RoleArtifactReferenceAuthority
                .makeCaptureBoundStreamDecoder(
                    retainedDelivery: retainedDelivery,
                    headerJSON: oversizedHeader
                )
        ) {
            XCTAssertEqual(
                $0 as? RoleArtifactReferenceAuthorityError,
                .captureBoundStreamProjectionRejected
            )
        }
    }

    func testFrozenCaptureAndCrosswalkContractsRemainNonAuthorizing()
        throws
    {
        let captureContract =
            PrimeNativeNeuralGateReplayCaptureInventoryContract
            .frozenV1
        XCTAssertNoThrow(try captureContract.validate())
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    captureContract
                )
            ),
            "ae3477c44af1f36a111a6312a88a6b86995ddad231c9225a069173860ed29878"
        )
        XCTAssertTrue(
            captureContract.singleSourceCaptureEpochEstablished
        )
        XCTAssertTrue(
            captureContract.durableArtifactOriginEstablished
        )
        XCTAssertFalse(
            captureContract
                .independentPromptTargetCrosswalkEstablished
        )
        XCTAssertFalse(captureContract.modelExecutionEstablished)
        XCTAssertFalse(captureContract.mechanicsPassAuthorized)
        XCTAssertFalse(captureContract.productAuthorityAuthorized)

        let deliveryContract =
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityContract
            .frozenV1
        XCTAssertNoThrow(try deliveryContract.validate())
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    deliveryContract
                )
            ),
            "b638564791715dcd250c86d3c0faaac7b79b2a26b7dd7a0334ad4772d9afaf88"
        )
        XCTAssertTrue(
            deliveryContract.retainedCaptureBindingImplemented
        )
        XCTAssertTrue(
            deliveryContract
                .targetFreeScheduleContentBindingImplemented
        )
        XCTAssertTrue(
            deliveryContract
                .declarativeBranchOwnershipBindingImplemented
        )
        XCTAssertFalse(deliveryContract.processDeliveryObserved)
        XCTAssertFalse(deliveryContract.workerMaterialized)
        XCTAssertFalse(deliveryContract.modelExecutionEstablished)
        XCTAssertFalse(deliveryContract.evaluationPerformed)
        XCTAssertFalse(deliveryContract.mechanicsPassAuthorized)
        XCTAssertFalse(deliveryContract.terminalReceiptAuthorized)
        XCTAssertFalse(deliveryContract.productAuthorityAuthorized)

        let crosswalkContract =
            PrimeNativeNeuralGatePromptTargetCrosswalkAuthorityContract
            .frozenV1
        XCTAssertNoThrow(try crosswalkContract.validate())
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    crosswalkContract
                )
            ),
            "b4a994635c2d7fafe8f9d47587122beee149533013b69592242bcba33b60ea67"
        )
        XCTAssertTrue(
            crosswalkContract
                .independentPromptTargetCrosswalkEstablished
        )
        XCTAssertTrue(
            crosswalkContract
                .outerExpectedCompletionBindingEstablished
        )
        XCTAssertFalse(
            crosswalkContract
                .promptContentTargetIndependenceEstablished
        )
        XCTAssertFalse(crosswalkContract.processDeliveryObserved)
        XCTAssertFalse(crosswalkContract.modelExecutionEstablished)
        XCTAssertFalse(crosswalkContract.mechanicsPassAuthorized)
        XCTAssertFalse(crosswalkContract.productAuthorityAuthorized)
    }

    private struct Root {
        let url: URL
        let root: PrimeArtifactRoot
    }

    private struct LogitMaterial {
        let dictionary: Data
        let chunks: [Data]
        let manifest: Data
    }

    private struct Material {
        let seed: PrimeNativeNeuralGateArtifactSeed
        let alternateSeed:
            PrimeNativeNeuralGateArtifactSeed
        let schedule:
            PrimeNativeNeuralGatePromptSchedule
        let promptBundle:
            PrimeNativeNeuralGateInvariantBundle
        let outerBundle:
            PrimeNativeNeuralGateInvariantBundle
        let alternateOuterBundle:
            PrimeNativeNeuralGateInvariantBundle
        let rawBundle:
            PrimeNativeNeuralGateInvariantBundle
        let logit: LogitMaterial
        let alternateLogit: LogitMaterial
    }

    private struct AuthorityMaterial {
        let seed: PrimeNativeNeuralGateArtifactSeed
        let promptBundle:
            PrimeNativeNeuralGateInvariantBundle
        let outerBundle:
            PrimeNativeNeuralGateInvariantBundle
        let swappedOuterBundle:
            PrimeNativeNeuralGateInvariantBundle
        let terminalByteOmittedOuterBundle:
            PrimeNativeNeuralGateInvariantBundle
        let rawBundle:
            PrimeNativeNeuralGateInvariantBundle
        let logit: LogitMaterial
    }

    private enum AuthorityMaterialError: Error {
        case duplicatePromptBinding
        case missingPromptBinding
        case noSameLengthDistinctTargets
        case noTerminalByteMutation
    }

    private func makeRoot() throws -> Root {
        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(
                "prime-source-composition-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: false
        )
        XCTAssertEqual(chmod(url.path, mode_t(0o700)), 0)
        return Root(
            url: url,
            root: try PrimeArtifactRoot(
                directoryURL: url
            )
        )
    }

    private func makeMaterial() throws -> Material {
        let seed:
            PrimeNativeNeuralGateArtifactSeed = .seed1618
        let alternateSeed:
            PrimeNativeNeuralGateArtifactSeed = .seed2718
        var promptRecords = [Data]()
        promptRecords.reserveCapacity(18_432)
        for ordinal in 0 ..< 18_432 {
            let prompt = String(
                format: "prime-source-%05d",
                ordinal
            )
            promptRecords.append(
                try Codec.encodePromptOnlyRow(
                    promptTokenIDs:
                        [1] + prompt.utf8.map {
                            UInt16($0) + 256
                        }
                )
            )
        }
        let promptBundle = try
            PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: promptRecords)
        let schedule = try
            PrimeNativeNeuralGateReplayComposition
            .makePromptSchedule(
                canonicalPromptRecords:
                    promptBundle.canonicalRecords
            )
        let correlations =
            schedule.orderedPrompts.map(\.correlationID)
        let outerRecords = try correlations.enumerated().map {
            try Codec.encodeOuterEvaluationRow(
                executionIndex: UInt32($0.offset),
                correlationID: $0.element,
                expectedCompletionUTF8:
                    Data("A".utf8)
                )
        }
        let alternateOuterRecords = try correlations.enumerated().map {
            try Codec.encodeOuterEvaluationRow(
                executionIndex: UInt32($0.offset),
                correlationID: $0.element,
                expectedCompletionUTF8:
                    Data("B".utf8)
            )
        }

        let byteLogits = Self.logits(selecting: 321)
        let eosLogits = Self.logits(
            selecting:
                PrimeNativeNeuralGateCorrectedExecutionPolicy
                .endOfSequenceTokenID
        )
        let decisions = [
            try PrimeNativeNeuralGateCompletionDecision
                .make(
                    ordinal: 1,
                    fullVocabularyLogits: byteLogits
                ),
            try PrimeNativeNeuralGateCompletionDecision
                .make(
                    ordinal: 2,
                    fullVocabularyLogits: eosLogits
                ),
        ]
        let context = try
            PrimeNativeNeuralGateCorrectedReplicateContext(
                evaluationSeed: seed.rawValue
            )
        var rawRecords = [Data]()
        rawRecords.reserveCapacity(18_432)
        for scheduled in schedule.orderedPrompts {
            let input = try
                PrimeNativeNeuralGatePromptOnlyExecutionInput
                .derive(
                    promptText:
                        scheduled.promptRow.canonicalPrompt
                )
            let execution = try
                PrimeNativeNeuralGateRawExecution.validate(
                    replicateContext: context,
                    input: input,
                    decisions: decisions
                )
            rawRecords.append(
                try Codec.encodeRawExecutionReference(
                    replicateSeed: seed,
                    executionIndex:
                        scheduled.executionIndex,
                    primeCPI2PromptBindingSHA256:
                        input.bindingSHA256,
                    traceSHA256:
                        execution.traceSHA256,
                    generatedTokenIDs: [321],
                    termination: .eos
                )
            )
        }
        return Material(
            seed: seed,
            alternateSeed: alternateSeed,
            schedule: schedule,
            promptBundle: promptBundle,
            outerBundle:
                try PrimeNativeNeuralGateInvariantCodec
                .makeBundle(records: outerRecords),
            alternateOuterBundle:
                try PrimeNativeNeuralGateInvariantCodec
                .makeBundle(records: alternateOuterRecords),
            rawBundle:
                try PrimeNativeNeuralGateInvariantCodec
                .makeBundle(records: rawRecords),
            logit: try makeLogitMaterial(
                seed: seed,
                correlations: correlations,
                byteLogits: byteLogits,
                eosLogits: eosLogits
            ),
            alternateLogit: try makeLogitMaterial(
                seed: alternateSeed,
                correlations: correlations,
                byteLogits: byteLogits,
                eosLogits: eosLogits
            )
        )
    }

    private func makeAuthorityMaterial(
        crosswalk:
            PrimeNativeNeuralGateSourceDerivedPromptTargetCrosswalk
    ) throws -> AuthorityMaterial {
        let seed:
            PrimeNativeNeuralGateArtifactSeed = .seed1618
        let promptRecords = try crosswalk.entries.map {
            try Codec.encodePromptOnlyRow(
                promptTokenIDs: $0.promptTokenIDs
            )
        }
        let promptBundle = try
            PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: promptRecords)
        let schedule = try
            PrimeNativeNeuralGateReplayComposition
            .makePromptSchedule(
                canonicalPromptRecords:
                    promptBundle.canonicalRecords
            )

        var entryByPromptBinding = [
            String:
                PrimeNativeNeuralGateSourceDerivedPromptTargetEntry
        ]()
        entryByPromptBinding.reserveCapacity(
            crosswalk.entries.count
        )
        for entry in crosswalk.entries {
            guard entryByPromptBinding.updateValue(
                    entry,
                    forKey: entry.promptBinding.sha256
                  ) == nil
            else {
                throw AuthorityMaterialError
                    .duplicatePromptBinding
            }
        }
        let scheduledEntries = try
            schedule.orderedPrompts.map { scheduled in
                guard let entry = entryByPromptBinding[
                        scheduled
                            .primeCPI2PromptBindingSHA256
                      ]
                else {
                    throw AuthorityMaterialError
                        .missingPromptBinding
                }
                return entry
            }

        let outerRecords = try zip(
            schedule.orderedPrompts,
            scheduledEntries
        ).map { pair in
            try Codec.encodeOuterEvaluationRow(
                executionIndex:
                    pair.0.executionIndex,
                correlationID: pair.0.correlationID,
                expectedCompletionUTF8:
                    pair.1.expectedCompletionUTF8
            )
        }

        var firstByByteCount = [Int: (Int, Data)]()
        var swapPair: (Int, Int)?
        for (index, entry) in scheduledEntries.enumerated() {
            let target = entry.expectedCompletionUTF8
            if let first = firstByByteCount[target.count],
               first.1 != target
            {
                swapPair = (first.0, index)
                break
            }
            firstByByteCount[target.count] = (index, target)
        }
        guard let swapPair else {
            throw AuthorityMaterialError
                .noSameLengthDistinctTargets
        }
        var swappedTargets = scheduledEntries.map(
            \.expectedCompletionUTF8
        )
        swappedTargets.swapAt(swapPair.0, swapPair.1)
        let swappedOuterRecords = try zip(
            schedule.orderedPrompts,
            swappedTargets
        ).map { pair in
            try Codec.encodeOuterEvaluationRow(
                executionIndex:
                    pair.0.executionIndex,
                correlationID: pair.0.correlationID,
                expectedCompletionUTF8: pair.1
            )
        }

        guard let terminalMutationIndex =
                scheduledEntries.firstIndex(where: {
                    !$0.canonicalExpectedCompletion.isEmpty
                })
        else {
            throw AuthorityMaterialError
                .noTerminalByteMutation
        }
        var terminalByteOmittedTargets =
            scheduledEntries.map(\.expectedCompletionUTF8)
        terminalByteOmittedTargets[terminalMutationIndex] =
            Data(
                scheduledEntries[terminalMutationIndex]
                    .canonicalExpectedCompletion
                    .dropLast().utf8
            )
        let terminalByteOmittedOuterRecords = try zip(
            schedule.orderedPrompts,
            terminalByteOmittedTargets
        ).map { pair in
            try Codec.encodeOuterEvaluationRow(
                executionIndex:
                    pair.0.executionIndex,
                correlationID: pair.0.correlationID,
                expectedCompletionUTF8: pair.1
            )
        }

        let byteLogits = Self.logits(selecting: 321)
        let eosLogits = Self.logits(
            selecting:
                PrimeNativeNeuralGateCorrectedExecutionPolicy
                .endOfSequenceTokenID
        )
        let decisions = [
            try PrimeNativeNeuralGateCompletionDecision
                .make(
                    ordinal: 1,
                    fullVocabularyLogits: byteLogits
                ),
            try PrimeNativeNeuralGateCompletionDecision
                .make(
                    ordinal: 2,
                    fullVocabularyLogits: eosLogits
                ),
        ]
        let context = try
            PrimeNativeNeuralGateCorrectedReplicateContext(
                evaluationSeed: seed.rawValue
            )
        var rawRecords = [Data]()
        rawRecords.reserveCapacity(
            schedule.orderedPrompts.count
        )
        for scheduled in schedule.orderedPrompts {
            let input = try
                PrimeNativeNeuralGatePromptOnlyExecutionInput
                .derive(
                    promptText:
                        scheduled.promptRow.canonicalPrompt
                )
            let execution = try
                PrimeNativeNeuralGateRawExecution.validate(
                    replicateContext: context,
                    input: input,
                    decisions: decisions
                )
            rawRecords.append(
                try Codec.encodeRawExecutionReference(
                    replicateSeed: seed,
                    executionIndex:
                        scheduled.executionIndex,
                    primeCPI2PromptBindingSHA256:
                        input.bindingSHA256,
                    traceSHA256:
                        execution.traceSHA256,
                    generatedTokenIDs: [321],
                    termination: .eos
                )
            )
        }
        let correlations = schedule.orderedPrompts.map(
            \.correlationID
        )
        return AuthorityMaterial(
            seed: seed,
            promptBundle: promptBundle,
            outerBundle:
                try PrimeNativeNeuralGateInvariantCodec
                .makeBundle(records: outerRecords),
            swappedOuterBundle:
                try PrimeNativeNeuralGateInvariantCodec
                .makeBundle(records: swappedOuterRecords),
            terminalByteOmittedOuterBundle:
                try PrimeNativeNeuralGateInvariantCodec
                .makeBundle(
                    records:
                        terminalByteOmittedOuterRecords
                ),
            rawBundle:
                try PrimeNativeNeuralGateInvariantCodec
                .makeBundle(records: rawRecords),
            logit: try makeLogitMaterial(
                seed: seed,
                correlations: correlations,
                byteLogits: byteLogits,
                eosLogits: eosLogits
            )
        )
    }

    private func makeLogitMaterial(
        seed: PrimeNativeNeuralGateArtifactSeed,
        correlations: [String],
        byteLogits: [Float],
        eosLogits: [Float]
    ) throws -> LogitMaterial {
        let context = try
            PrimeNativeNeuralGateCorrectedReplicateContext(
                evaluationSeed: seed.rawValue
            )
        let dictionaryData = try
            PrimeNativeNeuralGateLogitSidecarCodec
            .encodeDictionary(
                fullVocabularyLogits: [
                    byteLogits,
                    eosLogits,
                ],
                replicateContext: context
            )
        let dictionary = try
            PrimeNativeNeuralGateLogitSidecarCodec
            .decodeDictionary(
                dictionaryData,
                expectedReplicateContext: context
            )
        let byteIndex = try dictionary
            .dictionaryIndex(
                forFullVocabularyLogits: byteLogits
            )
        let eosIndex = try dictionary
            .dictionaryIndex(
                forFullVocabularyLogits: eosLogits
            )
        let rows = try correlations.enumerated().map {
            try PrimeNativeNeuralGateLogitRowReference(
                rowOrdinal: $0.offset,
                correlationID: $0.element,
                decisions: [
                    try PrimeNativeNeuralGateLogitDecisionReference(
                        ordinal: 1,
                        dictionaryIndex: byteIndex
                    ),
                    try PrimeNativeNeuralGateLogitDecisionReference(
                        ordinal: 2,
                        dictionaryIndex: eosIndex
                    ),
                ]
            )
        }
        var chunks = [Data]()
        chunks.reserveCapacity(18)
        for ordinal in 0 ..< 18 {
            let start = ordinal * 1_024
            let end = start + 1_024
            chunks.append(
                try PrimeNativeNeuralGateLogitSidecarCodec
                .encodeChunk(
                    rows: Array(rows[start ..< end]),
                    chunkOrdinal: ordinal,
                    dictionary: dictionary
                )
            )
        }
        return LogitMaterial(
            dictionary: dictionaryData,
            chunks: chunks,
            manifest:
                try PrimeNativeNeuralGateLogitSidecarCodec
                .encodeManifest(
                    dictionaryData: dictionaryData,
                    chunkData: chunks,
                    expectedReplicateContext: context
                )
        )
    }

    private func publishCompleteMaterial(
        _ material: Material,
        to root: PrimeArtifactRoot
    ) throws {
        try publishPromptMaterial(
            material.promptBundle,
            to: root
        )
        try publishRecordBundle(
            material.outerBundle,
            manifestKey: .outerEvaluationManifest,
            globalKey: .outerEvaluationGlobal,
            chunkKey: {
                .outerEvaluationChunk($0)
            },
            to: root
        )
        try publishRecordBundle(
            material.rawBundle,
            manifestKey:
                .rawExecutionManifest(material.seed),
            globalKey:
                .rawExecutionGlobal(material.seed),
            chunkKey: {
                .rawExecutionChunk(material.seed, $0)
            },
            to: root
        )
        try publishLogitMaterial(
            material.logit,
            seed: material.seed,
            to: root
        )
        try publishLogitMaterial(
            material.alternateLogit,
            seed: material.alternateSeed,
            to: root
        )
    }

    private func publishAuthorityMaterial(
        _ material: AuthorityMaterial,
        outerBundle:
            PrimeNativeNeuralGateInvariantBundle,
        to root: PrimeArtifactRoot
    ) throws {
        try publishPromptMaterial(
            material.promptBundle,
            to: root
        )
        try publishRecordBundle(
            outerBundle,
            manifestKey: .outerEvaluationManifest,
            globalKey: .outerEvaluationGlobal,
            chunkKey: {
                .outerEvaluationChunk($0)
            },
            to: root
        )
        try publishRecordBundle(
            material.rawBundle,
            manifestKey:
                .rawExecutionManifest(material.seed),
            globalKey:
                .rawExecutionGlobal(material.seed),
            chunkKey: {
                .rawExecutionChunk(material.seed, $0)
            },
            to: root
        )
        try publishLogitMaterial(
            material.logit,
            seed: material.seed,
            to: root
        )
    }

    private func roleArtifactFramedGlobal<Slot: Encodable>(
        _ slots: [Slot]
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        var stream = Data("PRIMEIRM1".utf8)
        appendRoleArtifactUInt64(
            UInt64(slots.count),
            to: &stream
        )
        for slot in slots {
            let record = try encoder.encode(slot)
            appendRoleArtifactUInt64(
                UInt64(record.count),
                to: &stream
            )
            stream.append(record)
        }
        return stream
    }

    private func feedRoleArtifactStream(
        _ data: Data,
        blockByteCount: Int = 64 * 1_024,
        consume: (Data) throws -> Void
    ) throws {
        var offset = 0
        while offset < data.count {
            let end = min(data.count, offset + blockByteCount)
            try consume(Data(data[offset ..< end]))
            offset = end
        }
    }

    private func appendRoleArtifactUInt64(
        _ value: UInt64,
        to data: inout Data
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.append(contentsOf: $0)
        }
    }

    private func publishPromptMaterial(
        _ bundle: PrimeNativeNeuralGateInvariantBundle,
        to root: PrimeArtifactRoot
    ) throws {
        try publishRecordBundle(
            bundle,
            manifestKey: .promptOnlyFixtureManifest,
            globalKey: .promptOnlyFixtureGlobal,
            chunkKey: {
                .promptOnlyFixtureChunk($0)
            },
            to: root
        )
    }

    private func publishRecordBundle(
        _ bundle: PrimeNativeNeuralGateInvariantBundle,
        manifestKey:
            PrimeNativeNeuralGateArtifactKey,
        globalKey:
            PrimeNativeNeuralGateArtifactKey,
        chunkKey:
            (UInt32) -> PrimeNativeNeuralGateArtifactKey,
        to root: PrimeArtifactRoot
    ) throws {
        try publish(
            bundle.globalStream,
            key: globalKey,
            to: root
        )
        for (index, chunk) in
            bundle.chunkStreams.enumerated()
        {
            try publish(
                chunk,
                key: chunkKey(UInt32(index)),
                to: root
            )
        }
        try publish(
            try Codec.encodeRecordManifest(
                key: manifestKey,
                invariantManifest: bundle.manifest
            ),
            key: manifestKey,
            to: root
        )
    }

    private func replaceRecordBundle(
        _ bundle: PrimeNativeNeuralGateInvariantBundle,
        manifestKey:
            PrimeNativeNeuralGateArtifactKey,
        globalKey:
            PrimeNativeNeuralGateArtifactKey,
        chunkKey:
            (UInt32) -> PrimeNativeNeuralGateArtifactKey,
        in root: Root
    ) throws {
        let keys =
            [globalKey]
            + bundle.chunkStreams.indices.map {
                chunkKey(UInt32($0))
            }
            + [manifestKey]
        for key in keys {
            let spec = try
                PrimeNativeNeuralGateReplayArtifactOutputContract
                .frozenV4.spec(for: key)
            try FileManager.default.removeItem(
                at: root.url.appendingPathComponent(
                    spec.relativePath
                )
            )
        }
        try publishRecordBundle(
            bundle,
            manifestKey: manifestKey,
            globalKey: globalKey,
            chunkKey: chunkKey,
            to: root.root
        )
    }

    private func publishLogitMaterial(
        _ material: LogitMaterial,
        seed: PrimeNativeNeuralGateArtifactSeed,
        to root: PrimeArtifactRoot
    ) throws {
        try publish(
            material.dictionary,
            key: .logitDictionary(seed),
            to: root
        )
        for (index, chunk) in
            material.chunks.enumerated()
        {
            try publish(
                chunk,
                key: .logitChunk(seed, UInt32(index)),
                to: root
            )
        }
        try publish(
            material.manifest,
            key: .logitManifest(seed),
            to: root
        )
    }

    private func publish(
        _ data: Data,
        key: PrimeNativeNeuralGateArtifactKey,
        to root: PrimeArtifactRoot
    ) throws {
        let spec = try
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4.spec(for: key)
        XCTAssertLessThanOrEqual(
            UInt64(data.count),
            spec.maximumByteCount
        )
        try ensureParents(
            of: spec.relativePath,
            in: root
        )
        _ = try root.publish(
            data,
            at: spec.relativePath,
            purpose: .immutableData
        )
    }

    private func ensureParents(
        of relativePath: String,
        in root: PrimeArtifactRoot
    ) throws {
        let components = relativePath.split(
            separator: "/"
        ).dropLast()
        var current = ""
        for component in components {
            current = current.isEmpty
                ? String(component)
                : "\(current)/\(component)"
            try root.ensurePrivateDirectory(at: current)
        }
    }

    private static func logits(
        selecting tokenID: Int
    ) -> [Float] {
        var values = Array(
            repeating: Float(-10),
            count: 512
        )
        values[tokenID] = 10
        return values
    }

    private func assertThrows(
        _ expected: SourceCompositionError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: () throws -> Void
    ) {
        XCTAssertThrowsError(
            try operation(),
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as? SourceCompositionError,
                expected,
                file: file,
                line: line
            )
        }
    }

    private func assertCaptureThrows(
        _ expected: CaptureError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: () throws -> Void
    ) {
        XCTAssertThrowsError(
            try operation(),
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as? CaptureError,
                expected,
                file: file,
                line: line
            )
        }
    }

    private func assertCrosswalkThrows(
        _ expected: CrosswalkError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: () throws -> Void
    ) {
        XCTAssertThrowsError(
            try operation(),
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as? CrosswalkError,
                expected,
                file: file,
                line: line
            )
        }
    }

    private func completeSwiftSource(
        target: String
    ) throws -> String {
        let directory = repositoryRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent(
                target,
                isDirectory: true
            )
        let entries = try FileManager.default
            .contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            .sorted {
                $0.lastPathComponent
                    < $1.lastPathComponent
            }
        let swiftFiles = entries.filter {
            $0.pathExtension == "swift"
        }
        XCTAssertEqual(
            entries.map(\.lastPathComponent),
            swiftFiles.map(\.lastPathComponent)
        )
        return try swiftFiles.map {
            try String(
                contentsOf: $0,
                encoding: .utf8
            )
        }.joined(separator: "\n")
    }

    private func sourceDeclaration(
        named typeName: String,
        in source: String
    ) -> Substring? {
        let marker = "public struct \(typeName)"
        guard let start = source.range(of: marker)
        else {
            return nil
        }
        let bodyStart = start.lowerBound
        let searchStart = start.upperBound
        let end = source.range(
            of: "\npublic struct ",
            range: searchStart ..< source.endIndex
        )?.lowerBound ?? source.endIndex
        return source[bodyStart ..< end]
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
