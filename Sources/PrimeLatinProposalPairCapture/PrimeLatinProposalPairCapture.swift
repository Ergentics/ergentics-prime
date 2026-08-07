import Foundation

public enum PrimeLatinProposalPairCaptureError: Error, Equatable, Sendable {
    case invalidLocator(String)
    case invalidRoot(String)
    case invalidDocument(String)
    case invalidSemantics(String)
    case captureChanged
}

extension PrimeLatinProposalPairCaptureError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidLocator(value):
            "invalid Latin proposal-pair locator: \(value)"
        case let .invalidRoot(value):
            "invalid Latin proposal-pair root: \(value)"
        case let .invalidDocument(value):
            "invalid Latin proposal-pair document: \(value)"
        case let .invalidSemantics(value):
            "invalid Latin proposal-pair semantics: \(value)"
        case .captureChanged:
            "Latin proposal-pair capture changed"
        }
    }
}

public struct PrimeLatinProposalPairLocator: Equatable, Sendable {
    public let sha256: String
    public let relativePath: String

    public init(sha256: String) throws {
        guard PrimeLatinProposalPairContract.isSHA256(sha256) else {
            throw PrimeLatinProposalPairCaptureError.invalidLocator(sha256)
        }
        self.sha256 = sha256
        relativePath = PrimeLatinProposalPairContract.publicationRoot
            + "/pairs/\(sha256).json"
    }
}

public struct PrimeLatinProposalSourceObservation: Equatable, Sendable {
    public let repository: String
    public let commit: String
    public let tree: String

    fileprivate init(repository: String, commit: String, tree: String) {
        self.repository = repository
        self.commit = commit
        self.tree = tree
    }
}

public struct PrimeLatinProposalAuthorityBoundary: Equatable, Sendable {
    public let disposition: String
    public let referencedInputSnapshotAvailable: Bool
    public let independentReplayComplete: Bool
    public let llmGitStateIndependentlyObserved: Bool
    public let producerClaimsIndependentlyRecomputed: Bool
    public let primeProposalPacketProduced: Bool
    public let primeTrialAuthorizationProduced: Bool
    public let trialExecutionAuthorized: Bool
    public let furtherTrainingAuthorized: Bool
    public let promotionAuthorized: Bool
    public let productUseAuthorized: Bool

    fileprivate init() {
        disposition = "abstain_requires_original_bound_input_bytes"
        referencedInputSnapshotAvailable = false
        independentReplayComplete = false
        llmGitStateIndependentlyObserved = false
        producerClaimsIndependentlyRecomputed = false
        primeProposalPacketProduced = false
        primeTrialAuthorizationProduced = false
        trialExecutionAuthorized = false
        furtherTrainingAuthorized = false
        promotionAuthorized = false
        productUseAuthorized = false
    }
}

public struct PrimeLatinProposalPairObservation: Equatable, Sendable {
    public let pairReceiptSHA256: String
    public let llmSource: PrimeLatinProposalSourceObservation
    public let candidateIDs: [String]
    public let outputNamespace: String
    public let authority: PrimeLatinProposalAuthorityBoundary

    fileprivate init(
        pairReceiptSHA256: String,
        llmSource: PrimeLatinProposalSourceObservation,
        candidateIDs: [String],
        outputNamespace: String
    ) {
        self.pairReceiptSHA256 = pairReceiptSHA256
        self.llmSource = llmSource
        self.candidateIDs = candidateIDs
        self.outputNamespace = outputNamespace
        authority = PrimeLatinProposalAuthorityBoundary()
    }
}

/// A live, non-Codable capture of one exact mechanically published pair.
/// It is transport observation only; original referenced bytes remain absent.
public final class PrimeLatinProposalPairCapture: @unchecked Sendable {
    public let observation: PrimeLatinProposalPairObservation

    private let root: PrimeLatinArtifactRoot
    private let locator: PrimeLatinProposalPairLocator
    private let snapshot: PrimeLatinProposalPairSnapshot

    private init(
        root: PrimeLatinArtifactRoot,
        locator: PrimeLatinProposalPairLocator,
        snapshot: PrimeLatinProposalPairSnapshot
    ) {
        self.root = root
        self.locator = locator
        self.snapshot = snapshot
        observation = snapshot.observation
    }

    public static func capture(
        labRoot: URL,
        pairSHA256: String
    ) throws -> PrimeLatinProposalPairCapture {
        try PrimeLatinProposalPairContract.requireCanonicalRoot(labRoot)
        let locator = try PrimeLatinProposalPairLocator(sha256: pairSHA256)
        let root = try PrimeLatinArtifactRoot(directoryURL: labRoot)
        let first = try PrimeLatinProposalPairLoader.load(
            root: root, locator: locator)
        let second = try PrimeLatinProposalPairLoader.load(
            root: root, locator: locator)
        guard first == second else {
            throw PrimeLatinProposalPairCaptureError.captureChanged
        }
        return PrimeLatinProposalPairCapture(
            root: root, locator: locator, snapshot: second)
    }

