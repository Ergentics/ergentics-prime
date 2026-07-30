import Foundation
import PrimeCore

public enum PrimeNativeCorpusReplayError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidPlan(String)
    case invalidObservation(String)
    case invalidCandidate(String)
    case invalidReceipt(String)
    case sourceTransplantMismatch(String)
    case replayMismatch(String)

    public var errorDescription: String? {
        switch self {
        case let .invalidPlan(detail):
            "native corpus replay plan is invalid: \(detail)"
        case let .invalidObservation(detail):
            "native corpus replay observation is invalid: \(detail)"
        case let .invalidCandidate(detail):
            "native corpus replay candidate is invalid: \(detail)"
        case let .invalidReceipt(detail):
            "native corpus replay receipt is invalid: \(detail)"
        case let .sourceTransplantMismatch(detail):
            "native corpus replay source transplant drifted: \(detail)"
        case let .replayMismatch(detail):
            "native corpus fresh-process replay diverged: \(detail)"
        }
    }
}

private enum PrimeNativeCorpusReplayHex {
    static func isLowercaseHex(
        _ value: String,
        byteCount: Int
    ) -> Bool {
        value.utf8.count == byteCount * 2
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }
}

public enum PrimeNativeCorpusReplaySourceRole:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case tokenizerMechanics =
        "tokenizer_mechanics"
    case corpusAndEmbeddedRegrader =
        "corpus_and_embedded_regrader"
    case consensusSeedLineage =
        "consensus_seed_lineage"
    case tokenizerRegression =
        "tokenizer_regression"
    case corpusRegression =
        "corpus_regression"
}

public enum PrimeNativeCorpusReplayTransplantPolicy:
    String,
    Codable,
    Equatable,
    Sendable
{
    case byteExactPrimeSource =
        "byte_exact_prime_source"
    case explicitLiteralBridge =
        "explicit_literal_bridge"
    case lineageOnly = "lineage_only"
}

public struct PrimeNativeCorpusReplaySourceBinding:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeNativeCorpusReplaySourceRole
    public let donorRelativePath: String
    public let primeRelativePath: String?
    public let gitBlobOID: String
    public let byteCount: UInt64
    public let sha256: String
    public let policy:
        PrimeNativeCorpusReplayTransplantPolicy

    public init(
        role: PrimeNativeCorpusReplaySourceRole,
        donorRelativePath: String,
        primeRelativePath: String?,
        gitBlobOID: String,
        byteCount: UInt64,
        sha256: String,
        policy:
            PrimeNativeCorpusReplayTransplantPolicy
    ) {
        self.role = role
        self.donorRelativePath = donorRelativePath
        self.primeRelativePath = primeRelativePath
        self.gitBlobOID = gitBlobOID
        self.byteCount = byteCount
        self.sha256 = sha256
        self.policy = policy
    }

    public func validate() throws {
        guard Self.safeRelativePath(
                  donorRelativePath
              ),
              primeRelativePath.map(
                  Self.safeRelativePath
              ) ?? true,
              PrimeNativeCorpusReplayHex
                .isLowercaseHex(
                    gitBlobOID,
                    byteCount: 20
                ),
              byteCount > 0,
              PrimeNativeCorpusReplayHex
                .isLowercaseHex(
                    sha256,
                    byteCount: 32
                ),
              (policy
                  == .byteExactPrimeSource
                  ? primeRelativePath != nil
                  : true),
              (policy == .lineageOnly
                  ? primeRelativePath == nil
                  : true)
        else {
            throw PrimeNativeCorpusReplayError
                .invalidPlan(role.rawValue)
        }
    }

    private static func safeRelativePath(
        _ value: String
    ) -> Bool {
        guard !value.isEmpty,
              !value.hasPrefix("/"),
              !value.contains("\0")
        else {
            return false
        }
        return value.split(
            separator: "/",
            omittingEmptySubsequences: false
        ).allSatisfy {
            !$0.isEmpty && $0 != "." && $0 != ".."
        }
    }

    private enum CodingKeys: String, CodingKey {
        case role
        case donorRelativePath =
            "donor_relative_path"
        case primeRelativePath =
            "prime_relative_path"
        case gitBlobOID = "git_blob_oid"
        case byteCount = "byte_count"
        case sha256
        case policy
    }
}

