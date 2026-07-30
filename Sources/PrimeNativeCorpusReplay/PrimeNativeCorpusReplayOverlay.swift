import Foundation
import PrimeCore
import PrimeNativeCorpusReplayMechanics

private typealias HistoricalCorpus =
    PrimeNativeCorpusReplayMechanics
    .ErgenticsPrimeNativeTextCorpus
private typealias HistoricalTokenizer =
    PrimeNativeCorpusReplayMechanics
    .PrimeNativeByteTokenizer

public struct PrimeNativeCorpusReplayCandidateResult:
    Sendable
{
    public let candidate:
        PrimeNativeCorpusReplayCandidate
    public let candidateBinding:
        PrimeArtifactBinding
    public let observation:
        PrimeNativeCorpusReplayObservation
}

public struct PrimeNativeCorpusReplayReceiptResult:
    Sendable
{
    public let receipt:
        PrimeNativeCorpusReplayReceipt
    public let receiptBinding:
        PrimeArtifactBinding
    public let observation:
        PrimeNativeCorpusReplayObservation
}

/// Two-process, receipt-last publication for the exact corpus replay.
///
/// The probe can publish only an explicitly incomplete candidate. The
/// verifier alone can publish the final receipt after a complete second
/// materialization compares byte-exactly with the probe observation.
public enum PrimeNativeCorpusReplayOverlay {
    private static let maximumSnapshotBytes:
        UInt64 = 128 * 1024 * 1024
    private static let maximumExecutableBytes =
        PrimeSecureRunningExecutableCapture
        .maximumByteCount
    private static let maximumJSONBytes:
        UInt64 = 4 * 1024 * 1024
    private static let primeRemoteURL =
        "https://github.com/Ergentics/ergentics-prime.git"
    private static let
        canonicalHistorical20260730RequiredPrimeSourcePaths:
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

    public static func publishCandidate(
        primeSourceRoot: URL,
        to root: PrimeArtifactRoot
    ) throws -> PrimeNativeCorpusReplayCandidateResult {
        let plan = PrimeNativeCorpusReplayPlan.frozenV1
        try plan.validate()
        let probeProcessIdentifier =
            ProcessInfo.processInfo.processIdentifier
        guard probeProcessIdentifier > 0 else {
            throw PrimeNativeCorpusReplayError
                .invalidCandidate(
                    "probe process identifier is not positive"
                )
        }
        try root.requirePrivateRootMode()
        try root.requireEmpty()

        let transport = PrimeNativeGitBlobTransport()
        let preState = try transport.sourceState(
            repositoryRoot: primeSourceRoot,
            phase: .preSnapshot
        )
        try requireCleanSource(preState)

        let preSnapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: primeSourceRoot,
                requiredRelativePaths:
                    PrimeNativeCorpusReplayPlan
                    .requiredPrimeSourcePaths
            )
        try validateTransplants(in: preSnapshot)

        let executable =
            try PrimeSecureRunningExecutableCapture
            .data()
        let observation =
            try PrimeNativeCorpusReplayObservation
            .runAndValidate()
        guard try observation.contentSHA256()
                == plan.expectedObservationSHA256
        else {
            throw PrimeNativeCorpusReplayError
                .invalidObservation(
                    "canonical observation hash drifted"
                )
        }
        let tokenizerManifest =
            try PrimeNativeCorpusReplayObservation
            .prettyTokenizerManifestData()
        let corpusManifest =
            try PrimeNativeCorpusReplayObservation
            .prettyCorpusManifestData()
        try validateHistoricalManifests(
            tokenizerData: tokenizerManifest,
            corpusData: corpusManifest
        )