    @discardableResult
    public func recaptureAndValidateUnchanged() throws
        -> PrimeLatinProposalPairObservation
    {
        let current = try PrimeLatinProposalPairLoader.load(
            root: root, locator: locator)
        guard current == snapshot else {
            throw PrimeLatinProposalPairCaptureError.captureChanged
        }
        return current.observation
    }

    public func ephemeralSummary() -> PrimeLatinProposalPairEphemeralSummary {
        PrimeLatinProposalPairEphemeralSummary(observation: observation)
    }
}

/// Encodable for stdout only; deliberately neither Decodable nor a receipt.
public struct PrimeLatinProposalPairEphemeralSummary:
    Encodable, Equatable, Sendable
{
    public let schema: String
    public let outcome: String
    public let claimScope: String
    public let pairReceiptSHA256: String
    public let llmRepository: String
    public let llmCommit: String
    public let llmTree: String
    public let candidateIDs: [String]
    public let outputNamespace: String
    public let disposition: String
    public let referencedInputSnapshotAvailable: Bool
    public let independentReplayComplete: Bool
    public let llmGitStateIndependentlyObserved: Bool
    public let producerClaimsIndependentlyRecomputed: Bool
    public let primeProposalPacketProduced: Bool
    public let primeTrialAuthorizationProduced: Bool
    public let trialExecutionAuthorized: Bool
    public let furtherTrainingAuthorized: Bool
    public let promotionAuthorized: Bool
    public let productUseAuthorized: Bool
    public let durableReceiptPublished: Bool
    public let ephemeralStandardOutputOnly: Bool

    fileprivate init(observation: PrimeLatinProposalPairObservation) {
        schema = "ergentics_prime_latin_proposal_pair_capture_summary_v1"
        outcome = "abstain"
        claimScope = "mechanics_transport_capture_only_non_authorizing"
        pairReceiptSHA256 = observation.pairReceiptSHA256
        llmRepository = observation.llmSource.repository
        llmCommit = observation.llmSource.commit
        llmTree = observation.llmSource.tree
        candidateIDs = observation.candidateIDs
        outputNamespace = observation.outputNamespace
        disposition = observation.authority.disposition
        referencedInputSnapshotAvailable =
            observation.authority.referencedInputSnapshotAvailable
        independentReplayComplete =
            observation.authority.independentReplayComplete
        llmGitStateIndependentlyObserved =
            observation.authority.llmGitStateIndependentlyObserved
        producerClaimsIndependentlyRecomputed =
            observation.authority.producerClaimsIndependentlyRecomputed
        primeProposalPacketProduced =
            observation.authority.primeProposalPacketProduced
        primeTrialAuthorizationProduced =
            observation.authority.primeTrialAuthorizationProduced
        trialExecutionAuthorized = observation.authority.trialExecutionAuthorized
        furtherTrainingAuthorized = observation.authority.furtherTrainingAuthorized
        promotionAuthorized = observation.authority.promotionAuthorized
        productUseAuthorized = observation.authority.productUseAuthorized
        durableReceiptPublished = false
        ephemeralStandardOutputOnly = true
    }

    public func canonicalData() throws -> Data {
        try PrimeLatinCanonicalJSON.encode(self)
    }
}

public enum PrimeLatinProposalPairCaptureArgumentError:
    Error, Equatable, Sendable
{
    case invalidArguments
}

extension PrimeLatinProposalPairCaptureArgumentError: LocalizedError {
    public var errorDescription: String? {
        "required arguments: --lab-root <absolute canonical path> --pair-sha256 <64 lowercase hexadecimal characters>"
    }
}

public struct PrimeLatinProposalPairCaptureArguments: Equatable, Sendable {
    public let labRoot: URL
    public let pairSHA256: String

    public static func parse(_ values: [String]) throws
        -> PrimeLatinProposalPairCaptureArguments
    {
        guard values.count == 4,
              values[0] == "--lab-root",
              values[2] == "--pair-sha256" else {
            throw PrimeLatinProposalPairCaptureArgumentError.invalidArguments
        }
        let rootValue = values[1]
        guard rootValue.hasPrefix("/"),
              !rootValue.utf8.contains(0) else {
            throw PrimeLatinProposalPairCaptureArgumentError.invalidArguments
        }
        let labRoot = URL(fileURLWithPath: rootValue, isDirectory: true)
        do {
            guard labRoot.path == rootValue else {
                throw PrimeLatinProposalPairCaptureArgumentError
                    .invalidArguments
            }
            try PrimeLatinProposalPairContract.requireCanonicalRoot(labRoot)
            _ = try PrimeLatinProposalPairLocator(sha256: values[3])
        } catch {
            throw PrimeLatinProposalPairCaptureArgumentError.invalidArguments
        }
        return Self(labRoot: labRoot, pairSHA256: values[3])
    }
}