public struct PrimeNativeCorpusReplayManifestPin:
    Codable,
    Equatable,
    Sendable
{
    public let artifactID: String
    public let donorRelativePath: String
    public let gitBlobOID: String
    public let byteCount: UInt64
    public let artifactSHA256: String
    public let internalManifestSHA256: String

    public init(
        artifactID: String,
        donorRelativePath: String,
        gitBlobOID: String,
        byteCount: UInt64,
        artifactSHA256: String,
        internalManifestSHA256: String
    ) {
        self.artifactID = artifactID
        self.donorRelativePath = donorRelativePath
        self.gitBlobOID = gitBlobOID
        self.byteCount = byteCount
        self.artifactSHA256 = artifactSHA256
        self.internalManifestSHA256 =
            internalManifestSHA256
    }

    public func validate() throws {
        guard !artifactID.isEmpty,
              !donorRelativePath.hasPrefix("/"),
              !donorRelativePath.contains(".."),
              PrimeNativeCorpusReplayHex
                .isLowercaseHex(
                    gitBlobOID,
                    byteCount: 20
                ),
              byteCount > 0,
              PrimeNativeCorpusReplayHex
                .isLowercaseHex(
                    artifactSHA256,
                    byteCount: 32
                ),
              PrimeNativeCorpusReplayHex
                .isLowercaseHex(
                    internalManifestSHA256,
                    byteCount: 32
                )
        else {
            throw PrimeNativeCorpusReplayError
                .invalidPlan(artifactID)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case artifactID = "artifact_id"
        case donorRelativePath =
            "donor_relative_path"
        case gitBlobOID = "git_blob_oid"
        case byteCount = "byte_count"
        case artifactSHA256 =
            "artifact_sha256"
        case internalManifestSHA256 =
            "internal_manifest_sha256"
    }
}

public struct PrimeNativeCorpusReplayPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let planID: String
    public let claimScope: String
    public let companionRepository: String
    public let companionRemoteURL: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let sourceBindings:
        [PrimeNativeCorpusReplaySourceBinding]
    public let manifestPins:
        [PrimeNativeCorpusReplayManifestPin]
    public let consensusSeeds: [Int]
    public let splitOrder: [String]
    public let expectedSplitCount: Int
    public let expectedRowCount: Int
    public let expectedTokenInstanceCount: Int
    public let expectedOrderedCorpusRowsSHA256:
        String
    public let expectedFalsifierSHA256: String
    public let expectedObservationSHA256:
        String
    public let sourceSnapshotPath: String
    public let probeExecutablePath: String
    public let verifierExecutablePath: String
    public let tokenizerManifestPath: String
    public let corpusManifestPath: String
    public let probeObservationPath: String
    public let candidatePath: String
    public let verifierObservationPath: String
    public let receiptPath: String
    public let fullRowsPublished: Bool
    public let sameImplementationSemanticEvaluator:
        Bool
    public let algorithmicallyIndependentSemanticOracle:
        Bool
    public let modelExecutionAuthorized: Bool
    public let neuralKitExecutionAuthorized: Bool
    public let functionalTrainingAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let pythonExecutionAuthorized: Bool
    public let shellScientificAuthorityAuthorized:
        Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        planID:
            "ergentics_prime_source_pinned_full_swift_corpus_transplant_replay_v1",
        claimScope:
            "source_pinned_full_swift_corpus_generator_transplant_replay_only",
        companionRepository:
            "Ergentics/pmhnp-companion-ergentics",
        companionRemoteURL:
            "https://github.com/Ergentics/pmhnp-companion-ergentics.git",
        companionRevision:
            "163fc100710ece48119bc25954452d10f6a84f7f",
        companionTreeOID:
            "9009daa4f8a07fbd5897e00b9571cef44ec292db",
        sourceBindings: [
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
        ],
        manifestPins: [
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
        ],
        consensusSeeds: [
            1_618,
            2_718,
            3_141,
        ],
        splitOrder: [
            "train",
            "refusal_train",
            "validation",
            "refusal_validation",
            "combination_holdout",
            "ood",
            "mutation",
            "abstention",
        ],
        expectedSplitCount: 8,
        expectedRowCount: 155_648,
        expectedTokenInstanceCount:
            38_506_757,
        expectedOrderedCorpusRowsSHA256:
            "db7c62b9f1297c5b4fe020053548d1fdc46fde69b37cf59d4d822d01d0c1fb65",
        expectedFalsifierSHA256:
            "95d3241959b02b4a4cc57aa824078150f3059811f2e7745d84b7e8e16d3e104a",
        expectedObservationSHA256:
            "520b9669d61d414463cccde512d39f9d631fae1ef6f44062aaf940e72f35fcb1",
        sourceSnapshotPath:
            "source/prime-swift-source-snapshot.v1.json",
        probeExecutablePath:
            "bin/PrimeNativeCorpusReplayProbe",
        verifierExecutablePath:
            "bin/PrimeNativeCorpusReplayVerifier",
        tokenizerManifestPath:
            "corpus-replay/prime-native-byte-tokenizer-manifest.v1.json",
        corpusManifestPath:
            "corpus-replay/prime-native-text-corpus-manifest.v1.json",
        probeObservationPath:
            "corpus-replay/probe-observation.v1.json",
        candidatePath:
            "corpus-replay/probe-candidate.v1.json",
        verifierObservationPath:
            "corpus-replay/verifier-observation.v1.json",
        receiptPath:
            "prime-native-full-corpus-replay-receipt.v1.json",
        fullRowsPublished: false,
        sameImplementationSemanticEvaluator:
            true,
        algorithmicallyIndependentSemanticOracle:
            false,
        modelExecutionAuthorized: false,
        neuralKitExecutionAuthorized: false,
        functionalTrainingAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        pythonExecutionAuthorized: false,
        shellScientificAuthorityAuthorized:
            false,
        authorityStatement:
            "This Swift-owned corpus/regrade-authority gate transplants the exact pinned tokenizer and corpus source blobs into an isolated Prime target, replaces the corpus blob's hidden broad-canary dependency with an explicit three-seed bridge, regenerates all eight splits and all 155,648 rows, compares every declared aggregate against frozen donor goldens, and reruns the embedded text regrader for every row in distinct Release probe and verifier processes whose positive process identifiers are receipt-bound. The donor manifest's companion implementation path remains historical lineage while Prime source snapshots and executables bind actual execution. The fixed /usr/bin/git source-state observer is mechanics-only and is not scientific authority. The embedded parser shares evaluator structs with generation, so this is a same-implementation semantic regrade and not an algorithmically independent scientific oracle. It publishes deterministic aggregates rather than physical row shards and does not execute a model or NeuralKit, train, quantize, use Python as authority, or authorize product use."
    )

    public static let requiredPrimeSourcePaths:
        Set<String> = [
            "Package.swift",
            "Sources/PrimeCore/PrimeDurableArtifacts.swift",
            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
            "Sources/PrimeCore/PrimeNativeGitBlobTransport.swift",
            "Sources/PrimeCore/PrimeSecureRunningExecutableCapture.swift",
            "Sources/PrimeCore/PrimeSwiftSourceProvenance.swift",
            "Sources/PrimeNativeCorpusReplayMechanics/PrimeNativeByteTokenizer.swift",
            "Sources/PrimeNativeCorpusReplayMechanics/ErgenticsPrimeNativeTextCorpus.swift",
            "Sources/PrimeNativeCorpusReplayMechanics/SeedBridge.swift",
            "Sources/PrimeNativeCorpusReplayMechanics/PrimeNativeCorpusReplayObservation.swift",
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayContract.swift",
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayArguments.swift",
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayOverlay.swift",
            "Sources/PrimeNativeCorpusReplayProbe/PrimeNativeCorpusReplayProbeMain.swift",
            "Sources/PrimeNativeCorpusReplayVerifier/PrimeNativeCorpusReplayVerifierMain.swift",
        ]

    public func validate() throws {
        let sourceRoles = sourceBindings.map(\.role)
        let pinIDs = manifestPins.map(\.artifactID)
        guard self == Self.frozenV1,
              schemaVersion == 1,
              sourceRoles
                == PrimeNativeCorpusReplaySourceRole
                .allCases,
              Set(sourceRoles).count
                == sourceRoles.count,
              pinIDs
                == [
                    "tokenizer_manifest",
                    "corpus_manifest",
                ],
              Set(pinIDs).count == pinIDs.count,
              consensusSeeds
                == PrimeNativeEvaluationContract
                .frozenV1
                .multiSeedConsensusSeeds,
              Set(consensusSeeds).count
                == consensusSeeds.count,
              splitOrder.count == expectedSplitCount,
              Set(splitOrder).count == splitOrder.count,
              expectedRowCount == 155_648,
              expectedTokenInstanceCount
                == 38_506_757,
              PrimeNativeCorpusReplayHex
                .isLowercaseHex(
                    expectedOrderedCorpusRowsSHA256,
                    byteCount: 32
                ),
              PrimeNativeCorpusReplayHex
                .isLowercaseHex(
                    expectedFalsifierSHA256,
                    byteCount: 32
                ),
              PrimeNativeCorpusReplayHex
                .isLowercaseHex(
                    expectedObservationSHA256,
                    byteCount: 32
                ),
              !fullRowsPublished,
              sameImplementationSemanticEvaluator,
              !algorithmicallyIndependentSemanticOracle,
              !modelExecutionAuthorized,
              !neuralKitExecutionAuthorized,
              !functionalTrainingAuthorized,
              !quantizationAuthorized,
              !productUseAuthorized,
              !pythonExecutionAuthorized,
              !shellScientificAuthorityAuthorized,
              authorityStatement.contains(
                  "Swift-owned corpus/regrade-authority gate"
              ),
              authorityStatement.contains(
                  "fixed /usr/bin/git source-state observer is mechanics-only and is not scientific authority"
              ),
              authorityStatement.contains(
                  "same-implementation semantic regrade"
              ),
              authorityStatement.contains(
                  "not an algorithmically independent scientific oracle"
              )
        else {
            throw PrimeNativeCorpusReplayError
                .invalidPlan("frozen contract")
        }
        try sourceBindings.forEach {
            try $0.validate()
        }
        try manifestPins.forEach {
            try $0.validate()
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(self)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case planID = "plan_id"
        case claimScope = "claim_scope"
        case companionRepository =
            "companion_repository"
        case companionRemoteURL =
            "companion_remote_url"
        case companionRevision =
            "companion_revision"
        case companionTreeOID =
            "companion_tree_oid"
        case sourceBindings = "source_bindings"
        case manifestPins = "manifest_pins"
        case consensusSeeds = "consensus_seeds"
        case splitOrder = "split_order"
        case expectedSplitCount =
            "expected_split_count"
        case expectedRowCount =
            "expected_row_count"
        case expectedTokenInstanceCount =
            "expected_token_instance_count"
        case expectedOrderedCorpusRowsSHA256 =
            "expected_ordered_corpus_rows_sha256"
        case expectedFalsifierSHA256 =
            "expected_falsifier_sha256"
        case expectedObservationSHA256 =
            "expected_observation_sha256"
        case sourceSnapshotPath =
            "source_snapshot_path"
        case probeExecutablePath =
            "probe_executable_path"
        case verifierExecutablePath =
            "verifier_executable_path"
        case tokenizerManifestPath =
            "tokenizer_manifest_path"
        case corpusManifestPath =
            "corpus_manifest_path"
        case probeObservationPath =
            "probe_observation_path"
        case candidatePath = "candidate_path"
        case verifierObservationPath =
            "verifier_observation_path"
        case receiptPath = "receipt_path"
        case fullRowsPublished =
            "full_rows_published"
        case sameImplementationSemanticEvaluator =
            "same_implementation_semantic_evaluator"
        case algorithmicallyIndependentSemanticOracle =
            "algorithmically_independent_semantic_oracle"
        case modelExecutionAuthorized =
            "model_execution_authorized"
        case neuralKitExecutionAuthorized =
            "neural_kit_execution_authorized"
        case functionalTrainingAuthorized =
            "functional_training_authorized"
        case quantizationAuthorized =
            "quantization_authorized"
        case productUseAuthorized =
            "product_use_authorized"
        case pythonExecutionAuthorized =
            "python_execution_authorized"
        case shellScientificAuthorityAuthorized =
            "shell_scientific_authority_authorized"
        case authorityStatement =
            "authority_statement"
    }
}

