import Foundation

public enum PrimeNativeGenerationContractOverlayError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidPlan
    case invalidParentAdapter(String)
    case invalidProjection(String)
    case invalidReceipt(String)
    case mutationUndetected(String)

    public var errorDescription: String? {
        switch self {
        case .invalidPlan:
            "native generation-contract overlay plan drifted"
        case let .invalidParentAdapter(detail):
            "native generation-contract parent adapter rejected: \(detail)"
        case let .invalidProjection(detail):
            "native generation-contract projection rejected: \(detail)"
        case let .invalidReceipt(detail):
            "native generation-contract receipt rejected: \(detail)"
        case let .mutationUndetected(mutation):
            "native generation-contract mutation was not detected: \(mutation)"
        }
    }
}

/// Frozen overlay that admits the standalone projection without rewriting the
/// historical adapter receipt.
public struct PrimeNativeGenerationContractOverlayPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let overlayID: String
    public let claimScope: String
    public let parentAdapterReceiptPath: String
    public let parentAdapterReceiptSHA256: String
    public let parentAdapterReceiptByteCount: UInt64
    public let parentAdapterProjectionPath: String
    public let parentAdapterProjectionSHA256: String
    public let parentAdapterProjectionByteCount: UInt64
    public let parentAdapterSourceRevision: String
    public let parentAdapterSourceTreeOID: String
    public let parentAdapterSourceIdentitySHA256:
        String
    public let expectedCopiedParentEvidenceCount:
        Int
    public let expectedCopiedParentEvidenceByteCount:
        UInt64
    public let sourceSnapshotPath: String
    public let executablePath: String
    public let projectionPath: String
    public let receiptPath: String
    public let parentAdapterMustRemainUnmodified:
        Bool
    public let fixedCapEOSGenerationContractBound:
        Bool
    public let generationBehaviorCompatibilityComplete:
        Bool
    public let physicalGenerationShardsObserved:
        Bool
    public let independentRegradeExecuted: Bool
    public let phaseThreeCompatibilityComplete:
        Bool
    public let modelExecutionAuthorized: Bool
    public let functionalTrainingAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let pythonExecutionAuthorized: Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        overlayID:
            "ergentics_prime_native_fixed_cap_eos_kv_v2_generation_contract_projection_overlay_v1",
        claimScope:
            "source_pinned_fixed_cap_eos_generation_contract_binding_only",
        parentAdapterReceiptPath:
            "prime-native-resolved-contract-adapter-receipt.v1.json",
        parentAdapterReceiptSHA256:
            "0c5cb638a5ba4e157f9e9a62b648862fe5511841e43f18b87c9d94d5b4b3a867",
        parentAdapterReceiptByteCount: 13_293,
        parentAdapterProjectionPath:
            "adapter/prime-native-resolved-contract-projection.v1.json",
        parentAdapterProjectionSHA256:
            "ddba956b7b4f7e3996fde6d8f11046ec3a222ef62467b806b5170887ef7620bf",
        parentAdapterProjectionByteCount: 3_964,
        parentAdapterSourceRevision:
            "69e65f2d23fe790bec2336e0d2c8686e1fd4daaf",
        parentAdapterSourceTreeOID:
            "08a7d58b2f0f41962642ba2faeda547962bd2449",
        parentAdapterSourceIdentitySHA256:
            "464853f9b09358b3ed95e5ac7fbf63888e6458af8ec8996ca485c1d7d0581647",
        expectedCopiedParentEvidenceCount: 14,
        expectedCopiedParentEvidenceByteCount:
            25_958_642,
        sourceSnapshotPath:
            "generation-contract/prime-swift-source-snapshot.v1.json",
        executablePath:
            "generation-contract/PrimeNativeGenerationContractProjectionProbe.executable",
        projectionPath:
            PrimeNativeGenerationContractPlan
            .frozenV1.projectionRelativePath,
        receiptPath:
            "prime-native-generation-contract-projection-receipt.v1.json",
        parentAdapterMustRemainUnmodified: true,
        fixedCapEOSGenerationContractBound: true,
        generationBehaviorCompatibilityComplete:
            false,
        physicalGenerationShardsObserved: false,
        independentRegradeExecuted: false,
        phaseThreeCompatibilityComplete: false,
        modelExecutionAuthorized: false,
        functionalTrainingAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        pythonExecutionAuthorized: false,
        authorityStatement:
            "This Swift overlay losslessly revalidates and copies the exact frozen adapter evidence, binds one standalone content-audited-lineage fixed-cap/EOS and KV-cache projection, and leaves the historical adapter receipt unchanged. The declared companion source blobs are not runtime-resolved in this slice, cache-parity values are not observed, and fresh verification requires a Release verifier built from the same Prime source identity. It establishes contract-projection availability only. It does not observe a physical generation shard, execute a model or NeuralKit, independently regrade generated behavior, regenerate corpus rows, train, quantize, claim Phase-3 completion, claim an independent scientific oracle, or authorize product use."
    )

    public func validate() throws {
        guard self == .frozenV1,
              parentAdapterMustRemainUnmodified,
              fixedCapEOSGenerationContractBound,
              !generationBehaviorCompatibilityComplete,
              !physicalGenerationShardsObserved,
              !independentRegradeExecuted,
              !phaseThreeCompatibilityComplete,
              !modelExecutionAuthorized,
              !functionalTrainingAuthorized,
              !quantizationAuthorized,
              !productUseAuthorized,
              !pythonExecutionAuthorized
        else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidPlan
        }
    }
}

public enum PrimeNativeGenerationContractOverlayOutcome:
    String,
    Codable,
    Equatable,
    Sendable
{
    case pass = "PASS"
}