private struct PrimeLatinProposalPairSnapshot: Equatable {
    let rootIdentity: PrimeLatinArtifactRootIdentity
    let observation: PrimeLatinProposalPairObservation
    let receiptFile: PrimeLatinVerifiedPublicationArtifact
    let catalogFile: PrimeLatinVerifiedPublicationArtifact
    let experimentFile: PrimeLatinVerifiedPublicationArtifact
    let receiptBinding: PrimeLatinCapturedArtifactBinding
    let catalogBinding: PrimeLatinCapturedArtifactBinding
    let experimentBinding: PrimeLatinCapturedArtifactBinding
    let receiptData: Data
    let catalogData: Data
    let experimentData: Data
}

private enum PrimeLatinProposalPairLoader {
    static func load(
        root: PrimeLatinArtifactRoot,
        locator: PrimeLatinProposalPairLocator
    ) throws -> PrimeLatinProposalPairSnapshot {
        let rootIdentity = try root.verifiedRootIdentity()
        let receiptBinding = try root.bindExisting(
            at: locator.relativePath,
            purpose: .immutableData,
            maximumByteCount:
                PrimeLatinProposalPairContract.maximumDocumentBytes)
        guard receiptBinding.sha256 == locator.sha256,
              receiptBinding.byteCount > 0 else {
            throw PrimeLatinProposalPairCaptureError
                .invalidDocument("pair_receipt_binding")
        }
        let receiptRead = try root.readVerifiedArtifact(
            receiptBinding,
            maximumByteCount:
                PrimeLatinProposalPairContract.maximumDocumentBytes)
        let receiptData = receiptRead.data
        let receipt = try decode(
            PrimeLatinPairReceipt.self,
            data: receiptData,
            path: locator.relativePath)
        try validate(receipt)

        let catalogBinding = try childBinding(
            receipt.candidateCatalog,
            kind: "candidate_catalog",
            directory: "catalogs")
        let experimentBinding = try childBinding(
            receipt.experimentManifest,
            kind: "experiment_manifest",
            directory: "experiments")
        let catalogRead = try root.readVerifiedArtifact(
            catalogBinding,
            maximumByteCount:
                PrimeLatinProposalPairContract.maximumDocumentBytes)
        let experimentRead = try root.readVerifiedArtifact(
            experimentBinding,
            maximumByteCount:
                PrimeLatinProposalPairContract.maximumDocumentBytes)
        let catalogData = catalogRead.data
        let experimentData = experimentRead.data
        let catalog = try decode(
            PrimeLatinCandidateCatalog.self,
            data: catalogData,
            path: catalogBinding.relativePath)
        let experiment = try decode(
            PrimeLatinExperimentManifest.self,
            data: experimentData,
            path: experimentBinding.relativePath)
        try validate(catalog)
        try validate(
            experiment,
            catalog: catalog,
            catalogData: catalogData)
        try validateBindingConsistency(
            catalog: catalog,
            experiment: experiment)

        let finalReceiptRead = try root.readVerifiedArtifact(
            receiptBinding,
            maximumByteCount:
                PrimeLatinProposalPairContract.maximumDocumentBytes)
        let finalCatalogRead = try root.readVerifiedArtifact(
            catalogBinding,
            maximumByteCount:
                PrimeLatinProposalPairContract.maximumDocumentBytes)
        let finalExperimentRead = try root.readVerifiedArtifact(
            experimentBinding,
            maximumByteCount:
                PrimeLatinProposalPairContract.maximumDocumentBytes)

        guard receipt.llmSource == catalog.llmSource,
              receipt.llmSource == experiment.llmSource,
              receipt.candidateCatalog.sha256
                == PrimeLatinSHA256.hexDigest(of: catalogData),
              receipt.candidateCatalog.byteCount
                == UInt64(catalogData.count),
              receipt.experimentManifest.sha256
                == PrimeLatinSHA256.hexDigest(of: experimentData),
              receipt.experimentManifest.byteCount
                == UInt64(experimentData.count),
              try root.verifiedRootIdentity() == rootIdentity,
              finalReceiptRead == receiptRead,
              finalCatalogRead == catalogRead,
              finalExperimentRead == experimentRead else {
            throw PrimeLatinProposalPairCaptureError.captureChanged
        }

        let observation = PrimeLatinProposalPairObservation(
            pairReceiptSHA256: locator.sha256,
            llmSource: PrimeLatinProposalSourceObservation(
                repository: receipt.llmSource.repository,
                commit: receipt.llmSource.commit,
                tree: receipt.llmSource.tree),
            candidateIDs: experiment.candidateIDs,
            outputNamespace: experiment.outputNamespace)
        return PrimeLatinProposalPairSnapshot(
            rootIdentity: rootIdentity,
            observation: observation,
            receiptFile: finalReceiptRead.artifact,
            catalogFile: finalCatalogRead.artifact,
            experimentFile: finalExperimentRead.artifact,
            receiptBinding: receiptBinding,
            catalogBinding: catalogBinding,
            experimentBinding: experimentBinding,
            receiptData: finalReceiptRead.data,
            catalogData: finalCatalogRead.data,
            experimentData: finalExperimentRead.data)
    }