public struct PrimeNativeCorpusReplaySourceState:
    Codable,
    Equatable,
    Sendable
{
    public let remoteURL: String
    public let revision: String
    public let treeOID: String
    public let clean: Bool

    public init(
        _ state:
            PrimeNativeMigrationResolverSourceState
    ) {
        remoteURL = state.remoteURL
        revision = state.revision
        treeOID = state.treeOID
        clean = state.clean
    }

    private enum CodingKeys: String, CodingKey {
        case remoteURL = "remote_url"
        case revision
        case treeOID = "tree_oid"
        case clean
    }
}

public struct PrimeNativeCorpusReplayCandidate:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let claimScope: String
    public let planSHA256: String
    public let probeProcessIdentifier: Int32
    public let preSourceState:
        PrimeNativeCorpusReplaySourceState
    public let postSourceState:
        PrimeNativeCorpusReplaySourceState
    public let sourceSnapshot:
        PrimeArtifactBinding
    public let probeExecutable:
        PrimeArtifactBinding
    public let tokenizerManifest:
        PrimeArtifactBinding
    public let corpusManifest:
        PrimeArtifactBinding
    public let probeObservation:
        PrimeArtifactBinding
    public let receiptPublished: Bool
    public let authorityStatement: String

    public init(
        planSHA256: String,
        probeProcessIdentifier: Int32,
        preSourceState:
            PrimeNativeCorpusReplaySourceState,
        postSourceState:
            PrimeNativeCorpusReplaySourceState,
        sourceSnapshot: PrimeArtifactBinding,
        probeExecutable: PrimeArtifactBinding,
        tokenizerManifest:
            PrimeArtifactBinding,
        corpusManifest: PrimeArtifactBinding,
        probeObservation: PrimeArtifactBinding
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_full_corpus_replay_candidate"
        claimScope =
            PrimeNativeCorpusReplayPlan
            .frozenV1.claimScope
        self.planSHA256 = planSHA256
        self.probeProcessIdentifier =
            probeProcessIdentifier
        self.preSourceState = preSourceState
        self.postSourceState = postSourceState
        self.sourceSnapshot = sourceSnapshot
        self.probeExecutable = probeExecutable
        self.tokenizerManifest =
            tokenizerManifest
        self.corpusManifest = corpusManifest
        self.probeObservation =
            probeObservation
        receiptPublished = false
        authorityStatement =
            "This immutable probe candidate binds the positive probe process identifier and is incomplete without the fresh Release verifier and final receipt; that verifier must have a distinct positive process identifier. It is not a PASS receipt."
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case claimScope = "claim_scope"
        case planSHA256 = "plan_sha256"
        case probeProcessIdentifier =
            "probe_process_identifier"
        case preSourceState =
            "pre_source_state"
        case postSourceState =
            "post_source_state"
        case sourceSnapshot = "source_snapshot"
        case probeExecutable = "probe_executable"
        case tokenizerManifest =
            "tokenizer_manifest"
        case corpusManifest = "corpus_manifest"
        case probeObservation =
            "probe_observation"
        case receiptPublished =
            "receipt_published"
        case authorityStatement =
            "authority_statement"
    }
}