public struct PrimeNativeGenerationContractOverlayReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let outcome:
        PrimeNativeGenerationContractOverlayOutcome
    public let claimScope: String
    public let plan:
        PrimeNativeGenerationContractOverlayPlan
    public let primeSourceRemoteURL: String
    public let primeSourceRevision: String
    public let primeSourceTreeOID: String
    public let primeSourceTreeClean: Bool
    public let primeSourceCommandObservations:
        [PrimeNativeMigrationGitCommandObservation]
    public let primeSourceSnapshot:
        PrimeArtifactBinding
    public let projectionExecutable:
        PrimeArtifactBinding
    public let parentAdapterReceipt:
        PrimeArtifactBinding
    public let copiedParentEvidence:
        [PrimeArtifactBinding]
    public let generationContractProjection:
        PrimeArtifactBinding
    public let mutationSweep:
        [PrimeNativeGenerationContractMutationRecord]
    public let parentAdapterValidatedAtExecution:
        Bool
    public let parentEvidenceCopiedLosslessly:
        Bool
    public let sourcePinsBound: Bool
    public let sourceBlobEvidenceResolvedAtExecution:
        Bool
    public let freshVerifierSameSourceIdentityRequired:
        Bool
    public let standaloneProjectionComplete: Bool
    public let kvCacheMechanicsProjected: Bool
    public let cacheParityWitnessValuesObserved:
        Bool
    public let fullVocabularyWitnessMechanicsProjected:
        Bool
    public let fullVocabularyWitnessValuesRecomputedFromLogits:
        Bool
    public let generatedTextCanonicalEquivalenceBound:
        Bool
    public let fixedCapEOSGenerationContractBound:
        Bool
    public let generationBehaviorCompatibilityComplete:
        Bool
    public let physicalGenerationShardsObserved:
        Bool
    public let independentRegradeExecuted: Bool
    public let corpusRowsRegenerated: Bool
    public let corpusSemanticRegradePerformed:
        Bool
    public let phaseThreeCompatibilityComplete:
        Bool
    public let archiveExpanded: Bool
    public let companionWritePerformed: Bool
    public let companionRuntimeDependencyAdded:
        Bool
    public let donorExecutionPerformed: Bool
    public let neuralKitExecutionPerformed: Bool
    public let modelExecutionPerformed: Bool
    public let functionalTrainingPerformed: Bool
    public let quantizationPerformed: Bool
    public let productPromotionAuthorized: Bool
    public let independentScientificOracleClaimed:
        Bool
    public let existingAdapterModified: Bool
    public let nextMissingPrerequisite: String

    public init(
        primeSourceRemoteURL: String,
        primeSourceRevision: String,
        primeSourceTreeOID: String,
        primeSourceTreeClean: Bool,
        primeSourceCommandObservations:
            [PrimeNativeMigrationGitCommandObservation],
        primeSourceSnapshot:
            PrimeArtifactBinding,
        projectionExecutable:
            PrimeArtifactBinding,
        parentAdapterReceipt:
            PrimeArtifactBinding,
        copiedParentEvidence:
            [PrimeArtifactBinding],
        generationContractProjection:
            PrimeArtifactBinding,
        mutationSweep:
            [PrimeNativeGenerationContractMutationRecord]
    ) {
        schemaVersion = 1
        artifactKind =
            "prime_native_generation_contract_projection_overlay"
        outcome = .pass
        claimScope =
            PrimeNativeGenerationContractOverlayPlan
            .frozenV1.claimScope
        plan = .frozenV1
        self.primeSourceRemoteURL =
            primeSourceRemoteURL
        self.primeSourceRevision =
            primeSourceRevision
        self.primeSourceTreeOID =
            primeSourceTreeOID
        self.primeSourceTreeClean =
            primeSourceTreeClean
        self.primeSourceCommandObservations =
            primeSourceCommandObservations
        self.primeSourceSnapshot =
            primeSourceSnapshot
        self.projectionExecutable =
            projectionExecutable
        self.parentAdapterReceipt =
            parentAdapterReceipt
        self.copiedParentEvidence =
            copiedParentEvidence
        self.generationContractProjection =
            generationContractProjection
        self.mutationSweep = mutationSweep
        parentAdapterValidatedAtExecution = true
        parentEvidenceCopiedLosslessly = true
        sourcePinsBound = true
        sourceBlobEvidenceResolvedAtExecution =
            false
        freshVerifierSameSourceIdentityRequired =
            true
        standaloneProjectionComplete = true
        kvCacheMechanicsProjected = true
        cacheParityWitnessValuesObserved = false
        fullVocabularyWitnessMechanicsProjected =
            true
        fullVocabularyWitnessValuesRecomputedFromLogits =
            false
        generatedTextCanonicalEquivalenceBound =
            true
        fixedCapEOSGenerationContractBound = true
        generationBehaviorCompatibilityComplete =
            false
        physicalGenerationShardsObserved = false
        independentRegradeExecuted = false
        corpusRowsRegenerated = false
        corpusSemanticRegradePerformed = false
        phaseThreeCompatibilityComplete = false
        archiveExpanded = false
        companionWritePerformed = false
        companionRuntimeDependencyAdded = false
        donorExecutionPerformed = false
        neuralKitExecutionPerformed = false
        modelExecutionPerformed = false
        functionalTrainingPerformed = false
        quantizationPerformed = false
        productPromotionAuthorized = false
        independentScientificOracleClaimed = false
        existingAdapterModified = false
        nextMissingPrerequisite =
            "source_pinned_full_swift_corpus_generator_transplant_replay"
    }

    public func validate() throws {
        try plan.validate()
        let copiedPaths =
            copiedParentEvidence.map(\.relativePath)
        guard schemaVersion == 1,
              artifactKind
                == "prime_native_generation_contract_projection_overlay",
              outcome == .pass,
              claimScope == plan.claimScope,
              PrimeNativeContractMigrationPlan
                .frozenV1
                .acceptedResolverRemoteURLs
                .contains(primeSourceRemoteURL),
              PrimeNativeContractMigrationPlan
                .isGitOID(primeSourceRevision),
              PrimeNativeContractMigrationPlan
                .isGitOID(primeSourceTreeOID),
              primeSourceTreeClean,
              !primeSourceCommandObservations.isEmpty,
              primeSourceSnapshot.relativePath
                == plan.sourceSnapshotPath,
              primeSourceSnapshot.purpose
                == .immutableData,
              projectionExecutable.relativePath
                == plan.executablePath,
              projectionExecutable.purpose == .executable,
              parentAdapterReceipt.relativePath
                == plan.parentAdapterReceiptPath,
              parentAdapterReceipt.sha256
                == plan.parentAdapterReceiptSHA256,
              parentAdapterReceipt.byteCount
                == plan.parentAdapterReceiptByteCount,
              parentAdapterReceipt.purpose
                == .immutableData,
              copiedParentEvidence.count
                == plan.expectedCopiedParentEvidenceCount,
              copiedParentEvidence.reduce(
                  UInt64(0),
                  { $0 + $1.byteCount }
              ) == plan
                .expectedCopiedParentEvidenceByteCount,
              copiedPaths == copiedPaths.sorted(),
              Set(copiedPaths).count == copiedPaths.count,
              generationContractProjection.relativePath
                == plan.projectionPath,
              generationContractProjection.purpose
                == .immutableData,
              mutationSweep.map(\.mutation)
                == PrimeNativeGenerationContractMutation
                .allCases,
              mutationSweep.allSatisfy({
                  $0.detectorID
                        == $0.mutation.detectorID
                      && $0.detected
                      && $0.restored
                      && !$0
                        .independentScientificOracleClaimed
              }),
              parentAdapterValidatedAtExecution,
              parentEvidenceCopiedLosslessly,
              sourcePinsBound,
              !sourceBlobEvidenceResolvedAtExecution,
              freshVerifierSameSourceIdentityRequired,
              standaloneProjectionComplete,
              kvCacheMechanicsProjected,
              !cacheParityWitnessValuesObserved,
              fullVocabularyWitnessMechanicsProjected,
              !fullVocabularyWitnessValuesRecomputedFromLogits,
              generatedTextCanonicalEquivalenceBound,
              fixedCapEOSGenerationContractBound,
              !generationBehaviorCompatibilityComplete,
              !physicalGenerationShardsObserved,
              !independentRegradeExecuted,
              !corpusRowsRegenerated,
              !corpusSemanticRegradePerformed,
              !phaseThreeCompatibilityComplete,
              !archiveExpanded,
              !companionWritePerformed,
              !companionRuntimeDependencyAdded,
              !donorExecutionPerformed,
              !neuralKitExecutionPerformed,
              !modelExecutionPerformed,
              !functionalTrainingPerformed,
              !quantizationPerformed,
              !productPromotionAuthorized,
              !independentScientificOracleClaimed,
              !existingAdapterModified,
              nextMissingPrerequisite
                == "source_pinned_full_swift_corpus_generator_transplant_replay"
        else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidReceipt("structural contract")
        }
        try PrimeNativeContractMigrationResolver
            .validateResolverSourceCommandObservations(
                primeSourceCommandObservations,
                remoteURL: primeSourceRemoteURL,
                revision: primeSourceRevision,
                treeOID: primeSourceTreeOID,
                clean: primeSourceTreeClean
            )
    }

    public func validate(
        in root: PrimeArtifactRoot
    ) throws {
        try validate(
            in: root,
            historicalSourcePin: nil,
            requiredPrimeSourcePaths:
                PrimeNativeGenerationContractOverlay
                .requiredPrimeSourcePaths
        )
    }

    /// Replays the exact canonical 2026-07-30 generation-contract parent.
    public func validateCanonicalHistorical20260730(
        binding: PrimeArtifactBinding,
        in root: PrimeArtifactRoot
    ) throws {
        guard binding.relativePath
                == "prime-native-generation-contract-projection-receipt.v1.json",
              binding.sha256
                == "05d135bb04bc377b85b7bce98a6eebbab35a80172567407d2c4625f4af9b990b",
              binding.byteCount == 20_010,
              binding.purpose == .immutableData,
              primeSourceRemoteURL
                == "https://github.com/Ergentics/ergentics-prime.git",
              primeSourceRevision
                == "28906ef704f4d8727ea0da5e068f6ecbe52330ab",
              primeSourceTreeOID
                == "c2d07ff9f4a011f7dddf8eb91dcd7278d873b18c",
              primeSourceTreeClean,
              primeSourceSnapshot.relativePath
                == "generation-contract/prime-swift-source-snapshot.v1.json",
              primeSourceSnapshot.sha256
                == "f3b51e4a01f4af2725fff1e1256db7d1378e0d412b6f22d26840ef5f97ff15c7",
              primeSourceSnapshot.byteCount
                == 2_858_617,
              primeSourceSnapshot.purpose
                == .immutableData
        else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidReceipt(
                    "canonical historical identity"
                )
        }
        let persisted =
            try root.decodeVerified(
                PrimeNativeGenerationContractOverlayReceipt
                    .self,
                binding: binding,
                maximumByteCount: 4 * 1024 * 1024
            )
        guard persisted == self else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidReceipt(
                    "canonical historical receipt binding"
                )
        }
        try validate(
            in: root,
            historicalSourcePin:
                .nativeGenerationContractProjection20260730,
            requiredPrimeSourcePaths:
                PrimeNativeGenerationContractOverlay
                .canonicalHistorical20260730RequiredPrimeSourcePaths
        )
    }

    private func validate(
        in root: PrimeArtifactRoot,
        historicalSourcePin:
            PrimePinnedHistoricalReleaseSource?,
        requiredPrimeSourcePaths: Set<String>
    ) throws {
        try validate()
        let parent =
            try root.decodeVerified(
                PrimeNativeResolvedContractAdapterReceipt
                    .self,
                binding: parentAdapterReceipt,
                maximumByteCount: 4 * 1024 * 1024
            )
        try PrimeNativeGenerationContractOverlay
            .validateHistoricalParentAdapter(
                parent,
                in: root
            )
        guard PrimeNativeGenerationContractOverlay
                .expectedParentEvidence(
                    from: parent
                ) == copiedParentEvidence
        else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidReceipt(
                    "copied parent evidence"
                )
        }

        let sourceSnapshot =
            try root.decodeVerified(
                PrimeSwiftSourceSnapshot.self,
                binding: primeSourceSnapshot,
                maximumByteCount:
                    64 * 1024 * 1024
            )
        if let historicalSourcePin {
            try PrimeSwiftSourceProvenance
                .validatePinnedReleaseEvidence(
                    sourceSnapshot,
                    requiredRelativePaths:
                        requiredPrimeSourcePaths,
                    pin: historicalSourcePin
                )
        } else {
            try PrimeSwiftSourceProvenance.validate(
                sourceSnapshot,
                requiredRelativePaths:
                    requiredPrimeSourcePaths
            )
        }
        _ = try root.verify(projectionExecutable)

        let projection =
            try root.decodeVerified(
                PrimeNativeGenerationContractProjection
                    .self,
                binding:
                    generationContractProjection,
                maximumByteCount: 4 * 1024 * 1024
            )
        try projection.validate()
        guard projection == .frozenV1 else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidReceipt(
                    "generation projection replay"
                )
        }
        let replayed =
            try PrimeNativeGenerationContractOverlay
            .mutationSweep()
        guard replayed == mutationSweep else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidReceipt(
                    "mutation sweep replay"
                )
        }
    }
}