    private static func decode<Value: Codable>(
        _ type: Value.Type,
        data: Data,
        path: String
    ) throws -> Value {
        guard !data.isEmpty,
              UInt64(data.count)
                <= PrimeLatinProposalPairContract.maximumDocumentBytes
        else {
            throw PrimeLatinProposalPairCaptureError
                .invalidDocument(path)
        }
        do {
            return try PrimeLatinCanonicalJSON.decode(
                type,
                from: data,
                artifact: path)
        } catch {
            throw PrimeLatinProposalPairCaptureError
                .invalidDocument(path)
        }
    }

    private static func childBinding(
        _ document: PrimeLatinPublishedDocument,
        kind: String,
        directory: String
    ) throws -> PrimeLatinCapturedArtifactBinding {
        try PrimeLatinProposalPairContract.requireSHA256(
            document.sha256)
        guard document.documentKind == kind,
              document.byteCount > 0,
              document.byteCount
                <= PrimeLatinProposalPairContract.maximumDocumentBytes,
              document.relativePath
                == PrimeLatinProposalPairContract.publicationRoot
                    + "/\(directory)/\(document.sha256).json" else {
            throw PrimeLatinProposalPairCaptureError
                .invalidDocument(kind)
        }
        return PrimeLatinCapturedArtifactBinding(
            relativePath: document.relativePath,
            sha256: document.sha256,
            byteCount: document.byteCount,
            purpose: .immutableData)
    }