public enum PrimeNativeCorpusReplayOutcome:
    String,
    Codable,
    Equatable,
    Sendable
{
    case pass = "PASS"
}

public struct PrimeNativeCorpusReplayReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let outcome:
        PrimeNativeCorpusReplayOutcome
    public let claimScope: String
    public let planSHA256: String
    public let primeSourceRevision: String
    public let primeSourceTreeOID: String
    public let probeProcessIdentifier: Int32
    public let verifierProcessIdentifier: Int32
    public let candidate: PrimeArtifactBinding
    public let verifierExecutable:
        PrimeArtifactBinding
    public let verifierObservation:
        PrimeArtifactBinding
    public let sourcePinsBound: Bool
    public let byteExactTransplantCount: Int
    public let seedBridgeBoundToEvaluationContract:
        Bool
    public let allEightSplitsRegenerated: Bool
    public let corpusRowsRegenerated: Bool
    public let regeneratedRowCount: Int
    public let corpusSemanticRegradePerformed:
        Bool
    public let regradedRowCount: Int
    public let freshProcessReplayExact: Bool
    public let deterministicAggregateEvidence:
        Bool
    public let physicalRowShardsPublished: Bool
    public let sameImplementationSemanticEvaluator:
        Bool
    public let algorithmicallyIndependentSemanticOracle:
        Bool
    public let independentScientificOracleClaimed:
        Bool
    public let modelExecutionPerformed: Bool
    public let neuralKitExecutionPerformed: Bool
    public let functionalTrainingPerformed: Bool
    public let quantizationPerformed: Bool
    public let productUseAuthorized: Bool
    public let pythonScientificAuthorityUsed: Bool
    public let shellScientificAuthorityUsed: Bool
    public let authorityStatement: String

    public init(
        planSHA256: String,
        primeSourceRevision: String,
        primeSourceTreeOID: String,
        probeProcessIdentifier: Int32,
        verifierProcessIdentifier: Int32,
        exactReplayObserved: Bool,
        candidate: PrimeArtifactBinding,
        verifierExecutable:
            PrimeArtifactBinding,
        verifierObservation:
            PrimeArtifactBinding
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_full_corpus_replay_receipt"
        outcome = .pass
        claimScope =
            PrimeNativeCorpusReplayPlan
            .frozenV1.claimScope
        self.planSHA256 = planSHA256
        self.primeSourceRevision =
            primeSourceRevision
        self.primeSourceTreeOID =
            primeSourceTreeOID
        self.probeProcessIdentifier =
            probeProcessIdentifier
        self.verifierProcessIdentifier =
            verifierProcessIdentifier
        self.candidate = candidate
        self.verifierExecutable =
            verifierExecutable
        self.verifierObservation =
            verifierObservation
        sourcePinsBound = true
        byteExactTransplantCount = 2
        seedBridgeBoundToEvaluationContract =
            true
        allEightSplitsRegenerated = true
        corpusRowsRegenerated = true
        regeneratedRowCount = 155_648
        corpusSemanticRegradePerformed = true
        regradedRowCount = 155_648
        freshProcessReplayExact =
            exactReplayObserved
                && probeProcessIdentifier > 0
                && verifierProcessIdentifier > 0
                && probeProcessIdentifier
                    != verifierProcessIdentifier
        deterministicAggregateEvidence = true
        physicalRowShardsPublished = false
        sameImplementationSemanticEvaluator =
            true
        algorithmicallyIndependentSemanticOracle =
            false
        independentScientificOracleClaimed =
            false
        modelExecutionPerformed = false
        neuralKitExecutionPerformed = false
        functionalTrainingPerformed = false
        quantizationPerformed = false
        productUseAuthorized = false
        pythonScientificAuthorityUsed = false
        shellScientificAuthorityUsed = false
        authorityStatement =
            PrimeNativeCorpusReplayPlan
            .frozenV1.authorityStatement
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case outcome
        case claimScope = "claim_scope"
        case planSHA256 = "plan_sha256"
        case primeSourceRevision =
            "prime_source_revision"
        case primeSourceTreeOID =
            "prime_source_tree_oid"
        case probeProcessIdentifier =
            "probe_process_identifier"
        case verifierProcessIdentifier =
            "verifier_process_identifier"
        case candidate
        case verifierExecutable =
            "verifier_executable"
        case verifierObservation =
            "verifier_observation"
        case sourcePinsBound =
            "source_pins_bound"
        case byteExactTransplantCount =
            "byte_exact_transplant_count"
        case seedBridgeBoundToEvaluationContract =
            "seed_bridge_bound_to_evaluation_contract"
        case allEightSplitsRegenerated =
            "all_eight_splits_regenerated"
        case corpusRowsRegenerated =
            "corpus_rows_regenerated"
        case regeneratedRowCount =
            "regenerated_row_count"
        case corpusSemanticRegradePerformed =
            "corpus_semantic_regrade_performed"
        case regradedRowCount =
            "regraded_row_count"
        case freshProcessReplayExact =
            "fresh_process_replay_exact"
        case deterministicAggregateEvidence =
            "deterministic_aggregate_evidence"
        case physicalRowShardsPublished =
            "physical_row_shards_published"
        case sameImplementationSemanticEvaluator =
            "same_implementation_semantic_evaluator"
        case algorithmicallyIndependentSemanticOracle =
            "algorithmically_independent_semantic_oracle"
        case independentScientificOracleClaimed =
            "independent_scientific_oracle_claimed"
        case modelExecutionPerformed =
            "model_execution_performed"
        case neuralKitExecutionPerformed =
            "neural_kit_execution_performed"
        case functionalTrainingPerformed =
            "functional_training_performed"
        case quantizationPerformed =
            "quantization_performed"
        case productUseAuthorized =
            "product_use_authorized"
        case pythonScientificAuthorityUsed =
            "python_scientific_authority_used"
        case shellScientificAuthorityUsed =
            "shell_scientific_authority_used"
        case authorityStatement =
            "authority_statement"
    }
}
