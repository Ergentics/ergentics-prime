import Foundation
@testable import PrimeCore
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateLogitSidecarMechanics
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayComposition
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateReplayTransport
import XCTest

final class PrimeNativeNeuralGateReplayCompositionTests:
    XCTestCase
{
    private typealias Composition =
        PrimeNativeNeuralGateReplayComposition
    private typealias Error =
        PrimeNativeNeuralGateReplayCompositionError
    private typealias Codec =
        PrimeNativeNeuralGateReplayTransportCodec
    private typealias Decoder =
        PrimeNativeNeuralGateReplayTransportDecoder

    func testFrozenCompositionContractIsExactAndNonAuthorizing()
        throws
    {
        let contract =
            PrimeNativeNeuralGateReplayCompositionContract
            .frozenV1
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.artifactOutputContractSHA256,
            "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1"
        )
        XCTAssertEqual(
            contract.invariantCodecID,
            PrimeNativeNeuralGateInvariantCodec
                .serializationContractID
        )
        XCTAssertEqual(
            contract.logitSidecarCodecID,
            PrimeNativeNeuralGateLogitSidecarPolicy
                .codecID
        )
        XCTAssertEqual(
            contract.scheduleIdentityMagic,
            "PRIMESCH1"
        )
        XCTAssertEqual(
            contract.scheduleIdentitySerializationID,
            "primesch1_then_uint32_big_endian_record_count_then_raw_prompt_global_stream_sha256_v1"
        )
        XCTAssertEqual(
            contract.correlationIdentityMagic,
            "PRIMECOR1"
        )
        XCTAssertEqual(
            contract.correlationIdentitySerializationID,
            "primecor1_then_uint32_big_endian_execution_index_then_raw_primecpi2_prompt_binding_sha256_v1"
        )
        XCTAssertEqual(contract.exactRowCount, 18_432)
        XCTAssertEqual(
            contract.admittedReplicateSeeds,
            [1_618, 2_718, 3_141]
        )
        XCTAssertTrue(contract.canonicalCodecImplemented)
        XCTAssertTrue(
            contract.strictPromptScheduleImplemented
        )
        XCTAssertTrue(
            contract.exactCrossArtifactJoinImplemented
        )
        XCTAssertTrue(
            contract.correctedTraceRecomputationImplemented
        )
        XCTAssertFalse(
            contract
                .correlationScheduleCapabilityDeliveryImplemented
        )
        XCTAssertFalse(
            contract
                .independentPromptTargetCrosswalkImplemented
        )
        XCTAssertFalse(contract.descriptorStreamingImplemented)
        XCTAssertFalse(
            contract.durableArtifactOriginEstablished
        )
        XCTAssertFalse(contract.publicationAuthorized)
        XCTAssertFalse(contract.scientificAuthorityAuthorized)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.terminalReceiptAuthorized)
        XCTAssertFalse(contract.productAuthorityAuthorized)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(contract)
            ),
            "75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e"
        )
    }

    func testPromptScheduleUsesStrictCanonicalRecordOrdinals()
        throws
    {
        let fixture = try Self.fixtureResult.get()
        let schedule = fixture.schedule
        XCTAssertEqual(
            schedule.orderedPrompts.count,
            18_432
        )
        XCTAssertEqual(
            schedule.orderedPrompts.map(\.executionIndex),
            (0 ..< 18_432).map(UInt32.init)
        )
        XCTAssertTrue(
            schedule.strictCanonicalRecordOrderObserved
        )
        XCTAssertTrue(
            schedule
                .exactInMemoryScheduleIndexCoverageObserved
        )
        XCTAssertFalse(
            schedule.correctedFixtureIdentityEstablished
        )
        XCTAssertFalse(
            schedule.sourceStreamBindingEstablished
        )
        XCTAssertFalse(schedule.mechanicsPassAuthorized)
        XCTAssertEqual(
            schedule.promptGlobalStreamSHA256,
            "de88005255409efa2e6a03f7f2158121fc2432a6d0dd58bd934c9112f010bdf8"
        )
        XCTAssertEqual(
            schedule.scheduleIdentitySHA256,
            "f7bbbd578b6bc66497cf54c34eac846aa7dc3a2afc548fed10978bfd3974c188"
        )
        XCTAssertEqual(
            Set(
                schedule.orderedPrompts
                    .map(
                        \.primeCPI2PromptBindingSHA256
                    )
            ).count,
            18_432
        )
        XCTAssertEqual(
            schedule.orderedPrompts[0].correlationID,
            "cabad0574ae8d7949ddc2ab00ab56b5bcd032e9d436ae0e27760e2db8cd82338"
        )
        XCTAssertEqual(
            schedule.orderedPrompts[18_431]
                .correlationID,
            "288fc7f787e9a1a63e0e614bf103ef99bb6656f77c3d0f2c64912e889b667a6f"
        )

        assertThrows(
            .invalidPromptRecordCount(
                expected: 18_432,
                observed: 18_431
            )
        ) {
            _ = try Composition.makePromptSchedule(
                canonicalPromptRecords:
                    Array(
                        fixture
                        .canonicalPromptRecords
                        .dropLast()
                    )
            )
        }

        var duplicate = fixture.canonicalPromptRecords
        duplicate[1] = duplicate[0]
        assertThrows(.duplicatePromptRecord(index: 1)) {
            _ = try Composition.makePromptSchedule(
                canonicalPromptRecords: duplicate
            )
        }

        var swapped = fixture.canonicalPromptRecords
        swapped.swapAt(0, 1)
        assertThrows(
            .noncanonicalPromptRecordOrder(index: 1)
        ) {
            _ = try Composition.makePromptSchedule(
                canonicalPromptRecords: swapped
            )
        }
    }

    func testExactKeyedJoinRecomputesPromptAndTraceBindings()
        throws
    {
        let fixture = try Self.fixtureResult.get()
        let joined = try Composition.join(
            schedule: fixture.schedule,
            replicateSeed: fixture.seed,
            outerRows: Array(
                fixture.outerRows.reversed()
            ),
            rawRows: Array(fixture.rawRows.reversed()),
            validatedLogitSidecar: fixture.sidecar
        )
        XCTAssertEqual(joined.replicateSeed, fixture.seed)
        XCTAssertEqual(joined.orderedRows.count, 18_432)
        XCTAssertEqual(
            joined.orderedRows.map {
                $0.scheduledPrompt.executionIndex
            },
            (0 ..< 18_432).map(UInt32.init)
        )
        XCTAssertTrue(
            joined.exactInMemoryJoinIndexCoverageObserved
        )
        XCTAssertFalse(
            joined.correctedFixtureIdentityEstablished
        )
        XCTAssertTrue(joined.promptDigestJoinObserved)
        XCTAssertTrue(joined.outerCorrelationJoinObserved)
        XCTAssertTrue(joined.correctedTraceJoinObserved)
        XCTAssertFalse(
            joined
                .outerExpectedCompletionBindingEstablished
        )
        XCTAssertFalse(
            joined.durableArtifactOriginEstablished
        )
        XCTAssertFalse(
            joined
                .promptContentTargetIndependenceEstablished
        )
        XCTAssertFalse(joined.modelExecutionEstablished)
        XCTAssertFalse(joined.mechanicsPassAuthorized)

        var duplicateOuter = fixture.outerRows
        duplicateOuter[18_431] = duplicateOuter[0]
        assertThrows(
            .duplicateOuterExecutionIndex(0)
        ) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: duplicateOuter,
                rawRows: fixture.rawRows,
                validatedLogitSidecar:
                    fixture.sidecar
            )
        }

        assertThrows(
            .invalidOuterRowCount(
                expected: 18_432,
                observed: 18_431
            )
        ) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: Array(
                    fixture.outerRows.dropLast()
                ),
                rawRows: fixture.rawRows,
                validatedLogitSidecar:
                    fixture.sidecar
            )
        }

        var duplicateCorrelation = fixture.outerRows
        duplicateCorrelation[18_431] = try
            Self.decodeOuter(
                executionIndex: 18_431,
                correlationID:
                    fixture.outerRows[0]
                    .correlationID
            )
        assertThrows(
            .duplicateOuterCorrelationID(index: 18_431)
        ) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: duplicateCorrelation,
                rawRows: fixture.rawRows,
                validatedLogitSidecar:
                    fixture.sidecar
            )
        }

        var wrongOuterCorrelation = fixture.outerRows
        wrongOuterCorrelation[0] = try
            Self.decodeOuter(
                executionIndex: 0,
                correlationID:
                    Self.digest("f")
            )
        assertThrows(.outerCorrelationMismatch(index: 0)) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: wrongOuterCorrelation,
                rawRows: fixture.rawRows,
                validatedLogitSidecar:
                    fixture.sidecar
            )
        }

        var wrongPromptDigest = fixture.rawRows
        wrongPromptDigest[0] = try Self.decodeRaw(
            seed: fixture.seed,
            scheduled:
                fixture.schedule.orderedPrompts[0],
            primeCPI2PromptBindingSHA256:
                Self.digest("f"),
            traceSHA256:
                fixture.rawRows[0].traceSHA256,
            generatedTokenIDs: [321]
        )
        assertThrows(.rawPromptDigestMismatch(index: 0)) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: wrongPromptDigest,
                validatedLogitSidecar:
                    fixture.sidecar
            )
        }

        var recordDigestSubstitution = fixture.rawRows
        let firstScheduledPrompt =
            fixture.schedule.orderedPrompts[0]
        recordDigestSubstitution[0] = try Self.decodeRaw(
            seed: fixture.seed,
            scheduled: firstScheduledPrompt,
            primeCPI2PromptBindingSHA256:
                firstScheduledPrompt
                .canonicalPromptRecordSHA256,
            traceSHA256:
                fixture.rawRows[0].traceSHA256,
            generatedTokenIDs: [321]
        )
        assertThrows(.rawPromptDigestMismatch(index: 0)) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: recordDigestSubstitution,
                validatedLogitSidecar:
                    fixture.sidecar
            )
        }

        var wrongTrace = fixture.rawRows
        wrongTrace[0] = try Self.decodeRaw(
            seed: fixture.seed,
            scheduled:
                fixture.schedule.orderedPrompts[0],
            primeCPI2PromptBindingSHA256:
                fixture.rawRows[0].promptSHA256,
            traceSHA256: Self.digest("f"),
            generatedTokenIDs: [321]
        )
        assertThrows(.traceDigestMismatch(index: 0)) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: wrongTrace,
                validatedLogitSidecar:
                    fixture.sidecar
            )
        }

        var wrongGenerated = fixture.rawRows
        wrongGenerated[0] = try Self.decodeRaw(
            seed: fixture.seed,
            scheduled:
                fixture.schedule.orderedPrompts[0],
            primeCPI2PromptBindingSHA256:
                fixture.rawRows[0].promptSHA256,
            traceSHA256:
                fixture.rawRows[0].traceSHA256,
            generatedTokenIDs: [322]
        )
        assertThrows(.generatedTokenMismatch(index: 0)) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: wrongGenerated,
                validatedLogitSidecar:
                    fixture.sidecar
            )
        }

        var crossSeed = fixture.rawRows
        crossSeed[0] = try Self.decodeRaw(
            seed: .seed2718,
            scheduled:
                fixture.schedule.orderedPrompts[0],
            primeCPI2PromptBindingSHA256:
                fixture.rawRows[0].promptSHA256,
            traceSHA256:
                fixture.rawRows[0].traceSHA256,
            generatedTokenIDs: [321]
        )
        assertThrows(
            .rawReplicateSeedMismatch(
                expected: 1_618,
                observed: 2_718
            )
        ) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: crossSeed,
                validatedLogitSidecar:
                    fixture.sidecar
            )
        }

        var duplicateRaw = fixture.rawRows
        duplicateRaw[18_431] = duplicateRaw[0]
        assertThrows(
            .duplicateRawExecutionIndex(0)
        ) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: duplicateRaw,
                validatedLogitSidecar:
                    fixture.sidecar
            )
        }

        assertThrows(
            .invalidRawRowCount(
                expected: 18_432,
                observed: 18_431
            )
        ) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: Array(
                    fixture.rawRows.dropLast()
                ),
                validatedLogitSidecar:
                    fixture.sidecar
            )
        }

        var fixedCapDecisionCounts = Array(
            repeating: 2,
            count: 18_432
        )
        fixedCapDecisionCounts[0] = 64
        let fixedCapSidecar = try Self.makeSidecar(
            seed: fixture.seed,
            correlations: fixture.correlations,
            byteLogits: fixture.byteLogits,
            eosLogits: fixture.eosLogits,
            decisionCounts: fixedCapDecisionCounts
        )
        let fixedCapDecisions = try (1 ... 64).map {
            try PrimeNativeNeuralGateCompletionDecision
                .make(
                    ordinal: $0,
                    fullVocabularyLogits:
                        fixture.byteLogits
                )
        }
        let fixedCapInput = try
            PrimeNativeNeuralGatePromptOnlyExecutionInput
            .derive(
                promptText:
                    firstScheduledPrompt
                    .promptRow.canonicalPrompt
            )
        let fixedCapExecution = try
            PrimeNativeNeuralGateRawExecution.validate(
                replicateContext:
                    PrimeNativeNeuralGateCorrectedReplicateContext(
                        evaluationSeed:
                            fixture.seed.rawValue
                    ),
                input: fixedCapInput,
                decisions: fixedCapDecisions
            )
        XCTAssertEqual(
            fixedCapExecution.termination,
            .fixedCap
        )
        XCTAssertEqual(
            fixedCapExecution.decisionsExecuted,
            64
        )
        var fixedCapRawRows = fixture.rawRows
        fixedCapRawRows[0] = try Self.decodeRaw(
            seed: fixture.seed,
            scheduled: firstScheduledPrompt,
            primeCPI2PromptBindingSHA256:
                firstScheduledPrompt
                .primeCPI2PromptBindingSHA256,
            traceSHA256:
                fixedCapExecution.traceSHA256,
            generatedTokenIDs:
                fixedCapExecution.generatedTokenIDs.map {
                    UInt16($0)
                },
            termination: .fixedCap
        )
        let fixedCapJoined = try Composition.join(
            schedule: fixture.schedule,
            replicateSeed: fixture.seed,
            outerRows: fixture.outerRows,
            rawRows: fixedCapRawRows,
            validatedLogitSidecar: fixedCapSidecar
        )
        XCTAssertEqual(
            fixedCapJoined.orderedRows[0]
                .rawExecution.termination,
            .fixedCap
        )

        var equalCountEOSMutation = fixedCapRawRows
        equalCountEOSMutation[0] = try Self.decodeRaw(
            seed: fixture.seed,
            scheduled: firstScheduledPrompt,
            primeCPI2PromptBindingSHA256:
                firstScheduledPrompt
                .primeCPI2PromptBindingSHA256,
            traceSHA256:
                fixedCapExecution.traceSHA256,
            generatedTokenIDs: Array(
                repeating: UInt16(321),
                count: 63
            ),
            termination: .eos
        )
        XCTAssertEqual(
            equalCountEOSMutation[0].decisionCount,
            fixedCapRawRows[0].decisionCount
        )
        assertThrows(.terminationMismatch(index: 0)) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: equalCountEOSMutation,
                validatedLogitSidecar:
                    fixedCapSidecar
            )
        }
    }

    func testSidecarCorrelationDecisionSeedAndFloatMutationsFail()
        throws
    {
        let fixture = try Self.fixtureResult.get()

        var correlations = fixture.correlations
        correlations[0] = "mutated-correlation-00000000"
        let wrongCorrelation = try Self.makeSidecar(
            seed: fixture.seed,
            correlations: correlations,
            byteLogits: fixture.byteLogits,
            eosLogits: fixture.eosLogits
        )
        assertThrows(.logitCorrelationMismatch(index: 0)) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: fixture.rawRows,
                validatedLogitSidecar:
                    wrongCorrelation
            )
        }

        var decisionCounts = Array(
            repeating: 2,
            count: 18_432
        )
        decisionCounts[0] = 1
        let missingDecision = try Self.makeSidecar(
            seed: fixture.seed,
            correlations: fixture.correlations,
            byteLogits: fixture.byteLogits,
            eosLogits: fixture.eosLogits,
            decisionCounts: decisionCounts
        )
        assertThrows(.decisionCountMismatch(index: 0)) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: fixture.rawRows,
                validatedLogitSidecar:
                    missingDecision
            )
        }

        let wrongSeed = try Self.makeSidecar(
            seed: .seed2718,
            correlations: fixture.correlations,
            byteLogits: fixture.byteLogits,
            eosLogits: fixture.eosLogits
        )
        assertThrows(
            .logitReplicateSeedMismatch(
                expected: 1_618,
                observed: 2_718
            )
        ) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: fixture.rawRows,
                validatedLogitSidecar: wrongSeed
            )
        }

        var mutatedLogits = fixture.byteLogits
        mutatedLogits[0] = -9
        let wrongFloat = try Self.makeSidecar(
            seed: fixture.seed,
            correlations: fixture.correlations,
            byteLogits: mutatedLogits,
            eosLogits: fixture.eosLogits
        )
        assertThrows(.traceDigestMismatch(index: 0)) {
            _ = try Composition.join(
                schedule: fixture.schedule,
                replicateSeed: fixture.seed,
                outerRows: fixture.outerRows,
                rawRows: fixture.rawRows,
                validatedLogitSidecar: wrongFloat
            )
        }
    }

    func testCompositionTargetIsPureAndTrapDisjoint()
        throws
    {
        let source = try completeSwiftSource(
            target:
                "PrimeNativeNeuralGateReplayComposition"
        )
        let imports = source
            .split(separator: "\n")
            .filter { $0.hasPrefix("import ") }
            .map(String.init)
        XCTAssertEqual(
            imports,
            [
                "import Foundation",
                "import PrimeNativeNeuralGateCorrectedMechanics",
                "import PrimeNativeNeuralGateLogitSidecarMechanics",
                "import PrimeNativeNeuralGateReplayArtifactContracts",
                "import PrimeNativeNeuralGateReplayMechanics",
                "import PrimeNativeNeuralGateReplayTransport",
            ]
        )
        for forbidden in [
            "import PrimeCore",
            "import PrimeNativeCorpusReplayMechanics",
            "import PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "import PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "import PrimeNativeNeuralGatePromptSolver",
            "import PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            "import MLX",
            "ErgenticsPrimeRuntime",
            "Foundation.Process",
            "Process(",
            "posix_spawn",
            "execve(",
            "system(",
            "popen(",
            "/bin/sh",
            "/bin/zsh",
            "\"python3\"",
            "try" + "!",
            "fatalError(",
            "precondition(",
            "preconditionFailure(",
            "FileHandle(forWriting",
            "FileHandle(forUpdating",
            "FileHandle(forReadingFrom:",
            "FileHandle.standardInput",
            "FileManager.default",
            "Data(contentsOf:",
            "String(contentsOf:",
            "InputStream(",
            "Bundle.",
            "OutputStream(",
            "URLSession",
            "import Network",
            "NWConnection",
            "CFReadStream",
            "NSFileCoordinator",
            "createFile(",
            "write(to:",
            "read(",
            "O_WRONLY",
            "O_RDWR",
            "O_CREAT",
            "O_RDONLY",
            "open(",
            "openat(",
            "fopen(",
            "mmap(",
            "stat(",
            "lstat(",
            "fstat(",
            "access(",
            "opendir(",
            "readdir(",
            "rename(",
            "unlink(",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                forbidden
            )
        }
    }

    private struct Fixture {
        let seed: PrimeNativeNeuralGateArtifactSeed
        let canonicalPromptRecords: [Data]
        let schedule: PrimeNativeNeuralGatePromptSchedule
        let outerRows:
            [PrimeNativeNeuralGateReplayOuterEvaluationRow]
        let rawRows:
            [PrimeNativeNeuralGateReplayRawExecutionReference]
        let correlations: [String]
        let byteLogits: [Float]
        let eosLogits: [Float]
        let sidecar:
            PrimeNativeNeuralGateValidatedLogitSidecar
    }

    private static let fixtureResult:
        Result<Fixture, Swift.Error> = Result {
            try makeFixture()
        }

    private static func makeFixture() throws -> Fixture {
        let seed:
            PrimeNativeNeuralGateArtifactSeed = .seed1618
        var unsorted = [Data]()
        unsorted.reserveCapacity(18_432)
        for ordinal in 0 ..< 18_432 {
            let prompt = String(
                format: "prime-schedule-%05d",
                ordinal
            )
            unsorted.append(
                try Codec.encodePromptOnlyRow(
                    promptTokenIDs:
                        [1] + prompt.utf8.map {
                            UInt16($0) + 256
                        }
                )
            )
        }
        let canonical = try
            PrimeNativeNeuralGateInvariantCodec
            .canonicalRecords(unsorted)
        let schedule = try Composition
            .makePromptSchedule(
                canonicalPromptRecords: canonical
            )
        let correlations =
            schedule.orderedPrompts.map(\.correlationID)
        let outer = try correlations.enumerated().map {
            try decodeOuter(
                executionIndex: UInt32($0.offset),
                correlationID: $0.element
            )
        }

        let byteLogits = logits(selecting: 321)
        let eosLogits = logits(
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
        var raw =
            [PrimeNativeNeuralGateReplayRawExecutionReference]()
        raw.reserveCapacity(18_432)
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
            raw.append(
                try decodeRaw(
                    seed: seed,
                    scheduled: scheduled,
                    primeCPI2PromptBindingSHA256:
                        input.bindingSHA256,
                    traceSHA256:
                        execution.traceSHA256,
                    generatedTokenIDs: [321]
                )
            )
        }
        let sidecar = try makeSidecar(
            seed: seed,
            correlations: correlations,
            byteLogits: byteLogits,
            eosLogits: eosLogits
        )
        return Fixture(
            seed: seed,
            canonicalPromptRecords: canonical,
            schedule: schedule,
            outerRows: outer,
            rawRows: raw,
            correlations: correlations,
            byteLogits: byteLogits,
            eosLogits: eosLogits,
            sidecar: sidecar
        )
    }

    private static func makeSidecar(
        seed: PrimeNativeNeuralGateArtifactSeed,
        correlations: [String],
        byteLogits: [Float],
        eosLogits: [Float],
        decisionCounts: [Int]? = nil
    ) throws -> PrimeNativeNeuralGateValidatedLogitSidecar {
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
        let counts = decisionCounts ?? Array(
            repeating: 2,
            count: 18_432
        )
        guard correlations.count == 18_432,
              counts.count == 18_432
        else {
            throw Error.invalidLogitRowCount(
                expected: 18_432,
                observed: correlations.count
            )
        }
        let rows = try correlations.enumerated().map {
            let decisions:
                [PrimeNativeNeuralGateLogitDecisionReference]
            switch counts[$0.offset] {
            case 1:
                decisions = [
                    try PrimeNativeNeuralGateLogitDecisionReference(
                        ordinal: 1,
                        dictionaryIndex: byteIndex
                    ),
                ]
            case 2:
                decisions = [
                    try PrimeNativeNeuralGateLogitDecisionReference(
                        ordinal: 1,
                        dictionaryIndex: byteIndex
                    ),
                    try PrimeNativeNeuralGateLogitDecisionReference(
                        ordinal: 2,
                        dictionaryIndex: eosIndex
                    ),
                ]
            case 64:
                decisions = try (1 ... 64).map {
                    try PrimeNativeNeuralGateLogitDecisionReference(
                        ordinal: $0,
                        dictionaryIndex: byteIndex
                    )
                }
            default:
                throw Error.decisionCountMismatch(
                    index: UInt32($0.offset)
                )
            }
            return try PrimeNativeNeuralGateLogitRowReference(
                rowOrdinal: $0.offset,
                correlationID: $0.element,
                decisions: decisions
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
        let manifest = try
            PrimeNativeNeuralGateLogitSidecarCodec
            .encodeManifest(
                dictionaryData: dictionaryData,
                chunkData: chunks,
                expectedReplicateContext: context
            )
        return try
            PrimeNativeNeuralGateLogitSidecarCodec
            .validateCompleteSidecar(
                dictionaryData: dictionaryData,
                chunkData: chunks,
                manifestData: manifest,
                expectedReplicateContext: context
            )
    }

    private static func decodeOuter(
        executionIndex: UInt32,
        correlationID: String
    ) throws
        -> PrimeNativeNeuralGateReplayOuterEvaluationRow
    {
        try Decoder.decodeOuterEvaluationRow(
            from: try Codec.encodeOuterEvaluationRow(
                executionIndex: executionIndex,
                correlationID: correlationID,
                expectedCompletionUTF8:
                    Data("A".utf8)
            )
        )
    }

    private static func decodeRaw(
        seed: PrimeNativeNeuralGateArtifactSeed,
        scheduled: PrimeNativeNeuralGateScheduledPrompt,
        primeCPI2PromptBindingSHA256: String,
        traceSHA256: String,
        generatedTokenIDs: [UInt16],
        termination:
            PrimeNativeNeuralGateReplayTermination = .eos
    ) throws
        -> PrimeNativeNeuralGateReplayRawExecutionReference
    {
        try Decoder.decodeRawExecutionReference(
            expectedSeed: seed,
            from: try Codec.encodeRawExecutionReference(
                replicateSeed: seed,
                executionIndex:
                    scheduled.executionIndex,
                primeCPI2PromptBindingSHA256:
                    primeCPI2PromptBindingSHA256,
                traceSHA256: traceSHA256,
                generatedTokenIDs:
                    generatedTokenIDs,
                termination: termination
            )
        )
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

    private static func digest(
        _ character: Character
    ) -> String {
        String(
            repeating: String(character),
            count: 64
        )
    }

    private func assertThrows(
        _ expected: Error,
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
                $0 as? Error,
                expected,
                file: file,
                line: line
            )
        }
    }

    private func completeSwiftSource(
        target: String
    ) throws -> String {
        let directory =
            repositoryRoot
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
        XCTAssertFalse(swiftFiles.isEmpty)
        XCTAssertEqual(
            entries.map(\.lastPathComponent),
            swiftFiles.map(\.lastPathComponent),
            "pure target contains a non-Swift entry"
        )
        return try swiftFiles.map {
            try String(
                contentsOf: $0,
                encoding: .utf8
            )
        }.joined(separator: "\n")
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