    private static func validate(
        _ receipt: PrimeLatinPairReceipt
    ) throws {
        try PrimeLatinProposalPairContract.requireApprovedSource(
            receipt.llmSource)
        guard receipt.schema
                == PrimeLatinProposalPairContract.pairReceiptSchema,
              receipt.authorityStatus
                == "mechanics_only_non_authorizing",
              receipt.completionScope
                == "catalog_experiment_pair_only",
              receipt.referencedInputSnapshot == "absent",
              receipt.independentReplayStatus
                == "requires_original_bound_input_bytes",
              receipt.externalStateCommitAtomicity
                == "absent_live_roots_revalidated_before_receipt_rename",
              receipt.publicationCoordination
                == "cooperative_process_lock_only" else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("pair_receipt")
        }
        _ = try childBinding(
            receipt.candidateCatalog,
            kind: "candidate_catalog",
            directory: "catalogs")
        _ = try childBinding(
            receipt.experimentManifest,
            kind: "experiment_manifest",
            directory: "experiments")
    }

    private static func validate(
        _ catalog: PrimeLatinCandidateCatalog
    ) throws {
        try PrimeLatinProposalPairContract.requireApprovedSource(
            catalog.llmSource)
        guard catalog.schema
                == PrimeLatinProposalPairContract.catalogSchema,
              catalog.laneID
                == PrimeLatinProposalPairContract.laneID,
              catalog.ergenticsMLXLocation
                == PrimeLatinProposalPairContract.ergenticsMLXLocation,
              catalog.ergenticsMLXRevision
                == PrimeLatinProposalPairContract.ergenticsMLXRevision,
              catalog.quarantinePolicyID
                == PrimeLatinProposalPairContract.quarantinePolicyID,
              catalog.authorityStatus
                == "root_bound_proposal_input_only_non_authorizing"
        else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("candidate_catalog")
        }
        try PrimeLatinProposalPairContract.requireBinding(
            catalog.packageManifest,
            scope: .ergenticsLLMRepository)
        try PrimeLatinProposalPairContract.requireBinding(
            catalog.dependencyLock,
            scope: .ergenticsLLMRepository)
        try PrimeLatinProposalPairContract.requireBinding(
            catalog.tokenizerManifest,
            scope: .ergenticsMLXLab)
        try PrimeLatinProposalPairContract.requireBinding(
            catalog.initializationContract,
            scope: .ergenticsMLXLab)
        guard catalog.packageManifest.relativePath == "Package.swift",
              catalog.packageManifest.sha256
                == PrimeLatinProposalPairContract.packageManifestSHA256,
              catalog.packageManifest.byteCount
                == PrimeLatinProposalPairContract.packageManifestByteCount,
              catalog.dependencyLock.relativePath == "Package.resolved",
              catalog.dependencyLock.sha256
                == PrimeLatinProposalPairContract.dependencyLockSHA256,
              catalog.dependencyLock.byteCount
                == PrimeLatinProposalPairContract.dependencyLockByteCount,
              !catalog.candidates.isEmpty,
              catalog.candidates.count <= 64 else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("catalog_bindings")
        }

        let candidateIDs = catalog.candidates.map(\.candidateID)
        guard candidateIDs == candidateIDs.sorted(),
              Set(candidateIDs).count == candidateIDs.count,
              Set(catalog.candidates.map(\.declarationSHA256)).count
                == catalog.candidates.count else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("candidate_order")
        }
        for candidate in catalog.candidates {
            try PrimeLatinProposalPairContract.requireLatinIdentifier(
                candidate.candidateID)
            try PrimeLatinProposalPairContract.requireIdentifier(
                candidate.sourceAttribution)
            try PrimeLatinProposalPairContract.requireSHA256(
                candidate.declarationSHA256)
            try PrimeLatinProposalPairContract.requireBinding(
                candidate.architectureDeclaration,
                scope: .ergenticsLLMRepository)
            try PrimeLatinProposalPairContract.requireBinding(
                candidate.implementationSource,
                scope: .ergenticsLLMRepository)
            try PrimeLatinProposalPairContract.requireBinding(
                candidate.parameterCountDerivation,
                scope: .ergenticsLLMRepository)
            guard candidate.sourceKind == "contributor_declared",
                  candidate.attributionAssurance
                    == "trusted_local_declaration",
                  !candidate.cryptographicHumanAuthentication,
                  !candidate.sourceAttribution.lowercased().contains("prime"),
                  candidate.declarationSHA256
                    == candidate.architectureDeclaration.sha256,
                  candidate.parameterCount > 0 else {
                throw PrimeLatinProposalPairCaptureError
                    .invalidSemantics("candidate")
            }
        }

        let implementations = catalog.candidates
            .map(\.implementationSource)
            .sorted { $0.relativePath < $1.relativePath }
        let quarantine = catalog.dependencyQuarantine
        guard quarantine.policyID
                == PrimeLatinProposalPairContract.quarantinePolicyID,
              quarantine.packageManifest == catalog.packageManifest,
              quarantine.dependencyLock == catalog.dependencyLock,
              quarantine.candidateImplementationSources == implementations,
              quarantine.authorityTargetDependencyCount == 0,
              quarantine.lockfilePinScanComplete,
              quarantine.status == "producer_recomputed_pass" else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("dependency_quarantine")
        }
    }

    private static func validate(
        _ experiment: PrimeLatinExperimentManifest,
        catalog: PrimeLatinCandidateCatalog,
        catalogData: Data
    ) throws {
        try PrimeLatinProposalPairContract.requireApprovedSource(
            experiment.llmSource)
        guard experiment.schema
                == PrimeLatinProposalPairContract.experimentSchema,
              experiment.laneID == PrimeLatinProposalPairContract.laneID,
              experiment.candidateCatalogSHA256
                == PrimeLatinSHA256.hexDigest(of: catalogData),
              experiment.candidateCatalogByteCount
                == UInt64(catalogData.count),
              experiment.candidateIDs == catalog.candidates.map(\.candidateID),
              experiment.dependencyLock == catalog.dependencyLock,
              experiment.tokenizerManifest == catalog.tokenizerManifest,
              experiment.initializationContract
                == catalog.initializationContract,
              experiment.outputDisposition
                == "must_be_absent_create_once_non_restorable" else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("experiment_cross_binding")
        }
        try PrimeLatinProposalPairContract.requireBinding(
            experiment.corpusManifest,
            scope: .ergenticsMLXLab)
        try PrimeLatinProposalPairContract.requireBinding(
            experiment.evaluationContract,
            scope: .ergenticsLLMRepository)

        let splits = experiment.splits
        for identifier in [
            splits.trainingSplitID,
            splits.validationSplitID,
            splits.selectionSplitID,
        ] {
            try PrimeLatinProposalPairContract.requireLatinIdentifier(identifier)
        }
        guard Set([
            splits.trainingSplitID,
            splits.validationSplitID,
            splits.selectionSplitID,
        ]).count == 3,
              !splits.selectionSplitID.lowercased().contains("holdout"),
              !splits.selectionSplitID.lowercased().contains("primary_v1"),
              splits.selectionDataStatus
                == "trusted_local_declared_unverified" else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("splits")
        }
        let splitBindings = [
            splits.trainingSplit,
            splits.validationSplit,
            splits.selectionSplit,
            splits.selectionObservationDeclaration,
        ]
        for binding in splitBindings {
            try PrimeLatinProposalPairContract.requireBinding(
                binding,
                scope: .ergenticsMLXLab)
        }
        guard Set(splitBindings.map {
            "\($0.scope.rawValue):\($0.relativePath)"
        }).count == splitBindings.count,
              Set([
                splits.trainingSplit.sha256,
                splits.validationSplit.sha256,
                splits.selectionSplit.sha256,
              ]).count == 3 else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("split_bindings")
        }

        let budget = experiment.requestedTrialBudget
        guard budget.application
                == "identical_per_candidate_requested_ceiling",
              budget.optimizerSteps > 0,
              budget.trainingTokens > 0,
              budget.wallClockSeconds > 0 else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("trial_budget")
        }
        try PrimeLatinProposalPairContract.requireRelativePath(
            experiment.outputNamespace)
        guard experiment.outputNamespace.hasPrefix(
                PrimeLatinProposalPairContract.outputNamespacePrefix),
              !experiment.outputNamespace.lowercased().contains(
                "ergentics_latin_primary_v1") else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("output_namespace")
        }
        let authority = experiment.authority
        guard authority.primeProposalPacket == "absent",
              authority.primeTrialAuthorization == "absent",
              !authority.trialExecutionAuthorized,
              !authority.furtherTrainingAuthorized,
              !authority.promotionAuthorized,
              !authority.productUseAuthorized else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("experiment_authority")
        }
    }

    private static func validateBindingConsistency(
        catalog: PrimeLatinCandidateCatalog,
        experiment: PrimeLatinExperimentManifest
    ) throws {
        var bindings = [
            catalog.packageManifest,
            catalog.dependencyLock,
            catalog.tokenizerManifest,
            catalog.initializationContract,
            experiment.dependencyLock,
            experiment.corpusManifest,
            experiment.tokenizerManifest,
            experiment.initializationContract,
            experiment.evaluationContract,
            experiment.splits.trainingSplit,
            experiment.splits.validationSplit,
            experiment.splits.selectionSplit,
            experiment.splits.selectionObservationDeclaration,
            catalog.dependencyQuarantine.packageManifest,
            catalog.dependencyQuarantine.dependencyLock,
        ]
        for candidate in catalog.candidates {
            bindings.append(candidate.architectureDeclaration)
            bindings.append(candidate.implementationSource)
            bindings.append(candidate.parameterCountDerivation)
        }
        bindings.append(contentsOf:
            catalog.dependencyQuarantine.candidateImplementationSources)

        var identityByLocation =
            [String: (sha256: String, byteCount: UInt64)]()
        var byteCountBySHA256 = [String: UInt64]()
        for binding in bindings {
            if binding.scope == .ergenticsMLXLab,
               pathsOverlap(
                   binding.relativePath,
                   experiment.outputNamespace) {
                throw PrimeLatinProposalPairCaptureError
                    .invalidSemantics("input_output_path_overlap")
            }
            let location =
                "\(binding.scope.rawValue)\u{0}" +
                binding.relativePath.lowercased()
            if let existing = identityByLocation[location],
               existing.sha256 != binding.sha256
                || existing.byteCount != binding.byteCount {
                throw PrimeLatinProposalPairCaptureError
                    .invalidSemantics("inconsistent_artifact_location")
            }
            identityByLocation[location] = (
                binding.sha256,
                binding.byteCount)

            if let existing = byteCountBySHA256[binding.sha256],
               existing != binding.byteCount {
                throw PrimeLatinProposalPairCaptureError
                    .invalidSemantics("inconsistent_artifact_hash")
            }
            byteCountBySHA256[binding.sha256] = binding.byteCount
        }

        var strictRoles = [
            ("package_manifest", catalog.packageManifest),
            ("dependency_lock", catalog.dependencyLock),
            ("tokenizer_manifest", catalog.tokenizerManifest),
            ("initialization_contract", catalog.initializationContract),
            ("corpus_manifest", experiment.corpusManifest),
            ("evaluation_contract", experiment.evaluationContract),
            ("training_split", experiment.splits.trainingSplit),
            ("validation_split", experiment.splits.validationSplit),
            ("selection_split", experiment.splits.selectionSplit),
            (
                "selection_observation_declaration",
                experiment.splits.selectionObservationDeclaration
            ),
        ]
        for candidate in catalog.candidates {
            strictRoles.append((
                "candidate_architecture:\(candidate.candidateID)",
                candidate.architectureDeclaration
            ))
            strictRoles.append((
                "candidate_parameter_derivation:\(candidate.candidateID)",
                candidate.parameterCountDerivation
            ))
        }
        var strictRoleBySHA256 = [String: String]()
        for (role, binding) in strictRoles {
            if strictRoleBySHA256.updateValue(
                role,
                forKey: binding.sha256
            ) != nil {
                throw PrimeLatinProposalPairCaptureError
                    .invalidSemantics("aliased_strict_artifact_roles")
            }
        }
    }

    private static func pathsOverlap(
        _ first: String,
        _ second: String
    ) -> Bool {
        let firstComponents = first.lowercased().split(separator: "/")
        let secondComponents = second.lowercased().split(separator: "/")
        let sharedCount = min(firstComponents.count, secondComponents.count)
        return firstComponents.prefix(sharedCount)
            == secondComponents.prefix(sharedCount)
    }
}