public enum PrimeNativeGenerationContractOverlay {
    public static let requiredPrimeSourcePaths:
        Set<String> = [
        "Sources/PrimeCore/PrimeNativeGenerationContractProjection.swift",
        "Sources/PrimeCore/PrimeNativeGenerationContractOverlay.swift",
        "Sources/PrimeCore/PrimeNativeGenerationContractArguments.swift",
        "Sources/PrimeCore/PrimeDurableArtifacts.swift",
        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
        "Sources/PrimeCore/PrimeNativeContractMigration.swift",
        "Sources/PrimeCore/PrimeNativeContractMigrationResolver.swift",
        "Sources/PrimeCore/PrimeNativeGitBlobTransport.swift",
        "Sources/PrimeCore/PrimeNativeResolvedContractAdapter.swift",
        "Sources/PrimeCore/PrimeNativeResolvedContractModels.swift",
        "Sources/PrimeCore/PrimeSecureRunningExecutableCapture.swift",
        "Sources/PrimeCore/PrimeSwiftSourceProvenance.swift",
        "Sources/PrimeNativeGenerationContractProjectionProbe/PrimeNativeGenerationContractProjectionProbeMain.swift",
        "Sources/PrimeNativeGenerationContractProjectionVerifier/PrimeNativeGenerationContractProjectionVerifierMain.swift",
    ]

