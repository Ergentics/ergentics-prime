import Foundation
import XCTest
@testable import PrimeCore
@testable import PrimeNativeCorpusReplay
@testable import PrimeNativeCorpusReplayMechanics

final class PrimeNativeCorpusReplayContractTests:
    XCTestCase
{
    func testByteExactTransplantsMatchFrozenDonorBindings()
        throws
    {
        let expected: [
            (
                path: String,
                byteCount: UInt64,
                sha256: String
            )
        ] = [
            (
                "Sources/PrimeNativeCorpusReplayMechanics/PrimeNativeByteTokenizer.swift",
                21_320,
                "9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721"
            ),
            (
                "Sources/PrimeNativeCorpusReplayMechanics/ErgenticsPrimeNativeTextCorpus.swift",
                177_032,
                "4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210"
            ),
        ]

        for item in expected {
            let data = try Data(
                contentsOf: repositoryRoot
                    .appendingPathComponent(item.path)
            )
            XCTAssertEqual(
                UInt64(data.count),
                item.byteCount,
                "transplanted donor byte count drifted: \(item.path)"
            )
            XCTAssertEqual(
                PrimeSHA256.hexDigest(of: data),
                item.sha256,
                "transplanted donor SHA-256 drifted: \(item.path)"
            )
        }
    }

    func testFrozenPlanBindsEveryDonorSourceAndPolicyExactly()
        throws
    {
        let plan = PrimeNativeCorpusReplayPlan.frozenV1
        try plan.validate()

        XCTAssertEqual(
            plan.companionRevision,
            "163fc100710ece48119bc25954452d10f6a84f7f"
        )
        XCTAssertEqual(
            plan.companionTreeOID,
            "9009daa4f8a07fbd5897e00b9571cef44ec292db"
        )
        XCTAssertEqual(
            plan.sourceBindings,
            [
                PrimeNativeCorpusReplaySourceBinding(
                    role: .tokenizerMechanics,
                    donorRelativePath:
                        "prime-runtime/Sources/ErgenticsPrimeRuntime/PrimeNativeByteTokenizer.swift",
                    primeRelativePath:
                        "Sources/PrimeNativeCorpusReplayMechanics/PrimeNativeByteTokenizer.swift",
                    gitBlobOID:
                        "27f5d4f61864499027d3e65516ae4c5cfe1ff5d1",
                    byteCount: 21_320,
                    sha256:
                        "9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721",
                    policy: .byteExactPrimeSource
                ),
                PrimeNativeCorpusReplaySourceBinding(
                    role: .corpusAndEmbeddedRegrader,
                    donorRelativePath:
                        "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift",
                    primeRelativePath:
                        "Sources/PrimeNativeCorpusReplayMechanics/ErgenticsPrimeNativeTextCorpus.swift",
                    gitBlobOID:
                        "b2a087c9410a71f2bc99debade752ff779d7a8a8",
                    byteCount: 177_032,
                    sha256:
                        "4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210",
                    policy: .byteExactPrimeSource
                ),
                PrimeNativeCorpusReplaySourceBinding(
                    role: .consensusSeedLineage,
                    donorRelativePath:
                        "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift",
                    primeRelativePath:
                        "Sources/PrimeNativeCorpusReplayMechanics/SeedBridge.swift",
                    gitBlobOID:
                        "027a25b49dde1acfb4cd8af970e05ecd8241f427",
                    byteCount: 216_815,
                    sha256:
                        "8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f",
                    policy: .explicitLiteralBridge
                ),
                PrimeNativeCorpusReplaySourceBinding(
                    role: .tokenizerRegression,
                    donorRelativePath:
                        "prime-runtime/Tests/ErgenticsPrimeRuntimeTests/PrimeNativeByteTokenizerTests.swift",
                    primeRelativePath: nil,
                    gitBlobOID:
                        "de1a53c1b6b28dd312afff001454f234d284243a",
                    byteCount: 9_297,
                    sha256:
                        "b526bb68ddfa77f15a0d0b729874debf4c92e1b86cbbd806d013dd1ac012dd4e",
                    policy: .lineageOnly
                ),
                PrimeNativeCorpusReplaySourceBinding(
                    role: .corpusRegression,
                    donorRelativePath:
                        "prime-runtime/Tests/ErgenticsPrimeRuntimeTests/ErgenticsPrimeNativeTextCorpusTests.swift",
                    primeRelativePath: nil,
                    gitBlobOID:
                        "e696a531b958ce1898f67b29568f0e7e9e9af805",
                    byteCount: 14_178,
                    sha256:
                        "00ab85797c1e6a4d1ed80fe009f6578a5c904a2d1c3717180e593a3dc84dd4ff",
                    policy: .lineageOnly
                ),
            ]
        )
    }

    func testManifestPinsAndFullReplayAggregatesAreExact()
        throws
    {
        let plan = PrimeNativeCorpusReplayPlan.frozenV1
        try plan.validate()

        XCTAssertEqual(
            plan.manifestPins,
            [
                PrimeNativeCorpusReplayManifestPin(
                    artifactID: "tokenizer_manifest",
                    donorRelativePath:
                        "content-staging/prime-native-byte-tokenizer-manifest.v1.json",
                    gitBlobOID:
                        "c2661016dd5a3af21fd6a998f286184ebdd7a196",
                    byteCount: 4_790,
                    artifactSHA256:
                        "5e3db93d26535cbb66b14f0170b1e04882aa942560af3c8b571d76dfaaa9f302",
                    internalManifestSHA256:
                        "f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7"
                ),
                PrimeNativeCorpusReplayManifestPin(
                    artifactID: "corpus_manifest",
                    donorRelativePath:
                        "content-staging/prime-native-text-corpus-manifest.v1.json",
                    gitBlobOID:
                        "a01344ad4105d755cfd97324092b15a1b31dc542",
                    byteCount: 44_803,
                    artifactSHA256:
                        "fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031",
                    internalManifestSHA256:
                        "7f42e6f0504e3751fca24bcce35f17fa361b4efcbd577f679fff7577f3e98ba7"
                ),
            ]
        )
        XCTAssertEqual(plan.expectedSplitCount, 8)
        XCTAssertEqual(
            plan.splitOrder,
            [
                "train",
                "refusal_train",
                "validation",
                "refusal_validation",
                "combination_holdout",
                "ood",
                "mutation",
                "abstention",
            ]
        )
        XCTAssertEqual(plan.expectedRowCount, 155_648)
        XCTAssertEqual(
            plan.expectedTokenInstanceCount,
            38_506_757
        )
        XCTAssertEqual(
            plan.expectedOrderedCorpusRowsSHA256,
            "db7c62b9f1297c5b4fe020053548d1fdc46fde69b37cf59d4d822d01d0c1fb65"
        )
        XCTAssertEqual(
            plan.expectedFalsifierSHA256,
            "95d3241959b02b4a4cc57aa824078150f3059811f2e7745d84b7e8e16d3e104a"
        )
        XCTAssertEqual(
            plan.expectedObservationSHA256,
            "520b9669d61d414463cccde512d39f9d631fae1ef6f44062aaf940e72f35fcb1"
        )
        XCTAssertTrue(
            plan.authorityStatement.contains(
                "Swift-owned corpus/regrade-authority gate"
            )
        )
        XCTAssertTrue(
            plan.authorityStatement.contains(
                "fixed /usr/bin/git source-state observer is mechanics-only and is not scientific authority"
            )
        )
    }

    func testSeedBridgeIsExactlyTheEvaluationContractTriad()
        throws
    {
        try PrimeNativeEvaluationContract
            .frozenV1.validateFrozenV1()
        try PrimeNativeCorpusReplayPlan
            .frozenV1.validate()

        let expected =
            PrimeNativeEvaluationContract
            .frozenV1.multiSeedConsensusSeeds
        XCTAssertEqual(expected, [1_618, 2_718, 3_141])
        XCTAssertEqual(
            PrimeNativeCorpusReplayPlan
                .frozenV1.consensusSeeds,
            expected
        )
        XCTAssertEqual(
            ErgenticsNativeLanguageCanary
                .frozenSeeds,
            expected
        )
    }

    func testFrozenObservationBindsEverySplitWithoutRunningFullReplay()
        throws
    {
        let frozen =
            PrimeNativeCorpusReplayObservation.frozenV1
        try frozen.validateFrozen()
        let expected: [
            String: (
                rows: Int,
                tokens: Int,
                hashes: [String]
            )
        ] = [
            "train": (
                131_072,
                31_138_522,
                [
                    "c03b316f571f101ca45b75c440c83b6b0a264f9ced73ba96a61bbaf65a9e9813",
                    "248461a1bd27fd289df677ec98e0fe13bcf94df8be7affec72345752c8e02493",
                    "c1fa09804d89733aa818b51e9079d4fdea3002297d5e365c3541caf6304fb6a0",
                    "7e9694c6b8d62c6e77630389c24ed984816d891730cf693bcbdd8e2f6e3650ef",
                    "d7259ac8f558f574ecc75464f9f3678d3da2100abec5fc9404365dd9974f517f",
                    "82da3e4164bbab0a01d931b015f1d3cff41ad95c861fefc1f3cccc48ccafd906",
                ]
            ),
            "refusal_train": (
                4_096,
                1_008_508,
                [
                    "699dfe19924f09d15e3e0cd6fac1c511813d1223592a86b7a577095327011359",
                    "d37679915d36aa9fde3da88a737d988b59ef8326096a9ada46abb3bf537d3410",
                    "40599a219f4ee69dd1ae1e28ff9c8b74952b2605c12f6c4a1db9d293c4612c3d",
                    "f219ba49ede0247f16e58ce96800176ef664d5f35b93d81b77c492a7985d6c49",
                    "7ce0e2d87c0acf3192895bb297fdd1f2148fe56f23b0b5261152d2c4ca59ad3e",
                    "d85f3c36e37faafdabacc9d322ce805412aa4a57654c14e414d6c0ac386e20be",
                ]
            ),
            "validation": (
                4_096,
                1_086_090,
                [
                    "b113836b0f299acd60d9390948bb1cdc163478973a15953f05b7035e26ccf24b",
                    "8d1da3aa5923078f95cf4389364dba9e7554fd69afbf8807ffdb13f429a11f6b",
                    "34d7925a5f51f692d9c3803faf72f8e44024d458379187ef66d8419c4b772eb3",
                    "7f15781c4fcb5d6c79a0b6c41d0c08ef73cfba6e74d22a5e4d946ebfc19d5043",
                    "1944ef76a5754a7995cfd9d5bc0db163c06ab09c0ed99a3a0b8c952654aecd22",
                    "99c9eaec0aed1445a4193bf3511be75e1d20d491bf19af5332feb90d417d5a26",
                ]
            ),
            "refusal_validation": (
                2_048,
                594_403,
                [
                    "51482b1b7eb8bd0d4afeed7e153a7e866220778ba76d6521bcb59251a4cfc567",
                    "05f476eb53486f45241a871bd35ea3467de8ea9c39e7e18b4eaec3a15986272b",
                    "a83a624c4cbad88665bb3363dc8d30019ab168c59be19ac850bcbca89a6aca5d",
                    "592269ca87c03531602a980937ee01b01bf6ad27792dd2c76cdf941f6d73c1a1",
                    "7c63ccd5c8b717ed308e0547bac820123b891c476e79ad771eb8a6b6cefec675",
                    "4181e7fb1628a922bf3515afa49a4e95c41ac1db35ce85a1ad01749e7018572d",
                ]
            ),
            "combination_holdout": (
                4_096,
                1_205_827,
                [
                    "dc087b4ef26e7b43d86e3982a067f128abda150f456941509cca2ca60ccbe810",
                    "f1cfbeccf8daacbee95689fb46ee00395cada3d6dee3eafe6e838fca69dd4d4a",
                    "3bf449d7bd5131a91cd6445200642a0c9cc4ddc3970edcfaf13e53881e5a41ef",
                    "a10c3eb643d14f54f1c7a2a330fac3117bb0bf593fe2c6b34d6ff6b9a54cef44",
                    "fb9463d8f782e833253386d2d78108a120ee9c691e2434757a1885bb2f9e7f19",
                    "92f008acb09e94b2d30a0dc1283d323261072c47a4e6c1e1dc7bd041978e2732",
                ]
            ),
            "ood": (
                4_096,
                1_553_752,
                [
                    "5ec1b747579a985637c30ff6c880f50668eddd0203bec0f580f78f30fc3edeea",
                    "82f5c29dc6cb50c23a661838adf45157840aef0cdefae6a1eb82f56862c100db",
                    "58bff8b5be51d10d0004a5c5712472c1e5bcfdc635fb5c61757c3fdd1cda965c",
                    "1a52f78d5262280c94ea6872e210a1b0d6a99d26aead85eac7bdcef7873e78ef",
                    "d4f7c4a48dc9a0c4d7c1eccc0f448cca16d61844c71285783ef6f3697f3b0b92",
                    "0c8da4892e3cb7483886f2f48386680fa214f9c93da424057acd36df8e515f42",
                ]
            ),
            "mutation": (
                4_096,
                1_275_481,
                [
                    "5c7700ea8e52a61dcdb07b1b148c0993c2541b3e23c28801250ed08c2c6c9391",
                    "f2a043157e70725f91d9d1126f22ec2dbfc011c32650e778e41054b4b7e290b5",
                    "40f2411445180c15c8dea0005aaa906746fd0974c1a5b60d8390eb59c059fa94",
                    "c8cbfc219371f30de7f05d6deca46ad91429942c38b6203a5962d04e7e1231ef",
                    "e02be8198569d23fb222a12ab229c8105edcee984fd41294b4ae4f63deb611c3",
                    "150161a3c63194e1ad3807dd8692b51431aca59ce1be68da3a229e7d1bed2199",
                ]
            ),
            "abstention": (
                2_048,
                644_174,
                [
                    "bd63a9592b03a5493de0b67036dce027031f239fa692f3d588272be807d7135f",
                    "17e999ba61f0380e6ae1f91b944b75f48537d36d425e916372d18aeb4f24b684",
                    "12dd719ebada4e1691d86324d55fc46e956acd283bea6ad4480150de8363a35e",
                    "9072066b3d6d85c771dcdc3ee8eb435e581e66957c033afce52c50a9e07122c9",
                    "59dd9308b4c3d9d273db74e106ce3babdf0da4e2a5b28cafff641283dcbd2637",
                    "604fcb2aa939a3a8fb932a33f8c4e5398d9d087e179d60186932f39237a8cee8",
                ]
            ),
        ]

        XCTAssertEqual(
            frozen.splitObservations.map(\.split),
            PrimeNativeCorpusReplayPlan
                .frozenV1.splitOrder
        )
        for split in frozen.splitObservations {
            let pinned = try XCTUnwrap(
                expected[split.split]
            )
            XCTAssertEqual(split.rowCount, pinned.rows)
            XCTAssertEqual(
                split.acceptedRowCount,
                pinned.rows
            )
            XCTAssertEqual(
                split.rawTokenInstances,
                pinned.tokens
            )
            XCTAssertEqual(
                [
                    split.orderedRowsSHA256,
                    split.orderedEvaluationRowsSHA256,
                    split.semanticSetSHA256,
                    split.promptSetSHA256,
                    split.sequenceSetSHA256,
                    split.freshRegradeSHA256,
                ],
                pinned.hashes
            )
        }
        XCTAssertEqual(frozen.fullRowCount, 155_648)
        XCTAssertEqual(frozen.acceptedRowCount, 155_648)
        XCTAssertEqual(
            frozen.rawTokenInstances,
            38_506_757
        )
        XCTAssertEqual(
            frozen.falsifierSummary.falsifierCount,
            10
        )
        XCTAssertEqual(
            frozen.falsifierSummary.detectedCount,
            10
        )
        XCTAssertEqual(
            frozen.leakageSummary
                .trainEvaluationPromptOverlapCount,
            0
        )
        XCTAssertEqual(
            frozen.leakageSummary
                .trainEvaluationSemanticOverlapCount,
            0
        )
        XCTAssertEqual(
            frozen.leakageSummary
                .refusalTrainAbstentionContractOverlapCount,
            0
        )
        XCTAssertTrue(
            frozen.refusalSummary.allReasonsTaught
        )
        XCTAssertTrue(
            frozen.refusalSummary
                .allTuningAndEvaluationContractsHeldOut
        )
        XCTAssertTrue(
            frozen.refusalSummary
                .allRowsAcceptedByFreshRegrade
        )
    }

    func testCandidateIsExplicitlyIncompleteAndNotAReceiptOrPass()
        throws
    {
        let state = try JSONDecoder().decode(
            PrimeNativeCorpusReplaySourceState.self,
            from: Data(
                """
                {
                  "remote_url": "https://github.com/Ergentics/ergentics-prime.git",
                  "revision": "1111111111111111111111111111111111111111",
                  "tree_oid": "2222222222222222222222222222222222222222",
                  "clean": true
                }
                """.utf8
            )
        )
        let binding = PrimeArtifactBinding(
            relativePath: "evidence.json",
            sha256: String(repeating: "a", count: 64),
            byteCount: 1,
            purpose: .immutableData
        )
        let candidate = PrimeNativeCorpusReplayCandidate(
            planSHA256:
                String(repeating: "b", count: 64),
            probeProcessIdentifier: 101,
            preSourceState: state,
            postSourceState: state,
            sourceSnapshot: binding,
            probeExecutable: binding,
            tokenizerManifest: binding,
            corpusManifest: binding,
            probeObservation: binding
        )

        XCTAssertFalse(candidate.receiptPublished)
        XCTAssertEqual(
            candidate.probeProcessIdentifier,
            101
        )
        XCTAssertFalse(
            candidate.artifactKind.contains("receipt")
        )
        XCTAssertTrue(
            candidate.authorityStatement.contains(
                "incomplete without the fresh Release verifier and final receipt"
            )
        )
        XCTAssertTrue(
            candidate.authorityStatement.contains(
                "not a PASS receipt"
            )
        )

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: PrimeCanonicalJSON.encode(
                    candidate
                )
            ) as? [String: Any]
        )
        XCTAssertNil(object["outcome"])
        XCTAssertEqual(
            object["receipt_published"] as? Bool,
            false
        )
    }

    func testFrozenObservationRejectsAggregateAndNonclaimMutations()
        throws
    {
        let data = try PrimeCanonicalJSON.encode(
            PrimeNativeCorpusReplayObservation.frozenV1
        )
        let base = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )
        var mutations = [[String: Any]]()

        var count = base
        count["full_row_count"] = 155_647
        mutations.append(count)

        var seeds = base
        seeds["consensus_seeds"] = [
            2_718,
            1_618,
            3_141,
        ]
        mutations.append(seeds)

        var independence = base
        independence[
            "algorithmically_independent_semantic_oracle"
        ] = true
        mutations.append(independence)

        var splitOrder = base
        splitOrder["split_observations"] =
            Array(
                try XCTUnwrap(
                    base["split_observations"]
                        as? [[String: Any]]
                ).reversed()
            )
        mutations.append(splitOrder)

        var splitCount = base
        var splitValues = try XCTUnwrap(
            splitCount["split_observations"]
                as? [[String: Any]]
        )
        splitValues[0]["accepted_row_count"] =
            131_071
        splitCount["split_observations"] = splitValues
        mutations.append(splitCount)

        var leakage = base
        var leakageValue = try XCTUnwrap(
            leakage["leakage_summary"]
                as? [String: Any]
        )
        leakageValue[
            "train_evaluation_prompt_overlap_count"
        ] = 1
        leakage["leakage_summary"] = leakageValue
        mutations.append(leakage)

        var refusal = base
        var refusalValue = try XCTUnwrap(
            refusal["refusal_summary"]
                as? [String: Any]
        )
        refusalValue["all_reasons_taught"] = false
        refusal["refusal_summary"] = refusalValue
        mutations.append(refusal)

        var falsifier = base
        var falsifierValue = try XCTUnwrap(
            falsifier["falsifier_summary"]
                as? [String: Any]
        )
        falsifierValue["detected_count"] = 9
        falsifier["falsifier_summary"] =
            falsifierValue
        mutations.append(falsifier)

        for mutation in mutations {
            let mutated = try JSONDecoder().decode(
                PrimeNativeCorpusReplayObservation
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try mutated.validateFrozen()
            )
        }
    }

    func testFrozenPlanRejectsSourceCountOrderAndAuthorityMutations()
        throws
    {
        let data = try PrimeCanonicalJSON.encode(
            PrimeNativeCorpusReplayPlan.frozenV1
        )
        let base = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )
        var mutations = [[String: Any]]()

        var count = base
        count["expected_row_count"] = 155_647
        mutations.append(count)

        var observationHash = base
        observationHash[
            "expected_observation_sha256"
        ] = String(repeating: "0", count: 64)
        mutations.append(observationHash)

        var splitOrder = base
        splitOrder["split_order"] = [
            "refusal_train",
            "train",
            "validation",
            "refusal_validation",
            "combination_holdout",
            "ood",
            "mutation",
            "abstention",
        ]
        mutations.append(splitOrder)

        var model = base
        model["model_execution_authorized"] = true
        mutations.append(model)

        var shards = base
        shards["full_rows_published"] = true
        mutations.append(shards)

        var source = base
        var sources = try XCTUnwrap(
            source["source_bindings"]
                as? [[String: Any]]
        )
        sources[0]["sha256"] =
            String(repeating: "0", count: 64)
        source["source_bindings"] = sources
        mutations.append(source)

        for mutation in mutations {
            let mutated = try JSONDecoder().decode(
                PrimeNativeCorpusReplayPlan.self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try mutated.validate()
            )
        }
    }

    func testReceiptKeepsEveryNonclaimAndSameImplementationLimit()
        throws
    {
        let binding = PrimeArtifactBinding(
            relativePath: "evidence.json",
            sha256: String(repeating: "a", count: 64),
            byteCount: 1,
            purpose: .immutableData
        )
        let receipt = PrimeNativeCorpusReplayReceipt(
            planSHA256:
                String(repeating: "b", count: 64),
            primeSourceRevision:
                String(repeating: "c", count: 40),
            primeSourceTreeOID:
                String(repeating: "d", count: 40),
            probeProcessIdentifier: 101,
            verifierProcessIdentifier: 202,
            exactReplayObserved: true,
            candidate: binding,
            verifierExecutable: binding,
            verifierObservation: binding
        )

        XCTAssertTrue(
            receipt.sameImplementationSemanticEvaluator
        )
        XCTAssertEqual(
            receipt.probeProcessIdentifier,
            101
        )
        XCTAssertEqual(
            receipt.verifierProcessIdentifier,
            202
        )
        XCTAssertTrue(receipt.freshProcessReplayExact)
        XCTAssertFalse(
            receipt.algorithmicallyIndependentSemanticOracle
        )
        XCTAssertFalse(
            receipt.independentScientificOracleClaimed
        )
        XCTAssertFalse(receipt.physicalRowShardsPublished)
        XCTAssertFalse(receipt.modelExecutionPerformed)
        XCTAssertFalse(receipt.neuralKitExecutionPerformed)
        XCTAssertFalse(receipt.functionalTrainingPerformed)
        XCTAssertFalse(receipt.quantizationPerformed)
        XCTAssertFalse(receipt.productUseAuthorized)
        XCTAssertFalse(
            receipt.pythonScientificAuthorityUsed
        )
        XCTAssertFalse(
            receipt.shellScientificAuthorityUsed
        )
        XCTAssertTrue(
            receipt.authorityStatement.contains(
                "same-implementation semantic regrade"
            )
        )
        XCTAssertTrue(
            receipt.authorityStatement.contains(
                "not an algorithmically independent scientific oracle"
            )
        )
    }

    func testFreshProcessWitnessRequiresPositiveDistinctIdentifiersAndExactReplay()
        throws
    {
        let binding = PrimeArtifactBinding(
            relativePath: "evidence.json",
            sha256: String(repeating: "a", count: 64),
            byteCount: 1,
            purpose: .immutableData
        )

        func receipt(
            probe: Int32,
            verifier: Int32,
            exact: Bool
        ) -> PrimeNativeCorpusReplayReceipt {
            PrimeNativeCorpusReplayReceipt(
                planSHA256:
                    String(repeating: "b", count: 64),
                primeSourceRevision:
                    String(repeating: "c", count: 40),
                primeSourceTreeOID:
                    String(repeating: "d", count: 40),
                probeProcessIdentifier: probe,
                verifierProcessIdentifier: verifier,
                exactReplayObserved: exact,
                candidate: binding,
                verifierExecutable: binding,
                verifierObservation: binding
            )
        }

        XCTAssertTrue(
            receipt(
                probe: 101,
                verifier: 202,
                exact: true
            ).freshProcessReplayExact
        )
        XCTAssertFalse(
            receipt(
                probe: 101,
                verifier: 101,
                exact: true
            ).freshProcessReplayExact
        )
        XCTAssertFalse(
            receipt(
                probe: 0,
                verifier: 202,
                exact: true
            ).freshProcessReplayExact
        )
        XCTAssertFalse(
            receipt(
                probe: 101,
                verifier: 202,
                exact: false
            ).freshProcessReplayExact
        )

        XCTAssertNoThrow(
            try PrimeNativeCorpusReplayOverlay
                .requireDistinctProcessIdentifiers(
                    probe: 101,
                    verifier: 202
                )
        )
        for pair: (Int32, Int32) in [
            (101, 101),
            (0, 202),
            (101, 0),
        ] {
            XCTAssertThrowsError(
                try PrimeNativeCorpusReplayOverlay
                    .requireDistinctProcessIdentifiers(
                        probe: pair.0,
                        verifier: pair.1
                    )
            ) { error in
                XCTAssertEqual(
                    error as? PrimeNativeCorpusReplayError,
                    .replayMismatch(
                        "probe and verifier process identifiers must be positive and distinct"
                    )
                )
            }
        }
    }

    func testArgumentParserAcceptsOnlyCanonicalPrimeAndArtifactRoots()
        throws
    {
        let temporary = FileManager.default
            .temporaryDirectory
            .resolvingSymlinksInPath()
            .appendingPathComponent(
                "prime-corpus-arguments-\(UUID().uuidString)",
                isDirectory: true
            )
        let prime = temporary.appendingPathComponent(
            "prime",
            isDirectory: true
        )
        let artifact = prime
            .appendingPathComponent(
                "artifacts",
                isDirectory: true
            )
            .appendingPathComponent(
                "run",
                isDirectory: true
            )
        let outside = temporary.appendingPathComponent(
            "outside",
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: artifact,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: outside,
            withIntermediateDirectories: true
        )
        defer {
            try? FileManager.default.removeItem(
                at: temporary
            )
        }

        let parsed = try PrimeNativeCorpusReplayArguments
            .parse([
                "PrimeNativeCorpusReplayProbe",
                "--artifact-root",
                artifact.path,
                "--prime-root",
                prime.path,
            ])
        XCTAssertEqual(parsed.primeRoot.path, prime.path)
        XCTAssertEqual(
            parsed.artifactRoot.path,
            artifact.path
        )

        let rejected: [[String]] = [
            ["probe"],
            [
                "probe",
                "--prime-root",
                prime.path,
            ],
            [
                "probe",
                "--prime-root",
                prime.path,
                "--artifact-root",
                outside.path,
            ],
            [
                "probe",
                "--prime-root",
                prime.path,
                "--artifact-root",
                artifact.path,
                "--seed",
                prime.path,
            ],
            [
                "probe",
                "--prime-root",
                prime.path,
                "--prime-root",
                prime.path,
                "--artifact-root",
                artifact.path,
            ],
            [
                "probe",
                "--prime-root",
                "relative",
                "--artifact-root",
                artifact.path,
            ],
        ]
        for arguments in rejected {
            XCTAssertThrowsError(
                try PrimeNativeCorpusReplayArguments
                    .parse(arguments),
                "authority-expanding or incomplete arguments were admitted: \(arguments)"
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