private enum PrimeLatinProposalPairContract {
    static let forbiddenContext = [
        "llama",
        "mlxllm",
        "mlx-swift-lm",
        "mlx_swift_lm",
        "mlx-community",
        "huggingface",
        "runtime-bundle-3b",
        "primecore",
        "pmhnp",
        "ml-explore/mlx-swift",
    ]
    static let publicationRoot = "evidence/latin-proposal-artifacts"
    static let pairReceiptSchema =
        "ergentics_latin_proposal_pair_receipt_v1"
    static let catalogSchema =
        "ergentics_latin_candidate_catalog_v1"
    static let experimentSchema =
        "ergentics_latin_experiment_manifest_v1"
    static let laneID = "latin_primary_prospective_v1"
    static let repository = "Ergentics/ergentics-llm"
    static let approvedCommit =
        "81cc7ee8e58ad7f3c917b0c32ae55c09d5606e1b"
    static let approvedTree =
        "01c7f0045e30e79cd4154ef00345f6d6a29d137a"
    static let ergenticsMLXLocation =
        "https://github.com/Ergentics/ergentics-mlx-swift"
    static let ergenticsMLXRevision =
        "d37885a278f1c37484a94d0f401a418735e66519"
    static let packageManifestSHA256 =
        "ab460122d5f364046224c6445a20f3beb34e2831de94db1271bbafb59726c902"
    static let packageManifestByteCount: UInt64 = 6_109
    static let dependencyLockSHA256 =
        "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530"
    static let dependencyLockByteCount: UInt64 = 645
    static let quarantinePolicyID =
        "ergentics_latin_first_party_dependency_quarantine_v1"
    static let outputNamespacePrefix = "models/latin-prospective/"
    static let maximumDocumentBytes: UInt64 = 1_048_576