    static let
        canonicalHistorical20260730RequiredPrimeSourcePaths:
        Set<String> = [
            "Sources/PrimeCore/PrimeNativeGenerationContractProjection.swift",
            "Sources/PrimeCore/PrimeNativeGenerationContractOverlay.swift",
            "Sources/PrimeCore/PrimeNativeGenerationContractArguments.swift",
            "Sources/PrimeCore/PrimeDurableArtifacts.swift",
            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
            "Sources/PrimeCore/PrimeNativeContractMigration.swift",
            "Sources/PrimeCore/PrimeNativeContractMigrationResolver.swift",
            "Sources/PrimeCore/PrimeNativeGitBlobTransport.swift",
            "Sources/PrimeCore/PrimeNativeResolvedContractAdapter.swift",
            "Sources/PrimeCore/PrimeNativeResolvedContractModels.swift",
            "Sources/PrimeCore/PrimeSecureRunningExecutableCapture.swift",
            "Sources/PrimeCore/PrimeSwiftSourceProvenance.swift",
            "Sources/PrimeNativeGenerationContractProjectionProbe/PrimeNativeGenerationContractProjectionProbeMain.swift",
            "Sources/PrimeNativeGenerationContractProjectionVerifier/PrimeNativeGenerationContractProjectionVerifierMain.swift",
        ]