        let postSnapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: primeSourceRoot,
                requiredRelativePaths:
                    PrimeNativeCorpusReplayPlan
                    .requiredPrimeSourcePaths
            )
        guard postSnapshot == preSnapshot else {
            throw PrimeNativeCorpusReplayError
                .sourceTransplantMismatch(
                    "Prime source changed during probe replay"
                )
        }
        let postState = try transport.sourceState(
            repositoryRoot: primeSourceRoot,
            phase: .postExecutable
        )
        try requireStableSource(
            preState,
            postState
        )

        for directory in [
            "source",
            "bin",
            "corpus-replay",
        ] {
            try root.ensurePrivateDirectory(
                at: directory
            )
        }
        let sourceBinding =
            try root.publishCanonical(
                preSnapshot,
                at: plan.sourceSnapshotPath
            )
        let executableBinding = try root.publish(
            executable,
            at: plan.probeExecutablePath,
            purpose: .executable
        )
        let tokenizerBinding = try root.publish(
            tokenizerManifest,
            at: plan.tokenizerManifestPath,
            purpose: .immutableData
        )
        let corpusBinding = try root.publish(
            corpusManifest,
            at: plan.corpusManifestPath,
            purpose: .immutableData
        )
        let observationBinding =
            try root.publishCanonical(
                observation,
                at: plan.probeObservationPath
            )
        let candidate =
            PrimeNativeCorpusReplayCandidate(
                planSHA256:
                    try plan.contentSHA256(),
                probeProcessIdentifier:
                    probeProcessIdentifier,
                preSourceState:
                    PrimeNativeCorpusReplaySourceState(
                        preState
                    ),
                postSourceState:
                    PrimeNativeCorpusReplaySourceState(
                        postState
                    ),
                sourceSnapshot: sourceBinding,
                probeExecutable:
                    executableBinding,
                tokenizerManifest:
                    tokenizerBinding,
                corpusManifest: corpusBinding,
                probeObservation:
                    observationBinding
            )
        try validate(candidate, in: root)
        let candidateBinding =
            try root.publishCanonical(
                candidate,
                at: plan.candidatePath
            )
        let rebound = try root.bindExisting(
            at: plan.candidatePath,
            purpose: .immutableData,
            maximumByteCount: maximumJSONBytes
        )
        guard rebound == candidateBinding,
              try root.decodeVerified(
                  PrimeNativeCorpusReplayCandidate
                    .self,
                  binding: rebound,
                  maximumByteCount:
                    maximumJSONBytes
              ) == candidate
        else {
            throw PrimeNativeCorpusReplayError
                .invalidCandidate(
                    "candidate did not persist exactly"
                )
        }
        try root.requireAbsent(at: plan.receiptPath)
        return PrimeNativeCorpusReplayCandidateResult(
            candidate: candidate,
            candidateBinding: candidateBinding,
            observation: observation
        )
    }

    public static func verifyAndSeal(
        primeSourceRoot: URL,
        in root: PrimeArtifactRoot
    ) throws -> PrimeNativeCorpusReplayReceiptResult {
        let plan = PrimeNativeCorpusReplayPlan.frozenV1
        try plan.validate()
        let verifierProcessIdentifier =
            ProcessInfo.processInfo.processIdentifier
        try root.requirePrivateRootMode()
        try root.requireAbsent(
            at: plan.verifierExecutablePath
        )
        try root.requireAbsent(
            at: plan.verifierObservationPath
        )
        try root.requireAbsent(at: plan.receiptPath)

        let candidateBinding =
            try root.bindExisting(
                at: plan.candidatePath,
                purpose: .immutableData,
                maximumByteCount:
                    maximumJSONBytes
            )
        let candidate =
            try root.decodeVerified(
                PrimeNativeCorpusReplayCandidate
                    .self,
                binding: candidateBinding,
                maximumByteCount:
                    maximumJSONBytes
            )
        try requireDistinctProcessIdentifiers(
            probe: candidate.probeProcessIdentifier,
            verifier: verifierProcessIdentifier
        )
        try validate(candidate, in: root)

        let transport = PrimeNativeGitBlobTransport()
        let preState = try transport.sourceState(
            repositoryRoot: primeSourceRoot,
            phase: .preSnapshot
        )
        try requireCleanSource(preState)
        guard PrimeNativeCorpusReplaySourceState(
            preState
        ) == candidate.postSourceState else {
            throw PrimeNativeCorpusReplayError
                .replayMismatch(
                    "verifier source state differs from probe"
                )
        }

        let probeSnapshot =
            try root.decodeVerified(
                PrimeSwiftSourceSnapshot.self,
                binding: candidate.sourceSnapshot,
                maximumByteCount:
                    maximumSnapshotBytes
            )
        let verifierSnapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: primeSourceRoot,
                requiredRelativePaths:
                    PrimeNativeCorpusReplayPlan
                    .requiredPrimeSourcePaths
            )
        guard verifierSnapshot == probeSnapshot else {
            throw PrimeNativeCorpusReplayError
                .replayMismatch(
                    "verifier source snapshot differs from probe"
                )
        }

        let verifierExecutable =
            try PrimeSecureRunningExecutableCapture
            .data()
        let verifierExecutableBinding =
            try root.publish(
                verifierExecutable,
                at: plan.verifierExecutablePath,
                purpose: .executable
            )
        let observation =
            try PrimeNativeCorpusReplayObservation
            .runAndValidate()
        guard try observation.contentSHA256()
                == plan.expectedObservationSHA256
        else {
            throw PrimeNativeCorpusReplayError
                .invalidObservation(
                    "fresh verifier observation hash drifted"
                )
        }
        let probeObservation =
            try root.decodeVerified(
                PrimeNativeCorpusReplayObservation
                    .self,
                binding:
                    candidate.probeObservation,
                maximumByteCount:
                    maximumJSONBytes
            )
        try probeObservation.validateFrozen()
        let canonicalReplayExact =
            try observation.canonicalData()
                == probeObservation.canonicalData()
        let exactReplayObserved =
            observation == probeObservation
                && canonicalReplayExact
        guard exactReplayObserved
        else {
            throw PrimeNativeCorpusReplayError
                .replayMismatch(
                    "probe and verifier observations differ"
                )
        }

        let postSnapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: primeSourceRoot,
                requiredRelativePaths:
                    PrimeNativeCorpusReplayPlan
                    .requiredPrimeSourcePaths
            )
        guard postSnapshot == verifierSnapshot else {
            throw PrimeNativeCorpusReplayError
                .replayMismatch(
                    "Prime source changed during verifier replay"
                )
        }
        let postState = try transport.sourceState(
            repositoryRoot: primeSourceRoot,
            phase: .postExecutable
        )
        try requireStableSource(
            preState,
            postState
        )
        guard PrimeNativeCorpusReplaySourceState(
            postState
        ) == candidate.postSourceState else {
            throw PrimeNativeCorpusReplayError
                .replayMismatch(
                    "verifier closure source state differs from probe"
                )
        }

        let observationBinding =
            try root.publishCanonical(
                observation,
                at: plan.verifierObservationPath
            )
        let receipt = PrimeNativeCorpusReplayReceipt(
            planSHA256: try plan.contentSHA256(),
            primeSourceRevision:
                postState.revision,
            primeSourceTreeOID:
                postState.treeOID,
            probeProcessIdentifier:
                candidate.probeProcessIdentifier,
            verifierProcessIdentifier:
                verifierProcessIdentifier,
            exactReplayObserved:
                exactReplayObserved,
            candidate: candidateBinding,
            verifierExecutable:
                verifierExecutableBinding,
            verifierObservation:
                observationBinding
        )
        try validate(receipt, in: root)

        // Receipt publication is deliberately last.
        let receiptBinding =
            try root.publishCanonical(
                receipt,
                at: plan.receiptPath
            )
        let rebound = try root.bindExisting(
            at: plan.receiptPath,
            purpose: .immutableData,
            maximumByteCount: maximumJSONBytes
        )
        let persisted = try root.decodeVerified(
            PrimeNativeCorpusReplayReceipt.self,
            binding: rebound,
            maximumByteCount: maximumJSONBytes
        )
        guard rebound == receiptBinding,
              persisted == receipt else {
            throw PrimeNativeCorpusReplayError
                .invalidReceipt(
                    "receipt did not persist exactly"
                )
        }
        try validate(persisted, in: root)
        return PrimeNativeCorpusReplayReceiptResult(
            receipt: receipt,
            receiptBinding: receiptBinding,
            observation: observation
        )
    }

    public static func validate(
        _ candidate:
            PrimeNativeCorpusReplayCandidate,
        in root: PrimeArtifactRoot
    ) throws {
        try validate(
            candidate,
            in: root,
            historicalSourcePin: nil,
            requiredPrimeSourcePaths:
                PrimeNativeCorpusReplayPlan
                .requiredPrimeSourcePaths
        )
    }

    private static func validate(
        _ candidate:
            PrimeNativeCorpusReplayCandidate,
        in root: PrimeArtifactRoot,
        historicalSourcePin:
            PrimePinnedHistoricalReleaseSource?,
        requiredPrimeSourcePaths: Set<String>
    ) throws {
        let plan = PrimeNativeCorpusReplayPlan.frozenV1
        try plan.validate()
        let expected =
            PrimeNativeCorpusReplayCandidate(
                planSHA256:
                    try plan.contentSHA256(),
                probeProcessIdentifier:
                    candidate.probeProcessIdentifier,
                preSourceState:
                    candidate.preSourceState,
                postSourceState:
                    candidate.postSourceState,
                sourceSnapshot:
                    candidate.sourceSnapshot,
                probeExecutable:
                    candidate.probeExecutable,
                tokenizerManifest:
                    candidate.tokenizerManifest,
                corpusManifest:
                    candidate.corpusManifest,
                probeObservation:
                    candidate.probeObservation
            )
        guard candidate == expected,
              candidate.probeProcessIdentifier > 0,
              candidate.preSourceState
                == candidate.postSourceState,
              candidate.preSourceState.clean,
              candidate.preSourceState.remoteURL
                == primeRemoteURL,
              candidate.preSourceState
                .revision.utf8.count == 40,
              candidate.preSourceState
                .treeOID.utf8.count == 40,
              candidate.sourceSnapshot.relativePath
                == plan.sourceSnapshotPath,
              candidate.sourceSnapshot.purpose
                == .immutableData,
              candidate.probeExecutable.relativePath
                == plan.probeExecutablePath,
              candidate.probeExecutable.purpose
                == .executable,
              candidate.tokenizerManifest.relativePath
                == plan.tokenizerManifestPath,
              candidate.tokenizerManifest.purpose
                == .immutableData,
              candidate.corpusManifest.relativePath
                == plan.corpusManifestPath,
              candidate.corpusManifest.purpose
                == .immutableData,
              candidate.probeObservation.relativePath
                == plan.probeObservationPath,
              candidate.probeObservation.purpose
                == .immutableData,
              candidate.probeObservation.sha256
                == plan.expectedObservationSHA256,
              !candidate.receiptPublished,
              candidate.authorityStatement.contains(
                  "not a PASS receipt"
              )
        else {
            throw PrimeNativeCorpusReplayError
                .invalidCandidate(
                    "candidate fields drifted"
                )
        }

        let snapshot =
            try root.decodeVerified(
                PrimeSwiftSourceSnapshot.self,
                binding: candidate.sourceSnapshot,
                maximumByteCount:
                    maximumSnapshotBytes
            )
        if let historicalSourcePin {
            try PrimeSwiftSourceProvenance
                .validatePinnedReleaseEvidence(
                    snapshot,
                    requiredRelativePaths:
                        requiredPrimeSourcePaths,
                    pin: historicalSourcePin
                )
        } else {
            try PrimeSwiftSourceProvenance.validate(
                snapshot,
                requiredRelativePaths:
                    requiredPrimeSourcePaths
            )
        }
        try validateTransplants(in: snapshot)
        _ = try root.verify(
            candidate.probeExecutable
        )

        let tokenizerData = try root.readVerified(
            candidate.tokenizerManifest,
            maximumByteCount: maximumJSONBytes
        )
        let corpusData = try root.readVerified(
            candidate.corpusManifest,
            maximumByteCount: maximumJSONBytes
        )
        try validateHistoricalManifests(
            tokenizerData: tokenizerData,
            corpusData: corpusData
        )
        let observation =
            try root.decodeVerified(
                PrimeNativeCorpusReplayObservation
                    .self,
                binding:
                    candidate.probeObservation,
                maximumByteCount:
                    maximumJSONBytes
            )
        try observation.validateFrozen()
    }

    public static func validate(
        _ receipt:
            PrimeNativeCorpusReplayReceipt,
        in root: PrimeArtifactRoot
    ) throws {
        try validate(
            receipt,
            in: root,
            historicalSourcePin: nil,
            requiredPrimeSourcePaths:
                PrimeNativeCorpusReplayPlan
                .requiredPrimeSourcePaths
        )
    }

    /// Replays the exact canonical 2026-07-30 full-corpus parent.
    public static func
        validateCanonicalHistorical20260730(
        _ receipt:
            PrimeNativeCorpusReplayReceipt,
        binding: PrimeArtifactBinding,
        in root: PrimeArtifactRoot
    ) throws {
        guard binding.relativePath
                == "prime-native-full-corpus-replay-receipt.v1.json",
              binding.sha256
                == "88d243827c1aff0ce8125402f84c4ffe4012d058dedaf88f614099e975dafdc2",
              binding.byteCount == 2_965,
              binding.purpose == .immutableData,
              receipt.primeSourceRevision
                == "e17d031af4ec48b644a326646da7bcb8ce24388d",
              receipt.primeSourceTreeOID
                == "3f061674b652cca9cbc2429dc44c85a3aa803665",
              receipt.candidate.relativePath
                == "corpus-replay/probe-candidate.v1.json",
              receipt.candidate.sha256
                == "a9319a41b436075523c4ace314233f69370af1917725e1caea91ed36409a292f",
              receipt.candidate.byteCount == 2_011,
              receipt.candidate.purpose
                == .immutableData
        else {
            throw PrimeNativeCorpusReplayError
                .invalidReceipt(
                    "canonical historical identity"
                )
        }
        let persisted =
            try root.decodeVerified(
                PrimeNativeCorpusReplayReceipt.self,
                binding: binding,
                maximumByteCount:
                    maximumJSONBytes
            )
        guard persisted == receipt else {
            throw PrimeNativeCorpusReplayError
                .invalidReceipt(
                    "canonical historical receipt binding"
                )
        }
        let candidate =
            try root.decodeVerified(
                PrimeNativeCorpusReplayCandidate
                    .self,
                binding: receipt.candidate,
                maximumByteCount:
                    maximumJSONBytes
            )
        guard candidate.preSourceState.remoteURL
                == primeRemoteURL,
              candidate.preSourceState.revision
                == receipt.primeSourceRevision,
              candidate.preSourceState.treeOID
                == receipt.primeSourceTreeOID,
              candidate.preSourceState.clean,
              candidate.postSourceState
                == candidate.preSourceState,
              candidate.sourceSnapshot.relativePath
                == "source/prime-swift-source-snapshot.v1.json",
              candidate.sourceSnapshot.sha256
                == "0811b735c3162269907ce44db5321733dc01fc85454f45a8ebb19e0520b02d37",
              candidate.sourceSnapshot.byteCount
                == 3_400_268,
              candidate.sourceSnapshot.purpose
                == .immutableData
        else {
            throw PrimeNativeCorpusReplayError
                .invalidReceipt(
                    "canonical historical candidate identity"
                )
        }
        try validate(
            receipt,
            in: root,
            historicalSourcePin:
                .nativeFullCorpusReplay20260730,
            requiredPrimeSourcePaths:
                canonicalHistorical20260730RequiredPrimeSourcePaths
        )
    }

    private static func validate(
        _ receipt:
            PrimeNativeCorpusReplayReceipt,
        in root: PrimeArtifactRoot,
        historicalSourcePin:
            PrimePinnedHistoricalReleaseSource?,
        requiredPrimeSourcePaths: Set<String>
    ) throws {
        let plan = PrimeNativeCorpusReplayPlan.frozenV1
        try plan.validate()
        let expected =
            PrimeNativeCorpusReplayReceipt(
                planSHA256:
                    try plan.contentSHA256(),
                primeSourceRevision:
                    receipt.primeSourceRevision,
                primeSourceTreeOID:
                    receipt.primeSourceTreeOID,
                probeProcessIdentifier:
                    receipt.probeProcessIdentifier,
                verifierProcessIdentifier:
                    receipt.verifierProcessIdentifier,
                exactReplayObserved:
                    receipt.freshProcessReplayExact,
                candidate: receipt.candidate,
                verifierExecutable:
                    receipt.verifierExecutable,
                verifierObservation:
                    receipt.verifierObservation
            )
        guard receipt == expected,
              receipt.outcome == .pass,
              receipt.probeProcessIdentifier > 0,
              receipt.verifierProcessIdentifier > 0,
              receipt.probeProcessIdentifier
                != receipt.verifierProcessIdentifier,
              receipt.candidate.relativePath
                == plan.candidatePath,
              receipt.candidate.purpose
                == .immutableData,
              receipt.verifierExecutable
                .relativePath
                == plan.verifierExecutablePath,
              receipt.verifierExecutable.purpose
                == .executable,
              receipt.verifierObservation
                .relativePath
                == plan.verifierObservationPath,
              receipt.verifierObservation.purpose
                == .immutableData,
              receipt.verifierObservation.sha256
                == plan.expectedObservationSHA256,
              receipt.sourcePinsBound,
              receipt.byteExactTransplantCount == 2,
              receipt
                .seedBridgeBoundToEvaluationContract,
              receipt.allEightSplitsRegenerated,
              receipt.corpusRowsRegenerated,
              receipt.regeneratedRowCount
                == plan.expectedRowCount,
              receipt
                .corpusSemanticRegradePerformed,
              receipt.regradedRowCount
                == plan.expectedRowCount,
              receipt.freshProcessReplayExact,
              receipt.deterministicAggregateEvidence,
              !receipt.physicalRowShardsPublished,
              receipt.sameImplementationSemanticEvaluator,
              !receipt
                .algorithmicallyIndependentSemanticOracle,
              !receipt
                .independentScientificOracleClaimed,
              !receipt.modelExecutionPerformed,
              !receipt.neuralKitExecutionPerformed,
              !receipt.functionalTrainingPerformed,
              !receipt.quantizationPerformed,
              !receipt.productUseAuthorized,
              !receipt.pythonScientificAuthorityUsed,
              !receipt.shellScientificAuthorityUsed
        else {
            throw PrimeNativeCorpusReplayError
                .invalidReceipt(
                    "receipt fields drifted"
                )
        }

        let candidate =
            try root.decodeVerified(
                PrimeNativeCorpusReplayCandidate
                    .self,
                binding: receipt.candidate,
                maximumByteCount:
                    maximumJSONBytes
            )
        try validate(
            candidate,
            in: root,
            historicalSourcePin:
                historicalSourcePin,
            requiredPrimeSourcePaths:
                requiredPrimeSourcePaths
        )
        guard receipt.primeSourceRevision
                == candidate.postSourceState.revision,
              receipt.primeSourceTreeOID
                == candidate.postSourceState.treeOID,
              receipt.probeProcessIdentifier
                == candidate.probeProcessIdentifier
        else {
            throw PrimeNativeCorpusReplayError
                .invalidReceipt(
                    "receipt source differs from candidate"
                )
        }
        _ = try root.verify(
            receipt.verifierExecutable
        )
        let probeObservation =
            try root.decodeVerified(
                PrimeNativeCorpusReplayObservation
                    .self,
                binding:
                    candidate.probeObservation,
                maximumByteCount:
                    maximumJSONBytes
            )
        let verifierObservation =
            try root.decodeVerified(
                PrimeNativeCorpusReplayObservation
                    .self,
                binding:
                    receipt.verifierObservation,
                maximumByteCount:
                    maximumJSONBytes
            )
        try probeObservation.validateFrozen()
        try verifierObservation.validateFrozen()
        guard probeObservation == verifierObservation,
              try probeObservation.canonicalData()
                == verifierObservation.canonicalData()
        else {
            throw PrimeNativeCorpusReplayError
                .invalidReceipt(
                    "fresh-process observations differ"
                )
        }
    }

    static func requireDistinctProcessIdentifiers(
        probe: Int32,
        verifier: Int32
    ) throws {
        guard probe > 0,
              verifier > 0,
              probe != verifier else {
            throw PrimeNativeCorpusReplayError
                .replayMismatch(
                    "probe and verifier process identifiers must be positive and distinct"
                )
        }
    }

    private static func validateTransplants(
        in snapshot: PrimeSwiftSourceSnapshot
    ) throws {
        let plan = PrimeNativeCorpusReplayPlan.frozenV1
        let files = Dictionary(
            uniqueKeysWithValues:
                snapshot.files.map {
                    ($0.relativePath, $0)
                }
        )
        for source in plan.sourceBindings
            where source.policy
                == .byteExactPrimeSource
        {
            guard let path = source.primeRelativePath,
                  let file = files[path],
                  file.sha256 == source.sha256,
                  file.byteCount == source.byteCount
            else {
                throw PrimeNativeCorpusReplayError
                    .sourceTransplantMismatch(
                        source.role.rawValue
                    )
            }
        }
        guard ErgenticsNativeLanguageCanary
                .frozenSeeds
                == plan.consensusSeeds,
              plan.consensusSeeds
                == PrimeNativeEvaluationContract
                .frozenV1
                .multiSeedConsensusSeeds,
              files[
                  "Sources/PrimeNativeCorpusReplayMechanics/SeedBridge.swift"
              ] != nil
        else {
            throw PrimeNativeCorpusReplayError
                .sourceTransplantMismatch(
                    "consensus seed bridge"
                )
        }
    }

    private static func validateHistoricalManifests(
        tokenizerData: Data,
        corpusData: Data
    ) throws {
        let plan = PrimeNativeCorpusReplayPlan.frozenV1
        guard let tokenizerPin =
                plan.manifestPins.first(where: {
                    $0.artifactID
                        == "tokenizer_manifest"
                }),
              let corpusPin =
                plan.manifestPins.first(where: {
                    $0.artifactID
                        == "corpus_manifest"
                }),
              UInt64(tokenizerData.count)
                == tokenizerPin.byteCount,
              PrimeSHA256.hexDigest(
                  of: tokenizerData
              ) == tokenizerPin.artifactSHA256,
              UInt64(corpusData.count)
                == corpusPin.byteCount,
              PrimeSHA256.hexDigest(of: corpusData)
                == corpusPin.artifactSHA256
        else {
            throw PrimeNativeCorpusReplayError
                .replayMismatch(
                    "historical manifest bytes"
                )
        }
        let tokenizer = try JSONDecoder().decode(
            HistoricalTokenizer.Manifest.self,
            from: tokenizerData
        )
        try HistoricalTokenizer.verify(tokenizer)
        let corpus = try JSONDecoder().decode(
            HistoricalCorpus.Manifest.self,
            from: corpusData
        )
        try HistoricalCorpus.verify(corpus)
        guard tokenizer
                == HistoricalTokenizer.manifest(),
              corpus == HistoricalCorpus.manifest(),
              tokenizer.manifestSHA256
                == tokenizerPin
                .internalManifestSHA256,
              corpus.manifestSHA256
                == corpusPin.internalManifestSHA256,
              corpus.orderedCorpusRowsSHA256
                == plan
                .expectedOrderedCorpusRowsSHA256,
              corpus.falsifierSHA256
                == plan.expectedFalsifierSHA256,
              corpus.generator.implementationPath
                == "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift",
              corpus.evaluationContract
                .multiSeedConsensusSeeds
                == plan.consensusSeeds
        else {
            throw PrimeNativeCorpusReplayError
                .replayMismatch(
                    "historical manifest semantics"
                )
        }
    }

    private static func requireCleanSource(
        _ state:
            PrimeNativeMigrationResolverSourceState
    ) throws {
        guard state.clean,
              state.remoteURL == primeRemoteURL
        else {
            throw PrimeNativeCorpusReplayError
                .sourceTransplantMismatch(
                    "Prime source is not clean and canonical"
                )
        }
    }

    private static func requireStableSource(
        _ before:
            PrimeNativeMigrationResolverSourceState,
        _ after:
            PrimeNativeMigrationResolverSourceState
    ) throws {
        try requireCleanSource(after)
        guard before.remoteURL == after.remoteURL,
              before.revision == after.revision,
              before.treeOID == after.treeOID
        else {
            throw PrimeNativeCorpusReplayError
                .sourceTransplantMismatch(
                    "Prime source changed during replay"
                )
        }
    }
}