    static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    static func requireSHA256(_ value: String) throws {
        guard isSHA256(value) else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("sha256")
        }
    }

    static func isGitOID(_ value: String) -> Bool {
        value.utf8.count == 40 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    static func requireApprovedSource(
        _ source: PrimeLatinLLMSource
    ) throws {
        guard isGitOID(source.commit),
              isGitOID(source.tree),
              source.repository == repository,
              source.commit == approvedCommit,
              source.tree == approvedTree else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("unapproved_llm_source")
        }
    }

    static func requireIdentifier(_ value: String) throws {
        guard !value.isEmpty,
              value.utf8.count <= 128,
              value.utf8.allSatisfy({
                ($0 >= 97 && $0 <= 122)
                    || ($0 >= 48 && $0 <= 57)
                    || $0 == 45
                    || $0 == 46
                    || $0 == 95
              }) else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("identifier")
        }
        try requireNoForbiddenContext(value)
    }

    static func requireLatinIdentifier(_ value: String) throws {
        try requireIdentifier(value)
        guard value.hasPrefix("latin_")
                || value.hasPrefix("ergentics_latin_") else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("latin_identifier")
        }
    }

    static func requireRelativePath(_ value: String) throws {
        guard !value.isEmpty,
              value.utf8.count <= 1_024,
              !value.hasPrefix("/"),
              !value.hasSuffix("/"),
              !value.contains("\\"),
              value.split(
                separator: "/",
                omittingEmptySubsequences: false
              ).allSatisfy({ component in
                !component.isEmpty
                    && component != "."
                    && component != ".."
                    && component.utf8.allSatisfy({
                        ($0 >= 65 && $0 <= 90)
                            || ($0 >= 97 && $0 <= 122)
                            || ($0 >= 48 && $0 <= 57)
                            || $0 == 45
                            || $0 == 46
                            || $0 == 95
                    })
              }) else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("relative_path")
        }
        try requireNoForbiddenContext(value)
    }

    static func requireNoForbiddenContext(
        _ value: String
    ) throws {
        let normalized = value.lowercased()
        guard !forbiddenContext.contains(where: normalized.contains) else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("forbidden_dependency_context")
        }
    }

    static func requireBinding(
        _ binding: PrimeLatinArtifactBinding,
        scope: PrimeLatinArtifactScope
    ) throws {
        let normalizedRelativePath = binding.relativePath.lowercased()
        guard binding.scope == scope,
              binding.byteCount > 0,
              !(binding.scope == .ergenticsMLXLab
                && (normalizedRelativePath == publicationRoot
                    || normalizedRelativePath.hasPrefix(
                        publicationRoot + "/"))) else {
            throw PrimeLatinProposalPairCaptureError
                .invalidSemantics("artifact_binding")
        }
        try requireRelativePath(binding.relativePath)
        try requireSHA256(binding.sha256)
    }

    static func requireCanonicalRoot(_ root: URL) throws {
        let path = root.path
        guard root.isFileURL, path.hasPrefix("/"), path != "/",
              !path.utf8.contains(0),
              root.standardizedFileURL.path == path,
              root.resolvingSymlinksInPath().standardizedFileURL.path == path
        else {
            throw PrimeLatinProposalPairCaptureError.invalidRoot(path)
        }
    }
}

