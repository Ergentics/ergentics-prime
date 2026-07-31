#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation
@testable import PrimeCore
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateLogitSidecarMechanics
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayComposition
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateReplaySourceBinding
import PrimeNativeNeuralGateReplaySourceComposition
import PrimeNativeNeuralGateReplayTransport
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