    public static func publish(
        adapterRoot: PrimeArtifactRoot,
        primeSourceRoot: URL,
        primeSourcePreState:
            PrimeNativeMigrationResolverSourceState,
        primeSourceSnapshot:
            PrimeSwiftSourceSnapshot,
        to outputRoot: PrimeArtifactRoot
    ) throws -> (
        receipt:
            PrimeNativeGenerationContractOverlayReceipt,
        receiptBinding: PrimeArtifactBinding
    ) {
        let plan =
            PrimeNativeGenerationContractOverlayPlan
            .frozenV1
        try plan.validate()
        try adapterRoot.requirePrivateRootMode()
        try outputRoot.requirePrivateRootMode()
        try outputRoot.requireEmpty()

        let parentReceiptBinding =
            try adapterRoot.bindExisting(
                at: plan.parentAdapterReceiptPath,
                purpose: .immutableData,
                maximumByteCount: 4 * 1024 * 1024
            )
        try validateParentAdapterReceiptBinding(
            parentReceiptBinding
        )
        let parent =
            try adapterRoot.decodeVerified(
                PrimeNativeResolvedContractAdapterReceipt
                    .self,
                binding: parentReceiptBinding,
                maximumByteCount: 4 * 1024 * 1024
            )
        try validateHistoricalParentAdapter(
            parent,
            in: adapterRoot
        )
        try validateSourceState(
            primeSourcePreState,
            expectedRemoteURL: nil,
            expectedRevision: nil,
            expectedTreeOID: nil
        )
        try PrimeSwiftSourceProvenance.validate(
            primeSourceSnapshot,
            requiredRelativePaths:
                requiredPrimeSourcePaths
        )

        let executableData =
            try PrimeSecureRunningExecutableCapture
            .data()
        let postState =
            try PrimeNativeGitBlobTransport()
            .sourceState(
                repositoryRoot: primeSourceRoot,
                phase: .postExecutable
            )
        try validateSourceState(
            postState,
            expectedRemoteURL:
                primeSourcePreState.remoteURL,
            expectedRevision:
                primeSourcePreState.revision,
            expectedTreeOID:
                primeSourcePreState.treeOID
        )
        let sourceObservations =
            primeSourcePreState.commandObservations
            + postState.commandObservations
        try PrimeNativeContractMigrationResolver
            .validateResolverSourceCommandObservations(
                sourceObservations,
                remoteURL: postState.remoteURL,
                revision: postState.revision,
                treeOID: postState.treeOID,
                clean: postState.clean
            )

        try outputRoot.ensurePrivateDirectory(
            at: "adapter"
        )
        try outputRoot.ensurePrivateDirectory(
            at: "resolved"
        )
        try outputRoot.ensurePrivateDirectory(
            at: "generation-contract"
        )
        let copiedParentEvidence =
            try expectedParentEvidence(
                from: parent
            ).map {
                try copy(
                    $0,
                    from: adapterRoot,
                    to: outputRoot
                )
            }
        let copiedParentReceipt =
            try copy(
                parentReceiptBinding,
                from: adapterRoot,
                to: outputRoot
            )
        let sourceSnapshotBinding =
            try outputRoot.publishCanonical(
                primeSourceSnapshot,
                at: plan.sourceSnapshotPath
            )
        let executableBinding =
            try outputRoot.publish(
                executableData,
                at: plan.executablePath,
                purpose: .executable
            )
        let projection =
            PrimeNativeGenerationContractProjection
            .frozenV1
        try projection.validate()
        let projectionBinding =
            try outputRoot.publishCanonical(
                projection,
                at: plan.projectionPath
            )
        let mutations = try mutationSweep()

        let receipt =
            PrimeNativeGenerationContractOverlayReceipt(
                primeSourceRemoteURL:
                    postState.remoteURL,
                primeSourceRevision:
                    postState.revision,
                primeSourceTreeOID:
                    postState.treeOID,
                primeSourceTreeClean:
                    postState.clean,
                primeSourceCommandObservations:
                    sourceObservations,
                primeSourceSnapshot:
                    sourceSnapshotBinding,
                projectionExecutable:
                    executableBinding,
                parentAdapterReceipt:
                    copiedParentReceipt,
                copiedParentEvidence:
                    copiedParentEvidence,
                generationContractProjection:
                    projectionBinding,
                mutationSweep: mutations
            )
        try receipt.validate(in: outputRoot)
        let receiptBinding =
            try outputRoot.publishCanonical(
                receipt,
                at: plan.receiptPath
            )
        let roundTrip =
            try outputRoot.decodeVerified(
                PrimeNativeGenerationContractOverlayReceipt
                    .self,
                binding: receiptBinding,
                maximumByteCount: 4 * 1024 * 1024
            )
        guard roundTrip == receipt else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidReceipt(
                    "canonical round trip"
                )
        }
        try roundTrip.validate(in: outputRoot)
        return (roundTrip, receiptBinding)
    }

    static func validateHistoricalParentAdapter(
        _ parent:
            PrimeNativeResolvedContractAdapterReceipt,
        in root: PrimeArtifactRoot
    ) throws {
        let plan =
            PrimeNativeGenerationContractOverlayPlan
            .frozenV1
        try parent.validate()
        guard parent.adapterSourceRevision
                == plan.parentAdapterSourceRevision,
              parent.adapterSourceTreeOID
                == plan.parentAdapterSourceTreeOID,
              !parent.fixedCapEOSGenerationContractBound,
              !parent.generationBehaviorCompatibilityComplete,
              parent.compatibilityProjection.relativePath
                == plan.parentAdapterProjectionPath,
              parent.compatibilityProjection.sha256
                == plan.parentAdapterProjectionSHA256,
              parent.compatibilityProjection.byteCount
                == plan.parentAdapterProjectionByteCount
        else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidParentAdapter(
                    "frozen identity"
                )
        }

        let historicalSnapshot =
            try root.decodeVerified(
                PrimeSwiftSourceSnapshot.self,
                binding:
                    parent.adapterSourceSnapshot,
                maximumByteCount:
                    64 * 1024 * 1024
            )
        try PrimeSwiftSourceProvenance.validate(
            historicalSnapshot,
            requiredRelativePaths:
                PrimeNativeResolvedContractAdapter
                .requiredAdapterSourcePaths,
            expectation:
                PrimeSwiftSourceProvenanceExpectation(
                    sourceIdentitySHA256:
                        plan
                        .parentAdapterSourceIdentitySHA256,
                    buildConfiguration: "release"
                )
        )
        _ = try root.verify(
            parent.adapterExecutable
        )
        let parentResolution =
            try root.decodeVerified(
                PrimeNativeContractMigrationReceipt.self,
                binding: parent.parentReceipt,
                maximumByteCount: 4 * 1024 * 1024
            )
        try PrimeNativeResolvedContractAdapter
            .validateParentResolution(
                parentResolution,
                in: root
            )
        guard parentResolution.resolverSourceSnapshot
                == parent
                .parentResolverSourceSnapshot,
              parentResolution.resolverExecutable
                == parent.parentResolverExecutable,
              parentResolution.artifacts.map(\.artifact)
                == parent.copiedParentArtifacts
        else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidParentAdapter(
                    "resolution chain"
                )
        }
        for binding in expectedParentEvidence(
            from: parent
        ) {
            _ = try root.verify(binding)
        }
        let adapterProjection =
            try root.decodeVerified(
                PrimeNativeResolvedContractProjection
                    .self,
                binding:
                    parent.compatibilityProjection,
                maximumByteCount: 4 * 1024 * 1024
            )
        try adapterProjection.validate()
    }

    static func expectedParentEvidence(
        from parent:
            PrimeNativeResolvedContractAdapterReceipt
    ) -> [PrimeArtifactBinding] {
        (
            [
                parent.adapterSourceSnapshot,
                parent.adapterExecutable,
                parent.parentReceipt,
                parent.parentResolverSourceSnapshot,
                parent.parentResolverExecutable,
                parent.compatibilityProjection,
            ] + parent.copiedParentArtifacts
        ).sorted {
            $0.relativePath < $1.relativePath
        }
    }

    static func mutationSweep() throws
        -> [PrimeNativeGenerationContractMutationRecord]
    {
        var records =
            [PrimeNativeGenerationContractMutationRecord]()
        for mutation in
            PrimeNativeGenerationContractMutation.allCases
        {
            let detected: Bool
            switch mutation {
            case .sourcePinSetDrift:
                detected = try detectsProjectionMutation {
                    guard var plan =
                            $0["plan"]
                                as? [String: Any],
                          var bindings =
                            plan["source_bindings"]
                                as? [[String: Any]]
                    else {
                        throw PrimeNativeGenerationContractOverlayError
                            .invalidProjection(
                                "mutation fixture"
                            )
                    }
                    bindings.removeLast()
                    plan["source_bindings"] =
                        bindings
                    $0["plan"] = plan
                }
            case .sourcePathDrift:
                detected = try detectsSourceBindingMutation {
                    $0["repository_relative_path"] =
                        "prime-runtime/Sources/Drift.swift"
                }
            case .sourceBlobOIDDrift:
                detected = try detectsSourceBindingMutation {
                    $0["git_blob_oid"] = String(
                        repeating: "0",
                        count: 40
                    )
                }
            case .sourceSHA256Drift:
                detected = try detectsSourceBindingMutation {
                    $0["sha256"] = String(
                        repeating: "0",
                        count: 64
                    )
                }
            case .sourceByteCountDrift:
                detected = try detectsSourceBindingMutation {
                    $0["byte_count"] = 216_814
                }
            case .sourceBlobResolutionOverclaim:
                detected = try detectsProjectionMutation {
                    guard var plan =
                            $0["plan"]
                                as? [String: Any]
                    else {
                        throw PrimeNativeGenerationContractOverlayError
                            .invalidProjection(
                                "mutation fixture"
                            )
                    }
                    plan[
                        "source_blob_evidence_resolved_at_execution"
                    ] = true
                    $0["plan"] = plan
                }
            case .freshVerifierIdentityPolicyDrift:
                detected = try detectsProjectionMutation {
                    guard var plan =
                            $0["plan"]
                                as? [String: Any]
                    else {
                        throw PrimeNativeGenerationContractOverlayError
                            .invalidProjection(
                                "mutation fixture"
                            )
                    }
                    plan[
                        "fresh_verifier_source_identity_policy"
                    ] =
                        "any_future_source_identity_v0"
                    $0["plan"] = plan
                }
            case .parentAdapterReceiptBindingDrift:
                let changed = PrimeArtifactBinding(
                    relativePath:
                        PrimeNativeGenerationContractOverlayPlan
                        .frozenV1
                        .parentAdapterReceiptPath,
                    sha256: String(
                        repeating: "0",
                        count: 64
                    ),
                    byteCount:
                        PrimeNativeGenerationContractOverlayPlan
                        .frozenV1
                        .parentAdapterReceiptByteCount,
                    purpose: .immutableData
                )
                detected = throwsError {
                    try validateParentAdapterReceiptBinding(
                        changed
                    )
                }
            case .generationContractIDDrift:
                detected = try detectsProjectionMutation {
                    $0["generation_contract_id"] =
                        "target_length_oracle"
                }
            case .promptGroupingIDDrift:
                detected = try detectsProjectionMutation {
                    $0["prompt_grouping_key_id"] =
                        "target_token_count_v0"
                }
            case .allowedSupportDrift:
                detected = try detectsProjectionMutation {
                    guard var support =
                            $0[
                                "allowed_completion_token_ids"
                            ] as? [Int]
                    else {
                        throw PrimeNativeGenerationContractOverlayError
                            .invalidProjection(
                                "mutation fixture"
                            )
                    }
                    support.removeLast()
                    $0[
                        "allowed_completion_token_ids"
                    ] = support
                }
            case .allowedSupportHashDrift:
                detected = try detectsProjectionMutation {
                    $0[
                        "allowed_completion_token_set_sha256"
                    ] = String(
                        repeating: "0",
                        count: 64
                    )
                }
            case .asciiConstrainedSupport:
                detected = try detectsProjectionMutation {
                    $0[
                        "allowed_completion_token_ids"
                    ] = [70] + Array(288 ... 383)
                }
            case .allowedSupportTieRuleDrift:
                detected = try detectsProjectionMutation {
                    $0[
                        "greedy_equal_logit_tie_policy"
                    ] =
                        "last_ordered_support_entry_wins"
                }
            case .rawFullVocabularyTieRuleDrift:
                detected = try detectsProjectionMutation {
                    $0[
                        "raw_full_vocabulary_equal_logit_tie_policy"
                    ] =
                        "last_vocabulary_token_wins"
                }
            case .selectedLogProbabilityPolicyDrift:
                detected = try detectsProjectionMutation {
                    $0[
                        "selected_token_log_probability_policy"
                    ] =
                        "renormalized_allowed_support_logsoftmax_v0"
                }
            case .fullVocabularyLogSoftmaxPrecisionDrift:
                detected =
                    try detectsFullVocabularyWitnessMutation {
                        $0[
                            "log_probability_extraction_precision_policy"
                        ] =
                            "float64_direct_extraction_v0"
                    }
            case .disallowedProbabilityMassComputationDrift:
                detected =
                    try detectsFullVocabularyWitnessMutation {
                        $0[
                            "disallowed_probability_mass_per_decision_policy"
                        ] =
                            "sum_only_disallowed_argmax_probability_v0"
                    }
            case .fullVocabularyWitnessObservationOverclaim:
                detected =
                    try detectsFullVocabularyWitnessMutation {
                        $0[
                            "witness_values_recomputed_from_logits"
                        ] = true
                    }
            case .terminatedBatchFillerPolicyDrift:
                detected = try detectsProjectionMutation {
                    $0[
                        "terminated_batch_filler_token_policy"
                    ] =
                        "repeat_last_generated_byte_token_v0"
                }
            case .cachedPromptPrefillPolicyDrift:
                detected = try detectsKVCacheMechanicsMutation {
                    $0["prompt_prefill_policy"] =
                        "uncached_prompt_prefill_v0"
                }
            case .cachedDecodeStepWidthDrift:
                detected = try detectsKVCacheMechanicsMutation {
                    $0["decode_step_input_token_count"] =
                        2
                }
            case .batchGeometryGuardRemoved:
                detected = try detectsKVCacheMechanicsMutation {
                    $0["prompt_batch_geometry_policy"] =
                        "variable_unpadded_prompt_lengths_v0"
                }
            case .contextCapacityGuardRemoved:
                detected = try detectsKVCacheMechanicsMutation {
                    $0[
                        "insufficient_generation_context_row_ids_must_be_empty"
                    ] = false
                }
            case .cacheParityFixtureDrift:
                detected = try detectsKVCacheMechanicsMutation {
                    $0["multi_step_continuation_token_id_paths"] =
                        [
                            [321, 70],
                            [341, 342, 344, 70],
                        ]
                }
            case .singleStepCacheParityThresholdDrift:
                detected = try detectsKVCacheMechanicsMutation {
                    $0[
                        "single_step_maximum_logit_delta_upper_bound"
                    ] = 1e-3
                }
            case .multiStepCacheParityThresholdDrift:
                detected = try detectsKVCacheMechanicsMutation {
                    $0[
                        "multi_step_maximum_logit_delta_upper_bound"
                    ] = 1e-3
                }
            case .multiStepCacheParityDecisionCountDrift:
                detected = try detectsKVCacheMechanicsMutation {
                    $0[
                        "multi_step_compared_decision_count"
                    ] = 5
                }
            case .multiStepUnevenEOSRequirementRemoved:
                detected = try detectsKVCacheMechanicsMutation {
                    $0[
                        "multi_step_uneven_eos_required"
                    ] = false
                }
            case .cacheParityObservationOverclaim:
                detected = try detectsKVCacheMechanicsMutation {
                    $0[
                        "cache_parity_witness_values_observed"
                    ] = true
                }
            case .generatedTextComparisonPolicyDrift:
                detected = try detectsProjectionMutation {
                    $0[
                        "prime_byte_exact_generated_text_hardening_applied"
                    ] = true
                }
            case .promptTargetLeakage:
                let request =
                    try PrimeNativePromptOnlyGenerationRequest(
                        rowID: "mutation-row",
                        seed: 1618,
                        promptText: "Prime prompt\n"
                    )
                let changed =
                    try mutateObject(
                        PrimeCanonicalJSON.encode(
                            request
                        )
                    ) {
                        $0["target"] = "7\n"
                    }
                detected = throwsError {
                    _ = try JSONDecoder().decode(
                        PrimeNativePromptOnlyGenerationRequest
                            .self,
                        from: changed
                    )
                }
            case .targetDependentPromptGrouping:
                detected = try detectsProjectionMutation {
                    guard var fields =
                            $0[
                                "prompt_only_fields"
                            ] as? [String: Any],
                          var historical =
                            fields[
                                "historical_boundary_fields"
                            ] as? [String]
                    else {
                        throw PrimeNativeGenerationContractOverlayError
                            .invalidProjection(
                                "mutation fixture"
                            )
                    }
                    historical.append(
                        "target_token_count_grouping_key"
                    )
                    fields[
                        "historical_boundary_fields"
                    ] = historical
                    $0["prompt_only_fields"] =
                        fields
                }
            case .targetDependentDecisionBudget:
                detected = try detectsProjectionMutation {
                    $0[
                        "maximum_generation_token_decisions"
                    ] = 63
                }
            case .decisionBudgetUpperDrift:
                detected = try detectsProjectionMutation {
                    $0[
                        "maximum_generation_token_decisions"
                    ] = 65
                }
            case .eosUnavailable:
                detected = try detectsProjectionMutation {
                    $0[
                        "eos_available_at_every_decision"
                    ] = false
                }
            case .shortFixedCap:
                detected = throwsError {
                    _ = try rawObservation(
                        byteCount: 63,
                        terminatedByEOS: false,
                        termination: .fixedCap,
                        eosLogProbability: nil,
                        meanLogProbability: -1
                    )
                }
            case .terminationInconsistency:
                detected = throwsError {
                    _ = try rawObservation(
                        byteCount: 1,
                        terminatedByEOS: true,
                        termination: .eos,
                        eosLogProbability: nil,
                        meanLogProbability: -1
                    )
                }
            case .immediateEOSMeanOmission:
                detected = throwsError {
                    _ = try rawObservation(
                        byteCount: 0,
                        terminatedByEOS: true,
                        termination: .eos,
                        eosLogProbability: -7.25,
                        meanLogProbability: 0
                    )
                }
            case .invalidUTF8EvidenceErasure:
                detected = throwsError {
                    _ =
                        try PrimeNativeHistoricalRawGenerationObservation(
                            text: "",
                            tokenIDs: [511],
                            tokenLogProbabilities: [-1],
                            meanLogProbability: -1,
                            terminatedByEOS: true,
                            terminationReason: .eos,
                            utf8Valid: true,
                            eosLogProbability: -1,
                            rawFullVocabularyAllowedSupportGreedyTokenParity:
                                true,
                            disallowedFullVocabularyArgmaxCount:
                                0,
                            maximumDisallowedTokenProbabilityMass:
                                0,
                            latencySeconds: 0.001
                        )
                }
            case .decisionLogProbabilityCountMismatch:
                detected = throwsError {
                    _ =
                        try PrimeNativeHistoricalRawGenerationObservation(
                            text: "A",
                            tokenIDs: [321],
                            tokenLogProbabilities: [],
                            meanLogProbability: -1,
                            terminatedByEOS: true,
                            terminationReason: .eos,
                            utf8Valid: true,
                            eosLogProbability: -1,
                            rawFullVocabularyAllowedSupportGreedyTokenParity:
                                true,
                            disallowedFullVocabularyArgmaxCount:
                                0,
                            maximumDisallowedTokenProbabilityMass:
                                0,
                            latencySeconds: 0.001
                        )
                }
            case .supportWitnessInconsistency:
                detected = throwsError {
                    _ =
                        try PrimeNativeHistoricalRawGenerationObservation(
                            text: "",
                            tokenIDs: [],
                            tokenLogProbabilities: [],
                            meanLogProbability: -1,
                            terminatedByEOS: true,
                            terminationReason: .eos,
                            utf8Valid: true,
                            eosLogProbability: -1,
                            rawFullVocabularyAllowedSupportGreedyTokenParity:
                                true,
                            disallowedFullVocabularyArgmaxCount:
                                1,
                            maximumDisallowedTokenProbabilityMass:
                                0.5,
                            latencySeconds: 0.001
                        )
                }
            case .zeroLatency:
                detected = throwsError {
                    _ =
                        try PrimeNativeHistoricalRawGenerationObservation(
                            text: "",
                            tokenIDs: [],
                            tokenLogProbabilities: [],
                            meanLogProbability: -1,
                            terminatedByEOS: true,
                            terminationReason: .eos,
                            utf8Valid: true,
                            eosLogProbability: -1,
                            rawFullVocabularyAllowedSupportGreedyTokenParity:
                                true,
                            disallowedFullVocabularyArgmaxCount:
                                0,
                            maximumDisallowedTokenProbabilityMass:
                                0,
                            latencySeconds: 0
                        )
                }
            case .optionalNilPolicyDrift:
                detected = try detectsProjectionMutation {
                    $0["optional_nil_key_encoding"] =
                        "explicit_null"
                }
            case .rawShardFieldListDrift:
                detected = try detectsProjectionMutation {
                    guard var fields =
                            $0["raw_shard_fields"]
                                as? [String: Any],
                          var generated =
                            fields["generated_fields"]
                                as? [String]
                    else {
                        throw PrimeNativeGenerationContractOverlayError
                            .invalidProjection(
                                "mutation fixture"
                            )
                    }
                    generated.removeLast()
                    fields["generated_fields"] =
                        generated
                    $0["raw_shard_fields"] =
                        fields
                }
            case .schema4FieldListDrift:
                detected = try detectsProjectionMutation {
                    guard var fields =
                            $0["schema4_regrade_fields"]
                                as? [String: Any],
                          var ordered =
                            fields["ordered_record_fields"]
                                as? [String]
                    else {
                        throw PrimeNativeGenerationContractOverlayError
                            .invalidProjection(
                                "mutation fixture"
                            )
                    }
                    ordered.removeLast()
                    fields["ordered_record_fields"] =
                        ordered
                    $0["schema4_regrade_fields"] =
                        fields
                }
            case .regradeAuthorityLeakage:
                detected = try detectsProjectionMutation {
                    guard var fields =
                            $0[
                                "prompt_only_fields"
                            ] as? [String: Any],
                          var request =
                            fields[
                                "prime_request_fields"
                            ] as? [String]
                    else {
                        throw PrimeNativeGenerationContractOverlayError
                            .invalidProjection(
                                "mutation fixture"
                            )
                    }
                    request.append(
                        "evaluation_row_sha256"
                    )
                    fields["prime_request_fields"] =
                        request
                    $0["prompt_only_fields"] =
                        fields
                }
            case .projectionAuthorityExpansion:
                detected = try detectsProjectionMutation {
                    guard var nonclaims =
                            $0["nonclaims"]
                                as? [String: Any]
                    else {
                        throw PrimeNativeGenerationContractOverlayError
                            .invalidProjection(
                                "mutation fixture"
                            )
                    }
                    nonclaims[
                        "product_promotion_authorized"
                    ] = true
                    $0["nonclaims"] = nonclaims
                }
            }
            guard detected else {
                throw PrimeNativeGenerationContractOverlayError
                    .mutationUndetected(
                        mutation.rawValue
                    )
            }
            records.append(
                .detectedAndRestored(mutation)
            )
        }
        try records.forEach { try $0.validate() }
        return records
    }

    private static func rawObservation(
        byteCount: Int,
        terminatedByEOS: Bool,
        termination:
            PrimeNativeHistoricalGenerationTermination,
        eosLogProbability: Double?,
        meanLogProbability: Double
    ) throws
        -> PrimeNativeHistoricalRawGenerationObservation
    {
        try PrimeNativeHistoricalRawGenerationObservation(
            text: String(
                repeating: "A",
                count: byteCount
            ),
            tokenIDs: Array(
                repeating: 321,
                count: byteCount
            ),
            tokenLogProbabilities: Array(
                repeating: -1,
                count: byteCount
            ),
            meanLogProbability:
                meanLogProbability,
            terminatedByEOS: terminatedByEOS,
            terminationReason: termination,
            utf8Valid: true,
            eosLogProbability:
                eosLogProbability,
            rawFullVocabularyAllowedSupportGreedyTokenParity:
                true,
            disallowedFullVocabularyArgmaxCount:
                0,
            maximumDisallowedTokenProbabilityMass:
                0,
            latencySeconds: 0.001
        )
    }

    private static func detectsProjectionMutation(
        _ mutate: (inout [String: Any]) throws -> Void
    ) throws -> Bool {
        let data =
            try PrimeCanonicalJSON.encode(
                PrimeNativeGenerationContractProjection
                    .frozenV1
            )
        let changed = try mutateObject(
            data,
            mutate
        )
        return throwsError {
            let decoded =
                try JSONDecoder().decode(
                    PrimeNativeGenerationContractProjection
                        .self,
                    from: changed
                )
            try decoded.validate()
        }
    }

    private static func detectsSourceBindingMutation(
        _ mutate: (inout [String: Any]) throws -> Void
    ) throws -> Bool {
        try detectsProjectionMutation {
            guard var plan =
                    $0["plan"] as? [String: Any],
                  var bindings =
                    plan["source_bindings"]
                        as? [[String: Any]],
                  !bindings.isEmpty
            else {
                throw PrimeNativeGenerationContractOverlayError
                    .invalidProjection(
                        "mutation fixture"
                    )
            }
            var first = bindings[0]
            try mutate(&first)
            bindings[0] = first
            plan["source_bindings"] = bindings
            $0["plan"] = plan
        }
    }

    private static func detectsKVCacheMechanicsMutation(
        _ mutate: (inout [String: Any]) throws -> Void
    ) throws -> Bool {
        try detectsProjectionMutation {
            guard var mechanics =
                    $0["kv_cache_mechanics"]
                        as? [String: Any]
            else {
                throw PrimeNativeGenerationContractOverlayError
                    .invalidProjection(
                        "mutation fixture"
                    )
            }
            try mutate(&mechanics)
            $0["kv_cache_mechanics"] = mechanics
        }
    }

    private static func detectsFullVocabularyWitnessMutation(
        _ mutate: (inout [String: Any]) throws -> Void
    ) throws -> Bool {
        try detectsProjectionMutation {
            guard var witness =
                    $0["full_vocabulary_witness"]
                        as? [String: Any]
            else {
                throw PrimeNativeGenerationContractOverlayError
                    .invalidProjection(
                        "mutation fixture"
                    )
            }
            try mutate(&witness)
            $0["full_vocabulary_witness"] = witness
        }
    }

    private static func mutateObject(
        _ data: Data,
        _ mutate: (inout [String: Any]) throws -> Void
    ) throws -> Data {
        guard var object =
                try JSONSerialization
                .jsonObject(with: data)
                as? [String: Any]
        else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidProjection(
                    "mutation fixture"
                )
        }
        try mutate(&object)
        return try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys]
        )
    }

    private static func throwsError(
        _ operation: () throws -> Void
    ) -> Bool {
        do {
            try operation()
            return false
        } catch {
            return true
        }
    }

    private static func validateSourceState(
        _ state:
            PrimeNativeMigrationResolverSourceState,
        expectedRemoteURL: String?,
        expectedRevision: String?,
        expectedTreeOID: String?
    ) throws {
        guard PrimeNativeContractMigrationPlan
                .frozenV1
                .acceptedResolverRemoteURLs
                .contains(state.remoteURL),
              expectedRemoteURL.map({
                  $0 == state.remoteURL
              }) ?? true,
              PrimeNativeContractMigrationPlan
                .isGitOID(state.revision),
              expectedRevision.map({
                  $0 == state.revision
              }) ?? true,
              PrimeNativeContractMigrationPlan
                .isGitOID(state.treeOID),
              expectedTreeOID.map({
                  $0 == state.treeOID
              }) ?? true,
              state.clean
        else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidReceipt(
                    "Prime source identity"
                )
        }
    }

    private static func validateParentAdapterReceiptBinding(
        _ binding: PrimeArtifactBinding
    ) throws {
        let plan =
            PrimeNativeGenerationContractOverlayPlan
            .frozenV1
        guard binding.relativePath
                == plan.parentAdapterReceiptPath,
              binding.sha256
                == plan.parentAdapterReceiptSHA256,
              binding.byteCount
                == plan.parentAdapterReceiptByteCount,
              binding.purpose == .immutableData
        else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidParentAdapter(
                    "receipt binding"
                )
        }
    }

    private static func copy(
        _ binding: PrimeArtifactBinding,
        from inputRoot: PrimeArtifactRoot,
        to outputRoot: PrimeArtifactRoot
    ) throws -> PrimeArtifactBinding {
        let data = try inputRoot.readVerified(
            binding,
            maximumByteCount:
                PrimeSecureRunningExecutableCapture
                .maximumByteCount
        )
        let copied = try outputRoot.publish(
            data,
            at: binding.relativePath,
            purpose: binding.purpose
        )
        guard copied == binding else {
            throw PrimeNativeGenerationContractOverlayError
                .invalidParentAdapter(
                    "lossless evidence copy"
                )
        }
        return copied
    }
}