private struct PrimeLatinLLMSource:
    Codable,
    Equatable,
    Sendable
{
    let repository: String
    let commit: String
    let tree: String
}

private struct PrimeLatinPublishedDocument:
    Codable,
    Equatable,
    Sendable
{
    let documentKind: String
    let relativePath: String
    let sha256: String
    let byteCount: UInt64
}

private struct PrimeLatinPairReceipt:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let llmSource: PrimeLatinLLMSource
    let candidateCatalog: PrimeLatinPublishedDocument
    let experimentManifest: PrimeLatinPublishedDocument
    let authorityStatus: String
    let completionScope: String
    let referencedInputSnapshot: String
    let independentReplayStatus: String
    let externalStateCommitAtomicity: String
    let publicationCoordination: String
}

private enum PrimeLatinArtifactScope:
    String,
    Codable,
    Sendable
{
    case ergenticsLLMRepository = "ergentics_llm_repository"
    case ergenticsMLXLab = "ergentics_mlx_lab"
}

private struct PrimeLatinArtifactBinding:
    Codable,
    Equatable,
    Sendable
{
    let scope: PrimeLatinArtifactScope
    let relativePath: String
    let sha256: String
    let byteCount: UInt64
}

private struct PrimeLatinCandidateRecord:
    Codable,
    Equatable,
    Sendable
{
    let candidateID: String
    let sourceKind: String
    let sourceAttribution: String
    let attributionAssurance: String
    let cryptographicHumanAuthentication: Bool
    let declarationSHA256: String
    let architectureDeclaration: PrimeLatinArtifactBinding
    let implementationSource: PrimeLatinArtifactBinding
    let parameterCount: UInt64
    let parameterCountDerivation: PrimeLatinArtifactBinding
}

private struct PrimeLatinDependencyQuarantine:
    Codable,
    Equatable,
    Sendable
{
    let policyID: String
    let packageManifest: PrimeLatinArtifactBinding
    let dependencyLock: PrimeLatinArtifactBinding
    let candidateImplementationSources: [PrimeLatinArtifactBinding]
    let authorityTargetDependencyCount: UInt64
    let lockfilePinScanComplete: Bool
    let status: String
}

private struct PrimeLatinCandidateCatalog:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let laneID: String
    let llmSource: PrimeLatinLLMSource
    let packageManifest: PrimeLatinArtifactBinding
    let dependencyLock: PrimeLatinArtifactBinding
    let tokenizerManifest: PrimeLatinArtifactBinding
    let initializationContract: PrimeLatinArtifactBinding
    let candidates: [PrimeLatinCandidateRecord]
    let ergenticsMLXLocation: String
    let ergenticsMLXRevision: String
    let quarantinePolicyID: String
    let dependencyQuarantine: PrimeLatinDependencyQuarantine
    let authorityStatus: String
}

private struct PrimeLatinTrialBudget:
    Codable,
    Equatable,
    Sendable
{
    let application: String
    let optimizerSteps: UInt64
    let trainingTokens: UInt64
    let wallClockSeconds: UInt64
}

private struct PrimeLatinSplitSet:
    Codable,
    Equatable,
    Sendable
{
    let trainingSplitID: String
    let validationSplitID: String
    let selectionSplitID: String
    let selectionDataStatus: String
    let trainingSplit: PrimeLatinArtifactBinding
    let validationSplit: PrimeLatinArtifactBinding
    let selectionSplit: PrimeLatinArtifactBinding
    let selectionObservationDeclaration: PrimeLatinArtifactBinding
}

private struct PrimeLatinNonAuthorityBoundary:
    Codable,
    Equatable,
    Sendable
{
    let primeProposalPacket: String
    let primeTrialAuthorization: String
    let trialExecutionAuthorized: Bool
    let furtherTrainingAuthorized: Bool
    let promotionAuthorized: Bool
    let productUseAuthorized: Bool
}

private struct PrimeLatinExperimentManifest:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let laneID: String
    let llmSource: PrimeLatinLLMSource
    let candidateCatalogSHA256: String
    let candidateCatalogByteCount: UInt64
    let candidateIDs: [String]
    let dependencyLock: PrimeLatinArtifactBinding
    let corpusManifest: PrimeLatinArtifactBinding
    let tokenizerManifest: PrimeLatinArtifactBinding
    let initializationContract: PrimeLatinArtifactBinding
    let evaluationContract: PrimeLatinArtifactBinding
    let splits: PrimeLatinSplitSet
    let requestedTrialBudget: PrimeLatinTrialBudget
    let outputNamespace: String
    let outputDisposition: String
    let authority: PrimeLatinNonAuthorityBoundary
}
