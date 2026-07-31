import Foundation
import PrimeNativeNeuralGateReplayArtifactContracts
@testable import PrimeNativeNeuralGateReplayTransport
import XCTest

final class PrimeNativeNeuralGateReplayTransportTests:
    XCTestCase
{
    private typealias Decoder =
        PrimeNativeNeuralGateReplayTransportDecoder
    private typealias Error =
        PrimeNativeNeuralGateReplayTransportError
    private typealias Contract =
        PrimeNativeNeuralGateReplayArtifactOutputContract

    func testDecoderModesFailBeforeArtifactBytesAreParsed()
        throws
    {
        for key: PrimeNativeNeuralGateArtifactKey in [
            .promptOnlyFixtureManifest,
            .outerEvaluationManifest,
            .rawExecutionManifest(.seed1618),
        ] {
            XCTAssertNoThrow(
                try Decoder.requireBoundedArtifactSpec(
                    for: key
                )
            )
        }

        for key: PrimeNativeNeuralGateArtifactKey in [
            .promptOnlyFixtureGlobal,
            .promptOnlyFixtureChunk(0),
            .outerEvaluationGlobal,
            .outerEvaluationChunk(0),
            .rawExecutionGlobal(.seed1618),
            .rawExecutionChunk(.seed1618, 0),
        ] {
            assertThrows(
                .descriptorStreamingDecoderRequired
            ) {
                _ = try Decoder.decodeArtifact(
                    key: key,
                    from: Data([0xff])
                )
            }
        }

        for key: PrimeNativeNeuralGateArtifactKey in [
            .logitDictionary(.seed1618),
            .logitManifest(.seed1618),
            .logitChunk(.seed1618, 0),
        ] {
            assertThrows(.sourceBoundCodecRequired) {
                _ = try Decoder.decodeArtifact(
                    key: key,
                    from: Data([0xff])
                )
            }
        }

        var deferred: [PrimeNativeNeuralGateArtifactKey] = [
            .correctedStatisticsVerdict,
            .correctedWorkerRequestReserved,
            .correctedWorkerProcessReserved,
            .correctedWorkerExecutionReserved,
            .correctedWorkerResultReserved,
            .replacementTerminalReceiptReserved,
        ]
        for arm in PrimeNativeNeuralGateArtifactArm.allCases {
            deferred.append(
                contentsOf: [
                    .mutationDeltaManifest(arm),
                    .mutationDeltaGlobal(arm),
                    .mutationDeltaChunk(arm, 0),
                ]
            )
        }
        for role in
            PrimeNativeNeuralGateHistoricalArtifactRole
            .allCases
        {
            deferred.append(
                contentsOf: [
                    .historicalMaterialManifest(role),
                    .historicalGateObservation(role),
                    .historicalMutationObservation(role),
                ]
            )
        }
        for seed in
            PrimeNativeNeuralGateArtifactSeed.allCases
        {
            deferred.append(.mlxObservation(seed))
        }
        for key in deferred {
            assertThrows(.schemaDeferred) {
                _ = try Decoder
                    .requireBoundedArtifactSpec(for: key)
            }
            assertThrows(.schemaDeferred) {
                _ = try Decoder.decodeArtifact(
                    key: key,
                    from: Data([0xff])
                )
            }
        }
    }

    func testPromptManifestBindsExactPartitionAndPaths()
        throws
    {
        let data = try recordManifestData(
            key: .promptOnlyFixtureManifest,
            recordSchemaID:
                PrimeNativeNeuralGateReplayRecordSchema
                .promptOnlyRowV1,
            recordCount: 18_432,
            globalKey: .promptOnlyFixtureGlobal,
            chunkKeys: (0 ..< 5).map {
                .promptOnlyFixtureChunk(UInt32($0))
            },
            chunkRecordCounts: [
                4_096,
                4_096,
                4_096,
                4_096,
                2_048,
            ]
        )

        guard case let .recordManifest(manifest) =
            try Decoder.decodeArtifact(
                key: .promptOnlyFixtureManifest,
                from: data
            )
        else {
            return XCTFail("wrong decoded artifact")
        }
        XCTAssertEqual(manifest.recordCount, 18_432)
        XCTAssertEqual(
            manifest.orderedChunks.map(\.ordinal),
            [0, 1, 2, 3, 4]
        )
        XCTAssertEqual(
            manifest.orderedChunks.map(\.recordCount),
            [4_096, 4_096, 4_096, 4_096, 2_048]
        )
        XCTAssertEqual(
            manifest.relativePath,
            try Contract.frozenV4.spec(
                for: .promptOnlyFixtureManifest
            ).relativePath
        )
        XCTAssertFalse(manifest.recordsMaterialized)
        XCTAssertFalse(manifest.mechanicsPassAuthorized)

        var wrongPath = try object(from: data)
        var chunks = try XCTUnwrap(
            wrongPath["chunks"] as? [[String: Any]]
        )
        chunks[0]["relative_path"] =
            "neural-gate-replay/corrected/fixture/wrong.bin"
        wrongPath["chunks"] = chunks
        assertThrows(.invalidBinding) {
            _ = try Decoder.decodeArtifact(
                key: .promptOnlyFixtureManifest,
                from: try canonicalData(wrongPath)
            )
        }

        var wrongOrder = try object(from: data)
        var reordered = try XCTUnwrap(
            wrongOrder["chunks"] as? [[String: Any]]
        )
        reordered.swapAt(0, 1)
        wrongOrder["chunks"] = reordered
        assertThrows(.invalidManifest) {
            _ = try Decoder.decodeArtifact(
                key: .promptOnlyFixtureManifest,
                from: try canonicalData(wrongOrder)
            )
        }

        var authorizing = try object(from: data)
        authorizing["mechanics_pass_authorized"] =
            true
        assertThrows(
            .authorizingClaimForbidden(
                "manifest_materialization_or_pass"
            )
        ) {
            _ = try Decoder.decodeArtifact(
                key: .promptOnlyFixtureManifest,
                from: try canonicalData(authorizing)
            )
        }

        var zeroBytes = try object(from: data)
        var global = try XCTUnwrap(
            zeroBytes["global_stream"]
                as? [String: Any]
        )
        global["byte_count"] = 0
        zeroBytes["global_stream"] = global
        assertThrows(.invalidBinding) {
            _ = try Decoder.decodeArtifact(
                key: .promptOnlyFixtureManifest,
                from: try canonicalData(zeroBytes)
            )
        }

        var uppercaseDigest = try object(from: data)
        var upperGlobal = try XCTUnwrap(
            uppercaseDigest["global_stream"]
                as? [String: Any]
        )
        upperGlobal["sha256"] = digest("A")
        uppercaseDigest["global_stream"] =
            upperGlobal
        assertThrows(.invalidSHA256(digest("A"))) {
            _ = try Decoder.decodeArtifact(
                key: .promptOnlyFixtureManifest,
                from: try canonicalData(
                    uppercaseDigest
                )
            )
        }

        var wrongSchema = try object(from: data)
        wrongSchema["schema_version"] = 2
        assertThrows(.invalidSchemaVersion) {
            _ = try Decoder.decodeArtifact(
                key: .promptOnlyFixtureManifest,
                from: try canonicalData(wrongSchema)
            )
        }
    }

    func testPromptOnlyRowHasNoRowSeedOrDedicatedOuterFields()
        throws
    {
        let row: [String: Any] = [
            "schema_version": 1,
            "record_kind":
                PrimeNativeNeuralGateReplayRecordSchema
                .promptOnlyRowV1,
            "prompt_token_ids": [1, 321],
        ]
        let decoded = try Decoder.decodePromptOnlyRow(
            from: try canonicalData(row)
        )
        XCTAssertEqual(decoded.promptTokenIDs, [1, 321])
        XCTAssertEqual(decoded.canonicalPrompt, "A")
        XCTAssertFalse(decoded.dedicatedTargetFieldPresent)
        XCTAssertFalse(
            decoded.targetIndependenceEstablished
        )

        for forbidden in [
            "expected_target",
            "replicate_seed",
            "correlation_id",
            "decision_budget",
            "termination",
        ] {
            var leaked = row
            leaked[forbidden] = "forbidden"
            assertThrows(
                .forbiddenPromptOnlyField(forbidden)
            ) {
                _ = try Decoder.decodePromptOnlyRow(
                    from: try canonicalData(leaked)
                )
            }
        }

        var invalidToken = row
        invalidToken["prompt_token_ids"] = [1, 2]
        assertThrows(.invalidPromptTokens) {
            _ = try Decoder.decodePromptOnlyRow(
                from: try canonicalData(invalidToken)
            )
        }

        var targetLikeContent = row
        targetLikeContent["prompt_token_ids"] =
            [1] + Array("target=A".utf8).map {
                Int($0) + 256
            }
        let acceptedShape =
            try Decoder.decodePromptOnlyRow(
                from:
                    try canonicalData(
                        targetLikeContent
                    )
            )
        XCTAssertEqual(
            acceptedShape.canonicalPrompt,
            "target=A"
        )
        XCTAssertFalse(
            acceptedShape.targetIndependenceEstablished
        )
    }

    func testOuterAndRawManifestsBindExactRoleAndSeedPaths()
        throws
    {
        let chunkCounts = [
            4_096,
            4_096,
            4_096,
            4_096,
            2_048,
        ]
        let outerData = try recordManifestData(
            key: .outerEvaluationManifest,
            recordSchemaID:
                PrimeNativeNeuralGateReplayRecordSchema
                .outerEvaluationRowV1,
            recordCount: 18_432,
            globalKey: .outerEvaluationGlobal,
            chunkKeys: (0 ..< 5).map {
                .outerEvaluationChunk(UInt32($0))
            },
            chunkRecordCounts: chunkCounts
        )
        guard case let .recordManifest(outer) =
            try Decoder.decodeArtifact(
                key: .outerEvaluationManifest,
                from: outerData
            )
        else {
            return XCTFail("wrong outer manifest")
        }
        XCTAssertEqual(
            outer.recordSchemaID,
            PrimeNativeNeuralGateReplayRecordSchema
                .outerEvaluationRowV1
        )

        let rawData = try recordManifestData(
            key: .rawExecutionManifest(.seed1618),
            recordSchemaID:
                PrimeNativeNeuralGateReplayRecordSchema
                .rawExecutionReferenceV1,
            recordCount: 18_432,
            globalKey: .rawExecutionGlobal(.seed1618),
            chunkKeys: (0 ..< 5).map {
                .rawExecutionChunk(
                    .seed1618,
                    UInt32($0)
                )
            },
            chunkRecordCounts: chunkCounts
        )
        guard case let .recordManifest(raw) =
            try Decoder.decodeArtifact(
                key: .rawExecutionManifest(.seed1618),
                from: rawData
            )
        else {
            return XCTFail("wrong raw manifest")
        }
        XCTAssertEqual(
            raw.artifactKey,
            .rawExecutionManifest(.seed1618)
        )
        assertThrows(.invalidBinding) {
            _ = try Decoder.decodeArtifact(
                key: .rawExecutionManifest(.seed2718),
                from: rawData
            )
        }
    }

    func testCanonicalJSONRejectsAlternateAndMalformedBytes()
        throws
    {
        let row: [String: Any] = [
            "schema_version": 1,
            "record_kind":
                PrimeNativeNeuralGateReplayRecordSchema
                .promptOnlyRowV1,
            "prompt_token_ids": [1, 321],
        ]
        let canonical = try canonicalData(row)

        var whitespace = canonical
        whitespace.append(0x0a)
        assertThrows(.noncanonicalJSON) {
            _ = try Decoder.decodePromptOnlyRow(
                from: whitespace
            )
        }

        var unknown = row
        unknown["unknown"] = false
        assertThrows(.noncanonicalJSON) {
            _ = try Decoder.decodePromptOnlyRow(
                from: try canonicalData(unknown)
            )
        }

        let duplicate =
            #"{"prompt_token_ids":[1,321],"prompt_token_ids":[1,322],"record_kind":"prime_stage_b_prompt_only_row_v1","schema_version":1}"#
        XCTAssertThrowsError(
            try Decoder.decodePromptOnlyRow(
                from: Data(duplicate.utf8)
            )
        )

        let wrongKeyOrder =
            #"{"schema_version":1,"record_kind":"prime_stage_b_prompt_only_row_v1","prompt_token_ids":[1,321]}"#
        assertThrows(.noncanonicalJSON) {
            _ = try Decoder.decodePromptOnlyRow(
                from: Data(wrongKeyOrder.utf8)
            )
        }

        let alternateEscape =
            #"{"prompt_token_ids":[1,321],"record_kind":"\u0070rime_stage_b_prompt_only_row_v1","schema_version":1}"#
        assertThrows(.noncanonicalJSON) {
            _ = try Decoder.decodePromptOnlyRow(
                from: Data(alternateEscape.utf8)
            )
        }

        var missing = row
        missing.removeValue(
            forKey: "prompt_token_ids"
        )
        assertThrows(.invalidJSON) {
            _ = try Decoder.decodePromptOnlyRow(
                from: try canonicalData(missing)
            )
        }

        var nullValue = row
        nullValue["prompt_token_ids"] = NSNull()
        assertThrows(.invalidJSON) {
            _ = try Decoder.decodePromptOnlyRow(
                from: try canonicalData(nullValue)
            )
        }

        var bom = Data([0xef, 0xbb, 0xbf])
        bom.append(canonical)
        assertThrows(.byteOrderMarkForbidden) {
            _ = try Decoder.decodePromptOnlyRow(from: bom)
        }
        assertThrows(.invalidUTF8) {
            _ = try Decoder.decodePromptOnlyRow(
                from: Data([0x7b, 0xff, 0x7d])
            )
        }
        assertThrows(.rootObjectRequired) {
            _ = try Decoder.decodePromptOnlyRow(
                from: Data("[]".utf8)
            )
        }

        let tooDeep =
            #"{"a":"# + String(
                repeating: "[",
                count: 17
            ) + "0" + String(
                repeating: "]",
                count: 17
            ) + "}"
        assertThrows(
            .nestingDepthExceeded(maximumDepth: 16)
        ) {
            _ = try Decoder.decodePromptOnlyRow(
                from: Data(tooDeep.utf8)
            )
        }

        assertThrows(
            .artifactTooLarge(maximumBytes: 65_536)
        ) {
            _ = try Decoder.decodePromptOnlyRow(
                from: Data(
                    repeating: 0x20,
                    count: 65_537
                )
            )
        }

        var tooManyStructuralTokens =
            Data(#"{"a":["#.utf8)
        for ordinal in 0 ..< 233_333 {
            if ordinal > 0 {
                tooManyStructuralTokens.append(0x2c)
            }
            tooManyStructuralTokens.append(
                contentsOf: [0x5b, 0x5d]
            )
        }
        tooManyStructuralTokens.append(
            contentsOf: [0x5d, 0x7d]
        )
        XCTAssertLessThan(
            tooManyStructuralTokens.count,
            1_048_576
        )
        assertThrows(
            .structuralTokenLimitExceeded(
                maximumCount: 700_000
            )
        ) {
            _ = try Decoder.decodeArtifact(
                key: .promptOnlyFixtureManifest,
                from: tooManyStructuralTokens
            )
        }

        let manifest = try recordManifestData(
            key: .promptOnlyFixtureManifest,
            recordSchemaID:
                PrimeNativeNeuralGateReplayRecordSchema
                .promptOnlyRowV1,
            recordCount: 18_432,
            globalKey: .promptOnlyFixtureGlobal,
            chunkKeys: (0 ..< 5).map {
                .promptOnlyFixtureChunk(UInt32($0))
            },
            chunkRecordCounts: [
                4_096,
                4_096,
                4_096,
                4_096,
                2_048,
            ]
        )
        var exactString = try object(from: manifest)
        exactString["padding"] = String(
            repeating: "x",
            count: 65_536
        )
        assertThrows(.noncanonicalJSON) {
            _ = try Decoder.decodeArtifact(
                key: .promptOnlyFixtureManifest,
                from: try canonicalData(exactString)
            )
        }
        var oversizedString = exactString
        oversizedString["padding"] = String(
            repeating: "x",
            count: 65_537
        )
        assertThrows(
            .stringTokenTooLarge(
                maximumBytes: 65_536
            )
        ) {
            _ = try Decoder.decodeArtifact(
                key: .promptOnlyFixtureManifest,
                from: try canonicalData(
                    oversizedString
                )
            )
        }
    }

    func testOuterEvaluationAndRawExecutionStaySeparated()
        throws
    {
        let outer = try Decoder.decodeOuterEvaluationRow(
            from: try canonicalData([
                "schema_version": 1,
                "record_kind":
                    PrimeNativeNeuralGateReplayRecordSchema
                    .outerEvaluationRowV1,
                "execution_index": 7,
                "correlation_id":
                    "fixture_00000007",
                "expected_completion_utf8": [65],
            ])
        )
        XCTAssertEqual(outer.executionIndex, 7)
        XCTAssertEqual(
            outer.canonicalExpectedCompletion,
            "A"
        )

        let rawObject: [String: Any] = [
            "schema_version": 1,
            "record_kind":
                PrimeNativeNeuralGateReplayRecordSchema
                .rawExecutionReferenceV1,
            "replicate_seed": 2_718,
            "execution_index": 7,
            "prompt_sha256": digest("a"),
            "trace_sha256": digest("b"),
            "decision_count": 2,
            "generated_token_ids": [321],
            "termination": "eos",
            "logits_materialized": false,
            "execution_authorized": false,
        ]
        let raw =
            try Decoder.decodeRawExecutionReference(
                expectedSeed: .seed2718,
                from: try canonicalData(rawObject)
            )
        XCTAssertEqual(raw.replicateSeed, .seed2718)
        XCTAssertEqual(raw.termination, .eos)
        XCTAssertEqual(raw.generatedTokenIDs, [321])
        XCTAssertFalse(raw.executionAuthorized)

        var targetLeak = rawObject
        targetLeak["expected_completion_utf8"] = [65]
        assertThrows(.noncanonicalJSON) {
            _ = try Decoder.decodeRawExecutionReference(
                expectedSeed: .seed2718,
                from: try canonicalData(targetLeak)
            )
        }

        var rowSeed = rawObject
        rowSeed["replicate_seed"] = 300
        assertThrows(.invalidReplicateSeed) {
            _ = try Decoder.decodeRawExecutionReference(
                expectedSeed: .seed2718,
                from: try canonicalData(rowSeed)
            )
        }

        assertThrows(.invalidReplicateSeed) {
            _ = try Decoder.decodeRawExecutionReference(
                expectedSeed: .seed1618,
                from: try canonicalData(rawObject)
            )
        }

        var wrongEOS = rawObject
        wrongEOS["decision_count"] = 1
        assertThrows(.invalidTermination) {
            _ = try Decoder.decodeRawExecutionReference(
                expectedSeed: .seed2718,
                from: try canonicalData(wrongEOS)
            )
        }

        var immediateEOS = rawObject
        immediateEOS["decision_count"] = 1
        immediateEOS["generated_token_ids"] = []
        XCTAssertNoThrow(
            try Decoder.decodeRawExecutionReference(
                expectedSeed: .seed2718,
                from: try canonicalData(immediateEOS)
            )
        )

        var outOfRangeIndex = rawObject
        outOfRangeIndex["execution_index"] = 18_432
        assertThrows(.invalidExecutionIndex) {
            _ = try Decoder.decodeRawExecutionReference(
                expectedSeed: .seed2718,
                from: try canonicalData(
                    outOfRangeIndex
                )
            )
        }

        var invalidToken = rawObject
        invalidToken["generated_token_ids"] = [512]
        assertThrows(.invalidGeneratedTokens) {
            _ = try Decoder.decodeRawExecutionReference(
                expectedSeed: .seed2718,
                from: try canonicalData(invalidToken)
            )
        }

        var authorized = rawObject
        authorized["execution_authorized"] = true
        assertThrows(
            .authorizingClaimForbidden(
                "raw_execution_or_logits"
            )
        ) {
            _ = try Decoder.decodeRawExecutionReference(
                expectedSeed: .seed2718,
                from: try canonicalData(authorized)
            )
        }

        var fixedCap = rawObject
        fixedCap["decision_count"] = 64
        fixedCap["generated_token_ids"] =
            Array(repeating: 321, count: 64)
        fixedCap["termination"] = "fixed_cap"
        XCTAssertNoThrow(
            try Decoder.decodeRawExecutionReference(
                expectedSeed: .seed2718,
                from: try canonicalData(fixedCap)
            )
        )

        var shortFixedCap = fixedCap
        shortFixedCap["generated_token_ids"] =
            Array(repeating: 321, count: 63)
        assertThrows(.invalidTermination) {
            _ = try Decoder.decodeRawExecutionReference(
                expectedSeed: .seed2718,
                from: try canonicalData(shortFixedCap)
            )
        }
    }

    func testTransportSourceClosureStaysPureAndNonExecuting()
        throws
    {
        let source = try completeSwiftSource(
            target:
                "PrimeNativeNeuralGateReplayTransport"
        )
        XCTAssertEqual(
            source
                .split(separator: "\n")
                .filter {
                    $0.hasPrefix("import ")
                }
                .map(String.init),
            [
                "import Foundation",
                "import PrimeNativeNeuralGateReplayArtifactContracts",
                "import PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        for forbidden in [
            "PrimeCore",
            "CorrectedMechanics",
            "EvaluationMechanics",
            "FixtureAuthority",
            "PromptSolver",
            "LogitSidecarMechanics",
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
        XCTAssertFalse(
            PrimeNativeNeuralGateReplayTransportAuthority
                .mechanicsPassAuthorized
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplayTransportAuthority
                .groundedVerdictAuthorized
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplayTransportAuthority
                .mutationDetectionAuthorized
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateReplayTransportAuthority
                .terminalReceiptAuthorized
        )
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

    private func recordManifestData(
        key: PrimeNativeNeuralGateArtifactKey,
        recordSchemaID: String,
        recordCount: Int,
        globalKey: PrimeNativeNeuralGateArtifactKey,
        chunkKeys:
            [PrimeNativeNeuralGateArtifactKey],
        chunkRecordCounts: [Int]
    ) throws -> Data {
        let contract = Contract.frozenV4
        let manifestSpec = try contract.spec(
            for: key
        )
        let globalSpec = try contract.spec(
            for: globalKey
        )
        let chunks = try zip(
            chunkKeys,
            chunkRecordCounts
        ).enumerated().map {
            let spec = try contract.spec(
                for: $0.element.0
            )
            return [
                "ordinal": $0.offset,
                "record_count": $0.element.1,
                "relative_path": spec.relativePath,
                "sha256": digest("b"),
                "byte_count": 1,
            ] as [String: Any]
        }
        return try canonicalData([
            "schema_version":
                manifestSpec.schemaVersion,
            "artifact_kind":
                manifestSpec.schemaID,
            "record_schema_id": recordSchemaID,
            "record_count": recordCount,
            "global_stream": [
                "relative_path":
                    globalSpec.relativePath,
                "sha256": digest("a"),
                "byte_count": 1,
            ],
            "chunks": chunks,
            "records_materialized": false,
            "mechanics_pass_authorized": false,
        ])
    }

    private func canonicalData(
        _ object: [String: Any]
    ) throws -> Data {
        XCTAssertTrue(
            JSONSerialization.isValidJSONObject(
                object
            )
        )
        return try JSONSerialization.data(
            withJSONObject: object,
            options: [
                .sortedKeys,
                .withoutEscapingSlashes,
            ]
        )
    }

    private func object(
        from data: Data
    ) throws -> [String: Any] {
        try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )
    }

    private func digest(
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

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
